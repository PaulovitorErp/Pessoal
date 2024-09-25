#INCLUDE "MDTA223.ch"
#INCLUDE "Protheus.ch"

#DEFINE _nVERSAO 2 //Versao do fonte
//---------------------------------------------------------------------
/*/{Protheus.doc} MDTA223
Programa de  Registro dos Programas de Saúde nos Laudos.

@author Bruno L. Souza
@since 15/04/13
@version MP10/11
@return Nil
/*/
//---------------------------------------------------------------------
Function MDTA223()

//#########################################################################
//## Armazena variaveis p/ devolucao (NGRIGHTCLICK) 					 ##
//#########################################################################
Local aNGBEGINPRM := NGBEGINPRM(_nVERSAO)
Private lSigaMdtPS := If( SuperGetMv("MV_MDTPS",.F.,"N") == "S", .t. , .f. )
Private aRotina := MenuDef(lSigaMdtPS)
//################################################################
//## Define o cabecalho da tela de atualizacoes                 ##
//################################################################
Private cCadastro  := STR0001 //"Laudos x Equipamentos Radioativos"
Private aCHKDEL := {}, bNGGRAVA
Private cPrograma := "MDTA223"
Private cCliMdtPs

If !NGCADICBASE("TIA_LAUDO","A","TIA",.F.)
	If !NGINCOMPDIC(If (lSigaMdtPS,"UPDMDTPS","UPDMDT68"))
		Return .F.
	Endif
Endif 

//Se for prestador de serviço
If lSigaMdtPS
	DbSelectArea("SA1")
	DbSetOrder(1)    
	mBrowse( 6, 1,22,75,"SA1")
Else
	MDT223CAD()
Endif

//#########################################################################
//## Devolve variaveis armazenadas (NGRIGHTCLICK) 					  	 ##
//#########################################################################
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

@author Bruno L. Souza
@since 15/04/13
@version MP10/11
@return Array com opcoes da rotina. 
/*/
//---------------------------------------------------------------------
Static Function MenuDef(lPres)

Local aRotina
Default lPres := .F.

If lPres
	aRotina :=	{ { STR0002, "AxPesqui"  , 0 , 1},;  //"Pesquisar"
                  { STR0003, "NGCAD01"   , 0 , 2},;  //"Visualizar"
                  { STR0004, "MDT223CAD" , 0 , 4} }  //"Laudo"
Else
	aRotina :=  { { STR0002, "AxPesqui"  , 0 , 1},;   //"Pesquisar"
                  { STR0003, "NGCAD01"   , 0 , 2},;   //"Visualizar"
                  { STR0005, "MDT223PS"  , 0 , 4, 3} } //"Programa de Saúde"
Endif

Return aRotina

//---------------------------------------------------------------------
/*/{Protheus.doc} MDT223CAD
Monta um browse dos laudos.

@author Bruno L. Souza
@since 15/04/13
@version MP10/11
@return Nil
/*/
//---------------------------------------------------------------------
Function MDT223CAD()

Local aArea := GetArea()
Local cOldCad := cCadastro

aRotina := MenuDef()

DbSelectArea("TO0")
//Se for prestador de serviço faz filtro de laudos por cliente
If lSigaMdtPS
	Set Filter To TO0->TO0_CLIENT+TO0->TO0_LOJA == SA1->A1_COD+SA1->A1_LOJA
	cCliMdtPs := SA1->A1_COD+SA1->A1_LOJA
Endif
DbSetOrder(1)

mBrowse( 6, 1,22,75,"TO0")

RestArea(aArea)
cCadastro := cOldCad

Return .T.

//---------------------------------------------------------------------
/*/{Protheus.doc} MDT223PS
Monta um browse dos Programas de Saúde.

@author Bruno L. Souza
@since 17/04/13
@version MP10/11
@return Nil
/*/
//---------------------------------------------------------------------
Function MDT223PS( cAlias , nReg, nOpcx )
//Objetos de Tela
Local oDlgPS, oPnlPS
Local oGetPS
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
Private aCols := {}, aHeader := {}

aRotSetOpc( "TIA" , 1 , 4 )

//Inicializa variaveis de Tela
Aadd(aObjects,{050,050,.t.,.t.})
Aadd(aObjects,{100,100,.t.,.t.})
aInfo   := {aSize[1],aSize[2],aSize[3],aSize[4],0,0}
aPosObj := MsObjSize(aInfo, aObjects,.t.)

// Monta a GetDados dos Requisitos Legais
aAdd(aNoFields,"TIA_LAUDO")
aAdd(aNoFields,"TIA_FILIAL")
nInd	  := 1
cKeyGet   := "TO0->TO0_LAUDO"
cWhileGet := "TIA->TIA_FILIAL == '"+xFilial("TIA")+"' .AND. TIA->TIA_LAUDO == '"+TO0->TO0_LAUDO+"'"

//Monta aCols e aHeader de TIA
dbSelectArea("TIA")
dbSetOrder(nInd)
FillGetDados( nOpcx, "TIA", 1, cKeyGet, {|| }, {|| .T.},aNoFields,,,,;
					{|| NGMontaAcols("TIA",&cKeyGet,cWhileGet)})
If Empty(aCols)
	aCols := BLANKGETD(aHeader)
Endif

nOpca := 0

DEFINE MSDIALOG oDlgPS TITLE STR0001 From aSize[7],0 To aSize[6],aSize[5] OF oMainWnd PIXEL   //"Laudo x Programas de Saúde"

	oPnlPS := TPanel():New(0, 0, Nil, oDlgPS, Nil, .T., .F., Nil, Nil, 0, 60, .T., .F. )
		oPnlPS:Align := CONTROL_ALIGN_TOP
        
        TSay():New( 6 , 7 ,{| | OemtoAnsi(STR0006) },oPnlPS,,,.F.,.F.,.F.,.T.,CLR_BLACK,CLR_WHITE,020,008)//"Laudo"
		TGet():New( 5 , 27,{|u| If( PCount() > 0 , TO0->TO0_LAUDO := u , TO0->TO0_LAUDO )},oPnlPS,40,10,"@!",;
						,CLR_BLACK,CLR_WHITE,,,,.T.,"",,{|| .F. },.F.,.F.,,.F.,.F.,,,,,,.T.)
		
		TSay():New( 6 , 84 ,{| | OemtoAnsi(STR0007) },oPnlPS,,,.F.,.F.,.F.,.T.,CLR_BLACK,CLR_WHITE,020,008)//"Nome Laudo"
		TGet():New( 5 , 104,{|u| If( PCount() > 0 , TO0->TO0_NOME := u , TO0->TO0_NOME )},oPnlPS,150,10,"@!",;
						,CLR_BLACK,CLR_WHITE,,,,.T.,"",,{|| .F. },.F.,.F.,,.F.,.F.,,,,,,.T.)
	    
		TButton():New( 30 , 5 , "&"+STR0005, oPnlPS, {|| MDT223BU(@oGetPS) } , 58 , 12 ,, /*oFont*/,,.T.,,,,/* bWhen*/,,)	
	
		PutFileInEof("TIA")
		oGetPS := MsNewGetDados():New(0,0,200,210,IIF(!lAltProg,0,GD_INSERT+GD_UPDATE+GD_DELETE),;
 								{|| MDT223Lin("TIA",,@oGetPS)},{|| MDT223Lin("TIA",.T.,@oGetPS)},/*cIniCpos*/,/*aAlterGDa*/,;
   								/*nFreeze*/,/*nMax*/,/*cFieldOk */,/*cSuperDel*/,/*cDelOk */,oDlgPS,aHeader,aCols)

		oGetPS:oBrowse:Align := CONTROL_ALIGN_ALLCLIENT

	NGPOPUP(asMenu,@oMenu,oPnlPS)
	oPnlPS:bRClicked:= { |o,x,y| oMenu:Activate(x,y,oPnlPS)}
	aSort(oGetPS:aCOLS,,,{ |x, y| x[1] < y[1] }) //Ordena por Programa de Saúde.
	
ACTIVATE MSDIALOG oDlgPS ON INIT EnchoiceBar(oDlgPS,{|| nOpca:=1,If(MDT223TOk(@oGetPS), oDlgPS:End(), nOpca := 0)},{|| oDlgPS:End(),nOpca := 0})

If nOpca == 1
	fGravaPS(@oGetPS)//Grava Programas de Saude.
Endif

Return .T.
//---------------------------------------------------------------------
/*/{Protheus.doc} MDT223BU
Mostra um markbrowse com todos os Requisitos Legais
para poder seleciona-los de uma so vez.(Baseado na funcao MDT230BU)

@author Bruno L. Souza
@since 15/04/13
@version MP10/11
@return Nil
/*/
//---------------------------------------------------------------------
Static Function MDT223BU( oGetPS )
Local aArea := GetArea()
//Variaveis para montar TRB
Local aDBF,aTRBRE
Local oTempTRB

//Variaveis de Tela      
Local oDlgProg,oFont
Local oMARKProg
Local oPnlProg

Local bOkReq	 := {|| nOpcao := 1,oDlgProg:End()}
Local bCancelReq := {|| nOpcao := 0,oDlgProg:End()}
Local nOpcao
Local lInverte, lRet
Local cAliasTRB := GetNextAlias()

Private cMarca := GetMark()    

lInverte:= .F.

//Valores e Caracteristicas da TRB
aDBF := {}
AADD(aDBF,{ "TRB_OK"      , "C" ,02      , 0 })
AADD(aDBF,{ "TRB_CODPRO"  , "C" ,TamSX3("TIA_CODPRO")[1], 0 })
AADD(aDBF,{ "TRB_NOMPRO"  , "C" ,TamSX3("TIA_NOMPRO")[1], 0 })
AADD(aDBF,{ "TRB_DESPRO"  , "C" ,TamSX3("TIA_DESPRO")[1], 0 })

aTRBRE := {}  
AADD(aTRBRE,{ "TRB_OK"    ,NIL," "	  ,})
AADD(aTRBRE,{ "TRB_CODPRO",NIL,STR0008,})//"Prog. Saúde"
AADD(aTRBRE,{ "TRB_NOMPRO",NIL,STR0009,})//"Nome"
AADD(aTRBRE,{ "TRB_DESPRO",NIL,STR0010,})//"Descrição"

//Cria TRB
oTempTRB := FWTemporaryTable():New( cAliasTRB, aDBF )
oTempTRB:AddIndex( "1", {"TRB_CODPRO"} )
oTempTRB:Create()

dbSelectArea("ST9")

Processa({|lEnd| fBuscaEq( cAliasTRB , oGetPS )},STR0011,STR0011)//"Buscando Programas de Saúde..."//"Espere"
Dbselectarea(cAliasTRB)
Dbgotop()
If (cAliasTRB)->(Reccount()) <= 0
	oTempTRB:Delete()
	RestArea(aArea)
	lRefresh := .t.
	Msgstop(STR0012,STR0013) //"Não existem Programas de Saúde cadastrados" //"ATENÇÃO" 
	Return .t.
Endif

nOpcao := 0

DEFINE MSDIALOG oDlgProg TITLE OemToAnsi(STR0005) From 64,160 To 580,730 OF oMainWnd Pixel  //"Programas de Saúde"
	
	oPnlProg := TPanel():New(0, 0, Nil, oDlgProg, Nil, .T., .F., Nil, Nil, 0, 55, .T., .F. )
		oPnlProg:Align := CONTROL_ALIGN_TOP
		
		@ 8,9.6 TO 45,280 OF oPnlProg PIXEL
		TSay():New(19,12,{|| OemtoAnsi(STR0015) },oPnlProg,,,.F.,.F.,.F.,.T.,CLR_BLACK,CLR_WHITE,200,010)//"Estes são os planos cadastrados no sistema."
		TSay():New(29,12,{|| OemtoAnsi(STR0016) },oPnlProg,,,.F.,.F.,.F.,.T.,CLR_BLACK,CLR_WHITE,200,010)//"Selecione aqueles que foram avaliados no laudo."

   	oMARKProg := MsSelect():NEW(cAliasTRB,"TRB_OK",,aTRBRE,@lINVERTE,@cMARCA,{0,0,0,0},,,oDlgProg)
		oMARKProg:oBROWSE:lHASMARK	  := .T.
		oMARKProg:oBROWSE:lCANALLMARK := .T.
		oMARKProg:oBROWSE:bALLMARK	  := {|| f223INVERT(cMarca,cAliasTRB) }//Funcao inverte marcadores
		oMARKProg:oBROWSE:ALIGN		  := CONTROL_ALIGN_ALLCLIENT

EnchoiceBar(oDlgProg,bOkReq,bCancelReq) 

ACTIVATE MSDIALOG oDlgProg CENTERED

lRet := ( nOpcao == 1 )

If lRet
	MDT223CPY(@oGetPS,cAliasTRB)//Funcao para copiar planos a GetDados
Endif

oTempTRB:Delete()

RestArea(aArea)

Return lRet
//---------------------------------------------------------------------
/*/{Protheus.doc} MDT223CPY
Copia os planos selecionados no markbrowse para a GetDados.

@author Bruno L. Souza
@since 15/04/13
@version MP10/11
@return Nil
/*/
//---------------------------------------------------------------------
Static Function MDT223CPY(oGetPS,cAliasTRB)
Local nCols, nPosCod
Local aColsOk := aClone(oGetPS:aCols)
Local aHeadOk := aClone(oGetPS:aHeader)
Local aColsTp := BLANKGETD(aHeadOk)

nPosCod := aScan( aHeadOk,{|x| Trim(Upper(x[2])) == "TIA_CODPRO"})
nPosNom := aScan( aHeadOk,{|x| Trim(Upper(x[2])) == "TIA_NOMPRO"})
nPosDes := aScan( aHeadOk,{|x| Trim(Upper(x[2])) == "TIA_DESPRO"})

For nCols := Len(aColsOk) To 1 Step -1 //Deleta do aColsOk os registros - não marcados; não estiver encontrado
	dbSelectArea(cAliasTRB)
	dbSetOrder(1)
	If !dbSeek(aColsOK[nCols,nPosCod]) .OR. Empty((cAliasTRB)->TRB_OK)
		aDel(aColsOk,nCols)
		aSize(aColsOk,Len(aColsOk)-1)
	EndIf
Next nCols

dbSelectArea(cAliasTRB)
dbGoTop()
While (cAliasTRB)->(!Eof())
	If !Empty((cAliasTRB)->TRB_OK) .AND. aScan( aColsOk , {|x| x[nPosCod] == (cAliasTRB)->TRB_CODPRO } ) == 0
		aAdd(aColsOk,aClone(aColsTp[1]))
		aColsOk[Len(aColsOk),nPosCod] := (cAliasTRB)->TRB_CODPRO
		aColsOk[Len(aColsOk),nPosNom] := (cAliasTRB)->TRB_NOMPRO
		aColsOk[Len(aColsOk),nPosDes] := (cAliasTRB)->TRB_DESPRO
	EndIf
	(cAliasTRB)->(dbSkip())
End

If Len(aColsOK) <= 0
	aColsOK := aClone(aColsTp)
EndIf

aSort(aColsOK,,,{ |x, y| x[1] < y[1] }) //Ordena por plano
oGetPS:aCols := aClone(aColsOK)
oGetPS:oBrowse:Refresh()
Return .T.
//---------------------------------------------------------------------
/*/{Protheus.doc} f223INVERT
Inverte a marcacao do browse.

@author Bruno L. Souza
@since 15/04/13
@version MP10/11
@return Nil
/*/
//---------------------------------------------------------------------
Static Function f223INVERT(cMarca,cAliasTRB)
Local aArea := GetArea()

dbSelectArea(cAliasTRB)
dbGoTop()
While !(cAliasTRB)->(Eof())
	(cAliasTRB)->TRB_OK := IF(Empty((cAliasTRB)->TRB_OK),cMARCA," ")
	(cAliasTRB)->(dbskip())
End

RestArea(aArea)
Return .T.
//---------------------------------------------------------------------
/*/{Protheus.doc} fGravaPS
Funcao para gravar dados da MsNewGetDados,
Equipamentos Radioativos na TIA

@author Bruno L. Souza
@since 15/04/13
@version MP10/11
@return Nil
/*/
//---------------------------------------------------------------------
Static Function fGravaPS( oObjeto )

Local aArea := GetArea()
Local i, j, ny, nPosCod
Local nOrd, cKey, cWhile 
Local aColsOk := aClone(oObjeto:aCols)
Local aHeadOk := aClone(oObjeto:aHeader)

nPosCod := aScan( aHeadOk,{|x| Trim(Upper(x[2])) == "TIA_CODPRO"})
nOrd 	:= 1
cKey 	:= xFilial("TIA")+TO0->TO0_LAUDO
cWhile  := "xFilial('TIA')+TO0->TO0_LAUDO == TIA->TIA_FILIAL+TIA->TIA_LAUDO"

If Len(aColsOK) > 0
	//Coloca os deletados por primeiro
	aSORT(aColsOK,,, { |x, y| x[Len(aColsOK[1])] .and. !y[Len(aColsOK[1])] } )
	
	For i:=1 to Len(aColsOK)
		If !aColsOK[i][Len(aColsOK[i])] .and. !Empty(aColsOK[i][nPosCod])
			dbSelectArea("TIA")
			dbSetOrder(nOrd)
			If dbSeek(cKey+aColsOK[i][nPosCod])
				RecLock("TIA",.F.)
			Else
				RecLock("TIA",.T.)
			Endif
			For j:=1 to FCount()
				If "_FILIAL"$Upper(FieldName(j))
					FieldPut(j, xFilial("TIA"))
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
			MsUnlock("TIA")
		Elseif !Empty(aColsOK[i][nPosCod])
			dbSelectArea("TIA")
			dbSetOrder(nOrd)
			If dbSeek(cKey+aColsOK[i][nPosCod])
				RecLock("TIA",.F.)
				dbDelete()
				MsUnlock("TIA")
			Endif
		Endif
	Next i
Endif
 
dbSelectArea("TIA")
dbSetOrder(nOrd)
dbSeek(cKey)
While !Eof() .and. &(cWhile)
	If aScan( aColsOK,{|x| x[nPosCod] == TIA->TIA_CODPRO .AND. !x[Len(x)]}) == 0
		RecLock("TIA",.f.)
		DbDelete()
		MsUnLock("TIA")
	Endif
	dbSelectArea("TIA")
	dbSkip()
End
RestArea(aArea)

Return .T.
//---------------------------------------------------------------------
/*/{Protheus.doc} MDT223Lin
Valida linhas do MsNewGetDados dos Planos Emergenciais.

@author Bruno L. Souza
@since 15/04/13
@version MP10/11
@return Nil
/*/
//---------------------------------------------------------------------
Function MDT223Lin(cAlias,lFim,oObjeto)
Local nX
Local aColsOk := {}, aHeadOk := {}
Local nPosCod := 1, nAt := 1
Local nCols, nHead
Default lFim := .F.

aColsOk := aClone(oObjeto:aCols)
aHeadOk := aClone(oObjeto:aHeader)
nAt     := oObjeto:nAt

If cAlias == "TIA"
	nPosCod := aScan( aHeadOk,{|x| Trim(Upper(x[2])) == "TIA_CODPRO"})
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

PutFileInEof("TIA")

Return .T.
//---------------------------------------------------------------------
/*/{Protheus.doc} MDT223TOk
Função para verificar toda a MsNewGetdados.

@author Bruno L. Souza
@since 15/04/13
@version MP10/11
@return Nil
/*/
//---------------------------------------------------------------------
Function MDT223TOk(oObjeto)

If !MDT223Lin("TIA",.T.,@oObjeto)
	Return .F.
Endif

Return .T.
//---------------------------------------------------------------------
/*/{Protheus.doc} fBuscaEq
Funcao para retornar todos os Requisitos.

@author Bruno L. Souza
@since 15/04/13
@version MP10/11
@return Nil
/*/
//---------------------------------------------------------------------
Static Function fBuscaEq( cAliasTRB , oGetPS )
Local nPosCod := 1
Local aArea   := GetArea()
Local aColsOK := aClone(oGetPS:aCols)
Local aHeadOk := aClone(oGetPS:aHeader)

nPosCod := aScan( aHeadOk,{|x| Trim(Upper(x[2])) == "TIA_CODPRO"})

dbSelectArea("TMO")
dbSetOrder(1)
If dbSeek(xFilial("TMO"))
	While TMO->(!Eof()) .AND. TMO->TMO_FILIAL == xFilial("TMO")
		RecLock(cAliasTRB,.T.)
		(cAliasTRB)->TRB_OK     := If( aScan( aColsOk , {|x| x[nPosCod] == TMO->TMO_CODPRO } ) > 0, cMarca , " " )
		(cAliasTRB)->TRB_CODPRO := TMO->TMO_CODPRO
		(cAliasTRB)->TRB_NOMPRO := TMO->TMO_NOMPRO
		(cAliasTRB)->TRB_DESPRO := TMO->TMO_DESPRO
		(cAliasTRB)->(MsUnLock())		
		TMO->(dbSkip())
	End
EndIf

RestArea(aArea)
Return