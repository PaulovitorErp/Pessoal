#INCLUDE "MNTA904.ch"
#INCLUDE "PROTHEUS.CH"
#INCLUDE "DbTree.ch"

#DEFINE __FOLDER_CTT__ 01 //CENTRO DE CUSTO
#DEFINE __FOLDER_SHB__ 02 //CENTRO DE TRABALHO
#DEFINE __FOLDER_ST6__ 03 //FAMILIA
#DEFINE __FOLDER_TQR__ 04 //TIPO MODELO
#DEFINE __FOLDER_STD__ 05 //AREA MANUTENCAO
#DEFINE __FOLDER_STE__ 06 //TIPO MANUTENCAO
#DEFINE __FOLDER_ST4__ 07 //SERVICO
#DEFINE __FOLDER_TAF__ 08 //LOCALIZACAO
#DEFINE __FOLDER_TUA__ 09 //SOLICITACOES
#DEFINE __FOLDER_ST9__ 00 // Bem

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Programa  ³ MNTA904   ³ Autor ³Vitor Emanuel Batista ³ Data ³14/06/2010³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³Programa para configurar a restricao de acesso a usuarios e ³±±
±±³          ³grupo de usuarios na Arvore Logica                          ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³SIGAMNT                                                     ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function MNTA904()

	Local aNGBeginPrm := {}

	If !FindFunction( 'MNTAmIIn' ) .Or. MNTAmIIn( 19, 95 )

		aNGBeginPrm := NGBeginPrm()

		Private aRotina   := MenuDef()
		Private cCadastro := STR0001   // Restrição de Acesso
		Private aTrocaF3  := {}

		// Ajuste de base na tabela TUB.
		MNTA904UPD()

		dbSelectArea("TUA")
		dbSetOrder(1)
		mBrowse(6,1,22,75,"TUA")

		NGReturnPrm( aNGBeginPrm )

	EndIf

Return

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³ MNT904PER ³ Autor ³Vitor Emanuel Batista ³ Data ³14/06/2010³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³Visualizacao, Inclusao, Alteracao e Exclusao das Permissoes ³±±
±±³          ³de usuario na Arvore Logica                                 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³MNTA904                                                     ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function MNT904PER(cAlias,nRecno,nOpc)

	Local oDlg
	Local oTFolder
	Local oPanel
	Local oMenuTree
	Local nY
	Local lDistri := NGCADICBASE("TUA_INFARE","A","TUA",.F.)
	Local nLenArr := 8+If(lDistri,1,0)

	//Variaveis da Enchoice
	Local oEnchoice, oEncFac
	Local aCposFac := aNao := {} // Retirado campos que estavam sendo ocultados da tela.
	Local aChoice  := NGCAMPNSX3("TUA",aNao)

	//Objetos de pesquisa
	Local oPnlSearch
	Local oCBoxSearch
	Local oGetSearch
	Local oBtnSearch

	//Objetos MsSelect
	Local oMarkCTT
	Local oMarkSHB
	Local oMarkST6
	Local oMarkTQR
	Local oMarkSTD
	Local oMarkSTE
	Local oMarkST4

	//Array com o tamanho do Dialog
	Local aSize     := MsAdvSize(,.F.,430)
	Local nAltura   := aSize[6]
	Local nLargura  := aSize[5]

	//Indica confirmacao do cadastro
	Local lConfirm  := .F.
	Local cCombo

	//Variaveis de controle no MsSelect
	Local lInverte  := .F.

	Private cMarca  := GetMark()
	Private oBtnMark, oBtnVisual, oBtnLeg

	//Array de controle de Variaveis e objetos do Folder
	Private aTables    := Array(nLenArr)
	Private aTFolder   := Array(nLenArr)
	Private aObjects   := Array(nLenArr)
	Private aIndex     := Array(nLenArr)
	Private aAlias     := Array(nLenArr)
	Private aUniqueKey := Array(nLenArr)
	Private aArqTRB    := Array(nLenArr)

	//Indica Alias e Posicao do Folder atual
	Private cAliasAtu
	Private nFolderAtu := 1

	//Conteudo do TGet de pesquisa
	Private cGetSearch := Space(100)

	Private aTelaTUA   := {}, aGetsTUA := {}
	Private aTelaFac   := {}, aGetsFac := {}

	//TRB para o Centro de Custo
	Private cTRBCTT    := GetNextAlias()
	Private aCTTHeader := {}

	//TRB para o Centro de Trabalho
	Private cTRBSHB    := GetNextAlias()
	Private aSHBHeader := {}

	//TRB para a Familia de Bens
	Private cTRBST6    := GetNextAlias()
	Private aST6Header := {}

	//TRB para o Tipo de Modelo
	Private cTRBTQR    := GetNextAlias()
	Private aTQRHeader := {}

	//TRB para o
	Private cTRBSTD    := GetNextAlias()
	Private aSTDHeader := {}

	//TRB para o
	Private cTRBST4    := GetNextAlias()
	Private aST4Header := {}

	//TRB para o
	Private cTRBSTE    := GetNextAlias()
	Private aSTEHeader := {}

	//TRB para o
	Private cTRBTAF    := GetNextAlias()

	Private oTmpTbl1
	Private oTmpTbl2

	Private nMaxNivel
	Private aVetInr    := {}
	Private aMarkTree  := {}

	//+-----------------------------------------+
	//| Inicializa variaveis de memoria da TUA  |
	//+-----------------------------------------+
	dbSelectArea("TUA")
	dbSetOrder(1)
	RegToMemory("TUA", nOpc == 3)


	//Carrega array de controle de tabelas temporarias
	aTables[__FOLDER_CTT__] := cTRBCTT
	aTables[__FOLDER_SHB__] := cTRBSHB
	aTables[__FOLDER_ST6__] := cTRBST6
	aTables[__FOLDER_TQR__] := cTRBTQR
	aTables[__FOLDER_STD__] := cTRBSTD
	aTables[__FOLDER_STE__] := cTRBSTE
	aTables[__FOLDER_ST4__] := cTRBST4
	aTables[__FOLDER_TAF__] := cTRBTAF
	If lDistri
		aTables[__FOLDER_TUA__] := "TUA"
	EndIf
	cAliasAtu := aTables[1]

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Carrega array com os descritivos do Folder ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	aTFolder[__FOLDER_CTT__] := STR0030 //"Centro de Custo"
	aTFolder[__FOLDER_SHB__] := STR0031 //"Centro de Trabalho"
	aTFolder[__FOLDER_ST6__] := STR0032 //"Família"
	aTFolder[__FOLDER_TQR__] := STR0033 //"Tipo Modelo"
	aTFolder[__FOLDER_STD__] := STR0034 //"Área Manutenção"
	aTFolder[__FOLDER_STE__] := STR0035 //"Tipo Manutenção"
	aTFolder[__FOLDER_ST4__] := STR0036 //"Serviço"
	aTFolder[__FOLDER_TAF__] := STR0037 //"Árvore"
	If lDistri
		aTFolder[__FOLDER_TUA__] := STR0038 //"Abertura de Solicitação"
	EndIf

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Carrega array de controle de tabelas do MsSelect³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	aAlias[__FOLDER_CTT__] := "CTT"
	aAlias[__FOLDER_SHB__] := "SHB"
	aAlias[__FOLDER_ST6__] := "ST6"
	aAlias[__FOLDER_TQR__] := "TQR"
	aAlias[__FOLDER_STD__] := "STD"
	aAlias[__FOLDER_STE__] := "STE"
	aAlias[__FOLDER_ST4__] := "ST4"
	aAlias[__FOLDER_TAF__] := "TAF"
	If lDistri
		aAlias[__FOLDER_TUA__] := "TQB"
	EndIf

	//+---------------------------------------------+
	//| Carrega array com chave unica das tabelas   |
	//+---------------------------------------------+
	aUniqueKey[__FOLDER_CTT__] := "CTT_CUSTO"
	aUniqueKey[__FOLDER_SHB__] := "HB_COD"
	aUniqueKey[__FOLDER_ST6__] := "T6_CODFAMI"
	aUniqueKey[__FOLDER_TQR__] := "TQR_TIPMOD"
	aUniqueKey[__FOLDER_STD__] := "TD_CODAREA"
	aUniqueKey[__FOLDER_STE__] := "TE_TIPOMAN"
	aUniqueKey[__FOLDER_ST4__] := "T4_SERVICO"
	aUniqueKey[__FOLDER_TAF__] := "TAF_CODNIV"
	If lDistri
		aUniqueKey[__FOLDER_TUA__] := "TQB_GRPUSR"
	EndIf

	//+-----------------------------------------------------+
	//| Seta Visual, Inclui, Altera ou Exclui conforme nOpc |
	//+-----------------------------------------------------+
	aRotSetOpc(cAlias,nRecno,nOpc)

	DEFINE MsDialog oDlg Title cCadastro From aSize[7],0 To nAltura,nLargura COLOR CLR_BLACK,CLR_WHITE Pixel

	//+--------------------------------+
	//| Cria Enchoice para tabela TUA  |
	//+--------------------------------+
	aTela                := {}
	aGets                := {}
	oEnchoice            := MsMGet():New("TUA",nRecno,nOpc,,,,aChoice,{0,0,105,0},,3)
	oEnchoice:oBox:Align := CONTROL_ALIGN_TOP

	aTelaTUA             := aClone(aTela)
	aGetsTUA             := aClone(aGets)

	//+-----------------------------------------------------+
	//| Cria Panel pai dos objetos inferiores ao MsSelect 	|
	//+-----------------------------------------------------+
	oPanel               := TPanel():New(0,0,,oDlg,,,,,CLR_WHITE,0,0,.T.,.T.)
	oPanel:Align         := CONTROL_ALIGN_ALLCLIENT

	//+------------------------------------------------+
	//| Cria Panel com botoes de suporte ao MsSelect   |
	//+------------------------------------------------+
	oPnlBtn              := TPanel():New(0,0,,oPanel,,,,,RGB(67,70,87),13,0,.F.,.F.)
	oPnlBtn:Align        := CONTROL_ALIGN_LEFT

	oPnlAux              := TPanel():New(0,0,,oPnlBtn,,,,,RGB(67,70,87),0,10,.F.,.F.)
	oPnlAux:Align        := CONTROL_ALIGN_TOP

	oBtnVisual           := TBtnBmp():NewBar("ng_ico_visualizar","ng_ico_visualizar",,,,{|| Visualize(cAliasAtu,aAlias[nFolderAtu])},,oPnlBtn)
	oBtnVisual:cToolTip  := STR0026 //"Visualizar Registro"
	oBtnVisual:Align     := CONTROL_ALIGN_TOP

	oBtnMark             := TBtnBmp():NewBar("ng_ico_etapa","ng_ico_etapa",,,,{|| MarkTree(aObjects[__FOLDER_TAF__],aTables[__FOLDER_TAF__])},,oPnlBtn)
	oBtnMark:cToolTip    := STR0002 //"Marcar/Desmarcar"
	oBtnMark:Align       := CONTROL_ALIGN_TOP
	oBtnMark:Hide()

	oBtnLeg              := TBtnBmp():NewBar("ng_ico_lgndos","ng_ico_lgndos",,,,{|| fLegenda()},,oPnlBtn)
	oBtnLeg:cToolTip     := STR0039 //"Legenda"
	oBtnLeg:Align        := CONTROL_ALIGN_TOP
	oBtnLeg:Hide()

	oBtnRefresh          := TBtnBmp():NewBar("ng_ico_refresh","ng_ico_refresh",,,,{|| Processa({|| RemakeTree(aTables,aObjects[__FOLDER_TAF__]) },STR0003, STR0004) },,oPnlBtn)			 //"Aguarde..."###"Reiniciando Variáveis..."
	oBtnRefresh:cToolTip := STR0005 //"Refazer Filtro"
	oBtnRefresh:Align    := CONTROL_ALIGN_TOP
	oBtnRefresh:Hide()

	//+-------------------------------------------------------+
	//| Cria Folder com todos os dados possiveis de permissao |
	//+-------------------------------------------------------+
	oTFolder            := TFolder():New( 0,0,aTFolder,,oPanel,,,,.T.,,0,aSize[6] )
	oTFolder:Align      := CONTROL_ALIGN_ALLCLIENT
	oTFolder:bSetOption := {|nOption| ChangeOption(nOption,aTables,oCBoxSearch,aIndex,aObjects)}

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Carrega dados do Centro de Custo ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	Processa({|| LoadTrb(__FOLDER_CTT__,@aCTTHeader)},STR0003, STR0006) //"Aguarde..."##"Carregando dados de Centro de Custo..."

	oMarkCTT                     := MsSelect():New(cTRBCTT,"TRB_OK",,aCTTHeader,@lInverte,@cMarca,,,,oTFolder:aDIALOGS[1])
	oMarkCTT:oBrowse:Align       := CONTROL_ALIGN_ALLCLIENT
	oMarkCTT:oBrowse:bAllMark    := { || MarkInverte(cMarca,cTRBCTT) }
	oMarkCTT:oBrowse:lHasMark    := .T.
	oMarkCTT:oBrowse:lCanAllMark := .T.

	If !Inclui .And. !Altera//Nao permite marcacao na visualizacao
		oMarkCTT:bMark := {|| If(Empty((cTRBCTT)->TRB_OK),(cTRBCTT)->TRB_OK := cMarca, (cTRBCTT)->TRB_OK := Space(2))}
	EndIf

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Carrega dados do Centro de Trabalho³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	Processa({|| LoadTrb(__FOLDER_SHB__,@aSHBHeader)},STR0003, STR0007) //"Aguarde..."##"Carregando dados de Centro de Trabalho..."

	oMarkSHB                     := MsSelect():New(cTRBSHB,"TRB_OK",,aSHBHeader,@lInverte,@cMarca,,,,oTFolder:aDIALOGS[2])
	oMarkSHB:oBrowse:Align       := CONTROL_ALIGN_ALLCLIENT
	oMarkSHB:oBrowse:bAllMark    := { || MarkInverte(cMarca,cTRBSHB) }
	oMarkSHB:oBrowse:lHasMark    := .T.
	oMarkSHB:oBrowse:lCanAllMark := .T.

	If !Inclui .And. !Altera//Nao permite marcacao na visualizacao
		oMarkSHB:bMark := {|| If(Empty((cTRBSHB)->TRB_OK),(cTRBSHB)->TRB_OK := cMarca, (cTRBSHB)->TRB_OK := Space(2))}
	EndIf

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Carrega dados da Familia de Bens   ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	Processa({|| LoadTrb(__FOLDER_ST6__,@aST6Header)},STR0003, STR0008) //"Aguarde..."##"Carregando dados da Família de Bens..."

	oMarkST6                     := MsSelect():New(cTRBST6,"TRB_OK",,aST6Header,@lInverte,@cMarca,,,,oTFolder:aDIALOGS[3])
	oMarkST6:oBrowse:Align       := CONTROL_ALIGN_ALLCLIENT
	oMarkST6:oBrowse:bAllMark    := { || MarkInverte(cMarca,cTRBST6) }
	oMarkST6:oBrowse:lHasMark    := .T.
	oMarkST6:oBrowse:lCanAllMark := .T.

	If !Inclui .And. !Altera//Nao permite marcacao na visualizacao
		oMarkST6:bMark := {|| If(Empty((cTRBST6)->TRB_OK),(cTRBST6)->TRB_OK := cMarca, (cTRBST6)->TRB_OK := Space(2))}
	EndIf

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Carrega dados do Tipo de Modelo    ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	Processa({|| LoadTrb(__FOLDER_TQR__,@aTQRHeader)},STR0003, STR0009,) //"Aguarde..."##"Carregando dados de Tipo Modelo..."

	oMarkTQR                     := MsSelect():New(cTRBTQR,"TRB_OK",,aTQRHeader,@lInverte,@cMarca,,,,oTFolder:aDIALOGS[4])
	oMarkTQR:oBrowse:Align       := CONTROL_ALIGN_ALLCLIENT
	oMarkTQR:oBrowse:bAllMark    := { || MarkInverte(cMarca,cTRBTQR) }
	oMarkTQR:oBrowse:lHasMark    := .T.
	oMarkTQR:oBrowse:lCanAllMark := .T.

	If !Inclui .And. !Altera//Nao permite marcacao na visualizacao
		oMarkTQR:bMark := {|| If(Empty((cTRBTQR)->TRB_OK),(cTRBTQR)->TRB_OK := cMarca, (cTRBTQR)->TRB_OK := Space(2))}
	EndIf

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Carrega dados da Area de Manutencao³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	Processa({|| LoadTrb(__FOLDER_STD__,@aSTDHeader)},STR0003, STR0010) //"Aguarde..."##"Carregando dados da Área de Manutenção..."

	oMarkSTD                     := MsSelect():New(cTRBSTD,"TRB_OK",,aSTDHeader,@lInverte,@cMarca,,,,oTFolder:aDIALOGS[5])
	oMarkSTD:oBrowse:Align       := CONTROL_ALIGN_ALLCLIENT
	oMarkSTD:oBrowse:bAllMark    := { || MarkInverte(cMarca,cTRBSTD) }
	oMarkSTD:oBrowse:lHasMark    := .T.
	oMarkSTD:oBrowse:lCanAllMark := .T.

	If !Inclui .And. !Altera//Nao permite marcacao na visualizacao
		oMarkSTD:bMark := {|| If(Empty((cTRBSTD)->TRB_OK),(cTRBSTD)->TRB_OK := cMarca, (cTRBSTD)->TRB_OK := Space(2))}
	EndIf

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Carrega dados do Tipo de Manutencao³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	Processa({|| LoadTrb(__FOLDER_STE__,@aSTEHeader)},STR0003, STR0011) //"Aguarde..."##"Carregando dados do Tipo de Manutenção..."

	oMarkSTE                     := MsSelect():New(cTRBSTE,"TRB_OK",,aSTEHeader,@lInverte,@cMarca,,,,oTFolder:aDIALOGS[6])
	oMarkSTE:oBrowse:Align       := CONTROL_ALIGN_ALLCLIENT
	oMarkSTE:oBrowse:bAllMark    := { || MarkInverte(cMarca,cTRBSTE) }
	oMarkSTE:oBrowse:lHasMark    := .T.
	oMarkSTE:oBrowse:lCanAllMark := .T.

	If !Inclui .And. !Altera//Nao permite marcacao na visualizacao
		oMarkSTE:bMark := {|| If(Empty((cTRBSTE)->TRB_OK),(cTRBSTE)->TRB_OK := cMarca, (cTRBSTE)->TRB_OK := Space(2))}
	EndIf

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Carrega dados do Servico de Manut. ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	Processa({|| LoadTrb(__FOLDER_ST4__,@aST4Header)},STR0003, STR0012) //"Aguarde..."##"Carregando dados do Serviço de Manutenção..."

	oMarkST4                     := MsSelect():New(cTRBST4,"TRB_OK",,aST4Header,@lInverte,@cMarca,,,,oTFolder:aDIALOGS[7])
	oMarkST4:oBrowse:Align       := CONTROL_ALIGN_ALLCLIENT
	oMarkST4:oBrowse:bAllMark    := { || MarkInverte(cMarca,cTRBST4) }
	oMarkST4:oBrowse:lHasMark    := .T.
	oMarkST4:oBrowse:lCanAllMark := .T.

	If !Inclui .And. !Altera//Nao permite marcacao na visualizacao
		oMarkST4:bMark := {|| If(Empty((cTRBST4)->TRB_OK),(cTRBST4)->TRB_OK := cMarca, (cTRBST4)->TRB_OK := Space(2))}
	EndIf

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Folder contendo Arvore Logica      ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	oTree       := dbTree():New(0,0,0,0,oTFolder:aDIALOGS[__FOLDER_TAF__],,,.T.)
	oTree:Align := CONTROL_ALIGN_ALLCLIENT

	If PtGetTheme() = "MDI"
		oTree:bRClicked  := {|oObject,nX,nY| oMenuTree:Activate( nX-oDlg:nLeft-45, nY-oDlg:nTop-oTree:nTop-290, oTree ) }
	Else
		oTree:bRClicked  := {|oObject,nX,nY| oMenuTree:Activate( nX-oDlg:nLeft-30, nY-oDlg:nTop-oTree:nTop-170, oTree ) }
	EndIf

	oTree:bLDblClick := {|oObject,nX,nY| MarkTree(oTree,cTRBTAF) }

	TreePopUp(@oMenuTree,oTree)

	If lDistri
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Folder contendo campos de S.S.     ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		aTela         := {}
		aGets         := {}
		oPnlFac       := TPanel():New(0,0,,oTFolder:aDIALOGS[__FOLDER_TUA__],,,,,RGB(67,70,87),0,10,.F.,.F.)
		oPnlFac:Align := CONTROL_ALIGN_TOP

		@ 002,004 Say OemToAnsi(STR0040) Of oPnlFac Color RGB(255,255,255) Pixel //"Informe as permissões do Usuário/Grupo para a Abertura de S.S."

		oEncFac            := MsMGet():New("TUA",nRecno,nOpc,,,,aCposFac,{0,0,100,100},,3,,,,oTFolder:aDIALOGS[__FOLDER_TUA__])
		oEncFac:oBox:Align := CONTROL_ALIGN_ALLCLIENT

		aTelaFac := aClone(aTela)
		aGetsFac := aClone(aGets)
	EndIf
	//+--------------------------------------------------+
	//| Cria Panel com opcoes de pesquisa no MsSelect	 |
	//+--------------------------------------------------+
	oPnlSearch       := TPanel():New(0,0,,oPanel,,,,,CLR_WHITE,0,15,.F.,.F.)
	oPnlSearch:Align := CONTROL_ALIGN_TOP

	oCBoxSearch := TComboBox():New(02,02,{|u| If(PCount()>0,cCombo:=u,cCombo)},aIndex[nFolderAtu],100,20,oPnlSearch,,;
	{|| ChangeIndex(cAliasAtu,oCBoxSearch:nAt,aObjects[nFolderAtu])},,,,.T.,,,,{|| nFolderAtu != __FOLDER_TAF__ .And. nFolderAtu != __FOLDER_TUA__},,,,,"cCombo")
	oGetSearch  := TGet():New( 02,105,{|u| If(PCount()>0,cGetSearch:=u,cGetSearch)}, oPnlSearch,096,008,,,0,,,.F.,,.T.,,.F.,;
	{|| nFolderAtu != __FOLDER_TAF__ .And. nFolderAtu != __FOLDER_TUA__},.F.,.F.,,.F.,.F.,,cGetSearch,,,, )
	oBtnSearch  := TButton():New( 002, 202, STR0017,oPnlSearch,{|| TrbSeek(cAliasAtu,oCBoxSearch:nAt,cGetSearch,aObjects[nFolderAtu])},; //"Buscar"
	35,11,,,.F.,.T.,.F.,,.F.,{|| nFolderAtu != __FOLDER_TAF__ .And. nFolderAtu != __FOLDER_TUA__},,.F. )

	//+--------------------------------------------------+
	//| Carrega array de controle dos MsSelect criados   |
	//+--------------------------------------------------+
	aObjects[__FOLDER_CTT__] := oMarkCTT
	aObjects[__FOLDER_SHB__] := oMarkSHB
	aObjects[__FOLDER_ST6__] := oMarkST6
	aObjects[__FOLDER_TQR__] := oMarkTQR
	aObjects[__FOLDER_STD__] := oMarkSTD
	aObjects[__FOLDER_STE__] := oMarkSTE
	aObjects[__FOLDER_ST4__] := oMarkST4
	aObjects[__FOLDER_TAF__] := oTree
	If lDistri
		aObjects[__FOLDER_TUA__] := oEncFac
	EndIf

	HideFolder(oTFolder)

	If nOpc == 2 .Or. nOpc == 5
		Activate MsDialog oDlg On Init EnchoiceBar(oDlg,{|| (lConfirm := .T.,oDlg:End()) },{|| oDlg:End()})
	ElseIf nOpc == 3 .Or. nOpc == 4
		Activate MsDialog oDlg On Init EnchoiceBar(oDlg,{|| If(Obrigatorio(aGetsTUA,aTelaTUA) .And. If(lDistri,Obrigatorio(aGetsFac,aTelaFac),.T.) .And. ProcessTree(aTables,aObjects),(lConfirm := .T.,oDlg:End()),)},{|| oDlg:End()})
	EndIf

	If lConfirm

		//+-----------------------------------------------------+
		//| Seta Visual, Inclui, Altera ou Exclui conforme nOpc |
		//+-----------------------------------------------------+
		aRotSetOpc(cAlias,nRecno,nOpc)
		If INCLUI .Or. ALTERA

			dbSelectArea("TUA")
			RecLock("TUA",INCLUI)

			For nY := 1 To FCOUNT()
				FieldPut(nY, &("M->" + FieldName(nY)))
			Next nY
			TUA->TUA_FILIAL := xFilial("TUA")
			TUA->(MsUnLock())

			For nY := 1 To 7
				GravaFolder(aTables[nY],cValToChar(nY),aUniqueKey[nY])
			Next nY

			GravaTree(aTables[__FOLDER_TAF__])

			//__FOLDER_TAF__ 08 //LOCALIZACAO
		ElseIf EXCLUI
			dbSelectArea("TUB")
			dbSetOrder(1)
			dbSeek(xFilial("TUB")+M->TUA_TIPRES+M->TUA_TIPO+M->TUA_GRPUSR)
			While !Eof() .And. TUB->TUB_FILIAL == xFilial("TUB") .And. TUB->TUB_TIPRES == M->TUA_TIPRES .And. TUB->TUB_TIPO == M->TUA_TIPO;
			.And. TUB->TUB_GRPUSR == M->TUA_GRPUSR

				RecLock("TUB",.F.)
				dbDelete()
				TUB->(MsUnLock())
				dbSkip()
			EndDo

			RecLock("TUA",.F.)
			dbDelete()
			TUA->(MsUnLock())
		EndIf

	EndIf

	//Deleta arquivos temporarios
	For nY := 1 To Len(aArqTRB)
		If !Empty(aArqTRB[nY])
			aArqTRB[nY]:Delete()
		EndIf
	Next nY

Return

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³ProcessTree ³Autor ³Vitor Emanuel Batista ³ Data ³21/06/2010³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³Processa filtros marcando/desmarcando itens da Tree         ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³cMarca - Conteudo do campo marcado                          ³±±
±±³          ³cTrb   - Tabela temporaria do MsSelect                      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³MNTA904                                                     ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Static Function ProcessTree(aTables,aObjects)

	//+-------------------------+
	//| Valida campo TUA_GRPUSR |
	//+-------------------------+
	If Inclui .And. !MNT904GRPUS(.T.)
		Return .F.
	EndIf

	If Select(aTables[__FOLDER_TAF__]) == 0
		Processa({|| LoadTree(aObjects[__FOLDER_TAF__],aTables[__FOLDER_TAF__])},STR0003, STR0018) //"Aguarde..."##"Carregando dados da Árvore..."
	EndIf
	Processa({|| LoadMarkTree(aTables,aObjects[__FOLDER_TAF__]) },STR0003, STR0019) //"Aguarde..."##"Selecionando itens de acordo com filtro..."

Return .T.


/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³MarkInverte ³Autor ³Vitor Emanuel Batista ³ Data ³21/06/2010³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³Inverte opcoes do MsSelect selecionado                      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³cMarca - Conteudo do campo marcado                          ³±±
±±³          ³cTrb   - Tabela temporaria do MsSelect                      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³MNTA904                                                     ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Static Function MarkInverte(cMarca,cTrb,lMarkAll)
	Local aArea := (cTrb)->(GetArea())
	Local cMarkAll := "", lFirst := .T.
	Default lMarkAll := .F.

	If Inclui .or. Altera
		If lMarkAll
			dbSelectArea(cTrb)
			dbGoTop()
			While !Eof()
				If lFirst
					cMarkAll := (cTrb)->TRB_OK
					lFirst   := .F.
				EndIf
				(cTrb)->TRB_OK := cMarkAll
				dbSkip()
			EndDo
		EndIf

		dbSelectArea(cTrb)
		dbGoTop()
		While !Eof()
			(cTrb)->TRB_OK := If(!Empty((cTrb)->TRB_OK) ," ",cMARCA)
			dbSkip()
		EndDo
	EndIf
	RestArea(aArea)
Return

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³ GravaTree  ³Autor ³Vitor Emanuel Batista ³ Data ³21/06/2010³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³Grava registros mascados na TUB                             ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³cTrbTree - Tabela temporaria do Tree                        ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³MNTA904                                                     ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Static Function GravaTree( cTrbTree )
	
	// Deleta registros que já contém restrições.
	DeleteTree( cTrbTree )

	dbSelectArea( cTrbTree )
	dbGoTop()
	
	While (cTrbTree)->( !EoF() )
		
		If (cTrbTree)->MARCA == '1' .Or. (cTrbTree)->FILTRO == '1'
			
			If (cTrbTree)->CARGO == 'BEM'

				cCode   := (cTrbTree)->CODCON
				cOption := cValToChar( __FOLDER_ST9__ )

			Else

				cCode   := (cTrbTree)->CODPRO
				cOption := cValToChar( __FOLDER_TAF__ )

			EndIf
			
			dbSelectArea( 'TUB' )
			dbSetOrder( 1 ) // TUB_FILIAL + TUB_TIPRES + TUB_TIPO + TUB_GRPUSR + TUB_OPCAO + TUB_CODIGO
						
			RecLock( 'TUB', !dbSeek( xFilial( 'TUB' ) + M->TUA_TIPRES + M->TUA_TIPO + M->TUA_GRPUSR + cOption + cCode ) )
			TUB->TUB_FILIAL := xFilial("TUB")
			TUB->TUB_TIPRES := M->TUA_TIPRES
			TUB->TUB_TIPO   := M->TUA_TIPO
			TUB->TUB_GRPUSR := M->TUA_GRPUSR
			TUB->TUB_OPCAO  := cOption
			TUB->TUB_CODIGO := cCode
			TUB->TUB_FILTRO := (cTrbTree)->FILTRO
			TUB->TUB_MARCA  := (cTrbTree)->MARCA
			TUB->TUB_RESTRI := (cTrbTree)->RESTRI
			TUB->( MsUnLock() )

		EndIf

		(cTrbTree)->( dbSkip() )

	EndDo

Return

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³GravaFolder ³Autor ³Vitor Emanuel Batista ³ Data ³18/06/2010³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³Grava registros mascados na TUB                             ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³cTrb   - Tabela temporaria do MsSelect                      ³±±
±±³          ³cOpcao - Opcao do combobox                                  ³±±
±±³          ³cChave - Chave de pesquisa na TUB                           ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³MNTA904                                                     ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Static Function GravaFolder(cTrb,cOpcao,cChave)
	Local lInclui := INCLUI
	Local cCodigo

	dbSelectArea(cTrb)
	dbSetOrder(1)
	dbGoTop()
	While !Eof()
		cCodigo := (cTrb)->(&cChave)
		If ALTERA
			dbSelectArea("TUB")
			dbSetOrder(1)
			lInclui := !dbSeek(xFilial("TUB")+M->TUA_TIPRES+M->TUA_TIPO+M->TUA_GRPUSR+cOpcao+cCodigo)
		EndIf

		If lInclui
			If Empty((cTrb)->TRB_OK)
				RecLock("TUB",.T.)
				TUB->TUB_FILIAL := xFilial("TUB")
				TUB->TUB_TIPRES := M->TUA_TIPRES
				TUB->TUB_TIPO   := M->TUA_TIPO
				TUB->TUB_GRPUSR := M->TUA_GRPUSR
				TUB->TUB_OPCAO  := cOpcao
				TUB->TUB_CODIGO := cCodigo
				TUB->(MsUnLock())
			EndIf
		ElseIf ALTERA .And. !Empty((cTrb)->TRB_OK)
			RecLock("TUB",.F.)
			dbDelete()
			TUB->(MsUnLock())
		EndIf
		dbSelectArea(cTrb)
		dbSkip()
	EndDo

Return

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³ Visualize  ³Autor ³Vitor Emanuel Batista ³ Data ³17/06/2010³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³Visualiza registro posicionado no MsSelect atual            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³cTrb   - Tabela temporaria do MsSelect                      ³±±
±±³          ³cAlias - Alias relacionada ao Folder atual                  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³MNTA904                                                     ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Static Function Visualize( cTrb, cAlias )

	Local aNGBEGINPRM := NGBEGINPRM()
	Local cIndice     := (cAlias)->( IndexKey( 1 ) )
	Local bVisual     := { || NGCAD01( cAlias, Recno(), 2 ) }
	Local nTamTAF     := FWTamSX3( 'TAF_CODNIV' )[1]
	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Altera forma de consulta se funcao ³
	//³for chamada pela Tree              ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If cAlias == "TAF"

		dbSelectArea(cTRBTAF)
		dbSetOrder(2)
		If msSeek( '001' + SubStr( oTree:GetCargo(), 1, nTamTAF ) )
			If (cTRBTAF)->TIPO == "1"
				cIndice := "xFilial('ST9')+CODTIPO"
				cAlias  := "ST9"
				bVisual := {|| NG080FOLD(cAlias,Recno(),2)}
			Else
				cIndice := "xFilial('TAF')+CODEST+NIVSUP+ORDEM"
			EndIf
		Else
			Return
		EndIf
	EndIf

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Localiza registro na cAlias com a chave da cTrb ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	dbSelectArea(cAlias)
	dbSetOrder(1)
	If dbSeek((cTrb)->(&cIndice))
		EVal(bVisual)
	EndIf

	NGRETURNPRM(aNGBEGINPRM)
Return

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³ChangeOption³Autor ³Vitor Emanuel Batista ³ Data ³17/06/2010³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³Funcao chamada apos a troca de folder                       ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³nOption- Posicao do Folder escolhido                        ³±±
±±³          ³aTables- Vetor contendo as Alias utilizadas                 ³±±
±±³          ³oCBox  - ComboBox que sera alterado                         ³±±
±±³          ³aIndex - Vetor contendo os indices utilizados               ³±±
±±³          ³aObjects- Vetor contendo os objetos utilizados              ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³MNTA904                                                     ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Static Function ChangeOption(nOption,aTables,oCBox,aIndex,aObjects)
	Local cAlias  := aTables[nOption]
	Local aItems  := aIndex[nOption]
	Local oObjeto := aObjects[nOption]
	Local cObject := Upper(GetClassName(oObjeto))

	nFolderAtu := nOption //Posicao atual do Folder
	cAliasAtu  := cAlias //Alias atual
	cGetSearch := Space(100) //Limpa conteudo do TGet de pesquisa

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Nao devera atualizar o ComboBox caso Folder ³
	//³escolhido seja o de Localizacao (TAF)       ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If nOption != __FOLDER_TAF__
		oBtnMark:Hide()
		oBtnLeg:Hide()
		oBtnRefresh:Hide()
		If nOption == __FOLDER_TUA__
			oBtnVisual:Hide()
		Else
			oBtnVisual:Show()
			oCBox:SetItems(aItems)
		EndIf
	Else
		If !ProcessTree(aTables,aObjects)
			Return .F.
		EndIf
		oBtnVisual:Show()
		oBtnMark:Show()
		oBtnLeg:Show()
		If Inclui .or. Altera
			oBtnRefresh:Show()
		EndIf
	EndIf

	If nOption != __FOLDER_TUA__
		dbSelectArea(cAlias)
		dbSetOrder(1)
		(cAliasAtu)->(dbGoTop())
		If cObject == "DBTREE"
			oObjeto:SetFocus()
		ElseIf cObject == "MSMGET"
			oObjeto:SetFocus()
			oObjeto:Refresh()
		ElseIf cObject == "MSSELECT"
			oObjeto:oBrowse:SetOrder(1)
			oObjeto:oBrowse:DrawSelect()
			oObjeto:oBrowse:SetFocus()
			oObjeto:oBrowse:Refresh()
		EndIf
	EndIf

Return .T.

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³ChangeIndex³ Autor ³Vitor Emanuel Batista ³ Data ³17/06/2010³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³Altera o indice da tabela temporaria setada, ordenando o    ³±±
±±³          ³MsSelect                                                    ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³cAlias - Alias                                              ³±±
±±³          ³nOrdem - Ordem da Alias                                     ³±±
±±³          ³oMark  - Objeto MsSelect em foco                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³MNTA904                                                     ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Static Function ChangeIndex(cAlias,nOrdem,oMark)

	dbSelectArea(cAlias)
	dbSetOrder(nOrdem)
	oMark:oBrowse:SetOrder(nOrdem)
	oMark:oBrowse:DrawSelect()
	oMark:oBrowse:SetFocus()
	oMark:oBrowse:Refresh()
Return


/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³ TrbSeek   ³ Autor ³Vitor Emanuel Batista ³ Data ³17/06/2010³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³Posiciona registro no MsSelect                              ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³cAlias - Alias de pesquisa                                  ³±±
±±³          ³cSearch- String com o conteudo de pesquisa                  ³±±
±±³          ³oMark  - MsSelect atual                                     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³MNTA904                                                     ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Static Function TrbSeek(cAlias,nOrdem,cSearch,oMark)
	Local aArea := (cAlias)->(GetArea())

	dbSelectArea(cAlias)
	dbSetOrder(nOrdem)
	If !dbSeek(xFilial(aAlias[nFolderAtu])+Trim(cSearch))
		Help(" ",1,"PESQ01")
		RestArea(aArea)
	EndIf
	oMark:oBrowse:SetFocus()
	oMark:oBrowse:DrawSelect()
	oMark:oBrowse:Refresh()
Return

//-------------------------------------------------------------------
/*/{Protheus.doc} LoadTrb
Carrega Trb de Alias informada, lista indices e campos da Header

@author  Vitor Emanuel Batista
@since   17/06/2010
@version P12
@param nOpcao, numérico, opção de ação
@param aHeaPar, array, Array contendo aHeader
/*/
//-------------------------------------------------------------------
Static Function LoadTrb(nOpcao,aHeaPar)

	Local cQuery
	Local aIND 			:= {}
	Local aStruct 		:= {}
	Local cAliasQry 	:= GetNextAlias()
	Local cCampo 		:= ""
	Local cBrowse		:= ""
	Local cContext		:= ""
	Local cBoxSX3		:= ""
	Local cTitulo		:= ""
	Local aNgHeader		:= {}
	Local nInd			:= 0
	Local nTamTot		:= 0

	Local lTipFam := NGCADICBASE("T6_TIPOFAM","A","ST6",.F.)
	Local cTrb := aTables[nOpcao]
	Local cAlias := aAlias[nOpcao]
	//Variaveis utilizadas no SqlToTrb
	Local nI := 0
	Local nJ := 0
	Local nF := 0
	Local nCnt1
	Local nCnt2
	Local nCnt3
	Local nTotalRec := 0
	Local aStruQry  := {}
	Local aCBox     := {}
	Local aExpDel	:= { "DTOS", "STR", "NIVEL" }
	Local nPosDel 	:= {}
	Local nPosLoc

	aAdd(aHeaPar,{ "TRB_OK"	, Nil ," ",})

	// Carrega na array aHeader todos os campos do
	// Browse e que estao no banco de dados da cAlias
	aNgHeader := NGHeader(cAlias)
	nTamTot := Len(aNgHeader)
	For nInd := 1 To nTamTot
		cCampo 		:= aNgHeader[nInd,2]
		cBrowse		:= Posicione("SX3",2,cCampo,"X3_BROWSE")
		cContext	:= aNgHeader[nInd,10]
		cBoxSX3		:= X3CBox()
		cTitulo		:= aNgHeader[nInd,1]

		If cBrowse == "S" .And. cContext != "V"
			aAdd(aHeaPar,{ cCampo , Nil , Trim(cTitulo) })

			//Verifica campos Combo Box
			If !Empty(cBoxSX3)
				aAdd(aCBox, Trim(cCampo))
			EndIf
		EndIf
	Next nInd

	aStruct := (cAlias)->(dbStruct())
	aAdd(aStruct,{ "TRB_OK"			, "C" ,02, 0 })

	For nI := 1 To Len(aCBox)
		nPos := aScan(aStruct,{|x| x[1] == aCBox[nI]})
		If nPos > 0
			aStruct[nPos][3] := 25
		EndIf

	Next nI

	// Carrega na array aIndex todos os indices da cAlias
	aIndex[nOpcao] := {}
	dbSelectArea("SIX")
	dbSetOrder(1)
	dbSeek(cAlias)
	While !Eof() .And. SIX->INDICE == cAlias
		aAdd(aIND,SIX->CHAVE)

		// Busca descritivo de indice de acordo com a Linguagem
		aAdd( aIndex[nOpcao], SIX->( SixDescricao() ) )

		dbSkip()
	EndDo

	For nCnt1 := 1 To Len( aIND )
		aIND[nCnt1] := StrTokArr( AllTrim(aIND[ nCnt1 ]), "+" )
	Next nCnt1

	For nCnt2 := 1 To Len( aIND )
		For nCnt3 := 1 to Len( aIND[ nCnt2 ] )
			If ( nPosDel := aScan( aExpDel , { | x | AllTrim( Upper( x ) ) $ Upper( aIND[ nCnt2 ][ nCnt3 ] ) } ) ) > 0
				If ( nPosLoc := AT( "(" , aIND[ nCnt2 ][ nCnt3 ] ) ) > 0
					aIND[ nCnt2 ][ nCnt3 ] := SubStr( aIND[ nCnt2 ][ nCnt3 ] , nPosLoc + 1 )
				EndIf
				If ( nPosLoc := AT( "," , aIND[ nCnt2 ][ nCnt3 ] ) ) > 0
					aIND[ nCnt2 ][ nCnt3 ] := SubStr( aIND[ nCnt2 ][ nCnt3 ] , 1 , nPosLoc - 1 )
				EndIf
				If ( nPosLoc := AT( ")" , aIND[ nCnt2 ][ nCnt3 ] ) ) > 0
					aIND[ nCnt2 ][ nCnt3 ] := SubStr( aIND[ nCnt2 ][ nCnt3 ] , 1 , nPosLoc - 1 )
				EndIf
			EndIf
			aIND[ nCnt2 ][ nCnt3 ] := AllTrim(aIND[ nCnt2 ][ nCnt3 ])
		Next nCnt3
	Next nCnt2
	//Criação Tabela Temporária | visivel no oMark
	oTmpTbl1 := NGFwTmpTbl(cTrb,aStruct,aIND)

	aArqTRB[nOpcao] := oTmpTbl1

	cQuery := " SELECT * FROM "+RetSqlName(cAlias)
	cQuery += " WHERE "+PrefixoCpo(cAlias)+"_FILIAL = "+ValToSql(xFilial(cAlias))
	cQuery += "   AND D_E_L_E_T_ != '*'"
	If cAlias == "ST6" .And. lTipFam
		cQuery += "   AND T6_TIPOFAM = '1'"
	EndIf
	cQuery += " ORDER BY "+SqlOrder((cAlias)->(IndexKey(1)))

	//Logica abaixo retirado do SqlToTrb
	cQuery := ChangeQuery(cQuery)
	dbUseArea(.T., "TOPCONN", TCGenQry(,,cQuery), cAliasQry, .F., .T.)

	For nJ := 1 to Len(aStruct)
		If !(aStruct[nJ,2] $ "CM")
			TCSetField((cAliasQry), aStruct[nJ,1], aStruct[nJ,2],aStruct[nJ,3],aStruct[nJ,4])
		EndIf
	Next nJ

	nTotalRec:= (cAliasQry)->(RecCount())
	aStruQry := (cAliasQry)->(DbStruct())
	nF       := Len(aStruQry)

	(cAliasQry)->(DbGoTop())

	ProcRegua( nTotalRec )

	While ! (cAliasQry)->(Eof())
		IncProc()
		(cTrb)->(DbAppend())
		For nI := 1 To nF
			If (cTrb)->(FieldPos(aStruQry[nI,1])) > 0	 .And. aStruQry[nI,2] <> "M"
				If aScan(aCBox,{|x| x == aStruQry[nI,1]}) == 0
					(cTrb)->(FieldPut(FieldPos(aStruQry[nI,1]),(cAliasQry)->(FieldGet((cAliasQry)->(FieldPos(aStruQry[nI,1]))))))
				Else
					(cTrb)->(FieldPut(FieldPos(aStruQry[nI,1]),NGRETSX3BOX(aStruQry[nI,1],(cAliasQry)->(FieldGet((cAliasQry)->(FieldPos(aStruQry[nI,1])))))))
				EndIf
			EndIf
		Next nI

		If !INCLUI
			dbSelectArea("TUB")
			dbSetOrder(1)
			If !dbSeek(xFilial("TUB")+M->TUA_TIPRES+M->TUA_TIPO+M->TUA_GRPUSR+cValToChar(nOpcao)+(cTrb)->(&(aUniqueKey[nOpcao])))
				(cTrb)->TRB_OK := cMarca
			EndIf
		Else
			(cTrb)->TRB_OK := cMarca
		EndIf
		(cAliasQry)->(DbSkip())
	End
	(cAliasQry)->(dbCloseArea())
	(cTrb)->(dbGoTop())

Return

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³ LoadTree  ³ Autor ³Vitor Emanuel Batista ³ Data ³21/06/2010³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³Carrega Tree de acorodo com a TAF                           ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³oTree    - Objeto Tree                                      ³±±
±±³          ³cTrbTree - Tabela temporaria do Tree                        ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³MNTA904                                                     ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Static Function LoadTree(oTree,cTrbTree)

	Local aCampos  := {}
	Local aIndex   := {}
	Local nTamTAF  := FWTamSX3( 'TAF_CODNIV' )[1]
	Local cCargo   := "LOC"
	Local cCodEst  := "001"
	Local cPai     := IIf( nTamTAF > 3, '000001', '001' )
	Local cFolderA := "FOLDER7"
	Local cFolderB := "FOLDER8"
	Local nNivel

	aAdd( aCampos, { 'CODEST' , 'C', 03, 0 } )
	aAdd( aCampos, { 'DESCRI' , 'C', 56, 0 } )
	aAdd( aCampos, { 'NIVSUP' , 'C', nTamTAF, 0 } )
	aAdd( aCampos, { 'TIPO'   , 'C', 01, 0 } )
	aAdd( aCampos, { 'CODTIPO', 'C', 16, 0 } )
	aAdd( aCampos, { 'ORDEM'  , 'C', FWTamSX3( 'TAF_ORDEM' )[1], 0 } )
	aAdd( aCampos, { 'NIVEL'  , "N", 02, 0 } )
	aAdd( aCampos, { 'CARGO'  , 'C', 03, 0 } )
	aAdd( aCampos, { 'CC'     , 'C', 09, 0 } )
	aAdd( aCampos, { 'CENTRAB', 'C', 06, 0 } )
	aAdd( aCampos, { 'FILTRO' , 'C', 01, 0 } )
	aAdd( aCampos, { 'MARCA'  , 'C', 01, 0 } )
	aAdd( aCampos, { 'RESTRI' , 'C', FWTamSX3( 'TUB_RESTRI' )[1], 0 } )
	aAdd( aCampos, { 'CODPRO' , 'C', nTamTAF, 0 } )
	aAdd( aCampos, { 'CODCON' , 'C', FWTamSX3( 'TAF_CODCON' )[1], 0 } )

	//Indice Tabela Temporária
	aIndex   := {	{ 'CODEST', 'NIVSUP' }         ,;
                	{ 'CODEST', 'CODPRO', 'ORDEM' },;
                	{ 'TIPO'  , 'CODTIPO' }        ,;
                 	{ 'CODEST', 'NIVSUP', 'ORDEM' },;
                 	{ 'CODEST', 'NIVEL' , 'ORDEM' },;
					{ 'CODEST', 'CODCON' } }

	//Criação Tabela Temporária
	oTmpTbl2 := NGFwTmpTbl(cTrbTree,aCampos,aIndex)
	aArqTRB[__FOLDER_TAF__] := oTmpTbl2

	oTree:Reset()
	oTree:BeginUpdate()

	dbSelectArea("TAF")
	dbSetOrder(1)
	dbSeek(xFilial("TAF")+"001")

	RecLock( cTrbTree,.T. )
	(cTrbTree)->CODEST  := cCodEst
	(cTrbTree)->CODPRO  := TAF->TAF_CODNIV
	(cTrbTree)->DESCRI  := TAF->TAF_NOMNIV
	(cTrbTree)->NIVSUP  := TAF->TAF_NIVSUP
	(cTrbTree)->TIPO    := TAF->TAF_INDCON
	(cTrbTree)->CODTIPO := TAF->TAF_CODCON
	(cTrbTree)->NIVEL   := 0
	(cTrbTree)->CARGO   := 'LOC'
	(cTrbTree)->ORDEM   := TAF->TAF_ORDEM
	(cTrbTree)->CC      := TAF->TAF_CCUSTO
	(cTrbTree)->CENTRAB := TAF->TAF_CENTRA
	(cTrbTree)->( MsUnLock() )

	dbSelectArea("TUB")
	dbSetOrder(1)
	If dbSeek(xFilial("TUB")+M->TUA_TIPRES+M->TUA_TIPO+M->TUA_GRPUSR+cValToChar(__FOLDER_TAF__)+(cTrbTree)->CODPRO)
		cFolderA := "FOLDER10"
		cFolderB := "FOLDER11"
		aAdd(aMarkTree,(cTrbTree)->CODPRO)
		RecLock(cTrbTree,.F.)
		(cTrbTree)->FILTRO := TUB->TUB_FILTRO
		(cTrbTree)->MARCA  := TUB->TUB_MARCA
		(cTrbTree)->RESTRI := TUB->TUB_RESTRI
		(cTrbTree)->(MsUnLock())
	Else
		cFolderA := "FOLDER7"
		cFolderB := "FOLDER8"
	EndIf

	DbAddTree oTree Prompt TAF->TAF_NOMNIV Opened Resource cFolderA, cFolderB Cargo cPai+cCargo

	cPai := IIf( nTamTAF > 3, '000001', '001' )
	
	dbSelectArea("TAF")
	dbSetOrder(1)
	dbSeek(xFilial("TAF")+cCodEst+cPai)
	ProcRegua(RecCount()*2)
	
	While !TAF->(Eof()) .And. TAF->TAF_FILIAL == xFilial("TAF") .And. TAF->TAF_NIVSUP == cPai

		IncProc()
		If Empty( TAF->TAF_MODMNT ) .Or. !(TAF->TAF_INDCON $ "1/2/")
			TAF->(dbSkip())
			Loop
		EndIf

		If TAF->TAF_INDCON == "1"
			cCargo   := "BEM"

			dbSelectArea("ST9")
			dbSetOrder(1)
			If !dbSeek(xFilial("ST9")+TAF->TAF_CODCON) .Or. ST9->T9_SITBEM <> "A"
				TAF->(dbSkip())
				Loop
			EndIf

		ElseIf TAF->TAF_INDCON == "2"
			cCargo := "LOC"
		EndIf

		dbSelectArea(cTrbTree)
		dbSetOrder(2)
		
		RecLock( cTrbTree, .T. )
		(cTrbTree)->CODEST  := cCodEst
		(cTrbTree)->CODPRO  := TAF->TAF_CODNIV
		(cTrbTree)->DESCRI  := TAF->TAF_NOMNIV
		(cTrbTree)->NIVSUP  := TAF->TAF_NIVSUP
		(cTrbTree)->TIPO    := TAF->TAF_INDCON
		(cTrbTree)->CODTIPO := TAF->TAF_CODCON
		(cTrbTree)->NIVEL   := 1
		(cTrbTree)->CARGO   := cCargo
		(cTrbTree)->CODCON  := TAF->TAF_CODCON
		(cTrbTree)->ORDEM   := TAF->TAF_ORDEM
		(cTrbTree)->CC      := TAF->TAF_CCUSTO
		(cTrbTree)->CENTRAB := TAF->TAF_CENTRA
		(cTrbTree)->( MsUnLock() )

		TAF->( dbSkip() )

	EndDo

	dbSelectArea(cTrbTree)
	dbSetOrder(5)
	nNivel		:=1
	nMaxNivel	:=1
	While nNivel<=nMaxNivel
        dbSeek(cCodEst+Str(nNivel,2,0))

		While !(cTrbTree)->(Eof()) .And. nNivel==(cTrbTree)->NIVEL

			IncProc()
			
			nRecTrb := (cTrbTree)->( Recno() )
			cFilho  := (cTrbTree)->CODPRO

			dbSelectArea("TAF")
			dbSetOrder(2)
			dbSeek(xFilial("TAF")+cCodEst+cFilho)

			nRecTAF := TAF->(Recno())

			dbSelectArea("TAF")
			dbSetOrder(1)
			dbSeek(xFilial("TAF")+cCodEst+cFilho)
			While !TAF->(Eof()) .And. TAF->TAF_FILIAL == xFilial("TAF") .And.;
			TAF->TAF_NIVSUP == cFilho

				IncProc()
				If Empty( TAF->TAF_MODMNT ) .Or. !(TAF->TAF_INDCON $ "1/2")
					TAF->(dbSkip())
					Loop
				EndIf

				If TAF->TAF_INDCON == "1"
					cCargo   := "BEM"

					dbSelectArea("ST9")
					dbSetOrder(1)
					If !dbSeek(xFilial("ST9")+TAF->TAF_CODCON) .Or. ST9->T9_SITBEM <> "A"
						TAF->(dbSkip())
						Loop
					EndIf
				ElseIf TAF->TAF_INDCON == "2"
					cCargo := "LOC"
				EndIf

				RecLock( cTrbTree, .T. )
				(cTrbTree)->CODEST  := cCodEst
				(cTrbTree)->CODPRO  := TAF->TAF_CODNIV
				(cTrbTree)->DESCRI  := TAF->TAF_NOMNIV
				(cTrbTree)->NIVSUP  := TAF->TAF_NIVSUP
				(cTrbTree)->TIPO    := TAF->TAF_INDCON
				(cTrbTree)->CODTIPO := TAF->TAF_CODCON
				(cTrbTree)->NIVEL   := nNivel+1
				(cTrbTree)->CARGO   := cCargo
				(cTrbTree)->CODCON  := TAF->TAF_CODCON
				(cTrbTree)->ORDEM   := TAF->TAF_ORDEM
				(cTrbTree)->CC      := TAF->TAF_CCUSTO
				(cTrbTree)->CENTRAB := TAF->TAF_CENTRA
				(cTrbTree)->( MsUnLock() )
				
				nMaxNivel:=nNivel+1

				TAF->( dbSkip() )

			EndDo

			(cTrbTree)->(dbGoto(nRecTrb))
			TAF->(dbGoTo(nRecTAF))

			If TAF->TAF_INDCON == '1'
				
				cCargo  := 'BEM'
				cCode   := (cTrbTree)->CODCON
				cOption := cValToChar( __FOLDER_ST9__ )

			ElseIf TAF->TAF_INDCON == '2'
				
				cCargo  := 'LOC'
				cCode   := (cTrbTree)->CODPRO
				cOption := cValToChar( __FOLDER_TAF__ )

			EndIf

			If (cTrbTree)->TIPO == "1"
				cFolderA := "ng_ico_bemvermelho"
				cFolderB := "ng_ico_bemvermelho"
			Else
				cFolderA := "FOLDER7"
				cFolderB := "FOLDER8"
			EndIf

			If !INCLUI
				dbSelectArea("TUB")
				dbSetOrder(1)
				If dbSeek( xFilial( 'TUB' ) +M->TUA_TIPRES + M->TUA_TIPO + M->TUA_GRPUSR + cOption + cCode )
					
					If !Empty(TUB->TUB_RESTRI)
						If (cTrbTree)->TIPO == "1"
							cFolderA := "ng_ico_bemamarelo"
							cFolderB := "ng_ico_bemamarelo"
						Else
							cFolderA := "FOLDER5"
							cFolderB := "FOLDER6"
						EndIf
					ElseIf TUB->TUB_MARCA == "1"
						If (cTrbTree)->TIPO == "1"
							cFolderA := "ng_ico_bemverde"
							cFolderB := "ng_ico_bemverde"
						Else
							cFolderA := "FOLDER10"
							cFolderB := "FOLDER11"
						EndIf
						aAdd(aMarkTree,(cTrbTree)->CODPRO)
					EndIf

					RecLock( cTrbTree, .F. )
					(cTrbTree)->FILTRO := TUB->TUB_FILTRO
					(cTrbTree)->MARCA  := TUB->TUB_MARCA
					(cTrbTree)->RESTRI := TUB->TUB_RESTRI
					(cTrbTree)->( MsUnLock() )

				EndIf

			EndIf

			oTree:TreeSeek((cTrbTree)->NIVSUP+"LOC")
			oTree:AddItem( (cTrbTree)->DESCRI, (cTrbTree)->CODPRO + cCargo, cFolderA, cFolderB, , , 2 )
			
			(cTrbTree)->( dbSkip() )

		EndDo

		nNivel++

	EndDo

	//+-----------------------------------+
	//| Fecha folders de todos os filhos  |
	//+-----------------------------------+
	nNivel := nMaxNivel
	dbSelectArea(cTrbTree)
	dbSetOrder(5)
	If (cTrbTree)->(RecCount()) > 0
		ProcRegua(nNivel)
		While nNivel >= 1

			IncProc()
            dbSeek("001"+Str(nNivel,2,0))
			While (cTrbTree)->NIVEL == nNivel

				If (cTrbTree)->TIPO == "1"
					cCargo   := "BEM"
				ElseIf (cTrbTree)->TIPO == "2"
					cCargo := "LOC"
				EndIf

				oTree:TreeSeek((cTrbTree)->CODPRO+cCargo)

				oTree:PtCollapse()
				(cTrbTree)->(dbSkip())
			End
			nNivel--
		End
	EndIf

	oTree:EndUpdate()
	oTree:EndTree()
	oTree:TreeSeek("001LOC")

Return

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³ MarkTree   ³Autor ³Vitor Emanuel Batista ³ Data ³21/06/2010³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³Duplo clique sobre a Arvore, selecionando Localizacao/Bem   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³oTree    - Objeto Tree                                      ³±±
±±³          ³cTrbTree - Tabela temporaria do Tree                        ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³MNTA904                                                     ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Static Function MarkTree( oTree, cTrbTree, lRecursiva )

	Local cCodPro := SubStr( oTree:GetCargo(), 1, FWTamSX3( 'TAF_CODNIV' )[1] )
	Local nX      := 1
	Local nRet    := 0
	Local cRestri := ""
	Local nLenSon := 1
	Local aDelMark:= {} //Array com os itens que vao ser desmarcados
	Local lFilho  := .F. //Indica se deve marcar os Filhos
	Local aFilho  := {} //Array contendo codigo dos Filhos

	Default lRecursiva := .F.
	//+------------------------------+
	//| Se for visualizacao somente  |
	//+------------------------------+
	If !Inclui .And. !Altera
		dbSelectArea(cTrbTree)
		dbSetOrder(2)
		If dbSeek("001"+cCodPro) .And. !Empty((cTrbTree)->RESTRI)
			fDefOpcRot((cTrbTree)->TIPO, cTrbTree)
		EndIf
		Return .F.
	EndIf

	//+--------------------------------------------------+
	//| Verifica se item ja esta selecionado (Vermelho)  |
	//+--------------------------------------------------+
	If (nPos := aScan(aMarkTree,{|a| a == cCodPro})) == 0 .or. lRecursiva

		//+--------------------------------------------------------+
		//|  Verifica se item selecionado eh pai de outros itens   |
		//+--------------------------------------------------------+
		dbSelectArea(cTrbTree)
		dbSetOrder(1)
		If dbSeek("001"+cCodPro)
			lFilho := MsgYesNo(STR0020) //"Deseja selecionar todos os itens filhos desta localização?"
		EndIf

		//+-------------------------------------------------------------+
		//| Marca todas as Localizacoes Pai (acima) do item selecionado |
		//+-------------------------------------------------------------+
		dbSelectArea(cTrbTree)
		dbSetOrder(2)
		dbSeek("001"+cCodPro)
		While !Eof()
			If (nPos := aScan(aMarkTree,{|a| a == (cTrbTree)->CODPRO})) > 0 .And. (cTrbTree)->CODPRO != cCodPro
				Exit
			EndIf
			If nPos == 0
				aAdd(aMarkTree,(cTrbTree)->CODPRO)
			EndIf
			If oTree:TreeSeek((cTrbTree)->CODPRO)
				If !Empty((cTrbTree)->RESTRI) .And. (cTrbTree)->CODPRO != cCodPro
					fChangeBmp((cTrbTree)->TIPO,"2")
				Else
					fChangeBmp((cTrbTree)->TIPO,"1")
				EndIf
			EndIf

			RecLock(cTrbTree,.F.)
			(cTrbTree)->FILTRO := "2"
			(cTrbTree)->MARCA  := "1"
			If (cTrbTree)->CODPRO == cCodPro
				(cTrbTree)->RESTRI := ""
			EndIf
			(cTrbTree)->(MsUnLock())

			dbSelectArea(cTrbTree)
			dbSeek("001"+(cTrbTree)->NIVSUP)
		EndDo

		//+------------------------------------------------------------+
		//| Marca todos os itens filhos (abaixo) do item selecionado   |
		//+------------------------------------------------------------+
		If lFilho
			dbSelectArea(cTrbTree)
			dbSetOrder(2)
			dbSeek("001"+cCodPro)
			aAdd(aFilho,(cTrbTree)->CODPRO)

			dbSelectArea(cTrbTree)
			dbSetOrder(1)
			While nX <= nLenSon
				cPai := aFilho[nX]

				dbSeek("001"+cPai)
				While !Eof() .And. (cTrbTree)->NIVSUP == cPai
					If (nPos := aScan(aMarkTree,{|a| a == (cTrbTree)->CODPRO})) == 0
						aAdd(aMarkTree,(cTrbTree)->CODPRO)
					EndIf

					aAdd(aFilho,(cTrbTree)->CODPRO)
					nLenSon++
					dbSelectArea(cTrbTree)
					dbSkip()
				EndDo
				nX++
			EndDo

			For nX := 1 To Len(aFilho)
				dbSelectArea(cTrbTree)
				dbSetOrder(2)
				dbSeek("001"+aFilho[nX])
				oTree:TreeSeek(aFilho[nX])
				fChangeBmp((cTrbTree)->TIPO,"1")

				RecLock(cTrbTree,.F.)
				(cTrbTree)->FILTRO := "2"
				(cTrbTree)->MARCA  := "1"
				(cTrbTree)->RESTRI  := ""
				(cTrbTree)->(MsUnLock())

			Next nX
		EndIf
	Else
		lFilho := .F.//Se tiver restricao, verifica se replica restricoes
		dbSelectArea(cTrbTree)
		dbSetOrder(2)
		dbSeek("001"+cCodPro)

		If (nRet := fDefOpcRot((cTrbTree)->TIPO, cTrbTree)) == 0
			Return .F.
		EndIf
		cRestri := (cTrbTree)->RESTRI
		If nRet == 1 .And. !Empty(cRestri)
			//Verifica se tem itens filhos
			dbSelectArea(cTrbTree)
			dbSetOrder(1)
			If dbSeek("001"+cCodPro)
				lFilho := MsgYesNo(STR0041) //"Deseja replicar as restrições informadas para todos os filhos desta localização?"
			EndIf
		ElseIf nRet == 2//Se estiver vazio, coloca todos de verde
			MarkTree(oTree,cTrbTree,.T.)
			Return .T.
		EndIf

		//Resposiciona
		dbSelectArea(cTrbTree)
		dbSetOrder(2)
		dbSeek("001"+cCodPro)

		aAdd(aDelMark,(cTrbTree)->CODPRO)

		//+------------------------------------------------------------+
		//| Desmarca todos os itens abaixo da localizacao selecionada  |
		//+------------------------------------------------------------+
		If Empty(cRestri) .or. lFilho
			dbSelectArea(cTrbTree)
			dbSetOrder(1)
			While nX <= nLenSon
				cPai := aDelMark[nX]

				dbSeek("001"+cPai)
				While !Eof() .And. (cTrbTree)->NIVSUP == cPai
					If (nPos := aScan(aMarkTree,{|a| a == (cTrbTree)->CODPRO})) > 0 .or. lFilho
						aAdd(aDelMark,(cTrbTree)->CODPRO)
						nLenSon++
					EndIf

					dbSelectArea(cTrbTree)
					dbSkip()
				EndDo
				nX++
			EndDo
		EndIf

		For nX := 1 To Len(aDelMark)
			dbSelectArea(cTrbTree)
			dbSetOrder(2)
			dbSeek("001"+aDelMark[nX])
			oTree:TreeSeek(aDelMark[nX])

			If Empty(cRestri)
				RecLock(cTrbTree,.F.)
				(cTrbTree)->FILTRO := "1"
				(cTrbTree)->MARCA  := "2"
				(cTrbTree)->RESTRI := ""
				(cTrbTree)->(MsUnLock())

				fChangeBmp((cTrbTree)->TIPO,"3")

				nPos := aScan(aMarkTree,{|a| a == aDelMark[nX]})
				aDel( aMarkTree, nPos )
				aSize( aMarkTree, Len( aMarkTree ) - 1 )
			ElseIf !Empty((cTrbTree)->RESTRI) .or. lFilho
				RecLock(cTrbTree,.F.)
				(cTrbTree)->FILTRO := "2"
				(cTrbTree)->MARCA  := "1"
				(cTrbTree)->RESTRI  := fChgRestri(cRestri, Substr((cTrbTree)->CARGO,1,3))
				(cTrbTree)->(MsUnLock())

				fChangeBmp((cTrbTree)->TIPO,"2")

				If aScan(aMarkTree,{|a| a == aDelMark[nX]}) == 0
					aAdd(aMarkTree, aDelMark[nX])
				EndIf
			EndIf

		Next nX
	EndIf

	//+----------------------------------+
	//| Seta ao item inicial na Arvore   |
	//+----------------------------------+
	oTree:TreeSeek(cCodPro)

Return
/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Programa  ³MenuDef   ³ Autor ³Vitor Emanuel Batista  ³ Data ³14/06/2010³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Utilizacao de menu Funcional                               ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³Array com opcoes da rotina.                                 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³Parametros do array a Rotina:                               ³±±
±±³          ³1. Nome a aparecer no cabecalho                             ³±±
±±³          ³2. Nome da Rotina associada                                 ³±±
±±³          ³3. Reservado                                                ³±±
±±³          ³4. Tipo de Transa‡„o a ser efetuada:                        ³±±
±±³          ³    1 - Pesquisa e Posiciona em um Banco de Dados           ³±±
±±³          ³    2 - Simplesmente Mostra os Campos                       ³±±
±±³          ³    3 - Inclui registros no Bancos de Dados                 ³±±
±±³          ³    4 - Altera o registro corrente                          ³±±
±±³          ³    5 - Remove o registro corrente do Banco de Dados        ³±±
±±³          ³5. Nivel de acesso                                          ³±±
±±³          ³6. Habilita Menu Funcional                                  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³   DATA   ³ Programador   ³Manutencao efetuada                         ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Static Function MenuDef()

	Local aRotina

	aRotina := 	{	{STR0021,"AxPesqui" , 0, 1},; //"Pesquisar"
	{STR0022,"MNT904PER", 0, 2},; //"Visualizar"
	{STR0023,"MNT904PER", 0, 3},; //"Incluir"
	{STR0024,"MNT904PER", 0, 4},; //"Alterar"
	{STR0025,"MNT904PER", 0, 5,3}} //"Excluir"

Return aRotina

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³MNT904TIPO ³ Autor ³Vitor Emanuel Batista ³ Data ³16/06/2010³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³Validacao do campo TUA_TIPO, alterando o tamanho e consulta ³±±
±±³          ³do campo TUA_GRPUSR                                         ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³MNTA904                                                     ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function MNT904TIPO()
	aTrocaF3 := {}
	M->TUA_GRPUSR := Space(TAMSX3("TUA_GRPUSR")[1])
	M->TUA_NOME := Space(25)

	If M->TUA_TIPO == "1" //Grupo de Usuário
		aAdd(aTrocaF3,{"TUA_GRPUSR","GRP"})
	Else
		aAdd(aTrocaF3,{"TUA_GRPUSR","USR"})
	EndIf

Return .T.

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³MNT904GRPUS³ Autor ³Vitor Emanuel Batista ³ Data ³16/06/2010³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³Validacao do campo TUA_GRPUSR, verificando a existencia do  ³±±
±±³          ³Grupo de Usuario ou do Usuario, de acordo com o TUA_TIPO    ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³MNTA904                                                     ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function MNT904GRPUS(lFolder)
	Default lFolder := .F.

	If !Empty(M->TUA_GRPUSR) .or. lFolder
		If M->TUA_TIPO == "1" //Grupo de Usuário
			PswOrder(1) //Seta indice por Grupo de Usuário
			If !PswSeek( M->TUA_GRPUSR , .F.)
				Help(" ",1,"REGNOIS")
				Return .F.
			EndIf
		Else
			If !UsrExist(M->TUA_GRPUSR)
				Return .F.
			EndIf
		EndIf

		If !ExistChav("TUA",M->TUA_TIPRES+M->TUA_TIPO+M->TUA_GRPUSR)
			Return .F.
		EndIf

		M->TUA_NOME := MNT904NOME()
	EndIf
Return .T.

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³MNT904NOME ³ Autor ³Vitor Emanuel Batista ³ Data ³16/06/2010³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³Retorna nome do Grupo de Usuario ou do Usuario, de acordo   ³±±
±±³          ³com o TUA_TIPO                                              ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³MNTA904                                                     ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function MNT904NOME(lBrowse)

	Local cNome := Space(40)
	Local cTipo, cGrpUsr

	Default lBrowse := .F.

	If lBrowse //Se funcao estiver sendo chamado pelo X3_INIBRW
		cTipo   := TUA->TUA_TIPO
		cGrpUsr := TUA->TUA_GRPUSR
	Else ////Se funcao estiver sendo chamado pelo X3_RELACAO
		cTipo   := M->TUA_TIPO
		cGrpUsr := M->TUA_GRPUSR
	EndIf

	If cTipo == "1" .And. !Empty(cGrpUsr)
		cNome := GrpRetName(cGrpUsr)
	Else
		cNome := Substr(UsrFullName(cGrpUsr),1,40)
	EndIf

Return cNome


/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³LoadMarkTree³ Autor ³Vitor Emanuel Batista ³ Data ³23/06/2010³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³Verifica se ha permissao para visualizar registro na TAF     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³aTables - Vetor com as tabelas temporarias                   ³±±
±±³          ³oTree   - Objeto Tree                                        ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ MNTA904                                                     ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Static Function LoadMarkTree(aTables,oTree)

	Local aArea := GetArea()
	Local aAreaTmp
	Local cTrbTree := aTables[__FOLDER_TAF__]
	Local lRet
	Local nNivel
	Local cCodPro

	aMarkTree := {}
	oTree:BeginUpdate()
	dbSelectArea(cTrbTree)
	dbSetOrder(5)
	dbGoTop()
	ProcRegua(RecCount()*2)
	While !Eof()
		IncProc()

		lRet := (cTrbTree)->MARCA == "1" .And. (cTrbTree)->FILTRO == "2"

		If !lRet .And. !((cTrbTree)->MARCA == "2" .And. (cTrbTree)->FILTRO == "1")
			lRet := .T.
			//+--------------------------+
			//| Se registro for um Bem   |
			//+--------------------------+
			If (cTrbTree)->TIPO == "1"
				dbSelectArea("ST9")
				dbSetOrder(1)
				dbSeek(xFilial("ST9")+(cTrbTree)->CODTIPO)

				//+----------------------------------------------+
				//| Verifica se existe Centro de Custo do Bem    |
				//+----------------------------------------------+
				dbSelectArea(aTables[__FOLDER_CTT__])
				dbSetOrder(1)
				If dbSeek(xFilial("CTT")+ST9->T9_CCUSTO) .And. Empty((aTables[__FOLDER_CTT__])->TRB_OK)
					lRet := .F.
				EndIf

				//+----------------------------------------------+
				//| Verifica se existe Centro de Trabalho do Bem |
				//+----------------------------------------------+
				If lRet .And. !Empty(ST9->T9_CENTRAB)
					dbSelectArea(aTables[__FOLDER_SHB__])
					dbSetOrder(1)
					If dbSeek(xFilial("SHB")+ST9->T9_CENTRAB) .And. Empty((aTables[__FOLDER_SHB__])->TRB_OK)
						lRet := .F.
					EndIf
				EndIf

				//+----------------------------------------------+
				//| Verifica se existe Tipo de Modelo do Bem     |
				//+----------------------------------------------+
				dbSelectArea(aTables[__FOLDER_ST6__])
				dbSetOrder(1)
				If lRet .And. dbSeek(xFilial("ST6")+ST9->T9_CODFAMI) .And. Empty((aTables[__FOLDER_ST6__])->TRB_OK)
					lRet := .F.
				EndIf

				//+----------------------------------------------+
				//| Verifica se existe Tipo de Modelo do Bem     |
				//+----------------------------------------------+
				If lRet .And. NGCADICBASE("T9_TIPMOD","A","ST9",.F.)
					dbSelectArea(aTables[__FOLDER_TQR__])
					dbSetOrder(1)
					If dbSeek(xFilial("TQR")+ST9->T9_TIPMOD) .And. Empty((aTables[__FOLDER_TQR__])->TRB_OK)
						lRet := .F.
					EndIf
				EndIf

			Else //Se for Localizacao

				//+----------------------------------------------+
				//| Verifica se existe Centro de Custo do Bem    |
				//+----------------------------------------------+
				If !Empty((cTrbTree)->CC)
					dbSelectArea(aTables[__FOLDER_CTT__])
					dbSetOrder(1)
					If dbSeek(xFilial("CTT")+(cTrbTree)->CC) .And. Empty((aTables[__FOLDER_CTT__])->TRB_OK)
						lRet := .F.
					EndIf
				EndIf

				//+----------------------------------------------+
				//| Verifica se existe Centro de Trabalho do Bem |
				//+----------------------------------------------+
				If lRet .And. !Empty((cTrbTree)->CENTRAB)
					dbSelectArea(aTables[__FOLDER_SHB__])
					dbSetOrder(1)
					If dbSeek(xFilial("SHB")+(cTrbTree)->CENTRAB) .And. Empty((aTables[__FOLDER_SHB__])->TRB_OK)
						lRet := .F.
					EndIf
				EndIf

			EndIf

			If lRet
				RecLock(cTrbTree,.F.)
				(cTrbTree)->FILTRO := "1"
				(cTrbTree)->MARCA  := "1"
				(cTrbTree)->(MsUnLock())
			EndIf
		EndIf

		If lRet .And. Val( (cTrbTree)->CODPRO ) != 1
			aAreaTmp := (cTrbTree)->(GetArea())
			dbSelectArea(cTrbTree)
			dbSetOrder(2)
			dbSeek("001"+(cTrbTree)->NIVSUP)
			lRet := (cTrbTree)->MARCA == "1"
			RestArea(aAreaTmp)

		EndIf

		oTree:TreeSeek((cTrbTree)->CODPRO)
		If aScan(aMarkTree,{|a| a == (cTrbTree)->CODPRO}) == 0
			If !lRet
				If !Empty((cTrbTree)->RESTRI)
					fChangeBmp((cTrbTree)->TIPO,"2")
				Else
					fChangeBmp((cTrbTree)->TIPO,"3")
				EndIf
				If (cTrbTree)->MARCA == "1"
					RecLock(cTrbTree,.F.)
					(cTrbTree)->FILTRO := "2"
					(cTrbTree)->MARCA  := "2"
					(cTrbTree)->(MsUnLock())
				EndIf
			Else

				aAreaTmp := (cTrbTree)->(GetArea())
				//+---------------------------------------------------------------+
				//| Marca todas as Localizacoes Pai (acima) do item selecionado   |
				//+---------------------------------------------------------------+
				cCodPro := (cTrbTree)->CODPRO
				dbSelectArea(cTrbTree)
				dbSetOrder(2)

				While !Eof()
					If (nPos := aScan(aMarkTree,{|a| a == (cTrbTree)->CODPRO})) > 0
						Exit
					EndIf
					aAdd(aMarkTree,(cTrbTree)->CODPRO)
					If oTree:TreeSeek((cTrbTree)->CODPRO)
						If !Empty((cTrbTree)->RESTRI)
							fChangeBmp((cTrbTree)->TIPO,"2")
						Else
							fChangeBmp((cTrbTree)->TIPO,"1")
						EndIf
					EndIf

					If cCodPro <> (cTrbTree)->CODPRO
						RecLock(cTrbTree,.F.)
						(cTrbTree)->FILTRO := "1"
						(cTrbTree)->MARCA  := "1"
						(cTrbTree)->(MsUnLock())
					EndIf

					dbSelectArea(cTrbTree)
					dbSeek("001"+(cTrbTree)->NIVSUP)
				EndDo
				RestArea(aAreaTmp)
			EndIf
		EndIf

		dbSelectArea(cTrbTree)
		dbSkip()
	EndDo

	//+----------------------------------+
	//| Fecha folders de todos os filhos |
	//+----------------------------------+
	nNivel := nMaxNivel
	dbSelectArea(cTrbTree)
	dbSetOrder(5)
	dbGoTop()
	If (cTrbTree)->(RecCount()) > 0
		ProcRegua(nNivel)
		While nNivel >= 1

			IncProc()
            dbSeek("001"+Str(nNivel,2,0))
			While (cTrbTree)->NIVEL == nNivel

				If (cTrbTree)->TIPO == "1"
					cCargo   := "BEM"
				ElseIf (cTrbTree)->TIPO == "2"
					cCargo := "LOC"
				EndIf

				oTree:TreeSeek((cTrbTree)->CODPRO+cCargo)

				oTree:PtCollapse()
				(cTrbTree)->(dbSkip())
			End
			nNivel--
		End
	EndIf

	oTree:EndUpdate()
	oTree:EndTree()
	oTree:TreeSeek("001LOC")

	RestArea(aArea)
Return .F.

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³NGVerifTUB³ Autor ³ Vitor Emanuel Batista ³ Data ³24/08/2010³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³Valida se item sera visivel na arvore logica ou nao.        ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³cTipo - Tipo de restricao (1=Grupo;2=Usuario).              ³±±
±±³          ³cGrpUsr - Codigo do Grupo ou do usuario.                    ³±±
±±³          ³cOpc    - Codigo da opcao a ser verificada na restricao.    ³±±
±±³          ³cCodigo - Codigo do registro a ser verificado.              ³±±
±±³          ³cTipRes - Tipo da Restricao (1=Arvore Logica;2=Distribuicao)³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ Generico                                                   ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function NGVerifTUB(cTipo,cGrpUsr,cOpc,cCodigo,cTipRes)
	
	Local aArea    := GetArea()
	Local aAreaTUB := TUB->(GetArea())
	Local lRet     := .T.
	
	Default cTipRes := '1' // Arvore Lógica

	dbSelectArea( "TUB" )
	dbSetOrder( 1 )
	
	Do Case
		
		Case cOpc == '2' // Centro de Trabalho

			If !Empty( cCodigo ) .And. dbSeek( xFilial( 'TUB' ) + cTipRes + cTipo + cGrpUsr + cOpc + cCodigo )
				lRet := .F.
			EndIf

		Case cOpc == '7' // Serviço da Manutenção

			If dbSeek( xFilial( 'TUB' ) + cTipRes + cTipo + cGrpUsr + cOpc + cCodigo )
				lRet := .F.
			EndIf

			If lRet 
				
				dbSelectArea( 'ST4' )
				dbSetOrder( 1 )
				dbSeek( xFilial( 'ST4' ) + cCodigo )
				If ( lRet := NGVerifTUB( cTipo, cGrpUsr, '5', ST4->T4_CODAREA, cTipRes ) )
					lRet := NGVerifTUB( cTipo, cGrpUsr, '6', ST4->T4_TIPOMAN, cTipRes )
				EndIf

			EndIf
		
		Case cOpc $ '0/8' // Bem ou Localização

			If !dbSeek( xFilial( 'TUB' ) + cTipRes + cTipo + cGrpUsr + cOpc + cCodigo ) .Or.;
				( TUB->TUB_MARCA == '2' .And. Empty( TUB->TUB_RESTRI ) )
				lRet := .F.
			EndIf

		OtherWise // C.C. # Área da Manut. # Tipo Manut. # Família # Modelo

			If dbSeek( xFilial( 'TUB' ) + cTipRes + cTipo + cGrpUsr + cOpc + cCodigo )
				lRet := .F.
			EndIf

	End Case

	RestArea( aAreaTUB )
	RestArea( aArea )

Return lRet

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³TreePopUp ³ Autor ³ Vitor Emanuel Batista ³ Data ³19/08/2010³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³Monta o Menu PopUP                                          ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ oMenu  - Objeto do Menu                                    ³±±
±±³          ³ oParent- Objeto pai do oMenu                               ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³MNTA904                                                     ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Static Function TreePopUp( oMenu, oParent )

	MENU oMenu POPUP

		MENUITEM STR0026 Action Visualize(cAliasAtu,aAlias[nFolderAtu]) Resource "DBG10" //"Visualizar Registro"
		MENUITEM STR0002 Action MarkTree(aObjects[__FOLDER_TAF__],aTables[__FOLDER_TAF__]) Resource "NCO" //"Marcar/Desmarcar"
	
	ENDMENU

Return

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³RemakeTree³ Autor ³ Vitor Emanuel Batista ³ Data ³19/08/2010³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³Remonta a Arvore Logica de acordo com os Folders de Filtro, ³±±
±±³          ³desconsiderando as marcacoes feitas manualmente             ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³aTables - Vetor com as tabelas temporarias                  ³±±
±±³          ³oTree   - Objeto Tree                                       ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³MNTA904                                                     ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Static Function RemakeTree(aTables,oTree)
	Local cTrbTree := aTables[__FOLDER_TAF__]

	If !MsgYesNo(STR0027+CRLF+; //"Deseja refazer a marcação dos itens da Árvore de acordo com o filtro?"
	STR0028+CRLF+; //"Esta operação irá desconsiderar todas as seleções feitas manualmente."
	STR0029) //"Deseja prosseguir?"
		Return .F.
	EndIf

	dbSelectArea(cTrbTree)
	dbGoTop()
	ProcRegua(RecCount()*2)
	While !Eof()
		IncProc()

		If (cTrbTree)->MARCA != "2" .Or. (cTrbTree)->FILTRO != "2"
			RecLock(cTrbTree,.F.)
			(cTrbTree)->FILTRO := "2"
			(cTrbTree)->MARCA  := "2"
			(cTrbTree)->RESTRI := ""
			(cTrbTree)->(MsUnLock())
		EndIf

		dbSelectArea(cTrbTree)
		dbSkip()
	EndDo

	Processa({|| LoadMarkTree(aTables,oTree) },STR0003, STR0019) //"Aguarde..."##"Selecionando itens de acordo com filtro..."
Return

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³HideFolder³ Autor ³ Vitor Emanuel Batista ³ Data ³10/11/2010³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³Desabilita os folder de acordo com o compartilhamento das   ³±±
±±³          ³suas respectivas tabelas                                    ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³oFolder - Objeto TFolder                                    ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³MNTA904                                                     ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Static Function HideFolder(oFolder)
	Local nX

	For nX := 1 To Len(aAlias)
		If __FOLDER_TAF__ != nX
			If NGSX2MODO("TAF") != NGSX2MODO(aAlias[Nx]) .And. NGSX2MODO(aAlias[Nx]) != "C"
				oFolder:aEnable(nX,.F.)
			EndIf
		EndIf
	Next nX

Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³fDefOpcRotºAutor  ³Roger Rodrigues     º Data ³  13/05/11   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³DEFINE opcoes permitidas no click da direita na A.L.        º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³MNTA904                                                     º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function fDefOpcRot(cOpcArv, cTrbTree)

	Local oDlgOpc
	Local i
	Local nConfirma:= 0, lTodos := .F.
	Local lInverte := .F.
	Local cOpcao   := (cTrbTree)->RESTRI, lMark := .F.
	Local aDbfOpc  := {}, aMarkOpc := {}
	Local cTrbOpc  := GetNextAlias()
	Local aOpcoes  := MNT904OPC(Substr((cTrbTree)->CARGO,1,3))
	Local oTmpTbl3

	aAdd(aDbfOpc,{ "TRB_OK"       , "C" ,02, 0 })
	aAdd(aDbfOpc,{ "TRB_CODIGO"   , "C" ,03, 0 })
	aAdd(aDbfOpc,{ "TRB_DESCRI"   , "C" ,75, 0 })
	aAdd(aDbfOpc,{ "TRB_DEPEND"   , "C" ,03, 0 })

	oTmpTbl3 := NGFwTmpTbl(cTrbOpc,aDbfOpc,{{"TRB_CODIGO"},{"TRB_DESCRI"},{"TRB_DEPEND"}})

	aAdd(aMarkOpc,{"TRB_OK"       ,NIL," ",})
	aAdd(aMarkOpc,{"TRB_DESCRI"   ,NIL,STR0042,}) //"Opção"

	For i:=1 to Len(aOpcoes)
		lMark := MNT904VOPC(cOpcao,Substr(aOpcoes[i,1],1,1),Substr(aOpcoes[i,1],3,1))
		dbSelectArea(cTrbOpc)
		RecLock(cTrbOpc, .T.)
		If lMark
			(cTrbOpc)->TRB_OK := cMarca
		EndIf
		(cTrbOpc)->TRB_CODIGO := aOpcoes[i,1]
		(cTrbOpc)->TRB_DESCRI := aOpcoes[i,2]
		(cTrbOpc)->TRB_DEPEND := aOpcoes[i,3]
		(cTrbOpc)->(MsUnlock())
	Next i
	dbSelectArea(cTrbOpc)
	dbSetOrder(3)
	dbGoTop()

	DEFINE MsDIALOG oDlgOpc FROM 120,0 To 480,540 TITLE STR0043 Of oMainWnd COLOR CLR_BLACK,CLR_WHITE Pixel //"Definição de Opções"

	oMarkOpc := MsSelect():New(cTrbOpc,"TRB_OK",,aMarkOpc,@lInverte,@cMarca,{12,0,200,200},,,oDlgOpc)
	If !Inclui .And. !Altera//Nao permite marcacao na visualizacao
		oMarkOpc:bMark := {|| If(Empty((cTrbOpc)->TRB_OK),(cTrbOpc)->TRB_OK := cMarca, (cTrbOpc)->TRB_OK := Space(2))}
	Else
		oMarkOpc:bMark := {|| fMarkOpc(cTrbOpc, aOpcoes, (cTrbOpc)->TRB_CODIGO, !Empty((cTrbOpc)->TRB_OK), cMarca ) .And. oMarkOpc:oBrowse:Refresh()}
	EndIf
	oMarkOpc:oBrowse:lHasMark    := .T.
	oMarkOpc:oBrowse:lCanAllMark := .T.
	oMarkOpc:oBrowse:bAllMark    := { || MarkInverte(cMarca,cTrbOpc,.T.) }
	oMarkOpc:oBrowse:Align := CONTROL_ALIGN_ALLCLIENT

	ACTIVATE MsDIALOG oDlgOpc ON INIT EnchoiceBar(@oDlgOpc,{|| nConfirma := 1,oDlgOpc:End()},;
	{|| nConfirma := 0,oDlgOpc:End()}) CENTERED

	If nConfirma > 0 .And. (Inclui .or. Altera)
		cOpcao   := ""
		//Grava as opcoes em uma string
		lTodos := .T.
		dbSelectArea(cTrbOpc)
		dbSetOrder(1)
		dbGoTop()
		While !eof()
			If !Empty((cTrbOpc)->TRB_OK)
				If At(Substr((cTrbOpc)->TRB_CODIGO,1,2), cOpcao) == 0
					If !Empty(cOpcao)
						cOpcao += ";"
					EndIf
					cOpcao += (cTrbOpc)->TRB_CODIGO
				Else
					cOpcao += Substr((cTrbOpc)->TRB_CODIGO,3,1)
				EndIf
			Else
				lTodos := .F.
			EndIf
			dbSelectArea(cTrbOpc)
			dbSkip()
		End
		If !Empty(cOpcao)
			cOpcao += ";"
		EndIf
		If lTodos
			cOpcao := ""
			nConfirma := 2
		EndIf
		RecLock(cTrbTree,.F.)
		(cTrbTree)->RESTRI := cOpcao
		(cTrbTree)->(MsUnlock())
	EndIf

	oTmpTbl3:Delete()

Return nConfirma//0 Cancela, 1 Confirma, 2 Confirma sem Restricoes

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³MNT904OPC   ºAutor  ³Roger Rodrigues   º Data ³  13/05/11   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Retorna array com opcoes da AL                              º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³MNTA904                                                     º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function MNT904OPC(cTipo)
	Local aRetorno := {}
	Default cTipo  := "LOC"

	//Codigo, Descricao, Dependencia
	If cTipo == "LOC"
		aAdd(aRetorno, {"L=I", STR0044, "L=V"} ) //"Incluir localização."
		aAdd(aRetorno, {"L=A", STR0045, "L=V"} ) //"Alterar localização."
		aAdd(aRetorno, {"L=E", STR0046, "L=V"} ) //"Excluir localização."
		aAdd(aRetorno, {"L=V", STR0047, ""} ) //"Visualizar localização."
		aAdd(aRetorno, {"B=I", STR0048, "L=V"} ) //"Incluir bem."
	ElseIf cTipo == "BEM"
		aAdd(aRetorno, {"B=E", STR0049, "B=V"} ) //"Excluir bem."
		aAdd(aRetorno, {"B=V", STR0050, ""} ) //"Visualizar bem."
		aAdd(aRetorno, {"O=P", STR0051, "O=V" }) //"Incluir ordem de serviço preventiva."
	EndIf

	aAdd(aRetorno, {"S=I", STR0052, "S=V"} ) //"Incluir solicitação de serviço."
	aAdd(aRetorno, {"S=A", STR0053, "S=V"} ) //"Alterar solicitação de serviço."
	aAdd(aRetorno, {"S=E", STR0054, "S=V"} ) //"Excluir solicitação de serviço."
	aAdd(aRetorno, {"S=G", STR0055, "S=V"} ) //"Gerar ordem de serviço a partir da solicitação de serviço."
	aAdd(aRetorno, {"S=D", STR0056, "S=V"} ) //"Distribuir solicitações de serviço."
	aAdd(aRetorno, {"S=F", STR0057, "S=V"} ) //"Finalizar solicitações de serviço."
	aAdd(aRetorno, {"S=S", STR0058, "S=V"} ) //"Realizar pesquisa de satisfação de solicitações de serviço."
	aAdd(aRetorno, {"S=V", STR0059, If(cTipo == "BEM","B=V","L=V")} ) //"Visualizar solicitações de serviço."

	aAdd(aRetorno, {"O=C", STR0060, "O=V"} ) //"Incluir ordem de serviço corretiva."
	aAdd(aRetorno, {"O=L", STR0061, "O=V"} ) //"Liberar ordens de serviço."
	aAdd(aRetorno, {"O=R", STR0062, "O=V"} ) //"Retornar ordens de serviço."
	aAdd(aRetorno, {"O=V", STR0063, If(cTipo == "BEM","B=V","L=V")} ) //"Visualizar ordens de serviço."

Return aRetorno

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³MNT904VOPCºAutor  ³Roger Rodrigues     º Data ³  16/05/11   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Verifica se o item esta na string de permissao              º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³MNTA904                                                     º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function MNT904VOPC(cOpcoes,cTipo,cOperac)
	Local i, nPos, nPos2
	Local cString := ""
	Local lRet := .F.

	//Verifica se tipo esta definido
	If (nPos := At(cTipo+"=",cOpcoes)) > 0 .And. (nPos2 := At(";",Substr(cOpcoes,nPos))) > 0
		//Verifica operacao
		cString := Substr(cOpcoes,nPos,(nPos2-1))
		For i:=1 to Len(cString)
			If i > 2
				If Substr(cString,i,1) == cOperac
					lRet := .T.
					Exit
				EndIf
			EndIf
		Next i
	Else
		lRet := .F.
	EndIf

Return lRet

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³fMarkOpc  ºAutor  ³Roger Rodrigues     º Data ³  17/05/11   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Marca opcoes de restricoes                                  º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³MNTA904                                                     º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function fMarkOpc(cTrbOpc,aOpcoes,cCodigo,lMarca,cMarca)
	Local nRecno := Recno()
	If Inclui .or. Altera
		If lMarca
			dbSelectArea(cTrbOpc)
			dbSetOrder(1)
			If dbSeek(cCodigo)
				RecLock(cTrbOpc,.F.)
				(cTrbOpc)->TRB_OK := cMarca
				(cTrbOpc)->(MsUnlock())
				If !Empty((cTrbOpc)->TRB_DEPEND)
					fMarkOpc(cTrbOpc,aOpcoes,(cTrbOpc)->TRB_DEPEND,lMarca,cMarca)
				EndIf
			EndIf
		Else
			dbSelectArea(cTrbOpc)
			dbSetOrder(1)
			If dbSeek(cCodigo)
				RecLock(cTrbOpc,.F.)
				(cTrbOpc)->TRB_OK := Space(2)
				(cTrbOpc)->(MsUnlock())
			EndIf
			dbSelectArea(cTrbOpc)
			dbSetOrder(3)
			dbSeek(cCodigo)
			While !eof() .And. cCodigo == (cTrbOpc)->TRB_DEPEND
				If !Empty((cTrbOpc)->TRB_DEPEND)
					fMarkOpc(cTrbOpc,aOpcoes,(cTrbOpc)->TRB_CODIGO,lMarca,cMarca)
				Else
					Exit
				EndIf
				dbSelectArea(cTrbOpc)
				dbSkip()
			End
		EndIf
	EndIf
	dbSelectArea(cTrbOpc)
	dbSetOrder(3)
	dbGoTo(nRecno)

Return .T.

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³fChangeBmpºAutor  ³Roger Rodrigues     º Data ³  18/05/11   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Altera imagem dos itens da arvore                           º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³MNTA904                                                     º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function fChangeBmp(cTipo,cCor)

	If cTipo == "1"
		If cCor == "3"
			oTree:ChangeBmp("ng_ico_bemvermelho","ng_ico_bemvermelho")
		ElseIf cCor == "2"
			oTree:ChangeBmp("ng_ico_bemamarelo","ng_ico_bemamarelo")
		Else
			oTree:ChangeBmp("ng_ico_bemverde","ng_ico_bemverde")
		EndIf
	Else
		If cCor == "3"
			oTree:ChangeBmp("FOLDER7","FOLDER8")
		ElseIf cCor == "2"
			oTree:ChangeBmp("FOLDER5","FOLDER6")
		Else
			oTree:ChangeBmp("FOLDER10","FOLDER11")
		EndIf
	EndIf

Return .T.
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³fChgRestriºAutor  ³Roger Rodrigues     º Data ³  19/05/11   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Altera restricao de localizacao para bens                   º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³MNTA904                                                     º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function fChgRestri(cRestri, cCargo)
	Local nPos, nPos2
	Local cString := ""
	Local cRetorno := cRestri
	Local cRestBem := ""

	If cCargo == "BEM"
		//Remove parte B= da loc
		If MNT904VOPC(cRestri,"B","I")
			If (nPos := At("B=",cRestri)) > 0 .And. (nPos2 := At(";",Substr(cRestri,nPos))) > 0
				//Verifica operacao
				cString := Substr(cRestri,nPos,nPos2)
				cRetorno := StrTran(cRetorno,cString,"")
			EndIf
		EndIf
		If MNT904VOPC(cRestri,"L","V")
			cRestBem := "V"
		EndIf
		If MNT904VOPC(cRestri,"L","E")
			cRestBem += "E"
		EndIf
		//Verifica se tipo esta definido
		If (nPos := At("L=",cRestri)) > 0 .And. (nPos2 := At(";",Substr(cRestri,nPos))) > 0
			//Verifica operacao
			cString := Substr(cRestri,nPos,(nPos2-1))
			If !Empty(cRestBem)
				cRetorno := StrTran(cRetorno,cString,"B="+cRestBem)
			Else
				cRetorno := StrTran(cRetorno,cString,"")
			EndIf
		EndIf
	EndIf
Return cRetorno

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³fLegenda  ºAutor  ³Roger Rodrigues     º Data ³  10/06/11   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Monta tela de legenda                                       º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³MNTA904                                                     º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function fLegenda()
	Local oDlgLeg
	Local oPnlLegend
	Local nColImg := 13, nColTxt := 30

	DEFINE MsDialog oDlgLeg Title OemToAnsi(cCadastro) From 0,0 To 250,235 OF oMainWnd Pixel

	oPnlLegend := TPanel():New(0,0,,oDlgLeg,,,,,CLR_WHITE,0,18,.F.,.F.)
	oPnlLegend:Align := CONTROL_ALIGN_ALLCLIENT

	@ 008,005 To 120,113 LABEL Oemtoansi(STR0039) OF oPnlLegend Pixel //"Legenda"

	oBmp := TBitmap():New(17,nColImg,0,0,"FOLDER10",,.T.,oPnlLegend,,,.F.,.F.,,,.F.,,.T.,,.F.)
	oBmp:lAutoSize := .T.
	TSay():New(20,nColTxt,{|| STR0013},oPnlLegend,,,,,,.T.,CLR_BLACK,,200,20) //"Localização Liberada"

	oBmp := TBitmap():New(32,nColImg,0,0,"FOLDER5",,.T.,oPnlLegend,,,.F.,.F.,,,.F.,,.T.,,.F.)
	oBmp:lAutoSize := .T.
	TSay():New(35,nColTxt,{|| STR0064},oPnlLegend,,,,,,.T.,CLR_BLACK,,200,20) //"Localização com Restrições"

	oBmp := TBitmap():New(47,nColImg,0,0,"FOLDER7",,.T.,oPnlLegend,,,.F.,.F.,,,.F.,,.T.,,.F.)
	oBmp:lAutoSize := .T.
	TSay():New(50,nColTxt,{|| STR0014},oPnlLegend,,,,,,.T.,CLR_BLACK,,200,20) //"Localização Desmarcada"

	oBmp := TBitmap():New(65,nColImg,0,0,"ng_ico_bemverde",,.T.,oPnlLegend,,,.F.,.F.,,,.F.,,.T.,,.F.)
	oBmp:lAutoSize := .T.
	TSay():New(68,nColTxt,{|| STR0015},oPnlLegend,,,,,,.T.,CLR_BLACK,,200,20) //"Bem Marcado"

	oBmp := TBitmap():New(83,nColImg,0,0,"ng_ico_bemamarelo",,.T.,oPnlLegend,,,.F.,.F.,,,.F.,,.T.,,.F.)
	oBmp:lAutoSize := .T.
	TSay():New(86,nColTxt,{|| STR0065},oPnlLegend,,,,,,.T.,CLR_BLACK,,200,20) //"Bem com Restrições"

	oBmp := TBitmap():New(101,nColImg,0,0,"ng_ico_bemvermelho",,.T.,oPnlLegend,,,.F.,.F.,,,.F.,,.T.,,.F.)
	oBmp:lAutoSize := .T.
	TSay():New(104,nColTxt,{|| STR0016},oPnlLegend,,,,,,.T.,CLR_BLACK,,200,20) //"Bem Desmarcado"

	Activate MsDialog oDlgLeg Centered


Return .T.

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³MNT904WHENºAutor  ³Roger Rodrigues     º Data ³  15/06/11   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³When dos campos da tela                                     º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³MNTA904                                                     º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function MNT904WHEN(cCampo)
	Local lRet := .T.

	If cCampo == "TUA_TIPRES"
		lRet := NGCADICBASE("TUA_INFARE","A","TUA",.F.)
	EndIf

Return lRet

//-----------------------------------------------------------------------
/*/{Protheus.doc} DeleteTree
Deleta registros que já possuam restrições para recriar a estrutura.
@type function

@author Alexandre Santos
@since 19/04/2021

@param  cTRBTree, string, Alias que controla estrutura da árvore.
@return
/*/
//-----------------------------------------------------------------------
Static Function DeleteTree( cTRBTree )

	Local cAlsTUB := GetNextAlias()

	BeginSQL Alias cAlsTUB

		SELECT
			TUB.TUB_CODIGO,
			TUB.TUB_OPCAO
		FROM
			%table:TUB% TUB
		WHERE
			TUB.TUB_FILIAL = %xFilial:TUB%       AND
			TUB.TUB_TIPRES = %exp:M->TUA_TIPRES% AND
			TUB.TUB_TIPO   = %exp:M->TUA_TIPO%   AND
			TUB.TUB_GRPUSR = %exp:M->TUA_GRPUSR% AND
			TUB.TUB_OPCAO IN ( '8', '0' )       AND
			TUB.%NotDel%

	EndSQL

	While (cAlsTUB)->( !EoF() )

		If (cAlsTUB)->TUB_OPCAO == '8'

			dbSelectArea( cTRBTree )
			dbSetOrder( 2 ) // CODEST + CODPRO + ORDEM
			If dbSeek( '001' + (cAlsTUB)->TUB_CODIGO ) .And. (cTRBTree)->MARCA == '2' .And. (cTRBTree)->FILTRO == '2'

				RecLock( 'TUB', .F. )
				dbDelete()
				TUB->( MsUnLock() )

			EndIf


		Else

			dbSelectArea( cTRBTree )
			dbSetOrder( 6 ) // CODEST + CODCON
			If dbSeek( '001' + TUB->TUB_CODIGO ) .And. (cTRBTree)->MARCA == '2' .And. (cTRBTree)->FILTRO == '2'

				RecLock( 'TUB', .F. )
					dbDelete()
				TUB->( MsUnLock() )

			EndIf

		EndIf

		(cAlsTUB)->( dbSkip() )

	End

	(cAlsTUB)->( dbCloseArea() )
	
Return

//-----------------------------------------------------------------------
/*/{Protheus.doc} MNTA904UPD
Atualiza os registros da tabela TUB conforme novo agrupador TUB_OPCAO - 0
@type function

@author Alexandre Santos
@since 19/04/2021

@param 
@return
/*/
//-----------------------------------------------------------------------
Function MNTA904UPD()

	Local cUpd := 'UPDATE '
	
	cUpd += 	RetSQLName( 'TUB' )
	cUpd += ' SET '
	cUpd += 	"TUB_OPCAO  = '0', "
	cUpd += 	"TUB_CODIGO = TAF.TAF_CODCON "
	cUpd += "FROM "
	cUpd += 	RetSQLName( 'TUB' ) + " TUB "
	cUpd += "INNER JOIN "
	cUpd += 	RetSQLName( 'TAF' ) + " TAF ON "
	cUpd += 		"TAF.TAF_CODNIV = TUB.TUB_CODIGO AND "
	cUpd += 		"TAF.TAF_INDCON = '1'            AND "
	cUpd += 		"TAF.D_E_L_E_T_ <> '*'           AND "
	cUpd += 		NGModComp( 'TAF', 'TUB' )
	cUpd += "WHERE "
	cUpd += 	"TUB.D_E_L_E_T_ <> '*' AND "
	cUpd += 	"TUB.TUB_OPCAO = '8'"

	TCSqlExec( cUpd )

Return
