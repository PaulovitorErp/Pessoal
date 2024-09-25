#Include "Protheus.ch"
#Include "Mdta183.ch"

#DEFINE _nVERSAO 2 //Versao do fonte  

//---------------------------------------------------------------------
/*/{Protheus.doc} MDTA183
Cadastro de Produtos Quimicos.

@author Hugo R. Pereira
@since 18/01/2013
@version MP10
@return Nil
/*/
//---------------------------------------------------------------------
Function MDTA183

	Local aNGBEGINPRM := NGBEGINPRM(_nVERSAO) // Armazena variaveis para devolucao [NGRIGHTCLICK]
	Local lSigaMdtPs  := GetNewPar("MV_MDTPS","N") == "S"
	Local nX		  := 0
	Local aCampos	  := { 	{ "TJB_RISSYP" , "TJB_MRISCO"	} , ; 
							{ "TJB_CARSYP" , "TJB_MCARAC"	} , ;
							{ "TJB_PRCSYP" , "TJB_MPRCAT"	} , ;
							{ "TJB_ESTSYP" , "TJB_MESTOC"	} , ;
							{ "TJB_DESSYP" , "TJB_MDESCA"	} , ;
							{ "TJB_TRASYP" , "TJB_MTRANS"	} , ;
							{ "TJB_LOCSYP" , "TJB_MLOCAL"	} 	}
	
	If !AliasInDic("TJB") .And. !NGCADICBASE("TJB_CODPRO","A","TJB",.F.)
		If !NGINCOMPDIC("UPDMDT58","TGOSM1",.F.)
			NGRETURNPRM(aNGBEGINPRM) // Devolve variaveis armazenadas [NGRIGHTCLICK]
			Return
		Endif
	Endif  
	
	Private cCadastro := OemtoAnsi( If(lSigaMdtPs, STR0007, STR0008) ) // "Clientes" ## "Produtos Químicos"
	Private aMemos	  := {}
	
	For nX := 1 to len( aCampos )
		If TJB->( ColumnPos( aCampos[nX][1] ) ) > 0
			AADD( aMemos , { aCampos[nX][1] , aCampos[nX][2] } )
		EndIf
	Next
	
	SetBrwChgAll(.F.)
	
	Mdt183Brw( If( lSigaMdtPs, "SA1", "TJB" ), 1, MenuDef(lSigaMdtPs,.F.) )
	
	NGRETURNPRM(aNGBEGINPRM) // Devolve variaveis armazenadas [NGRIGHTCLICK]
	  
Return

//---------------------------------------------------------------------
/*/{Protheus.doc} MenuDef
Menu Funcional.

@author Hugo R. Pereira
@since 18/01/2013
@version MP10
@return Nil
/*/
//---------------------------------------------------------------------
Static Function MenuDef(lMdtPs,lMdi)
	
	Local aRotina := {}
	
	Default lMdtPs := GetNewPar("MV_MDTPS","N") == "S"
	Default lMdi	:= .T.
	
	If lMdtPs
		aRotina := {	{ STR0001 , "AxPesqui" , 0, 1 } ,; // "Pesquisar"
						{ STR0002, "NGCAD01"   , 0, 2 } ,; // "Visualizar"
						{ STR0006, "MDT183PSPQ", 0, 4 } }  // "Prod. Químicos"
	Else
		aRotina := {	{ STR0001, "AxPesqui" , 0, 1 } ,;   // "Pesquisar"
						{ STR0002, "MDT183CAD", 0, 2 } ,;   // "Visualizar"
						{ STR0003, "MDT183CAD", 0, 3 } ,;   // "Incluir"
						{ STR0004, "MDT183CAD", 0, 4 } ,;   // "Alterar"
						{ STR0005, "MDT183CAD", 0, 5 } }   // "Excluir"
						
		If !lMdi .AND. AliasInDic("TJ9")
			aAdd(aRotina,{ STR0011 , "MDT183EPI", 0, 4 })    // "EPIs"
		EndIf
	Endif
	
Return aRotina

//---------------------------------------------------------------------
/*/{Protheus.doc} Mdt183Brw
Tela inicialm para selecao de Cliente. [Prestador de Servico]

@author Hugo R. Pereira
@since 18/01/2013
@version MP10
@return Nil
/*/
//---------------------------------------------------------------------
Static Function Mdt183Brw(cAliasBrw, nOrdBrw, aRotPar)
	
	Default aRotPar := {}
	Default nOrdBrw := 1
	
	Private aRotina := aClone(aRotPar)
	
	If Len(aRotina) == 0
		Return
	Endif
	
	dbSelectArea(cAliasBrw)
	dbSetOrder(nOrdBrw)
	mBrowse(6, 1, 22, 75, cAliasBrw)
	
Return

//---------------------------------------------------------------------
/*/{Protheus.doc} MDT183PSPQ
Tela inicialm para selecao de Cliente. [Prestador de Servico]

@author Hugo R. Pereira
@since 18/01/2013
@version MP10
@return Nil
/*/
//---------------------------------------------------------------------
Function MDT183PSPQ(cAlias, nRecno, nOpcx)
	
	Private cCliMdtPs := SA1->A1_COD + SA1->A1_LOJA	
	
	dbSelectArea("TJB")
	Set Filter To TJB->TJB_CLIENT + TJB->TJB_LOJA == cCliMdtps
	
	Mdt183Brw( "TJB", 2, MenuDef(.F.,.F.) )
	
	dbSelectArea("TJB")
	Set Filter To
	
Return

//---------------------------------------------------------------------
/*/{Protheus.doc} MDT183CAD
Cadastro de produtos químicos.

@author Hugo R. Pereira
@since 18/01/2013
@version MP10
@return Nil
/*/
//---------------------------------------------------------------------
Function MDT183CAD(cAlias, nRecno, nOpcx)
	
	Local lSigaMdtPs  := GetNewPar("MV_MDTPS","N") == "S"
	Local nOk := 0
	Local lRet := .T.
	Local aIndTJC := NGRETINDTAB("TJC")
	Local nX
	Local aCampos  := { 	{ "TJB_RISSYP" , "TJB_MRISCO"	} , ; 
							{ "TJB_CARSYP" , "TJB_MCARAC"	} , ;
							{ "TJB_PRCSYP" , "TJB_MPRCAT"	} , ;
							{ "TJB_ESTSYP" , "TJB_MESTOC"	} , ;
							{ "TJB_DESSYP" , "TJB_MDESCA"	} , ;
							{ "TJB_TRASYP" , "TJB_MTRANS"	} , ;
							{ "TJB_LOCSYP" , "TJB_MLOCAL"	} 	}
	
	Private cCadastro := OemtoAnsi(STR0008) // "Produtos Químicos"
	Private aChkDel   := {}
	Private bNGGRAVA  := {|| fExcluiRel( nOpcx ) }
	
	aMemos := {}
	For nX := 1 to len( aCampos )
		If TJB->( FieldPos( aCampos[nX][1] ) ) > 0
			AADD( aMemos , { aCampos[nX][1] , aCampos[nX][2] } )
		EndIf
	Next
	
	If lSigaMdtPs
		aChkDel   := { {'TJB->TJB_CLIENT+TJB->TJB_LOJA+TJB->TJB_CODPRO' , "TJD", 4} }
		If len( aIndTJC ) >= 4
			aAdd( aChkDel , {'TJB->TJB_CLIENT+TJB->TJB_LOJA+TJB->TJB_CODPRO' , "TJC", 4} )
		EndIf
		If AliasInDic( "TIB" )
			aAdd( aChkDel , {'TJB->TJB_CODPRO' , "TIB", 3} )
		EndIf
	Else
		aChkDel   := {	{'TJB->TJB_CODPRO' , "TJD", 2} }
		If len( aIndTJC ) >= 2
			aAdd( aChkDel , {'TJB->TJB_CODPRO' , "TJC", 2} )
		EndIf
		If AliasInDic( "TIB" )
			aAdd( aChkDel , {'TJB->TJB_CODPRO' , "TIB", 3} )
		EndIf
	Endif
	
	If nOpcx == 5
		If !NGCHKDEL("TIB")
			lRet := .F.
		EndIf	
	EndIf
	
	If lRet 
		nOk := NGCAD01(cAlias, nRecno, nOpcx)
	EndIf

Return
//---------------------------------------------------------------------
/*/{Protheus.doc} MDT183VPRD
Validacao do campo Produto [TJB_CODPRO].

@author Hugo R. Pereira
@since 18/01/2013
@version MP10
@return Nil
/*/
//---------------------------------------------------------------------
Function MDT183VPRD(lSXB)
Local cTipo := SuperGetMv("MV_MDTPEPI",.F.,"")
Local lRet := .T.
Local aEpis := STRTOKARR( cTipo , ";" )//Separa os itens que foram inseridos
Local nEpi := 0
Local aAreaSB1 := {}

Default lSXB := .F.

	If !lSXB 
		// Verifica existencia de codigo na tabela SB1, e da chave na TJB
		If !Empty(M->TJB_CODPRO)
			If !ExistCpo("SB1",M->TJB_CODPRO) .Or. !MDT182EXPQ(M->TJB_CODPRO, .T.)
				lRet := .F.
			EndIf
		EndIf
	EndIf
	If lRet .AND. !Empty(cTipo)
		aAreaSB1 := SB1->(GetArea())
		dbSelectArea("SB1")
		dbSetOrder(2)
		For nEpi := 1 To Len(aEpis)
			If !lSXB
				MsSeek(xFilial("SB1") + aEpis[nEpi] + M->TJB_CODPRO )
			EndIf
			If SB1->B1_TIPO == aEpis[nEpi]
				lRet := .F.
				Exit
			EndIf
		Next nEpi
		If !lRet .AND. !lSXB
		 	HELP(" ",1,"PRODEPI",,STR0019,2,1) //"Código escolhido refere se a um EPI - Equipamento de Proteção Individual."
		EndIf
		RestArea(aAreaSB1)
	EndIf
	
Return lRet
//---------------------------------------------------------------------
/*/{Protheus.doc} MDT183EPI
Relacionar EPIs ao Produto Quimico

@author Guilherme Benkendorf
@since 12/02/2013
@version MP11
@return Nil
/*/
//---------------------------------------------------------------------
Function MDT183EPI(cAlias , nReg, nOpcx)
	Local lSigaMdtPs  := GetNewPar("MV_MDTPS","N") == "S"
	//Objetos de Tela
	Local oDlgEPI,;
		  oPanel ,;
		  oGetEPI,;
		  oPnlAll,;
		  oMenu
	
	//Variaveis de inicializacao de GetDados
	Local aNoFields := {}
	Local nInd		:= 0
	Local cKeyGet	:= ""
	Local cWhileGet	:= ""
	
	//Variaveis de tela
	Local aInfo		:= {}
	Local aPosObj	:= {}
	Local aSize		:= MsAdvSize(,.f.,430)
	Local aObjects	:= {}
	
	//Variaveis de GetDados
	Local lAltProg	:= If(INCLUI .Or. ALTERA, .T.,.F.)
	Private aCols	:= {}
	Private aHeader := {}
	
	aRotSetOpc( "TJ9" , 1 , 4 )
	
	//Inicializa variaveis de Tela
	Aadd(aObjects,{050,050,.t.,.t.})
	Aadd(aObjects,{100,100,.t.,.t.})
	aInfo   := {aSize[1],aSize[2],aSize[3],aSize[4],0,0}
	aPosObj := MsObjSize(aInfo, aObjects,.t.)
	
	// Monta a GetDados dos Requisitos Legais
	aAdd(aNoFields,"TJ9_CODPRO")
	aAdd(aNoFields,"TJ9_FILIAL")
	
	If lSigaMdtPs
		aAdd(aNoFields,"TJ9_CLIENT")
		aAdd(aNoFields,"TJ9_LOJA")
		nInd		:= 3
		cKeyGet 	:= "SA1->A1_COD+SA1->A1_LOJA+TJB->TJB_CODPRO"
		cWhileGet 	:= "TJ9->TJ9_FILIAL == '"+xFilial("TJ9")+"' .AND. TJ9->TJ9_CODPRO == '"+TJB->TJB_CODPRO+"'"+;
							" .AND. TJ9->TJ9_CLIENT+TJ9->TJ9_LOJA == '"+SA1->A1_COD+SA1->A1_LOJA+"'"
	Else
		nInd		:= 1
		cKeyGet 	:= "TJB->TJB_CODPRO"
		cWhileGet 	:= "TJ9->TJ9_FILIAL == '"+xFilial("TJ9")+"' .AND. TJ9->TJ9_CODPRO == '"+TJB->TJB_CODPRO+"'"
	EndIf
	
	//Monta aCols e aHeader de TJ9
	dbSelectArea("TJ9")
	dbSetOrder(nInd)
	FillGetDados( nOpcx, "TJ9", 1, cKeyGet, {|| }, {|| .T.},aNoFields,,,,;
				{|| NGMontaAcols("TJ9",&cKeyGet,cWhileGet)})
	
	If Empty(aCols)
		aCols := BLANKGETD(aHeader)
	Endif
	
	nOpca := 0 
	
	DEFINE MSDIALOG oDlgEPI TITLE STR0009 From aSize[7],0 To aSize[6],aSize[5] OF oMainWnd PIXEL   //"Prod. Químico x EPIs"
	
		oPnlAll := TPanel():New(,,,oDlgEPI,,,,,,,, .F., .F. )
			oPnlAll:Align := CONTROL_ALIGN_ALLCLIENT
		
		oPanel := TPanel():New(0, 0, Nil, oPnlAll, Nil, .T., .F., Nil, Nil, 0, 60, .T., .F. )
			oPanel:Align := CONTROL_ALIGN_TOP
	        
	        TSay():New( 6 , 7 ,{| | OemtoAnsi(STR0006) },oPanel,,,.F.,.F.,.F.,.T.,CLR_BLACK,CLR_WHITE,020,008)//"Prod. Químico"
			TGet():New( 5 , 27,{|u| If( PCount() > 0 , TJB->TJB_CODPRO := u ,TJB->TJB_CODPRO )},oPanel,40,10,"@!",;
							   ,CLR_BLACK,CLR_WHITE,,,,.T.,"",,{|| .F. },.F.,.F.,,.F.,.F.,,,,,,.T.)
			
			TSay():New( 6 , 84 ,{| | OemtoAnsi(STR0010) },oPanel,,,.F.,.F.,.F.,.T.,CLR_BLACK,CLR_WHITE,020,008)//"Desc. Prod."
			TGet():New( 5 , 120,{|u| If( PCount() > 0 , NGSEEK("SB1",TJB->TJB_CODPRO,1,"B1_DESC") := u , NGSEEK("SB1",TJB->TJB_CODPRO,1,"B1_DESC") )},;
								oPanel,150,10,"@!",,CLR_BLACK,CLR_WHITE,,,,.T.,"",,{|| .F. },.F.,.F.,,.F.,.F.,,,,,,.T.)
		    
			TButton():New( 30 , 5 , "&"+STR0011, oPanel, {|| MDT183BU(@oGetEPI) } , 49 , 12 ,, /*oFont*/,,.T.,,,,/* bWhen*/,,)//"EPIs"
		
			PutFileInEof("TJ9")
			oGetEPI := MsNewGetDados():New(0,0,200,210,IIF(!lAltProg,0,GD_INSERT+GD_UPDATE+GD_DELETE),;
	 								{|| MDT183Lin("TJ9",,@oGetEPI)},{|| MDT183Lin("TJ9",.T.,@oGetEPI)},/*cIniCpos*/,/*aAlterGDa*/,;
	   								/*nFreeze*/,/*nMax*/,/*cFieldOk */,/*cSuperDel*/,/*cDelOk */,oPnlAll,aHeader,aCols)
			oGetEPI:oBrowse:Align := CONTROL_ALIGN_ALLCLIENT
	
		NGPOPUP(asMenu,@oMenu,oPanel)
		oPanel:bRClicked:= { |o,x,y| oMenu:Activate(x,y,oPanel)}
		aSort(oGetEPI:aCOLS,,,{ |x, y| x[1] < y[1] }) //Ordena por EPIs
		
	ACTIVATE MSDIALOG oDlgEPI ON INIT EnchoiceBar(oDlgEPI,{|| nOpca:=1,If(MDT183TOk(@oGetEPI), oDlgEPI:End(), nOpca := 0)},{|| oDlgEPI:End(),nOpca := 0})
	
	If nOpca == 1
		fGravaEPI(@oGetEPI)//Grava EPIs
	Endif

Return .T.
//---------------------------------------------------------------------
/*/{Protheus.doc} MDT183BU 
 Mostra um markbrowse com todos os Produtos(EPI)para poder seleciona-los
 de uma so vez.(Baseado na funcao MDT230BU)

@author Guilherme Benkendorf
@since 12/02/13
@version MP10
@return Nil
/*/
//---------------------------------------------------------------------
Static Function MDT183BU( oGetEPI )
Local aArea := GetArea()
//Variaveis para montar TRB
Local aDBF,aTRBEPI
//Variaveis de Tela      
Local oDlgEPIS
Local oMARKEPI
//
Local nOpt
Local lInverte, lRet
Local cAliasTRB := GetNextAlias()
Local oDlgEPI
Local oPanelEPI
Local oTempTRB

Private cMarca := GetMark()    

lInverte:= .f.

//Valores e Caracteristicas da TRB
aDBF := {}
AADD(aDBF,{ "TRB_OK"	,	"C" ,02							, 0 })
AADD(aDBF,{ "TRB_CODEPI",	"C" ,TamSX3("TJ9_CODEPI")[1]	, 0 })
AADD(aDBF,{ "TRB_DESC"	,	"C" ,TamSX3("TJ9_DESC")[1]		, 0 })

aTRBEPI := {}  
AADD(aTRBEPI,{ "TRB_OK"		,NIL," "		,})
AADD(aTRBEPI,{ "TRB_CODEPI"	,NIL,"Cod. EPI"	,})  //"Cod. EPI"
AADD(aTRBEPI,{ "TRB_DESC"	,NIL,"Desc. EPI",})  //"Desc. EPI"

oTempTRB := FWTemporaryTable():New( cAliasTRB, aDBF )
oTempTRB:AddIndex( "1", {"TRB_CODEPI"} )
oTempTRB:Create()

dbSelectArea("SB1")

Processa({|lEnd| fBuscaEPI( cAliasTRB , oGetEPI )},STR0012 + "...",STR0013)//"Buscando EPI" ## "Espere"

Dbselectarea(cAliasTRB)
Dbgotop()
If (cAliasTRB)->(Reccount()) <= 0
	oTempTRB:Delete()
	RestArea(aArea)
	lRefresh := .t.
	Msgstop(STR0014,STR0015)  //"Não existem Produtos(EPI) cadastrados" //"ATENÇÃO" 
	Return .t.
Endif

nOpt := 0

DEFINE MSDIALOG oDlgEPIS TITLE OemToAnsi(STR0016) From 64,160 To 580,736 OF oMainWnd Pixel  //"Produtos(EPI)"
	
		oPanelEPI := TPanel():New( 0 , 0 , , oDlgEPIS , , .T. , .F. , , , 0 , 55 , .T. , .F. )
		oPanelEPI:Align := CONTROL_ALIGN_ALLCLIENT
	
		@ 8,9.6 TO 45,280 OF oPanelEPI PIXEL
		TSay():New(19,12,{|| OemtoAnsi(STR0017) },oPanelEPI,,,.F.,.F.,.F.,.T.,CLR_BLACK,CLR_WHITE,200,010)//"Estes são os EPIs cadastrados no sistema."
		TSay():New(29,12,{|| OemtoAnsi(STR0018) },oPanelEPI,,,.F.,.F.,.F.,.T.,CLR_BLACK,CLR_WHITE,200,010)//"Selecione aqueles que foram avaliados no Prod. Químico."
		
	   	oMARKEPI := MsSelect():NEW(cAliasTRB,"TRB_OK",,aTRBEPI,@lINVERTE,@cMARCA,{ 56 , 0 , 246 , 300 },,,oPanelEPI)
		oMARKEPI:oBROWSE:lHASMARK		:= .T.
		oMARKEPI:oBROWSE:lCANALLMARK	:= .T.
		oMARKEPI:oBROWSE:bALLMARK		:= {|| MDTA183INV(cMarca,cAliasTRB) }//Funcao inverte marcadores
	   		 
ACTIVATE MSDIALOG oDlgEPIS ON INIT EnchoiceBar(oDlgEPIS,{|| nOpt := 1,oDlgEPIS:End()},{|| nOpt := 0,oDlgEPIS:End()}) CENTERED

lRet := ( nOpt == 1 )  
  
If lRet
	MDT183CPY(@oGetEPI,cAliasTRB)//Funcao para copiar planos a GetDados
Endif

oTempTRB:Delete()

RestArea(aArea)

Return lRet
//---------------------------------------------------------------------
/*/{Protheus.doc} MDT183CPY 
Copia os planos selecionados no markbrowse para a GetDados 

@author Guilherme Benkendorf
@since 12/02/13
@version MP10
@return Nil
/*/
//---------------------------------------------------------------------
Static Function MDT183CPY(oGetEPI,cAliasTRB)
	Local nCols, nPosCod
	Local aColsOk := aClone(oGetEPI:aCols)
	Local aHeadOk := aClone(oGetEPI:aHeader)
	Local aColsTp := BLANKGETD(aHeadOk)
	
	nPosCod := aScan( aHeadOk,{|x| Trim(Upper(x[2])) == "TJ9_CODEPI"})
	nPosDes := aScan( aHeadOk,{|x| Trim(Upper(x[2])) == "TJ9_DESC"})
	
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
		If !Empty((cAliasTRB)->TRB_OK) .AND. aScan( aColsOk , {|x| x[nPosCod] == (cAliasTRB)->TRB_CODEPI } ) == 0
			aAdd(aColsOk,aClone(aColsTp[1]))
			aColsOk[Len(aColsOk),nPosCod] := (cAliasTRB)->TRB_CODEPI
			aColsOk[Len(aColsOk),nPosDes] := (cAliasTRB)->TRB_DESC
		EndIf
		(cAliasTRB)->(dbSkip())
	End
	
	If Len(aColsOK) <= 0
		aColsOK := aClone(aColsTp)
	EndIf
	
	aSort(aColsOK,,,{ |x, y| x[1] < y[1] }) //Ordena por EPI
	oGetEPI:aCols := aClone(aColsOK)
	oGetEPI:oBrowse:Refresh()
Return .T.
//---------------------------------------------------------------------
/*/{Protheus.doc} MDTA183INV 
Inverte a marcacao do browse 

@author Guilherme Benkendorf
@since 12/02/13
@version MP10
@return Nil
/*/
//---------------------------------------------------------------------
Static Function MDTA183INV(cMarca,cAliasTRB)
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
/*/{Protheus.doc} fGravaEPI 
Funcao para gravar dados da MsNewGetDados,Produtos(EPIs) na TJ9

@author Guilherme Benkendorf
@since 12/02/13
@version MP10
@return Nil
/*/
//---------------------------------------------------------------------
Static Function fGravaEPI( oObjeto )
	Local lSigaMdtPs  := GetNewPar("MV_MDTPS","N") == "S"
	Local aArea := GetArea()
	Local nX, ny, nZ, nPosCod
	Local nOrd, cKey, cWhile 
	Local aColsOk := aClone(oObjeto:aCols)
	Local aHeadOk := aClone(oObjeto:aHeader)
	
	nPosCod := aScan( aHeadOk,{|x| Trim(Upper(x[2])) == "TJ9_CODEPI"})
	If lSigaMdtPs
		nOrd 	:= 3
		cKey 	:= xFilial("TJ9")+SA1->A1_COD+SA1->A1_LOJA+TJB->TJB_CODPRO
		cWhile  := "xFilial('TJ9')+SA1->A1_COD+SA1->A1_LOJA+TJB->TJB_CODPRO == TJ9->TJ9_FILIAL+TJ9->TJ9_CLIENT+TJ9->TJ9_LOJA+TJ9->TJ9_CODPRO"
	Else
		nOrd 	:= 1
		cKey 	:= xFilial("TJ9")+TJB->TJB_CODPRO
		cWhile  := "xFilial('TJ9')+TJB->TJB_CODPRO == TJ9->TJ9_FILIAL+TJ9->TJ9_CODPRO"
	EndIf
	
	If Len(aColsOK) > 0
		//Coloca os deletados por primeiro
		aSORT(aColsOK,,, { |x, y| x[Len(aColsOK[1])] .and. !y[Len(aColsOK[1])] } )
		
		For nX:=1 to Len(aColsOK)
			If !aColsOK[nX][Len(aColsOK[nX])] .and. !Empty(aColsOK[nX][nPosCod])
				dbSelectArea("TJ9")
				dbSetOrder(nOrd)
				If dbSeek(cKey+aColsOK[nX][nPosCod])
					RecLock("TJ9",.F.)
				Else
					RecLock("TJ9",.T.)
				Endif
				For nZ:=1 to FCount()
					If "_FILIAL"$Upper(FieldName(nZ))
						FieldPut(nZ, xFilial("TJ9"))
					ElseIf "_CODPRO"$Upper(FieldName(nZ))
						FieldPut(nZ, TJB->TJB_CODPRO)
					ElseIf "_CLIENT"$Upper(FieldName(nZ))
						FieldPut(nZ, SA1->A1_COD)
					ElseIf "_LOJA"$Upper(FieldName(nZ))
						FieldPut(nZ, SA1->A1_LOJA)
					ElseIf (nPos := aScan(aHeadOk, {|x| Trim(Upper(x[2])) == Trim(Upper(FieldName(nZ))) }) ) > 0
						FieldPut(nZ, aColsOK[nX,nPos])
					Endif
				Next nZ
				MsUnlock("TJ9")
			Elseif !Empty(aColsOK[nX][nPosCod])
				dbSelectArea("TJ9")
				dbSetOrder(nOrd)
				If dbSeek(cKey+aColsOK[nX][nPosCod])
					RecLock("TJ9",.F.)
					dbDelete()
					MsUnlock("TJ9")
				Endif
			Endif
		Next nX
	Endif
	 
	dbSelectArea("TJ9")
	dbSetOrder(nOrd)
	dbSeek(cKey)
	While !Eof() .and. &(cWhile)
		If aScan( aColsOK,{|x| x[nPosCod] == TJ9->TJ9_CODEPI .AND. !x[Len(x)]}) == 0
			RecLock("TJ9",.f.)
			DbDelete()
			MsUnLock("TJ9")
		Endif
		dbSelectArea("TJ9")
		dbSkip()
	End
	RestArea(aArea)

Return .T.
//---------------------------------------------------------------------
/*/{Protheus.doc} MDT183Lin 
Valida linhas do MsNewGetDados dos Planos Emergenciais

@author Guilherme Benkendorf
@since 12/02/13
@version MP10
@return Nil
/*/
//---------------------------------------------------------------------
Function MDT183Lin(cAlias,lFim,oObjeto)
	Local nX
	Local nPosCod := 1, nAt := 1
	Local nCols, nHead
	Local aColsOk := {}, aHeadOk := {}
	Default lFim := .F.
	
	aColsOk := aClone(oObjeto:aCols)
	aHeadOk := aClone(oObjeto:aHeader)
	nAt     := oObjeto:nAt
	
	If cAlias == "TJ9"
		nPosCod := aScan( aHeadOk,{|x| Trim(Upper(x[2])) == "TJ9_CODEPI"})
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
				//Verifica se os campos obrigatórios estão preenchidos
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
	
	PutFileInEof("TJ9")

Return .T.
//---------------------------------------------------------------------
/*/{Protheus.doc} MDT183TOk 
Função para verificar toda a MsNewGetdados

@author Guilherme Benkendorf
@since 12/02/13
@version MP10
@return Nil
/*/
//---------------------------------------------------------------------
Function MDT183TOk(oObjeto)

	If !MDT183Lin("TJ9",.T.,@oObjeto)
		Return .F.
	Endif

Return .T.
//---------------------------------------------------------------------
/*/{Protheus.doc} fBuscaEPI
Funcao para retornar todos os Produtos EPI

@author Guilherme Benkendorf
@since 12/02/13
@version MP10
@return Nil
/*/
//---------------------------------------------------------------------
Static Function fBuscaEPI( cAliasTRB , oGetEPI )
	Local nPosCod := 1
	Local aArea   := GetArea()
	Local aColsOK := aClone(oGetEPI:aCols)
	Local aHeadOk := aClone(oGetEPI:aHeader)
	Local cSeekSB1:= "SB1->B1_FILIAL+SB1->B1_TIPO"
	Local cTipo := SuperGetMv("MV_MDTPEPI",.F.,"")
	Local aEpis := STRTOKARR( cTipo , ";" )//Separa os itens que foram inseridos
	Local nEpi := 0
	
	nPosCod := aScan( aHeadOk,{|x| Trim(Upper(x[2])) == "TJ9_CODEPI"})
	
	If Empty(cTipo)
		cSeekSB1 := "SB1->B1_FILIAL"
		cTipo := ""
	EndIf
	
	If Len(aEpis) > 1//Caso tenha mais de um tipo de Epi
		For  nEpi:= 1 to  Len(aEpis)//Percorre todos os tipos adicionados
			dbSelectArea("SB1")
			dbSetOrder(2)
			dbSeek(xFilial("SB1")+aEpis[nEpi])
			While SB1->(!Eof()) .AND. &cSeekSB1. == xFilial("SB1")+aEpis[nEpi]
			
				dbSelectArea("TN3")
				dbSetOrder( 2 ) //TN3_FILIAL+TN3_CODEPI
				If !dbSeek( xFilial("TN3") + SB1->B1_COD )
					dbSelectArea("SB1")
					dbSkip()
					Loop
				EndIf
		
				RecLock(cAliasTRB,.T.)
				(cAliasTRB)->TRB_OK		:= If( aScan( aColsOk , {|x| x[nPosCod] == SB1->B1_COD } ) > 0, cMarca , " " )
				(cAliasTRB)->TRB_CODEPI	:= SB1->B1_COD
				(cAliasTRB)->TRB_DESC 	:= SB1->B1_DESC
				(cAliasTRB)->(MsUnLock())		
				SB1->(dbSkip())
			End
		Next nEpi 
	Else//Caso seja somente um tipo ou esteja vazio.
		dbSelectArea("SB1")
		dbSetOrder(2)
		dbSeek(xFilial("SB1")+cTipo)
		While SB1->(!Eof()) .AND. &cSeekSB1. == xFilial("SB1")+cTipo
			
			dbSelectArea("TN3")
			dbSetOrder( 2 ) //TN3_FILIAL+TN3_CODEPI
			If !dbSeek( xFilial("TN3") + SB1->B1_COD )
				dbSelectArea("SB1")
				dbSkip()
				Loop
			EndIf
			
			RecLock(cAliasTRB,.T.)
			(cAliasTRB)->TRB_OK 		:= If( aScan( aColsOk , {|x| x[nPosCod] == SB1->B1_COD } ) > 0, cMarca , " " )
			(cAliasTRB)->TRB_CODEPI	:= SB1->B1_COD
			(cAliasTRB)->TRB_DESC	:= SB1->B1_DESC
			(cAliasTRB)->(MsUnLock())		
			SB1->(dbSkip())
		End
	Endif

RestArea(aArea)

Return
//---------------------------------------------------------------------
/*/{Protheus.doc} fExcluiRel
Exclui o relacionamento com o Produto

@author Jackson Machado
@since 28/03/17
@return Nil
/*/
//---------------------------------------------------------------------
Static Function fExcluiRel( nOpcx )
	
	Local nOrd, cKey, cWhile 
	Local lSigaMdtPs  := GetNewPar("MV_MDTPS","N") == "S"
	
	If lSigaMdtPs
		nOrd 	:= 3
		cKey 	:= xFilial("TJ9")+SA1->A1_COD+SA1->A1_LOJA+TJB->TJB_CODPRO
		cWhile  := "xFilial('TJ9')+SA1->A1_COD+SA1->A1_LOJA+TJB->TJB_CODPRO == TJ9->TJ9_FILIAL+TJ9->TJ9_CLIENT+TJ9->TJ9_LOJA+TJ9->TJ9_CODPRO"
	Else
		nOrd 	:= 1
		cKey 	:= xFilial("TJ9")+TJB->TJB_CODPRO
		cWhile  := "xFilial('TJ9')+TJB->TJB_CODPRO == TJ9->TJ9_FILIAL+TJ9->TJ9_CODPRO"
	EndIf
	
	If nOpcx == 5
		dbSelectArea("TJ9")
		dbSetOrder(nOrd)
		dbSeek(cKey)
		While !Eof() .and. &(cWhile)
			RecLock("TJ9",.F.)
			TJ9->(DbDelete())
			TJ9->(MsUnLock())
			TJ9->(dbSkip())
		End
	EndIf
	
Return .T.