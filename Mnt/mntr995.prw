#INCLUDE "MNTR995.ch"
#INCLUDE "PROTHEUS.CH"

//----------------------------
//Posições da array aPNEUSINI
//----------------------------
Static __LOCALIZ__ := 1
Static __CODBEM__  := 2
Static __EIXO__    := 4

//---------------------------------------------------------------------
/*/{Protheus.doc} MNTR995
Relatório de  Guia de Calibração e Medição de Sulco

@author Vitor Emanuel Batista
@since 03/05/2011
@version MP10
@return Nil
/*/
//---------------------------------------------------------------------
Function MNTR995()
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Guarda conteudo e declara variaveis padroes ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	Local aNGBEGINPRM := NGBEGINPRM()

	Local aPerg := {}
	Local cPerg := "MNTR995"

	Private oPrint

	If Pergunte(cPerg,.T.)
		If !MNTR995BEM(MV_PAR01)
			MNTR995()
		Else
			Processa({ |lEnd| ImpRelatorio(MV_PAR01) },STR0003)   		 //"Aguarde... Processando dados"
			oPrint:Preview()
		EndIf
	EndIf
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Retorna conteudo de variaveis padroes       ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	NGRETURNPRM(aNGBEGINPRM)
Return

//---------------------------------------------------------------------
/*/{Protheus.doc} ImpRelatorio
Imprime relatório de Calibração e Medição

@author Vitor Emanuel Batista
@since 03/05/2011
@version MP10
@return Nil
/*/
//---------------------------------------------------------------------
Static Function ImpRelatorio(cBemPai)

	Private oFont1, oFont2, oFont3
	Private nHorzRes, nVertRes
	Private nCabecX, nTextY
	Private nAltura, nLargura
	Private nLin

	Private cCodBem995 := cBemPai
	Private cCodFami, cTipMod

	Private aPNEUSINI := {}

	oPrint  := TMSPrinter():New(STR0004) //"Guia de Calibração e Medição de Sulco"
		oPrint:SetlandScape()
		oPrint:Setup()

		//-------------------------------------------------
		// Valores totais de Altura e Largura da impressao
		//-------------------------------------------------
		nHorzRes := 3250 //oPrint:nHorzRes() - 50
		nVertRes := 4018 //oPrint:nVertRes() - 50

		//--------------------------------------------------
		// Altera tamanho do texto dependendo da impressora
		//--------------------------------------------------
		/*
		If nHorzRes > 4000 //CutePDF Writer / Microsoft XPS Document Writer
			oFont1   := TFont():New(,20,20,,.T.,,,,.T.,.F.)
			oFont2   := TFont():New(,14,14,,.T.,,,,.T.,.F.)
			oFont3   := TFont():New(,12,12,,.T.,,,,.T.,.F.)
			nMultImg := 5
			nCabecX  := 500
			nObservX := 0
			nTextY   := 20
		Else
		*/
			oFont1   := TFont():New(,16,16,,.T.,,,,.T.,.F.)
			oFont2   := TFont():New(,10,10,,.T.,,,,.T.,.F.)
			oFont3   := TFont():New(,08,08,,.T.,,,,.T.,.F.)
			nMultImg := 3
			nCabecX  := 0
			nTextY   := 0
			nObservX := 200
		//EndIf

		//-------------------------------------------------
		// Indica quantidade de itens da regua do PROCESSA
		//-------------------------------------------------
		ProcRegua(3)

		//----------------------------------
		// Imprime o cabeçalho do relatório
		//----------------------------------
		ImpHeader()

		//-----------------------------------------------
		// Imprime o centro do relatório com a estrutura
		//-----------------------------------------------
		ImpCenter()

		//--------------------------------
		// Imprime o rodapé do relatório
		//--------------------------------
		ImpFooter(1)

Return

//---------------------------------------------------------------------
/*/{Protheus.doc} ImpHeader
Imprime o cabeçalho do relatório

@author Vitor Emanuel Batista
@since 03/05/2011
@version MP10
@return Nil
/*/
//---------------------------------------------------------------------
Static Function ImpHeader()

	//-------------------------------------
	// Atualiza mensagem da regua PROCESSA
	//-------------------------------------
	IncProc(STR0005) //"Imprimindo cabeçalho."

	dbSelectArea("ST9")
	dbSetOrder(1)
	dbSeek(xFilial("ST9")+cCodBem995)
	cCodFami  := ST9->T9_CODFAMI
	cTipMod   := ST9->T9_TIPMOD

	oPrint:StartPage()
	oPrint:Say(15,20,STR0004,oFont1) //"Guia de Calibração e Medição de Sulco"
	oPrint:Say(25,nHorzRes,STR0033+DTOC(dDataBase) + STR0034 + SubStr(Time(),1,5),oFont2,,,,1) //"Emissão: "###" Hora: "
	oPrint:line(90,20,90,nHorzRes)

	//oPrint:Box(120,20,400,nHorzRes)
	oPrint:Box(120,20,400,1000+nCabecX)

	//Faz verificação de Código + Nome do bem para não truncar o relatório
	cCodNomBem := Alltrim(ST9->T9_CODBEM) + " - " + AllTrim(ST9->T9_NOME)
	oPrint:Say(140,40,STR0006 + SubStr(AllTrim(cCodNomBem),1,36),oFont2) //"Veículo.: "
	If Len(AllTrim(cCodNomBem)) > 36
		oPrint:Say(190,40,SubStr(AllTrim(cCodNomBem),39,59),oFont2) //"Veículo.: "
	EndIf

	oPrint:Say(240,40,STR0007 + AllTrim(ST9->T9_PLACA),oFont2) //"Placa....: "
	oPrint:Say(340,40,STR0008 + AllTrim(ST9->T9_TIPMOD) + " - " + AllTrim(NGSEEK("TQR",ST9->T9_TIPMOD,1,"TQR->TQR_DESMOD")),oFont2) //"Modelo.: "

	oPrint:Box(120,1010+nCabecX,400,2200+nCabecX*1.5 - nObservX)
	oPrint:Say(140,1030+nCabecX,STR0032+"............:          /         /                ",oFont2) //"Data"
	oPrint:Say(140,1080+nCabecX + ((2200+nCabecX*1.5 - nObservX) - (1010+nCabecX))/2,STR0009+"          :         ",oFont2) //"Hora:"
	oPrint:Say(240,1030+nCabecX,STR0010,oFont2) //"Contador....:"
	If NGIFDICIONA("TPE",xFilial("TPE")+cCodBem995,1)
		oPrint:Say(240,1080+nCabecX + ((2200+nCabecX*1.5 - nObservX) - (1010+nCabecX))/2,"Cont.2:",oFont2)
	EndIf
	oPrint:Say(340,1030+nCabecX,STR0011,oFont2) //"Executante.:"

	oPrint:Box(120,2210+nCabecX*1.5-nObservX,400,nHorzRes)
	oPrint:Say(140,2230+nCabecX*1.5-nObservX,STR0012,oFont2) //"Observações"

Return

//---------------------------------------------------------------------
/*/{Protheus.doc} ImpCenter
Imprime o centro do relatório com a imagem da estrutura

@author Vitor Emanuel Batista
@since 03/05/2011
@version MP10
@return Nil
/*/
//---------------------------------------------------------------------
Static Function ImpCenter()

	//-------------------------------------
	// Atualiza mensagem da regua PROCESSA
	//-------------------------------------
	IncProc(STR0013) //"Analisando estrutura"

	//---------------------------------------------------
	// Cria tPaintPanel com a estrutura atual do Bem Pai
	//---------------------------------------------------
	oTPanel := MNTA232IMP(cCodBem995,,.F.)
		nAltura  := oTPanel:nHeight
		nLargura := oTPanel:nWidth
		oTPanel:Hide()

	//---------------------------------------------------
	// Cria tPaintPanel com a estrutura atual do Bem Pai
	//---------------------------------------------------
	cImgEstru := GetTempPath()+StrTran(Time(),":","")
	oTPanel:SaveToPng(0,0,nLargura,nAltura,cImgEstru+".PNG")
		oTPanel:Free()

		While !File( cImgEstru+".png" )
			Sleep( 1000 )
		End While

		//---------------------------------------------------------
		// Exporta imagem para BMP para funcionar com o TMSPrinter
		//---------------------------------------------------------
		oBmp := TBitmap():New(0,0,0,0,,,.T.,,,,,.F.,,,,,.T.)
			oBmp:Hide()
			oBmp:Load(,cImgEstru+".PNG")

			oBmp:lStretch:= .T.
			oBmp:lTransparent := .T.
			oBmp:nHeight := nAltura*4
			oBmp:nWidth  := nLargura*4
			oBmp:nClrPane := CLR_WHITE
			oBmp:SaveAsBmp(cImgEstru+".BMP")
			oBmp:Free()

	//---------------------------------------
	// Adiciona imagem do esquema de rodados
	//---------------------------------------
	nLin := 480+nAltura*nMultImg
	oPrint:Say(415,20,STR0014,oFont2) //"Esquema de Rodados"
	oPrint:SayBitMap(480,(nHorzRes-nLargura)/2,cImgEstru+".BMP",nLargura*nMultImg,nAltura*nMultImg)
	oPrint:Box(475,20,nLin,nHorzRes)

Return

//---------------------------------------------------------------------
/*/{Protheus.doc} ImpFooter
Imprime o rodapé do relatório com informações da estrutura, calibragem,
medição e problema.

@param nPos Posição a ser impressa
@author Vitor Emanuel Batista
@since 03/05/2011
@version MP10
@return Nil
/*/
//---------------------------------------------------------------------
Static Function ImpFooter(nPos)
	Local nX

	Default nPos := 1

	//-------------------------------------
	// Atualiza mensagem da regua PROCESSA
	//-------------------------------------
	IncProc(STR0015) //"Imprimindo rodapé."

	//------------------------------
	// Monta cabeçalho da Estrutura
	//------------------------------
	nLargEstru := nHorzRes/4
	oPrint:Say(nLin+030,20 + (nLargEstru - 20)/2,STR0016,oFont2,,,,2) //"Estrutura"
	oPrint:Box(nLin+090,20,nLin+150,nLargEstru)
	oPrint:Say(nLin+100,40,STR0017,oFont3) //"Eixo"
	oPrint:Say(nLin+100,nLargEstru/7,STR0018,oFont3) //"Posição"
	oPrint:Say(nLin+100,nLargEstru/3,STR0019,oFont3) //"Código"
	oPrint:Say(nLin+100,nLargEstru/1.5,STR0020,oFont3) //"Modelo"

	//-------------------------------
	// Monta cabeçalho da Calibragem
	//-------------------------------
	oPrint:Say(nLin+030,nLargEstru+10 + (nHorzRes/2.22 - nLargEstru+10)/2,STR0021,oFont2,,,,2) //"Calibragem (BAR)"
	oPrint:Box(nLin+090,nLargEstru+10,nLin+150,nHorzRes/2.22)
	oPrint:Say(nLin+100,nHorzRes/3.85,STR0022,oFont3) //"Mínima"
	oPrint:Say(nLin+100,nHorzRes/3.33,STR0023,oFont3) //"Máxima"
	oPrint:Say(nLin+100,nHorzRes/2.85,STR0024,oFont3) //"Aferida"
	oPrint:Say(nLin+100,nHorzRes/2.50,STR0025,oFont3) //"Realizada"

	//-------------------------------------
	// Monta cabeçalho da Medição de Sulco
	//-------------------------------------
	oPrint:Say(nLin+030,nHorzRes/2.22 + 10 + (nHorzRes / 1.6 - nHorzRes/2.22 + 10)/2,STR0026,oFont2,,,,2) //"Medição de Sulco (MM)"
	oPrint:Box(nLin+090,nHorzRes/2.22 + 10,nLin+150,nHorzRes / 1.6)
	oPrint:Say(nLin+100,nHorzRes/2.10,"1º",oFont3)
	oPrint:Say(nLin+100,nHorzRes/1.88,"2º",oFont3)
	oPrint:Say(nLin+100,nHorzRes/1.70,"3º",oFont3)

	//------------------------------
	// Monta cabeçalho do Problema
	//------------------------------
	oPrint:Say(nLin+030,nHorzRes/1.6 + 15,STR0027,oFont2) //"Problema"
	oPrint:Box(nLin+090,nHorzRes/1.6 + 10,nLin+150,nHorzRes)
	oPrint:Say(nLin+100,nHorzRes/1.6 - 20 + (nHorzRes - nHorzRes/1.6)/2,STR0028,oFont3) //"Descrição"


	nBoxY := nLin+165
	nLin += 195 + nTextY
	For nX := nPos To Len(aPNEUSINI)

		If !Empty(aPNEUSINI[nX][__CODBEM__])
			dbSelectArea("ST9")
			dbSetOrder(1)
			dbSeek(xFilial("ST9")+aPNEUSINI[nX][__CODBEM__])
			cNoEix := NGSEEK('TQ1',cCodFami+cTipMod+Str(aPNEUSINI[nX][__EIXO__],3),1,'TQ1->TQ1_EIXO')
			If AllTrim(cNoEix) != "RESERVA"
				oPrint:Say(nLin,43,cValToChar(aPNEUSINI[nX][__EIXO__]),oFont3)
			EndIf
			oPrint:Say(nLin,nLargEstru/7,AllTrim(aPNEUSINI[nX][__LOCALIZ__]),oFont3)
			oPrint:Say(nLin,nLargEstru/3,AllTrim(aPNEUSINI[nX][__CODBEM__]),oFont3)
			oPrint:Say(nLin,nLargEstru/1.5,SubStr(NGSEEK("TQR",ST9->T9_TIPMOD,1,"TQR->TQR_DESMOD"),1,15),oFont3)

			//------------------------------------
			// Cria itens da tabela de Calibragem
			//------------------------------------
			dbSelectArea("TQS")
			dbSetOrder(1)
			dbSeek(xFilial("TQS")+ST9->T9_CODBEM)
			dbSelectArea("TQX")
			dbSetOrder(1)
			dbSeek(xFilial("TQX")+TQS->TQS_MEDIDA+ST9->T9_TIPMOD)

			oPrint:Say(nLin,nHorzRes/3.85 + 20,Transform(TQX->TQX_CALMIN,"@E 999"),oFont3)
			oPrint:Say(nLin,nHorzRes/3.33 + 20,Transform(TQX->TQX_CALMAX,"@E 999"),oFont3)
			oPrint:Say(nLin-10,nHorzRes/2.85 - 10,"________",oFont3)
			oPrint:Say(nLin-10,nHorzRes/2.50,"________",oFont3)

			//------------------------------------------
			// Cria itens da tabela de Medição de Sulco
			//------------------------------------------
			oPrint:Say(nLin-10,nHorzRes/2.10 - 55,"________",oFont3)
			oPrint:Say(nLin-10,nHorzRes/1.88 - 55,"________",oFont3)
			oPrint:Say(nLin-10,nHorzRes/1.70 - 55,"________",oFont3)

			//-----------------------------------
			// Cria itens da tabela de Problemas
			//-----------------------------------
			oPrint:Box(nLin-15,nHorzRes/1.6 + 25,nLin + 20,nHorzRes/1.6 + 55)
			oPrint:line(nLin+20,nHorzRes/1.6 + 80,nLin+20,nHorzRes-20)

			nLin += 60 + nTextY

			If nLin >= nVertRes-100
				Exit
			EndIf

		EndIf
	Next nX

	oPrint:Box(nBoxY,20,nLin-20,nLargEstru) //Box da Estrutura
	oPrint:Box(nBoxY,nLargEstru+10,nLin-20,nHorzRes/2.22) //Box da Calibragem
	oPrint:Box(nBoxY,nHorzRes/2.22 + 10,nLin-20,nHorzRes / 1.6) //Box da Medição de Sulco
	oPrint:Box(nBoxY,nHorzRes/1.6 + 10,nLin-20,nHorzRes) //Box do Problema

	If nX <= Len(aPNEUSINI)
		oPrint:EndPage()

		//----------------------------------
		// Imprime o cabeçalho do relatório
		//----------------------------------
		ImpHeader()

		//-----------------------------------------------
		// Imprime o centro do relatório com a estrutura
		//-----------------------------------------------
		ImpCenter()

		//-----------------------------------------------
		// Imprime o rodapé do relatório
		//-----------------------------------------------
		ImpFooter(nX+1)

	EndIf

Return

//---------------------------------------------------------------------
/*/{Protheus.doc} MNTR995BEM
Valida código do Bem, verificando se ele existe e possui estrutura no
modo gráfico.

@author Vitor Emanuel Batista
@since 16/05/2011
@version MP10
@return Nil
/*/
//---------------------------------------------------------------------
Function MNTR995BEM(cCodBem)

	If !ExistCpo('ST9',cCodBem,1)
		Return .F.
	EndIf

	If !MNTOPEN232(cCodBem)
		ShowHelpDlg(STR0029,	{STR0030},1,; //### //"ATENÇÃO"###"Não existe estrutura gráfica para o Esquema Padrão do Bem selecionado."
									{STR0031	},1) // //"Configure o Esquema padrão gráfico na rotina de Esquema Mod. 2 (MNTA221)."
		Return .F.
	EndIf

Return .T.
