#INCLUDE "MNTA095.CH"
#INCLUDE "PROTHEUS.CH"
#INCLUDE "DBTREE.CH"

Static lRel12133 := GetRPORelease() >= '12.1.033'

//---------------------------------------------------------------------
/*/{Protheus.doc} MNTA095
Estrutura de Familia de bens

@return Vazio.

@author
@since
/*/
//---------------------------------------------------------------------
Function MNTA095()

	Local nORDER
	Local nRECNO
	Local nX
	Local aOldMenu    := {}
	Local aNGBEGINPRM := {}
	Local aIndSTC     := {}
	Local aPesq 	  := {}
	Local aDescr      := {}
	Local oTmpTbl1

	If !FindFunction( 'MNTAmIIn' ) .Or. MNTAmIIn( 19, 95 )

		aOldMenu    := IIf( Type("asMenu") == "A", ACLONE( asMenu ), {} )
		aNGBEGINPRM := NGBEGINPRM()

		Private cAliasSTC := GetNextAlias() //Seleciona novo alias para o TRB
		Private aDBFSTC   := {} 		    //Define os campos do TRB

		Private cPrograma := "MNTA095"
		Private aGETS     := {}
		Private cCadastro := OemToAnsi(STR0001) //"Estrutura PadrÆo"
		Private aRotina   := MenuDef()
		Private lTpModAlt := .F. //identifica que já havia bem padrao cadastrado antes de integrar com o frota e na alteração do registro chega a chave antiga

		Private lGFrota   := NGVERUTFR()
		Private lStatus   := NGCADICBASE('T9_STATUS','A','ST9',.f.)
		Private lSequeSTC := NGCADICBASE( "TC_SEQUEN","A","STC",.F. ) //Verifica se existe o campo TC_SEQUEN no dicionário ou base dados.
		Private lTipMod   := lRel12133 .Or. lGFrota

		Private aFIELD := {}
		Private aDBF := {}
		Private aOrdStruct := {}

		aIndSTC     := fRetIndex( 1 ) //Retorna os indices do TRB

		M->TC_TIPOEST := "F"

		//|------------------------------------------------------|
		//| Salva area de trabalho.                              |
		//|------------------------------------------------------|
		cOODALIAS := Alias()
		nORDER    := IndexOrd()
		nRECNO    := Recno()

		//|-----------------------------------------|
		//| Montagem do mBrowse                     |
		//|-----------------------------------------|
		dbSelectArea("STC")
		If(lTipMod,dbSetOrder(05),dbSetOrder(01))

		//Define os campos que irao aparecer no mBrowse, como se utilizado um Alias de TRB, deve-se definir o tipo, tamanho, decimal e picture tambem
		aAdd(aFIELD,{ STR0049 , "TC_FILIAL" , "C" , If( FindFunction( "FwSizeFilial" ) , FwSizeFilial() , 2 ) , 0 , "@!" }) //"Filial"
		aAdd(aFIELD,{ STR0007 , "TC_CODBEM" , "C" , 16                                                         , 0 , "@!" }) //"Familia"
		aAdd(aFIELD,{ STR0008 , "TC_NOME"   , "C" , 40                                                         , 0 , "@!" }) //"Nome"

		If lTipMod//Caso tiver ambiente frota, adiciona tipo modelo ao browse
			aAdd( aFIELD , { STR0047 , "TC_TIPMOD"  , "C" , 10 , 0 , "@!" })//"Tipo Modelo"
			aAdd( aFIELD , { STR0008 , "TQR_DESMOD" , "C" , 20 , 0 , "@!" })//"Nome"
		EndIf

		//Monta o DBF do TRB
		aDBFSTC   := {{ "TC_FILIAL" , "C" , If( FindFunction( "FwSizeFilial" ) , FwSizeFilial() , 2 )  , 0 } , ;
					{ "TC_CODBEM" , "C" , 16                                                         , 0 } , ;
					{ "TC_NOME"   , "C" , 40                                                         , 0 }}

		If lTipMod//Caso tiver ambiente frota, adiciona os campos de tipo modelo no DBF
			aAdd( aDBFSTC , { "TC_TIPMOD"  , "C" , 10 , 0 } )
			aAdd( aDBFSTC , { "TQR_DESMOD" , "C" , 20 , 0 } )
		EndIf

		//Monta arquivo de trabalho
		oTmpTbl1  := FWTemporaryTable():New( cAliasSTC, aDBFSTC )
		For nX := 1 To Len(aIndSTC)
			oTmpTbl1:AddIndex( "Ind"+StrZero(nX,2) ,  aIndSTC[nX]  )
		Next nX
		oTmpTbl1:Create()

		MNT95MTTRB()//Chama funcao para alimentar o TRB

		//Posiciona no TRB para abrir o Browse
		dbSelectArea(cAliasSTC)
		dbSeek( xFilial("STC"))
		aDescr := fRetIndex(2)
		//MBROWSE( 6 , 1 , 22 , 75 , ( cAliasSTC ) , aFIELD )//Passa o aFields para definir os campos que irao aparecer no Browse

		//Cria Array para montar a chave de pesquisa
		For nX := 1 To Len(aDescr)
			aAdd( aPesq , {aDescr[nX] , {{"","C" , 255 , 0 ,"","@!"} }} )
		Next nX

		oBrowse:= FWMBrowse():New()
		oBrowse:SetDescription(cCadastro)
		oBrowse:SetTemporary(.T.)
		oBrowse:SetAlias(cAliasSTC)
		oBrowse:SetFields(aFIELD)
		oBrowse:SetProfileID('1')
		oBrowse:SetSeek(.T.,aPesq)
		oBrowse:Activate()

		oTmpTbl1:Delete()

		Set Key VK_F9 To
		DbselectArea("STC")
		DbsetOrder(1)
		Set Filter To
		DbsetOrder(1)
		Dbseek(xFILIAL('STC'))

		//|------------------------------------------------------------|
		//| Devolve variaveis armazenadas (NGRIGHTCLICK)               |
		//|------------------------------------------------------------|
		asMenu  := ACLONE(aOldMenu)
		NGRETURNPRM(aNGBEGINPRM)

	EndIf

Return NIL

//---------------------------------------------------------------------
/*/{Protheus.doc} NG095PROCES
Programa de Processamento de Estrutura

@return Vazio.

@param cALIAS, Caracter, Alias da tabela utilizada.
@param nRECNO, Numérico, Recno do registro.
@param nOPC  , Caracter, Opção utilizada.

@author Paulo Pego
@since 28/05/98
/*/
//---------------------------------------------------------------------
Function NG095PROCES(cALIAS,nRECNO,nOPC)

	Local lRET, cSequen, I := 0
	Local oTmpTbl2
	Local nIndexTRB // Variavel que guarda o indice do TRB
	Local aSUB := {OemToAnsi(STR0010),; // "Pesquisa"
				   OemToAnsi(STR0011),; // "Visualização"
				   OemToAnsi(STR0012),; // "Inclusão"
				   OemToAnsi(STR0013),; // "Alteração"
				   OemToAnsi(STR0014)}  // "Exclusão"

	Local cOldFiltro := STC->(dbFilter())
	dbSelectArea("STC")
	Set Filter To STC->TC_FILIAL = xFilial('STC') .And. TC_TIPOEST = 'F'

	If Type("lGFrota") <> "U"
		Private lGFrota := NGVERUTFR()
	EndIf

	If Type("lTipMod") <> "U"
		Private lTipMod := lRel12133 .Or. lGFrota
	EndIf

	If IsInCallStack("MNTA095")
		If lTipMod
			dbSetOrder(05)
			dbSeek(xFilial("STC")+(cALIAS)->TC_CODBEM+(cALIAS)->TC_TIPMOD)
		Else
			dbSetOrder(01)
			dbSeek(xFilial("STC")+(cALIAS)->TC_CODBEM)
		EndIf
	EndIf

	Private oTREE, cCOMP, nFECHA := 0, lTRB := .F.
	Private cFIRST := STC->TC_CODBEM, cSEQ := STC->TC_SEQRELA
	Private cALI, cRET, nNIVEL
	Private nINIC := STC->(Recno())
	Private cPAI   := STC->TC_CODBEM
	Private nOPCAO := nOPC
	Private bCARGO,bcSEQ
	Private oDLG95,oMenu
	Private oBtn1, oBtn3, oBtn4, oBtn5, oBtn6, oBtn7
	Private cNextSeq

	Private oDesMod
	Private cDesMod := ''
	Private oDESC, cDESC := Space(40)
	Private cNGTIPMOD := If(lTipMod,STC->TC_TIPMOD," ")
	Private aNewSeq   := {} //armazena todas as novas sequencias a serem utilizadas na rotina
	Private cPAD 	  := GetNextAlias()

	bCARGO := {|| SUBSTR(oTREE:GETCARGO(),1,16)}
	bcSEQ  := {|| SUBSTR(oTREE:GETCARGO(),17,5)}
	cSEQ   := Space(Len(stc->tc_seqrela))

	cTITULO := STR0015+aSUB[nOPC] //"Cadastro de Estrutura Padrao "

	If lTipMod .And. nOPC != 3
		dbSelectArea("TQR")
		dbSetOrder(1)
		If dbSeek(xFilial("TQR") + cNGTIPMOD)
			cDesMod := TQR->TQR_DESMOD
		ElseIf Trim(cNGTIPMOD) == '*'
			cDesMod := STR0055 // "TODOS"
		EndIf
	EndIf

	dbSelectArea("ST6")
	dbSetOrder(1)
	If dbSeek(xFilial("ST6") + RTrim( cFIRST ) ) .And. (nOPC!= 3)
		cDESC := ST6->T6_NOME
	EndIf

	//|------------------------------------------|
	//|Cria Arquivo de Trabalho                  |
	//|------------------------------------------|
	dbSelectArea("STC")
	aDBF := STC->(DbStruct())
	//Intancia classe FWTemporaryTable
	oTmpTbl2  := FWTemporaryTable():New( cPAD, aDBF )
	//Cria indices
	oTmpTbl2:AddIndex( "Ind01" , {"TC_CODBEM" ,"TC_COMPONE","TC_LOCALIZ"} )
	oTmpTbl2:AddIndex( "Ind02" , {"TC_COMPONE","TC_CODBEM","TC_SEQRELA" } )
	oTmpTbl2:AddIndex( "Ind03" , {"TC_COMPONE","TC_SEQRELA"} )
	oTmpTbl2:AddIndex( "Ind04" , {"TC_COMPONE","TC_LOCALIZ"} )
	oTmpTbl2:AddIndex( "Ind05" , {"TC_SEQRELA"			   } )
	oTmpTbl2:AddIndex( "Ind06" , {"TC_SEQSUP" ,"TC_SEQRELA"} )
	//Cria a tabela temporaria
	oTmpTbl2:Create()

	If nOPC == 3
		lTRB      := .F.
		cFIRST    := Space(16)
		cPAI      := Space(Len(ST6->T6_CODFAMI))
		cNGTIPMOD := Space(10)
	Else
		dbSelectArea("STC")
		If lTipMod
			dbSetOrder(5)
			dbSeek(xFilial("STC")+cPAI+cNGTIPMOD)
			While !Eof() .And. STC->TC_FILIAL == xFilial("STC") .And.;
			STC->TC_CODBEM == cPAI .AND. STC->TC_TIPMOD == cNGTIPMOD

				If Empty(STC->TC_SEQSUP)
					aArea  := STC->(GetArea())
					cBEMP  := STC->TC_CODBEM
					cCOMP  := STC->TC_COMPONE
					nNIVEL := STC->TC_SEQRELA
					lTRB   := .T.
					cKey   := STC->TC_CODBEM + STC->TC_COMPONE + STC->TC_SEQRELA

					dbSelectArea(cPAD)
					dbSetOrder(01)
					If !(cPAD)->(dbSeek(cKey))
						dbSelectArea(cPAD)
						RecLock((cPad),.T.)
						For i := 1 To Fcount()
							cFIEL1   := "(cPAD)->" + STC->(FIELDNAME(i))
							cFIEL2   := "STC->" + STC->(FIELDNAME(i))
							&cFIEL1. := &cFIEL2.
						Next i
						MsunLock(cPAD)

						cSequen := STC->TC_SEQRELA
						dbSelectArea("STC")
						dbSetOrder(7)
						If dbSeek(xFilial('STC')+cSequen)
							NGMARTRB095(cSequen)
						EndIf
					EndIf
					RestArea(aArea)
				EndIf

				STC->(dbSkip())
			End
		Else
			dbsetOrder(1)
			dbseek(xFilial("STC")+cPAI)
			While !Eof() .And. STC->TC_FILIAL == xFILIAL("STC") .And.;
			STC->TC_CODBEM == cPAI

				aArea  := STC->(GetArea())
				cBEMP  := STC->TC_CODBEM
				cCOMP  := STC->TC_COMPONE
				nNIVEL := STC->TC_SEQRELA
				lTRB   := .T.
				cKey   := STC->TC_CODBEM + STC->TC_COMPONE + STC->TC_SEQRELA

				dbSelectArea(cPAD)
				dbSetOrder(01)
				If !(cPAD)->(Dbseek(cKey))
					dbSelectArea(cPAD)
					RecLock((cPad),.T.)
					For i := 1 To Fcount()
						cFIEL1   := "(cPAD)->" + STC->(FIELDNAME(i))
						cFIEL2   := "STC->" + STC->(FIELDNAME(i))
						&cFIEL1. := &cFIEL2.
					Next i
					MsunLock(cPAD)

					cSequen := STC->TC_SEQRELA

					If lSequeSTC //Verifica se existe o campo TC_SEQUEN no dicionário ou base dados.
						(cPAD)->TC_SEQUEN := STC->TC_SEQUEN
						Mnt090AdFi( STC->TC_CODBEM,STC->TC_COMPONE,STC->TC_SEQUEN ) //Adiciona filhos no array para controle da árvore ordenada
					EndIf

					dbSelectArea("STC")
					dbSetOrder(7)
					If dbSeek(xFilial('STC')+cSequen)
						NGMARTRB095(cSequen)
					EndIf
				EndIf
				RestArea(aArea)
				dbSkip()
			End
		EndIf
	EndIf

	lRET  := .F.
	cLOC1 := " "
	cLOC2 := " "
	cLOC3 := " "
	lTREE := .F.

	ST6->(dbSeek(xFilial("ST6")))
	DEFINE FONT NgFont NAME "Courier New" SIZE 6, 0

	DEFINE MSDIALOG oDLG95 FROM  06,6 To 339,537 TITLE cTITULO PIXEL

	bCLICK := {|| CLICH95() }
	bMOVE := {|| MNT095MOVE(EVAL(bCARGO),EVAL(bcSEQ))}
	lOPT := (nOPC == 3)
	lOPTMod := (nOPC == 3)
	If Empty(cNGTIPMOD) .And. (nOPC == 4)
		lOPTMod := .t.
		lTpModAlt := .t.
	EndIf

	@ 09,008 SAY OemToAnsi(STR0016) SIZE 37,7 OF oDLG95 PIXEL //"Codigo:"
	lTemTPM := .F.
	If lTipMod
		lTemTPM := .T.
		@ 07,035 MSGET cPAI  SIZE 48, 08 OF oDLG95 PIXEL When (lopt) VALID ChkPai(cPai) Picture "@!" F3 "ST6" HASBUTTON
		@ 07,100 MSGET oDESC VAR cDESC SIZE 160,08 OF oDLG95 PIXEL When .F.
		@ 25,008 SAY OemToAnsi(STR0045) SIZE 37,7 OF oDLG95 PIXEL  //Modelo:
		@ 23,035 MSGET cNGTIPMOD  SIZE 48, 08 OF oDLG95 PIXEL When (loptMod) VALID ChkMod(cNGTIPMOD) .And. CHKPAI95(cPAI) Picture "@!" F3 "TQR" HASBUTTON
		@ 23,100 MSGET oDesMod VAR cDesMod SIZE 160,08 OF oDLG95 PIXEL When .F.
	Else
		@ 07,035 MSGET cPAI  SIZE 48, 08 OF oDLG95 PIXEL When (lopt) VALID ChkPai(cPai) .And. CHKPAI95(cPAI) F3 "ST6" HASBUTTON
		@ 07,100 MSGET oDESC VAR cDESC SIZE 160,08 OF oDLG95 PIXEL When .F.
	EndIf

	@ 155,02 SAY OLOC951 VAR cLOC1 SIZE 048, 08 OF oDLG95 PIXEL
	@ 155,36 SAY oLOC952 VAR cLOC2 SIZE 048, 08 OF oDLG95 PIXEL
	@ 155,90 SAY oLOC953 VAR cLOC3 SIZE 348, 08 OF oDLG95 PIXEL

	If STR(nOPC,1) $ "2"
		oBtn1 := sButton():New(137, 138, 15, {||NGINFILH095(2)}, oDlg95, .F., Nil, Nil)  //visualizar
		oBtn6 := sButton():New(137, 196, 01, {||lRET := .T.,oDLG95:END()}, oDlg95, .T., Nil, Nil)  //ok
	ElseIf STR(nOPC,1) $ "3/4"
		oBtn3 := sButton():New(137, 109, 04, {||NGINFILH095(3)}, oDlg95, (nOpc == 4), Nil, Nil)  //incluir
		oBtn4 := sButton():New(137, 138, 11, {||NGINFILH095(4)}, oDlg95, .F., Nil, Nil)  //editar
		oBtn5 := sButton():New(137, 167, 03, {||NGINFILH095(5)}, oDlg95, .F., Nil, Nil)  //excluir
		oBtn6 := sButton():New(137, 196, 01, {||If(CHKPAD95(cPAI),EVAL({|| lRET := .T.,oDLG95:END()}), lRET := .F.)}, oDlg95, .T., Nil, Nil)  //ok
	ElseIf nOPC == 5
		oBtn6 := sButton():New(137, 196, 01, {||lRET := .T.,oDLG95:END()}, oDlg95, .T., Nil, Nil)  //ok
	EndIf

	oBtn7 := sButton():New(137, 225, 02, {||oDLG95:END()}, oDlg95, .T., Nil, Nil)  //cancelar

	//|------------------------------------------------|
	//| Realiza a montagem da estrutura oTree          |
	//|------------------------------------------------|
	GENTREE95()

	If IsInCallStack("MNTA095")
		NGPOPUP(asMenu,@oMenu)
		oDlg95:bRClicked:= { |o,x,y| oMenu:Activate(x,y,oDlg95)}
	EndIf

	If lTipMod
		ACTIVATE MSDIALOG oDLG95 VALID NaoVazio(cNGTIPMOD) .And. !fTreeVazia() CENTERED
	Else
		ACTIVATE MSDIALOG oDLG95 VALID NaoVazio(cPAI) .And. !fTreeVazia() CENTERED
	EndIf

	If STR(nOPC,1) $ "5"
		dbSelectArea(cPAD)
		dbGoTop()
		While (cPAD)->(!Eof())
			RecLock((cPad),.F.)
			dbDelete()
			MsUnLock(cPAD)
			(cPAD)->(dbSkip())
		EndDo
	EndIf

	//|-------------------------------------------------------------|
	//| Atualiza arquivo STC com alteracoes realizadas na rotina    |
	//|-------------------------------------------------------------|
	If lRET
		NGATUES95()
	EndIf

	oTmpTbl2:Delete()

	DbselectArea("STC")
	Set Filter To &(cOldFiltro)
	If IsInCallStack("MNTA095")
		If(lTipMod,dbSetOrder(05),dbSetOrder(01))
		If nOPC == 5
			dbSeek(xFilial("STC"))
		Else
			dbGoTo(nINIC)
		Endif

		nIndexTRB := fPesqIndex()//Salva o indice atual do TRB
		//Caso chamado via MNTA095, chama funcao para refazer os itens do Browse, pois podem ter sido alterados
		MNT95MTTRB( If( nIndexTRB == 1 , ;
		STC->TC_FILIAL + STC->TC_CODBEM + If( lTipMod , STC->TC_TIPMOD , "" ) , ;
		STC->TC_FILIAL + If( lTipMod , STC->TC_TIPMOD , "" ) + STC->TC_CODBEM ) , ;
		nIndexTRB )
	EndIf

Return Nil

//---------------------------------------------------------------------
/*/{Protheus.doc} GENTREE95
CRIA O OBJETO oTREE QUE GERENCIA OS NIVEIS

@return Vazio.

@author Paulo Pego
@since 28/05/98
/*/
//---------------------------------------------------------------------
Function GENTREE95()

	Local oMenu
	Local cDESC	:= Space(40)
	Local aItens	:= {}
	Local nI		:= 0

	lTRB := .F.

	If lTREE
		oTREE:END()
		lTREE := .F.
	EndIf

	oTREE := dbTree():New(045,012,132,252,oDLG95,{|| MNT095MOVE(EVAL(bCARGO),EVAL(bcSEQ))},,.T.)

	NGPOPUP(asMenu,@oMenu)
	oTree:bRClicked:= { |o,x,y| oMenu:Activate(x-390,y-450,oTree)}

	dbSelectArea("ST6")
	dbSetOrder(01)
	If dbSeek(xFILIAL("ST6")+ RTrim( cFIRST) ) .And. !Empty(cFIRST)
		cDESC := ST6->T6_NOME
	EndIf

	dbSelectArea(cPAD)
	dbSetOrder(1)
	lTRB := dbSeek(cFIRST)
	cSEQ := (cPAD)->TC_SEQRELA
	cLOC := (cPAD)->TC_LOCALIZ

	If lTRB
		cPRODESC := cFIRST+' - '+cDESC
		DBADDTREE oTREE PROMPT cPRODESC OPENED RESOURCE "FOLDER5", "FOLDER6" CARGO cFIRST+cSEQ+cLOC

		If lSequeSTC //Verifica se existe o campo TC_SEQUEN no dicionário ou base dados.

			While !EoF() .And. Alltrim((cPAD)->TC_CODBEM) == Alltrim(cFIRST)

				nREC		:= RECNO()
				cCOMP		:= (cPAD)->TC_COMPONE
				cITEM		:= IF(ST6->(dbSeek(xFILIAL("ST6") + RTrim( cCOMP ) )),ST6->T6_NOME," ")
				cSEQ		:= (cPAD)->TC_SEQRELA
				cLOC		:= (cPAD)->TC_LOCALIZ
				cPRODESC	:= If(!Empty(cLOC),cCOMP+' - '+Alltrim(cITEM)+' - '+cLOC,cCOMP+' - '+cITEM)

				aAdd( aItens,{ cCOMP,cITEM,cSEQ,cLOC } )

				Dbgoto(nREC)
				Dbskip()

			End While

			// Ordena itens antes de exibir na árvore
			aItens := aSort( aItens,,,{ |x,y| x[3] < y[3] } )

			For nI := 1 To Len( aItens )

				cCOMP := aItens[nI][1] //Componente
				cITEM := aItens[nI][2] //Item
				cSEQ  := aItens[nI][3] //Sequência
				cLOC  := aItens[nI][4] //Localização

				Dbselectarea( cPAD )
				dbSetOrder( 06 )
				If dbSeek( cSEQ )
					NGMARTRE095( cCOMP,cSEQ,cLOC )
				Else
					cPRODESC := If(!Empty(cLOC),cCOMP+' - '+Alltrim(cITEM)+' - '+cLOC,cCOMP+' - '+cITEM)

					DBADDITEM oTREE PROMPT cPRODESC RESOURCE "FOLDER5" CARGO cCOMP+cSEQ+cLOC
				EndIf

			Next nI

		Else

			While (cPAD)->(!Eof()) .And. Alltrim((cPAD)->TC_CODBEM) == Alltrim(cFIRST)
				aArea    := (cPAD)->(GetArea())
				cCOMP    := (cPAD)->TC_COMPONE
				cITEM    := IF(ST6->(dbSeek(xFILIAL("ST6")+ RTrim( cCOMP ) )),ST6->T6_NOME," ")
				cSEQ     := (cPAD)->TC_SEQRELA
				cLOC     := (cPAD)->TC_LOCALIZ
				cPRODESC := If(!Empty(cLOC),cCOMP+' - '+Alltrim(cITEM)+' - '+cLOC,cCOMP+' - '+cITEM)
				dbSelectArea(cPAD)
				dbSetOrder(06)
				If dbSeek(cSEQ)
					NGMARTRE095(cCOMP,cSEQ,cLOC)
				Else
					DBADDITEM oTREE PROMPT cPRODESC RESOURCE "FOLDER5" CARGO cCOMP+cSEQ+cLOC
				EndIf
				(cPAD)->(RestARea(aArea))
				(cPAD)->(dbSkip())
			End While

		EndIf

		DBENDTREE oTREE
	EndIf

	oTREE:REFRESH()
	oTREE:TREESEEK(cFIRST)
	oDLG95:REFRESH()

Return NIL

//---------------------------------------------------------------------
/*/{Protheus.doc} NGMARTRE095
Busca Itens filhos na estrutura - Funcao Recursiva

@return Vazio.

@param cPAI , Caracter, Código do pai.
@param cNIV , Caracter, Nivel utilizado.
@param cLOCAL , Caracter, Local utilizado.

@author Paulo Pego
@since 28/05/98
/*/
//---------------------------------------------------------------------
Function NGMARTRE095(cPAI,cNIV,cLOCAL)
	Local aArea

	dbSelectArea("ST6")
	dbSetOrder(1)
	dbSeek(xFilial("ST6")+ RTrim( cPAI ) )
	cDESCPAI := SubStr(ST6->T6_NOME,1,40)
	cPRODESC := If(!Empty(cLOCAL),cPAI+' - '+Alltrim(cDESCPAI)+' - '+cLOCAL,cPAI+' - '+cDESCPAI)

	DBADDTREE oTREE PROMPT cPRODESC OPENED RESOURCE "FOLDER5", "FOLDER6" CARGO cPAI+cNIV+cLOCAL

	dbSelectArea(cPAD)
	While !(cPAD)->(Eof()) .And. (cPAD)->TC_SEQSUP == cNIV //(cPAD)->TC_CODBEM == cPAI
		aArea := (cPAD)->(GetArea())
		cCOMP := (cPAD)->TC_COMPONE
		cITEM := IF(ST6->(dbSeek(xFilial("ST6") + RTrim( cCOMP ) )),ST6->T6_NOME, " " )
		cSEQ  := (cPAD)->TC_SEQRELA
		cLOC  := (cPAD)->TC_LOCALIZ
		dbSelectArea(cPAD)
		If dbSeek((cPAD)->TC_SEQRELA)
			NGMARTRE095(cCOMP,cSEQ,cLOC)
		Else
			cPRODESC := If(!Empty(cLOC),cCOMP+' - '+Alltrim(cITEM)+ ' - '+cLOC,cCOMP+' - '+cITEM)
			DBADDITEM oTREE PROMPT cPRODESC RESOURCE "FOLDER5" CARGO cCOMP+cSEQ+cLOC
		EndIf
		dbSelectArea(cPAD)
		RestArea(aArea)
		dbSkip()
	End

	DBENDTREE oTREE
	oTREE:REFRESH()
	oTREE:SETFOCUS()
	oDLG95:REFRESH()
Return NIL

//---------------------------------------------------------------------
/*/{Protheus.doc} NGMARTRB095
Inclui no arquivo de trabalho os itens filhos

@return Vazio.

@param cNivPai , Caracter, Nível do pai.

@author Paulo Pego
@since 28/05/98
/*/
//---------------------------------------------------------------------
Function NGMARTRB095(cNivPai)
	Local cFIEL1,cFIEL2,i := 0
	Local cSequen, aArea

	dbSelectArea("STC")
	dbSetOrder(7)
	While !Eof() .And. STC->TC_FILIAL == xFILIAL("STC") .And. STC->TC_SEQSUP == cNivPai

		aArea  := STC->(GetArea())
		cCOMP  := STC->TC_COMPONE
		nNIVEL := STC->TC_SEQRELA
		cKey   := STC->TC_CODBEM + STC->TC_COMPONE + STC->TC_SEQRELA
		dbSelectArea(cPAD)
		dbSetOrder(01)
		If !(cPAD)->(Dbseek(cKey))
			RecLock((cPad),.T.)
			For i := 1 To Fcount()
				cFIEL1   := "(cPAD)->" + STC->(FIELDNAME(i))
				cFIEL2   := "STC->" + STC->(FIELDNAME(i))
				&cFIEL1. := &cFIEL2.
			Next i

			If lSequeSTC //Verifica se existe o campo TC_SEQUEN no dicionário ou base dados.
				(cPAD)->TC_SEQUEN := STC->TC_SEQUEN
				Mnt090AdFi( STC->TC_CODBEM,STC->TC_COMPONE,STC->TC_SEQUEN ) //Adiciona filhos no array para controle da árvore ordenada.
			EndIf
			MsunLock(cPAD)

			cSequen := STC->TC_SEQRELA
			dbSelectArea("STC")
			dbSetOrder(7)
			If dbSeek(xFilial('STC')+cSequen)
				NGMARTRB095(cSequen)
			EndIf
		EndIf
		RestArea(aArea)
		dbSkip()
	End
Return NIL

//---------------------------------------------------------------------
/*/{Protheus.doc} CHKPAI95
Validaca codigo do pai ao digitar codigo pai/tipo modelo

@return Sempre verdadeiro.

@param cPai , Caracter, Código do pai.

@author Paulo Pego
@since 28/05/98
/*/
//---------------------------------------------------------------------
Function CHKPAI95(cPai)

	Local aAreaSTC := STC->(GetArea())
	Local lFOUND := .F.

	//|-----------------------------------|
	//| Consiste codigo valido            |
	//|-----------------------------------|
	If !ST6->(dbSeek(xFilial("ST6") + RTrim( cPai ) ))
		HELP(" ",1,"CODNEXIST")
		Return .F.
	EndIf

	//|-----------------------------------------------------------------|
	//| Consiste se o bem esta cadastrado em outra estrutura como pai   |
	//|-----------------------------------------------------------------|
	cPai := cPai+Space( TAMSX3("TC_CODBEM")[1]-TAMSX3("T6_CODFAMI")[1] )

	dbSelectArea("STC")
	If lTipMod

		dbSetOrder(5)
		dbSeek(xFilial("STC") + cPai + cNGTIPMOD)

		While !Eof() .And. STC->TC_FILIAL == xFilial("STC") .And. STC->TC_CODBEM == cPai .And. STC->TC_TIPMOD == cNGTIPMOD
			lFOUND := STC->TC_TIPOEST = 'F' .And. Empty(STC->TC_SEQSUP)
			If lFOUND
				Exit
			EndIf
			STC->(dbSkip())
		EndDo

	Else

		dbSetOrder(1)
		dbSeek(xFilial("STC")+cPai)
		While !Eof() .And. STC->TC_FILIAL == xFilial("STC") .And. STC->TC_CODBEM == cPai
			lFOUND := STC->TC_TIPOEST = 'F' .And. Empty(STC->TC_SEQSUP)
			If lFOUND
				Exit
			EndIf
			STC->(dbSkip())
		EndDo

	EndIf

	dbSelectArea(cPAD)
	dbSetOrder(1)
	If lFOUND
		HELP(" ",1,"A090JAEPAI")
		Return .F.
	EndIf

	cDESC := ST6->T6_NOME
	oDESC:REFRESH()

	If !lTpModAlt .Or. !lTemTPM
		cFIRST   := cPAI
		cPRODESC := cPAI+' - '+cDESC
		DBADDTREE oTREE PROMPT cPRODESC OPENED RESOURCE "FOLDER5", "FOLDER6" CARGO cPAI+Space(TAMSX3("TC_LOCALIZ")[1]+TAMSX3("TC_SEQRELA")[1])
		DBENDTREE oTREE

		oTREE:REFRESH()
		oTREE:SETFOCUS()
		lOPT := .F.
		lOPTMod := .F.
	EndIf

	RestArea(aAreaSTC)

Return .T.

//---------------------------------------------------------------------
/*/{Protheus.doc} NGINFILH095
Operacoes basicas da estrutura (incluir, alterar, etc.)

@return Sempre verdadeiro.

@param nOPC , Numérico, Operação a ser executada (2,3,4 ou 5)

@author Paulo Pego
@since 28/05/98
/*/
//---------------------------------------------------------------------
Function NGINFILH095(nOPC)

	Local oDLG952, oMenu, lRET := .F.
	Local cITEM, cPROD, cCOD, cCODIGO
	Local aSUB := {OemToAnsi(STR0010) ,; //"Pesquisa"
				   OemToAnsi(STR0011) ,; //"Visualiza‡Æo"
				   OemToAnsi(STR0012) ,; //"InclusÆo"
				   OemToAnsi(STR0013) ,; //"Altera‡Æo"
				   OemToAnsi(STR0014) }  //"ExclusÆo"
	Local cWhen := NGSEEKDIC("SX3","TC_MANUATI",2,"X3_WHEN")
	Private cLOCA
	Private aCONTADO := {"S","N"}, aCOMPONE := {"S","N"}, aOBRIGAT := {"S","N"}
	Private nVALUE, nMANUT, nOBRIG
	Private dNGDATAEP

	cCODIGO  := SubStr(oTREE:GetCargo(),1,16)

	If STR(nOPC,1) $ "2/4/5" .And. cCODIGO == cPAI
		Return .T.
	ElseIf nOPC == 3
		cITEM     := Space(Len(ST6->T6_CODFAMI))
		cPROD     := Space(40)
		cLOCA     := Space(6)
		cOLDLOCA  := Space(6)
		cNOMLOCA  := Space(40)
		cCONTADO  := Space(3)
		dNGDATAEP := DDataBase
		nVALUE    := 1
		nOBRIG    := 1
		nMANUT    := 1
	Else
		cCOD      := EVAL(bCARGO)
		cSEQ      := EVAL(bcSEQ)
		cITEM     := cCOD
		cPROD     := NGSEEK("ST6", RTrim( cITEM ) ,1,"T6_NOME")
		dNGDATAEP := (cPAD)->TC_DATAINI
		cLOCA     := (cPAD)->TC_LOCALIZ
		cOLDLOCA  := (cPAD)->TC_LOCALIZ
		cCONTADO  := (cPAD)->TC_CONTADO
		nVALUE    := IF((cPAD)->TC_CONTADO =="S",1,2)
		nOBRIG    := IF((cPAD)->TC_OBRIGAT =="S",1,2)
		nMANUT    := IF((cPAD)->TC_MANUATI =="S",1,2)

		TPS->(dbSeek(xFILIAL("TPS")+cLOCA))
		cNOMLOCA := TPS->TPS_NOME
		dbSetOrder(1)
	EndIf

	cTITULO := STR0017+aSUB[nOPC]+STR0018 //"Estrutura PadrÆo - "###" Componente"
	DEFINE MSDIALOG oDLG952 FROM  06,6 To 299,537 TITLE OEMTOANSI(cTITULO) PIXEL

	@ 06,05 To 036, 262 LABEL "" OF oDLG952  PIXEL
	@ 12,10 SAY OEMTOANSI(IF(M->TC_TIPOEST == "B",STR0019,STR0020)) SIZE 37,7 OF oDLG952 PIXEL //"Bem:"###"Familia:"
	@ 39,05 To 115,262 LABEL "" OF oDLG952  PIXEL

	@ 20,10 MSGET cITEM SIZE 42,10 OF oDLG952 PIXEL F3 "ST6" VALID CHKFILHO95(cITEM,@cPROD) PICTURE "@!" WHEN (STR(nOPC,1) $ "3") HASBUTTON
	@ 12,87 SAY OEMTOANSI(STR0021) SIZE 37,7 OF oDLG952 PIXEL //"Descri‡Æo:"
	@ 20,87 MSGET oPROD var cPROD SIZE 120,10 OF oDLG952 PIXEL WHEN .F.

	@ 47,10 SAY OEMTOANSI(STR0022) SIZE 34, 7 OF oDLG952 PIXEL //"Localiza‡Æo:"
	@ 56,10 MSGET cLOCA SIZE 30,10 OF oDLG952 PIXEL VALID CHKLOCA95(cLOCA,nOPC,cOLDLOCA,cITEM) PICTURE "@!" WHEN (STR(nOPC,1) $ "3") F3 "TPS" HASBUTTON
	@ 56,87 GET oNOMLOCA VAR cNOMLOCA SIZE 120, 10 OF oDLG952 PIXEL WHEN .F.

	@ 82,10 SAY STR0023 SIZE 22,7 OF oDLG952 PIXEL //"Data..:"
	@ 91,10 MSGET dNGDATAEP SIZE 50,10 OF oDLG952 PIXEL VALID !Empty(dNGDATAEP) WHEN (STR(nOPC,1) $ "3/4") HASBUTTON

	@ 82,87 To 110,120 LABEL STR0024 OF oDLG952  PIXEL //"Contador"
	@ 89,92 RADIO oRAD VAR nVALUE ITEMS STR0025, STR0026 WHEN (STR(nOPC,1) $ "3/4") 3D SIZE 20,10 PIXEL //"&Sim"###"&Nao"

	If M->TC_TIPOEST == "F"
		@ 82,134 To 110,167 LABEL STR0027 OF oDLG952 PIXEL //"Obrigatorio"
		@ 89,138 RADIO oRAD VAR nOBRIG ITEMS STR0025,STR0026 WHEN (STR(nOPC,1) $ "3/4") 3D SIZE 20,10 PIXEL //"&Sim"###"&Nao"

		@ 82,181 To 110,214 LABEL STR0028 OF oDLG952  PIXEL //"Bem Ativo"
		@ 89,186 RADIO oRAD VAR nMANUT ITEMS STR0025, STR0026 WHEN (STR(nOPC,1) $ "3/4") 3D SIZE 20,10 PIXEL //"&Sim"###"&Nao"
		oRAD:bWhen := {|| (STR(nOPC,1) $ "3/4") .And. If(Empty(cWhen),.T.,&cWhen)}
	EndIf

	If STR(nOPC,1) $ "3/4"
		DEFINE SBUTTON FROM 122,200 TYPE 1 ENABLE OF oDLG952 ACTION (lRet := fChkComp(cITEM,cLOCA),If(lRet,oDLG952:END(),Nil))
	ElseIf nOPC == 5
		DEFINE SBUTTON FROM 122,200 TYPE 1 ENABLE OF oDLG952 ACTION (lRET := .T.,oDLG952:END())
	Endif

	DEFINE SBUTTON FROM 122,230 TYPE 2 ENABLE OF oDLG952 ACTION (lRET := .F.,oDLG952:END())
	NGPOPUP(asMenu,@oMenu)
	oDlg952:bRClicked:= { |o,x,y| oMenu:Activate(x,y,oDlg952)}

	ACTIVATE MSDIALOG oDLG952 CENTERED

	If nOPC == 2
		Return .T.
	ElseIf lRET .And. (STR(nOPC,1) $ "3/4" )
		cSEQ := EVAL(bcSEQ)

		If nOPC == 3
			NGSEGTREE095(cITEM+Space(TAMSX3("TC_CODBEM")[1]-TAMSX3("T6_CODFAMI")[1]),Nil,cLOCA,cSEQ,nOPC)

			If lSequeSTC //Verifica se existe o campo TC_SEQUEN no dicionário ou base dados.
				Mnt090AdFi( (cPAD)->TC_CODBEM,(cPAD)->TC_COMPONE,(cPAD)->TC_SEQUEN ) //Adiciona filhos no array para controle da árvore ordenada.
			EndIf

		ElseIf nOPC == 4
			RecLock((cPad),.F.)
			cSEQ := EVAL(bcSEQ)
			cCOD := SUBSTR(cITEM + Space(16),1,16)
			(cPAD)->TC_LOCALIZ := cLOCA
			(cPAD)->TC_DATAINI := dNGDATAEP
			(cPAD)->TC_CONTADO := aCONTADO[nVALUE]
			(cPAD)->TC_MANUATI := aCOMPONE[nMANUT]
			(cPAD)->TC_OBRIGAT := aOBRIGAT[nOBRIG]
			MsUnLock(cPAD)
		EndIf
		oTREE:REFRESH()
		oTREE:SETFOCUS()

	ElseIf lRET .And. (STR(nOPC,1) $ "5")
		NGSEGTREE095((cPAD)->TC_COMPONE,(cPAD)->TC_SEQRELA,Nil,Nil,nOPC)

	EndIf

Return .T.

//---------------------------------------------------------------------
/*/{Protheus.doc} fChkComp
Valida a inclusao/alteracao de um componente na estrutura

@return lRet, Lógica, Retorna verdadeiro mediante as condições.

@param cITEM , Caracter, Item.
@param cLOCA , Caracter, Localização do item.

@author Felipe Nathan Welter
@since 18/02/11
/*/
//---------------------------------------------------------------------
Static Function fChkComp(cITEM,cLOCA)
	Local lRet := .T.
	Local aArea := (cPAD)->(GetArea())
	Local cCODIGO := SubStr(oTREE:GetCargo(),1,16)
	Local cSEQUEN := SubStr(oTREE:GetCargo(),17,5)

	//nao permite a inclusao de dois componentes com mesmo codigo e localizacao no mesmo nivel, com mesmo pai
	dbSelectArea(cPAD)
	dbSetOrder(01)
	cITEM += Space( TAMSX3("TC_CODBEM")[1]-TAMSX3("T6_CODFAMI")[1] )
	dbSeek(cCODIGO+cITEM+cLOCA)
	While cCODIGO == (cPAD)->TC_CODBEM .And. cITEM == (cPAD)->TC_COMPONE .And. cLOCA == (cPAD)->TC_LOCALIZ
		If (cPAD)->TC_SEQSUP == cSEQUEN
			MsgInfo(STR0046,OemToAnsi(STR0031))  //"Já existe componente com mesma família e localização neste nível."##"ATEN€ÇO"
			lRet := .F.
			Exit
		EndIf
		(cPAD)->(dbSkip())
	EndDo
	(cPAD)->(RestArea(aArea))
Return lRet

//---------------------------------------------------------------------
/*/{Protheus.doc} CHKFILHO95
Valida a digitacao do codigo da familia (componente)

@return Sempre verdadeiro.

@param cITEM , Caracter, Item.
@param cPROD , Caracter, Nome do Item.

@author Paulo Pego
@since 28/10/98
/*/
//---------------------------------------------------------------------
Function CHKFILHO95(cITEM, cPROD)
	Local cKey := cITEM+Space(Len(STC->TC_CODBEM)-Len(cITEM))
	Local cPAISU := SubStr(oTREE:GetCargo(),1,16)

	If !ST6->(dbSeek(xFilial('ST6') + RTrim( cITEM ) ))
		Help(" ",1, "CODNEXIST")
		Return .F.
	EndIf

	If cKey = Substr(cFIRST,1,Len(STC->TC_CODBEM)) .Or. cKey = cPAISU
		Help(" ",1,"A090CODPAI")
		Return .F.
	EndIf

	//|-------------------------------------------------------|
	//|Consiste se o bem esta cadastrado em outra estrutura   |
	//|-------------------------------------------------------|
	dbSelectArea("STC")
	dbSetOrder(3)
	If dbSeek(xFilial('STC')+cKey)
		While !Eof() .And. STC->TC_FILIAL = xFilial('STC') .And. STC->TC_CODBEM = cKey
			If STC->TC_TIPOEST == "B"
				Help(" ",1,"A090NODES2",,cKey,2,26)
				dbSetOrder(1)
				Return .F.
			EndIf
			dbSkip()
		End
	EndIf

	//---------------------------------------------------------------
	// Verifica se o pai é filho do componente em outra estrutura
	//---------------------------------------------------------------
	If EachOther( cITEM, cPAISU )
		Help(" ",1,"A090CODPAI")
		Return .F.
	EndIf

	cPROD := NGSEEK( 'ST6', RTrim( cITEM ),  1, 'T6_NOME')
	oPROD:Refresh()

Return .T.

//---------------------------------------------------------------------
/*/{Protheus.doc} CHKLOCA95
Valida localizacao informada e preenche descricao

@return lRETOR, Lógica, Condicional a verificação.

@param cLOCA	, Caracter, Localização.
@param nOPC		, Numérico, Número da opção.
@param cOLDLOCA , Caracter, Localização anterior.
@param cVITEM1  , Caracter, Item.

@author Paulo Pego
@since 28/10/98
/*/
//---------------------------------------------------------------------
Function CHKLOCA95(cLOCA,nOPC,cOLDLOCA,cVITEM1)
	Local lRETOR := .T.
	cNomLoca := Space(40)
	If !Empty(cLoca)
		If !TPS->(Dbseek(xFilial("TPS")+cLOCA))
			HELP(" ",1, "REGNOIS")
			lRETOR := .F.
		Else
			dbSelectArea(cPAD)
			dbSetOrder(4)
			If dbSeek(cVITEM1+cLOCA)
				Help(" ",1, "LOCALJAEXI")
				lRETOR := .F.
			Else
				cNOMLOCA := TPS->TPS_NOME
			EndIf
		EndIf
	EndIf
	oNOMLOCA:Refresh()
Return lRETOR

//---------------------------------------------------------------------
/*/{Protheus.doc} NGATUES95
Atualiza o arquivo de Estrutura (STC) basedo no arquivo de
no arquivo de Trabalho (PAD)

@return Sempre verdadeiro.

@author Paulo Pego
@since 28/10/98
/*/
//---------------------------------------------------------------------
Function NGATUES95()

	Local lFirst  := .t.
	Local lFound  := .F.
	Local nX

	Set Delete Off //considera registros deletados

	//refaz todas as sequencias utilizadas na rotina
	//para que nao haja inconsistencia de base
	For nX := 1 To Len(aNewSeq)
		cNextSeq := fNextSeq(If(nX==1,Nil,cNextSeq))
		aNewSeq[nX,2] := cNextSeq
	Next aNewSeq

	dbSelectArea(cPAD)
	dbGoTop()

	While !Eof()
		If !Deleted()
			Set Delete On
			dbSelectArea("STC")

			lFound := .F.

			//Procura se registro ja existe na STC
			If lTipMod
				dbSetOrder(5)
				dbSeek(xFilial('STC') + (cPAD)->TC_CODBEM + (cPAD)->TC_TIPMOD + (cPAD)->TC_COMPONE)
				While !Eof() .And. STC->TC_FILIAL  == xFilial('STC') .And.;
				STC->TC_CODBEM  == (cPAD)->TC_CODBEM .And.;
				STC->TC_TIPMOD  == (cPAD)->TC_TIPMOD .and.;
				STC->TC_COMPONE == (cPAD)->TC_COMPONE

					If !Deleted()
						If M->TC_TIPOEST == "B"
							lFound := .T.
							Exit
						Else
							If (cPAD)->TC_LOCALIZ == STC->TC_LOCALIZ .And. (cPAD)->TC_SEQRELA == STC->TC_SEQRELA
								lFound := .T.
								Exit
							EndIf
						EndIf
					EndIf

					dbSkip()
				EndDo
			Else
				dbSetOrder(1)
				dbSeek(xFilial('STC') + (cPAD)->TC_CODBEM + (cPAD)->TC_COMPONE)
				While !Eof() .And. stc->tc_filial  == xFilial('STC') .And.;
				STC->TC_CODBEM == (cPAD)->TC_CODBEM .And.;
				STC->TC_COMPONE == (cPAD)->TC_COMPONE

					If !Deleted()
						If M->TC_TIPOEST == "B"
							lFound := .T.
							Exit
						Else
							If (cPAD)->TC_LOCALIZ == STC->TC_LOCALIZ .And. (cPAD)->TC_SEQRELA == STC->TC_SEQRELA
								lFound := .T.
								Exit
							EndIf
						EndIf
					EndIf

					dbSkip()
				EndDo
			EndIf

			//Inclui/altera registro na STC conforme PAD
			If !lFound
				RecLock("STC",.T.)
				Replace TC_FILIAL  with xFilial('STC')
				Replace TC_TIPOEST with M->TC_TIPOEST
				Replace TC_CODBEM  with (cPAD)->TC_CODBEM
				Replace TC_COMPONE with (cPAD)->TC_COMPONE

				If lTipMod
					Replace TC_TIPMOD with (cPAD)->TC_TIPMOD
				EndIf

				If lSequeSTC //Verifica se existe o campo TC_SEQUEN no dicionário ou base dados.
					Mnt090AdFi( (cPAD)->TC_CODBEM,(cPAD)->TC_COMPONE ) //Adiciona filhos no array para controle da árvore ordenada.
					STC->TC_SEQUEN := Mnt090RtSq( STC->TC_CODBEM,STC->TC_COMPONE ) //Função que retorna o sequencial do componente na estrutura.
				EndIf

				nX := aSCan(aNewSeq,{|x| x[1] == (cPAD)->TC_SEQRELA})
				Replace TC_SEQRELA with If(nX>0,aNewSeq[nX,2],(cPAD)->TC_SEQRELA)
				nX := aSCan(aNewSeq,{|x| x[1] == (cPAD)->TC_SEQSUP})
				Replace TC_SEQSUP with If(nX>0,aNewSeq[nX,2],(cPAD)->TC_SEQSUP)

			Else
				RecLock("STC",.F.)
			EndIf

			If lTipMod
				If Empty(TC_TIPMOD)
					If !Empty(cNGTIPMOD)
						Replace TC_TIPMOD with cNGTIPMOD
					EndIf
				EndIf
			EndIf

			Replace TC_LOCALIZ with (cPAD)->TC_LOCALIZ
			Replace TC_DATAINI with (cPAD)->TC_DATAINI
			Replace TC_CONTADO with (cPAD)->TC_CONTADO
			Replace TC_MANUATI with (cPAD)->TC_MANUATI
			Replace TC_OBRIGAT with (cPAD)->TC_OBRIGAT
			MsunLock("STC")

			If lFirst
				nINIC := Recno()
				lFirst := .F.
			Endif

		Else

			Set Delete On
			dbSelectArea("STC")

			If lTipMod
				dbSetOrder(5)
				dbSeek(xFilial('STC') + (cPAD)->TC_CODBEM + (cPAD)->TC_TIPMOD + (cPAD)->TC_COMPONE)

				While !Eof() .And. STC->TC_FILIAL  == xFilial('STC') .And.;
				STC->TC_CODBEM  == (cPAD)->TC_CODBEM .And.;
				STC->TC_TIPMOD  == (cPAD)->TC_TIPMOD .and.;
				STC->TC_COMPONE == (cPAD)->TC_COMPONE

					If !Deleted() .And. STC->TC_LOCALIZ == (cPAD)->TC_LOCALIZ .And. (cPAD)->TC_SEQRELA == STC->TC_SEQRELA
						RecLock("STC",.F.)
						dbDelete()
						MsunLock("STC")
					EndIf
					dbSkip()
				EndDo
			Else
				dbsetOrder(1)
				dbSeek(xFilial('STC') + (cPAD)->TC_CODBEM + (cPAD)->TC_COMPONE)

				While !Eof() .And. STC->TC_FILIAL  == xFilial('STC') .And.;
				STC->TC_CODBEM  == (cPAD)->TC_CODBEM .And.;
				STC->TC_COMPONE == (cPAD)->TC_COMPONE

					If !Deleted() .And. STC->TC_LOCALIZ == (cPAD)->TC_LOCALIZ .And. (cPAD)->TC_SEQRELA == STC->TC_SEQRELA
						RecLock("STC",.F.)
						dbDelete()
						MsunLock("STC")
					EndIf
					dbSkip()
				EndDo
			EndIf

		EndIf

		Set Delete Off
		dbSelectArea(cPAD)
		dbSkip()
	End

	Set Delete On
	lRefresh := .T.

Return .T.

//---------------------------------------------------------------------
/*/{Protheus.doc} CHKPAD95
Consiste a estrutura padrao com a estrutura de bens

@return lRet, Lógica, Retorna .T. caso esteja correto.

@author Paulo Pego
@since 28/10/98
/*/
//---------------------------------------------------------------------
Function CHKPAD95(cPai)

	Local lRet := .t., nRec, lFound := .t.,I := 0
	Local nNIVEL
	Local cOldFiltro
	Local oTmpTbl3
	Local oTmpTbl4
	Local lcModelo := Trim(cNGTIPMOD) != '*'

	Private bFami := {|x| ST9->(Dbseek(xFilial('ST9') + x)), st9->t9_codfami}
	Private cRel	  := GetNextAlias()
	Private cTRBSTC	  := GetNextAlias()

	//|-----------------------------------------------------------------|
	//|Cria Arquivo de Trabalho que ira gerar o relatorio de erro       |
	//|-----------------------------------------------------------------|
	aDBF := {}
	Aadd(aDBF, {"PAI"   , "C", 30, 0})
	Aadd(aDBF, {"LOCA"  , "C", 30, 0})
	Aadd(aDBF, {"DESCR"  , "C", 70, 0})

	//Intancia classe FWTemporaryTable (Arquivo 3)
	oTmpTbl3  := FWTemporaryTable():New( cREL, aDBF )
	//Cria indices
	oTmpTbl3:AddIndex( "Ind01" , {"PAI"}  )
	//Cria a tabela temporaria
	oTmpTbl3:Create()

	//|------------------------------------|
	//|Cria Arquivo de Trabalho            |
	//|------------------------------------|
	// OBS: FOI INCLUIDO OS CAMPOS TC_OK,TC_CCUSTO,TC_CENTRAB,CALENDA NO
	// ARQUIVO TEMPORARIO PORQUE E USADO NA CHAMADA DA FUNCAO NGMAKTRB090
	// QUE ESTµ NO MNTA090.PRW. NAO RETIRAR OS CAMPOS ACIMA

	nTam := Len(stc->tc_codbem)
	aDBF := STC->(DbStruct())

	Aadd(aDBF, { 'TC_FAMBEM'  , 'C', nTam, 0 } )
	Aadd(aDBF, { 'TC_FAMCOMP' , 'C', nTam, 0 } )
	Aadd(aDBF, { 'TC_LOCBEM'  , 'C', 06  , 0 } )
	Aadd(aDBF, { 'TC_OK'      , 'C', 01  , 0 } )
	Aadd(aDBF, { 'TC_CCUSTO'  , 'C', Len(SI3->I3_CUSTO), 0 } )
	Aadd(aDBF, { 'TC_CENTRAB' , 'C', 06  , 0 } )
	Aadd(aDBF, { 'TC_CALENDA' , 'C', 03  , 0 } )
	AaDD(aDBF, { 'TC_CONTAD1' , 'N', 09  , 0 } )
	AaDD(aDBF, { 'TC_CONTAD2' , 'N', 09  , 0 } )
	Aadd(aDBF, { 'TC_COMPNOV' , 'C', 01  , 0 } )
	Aadd(aDBF, { 'TC_HORAIMP' , 'C', 05  , 0 } )
	Aadd(aDBF, { 'TC_HORASAI' , 'C', 05  , 0 } )
	Aadd(aDBF, { 'TC_CONT1AT' , 'N', 09  , 0 } )
	Aadd(aDBF, { 'TC_CONT2AT' , 'N', 09  , 0 } )
	aAdd(aDBF,{ 'NIVEL'     , 'N', 03, 0 } )

	//Intancia classe FWTemporaryTable
	oTmpTbl4  := FWTemporaryTable():New( cTRBSTC, aDBF )
	//Cria indices
	oTmpTbl4:AddIndex( "Ind01" , {"TC_FAMBEM","TC_FAMCOMP"}  )
	oTmpTbl4:AddIndex( "Ind02" , {"TC_COMPONE","TC_CODBEM","TC_SEQRELA"} ) // O segundo índice é usado na função NGMAKTRB090 no fonte mnta090 
	//Cria a tabela temporaria
	oTmpTbl4:Create()

	//|-----------------------------------------------------------------------|
	//| Coloca para o ambiente de processamento no STC para estrutura de BEM  |
	//|-----------------------------------------------------------------------|
	DbselectArea("ST9")
	DbsetOrder(4)

	M->TC_TIPOEST := "B"

	DbselectArea("STC")
	nRECAMPO := Fcount()
	DbsetOrder(1)
	cOldFiltro := STC->(dbFilter())
	Set Filter To STC->TC_FILIAL = xFilial("STC") .And. STC->TC_TIPOEST == "B"
	dbSeek(xFilial('STC'))

	DbselectArea(cPAD)
	nRecPAD := Recno()
	Dbgotop()

	DbselectArea("ST9")
	Dbseek(xFilial('ST9') + Trim(cPai))

	While !Eof() .And. st9->t9_filial == xFilial('ST9') .And. ;
	Alltrim(st9->t9_codfami) == Alltrim(cPAI)

		If lTipMod
			If (lcModelo .And. ST9->T9_TIPMOD != cNGTIPMOD)
				ST9->(DbsetOrder(4))
				ST9->(Dbskip())
				Loop
			EndIf
		EndIf

		cCODBEM := st9->t9_codbem
		cNOMBEM := st9->t9_nome
		nST9    := ST9->(Recno())

		ST9->(DbsetOrder(1))

		If !STC->( Dbseek(xFilial('STC') + cCODBEM) )
			ST9->(DbsetOrder(4))
			ST9->(Dbskip())
			Loop
		Endif

		While !Eof() .And. stc->tc_filial == xFilial('STC') .And. ;
		Trim(stc->tc_codbem) == Trim(cCODBEM)

			nRec   := STC->(Recno())
			cCOMP  := stc->tc_compone
			nNIVEL := stc->tc_seqrela
			DbselectArea(cTRBSTC)
			(cTRBSTC)->(DbAppend())
			For i := 1 To nRECAMPO
				(cTRBSTC)->(FieldPut(i, STC->(FIELDGET(i)) ))
			Next i
			(cTRBSTC)->tc_fambem  := Eval(bFAMI, stc->tc_codbem)
			(cTRBSTC)->tc_famcomp := Eval(bFAMI, stc->tc_compone)
			(cTRBSTC)->tc_locbem  := ''

			DbselectArea("STC")
			cLoc := (cTRBSTC)->TC_LOCALIZ
			If Dbseek(xFilial('STC') + cCOMP )
				NGMAKTRB090(cCOMP,cLoc)
			Endif

			Dbgoto(nRec)
			Dbskip()
		End

		//|----------------------------------------------------------|
		//| Verifica se a estrutura do bem atende a estrutura padrao |
		//|----------------------------------------------------------|
		(cPAD)->(Dbgotop())
		While !(cPAD)->(Eof())
			lFound := .t.
			DbselectArea(cTRBSTC)
			If !Dbseek((cPAD)->tc_codbem + (cPAD)->tc_compone )
				lFound := .f.
			Else
				If !Empty((cPAD)->tc_localiz)
					lFound :=  .f.
					While !Eof() .And. Alltrim((cTRBSTC)->tc_fambem) == Alltrim((cPAD)->tc_codbem)  .And.;
					Alltrim((cTRBSTC)->tc_famcomp) == Alltrim((cPAD)->tc_compone)

						If (cTRBSTC)->tc_localiz == (cPAD)->tc_localiz

							//busca localizacao do pai na estrutura padrao
							cLocP1 := ""
							aAreaPAD := (cPAD)->(GetArea())
							If !Empty((cPAD)->TC_SEQSUP)
								(cPAD)->(dbSetOrder(05))
								If (cPAD)->(dbSeek((cPAD)->TC_SEQSUP))
									cLocP1 := (cPAD)->TC_LOCALIZ
								EndIf
							EndIf
							(cPAD)->(RestArea(aAreaPAD))

							If AllTrim(cLocP1) = AllTrim((cTRBSTC)->TC_LOCBEM)
								lFound := .t.
								Exit
							EndIf
						Endif
						(cTRBSTC)->(Dbskip())
					End
				Endif
			Endif

			If !lFound
				If (cPAD)->tc_obrigat == "S"
					(cREL)->(DbAppend())
					(cREL)->PAI  := TRIM(cCODBEM) + " " + cNOMBEM
					(cREL)->LOCA := TRIM((cPAD)->TC_LOCALIZ)+" "+IF(TPS->(Dbseek(xFILIAL("TPS")+(cPAD)->TC_LOCALIZ)),TPS->TPS_NOME,Space(10))
					(cREL)->DESCR := STR0039 //"POSICAO OBRIGATORIA NA ESTRUTURA PADRAO NAO EXISTE NA ESTRUTURA DO BEM"
				Endif
			Endif

			ST9->( Dbseek(xFilial('ST9') + (cTRBSTC)->tc_compone) )
			If (cPAD)->tc_contado == "S" .And. (cPAD)->tc_obrigat == "S"
				If ST9->T9_TEMCONT == 'N'
					(cREL)->(DbAppend())
					(cREL)->PAI  := TRIM(cCODBEM) + " " + cNOMBEM
					(cREL)->LOCA := TRIM((cPAD)->TC_LOCALIZ)+" "+IF(TPS->(Dbseek(xFILIAL("TPS")+(cPAD)->TC_LOCALIZ)),TPS->TPS_NOME,Space(10))
					(cREL)->DESCR := STR0029 //"BEM CONTROLADO POR CONTADOR NAO EXISTENTE NA ESTRUTURA DO BEM"
				Endif
			Endif

			If ((cTRBSTC)->tc_fambem + (cTRBSTC)->tc_famcomp) == ((cPAD)->tc_codbem + (cPAD)->tc_compone)
				(cTRBSTC)->(dBDelete())
			Endif
			DbselectArea(cPAD)
			Dbskip()
		End

		DbselectArea(cTRBSTC)
		ZAP

		ST9->(DbsetOrder(4))
		ST9->(Dbgoto(nST9))
		st9->(Dbskip())
	End

	//|------------------------------------------------------|
	//| VERIFICA SE EXISTE ERROR E GERA O RELATORIO          |
	//|------------------------------------------------------|
	lRet := .t.
	(cREL)->(Dbgotop())
	If !(cREL)->(Eof())
		If MSGYESNO(STR0030, OEMTOANSI(STR0031)) //"Existe(m) erro(s) de consistencia na estrutura. Deseja imprimir ?"###"ATEN€ÇO"
			NG095LERROS()
		Endif
		lRet := .f.
	Endif

	//|------------------------------------------------------|
	//| Retorna ao ambiente original                         |
	//|------------------------------------------------------|
	DbselectArea("ST9")
	DbsetOrder(1)

	M->TC_TIPOEST := "F"

	DbselectArea("STC")
	DbsetOrder(1)
	Set Filter To &(cOldFiltro)
	Dbseek(xFilial('STC'))

	oTmpTbl3:Delete()
	oTmpTbl4:Delete()

	DbselectArea(cPAD)
	Dbgoto(nRecPAD)
Return lRet

//---------------------------------------------------------------------
/*/{Protheus.doc} NG095LERROS
Função responsável por chamar o relatório de erros.

@return Vazio.

@author Paulo Pego
@since 28/10/98
/*/
//---------------------------------------------------------------------
Static Function NG095LERROS()
	Local cString    := "ST9"
	Local cDesc1     := STR0032 //"Listagem de error ocorrido na estrutura "
	Local cDesc2     := ""
	Local cDesc3     := ""
	Local wnrel      := "MNTA095"

	Private aReturn  := { STR0033, 1,STR0034, 1, 2, 1, "",1 } //"Zebrado"###"Administracao"
	Private nLastKey := 0
	Private Tamanho  := "M"
	Private cPERG    := " "
	Private NOMEPROG := "MNTA095"
	Private Titulo   := STR0035 //"LISTAGEM DE ERROR NA ESTRUTURA"
	Private CABEC1,CABEC2

	//|-------------------------------------------------------------|
	//| Envia controle para a funcao SETPRINT                       |
	//|-------------------------------------------------------------|
	wnrel:=SetPrint(cString,wnrel,cPerg,titulo,cDesc1,cDesc2,cDesc3,.F.,"")
	If nLastKey = 27
		Set Filter To
		Return
	Endif

	SetDefault(aReturn,cString)

	If nLastKey = 27
		Set Filter To
		Return
	Endif

	RptStatus({|lEnd| R095Imp(@lEnd,wnRel,titulo,tamanho)},titulo)

Return NIL

//---------------------------------------------------------------------
/*/{Protheus.doc} R095IMP
Responsável por realizar a impressão do relatório.

@return Vazio.

@param lEnd		, Lógica  , Determina o fim da impressão.
@param wnRel	, Caracter, Variável padrão da impressão.
@param titulo	, Caracter, Titulo do relatório.
@param tamanho  , Caracter, Tamanho da impressão do relatório.

@author Paulo Pego
@since 28/10/98
/*/
//---------------------------------------------------------------------
Static Function R095Imp(lEnd,wnRel,titulo,tamanho)
	Local cRodaTxt   := ""
	Local nCntImpr   := 0
	Private li       := 80,cPerg := "XXXXX"
	Private nomeprog := "MNTA095"
	Private Cabec1, cABEC2
	m_pag  := 1
	nTipo  := IIF(aReturn[4]==1,15,18)

	CABEC1 := STR0036 //"BEM                            POSICAO                        PROBLEMA"

	DbselectArea(cREL)
	Dbgotop()
	SetRegua(LastRec())

	While !(cREL)->(Eof())
		IncRegua()

		If Li > 58
			Cabec(titulo,Cabec1,cPerg,nomeprog,tamanho,nTipo)
		EndIf

		NGSOMALI(58)
		@li,000 Psay (cREL)->PAI
		@li,031 Psay (cREL)->LOCA
		@li,062 Psay (cREL)->DESCR

		(cREL)->(Dbskip())
	End

	Roda(nCntImpr,cRodaTxt,Tamanho)

	Set Filter To

	Set device to Screen

	If aReturn[5] = 1
		Set Printer To
		dbCommitAll()
		OurSpool(wnrel)
	Endif
	MS_FLUSH()
Return NIL

//---------------------------------------------------------------------
/*/{Protheus.doc} CLICH95
Responsável por chamar a função NGINFILH095 com parâmetro 2.

@return Vazio.

@author Paulo Pego
@since 28/10/98
/*/
//---------------------------------------------------------------------
Function CLICH95()
	NGINFILH095(2)
Return NIL

//---------------------------------------------------------------------
/*/{Protheus.doc} MNT095MOVE
Rotina chamada ao trocar o foco do item da estrutura

@return Vazio.

@param cCOD	 , Caracter, Código da bem.
@param cSEQU , Caracter, Sequência da estrutura.

@author Paulo Pego
@since 28/10/98
/*/
//---------------------------------------------------------------------
Function MNT095MOVE(cCOD,cSEQU)

	Local cKey := SUBSTR(oTREE:GETCARGO(),17,TAMSX3("TC_SEQRELA")[1])

	If cCOD == cPAI
		If STR(nOPCAO,1) $ "2"
			oBtn1:Disable()  //visualizar
		ElseIf STR(nOPCAO,1) $ "3/4"
			oBtn4:Disable()  //editar
			oBtn5:Disable()  //excluir
		EndIf
	Else
		If STR(nOPCAO,1) $ "2"
			oBtn1:Enable()  //visualizar
		ElseIf STR(nOPCAO,1) $ "3/4"
			oBtn4:Enable()  //editar
			oBtn5:Enable()  //excluir
		EndIf
	EndIf

	cLOC1  := Space(12)
	cLOC2  := Space(17)
	cLOC3  := Space(40)

	dbSelectArea(cPAD)
	dbSetOrder(5)
	If dbSeek(cKey)
		ST6->(dbSeek(xFilial("ST6") + RTrim( (cPAD)->TC_COMPONE ) ))
		If !Empty((cPAD)->TC_LOCALIZ)
			If TPS->(dbSeek(xFILIAL("TPS")+(cPAD)->TC_LOCALIZ))
				cLOC1 := STR0038 //"Localizacao"
				cLOC2 := (cPAD)->TC_LOCALIZ
				cLOC3 := Alltrim(TPS->TPS_NOME)
			EndIf
		EndIf
	EndIf

	OLOC951:Refresh()
	oLOC952:Refresh()
	oLOC953:Refresh()

	dbSelectArea(cPAD)
	dbSetOrder(1)

Return NIL

//---------------------------------------------------------------------
/*/{Protheus.doc} NGSEGTREE095
Busca itens filhos na estrutura - funcao recursiva que inclui
ou exclui os filhos da arvore e do arquivo temporario

@return Vazio.

@param cCOMPONE	, Caracter, Codigo do componente a ser pai.
@param cSEQ		, Caracter, Sequência do componente.
@param cLOCAL	, Caracter, Localização do componente.
@param cSEQSUP	, Caracter, Sequência superior do componente na estrutura.
@param nOPC		, Caracter, Operação 3=inclusao;5=exclusao.
@param cSEQSTC	, Caracter, Sequência superior da estrutura STC.

@sample NGSEGTREE095(cCOMP,Nil,cLOCA,cSEQ,3)

@author Deivys Joenck
@since 21/01/02
/*/
//---------------------------------------------------------------------
Function NGSEGTREE095(cCOMPONE,cSEQ,cLOCAL,cSEQSUP,nOPC,cSEQSTC)

	Local aArea, aArea2, cCARGO
	Local cOldCARGO := oTREE:GetCargo()
	Local lBemFilho := .F.
	Local cDESCPAI  //para adicao do item na TREE
	Local cCOMP, cSEQ1, cITEM, cLOCA  //para componentes (filhos) do item
	Local cPRODESC := ""

	If nOPC == 3

		cSEQ := fNextSeq(@cNextSeq)

		//Grava item na tabela PAD
		RecLock((cPad),.T.)
		(cPAD)->TC_FILIAL  := xFilial("STC")
		(cPAD)->TC_TIPOEST := M->TC_TIPOEST
		(cPAD)->TC_CODBEM  := EVAL(bCARGO)
		(cPAD)->TC_COMPONE := cCOMPONE
		(cPAD)->TC_LOCALIZ := cLOCAL
		(cPAD)->TC_DATAINI := dNGDATAEP
		(cPAD)->TC_CONTADO := aCONTADO[nVALUE]
		(cPAD)->TC_OBRIGAT := aOBRIGAT[nOBRIG]
		(cPAD)->TC_MANUATI := aCOMPONE[nMANUT]
		(cPAD)->TC_SEQRELA := cSEQ
		If oTREE:Nivel() > 1
			(cPAD)->TC_SEQSUP  := cSEQSUP
		EndIf
		If lTipMod
			(cPAD)->TC_TIPMOD := cNGTIPMOD
		EndIf
		MsUnLock(cPAD)

		//Adiciona item na arvore (oTREE)
		dbSelectArea("ST6")
		dbSetOrder(1)
		If dbSeek(xFilial("ST6") + RTrim( cCOMPONE ) )
			cDESCPAI := SubStr(ST6->T6_NOME,1,40)
			cPRODESC := If(!Empty(cLOCAL),cCOMPONE+' - '+Alltrim(cDESCPAI)+' - '+cLOCAL,cCOMPONE+' - '+cDESCPAI)
		EndIf

		cCARGO := cCOMPONE+cSEQ+cLOCAL
		oTREE:ADDITEM(cPRODESC,cCARGO,"FOLDER5","FOLDER6",,,2)
		oTREE:TREESEEK(cCARGO)

		cOldCARGO := oTREE:GetCargo()
		cSEQSUP   := cSEQ

		//Quando nao há sequencia superior, considera todos os itens cujo CODBEM seja igual ao codigo do parametro,
		//já quando passa sequencia superior, faz busca somente pelos itens da estrutura selecionada
		If Empty(cSEQSTC)

			dbSelectArea("STC")
			Dbsetorder( If( lSequeSTC,8,1 ) )
			If dbSeek(xFilial("STC")+cCOMPONE)
				While !Eof() .And. STC->TC_FILIAL == xFilial("STC") .And. STC->TC_CODBEM == cCOMPONE

					aArea := STC->(GetArea())
					cCOMP := STC->TC_COMPONE
					cSEQ1 := STC->TC_SEQRELA
					cITEM := IF(ST6->(dbSeek(xFilial("ST6") + RTrim( cCOMP ) )),ST6->T6_NOME," ")
					cLOCA := STC->TC_LOCALIZ

					//se for pai de estrutura, adiciona subestrutura (considera que funcao e' recursiva)
					//nao pegando itens no meio de outras estruturas. No nivel 1 considera todos conforme TC_CODBEM
					If (ProcName(1) != "NGSEGTREE095" .And. Empty(STC->TC_SEQSUP)) .Or.;
					ProcName(1) == "NGSEGTREE095"

						dbSelectArea("STC")
						Dbsetorder( If( lSequeSTC,8,1 ) )
						If dbSeek(xFilial("STC")+cCOMP)
							//componente (filho) possui mais niveis abaixo
							NGSEGTREE095(cCOMP,Nil,cLOCA,cSEQ,nOPC,cSEQ1)
							oTREE:TREESEEK(cOldCARGO)
						Else
							//adiciona componente na arvore
							STC->(RestArea(aArea))

							cSEQ := fNextSeq(@cNextSeq)

							cCARGO := cCOMP+cSEQ+STC->TC_LOCALIZ
							cPRODESC := If(!Empty(cLOCA),cCOMP+' - '+Alltrim(cITEM)+' - '+cLOCA,cCOMP+' - '+cITEM)
							oTREE:ADDITEM(cPRODESC,cCARGO,"FOLDER5","FOLDER6",,,2)
							oTREE:TREESEEK(cCARGO)

							RecLock((cPad),.T.)
							(cPAD)->TC_FILIAL  := xFilial("STC")
							(cPAD)->TC_TIPOEST := M->TC_TIPOEST
							(cPAD)->TC_CODBEM  := STC->TC_CODBEM
							(cPAD)->TC_COMPONE := STC->TC_COMPONE
							(cPAD)->TC_SEQRELA := cSEQ
							(cPAD)->TC_SEQSUP  := cSEQSUP
							(cPAD)->TC_LOCALIZ := STC->TC_LOCALIZ
							(cPAD)->TC_DATAINI := dNGDATAEP
							(cPAD)->TC_CONTADO := STC->TC_CONTADO
							(cPAD)->TC_OBRIGAT := STC->TC_OBRIGAT
							(cPAD)->TC_MANUATI := STC->TC_MANUATI
							If lTipMod
								(cPAD)->TC_TIPMOD := cNGTIPMOD
							EndIf
							MsUnLock(cPAD)
							oTREE:TREESEEK(cOldCARGO)
						EndIf
					EndIf

					dbSelectArea("STC")
					STC->(RestArea(aArea))
					dbSkip()
				End
			EndIf

		Else
			dbSelectArea("STC")
			Dbsetorder( If( lSequeSTC,8,7 ) )
			If !lSequeSTC
				lBemFilho := dbSeek( xFilial( "STC" )+cSEQSTC )
			Else
				lBemFilho := dbSeek( xFilial( "STC" )+cCOMPONE )
			EndIf
			If lBemFilho

				While !Eof() .And. STC->TC_FILIAL == xFilial("STC") .And. STC->TC_SEQSUP == cSEQSTC

					aArea := STC->(GetArea())
					cCOMP := STC->TC_COMPONE
					cSEQ1 := STC->TC_SEQRELA
					cITEM := IF(ST6->(dbSeek(xFilial("ST6") + RTrim( cCOMP ) )),ST6->T6_NOME," ")
					cLOCA := STC->TC_LOCALIZ

					//se for pai de estrutura, adiciona subestrutura (considera que funcao e' recursiva)
					//nao pegando itens no meio de outras estruturas. No nivel 1 considera todos conforme TC_CODBEM
					If (ProcName(1) != "NGSEGTREE095" .And. Empty(STC->TC_SEQSUP)) .Or.;
					ProcName(1) == "NGSEGTREE095"

						dbSelectArea("STC")
						Dbsetorder( If( lSequeSTC,8,7 ) )
						If !lSequeSTC
							lBemFilho := dbSeek( xFilial( "STC" )+cSEQ1 )
						Else
							lBemFilho := dbSeek( xFilial( "STC" )+cCOMPONE )
						EndIf
						If lBemFilho
							//componente (filho) possui mais niveis abaixo
							NGSEGTREE095(cCOMP,Nil,cLOCA,cSEQ,nOPC,cSEQ1)
							oTREE:TREESEEK(cOldCARGO)
						Else
							//adiciona componente na arvore
							STC->(RestArea(aArea))

							cSEQ := fNextSeq(@cNextSeq)

							cCARGO := cCOMP+cSEQ+STC->TC_LOCALIZ
							cPRODESC := If(!Empty(cLOCA),cCOMP+' - '+Alltrim(cITEM)+' - '+cLOCA,cCOMP+' - '+cITEM)
							oTREE:ADDITEM(cPRODESC,cCARGO,"FOLDER5","FOLDER6",,,2)
							oTREE:TREESEEK(cCARGO)

							RecLock((cPad),.T.)
							(cPAD)->TC_FILIAL  := xFilial("STC")
							(cPAD)->TC_TIPOEST := M->TC_TIPOEST
							(cPAD)->TC_CODBEM  := STC->TC_CODBEM
							(cPAD)->TC_COMPONE := STC->TC_COMPONE
							(cPAD)->TC_SEQRELA := cSEQ
							(cPAD)->TC_SEQSUP  := cSEQSUP
							(cPAD)->TC_LOCALIZ := STC->TC_LOCALIZ
							(cPAD)->TC_DATAINI := dNGDATAEP
							(cPAD)->TC_CONTADO := STC->TC_CONTADO
							(cPAD)->TC_OBRIGAT := STC->TC_OBRIGAT
							(cPAD)->TC_MANUATI := STC->TC_MANUATI
							If lTipMod
								(cPAD)->TC_TIPMOD := cNGTIPMOD
							EndIf
							MsUnLock(cPAD)
							oTREE:TREESEEK(cOldCARGO)
						EndIf
					EndIf

					dbSelectArea("STC")
					STC->(RestArea(aArea))
					dbSkip()
				End
			EndIf
		EndIf

	ElseIf nOPC == 5

		//busca pelo item
		dbSelectArea(cPAD)
		dbSetOrder(05)
		dbSeek(cSEQ)
		cCARGO := (cPAD)->TC_COMPONE + (cPAD)->TC_SEQRELA + (cPAD)->TC_LOCALIZ
		aArea := (cPAD)->(GetArea())

		//busca pelos filhos do item
		dbSelectArea(cPAD)
		dbSetOrder(06)
		dbSeek(cSEQ)
		While (cPAD)->(!Eof()) .And. (cPAD)->TC_SEQSUP == cSEQ

			aArea2 := (cPAD)->(GetArea())
			cCOMP := (cPAD)->TC_COMPONE
			cSEQ1 := (cPAD)->TC_SEQRELA
			cSEQ2 := (cPAD)->TC_SEQSUP
			cITEM := IF(ST6->(Dbseek(xFILIAL("ST6") + RTrim( cCOMP ) )),ST6->T6_NOME," ")
			cLOCA := (cPAD)->TC_LOCALIZ

			dbSelectArea(cPAD)
			dbSetOrder(06)
			If dbSeek(cSEQ2)
				//recursivamente, acessa itens filhos
				NGSEGTREE095(cCOMP,cSEQ1,Nil,Nil,nOPC)
			EndIf

			(cPAD)->(RestArea(aArea2))
			(cPAD)->(dbSkip())
		EndDo

		//exclui item
		(cPAD)->(RestArea(aArea))
		RecLock((cPad),.F.)
		dbDelete()
		MsUnLock(cPAD)

		//deleta item da arvore
		oTREE:TREESEEK(cCARGO)
		oTREE:DELITEM()
		oTREE:REFRESH()

	EndIf

	DBENDTREE oTREE
	oTREE:REFRESH()
	oTREE:SETFOCUS()
	oDLG95:REFRESH()
	MNT095MOVE(EVAL(bCARGO),EVAL(bcSEQ)) //atualiza botoes na tela

Return NIL

//---------------------------------------------------------------------
/*/{Protheus.doc} ChkMod
Validacao do codigo do tipo modelo

@return Sempre Verdadeiro.

@param cNGTIPMOD, Caracter, Tipo do modelo da estrutura.

@sample ChkMod("         1")

@author
@since
/*/
//---------------------------------------------------------------------
Function ChkMod(cNGTIPMOD)

	Local aArea := GetArea()

	If lRel12133 .And. Trim(cNGTIPMOD) == '*'

		cDesMod := STR0055 // TODOS

	Else

		dbSelectArea("TQR")
		dbSetOrder(1)
		If !DbSeek(xFilial("TQR")+cNGTIPMOD)
			HELP(" ",1, "REGNOIS")
			Return .f.
		EndIf

		cDesMod := TQR->TQR_DESMOD

	EndIf

	oDesMod:Refresh()

	oBtn3:Enable()

	RestArea(aArea)

Return .T.

//---------------------------------------------------------------------
/*/{Protheus.doc} ChkPai
Validacao do codigo do bem pai

@return Sempre Verdadeiro.

@param cPai, Caracter, Código da estrutura pai.

@sample ChkPai("         1")

@author
@since
/*/
//---------------------------------------------------------------------
Function ChkPai(cPai)
	Local aArea := GetArea()

	dbSelectArea("ST6")
	dbSetOrder(01)
	If !ST6->(Dbseek(xFilial("ST6") + RTrim( cPai )))
		HELP(" ",1,"CODNEXIST")
		Return .F.
	EndIf

	cDESC := ST6->T6_NOME
	oDESC:REFRESH()

	If !lTipMod
		oBtn3:Enable()
	EndIf

	RestArea(aArea)
Return .t.

//---------------------------------------------------------------------
/*/{Protheus.doc} MenuDef
Utilizacao de Menu Funcional.

Parametros Parametros do array a Rotina:
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

@return aRotina, Array, Array com opcoes da rotina.

@sample MenuDef()

@author Rafael Diogo Richter
@since  02/02/2008
/*/
//---------------------------------------------------------------------
Static Function MenuDef()

	Local nTipPesq := If( "10" $ cVersao , 6 , 1 )//Quando versao 10, altera o tipo do MenuDef para 6 pois da problema com tipo 1 ( P.O.G. )

	Local aRotina := { { STR0002 , "MNT095PESQ"  , 0 , nTipPesq     } , ; //"Pesquisar"
					   { STR0003 , "NG095PROCES" , 0 , 2            } , ; //"Visualizar"
					   { STR0004 , "NG095PROCES" , 0 , 3            } , ; //"Incluir"
					   { STR0005 , "NG095PROCES" , 0 , 4        , 0 } , ; //"Alterar"
					   { STR0006 , "NG095PROCES" , 0 , 5        , 3 } }   //"Excluir"

Return aRotina

//---------------------------------------------------------------------
/*/{Protheus.doc} fNextSeq
Retorna a proxima sequencia disponivel p/ estrutura padrao.
Deve ser chamada sempre antes de criar uma nova sequencia.

@return cSeq, Caracter, Proxíma sequência a ser seguida.

@param cSeq, Caracter, Sequência atual.

@sample fNextSeq("001")

@author Felipe Nathan Welter
@since  16/02/11
/*/
//---------------------------------------------------------------------
Static Function fNextSeq(cSeq)

	Local cQuery := ""
	Local cAliasQry := GetNextAlias()

	If Empty(cSeq)
		cQuery += "SELECT MAX(STC.TC_SEQRELA) AS SEQRELA FROM "
		cQuery += RetSQLName("STC")+" STC "
		cQuery += " WHERE "
		cQuery += " STC.TC_TIPOEST = 'F'"
		cQuery += " AND STC.TC_FILIAL = "+ValToSQL(xFilial("STC"))
		cQuery += " AND STC.D_E_L_E_T_ <> '*' "

		cQuery := ChangeQuery(cQuery)
		dbUseArea( .T., "TOPCONN", TCGENQRY(,,cQuery),cAliasQry, .F., .T.)
		cSeq := If(!Empty((cAliasQry)->SEQRELA),(cAliasQry)->SEQRELA,Replicate('0',TAMSX3("TC_SEQRELA")[1]))
		(cAliasQry)->(dbCloseArea())
	EndIf

	cSeq := If(FindFunction("Soma1Old"),Soma1Old(cSeq),Soma1(cSeq))
	aAdd(aNewSeq,{cSeq,Nil})

Return cSeq

//---------------------------------------------------------------------
/*/{Protheus.doc} fTreeVazia
Verifica se a tree possui elementos.

@return lTreeVazia, Lógico,  Retorna se a arvore está vazia.

@sample fTreeVazia()

@author Robson Pereira
@since  20/01/12
/*/
//---------------------------------------------------------------------
Static Function fTreeVazia()
	Local lTreeVazia := .F.

	If oTree:Total() < 2
		lTreeVazia := .T.
		MsgStop(STR0048)//"Não foi adicionado nenhum componente à estrutura."
	EndIf

Return lTreeVazia
//---------------------------------------------------------------------
/*/{Protheus.doc} MNT95MTTRB
Alimenta o TRB utilizado no mBrowse
Uso MNTA095

@return

@sample
MNT95MTTRB()

@param cSeek - Indica se deve ou nao realiza busca no TRB apos monta-lo
nIndex - Indica qual sera o indice de pesquisa

@author Jackson Machado
@since 05/12/2012
@version 1.0
/*/
//---------------------------------------------------------------------
Static Function MNT95MTTRB( cSeek , nIndex )

	Local cQrySTC  := "" // Variavel que salva a query a se executada
	Local aArea    := STC->( GetArea() ) // Salva area da STC
	Local lST6     := .T. // Variavel de controle da existencia da ST6
	Local lTQR     := .T. // Variavel de controle da existencia da TQR

	Default cSeek  := ""
	Default nIndex := 1

	// Garante que TRB estara vazio
	dbSelectArea( cAliasSTC )
	ZAP

	// Variaveis utilizadas apenas para nao exibir mensagem de Warning
	lST6 := .T.
	lTQR := .T.

	//------------------------------------------------------------------------------------
	// Caso ambiente TOP, executa um query para selecionar todos os registros da STC
	// que seja do tipo de estrutura padrão (Família). Utiliza o agrupamento GROUP BY
	// para trazer um valor unico para cada estrutura.
	//------------------------------------------------------------------------------------
	cQrySTC := " SELECT STC.TC_FILIAL, STC.TC_CODBEM, ST6.T6_NOME AS TC_NOME"
	If lTipMod // Se tiver ambiente frota ou release for >= 12.1.33, traz o tipo modelo tambem
		cQrySTC += ", STC.TC_TIPMOD AS TC_TIPMOD, "

		cQrySTC += "CASE WHEN STC.TC_TIPMOD = '" + Padr( '*', Len( STC->TC_TIPMOD ) ) + "' THEN " +;
					ValToSQL( STR0055 ) + " ELSE TQR_DESMOD END AS TQR_DESMOD"

	EndIf
	cQrySTC += " FROM " + RetSqlName( "STC" ) + " STC "
	cQrySTC += " JOIN " + RetSqlName( "ST6" ) + " ST6 ON ST6.T6_CODFAMI = STC.TC_CODBEM "
	cQrySTC += "  AND ST6.D_E_L_E_T_ <> '*' AND "
	If FWModeAccess("ST6",3)  == "C"
		cQrySTC += NGMODCOMP("ST6","STC")
	Else
		cQrySTC += NGMODCOMP("STC","ST6")
	EndIf

	If lTipMod // Se tiver ambiente frota ou release for >= 12.1.33, faz JOIN com a tabela de tipo modelo
		cQrySTC += " LEFT JOIN " + RetSqlName( "TQR" ) + " TQR ON TQR.TQR_TIPMOD = STC.TC_TIPMOD "
		cQrySTC += "  AND TQR.D_E_L_E_T_ <> '*' AND "
		If FWModeAccess("TQR",3)  == "C"
			cQrySTC += NGMODCOMP("TQR","STC")
		Else
			cQrySTC += NGMODCOMP("STC","TQR")
		EndIf
	EndIf

	cQrySTC += " WHERE STC.TC_TIPOEST = 'F' AND "//Traz apenas registros que sejam de estrutura padrao
	cQrySTC += "  STC.TC_FILIAL = " + ValToSql( xFilial( "STC" ) ) + " "
	cQrySTC += "  AND STC.TC_CODBEM NOT IN ( SELECT STC.TC_COMPONE FROM " + RetSQLName( "STC" ) + " )"
	If lTipMod
		cQrySTC += " AND (TQR.TQR_DESMOD IS NOT NULL "
		If lRel12133
			cQrySTC += " OR RTRIM(STC.TC_TIPMOD) = '*' "
		EndIf
		cQrySTC += " ) "
	EndIf
	cQrySTC += "  AND STC.TC_SEQSUP = '' AND STC.D_E_L_E_T_ <> '*' "
	cQrySTC += "  GROUP BY STC.TC_FILIAL, STC.TC_CODBEM, ST6.T6_NOME"//Agrupa para trazer um registro unico por estrutura
	If lTipMod // Se tiver ambiente frota ou release for >= 12.1.33, GROUP BY necessita dos dois campos inclusos (TIPMOD e DESMOD)
		cQrySTC += ", STC.TC_TIPMOD, TQR.TQR_DESMOD "
	EndIf

	SqlToTRB( cQrySTC , aDBFSTC , cAliasSTC ) // Monta o TRB de acordo com o DBF e o retorno da query

	//----------------------------------------------------------
	// Não mostra estrutura no browse caso ela também seja PARTE de outra estrutura
	//----------------------------------------------------------
	DbSelectArea( cAliasSTC )
	DbGoTop()
	While !EoF()

		DbSelectArea( "STC" )
		DbSetOrder( 03 ) // TC_FILIAL+TC_COMPONE+TC_CODBEM
		If DbSeek( xFilial( "STC" ) + ( cAliasSTC )->TC_CODBEM )

			DbSelectArea( cAliasSTC )

			If !Empty( STC->TC_SEQSUP )
				RecLock( cAliasSTC,.F. )
				DbDelete()
				MsUnLock( cAliasSTC )
			EndIf

		EndIf

		DbSelectArea( cAliasSTC )
		DbSkip()

	End While

	// Caso variavel de Seek seja passada, posiciona no registro
	If !Empty( cSeek )
		dbSelectArea( cAliasSTC )
		dbSetOrder( nIndex )
		dbSeek( cSeek )
	EndIf

	// Reposiciona corretamente na STC
	dbSelectArea( "STC" )
	Set Filter To
	STC->( RestArea( aArea ) )

Return

//---------------------------------------------------------------------
/*/{Protheus.doc} MNT095PESQ
Monta Dialog de Janela para Pesquisa
Uso MNTA095

@return

@sample
MNT095PESQ( "TRB" , 1 , 1 )

@param  cAlias - Alias de Trabalho
nRec   - Recno posicionado
nOpcx  - Opção do MenuDef

@author Jackson Machado
@since 05/12/2012
@version 1.0
/*/
//---------------------------------------------------------------------
Function MNT095PESQ( cAlias , nRec , nOpcx )

	//Declaracao de variavies
	Local oDialog, oCbx, cOrd, oGet
	Local nOrd     := 1
	Local nIndex   := fPesqIndex()
	Local cCampo   := Space(40)
	Local lMenuDef := ( ProcName( 1 ) == "MBRBLIND" ) .Or. RunInMenuDef()//Define se foi chamado pelo MenuDef
	Local aOrd     := {}

	If ( cAlias )->( Eof() )//Caso esteja em final de arquivo, valida.
		If lMenuDef //Se for chamado via Menu Funcional exibe outra mensagem
			Help(" ",1,"ARQVAZIO")
		Else
			Help(" ",1,"A000FI")
		EndIf
		Return
	EndIf

	aOrd := fRetIndex( 2 ) //Seleciona o array descritivo dos indices
	cOrd := aOrd[ nIndex ]
	nOrd := nIndex

	//Monta a dialog
	DEFINE MSDIALOG oDialog FROM 00,00 TO 80,490 PIXEL TITLE OemToAnsi(STR0010)//"Pesquisa"

	//Monta o ComboBox com os indices
	oCbx := TComboBox():New( 05 , 05 , {|u| If(PCount() > 0, cOrd := u, cOrd)} , aOrd , 206 , 36 , oDialog , , ,;
	{|| nOrd := oCbx:nAt} , , , .T. , , , , {|| .T. } , , , , , "cOrd" )

	//Monta o get que ira receber o valor de pesquisa
	oGet := TGet():New( 22 , 05 , {|u| If(PCount() > 0, cCampo := u, cCampo)} , oDialog , 206 , 10 , "" , {|| .T. } , , , ,;
	.T. , , .T. , , .T. , , .F. , .F. , , .F. , .F. , , cCampo , , , , .T. )

	// Define os botoes
	// Caso confirme a tela, chama funcao para pesquisa, se retorar verdadeiro, fecha a tela
	SButton():New( 05 , 215 , 1 , {|| If(fPosiciona( cAlias , oCbx , cOrd , oGet , cCampo , nOrd ),oDialog:End(),) },;
	oDialog , .T. , /*cMsg*/ , /*bWhen*/ )
	// Caso cancele, apenas fecha a tela
	SButton():New( 20 , 215 , 2 , {|| oDialog:End() },;
	oDialog , .T. , /*cMsg*/ , /*bWhen*/ )

	ACTIVATE MSDIALOG oDialog CENTERED

Return
//---------------------------------------------------------------------
/*/{Protheus.doc} fPosiciona
Posiciona no registro selecionado
Uso MNTA095

@return Logico - Retorna verdadeiro caso posicione no registro e falso caso nao posicione

@sample
MNT095PESQ( "TRB" , oObj , "1" , oObj2 , "VEILEV" , 1 )

@param  cAlias - Alias de Trabalho
oCbx   - Objeto do ComboBox
cOrd   - Valor do Objeto do ComboBox
oGet   - Objeto do TGet
cCampo - Valor do Objeto do TGet
nOrd   - Ordem a ser posicionada na tabela

@author Jackson Machado
@since 05/12/2012
@version 1.0
/*/
//---------------------------------------------------------------------
Static Function fPosiciona( cAlias , oCbx , cOrd , oGet , cCampo , nOrd )

	Local lRet := .T.//Declara variavel de controle de retorno

	dbSelectArea( cAlias )//Posiciona no alias
	dbSetOrder( nOrd )//Posiciona no indice selecionado
	If !dbSeek( AllTrim( cCampo ) )//Realiza a pesquisa de acordo com o valor do GET
		//Caso nao encontre, mostra a mensagem
		ShowHelpDlg( STR0050 , { STR0051 } , 1 , ;//"Atenção"###"Nenhuma resultado foi encontrado."
		{ STR0052 } , 1 )//"Realize uma nova pesquisa."
		oGet:SetFocus()//Seta o foco no Get para realizacao de nova pesquisa
		lRet := .F.	//Altera variavel do controle de retorno para retornar falso
	EndIf

Return lRet
//---------------------------------------------------------------------
/*/{Protheus.doc} fRetIndex
Retorna os indices utilizados

@return Array - Retorna o indice utilizado de acordo com a necessidade

@sample fRetIndex( 1 )
@obs Uso MNTA095

@param  nType, Numérico, Indica o tipo de retorno
	1 - Indice para utilizacao
	2 - Descricao dos indices
	Caso nao seja definido retorna ambos
@param lAgluInd, Lógico, Aglutina os indices em uma unica linha.

@author Jackson Machado
@since 05/12/2012
@version 1.0
/*/
//---------------------------------------------------------------------
Static Function fRetIndex( nType , lAgluInd )

	// Declaracao de variavies
	Local nIndex   := 0 // Variavel de For
	Local aDesc    := {} // Array com as descricoes dos indices
	Local aIndex   := {} // Array com os indices
	Local aReturn  := {} // Array bidimencional contendo o array de descricoes e o array de indices
	Local aIndices := { { {"TC_FILIAL", "TC_CODBEM"} , STR0049+" + "+STR0007 } } // Indices utilizados###"Filial"###"Família"

	Default nType := 0 // Declara o tipo como 0 para retornar o aReturn completo
	Default lAgluInd := .F. // Não aglutina os indices em uma unica linha dentro do array.

	If lAgluInd
		aIndices   := { { "TC_FILIAL + TC_CODBEM" , STR0049+" + "+STR0007 } } // Indices utilizados###"Filial"###"Família"
	EndIf

	If lTipMod // Caso tiver ambiente frota, altera o indice para considerar tipo modelo
		If lAgluInd
			aIndices := { { "TC_FILIAL + TC_CODBEM + TC_TIPMOD" , STR0049+" + "+STR0007+" + "+STR0047 } , ;	// ###"Filial"###"Família"###"Tipo Modelo"
						  { "TC_FILIAL + TC_TIPMOD + TC_CODBEM" , STR0049+" + "+STR0047+" + "+STR0007 } }	// ###"Filial"###"Tipo Modelo"###"Família"
		Else
			aIndices := { { {"TC_FILIAL", "TC_CODBEM", "TC_TIPMOD"} , STR0049+" + "+STR0007+" + "+STR0047 } , ; // ###"Filial"###"Família"###"Tipo Modelo"
						  { {"TC_FILIAL", "TC_TIPMOD", "TC_CODBEM"} , STR0049+" + "+STR0047+" + "+STR0007 } }   // ###"Filial"###"Tipo Modelo"###"Família"
		EndIf
	EndIf

	For nIndex := 1 To Len( aIndices ) // Percorre o array de indices, adicionando os arrays secundarios
		aAdd( aIndex , aIndices[ nIndex , 1 ] ) // Adiciona os valores dos indices no array de indices
		aAdd( aDesc  , aIndices[ nIndex , 2 ] ) // Adiciona as descricoes dos indices no array de indices
	Next nIndex

	aReturn := { aIndex , aDesc } // Adiciona no array de retorno o array de valores dos indices e de descricoes dos indices
	aReturn := If( nType <> 0 , aClone( aReturn[ nType ] ) , aClone( aReturn ) ) // Caso tipo diferente de 0, retorna de acordo com a tipo informado

Return aReturn

//---------------------------------------------------------------------
/*/{Protheus.doc} fPesqIndex
Pesquisa o indice selecionado
Uso MNTA095

@return Numerico - Retorna o valor do indice selecionado

@sample
fPesqIndex()

@author Jackson Machado
@since 05/12/2012
@version 1.0
/*/
//---------------------------------------------------------------------
Static Function fPesqIndex()

	Local nIndex    := 1
	Local cIndexTRB := ( cAliasSTC )->( IndexKey() ) //Verifica qual o indice no exato momento no TRB
	Local aIndexTRB := fRetIndex( 1 , .T. )//Retorna todos os indices disponíveis no TRB
	Local aIndex    := {}

	//Realiza adequacao de espacos entre o indice
	cIndexTRB := StrTran(cIndexTRB,"+"," + ")

    If lTipMod
        aAdd(aIndex, aIndexTRB[1] )
        aAdd(aIndex, aIndexTRB[2] )
    Else
        aAdd(aIndex, aIndexTRB[1] )
    EndIf
	//Verifica se o indice esta nos indices de criacao
	nIndex    := aScan( aIndex , { |x| AllTrim( x ) == AllTrim( cIndexTRB ) } )

	//Caso nao localize o indice solicitado
	If nIndex == 0
		ShowHelpDlg( STR0050 , { STR0053 } , 1 , ;//"Atenção"###"Índice não encontrado."
							   { STR0054 } , 1 )  //"Contate o administrador do sistema."
		nIndex := 1
	Endif

Return nIndex

//---------------------------------------------------------------------
/*/{Protheus.doc} EachOther
Verifica se o pai é filho do componente em outra estrutura

@param cComponent, string, código do componente
@param cFather, string, código do pai
@author Maria Elisandra de Paula
@since 25/01/2021
@return boolean
/*/
//---------------------------------------------------------------------
Static Function EachOther( cComponent, cFather  )

	Local cAliasQry := GetNextAlias()
	Local lRet      := .F.

	BeginSql Alias cAliasQry

		SELECT COUNT( STC.TC_CODBEM ) TOTAL
		FROM %Table:STC% STC
		WHERE STC.TC_FILIAL = %xFilial:STC%
			AND STC.%Notdel%
			AND STC.TC_COMPONE = %Exp:cFather%
			AND STC.TC_CODBEM = %Exp:cComponent%

	EndSql

	lRet := (cAliasQry)->TOTAL > 0

	(cAliasQry)->( dbCloseArea() )

Return lRet
