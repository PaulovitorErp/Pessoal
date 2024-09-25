#INCLUDE "SGAA111.CH"
#INCLUDE "PROTHEUS.CH"

Static __nLastInd := 0 // Indica ultimo indice adicionado (Marcados)

//---------------------------------------------------------------------
/*/{Protheus.doc} SGAA111
Programa para Multiplas Avaliacoes de Aspectos e Impactos Ambientais.

@param lAprov Define se o processo e de aprovacao.

@author Hugo R. Pereira
@since 19/10/2012
@version MP10
@return Nil
/*/
//---------------------------------------------------------------------
Function SGAA111(lAprov,aFiltroAsp)

	Local aNGBEGINPRM := NGBEGINPRM( ) // Armazena variaveis p/ devolucao [NGRIGHTCLICK]
	Local cPerg       := "SGA111"             // Grupo de Perguntas relacionado
	Local aReturn := {.F.,{}}

	Default lAprov := .F.

	Private _lActAprv	:= lAprov // Variavel de controle do processo [ Copia | Aprovacao ]
	Private lRevisa		:= If( _lActAprv , .F. , NGCADICBASE( "TAB_REVISA" , "A" , "TAB" , .F. ) )// Variavel de controle de revisao - Caso aprovação não repassa revisão

	InitPerg(cPerg) // Define perguntas

	If !Empty(aFiltroAsp)
		aReturn := MainBrw(,aFiltroAsp)
	ElseIf Pergunte(cPerg)
		aReturn := MainBrw(cPerg) // Apresenta browse principal
	Endif

	NGRETURNPRM(aNGBEGINPRM) // Devolve variaveis armazenadas [NGRIGHTCLICK]

Return aReturn

//---------------------------------------------------------------------
/*/{Protheus.doc} MainBrw
Programa para Multiplas Avaliacoes de Aspectos e Impactos Ambientais.

@param cPerg   Grupo de Perguntas relacionado.

@author Hugo R. Pereira
@since 19/10/2012
@version MP10
@return Nil
/*/
//---------------------------------------------------------------------
Static Function MainBrw(cPerg,aFiltroAsp)

	// Tela principal
	Local oWndBrw, oPnlBrw, oMrkAval
	Local oPnlPsq, oPnlMrk, oPnlTit
	Local oTempProc

	// Definicoes de tamanho
	Local nBrdMrg  := 10 // Borda entre o group e a window principal
	Local nBrdMrk  := 7  // Borda entre o markbrowse e a borda do group
	Local SeekArea := 35 // Espaco entre bottom markbrowse e o group. [Area Pesquisa]

	// Controle do processo
	Local lExecute := .F. // Controle de confirmacao do processo
	Local aIncons  := {}  // Array de controle de inconsistencias
	Local lResult  := .F. // Controle de resultado da consulta/pesquisa

	// Variaveis de objetos
	Local cMrkPsq   := Space(120) // Variavel do campo de pesquisa [Get]
	Local cRevisa   := Space(6)   // Variavel do campo de revisao [Get]
	Local cCbbInd   := ""         // Variavel do campo indices [Combobox]
	Local cTitleBrw := ""         // Titulo do processo em questao
	Local cTitlePrc := ""         // Titulo do processo em questao
	Local cMrkBrw   := GetMark()  // Marca utilizada pelo markbrowse

	// Definicoes da Tela
	Local aCoors    := MsAdvSize(,.f.,430) // Retorna limites da tela para a construcao da tela

	Local aTrbBrw   := CrtAllTrb() // Constroi tabelas temporarias para controle dos browses da consulta
	Local aBtnOpc   := {}

	Local oFontT    := TFont():New("Arial",,14,,.T.)

	Private aDesemps := {}

	Processa( {|| lResult := IncTrbBrw(aFiltroAsp) } ) // Inicia proceso de incremento das tabelas

	// Caso nao encontre nenhum registro
	If !lResult
		If ValType( oTempProc ) <> "U"
			oTempProc:Delete()
		EndIf
		Return {.F.,aDesemps}
	Endif

	SetInclui() // Define operacao como inclusao

	aCoors     := { aCoors[7], 0, aCoors[6], aCoors[5] }	// Tratamento para dimensoes da tela
	__nLastInd := Len(aTrbBrw[1][2])                     // Indica ultimo indice adiciona (Marcados)

	SetTitleBrw( @cTitleBrw, @cTitlePrc )

	Define MsDialog oWndBrw Title cTitleBrw From aCoors[1], aCoors[2] To aCoors[3], aCoors[4] Of oMainWnd Pixel

		oWndBrw:lEscClose := .F.

		// Painel Principal
		oPnlBrw       := TPanel():New( 0, 0, , oWndBrw, , , , , , 0, 0 )
		oPnlBrw:Align := CONTROL_ALIGN_ALLCLIENT

				oPnlPsq       := TPanel():New( 0, 0, , oPnlBrw, , , , , , 0, 34 )
				oPnlPsq:Align := CONTROL_ALIGN_TOP

				oPnlMrk       := TPanel():New( 0, 0, , oPnlBrw, , , , , , 0, 0 )
				oPnlMrk:Align := CONTROL_ALIGN_ALLCLIENT

						oPnlTit := TPanel():New( 0, 0, , oPnlMrk, , , , , RGB(67,70,87), 0, 13 )
						oPnlTit:Align := CONTROL_ALIGN_TOP

							TSay():New( 003, 002, {|| cTitlePrc }, oPnlTit, , oFontT, , , , .T., RGB(255,255,255) , , 200, 10 )

					// Markbrowse Avaliacoes
					oMrkAval := MsSelect():New( aTrbBrw[1][1], "TAB_OK", , aTrbBrw[1][3], , @cMrkBrw, , , , oPnlMrk )
					oMrkAval:oBrowse:lHasMark    := .T.
					oMrkAval:oBrowse:lCanAllMark := .T.
					oMrkAval:bMark               := {|| SetMrkAval( @cMrkBrw, @oMrkAval, 1 ) }
					oMrkAval:oBrowse:bAllMark    := {|| SetMrkAval( @cMrkBrw, @oMrkAval, 2 ) }
					oMrkAval:oBrowse:Align       := CONTROL_ALIGN_ALLCLIENT

					@ 001,330 To 030,670 Label STR0011 Of oPnlPsq Pixel
					// Cria area de pesquisa do markbrowse
					CrtPsqBrw(aTrbBrw[1][1], aTrbBrw[1][2], cCbbInd, @cMrkPsq, aCoors, {oPnlPsq, oMrkAval}, @cRevisa )

				oMrkAval:oBrowse:SetFocus()

				// Botoes especificos (EnchoiceBar)
				aBtnOpc   := {	{"BMPCONS", {|| VisDesemp((cAliasAval)->TAB_ORDEM, (cAliasAval)->TAB_CODASP, @cMrkBrw) }, STR0005 }, ; // "Visualizar"
									{"PARAMETROS", {|| ReBldCns(cPerg, @cMrkBrw, @oMrkAval) }, STR0008 } }												// "Parâmetros"

	Activate MsDialog oWndBrw On Init ( EnchoiceBar( oWndBrw, {|| SetOkBrw(cRevisa,@lExecute, oWndBrw) }, {|| oWndBrw:End() }, , aBtnOpc ) )

	// Se houve confirmacao do processos
	If lExecute
		// Se o processo e de aprovacao
		If _lActAprv

			// Processo de Aprovacao
			Processa( {|| aIncons := Sg111Aprov() } )

		Else

			// Processo de Gravacao
			Processa( {|| aIncons := Sg111Grava(cRevisa) } )

		Endif

		// Se houveram inconsistencias durante o processo
		If Len(aIncons) > 0
			ShowIncApv(aIncons)
		Endif

	Endif

	If ValType( oTempProc ) <> "U"
		oTempProc:Delete()
	EndIf

Return {lExecute,aDesemps}
//---------------------------------------------------------------------
/*/{Protheus.doc} SetTitleBrw
Define titulo e processo.

@param cTitleBrw  Titulo do browse.
@param cTitlePrc  Definicao do processo.

@author Hugo R. Pereira
@since 19/10/2012
@version MP10
@return Nil
/*/
//---------------------------------------------------------------------
Static Function SetTitleBrw( cTitleBrw, cTitlePrc )

	If _lActAprv
		cTitleBrw := STR0001 // "Aprovação de Avaliações Ambientais"
		cTitlePrc := STR0048 // "Selecione os itens a serem aprovados:"
	Else
		cTitleBrw := STR0002 // "Cópia de Avaliações Ambientais"
		cTitlePrc := STR0049 // "Selecione os itens a serem copiados:"
	Endif

Return

//---------------------------------------------------------------------
/*/{Protheus.doc} SetMrkAval

@param cMrkBrw  Marca utilizada pelo markbrowse [GetMark()].
@param oMrkAval Objeto markbrowse.
@param nAction  Define se a marcacao sera efetuada para todo o alias, ou apenas o registro atual.

@author Hugo R. Pereira
@since 19/10/2012
@version MP10
@return Nil
/*/
//---------------------------------------------------------------------
Static Function SetMrkAval( cMrkBrw, oMrkAval, nCall )

	Local aArea := {}

	Default nCall := 1

	dbSelectArea(cAliasAval)

	If nCall == 2

		aArea := GetArea()

		dbSelectArea(cAliasAval)
		dbSetOrder(1)
		dbGoTop()
		While !Eof()

			// Atualiza campos de controle de marcacao
			RecLock(cAliasAval, .F.)
			(cAliasAval)->TAB_OK   := If( Empty( (cAliasAval)->TAB_OK ),   cMrkBrw, Space(Len(cMrkBrw)) )
			(cAliasAval)->(MsUnlock())

			dbSelectArea(cAliasAval)
			(cAliasAval)->(dbSkip())

		End

		RestArea(aArea)

	Endif

	// Atualiza markbrowse
	oMrkAval:oBrowse:Refresh()

Return

//---------------------------------------------------------------------
/*/{Protheus.doc} SetOkBrw
Funcao de confirmacao da tela principal.

@param lExecute Variavel de controle para finalizacao da tela.
@param oWndBrw  Objeto principal [MsDialog].

@author Hugo R. Pereira
@since 19/10/2012
@version MP10
@return Nil
/*/
//---------------------------------------------------------------------
Static Function SetOkBrw( cRevisa, lExecute, oWndBrw )

	Local nSitMrk := SitMrk()

	lExecute := .F.

	If !( lRevisa .And. Empty( cRevisa ) )
		If !lExecute
			// Caso nao naja nenhum item marcado
			If Str(nSitMrk,1) $ "1/2"

				If nSitMrk == 1 .Or. MsgYesNo( STR0050 + CRLF + ; // "Nenhum item foi selecionado."
															STR0010 ) 			// "Deseja realmente prosseguir?"
					oWndBrw:End()
				Endif

			ElseIf _lActAprv .Or. MsgYesNo( STR0009 + CRLF + ;	// "As avaliações selecionadas serão movidas para histórico."
														STR0010)         	// "Deseja realmente prosseguir?"
				lExecute := .T.
				oWndBrw:End()

			Endif
		EndIf
	Else
		ShowHelpDlg( "ATENÇÃO" , { "Não foi informada a revisão." } , 1 , { "Para prosseguir é necessário informar a revisão na qual os Desempenhos estão vinculados." } , 1 )
	EndIf

Return

//---------------------------------------------------------------------
/*/{Protheus.doc} CrtPsqBrw
Cria area de pesquisa do markbrowse.

@param cAliasMrk Alias markbrowse.
@param aIndMrk   Indices de pesquisa do markbrowse.
@param cCbbInd   Variavel/String do combobox.
@param cMrkPsq   Variavel/String do campo de pesquisa.
@param aCoors    Dimensoes e posicoes da tela.
@param aObjs     Objetos pais.

@author Hugo R. Pereira
@since 19/10/2012
@version MP10
@return Nil
/*/
//---------------------------------------------------------------------
Static Function CrtPsqBrw( cAliasMrk, aIndMrk, cCbbInd, cMrkPsq, aCoors, aObjs , cRevisa )

	Local oGetPsq, oBtnPsq, oCbbInd
	Local oGetRev
	Local oFontT  := TFont():New("Arial",,14,,.F.)
	Local aTamObj := { 150, 40, 120 , 16 } // Define tamanho dos objetos descritos

	Local nColObj := 0 // Controle de tamanho do objeto
	Local nMrgObj := 3 // Espaco entre os objetos
	Local nColFim := ( aCoors[4]/2 ) - 10

	cCbbInd := aIndMrk[1] // Inicializa ComboBox

    //Cria campo para informar a nova revisão
	If lRevisa

		TSay():New( 012 , 002, {|| "Revisão" }, aObjs[1], , oFontT, , , , .T., CLR_HBLUE , , 200, 10 )

   		oGetPsq    := TGet():New( 10 , 30 , {|u| If(PCount() > 0, cRevisa := u, cRevisa) }, aObjs[1], aTamObj[4] , 09, "",;
								 		{|| ExistCpo( "TDR" , cRevisa ) } , , , , .T., , .T., , .T., /* When */, .F., .F., , .F., .F., "TDR" ,cRevisa, , , , .T.)

	EndIf

	// Campo de Pesquisa
	nColObj    += aTamObj[1] + nMrgObj + aTamObj[2]
	oGetPsq    := TGet():New( 10, nColFim - nColObj, {|u| If(PCount() > 0, cMrkPsq := u, cMrkPsq) }, aObjs[1], aTamObj[1] , 09, "",;
									 		{||  } , , , , .T., , .T., , .T., /* When */, .F., .F., , .F., .F., ,cMrkPsq, , , , .T.)

	// Botao de Pesquisa
	oBtnPsq    := TButton():New( 10, nColFim - aTamObj[2], STR0011, aObjs[1], ; // "Pesquisar"
											{|| SearchMrk(cAliasMrk, aObjs[2], cMrkPsq, oGetPsq) }, aTamObj[2], 11.5, , , ,.T.)

	// ComboBox Indices
	nColObj    += aTamObj[3] + nMrgObj
	oCbbInd    := TComboBox():New( 10, nColFim - nColObj, {|u| If(PCount() > 0, cCbbInd := u, cCbbInd) }, aIndMrk, aTamObj[3], 22, aObjs[1], , , ;
											{||  }, , , .T., , , , {||.T.}, , , , , "cCbbInd")

	oCbbInd:bChange := {|| SetIndexCbb(cCbbInd, aIndMrk, cAliasMrk, aObjs[2], @cMrkPsq, oGetPsq, oBtnPsq) }

	// Aplica primeiro indice selecionado
	SetIndexCbb(cCbbInd, aIndMrk, cAliasMrk, aObjs[2], @cMrkPsq, oGetPsq, oBtnPsq)

Return

//---------------------------------------------------------------------
/*/{Protheus.doc} SetIndexCbb
Aplica ordenacao selecionada no combobox de indices.

@param cCbbInd   Variavel/String do combobox.
@param aIndMrk   Indices de pesquisa do markbrowse.
@param cAliasMrk Alias do markbrowse.
@param oBrwMrk   Objeto do markbrowse.
@param cMrkPsq   Variavel/String do campo de pesquisa.
@param oGetPsq   Objeto do campo de pesquisa.
@param oBtnPsq   Objeto do botao de pesquisa.

@author Hugo R. Pereira
@since 19/10/2012
@version MP10
@return Nil
/*/
//---------------------------------------------------------------------
Static Function SetIndexCbb( cCbbInd, aIndMrk, cAliasMrk, oBrwMrk, cMrkPsq, oGetPsq, oBtnPsq )

	Local nIndice := RetIndCbb(cCbbInd, aIndMrk) // Retorna numero do indice selecionado

	// Efetua ordenacao do alias do markbrowse, conforme indice selecionado
	dbSelectArea(cAliasMrk)
	dbSetOrder(nIndice)
	dbGoTop()

	// Se o indice selecionado for o ultimo [Marcados]
	If nIndice == Len(aIndMrk)
		cMrkPsq := Space(Len(cMrkPsq)) // Limpa campo de pesquisa
		oGetPsq:Disable()              // Desabilita campo de pesquisa
		oBtnPsq:Disable()              // Desabilita botao de pesquisa
		oBrwMrk:oBrowse:SetFocus()     // Define foco no markbrowse
	Else
		// cMrkPsq := Space(Len(cMrkPsq)) // Limpa campo de pesquisa
		oGetPsq:Enable()               // Habilita campo de pesquisa
		oBtnPsq:Enable()               // Habilita botao de pesquisa
		oGetPsq:SetFocus()             // Define foco no campo de pesquisa
	Endif

	oBrwMrk:oBrowse:Refresh()

Return .T.

//---------------------------------------------------------------------
/*/{Protheus.doc} RetIndCbb
Retorna o indice, em numero, do item selecionado no combobox

@param cCbbInd Indice/Item selecionado no combobox.
@param aIndMrk Indices de pesquisa do markbrowse.

@author Hugo R. Pereira
@since 19/10/2012
@version MP10
@return Nil
/*/
//---------------------------------------------------------------------
Static Function RetIndCbb( cCbbInd, aIndMrk )

	Local nIndice := aScan(aIndMrk, {|x| AllTrim(x) == AllTrim(cCbbInd) })

	// Se o indice nao foi encontrado nos indices pre-definidos, apresenta mensagem
	If nIndice == 0
		ShowHelpDlg(STR0013, {STR0012},1,; // "Atenção" ## "Índice não encontrado."
							  		{STR0014},1)  // "Contate o administrador do sistema."
		nIndice := 1
		cCbbInd := aIndMrk[1]
	Endif

Return nIndice

//---------------------------------------------------------------------
/*/{Protheus.doc} SearchMrk
Efetua pesquisa no markbrowse.

@param cAliasMrk Alias markbrowse.
@param oBrwMrk   Objeto do markbrowse.
@param cMrkPsq   Variavel/String do campo de pesquisa.
@param oGetPsq   Objeto do campo de pesquisa.

@author Hugo R. Pereira
@since 19/10/2012
@version MP10
@return Nil
/*/
//---------------------------------------------------------------------
Static Function SearchMrk( cAliasMrk, oBrwMrk, cMrkPsq, oGetPsq )

	Local aArea := GetArea()

	// Efetua pesquisa, e caso nao encontrado apresenta mensagem
	dbSelectArea(cAliasMrk)
	lFound := dbSeek( xFilial("TAB") + AllTrim(cMrkPsq) )

	If !lFound
		ShowHelpDlg(STR0013, {STR0015},1,;   // "Atenção" ## "Nenhuma resultado foi encontrado."
									{STR0016},1)    // "Realize uma nova pesquisa."
		RestArea(aArea)
	Endif

	// Atualiza markbrowse
	oBrwMrk:oBrowse:Refresh(.T.)

	// Se a pesquisa nao encontrou nenhum resultado
	If !lFound
		oGetPsq:SetFocus()         // Define foco no campo de pesquisa
	Else
		oBrwMrk:oBrowse:SetFocus() // Define foco no markbrowse
	Endif

Return lFound

//----------------------------------------------------------------
/*/{Protheus.doc} CrtAllTrb
Inicia/Efetua processo de criacao das todas as estruturas necessarias.

@author Hugo R. Pereira
@since 18/10/12
@version MP11
@return Nil
/*/
//---------------------------------------------------------------------
Static Function CrtAllTrb()

	Local aTrbs := Array(1,5)

	// Armazena referencias para criacao das tabelas temporarias
	aTrbs[1][1] := GetNextAlias()

	_SetOwnerPrvt( "cAliasAval", aTrbs[1][1] ) // Avaliacoes Disponiveis

	Processa( {|| aTrbs := ProcCrtTrb() } ) // Inicia proceso de construcao das tabelas temporarias

Return aTrbs

//---------------------------------------------------------------------
/*/{Protheus.doc} ProcCrtTrb
Inicia/Efetua processo de criacao da estruturas requisitada.

@author Hugo R. Pereira
@since 18/10/12
@version MP11
@return Nil
/*/
//---------------------------------------------------------------------
Static Function ProcCrtTrb()

	Local aTrbBrw := Array(1) // Define estrutura para as tabelas temporarias

	ProcRegua(0)

	IncProc(STR0017) // "Construindo estrutura de Avaliacoes Ambientais..."

	aTrbBrw[1] := CrtTrbBrw( cAliasAval , "TAB", 1 ) // Avaliacoes Ambientais

Return aTrbBrw

//---------------------------------------------------------------------
/*/{Protheus.doc} CrtTrbBrw
Define estruturas utilizadas pelo processo.
[ Tabelas temporarias, Markbrowse ]

@param cAliasTrb Alias utilizado pelo markbrowse.
@param cTable    Tabela a ser verificada.
@param nMrkBrw   Controle de markbrowses [Implementacao futura].

@author Hugo R. Pereira
@since 18/10/12
@version MP11
@return Nil
/*/
//---------------------------------------------------------------------
Static Function CrtTrbBrw( cAliasTrb, cTable, nMrkBrw )

	Local aColBrw, nInd
	Local aIndexes := {} // Indices
	Local aIndSeek := {} // Indices utilizados para pesquisa
	Local aIndTrb  := {} // Indices tabela temporaria
	Local aFldBrw  := {} // Campos utilizados pelo processo
	Local nIdx	   := 0

	aFldBrw  := RetFldTbl(cTable, nMrkBrw)                  	// Retorna campos utilizados
	aIndexes := RetIndexTb(cTable, aFldBrw)                 	// Indices da tabela em quetao
	aColBrw  := RetFldBrw(aFldBrw, Str(nMrkBrw,1) $ "1/2")	// Campos (TRB) e Colunas (Browse)

	// Define, atraves dos indices da tabela, os indices de procura e indices da tabela temporaria
	For nInd := 1 To Len(aIndexes)
		aAdd( aIndTrb  , aIndexes[nInd][1] ) // Indices tabela temporaria
		aAdd( aIndSeek , aIndexes[nInd][2] ) // Indices de pesquisa
	Next nInd

	//cArqTrb := NGCRIATRB( aColBrw[2], aIndTrb, cAliasTrb ) // Cria tabela temporaria

	oTempProc := FWTemporaryTable():New( cAliasTrb, aColBrw[2] )
	For nIdx := 1 To Len( aIndTrb )
		oTempProc:AddIndex( RETASC( cValToChar( nIdx ) , 1 , .T. ), StrTokArr( aIndTrb[nIdx] , "+" ) )
	Next nIdx
	oTempProc:Create()

Return { cAliasTrb, aIndSeek, aColBrw[1], oTempProc }

//---------------------------------------------------------------------
/*/{Protheus.doc} RetFldBrw
Define os campos utilizados pelo processo.

@param aFldBrw   Array de controle dos campos pre-definidos.
@param lMrkBrw   Define se deve adicionar o campo aos apresentados pelo markbrowse.

@author Hugo R. Pereira
@since 18/10/12
@version MP11
@return Nil
/*/
//---------------------------------------------------------------------
Static Function RetFldBrw( aFldBrw, lMrkBrw )

	Local nInd
	Local aArea   := GetArea()
	Local aFldMrk := {}
	Local aFldTrb := {}
	Local aFldEsp := {}
	Local cCampo  := ''

	// Verifica campos selecionados para apresentacao
	For nInd := 1 To Len(aFldBrw)

		cCampo  := aFldBrw[nInd][1]

		If !Empty( Posicione( "SX3", 2, cCampo, "X3_USADO" ) )

			// Define que o campo sera utilizado pelo markbrowse
			SetFldTbl( { AllTrim(cCampo), GetSx3Cache(cCampo, 'X3_TIPO'), GetSx3Cache(cCampo, 'X3_TAMANHO'), GetSx3Cache(cCampo, 'X3_DECIMAL'), ;
					  X3Picture(cCampo), Posicione( 'SX3' , 2 , cCampo , 'X3Titulo()' ) }, @aFldMrk, @aFldTrb, lMrkBrw, aFldBrw[nInd] )

		Else

			// Verifica se o campo existe na relacao de campos especificos
			aFldEsp := GetFldEsp( aFldBrw[nInd][1] )
			If !Empty(aFldEsp)

				// Define que o campo sera utilizado pelo markbrowse
				SetFldTbl( { aFldEsp[1], aFldEsp[2], aFldEsp[3], aFldEsp[4], aFldEsp[5], aFldEsp[6] },;
								@aFldMrk, @aFldTrb, lMrkBrw, aFldBrw[nInd] )
			Endif

		Endif
	Next nInd

	RestArea(aArea)

Return { aFldMrk, aFldTrb }


//---------------------------------------------------------------------
/*/{Protheus.doc} SetFldEsp
Define campos especificos para o processo em questao.

@author Hugo R. Pereira
@since 18/10/12
@version MP11
@return Nil
/*/
//---------------------------------------------------------------------
Static Function SetFldEsp()

	Local aFldEsp := {}

	aAdd( aFldEsp, { "TAB_OK"  , "C", 2  , 0, "", " " } )

Return aFldEsp


//---------------------------------------------------------------------
/*/{Protheus.doc} GetFldEsp
Verifica e retornar campo definido de forma especifica, atraves da funcao SetFldEsp().

@param cField Campo a ser verificado.

@author Hugo R. Pereira
@since 18/10/12
@version MP11
@return Nil
/*/
//---------------------------------------------------------------------
Static Function GetFldEsp( cField )

	Local aFldEsp := SetFldEsp()
	Local nPosFld := 0

	// Verifica se o campo informado esta presente nos campos especificos
	nPosFld := aScan( aFldEsp, {|x| x[1] == cField } )

Return If( nPosFld > 0, aFldEsp[nPosFld], {} )

//---------------------------------------------------------------------
/*/{Protheus.doc} SetFldTbl
Define os campos, e suas especificações, para montagem do alias e do browse do markbrowse.

@param aField  Array dos campos e suas especificacoes.
@param aFldMrk Array de controle dos campos apresentados no markbrowse.
@param aFldTrb Array de controle dos campos presentes no alias do markbrowse.
@param lMrkBrw Define se deve adicionar o campo aos apresentados pelo markbrowse.
@param aFldBrw Array de controle dos campos pre-definidos.

@author Hugo R. Pereira
@since 18/10/12
@version MP11
@return Nil
/*/
//---------------------------------------------------------------------
Static Function SetFldTbl( aField, aFldMrk, aFldTrb, lMrkBrw, aFldBrw )

	// Se a apresentacao no markbrowse deve ser considerada, e se o campo foi definido para tal processo
	If lMrkBrw .And. ( Len(aFldBrw) == 1 .Or. aFldBrw[Len(aFldBrw)] )
		aAdd( aFldMrk , { aField[1], Nil, aField[6] } )                // Campos apresentados pelo markbrowse
	Endif
	aAdd( aFldTrb , { aField[1], aField[2], aField[3], aField[4] } ) // Campos para o alias do markbrowse

Return

//---------------------------------------------------------------------
/*/{Protheus.doc} RetFldTbl
Retornar campos pre-definidos conforme a tabela informada.

@param cTable  Tabela a ser verificada.
@param nMrkBrw Controle de markbrowses [Implementacao futura]

@author Hugo R. Pereira
@since 18/10/12
@version MP11
@return Nil
/*/
//---------------------------------------------------------------------
Static Function RetFldTbl( cTable, nMrkBrw )

	Local aFldBrw := {}

	If cTable == "TAB"

		// Define campos que serao utilizados para montagem do alias para o markbrowse, assim como os campos que serao apresentados pelo mesmo
		// A segunda posicao do array, define se o campo sera apresentado no 'browse' do markbrowse
		aFldBrw := { {"TAB_OK", nMrkBrw == 1}, {"TAB_FILIAL", .F.}, {"TAB_ORDEM"}, {"TAB_DTRESU"}, {"TAB_CODASP"}, {"TAB_NOMASP"},;
						 {"TAB_CODIMP"}, {"TAB_NOMIMP"}, {"TAB_CODEST"}, {"TAB_CODNIV"}, {"TAB_DESNIV"}, {"TAB_CODCLA"}, {"TAB_NOMCLA"} }

		If TAB->(FieldPos("TAB_REVISA")) > 0//Caso já tenha o campo de revisao, adiciona
		 	aAdd( aFldBrw , { "TAB_REVISA" } )
		EndIf

	Endif

Return aFldBrw

//---------------------------------------------------------------------
/*/{Protheus.doc} RetIndexTb
Retorna os indices referentes a tabela informada.

@param cTable  Codido da tabela a ser verificada.
@param aFldBrw Array com os campos pre-definidos.

@author Hugo R. Pereira
@since 18/10/12
@version MP11
@return Nil
/*/
//---------------------------------------------------------------------
Static Function RetIndexTb( cTable, aFldBrw )

	Local aIndexes := {}

	Local aArea    := GetArea()
	Local aAreaSIX := SIX->(GetArea())

	dbSelectArea("SIX")
	dbSetOrder(1)
	dbSeek(cTable)
	While !Eof() .And. SIX->INDICE == cTable

		// Verifica se podera utilizar o indice, conforme os campos utilizados
		If CanUseInd(SIX->CHAVE, aFldBrw)
			aAdd(aIndexes, { AllTrim(SIX->CHAVE), AllTrim(SIX->DESCRICAO) } )
		Endif

		dbSelectArea("SIX")
		SIX->(dbSkip())

	End

	// Adiciona indice 'Marcados' a fim de possibilitar a ordenacao pelo itens marcados no markwbrowse
	aAdd(aIndexes, { "TAB_OK", STR0018 } ) //"Marcados"

	RestArea(aAreaSIX)
	RestArea(aArea)

Return aIndexes

//---------------------------------------------------------------------
/*/{Protheus.doc} CanUseInd
Verifica se o indice pode ser utilizado conforme os campos pre-definidos.

@param cIndex  Indice a ser avaliado.
@param aFldBrw Array com os campos pre-definidos.

@author Hugo R. Pereira
@since 18/10/12
@version MP11
@return Nil
/*/
//---------------------------------------------------------------------
Static Function CanUseInd( cIndex, aFldBrw )

	Local lIndexOk := .T.
	Local aFields  := {}
	Local nInd

	If Empty(aFldBrw)
		Return .T.
	Endif

	// Seleciona campos presentes no indice
	aFields := StrTokArr(AllTrim(cIndex),"+")

	// Verifica se algum dos campos nao esta definido previamente
	For nInd := 1 To Len(aFields)
		If !( lIndexOk := (aScan(aFldBrw, {|x| x[1] == aFields[nInd] }) > 0) )
			Exit
		Endif
	Next nInd

Return lIndexOk

//---------------------------------------------------------------------
/*/{Protheus.doc} IncTrbBrw
Incrementa alias do markbrowse.

@param cMrkBrw Marca utilizada pelo markbrowse [GetMark()].

@author Hugo R. Pereira
@since 18/10/12
@version MP11
@return Nil
/*/
//---------------------------------------------------------------------
Static Function IncTrbBrw(aFiltroAsp)

	Local nField, cFldOri, cFldDest, cIndexAt
	Local lNEmpty := .T.

	Local cFiltro111

	Default aFiltroAsp := {}

	If !Empty(aFiltroAsp)
		cFiltro111 := BuildFilter(aFiltroAsp)
	Endif

	dbSelectArea(cAliasAval)
	ZAP

	// Salva indice atual do alias
	cIndexAt := (cAliasAval)->(IndexOrd())

	dbSelectArea("TAB")
	ProcRegua(0)

	dbSelectArea("TAB")
	dbSetOrder(1)
	dbSeek(xFilial("TAB"))

	While !Eof() .And. TAB->TAB_FILIAL == xFilial("TAB")

		IncProc(STR0019) // "Selecionando Avaliacoes ..."

		If !Empty(cFiltro111)

			// Se o aspecto nao estiver dentro da margem dos parametros informados
			If &(cFiltro111)
				dbSelectArea("TAB")
				dbSkip()
				Loop
			Endif

		Else

			// Se a data de resultado nao estiver dentro da margem dos parametros informados
			If TAB->TAB_DTRESU < MV_PAR01 .Or. TAB->TAB_DTRESU > MV_PAR02
				dbSelectArea("TAB")
				dbSkip()
				Loop
			Endif

			// Se a avaliacao nao estiver dentro da margem dos parametros informados
			If TAB->TAB_ORDEM < MV_PAR03 .Or. TAB->TAB_ORDEM > MV_PAR04
				dbSelectArea("TAB")
				dbSkip()
				Loop
			Endif

			// Se o aspecto nao estiver dentro da margem dos parametros informados
			If TAB->TAB_CODASP < MV_PAR05 .Or. TAB->TAB_CODASP > MV_PAR06
				dbSelectArea("TAB")
				dbSkip()
				Loop
			Endif

			// Se o impacto nao estiver dentro da margem dos parametros informados
			If TAB->TAB_CODIMP < MV_PAR07 .Or. TAB->TAB_CODIMP > MV_PAR08
				dbSelectArea("TAB")
				dbSkip()
				Loop
			Endif

			If TAB->(FieldPos("TAB_REVISA")) > 0
				If !Empty( MV_PAR09 ) .And. TAB->TAB_REVISA <> MV_PAR09
					dbSelectArea("TAB")
					dbSkip()
					Loop
				EndIf
			EndIf

		EndIf

		// Se o processo nao for de aprovacao e a avaliacao atual estiver pendente,
		// ou se o processo for de aprovacao e a avaliacao atual estiver aprovada
		If ( !_lActAprv .And. ( TAB->TAB_SITUAC == "1" .Or. Empty(TAB->TAB_SITUAC) ) ) .Or.;
			 ( _lActAprv .And. TAB->TAB_SITUAC != "1" .And. !Empty(TAB->TAB_SITUAC) )
			dbSelectArea("TAB")
			dbSkip()
			Loop
		Endif

		// Persiste avaliacao atual no alias do markbrowse
		dbSelectArea(cAliasAval)
		dbSetOrder(1)
		If !dbSeek(TAB->TAB_ORDEM + TAB->TAB_CODASP)

			dbSelectArea(cAliasAval)
			RecLock(cAliasAval,.T.)

		   For nField := 1 To (cAliasAval)->(FCount())
		   	If NGCADICBASE(FieldName(nField),"A","TAB",.F.)
			      cFldOri  := "TAB->"           + FieldName(nField)
			      cFldDest := cAliasAval + "->"  + FieldName(nField)
			      Replace &cFldDest. with &cFldOri.
			   Endif
		   Next nField

		   (cAliasAval)->TAB_NOMASP := NGSEEK( "TA4", (cAliasAval)->TAB_CODASP, 1, "TA4_DESCRI" )
		   (cAliasAval)->TAB_NOMIMP := NGSEEK( "TAE", (cAliasAval)->TAB_CODIMP, 1, "TAE_DESCRI" )
		   (cAliasAval)->TAB_NOMCLA := NGSEEK( "TA8", (cAliasAval)->TAB_CODCLA, 1, "TA8_DESCRI" )
		   (cAliasAval)->TAB_DESNIV := NGSEEK( "TAF", (cAliasAval)->TAB_CODEST + (cAliasAval)->TAB_CODNIV,2,"TAF_NOMNIV")

		   (cAliasAval)->(MsUnLock())

		Endif

		dbSelectArea("TAB")
		TAB->(dbSkip())

	End

	dbSelectArea(cAliasAval)
	dbSetOrder(cIndexAt)
	dbGoTop()

	If (cAliasAval)->(Eof())
		ShowHelpDlg(STR0013,{STR0020},1,; // "Atenção" ## "Nenhum registro foi encontrado."
						  			{STR0021},2) // "Verifique os parametros informados"
		lNEmpty := .F.
	Endif

Return lNEmpty

//---------------------------------------------------------------------
/*/{Protheus.doc} GetVarOpc
Define array de controle para variaveis globais.

@author Hugo R. Pereira
@since 18/10/12
@version MP11
@return Nil
/*/
//---------------------------------------------------------------------
Static Function GetVarOpc()

	Local aVarScr := {}

	If Type("Inclui") == "L"
		aAdd( aVarScr, { "Inclui", Inclui } )
	Endif

	If Type("Altera") == "L"
		aAdd( aVarScr, { "Altera", Altera } )
	Endif

Return aVarScr

//---------------------------------------------------------------------
/*/{Protheus.doc} VisDesemp
Visualiza avaliacao selecionada.

@param cOrdem   Ordem da avaliacao a ser visualizado.
@param cAspecto Codigo do aspecto a ser visualizado.

@author Hugo R. Pereira
@since 18/10/12
@version MP11
@return Nil
/*/
//---------------------------------------------------------------------
Static Function VisDesemp(cOrdem, cAspecto, cMrkBrw)

	Local aVarScr := GetVarOpc()
	Local nVar

	Local aArea    := GetArea()
	Local aAreaTAB := TAB->(GetArea())

	Private aRotina

	SetVisual()

	dbSelectArea("TAB")
	dbSetOrder(1)
	If dbSeek(xFilial("TAB") + cOrdem + cAspecto)

		//aRotina := StaticCall(SGAA110, MENUDEF)

		// Define arotina
		aRotina := {	{ "" , "AxPesqui" , 0 , 1},;     // "Pesquisar"
							{ "" , "Sg110Pro" , 0 , 2},;     // "Visualizar"
							{ "" , "Sg110Pro" , 0 , 3},;     // "Incluir"
							{ "" , "Sg110Pro" , 0 , 4},;     // "Alterar"
							{ "" , "Sg110Pro" , 0 , 5, 3},;  // "Excluir"
							{ "" , "Sg110Cpy" , 0 , 4}}      // "Copiar"

		If ValType(aRotina) == "A"
			Sg110Pro(Alias(), Recno(), 2)
		EndIf

	Else
		ShowHelpDlg(STR0013,	{STR0022},1,;	// "Atenção" ## "Não possível encontrar o registro requisitado."
									{STR0023},1)	// "Verifique a avaliação selecionada."
	Endif

	If Len(aVarScr) > 0
		For nVar := 1 To Len(aVarScr)
			&(aVarScr[nVar][1]) := aVarScr[nVar][2]
		Next nVar
	Endif

	RestArea(aAreaTAB)
	RestArea(aArea)

	// Retorna/Define marca ao marbrowse
	ThisMark(cMrkBrw)

Return

//---------------------------------------------------------------------
/*/{Protheus.doc} ReBldCns
Efetua o reprocessamento da consulta conforme a confirmacao de novos parametros.

@param cPerg   Grupo de Perguntas relacionado.
@param cMrkBrw Marca utilizada pelo markbrowse [GetMark()].

@author Hugo R. Pereira
@since 18/10/12
@version MP11
@return Nil
/*/
//---------------------------------------------------------------------
Static Function ReBldCns(cPerg, cMrkBrw, oMrkAval)

	// Apresenta a tela de parametros (Pergunta)
	lResult := .T.
	If Pergunte(cPerg) // Apresenta parametros
		Processa( {||  IncTrbBrw() } ) // Caso confirmados novos parametros, reconstroi a consulta
		oMrkAval:oBrowse:Refresh()
	Endif

Return

//---------------------------------------------------------------------
/*/{Protheus.doc} Sg111Grava
Funcao de gravacao/copias das avaliacoes selecionadas.

@author Hugo R. Pereira
@since 19/10/2012
@version MP10
@return Nil
/*/
//---------------------------------------------------------------------
Static Function Sg111Grava(cRevisa)

	Local nFld, nRec, nOrdPosTAB, nOrdPosTAD
	Local cNextOrd, nPosTmp
	Local lGrvOk := .T.

	Local aFldTAB := {}
	Local aFldTAD := {}
	Local aIncons := {}

	dbSelectArea("TAB")
	nOrdPosTAB := TAB->(FieldPos("TAB_ORDEM"))

	dbSelectArea("TAD")
	nOrdPosTAD := TAD->(FieldPos("TAD_ORDEM"))

	If nOrdPosTAB == 0 .Or. nOrdPosTAD == 0
		Return
	Endif

	dbSelectArea(cAliasAval)
	dbSetOrder(__nLastInd)
	dbGotop()
	ProcRegua(RecCount())
	While !Eof() .And. !Empty((cAliasAval)->TAB_OK)

		IncProc(STR0003) // "Registrando Avaliações..."

		lGrvOk := .T.

		dbSelectArea("TAB")
		dbSetOrder(1)
		If dbSeek(xFilial("TAB") + (cAliasAval)->TAB_ORDEM + (cAliasAval)->TAB_CODASP)

			lGrvOk := Sg100NvAtv((cAliasAval)->TAB_CODNIV, (cAliasAval)->TAB_CODEST)

			If !lGrvOk
				SetIncons(@aIncons) // Armazena inconsistencia encontrada

				dbSelectArea(cAliasAval)
				(cAliasAval)->(dbSkip())
				Loop
			Endif

			// Grava campos conforme base de dados
			aAdd( aFldTAB, Array(FCount()) )
			For nFld := 1 To Len(aFldTAB[Len(aFldTAB)])
				aFldTAB[Len(aFldTAB)][nFld] := &( "TAB->" + FieldName(nFld) )
			Next nFld

			// Grava campo Situacao como '1'
			nPosTmp := TAB->(FieldPos("TAB_SITUAC"))
			If nPosTmp > 0
				aFldTAB[Len(aFldTAB)][nPosTmp] := "1"
			Endif

			// Grava campo Situacao como '1'
			nPosTmp := TAB->(FieldPos("TAB_REVISA"))
			If nPosTmp > 0 .And. lRevisa
				aFldTAB[Len(aFldTAB)][nPosTmp] := cRevisa
			Endif

			// Grava campo Ordem conforme ultima ordem disponivel
			cNextOrd := GetSxENum("TAB", "TAB_ORDEM")
			aFldTAB[Len(aFldTAB)][nOrdPosTAB] := cNextOrd
			ConfirmSX8()

			// Opcoes da Avaliacao

			dbSelectArea("TAD")
			dbSetOrder(1)
			dbSeek(xFilial("TAD") + (cAliasAval)->TAB_ORDEM)
			While !Eof() .and. TAD->TAD_ORDEM == (cAliasAval)->TAB_ORDEM

				// Grava campos conforme base de dados
				aAdd( aFldTAD, Array(FCount()) )
				For nFld := 1 To Len(aFldTAD[Len(aFldTAD)])
					aFldTAD[Len(aFldTAD)][nFld] := &( "TAD->" + FieldName(nFld) )
				Next nFld

				// Grava campo Ordem conforme avaliacao previamente definida
				aFldTAD[Len(aFldTAD)][nOrdPosTAD] := cNextOrd

				dbSelectArea("TAD")
				dbSkip()
			End

			If !Sg110GraHis((cAliasAval)->TAB_ORDEM, .F.)

				SetIncons(@aIncons) // Armazena inconsistencia encontrada

				While (nOrdTAD := aScan(aFldTAD, {|x| x[nOrdPosTAD] == (cAliasAval)->TAB_ORDEM })) > 0
					aDel( aFldTAD, nOrdTAD )
					aSize( aFldTAD, Len(aFldTAD) - 1 )
				End

				aDel( aFldTAB, Len(aFldTAB) )
				aSize( aFldTAB, Len(aFldTAB) - 1 )

			Endif

		Endif

		dbSelectArea(cAliasAval)
		(cAliasAval)->(dbSkip())

	End

	// Efetua persistencia dos dados das avaliacoes
	If Len(aFldTAB) > 0 .And. Len(aFldTAD) > 0

		For nFld := 1 To Len(aFldTAB)
			aAdd(aDesemps,aFldTAB[nFld][nOrdPosTAB])
			dbSelectArea("TAB")
			RecLock("TAB", .T.)
			For nRec := 1 To Len(aFldTAB[nFld])
				FieldPut(nRec, aFldTAB[nFld][nRec])
			Next nRec
			TAB->(MsUnLock())
		Next nFld

		For nFld := 1 To Len(aFldTAD)
			dbSelectArea("TAD")
			RecLock("TAD", .T.)
			For nRec := 1 To Len(aFldTAD[nFld])
				FieldPut(nRec, aFldTAD[nFld][nRec])
			Next nRec
			TAD->(MsUnLock())
		Next nFld

	Endif

Return aIncons

//---------------------------------------------------------------------
/*/{Protheus.doc} Sg111Aprov
Funcao de aprovacao das avaliacoes selecionadas.

@author Hugo R. Pereira
@since 19/10/2012
@version MP10
@return Nil
/*/
//---------------------------------------------------------------------
Static Function Sg111Aprov()

	Local nRecTAB, cRet
	Local aIncons := {}
	Local lAprvOk := .T.

	dbSelectArea(cAliasAval)
	dbSetOrder(__nLastInd)
	dbGotop()
	ProcRegua(RecCount())
	While !Eof() .And. !Empty((cAliasAval)->TAB_OK)

		IncProc(STR0004) // "Efetuando Aprovação..."

		lAprvOk := .T.

		dbSelectArea("TAB")
		dbSetOrder(1)
		If dbSeek(xFilial("TAB") + (cAliasAval)->TAB_ORDEM + (cAliasAval)->TAB_CODASP)

			nRecTAB := Recno()

			// Verifica se as avaliações foram respondidas
			lAprvOk := SGA110VIMR(.T., (cAliasAval)->TAB_ORDEM, .F.)

			// Verifica se a avaliação tem os planos de ação e emergencial preenchidos de acordo com a sua classe
			If lAprvOk
				cRet    := SG110CHKPL(TAB->TAB_CODCLA, TAB->TAB_CODPLA, TAB->TAB_CODEME, .F., .F.)
				lAprvOk := ( cRet != "0" )
			Endif


			// Verifica se a avaliação tem o objetivo de acordo com a sua classe
			If lAprvOk .AND. NGCADICBASE("TAB_CODOBJ","A","TAB",.F.)
				cRet    := SG110CHKOB(TAB->TAB_CODCLA, TAB->TAB_CODOBJ, .F., .F.)
				lAprvOk := ( cRet != "0" )
			Endif

			// Caso haja alguma inconsistencia
			If !lAprvOk

				SetIncons(@aIncons) // Armazena inconsistencia encontrada

				dbSelectArea(cAliasAval)
				(cAliasAval)->(dbSkip())
				Loop

			Endif

			aAdd(aDesemps,(cAliasAval)->TAB_ORDEM)

			dbSelectArea("TAB")
			dbGoTo(nRecTAB)
			RecLock("TAB",.F.)
			TAB->TAB_SITUAC := cRet
			TAB->TAB_DTRESU := dDataBase
			TAB->(MsUnlock())

		Endif

		dbSelectArea(cAliasAval)
		(cAliasAval)->(dbSkip())

	End

Return aIncons

//---------------------------------------------------------------------
/*/{Protheus.doc} SetIncons
Armazena inconsistencias em array especifico.

@param aIncons Array com as avaliacoes inconsistentes.

@author Hugo R. Pereira
@since 18/10/12
@version MP11
@return Nil
/*/
//---------------------------------------------------------------------
Static Function SetIncons(aIncons)

	If ValType(aIncons) == "A"
		aAdd(aIncons, { (cAliasAval)->TAB_ORDEM, DTOC((cAliasAval)->TAB_DTRESU), (cAliasAval)->TAB_CODASP, (cAliasAval)->TAB_NOMASP } )
	Endif

Return

//---------------------------------------------------------------------
/*/{Protheus.doc} ShowIncApv
Apresenta tela/memo com inconsistencias da aprovacao.

@param aIncons Array com as avaliacoes inconsistentes.

@author Hugo R. Pereira
@since 18/10/12
@version MP11
@return Nil
/*/
//---------------------------------------------------------------------
Static Function ShowIncApv(aIncons)

	Local nIncons
	Local cMsgIcs

	Default aIncons := {}

	If Len(aIncons) == 0
		Return
	Endif

	cMsgIcs := STR0043 + CRLF // "Foram encontradas inconsistências durante a efetivação dos dados."
	cMsgIcs += STR0044        // "O processo deverá ser feito manualmente através da rotina de Desempenho [SGAA110]."

	If FindFunction("NGMSGMEMO")

		cMsgIcs += + CRLF + CRLF + STR0045 + CRLF // "Verifique a(s) seguinte(s) avaliação(ões):"
		cMsgIcs += Replicate("-",10) + CRLF

		// Imprime avaliacao inconsistente
		For nIncons := 1 To Len(aIncons)
			cMsgIcs += aIncons[nIncons][1] + "  -  "
			cMsgIcs += aIncons[nIncons][2] + "   "
			cMsgIcs += AllTrim(aIncons[nIncons][3]) + "   "
			cMsgIcs += AllTrim(aIncons[nIncons][4]) + CRLF
		Next

		cMsgIcs += Replicate("-",10)

		NGMSGMEMO(STR0046, cMsgIcs) // "Inconsistencias"
	Else
		ShowHelpDlg(STR0013, {cMsgIcs}, 1,; // "Atenção"
									{STR0047}, 1)  // "Realize o processo através da rotina de Desempenho."
	Endif

Return

//---------------------------------------------------------------------
/*/{Protheus.doc} ShowIncApv
Apresenta tela/memo com inconsistencias da aprovacao.

@param aIncons Array com as avaliacoes inconsistentes.

@author Hugo R. Pereira
@since 18/10/12
@version MP11
@return Nil
/*/
//---------------------------------------------------------------------
Static Function SitMrk()

	Local nSitMrk := 0

	Local aArea     := GetArea()
	Local aAreaAval := (cAliasAval)->(GetArea())

	dbSelectArea(cAliasAval)
	dbSetOrder(__nLastInd)
	dbGoTop()

	If Eof()
		nSitMrk := 1
	ElseIf Empty( (cAliasAval)->TAB_OK )
		nSitMrk := 2
	Endif

	RestArea(aAreaAval)
	RestArea(aArea)

Return nSitMrk

//---------------------------------------------------------------------
/*/{Protheus.doc} InitPerg
Define perguntas essenciais a consulta.

@param cPerg Codigo/Grupo de perguntas referente.

@author Hugo R. Pereira
@since 18/10/12
@version MP11
@return Nil
/*/
//---------------------------------------------------------------------
Static Function InitPerg(cPerg)

	Local aPerg   := {}
	Local aHelp   := {}
	Local aTamCpo := {}

	Local cGrupo := ""
	Local aArea  := GetArea()
	Local nInd

	RestArea(aArea)

Return
//---------------------------------------------------------------------
/*/{Protheus.doc} SG111FSITA
Filtro de Avaliacoes Ambientais. [ Pendentes | Aprovadas ]
Verificacao da variavel '_lActAprv' a fim de definir o retorno.
Caso a variavel esteja true, define que deve apresentar apenas avaliacoes pendentes,
caso contrario apenas aprovadas.

@author Hugo R. Pereira
@since 18/10/12
@version MP11
@return Nil
/*/
//---------------------------------------------------------------------
Function SG111FSITA()

	Local lAprov  := If(Type("_lActAprv") == "L", _lActAprv, .F.)       // Consiste existencia de variavel de controle P/A
	Local lAvlPnd := TAB->TAB_SITUAC == "1" .Or. Empty(TAB->TAB_SITUAC) // Verifica se a avaliacao esta Pendente

	// Define retorno conforme variavel de controle [Pendente ou Aprovada]
	//lRet := ( lAprov .And. lAvlPnd ) .Or. ( !lAprov .And. !lAvlPnd )

Return If( lAprov, lAvlPnd, !lAvlPnd )

//---------------------------------------------------------------------
/*/{Protheus.doc} SGA111PRAV
Validacao de pergunta de avaliacoes ambientais.
Verifica se a avaliacao selecionada e valida perante os parametros definidos.

@param nPerg Verifica a origem da chamada. Campo 'De' ou 'Ate'.

@author Hugo R. Pereira
@since 18/10/12
@version MP11
@return Nil
/*/
//---------------------------------------------------------------------
Function SGA111PRAV(nPerg)

	Local aArea    := GetArea()
	Local aAreaTAB := TAB->(GetArea())

	Local cCodAval := If(nPerg == 1, MV_PAR03, MV_PAR04)
	Local lRet     := .T.

	Default nPerg := 1

	// Se encontrou a avaliacao informada
	If NGIFDBSEEK("TAB",cCodAval,1)
		If _lActAprv .And. !(TAB->TAB_SITUAC == '1' .Or. Empty(TAB->TAB_SITUAC))
			ShowHelpDlg(STR0013, {STR0024}, 1, ; // "Atenção" ## "Apenas avaliações pendentes podem ser selecionadas."
										{STR0025}, 1)   // "Selecione outra avaliação."
			lRet := .F.
		ElseIf !_lActAprv .And. (TAB->TAB_SITUAC == '1' .Or. Empty(TAB->TAB_SITUAC))
			ShowHelpDlg(STR0013, {STR0026}, 1, ; // "Atenção"
									{STR0025}, 1)      // "Selecione outra avaliação."
			lRet := .F.
		Endif
	Endif

	// Validacao padrao de perguntas 'De/Ate'
	If lRet
		If nPerg == 1
			lRet := Empty(mv_par03) .Or. Existcpo("TAB",mv_par03)
		Else
			lRet := AteCodigo("TAB", mv_par03, mv_par04)
		Endif
	Endif

	RestArea(aAreaTAB)
	RestArea(aArea)

Return lRet

//---------------------------------------------------------------------
/*/{Protheus.doc} BuildFilter
Função utilizada pelo TNGPG, para planta gráfica no módulo de SGA.
Verifica o campo passado por paramêtro

@author Gabriel Augusto Werlich
@since 03/07/2014
@version MP11
@return cFiltro, retorna a String a ser passada para o Set Filter.
/*/
//---------------------------------------------------------------------
Static Function BuildFilter(aFiltroAsp)

Local cFiltro := ""
Local i

For i := 1 to Len(aFiltroAsp)
	cFiltro += If(i > 1," .Or. ", "")
	cFiltro += aFiltroAsp[i][1] + " <> '" + aFiltroAsp[i][2] + "'"
Next

Return cFiltro