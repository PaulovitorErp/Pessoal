#Include "MDTA212.ch"
#Include "Protheus.ch"
#INCLUDE "COLORS.CH"

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³ MDTA212  ³ Autor ³ Thiago Machado        ³ Data ³ 23/07/01 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Programa de  Registro dos Planos Emergenciais nos Laudos.  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ Generico                                                   ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function MDTA212()

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Armazena variaveis p/ devolucao (NGRIGHTCLICK) 						  ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
Local aNGBEGINPRM := NGBEGINPRM()

PRIVATE aRotina := MenuDef()
Private lSigaMdtPS := If( SuperGetMv("MV_MDTPS",.F.,"N") == "S", .t. , .f. )
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Define o cabecalho da tela de atualizacoes                   ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
PRIVATE cCadastro  := STR0001 //"Locais Avaliados no Laudo"
PRIVATE aCHKDEL := {}, bNGGRAVA
Private cPrograma := "MDTA212"
Private cCliMdtPs
Private cTipPE := "2"
//Adicionada verificação de update do campo TJK_DESPLA, apesar de não obrigatório precisa da criação dos campos para o relacionamento de laudo e plano emergencial
If !NGCADICBASE("TJK_DESPLA","A","TJK",.F.)
	If !NGINCOMPDIC(If (lSigaMdtPS,"UPDMDTPS","UPDMDT38"))
		Return .F.
	Endif
Endif

If !NGCADICBASE("TJG_LAUDO","A","TJG",.F.)
	If !NGINCOMPDIC(If (lSigaMdtPS,"UPDMDTPS","UPDMDT53"))
		Return .F.
	Endif
Endif

//Se for prestador de serviço
If lSigaMdtPS
	DbSelectArea("SA1")
	DbSetOrder(1)
	mBrowse( 6, 1,22,75,"SA1")
Else
	MDT212CAD()
Endif

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Devolve variaveis armazenadas (NGRIGHTCLICK) 					  	  ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

NGRETURNPRM(aNGBEGINPRM)

Return .T.

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
Local aRotina
Local lSigaMdtPS := If( SuperGetMv("MV_MDTPS",.F.,"N") == "S", .t. , .f. )

If lSigaMdtPS
	aRotina :=	{ { STR0002, "AxPesqui"  , 0 , 1},;  //"Pesquisar"
                  { STR0003, "NGCAD01"   , 0 , 2},;  //"Visualizar"
                  { STR0005, "MDT212CAD" , 0 , 4} }  //"Laudo"
Else
	aRotina :=  { { STR0002, "AxPesqui"  , 0 , 1},;   //"Pesquisar"
                  { STR0003, "NGCAD01"   , 0 , 2},;   //"Visualizar"
                  { STR0017, "MDT212PE"  , 0 , 4, 3} } //"Planos Emergenciais"
Endif

Return aRotina

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³ MDT230CAD³ Autor ³                       ³ Data ³          ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Monta um browse dos laudos.                                ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ Generico                                                   ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function MDT212CAD()

Local aArea := GetArea()
Local aOldRotina := aCLONE(aROTINA)
Local cOldCad := cCadastro

If lSigaMdtPS
	aRotina := {{ STR0002	, "AxPesqui", 0 , 1},;  //"Pesquisar"
 				{ STR0003	, "NGCAD01"	, 0 , 2},;  //"Visualizar"
                { STR0017, "MDT212PE"  , 0 , 4, 3} } //"Planos Emergenciais"
Endif

DbSelectArea("TO0")
//Se for prestador de serviço faz filtro de laudos por cliente
If lSigaMdtPS
	Set Filter To TO0->TO0_CLIENT+TO0->TO0_LOJA == SA1->A1_COD+SA1->A1_LOJA
	cCliMdtPs := SA1->A1_COD+SA1->A1_LOJA
Endif
DbSetOrder(1)

mBrowse( 6, 1,22,75,"TO0")

aROTINA := aCLONE(aOldRotina)
RestArea(aArea)
cCadastro := cOldCad
Return .T.
/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³ MDT212PE ³ Autor ³Guilherme Benkendorf   ³ Data ³19/12/2012³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Monta um browse dos Planos.                                ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ Generico                                                   ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function MDT212PE( cAlias , nReg, nOpcx )

	//Objetos de Tela
	Local oDlgPE, oPanel, cCampo, oPnlAll
	Local oGetPE
	Local oMenu

	//Variaveis de inicializacao de GetDados
	Local aNoFields := {}
	Local nInd
	Local cKeyGet
	Local cWhileGet

	//Variaveis de tela
	Local aInfo, aPosObj
	Local aSize := MsAdvSize(,.f.,430), aObjects := {}

	//Variaveis de GetDados
	Local lAltProg := If(INCLUI .Or. ALTERA, .T.,.F.)
	Local nX
	Local aAlter := {}
	Private aCols := {}, aHeader := {}, aColsMDT := {}, aColsSGA := {}

	aRotSetOpc( "TJG" , 1 , 4 )

	//Inicializa variaveis de Tela
	Aadd(aObjects,{050,050,.t.,.t.})
	Aadd(aObjects,{100,100,.t.,.t.})
	aInfo   := {aSize[1],aSize[2],aSize[3],aSize[4],0,0}
	aPosObj := MsObjSize(aInfo, aObjects,.t.)

	// Monta a GetDados dos Planos Emergenciais
	aAdd(aNoFields,"TJG_LAUDO")
	aAdd(aNoFields,"TJG_FILIAL")
	aAdd(aNoFields,"TJG_NOME")
	aAdd(aNoFields,"TJG_SEQUEN")
	nInd		:= 1
	cKeyGet 	:= "TO0->TO0_LAUDO"
	cWhileGet 	:= "TJG->TJG_FILIAL == '"+xFilial("TJG")+"' .AND. TJG->TJG_LAUDO == '"+TO0->TO0_LAUDO+"'"

	If !NGCADICBASE("TBB_MODULO","A","TBB",.F.)

		//Monta aCols e aHeader de TJG
		dbSelectArea("TJG")
		dbSetOrder(nInd)
		FillGetDados( nOpcx, "TJG", 1, cKeyGet, {|| }, {|| .T.},aNoFields,,,,;
							{|| NGMontaAcols("TJG",&cKeyGet,cWhileGet)})
		If Empty(aCols)
			aCols := BLANKGETD(aHeader)
		Endif

	Else

		//montando aHeader
		aHeader := CABECGETD( "TJG" , aNoFields , 2 )
		nUsado  := Len( aHeader )

		//montando aCols para o folder MDT e SGA
		DbSelectArea("TJG")
		TJG->(DbSetOrder(1))
		IF TJG->(DbSeek(xFilial("TJG")+TO0->TO0_LAUDO))

			while TJG->(!Eof()) .AND. TJG->TJG_FILIAL == xFilial("TJG") .AND. TJG->TJG_LAUDO == TO0->TO0_LAUDO

				IF NGSEEK('TBB',TJG->TJG_CODPLA,1,'TBB_MODULO') == "2"

					AADD(aColsMDT, Array(len(aHeader)+1))
					aColsMDT[len(aColsMDT),len(aHeader)+1]:= .F.

					For nX:=1 to len(aHeader)

						If !("V" $ aHeader[nX][10])
						cCampo := aHeader[nX][2]
							aColsMDT[len(aColsMDT),nX] := TJG->&cCampo
						Else

							If ExistIni(aHeader[nX][2])

								cCampo := GetSx3Cache( aHeader[nX][2], 'X3_RELACAO' )
								aColsMDT[len(aColsMDT),nX] := &cCampo

							Endif

						Endif

					Next nX

				Else

					AADD(aColsSGA, Array(len(aHeader)+1))
					aColsSGA[len(aColsSGA),len(aHeader)+1]:= .F.

					For nX:=1 to len(aHeader)

						If !("V" $ aHeader[nX][10])
						cCampo := aHeader[nX][2]
							aColsSGA[len(aColsSGA),nX] := TJG->&cCampo

						Else

							If  ExistIni(aHeader[nX][2])

								cCampo := GetSx3Cache( aHeader[nX][2], 'X3_RELACAO' )
								aColsSGA[len(aColsSGA),nX] := &cCampo

							Endif

						Endif

					Next nX

				Endif

				TJG->(DbSkip())
			Enddo

		Endif

		If Empty(aColsMDT)

			aColsMDT:={Array(nUsado+1)}
			aColsMDT[1,nUsado+1]:=.F.
			For nX:=1 to nUsado
				aColsMDT[1,nX]:=CriaVar(aHeader[nX,2])
			Next

		Endif


		If Empty(aColsSGA)

			aColsSGA:={Array(nUsado+1)}
			aColsSGA[1,nUsado+1]:=.F.
			For nX:=1 to nUsado
				aColsSGA[1,nX]:=CriaVar(aHeader[nX,2])
			Next

		Endif

	Endif

	nOpca := 0
	DEFINE MSDIALOG oDlgPE TITLE STR0004 From aSize[7],0 To aSize[6],aSize[5] OF oMainWnd PIXEL   //"Laudo x Plano Emerg."

		oPnlAll := TPanel():New(01,01,,oDlgPE,,,,,,10,10,.F.,.F.)
		oPnlAll:Align := CONTROL_ALIGN_ALLCLIENT

		oPanel := TPanel():New(0, 0, Nil, oPnlAll, Nil, .T., .F., Nil, Nil, 0, 60, .T., .F. )
			oPanel:Align := CONTROL_ALIGN_TOP

			TSay():New( 6 , 7 ,{|| OemtoAnsi(STR0005) },oPanel,,,.F.,.F.,.F.,.T.,CLR_BLACK,CLR_WHITE,020,008)//"Laudo"
			TGet():New( 5 , 27 ,{|u| If( PCount() > 0 , TO0->TO0_LAUDO := u , TO0->TO0_LAUDO )},oPanel,40,10,"@!",;
							,CLR_BLACK,CLR_WHITE,,,,.T.,"",,{|| .F. },.F.,.F.,,.F.,.F.,,,,,,.T.)

			TSay():New( 6 , 84 ,{|| OemtoAnsi(STR0006) },oPanel,,,.F.,.F.,.F.,.T.,CLR_BLACK,CLR_WHITE,020,008)//"Nome Laudo"
			TGet():New( 5 , 120 ,{|u| If( PCount() > 0 , TO0->TO0_NOME := u , TO0->TO0_NOME )},oPanel,150,10,"@!",;
							,CLR_BLACK,CLR_WHITE,,,,.T.,"",,{|| .F. },.F.,.F.,,.F.,.F.,,,,,,.T.)

			TButton():New( 30 , 5 , "&"+STR0007 , oPanel, {|| MDT212BU(@oGetPE) } , 49 , 12 ,, /*oFont*/,,.T.,,,,/* bWhen*/,,)
		PutFileInEof("TJG")


		If !NGCADICBASE("TBB_MODULO","A","TBB",.F.)

			oGetPE   := MsNewGetDados():New(0,0,200,210,IIF(!lAltProg,0,GD_INSERT+GD_UPDATE+GD_DELETE),;
											{|| MDT212Lin("TJG",,@oGetPE)},{|| MDT212Lin("TJG",.T.,@oGetPE)},/*cIniCpos*/,/*aAlterGDa*/,;
											/*nFreeze*/,/*nMax*/,/*cFieldOk */,;
															/*cSuperDel*/,/*cDelOk */,oPnlAll,aHeader,aCols)
				oGetPE:oBrowse:Align := CONTROL_ALIGN_ALLCLIENT

			NGPOPUP(asMenu,@oMenu,oPanel)
			oPanel:bRClicked:= { |o,x,y| oMenu:Activate(x,y,oPanel)}
			aSort(oGetPE:aCOLS,,,{ |x, y| x[1] < y[1] }) //Ordena por plano

		Else

			oPanelABAS := TPanel():New(65,0,,oPnlAll,,,,,,aSize[3],aSize[4]-60 )
			// Cria a Folder
		aTFolder := { "PAE - MDT" , "PAE - SGA" }
			oTFolder := TFolder():New( 0,0,aTFolder,,oPanelAbas,,,,,,aSize[3],aSize[4]-60  )
				oTFolder:bSetOption := { | nOption | ChangeOption( nOption ) }

			oMDT:=MsNewGetDados():New(0,0, aSize[4]-70 ,aSize[3],IIF(!lAltProg,0,GD_INSERT+GD_UPDATE+GD_DELETE),;
										,,,/*aAlter*/,,,,,,oTFolder:aDialogs[1],aHeader,aColsMDT)
			oSGA:=MsNewGetDados():New(0,0, aSize[4]-70 ,aSize[3],IIF(!lAltProg,0,GD_INSERT+GD_UPDATE+GD_DELETE),;
										,,,/*aAlter*/,,,,,,oTFolder:aDialogs[2],aHeader,aColsSGA)

			NGPOPUP(asMenu,@oMenu,oPanel)
			oPanel:bRClicked:= { |o,x,y| oMenu:Activate(x,y,oPanel)}
			aSort(oMDT:aCOLS,,,{ |x, y| x[1] < y[1] }) //Ordena por plano
			aSort(oSGA:aCOLS,,,{ |x, y| x[1] < y[1] }) //Ordena por plano

		Endif

	ACTIVATE MSDIALOG oDlgPE ON INIT EnchoiceBar(oDlgPE,{|| nOpca:=1,If(MDT212TOk(@oGetPE), oDlgPE:End(), nOpca := 0)},{|| oDlgPE:End(),nOpca := 0})

	If nOpca == 1
		fGravaPE(@oGetPE)//Grava plano emergencial
	Endif

Return .T.
//---------------------------------------------------------------------
/*/{Protheus.doc} ChangeOption
Função chamada na Troca de Folder (Utilizada para alimentar o aTROCAF3)

@samples ChangeOption( 1 )

@author Jackson Machado
@since 29/05/2013
@return Nil
/*/
//---------------------------------------------------------------------
Static Function ChangeOption( nOption )

	cTipPE := ""

	If nOption == 1
	 	cTipPE := "2"
	Else
		cTipPE := "1"
	EndIf

Return
/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³ MDT212BU ³ Autor ³Guilherme Benkendorf   ³ Data ³ 20/12/12 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Mostra um markbrowse com todos os Plano de emergincia	  ³±±
±±³          ³ para poder seleciona-los de uma so vez.                    ³±±
±±³			 ³ (Baseado na funcao MDT230BU)								  ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Static Function MDT212BU( oGetPE )
Local aArea := GetArea()
//Variaveis para montar TRB
Local aDBF,aTRBPE
//Variaveis de Tela
Local oDlgF,oFont
Local oMARKF
//
Local nOpt
Local nSizeTJK := If((TAMSX3("TJK_DESPLA")[1]) < 1,80,(TAMSX3("TJK_DESPLA")[1]))
Local lInverte, lRet
Local cAliasTRB := GetNextAlias()
Local aDescIdx	:= {}
Local cPesquisar:=Space( 200 )

Private cMarca := GetMark()
Private OldCols := aCLONE(aCols)
Private aCbxPesq //ComboBox com indices de pesquisa
Private cCbxPesq   := ""
Private oCbxPesq //ComboBox de Pesquisa
lInverte:= .f.


//If !NGCADICBASE("TBB_MODULO","A","TBB",.F.)
	//Valores e Caracteristicas da TRB
	aDBF := {}
	AADD(aDBF,{ "TJK_OK"      , "C" ,02      , 0 })
	AADD(aDBF,{ "TJK_CODPLA"  , "C" ,06      , 0 })
	AADD(aDBF,{ "TJK_DESPLA"  , "C" ,nSizeTJK, 0 })

	aTRBPE := {}
	AADD(aTRBPE,{ "TJK_OK"    ,NIL," "	  	,})
	AADD(aTRBPE,{ "TJK_CODPLA",NIL,STR0008	,})  //"Cod. Plano"
	AADD(aTRBPE,{ "TJK_DESPLA",NIL,STR0009	,})  //"Desc. Plano Emerg."

	If NGCADICBASE("TBB_MODULO","A","TBB",.F.)

		AADD(aDBF,{ "TJK_MODULO","C",03,0	})  //"Módulo"
		AADD(aTRBPE,{ "TJK_MODULO",NIL,STR0018	,})  //"Módulo"

	Endif

	oTempTRB := FWTemporaryTable():New( cAliasTRB, aDBF )
	oTempTRB:AddIndex( "1", {"TJK_CODPLA"} )
	oTempTRB:AddIndex( "2", {"TJK_DESPLA"} )
	oTempTRB:AddIndex( "3", {"TJK_OK"} )
	oTempTRB:Create()

	dbSelectArea("TJK")

	Processa({|lEnd| fBuscaPlano( cAliasTRB , oGetPE )},STR0015,STR0016)//Busca valores dos Planos Emergenciais



Dbselectarea(cAliasTRB)
Dbgotop()
If (cAliasTRB)->(Reccount()) <= 0
	oTempTRB:Delete()
	RestArea(aArea)
	lRefresh := .t.
	Msgstop(STR0011,STR0012)  //"Não existem planos cadastrados" //"ATENÇÃO"
	Return .t.
Endif

nOpt := 0

	If !NGCADICBASE("TBB_MODULO","A","TBB",.F.)
		DEFINE MSDIALOG oDlgF TITLE OemToAnsi(STR0007) From 64,160 To 655,800 OF oMainWnd Pixel  //"Plano Emerg."

	Else
		DEFINE MSDIALOG oDlgF TITLE OemToAnsi(STR0007) From 64,160 To 655,830 OF oMainWnd Pixel  //"Plano Emerg."

	Endif

	//--- PESQUISAR
	//Define as opcoes de Pesquisa
	aCbxPesq := aClone( aDescIdx )
	aAdd( aCbxPesq , STR0019 ) //"Código+Descrição"
	aAdd( aCbxPesq , STR0020 ) //"Descrição+Código"
	aAdd( aCbxPesq , STR0021 ) //"Marcados"
	cCbxPesq := aCbxPesq[ 1 ]

	oPanelTop := TPanel():New( 01 , 01 , , oDlgF , , , , CLR_BLACK , CLR_WHITE , 0 , 55 , .T. , .T. )
	oPanelTop :Align := CONTROL_ALIGN_TOP

	@ 10,08 TO 45 , 265 OF oPanelTop PIXEL
	TSay():New(19,12,{|| OemtoAnsi(STR0013) },oPanelTop,,,.F.,.F.,.F.,.T.,CLR_BLACK,CLR_WHITE,200,010)//"Estes são os planos cadastrados no sistema."
	TSay():New(29,12,{|| OemtoAnsi(STR0014) },oPanelTop,,,.F.,.F.,.F.,.T.,CLR_BLACK,CLR_WHITE,200,010)//"Selecione aqueles que foram avaliados no laudo."

	oPnlPesq 		:= TPanel():New( 01 , 01 , , oDlgF , , , , CLR_BLACK , CLR_WHITE , 0 , 55 , .T. , .T. )
	oPnlPesq:Align	:= CONTROL_ALIGN_TOP

	oCbxPesq := TComboBox():New( 010 , 002 , { | u | If( PCount() > 0 , cCbxPesq := u , cCbxPesq ) } , ;
		aCbxPesq , 200 , 08 , oPnlPesq , , { | | } ;
		, , , , .T. , , , , , , , , , "cCbxPesq" )
	oCbxPesq:bChange := { | | fIndexSet( cAliasTRB , aCbxPesq , @cPesquisar , oMARKF ) }

	oPesquisar := TGet():New( 025 , 002 , { | u | If( PCount() > 0 , cPesquisar := u , cPesquisar ) } , oPnlPesq , 200 , 008 , "" , { | | .T. } , CLR_BLACK , CLR_WHITE , ,;
		.F. , , .T. /*lPixel*/ , , .F. , { | | .T. }/*bWhen*/ , .F. , .F. , , .F. /*lReadOnly*/ , .F. , "" , "cPesquisar" , , , , .F. /*lHasButton*/ )

	oBtnPesq := TButton():New( 010 , 220 , STR0002 , oPnlPesq , { | | fTRBPes( cAliasTRB , oMARKF , cPesquisar) } , ;//"Pesquisar" //"Pesquisar"
	60 , 10 , , , .F. , .T. , .F. , , .F. , , , .F. )

		oMARKF := MsSelect():NEW(cAliasTRB,"TJK_OK",,aTRBPE,@lINVERTE,@cMARCA,{45,5,200,281})
		oMARKF:oBROWSE:lHASMARK := .T.
		oMARKF:oBROWSE:lCANALLMARK := .T.
		oMARKF:oBROWSE:bALLMARK := {|| MDTA212INV(cMarca,cAliasTRB) }//Funcao inverte marcadores
		oMARKF:oBROWSE:ALIGN := CONTROL_ALIGN_TOP

ACTIVATE MSDIALOG oDlgF ON INIT EnchoiceBar(oDlgF,{|| nOpt := 1,oDlgF:End()},{|| nOpt := 0,oDlgf:End()}) CENTERED

lRet := ( nOpt == 1 )

If lRet
	MDT212CPY(@oGetPE,cAliasTRB)//Funcao para copiar planos a GetDados
Endif

oTempTRB:Delete()

RestArea(aArea)

Return lRet
/*/
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³ Fun‡…o   ³MDT212CPY ³ Autor ³Guilhemre Benkendorf   ³ Data ³ 27/12/12 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Descri‡…o³ Copia os planos selecionados no markbrowse para a GetDados ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
/*/
Static Function MDT212CPY(oGetPE,cAliasTRB)
Local nCols, nPosCod
Local aColsOk := {}, aColsOkMDT := {}, aColsOkSGA := {}
Local aHeadOk := {}
Local aColsTp := {}


If !NGCADICBASE("TBB_MODULO","A","TBB",.F.)

	aColsOk := aClone(oGetPE:aCols)
	aHeadOk := aClone(oGetPE:aHeader)
	aColsTp := BLANKGETD(aHeadOk)

	nPosCod := aScan( aHeadOk,{|x| Trim(Upper(x[2])) == "TJG_CODPLA"})
	nPosDes := aScan( aHeadOk,{|x| Trim(Upper(x[2])) == "TJG_DESPLA"})

	For nCols := Len(aColsOk) To 1 Step -1 //Deleta do aColsOk os registros - não marcados; não estiver encontrado
		dbSelectArea(cAliasTRB)
		dbSetOrder(1)
		If !dbSeek(aColsOK[nCols,nPosCod]) .OR. Empty((cAliasTRB)->TJK_OK)
			aDel(aColsOk,nCols)
			aSize(aColsOk,Len(aColsOk)-1)
		EndIf
	Next nCols

	dbSelectArea(cAliasTRB)
	dbGoTop()
	While (cAliasTRB)->(!Eof())
		If !Empty((cAliasTRB)->TJK_OK) .AND. aScan( aColsOk , {|x| x[nPosCod] == (cAliasTRB)->TJK_CODPLA } ) == 0
			aAdd(aColsOk,aClone(aColsTp[1]))
			aColsOk[Len(aColsOk),nPosCod] := (cAliasTRB)->TJK_CODPLA
			aColsOk[Len(aColsOk),nPosDes] := (cAliasTRB)->TJK_DESPLA
		EndIf
		(cAliasTRB)->(dbSkip())
	End

	If Len(aColsOK) <= 0
		aColsOK := aClone(aColsTp)
	EndIf

	aSort(aColsOK,,,{ |x, y| x[1] < y[1] }) //Ordena por plano
	oGetPE:aCols := aClone(aColsOK)
	oGetPE:oBrowse:Refresh()

Else

	aColsOkMDT := aClone(oMDT:aCols)
	aColsOkSGA := aClone(oSGA:aCols)

	aHeadOk := aClone(oMDT:aHeader)
	aColsTp := BLANKGETD(aHeadOk)

	nPosCod := aScan( aHeadOk,{|x| Trim(Upper(x[2])) == "TJG_CODPLA"})
	nPosDes := aScan( aHeadOk,{|x| Trim(Upper(x[2])) == "TJG_DESPLA"})

	//Deleta do aColsOk os registros - não marcados; não estiver encontrado
	For nCols := Len(aColsOkMDT) To 1 Step -1
		dbSelectArea(cAliasTRB)
		dbSetOrder(1)
		If !dbSeek(aColsOKMDT[nCols,nPosCod]) .OR. Empty((cAliasTRB)->TJK_OK)
			aDel(aColsOkMDT,nCols)
			aSize(aColsOkMDT,Len(aColsOkMDT)-1)
		EndIf
	Next nCols


	For nCols := Len(aColsOkSGA) To 1 Step -1
		dbSelectArea(cAliasTRB)
		dbSetOrder(1)
		If !dbSeek(aColsOKSGA[nCols,nPosCod]) .OR. Empty((cAliasTRB)->TJK_OK)
			aDel(aColsOkSGA,nCols)
			aSize(aColsOkSGA,Len(aColsOkSGA)-1)
		EndIf
	Next nCols


	//copia as novas marcacoes
	dbSelectArea(cAliasTRB)
	dbGoTop()
	While (cAliasTRB)->(!Eof())
		If !Empty((cAliasTRB)->TJK_OK) .AND. (cAliasTRB)->TJK_MODULO == "MDT" .AND. aScan( aColsOkMDT , {|x| x[nPosCod] == (cAliasTRB)->TJK_CODPLA } ) == 0
			aAdd(aColsOkMDT,aClone(aColsTp[1]))
			aColsOkMDT[Len(aColsOkMDT),nPosCod] := (cAliasTRB)->TJK_CODPLA
			aColsOkMDT[Len(aColsOkMDT),nPosDes] := (cAliasTRB)->TJK_DESPLA
		ElseIF!Empty((cAliasTRB)->TJK_OK) .AND. (cAliasTRB)->TJK_MODULO == "SGA" .AND. aScan( aColsOkSGA , {|x| x[nPosCod] == (cAliasTRB)->TJK_CODPLA } ) == 0
			aAdd(aColsOkSGA,aClone(aColsTp[1]))
			aColsOkSGA[Len(aColsOkSGA),nPosCod] := (cAliasTRB)->TJK_CODPLA
			aColsOkSGA[Len(aColsOkSGA),nPosDes] := (cAliasTRB)->TJK_DESPLA
		Endif
		(cAliasTRB)->(dbSkip())
	End



	If Len(aColsOKMDT) <= 0
		aColsOKMDT := aClone(aColsTp)
	EndIf
	If Len(aColsOKSGA) <= 0
		aColsOKSGA := aClone(aColsTp)
	EndIf


	aSort(aColsOKMDT,,,{ |x, y| x[1] < y[1] }) //Ordena por plano
	aSort(aColsOKSGA,,,{ |x, y| x[1] < y[1] }) //Ordena por plano
	oMDT:aCols := aClone(aColsOKMDT)
	oSGA:aCols := aClone(aColsOKSGA)
	oMDT:oBrowse:Refresh()
	oSGA:oBrowse:Refresh()

Endif


Return .T.
/*/
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³ Fun‡…o   ³MDTA212INV³ Autor ³Guiherme Benkendorf    ³ Data ³ 27/12/12 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Descri‡…o³ Inverte a marcacao do browse                               ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
/*/
Static Function MDTA212INV(cMarca,cAliasTRB)
Local aArea := GetArea()

dbSelectArea(cAliasTRB)
dbGoTop()
While !(cAliasTRB)->(Eof())
	(cAliasTRB)->TJK_OK := IF(Empty((cAliasTRB)->TJK_OK),cMARCA," ")
	(cAliasTRB)->(dbskip())
End

RestArea(aArea)
Return .T.
/*/
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³ Fun‡…o   ³fGravaPE  ³ Autor ³Guilherme Benkendorf   ³ Data ³ 21/12/12 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Descri‡…o³ Funcao para gravar dados da MsNewGetDados,    			  ³±±
±±³ 		 ³ Plano Emergenciais na TJG								  ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
/*/
Static Function fGravaPE( oObjeto )

Local aArea := GetArea()
Local i, j, ny, nPosCod
Local nOrd, cKey, cWhile
Local aColsOk := {}
Local aHeadOk := {}

If !NGCADICBASE("TBB_MODULO","A","TBB",.F.)
	aColsOk := aClone(oObjeto:aCols)
	aHeadOk := aClone(oObjeto:aHeader)

else
	aHeadOk := aClone(oMDT:aHeader)
	aColsOk := aClone(oMDT:aCols)

	For i := 1 to len(oSGA:aCols)

		AADD(aColsOk,oSGA:aCols[I])

	Next i

Endif


nPosCod := aScan( aHeadOk,{|x| Trim(Upper(x[2])) == "TJG_CODPLA"})
nOrd 	:= 1
cKey 	:= xFilial("TJG")+TO0->TO0_LAUDO
cWhile  := "xFilial('TJG')+TO0->TO0_LAUDO == TJG->TJG_FILIAL+TJG->TJG_LAUDO"

If Len(aColsOK) > 0
	//Coloca os deletados por primeiro
	aSORT(aColsOK,,, { |x, y| x[Len(aColsOK[1])] .and. !y[Len(aColsOK[1])] } )

	For i:=1 to Len(aColsOK)
		If !aColsOK[i][Len(aColsOK[i])] .and. !Empty(aColsOK[i][nPosCod])
			dbSelectArea("TJG")
			dbSetOrder(nOrd)
			If dbSeek(cKey+aColsOK[i][nPosCod])
				RecLock("TJG",.F.)
			Else
				RecLock("TJG",.T.)
			Endif
			For j:=1 to FCount()
				If "_FILIAL"$Upper(FieldName(j))
					FieldPut(j, xFilial("TJG"))
				ElseIf "_LAUDO"$Upper(FieldName(j))
					FieldPut(j, TO0->TO0_LAUDO)
				ElseIf "_CLIENT"$Upper(FieldName(j))
					FieldPut(j, SA1->A1_COD)
				ElseIf "_LOJA"$Upper(FieldName(j))
					FieldPut(j, SA1->A1_LOJA)
				ElseIf (nPos := aScan(aHeadOk, {|x| Trim(Upper(x[2])) == Trim(Upper(FieldName(j))) }) ) > 0
					FieldPut(j, aColsOK[i,nPos])
				Endif
			Next j
			MsUnlock("TJG")
		Elseif !Empty(aColsOK[i][nPosCod])
			dbSelectArea("TJG")
			dbSetOrder(nOrd)
			If dbSeek(cKey+aColsOK[i][nPosCod])
				RecLock("TJG",.F.)
				dbDelete()
				MsUnlock("TJG")
			Endif
		Endif
	Next i
Endif
dbSelectArea("TJG")
dbSetOrder(nOrd)
dbSeek(cKey)
While !Eof() .and. &(cWhile)
	If aScan( aColsOK,{|x| x[nPosCod] == TJG->TJG_CODPLA .AND. !x[Len(x)]}) == 0
		RecLock("TJG",.f.)
		DbDelete()
		MsUnLock("TJG")
	Endif
	dbSelectArea("TJG")
	dbSkip()
End

RestArea(aArea)

Return .T.
/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³MDT212Lin ³ Autor ³Guilherme Benkendorf   ³ Data ³ 21/12/12 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Valida linhas do MsNewGetDados dos Planos Emergenciais	  ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function MDT212Lin(cAlias,lFim,oObjeto)
Local f
Local aColsOk := {}, aHeadOk := {}
Local nPosCod := 1, nAt := 1
Local nCols, nHead
Default lFim := .F.

aColsOk := aClone(oObjeto:aCols)
aHeadOk := aClone(oObjeto:aHeader)
nAt     := oObjeto:nAt

If cAlias == "TJG"
	nPosCod := aScan( aHeadOk,{|x| Trim(Upper(x[2])) == "TJG_CODPLA"})
	If lFim
		If Len(aColsOk) == 1 .AND. Empty(aColsOk[1][nPosCod])
			Return .T.
		EndIf
	EndIf
EndIf

//Percorre aCols
For f:= 1 to Len(aColsOk)
	If !aColsOk[f][Len(aColsOk[f])]
		If lFim .or. f == nAt
			//VerIfica se os campos obrigatórios estão preenchidos
			If Empty(aColsOk[f][nPosCod])
				//Mostra mensagem de Help
				Help(1," ","OBRIGAT2",,aHeadOk[nPosCod][1],3,0)
				Return .F.
			Endif
		Endif
		//Verifica se é somente LinhaOk
		If f <> nAt .and. !aColsOk[nAt][Len(aColsOk[nAt])]
			If aColsOk[f][nPosCod] == aColsOk[nAt][nPosCod]
				Help(" ",1,"JAEXISTINF",,aHeadOk[nPosCod][1])
				Return .F.
			Endif
		Endif
	Endif
Next f

PutFileInEof("TJG")

Return .T.
/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³MDT212TOk ³ Autor ³Guilherme Benkendorf   ³ Data ³ 21/12/12 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Função para verificar toda a MsNewGetdados				  ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function MDT212TOk(oObjeto)

If NGCADICBASE("TBB_MODULO","A","TBB",.F.)
	Return .T.
Endif

If !MDT212Lin("TJG",.T.,@oObjeto)
	Return .F.
Endif

Return .T.
/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³fBuscaPlano Autor ³Guilherme Benkendorf   ³ Data ³ 21/12/12 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Funcao para retornar todos os planos emergenciais		  ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Static Function fBuscaPlano( cAliasTRB , oGetPE )
Local nPosCod := 1
Local aArea   := GetArea()
Local aColsOK := {} , aColsOKMDT := {}, aColsOKSGA
Local aHeadOk := {}


IF !NGCADICBASE("TBB_MODULO","A","TBB",.F.)
	aColsOK := aClone(oGetPE:aCols)
	aHeadOk := aClone(oGetPE:aHeader)

	nPosCod := aScan( aHeadOk,{|x| Trim(Upper(x[2])) == "TJG_CODPLA"})

	dbSelectArea("TJK")
	dbSetOrder(1)
	If dbSeek(xFilial("TJK"))
		While TJK->(!Eof()) .AND. TJK->TJK_FILIAL == xFilial("TJK")
			RecLock(cAliasTRB,.T.)
			(cAliasTRB)->TJK_OK     := If( aScan( aColsOk , {|x| x[nPosCod] == TJK->TJK_CODPLA } ) > 0, cMarca , " " )
			(cAliasTRB)->TJK_CODPLA := TJK->TJK_CODPLA
			(cAliasTRB)->TJK_DESPLA := TJK->TJK_DESPLA
			(cAliasTRB)->(MsUnLock())
			TJK->(dbSkip())
		End
	EndIf

Else

	aColsOKMDT := aClone(oMDT:aCols)
	aColsOKSGA := aClone(oSGA:aCols)

	aHeadOk := aClone(oMDT:aHeader)

	nPosCod := aScan( aHeadOk,{|x| Trim(Upper(x[2])) == "TJG_CODPLA"})

	dbSelectArea("TBB")
	dbSetOrder(1)
	If dbSeek(xFilial("TBB"))
		While TBB->(!Eof()) .AND. TBB->TBB_FILIAL == xFilial("TBB")
			RecLock(cAliasTRB,.T.)
			(cAliasTRB)->TJK_OK     := If( aScan( aColsOkMDT , {|x| x[nPosCod] == TBB->TBB_CODPLA } ) > 0, cMarca , If( aScan( aColsOkSGA , {|x| x[nPosCod] == TBB->TBB_CODPLA } ) > 0, cMarca , " " ) )
			(cAliasTRB)->TJK_CODPLA := TBB->TBB_CODPLA
			(cAliasTRB)->TJK_DESPLA := TBB->TBB_DESPLA
			(cAliasTRB)->TJK_MODULO := IF (TBB->TBB_MODULO == "2" ,"MDT","SGA")
			(cAliasTRB)->(MsUnLock())
			TBB->(dbSkip())
		End
	EndIf


Endif


RestArea(aArea)
Return
//---------------------------------------------------------------------
/*/{Protheus.doc} fTRBPes
Funcao de Pesquisar no Browse.

@samples fTRBPes()

@return Sempre verdadeiro

@param cAliasTRB1	- Alias do MarkBrowse ( Obrigatório )
@param oMark 		- Objeto do MarkBrowse ( Obrigatório )

@author Guilherme Freudenburg
@since 05/03/2014
/*/
//---------------------------------------------------------------------
Static Function fTRBPes(cAliasTRB , oMark , cPesquisar )

	Local nRecNoAtu := 1//Variavel para salvar o recno
	Local lRet		:= .T.

	//Posiciona no TRB e salva o recno
	dbSelectArea( cAliasTRB )
	nRecNoAtu := RecNo()

	dbSelectArea( cAliasTRB )
	If dbSeek( AllTrim( cPesquisar ) )
		//Caso exista a pesquisa, posiciona
		oMark:oBrowse:SetFocus()
	Else
		//Caso nao exista, retorna ao primeiro recno e exibe mensagem
		dbGoTo( nRecNoAtu )
		ApMsgInfo( STR0023 , STR0022 ) //"Valor não encontrado."###"Atenção"
		oPesquisar:SetFocus()
		lRet := .F.
	EndIf

	// Atualiza markbrowse
	oMark:oBrowse:Refresh(.T.)

Return lRet

//---------------------------------------------------------------------
/*/{Protheus.doc} fIndexSet
Seta o indice para pesquisa.

@return

@param cAliasTRB	- Alias do TRB ( Obrigatório )
@param aCbxPesq	- Indices de pesquisa do markbrowse. ( Obrigatório )
@param cPesquisar	- Valor da Pesquisa ( Obrigatório )
@param oMark		- Objeto do MarkBrowse ( Obrigatório )

@author Guilherme Freudenburg
@since 05/03/2014
/*/
//---------------------------------------------------------------------
Static Function fIndexSet( cAliasTRB , aCbxPesq , cPesquisar , oMark )

	Local nIndice := fIndComb( aCbxPesq ) // Retorna numero do indice selecionado

	// Efetua ordenacao do alias do markbrowse, conforme indice selecionado
	dbSelectArea( cAliasTRB )
	dbSetOrder( nIndice )
	dbGoTop()

	// Se o indice selecionado for o ultimo [Marcados]
	If nIndice == Len( aCbxPesq )
		cPesquisar := Space( Len( cPesquisar ) ) // Limpa campo de pesquisa
		oPesquisar:Disable()              // Desabilita campo de pesquisa
		oBtnPesq:Disable()              // Desabilita botao de pesquisa
		oMark:oBrowse:SetFocus()     // Define foco no markbrowse
	Else
		oPesquisar:Enable()               // Habilita campo de pesquisa
		oBtnPesq:Enable()               // Habilita botao de pesquisa
		oBtnPesq:SetFocus()             // Define foco no campo de pesquisa
	Endif

	oMark:oBrowse:Refresh()

Return

//---------------------------------------------------------------------
/*/{Protheus.doc} fIndComb
Retorna o indice, em numero, do item selecionado no combobox

@return nIndice - Retorna o valor do Indice

@param aIndMrk - Indices de pesquisa do markbrowse. ( Obrigatório )

@author Guilherme Freudenburg
@since 05/03/2014
/*/
//---------------------------------------------------------------------
Static Function fIndComb( aIndMrk )

	Local nIndice := aScan( aIndMrk , { | x | AllTrim( x ) == AllTrim( cCbxPesq ) } )

	// Se o indice nao foi encontrado nos indices pre-definidos, apresenta mensagem
	If nIndice == 0
		ShowHelpDlg( STR0022 ,	{ STR0024 } , 1 , ; //"Atenção"###"Índice não encontrado."
									{ STR0025 } , 1 ) //"Contate o administrador do sistema."
		nIndice := 1
	Endif

Return nIndice