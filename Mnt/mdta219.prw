#INCLUDE "MDTA219.ch"
#INCLUDE "Protheus.ch"

#DEFINE _nVERSAO 2 //Versao do fonte
//---------------------------------------------------------------------
/*/{Protheus.doc} MDTA219
Programa de Registro das Familias dos Equipamentos nos Laudos.

@author Bruno L. Souza
@since 10/05/13
@version MP11
@return Nil
/*/   
//---------------------------------------------------------------------
Function MDTA219()

//#########################################################################
//## Armazena variaveis p/ devolucao (NGRIGHTCLICK) 					 ##
//#########################################################################
Local aNGBEGINPRM := NGBEGINPRM(_nVERSAO)
Private lSigaMdtPS := If( SuperGetMv("MV_MDTPS",.F.,"N") == "S", .t. , .f. )
Private aRotina := MenuDef(lSigaMdtPS)
//################################################################
//## Define o cabecalho da tela de atualizacoes                 ##   
//################################################################
Private cCadastro  := STR0001 //"Laudos x Fam�lias de Equipamentos"
Private aCHKDEL := {}, bNGGRAVA
Private cPrograma := "MDTA219" 
Private cCliMdtPs

If !NGCADICBASE("TIG_LAUDO","A","TIG",.F.)
	If !NGINCOMPDIC(If (lSigaMdtPS,"UPDMDTPS","UPDMDT82"))
		Return .F.
	Endif
Endif 

//Se for prestador de servi�o
If lSigaMdtPS
	DbSelectArea("SA1")
	DbSetOrder(1)    
	mBrowse( 6, 1,22,75,"SA1")
Else
	MDT219CAD()
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
	4. Tipo de Transa��o a ser efetuada:
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
                  { STR0004, "MDT219CAD" , 0 , 4} }  //"Laudo"
Else
	aRotina :=  { { STR0002, "AxPesqui"  , 0 , 1},;   //"Pesquisar"
                  { STR0003, "NGCAD01"   , 0 , 2},;   //"Visualizar"
                  { STR0005, "MDT219EQ"  , 0 , 4, 3} } //Fam�lias
Endif

Return aRotina

//---------------------------------------------------------------------
/*/{Protheus.doc} MDT219CAD
Monta um browse dos laudos.

@author Bruno L. Souza
@since 15/04/13
@version MP10/11
@return Nil
/*/
//---------------------------------------------------------------------
Function MDT219CAD()

Local aArea := GetArea()
Local cOldCad := cCadastro

aRotina := MenuDef()

DbSelectArea("TO0")
//Se for prestador de servi�o faz filtro de laudos por cliente
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
/*/{Protheus.doc} MDT219EQ
Monta um browse das Fam�lias de Equipamentos.

@author Bruno L. Souza
@since 10/05/13
@version MP11
@return Nil
/*/
//---------------------------------------------------------------------
Function MDT219EQ( cAlias , nReg, nOpcx )
//Objetos de Tela
Local oDlgFam, oPnlFam
Local oGetFam
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

aRotSetOpc( "TI9" , 1 , 4 )

//Inicializa variaveis de Tela
Aadd(aObjects,{050,050,.t.,.t.})
Aadd(aObjects,{100,100,.t.,.t.})
aInfo   := {aSize[1],aSize[2],aSize[3],aSize[4],0,0}
aPosObj := MsObjSize(aInfo, aObjects,.t.)

// Monta a GetDados dos Requisitos Legais
aAdd(aNoFields,"TIG_LAUDO")
aAdd(aNoFields,"TIG_FILIAL")
If lSigaMdtPs
	aAdd(aNoFields,"TIG_CLIENT")
	aAdd(aNoFields,"TIG_LOJA")
	nInd	  := 3
	cKeyGet   := "SA1->A1_COD+SA1->A1_LOJA+TO0->TO0_LAUDO"
	cWhileGet := "TIG->TIG_FILIAL == '"+xFilial("TIG")+"' .AND. TIG->TIG_LAUDO == '"+TO0->TO0_LAUDO+"'"+;
						" .AND. TIG->TIG_CLIENT+TIG->TIG_LOJA == '"+SA1->A1_COD+SA1->A1_LOJA+"'"
Else
	nInd	  := 1
	cKeyGet   := "TO0->TO0_LAUDO"
	cWhileGet := "TIG->TIG_FILIAL == '"+xFilial("TIG")+"' .AND. TIG->TIG_LAUDO == '"+TO0->TO0_LAUDO+"'"
EndIf

//Monta aCols e aHeader de TIG
dbSelectArea("TIG")
dbSetOrder(nInd)
FillGetDados( nOpcx, "TIG", 1, cKeyGet, {|| }, {|| .T.},aNoFields,,,,;
					{|| NGMontaAcols("TIG",&cKeyGet,cWhileGet)})
If Empty(aCols)
	aCols := BLANKGETD(aHeader)
Endif
   
nOpca := 0  

DEFINE MSDIALOG oDlgFam TITLE STR0001 From aSize[7],0 To aSize[6],aSize[5] OF oMainWnd PIXEL //"Laudos x Fam�lias de Equipamentos"

	oPnlFam := TPanel():New(0, 0, Nil, oDlgFam, Nil, .T., .F., Nil, Nil, 0, 60, .T., .F. )
		oPnlFam:Align := CONTROL_ALIGN_TOP
        
        TSay():New( 6 , 7 ,{| | OemtoAnsi(STR0006) },oPnlFam,,,.F.,.F.,.F.,.T.,CLR_BLACK,CLR_WHITE,020,008)//"Laudo"
		TGet():New( 5 , 27,{|u| If( PCount() > 0 , TO0->TO0_LAUDO := u , TO0->TO0_LAUDO )},oPnlFam,40,10,"@!",;
						,CLR_BLACK,CLR_WHITE,,,,.T.,"",,{|| .F. },.F.,.F.,,.F.,.F.,,,,,,.T.)
		  
		TSay():New( 6 , 84 ,{| | OemtoAnsi(STR0007) },oPnlFam,,,.F.,.F.,.F.,.T.,CLR_BLACK,CLR_WHITE,020,008)//"Nome Laudo"
		TGet():New( 5 , 103,{|u| If( PCount() > 0 , TO0->TO0_NOME := u , TO0->TO0_NOME )},oPnlFam,150,10,"@!",;
						,CLR_BLACK,CLR_WHITE,,,,.T.,"",,{|| .F. },.F.,.F.,,.F.,.F.,,,,,,.T.)
	    
		TButton():New( 30 , 5 , "&"+STR0005, oPnlFam, {|| MDT219BU(@oGetFam) } , 49 , 12 ,, /*oFont*/,,.T.,,,,/* bWhen*/,,)	
	
		PutFileInEof("TIG")
		oGetFam := MsNewGetDados():New(0,0,200,210,IIF(!lAltProg,0,GD_INSERT+GD_UPDATE+GD_DELETE),;
 								{|| MDT219Lin("TIG",,@oGetFam)},{|| MDT219Lin("TIG",.T.,@oGetFam)},/*cIniCpos*/,/*aAlterGDa*/,;
   								/*nFreeze*/,/*nMax*/,/*cFieldOk */,/*cSuperDel*/,/*cDelOk */,oDlgFam,aHeader,aCols)

		oGetFam:oBrowse:Align := CONTROL_ALIGN_ALLCLIENT

	NGPOPUP(asMenu,@oMenu,oPnlFam)
	oPnlFam:bRClicked:= { |o,x,y| oMenu:Activate(x,y,oPnlFam)}
	aSort(oGetFam:aCOLS,,,{ |x, y| x[1] < y[1] }) //Ordena por Fam�lias
	
ACTIVATE MSDIALOG oDlgFam ON INIT EnchoiceBar(oDlgFam,{|| nOpca:=1,If(MDT219TOk(@oGetFam), oDlgFam:End(), nOpca := 0)},{|| oDlgFam:End(),nOpca := 0})

If nOpca == 1
	fGravaEQ(@oGetFam)//Grava Fam�lias
Endif

Return .T.
//---------------------------------------------------------------------
/*/{Protheus.doc} MDT219BU
Mostra um markbrowse com todos os Requisitos Legais
para poder seleciona-los de uma so vez.(Baseado na funcao MDT230BU)

@author Bruno L. Souza
@since 15/04/13
@version MP10/11
@return Nil
/*/
//---------------------------------------------------------------------
Static Function MDT219BU( oGetFam )
Local aArea := GetArea()
//Variaveis para montar TRB
Local aDBF,aTRBFA
Local oTempTRB
//Variaveis de Tela      
Local oDlgEquip,oFont
Local oMARKEquip
Local oPnlMSG

Local bOkReq	 := {|| nOpcao := 1,oDlgEquip:End()}
Local bCancelReq := {|| nOpcao := 0,oDlgEquip:End()}
Local nOpcao
Local lInverte, lRet
Local cAliasTRB := GetNextAlias()

Private cMarca := GetMark()    

lInverte := .F.

//Valores e Caracteristicas da TRB
aDBF := {}
AADD(aDBF,{ "TRB_OK"      , "C" ,02      , 0 })
AADD(aDBF,{ "TRB_CODFAM"  , "C" ,TamSX3("TIG_CODFAM")[1], 0 })
AADD(aDBF,{ "TRB_NOMFAM"  , "C" ,TamSX3("TIG_NOMFAM")[1], 0 })

aTRBFA := {}  
AADD(aTRBFA,{ "TRB_OK"    ,NIL," "	  ,})
AADD(aTRBFA,{ "TRB_CODFAM",NIL,STR0008,})//"Cod. Fam�lia"
AADD(aTRBFA,{ "TRB_NOMFAM",NIL,STR0009,})//"Nome"

//Cria TRB
oTempTRB := FWTemporaryTable():New( cAliasTRB, aDBF )
oTempTRB:AddIndex( "1", {"TRB_CODFAM"} )
oTempTRB:Create()

dbSelectArea("ST6")

Processa({|lEnd| fBuscaFam( cAliasTRB , oGetFam )},STR0010,STR0011)//"Buscando Fam�lias..."#"Espere"
Dbselectarea(cAliasTRB)
Dbgotop()   
If (cAliasTRB)->(Reccount()) <= 0
	oTempTRB:Delete()
	RestArea(aArea)
	lRefresh := .t.
	Msgstop(STR0012,STR0013) //"N�o existem Fam�lias cadastradas"#"ATEN��O" 
	Return .t.
Endif  

nOpcao := 0

DEFINE MSDIALOG oDlgEquip TITLE OemToAnsi(STR0005) From 64,160 To 580,730 OF oMainWnd Pixel  //"Fam�lias"
	
	oPnlMSG := TPanel():New(0, 0, Nil, oDlgEquip, Nil, .T., .F., Nil, Nil, 0, 55, .T., .F. )
		oPnlMSG:Align := CONTROL_ALIGN_TOP
		
		@ 8,9.6 TO 45,280 OF oPnlMSG PIXEL
		TSay():New(19,12,{|| OemtoAnsi(STR0014) },oPnlMSG,,,.F.,.F.,.F.,.T.,CLR_BLACK,CLR_WHITE,200,010)//"Estas s�o as fam�lias cadastrados no sistema."
		TSay():New(29,12,{|| OemtoAnsi(STR0015) },oPnlMSG,,,.F.,.F.,.F.,.T.,CLR_BLACK,CLR_WHITE,200,010)//"Selecione aqueles que foram avaliados no laudo."

	oMARKEquip := MsSelect():NEW(cAliasTRB,"TRB_OK",,aTRBFA,@lINVERTE,@cMARCA,{0,0,0,0},,,oDlgEquip)
		oMARKEquip:oBROWSE:lHASMARK		:= .T.
		oMARKEquip:oBROWSE:lCANALLMARK	:= .T.
		oMARKEquip:oBROWSE:bALLMARK		:= {|| f219INVERT(cMarca,cAliasTRB) }//Funcao inverte marcadores
		oMARKEquip:oBROWSE:ALIGN		:= CONTROL_ALIGN_ALLCLIENT

EnchoiceBar(oDlgEquip,bOkReq,bCancelReq) 

ACTIVATE MSDIALOG oDlgEquip CENTERED

lRet := ( nOpcao == 1 )

If lRet
	MDT221CPY(@oGetFam,cAliasTRB)//Funcao para copiar planos a GetDados
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
Static Function MDT221CPY(oGetFam,cAliasTRB)
Local nCols, nPosCod
Local aColsOk := aClone(oGetFam:aCols)
Local aHeadOk := aClone(oGetFam:aHeader)
Local aColsTp := BLANKGETD(aHeadOk)

nPosCod := aScan( aHeadOk,{|x| Trim(Upper(x[2])) == "TIG_CODFAM"})
nPosDes := aScan( aHeadOk,{|x| Trim(Upper(x[2])) == "TIG_NOMFAM"})

For nCols := Len(aColsOk) To 1 Step -1 //Deleta do aColsOk os registros - n�o marcados; n�o estiver encontrado
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
	If !Empty((cAliasTRB)->TRB_OK) .AND. aScan( aColsOk , {|x| x[nPosCod] == (cAliasTRB)->TRB_CODFAM } ) == 0
		aAdd(aColsOk,aClone(aColsTp[1]))
		aColsOk[Len(aColsOk),nPosCod] := (cAliasTRB)->TRB_CODFAM
		aColsOk[Len(aColsOk),nPosDes] := (cAliasTRB)->TRB_NOMFAM
	EndIf
	(cAliasTRB)->(dbSkip())
End

If Len(aColsOK) <= 0
	aColsOK := aClone(aColsTp)
EndIf

aSort(aColsOK,,,{ |x, y| x[1] < y[1] }) //Ordena por plano
oGetFam:aCols := aClone(aColsOK)
oGetFam:oBrowse:Refresh()
Return .T.
//---------------------------------------------------------------------
/*/{Protheus.doc} f219INVERT
Inverte a marcacao do browse.

@author Bruno L. Souza
@since 15/04/13
@version MP10/11
@return Nil
/*/
//---------------------------------------------------------------------
Static Function f219INVERT(cMarca,cAliasTRB)
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
Equipamentos Radioativos na TIG

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

nPosCod := aScan( aHeadOk,{|x| Trim(Upper(x[2])) == "TIG_CODFAM"})
If lSigaMdtPs
	nOrd 	:= 3
	cKey 	:= xFilial("TIG")+SA1->A1_COD+SA1->A1_LOJA+TO0->TO0_LAUDO
	cWhile  := "xFilial('TIG')+SA1->A1_COD+SA1->A1_LOJA+TO0->TO0_LAUDO == TIG->TIG_FILIAL+TIG->TIG_CLIENT+TIG->TIG_LOJA+TIG->TIG_LAUDO"
Else
	nOrd 	:= 1
	cKey 	:= xFilial("TIG")+TO0->TO0_LAUDO
	cWhile  := "xFilial('TIG')+TO0->TO0_LAUDO == TIG->TIG_FILIAL+TIG->TIG_LAUDO"
EndIf

If Len(aColsOK) > 0
	//Coloca os deletados por primeiro
	aSORT(aColsOK,,, { |x, y| x[Len(aColsOK[1])] .and. !y[Len(aColsOK[1])] } )
	
	For i:=1 to Len(aColsOK)
		If !aColsOK[i][Len(aColsOK[i])] .and. !Empty(aColsOK[i][nPosCod])
			dbSelectArea("TIG")
			dbSetOrder(nOrd)
			If dbSeek(cKey+aColsOK[i][nPosCod])
				RecLock("TIG",.F.)
			Else
				RecLock("TIG",.T.)
			Endif
			For j:=1 to FCount()
				If "_FILIAL"$Upper(FieldName(j))
					FieldPut(j, xFilial("TIG"))
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
			MsUnlock("TIG")
		Elseif !Empty(aColsOK[i][nPosCod])
			dbSelectArea("TIG")
			dbSetOrder(nOrd)
			If dbSeek(cKey+aColsOK[i][nPosCod])
				RecLock("TIG",.F.)
				dbDelete()
				MsUnlock("TIG")
			Endif
		Endif
	Next i
Endif
 
dbSelectArea("TIG")
dbSetOrder(nOrd)
dbSeek(cKey)
While !Eof() .and. &(cWhile)
	If aScan( aColsOK,{|x| x[nPosCod] == TIG->TIG_CODFAM .AND. !x[Len(x)]}) == 0
		RecLock("TIG",.f.)
		DbDelete()
		MsUnLock("TIG")
	Endif
	dbSelectArea("TIG")
	dbSkip()
End
RestArea(aArea)

Return .T.
//---------------------------------------------------------------------
/*/{Protheus.doc} MDT219Lin
Valida linhas do MsNewGetDados dos Planos Emergenciais.

@author Bruno L. Souza
@since 15/04/13
@version MP10/11
@return Nil
/*/
//---------------------------------------------------------------------
Function MDT219Lin(cAlias,lFim,oObjeto)
Local nX
Local aColsOk := {}, aHeadOk := {}
Local nPosCod := 1, nAt := 1
Local nCols, nHead
Default lFim := .F.

aColsOk := aClone(oObjeto:aCols)
aHeadOk := aClone(oObjeto:aHeader)
nAt     := oObjeto:nAt

If cAlias == "TIG"
	nPosCod := aScan( aHeadOk,{|x| Trim(Upper(x[2])) == "TIG_CODFAM"})
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
			//VerIfica se os campos obrigat�rios est�o preenchidos
			If Empty(aColsOk[nX][nPosCod])
				//Mostra mensagem de Help
				Help(1," ","OBRIGAT2",,aHeadOk[nPosCod][1],3,0)
				Return .F.
			Endif
		Endif
		//Verifica se � somente LinhaOk
		If nX <> nAt .and. !aColsOk[nAt][Len(aColsOk[nAt])]
			If aColsOk[nX][nPosCod] == aColsOk[nAt][nPosCod]
				Help(" ",1,"JAEXISTINF",,aHeadOk[nPosCod][1])
				Return .F.
			Endif
		Endif
	Endif
Next nX

PutFileInEof("TIG")

Return .T.
//---------------------------------------------------------------------
/*/{Protheus.doc} MDT219TOk
Fun��o para verificar toda a MsNewGetdados.

@author Bruno L. Souza
@since 10/05/13
@version MP10/11
@return Nil
/*/
//---------------------------------------------------------------------
Function MDT219TOk(oObjeto)

If !MDT219Lin("TIG",.T.,@oObjeto)
	Return .F.
Endif

Return .T.
//---------------------------------------------------------------------
/*/{Protheus.doc} fBuscaFam
Funcao para retornar todas as Fam�lias.

@author Bruno L. Souza
@since 10/05/13
@version MP10/11
@return Nil
/*/
//---------------------------------------------------------------------
Static Function fBuscaFam( cAliasTRB , oGetFam )
Local nPosCod := 1
Local aArea   := GetArea()
Local aColsOK := aClone(oGetFam:aCols)
Local aHeadOk := aClone(oGetFam:aHeader)

nPosCod := aScan( aHeadOk,{|x| Trim(Upper(x[2])) == "TIG_CODFAM"})

dbSelectArea("ST6")
dbSetOrder(1)
If dbSeek(xFilial("ST6"))
	While ST6->(!Eof()) .AND. ST6->T6_FILIAL == xFilial("ST6")
		RecLock(cAliasTRB,.T.)
		(cAliasTRB)->TRB_OK     := If( aScan( aColsOk , {|x| x[nPosCod] == ST6->T6_CODFAMI } ) > 0, cMarca , " " )
		(cAliasTRB)->TRB_CODFAM := ST6->T6_CODFAMI
		(cAliasTRB)->TRB_NOMFAM := ST6->T6_NOME
		(cAliasTRB)->(MsUnLock())		
		ST6->(dbSkip())
	End
EndIf

RestArea(aArea)
Return