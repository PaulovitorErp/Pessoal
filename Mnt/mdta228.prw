#Include 'Protheus.ch'
#Include 'MDTA228.ch'

#DEFINE _nVERSAO 2 //Versao do fonte

//---------------------------------------------------------------------
/*/{Protheus.doc} MDTA228
Laudo X Questionário de Produto QUimico

@author Taina Alberto Cardoso
@since 25/04/13
@version MP11
@return Nil
/*/
//---------------------------------------------------------------------
Function MDTA228()

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Armazena variaveis p/ devolucao (NGRIGHTCLICK) 				  		  ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	Local aNGBEGINPRM := NGBEGINPRM(_nVERSAO)
	LOCAL cFiltraSRJ			//Variavel para filtro
	LOCAL aIndexSRJ	:= {}		//Variavel Para Filtro
	
	
	PRIVATE cCadastro := OemtoAnsi(STR0001) //"Laudos por Questionario Quimico"
	PRIVATE aCHKDEL := {}, bNGGRAVA
	Private cPrograma := "MDTA228"
	Private aRotina := MenuDef()
	
	If !AliasInDic("TID")
		If !NGINCOMPDIC("UPDMDT78","THFTE6",.T.)
	  		Return .F.
		EndIf
	EndIf
	
	DbSetOrder(1)
	mBrowse( 6, 1,22,75,"TO0")
	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Devolve variaveis armazenadas (NGRIGHTCLICK)                          ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	NGRETURNPRM(aNGBEGINPRM)

Return


//---------------------------------------------------------------------
/*/{Protheus.doc} MenuDef


@author Taina Alberto Cardoso
@since 24/04/13
@version MP11
@return Nil
/*/
//---------------------------------------------------------------------
Static Function MenuDef()  
	Local aRotina

	
	aRotina :=	{  { STR0003,"AxPesqui"  , 0 , 1},;   //"Pesquisar"
					{ STR0004 ,"NGCAD01"   , 0 , 2},; //"Visualizar"
					{ STR0002,"QUEST_228", 0 , 4}}    //"Questionário"
	
Return aRotina

//---------------------------------------------------------------------
/*/{Protheus.doc} QUEST_228
Inclusao de Questionarios no Laudo

@author Taina Alberto Cardoso
@since 24/04/13
@version MP11
@return Nil
/*/
//---------------------------------------------------------------------
Function QUEST_228(cAlias,nReg,nOpcx) 
	LOCAL i
	Local aNAO := {}, cKEY, cGETWHILE
	Local aNoFields := {}   
	Local oPanel, oPanelCmps, oPanelGet
	
	Private aButtons := {}
	
	Private oDLG5, oMenu
	Private aTELA[0][0],aGETS[0],aHeader[0],Continua,nUsado:=0,aCols := {}
	bCampo   := {|nCPO| Field(nCPO) }
	DbSelectArea("TIF")
	FOR i := 1 TO FCount()
	      M->&(EVAL(bCampo,i)) := &(EVAL(bCampo,i))
	
	      If nOPCX == 3    //INCLUIR
	         IF      ValType(M->&(EVAL(bCampo,i))) == "C"
	                M->&(EVAL(bCampo,i)) := SPACE(LEN(M->&(EVAL(bCampo,i))))
	         ELSEIF ValType(M->&(EVAL(bCampo,i))) == "N"
	                M->&(EVAL(bCampo,i)) := 0
	         ELSEIF ValType(M->&(EVAL(bCampo,i))) == "D"  
	                M->&(EVAL(bCampo,i)) := cTod("  /  /  ")
	         ELSEIF ValType(M->&(EVAL(bCampo,i))) == "L"
	                M->&(EVAL(bCampo,i)) := .F.
	         ENDIF
	      Endif
	Next i
	
	AAdd(aNAO,"TIF_LAUDO")
	M->TIF_LAUDO  := TO0->TO0_LAUDO
	cKEY      := M->TIF_LAUDO
	cGETWHILE := "TIF_LAUDO == TO0->TO0_LAUDO .AND. TIF_FILIAL == xFilial('TIF')"
	aHeader   := CABECGETD("TIF",aNAO)
	
	//Inclui coluna de registro atraves de funcao generica
	//ADHeadRec("TIF",aHeader)
	
	DbSelectArea("TIF")
	DbSetOrder(1)
	
	aCOLS := MAKEGETD("TIF",cKEY,aHeader,cGETWHILE,,.f.)
	If Empty(aCOLS)
	   aCOLS :=BLANKGETD(aHeader)
	Else
	   M->TIF_QUEST:= TIF->TIF_QUEST
	Endif
	
	DbSelectArea("TIF")
	
	nOPCAP := 0   
	
	Private aSize := MsAdvSize(,.f.,430), aObjects := {}
	Aadd(aObjects,{050,050,.t.,.t.})
	Aadd(aObjects,{100,100,.t.,.t.})
	aInfo := {aSize[1],aSize[2],aSize[3],aSize[4],0,0}
	aPosObj := MsObjSize(aInfo, aObjects,.t.)
	
	DEFINE MSDIALOG oDlg5 TITLE Ccadastro From aSize[7],0 To aSize[6],aSize[5] OF oMainWnd  Pixel
		oDlg5:lMaximized := .T.
		
		//Painel de Fundo
		oPanel := TPanel():New(00,00,,oDlg5,,,,,,0,0,.F.,.F.)
		oPanel:Align   := CONTROL_ALIGN_ALLCLIENT
			
			//Painel dos campos
			oPanelCmps := TPanel():New(00,00,,oPanel,,,,,,0,60,.F.,.F.)
			oPanelCmps:Align:= CONTROL_ALIGN_TOP
			
					@ 03,10 SAY OemToAnsi(STR0005) OF oPanelCmps Pixel //"Laudo"
					@ 02,45 MSGET TO0->TO0_LAUDO When .f. OF oPanelCmps Pixel
			
					@ 16,10 SAY OemToAnsi(STR0006) OF oPanelCmps Pixel //"Nome" 
					@ 16,45 MSGET TO0->TO0_NOME When .f. SIZE 180,7 OF oPanelCmps Pixel
			
					@ 29,10 SAY OemToAnsi(STR0007) OF oPanelCmps Pixel  //"Data Início"
					@ 28,45 MSGET TO0->TO0_DTINIC When  .f. SIZE 50,7 OF oPanelCmps HasButton Pixel 
			
					@ 29,120 SAY OemToAnsi(STR0008) OF oPanelCmps Pixel  //"Data Fim"
					@ 28,150 MSGET TO0->TO0_DTFIM When .f. SIZE 50,7 OF oPanelCmps HasButton Pixel
					
					@ 43,09  BUTTON STR0002 OF oPanelCmps Pixel SIZE 40,12  ACTION { | | fMarkQuest( oGet ) }//Questionario
			
			//Painel da MsGetDados
			oPanelGet := TPanel():New(00,00,,oPanel,,,,,,0,0,.F.,.F.)
			oPanelGet:Align:= CONTROL_ALIGN_ALLCLIENT
				
				oGet := MSGetDados():New(00,00,00,00,nOpcx,"MDT228LOK","MDT228TOK","",.T.,,,,3000,,,,, oPanelGet )
				oGet:oBrowse:Align := CONTROL_ALIGN_ALLCLIENT
		 
		NGPOPUP(asMenu,@oMenu,oPanel)
		oPanel:bRClicked:= { |o,x,y| oMenu:Activate(x,y,oPanel)}      
	
	ACTIVATE MSDIALOG oDLG5 ON INIT EnchoiceBar(oDLG5,{||nOPCAP:=1,if(oGet:TudoOk(),oDLG5:End(),nOPCAP := 0)},{||oDLG5:End()},,aButtons)
	
	If nOPCAP == 1   
		Begin Transaction 
			NG228GRAVA()   
		End Transaction
EndIf

//---------------------------------------------------------------------
/*/{Protheus.doc} MDT228LOK
Valida a linha da GetDados Digitada

@author Taina Alberto Cardoso
@since 25/04/13
@version MP11
@return Nil
/*/
//---------------------------------------------------------------------
Function MDT228LOK(o)
	
	Local xx := 0, lRET := .T.
	Local nX
	Local nPOS := aSCAN(aHEADER,{|x| Trim(Upper(x[2])) == "TIF_QUEST"})
	
	If acols[n][len(acols[n])]
		Return .t.
	Endif
	
	For nX := 1 to Len(aCOLS)
		If nX != n .and. !acols[nx][len(acols[nx])] .and. aCOLS[nX][1] == aCols[n][1]
			xx++
			Exit
		EndIf 
	Next
	
	If xx > 0
		Help(" ",1,"JAEXISTINF")
		lRet := .f.
	Endif

Return lRet

//---------------------------------------------------------------------
/*/{Protheus.doc} MDT228TOK
Valida toda a GetDados

@author Taina Alberto Cardoso
@since 25/04/13
@version MP11
@return Nil
/*/
//---------------------------------------------------------------------
Function MDT228TOK()
	Private nColuna := Len(aCols[n])
	ASORT(aCols,,, { |x, y| x[nColuna] .and. !y[nColuna] } )
Return .t.

//---------------------------------------------------------------------
/*/{Protheus.doc} NG228GRAVA

Grava os Questionários do Laudo

@author Taina Alberto Cardoso
@since 25/04/13
@version MP11
@return Nil
/*/
//---------------------------------------------------------------------
Function NG228GRAVA()
	Local aBACK := aCLONE(aCOLS)
	Local nx,i
	Local nPOS1 := aSCAN(aHEADER,{|x| Trim(Upper(x[2])) == "TIF_QUEST"})
	
	aEVAL(aBACK, {|x| If( !Empty(x[1]),  AAdd(aCOLS,x), NIL) })
	
	cSeekTIF := xFilial("TIF")+TO0->TO0_LAUDO
	Private cWhileTIF := "TIF->TIF_FILIAL + TIF->TIF_LAUDO"
	
	DbSelectArea("TIF")
	DbSetOrder(1)
	
	For nx := 1 To Len(aCols)
		If aCols[nx][Len(aCols[nx])]
			dbSelectArea("TIF")
			If DbSeek(cSeekTIF+aCols[nx][nPOS1])
				RecLock("TIF",.F.,.T.)
				dbDelete()
				MSUNLOCK("TIF")
			EndIf
			dbSelectArea("TIF")
			Loop
		Endif
		If !empty(aCols[nx][nPos1])
			dbSelectArea("TIF")
			If DbSeek(cSeekTIF+aCols[nx][nPos1])
				RecLock("TIF",.F.)
			Else
				RecLock("TIF",.T.)
			Endif
			TIF->TIF_FILIAL := xFilial("TIF")
			TIF->TIF_LAUDO  := TO0->TO0_LAUDO
			dbSelectArea("TIF")
			FOR i := 1 TO FCount()
				If FieldName(i) == "TIF_FILIAL" .OR. FieldName(i) == "TIF_LAUDO" .or.;
					aSCAN(aHEADER, {|x| AllTrim(Upper(X[2])) == FieldName(i) }) < 1
					Loop
				EndIf   
				x   := "m->" + FieldName(i)
				&x. := aCols[nx][aSCAN(aHEADER, {|x| AllTrim(Upper(X[2])) == FieldName(i) })]         
				y   := "TIF->" + FieldName(i)
				&y := &x
			Next i
			MSUNLOCK("TIF")
		Endif
	Next nx
	
	Dbselectarea("TIF")
	DbSeek(cSeekTIF)
	While !eof() .and. cSeekTIF == &(cWhileTIF)
	      lDelete := .t.
	      For nx := 1 To Len(aCols)
	          If trim(TIF->TIF_QUEST) == Trim(aCols[nx][nPos1])
	             lDelete := .f.
	          Endif
	      Next nx
	
	      If lDelete 
	          Reclock("TIF",.f.,.t.)
	          Dbdelete()
	          MsunLock("TIF")
	      Endif
	
	      Dbselectarea("TIF")
	      Dbskip()
	End
Return .t.

//---------------------------------------------------------------------
/*/{Protheus.doc} fMarkQuest
Mostra um markbrowse com todos os Requisitos Legais
para poder seleciona-los de uma so vez.(Baseado na funcao MDT230BU)

@author Guilherme Freudenburg
@since 23/07/2014
@version 11
@return Nil
/*/
//---------------------------------------------------------------------
Static Function fMarkQuest( oGetRE )
Local aArea 		:= GetArea()
//Variaveis para montar TRB
Local aDBF,aTRB
Local oTempTRB
//Variaveis de Tela      
Local oDlgReq,oFont
Local oMARKFReq
Local oPnlMSG
//Variaveis Locais
Local bOkReq	 	:= {|| nOpcao := 1,oDlgReq:End()}
Local bCancelReq 	:= {|| nOpcao := 0,oDlgReq:End()}
Local nOpcao
Local lInverte, lRet 
Local cAliasTRB 	:= GetNextAlias()
Local aDescIdx	:= {}
Local cPesquisar	:=Space( 200 )   

Private cMarca 	:= GetMark()     
Private OldCols 	:= aCLONE(aCols)   
Private aCbxPesq 	//ComboBox com indices de pesquisa
Private cCbxPesq	:= ""
Private oCbxPesq 	//ComboBox de Pesquisa
lInverte:= .f.

//Valores e Caracteristicas da TRB
aDBF := {}
AADD(aDBF,{ "TRB_OK"      , "C" ,02      					, 0 })
AADD(aDBF,{ "TRB_QUEST"   , "C" ,TamSX3("TIF_QUEST")[1]	, 0 })
AADD(aDBF,{ "TRB_DESQUE"  , "C" ,TamSX3("TIF_DESQUE")[1], 0 })

aTRB := {}  
AADD(aTRB,{ "TRB_OK"    	,NIL	," "	  	,})
AADD(aTRB,{ "TRB_QUEST"	,NIL	,STR0009	,}) //"Questionário"
AADD(aTRB,{ "TRB_DESQUE"	,NIL	,STR0010	,}) //"Descrição "

//Cria TRB
oTempTRB := FWTemporaryTable():New( cAliasTRB, aDBF )
oTempTRB:AddIndex( "1", {"TRB_QUEST"} )
oTempTRB:AddIndex( "2", {"TRB_DESQUE"} )
oTempTRB:AddIndex( "3", {"TRB_OK"} )
oTempTRB:Create()

dbSelectArea("TIB")

Processa({|lEnd| fBuscaReq( cAliasTRB , oGetRE ) } , STR0012,STR0011 )//"Buscando Requisitos..."//"Espere"
Dbselectarea(cAliasTRB)
Dbgotop()

If (cAliasTRB)->(Reccount()) <= 0
	oTempTRB:Delete()
	RestArea(aArea)
	lRefresh := .t.
	ShowHelpDlg( STR0013 ,{ STR0014 } ,1 ,{ STR0025 } ,1 )//"ATENÇÃO"##"Não existem Questionários Químicos cadastrados"##"Incluir um Questionário Químico."
	Return .t.
Endif 
 
nOpcao := 0

DEFINE MSDIALOG oDlgReq TITLE OemToAnsi(STR0015) From 64,160 To 580,730 OF oMainWnd Pixel  //"Questionários Quimicos"
	
		oPnl 		:= TPanel():New( 01 , 01 , , oDlgReq , , , , CLR_BLACK , CLR_WHITE , 0 , 55 , .T. , .F. )
		oPnl:Align	:= CONTROL_ALIGN_TOP 
		
		@ 8,9.6 TO 45,280 OF oPnl PIXEL
		TSay():New(19,12,{|| OemtoAnsi(STR0016) },oPnl,,,.F.,.F.,.F.,.T.,CLR_BLACK,CLR_WHITE,200,010)//"Estes são os planos cadastrados no sistema."
		TSay():New(29,12,{|| OemtoAnsi(STR0017) },oPnl,,,.F.,.F.,.F.,.T.,CLR_BLACK,CLR_WHITE,200,010)//"Selecione aqueles que foram avaliados no laudo."

		//PESQUISAR
		//Define as opcoes de Pesquisa  
		aCbxPesq := aClone( aDescIdx )       
		aAdd( aCbxPesq , STR0018 ) //"Código+Descrição"
		aAdd( aCbxPesq , STR0019 ) //"Descrição+Código"  
		aAdd( aCbxPesq , STR0020 ) //"Marcados"   
		cCbxPesq := aCbxPesq[ 1 ]  
 
	oPnlMSG := TPanel():New(0, 0, Nil, oDlgReq, Nil, .T., .F., Nil, Nil, 0, 55, .T., .F. )
	oPnlMSG:Align := CONTROL_ALIGN_TOP
	
	oCbxPesq := TComboBox():New( 010 , 002 , { | u | If( PCount() > 0 , cCbxPesq := u , cCbxPesq ) } , ;  
	aCbxPesq , 200 , 08 , oPnlMSG , , { | | } ;
	, , , , .T. , , , , , , , , , "cCbxPesq" )  
	oCbxPesq:bChange := { | | fIndexSet( cAliasTRB , aCbxPesq , @cPesquisar , oMARKFReq ) }
	
	oPesquisar := TGet():New( 025 , 002 , { | u | If( PCount() > 0 , cPesquisar := u , cPesquisar ) } , oPnlMSG , 200 , 008 , "" , { | | .T. } , CLR_BLACK , CLR_WHITE , ,;
	.F. , , .T. /*lPixel*/ , , .F. , { | | .T. }/*bWhen*/ , .F. , .F. , , .F. /*lReadOnly*/ , .F. , "" , "cPesquisar" , , , , .F. /*lHasButton*/ )
	 				
	oBtnPesq := TButton():New( 010 , 220 , STR0021 , oPnlMSG , { | | fTRBPes( cAliasTRB , oMARKFReq , cPesquisar) } , ;//"Pesquisar"
	60 , 10 , , , .F. , .T. , .F. , , .F. , , , .F. ) 

		oMARKFReq := MsSelect():NEW(cAliasTRB,"TRB_OK",,aTRB,@lINVERTE,@cMARCA,{100,5,264,281},,,oDlgReq) 
		oMARKFReq:oBROWSE:lHASMARK		:= .T.
		oMARKFReq:oBROWSE:lCANALLMARK	:= .T.    
		oMARKFReq:oBROWSE:bALLMARK		:= {|| MDTA226INV(cMarca,cAliasTRB) }//Funcao inverte marcadores
		oMARKFReq:oBROWSE:ALIGN			:= CONTROL_ALIGN_ALLCLIENT

EnchoiceBar(oDlgReq,bOkReq,bCancelReq)   

ACTIVATE MSDIALOG oDlgReq CENTERED    

lRet := ( nOpcao == 1 )  

If lRet
	MDT228CPY(@oGetRE,cAliasTRB)//Função para copiar os questionários para a GetDados
Endif

oTempTRB:Delete() 

RestArea(aArea)

Return lRet
//---------------------------------------------------------------------
/*/{Protheus.doc} MDT228CPY
Copia os planos selecionados no markbrowse para a GetDados.

@author Guilherme Freudenburg
@since 23/07/2014
@version 11
@return Nil
/*/
//---------------------------------------------------------------------
Static Function MDT228CPY(oGetRE,cAliasTRB)
Local nCols, nPosCod 
Local aColsOk := aClone(aCols)		//Copia do aCols utilizado
Local aHeadOk := aClone(aHeader)	//Copia o aHeader
Local aColsTp := BLANKGETD(aHeadOk)

nPosCod := aScan( aHeadOk,{|x| Trim(Upper(x[2])) == "TIF_QUEST"})	//Verificar a posição do campo
nPosDes := aScan( aHeadOk,{|x| Trim(Upper(x[2])) == "TIF_DESQUE"})	//Verificar a posição do campo

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
	If !Empty((cAliasTRB)->TRB_OK) .AND. aScan( aColsOk , {|x| x[nPosCod] == (cAliasTRB)->TRB_QUEST } ) == 0
		aAdd(aColsOk,aClone(aColsTp[1]))
		aColsOk[Len(aColsOk),nPosCod] := (cAliasTRB)->TRB_QUEST
		aColsOk[Len(aColsOk),nPosDes] := (cAliasTRB)->TRB_DESQUE
	EndIf
	(cAliasTRB)->(dbSkip())
End

If Len(aColsOK) <= 0
	aColsOK := aClone(aColsTp)
EndIf

aSort(aColsOK,,,{ |x, y| x[1] < y[1] }) //Ordena por plano
aCols := aClone(aColsOK)
oGetRE:oBrowse:Refresh()
Return .T.
//---------------------------------------------------------------------
/*/{Protheus.doc} MDTA226INV
Inverte a marcacao do browse.

@author Guilherme Freudenburg
@since 23/07/2014
@version 11
@return Nil
/*/
//---------------------------------------------------------------------
Static Function MDTA226INV(cMarca,cAliasTRB)
Local aArea := GetArea()

dbSelectArea(cAliasTRB)
dbGoTop()
While !(cAliasTRB)->(Eof())//Verificar se não é fim de arquivo
	(cAliasTRB)->TRB_OK := IF(Empty((cAliasTRB)->TRB_OK),cMARCA," ")
	(cAliasTRB)->(dbskip())
End

RestArea(aArea)
Return .T.
//---------------------------------------------------------------------
/*/{Protheus.doc} fBuscaReq
Funcao para retornar todos os Questionários Químicos.

@author Guilherme Freudenburg
@since 23/07/2014
@version 11
@return Nil
/*/
//---------------------------------------------------------------------
Static Function fBuscaReq( cAliasTRB , oGetRE )
Local nPosCod := 1
Local aArea   := GetArea()
Local aColsOK := aClone(aCols)
Local aHeadOk := aClone(aHeader)

nPosCod := aScan( aHeadOk,{|x| Trim(Upper(x[2])) == "TIF_QUEST"})//Verificar a posição do campo
  
dbSelectArea("TIB")
dbSetOrder(1)
If dbSeek(xFilial("TIB"))
	While TIB->(!Eof()) .AND. TIB->TIB_FILIAL == xFilial("TIB")
		RecLock(cAliasTRB,.T.)
		(cAliasTRB)->TRB_OK     	:= If( aScan( aColsOk , {|x| x[nPosCod] == TIB->TIB_CODIGO } ) > 0, cMarca , " " )
		(cAliasTRB)->TRB_QUEST 	:= TIB->TIB_CODIGO
		(cAliasTRB)->TRB_DESQUE 	:= TIB->TIB_DESCRI
		(cAliasTRB)->(MsUnLock())		
		TIB->(dbSkip())
	End
EndIf

RestArea(aArea)
Return
//---------------------------------------------------------------------
/*/{Protheus.doc} fTRBPes
Funcao de Pesquisar no Browse.

@return Sempre verdadeiro

@param cAliasTRB1	- Alias do MarkBrowse ( Obrigatório )
@param oMark 		- Objeto do MarkBrowse ( Obrigatório )
@param cPesquisar	- Valor que sera pesquisado  

@author Guilherme Freudenburg
@since 23/07/2014
/*/
//---------------------------------------------------------------------
Static Function fTRBPes(cAliasTRB , oMark , cPesquisar )
 
	Local nRecNoAtu 	:= 1//Variavel para salvar o recno
	Local lRet			:= .T.
	
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
		ApMsgInfo( STR0022 , STR0013 ) //"Valor não encontrado."###"Atenção"
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
@since 23/07/2014
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
@since 23/07/2014
/*/
//---------------------------------------------------------------------
Static Function fIndComb( aIndMrk )   

	Local nIndice := aScan( aIndMrk , { | x | AllTrim( x ) == AllTrim( cCbxPesq ) } )
   
	// Se o indice nao foi encontrado nos indices pre-definidos, apresenta mensagem
	If nIndice == 0
		ShowHelpDlg( STR0013 ,	{ STR0023 } , 1 , ; //"Atenção"###"Índice não encontrado."
									{ STR0024 } , 1 ) //"Contate o administrador do sistema."
		nIndice := 1 
	Endif

Return nIndice