#INCLUDE "PROTHEUS.CH"
#INCLUDE "MDTA990.CH"

//Variaveis de List
#DEFINE _POS_LIST_ROTINA_ 1
#DEFINE _POS_LIST_DESCRI_ 2

//Variaveis de Mark
#DEFINE _POS_MARK_ROTINA_ 1
#DEFINE _POS_MARK_OK_     2
#DEFINE _POS_MARK_CODIGO_ 3
#DEFINE _POS_MARK_DESCRI_ 4

//Variaveis do SX5
#DEFINE nPOSCHAV 3
#DEFINE nPOSDESC 4

//---------------------------------------------------------------------
/*/{Protheus.doc} MDTA990
Função para cadastro das restrições de acesso de cada rotina

@return

@sample
MDTA990()

@author Jackson Machado
@since 21/08/2012
@version 1.0
/*/
//---------------------------------------------------------------------
Function MDTA990()

	//-------------------------------------------------
	// Armazena variaveis p/ devolucao (NGRIGHTCLICK)
	//-------------------------------------------------
	Local aNGBEGINPRM := NGBEGINPRM( )

    //------------------
    // Variaveis locais
    //------------------
    Local nX
    Local cTemp      := "", cGrupos := ""
    Local lConfirm   := .F.
	Local nSX5
	Local aSX5		 := {}

	//Code-blocks
	Local bChange

    //Variaveis de TRB
    Local cAliTRB    := GetNextAlias()

    //Criacao das colunas dos browses
	Local aTemp      := {}, aDBF := {}
	Local aColLis    := {}, aColMkr := {}
	Local aCamLis    := { "TKP_ROTINA"  , "TKP_DESCRI" }
	Local aCamMkr    := { "CHAVE"   	, "DESCRI"  }

	//Variaveis de tamanho de tela e objetos
	Local aSize      := {}, aObjects := {}, aInfo := {}, aPosObj := {}

	//Objetos locais
	Local oLayer
	Local oDialog, oPnlPai, oPanelLeft
	Local oSplitter, oColuna, oPanelRight
	Local oTempTRB

	//-------------------
    // Variaveis private
    //-------------------

	//Variaveis de controle de Marcacao
	Private cMarca   := GetMark()
	Private lInvert  := .F.
	Private aVETINR  := {}

	//Variaveis de controle das listagens
	Private aMark := {}, aList := {}

	//Objetos privates
	Private oMark, oList

	If AMiIn( 35 ) // Somente autorizado para SIGAMDT

		//Definicao de tamanho de tela e objetos
		aSize := MsAdvSize(,.f.,430)
		Aadd(aObjects,{030,030,.t.,.t.})
		Aadd(aObjects,{100,100,.t.,.t.})
		aInfo := {aSize[1],aSize[2],aSize[3],aSize[4],0,0}
		aPosObj := MsObjSize(aInfo, aObjects,.t.)

		For nX := 1 To Len(aCamLis)//Percorre array de campos para o listbox
			aAdd( aColLis , fFieldCol("{|| aList[oList:At()]["+cValToChar(nX)+"] }", aCamLis[nX]) )
		Next nX

		//Percorre array de campos para o markbrowse e adiciona os campos no DBF do TRB
		aAdd(aDBF,{ "OK" , "C" , 02 , 0 })
		For nX := 1 To Len(aCamMkr)
			aAdd( aColMkr , fFieldCol("{|| " + cAliTRB + "->" + AllTrim(aCamMkr[nX]) + " }", "X5_" + aCamMkr[nX]) )
			aAdd(aDBF,{ aCamMkr[nX] , "C" , TAMSX3("X5_" + aCamMkr[nX])[1] , TAMSX3("X5_" + aCamMkr[nX])[2] })
		Next nX

		//Alimenta os arrays
		dbSelectArea("TKP")
		dbSetOrder(1)
		dbGoTop()
		While TKP->(!Eof())
			//Caso rotina não tenha sido adicionada, adiciona no array de listagem
			If aScan(aList,{|x| x[_POS_LIST_ROTINA_] == TKP->TKP_ROTINA }) == 0
				aAdd(aList,{TKP->TKP_ROTINA, TKP->TKP_DESCRI})
			Endif
			aTemp := StrTokArr(TKP->TKP_GRUPOS,";")//Transforma grupos que estam em formato de string, separados por ';', em um array
			aSX5  := FwGetSX5("P1")
			For nSX5 := 1 To Len( aSX5 )
				//Caso funcao esteja no array, traz marcada
				If aScan(aTemp,{|x| x == AllTrim(aSX5[ nSX5 , nPOSCHAV ]) }) > 0
					cTemp := cMarca
				Else
					cTemp := ""
				Endif
				//Adiciona no array do markbrowse, de acordo com a sua marcacao, utilizada funcao X5Descri para retornar a descricao traduzida
				aAdd(aMark,{TKP->TKP_ROTINA,cTemp,aSX5[ nSX5 , nPOSCHAV ],aSX5[ nSX5 , nPOSDESC ]})
			Next nSX5
			TKP->(dbSkip())
		End

		oTempTRB := FWTemporaryTable():New( cAliTRB, aDBF )
		oTempTRB:AddIndex( "1", {"CHAVE"} )
		oTempTRB:Create()

		//Alimenta primeiro array do mark
		fTrocaLinha(If(Len(aList) > 0,aList[1][_POS_LIST_ROTINA_],""),cAliTRB)//Caso tenha rotinas traz a primeira, caso nao passa vazio

		//---------------
		// Monta janela
		//---------------
		DEFINE MSDIALOG oDialog TITLE OemToAnsi(STR0001) From aSize[7],0 To aSize[6],aSize[5] OF oMainWnd PIXEL//"Restrições"

			//Cria painel para adequacao
			oPnlPai := TPanel():New(00,00,,oDialog,,,,,,00,00,.F.,.T.)
				oPnlPai:Align := CONTROL_ALIGN_ALLCLIENT

				//Cria o layer pelo metodo construtor
				oLayer := FWLayer():New()

				//Inicia o Layer
				oLayer:Init(oPnlPai,.T.)

				//Cria linha fixa para tamanho e adequacao de tela
				oLayer:addLine("LinhaFixa",95,.T.)

				//Cria as colunas do Layer
				oLayer:addCollumn("ColunaList",50,.F.,"LinhaFixa")
				oLayer:addCollumn("ColunaMark",50,.F.,"LinhaFixa")

				//Adiciona Janelas as colunas
				oLayer:addWindow("ColunaList","JanelaList",STR0002 ,100,.F.,.F.,{|| },"LinhaFixa",{|| })//"Rotinas"
				oLayer:addWindow("ColunaMark","JanelaMark",STR0003 ,100,.F.,.F.,{|| },"LinhaFixa",{|| })//"Especialidades SESMT"

				//Atribui a janela do listbox
				oPanelLeft := oLayer:getWinPanel("ColunaList","JanelaList","LinhaFixa")

				//Cria um browse de listagem
				oList := FwBrowse():New()
					oList:SetDataArray()//Define que a utilizacao é por array
					oList:SetColumns(aColLis)//Define as colunas preestabelecidas
					oList:SetArray(aList)//Define o array a ser utilizado
					oList:SetOwner(oPanelLeft)//Define o objeto pai
					bChange := {|| fTrocaLinha(aList[oList:At()][_POS_LIST_ROTINA_],cAliTRB) }//Bloco de codigo para troca de linha
					oList:SetChange(bChange)//Define o bloco de codigo a ser executado na troca de linha
					oList:DisableReport()//Desabilita botao de impressao
					oList:DisableConfig()//Desabilita botao de configuracao
					oList:Activate()//Ativa o browse

				//Atribui a janela do markbrowse
				oPanelRight := oLayer:getWinPanel("ColunaMark","JanelaMark","LinhaFixa")

				//Cria um browse de marcacoes
				oMark := FwBrowse():New()
					oMark:AddMarkColumns(	{|| If((cAliTRB)->OK == cMarca,"LBTIK","LBNO")},;
											{|| fMark(cMarca,lInvert,,cAliTRB ), oMark:Refresh() },;
											{|| fMark(cMarca,lInvert,.T.,cAliTRB),oMark:Refresh(.T.) } ) //Coluna de marcacao
					oMark:SetColumns(aColMkr)//Define as colunas preestabelecidas
					oMark:SetAlias(cAliTRB)//Define alias de utilizacao
					oMark:SetOwner(oPanelRight)//Define o objeto pai
					oMark:SetDataTable()//Define que a utilizacao é por tabela
					oMark:DisableReport()//Desabilita botao de impressao
					oMark:DisableConfig()//Desabilita botao de configuracao
					oMark:Activate()//Ativa o browse

		ACTIVATE MSDIALOG oDialog ON INIT EnchoiceBar(oDialog,{|| lConfirm := .T., oDialog:End() },{|| lConfirm := .F., oDialog:End() }) CENTERED

		If lConfirm//Caso confirme a tela
			cTemp   := ""
			cGrupos := ""

			//Percorre o array de marcacoes
			For nX := 1 To Len(aMark)
				If cTemp <> aMark[nX][_POS_MARK_ROTINA_] .AND. !Empty(cTemp) //Se trocar a rotina ao precorrer o array, grava
					dbSelectArea("TKP")
					dbSetOrder(1)
					If dbSeek(xFilial("TKP")+cTemp)
						RecLock("TKP",.F.)
						TKP->TKP_GRUPOS := cGrupos
						TKP->(MsUnLock())
					Endif
					//Salva e zera variaveis de controle
					cTemp   := aMark[nX][_POS_MARK_ROTINA_]
					cGrupos := ""
				ElseIf Empty(cTemp)//Caso for primeira vez, salva a primeira rotina
					cTemp   := aMark[nX][_POS_MARK_ROTINA_]
				Endif
				If aMark[nX][_POS_MARK_OK_] == cMarca//Se tiver marcado, grava na variavel de controle
					cGrupos += AllTrim(aMark[nX][_POS_MARK_CODIGO_])+";"
				Endif
			Next nX
			//Realiza a ultima gravacao ao sair do For
			dbSelectArea("TKP")
			dbSetOrder(1)
			If dbSeek(xFilial("TKP")+cTemp)
				RecLock("TKP",.F.)
				TKP->TKP_GRUPOS := cGrupos
				TKP->(MsUnLock())
			Endif
		Endif

		//Exclui tabela temporaria
		oTempTRB:Delete()
	
	EndIf

	//-------------------------------------------------
	// Devolve variaveis armazenadas (NGRIGHTCLICK)
	//-------------------------------------------------
	NGRETURNPRM(aNGBEGINPRM)

Return
//---------------------------------------------------------------------
/*/{Protheus.doc} fTrocaLinha
Funcao chamada na troca de linhas da listagem das rotinas

@return .T.

@sample
fTrocaLinha()

@author Jackson Machado
@since 21/08/2012
/*/
//---------------------------------------------------------------------
Static Function fTrocaLinha(cRotina,cAlias)

	//Limpa o Alias para receber os novos registros
	dbSelectArea(cAlias)
	ZAP

	//Verifica se a rotina possui registros salvos
	If (nPos := aScan(aMark,{|x| x[_POS_MARK_ROTINA_] == cRotina})) > 0
		While nPos <= Len(aMark) .And. aMark[nPos][_POS_MARK_ROTINA_] == cRotina
			//Enquanto a posição seja menor que o tamanho do array e seja a mesma rotina
			RecLock(cAlias,.T.)
			(cAlias)->OK        := aMark[nPos][_POS_MARK_OK_]
			(cAlias)->CHAVE  	:= aMark[nPos][_POS_MARK_CODIGO_]
			(cAlias)->DESCRI 	:= aMark[nPos][_POS_MARK_DESCRI_]
			(cAlias)->(MsUnLock())
			nPos ++
		End
	Endif

	If Type("oMark") == "O"//Caso o markbrowse exista, atualiza ele
		oMark:Refresh(.T.)
	Endif

Return .T.

//---------------------------------------------------------------------
/*/{Protheus.doc} fMark
Inverte marcacoes

@return .T.

@sample
fMark()

@author Jackson Machado
@since 21/08/2012
/*/
//---------------------------------------------------------------------
Static Function fMark(cMarca,lInvert,lAll,cAlias)
	Local nReg, nPos
	Local aArea := GetArea()

	Default lAll := .F.

	If lAll//Caso for no bAllMark
		nReg := (cAlias)->(Recno())
		dbSelectArea(cAlias)
		dbGoTop()
		While !Eof()
			//Verifica todas as posicoes no array, invertendo as marcacoes
			If (nPos := aScan(aMark,{|x| x[_POS_MARK_ROTINA_] == aList[oList:At()][_POS_LIST_ROTINA_] .AND. ;
											x[_POS_MARK_CODIGO_] == (cAlias)->CHAVE })) > 0
				aMark[nPos,_POS_MARK_OK_] := If(Empty((cAlias)->OK),cMarca,"  ")
			Endif
			RecLock(cAlias,.F.)
			(cAlias)->OK := If(Empty((cAlias)->OK),cMarca,"  ")
			(cAlias)->(MsUnLock())
			(cAlias)->(dbSkip())
		End
		dbSelectArea(cAlias)
		dbGoTo(nReg)
	Else
		//Caso for no bMark
		//Verifica a posicao especifica no array, invertendo a marcacao
		If (nPos := aScan(aMark,{|x| x[_POS_MARK_ROTINA_] == aList[oList:At()][_POS_LIST_ROTINA_] .AND. ;
										x[_POS_MARK_CODIGO_] == (cAlias)->CHAVE })) > 0
			aMark[nPos,_POS_MARK_OK_] := If(Empty((cAlias)->OK),cMarca,"  ")
		Endif
		RecLock(cAlias,.F.)
		(cAlias)->OK := If(Empty((cAlias)->OK),cMarca,"  ")
		(cAlias)->(MsUnLock())
	Endif
	RestArea(aArea)
Return .T.
//---------------------------------------------------------------------
/*/{Protheus.doc} fFieldCol
Define objeto das colunas

@return .T.

@sample
fFieldCol()

@author Jackson Machado
@since 21/08/2012
/*/
//---------------------------------------------------------------------
Static Function fFieldCol( cData, cCampo )

	Local oColuna
	Local cTipo   := GetSx3Cache( cCampo, 'X3_TIPO' )
	Local aTamCpo := TamSX3( cCampo )
	Local cTitulo := Alltrim(Posicione( 'SX3' , 2 , cCampo , 'X3Titulo()' ))

	//Adiciona as colunas do markbrowse
	oColuna := FWBrwColumn():New()//Cria objeto
	oColuna:SetAlign( If(cTipo== "N",CONTROL_ALIGN_RIGHT,CONTROL_ALIGN_LEFT) )//Define alinhamento
	oColuna:SetData( &(cData) )//Define valor

	oColuna:SetEdit( .F. )//Indica se é editavel
	oColuna:SetTitle( If( "CHAVE" $ UPPER( cTitulo ), STR0004, cTitulo ) )//Define titulo###"Código"
	oColuna:SetType( cTipo )//Define tipo
	oColuna:SetSize( aTamCpo[1] + aTamCpo[2] )//Define tamanho
	oColuna:SetPicture( X3Picture(cCampo) ) //Define picture

Return oColuna
