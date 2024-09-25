#Include "MNTA682.ch"
#Include "Protheus.ch"

#Define _nVersao  01 //Versao do fonte

#Define _oFont06B TFont():New("Courier New", 06, 06,, .T.,,,, .F., .F.)
#Define _oFont06  TFont():New("Courier New", 06, 06,, .F.,,,, .F., .F.)

//---------------------------------------------------------------------
/*/{Protheus.doc} MNTA682()
Monta o cabecalho do abastecimento

@author Vitor Emanuel Batista
@since 21/09/2010
/*/
//---------------------------------------------------------------------
Function MNTA682()

	Local aNGBeginPrm := NGBeginPrm(_nVersao)
	Local oBrowse
	
	If !MntCheckCC("MNTA682")
		Return .F.
	EndIf
	
	oBrowse := FWMBrowse():New()
	
		oBrowse:SetChgAll(.F.)				// Não exibe tela de seleção de filial
		oBrowse:SetAlias( "TVJ" )			// Alias da tabela utilizada
		oBrowse:SetMenuDef( "MNTA682" )		// Nome do fonte onde está a função MenuDef
		oBrowse:SetDescription( STR0004 )	// Descrição do browse
		oBrowse:SetFilterDefault( "TVJ->TVJ_STATUS <> '2'" )
		
		oBrowse:Activate()
	
	NGReturnPrm(aNGBeginPrm)

Return

//---------------------------------------------------------------------
/*/{Protheus.doc} MenuDef
Opções de menu

@author Rafael Diogo Richter 
@since Data 02/02/2008
@version P11
@return aRotina - Estrutura
	[n,1] Nome a aparecer no cabecalho
	[n,2] Nome da Rotina associada
	[n,3] Reservado
	[n,4] Tipo de Transação a ser efetuada:
		1 - Pesquisa e Posiciona em um Banco de Dados
		2 - Simplesmente Mostra os Campos
		3 - Inclui registros no Bancos de Dados
		4 - Altera o registro corrente
		5 - Remove o registro corrente do Banco de Dados
		6 - Alteração sem inclusão de registros
		7 - Cópia
		8 - Imprimir
	[n,5] Nivel de acesso
	[n,6] Habilita Menu Funcional
/*/
//---------------------------------------------------------------------
Static Function MenuDef()

	Local aRotina :=	{ { STR0070, "AxPesqui", 0, 1},;		//"Pesquisar"
							{ STR0071, "MNT682VIS", 0, 2},;		//"Visualizar"
							{ STR0072, "MNT682INC", 0, 3},; 	//"Incluir"
							{ STR0073, "MNT682INC", 0, 4},;		//"Alterar"
							{ STR0074, "MNT681EXC", 0, 5, 3},;	//"Excluir"
							{ STR0075, "MNT681GER", 0, 6}}		//"Gerar"

Return aRotina

//---------------------------------------------------------------------
/*/{Protheus.doc} MNT682INC()
Cria e chama tela de parametros do relatorio
@author Vitor Emanuel Batista
@since 21/09/2010
@version P11
/*/
//---------------------------------------------------------------------
Function MNT682INC(cAlias, nRecno, nOpc)
	
	Local aPerg	:= {}
	Local cFilOld := cFilAnt
	Private nSaveSX8 := GetSX8Len()
	
	RegToMemory("TVJ", nOpc == 3)
	
	M->TVJ_OBRA := cFilAnt
	If nOpc != 3
		M->TVJ_DESC01 := NGSEEK( "SB1", M->TVJ_PROD01, 1, "B1_DESC")
		M->TVJ_DESC02 := NGSEEK( "SB1", M->TVJ_PROD02, 1, "B1_DESC")
		M->TVJ_DESC03 := NGSEEK( "SB1", M->TVJ_PROD03, 1, "B1_DESC")
		M->TVJ_DESC04 := NGSEEK( "SB1", M->TVJ_PROD04, 1, "B1_DESC")
		M->TVJ_DESC05 := NGSEEK( "SB1", M->TVJ_PROD05, 1, "B1_DESC")
		M->TVJ_DESC06 := NGSEEK( "SB1", M->TVJ_PROD06, 1, "B1_DESC")
		M->TVJ_DESC07 := NGSEEK( "SB1", M->TVJ_PROD07, 1, "B1_DESC")
	EndIf

	If MontaParam(nOpc)
		RptStatus({ |lEnd| ImpRel(.T.) }, STR0019) //"Controle Diário de Abastecimento e Lubrificação"
	EndIf
	
	cFilAnt := cFilOld
Return

//---------------------------------------------------------------------
/*/{Protheus.doc} MontaParam()
Lista parametro para preenchimento dos dados da planilha 

@author Vitor Emanuel Batista
@since 21/09/2010
/*/
//---------------------------------------------------------------------
Static Function MontaParam(nOpc)

	Local oDlg, lOk	:= .F.
	Local cLoja := Space( TamSX3("TVJ_LOJA")[1] )

	DEFINE MsDialog oDlg Title 'Parâmetros' FROM 0,0 TO 445, 525 PIXEL color CLR_BLACK,CLR_WHITE
		
		oDlg:lEscClose := .F.
		
		oPanel := TPanel():New(0,0,,oDlg,,,,,,0,0,.F.,.F.)
			oPanel:Align := CONTROL_ALIGN_ALLCLIENT
		
		@ 10,10 Say STR0020 COLOR CLR_HBLUE Of oPanel Pixel //"Folha"
		@ 08,45 MsGet M->TVJ_FOLHA Picture Replicate('9', TamSX3('TTA_FOLHA')[1] );
			Valid ValidFolha(M->TVJ_FOLHA, M->TVJ_OBRA) SIZE 35,08 When nOpc == 3 HASBUTTON Of oPanel Pixel
		
		@ 24,10 Say 'Filial (Obra)' COLOR CLR_HBLUE Of oPanel Pixel //"Filial"
		@ 22,45 MsGet M->TVJ_OBRA Picture "@!" Valid IIf(!Empty(M->TVJ_OBRA), ExistCpo('SM0', cEmpAnt + M->TVJ_OBRA), .T. ) ;
			On Change (cFilAnt := M->TVJ_OBRA) F3 "SM0" SIZE 50,08 HASBUTTON Of oPanel Pixel
		
		@ 38,10 Say STR0022 COLOR CLR_HBLUE Of oPanel Pixel //"Comboio"
		@ 36,45 MsGet M->TVJ_POSTO Picture "@!" Valid IIf(!Empty(M->TVJ_POSTO),ExistCpo('TQF',M->TVJ_POSTO), .T.) ;
			On Change ( M->TVJ_LOJA := cLoja ) F3 "NGN" SIZE 50,08 HASBUTTON Of oPanel Pixel

		@ 52,10 Say STR0023 COLOR CLR_HBLUE Of oPanel Pixel //"Loja"
		@ 50,45 MsGet M->TVJ_LOJA  Picture "@!" Valid IIf(!Empty(M->TVJ_LOJA),ExistCpo('TQF',M->TVJ_POSTO+M->TVJ_LOJA), .T.) SIZE 20,08 HASBUTTON Of oPanel Pixel

		@ 66,10 Say STR0024 COLOR CLR_HBLUE Of oPanel Pixel //"Data Abast."
		@ 64,45 MsGet M->TVJ_DTABAS Picture "99/99/99" Valid IIf(!Empty(M->TVJ_DTABAS), fValData(), .T.) SIZE 45,08 HASBUTTON Of oPanel Pixel
		
		@ 80,10 Say STR0025 COLOR CLR_HBLUE Of oPanel Pixel //"Centro Custo"
		@ 78,45 MsGet M->TVJ_CCUSTO Picture "@!" Valid IIf(!Empty(M->TVJ_CCUSTO), ExistCpo('CTT',M->TVJ_CCUSTO), .T.) F3 "CTT" SIZE 35,08 HASBUTTON Of oPanel Pixel
		
		@ 094,010 Say STR0026 Of oPanel Pixel //"Produto 1"
		@ 092,045 MsGet M->TVJ_PROD01 Picture "@!" Valid IIf(!Empty(M->TVJ_PROD01),ExistCpo("SB1",M->TVJ_PROD01),.T.) .And. MNT682PROD('M->TVJ_PROD01','M->TVJ_DESC01') F3 "SB1" SIZE 70,08 HASBUTTON Of oPanel Pixel		
		@ 092,120 MsGet M->TVJ_DESC01 Picture "@!" SIZE 135,08 When .F. HASBUTTON Of oPanel Pixel
		 
		@ 108,010 Say STR0027 Of oPanel Pixel //"Produto 2"
		@ 106,045 MsGet M->TVJ_PROD02 Picture "@!" Valid IIf(!Empty(M->TVJ_PROD02),ExistCpo("SB1",M->TVJ_PROD02),.T.) .And. MNT682PROD('M->TVJ_PROD02','M->TVJ_DESC02') F3 "SB1" SIZE 70,08 HASBUTTON Of oPanel Pixel
		@ 106,120 MsGet M->TVJ_DESC02 Picture "@!" SIZE 135,08 When .F. HASBUTTON Of oPanel Pixel
		
		@ 122,010 Say STR0028 Of oPanel Pixel //"Produto 3"
		@ 120,045 MsGet M->TVJ_PROD03 Picture "@!" Valid IIf(!Empty(M->TVJ_PROD03),ExistCpo("SB1",M->TVJ_PROD03),.T.) .And. MNT682PROD('M->TVJ_PROD03','M->TVJ_DESC03') F3 "SB1" SIZE 70,08 HASBUTTON Of oPanel Pixel
		@ 120,120 MsGet M->TVJ_DESC03 Picture "@!" SIZE 135,08 When .F. HASBUTTON Of oPanel Pixel
		
		@ 136,010 Say STR0029 Of oPanel Pixel //"Produto 4"
		@ 134,045 MsGet M->TVJ_PROD04 Picture "@!" Valid IIf(!Empty(M->TVJ_PROD04),ExistCpo("SB1",M->TVJ_PROD04),.T.) .And. MNT682PROD('M->TVJ_PROD04','M->TVJ_DESC04') F3 "SB1" SIZE 70,08 HASBUTTON Of oPanel Pixel
		@ 134,120 MsGet M->TVJ_DESC04 Picture "@!" SIZE 135,08 When .F. HASBUTTON Of oPanel Pixel
		
		@ 150,010 Say STR0030 Of oPanel Pixel //"Produto 5"
		@ 148,045 MsGet M->TVJ_PROD05 Picture "@!" Valid IIf(!Empty(M->TVJ_PROD05),ExistCpo("SB1",M->TVJ_PROD05),.T.) .And. MNT682PROD('M->TVJ_PROD05','M->TVJ_DESC05') F3 "SB1" SIZE 70,08 HASBUTTON Of oPanel Pixel		
		@ 148,120 MsGet M->TVJ_DESC05 Picture "@!" SIZE 135,08 When .F. HASBUTTON Of oPanel Pixel
		
		@ 164,010 Say STR0031 Of oPanel Pixel //"Produto 6"
		@ 162,045 MsGet M->TVJ_PROD06 Picture "@!" Valid IIf(!Empty(M->TVJ_PROD06),ExistCpo("SB1",M->TVJ_PROD06),.T.) .And. MNT682PROD('M->TVJ_PROD06','M->TVJ_DESC06') F3 "SB1" SIZE 70,08 HASBUTTON Of oPanel Pixel
		@ 162,120 MsGet M->TVJ_DESC06 Picture "@!" SIZE 135,08 When .F. HASBUTTON Of oPanel Pixel

		@ 178,010 Say STR0032 Of oPanel Pixel //"Produto 7"
		@ 176,045 MsGet M->TVJ_PROD07 Picture "@!" Valid IIf(!Empty(M->TVJ_PROD07),ExistCpo("SB1",M->TVJ_PROD07),.T.) .And. MNT682PROD('M->TVJ_PROD07','M->TVJ_DESC07') F3 "SB1" SIZE 70,08 HASBUTTON Of oPanel Pixel
		@ 176,120 MsGet M->TVJ_DESC07 Picture "@!" SIZE 135,08 When .F. HASBUTTON Of oPanel Pixel
					
	Activate MsDialog oDlg On Init EnchoiceBar(oDlg,{||  lOk := ValidParam(), IIf(lOk,oDlg:End(),Nil)},;
													{||  lOk := .F.,oDlg:End(),IIf(nSaveSX8 < GetSX8Len(),RollBackSX8(),Nil) },,,,,,, .F.) CENTERED

Return lOk
//---------------------------------------------------------------------
/*/{Protheus.doc} ValidParam()
Valida parametros digitados 

@author Vitor Emanuel Batista
@since 28/09/2010
/*/
//---------------------------------------------------------------------
Static Function ValidParam()

	Local lRet := .F.

	If ( lRet := ValidFolha(M->TVJ_FOLHA,M->TVJ_OBRA) )
		
		Do Case 
			Case Empty(M->TVJ_FOLHA) .Or. Empty(M->TVJ_OBRA) .Or. Empty(M->TVJ_POSTO) .Or. ;
					Empty(M->TVJ_LOJA) .Or. Empty(M->TVJ_DTABAS) .Or. Empty(M->TVJ_CCUSTO)
					
				Help(" ", 1, "OBRIGAT",, "", 3)
				lRet := .F.
			
			Case Len( AllTrim(M->TVJ_FOLHA) ) <> 9
			
				ShowHelpDlg(STR0033, {STR0034}, 3, {STR0035}, 3) //"ATENÇÃO"###"Folha com quantidade de caracteres inválido."###"Informe uma folha com 9 caracteres."
					lRet := .F.
			OtherWise
				lRet := .T.
				
				
		End Case
	Endif
	
Return lRet

//---------------------------------------------------------------------
/*/{Protheus.doc} ImpRel()
Imprime o relatorio 

@author Vitor Emanuel Batista
@since 28/09/2010
/*/
//---------------------------------------------------------------------
Static Function ImpRel(lUpsert)
	
	Local nX
	Local aBens := ListaBem(lUpsert)

	If Len(aBens) > 0
		
		If lUpsert
			
			dbSelectArea("TVJ")
			dbSetOrder(1)
			
			RecLock( "TVJ", !dbSeek(xFilial("TVJ") + M->TVJ_FOLHA) )
			
			TVJ->TVJ_FILIAL := xFilial("TVJ") 
			TVJ->TVJ_FOLHA  := M->TVJ_FOLHA
			TVJ->TVJ_OBRA   := M->TVJ_OBRA
			TVJ->TVJ_POSTO  := M->TVJ_POSTO
			TVJ->TVJ_LOJA   := M->TVJ_LOJA
			TVJ->TVJ_DTABAS := M->TVJ_DTABAS
			TVJ->TVJ_CCUSTO := M->TVJ_CCUSTO
			TVJ->TVJ_PROD01 := M->TVJ_PROD01
			TVJ->TVJ_PROD02 := M->TVJ_PROD02
			TVJ->TVJ_PROD03 := M->TVJ_PROD03
			TVJ->TVJ_PROD04 := M->TVJ_PROD04
			TVJ->TVJ_PROD05 := M->TVJ_PROD05
			TVJ->TVJ_PROD06 := M->TVJ_PROD06
			TVJ->TVJ_PROD07 := M->TVJ_PROD07
			TVJ->TVJ_STATUS := '1'
			TVJ->TVJ_USUARI := cUsername
			
			TVJ->( MsUnLock() )
			
			//-----------------------------------------------
			//Remove bens não selecionados da planilha
			//-----------------------------------------------	
			dbSelectArea("TVP")
			dbSetOrder(1)
			dbSeek(xFilial("TVP") + M->TVJ_FOLHA)
			While !EoF() .And. xFilial("TVP") == TVP->TVP_FILIAL .And. TVP->TVP_FOLHA == M->TVJ_FOLHA
			
				If aScan(aBens, {|x| x == TVP->TVP_CODBEM}) == 0
				
					TVP->( RecLock("TVP",.F.) )
					TVP->( dbDelete() )
					TVP->( MsUnLock() )
					
				EndIf
				
				dbSelectArea("TVP")
				dbSkip()
			EndDo
		
			//-----------------------------------------------
			//Acrescenta bens selecionados na planilha
			//-----------------------------------------------
			dbSelectArea("TVP")
			dbSetOrder(1)
			For nX := 1 To Len(aBens)
			
				If !dbSeek(xFilial("TVP") + M->TVJ_FOLHA + aBens[nX])
					
					TVP->( RecLock("TVP", .T.) )
					
					TVP->TVP_FILIAL := xFilial("TVP")
					TVP->TVP_FOLHA  := M->TVJ_FOLHA
					TVP->TVP_CODBEM := aBens[nX]
					
					TVP->( MsUnLock() )
					
				EndIf
			Next nX
		EndIf
	
		oPrint := TMSPrinter():New(STR0019) //"Controle Diário de Abastecimento e Lubrificação"
			oPrint:SetLandScape() 
			oPrint:StartPage()
	
		//Imprime cabecalho
		ImpCabec()
		
		nLin := 320
		
		For nX := 1 To Len(aBens)
		
			If nX != 1 .And. Mod(nX, 40) == 1
				
				//Imprime rodape
				ImpRodape()
				
				//Cria nova pagina
				oPrint:EndPage()
				oPrint:StartPage()
				
				//Imprime cabecalho
				ImpCabec()
				
				nLin := 320
			EndIf
			
			oPrint:Box(nLin, 010, nLin + 50,240) //Codigo do Bem
			oPrint:Say(nLin + 10, 020, aBens[nX],_oFont06B)
			oPrint:Box(nLin, 240, nLin + 50, 460) //Horimetro
			oPrint:Box(nLin, 460, nLin + 50, 570) //Hora Abast.
			oPrint:Box(nLin, 570, nLin + 50, 680) //Oleo Diesel
			oPrint:Box(nLin, 680, nLin + 50, 880) // Produto 1
			oPrint:Box(nLin, 880, nLin + 50, 1080) // Produto 2
			oPrint:Box(nLin, 1080, nLin + 50, 1280) // Produto 3
			oPrint:Box(nLin, 1280, nLin + 50, 1480) // Produto 4
			oPrint:Box(nLin, 1480, nLin + 50, 1680) // Produto 5
			oPrint:Box(nLin, 1680, nLin + 50, 1880) // Produto 6
			oPrint:Box(nLin, 1880, nLin + 50, 2080) // Produto 7
			oPrint:Box(nLin, 2080, nLin + 50, 2180) //Motor
			oPrint:Box(nLin, 2180, nLin + 50, 2280) //Transm.
			oPrint:Box(nLin, 2280, nLin + 50, 2380) //Hid.
			oPrint:Box(nLin, 2380, nLin + 50, 2480) //1 Eixo
			oPrint:Box(nLin, 2480, nLin + 50, 2580) //2 Eixo
			oPrint:Box(nLin, 2580, nLin + 50, 2680) //T/C
			oPrint:Box(nLin, 2680, nLin + 50, 3060) //Assinatura
			
			nLin += 50
		Next nX
		
		//Imprime rodape
		ImpRodape()
		
		oPrint:EndPage()
		oPrint:Preview()
		
	EndIf

Return
//---------------------------------------------------------------------
/*/{Protheus.doc} ImpRel()
Imprime o rodape listando os produtos aplicados no veiculo

@author Vitor Emanuel Batista
@since 21/09/2010
/*/
//---------------------------------------------------------------------
Static Function ImpRodape()

	oPrint:Say(2750, 050, STR0036, _oFont06B) //"Produtos Aplicados no veículo principal"
	oPrint:Say(2790, 050, TVJ->TVJ_PROD01 + " - " + NGSeek("SB1", TVJ->TVJ_PROD01, 1, "SB1->B1_DESC"), _oFont06B)
	oPrint:Say(2820, 050, TVJ->TVJ_PROD02 + " - " + NGSeek("SB1", TVJ->TVJ_PROD02, 1, "SB1->B1_DESC"), _oFont06B)
	oPrint:Say(2850, 050, TVJ->TVJ_PROD03 + " - " + NGSeek("SB1", TVJ->TVJ_PROD03, 1, "SB1->B1_DESC"), _oFont06B)
	oPrint:Say(2880, 050, TVJ->TVJ_PROD04 + " - " + NGSeek("SB1", TVJ->TVJ_PROD04, 1, "SB1->B1_DESC"), _oFont06B)
	oPrint:Say(2910, 050, TVJ->TVJ_PROD05 + " - " + NGSeek("SB1", TVJ->TVJ_PROD05, 1, "SB1->B1_DESC"), _oFont06B)
	oPrint:Say(2940, 050, TVJ->TVJ_PROD06 + " - " + NGSeek("SB1", TVJ->TVJ_PROD06, 1, "SB1->B1_DESC"), _oFont06B)
	oPrint:Say(2970, 050, TVJ->TVJ_PROD07 + " - " + NGSeek("SB1", TVJ->TVJ_PROD07, 1, "SB1->B1_DESC"), _oFont06B)
	
Return
//---------------------------------------------------------------------
/*/{Protheus.doc} ImpCabec()
Imprime cabecalho do relatorio

@author Vitor Emanuel Batista
@since 21/09/2010
/*/
//---------------------------------------------------------------------
Static Function ImpCabec()

	Local cSMCOD := IIf( FindFunction("FWGrpCompany"), FWGrpCompany(), SM0->M0_CODIGO )
	Local cSMFIL := IIf( FindFunction("FWCodFil")    , FWCodFil()    , SM0->M0_CODFIL )

	//---------------------------------------------------------------------
	//Configura logo da empresa no cabeçalho do relatório.
	//---------------------------------------------------------------------
	If File("LGRL" + cSMCOD + cSMFIL + ".BMP")
		
		oPrint:SayBitMap(100, 060, "LGRL" + cSMCOD + cSMFIL + ".BMP", 120, 080)
		
	ElseIf File("LGRL" + cSMCOD + ".BMP")
		
		oPrint:SayBitMap(100, 060, "LGRL" + cSMCOD + ".BMP", 120, 080)
		
	ElseIf File("\SIGAADV\LGRL" + cSMCOD + cSMFIL + ".BMP")
		
		oPrint:SayBitMap(100, 060, "\SIGAADV\LGRL" + cSMCOD + cSMFIL + ".BMP", 120, 080)
	
	ElseIf File("\SIGAADV\LGRL" + cSMCOD + ".BMP")
	
		oPrint:SayBitMap(100, 060, "\SIGAADV\LGRL" + cSMCOD + ".BMP", 120, 080)
		
	Endif
	
	oPrint:Box(100, 010, 220, 240)
	oPrint:Box(100, 240, 220, 740)
	
	oPrint:Say(120, 280, STR0037, _oFont06B) //"Controle Diário de Abastecimento"
	oPrint:Say(170, 380, STR0038, _oFont06B) //"e Lubrificação"
	
	oPrint:Box(100, 740, 160, 1340)
	oPrint:Say(120, 755, STR0039 + TVJ->TVJ_OBRA + " - " + NGSeekDic("SM0", cEmpAnt + TVJ->TVJ_OBRA, 1, "SM0->M0_FILIAL"), _oFont06B) //"Filial: "
	
	oPrint:Box(160, 740, 220,1340)
	oPrint:Say(180, 755, STR0040 + TVJ->TVJ_CCUSTO + "- " + SubStr( NGSeek(STR0041, TVJ->TVJ_CCUSTO, 1, "CTT_DESC01"), 1, 24), _oFont06B) //"C.C: "###"CTT"
	
	oPrint:Box(100, 1340, 220,1660)
	oPrint:Say(120, 1355, STR0042 + TVJ->TVJ_POSTO, _oFont06B) //"Comboio: "
	
	cComboio := NGSeek("SA2", TVJ->TVJ_POSTO, 1, "A2_NOME")
	
	oPrint:Say(155, 1355, SubStr( AllTrim(cComboio), 1, 19),_oFont06B)
	oPrint:Say(190, 1355, SubStr( AllTrim( Right(cComboio, 21) ), 1, 19), _oFont06B)
	oPrint:Box(100, 1660, 220, 2180)
	
	oPrint:Say(120, 1675, STR0043 + TVJ->TVJ_FOLHA, _oFont06B) //"Folha: "
	oPrint:Box(160, 1660, 220, 2180)
	
	oPrint:Say(180, 1675, STR0044 + DToC(TVJ->TVJ_DTABAS), _oFont06B) //"Data: "
	oPrint:Box(100, 2180, 220, 3060)
	
	oPrint:Say(120, 2520, STR0045, _oFont06B) //"Leitura da Bomba"
	oPrint:Say(180, 2195, STR0046, _oFont06B) //"Inicial:"
	oPrint:Say(180, 2620, STR0047, _oFont06B) //"Final:"

	oPrint:Box(220, 010, 320, 240)
	oPrint:Say(230, 030, STR0048, _oFont06B) //"Código do Bem"
	
	oPrint:Box(220, 240, 320, 460)
	oPrint:Say(230, 245, "Contador", _oFont06B) //"Horímetro"
	
	oPrint:Box(220, 460, 320, 570)
	oPrint:Say(230, 465, STR0050, _oFont06B) //"Hora"
	oPrint:Say(270, 465, STR0051, _oFont06B) //"Abast."
	
	oPrint:Box(220, 570, 320, 680)
	oPrint:Say(230, 575, "Combust.", _oFont06B) //"Óleo"
	//oPrint:Say(270, 575, STR0053, _oFont06B) //"Diesel"

	oPrint:Box(220, 680, 250, 2080)
	oPrint:Say(225, 700, STR0036, _oFont06B) //"Produtos Aplicados no veículo principal"

	oPrint:Box(250, 680, 320, 880) //Produto 1
	oPrint:Say(255, 688, SubStr(TVJ->TVJ_PROD01, 01, 14), _oFont06B)
	oPrint:Say(275, 688, SubStr(TVJ->TVJ_PROD01, 15, 14), _oFont06B)
	oPrint:Say(295, 688, SubStr(TVJ->TVJ_PROD01, 29, 12), _oFont06B)
	
	oPrint:Box(250, 880, 320, 1080) //Produto 2
	oPrint:Say(255, 888, SubStr(TVJ->TVJ_PROD02, 01, 14), _oFont06B)
	oPrint:Say(275, 888, SubStr(TVJ->TVJ_PROD02, 15, 14), _oFont06B)
	oPrint:Say(295, 888, SubStr(TVJ->TVJ_PROD02, 29, 12), _oFont06B)

	oPrint:Box(250, 1080, 320, 1280) //Produto 3
	oPrint:Say(255, 1088, SubStr(TVJ->TVJ_PROD03, 01, 14), _oFont06B)
	oPrint:Say(275, 1088, SubStr(TVJ->TVJ_PROD03, 15, 14), _oFont06B)
	oPrint:Say(295, 1088, SubStr(TVJ->TVJ_PROD03, 29, 12), _oFont06B)
	
	oPrint:Box(250, 1280, 320, 1480) //Produto 4
	oPrint:Say(255, 1288,SubStr(TVJ->TVJ_PROD04, 01, 14), _oFont06B)
	oPrint:Say(275, 1288,SubStr(TVJ->TVJ_PROD04, 15, 14), _oFont06B)
	oPrint:Say(295, 1288,SubStr(TVJ->TVJ_PROD04, 29, 12), _oFont06B)

	oPrint:Box(250, 1480, 320, 1680) //Produto 5
	oPrint:Say(255, 1488,SubStr(TVJ->TVJ_PROD05, 01, 14), _oFont06B)
	oPrint:Say(275, 1488,SubStr(TVJ->TVJ_PROD05, 15, 14), _oFont06B)
	oPrint:Say(295, 1488,SubStr(TVJ->TVJ_PROD05, 29, 12), _oFont06B)

	oPrint:Box(250, 1680, 320, 1880) //Produto 6
	oPrint:Say(255, 1688,SubStr(TVJ->TVJ_PROD06, 01, 14), _oFont06B)
	oPrint:Say(275, 1688,SubStr(TVJ->TVJ_PROD06, 15, 14), _oFont06B)
	oPrint:Say(295, 1688,SubStr(TVJ->TVJ_PROD06, 29, 12), _oFont06B)
	
	oPrint:Box(250, 1880, 320, 2080) //Produto 7
	oPrint:Say(255, 1888,SubStr(TVJ->TVJ_PROD07, 01, 14), _oFont06B)
	oPrint:Say(275, 1888,SubStr(TVJ->TVJ_PROD07, 15, 14), _oFont06B)
	oPrint:Say(295, 1888,SubStr(TVJ->TVJ_PROD07, 29, 12), _oFont06B)
	
	oPrint:Box(220, 2080, 250, 2680)
	oPrint:Say(225, 2270,STR0054,_oFont06B) //"Componentes"
	
	oPrint:Box(250, 2080, 320, 2180)
	oPrint:Say(270, 2090,STR0055,_oFont06B) //"Motor"
	
	oPrint:Box(250, 2180, 320, 2280)
	oPrint:Say(270, 2190,STR0056,_oFont06B) //"Transm."
	
	oPrint:Box(250, 2280, 320, 2380)
	oPrint:Say(270, 2290,STR0057,_oFont06B) //"Hid."
	
	oPrint:Box(250, 2380, 320, 2480)
	oPrint:Say(270, 2390,STR0058,_oFont06B) //"1ºEixo"
	
	oPrint:Box(250, 2480, 320, 2580)
	oPrint:Say(270, 2490,STR0059,_oFont06B) //"2ºEixo"

	oPrint:Box(250, 2580, 320, 2680)
	oPrint:Say(270, 2590,"T/C",_oFont06B) // Tanque de Combustível
	
	oPrint:Box(220, 2680, 320, 3060)
	oPrint:Say(225, 2810, STR0060, _oFont06B) //"Assinatura"
	oPrint:Say(250, 2855, STR0061, _oFont06B) //"dos"
	oPrint:Say(275, 2810, STR0062, _oFont06B) //"Operadores"
	
Return
//---------------------------------------------------------------------
/*/{Protheus.doc} ListaBem()
Lista Bens que tenham tanque de combustivel 

@author Vitor Emanuel Batista
@since 21/09/2010
/*/
//------------------------------------------------------------------
Static Function ListaBem(lUpsert)

	Local oDlg
	Local oMarkBrw 
	Local oArqTrb
	
	Local lOk		:= !lUpsert
	Local lInverte	:= .F.	
	
	Local aBens		:= {}
	Local aStruct	:= {}
	Local aFldsST9	:= {}
	
	Local cMarca	:= GetMark()
	Local cBensTrb	:= GetNextAlias()
	
	aAdd(aFldsST9, { "T9_OK"    , Nil, ""     , }) //""
	aAdd(aFldsST9, { "T9_CODBEM", Nil, STR0063, }) //"Código"
	aAdd(aFldsST9, { "T9_NOME"  , Nil, STR0064, }) //"Nome"
	
	aAdd(aStruct, { "T9_OK"		, "C", 02                    , 0 })
	aAdd(aStruct, { "T9_CODBEM"	, "C", TamSX3('T9_CODBEM')[1], 0 })
	aAdd(aStruct, { "T9_NOME"	, "C", TamSX3('T9_NOME')[1]  , 0 })
	
	cQuery := " SELECT ' ' AS OK, T9_CODBEM, T9_NOME FROM " + RetSqlName("ST9")
	cQuery += " WHERE T9_FILIAL = " + ValToSql( xFilial("ST9", M->TVJ_OBRA) )
	cQuery += "   AND T9_CATBEM = '4' AND T9_SITBEM = 'A'"
	cQuery += "   AND D_E_L_E_T_ != '*' AND "
	cQuery += "     ( SELECT COUNT(*) FROM " + RetSqlName("TT8")
	cQuery += "        WHERE TT8_FILIAL = " + ValToSql( xFilial("TT8", M->TVJ_OBRA) )
	cQuery += "          AND TT8_CODBEM = T9_CODBEM"
	cQuery += "          AND D_E_L_E_T_ != '*' ) > 0"
	
	//Ponto de entrada para configurar filtro da lista de bem via query.
	If ExistBlock("MNTA6821")
		cQuery += ExecBlock("MNTA6821",.F.,.F.,{M->TVJ_LOJA, M->TVJ_DTABAS, M->TVJ_CCUSTO})
	EndIf
	
	cQuery += "   ORDER BY T9_CODBEM"
	
	//Criação Tabela Temporária
	oArqTrb := NGFwTmpTbl(cBensTrb,aStruct,{{"T9_CODBEM"}}) 
	
	//Funcao que ira executar query e adicionar em uma Trb
	SqlToTrb(cQuery, aStruct, cBensTrb)
	
	dbSelectArea("TVJ")
	dbSetOrder(1)
	If dbSeek(xFilial("TVJ") + M->TVJ_FOLHA)
	
		dbSelectArea("TVP")
		dbSetOrder(1)
		If dbSeek(xFilial("TVP") + M->TVJ_FOLHA)
			
			While !EoF() .And. xFilial("TVP") == TVP->TVP_FILIAL .And. TVP->TVP_FOLHA == M->TVJ_FOLHA
			
				dbSelectArea(cBensTrb)
				dbSetOrder(1)
				If dbSeek(TVP->TVP_CODBEM)
				
					(cBensTrb)->( RecLock(cBensTrb, .F.) )
					(cBensTrb)->T9_OK := cMarca
					(cBensTrb)->( MsUnLock() )
					
				EndIf
				
				dbSelectArea("TVP")
				dbSkip()
			EndDo
			
		EndIf
	EndIf
	
	(cBensTrb)->( dbGoTop() )

	If lUpsert
		Define MsDialog oDlg FROM 0,0 To 500,550 Title STR0065 Of oMainWnd Color CLR_BLACK, CLR_WHITE Pixel //"Lista de Bens"
			
			oMark := MsSelect():New(cBensTrb, "T9_OK",, aFldsST9, @lInverte, @cMarca, )
				oMark:oBrowse:Align := CONTROL_ALIGN_ALLCLIENT
				oMark:oBrowse:bAllMark    := { || MNT682INV(cMarca, cBensTrb) }
				oMark:oBrowse:lHasMark    := .T.
				oMark:oBrowse:lCanAllMark := .T.	
		
		Activate MsDialog oDlg On Init EnchoiceBar( oDlg, {|| IIf( ( lOk := ValidaMark(cBensTrb) ), oDlg:End(), Nil), IIf(nSaveSX8 < GetSX8Len(), ConfirmSX8(),Nil) },;
														  {|| lOk := .F., oDlg:End() , RollBackSX8() },,,,,,,.F.) Centered
	EndIf
	
	If lOk
		dbSelectArea(cBensTrb)
		dbGoTop()
		While (cBensTrb)->( !EoF() )
			
			If !Empty( (cBensTrb)->T9_OK )
				aAdd(aBens, (cBensTrb)->T9_CODBEM)
			EndIf
			   
			(cBensTrb)->( dbSkip() )
		EndDo
	EndIf
	
	oArqTrb:Delete()
	
Return aBens

//-----------------------------------------------------------------
/*/{Protheus.doc} MNT682INV()
Inverte a marcação dos bens.   

@author Vitor Emanuel Batista
@since 18/06/2009
/*/
//------------------------------------------------------------------
Static Function MNT682INV(cMarca, cAliasTrb)

	Local nRecno := (cAliasTrb)->( Recno() ) 
	
	dbSelectArea(cAliasTrb)
	dbGoTop()
	While !(cAliasTrb)->( EoF() )
	
	   (cAliasTrb)->T9_OK := IIf( !Empty( (cAliasTrb)->T9_OK ), '  ', cMarca )
	   
	   (cAliasTrb)->( dbSkip() )
	EndDo
	
	dbGoTo(nRecno)
	
	lRefresh := .T.
	
Return Nil  

//---------------------------------------------------------------------
/*/{Protheus.doc} ValidaMark()
Valida se usuario selecionou pelo menos um Bem

@author Vitor Emanuel Batista
@since 24/09/2010
/*/
//------------------------------------------------------------------
Static Function ValidaMark(cBensTrb)

	Local aArea := (cBensTrb)->( GetArea() )
	Local lOk   := .F.
	
	dbSelectArea(cBensTrb)
	dbGoTop()
	While (cBensTrb)->( !EoF() )
	
		If ( lOk := !Empty( (cBensTrb)->T9_OK ) )
			Exit
		EndIf
		
		(cBensTrb)->( dbSkip() )
	EndDo

	If !lOk
		MsgStop(STR0066) //"Selecione um Bem para continuar ou cancele a operação."
	EndIf
	
	RestArea(aArea)
	
Return lOk

//-----------------------------------------------------------------
/*/{Protheus.doc} MNT682PROD()
Valida campo de codigo do produto  
  
@author Vitor Emanuel Batista
@since 18/06/2009
/*/
//------------------------------------------------------------------
Function MNT682PROD(cCodCpo, cDescCpo)

	Local lRet		:= .T.
	Local cCodVar := &cCodCpo
	
	If Empty(cCodVar)
	
		&(cDescCpo) := Space( TamSX3('B1_COD')[1] )
	
	ElseIf ( lRet := ExistCpo("SB1", &cCodCpo, 1) )
		
		dbSelectArea("SB1")
		dbSetOrder(1)
		If dbSeek(xFilial("SB1") + &cCodCpo)
			&(cDescCpo) := SubStr(SB1->B1_DESC, 1, 40) + Space(40 - Len(SB1->B1_DESC))
		EndIf
		
	EndIf

Return lRet

//-----------------------------------------------------------------
/*/{Protheus.doc} MNT681GER()
Gera Abastecimento e Lubrificacao   

@author Vitor Emanuel Batista
@since 29/09/2010
/*/
//------------------------------------------------------------------
Function MNT681GER()

  	Local cFilOld  := cFilAnt 
	
	cFilAnt := TVJ->TVJ_OBRA
	
	MNTA681(TVJ->TVJ_FOLHA)
	
	cFilAnt := cFilOld   
	
Return
//-----------------------------------------------------------------
/*/{Protheus.doc} MNT682VIS()
Visualiza Planilha de Abastecimento e Lubrificacao   

@author Vitor Emanuel Batista
@since 29/09/2010
/*/
//------------------------------------------------------------------
Function MNT682VIS()
	
	dbSelectArea("TVJ")
	dbSetOrder(1)
	If dbSeek(xFilial("TVJ") + TVJ->TVJ_FOLHA)
			
		M->TVJ_FOLHA  := TVJ->TVJ_FOLHA
		M->TVJ_OBRA   := TVJ->TVJ_OBRA
		M->TVJ_POSTO  := TVJ->TVJ_POSTO
		M->TVJ_LOJA   := TVJ->TVJ_LOJA
		M->TVJ_DTABAS := TVJ->TVJ_DTABAS
		M->TVJ_CCUSTO := TVJ->TVJ_CCUSTO
		M->TVJ_PROD01 := TVJ->TVJ_PROD01
		M->TVJ_PROD02 := TVJ->TVJ_PROD02
		M->TVJ_PROD03 := TVJ->TVJ_PROD03
		M->TVJ_PROD04 := TVJ->TVJ_PROD04
		M->TVJ_PROD05 := TVJ->TVJ_PROD05
		M->TVJ_PROD06 := TVJ->TVJ_PROD06
		M->TVJ_PROD07 := TVJ->TVJ_PROD07
		
	EndIf
	
	ImpRel(.F.) //Imprime o relatorio 

Return

//-----------------------------------------------------------------
/*/{Protheus.doc} MNT681EXC()
Exclui planilha de Abastecimento e Lubrificacao
    
@author Vitor Emanuel Batista
@since 29/09/2010
/*/
//------------------------------------------------------------------
Function MNT681EXC()

	If MsgYesNo(STR0076) //"Deseja excluir o registro selecionado?"
		
		dbSelectArea("TVP")
		dbSetOrder(1)
		If dbSeek(xFilial("TVP") + TVJ->TVJ_FOLHA)
		
			While TVP->( !EoF() ) .And. xFilial("TVP") == TVP->TVP_FILIAL .And. TVP->TVP_FOLHA == TVJ->TVJ_FOLHA
				
				TVP->( RecLock("TVP",.F.) )
				TVP->( dbDelete() )
				TVP->( MsUnlock() )
				
				TVP->( dbSkip() ) 
			EndDo
			
		EndIf
		
		TVJ->( RecLock("TVJ", .F.) )
		TVJ->( dbDelete() )
		TVJ->( MsUnlock() )
	EndIf

Return

//-----------------------------------------------------------------
/*/{Protheus.doc} ValidFolha()
Valida parametros digitados 
   
@author Vitor Emanuel Batista
@since 28/09/2010
/*/
//------------------------------------------------------------------
Static Function ValidFolha(cFolha, cObra)

	Local aOldArea	:= GetArea()
	
	Local lRet			:= ExistChav('TVJ', cFolha)
	Local cAliasQry	:= GetNextAlias()
	
	If lRet .And. !Empty(cFolha) .And. !Empty(cObra)

		cQuery := " SELECT TTA_FOLHA "
		cQuery += " FROM " + RetSqlName("TTA")
		cQuery += " WHERE TTA_FOLHA = " + ValToSql(cFolha)
		cQuery += "   AND D_E_L_E_T_ = ' ' "
		
		cQuery := ChangeQuery(cQuery)
		
		dbUseArea( .T., "TOPCONN", TCGenQry(,,cQuery), cAliasQry, .F., .F.)
	
		If !( lRet := EoF() )
			MsgStop(STR0077 + cFolha + STR0078) //"Folha "###" já preenchida."
		Endif
		
		(cAliasQry)->( dbCloseArea() )
		
	EndIf

	RestArea(aOldArea)

Return lRet

//-----------------------------------------------------------------
/*/{Protheus.doc} fValData()
Validação de data
    	
@author Maria Elisandra de Paula
@since 18/11/2014
/*/
//------------------------------------------------------------------
Static Function fValData()
	
	Local lDataOk
	
	If !( lDataOk := M->TVJ_DTABAS <= dDataBase )
		MsgAlert(STR0079) //"A data deve ser menor ou igual à data atual!"
	EndIf
	 
Return lDataOk