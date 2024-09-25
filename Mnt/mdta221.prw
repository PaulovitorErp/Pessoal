#INCLUDE "MDTA221.ch"
#INCLUDE "Protheus.ch"

#DEFINE _nVERSAO 2 //Versao do fonte
//---------------------------------------------------------------------
/*/{Protheus.doc} MDTA221
Programa de  Registro dos Equipamentos Radioativos nos Laudos.

@author Bruno L. Souza
@since 15/04/13
@version MP10/11
@return Nil
/*/
//---------------------------------------------------------------------
Function MDTA221()

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
Private cPrograma := "MDTA221"
Private cCliMdtPs

If !NGCADICBASE("TI9_LAUDO","A","TI9",.F.)
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
	MDT221CAD()
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
                  { STR0004, "MDT221CAD" , 0 , 4} }  //"Laudo"
Else
	aRotina :=  { { STR0002, "AxPesqui"  , 0 , 1},;   //"Pesquisar"
                  { STR0003, "NGCAD01"   , 0 , 2},;   //"Visualizar"
                  { STR0005, "MDT221EQ"  , 0 , 4, 3} } //"Equipamentos"
Endif

Return aRotina

//---------------------------------------------------------------------
/*/{Protheus.doc} MDT221CAD
Monta um browse dos laudos.

@author Bruno L. Souza
@since 15/04/13
@version MP10/11
@return Nil
/*/
//---------------------------------------------------------------------
Function MDT221CAD()

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
/*/{Protheus.doc} MDT226EQ
Monta um browse dos Equipamentos radioativos.

@author Bruno L. Souza
@since 15/04/13
@version MP10/11
@return Nil
/*/
//---------------------------------------------------------------------
Function MDT221EQ( cAlias , nReg, nOpcx )
//Objetos de Tela
Local oDlgRE, oPnlRE
Local oGetEQ
Local oMenu
Local oPnlTOT

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

aRotSetOpc( "TI9" , 1 , 4 )

//Inicializa variaveis de Tela
Aadd(aObjects,{050,050,.t.,.t.})
Aadd(aObjects,{100,100,.t.,.t.})
aInfo   := {aSize[1],aSize[2],aSize[3],aSize[4],0,0}
aPosObj := MsObjSize(aInfo, aObjects,.t.)

// Monta a GetDados dos Requisitos Legais
aAdd(aNoFields,"TI9_LAUDO")
aAdd(aNoFields,"TI9_FILIAL")
nInd	  := 1
cKeyGet   := "TO0->TO0_LAUDO"
cWhileGet := "TI9->TI9_FILIAL == '"+xFilial("TI9")+"' .AND. TI9->TI9_LAUDO == '"+TO0->TO0_LAUDO+"'"

//Monta aCols e aHeader de TI9
dbSelectArea("TI9")
dbSetOrder(nInd)
FillGetDados( nOpcx, "TI9", 1, cKeyGet, {|| }, {|| .T.},aNoFields,,,,;
					{|| NGMontaAcols("TI9",&cKeyGet,cWhileGet)})
If Empty(aCols)
	aCols := BLANKGETD(aHeader)
Endif

nOpca := 0

DEFINE MSDIALOG oDlgRE TITLE STR0001 From aSize[7],0 To aSize[6],aSize[5] OF oMainWnd PIXEL   //"Laudo x Requisitos"

	oPnlTOT := TPanel():New( , , , oDlgRE , , , , , , , , .F. , .F. )
		oPnlTOT:Align := CONTROL_ALIGN_ALLCLIENT

	oPnlRE := TPanel():New(0, 0, Nil, oPnlTOT, Nil, .T., .F., Nil, Nil, 0, 60, .T., .F. )
		oPnlRE:Align := CONTROL_ALIGN_TOP
        
        TSay():New( 6 , 7 ,{| | OemtoAnsi(STR0006) },oPnlRE,,,.F.,.F.,.F.,.T.,CLR_BLACK,CLR_WHITE,020,008)//"Laudo"
		TGet():New( 5 , 27,{|u| If( PCount() > 0 , TO0->TO0_LAUDO := u , TO0->TO0_LAUDO )},oPnlRE,40,10,"@!",;
						,CLR_BLACK,CLR_WHITE,,,,.T.,"",,{|| .F. },.F.,.F.,,.F.,.F.,,,,,,.T.)
		
		TSay():New( 6 , 84 ,{| | OemtoAnsi(STR0007) },oPnlRE,,,.F.,.F.,.F.,.T.,CLR_BLACK,CLR_WHITE,020,008)//"Nome Laudo"
		TGet():New( 5 , 104,{|u| If( PCount() > 0 , TO0->TO0_NOME := u , TO0->TO0_NOME )},oPnlRE,150,10,"@!",;
						,CLR_BLACK,CLR_WHITE,,,,.T.,"",,{|| .F. },.F.,.F.,,.F.,.F.,,,,,,.T.)
	    
		TButton():New( 30 , 5 , "&"+STR0016, oPnlRE, {|| MDT221BU(@oGetEQ) } , 49 , 12 ,, /*oFont*/,,.T.,,,,/* bWhen*/,,)	
	
		PutFileInEof("TI9")
		oGetEQ := MsNewGetDados():New(0,0,200,210,IIF(!lAltProg,0,GD_INSERT+GD_UPDATE+GD_DELETE),;
 								{|| MDT221Lin("TI9",,@oGetEQ)},{|| MDT221Lin("TI9",.T.,@oGetEQ)},/*cIniCpos*/,/*aAlterGDa*/,;
   								/*nFreeze*/,/*nMax*/,/*cFieldOk */,/*cSuperDel*/,/*cDelOk */,oPnlTOT,aHeader,aCols)

		oGetEQ:oBrowse:Align := CONTROL_ALIGN_ALLCLIENT

	NGPOPUP(asMenu,@oMenu,oPnlRE)
	oPnlRE:bRClicked:= { |o,x,y| oMenu:Activate(x,y,oPnlRE)}
	aSort(oGetEQ:aCOLS,,,{ |x, y| x[1] < y[1] }) //Ordena por Equipamentos 
	
ACTIVATE MSDIALOG oDlgRE ON INIT EnchoiceBar(oDlgRE,{|| nOpca:=1,If(MDT221TOk(@oGetEQ), oDlgRE:End(), nOpca := 0)},{|| oDlgRE:End(),nOpca := 0})

If nOpca == 1
	fGravaEQ(@oGetEQ)//Grava Requisitos Legais
Endif

Return .T.
//---------------------------------------------------------------------
/*/{Protheus.doc} MDT221BU
Mostra um markbrowse com todos os Requisitos Legais
para poder seleciona-los de uma so vez.(Baseado na funcao MDT230BU)

@author Bruno L. Souza
@since 15/04/13
@version MP10/11
@return Nil
/*/
//---------------------------------------------------------------------
Static Function MDT221BU( oGetEQ )
Local aArea := GetArea()
//Variaveis para montar TRB
Local aDBF,aTRBRE
//Variaveis de Tela      
Local oDlgEquip,oFont
Local oMARKEquip
Local oPnlMSG
Local oPnlBUT

Local bOkReq	 := {|| nOpcao := 1,oDlgEquip:End()}
Local bCancelReq := {|| nOpcao := 0,oDlgEquip:End()}
Local nOpcao
Local lInverte, lRet
Local cAliasTRB := GetNextAlias()
Local oTempTRB

Private cMarca := GetMark()    

lInverte := .F.

//Valores e Caracteristicas da TRB
aDBF := {}
AADD(aDBF,{ "TRB_OK"      , "C" ,02      , 0 })
AADD(aDBF,{ "TRB_CODEQP"  , "C" ,TamSX3("TI9_CODEQP")[1], 0 })
AADD(aDBF,{ "TRB_DESEQP"  , "C" ,TamSX3("TI9_DESEQP")[1], 0 })

aTRBRE := {}  
AADD(aTRBRE,{ "TRB_OK"    ,NIL," "	  ,})
AADD(aTRBRE,{ "TRB_CODEQP",NIL,STR0008,})//"Cod. Equipamento"
AADD(aTRBRE,{ "TRB_DESEQP",NIL,STR0009,})//"Desc. Equipamento"

//Cria TRB
oTempTRB := FWTemporaryTable():New( cAliasTRB, aDBF )
oTempTRB:AddIndex( "1", {"TRB_CODEQP"} )
oTempTRB:Create()

dbSelectArea("ST9")

Processa({|lEnd| fBuscaEq( cAliasTRB , oGetEQ )},STR0010,STR0011)//"Buscando Equipamentos..."//"Espere"
Dbselectarea(cAliasTRB)
Dbgotop()
If (cAliasTRB)->(Reccount()) <= 0
	oTempTRB:Delete()
	RestArea(aArea)
	lRefresh := .t.
	Msgstop(STR0012,STR0013) //"Não existem Equipamentos cadastrados" //"ATENÇÃO" 
	Return .t.
Endif

nOpcao := 0

DEFINE MSDIALOG oDlgEquip TITLE OemToAnsi(STR0016) From 64,160 To 580,730 OF oMainWnd Pixel  //"Equipamentos"
	
	oPnlBUT := TPanel():New( , , , oDlgEquip , , , , , , , , .F. , .F. )
		oPnlBUT:Align := CONTROL_ALIGN_ALLCLIENT
	
	oPnlMSG := TPanel():New(0, 0, Nil, oPnlBUT, Nil, .T., .F., Nil, Nil, 0, 55, .T., .F. )
		oPnlMSG:Align := CONTROL_ALIGN_TOP
		
		@ 8,9.6 TO 45,280 OF oPnlMSG PIXEL
		TSay():New(19,12,{|| OemtoAnsi(STR0014) },oPnlMSG,,,.F.,.F.,.F.,.T.,CLR_BLACK,CLR_WHITE,200,010)//"Estes são os planos cadastrados no sistema."
		TSay():New(29,12,{|| OemtoAnsi(STR0015) },oPnlMSG,,,.F.,.F.,.F.,.T.,CLR_BLACK,CLR_WHITE,200,010)//"Selecione aqueles que foram avaliados no laudo."

	oMARKEquip := MsSelect():NEW(cAliasTRB,"TRB_OK",,aTRBRE,@lINVERTE,@cMARCA,{0,0,0,0},,,oPnlBUT)
		oMARKEquip:oBROWSE:lHASMARK		:= .T.
		oMARKEquip:oBROWSE:lCANALLMARK	:= .T.
		oMARKEquip:oBROWSE:bALLMARK		:= {|| f221INVERT(cMarca,cAliasTRB) }//Funcao inverte marcadores
		oMARKEquip:oBROWSE:ALIGN		:= CONTROL_ALIGN_ALLCLIENT

EnchoiceBar(oDlgEquip,bOkReq,bCancelReq) 

ACTIVATE MSDIALOG oDlgEquip CENTERED

lRet := ( nOpcao == 1 )

If lRet
	MDT221CPY(@oGetEQ,cAliasTRB)//Funcao para copiar planos a GetDados
Endif

oTempTRB:Delete()

RestArea(aArea)

Return lRet
//---------------------------------------------------------------------
/*/{Protheus.doc} MDT221CPY
Copia os planos selecionados no markbrowse para a GetDados.

@author Bruno L. Souza
@since 15/04/13
@version MP10/11
@return Nil
/*/
//---------------------------------------------------------------------
Static Function MDT221CPY(oGetEQ,cAliasTRB)
Local nCols, nPosCod
Local aColsOk := aClone(oGetEQ:aCols)
Local aHeadOk := aClone(oGetEQ:aHeader)
Local aColsTp := BLANKGETD(aHeadOk)

nPosCod := aScan( aHeadOk,{|x| Trim(Upper(x[2])) == "TI9_CODEQP"})
nPosDes := aScan( aHeadOk,{|x| Trim(Upper(x[2])) == "TI9_DESEQP"})

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
	If !Empty((cAliasTRB)->TRB_OK) .AND. aScan( aColsOk , {|x| x[nPosCod] == (cAliasTRB)->TRB_CODEQP } ) == 0
		aAdd(aColsOk,aClone(aColsTp[1]))
		aColsOk[Len(aColsOk),nPosCod] := (cAliasTRB)->TRB_CODEQP
		aColsOk[Len(aColsOk),nPosDes] := (cAliasTRB)->TRB_DESEQP
	EndIf
	(cAliasTRB)->(dbSkip())
End

If Len(aColsOK) <= 0
	aColsOK := aClone(aColsTp)
EndIf

aSort(aColsOK,,,{ |x, y| x[1] < y[1] }) //Ordena por plano
oGetEQ:aCols := aClone(aColsOK)
oGetEQ:oBrowse:Refresh()
Return .T.
//---------------------------------------------------------------------
/*/{Protheus.doc} f221INVERT
Inverte a marcacao do browse.

@author Bruno L. Souza
@since 15/04/13
@version MP10/11
@return Nil
/*/
//---------------------------------------------------------------------
Static Function f221INVERT(cMarca,cAliasTRB)
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
/*/{Protheus.doc} fGravaEQ
Funcao para gravar dados da MsNewGetDados,
Equipamentos Radioativos na TI9

@author Bruno L. Souza
@since 15/04/13
@version MP10/11
@return Nil
/*/
//---------------------------------------------------------------------
Static Function fGravaEQ( oObjeto )

Local aArea := GetArea()
Local i, j, ny, nPosCod
Local nOrd, cKey, cWhile 
Local aColsOk := aClone(oObjeto:aCols)
Local aHeadOk := aClone(oObjeto:aHeader)

nPosCod := aScan( aHeadOk,{|x| Trim(Upper(x[2])) == "TI9_CODEQP"})
nOrd 	:= 1
cKey 	:= xFilial("TI9")+TO0->TO0_LAUDO
cWhile  := "xFilial('TI9')+TO0->TO0_LAUDO == TI9->TI9_FILIAL+TI9->TI9_LAUDO"

If Len(aColsOK) > 0
	//Coloca os deletados por primeiro
	aSORT(aColsOK,,, { |x, y| x[Len(aColsOK[1])] .and. !y[Len(aColsOK[1])] } )
	
	For i:=1 to Len(aColsOK)
		If !aColsOK[i][Len(aColsOK[i])] .and. !Empty(aColsOK[i][nPosCod])
			dbSelectArea("TI9")
			dbSetOrder(nOrd)
			If dbSeek(cKey+aColsOK[i][nPosCod])
				RecLock("TI9",.F.)
			Else
				RecLock("TI9",.T.)
			Endif
			For j:=1 to FCount()
				If "_FILIAL"$Upper(FieldName(j))
					FieldPut(j, xFilial("TI9"))
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
			MsUnlock("TI9")
		Elseif !Empty(aColsOK[i][nPosCod])
			dbSelectArea("TI9")
			dbSetOrder(nOrd)
			If dbSeek(cKey+aColsOK[i][nPosCod])
				RecLock("TI9",.F.)
				dbDelete()
				MsUnlock("TI9")
			Endif
		Endif
	Next i
Endif
 
dbSelectArea("TI9")
dbSetOrder(nOrd)
dbSeek(cKey)
While !Eof() .and. &(cWhile)
	If aScan( aColsOK,{|x| x[nPosCod] == TI9->TI9_CODEQP .AND. !x[Len(x)]}) == 0
		RecLock("TI9",.f.)
		DbDelete()
		MsUnLock("TI9")
	Endif
	dbSelectArea("TI9")
	dbSkip()
End
RestArea(aArea)

Return .T.
//---------------------------------------------------------------------
/*/{Protheus.doc} MDT221Lin
Valida linhas do MsNewGetDados dos Planos Emergenciais.

@author Bruno L. Souza
@since 15/04/13
@version MP10/11
@return Nil
/*/
//---------------------------------------------------------------------
Function MDT221Lin(cAlias,lFim,oObjeto)
Local nX
Local aColsOk := {}, aHeadOk := {}
Local nPosCod := 1, nAt := 1
Local nCols, nHead
Default lFim := .F.

aColsOk := aClone(oObjeto:aCols)
aHeadOk := aClone(oObjeto:aHeader)
nAt     := oObjeto:nAt

If cAlias == "TI9"
	nPosCod := aScan( aHeadOk,{|x| Trim(Upper(x[2])) == "TI9_CODEQP"})
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

PutFileInEof("TI9")

Return .T.
//---------------------------------------------------------------------
/*/{Protheus.doc} MDT221TOk
Função para verificar toda a MsNewGetdados.

@author Bruno L. Souza
@since 15/04/13
@version MP10/11
@return Nil
/*/
//---------------------------------------------------------------------
Function MDT221TOk(oObjeto)

If !MDT221Lin("TI9",.T.,@oObjeto)
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
Static Function fBuscaEq( cAliasTRB , oGetEQ )
Local nPosCod := 1
Local aArea   := GetArea()
Local aColsOK := aClone(oGetEQ:aCols)
Local aHeadOk := aClone(oGetEQ:aHeader)

nPosCod := aScan( aHeadOk,{|x| Trim(Upper(x[2])) == "TI9_CODEQP"})

dbSelectArea("ST9")
dbSetOrder(1)
If dbSeek(xFilial("ST9"))
	While ST9->(!Eof()) .AND. ST9->T9_FILIAL == xFilial("ST9")
		RecLock(cAliasTRB,.T.)
		(cAliasTRB)->TRB_OK     := If( aScan( aColsOk , {|x| x[nPosCod] == ST9->T9_CODBEM } ) > 0, cMarca , " " )
		(cAliasTRB)->TRB_CODEQP := ST9->T9_CODBEM
		(cAliasTRB)->TRB_DESEQP := ST9->T9_NOME
		(cAliasTRB)->(MsUnLock())		
		ST9->(dbSkip())
	End
EndIf

RestArea(aArea)
Return