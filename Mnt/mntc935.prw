#INCLUDE "mntc935.ch"
#include "DbTree.ch"
#INCLUDE "PROTHEUS.CH"

//---------------------------------------------------------------------------
/*/{Protheus.doc} MNTC935
Gerencial de Custos

@author Marcos Wagner Junior
@since 06/10/2010
@version undefined

@type function
/*/
//---------------------------------------------------------------------------
Function MNTC935()

	Local aNGBeginPrm := {}
	Local nAltura	  := 0
	Local nI          := 0
	Local nLargura	  := 0
	Local aCampos	  := {}

	If !FindFunction( 'MNTAmIIn' ) .Or. MNTAmIIn( 19, 95 )

		aNGBeginPrm := NGBeginPrm()
		nAltura     := ( GetScreenRes()[2] - 85 )
		nLargura    := ( GetScreenRes()[1] - 7 )

		Private oTree //Tela principal
		Private oBrowseRO1
		Private oPnlDownR1
		Private oDlg
		Private oDlgParame
		Private oPnlButton //menu lateral esquerdo
		Private oNGGraphic
		Private nNGGraType //montar grafico

		// Tela de parametros
		Private dDtI1
		Private dDtI2
		Private dDtI3
		Private dDtI4
		Private dDtI5
		Private dDtI6
		Private dDtF1
		Private dDtF2
		Private dDtF3
		Private dDtF4
		Private dDtF5
		Private dDtF6

		Private cChavePai	:= ''
		Private cCadastro	:= OemToAnsi(STR0001) //"Gerencial de Custos"
		Private aGrafico935	:= {} //Graficos
		Private aColsRod	:= {} //Detalhes

		// NOVOS
		Private oBtnVisual
		Private oBtnGrafic
		Private oBtnRelato
		Private cTRBMAIN := GetNextAlias()
		Private oTmpTA100
		Private cAlias, oEnc
		Private aGets  := Array(0)
		Private aTela  := Array(0,0)

		Private nNivel      := 0
		Private cEmQue      := ''
		Private cStatus     := ''
		Private aStatus     := {}
		Private cAliasQry

		Private lFerrament 	:= .T.
		Private cDeFerram 	:= Space(Len(SH4->H4_CODIGO))
		Private cAteFerram 	:= Replicate('Z',Len(SH4->H4_CODIGO))
		Private lMaodeObra 	:= .T.
		Private cDeMdo    	:= Space(Len(ST1->T1_CODFUNC))
		Private cAteMdo    	:= Replicate('Z',Len(ST1->T1_CODFUNC))
		Private lProduto   	:= .T.
		Private cDeProd   	:= Space(Len(SB1->B1_COD))
		Private cAteProd   	:= Replicate('Z',Len(SB1->B1_COD))
		Private lTerceiro  	:= .T.
		Private cDeTerc   	:= Space(Len(SA2->A2_COD))
		Private cAteTerc   	:= Replicate('Z',Len(SA2->A2_COD))
		Private lEspeciali 	:= .T.
		Private cDeEspec  	:= Space(Len(ST0->T0_ESPECIA))
		Private cAteEspec  	:= Replicate('Z',Len(ST0->T0_ESPECIA))

		Private aSize   	:= MsAdvSize(,.f.,430)
		Private oBrwSTL
		Private aCamposOK 	:= {}
		Private aCamposOK1 	:= {}
		Private aCamposOK2 	:= {}
		Private aBoxEsq 	:= {}
		Private aBoxDir 	:= {}
		Private aNaoPode 	:= {}
		Private nTotalPai 	:= 0
		Private lTemOfi 	:= .f.
		Private lPrxUltNiv 	:= .f.
		Private nPosFrota 	:= 0
		Private nPosPadrao 	:= 0
		Private nDiv := 0
		Private lMsgLeft 	:= .F.
		Private cPERG 		:= PadR( "MNC935", Len(Posicione("SX1", 1, "MNC935", "X1_GRUPO")) )
		Private lGFrota 	:= NGVERUTFR()
		Private cOldTabela 	:= ''
		Private nTamanho 	:= 0
		Private bBoxEsq
		Private bBoxDir
		Private cDescNivPai
		Private cDescNivFil
		Private aTabRegToM
		Private lFirst 		:= .t.
		Private lFolder1
		Private lFolder2
		Private lFolder3
		Private lFolder4
		Private lFolder5
		Private lFolder6
		Private cCaminho 	:= ""
		Private cRENAVA 	:= ''
		Private INCLUI 		:= .F.
		Private ALTERA 		:= .T.
		Private cDESFIL 	:= ''
		Private oBtnTRX
		Private lUltReg := .F.

		// Variaveis utilizadas no NGUTIL
		Private aColorGraph := {CLR_HGREEN,CLR_HBLUE,CLR_HRED,CLR_YELLOW,CLR_BROWN,CLR_CYAN,;
		CLR_MAGENTA,CLR_GRAY,CLR_WHITE,CLR_BLUE,CLR_GREEN,CLR_RED,CLR_HGRAY,;
		CLR_HCYAN,CLR_HMAGENTA,CLR_BLACK,RGB(178,241,18),RGB(131,199,154),;
		RGB(111,156,210),RGB(236,99,120),RGB(255,255,162),RGB(19,88,88),;
		RGB(60,9,60),RGB(141,125,194),RGB(255,93,0),RGB(255,196,0)}

		Store dDataBase-30 To dDtI1, dDtI2, dDtI3, dDtI4, dDtI5, dDtI6
		Store dDataBase To dDtF1, dDtF2, dDtF3, dDtF4, dDtF5, dDtF6
		Store .T. to lFolder1, lFolder2, lFolder3, lFolder4, lFolder5, lFolder6

		aAdd( aCampos, { 'CODEST', 'C', 04, 0 } )
		aAdd(aCampos,{"CODPRO"   ,"C",20,0})
		aAdd(aCampos,{"CODIGO"   ,"C",56,0})
		aAdd(aCampos,{"DESCRI"   ,"C",56,0})
		aAdd(aCampos,{"CHAVFIL"  ,"C",70,0})
		aAdd( aCampos, { 'NIVSUP', 'C', 04, 0 } )
		aAdd(aCampos,{"NIVEL"    ,"N",02,0})
		aAdd(aCampos,{"CNIVEL"   ,"C",02,0})
		aAdd(aCampos,{"CARGO"    ,"C",06,0})
		aAdd(aCampos,{"CHAVPAI"  ,"C",140,0})  //mais que isso pode gerar Maximum index levels exceeded.
		aAdd(aCampos,{"VALPRE"   ,"N",15,2})
		aAdd(aCampos,{"VALREA"   ,"N",15,2})
		aAdd(aCampos,{"DIVISAO"  ,"C",03,2})
		aAdd(aCampos,{"QTDEOS"   ,"N",12,0})
		aAdd(aCampos,{"TABELA"   ,"C",03,0})
		aAdd(aCampos,{"DATATAB"  ,"D",08,0})
		aAdd(aCampos,{"HORATAB"  ,"C",05,0})
		aAdd(aCampos,{"PARCELA"  ,"N",03,0})
		aAdd(aCampos,{"MESANO"   ,"C",07,0})

		cTRBMAIN	:= GetNextAlias()

		//Cria tabela temporaria
		oTmpTA100 := FWTemporaryTable():New(cTRBMAIN, aCampos)
		oTmpTA100:AddIndex("Ind01", {"CODEST","NIVSUP"})
		oTmpTA100:AddIndex("Ind02", {"CODEST","CODPRO"})
		oTmpTA100:AddIndex("Ind03", {"NIVSUP","CODEST"})
		oTmpTA100:AddIndex("Ind04", {"CODEST","DESCRI"})
		oTmpTA100:AddIndex("Ind05", {"CNIVEL","DESCRI"})
		oTmpTA100:AddIndex("Ind06", {"CHAVPAI"})
		oTmpTA100:Create()

		aOnde  := {"1="+STR0003,"2="+STR0004,"3="+STR0005,"4="+STR0006,"5="+STR0007,"6="+STR0008,"7="+STR0009} //"Filial"###"Área"###"Tipo"###"Serviço"###"Família"###"Bem"###"O.S."
		aEmQue := {"1="+STR0010,"2="+STR0011,"3="+STR0012,"4="+STR0013} //"Preventiva"###"Corretiva"###"Outros"###"Todos"
		cEmQue := '4'

		// Liberada ### Pendente ### Aberta ### Finalizada ### Todas
		aStatus := { '1=' + STR0133, '2=' + STR0134, '3=' + STR0135, '4=' + STR0136, '5=' + STR0137 }
		cStatus := '4'

		aOndeF2 := {"1="+STR0003,"2="+STR0007,"3="+STR0008} //"Filial"###"Família"###"Bem"
		aOndeF3 := {"1="+"Filial","2="+STR0007,"3="+STR0008} //"Família"###"Bem"
		aOndeF4 := {"1="+STR0003,"2="+STR0007,"3="+STR0008} //"Filial"###"Família"###"Bem"

		//cria SX1 e alimenta listbox
		MNTC935SX1()

		//joga tabelas em memoria
		aTabRegToM := {"STD","STE","ST4","ST6","ST9","STJ","CTT","ST5"}
		If lGFrota
			MNTA765VAR()
			aAdd(aTabRegToM,"TQN")
			aAdd(aTabRegToM,"TRX")
			aAdd(aTabRegToM,"TS1")
			aAdd(aTabRegToM,"TRH")
			aAdd(aTabRegToM,"TS0")
		Endif

		If NGUSATARPAD()
			aAdd(aTabRegToM,"TT9")
		EndIf

		For nI := 1 To Len(aTabRegToM)
			dbSelectArea(aTabRegToM[nI])
			dbSetOrder(1)
			dbSeek(xFilial(aTabRegToM[nI]),.T.)
			RegToMemory(aTabRegToM[nI],.F.)
		Next

		// Montagem dos Insumos Realizados da Ordem de Servico
		dbSelectArea("STL")
		aCols   := {}
		aHeader := {}
		aHoBrw1 := {}
		aHoBrw2 := {}
		For nI := 1 To 2
			If nI == 1
				aCamposSTL := NGCAMPNSX3("STL",{"TL_ORDEM","TL_PLANO","TL_TAREFA","TL_NOMTAR","TL_TIPOREG","TL_NOMTREG"})
			Else
				aCamposSTL := NGCAMPNSX3("STT",{"TT_ORDEM","TT_PLANO","TT_TAREFA","TT_NOMTAR","TT_TIPOREG","TT_NOMTREG"})
			Endif

			//Monta aHeader - Contador 1
			For nI := 1 To Len(aCamposSTL)
				If cNivel >= Posicione("SX3",2,aCamposSTL[nI],"X3_NIVEL")  // sem X3USO
					If nI == 1
						aAdd(aHoBrw1,{AllTrim(Posicione("SX3",2,aCamposSTL[nI],"X3Titulo()")), aCamposSTL[nI], Posicione("SX3",2,aCamposSTL[nI],"X3_PICTURE"),;
												Posicione("SX3",2,aCamposSTL[nI],"X3_TAMANHO"), Posicione("SX3",2,aCamposSTL[nI],"X3_DECIMAL"), Posicione("SX3",2,aCamposSTL[nI],"X3_VALID"), Posicione("SX3",2,aCamposSTL[nI],"X3_USADO"),;
												Posicione("SX3",2,aCamposSTL[nI],"X3_TIPO")	, Posicione("SX3",2,aCamposSTL[nI],"X3_ARQUIVO"), Posicione("SX3",2,aCamposSTL[nI],"X3_CONTEXT") })
					Else
						aAdd(aHoBrw2,{AllTrim(Posicione("SX3",2,aCamposSTL[nI],"X3Titulo()")), aCamposSTL[nI], Posicione("SX3",2,aCamposSTL[nI],"X3_PICTURE"),;
												Posicione("SX3",2,aCamposSTL[nI],"X3_TAMANHO"), Posicione("SX3",2,aCamposSTL[nI],"X3_DECIMAL"), Posicione("SX3",2,aCamposSTL[nI],"X3_VALID"), Posicione("SX3",2,aCamposSTL[nI],"X3_USADO"),;
												Posicione("SX3",2,aCamposSTL[nI],"X3_TIPO"), Posicione("SX3",2,aCamposSTL[nI],"X3_ARQUIVO"), Posicione("SX3",2,aCamposSTL[nI],"X3_CONTEXT") })
					Endif
					If Posicione("SX3",2,aCamposSTL[nI],"X3_CONTEXT") != 'V'
						If nI == 1
							aAdd(aCamposOK1,aCamposSTL[nI])
						Else
							aAdd(aCamposOK2,aCamposSTL[nI])
						EndIf
					EndIf
				EndIf
			Next
		Next

		Define MsDialog oDlg Title cCadastro From 10,0 To aSize[6],aSize[5] Of oMAINWND Pixel

		oDlg:lMaximized := .T.
		oDlg:lEscClose  := .F.

		/*   oSplitVertical oPnlBtn21
		ÚÄÄÄÄÄÄÄÄÄÄÄÄ³Ä³ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		³±           ³±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±³Ä> oPnlLgnd21
		³±           ³±                                                    ³
		³±    o      ³±                                              o     ³
		³±    P      ³±                                              P     ³
		³±    a      :±     oPnlDownL1                               a     ³
		³±    n      ÃÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ..Ä..ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄnÄÄÄÄÄ³Ä oSplitHor2
		³±    e      :±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±e±±±±±³Ä> oPnlLgnd22
		³±    l      ³±                                              l     ³
		³±    1      ³±                                              2     ³
		³±           ³±                                                    ³
		³±           ³±     oPnlUpR1/oPnlUpR2 - oPnlUpR3             ³
		À³ÄÄÄÄÄÄÄÄÄÄÄÁ³ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		³oPnlBtn     ³oPnlBtn22/oPnlBtn23 */

		oPanelDlg := TPanel():New(01,01,,oDlg,,,,,,nLargura,nAltura,.T.,.T.)
		oPanelDlg:Align := CONTROL_ALIGN_ALLCLIENT

		oPanelCam := TPanel():New(01,01,,oPanelDlg,,,,,,nLargura,15,.T.,.T.)
		oPanelCam:Align := CONTROL_ALIGN_TOP
		oPanelCam:CoorsUpdate()
		oGetCam := TGet():New(02,02,{||cCaminho},oPanelCam,oPanelCam:nWidth/2-3,09,/*cPicture*/,,CLR_BLACK,RGB(211,211,211),;
		/*oFont*/,,,.T.,,,/*bWhen*/,,,/*bChange*/,.T./*lReadOnly*/,.F.,,cCaminho,,,,.F.,.T.)

		oSplitVertical := tSplitter():New( 0,0,oPanelDlg,1,1,0 )
		oSplitVertical:Align := CONTROL_ALIGN_ALLCLIENT

		oPnlLegEsq := TPanel():New(01,01,,oPanelDlg,,,,,,nLargura*0.01,nAltura,.T.,.T.)
		oPnlLegEsq:Align := CONTROL_ALIGN_LEFT
		oPanelEsq := TPanel():New(01,01,,oSplitVertical,,,,,,nLargura*0.43,nAltura,.T.,.T.)
		oPanelEsq:Align := CONTROL_ALIGN_LEFT
		oScrollUp := TScrollBox():new(oPanelEsq,0,0,50,50,.T.,.T.,.T.)
		oScrollUp:Align := CONTROL_ALIGN_ALLCLIENT

		oPanelDir := TPanel():New(01,01,,oSplitVertical,,,,,,nLargura*0.56,nAltura,.T.,.T.)
		oPanelDir:Align := CONTROL_ALIGN_RIGHT

		oPnlDownL1 := TPanel():New(0,0,,oPanelEsq,,,,,,10,nAltura,.T.,.T.)
		oPnlDownL1:Align := CONTROL_ALIGN_ALLCLIENT

		//Inferior lado esquerdo - Tree
		oTree := DbTree():New(001, 001, 002, 002 , oPnlDownL1,,,.T.,.F.)
		oTree:Align    := CONTROL_ALIGN_ALLCLIENT
		oTree:nClrPane := RGB(221,221,221)
		oTree:blDblClick := { || MNT935DCLI()}
		oTree:bChange:= {|| MNT935VChg()}

		oSplitHor2 := tSplitter():New( 0,0,oPanelDir,50,50,1 )
		oSplitHor2:Align := CONTROL_ALIGN_ALLCLIENT

		//Getdados e Enchoice superiores do lado direito
		oPnlPaiDir := TPanel():New(01,01,,oSplitHor2,,,,,,10,nAltura*0.30,.F.,.T.)
		oPnlPaiDir:Align := CONTROL_ALIGN_TOP
		oPnlUpR1 := TPanel():New(01,01,,oPnlPaiDir,,,,,,10,nAltura,.F.,.T.)
		oPnlUpR1:Align := CONTROL_ALIGN_ALLCLIENT
		oPnlUpR2 := TPanel():New(01,01,,oPnlPaiDir,,,,,,10,nAltura,.F.,.T.)
		oPnlUpR2:Align := CONTROL_ALIGN_ALLCLIENT
		oPnlUpR2:lVisible := .f.
		oPnlUpR3  := TPanel():New(01,01,,oPnlPaiDir,,,,,,10,nAltura,.F.,.T.)
		oPnlUpR3:Align := CONTROL_ALIGN_ALLCLIENT
		oPnlUpR3:lVisible := .f.
		//Menu lateral esquerdo
		oPnlButton := TPanel():New(0,0,,oPnlLegEsq,,,,,RGB(67,70,87),13,0,.F.,.F.)
		oPnlButton:Align := CONTROL_ALIGN_ALLCLIENT
		oBtnVisual  := TBtnBmp():NewBar("ng_ico_visual","ng_ico_visual",,,,{|| MNT935VRun()},,oPnlButton)
		oBtnVisual:cToolTip := STR0014 //"Visualizar cadastro"
		oBtnVisual:Align  := CONTROL_ALIGN_TOP
		oBtnVisual:lVisible := .f.
		oBtnGrafic  := TBtnBmp():NewBar("ng_ico_grafpizza","ng_ico_grafpizza",,,,oTree:blDblClick,,oPnlButton)
		oBtnGrafic:cToolTip := STR0015 //"Visualizar detalhes"
		oBtnGrafic:Align  := CONTROL_ALIGN_TOP
		oBtnGrafic:lVisible := .f.

		oBtnRelato  := TBtnBmp():NewBar( 'ng_ico_imp', 'ng_ico_imp', , , , { ||RelatoC935() }, , oPnlButton )
		oBtnRelato:cToolTip := STR0016 // Relatório
		oBtnRelato:Align    := CONTROL_ALIGN_TOP
		oBtnRelato:lVisible := .F.

		oBtnFtr  := TBtnBmp():NewBar("ng_ico_filtro1","ng_ico_filtro1",,,,{|| TelaParame()},,oPnlButton)
		oBtnFtr:cToolTip := STR0017 //"Filtro"
		oBtnFtr:Align  := CONTROL_ALIGN_TOP
		oBtnLeg  := TBtnBmp():NewBar("ng_ico_lgndos","ng_ico_lgndos",,,,{|| ShowLegend()},,oPnlButton)
		oBtnLeg:cToolTip := STR0018 //"Legenda"
		oBtnLeg:Align  := CONTROL_ALIGN_TOP
		oBtnTRX  := TBtnBmp():NewBar("pmsinfo","pmsinfo",,,,{|| },,oPnlButton)
		oBtnTRX:cToolTip := STR0127  //"Multas não contabilizadas"
		oBtnTRX:Align  := CONTROL_ALIGN_TOP
		oBtnTRX:lVisible := .f.

		//Panels inferiores do lado direito
		oPnlDownR1 := TPanel():New(01,01,,oSplitHor2,,,,,,10,nAltura*0.70,.F.,.T.)
		oPnlDownR1:Align := CONTROL_ALIGN_BOTTOM
		oPnlUpLeg := TPanel():New(01,01,,oPnlDownR1,,,,,RGB(67,70,87),13,13,.F.,.T.)
		oPnlUpLeg:Align := CONTROL_ALIGN_TOP

		If !TelaParame()
			//-----------------------------------------------------------
			//| Devolve variaveis armazenadas (NGRIGHTCLICK)            |
			//-----------------------------------------------------------
			NGRETURNPRM(aNGBEGINPRM)
			oTmpTA100:Delete()
			Return Nil
		Endif

		CriaBrowse(@oPnlUpR1,@oBrowseRO1)

		ACTIVATE MSDIALOG oDlg ON INIT EnchoiceBar(@oDlg,{||nOpc :=2,oDlg:End()},{||nOpc := 1,oDlg:End()},,)

		oTmpTA100:Delete()
		
		NGReturnPrm( aNGBeginPrm )

	EndIf

Return

//---------------------------------------------------------------------------
/*/{Protheus.doc} CriaBrowse
Cria TCBrowse dependendo dos parametros informados no cabec.

@author Vitor Emanuel Batista
@since 02/09/2009
@version undefined
@param oPanel, object, Panel onde será criado o Browse.
@param _oBrowse, object, Browse em referência.
@type function
/*/
//---------------------------------------------------------------------------
Static Function CriaBrowse(oPanel,_oBrowse)
	Local nX := 1

	CursorWait()

	aHeader := {}
	aHeader := RetInfoBrw()

	// Cria Browse
	If ValType(_oBrowse) != "O"
		_oBrowse := TCBrowse():New( 0 , 0, 260 , 156 ,,,,oPanel,,,,,{||},,,,,,,.F.,,.F.,,.F.,,, )
		_oBrowse:Align := CONTROL_ALIGN_ALLCLIENT
	Else
		oBrowseRO1:aARRAY    := {}
		oBrowseRO1:aCOLUMNS  := {}
		oBrowseRO1:aCOLSIZES := {}
	Endif

	For nX := 1 to Len(aHeader)
		_oBrowse:AddColumn(TCColumn():New(aHeader[nX][1],&("{|| If(Len(_oBrowse:aArray) >= _oBrowse:nAt,_oBrowse:aArray[_oBrowse:nAt,"+cValToChar(nX)+"],'') }"),;
		aHeader[nX][4],,,aHeader[nX][3],aHeader[nX][2],.F.,.F.,,,,.F.))
	Next nX

	//Ponto de Entrada que permite filtrar os dados que serão apresentados na consulta
	If ExistBlock("MNTC9351")
		aColsRod := ExecBlock("MNTC9351",.F.,.F.)
	EndIf
	_oBrowse:SetArray(aColsRod) // Seta vetor para a browse
	_oBrowse:Refresh()
	//------------------------------------------------
	//| Restaura o Estado do Cursor                  |
	//------------------------------------------------
	CursorArrow()
Return Nil

//---------------------------------------------------------------------------
/*/{Protheus.doc} RetInfoBrw
Retorna array contendo aHeader para o TCBrowse

@author Marcos Wagner Junior
@since 02/09/20009
@version undefined

@type function
/*/
//---------------------------------------------------------------------------
Static Function RetInfoBrw()
	Local aInfoBrw := {}
	Local cNIVSUP  := SubStr( oTree:GetCargo(), 1, 4 )

	dbSelectArea(cTRBMAIN)
	dbSetOrder( fDefOrdem( cNIVSUP ) )
	If dbSeek(cNIVSUP)
		If (cTRBMAIN)->DIVISAO == 'DOC'
			If lPrxUltNiv
				aAdd(aInfoBrw,{STR0022,40,"LEFT","","COD","D",10}) //"Data"
				aAdd(aInfoBrw,{STR0023,40,"LEFT","","DES","C",05}) //"Hora"
				aAdd(aInfoBrw,{STR0024,50,"RIGHT","@E 999,999,999,999.99","VL1","N",18}) //"Valor Previsto"
				aAdd(aInfoBrw,{STR0131,50,"RIGHT","@E 999,999,999,999.99","VL2","N",18}) //"VL2" //"Valor Pago"
				aAdd(aInfoBrw,{"%",20,"LEFT","@E 999.99",,"N",07})
			Else
				aAdd(aInfoBrw,{STR0019,45,"LEFT","","COD","C",06}) //"Código"
				aAdd(aInfoBrw,{STR0020,100,"LEFT","","DES","C",40}) //"Descrição"
				aAdd(aInfoBrw,{STR0024,50,"RIGHT","@E 999,999,999,999.99","VL1","N",18}) //"Valor Previsto"
				aAdd(aInfoBrw,{STR0131,50,"RIGHT","@E 999,999,999,999.99","VL2","N",18}) //"VL2" //"Valor Pago"
				aAdd(aInfoBrw,{"%",20,"LEFT","@E 999.99",,"N",07})
			Endif

		ElseIf (cTRBMAIN)->TABELA $ ('TRH/TRX/TQN/MEA')
			aAdd(aInfoBrw,{STR0022,40,"LEFT","","COD","D",10}) //"Data"
			If (cTRBMAIN)->TABELA != 'MEA' //Para abastecimento nao trara hora
				aAdd(aInfoBrw,{STR0023,40,"LEFT","","DES","C",05}) //"Hora"
			Endif
			If (cTRBMAIN)->TABELA == 'TRX' //Para abastecimento nao trara hora
				aAdd(aInfoBrw,{STR0024,50,"RIGHT","@E 999,999,999,999.99","VL1","N",18}) //"Valor Previsto"
				aAdd(aInfoBrw,{STR0131,50,"RIGHT","@E 999,999,999,999.99","VL2","N",18}) //"VL2" //"Valor Pago"
			Else
				aAdd(aInfoBrw,{STR0021,50,"RIGHT","@E 999,999,999,999.99","VL2","N",18}) //"VL2" //"Valor"
			Endif
			aAdd(aInfoBrw,{"%",20,"LEFT","@E 999.99",,"N",07})

		Else
			aAdd(aInfoBrw,{STR0019,45,"LEFT","","COD","C",16}) //"Código"
			If !lPrxUltNiv .AND. (cTRBMAIN)->TABELA != 'STJ'
				aAdd(aInfoBrw,{STR0020,100,"LEFT","","DES","C",40}) //"Descrição"
			Endif
			If ((cTRBMAIN)->DIVISAO == 'OFI' .OR. (cTRBMAIN)->DIVISAO == 'PNE') .OR. Empty((cTRBMAIN)->DIVISAO) .OR. !lGFrota
				aAdd(aInfoBrw,{STR0024,50,"RIGHT","@E 999,999,999,999.99","VL1","N",18}) //"Valor Previsto"
				aAdd(aInfoBrw,{"%",20,"LEFT","@E 999.99","","N",07})
				aAdd(aInfoBrw,{STR0025,50,"RIGHT","@E 999,999,999,999.99","VL2","N",18}) //"Valor Realizado"
				aAdd(aInfoBrw,{"%",20,"LEFT","@E 999.99","","N",07})
				If !lPrxUltNiv .AND. !((cTRBMAIN)->TABELA $ 'STJ/ST5')
					aAdd(aInfoBrw,{STR0026,45,"RIGHT","@E 9,999,999","","N",07}) //"Qtde OS"
				Endif
			Else
				If (cTRBMAIN)->DIVISAO == "MUL
					aAdd(aInfoBrw,{STR0024,50,"RIGHT","@E 999,999,999,999.99","VL1","N",18}) //"Valor Previsto"
					aAdd(aInfoBrw,{STR0131,50,"RIGHT","@E 999,999,999,999.99","VL2","N",18}) //"VL2" //"Valor Pago"
					aAdd(aInfoBrw,{"%",20,"LEFT","@E 999.99",,"N",07})

				ElseIf !( Trim( cNIVSUP ) $ ( 'SIN/ABA/DOC' ) )

					aAdd(aInfoBrw,{STR0021,50,"RIGHT","@E 999,999,999,999.99","VL2","N",18}) //"VL2" //"Valor"
					aAdd(aInfoBrw,{"%",20,"LEFT","@E 999.99",,"N",07})

				EndIf
			Endif
		Endif
	Else
		aAdd(aInfoBrw,{STR0019,45,"LEFT","","COD","C",16}) //"Código"
		aAdd(aInfoBrw,{STR0024,50,"RIGHT","@E 999,999,999,999.99","VL1","N",18}) //"Valor Previsto"
		aAdd(aInfoBrw,{"%",20,"LEFT","@E 999.99","","N",07})
		aAdd(aInfoBrw,{STR0025,50,"RIGHT","@E 999,999,999,999.99","VL2","N",18}) //"Valor Realizado"
		aAdd(aInfoBrw,{"%",20,"LEFT","@E 999.99","","N",07})
	Endif

	cDescNivFil := MNC935NIV((cTRBMAIN)->TABELA)

Return aInfoBrw

//---------------------------------------------------------------------------
/*/{Protheus.doc} Grafico935
Graficos

@author Marcos Wagner Junior
@since 15/03/2010
@version undefined

@type function
/*/
//---------------------------------------------------------------------------
Static Function Grafico935()

	Private cTRBP935

	If Empty((cTRBMAIN)->DIVISAO) .OR. (cTRBMAIN)->DIVISAO == 'OFI' .OR. ;
	(cTRBMAIN)->DIVISAO == 'PNE' .Or. (cTRBMAIN)->DIVISAO == 'MUL' .Or. (cTRBMAIN)->DIVISAO == 'DOC'
		aGrafico935 := {STR0027,STR0028} //"Previsto"###"Realizado"
	Else
		aGrafico935 := {cDescNivPai,cDescNivFil}
	Endif

	CRIATRB935()

Return .t.

//---------------------------------------------------------------------------
/*/{Protheus.doc} CRIATRB935
Cria TRB

@author Marcos Wagner Junior
@since 15/03/2010
@version undefined

@type function
/*/
//---------------------------------------------------------------------------
Static Function CRIATRB935()

	Local nI       := 0
	Local cNIVSUP  := Trim( SubStr( oTree:GetCargo(), 5, 4 ) )
	Local nCOD, nDES, nVL1, nVL2
	Local oTmpT935

	Private cTRBP935 := GetNextAlias()

	nCOD := aSCAN(aHeader,{|x| x[5] = 'COD' })
	nDES := aSCAN(aHeader,{|x| x[5] = 'DES' })
	nVL1 := aSCAN(aHeader,{|x| x[5] = 'VL1' })
	nVL2 := aSCAN(aHeader,{|x| x[5] = 'VL2' })

	If cNIVSUP == 'SIN' .OR. cNIVSUP == 'MUL' .OR. cNIVSUP == 'DOC'
		oPnlDownR1:Hide()
		Return .t.
	Else
		oPnlDownR1:Show()
	Endif

	aDBF935 := {{"CODIGO" ,"C",20, 0 },;
				{"DESCRI" ,"C",20, 0 },;
				{"VALOR1" ,"N",16, 2 },;
				{ 'VALOR2', 'N', 16, 2 } }

	oTmpT935 := FWTemporaryTable():New(cTRBP935, aDBF935)
	oTmpT935:AddIndex("Ind01", {"CODIGO"})
	oTmpT935:Create()

	For nI := 1 to Len(aColsRod)
		RecLock(cTRBP935,.t.)
		(cTRBP935)->CODIGO  := aColsRod[nI][nCOD]
		If nDES == 0
			(cTRBP935)->DESCRI  := aColsRod[nI][nCOD]
		Else
			(cTRBP935)->DESCRI  := aColsRod[nI][nDES]
		Endif
		(cTRBP935)->VALOR1  := IIf(nVL1>0,aColsRod[nI][nVL1],0)
		(cTRBP935)->VALOR2  := IIf(nVL2>0,aColsRod[nI][nVL2],0)
		(cTRBP935)->(MsUnLock())
	Next

	dbSelectArea(cTRBP935)
	dbGoTop()

	NGGRAFICO(	" ",;
	" ",;
	" ",;
	" ",;
	" ",;
	aGrafico935,;
	"A",;
	(cTRBP935),;
	,;
	,;
	.t.,;
	oPnlDownR1,;
	oPnlUpLeg)

	//Deleta o arquivo temporario fisicamente
	oTmpT935:Delete()

Return

//---------------------------------------------------------------------------
/*/{Protheus.doc} MNT935VChg
Verifica se o item selecionado ja foi carregado

@author Rafael Diogo Richter
@since 22/04/2009
@version undefined
@param lProcess, logical, Indica se a funcao exibira Processamentos
@param lLegenda, logical, Indica se a funcao carregara as legendas
@type function
/*/
//---------------------------------------------------------------------------
Function MNT935VChg(lProcess,lLegenda)

	Local _cCargo := Trim( SubStr( oTree:GetCargo(), 5, 4 ) )
	Local cCod    := Trim( SubStr( oTree:GetCargo(), 1, 4 ) )

	If _cCargo $ ( 'SM0/LOC/DIV/TIN/MEA' ) // Inibe o botao Visualizar para Filial, Divisao

		oBtnVisual:lVisible := .f.
		oBtnGrafic:lVisible := .f.

	Else

		oBtnVisual:lVisible := .t.
		oBtnGrafic:lVisible := .t.

		If _cCargo $ ( 'TQN/TRX/TS1/TRH' )
			oBtnGrafic:lVisible := .f.
		EndIf

	EndIf

	/*Quando nao encontrar o registro
	para SEM ESPECIFICACAO DE TAREFA
	desabilita botao visualizar*/
	If !fLoadArea( @_cCargo, cCod, .T. )
		oBtnVisual:Disable()
		oBtnGrafic:Disable()
	Else
		oBtnVisual:Enable()
		oBtnGrafic:Enable()
	EndIf

Return .T.

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³ MNT935DCLI ³ Autor ³ Rafael Diogo Richter ³ Data ³17/10/2008³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³Carrega os registros do item selecionado.                    ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ MNTA902                                                     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³         Atualizacoes Sofridas Desde a Construcao Inicial.              ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Programador ³ Data   ³ F.O  ³  Motivo da Alteracao                      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³            ³        ³      ³                                           ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Static Function MNT935DCLI()

	Local _cCargo := Trim( SubStr( oTree:GetCargo(), 4, 5 ) )
	Local cCod    := Trim( SubStr( oTree:GetCargo(), 1, 4 ) )

	/*Quando nao encontrar o registro
	para SEM ESPECIFICACAO DE TAREFA
	desabilita botao visualizar*/
	If !fLoadArea(@_cCargo,cCod,.T.)
		oBtnVisual:Disable()
		oBtnGrafic:Disable()
	Else
		oBtnVisual:Enable()
		oBtnGrafic:Enable()
	EndIf

	oBtnRelato:lVisible := .T.

	fHideRefre(@oPnlUpR1)
	If _cCargo $ ( 'TQN/TRX/TS1/TRH' )
		MNT935VRun()
	Else
		If ValType('oEnc') == 'O'
			oEnc:Hide()
			oEnc:EnchRefreshAll()
		Endif
		MsgRun(STR0029,STR0030,{||MNTDCVIS()}) //"Carregando tela do item selecionado, aguarde..."###"Carregando"
	EndIf

Return .T.

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³  MNTDCVIS  ³ Autor ³ Rafael Diogo Richter ³ Data ³17/10/2008³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³Mostra os registros do item selecionado.                     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ MNTA902                                                     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³         Atualizacoes Sofridas Desde a Construcao Inicial.              ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Programador ³ Data   ³ F.O  ³  Motivo da Alteracao                      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³            ³        ³      ³                                           ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Static Function MNTDCVIS()

	Local cNIVSUP      := SubStr( oTree:GetCargo(), 1, 4 )
	Local nTotPre      := 0
	Local nTotRea      := 0
	Local lTrocaHeader := .F.

	Store .F. to lTemOfi, lPrxUltNiv

	nTotalPai := 0
	aColsRod := {}

	aArea := (cTRBMAIN)->(GetArea())
	dbSelectArea(cTRBMAIN)
	dbSetOrder(2)
	dbSeek(cNIVSUP)

	If cOldTabela <> (cTRBMAIN)->TABELA+(cTRBMAIN)->DIVISAO .Or.; //sempre que trocar de nivel
	IsInCallStack("GerarConsulta") //sempre que for gerada a partir do browse
		lTrocaHeader := .t.
		cOldTabela := (cTRBMAIN)->TABELA+(cTRBMAIN)->DIVISAO
	Endif

	cDescNivPai := MNC935NIV((cTRBMAIN)->TABELA)

	If Empty((cTRBMAIN)->DIVISAO)
		dbSetOrder(3)
		dbSeek(cNIVSUP)
		While !Eof() .AND. (cTRBMAIN)->NIVSUP == cNIVSUP
			nTotalPai += (cTRBMAIN)->VALREA //Pega o valor do nivel pai
			nTotPre += (cTRBMAIN)->VALPRE
			nTotRea += (cTRBMAIN)->VALREA
			dbSkip()
		End
		cDescNivPai := STR0031 //"Total custos"
		RestArea(aArea)
	ElseIf (cTRBMAIN)->DIVISAO != 'OFI' .AND. lGFrota
		nTotalPai   := (cTRBMAIN)->VALREA //Pega o valor do nivel pai
	Else
		nTotPre := (cTRBMAIN)->VALPRE
		nTotRea := (cTRBMAIN)->VALREA
	Endif

	//-----------------------------------------------
	aArea := (cTRBMAIN)->(GetArea())

	//carrega caminho atual percorrido na arvore
	fUpdateWay((cTRBMAIN)->(RecNo()), cNivSup )

	dbSelectArea( cTRBMAIN )
	dbSetOrder( fDefOrdem( cNIVSUP ) )
	If dbSeek( cNIVSUP )
		// Se o registro for DOC/MUL/SIN carrega os dados somente do registro posicionado, ou seja, cai no "Else".
		If !lUltReg 
			While !Eof() .AND. ( cTRBMAIN )->NIVSUP == cNIVSUP
				fCarDados( nTotPre, nTotRea )
				dbSkip()
			End
		Else
			fCarDados( nTotPre, nTotRea )
		EndIf
	Endif

	If lTrocaHeader
		If Type('oBrowseRO1') == 'O'
			oBrowseRO1:Free()
		Endif
		CriaBrowse(@oPnlUpR1,@oBrowseRO1)
	Endif

	If ExistBlock("MNTC9351")
		aColsRod := ExecBlock("MNTC9351",.F.,.F.)
	EndIf
	oBrowseRO1:SetArray(aColsRod)
	oBrowseRO1:GoTop()
	oBrowseRO1:Refresh()

	Grafico935()

	RestArea(aArea)

Return .T.

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Metodo    ³  MNT935Ofi  ³Autor³ Marcos Wagner Junior ³ Data ³26/04/2011³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Query que busca os dados de Oficina.                       ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ MNTC935                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Static Function MNT935Ofi(_n2,lPneu,lCarrDados)

	Local nQtdChk		:= 0
	Local nAdd			:= 0
	Local nQ			:= 0
	Local nI			:= 0
	Local cFiltroSTL	:= ""
	Local cTipoReg		:= ""
	Local cQueryLoc		:= ""
	Local lLocaliz		:= .F.
	Local oTmpTRBIns

	Private lAdicionou	:= .F.
	Private aSTLouSTT	:= {}
	Private aDBF		:= {}
	Private aInd		:= {}
	Private cAliasQry	:= GetNextAlias()

	aAdd(aDBF,{ "VALPRE", "N", 10, 2 })
	aAdd(aDBF,{ "VALREA", "N", 10, 2 })

	If _n2 == 2
		aInd := {"TT_FILIAL","TS_ORDEM","TS_PLANO","TT_TAREFA","TT_TIPOREG","TT_CODIGO","TT_SEQRELA"}
		aAdd(aDBF,{ "TS_FILIAL"	, "C" ,Len(STS->TS_FILIAL)	, 0 })
		aAdd(aDBF,{ "TS_ORDEM"	, "C" ,Len(STS->TS_ORDEM)	, 0 })
		aAdd(aDBF,{ "TS_PLANO"	, "C" ,Len(STS->TS_PLANO)	, 0 })
		aAdd(aDBF,{ "TS_CODBEM"	, "C" ,Len(STS->TS_CODBEM)	, 0 })
		aAdd(aDBF,{ "TS_SERVICO", "C" ,Len(STS->TS_SERVICO)	, 0 })
		aAdd(aDBF,{ "TS_SEQRELA", "C" ,Len(STS->TS_SEQRELA)	, 0 })
		aAdd(aDBF,{ "TS_CCUSTO"	, "C" ,Len(STS->TS_CCUSTO)	, 0 })
		aAdd(aDBF,{ "TS_CODAREA", "C" ,Len(STS->TS_CODAREA)	, 0 })
		aAdd(aDBF,{ "TS_TIPO"	, "C" ,Len(STS->TS_TIPO)	, 0 })
		aAdd(aDBF,{ "TT_FILIAL"	, "C" ,Len(STT->TT_FILIAL)	, 0 })
		aAdd(aDBF,{ "TT_CODIGO"	, "C" ,Len(STT->TT_CODIGO)	, 0 })
		aAdd(aDBF,{ "TT_DTINICI", "D" ,8 					, 0 })
		aAdd(aDBF,{ "TT_HOINICI", "C" ,Len(STT->TT_HOINICI)	, 0 })
		aAdd(aDBF,{ "TT_TAREFA"	, "C" ,Len(STT->TT_TAREFA)	, 0 })
		aAdd(aDBF,{ "TT_SEQRELA", "C" ,Len(STT->TT_SEQRELA)	, 0 })
		aAdd(aDBF,{ "TT_TIPOREG", "C" ,Len(STT->TT_TIPOREG)	, 0 })
		aAdd(aDBF,{ "TT_CUSTO"	, "N" ,TAMSX3("TT_CUSTO")[1], TAMSX3("TT_CUSTO")[2] })
	Else
		aInd := {"TL_FILIAL","TJ_ORDEM","TJ_PLANO","TL_TAREFA","TL_TIPOREG","TL_CODIGO","TL_SEQRELA"}
		aAdd(aDBF,{ "TJ_FILIAL"	, "C" ,Len(STJ->TJ_FILIAL)	, 0 })
		aAdd(aDBF,{ "TJ_ORDEM"	, "C" ,Len(STJ->TJ_ORDEM)	, 0 })
		aAdd(aDBF,{ "TJ_PLANO"	, "C" ,Len(STJ->TJ_PLANO)	, 0 })
		aAdd(aDBF,{ "TJ_CODBEM"	, "C" ,Len(STJ->TJ_CODBEM)	, 0 })
		aAdd(aDBF,{ "TJ_SERVICO", "C" ,Len(STJ->TJ_SERVICO)	, 0 })
		aAdd(aDBF,{ "TJ_SEQRELA", "C" ,Len(STJ->TJ_SEQRELA)	, 0 })
		aAdd(aDBF,{ "TJ_CCUSTO"	, "C" ,Len(STJ->TJ_CCUSTO)	, 0 })
		aAdd(aDBF,{ "TJ_CODAREA", "C" ,Len(STJ->TJ_CODAREA)	, 0 })
		aAdd(aDBF,{ "TJ_TIPO"	, "C" ,Len(STJ->TJ_TIPO)	, 0 })
		aAdd(aDBF,{ "TL_FILIAL"	, "C" ,Len(STL->TL_FILIAL)	, 0 })
		aAdd(aDBF,{ "TL_CODIGO"	, "C" ,Len(STL->TL_CODIGO)	, 0 })
		aAdd(aDBF,{ "TL_DTINICI", "D" ,8 					, 0 })
		aAdd(aDBF,{ "TL_HOINICI", "C" ,Len(STL->TL_HOINICI)	, 0 })
		aAdd(aDBF,{ "TL_TAREFA"	, "C" ,Len(STL->TL_TAREFA)	, 0 })
		aAdd(aDBF,{ "TL_SEQRELA", "C" ,Len(STL->TL_SEQRELA)	, 0 })
		aAdd(aDBF,{ "TL_TIPOREG", "C" ,Len(STL->TL_TIPOREG)	, 0 })
		aAdd(aDBF,{ "TL_CUSTO"	, "N" ,TAMSX3("TL_CUSTO")[1], TAMSX3("TL_CUSTO")[2] })
	EndIf

	aAdd(aDBF,{ "TD_NOME"	, "C", Len(STD->TD_NOME)	, 0 })
	aAdd(aDBF,{ "T4_NOME"	, "C", Len(ST4->T4_NOME)	, 0 })
	aAdd(aDBF,{ "T6_NOME"	, "C", Len(ST6->T6_NOME)	, 0 })
	aAdd(aDBF,{ "CTT_DESC01", "C", Len(CTT->CTT_DESC01)	, 0 })
	aAdd(aDBF,{ "TE_NOME"	, "C", Len(STE->TE_NOME)	, 0 })
	aAdd(aDBF,{ "TE_CARACTE", "C", Len(STE->TE_CARACTE)	, 0 })
	aAdd(aDBF,{ "T9_CODFAMI", "C", Len(ST9->T9_CODFAMI)	, 0 })
	aAdd(aDBF,{ "T9_CODBEM"	, "C", Len(ST9->T9_CODBEM) 	, 0 })
	aAdd(aDBF,{ "T9_NOME"	, "C", Len(ST9->T9_NOME)	, 0 })
	aAdd(aDBF,{ "TAF_CODNIV", "C", Len(TAF->TAF_CODNIV)	, 0 })
	aAdd(aDBF,{ "TAF_NOMNIV", "C", Len(TAF->TAF_NOMNIV)	, 0 })

	oTmpTRBIns := FWTemporaryTable():New(cAliasQry, aDBF)
	oTmpTRBIns:AddIndex("Ind01", aInd)
	oTmpTRBIns:Create()

	ProcRegua(Len(aBoxDir))

	If lEspeciali
		cFiltroSTL += " (STL.TL_TIPOREG = 'E' AND STL.TL_CODIGO BETWEEN '"+cDeEspec+"' AND '"+cAteEspec+"' ) "
		cTipoReg += "'E',"
		nQtdChk++
	Endif
	If lFerramenta
		cFiltroSTL += IIf(nQtdChk > 0, "OR", "")
		cFiltroSTL += " (STL.TL_TIPOREG = 'F' AND STL.TL_CODIGO BETWEEN '"+cDeFerram+"' AND '"+cAteFerram+"' ) "
		cTipoReg += "'F',"
		nQtdChk++
	Endif
	If lMaodeObra
		cFiltroSTL += IIf(nQtdChk > 0, "OR", "")
		cFiltroSTL += " (STL.TL_TIPOREG = 'M' AND STL.TL_CODIGO BETWEEN '"+cDeMdo+"' AND '"+cAteMdo+"' ) "
		cTipoReg += "'M',"
		nQtdChk++
	Endif
	If lProduto
		cFiltroSTL += IIf(nQtdChk > 0, "OR", "")
		cFiltroSTL += " (STL.TL_TIPOREG = 'P' AND STL.TL_CODIGO BETWEEN '"+cDeProd+"' AND '"+cAteProd+"' ) "
		cTipoReg += "'P',"
		nQtdChk++
	Endif
	If	lTerceiro
		cFiltroSTL += IIf(nQtdChk > 0, "OR", "")
		cFiltroSTL += " (STL.TL_TIPOREG = 'T' AND STL.TL_CODIGO BETWEEN '"+cDeTerc+"' AND '"+cAteTerc+"' ) "
		cTipoReg += "'T',"
		nQtdChk++
	Endif
	If nQtdChk > 1
		cFiltroSTL := " AND (" + cFiltroSTL + ")"
	ElseIf nQtdChk == 1
		cFiltroSTL := " AND " + cFiltroSTL
	Endif

	//caso nao selecionar nenhum tipo de insumo, consulta fica vazia
	cFiltroSTL += " AND STL.TL_TIPOREG IN ("+If(Empty(cTipoReg),"''",SubStr(cTipoReg,1,Len(cTipoReg)-1))+")"

	For nQ := 1 To 2
		lLocaliz := (nQ == 2)

		//Se for pneu, não busca localização
		If nQ == 2 .And. lPneu
			Exit
		EndIf
		cQueryRet := fQryOfi(_n2, lPneu, lLocaliz, cFiltroSTL)
		If nQ == 1
			cQueryLeft := cQueryRet
		Else
			cQueryLoc := cQueryRet
		EndIf
	Next nQ

	SqlToTrb(cQueryLeft,aDBF,cAliasQry)

	If !lPneu
		fGrvLoc(cQueryLoc,cAliasQry,_n2)
	EndIf

	(cAliasQry)->(dbGoTop())
	If (cAliasQry)->(!Eof())
		lTemOS := .t.
	Endif

	If !lCarrDados
		nX++
		Return .t.
	Endif

	//Essa funcao ajusta a tabela temporaria para os insumos do tipo especialidade x mao-de-obra
	//identificando as MDO realizadas em cima de especialidades previstas e salvando esses valores
	//como se fossem especialidades realizadas
	fAjustESP(_n2)

	If aSCAN(aBoxDir,{|x| x[2] = '01' }) == 0
		MNC935ARR()
	Endif
	If aSCAN(aBoxDir,{|x| x[2] = '08' }) == 0
		lAdicionou := .t.
		nAdd++
		aAdd( aBoxDir , { STR0009, "08", 3,'cTJORDEM', 'STJ'  } )  //"O.S."
	Endif
	cChavePai := ''

	For nI := 1 to Len(aBoxDir)
		IncProc()
		If lPneu
			MontaTree(nI,nI == 1,'PNE',"PNEU",aBoxDir[nI][5])
		Else
			MontaTree(nI,nI == 1,'OFI',"OFICINA",aBoxDir[nI][5])
		Endif
	Next

	If lAdicionou
		If nDiv <> 0
			aDel( aBoxDir,nDiv)
			aSize( aBoxDir, Len( aBoxDir )-1)
		Endif

		For nI := 1 to nAdd
			aDel( aBoxDir,Len(aBoxDir))
		Next
		aSize( aBoxDir, Len( aBoxDir )-nAdd)
	Endif

	nX++

	oTmpTRBIns:Delete()

Return .T.

//---------------------------------------------------------------------------
/*/{Protheus.doc} fAjustESP
Essa funcao ajusta a tabela temporaria para os insumos do
tipo especialidade x mao-de-obra identificando as MDO
realizadas em cima de especialidades previstas e salvando
esses valores como se fossem especialidades realizadas
[Funcao baseada na antiga funcao fVerFunEsp daqui mesmo]

@author Felipe Nathan Welter
@since 23/02/2012
@version undefined
@param _n2, numeric
@type function
/*/
//---------------------------------------------------------------------------
Static Function fAjustESP(_n2)

	Local nI
	Local cChaveSTL2
	Local cChaveSTL1
	Local nValorReal
	Local cTIPOINSUM
	Local cCHAVETAB
	Local cT5TAREFA
	Local cCODINSUMO
	Local aArea1
	Local aArea2
	Local aAreaOld
	Local aMDO
	Local _aSTLouSTT := {}

	If _n2 == 1
		cFilSTL := xFilial('STL')
	Else
		cFilSTT := xFilial('STT')
	EndIf

	aAreaOld := GetArea()
	dbSelectArea(cAliasQry)
	dbGoTop()
	While (cAliasQry)->(!Eof())

		aMDO     := {}
		nValorReal := 0
		cChaveSTL1 := &(aSTLouSTT[24]+'+'+aSTLouSTT[25]+'+'+aSTLouSTT[28]+'+'+aSTLouSTT[29]+'+'+aSTLouSTT[10])

		If !(&(aSTLouSTT[28]) $ ('E'))
			(cAliasQry)->(dbSkip())
			Loop
		Endif

		If _n2 == 1
			_aSTLouSTT := {'STL','cFilSTL','STL->TL_ORDEM','STL->TL_PLANO','STL->TL_TIPOREG','STL->TL_CODIGO','STL->TL_CUSTO','STL->TL_SEQRELA','STL->TL_TAREFA'}
			cChaveSTL2 := 'xFilial("STL")+STL->TL_ORDEM+STL->TL_PLANO+STL->TL_TAREFA+STL->TL_TIPOREG+STL->TL_CODIGO+STL->TL_SEQRELA'
		Else
			_aSTLouSTT := {'STT','cFilSTT','STT->TT_ORDEM','STT->TT_PLANO','STT->TT_TIPOREG','STT->TT_CODIGO','STT->TT_CUSTO','STT->TT_SEQRELA','STT->TT_TAREFA'}
			cChaveSTL2 := 'xFilial("STT")+STT->TT_ORDEM+STT->TT_PLANO+STT->TT_TAREFA+STT->TT_TIPOREG+STT->TT_CODIGO+STT->TT_SEQRELA'
		Endif

		cTIPOINSUM := IIF(Empty(&(aSTLouSTT[28])),'',&(aSTLouSTT[28]))
		cCHAVETAB  := IIF(Empty(&(aSTLouSTT[24])),'',&(aSTLouSTT[24]))
		cT5TAREFA  := IIF(Empty(&(aSTLouSTT[25])),Space(Len(ST5->T5_DESCRIC)),&(aSTLouSTT[25]))
		cCODINSUMO := IIF(Empty(&(aSTLouSTT[29])),'',&(aSTLouSTT[29]))

		If cTIPOINSUM == 'E'
			//Apenas verifica a Especialidade se nao houver insumo previsto do Funcionario
			dbSelectArea(_aSTLouSTT[1])
			dbSetOrder(4)
			If dbSeek(cCHAVETAB+"M")
				While !Eof() .AND. &(_aSTLouSTT[2])+&(_aSTLouSTT[3])+&(_aSTLouSTT[4]) == cCHAVETAB .AND. &(_aSTLouSTT[5]) == 'M'
					If &(_aSTLouSTT[9]) == cT5TAREFA
						nPosMDO := aSCAN(aMDO,{|x| x[2] = &(_aSTLouSTT[9]+'+'+_aSTLouSTT[6]) })
						dbSelectArea("ST2")
						dbSetOrder(1)
						If dbSeek(xFilial('ST2')+SubStr(&(_aSTLouSTT[6]),1,6))
							If ST2->T2_ESPECIA == SubStr(cCODINSUMO,1,3)

								If &(_aSTLouSTT[8]) == '0  ' //Se a MDO foi prevista, adiciona a array com '0' na primeira posicao
									If nPosMDO == 0
										AADD(aMDO,{'0',&(_aSTLouSTT[9]+'+'+_aSTLouSTT[6])})
									Else
										aMDO[nPosMDO][1] := '0'
									Endif
								Else //MDO REALIZADA
									If nPosMDO == 0 //Senao tiver previsto a MDO, adiciona na array
										AADD(aMDO,{'1',&(_aSTLouSTT[9]+'+'+_aSTLouSTT[6]),&(_aSTLouSTT[7])})

										aArea1 := (_aSTLouSTT[1])->(GetArea())
										aArea2 := (cAliasQry)->(GetArea())
										dbSelectArea(cAliasQry)
										dbSetOrder(01)
										If dbSeek(&cChaveSTL2)
											RecLock(cAliasQry,.F.)
											&(aSTLouSTT[11]) := 0
											MsUnLock(cAliasQry)
										EndIf
										RestArea(aArea2)
										RestArea(aArea1)
									Endif
								Endif

							Endif
						EndIf
					EndIf

					dbSelectArea(_aSTLouSTT[1])
					dbSkip()
				End
			Endif
			For nI := 1 to Len(aMDO)
				If aMDO[nI][1] == '1' //Guarda apenas os realizados, quando MDO
					nValorReal += aMDO[nI][3]
				Endif
			Next
			RecLock(cAliasQry,.F.)
			(cAliasQry)->VALPRE := &(aSTLouSTT[11])
			(cAliasQry)->VALREA := nValorReal
			MsUnLock(cAliasQry)

		Endif

		(cAliasQry)->(dbSkip())
	EndDo

	RestArea(aAreaOld)

Return Nil

//---------------------------------------------------------------------------
/*/{Protheus.doc} MontaTree
Monta a estrutura de OS
@author Marcos Wagner Junior
@since 18/10/2010
@version undefined
@param _nSoma, numeric, posição do elemento - ex: aBoxDir[n]
@param lNivel1, logical, indica se é o primeiro nível
@param cNivelPai, characters, Nivel pai - ex: 'OFI'
@param cDesNivPai, characters, descrição do nivel pai - ex: 'OFICINA'
@param _cTabela, characters, alias da tabela - ex: 'STJ'

@type function
/*/
//---------------------------------------------------------------------------
Static Function MontaTree(_nSoma,lNivel1,cNivelPai,cDesNivPai,_cTabela)

	Local nIniPai		:= 0
	Local nIniPes		:= 0
	Local CNIVEL		:= StrZero(_nSoma,2)
	Local cNIVSUP		:= '0000'
	Local cOldTJORDEM	:= ''
	Local cDescricao	:= ''
	Local nI
	Local lAddFil		:= .T.
	Local lMNTC9352		:= ExistBlock("MNTC9352")
	Local nTamSTD		:= TAMSX3("TD_NOME")[1]
	Local nTamSTE		:= TAMSX3("TE_NOME")[1]
	Local nTamST4		:= TAMSX3("T4_NOME")[1]
	Local nTamST6		:= TAMSX3("T6_NOME")[1]

	Default nEST := 0

	For nI := 1 to Len(aBoxDir)-1
		nIniPai += aBoxDir[nI][3]
	Next
	nIniPes := nIniPai

	dbSelectArea(cAliasQry)
	dbGoTop()
	While !Eof()

		//Se o valor for vazio, pula pro proximo registro
		If &(aSTLouSTT[11]) == 0 .And. (aSTLouSTT[11] <> "(cAliasQry)->TRX_VALPAG" .And. aSTLouSTT[11] <> "(cAliasQry)->TS1_VALPAG" )
			dbSkip()
			Loop
		Endif

		cChavePai := ''
		cChavePes := ''

		cT9CCUSTO  := IIF(Empty(&(aSTLouSTT[4])),Space(Len(ST9->T9_CCUSTO)),&(aSTLouSTT[4]))
		cTJCODAREA := IIF(Empty(&(aSTLouSTT[5])),Space(Len(STJ->TJ_CODAREA)),&(aSTLouSTT[5]))
		cTJTIPO    := IIF(Empty(&(aSTLouSTT[6])),Space(Len(STJ->TJ_TIPO)),&(aSTLouSTT[6]))
		cTJSERVICO := IIF(Empty(&(aSTLouSTT[7])),Space(Len(STJ->TJ_SERVICO)),&(aSTLouSTT[7]))
		cT9CODFAMI := IIF(Empty(&(aSTLouSTT[12])),Space(Len(ST9->T9_CODFAMI)),&(aSTLouSTT[12]))
		cT9CODBEM  := IIF(Empty(&(aSTLouSTT[1])),Space(Len(STJ->TJ_CODBEM)),&(aSTLouSTT[1]))
		cTJORDEM   := IIF(Empty(&(aSTLouSTT[8])),Space(Len(STJ->TJ_ORDEM)),&(aSTLouSTT[8]))
		cTJPLANO   := IIF(Empty(&(aSTLouSTT[30])),Space(Len(STJ->TJ_PLANO)),&(aSTLouSTT[30]))
		dDATATAB   := IIF(Empty(&(aSTLouSTT[19])),"  /  /  ",&(aSTLouSTT[19]))
		cHORATAB   := IIF(Empty(&(aSTLouSTT[23])),Space(5),&(aSTLouSTT[23]))
		cPARCELA   := IIF(Empty(&(aSTLouSTT[20])),0,&(aSTLouSTT[20]))
		cDOCUMENTO := IIF(Empty(&(aSTLouSTT[21])),Space(Len(TS1->TS1_DOCTO)),&(aSTLouSTT[21]))
		cCHAVETAB  := IIF(Empty(&(aSTLouSTT[24])),'',&(aSTLouSTT[24]))
		cT5TAREFA  := IIF(Empty(&(aSTLouSTT[25])),Space(Len(ST5->T5_DESCRIC)),&(aSTLouSTT[25]))
		cTIPOINSUM := IIF(Empty(&(aSTLouSTT[28])),'',&(aSTLouSTT[28]))
		cCODINSUMO := IIF(Empty(&(aSTLouSTT[29])),'',&(aSTLouSTT[29]))
		cMESANO    := AllTrim(StrZero(Month(STOD(dDATATAB)),2)+'/'+AllTrim(Str(Year(STOD(dDATATAB)))))

		cDIVISAO   := cNivelPai

		For nI := 1 to _nSoma
			cChavePai += &(aBoxDir[nI][4])
			If (_nSoma > 1 .AND. nI <> _nSoma) .OR. Empty(cChavePes)
				cChavePes += &(aBoxDir[nI][4])
			Endif
		Next

		If aBoxDir[_nSoma][2] == '01'
			cCodigo    := cNivelPai
			cDescricao := cDesNivPai
			cChavFilho := cNivelPai
			cCargo     := 'DIV'
			If cNivelPai == 'OFI'
				cFolderA   := 'ng_ico_oficina'
				cFolderB   := 'ng_ico_oficina'
			ElseIf cNivelPai == 'DOC'
				cFolderA   := 'NG_ICO_DOC2'
				cFolderB   := 'NG_ICO_DOC1'
			ElseIf cNivelPai == 'ABA'
				cFolderA   := 'NG_ICO_ABAST1'
				cFolderB   := 'NG_ICO_ABAST2'
			ElseIf cNivelPai == 'SIN'
				cFolderA   := 'NG_ICO_SINISTRO2'
				cFolderB   := 'NG_ICO_SINISTRO1'
			ElseIf cNivelPai == 'MUL'
				cFolderA   := 'NG_ICO_MULTAS2'
				cFolderB   := 'NG_ICO_MULTAS1'
			ElseIf cNivelPai == 'PNE'
				cFolderA   := 'NG_ICO_PNEU2'
				cFolderB   := 'NG_ICO_PNEU1'
			Endif
		ElseIf aBoxDir[_nSoma][2] == '03'
			cCodigo    := AllTrim(cTJCODAREA)
			cDescricao := SubStr(NGSEEK("STD",cCodigo,1,"TD_NOME"),1,nTamSTD)
			cChavFilho := xFilial('STD')+cTJCODAREA
			cCargo     := 'STD'
			cFolderA   := 'NG_ICO_AREAMNT'
			cFolderB   := 'NG_ICO_AREAMNT'
		ElseIf aBoxDir[_nSoma][2] == '04'
			cCodigo    := AllTrim(cTJTIPO)
			cDescricao := SubStr(NGSEEK("STE",cCodigo,1,"TE_NOME"),1,nTamSTE)
			cChavFilho := xFilial('STE')+cTJTIPO
			cCargo     := 'STE'
			cFolderA   := 'NG_ICO_TIPOSERVICO'
			cFolderB   := 'NG_ICO_TIPOSERVICO'
		ElseIf aBoxDir[_nSoma][2] == '05'
			cCodigo    := AllTrim(cTJSERVICO)
			cDescricao := SubStr(NGSEEK("ST4",cCodigo,1,"T4_NOME"),1,nTamST4)
			cChavFilho := xFilial('ST4')+cTJSERVICO
			cCargo     := 'ST4'
			If &(aSTLouSTT[18]) == 'C'
				cFolderA := 'NG_ICO_IOSCO'
				cFolderB := 'NG_ICO_IOSCO'
			ElseIf &(aSTLouSTT[18]) == 'P'
				cFolderA := 'NG_ICO_IOSPR'
				cFolderB := 'NG_ICO_IOSPR'
			Endif
		ElseIf aBoxDir[_nSoma][2] == '06'
			cCodigo    := AllTrim(cT9CODFAMI)
			cDescricao := SubStr(NGSEEK("ST6",cCodigo,1,"T6_NOME"),1,nTamST6)
			cChavFilho := xFilial('ST6')+cT9CODFAMI
			cCargo     := 'ST6'
			cFolderA   := 'NG_ICO_FAMILIA'
			cFolderB   := 'NG_ICO_FAMILIA'
		ElseIf aBoxDir[_nSoma][2] == '07'
			cCodigo    := AllTrim(cT9CODBEM)
			cDescricao := If(Empty(AllTrim(&(aSTLouSTT[13]))) .And. aSTLouSTT[31] == '(cAliasQry)->TAF_NOMNIV',;
			IIf(!Empty((cAliasQry)->TAF_CODNIV), AllTrim(&(aSTLouSTT[31])),""), AllTrim(&(aSTLouSTT[13])) )
			cChavFilho := xFilial('ST9')+cT9CODBEM
			cCargo     := 'ST9'
			cFolderA   := 'ENGRENAGEM'
			cFolderB   := 'ENGRENAGEM'
		ElseIf aBoxDir[_nSoma][2] == '08'
			If _cTabela == 'STJ'
				cCodigo    := cTJORDEM
				cDescricao := ''
				cChavFilho := xFilial('STJ')+cTJORDEM
				cFolderA   := 'NGOSVERDE'
				cFolderB   := 'NGOSVERDE'
			ElseIf _cTabela == 'TS1'
				cCodigo    := AllTrim(cDOCUMENTO)
				cDescricao := AllTrim(&(aSTLouSTT[22]))
				cChavFilho := xFilial('ST1')+AllTrim(cDOCUMENTO)
				cFolderA   := 'NG_ICO_DOCDET'
				cFolderB   := 'NG_ICO_DOCDET'
			ElseIf _cTabela == 'TQN'
				cCodigo    := AllTrim(dDATATAB+cHORATAB)
				cDescricao := ''
				cChavFilho := xFilial('TQN')+cCHAVETAB
				cFolderA   := 'NG_ICO_ABASTDET'
				cFolderB   := 'NG_ICO_ABASTDET'
			ElseIf _cTabela == 'TRH'
				cCodigo    := AllTrim(dDATATAB+cHORATAB)
				cDescricao := ''
				cChavFilho := xFilial('TRH')+cCHAVETAB
				cFolderA   := 'NG_ICO_SINISTRODET'
				cFolderB   := 'NG_ICO_SINISTRODET'
			ElseIf _cTabela == 'TRX'
				cCodigo    := AllTrim(dDATATAB+cHORATAB)
				cDescricao := ''
				cChavFilho := xFilial('TRX')+cCHAVETAB
				cFolderA   := 'NG_ICO_MULTASDET'
				cFolderB   := 'NG_ICO_MULTASDET'
			ElseIf _cTabela == 'MEA'
				dDATATAB   := STOD(dDATATAB)
				cCodigo    := AllTrim(StrZero(Month(dDATATAB),2)+'/'+AllTrim(Str(Year(dDATATAB))))
				cDescricao := ''
				cChavFilho := cCHAVETAB
				cFolderA   := 'NG_ICO_ABASTDET'
				cFolderB   := 'NG_ICO_ABASTDET'
				dDATATAB   := DTOS(dDATATAB)
			Endif
			cCargo     := _cTabela
		ElseIf aBoxDir[_nSoma][2] == '09'
			cCodigo    := AllTrim(cT5TAREFA)
			lCorret := (Val(cTJPLANO) == 0)
			If NGUSATARPAD()
				cDescricao := NGSEEK("TT9",cCodigo,1,"TT9_DESCRI")
				cChavFilho := xFilial('TT9')+cCodigo
			Else
				cDescricao := NGSEEK("ST5",&(aSTLouSTT[26])+cCodigo,1,"T5_DESCRIC")
				cChavFilho := xFilial('ST5')+&(aSTLouSTT[26])+cCodigo
			Endif
			cDescricao := If(Empty(cDescricao),STR0116,cDescricao)  //"SEM ESPECIFICACAO DE TAREFA"
			cCargo     := 'ST5'
			cFolderA   := 'NG_ICO_TAREFA'
			cFolderB   := 'NG_ICO_TAREFA'
		ElseIf aBoxDir[_nSoma][2] == '10'
			cCodigo    := AllTrim(cT9CCUSTO)
			cDescricao := AllTrim(&(aSTLouSTT[27]))
			cChavFilho := xFilial('CTT')+cT9CCUSTO
			cCargo     := 'CTT'
			cFolderA   := 'NG_ICO_CCUSTO'
			cFolderB   := 'NG_ICO_CCUSTO'
		ElseIf aBoxDir[_nSoma][2] == '11'
			cCodigo    := AllTrim(cTIPOINSUM)
			cDescricao := TIPREGBRW(cTIPOINSUM)
			cChavFilho := cTIPOINSUM
			If cTIPOINSUM == 'E'
				cFolderA   := 'NG_TREE_ESPECIALIDADE01'
				cFolderB   := 'NG_TREE_ESPECIALIDADE02'
			ElseIf cTIPOINSUM == 'F'
				cFolderA   := 'NG_TREE_FERRAMENTA01'
				cFolderB   := 'NG_TREE_FERRAMENTA02'
			ElseIf cTIPOINSUM == 'P'
				cFolderA   := 'NG_TREE_PRODUTO01'
				cFolderB   := 'NG_TREE_PRODUTO02'
			ElseIf cTIPOINSUM == 'M'
				cFolderA   := 'NG_TREE_FUNCIONARIO01'
				cFolderB   := 'NG_TREE_FUNCIONARIO02'
			ElseIf cTIPOINSUM == 'T'
				cFolderA   := 'NG_TREE_TERCEIROS01'
				cFolderB   := 'NG_TREE_TERCEIROS02'
			Endif
			cCargo     := 'TIN'
		Endif
		nNivel        := _nSoma

		If _nSoma == 1
			cChavePes := Space(53) //Alimenta com espaco, para dar o seek correto (CHAVPAI)
		Endif

		DbSelectArea(cTRBMAIN)
		dbSetOrder(6)
		If !dbSeek(cChavePai);
		.And. !Empty(cCodigo)  //quando filial compartilhada, na ordenacao por filial nao deve mostrar filial branco

			nEST++
			If _nSoma > 1 //Se maior que 1, entao ja tem um 'nivel pai'
				DbSelectArea(cTRBMAIN)
				dbSetOrder(6)
				If dbSeek(cChavePes)
					cNIVSUP := (cTRBMAIN)->CODEST
				Endif
			Endif

			RecLock(cTRBMAIN,.t.)
			(cTRBMAIN)->CODEST  := StrZero( nEST, 4 )
			(cTRBMAIN)->NIVSUP  := cNIVSUP
			(cTRBMAIN)->CODPRO  := StrZero( nEST, 4 )
			(cTRBMAIN)->CODIGO  := cCodigo
			(cTRBMAIN)->DESCRI  := cDescricao
			(cTRBMAIN)->CARGO   := cCargo
			(cTRBMAIN)->NIVEL   := nNivel
			(cTRBMAIN)->CNIVEL  := CNIVEL
			(cTRBMAIN)->CHAVPAI := cChavePai
			(cTRBMAIN)->CHAVFIL := cChavFilho
			(cTRBMAIN)->DIVISAO := cNivelPai
			(cTRBMAIN)->TABELA  := _cTabela
			(cTRBMAIN)->DATATAB := STOD(dDATATAB)
			(cTRBMAIN)->HORATAB := cHORATAB
			(cTRBMAIN)->PARCELA := cPARCELA
			(cTRBMAIN)->MESANO  := cMESANO

			If AllTrim(&(aSTLouSTT[10])) == '0'
				(cTRBMAIN)->VALPRE += &(aSTLouSTT[11])
				If cTIPOINSUM == 'E'
					(cTRBMAIN)->VALREA += (cAliasQry)->VALREA
				Endif
			Else
				(cTRBMAIN)->VALREA += &(aSTLouSTT[11])
			Endif

			If aSTLouSTT[10] == "(cAliasQry)->TRX_VALOR" .Or. aSTLouSTT[10] == "(cAliasQry)->TS1_VALOR"
				(cTRBMAIN)->VALPRE += &(aSTLouSTT[10])
			EndIf

			If cNivelPai == 'OFI' .OR. cNivelPai == 'PNE'
				(cTRBMAIN)->QTDEOS := 1
			Endif
			(cTRBMAIN)->(MsUnlock())

			oTree:TreeSeek( cNIVSUP )

			If _cTabela $ ('TQN/TRH/TRX')
				cCodigo := DTOC(STOD(dDATATAB)) + ' - ' + cHORATAB
			Endif

			If _cTabela != 'TQN' .AND. _cTabela != 'STJ' //Nao adicionar na arvore se for abastecimento ou O.S., pois teremos informacoes demais
				If lMNTC9352
					lAddFil := ExecBlock("MNTC9352",.F.,.F.)
				EndIf
				If lAddFil
					oTree:AddItem(cCodigo+IIF(!Empty(cDescricao),' - '+cDescricao,''), StrZero( nEST, 4 )+cCargo,cFolderA,cFolderB,,, 2 )
					oTree:PtCollapse()
				EndIf
			EndIf
		ElseIf !Empty(cCodigo)  //quando filial compartilhada, na ordenação por filial não deve mostrar filial em branco
			RecLock(cTRBMAIN,.f.)
			If AllTrim(&(aSTLouSTT[10])) == '0'
				(cTRBMAIN)->VALPRE += &(aSTLouSTT[11])
				If cTIPOINSUM == 'E'
					(cTRBMAIN)->VALREA += (cAliasQry)->VALREA
				Endif
			Else
				(cTRBMAIN)->VALREA += &(aSTLouSTT[11])
				If aSTLouSTT[10] == "(cAliasQry)->TRX_VALOR" .Or. aSTLouSTT[10] == "(cAliasQry)->TS1_VALOR"
					(cTRBMAIN)->VALPRE += &(aSTLouSTT[10])
				EndIf
			Endif
			If (cNivelPai == 'OFI' .OR. cNivelPai == 'PNE') .AND. (Empty(cOldTJORDEM) .OR. cOldTJORDEM != cTJORDEM)
				(cTRBMAIN)->QTDEOS += 1
			Endif
			(cTRBMAIN)->(MsUnlock())
		Endif

		cOldTJORDEM := cTJORDEM

		dbSelectArea(cAliasQry)
		(cAliasQry)->(dbSkip())

		If cTJORDEM != IIF(Empty(&(aSTLouSTT[8])),Space(Len(STJ->TJ_ORDEM)),&(aSTLouSTT[8])) .OR. Eof()

			oTree:TreeSeek( StrZero( nEST, 4 ) )

			If Trim( SubStr( oTree:GetCargo(), 5, 4 ) ) == 'STJ' .AND. (cTRBMAIN)->VALREA > (cTRBMAIN)->VALPRE
				dbSelectArea(oTree:cArqTree)
				oTree:ChangeBmp('NGOSVERMELHO','NGOSVERMELHO')
			Endif
		Endif

		dbSelectArea(cAliasQry)

	End

Return .t.

//---------------------------------------------------------------------------
/*/{Protheus.doc} ColapTotal
Monta a estrutura de OS

@author Marcos Wagner Junior
@since 18/10/2010
@version undefined

@type function
/*/
//---------------------------------------------------------------------------
Static Function ColapTotal()

	Local nMaxNvl := nEST

	dbSelectArea(cTRBMAIN)
	dbSetOrder(3)
	If (cTRBMAIN)->(RecCount()) > 0
		While nMaxNvl >= 0

			If dbSeek(StrZero( nMaxNvl, 4 ) )

				oTree:TreeSeek( StrZero( nMaxNvl,4 ) )
				oTree:PtCollapse()

			Endif
			nMaxNvl--
		End
	EndIf

Return .t.

//---------------------------------------------------------------------------
/*/{Protheus.doc} GerarConsulta
Botao Gerar Consulta
@author Marcos Wagner Junior
@since 30/09/2010
@version undefined
@param lEnd, logical
@param _lFirst, logical
@type function
/*/
//---------------------------------------------------------------------------
Static Function GerarConsulta(lEnd,_lFirst)
	Local lOpen := .T.
	Private nI, lNivel1 := .t.
	Private cFolderA := "FOLDER10" // Folder Verde Fechado
	Private cFolderB := "FOLDER11" // Folder Verde Aberto
	Private cPredio := "predio"
	Private cCargo := 'LOC'
	Private nEST := 0
	Private aSTLouSTT := {}

	lFirst := .f.

	If !MNC935PAR()
		Return .f.
	Endif

	If ValType('oEnc') == 'O'
		oEnc:Hide()
		oEnc:EnchRefreshAll()
	Endif

	fHideRefre(@oPnlUpR1)

	GerarDados(.f.)

	If !_lFirst .And. (lTemOS .Or. lTemOut)
		dbSelectArea(cTRBMAIN)
		Zap

		oTree:Reset()
		oTree:SetUpdatesEnable(.F.)

		If Type('oBrowseRO1') == 'O'
			oBrowseRO1:aArray := {}
			oBrowseRO1:GoTop()
			oBrowseRO1:Refresh()
		Endif

		DbAddTree oTree Prompt AllTrim( SM0->M0_FILIAL ) + Space( 56 - Len( AllTrim( SM0->M0_FILIAL ) ) ) Opened Resource cPredio,cPredio Cargo '0000' + cCargo

	Endif

	lMsgLeft := .F.

	GerarDados(.t.)

	If lMsgLeft
		If (!lFolder1 .And. !lFolder3) .Or. !lTemOS
			lOpen := .F.
			MsgInfo(STR0032,STR0033) //"Não há dados para os parâmetros e níveis selecionados."###"ATENÇÃO"
		Else
			MsgInfo(	STR0034+; //"Para apresentar as informações de alguns dos itens do Gestão de Frotas (sinistros, multas etc.) "
			STR0035) //"é necessário incluir ao menos um dos seguintes níveis: filial, bem, familia ou componente de custo."
		EndIf
	EndIf


	If lTemOS .Or. lTemOut

		If lOpen
			oDlgParame:End()
		EndIf

		DbEndTree oTree
		ColapTotal()
		oTree:Refresh()

		oBtnRelato:lVisible := .t.

		MsgRun(STR0029,STR0030,{||MNTDCVIS()}) //"Carregando tela do item selecionado, aguarde..."###"Carregando"

		If !_lFirst
			oTree:SetUpdatesEnable(.T.)
			oTree:SetFocus()
		Endif
	Else
		MsgInfo(STR0032,STR0033) //"Não há dados para os parâmetros e níveis selecionados."###"ATENÇÃO"
	Endif

Return .t.

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    |MNC935DeAt| Autor ³Marcos Wagner Junior   ³ Data ³ 07/12/10 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o | Valida todos codigos De... , Ate...,                       ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ MNTC935                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function MNC935DeAt(nOpc,cParDe,cParAte,cTabela,_nZZ)

	If (Empty(cParDe) .AND. cParAte == Replicate('Z',_nZZ))
		Return .t.
	Else
		If nOpc == 1
			If Empty(cParDe)
				Return .t.
			Else
				lRet := IIf(Empty(cParDe),.t.,ExistCpo(cTabela,cParDe))
				If !lRet
					Return .f.
				EndIf
			Endif
		ElseIf nOpc == 2
			If (cParAte == Replicate('Z',_nZZ))
				Return .t.
			Else
				lRet := IIF(ATECODIGO(cTabela,cParDe,cParAte,10),.T.,.F.)
				If !lRet
					Return .f.
				EndIf
			EndIf
		EndIf
	Endif

Return .t.

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    |ChangeFer | Autor ³Marcos Wagner Junior   ³ Data ³ 07/12/10 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o | Evento Change do CheckBox de Ferramenta                    ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ MNTC935                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function ChangeFer()

	If lFerrament
		cAteFerram := IIF(Empty(cAteFerram),Replicate('Z',Len(SH4->H4_CODIGO)),cAteFerram)
	Endif
	oInvisivel:SetFocus()
	oFerramenta:SetFocus()

Return .t.

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    |ChangeMdo | Autor ³Marcos Wagner Junior   ³ Data ³ 07/12/10 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o | Evento Change do CheckBox de M-D-O                         ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ MNTC935                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function ChangeMdo()

	If lMaodeObra
		cAteMdo := IIF(Empty(cAteMdo),Replicate('Z',Len(ST1->T1_CODFUNC)),cAteMdo)
	Endif
	oInvisivel:SetFocus()
	oMaodeObra:SetFocus()

Return .t.

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    |ChangePro | Autor ³Marcos Wagner Junior   ³ Data ³ 07/12/10 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o | Evento Change do CheckBox de Produto                       ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ MNTC935                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function ChangePro()

	If lProduto
		cAteProd := IIF(Empty(cAteProd),Replicate('Z',Len(SB1->B1_COD)),cAteProd)
	Endif
	oInvisivel:SetFocus()
	oDeProd:SetFocus()

Return .t.

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    |ChangeTer | Autor ³Marcos Wagner Junior   ³ Data ³ 07/12/10 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o | Evento Change do CheckBox de Terceiro                      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ MNTC935                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function ChangeTer()

	If lTerceiro
		cAteTerc := IIF(Empty(cAteTerc),Replicate('Z',Len(SA2->A2_COD)),cAteTerc)
	Endif
	oInvisivel:SetFocus()
	oTerceiro:SetFocus()

Return .t.

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    |ChangeEsp | Autor ³Marcos Wagner Junior   ³ Data ³ 07/12/10 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o | Evento Change do CheckBox de Especialidade                 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ MNTC935                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function ChangeEsp()

	If lEspeciali
		cAteEspec := IIF(Empty(cAteEspec),Replicate('Z',Len(ST0->T0_ESPECIA)),cAteEspec)
	Endif
	oInvisivel:SetFocus()
	oEspecialidade:SetFocus()

Return .t.

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³ MNT935VRun ³ Autor ³ Marcos Wagner Junior ³ Data ³ 07/12/10 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³Carrega os registros do item selecionado.                    ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ MNTA935                                                     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³         Atualizacoes Sofridas Desde a Construcao Inicial.              ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Programador ³ Data   ³ F.O  ³  Motivo da Alteracao                      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³            ³        ³      ³                                           ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Static Function MNT935VRun()
	MsgRun(STR0029,STR0030,{||MNT935Enc()}) //"Carregando Tela do item selecionado, aguarde..."###"Carregando"
Return .T.
/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³  MNT935Enc ³ Autor ³ Marcos Wagner Junior ³ Data ³ 07/12/10 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³Mostra os registros do item selecionado na Enchoice          ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ MNTA935                                                     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³         Atualizacoes Sofridas Desde a Construcao Inicial.              ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Programador ³ Data   ³ F.O  ³  Motivo da Alteracao                      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³            ³        ³      ³                                           ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Static Function MNT935Enc()

	Local i           := 0
	Local nI          := 0
	Local cCod        := Trim( SubStr( oTree:GetCargo(), 1, 4 ) )
	Local _cCargo     := Trim( SubStr( oTree:GetCargo(), 5, 4 ) )
	Local lCarregaEnc := .F.

	oPnlDownR1:Hide()
	For nI := 1 To Len(aTabRegToM)
		If aTabRegToM[nI] == _cCargo
			lCarregaEnc := .t.
			Exit
		Endif
	Next

	If !lCarregaEnc
		Return .T.
	Else
		fLoadArea(@_cCargo,cCod)
		_cAlias := _cCargo
		_nRecno := _cCargo+"->(Recno())"
		_cRelac := _cCargo+"->"
	EndIf

	//carrega caminho atual percorrido na arvore
	fUpdateWay((cTRBMAIN)->(RecNo()),cCod)


	cAlias := _cAlias
	nOpcx := 2
	nRecno := &_nRecno
	bCampo  := {|nCPO| Field(nCPO) }
	aNao := {}
	If _cCargo == "ST9"
		If lGFrota
			aNao    := {}
		Else
			aNao    := {"T9_CODTMS"	,;
			"T9_PLACA"	,;
			"T9_CAPMAX"	,;
			"T9_MEDIA"	,;
			"T9_TIPVEI"	,;
			"T9_ANOMOD"	,;
			"T9_ANOFAB"	,;
			"T9_CHASSI"	,;
			"T9_CORVEI"	,;
			"T9_DESCOR"	,;
			"T9_CIDEMPL",;
			"T9_UFEMPLA",;
			"T9_RENAVAM",;
			"T9_NRMOTOR",;
			"T9_CEREVEI"}
		EndIf
	Endif
	dbSelectArea(_cAlias)
	aChoice  := NGCAMPNSX3(_cAlias,aNao)
	For i := 1 To FCOUNT()
		cCampo := "M->" + FieldName(i)
		cRelac := _cRelac + FieldName(i)
		&cCampo. := &cRelac
	Next

	fHideRefre(@oPnlUpR2)

	If Type("oEnc") == "O"
		oEnc:hide()
		oPnlUpR2:FreeChildren()
		oEnc:=NIL
		oPnlUpR2:Hide()
		oPnlUpR2:Refresh()
		aGets  := Array(0)
		aTela  := Array(0,0)
	EndIf

	dbSelectArea(cAlias)
	dbSetOrder(1)
	RegToMemory(cAlias,.f.)

	oEnc:= MsMGet():New(cAlias,nRecno,2,,,,aChoice,{000,000,000,000},,,,,,oPnlUpR2,,.T./*lMemoria*/)

	//carrega variaveis auxiliares para o enchoice
	If _cCargo == "ST9" //SXB NG1 de T9_CENTRAB
		M->TP9_CCUSTO := M->T9_CCUSTO
	EndIf

	oEnc:oBox:Align		:= CONTROL_ALIGN_ALLCLIENT
	oEnc:Disable()
	oEnc:EnchRefreshAll()
	oPnlUpR2:Show()
	oPnlUpR2:Refresh()

Return .T.

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³ fLoadArea  ³ Autor ³ Marcos Wagner Junior ³ Data ³ 21/12/10 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Verifica possibilidade de carregar dados em enchoice e se o ³±±
±±³          ³ registro em selecao existe em base.                         ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ MNTC935                                                     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Static Function fLoadArea(_cCargo,cCod,lRestore)
	Local aArea
	Local lRet := .F.
	Default lRestore := .F.

	If _cCargo == "TS1"
		_cCargo := "TS0"
	ElseIf _cCargo == "ST5"
		If NGUSATARPAD()
			_cCargo := "TT9"
		EndIf
	Endif

	If Select(_cCargo) > 0
		dbSelectArea(cTRBMAIN)
		dbSetOrder(2)
		dbSeek(cCod)

		aArea := &(_cCargo)->(GetArea())
		dbSelectArea(_cCargo)
		dbSetOrder(1)
		dbSeek(RTrim((cTRBMAIN)->CHAVFIL))
		lRet := Found()

		If lRestore .And. _cCargo == "SM0"
			RestArea(aArea)
		EndIf
	EndIf

Return lRet

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³ fLoadSTL ³ Autor ³ Denis                 ³ Data ³ 06.09.01 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Carrega aCols do STL nos campos temporarios M->            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³ Nenhum                                                     ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Static Function fLoadSTL(lStartVar)

	Local nI       := 0
	Local nIns     := 0
	Local _cTAREFA := ''

	If !lStartVar
		Return .t.
	Endif

	dbSelectArea(cTRBMAIN)
	dbSetOrder(2)
	dbSeek( SubStr( oTree:GetCargo(), 1, 4 ) )
	cOrdemTJ := AllTrim((cTRBMAIN)->CHAVFIL)

	If aSCAN(aBoxDir,{|x| x[2] = '09' }) <> 0
		While !Eof() .AND. Empty(_cTAREFA)
			dbSelectArea(cTRBMAIN)
			dbSetOrder(1)
			If dbSeek((cTRBMAIN)->NIVSUP) .AND. (cTRBMAIN)->TABELA == "ST5"
				_cTAREFA := AllTrim((cTRBMAIN)->CODIGO)
			Endif
		End
	Endif

	For nIns := 1 To 2
		If nIns == 1
			aCols := BlankGetD(aHoBrw1)
			aHoBrw := aHoBrw1
			aSTLouSTT := {'STJ','STL'}
		Else
			If !Empty(aCols[1][1])
				Exit
			Endif
			aCols := BlankGetD(aHoBrw2)
			aHoBrw := aHoBrw2
			aSTLouSTT := {'STS','STT'}
		Endif

		dbSelectArea(aSTLouSTT[1])
		dbSetOrder(01)
		dbSeek(xFilial(aSTLouSTT[1])+cOrdemTJ)

		cAliasAux := GetNextAlias()
		cQuery := "SELECT "
		aCamposOK := aCamposOK1
		For nI := 1 to Len(aCamposOK)
			cQuery += aCamposOK[nI] + IIF(nI <> Len(aCamposOK),',','')
		Next
		cQuery += " FROM "+RetSqlName(aSTLouSTT[2])
		cQuery += " WHERE TL_ORDEM = '"+cOrdemTJ+"' AND "
		cQuery += " D_E_L_E_T_ = ' '"
		If !Empty(_cTAREFA)
			cQuery += " AND TL_TAREFA = '" + _cTAREFA + "'"
		Endif
		If oBrowseRO1:aArray[oBrowseRO1:nAt][1] == STR0036 //"Especialidade"
			cQuery += " AND TL_TIPOREG = 'E' "
		ElseIf oBrowseRO1:aArray[oBrowseRO1:nAt][1] == STR0037 //"Mao de Obra"
			cQuery += " AND TL_TIPOREG = 'M' "
		ElseIf oBrowseRO1:aArray[oBrowseRO1:nAt][1] == STR0038 //"Produto"
			cQuery += " AND TL_TIPOREG = 'P' "
		ElseIf oBrowseRO1:aArray[oBrowseRO1:nAt][1] == STR0039 //"Terceiro"
			cQuery += " AND TL_TIPOREG = 'T' "
		ElseIf oBrowseRO1:aArray[oBrowseRO1:nAt][1] == STR0036 //"Especialidade"
			cQuery += " AND TL_TIPOREG = 'E' "
		Endif
		If nIns == 2
			cQuery := StrTran(cQuery,'TL_','TT_')
		Endif
		cQuery := ChangeQuery(cQuery)
		dbUseArea( .T., "TOPCONN", TCGENQRY(,,cQuery),cAliasAux, .F., .T.)

		dbSelectArea(cAliasAux)
		While !Eof()
			aColsAux := BlankGetD(aHoBrw)
			RegToMemory(aSTLouSTT[2],.f.)
			For nI := 1 to Len(aHoBrw)
				If aHoBrw[nI][10] == 'V'
					aColsAux[Len(aColsAux)][nI] := CriaVar(AllTrim(aHoBrw[nI][2]))
				Else
					aColsAux[Len(aColsAux)][nI] := (cAliasAux)->&(aHoBrw[nI][2])
				Endif
			Next
			aColsAux[Len(aColsAux)][Len(aColsAux[1])] := .f.
			If Empty(aCols[1][1])
				aCols := {}
			Endif
			AADD(aCols,aColsAux[1])
			dbSelectArea(cAliasAux)
			dbSkip()
		End
	Next

	If oPnlUpR1:lVisibleControl
		oPnlUpR1:Hide()
		oPnlUpR1:Refresh()
	ElseIf oPnlUpR2:lVisibleControl
		oPnlUpR2:Hide()
		oPnlUpR2:Refresh()
	Endif
	oPnlUpR3:lVisible := .t.

	If ValType('oBrwSTL') <> 'O'
		oBrwSTL := MsNewGetDados():New(0,0,10000,10000,0,'MNT656OK(1)','MNT656OK(2)','',{},,2000,'AllwaysTrue()','','MNT656LIDE()',oPnlUpR3,aHoBrw,aCols)
		oBrwSTL:oBrowse:Align := CONTROL_ALIGN_ALLCLIENT
		oBrwSTL:oBrowse:bChange:= {|| fLoadSTL(.F.) }
		oBrwSTL:oBrowse:Default()
		oBrwSTL:oBrowse:Refresh()
	Endif

Return

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³fHideRefre³ Autor ³ Marcos Wagner Junior  ³ Data ³ 13/01/11 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³                                                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³ MNTC935                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Static Function fHideRefre(_oPanel)

	oPnlUpR1:Hide()
	oPnlUpR1:Refresh()
	oPnlUpR2:Hide()
	oPnlUpR2:Refresh()
	oPnlUpR3:Hide()
	oPnlUpR3:Refresh()

	_oPanel:Show()
	_oPanel:Refresh()

Return .t.

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³fHideRefre³ Autor ³ Marcos Wagner Junior  ³ Data ³ 13/01/11 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³                                                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³ MNTC935                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Static Function RelatoC935()

	Local WNREL      := "MNTC935"
	Local cDESC1     := ""
	Local cDESC2     := ""
	Local cDESC3     := ""
	Local cSTRING    := "ST9"
	Local nI

	Private NOMEPROG := "MNTC935"
	Private TAMANHO  := ""
	Private aRETURN  := {STR0040,1,STR0041,1,2,1,"",1} //"Zebrado"###"Administracao"
	Private TITULO   := STR0042 //"Relatório - Consulta Gerencial de Custos"
	Private nLASTKEY := 0
	Private CABEC1,CABEC2

	nTamanho := 0
	For nI := 1 to Len(aHeader)
		nTamanho += aHeader[nI][7]
		nTamanho += 3
	Next

	If nTamanho <= 80
		TAMANHO := "P"
	ElseIf nTamanho <= 132
		TAMANHO := "M"
	Else
		TAMANHO := "G"
	Endif

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Envia controle para a funcao SETPRINT                        ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	WNREL:=SetPrint(cSTRING,WNREL,Nil,TITULO,cDESC1,cDESC2,cDESC3,.F.,,,,,.F.)
	If nLASTKEY = 27
		Set Filter To
		DbSelectArea("ST9")
		Return
	EndIf
	SetDefault(aRETURN,cSTRING)
	RptStatus({|lEND| RelatoImpr(@lEND,WNREL,TITULO,TAMANHO)},TITULO)

Return Nil

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³ RelatoImpr ³Autor ³ Marcos Wagner Junior ³ Data ³19/02/2009³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³  Cria os relatorios													  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³                                                            ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Static Function RelatoImpr(lEND,WNREL,TITULO,TAMANHO)
	Local cOldCbc1 := ""
	Local nI := 0, nX := 0, cTexto
	Local cRODATXT := ""
	Local nCNTIMPR := 0
	Local aPos := {}, aWay := {}
	Local lRet := .t.
	Local lFirst := .t.
	Local nLimit := If(TAMANHO=="P",70,If(TAMANHO=="M",122,210))
	Private li := 80 ,m_pag := 1
	nTIPO  := IIf(aReturn[4]==1,15,18)

	CABEC1 := ''
	For nI := 1 To Len(aHeader)
		nLenColuna := Len(aHeader[nI][1])
		nLenCampo  := aHeader[nI][7]
		If nLenColuna > nLenCampo
			nEspaco := nLenColuna
		Else
			nEspaco := nLenCampo
		Endif

		nEspacoAnt := 0
		If aHeader[nI][6] == 'N'
			If nLenCampo > nLenColuna //.AND. aHeader[nI][1] <> '%'
				nEspacoAnt := nLenCampo-nLenColuna+IIF(aHeader[nI][1] == '%',-1,0)
			Endif
		Endif

		AADD(aPos,Len(CABEC1))

		CABEC1 += Space(nEspacoAnt) + aHeader[nI][1] + Space(nEspaco-Len(aHeader[nI][1])+3)
	Next

	/*/
	1         2         3         4         5         6         7         8         9         0         1         2         3
	01234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890
	***********************************************************************************************************************************
	Codigo             Descrição                                      Valor Previsto        %      Valor Realizado        %   Qtde O.S.
	***********************************************************************************************************************************
	xxxxxxxxxxxxxxxx   xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx   999,999,999,999.99   100,00   999,999,999,999.99   100,00       xxxxx
	xxxxxxxxxxxxxxxx   xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx   999,999,999,999.99   100,00   999,999,999,999.99   100,00       xxxxx
	*/

	/*/
	1         2         3         4         5         6         7         8
	0123456789012345678901234567890123456789012345678901234567890123456789012345678901234567
	****************************************************************************************
	Codigo                 Valor Previsto        %      Valor Realizado        %   Qtde O.S.
	****************************************************************************************
	xxxxxxxxxxxxxxxx   999,999,999,999.99   100,00   999,999,999,999.99   100,00       xxxxx
	xxxxxxxxxxxxxxxx   999,999,999,999.99   100,00   999,999,999,999.99   100,00       xxxxx
	*/

	/*/
	1         2         3         4         5         6
	012345678901234567890123456789012345678901234567890123456789012345
	******************************************************************
	Codigo       Valor Previsto        %      Valor Realizado        %
	******************************************************************
	xxxxxx   999,999,999,999.99   100,00   999,999,999,999.99   100,00
	xxxxxx   999,999,999,999.99   100,00   999,999,999,999.99   100,00

	*/

	CABEC2 := ""
	aTotais := {}

	If Len(aColsRod) == 0
		MsgInfo(STR0043,STR0033) //"Não existem dados para montar o relatório."###"ATENÇÃO"
		lRet := .f.
	Else

		cOldCbc1 := CABEC1
		CABEC1 := ''

		NgSomaLi(58,.F.)
		@Li,05 PSay STR0044 //"PARÂMETROS"

		NgSomaLi(58,.F.)
		NgSomaLi(58,.F.)
		@Li,05 PSay STR0045 //"Oficina"
		NgSomaLi(58,.F.)
		@Li,03 PSay Replicate("-",40)

		NgSomaLi(58,.F.)
		cTexto := ""
		For nX := 1 To Len(aEmQue)
			cTexto += If(nX == Val(cEmQue),"[x]","[ ]")+Space(1)+aEmQue[nX]+Space(2)
		Next nX

		@Li,07 PSay STR0085+": "+cTexto  //"Tipo de Manutenção"

		NgSomaLi( 58, .F. )
		cTexto := ''

		For nX := 1 To Len( aStatus )
			cTexto += IIf( nX == Val( cStatus ), '[x]', '[ ]' ) + Space( 1 ) + aStatus[nX] + Space( 2 )
		Next nX

		@Li,07 PSay STR0132 + cTexto // Considerar O.S.:

		NgSomaLi(58,.F.)
		@Li,07 PSay If(lFolder1,"[x]","[ ]")+Space(1)+STR0046 //"Listar dados"
		@Li,33 PSay STR0047+Space(1)+DTOC(dDtI1) //"de"
		@Li,66 PSay STR0048+Space(1)+DTOC(dDtF1) //"até"
		NgSomaLi(58,.F.)
		@Li,07 PSay If(lFerrament,"[x]","[ ]")+Space(1)+STR0049 //"Ferramenta"
		@Li,33 PSay STR0047+Space(1)+cDeFerram //"de"
		@Li,66 PSay STR0048+Space(1)+cAteFerram //"até"
		NgSomaLi(58,.F.)
		@Li,07 PSay If(lMaodeObra,"[x]","[ ]")+Space(1)+STR0050 //"Mão de Obra"
		@Li,33 PSay STR0047+Space(1)+cDeMdo //"de"
		@Li,66 PSay STR0048+Space(1)+cAteMdo //"até"
		NgSomaLi(58,.F.)
		@Li,07 PSay If(lProduto,"[x]","[ ]")+Space(1)+STR0038 //"Produto"
		@Li,33 PSay STR0047+Space(1)+cDeProd //"de"
		@Li,66 PSay STR0048+Space(1)+cAteProd //"até"
		NgSomaLi(58,.F.)
		@Li,07 PSay If(lTerceiro,"[x]","[ ]")+Space(1)+STR0039 //"Terceiro"
		@Li,33 PSay STR0047+Space(1)+cDeTerc //"de"
		@Li,66 PSay STR0048+Space(1)+cAteTerc //"até"
		NgSomaLi(58,.F.)
		@Li,07 PSay If(lEspeciali,"[x]","[ ]")+Space(1)+STR0036 //"Especialidade"
		@Li,33 PSay STR0047+Space(1)+cDeEspec //"de"
		@Li,66 PSay STR0048+Space(1)+cAteEspec //"até"

		If lGFrota

			NgSomaLi(58,.F.)
			NgSomaLi(58,.F.)
			@Li,05 PSay STR0051 //"Abastecimentos"
			NgSomaLi(58,.F.)
			@Li,03 PSay Replicate("-",40)
			NgSomaLi(58,.F.)
			@Li,07 PSay If(lFolder2,"[x]","[ ]")+Space(1)+STR0046 //"Listar dados"
			@Li,33 PSay STR0047+Space(1)+DTOC(dDtI5) //"de"
			@Li,66 PSay STR0048+Space(1)+DTOC(dDtF5) //"até"

			NgSomaLi(58,.F.)
			NgSomaLi(58,.F.)
			@Li,05 PSay STR0052 //"Pneus"
			NgSomaLi(58,.F.)
			@Li,03 PSay Replicate("-",40)
			NgSomaLi(58,.F.)
			@Li,07 PSay If(lFolder3,"[x]","[ ]")+Space(1)+STR0046 //"Listar dados"
			@Li,33 PSay STR0047+Space(1)+DTOC(dDtI6) //"de"
			@Li,66 PSay STR0048+Space(1)+DTOC(dDtF6) //"até"

			NgSomaLi(58,.F.)
			NgSomaLi(58,.F.)
			@Li,05 PSay STR0053 //"Sinistros"
			NgSomaLi(58,.F.)
			@Li,03 PSay Replicate("-",40)
			NgSomaLi(58,.F.)
			@Li,07 PSay If(lFolder4,"[x]","[ ]")+Space(1)+STR0046 //"Listar dados"
			@Li,33 PSay STR0047+Space(1)+DTOC(dDtI2) //"de"
			@Li,66 PSay STR0048+Space(1)+DTOC(dDtF2) //"até"

			NgSomaLi(58,.F.)
			NgSomaLi(58,.F.)
			@Li,05 PSay STR0054 //"Multas"
			NgSomaLi(58,.F.)
			@Li,03 PSay Replicate("-",40)
			NgSomaLi(58,.F.)
			@Li,07 PSay If(lFolder5,"[x]","[ ]")+Space(1)+STR0046 //"Listar dados"
			@Li,33 PSay STR0047+Space(1)+DTOC(dDtI3) //"de"
			@Li,66 PSay STR0048+Space(1)+DTOC(dDtF3) //"até"

			NgSomaLi(58,.F.)
			NgSomaLi(58,.F.)
			@Li,05 PSay STR0055 //"Documentos"
			NgSomaLi(58,.F.)
			@Li,03 PSay Replicate("-",40)
			NgSomaLi(58,.F.)
			@Li,07 PSay If(lFolder6,"[x]","[ ]")+Space(1)+STR0046 //"Listar dados"
			@Li,33 PSay STR0047+Space(1)+DTOC(dDtI4) //"de"
			@Li,66 PSay STR0048+Space(1)+DTOC(dDtF4) //"até"

		EndIf

		NgSomaLi(58,.F.)
		NgSomaLi(58,.F.)
		NgSomaLi(58,.F.)
		@Li,05 PSay STR0056 //"Níveis"
		NgSomaLi(58,.F.)
		@Li,03 PSay Replicate("-",40)

		//monta array com niveis
		aWay := StrTokArr(cCaminho,'\')
		aSize(aWay,Len(aWay)+1)
		aIns(aWay,1)
		aWay[1] := Space(02)

		//adiciona descricao em cada nivel
		aArea := (cTRBMAIN)->(GetArea())
		dbSelectArea(cTRBMAIN)
		dbSetOrder(02)
		If dbSeek( SubStr( oTree:GetCargo(), 1, 4 ) )

			For nI := Len(aWay) To 3 Step -1
				aWay[nI] := " "+AllTrim(aWay[nI])+" ("+AllTrim((cTRBMAIN)->DESCRI)+") "
				dbSelectArea(cTRBMAIN)
				dbSetOrder(01)
				dbSeek((cTRBMAIN)->NIVSUP)
			Next nI

			RestArea(aArea)

		EndIf

		//imprime os niveis
		nI := 1
		NgSomaLi(58,.F.)
		While nI <= Len(aWay)
			cTxt := If(nI==1,aWay[1]+aWay[2],Space(Len(aWay[1])))
			nI   += If(nI==1,2,0)
			While (nI) <= Len(aWay)
				If Len(cTxt+aWay[nI])+2 < nLimit
					cTxt += '\'+aWay[nI]
					nI++
				Else
					Exit
				EndIf
			EndDo
			@Li,05 PSay cTxt
			NgSomaLi(58,.F.)
		EndDo

		//quebra pagina
		CABEC1 := cOldCbc1
		Li := 59
		NgSomaLi(58,.F.)

		For nI := 1 To Len(aColsRod)
			NgSomaLi(58,.F.)
			For nX := 1 to Len(aHeader)
				lNumerico := .f.
				lTransform := .t.
				nRecua    := 0
				If aHeader[nX][4] == "@E 999,999,999,999.99" //Picture
					@Li,aPos[nX] Psay PADL(Transform(aColsRod[nI][nX],'999,999,999,999.99'),18)
					lNumerico := .t.
					cPict := '999,999,999,999,999.99'
					cNPic := 22
					nRecua := 4
				ElseIf aHeader[nX][4] == "@E 999.99"
					@Li,aPos[nX] Psay PADL(Transform(aColsRod[nI][nX],'999.99'),6)
					lNumerico := .t.
					cPict := '999.99'
					cNPic := 6
				ElseIf aHeader[nX][4] == "@E 9,999,999"
					@Li,aPos[nX] Psay PADL(aColsRod[nI][nX],7)
					lNumerico := .t.
					cPict := '999,999,999'
					cNPic := 9
					nRecua := 2
					lTransform := .f.
				Else
					@Li,aPos[nX] Psay SubStr(aColsRod[nI][nX],1,aHeader[nX][7])
				Endif

				If lNumerico
					nTotalPos := aSCAN(aTotais,{|x| x[1] == nX })
					If nTotalPos == 0
						aAdd(aTotais,{nX,cPict,cNPic,aPos[nX]-nRecua,lTransform,aColsRod[nI][nX]})
					Else
						aTotais[nTotalPos][6] += aColsRod[nI][nX]
					Endif
				Endif

			Next
		Next
		If Len(aTotais) > 0
			NgSomaLi(58,.F.)
			NgSomaLi(58,.F.)
			lFirst := .t.
			For nX := 1 To Len(aTotais)
				If ((cTRBMAIN)->DIVISAO == 'OFI' .OR. (cTRBMAIN)->DIVISAO == 'PNE') .AND. aHeader[aTotais[nX][1]][1] == '%'
					If lFirst
						nTotalPai := aTotais[nX-1][6] + aTotais[nX+1][6]
						@Li,aTotais[nX][4] Psay PADL(Transform((aTotais[nX-1][6]/nTotalPai*100),aTotais[nX][2]),aTotais[nX][3])
						lFirst := .f.
					Else
						nTotalPai := aTotais[nX-3][6] + aTotais[nX-1][6]
						@Li,aTotais[nX][4] Psay PADL(Transform((aTotais[nX-1][6]/nTotalPai*100),aTotais[nX][2]),aTotais[nX][3])
					Endif
				Else
					If aTotais[nX][5] //Se utilizara Transform
						@Li,aTotais[nX][4] Psay PADL(Transform(aTotais[nX][6],aTotais[nX][2]),aTotais[nX][3])
					Else
						@Li,aTotais[nX][4] Psay PADL(aTotais[nX][6],aTotais[nX][3])
					Endif
				Endif
			Next
		Endif
		RODA(nCNTIMPR,cRODATXT,TAMANHO)
	Endif

	Set Filter To
	Set Device To Screen
	If aReturn[5] == 1
		Set Printer To
		dbCommitAll()
		OurSpool(WNREL)
	EndIf
	MS_FLUSH()

Return lRet

//--------------------------------------------------------------------------
/*/{Protheus.doc} MNT935Aba
Query que busca os dados de Abastecimentos.
@type function

@author Marcos Wagner Junior
@since 26/04/2011

@param lCarrDados, Lógico, Carrega campos ou não.
@return Lógico, Sempre verdadeiro.
/*/
//--------------------------------------------------------------------------
Static Function MNT935Aba(lCarrDados)

	Local 	cExpData  := "%%"
	Private cAliasQry := ""

	If !Empty(dDtI2) .And. !Empty(dDtF2)
		cExpData := "% AND TQN.TQN_DTABAS >= " + ValToSql( DTOS(dDtI5) )
		cExpData += " AND TQN.TQN_DTABAS <= " + ValToSql( DTOS(dDtF5) ) + "%"
	Endif

	cAliasQry := GetNextAlias()
	BeginSQL Alias cAliasQry
		SELECT TQN.TQN_FROTA, TQN.TQN_FILIAL, TQN.TQN_CCUSTO, TQN.TQN_VALTOT, ST9.T9_CODFAMI,
			   ST9.T9_NOME, ST6.T6_NOME, TQN.TQN_DTABAS, TQN.TQN_HRABAS, CTT.CTT_DESC01
		  FROM %table:TQN% TQN
		  JOIN %table:ST9% ST9 ON TQN.TQN_FROTA = ST9.T9_CODBEM
		   AND ST9.T9_FILIAL = %xFilial:ST9%
		   AND ST9.%notDel%
		  JOIN %table:CTT% CTT ON	ST9.T9_CCUSTO = CTT.CTT_CUSTO
		   AND CTT.CTT_FILIAL = %xFilial:CTT%
		   AND CTT.%notDel%
		  JOIN %table:ST6% ST6 ON	ST9.T9_CODFAMI = ST6.T6_CODFAMI
		   AND ST6.T6_FILIAL = %xFilial:ST6%
		   AND ST6.%notDel%
		 WHERE TQN.TQN_FILIAL = %xFilial:TQN%
		   AND TQN.%notDel%
		   %exp:cExpData%
		 ORDER BY TQN.TQN_DTABAS
	EndSQL

	If !Eof()
		lTemOut := .t.
	Endif

	If !lCarrDados
		(cAliasQry)->(dbCloseArea())
		Return .t.
	Endif

	aSTLouSTT := {'(cAliasQry)->TQN_FROTA','','','(cAliasQry)->TQN_CCUSTO',;
	'','','','',;
	'(cAliasQry)->TQN_FILIAL','','(cAliasQry)->TQN_VALTOT','(cAliasQry)->T9_CODFAMI',;
	'(cAliasQry)->T9_NOME','(cAliasQry)->T6_NOME','','',;
	'','','(cAliasQry)->TQN_DTABAS','',;
	'','','(cAliasQry)->TQN_HRABAS','(cAliasQry)->TQN_FROTA+(cAliasQry)->TQN_DTABAS+(cAliasQry)->TQN_HRABAS',;
	'','','(cAliasQry)->CTT_DESC01','',;
	'','',''}

	ChamaLeft('ABA',"ABASTECIMENTO")

	(cAliasQry)->(dbCloseArea())

Return .t.

//--------------------------------------------------------------------------
/*/{Protheus.doc} MNT935Sin
Query que busca os dados de Sinistros.
@type function

@author Marcos Wagner Junior
@since 26/04/2011

@param lCarrDados, Lógico, Carrega campos ou não.
@return Lógico, Sempre verdadeiro.
/*/
//--------------------------------------------------------------------------
Static Function MNT935Sin(lCarrDados)

	Local 	cExpData  := "%%"
	Local 	cSumTRK	  := "%%"
	Local 	cSumTRO	  := "%%"
	Local 	cSumTRL	  := "%%"
	Local 	cSumTRM	  := "%%"
	Local 	cSumTRV	  := "%%"
	Local 	cSumSTL	  := "%%"

	Private cAliasQry := ""

	If !Empty(dDtI2) .And. !Empty(dDtF2)
		cExpData := "% AND TRH.TRH_DTACID >= " + ValToSql( DTOS(dDtI2) )
		cExpData += " AND TRH.TRH_DTACID <= " + ValToSql( DTOS(dDtF2) ) + "%"
	Endif

	//Verificar o banco de dados
	If AllTrim( TCGetDB() ) == "ORACLE"
		cSumTRK := "%SELECT NVL( SUM(TRK.TRK_VALAVA - TRK.TRK_VALREC),0 )%"
		cSumTRO := "%SELECT NVL( SUM(TRO.TRO_VALPRE),0 )%"
		cSumTRL := "%SELECT NVL( SUM(TRL.TRL_VALPRE),0 )%"
		cSumTU4 := '%SELECT NVL( SUM( TU4.TU4_VALANI * TU4.TU4_QTDANI ), 0 )%'
		cSumTRM := "%SELECT NVL( SUM(TRM.TRM_VALVIT),0 )%"
		cSumTRV := "%SELECT NVL( SUM(TRV.TRV_VALRES),0 )%"
		cSumSTL := "%SELECT NVL( SUM(STL.TL_CUSTO),0 )%"
	Else
		cSumTRK := "%SELECT ISNULL( SUM(TRK.TRK_VALAVA - TRK.TRK_VALREC),0 )%"
		cSumTRO := "%SELECT ISNULL( SUM(TRO.TRO_VALPRE),0 )%"
		cSumTRL := "%SELECT ISNULL( SUM(TRL.TRL_VALPRE),0 )%"
		cSumTU4 := '%SELECT ISNULL( SUM( TU4.TU4_VALANI * TU4.TU4_QTDANI ), 0 )%'
		cSumTRM := "%SELECT ISNULL( SUM(TRM.TRM_VALVIT),0 )%"
		cSumTRV := "%SELECT ISNULL( SUM(TRV.TRV_VALRES),0 )%"
		cSumSTL := "%SELECT ISNULL( SUM(STL.TL_CUSTO),0 )%"
	Endif

	cAliasQry := GetNextAlias()
	BeginSQL Alias cAliasQry
		SELECT TRH.TRH_FILIAL, TRH.TRH_NUMSIN, TRH.TRH_VALGUI, TRH.TRH_VALDAN, ST9.T9_CODFAMI, ST9.T9_NOME,
			TRH.TRH_CODBEM, ST6.T6_NOME, ST9.T9_CCUSTO, TRH.TRH_DTACID, TRH.TRH_HRACID, CTT.CTT_DESC01,
			( ( %exp:cSumTRK%
					FROM %table:TRK% TRK
						WHERE TRH.TRH_NUMSIN = TRK.TRK_NUMSIN AND
							TRH.TRH_FILIAL = %xFilial:TRH% AND
							TRH.%notDel% ) +
							( %exp:cSumTRO%
								FROM %table:TRO% TRO   WHERE TRH.TRH_NUMSIN = TRO.TRO_NUMSIN AND
								TRO.TRO_FILIAL = %xFilial:TRO% AND
								TRO.%notDel% ) +
							( %exp:cSumTRL%
								FROM %table:TRL% TRL WHERE TRH.TRH_NUMSIN = TRL.TRL_NUMSIN AND
								TRL.TRL_FILIAL = %xFilial:TRL% AND
								TRL.%notDel% ) +
							( %exp:cSumTU4%
								FROM %table:TU4% TU4 WHERE TRH.TRH_NUMSIN = TU4.TU4_NUMSIN AND
								TU4.TU4_FILIAL = %xFilial:TU4% AND
								TU4.%notDel% ) +
							( %exp:cSumTRM%
								FROM %table:TRM% TRM WHERE TRH.TRH_NUMSIN = TRM.TRM_NUMSIN AND
								TRM.TRM_FILIAL = %xFilial:TRM% AND
								TRM.%notDel% ) -
							( %exp:cSumTRV%
								FROM %table:TRV% TRV WHERE TRH.TRH_NUMSIN = TRV.TRV_NUMSIN AND
								TRV.TRV_FILIAL = %xFilial:TRV% AND
								TRV.%notDel% ) +
							( %exp:cSumSTL%
								FROM %table:STL% STL , %table:STJ% STJ
								WHERE STL.TL_ORDEM = STJ.TJ_ORDEM AND STL.TL_PLANO = STJ.TJ_PLANO AND
								STL.TL_FILIAL = STJ.TJ_FILIAL AND STJ.TJ_ORDEM =
							( SELECT TRT.TRT_NUMOS FROM %table:TRT% TRT WHERE TRT.TRT_NUMSIN = TRH.TRH_NUMSIN AND
								TRT.%notDel% AND TRT.TRT_FILIAL = %xFilial:TRT% )  AND STJ.TJ_PLANO =
								( SELECT TRT.TRT_PLANO  FROM %table:TRT% TRT
									WHERE TRT.TRT_NUMSIN = TRH.TRH_NUMSIN AND
									TRT.%notDel%  )  AND STL.%notDel% ) ) SUMTOTAL
							FROM %table:TRH% TRH
								JOIN %table:ST9% ST9 ON TRH.TRH_CODBEM = ST9.T9_CODBEM AND
									ST9.T9_FILIAL = %xFilial:ST9% AND
									ST9.%notDel%
								LEFT JOIN %table:ST6% ST6 ON ST9.T9_CODFAMI = ST6.T6_CODFAMI AND
									ST6.T6_FILIAL = %xFilial:ST6% AND
									ST6.%notDel%
								LEFT JOIN %table:CTT% CTT ON ST9.T9_CCUSTO = CTT.CTT_CUSTO AND
									CTT.CTT_FILIAL = %xFilial:CTT% AND
									CTT.%notDel%
								WHERE TRH.%notDel%
									%exp:cExpData%
			EndSQL

	If ( cAliasQry )->( !EoF() )
		lTemOut := .T.
	EndIf

	If !lCarrDados
		(cAliasQry)->(dbCloseArea())
		Return .t.
	Endif

	aSTLouSTT := {'(cAliasQry)->TRH_CODBEM','','','(cAliasQry)->T9_CCUSTO',;
	'','','','',;
	'(cAliasQry)->TRH_FILIAL','',;
	'(cAliasQry)->TRH_VALGUI+(cAliasQry)->TRH_VALDAN+(cAliasQry)->SUMTOTAL',;
	'(cAliasQry)->T9_CODFAMI','(cAliasQry)->T9_NOME','(cAliasQry)->T6_NOME','','',;
	'','','(cAliasQry)->TRH_DTACID','',;
	'','','(cAliasQry)->TRH_HRACID','(cAliasQry)->TRH_NUMSIN',;
	'','','(cAliasQry)->CTT_DESC01','',;
	'','',''}

	ChamaLeft('SIN',"SINISTRO")

	(cAliasQry)->(dbCloseArea())

Return .t.

//--------------------------------------------------------------------------
/*/{Protheus.doc} MNT935Mul
Query que busca os dados de Multas.
@type function

@author Marcos Wagner Junior
@since 26/04/2011

@param lCarrDados, Lógico, Carrega campos ou não.
@return Lógico, Sempre verdadeiro.
/*/
//--------------------------------------------------------------------------
Static Function MNT935Mul(lCarrDados)

	Local lST9 := .F.
	Local lST6 := .F.
	Local lCTT := .F.
	Local nX, nTRX := 0, nAllTRX := 0, nCustoTRX := 0, nAllCustoTRX := 0
	Local cExpData  := "%%"
	Private cAliasQry := ""

	If !Empty(dDtI2) .And. !Empty(dDtF2)
		cExpData := "% AND TRX.TRX_DTVECI >= " + ValToSql( DTOS(dDtI3) )
		cExpData += " AND TRX.TRX_DTVECI <= " + ValToSql( DTOS(dDtF3) ) + "%"
	Endif

	cAliasQry := GetNextAlias()
	BeginSQL Alias cAliasQry
		SELECT SUM( TRX.TRX_VALPAG ) AS TOT,
				COUNT( TRX.TRX_VALPAG ) AS QTD
					FROM %table:TRX% TRX
					WHERE  TRX.TRX_FILIAL = %xFilial:TRX% AND
			   			TRX.%notDel%
			   			%exp:cExpData%
	EndSQL

	nAllTRX 	 := (cAliasQry)->QTD
	nAllCustoTRX := (cAliasQry)->TOT

	(cAliasQry)->(dbCloseArea())

	lST9 := aSCAN(aBoxDir,{|x| x[2] = '07' }) <> 0
	lST6 := aSCAN(aBoxDir,{|x| x[2] = '06' }) <> 0
	lCTT := aSCAN(aBoxDir,{|x| x[2] = '10' }) <> 0

	cAliasQry := GetNextAlias()
	BeginSQL Alias cAliasQry
		SELECT TRX.TRX_FILIAL, TRX.TRX_VALPAG, TRX.TRX_CODBEM, TRX.TRX_DTVECI, TRX.TRX_RHINFR,
				TRX.TRX_MULTA, TRX.TRX_TPMULT, TRX.TRX_CCUSTO,TRX.TRX_VALOR,ST6.T6_NOME,
				ST9.T9_NOME, ST9.T9_CODFAMI, CTT.CTT_DESC01
				FROM %table:TRX% TRX
			JOIN %table:ST9% ST9 ON TRX.TRX_CODBEM = ST9.T9_CODBEM AND
				ST9.T9_FILIAL = %xFilial:ST9% AND
				ST9.%notDel%
			JOIN %table:ST6% ST6 ON ST9.T9_CODFAMI = ST6.T6_CODFAMI AND
				ST6.T6_FILIAL = %xFilial:ST6% AND
				ST6.%notDel%
			JOIN %table:CTT% CTT ON TRX.TRX_CCUSTO = CTT.CTT_CUSTO AND
				CTT.CTT_FILIAL = %xFilial:CTT% AND
				CTT.%notDel%
		WHERE TRX.TRX_FILIAL = %xFilial:TRX% AND
				TRX.%notDel%
				%exp:cExpData%
	EndSQL

	While (cAliasQry)->(!Eof())
		nTRX++
		nCustoTRX += (cAliasQry)->TRX_VALPAG
		(cAliasQry)->(dbSkip())
	EndDo

	If nX == 2 .And. !lCarrDados
		oBtnTRX:lVisible := .F.
		If (nAllTRX != nTRX)
			oBtnTRX:lVisible := .T.
			oBtnTRX:bAction := {|| MsgInfo(;
			STR0128+MV_SIMB1+" "+AllTrim(cValToChar(Transform(nAllCustoTRX-nCustoTRX,PesqPict("TRX","TRX_VALPAG"))))+;  //"Foi contabilizado o valor de "
			STR0129+cValToChar(nAllTRX-nTRX)+STR0130,STR0054)}  //" vinculado a "##" multa(s) sem relacionamento com nenhum centro de custo ou veículo da empresa."##"Multas"
		EndIf
	EndIf

	dbGoTop()
	If !Eof()
		lTemOut := .t.
	Endif

	If !lCarrDados
		(cAliasQry)->(dbCloseArea())
		Return .t.
	Endif

	aSTLouSTT := {'(cAliasQry)->TRX_CODBEM','','','(cAliasQry)->TRX_CCUSTO',;
	'','','','',;
	'(cAliasQry)->TRX_FILIAL','(cAliasQry)->TRX_VALOR','(cAliasQry)->TRX_VALPAG','(cAliasQry)->T9_CODFAMI',;
	'(cAliasQry)->T9_NOME','(cAliasQry)->T6_NOME','','',;
	'','','(cAliasQry)->TRX_DTVECI','',;
	'','','(cAliasQry)->TRX_RHINFR','(cAliasQry)->TRX_MULTA+(cAliasQry)->TRX_TPMULT',;
	'','','(cAliasQry)->CTT_DESC01','',;
	'','',''}

	ChamaLeft('MUL',"MULTA")

	(cAliasQry)->(dbCloseArea())

Return .t.

//--------------------------------------------------------------------------
/*/{Protheus.doc} MNT935Doc
Query que busca os dados de Documentos.
@type function

@author Marcos Wagner Junior
@since 26/04/2011

@param lCarrDados, Lógico, Carrega campos ou não.
@return Lógico, Sempre verdadeiro.
/*/
//--------------------------------------------------------------------------
Static Function MNT935Doc(lCarrDados)

	Local 	cExpData  := "%%"
	Private cAliasQry := ""

	If !Empty(dDtI4) .AND. !Empty(dDtF4)
		cExpData := "% AND TS1.TS1_DTVENC >= " + ValToSql( DTOS(dDtI4) )
		cExpData += " AND TS1.TS1_DTVENC <= " + ValToSql( DTOS(dDtF4) ) + "%"
	Endif

	cAliasQry := GetNextAlias()
	BeginSQL Alias cAliasQry
		SELECT TS1.TS1_FILIAL, ST6.T6_NOME, ST9.T9_NOME, ST9.T9_CODFAMI, ST9.T9_CCUSTO, TS1.TS1_VALOR, TS1.TS1_CODBEM,
			TS1.TS1_DTVENC, TS1.TS1_QTDPAR, TS1.TS1_DOCTO, TS0.TS0_NOMDOC, CTT.CTT_DESC01, TS1.TS1_VALPAG
			FROM %table:TS1% TS1
				JOIN %table:TS0% TS0 ON TS1.TS1_DOCTO = TS0.TS0_DOCTO AND
								 TS0.TS0_FILIAL = %xFilial:TS0% AND
								 TS0.%notDel%
				JOIN %table:ST9% ST9 ON TS1.TS1_CODBEM = ST9.T9_CODBEM AND
								 ST9.T9_FILIAL = %xFilial:ST9% AND
								 ST9.%notDel%
				JOIN %table:ST6% ST6 ON	ST9.T9_CODFAMI = ST6.T6_CODFAMI AND
								 ST6.T6_FILIAL = %xFilial:ST6% AND
								 ST6.%notDel%
				JOIN %table:CTT% CTT ON	ST9.T9_CCUSTO = CTT.CTT_CUSTO  AND
								 CTT.CTT_FILIAL = %xFilial:CTT% AND
								 CTT.%notDel%
		WHERE 	TS1.TS1_FILIAL = %xFilial:TS1% AND
				TS1.%notDel%
				%exp:cExpData%
	EndSQL

	If !Eof()
		lTemOut := .t.
	Endif

	If !lCarrDados
		(cAliasQry)->(dbCloseArea())
		Return .t.
	Endif

	aSTLouSTT := {'(cAliasQry)->TS1_CODBEM','','','(cAliasQry)->T9_CCUSTO',;
	'','','','',;
	'(cAliasQry)->TS1_FILIAL','(cAliasQry)->TS1_VALOR','(cAliasQry)->TS1_VALPAG','(cAliasQry)->T9_CODFAMI',;
	'(cAliasQry)->T9_NOME','(cAliasQry)->T6_NOME','','',;
	'','','(cAliasQry)->TS1_DTVENC','(cAliasQry)->TS1_QTDPAR',;
	'(cAliasQry)->TS1_DOCTO','(cAliasQry)->TS0_NOMDOC','','(cAliasQry)->TS1_CODBEM+(cAliasQry)->TS1_DOCTO+(cAliasQry)->TS1_DTVENC',;
	'','','(cAliasQry)->CTT_DESC01','',;
	'','',''}
	ChamaLeft('DOC',"DOCUMENTO")

	(cAliasQry)->(dbCloseArea())

Return .t.

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Metodo    ³  MNC935PAR  ³Autor³ Marcos Wagner Junior ³ Data ³12/05/2011³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Define a ordem a ser seguida na arvore                     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ MNTC935                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Static Function MNC935PAR()

	If !MNC935TOK()
		Return .f.
	Endif

Return .t.

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Metodo    ³  MNC935TOK  ³Autor³ Marcos Wagner Junior ³ Data ³12/05/2011³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Valida se a ordem dos niveis esta correta                  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ MNTC935                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Static Function MNC935TOK()

	If Empty(aBoxDir[oBoxDir:nAt,1])
		MsgInfo(STR0057,STR0033) //"Pelo menos um nível deverá ser informado."###"ATENÇÃO"
		Return .f.
	Endif

Return .t.

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Metodo    ³  MNC935ESQ  ³Autor³ Marcos Wagner Junior ³ Data ³12/05/2011³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Joga da esquerda pra direita                               ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ MNTC935                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Static Function MNC935ESQ()
	Local nI

	If !Empty(aBoxDir[1][1])
		For nI := 1 to Len(aBoxDir)
			nPos := aSCAN(aNaoPode,{|x| x[1]+x[2] = aBoxEsq[oBoxEsq:nAt][2]+aBoxDir[nI][2]})
			If nPos > 0
				MsgInfo(STR0058+" '" + aBoxEsq[oBoxEsq:nAt][1] + "' "+STR0059+" '"+aNaoPode[nPos][3],STR0033) //"O nível"###"não poderá ficar abaixo do nível"##"ATENÇÃO"
				Return .f.
			Endif
		Next
	Endif

	If Empty(aBoxDir[1][1])
		aBoxDir := {}
	Endif
	aAdd( aBoxDir,aBoxEsq[oBoxEsq:nAt])
	oBoxDir:SetArray( aBoxDir )
	oBoxDir:bLine:= bBoxDir

	aDel( aBoxEsq,oBoxEsq:nAt)
	aSize( aBoxEsq, Len( aBoxEsq )-1)
	If Len( aBoxEsq ) > 0
		oBoxEsq:SetArray( aBoxEsq )
		oBoxEsq:bLine:= bBoxEsq
	Else
		aAdd( aBoxEsq , {"","",0,""} )
		oBoxEsq:bLine:= bBoxEsq
	Endif

Return .t.

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Metodo    ³  MNC935DIR  ³Autor³ Marcos Wagner Junior ³ Data ³12/05/2011³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Joga da direita pra esquerda                               ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ MNTC935                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Static Function MNC935DIR()

	If Empty(aBoxEsq[1][1])
		aBoxEsq := {}
	Endif
	aAdd( aBoxEsq,aBoxDir[oBoxDir:nAt])
	oBoxEsq:SetArray( aBoxEsq )
	oBoxEsq:bLine:= bBoxEsq

	aDel( aBoxDir,oBoxDir:nAt)
	aSize( aBoxDir, Len( aBoxDir )-1)
	If Len( aBoxDir ) > 0
		oBoxDir:SetArray( aBoxDir )
		oBoxDir:bLine:= bBoxDir
	Else
		aAdd( aBoxDir , {"","",0,"",""} )
		oBoxDir:bLine:= bBoxDir
	Endif

Return .t.

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Metodo    ³ MNTC935SX1  ³Autor³ Marcos Wagner Junior ³ Data ³12/05/2011³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Cria SX1 e alimenta os listbox                             ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ MNTC935                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Static Function MNTC935SX1()

	If lGFrota
		aAdd( aBoxEsq , { STR0062, "01", 3,'cDIVISAO'  ,'DIV'}) //"Componente de Custo"
	EndIf
	aAdd( aBoxEsq , { STR0004, "03", Len(STJ->TJ_CODAREA) ,'cTJCODAREA','STD'}) //"Área"
	aAdd( aBoxEsq , { STR0063, "04", Len(STJ->TJ_TIPO)    ,'cTJTIPO'   ,'STE'}) //"Tipo MNT"
	aAdd( aBoxEsq , { STR0006, "05", Len(STJ->TJ_SERVICO) ,'cTJSERVICO','ST4'}) //"Serviço"
	aAdd( aBoxEsq , { STR0007, "06", Len(ST9->T9_CODFAMI) ,'cT9CODFAMI','ST6'}) //"Família"
	aAdd( aBoxEsq , { STR0008, "07", Len(STJ->TJ_CODBEM)  ,'cT9CODBEM' ,'ST9'}) //"Bem"
	aAdd( aBoxEsq , { STR0064, "09", Len(ST5->T5_DESCRIC) ,'cT5TAREFA' ,'ST5'}) //"Tarefa"
	aAdd( aBoxEsq , { STR0065, "10", Len(ST9->T9_CCUSTO)  ,'cT9CCUSTO' ,'CTT'}) //"Centro De Custo"
	aAdd( aBoxEsq , { STR0066, "11", Len(STL->TL_TIPOREG) ,'cTIPOINSUM','TIN'}) //"Tipo de Insumo"

	If lGFrota
		aAdd(aNaoPode,{"01","03",STR0004})//"Componente de Custo" ### "Área" //"Área"
		aAdd(aNaoPode,{"01","04",STR0063})//"Componente de Custo" ### "Tipo MNT" //"Tipo MNT"
		aAdd(aNaoPode,{"01","05",STR0006})//"Componente de Custo" ### "Serviço" //"Serviço"
		aAdd(aNaoPode,{"01","09",STR0064})//"Componente de Custo" ### "Tarefa" //"Tarefa"
		aAdd(aNaoPode,{"01","11",STR0066})//"Componente de Custo" ### "Tipo de Insumo" //"Tipo de Insumo"
	EndIf
	aAdd(aNaoPode,{"06","07",STR0008})//"Família"  ### "Bem" //"Bem"

	If Empty(aBoxDir)
		aAdd( aBoxDir , {"","",0,"",""} )
	EndIf

Return Nil

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Metodo    ³ MNTC935SX1  ³Autor³ Marcos Wagner Junior ³ Data ³12/05/2011³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Chama a funcao para alimentar a arvore                     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ MNTC935                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Static Function ChamaLeft(cDiv,cDesDiv)
	Local nI, nAdd := 0
	Private lAdicionou := .f.

	cChavePai := ''
	lNivel1 := .t.

	If aSCAN(aBoxDir,{|x| x[2] = '01' }) == 0
		MNC935ARR()
	Else
		nPosFrota := 1
	Endif

	If nPosFrota == 0 //Senao tiver nenhum nivel de Frota (Filial, Bem, Familia, Componente de Custo), nao mostra
		lMsgLeft := .T.
		Return .t.
	Endif

	If cDiv == 'DOC'
		lAdicionou := .t.
		aAdd( aBoxDir , { STR0067, "08", 6, 'cDOCUMENTO', 'TS1'} ) //"Documento"
		nAdd++
	ElseIf cDiv == 'ABA'
		lAdicionou := .t.
		aAdd( aBoxDir , { STR0068, "08", 7,'cMESANO', 'MEA'} ) //"Mes/Ano"
		nAdd++
		aAdd( aBoxDir , { STR0069, "08", 13,'dDATATAB+cHORATAB', 'TQN'} ) //"Abastecimento"
		nAdd++
	ElseIf cDiv == 'SIN'
		lAdicionou := .t.
		aAdd( aBoxDir , { STR0070, "08", 13,'dDATATAB+cHORATAB', 'TRH'} ) //"Sinistro"
		nAdd++
	ElseIf cDiv == 'MUL'
		lAdicionou := .t.
		aAdd( aBoxDir , { STR0071, "08", 13,'dDATATAB+cHORATAB', 'TRX'} ) //"Multa"
		nAdd++
	Endif

	For nI := 1 to Len(aBoxDir)
		If aBoxDir[nI][2] $ ('01/06/07/08/10')
			IncProc()
			MontaTree(nI,lNivel1,cDiv,cDesDiv,aBoxDir[nI][5])
			lNivel1 := .f.
		Endif
	Next

	If lAdicionou
		If nDiv <> 0
			aDel( aBoxDir,nDiv)
			aSize( aBoxDir, Len( aBoxDir )-1)
		Endif

		For nI := 1 to nAdd
			aDel( aBoxDir,Len(aBoxDir))
		Next
		aSize( aBoxDir, Len( aBoxDir )-nAdd)
	Endif

Return .t.

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Metodo    ³  MNC935ARR  ³Autor³ Marcos Wagner Junior ³ Data ³26/04/2011³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³                                                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ MNTC935                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Static Function MNC935ARR()
	Local nI
	nPosFrota := 0
	nPosPadrao := 0
	nDiv := 0

	If !lGFrota
		Return .t.
	Endif

	If aSCAN(aBoxDir,{|x| x[2] = '01' }) == 0
		nPosFrota := aSCAN(aBoxDir,{|x| x[2] $ '06/07' })
		For nI := 1 to Len(aBoxDir)
			nPosPadrao := aSCAN(aBoxDir,{|x| !x[2] $ '06/07' })
			If nPosPadrao <> 0
				Exit
			Endif
		Next

		If nPosPadrao <> 0 .AND. nPosFrota <> 0
			nDiv := IIF(nPosPadrao < nPosFrota,nPosPadrao,nPosFrota+1)
		ElseIf nPosPadrao == 0
			//		Return .t.
		ElseIf nPosFrota  == 0
			Return .t.
		Endif

		If nDiv == 0
			nDiv := Len(aBoxDir)+1
		Endif

		lAdicionou := .t.
		aSize( aBoxDir, Len( aBoxDir )+1)
		aIns(aBoxDir,nDiv)

		aBoxDir[nDiv] := {,,,,}
		aBoxDir[nDiv][1] := STR0062 //"Componente de Custo"
		aBoxDir[nDiv][2] := "01"
		aBoxDir[nDiv][3] := 3
		aBoxDir[nDiv][4] := 'cDIVISAO'
		aBoxDir[nDiv][5] := 'DIV'
	Endif

Return .t.

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Metodo    ³  MNC935NIV  ³Autor³ Marcos Wagner Junior ³ Data ³26/04/2011³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Retorna a descricao do nivel                               ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ MNTC935                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Static Function MNC935NIV(_cTabela)
	Local cDescNivel := ""

	If _cTabela == 'DIV'
		cDescNivel := STR0062 //"Componente de Custo"
	ElseIf _cTabela == 'ST9'
		cDescNivel := STR0008 //"Bem"
	ElseIf _cTabela == 'ST6'
		cDescNivel := STR0007 //"Família"
	ElseIf _cTabela == 'TRX'
		cDescNivel := STR0054 //"Multas"
	ElseIf _cTabela == 'TS1'
		cDescNivel := STR0055 //"Documentos"
	ElseIf _cTabela == 'TRH'
		cDescNivel := STR0053 //"Sinistros"
	ElseIf _cTabela == 'TQN'
		cDescNivel := STR0051 //"Abastecimentos"
	ElseIf _cTabela == 'MEA'
		cDescNivel := STR0072 //"Período"
	ElseIf _cTabela == 'CTT'
		cDescNivel := STR0073 //"Centros de Custo"
	ElseIf _cTabela == 'ST5'
		cDescNivel := STR0064 //"Tarefa"
	ElseIf _cTabela == 'TIN'
		cDescNivel := STR0066 //"Tipo de Insumo"
	Else
		If _cTabela == 'SM0'
			cDescNivel := STR0074 //"Empresa"
		ElseIf _cTabela == 'STD'
			cDescNivel := STR0004 //"Área"
		ElseIf _cTabela == 'STE'
			cDescNivel := STR0005 //"Tipo"
		ElseIf _cTabela == 'ST4'
			cDescNivel := STR0006 //"Serviço"
		ElseIf _cTabela == 'STJ'
			cDescNivel := STR0075 //"Ordem de Serviço"
		EndIf
	Endif

Return cDescNivel

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Metodo    ³ ShowLegend  ³Autor³ Marcos Wagner Junior ³ Data ³28/06/2011³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Monta a tela de legenda                                    ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ MNTC935                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Static Function ShowLegend()
	Local oDlgLegend
	Local nSumX := 0

	Define MsDialog oDlgLegend From 06,6 To If(lGFrota,508,278),475 Title OemToAnsi(STR0018) Pixel //"Legenda"

	oGrpGeral := TGroup():New( 002,005,042,230,STR0076,oDlgLegend,CLR_BLACK,CLR_WHITE,.T.,.F. ) //"Geral:"
	@ 010,010 Bitmap oLgnd1 Resource "Folder10" Size 25,25 Pixel Of oGrpGeral Noborder When .F.
	@ 013,030 Say OemToAnsi(STR0003) Of oGrpGeral Pixel	 //"Filial"
	@ 010,120 Bitmap oLgnd1 Resource 'NG_ICO_FAMILIA' Size 25,25 Pixel Of oGrpGeral Noborder When .F.
	@ 013,140 Say OemToAnsi(STR0007) Of oGrpGeral Pixel	 //"Família"
	@ 024,010 Bitmap oLgnd1 Resource 'ENGRENAGEM' Size 25,25 Pixel Of oGrpGeral Noborder When .F.
	@ 027,030 Say OemToAnsi(STR0008) Of oGrpGeral Pixel //"Bem"
	@ 026,120 Bitmap oLgnd1 Resource 'NG_ICO_CCUSTO' Size 25,25 Pixel Of oGrpGeral Noborder When .F.
	@ 028,140 Say OemToAnsi(STR0065) Of oGrpGeral Pixel	 //"Centro de Custo"

	oGrpOficin := TGroup():New( 043,005,If(lGFrota,139,125),230,STR0045+":",oDlgLegend,CLR_BLACK,CLR_WHITE,.T.,.F. )  //"Oficina"
	If lGFrota
		@ 051,010 Bitmap oLgnd1 Resource 'NG_ICO_OFICINA' Size 25,25 Pixel Of oGrpOficin Noborder When .F.
		@ 054,030 Say OemToAnsi(STR0077) Of oGrpOficin Pixel //"Grupo Oficina"
		@ 051,120 Bitmap oLgnd1 Resource 'NG_ICO_PNEU1' Size 25,25 Pixel Of oGrpOficin Noborder When .F.
		@ 054,140 Say OemToAnsi(STR0078) Of oGrpOficin Pixel //"Grupo Pneus"
		nSumX := 14
	EndIf
	@ 051+nSumX,010 Bitmap oLgnd1 Resource 'NG_ICO_AREAMNT' Size 25,25 Pixel Of oGrpOficin Noborder When .F.
	@ 054+nSumX,030 Say OemToAnsi(STR0079) Of oGrpOficin Pixel //"Área Mnt"
	@ 051+nSumX,120 Bitmap oLgnd1 Resource 'NG_ICO_TIPOSERVICO' Size 25,25 Pixel Of oGrpOficin Noborder When .F.
	@ 054+nSumX,140 Say OemToAnsi(STR0063) Of oGrpOficin Pixel //"Tipo Mnt"
	@ 065+nSumX,010 Bitmap oLgnd1 Resource 'NG_ICO_IOSCOM' Size 25,25 Pixel Of oGrpOficin Noborder When .F.
	@ 068+nSumX,030 Say OemToAnsi(STR0011) Of oGrpOficin Pixel //"Corretiva"
	@ 065+nSumX,120 Bitmap oLgnd1 Resource 'NG_ICO_IOSPRM' Size 25,25 Pixel Of oGrpOficin Noborder When .F.
	@ 068+nSumX,140 Say OemToAnsi(STR0010) Of oGrpOficin Pixel //"Preventiva"
	@ 079+nSumX,010 Bitmap oLgnd1 Resource 'NG_ICO_TAREFA' Size 25,25 Pixel Of oGrpOficin Noborder When .F.
	@ 082+nSumX,030 Say OemToAnsi(STR0064) Of oGrpOficin Pixel //"Tarefa"
	@ 079+nSumX,120 Bitmap oLgnd1 Resource 'NG_TREE_ESPECIALIDADE01' Size 25,25 Pixel Of oGrpOficin Noborder When .F.
	@ 082+nSumX,140 Say OemToAnsi(STR0036) Of oGrpOficin Pixel //82 85     101 127       109 112 //"Especialidade"
	@ 093+nSumX,010 Bitmap oLgnd1 Resource 'NG_TREE_FERRAMENTA01' Size 25,25 Pixel Of oGrpOficin Noborder When .F.
	@ 096+nSumX,030 Say OemToAnsi(STR0049) Of oGrpOficin Pixel //"Ferramenta"
	@ 093+nSumX,120 Bitmap oLgnd1 Resource 'NG_TREE_PRODUTO01' Size 25,25 Pixel Of oGrpOficin Noborder When .F.
	@ 096+nSumX,140 Say OemToAnsi(STR0038) Of oGrpOficin Pixel //82 85     101 127       109 112 //"Produto"
	@ 107+nSumX,010 Bitmap oLgnd1 Resource 'NG_TREE_FUNCIONARIO01' Size 25,25 Pixel Of oGrpOficin Noborder When .F.
	@ 110+nSumX,030 Say OemToAnsi(STR0080) Of oGrpOficin Pixel //"Funcionário"
	@ 107+nSumX,120 Bitmap oLgnd1 Resource 'NG_TREE_TERCEIROS01' Size 25,25 Pixel Of oGrpOficin Noborder When .F.
	@ 110+nSumX,140 Say OemToAnsi(STR0081) Of oGrpOficin Pixel //82 85     101 127       109 112 //"Terceiros"

	If lGFrota
		oGrpAbaste := TGroup():New( 140,005,166,230,STR0069+":",oDlgLegend,CLR_BLACK,CLR_WHITE,.T.,.F. )  //"Abastecimento"
		@ 148,010 Bitmap oLgnd1 Resource 'NG_ICO_ABAST1' Size 25,25 Pixel Of oGrpAbaste Noborder When .F.
		@ 151,030 Say OemToAnsi(STR0082) Of oGrpAbaste Pixel //"Grupo"
		@ 148,120 Bitmap oLgnd1 Resource 'NG_ICO_ABASTDET' Size 25,25 Pixel Of oGrpAbaste Noborder When .F.
		@ 151,140 Say OemToAnsi(STR0083) Of oGrpAbaste Pixel //"Mês/Ano"

		oGrpSinist := TGroup():New( 167,005,193,230,STR0070+":",oDlgLegend,CLR_BLACK,CLR_WHITE,.T.,.F. )  //"Sinistro"
		@ 175,010 Bitmap oLgnd1 Resource 'NG_ICO_SINISTRO2' Size 25,25 Pixel Of oGrpSinist Noborder When .F.
		@ 178,030 Say OemToAnsi(STR0082) Of oGrpSinist Pixel //"Grupo"
		@ 175,120 Bitmap oLgnd1 Resource 'NG_ICO_SINISTRODET' Size 25,25 Pixel Of oGrpSinist Noborder When .F.
		@ 178,140 Say OemToAnsi(STR0084) Of oGrpSinist Pixel //"Detalhe"

		oGrpMulta  := TGroup():New( 194,005,220,230,STR0071+":",oDlgLegend,CLR_BLACK,CLR_WHITE,.T.,.F. )  //"Multa"
		@ 202,010 Bitmap oLgnd1 Resource 'NG_ICO_MULTAS2' Size 25,25 Pixel Of oGrpMulta Noborder When .F.
		@ 205,030 Say OemToAnsi(STR0082) Of oGrpMulta Pixel //"Grupo"
		@ 202,120 Bitmap oLgnd1 Resource 'NG_ICO_MULTASDET' Size 25,25 Pixel Of oGrpMulta Noborder When .F.
		@ 205,140 Say OemToAnsi(STR0084) Of oGrpMulta Pixel //"Detalhe"

		oGrpDocume := TGroup():New( 221,005,247,230,STR0067+":",oDlgLegend,CLR_BLACK,CLR_WHITE,.T.,.F. )  //"Documento"
		@ 229,010 Bitmap oLgnd1 Resource 'NG_ICO_DOC2' Size 25,25 Pixel Of oGrpDocume Noborder When .F.
		@ 232,030 Say OemToAnsi(STR0082) Of oGrpDocume Pixel //"Grupo"
		@ 229,120 Bitmap oLgnd1 Resource 'NG_ICO_DOCDET' Size 25,25 Pixel Of oGrpDocume Noborder When .F.
		@ 232,140 Say OemToAnsi(STR0084) Of oGrpDocume Pixel //"Detalhe"
	Endif

	Activate MsDialog oDlgLegend Centered

Return .t.

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Metodo    ³ TelaParame  ³Autor³ Marcos Wagner Junior ³ Data ³16/09/2011³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Monta a tela de legenda                                    ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ MNTC935                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Static Function TelaParame()

	Local nPadrao    := If( lGFrota, 0, 76 )
	Local oSituation
	Local oGet

	Private lTemOS   := .F.
	Private lTemOut  := .F.

	Define MsDialog oDlgParame From 0,0 To 636-(nPadrao*2),760 Title OemToAnsi(STR0001+" - "+STR0044) Pixel //"Gerencial de Custos"###"Parâmetros"

	oScroll := TScrollArea():New(oDlgParame,01,01,100,100)
	oScroll:Align := CONTROL_ALIGN_ALLCLIENT

	oPanelPara := TPanel():New(01,01,,oDlgParame,,,,,,100,100,.T.,.T.)
	oPanelPara:Align := CONTROL_ALIGN_ALLCLIENT

	oScroll:SetFrame( oPanelPara )

	//Primeiro Folder 		  Era:002,005,097,377
	oGroupApre   := TGroup():New( 002,005,102,377,STR0045+":",oPanelPara,CLR_BLACK,CLR_WHITE,.T.,.F. ) //"Oficina"

	@ 011,010 Say Oemtoansi(STR0085+":") Of oGroupApre Pixel //"Tipo de Manutenção"
	@ 009,063 Combobox oEmQue Var cEmQue Items aEmQue Size 60,10 Of oGroupApre Pixel VALID NaoVazio(cEmQue) When lFolder1
	oEmQue:bHelp := { || ShowHelpCpo(NoAcento(AnsiToOem(STR0085+":")), ; //"Tipo de Manutenção"
	{STR0086},2)} //"Indica o tipo de ordens de serviço para visualização na consulta gerencial."

	@ 011,130 Say STR0132 Of oGroupApre Pixel // Considerar O.S.:
	@ 009,173 Combobox oSituation Var cStatus Items aStatus Size 60,10 Of oGroupApre Pixel VALID NaoVazio( cStatus ) When lFolder1

	// Considerar O.S.: ## Indica qual a situação da ordem de serviço considerada para visualização na consulta gerencial.
	oSituation:bHelp := { || ShowHelpCpo( ( OemToAnsi( STR0132 ) ), { STR0138 }, 2 ) }

	//Deixar invisivel, utilizada para setar o foco apenas.
	@ 017,005 CheckBox oInvisivel Var lFerrament Prompt OemToAnsi(STR0049) Size 102,10 of oGroupApre Pixel //"Ferramenta"
	oInvisivel:lVisible := .F.

	If lGFrota
		@ 028,010 CheckBox oFolder1 Var lFolder1 Prompt OemToAnsi(STR0046) On Change MNChange('1') Size 102,10 of oGroupApre Pixel //"Listar dados"
	Else
		@ 030,019 Say Oemtoansi(STR0046) Of oGroupApre Pixel //"Listar dados"
		lFolder1 := .T.
	EndIf
	@ 029,071 Say Oemtoansi(STR0118+":") Of oGroupApre Pixel //"De"
	@ 028,083 MsGet oGet Var dDtI1 Of oGroupApre Valid MNC935DT(1,'1') Picture '99/99/9999' Size 44,08 HASBUTTON Pixel When lFolder1
	oGet:bHelp := { || ShowHelpCpo(NoAcento(AnsiToOem(STR0118+":")), ; //"De"
	{STR0087},2)} //"Indica a data início para filtro das ordens de serviço."
	@ 029,130 Say Oemtoansi(STR0048+":") Of oGroupApre Pixel //"Até"
	@ 028,144 MsGet oGet Var dDtF1 Of oGroupApre Valid MNC935DT(2,'1') Picture '99/99/9999' Size 44,08 HASBUTTON Pixel When lFolder1
	oGet:bHelp := { || ShowHelpCpo(NoAcento(AnsiToOem(STR0048+":")), ; //"Até"
	{STR0088},2)} //"Indica a data fim para filtro das ordens de serviço."

	@ 040,010 CheckBox oFerramenta Var lFerrament Prompt OemToAnsi(STR0049) On Change ChangeFer() Size 102,10 of oGroupApre Pixel When lFolder1	 //"Ferramenta"
	@ 041,071 Say Oemtoansi(STR0118+":") Of oGroupApre Pixel //"De"
	@ 040,083 MsGet oDeFerram Var cDeFerram Of oGroupApre Valid MNC935DeAt(1,cDeFerram,cAteFerram,'SH4',Len(cDeFerram)) Picture '@!' Size 115,08 HASBUTTON Pixel F3 'SH4' When lFerrament .AND. lFolder1
	oDeFerram:bHelp := { || ShowHelpCpo(NoAcento(AnsiToOem(STR0118+":")), ; //"De"
	{STR0089},2)} //"Indica o início do intervalo para filtro de ferramentas das ordens de serviço."
	@ 041,209 Say Oemtoansi(STR0048+":") Of oGroupApre Pixel //"Até"
	@ 040,223 MsGet oAteFerram Var cAteFerram Of oGroupApre Valid MNC935DeAt(2,cDeFerram,cAteFerram,'SH4',Len(cDeFerram)) Picture '@!' Size 115,08 HASBUTTON Pixel F3 'SH4' When lFerrament .AND. lFolder1
	oAteFerram:bHelp := { || ShowHelpCpo(NoAcento(AnsiToOem(STR0048+":")), ; //"Até"
	{STR0090},2)} //"Indica o fim do intervalo para filtro de ferramentas das ordens de serviço."

	@ 052,010 CheckBox oMaodeObra Var lMaodeObra Prompt OemToAnsi(STR0050) On Change ChangeMdo() Size 102,10 of oGroupApre Pixel When lFolder1 //"Mão de Obra"
	@ 053,071 Say Oemtoansi(STR0118+":") Of oGroupApre Pixel //"De"
	@ 052,083 MsGet oDeMdo Var cDeMdo  Of oGroupApre Valid MNC935DeAt(1,cDeMdo,cAteMdo,'ST1',Len(cDeMdo)) Picture '@!' Size 115,08 HASBUTTON Pixel F3 'ST1' When lMaodeObra .AND. lFolder1
	oDeMdo:bHelp := { || ShowHelpCpo(NoAcento(AnsiToOem(STR0118+":")), ; //"De"
	{STR0091},2)} //"Indica o início do intervalo para filtro de mão de obra das ordens de serviço."
	@ 053,209 Say Oemtoansi(STR0048+":") Of oGroupApre Pixel //"Até"
	@ 052,223 MsGet oAteMdo Var cAteMdo Of oGroupApre Valid MNC935DeAt(2,cDeMdo,cAteMdo,'ST1',Len(cDeMdo)) Picture '@!' Size 115,08 HASBUTTON Pixel F3 'ST1' When lMaodeObra .AND. lFolder1
	oAteMdo:bHelp := { || ShowHelpCpo(NoAcento(AnsiToOem(STR0048+":")), ; //"Até"
	{STR0092},2)} //"Indica o fim do intervalo para filtro de mão de obra das ordens de serviço."

	@ 064,010 CheckBox oProduto Var lProduto Prompt OemToAnsi(STR0038) On Change ChangePro() Size 102,10 of oGroupApre Pixel When lFolder1 //"Produto"
	@ 065,071 Say Oemtoansi(STR0118+":") Of oGroupApre Pixel //"De"
	@ 064,083 MsGet oDeProd Var cDeProd  Of oGroupApre Valid MNC935DeAt(1,cDeProd,cAteProd,'SB1',Len(cDeProd)) Picture '@!' Size 115,08 HASBUTTON Pixel F3 'SB1' When lProduto .AND. lFolder1
	oDeProd:bHelp := { || ShowHelpCpo(NoAcento(AnsiToOem(STR0118+":")), ; //"De"
	{STR0093},2)} //"Indica o início do intervalo para filtro de produtos das ordens de serviço."
	@ 065,209 Say Oemtoansi(STR0048+":") Of oGroupApre Pixel //"Até"
	@ 064,223 MsGet oAteProd Var cAteProd Of oGroupApre Valid MNC935DeAt(2,cDeProd,cAteProd,'SB1',Len(cDeProd)) Picture '@!' Size 115,08 HASBUTTON Pixel F3 'SB1' When lProduto .AND. lFolder1
	oAteProd:bHelp := { || ShowHelpCpo(NoAcento(AnsiToOem(STR0048+":")), ; //"Até"
	{STR0094},2)} //"Indica o fim do intervalo para filtro de produtos das ordens de serviço."

	@ 076,010 CheckBox oTerceiro Var lTerceiro Prompt OemToAnsi(STR0039) On Change ChangeTer() Size 102,10 of oGroupApre Pixel When lFolder1 //"Terceiro"
	@ 077,071 Say Oemtoansi(STR0118+":") Of oGroupApre Pixel //"De"
	@ 076,083 MsGet oDeTerc Var cDeTerc  Of oGroupApre Valid MNC935DeAt(1,cDeTerc,cAteTerc,'SA2',Len(cDeTerc)) Picture '@!' Size 115,08 HASBUTTON Pixel F3 'SA2' When lTerceiro .AND. lFolder1
	oDeTerc:bHelp := { || ShowHelpCpo(NoAcento(AnsiToOem(STR0118+":")), ; //"De"
	{STR0095},2)} //"Indica o início do intervalo para filtro de terceiros das ordens de serviço."
	@ 077,209 Say Oemtoansi(STR0048+":") Of oGroupApre Pixel //"Até"
	@ 076,223 MsGet oAteTerc Var cAteTerc Of oGroupApre Valid MNC935DeAt(2,cDeTerc,cAteTerc,'SA2',Len(cDeTerc)) Picture '@!' Size 115,08 HASBUTTON Pixel F3 'SA2' When lTerceiro .AND. lFolder1
	oAteTerc:bHelp := { || ShowHelpCpo(NoAcento(AnsiToOem(STR0048+":")), ; //"Até"
	{STR0096},2)} //"Indica o fim do intervalo para filtro de terceiros das ordens de serviço."

	@ 088,010 CheckBox oEspecialidade Var lEspeciali Prompt OemToAnsi(STR0036) On Change ChangeEsp() Size 102,10 of oGroupApre Pixel When lFolder1 //"Especialidade"
	@ 089,071 Say Oemtoansi(STR0118+":") Of oGroupApre Pixel //"De"
	@ 088,083 MsGet oDeEspec Var cDeEspec  Of oGroupApre Valid MNC935DeAt(1,cDeEspec,cAteEspec,'ST0',Len(cDeEspec)) Picture '@!' Size 115,08 HASBUTTON Pixel F3 'ST0' When lEspeciali .AND. lFolder1
	oDeEspec:bHelp := { || ShowHelpCpo(NoAcento(AnsiToOem(STR0118+":")), ; //"De"
	{STR0097},2)} //"Indica o início do intervalo para filtro de especialidades das ordens de serviço."
	@ 089,209 Say Oemtoansi(STR0048+":") Of oGroupApre Pixel //"Até"
	@ 088,223 MsGet oAteEspec Var cAteEspec Of oGroupApre Valid MNC935DeAt(2,cDeEspec,cAteEspec,'ST0',Len(cDeEspec)) Picture '@!' Size 115,08 HASBUTTON Pixel F3 'ST0' When lEspeciali .AND. lFolder1
	oAteEspec:bHelp := { || ShowHelpCpo(NoAcento(AnsiToOem(STR0048+":")), ; //"Até"
	{STR0098},2)} //"Indica o fim do intervalo para filtro de especialidades das ordens de serviço."

	If lGFrota

		//Segundo Folder		Era: 099,005,122,190
		oGrpFold5   := TGroup():New( 104,005,127,190,STR0051+":",oPanelPara,CLR_BLACK,CLR_WHITE,.T.,.F. )  //"Abastecimentos"
		@ 112,010 CheckBox oFolder2 Var lFolder2 Prompt OemToAnsi(STR0046) On Change MNChange('2') Size 102,10 of oGrpFold5 Pixel //"Listar dados"
		@ 113,071 Say Oemtoansi(STR0118+":") Of oGrpFold5 Pixel  //"De"
		@ 112,083 MsGet oGet Var dDtI5  Of oGrpFold5 Valid MNC935DT(1,'5') Picture '99/99/9999' Size 44,08 HASBUTTON Pixel When lFolder2
		oGet:bHelp := { || ShowHelpCpo(NoAcento(AnsiToOem(STR0118+":")), ;  //"De"
		{STR0099},2)} //"Indica o início do intervalo para filtro de abastecimentos."
		@ 113,130 Say Oemtoansi(STR0048+":") Of oGrpFold5 Pixel //"Até"
		@ 112,144 MsGet oGet Var dDtF5 Of oGrpFold5 Valid MNC935DT(2,'5') Picture '99/99/9999' Size 44,08 HASBUTTON Pixel When lFolder2
		oGet:bHelp := { || ShowHelpCpo(NoAcento(AnsiToOem(STR0048+":")), ; //"Até"
		{STR0100},2)} //"Indica o fim do intervalo para filtro de abastecimentos."

		//Terceiro Folder		Era: 099,192,122,377
		oGrpFold6   := TGroup():New( 104,192,127,377,STR0052+":",oPanelPara,CLR_BLACK,CLR_WHITE,.T.,.F. )  //"Pneus"
		@ 112,197 CheckBox oFolder3 Var lFolder3 Prompt OemToAnsi(STR0046) On Change MNChange('3') Size 102,10 of oGrpFold6 Pixel //"Listar dados"
		@ 113,258 Say Oemtoansi(STR0118+":") Of oGrpFold6 Pixel //"De"
		@ 112,270 MsGet oGet Var dDtI6  Of oGrpFold6 Valid MNC935DT(1,'6') Picture '99/99/9999' Size 44,08 HASBUTTON Pixel When lFolder3
		oGet:bHelp := { || ShowHelpCpo(NoAcento(AnsiToOem(STR0118+":")), ; //"De"
		{STR0101},2)} //"Indica o início do intervalo para filtro de ordens de serviço de pneus."
		@ 113,317 Say Oemtoansi(STR0048+":") Of oGrpFold6 Pixel //"Até"
		@ 112,331 MsGet oGet Var dDtF6 Of oGrpFold6 Valid MNC935DT(2,'6') Picture '99/99/9999' Size 44,08 HASBUTTON Pixel When lFolder3
		oGet:bHelp := { || ShowHelpCpo(NoAcento(AnsiToOem(STR0048+":")), ; //"Até"
		{STR0102},2)} //"Indica o fim do intervalo para filtro de ordens de serviço de pneus."

		//Quarto Folder			Era: 123,005,146,190
		oGrpFold2   := TGroup():New( 128,005,151,190,STR0053+":",oPanelPara,CLR_BLACK,CLR_WHITE,.T.,.F. )  //"Sinistros"
		@ 138,010 CheckBox oFolder4 Var lFolder4 Prompt OemToAnsi(STR0046) On Change MNChange('4') Size 102,10 of oGrpFold2 Pixel //"Listar dados"
		@ 139,071 Say Oemtoansi(STR0118+":") Of oGrpFold2 Pixel //"De"
		@ 138,083 MsGet oGet Var dDtI2  Of oGrpFold2 Valid MNC935DT(1,'2') Picture '99/99/9999' Size 44,08 HASBUTTON Pixel When lFolder4
		oGet:bHelp := { || ShowHelpCpo(NoAcento(AnsiToOem(STR0118+":")), ; //"De"
		{STR0103},2)} //"Indica o início do intervalo para filtro de sinistros."
		@ 139,130 Say Oemtoansi(STR0048+":") Of oGrpFold2 Pixel //"Até"
		@ 138,144 MsGet oGet Var dDtF2 Of oGrpFold2 Valid MNC935DT(2,'2') Picture '99/99/9999' Size 44,08 HASBUTTON Pixel When lFolder4
		oGet:bHelp := { || ShowHelpCpo(NoAcento(AnsiToOem(STR0048+":")), ; //"Até"
		{STR0104},2)} //"Indica o fim do intervalo para filtro de sinistros."

		//Quinto Folder			Era: 123,192,146,377
		oGrpFold3   := TGroup():New( 128,192,151,377,STR0054+":",oPanelPara,CLR_BLACK,CLR_WHITE,.T.,.F. )  //"Multas"
		@ 138,197 CheckBox oFolder5 Var lFolder5 Prompt OemToAnsi(STR0046) On Change MNChange('5') Size 102,10 of oGrpFold3 Pixel //"Listar dados"
		@ 139,258 Say Oemtoansi(STR0118+":") Of oGrpFold3 Pixel //"De"
		@ 138,270 MsGet oGet Var dDtI3  Of oGrpFold3 Valid MNC935DT(1,'3') Picture '99/99/9999' Size 44,08 HASBUTTON Pixel When lFolder5
		oGet:bHelp := { || ShowHelpCpo(NoAcento(AnsiToOem(STR0118+":")), ; //"De"
		{STR0105},2)} //"Indica o início do intervalo para filtro de multas."
		@ 139,317 Say Oemtoansi(STR0048+":") Of oGrpFold3 Pixel //"Até"
		@ 138,331 MsGet oGet Var dDtF3 Of oGrpFold3 Valid MNC935DT(2,'3') Picture '99/99/9999'Size 44,08 HASBUTTON Pixel When lFolder5
		oGet:bHelp := { || ShowHelpCpo(NoAcento(AnsiToOem(STR0048+":")), ; //"Até"
		{STR0106},2)} //"Indica o fim do intervalo para filtro de multas."

		//Sexto Folder			Era: 147,005,170,190
		oGrpFold4   := TGroup():New( 152,005,175,190,STR0107,oPanelPara,CLR_BLACK,CLR_WHITE,.T.,.F. ) //"Documentos:"
		@ 160,010 CheckBox oFolder6 Var lFolder6 Prompt OemToAnsi(STR0046) On Change MNChange('6') Size 102,10 of oGrpFold4 Pixel //"Listar dados"
		@ 161,071 Say Oemtoansi(STR0118+":") Of oGrpFold4 Pixel //"De"
		@ 160,083 MsGet oGet Var dDtI4 Of oGrpFold4 Valid MNC935DT(1,'4') Picture '99/99/9999' Size 44,08 HASBUTTON Pixel When lFolder6
		oGet:bHelp := { || ShowHelpCpo(NoAcento(AnsiToOem(STR0118+":")), ; //"De"
		{STR0108},2)} //"Indica o início do intervalo para filtro de documentos."
		@ 161,130 Say Oemtoansi(STR0048+":") Of oGrpFold4 Pixel //"Até"
		@ 160,144 MsGet oGet Var dDtF4 Of oGrpFold4 Valid MNC935DT(2,'4') Picture '99/99/9999' Size 44,08 HASBUTTON Pixel When lFolder6
		oGet:bHelp := { || ShowHelpCpo(NoAcento(AnsiToOem(STR0048+":")), ; //"Até"
		{STR0109},2)} //"Indica o fim do intervalo para filtro de documentos."
	Endif

	oGrpSX1 := TGroup():New( 179-nPadrao,005,304-nPadrao,377,STR0110,oPanelPara,CLR_BLACK,CLR_WHITE,.T.,.F. ) //"Árvore"
	TSay():New(185-nPadrao,039,{||STR0111+":"} ,oGrpSX1,,,,,,.T.,CLR_HBLUE,CLR_WHITE,200,20) //"Níveis de Custo"
	TSay():New(185-nPadrao,230,{||STR0112+":"},oGrpSX1,,,,,,.T.,CLR_HBLUE,CLR_WHITE,200,20) //"Ordem dos Níveis"

	oBoxEsq := VCBrowse():New( 194-nPadrao , 10, 175, 105,,{STR0056},{100},;  //"Níveis"
	oGrpSX1,,,,,{||},,,,,,,.F.,,.T.,,.F.,,.T.,.T.)

	oBoxEsq:SetArray(aBoxEsq)
	bBoxEsq := { || { aBoxEsq[oBoxEsq:nAt,1] } }
	oBoxEsq:bLine:= bBoxEsq

	@ 405-If(lGFrota,0,146),366 BTNBMP oBtnNext Resource "NEXT" Size 29,29 Of oGrpSX1 Noborder Action MNC935ESQ() When !Empty(aBoxEsq[oBoxEsq:nAt,1])
	@ 445-If(lGFrota,0,146),366 BTNBMP oBtnNext Resource "PREV" Size 29,29 Of oGrpSX1 Noborder Action MNC935DIR() When !Empty(aBoxDir[oBoxDir:nAt,1])

	oBoxDir := VCBrowse():New( 194-nPadrao , 202, 170, 105,,{STR0119},{100},;  //"Ordem"
	oGrpSX1,,,,,{||},,,,,,,.F.,,.T.,,.F.,,.T.,.T.)
	oBoxDir:SetArray(aBoxDir)
	bBoxDir := { || { aBoxDir[oBoxDir:nAt,1] } }
	oBoxDir:bLine:= bBoxDir

	oGeraOK := TButton():New( 306-nPadrao, 250, "OK",oPanelPara,,40,10,,,.F.,.T.,.F.,,.F.,,,.F. )
	oGeraOK:bAction := {|| GerarConsulta(.f.) }
	oBtnCancel := TButton():New( 306-nPadrao, 295, STR0113,oPanelPara,,40,10,,,.F.,.T.,.F.,,.F.,,,.F. ) //"Cancelar"
	oBtnCancel:bAction := {|| oDlgParame:End() }

	Activate MsDialog oDlgParame Centered

	If lFirst .Or. (!lTemOS .And. !lTemOut)
		Return .f.
	Endif

Return .t.

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Metodo    ³  MNC935DT   ³Autor³ Marcos Wagner Junior ³ Data ³20/09/2011³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Validacao de Data			                                   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ MNTC935                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Static Function MNC935DT(_nOrd,_cData)

	lRet := If(Empty(&('dDtF'+_cData)),.T.,VALDATA(&('dDtI'+_cData),&('dDtF'+_cData),IIF(_nOrd==1,"DATAMAIOR","DATAMENOR")))

	If lRet .And. _nOrd == 2 .And. Empty(&('dDtF'+_cData)) .And. !Empty(&('dDtI'+_cData))
		ShowHelpDlg(STR0114,{STR0115},1,{""},1) //"INVALIDO"###"Data fim não informada."
		lRet := .F.
	EndIf

Return lRet

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Metodo    ³  MNChange   ³Autor³ Marcos Wagner Junior ³ Data ³20/09/2011³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Validacao de Data			                                   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ MNTC935                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Static Function MNChange(_cNum)

	oInvisivel:SetFocus()
	&('oFolder'+_cNum):SetFocus()

Return .t.

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Metodo    ³  GerarDados ³Autor³ Marcos Wagner Junior ³ Data ³20/09/2011³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Validacao de Data			                                   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ MNTC935                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Static Function GerarDados(lCarrDados)
	Private nX := 1

	If lFolder1
		While nX <= 2
			Processa({ |lEnd| MNT935Ofi(nX,.f.,lCarrDados) },STR0120+" "+STR0121)  //"Aguarde..."##"Carregando ordens de serviço..."
		End
	Endif
	If lGFrota
		If lFolder2
			Processa({ |lEnd| MNT935Aba(lCarrDados) },STR0120+" "+STR0122)  //"Aguarde..."##"Carregando abastecimentos..."
		Endif
		If lFolder3
			nX := 1
			While nX <= 2
				Processa({ |lEnd| MNT935Ofi(nX,.t.,lCarrDados) },STR0120+" "+STR0123)  //"Aguarde..."##"Carregando pneus..."
			End
		Endif
		If lFolder4
			Processa({ |lEnd| MNT935Sin(lCarrDados) },STR0120+" "+STR0124)  //"Aguarde..."##"Carregando sinistros..."
		Endif
		If lFolder5
			Processa({ |lEnd| MNT935Mul(lCarrDados) },STR0120+" "+STR0125)  //"Aguarde..."##"Carregando multas..."
		Endif
		If lFolder6
			Processa({ |lEnd| MNT935Doc(lCarrDados) },STR0120+" "+STR0126)  //"Aguarde..."##"Carregando documentos..."
		Endif
	Endif

Return .t.

//---------------------------------------------------------------------------
/*/{Protheus.doc} fUpdateWay
Carrega caminho atual percorrido na arvore

@author NG Informatica
@since 30/09/2016
@version undefined
@param nRecTRB, numeric - Recno
@param cNiv, characters - Nivel
@type function
/*/
//---------------------------------------------------------------------------
Static Function fUpdateWay(nRecTRB,cNiv)

	Local aArea := GetArea()
	Local aAreaTRB := (cTRBMAIN)->(GetArea())
	dbSelectArea(cTRBMAIN)
	dbGoTo(nRecTRB)
	If oTree:Nivel() > 1
		cCaminho := MNC935NIV((cTRBMAIN)->TABELA)
		dbSelectArea(cTRBMAIN)
		dbSetOrder(02)
		dbSeek(cNiv)
		While (cTRBMAIN)->(!Eof())
			cNiv := (cTRBMAIN)->NIVSUP
			dbSeek(cNiv)
			cCaminho := MNC935NIV((cTRBMAIN)->TABELA) + " \ " + cCaminho
		EndDo
		cCaminho := AllTrim(SM0->M0_FILIAL) + cCaminho
	Else
		cCaminho := AllTrim(SM0->M0_FILIAL)
	EndIf
	RestArea(aAreaTRB)
	RestArea(aArea)
Return Nil

//---------------------------------------------------------------------------
/*/{Protheus.doc} fQryOfi
Monta a query de oficina
@author bruno.souza
@since 04/10/2016
@version undefined
@param _n2, numeric, Indica se é a tabela Principal (1) ou a espelho (2)
@param lPneu, logical, Indica a tratativa de bens de categoria 3=Pneu
@param lLocaliz, logical, Indica a tratativa de localizações
@type function
/*/
//---------------------------------------------------------------------------
Static Function fQryOfi(_n2, lPneu, lLocaliz, cFiltroSTL)

	Local cQuery := ""

	cQuery := " SELECT 0 AS VALPRE, 0 AS VALREA,"
	cQuery += " STJ.TJ_FILIAL, STJ.TJ_CCUSTO, STJ.TJ_CODAREA, STJ.TJ_TIPO, STJ.TJ_SERVICO, STJ.TJ_ORDEM, STL.TL_TAREFA,"
	cQuery += " STJ.TJ_SEQRELA, STL.TL_SEQRELA, STL.TL_CUSTO, CTT.CTT_DESC01,STE.TE_CARACTE,"
	cQuery += " STJ.TJ_CODBEM, STL.TL_DTINICI, STL.TL_HOINICI, STL.TL_TIPOREG, STL.TL_CODIGO, STJ.TJ_PLANO, STL.TL_FILIAL,"
	If !lLocaliz
		cQuery += " ST9.T9_CODFAMI, ST6.T6_NOME, ST9.T9_CODBEM, ST9.T9_NOME"
	Else
		cQuery += " TAF.TAF_CODNIV, TAF.TAF_NOMNIV"
	EndIf
	cQuery += " FROM " + RetSqlName("STL")+" STL, "+ RetSqlName("STJ")+" STJ "

	//JOIN Tipos de manutencao
	cQuery += "	JOIN " + RetSQLName("STE") + " STE ON STJ.TJ_TIPO = STE.TE_TIPOMAN "

	cQuery += " AND " + NGMODCOMP("STJ","STE")
	cQuery += " AND STE.D_E_L_E_T_ <> '*' "

	//JOIN Area de Manutencao
	cQuery += "	JOIN " + RetSQLName("STD") + " STD ON STJ.TJ_CODAREA = STD.TD_CODAREA "

	cQuery += " AND " + NGMODCOMP("STJ","STD")
	cQuery += " AND STD.D_E_L_E_T_ <> '*' "

	//JOIN Servico
	cQuery += "	JOIN " + RetSQLName("ST4") + " ST4 ON STJ.TJ_SERVICO = ST4.T4_SERVICO "

	cQuery += " AND " + NGMODCOMP("STJ","ST4")
	cQuery += " AND ST4.D_E_L_E_T_ <> '*' "

	//JOIN Bem
	If !lLocaliz
		cQuery += "	JOIN " + RetSQLName("ST9") + " ST9 ON STJ.TJ_CODBEM = ST9.T9_CODBEM "

		cQuery += " AND " + NGMODCOMP("STJ","ST9")
		cQuery += " AND ST9.D_E_L_E_T_ <> '*' "

		//JOIN Familia
		cQuery += "	JOIN " + RetSQLName("ST6") + " ST6 ON ST9.T9_CODFAMI = ST6.T6_CODFAMI "

		cQuery += " AND " + NGMODCOMP("ST9","ST6")
		cQuery += " AND ST6.D_E_L_E_T_ <> '*' "
	EndIf

	//JOIN Localização
	If lLocaliz
		cQuery += "	JOIN " + RetSQLName("TAF") + " TAF ON STJ.TJ_CODBEM = TAF.TAF_CODNIV "

		cQuery += " AND " + NGMODCOMP("STJ","TAF")
		cQuery += " AND TAF.D_E_L_E_T_ <> '*' "
	EndIf

	//JOIN Centro de Custo
	If lLocaliz
		cQuery += " LEFT"
	EndIf
	cQuery += "	JOIN " + RetSQLName("CTT") + " CTT ON STJ.TJ_CCUSTO = CTT.CTT_CUSTO "

	cQuery += " AND " + NGMODCOMP("STJ","CTT")
	cQuery += " AND CTT.D_E_L_E_T_ <> '*' "

	cQuery += " WHERE "

	// Condição que filtra pela situação em que a O.S. se encontra
	Do Case

		Case cStatus == '1' // Liberadas
			cQuery += " STJ.TJ_SITUACA = 'L'  AND STJ.TJ_TERMINO = 'N' AND "

		Case cStatus == '2' // Pendentes
			cQuery += " STJ.TJ_SITUACA = 'P'  AND STJ.TJ_TERMINO = 'N' AND "

		Case cStatus == '3' // Abertas
			cQuery += " STJ.TJ_SITUACA <> 'C' AND STJ.TJ_TERMINO = 'N' AND "

		Case cStatus == '4' // Finalizadas
			cQuery += " STJ.TJ_SITUACA = 'L'  AND STJ.TJ_TERMINO = 'S' AND "

	EndCase

	cQuery += " STL.TL_CUSTO > 0"

	If lPneu
		cQuery += " AND ST9.T9_CATBEM = '3' "
		If !Empty(dDtI6) .AND. !Empty(dDtF6)
			cQuery += " AND STL.TL_DTINICI >= '"+DTOS(dDtI6)+"'"
			cQuery += " AND STL.TL_DTINICI <= '"+DTOS(dDtF6)+"'"
		Endif
	Else
		If !lLocaliz
			cQuery += " AND ST9.T9_CATBEM <> '3' "
		EndIf
		If !Empty(dDtI1) .AND. !Empty(dDtF1)
			cQuery += " AND STL.TL_DTINICI >= '"+DTOS(dDtI1)+"'"
			cQuery += " AND STL.TL_DTINICI <= '"+DTOS(dDtF1)+"'"
		Endif
	Endif
	cQuery += " AND " + NGMODCOMP("STJ","STL")
	cQuery += " AND   STL.TL_ORDEM  = STJ.TJ_ORDEM "
	cQuery += " AND   STL.TL_PLANO  = STJ.TJ_PLANO "
	cQuery += " AND   STJ.D_E_L_E_T_ <> '*' "
	cQuery += " AND   STL.D_E_L_E_T_ <> '*' "
	cQuery += " AND STJ.TJ_FILIAL = " + ValToSql(xFilial('STJ'))
	If cEmQue == '1'
		cQuery += " AND TE_CARACTE = 'P' "
	ElseIf cEmQue == '2'
		cQuery += " AND TE_CARACTE = 'C' "
	ElseIf cEmQue == '3'
		cQuery += " AND TE_CARACTE = 'O' "
	Endif
	If !Empty(cFiltroSTL)
		cQuery += cFiltroSTL
	Endif
	cQuery += " ORDER BY STJ.TJ_ORDEM, STL.TL_SEQRELA "
	If _n2 == 2
		cQuery := StrTran(cQuery,'TJ','TS')
		cQuery := StrTran(cQuery,'TL','TT')
		aSTLouSTT := {'(cAliasQry)->TS_CODBEM','(cAliasQry)->TT_DTINICI','(cAliasQry)->TT_HOINICI','(cAliasQry)->TS_CCUSTO',;
		'(cAliasQry)->TS_CODAREA','(cAliasQry)->TS_TIPO','(cAliasQry)->TS_SERVICO','(cAliasQry)->TS_ORDEM',;
		'(cAliasQry)->TS_FILIAL','(cAliasQry)->TT_SEQRELA','(cAliasQry)->TT_CUSTO','(cAliasQry)->T9_CODFAMI',;
		'(cAliasQry)->T9_NOME',,,,;
		'(cAliasQry)->T4_NOME','(cAliasQry)->TE_CARACTE','','',;
		'','','','xFilial("STT")+(cAliasQry)->TS_ORDEM+(cAliasQry)->TS_PLANO',;
		'(cAliasQry)->TT_TAREFA','(cAliasQry)->TS_CODBEM+(cAliasQry)->TS_SERVICO+(cAliasQry)->TS_SEQRELA','(cAliasQry)->CTT_DESC01','(cAliasQry)->TT_TIPOREG',;
		'(cAliasQry)->TT_CODIGO','(cAliasQry)->TS_PLANO',''}
	Else
		aSTLouSTT := {'(cAliasQry)->TJ_CODBEM','(cAliasQry)->TL_DTINICI','(cAliasQry)->TL_HOINICI','(cAliasQry)->TJ_CCUSTO',;
		'(cAliasQry)->TJ_CODAREA','(cAliasQry)->TJ_TIPO','(cAliasQry)->TJ_SERVICO','(cAliasQry)->TJ_ORDEM',;
		'(cAliasQry)->TJ_FILIAL','(cAliasQry)->TL_SEQRELA','(cAliasQry)->TL_CUSTO','(cAliasQry)->T9_CODFAMI',;
		'(cAliasQry)->T9_NOME',,,,;
		'(cAliasQry)->T4_NOME','(cAliasQry)->TE_CARACTE','','',;
		'','','','xFilial("STL")+(cAliasQry)->TJ_ORDEM+(cAliasQry)->TJ_PLANO',;
		'(cAliasQry)->TL_TAREFA','(cAliasQry)->TJ_CODBEM+(cAliasQry)->TJ_SERVICO+(cAliasQry)->TJ_SEQRELA','(cAliasQry)->CTT_DESC01','(cAliasQry)->TL_TIPOREG',;
		'(cAliasQry)->TL_CODIGO','(cAliasQry)->TJ_PLANO','(cAliasQry)->TAF_NOMNIV' }
	Endif
Return cQuery

//---------------------------------------------------------------------------
/*/{Protheus.doc} fGrvLoc
Grava localização no trb de oficina
@author bruno.souza
@since 04/10/2016
@version undefined
@param cQueryLoc, characters, query de localizações
@param cAliasQry, characters, alias do TRB
@param _n2, numeric, Indica se é a tabela Principal (1) ou a espelho (2)
@type function
/*/
//---------------------------------------------------------------------------
Static Function fGrvLoc(cQueryLoc, cAliasQry, _n2)

	Local cQryAlias := GetNextAlias()

	cQueryLoc := ChangeQuery(cQueryLoc)
	dbUseArea( .T., "TOPCONN", TCGenQry(,,cQueryLoc), cQryAlias, .F., .T.)
	(cQryAlias)->(dbGoTop())
	While (cQryAlias)->(!Eof())
		RecLock(cAliasQry, .T.)
		(cAliasQry)->VALREA	:=(cQryAlias)->VALREA
		(cAliasQry)->VALPRE	:=(cQryAlias)->VALPRE

		If _n2 == 2
			(cAliasQry)->TS_FILIAL	:= (cQryAlias)->TS_FILIAL
			(cAliasQry)->TS_ORDEM	:= (cQryAlias)->TS_ORDEM
			(cAliasQry)->TS_PLANO	:= (cQryAlias)->TS_PLANO
			(cAliasQry)->TS_CODBEM	:= (cQryAlias)->TS_CODBEM
			(cAliasQry)->TS_SERVICO := (cQryAlias)->TS_SERVICO
			(cAliasQry)->TS_SEQRELA := (cQryAlias)->TS_SEQRELA
			(cAliasQry)->TS_CCUSTO	:= (cQryAlias)->TS_CCUSTO
			(cAliasQry)->TS_CODAREA := (cQryAlias)->TS_CODAREA
			(cAliasQry)->TS_TIPO	:= (cQryAlias)->TS_TIPO
			(cAliasQry)->TT_FILIAL	:= (cQryAlias)->TT_FILIAL
			(cAliasQry)->TT_CODIGO	:= (cQryAlias)->TT_CODIGO
			(cAliasQry)->TT_DTINICI := StoD((cQryAlias)->TT_DTINICI)
			(cAliasQry)->TT_HOINICI := (cQryAlias)->TT_HOINICI
			(cAliasQry)->TT_TAREFA	:= (cQryAlias)->TT_TAREFA
			(cAliasQry)->TT_SEQRELA := (cQryAlias)->TT_SEQRELA
			(cAliasQry)->TT_TIPOREG := (cQryAlias)->TT_TIPOREG
			(cAliasQry)->TT_CUSTO	:= (cQryAlias)->TT_CUSTO
		Else
			(cAliasQry)->TJ_FILIAL	:= (cQryAlias)->TJ_FILIAL
			(cAliasQry)->TJ_ORDEM	:= (cQryAlias)->TJ_ORDEM
			(cAliasQry)->TJ_PLANO	:= (cQryAlias)->TJ_PLANO
			(cAliasQry)->TJ_CODBEM	:= (cQryAlias)->TJ_CODBEM
			(cAliasQry)->TJ_SERVICO := (cQryAlias)->TJ_SERVICO
			(cAliasQry)->TJ_SEQRELA := (cQryAlias)->TJ_SEQRELA
			(cAliasQry)->TJ_CCUSTO	:= (cQryAlias)->TJ_CCUSTO
			(cAliasQry)->TJ_CODAREA := (cQryAlias)->TJ_CODAREA
			(cAliasQry)->TJ_TIPO	:= (cQryAlias)->TJ_TIPO
			(cAliasQry)->TL_FILIAL	:= (cQryAlias)->TL_FILIAL
			(cAliasQry)->TL_CODIGO	:= (cQryAlias)->TL_CODIGO
			(cAliasQry)->TL_DTINICI := StoD((cQryAlias)->TL_DTINICI)
			(cAliasQry)->TL_HOINICI := (cQryAlias)->TL_HOINICI
			(cAliasQry)->TL_TAREFA	:= (cQryAlias)->TL_TAREFA
			(cAliasQry)->TL_SEQRELA := (cQryAlias)->TL_SEQRELA
			(cAliasQry)->TL_TIPOREG := (cQryAlias)->TL_TIPOREG
			(cAliasQry)->TL_CUSTO	:= (cQryAlias)->TL_CUSTO
		EndIf
		(cAliasQry)->CTT_DESC01	:= (cQryAlias)->CTT_DESC01
		(cAliasQry)->TE_CARACTE	:= (cQryAlias)->TE_CARACTE
		(cAliasQry)->TAF_CODNIV	:= (cQryAlias)->TAF_CODNIV
		(cAliasQry)->TAF_NOMNIV	:= (cQryAlias)->TAF_NOMNIV
		MsUnLock()
		(cQryAlias)->(dbSkip())
	End
	(cQryAlias)->(dbCloseArea())
Return .T.

//------------------------------------------------------------------
/*/{Protheus.doc} fDefOrdem
Define o índice a ser usado na pesquisa. 
Caso o registro posicionado atualmente seja especificamente um registro de MUL/DOC/SIN o índice é 2, se não é 3.

@type function

@author Gabriel Sokacheski
@since 25/06/2020

@param cNIVSUP, caractere, Código do registro posicionado atualmente.

@return nOrdem, numérico, Retorna a ordem a ser utilizada na pesquisa.
/*/
//------------------------------------------------------------------
Static Function fDefOrdem( cNIVSUP )

	Local nOrdem := 3

	lUltReg := .F.
	
	dbSelectArea( cTRBMAIN )
	dbSetOrder( 2 )
	If dbSeek( cNIVSUP )
		If ( cTRBMAIN )->TABELA $ 'TS1/TRX/TRH'
			nOrdem := 2
			lUltReg := .T.
		EndIf
	EndIf

Return nOrdem

//------------------------------------------------------------------
/*/{Protheus.doc} fCarDados
Monta os dados do registro posicionado atualmente

@type function

@author Gabriel Sokacheski
@since 25/06/2020

@param nTotPre, numérico, Indica o valor total previsto.
@param nTotRea, numérico, Indica o valor total realizado.
/*/
//------------------------------------------------------------------
Static Function fCarDados( nTotPre, nTotRea )

	Local _nPercPre := 0
	Local _nPercRea := 0

	If ( cTRBMAIN )->DIVISAO $ ( 'SIN/MUL/ABA/DOC' ) .And. !Empty( ( cTRBMAIN )->DIVISAO ) .And. !lTemOfi
		
		If ( cTRBMAIN )->TABELA == 'TQN'
			lPrxUltNiv := .T.
			nPercTotal := ( ( cTRBMAIN )->VALREA / nTotalPai * 100 )
			aAdd( aColsRod, { DTOC( ( cTRBMAIN )->DATATAB ), ( cTRBMAIN )->HORATAB, ( cTRBMAIN )->VALREA, nPercTotal } )
		ElseIf ( cTRBMAIN )->TABELA == 'MEA'
			nPercTotal := ( ( cTRBMAIN )->VALREA / nTotalPai * 100 )
			aAdd( aColsRod, { ( cTRBMAIN )->MESANO, ( cTRBMAIN )->VALREA, nPercTotal } )
		ElseIf ( cTRBMAIN )->TABELA == 'TRH'
			lPrxUltNiv := .T.
			nPercTotal := ( ( cTRBMAIN )->VALREA / nTotalPai * 100 )
			aAdd( aColsRod, {DTOC( ( cTRBMAIN )->DATATAB ), ( cTRBMAIN )->HORATAB, ( cTRBMAIN )->VALREA, nPercTotal } )
		ElseIf ( cTRBMAIN )->TABELA $ 'TRX/TS1'
			lPrxUltNiv := .T.
			nPercTotal := ( ( cTRBMAIN )->VALREA / nTotalPai * 100 )
			aAdd( aColsRod, {DTOC( ( cTRBMAIN )->DATATAB ), ( cTRBMAIN )->HORATAB, ( cTRBMAIN )->VALPRE, ( cTRBMAIN )->VALREA, nPercTotal } )
		ElseIf ( cTRBMAIN )->DIVISAO $ 'MUL/DOC'
			_nPercPre := ( ( cTRBMAIN )->VALREA / nTotalPai * 100 )
			aAdd( aColsRod, { ( cTRBMAIN )->CODIGO, ( cTRBMAIN )->DESCRI, ( cTRBMAIN )->VALPRE, ( cTRBMAIN )->VALREA, _nPercPre } )
		Else
			_nPercPre := ( ( cTRBMAIN )->VALREA / nTotalPai * 100 )
			aAdd( aColsRod, { ( cTRBMAIN )->CODIGO, ( cTRBMAIN )->DESCRI, ( cTRBMAIN )->VALREA, _nPercPre } )
		EndIf

	Else
		_nPercPre := ( ( cTRBMAIN )->VALPRE / nTotPre * 100 )
		_nPercRea := ( ( cTRBMAIN )->VALREA / nTotRea * 100 )
		
		If ( cTRBMAIN )->DIVISAO $ ( 'OFI/PNE' )
			lTemOfi := .T.
			
			If ( cTRBMAIN )->TABELA == 'STJ'
				lPrxUltNiv := .T.
				aAdd( aColsRod, { ( cTRBMAIN )->CODIGO, ( cTRBMAIN )->VALPRE, _nPercPre, ( cTRBMAIN )->VALREA, _nPercRea } )
			ElseIf ( cTRBMAIN )->TABELA == 'ST5'
				aAdd( aColsRod, { ( cTRBMAIN )->CODIGO, ( cTRBMAIN )->DESCRI, ( cTRBMAIN )->VALPRE, _nPercPre, ( cTRBMAIN )->VALREA, _nPercRea } )
			Else
				aAdd( aColsRod, { ( cTRBMAIN )->CODIGO, ( cTRBMAIN )->DESCRI, ( cTRBMAIN )->VALPRE, _nPercPre, ( cTRBMAIN )->VALREA, _nPercRea, ( cTRBMAIN )->QTDEOS } )
			EndIf

		Else
			aAdd( aColsRod, { ( cTRBMAIN )->CODIGO, ( cTRBMAIN )->DESCRI, ( cTRBMAIN )->VALPRE, _nPercPre, ( cTRBMAIN )->VALREA, _nPercRea, 0 } )
		EndIf

	EndIf

Return
