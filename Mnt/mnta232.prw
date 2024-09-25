#INCLUDE "MNTA232.ch"
#INCLUDE "PROTHEUS.CH"
#INCLUDE "FWADAPTEREAI.CH" // Integração via Mensagem Única

//Variaveis estaticas com as posicoes da array aShape
Static __IDPNEU__    := 1
Static __CODPNEU__   := 2
Static __IMGX__      := 3
Static __IMGY__      := 4
Static __TYPE__      := 5
Static __ARRTXT__    := 6
Static __IDTXT__     := 1
Static __VIDA__      := 1
Static __ESTEPE__    := 2
Static __INVISIBLE__ := 3
Static __INFO__      := 7
Static __TOOLTIP__   := 8
Static __TXTVISIBLE__:= 9

//Variaveis estaticas com as posicoes das arrays aPNEUSINI aPNEUSFIM
Static __LOCALIZ__ := 1
Static __CODBEM__  := 2
Static __CODFAMI__ := 3
Static __EIXO__    := 4
Static __TIPEIXO__ := 5
Static __MEDIDA__  := 6
Static __SULCO__   := 7
Static __BANDA__   := 8
Static __DOT__     := 9
Static __STATUS__  := 10
Static __SEQREL__  := 11
Static __MOTIVO__  := 12
Static __CODESTO__ := 13
Static __LOCPAD__  := 14
Static __USUARIO__ := 15
Static __CCUSTO__  := 16
Static __CENTRAB__ := 17
Static __ITEMCTA__ := 26
Static __EMISSAO__ := 27

/*--------------------------------------------------------+
| Variáveis estáticas com as posições do array aPneuCont. |
+--------------------------------------------------------*/
Static __CDPNEU__  := 1
Static __DSCPNE__  := 2
Static __POSPNE__  := 3
Static __CONTPN__  := 4

//Usadas no MNTA231
Static __LIVRE__   := 18 // Opcao Livre
Static __LOCALAM__ := 19 // Almoxarifado
Static __NUMLOTE__ := 20 // Sub_lote
Static __LOTECTL__ := 21 // Lote
Static __NUMSERI__ := 22 // Numero da serie
Static __LOCALIF__ := 23 // Localizacao fisica
Static __DATAVAL__ := 24 // Data de validade
Static __CODEANT__ := 25 // Codigo do produto no estoque antigo

Static lRel12133 := GetRPORelease() >= '12.1.033'

//---------------------------------------------------------------------
//Main ;
/*/{Protheus.doc} MNTA232
Novo esquema de Rodados Grafico
@author Vitor Emanuel Batista
@since 02/06/2009
@version undefined
@param cOrdem, characters, Ordem de Servico
@param cPlano, characters, Plano da O.S.
@type function
/*/
//---------------------------------------------------------------------
Function MNTA232(cOrdem,cPlano)

	//Bloco de codigo para abrir a empresa 99
	Local cFuncBkp := FunName()
	Local lOpened  := .T.
	Local lTudOk   := .F.

	//+-------------------------------------------------------------------+
	//|Guarda conteudo e declara variaveis padroes 						  |
	//+-------------------------------------------------------------------+
	Local aNGBEGINPRM := NGBEGINPRM(,"MNTA232",{},.T.,.T.)

	//Objetos na tela
	Local oDlg, oPanelTot, oMenu
	Local oPnlBtn, oBtnVisual, oBtnHist
	Local oTCabecalho, oPnlInferior
	Local oTRodape, oPnlRodape
	Local oTCentro, oScrllCentro

	//Variaveis de caminhos para as imagens
	Local cBARRAS  	  := If(GetRemoteType() == 2,"/","\")

	//Variaveis de Largura/Altura da Janela
	Local aSize   := If(lOpened,MsAdvSize(,.F.,430),{0,0,0,0,(GetScreenRes()[1]-7),(GetScreenRes()[2]-85)})

	If !FindFunction( 'MNTAmIIn' ) .Or. MNTAmIIn( 19, 95 )

		SetFunName( 'MNTA232' )

		If !MNT232VERS()
			MsgInfo( STR0147  ) // 'Para utilizar a rotina é necessário atualizar o ambiente. Verifique o pacote de atualização referente ao ticket 6255067'
			Return .F.
		EndIf

		Private nLargura  := aSize[5]
		Private nAltura   := aSize[6]+If(PtGetTheme() = "MDI",120,0)

		//Variavel padrao com o diretoria das imagens
		Private cDirImg   := GetTempPath()+"rodados"+cBARRAS

		// Variável que indica se o sistema está utilizando mais Vidas de Pneus
		Private lMaisVidas := MNTA221Vds()

		//Seta INCLUI := .T.
		SetInclui()

		//Valida abertura do programa
		If !VldOpenRod(lOpened,cOrdem,cPlano)
			Return .F.
		EndIf

		//Variaveis do Cabecalho
		Private oDtMov
		Private lPai      := .F.
		Private lContPai  := .F.
		Private cBemPai   := ST9->T9_CODBEM
		Private cPaiEst   := "" //Quando cBemPai for filho, cPaiEst sera pai para atualizacao de contador
		Private cDescBem  := Trim(ST9->T9_CODBEM) + " - " + Trim(ST9->T9_NOME)
		Private cCodBem	  := ST9->T9_CODBEM
		Private cDesTipMod:= Trim(ST9->T9_TIPMOD) + " - " + Trim(NGSEEK("TQR",ST9->T9_TIPMOD,1,"TQR->TQR_DESMOD"))
		Private cTipMod   := ST9->T9_TIPMOD
		Private cDesCodFam:= Trim(ST9->T9_CODFAMI) + " - " + Trim(NGSEEK("ST6",ST9->T9_CODFAMI,1,"ST6->T6_NOME"))
		Private cCodFami  := ST9->T9_CODFAMI
		Private cNomBem   := ST9->T9_NOME
		Private cPlaca    := Trim(ST9->T9_PLACA)
		Private cLocal    := Trim(ST9->T9_UFEMPLA) + " - " + Trim(Substr(ST9->T9_CIDEMPL,1,15))
		Private cLocMerc  := ""
		Private cLocRuss  := ""
		Private cTamFont  := "7"
		Private dDTDATEM  := CtoD("  /  /  ")
		Private cHORALE1  := "  :  "
		Private cHORALE2  := "  :  "
		Private nPOSCONT  := 0
		Private nPOSCON2  := 0
		Private lTEMCONT  := fVerTpCont()
		Private lDtvSgCnt := NGCADICBASE("TPE_SITUAC","A","TPE",.F.) //Indica se permite desativar segundo contador
		Private lTEMCON2  := MNT2322CNT(xFilial("TPE"),lDtvSgCnt,cBemPai)
		Private lWHENCONT := lWHENCON2 := .T. //Utilizado por ponto de entrada

		//Variaveis de controle dos shapes
		Private nId       := 0
		Private aShape    := {}
		Private aAllShape := {}
		Private aRodizio  := {}

		//Localiza codigo da imagem na estrutura
		Private cCodImg     := ''
		Private aEstruturas := {}
		Private nPosEstru   := 1

		If lRel12133
			MNTSeekPad( 'TQ0', 1, cCodFami, cTipMod )
			cCodImg := Trim( TQ0->TQ0_CODEST )
		Else
			cCodImg := Trim(NGSEEK("TQ0",cCodFami+cTipMod,1,"TQ0->TQ0_CODEST"))
		EndIf

		aEstruturas :=	NGRETESTRU(cCodImg)

		//Variaveis do caminho das imagens
		Private cImgPlaca   := cDirImg+"NG_RODADOS_PLACA.PNG"
		Private cImgEstru   := cDirImg+"NG_ESTRUTURA_"+cCodImg+".PNG"
		Private cImgEstoque := cDirImg+"NG_RODADOS_ESTOQUE.PNG"
		Private cImgRecape  := cDirImg+"NG_RODADOS_RECAPE.PNG"
		Private cImgSucata  := cDirImg+"NG_RODADOS_SUCATA.PNG"
		Private cImgAnalise := cDirImg+"NG_RODADOS_ANALISE.PNG"
		//Mercosul - Mercado Comum do Sul
		Private cImgPlMerc  := lower(cDirImg+"ng_rodados_mercosul_placa.png")
		Private cImgBand    := cDirImg
		Private cLogMerc    := lower(cDirImg+"ng_rodados_logo_mercosul.png")
		Private cImgPlRuss  := lower(cDirImg + "ng_rodados_russia_placa.png")

		//Variavel de Shape em Foco
		Private nFocus  := Nil
		Private oTFocus := Nil

		//Variaveis dos Status - Rodape
		Private nIdEstoque, nIdRecape, nIdSucata, nIdAnalise

		//Parametros utlizados
		Private cNGRODIZ  := AllTrim(GetMv("MV_NGRODIZ")) //Servico de Rodizio
		Private cNGSERPN  := AllTrim(GetMv("MV_NGSERPN")) //Servico de Movimentacao
		Private cNGSERCA  := AllTrim(GetMv("MV_NGSERCA")) //Servico de Canibalismo
		Private cUsaIntEs := AllTrim(GetMV("MV_NGMNTES")) //Integracao com estoque
		Private cMotivPad := AllTrim(GetMv("MV_NGMOROD")) //Motivo para Rodizio
		Private cNGSTEP   := AllTrim(GetMv("MV_NGSTEP" ))  //Identifica se podera ser movimentado o Stepe
		Private cNGGERPR  := AllTrim(GETMv("MV_NGGERPR")) //Gera O.S preventivas automaticamente
		Private nNGDIFSU  := GetMv("MV_NGDIFSU") //Identifica a diferenca de sulco entre eixos
		Private cNGBEMTR  := AllTrim(GetMv("MV_NGBEMTR")) //Status de Bem Transferido
		Private cNGSTAPL  := AllTrim(GetMv("MV_NGSTAPL")) //Status de pneu Aplicado
		Private cNGSTACA  := AllTrim(GetMv("MV_NGSTACA")) //Status de Canibalismo
		Private cNGSTAAT  := AllTrim(GetMv("MV_NGSTAAT")) //Status de Analise Tecnica
		Private cNGSTARS  := AllTrim(GetMv("MV_NGSTARS")) //Status de Sulcata
		Private cNGSTAGR  := AllTrim(GetMv("MV_NGSTAGR")) //Status de Recape
		Private cNGSTAEU  := AllTrim(GetMv("MV_NGSTAEU")) //Status de Estoque Usado
		Private cNGSTAER  := AllTrim(GetMv("MV_NGSTAER")) //Status de Estoque Reformado
		Private cNGSTAEN  := AllTrim(GetMv("MV_NGSTAEN")) //Status de Estoque Novo
		Private cNGSTEST  := AllTrim(GetMv("MV_NGSTEST")) //Status de Estoque na Filial
		Private cNGSTAGC  := AllTrim(GetMv("MV_NGSTAGC")) //Status de Conserto

		//Variaveis do programa
		Private aPNEUSINI := {}
		Private aPNEUSFIM := {}
		Private aPneuCont := {}
		Private aPneusReq := {}
		Private aBEMLOC   := {}
		Private lRodzSXB  := AllTrim(STJ->TJ_SERVICO) == cNGRODIZ
		Private lRodizio  := AllTrim(STJ->TJ_SERVICO) == cNGRODIZ .And. AllTrim(STJ->TJ_SERVICO) != cNGSERPN
		Private lDisponi  := AllTrim(STJ->TJ_SERVICO) == cNGSERPN
		Private lCanibal  := AllTrim(STJ->TJ_SERVICO) == cNGSERCA
		Private lTZUser   := NGCADICBASE("TZ_USUARIO","D","STZ",.F.) //Campo que grava usuario da movimentacao
		Private lCATBEM   := NGCADICBASE('T9_CATBEM','A','ST9',.F.)
		Private lContEs   := NGCADICBASE('TQZ_ALMOX','A','TQZ',.F.) //Campos de histórico do status que controlam estoque
		Private cTZUser   := cUserName
		Private dDataOS   := STJ->TJ_DTMPINI, cHoraOS := If(AllTrim(STJ->TJ_HORACO1)==":",STJ->TJ_HOMPINI,STJ->TJ_HORACO1)
		Private dDataOR   := STJ->TJ_DTORIGI
		Private cHRTIME   := SubStr(Time(),1,5) //Hora do Sistema
		Private cHRTIME1M := MTOH(HTOM(cHRTIME)+1) //Hora do Sistema + 1 minuto para a troca de localizacao na estrutura
		Private cSemMov   := Alltrim(SubStr(Str(Year(dDTDATEM),4),3,2)+StrZero(NGSEMANANO(dDTDATEM),2)) //Validacao do DOT
		Private cNumOS    := STJ->TJ_ORDEM, cNumPL := STJ->TJ_PLANO
		Private cBem      := cBemPai
		Private cCALENB   := ST9->T9_CALENDA

		// NAO RETIRAR USADA NA CONSULTA NG1
		Private M->TP9_CCUSTO := Space(Len(ST9->T9_CCUSTO))

		//Variavel utilizada por pontos de entradas
		//sendo possivel aumentar a array para adicionar campos de usuario
		Private nTamTRB := 0

		//Variaveis de validacao do preenchimento do cabecalho
		Private lVldCabec := .F.
		Private bVldCabec	:= {|| If(!lVldCabec,ValidCabec(oTCabecalho),.T.) }

		//Titulo do oDlg
		Private cCadastro := STR0003 + STJ->TJ_ORDEM + " - " + Trim(NGSEEK('ST4',STJ->TJ_SERVICO ,1,'ST4->T4_NOME')) //"Esquema de Rodados:.. O.S. "

		//CRIA TABELAS TEMPORARIAS
		Private aTempTbl	:= MNTA231TRB()
		Private oTmpTbl1	:= aTempTbl[ 1 , 1 ]
		Private oTmpTbl2	:= aTempTbl[ 2 , 1 ]
		Private cTRBY 		:= aTempTbl[ 1 , 2 ]
		Private cTRBZ 		:= aTempTbl[ 2 , 2 ]
		Private cAliQryTQI  := GetNextAlias()

		//Define os Pneus a serem mostrados na consulta.
		MNT232ListP()

		//Verificação de data e país para utilização da nova placa do mercosul
		If CPAISLOC == "BRA" .And. dToS(DDATABASE) >= "20170101"
			cLocMerc := "BRASIL"
			cImgBand := lower(cImgBand + "ng_rodados_merc_band_bra.png")
		ElseIf CPAISLOC == "ARG" .And. dToS(DDATABASE) >= "20160101"
			cLocMerc := "REPUBLICA ARGENTINA"
			cImgBand := lower(cImgBand + "ng_rodados_merc_band_arg.png")
		ElseIf CPAISLOC == "PAR" .And. dToS(DDATABASE) >= "20160101"
			cLocMerc := "REPUBLICA DEL PARAGUAY"
			cImgBand := lower(cImgBand + "ng_rodados_merc_band_pry.png")
		ElseIf CPAISLOC == "VEN" .And. dToS(DDATABASE) >= "20160101"
			cLocMerc := "REPUBLICA BOLIVARIANA DE VENEZUELA"
			cImgBand := lower(cImgBand + "ng_rodados_merc_band_ven.png")
			cTamFont := "6"
		ElseIf CPAISLOC == "URU" .And. dToS(DDATABASE) >= "20160101"
			cLocMerc := "URUGUAY"
			cImgBand := lower(cImgBand + "ng_rodados_merc_band_ury.png")
		ElseIf CPAISLOC == "URS"
			cLocRuss := "RUS"
			cImgBand := lower(cImgBand + "ng_rodados_russia_band.png")
			cImgPlaca := lower(cDirImg + "ng_rodados_russia_placa.png")
		EndIf

		DEFINE MSDIALOG oDlg TITLE cCadastro FROM 120,0 TO nAltura,nLargura Of oMainWnd COLOR CLR_BLACK,CLR_BLACK Pixel
		oDlg:lEscClose := .F.

		//Cria Painel para adequação da tela.
		oPanelTot := TPanel():New(0,0,,oDlg,,,,,,0,0,.F.,.F.)
		oPanelTot:Align := CONTROL_ALIGN_ALLCLIENT

		//Variaveis de Altura e Largura
		nAltCabec  := 110
		nAltRodape := If(lRodizio,If(PtGetTheme() = "MDI",92,72),125)
		nLargScrll := nLargura*(1-(250*1)/nLargura) + If(PtGetTheme()= "MDI",5,0)//Calcula tamanho para o Centro
		nAltCentro := nAltura/2 - nAltRodape - nAltCabec  //(Total - Rodape - Cabecalho)

		oTCabecalho  := TPaintPanel():new(0,0,nLargura/2,nAltCabec/2,oPanelTot,.F.)
		oTCabecalho:Align := CONTROL_ALIGN_TOP

		nImgWidth  := Val(aEstruturas[nPosEstru][2])
		nImgHeight := Val(aEstruturas[nPosEstru][3])

		//Medidas da Estrutura
		nLargEstru := nImgWidth //Largura da Estrutura (Verificar Tamanho da imagem)
		nAltEstru  := nImgHeight //Altura da Estrutura (Verificar Tamanho da imagem)

		//Barra Lateral Esquerda - Botoes
		oPnlBtn := TPanel():New(0,0,,oPanelTot,,,,,RGB(67,70,87),13,0,.T.,.T.)
		oPnlBtn:Align := CONTROL_ALIGN_LEFT

		oBtnVisual  := TBtnBmp():NewBar("ng_ico_visualizar","ng_ico_visualizar",,,,{|| NGCADBEM()},,oPnlBtn)
		oBtnVisual:cToolTip :=STR0004 //"Visualizar Bem"
		oBtnVisual:Align    := CONTROL_ALIGN_TOP

		oBtnHist  := TBtnBmp():NewBar("ng_ico_historico","ng_ico_historico",,,,{|| MNTA080HCO(If(nFocus==Nil,cBemPai,aShape[nFocus][__CODPNEU__]))},,oPnlBtn)
		oBtnHist:cToolTip := STR0005 //"Histórico do Contador"
		oBtnHist:Align    := CONTROL_ALIGN_TOP

		oBtnImp  := TBtnBmp():NewBar("ng_ico_imp","ng_ico_imp",,,,{|| MNTA231IMT(cBemPai,Nil,Nil,cTipMod)},,oPnlBtn)
		oBtnImp:cToolTip := STR0006 //"Imprimir Estrutura Inicial"
		oBtnImp:Align    := CONTROL_ALIGN_TOP

		oBtnFim  := TBtnBmp():NewBar("ng_os_marcada","ng_os_marcada",,,,{|| FinalizaOS(oDlg)},,oPnlBtn)
		oBtnFim:cToolTip := STR0007 //"Finalizar O.S"
		oBtnFim:Align    := CONTROL_ALIGN_TOP

		/*IMPLEMENTACAO FUTURA
		oBtnFer  := TBtnBmp():NewBar("ng_ico_ferram","ng_ico_ferram",,,,{||},,oPnlBtn,,{||.T.},,,,,,)
		oBtnFer:cToolTip := "Ferramentas"
		oBtnFer:Align    := CONTROL_ALIGN_TOP
		*/

		//Panel da Estrutura e do Rodape
		oPnlInferior  := TPanel():New(0,0,,oPanelTot,,,,CLR_WHITE,,nLargScrll/2,nAltCentro,.F.,.F.)
		oPnlInferior:Align := CONTROL_ALIGN_LEFT

		oScrllCentro  := TScrollBox():New(oPnlInferior,72,12,nAltCentro,nLargScrll/2,.T.,.T.,.F.)
		oScrllCentro:Align := CONTROL_ALIGN_TOP
		oTCentro           := TPaintPanel():new(0,0,If(nLargScrll/2 > nLargEstru/2, nLargScrll/2,nLargEstru/2),;
		If(nAltCentro > nAltEstru/2,nAltCentro,nAltEstru/2) ,oScrllCentro,.F.)
		//Se o tamanho da estrutura for menor que o centro(ScrollBox)
		If nLargEstru/2 < nLargScrll/2 .And. nAltEstru/2 < nAltCentro
			oTCentro:Align     := CONTROL_ALIGN_ALLCLIENT
		Else
			//oTCentro:Align     := CONTROL_ALIGN_TOP
		EndIf

		//Rodape
		oPnlRodape  := TPanel():New(0,0,,oPnlInferior,,,,CLR_WHITE,,nLargScrll/2,nAltRodape,.F.,.F.)
		oPnlRodape:Align := CONTROL_ALIGN_TOP
		oTRodape         := TPaintPanel():new(0,0,nLargScrll/2,100,oPnlRodape,.F.)
		oTRodape:Align   := CONTROL_ALIGN_ALLCLIENT

		//Barra Lateral Direita
		oPnlRodizio := TPanel():New(70,500,,oPanelTot,,,,,CLR_WHITE,(nLargura - nLargScrll)/2,nAltCentro+nAltRodape,.F.,.F.)
		oPnlRodizio:Align  := CONTROL_ALIGN_ALLCLIENT
		oTRodizio          := TPaintPanel():new(0,0,10,10,oPnlRodizio,.T.)
		oTRodizio:Align    := CONTROL_ALIGN_ALLCLIENT

		//+-------------------------------------------------------------------+
		//|Cria Rodape   													  |
		//+-------------------------------------------------------------------+
		CriaCabecalho(@oTCabecalho,nAltCabec,nLargura+ If(PtGetTheme()= "MDI",5,0))

		//+-------------------------------------------------------------------+
		//|Cria Centro   													  |
		//+-------------------------------------------------------------------+
		CriaCentro(@oTCentro,nAltCentro,nLargScrll)

		//+-------------------------------------------------------------------+
		//|Cria Rodizio  													  |
		//+-------------------------------------------------------------------+
		CriaRodizio(@oTRodizio,nLargura - nLargScrll - oTRodizio:nWidth)

		//+-------------------------------------------------------------------+
		//|Cria Rodape   													  |
		//+-------------------------------------------------------------------+
		CriaRodape(@oTRodape,nLargScrll,nAltRodape*2)

		//+-------------------------------------------------------------------+
		//|Monta os Eventos do Click no shape								  |
		//+-------------------------------------------------------------------+
		RodPopUp(@oMenu)

		//Eventos do TPaintPanel Central (Estrutura/Pneus)
		oTCentro:blClicked   := {|x,y| DblClick(x,y,@oTCentro)}
		oTCentro:bRClicked   := {|x,y| RClick(x,y,oMenu,@oTCentro) }  //Botao direito
		oTCentro:bLDblClick  := {|x,y| DblClick(x,y,@oTCentro)}    //Duplo clique

		//Eventos do TPaintPanel Lateral (Rodizio/Pneus)
		oTRodizio:blClicked  := {|x,y|  DblClick(x,y,@oTRodizio,.T.,.T.)}
		oTRodizio:bLDblClick := {|x,y| DblClick(x,y,@oTRodizio,.T.,.T.)}
		oTRodizio:bRClicked  := {|x,y| RClick(x,y,oMenu,@oTRodizio) }

		//Eventos do TPaintPanel Inferior (Rodape)
		oTRodape:blClicked   := {|x,y| ClickRodape(x,y,@oTRodape)}
		oTRodape:blClicked   := {|x,y| ClickRodape(x,y,@oTRodape)}
		oTRodape:bLDblClick  := {|x,y| ClickRodape(x,y,@oTRodape)}

		//Seta no campo de Data Movimentacao
		oDtMov:SetFocus()

		ACTIVATE MSDIALOG oDlg ON INIT EnchoiceBar( @oDlg, { || lTudOk := fVldCmmt2( @oDlg ) }, { || nopcmo := 1, oDlg:End() } )

		If lTudOk
			MsgRun( STR0011 , STR0002 , { || MNTA232RET(@cTRBY,@cTRBZ) })		 //"Aguarde"##"Processando informações..."
			NGDETRAVAROT("MNTA232FIM")
			NGDETRAVAROT("MNTA232RET")
		EndIf

		(cAliQryTQI)->(DbCloseArea())

		SetFunName( cFuncBkp )

		FWFreeArray( aPneuCont )

	EndIf

	//Retorna conteudo de variaveis padroes
	NGRETURNPRM(aNGBEGINPRM)

Return

//---------------------------------------------------------------------
/*/{Protheus.doc} fVldCmmt2
Validação final para o processo de movimentação de pneus.
@type function

@author Alexandre Santos
@since 04/07/2023

@param oDlg     , object, Objeto da tela de movimentação de pneus.

@return boolean , Indica se os movimentos estão validado.
/*/
//---------------------------------------------------------------------
Static Function fVldCmmt2( oDlg )

	Local lOk := .F.

	/*----------------------------------------------------------------+
	| Informe e Valid. dos contadores proprios relacionado aos pneus. |
	+----------------------------------------------------------------*/
	If fContPneus()

		/*------------------------------------------------------------+
		| Valid. final da movimentação e contadores do pai da estrut. |
		+------------------------------------------------------------*/
		If ( lOk := MNT232FIT() )

			oDlg:End()

		EndIf

	EndIf
	
Return lOk

//---------------------------------------------------------------------
/*/{Protheus.doc} MNT232FIT
Travamento de acesso e validacao final
@author Inacio Luiz Kolling
@since 10/10/2010
@version undefined
@type function
/*/
//---------------------------------------------------------------------
Function MNT232FIT()
	Local lRetT,lTravF,lTravR
	Store .F. To lRetT,lTravF,lTravR

	If NGTRAVAROT("MNTA232FIM")
		lTravF := .T.
		If NGTRAVAROT("MNTA232RET")
			lTravR := .T.
			lRetT := MNTA232FIM()
		EndIf
	EndIf
	If !lRetT .And. (lTravF .Or. lTravR)
		If lTravF
			NGDETRAVAROT("MNTA232FIM")
		EndIf
		If lTravR
			NGDETRAVAROT("MNTA232RET")
		EndIf
	EndIf

Return lRetT

//---------------------------------------------------------------------
/*/{Protheus.doc} NGCADBEM
Abre cadastro de Bens para visualizacao
@author Vitor Emanuel Batista
@since 09/06/2009
@version undefined
@type function
/*/
//---------------------------------------------------------------------
Static Function NGCADBEM()

	If nFocus == Nil
		cBem := cBemPai
	Else
		cBem := aShape[nFocus][__CODPNEU__]
	EndIf

	dbSelectArea("ST9")
	dbSetOrder(1)
	If dbSeek(xFilial("ST9")+cBem)
		MNTA080CAD( 'ST9' , ST9->( Recno() ) , 2 )
	Else
		Help(" ",1,"REGNOIS")
		Return .F.
	EndIf

Return .T.

//-------------------------------------------------------------------------------
/*/{Protheus.doc} ValidCabec
Valida campos do cabecalho.

@author Vitor Emanuel Batista
@since 17/08/2009

@sample ValidCabec(oPanel)

@param  oPanel   , Objeto, Objeto que contem os Gets do cabecalho
@return lVldCabec, Lógico, Verifica se é valido.
/*/
//-------------------------------------------------------------------------------
Static Function ValidCabec(oPanel)

	Local nX    := 0
	Local lRet  := .T.
	Local aArea := GetArea()

	For nX := 1 to Len(oPanel:oParent:oParent:aControls)
		If GetClassName(oPanel:oParent:oParent:aControls[nX]) == "TGET" .And. !Empty(oPanel:oParent:oParent:aControls[nX]:bValid)
			lRet := Eval(oPanel:oParent:oParent:aControls[nX]:bValid)
			If ValType(lRet) != "L"
				lRet := .T.
			EndIf
			If !lRet
				Exit
			EndIf
		EndIf
	Next nX

	RestArea(aArea)

Return lVldCabec := lRet

//---------------------------------------------------------------------
/*/{Protheus.doc} DblClick
Funcao chamada ao dar um duplo clique na Estrutura
@author Vitor Emanuel Batista
@since 09/06/2009
@version undefined
@param x, , Posicao X do clique
@param y, , Posicao Y do clique
@param oPanel, object, Objeto TPaintPanel
@param lTrocaPneu, logical, Se outro pneu estiver em Foco sera trocado
@param lAreaTrans, logical, Se o duplo clique foi chamado na Area de Transf.
@type function
/*/
//---------------------------------------------------------------------
Static Function DblClick(x,y,oPanel,lTrocaPneu,lAreaTrans)

	Local nShape     := 0
	Local nInvisible := 0
	Local nTempPos   := 0

	Default lTrocaPneu := .T.
	Default lAreaTrans := .F.

	//Valida campos do cabecalho
	If !Eval(bVldCabec)
		Return .F.
	EndIf

	//Clicou na Imagem Pneu
	nShape := aSCAN(aShape,{|x| (x[__IDPNEU__] == oPanel:ShapeAtu) .And. !aTail(X)[__INVISIBLE__]})
	If nShape == 0
		//Clicou no Texto do codigo so pneu
		nShape := aSCAN(aShape,{|x| (x[__ARRTXT__][__IDTXT__] == oPanel:ShapeAtu) .And. !aTail(X)[__INVISIBLE__]})

		//Verifica se shape eh o invisivel
		If nShape == 0
			//Clicou na Imagem Pneu
			nInvisible := aSCAN(aShape,{|x| (x[__IDPNEU__] == oPanel:ShapeAtu) })
			If nInvisible == 0
				//Clicou no Texto do codigo so pneu
				nInvisible := aSCAN(aShape,{|x| (x[__ARRTXT__][__IDTXT__] == oPanel:ShapeAtu)})
			EndIf
		EndIf
	EndIf

	//Se encontrou o shape
	If nShape > 0

		//Se nao existe outro pneu focado
		If nFocus == Nil
			NGClickPneu(@oPanel,nShape,.T.)
			nFocus  := Len(aShape)
			oTFocus := @oPanel
		Else
			//Se o pneu clicado for o mesmo que o setado, somente sera desabilitado o focus
			If nShape == nFocus
				NGClickPneu(@oPanel,nFocus,.F.)
				nFocus  := Nil
				oTFocus := Nil
			Else
				//Se for Stepe e estiver em Rodizio, nao sera permitida a movimentacao
				If lTrocaPneu
					If cNGSTEP == "N" .And. lRodizio .And. (aTail(aShape[nShape])[__ESTEPE__] .Or. If(nFocus == Nil, .F.,aTail(aShape[nFocus])[__ESTEPE__]))
						MsgStop(STR0012,STR0009) //"Segundo configurações, não será permitido movimentar Stepes quando o serviço for de Rodízio."##"Atenção"
						Return .F.
					EndIf
				EndIf

				//Senao ira desabilitar o setado e habilitar o clicado
				If !lTrocaPneu
					NGClickPneu(@oTFocus,nFocus,.F.)
					NGClickPneu(@oPanel,nShape,.T.)
					nFocus  := Len(aShape)
					oTFocus := @oPanel
				Else
					If DLGPNEU(0,nFocus,nShape) .And. TrocaPneu(nFocus,oTFocus,nShape,oPanel)
						nFocus  := Nil
						oTFocus := Nil
					EndIf
				EndIf
			EndIf
		EndIf
	Else
		//Se nao encontrou mas ja ha um pneu focado para desabilita-lo
		If nFocus != Nil

			//Se for Stepe e estiver em Rodizio, nao sera permitida a movimentacao
			If lTrocaPneu
				If cNGSTEP == "N" .And. lRodizio .And. aTail(aShape[nFocus])[__ESTEPE__]
					MsgStop(STR0012,STR0009) //"Segundo configurações, não será permitido movimentar Stepes quando o serviço for de Rodízio."#"Atenção"
					Return .F.
				EndIf
			EndIf

			//Se nao foi clicado no Panel do Rodizio
			If !lAreaTrans
				If nInvisible == 0
					NGClickPneu(@oTFocus,nFocus,.F.)
					nFocus  := Nil
					oTFocus := Nil
				Else

					If DLGPNEU(0,nFocus,nInvisible) .And. TrocaPneu(nFocus,oTFocus,nInvisible,oPanel)
						nFocus  := Nil
						oTFocus := Nil
					EndIf

				EndIf

			Else
				//Se o Pneu focado ja nao esta em Rodizio
				If aSCAN(aRodizio,{|aArray| aArray[1] == aShape[nFocus][__CODPNEU__] }) == 0
					If DLGPNEU(0,nFocus,,.T.)
						nTempPos  := aSCAN(aPNEUSFIM,{|aArray| aArray[__CODBEM__] == aShape[nFocus][__CODPNEU__]})

						//Localiza a primeira posicao vazia no aRodizio
						nRodPos := aSCAN(aRodizio,{|aArray| Empty(aArray[1]) })
						SetPosition(oTFocus,nFocus,oPanel,aRodizio[nRodPos][2],aRodizio[nRodPos][3])
						aRodizio[nRodPos][1] := aTail(aShape)[__CODPNEU__]
						aRodizio[nRodPos][4] := aClone(aPNEUSFIM[nTempPos])
						aRodizio[nRodPos][4][__LOCALIZ__] := aTail(aShape)[7][2]
						aRodizio[nRodPos][4][__LOCALIZ__] := STR0013 //"Área de Transferência"
						aPNEUSFIM[nTempPos][__CODBEM__] := Space(Len(aPNEUSFIM[nTempPos][__CODBEM__]))
						aPNEUSFIM[nTempPos][__MOTIVO__] := Space(Len(aPNEUSFIM[nTempPos][__MOTIVO__]))
						aPNEUSFIM[nTempPos][__SULCO__]  := 0
						aTail(aShape)[7][2] := STR0013//"Área de Transferência"
						nFocus  := Nil
						oTFocus := Nil
					EndIf
				Else
					NGClickPneu(@oTFocus,nFocus,.F.)
					nFocus  := Nil
					oTFocus := Nil
				EndIf
			EndIf
		Else
			//Abre consulta F3 para adicionar pneu
			If nInvisible > 0
				EntraPneu(oPanel,nInvisible)
			EndIf
		Endif
	EndIf

Return

//---------------------------------------------------------------------
/*/{Protheus.doc} SetPosition
Troca a posicao do shape no mesmo TPaintPanel ou em outro
@author Vitor Emanuel Batista
@since 06/08/2009
@version undefined
@param oPnlOrig, object, Objeto TPaintPanel do pneu de origem
@param nShape, numeric, Posicao na array aShape do pneu
@param oPnlDest, object, Objeto TPaintPanel do pneu de destino
@param nPosX, numeric, Posicao X que pneu ficara no novo TPaintPanel
@param nPosY, numeric, Posicao Y que pneu ficara no novo TPaintPanel
@type function
/*/
//---------------------------------------------------------------------
Static Function SetPosition(oPnlOrig,nShape,oPnlDest,nPosX,nPosY)

	Local cCodPneu   := aShape[nShape][__CODPNEU__]
	Local aInfo      := aClone(aShape[nShape][__INFO__])
	Local cToolTip   := aShape[nShape][__TOOLTIP__]
	//Local cType      := aShape[nShape][__TYPE__]
	Local nVida      := aTail(aShape[nShape])[__VIDA__]
	Local lStepe     := .F.
	Local lClick     := .F.
	Local lInvisible := .F.

	NGClickPneu(@oPnlOrig,nShape,lClick,!lInvisible)
	NGCriaPneu(@oPnlDest,nPosX,nPosY,"1",cCodPneu,nVida,lStepe,lClick,lInvisible,aInfo,cToolTip)
Return

//---------------------------------------------------------------------
/*/{Protheus.doc} TrocaPneu
Faz a troca entre dois pneus na estrutura
@author Vitor Emanuel Batista
@since 26/06/2009
@version undefined
@param nOrigem, numeric,  Posicao na array aShape do pneu de Origem
@param oPnlOrig, object,  Objeto TPaintPanel do pneu de origem
@param nDestino, numeric, Posicao na array aShape do pneu de Destino
@param oPnlDest, object,  Objeto TPaintPanel do pneu de destino
@type function
/*/
//---------------------------------------------------------------------
Static Function TrocaPneu(nOrigem,oPnlOrig,nDestino,oPnlDest)
	Local nRodPos1, nRodPos2
	Local nIdPneuOri := aShape[nOrigem][__IDPNEU__]
	Local nIdPneuDes := aShape[nDestino][__IDPNEU__]

	//Array contendo informacoes adicionario sobre o penu
	Local aInfoOri   := aClone(aShape[nOrigem][__INFO__])
	Local aInfoDes   := aClone(aShape[nDestino][__INFO__])

	//Codigo do Pneu
	Local cCodPneuOri := aShape[nOrigem][__CODPNEU__]
	Local cCodPneuDes := aShape[nDestino][__CODPNEU__]

	//Posicao X e Y do pneu de origem
	Local nImgXOri := aShape[nOrigem][__IMGX__]
	Local nImgYOri := aShape[nOrigem][__IMGY__]

	//Posicao X e Y do pneu de destino
	Local nImgXDes := aShape[nDestino][__IMGX__]
	Local nImgYDes := aShape[nDestino][__IMGY__]

	//Id do shape do Txt dos Pneus
	Local nIdTxtOri := aShape[nOrigem][__ARRTXT__][__IDTXT__]
	Local nIdTxtDes := aShape[nDestino][__ARRTXT__][__IDTXT__]

	//Vida dos Pneus
	Local nVidaOri := aTail(aShape[nOrigem])[__VIDA__]
	Local nVidaDes := aTail(aShape[nDestino])[__VIDA__]

	//Se os pneus sao Estepe ou nao
	Local lEstepeOri := aTail(aShape[nOrigem])[__ESTEPE__]
	Local lEstepeDes := aTail(aShape[nDestino])[__ESTEPE__]

	//Se o pneu de destino esta invisivel
	Local lInvisible := aTail(aShape[nDestino])[__INVISIBLE__]

	Local cToolTipOri   := aShape[nOrigem][__TOOLTIP__]
	Local cToolTipDes   := aShape[nDestino][__TOOLTIP__]

	//Codigo do tipo do pneu
	Local cTypeOri      := aShape[nOrigem][__TYPE__]
	Local cTypeDes      := aShape[nDestino][__TYPE__]

	//Faz a troca dos pneus se eles estiverem em Rodizio
	nRodPos1 := aSCAN(aRodizio,{|aArray| aArray[1] == cCodPneuOri })
	nRodPos2 := aSCAN(aRodizio,{|aArray| aArray[1] == cCodPneuDes })
	If nRodPos1 > 0
		aRodizio[nRodPos1][1] := cCodPneuDes
	EndIf
	If nRodPos2 > 0
		aRodizio[nRodPos2][1] := cCodPneuOri
	EndIf

	//Se o pneu de destino estiver invisivel, Pneu Origem fica invisivel e Pneu Destino fica ativo
	If lInvisible
		NGClickPneu(@oPnlOrig,nOrigem,.F.,.T.)
		NGCriaPneu(@oPnlDest,nImgXDes,nImgYDes,cTypeDes,cCodPneuOri,nVidaOri,lEstepeDes,.F.,.F.,aInfoDes,cToolTipOri)

		aDel( aShape, nDestino )
		aSize( aShape, Len( aShape ) - 1 )

		oPnlDest:DeleteItem(nIdPneuDes)
		oPnlDest:DeleteItem(nIdTxtDes)
	Else
		aDel( aShape, nDestino )
		aDel( aShape, nOrigem )
		aSize( aShape, Len( aShape ) - 2 )

		oPnlDest:DeleteItem(nIdPneuDes)
		oPnlDest:DeleteItem(nIdTxtDes)

		oPnlOrig:DeleteItem(nIdPneuOri)
		oPnlOrig:DeleteItem(nIdTxtOri)

		NGCriaPneu(@oPnlOrig,nImgXOri,nImgYOri,cTypeOri,cCodPneuDes,nVidaDes,lEstepeOri,.F.,.F.,aInfoDes,cToolTipDes)
		NGCriaPneu(@oPnlDest,nImgXDes,nImgYDes,cTypeDes,cCodPneuOri,nVidaOri,lEstepeDes,.F.,.F.,aInfoOri,cToolTipOri)
	EndIf

Return .T.

//---------------------------------------------------------------------
/*/{Protheus.doc} NGClickPneu
Funcao chamada ao dar um duplo clique sobre um pneu
@author Vitor Emanuel Batista
@since 02/06/2009
@version undefined
@param oPanel, object,  Objeto TPaintPanel
@param nShape, numeric, Posicao na array aShape do pneu
@param lMarca, logical, Indica se pneu estara marcado (mais claro)
@param lInvisible, logical, Indica se pneu devera ficar invisivel
@type function
/*/
//---------------------------------------------------------------------
Function NGClickPneu(oPanel,nShape,lMarca,lInvisible)

	Local nIdPneu  := aShape[nShape][__IDPNEU__]
	Local cCodPneu := aShape[nShape][__CODPNEU__]
	Local nImgX    := aShape[nShape][__IMGX__]
	Local nImgY    := aShape[nShape][__IMGY__]
	Local nIdTxt   := aShape[nShape][__ARRTXT__][__IDTXT__]
	Local nVida    := aTail(aShape[nShape])[__VIDA__]
	Local lEstepe  := aTail(aShape[nShape])[__ESTEPE__]
	Local aInfo    := aClone(aShape[nShape][__INFO__])
	Local cToolTip := aShape[nShape][__TOOLTIP__]
	Local cType    := aShape[nShape][__TYPE__]
	Local lVisibleText := aShape[nShape][__TXTVISIBLE__]
	Local nPosRod

	Default lMarca := .T.
	Default lInvisible := .F.

	cToolTip := If(!lInvisible,cToolTip,"")
	aDel( aShape, nShape )
	aSize( aShape, Len( aShape ) - 1 )

	oPanel:DeleteItem(nIdPneu)
	oPanel:DeleteItem(nIdTxt)

	NGCriaPneu(@oPanel,nImgX,nImgY,cType,cCodPneu,nVida,lEstepe,lMarca,lInvisible,aInfo,cToolTip,lVisibleText)

	If lInvisible .And. Type("aRodizio") == "A"
		nPosRod := aSCAN(aRodizio,{|aArray| aArray[1] == cCodPneu })
		If nPosRod > 0
			aRodizio[nPosRod][1] := ""
		EndIf
	EndIf

Return

//---------------------------------------------------------------------
/*/{Protheus.doc} RClick
Funcao chamada ao dar um clique da direita sobre pneu
@author Vitor Emanuel Batista
@since 02/06/2009
@version undefined
@param x, , Posicao X do clique
@param y, , Posicao Y do clique
@param oMenu, object,  Objeto TMenu
@param oPanel, object, Objeto TPaintPanel
@type function
/*/
//---------------------------------------------------------------------
Static Function RClick(x,y,oMenu,oPanel)

	Local nShape
	Local lTrocaPneu := .F.

	//Valida campos do cabecalho
	If !Eval(bVldCabec)
		Return .F.
	EndIf

	//Clicou no Pneu
	nShape := aSCAN(aShape,{|x| (x[__IDPNEU__] == oPanel:ShapeAtu) .And. !aTail(X)[__INVISIBLE__] })
	If nShape == 0
		//Clicou no Texto
		nShape := aSCAN(aShape,{|x| (x[__ARRTXT__][__IDTXT__] == oPanel:ShapeAtu) .And. !aTail(X)[__INVISIBLE__] })
	EndIf

	If nShape > 0
		If nFocus == Nil .Or. nFocus != nShape
			DblClick(x,y,@oPanel,lTrocaPneu)
		EndIf
		oMenu:Activate(x,y,@oPanel)
	EndIf

Return

//---------------------------------------------------------------------
/*/{Protheus.doc} CriaCabecalho
Cria todos os objetos do cabecalho do programa
@author Vitor Emanuel Batista
@since 02/06/2009
@version undefined
@param oPanel, object, Objeto TPaintPanel
@param nAltura, numeric,  Altura para o cabecalho
@param nLargura, numeric, Largura para o cabecalho
@type function
/*/
//---------------------------------------------------------------------
Static Function CriaCabecalho(oPanel,nAltura,nLargura)

	Local nCabecX  := 20
	Local nCabecY  := 13

	Local nPlacaX := nCabecX+730
	Local nPlacaY := nCabecY-11
	Local nPlacaZ := 18

	Local cIdShapBem := ""
	Local cIdShapCT1 := ""

	Local lMNTA2327 := ExistBlock("MNTA2327") //Verifica existencia de ponto de entrada MNTA2327

	oPanel:addShape(	"id="+RetId()+";type=1;left=0;top=0;width="+Str(nLargura)+";height=600;"+;
						"gradient=1,0,0,0,0,0.0,#eeeeee;pen-width=0;"+;
						"pen-color=#ffffff;is-container=1;")

	//+-------------------------------------------------------------------+
	//|Bem           													  |
	//+-------------------------------------------------------------------+
	cIdShapBem := RetId()
	oPanel:addShape("id="+cIdShapBem+";type=7;left="+Str(nCabecX)+";top="+Str(nCabecY)+";width=200;height=30;"+;
	"text="+STR0014+";font=Verdana,08,0,0,1;pen-color=#000000;pen-width=1;is-container=0") //"Bem:"
	@ nCabecY-009,nCabecX+025 MsGet cDescBem Of oPanel Picture '@!' When .F. Size 150,08 Pixel

	//+-------------------------------------------------------------------+
	//|Dt Mov.        													  |
	//+-------------------------------------------------------------------+
	oPanel:addShape("id="+RetId()+";type=7;left="+Str(nCabecX+380)+";top="+Str(nCabecY)+";width=200;height=30;"+;
	"text="+STR0015+";font=Verdana,08,0,0,1;pen-color=#0000FF;pen-width=1;is-container=0")						  //"Data Mov.:"
	@ nCabecY-009,nCabecX+220 MsGet oDtMov Var dDTDATEM Of oPanel Valid Mnta232DtH() .And. fVerBemPai(oPanel,nCabecX,nCabecY,cIdShapBem,cIdShapCT1) Picture '99/99/9999' Size 45,08 HASBUTTON Pixel

	//+-------------------------------------------------------------------+
	//|Esquema       													  |
	//+-------------------------------------------------------------------+
	oPanel:addShape(	"id="+RetId()+";type=7;left="+Str(nCabecX)+";top="+Str(nCabecY+27)+;
	";width=200;height=30;text="+STR0016+";font=Verdana,08,0,0,1;pen-color=#000000;pen-width=1;is-container=0") //"Esquema:"
	@ nCabecY+006,nCabecX+025 MsGet cDesCodFam Of oPanel Picture '@!' When .F. Size 150,08 Pixel

	//+-------------------------------------------------------------------+
	//|Hr. Leitura   													  |
	//+-------------------------------------------------------------------+
	oPanel:addShape(	"id="+RetId()+";type=7;left="+Str(nCabecX+380)+";top="+Str(nCabecY+27)+;
	";width=200;height=30;text="+STR0017+";font=Verdana,08,0,0,1;pen-color=#0000FF;pen-width=1;is-container=0") //"Hora Leitura:"
	@ nCabecY+006,nCabecX+220 MsGet cHORALE1 Of oPanel Picture '99:99' Valid Mnta232DtH( 1 ) .And. fVerBemPai(oPanel,nCabecX,nCabecY,cIdShapBem,cIdShapCT1) Size 20,08 Pixel

	//+-------------------------------------------------------------------+
	//|Contador 1    													  |
	//+-------------------------------------------------------------------+
	cIdShapCT1 := RetId()
	oPanel:addShape(	"id="+cIdShapCT1+";type=7;left="+Str(nCabecX+525)+";top="+Str(nCabecY+27)+;
	";width=200;height=30;text="+STR0018+";font=Verdana,08,0,0,1;pen-color=#"+If(lTEMCONT,"0000FF","000000")+";pen-width=1;is-container=0") //"Contador 1:"
	@ nCabecY+006,nCabecX+290 MsGet nPOSCONT Of oPanel Picture '@E 999,999,999' Valid Positivo(nPOSCONT) .And. ;
		If( lMNTA2327 , ExecBlock("MNTA2327",.F.,.F.,{nPOSCONT,cCodBem,1}),.T.) Size 60,08 HASBUTTON ;
		When lTEMCONT .And. lWHENCONT .And. (!FindFunction("NGBlCont") .Or. NGBlCont( cBemPai )) Pixel

	//+-------------------------------------------------------------------+
	//|Modelo        													  |
	//+-------------------------------------------------------------------+
	oPanel:addShape(	"id="+RetId()+";type=7;left="+Str(nCabecX)+";top="+Str(nCabecY+57)+;
	";width=200;height=30;text="+STR0019+";font=Verdana,08,0,0,1;pen-color=#000000;pen-width=1;is-container=0") //"Modelo:"
	@ nCabecY+021,nCabecX+025 MsGet cDesTipMod Of oPanel Picture '@!' When .F. Size 150,08 Pixel

	//+-------------------------------------------------------------------+
	//|Hr. Leitura   													  |
	//+-------------------------------------------------------------------+
	oPanel:addShape(	"id="+RetId()+";type=7;left="+Str(nCabecX+380)+";top="+Str(nCabecY+57)+;
	";width=200;height=30;text="+STR0017+";font=Verdana,08,0,0,1;pen-color=#"+If(lTEMCON2,"0000FF","000000")+";pen-width=1;is-container=0") //"Hora Leitura:"
	@ nCabecY+021,nCabecX+220 MsGet cHORALE2 Of oPanel Picture '99:99' Valid If(lTEMCON2,NGVALHORA(cHORALE2,.T.) .And. MNTA231HL(cHORALE2,2,dDTDATEM) .And. NGPONTOENTR("MNTA2316",.T.,{dDTDATEM,cHORALE2,2}),.T.) Size 20,08 When lTEMCON2 Pixel

	//+-------------------------------------------------------------------+
	//|Contador 2    													  |
	//+-------------------------------------------------------------------+

	oPanel:addShape(	"id="+RetId()+";type=7;left="+Str(nCabecX+525)+";top="+Str(nCabecY+57)+;
	";width=200;height=30;text="+STR0020+";font=Verdana,08,0,0,1;pen-color=#"+If(lTEMCON2,"0000FF","000000")+";pen-width=1;is-container=0") //"Contador 2:"
	@ nCabecY+021,nCabecX+290 MsGet nPOSCON2 Of oPanel Picture '@E 999,999,999' Valid Positivo(nPOSCON2) .And. If( lMNTA2327 , ExecBlock("MNTA2327",.F.,.F.,{nPOSCON2,cCodBem,2}),.T.) Size 60,08 HASBUTTON When lTEMCON2 .And. lWHENCON2 Pixel

	//+-------------------------------------------------------------------+
	//|Cria Placa    													  |
	//+-------------------------------------------------------------------+
	//Verificação de data e país para utilização da nova placa do mercosul
	If !Empty(cPlaca) .And. !Empty(cLocMerc) .And. !Empty(cImgPlMerc) .And. ((dToS(DDATABASE) >= "20160101" .And. CPAISLOC $ "ARG-PAR-VEN-URU") .Or. (dToS(DDATABASE) >= "20170101" .And. CPAISLOC = "BRA"))
		oPanel:addShape(	"id="+RetId()+";type=8;left="+Str(nPlacaX)+";top="+Str(nPlacaY)+";width=85;height=38;image-file="+;
		cImgPlMerc+";can-move=0;can-deform=0;can-mark=0;is-container=1")
		oPanel:addShape(	"id="+RetId()+";type=7;left="+Str(nPlacaX+38)+";top="+Str(nPlacaY+nPlacaZ)+";width=175;height=60;text="+;
		cLocMerc+";font=FE Engschrift,"+cTamFont+",1,0,3;pen-color=#FFFFFF;pen-width=1;is-container=0")
		oPanel:addShape( "id="+RetId()+";type=8;left="+Str(nPlacaX+215)+";top="+Str(nPlacaY+11)+";width=85;height=38;image-file="+;
		cImgBand+";can-move=0;can-deform=0;can-mark=0;is-container=1")
		oPanel:addShape( "id="+RetId()+";type=8;left="+Str(nPlacaX+11)+";top="+Str(nPlacaY+10)+";width=85;height=38;image-file="+;
		cLogMerc+";can-move=0;can-deform=0;can-mark=0;is-container=1")
		oPanel:addShape(	"id="+RetId()+";type=7;left="+Str(nPlacaX+10)+";top="+Str(nPlacaY+34)+";width=230;height=50;text="+;
		cPlaca+";font=FE Engschrift,30,1,0,3;pen-color=#000000;pen-width=1;is-container=0")

		//Forma antiga de exibição de placa
	ElseIf !Empty(cPlaca) .And. ((dToS(DDATABASE) <= "20160101" .And. CPAISLOC $ "ARG-PAR-VEN-URU") .Or. (dToS(DDATABASE) <= "20170101" .And. CPAISLOC = "BRA"))
		oPanel:addShape(	"id="+RetId()+";type=8;left="+Str(nPlacaX)+";top="+Str(nPlacaY)+";width=85;height=38;image-file="+;
		lower(cImgPlaca)+";can-move=0;can-deform=0;can-mark=0;is-container=1")
		oPanel:addShape(	"id="+RetId()+";type=7;left="+Str(nPlacaX+38)+";top="+Str(nPlacaY+17)+";width=175;height=60;text="+;
		cLocal+";font=Verdana,10,1,0,3;pen-color=#000000;pen-width=1;is-container=0")
		oPanel:addShape(	"id="+RetId()+";type=7;left="+Str(nPlacaX+10)+";top="+Str(nPlacaY+34)+";width=230;height=50;text="+;
		cPlaca+";font=Verdana,23,1,0,3;pen-color=#000000;pen-width=1;is-container=0")

	//Placa Rússia
	ElseIf  !Empty(cPlaca) .And. !Empty(cImgPlRuss) .And. CPAISLOC = "URS"

		//Placa modelo Rússia
		oPanel:addShape("id="+RetId()+";type=8;left="+Str(nPlacaX)+";top="+;
						Str(nPlacaY)+";width=85;height=38;image-file="+cImgPlRuss+;
						";can-move=0;can-deform=0;can-mark=0;is-container=1")
		//Localização
		oPanel:addShape("id="+RetId()+";type=7;left="+Str(nPlacaX+108)+";top="+;
						Str(nPlacaY+59)+";width=175;height=60;text="+cLocRuss+;
						";font=FE Engschrift,14,1,0,3;pen-color=#000000;"+;
						"pen-width=1;is-container=0")
		//Números referente a macroregião na Rússia (a ser estudado)
		oPanel:addShape("id="+RetId()+";type=7;left="+Str(nPlacaX+155)+";top=";
						+Str(nPlacaY+25)+";width=85;height=38;text="+'105'+;
						";font=Arial,17,1,0,3;pen-width=1;is-container=0")
		//Bandeira
		oPanel:addShape("id="+RetId()+";type=8;left="+Str(nPlacaX+217)+";top="+;
						Str(nPlacaY+61)+";width=85;height=38;image-file="+cImgBand+;
						";can-move=0;can-deform=0;can-mark=0;is-container=1")
		//Placa do bem
		oPanel:addShape("id="+RetId()+";type=7;left="+Str(nPlacaX-25)+";top="+;
						Str(nPlacaY+30)+";width=230;height=50;text="+cPlaca+;
						";font=FE Engschrift,23,1,0,3;pen-color=#000000;"+;
						"pen-width=1;is-container=0")
	EndIf

	//Container com Gradient
	oPanel:addShape(	"id="+RetId()+";type=1;left=0;top="+Str(nAltura-10)+";width="+Str(nLargura)+";height=5;"+;
						"gradient=1,0,0,0,180,1.0,#849CB6,0.1,#849CB6,0.1,#849CB6;pen-width=0;"+;
						"pen-color=#849CB6;can-move=0;can-mark=0;is-container=1;")

	oPanel:addShape(	"id="+RetId()+";type=1;left=0;top="+Str(nAltura-5)+";width="+Str(nLargura)+";height=5;"+;
						"gradient=1,0,0,0,180,1.0,#849CB6,0.1,#EAEAEA,0.0,#849CB6;pen-width=0;"+;
						"pen-color=#FFFFFF;can-move=0;can-mark=0;is-container=1;")
Return

//---------------------------------------------------------------------
/*/{Protheus.doc} RetId
Incrementa Id do Shape
@author Vitor Emanuel Batista
@since 02/06/2009
@version undefined
@type function
/*/
//---------------------------------------------------------------------
Static Function RetId()
Return AllTrim(Str(++nId))

//---------------------------------------------------------------------
/*/{Protheus.doc} CriaCentro
Cria todos os objetos do centro do programa
@author Vitor Emanuel Batista
@since 02/06/2009
@version undefined
@param oPanel, object, Objeto TPaintPanel
@param nAltura, numeric,  Altura para o centro
@param nLargura, numeric, Largura para o centro
@type function
/*/
//---------------------------------------------------------------------
Static Function CriaCentro(oPanel,nAltura,nLargura)

	Local nY, nX
	Local nWidth  := Val(aEstruturas[nPosEstru][2])
	Local nHeight := Val(aEstruturas[nPosEstru][3])
	//+-------------------------------------------------------------------+
	//|Posicao X e Y de toda a estrutura e Pneus						  |
	//+-------------------------------------------------------------------+
	Local nTop  := (nAltura - nHeight/2)
	Local nLeft := (nLargura - nWidth)/2

	//Se der valores negativos, zera
	nTop  := If(nTop < 0,0,nTop)
	nLeft := If(nLeft < 0,0,nLeft)

	aBEMLOC   := {}
	aPNEUSINI := {}

	//+-------------------------------------------------------------------+
	//|Cria Container													  |
	//+-------------------------------------------------------------------+
	oPanel:addShape(	"id="+RetId()+";type=1;left=0;top=0;width="+Str(If(nLargura > nWidth,nLargura,nWidth)+10)+";height="+Str(If(nAltura*2 > nHeight,nAltura*2,nHeight))+";"+;
						"gradient=1,0,0,0,0,0.0,#FFFFFF;pen-width=0;"+;
						"pen-color=#FFFFFF;can-move=0;can-mark=0;is-container=1;")

	//+-------------------------------------------------------------------+
	//|Cria Estrutura													  |
	//+-------------------------------------------------------------------+
	oPanel:addShape(	"id=12;type=8;left="+Str(nLeft)+";top="+Str(nTop)+";width="+Str(nWidth)+";height="+Str(nHeight)+;
						";image-file="+lower(cImgEstru)+";can-move=0;can-deform=0;can-mark=0;is-container=1")

	//+-------------------------------------------------------------------+
	//|Cria Pneus    													  |
	//+-------------------------------------------------------------------+

	dbSelectArea("STC")
	dbSetOrder(1)
	If dbSeek(xFilial("STC")+cBemPai)
		While !Eof() .And. xFilial("STC") == STC->TC_FILIAL .And. STC->TC_CODBEM == cBemPai
			If STC->TC_TIPOEST = "B" .And. ST9->(dbSeek(xFilial("ST9")+STC->TC_COMPONE))
				aAdd(aBEMLOC,{STC->TC_LOCALIZ,STC->TC_COMPONE,Space(Len(STZ->TZ_CAUSA)),ST9->T9_CODFAMI,STC->TC_CODBEM})
			EndIf
			dbSkip()
		EndDo
	EndIf

	dbSelectArea("TQ0")
	dbSetOrder(1)

	If lRel12133
		MNTSeekPad( 'TQ0', 1, cCodFami, cTipMod )
	Else
		dbSeek(xFilial("TQ0")+cCodFami+cTipMod)
	EndIf

	//Adiciona Stepes na Estrutura
	For nY := 1 To Len(aEstruturas[nPosEstru][5])

		lReserva := .F.
		dbSelectArea("TQ1")
		dbSetOrder(1)
		dbSeek(xFilial("TQ1")+TQ0->TQ0_DESENH+TQ0->TQ0_TIPMOD)
		While !Eof() .And. xFilial("TQ1") == TQ1->TQ1_FILIAL .And. TQ1->TQ1_DESENH == TQ0->TQ0_DESENH ;
		.And. TQ1->TQ1_TIPMOD == TQ0->TQ0_TIPMOD
			If TQ1->TQ1_EIXO = STR0021 //"RESERVA"
				lReserva := .T.
				Exit
			EndIf
			dbSkip()
		EndDo

		If lReserva
			CriaEixo(oPanel,.T.,nY,nTop,nLeft)
		EndIf

	Next nY

	//Adiciona Pneus na Estrutura
	For nX := 1 to Len(aEstruturas[nPosEstru][4])

		cEixo   := cValToChar(nX)

		dbSelectArea("TQ1")
		dbSetOrder(1)
		dbSeek(xFilial("TQ1")+TQ0->TQ0_DESENH+TQ0->TQ0_TIPMOD+Str(nX,3))

		CriaEixo(oPanel,.F.,nX,nTop,nLeft)
	Next nX

	//Faz copia do aPNEUSINI para o aPNEUSFIM
	aPNEUSFIM := aCLONE(aPNEUSINI)
	nTamTRB   := Len(aPNEUSINI[1]) //Nao retirar, utilizado por pontos de entrada

Return

//---------------------------------------------------------------------
/*/{Protheus.doc} CriaEixo
Cria eixo com todos os pneus
@author Vitor Emanuel Batista
@since 06/08/2009
@version undefined
@param oTPanel, object, Objeto TPaintPanel
@param lStepe, logical, Indica que eixo sera de Stepes
@param nAtu, numeric, Numero do eixo atual a ser criado
@param nTop, numeric,  Posicao Y inicial que pneu sera criado
@param nLeft, numeric, Posicao X inicial que pneu sera criado
@type function
/*/
//---------------------------------------------------------------------
Static Function CriaEixo(oTPanel,lStepe,nAtu,nTop,nLeft)

	Local nY, nPos
	Local nEstru := If(lStepe,5,4) //Posicao
	Local cCodPneu := ""
	Local cLocaliz, cPneuFam
	Local cPneuX, cPneuY
	Local lInvisible := .F.
	//Feito a verificacao da variavel, pois havia erro log na rotina MNTC125, que seguia a pilha de chamada:
	//IMPRODADOS(MNTC125.PRW) -> MNTA232IMP(MNTA232.PRW) -> CRIACENTRO(MNTA232.PRW)
	If Type("lContEs") == "U"
		lContEs := NGCADICBASE('TQZ_ALMOX','A','TQZ',.F.) //Campos de histórico do status que controlam estoque
	EndIf

	For nY := 1 To Len(aEstruturas[nPosEstru][nEstru][nAtu])
		cCodType := aEstruturas[nPosEstru][nEstru][nAtu][nY][1]
		nPneuX := nLeft+Val(aEstruturas[nPosEstru][nEstru][nAtu][nY][2])
		nPneuY := nTop+Val(aEstruturas[nPosEstru][nEstru][nAtu][nY][3])
		cPneuX := cValToChar(nPneuX)
		cPneuY := cValToChar(nPneuY)
		cCodPneu := ""

		//Adiciona na ultima posicao o numero do Eixo
		If lStepe
			aAdd(aEstruturas[nPosEstru][nEstru][nAtu][nY],0)
		EndIf

		cLocaliz := &("TQ1->TQ1_LOCPN"+cValToChar(nY))
		cPneuFam := &("TQ1->TQ1_FAMIL"+cValToChar(nY))
		nPos     := aSCAN(aBEMLOC, {|aArray| aArray[1] == cLocaliz})

		If !lStepe .Or. (lStepe .And. TQ0->TQ0_STEPES != "N" .And. Val(TQ0->TQ0_STEPES) >= nY)
			cCodPneu := If(nPos>0, aBEMLOC[nPos][2], Space(TAMSX3("T9_CODBEM")[1]))
			dbSelectArea("ST9")
			dbSetOrder(1)
			dbSeek(xFilial("ST9")+cCodPneu)
			dbSelectArea("TQS")
			dbSetOrder(1)
			dbSeek(xFilial("TQS")+cCodPneu)

			lInvisible := Empty(cCodPneu)
			cToolTip   := If(!lInvisible, Trim(cCodPneu) + " - " + Trim(NGSEEK("ST9",cCodPneu,1,"ST9->T9_NOME")),"")

			NGCriaPneu( oTPanel,;
			nPneuX,; //Posicao X
			nPneuY,; //Posicao Y
			cCodType,;
			cCodPneu,; //Codigo que sera impresso no pneu
			Val(TQS->TQS_BANDAA),; //Vida do pneu
			lStepe,; //Estepe
			.F.,; //Clicado
			lInvisible,; //Invisivel
			{ cPneuFam, cLocaliz },;//aEstruturas[nPosEstru][nEstru][nAtu][nY],;
			cToolTip) //Tipo Bem

			aAdd( aPNEUSINI, Array( 27 ) )

			aTail(aPNEUSINI)[__LOCALIZ__] := cLocaliz			//[01] LOCALIZACAO
			aTail(aPNEUSINI)[__CODBEM__]  := cCodPneu			//[02] CODBEM - PNEU
			aTail(aPNEUSINI)[__CODFAMI__] := cPneuFam			//[03] CODIGO FAMILIA
			aTail(aPNEUSINI)[__EIXO__]    := Val(TQ1->TQ1_SEQREL)	//[04] EIXO
			aTail(aPNEUSINI)[__TIPEIXO__] := TQ1->TQ1_TIPEIX	//[05] TIPO DE EIXO
			aTail(aPNEUSINI)[__MEDIDA__]  := TQS->TQS_MEDIDA	//[06] MEDIDA
			aTail(aPNEUSINI)[__SULCO__]   := TQS->TQS_SULCAT	//[07] SULCO
			aTail(aPNEUSINI)[__BANDA__]   := TQS->TQS_BANDAA	//[08] BANDA
			aTail(aPNEUSINI)[__DOT__]     := TQS->TQS_DOT		//[09] DOT
			aTail(aPNEUSINI)[__STATUS__]  := ST9->T9_STATUS	//[10] STATUS
			aTail(aPNEUSINI)[__SEQREL__]  := TQ1->TQ1_SEQREL	//[11] SEQ REL
			aTail(aPNEUSINI)[__MOTIVO__]  := Space(6)			//[12] MOTIVO
			aTail(aPNEUSINI)[__CODESTO__] := ST9->T9_CODESTO	//[13]  T9_CODESTO
			aTail(aPNEUSINI)[__LOCPAD__]  := IIF(lContEs,NGSEEK("TQZ",ST9->T9_CODBEM+DTOS(TQS->TQS_DTMEAT)+TQS->TQS_HRMEAT,1,"TQZ->TQZ_ALMOX"),' ')//[14] B1_LOCPAD
			aTail(aPNEUSINI)[__USUARIO__] := ''					//[15] USUARIO TZ_USUARIO
			aTail(aPNEUSINI)[__CCUSTO__]  := ST9->T9_CCUSTO	//[16] CENTRO DE CUSTO
			aTail(aPNEUSINI)[__CENTRAB__] := ST9->T9_CENTRAB   //[17] CENTRO DE TRABALHO
			aTail(aPNEUSINI)[__LIVRE__]   := ""
			aTail(aPNEUSINI)[__LOCALAM__] := Space(Len(STL->TL_LOCAL))   //[19] Almoxarifado
			aTail(aPNEUSINI)[__NUMLOTE__] := Space(Len(STL->TL_NUMLOTE)) //[20] Sub_lote
			aTail(aPNEUSINI)[__LOTECTL__] := Space(Len(STL->TL_LOTECTL)) //[21] Lote
			aTail(aPNEUSINI)[__NUMSERI__] := Space(Len(STL->TL_NUMSERI)) //[22] Numero da serie
			aTail(aPNEUSINI)[__LOCALIF__] := Space(Len(STL->TL_LOCALIZ)) //[23] Localizacao fisica
			aTail(aPNEUSINI)[__DATAVAL__] := Ctod("  /  /  ")            //[24] Data validade
			aTail(aPNEUSINI)[__CODEANT__] := ST9->T9_CODESTO             //[25] Codigo do produto no estoque antigo
			aTail(aPNEUSINI)[__ITEMCTA__] := ST9->T9_ITEMCTA             //[26] Codigo do item contabil
			aTail(aPNEUSINI)[__EMISSAO__] := Ctod("  /  /  ")            //[27] Data de emissão da NF quando aguardando aplicação			

		EndIf

	Next nY

Return

//---------------------------------------------------------------------
/*/{Protheus.doc} CriaRodape
Cria todos os objetos do rodape do programa
@author Vitor Emanuel Batista
@since 02/06/2009
@version undefined
@param oPanel, object, Objeto TPaintPanel
@param nLargura, numeric, Altura para o rodape
@param nAltRod, numeric,  Largura para o rodape
@type function
/*/
//---------------------------------------------------------------------
Static Function CriaRodape(oPanel,nLargura,nAltRod)

	Local nAltVidas := 20

	Local nLinBmp, nColBmp, nLinSay, nColSay

	Local nImgX := (nLargura-537-129)/2 //Total - Distancia X da ultima imagem + Tamanho da imagem
	Local nImgY := 25 + nAltVidas
	Local nLegCorY := If(!lRodizio,0,(nAltRod/4)+If(PtGetTheme() = "MDI",18,8))
	nImgX := If(nImgX<0,0,nImgX)

	//Container com Gradient
	oPanel:addShape(	"id="+RetId()+";type=1;left=0;top=0;width="+Str(nLargura)+";height="+Str(nAltRod)+";"+;
						"gradient=1,0,0,0,180,0.0,#FFFFFF,0.1,#FDFBFD,1.0,#CDD1D4;pen-width=0;pen-color=#FFFFFF;can-move=0;can-mark=0;is-container=1;")

	//Linha acima do Gradient
	oPanel:addShape(	"id="+RetId()+";type=1;left=0;top="+Str(nLegCorY*2)+";width="+AllTrim(Str(nLargura))+";height="+cValToChar(nAltVidas)+";"+;
						"gradient=1,10,0,229,0,0.0,#F2F3F6;pen-width=0;pen-color=#F2F3F6;can-move=0;can-mark=0;is-container=0;")

	nLinBmp := nLegCorY + 1.5
	nColBmp := nImgX/2 + 30
	nLinSay := nLegCorY + 1.5
	nColSay := nImgX/2 + 45
	@ nLinBmp,nColBmp BITMAP oBmp0 RESNAME "BR_PRETO" SIZE 16,16 NOBORDER OF oPanel PIXEL
	@ nLinSay,nColSay Say STR0022 OF oPanel Pixel //"Novo"

	nColBmp += 060
	nColSay += 060
	@ nLinBmp,nColBmp BITMAP oBmp1 RESNAME "BR_VERDE" SIZE 16,16 NOBORDER OF oPanel PIXEL
	@ nLinSay,nColSay Say STR0023 OF oPanel Pixel //"1 Vida"

	nColBmp += 060
	nColSay += 060
	@ nLinBmp,nColBmp BITMAP oBmp2 RESNAME "BR_AZUL" SIZE 16,16 NOBORDER OF oPanel PIXEL
	@ nLinSay,nColSay Say STR0024 OF oPanel Pixel //"2 Vidas"

	nColBmp += 060
	nColSay += 060
	@ nLinBmp,nColBmp BITMAP oBmp3 RESNAME "BR_LARANJA" SIZE 16,16 NOBORDER OF oPanel PIXEL
	@ nLinSay,nColSay Say STR0025 OF oPanel Pixel //"3 Vidas"

	nColBmp += 060
	nColSay += 060
	@ nLinBmp,nColBmp BITMAP oBmp3 RESNAME "BR_VERMELHO" SIZE 16,16 NOBORDER OF oPanel PIXEL
	@ nLinSay,nColSay Say STR0085+If(lMaisVidas," +","") OF oPanel Pixel //"4 Vidas"
	If ExistBlock("MNTA2321") // Verifica se existe o ponto de entrada
		ExecBlock("MNTA2321",.F.,.F.,{oPanel}) // Passa objeto visual
	EndIf
	// Quando não for Rodízio
	If !lRodizio
		//Linha acima do Gradient
		oPanel:addShape(	"id="+RetId()+";type=1;left=0;top="+cValToChar(nAltVidas)+";width="+AllTrim(Str(nLargura))+";height=5;"+;
							"gradient=1,10,0,229,0,0.0,#CDD1D4;pen-width=0;pen-color=#CDD1D4;can-move=0;can-mark=0;is-container=0;")

		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Imagens - Status ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		//Estoque
		nIdEstoque := Val(RetId())
		oPanel:addShape(	"id="+Str(nIdEstoque)+";type=8;left="+Str(nImgX)+";top="+Str(nImgY)+;
							";width=151;height=133;image-file="+lower(cImgEstoque)+";tooltip=Estoque;can-mark=1;is-container=0")
		oPanel:addShape(	"id="+Str(nIdEstoque)+";type=7;left="+Str(nImgX-20)+";top="+Str(nImgY+110)+;
							";width=175;height=60;text="+STR0026+";font=Verdana,12,1,1,3;"+; //"Estoque"
							"pen-color=#000000;pen-width=1;tooltip="+STR0026+";can-mark=1;is-container=0") //"Estoque"

		//Recape
		nIdRecape := Val(RetId())
		oPanel:addShape(	"id="+Str(nIdRecape)+";type=8;left="+Str(nImgX+192)+";top="+Str(nImgY)+;
							";width=129;height=129;image-file="+lower(cImgRecape)+";tooltip=Conserto/Recape;can-mark=1;is-container=0")
		oPanel:addShape(	"id="+Str(nIdRecape)+";type=7;left="+Str(nImgX+172)+";top="+Str(nImgY+110)+;
							";width=175;height=60;text="+STR0027+";font=Verdana,12,1,1,3;"+; //"Conserto/Recape"
							"pen-color=#000000;pen-width=1;tooltip="+STR0027+";can-mark=1;is-container=0") //"Conserto/Recape"

		//Sucata
		nIdSucata := Val(RetId())
		oPanel:addShape(	"id="+Str(nIdSucata)+";type=8;left="+Str(nImgX+387)+";top="+Str(nImgY-15)+;
							";width=102;height=154;image-file="+lower(cImgSucata)+";tooltip=Sucata;can-mark=1;is-container=0")
		oPanel:addShape(	"id="+Str(nIdSucata)+";type=7;left="+Str(nImgX+347)+";top="+Str(nImgY+110)+;
							";width=175;height=60;text="+STR0028+";font=Verdana,12,1,1,3;"+; //"Sucata"
							"pen-color=#000000;pen-width=1;tooltip="+STR0028+";can-mark=1;is-container=0") //"Sucata"

		//Analise Tecnica
		nIdAnalise := Val(RetId())
		oPanel:addShape(	"id="+Str(nIdAnalise)+";type=8;left="+Str(nImgX+537)+";top="+Str(nImgY)+;
							";width=129;height=129;image-file="+lower(cImgAnalise)+";tooltip=Análise;can-mark=1;is-container=0")
		oPanel:addShape(	"id="+Str(nIdAnalise)+";type=7;left="+Str(nImgX+517)+";top="+Str(nImgY+110)+;
							";width=175;height=60;text="+STR0029+";font=Verdana,12,1,1,3;"+; //"Análise"
							"pen-color=#000000;pen-width=1;tooltip="+STR0029+";can-mark=1;is-container=0") //"Análise"
	EndIf

Return

//---------------------------------------------------------------------
/*/{Protheus.doc} CriaRodizio
Cria todos os objetos do Rodizio do programa
@author Vitor Emanuel Batista
@since 02/06/2009
@version undefined
@param oPanel, object,    Objeto TPaintPanel
@param nLargura, numeric, Largura para o rodizio
@type function
/*/
//---------------------------------------------------------------------
Static Function CriaRodizio(oPanel,nLargura)

	Local nX
	Local nPosX1 := 25
	Local nPosX2 := 120
	Local nPosY  := 40
	Local cCodPneu := ""
	Local aTemp  := {}
	Local nIndex := 0
	Local cAliasQry := ''

	//Container com Gradient
	oPanel:addShape(	"id="+RetId()+";type=1;left=5;top=0;width="+AllTrim(Str(nLargura))+";height="+Str(nAltura)+";"+;
						"gradient=1,10,0,229,0,0.0,#C6C6C6,0.1,#EAEAEA,1.0,#EAEAEA;pen-width=0;"+;
						"pen-color=#FFFFFF;can-move=0;can-mark=1;is-container=1;")

	//Divisao entre o TPaintPanel do centro e do rodape com o do rodizio
	oPanel:addShape(	"id="+RetId()+";type=1;left=0;top=0;width=5;height="+Str(nAltura)+";gradient=1,10,0,229,0,0.0,#8D949E;pen-width=0;"+;
						"pen-color=#8D949E;can-move=0;can-mark=0;is-container=0;")

	oPanel:addShape(	"id="+RetId()+";type=7;left=10;top=10;width=210;height=60;text="+STR0013+";font=Verdana,11,1,0,3;"+; //"Área de Transferência"
						"pen-color=#000000;pen-width=1;can-mark=1;is-container=0")

	//Cria array contendo localizacoes possiveis para pneus em rodizio
	For nX := 1 to 30
		aAdd(aRodizio,{cCodPneu,nPosX1,nPosY,{}})
		aAdd(aRodizio,{cCodPneu,nPosX2,nPosY,{}})
		nPosY += 30
	Next nX

	//---------------------------------------------------------------------------------
	// Busca pneus que foram retirados do armazém mas não foram aplicados no veículo
	//---------------------------------------------------------------------------------
	If SD3->( FieldPos('D3_PNEU') ) > 0

		cAliasQry := GetNextAlias()

		// Executa query para pneus aguardando aplicação
		BeginSql Alias cAliasQry

			SELECT ST9.T9_CODBEM,
				ST9.T9_CODFAMI,
				ST9.T9_STATUS,
				ST9.T9_CODESTO,
				ST9.T9_LOCPAD,
				ST9.T9_CCUSTO,
				ST9.T9_CENTRAB,
				ST9.T9_ITEMCTA,
				TQS.TQS_BANDAA,
				TQS.TQS_MEDIDA,
				TQS.TQS_DOT,
				TQS.TQS_SULCAT,
				STL.TL_LOCALIZ,
				STL.TL_NUMSERI,
				STL.TL_LOTECTL,
				STL.TL_NUMLOTE,
				STL.TL_LOCAL,
				SD3.D3_EMISSAO
			FROM %table:SD3% SD3
			JOIN %table:ST9% ST9
				ON ST9.T9_CODBEM = SD3.D3_PNEU
				AND ST9.T9_FILIAL = %xFilial:ST9%
				AND ST9.T9_CATBEM = '3'
				AND ST9.T9_STATUS <> ' '
				AND ST9.%notdel%
				AND ST9.T9_STATUS = %exp:Alltrim( SuperGetMv( 'MV_NGSTAGA', .F., '' ) )% // Aguardando aplicação
			JOIN %table:TQS% TQS
				ON TQS.TQS_CODBEM = SD3.D3_PNEU
				AND TQS.TQS_FILIAL = %xFilial:TQS%
				AND TQS.%notdel%
			JOIN %table:STL% STL
				ON STL.TL_NUMSEQ = SD3.D3_NUMSEQ
				AND STL.TL_FILIAL = %xFilial:STL%
				AND STL.%notdel%
			WHERE SD3.%notDel%
				AND SD3.D3_FILIAL = %xFilial:SD3%
				AND SD3.D3_ORDEM = %exp:cNumOS%
				AND SD3.D3_PNEU <> ' '

		EndSql

		aPneusReq := {}

		While !(cAliasQry)->( Eof() )

			aTemp := Array(27)
			aTemp[__LOCALIZ__] := '' //[01] LOCALIZACAO
			aTemp[__CODBEM__]  := (cAliasQry)->T9_CODBEM //[02] CODBEM - PNEU
			aTemp[__CODFAMI__] := (cAliasQry)->T9_CODFAMI  //[03] CODIGO FAMILIA
			aTemp[__EIXO__]    := 0	 //[04] EIXO
			aTemp[__TIPEIXO__] := '' //[05] TIPO DE EIXO
			aTemp[__MEDIDA__]  := (cAliasQry)->TQS_MEDIDA //[06] MEDIDA
			aTemp[__SULCO__]   := (cAliasQry)->TQS_SULCAT //[07] SULCO
			aTemp[__BANDA__]   := (cAliasQry)->TQS_BANDAA //[08] BANDA
			aTemp[__DOT__]     := (cAliasQry)->TQS_DOT //[09] DOT
			aTemp[__STATUS__]  := (cAliasQry)->T9_STATUS //[10] STATUS
			aTemp[__SEQREL__]  := '' //[11] SEQ REL
			aTemp[__MOTIVO__]  := '' //[12] MOTIVO
			aTemp[__CODESTO__] := (cAliasQry)->T9_CODESTO //[13] T9_CODESTO
			aTemp[__LOCPAD__]  := (cAliasQry)->T9_LOCPAD //[14] B1_LOCPAD
			aTemp[__USUARIO__] := '' //[15] USUARIO TZ_USUARIO
			aTemp[__CCUSTO__]  := (cAliasQry)->T9_CCUSTO //[16] CENTRO DE CUSTO
			aTemp[__CENTRAB__] := (cAliasQry)->T9_CENTRAB //[17] CENTRO DE TRABALHO
			aTemp[__LIVRE__]   := ''
			aTemp[__LOCALAM__] := (cAliasQry)->TL_LOCAL //[19] Almoxarifado
			aTemp[__NUMLOTE__] := (cAliasQry)->TL_NUMLOTE //[20] Sub_lote
			aTemp[__LOTECTL__] := (cAliasQry)->TL_LOTECTL //[21] Lote
			aTemp[__NUMSERI__] := (cAliasQry)->TL_NUMSERI //[22] Numero da serie
			aTemp[__LOCALIF__] := (cAliasQry)->TL_LOCALIZ //[23] Localizacao fisica
			aTemp[__DATAVAL__] := Ctod("  /  /  ") //[24] Data validade
			aTemp[__CODEANT__] := (cAliasQry)->T9_CODESTO //[25] Codigo do produto no estoque antigo
			aTemp[__ITEMCTA__] := (cAliasQry)->T9_ITEMCTA //[26] Codigo do produto no estoque antigo
			aTemp[__EMISSAO__] := Stod( (cAliasQry)->D3_EMISSAO )//[27] Data de emissão da NF

			nIndex := aSCAN(aRodizio,{|x| Empty(x[1]) }) // busca a primeira posicao vazia no aRodizio
			aRodizio[nIndex][1] := aTemp[__CODBEM__]
			aRodizio[nIndex][4] := aClone( aTemp )

			aAdd( aPneusReq, aClone( aTemp ) ) // pneus que vem de requisição e serão adicionados na area de transferencia

			NGCriaPneu(@oPanel,;
				aRodizio[nIndex,2],;
				aRodizio[nIndex,3],;
				"1",;
				aRodizio[nIndex][1],;
				Val( (cAliasQry)->TQS_BANDAA );
				,,,,;
				{ (cAliasQry)->T9_CODFAMI , STR0013 } ) //"Área de Transferência"

			(cAliasQry)->( dbSkip() )

		EndDo

		(cAliasQry)->( dbCloseArea() )

	EndIf

Return

//---------------------------------------------------------------------
/*/{Protheus.doc} ClickRodape
Funcao chamada ao dar um clique da direita sobre o Rodape
@author Vitor Emanuel Batista
@since 02/06/2009
@version undefined
@param x, , Posicao X do clique
@param y, , Posicao Y do clique
@param oPanel, object, Objeto TPaintPanel
@type function
/*/
//---------------------------------------------------------------------
Static Function ClickRodape(x,y,oPanel)

	Local nShapeAtu := oPanel:ShapeAtu
	Local lOk   	 := .F.

	//Se nao houver pneu setado
	If nFocus == Nil .Or. oTFocus == Nil
		Return .F.
	ElseIf aTail(aShape[nFocus])[__INVISIBLE__] //Indica pneu invisivel
		Return .F.
	ElseIf lRodizio
		//MsgStop("Será possível retirar o pneu da estrutura somente para Serviço de Movimentação de Pneus ("+cNGSERPN+")","Atenção")
		Return .F.
	EndIf

	If DLGPNEU(nShapeAtu,nFocus)
		lOk := .T.
		NGCriaPneu(oTFocus,;
		aShape[nFocus][__IMGX__],;
		aShape[nFocus][__IMGY__],;
		aShape[nFocus][__TYPE__],;
		"",;
		0,;
		aTail(aShape[nFocus])[__ESTEPE__],;
		.F.,;
		.T.,;
		aClone(aShape[nFocus][__INFO__]),;
		"")//Tooltip

		oTFocus:DeleteItem(aShape[nFocus][__IDPNEU__])
		oTFocus:DeleteItem(aShape[nFocus][__ARRTXT__][__IDTXT__])

		aDel( aShape, nFocus )
		aSize( aShape, Len( aShape ) - 1 )

		nFocus  := Nil
		oTFocus := Nil
	EndIf

Return lOk

//---------------------------------------------------------------------
/*/{Protheus.doc} DLGPNEU
Abre dialog para retirar ou adicionar pneu da estrutura
@author Vitor Emanuel Batista
@since 02/06/2009
@version undefined
@param nOpcao, numeric, Opcao de adicionar ou retirar pneu (id do Shape)
@param nFocus, numeric, Posicao na array aShape do pneu Focado
@param nShape, numeric, Posicao na array aShape do segundo pneu
@param lArea, logical, Indica que pneu ira para a Area de Transferencia
@type function
/*/
//---------------------------------------------------------------------
Static Function DLGPNEU(nOpcao,nFocus,nShape,lArea)

	Local nPosY      := 0.5 //Variavel que indica posicao dos objetos na tela
	Local lOk   	 := .F. //Se foi confirmado tela e esta tudo Ok
	Local cPneu1     := aShape[nFocus][__CODPNEU__]
	Local cPneu2     := If(!Empty(nShape),aShape[nShape][__CODPNEU__],"")
	Local lInvisible := If(!Empty(nShape),aTail(aShape[nShape])[__INVISIBLE__],.F.)
	Local cCabec     := STR0030 + AllTrim(cPneu1) //"Disponibilizacao do Rodado: "

	//Variavel de controle utilizada no MNTA231SU() para validar TWI.
	Local lValidTwi	 := .F.

	//Variaveis de Centro de custo e Centro de Trabalho
	Local cCCUSTO  := NGSEEK('ST9',cPneu1,1,'ST9->T9_CCUSTO')
	Local cCENTRAB := NGSEEK('ST9',cPneu1,1,'ST9->T9_CENTRAB')

	//Variavel que indica se podera ser alterado o Centro de Trabalho e Centro de Custo
	Local lMoviBem := NGSEEK('ST9',cPneu1,1,'ST9->T9_MOVIBEM') = 'S'

	//Indica se campo Status estara aberto
	Local lStatus  := .T.

	//Variaveis basicas
	Local cNomMot1	 := cNomMot2  := Space(Len(ST8->T8_NOME))
	Local cMotivo1	 := cMotivo2  := Space(Len(ST8->T8_CODOCOR))
	Local nSulco1	 := nSulco2   := 0.00
	Local nPosPneu1:= nPosPneu2 := 0

	//Variavel para validação do ponto de entrada MNTA2322
	Local l2322	:= .T.
	Local l2326	:= .T.

	//Variaveis que indicam como sera a tela
	Local lSaiPneu		:= .F. //Indica que o pneu saira da tela (clicando no rodape)
	Local lAltPneu		:= .F. //Indica que Motivo Sulco do pneu serao alterados
	Local lTrocaPneu	:= .F. //Indica que dois pneus serao trocados na estrutura
	Local lAltLoc		:= .F. //Indica que pneu sera trocado na estrutura por uma localizacao vazia

	//Variaveis para validacoes

	Local cNomSt	 := Space(30)
	Local nCodPneReq := 0


	Private cNomCust	  := NGSEEK('CTT',cCCUSTO,1,'CTT->CTT_DESC01')
	Private cNomSHB	      := NGSEEK('SHB',cCENTRAB,1,'SHB->HB_NOME')
	Private M->TQY_STATUS := Space(Len(TQY->TQY_STATUS))
	Private lFrota	      := GetNewPar('MV_NGMNTFR','N') == 'S' // Variavel utilizada na construção da tela de inclusão de Status através do F3.

	//Variável usada para validação do status x destino no estoque
	Private cPneu   := ""
	Private lRecape := .F.

	Private cItemCTA := NGSEEK('ST9',cPneu1,1,'ST9->T9_ITEMCTA')
	Private cNomeCTA := NGSEEK('CTD',cItemCTA,1,'CTD->CTD_DESC01')

	//Variaveis da validacao do Status
	Private cCodST9Est := ''
	Private cCodST9Alm := ''
	Private cCodST9Loc := ''

	//Variaveis de localizacao do pneu na array aPNEUSFIM
	nPosPneu1 := aSCAN(aPNEUSFIM,{|aArray| aArray[__LOCALIZ__] == (aShape[nFocus][__INFO__])[2] })
	nPosPneu2 := If(!Empty(nShape),aSCAN(aPNEUSFIM,{|aArray| aArray[__LOCALIZ__] == (aShape[nShape][__INFO__])[2] }),0)

	//Se os pneus selecionados nao estiverem na estrutura (Estiver na area de transferencia)
	If nPosPneu1 == 0 .And. nPosPneu2 == 0
		Return .F.
	EndIf

	//Verifica Familia dos pneus, nao permitindo movimentacao se forem diferentes
	If !Empty(nShape) .And. !Empty(nFocus)
		If (aShape[nFocus][__INFO__])[1] != (aShape[nShape][__INFO__])[1]
			MsgStop(STR0031,STR0009) //"Familía divergente entre os pneus."##"Atenção"
			Return .F.
		EndIf
	EndIf

	If !Empty(cPneu1)
		//Adiciona oPneu na consulta
		dbSelectarea(cAliQryTQI)
		dbSetOrder(1)
		If !dbSeek(cPneu1)
			RecLock((cAliQryTQI),.T.)
			(cAliQryTQI)->T9_CODBEM := cPneu1
			(cAliQryTQI)->T9_NOME := NGSEEK("ST9",cPneu1,1,"T9_NOME")
			MsUnlock()
		EndIf
	EndIf

	If nOpcao == 0 .And. !Empty(nFocus)

		//Variavel de controle utilizada no MNTA231SU() para validar TWI.
		lValidTwi := .T.

		If !Empty(nShape) .And. !lInvisible
			cCabec     := STR0032 + Trim(cPneu1) + STR0033 + Trim(cPneu2) //"Transferência de Localização entre os Pneus "###" e "
			lTrocaPneu := .T.
			If nPosPneu1 == 0
				nPosRod := aSCAN(aRodizio,{|aArray| aArray[1] == cPneu1})
				If nPosRod > 0
					cMotivo1 := aRodizio[nPosRod][4][__MOTIVO__]
					nSulco1	:= aRodizio[nPosRod][4][__SULCO__]
				EndIf
			Else
				cMotivo1 := aPNEUSFIM[nPosPneu1][__MOTIVO__]
				nSulco1	:= aPNEUSFIM[nPosPneu1][__SULCO__]
			EndIf

			If nPosPneu2 == 0
				nPosRod := aSCAN(aRodizio,{|aArray| aArray[1] == cPneu2})
				If nPosRod > 0
					cMotivo2 := aRodizio[nPosRod][4][__MOTIVO__]
					nSulco2	:= aRodizio[nPosRod][4][__SULCO__]
				EndIf
			Else
				cMotivo2 := aPNEUSFIM[nPosPneu2][__MOTIVO__]
				nSulco2	:= aPNEUSFIM[nPosPneu2][__SULCO__]

			EndIf
		Else
			If lInvisible
				nPosPneu1 := aSCAN(aPNEUSFIM,{|aArray| aArray[__LOCALIZ__] == (aShape[nFocus][__INFO__])[2] })
				nPosPneu2 := aSCAN(aPNEUSFIM,{|aArray| aArray[__LOCALIZ__] == (aShape[nShape][__INFO__])[2] })
				cCabec    := STR0034 + Trim(cPneu1) //"Transferência de Localização do Pneu "
				lAltLoc   := .T.
			Else
				cCabec    := STR0035 + Trim(cPneu1) + STR0036 //"Alteração do pneu "###" na estrutura. "
				lAltPneu  := .T.
			EndIf

			//Se ja foi informado o motivo do pneu em alteracao
			If nPosPneu1 > 0
				cMotivo1 := aPNEUSFIM[nPosPneu1][__MOTIVO__]
				nSulco1	 := aPNEUSFIM[nPosPneu1][__SULCO__]
			ElseIf lRodizio
				nPosRod  := aSCAN(aRodizio,{|aArray| aArray[1] == cPneu1})
				cMotivo1 := aRodizio[nPosRod][4][__MOTIVO__]
				nSulco1	 := aRodizio[nPosRod][4][__SULCO__]
			EndIf
			If nPosPneu2 > 0
				nSulco2  := aPNEUSFIM[nPosPneu2][__SULCO__]
			EndIf
		EndIf

	Else
		//Se o pneu nao estava na estrutura nao eh necessario preencher informacoes
		If aSCAN(aPNEUSINI,{|aArray| aArray[__CODBEM__] == cPneu1}) == 0
			If nPosPneu1 > 0
				If nOpcao != nIdEstoque
					ShowHelpDlg(STR0009,	{STR0092},1,; //"Não é possível fazer movimentação diferente de Estoque para pneus que ainda não estão na estrutura."
					{STR0093},1) //"Utilize a rotina de Analise Técnica para esta operação."
					Return .F.
				Else
					aPNEUSFIM[nPosPneu1][__CODBEM__]  := ""
				EndIf
			EndIf
			Return .T.
		EndIf

		If nOpcao == nIdEstoque
			If ExistBlock("MNTA2322")
				l2322 := ExecBlock("MNTA2322",.F.,.F.,{"E"})
				If !l2322
					Return .F.
				EndIf
			EndIf
			cCabec += STR0037 //" - Estoque"
			lSaiPneu := .T.
		ElseIf nOpcao == nIdRecape

			If ExistBlock("MNTA2322")
				l2322 := ExecBlock("MNTA2322",.F.,.F.,{"R"})
				If !l2322
					Return .F.
				EndIf
			EndIf
			cCabec   += STR0038 //" - Recape"
			lStatus  := .T.
			lSaiPneu := .T.
			lRecape  := .T.

		ElseIf nOpcao == nIdSucata
			If ExistBlock("MNTA2322")
				l2322 := ExecBlock("MNTA2322",.F.,.F.,{"S"})
				If !l2322
					Return .F.
				EndIf
			EndIf
			cCabec += STR0039 //" - Sucata"
			M->TQY_STATUS := cNGSTARS
			lStatus  := .F.
			lSaiPneu := .T.
		ElseIf nOpcao == nIdAnalise
			If ExistBlock("MNTA2322")
				l2322 := ExecBlock("MNTA2322",.F.,.F.,{"A"})
				If !l2322
					Return .F.
				EndIf
			EndIf
			cCabec += STR0040 //" - Análise"
			M->TQY_STATUS := cNGSTAAT
			lStatus  := .F.
			lSaiPneu := .T.
		Else //Se clicou no fundo branco
			Return .F.
		EndIf

		cNomSt := NGSEEK('TQY',M->TQY_STATUS,1,'TQY->TQY_DESTAT')

		//Variavel utilizada na consulta F3 TQYPAR
		If nOpcao == nIdRecape
			cFilTQYPAR := "MNTA232TQY('REC')"
		Else
			cFilTQYPAR := "MNTA232TQY('EST')"
		EndIf

	EndIf

	//Faz consistencia dos pneus em troca (Sulco, Medida, DOT, TWI)
	If !Empty(cPneu1) .And. !Empty(nShape)
		If !ConsisPneu(cPneu1,(aShape[nShape][__INFO__])[2],.F.)
			Return .F.
		EndIf
		If !lInvisible .And. nPosPneu1 > 0
			If !ConsisPneu(cPneu2,(aShape[nFocus][__INFO__])[2],.F.)
				Return .F.
			EndIf
		EndIf
	EndIf
	// Verifica se o pneu foi selecionado para Sucata (cNGSTARS)
	If !Empty(cPneu1) .And. M->TQY_STATUS == cNGSTARS
		If !NG232CHKBE( cPneu1 )
			Return .F.
		EndIf
	EndIf

	//Variaveis da validacao do sulco
	cEmpOri  := cEmpAnt
	cHrSulco := cHORALE1

	If AllTrim(cHrSulco) == ":"
		cHrSulco := Substr(Time(),1,5)
	EndIf

	//Utiliza motivo padrao em Rodizio
	If lRodizio
		cMotivo1 := Padr(cMotivPad,Len(cMotivo1))
		cMotivo2 := Padr(cMotivPad,Len(cMotivo2))
	EndIf

	//Se motivos estiverem preenchidos, carrega nome do motivo
	If !Empty(cMotivo1)
		NGPMOT231(cMotivo1,@cNomMot1)
	EndIf

	If !Empty(cMotivo2)
		NGPMOT231(cMotivo2,@cNomMot2)
	EndIf

	If !lOk

		l2326 := .T.
		If ExistBlock("MNTA2326")
			l2326 := ExecBlock("MNTA2326", .F., .F.)
		EndIf

		If l2326
			If !NGLANCON( CPNEU1, DDTDATEM, CHORALE1, CBEMPAI, .F. ) .And. ;
				!MsgYesNo( STR0144 + chr(13)+ STR0145 ) // "Já existe lançamento de contador com data posterior a informada." # "Deseja continuar ?"

				Return .F.
			EndIf
		EndIf
		nCodPneReq := aSCAN( aPneusReq, { | aArray | aArray[ 2 ] == aShape[ nFocus, __CODPNEU__] } )

		If nCodPneReq == 0

			DEFINE MSDIALOG oDlg TITLE OemToAnsi(cCabec) From 0,0 To 180,900 Pixel COLOR CLR_BLACK,CLR_WHITE
			oDlg:lEscClose := .F.
			oPnlPai := TPanel():New(00,00,,oDlg,,,,,,465,195,.F.,.F.)
			oPnlPai:Align := CONTROL_ALIGN_ALLCLIENT

			// Ponto de Entrada que carrega o valor do Sulco do primeiro pneu.
			If ExistBlock( 'MNTA2318' )
				nSulco1 := ExecBlock( 'MNTA2318', .F., .F., { cPneu1, IIf( lSaiPneu, 1, IIf( lTrocaPneu, 2, 3 ) ), nSulco1 } )
			EndIf

			If lSaiPneu

				@nPosY,1		Say OemtoAnsi(STR0041) Of oPnlPai COLOR CLR_HBLUE //"Motivo"
				@nPosY,5.5		MSget cMotivo1 Picture "@!" VALID NGPMOT231(cMotivo1,@cNomMot1) F3 "STN" SIZE 35,10 Of oPnlPai HASBUTTON
				@nPosY,11		MsGet cNomMot1 Picture "@!" SIZE 120,10 Of oPnlPai WHEN .F.

				// Ponto de entrada para carregar Centro de Custo
				If ExistBlock( 'MNTA232B' )
					cCCUSTO := ExecBlock( 'MNTA232B', .F., .F., { cPneu1 } )
					MNTA231CC(cCCUSTO)
				EndIf

				@nPosY,28		Say OemtoAnsi(STR0042) Of oPnlPai COLOR CLR_HBLUE //"Centro de Custo"
				@nPosY,33.5	MsGet cCCUSTO Picture "@!" VALID CTB105CC(cCCUSTO) .And. MNTA231CC(cCCUSTO) F3 "CTT" ;
				SIZE 35,10 HASBUTTON Of oPnlPai WHEN lMoviBem
				@nPosY,40		MsGet cNomCust  Picture "@!" SIZE 120,10 Of oPnlPai WHEN .F.

				nPosY += 1

				@nPosY,1		Say OemtoAnsi(STR0043) Of oPnlPai//"C. Trabalho"
				@nPosY,5.5		MsGet cCentrab Picture "@!" VALID MNTA231CT(cCentrab,cCCUSTO) F3 "NG1" SIZE 35,10 Of oPnlPai HASBUTTON WHEN lMoviBem
				@nPosY,11		MsGet cNomSHB  Picture "@!" SIZE 120,10 Of oPnlPai WHEN .F.

				@nPosY,28		Say OemtoAnsi(STR0044) Of oPnlPai COLOR CLR_HBLUE //"Status"
				@nPosY,33.5	    MsGet M->TQY_STATUS Picture "@!" VALID ValidStatus(M->TQY_STATUS,@cNomSt,cPneu1,lStatus,lOk) F3 "TQYPAR" SIZE 35,10 Of oPnlPai WHEN lStatus HASBUTTON
				@nPosY,40		MsGet cNomSt  Picture "@!" SIZE 120,10 Of oPnlPai WHEN .F.

				nPosY += 1

				@nPosY,1   Say OemtoAnsi(STR0045) Of oPnlPai COLOR CLR_HBLUE  //"Sulco"
				@nPosY,5.5 MsGet nSulco1 Picture "@E 999.99" VALID MNTA231SU(cPneu1,nSulco1,cHrSulco,lValidTwi) SIZE 35,10 Of oPnlPai HASBUTTON

				nPosY += 1

				// Ponto de entrada para carregar Item Conta
				If ExistBlock( 'MNTA232C' )
					cItemCTA := ExecBlock( 'MNTA232C', .F., .F., { cPneu1 } )
					MNTA232CTA()
				EndIf

				@nPosY,1   Say OemtoAnsi(STR0143) Of oPnlPai //"Item Conta"
				@nPosY,5.5 MsGet cItemCTA Picture "@!" VALID MNTA232CTA()  F3 "CTD" SIZE 80,10 Of oPnlPai HASBUTTON
				@nPosY,16  MsGet cNomeCTA Picture "@!" SIZE 120,10 Of oPnlPai WHEN .F.

			ElseIf lTrocaPneu

				@nPosY,1 Say OemtoAnsi(Trim(cPneu1) + STR0046 + Trim((aShape[nFocus][__INFO__])[2]) + STR0047 + Trim((aShape[nShape][__INFO__])[2])) Of oPnlPai COLOR CLR_HRED //" - Localização "###" para "

				nPosY += 0.7
				@nPosY,1   Say OemtoAnsi(STR0041) Of oPnlPai COLOR CLR_HBLUE //"Motivo"
				@nPosY,4.5 MsGet cMotivo1 Picture "@!" VALID NGPMOT231(cMotivo1,@cNomMot1) F3 "STN" SIZE 35,10 Of oPnlPai HASBUTTON
				@nPosY,10  MsGet cNomMot1 Picture "@!" SIZE 120,10 Of oPnlPai WHEN .F.

				@nPosY,28   Say OemtoAnsi(STR0045) Of oPnlPai COLOR CLR_HBLUE //"Sulco"
				@nPosY,31.5 MsGet nSulco1 Picture "@E 999.99" VALID MNTA231SU(cPneu1,nSulco1,cHrSulco,lValidTwi) SIZE 35,10 Of oPnlPai HASBUTTON

				nPosY += 1
				@nPosY,1 Say OemtoAnsi(Trim(cPneu2) + STR0046 + Trim( (aShape[nShape][__INFO__])[2]) + STR0047 + Trim( (aShape[nFocus][__INFO__])[2])) Of oPnlPai COLOR CLR_HRED //" - Localização "###" para "

				nPosY += 0.7
				@nPosY,1   Say OemtoAnsi(STR0041) Of oPnlPai COLOR CLR_HBLUE //"Motivo"
				@nPosY,4.5 MsGet cMotivo2 Picture "@!" VALID NGPMOT231(cMotivo2,@cNomMot2) F3 "STN" SIZE 35,10 Of oPnlPai HASBUTTON
				@nPosY,10  MsGet cNomMot2 Picture "@!" SIZE 120,10 Of oPnlPai WHEN .F.

				@nPosY,28   Say OemtoAnsi(STR0045) Of oPnlPai COLOR CLR_HBLUE //"Sulco"
				@nPosY,31.5 MsGet nSulco2 Picture "@E 999.99" VALID MNTA231SU(cPneu2,nSulco2,cHrSulco,lValidTwi) SIZE 35,10 Of oPnlPai HASBUTTON

			Else
				If lAltLoc
					@nPosY,1 Say OemtoAnsi(Trim(cPneu1) + STR0046 + Trim( (aShape[nFocus][__INFO__])[2]) + STR0047 + Trim((aShape[nShape][__INFO__])[2])) Of oPnlPai COLOR CLR_HRED	 //" - Localização "##" para "
					nPosY += 0.7
					oDlg:nHeight += 15
				ElseIf lArea
					@nPosY,1 Say OemtoAnsi(Trim(cPneu1) + STR0046 + Trim( (aShape[nFocus][__INFO__])[2]) + STR0048) Of oPnlPai COLOR CLR_HRED	 //" - Localização "##" para a Área de Transferência"
					nPosY += 0.7
					oDlg:nHeight += 15
				EndIf

				@nPosY,1   Say OemtoAnsi(STR0041) Of oPnlPai COLOR CLR_HBLUE //"Motivo"
				@nPosY,6.5 MsGet cMotivo1 Picture "@!" VALID NGPMOT231(cMotivo1,@cNomMot1) F3 "STN" SIZE 35,10 Of oPnlPai HASBUTTON
				@nPosY,13  MsGet cNomMot1 Picture "@!" SIZE 120,10 Of oPnlPai WHEN .F.

				nPosY += 1
				@nPosY,1   Say OemtoAnsi(STR0045) Of oPnlPai COLOR CLR_HBLUE //"Sulco"
				@nPosY,6.5 MsGet nSulco1 Picture "@E 999.99" VALID MNTA231SU(cPneu1,nSulco1,cHrSulco,lValidTwi) SIZE 35,10 Of oPnlPai HASBUTTON

				oDlg:nHeight -= 50
			EndIf
			cPneu := cPneu1
			ACTIVATE MSDIALOG oDlg ON INIT EnchoiceBar(oDlg,{|| lOk := .T. ,If(ValidDlgPneu(oDlg,cPneu),oDlg:End(),lOk := .F.)},{|| lOk := .F.,oDlg:End()}) CENTERED
		Else

			// Adiciona valor do sulco do pneu.
			nSulco1 := aPneusReq[ nCodPneReq, __SULCO__ ]
			lOk := .T.

		EndIf

	EndIf

	If lOk
		//Ponto de entrada para fazer validacoes adicionais
		If nPosPneu1 > 0
			nPOSV := nPosPneu1
			If ExistBlock("MNTA2313")
				If !ExecBlock("MNTA2313",.F.,.F.)
					Return .F.
				EndIf
			EndIf
		EndIf

		If lSaiPneu
			nPosPneu1 := aSCAN(aPNEUSINI,{|aArray| aArray[__CODBEM__] == cPneu1})
			nPosPneu2 := aSCAN(aPNEUSFIM,{|aArray| aArray[__CODBEM__] == cPneu1})
			If nPosPneu1 > 0 //Se pneu retirado estava na estrutura inicial
				
				aPNEUSINI[nPosPneu1][__MOTIVO__]  := cMotivo1
				aPNEUSINI[nPosPneu1][__CCUSTO__]  := cCCUSTO
				aPNEUSINI[nPosPneu1][__CENTRAB__] := cCENTRAB
				aPNEUSINI[nPosPneu1][__STATUS__]  := M->TQY_STATUS
				aPNEUSINI[nPosPneu1][__CODESTO__] := cCodST9Est
				aPNEUSINI[nPosPneu1][__LOCPAD__]  := cCodST9Alm
				aPNEUSINI[nPosPneu1][__SULCO__]   := nSulco1
				aPNEUSINI[nPosPneu1][__USUARIO__] := cTZUser
				aPNEUSINI[nPosPneu1][__ITEMCTA__] := cItemCTA
				aPNEUSINI[nPosPneu1][__LOCALIF__] := cCodST9Loc

			EndIf

			If nPosPneu2 > 0
				aPNEUSFIM[nPosPneu2][__CODBEM__]  := ""
				aPNEUSFIM[nPosPneu2][__USUARIO__] := cTZUser
			EndIf

			nPosRod := aSCAN(aRodizio,{|aArray| aArray[1] == cPneu1})

		ElseIf lTrocaPneu
			If nPosPneu1 > 0 .And. nPosPneu2 > 0

				cTempLoc := aPNEUSFIM[nPosPneu1][__LOCALIZ__]
				cTipoEix := aPNEUSFIM[nPosPneu1][__TIPEIXO__]
				cTempEixo:= aPNEUSFIM[nPosPneu1][__EIXO__]

				aPNEUSFIM[nPosPneu1][__MOTIVO__]  := cMotivo1
				aPNEUSFIM[nPosPneu1][__SULCO__]   := nSulco1
				aPNEUSFIM[nPosPneu1][__USUARIO__] := cTZUser

				aTempPneu := aClone(aPNEUSFIM[nPosPneu1])

				aPNEUSFIM[nPosPneu2][__MOTIVO__]  := cMotivo2
				aPNEUSFIM[nPosPneu2][__SULCO__]   := nSulco2
				aPNEUSFIM[nPosPneu2][__USUARIO__] := cTZUser

				aPNEUSFIM[nPosPneu1] := aClone(aPNEUSFIM[nPosPneu2])
				aPNEUSFIM[nPosPneu2] := aClone(aTempPneu)
				aPNEUSFIM[nPosPneu2][__LOCALIZ__] := aPNEUSFIM[nPosPneu1][__LOCALIZ__]
				aPNEUSFIM[nPosPneu1][__LOCALIZ__] := cTempLoc

				aPNEUSFIM[nPosPneu2][__TIPEIXO__] := aPNEUSFIM[nPosPneu1][__TIPEIXO__]
				aPNEUSFIM[nPosPneu1][__TIPEIXO__] := cTipoEix

				aPNEUSFIM[nPosPneu2][__EIXO__] := aPNEUSFIM[nPosPneu1][__EIXO__]
				aPNEUSFIM[nPosPneu1][__EIXO__] := cTempEixo

				aShape[nShape][7][2] := aPNEUSFIM[nPosPneu1][__LOCALIZ__]
				aShape[nFocus][7][2] := aPNEUSFIM[nPosPneu2][__LOCALIZ__]

			ElseIf nPosPneu1 > 0
				cTempLoc := aPNEUSFIM[nPosPneu1][__LOCALIZ__]
				cTipoEix := aPNEUSFIM[nPosPneu1][__TIPEIXO__]
				cTempEixo:= aPNEUSFIM[nPosPneu1][__EIXO__]
				nPosRod  := aSCAN(aRodizio,{|aArray| aArray[1] == aShape[nShape][__CODPNEU__]})
				aPNEUSFIM[nPosPneu1][__MOTIVO__]  := cMotivo1
				aPNEUSFIM[nPosPneu1][__SULCO__]   := nSulco1
				aPNEUSFIM[nPosPneu1][__USUARIO__] := cTZUser
				aTempPneu := aClone(aPNEUSFIM[nPosPneu1])

				aRodizio[nPosRod][4][__MOTIVO__]  := cMotivo2
				aRodizio[nPosRod][4][__SULCO__]   := nSulco2
				aRodizio[nPosRod][4][__USUARIO__] := cTZUser

				aPNEUSFIM[nPosPneu1] := aClone(aRodizio[nPosRod][4])
				aRodizio[nPosRod][4] := aClone(aTempPneu)
				aRodizio[nPosRod][4][__LOCALIZ__] := aPNEUSFIM[nPosPneu1][__LOCALIZ__]
				aPNEUSFIM[nPosPneu1][__LOCALIZ__] := cTempLoc

				aRodizio[nPosRod][4][__TIPEIXO__] := aPNEUSFIM[nPosPneu1][__TIPEIXO__]
				aPNEUSFIM[nPosPneu1][__TIPEIXO__] := cTipoEix

				aRodizio[nPosRod][4][__EIXO__] := aPNEUSFIM[nPosPneu1][__EIXO__]
				aPNEUSFIM[nPosPneu1][__EIXO__] := cTempEixo

				aShape[nFocus][7][2] := aRodizio[nPosRod][4][__LOCALIZ__]
				aShape[nShape][7][2] := aPNEUSFIM[nPosPneu1][__LOCALIZ__]

			Else //Se estiver na area de transferencia

				//Localiza a primeira posicao vazia no aRodizio
				If nPosRod := aSCAN(aRodizio,{|aArray| aArray[1] == cPneu1}) > 0
					nPosRod := aSCAN(aRodizio,{|aArray| aArray[1] == cPneu1})
				Else
					nPosRod := aSCAN(aRodizio,{|aArray| Empty(aArray[1])})
				EndIf

				cTempLoc := aRodizio[nPosRod][4][__LOCALIZ__]
				cTipoEix := aRodizio[nPosRod][4][__TIPEIXO__]
				cTempEixo:= aRodizio[nPosRod][4][__EIXO__]
				aRodizio[nPosRod][4][__MOTIVO__]  := cMotivo1
				aRodizio[nPosRod][4][__SULCO__]   := nSulco1
				aRodizio[nPosRod][4][__USUARIO__] := cTZUser

				aPNEUSFIM[nPosPneu2][__MOTIVO__]  := cMotivo2
				aPNEUSFIM[nPosPneu2][__SULCO__]   := nSulco2
				aPNEUSFIM[nPosPneu2][__USUARIO__] := cTZUser
				aTempPneu := aClone(aPNEUSFIM[nPosPneu2])

				aPNEUSFIM[nPosPneu2] := aClone(aRodizio[nPosRod][4])
				aRodizio[nPosRod][4] := aClone(aTempPneu)
				aPNEUSFIM[nPosPneu2][__LOCALIZ__] := aRodizio[nPosRod][4][__LOCALIZ__]
				aRodizio[nPosRod][4][__LOCALIZ__] := cTempLoc

				aPNEUSFIM[nPosPneu2][__TIPEIXO__] := aRodizio[nPosRod][4][__TIPEIXO__]
				aRodizio[nPosRod][4][__TIPEIXO__] := cTipoEix

				aPNEUSFIM[nPosPneu2][__EIXO__] := aRodizio[nPosRod][4][__EIXO__]
				aRodizio[nPosRod][4][__EIXO__] := cTempEixo

				aShape[nShape][7][2] := aRodizio[nPosRod][4][__LOCALIZ__]
				aShape[nFocus][7][2] := aPNEUSFIM[nPosPneu2][__LOCALIZ__]
			EndIf

		Else
			
			If lAltLoc
				
				If nPosPneu1 > 0 .And. nPosPneu2 > 0
					
					cTempLoc := aPNEUSFIM[nPosPneu1][__LOCALIZ__]
					cTipoEix := aPNEUSFIM[nPosPneu1][__TIPEIXO__]
					cTempEixo:= aPNEUSFIM[nPosPneu1][__EIXO__]
					
					aPNEUSFIM[nPosPneu1][__LOCALIZ__] := aPNEUSFIM[nPosPneu2][__LOCALIZ__]
					aPNEUSFIM[nPosPneu1][__MOTIVO__]  := cMotivo1
					aPNEUSFIM[nPosPneu1][__SULCO__]   := nSulco1
					aPNEUSFIM[nPosPneu1][__USUARIO__] := cTZUser
					
					aPNEUSFIM[nPosPneu2][__LOCALIZ__] := cTempLoc
					aPNEUSFIM[nPosPneu2][__TIPEIXO__] := cTipoEix
					aPNEUSFIM[nPosPneu2][__EIXO__]    := cTempEixo

				ElseIf nPosPneu1 > 0
					nPosRod  := aSCAN(aRodizio,{|aArray| aArray[1] == aShape[nShape][__CODPNEU__]})

					aShape[nFocus][7][2] := aPNEUSFIM[nPosPneu1][__LOCALIZ__]
					aShape[nShape][7][2] := aRodizio[nPosRod][4][__LOCALIZ__]
					aPNEUSFIM[nPosPneu1][__MOTIVO__]  := cMotivo1
					aPNEUSFIM[nPosPneu1][__SULCO__]   := nSulco1
					aPNEUSFIM[nPosPneu1][__USUARIO__] := cTZUser

				ElseIf nPosPneu2 > 0
					nPosRod := aSCAN(aRodizio,{|aArray| aArray[1] == aShape[nFocus][__CODPNEU__]})

					aRodizio[nPosRod][4][__LOCALIZ__] := aPNEUSFIM[nPosPneu2][__LOCALIZ__]
					aRodizio[nPosRod][4][__TIPEIXO__] := aPNEUSFIM[nPosPneu2][__TIPEIXO__]
					aRodizio[nPosRod][4][__EIXO__]    := aPNEUSFIM[nPosPneu2][__EIXO__]
					aRodizio[nPosRod][4][__MOTIVO__]  := cMotivo1
					aRodizio[nPosRod][4][__SULCO__]   := nSulco1
					aRodizio[nPosRod][4][__USUARIO__] := cTZUser

					aPNEUSFIM[nPosPneu2] := aClone(aRodizio[nPosRod][4])
				EndIf

			ElseIf lArea

				aPNEUSFIM[nPosPneu1][__MOTIVO__]  := cMotivo1
				aPNEUSFIM[nPosPneu1][__SULCO__]   := nSulco1

			EndIf

		EndIf

	EndIf

Return lOk

//---------------------------------------------------------------------
/*/{Protheus.doc} MNTA232TQY
Funcao para filtrar consulta SXB TQYPAR
@author Vitor Emanuel Batista
@since 19/08/2009
@version undefined
@param cOpcao, characters,
@type function
@obs Consulta SXB - TQYPAR
/*/
//---------------------------------------------------------------------
Function MNTA232TQY(cOpcao)

	If cOpcao == 'EST'
		If (AllTrim(TQY->TQY_STATUS) $ cNGSTAEU .Or. AllTrim(TQY->TQY_STATUS)  == cNGSTAER .Or.;
		AllTrim(TQY->TQY_STATUS) == cNGSTAEN .Or. AllTrim(TQY->TQY_STATUS)  == cNGSTEST) .And.;
		(Empty(TQY->TQY_CATBEM) .Or. TQY->TQY_CATBEM = '3')
			Return .T.
		EndIf
	Else
		If (AllTrim(TQY->TQY_STATUS) == cNGSTAGR .Or. AllTrim(TQY->TQY_STATUS)  == cNGSTAGC) .And.;
		(Empty(TQY->TQY_CATBEM) .Or. TQY->TQY_CATBEM = '3')
			Return .T.
		EndIf
	EndIf

Return .F.

//---------------------------------------------------------------------
/*/{Protheus.doc} ValidDlgPneu
Valida todo o dialog da entrada/saida do pneu na estrutura
@author Vitor Emanuel Batista
@since 11/08/2009
@version undefined
@param oDlg, object, Objeto oDlg
@param cBemPneu, characters, descricao
@type function
/*/
//---------------------------------------------------------------------
Static Function ValidDlgPneu(oDlg,cBemPneu)

	Local nX
	Local lOk := .T.
	Local lStatMov
	Local aOldArea := GetArea()

	For nX := 1 to Len(oDlg:aControls)
		lOk := Eval(oDlg:aControls[nX]:bValid)
		If ValType(lOk) == "L" .And. !lOk
			Exit
		Else
			lOk := .T.
		EndIf
	Next nX
	//Como essa funcao pode ser chamada em uma situação em que cStatus e/ou cCodST9Est nao existam, entao testa antes pra nao da erro
	If Type("M->TQY_STATUS") == "C" .And. Type("cCodST9Est") == "C" .And. lOk
		//Para caso for status que movimenta estoque
		lStatMov := (M->TQY_STATUS $ cNGSTAEU) .Or. M->TQY_STATUS  == cNGSTAER .Or. M->TQY_STATUS == cNGSTAEN .Or. M->TQY_STATUS  == cNGSTEST .or.;
		M->TQY_STATUS  == cNGSTARS

		lOk := .T. //Validação adicionada devido a não gravação da tela de disponibilização de rodado! SS:.024113.

		//Para caso de estar confirmando a tela de envio do produto para o estoque sem ter preenchido o codigo do produto e for status que movimenta est
		If cUsaIntEs == 'S' .And. AllTrim(GetMV("MV_NGPNEST")) == 'S' .And. Empty(cCodST9Est) .And. lStatMov
			If !(M->TQY_STATUS $ cNGSTAGR+'/'+cNGSTAAT)
				MsgStop(STR0104) //"Informe um código de estoque para destino do Pneu."
			EndIf

			lOk := MNT231DEST(cPneu,M->TQY_STATUS)

			RestArea(aOldArea)

		EndIf

	EndIf

Return lOk

//---------------------------------------------------------------------
/*/{Protheus.doc} ConsisPneu
Faz consistencia do pneu (Medida,DOT,Sulco)
@author Vitor Emanuel Batista
@since 18/08/2009
@version undefined
@param cPneu, characters, Pneu a ser alterado na estrutura
@param cLocaliz, characters, Localizacao na estrutura
@param lConfTela, logical, Verificar se é na confirmação de tela
@param lConfMov, logical, se deve validar uma movimentação posterior
@type function
/*/
//---------------------------------------------------------------------
Static Function ConsisPneu( cPneu, cLocaliz, lConfTela, lConfMov )

	Local nPos,nZ    := 0
	Local nDifSMa    := 0
	Local nDifSMe    := 0
	Local nRecST9    := 0
	Local nPosPneu   := 0
	Local cBemPEs    := ""
	Local cTQSDot    := ""
	Local cCodLoc    := ""
	Local cStatusST9 := NGSEEK('ST9', cPneu, 1,'T9_STATUS')
	Local cAlmoxaST9 := NGSEEK('ST9', cPneu, 1,'T9_LOCPAD')
	Local cEstoquST9 := NGSEEK('ST9', cPneu, 1,'T9_CODESTO')
	Local lTesBan    := .T.
	Local lTransf    := .F. //Usada para saber se o pneu esta na area de transferencia
	Local lPneEst    := GetNewPar('MV_NGPNEST','N') == 'S' // Verifica parametro de controle de estoque do pneu.
	Local aOldEstoq  := {}
	Local aValTWI    := {} //Variavel utilizada para receber informações retornadas da função MNTA231TWI

	Default lConfTela := .F.
	Default lConfMov:= .F.

	cQryAlias := GetNextAlias()
	cQuery := " SELECT TP_DTLEITU,TP_HORA FROM "+RetSqlName( "STP" )
	cQuery += " WHERE TP_CODBEM = '" + NGRETTXT(cPneu) + "'"
	cQuery += " AND TP_TIPOLAN = 'I' "
	cQuery += " AND D_E_L_E_T_ <> '*' "
	cQuery += " ORDER BY TP_DTLEITU,TP_HORA"
	cQuery := ChangeQuery(cQuery)
	dbUseArea( .T., "TOPCONN", TCGenQry(,,cQuery), cQryAlias, .F., .T.)

	dbSelectArea( cQryAlias )
	dbGoTop()
	//Se a data/hora da movimentação do pneu for menor que a STP, OU a data for da mov. for menor que a STP.
	If ( DToS( dDTDATEM ) < (cQryAlias)->TP_DTLEITU ) .Or. ( DToS( dDTDATEM ) == (cQryAlias)->TP_DTLEITU .And. cHORALE1 < (cQryAlias)->TP_HORA )
		MsgStop( STR0111 ) //"A data e hora de inclusão do pneu não pode ser menor que a data e hora da movimentação."
		Return .F.
	EndIf

	nPosPneu := aSCAN(aRodizio,{|aArray| aArray[1] == cPneu})
	lTransf  := nPosPneu > 0

	/*-----------------------------------------------------------------------------------------------------------
	| Caso codigo de produto preenchido, integracao com o estoque, empresa utilizar identificao de bem no estoque|
	| e produto tiver mais de um almoxarifado, chama tela para informar a qual almoxarifado debitar.             |
	-------------------------------------------------------------------------------------------------------------*/
	If lPneEst .And. aScan( aPneusIni, {|x| Alltrim(x[__CODBEM__]) == Alltrim(cPneu)}) == 0 .And. aSCAN( aPneusReq, { | aArray | AllTrim( aArray[ 2 ] ) == Alltrim(cPneu) } ) == 0
		If Empty(cEstoquST9)
			If !lConfTela
				If !MSGYESNO(STR0105+Chr(13)+STR0106+Chr(13); //"Não será efetuado o lançamento de insumo para custeio" ## "do componente ( Pneu ), pois o campo de relacionamento"
				+' ( T9_CODESTO - ' + AllTrim( FWX3Titulo( 'T9_CODESTO' ) ) + ' ) ';
				+STR0107) //"no cadastro de pneu não está prenchido. Deseja continuar ?"
					Return .F.
				EndIf
			EndIf
		EndIf

		If !lConfTela

			If cUsaIntEs == 'S' .And. ( Empty( cEstoquST9 ) .Or. Empty( cAlmoxaST9 ) .Or. ( SuperGetMV( 'MV_LOCALIZ', .F., 'N' ) == 'S' .And.;
				NGSEEK( 'SB1', cEstoquST9, 1, 'B1_LOCALIZ' ) == 'S' .And. Empty( cCodLoc ) ) )

				aOldEstoq  := NG231OLDES(cStatusST9, cEstoquST9, cAlmoxaST9)
				cAlmoxaST9 := aOldEstoq[2]
				cEstoquST9 := aOldEstoq[1]
				cCodLoc    := aOldEstoq[3]

			EndIf

		EndIf

	EndIf

	dbSelectArea("TQS")
	dbSetOrder(1)
	If !dbSeek(xFilial("TQS")+cPneu)
		Help(" ",1,"REGNOIS")
		Return .F.
	EndIf
	nDifSMa := TQS->TQS_SULCAT + nNGDIFSU
	nDifSMe := TQS->TQS_SULCAT - nNGDIFSU

	nPos  := aSCAN(aPNEUSFIM,{|aArray| aArray[__LOCALIZ__] == cLocaliz})
	If nPos >0
		nNumE := aPNEUSFIM[nPos][__EIXO__]
	Else
		Return .T.
	EndIf

	For nZ := 1 to Len(aPNEUSFIM)
		If aPNEUSFIM[nZ][__EIXO__] == nNumE
			If !Empty(aPNEUSFIM[nZ][__CODBEM__])
				// Consistencia do pneu posicionado em relação aos demais da estrutura
				If aPNEUSFIM[nZ][__CODBEM__] != cPneu

					// CONSISTENCIA DA MEDIDA
					If !lConfTela
						If aPNEUSFIM[nZ][__MEDIDA__] <> TQS->TQS_MEDIDA
							If !MSGYESNO(STR0049+Trim(cPneu)+STR0050+Chr(13)+STR0051) //"Pneu "###" não tem a mesma medida dos demais"###"Confirmar ?"
								Return .F.
							Else
								Exit
							Endif
						Endif
					EndIf

					// CONSISTENCIA DO SULCO
					If aPNEUSFIM[nZ][__SULCO__] < nDifSMe .And. aPNEUSFIM[nZ][__SULCO__] > nDifSMa
						If !MSGYESNO(STR0052+Trim(cPneu)+STR0053+Chr(13)+STR0051) //"Profundidade do sulco do pneu "###" está diferente dos demais pneus"##"Confirmar ?"
							Return .F.
						Else
							Exit
						Endif
					Endif
				Else // Consistem o pneu posicionado.
					//CONSISTE SE O SULCO É VALIDO PARA o LIMITE TWI
					If FindFunction("MNTA231TWI")

						aValTWI := MNTA231TWI(cPneu, .T., aPNEUSFIM[nZ][__SULCO__])

						If !aValTWI[1]
							MsgInfo(aValTWI[2], STR0009) //Anteção
							Return .F.
						EndIf

					EndIf
				Endif
			EndIf
		Endif
	Next

	// CONSISTENCIA DO TIPO DE EIXO
	If Val(aPNEUSFIM[nPos][__TIPEIXO__]) > 2
		If !lTEMCONT
			cBemPEs := NGBEMPAI(cPneu)
			If !Empty(cBemPEs)
				dbSelectArea("ST9")
				nRecST9 := Recno()
				dbSetOrder(1)
				If dbSeek(xFilial("ST9")+cBemPES)
					lTesBan := If(ST9->T9_TEMCONT = "S",.T.,.F.)
				Endif
				Dbgoto(nRecST9)
			Endif
		Endif

		If lTesBan
			If TQS->TQS_BANDAA <> '1'
				If !MSGYESNO(STR0054+Trim(cPneu)+STR0055+Chr(13)+STR0051) //"Banda do pneu "###" está diferente da original"##"Confirmar ?"
					Return .F.
				Endif
			Endif
		Endif
	Endif

	// CONSISTENCIA DO DOT
	cTQSDot := StrZero(Val(SuBstr(TQS->TQS_DOT,3,2))+5,2)+SuBstr(TQS->TQS_DOT,1,2)
	If cSemMov > cTQSDot
		If !MSGYESNO(STR0049+Trim(cPneu)+STR0056+Chr(13)+STR0051) //"Pneu "##" com data de validade vencida"##"Confirmar ?"
			Return .F.
		Endif
	Endif

	// Verifica se há uma movimentação posterior
	// Essa validação é necessária para um pneu novo na estrutura
	If lConfMov .And. !NGCONSTZ( cPneu, DDTDATEM, CHORALE1, "E", '' )
		Return .F.
	EndIf

	//Permite realizar validações adicionais relacionados ao pneu e a localização
	If ExistBlock("MNTA2324")
		If !ExecBlock("MNTA2324",.F.,.F.,{cPneu,cLocaliz, aPNEUSFIM})
			Return .F.
		EndIf
	Endif

	//Apos a consistencia, joga o valor do almoxarifado para a posicao correspondente no array
	If !lConfTela
		aPNEUSFIM[nPos][__LOCPAD__]  := cAlmoxaST9
		aPNEUSFIM[nPos][__CODESTO__] := cEstoquST9
		aPNEUSFIM[nPos][__LOCALIF__] := cCodLoc
	EndIf

Return .T.

//---------------------------------------------------------------------
/*/{Protheus.doc} ValidStatus
Valida campo status no dialog de disponibilizar pneu
@author Vitor Emanuel Batista
@since 11/08/2009
@version undefined
@param cStatus, characters, Status informado
@param cNomSt, characters, Descricao do Status (Referencia)
@param cCompone, characters, Componente (Pneu)
@param lStatus, logical, Se o campo Status esta bloqueado
@param lOk, logical, Se foi clicado no Ok do menubar
@type function
/*/
//---------------------------------------------------------------------
Static Function ValidStatus(cStatus,cNomSt,cCompone,lStatus,lOk)

	If !lStatus
		Return .T.
	EndIf

	cNomSt := Space(30)

	If lRecape
		If cStatus != cNGSTAGR .And. cStatus != cNGSTAGC
			Help(" ",1,"REGNOIS")
			Return .F.
		EndIf
	Else
		If !(cStatus $ cNGSTAEU) .And. cStatus  != cNGSTAER .And. cStatus != cNGSTAEN .And. cStatus  != cNGSTEST
			Help(" ",1,"REGNOIS")
			Return .F.
		EndIf
	EndIf

	If !ExistCpo("TQY",cStatus)
		Return .F.
	Endif

	cNomSt := NGSEEK('TQY',M->TQY_STATUS,1,'TQY->TQY_DESTAT')

	If cUsaIntEs == 'S' .And. AllTrim(GetMV("MV_NGPNEST")) == 'S' .And. !lOk .And. !lRecape
		MNT231DEST(cCompone,cStatus)
	EndIf

Return .T.

//---------------------------------------------------------------------
/*/{Protheus.doc} RodPopUp
Monta o Menu PopUP
@author Vitor Emanuel Batista
@since 28/07/2008
@version undefined
@param oMenu, object, Objeto do Menu
@type function
/*/
//---------------------------------------------------------------------
Static Function RodPopUp(oMenu)

	oMenu := TMenu():New(0,0,0,0,.T.,,Nil)
	If !FindFunction("MNTC125")
		oMenu:Add(TMenuItem():New(oMenu:Owner(),STR0057,,,,{|| DetalhePneu() },,"DBG10",,,,,,,.T.)	) //"Composição"
	Else
		oMenu:Add(TMenuItem():New(oMenu:Owner(),STR0091,,,,{|| MNTC125(aShape[nFocus][__CODPNEU__]) },,"DBG10",,,,,,,.T.)	) //'Consulta Pneu'
	EndIf
	oMenu:Add(TMenuItem():New(oMenu:Owner(),STR0058,,,,{|| MNC600ORD(aShape[nFocus][__CODPNEU__])},,"NGOSVERMELHO",,,,,,,.T.)) //"Ordem de Servico"
	oMenu:Add(TMenuItem():New(oMenu:Owner(),STR0059,,,,{|| MNTA080SUH(aShape[nFocus][__CODPNEU__])},,'PAPEL_ESCRITO',,,,,,,.T.)) //"Histórico de Sulco"

	//Permite Adicionar novas opções no clique da direita
	If ExistBlock("MNTA2325")
		ExecBlock("MNTA2325",.F.,.F., {oMenu})
	Endif

Return

//---------------------------------------------------------------------
/*/{Protheus.doc} MNTA232IMG
Verifica imagens no repositorio e exporta.
@author Vitor Emanuel Batista
@since 25/06/2009
@version undefined
@param aImg, array, descricao
@type function
/*/
//---------------------------------------------------------------------
Function MNTA232IMG(aImg)

	Local nX, nY
	Local lRet     := .T.

	Local cBARRAS  := If(isSRVunix(),"/","\")
	Local cTemp    := GetTempPath() //"C:"+cBARRAS+"Temp"+cBARRAS
	Local cRodados := cTemp+"rodados"+cBARRAS
	Local cExtImg  := ".PNG"

	Local aTypeEstru	:= NGRETESTRU()
	Local aTypePneu		:= NGRETPNEUS()
	Local aAllImg		:= {	"NG_RODADOS_ANALISE","NG_RODADOS_ESTOQUE"	,"NG_RODADOS_PLACA"	,;
								"NG_RODADOS_RECAPE"	,"NG_RODADOS_SUCATA"	, "NG_CALOTA" 		,;
								"ng_rodados_logo_mercosul"		,"ng_rodados_merc_band_arg"		,;
					  			"ng_rodados_merc_band_pry"		,"ng_rodados_merc_band_ury"		,;
								"ng_rodados_merc_band_ven"		,"ng_rodados_mercosul_placa"	,;
								"ng_rodados_russia_band"		,"ng_rodados_russia_placa"		,;
								"ng_rodados_merc_band_bra"      ,"NG_PNEU_VAZIO"                ,;
								"NG_PNEU_MEDICAO" }

	Local aPneus		:= {	"NG_PNEU_PRETO_CLARO_"		,"NG_PNEU_PRETO_ESCURO_"	,;
								"NG_PNEU_VERMELHO_CLARO_"	,"NG_PNEU_VERMELHO_ESCURO_"	,;
								"NG_PNEU_VERDE_CLARO_"		,"NG_PNEU_VERDE_ESCURO_"	,;
								"NG_PNEU_LARANJA_CLARO_"	,"NG_PNEU_LARANJA_ESCURO_"	,;
								"NG_PNEU_AZUL_CLARO_"		,"NG_PNEU_AZUL_ESCURO_"	    }


	Local aEstruturas := {"NG_ESTRUTURA_"}

	Default aImg := {}

	//Verifica se é linux para tratar o caminho
	If GetRemoteType() == REMOTE_QT_LINUX .and. At(":",cTemp)==0
		cTemp := "l:" + cTemp   //Adiciona "l:"  ao inicio do caminho
	EndIf
	//Verifica se é linux para tratar o caminho
	If GetRemoteType() == REMOTE_QT_LINUX .and. At(":",cRodados)==0
		cRodados := "l:" + cRodados   //Adiciona "l:"  ao inicio do caminho
	EndIf

	//Inclui todas as imagens verificando os tipos existentes (NGRETPNEUS)
	For nX := 1 to Len(aTypePneu)
		For nY := 1 to Len(aPneus)
			aAdd(aAllImg,aPneus[nY]+aTypePneu[nX][1])
		Next nY
	Next nX

	For nX := 1 to Len(aTypeEstru)
		aAdd(aAllImg,aEstruturas[1]+aTypeEstru[nX][1])
	Next nX

	For nX := 1 To Len(aImg)
		aAdd(aAllImg,aImg[nX])
	Next nX

	//Cria Pasta Temp
	If !ExistDir(cTemp)
		MakeDir(cTemp)
	EndIf

	//Cria pasta no Temp
	If !ExistDir(cRodados)
		MakeDir(cRodados)
	EndIf

	ProcRegua(Len(aAllImg))

	For nX := 1 to Len(aAllImg)

		IncProc(STR0060+Transform((nX*100)/Len(aAllImg),"@E 999.99")+"%" ) //"Processando.. "

		//Se não existir a imagem, exporta do RPO
		If !File(cRodados+aAllImg[nX]+cExtImg)
			//Exporta imagens do RPO para a pasta especificada
			If !Resource2File(aAllImg[nX]+cExtImg,cRodados+aAllImg[nX]+cExtImg)
				lRet := .F.
				Exit
			EndIf
		EndIf
	Next nX

Return lRet

//---------------------------------------------------------------------
/*/{Protheus.doc} VldOpenRod
Valida abertura do programa de Rodados
@author Vitor Emanuel Batista
@since 05/08/2009
@version undefined
@param lOpened, logical, ndica que o sistema nao estava aberto
@param cOrdem, characters, Ordem de Servico
@param cPlano, characters, Plano da O.S
@return .T. Indica que esta tudo Ok / .F. ha problemas
@type function
/*/
//---------------------------------------------------------------------
Static Function VldOpenRod(lOpened,cOrdem,cPlano)

	Local lOkImg := .F.
	Local lFoundEP := .F.

	If !lOpened
		//Inicializa variaveis (chumbado)
		dbSelectArea("STJ")
		dbSetOrder(2)
		dbSeek(xFilial("STJ")+"BEXT004          PNEMOV")
		dbSelectArea("ST9")
		dbSetOrder(1)
		dbSeek(xFilial("ST9")+STJ->TJ_CODBEM)
	Else
		dbSelectArea("STJ")
		dbSetOrder(1)
		If !dbSeek(xFilial("STJ")+cOrdem+cPlano)
			MsgStop(STR0061,STR0062) //"Ordem de Serviço não encontrada"###"NÃO CONFORMIDADE"
			Return .F.
		EndIf

		dbSelectArea("ST9")
		dbSetOrder(1)
		dbSeek(xFilial("ST9")+STJ->TJ_CODBEM)
	EndIf

	dbSelectArea("TQ0")
	dbSetOrder(1)

	If lRel12133
		lFoundEP := MNTSeekPad( 'TQ0', 1, ST9->T9_CODFAMI, ST9->T9_TIPMOD ) .And. !Empty(TQ0->TQ0_CODEST)
	Else
		lFoundEP := dbSeek(xFilial("TQ0")+ST9->T9_CODFAMI+ST9->T9_TIPMOD) .And. !Empty(TQ0->TQ0_CODEST)
	EndIf

	If !lFoundEP
		ShowHelpDlg(STR0009,	{STR0063},1,; //"ATENÇÃO"###"Não existe o Esquema Padrão gráfico cadastrado."
		{STR0064},1) //"Cadastre um Esquema Padrão Mod 2 para utilizar esta rotina."
		Return .F.
	EndIf

	dbSelectArea("TQ1")
	dbSetOrder(1)
	If !dbSeek(xFilial('TQ1')+TQ0->TQ0_DESENH+TQ0->TQ0_TIPMOD)
		ShowHelpDlg(STR0009,	{STR0065+Trim(ST9->T9_CODFAMI)+STR0066+TQ0->TQ0_TIPMOD},1,; //"ATENÇÃO"##"Nao Existe Itens Para Esquema de Rodado "###" Modelo "
		{STR0067},1)	 //"Cadastre os Itens em Esquema Padrão Mod 2 para utilizar esta rotina."
		Return .F.
	EndIf

	Processa({ |lEnd| lOkImg := MNTA232IMG() },STR0070)	 //"Aguarde.. Exportando Imagens..."
	If !lOkImg //Verifica imagens no RPO e exporta para pasta no Temp
		MsgStop(	STR0071+CHR(13)+CHR(13)+; //"Existem algumas imagens necessárias para a utilização desta rotina que não foram encontradas."
		STR0072,STR0062) //"Favor alertar o administrador para que o sistema seja atualizado corretamente."##"NÃO CONFORMIDADE"
		Return .F.
	EndIf

Return .T.

//---------------------------------------------------------------------
/*/{Protheus.doc} EntraPneu
Abre janela F3 com os pneus disponiveis para a estrutura
@author Vitor Emanuel Batista
@since 07/08/2009
@version undefined
@param oPanel, object, Objeto TPaintPanel selecionado
@param nShape, numeric, Posicao da array aShape do pneu selecionado
@type function
/*/
//---------------------------------------------------------------------
Static Function EntraPneu(oPanel,nShape)

	Local lCONDP, cCodPneu, nPosPneu
	Local nIdPneu  := aShape[nShape][__IDPNEU__]
	Local nImgX    := aShape[nShape][__IMGX__]
	Local nImgY    := aShape[nShape][__IMGY__]
	Local nIdTxt   := aShape[nShape][__ARRTXT__][__IDTXT__]
	Local lEstepe  := aTail(aShape[nShape])[__ESTEPE__]
	Local aInfo    := aClone(aShape[nShape][__INFO__])
	Local cType    := aShape[nShape][__TYPE__]
	Local nX       := 0

	Private cFilFami   := aInfo[1] //Familia da localização do pneu em sua estrutura. Utilizado na consulta padrão de pneus.

	If lRodizio .Or. lCanibal
		MsgStop(STR0073+"("+cNGSERPN+")",STR0009) //"Será possível incluir um pneu da estrutura somente para Serviço de Movimentação de Pneus ("##"Atenção"
		Return .F.
	EndIf

	//Deleta os Pneus ja aplicados na estrutura
	For nX := 1 to Len(aPNEUSFIM)

		If !Empty(aPNEUSFIM[nx][__CODBEM__])
			dbSelectArea(cAliQryTQI)
			dbSetOrder(1)
			If dbSeek(aPNEUSFIM[nx][__CODBEM__])
				Reclock(cAliQryTQI,.F.)
				Dbdelete()
				MsUnlock()
			EndIf
		EndIf

	Next nX

	//Deleta os Pneus enviados para rodizio
	For nX := 1 to Len(aRodizio)

		If !Empty(aRodizio[nx][1])
			dbSelectArea(cAliQryTQI)
			dbSetOrder(1)
			If dbSeek(aRodizio[nx][1])
				Reclock(cAliQryTQI,.F.)
				Dbdelete()
				MsUnlock()
			EndIf
		EndIf

	Next nX

	dbSelectArea("ST6")
	lCONDP := CONPAD1(NIL,NIL,NIL,"PNEUOS",NIL,NIL,.F.)

	If lCONDP

		If !Empty(ST9->T9_CODBEM) .And. ConsisPneu( ST9->T9_CODBEM, aInfo[2], .F., .T. )
			cCodPneu := ST9->T9_CODBEM
			cToolTip := Trim(cCodPneu) + " - " + Trim(ST9->T9_NOME)
			NGCriaPneu(@oPanel,nImgX,nImgY,cType,cCodPneu,NGSEEK("TQS",cCodPneu,1,"Val(TQS->TQS_BANDAA)"),lEstepe,.F.,.F.,aInfo,cToolTip)
			nPosPneu := aSCAN(aPNEUSFIM,{|aArray| aArray[__LOCALIZ__] == aInfo[2]})
			aPNEUSFIM[nPosPneu][__CODBEM__]  := ST9->T9_CODBEM
			aPNEUSFIM[nPosPneu][__CODFAMI__] := ST9->T9_CODFAMI
			aPNEUSFIM[nPosPneu][__MEDIDA__]  := TQS->TQS_MEDIDA
			aPNEUSFIM[nPosPneu][__SULCO__]   := TQS->TQS_SULCAT
			aPNEUSFIM[nPosPneu][__BANDA__]   := TQS->TQS_BANDAA
			aPNEUSFIM[nPosPneu][__DOT__]     := TQS->TQS_DOT
			aPNEUSFIM[nPosPneu][__MOTIVO__]  := Space(Len(aPNEUSFIM[nPosPneu][__MOTIVO__]))
			aPNEUSFIM[nPosPneu][__CCUSTO__]  := ST9->T9_CCUSTO
			aPNEUSFIM[nPosPneu][__CENTRAB__] := ST9->T9_CENTRAB
			
			aDel( aShape, nShape )
			aSize( aShape, Len( aShape ) - 1 )

			oPanel:DeleteItem(nIdPneu)
			oPanel:DeleteItem(nIdTxt)

			//Se o pneu nao estava na estrutura eh necessario preencher informacoes sobre Almoxarifado, Lote, SubLote,Localizacao, Data Validade
			If aSCAN(aPNEUSINI,{|aArray| aArray[__CODBEM__] == cCodPneu}) == 0
				NGIFDBSEEK("ST9",cCodPneu,1)
				If AllTrim(GetMV("MV_NGMNTES")) == 'S' .And. !Empty(st9->t9_codesto) .And. ;
				AllTrim(GetMV("MV_RASTRO")) == 'S' .And. AllTrim(GetMV("MV_LOCALIZ")) == 'S' .And. ;
				NGSEEK('SB1',ST9->T9_CODESTO,1,"B1_RASTRO") = "S"
					MNTA231LL(cCodPneu,nPosPneu)
				Endif
			EndIf
		EndIf
	EndIf
Return

//---------------------------------------------------------------------
/*/{Protheus.doc} NGFILT232
Faz valicoes para a consulta generica NGPNEU.

@author	Vitor Emanuel Batista - Elynton Fellipe Bazzo
@since		05/08/2009 - 16/06/2015
@version	MP12
@return	lRet
/*/
//---------------------------------------------------------------------
Function NGFILT232()

	Local lRet := .F.

	//Verifica se o pneu está contido na Área de Transferência.
	Local lTransf := IIF( lRodzSXB, .T., IIF (cPrograma == "MNTA232", aSCAN(aRodizio,{|aArray| aArray[1] == ST9->T9_CODBEM }) == 0, .F. ) )

	//Verifica se o pneu está contido na própria estrutura.
	Local lEstrut := IIF( lRodzSXB, .T., IIF (cPrograma == "MNTA232", aSCAN(aPNEUSFIM,{|aArray| aArray[__CODBEM__] == ST9->T9_CODBEM}) == 0, .F. ) )

	If ST9->T9_SITBEM == 'A' .AND. ST9->T9_CATBEM == '3'

		If Type( "cPrograma" ) = "C" .And. cPrograma == "MNTA232"
			lTransf := IIF( lRodzSXB , .T. , aSCAN(aRodizio,{|aArray| aArray[1] == ST9->T9_CODBEM }) == 0 )

			lEstrut := IIF( lRodzSXB , .T. , aSCAN(aPNEUSFIM,{|aArray| aArray[__CODBEM__] == ST9->T9_CODBEM}) == 0 )
			//Se pneu estava ma estrutura mas foi retirado
			If aSCAN(aPNEUSINI,{|aArray| aArray[__CODBEM__] == ST9->T9_CODBEM}) > 0 .And. ;
			aSCAN(aPNEUSFIM,{|aArray| aArray[__CODBEM__] == ST9->T9_CODBEM}) == 0 .And.;
			aSCAN(aRodizio,{|aArray| aArray[1] == ST9->T9_CODBEM }) == 0
				lRet := .T.
			ElseIf ST9->T9_ESTRUTU == 'N' .And. ST9->T9_CODFAMI == cFilFami .And. ST9->T9_SITBEM == "A" .And. NGFILT231() .And. lTransf .And. lEstrut
				lRet := .T.
			EndIf
		Else

			lRet := .T.

		EndIf

	EndIf

Return lRet

//---------------------------------------------------------------------
/*/{Protheus.doc} DetalhePneu
Mostra detalhe do pneu selecionado no clique da direita
@author Vitor Emanuel Batista
@since 13/08/2009
@version undefined
@type function
/*/
//---------------------------------------------------------------------
Static Function DetalhePneu()

	Local oDlg

	If nFocus == Nil
		Return
	EndIf

	DEFINE MsDIALOG oDlg TITLE STR0074 From 30,20 To 34.5,80 COLOR CLR_BLACK,CLR_WHITE //"Composicao do rodado do esquema"
		@0.2,0.5 SAY STR0075	+ Alltrim(aShape[nFocus][__CODPNEU__])	+'  -  '+ NGSEEK("ST9",aShape[nFocus][__CODPNEU__],1,"ST9->T9_NOME")	Of oDlg //"Rodado.........: "
		@0.9,0.5 SAY STR0076	+ Alltrim(aShape[nFocus][7][1])			+'  -  '+ NGSEEK("ST6",aShape[nFocus][7][1],1,"ST6->T6_NOME")				Of oDlg //"Família...........: "
		@1.6,0.5 SAY STR0077	+ Alltrim(aShape[nFocus][7][2])			+'  -  '+ NGSEEK("TPS",aShape[nFocus][7][2],1,"TPS->TPS_NOME")			Of oDlg //"Localização..: "
	ACTIVATE MsDIALOG oDlg Centered

Return

//---------------------------------------------------------------------------
/*/{Protheus.doc} MNTA232FIM
Consistencia Final para dados serem gravados
@type function

@author Vitor Emanuel Batista
@since 14/08/2009

@sample MNTA232FIM()

@param	[lFinalOS], Lógico, Define se a OS foi finalizada.
@return .T.
/*/
//---------------------------------------------------------------------------
Function MNTA232FIM( lFinalOS )

	Local nX          := 0
	Local nPos        := 0
	Local nCountSTZ   := 0
	Local aARRAYSTC   := {}
	Local cHRTROCL    := ''
	Local cQuery      := ''
	Local cQryAlias   := ''
	Local lPneuNovo   := .F.
	Local lAlterou    := .F.
	Local aArea       := GetArea()

	Private lEfetLanc := .T.

	Default lFinalOS  := .F.

	If !Eval(bVldCabec)
		Return .F.
	EndIf

	If !lFinalOS
		If lTEMCONT .And. (nPOSCONT > 0 .Or. fCheckCont(1) )
			If !(MNTA231VCO(If(lPai,cPaiEst,cBemPai),nPOSCONT,1) .And. MNTA231HIS(nPOSCONT,cHORALE1,1,.T.,If(lPai,cPaiEst,cBemPai)))
				Return .F.
			EndIf
		EndIf
		If lTEMCON2 .And. (nPOSCON2 > 0 .Or. fCheckCont(2))
			If!(MNTA231VCO(cBemPai,nPOSCON2,2) .And. MNTA231HIS(nPOSCON2,cHORALE2,2,.T.,cBemPai))
				Return .F.
			EndIf
		EndIf
	EndIf

	//Verifica se ha pneus na Area de Transferencia
	nPos := aScan(aRodizio,{|aArray| !Empty(aArray[1]) })
	If nPos > 0
		MsgStop(STR0078,STR0062) //"Ainda existem pneus na Área de Transferência."##"NÃO CONFORMIDADE"
		Return .F.
	EndIf

	dbSelectArea("STJ")
	dbSetOrder(1)
	dbSeek(xFilial("STJ")+cNumOS+cNumPL)

	If !lCanibal
		dbSelectArea("STC")
		dbSetOrder( 01 )
		If dbSeek(xFilial("STC")+cCodFami)
			While !Eof() .And. STC->TC_FILIAL == xFilial( "STC" ) .And. AllTrim( STC->TC_CODBEM ) == AllTrim( cCodFami )
				If STC->TC_TIPOEST == 'F' .And. STC->TC_TIPMOD = cTipMod
					Aadd(aARRAYSTC,{STC->TC_LOCALIZ,STC->TC_OBRIGAT})
				Endif
				dbskip()
			EndDo
		Endif

		//Valida se todos os pneus obrigatorios foram preenchidos
		For nX := 1 to Len(aPNEUSFIM)
			nPos := ASCAN(aARRAYSTC,{|aArray| aArray[1] == aPNEUSFIM[nX][__LOCALIZ__]})
			If nPos > 0
				If Empty(aPNEUSFIM[nX][__CODBEM__]) .And. aARRAYSTC[nPos][2] = 'S'
					MsgInfo(STR0079+Trim(aARRAYSTC[nPos][1]),STR0062) //"Não foi informado rodado para a localização "##"NÃO CONFORMIDADE"
					Return .F.
				Endif
			Endif
		Next nX

		//Hora da entrada para o comp que trocou de localizacao
		cHRTROCL := If(Alltrim(cHORALE1) = ":",cHRTIME1M,MTOH(HTOM(SubStr(cHORALE1,1,5))+1))
		If cHRTROCL = "24:00"
			cHRTROCL := "00:00"
		EndIf
		//Data da entrada para o comp que trocou de localizacao
		dDTROCLO := If(Alltrim(cHRTROCL) = "00:00",dDTDATEM+1,dDTDATEM)
		//Hora para o componente que saiu ou entrou na estrutura
		cHORAESA := If(Alltrim(cHORALE1) = ":",cHRTIME,Substr(cHORALE1,1,5))

		//Le a estrutura final
		For nX := 1 To Len(aPNEUSFIM)

			If !Empty(aPNEUSFIM[nX][__CODBEM__])
				nPos := ASCAN(aPNEUSINI,{|x| x[__CODBEM__] == aPNEUSFIM[nX][__CODBEM__]})
				If nPos > 0 //Componente ja existente na estrutura

					If aPNEUSINI[nPos][__LOCALIZ__] <> aPNEUSFIM[nX][__LOCALIZ__] ///Troco de Localizacao

						//Consiste a movimentacao do componente valida para a saida da localizacao inicial
						If !NGCONSTZ(aPNEUSFIM[nX][__CODBEM__],dDTDATEM,cHORAESA, ,aPNEUSINI[nPos][__LOCALIZ__])
							Return .F.
						EndIf

						//Consiste a movimentacao do componente valida para a entrada da localizacao final
						If !NGCONSTZ(aPNEUSFIM[nX][__CODBEM__],dDTROCLO,cHRTROCL,"E",aPNEUSFIM[nX][__LOCALIZ__])
							Return .F.
						EndIf
					EndIf
				Else //Componente novo adicionado na estrutura
					lPneuNovo := .T. //Indica que foi adicionado um pneu
					//Consiste a movimentacao do componente valida para a entrada na estrutura
					If !NGCONSTZ(aPNEUSFIM[nX][__CODBEM__],dDTDATEM,cHORAESA,"E",aPNEUSFIM[nX][__LOCALIZ__])
						Return .F.
					EndIf

				Endif
			Else
				nPos := ASCAN(aPNEUSINI,{|x| x[__LOCALIZ__] == aPNEUSFIM[nX][__LOCALIZ__]})
				If !Empty(aPNEUSINI[nX][__CODBEM__])
					lPneuNovo := .T. //Indica que foi retirado um pneu
				EndIf
			EndIf

		Next nX

		//Le a estrutura inicial
		For nX := 1 To Len(aPNEUSINI)
			If !Empty(aPNEUSINI[nX][__CODBEM__])
				nPos := ASCAN(aPNEUSFIM,{|x| x[__CODBEM__] == aPNEUSINI[nX][__CODBEM__]})
				If nPos = 0 //Componente que saiu da estrutura inicial
					//Consiste a movimentacao do componente valida para a saida
					If !NGCONSTZ(aPNEUSINI[nX][__CODBEM__],dDTDATEM,cHORAESA, ,aPNEUSINI[nX][__LOCALIZ__])
						Return .F.
					EndIf
				EndIf
			EndIf
		Next nX

		//Le a estrutura final e separa o novo componente e verifica e esta em outro estrutura
		For nX := 1 To Len(aPNEUSFIM)
			If !Empty(aPNEUSFIM[nX][__CODBEM__])
				If !ConsisPneu(aPNEUSFIM[nX][__CODBEM__],aPNEUSFIM[nX][__LOCALIZ__],.T.)
					Return .F.
				EndIf
				lEfetLanc := .F.
				nPosN := ASCAN(aPNEUSINI,{|x| x[__CODBEM__] == aPNEUSFIM[nX][__CODBEM__]})
				If nPosN = 0
					If NGIFDBSEEK("STC",aPNEUSFIM[nX][__CODBEM__],3)

						NGIFDBSEEK("TQS",aPNEUSFIM[nX,__CODBEM__],1)
						MsgInfo(STR0099+Chr(13)+Chr(13)+;
						STR0100+" "+STR0101+Chr(13)+;
						STR0095+" "+STC->TC_CODBEM+Chr(13)+;
						STR0098+" "+aPNEUSFIM[nX,__CODBEM__]+Chr(13)+;
						STR0096+" "+TQS->TQS_EIXO+Chr(13)+;
						STR0097+" "+TQS->TQS_POSIC+Chr(13)+Chr(13)+;
						STR0100+" "+STR0102+Chr(13)+;
						STR0095+" "+cBEM+Chr(13)+;
						STR0098+" "+aPNEUSFIM[nX,__CODBEM__]+Chr(13)+;
						STR0096+" "+Str(aPNEUSFIM[nX,__EIXO__],2)+Chr(13)+;
						STR0097+" "+aPNEUSFIM[nX,__LOCALIZ__],STR0062)
						Return .F.
					EndIf
				EndIf
			EndIf
		Next nX

	EndIf

	//Verifica se houve alteracoes na estrutura
	For nX := 1 to Len(aPNEUSINI)
		nPos := aScan(aPNEUSFIM,{|aArray| aArray[__CODBEM__] == aPNEUSINI[nX][__CODBEM__]})
		If nPos == 0
			lAlterou := .T.
			Exit
		Else
			If aPNEUSINI[nX][__LOCALIZ__] <> aPNEUSFIM[nPos][__LOCALIZ__]
				lAlterou := .T.
				Exit
			Endif
		Endif
	Next nX

	//Alterado local dessa validação para ocorra somente após verificar se houve rodízio (lAlterou). Visto a necessidade de quando for Movimentação
	//de pneus aceite também o rodízio.
	If !lPneuNovo .And. lDisponi .And. !lAlterou .And. !lCanibal

		//Verifica se nesta O.S ja foram colocados ou retirados pneus na estrutura, permitindo assim fazer somente rodizio.
		cQryAlias := GetNextAlias()
		cQuery    := " SELECT COUNT(*) AS COUNT "
		cQuery    += "   FROM " + RetSqlName("STZ")
		cQuery    += "  WHERE TZ_ORDEM = " +  ValToSql(cNumOS)
		cQuery	  += "	  AND TZ_PLANO = " +  ValToSql(cNumPL)
		cQuery    += "    AND D_E_L_E_T_ = ''"
		cQuery    := ChangeQuery(cQuery)
		dbUseArea( .T., "TOPCONN", TCGenQry(,,cQuery), cQryAlias, .F., .T.)
		nCountSTZ := (cQryAlias)->COUNT
		(cQryAlias)->(dbCloseArea())

		If nCountSTZ == 0
			MsgStop(STR0080,STR0062) //"Para serviço do tipo Movimentação, deverá ser retirado/adicionado pelo menos um pneu da estrutura."##"NÃO CONFORMIDADE"
			RestArea(aArea)
			Return .F.
		EndIf

	EndIf

	// Caso não sejam encontradas movimentaçãoes para a estrutura, verifica então se a o.s. em questão
	// efetuou alguma movimentação anteriormente nessa estrutura, permitindo então que a o.s. seja finalizada
	If !lAlterou
		lAlterou := fBuscaAlt()
	EndIf

	If !lAlterou
		MsgStop(STR0081,STR0062) //"Não foram feitas alterações na estrutura."##"NÃO CONFORMIDADE"
		RestArea(aArea)
		Return .F.
	EndIf

	// Aviso de movimentação retroativa
	If NGHISTRETR(cBemPai,dDTDATEM,cHORALE1,1,xFilial("STP")) .And. ;
		!MsgYesNo( STR0144 + chr(13) + STR0146 + chr(13) + chr(13) + STR0145 ) //"Já existe lançamento de contador com data posterior a informada."
			//"Como este apontamento influenciará nos demais itens da estrutura o processo poderá ser demorado dependendo da quantidade de registros."
			// "Deseja continuar ?"
		Return .F.
	EndIf

	RestArea(aArea)
Return .T.

//---------------------------------------------------------------------
/*/{Protheus.doc} MNTA232RET
Grava alteracoes feitas na estrutura
@author Vitor Emanuel Batista
@since 14/08/2009
@version undefined
@type function
/*/
//---------------------------------------------------------------------
Function MNTA232RET(cTRBY,cTRBZ)

	Local nX, xy, yx, yk, m, ny
	Local nInd1         := 0
	Local lAlterou  	:= .F.
	Local lMain 		:= .F.
	Local lMNTA2314		:= ExistBlock("MNTA2314")
	Local lMNTA2315		:= ExistBlock("MNTA2315")
	Local lPIMSINT		:= SuperGetMV("MV_PIMSINT",.F.,.F.)
	Local cBEMPEST		:= ""
	Local nPOSSTZ 		:= 0
	Local aComponents   := {}
	Local aRetCon       := {}
	Local lFim          := .F.
	Local lRetroat      := NGHISTRETR(cBemPai,dDTDATEM,cHORALE1,1,xFilial("STP"))

	Private nTroLoc     := 7   //Tamanho do aARTROLOC
	Private cHORALE1    := If(AllTrim(cHORALE1)==":",Substr(Time(),1,5),cHORALE1)
	Private cHORALE2    := If(AllTrim(cHORALE2)==":",Substr(Time(),1,5),cHORALE2)

	//Atualiza contador 1
	If lTEMCONT .And. nPOSCONT > 0
		nPOSSTZ := nPOSCONT
	Endif

	//Verifica se houve alteracoes na estrutura
	For nX := 1 to Len(aPNEUSINI)
		nPos := aScan(aPNEUSFIM,{|aArray| aArray[__CODBEM__] == aPNEUSINI[nX][__CODBEM__]})
		If nPos == 0
			lAlterou := .T.
			Exit
		Else
			If aPNEUSINI[nX][__LOCALIZ__] <> aPNEUSFIM[nPos][__LOCALIZ__]
				lAlterou := .T.
				Exit
			Endif
		Endif
	Next nX

	//Se nao houve alteracoes, retorna
	If !lAlterou
		Return .T.
	EndIf

	//Retorna o bem pai de toda a estrutura
	cBEMPEST := NGBEMPAI(cBemPai,dDTDATEM,cHORALE1)
	cBEMPEST := If(Empty(cBEMPEST),cBemPai,cBEMPEST)

	//Alimenta o arquivo temporario com os componentes que fazem parte da
	//estrutura do bem pai antes do Rodizio
	dbSelectArea("ST9")
	nREGST998 := Recno()
	cCUSTOB   := NGSEEK('ST9',cBemPai,1,'ST9->T9_CCUSTO')
	cCENTRAB  := NGSEEK('ST9',cBemPai,1,'ST9->T9_CENTRAB')
	cItemCont := NGSEEK('ST9',cBemPai,1,'ST9->T9_ITEMCTA')
	M98ARQTRB(cTRBY,cBEMPEST,.T.)

	dbSelectArea("ST9")
	DbGoto(nREGST998)

	aBENSSAIDA := {} // pneus que saem da estrutura - inclusive aqueles que trocam de localização
	aBENSENTRA := {} // pneus que entram na estrutura - inclusive aqueles que trocam de localização

	aARDELSTC := {} // pneus que saem da estrutura e serão deletados da STC
	aARTROLOC := {} // pneus que apenas trocam de localização

	For xy := 1 To Len(aPNEUSINI)
		If !Empty(aPNEUSINI[xy][__CODBEM__])
			nPOS3 := ASCAN(aPNEUSFIM,{|x| x[__CODBEM__] == aPNEUSINI[xy][__CODBEM__]})

			//Deletado da Estrutura
			If nPOS3 = 0
				aAdd(aARDELSTC,aPNEUSINI[xy])
			Else //Troca de Localizacao
				
				If aPNEUSINI[xy][__LOCALIZ__] != aPNEUSFIM[nPOS3][__LOCALIZ__]

					//Se houver modificacoes no tamanho nesta array, devera ser alterada a variavel nTroLoc
					aAdd( aARTROLOC, { 	aPNEUSINI[xy][__CODBEM__]    ,;
										aPNEUSFIM[nPOS3][__LOCALIZ__],;
										aPNEUSINI[xy][__LOCALIZ__]   ,;
										aPNEUSFIM[xy][__MOTIVO__]    ,;
										cBemPai                      ,; 
										aPNEUSINI[xy][__USUARIO__]   ,;
										aPNEUSFIM[nPOS3][__USUARIO__] } )

					If lMNTA2314
						ExecBlock( 'MNTA2314' , .F., .F., { xy } )
					EndIf

				EndIf

			EndIf

		EndIf

	Next xy

	/*---------------------------------------------------------------------+
	| Prepara o array de pneus que possuem contador proprio para gravação. |
	+---------------------------------------------------------------------*/
	For xY := 1 To Len( aPneuCont )

		If aScan( aRetCon, { |aX| aX[1] == aPneuCont[xY,__CDPNEU__] .And.;
			aPneuCont[xy,__CONTPN__] > 0 } ) == 0
		
			aAdd( aRetCon, { aPneuCont[xy,__CDPNEU__], dDTDATEM, aPneuCont[xy,__CONTPN__], cHORALE1, 1 } )

		EndIf

	Next xY

	//Identifica a utilização de MSDialog
	lMain := Type( "oMainWnd" ) == "O"

	/* 
		Transação principal que trata a gravação do histórico de movimentações e estrutura. 
		Sendo esta transação separada dos contadores.
	*/
	BEGIN TRANSACTION

		// deleta os rodados do STC e baixa do STZ que sairam da estrutura
		For yx := 1 To Len(aARDELSTC)
			cBEMPCOM := cBemPai
			dbSelectArea("STC")
			dbSetOrder(1)
			If dbSeek(xFilial("STC")+cBEMPCOM+aARDELSTC[yx][__CODBEM__])
				dbSelectArea("STZ")
				dbSetOrder(1)
				If dbSeek(xFilial("STZ")+aARDELSTC[yx][__CODBEM__]+'E')
					
					While !Eof() .And. STZ->TZ_FILIAL == xFilial('STZ') .And. STZ->TZ_CODBEM == aARDELSTC[yx][__CODBEM__] .And. STZ->TZ_TIPOMOV = 'E'
						
						If Empty( STZ->TZ_DATASAI )
							
							RecLock( 'STZ', .F. )
							
								STZ->TZ_TIPOMOV := 'S'
								STZ->TZ_DATASAI := dDTDATEM
								STZ->TZ_HORASAI := If(Alltrim(cHORALE1) = ":",cHRTIME,cHORALE1)
								STZ->TZ_CONTSA2 := nPOSCON2
								STZ->TZ_CAUSA   := aARDELSTC[yx][__MOTIVO__]
								STZ->TZ_ORDEM   := cNumOS
								STZ->TZ_PLANO   := cNumPL
								
								If lTZUser
									STZ->TZ_USUARIO := aARDELSTC[yx][__USUARIO__]
								EndIf

								If STZ->TZ_TEMCONT == 'S' .And.;
									( nPosAux := aScan( aPneuCont, { |x| x[__CDPNEU__] == STZ->TZ_CODBEM } ) ) > 0

									STZ->TZ_CONTSAI := aPneuCont[nPosAux,__CONTPN__]

								Else

									STZ->TZ_CONTSAI := nPOSSTZ

								EndIf

							STZ->( MsUnLock() )

							aAdd(aBENSSAIDA,{STZ->TZ_CODBEM,STZ->(Recno()), .F., STZ->TZ_CONTSAI})

							dbSelectArea("ST9")
							dbSetOrder(1)
							If dbSeek(xFilial("ST9")+aARDELSTC[yx][__CODBEM__])
								RecLock("ST9",.F.)
								ST9->T9_ESTRUTU := "N"
								ST9->(MsUnLock())
							EndIf

							If lMNTA2315
								ExecBlock( 'MNTA2315' , .F., .F., { 'D', yx })
							EndIf

							Exit
						EndIf

						Dbskip()

					End

				EndIf

				Reclock("STC",.F.)
				dbDelete()
				STC->(MsUnlock())

			Else
				ShowHelpDlg(STR0113,{STR0114,STR0115,STR0116},5,; //"Aviso" ##"Não foi possivel atualizar a tabela:" ## "Hist. de Estrutura (STZ)" ## " e atualizar o campo T9_ESTRUTU"
				{STR0117 + aARDELSTC[yx][__CODBEM__] + STR0118,STR0117 + cBemPai + STR0119},5) //"Analisar se o bem " ## " esta na estrutura" ## "é pai da estrutura"
			EndIf

			dbSelectArea("ST9")
			dbSetOrder(1)
			If dbSeek(xFilial("ST9")+aARDELSTC[yx][__CODBEM__])
				If ST9->T9_MOVIBEM = "S" .And. (ST9->T9_CCUSTO <> aARDELSTC[yx][__CCUSTO__] .Or. ST9->T9_CENTRAB <> aARDELSTC[yx][__CENTRAB__])
					RecLock("ST9",.F.)
					ST9->T9_CCUSTO  := aARDELSTC[yx][__CCUSTO__]
					ST9->T9_CENTRAB := aARDELSTC[yx][__CENTRAB__]
					ST9->T9_ITEMCTA := aARDELSTC[yx][__ITEMCTA__]
					ST9->(MsUnLock())

					//Atualiza o centro de custo no ativo fixo
					NGATUATF(ST9->T9_CODIMOB,ST9->T9_CCUSTO)

					dbSelectArea( 'TPN' )
					dbSetOrder( 1 )

					RecLock( 'TPN', .T. )
					
						TPN->TPN_FILIAL := FWxFilial( 'TPN' )
						TPN->TPN_CODBEM := aARDELSTC[yx][__CODBEM__]
						TPN->TPN_DTINIC := dDTDATEM
						TPN->TPN_HRINIC := If(Alltrim(cHORALE1) = ":",cHRTIME,cHORALE1)
						TPN->TPN_CCUSTO := aARDELSTC[yx][__CCUSTO__]
						TPN->TPN_CTRAB  := aARDELSTC[yx][__CENTRAB__]
						TPN->TPN_UTILIZ := "U"
						TPN->TPN_POSCO2 := nPOSCON2
						
						If ST9->T9_TEMCONT == 'S' .And.;
							( nPosAux := aScan( aPneuCont, { |x| x[__CDPNEU__] == TPN->TPN_CODBEM } ) ) > 0

							TPN->TPN_POSCON :=  aPneuCont[nPosAux,__CONTPN__]
							
						Else

							TPN->TPN_POSCON := nPOSCONT

						EndIf
					
					TPN->( MsUnLock() )

					//Funcao de integracao com o PIMS atraves do EAI
					If lPIMSINT .And. FindFunction("NGIntPIMS")
						NGIntPIMS("TPN",TPN->(RecNo()),3)
					EndIf

					//----------------------------------------------------
					// Integração via mensagem única do cadastro de Bem
					//----------------------------------------------------
					If FindFunction("MN080INTMB") .And. MN080INTMB(ST9->T9_CODFAMI)

						DbSelectArea( "ST9" )

						// Define array private que será usado dentro da integração
						aParamMensUn    := Array( 4 )
						aParamMensUn[1] := Recno() // Indica numero do registro
						aParamMensUn[2] := 4       // Indica tipo de operação que esta invocando a mensagem unica
						aParamMensUn[3] := .F.     // Indica que se deve recuperar dados da memória
						aParamMensUn[4] := 1       // Indica se deve inativar o bem (1 ativo,2 - inativo)

						lMuEquip := .F.
						bBlock := { || FWIntegDef( "MNTA080",EAI_MESSAGE_BUSINESS,TRANS_SEND,Nil ) }

						If lMain
							MsgRun( "Aguarde integração com backoffice...","Equipment",bBlock )
						Else
							Eval( bBlock )
						EndIf

					EndIf
				Else
					RecLock("ST9",.F.)
					ST9->T9_ITEMCTA := aARDELSTC[yx][__ITEMCTA__]
					ST9->(MsUnLock())
				Endif

			Endif

		Next yx

		// baixa do STZ os compomente que trocam de localiza‡ao
		For yk := 1 To Len( aARTROLOC )

			dbSelectArea("STZ")
			dbSetOrder(1)
			If dbSeek(xFilial("STZ")+aARTROLOC[yk][1]+'E')
				
				While !EoF() .And. STZ->TZ_FILIAL == xFilial('STZ') .And. STZ->TZ_CODBEM == aARTROLOC[yk][1] .And. STZ->TZ_TIPOMOV = 'E'
					
					If Empty(STZ->TZ_DATASAI) .And. STZ->TZ_LOCALIZ = aARTROLOC[yk][3]
						
						RecLock( 'STZ', .F. )

							STZ->TZ_TIPOMOV := 'S'
							STZ->TZ_DATASAI := dDTDATEM
							STZ->TZ_CONTSAI := nPOSSTZ
							STZ->TZ_HORASAI := If(Alltrim(cHORALE1) = ":",cHRTIME,cHORALE1)
							STZ->TZ_CAUSA   := aARTROLOC[yk][4]
							STZ->TZ_ORDEM   := cNumOS
							STZ->TZ_PLANO   := cNumPL
							STZ->TZ_CONTSA2 := nPOSCON2
							
							If lTZUser
								STZ->TZ_USUARIO := aARTROLOC[yk][7]
							EndIf

							If STZ->TZ_TEMCONT == 'S' .And.;
								( nPosAux := aScan( aPneuCont, { |x| x[__CDPNEU__] == STZ->TZ_CODBEM } ) ) > 0

								STZ->TZ_CONTSAI :=  aPneuCont[nPosAux,__CONTPN__]
							
							Else

								STZ->TZ_CONTSAI := nPOSCONT

							EndIf


						STZ->( MsUnLock() )

						If lMNTA2315
							ExecBlock( 'MNTA2315' , .F., .F., { 'S', yk })
						EndIf

						aAdd(aBENSSAIDA,{STZ->TZ_CODBEM,STZ->(Recno()), .F., STZ->TZ_CONTSAI })

						Exit

					EndIf

					dbSkip()

				End
				
			Else
				ShowHelpDlg(STR0113,{STR0114,STR0115},5,; //"Aviso" ## "Não foi possivel atualizar a tabela:" ## "Hist. de Estrutura (STZ)"
				{STR0117+ aARTROLOC[yk][1] + STR0118},5) //"Analisar se o bem " ## " esta na estrutura"
			EndIf

			dbSelectArea("STC")
			dbSetOrder(1)
			If dbSeek(xFilial("STC")+aARTROLOC[yk][5]+aARTROLOC[yk][1])
				RecLock("STC",.F.)
				Dbdelete()
				STC->(MsUnLock())
			EndIf

		Next yk

		// Atualiza a estrutura STC com os componentes novos
		For m := 1 to Len(aPNEUSFIM)
			If !Empty(aPNEUSFIM[m][__CODBEM__])
				cBEMPCOM := cBemPai
				dbSelectArea("STC")
				dbSetOrder(1)
				If !dbSeek(xFilial("STC")+cBEMPCOM+aPNEUSFIM[m][__CODBEM__])
					Reclock("STC",.T.)
					STC->TC_FILIAL  := xFilial("STC")
					STC->TC_CODBEM  := cBEMPCOM
					STC->TC_COMPONE := aPNEUSFIM[m][__CODBEM__]
					STC->TC_LOCALIZ := aPNEUSFIM[m][__LOCALIZ__]
					STC->TC_TIPOEST := 'B'
					STC->TC_DATAINI := dDTDATEM
					STC->TC_TIPMOD  := cTipMod
					STC->(MsUnlock())

					dbSelectArea("ST9")
					dbSetOrder(1)
					If dbSeek(xFilial("ST9")+aPNEUSFIM[m][__CODBEM__])
						//Atualiza campo T9_ESTRUTU, indicando o pneu como aplicado
						RecLock("ST9",.F.)
						ST9->T9_ESTRUTU := "S"
						MsUnLock("ST9")
						If ST9->T9_MOVIBEM = "S" .And. (ST9->T9_CCUSTO <> cCUSTOB .Or. ST9->T9_CENTRAB <> cCENTRAB .Or. ST9->T9_ITEMCTA <> cItemCont)
							RecLock("ST9",.F.)
							ST9->T9_CCUSTO  := cCUSTOB
							ST9->T9_CENTRAB := cCENTRAB
							ST9->T9_CALENDA := cCALENB
							ST9->T9_ITEMCTA := cItemCont
							ST9->T9_STATUS  := AllTrim(cNGSTAPL)
							ST9->(MsUnLock())

							//Atualiza o centro de custo no ativo fixo
							NGATUATF(ST9->T9_CODIMOB,ST9->T9_CCUSTO)

							dbSelectArea("TPN")
							dbSetOrder(1)
							If !dbSeek(xFilial("TPN")+aPNEUSFIM[m][__CODBEM__]+DTOS(dDTDATEM)+If(Alltrim(cHORALE1) = ":",cHRTIME,cHORALE1))
								
								RecLock( 'TPN', .T. )
									
									TPN->TPN_FILIAL := FWxFilial( 'TPN' )
									TPN->TPN_CODBEM := aPNEUSFIM[m][__CODBEM__]
									TPN->TPN_DTINIC := dDTDATEM
									TPN->TPN_HRINIC := If(Alltrim(cHORALE1) = ":",cHRTIME,cHORALE1)
									TPN->TPN_CCUSTO := cCUSTOB
									TPN->TPN_CTRAB  := cCENTRAB
									TPN->TPN_UTILIZ := "U"
									TPN->TPN_POSCO2 := nPOSCON2
								
									If ST9->T9_TEMCONT == 'S' .And.;
										( nPosAux := aScan( aPneuCont, { |x| x[__CDPNEU__] == TPN->TPN_CODBEM } ) ) > 0

										TPN->TPN_POSCON :=  aPneuCont[nPosAux,__CONTPN__]
							
									Else

										TPN->TPN_POSCON := nPOSCONT

									EndIf
								
								TPN->( MsUnLock() )

								//Funcao de integracao com o PIMS atraves do EAI
								If lPIMSINT .And. FindFunction("NGIntPIMS")
									NGIntPIMS("TPN",TPN->(RecNo()),3)
								EndIf

								//----------------------------------------------------
								// Integração via mensagem única do cadastro de Bem
								//----------------------------------------------------
								If FindFunction("MN080INTMB") .And. MN080INTMB(ST9->T9_CODFAMI)

									DbSelectArea( "ST9" )

									// Define array private que será usado dentro da integração
									aParamMensUn    := Array( 4 )
									aParamMensUn[1] := Recno() // Indica numero do registro
									aParamMensUn[2] := 4       // Indica tipo de operação que esta invocando a mensagem unica
									aParamMensUn[3] := .F.     // Indica que se deve recuperar dados da memória
									aParamMensUn[4] := 1       // Indica se deve inativar o bem (1 ativo,2 - inativo)

									lMuEquip := .F.
									bBlock := { || FWIntegDef( "MNTA080",EAI_MESSAGE_BUSINESS,TRANS_SEND,Nil ) }

									If lMain
										MsgRun( "Aguarde integração com backoffice...","Equipment",bBlock )
									Else
										Eval( bBlock )
									EndIf

								EndIf

							EndIf
						Endif
					Endif

					cTEMCONT := ST9->T9_TEMCONT
					dbSelectArea("ST9")
					nREGST9 := Recno()
					dbSelectArea("ST9")
					dbSetOrder(1)
					dbSeek(xFilial("ST9")+cBemPai)
					cTEMCPAI := ST9->T9_TEMCONT
					Dbgoto(nREGST9)

					dbSelectArea("STZ")
					If !Dbseek(XFILIAL("STZ")+aPNEUSFIM[m][__CODBEM__]+'E')
						RecLock("STZ",.T.)
						STZ->TZ_FILIAL  := xFilial('STZ')
						STZ->TZ_CODBEM  := aPNEUSFIM[m][__CODBEM__]
						STZ->TZ_BEMPAI  := cBEMPCOM
						STZ->TZ_TIPOMOV := 'E'

						nPOSX := ASCAN(aPNEUSINI,{|x| x[__CODBEM__] == aPNEUSFIM[m][__CODBEM__]})
						If nPOSX > 0 //Componente que trocou de localizacao
							If aPNEUSFIM[m][__LOCALIZ__] <> aPNEUSINI[nPOSX][__LOCALIZ__]
								STZ->TZ_HORAENT := If(Alltrim(cHORALE1) = ":",cHRTIME1M,MTOH(HTOM(SubStr(cHORALE1,1,5))+1))
								If STZ->TZ_HORAENT = "24:00"
									STZ->TZ_HORAENT := "00:00"
								EndIf
								If STZ->TZ_HORAENT = "00:00"
									STZ->TZ_DATAMOV := dDTDATEM + 1

									dbSelectArea("STC")
									Reclock("STC",.F.)
									STC->TC_DATAINI := STZ->TZ_DATAMOV
									STC->(MsUnlock())
								Else
									STZ->TZ_DATAMOV := dDTDATEM
								EndIf
							EndIf
						Else
							STZ->TZ_HORAENT := If(Alltrim(cHORALE1) = ":",cHRTIME,cHORALE1)
							STZ->TZ_DATAMOV := dDTDATEM
						EndIf

						If cTEMCONT == 'S' .And.;
							( nPosAux := aScan( aPneuCont, { |x| x[__CDPNEU__] == STZ->TZ_CODBEM } ) ) > 0

							STZ->TZ_POSCONT := aPneuCont[nPosAux,__CONTPN__]

						Else

							STZ->TZ_POSCONT := nPOSSTZ

						EndIf

						STZ->TZ_LOCALIZ := aPNEUSFIM[m][__LOCALIZ__]
						STZ->TZ_TEMCONT := cTEMCONT
						STZ->TZ_TEMCPAI := cTEMCPAI
						//Verificar se o bem tem 1º contador
						If cTEMCONT <> "N"
							STZ->TZ_HORACO1 := cHORALE1
						EndIf
						//Verificar se o bem tem 2º contador
						If NGIFDBSEEK('TPE',aPNEUSFIM[m][__CODBEM__],1)
							STZ->TZ_HORACO2 := cHORALE2
						EndIf
						STZ->TZ_ORDEM   := cNumOS
						STZ->TZ_PLANO   := cNumPL
						If lTZUser
							STZ->TZ_USUARIO := aPNEUSFIM[m][__USUARIO__]
						EndIf

						dbSelectArea("STZ")
						STZ->(MsUnLock())
					EndIf
					If lMNTA2315
						ExecBlock( 'MNTA2315' , .F., .F., { 'T', m })
					EndIf
					Aadd(aBENSENTRA,{STZ->TZ_CODBEM,STZ->(Recno()), .F., STZ->TZ_POSCONT})

				Else
					If STC->TC_LOCALIZ <> aPNEUSFIM[m][__LOCALIZ__]
						Reclock("STC",.F.)
						STC->TC_LOCALIZ := aPNEUSFIM[m][__LOCALIZ__]
						STC->(MsUnlock())
					EndIf
				EndIf
			EndIf
		Next m

		//Retorna a estrutura padrao do bem pai e informacao dos componentes que recebem contador
		dbSelectArea("ST9")
		dbSetOrder(1)
		dbSeek(xFilial("ST9")+cBEMPEST)
		cCODFAM232 := ST9->T9_CODFAMI+Space(Len(ST9->T9_CODBEM)-Len(ST9->T9_CODFAMI))
		cTIPMOD232 := ST9->T9_TIPMOD
		aESTFAM232 := NGCOMPEST(cCODFAM232,"F",.T.,.F.,.T.,Nil,Nil,cTIPMOD232)

		// Le array com os itens de saida
		For ny := 1 To Len(aBENSSAIDA)

			dbSelectArea("STZ")
			dbGoTo(aBENSSAIDA[ny][2])

			dbSelectArea("ST9")
			dbSetOrder(1)
			If dbSeek(xFilial("ST9")+aBENSSAIDA[ny][1])

				//Verifica se o componente e um step
				lREPAS232 := .T.

				//-------------------------------------------
				cPaiSup := ""
				lEnd := .F.

				DbSelectArea("ST9")
				DbSetOrder(01)
				Dbseek(xfilial("ST9")+cBemPai)
				cCodPai := ST9->T9_CODBEM
				cFamP232 := ST9->T9_CODFAMI+Space(Len(ST9->T9_CODBEM)-Len(ST9->T9_CODFAMI))
				cLocP232 := ""

				Dbseek(xFILIAL("ST9")+aBENSSAIDA[ny][1])
				cCodCom := ST9->T9_CODBEM
				cFamC232 := ST9->T9_CODFAMI+Space(Len(ST9->T9_CODBEM)-Len(ST9->T9_CODFAMI))
				cLocC232 := STZ->TZ_LOCALIZ

				//Se bem bem pai deste componente também é filho de outro componente na estrutura,
				//busca sua localização
				dbSelectArea("STC")
				nRecNo := STC->(RecNo())
				dbSetOrder(03)
				If dbSeek(xFilial("STC")+cCodPai)
					cLocP232 := STC->TC_LOCALIZ
					cPaiSup := STC->TC_CODBEM
				EndIf
				dbGoTo(nRecNo)

				nPOSF232 := 0
				If Len(aESTFAM232) > 0
					nPOSF232 := aSCAN(aESTFAM232,{|x| cFamC232+cLocC232 = x[1]+x[2].And.;
					cFamP232+cLocP232 = x[6]+x[7]})
				EndIf

				If nPOSF232 > 0
					If aESTFAM232[nPOSF232,3] = "N"
						lREPAS232 := .F.
					EndIf
				ElseIf !Empty(cPaiSup)
					While !lEnd
						//se nao encontrou, busca estruturas padrao dos pais imediatos, ate o topo da estrutura
						cTpMod2 := NGSEEK('ST9',cCodPai,1,'T9_TIPMOD')
						cFamPa2 := NGSEEK('ST9',cCodPai,1,'T9_CODFAMI')+Space(Len(st9->t9_codbem)-Len(st9->t9_codfami))
						aESTFAM2 := NGCOMPEST(cFamPa2,"F",.T.,.F.,.T.,Nil,Nil,cTpMod2)

						//sobe um nivel na estrutura
						cCodCom := cCodPai
						cCodPai := cPaiSup

						//executa busca na nova estrutura padrao
						nPOSF232 := aSCAN(aESTFAM2,{|x| cFamC232+cLocC232 = x[1]+x[2] .And.;
						cFamP232+cLocP232 = x[6]+x[7]})
						If nPOSF232 > 0
							lREPAS232 := (aESTFAM2[nPOSF232,3] != "N")
							lEnd := .T.
						Else
							//Se bem bem pai deste componente também é filho de outro componente na estrutura:
							dbSelectArea("STC")
							nRecNo := STC->(RecNo())
							dbSetOrder(03)
							If !lFim .AND. dbSeek(xFilial("STC")+cCodPai)
								cLocP232 := STC->TC_LOCALIZ
								cPaiSup := STC->TC_CODBEM
								lFim := cCodPai == cPaiSup //Verifica se chegou ao fim da lista de pneus
							Else
								lEnd := .T.
							EndIf
							dbSelectArea("STC")
							dbGoTo(nRecNo)
						EndIf
					EndDo
				EndIf
				//-------------------------------------------

				aBENSSAIDA[nY,3] := lREPAS232
				If lREPAS232
					// Procura no arq. (cTRBY) quem ‚ o pai do componente na estrutura e acessa o ST9 para obter
					// o contador e alterar o contador no STZ
					dbSelectArea(cTRBY)
					dbSetOrder(02)
					If dbSeek(aBENSSAIDA[ny][1])
						If (cTRBY)->TC_CONTRO <> "N"

							//Procura o bem pai do componente
							cVBEMPAI98 := NGTBEMPTE( aBENSSAIDA[ny][1], (cTRBY))

							If !Empty(cVBEMPAI98)
								dbSelectArea("ST9")
								dbSetOrder(1)
								If dbSeek(xFilial("ST9")+cVBEMPAI98)

									dbSelectArea("STZ")
									dbGoto(aBENSSAIDA[ny][2])
									nCONT2TRBY := STZ->TZ_CONTSA2

									dbSelectArea("TPE")
									dbSetOrder(1)
									If MNT2322CNT(xFilial("TPE"),lDtvSgCnt,cVBEMPAI98)
										nCONT2TRBY := TPE->TPE_POSCON
										If MNT2322CNT(xFilial("TPE"),lDtvSgCnt,aBENSSAIDA[ny][1])
											nCONT2TRBY := STZ->TZ_CONTSA2
										EndIf
									EndIf

									dbSelectArea("STZ")
									RecLock("STZ",.F.)
									STZ->TZ_CONTSAI := nPOSSTZ
									STZ->TZ_CONTSA2 := nCONT2TRBY
									STZ->TZ_ORDEM   := cNumOS
									STZ->TZ_PLANO   := cNumPL
									STZ->(MsUnLock())

								EndIf

							EndIf

						EndIf

					EndIf

				Else
					nCONT2TRBY := 0
					dbSelectArea("TPE")
					dbSetOrder(01)
					If MNT2322CNT(xFilial("TPE"),lDtvSgCnt,aBENSSAIDA[ny][1])
						nCONT2TRBY := TPE->TPE_POSCON
					EndIf

					dbSelectArea("STZ")
					dbGoto(aBENSSAIDA[ny][2])
					RecLock("STZ",.F.)
					STZ->TZ_CONTSAI := nPOSSTZ
					STZ->TZ_CONTSA2 := nCONT2TRBY
					STZ->TZ_ORDEM   := cNumOS
					STZ->TZ_PLANO   := cNumPL
					STZ->(MsUnLock())

				EndIf

			EndIf

		Next ny

		//Alimenta o arquivo temporario com os componentes que fazem parte da
		//estrutura do bem pai apos o Rodizio
		dbSelectArea("STC")
		dbSetOrder(1)
		M98ARQTRB(cTRBZ,cBEMPEST,.T.)

		// Le array com os itens de entrada
		For nx := 1 To Len(aBENSENTRA)

			dbSelectArea("STZ")
			DbGoto(aBENSENTRA[nx][2])

			dbSelectArea("ST9")
			dbSetOrder(01)
			If dbSeek(xFilial("ST9")+aBENSENTRA[nx][1])

				//Verifica se o componente e um step
				lREPAS232 := .T.

				//-------------------------------------------
				cPaiSup := ""
				lEnd := .F.

				DbSelectArea("ST9")
				DbSetOrder(01)
				Dbseek(xfilial("ST9")+cBemPai)
				cCodPai := ST9->T9_CODBEM
				cFamP232 := ST9->T9_CODFAMI+Space(Len(ST9->T9_CODBEM)-Len(ST9->T9_CODFAMI))
				cLocP232 := ""

				Dbseek(xFILIAL("ST9")+aBENSENTRA[nx][1])
				cCodCom := ST9->T9_CODBEM
				cFamC232 := ST9->T9_CODFAMI+Space(Len(ST9->T9_CODBEM)-Len(ST9->T9_CODFAMI))
				cLocC232 := STZ->TZ_LOCALIZ

				//Se bem bem pai deste componente também é filho de outro componente na estrutura,
				//busca sua localização
				dbSelectArea("STC")
				nRecNo := STC->(RecNo())
				dbSetOrder(03)
				If dbSeek(xFilial("STC")+cCodPai)
					cLocP232 := STC->TC_LOCALIZ
					cPaiSup := STC->TC_CODBEM
				EndIf
				dbGoTo(nRecNo)

				nPOSF232 := 0
				If Len(aESTFAM232) > 0
					nPOSF232 := aSCAN(aESTFAM232,{|x| cFamC232+cLocC232 = x[1]+x[2].And.;
					cFamP232+cLocP232 = x[6]+x[7]})
				EndIf

				If nPOSF232 > 0
					If aESTFAM232[nPOSF232,3] = "N"
						lREPAS232 := .F.
					EndIf
				ElseIf !Empty(cPaiSup)
					While !lEnd
						//se nao encontrou, busca estruturas padrao dos pais imediatos, ate o topo da estrutura
						cTpMod2 := NGSEEK('ST9',cCodPai,1,'T9_TIPMOD')
						cFamPa2 := NGSEEK('ST9',cCodPai,1,'T9_CODFAMI')+Space(Len(st9->t9_codbem)-Len(st9->t9_codfami))
						aESTFAM2 := NGCOMPEST(cFamPa2,"F",.T.,.F.,.T.,Nil,Nil,cTpMod2)

						//sobe um nivel na estrutura
						cCodCom := cCodPai
						cCodPai := cPaiSup

						//executa busca na nova estrutura padrao
						nPOSF232 := aSCAN(aESTFAM2,{|x| cFamC232+cLocC232 = x[1]+x[2] .And.;
						cFamP232+cLocP232 = x[6]+x[7]})
						If nPOSF232 > 0
							lREPAS232 := (aESTFAM2[nPOSF232,3] != "N")
							lEnd := .T.
						Else
							//Se bem bem pai deste componente também é filho de outro componente na estrutura:
							dbSelectArea("STC")
							nRecNo := STC->(RecNo())
							dbSetOrder(03)
							If !lFim .AND. dbSeek(xFilial("STC")+cCodPai)
								cLocP232 := STC->TC_LOCALIZ
								cPaiSup := STC->TC_CODBEM
								lFim := cCodPai == cPaiSup //Verifica se chegou ao fim da lista de pneus
							Else
								lEnd := .T.
							EndIf
							dbSelectArea("STC")
							dbGoTo(nRecNo)
						EndIf
					EndDo
				EndIf
				//-------------------------------------------

				aBENSENTRA[nX,3] := lREPAS232
				If lREPAS232
					// Procura no arq. (cTRBZ) que ‚ o pai do componente na estrutura e acessa o ST9 e para obter
					// o contador e alterar o contador no STZ
					dbSelectArea(cTRBZ)
					dbSetOrder(02)
					If dbSeek(aBENSENTRA[nx][1])
						If (cTRBZ)->TC_CONTRO <> "N"

							nREGTRBZ := Recno()

							//Procura o bem pai do componente na estrutura
							cVBEMPAI98 := NGTBEMPTE(aBENSENTRA[nx][1],(cTRBZ))

							dbSelectArea(cTRBZ)
							dbGoto(nREGTRBZ)

							dbSelectArea("ST9")
							dbSetOrder(01)
							If dbSeek(xFilial("ST9")+cVBEMPAI98)

								dbSelectArea("STZ")
								DbGoto(aBENSENTRA[nx][2])
								nCONT1TRBZ := nPOSCONT
								nCONT2TRBZ := nPOSCON2
								If MNT2322CNT(xFilial("TPE"),lDtvSgCnt,cVBEMPAI98)
									nCONT2TRBZ := nPOSCON2
									If MNT2322CNT(xFilial("TPE"),lDtvSgCnt,aBENSENTRA[nx][1])
										nCONT2TRBZ := nPOSCON2
									EndIf
								EndIf

								dbSelectArea("STZ")
								RecLock("STZ",.F.)
								STZ->TZ_POSCONT := nPOSSTZ
								STZ->TZ_POSCON2 := nPOSCON2
								STZ->TZ_ORDEM   := cNumOS
								STZ->TZ_PLANO   := cNumPL
								STZ->(MsUnLock())

								If nCONT1TRBZ > 0
									dbSelectArea("ST9")
									dbSetOrder(01)
									If dbSeek(xFilial("ST9")+STZ->TZ_CODBEM)

										//Inclui registro de entrada na estrutura para componente controlado por Pai da estrutura
										//ou Imediato e Contador Proprio
										If ST9->T9_TEMCONT == "S"
											
											aAdd( aRetCon, { STZ->TZ_CODBEM, STZ->TZ_DATAMOV, nCONT1TRBZ, STZ->TZ_HORAENT, 1 } )

										ElseIf ST9->T9_TEMCONT = "P" .Or. ST9->T9_TEMCONT = "I"
											
											aAdd( aComponents, { STZ->TZ_CODBEM, STZ->TZ_DATAMOV, STZ->TZ_HORAENT, 1, nCONT1TRBZ, ST9->T9_CONTACU, ST9->T9_VIRADAS } )
										
										EndIf

									EndIf

								EndIf

								If nCONT2TRBZ > 0
									If MNT2322CNT(xFilial("TPE"),lDtvSgCnt,STZ->TZ_CODBEM)

										//Inclui registro de entrada na estrutura para componente controlado por Pai da estrutura
										//ou Imediato e Contador Proprio
										If (cTRBZ)->TC_CONTRO == "S"

											aAdd( aRetCon, { STZ->TZ_CODBEM, STZ->TZ_DATAMOV, nCONT2TRBZ, cHORALE2, 2 } )

										ElseIf (cTRBZ)->TC_CONTRO == "P" .Or. (cTRBZ)->TC_CONTRO == "I"
											
											aAdd( aComponents, { STZ->TZ_CODBEM, STZ->TZ_DATAMOV, cHORALE2, 2, nCONT2TRBZ, TPE->TPE_CONTAC, TPE->TPE_VIRADA } )
										
										EndIf

									EndIf
								EndIf
							EndIf
						EndIf
					EndIf
				Else
					nCONT2TRBZ := 0
					If MNT2322CNT(xFilial("TPE"),lDtvSgCnt,aBENSENTRA[nx][1])
						nCONT2TRBZ := nPOSCON2
					EndIf

					dbSelectArea("STZ")
					DbGoto(aBENSENTRA[nx][2])
					RecLock("STZ",.F.)
					STZ->TZ_POSCONT := nPOSSTZ
					STZ->TZ_POSCON2 := nPOSCON2
					STZ->TZ_ORDEM   := cNumOS
					STZ->TZ_PLANO   := cNumPL
					STZ->(MsUnLock())
				EndIf
			EndIf
		Next nx

		// Gera as pendencias TR1
		MNTA232PEN()

		lRet := MNTA232ANE()

		If !lRet

			DisarmTransaction()
			
		EndIf

	END TRANSACTION
	
	If lRet

		For nInd1 := 1 To Len( aRetCon )
			
			// Atualiza contador dos componentes da estrutura, quando estes possuem contador proprio.
			NGTRETCON( aRetCon[nInd1,1], aRetCon[nInd1,2], aRetCon[nInd1,3], aRetCon[nInd1,4], aRetCon[nInd1,5], , .T. )
			
		Next nInd1

		If !Empty( aComponents )
			
			// Inclusão em lote do histórico de contadores conforme entrada na estrutura
			NGINREGEST( , , , , , , , aComponents, .F. )

		EndIf

		If lRetroat

			// Tratamento para movimentação retroativa
			MNT232PAST( aBENSSAIDA, aBENSENTRA, dDTDATEM, cHORALE1, nPOSCONT, cHORALE2, nPOSCON2 )

		EndIf

		//Atualiza contador 1
		If ( lTEMCONT .And. nPOSCONT > 0 )
			NGTRETCON( IIf( lPai, cPaiEst, cBemPai ), dDTDATEM, nPOSCONT, cHORALE1, 1,, .T. )
		Endif

		//Atualiza contador 2
		If lTEMCON2 .And. nPOSCON2 > 0
			NGTRETCON( If( lPai, cPaiEst, cBemPai ), dDTDATEM, nPOSCON2, cHORALE2, 2,, .T. )
		Endif

		//GERA O.S AUTOMATICA POR CONTADOR
		dbSelectArea("ST9")
		dbSetOrder(16)
		dbSeek(cBemPai)
		If (cNGGERPR = "S" .Or. cNGGERPR = "C") .And. (!Empty(nPOSCONT) .Or. !Empty(nPOSCON2))
			If cNGGERPR = "C"
				If MsgYesNo(STR0082+chr(13)+chr(13); //"Deseja que seja verificado a existência de o.s automática por contador?"
				+STR0083,STR0009) //"Confirma (Sim/Não)"#"ATENÇÃO"
					//------------------------------------------------------------------------
					//O parâmetro de filial para a função NGGEROSAUT deve ser passado completo
					//para no caso das tabelas ST9/STJ terem compartilhamento diferente
					//------------------------------------------------------------------------
					NGGEROSAUT(cBemPai,If(!Empty(nPOSCONT),nPOSCONT,nPOSCON2),cFilAnt)
				EndIf
			Else
				//------------------------------------------------------------------------
				//O parâmetro de filial para a função NGGEROSAUT deve ser passado completo
				//para no caso das tabelas ST9/STJ terem compartilhamento diferente
				//------------------------------------------------------------------------
				NGGEROSAUT(cBemPai,If(!Empty(nPOSCONT),nPOSCONT,nPOSCON2),cFilAnt)
			Endif
		EndIf

		//Fazer alteracoes apos gerar O.S Preventiva automatica por contador
		If ExistBlock("MNTA2311")
			ExecBlock("MNTA2311",.F.,.F.)
		Endif

		// Testa se o serviço e CABIBALISMO
		If lCanibal
			// Somente o bem pai recebera status de CANIBALISMO
			dbSelectArea("ST9")
			dbSetOrder(01)

			If dbSeek(xFilial("ST9")+cBemPai)
				RecLock("ST9",.F.)
				ST9->T9_STATUS := cNGSTACA
				ST9->(MsUnLock())
			Endif

		Endif

		/*---------------------------------------------------------------+
		| P.E. com intuito de manipular a O.S. de movimentação de pneus. |
		+---------------------------------------------------------------*/
		If ExistBlock( 'MNTA2320' )
			ExecBlock( 'MNTA2320', .F., .F., { STJ->TJ_ORDEM, STJ->TJ_PLANO } )
		EndIf

	EndIf

Return lRet

//---------------------------------------------------------------------
/*/{Protheus.doc} MNTA232PEN
Consiste as pendencias na gravacao das alteracoes feitas
@author Vitor Emanuel Batista
@since 14/08/2009
@version undefined
@type function
/*/
//---------------------------------------------------------------------
Static Function MNTA232PEN()

	Local Zp := 0,V2 := Zp, nPos
	Local cCodMed
	Local lTesBa   := .F.
	Private lPrimL := .T.
	Private cComPE,cBemPC,cCodPen,cLocC

	// CONSISTENCIA DA MEDIDA
	For Zp := 1 To Len(aEstruturas[nPosEstru][5])
		cCodMed := Space(Len(TQS->TQS_MEDIDA))
		For V2 := 1 To Len(aPNEUSFIM)
			nPos := aSCAN(aPNEUSINI,{|aArray| aArray[__LOCALIZ__] == aPNEUSFIM[V2][__LOCALIZ__]})
			If aPNEUSINI[nPos][__EIXO__] == Zp
				If !Empty(aPNEUSFIM[V2][__CODBEM__])
					If Empty(cCodMed)
						cCodMed := aPNEUSFIM[V2][__MEDIDA__]
						cComPE  := aPNEUSFIM[V2][__CODBEM__]
						cLocC   := aPNEUSFIM[V2][__LOCALIZ__]
					Else
						If aPNEUSFIM[V2][__MEDIDA__] <> cCodMed
							If lPrimL
								MNTA231GPEN(cComPE,'01',cLocC)
							Endif
							MNTA231GPEN(aPNEUSFIM[V2][__CODBEM__],'01',aPNEUSFIM[V2][__LOCALIZ__])
						Endif
					EndIf
				Endif
			Endif
		Next V2
	Next Zp

	// CONSISTENCIA DO TIPO DE EIXO
	For V2 := 1 To Len(aPNEUSFIM)
		If Val(aPNEUSFIM[V2,__TIPEIXO__]) > 2 .And. !Empty(aPNEUSFIM[V2][__CODBEM__])
			If !lTEMCONT
				cBemPEs := NGBEMPAI(aPNEUSFIM[V2][__CODBEM__])
				If !Empty(cBemPEs)
					dbSelectArea("ST9")
					nRecST9 := Recno()
					dbSetOrder(1)
					If dbSeek(xFilial("ST9")+cBemPES)
						lTesBa := If(ST9->T9_TEMCONT = "S",.T.,.F.)
					Endif
					Dbgoto(nRecST9)
				Endif
			Else
				lTesBa := .T.
			Endif
			If lTesBa
				If aPNEUSFIM[V2,__BANDA__] <> '0'
					MNTA231GPEN(aPNEUSFIM[V2][__CODBEM__],'02',aPNEUSFIM[V2][__LOCALIZ__])
				Endif
			Endif
		Endif
	Next V2

	// CONSISTENCIA DO SULCO
	lPrimL  := .T.
	nParSul := nNGDIFSU //GETMV("MV_NGDIFSU")
	For Zp := 1 To Len(aEstruturas[nPosEstru][5])
		cLocC := Space(6)
		For V2 := 1 To Len(aPNEUSFIM)
			nPos := aSCAN(aPNEUSINI,{|aArray| aArray[__LOCALIZ__] == aPNEUSFIM[V2][__LOCALIZ__]})
			If aPNEUSINI[nPos][__EIXO__] = Zp
				If !Empty(aPNEUSFIM[V2][__CODBEM__])
					nDifSMa := aPNEUSFIM[V2][__SULCO__] + nParSul
					nDifSMe := aPNEUSFIM[V2][__SULCO__] - nParSul
					If aPNEUSFIM[V2][__SULCO__] >= nDifSMe .And. aPNEUSFIM[V2][__SULCO__] <= nDifSMa
					Else
						If Empty(cLocC)
							cComPE  := aPNEUSFIM[V2][__CODBEM__]
							cLocC   := aPNEUSFIM[V2][__LOCALIZ__]
						Else
							If lPrimL
								MNTA231GPEN(cComPE,'03',cLocC)
							Endif
							MNTA231GPEN(aPNEUSFIM[V2][__CODBEM__],'03',aPNEUSFIM[V2][__LOCALIZ__])
						Endif
					Endif
				Endif
			Endif
		Next V2
	Next Zp

	// CONSISTENCIA DO DOT
	For V2 := 1 To Len(aPNEUSFIM)
		If !Empty(aPNEUSFIM[V2][__CODBEM__])
			cTQSDot := StrZero(Val(SuBstr(aPNEUSFIM[V2][__DOT__],3,2))+5,2)+SuBstr(aPNEUSFIM[V2][__DOT__],1,2)
			If cSemMov > cTQSDot
				MNTA231GPEN(aPNEUSFIM[V2][__CODBEM__],'04',aPNEUSFIM[V2][__LOCALIZ__])
			Endif
		Endif
	Next V2

Return

//---------------------------------------------------------------------
/*/{Protheus.doc} MNTA232ANE
Atualiza o eixo do componente na cadastro de pneus
@author Vitor Emanuel Batista
@since 14/08/2009
@version undefined
@type function
/*/
//---------------------------------------------------------------------
Static Function MNTA232ANE()

	Local nF		:= 0
	Local lMNTA2323 := ExistBlock("MNTA2323")
	Local lRet      := .T.
	Local xRetVld   := Nil

	dbSelectArea("TQS")
	dbSetOrder(1)

	//Saindo da estrutura
	For nF := 1 To Len(aPNEUSINI)
		If !Empty(aPNEUSINI[nF][__CODBEM__])
			If ASCAN(aPNEUSFIM,{|x| x[__CODBEM__] == aPNEUSINI[nF][__CODBEM__]}) == 0
				cNoEix := NGSEEK('TQ1',cCodFami+cTipMod+Str(aPNEUSINI[nF][__EIXO__],3),1,'TQ1_EIXO')
				cNoEix := If(Upper(cNoEix) == Upper(STR0021),'R',aPNEUSINI[nF][__LOCALIZ__]) //"RESERVA"
				
				xRetVld := MNTA231NC( aPNEUSINI[nF][__CODBEM__], aPNEUSINI[nF][__MEDIDA__], aPNEUSINI[nF][__SULCO__], aPNEUSINI[nF][__BANDA__],;
					aPNEUSINI[nF][__STATUS__], '   ', cNoEix, aPNEUSINI[nF][__TIPEIXO__], .F., aPNEUSINI[nF][__CODESTO__], aPNEUSINI[nF][__LOCPAD__],;
					aPNEUSINI[nF][__CODEANT__], aPNEUSINI[nF][__LOCALIF__] )
				
				If ValType( xRetVld ) == 'L' 
				
					If !xRetVld
						lRet := xRetVld
						Exit
					EndIf

				EndIf

			EndIf

		EndIf

	Next nF

	If lRet
	
		//Entrando na Estrutura
		For nF := 1 To Len(aPNEUSFIM)
			
			If !Empty(aPNEUSFIM[nF][__CODBEM__])
				cNoEix := NGSEEK('TQ1',cCodFami+cTipMod+Str(aPNEUSINI[nF][__EIXO__],3),1,'TQ1->TQ1_EIXO')

				If Upper(Alltrim(cNoEix)) == Upper(STR0021)
					cNoEix := 'R'
				ElseIf aPNEUSINI[nF][__EIXO__] > 9
					cNoEix := Str(aPNEUSINI[nF][__EIXO__],2)
				Else
					cNoEix := Str(aPNEUSINI[nF][__EIXO__],1)
				EndIf

				//Ponto de entrada para alterar o almoxerifado
				If lMNTA2323
					aPNEUSFIM[nF][__LOCPAD__] := ExecBlock("MNTA2323",.F.,.F.,{aPNEUSFIM[nF]}) // Passa o almoxerifado por parametro.
				EndIf

				MNTA231NC( aPNEUSFIM[nF][__CODBEM__], aPNEUSFIM[nF][__MEDIDA__], aPNEUSFIM[nF][__SULCO__], aPNEUSFIM[nF][__BANDA__], cNGSTAPL,;
					cNoEix, aPNEUSFIM[nF][__LOCALIZ__], aPNEUSFIM[nF][__TIPEIXO__], .T., aPNEUSFIM[nF][__CODESTO__], aPNEUSFIM[nF][__LOCPAD__],;
					aPNEUSINI[nF][__CODEANT__], aPNEUSINI[nF][__LOCALIF__] )

			EndIf

		Next nF
		
		For nF := 1 To Len(aPNEUSFIM)

			If !Empty(aPNEUSFIM[nF][__CODBEM__])

				If ASCAN(aPNEUSINI,{|aArray| aArray[__CODBEM__] == aPNEUSFIM[nF][__CODBEM__]}) == 0;
					.And. ( ( Len( aPneusReq ) > 0; // pneus que vem de requisição já possuem uma STL vinculada a uma movimentação
					.And. ASCAN( aPneusReq, {|x| x[__CODBEM__] == aPNEUSFIM[nF][__CODBEM__]}) == 0 ) .Or. Len( aPneusReq ) == 0 )


					xRetVld := MNTA231STL( aPNEUSFIM[nF][__CODBEM__], nF, aPNEUSFIM[nF][__LOCPAD__], aPNEUSFIM[nF][__CODESTO__] )

					If ValType( xRetVld ) == 'L' 
			
						If !xRetVld
							lRet := xRetVld
							Exit
						EndIf

					EndIf
				
				EndIf
			
			EndIf

		Next nF

	EndIf

Return lRet

//-------------------------------------------------------------------------------
/*/{Protheus.doc} FinalizaOS
Finaliza a Ordem de Servico e salva as alteracoes feitas

@author Vitor Emanuel Batista
@since 18/08/2009

@sample FinalizaOS(oDlg)

@param  oDlg, Objeto, Objeto que contem os componentes de tela.
@return .T.
/*/
//-------------------------------------------------------------------------------
Static Function FinalizaOS(oDlg)

	If Eval(bVldCabec) .And. MsgYesNo(STR0084,STR0009)	 //"Deseja realmente finalizar esta Ordem de Serviço?"##"Atenção"
		If lTEMCONT .And. (nPOSCONT > 0 .Or. fCheckCont(1) )
			If !(MNTA231VCO(If(lPai,cPaiEst,cBemPai),nPOSCONT,1) .And. MNTA231HIS(nPOSCONT,cHORALE1,1,.T.,If(lPai,cPaiEst,cBemPai)))
				Return .F.
			EndIf
		EndIf
		If lTEMCON2 .And. (nPOSCON2 > 0 .Or. fCheckCont(2))
			If!(MNTA231VCO(cBemPai,nPOSCON2,2) .And. MNTA231HIS(nPOSCON2,cHORALE2,2,.T.,cBemPai))
				Return .F.
			EndIf
		EndIf

		MNTA231FIN( oDlg, cBemPai, dDTDATEM, nPOSCONT, cHORALE1, nPOSCON2, cHORALE2 )
	EndIf

Return .T.

//---------------------------------------------------------------------
/*/{Protheus.doc} MNTA232IMP
Gera relatorio em TMSPrinter ou gera objeto TPaintPanel da
estrutura do Bem Pai.
@author Vitor Emanuel Batista
@since 28/07/2010
@version undefined
@param cBem, characters, Bem Pai
@param oParse, object,  Objeto pai
@param lPrint, logical, Indica se deve imprimir ou gerar objeto.
@type function
/*/
//---------------------------------------------------------------------
Function MNTA232IMP(cBem,oParse,lPrint)

	Local cCodImg
	Local nLargura, nAltura

	//Variaveis de caminhos para as imagens
	Local cBARRAS     := If(isSRVunix(),"/","\")

	Private nPosEstru := 1
	Private aEstruturas
	Private cBemPai := cBem
	Private cCodFami,cTipMod

	If IsInCallStack("MNTA232") .Or. (IsInCallStack("MNTA995") .And. !IsInCallStack("MNTR995"))
		nIdTmp    := nId
		aShapeTmp := aShape
		aAllShapeTmp := aAllShape
		aRodizioTmp  := aRodizio
		aPNEUSINITMP := aPNEUSINI
		aPNEUSFIMTMP := aPNEUSFIM
		aBEMLOCTMP   := aBEMLOC
	EndIf

	//Variaveis de controle dos shapes
	Private nId       := 0
	Private aShape    := {}
	Private aAllShape := {}
	Private aRodizio  := {}

	//Variaveis do programa
	aPNEUSINI := {}
	aPNEUSFIM := {}
	aBEMLOC   := {}

	//Variavel padrao com o diretoria das imagens
	Private cDirImg   := GetTempPath()+"rodados"+cBARRAS

	Private cImgEstru

	If NGCADICBASE("TQ0_CODEST","A","TQ0",.F.)
		dbSelectArea("ST9")
		dbSetOrder(1)
		If dbSeek(xFilial("ST9")+cBemPai)
			nRecnoST9 := Recno()

			If lRel12133
				MNTSeekPad( 'TQ0', 1, ST9->T9_CODFAMI, ST9->T9_TIPMOD )
				cCodImg := TQ0->TQ0_CODEST
			Else
				cCodImg := NGSEEK("TQ0",ST9->T9_CODFAMI+ST9->T9_TIPMOD,1,"TQ0->TQ0_CODEST")
			EndIf

			If Empty(cCodImg)
				ShowHelpDlg(STR0009,	{STR0086},1,; //"Bem não possui Esquema Padrão Gráfico cadastrado."
				{STR0087},1) //"Cadastrar Esquema Padrão pela rotina Esquema Mod. 2 (MNTA221)"
				Return .F.
			EndIf
		Else
			Help(" ",1,"REGNOIS")
			Return .F.
		EndIf
	Else
		Return .F.
	EndIf

	cImgEstru   := cDirImg+"NG_ESTRUTURA_"+AllTrim(cCodImg)+".PNG"

	//Caso nao encontrar as imagens na temp ele recria.
	If !File( cImgEstru )
		MNTA232IMG()
	EndIf
	aEstruturas :=	NGRETESTRU(AllTrim(cCodImg))

	cCodFami := ST9->T9_CODFAMI
	cTipMod  := ST9->T9_TIPMOD

	nLargura := Val(aEstruturas[nPosEstru][2])+10
	nAltura  := Val(aEstruturas[nPosEstru][3])

	oTPanel := TPaintPanel():New(0,0,nLargura/2,nAltura/2,oParse,.F.)
	oTPanel:Hide()

	CriaCentro(oTPanel,0,0)

	ST9->(dbGoTo(nRecnoST9))
	If lPrint

		cImgEstru := GetTempPath()+cBARRAS+StrTran(Time(),":","")

		oTPanel:SaveToPng(0,0,nLargura,nAltura,cImgEstru+".png")
		oTPanel:Free()

		While !File( cImgEstru+".png" )
			Sleep( 1000 )
		End While

		//Exporta imagem para BMP para funcionar com o TMSPrinter
		oBmp := TBitmap():New(0,0,0,0,,,.T.,,,,,.F.,,,,,.T.)
		oBmp:Hide()
		If !oBmp:Load(,cImgEstru+".png")
			Return .F.
		EndIf

		oBmp:lStretch:= .T.
		oBmp:lTransparent := .T.
		oBmp:nHeight := nAltura*4
		oBmp:nWidth  := nLargura*4
		oBmp:nClrPane := CLR_WHITE
		oBmp:SaveAsBmp(cImgEstru+".bmp")
		oBmp:Free()

		oFont14 := TFont():New("Arial",14,14,,.T.,,,,.T.,.F.)
		cTitRel := STR0088+Alltrim(ST9->T9_CODBEM)+" - " //"Estrutura do Rodado...:   "
		cTitRel += ST9->T9_NOME+Space(10)+STR0089+"..: "+Alltrim(ST9->T9_TIPMOD)+" - "+ NGSEEK("TQR",ST9->T9_TIPMOD,1,"TQR_DESMOD") //"Modelo"

		oPrint := FWMSPrinter():New( STR0090, , .F., , .F. ) //"Impressao do Esquema de Rodado"
		oPrint:SetlandScape()
		oPrint:StartPage()
		oPrint:Say( 020,0040,cTitRel,oFont14 )
		oPrint:SayBitMap( 200, 200, cImgEstru + ".bmp", nLargura, nAltura )
		oPrint:EndPage()
		oPrint:Preview()
		FErase( cImgEstru + ".png" )
		FErase( cImgEstru + ".bmp" )

	Else
		oTPanel:Show()
	EndIf

	If IsInCallStack("MNTA232") .Or. (IsInCallStack("MNTA995") .And. !IsInCallStack("MNTR995"))
		nId    := nIdTmp
		aShape := aShapeTmp
		aAllShape := aAllShapeTmp
		aRodizio  := aRodizioTmp
		aPNEUSINI := aPNEUSINITMP
		aPNEUSFIM := aPNEUSFIMTMP
		aBEMLOC   := aBEMLOCTMP
	EndIf

Return oTPanel

//---------------------------------------------------------------------
/*/{Protheus.doc} MNTOPEN232
Verifica se o Bem informado pode ser aberto no modo Grafico,
verificando se este possui estrutura gráfica
@author Vitor Emanuel Batista
@since 17/05/2011
@version undefined
@param cBem, characters, Bem Pai
@type function
/*/
//---------------------------------------------------------------------
Function MNTOPEN232(cBem)

	Local lNew := .F.
	Local lFoundEP := .F.

	If NGCADICBASE("TQ0_CODEST","A","TQ0",.F.)
		dbSelectArea("ST9")
		dbSetOrder(1)
		If dbSeek(xFilial("ST9")+cBem)
			dbSelectArea("TQ0")
			dbSetOrder(1)

			If lRel12133
				lFoundEP := MNTSeekPad( 'TQ0', 1, ST9->T9_CODFAMI, ST9->T9_TIPMOD ) .And. !Empty(TQ0->TQ0_CODEST)
			Else
				lFoundEP := dbSeek(xFilial("TQ0")+ST9->T9_CODFAMI+ST9->T9_TIPMOD) .And. !Empty(TQ0->TQ0_CODEST)
			EndIf

			If lFoundEP
				lNew := .T.
			EndIf
		EndIf
	EndIf

Return lNew

//---------------------------------------------------------------------
/*/{Protheus.doc} AbreEmpresa
Abre empresa com SIX, SX2 e SX3
@author Vitor Emanuel Batista
@since 18/02/2009
@version undefined
@type function
/*/
//---------------------------------------------------------------------
Static Function AbreEmpresa()

	Local lOpen  := .F.
	Local cCodEmp  := ""
	Local cCodFil  := ""
	Local aTable   := {"ST9","ST6","STJ","TPY","STB","DA3"}

	//Abre tabelas necessarias
	If !(Type("oMainWnd")=="O")
		Private cAcesso := ""
		Private cPaisLoc:= ""

		cCodEmp := '99'
		cCodFil := '01'

		RPCSetType(3) //Nao utiliza licensa
		//Abre empresa/filial/modulo/arquivos
		RPCSetEnv(cCodEmp,cCodFil,"","","MNT","",aTable)

		lOpen := .T.
	EndIf

Return lOpen

//---------------------------------------------------------------------
/*/{Protheus.doc} MNT232MOTWH
When do campo ST8->T8_TIPO quando via consulta pelo MNTA232 ou MNTA231

@author Jackson Machado
@since 23/09/2011

@version undefined
@type function
@return lRet, Lógico, Quando falso trava o campo.
/*/
//---------------------------------------------------------------------
Function MNT232MOTWH()

	Local lRet := .T.
	Local oModel125

	If IsInCallStack("MNTA232") .or. IsInCallStack("MNTA231")
		lRet := .F.
	ElseIf IsInCallStack("MNTA125") // Cadastro de Ocorrências da Manutenção
		oModel125 := FWModelActive()
		If oModel125:GetOperation() == 4 // Caso seja alteração, fecha campo T8_TIPO
			lRet := .F.
		EndIf
	Endif

Return lRet
//---------------------------------------------------------------------
/*/{Protheus.doc} MNT232B2LO
Valida se existe mais de um almoxarifado para o produto

@return Lógico - Retorna verdadeiro caso tenha mais de um armazem para o produto,
@return caso contrario, retornará falso pois tem apenas um armazem (ou nenhum)

@param cProd - Codigo do Produto a ser verificado

@sample
MNT232B2LO( 'PROD01' )

@author Jackson Machado
@since 12/02/2013
@version 1.0
/*/
//---------------------------------------------------------------------
Function MNT232B2LO( cProd )

	Local nAlm  := 0
	Local lRet  := .T.
	Local aArea := GetArea()

	dbSelectArea( "SB2" )
	dbSetOrder( 1 )
	dbSeek( xFilial( "SB2" ) + cProd )
	While SB2->( !Eof() ) .And. SB2->B2_FILIAL == xFilial("SB2") .And. SB2->B2_COD == cProd
		nAlm ++
		SB2->( dbSkip() )
	End

	RestArea(aArea)

	lRet := nAlm > 1

Return lRet
//---------------------------------------------------------------------
/*/{Protheus.doc} NG232CHKBE
Função que verifica se o bem possui ordem de serviço em aberto.

@param string cBemST9 - Codigo do bem a ser verificado - Obrigatorio

@author Guilherme Benkendorf
@since 16/07/13
@version MP11
@return Nil
/*/
//---------------------------------------------------------------------
Function NG232CHKBE( cBemST9 )

	Local aArea		:= GetArea()
	Local cAlsTemp	:= ""
	Local cQuery	:= ""
	Local lRet		:= .T.

	cAlsTemp:= GetNextAlias()
	//Verifica a existencia de ordem de servico preventiva do Bem
	cQuery	:= "SELECT count(*) NQTD FROM " + RetSqlName("STJ") + " "
	cQuery	+= "STJ WHERE STJ.TJ_FILIAL = '" + xFilial("STJ") + "' AND "
	cQuery	+= "STJ.TJ_CODBEM = '" + NGRETTXT(Alltrim(cBemST9)) + "' AND "
	cQuery	+= "STJ.TJ_SITUACA = 'L' AND STJ.TJ_TERMINO = 'N' AND "
	cQuery	+= "STJ.D_E_L_E_T_ <> '*'"
	cQuery	:= ChangeQuery(cQuery)
	dbUseArea( .T. , "TOPCONN" , TcGenQry(,,cQuery) ,cAlsTemp,.T.,.T.)

	dbSelectArea(cAlsTemp)
	dbGoTop()
	//Caso tenha OS, sera mostrado que existe ordem e deseja continuar o processo
	If (cAlsTemp)->NQTD > 0
		lRet := .F.
	EndIf

	(cAlsTemp)->( dbCloseArea() )

	If !lRet
		Help("",1,STR0062,,STR0109,2,1)//"NAO CONFORMIDADE"//"Não foi possível continuar o processo."//"Existe Ordem de Serviço aberta para manutenção do bem."
	EndIf

	RestArea(aArea)

Return lRet

//---------------------------------------------------------------------
/*/{Protheus.doc} fVerTpCont
Verifica o tipo do contador do bem em questão

@author Lucas Guszak
@since 16/12/13
@version MP11
@return lRet
/*/
//---------------------------------------------------------------------
Static Function fVerTpCont()

	Local lRet := .T.

	If ST9->T9_TEMCONT == "S"
		lRet := .T.
	ElseIf ST9->T9_TEMCONT == "P" .Or. ST9->T9_TEMCONT == "I"
		lContPai := .T.
		lRet := .F.
	Else
		lRet := .F.
	EndIf

Return lRet

//---------------------------------------------------------------------
/*/{Protheus.doc} fVerBemPai
Verifica o bem pai da estrutura de acordo com a data e hora informados

OBS.: SOMENTE CONTADOR 1, FICA PEDENTE TRATAMENTO CONTADOR 2

@author Lucas Guszak
@since 17/12/13
@version MP11
@return lRet
/*/
//---------------------------------------------------------------------
Static Function fVerBemPai(oPanel,nCabecX,nCabecY,cIdShapBem,cIdShapCT1)

	Local aAreaST9 := ("ST9")->(GetArea())

	//-------------------------
	// cBemPai - Bem em questao
	// cPaiEst - Pai do cBemPai
	//-------------------------

	//Somente verifica apos de data e hora preenchidos
	If !Empty(dDTDATEM) .And. cHORALE1 != "  :  "

		DbSelectArea("ST9")
		DbSetOrder(1)
		If DbSeek(xFilial("ST9")+cBemPai)

			//Verifica se o tipo do contador do bem
			If ST9->T9_TEMCONT == "P" .Or. ST9->T9_TEMCONT == "I"

				//Preenche com o pai da estrutura
				cPaiEst := NGBEMPAI(ST9->T9_CODBEM,dDTDATEM,cHORALE1)

				DbSelectArea("ST9")
				DbSetOrder(1)
				If	DbSeek(xFilial("ST9")+If(Empty(cPaiEst),cBemPai,cPaiEst))

					lPai		:= If(Empty(cPaiEst),.F.,.T.)
					lTEMCONT	:= If(  ST9->T9_TEMCONT == "S" , .T. , .F. )
					cDescBem	:= Trim(ST9->T9_CODBEM)	+ " - " + Trim(ST9->T9_NOME)
					cDesTipMod	:= Trim(ST9->T9_TIPMOD)	+ " - " + Trim(NGSEEK("TQR",ST9->T9_TIPMOD,1,"TQR->TQR_DESMOD"))
					cDesCodFam	:= Trim(ST9->T9_CODFAMI)	+ " - " + Trim(NGSEEK("ST6",ST9->T9_CODFAMI,1,"ST6->T6_NOME"))

					//---------------------------------------
					// Apaga labels
					//---------------------------------------
					oPanel:DeleteItem(Val(cIdShapBem)) //Bem: ou Bem Pai:
					oPanel:DeleteItem(Val(cIdShapCT1)) //Contador 1:

					//-----------------------
					// Bem: ou Bem Pai:
					//-----------------------
					oPanel:addShape("id="+cIdShapBem+";type=7;left="+Str(nCabecX)+";top="+Str(nCabecY)+";width=200;height=30;"+;
					"text="+If(lPai,STR0110,STR0014)+";font=Verdana,08,0,0,1;pen-color=#000000;pen-width=1;is-container=0") //"Bem:" ## "Bem Pai:"

					//-----------------------
					// Contador 1:
					//-----------------------
					oPanel:addShape(	"id="+cIdShapCT1+";type=7;left="+Str(nCabecX+525)+";top="+Str(nCabecY+27)+;
					";width=200;height=30;text="+STR0018+";font=Verdana,08,0,0,1;pen-color=#"+If(lTEMCONT,"0000FF","000000")+";pen-width=1;is-container=0") //"Contador 1:"

					//Atualiza tela
					oPanel:Owner():CommitControls()

				EndIf
			EndIf
		EndIf
	EndIf

	If !lTEMCONT
		nPOSCONT := 0
	EndIf

	RestArea(aAreaST9)

Return .T.

//---------------------------------------------------------------------
/*/{Protheus.doc} fCheckCont
Verifica se os Pneus tem contador próprio ou segundo contador

@param nTpCont - 1 = Primeiro contador; 2 = Segundo contador.
@param BemPai - Bem pai para buscar a estrutura dos pneus.

@author Tainã Alberto Cardoso
@since 07/12/15
@version MP11
@return lRet
/*/
//---------------------------------------------------------------------
Static Function fCheckCont(nTpCont)

	Local nX        := 0
	Local lValid := .F.
	Local lDtvSgCnt := NGCADICBASE("TPE_SITUAC", "A", "TPE", .F.) //Indica se é possível ativar/desativar segundo contador

	//Percorre os Pneus que ja estavam na estrutura
	For nX := 1 to Len(aPNEUSINI)

		If !Empty(aPNEUSINI[nx][__CODBEM__])

			//Verificar se é para validar o primeiro contador
			If nTpCont == 1

				dbSelectArea("ST9")
				dbSetOrder(1)
				If dbSeek(xFilial("ST9") + aPNEUSINI[nx][__CODBEM__])

					If ST9->T9_TEMCONT $ "P/I"
						lValid := .T.
						Exit
					EndIf

				EndIf

			Else //Verifica se é segundo contador
				If MNT2322CNT(xFilial("TPE"),lDtvSgCnt,aPNEUSINI[nx][__CODBEM__])
					lValid := .T.
					Exit

				EndIf

			EndIf

		EndIf

	next Nx

	If !lValid

		//Percorre os Pneus que vão para a estrutura
		For nX := 1 to Len(aPNEUSFIM)

			If !Empty(aPNEUSFIM[nx][__CODBEM__])

				//Verificar se é para validar o primeiro contador
				If nTpCont == 1

					dbSelectArea("ST9")
					dbSetOrder(1)
					If dbSeek(xFilial("ST9") + aPNEUSFIM[nx][__CODBEM__])

						If ST9->T9_TEMCONT $ "P/I"
							lValid := .T.
							Exit
						EndIf

					EndIf

				Else //Verifica se é segundo contador

					dbSelectArea("TPE")
					dbSetOrder(1)
					If MNT2322CNT(xFilial("TPE"),lDtvSgCnt,aPNEUSFIM[nx][__CODBEM__])
						lValid := .T.
						Exit
					EndIf

				EndIf

			EndIf

		next Nx

	EndIf

Return lValid
//---------------------------------------------------------------------
/*/{Protheus.doc} fValHrL1
Valida se o campo de hora está vazio

@param cHora: Hora
@author Wexlei Silveira
@since 23/01/2017
@version MP11
@return True
/*/
//---------------------------------------------------------------------
Static Function fValHrL1(cHora)

Local lRet := .T.

If Empty(StrTran(cHora, ":",""))
	lRet := .F.
	MsgStop(STR0137,STR0009) //O preenchimento do campo Hora Leitura é obrigatório
EndIf

Return lRet

//-------------------------------------------------------------------------------------------
/*/{Protheus.doc} MNT2322CNT
Valida se:
1) Existe o segundo contador
2) Se existe, verifica se é permitido desativar o mesmo, e retorna se está ou não ativado.


@author Maicon André Pinheiro
@since 30/03/2017
@return bool lRet
@param lDtvSgCnt  - Verifica se é possível desativar segundo contador
	   cTQN_Frota - Frota que está validada.
@version P12
/*/
//-------------------------------------------------------------------------------------------
Static Function MNT2322CNT(cFilVld,lDtvSgCnt,cTQN_Frota)

	Local lRet := .F. //Não existe segundo contador ou está desativado.

	dbSelectArea("TPE")
	dbSetOrder(1)
	If dbSeek(cFilVld + cTQN_Frota)
		lRet := IIf(lDtvSgCnt, TPE->TPE_SITUAC == "1", .T.)
	EndIf

Return lRet
//---------------------------------------------------------------------
/*/{Protheus.doc} MNTA232CCB
Carrega o valor do contador do bem se o campo estiver bloqueado pelo
parâmentro NGLANEX

@param cCobBem: Código do bem
@param dData: Data
@param cHora: Hora
@author Wexlei Silveira
@since 07/06/2016
@version MP11
@return True
/*/
//---------------------------------------------------------------------
Static Function MNTA232CCB(cCobBem, dData, cHora)

	If FindFunction("NGBlCont") .And. !NGBlCont( cCobBem )
		nPOSCONT := NGTpCont(cCobBem, dData, cHora)
	EndIf

Return .T.

//-------------------------------------------------------------------------------------------
/*/{Protheus.doc} fBuscaAlt
//Efetuada busca nas movimentaçãoes, verificando se a O.S. em questão já realizou alguma
movimentação na estrutura.

@author Eduardo Mussi
@since 06/09/2017
@return lRet - Caso tenha movimentações .T.
@version P12
/*/
//-------------------------------------------------------------------------------------------
Static Function fBuscaAlt()

	Local lRet  	:= .F.
	Local aArea 	:= GetArea()
	Local cAliasQry := GetNextAlias()

	BeginSQL Alias cAliasQry
		SELECT STZ.R_E_C_N_O_ FROM %table:STZ% STZ
			WHERE
				TZ_FILIAL = %xFilial:STZ% AND
				TZ_BEMPAI = %exp:cBemPai% AND
				TZ_ORDEM  = %exp:cNumOs%  AND
				STZ.%notDel%
	EndSQL

	dbSelectArea( cAliasQry )
	lRet := IIf( (cAliasQry)->R_E_C_N_O_ > 0, .T., .F.)

	RestArea(aArea)

Return lRet

//---------------------------------------------------------------------
/*/{Protheus.doc} NGCONPNEU
Monta tela de consulta de Pneus

@author Tainã Alberto Cardoso
@since 23/02/17
@version MP11
@return lRet
/*/
//---------------------------------------------------------------------
Function NGCONPNEU()

	Local vST9Ind      := {NGRETTITULO("T9_CODBEM")}
	Local lRet         := .F.
	Local oBtn3        := Nil
	Local oBtn2        := Nil
	Local oBtn1        := Nil
	Local oChvSTJ      := Nil
	Local oBtnBuscar   := Nil

	Private cChaST9    := Space(TAMSX3("T9_CODBEM")[1])
	Private aLST9      := {}
	Private oOrdST9    := Nil
	Private cST9Ix     := ""
	Private cOrdemR    := ""
	Private lCheck1    := .F.
	Private lCheck2    := .F.
	Private nTipConsul := 1
	Private aSTJLN     := {}

	dbSelectArea( cAliQryTQI )
	Set Filter To (cAliQryTQI)->T9_CODFAMI == cFilFami
	(cAliQryTQI)->( dbGoTop() )

	DEFINE MSDIALOG oDlgCE TITLE OemToAnsi( STR0138 ) From 0,0 To 400,500 OF oMainWnd PIXEL //"Consulta de Pneus"

		//Painel TOP
		oPnlTop := TPanel():New(01, 01, , oDlgCE, , , , CLR_BLACK, CLR_WHITE, 50, 40)
		oPnlTop:Align := CONTROL_ALIGN_TOP

			@ 02,005 Combobox oOrdST9 Var cST9Ix Items vST9Ind Size 170,08 Pixel Of oPnlTop
			@ 02,180 Button oBtnBuscar Prompt STR0139 Of oPnlTop Size 30,11 Pixel Action MNT232ST9P() //"Buscar"
			@ 15,005 MsGet oChvSTJ Var cChaST9 Picture "@!" Size 170,08 Of oPnlTop Pixel

			oCheck1 := TCheckBox():New(27,07,STR0140,,oPnlTop, 100,10,,,,,,,,.T.,,,) //"Posicionar na browse na abertura"
			oCheck1:bSetGet     := {|| lCheck1 }
			oCheck1:bLClicked   := {|| lCheck1:=!lCheck1 }
			oCheck1:bWhen       := {|| .T. }

		//Painel MID
		oPnlMid := TPanel():New(01, 01, , oDlgCE, , , , CLR_BLACK, CLR_WHITE, 50, 35)
		oPnlMid:Align := CONTROL_ALIGN_ALLCLIENT

			@ 40,005 ListBox oLST9 ;//Var cList4;
		         Fields ;
		         (cAliQryTQI)->T9_CODBEM,;
		         (cAliQryTQI)->T9_NOME,;
		         ColSizes 40,40,40,50;
		         Size 210,100 Of oPnlMid Pixel;
		         HEADERS STR0141               ,; //"Código"
                             STR0142               ; //"Nome"

			oLST9:Align := CONTROL_ALIGN_ALLCLIENT
			oLST9:blDblClick := { || lRet := .T. ,NGIFDBSEEK("ST9",(cAliQryTQI)->T9_CODBEM,1),oDlgCE:End() }
			oLST9:REFRESH()
			oLST9:REFRESH()

		//Painel BOT
		oPnlBot := TPanel():New(01, 01, , oDlgCE, , , , CLR_BLACK, CLR_WHITE, 50, 20)
		oPnlBot:Align := CONTROL_ALIGN_BOTTOM

		DEFINE SBUTTON oBtn1 FROM 005,005 TYPE  1 ENABLE OF oPnlBot ACTION  (lRet := .T. ,NGIFDBSEEK("ST9",(cAliQryTQI)->T9_CODBEM,1),oDlgCE:End())
		DEFINE SBUTTON oBtn2 FROM 005,035 TYPE  2 ENABLE OF oPnlBot ACTION ( lRet := .F. ,oDlgCE:End())
		DEFINE SBUTTON oBtn3 FROM 005,065 TYPE 15 ENABLE OF oPnlBot ACTION NGVISUESPE("ST9",(cAliQryTQI)->T9_CODBEM)

	ACTIVATE MSDIALOG oDlgCE CENTERED
	(cAliQryTQI)->( dbClearFilter() )

Return lRet

//---------------------------------------------------------------------
/*/{Protheus.doc} MNT232ST9P

Filtro da matriz com as ordens de serviço

@author Tainã Alberto Cardoso
@since 23/02/17
@version MP11
@return lRet
/*/
//---------------------------------------------------------------------
Function MNT232ST9P()

	dbSelectArea(cAliQryTQI)
	dbSetOrder(1)
	dbSeek( Alltrim(cChaST9) )
	oLST9:REFRESH()


Return .T.

//---------------------------------------------------------------------
/*/{Protheus.doc} MNT232ListP
Filtra Pneus para montar a consulta padrão.
@type function

@author Tainã Alberto Cardoso
@since 23/02/17

@return .T.
/*/
//---------------------------------------------------------------------
Function MNT232ListP()

	Local aDbf       := {}
	Local aIndAux    := {}
	Local cQueryTQI  := ""
	Local oTempTable := Nil
	//Criadas variáveis para evitar 'Alltrim' que não funciona em banco Oracle
	Local cNotSTAGR  := IIf(!Empty(cNGSTAGR),cNGSTAGR,Space(1))
	Local cNotSTAGC  := IIf(!Empty(cNGSTAGC),cNGSTAGC,Space(1))
	Local cNotSTAAT  := IIf(!Empty(cNGSTAAT),cNGSTAAT,Space(1))

	//Monta estrutura e índice para criação de tabela temporária.
	aDbf := {{"T9_CODBEM" , "C", TAMSX3("T9_CODBEM")[1] , 0},;
	         {"T9_NOME"   , "C", TAMSX3("T9_NOME")[1]   , 0},;
			 {"T9_CODFAMI", "C", TAMSX3("T9_CODFAMI")[1], 0}}

	aIndAux    := {{ "T9_CODBEM" }}
	oTempTable := NGFwTmpTbl(cAliQryTQI, aDbf, aIndAux)

	//Insere os pneus na tabela temporaria conforme filtro na ST9
	cQueryTQI := "INSERT INTO " + oTempTable:GetRealName()
	cQueryTQI +=     " ("
	cQueryTQI +=      " T9_CODBEM,"
	cQueryTQI +=      " T9_NOME  ,"
	cQueryTQI +=      " T9_CODFAMI"
	cQueryTQI +=     " )"
	cQueryTQI += " SELECT"
	cQueryTQI +=      " T9_CODBEM,"
	cQueryTQI +=      " T9_NOME  ,"
	cQueryTQI +=      " T9_CODFAMI"
	cQueryTQI += " FROM "
	cQueryTQI +=      RetSqlName("ST9")
	cQueryTQI += " WHERE"
	cQueryTQI +=    " T9_SITBEM  = 'A' AND"
	cQueryTQI +=    " T9_CATBEM  = '3' AND"
	cQueryTQI +=    " T9_ESTRUTU = 'N' AND"
	cQueryTQI +=    " T9_FILIAL  =  " + ValToSQL(xFilial("ST9")) + "AND"
	cQueryTQI +=    " T9_STATUS IN (" + StrTran(ValToSQL(cNGSTAEU), ",", "','") + ", "
	cQueryTQI += 			            ValToSQL(cNGSTAER) + ", "
	cQueryTQI += 			            ValToSQL(cNGSTAEN) + ", "
	cQueryTQI += 			            ValToSQL(cNGSTEST) + ") AND"
	cQueryTQI +=    " T9_STATUS NOT IN (" + ValToSQL(cNotSTAGR) + "," + ValToSQL(cNotSTAGC) + "," + ValToSQL(cNotSTAAT) + ") AND"
	cQueryTQI +=    " D_E_L_E_T_ <> '*'"

	TcSQLExec(cQueryTQI)

Return .T.

//---------------------------------------------------------------------
/*/{Protheus.doc} MNTA232CTA
Valida item contabil do Pneu
@type function

@author Tainã Alberto Cardoso
@since 14/09/18

@return .T.
/*/
//---------------------------------------------------------------------
Function MNTA232CTA()

	Local lRet := .T.

	If !Empty( cItemCTA )
		lRet := Ctb105Item( cItemCTA ) //Envia o item contábil via parâmetro
		If lRet
			cNomeCTA := NGSEEK('CTD',cItemCTA,1,'CTD->CTD_DESC01')
		EndIf
	Else
		cNomeCTA := ""
	EndIf

Return lRet

//---------------------------------------------------------------------
/*/{Protheus.doc} fDelet
Deleta lançamentos de contador posteriores a movimentação
Utilizado para os pneus que saem da estrutura - para mov. retroativa

@author Maria Elisandra de Paula
@since 05/12/2019
@param aRemov, array, pneus que saíram da estrutura
@param dDtMov, date, data da movimentação
@param cHrMov, string, hora da movimentação
@param cHrCnt2, string, hora do contador 2
@return Nil
/*/
//---------------------------------------------------------------------
Static Function fDelet( aRemov, dDtMov, cHrMov, cHrCnt2 )

	Local cCodPneu  := ""
	Local nIndex    := 0
	Local cAliasQry := ""

	For nIndex := 1 To Len( aRemov )

		cCodPneu := aRemov[ nIndex, 1 ]

		//--------------------------------------
		// Busca STP posteriores
		//--------------------------------------
		cAliasQry := GetNextAlias()
		BeginSql Alias cAliasQry
			SELECT STP.TP_DTLEITU, STP.TP_HORA, STP.R_E_C_N_O_ RECNOSTP
			FROM %table:STP% STP
			WHERE  STP.TP_FILIAL = %xFilial:STP%
				AND  STP.TP_CODBEM = %Exp:cCodPneu%
				AND STP.TP_DTLEITU || STP.TP_HORA > %Exp:Dtos( dDtMov ) + cHrMov%
				AND STP.%NotDel%
			ORDER BY STP.TP_DTLEITU || STP.TP_HORA DESC
		EndSql

		While (cAliasQry)->( !Eof() )

			//--------------------------------
			// Decrementa Km da Banda do pneu
			//--------------------------------
			NGKMTQS( cCodPneu, Stod( (cAliasQry)->TP_DTLEITU ), (cAliasQry)->TP_HORA, .T. )

			//-------------------------------------------------------------
			// Exclui STP
			//-------------------------------------------------------------
			dbSelectArea("STP")
			dbGoto( (cAliasQry)->RECNOSTP )

			RecLock("STP",.F.)
			DbDelete()
			MsUnLock()

			(cAliasQry)->( dbSkip() )

		End

		(cAliasQry)->( dbCloseArea() )

		//--------------------------------------
		// Remove contador 2
		//--------------------------------------
		cAliasQry := GetNextAlias()
		BeginSql Alias cAliasQry
			SELECT TPP.R_E_C_N_O_ RECNOTPP
			FROM %table:TPP% TPP
			WHERE  TPP.TPP_FILIAL = %xFilial:TPP%
				AND  TPP.TPP_CODBEM = %Exp:cCodPneu%
				AND TPP.TPP_DTLEIT || TPP.TPP_HORA > %Exp:Dtos( dDtMov ) + cHrMov%
				AND TPP.%NotDel%
			ORDER BY TPP.TPP_DTLEIT || TPP.TPP_HORA DESC
		EndSql

		While (cAliasQry)->( !Eof() )

			dbSelectArea("TPP")
			dbGoto( (cAliasQry)->RECNOTPP )
			RecLock("TPP",.F.)
			DbDelete() // Exclui TPP
			MsUnLock()
			(cAliasQry)->( dbSkip() )

		End

		(cAliasQry)->( dbCloseArea() )

	Next nIndex

Return

//---------------------------------------------------------------------
/*/{Protheus.doc} fCreateCont
Inclui STP posteriores a movimentação.
Utilizado para os pneus que entram na estrutura

@author Maria Elisandra de Paula
@since 14/01/2020
@param aCreate, array, pneus que entraram na estrutura
@param dDtMov, date, data da movimentação
@param cHrCont, string, hora da movimentação
@param nPosconX, numerico, valor do contador
@param nType, numerico, tipo de contador 1 ou 2
@return Nil
/*/
//---------------------------------------------------------------------
Static Function fCreateCont( aCreate, dDtMov, cHrCont, nPosconX, nType )

	Local cCodPneu  := ""
	Local cFather   := ""
	Local cAliasQry := ""
	Local nAcumuPn	:= 0
	Local nAcumuPai := 0
	Local nVardiaPn := 0
	Local nIndex    := 0
	Local nCountPn  := 0
	Local dDtLeitu  := Ctod(' / / ')
	Local lUpdBem   := .F.

	For nIndex := 1 To Len( aCreate )

		nAcumuPn  := 0
		nAcumuPai := 0
		cCodPneu  := aCreate[ nIndex,1 ]

		// busca infos do pneu quando entrou na estrutura
		dbSelectArea("STZ")
		dbGoTo( aCreate[ nIndex,2 ] )

		If STZ->TZ_TEMCONT == "P"
			cFather	:= NGBEMPAI( cCodPneu )
		Else
			cFather	:= STZ->TZ_BEMPAI
		EndIf

		nAcumuPn  := NGGetCont( cCodPneu, dDtMov, cHrCont, , .F.,, cFather ) // Acumulado pneu quando entrou na estrutura
		nAcumuPai := fAcumPai( cFather, dDtMov, cHrCont, nPosconX, nType ) // Acumulado pai quando pneu entra na estrutura

		cAliasQry := GetNextAlias()

		If nType == 1

			// Busca as movimentações posteriores - bem Pai
			BeginSql Alias cAliasQry
				SELECT STP.TP_FILIAL FILIAL,
					STP.TP_DTLEITU DTLEITU,
					STP.TP_HORA HORA,
					STP.TP_POSCONT POSCONT,
					STP.TP_ACUMCON ACUMCON,
					STP.TP_TIPOLAN TIPOLAN
				FROM %Table:STP% STP
				WHERE STP.TP_CODBEM = %exp:cFather%
					AND %NotDel%
					AND STP.TP_FILIAL = %xFilial:STP%
					AND STP.TP_DTLEITU || STP.TP_HORA > %exp:dtos( dDtMov ) + cHrCont%
				ORDER BY STP.TP_DTLEITU || STP.TP_HORA
			EndSql

		Else

			BeginSql Alias cAliasQry
				SELECT TPP.TPP_FILIAL FILIAL,
					TPP.TPP_DTLEIT DTLEITU,
					TPP.TPP_HORA HORA,
					TPP.TPP_POSCON POSCONT,
					TPP.TPP_ACUMCO ACUMCON,
					TPP.TPP_TIPOLA TIPOLAN
				FROM %Table:TPP% TPP
				WHERE TPP.TPP_CODBEM = %exp:cFather%
					AND %NotDel%
					AND TPP.TPP_FILIAL = %xFilial:TPP%
					AND TPP.TPP_DTLEIT || TPP.TPP_HORA > %exp:dtos( dDtMov ) + cHrCont%
				ORDER BY TPP.TPP_DTLEIT || TPP.TPP_HORA
			EndSql

		EndIf
		// Repassa para o pneu todas as movimentações do Pai
		While (cAliasQry)->( !Eof() )

			lUpdBem   := .T.
			dDtLeitu  := Stod( (cAliasQry)->DTLEITU )
			nAcumuPn  := (cAliasQry)->ACUMCON - nAcumuPai + nAcumuPn
			nVardiaPn := NGVARIADT( cCodPneu, dDtLeitu, 1, nAcumuPn, .F., .F. )
			nCountPn  := (cAliasQry)->POSCONT

			NGGRAVAHIS( cCodPneu, (cAliasQry)->POSCONT, nVardiaPn, dDtLeitu, nAcumuPn ,0,(cAliasQry)->HORA, nType,;
						(cAliasQry)->TIPOLAN, (cAliasQry)->FILIAL, (cAliasQry)->FILIAL)

			nAcumuPai	:= (cAliasQry)->ACUMCON // backup do acumulado para próxima gravação

			(cAliasQry)->( DbSkip() )
		EndDo
		(cAliasQry)->( dbCloseArea() )

	Next nIndex

	// Ajusta tabela do bem
	If lUpdBem
		If nType == 1
			dbSelectArea("ST9")
			dbSetOrder(1)
			If dbSeek( xFilial("ST9") + cCodPneu  )
				Reclock( "ST9", .F. )
				ST9->T9_CONTACU := nAcumuPn
				ST9->T9_POSCONT	:= nCountPn
				ST9->T9_VARDIA	:= nVardiaPn
				ST9->T9_DTULTAC := dDtLeitu
				MsUnlock()
			EndIf
		Else
			dbSelectArea("TPE")
			dbSetOrder(1)
			If dbSeek( xFilial("TPE") + cCodPneu  )
				Reclock( "TPE", .F. )
				TPE->TPE_CONTAC := nAcumuPn
				TPE->TPE_POSCON	:= nCountPn
				TPE->TPE_VARDIA	:= nVardiaPn
				TPE->TPE_DTULTA := dDtLeitu
				MsUnlock()
			EndIf

		EndIf

	EndIf

Return

//---------------------------------------------------------------------
/*/{Protheus.doc} MNT232PAST
Adiciona ou remove lançamentos de contador para pneus
em movimentação retroativa

@author Maria Elisandra de Paula
@since 27/01/2020
@param aBensSaida, array, pneus com movimento saida, inclusive rodizio
	[1] - Código do bem
	[2] - Recno da movimentação na STZ
	[3] - Se posição na estrutura movimenta contador
@param aBensEntra, array, pneus com movimento entrada, inclusive rodizio
	[1] - Código do bem
	[2] - Recno da movimentação na STZ
	[3] - Se posição na estrutura movimenta contador
@param dDtMov, date, data da movimentação
@param cHrMov1, string, hora da movimentação
@param nPosconX1, numerico, posição do contador
@return Nil
/*/
//---------------------------------------------------------------------
Function MNT232PAST( aBensSaida, aBensEntra, dDtMov, cHrMov1, nPosconX1, cHrCnt2, nPosconX2 )

	Local nX      := 0
	Local nRodiz  := 0
	Local aRemov  := {}
	Local aCreate := {}

	For nX := 1 to Len( aBensSaida )

		nRodiz := aScan( aBensEntra, { |x| x[1] == aBensSaida[nX, 1] } )

		If nRodiz == 0 .Or. ; // pneus que saem da estrutura definitivamente
			( aBensSaida[nX,3] .And. !aBensEntra[nRodiz,3] ) // pneu de rodizio - sai de uma posicão com contador e entra no estepe

			aAdd( aRemov, aBensSaida[nX] )

		EndIf

	Next

	For nX := 1 to Len( aBensEntra )

		nRodiz := aScan( aBensSaida, { |x| x[1] == aBensEntra[nX, 1] } )

		If nRodiz == 0 .And. !aBensEntra[nX,3]
			// entra na estrutura na posição do estepe
			Loop
		EndIf

		If nRodiz == 0 .Or. ; // pneu que entra na estrutura em uma posição que leva contador
			( !aBensSaida[nRodiz,3] .And. aBensEntra[nX,3] ) // pneu de rodizio - sai do estepe e entra numa posição que leva contador

			aAdd( aCreate, aBensEntra[nX] )

		EndIf

	Next

	fDelet( aRemov, dDtMov, cHrMov1, cHrCnt2 ) // Remove lançamentos de contador posteriores a saída
	fCreateCont( aCreate, dDtMov, cHrMov1, nPosconX1, 1) // Inclui lançamentos de contador posteriores a entrada

	If lTEMCON2
		fCreateCont( aCreate, dDtMov, cHrCnt2, nPosconX2, 2 ) // Inclui lançamentos do segundo contador
	EndIf

Return

//---------------------------------------------------------------------
/*/{Protheus.doc} fAcumPai
Calcula o acumulado do bem de acordo com novo lançamento

@author Maria Elisandra de Paula
@since 27/01/2020
@param cFather, string, codigo do bem
@param dDtMov, date, data da movimentação
@param cHrMov, string, hora da movimentação
@param nPosconX, numerico, posição do contador
@param nType, numerico, tipo de contador - 1 ou 2
@return Nil
/*/
//---------------------------------------------------------------------
Static Function fAcumPai( cFather, dDtMov, cHrMov, nPosconX, nType )

	Local cLanex     := IIf( FindFunction('NGUSELANEX'), NGUSELANEX( cFather ) , ;
						AllTrim( SuperGetMv( 'MV_NGLANEX', .F., '' ) )  )
	Local nAcumuPai  := NGGetCont( cFather, dDtMov, cHrMov, cLanex, .F.,, cFather ) // Acumulado anterior

	Local nPosAntPai := 0
	Local nAux       := 0
	Local nMax       := 0

	Default nType := 1

	If !Empty( cLanex )

		nPosAntPai := NGGetCont( cFather, dDtMov, cHrMov, cLanex , .T.,, cFather ) // posição anterior

		If nPosconX < nPosAntPai // virada
			If nType == 1
				nMax :=  NGSEEK("ST9", cFather, 1, "ST9->T9_LIMICON" )
			Else
				nMax :=  NGSEEK("TPE", cFather, 1, "TPE->TPE_LIMICO" )
			EndIf

			nAux :=  nMax - nPosAntPai + nPosconX

		Else

			nAux := nPosconX - nPosAntPai

		EndIf

	EndIf

	nAcumuPai := nAcumuPai + nAux

Return nAcumuPai

//---------------------------------------------------------------------
/*/{Protheus.doc} MNT232VERS
Verifica se fontes auxiliares estão atualizados

@author Maria Elisandra de Paula
@since 27/01/2020
@return Nil
/*/
//---------------------------------------------------------------------
Function MNT232VERS()

	Local cFonteAtu := '2020021808:00:00'
	Local aInfoRpo  := GetApoInfo( 'MNTUTIL_ESTRUTURA.PRW' )
	Local lRet      := DtoS( aInfoRpo[4] ) + aInfoRpo[5] >= cFonteAtu

	If lRet
		cFonteAtu := '2020021311:28:04'
		aInfoRpo  := GetApoInfo( 'MNTUTIL_CONTADOR.PRW' )
		lRet      := DtoS( aInfoRpo[4] ) + aInfoRpo[5] >= cFonteAtu
	EndIf

Return lRet

//---------------------------------------------------------------------
/*/{Protheus.doc} fVldEmissa
Valida a data de movimentação do estoque de pneus aguardando aplicação

@author Maria Elisandra de Paula
@since 26/10/2020
@return boolean
/*/
//---------------------------------------------------------------------
Static Function fVldEmissa()

	Local lRet   := .T.
	Local nAscan := 0

	If !Empty( dDTDATEM )
		nAscan := aScan( aPneusReq, {|x| x[ __EMISSAO__ ] > dDTDATEM } )
		If nAscan > 0
			Help("",1,STR0062,,STR0148 + CRLF + Dtoc( aPneusReq[nAscan, __EMISSAO__] ),2,1) // "Os pneus originados do estoque possuem data de movimentação superior a data informada."
			lRet := .F.
		EndIf
	EndIf

Return lRet

//---------------------------------------------------------------------
/*/{Protheus.doc} fContPneus
Validação de linha para contador do pneu.
@type function

@author Alexandre Santos
@since 29/06/2023

@return boolean , Indica se o contador está validado.
/*/
//---------------------------------------------------------------------
Static Function fContPneus()

	Local aHdPneus   := {}
	Local cCadBkp    := cCadastro
	Local lOk        := .T.
	Local oDlgPneus
	Local oPanel1
	Local oPanel2
	Local oPanel3
	
	Private oGdPneus 

	/*---------------------------------------------------------+
	| Monta aHeader e aCols para tela de contadores dos pneus. |
	+---------------------------------------------------------*/
	fGeraCols( @aHdPneus, @aPneuCont )

	/*-----------------------------------------------------+
	| Montagem da tela para informe de contador dos pneus. |
	+-----------------------------------------------------*/
	If !Empty( aPneuCont )

		lOk := .F.

		DEFINE MSDIALOG oDlgPneus FROM 000, 000 TO 500, 900 TITLE '' OF oMainWnd PIXEL

			cCadastro := STR0151 // Informe de Contador - Pneus
			
			oDlgPneus:lEscClose  := .F.
			
			oPanel1 := TPanel():New( 0, 0, , oDlgPneus, , , , , , 0, 0, .T., .F. )
			oPanel1:Align := CONTROL_ALIGN_ALLCLIENT

				oPanel2 := TPanel():New( 0, 0, , oPanel1  , , , , , , 0, 15, .F., .F. )
				oPanel2:Align := CONTROL_ALIGN_TOP

					@ 003,010 Say STR0015 COLOR CLR_HBLUE OF oPanel2 Pixel // Data Mov.:
					@ 003,040 MsGet dDTDATEM Picture '99/99/9999' VALID Mnta232DtH();
						SIZE 45,08 OF oPanel2 HASBUTTON PIXEL

					@ 003,090 Say STR0017 COLOR CLR_HBLUE OF oPanel2 PIXEL // Hr. Leitura:
					@ 003,125 MsGet cHORALE1 Picture '99:99' VALID Mnta232DtH( 1 );
						SIZE 20,08 OF oPanel2 PIXEL

				oPanel3 := TPanel():New( 0, 0, , oPanel1  , , , , , , 0, 70, .F., .F. )
				oPanel3:Align := CONTROL_ALIGN_ALLCLIENT
				
				oGdPneus := MsNewGetDados():New( 0, 0, 0, 0, GD_UPDATE, 'Mnta232LOk()', , , { 'T9_POSCONT' }, , 99, , , , oPanel3, aHdPneus, aPneuCont )
				oGdPneus:oBrowse:Align := CONTROL_ALIGN_ALLCLIENT

		ACTIVATE MSDIALOG oDlgPneus ON INIT EnchoiceBar( oDlgPneus, { || lOk := fVldCmmt1( oDlgPneus ) },;
			{ || lOk := .F., oDlgPneus:End() } ) CENTERED

		If lOk
			
			aPneuCont := aClone( oGdPneus:aCols )

		EndIf

	EndIf

	cCadastro := cCadBkp

	FWFreeArray( aHdPneus )
	
Return lOk

//---------------------------------------------------------------------
/*/{Protheus.doc} fGeraCols
Monta aHeader e aCols para informe de contador dos pneus.
@type function

@author Alexandre Santos
@since 04/07/2023

@param aHdPneus , array, Array utilizado para criação do aHeader.
@param aPneuCont, array, Array utilizado para criação do aCols.
@return
/*/
//---------------------------------------------------------------------
Static Function fGeraCols( aHdPneus, aPneuCont )

	Local nInd1  := 0
	Local nPosPn := 0

	/*---------------------------------------------------------------+
	| Monta o aHeader conforme dicionário para os campos utilizados. |
	+---------------------------------------------------------------*/
	aHdPneus := NGHeadExc( { 'T9_CODBEM', 'T9_NOME', 'TQS_POSIC', 'T9_POSCONT' }, , .F., .F. )

	If ( nPosAux := aScan( aHdPneus, { |x| Trim( x[2] ) == 'T9_CODBEM' } ) ) > 0

		aHdPneus[nPosAux,1] := STR0049 // Pneu

	EndIf

	If ( nPosAux := aScan( aHdPneus, { |x| Trim( x[2] ) == 'T9_NOME' } ) ) > 0

		aHdPneus[nPosAux,1] := STR0149 // Desc. Pneu

	EndIf

	If ( nPosAux := aScan( aHdPneus, { |x| x[2] == 'T9_POSCONT' } ) ) > 0

		aHdPneus[nPosAux,6]  := 'Positivo()'
		aHdPneus[nPosAux,13] := ''

	EndIf

	For nInd1 := 1 to Len( aPNEUSINI )

		/*-------------------------------------------------+
		| Pneu antes do processo de movimentação de pneus. |
		+-------------------------------------------------*/
		If !Empty( aPNEUSINI[nInd1,__CODBEM__] ) .And. aPNEUSINI[nInd1,__CODBEM__] != aPNEUSFIM[nInd1,__CODBEM__]

			dbSelectArea( 'ST9' )
			dbSetOrder( 1 )
			msSeek( FWxFilial( 'ST9' ) + aPNEUSINI[nInd1,__CODBEM__] )

			If ST9->T9_TEMCONT == 'S' .And. aScan( aPneuCont, { |x| x[__CDPNEU__] == ST9->T9_CODBEM } ) == 0

				If ( nPosPn := aScan( aPNEUSFIM, { |x| x[__CODBEM__] == aPNEUSINI[nInd1,__CODBEM__] } ) ) > 0

					aAdd( aPneuCont, { ST9->T9_CODBEM, ST9->T9_NOME, Trim( aPNEUSFIM[nPosPn,__LOCALIZ__] ), 0, .F. } )

				Else

					aAdd( aPneuCont, { ST9->T9_CODBEM, ST9->T9_NOME, Trim( aPNEUSFIM[nInd1,__LOCALIZ__] ) + STR0150, 0, .F. } ) // - Removido

				EndIf

			EndIf

		EndIf

		/*--------------------------------------------------+
		| Pneu ao fim do processo de movimentação de pneus. |
		+--------------------------------------------------*/
		If !Empty( aPNEUSFIM[nInd1,__CODBEM__] )

			dbSelectArea( 'ST9' )
			dbSetOrder( 1 )
			msSeek( FWxFilial( 'ST9' ) + aPNEUSFIM[nInd1,__CODBEM__] )
				
			If ST9->T9_TEMCONT == 'S' .And. aScan( aPneuCont, { |x| x[__CDPNEU__] == ST9->T9_CODBEM } ) == 0

				aAdd( aPneuCont, { ST9->T9_CODBEM, ST9->T9_NOME, Trim( aPNEUSFIM[nInd1,__LOCALIZ__] ), 0, .F. } )

			EndIf

		EndIf
		
	Next nInd1
	
Return

//---------------------------------------------------------------------
/*/{Protheus.doc} fVldCmmt1
Validação de linha para contador do pneu.
@type function

@author Alexandre Santos
@since 29/06/2023

@param oDlg     , object, Objeto da tela para reporte de contadores.

@return boolean , Indica se o contador está validado.
/*/
//---------------------------------------------------------------------
Static Function fVldCmmt1( oDlg )

	Local lOk := .T.

	/*-------------------------------------------------+
	| Valid. todas as linhas com contadores dos pneus. |
	+-------------------------------------------------*/
	If ( lOk := Mnta232TOk() )

		oDlg:End()

	EndIf
	
Return lOk

//---------------------------------------------------------------------
/*/{Protheus.doc} Mnta232LOk
Validação de linha para contador do pneu.
@type function

@author Alexandre Santos
@since 29/06/2023

@param [nPosVld], integer, Linha que está sendo validada.

@return boolean , Indica se o contador está validado.
/*/
//---------------------------------------------------------------------
Function Mnta232LOk( nPosVld )

	Local lContOk   := .T.

	Default nPosVld := oGdPneus:nAt

	If oGdPneus:aCols[nPosVld,__CONTPN__] > 0 .And.;
		MNTA231VCO( oGdPneus:aCols[nPosVld,__CDPNEU__], oGdPneus:aCols[nPosVld,__CONTPN__], 1 )

		/*----------------------------------------------+
		| Valid. sobre o histórico do contador do pneu. |
		+----------------------------------------------*/
		lContOk := MNTA231HIS( oGdPneus:aCols[nPosVld,__CONTPN__], cHORALE1, 1, .F., oGdPneus:aCols[nPosVld,__CDPNEU__] )
	
	EndIf
	
Return lContOk

//---------------------------------------------------------------------
/*/{Protheus.doc} Mnta232TOk
Validação final para contadores dos pneus.
@type function

@author Alexandre Santos
@since 29/06/2023

@return boolean, Indica se os contadores estão validos.
/*/
//---------------------------------------------------------------------
Function Mnta232TOk()

	Local nInd1   := 0
	Local lContOk := .F.

	For nInd1 := 1 To Len( oGdPneus:aCols )

		lContOk := Mnta232LOk( nInd1 )

		If !lContOk

			Exit

		EndIf
		
	Next nInd1
	
Return lContOk

//---------------------------------------------------------------------
/*/{Protheus.doc} Mnta232DtH
Validação dos campos Data e Hora de Movimentação.
@type function

@author Alexandre Santos
@since 30/06/2023

@param  [nCall], integer, Indica o campo: 0 - Data Mov. e 1 - Hora. 
@return boolean, Indica se os campos estão validos.
/*/
//---------------------------------------------------------------------
Function Mnta232DtH( nCall )

	Local lRet    := .F.

	Default nCall := 0

	/*---------------------------------------+
	| Validações do campo Data Movimentação. |
	+---------------------------------------*/
	If nCall == 0

		If MNTA231DL() .And. fVldEmissa()

			lRet := .T.

		EndIf
	
	/*----------------------------------+
	| Validações do campo Hora Leitura. |
	+----------------------------------*/
	ElseIf nCall == 1

		If fValHrL1( cHORALE1 ) .And. NGVALHORA( cHORALE1, .T. ) .And.;
			MNTA231HL( cHORALE1, 1, dDTDATEM ) .And. MNTA232CCB( cCodBem, dDTDATEM, cHORALE1 )

			lRet := .T.

		EndIf

	EndIf

	If ExistBlock( 'MNTA2316' )

		lRet := ExecBlock( 'MNTA2316', .F., .F., { dDTDATEM, cHORALE1, nCall } )

	EndIf
		
Return lRet
