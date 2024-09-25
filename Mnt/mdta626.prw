#INCLUDE "Protheus.ch"
#INCLUDE "MDTA626.ch"

//---------------------------------------------------------------------
/*/{Protheus.doc} MDTA626
Programa de  relacionamento EPI x Tarefa.

@author Guilherme Benkendorf
@since 24/01/14
@version 11
@return Nil
/*/
//---------------------------------------------------------------------
Function MDTA626()

//------------------------------------------------
// Armazena variaveis p/ devolucao (NGRIGHTCLICK)
//------------------------------------------------
Local aNGBEGINPRM := NGBEGINPRM()

Private aRotina := MenuDef( .F. )

//---------------------------------------------
// Define o cabecalho da tela de atualizacoes
//---------------------------------------------
Private cCadastro  := STR0001//"EPI x Tarefa"
Private aCHKDEL := {}, bNGGRAVA
Private cPrograma := "MDTA626"
//------------------------------------------------------------
// Faz validação da integridade do dicionario e base para TIK
//------------------------------------------------------------
If !NGCADICBASE("TIK_TAREFA","A","TIK",.F.)
	If !NGINCOMPDIC("UPDMDT93","TIIAGV")
		Return .F.
	Endif
Endif

aRotina := MenuDef( .F. )

DbSelectArea("TN5")
DbSetOrder(1)

mBrowse( 6, 1,22,75,"TN5")

//--------------------------------------------
// Devolve variaveis armazenadas (NGRIGHTCLICK)
//--------------------------------------------
NGRETURNPRM(aNGBEGINPRM)

Return .T.
//---------------------------------------------------------------------
/*/{Protheus.doc} MenuDef
Utilizacao de Menu Funcional.
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

@author Guilherme Benkendorf
@since 24/01/14
@version 11
@return Array com opcoes da rotina.
/*/
//---------------------------------------------------------------------
Static Function MenuDef( lMdi )
Local lSigaMdtPS := If( SuperGetMv("MV_MDTPS",.F.,"N") == "S", .t. , .f. )
Default lMdi   := .T.

aRotina :=  { { STR0002, "MDT626CAD" , 0 , 2},;   //"Visualizar"
              { STR0003, "MDT626CAD" , 0 , 4 , 3} } //"EPI"

If !lMdi .And. !lSigaMdtPS .And. AliasInDic("TY4") .And. SuperGetMv( "MV_NGMDTTR" , .F. , "2" ) == "1" ;
	.And. FindFunction( "MDTGERTRM" )

	aAdd( aRotina , { STR0016 , "MDTGERTRM" , 0 , 4 } )//"Treinamentos"

EndIf

Return aRotina

//---------------------------------------------------------------------
/*/{Protheus.doc} MDT626CAD
Função de relacionamento entre EPI x Tarefa.

@author Guilherme Benkendorf
@since 24/01/14
@version 11
@return Nil
/*/
//---------------------------------------------------------------------
Function MDT626CAD( cAls , nRegTN5 , nOpcx )

Local nOpca := 0
//Objetos de Tela
Local oDlgTIK
Local oPnlAll, oPnlTN5, oPnlTIK, oPnlButton
Local oGetTIK, oEnchTN5, oButtEPI
Local oMenuTIK

//Variaveis de tela
Local aInfo, aPosObj
Local aSize := MsAdvSize(,.f.,430), aObjects := {}
Local aNao, aChoice

//Variaveis de GetDados
Local aColsTIK := {}, aHeaderTIK := {}
Local lAltProg

dbSelectArea( "SB1" )
Set Filter To SB1->B1_FILIAL == xFilial("SB1") .And. NGSEEK("TN3", SB1->B1_COD, 2, "TN3_CODEPI") <> " "

If IsInCallStack("MDTA090")
	lAltProg := .T.
Else
	lAltProg := If(INCLUI .Or. ALTERA, .T.,.F.)
EndIf

//Verificação do nOpcx para o menudef personalizado
nOpcx := If(nOpcx == 1, 2, 4 )

nRegTIK := TIK->(Recno())
aRotSetOpc( "TIK" , @nRegTIK , 4 )

//Inicializa variaveis de Tela
Aadd(aObjects,{050,050,.t.,.t.})
Aadd(aObjects,{100,100,.t.,.t.})
aInfo   := {aSize[1],aSize[2],aSize[3],aSize[4],0,0}
aPosObj := MsObjSize(aInfo, aObjects,.t.)

//-----------------------
// Defino posição Tarefa
//-----------------------
nRegTN5 := TN5->( Recno() )
RegToMemory( "TN5", .F. )

//----------------------
// Carrea aCols/aHeader
//----------------------
fSearchTIK( nOpcx, @aColsTIK, @aHeaderTIK )

DEFINE MSDIALOG oDlgTIK TITLE STR0001 From aSize[7],0 To aSize[6],aSize[5] OF oMainWnd PIXEL   //"EPI x Tarefa"
	//Panel criado para correta disposicao da tela
	oPnlPai := TPanel():New( , , , oDlgTIK , , , , , , , , .F. , .F. )
		oPnlPai:Align := CONTROL_ALIGN_ALLCLIENT

		//Painel - Parte Superior ( Cabeçalho )
		oPnlTN5 := TPanel():New( , , , oPnlPai , , , , , , , aSize[ 6 ] / 6 , .F. , .F. )
		   	oPnlTN5:Align := CONTROL_ALIGN_TOP
			//Enchoice da TN5
			aNao := {"TN5_VESSYP"}
			aChoice := NGCAMPNSX3("TN5",aNao)
			oEnchTN5 := MsmGet():New( "TN5" , nRegTN5 , 2 , , , , aChoice , { 12 , 0 , aSize[ 6 ] / 2 , aSize[ 5 ] / 2 } , ,  , /**/ , , , oPnlTN5 )
			oEnchTN5:Disable()
			oEnchTN5:oBox:Align := CONTROL_ALIGN_ALLCLIENT

		//Painel - Parte Intermediária ( Botão de Importação )
		oPnlBtn := TPanel():New( , , , oPnlPai , , , , , , , 15 , .F. , .F. )
	   		oPnlBtn:Align := CONTROL_ALIGN_TOP

			//Botão de listagem, em MarkBrowse, dos EPI
			oButtEPI := TButton():New( 2 , 5 , "&"+STR0003, oPnlBtn, {|| MDT626BU(@oGetTIK) } , 49 , 12 ,, /*oFont*/,,.T.,,,,{|| nOpcx <> 2 },,)

		oPnlTIK := TPanel():New(0, 0, Nil, oPnlPai, Nil, .T., .F., Nil, Nil, 0, 60, .T., .F. )
			oPnlTIK:Align := CONTROL_ALIGN_ALLCLIENT

					//GetDados da TIK - Tarefa x Epi
		PutFileInEof("TIK")
		oGetTIK := MsNewGetDados():New(0,0,200,210,IIF(!lAltProg,0,GD_INSERT+GD_UPDATE+GD_DELETE),;
	 								{|| MDT626Lin("TIK",,@oGetTIK)},{|| MDT626Lin("TIK",.T.,@oGetTIK)},/*cIniCpos*/,/*aAlterGDa*/,;
	   								/*nFreeze*/,/*nMax*/,/*cFieldOk */,/*cSuperDel*/,/*cDelOk */,oPnlTIK,aHeaderTIK,aColsTIK)
		oGetTIK:oBrowse:Align := CONTROL_ALIGN_ALLCLIENT

		// Ordena por código de EPI
		aSort(oGetTIK:aCOLS,,,{ |x, y| x[1] < y[1] })

ACTIVATE MSDIALOG oDlgTIK ON INIT EnchoiceBar(oDlgTIK, {|| nOpca:=1,If(MDT626TOk(@oGetTIK), oDlgTIK:End(), nOpca := 0)},;
																					{|| oDlgTIK:End(),nOpca := 0})

If nOpca == 1
	fGravaTIK(@oGetTIK)//Grava EPI x Tarefas
Endif

Return .T.
//---------------------------------------------------------------------
/*/{Protheus.doc} MDT626BU
Mostra um markbrowse com todos os EPI para poder seleciona-los de uma
 so vez.

@author Guilherme Benkendorf
@since 27/01/14
@version MP11
@return Nil
/*/
//---------------------------------------------------------------------
Static Function MDT626BU( oGetTIK )
Local aArea := GetArea()
//Variaveis para montar TRB
Local aDBF,aTRBEPI
//Variaveis de Tela
Local oDlgEPI
//Varivaeis operacionais
Local cKeyEPI   := "", cResultEPI := Space(60)
Local aEPICombo := {STR0003,STR0004,STR0005}//"EPI"##"Descrição"##"Marcados"
Local oEPICombo
Local oPanelEpi
Local oButtonEPI
Local oGetEPI
Local oMarkEPI
Local oTempTRB

Local nOpcao
Local lInverte, lRet
Local cTRBEPI := GetNextAlias()

Private cMarca := GetMark()

lInverte:= .f.

//Valores e Caracteristicas da TRB
aDBF := {}
AADD(aDBF,{ "TRB_OK"    , "C" ,02                  , 0 })
AADD(aDBF,{ "TRB_CODIGO", "C" ,TamSX3("B1_COD")[1] , 0 })
AADD(aDBF,{ "TRB_DESC"  , "C" ,TamSX3("B1_DESC")[1], 0 })

aTRBEPI := {}
AADD(aTRBEPI,{ "TRB_OK"    ,NIL," "	  	,})
AADD(aTRBEPI,{ "TRB_CODIGO",NIL,STR0003,})  //"EPI"
AADD(aTRBEPI,{ "TRB_DESC"  ,NIL,STR0004	,})  //"Descrição"

//Cria TRB
oTempTRB := FWTemporaryTable():New( cTRBEPI, aDBF )
oTempTRB:AddIndex( "1", {"TRB_CODIGO"} )
oTempTRB:AddIndex( "2", {"TRB_DESC"} )
oTempTRB:AddIndex( "3", {"TRB_OK"} )
oTempTRB:Create()

dbSelectArea("SB1")

Processa({|lEnd| fSearchEPI( cTRBEPI , oGetTIK )},STR0006,STR0007)//"Buscando EPI..."//"Espere"
Dbselectarea(cTRBEPI)
Dbgotop()
If (cTRBEPI)->(Reccount()) <= 0
	dbSelectArea(cTRBEPI)
	oTempTRB:Delete()
	RestArea(aArea)
	Msgstop(STR0008, STR0009 )  //"Não existem EPI cadastrados" //"ATENÇÃO"
	Return .T.
Endif

nOpcao := 0

DEFINE MSDIALOG oDlgEPI TITLE OemToAnsi(STR0003) From 150,0 To 710,550 PIXEL OF oMainWnd //"EPI"

oPanelEpi		:= TPanel():New(,,,oDlgEPI,,,,,,,, .F., .F. )
oPanelEpi:Align	:= CONTROL_ALIGN_ALLCLIENT

	TGroup():New(8, 8, 40, 270, , oPanelEpi, , , .T.)
	TSay():New(16,12,{|| OemtoAnsi(STR0010) },oPanelEpi,,,.F.,.F.,.F.,.T.,CLR_BLACK,CLR_WHITE,200,010)//"Estes são os EPI's cadastrados no sistema."
	TSay():New(26,12,{|| OemtoAnsi(STR0011) },oPanelEpi,,,.F.,.F.,.F.,.T.,CLR_BLACK,CLR_WHITE,200,010)//"Selecione aqueles que são necessários a tarefa."


	//Campo combo de indice para busca
	oEPICombo := TComboBox():New( 45, 5, {|u| if( Pcount()>0, cKeyEPI:= u, cKeyEPI ) }, aEPICombo,;
												 190, 10, oPanelEpi, ,{|| MDT626OrEP( @oEPICombo , @oGetEPI, @oMarkEPI, cTRBEPI ) },/*bValid*/,/*nClrBack*/,CLR_BLACK,;
												 .T., /*oFont*/, , ,/*bWhen*/, , , , , cKeyEPI, /*cLabelText*/ ,/*nLabelPos*/, /*oLabelFont*/, CLR_BLACK  )
	//Campo de busca
	oGetEPI := TGet():New( 58, 5, {|u| if( Pcount()>0, cResultEPI:= u, cResultEPI ) }, oPanelEpi, 190, 7, "@!",;
	 										/*bValid*/, CLR_BLACK, /*nClrBack*/, /*oFont*/, , , .T., , , {|| oEPICombo:nAt <> 3 },;
	 										, , /*bChange*/,/*lReadOnly*/,/*lPassword*/ , , cResultEPI, , , , /*lHasButton*/,;
	 										/*lNoButton*/, /*cLabelText*/ ,/*nLabelPos*/, /*oLabelFont*/, /*nLabelColor*/  )
	//Botão de pesquisa
	oButtonEPI := TButton():New( 44, 200, STR0012, oPanelEpi, {|| If(oEPICombo:nAt <> 3, fSeaEPI626( @oEPICombo , @oGetEPI, @oMarkEPI, cTRBEPI ), .T.) },;
												73, 12,	, /*oFont*/, , .T., , , , {|| oEPICombo:nAt <> 3  }, , )//"Pesquisar"

	oMarkEPI:= MsSelect():NEW(cTRBEPI,"TRB_OK",,aTRBEPI,@lINVERTE,@cMARCA,{73,5,267,272},,,oPanelEpi)
	oMarkEPI:bMARK               := {|| MDT626MK(cMarca, cTRBEPI, @oEPICombo, @oMarkEPI)}
	oMarkEPI:oBROWSE:lHASMARK    := .T.
	oMarkEPI:oBROWSE:lCANALLMARK := .T.
	oMarkEPI:oBROWSE:bALLMARK    := {|| MDT626INV(cTRBEPI , cMarca) }

ACTIVATE MSDIALOG oDlgEPI ON INIT EnchoiceBar(oDlgEPI,{|| nOpcao := 1,oDlgEPI:End()},{|| nOpcao := 2,oDlgEPI:End()}) Centered

lRet := ( nOpcao == 1 )

If lRet
	MDT626CPY(@oGetTIK,cTRBEPI)//Funcao para copiar planos a GetDados
Endif

dbSelectArea(cTRBEPI)
oTempTRB:Delete()

RestArea(aArea)

Return lRet
//------------------------------------------------------
/*/{Protheus.doc} MDT626OrEP()
Função de ordenação para o MarkBrose conforme selecionado
no ComboBox

oCombo - Objeto do comboBox
oGet   - Objeto do campo Get
oMark  - Objeto do MarkBrowse

@author  Guilherme Benkendorf
@since   27/01/2014
@version MP11
@return  Logico
/*/
//------------------------------------------------------
Static Function MDT626OrEP( oCombo, oGet, oMark, cAliasTRB )
Local nIndEPI

nIndEPI := oCombo:nAt
//Ordena TRB conforme selecionado no combo
dbSelectArea(cAliasTRB)
dbSetOrder(nIndEPI)
dbGoTop()
//Caso for marcação, limpa Get
If nIndEPI == 3 //TRB_OK
	oGet:cText	:= Space(60)
EndIf

oMark:oBrowse:Refresh()

Return .T.
//------------------------------------------------------
/*/{Protheus.doc} fSeaEPI626()
Função de busca do EPI para o Mark Browse

oCombo - Objeto do comboBox
oGet   - Objeto do campo Get
oMark  - Objeto do MarkBrowse

@author  Guilherme Benkendorf
@since   27/01/2014
@version MP11
@return  Logico
/*/
//------------------------------------------------------
Static Function fSeaEPI626( oCombo , oGet , oMark, cAliasTRB )
Local lRet
Local nInd
Local cResult

lRet    := .T.
nInd    := oCombo:nAt
cResult := AllTrim(oGet:cText)

dbSelectArea(cAliasTRB)
dbSetOrder(nInd)

If ! ( lRet := dbSeek( cResult ) )
	MsgInfo( STR0013 , STR0009 )//"Valor não encontrado."##"ATENÇÃO"
	(cAliasTRB)->(dbGoTop())
Else
	oMark:oBrowse:SetFocus()//Se encontra resultado, focaliza tela do mark
EndIf

Return lRet
//---------------------------------------------------------------------
/*/{Protheus.doc} fSearchTIK
Efetua a busca dos EPI, na TIK, relacionados a Tarefa posicionada
 no Browse

@author Guilherme Benkendorf
@since 27/01/14
@version MP11
@return Nil
/*/
//---------------------------------------------------------------------
Static Function fSearchTIK( nOpcx, aCols , aHeader )
Local aAreaTIK  := GetArea()
//Variaveis de inicializacao de GetDados
Local aNoFields := {}
Local nInd
Local cKeyGet
Local cWhileGet

// Monta a GetDados
aAdd(aNoFields , "TIK_FILIAL" )
aAdd(aNoFields , "TIK_TAREFA" )

nInd      := 1
cKeyGet   := "TN5->TN5_CODTAR"
cWhileGet := "TIK->TIK_FILIAL == '" + xFilial( "TIK" ) + "' .AND. TIK->TIK_TAREFA == '" + &cKeyGet + "'"

//Monta aCols e aHeader de TIK
dbSelectArea("TIK")
dbSetOrder(nInd)

FillGetDados( nOpcx, "TIK", 1, cKeyGet, {|| cKeyGet }, {|| .T.},aNoFields,,,,;
					 {|| NGMontaAcols("TIK",&cKeyGet,cWhileGet)},,aHeader , aCols )

If Empty(aCols)
	aCols := BLANKGETD(aHeader)
Endif

RestArea( aAreaTIK )

Return .T.
//---------------------------------------------------------------------
/*/{Protheus.doc} MDT626CPY
Copia os planos selecionados no markbrowse para a GetDados.

@author Guilherme Benkendorf
@since 31/01/13
@version MP10/11
@return Nil
/*/
//---------------------------------------------------------------------
Static Function MDT626CPY(oGetTIK,cAliasTRB)
Local nCols, nPosCod
Local aColsOk := aClone(oGetTIK:aCols)
Local aHeadOk := aClone(oGetTIK:aHeader)
Local aColsTp := BLANKGETD(aHeadOk)

//Procura posicionamento de EPI e Descrição no aHeader
nPosCod := aScan( aHeadOk,{|x| Trim(Upper(x[2])) == "TIK_EPI"})
nPosDes := aScan( aHeadOk,{|x| Trim(Upper(x[2])) == "TIK_DESEPI"})
//Deleta do aColsOk os registros - não marcados/não encontrado
For nCols := Len(aColsOk) To 1 Step -1
	dbSelectArea(cAliasTRB)
	dbSetOrder(1)
	If !dbSeek(aColsOK[nCols,nPosCod]) .OR. Empty((cAliasTRB)->TRB_OK)
		aDel(aColsOk,nCols)
		aSize(aColsOk,Len(aColsOk)-1)
	EndIf
Next nCols

//Grava no aCols os registros que estejam marcados e que não estejam no aCols
dbSelectArea(cAliasTRB)
dbGoTop()
While (cAliasTRB)->(!Eof())
	If !Empty((cAliasTRB)->TRB_OK) .AND. aScan( aColsOk , {|x| x[nPosCod] == (cAliasTRB)->TRB_CODIGO } ) == 0
		aAdd(aColsOk,aClone(aColsTp[1]))
		aColsOk[Len(aColsOk),nPosCod] := (cAliasTRB)->TRB_CODIGO
		aColsOk[Len(aColsOk),nPosDes] := (cAliasTRB)->TRB_DESC
	EndIf
	(cAliasTRB)->(dbSkip())
End

If Len(aColsOK) <= 0
	aColsOK := aClone(aColsTp)
EndIf
//Ordena por Código do EPI, copia aColsOK para a GetDados e executa refresh no objeto
aSort(aColsOK,,,{ |x, y| x[1] < y[1] })
oGetTIK:aCols := aClone(aColsOK)
oGetTIK:oBrowse:Refresh()
Return .T.
//---------------------------------------------------------------------
/*/{Protheus.doc} MDT626MK
Efetua Ações na marcações do MarkBrowse.

@author Guilherme Benkendorf
@since 31/01/13
@version MP10/11
@return Nil
/*/
//---------------------------------------------------------------------
Function MDT626MK( cMarca , cAliasTRB , oCombo , oMark )
Local nIndEPI

nIndEPI := oCombo:nAt
// Ordena o marcado quando for o indice 3 - Marcado
If nIndEPI == 3
	dbSelectArea( cAliasTRB )
	dbSetOrder( nIndEPI )
	//Atualiza tela do Mark, para exibir a ordem
	oMark:oBrowse:Refresh()
EndIf

Return .T.
//---------------------------------------------------------------------
/*/{Protheus.doc} MDT626INV
Inverte a marcacao do browse.

@author Guilherme Benkendorf
@since 27/01/14
@version 11
@return Nil
/*/
//---------------------------------------------------------------------
Function MDT626INV(cAliasTRB, cMARCA)
Local aArea := (cAliasTRB)->(GetArea())

Dbselectarea(cAliasTRB)
dbSetOrder(1)
dbGoTop()
While !Eof()
	(cAliasTRB)->TRB_OK := IF(Empty((cAliasTRB)->TRB_OK),cMARCA,Space(Len(cMARCA)))
	dbSelectArea(cAliasTRB)
	( cAliasTRB )->( dbSkip() )
End

RestArea(aArea)
Return .T.
//---------------------------------------------------------------------
/*/{Protheus.doc} fGravaTIK
Funcao para gravar dados da MsNewGetDados,
Plano Emergenciais na TJA

@author Guilherme Benkendorf
@since 31/01/13
@version MP10/11
@return Nil
/*/
//---------------------------------------------------------------------
Static Function fGravaTIK( oGet )

Local aArea := GetArea()
Local i, j, ny, nPosCod
Local nOrd, cKey, cWhile
Local aColsOk := aClone(oGet:aCols)
Local aHeadOk := aClone(oGet:aHeader)

nPosCod := aScan( aHeadOk,{|x| Trim(Upper(x[2])) == "TIK_EPI"})
nOrd 	:= 1
cKey 	:= xFilial("TIK")+TN5->TN5_CODTAR
cWhile  := "xFilial('TIK') == TIK->TIK_FILIAL .And. TIK->TIK_TAREFA == TN5->TN5_CODTAR"

If Len(aColsOK) > 0
//Coloca os deletados por primeiro
	aSORT(aColsOK,,, { |x, y| x[Len(aColsOK[1])] .and. !y[Len(aColsOK[1])] } )

	For i:=1 to Len(aColsOK)
		If !aColsOK[i][Len(aColsOK[i])] .And. !Empty(aColsOK[i][nPosCod])
			dbSelectArea("TIK")
			dbSetOrder(nOrd)
			If dbSeek( cKey + aColsOK[i][nPosCod])
				RecLock("TIK",.F.)
			Else
				RecLock("TIK",.T.)
			Endif
			For j:=1 to FCount()
				If "_FILIAL"$Upper(FieldName(j))
					FieldPut( j , xFilial("TIK"))
				ElseIf "_TAREFA"$Upper(FieldName(j))
					FieldPut( j , TN5->TN5_CODTAR )
				ElseIf (nPos := aScan(aHeadOk, {|x| Trim(Upper(x[2])) == Trim(Upper(FieldName(j))) }) ) > 0
					FieldPut( j , aColsOK[i,nPos])
				Endif
			Next j
			MsUnlock("TIK")
		Elseif !Empty(aColsOK[i][nPosCod])
			dbSelectArea("TIK")
			dbSetOrder(nOrd)
			If dbSeek(cKey+aColsOK[i][nPosCod])
				RecLock("TIK",.F.)
				dbDelete()
				MsUnlock("TIK")
			Endif
		Endif
	Next i
Endif

//Exclui items marcados como deletedos na GetDados
dbSelectArea("TIK")
dbSetOrder(nOrd)
dbSeek(cKey)
While !Eof() .and. &(cWhile)
	If aScan( aColsOK,{|x| x[nPosCod] == TIK->TIK_EPI .AND. !x[Len(x)]}) == 0
		RecLock( "TIK" , .F. )
		DbDelete()
		MsUnLock( "TIK" )
	Endif
	dbSelectArea( "TIK" )
	dbSkip()
End


RestArea(aArea)

Return .T.
//---------------------------------------------------------------------
/*/{Protheus.doc} MDT626Lin
Valida linhas do MsNewGetDados dos Planos Emergenciais.

@author Guilherme Benkendorf
@since 27/01/14
@version MP11
@return Nil
/*/
//---------------------------------------------------------------------
Function MDT626Lin(cAlias,lFim,oGet)
Local nX
Local aColsOk := {}, aHeadOk := {}
Local nPosCod := 1, nAt := 1
Local nCols
Default lFim := .F.

aColsOk := aClone(oGet:aCols)
aHeadOk := aClone(oGet:aHeader)
nAt     := oGet:nAt

If cAlias == "TIK"
	nPosCod := aScan( aHeadOk,{|x| Trim(Upper(x[2])) == "TIK_EPI"})
	If lFim
		If Len(aColsOk) == 1 .AND. Empty(aColsOk[1][nPosCod])
			Return .T.
		EndIf
	EndIf
EndIf

//Percorre aCols
For nX:= 1 to Len(aColsOk)
	If !aColsOk[nX][Len(aColsOk[nX])]
		If lFim .or. nX == nAt
			//VerIfica se os campos obrigatórios estão preenchidos
			If Empty(aColsOk[nX][nPosCod])
				//Mostra mensagem de Help
				Help(1," ","OBRIGAT2",,aHeadOk[nPosCod][1],3,0)
				Return .F.
			Endif
		Endif
		//Verifica se é somente LinhaOk
		If nX <> nAt .and. !aColsOk[nAt][Len(aColsOk[nAt])]
			If aColsOk[nX][nPosCod] == aColsOk[nAt][nPosCod]
				Help(" ",1,"JAEXISTINF",,aHeadOk[nPosCod][1])
				Return .F.
			Endif
		Endif
	Endif
Next nX

PutFileInEof("TIK")

Return .T.
//---------------------------------------------------------------------
/*/{Protheus.doc} MDT626TOk
Função para verificar toda a MsNewGetdados.

@author Guilherme Benkendorf
@since 27/01/14
@version MP11
@return Nil
/*/
//---------------------------------------------------------------------
Function MDT626TOk(oGet)

If !MDT626Lin("TIK",.T.,oGet)
	Return .F.
Endif

Return .T.

//---------------------------------------------------------------------
/*/{Protheus.doc} fSearchEPI
Funcao para retornar todos os EPI.

@author Guilherme Benkendorf
@since 27/01/14
@version MP11
@return Nil
/*/
//---------------------------------------------------------------------
Static Function fSearchEPI( cAliasTRB, oGetTIK )

	//Salva a área
	Local aArea := GetArea()
	
	//Variáveis de tabelas temporárias
	Local cAliasSB1	:= GetNextAlias()
	
	//Busca as informações do mark
	Local aColsOK := aClone( oGetTIK:aCols )
	Local aHeadOk := aClone( oGetTIK:aHeader )

	//Variáveis de busca das informações
	Local nPosCod  := aScan( aHeadOk, { |x| Trim( Upper( x[2] ) ) == "TIK_EPI" } )
	Local cMDTEPI  := SuperGetMV( "MV_MDTPEPI", .F., "" )
	Local aTipEPI  := Strtokarr2( cMDTEPI, ";" )
	Local lSX5	   := !Empty( cMDTEPI )
	Local cVirgula := ", "
	Local cStrEPI  := ""
	Local cVldEPI  := "%%"
	Local nCont	   := 0

	//Caso deva validar o conteúdo do parâmetro MV_MDTEPI
	If lSX5

		//Percorre os EPI's definidos no array
		For nCont := 1 To Len( aTipEPI )

			If nCont == Len( aTipEPI )
				cVirgula := ""
			EndIf

			cStrEPI += "'" + aTipEPI[ nCont ] + "'" + cVirgula

		Next nCont

		//Adiciona a validação para utilização na query
		cVldEPI := '% AND SB1.B1_TIPO IN (' + cStrEPI + ') %'

	EndIf

	BeginSQL Alias cAliasSB1

		SELECT
			SB1.B1_COD, SB1.B1_DESC
		FROM
			%Table:SB1% SB1
		INNER JOIN %Table:TN3% TN3 ON
			TN3.TN3_FILIAL = %xFilial:TN3% AND
			TN3.TN3_CODEPI = SB1.B1_COD AND
			TN3.%NotDel%
		WHERE
			SB1.B1_FILIAL = %xFilial:SB1% AND
			SB1.B1_MSBLQL <> '1' AND
			SB1.%NotDel%
			%Exp:cVldEPI%
		GROUP BY SB1.B1_COD, SB1.B1_DESC

	EndSQL

	//Posiciona na tabela da query para add os registros no TRB
	dbSelectArea( cAliasSB1 )
	( cAliasSB1 )->( dbGoTop() )
	
	//Percorre os registros add na tabela temporária
	While ( cAliasSB1 )->( !Eof() )

		//Salva o registro na tabela temporária
		RecLock( cAliasTRB, .T. )
			( cAliasTRB )->TRB_OK     := IIf( aScan( aColsOk, { |x| x[ nPosCod ] == ( cAliasSB1 )->B1_COD } ) > 0, cMarca, " " )
			( cAliasTRB )->TRB_CODIGO := ( cAliasSB1 )->B1_COD
			( cAliasTRB )->TRB_DESC   := ( cAliasSB1 )->B1_DESC
		( cAliasTRB )->( MsUnLock() )

		//Pula para o próximo registro
		( cAliasSB1 )->( dbSkip() )

	End

	//Fecha a tabela temporária
    ( cAliasSB1 )->( dbCloseArea() )

	//Retorna a área
	RestArea( aArea )

Return

//---------------------------------------------------------------------
/*/{Protheus.doc} MDT626EPI
Função de validação do código EPI, verifica se é um EPI e se esta
 relacionado a um fornecedor.

@author Guilherme Benkendorf
@since 27/01/14
@version MP11
@return lRet
@Usado: TIK_EPI
/*/
//---------------------------------------------------------------------
Function MDT626EPI( cCodEPI )
Local aAreaEPI:= GetArea()
Local cMDTEPI := SuperGetMV("MV_MDTPEPI",.F.,"")
Local lSX5    := !Empty( cMDTEPI )
Local lRet    := .T.

lRet := If( lRet, MDTProEpi( cCodEPI , cMDTEPI , lSX5 ), lRet )

dbSelectArea("TN3")
dbSetOrder( 2 ) //TN3_FILIAL+TN3_CODEPI
If lRet .And. !dbSeek( xFilial("TN3") + cCodEPI)
		ShowHelpDlg( "EPIINV", {STR0014} ,1,;//"Código EPI inválido."
											{STR0015},2)//"É necessário ter um fornecedor para o EPI."
		lRet := .F.
EndIf

RestArea(aAreaEPI)

Return lRet
