#Include "Protheus.ch"
#Include "RPTDEF.CH"
#Include "MNTR601.ch"
#Include "FWPrintSetup.ch"

#define DMPAPER_A4 9

//---------------------------------------------------------------------
/*/{Protheus.doc} MNTR601
Relatório de Código de barras de equipamentos/bens

Padrão impressão do código de barras:

	Etiqueta 99 * 38,1 mm
	Folha A4
	Marca: A4263 MaxPrint

@author André Felipe Joriatti
@since 05/07/2013
@return Nil: ever Nil
@version P11
/*/
//---------------------------------------------------------------------

Function MNTR601()

	Local aNGBEGINPRM := {}

	If FindFunction( 'MNTAmIIn' ) .And. !MNTAmIIn( 19, 95 )
		Return .F.
	EndIf

	aNGBEGINPRM := NGBEGINPRM()

	Private cPerg := "MNT601"

	//--------------------------------------
	// Criação das perguntas para o grupo:
	// MV_PAR01 De Família?
	// MV_PAR02 Até Família?
	// MV_PAR03 De Bem?
	// MV_PAR04 Até Bem?
	// MV_PAR05 Selecionar Vários?
	// MV_PAR06 Tipo de Código? 1=Barra; 2=QR Code
	//--------------------------------------

	If Pergunte( cPerg, .T. )
		RptStatus( { |lEnd| fRMNTR601() },STR0001 ) // "Imprimindo Relatório..."
	Endif

	NGRETURNPRM( aNGBEGINPRM )

Return Nil

//---------------------------------------------------------------------
/*/{Protheus.doc} fRMNTR601
Chamada do relatório

@author André Felipe Joriatti
@since 05/07/2013
@return Nil: ever Nil
@version P11
/*/
//---------------------------------------------------------------------
Static Function fRMNTR601()

	Local aDBF       := {}
	Local nCont      := 0

	Private cTRBImp  := GetNextAlias() // TRB com os dados a serem impressos
	Private oArqTrab := Nil
	Private cMarca   := GetMark()

	//-----------------------------------
	// Criação de arquivo de trabalho
	//-----------------------------------
	aAdd( aDBF,{ "T9_OK"     ,"C",02,0 } )
	aAdd( aDBF,{ "T9_CODBEM" ,"C",16,0 } )
	aAdd( aDBF,{ "T9_NOME"   ,"C",40,0 } )
	aAdd( aDBF,{ "T9_BARCODE","C",20,0 } )

	//Criação Tabela Temporária
	oArqTrab  := NGFwTmpTbl(cTRBImp, aDBF, {{"T9_CODBEM","T9_NOME" }})

	//---------------------------
	// Carrega TRB com os dados
	//---------------------------
	Processa( { |lEND| fLoadArq() },STR0002 ) // "Carregando arquivo de dados..."

	//-----------------------------------
	// Seleciona bens caso MV_PAR05 == 1
	//-----------------------------------
	fSelBem()

	// Verifica se existem registros marcados
	DbSelectArea( cTRBImp )
	DbGoTop()
	While !EoF()
		If ( cTRBImp )->T9_OK == cMarca
			nCont++
			Exit
		EndIf

		NGDBSELSKIP( cTRBImp )
	End While

	If nCont > 0 // verifica qtde de registros que foram selecionados

		If ValType(MV_PAR06) == 'N' .And. MV_PAR06 == 2
			// QR Code
			Processa( { |lEND| fQRCode() },STR0003 ) // "Imprimindo relatório..."
		Else
			// código de barras
			Processa( { |lEND| fBarCode() },STR0003 ) // "Imprimindo relatório..."
		EndIf

	Else
		MsgStop( STR0021 ) // "Não há dados para construir o relatório."
	EndIf

	// Deleta arquivo de trabalho
	DbSelectArea( cTRBImp )
	oArqTrab:Delete()

Return Nil

//---------------------------------------------------------------------
/*/{Protheus.doc} fLoadArq
Carrega arquivo de dados do relatório

@author André Felipe Joriatti
@since 05/07/2013
@return Nil: ever Nil
@version P11
/*/
//---------------------------------------------------------------------
Static Function fLoadArq()

	Local cTRBQuery := GetNextAlias()
	Local cMarcaPrm := ""

	// Caso usuario não tenha aberta a dialog de parametros
	If Type( "MV_PAR05" ) != "N"
		Pergunte( cPerg,.F. )
	EndIf

	cMarcaPrm := If( MV_PAR05 == 2,cMarca,"  " )

	// Consulta que seleciona bens conforme parametros
	BeginSql Alias cTRBQuery
		SELECT ST9.T9_CODBEM, ST9.T9_NOME, ST9.T9_BARCODE
			FROM %table:ST9%  ST9
			WHERE  ST9.T9_SITBEM = 'A'
				AND ST9.T9_CODFAMI BETWEEN %Exp:MV_PAR01% AND %Exp:MV_PAR02%
				AND ST9.T9_CODBEM  BETWEEN %Exp:MV_PAR03% AND %Exp:MV_PAR04%
				AND ST9.T9_FILIAL = %xFilial:ST9%
				AND ST9.%NotDel%
				AND ST9.T9_BARCODE <> ' '
			ORDER BY ST9.T9_FILIAL, ST9.T9_CODBEM
	EndSql

	While !( cTRBQuery )->( EoF() )

		//----------------------------
		// Adiciona registro no TRB
		//----------------------------
			RecLock( cTRBImp,.T. )
			( cTRBImp )->T9_OK      := cMarcaPrm
			( cTRBImp )->T9_CODBEM  := ( cTRBQuery )->T9_CODBEM
			( cTRBImp )->T9_NOME    := ( cTRBQuery )->T9_NOME
			( cTRBImp )->T9_BARCODE := ( cTRBQuery )->T9_BARCODE
			MsUnLock( cTRBImp )

		( cTRBQuery )->( DbSkip() )
	End While

	( cTRBQuery )->( DbCloseArea() )

	( cTRBImp )->( DbGoTop() )

Return Nil

//---------------------------------------------------------------------
/*/{Protheus.doc} fBarCode
Impressão do relatório com código de barras

@author André Felipe Joriatti
@since 05/07/2013
@return Nil: ever Nil
@version P11
/*/
//---------------------------------------------------------------------
Static Function fBarCode()

	Local nColText   := 0
	Local nLinhaCod  := 0
	Local nLinBarCde := 0
	Local nQtdeEtqta := 0
	Local oFontNm    := TFont():New()
	Local nBtmBox    := 0
	Local nRgtBox    := 0
	Local oPrinter

	Private nVezes   := 1
	Private nLin     := 100

	//--------------------------------
	// Criação do objeto do relatório
	//--------------------------------
	oPrinter := TMsPrinter():New( "MNTR601" + GetNextAlias(),,,,,,,,,,,, )
	oPrinter:Setup()
	oPrinter:SetPortrait()
	oPrinter:SetPaperSize( DMPAPER_A4 ) // Folha A4

	nColText := 60
	nRgtBox  := oPrinter:nHorzRes() - 60
	nTamLine := 60
	nLineBC := 0

	DbSelectArea( cTRBImp )
	( cTRBImp )->( DbSetOrder( 01 ) )
	( cTRBImp )->( DbGoTop() )

	While !EoF()

		If ( cTRBImp )->T9_OK != cMarca
			NGDBSELSKIP( cTRBImp )
			Loop
		EndIf

		If nQtdeEtqta == 0

			nLin       := 150
			nLineBC    := 0
			nVezes     := 1

			oPrinter:StartPage()
		EndIf

		nQtdeEtqta++

		nLinhaCod  := fRetLinha( 230 )
		nLinBarCde := fRetLinha( 50 )
		nBtmBox    := nLinhaCod + 280
		// nLineBC    += If( nQtdeEtqta == 1, 1.4, 2.5 - ((nVezes-1) * 0.0119)  )
		nLineBC += If( nQtdeEtqta == 1, 2.2, 2.5 - ( ( nVezes - 1 ) * 0.0119 ) )

		// Forma Box do equipamento em questao
		oPrinter:Line( nLinhaCod, nColText, nBtmBox  , nColText )  //Linha vertical
		oPrinter:Line( nLinhaCod, nColText, nLinhaCod, nRgtBox  )  //Linha vertical
		oPrinter:Line( nBtmBox  , nColText, nBtmBox  , nRgtBox  )  //Linha vertical
		oPrinter:Line( nBtmBox  , nRgtBox , nLinhaCod, nRgtBox  )  //Linha vertical

		oPrinter:Say( ( nLinhaCod + 13.5 ),( nColText + 15    ), AllTrim( ( cTRBImp )->T9_CODBEM ), oFontNm, , CLR_BLACK ) // Codigo do Equipamento
		oPrinter:Say( ( nLinhaCod + 13.5 ),( nColText + 615   ), ( cTRBImp )->T9_NOME, oFontNm, , CLR_BLACK ) // Descriação do Equipamento
		oPrinter:Say( ( nLinhaCod + 13.5 ),( nColText + 1730  ), AllTrim( ( cTRBImp )->T9_BARCODE ), , , CLR_BLACK )

		// Linhas centrais
		oPrinter:Line( nLinhaCod + nTamLine, nColText, nLinhaCod + nTamLine, nRgtBox  )
		oPrinter:Line( nLinhaCod, nColText + 600 , nLinhaCod + nTamLine, nColText + 600  )
		oPrinter:Line( nLinhaCod, nColText + 1690, nLinhaCod + nTamLine, nColText + 1690  )

		MsBar("CODE128", nLineBC, 1, AllTrim( ( cTRBImp )->T9_BARCODE ),oPrinter, .F., NIL, .T., 0.0600, 1.1, .F., , "CODE128", .F.)

		If nQtdeEtqta == 10
			nQtdeEtqta := 0
			oPrinter:EndPage()
		EndIf

		NGDBSELSKIP( cTRBImp )

	End While

	If nQtdeEtqta > 0
		oPrinter:EndPage()
	Endif

	oPrinter:Preview()

	FreeObj( oPrinter )
	oPrinter := Nil

Return Nil

//---------------------------------------------------------------------
/*/{Protheus.doc} fRetLinha
Retorna a próxima linha do relatório, incrementando 20 por default, ou
conforme definido no parametro

@param Integer nIncremento: *Opcional, define o incremento da posição horizontal
@author André Felipe Joriatti
@since 05/07/2013
@return Integer proxima posição para linha
@version P11
/*/
//---------------------------------------------------------------------

Static Function fRetLinha( nIncremento )

	Default nIncremento := 20

	nIncremento := If( nVezes == 1,0,nIncremento )
	nVezes++

Return ( nLin += nIncremento )

//---------------------------------------------------------------------
/*/{Protheus.doc} fSelBem
Gera dialog para marcar os bens que deseja imprimir caso MV_PAR05 == 1

@author André Felipe Joriatti
@since 05/07/2013
@return Nil: ever Nil
@version P11
/*/
//---------------------------------------------------------------------
Static Function fSelBem()

	Local aCamposMsSel := {}
	Local lInverte     := .F.
	Local lConfirm     := .F.
	Local oGrpBem      := Nil
	Local oGrpLbl      := Nil
	Local oPnlSel      := Nil

	If MV_PAR05 == 2 // Não seleciona vários
		Return Nil
	EndIf

	aAdd( aCamposMsSel,{ "T9_OK"     ,Nil," "	  } )
	aAdd( aCamposMsSel,{ "T9_CODBEM" ,Nil,STR0016 } ) // "Bem"
	aAdd( aCamposMsSel,{ "T9_NOME"   ,Nil,STR0017 } ) // "Nome Do Bem"
	aAdd( aCamposMsSel,{ "T9_BARCODE",Nil,STR0018 } ) // "Código de Barras"

	Define MsDialog oDlgCons Title OemToAnsi( STR0019 ) From 020,000 To 470,700 Of oMainWnd Pixel // "Bens"

		oDlgCons:lEscClose := .F.

		oPnlSel := TPanel():New(0,0,,oDlgCons,,,,,,0,0,.F.,.F.)
		oPnlSel:Align := CONTROL_ALIGN_ALLCLIENT

			oGrpLbl := TGroup():New( 010,004,030,348,,oPnlSel,CLR_BLUE,,.T., )

			@ 013,105 Say STR0020 COLOR CLR_HBLUE Of oGrpLbl Size 200,050 Pixel // "Selecione os Bens que deseja imprimir no relatório:"

			oGrpBem := TGroup():New( 035,004,200,348,,oPnlSel,CLR_BLUE,,.T., )

				oMarkQsts := MsSelect():New( cTRBImp,"T9_OK",,aCamposMsSel,@lInverte,@cMarca,{ 040,010,195,342 },,,oPnlSel,, )
				oMarkQsts:oBrowse:lHasMark    := .T.
				oMarkQsts:oBrowse:lCanallMark := .T.
				oMarkQsts:oBrowse:bAllMark    := { || InvMarca( cMarca,cTRBImp ) } // Função inverte marcadores

	Activate MsDialog oDlgCons On Init EnchoiceBar( oDlgCons, { || lConfirm := .T.,oDlgCons:End() },{ || lConfirm := .F.,oDlgCons:End() } ) Centered

Return Nil

//---------------------------------------------------------------------
/*/{Protheus.doc} InvMarca
Inverte a marcação das questões

@param String cMarca: Marcação
@param String cAliasTRB: Alias temporário
@author André Felipe Joriatti
@since 08/07/2013
@version P11
@return Boolean lRet: ever true
/*/
//---------------------------------------------------------------------

Static Function InvMarca( cMarca,cAliasTRB )

	Local lRet  := .T.
	Local aArea := GetArea()

	DbSelectArea( cAliasTRB )
	( cAliasTRB )->( DbGoTop() )
	While !( cAliasTRB )->( EoF() )
		( cAliasTRB )->T9_OK := If( Empty( ( cAliasTRB )->T9_OK ),cMarca," " )
		( cAliasTRB )->( DbSkip() )
	End While

	RestArea( aArea )

Return lRet

//---------------------------------------------------------------------
/*/{Protheus.doc} MNTR601VL
Valida perguntas do relatório.

@param Integer nParam: indica o número do parametro para validar.
@author André Felipe Joriatti
@since 08/07/2013
@version P11
@return Boolean lRet: conforme validação
/*/
//---------------------------------------------------------------------
Function MNTR601VL( nParam )

	Local lRet    := .T.
	Local cCodBem := ""
	Local lVrfBem := .T.

	Do Case
		Case nParam == 1 // De Família?
			lRet := If( Empty( MV_PAR01 ), .T., ExistCpo( "ST6",MV_PAR01 ) )
		Case nParam == 2 // Até Família?
			lRet := If( AteCodigo( "ST6", MV_PAR01, MV_PAR02,6 ), .T., .F. )
		Case nParam == 3 // De Bem?
			cCodBem := MV_PAR03
			lVrfBem := !Empty( cCodBem )
			lRet    := If( lVrfBem, ExistCpo( "ST9", cCodBem ), .T.)
		Case nParam == 4 // Até Bem?
			cCodBem := MV_PAR04
			lVrfBem := cCodBem <> Replicate( "Z", Len(ST9->T9_CODBEM) )
			lRet    := If( AteCodigo( "ST9", MV_PAR03, cCodBem, 16 ), .T., .F. )
		Case nParam == 5 // Selecionar Vários?
			lRet := !Empty( MV_PAR05 )
	EndCase

	If lRet .And. lVrfBem .And. ( nParam == 3 .Or. nParam == 4 )
		If !( lRet := NGSeek("ST9", cCodBem,1, "T9_SITBEM") == "A" )
			ShowHelpDlg( "Atenção",;
					   	{ "O bem está inativo."     }, 2,;
					   	{ "Selecione um bem ativo." }, 2 )
		Endif
	Endif

Return lRet

//---------------------------------------------------------------------
/*/{Protheus.doc} fQRCode
Impressão do relatório com QR Code

@author Maria Elisandra de Paula
@since 04/11/21
@return
/*/
//---------------------------------------------------------------------
Static Function fQRCode()

    Local oPrint := FWMSPrinter():New( 'MNTR601' )
	Local oFont1 := TFont():New()
    Local aBox   := {}
    Local aInf   := {}
    Local nInd   := 0
	Local nCount := 0
	Local nLineQ := 500
    Local nInc   := 460

    Local nCol1  := 200
    Local nCol2  := 900
    Local nCol3  := 1200
    Local nCol4  := 2200

    Local nLine1 := 100
    Local nLine2 := 250
    Local nLine3 := 400
    Local nLine4 := 550

    oPrint:SetPortrait() //Retrato
    oPrint:SetPaperSize(9)//A4
    If oPrint:nModalResult != PD_OK // se CANCELAR
		Return .F.
    EndIf

	DbSelectArea( cTRBImp )
	DbSetOrder( 01 )
	DbGoTop()

	oPrint:StartPage()

	While !Eof()

		If (cTRBImp)->T9_OK != cMarca

			DbSelectArea(cTRBImp)
			dbSkip()

			Loop
		EndIf

		If nCount == 6 // início de página 
			oPrint:EndPage()
			oPrint:StartPage()

			nLine1 := 100
			nLine2 := 250
			nLine3 := 400
			nLine4 := 550
			nLineQ := 500
			nCount := 0
		EndIf

		aBox:= {}
		aInf:= {}

		aAdd( aBox, { nLine1, nCol2, nLine2, nCol4 + 2 }) // código
		aAdd( aBox, { nLine1, nCol1, nLine4, nCol2 }) 	// qrcode
		aAdd( aBox, { nLine2, nCol2, nLine3, nCol4 + 2 }) // nome
		aAdd( aBox, { nLine3, nCol2, nLine4, nCol4 + 2 }) // code qr

		aAdd( aInf, { nLine1, nCol2, ( cTRBImp )->T9_CODBEM  , nCol3 }) 
		aAdd( aInf, { nLine2, nCol2, ( cTRBImp )->T9_NOME    , nCol3 })
		aAdd( aInf, { nLine3, nCol2, ( cTRBImp )->T9_BARCODE , nCol3}) 

		For nInd := 1 to Len( aBox ) // Imprime caixas
			oPrint:Box( aBox[nInd,1], aBox[nInd,2], aBox[nInd,3], aBox[nInd,4] )
		Next nInd

		For nInd := 1 to Len( aInf ) // imprime informações
			oPrint:SayAlign( aInf[nInd,1], aInf[nInd,2] + 20, aInf[nInd,3], oFont1, 1000, 150, , 0, 0 )							
		Next nInd

		oPrint:QrCode( nLineQ , nCol1 + 100, ( cTRBImp )->T9_BARCODE, 100 )

		nCount++
		nLine1 += nInc
		nLine2 += nInc
		nLine3 += nInc
		nLine4 += nInc
		nLineQ += nInc

		DbSelectArea( cTRBImp )
		DbSkip()

	End
	
    oPrint:Preview()
    FreeObj( oPrint )

Return 
