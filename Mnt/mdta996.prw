#Include "Protheus.ch"
#Include "MDTA996.ch"

#DEFINE _nVersao 2 //Versao do fonte  

// variáveis para manipular as posições do array de perguntas.				  
Static _CODGRU_ := 1  // Código do grupo da pergunta. Char 
Static _QUESTA_ := 2  // Código da pergunta. Char
Static _ORDEM_  := 3  // Ordem da pergunta, é utilizado para ordenação (apresentação visual). Char
Static _TPLIST_ := 4  // Tipo da pergunta. Char
Static _INDSEX_ := 5  // Sexo. Char
Static _OBS_    := 6  // Possui campo Obs.?. Boolean 
Static _PERGUN_ := 7  // Texto da pergunta em si. Char 
Static _COMBO_  := 8  // Conteudo da pergunta, se possuir (se for de opções). Char 
Static _TAM_    := 9  // Tamanho. Int 
Static _FORMAT_ := 10 // Formato. Char
Static _TIPGRP_ := 11 // Tipo do Grupo. Char ( combo )
Static _TPGRPP_ := 12 // Tipo do grupo no questionário (1=Normal,2=Rótulo)
Static _DEFAUL_ := 13 // Valor Default da pergunta
Static _ORDGRP_ := 14 // Ordem do grupo  
 
//---------------------------------------------------------------------
/*/{Protheus.doc} MDTA996
Rotina para resposta de Questionário Segurança do Trabalho.

@author André Felipe Joriatti
@since 14/03/2013
@version MP11      
@return nil 
/*/
//---------------------------------------------------------------------
  
Function MDTA996( cFiltro,cQuest )

	Local aNGBEGINPRM  := NGBEGINPRM( _nVersao )  
	Default cFiltro    := ""
	Default cQuest	   := ""
	  
	If !MDT999COMPQ()
		Return Nil
	EndIf

	Private aRotina    := MenuDef()
	Private cCadastro  := STR0001 // "Respostas do Questionário"
   Private cQuestSel  := cQuest

	// Abre rotina
	MDTB001BRW( cFiltro )

	NGRETURNPRM( aNGBEGINPRM )

Return Nil

//---------------------------------------------------------------------
/*/{Protheus.doc} MDTB001BRW
função para browse da rotina.

@author André Felipe Joriatti
@since 14/03/2013
@version MP11
@return nil
/*/
//---------------------------------------------------------------------

Static Function MDTB001BRW( cFiltro )

	Local aArea := GetArea()
 
	Private cCadastro := STR0001 // "Respostas do Questionário"
	Private aRotina   := MenuDef()
	aRotina := MenuDef()

	DbSelectArea( "TJ1" )
	If !Empty( cFiltro )
		Set Filter To &( cFiltro )
	EndIf
	MBrowse( 6,1,22,75,"TJ1" )

	RestArea( aArea )

Return Nil

//---------------------------------------------------------------------
/*/{Protheus.doc} MenuDef
Retorna menu da rotina.

@author André Felipe Joriatti
@since 15/02/2013
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
	aRotina := { { STR0003,"AxPesqui"  ,0,1 },;  // "Pesquisar"
                 { STR0004,"MDTB001CM" ,0,2 },;  // "Visualizar"
                 { STR0005,"MDTB001CM" ,0,3 },;  // "Incluir"
                 { STR0006,"MDTB001CM" ,0,4 },;  // "Alterar"
                 { STR0007,"MDTB001CM" ,0,5,3 },;// "Excluir" 
                 { STR0008,"IMPMDTB001",0,5 } }  // "Imprimir"

Return aRotina

//---------------------------------------------------------------------
/*/{Protheus.doc} MDTB001CM
função para tela de cadastro da rotina.

@author André Felipe Joriatti
@since 14/03/2013
@version MP11
@return nil

@Obs Chamadas Externas: MDTA992 - PT/PET
/*/
//---------------------------------------------------------------------

Function MDTB001CM( cAlias,nRecno,nOpcx, cCall996 )
	Local lRet := .F.
	Local aArea := GetArea()

	If nOpcx == 3
		lRet := fIncAnsw()
	Else
		If fPreValid( nOpcx )
			RegToMemory( "TJ1",.F. )
			lRet := MDTB001C( cAlias,nRecno,nOpcx )
		EndIf
	EndIf

	RestArea( aArea )

Return lRet

//---------------------------------------------------------------------
/*/{Protheus.doc} fIncAnsw
tela inicial para inclusão de uma resposta.

@author André Felipe Joriatti
@since 15/03/2013
@version MP11
@return Nil
/*/
//---------------------------------------------------------------------

Static Function fIncAnsw()

	Local aArea     := GetArea()
	Local nOpcx     := 3
	Local lConfirm  := .F.
	Local lRet      := .F.
	Local oTPanel   := Nil
	Local oQuest    := Nil
	Local cQuest    := Space( TAMSX3( "TJ2_QUESTI" )[1] )
	Local oDataReal := Nil
	Local dDataReal := CTOD( "  /  /    " )
	Local cMatFunc  := Space( TAMSX3( "RA_MAT" )[1] )
	Local oGroup
	Local oConfirm
	Local oCancel
	Local lCallCad  := IsInCallStack( "MDTB001C" ) // indica se está sendo chamada pela tela de cadastro
	Local lCallPT		:= IsInCallStack( "MDTA992LIB" ) // indica se está sendo chamada pela Permissão de Trabalho MDTA992

	Private oDlgInc := Nil
	Private oFunct  := Nil
	Private cFunct  := ""
	Private oTar    := Nil
	Private cTar    := ""
	Private oCC     := Nil
	Private cCC     := ""
	Private oAmbFis := Nil
	Private cAmbFis := ""
	Private oLoc    := Nil
	Private cLoc    := ""
	Private oNomeF  := Nil
	Private oNomeResp
	Private cNomFun
	Private cNomResp
	Private oTitCom
	Private oFunc
	Private oResp
	Private oCbxTPF
	Private oCbxTPR

	If !lCallCad .And. !lCallPT
		RegToMemory( "TJ1",.T. )
	EndIf

	If IsInCallStack( "SGAA220" )
		M->TJ1_QUESTI := cQuestSga
	ElseIf !Empty( cQuestSel )
		M->TJ1_QUESTI := cQuestSel
	EndIf

	Define MsDialog oDlgInc From 005,005 To 450,500 COLOR CLR_BLACK,CLR_WHITE STYLE nOr( DS_SYSMODAL,WS_MAXIMIZEBOX,WS_POPUP ) Of oMainwnd Pixel

		oDlgInc:lEscClose := .F.

		oTPanel := tPaintPanel():New( 0,0,0,0,oDlgInc,.F. )
			oTPanel:Align := CONTROL_ALIGN_ALLCLIENT

			// Container do Fundo
			oTPanel:addShape( "id=0;type=1;left=0;top=0;width=510;height=470;" + ;
							"gradient=1,0,0,0,180,0.0,#FFFFFF;pen-color=#FFFFFF;can-move=0;can-mark=0;is-container=1;" )

			// Gradiente
			oTPanel:addShape( "id=1;type=1;left=1;top=1;width=506;height=470;" + ;
							"gradient=1,0,0,0,380,0.0,#FFFFFF,0.1,#FDFBFD,1.0,#CDD1D4;pen-width=0;pen-color=#FFFFFF;can-move=0;can-mark=0;is-container=1;" )

			@ 22,20 Say STR0009 COLOR CLR_HBLUE Of oTPanel Pixel // "Questionário: "
			@ 20,66 MsGet oQuest Var M->TJ1_QUESTI Picture "@!" F3 "TJ2" Valid fValQt( M->TJ1_QUESTI ) Size 060,009 Of oTPanel Hasbutton Pixel When If( IsInCallStack( "SGAA220" ) .Or. lCallPT .Or. !Empty( cQuestSel ),.f.,!lCallCad )
				oQuest:bHelp := { || ShowHelpCpo( "M->TJ1_QUESTI",{ STR0010 },5,{},5 ) } // "Informe o código do Questionário a ser respondido."
				oQuest:SetFocus()  

			@ 35,20 Say STR0011 COLOR CLR_HBLUE Of oTPanel Pixel // "Data Realização: "
			@ 33,66 MsGet oDataReal Var M->TJ1_DTINC Picture "99/99/9999" Size 060,009 Of oTPanel Valid fValDtReal( M->TJ1_DTINC ) Hasbutton Pixel When !lCallCad .And. !lCallPT
				oDataReal:bHelp := { || ShowHelpCpo( "M->TJ1_DTINC",{ STR0012 },5,{},5 ) } // "Informe a Data de Realização/Resposta do Questionário."

			@ 48,20 Say STR0037 Of oTPanel Pixel // "Tipo Funcionário: "
			@ 46,66 COMBOBOX oCbxTPF Var M->TJ1_TPFUN Valid MDT996VTF() Items { STR0038,STR0039,STR0040 } Pixel Size 060,040 Of oTPanel When !lCallCad .And. !lCallPT // "1=Funcionário"##"2=SESMT"##"3=Outros"
				oCbxTPF:bHelp := { || ShowHelpCpo( "M->TJ1_TPFUN",{ STR0031 },5,{},5 ) } // "Informe o Tipo de Funcionário: 1 para Funcionário, 2 para SESMT ou 3 para Outros."

			@ 66,20 Say STR0013 Of oTPanel Pixel // "Funcionário: " 
			@ 64,66 MsGet oFunc Var M->TJ1_MAT Picture "@!" Size 060,009 Of oTPanel Pixel F3 "SRA" Hasbutton;
				Valid fMDT996FUNC() When !lCallCad .And. !lCallPT
				oFunc:bHelp := { || ShowHelpCpo( "M->TJ1_MAT",{ STR0032 },5,{},5 ) } // "Informe a Matrícula do Funcionário caso queira vincular um Funcionário a essa resposta de Questionário, o código do SESMT ou QAA, conforme o tipo selecionado."

			@ 64,128 Msget oNomeF Var cNomFun Picture "@!" Size 090,009 Of oTPanel Pixel Hasbutton When .F. // nome do funcionario

			@ 79,20 Say STR0034 Of oTPanel Pixel // "Tipo Responsável: " 	
			@ 77,66 COMBOBOX oCbxTPR Var M->TJ1_TPRES Valid MDT996VTR() Items { STR0038,STR0039,STR0040 } Pixel Size 060,040 Of oTPanel When !lCallCad .And. !lCallPT // "1=Funcionário"##"2=SESMT"##"3=Outros"
				oCbxTPR:bHelp := { || ShowHelpCpo( "M->TJ1_TPRES",{ STR0033 },5,{},5 ) } // "Informe o Tipo de Responsável: 1 para Funcionário, 2 para SESMT ou 3 para Outros."
  
			@ 97,20 Say STR0035 Of oTPanel Pixel // "Responsável: "     
			@ 95,66 MsGet oResp Var M->TJ1_RESPEN Picture "@!" Size 060,009 Of oTPanel Pixel F3 "SRA" Hasbutton;
				Valid fMDT996FUNC() When !lCallCad .And. !lCallPT
				oResp:bHelp := { || ShowHelpCpo( "M->TJ1_RESPEN",{ STR0036 },5,{},5 ) } // "Responsável pela entrevista/coleta das informações, podendo ser através do código do Funcionário, SESMT ou QAA, conforme o tipo selecionado."
				
			@ 95,128 Msget oNomeResp Var cNomResp Picture "@!" Size 090,009 Of oTPanel Pixel Hasbutton When .F. // nome do responsável

			@ 110,20 Say STR0015 Of oTPanel Pixel // "Titulo Comentário: "  
			@ 108,66 MsGet oTitCom Var M->TJ1_TITULO Size 060,009 Of oTPanel Pixel When !lCallCad
				oTitCom:bHelp := { || ShowHelpCpo( "M->TJ1_TITULO",{ STR0016 },5,{},5 ) } // "Informe um título para o campo de comentário."

			oGroup := tGroup():New( 125,020,210,230,STR0017,oTPanel,CLR_BLACK,CLR_BLACK,.T. ) // "Campos Relacionados"
   
				If lCallCad
					fLoadCps( M->TJ1_QUESTI )
				EndIf

				@ 138,035 Say STR0018 COLOR CLR_BLACK Of oGroup Pixel // "Função: "
				@ 136,075 MsGet oFunct Var cFunct Picture "@!" Size 100,009 Of oGroup Pixel When .F.

				@ 151,035 Say STR0019 COLOR CLR_BLACK Of oGroup Pixel // "Tarefa: "
				@ 149,075 MsGet oTar Var cTar Picture "@!" Size 100,009 Of oGroup Pixel When .F.

				@ 164,035 Say STR0020 COLOR CLR_BLACK Of oGroup Pixel // "C. Custo: "
				@ 162,075 MsGet oCC Var cCC Picture "@!" Size 100,009 Of oGroup Pixel When .F.

				@ 177,035 Say STR0021 COLOR CLR_BLACK Of oGroup Pixel // "Amb. Físico: "
				@ 175,075 MsGet oAmbFis Var cAmbFis Picture "@!" Size 100,009 Of oGroup Pixel When .F.

				@ 190,035 Say STR0022 COLOR CLR_BLACK Of oGroup Pixel // "Localização: "
				@ 188,075 MsGet oLoc Var cLoc Picture "@!" Size 100,009 Of oGroup Pixel When .F.

			Define sButton oConfirm From 215,180 Type 1 Enable Of oTPanel Action ( If( fValInic( lCallCad ),( lConfirm := .T.,oDlgInc:End() ), ) )
				oConfirm:SetCss( CSSButton() )

			Define sButton oCancel From 215,209 Type 2 Enable Of oTPanel Action ( lConfirm := .F.,oDlgInc:End() )
				oCancel:SetCss( CSSButton() )

			If lCallCad
				oCancel:Disable()
			EndIf

	Activate MsDialog oDlgInc Centered

	If lConfirm .And. !lCallCad
		lRet := MDTB001C( "TJ1",0,3 )
	EndIf

	RestArea( aArea )

Return lRet

//---------------------------------------------------------------------
/*/{Protheus.doc} fValInic
valida registro duplicado para cadastro de respostas do questionário.

@author André Felipe Joriatti
@since 22/03/2013
@version MP11
@return boolean lRet: conforme validação
/*/
//---------------------------------------------------------------------

Static Function fValInic( lCallCad )
	
	Local lRet := .T.
	Local lSeqRes		:= TJ1->( FieldPos( "TJ1_SEQRES" ) ) > 0
	Local cSeqRespost	:= If( lSeqRes ,If( Type("M->TJ1_SEQRES") <> "U",  M->TJ1_SEQRES , Space( TAMSX3( "TJ1_SEQRES" )[1] ) ) , "" )
	Local nTamQt   := TAMSX3( "TJ1_QUESTI" )[1]
	Local nTamFunc := TAMSX3( "TJ1_FUNC"   )[1]
	Local nTamTar  := TAMSX3( "TJ1_TAR"    )[1]
	Local nTamCC   := TAMSX3( "TJ1_CC"     )[1]
	Local nTamAmb  := TAMSX3( "TJ1_AMB"    )[1]
	Local nTamLoc  := TAMSX3( "TJ1_LOC"    )[1]
	Local nTamMat  := TAMSX3( "TJ1_MAT"    )[1]
	Local nTamOs   := TAMSX3( "TJ1_OSSIMU" )[1]

	If !lCallCad
		If NGIFDBSEEK( "TJ2",Padr( M->TJ1_QUESTI,TAMSX3( "TJ2_QUESTI" )[1] ),01 ) // // TJ2_FILIAL+TJ2_QUESTI
			lRet := !NGIFDBSEEK( "TJ1",Padr( M->TJ1_QUESTI,nTamQt ) +;
									   DTOS( M->TJ1_DTINC ) +;
									   Padr( TJ2->TJ2_FUNC,nTamFunc )+;
									   Padr( TJ2->TJ2_TAR,nTamTar ) +;
									   Padr( TJ2->TJ2_CC,nTamCC ) +;
									   Padr( TJ2->TJ2_AMB,nTamAmb ) +;
									   Padr( TJ2->TJ2_LOC,nTamLoc ) +;
									   Padr( M->TJ1_MAT,nTamMat ) +;
											Padr( If( IsInCallStack( "SGAA220" ),TRBQ->TBQ_ORDEM,"" ),nTamOs ) +;
											cSeqRespost,;
											01,.F. ) // TJ1_FILIAL+TJ1_QUESTI+DTOS( TJ1_DTINC )+TJ1_FUNC+TJ1_TAR+TJ1_CC+TJ1_AMB+TJ1_LOC+TJ1_MAT+TJ1_OSSIMU+TJ1_SEQRES

		Else
			lRet := .f.
		EndIf

		// inicializar algumas variáveis de memória
		DbSelectArea( "TJ2" )
		If lRet
			M->TJ1_FUNC := TJ2->TJ2_FUNC
			M->TJ1_TAR  := TJ2->TJ2_TAR
			M->TJ1_CC   := TJ2->TJ2_CC
			M->TJ1_LOC  := TJ2->TJ2_LOC
		Else
			ShowHelpDlg( "",{ STR0023 },2,{ "" },2 ) // "Já Existe um Questionário respondido com esses mesmos dados."
		EndIf
	EndIf

Return lRet

//---------------------------------------------------------------------
/*/{Protheus.doc} fValQt
valida campo de questionário.

@param string cQuest: indica o questionário.
@author André Felipe Joriatti
@since 15/03/2013
@version MP11
@return boolean lRet: conforme validação.
/*/
//---------------------------------------------------------------------

Static Function fValQt( cQuest )

	Local lRet := .F.
	lRet := ExistCpo( "TJ2",cQuest )

	cFunct  := Space( 1 )
	cTar    := Space( 1 )
	cCC     := Space( 1 )
	cAmbFis := Space( 1 )
	cLoc    := Space( 1 )

	If lRet
		Processa( { || fLoadCps( cQuest ) } )
	EndIf

Return lRet

//---------------------------------------------------------------------
/*/{Protheus.doc} fValDtReal
validação de campo de data, preenchimento obrigatório.

@param date dDataReal: indica a data para validar.
@author André Felipe Joriatti
@since 15/03/2013
@version MP11
@return lRet conforme validação.
/*/
//---------------------------------------------------------------------

Static Function fValDtReal( dDataReal )

	Local lRet := .F.
	lRet := Empty( dDataReal )

	If lRet
		ShowHelpDlg( "",{ STR0024 },2,{ "" },2 )
	EndIf
	
	lRet := !lRet

Return lRet

//---------------------------------------------------------------------
/*/{Protheus.doc} fPreValid
Faz a pré validação para a Visualização/Alteração/Exclusão.

@param nOpcx Numerico Indica a operação a ser realizada.
@author Guilherme Benkendorf
@since 22/10/2014
@version MP11
@return lRet Boolean Indica se a operação cotinua.
/*/
//---------------------------------------------------------------------

Static Function fPreValid( nOpcx )
	Local lRet    := .T.
	Local aArea   := GetArea()
	Local aAreaTJ1:= TJ1->( GetArea() )

	If nOpcx == 4 .Or. nOpcx == 5
		If !Empty( TJ1->TJ1_SEQRES ) .And. !NGVALSX9( "TJ1" , { "TJ5" } , .T. , ,.F. )
			lRet := .F.
		EndIf
	EndIf

	RestArea( aArea )
	RestArea( aAreaTJ1 )

Return lRet

//---------------------------------------------------------------------
/*/{Protheus.doc} fLoadCps
carrega campos relacionados de acordo com o questionário digitado.

@param string cQuest: indica o questionário.
@author André Felipe Joriatti
@since 15/03/2013
@version MP11
@return nil
/*/
//---------------------------------------------------------------------

Static Function fLoadCps( cQuest )

	Local aArea := GetArea()

	If NGIFDBSEEK( "TJ2",Padr( cQuest,TAMSX3( "TJ2_QUESTI" )[1] ),01 )
		cFunct  := NGSEEK( "SRJ",Padr( TJ2->TJ2_FUNC,TAMSX3( "RJ_FUNCAO" )[1] ),1,"SRJ->RJ_DESC" )
		cTar    := NGSEEK( "TN5",Padr( TJ2->TJ2_TAR,TAMSX3( "TN5_CODTAR" )[1] ),1,"TN5->TN5_NOMTAR" )
		cCC     := NGSEEK( "CTT",Padr( TJ2->TJ2_CC,TAMSX3( "CTT_CUSTO" )[1] ),1,"CTT->CTT_DESC01" )
		cAmbFis := NGSEEK( "TNE",Padr( TJ2->TJ2_AMB,TAMSX3( "TNE_CODAMB" )[1] ),1,"TNE->TNE_NOME" )
		cLoc    := NGSEEK( "TAF",Padr( TJ2->TJ2_LOC,TAMSX3( "TAF_CODNIV" )[1] ),8,"TAF->TAF_NOMNIV" )
	EndIf

	oDlgInc:Refresh()
	RestArea( aArea )

Return Nil

//---------------------------------------------------------------------
/*/{Protheus.doc} MDTB001C
Função de cadastro da rotina.

@author André Felipe Joriatti
@since 18/03/2013
@version MP11
@return nil
/*/
//---------------------------------------------------------------------

Function MDTB001C( cAlias,nRecno,nOpcx )

	Local cDGrpAtu    := ""
	Local nI          := 0
	Local nT          := 0
	Local nW          := 0	
	Local nY          := 0
	Local nM          := 0
	Local oFontTit    := tFont():New( "Arial",,17,,.T. )
	Local oFontGrp    := tFont():New( "Arial",,13,,.T. )
	Local cCadastro   := STR0002 // "Resposta de Questionário"
	Local aItens      := {}
	Local aButtons    := {}
	Local nSize       := 0
	Local cPict       := "" 
	Local nPos        := 0
	Local nSeqDados   := 0
	Local nSeqRadios  := 0
	Local nPosEq      := 0
	Local cValor      := ""
	Local cOpcExibir  := ""
	Local nPosMemo    := 0
	Local oMemoTJ1
	local lConfirm    := .F.
	Local lRet        := .F.
	local lVisual     := If( cValToChar( nOpcx ) $ "25",.T.,.F. )
	Local nTamCpo     := 0
	Local nK          := 0
	Local aClsQsta    := {}
	Local cOrdemSimul := If( IsInCallStack( "SGAA220" ),TRBQ->TBQ_ORDEM,Space( TAMSX3( "TJ5_OSSIMU" )[1] ) )
	Local nTamTexto   := 0
	Local cTipo       := ""
	Local cPicture    := ''

	Local lSeqRes		:= TJ5->( FieldPos( "TJ5_SEQRES" ) ) > 0
	Local cSeqRespost	:= If( lSeqRes ,If( Type("M->TJ1_SEQRES") <> "U",  M->TJ1_SEQRES , Space( TAMSX3( "TJ5_SEQRES" )[1] ) ) , "" )

	Local cValCpoOclt := ""
	// Sexo do Funcionário
	Local cIndSexo   := ""

	// variáveis para chave primaria da tj1 e tj5
	Local cFuncao    := NGSEEK( "TJ2",M->TJ1_QUESTI,1,"TJ2->TJ2_FUNC" )
	Local cTar       := NGSEEK( "TJ2",M->TJ1_QUESTI,1,"TJ2->TJ2_TAR"  )
	Local cCC        := NGSEEK( "TJ2",M->TJ1_QUESTI,1,"TJ2->TJ2_CC"   )
	Local cAmb       := NGSEEK( "TJ2",M->TJ1_QUESTI,1,"TJ2->TJ2_AMB"  )
	Local cLoc       := NGSEEK( "TJ2",M->TJ1_QUESTI,1,"TJ2->TJ2_LOC"  )

	Local cCodigoComp := " "
	Local lFoundResp  := .F.
	
	Local nTamPnl     := Nil // Usado para controlar o tamanho dos pnls de pergunta.
	// Variaveis de Largura/Altura da Janela
	Local aSize      := MsAdvSize( Nil,.F. )

	Private nLargura   := aSize[5]
	Private nAltura    := aSize[6]
	Private aDados     := {} // array usado para armazenar os dados digitados ou inputados nos objetos - tipo pergunta(objeto),objeto,valor,questão
	Private aRadios    := {} // usado para controlar os radios das respostas
	Private aPerguntas := fRetPerg( M->TJ1_QUESTI ) // recupera as perguntas do questionário
	Private aGrpsP     := fRetGrp( aPerguntas ) // extrai somente os grupos das perguntas
	Private nLinObj    := 0
	Private nFatMlt    := 0
	Private aChks      := {}
	Private aMemos     := {} // armazena os memos do questionario por pergunta
	Private aGetDdsGrp := {} // armazena as get dados das respostas (grupos de perguntas do tipo Título de Colunas).
	Private cSequenc   := "001"
	Private oScroll    := Nil
	Private oPnlGrp    := Nil
	Private oPnlTop    := Nil
	Private oMemo      := Nil
	Private oSay       := Nil
	
	Private aPnlsPergs := {} // array que irá conter os panels das perguntas formato: { { Código Questão,Objeto do panel } }

	// ordena por grupo + ordem
	aSort( aPerguntas,,,{ |x,y| x[_CODGRU_] + x[_ORDEM_] < y[_CODGRU_] + y[_ORDEM_] } )
	
	If M->TJ1_TPFUN == "2" // Se for do tipo Funcionário
		cIndSexo := If( AllTrim( NGSEEK( "SRA",M->TJ1_MAT,1,"SRA->RA_SEXO" ) ) == "M","1","2" )
	Else
		cIndSexo := "O"
	EndIf
	
	// estabiliza tamanho de campo TJ1_MAT, uma vez que este tem diferentes consultas padrão, acaba vindo com diferentes tamanhos, e precisa ser
	// 'estabilizado' para não interferir no posicionamento de registros.
	M->TJ1_MAT := PadR( M->TJ1_MAT,TAMSX3( "TJ1_MAT" )[1] )

	Define MsDialog oDlgResp Title OemToAnsi( cCadastro ) From aSize[7],0 To nAltura,nLargura Of oMainWnd Pixel

		oDlgResp:lEscClose := .F.

		oPnlTop := TPanel():New( 000,000,,oDlgResp,,,,,RGB( 67,70,87 ),000,013 )
		oPnlTop:Align   := CONTROL_ALIGN_TOP
		oPnlTop:nHeight := 25
			TSay():New( 003,002,{ || STR0025 + M->TJ1_QUESTI },oPnlTop,,oFontTit,,,,.T.,RGB( 255,255,255 ),,200,010 ) // #"Questionário " 

		   oScroll := TScrollBox():New( oDlgResp,050,000,,,.t.,,.t. )
		   	oScroll:Align := CONTROL_ALIGN_ALLCLIENT

				nLinObj := 2

				//-----------------------------------------------------
				// laço em cima de grupos das questões do questionário
				//-----------------------------------------------------

				aSort( aGrpsP,,,{ |x,y| x[4] < y[4] } ) // Ordena grupos pela ordem

				For nI := 1 To Len( aGrpsP )

					// Caso grupo de perguntas tenha sido declarado como Grupo Rótulo no cadastro do Questionário 
					If aGrpsP[nI][3] == "2"
						Loop
					EndIf

					cDGrpAtu := NGSEEK( "TJ4",aGrpsP[nI][1],1,"TJ4->TJ4_DESCRI" )
					// panel de grupo
					oPnlGrp := TPaintPanel():New( nLinObj-1,0,nLargura/2 - 20,10,oScroll )

						oPnlGrp:addShape( "id=1;type=1;left=0;top=0;width=" + AllTrim( Str( nLargura / 2 * 1.94,5 ) ) + ";height=20;" + ;
	                	                  "gradient=1,0,0,0,15,0.0,#FFFFFF,0.1,#FFFFFF,1.0,#FFFFFF;pen-width=1;" + ;
	                			          "pen-color=#FFFFFF;can-move=0;can-mark=0;is-blinker=1;" )

   						oPnlGrp:addShape( "id=2;type=1;left=10;top=0;width=" + AllTrim( Str( nLargura / 2 * 1.87,5 ) ) + ";height=20;" + ;
                			 		      "gradient=1,0,0,0,15,0.0,#FFFFFF,0.1,#FDFBFD,1.0,#CDD1D4;pen-width=1;" + ;
                			 		      "pen-color=#B0C4DE;can-move=0;can-mark=0;is-blinker=1;" )

	        	       		oSay := TSay():New( 002,011,,oPnlGrp,,oFontGrp,,,,.t.,RGB( 67,70,87 ),,200,010 )
	        	       			oSay:SetText( cDGrpAtu )

					nLinObj += 13

					If aGrpsP[nI][2] == "2" // para grupo do tipo 'Título de Colunas'

						// 1 = objeto( getdados ); 2 = aHeader da Get Dados; 3 = aCols da Get Dados
						aAdd( aGetDdsGrp,{ ,{},{},cSequenc } )

						aGetDdsGrp[Len( aGetDdsGrp )][2] := {}

						//------------------------------
						// montagem de aheader dinâmico
						//------------------------------
						For nT := 1 To Len( aPerguntas )
							// aPerguntas[nT][_INDSEX_]: 1=Masculino;2=Feminino;3=Ambos
							If aPerguntas[nT][_CODGRU_] == aGrpsP[nI][1] .And. ( AllTrim( If( aPerguntas[nT][_INDSEX_] == "3",cIndSexo,aPerguntas[nT][_INDSEX_] ) ) ==  AllTrim( cIndSexo ) .Or. cIndSexo == "O" )
								nTamCpo := 0
								If aPerguntas[nT][_TPLIST_] == "3" // Texto Descritivo
									nTamCpo := aPerguntas[nT][_TAM_]
									cPicture := "@!"
								ElseIf aPerguntas[nT][_TPLIST_] == "1" // Opção Única
									nTamCpo := 1
									cPicture := "@!"
								Else
									If aPerguntas[nT][_TPLIST_] == "4"
										cPicture := "@E " + aPerguntas[nT][_FORMAT_]
									ElseIf aPerguntas[nT][_TPLIST_] == "5"
										cPicture := "@E 999,999.99"
									EndIf
									nTamCpo := 9
								EndIf
								aHeader := { aPerguntas[nT][_PERGUN_],;                                            // titulo
											 "C_" + aPerguntas[nT][_QUESTA_],;                                     // campo
											 cPicture,;                                                            // picture
											 nTamCpo,;                                                             // tamanho
											 If( aPerguntas[nT][_TPLIST_] $ "45",2,0 ),;                           // decimal
											 "AllwaysTrue()",;                                                     // valid
											 "",;                                                                  // usado
											 If( aPerguntas[nT][_TPLIST_] $ "45","N","C" ),;                       // tipo
											 "",;                                                                  // f3
											 "R",;                                                                 // contexto
											 If( aPerguntas[nT][_TPLIST_] == "1",fRetChrArr( fRetOpcQt( M->TJ1_QUESTI,aPerguntas[nT][_QUESTA_] ) ),"" ),; // box
											 Nil,;                                                                 // relação
											 If( aPerguntas[nT][_TPLIST_] == "5",".F.",".T." );                    // when
										   }
								aAdd( aGetDdsGrp[Len( aGetDdsGrp )][2],aHeader )
							EndIf
						Next nT

						// Campo para sequencial
						aAdd( aGetDdsGrp[Len( aGetDdsGrp )][2],{ "Id",;            // titulo
																 "C_SEQ",;         // campo
											 					 "999",; 		   // picture
											 					 3,;               // tamanho
											 				     0,;               // decimal
											 					 "AllwaysTrue()",; // valid
											 					 "",;              // usado
											 					 "C",;             // tipo
											 					 "",;              // f3
											 					 "R",;             // contexto
											 					 "",;              // box
											 					 "fIncSeq( " + cSequenc + " )",; // relação
											 					 ".F.";            // when
										    				   };
							)

						If nOpcx == 3
							// Insere uma linha em branco
							aGetDdsGrp[Len( aGetDdsGrp )][3] := BLANKGETD( aGetDdsGrp[Len( aGetDdsGrp )][2] )
							// Inicia o campo sequencial com 001
							aGetDdsGrp[Len( aGetDdsGrp )][3][1][Len( aGetDdsGrp[Len( aGetDdsGrp )][2] )] := "001"
						Else
							//-------------------------------------------------------------------------------------------
							// Laço em cima do aHeader da get dados que esta dentro de: aGetDdsGrp[Len( aGetDdsGrp )][2]
							//------------------------------------------------------------------------------------------- 
							For nK := 1 To ( Len( aGetDdsGrp[Len( aGetDdsGrp )][2] ) - 1 )

								//-----------------------------------------------
								// Atribui à cQst referente ao campo do aHeader
								//-----------------------------------------------
								cQst := SubStr( aGetDdsGrp[Len( aGetDdsGrp )][2][nK][2],3,4 )
								DbSelectArea( "TJ5" )
								DbSetOrder( 01 ) // TJ5_FILIAL+TJ5_QUEST+DTOS( TJ5_DTRESP )+TJ5_FUNC+TJ5_TAR+TJ5_CC+TJ5_AMB+TJ5_LOC+TJ5_MAT+TJ5_OSSIMU+TJ5_PERG+TJ5_RESPCD+TJ5_SEQGTD
								If DbSeek( xFilial( "TJ5" ) + M->TJ1_QUESTI + DTOS( M->TJ1_DTINC ) + cFuncao + cTar + cCC + cAmb + cLoc + M->TJ1_MAT + cOrdemSimul + cSeqRespost + cQst )

									/*
										Obs.: Cada campo da linha da getDados é um registro de resposta TJ5, sendo assim, foi utilizado o controle por meio
										do campo TJ5_SEQGTD para agrupar vários registros de respostas de forma que eles se refiram a um registro apenas na getDados
										pois, a getDados serve apenas para representação visual, a estrutura como os dados são armazenados não correspondem a 
										estrutura da getDados
										Ex.: existem três registros TJ5 cujo TJ5_SEQGTD == 001, isso quer dizer, que na getDados esses três registros serão agrupados
										de forma a exibir como se fossem UMA linha apenas na getDados
									*/

									// Laço em cima de todas as respostas respondidas para aquela questão, cQst
									While !EoF() .And. TJ5->( TJ5_FILIAL + TJ5_QUEST + DTOS( TJ5_DTRESP ) + TJ5_FUNC + TJ5_TAR + TJ5_CC + TJ5_AMB + TJ5_LOC + TJ5_MAT + cOrdemSimul + If( lSeqRes,TJ5_SEQRES , "" ) + TJ5_PERG ) == ;
															  			( xFilial( "TJ5" ) + M->TJ1_QUESTI + DTOS( M->TJ1_DTINC ) + cFuncao + cTar + cCC + cAmb + cLoc + M->TJ1_MAT + cOrdemSimul + cSeqRespost + cQst )

											//--------------------------------------------------------------------------  
											// Se a  resposta pertence a uma linha que ainda não foi inclusa no aCols
											//--------------------------------------------------------------------------
											If ( nPosQsta := aScan( aGetDdsGrp[Len( aGetDdsGrp )][3],{ |x| x[Len(x)-1] == TJ5->TJ5_SEQGTD } ) ) == 0

												//-----------------------------------------------
												// Cria uma nova linha para getDados, em branco
												//-----------------------------------------------
												aClsQsta := Array( Len( aGetDdsGrp[Len( aGetDdsGrp )][2] ) + 1 )

												//-------------------------------------------------------------------------------------------------
												// Insere a resposta posicionada atualmente ( TJ5 ) em sua respectiva posição no campo da getDados
												//-------------------------------------------------------------------------------------------------
												If aGetDdsGrp[Len( aGetDdsGrp )][2][nK][8] == "C"
													If NGSEEK( "TJ3",M->TJ1_QUESTI + cQst,01,"TJ3->TJ3_TPLIST" ) == "1" // opção exclusiva
														aClsQsta[nK] := If( !Empty( TJ5->TJ5_RESPCD ),AllTrim( TJ5->TJ5_RESPCD ),"" )
													ElseIf NGSEEK( "TJ3",M->TJ1_QUESTI + cQst,01,"TJ3->TJ3_TPLIST" ) == "3" // texto descritivo
														nTamTexto := aGetDdsGrp[Len( aGetDdsGrp )][2][nK][4]
														aClsQsta[nK] := If( !Empty( TJ5->TJ5_TEXTD ),PadR( TJ5->TJ5_TEXTD,nTamTexto ),Space( nTamTexto ) )
													EndIf
												ElseIf aGetDdsGrp[Len( aGetDdsGrp )][2][nK][8] == "N"
													aClsQsta[nK] := TJ5->TJ5_NUMERI
												EndIf

												//--------------------------------------------------------------
												// Atribui o campo de controle sequencial o valor de TJ5_SEQGTD
												//--------------------------------------------------------------
												aClsQsta[Len( aClsQsta ) - 1] := TJ5->TJ5_SEQGTD
												aClsQsta[Len( aClsQsta )]     := .F.
												aAdd( aGetDdsGrp[Len( aGetDdsGrp )][3],aClsQsta )

											Else // Senão, se a resposta ja pertence a uma linha que já foi inclusa no aCols
											
												//--------------------------------------------------------------------------
												// Insere o registro de resposta ( TJ5 ) a sua posição em campo na getDados
												//--------------------------------------------------------------------------
												If aGetDdsGrp[Len( aGetDdsGrp )][2][nK][8] == "C"
													If NGSEEK( "TJ3",M->TJ1_QUESTI + cQst,01,"TJ3->TJ3_TPLIST" ) == "1" // opção exclusiva
														aGetDdsGrp[Len( aGetDdsGrp )][3][nPosQsta][nK] := If( !Empty( TJ5->TJ5_RESPCD ),AllTrim( TJ5->TJ5_RESPCD ),"" )
													ElseIf NGSEEK( "TJ3",M->TJ1_QUESTI + cQst,01,"TJ3->TJ3_TPLIST" ) == "3" // texto descritivo
														nTamTexto := aGetDdsGrp[Len( aGetDdsGrp )][2][nK][4]
														aGetDdsGrp[Len( aGetDdsGrp )][3][nPosQsta][nK] := If( !Empty( TJ5->TJ5_TEXTD ),PadR( TJ5->TJ5_TEXTD,nTamTexto ),Space( nTamTexto ) )
													EndIf
												ElseIf aGetDdsGrp[Len( aGetDdsGrp )][2][nK][8] == "N"
													aGetDdsGrp[Len( aGetDdsGrp )][3][nPosQsta][nK] := TJ5->TJ5_NUMERI
												EndIf

											EndIf

										NGDBSELSKIP( "TJ5" )
									EndDo
								EndIf
							Next nK
							
							// Caso alteração de getdados e algum registro esta com a resposta em branco, então inicializa um valor para o campo no aCols
							If Len( aGetDdsGrp[Len( aGetDdsGrp )][3] ) > 0

								For nY := 1 To Len( aGetDdsGrp[Len( aGetDdsGrp )][3] ) // Percorre o aCols da get dados atual
									For nM := 1 To ( Len( aGetDdsGrp[Len( aGetDdsGrp )][3][nY] ) - 2 ) // Percorre cada campo do acols
										cQst := SubStr( aGetDdsGrp[Len( aGetDdsGrp )][2][nM][2],3,4 ) // Número da questão

										If Empty( aGetDdsGrp[Len( aGetDdsGrp )][3][nY][nM] )
											cTipo := NGSEEK( "TJ3",M->TJ1_QUESTI + cQst,01,"TJ3->TJ3_TPLIST" )
											If cTipo == "3" // Texto Descritivo
												aGetDdsGrp[Len( aGetDdsGrp )][3][nY][nM] := Space( aGetDdsGrp[Len( aGetDdsGrp )][2][nM][4] )
											ElseIf cTipo == "1" // Opção única
												aGetDdsGrp[Len( aGetDdsGrp )][3][nY][nM] := ""
											ElseIf cTipo == "4" // Numérico
												aGetDdsGrp[Len( aGetDdsGrp )][3][nY][nM] := 0
											EndIf
										EndIf

									Next nM
								Next nY

							Else // Caso a getDados esteja vazia, inicializa aCols em branco
								//-----------------------------------
								// Cria registro no aCols em branco
								//-----------------------------------
								aGetDdsGrp[Len( aGetDdsGrp )][3] := BLANKGETD( aGetDdsGrp[Len( aGetDdsGrp )][2] )
								
								//----------------------------
								// inicia o campo sequencial
								//----------------------------
								aGetDdsGrp[Len( aGetDdsGrp )][3][1][Len( aGetDdsGrp[Len( aGetDdsGrp )][2] )] := "001"
							EndIf
						EndIf

						// Cria getdados
						aGetDdsGrp[Len( aGetDdsGrp )][1] := MsNewGetDados():New( nLinObj,010,0,0,If( cValToChar(nOpcx) $ "5\2",0,GD_INSERT+GD_UPDATE+GD_DELETE),;
																				 "AllwaysTrue()","AllwaysTrue()",,,,,"AllwaysTrue()","AllwaysTrue()",;
																				 "AllwaysTrue()",oScroll,aGetDdsGrp[Len( aGetDdsGrp )][2],;
																				 aGetDdsGrp[Len( aGetDdsGrp )][3],, )
						aGetDdsGrp[Len( aGetDdsGrp )][1]:oBrowse:nHeight := 150
						aGetDdsGrp[Len( aGetDdsGrp )][1]:oBrowse:nWidth  := nLargura - 100

						nLinObj += 80
						cSequenc := Soma1( cSequenc )

					Else // Para demais grupos que não sejam do tipo 'Título de Colunas'

						//-----------------------------------------------------------------------------------
						// Laço em cima de questões de cada grupo, para exibir as mesmas em forma de objeto
						// Visual correspondente ao seu tipo
						//-----------------------------------------------------------------------------------
						For nT := 1 To Len( aPerguntas )
							If ( AllTrim( If( aPerguntas[nT][_INDSEX_] == "3",cIndSexo,aPerguntas[nT][_INDSEX_] ) ) ==  AllTrim( cIndSexo ) .Or. cIndSexo == "O" )

								// Se pergunta corresponde ao grupo
								If aPerguntas[nT][_CODGRU_] == aGrpsP[nI][1]

									nTamPnl := If ( aPerguntas[nT][_OBS_],60,40 )

									aAdd( aPnlsPergs,{ aPerguntas[nT][_QUESTA_],Nil } )

									// Panel para conter a pergunta
						 			aPnlsPergs[Len( aPnlsPergs )][2] := tPanel():New( nLinObj,010,,oScroll,,,,,,nLargura/2 - 53,nTamPnl,,.T. )
						 			aPnlsPergs[Len( aPnlsPergs )][2]:lCanGotFocus := .T.

									nPosPnls := Len( aPnlsPergs )
						 			aPnlsPergs[nPosPnls][2]:bLClicked  := &( "{ || fPnlBackClr( " + cValToChar( nPosPnls ) + ",.T. ) }" )
						 			aPnlsPergs[nPosPnls][2]:bGotFocus  := &( "{ || fPnlBackClr( " + cValToChar( nPosPnls ) + ",.T. ) }" )
						 			aPnlsPergs[nPosPnls][2]:bLostFocus := &( "{ || fPnlBackClr( " + cValToChar( nPosPnls ) + ",.F. ) }" )

						 			nLinObj += If ( aPerguntas[nT][_OBS_],70,50 )

						 				oScrollPer := tScrollBox():New( aPnlsPergs[Len( aPnlsPergs )][2],050,000,,,.T.,,.T. )
						 					oScrollPer:Align := CONTROL_ALIGN_ALLCLIENT
	
							 					oSay := tSay():New( 001,002,,oScrollPer,,oFontGrp,,,,.T.,RGB( 67,70,87 ),,200,010 )
			        	       						oSay:SetText( aPerguntas[nT][_PERGUN_] )
	
			        	       		nSeqDados++ // incrementa id na matriz de respostas
			        	       		// formato de aDados: Id,Tipo Pergunta,Objeto,Valor,Questão
			        	       		aAdd( aDados,{ nSeqDados,aPerguntas[nT][_TPLIST_],,,aPerguntas[nT][_QUESTA_] } )
	
			        	       		// guarda posição do array atual
			        	       		nPosPerg := Len( aDados )
	
							 		If aPerguntas[nT][_TPLIST_] == "1" // radio button ( 1=Opção Exclusiva )
	
							 			DbSelectArea( "TJ5" )
							 			DbSetOrder( 01 ) // TJ5_FILIAL+TJ5_QUEST+DTOS( TJ5_DTRESP )+TJ5_FUNC+TJ5_TAR+TJ5_CC+TJ5_AMB+TJ5_LOC+TJ5_MAT+TJ5_OSSIMU+TJ5_PERG+TJ5_RESPCD+TJ5_SEQGTD
							 			If DbSeek( xFilial( "TJ5" ) + M->TJ1_QUESTI + DTOS( M->TJ1_DTINC ) + M->TJ1_FUNC + M->TJ1_TAR + M->TJ1_CC + M->TJ1_AMB + M->TJ1_LOC + M->TJ1_MAT + cOrdemSimul + cSeqRespost + Padr( aPerguntas[nT][_QUESTA_],TAMSX3( "TJ5_PERG" )[1] ) )
							 				// inicializa caso seja alteração. 
											aDados[nPosPerg][4] := TJ5->TJ5_RESPCD
											cCodigoComp         := TJ5->TJ5_RESPCD
											lFoundResp := .T.
										Else
											lFoundResp := .F.
										EndIf

										aItens := {}
										aItens := fRetOpcQt( M->TJ1_QUESTI,aPerguntas[nT][_QUESTA_] )

							 			nAcumLi   := 0
										nLimCol   := nLargura - 50
										nLinhaRad := 15

										// Esse ajuste técnico foi feito porque quando se trata de um btn de radio (Opção Única), não é possível setar o 
										// foco sobre o mesmo, visto que para montar radio uso o objeto TBtnBmp2, porém, é preciso que sempre após
										// sair de uma questão o foco seja posicionado na questão imediatamente posterior, então, para conseguir setar 
										// o foco neste tipo de pergunta, coloquei um campo Get que fica oculto dentro da panel da Pergunta em questão, 
										// dessa forma, 'seto' o foco não no objeto TBtnBmp2 em si (uma vez que isso não é possível) mas sim no campo
										// get que está oculto dentro de sua panel (a panel da pergunta do tipo Opção Única).

										oGetOculto := tGet():New( -004,-005,{ |u| If( PCount() > 0,cValCpoOclt := u,cValCpoOclt ) },oScrollPer,000,009,"@!" )

										nLarguraMax := nLargura / 8

										// Monta botões radio com base no aItens
							 			For nW := 1 To Len( aItens )
							 			
							 				cOpcAtual := AllTrim( aItens[nW] )
	
											If ( nAcumLi + Len( SubStr( cOpcAtual,3,Len( cOpcAtual ) ) ) + 5 ) > nLarguraMax
												nLinhaRad += 9
												nAcumli   := 0
											EndIf
	
											nPosEq := At( "=",cOpcAtual )
											cValor := SubStr( cOpcAtual,1,nPosEq-1 )
	
											If !lFoundResp
												cCodigoComp := AllTrim( aPerguntas[nT][_DEFAUL_] )
												aDados[nPosPerg][4] := cCodigoComp
											EndIf
											cOpcExibir := SubStr( cOpcAtual,nPosEq + 1,Len( cOpcAtual ) )
		
											aAdd( aRadios,{ nPosPerg,tBtnBmp2():New( nLinhaRad * 2,26 + ( nAcumLi * 7 ),14,14,If( AllTrim( cCodigoComp ) == AllTrim( cValor ),"ngradiook","ngradiono" ),,,,{||},oScrollPer,,,.T. ) } )
											// oSay := TSay():New( nLinhaRad,22 + ( nAcumLi * 3.5 ),,oScrollPer,,,,,,.T.,RGB( 67,70,87 ),,200,010 )
				        	       				// oSay:SetText( cOpcExibir )

			    							@ nLinhaRad,22 + ( nAcumLi * 3.5 ) Say oSay Prompt Space( 30 ) Pixel Of oScrollPer
			    							oSay:SetText( cOpcExibir )

											nSeqRadios := Len( aRadios )
											If !lVisual
				        	       				aRadios[nSeqRadios][2]:bLClicked := &( "{ || fRadioB001( " + cValToChar( nPosPerg ) + "," + cValToChar( nSeqRadios ) + " , '" + cValor + "') }" )
												aRadios[nSeqRadios][2]:bAction   := &( "{ || fRadioB001( " + cValToChar( nPosPerg ) + "," + cValToChar( nSeqRadios ) + " , '" + cValor + "') }" )
											EndIf
		
											nAcumLi += Len( cOpcAtual ) + 4
							 			Next nW

							 			cCodigoComp := " "
							 			lFoundResp  := .F.
							 		ElseIf aPerguntas[nT][_TPLIST_] == "2" // check box ( 2=Múltiplas Opções )
											 		
							 			aItens := {}
							 			aItens := fRetOpcQt( M->TJ1_QUESTI,aPerguntas[nT][_QUESTA_] )

							 			nAcumLi   := 0
										nLimCol   := aSize[5] / 8
										nLinhaRad := 15

										// Verifica a opção default
										DbSelectArea( "TJ3" )
										DbSetOrder( 01 ) // TJ3_FILIAL+TJ3_QUESTI+TJ3_QUESTA
										DbSeek( xFilial( "TJ3" ) + M->TJ1_QUESTI + aPerguntas[nT][_QUESTA_] )
										cDefaultTJ3 := TJ3->TJ3_DEFAUL
										// Monta botões check box com base em aItens
							 			For nW := 1 To Len( aItens )
							 			
							 				cOpcAtual := AllTrim( aItens[nW] )
		
											If ( nAcumLi + Len( SubStr( cOpcAtual,3,Len( AllTrim( cOpcAtual ) ) ) ) + 5 ) > nLimCol
										   		nLinhaRad += 9
				   								nAcumLi   := 0
											EndIf

											nPosEq := At( "=",cOpcAtual )
											cValor := SubStr( cOpcAtual,1,nPosEq-1 )

											cOpcExibir := SubStr( cOpcAtual,nPosEq + 1,Len( cOpcAtual ) )
											lChk := AllTrim( cValor ) == AllTrim( cDefaultTJ3 ) // Marca default

											aAdd( aChks,{ ,aPerguntas[nT][_QUESTA_],cValor,lChk } )
											nPos := Len( aChks )

											DbSelectArea( "TJ5" )
							 				DbSetOrder( 01 ) // TJ5_FILIAL+TJ5_QUEST+DTOS( TJ5_DTRESP )+TJ5_FUNC+TJ5_TAR+TJ5_CC+TJ5_AMB+TJ5_LOC+TJ5_MAT+TJ5_OSSIMU+TJ5_PERG+TJ5_RESPCD+TJ5_SEQGTD
							 				If nOpcx != 3
							 					aChks[nPos][4] := DbSeek( xFilial( "TJ5" ) + M->TJ1_QUESTI + DTOS( M->TJ1_DTINC ) + M->TJ1_FUNC + M->TJ1_TAR + M->TJ1_CC + M->TJ1_AMB + M->TJ1_LOC + M->TJ1_MAT + cOrdemSimul + cSeqRespost + Padr( aPerguntas[nT][_QUESTA_],TAMSX3( "TJ5_PERG" )[1] ) + Padr( cValor,TAMSX3( "TJ5_RESPCD" )[1] ) )
							 				EndIf

											aChks[nPos][1] := tCheckBox():New( nLinhaRad - 1,13 + ( nAcumLi * 3.5 ),cOpcExibir,,oScrollPer,13 + ( Len( cOpcExibir ) * 3.9 ),007,,,,,,,,.T.,,, )
											aChks[nPos][1]:bSetGet := &( "{ |u| if( PCount() == 0,aChks[" + cValToChar( nPos ) + "][4],aChks[" + cValToChar( nPos ) + "][4] := u ) }" )
											aChks[nPos][1]:bWhen := { || !lVisual }

											nAcumLi += Len( cOpcExibir ) + 8

							 			Next nW
		
							 		ElseIf aPerguntas[nT][_TPLIST_] $ "345" // msget ( 3=Texto Descritivo;4=Numérico;5=Result. Formul. )
							 		
							 			DbSelectArea( "TJ5" )
							 			DbSetOrder( 01 ) // TJ5_FILIAL+TJ5_QUEST+DTOS( TJ5_DTRESP )+TJ5_FUNC+TJ5_TAR+TJ5_CC+TJ5_AMB+TJ5_LOC+TJ5_MAT+TJ5_OSSIMU+TJ5_PERG+TJ5_RESPCD+TJ5_SEQGTD
							 			DbSeek( xFilial( "TJ5" ) + M->TJ1_QUESTI + DTOS( M->TJ1_DTINC ) + M->TJ1_FUNC + M->TJ1_TAR + M->TJ1_CC + M->TJ1_AMB + M->TJ1_LOC + M->TJ1_MAT + cOrdemSimul + cSeqRespost + Padr( aPerguntas[nT][_QUESTA_],TAMSX3( "TJ5_PERG" )[1] ) )
		
							 			nPos := Len( aDados )
							 			lHasButton := .F.
										
										If !( aPerguntas[nT][_TPLIST_] $ "45" )
											cPict := "@!"
											aDados[nPos][4] := SubStr( TJ5->TJ5_TEXTD,1,aPerguntas[nT][_TAM_] ) // If( !Empty( TJ5->TJ5_TEXTD ),TJ5->TJ5_TEXTD,Space( aPerguntas[nT][_TAM_] ) )
											nSize := 300
										Else
											cPict := "@E " + If ( aPerguntas[nT][_TPLIST_] == "4",aPerguntas[nT][_FORMAT_],"999,999.99" )
											aDados[nPos][4] := If( TJ5->TJ5_NUMERI != 0,TJ5->TJ5_NUMERI,0 )
											nSize := 80
											lHasButton := .T.
										EndIf

										nLinhaRad := 15
										aDados[nPos][3] := tGet():New( nLinhaRad,013,&( "{ |u| if( PCount() > 0,aDados[" + cValToChar( nPos ) + "][4] := u,aDados[" + cValToChar( nPos ) + "][4] ) }" ),oScrollPer,nSize,009,cPict,,,,,,,.T.,,,,,,,,,,,,,,lHasButton,, )
										aDados[nPos][3]:bWhen := If ( aPerguntas[nT][_TPLIST_] == "5",{ || .f. },{ || !lVisual } )

							 		EndIf

							 		// Gera campo Memo caso a pergunta tenha
									If aPerguntas[nT][_OBS_] // Indica se a questão possui campo Memo
									
										// Se pergunta tipo radio button incrementa 5, senão incrementa 12
										nLinhaRad += If( aPerguntas[nT][_TPLIST_] == "1",10,12 )
								
										aAdd( aMemos,{ aPerguntas[nT][_QUESTA_],"" } )
										nPosMemo := Len( aMemos )
								
										DbSelectArea( "TJ5" )
										DbSetOrder( 01 ) // TJ5_FILIAL+TJ5_QUEST+DTOS( TJ5_DTRESP )+TJ5_FUNC+TJ5_TAR+TJ5_CC+TJ5_AMB+TJ5_LOC+TJ5_MAT+TJ5_OSSIMU+TJ5_PERG+TJ5_RESPCD+TJ5_SEQGTD
										DbSeek( xFilial( "TJ5" ) + M->TJ1_QUESTI + DTOS( M->TJ1_DTINC ) + M->TJ1_FUNC + M->TJ1_TAR + M->TJ1_CC + M->TJ1_AMB + M->TJ1_LOC + M->TJ1_MAT + cOrdemSimul + cSeqRespost + Padr( aPerguntas[nT][_QUESTA_],TAMSX3( "TJ5_PERG" )[1] ) )
										
										aMemos[nPosMemo][2] := If( !Empty( TJ5->TJ5_RESMCD ),MSMM( TJ5->TJ5_RESMCD ),"" )
								
										// exibe campo memo
										oMemo := tMultiget():New( nLinhaRad,12,&( "{ |u| If( PCount() > 0,aMemos[" + cValToChar( nPosMemo ) + "][2] := u,aMemos[" + cValToChar( nPosMemo ) + "][2] ) }" ),oScrollPer,( nLargura/2 ) - 100,25,,,,,,.T. )
										oMemo:EnableHScroll( .T. )
										oMemo:EnableVScroll( .T. )
										oMemo:bWhen := { || !lVisual }

									EndIf

								EndIf
							EndIf
						Next nT
					EndIf
				Next nI

				nLinObj += 15

				//--------------------------------
				// campo memo de TJ1. Comentários
				//--------------------------------
				oSay := tSay():New( nLinObj,12,,oScroll,,,,,,.T.,RGB( 67,70,87 ),,200,010 )
		        	oSay:SetText( M->TJ1_TITULO )

		        nLinObj += 12

		        M->TJ1_COMTVM := MSMM( M->TJ1_COMTCM )

				oMemoTJ1 := tMultiget():New( nLinObj,12,{ |u| If( PCount() > 0,M->TJ1_COMTVM := u,M->TJ1_COMTVM ) },oScroll,( nLargura/2 ) - 53,50,,,,,,.T. )
					oMemoTJ1:EnableHScroll( .T. )
					oMemoTJ1:EnableVScroll( .T. )
					oMemoTJ1:bWhen := { || !lVisual }

		//--------------------------------
		// adiciona botões na enchoice
		//--------------------------------
		aAdd( aButtons, { "pcoimg32_mdi.png",{ || fIncAnsw()   },STR0026  } )  // "Questi." 
		aAdd( aButtons, { "colform_mdi.png" ,{ || fCalcFB001() },STR0027  } )  // "Calcular"

		If nOpcx != 3
			aAdd( aButtons, { "rpmimg32_mdi.png" , { || IMPMDTB001() },STR0008 } ) // "Imprimir"
		EndIf

	Activate MsDialog oDlgResp On Init EnchoiceBar( oDlgResp,{ || lConfirm := .T.,If( !AllwaysTrue(),lConfirm := .F.,oDlgResp:End() ) },;
															 { || lConfirm := .F.,oDlgResp:End() },,aButtons )

	// Grava dados caso Confirmar
	If lConfirm
		Begin Transaction
			Processa( { || MDTB001GRV( nOpcx ) } )
		End Transaction
		lRet := .T.
	EndIf

Return lRet

//---------------------------------------------------------------------
/*/{Protheus.doc} IMPMDTB001
imprimir relatório de respostas do questionário.

@param string cChave: para chamadas externas, informa a chave única da
tabela de cabeçalho de respostas.
@author André Felipe Joriatti
@since 20/03/2013
@version MP11
@return nil
/*/
//---------------------------------------------------------------------

Function IMPMDTB001( cChave )
	MDTR910()
Return Nil

//---------------------------------------------------------------------
/*/{Protheus.doc} fRetPerg
Retorna array com as perguntas do questionario informado nos parametros.

@param string cQuesti: indica o questionário que se deseja recuper as pergs.
@author André Felipe Joriatti
@since 18/03/2013
@version MP11
@return array aPergs: indica as perguntas do questionário.
@Estrutura do array:
	aPergs[n][1]: Código do grupo da pergunta. Char
	aPergs[n][2]: Código da pergunta. Char
	aPergs[n][3]: Ordem da pergunta, é utilizado para ordenação (apresentação visual). Char
	aPergs[n][4]: Tipo da pergunta. Char
	aPergs[n][5]: Sexo. Char
	aPergs[n][6]: Possui campo Obs.?. Boolean
	aPergs[n][7]: Texto da pergunta em si. Char
	aPergs[n][8]: Conteudo da pergunta, se possuir (se for de opções). Char
	aPergs[n][9]: Tamanho. Int
	aPergs[n][10]: Formato. Char
	aPergs[n][11]: Tipo do grupo (titulo central, titulo de colunas, etc). Char
	aPergs[n][12]: Valor default da questão. Char
	aPergs[n][13]: tipo do grupo, se normal ou rótulo. Char
/*/
//---------------------------------------------------------------------

Static Function fRetPerg( cQuesti )

	Local aArea     := GetArea()
	Local aPergs    := {}
	Local cQuery    := ""
	Local cTRBQuery := GetNextAlias()

	#IFNDEF TOP
		NGIFDBSEEK( "TJ3",cQuesti,01 ) // TJ3_FILIAL+TJ3_QUESTI+TJ3_QUESTA
		While !EoF() .And. TJ3->( TJ3_FILIAL + TJ3_QUESTI ) ==  xFilial( "TJ3" ) + cQuesti
			
			aAdd( aPergs,{ TJ3->TJ3_CODGRU,;                      // _CODGRU_
						   TJ3->TJ3_QUESTA,;                      // _QUESTA_
						   TJ3->TJ3_ORDEM,;                       // _ORDEM_
						   TJ3->TJ3_TPLIST,;                      // _TPLIST_
						   TJ3->TJ3_INDSEX,;                      // _INDSEX_ // 1=Masculino;2=Feminino;3=Ambos
						   If( TJ3->TJ3_ONMEMO == "1",.T.,.F. ),; // _OBS_
						   TJ3->TJ3_PERGUN,;                      // _PERGUN_
						   TJ3->TJ3_COMBO,;                       // _COMBO_
						   TJ3->TJ3_TAM,;                         // _TAM_
						   TJ3->TJ3_FORMAT,;                      // _FORMAT_
						   NGSEEK( "TJ4",PadR( TJ3->TJ3_CODGRU,TAMSX3( "TJ4_CODGRU" )[1] ),1,"TJ4->TJ4_TIPREG" ),; // _TIPGRP_
						   TJ3->TJ3_TIPGRP,;                      // _TPGRPP_
						   TJ3->TJ3_DEFAUL,;                      // _DEFAUL_
						   TJ3->TJ3_ORDGRP,;                      // _ORDGRP_
						 } )

			NGDBSELSKIP( "TJ3" )
		End While

	#ELSE
		cQuery := "SELECT TJ3_CODGRU,TJ3_QUESTA, "
		cQuery +=  	"TJ3_ORDEM,TJ3_TPLIST, "
		cQuery +=  	"TJ3_INDSEX,TJ3_ONMEMO, "
		cQuery +=  	"TJ3_PERGUN,TJ3_COMBO, "
		cQuery +=  	"TJ3_TAM,TJ3_FORMAT,TJ3_TIPGRP,TJ3_DEFAUL,TJ3_ORDGRP FROM " + RetSQLName( "TJ3" ) + " "
		cQuery += "WHERE TJ3_FILIAL = '" + xFilial( "TJ3" ) + "' AND TJ3_QUESTI = '" + cQuesti + "' AND D_E_L_E_T_ <> '*'"

		cQuery := ChangeQuery( cQuery )
		aPergs := {}
		MPSysOpenQuery( cQuery , cTRBQuery )
		
		( cTRBQuery )->( DbGoTop() )
		While !( cTRBQuery )->( EoF() )
			aAdd( aPergs,{ ( cTRBQuery )->TJ3_CODGRU,;                  // _CODGRU_
					   ( cTRBQuery )->TJ3_QUESTA,;                      // _QUESTA_
					   ( cTRBQuery )->TJ3_ORDEM,;                       // _ORDEM_
					   ( cTRBQuery )->TJ3_TPLIST,;                      // _TPLIST_
					   ( cTRBQuery )->TJ3_INDSEX,;                      // _INDSEX_ // 1=Masculino;2=Feminino;3=Ambos
					   If( ( cTRBQuery )->TJ3_ONMEMO == "1",.T.,.F. ),; // _OBS_
					   ( cTRBQuery )->TJ3_PERGUN,;                      // _PERGUN_
					   ( cTRBQuery )->TJ3_COMBO,;                       // _COMBO_
					   ( cTRBQuery )->TJ3_TAM,;                         // _TAM_
					   ( cTRBQuery )->TJ3_FORMAT,;                      // _FORMAT_
					   NGSEEK( "TJ4",PadR( ( cTRBQuery )->TJ3_CODGRU,TAMSX3( "TJ4_CODGRU" )[1] ),1,"TJ4->TJ4_TIPREG" ),; // _TIPGRP_
					   ( cTRBQuery )->TJ3_TIPGRP,;                      // _TPGRPP_
					   ( cTRBQuery )->TJ3_DEFAUL,;                      // _DEFAUL_
					   ( cTRBQuery )->TJ3_ORDGRP,;                      // _ORDGRP_
					 } )
			( cTRBQuery )->( DbSkip() )
		End While

		( cTRBQuery )->( DbCloseArea() )
		Use

	#ENDIF

	RestArea( aArea )

Return aPergs

//---------------------------------------------------------------------
/*/{Protheus.doc} fRetGrp
retorna grupos de forma distinta de acordo com o array de questões 
informado nos parametros.

@param array aPerguntas: indica o array de perguntas que se deseja extrair 
de forma distinta os grupos
@author André Felipe Joriatti
@since 19/03/2013
@version MP11
@return array aGrps: indica os grupos das perguntas
/*/
//---------------------------------------------------------------------

Static Function fRetGrp( aPerguntas )

	Local aGrps     := {}
	Local nI        := 0
	Local aSortGrps := {} // armazena grupos de forma ordenada pela sua ordem

	For nI := 1 To Len( aPerguntas )
		If aScan( aGrps,{ |x| AllTrim( x[1] ) == AllTrim( aPerguntas[nI][_CODGRU_] ) } ) == 0
			If !( aPerguntas[nI][_TIPGRP_] $ "34" )
				aAdd( aGrps,{ aPerguntas[nI][_CODGRU_],aPerguntas[nI][_TIPGRP_],aPerguntas[nI][_TPGRPP_],aPerguntas[nI][_ORDGRP_] } )
			EndIf
		EndIf
	Next nI

Return aGrps

//---------------------------------------------------------------------
/*/{Protheus.doc} fRetOpcQt
retorna array de opções para questões do questionário que seja do tipo
opção exclusiva ou multiplas opções.

@param string cQuesti: indica o código do questionário.
@param string cQest: indica código da questão do questionário. 
@author André Felipe Joriatti
@since 19/03/2013
@version MP11
@return array aOpcs: indica opções da questão
/*/
//---------------------------------------------------------------------

Static Function fRetOpcQt( cQuesti,cQest )

	Local aOpcs   := {}
	Local cCombo  := NGSEEK( "TJ3",cQuesti + cQest,1,"TJ3->TJ3_COMBO" )
	Local nI      := 0
	Local aOp     := StrTokArr( cCombo, ";" )
	Local nPosAst := 0

	For nI := 1 To Len( aOp )
		if "*" $ aOp[nI]
			nPosAst := At( "*",aOp[nI] )
			aAdd( aOpcs,SubStr( aOp[nI],1,nPosAst - 1 ) )
		EndIf
	Next nI

	If Len( aOpcs ) == 0
		aOpcs := aOp
	EndIf

Return aOpcs

//---------------------------------------------------------------------
/*/{Protheus.doc} MDTB001GRV
Efetua gravação dos dados da rotina.

@param integer nOpcx: indica operação que esta sendo realizada 
@author André Felipe Joriatti
@since 20/03/2013
@version MP11
/*/
//---------------------------------------------------------------------

Function MDTB001GRV( nOpcx )

	Local aArea       := GetArea()
	Local cOrdemSimul := If( IsInCallStack( "SGAA220" ),TRBQ->TBQ_ORDEM,Space( TAMSX3( "TJ5_OSSIMU" )[1] ) )
	Local lSeqRes		:= TJ5->( FieldPos( "TJ5_SEQRES" ) ) > 0
	Local cSeqRespost	:= If( lSeqRes ,If( Type("M->TJ1_SEQRES") <> "U",  M->TJ1_SEQRES , Space( TAMSX3( "TJ5_SEQRES" )[1] ) ) , "" )
	Local cChaveTJ5   := xFilial( "TJ5" ) +;
			        	 PadR( M->TJ1_QUESTI,TAMSX3( "TJ5_QUEST" )[1] ) +;
 			        	 DTOS( M->TJ1_DTINC ) +;
			        	 PadR( M->TJ1_FUNC,TAMSX3( "TJ5_FUNC" )[1]    ) +;	
			        	 PadR( M->TJ1_TAR,TAMSX3( "TJ5_TAR" )[1]      ) +;
			        	 PadR( M->TJ1_CC,TAMSX3( "TJ5_CC" )[1]        ) +;
			        	 PadR( M->TJ1_AMB,TAMSX3( "TJ5_AMB" )[1]      ) +;
			        	 PadR( M->TJ1_LOC,TAMSX3( "TJ5_LOC" )[1]      ) +;
			        	 PadR( M->TJ1_MAT,TAMSX3( "TJ5_MAT" )[1]      ) +;
			        	 PadR( cOrdemSimul,TAMSX3( "TJ5_OSSIMU" )[1]  ) +;
			        	 cSeqRespost

	Local cFuncao    := NGSEEK( "TJ2",M->TJ1_QUESTI,1,"TJ2->TJ2_FUNC" )
	Local cTar       := NGSEEK( "TJ2",M->TJ1_QUESTI,1,"TJ2->TJ2_TAR"  )
	Local cCC        := NGSEEK( "TJ2",M->TJ1_QUESTI,1,"TJ2->TJ2_CC"   )
	Local cAmb       := NGSEEK( "TJ2",M->TJ1_QUESTI,1,"TJ2->TJ2_AMB"  )
	Local cLoc       := NGSEEK( "TJ2",M->TJ1_QUESTI,1,"TJ2->TJ2_LOC"  )	
	Local cMat       := M->TJ1_MAT
	Local nI         := 0
	Local nT         := 0
	Local nW         := 0
	Local cTextoD    := ""
	Local nNumerico  := 0
	Local cTipoQst   := ""
	Local cCdOpExc   := ""
	Local lDel       := .F.
	Local lNaoGrava  := .F.

	If NGIFDBSEEK( "TJ2",M->TJ1_QUESTI,01 ) // TJ2_FILIAL+TJ2_QUESTI

		If cValToChar( nOpcx ) $ "34"
			// grava cabeçalho de respostas
			RecLock( "TJ1",nOpcx == 3 )
			TJ1->TJ1_FILIAL  := xFilial( "TJ1" )
			TJ1->TJ1_QUESTI  := M->TJ1_QUESTI
			TJ1->TJ1_FUNC    := cFuncao
			TJ1->TJ1_TAR     := cTar
			TJ1->TJ1_CC      := cCC
			TJ1->TJ1_AMB     := cAmb
			TJ1->TJ1_LOC     := cLoc
			TJ1->TJ1_TPFUN   := M->TJ1_TPFUN
			TJ1->TJ1_MAT     := cMat
			TJ1->TJ1_TPRES   := M->TJ1_TPRES
			TJ1->TJ1_RESPENT := M->TJ1_RESPENT
			TJ1->TJ1_DTINC   := M->TJ1_DTINC
			TJ1->TJ1_USER    := cUserName
			TJ1->TJ1_TITULO  := M->TJ1_TITULO
			TJ1->TJ1_OSSIMU  := If( IsInCallStack( "SGAA220" ),TRBQ->TBQ_ORDEM,"" )
			If !Empty( cSeqRespost )
				TJ1->TJ1_SEQRES:= cSeqRespost
			EndIf

			// gravação de memo na SYP
			If nOpcx == 3 .And. !Empty( M->TJ1_COMTVM )
				TJ1->TJ1_COMTCM := MSMM( ,TAMSX3( "TJ1_COMTVM" )[1],,M->TJ1_COMTVM,1,,,"TJ1","TJ1_COMTCM" )
			ElseIf nOpcx == 4
				MSMM( TJ1->TJ1_COMTCM,TAMSX3( "TJ1_COMTVM" )[1],,M->TJ1_COMTVM,1,,,"TJ1","TJ1_COMTCM" )
			EndIf
			MsUnLock( "TJ1" )

			//--------------------------------------------------------------------------------
			// exclui todos os registros de respostas relacionados a resposta de questionario
			//--------------------------------------------------------------------------------
			If nOpcx == 4 // Alteração

				DbSelectArea( "TJ5" )
				DbSetOrder( 01 )
				DbSeek( cChaveTJ5 )
				While !EoF() .And. TJ5->( TJ5_FILIAL+TJ5_QUEST+DTOS( TJ5_DTRESP )+TJ5_FUNC+TJ5_TAR+TJ5_CC+TJ5_AMB+TJ5_LOC+TJ5_MAT+TJ5_OSSIMU + If(lSeqRes,TJ5_SEQRES,"" )) == cChaveTJ5
					
					// Exclui da SYP conforme chave
					MSMM( TJ5->TJ5_RESMCD,Nil,Nil,Nil,2,Nil,Nil,"TJ5","TJ5_RESMCD","SYP" )
					
					DbSelectArea( "TJ5" )
					RecLock( "TJ5",.F. )
					DbDelete()
					MsUnLock( "TJ5" )
					NGDBSELSKIP( "TJ5" )
				EndDo
			EndIf

			//--------------------------------------------------------------------------------
			// Formato de aDados:
	        // aAdd( aDados,{ IdSequencial,TipoPergunta,Objeto,Valor,Questão/Pergunta } )
	        //--------------------------------------------------------------------------------

			NGDBAREAORDE( "TJ5",01 ) // TJ5_FILIAL+TJ5_QUEST+DTOS( TJ5_DTRESP )+TJ5_FUNC+TJ5_TAR+TJ5_CC+TJ5_AMB+TJ5_LOC+TJ5_MAT+TJ5_PERG+TJ5_RESPCD+TJ5_SEQGTD
			// Grava itens de respostas
			For nI := 1 To len( aDados )

				nPosMemo := aScan( aMemos,{ |x| AllTrim( x[1] ) == AllTrim( aDados[nI][5] ) } )

				If aDados[nI][2] == "1" .And. !Empty( aDados[nI][4] ) // radio button opção unica.
					fMngRecTJ5( .F.,; //  Indica se registro deletado
								M->TJ1_QUESTI,; // Indica código de Questionário
								M->TJ1_DTINC,; // Indica data da resposta
								aDados[nI][5],; // Indica código da questão
								cFuncao,; // Indica Código da Função
								cTar,; // Indica código da tarefa
								cCC,; // Indica centro de custo
								cAmb,; // Indica Ambiente
								cLoc,; // Indica Localização
								cMat,; // Indica Responsável
								aDados[nI][4],; // Indica código da questão
								"",; // Indica sequencial de get dados
								fRetPItem( M->TJ1_QUESTI,aDados[nI][5],aDados[nI][4] ),; // Indica peso da questão
								"",; // Indica texto descritivo
								0,; // Indica conteúdo numérico
								If( nPosMemo != 0,aMemos[nPosMemo][2],"" ),; // Indica Memo
								cSeqRespost,;
								nOpcx; // Indica operação atual
							  )

				ElseIf aDados[nI][2] == "2" // check box, multiplas opções

					For nT := 1 To Len( aChks )
						If aChks[nT][4] .And. !Empty( aChks[nT][3] ) .And. AllTrim( aDados[nI][5] ) == AllTrim( aChks[nT][2] )
							fMngRecTJ5( .F.,; // Indica se deletado
										M->TJ1_QUESTI,; // Indica código questionário
									    M->TJ1_DTINC,; // Indica data do questionário
									    aDados[nI][5],; // Indica código da questão
									    cFuncao,; // Indica código da função
									    cTar,; // Indica código da tarefa
									    cCC,; // Indica centro de custo
									    cAmb,; // Indica Ambiente
									    cLoc,; // Indica Localização
									    cMat,; // Indica responsável
									    aChks[nT][3],; // Indica código da questão
									    "",; // Indica sequencia de get dados
									    fRetPItem( M->TJ1_QUESTI,aDados[nI][5],aChks[nT][3] ),; // Indica peso da questão
									    "",; // Indica texto descritivo
									    0,; // Indica conteúdo numérico
									    If( nPosMemo != 0,aMemos[nPosMemo][2],"" ),; // Indica Memo
									    cSeqRespost,;
									    nOpcx; // Indica operação atual
									  )

						EndIf
					Next nT

				ElseIf aDados[nI][2] $ "345"

					cTextoD   := If( AllTrim( aDados[nI][2] ) == "3",aDados[nI][4],"" )
					nNumerico := If( AllTrim( aDados[nI][2] ) $ "45",aDados[nI][4],0 )

					If aDados[nI][2] $ "3"
						lNaoGrava := Empty( aDados[nI][4] )
					EndIf

					If !lNaoGrava
						fMngRecTJ5( .F.,; // Indica se deletado
									M->TJ1_QUESTI,; // Indica código do questionário
									M->TJ1_DTINC,; // Indica data de resposta
									aDados[nI][5],; // Indica código da questão
									cFuncao,; // Indica código da Função
									cTar,; // Indica código da tarefa
									cCC,; // Indica código do Centro de Custo
									cAmb,; // Indica Código do Ambiente
									cLoc,; // Indica Código da Localização
									cMat,; // Indica responsável
									"",; // Indica Código da resposta
									"",; // Indica sequencia de get dados
									0,; // Indica peso da questão
									cTextoD,; // Indica texto descritivo
									nNumerico,; // Indica numérico
									If( nPosMemo != 0,aMemos[nPosMemo][2],"" ),; // Indica conteudo do memo
									cSeqRespost,;
									nOpcx;// Indica código da operação atual
								  )
					EndIf

					lNaoGrava := .F.
				EndIf

			Next nI
			
			// insere, altera, deleta referentes a grupos de titulo de colunas (getdados dinâmica)
			For nI := 1 To Len( aGetDdsGrp )
				For nT := 1 To Len( aGetDdsGrp[nI][1]:aCols )
					For nW := 1 To ( Len( aGetDdsGrp[nI][1]:aCols[nT] ) - 2 )
					
						cTipoQst  := NGSEEK( "TJ3",M->TJ1_QUESTI + PadR( SubStr( aGetDdsGrp[nI][1]:aHeader[nW][2],3,4 ),TAMSX3( "TJ3_QUESTA" )[1] ),01,"TJ3->TJ3_TPLIST" )
						
						cCdOpExc  := If( AllTrim( cTipoQst ) == "1",aGetDdsGrp[nI][1]:aCols[nT][nW],"" )
						cTextoD   := If( AllTrim( cTipoQst ) == "3",aGetDdsGrp[nI][1]:aCols[nT][nW],"" )
						nNumerico := If( AllTrim( cTipoQst ) $ "45",aGetDdsGrp[nI][1]:aCols[nT][nW],0  )

						lDel      := aGetDdsGrp[nI][1]:aCols[nT][Len( aGetDdsGrp[nI][1]:aCols[nT] )]
						
						// valida se registro está vazio.
						If !( Empty( cCdOpExc ) .And. Empty( cTextoD ) .And. nNumerico == 0 )
							
							// Teste
							cSeqGD := aGetDdsGrp[nI][1]:aCols[nT][Len( aGetDdsGrp[nI][1]:aCols[nT] ) - 1]

							fMngRecTJ5( lDel,; // Indica se deletado
										M->TJ1_QUESTI,; // Indica o Código do Questionário
										M->TJ1_DTINC,; // Indica Data da resposta
										SubStr( aGetDdsGrp[nI][2][nW][2],3,4 ),; // Indica código da Questão
										cFuncao,; // Indica Código da Função relacionada ao Questionário
										cTar,; // Indica Código da Tarefa
										cCC,; // Indica Código C.C.
										cAmb,; // Indica Código do Ambiente
										cLoc,; // Indica Localização
										cMat,; // Indica Responsável
										cCdOpExc,; // Código resposta
										aGetDdsGrp[nI][1]:aCols[nT][Len( aGetDdsGrp[nI][1]:aCols[nT] ) - 1],; // Sequencial linha da get dados
										If( AllTrim( cTipoQst ) == "1",fRetPItem( M->TJ1_QUESTI,SubStr( aGetDdsGrp[nI][1]:aHeader[nW][2],3,4 ),cCdOpExc ),0 ),; // Peso da questão
										cTextoD,; // Resposta texto descritivo
										nNumerico,; // Resposta numérico
										"",; // Memo
										cSeqRespost,;
										nOpcx,; // Operação atual
								      )
						EndIf
					Next nW
				Next nT

			Next nI

		ElseIf nOpcx == 5

			DbSelectArea( "TJ5" )
			DbSetOrder( 01 ) // TJ5_FILIAL+TJ5_QUEST+DTOS( TJ5_DTRESP )+TJ5_FUNC+TJ5_TAR+TJ5_CC+TJ5_AMB+TJ5_LOC+TJ5_MAT+TJ5_OSSIMU+TJ5_PERG+TJ5_RESPCD+TJ5_SEQGTD
			DbSeek( cChaveTJ5 )
			While !EoF() .And. TJ5->( TJ5_FILIAL+TJ5_QUEST+DTOS( TJ5_DTRESP )+TJ5_FUNC+TJ5_TAR+TJ5_CC+TJ5_AMB+TJ5_LOC+TJ5_MAT+TJ5_OSSIMU + If(lSeqRes,TJ5_SEQRES,"" ) ) == cChaveTJ5

				// Exclui da SYP conforme chave
				MSMM( TJ5->TJ5_RESMCD,Nil,Nil,Nil,2,Nil,Nil,"TJ5","TJ5_RESMCD","SYP" )

				RecLock( "TJ5",.F. )
				DbDelete()
			    MsUnLock( "TJ5" )

			    NGDBSELSKIP( "TJ5" )
			EndDo

			// Exclui da SYP conforme chave
			MSMM( TJ1->TJ1_COMTCM,Nil,Nil,Nil,2,Nil,Nil,"TJ1","TJ1_COMTCM","SYP" )

			RecLock( "TJ1",.F. )
			DbDelete()
			MsUnLock( "TJ1" )
		EndIf

	EndIf

	RestArea( aArea )

Return Nil

//---------------------------------------------------------------------
/*/{Protheus.doc} fRadioB001
Inverte o radio da pergunta conforme o id informado no parametro, 
que será usado para localizar a pergunta no array aDados

@param integer nPos: indica a posição da pergunta em questão
@author André Felipe Joriatti
@since 21/03/2013
@version MP11
@return boolean lRet: sempre true 
/*/
//---------------------------------------------------------------------

Static Function fRadioB001( nPos,nPosRadio,cValor )

	Local lRet := .T.
	Local nI   := 0

	cValorC := If( ValType( cValor ) == "N",cValToChar( cValor ),cValor )

	// coloca todos os radios da pergunta em questão como nao marcados
	For nI := 1 To Len( aRadios )
		If aRadios[nI][1] == nPos
			aRadios[nI][2]:LoadBitmaps( "ngradiono" )
			If aDados[nPos][4] != "0"
				aDados[nPos][4] := "0"
			EndIf
		EndIf
	Next nI

	If aDados[nPos][4] == "0" // não marcado
		aRadios[nPosRadio][2]:LoadBitmaps( "ngradiook" )
		aDados[nPos][4] := cValorC
	EndIf
	oScroll:Refresh()

Return lRet

//---------------------------------------------------------------------
/*/{Protheus.doc} fRetPItem
Retorna o peso do item da pergunta do questionario, conforme parametros

@param string cQuesti: indica o questionário
@param string cQuesta: indica a pergunta
@param string cItem: indica o item da pergunta
@author André Felipe Joriatti
@since 26/03/2013
@version MP11
@return integer nPeso: peso do item
/*/
//---------------------------------------------------------------------

Static Function fRetPItem( cQuesti,cQuesta,cItem )

	Local nPeso  := 0
	Local cPeso  := "0"
	Local aArea  := GetArea()
	Local cCombo := NGSEEK( "TJ3",PadR( cQuesti,TAMSX3( "TJ3_QUESTI" )[1] ) + PadR( cQuesta,TAMSX3( "TJ3_QUESTA" )[1] ),1,"TJ3->TJ3_COMBO" )
	Local aItens := {}
	Local nI     := 0

	If !Empty( cCombo )
		
		aItens := StrTokArr( cCombo, ";" )
		
		For nI := 1 To Len( aItens )

			If AllTrim( cItem ) $ SubStr( aItens[nI], 1, At( '=', AllTrim( aItens[nI] ) ) - 1 ) .And. aItens[nI] $ '*P:'
			
				cPeso := SubStr( aItens[nI],At( "*P:",aItens[nI] ) + 3,Len( aItens[nI] ) )
				Exit

			EndIf

		Next nI

	EndIf

	nPeso := Val( cPeso )

	RestArea( aArea )

Return nPeso

//---------------------------------------------------------------------
/*/{Protheus.doc} fCalcFB001
Gera resultados para os campos que recebem resultado de fórmula.

@author André Felipe Joriatti
@since 28/03/2013
@version MP11
@return boolean lRet: sempre true
/*/
//---------------------------------------------------------------------

Static Function fCalcFB001()

	Local lRet      := .T.
	Local nI        := 0
	Local nT        := 0
	Local nW        := 0
	Local nY        := 0
	Local nJ        := 0
	Local nPosDds   := 0
	Local cCodForm  := ""
	Local cFormula  := ""
	Local nResult   := 0
	Local cSubst    := ""
	Local bError    := ErrorBlock( { |e| ChecErro( e ) } )
	Local cQuesti   := PadR( M->TJ1_QUESTI,TAMSX3( "TJ3_QUESTI" )[1] )
	Local cQuestao  := ""
	Local xValor
	Local cTipoQes  := ""
	Local xVal

	Begin Sequence
		//-------------------------------------------
		// Cálculo de Fórmula para questões normais.
		//-------------------------------------------
		For nI := 1 To Len( aPerguntas )
			If aPerguntas[nI][_TPLIST_] == "5" // Questão do tipo resultado de Fórmula.
				cQuestao := PadR( aPerguntas[nI][_QUESTA_],TAMSX3( "TJ3_QUESTA" )[1] )
				nPosDds  := aScan( aDados,{ |x| AllTrim( x[5] ) == AllTrim( cQuestao ) } )
				If nPosDds != 0
					cCodForm := NGSEEK( "TJ3", cQuesti + cQuestao,1,"TJ3->TJ3_FORMUL" )
					If !Empty( cCodForm )
						cFormula := NGSEEK( "TG0",Padr( cCodForm,TAMSX3( "TG0_CODFOR" )[1] ),1,"TG0->TG0_FORMUL" )
						If !Empty( cFormula )
							//---------------------------------------------------------------------------
							// percorre todas as perguntas e verifica se elas estão na fórmula utilizada
							// pela pergunta que recebe fórmula, se sim, pega o valor delas
							// e joga na fórmula
							//---------------------------------------------------------------------------
							For nT := 1 To Len( aDados )
								cSubst := If( AllTrim( aDados[nT][2] ) == "1",;
											  cValToChar( fRetPItem( cQuesti,aDados[nT][5],aDados[nT][4] ) ),; // Caso TRUE
											  AllTrim( If( ValType( aDados[nT][4] ) == "N",cValToChar( aDados[nT][4] ),aDados[nT][4] ) ) ) // Caso FALSE 
								cFormula := StrTran( cFormula,"#" + AllTrim( aDados[nT][5] ) + "#",cSubst )
							Next nT
							
							//-------------------------------------------------------------
							// executa cálculo da fórmula e atribui a pergunta de fórmula
							//-------------------------------------------------------------
							nResult := &( cFormula )
							aDados[nPosDds][4] := If( ValType( nResult ) <> "N", 0 , nResult )
						EndIf
					EndIf
				EndIf
			EndIf
		Next nI
		
		//-------------------------------------------------
		// Cálculo de Fórmula para Grupo Título de Colunas.
		//-------------------------------------------------
		For nI := 1 To Len( aGetDdsGrp ) // Percorre as get dados
			For nT := 1 To Len( aGetDdsGrp[nI][1]:aCols ) // Percorre o aCols das get dados
				For nW := 1 To ( Len( aGetDdsGrp[nI][1]:aHeader ) - 1 )
					cCodForm := NGSEEK( "TJ3",cQuesti + PadR( SubStr( aGetDdsGrp[nI][1]:aHeader[nW][2],3,4 ),TAMSX3( "TJ3_QUESTA" )[1] ),1,"TJ3->TJ3_FORMUL" )
					If !Empty( cCodForm )
						cFormula := NGSEEK( "TG0",PadR( cCodForm,TAMSX3( "TG0_CODFOR" )[1] ),1,"TG0->TG0_FORMUL" )
						If !Empty( cFormula )
							
							// Inicia jogando pra fórmula os valores de questões que não são de Get Dados
							For nY := 1 To Len( aDados )
								cSubst := If( AllTrim( aDados[nY][2] ) == "1",; // Se for do Tipo Opção Única
											  cValToChar( fRetPItem( cQuesti,aDados[nY][5],aDados[nY][4] ) ),; // Caso TRUE
											  AllTrim( If( ValType( aDados[nY][4] ) == "N",cValToChar( aDados[nY][4] ),aDados[nY][4] ) ) ) // Caso FALSE 
								cFormula := StrTran( cFormula,"#" + AllTrim( aDados[nY][5] ) + "#",cSubst )
							Next nY
							
							// Agora jogo pra fórmula valores de questões que estão na fórmula e SÃO da get dados.
							For nJ := 1 To ( Len( aGetDdsGrp[nI][1]:aCols[nT] ) - 2 ) // Percorro apenas a linha atual da Get Dados
								cTipoQes := NGSEEK( "TJ3",cQuesti + PadR( SubStr( aGetDdsGrp[nI][1]:aHeader[nJ][2],3,4 ),TAMSX3( "TJ3_QUESTA" )[1] ),1,"TJ3->TJ3_TPLIST" )
								If cTipoQes == "1" // Caso tipo Opção Única, então pega pelo peso
									cSubst := cValToChar( fRetPItem( cQuesti,PadR( SubStr( aGetDdsGrp[nI][1]:aHeader[nJ][2],3,4 ),TAMSX3( "TJ3_QUESTA" )[1] ),aGetDdsGrp[nI][1]:aCols[nT][nJ] ) )
								Else
									xValor := aGetDdsGrp[nI][1]:aCols[nT][nJ]
									cSubst := If( ValType( xValor ) == "N",cValToChar( xValor ),xValor )
								EndIf
								cFormula := StrTran( cFormula,"#" + AllTrim( PadR( SubStr( aGetDdsGrp[nI][1]:aHeader[nJ][2],3,4 ),TAMSX3( "TJ3_QUESTA" )[1] ) ) + "#",cSubst )
							Next nJ
						EndIf
						xVal := &( cFormula )
						If ValType( xVal ) == "N"
							If xVal > 999999.99 // Se for maior que a picture do campo de fórmula.
								MsgStop( STR0041 ) // "Resultado da Fórmula ultrapassou o tamanho do campo."
								aGetDdsGrp[nI][1]:aCols[nT][nW] := 0
							Else
								aGetDdsGrp[nI][1]:aCols[nT][nW] := &( cFormula ) // Recebe cálculo da formula
							EndIf
						Else
							aGetDdsGrp[nI][1]:aCols[nT][nW] := 0
						EndIf
					EndIf
					
				Next nW
			Next nT
		Next nI

	End Sequence

	ErrorBlock( bError )

Return lRet

//---------------------------------------------------------------------
/*/{Protheus.doc} fRetChrArr
Retorna uma string com os valores do array informado no parametro
concatenados.

@param array aArrTrans: indica array que se deseja converter para string
@author André Felipe Joriatti
@since 03/04/2013
@version MP11
@return string cString: posições do array concatenadas em uma string
/*/
//---------------------------------------------------------------------

Static Function fRetChrArr( aArrTrans )

	Local cString := ""
	Local nI      := 0

	For nI := 1 To Len( aArrTrans )
		cString += 	aArrTrans[nI] + If( nI != Len( aArrTrans ),";","" )
	Next nI

Return cString

//---------------------------------------------------------------------
/*/{Protheus.doc} fMngRecTJ5
Insere ou altera registros na TJ5 de acordo com os parametros informados.

@param boolean lDel: indica se é para deletar o registro.
@param: os parametros seguem a nomenclatura dos campos da tabela com 
o prefixo C_ ao invés do alias, com excessão de C_MEMO que se trata
do valor do campo memo da pergunta de questionário.
@author André Felipe Joriatti
@since 04/04/2013
@version MP11
/*/
//---------------------------------------------------------------------

Static Function fMngRecTJ5( lDel,C_QUEST,C_DTRESP,C_PERG,C_FUNC,C_TAR,C_CC,C_AMB,C_LOC,C_MAT,C_RESPCD,C_SEQGTD,C_RSPSO,C_TEXTD,C_NUMERI,C_MEMO,C_SEQRES,nOpcx )

	If !lDel
		DbSelectArea( "TJ5" )
		RecLock( "TJ5",.T. )
		TJ5->TJ5_FILIAL := xFilial( "TJ5" )
		TJ5->TJ5_QUEST  := C_QUEST
		TJ5->TJ5_DTRESP := C_DTRESP
		TJ5->TJ5_PERG   := C_PERG
		TJ5->TJ5_FUNC   := C_FUNC
		TJ5->TJ5_TAR    := C_TAR
		TJ5->TJ5_CC     := C_CC
		TJ5->TJ5_AMB    := C_AMB
		TJ5->TJ5_LOC    := C_LOC
		TJ5->TJ5_MAT    := C_MAT
		TJ5->TJ5_RESPCD := C_RESPCD
		TJ5->TJ5_SEQGTD := C_SEQGTD
		TJ5->TJ5_RSPSO  := C_RSPSO
		TJ5->TJ5_TEXTD  := C_TEXTD
		TJ5->TJ5_NUMERI := C_NUMERI
		TJ5->TJ5_OSSIMU := If( IsInCallStack( "SGAA220" ),TRBQ->TBQ_ORDEM,"" )
		If !Empty(C_SEQRES)
			TJ5->TJ5_SEQRES := C_SEQRES
		EndIf

		If ( nOpcx == 3 ) .And. !Empty( C_MEMO ) // Inclusão
			TJ5->TJ5_RESMCD := MSMM( ,TAMSX3( "TJ5_RESMV" )[1],,C_MEMO,1,,,"TJ5","TJ5_RESMCD" )
		Else // Alteração
			MSMM( TJ5->TJ5_RESMCD,TAMSX3( "TJ5_RESMV" )[1],,C_MEMO,1,,,"TJ5","TJ5_RESMCD" )
		EndIf

		MsUnLock( "TJ5" )
	EndIf

Return Nil

//---------------------------------------------------------------------
/*/{Protheus.doc} fIncSeq
Incrementa sequencial de controle do agrupamento de registros para 
mostrar em Grupo de perguntas do tipo Título de Colunas (get dados)

@author André Felipe Joriatti
@since 04/04/2013
@version MP11
/*/
//---------------------------------------------------------------------

Function fIncSeq( nSeq )

	Local cSeq     := StrZero( nSeq,3 )
	Local nPosGD   := aScan( aGetDdsGrp,{ |x| AllTrim( x[4] ) == AllTrim( cSeq ) } )
	Local aCols    := aGetDdsGrp[nPosGD][1]:aCols
	Local nI       := 0
	Local cSeqLast := "000"

	For nI := 1 To ( Len( aCols ) - 1 )
		cSeqLast := If( aCols[nI][Len( aCols[nI] ) - 1] > cSeqLast,aCols[nI][Len( aCols[nI] ) - 1],cSeqLast )
	Next nI

	cSeqLast := Soma1( cSeqLast )

Return cSeqLast

//---------------------------------------------------------------------
/*/{Protheus.doc} MDT996VTF
Valid de combo que altera consulta F3 de funcionário que será relacionado
a resposta do Questionário.

@author André Felipe Joriatti
@since 07/06/2013
@return Boolean lRet: conforme validação.
@version MP11
/*/
//---------------------------------------------------------------------

Function MDT996VTF()   

	Local lRet       := .T.
	Local aConsultas := { "SRA","TMK","QAA" } // "1=Funcionário","2=SESMT","3=Outros"

	//Limpa o campo somente se for alterado o tipo de funcionário.
	If oFunc:cF3 <>  aConsultas[Val( M->TJ1_TPFUN )]
		oFunc:CTEXT:= SPACE(Len(TJ1_MAT))
	Endif
	
	If Val( M->TJ1_TPFUN ) >= 1 .And. Val( M->TJ1_TPFUN ) <= 3
		oFunc:cF3 := aConsultas[Val( M->TJ1_TPFUN )]
	EndIf   
	If Empty(oFunc:CTEXT)//Preenche o nome do Funcionário.
		cNomFun:="" 
	Endif

Return lRet

//---------------------------------------------------------------------
/*/{Protheus.doc} MDT996VTR
Valid de combo que altera consulta F3 de campo responsável que será relacionado 
a resposta do Questionário.

@author André Felipe Joriatti
@since 07/06/2013
@return Boolean lRet: conforme validação.
@version MP11
/*/
//---------------------------------------------------------------------

Function MDT996VTR()

	Local lRet       := .T.
	Local aConsultas := { "SRA","TMK","QAA" } // "1=Funcionário","2=SESMT","3=Outros"
	
	//Limpa o campo somente se for alterado o tipo de Responsavel.
	If oResp:cF3 <>  aConsultas[Val( M->TJ1_TPRES )]
		oResp:CTEXT:= SPACE(Len(TJ1_RESPEN))
	Endif
	
	If Val( M->TJ1_TPRES ) >= 1 .And. Val( M->TJ1_TPRES ) <= 3
		oResp:cF3 := aConsultas[Val( M->TJ1_TPRES )]
	EndIf
	 
	If Empty(oResp:CTEXT)//Preenche o nome do Rsponsavel.
		cNomResp:="" 
	Endif
	
Return lRet

//---------------------------------------------------------------------
/*/{Protheus.doc} fMDT996FUNC
valid do campo de funcionário e responsável relacionado as respostas 
do questionário.

@author André Felipe Joriatti
@since 07/06/2013
@return Boolean lRet: conforme validação.
@version MP11
/*/
//---------------------------------------------------------------------
 
Static Function fMDT996FUNC()

	Local nInd        := 0
	Local cAliasVer   := ""
	Local cCpo        := ""
	Local lRet        := .T.
	Local cChave      := ""
	Local cValorValid := ""
	Local cVarNome    := ""
	Local cCampo      := ""

	If ReadVar() == "M->TJ1_MAT"
		cValorValid := M->TJ1_TPFUN
		cChave      := M->TJ1_MAT
		cVarNome    := "cNomFun"
	ElseIf ReadVar() == "M->TJ1_RESPEN"
		cValorValid := M->TJ1_TPRES
		cChave      := M->TJ1_RESPEN
		cVarNome    := "cNomResp"
	EndIf

	If cValorValid == "1" // Funcionário
		nInd      := 1 // RA_FILIAL+RA_MAT
		cAliasVer := "SRA"
		cCpo      := "SRA->RA_NOME"
		cChave    := PadR( cChave,TAMSX3( "RA_MAT" )[1] )
	ElseIf cValorValid == "2" // SESMT
		nInd      := 1 // TMK_FILIAL+TMK_CODUSU
		cAliasVer := "TMK"
		cCpo      := "TMK->TMK_NOMUSU"
		cChave    := PadR( cChave,TAMSX3( "TMK_CODUSU" )[1] )
	ElseIf cValorValid == "3" // Outros
		nInd      := 1 // QAA_FILIAL+QAA_MAT
		cAliasVer := "QAA"
		cCpo      := "QAA->QAA_NOME"
		cChave    := PadR( cChave,TAMSX3( "QAA_MAT" )[1] )
	EndIf

	If Empty( cChave )
		&( cVarNome ) := Space( TAMSX3( SubStr( cCpo,6,( Len( cCpo ) - 5 ) ) )[1] )
		Return .T.
	EndIf

	lRet := NGIFDBSEEK( cAliasVer,cChave,nInd,.T. )

	If lRet
		&( cVarNome ) := NGSEEK( cAliasVer,cChave,nInd,cCpo )
	EndIf

Return lRet

//---------------------------------------------------------------------
/*/{Protheus.doc} fPnlBackClr
Função executada no ganho e perda de foco das panels das perguntas.

@param Int nPosPanel: indica qual a posição do panel no array de panels
@param Boolean lGotFocus: caso sim, esta sendo executado no GANHO de foco
@author André Felipe Joriatti
@since 11/06/2013
@return Nil: ever Nil
@version MP11
/*/
//---------------------------------------------------------------------

Static Function fPnlBackClr( nPosPanel,lGotFocus )

	If lGotFocus
		aPnlsPergs[nPosPanel][2]:nClrPane := CLR_BLACK
	Else
		aPnlsPergs[nPosPanel][2]:nClrPane := CLR_WHITE
	EndIf

Return Nil

//---------------------------------------------------------------------
/*/{Protheus.doc} 
Função utilizada para deletar a resposta.

@author Guilherme Benkendorf
@since 22/10/2014
@return Nil
@version MP11/12
/*/
//---------------------------------------------------------------------

Function MDTDelResp( cSequenRes )
	Local nX
	Local cAls
	Local nIdx
	Local aRelacQues := { { "TJ1" , "TJ1_FILIAL+TJ1_SEQRES" 								, "TJ1->TJ1_FILIAL+TJ1->TJ1_SEQRES" } ,;
									 { "TJ5" , "TJ5_FILIAL+TJ5_SEQRES+TJ5_QUEST+TJ5_PERG"	, "TJ5->TJ5_FILIAL+TJ5->TJ5_SEQRES" } }
	
	For nX := 1 To Len( aRelacQues )
		cAls  := aRelacQues[ nX , 1 ] //Alias
		nIdx  := NGRETORDEM( cAls , aRelacQues[ nX , 2 ] ) //Indice
		cWhile:= aRelacQues[ nX , 3 ]
		
		If AliasInDic( cAls ) .And. nIdx > 0 
		
			dbSelectArea( cAls )
			dbSetOrder( nIdx )	//TJ1_FILIAL+TJ1_SEQRES
			dbSeek( xFilial( cAls ) + cSequenRes )
			While !Eof() .And. &( cWhile ) == xFilial( cAls ) + cSequenRes
				
				RecLock( cAls , .F. )
					dbDelete()
				( cAls )->( MsUnLock() )
				
				( cAls )->( dbSkip() )
			End
		EndIf
	Next nX

Return Nil
