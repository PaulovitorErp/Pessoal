#include "Protheus.ch"
#include "MDTA999.ch"

//----------------------------------------------
// Posições dos campos no aAGeral
// Se alterar, deixar o _DEL_ SEMPRE por último
//----------------------------------------------
Static _CODGRU_ := 1
Static _QUESTA_ := 2
Static _PERGUN_ := 3
Static _INDSEX_ := 4
Static _COMBO_  := 5
Static _TPLIST_ := 6
Static _ONMEMO_ := 7
Static _ORDEM_  := 8
Static _TAM_    := 9
Static _FORMAT_ := 10
Static _FORMUL_ := 11
Static _DEFAUL_ := 12
Static _ORDGRP_ := 13
Static _TIPGRP_ := 14
Static _CATOT_  := 15
Static _DEL_    := 16

Static _CLR_LINE:= SetTransparentColor( CLR_BLACK , 50 )

//---------------------------------------------------------------------
/*/{Protheus.doc} MDTA999
Questionário padrão.
Nova rotina de questionário padrão, para dar suporte a vários processos,
como por exemplo: observação de ,índice de práticas seguras,
análises de segurança no trabalho, etc...

@author André Felipe Joriatti
@since 18/02/2013
@version MP11
@return lRet
/*/
//---------------------------------------------------------------------
Function MDTA999()

	Local lRet := .T.
	//--------------------------------------------------
	// Armazena variáveis p/ devolução ( NGRIGHTCLICK )
	//--------------------------------------------------
	Local aNGBEGINPRM := NGBEGINPRM( )

	If !MDT999COMPQ()
		Return Nil
	EndIf

	Private nTamGrp  := TAMSX3( "TJ3_CODGRU" )[1]
	Private nTamQt   := TAMSX3( "TJ3_QUESTA" )[1]
	Private nTamPerg := TAMSX3( "TJ3_PERGUN" )[1]
	Private nTamComb := TAMSX3( "TJ3_COMBO"  )[1]
	Private nTamOrd  := TAMSX3( "TJ3_ORDEM"  )[1]
	Private nTamFor  := TAMSX3( "TJ3_FORMAT" )[1]
	Private nTamFU   := TAMSX3( "TJ3_FORMUL" )[1]
	Private nTamDef  := TAMSX3( "TJ3_DEFAUL" )[1]
	Private nTamOGrp := TAMSX3( "TJ3_ORDGRP" )[1]

	Private aRotina    := MenuDef()
	Private cCadastro
	Private lCopia     := .F. // variável utilizada para controle de comando Copiar, disponível no menu da rotina.
	Private aChkDel    := {}
	Private aTrocaF3   := {}

	//----------------------------------------------
	// Define o cabeçalho da tela de atualizações
	//----------------------------------------------
	cCadastro := OemToAnsi( STR0001 ) // "Questionario Padrão"

	//------------------------------------------------------
	// verificação de integridade referencial na exclusão
	// aChkDel[n][1] - Chave de pesquisa.
	// aChkDel[n][2] - Alias de pesquisa.
	// aChkDel[n][3] - Ordem de pesquisa.
	//------------------------------------------------------
	aChkDel := { { "TJ2->TJ2_QUESTI","TJ1",1 } } // TJ1 - Respostas do Questionário

	//---------------------------
	// endereça função de browse
	//---------------------------
	DbSelectArea( "TJ2" )
	DbSetOrder( 1 ) // TJ2_FILIAL+TJ2_QUESTI
	MBrowse( 6, 1,22,75,"TJ2" )

	//-------------------------------------------------
	// Devolve variaveis armazenadas ( NGRIGHTCLICK )
	//-------------------------------------------------
	NGRETURNPRM( aNGBEGINPRM )

Return lRet

//---------------------------------------------------------------------
/*/{Protheus.doc} MenuDef
Retorna menu da rotina.

@author André Felipe Joriatti
@since 18/02/2013
@version MP11
@return array aRotina: indica o menu da rotina
aRotina[n][1]: nome a aparecer no cabeçalho
aRotina[n][2]: nome da rotina associada
aRotina[n][3]: reservado
aRotina[n][4]: abaixo descrição de possiveis valores
	- 1: pesquisa e posiciona em um banco de dados.
	- 2: simplesmente mostra os campos.
	- 3: inclui registros no banco de dados.
	- 4: altera o registro corrente.
	- 5: remove o registro corrente do banco de dados.
aRotina[n][5]: nivel de acesso
aRotina[n][6]: habilita menu funcional
/*/
//---------------------------------------------------------------------

Static Function MenuDef()

	Local aRotina
	aRotina := { { STR0002,"AxPesqui" ,0,1   },; // "Pesquisar"
                 { STR0003,"MDT999CAD",0,2   },; // "Visualizar"
                 { STR0004,"MDT999CAD",0,3   },; // "Incluir"
                 { STR0005,"MDT999CAD",0,4   },; // "Alterar"
                 { STR0006,"MDT999CAD",0,5,3 },; // "Excluir"
                 { STR0007,"MDT999CP" ,0,4   },; // "Copiar"
                 { STR0008,"MDT999IMP",0,2   } } // "Imprimir"

Return aRotina

//---------------------------------------------------------------------
/*/{Protheus.doc} MDTA999CAD
Função para tela de cadastro, suportando as seguintes operações:
Visualização, Inclusão, Alteração, Exclusão.

@param String cAlias: indica tabela do cadastro.
@param Int nRecno: indica número do registro a ser aberto.
@param Int nOpcx: indica o número da opção, possíveis valores:
				  2 - visualizar
				  3 - incluir
				  4 - alterar
				  5 - excluir
@author André Felipe Joriatti
@since 18/02/2013
@version MP11
@return lRet: ever true.
/*/
//---------------------------------------------------------------------

Function MDT999CAD( cAlias,nRecno,nOpcx )

	Local lRet          := .T.
	Local aArea         := GetArea()
	Local aDcOp         := { "",STR0003,STR0004,STR0005,STR0006 } // "Visualizar","Incluir","Alterar","Excluir"
	Local cCadastro     := STR0009 + aDcOp[nOpcx] // "Questionário - "
	Local oFont         := TFont():New( "Arial",,14,,.T. )
	Local lAltProg      := .T.
	Local nOpca         := 0

	//---------------------------------------
	// campos da tela conforme o alinhamento
	//---------------------------------------
	Local aChoiceTPTJ2 := {} // topo, questionario
	Local aChoiceMeio  := {} // recupera campos que vão no meio da tela, nos folders.

	//----------------------
	// campos das get dados
	//----------------------
	Local aCposGrp := {} // campos a aparecer na get dados de grupo das perguntas
	Local aCposPer := {} // campos a aparecer na get dados de perguntas

	// variável para controle da função de cópia de questionário
	Local nOper := 0

	Local aAreaTJ2 := {}

	aAdd( aCposGrp,"TJ3_CODGRU" )
	aAdd( aCposGrp,"TJ3_NOMGRU" )
	aAdd( aCposGrp,"TJ3_ORDGRP" )
	aAdd( aCposGrp,"TJ3_TIPGRP" )

	aAdd( aCposPer,"TJ3_QUESTA"  )
	aAdd( aCposPer,"TJ3_PERGUN"  )
	aAdd( aCposPer,"TJ3_INDSEX"  )
	aAdd( aCposPer,"TJ3_COMBO"   )
	aAdd( aCposPer,"TJ3_TPLIST"  )
	aAdd( aCposPer,"TJ3_ONMEMO"  )
	aAdd( aCposPer,"TJ3_ORDEM"   )
	aAdd( aCposPer,"TJ3_TAM"     )
	aAdd( aCposPer,"TJ3_FORMAT"  )
	aAdd( aCposPer,"TJ3_FORMUL"  )
	aAdd( aCposPer,"TJ3_CATOT"   )

	aAdd( aChoiceTPTJ2,"TJ2_QUESTI" )
	aAdd( aChoiceTPTJ2,"TJ2_NOMQUE" )
	aAdd( aChoiceTPTJ2,"TJ2_DTCAD"  )
	aAdd( aChoiceTPTJ2,"TJ2_USER"   )

	aAdd( aChoiceMeio,"TJ2_FUNC"    )
	aAdd( aChoiceMeio,"TJ2_TAR"     )
	aAdd( aChoiceMeio,"TJ2_CC"      )
	aAdd( aChoiceMeio,"TJ2_AMB"     )
	aAdd( aChoiceMeio,"TJ2_LOC"     )
	aAdd( aChoiceMeio,"TJ2_INDDAT"  )
	aAdd( aChoiceMeio,"TJ2_INDEMP"  )
	aAdd( aChoiceMeio,"TJ2_INDTIT"  )
	aAdd( aChoiceMeio,"TJ2_INDTEX"  )
	aAdd( aChoiceMeio,"TJ2_INDRES"  )
	aAdd( aChoiceMeio,"TJ2_CDTEXT"  )
	aAdd( aChoiceMeio,"TJ2_TPRES"   )
	aAdd( aChoiceMeio,"TJ2_CODRES"  )
	aAdd( aChoiceMeio,"TJ2_NOMRES"  )
	aAdd( aChoiceMeio,"NOUSER"      )

	// variável utilizada para bloquear edição das get dados em caso de visualização ou exclusão
	lAltProg := If( nOpcx == 2 .Or. nOpcx == 5,.F.,.T. )

	Private aSvATela := {}
	Private aSize    := MsAdvSize( ,.F.,430 )
	Private aObjects := {}

	aAdd( aObjects,{ 200,200,.T.,.F. } )
	aInfo   := { aSize[1],aSize[2],aSize[3],aSize[4],0,0 }
	aPosObj := MsObjSize( aInfo,aObjects,.T. )

	// array geral das perguntas.
	Private aAGeral       := {}
	Private aColsGrp      := {} // aCols da get dados de grupo de perguntas
	Private aColsPerg     := {} // aCols da get dados de perguntas
	Private oDlgQest      // dialog do cadastro
	Private oPnlAll       // panel All
	Private oPanelTP      // panel topo
	Private oPanelBT      // panel bottom
	Private oPnlTITTOP    // panel para exibir titulo do panel top
	Private oSplitterB    // objeto usado na divisao dos panels da tela, no pannel bottom
	Private oSplitterMeio // splitter que comporta os panels do meio e o bottom
	Private oBttom1       // panel 1 do bottom
	Private oBttom2       // panel 2 do bottom
	Private oPnlTPR       // panel para titulo da get dados de perguntas
	Private oPnlTGR       // panel para titulo da get dados de grupode de perguntas
	Private oPnlGRP       // panel para get dados de grupo de perguntas
	Private oPnlPER       // panel para get dados de perguntas
	Private oEnc_01       // msmget de questionario
	Private oEnc02        // msmget do meio
	Private oGetGrp       // get dados do grupo de perguntas
	Private oGetPerg      // get dados das perguntas
	Private aHdTJ31       := NGHeadExc( aCposGrp )  // header da TJ3 para identificar os grupos das perguntas
	Private aHdTJ32       := NGHeadExc( aCposPer, , .F., .F. )  // header da TJ3 para identificar as perguntas
	Private nLiGetGrp     := 1 // indica linha atual da get dados de grupos, usada para controle de cor da linha.

	If ( nOpcx == 4 .Or. nOpcx == 5 ) .And. !NGVALSX9( "TJ2", { "TJ3", "TJ4" , "TG0" }, .T. , , .F. )
		Return .F.
	EndIf

	DbSelectArea( "TJ2" )
	RegToMemory( "TJ2",( nOpcx == 3 ),.T.,.T. )

	aAreaTJ2 := TJ2->(GetArea())

	// obtem 'array geral' da rotina, usado para armazenar os dados das get dados
	aAGeral := fGetAGeral( nOpcx )

	TJ2->(RestArea(aAreaTJ2))

	// obtem dados de grupos e de perguntas
	aColsGrp  := fGetDdsIni( aAGeral,"G" )
	aColsPerg := fGetDdsIni( aAGeral,"P" )

	// variáveis usadas para controle de perguntas no array aAGeral
	M->TJ3_DEFAUL := " "
	M->TJ3_COMBO  := Space( TAMSX3( "TJ3_COMBO" )[1] )

	Define MSDialog oDlgQest Title OemToAnsi( cCadastro ) From aSize[7],000 To aSize[6],aSize[5] Pixel

		oPnlAll := TPanel():New( 00,00,,oDlgQest,oFont,,,,CLR_WHITE,12,12,.F.,.F. )
		oPnlAll:Align := CONTROL_ALIGN_ALLCLIENT

		// exibe titulo do panel topo
		oPnlTITTOP := TPanel():New( 00,00,,oPnlAll,,,,,RGB( 67,70,87 ),0,13 )
		oPnlTITTOP:Align := CONTROL_ALIGN_TOP
		oPnlTITTOP:nHeight := 25
		TSay():New( 002,002,{ || STR0063 },oPnlTITTOP,,oFont,,,,.T.,RGB( 255,255,255 ),,200,010 ) // #"Questionário"

		// panel topo
		oPanelTP := TPanel():New( 00,00,,oPnlAll,,,,,CLR_WHITE,12,12,.F.,.F. )
		oPanelTP:Align := CONTROL_ALIGN_TOP
		oPanelTP:nHeight := 130

			// caso seja uma cópia de questionário, então seta como operação de incluir para o msmget de código e nome do questionario
			If Type( "lCopia" ) == "L" // tratamento para chamadas externas.
				If	lCopia
					Inclui := .T.
					M->TJ2_QUESTI := Space( TAMSX3( "TJ2_QUESTI" )[1] )
					M->TJ2_NOMQUE := Space( TAMSX3( "TJ2_NOMQUE" )[1] )
					M->TJ2_DTCAD  := dDataBase
					M->TJ2_USER   := cUserName
				EndIf
			EndIf
			nOper   := If( Type( "lCopia" ) == "L" .And. lCopia,3,nOpcx )
			oEnc_01 := MsMGet():New( "TJ2",nRecno,nOper,,,,aChoiceTPTJ2,{ 0,0,65,aPosObj[1][4] },,,,,,oPanelTP,,,.F.,,.T.,,,,, )

		oSplitterMeio := tSplitter():New( 00,00,oPnlAll,000,000,1 )
		oSplitterMeio:Align := CONTROL_ALIGN_ALLCLIENT

			// panel do meio
			oPanelME := TPanel():New( 00,00,,oSplitterMeio,oFont,,,,CLR_WHITE,12,12,.F.,.F. )
			oPanelME:Align   := CONTROL_ALIGN_TOP
			oPanelME:nHeight := 150

				oEnc02            := MsMGet():New( "TJ2",nRecno,nOpcx,,,,aChoiceMeio,{ 0,0,65,aPosObj[1][4] },,,,,,oPanelME,,,.F.,,,,,,, )
				oEnc02:oBox:Align := CONTROL_ALIGN_ALLCLIENT

			// panel bottom
			oPanelBT := TPanel():New( 000,000,,oSplitterMeio,oFont,,,,CLR_WHITE,12,12,.F.,.T. )
				oPanelBT:Align := CONTROL_ALIGN_ALLCLIENT

				oSplitterB := tSplitter():New( 00,00,oPanelBT,000,000 )
					oSplitterB:Align := CONTROL_ALIGN_ALLCLIENT

					//---------------------
					// grupo de perguntas
					//---------------------
					oBttom1 := TPanel():New( 00,00,,oSplitterB,oFont,,,,CLR_WHITE,000,000,.F.,.F. )
						oBttom1:nWidth := 150

						// exibe titulo de grupo de perguntas
						oPnlTGR := TPanel():New( 00,00,,oBttom1,,,,,RGB( 67,70,87 ),000,013 )
							oPnlTGR:Align := CONTROL_ALIGN_TOP
							TSay():New( 002,002,{ || STR0010 },oPnlTGR,,oFont,,,,.T.,CLR_WHITE,,200,010 ) // # "Grupo Perguntas"

						// panel da get dados de grupo de perguntas
						oPnlGRP := TPanel():New( 000,000,,oBttom1,oFont,,,,CLR_WHITE,000,000,.F.,.T. )
							oPnlGRP:Align := CONTROL_ALIGN_ALLCLIENT

							// get dados de grupo de perguntas TJ3
							oGetGrp := MsNewGetDados():New( 000,000,000,000,IIf( !lAltProg,0,GD_INSERT + GD_UPDATE + GD_DELETE ),;
								                            { || fCrGGrp( "L" ) },{ || fCrGGrp( "T" ) },,,,9999,,,{ || fDelGrp() },oPnlGRP,aHdTJ31,aColsGrp )
								// seta atributos do objerto get dados
								oGetGrp:nAt := 1
								oGetGrp:oBrowse:Align   := CONTROL_ALIGN_ALLCLIENT
								oGetGrp:oBrowse:Default()
								oGetGrp:oBrowse:Refresh()
								oGetGrp:oBrowse:bValid    := { || fCrGGrp( "L" ) }
								oGetGrp:oBrowse:bChange   := { || fChgGrp() }
								oGetGrp:oBrowse:bGotFocus := { || fAtuCurLiGRP() }
								oGetGrp:oBrowse:lUseDefaultColors := .F.
								oGetGrp:oBrowse:SetBlkBackColor( { || fGDColor() } )
								oGetGrp:SetEditLine( .F. )

								oGetGrp:oBrowse:Refresh()

					//-------------------------
					// perguntas
					//-------------------------
					oBttom2 := TPanel():New( 00,00,,oSplitterB,oFont,,,,CLR_WHITE,000,000,.F.,.F. )
						oBttom2:nWidth := 300

						// exibe titulo de grupo de perguntas
						oPnlTPR := TPanel():New( 00,00,,oBttom2,,,,,RGB( 67,70,87 ),000,013 )
							oPnlTPR:Align := CONTROL_ALIGN_TOP
							TSay():New( 002,002,{ || STR0064 },oPnlTPR,,oFont,,,,.T.,CLR_WHITE,,200,010 ) // #"Perguntas"

						// panel da get dados de perguntas
						oPnlPER := TPanel():New( 000,000,,oBttom2,oFont,,,,CLR_WHITE,000,000,.F.,.T. )
							oBttom2:nWidth := 300
							oPnlPER:Align := CONTROL_ALIGN_ALLCLIENT

							// get dados de perguntas TJ3
							oGetPerg := MsNewGetDados():New( 000,000,000,300,IIf( !lAltProg,0,GD_INSERT + GD_UPDATE + GD_DELETE ),;
								                        { || fCrGPerg( "L" ) },{ || fCrGPerg( "T" ) },,,,9999,,,{ || fDelPerg() },oPnlPER,aHdTJ32,aColsPerg )

								// seta atributos do objeto get dados
								oGetPerg:oBrowse:Align   := CONTROL_ALIGN_ALLCLIENT
								oGetPerg:oBrowse:Default()
								oGetPerg:oBrowse:Refresh()
								oGetPerg:oBrowse:bValid  := { || fCrGPerg( "L" ) }
								oGetPerg:oBrowse:bChange := { || .T. }
								oGetPerg:SetEditLine( .F. )

								// desabilita get dados de perguntas caso seja grupo do tipo rótulo ou grupo do tipo 'grupo de totais'
								If !( NGSEEK( "TJ4",PadR( oGetGrp:aCols[1][GDFIELDPOS( "TJ3_CODGRU",oGetGrp:aHeader )],TAMSX3( "TJ4_CODGRU" )[1] ),01,"TJ4->TJ4_TIPREG" ) $ "34" ) .And.;
								   ( oGetGrp:aCols[1][GDFIELDPOS( "TJ3_TIPGRP",oGetGrp:aHeader )] != "2" )

									oGetPerg:oBrowse:Enable()
								Else
									oGetPerg:oBrowse:Disable()
								EndIf

		// Função serve para atualizar o valor de TJ2_NOMRES sempre que abre a rotina, dessa forma, se eu alterar por exemplo o
		// cadastro do funcionario e o meu responsável for um funcionário, ele vai atualizar TJ2_NOMRES com o nome do funcionário atualizado.
		MDT999RNRE()

	Activate MSDialog oDlgQest On Init ( EnchoiceBar( oDlgQest,{ || nOpca := 1,If( !MDT999OK( nOpcx ),nOpca := 0,oDlgQest:End() ) },;
															   { || nOpca := 2,oDlgQest:End() } ) )

	// coloca ponteiro do mouse em estado de espera
	CursorWait()

	If nOpca == 1
		Begin Transaction
			Processa( { || MDT999GRV( nOpcx ) } )
		End Transaction
	EndIf

	// restaura ponteiro do mouse
	CursorArrow()

	RestArea( aArea )

Return lRet

//---------------------------------------------------------------------
/*/{Protheus.doc} MDT999CP
Copia questionário que estiver posicionado no browse.

@author André Felipe Joriatti
@since 18/02/2013
@version MP11
@return lRet: ever true.
/*/
//---------------------------------------------------------------------

Function MDT999CP()

	Local lRet   := .T.
	Local nRecno := TJ2->( Recno() )
	Local lOk    := .T.

	lCopia := .F.

	If xFilial( "TJ2" ) != TJ2->TJ2_FILIAL .Or. ( TJ2->( EoF() ) .Or. TJ2->( BoF() ) )
		Help( "",1,"ARQVAZIO" )
		lOk := .F.
	EndIf

	If lOk
		lCopia := .T.
		MDT999CAD( "TJ2",nRecno,4 )
		lCopia := .F.
	EndIf

Return lRet

//---------------------------------------------------------------------
/*/{Protheus.doc} MDT999BLSMT
Validação de campo TJ2_TPRES, troca F3 do campo TJ2_CODRES conforme tipo
de responsável escolhido.

@param string cTipoResp: indica o tipo de responsável.
@author André Felipe Joriatti
@since 25/03/2013
@version MP11
@return boolean lRet: sempre true.
/*/
//---------------------------------------------------------------------

Function MDT999BLSMT( cTipoResp )

	Local lRet := .T.
	aTrocaF3   := {}

	If cTipoResp == "1" // SESMT
		aAdd( aTrocaF3,{ "TJ2_CODRES","TMK" } )
	ElseIf cTipoResp == "2" // Funcionario
		aAdd( aTrocaF3,{ "TJ2_CODRES","SRA" } )
	ElseIf cTipoResp == "3" // Outros
		aAdd( aTrocaF3,{ "TJ2_CODRES","" } )
	EndIf
	M->TJ2_CODRES := Space( TAMSX3( "TJ2_CODRES" )[1] )
	M->TJ2_NOMRES := Space( TAMSX3( "TJ2_NOMRES" )[1] )

Return lRet

//---------------------------------------------------------------------
/*/{Protheus.doc} MDT999RESP
Validação de campo TJ2_CODRES.

@param string cTipRes: indica o tipo de responsável.
@param string cCodResp: indica o código do responsável.
@author André Felipe Joriatti
@since 25/03/2013
@version MP11
@return boolean lRet: sempre true.
/*/
//---------------------------------------------------------------------

Function MDT999RESP( cTipRes,cCodResp )

	Local lRet   := .T.
	Local cAlias := If( cTipRes == "1","TMK","SRA" )
	Local nInd   := If( cTipRes == "1",1,1 )
	Local cChave := If( cTipRes == "1",PadR( cCodResp,TAMSX3( "TMK_CODUSU" )[1] ),PadR( cCodResp,TAMSX3( "RA_MAT" )[1] ) )
	Local cCampo := If( cTipRes == "1","TMK->TMK_NOMUSU","SRA->RA_NOME" )

	If cTipRes != "3" .And. !Empty( cChave )
		lRet := NGIFDBSEEK( cAlias,cChave,nInd,.T. )
	EndIf

	If lRet
		M->TJ2_NOMRES := SubStr( NGSEEK( cAlias,cChave,nInd,cCampo ),1,40 )
	EndIf

Return lRet

//---------------------------------------------------------------------
/*/{Protheus.doc} fGetAGeral
Retorna array geral da rotina, com todos os dados das perguntas.
Os campos são todos chumbados, essa rotina não vai dar suporte a adição
de campos de usuário
NÃO MEXER NA ESTRUTURA DO ARRAY!

@param integer nOpcx: indica operação, 3 inclusão, 2 visu., etc...
@author André Felipe Joriatti
@since 25/02/2013
@version MP11
@return array aArrayGer: indica array com estrutura de dados 'geral',
ou seja, será o array que conterá todas as perguntas.
Estrutura do array:
	1  - TJ3_CODGRU
	2  - TJ3_QUESTA
	3  - TJ3_PERGUN
	4  - TJ3_INDSEX
	5  - TJ3_COMBO
	6  - TJ3_TPLIST
	7  - TJ3_ONMEMO
	8  - TJ3_ORDEM
	9  - TJ3_TAM
	10 - TJ3_FORMAT
	11 - TJ3_FORMUL
	12 - TJ3_DEFAUL
	13 - TJ3_ORDGRP
	14 - TJ3_TIPGRP
/*/
//---------------------------------------------------------------------

Static Function fGetAGeral( nOpcx )

	Local aArrayGer := {}
	Local cQuery    := ""
	Local cTRBQuery := GetNextAlias()

	#IFNDEF TOP // Caso não seja ambiente SQL
		If nOpcx != 3
			NGIFDBSEEK( "TJ3",M->TJ2_QUESTI,01 ) // TJ3_FILIAL+TJ3_QUESTI+TJ3_QUESTA
			While !EoF() .And. TJ3->( TJ3_FILIAL + TJ3_QUESTI ) == xFilial( "TJ3" ) + M->TJ2_QUESTI
				aAdd( aArrayGer,{ TJ3->TJ3_CODGRU,;
								  TJ3->TJ3_QUESTA,;
								  TJ3->TJ3_PERGUN,;
								  TJ3->TJ3_INDSEX,;
								  TJ3->TJ3_COMBO,;
								  TJ3->TJ3_TPLIST,;
								  TJ3->TJ3_ONMEMO,;
								  TJ3->TJ3_ORDEM,;
								  TJ3->TJ3_TAM,;
								  TJ3->TJ3_FORMAT,;
								  TJ3->TJ3_FORMUL,;
								  TJ3->TJ3_DEFAUL,;
								  TJ3->TJ3_ORDGRP,;
								  TJ3->TJ3_TIPGRP,;
								  TJ3->TJ3_CATOT,;
								  .F. } ) // campo para indicar se linha esta deletada (.T.) ou não (.F.)

				NGDBSELSKIP( "TJ3" )
			End While
		EndIf

	#ELSE // Ambiente TOP SQL

		If nOpcx != 3
			cQuery := "SELECT TJ3_CODGRU,TJ3_QUESTA, "
			cQuery +=  	"TJ3_ORDEM,TJ3_TPLIST, "
			cQuery +=  	"TJ3_INDSEX,TJ3_ONMEMO, "
			cQuery +=  	"TJ3_PERGUN,TJ3_COMBO, "
			cQuery +=  	"TJ3_FORMUL,TJ3_ORDGRP, "
			cQuery +=   "TJ3_TIPGRP,TJ3_TAM, "
			cQuery +=  	"TJ3_FORMAT,TJ3_DEFAUL,TJ3_CATOT FROM " + RetSQLName( "TJ3" ) + " "
			cQuery += "WHERE TJ3_FILIAL = '" + xFilial( "TJ3" ) + "' AND TJ3_QUESTI = '" + M->TJ2_QUESTI + "' AND D_E_L_E_T_ <> '*'"

			cQuery := ChangeQuery( cQuery )
			MPSysOpenQuery( cQuery , cTRBQuery )

			( cTRBQuery )->( DbGoTop() )
			While !( cTRBQuery )->( EoF() )

				aAdd( aArrayGer,{ ( cTRBQuery )->TJ3_CODGRU,;
								  ( cTRBQuery )->TJ3_QUESTA,;
								  ( cTRBQuery )->TJ3_PERGUN,;
								  ( cTRBQuery )->TJ3_INDSEX,;
								  ( cTRBQuery )->TJ3_COMBO,;
								  ( cTRBQuery )->TJ3_TPLIST,;
								  ( cTRBQuery )->TJ3_ONMEMO,;
								  ( cTRBQuery )->TJ3_ORDEM,;
								  ( cTRBQuery )->TJ3_TAM,;
								  ( cTRBQuery )->TJ3_FORMAT,;
								  ( cTRBQuery )->TJ3_FORMUL,;
								  ( cTRBQuery )->TJ3_DEFAUL,;
								  ( cTRBQuery )->TJ3_ORDGRP,;
								  ( cTRBQuery )->TJ3_TIPGRP,;
								  ( cTRBQuery )->TJ3_CATOT,;
								  .F. } ) // campo para indicar se linha esta deletada (.T.) ou não (.F.)

				( cTRBQuery )->( DbSkip() )
			End While

			( cTRBQuery )->( DbCloseArea() )
			Use
		EndIf

	#ENDIF

	If nOpcx == 3 .Or. Len( aArrayGer ) == 0
		aAdd( aArrayGer,{ Space( nTamGrp ),;  // TJ3_CODGRU
						  Space( nTamQt ),;   // TJ3_QUESTA
						  Space( nTamPerg ),; // TJ3_PERGUN
						  "1",;               // TJ3_INDSEX
						  Space( nTamComb ),; // TJ3_COMBO
						  "1",;               // TJ3_TPLIST
						  "1",;               // TJ3_ONMEMO
						  "001",;             // TJ3_ORDEM
						  0,;                 // TJ3_TAM
						  "0000",;            // TJ3_FORMAT
						  Space( nTamFU ),;   // TJ3_FORMUL
						  Space( nTamDef ),;  // TJ3_DEFAUL
						  "001",;             // TJ3_ORDGRP
						  "1",;               // TJ3_TIPGRP (1-Normal,2-Rótulo)
						  "1",;               // TJ3_CATOT (1-Soma,2-Fórmula)
						  .F. } ) // campo para indicar se linha esta deletada (.T.) ou não (.F.)
	EndIf

Return aArrayGer

//---------------------------------------------------------------------
/*/{Protheus.doc} fGetDdsIni
Retorna acols da get dados de perguntas ou de grupo de perguntas.

@param Array aAGeral: indica array base para se retornar o acols
@param String cTipoGet: indica se get dados do grupo "G", ou perguntas "P"
@param String cGrupoP: indica grupo de perguntas.
@author André Felipe Joriatti
@since 25/02/2013
@version MP11
@return array aCols: acols desejado conforme parametro cTipoGet.
/*/
//---------------------------------------------------------------------

Static Function fGetDdsIni( aAGeral,cTipoGet,cGrupoP )

	Local nI     := 0
	Local aCols  := {}
	Local cGrupo := ""

	// Ordena array de dados
	aSort( aAGeral,,,{ |x,y| x[_CODGRU_] + x[_QUESTA_] < y[_CODGRU_] + y[_QUESTA_] } )

	If cTipoGet == "G" // para get dados de grupo de perguntas
		For nI := 1 To Len( aAGeral )
			If ( aScan( aCols,{ |x| AllTrim( x[1] ) == AllTrim( aAGeral[nI][_CODGRU_] ) } ) == 0 ) // Se o grupo ainda não existe no aCols, adiciona
				aAdd( aCols,{ aAGeral[nI][_CODGRU_],;
							  NGSEEK( "TJ4",aAGeral[nI][_CODGRU_],01,"TJ4->TJ4_DESCRI" ),;
							  aAGeral[nI][_ORDGRP_],;
							  aAGeral[nI][_TIPGRP_],;
							  Space( 1 ),;
							  .F. } )
			EndIf
		Next nI

		// Se não adicionou nenhum grupo
		If Len( aCols ) == 0
			aAdd( aCols,{ Space( nTamGrp ),;
						  Space( TAMSX3( "TJ3_NOMGRU" )[1] ),;
						  MDT999OGRP(),;
						  "1",;
						  Space( 1 ),;
						  .F. } )
		EndIf

		// Ordena array de grupos de forma descendente pela Ordem
		aSort( aCols,,,{ |x,y| x[3] < y[3] } )

	Elseif cTipoGet == "P"

		// Caso não for chamado pela função de troca de linha do grupo, então pega conforme o primeiro grupo.
		If !IsInCallStack( "fChgGrp" )
			// Param primeira chamada, onde deve recuperar da primeira linha do aAGeral, a linha padrão de inicialização do array
			cGrupo := If ( !Empty( cGrupoP ) .And. cGrupoP != Nil,cGrupoP,aColsGrp[1][_CODGRU_] )
		Else  // Aqui ele foi chamado pela função de troca linha do grupo
			cGrupo := cGrupoP
		EndIf

		For nI := 1 To Len( aAGeral )
			If AllTrim( aAGeral[nI][_CODGRU_] ) == AllTrim( cGrupo ) .And. !Empty( cGrupo ) .And. !Empty( aAGeral[nI][_QUESTA_] ) .And.;
			 !aAGeral[nI][_DEL_]
				aAdd( aCols, { aAGeral[nI][_QUESTA_],;
					   		   aAGeral[nI][_PERGUN_],;
					           aAGeral[nI][_INDSEX_],;
					           aAGeral[nI][_COMBO_],;
					           aAGeral[nI][_TPLIST_],;
					           aAGeral[nI][_ONMEMO_],;
					           aAGeral[nI][_ORDEM_],;
					           aAGeral[nI][_TAM_],;
					           aAGeral[nI][_FORMAT_],;
					           aAGeral[nI][_FORMUL_],;
					           aAGeral[nI][_CATOT_],;
					           Space( 1 ),;
					           aAGeral[nI][_DEL_] } )
			EndIf
		Next nI

		If Len( aCols ) == 0
			aAdd( aCols, { MDT999ICQT(),; // Retorna proximo número de questão
	   		   			   Space( nTamPerg ),;
	                       "1",;
	                       Space( nTamComb ),;
	                       "1",;
	                       "2",;
	                       MDT999IORD(),; // Retorna próximo número de ordem
	                       0,;
	                       Space( nTamFor ),;
	                       Space( nTamFU ),;
	                       "1",;
	                       Space( 1 ),;
	                       .F. } )
		EndIf
	EndIf

Return aCols

//---------------------------------------------------------------------
/*/{Protheus.doc} MDT999GRV
Grava dados da rotina

@param integer nOpcx: indica operação atual
@author André Felipe Joriatti
@since 25/02/2013
@version MP11
@return boolean lRet: ever true.
/*/
//---------------------------------------------------------------------

Function MDT999GRV( nOpcx )

	Local lRet       := .T.
	Local nI         := 0
	Local nY         := 0
	Local cCampo     := ""
	Local aArea      := GetArea()

	// se estiver fazendo uma copia de questionario, seta como operação de inclusão
	nOpcx := If( lCopia,3,nOpcx )

	// para inclusão ou alteração do registro
	If ( nOpcx == 3 .Or. nOpcx == 4 )

		// M->TJ2_NOMRES := If( M->TJ2_TPRES == "3",M->TJ2_NOMRES,Space( TAMSX3( "TJ2_NOMRES" )[1] ) )

		//--------------------------------------------------
		// insere ou altera na tabela de questionário - TJ2
		//--------------------------------------------------
		DbSelectArea( "TJ2" )
		RecLock( "TJ2",( nOpcx == 3 ) )
		For nY := 1 To FCount()
			cCampo := "M->" + FieldName( nY )
			FieldPut( nY,&( cCampo ) )
		Next nY

		If nOpcx == 3
			TJ2->TJ2_FILIAL := xFilial( "TJ2" )
		EndIf
		MsUnLock( "TJ2" )

		//------------------------------------------------------------------
		// insere ou altera registros de perguntas do questionário - TJ3
		//------------------------------------------------------------------
		For nI := 1 To Len( aAGeral )

			// Para registro padrão do aageral que não deve ser gravado, é apenas para controle.
			If Empty( aAGeral[nI][_CODGRU_] ) .Or. Empty( aAGeral[nI][_QUESTA_] )
				Loop
			EndIf

			lLock := NGIFDBSEEK( "TJ3",M->TJ2_QUESTI + aAGeral[nI][_QUESTA_],01 )
			If aAGeral[nI][_DEL_] .And. lLock
				RecLock( "TJ3",.F. )
				DbDelete()
				MsUnLock( "TJ3" )
			ElseIf !aAGeral[nI][_DEL_]
				RecLock( "TJ3",!lLock )
				TJ3->TJ3_FILIAL := xFilial( "TJ3" )
				TJ3->TJ3_QUESTI := M->TJ2_QUESTI
				TJ3->TJ3_QUESTA := aAGeral[nI][_QUESTA_]
				TJ3->TJ3_PERGUN := aAGeral[nI][_PERGUN_]
				TJ3->TJ3_INDSEX := aAGeral[nI][_INDSEX_]
				TJ3->TJ3_CODGRU := aAGeral[nI][_CODGRU_]
				TJ3->TJ3_COMBO  := aAGeral[nI][_COMBO_]
				TJ3->TJ3_TPLIST := aAGeral[nI][_TPLIST_]
				TJ3->TJ3_ONMEMO := aAGeral[nI][_ONMEMO_]
				TJ3->TJ3_DEFAUL := aAGeral[nI][_DEFAUL_]
				TJ3->TJ3_ORDEM  := aAGeral[nI][_ORDEM_]
				TJ3->TJ3_TAM    := aAGeral[nI][_TAM_]
				TJ3->TJ3_FORMAT := aAGeral[nI][_FORMAT_]
				TJ3->TJ3_FORMUL := aAGeral[nI][_FORMUL_]
				TJ3->TJ3_ORDGRP := aAGeral[nI][_ORDGRP_]
				TJ3->TJ3_TIPGRP := aAGeral[nI][_TIPGRP_]
				TJ3->TJ3_CATOT  := aAGeral[nI][_CATOT_]
				MsUnLock( "TJ3" )
			EndIf
		Next nI

	ElseIf nOpcx == 5 // deleção de registro

		// Deleta as perguntas do questionário
		NGIFDBSEEK( "TJ3",M->TJ2_QUESTI,01 )
		While !EoF() .And. TJ3->( TJ3_FILIAL + TJ3_QUESTI ) == xFilial( "TJ3" ) + M->TJ2_QUESTI
			RecLock( "TJ3",.F. )
			DbDelete()
			MsUnLock( "TJ3" )

			NGDBSELSKIP( "TJ3" )
		EndDo

		// Deleta o Questionário
		If NGIFDBSEEK( "TJ2",M->TJ2_QUESTI,01 )
			RecLock( "TJ2",.F. )
			DbDelete()
			MsUnLock( "TJ2" )
		EndIf

	EndIf

	RestArea( aArea )

Return lRet

//---------------------------------------------------------------------
/*/{Protheus.doc} fChgGrp
Função executada na mudança de linha da get dados de grupos de
perguntas

@author André Felipe Joriatti
@since 26/02/2013
@version MP11
@return boolean lRet: sempre true.
/*/
//---------------------------------------------------------------------

Static Function fChgGrp()

	Local lRet    := .T.
	Local nPosGrp := GDFIELDPOS( "TJ3_CODGRU",oGetGrp:aHeader )
	Local cGrupo  := oGetGrp:aCols[oGetGrp:nAt][nPosGrp]

	// limpa acols de perguntas
	oGetPerg:aCols := {}

	// recebe get dados se o grupo não estiver deletado
	If !oGetGrp:aCols[oGetGrp:nAt][Len( oGetGrp:aCols[oGetGrp:nAt] )]
		oGetPerg:aCols := fGetDdsIni( aAGeral,"P",cGrupo )
	EndIf

	If !( NGSEEK( "TJ4",Padr( cGrupo,TAMSX3( "TJ4_CODGRU" )[1] ),01,"TJ4->TJ4_TIPREG" ) $ "34" ) .And.;
	   ( oGetGrp:aCols[oGetGrp:nAt][GDFIELDPOS( "TJ3_TIPGRP",oGetGrp:aHeader )] != "2" )

		oGetPerg:oBrowse:Enable()
	Else
		oGetPerg:oBrowse:Disable()
	EndIf

	// posiciona get dados de perguntas na linha 1
	oGetPerg:nAt := 1

	oGetPerg:lNewLine := .F.

	fAtuCurLiGRP()

	oGetPerg:oBrowse:Refresh()

Return lRet

//---------------------------------------------------------------------
/*/{Protheus.doc} fCrGGrp
Valida get dados de grupo de perguntas.

@param String cTipoVl(obrigatório): indica tipo de validação, se 'L', então
irá validar linha, se 'T', então irá validar tudo.
@author André Felipe Joriatti
@since 26/02/2013
@version MP11
@return boolean lRet: conforme resultado da validação
/*/
//---------------------------------------------------------------------

Static Function fCrGGrp( cTipoVl )

	Local lRet        := .T.
	Local nPosGrp     := GDFIELDPOS( "TJ3_CODGRU",oGetGrp:aHeader )
	Local lDel        := .F.
	Local nI          := 0
	Local nT          := 0
	Local cCodGrp     := ""

	If cTipoVl == "L"

		lDel    := oGetGrp:aCols[oGetGrp:nAt][Len( oGetGrp:aCols[oGetGrp:nAt] )] // se linha estiver deletada
		cCodGrp := oGetGrp:aCols[oGetGrp:nAt][nPosGrp] // código do grupo
		If !lDel
			If !Empty( cCodGrp )
				For nI := 1 To Len( oGetGrp:aCols )
					If nI != oGetGrp:nAt
						If cCodGrp == oGetGrp:aCols[nI][nPosGrp] .And. !oGetGrp:aCols[nI][Len( oGetGrp:aCols[nI] )]
							lRet := .F.
							ShowHelpDlg( "",{ STR0011 },2,{ STR0012 },2 ) // "Código de Grupo já existe." # "Informe outro Código para o Grupo."
						EndIf
					EndIf
				Next nI
			Else
				lRet := .F.
				ShowHelpDlg( "",{ STR0013 },2,{ STR0014 },2 ) // "Código de Grupo não pode ser vazio." # "Informe o Código do Grupo."
			EndIf

			// Deixar essa parte sempre no final da validação da linha
			If lRet
				// Insere ou altera registro no array geral da rotina
				fMngAGeral()
			EndIf
		EndIf

	ElseIf cTipoVl == "T"

		For nI := 1 To Len( oGetGrp:aCols )
			If !oGetGrp:aCols[nI][Len( oGetGrp:aCols[nI] )] // Não deletado
				If !Empty( oGetGrp:aCols[nI][nPosGrp] ) // Código grupo não vazio
					For nT := 1 To Len( oGetGrp:aCols )
						If nI != nT
							// se registros de comparação não estiverem deletados
							If !oGetGrp:aCols[nT][Len( oGetGrp:aCols[nT] )]
								If oGetGrp:aCols[nI][nPosGrp] == oGetGrp:aCols[nT][nPosGrp]
									lRet := .F.
									ShowHelpDlg( "",{ STR0015 },2,{ "" },2 ) // "Existem Grupos Repetidos."
									Exit
								EndIf
							EndIf
						EndIf
					Next nT
				Else
					lRet := .F.
					ShowHelpDlg( "",{ STR0013 },2,{ STR0014 },2 ) // "Código de Grupo não pode ser vazio." # "Informe o Código do Grupo."
					Exit
				EndIf
			EndIf

			If !lRet
				Exit
			EndIf
		Next nI

	EndIf

Return lRet

//---------------------------------------------------------------------
/*/{Protheus.doc} fCrGPerg
Valida get dados de perguntas.

@param String cTipoVl(obrigatório): indica tipo de validação, se 'L', então
irá validar linha, se 'T', então irá validar tudo.
@author André Felipe Joriatti
@since 26/02/2013
@version MP11
@return boolean lRet: conforme resultado da validação
/*/
//---------------------------------------------------------------------

Static Function fCrGPerg( cTipoVl )

	Local lRet      := .T.
	Local lDel      := .F.
	Local nI        := 0
	Local nPosGrp   := GDFIELDPOS( "TJ3_CODGRU",oGetGrp:aHeader  ) // código do grupo
	Local nPosPerg  := GDFIELDPOS( "TJ3_PERGUN",oGetPerg:aHeader ) // campo de pergunta
	Local nPosEdtOp := GDFIELDPOS( "TJ3_COMBO" ,oGetPerg:aHeader ) // campo Editar Opc.
	Local nPosCpObs := GDFIELDPOS( "TJ3_ONMEMO",oGetPerg:aHeader ) // campo 'campo obs.'
	Local nPosTpRsp := GDFIELDPOS( "TJ3_TPLIST",oGetPerg:aHeader ) // campo tipo resposta
	Local nPosTGrp  := GDFIELDPOS( "TJ3_TIPGRP",oGetGrp:aHeader  ) // indica tipo do grupo

	If cTipoVl == "L"

		lDel := oGetPerg:aCols[oGetPerg:nAt][Len( oGetPerg:aCols[oGetPerg:nAt] )]
		If !lDel

			If !oGetGrp:aCols[oGetGrp:nAt][Len( oGetGrp:aCols[oGetGrp:nAt] )]

				If oGetGrp:aCols[oGetGrp:nAt][nPosTGrp] == "2"
					ShowHelpDlg( "",{ STR0016 },2,{ "" },2 ) // "Não é possível informar Questões para Grupo do tipo 'Rótulo'."
					oGetPerg:oBrowse:SetFocus()
					Return .F.
				EndIf

				// não permite perguntas dos tipos 'Múltiplas Opções'( 2 ) para grupo do tipo 'Titulo de Colunas'( 2 )
				If oGetPerg:aCols[oGetPerg:nAt][nPosTpRsp] $ "2" .And.;
				   NGSEEK( "TJ4",Padr( oGetGrp:aCols[oGetGrp:nAt][nPosGrp],TAMSX3( "TJ4_CODGRU" )[1] ),1,"TJ4->TJ4_TIPREG" ) == "2"

					ShowHelpDlg( "",{ STR0017 },2,{ "" },2 ) // "Não é possível inserir perguntas de 'Múltiplas Opções' caso grupo seja do tipo 'Título de colunas'."
					oGetPerg:oBrowse:SetFocus()
					Return .F.
				EndIf

				If Empty( oGetGrp:aCols[oGetGrp:nAt][nPosGrp] )
					ShowHelpDlg( "",{ STR0018 },2,{ STR0019 },2 ) // "Código do Grupo esta vazio." # "Preencha o Código do Grupo relacionado a essa pergunta."
					oGetPerg:oBrowse:SetFocus()
					Return .F.
				EndIf

				If NGSEEK( "TJ4",Padr( oGetGrp:aCols[oGetGrp:nAt][nPosGrp],TAMSX3( "TJ4_CODGRU" )[1] ),1,"TJ4->TJ4_TIPREG" ) $ "12"

					If Empty( oGetPerg:aCols[oGetPerg:nAt][nPosPerg] )

						ShowHelpDlg( "",{ STR0020 },2,{ STR0021 },2 ) // "A Pergunta é um campo obrigatório." # "Informe a Pergunta."
						oGetPerg:oBrowse:SetFocus()
						Return .F.
					Endif

					If Empty( oGetPerg:aCols[oGetPerg:nAt][nPosEdtOp] )
						If oGetPerg:aCols[oGetPerg:nAt][nPosCpObs] != "1" .And. !( oGetPerg:aCols[oGetPerg:nAt][nPosTpRsp] $ "345" )
							ShowHelpDlg( "",{ STR0022 },2,{ "" },2 ) // "É obrigatório informar a lista de Opções ou Campo Obs."
							oGetPerg:oBrowse:SetFocus()
							Return .F.
						EndIf
					EndIf

					If oGetPerg:aCols[oGetPerg:nAt][nPosTpRsp] $ "12" .And. Empty( oGetPerg:aCols[oGetPerg:nAt][nPosEdtOp] )
						ShowHelpDlg( "",{ STR0023 },2,{ STR0024 },2 ) // "Para pergunta do tipo 'Opção Exclusiva' ou 'Múltiplas Opções' é obrigatório informar as opções." # "Informe as opções."
						oGetPerg:oBrowse:SetFocus()
						Return .F.
					EndIf
				EndIf

			Else
				ShowHelpDlg( "",{ STR0025 },2,{ "" },2 ) // "Não é possível relacionar perguntas a um grupo deletado."
				oGetPerg:oBrowse:SetFocus()
				Return .F.
			EndIf

		EndIf

		// Insere ou altera registro no array geral da rotina
		fMngAGeral()

	ElseIf cTipoVl == "T"

		For nI := 1 To Len( oGetPerg:aCols )
			lDel := oGetPerg:aCols[nI][Len( oGetPerg:aCols[nI] )]
			If !lDel .And. NGSEEK( "TJ4",Padr( oGetGrp:aCols[oGetGrp:nAt][nPosGrp],TAMSX3( "TJ4_CODGRU" )[1] ),1,"TJ4->TJ4_TIPREG" ) $ "12"

				If Empty( oGetPerg:aCols[nI][nPosPerg] )

					ShowHelpDlg( "",{ STR0020 },2,{ STR0021 },2 ) // "A Pergunta é um campo obrigatório." # "Informe a Pergunta."
					Return .F.
				EndIf

				If Empty( oGetPerg:aCols[nI][nPosEdtOp] )
					If oGetPerg:aCols[nI][nPosCpObs] != "1" .And. !( oGetPerg:aCols[nI][nPosTpRsp] $ "345" ) 
						ShowHelpDlg( "",{ STR0022 },2,{ "" },2 ) // "É obrigatório informar a lista de Opções ou Campo Obs."
						Return .F.
					EndIf
				EndIf

				// não deixa incluir perguntas do tipo 'Multiplas Opções'( 2 ) caso tipo do grupo seja 'Titulo de Colunas'( 2 )
				If oGetPerg:aCols[nI][nPosTpRsp] == "2" .And.;
				   NGSEEK( "TJ4",Padr( oGetGrp:aCols[oGetGrp:nAt][nPosGrp],TAMSX3( "TJ4_CODGRU" )[1] ),1,"TJ4->TJ4_TIPREG" ) == "2"

					ShowHelpDlg( "",{ STR0026 },2,{ "" },2 ) // "Não é possível inserir perguntas de 'Múltiplas Opções' caso grupo seja do tipo 'Título de colunas'."
					Return .F.
				EndIf

				If oGetPerg:aCols[nI][nPosTpRsp] $ "12" .And. Empty( oGetPerg:aCols[nI][nPosEdtOp] )
					ShowHelpDlg( "",{ STR0027 },2,{ STR0028 },2 ) // "Para pergunta do tipo 'Opção Exclusiva' ou 'Múltiplas Opções' é obrigatório informar as opções." # "Informe as opções."
					Return .F.
				EndIf

			EndIf
		Next nI
	EndIf

Return lRet

//---------------------------------------------------------------------
/*/{Protheus.doc} MDT999OK
Valida tela de questionário

@param integer nOpcx(obrigatório): indica o tipo de operação atual.

@author André Felipe Joriatti
@since 26/02/2013
@version MP11
@return boolean lRet: conforme resultado da validação
/*/
//---------------------------------------------------------------------

Function MDT999OK( nOpcx )

	Local lRet        := .T.
	Local aArea       := GetArea()
	Local nI          := 0
	Local nQtdePgsGrp := 0
	Local cDcGrp      := ""
	Local aClsGrupo   := {}
	Local nPosGrp     := GDFIELDPOS( "TJ3_CODGRU",oGetGrp:aHeader )

	//--------------------------------
	// Valida integridade referencial
	//--------------------------------
	If nOpcx == 5
		lRet := !fVRelMDT999() // Se possui relacionamento
	EndIf

	If lRet .And. Empty( M->TJ2_QUESTI )
		ShowHelpDlg( "",{ STR0066 },2,{ STR0067 },2 ) // "Campo Questionário vazio" ## "Informe o campo de Questionário."
		lRet := .F.
	EndIf

	If lRet .And. Empty( M->TJ2_NOMQUE )
		ShowHelpDlg( "",{ STR0061 },2,{ STR0062 },2 ) // "Campo 'Nome Quest.' vazio." # "Informe o Nome do Questionário."
		lRet := .F.
	EndIf

	//------------------------------------------------------------------------
	// Caso grupo do tipo título de colunas, então a quantidade de perguntas
	// dele deve ser igual a quantidade de colunas definida na descrição
	//------------------------------------------------------------------------
	If lRet .And. cValToChar( nOpcx ) $ "34" // Inclusão/Alteração
		lRet := fCrGPerg( "T" ) .And. fCrGGrp( "T" )

		If lRet
			For nI := 1 To Len( oGetGrp:aCols )
				nQtdePgsGrp := 0

				If !oGetGrp:aCols[nI][Len( oGetGrp:aCols[nI] )]
					If NGSEEK( "TJ4",PadR( oGetGrp:aCols[nI][nPosGrp],TAMSX3( "TJ4_CODGRU" )[1] ),01,"TJ4->TJ4_TIPREG" ) == "2"

						cDcGrp := NGSEEK( "TJ4",PadR( oGetGrp:aCols[nI][nPosGrp],TAMSX3( "TJ4_CODGRU" )[1] ),01,"TJ4->TJ4_DESCRI" )

						// Atribui para nQtdePgsGrp a quantidade de perguntas do grupo
						aEval( aAGeral,{ |x| If( AllTrim( x[_CODGRU_] ) == AllTrim( oGetGrp:aCols[nI][nPosGrp] ) .And. !x[_DEL_] .And. !Empty( x[_QUESTA_] ) , nQtdePgsGrp++ ,  ) } )

						aClsGrupo := StrToKArr( cDcGrp,"*" )

						If Len( aClsGrupo ) != nQtdePgsGrp
							ShowHelpDlg( "",{ STR0068 + oGetGrp:aCols[nI][nPosGrp] + STR0069 + ; // "Número de Perguntas do grupo: " ## " está diferente da quantidade "
											  STR0070 },2,{ "" },2 ) // "de colunas especificadas na descrição do grupo."
							lRet := .F.
							Exit
						EndIf

					EndIf
				EndIf
			Next nI
		EndIf
	EndIf

	RestArea( aArea )

Return lRet

//---------------------------------------------------------------------
/*/{Protheus.doc} fMngAGeral
Gerencia registros no array geral, insere, altera ou deleta ( caso cOper
seja informado como D).

@param String cOper: n obrigat. caso informado, só pode ser informado
como D, se for informado, indica que deve deletar o registro do array

@author André Felipe Joriatti
@since 26/02/2013
@version MP11
@return Nil
/*/
//---------------------------------------------------------------------

Static Function fMngAGeral( cOper )

	Local nRecnoAG  := 0
	Local lDel      := .F.
	Local nPosGrp   := GDFIELDPOS( "TJ3_CODGRU",oGetGrp:aHeader  )
	Local nPosOGrp  := GDFIELDPOS( "TJ3_ORDGRP",oGetGrp:aHeader  )
	local nPosTGrp  := GDFIELDPOS( "TJ3_TIPGRP",oGetGrp:aHeader  )
	Local nPosQue   := GDFIELDPOS( "TJ3_QUESTA",oGetPerg:aHeader )
	Local nPosPerg  := GDFIELDPOS( "TJ3_PERGUN",oGetPerg:aHeader )
	Local nPosIndS  := GDFIELDPOS( "TJ3_INDSEX",oGetPerg:aHeader )
	Local nPosCmb   := GDFIELDPOS( "TJ3_COMBO",oGetPerg:aHeader  )
	Local nPosTpl   := GDFIELDPOS( "TJ3_TPLIST",oGetPerg:aHeader )
	Local nPosOM    := GDFIELDPOS( "TJ3_ONMEMO",oGetPerg:aHeader )
	Local nPosOrd   := GDFIELDPOS( "TJ3_ORDEM",oGetPerg:aHeader  )
	Local nPosTam   := GDFIELDPOS( "TJ3_TAM",oGetPerg:aHeader    )
	Local nPosFmat  := GDFIELDPOS( "TJ3_FORMAT",oGetPerg:aHeader )
	Local nPosForm  := GDFIELDPOS( "TJ3_FORMUL",oGetPerg:aHeader )
	Local nPosCato  := GDFIELDPOS( "TJ3_CATOT",oGetPerg:aHeader  )

	Local aPergunta := Array( _DEL_ )

	// Tenta encontrar pergunta no array geral
	nRecnoAG := aScan( aAGeral, { |x| ( AllTrim( x[_CODGRU_] ) + AllTrim( x[_QUESTA_] ) ) == AllTrim( oGetGrp:aCols[oGetGrp:nAt][nPosGrp] ) +;
										AllTrim( oGetPerg:aCols[oGetPerg:nAt][nPosQue] ) } )

	If cOper == "D" // deleta registro do array
		If nRecnoAG != 0
			// marca o registro como inverso do que ele esta.
			lDel := aAGeral[nRecnoAG][_DEL_]
			aAGeral[nRecnoAG][_DEL_] := !lDel
		EndIf
	Else // insere ou altera registro do array

		aPergunta[_CODGRU_] := oGetGrp:aCols[oGetGrp:nAt][nPosGrp]
		aPergunta[_ORDGRP_] := oGetGrp:aCols[oGetGrp:nAt][nPosOGrp]
		aPergunta[_TIPGRP_] := oGetGrp:aCols[oGetGrp:nAt][nPosTGrp]
		aPergunta[_QUESTA_] := oGetPerg:aCols[oGetPerg:nAt][nPosQue]
		aPergunta[_PERGUN_] := oGetPerg:aCols[oGetPerg:nAt][nPosPerg]
		aPergunta[_INDSEX_] := oGetPerg:aCols[oGetPerg:nAt][nPosIndS]
		aPergunta[_COMBO_]  := If( !Empty( M->TJ3_COMBO ),M->TJ3_COMBO,oGetPerg:aCols[oGetPerg:nAt][nPosCmb] )
		aPergunta[_TPLIST_] := oGetPerg:aCols[oGetPerg:nAt][nPosTpl]
		aPergunta[_ONMEMO_] := oGetPerg:aCols[oGetPerg:nAt][nPosOM]
		aPergunta[_ORDEM_]  := oGetPerg:aCols[oGetPerg:nAt][nPosOrd]
		aPergunta[_TAM_]    := oGetPerg:aCols[oGetPerg:nAt][nPosTam]
		aPergunta[_FORMAT_] := oGetPerg:aCols[oGetPerg:nAt][nPosFmat]
		aPergunta[_FORMUL_] := oGetPerg:aCols[oGetPerg:nAt][nPosForm]
		aPergunta[_CATOT_]  := oGetPerg:aCols[oGetPerg:nAt][nPosCato]

		//-------------------------------------------------------
		// tratamento especial para o campo default porque ele
		// não vai na get dados, apenas no array aageral
		//-------------------------------------------------------
		cDflt               := If( nRecnoAG != 0,aAGeral[nRecnoAG][_DEFAUL_]," " )
		aPergunta[_DEFAUL_] := If( !Empty( M->TJ3_DEFAUL ),M->TJ3_DEFAUL,If ( Type( "cDflt" ) == "C" .And. ValType( cDflt ) == "C",cDflt," " ) )
		aPergunta[_DEL_]    := oGetPerg:aCols[oGetPerg:nAt][Len( oGetPerg:aCols[oGetPerg:nAt] )]

		// Inserção de nova pergunta
		If nRecnoAG == 0
			aAdd( aAGeral,aPergunta )
		Else // alteração de pergunta já existente
			aAGeral[nRecnoAG] := {}
			aAGeral[nRecnoAG] := aPergunta
		EndIf

	EndIf

	M->TJ3_DEFAUL := " "
	M->TJ3_COMBO  := Space( nTamComb )

Return Nil

//---------------------------------------------------------------------
/*/{Protheus.doc} fDelPerg
Validação de deleção da pergunta, invoca função que deleta a pergunta
deletada na get dados no array geral da rotina.

@author André Felipe Joriatti
@since 26/02/2013
@version MP11
@return boolean lRet: sempre true.
/*/
//---------------------------------------------------------------------

Static Function fDelPerg()

	Local lRet     := .F.
	Local nPosPerg := GDFIELDPOS( "TJ3_QUESTA",oGetPerg:aHeader ) // campo de pergunta
	Local nPosTGrp := GDFIELDPOS( "TJ3_TIPGRP",oGetGrp:aHeader )  // tipo do grupo

	If !NGIFDBSEEK( "TJ5",M->TJ2_QUESTI + Padr( oGetPerg:aCols[n][nPosPerg],TAMSX3( "TJ5_PERG" )[1] ),2,.F. )
		If !IsInCallStack( "fDelGrp" ) .And. oGetGrp:aCols[oGetGrp:nAt][nPosTGrp] != "2"
			lRet := .T.
			fMngAGeral( "D" )
		Else
			ShowHelpDlg( "",{ STR0031 },2,{ "" },2 ) // "É preciso deixar uma linha em branco para Grupo do tipo 'Rótulo'."
		EndIf
	Else
		ShowHelpDlg( "",{ STR0032 },2,{ "" },2 ) // "Não é possível deletar a pergunta pois ela já foi respondida em um Questionário."
	EndIf

	oGetPerg:oBrowse:SetFocus()

Return lRet

//---------------------------------------------------------------------
/*/{Protheus.doc} fDelGrp
Validação de deleção do grupo de perguntas na get dados de grupos.
Impede usuário de excluir grupo caso o mesmo possua perguntas relacionadas.

@author André Felipe Joriatti
@since 26/02/2013
@version MP11
@return boolean lRet: conforme validação
/*/
//---------------------------------------------------------------------

Static Function fDelGrp()

	Local lRet     := .T.
	Local nI       := 0
	Local nCntGrps := 0 // conta número de grupos iguais no acols de oGetGrp
	Local nPosGrp  := GDFIELDPOS( "TJ3_CODGRU",oGetGrp:aHeader )
	Local nRecnGer := 0

	// nRecnGer := aScan( aAGeral, { |x| !x[_DEL_] .And. x[_CODGRU_] == oGetGrp:aCols[oGetGrp:nAt][nPosGrp] } )

	For nI := 1 To Len( aAGeral )
		If !aAGeral[nI][_DEL_] .And. AllTrim( aAGeral[nI][_CODGRU_] ) == AllTrim( oGetGrp:aCols[oGetGrp:nAt][nPosGrp] ) .And. !Empty( aAGeral[nI][_PERGUN_] )
			nRecnGer := 1
		EndIf
	Next nI

	// se houver dois grupos com o mesmo codigo, então permite deletar ao menos 1
	For nI := 1 To Len( oGetGrp:aCols )
		If oGetGrp:aCols[nI][nPosGrp] == oGetGrp:aCols[oGetGrp:nAt][nPosGrp] .And. !oGetGrp:aCols[nI][Len( oGetGrp:aCols[nI] )]
			nCntGrps++
		EndIf
	Next nI

	If nRecnGer > 0 .And. nCntGrps == 1
		lRet := .F.
		ShowHelpDlg( "",{ STR0033 },2,; // "Não é possível deletar Grupo pois ele está relacionado a uma ou mais perguntas."
						{ STR0034 },2 ) // "Primeiramente exclua suas perguntas."
	EndIf

	// Deleta grupo 'Totalizador' do array aAgeral
	If lRet
		For nI := 1 To Len( aAGeral )
			If AllTrim( aAGeral[nI][_CODGRU_] ) == AllTrim( oGetGrp:aCols[oGetGrp:nAt][nPosGrp] ) .And. Empty( aAGeral[nI][_PERGUN_] ) // Grupos totalizadores vão possuir o aAGeral[nI][_PERGUN_] vazio
				aAGeral[nI][_DEL_] := !aAGeral[nI][_DEL_]
			EndIf
		Next nI
	EndIf

	oGetGrp:oBrowse:SetFocus()

Return lRet

//---------------------------------------------------------------------
/*/{Protheus.doc} MDT999ICQT
X3_RELACAO do campo TJ3_QUESTA, incrementa a questão.

@author André Felipe Joriatti
@since 27/02/2013
@version MP11
@return string cNextQt: próximo número da questão na get dados.
/*/
//---------------------------------------------------------------------

Function MDT999ICQT()

	Local nTamQt     := TAMSX3( "TJ3_QUESTA" )[1]
	Local cNextQt    := StrZero( 1,nTamQt )
	Local nI         := 0

	For nI := 1 To Len( aAGeral )
		cNextQt := If( aAGeral[nI][_QUESTA_] > cNextQt,aAGeral[nI][_QUESTA_],cNextQt )
	Next nI
	cNextQt := Soma1( cNextQt )

	// para controlar quando for a primeira chamada
	// na inicialização do primeiro acols de perguntas quando
	// entra na rotina.
	If Len( aAGeral ) == 1 .And. Empty( aAGeral[1][_QUESTA_] ) .And. Empty( aAGeral[1][_CODGRU_] )
		cNextQt := StrZero( 1,nTamQt ) // seta como 0001
	EndIf

Return cNextQt

//---------------------------------------------------------------------
/*/{Protheus.doc} MDT999IORD
X3_RELACAO do campo TJ3_ORDEM, incrementa a ordem.

@author André Felipe Joriatti
@since 27/02/2013
@version MP11
@return string cNextOrd: número da próxima ordem disponível.
/*/
//---------------------------------------------------------------------

Function MDT999IORD()

	Local nTamOrd  := TAMSX3( "TJ3_ORDEM" )[1]
	Local cNextOrd := StrZero( 1,nTamOrd )
	Local nI       := 0
	Local nPosGrp  := 0
	Local cGrupo   := ""

	If Type( "oGetGrp" ) == "O"
		nPosGrp := GDFIELDPOS( "TJ3_CODGRU",oGetGrp:aHeader )
		cGrupo  := oGetGrp:aCols[oGetGrp:nAt][nPosGrp]
	EndIf

	For nI := 1 To Len( aAGeral )
		If !Empty( cGrupo ) .And. AllTrim( aAGeral[nI][_CODGRU_] ) != AllTrim( cGrupo )
			Loop
		ElseIf Empty( cGrupo )
			Loop
		EndIf
		cNextOrd := If( aAGeral[nI][_ORDEM_] > cNextOrd,aAGeral[nI][_ORDEM_],cNextOrd )
	Next nI

	//-----------------------------------------------------------
	// Para controlar quando for a primeira chamada
	// na inicialização do primeiro acols de perguntas quando
	// entra na rotina.
	//-----------------------------------------------------------
	If Len( aAGeral ) == 1 .And. Empty( aAGeral[1][_QUESTA_] ) .And. Empty( aAGeral[1][_CODGRU_] )
		cNextOrd := StrZero( 1,nTamOrd ) // seta como 001
	Else
		// Caso seja a primeira linha de um grupo novo
		If IsInCallStack( "fChgGrp" )
			cNextOrd := "001"
		Else
			cNextOrd := Soma1( cNextOrd )
		EndIf
	EndIf

Return cNextOrd

//---------------------------------------------------------------------
/*/{Protheus.doc} MDT999WBOX
When do campo TJ3_COMBO, abre essa função quando tenta entrar no campo
tela para informar as opções do combo da pergunta.

@author André Felipe Joriatti
@since 27/02/2013
@version MP11
@return boolean lRet: sempre falso
/*/
//---------------------------------------------------------------------

Function MDT999WBOX()

	Local lRet := .F.
	Local nXX
	Local nPosCmp  := GDFIELDPOS( "TJ3_COMBO",oGetPerg:aHeader )
	Local nPosGrp  := GDFIELDPOS( "TJ3_CODGRU",oGetGrp:aHeader )
	Local nPosPer  := GDFIELDPOS( "TJ3_QUESTA",oGetPerg:aHeader )
	Local nPosTList := GDFIELDPOS( "TJ3_TPLIST",oGetPerg:aHeader )
	Local oChecked  := LoadBitmap( GetResources(),"LBTIK" )
	Local oUnCheck  := LoadBitmap( GetResources(),"LBNO"  )
	Local aCodBox   := {	"1","2","3","4","5","6","7","8","9",;
						"A","B","C","D","E","F","G","H","I",;
						"J","K","L","M","N","O","P","Q","R",;
						"S","T","U","V","W","X","Y","Z" }
	Local nRecGeral
	Local cPeso    := ""
	Local nPosPeso := 0
	Local nI       := 0

	Private oBoxPerg
	Private aBoxPerg
	Private bBoxPerg

	If !( oGetPerg:aCols[oGetPerg:nAt][nPosTList] $ "12" )
		Return .F.
	EndIf
	nRecGeral     := aScan( aAGeral, { |x| x[_CODGRU_] + x[_QUESTA_] == oGetGrp:aCols[oGetGrp:nAt][nPosGrp] + oGetPerg:aCols[oGetPerg:nAt][nPosPer] } )
	M->TJ3_DEFAUL := If( !Empty( M->TJ3_DEFAUL ),M->TJ3_DEFAUL,If( nRecGeral != 0,aAGeral[nRecGeral][_DEFAUL_],Space( TAMSX3( "TJ3_DEFAUL" )[1] ) ) )

	M->TJ3_COMBO  := oGetPerg:aCols[oGetPerg:nAt,nPosCmp]
	aBoxPerg      := {}

	aOptions := StrTokArr( M->TJ3_COMBO, ";" )

	For nI := 1 To Len( aCodBox )
		nPos     := aScan( aOptions,{ |x| SubStr( x,1,2 ) == aCodBox[nI] + "=" } )
		If nPos != 0
			nPosPeso := At( "*P:",aOptions[nPos] )
			nPosFim  := If( nPosPeso != 0,nPosPeso - 3,Len( aOptions[nPos] ) )
			cDesc    := SubStr( aOptions[nPos],3,nPosFim )
			cPeso    := SubStr( aOptions[nPos],nPosPeso + 3,3 )
			cPeso    := If( nPosPeso != 0,cPeso,Space( 3 ) )
			aAdd( aBoxPerg , { .T.,aCodBox[nI],PadR( cDesc,30 ),cPeso } )
		Else
			aAdd( aBoxPerg , { .F.,aCodBox[nI],Space( 30 ),Space( 3 ) } )
		EndIf
	Next nI

	opcaoZZ := 0

	Define MsDialog oDlgOpcs Title OemToAnsi( STR0035 ) From 010,015 To 030,070 COLOR CLR_BLACK,CLR_WHITE Of oMainwnd // "Editar Lista de Opções"

		@ 005,009  Say STR0036 Of oDlgOpcs Pixel // "Configure a lista de opções:"

		oBoxPerg := VCBrowse():New( 017,010,200,110,,{ " ",STR0037,STR0038,STR0039 },{ 10,20,130,100 },; // "Opção" ### "Descrição" ### "Peso"
									oDlgOpcs,,,,,{ || },,,,,,,.F.,,.T.,,.F.,,.T.,.T. )
		oBoxPerg:SetArray( aBoxPerg )
		bBoxPerg            := { || { If( aBoxPerg[oBoxPerg:nAt,1],oChecked,oUnCheck ),aBoxPerg[oBoxPerg:nAt,2],aBoxPerg[oBoxPerg:nAt,3],aBoxPerg[oBoxPerg:nAt,4] } }
		oBoxPerg:bLine      := bBoxPerg
		oBoxPerg:bLDblClick := { || fMarkOpca( oBoxPerg:nColPos ) }

		@ 135,010 Say STR0040 Of oDlgOpcs Pixel  // "Opção Default"
		@ 135,047 MsGet M->TJ3_DEFAUL Picture "@!" Size 010,009 Pixel

		Define sButton From 135,155 Type 1 Enable Of oDlgOpcs Action ( If( fValTRBX2(),( opcaoZZ := 1,oDlgOpcs:End() ),opcaoZZ := 0 ) ) // Ok
		Define sButton From 135,185 Type 2 Enable Of oDlgOpcs Action oDlgOpcs:End() // Cancelar

	Activate MsDialog oDlgOpcs Centered

Return lRet

//---------------------------------------------------------------------
/*/{Protheus.doc} fValTRBX2
Valida confirmação da tela de opções da pergunta.

@author André Felipe Joriatti
@since 28/02/2013
@version MP11
@return boolean lRet: conforme validação
/*/
//---------------------------------------------------------------------

Static Function fValTRBX2()

	Local lRet    := .T.
	Local nI
	Local nPosCmp := GDFIELDPOS( "TJ3_COMBO",oGetPerg:aHeader )

	If !Empty( M->TJ3_DEFAUL )
		lRet := !( aScan( aBoxPerg,{ |x| x[1] .And. x[2] == AllTrim( M->TJ3_DEFAUL ) } ) == 0 )
	EndIf

	If !lRet
		MsgInfo( STR0065 ) // "A opção default não corresponde a um item entre as opções."
	Else
		M->TJ3_COMBO := ""

		For nI := 1 To Len( aBoxPerg )
			If aBoxPerg[nI][1] .And. !Empty( aBoxPerg[nI][3] )
				If !Empty( M->TJ3_COMBO )
					M->TJ3_COMBO += ";"
				Endif
				M->TJ3_COMBO += aBoxPerg[nI][2] + "=" + AllTrim( SubStr( aBoxPerg[nI][3],1,30 ) )
				If !Empty( aBoxPerg[nI][4] )
					M->TJ3_COMBO += "*P:" + StrZero( Val( AllTrim( aBoxPerg[nI][4] ) ),3 )
				EndIf
			EndIf
		Next nI

		If Len( M->TJ3_COMBO ) > 250
			MsgInfo( STR0042 ) // "A quantidade de caracteres no campo Editar Opc. ultrapassou 250."
			lRet := .F.
		ElseIf Empty( M->TJ3_COMBO )
			M->TJ3_COMBO := "1=" + STR0043 + ";" + "2=" + STR0044 + ";" + "3=" + STR0045 // "Sim"###"Nao"###"Sem Resposta"
			MsgInfo( STR0046 ) // "Nenhum item foi selecionado, portanto, serão consideradas as opções padrão (Sim, Não e Sem Resposta)."
		Endif
		If lRet
			oGetPerg:aCols[oGetPerg:nAt][nPosCmp] := PadR( M->TJ3_COMBO,250 )
		EndIf
	EndIf

Return lRet

//---------------------------------------------------------------------
/*/{Protheus.doc} fMarkOpca
Marca ou desmarca oções da markbrowse de oções da pergunta.

@param int nColuna: coluna
@author André Felipe Joriatti
@since 28/02/2013
@version MP11
@return Nil
/*/
//---------------------------------------------------------------------

Static Function fMarkOpca( nColuna )

	Local nAntes3
	Local cPeso   := ""
	Local nI      := 0

	If !aBoxPerg[oBoxPerg:nAt][1]
		nAntes3 := aBoxPerg[oBoxPerg:nAt][3]
		lEditCell( @aBoxPerg,oBoxPerg,'',3 ) // campo para descrição da opção
		lEditCell( @aBoxPerg,oBoxPerg,'',4 ) // campo para informar o peso
		If !Empty( aBoxPerg[oBoxPerg:nAt][3] )
			If "=" $ aBoxPerg[oBoxPerg:nAt][3] .Or. ";" $ aBoxPerg[oBoxPerg:nAt][3]
				aBoxPerg[oBoxPerg:nAt][3] := nAntes3
				MsgInfo( STR0048 + STR0049 ) // "Os seguintes caracteres não poderão ser utilizados: "###"= (sinal de igualdade) ou ; (ponto e virgula)"
				Return
			Endif

			If !Empty( aBoxPerg[oBoxPerg:nAt][4] )
				cPeso := alltrim( aBoxPerg[oBoxPerg:nAt][4] )
				For nI := 1 To len( cPeso )
					if !( substr( cPeso,nI,1 ) $ "0123456789" )
						MsgStop( STR0050 ) // "Informe apenas números no campo 'Peso'."
						aBoxPerg[oBoxPerg:nAt][4] := Space( 3 )
						Return
					EndIf
				Next nI
			Endif

			// Se o parametro for informado corretamente, a listbox é atualizada
			aBoxPerg[oBoxPerg:nAt][1] := .T.
			aBoxPerg[oBoxPerg:nAt][3] := PadR( aBoxPerg[oBoxPerg:nAt][3],30 )
			aBoxPerg[oBoxPerg:nAt][4] := PadR( aBoxPerg[oBoxPerg:nAt][4],3 )
			oBoxPerg:Refresh()
		Else
			aBoxPerg[oBoxPerg:nAt][1] := .F.
			aBoxPerg[oBoxPerg:nAt][3] := Space( 30 )
			aBoxPerg[oBoxPerg:nAt][4] := Space( 3 )
			oBoxPerg:Refresh()
		Endif
	Else
		// Caso o usuario desmarque o checkbox
		aBoxPerg[oBoxPerg:nAt][1] := .F.
		aBoxPerg[oBoxPerg:nAt][3] := Space( 30 )
		aBoxPerg[oBoxPerg:nAt][4] := Space( 3 )
		oBoxPerg:Refresh()
	Endif

Return

//---------------------------------------------------------------------
/*/{Protheus.doc} MDT999VFML
Função que valida a fórmula informada no registro.

@author André Felipe Joriatti
@since 11/03/2013
@version MP11
@return boolean lRet: conforme validação
/*/
//---------------------------------------------------------------------

Function MDT999VFML()

	Local lRet      := .T.
	Local nPosTipPg := GDFIELDPOS( "TJ3_TPLIST",oGetPerg:aHeader )

	If oGetPerg:aCols[oGetPerg:nAt][nPosTipPg] != "5"
		MsgStop( STR0051 ) // "Pergunta deve ser do tipo Resultado da Fórmula para habilitar o campo Fórmula."
		lRet := .F.
	EndIf

Return lRet

//---------------------------------------------------------------------
/*/{Protheus.doc} MDT999TPL
Valid do campo TJ3_TPLIST.

@author André Felipe Joriatti
@since 13/03/2013
@version MP11
@return boolean lRet: sempre true.
/*/
//---------------------------------------------------------------------

Function MDT999TPL()

	Local lRet      := .T.
	Local nPosForm  := GDFIELDPOS( "TJ3_FORMUL",oGetPerg:aHeader )
	Local nPosPict  := GDFIELDPOS( "TJ3_FORMAT",oGetPerg:aHeader )
	Local nPosCombo := GDFIELDPOS( "TJ3_COMBO",oGetPerg:aHeader )
	Local nPosTam   := GDFIELDPOS( "TJ3_TAM",oGetPerg:aHeader )

	If M->TJ3_TPLIST != "5" // Fórmula
		oGetPerg:aCols[oGetPerg:nAt][nPosForm] := Space( TAMSX3( "TJ3_FORMUL" )[1] )
	EndIf

	If !( M->TJ3_TPLIST $ "45" ) // Texto Descritivo
		oGetPerg:aCols[oGetPerg:nAt][nPosPict] := Space( TAMSX3( "TJ3_FORMAT" )[1] )
	EndIf

	If M->TJ3_TPLIST != "3" // Texto Descritivo
		oGetPerg:aCols[oGetPerg:nAt][nPosTam] := 0
	EndIf

	If !( M->TJ3_TPLIST $ "12" ) // Opção Exclusiva,Múltiplas Opções
		oGetPerg:aCols[oGetPerg:nAt][nPosCombo] := Space( TAMSX3( "TJ3_COMBO" )[1] )
	EndIf

Return lRet

//---------------------------------------------------------------------
/*/{Protheus.doc} MDT999VF
valida campo de formato TJ3_FORMAT.

@author André Felipe Joriatti
@since 27/03/2013
@version MP11
@return boolean lRet: conforme validação
/*/
//---------------------------------------------------------------------

Function MDT999VF()

	Local nPosTipPg := GDFIELDPOS( "TJ3_TPLIST",oGetPerg:aHeader )
	Local nI        := 0
	Local lRet      := .T.
	Local lInvalid  := .T.
	Local lVirgula  := .F.

	If oGetPerg:aCols[N][nPosTipPg] != "4" // deve ser numérico para informar o formato
		lRet := .F.
		MsgStop( STR0052 ) // "Informe o formato apenas para perguntas do tipo numérico."
	Else
		For nI := Len( AllTrim( M->TJ3_FORMAT ) ) To 1 Step -1
			If !( SubStr( AllTrim( M->TJ3_FORMAT ),nI,1 ) $ "9,." )
				lInvalid := .F.
				lRet := .F.
				Exit
			EndIf
			If SubStr( AllTrim( M->TJ3_FORMAT ),nI,1 ) == ","
				lVirgula := .T.
			EndIf
			If lVirgula .And. SubStr( AllTrim( M->TJ3_FORMAT ),nI,1 ) == "."
				lInvalid := .F.
				lRet := .F.
				Exit
			EndIf
			If SubStr(M->TJ3_FORMAT,1,1) == "."
				lInvalid := .F.
				lRet := .F.
				Exit
			Endif
		Next nI
		If !lInvalid
			ShowHelpDlg( "",{ STR0053 },2,; // "Formato Inválido."
							{ STR0054 },2 ) // "Utilize apenas os símbolos '9 , .' para definir o formato, como por exemplo 9.99"
		EndIf
	EndIf

Return lRet

//---------------------------------------------------------------------
/*/{Protheus.doc} MDT999VTAM
Valida campo TJ3_TAM

@author André Felipe Joriatti
@since 27/03/2013
@version MP11
@return boolean lRet: conforme validação
/*/
//---------------------------------------------------------------------

Function MDT999VTAM()

	Local lRet      := .T.
	Local nPosTipPg := GDFIELDPOS( "TJ3_TPLIST",oGetPerg:aHeader )

	If oGetPerg:aCols[oGetPerg:nAt][nPosTipPg] != "3"
		ShowHelpDlg( "",{ STR0055 },2,{ "" },2 ) // "Informe o tamanho apenas para campos do tipo Texto Descritivo."
		lRet := .F.
	Else
		If M->TJ3_TAM > 40
			ShowHelpDlg( "",{ STR0056 },2,{ STR0057 },2 ) // "Tamanho não pode ser maior que 40." # "Informe um valor igual ou inferior a 40."
			lRet := .F.
		EndIf
	EndIf

Return lRet

//---------------------------------------------------------------------
/*/{Protheus.doc} fVRelMDT999
Valida integridade relacional para Questionario.

@author André Felipe Joriatti
@since 27/03/2013
@version MP11
@return boolean lRet: true se estiver relacionado a algum registro na TJ1
/*/
//---------------------------------------------------------------------

Static Function fVRelMDT999()

	Local lRet := .T.

	NGDBAREAORDE( "TJ1",01 ) // TJ1_FILIAL+TJ1_QUESTI+DTOS( TJ1_DTINC )+TJ1_FUNC+TJ1_TAR+TJ1_CC+TJ1_AMB+TJ1_LOC+TJ1_MAT+TJ1_OSSIMU
	If ( lRet := DbSeek( xFilial( "TJ1" ) + PadR( TJ2->TJ2_QUESTI,TAMSX3( "TJ1_QUESTI" )[1] ) ) )
		ShowHelpDlg( "",{ STR0058 },2,{ "" },2 ) // "Este questionário já foi respondido, portanto não poderá ser excluído."
	EndIf

Return lRet

//---------------------------------------------------------------------
/*/{Protheus.doc} MDT999OGRP
X3_RELACAO do campo TJ3_ORDGRP, incrementa a ordem do grupo.

@author André Felipe Joriatti
@since 02/04/2013
@version MP11
@return string cNextOrd: número da próxima ordem disponível.
/*/
//---------------------------------------------------------------------

Function MDT999OGRP()

	Local cNextOrder := StrZero( 1,nTamOGrp )
	Local nI         := 0

	For nI := 1 To len( aAGeral )
		cNextOrder := If( aAGeral[nI][_ORDGRP_] > cNextOrder,aAGeral[nI][_ORDGRP_],cNextOrder )
	Next nI
	cNextOrder := Soma1( cNextOrder )

	//--------------------------------------------------------------------------
	// para controlar quando for a primeira chamada na inicilização do primeiro
	// acols de perguntas quando entra na rotina
	//--------------------------------------------------------------------------
	If len( aAGeral ) == 1 .And. Empty( aAGeral[1][_QUESTA_] ) .And. Empty( aAGeral[1][_CODGRU_] )
		cNextOrder := StrZero( 1,nTamOGrp ) // Seta como 001
	EndIf

Return cNextOrder

//---------------------------------------------------------------------
/*/{Protheus.doc} MDT999IMP
Função para  imprimir questionário em branco.

@author André Felipe Joriatti
@since 02/04/2013
@version MP11
/*/
//---------------------------------------------------------------------

Function MDT999IMP()
	MDTR910()
Return Nil

//---------------------------------------------------------------------
/*/{Protheus.doc} MDT999OGV
Função para validação do campo TJ3_ORDGRP.

@author André Felipe Joriatti
@since 03/04/2013
@version MP11
/*/
//---------------------------------------------------------------------

Function MDT999OGV()

	Local lRet 		:= .T.
	Local nPosOrdem := GDFIELDPOS( "TJ3_ORDGRP",oGetGrp:aHeader )
	Local nI	    := 0

	For nI := 1 To Len( oGetGrp:aCols )
		If AllTrim( oGetGrp:aCols[nI][nPosOrdem] ) == AllTrim( M->TJ3_ORDGRP )
			ShowHelpDlg( "",{ STR0059 },2,{ STR0060 },2 ) // "Não podem existir Ordens iguais para os grupos." # "Informe uma Ordem Diferente."
			lRet := .F.
		EndIf
	Next nI

Return lRet

//---------------------------------------------------------------------
/*/{Protheus.doc} MDTTJ3GRP
Valid do grupo de questões

@author André Felipe Joriatti
@since 09/04/2013
@version MP11
/*/
//---------------------------------------------------------------------

Function MDTTJ3GRP()

	Local lRet     := .T.
	Local nPosGrp  := GDFIELDPOS( "TJ3_CODGRU",oGetGrp:aHeader )
	Local nI
	Local nPosAlt  := 0
	Local cValor   := ""
	Local cCodGrp := oGetGrp:aCols[oGetGrp:nAt][nPosGrp]

	If ReadVar() == "M->TJ3_CODGRU"
		nPosAlt := _CODGRU_
		cValor  := M->TJ3_CODGRU

		//---------------------------------------------------------------------
		// Caso grupo do tipo Total ou Total por colunas da seção de perguntas
		//---------------------------------------------------------------------
		If NGSEEK( "TJ4",Padr( M->TJ3_CODGRU,TAMSX3( "TJ4_CODGRU" )[1] ),01,"TJ4->TJ4_TIPREG" ) $ "34"
			// Exclui perguntas que tenham sido relacionadas ao grupo
			fExcQsts( cCodGrp )

			oGetPerg:oBrowse:Refresh()
			oGetPerg:oBrowse:Disable()
		Else
			oGetPerg:oBrowse:Enable()
		EndIf

	ElseIf ReadVar() == "M->TJ3_TIPGRP"
		nPosAlt := _TIPGRP_
		cValor  := M->TJ3_TIPGRP

		// Caso grupo de perguntas do tipo rótulo então desabilita as perguntas.
		If cValor == "2"
			// Exclui perguntas que tenham sido relacionadas ao grupo
			fExcQsts( cCodGrp )

			// Desativa get dados de perguntas
			oGetPerg:oBrowse:Refresh()
			oGetPerg:oBrowse:Disable()
		Else
			// Para habilitar a get dados de perguntas, o grupo não pode ser Totalizador
			If !( NGSEEK( "TJ4",PadR( oGetGrp:aCols[oGetGrp:nAt][nPosGrp],TAMSX3( "TJ4_CODGRU" )[1] ),01,;
				"TJ4->TJ4_TIPREG" ) $ "34" )

				oGetPerg:oBrowse:Enable()
			EndIf
		EndIf

	ElseIf ReadVar() == "M->TJ3_ORDGRP"
		nPosAlt := _ORDGRP_
		cValor  := M->TJ3_ORDGRP
	EndIf

	For nI := 1 To Len( aAGeral )
		If AllTrim( aAGeral[nI][_CODGRU_] ) == AllTrim( oGetGrp:aCols[oGetGrp:nAt][nPosGrp] )
			aAGeral[nI][nPosAlt] := cValor
		EndIf
	Next nI

Return lRet

//---------------------------------------------------------------------
/*/{Protheus.doc} MDT99WHCRES
When do campo TJ2_CODRES, só habilita o campo caso TJ2_TPRES != 3 (Outros)

@author André Felipe Joriatti
@since 06/06/2013
@return Boolean lRet: indica se permite alteração do campo, sim ou não
@version MP11
/*/
//---------------------------------------------------------------------

Function MDT99WHCRES()

	Local lRet := .T.

	If M->TJ2_TPRES == "3"
		M->TJ2_CODRES := Space( TAMSX3( "TJ2_CODRES" )[1] )
		lRet := .F.
	EndIf

Return lRet

//---------------------------------------------------------------------
/*/{Protheus.doc} MDT999COMPQ
Valida compatibilidade de dicionário para executar rotinas de novo
Questionário.

@author André Felipe Joriatti
@since 06/06/2013
@return Boolean lRet: indica compatibilidade de dicionário
@version MP11
/*/
//---------------------------------------------------------------------

Function MDT999COMPQ( lExibeMens )

	Local lRet := .T.
	Default lExibeMens := .T.

	If !NGCADICBASE( "TJ2_QUESTI","A","TJ2",.F. )
		If lExibeMens
			NGINCOMPDIC( "UPDMDT88","THXDPI" )
		EndIf
		lRet := .F.
	EndIf

Return lRet

//---------------------------------------------------------------------
/*/{Protheus.doc} fGDColor
Altera cor da linha atualmente posicionada na Get Dados de Grupos.

@author André Felipe Joriatti
@since 10/06/2013
@return Integer nColor: indica cor a ser utilizada
@version MP11
/*/
//---------------------------------------------------------------------

Static Function fGDColor()

	Local nColor := CLR_WHITE

	If oGetGrp:nAt == nLiGetGrp
		nColor := _CLR_LINE
	EndIf

Return nColor

//---------------------------------------------------------------------
/*/{Protheus.doc} fAtuCurLiGRP
Atualiza variável número de linha atual da get dados do grupo de perguntas

@author André Felipe Joriatti
@since 10/06/2013
@return Boolean lRet: ever true.
@version MP11
/*/
//---------------------------------------------------------------------

Static Function fAtuCurLiGRP()

	Local lRet := .T.
	nLiGetGrp := oGetGrp:nAt // seta variável de controle da linha.
	oGetGrp:oBrowse:Refresh()

Return lRet

//---------------------------------------------------------------------
/*/{Protheus.doc} MDT999RNRE
Inicializador padrão para o campo TJ2_NOMRES

@author André Felipe Joriatti
@since 13/06/2013
@return Nil
@version MP11
/*/
//---------------------------------------------------------------------

Function MDT999RNRE()

	If IsInCallStack( "MDT999CP" )
		Inclui := .F.
	EndIf
	If Inclui
		M->TJ2_NOMRES := Space( TAMSX3( "TJ2_NOMRES" )[1] )
	Else
		If TJ2->TJ2_TPRES == "3" // Outros
			M->TJ2_NOMRES := TJ2->TJ2_NOMRES
		Else
			If TJ2->TJ2_TPRES == "1" // SESMT
				M->TJ2_NOMRES := NGSEEK( "TMK",PadR( TJ2->TJ2_CODRES,TAMSX3( "TMK_CODUSU" )[1] ),01,"TMK->TMK_NOMUSU" )
			ElseIf TJ2->TJ2_TPRES == "2" // Funcionarios
				M->TJ2_NOMRES := NGSEEK( "SRA",PadR( TJ2->TJ2_CODRES,TAMSX3( "RA_MAT" )[1] ),01,"SRA->RA_NOME" )
			EndIf
		EndIf
	EndIf

	If IsInCallStack( "MDT999CP" )
		Inclui := .T.
	EndIf
Return Nil

//---------------------------------------------------------------------
/*/{Protheus.doc} FILSXBTJ3()
Filtra consulta padrão TJ3.

@author André Felipe Joriatti
@since 19/06/2013
@return Boolean lRet: conforme o filtro executado.
@version MP11
/*/
//---------------------------------------------------------------------

Function FILSXBTJ3()

	Local lRet := .T.
	Local nPosGrp

	If IsInCallStack( "MDT851PRO" )
		// Lista conforme o Questionario e somente se pergunta for igual a Opção Única ou Numérico
		lRet := ( AllTrim( TJ3->TJ3_QUESTI ) == AllTrim( M->TG0_QUESTI ) ) .And. ( TJ3->TJ3_TPLIST $ "14" ) .And. !Empty( TJ3->TJ3_PERGUN )
	ElseIf IsInCallStack( "MDTA992CAD" )
		nPosGrp   := GDFIELDPOS( "TI5_CODGRU",oGetGrp:aHeader ) // código do grupo

		If nPosGrp > 0
			If NGSeek( "TJ4", oGetGrp:aCols[oGetGrp:nAt][ nPosGrp ] , 1 , "TJ4_TIPREG" ) == "4"
				lRet := ( AllTrim( TJ3->TJ3_QUESTI ) == AllTrim( M->TI5_QUESTI );// M->TI5_QUESTI memória de TI5_QUESTI retirada de objeto TGet ( oQuest )
								.And. ( TJ3->TJ3_TIPGRP == "1" ) .And. !Empty( TJ3->TJ3_PERGUN );
								.And. cOrdGpr992 == TJ3->TJ3_ORDGRP )
			Else
				lRet := ( AllTrim( TJ3->TJ3_QUESTI ) == AllTrim( M->TI5_QUESTI );// M->TI5_QUESTI memória de TI5_QUESTI retirada de objeto TGet ( oQuest )
								.And. ( TJ3->TJ3_TIPGRP == "1" ) .And. !Empty( TJ3->TJ3_PERGUN );
								.And. NGSeek( "TJ4", TJ3->TJ3_CODGRU , 1 , "TJ4_TIPREG" ) <> "2";
								.And. oGetGrp:aCols[oGetGrp:nAt][ nPosGrp ] == TJ3->TJ3_CODGRU )
			EndIf
		EndIf
	EndIf
Return lRet
//---------------------------------------------------------------------
/*/{Protheus.doc} MDT999VRTO()
When e Valid do campo TJ3_CATOT, só permite a edição do campo quando o grupo
da questão for do tipo Título de Colunas e a questão for do tipo
Resultado de Fórmula.

@author André Felipe Joriatti
@since 09/08/2013
@return Boolean lRet: conforme validação.
@version MP11
/*/
//---------------------------------------------------------------------

Function MDT999VRTO( cTipo )

	Local lRet      := .F.
	Local nPosGrp   := GDFIELDPOS( "TJ3_CODGRU",oGetGrp:aHeader ) // código do grupo
	Local nPosTpRsp := GDFIELDPOS( "TJ3_TPLIST",oGetPerg:aHeader ) // campo tipo resposta
	Local cCodGrp   := oGetGrp:aCols[oGetGrp:nAt][nPosGrp]
	Local cTipList  := oGetPerg:aCols[oGetPerg:nAt][nPosTpRsp]

	Default cTipo := "WHEN"

	lRet := ( NGSEEK( "TJ4",PadR( cCodGrp,TAMSX3( "TJ4_CODGRU" )[1] ),01,"TJ4->TJ4_TIPREG" ) == "2" .And. cTipList == "5" )

	If !lRet .And. cTipo == "VAL" .And. !Empty( M->TJ3_CATOT )
		MsgStop( STR0071 ) //"Informar este campo apenas para pergunta do tipo resultado da fórmula pertencente a um grupo de Título de Colunas."
	EndIf

Return lRet
//---------------------------------------------------------------------
/*/{Protheus.doc} fExcQsts()
Exclui questões da get dados de perguntas que estejam relacionadas ao
grupo informado no paramtro

@param String cCodGrp: indica código do grupo que se deseja excluir
perguntas.
@author André Felipe Joriatti
@since 17/09/2013
@return Nil, ever Nil
@version MP11
/*/
//---------------------------------------------------------------------

Static Function fExcQsts( cCodGrp )

	Local nI         := 0
	Local aQsts      := {}
	Local cQstNoExcl := "" // Identifica questão que não deverá ser excluída
	Local nPosQst    := GDFIELDPOS( "TJ3_QUESTA",oGetPerg:aHeader )
	Local nPosPerg   := GDFIELDPOS( "TJ3_PERGUN",oGetPerg:aHeader )
	Local nPosCombo  := GDFIELDPOS( "TJ3_COMBO" ,oGetPerg:aHeader )
	Local nPosTAM    := GDFIELDPOS( "TJ3_TAM"   ,oGetPerg:aHeader )
	Local nPosForm   := GDFIELDPOS( "TJ3_FORMAT",oGetPerg:aHeader )
	Local nPosFM     := GDFIELDPOS( "TJ3_FORMUL",oGetPerg:aHeader )
	Local nPosExcl   := 0

	// Nunca exclui a primeira questão da get dados
	// apenas seta como questão branca
	cQstNoExcl := oGetPerg:aCols[1][nPosQst]
	oGetPerg:aCols[1][nPosPerg]  := Space( TAMSX3( "TJ3_PERGUN" )[1] )
	oGetPerg:aCols[1][nPosCombo] := Space( TAMSX3( "TJ3_COMBO"  )[1] )
	oGetPerg:aCols[1][nPosTAM]   := 0
	oGetPerg:aCols[1][nPosForm]  := Space( TAMSX3( "TJ3_FORMAT" )[1] )
	oGetPerg:aCols[1][nPosFM]    := Space( TAMSX3( "TJ3_FORMUL" )[1] )

	// Recupera todas as questões que deverão ser excluídas
	For nI := 1 To Len( aAGeral )
		If !Empty( aAGeral[nI][_QUESTA_] ) .And. AllTrim( aAGeral[nI][_CODGRU_] ) == AllTrim( cCodGrp ) .And.;
			AllTrim( aAGeral[nI][_QUESTA_] ) != AllTrim( cQstNoExcl )
			aAdd( aQsts,aAGeral[nI][_QUESTA_] )
		EndIf
	Next nI

	// Exclui da get dados as questões relacionadas ao grupo
	For nI := 1 To Len( aQsts )
		If ( nPosExcl := aScan( oGetPerg:aCols,{ |x| AllTrim( x[nPosQst] ) == AllTrim( aQsts[nI] ) } ) ) > 0
			aDel( oGetPerg:aCols,nPosExcl )
			aSize( oGetPerg:aCols,Len( oGetPerg:aCols ) - 1 )
		EndIf
	Next nI

	// Exclui do array aAGeral todas as questões que foram excluídas da get dados
	For nI := 1 To Len( aQsts )
		If ( nPosExcl := aScan( aAGeral,{ |x| AllTrim( x[_QUESTA_] ) == AllTrim( aQsts[nI] ) } ) ) > 0
			aAGeral[nPosExcl][_DEL_] := .T.
		EndIf
	Next nI

Return Nil
