#INCLUDE 'PROTHEUS.CH'
#INCLUDE 'FWMVCDEF.CH'
#INCLUDE 'MNTA386.CH'

//-------------------------------------------------------------------
/*/{Protheus.doc} MNTA386
Rotina para atualizacao de custos das ordens de serviço via integracao
com backoffice de outro sistema.
@author Felipe Nathan Welter
@since 26/02/2013
@version P11
/*/
//-------------------------------------------------------------------
Function MNTA386()

	//+-------------------------------------------------------------+
	//| Armazena variaveis p/ devolucao (NGRIGHTCLICK)              |
	//+-------------------------------------------------------------+
	Local aNGBEGINPRM  := NGBEGINPRM()

	Local aFLDSTJ    := {}
	Local aFLDSTL    := {}
	Local aDBFSTJ    := {}
	Local aDBFSTL    := {}
	Local aFieldsSTJ := {}
	Local aFieldsSTL := {}
	Local aColLis    := {}
	Local aCoors     := FWGetDialogSize( oMainWnd )
	Local aFSTJTQN   := {STR0001 , STR0002} //'Ordens de Serviço' ## 'Abastecimentos'
	Local nX := 0
	
	Local cQueryTqn := ''
	
	Local oFont20  := TFont():New("Arial",,-13,.F.,.F.)
	Local oTmpTbl1
	Local oTmpTbl2
	Local oMainDlg
	Local oFWLayer
	Local oPnlSTJ
	Local oWinINF
	Local oPnlInf
	Local oMarkSTJ
	Local oBrwSTL
	Local oRlcSTJSTL
	Local oPnTopCus
	Local oPnAllCus
	Local oTButClCus
	Local oI1Folder
	Local oObjTQN

	Private cTRBSTJ := ''
	Private cTRBSTL := ''
	Private cCadastro  := ''  					//em uso no NGCAD01
	
	
	Private cAliasAbas := GetNextAlias() 

	//+-------------------------------------------------------------+
	//| Valida se pode executar a Rotina 							|
	//+-------------------------------------------------------------+
	If AllTrim(GetNewPar("MV_NGINTER","N")) != "M"
		ShowHelpDlg(STR0003, {STR0004+Space(01)+; //"ATENCAO" ## "A rotina de atualização de custos só pode ser executada se o ambiente estiver configurado"
					STR0005},1,; //"para trabalhar com integração via mensagem única."
				   {STR0006},1) //'Habilite o parâmetro MV_NGINTER para trabalhar com a integração.'
		Return .F.
	EndIf

	//+-------------------------------------------------------------+
	//| Monta estruturas de dados 									|
	//+-------------------------------------------------------------+

	//STJ
	aFieldsSTJ := {"TJ_ORDEM","TJ_PLANO","TJ_CODBEM","TJ_SERVICO","TJ_DTORIGI","TJ_CODAREA","TJ_DTMRFIM",;
				   "TJ_CUSTMDO","TJ_CUSTMAT","TJ_CUSTMAA","TJ_CUSTMAS","TJ_CUSTTER"}

	For nX := 1 To Len(aFieldsSTJ)

		aAdd(aDBFSTJ,{aFieldsSTJ[nX],;
					  Posicione("SX3", 2, aFieldsSTJ[nX], "X3_TIPO"),;
					  Posicione("SX3", 2, aFieldsSTJ[nX], "X3_TAMANHO"),;
					  Posicione("SX3", 2, aFieldsSTJ[nX], "X3_DECIMAL")})

			If !(aFieldsSTJ[nX] $ "TJ_CUSTMDO/TJ_CUSTMAT/TJ_CUSTMAA/TJ_CUSTMAS/TJ_CUSTTER")

				aAdd(aFLDSTJ,{Posicione("SX3", 2, aFieldsSTJ[nX], "X3Titulo()"),;
							  aFieldsSTJ[nX],;
							  Posicione("SX3", 2, aFieldsSTJ[nX], "X3_TIPO"),;
							  Posicione("SX3", 2, aFieldsSTJ[nX], "X3_TAMANHO"),;
							  Posicione("SX3", 2, aFieldsSTJ[nX], "X3_DECIMAL"),;
							  Posicione("SX3", 2, aFieldsSTJ[nX], "X3_PICTURE")})

			EndIf

	Next nX

	aAdd(aDBFSTJ,{"RECNO"		 ,"N",15,0})
	aAdd(aDBFSTJ,{"OK"   		 ,"C", 1,0})
	aAdd(aDBFSTJ,{"CUSTO"		 ,"N", 9,3})
	aAdd(aFLDSTJ,{"Custo","CUSTO","N", 9,3, "@E 999,999.99 "})

	//STL
	aFieldsSTL := {"TL_ORDEM","TL_TAREFA","TL_TIPOREG","TL_CODIGO","TL_SEQRELA","TL_CUSTO","TL_QUANTID","TL_UNIDADE"}

	//SEQRELA
	For nX := 1 To Len(aFieldsSTL)

		If aFieldsSTL[nX] == "TL_TIPOREG"

			aAdd(aDBFSTL,{aFieldsSTL[nX],;
						  Posicione("SX3", 2, aFieldsSTL[nX], "X3_TIPO"),;
						  15,;
						  Posicione("SX3", 2, aFieldsSTL[nX], "X3_DECIMAL")})

		Else

			aAdd(aDBFSTL,{aFieldsSTL[nX],;
						  Posicione("SX3", 2, aFieldsSTL[nX], "X3_TIPO"),;
						  Posicione("SX3", 2, aFieldsSTL[nX], "X3_TAMANHO"),;
						  Posicione("SX3", 2, aFieldsSTL[nX], "X3_DECIMAL")})

		EndIf

		If aFieldsSTL[nX] == "TL_TIPOREG"

			aAdd(aFLDSTL,{Posicione("SX3", 2, aFieldsSTL[nX], "X3Titulo()"),;
						  aFieldsSTL[nX],;
						  Posicione("SX3", 2, aFieldsSTL[nX], "X3_TIPO"),;
						  Posicione("SX3", 2, aFieldsSTL[nX], "X3_TAMANHO"),;
						  Posicione("SX3", 2, aFieldsSTL[nX], "X3_DECIMAL"),;
						  Posicione("SX3", 2, aFieldsSTL[nX], "X3_PICTURE")})

		ElseIf !(aFieldsSTL[nX] $ "TL_ORDEM/TL_SEQRELA")

			aAdd(aFLDSTL,{Posicione("SX3", 2, aFieldsSTL[nX], "X3Titulo()"),;
						  aFieldsSTL[nX],;
						  Posicione("SX3", 2, aFieldsSTL[nX], "X3_TIPO"),;
						  Posicione("SX3", 2, aFieldsSTL[nX], "X3_TAMANHO"),;
						  Posicione("SX3", 2, aFieldsSTL[nX], "X3_DECIMAL"),;
						  Posicione("SX3", 2, aFieldsSTL[nX], "X3_PICTURE")})

		EndIf

	Next nX

	aAdd(aDBFSTL,{"RECNO","N",15,0})

	//+-------------------------------------------------------------+
	//| Cria arquivos temporarios									|
	//+-------------------------------------------------------------+

	// STJ
	cTRBSTJ := GetNextAlias()
	//Intancia classe FWTemporaryTable
	oTmpTbl1:= FWTemporaryTable():New( cTRBSTJ, aDBFSTJ )
	//Adiciona os Indices
	oTmpTbl1:AddIndex( "Ind01" , {"TJ_ORDEM"})
	//Cria a tabela temporaria
	oTmpTbl1:Create()

	// STL
	cTRBSTL := GetNextAlias()
	//Intancia classe FWTemporaryTable
	oTmpTbl2:= FWTemporaryTable():New( cTRBSTL, aDBFSTL )
	//Adiciona os Indices
	oTmpTbl2:AddIndex( "Ind01" , {"TL_ORDEM","TL_TIPOREG","TL_CODIGO","TL_SEQRELA" } )
	//Cria a tabela temporaria
	oTmpTbl2:Create()

	//+-------------------------------------------------------------+
	//| Grava registros para os browses                             |
	//+-------------------------------------------------------------+
	fGravaDados('',aDBFSTJ,aFieldsSTJ,aFieldsSTL)

	//+-------------------------------------------------------------+
	//| Criacao dos objetos de tela                                 |
	//+-------------------------------------------------------------+

	Define MsDialog oMainDlg Title STR0007 From aCoors[1], aCoors[2] To aCoors[3], aCoors[4] Pixel //'Atualização de Custos'

	oPnTopCus := TPanel():New(0,0,,oMainDlg,,,,,,20,20,.F.,.F.)
 	oPnTopCus:Align := CONTROL_ALIGN_TOP
		
		oTButClCus := TBrowseButton():New( 05,05,STR0025,oPnTopCus,{|| fAtuCust(oMarkSTJ, oBrwSTL, aDBFSTJ,aFieldsSTJ, aFieldsSTL, oObjTQN ) },70,15,,oFont20,.F.,.T.,.F.,,.F.,,,)  //'Atualizar Custos'
	
	oPnAllCus := TPanel():New(0,0,,oMainDlg,,,,,,80,80,.F.,.F.)
	oPnAllCus:Align := CONTROL_ALIGN_ALLCLIENT

	oI1Folder := TFolder():New(01, 01, aFSTJTQN, , oPnAllCus, 1, CLR_BLACK, CLR_WHITE, .T., , 1000, 1000)
	oI1Folder:Align := CONTROL_ALIGN_ALLCLIENT

		// Cria o container onde serão colocados os browses
		oFWLayer := FWLayer():New()
		oFWLayer:Init( oI1Folder:aDialogs[1], .F., .T. )

			// Define Paineis
			oFWLayer:AddLine   ('UP'    , 60, .F.)
			oFWLayer:AddCollumn('ALL'   ,100, .F.,'UP'  )
			oFWLayer:AddLine   ('DOWN'  , 40, .F.)
			oFWLayer:AddCollumn('LEFT'  , 60, .F.,'DOWN')
			oFWLayer:AddCollumn('RIGHT' , 40, .F.,'DOWN')
			oFWLayer:addWindow ( 'RIGHT','WINDOW1' , STR0028,100, .F., .F., Nil,'DOWN') //'Custos'

				oPnlSTJ := oFWLayer:getColPanel('ALL'  ,'UP'  )
				oPnlSTL := oFWLayer:getColPanel('LEFT' ,'DOWN')

				oWinINF := oFWLayer:getWinPanel('RIGHT','WINDOW1','DOWN')
					
					oPnlInf := TPanel():New(00,00,,oWinINF,,,,,Nil,100,100,.F.,.F.)
					oPnlInf :Align := CONTROL_ALIGN_ALLCLIENT

						//Cria MarkBrowse de OS
						oMarkSTJ := FWMarkBrowse():New()
						oMarkSTJ :SetOwner(oPnlSTJ)
						oMarkSTJ :SetDescription(STR0008) //'Ordens de Serviço Faturadas'
						oMarkSTJ :SetAlias(cTRBSTJ)
						oMarkSTJ :SetTemporary(.T.)
						oMarkSTJ :DisableReport()
						
						oMarkSTJ :SetFields(aFLDSTJ)
						oMarkSTJ :SetFieldMark( 'OK' )
						oMarkSTJ :SetAllMark({|| oMarkSTJ:AllMark() })
						oMarkSTJ :SetChange ({|| oPnlInf:FreeChildren(), fGraficoSTL(@oPnlInf) })
						oMarkSTJ :Activate()

						//Cria Browse de Insumos
						oBrwSTL := FWMBrowse():New()
						oBrwSTL :SetOwner(oPnlSTL)
						oBrwSTL :SetDescription('Insumos')
						oBrwSTL :SetTemporary(.T.)
						oBrwSTL :SetAlias (cTRBSTL)
						oBrwSTL :SetFields(aFLDSTL)
						oBrwSTL :addLegend("Val((cTRBSTL)->TL_SEQRELA) == 0","GRAY",STR0029) //'Previsto'
						oBrwSTL :addLegend("Val((cTRBSTL)->TL_SEQRELA) > 0","GREEN",STR0030) //'Realizado'
						oBrwSTL :DisableReport()
						oBrwSTL :DisableDetails()
						oBrwSTL :SetProfileID('2')
						oBrwSTL :SetDoubleClick({|x| SetAltera(.F.), SetInclui(.F.),STL->(dbGoTo((cTRBSTL)->RECNO)), NGCAD01("STL",RecNo(),2)})
						oBrwSTL :Activate()

		// Relacionamento entre os Browses
		oRlcSTJSTL:= FWBrwRelation():New()
		oRlcSTJSTL:AddRelation( oMarkSTJ  , oBrwSTL , { { 'TL_ORDEM' , 'TJ_ORDEM' } } )
		oRlcSTJSTL:Activate()

		oObjTQN := FwBrowse():New()

			//Carrega a tabela temporária dos registros de abastecimentos
			cQueryTqn := fLoadQry( cQueryTqn )
			
			//Adiciona os campos a serem mostrados no Browse
			aColLis := aClone( fCampBrow() )

			oObjTQN:SetDataQuery()//Define que a utilizacao é por tabela
			oObjTQN:SetAlias( cAliasAbas )//Define alias de utilizacao
			oObjTQN:SetQuery( cQueryTqn )

			oObjTQN:DisableReport()//Desabilita botao de impressao
			oObjTQN:DisableConfig()//Desabilita botao de configuracao
			
			oObjTQN:SetOwner( oI1Folder:aDialogs[2] )//Define o objeto pai
			oObjTQN:SetColumns( aColLis )//Define as colunas preestabelecidas

		oObjTQN:Activate()//Ativa o browse

	Activate MsDialog oMainDlg CENTERED
	//+-------------------------------------------------------------+
	//| Apaga arquivos temporarios								    |
	//+-------------------------------------------------------------+

	oTmpTbl1:Delete()
	oTmpTbl2:Delete()
	
	//+-------------------------------------------------------------+
	//| Devolve variaveis armazenadas (NGRIGHTCLICK)                |
	//+-------------------------------------------------------------+
	NGRETURNPRM(aNGBEGINPRM)

Return Nil

//-------------------------------------------------------------------
/*/{Protheus.doc} fGravaDados
Funcao que grava ordens de servico e insumos para os browses, ou atualiza
uma determinada OS.

@param cOrdem  Caracter ordem de servico para atualizar (def: '')
@param aDBFSTJ Array Estrutura dos campos para a tabela temporária
@param aFieldsSTJ Array Campos para criar a tabela temporária STJ
@param aFieldsSTL Array Campos para criar a tabela temporária STL

@author Felipe Nathan Welter
@since 01/03/2013
@version P11
/*/
//-------------------------------------------------------------------
Static Function fGravaDados(cOrdem, aDBFSTJ, aFieldsSTJ, aFieldsSTL)

	Local cNGSEREF 	:= Alltrim(GETMV("MV_NGSEREF"))
	Local aServRef  := StrTokArr( cNGSEREF, ';' ) 
	Local cNGSECON 	:= Alltrim(GETMV("MV_NGSECON"))
	Local aServCon := StrTokArr( cNGSECON, ';' ) 
	Local cULMES	:= Alltrim(GetMv("MV_ULMES"))
	Local cQuery
	Local nX

	Default cOrdem := ''

	// Caso seja atualizacao de uma OS, apaga os registros da STJ e STL
	If !Empty(cOrdem)

		// Apaga STJ
		dbSelectArea(cTRBSTJ)
		If dbSeek(cOrdem)
			RecLock((cTRBSTJ),.F.)
			(cTRBSTJ)->(dbDelete())
			MsUnLock(cTRBSTJ)
		EndIf

		// Apaga STL
		dbSelectArea(cTRBSTL)
		dbSeek(cOrdem)
		While (cTRBSTL)->TL_ORDEM == cOrdem
			RecLock((cTRBSTL),.F.)
			(cTRBSTL)->(dbDelete())
			MsUnLock(cTRBSTL)
			(cTRBSTL)->(dbSkip())
		EndDo
	EndIf

	//STJ
	#IFDEF TOP
	cQuery := " SELECT "

	For nX := 1 To Len(aFieldsSTJ)
		cQuery += aFieldsSTJ[nX]+", "
	Next nX

	//Preenche a variavel cNGSEREF com todos os serviços do parametro MV_NGSEREF
	If !Empty( cNGSEREF )
		For nX := 1 To Len(aServRef)
			If nX == 1
				cNGSEREF := "'"+aServRef[nX]+"'"
			Else
				cNGSEREF += ",'"+aServRef[nX]+"'"
			EndIf
		Next nX
	Else
	
		cNGSEREF := "' '"
	
	EndIf
	
	//Preenche a variavel cNGSECON com todos os serviços do parametro MV_NGSECON
	If !Empty(cNGSECON)
	
		For nX := 1 To Len(aServCon)
			If nX == 1
				cNGSECON := "'"+aServCon[nX]+"'"
			Else
				cNGSECON += ",'"+aServCon[nX]+"'"
			EndIf
		Next nX
	
	Else
	
		cNGSECON := "' '"
	
	EndIf

	cQuery += " '' AS OK,"
	cQuery += " R_E_C_N_O_ AS RECNO,"
	cQuery += "        TJ_CUSTMDO + TJ_CUSTMAT + TJ_CUSTMAA + TJ_CUSTMAS + TJ_CUSTTER AS CUSTO"
	cQuery += " FROM "+RetSqlName("STJ")+" STJ "
	cQuery += " WHERE "
	cQuery += "  STJ.TJ_FILIAL = "+ValToSql(xFilial("STJ")) + " AND "
	cQuery += "  STJ.TJ_TERMINO = 'S' AND STJ.TJ_SITUACA = 'L' AND "
	cQuery += "  STJ.TJ_SERVICO NOT IN ("+ cNGSEREF +","+ cNGSECON +") AND"
	cQuery += "  STJ.TJ_FATURA = '1' AND (STJ.TJ_APROPRI = '2' OR STJ.TJ_APROPRI = '') AND"
	cQuery += "  STJ.TJ_DTORIGI > "+DTOS(GetMv("MV_ULMES"))+" AND "
	If !Empty(cOrdem)
		cQuery += "  STJ.TJ_ORDEM = "+ValToSql(cOrdem)+" AND "
	EndIf

	cQuery += "  STJ.D_E_L_E_T_ <> '*' "
	SqlToTRB(cQuery,aDBFSTJ,cTRBSTJ)
	#ELSE
	dbSelectArea("STJ")
	dbSetOrder(01)
	dbSeek(xFilial("STJ")+If(Empty(cOrdem),'',cOrdem))
	While STJ->(!Eof()) .And. STJ->TJ_FILIAL == xFilial("STJ") .And. If(Empty(cOrdem),.T.,STJ->TJ_ORDEM == cOrdem)
		If STJ->TJ_TERMINO == 'S' .And. STJ->TJ_SITUACA == 'L' .And.;
		AllTrim(STJ->TJ_SERVICO) != cNGSEREF .And. AllTrim(STJ->TJ_SERVICO) != cNGSECON .And.;
		STJ->TJ_FATURA == '1' .And. (Empty(STJ->TJ_APROPRI) .Or. STJ->TJ_APROPRI == '2') .And.;
		STJ->TJ_DTORIGI > cULMES
			RecLock(cTRBSTJ,.T.)
			For nX := 1 To Len(aFieldsSTJ)
				&("(cTRBSTJ)->"+aFieldsSTJ[nX]) := &("STJ->"+aFieldsSTJ[nX])
			Next nX
			(cTRBSTJ)->CUSTO := STJ->(TJ_CUSTMDO + TJ_CUSTMAT + TJ_CUSTMAA + TJ_CUSTMAS + TJ_CUSTTER)
			(cTRBSTJ)->RECNO := STJ->(RecNo())
			(cTRBSTJ)->(MsUnLock())
		EndIf
		STJ->(dbSkip())
	EndDo
	#ENDIF

	//STL
	dbSelectArea(cTRBSTJ)
	If(Empty(cOrdem),dbGoTop(),dbSeek(cOrdem))
	While (cTRBSTJ)->(!Eof()) .And. If(Empty(cOrdem),.T.,(cTRBSTJ)->TJ_ORDEM == cOrdem)
		dbSelectArea("STL")
		dbSetOrder(01)
		dbSeek(xFilial("STL")+(cTRBSTJ)->TJ_ORDEM)
		While STL->(!Eof()) .And. (cTRBSTJ)->TJ_ORDEM == STL->TL_ORDEM
			RecLock(cTRBSTL,.T.)
			For nX := 1 To Len(aFieldsSTL)
				If aFieldsSTL[nX] == "TL_TIPOREG"
					(cTRBSTL)->TL_TIPOREG := NGRETSX3BOX("TL_TIPOREG",STL->TL_TIPOREG)
				Else
					&("(cTRBSTL)->"+aFieldsSTL[nX]) := &("STL->"+aFieldsSTL[nX])
				EndIf
			Next nX
			(cTRBSTL)->RECNO := STL->(RecNo())
			(cTRBSTL)->(MsUnLock())
			STL->(dbSkip())
		EndDo
		(cTRBSTJ)->(dbSkip())
	EndDo

Return Nil

//-------------------------------------------------------------------
/*/{Protheus.doc} fGraficoSTL
Funcao que monta grafico de custos em painel.
@param oPanel painel para montagem (usar como referencia)
@author Felipe Nathan Welter
@since 01/03/2013
@version P11
/*/
//-------------------------------------------------------------------
Static Function fGraficoSTL(oPanel)

	//Cria Grafico em Barras
	oFWChrtSTL := FWChartFactory():New()
	oFWChrtSTL := oFWChrtSTL:getInstance( BARCHART ) // BARCHART(0) para barras
	oFWChrtSTL :Init( oPanel )
	oFWChrtSTL :SetTitle(STR0009, CONTROL_ALIGN_LEFT) //"Custos dos Insumos"
	oFWChrtSTL :SetLegend( CONTROL_ALIGN_BOTTOM )
	oFWChrtSTL :SetMask(MV_SIMB1+" *@*")
	oFWChrtSTL :SetPicture("@E 999,999,999.99")

	oFWChrtSTL :AddSerie(NGRETTITULO("TJ_CUSTMDO"),(cTRBSTJ)->TJ_CUSTMDO)
	oFWChrtSTL :AddSerie(NGRETTITULO("TJ_CUSTMAT"),(cTRBSTJ)->TJ_CUSTMAT)
	oFWChrtSTL :AddSerie(NGRETTITULO("TJ_CUSTMAA"),(cTRBSTJ)->TJ_CUSTMAA)
	oFWChrtSTL :AddSerie(NGRETTITULO("TJ_CUSTMAS"),(cTRBSTJ)->TJ_CUSTMAS)
	oFWChrtSTL :AddSerie(NGRETTITULO("TJ_CUSTTER"),(cTRBSTJ)->TJ_CUSTTER)

	//Controi o Grafico
	oFWChrtSTL:Build()

Return Nil

//-------------------------------------------------------------------
/*/{Protheus.doc} MNTA386ATU
Carrega e atualiza os custos dos insumos a partir do backoffice.

@param oMarkSTJ   Objeto MarkBrowse das ordens de serviço
@param oBrwSTL    Objeto Browse dos insumos
@param aDBFSTJ    Array Estrutura dos campos para a tabela temporária
@param aFieldsSTJ Array Campos para criar a tabela temporária STJ
@param aFieldsSTL Array Campos para criar a tabela temporária STL
@param oObjTQN    Objeto Browse dos abastecimentos

@author Felipe Nathan Welter
@since 26/02/2013
@version P11
/*/
//-------------------------------------------------------------------
Static Function MNTA386ATU(oMarkSTJ, oBrwSTL, aDBFSTJ, aFieldsSTJ, aFieldsSTL, oObjTQN )

	Local aArea    := GetArea()
	Local aAreacSTJ:= (cTRBSTJ)->(GetArea())
	Local cMarca   := oMarkSTJ:Mark()
	Local lInverte := oMarkSTJ:IsInvert()
	Local lRet     := .F.
	Local nQtd     := 0

	(cTRBSTJ)->( dbGoTop() )
	While (cTRBSTJ)->(!Eof())
		If oMarkSTJ:IsMark(cMarca)
			lRet := NGMUAtuCus((cTRBSTJ)->TJ_ORDEM,.T.) // Atualiza o custo da OS
			If lRet
				fGravaDados((cTRBSTJ)->TJ_ORDEM,aDBFSTJ,aFieldsSTJ, aFieldsSTL) // Repassa a gravacao
				nQtd++
			EndIf
		EndIf
		(cTRBSTJ)->( dbSkip() )
	End

	If nQtd > 0 
		MsgInfo(STR0010+CRLF+STR0011+cValToChar(nQtd),STR0007) //'Ordens de serviço atualizadas.' ## 'Total de registros: ' ## 'Atualização de Custos'
	ElseIf oObjTQN:LogicLen() == 0
		MsgInfo(STR0012,STR0007) //'Nenhum item foi marcado para atualização.' ## 'Atualização de Custos'
	EndIf

	(cTRBSTJ)->(RestArea(aAreacSTJ))
	oMarkSTJ:OnChange()
	oMarkSTJ:Refresh()
	oBrwSTL :Refresh()

	RestArea( aArea )

Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} ModelDef
Montagem do Model.
@author Felipe Nathan Welter
@since 26/02/2013
@version P11
/*/
//-------------------------------------------------------------------
Static Function ModelDef()
Return Nil

//-------------------------------------------------------------------
/*/{Protheus.doc} ViewDef
Montagem da View.
@author Felipe Nathan Welter
@since 26/02/2013
@version P11
/*/
//-------------------------------------------------------------------
Static Function ViewDef()
Return Nil

//-------------------------------------------------------------------
/*/{Protheus.doc} fAtuAbast

Atualiza os registros relacionados a abastecimentos.

@param oObjTQN  Objeto Browse dos abastecimentos

@author Tainã Alberto Cardoso
@since 22/10/2019
@version P12
/*/
//-------------------------------------------------------------------
Static Function fAtuAbast(oObjTQN)

	Local cULMES	:= dToS(SuperGetMv("MV_ULMES"))
	Local cProdD3   := ''
	Local cLocalD3  := ''
	Local aProdAtt  := {}
	Local cAliasTQN := GetNextAlias()

	BeginSQL Alias cAliasTQN

		SELECT TQN.R_E_C_N_O_ nRecTQN, SD3.D3_COD, SD3.D3_LOCAL
			FROM %table:TQN% TQN
			JOIN %table:SD3% SD3
				ON SD3.D3_NUMSEQ = TQN.TQN_NUMSEQ AND SD3.D3_FILIAL = %xFilial:SD3%

			WHERE	TQN.TQN_FILIAL = %xFilial:TQN%
				AND TQN.TQN_DTABAS > %exp:cULMES%
				AND TQN.TQN_NUMSEQ <> ''
				AND TQN.%NotDel%
				AND SD3.%NotDel%
	EndSQL

	While !Eof()

		cProdD3  := (cAliasTQN)->D3_COD
		cLocalD3 := (cAliasTQN)->D3_LOCAL
		
		If !Empty(cProdD3) .And. aScan(aProdAtt, {|x| x[1] + x[2] == cProdD3 + cLocalD3 }) == 0
			
			//Adicionado o Produto no Array para nao chamar em duplicidade o produto + almoxarifado
			aAdd(aProdAtt,{cProdD3 , cLocalD3})
			//Atualiza o Custo do Produto
			NGMUStoLvl(cProdD3, cLocalD3)

		EndIf

		DbSelectArea("SB2")
		DbSetOrder(1)
		If DbSeek( xFilial("SB2") + cProdD3 + cLocalD3 )
			
			dbSelectArea("TQN")
			dbGoTo((cAliasTQN)->nRecTQN)
			
			RecLock("TQN", .F.)
			TQN->TQN_VALUNI := SB2->B2_CM1
			TQN->TQN_VALTOT := TQN->TQN_VALUNI * TQN->TQN_QUANT
			MsUnLock()

		EndIf

		dbSelectArea(cAliasTQN)
		dbSkip()
		
	End

	(cAliasTQN)->( dbCloseArea() )

	oObjTQN:Refresh(.T.)

Return Nil

//---------------------------------------------------------------------
/*/{Protheus.doc} fFieldCol
Define objeto das colunas

@return oColuna Objeto Objeto da Coluna

@param cData Caracter Indica a busca do valor do campo
@param cAlign Caracter Indica o alinhamento do campo (CONTROL_ALIGN_RIGHT ou CONTROL_ALIGN_LEFT) (Somente obrigatório quando campo diferente de SX3)
@param cTitle Caracter Indica o titulo do campo (Somente obrigatório quando campo diferente de SX3)
@param cTipe Caracter Indica o tipo do campo (Somente obrigatório quando campo diferente de SX3)
@param nTam Numerico Indica o tamanho do campo (Somente obrigatório quando campo diferente de SX3)
@param cPicture Caracter Indica a Picture do campo (Somente obrigatório quando campo diferente de SX3)

@author Tainã Alberto Cardoso
@since 24/10/2019
/*/
//---------------------------------------------------------------------
Static Function fFieldCol( cData ,cAlign , cTitle , cTipe , nTam , cPicture )

	Local oColuna

	//Adiciona as colunas do markbrowse
	oColuna := FWBrwColumn():New()//Cria objeto
		oColuna:SetAlign( cAlign )//Define alinhamento
		oColuna:SetData( &(cData ) )//Define valor

		oColuna:SetEdit( .F. )//Indica se é editavel
		oColuna:SetTitle( cTitle )//Define titulo
		oColuna:SetType( cTipe )//Define tipo
		oColuna:SetSize( nTam )//Define tamanho
		oColuna:SetPicture( cPicture ) //Define picture

Return oColuna


//---------------------------------------------------------------------
/*/{Protheus.doc} fLoadQry
Define os registros que serão apresentados no Browse

@author Tainã Alberto Cardoso
@since 24/10/2019
/*/
//---------------------------------------------------------------------
Static Function fLoadQry(cQueryTqn)

	Local cULMES	:= dToS(SuperGetMv("MV_ULMES"))

	cQueryTqn := " SELECT TQN_NABAST, TQN_PLACA, TQN_FROTA, TQN_POSTO, TQN_LOJA, "
	cQueryTqn += " TQN_DTABAS, TQN_HRABAS, TQN_CODCOM, TQN_QUANT, "
	cQueryTqn += " TQN_VALUNI, TQN_VALTOT FROM " + RetSqlName("TQN") + " TQN "
	cQueryTqn += " JOIN " + RetSqlName("SD3") + " SD3 "
	cQueryTqn += " ON SD3.D3_NUMSEQ = TQN.TQN_NUMSEQ AND SD3.D3_FILIAL = '" +xFilial("SD3")+ "' "
	cQueryTqn += " WHERE TQN.TQN_FILIAL = '" + xFilial("TQN") + " ' "
	cQueryTqn += " AND TQN.TQN_DTABAS > '" + cULMES + " '"
	cQueryTqn += " AND TQN.TQN_NUMSEQ <> '' "
	cQueryTqn += " AND SD3.D_E_L_E_T_ <> '*' "
	cQueryTqn += " AND TQN.D_E_L_E_T_ <> '*' "

Return cQueryTqn

//---------------------------------------------------------------------
/*/{Protheus.doc} fCampBrow
Define os campos que serão apresentados no Browse

@author Tainã Alberto Cardoso
@since 24/10/2019
/*/
//---------------------------------------------------------------------
Static Function fCampBrow()

	Local aColLis := {}

	aAdd( aColLis , fFieldCol("{ | | " + cAliasAbas + "->TQN_NABAST }" , CONTROL_ALIGN_LEFT , STR0013 , "N" , TAMSX3( "TQN_NABAST" )[1] , X3Picture('TQN_NABAST') ) ) //"Número Abastecimento"
	aAdd( aColLis , fFieldCol("{ | | StoD(" + cAliasAbas + "->TQN_DTABAS) }" , CONTROL_ALIGN_LEFT , STR0014 , "D" , 10 , "99/99/9999" ) ) //"Data"
	aAdd( aColLis , fFieldCol("{ | | " + cAliasAbas + "->TQN_HRABAS }" , CONTROL_ALIGN_LEFT , STR0015 , "C" , 5 , "99:99" ) ) //"Hora"
	aAdd( aColLis , fFieldCol("{ | | " + cAliasAbas + "->TQN_PLACA }"  , CONTROL_ALIGN_LEFT , STR0016 , "C" , TAMSX3( "TQN_PLACA" )[1] , X3Picture('TQN_PLACA') ) ) //"Placa"
	aAdd( aColLis , fFieldCol("{ | | " + cAliasAbas + "->TQN_FROTA }"  , CONTROL_ALIGN_LEFT , STR0017 , "C" , TAMSX3( "TQN_FROTA" )[1] , X3Picture('TQN_FROTA')  ) ) //"Frota"
	aAdd( aColLis , fFieldCol("{ | | " + cAliasAbas + "->TQN_POSTO }"  , CONTROL_ALIGN_LEFT , STR0018 , "C" , TAMSX3( "TQN_POSTO" )[1] , X3Picture('TQN_POSTO') ) ) //"Posto"
	aAdd( aColLis , fFieldCol("{ | | " + cAliasAbas + "->TQN_LOJA }"   , CONTROL_ALIGN_LEFT , STR0019 , "C" , TAMSX3( "TQN_LOJA" )[1] , X3Picture('TQN_LOJA') ) ) //"Loja"
	aAdd( aColLis , fFieldCol("{ | | Posicione('SA2',1,xFilial('SA2') + " + cAliasAbas + "->TQN_POSTO + " + cAliasAbas + "->TQN_LOJA ,'A2_NREDUZ') }" , ;
			CONTROL_ALIGN_LEFT , STR0020 , "C" , TAMSX3( "A2_NREDUZ" )[1] , X3Picture('A2_NREDUZ') ) ) //"Descrição"
	aAdd( aColLis , fFieldCol("{ | | " + cAliasAbas + "->TQN_CODCOM }" , CONTROL_ALIGN_LEFT  , STR0021 , "C" , TAMSX3( "TQN_CODCOM" )[1] , X3Picture('TQN_CODCOM') ) ) //"Combustivel"
	aAdd( aColLis , fFieldCol("{ | | " + cAliasAbas + "->TQN_QUANT }"  , CONTROL_ALIGN_RIGHT , STR0022 , "N" , TAMSX3( "TQN_QUANT" )[1]  , X3Picture('TQN_QUANT') ) ) //"Quantidade"
	aAdd( aColLis , fFieldCol("{ | | " + cAliasAbas + "->TQN_VALUNI }" , CONTROL_ALIGN_RIGHT , STR0023 , "N" , TAMSX3( "TQN_VALUNI" )[1] , X3Picture('TQN_VALUNI') ) ) //"Valor Unitário"
	aAdd( aColLis , fFieldCol("{ | | " + cAliasAbas + "->TQN_VALTOT }" , CONTROL_ALIGN_RIGHT , STR0024 , "N" , TAMSX3( "TQN_VALTOT" )[1] , X3Picture('TQN_VALTOT') ) ) //"Valor Total"

Return aColLis

//---------------------------------------------------------------------
/*/{Protheus.doc} fAtuCust
Chamada das funções para atualizar os custos

@param oMarkSTJ   Objeto MarkBrowse das ordens de serviço
@param oBrwSTL    Objeto Browse dos insumos
@param aDBFSTJ    Array Estrutura dos campos para a tabela temporária
@param aFieldsSTJ Array Campos para criar a tabela temporária STJ
@param aFieldsSTL Array Campos para criar a tabela temporária STL
@param oObjTQN    Objeto Browse dos abastecimentos


@author Tainã Alberto Cardoso
@since 29/10/2019
/*/
//---------------------------------------------------------------------
Static Function fAtuCust(oMarkSTJ, oBrwSTL, aDBFSTJ,aFieldsSTJ, aFieldsSTL, oObjTQN )

	//Processa as Ordens de Serviço selecionadas
	Processa({|lEnd| MNTA386ATU(oMarkSTJ, oBrwSTL,aDBFSTJ, aFieldsSTJ, aFieldsSTL, oObjTQN)},STR0026) //"Aguarde... Atualizando O.S."
	
	//Processa as Ordens de Serviço selecionadas
	Processa({|lEnd| fAtuAbast(oObjTQN)},STR0027) //"Aguarde... Atualizando abastecimentos."

Return Nil

