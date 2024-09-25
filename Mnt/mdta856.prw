#INCLUDE "MDTA856.CH"
#INCLUDE "PROTHEUS.CH"

Static __nLastInd := 0 // Indica ultimo indice adicionado (Marcados)

//---------------------------------------------------------------------
/*/{Protheus.doc} MDTA856
Programa para Multiplas Análises Preliminares

@param lAprov Define se o processo e de aprovacao.

@author Hugo R. Pereira
@since 19/10/2012
@version MP10
@return Nil
/*/
//---------------------------------------------------------------------
Function MDTA856(lAprov)

	Local aNGBEGINPRM := NGBEGINPRM(  ) // Armazena variaveis p/ devolucao [NGRIGHTCLICK]
	Local cPerg       := Padr( "MDT856", 10 ) // Grupo de Perguntas relacionado,

	Default lAprov := .F.

	Private _lActAprv	:= lAprov // Variavel de controle do processo [ Copia | Aprovacao ]
    Private lRevisa	    := !_lActAprv// Variavel de controle de revisao - Caso aprovação não repassa revisão

	If !ChkOHSAS()
		//-----------------------------------------------------
		// Devolve variaveis armazenadas (NGRIGHTCLICK)
		//-----------------------------------------------------
		NGRETURNPRM( aNGBEGINPRM )
		Return .F.
	EndIf

	If !AliasInDic('TYH')

		// "As perguntas do relatório estão desatualizadas, favor aplicar a atualização contida no pacote da issue DNG-1847"
		MsgStop( STR0058 )

	Else
		If Pergunte(cPerg)
			MainBrw(cPerg) // Apresenta browse principal
		Endif

	EndIf

	NGRETURNPRM(aNGBEGINPRM) // Devolve variaveis armazenadas [NGRIGHTCLICK]

Return Nil

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
Static Function MainBrw(cPerg)

	// Tela principal
	Local oWndBrw, oPnlBrw, oMrkAval
	Local oPnlPsq, oPnlMrk, oPnlTit

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
	Local aColor    := NGCOLOR()

	Processa( {|| lResult := IncTrbBrw() } ) // Inicia proceso de incremento das tabelas

	// Caso nao encontre nenhum registro
	If !lResult
		aTrbBrw[1,4]:Delete()
		Return
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

				oPnlPsq       := TPanel():New( 0, 0, , oPnlBrw, , , , , , 0, 30 )
				oPnlPsq:Align := CONTROL_ALIGN_TOP

				oPnlMrk       := TPanel():New( 0, 0, , oPnlBrw, , , , , , 0, 0 )
				oPnlMrk:Align := CONTROL_ALIGN_ALLCLIENT

						oPnlTit := TPanel():New( 0, 0, , oPnlMrk, , , , , aColor[ 2 ] , 0, 13 )
						oPnlTit:Align := CONTROL_ALIGN_TOP

							TSay():New( 003, 002, {|| cTitlePrc }, oPnlTit, , oFontT, , , , .T., aColor[ 1 ] , , 200, 10 )

					// Markbrowse Avaliacoes
					oMrkAval := MsSelect():New( aTrbBrw[1][1], "TG6_OK", , aTrbBrw[1][3], , @cMrkBrw, , , , oPnlMrk )
					oMrkAval:oBrowse:lHasMark    := .T.
					oMrkAval:oBrowse:lCanAllMark := .T.
					oMrkAval:bMark               := {|| SetMrkAval( @cMrkBrw, @oMrkAval, 1 ) }
					oMrkAval:oBrowse:bAllMark    := {|| SetMrkAval( @cMrkBrw, @oMrkAval, 2 ) }
					oMrkAval:oBrowse:Align       := CONTROL_ALIGN_ALLCLIENT

					// Cria area de pesquisa do markbrowse
					CrtPsqBrw(aTrbBrw[1][1], aTrbBrw[1][2], cCbbInd, @cMrkPsq, aCoors, {oPnlPsq, oMrkAval}, @cRevisa )

				oMrkAval:oBrowse:SetFocus()

				// Botoes especificos (EnchoiceBar)
				aBtnOpc   := {	{"BMPCONS", {|| VisAnalis((cAliasAval)->TG6_ORDEM, (cAliasAval)->TG6_CODPER, @cMrkBrw) }, STR0005 }, ; // "Visualizar"
									{"PARAMETROS", {|| ReBldCns(cPerg, @cMrkBrw, @oMrkAval) }, STR0008 } }												// "Parâmetros"

	Activate MsDialog oWndBrw On Init ( EnchoiceBar( oWndBrw, {|| SetOkBrw(cRevisa,@lExecute, oWndBrw) }, {|| oWndBrw:End() }, , aBtnOpc ) )

	// Se houve confirmacao do processos
	If lExecute
		// Se o processo e de aprovacao
		If _lActAprv

			// Processo de Aprovacao
			Processa( {|| aIncons := MDT856Aprov() } )

		Else

			// Processo de Gravacao
			Processa( {|| aIncons := MDT856Grava(cRevisa) } )

		Endif

		// Se houveram inconsistencias durante o processo
		If Len(aIncons) > 0
			ShowIncApv(aIncons)
		Endif

	Endif

	If Len( aTrbBrw[1] ) > 0
		aTrbBrw[1,4]:Delete()
	EndIf

Return

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
			(cAliasAval)->TG6_OK   := If( Empty( (cAliasAval)->TG6_OK ),   cMrkBrw, Space(Len(cMrkBrw)) )
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
		ShowHelpDlg( "ATENÇÃO" , { STR0053 } , 1 , { STR0054 } , 1 ) //"Não foi informada a revisão."###"Para prosseguir é necessário informar a revisão na qual os Desempenhos estão vinculados."
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
		TSay():New( 012 , 002, {|| STR0055 }, aObjs[1], , oFontT, , , , .T., CLR_HBLUE , , 200, 10 ) //"Revisão"

	   	oGetPsq    := TGet():New( 10 , 30 , {|u| If(PCount() > 0, cRevisa := u, cRevisa) }, aObjs[1], aTamObj[4] , 09, "",;
												{|| ExistCpo( "TGP" , cRevisa ) } , , , , .T., , .T., , .T., /* When */, .F., .F., , .F., .F., "TGP" ,cRevisa, , , , .T.)
			oGetPsq:bHelp := { | | ShowHelpCpo(	"REVISAO" , ; //"Titulo"
															{ STR0056 } , 2 , ; //"Descrição do Help." //"Informe a revisão que será considerada para as cópias."
															{ } , 2 ) }
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
	lFound := dbSeek( xFilial("TG6") + AllTrim(cMrkPsq) )

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

	aTrbBrw[1] := CrtTrbBrw( cAliasAval , "TG6", 1 ) // Avaliacoes Ambientais

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
	Local nIdx     := 0

	aFldBrw  := RetFldTbl(cTable, nMrkBrw)                  	// Retorna campos utilizados
	aIndexes := RetIndexTb(cTable, aFldBrw)                 	// Indices da tabela em quetao
	aColBrw  := RetFldBrw( aFldBrw, Str(nMrkBrw,1) $ "1/2")	// Campos (TRB) e Colunas (Browse)

	// Define, atraves dos indices da tabela, os indices de procura e indices da tabela temporaria
	For nInd := 1 To Len(aIndexes)
		aAdd( aIndTrb  , aIndexes[nInd][1] ) // Indices tabela temporaria
		aAdd( aIndSeek , aIndexes[nInd][2] ) // Indices de pesquisa
	Next nInd

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

		cCampo := aFldBrw[nInd][1]

		If !Empty( Posicione( "SX3", 2, cCampo, "X3_USADO" ) ) //TG6_NOMPER

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
			EndIf

		EndIf
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

	aAdd( aFldEsp, { "TG6_OK"  , "C", 2  , 0, "", " " } )

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

	If cTable == "TG6"

		// Define campos que serao utilizados para montagem do alias para o markbrowse, assim como os campos que serao apresentados pelo mesmo
		// A segunda posicao do array, define se o campo sera apresentado no 'browse' do markbrowse
		aFldBrw := { {"TG6_OK", nMrkBrw == 1}, {"TG6_FILIAL", .F.}, {"TG6_ORDEM"}, {"TG6_DTRESU"}, {"TG6_CODPER"}, {"TG6_NOMPER"},;
						 {"TG6_CODDAN"}, {"TG6_NOMDAN"}, {"TG6_CODEST"}, {"TG6_CODNIV"}, {"TG6_DESNIV"}, {"TG6_CODCLA"}, {"TG6_NOMCLA"} , { "TG6_REVISA" } }

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
	//Removido função Descend, pois ocorre erro no objeto FwTemporaryTable
	aAdd(aIndexes, { "TG6_OK", STR0018 } ) //"Marcados"

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
Static Function IncTrbBrw()

	Local nField, cFldOri, cFldDest, cIndexAt
	Local lNEmpty := .T.

	dbSelectArea(cAliasAval)
	ZAP

	// Salva indice atual do alias
	cIndexAt := (cAliasAval)->(IndexOrd())

	dbSelectArea("TG6")
	ProcRegua(0)

	dbSelectArea("TG6")
	dbSetOrder(1)
	dbSeek(xFilial("TG6"))
	While TG6->( !Eof() ) .And. TG6->TG6_FILIAL == xFilial("TG6")

		IncProc(STR0019) // "Selecionando Avaliacoes ..."

		// Se a data de resultado nao estiver dentro da margem dos parametros informados
		If TG6->TG6_DTRESU < MV_PAR01 .Or. TG6->TG6_DTRESU > MV_PAR02
			dbSelectArea("TG6")
			dbSkip()
			Loop
		Endif

		// Se a avaliacao nao estiver dentro da margem dos parametros informados
		If TG6->TG6_ORDEM < MV_PAR03 .Or. TG6->TG6_ORDEM > MV_PAR04
			dbSelectArea("TG6")
			dbSkip()
			Loop
		Endif

		// Se o aspecto nao estiver dentro da margem dos parametros informados
		If TG6->TG6_CODPER < MV_PAR05 .Or. TG6->TG6_CODPER > MV_PAR06
			dbSelectArea("TG6")
			dbSkip()
			Loop
		Endif

		// Se o impacto nao estiver dentro da margem dos parametros informados
		If TG6->TG6_CODDAN < MV_PAR07 .Or. TG6->TG6_CODDAN > MV_PAR08
			dbSelectArea("TG6")
			dbSkip()
			Loop
		Endif

		If !Empty( MV_PAR09 ) .And. TG6->TG6_REVISA <> MV_PAR09
			dbSelectArea("TG6")
			dbSkip()
			Loop
		EndIf

		// Se o processo nao for de aprovacao e a avaliacao atual estiver pendente,
		// ou se o processo for de aprovacao e a avaliacao atual estiver aprovada
		If ( !_lActAprv .And. ( TG6->TG6_SITUAC == "1" .Or. Empty(TG6->TG6_SITUAC) ) ) .Or.;
			 ( _lActAprv .And. TG6->TG6_SITUAC != "1" .And. !Empty(TG6->TG6_SITUAC) )
			dbSelectArea("TG6")
			dbSkip()
			Loop
		Endif

		// Persiste avaliacao atual no alias do markbrowse
		dbSelectArea(cAliasAval)
		dbSetOrder(1)
		If !dbSeek(TG6->TG6_ORDEM + TG6->TG6_CODPER)

			dbSelectArea(cAliasAval)
			RecLock(cAliasAval,.T.)

		   For nField := 1 To (cAliasAval)->(FCount())
		   	If NGCADICBASE(FieldName(nField),"A","TG6",.F.)
			      cFldOri  := "TG6->"           + FieldName(nField)
			      cFldDest := cAliasAval + "->"  + FieldName(nField)
			      Replace &cFldDest. with &cFldOri.
			   Endif
		   Next nField

		   (cAliasAval)->TG6_NOMPER := NGSEEK( "TG1", (cAliasAval)->TG6_CODPER, 1, "TG1_DESCRI" )
		   (cAliasAval)->TG6_NOMDAN := NGSEEK( "TG8", (cAliasAval)->TG6_CODDAN, 1, "TG8_DESCRI" )
		   (cAliasAval)->TG6_NOMCLA := NGSEEK( "TG4", (cAliasAval)->TG6_CODCLA, 1, "TG4_DESCRI" )
		   (cAliasAval)->TG6_DESNIV := NGSEEK( "TAF", (cAliasAval)->TG6_CODEST + (cAliasAval)->TG6_CODNIV,2,"TAF_NOMNIV")

		   (cAliasAval)->(MsUnLock())

		Endif

		dbSelectArea("TG6")
		TG6->(dbSkip())

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
/*/{Protheus.doc} VisAnalis
Visualiza avaliacao selecionada.

@param cOrdem   Ordem da avaliacao a ser visualizado.
@param cPerigo Codigo do aspecto a ser visualizado.

@author Hugo R. Pereira
@since 18/10/12
@version MP11
@return Nil
/*/
//---------------------------------------------------------------------
Static Function VisAnalis(cOrdem, cPerigo, cMrkBrw)

	Local aVarScr := GetVarOpc()
	Local nVar

	Local aArea    := GetArea()
	Local aAreaTG6 := TG6->(GetArea())

	Private aRotina

	SetVisual()

	dbSelectArea("TG6")
	dbSetOrder(1)
	If dbSeek(xFilial("TG6") + cOrdem + cPerigo)

		//aRotina := StaticCall(MDTA110, MENUDEF)

		// Define arotina
		aRotina := {	{ "" , "AxPesqui" , 0 , 1},;     // "Pesquisar"
							{ "" , "MDT855Pro" , 0 , 2},;     // "Visualizar"
							{ "" , "MDT855Pro" , 0 , 3},;     // "Incluir"
							{ "" , "MDT855Pro" , 0 , 4},;     // "Alterar"
							{ "" , "MDT855Pro" , 0 , 5, 3},;  // "Excluir"
							{ "" , "MDT855Cpy" , 0 , 4}}      // "Copiar"

		If ValType(aRotina) == "A"
			MDT855Pro(Alias(), Recno(), 2)
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

	RestArea(aAreaTG6)
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
	Pergunte(cPerg) // Apresenta parametros
	Processa( {|| IncTrbBrw() } ) // Caso confirmados novos parametros, reconstroi a consulta
	oMrkAval:oBrowse:Refresh()

Return

//---------------------------------------------------------------------
/*/{Protheus.doc} MDT856Grava
Funcao de gravacao/copias das avaliacoes selecionadas.

@author Hugo R. Pereira
@since 19/10/2012
@version MP10
@return Nil
/*/
//---------------------------------------------------------------------
Static Function MDT856Grava(cRevisa)

	Local nFld, nRec, nOrdPosTG6, nOrdPosTAD
	Local cNextOrd, nPosTmp
	Local lGrvOk := .T.

	Local aFldTG6 := {}
	Local aFldTG7 := {}
	Local aIncons := {}

	dbSelectArea("TG6")
	nOrdPosTG6 := TG6->(FieldPos("TG6_ORDEM"))

	dbSelectArea("TG7")
	nOrdPosTG7 := TG7->(FieldPos("TG7_ORDEM"))

	If nOrdPosTG6 == 0 .Or. nOrdPosTG7 == 0
		Return
	Endif

	dbSelectArea(cAliasAval)
	dbSetOrder(__nLastInd)
	dbGotop()
	ProcRegua(RecCount())
	While !Eof() .And. !Empty((cAliasAval)->TG6_OK)

		IncProc(STR0003) // "Registrando Avaliações..."

		lGrvOk := .T.

		dbSelectArea("TG6")
		dbSetOrder(1)
		If dbSeek(xFilial("TG6") + (cAliasAval)->TG6_ORDEM + (cAliasAval)->TG6_CODPER)

			lGrvOk := Sg100NvAtv((cAliasAval)->TG6_CODNIV, (cAliasAval)->TG6_CODEST)

			If !lGrvOk
				SetIncons(@aIncons) // Armazena inconsistencia encontrada

				dbSelectArea(cAliasAval)
				(cAliasAval)->(dbSkip())
				Loop
			Endif

			// Grava campos conforme base de dados
			aAdd( aFldTG6, Array(FCount()) )
			For nFld := 1 To Len(aFldTG6[Len(aFldTG6)])
				aFldTG6[Len(aFldTG6)][nFld] := &( "TG6->" + FieldName(nFld) )
			Next nFld

			// Grava campo Situacao como '1'
			nPosTmp := TG6->(FieldPos("TG6_SITUAC"))
			If nPosTmp > 0
				aFldTG6[Len(aFldTG6)][nPosTmp] := "1"
			Endif

			// Grava campo Situacao como '1'
			nPosTmp := TG6->(FieldPos("TG6_REVISA"))
			If nPosTmp > 0
				aFldTG6[Len(aFldTG6)][nPosTmp] := cRevisa
			Endif

			// Grava campo Ordem conforme ultima ordem disponivel
			cNextOrd := GetSxENum("TG6", "TG6_ORDEM")
			aFldTG6[Len(aFldTG6)][nOrdPosTG6] := cNextOrd
			ConfirmSX8()

			// Opcoes da Avaliacao

			dbSelectArea("TG7")
			dbSetOrder(1)
			dbSeek(xFilial("TG7") + (cAliasAval)->TG6_ORDEM)
			While !Eof() .and. TG7->TG7_ORDEM == (cAliasAval)->TG6_ORDEM

				// Grava campos conforme base de dados
				aAdd( aFldTG7, Array(FCount()) )
				For nFld := 1 To Len(aFldTG7[Len(aFldTG7)])
					aFldTG7[Len(aFldTG7)][nFld] := &( "TG7->" + FieldName(nFld) )
				Next nFld

				// Grava campo Ordem conforme avaliacao previamente definida
				aFldTG7[Len(aFldTG7)][nOrdPosTG7] := cNextOrd

				dbSelectArea("TG7")
				dbSkip()
			End

			If !fGravaHist((cAliasAval)->TG6_ORDEM,cNextOrd)

				SetIncons(@aIncons) // Armazena inconsistencia encontrada

				While (nOrdTG7 := aScan(aFldTG7, {|x| x[nOrdPosTG7] == (cAliasAval)->TG6_ORDEM })) > 0
					aDel( aFldTG7, nOrdTG7 )
					aSize( aFldTG7, Len(aFldTG7) - 1 )
				End

				aDel( aFldTG6, Len(aFldTG6) )
				aSize( aFldTG6, Len(aFldTG6) - 1 )

			Endif

		Endif

		dbSelectArea(cAliasAval)
		(cAliasAval)->(dbSkip())

	End

	// Efetua persistencia dos dados das avaliacoes
	If Len(aFldTG6) > 0 .And. Len(aFldTG7) > 0

		For nFld := 1 To Len(aFldTG6)
			dbSelectArea("TG6")
			RecLock("TG6", .T.)
			For nRec := 1 To Len(aFldTG6[nFld])
				FieldPut(nRec, aFldTG6[nFld][nRec])
			Next nRec
			TG6->(MsUnLock())
		Next nFld

		For nFld := 1 To Len(aFldTG7)
			dbSelectArea("TG7")
			RecLock("TG7", .T.)
			For nRec := 1 To Len(aFldTG7[nFld])
				FieldPut(nRec, aFldTG7[nFld][nRec])
			Next nRec
			TG7->(MsUnLock())
		Next nFld

	Endif

Return aIncons

//---------------------------------------------------------------------
/*/{Protheus.doc} MDT856Aprov
Funcao de aprovacao das avaliacoes selecionadas.

@author Hugo R. Pereira
@since 19/10/2012
@version MP10
@return Nil
/*/
//---------------------------------------------------------------------
Static Function MDT856Aprov()

	Local nRecTG6, cRet
	Local aIncons := {}
	Local lAprvOk := .T.

	dbSelectArea(cAliasAval)
	dbSetOrder(__nLastInd)
	dbGotop()
	ProcRegua(RecCount())
	While !Eof() .And. !Empty((cAliasAval)->TG6_OK)

		IncProc(STR0004) // "Efetuando Aprovação..."

		lAprvOk := .T.

		dbSelectArea("TG6")
		dbSetOrder(1)
		If dbSeek(xFilial("TG6") + (cAliasAval)->TG6_ORDEM + (cAliasAval)->TG6_CODPER)

			nRecTG6 := Recno()

			// Verifica se as avaliações foram respondidas
			lAprvOk := MDT855VIMR(.T., (cAliasAval)->TG6_ORDEM, .F.)

			// Verifica se a avaliação tem os planos de ação e emergencial preenchidos de acordo com a sua classe
			If lAprvOk
				cRet    := fValidCla(TG6->TG6_CODCLA)
				lAprvOk := ( cRet != "0" )
			Endif

			// Caso haja alguma inconsistencia
			If !lAprvOk

				SetIncons(@aIncons) // Armazena inconsistencia encontrada

				dbSelectArea(cAliasAval)
				(cAliasAval)->(dbSkip())
				Loop

			Else
				dbSelectArea("TG6")
				dbGoTo(nRecTG6)
				RecLock("TG6",.F.)
				TG6->TG6_SITUAC := cRet
				TG6->TG6_DTRESU := dDataBase
				TG6->(MsUnlock())
			Endif

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
		aAdd(aIncons, { (cAliasAval)->TG6_ORDEM, DTOC((cAliasAval)->TG6_DTRESU), (cAliasAval)->TG6_CODPER, (cAliasAval)->TG6_NOMPER } )
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
	cMsgIcs += STR0044        // "O processo deverá ser feito manualmente através da rotina de Desempenho [MDTA110]."

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
	ElseIf Empty( (cAliasAval)->TG6_OK )
		nSitMrk := 2
	Endif

	RestArea(aAreaAval)
	RestArea(aArea)

Return nSitMrk

//---------------------------------------------------------------------
/*/{Protheus.doc} MDT856FSITA
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
Function MDT856FSITA()

	Local lAprov  := If(Type("_lActAprv") == "L", _lActAprv, .F.)       // Consiste existencia de variavel de controle P/A
	Local lAvlPnd := TG6->TG6_SITUAC == "1" .Or. Empty(TG6->TG6_SITUAC) // Verifica se a avaliacao esta Pendente

	// Define retorno conforme variavel de controle [Pendente ou Aprovada]
	//lRet := ( lAprov .And. lAvlPnd ) .Or. ( !lAprov .And. !lAvlPnd )

Return If( lAprov, lAvlPnd, !lAvlPnd )

//---------------------------------------------------------------------
/*/{Protheus.doc} MDT856PRAV
Validacao de pergunta de avaliacoes ambientais.
Verifica se a avaliacao selecionada e valida perante os parametros definidos.

@param nPerg Verifica a origem da chamada. Campo 'De' ou 'Ate'.

@author Hugo R. Pereira
@since 18/10/12
@version MP11
@return Nil
/*/
//---------------------------------------------------------------------
Function MDT856PRAV(nPerg)

	Local aArea    := GetArea()
	Local aAreaTG6 := TG6->(GetArea())

	Local cCodAval := If(nPerg == 1, MV_PAR03, MV_PAR04)
	Local lRet     := .T.

	Default nPerg := 1

	// Se encontrou a avaliacao informada
	If NGIFDBSEEK("TG6",cCodAval,1)
		If _lActAprv .And. !(TG6->TG6_SITUAC == '1' .Or. Empty(TG6->TG6_SITUAC))
			ShowHelpDlg(STR0013, {STR0024}, 1, ; // "Atenção" ## "Apenas avaliações pendentes podem ser selecionadas."
										{STR0025}, 1)   // "Selecione outra avaliação."
			lRet := .F.
		ElseIf !_lActAprv .And. (TG6->TG6_SITUAC == '1' .Or. Empty(TG6->TG6_SITUAC))
			ShowHelpDlg(STR0013, {STR0026}, 1, ; // "Atenção"
									{STR0025}, 1)      // "Selecione outra avaliação."
			lRet := .F.
		Endif
	Endif

	// Validacao padrao de perguntas 'De/Ate'
	If lRet
		If nPerg == 1
			lRet := Empty(mv_par03) .Or. Existcpo("TG6",mv_par03)
		Else
			lRet := AteCodigo("TG6", mv_par03, mv_par04)
		Endif
	Endif

	RestArea(aAreaTG6)
	RestArea(aArea)

Return lRet
//---------------------------------------------------------------------
/*/{Protheus.doc} fValidCla
Valida se todas as necessidades da classe foram informadas

@param cCodCla - Codigo da Classe a ser validada

@author Hugo R. Pereira
@since 18/10/12
@version MP11
@return Nil
/*/
//---------------------------------------------------------------------
Static Function fValidCla( cCodCla )

Local cRet		:= "2"//"Aprovado"
Local lSemPlaAc	:= .F.
Local lSemPlaEm := .F.
Local lSemObj	:= .F.
Local lSemMon	:= .F.
Local lReaval	:= .F.

dbSelectArea("TG4")
dbSetOrder(1)
If dbSeek(xFilial("TG4")+cCodCla)
	If TG4->TG4_PLANAC == "1" .AND. !NGIFDBSEEK( "TGF" , xFilial("TGF") + TG6->TG6_ORDEM , 1 )
		lSemPlaAc := .T.
	EndIf
	If TG4->TG4_PLANEM == "1" .AND. !NGIFDBSEEK( "TGG" , xFilial("TGG") + TG6->TG6_ORDEM , 1 )
		lSemPlaEm := .T.
	Endif
	If TG4->TG4_OBJETI == "1" .AND. !NGIFDBSEEK( "TGH" , xFilial("TGH") + TG6->TG6_ORDEM , 1 )
		lSemObj := .T.
	Endif
	If TG4->TG4_MONITO == "1" .AND. !NGIFDBSEEK( "TGI" , xFilial("TGI") + TG6->TG6_ORDEM , 1 )
		lSemMon := .T.
	Endif
	If TG4->TG4_REAVAL == "1"
		lReaval := .T.
	EndIf
EndIf

//Verifica se os criterios necessitam de relacionamento
dbSelectArea( "TG7" )
dbSetOrder( 1 )
dbSeek( xFilial( "TG7" ) + TG6->TG6_ORDEM )
While TG7->( !Eof() ) .And. TG7->TG7_FILIAL == xFilial( "TG7" ) .And. ;
		TG7->TG7_ORDEM == TG6->TG6_ORDEM
	dbSelectArea( "TG3" )
	dbSetOrder( 1 )
	If dbSeek( xFilial( "TG3" ) + TG7->TG7_CODAVA + TG7->TG7_CODOPC )
		If TG3->TG3_PLANAC == "1" .AND. !NGIFDBSEEK( "TGF" , xFilial("TGF") + TG6->TG6_ORDEM , 1 )
			lSemPlaAc := .T.
		EndIf
		If TG3->TG3_PLANEM == "1" .AND. !NGIFDBSEEK( "TGG" , xFilial("TGG") + TG6->TG6_ORDEM , 1 )
			lSemPlaEm := .T.
		Endif
		If TG3->TG3_OBJETI == "1" .AND. !NGIFDBSEEK( "TGH" , xFilial("TGH") + TG6->TG6_ORDEM , 1 )
			lSemObj := .T.
		Endif
		If TG3->TG3_MONITO == "1" .AND. !NGIFDBSEEK( "TGI" , xFilial("TGI") + TG6->TG6_ORDEM , 1 )
			lSemMon := .T.
		Endif
	EndIF
	TG7->( dbSkip() )
End

If lSemPlaAc .Or. lSemPlaEm .Or. lSemObj .Or. lSemMon .or. lReaval
	cRet := "0"
EndIf

Return cRet
//---------------------------------------------------------------------
/*/{Protheus.doc} fGravaHist
Grava no Historico a Avaliacao

@return

@author Jackson Machado
@since 27/03/2013
/*/
//---------------------------------------------------------------------
Static Function fGravaHist( cOrdem2 , cOrdRea )

	Local nTab
	Local Tab , ny , nx , TGE , cCodHis , i , nFor
	Local cTabGet	:= ""
	Local cTabHis	:= ""
	Local cSeek		:= ""
	Local cRet		:= "2"
	//Tabelas de GetDados
	Private aTabGet 		:= { ;
									{ "TGF" , "TGJ" , "TGF_CODPLA" } , ;
									{ "TGG" , "TGK" , "TGG_CODPLA" } , ;
									{ "TGH" , "TGL" , "TGH_CODOBJ" } , ;
									{ "TGI" , "TGM" , "TGI_CODMON" } ;
								}

	cCodCla 		:= If( Type( "cCodCla"       ) == "C" , cCodCla       , TG6->TG6_CODCLA )

	// Se deve verificar as validacoes. [Utilizado para processos automaticos]
	If ( cRet := fValidCla( cCodCla ) ) == "0" // Verifica a classe da avaliação
		Return .F.
	Endif

	cCodHis := fCodHist()

	dbSelectArea( "TG6" )
	RegToMemory( "TG6" , .F. )

	dbSelectArea( "TGD" )
	dbSetOrder( 3 )
	If !DbSeek( xFilial( "TGD" ) + cOrdem2 )
		RecLock( "TGD" , .T. )
	Else
		RecLock( "TGD" , .F. )
	Endif

	For i:=1 To FCount()
		If "_SITUAC" $ Upper( FieldName( i ) )
			FieldPut( i , cRet )
		ElseIf "_CODHIS" $ Upper( FieldName( i ) )
			FieldPut( i , cCodHis )
		ElseIf "_DTHIST" $ Upper( FieldName( i ) )
			FieldPut( i , dDataBase )
		ElseIf "_DTFINA" $ Upper( FieldName( i ) )
			FieldPut( i , dDataBase )
		ElseIf "_REAVAL" $ Upper ( FieldName( i ) )
			FieldPut( i , cOrdRea )
		Else
			nX := "TG6_" + Substr( FieldName( i ) , 5 )
			If TG6->( ColumnPos( nX ) ) > 0
				FieldPut( i , &( "M->" + nX ) )
			EndIf
		EndIf
	Next

	MsUnlock( "TGD" )

	dbSelectArea( "TG6" )
	RecLock( "TG6" , .F. )
	DbDelete()
	MsUnLock( "TG6" )

	//Passa a tabela TGN
	dbSelectArea( "TGN" )
	dbSetOrder( 1 )
	dbSeek( xFilial( "TGN" ) + cOrdem2 )
	While TGN->( !Eof() ) .And. TGN->TGN_FILIAL == xFilial( "TGN" ) .And. TGN->TGN_ANALIS == cOrdem2
		dbSelectArea( "TGN" )
		RegToMemory( "TGN" , .F. )

		dbSelectArea( "TGO" )
		dbSetOrder( 1 )
		If !dbSeek( xFilial( "TGO" ) + cCodHis + cOrdem2 + TGN->TGN_CODFOR )
			RecLock( "TGO" , .T. )
		Else
		 	RecLock( "TGO" , .F. )
		EndIf
		For i := 1 To FCount()
			If "_FILIAL" $ Upper( FieldName( i ) )
				FieldPut( i , xFilial( "TGO" ) )
			ElseIf "_CODHIS" $ Upper( FieldName( i ) )
				FieldPut( i , cCodHis )
			Else
				nX := "TGN_" + Substr( FieldName( i ) , 5 )
				If TGN->( ColumnPos( nX ) ) > 0
					FieldPut( i , &( "M->" + nX ) )
				Endif
			Endif
		Next i
		nFor++
		TGO->( MsUnlock() )

		dbSelectArea( "TGN" )
		TGN->( dbSkip() )
	EndDo

	//Passa a tabela TG7
	dbSelectArea( "TG7" )
	dbSetOrder( 1 )//TG7_FILIAL+TG7_ORDEM+TG7_CODAVA+TG7_CODOPC
	dbSeek( xFilial( "TG7" ) + cOrdem2 )
	While !Eof() .and. TG7->TG7_FILIAL == xFilial( "TG7" ) .and. TG7->TG7_ORDEM == cOrdem2
		dbSelectArea( "TG7" )
		RegToMemory( "TG7" , .F. )

		dbSelectArea( "TGE" )
		dbSetOrder( 1 ) //TGE_FILIAL+TGE_CODHIS+TGE_CODAVA+TGE_CODOPC
		If !dbSeek( xFilial( "TGE" ) + TGD->TGD_CODHIS + TG7->TG7_ORDEM + TG7->TG7_CODAVA + TG7->TG7_CODOPC )
			RecLock( "TGE" , .T. )
			For i := 1 To FCount()
				If "_CODHIS" $ Upper( FieldName( i ) )
					FieldPut( i , TGD->TGD_CODHIS )
				Else
					nX := "TG7_" + Substr( FieldName( i ) , 5 )
					If TG7->( ColumnPos( nX ) ) > 0
						FieldPut( i , &( 'M->' + nX ) )
					Endif
				Endif
			Next
			MsUnlock( "TGE" )

			DbSelectArea( "TG7" )
			RecLock( "TG7" , .F. )
			DbDelete()
			MsUnLock( "TG7" )

		EndIf

		dbSelectArea( "TG7" )
		dbSkip()
	End

	For nTab := 1 To Len( aTabGet )

		cTabGet	:= aTabGet[ nTab , 1 ]
		cTabHis	:= aTabGet[ nTab , 2 ]
		cSeek		:= aTabGet[ nTab , 3 ]

		dbSelectArea( cTabGet )
		dbSetOrder( 1 )
		dbSeek( xFilial( cTabGet ) + cOrdem2 )
		While !Eof() .and. &( PrefixoCPO( cTabGet ) + "->" + cTabGet + "_FILIAL" ) == xFilial( cTabGet ) .And. ;
							&( PrefixoCPO( cTabGet ) + "->" + cTabGet + "_ANALIS" ) == cOrdem2
			dbSelectArea( cTabGet )
			RegToMemory( cTabGet , .F. )

			dbSelectArea( cTabHis )
			dbSetOrder( 1 )
			If !dbSeek( xFilial( cTabHis ) + TGD->TGD_CODHIS + &( PrefixoCPO( cTabGet ) + "->" + cTabGet + "_ANALIS" ) + &( PrefixoCPO( cTabGet ) + "->" + cSeek ) )
				RecLock( cTabHis , .T. )
				For i := 1 To FCount()
					If "_CODHIS" $ Upper( FieldName( i ) )
						FieldPut( i , TGD->TGD_CODHIS )
					Else
						nX :=  cTabGet + "_" + Substr( FieldName( i ) , 5 )
						If cTabGet->( ColumnPos( nX ) ) > 0
							FieldPut( i , &( "M->" +nx ) )
						Endif
					Endif
				Next
				MsUnlock( cTabHis )

				DbSelectArea( cTabGet )
				RecLock( cTabGet , .F. )
				( cTabGet )->( DbDelete() )
				MsUnLock( cTabGet )
			EndIf
			( cTabGet )->( dbSkip() )
		End

	Next nTab

Return .T.
//---------------------------------------------------------------------
/*/{Protheus.doc} MDT856Ate
Valida pergunta Até

@param cAlias - Alias que será feito a pesquisa.
@param cAte - Pergunta Até.
@param cDe - Perunta De.
@return lRet

@author Guilherme Freudenburg
@since 09/12/2014
/*/
//---------------------------------------------------------------------
Function MDT856Ate(cAlias,cAte,cDe)

Local lRet := .T.

If cAte <> Replicate("Z",Len(cAte))
	lRet:= ExistCpo(cAlias,cAte)
	If lRet .And. !( cAte >= cDe )
		lRet:= .F.
		ShowHelpDlg(STR0013,{STR0051},1,{STR0052},2)//Atenção ##"Para a opção de Paramêtro de Até no arquivo de Perguntas, esta opção é invalida."##"Favor informar outro valor."
	Endif
Endif

Return lRet

//---------------------------------------------------------------------
/*/{Protheus.doc} fCodHist
Retorna codigo do historico

@return

@author Jackson Machado
@since 27/03/2013
/*/
//---------------------------------------------------------------------
Static Function fCodHist()

	Local cCodHis := "000000"
	dbSelectArea( "TGD" )
	dbSetOrder( 1 )
	dbGoTop()
	While TGD->( !Eof() ) .and. xFilial( "TGD" ) == TGD->TGD_FILIAL
		cCodHis := TGD->TGD_CODHIS
		TGD->( DbSkip() )
	End

Return StrZero( Val( cCodHis ) + 1 , 6 )
