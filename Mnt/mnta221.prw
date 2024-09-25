#INCLUDE "MNTA221.ch"
#INCLUDE "PROTHEUS.CH"

Static __IDPNEU__    := 1
Static __CODPNEU__   := 2
Static __IMGX__      := 3
Static __IMGY__      := 4
Static __TYPE__      := 5
Static __TXTX__      := 2
Static __TXTY__      := 3
Static __IDTXT__     := 1
Static __VIDA__      := 1
Static __ESTEPE__    := 2
Static __INVISIBLE__ := 3

//---------------------------------------------------------------------
/*/{Protheus.doc} MNTA221
Cadastro do Esquema Padrao

@author Vitor Emanuel Batista
@since 14/07/2009

@return Vazio.
/*/
//---------------------------------------------------------------------
Function MNTA221()


	//|---------------------------------------------|
	//| Guarda conteudo e declara variaveis padroes |
	//|---------------------------------------------|
	Local aNGBEGINPRM := {}
	Local lRet := .T.

	If !FindFunction( 'MNTAmIIn' ) .Or. MNTAmIIn( 95 )

		aNGBEGINPRM := NGBEGINPRM()

		If NGCADICBASE("TQ0_CODEST","A","TQ0",.F.)
			Processa({ |lEnd| lRet := VerifImg() },STR0001)	 //"Aguarde.. Exportando Imagens..."
			If !lRet ////Verifica imagens no RPO e exporta para pasta no Temp
				MsgStop(	STR0002+CHR(13)+CHR(13)+; //"Existem algumas imagens necessárias para a utilização desta rotina que não foram encontradas."
							STR0003,STR0004) //"Favor alertar o administrador para que o sistema seja atualizado corretamente."###"NÃO CONFORMIDADE"
			EndIf
		EndIf
		Private lGFrota   := NGVERUTFR()
		Private lTipMod   := GetRPORelease() >= '12.1.033' .Or. lGFrota //usada no MNTA220
		// Para o release 12.1.33 não se faz necessária a validação contida na função MNTA220FR
		If lGFrota
			MNTA220FR()
		EndIf

		//|---------------------------------------------|
		//| Retorna conteudo de variaveis padroes       |
		//|---------------------------------------------|
		If !lRet
			NGRETURNPRM(aNGBEGINPRM)
			Return lRet
		EndIf

		Private aRotina   := MenuDef()
		Private cCadastro := OemtoAnsi(STR0005)	 //"Cadastro do Esquema Padrao"
		Private lTQ1SUSP  := NGCADICBASE('TQ1_SUSPEN','A','TQ1',.F.)  //indica se usa eixo suspenso


		dbSelectArea("TQ0")
		mBrowse( 6, 1,22,75,"TQ0")

		//|---------------------------------------------|
		//| Retorna conteudo de variaveis padroes       |
		//|---------------------------------------------|
		NGRETURNPRM(aNGBEGINPRM)

	EndIf

Return

//---------------------------------------------------------------------
/*/{Protheus.doc} MNTA221INC
Inclusao, alteracao, exclusao e visualizacao do Desenho do
Esquema Padrao

@param cALIAS, Caracter, Alias da tabela utilizada.
@param nReg, Numérico, Numero do recno no registro.
@param nOpcx, Numérico, Numero da opção selecionada.

@author Vitor Emanuel Batista
@since 14/07/2009

@return Vazio.
/*/
//---------------------------------------------------------------------
Function MNTA221INC(cALIAS,nReg,nOpcx)
	Local oDlg, oMenu
	Local oPanelTot //Painel para adequação da tela.
	Local aPosObj  := {0,0,70,0}
	Local aCHOICE  := NGCAMPNSX3("TQ0")
	Local lTudoOk  := .F.

	//Variaveis para a imagens
	Local cBARRAS  := If(GetRemoteType() == 2,"/","\")
	Local nWidht   := 0
	Local nHeight  := 0

	Private nCbxStepe

	Private lOldEsquema := .F.

	//Indica se Utiliza Gestao de Frota
	Private lGFrota   := NGVERUTFR()

	//Numero de Ids adicionados
	Private nId := 0

	//Objetos Privates da Tela
	Private oTPanel, oEnc221, oBtnNext, oBtnPrev

	//Posicao na Array aEstrutura
	Private nPosEstru

	//Array contendo todas as estruturas
	Private aEstruturas

	Private aStepes   := {} //Variavel com os dados de todos os Stepes
	Private aOrderPneu:= {} //Indica posicao do pneu
	Private aRodados  := {} //Variavel com os dados de todos os pneus com localizacao, tipo eixo etc
	Private aShape    := {} //Array com shapes da estrutura e pneus
	Private aAllShape := {} //Array com todos os shapes da classe

	Private aTELA[0][0],aGETS[0],aHeader[0]

	//Carrega na memoria campos da tabela
	RegToMemory(cALIAS,nOpcx == 3)

	//Variavel padrao com o diretoria das imagens
	Private cDirImg   := GetTempPath()+"rodados"+cBARRAS //cDirExe

	SetVisual()
	If nOpcx == 3
		SetInclui()
		nPosEstru    := 1
		M->TQ0_EIXOS := 1
		aEstruturas  := NGRETESTRU(Nil,M->TQ0_EIXOS)
	Else
		If nOpcx == 4
			SetAltera()
		ElseIf nOpcx == 5
			SetExclui()
		EndIf

		aEstruturas := NGRETESTRU(Nil,TQ0->TQ0_EIXOS)
		nPosEstru  := aSCAN(aEstruturas,{|x| x[1] == Trim(TQ0->TQ0_CODEST)})
		If nPosEstru == 0
			If ALTERA
				If Len(aEstruturas) == 0
					ShowHelpDlg(STR0007,	{STR0027},1,; //"ATENÇÃO"###"Não existe estrutura gráfica para o Esquema Padrão selecionado."
												{STR0028},1) //"Utilize a outra rotina de Esquema Padrão."
					Return .F.
				Else
					ShowHelpDlg(STR0007,	{STR0029},1,; //"ATENÇÃO"###"Este esquema padrão ainda não foi relacionado com uma imagem de uma estrutura."
												{STR0030},1) //"Escolha a seguir a estrutura e faça as devidas configurações."
				EndIf
				nPosEstru := 1
			Else
				ShowHelpDlg(STR0007,	{STR0029},1,; //"ATENÇÃO"###"Este esquema padrão ainda não foi relacionado com uma imagem de uma estrutura."
											{STR0031},1) //"Escolha a opção Alterar para fazer as configurações na estrutura."
				Return .F.
			EndIf
			lOldEsquema := .T.
		EndIf

	EndIf

	DEFINE MSDIALOG oDlg TITLE cCadastro From 0,0 To 590,1010 COLOR CLR_BLACK,CLR_WHITE PIXEL

		//Cria Painel para adequação da tela.
		oPanelTot := TPanel():New(0,0,,oDlg,,,,,,0,0,.F.,.F.)
			oPanelTot:Align := CONTROL_ALIGN_ALLCLIENT

		oEnc221 := MsmGet():New(cALIAS, nReg, nopcx,,,,aCHOICE,aPosObj,,3,,,,oPanelTot)
			oEnc221:oBox:Align := CONTROL_ALIGN_TOP
			nCbxStepe := aScan(oEnc221:AENTRYCTRLS,{|x| "TQ0_STEPE" $ x:cREADVAR})
			oEnc221:AENTRYCTRLS[nCbxStepe]:aItems := {"N="+STR0033,"1="+STR0034,"2="+STR0035,"3="+STR0044,"4="+STR0045,"6="+STR0046,"8="+STR0047} //"Nao"##"Um"##"Dois"##"Três"##"Quatro"##"Seis"##"Oito" //Altera combo de Reserva
			oEnc221:AENTRYCTRLS[nCbxStepe]:bHelp := { || ShowHelpCpo("TQ0_STEPE", ;
							{STR0032},5,; //"Indica se a estrutura possui Stepes. N=Não;1=Um;2=Dois."
							{},0)  }

			oEnc221:AENTRYCTRLS[nCbxStepe]:Refresh()

			If !INCLUI//Altera a variavel de memoria, pois o MsmGet tras default 'N' ao alterar
				If !ALTERA
					oEnc221:AENTRYCTRLS[nCbxStepe]:BSETGET := {|X| IF (VALTYPE(X) <> 'U',M->TQ0_STEPES,M->TQ0_STEPES)}
					M->TQ0_STEPES := 'N'
					oEnc221:AENTRYCTRLS[nCbxStepe]:Refresh()
				EndIf
				M->TQ0_STEPES := TQ0->TQ0_STEPES
				oEnc221:AENTRYCTRLS[nCbxStepe]:Refresh()
			EndIf

			//-----------------------------------------------------------------------
			// Cria objeto auxiliar para perda de foco no objeto combobox TQ0_STEPES
			//-----------------------------------------------------------------------
			TGet():New( -100, -100,{|| " "},oEnc221:oBox,1,,,{|| oEnc221:AENTRYCTRLS[nCbxStepe]:SetFocus()},,,,.t.,,.T.,,.t.,/*&(cBlkWhen)*/,.F.,.F.,,.F.,.F.,,/*(cCampo)*/,,,,.t.)

		oTPanel  := TPaintPanel():new(0,0,0,0,oPanelTot,.f.)
			oTPanel:Align       := CONTROL_ALIGN_ALLCLIENT
			oTPanel:bLDblClick  := {|x,y| ClickEstru(x,y)}    //Duplo clique
			oTPanel:blClicked   := {|x,y| ClickEstru(x,y)}
			oTPanel:addShape(	"id=0;type=1;left=0;top=0;width=1000;height=1000;gradient=1,0,0,0,0,0.0,#FFFFFF;pen-width=0;"+;
									"pen-color=#FFFFFF;can-move=0;can-mark=0;is-container=1;") //Cria Container

		If INCLUI .Or. lOldEsquema
			oBtnPrev := TBtnBmp2():New( 005,435,26,26,'PGPREV',,,,{||ImgPrevNext('PREV',oTPanel:nWidth,oTPanel:nHeight)},oTPanel,,{|| Len(aEstruturas) != 1},.T. )
			oBtnNext := TBtnBmp2():New( 005,461,26,26,'PGNEXT',,,,{||ImgPrevNext('NEXT',oTPanel:nWidth,oTPanel:nHeight)},oTPanel,,{|| Len(aEstruturas) != 1},.T. )
		EndIf


		If Len(aSMenu) > 0
			NGPOPUP(aSMenu,@oMenu)
			oPanelTot:bRClicked := { |o,x,y| oMenu:Activate(x,y,oPanelTot)}
			oEnc221:oBox:bRClicked := { |o,x,y| oMenu:Activate(x,y,oEnc221:oBox)}
		Endif

	ACTIVATE MSDIALOG oDlg ON INIT (CriaEstrutura(),EnchoiceBar(oDlg,{|| lTudoOk := .T.,If(!MNT221VLD(),lTudoOk := .F.,oDlg:End())},;
												{|| lTudoOk := .F.,oDlg:End()})) CENTERED

	If lTudoOk
		BEGIN TRANSACTION
		GravaEstru()
		END TRANSACTION
	EndIf

Return

//---------------------------------------------------------------------
/*/{Protheus.doc} MNT221VLD
Verifica se todos os dados dos pneus foram preenchidos

@author Vitor Emanuel Batista
@since 14/07/2009

@return lRet, Lógico, Retorna falso caso alguma condição esteja errada.
/*/
//---------------------------------------------------------------------
Static Function MNT221VLD()
	Local nX, nY, nZ, nR
	Local lRet := .t.
	Local cAllLoc, cDelLoc

	//Valida campos do Enchoice
	If !Obrigatorio(aGets,aTela)
		Return .f.
	EndIf

	//Valida todos os pneus da estrutura
	If Len(aRodados) != Len(aEstruturas[nPosEstru][4])+1
		lRet := .f.
	EndIf

	If lRet
		//Valida Pneus na Estrutura
		For nX := 2 To Len(aRodados)
			nR := nX-1
			If Len(aRodados[nX])-2 != Len(aEstruturas[nPosEstru][4][nR])
				lRet := .f.
				Exit
			Else
				For nY := 2 To Len(aRodados[nX])-1
					For nZ := 1 To Len(aRodados[nX][nY])
						If Empty(aRodados[nX][nY][nZ])
							lRet := .f.
							Exit
						EndIf
					Next nZ
				Next nY
			EndIf
		Next nX

		//Valida Stepes
		If lRet
			For nY := 2 To Len(aRodados[1])-1
				For nZ := 1 To Len(aRodados[1][nY])
					If M->TQ0_STEPES != "N" .And. Val(M->TQ0_STEPES) >= nY-1
						If Empty(aRodados[1][nY][nZ])
							lRet := .f.
							Exit
						EndIf
					EndIf
				Next nZ
			Next nY
		EndIf
	EndIf

	If !lRet
		ShowHelpDlg(STR0007,	{STR0008},1,; //"ATENÇÃO"###"Existem pneus que não foram detalhados."
										{STR0009},1) //"Informe os detalhes necessários para todos os pneus da estrutura"
	EndIf

	cAllLoc := ""

	For nX := 1 To Val(M->TQ0_STEPES)
		cAllLoc += ValToSql(aRodados[1][nX+1][3])+","
	Next nX

	For nX := 2 To Len(aRodados)
		For nY := 2 To Len(aRodados[nX])-1
			cAllLoc += ValToSql(aRodados[nX][nY][3])+","
		Next nY
	Next nX

	//Verifica na exclusao se ja existem estrutura de Bens com pneus em localizacoes
	If EXCLUI .And. lRet
		lRet := MNT221VDEL(M->TQ0_DESENH,M->TQ0_TIPMOD,Substr(cAllLoc,1,Len(cAllLoc)-1))
	ElseIf ALTERA .And. lRet
		cDelLoc := ""
		dbSelectArea("TQ1")
		dbSetOrder(1)
		dbSeek(xFilial("TQ1")+M->TQ0_DESENH+M->TQ0_TIPMOD)
		While !Eof() .And. xFilial("TQ1")+M->TQ0_DESENH+M->TQ0_TIPMOD == TQ1->TQ1_FILIAL+TQ1->TQ1_DESENH+TQ1->TQ1_TIPMOD
			For nX := 0 to 9
				cCpoLoc := "TQ1->TQ1_LOCPN"+cValToChar(nX)
				If !Empty(&cCpoLoc) .And. !(&cCpoLoc $ cAllLoc)
					cDelLoc += ValToSql(&cCpoLoc)+","
				EndIf
			Next nX
			dbSkip()
		EndDo

		If !Empty(cDelLoc)
			lRet := MNT221CHKLC(M->TQ0_DESENH,M->TQ0_TIPMOD,Substr(cDelLoc,1,Len(cDelLoc)-1))
			If !lRet
				cLocaliz := Substr(cDelLoc,2,Len(TQ1->TQ1_LOCPN0))
				ShowHelpDlg(STR0007,	{STR0039 + cLocaliz},1,; //"ATENÇÃO"###"Alteração não permitida pois existem estruturas de Bens com pneus para a localização excluida: "
											{STR0040},1) //"Adicione a Localização no Esquema Padrão ou exclua os pneus na localização informada em todas as estruturas."
			EndIf
		EndIf
	EndIf

Return lRet

//---------------------------------------------------------------------
/*/{Protheus.doc} MNT221VDEL
Valida exclusao do Esquema Padrao, verificando localizacao

@param cDesenho, Caracter, Desenho do Esquema Padrao
@param cTipMod, Caracter, Tipo Modelo do Esquema Padrao
@param cAllLoc, Caracter, Localizacoes dos pneus no Esquema Padrao

@author Vitor Emanuel Batista
@since 14/07/2009

@return lRet, Lógico, Retorna falso caso alguma condição esteja errada.
/*/
//---------------------------------------------------------------------
Function MNT221VDEL(cDesenho,cTipMod,cAllLoc)
	Local lRet := .T.

	lRet := MNT221CHKLC(cDesenho,cTipMod,cAllLoc)
	If !lRet
		ShowHelpDlg(STR0007,	{STR0036},1,; //"ATENÇÃO"###"Exclusão não permitida pois existem estruturas de Bens com pneus para este Esquema Padrão."
									{STR0037},1)//"Exclua as estruturas para poder excluir este Esquema Padrão."
	EndIf

Return lRet

//---------------------------------------------------------------------
/*/{Protheus.doc} MNT221CHKLC
Valida se existe Pneus em estruturas do Esquema Padrao

@param cDesenho, Caracter, Desenho do Esquema Padrao
@param cTipMod, Caracter, Tipo Modelo do Esquema Padrao
@param cAllLoc, Caracter, Localizacoes dos pneus no Esquema Padrao

@obs Utilização nos fontes MNTA220/MNTA221.

@author Vitor Emanuel Batista
@since 14/07/2009

@return lRet, Lógico, Retorna falso caso alguma condição esteja errada.
/*/
//---------------------------------------------------------------------
Function MNT221CHKLC(cDesenho,cTipMod,cAllLoc)
Local lRet := .T.
Local cQryAlias,cQuery
Local aArea := GetArea()

cQryAlias := GetNextAlias()
cQuery := " SELECT COUNT(*) AS QUANT FROM " + RetSqlName("ST9") + " ST9 "
cQuery += " INNER JOIN " + RetSqlName("STZ") + " STZ ON TZ_BEMPAI = T9_CODBEM AND STZ.D_E_L_E_T_ = ''"
cQuery += " WHERE T9_CODFAMI = " + ValToSql(cDesenho)

If GetRPORelease() >= '12.1.033' .And. Trim(cTipMod) == '*'
	cQuery += " AND NOT EXISTS ( SELECT 1"
	cQuery += 	" FROM " + RetSqlName('TQ0') + " TQ0PAD"
	cQuery +=   " WHERE TQ0PAD.TQ0_DESENH = " + ValToSql( cDesenho )
	cQuery +=   " AND TQ0PAD.TQ0_TIPMOD = ST9.T9_TIPMOD"
	cQuery +=   " AND TQ0PAD.TQ0_FILIAL = " + ValToSql( xFilial('TQ0') )
	cQuery +=   " AND TQ0PAD.D_E_L_E_T_ = ' ' ) "
Else
	cQuery += " AND T9_TIPMOD = " + ValToSql(cTipMod)
EndIf

cQuery += "       AND TZ_LOCALIZ IN (" + cAllLoc + ")"
cQuery += "       AND TZ_DATASAI = '' AND TZ_TIPOMOV = 'E' AND ST9.D_E_L_E_T_ = ''"
cQuery := ChangeQuery(cQuery)
dbUseArea( .T., "TOPCONN", TCGenQry(,,cQuery), cQryAlias, .F., .T.)
If (cQryAlias)->QUANT > 0
	lRet := .F.
EndIf
(cQryAlias)->(dbCloseArea())

RestArea(aArea)

Return lRet

//---------------------------------------------------------------------
/*/{Protheus.doc} CriaEstrutura
Cria Estrutura de acordo com a variavel nPosEstru

@author Vitor Emanuel Batista
@since 14/07/2009

@return Sempre verdadeiro.
/*/
//---------------------------------------------------------------------
Static Function CriaEstrutura()
	Local nX, nY, nR, nEixo
	Local cEstrutura := cDirImg+"NG_ESTRUTURA_"+aEstruturas[nPosEstru][1]+".PNG"
	Local cId, cEixo
	Local lReserva := .f.
	Local lComecou := .f.
	Private cAltura, cLargura

	If Len(aRodados) > 0 .And. INCLUI
		//Valida Pneus na Estrutura
		For nX := 2 To Len(aRodados)
			nR := nX-1
			For nY := 2 To Len(aRodados[nX])-1
				If !Empty(aRodados[nX][nY][3]) .Or. !Empty(aRodados[nX][nY][4])
					lComecou := .t.
					Exit
				EndIf
			Next nY
		Next nX

		//Valida Stepes
		If !lComecou
			For nY := 2 To Len(aRodados[1])
				If M->TQ0_STEPES != "N" .And. Val(M->TQ0_STEPES) >= nY-1
					If !Empty(aRodados[1][nY][3]) .Or. !Empty(aRodados[1][nY][4])
						lComecou := .t.
						Exit
					EndIf
				EndIf
			Next nY
		EndIf

		If lComecou
			If !MsgYesNo(STR0010,STR0007) //"Esta estrutura já está pré-configurada, as informações cadastradas serão perdidas. Confirmar?"
				Return .f.
			EndIf
		EndIf
	EndIf

	//Apaga informacoes cadastradas
	aRodados   := {}
	aOrderPneu := {}

	For nX := 1 to Len(aAllShape)
		DeleteItem(@oTPanel,aAllShape[nX][1])
	Next nX

	//Exclui array de todos os shapes
	aAllShape := {}

	//Tamanho da estrutura
	cEstruLarg := cValToChar(aEstruturas[nPosEstru][2])
	cEstruAlt  := cValToChar(aEstruturas[nPosEstru][3])

	//Altura largura da estrutura - CENTRALIZA ESTRUTURA
	cAltura  := cValToChar((oTPanel:nHeight - Val(cEstruAlt))/2+10)//Centraliza estrutura considerando botões "<<Anterior - Próximo>>"
	cLargura := cValToChar((oTPanel:nWidth - Val(cEstruLarg))/2)

	//|----------------|
	//| Cria Estrutura |
	//|----------------|
	cId := RetId()
	oTPanel:addShape("id="+cId+";type=8;left="+cLargura+";top="+cAltura+";width="+cEstruLarg+";height="+cEstruAlt+;
							";image-file="+lower(cEstrutura)+";can-move=0;can-deform=0;can-mark=0;is-container=1") //tooltip=Rodados

	If Len(aRodados) == 0
		aRodados := Array(Len(aEstruturas[nPosEstru][4])+1)
	EndIf

	dbSelectArea("TQ1")
	dbSetOrder(1)

	If Len(aEstruturas[nPosEstru][5][1]) == 0
		M->TQ0_STEPES := "N"
		oEnc221:AENTRYCTRLS[nCbxStepe]:Refresh()
	ElseIf (M->TQ0_STEPES != "N") .and. (Val(M->TQ0_STEPES) > Len(aEstruturas[nPosEstru][5][1]))
		M->TQ0_STEPES := cValToChar(Len(aEstruturas[nPosEstru][5][1]))
		oEnc221:AENTRYCTRLS[nCbxStepe]:Refresh()
	EndIf

	//Adiciona Stepes na Estrutura
	For nY := 1 To Len(aEstruturas[nPosEstru][5])
		If aRodados[1] == Nil
			aRodados[1] := {}
			aAdd(aRodados[1],"1") //TQ1_TIPEIX
		EndIf

		lReserva := .f.
		If !INCLUI
			dbSeek(xFilial("TQ1")+TQ0->TQ0_DESENH+TQ0->TQ0_TIPMOD)
			While !Eof() .And. xFilial("TQ1") == TQ1->TQ1_FILIAL .And. TQ1->TQ1_DESENH == TQ0->TQ0_DESENH ;
								.And. TQ1->TQ1_TIPMOD == TQ0->TQ0_TIPMOD
				If TQ1->TQ1_EIXO = STR0011 //"RESERVA"
					lReserva := .t.
					Exit
				EndIf
				dbSkip()
			EndDo
		EndIf

		If !lReserva
			dbGoBottom()
			dbSkip()
		ElseIf lOldEsquema
			M->TQ0_STEPES := If(Empty(TQ1->TQ1_LOCPN2),'1','2')
			oEnc221:AENTRYCTRLS[nCbxStepe]:Refresh()
		EndIf

		CriaEixo(1,.T.,nY)
	Next nY

	//Adiciona Pneus na Estrutura
	For nX := 1 to Len(aEstruturas[nPosEstru][4])

		nEixo   := nX
		cEixo   := cValToChar(nEixo)

		If !INCLUI
			dbSeek(xFilial("TQ1")+TQ0->TQ0_DESENH+TQ0->TQ0_TIPMOD+Str(nEixo,3))
		Else
			dbGoBottom()
			dbSkip()
		EndIf

		If aRodados[nEixo+1] == Nil
			aRodados[nEixo+1] := {}
			aAdd(aRodados[nEixo+1],TQ1->TQ1_TIPEIX)
		EndIf

   	CriaEixo(nEixo+1,.F.,nX)
	Next nX

Return .t.

//---------------------------------------------------------------------
/*/{Protheus.doc} CriaEixo
Cria eixo completo

@param nEixo, Numérico, Posição na array aRodados.
@param lStepe, Lógico, Indica se eh stepe ou nao.
@param nAtu, Numérico, Posição na array aEstruturas.

@author Vitor Emanuel Batista
@since 14/07/2009

@return Vazio.
/*/
//---------------------------------------------------------------------
Static Function CriaEixo(nEixo,lStepe,nAtu)
	Local nY
	Local nEstru := If(lStepe,5,4) //Posicao
	Local nVida := 1
	Local cCodLoc := ""
	Local lSuspenso := .F.
	Local cPneuX, cPneuY

	For nY := 1 To Len(aEstruturas[nPosEstru][nEstru][nAtu])
		cCodType := aEstruturas[nPosEstru][nEstru][nAtu][nY][1]
		nPneuX := Val(cLargura)+Val(aEstruturas[nPosEstru][nEstru][nAtu][nY][2])
		nPneuY := Val(cAltura)+Val(aEstruturas[nPosEstru][nEstru][nAtu][nY][3])
		cPneuX := cValToChar(nPneuX)
		cPneuY := cValToChar(nPneuY)

		aAdd(aOrderPneu,{cPneuX+cPneuY,cValToChar(nY)})

		aAdd(aRodados[nEixo],Array(6))
		nPos := Len(aRodados[nEixo])

		aRodados[nEixo][1] := If(lStepe .Or. INCLUI ,"1",TQ1->TQ1_TIPEIX)
		aRodados[nEixo][nPos][1] := cPneuX
		aRodados[nEixo][nPos][2] := cPneuY
		aRodados[nEixo][nPos][3] := &("TQ1->TQ1_LOCPN"+cValToChar(nY))
		aRodados[nEixo][nPos][4] := &("TQ1->TQ1_FAMIL"+cValToChar(nY))
		aRodados[nEixo][nPos][5] := cValToChar(nY)
		aRodados[nEixo][nPos][6] := cCodType

		cCodLoc := aRodados[nEixo][nPos][3]

		//Adiciona na ultima posicao o numero do Eixo
		If lStepe
			aAdd(aEstruturas[nPosEstru][nEstru][nAtu][nY],0)
		EndIf


		If !lStepe .Or. (lStepe .And. M->TQ0_STEPES != "N" .And. Val(M->TQ0_STEPES) >= nY)
			NGCriaPneu( oTPanel,;
							nPneuX,;
							nPneuY,;
							cCodType,;
							cCodLoc,;
							nVida,;
							lStepe,; //estepe
							Empty(cCodLoc),; //clicado
							.f.,;
							aEstruturas[nPosEstru][nEstru][nAtu][nY],;
							"L")
		EndIf

		Next nY

	//Adiciona no aRodados a indicadao de eixo suspenso
	lSuspenso := If(lTQ1SUSP, (TQ1->TQ1_SUSPEN == '1') ,.F.)
	aAdd(aRodados[nEixo],lSuspenso) //eixo suspenso?

Return

//---------------------------------------------------------------------
/*/{Protheus.doc} CriaEixo
Grava Estrutura (TQ0 e TQ1)

@author Vitor Emanuel Batista
@since 14/07/2009

@return Sempre verdadeiro.
/*/
//---------------------------------------------------------------------
Static Function GravaEstru()
	Local nX ,ny, nz
	Local lAltStepe := .F.
	Local cSeqRela

	dbSelectArea("TQ0")
	dbSeek(xFilial("TQ0") + M->TQ0_DESENH+M->TQ0_TIPMOD)
	If INCLUI .OR. ALTERA

		If TQ0->TQ0_STEPES != M->TQ0_STEPES
			lAltStepe := .T.
		EndIf

		RecLock("TQ0",!Found())
		For ny := 1 To TQ0->(FCOUNT())
			nx := "M->" + FieldName(ny)
			FieldPut(ny, &nx.)
		Next ny

		TQ0->TQ0_FILIAL := xFilial('TQ0')
		TQ0->TQ0_DESENH := M->TQ0_DESENH
		TQ0->TQ0_TIPMOD := M->TQ0_TIPMOD
		TQ0->TQ0_EIXOS  := M->TQ0_EIXOS
		TQ0->TQ0_STEPES := M->TQ0_STEPES
		TQ0->TQ0_CODEST := aEstruturas[nPosEstru][1]
		TQ0->(MsUnLock())

		dbSelectArea("TQ1")
		dbSetOrder(1)
		If dbSeek(xFilial("TQ1")+M->TQ0_DESENH+M->TQ0_TIPMOD) .And. (lAltStepe .Or. lOldEsquema)
			While !Eof() .And. TQ1->TQ1_FILIAL == xFilial('TQ1') .And. TQ1->TQ1_DESENH == M->TQ0_DESENH .And. TQ1->TQ1_TIPMOD == M->TQ0_TIPMOD
				If lOldEsquema .Or. TQ1->TQ1_EIXO = STR0011 //"RESERVA"
					RecLock("TQ1",.F.)
					dbDelete()
					TQ1->(MsUnLock())
				EndIf
				dbskip()
			EndDo
		EndIf


		For nX := 1 to Len(aRodados)

			If nX == 1 .And. M->TQ0_STEPES == "N"
				Loop
			EndIf

			If nX == 1
				cSeqRel := Str(Len(aRodados),3)
				cEixo   := STR0011 //"RESERVA"
				nQtdPne := Val(M->TQ0_STEPES)
			Else
				cSeqRel := Str(nx-1,3)
				cEixo   := cSeqRel
				nQtdPne := Len(aRodados[nX])-2
			EndIf

			dbSelectArea("TQ1")
			dbSetOrder(1)
			dbSeek(xFilial("TQ1")+M->TQ0_DESENH+M->TQ0_TIPMOD+cSeqRel)
			RecLock("TQ1",!Found())
			TQ1->TQ1_FILIAL := xFilial('TQ1')
			TQ1->TQ1_DESENH := M->TQ0_DESENH
			TQ1->TQ1_TIPMOD := M->TQ0_TIPMOD
			TQ1->TQ1_SEQREL := cSeqRel

			TQ1->TQ1_EIXO   := cEixo
			TQ1->TQ1_TIPEIX := aRodados[nX][1]
			TQ1->TQ1_QTDPNE := nQtdPne
			For nY := 2 to Len(aRodados[nX])-1
				If nX > 1 .Or. (nX == 1 .And. Val(M->TQ0_STEPES) >= nY-1)
					cCpoLoc := "TQ1->TQ1_LOCPN"+aRodados[nX][nY][5]
					cCpoFam := "TQ1->TQ1_FAMIL"+aRodados[nX][nY][5]
					&cCpoLoc. := aRodados[nX][nY][3]
					&cCpoFam. := aRodados[nX][nY][4]
				EndIf
			Next nY
			If lTQ1SUSP
				TQ1->TQ1_SUSPEN := If(aRodados[nX][Len(aRodados[nX])],'1','2')
			EndIf
			TQ1->(MsUnLock())
		Next nx
	ElseIf EXCLUI
		dbSelectArea("TQ1")
		dbSetOrder(1)
		If dbSeek(xFilial("TQ1")+M->TQ0_DESENH+M->TQ0_TIPMOD)
			While !Eof() .And. TQ1->TQ1_FILIAL == XFILIAL("TQ1") ;
							.And. TQ1->TQ1_DESENH == M->TQ0_DESENH .And. TQ1->TQ1_TIPMOD == M->TQ0_TIPMOD
				RecLock("TQ1",.F.)
				dbdelete()
				TQ1->(MSUNLOCK())
				dbSelectArea("TQ1")
				dbskip()
			EndDo
		EndIf

		RecLock("TQ0",.F.)
		dbdelete()
		TQ0->(MSUNLOCK())

	EndIf
Return .T.

//---------------------------------------------------------------------
/*/{Protheus.doc} ClickEstru
Funcao chamada no duplo clique no pneu, informando Tipo do
Eixo, Localizacao e Familia

@param x, Numérico, Utilizado para controle de posicionamento.
@param y, Numérico, Utilizado para controle de posicionamento.

@author Vitor Emanuel Batista
@since 14/07/2009

@return Vazio.
/*/
//---------------------------------------------------------------------
Function ClickEstru(x,y)
	Local oDlg, oGetLoc, oGetFam
	Local cCpoLoc,cEixo, cItems, cPosX, cPosY
	Local nPos, nCpoPos, nEixo
	Local nIdPneu, nIdTxt, nShape, nInvisible
	Local aItems    := {}
	Local lTudoOk   := .F., lSuspenso := .F.
	Local cNomLocal := Space(Len(TPS->TPS_CODLOC))
	Local cNomFami  := Space(Len(ST6->T6_CODFAMI))

	//Indica na alteracao qual era a localizacao anterior
	Private cOldLoc := ""
	Private cOldFam := ""

	//Clicou na Imagem Pneu
	nShape := aSCAN(aShape,{|x| (x[__IDPNEU__] == oTPanel:ShapeAtu) .And. !aTail(X)[__INVISIBLE__]})
	If nShape == 0
		//Clicou no Texto do codigo so pneu
		nShape := aSCAN(aShape,{|x| (x[6][__IDTXT__] == oTPanel:ShapeAtu) .And. !aTail(X)[__INVISIBLE__]})

		//Verifica se shape eh o invisivel
		If nShape == 0
			//Clicou na Imagem Pneu
			nInvisible := aSCAN(aShape,{|x| (x[__IDPNEU__] == oTPanel:ShapeAtu) })
			If nInvisible == 0
				//Clicou no Texto do codigo so pneu
				nInvisible := aSCAN(aShape,{|x| (x[6][__IDTXT__] == oTPanel:ShapeAtu)})
			EndIf
		EndIf
	EndIf

	//Se encontrou o shape
	If nShape > 0

		M->TQ1_TIPEIX := Space(Len(TQ1->TQ1_TIPEIX)) //Tipo de Eixo - Livre, Direcional etc
		cItems  := AllTrim( Posicione( 'SX3', 2, 'TQ1_TIPEIX', 'X3CBox()' ) ) //Pega conteudo do X3_CBOX
		aItems  := StrTokArr(cItems,";") //Transforma String em array para aItems

		//Informacoes adicionais - aInfo
		cPosX   := cValToChar(aShape[nShape][3])
		cPosY   := cValToChar(aShape[nShape][4])
		nEixo   := aTail(aShape[nShape][7]) + 1
		cEixo   := cValToChar(nEixo)

		//Verifica posicao no aOrderPneu para saber numero do campo de localizacao e familia
		nCpoPos := aScan(aOrderPneu,{|aArray| aArray[1] == cPosX+cPosY })

		//Altera campo de acordo com o eixo para utilizar Help do eixo especificado
		cCpoLoc := "TQ1_LOCPN"+aOrderPneu[nCpoPos][2]
		cCpoFam := "TQ1_FAMIL"+aOrderPneu[nCpoPos][2]
		M->&cCpoLoc. := Space(Len(TQ1->&cCpoLoc.))
		M->&cCpoFam. := Space(Len(TQ1->&cCpoFam.))

		//Verifica se ja foi informado dados para este pneu
		If Len(aRodados)  >= nEixo .And. aRodados[nEixo] != Nil
			nPos := aScanX(aRodados[nEixo],{|aArray,nPos| nPos > 1 .And. aArray[1]+aArray[2] == cPosX+cPosY })
			If nPos > 0
				cOldLoc        := aRodados[nEixo][nPos][3]
				cOldFam        := aRodados[nEixo][nPos][4]
				M->&cCpoLoc.   := aRodados[nEixo][nPos][3]
				M->&cCpoFam.   := aRodados[nEixo][nPos][4]
				cNomLocal      := NGSEEK("TPS",M->&cCpoLoc.,1,"TPS->TPS_NOME")
				cNomFami       := NGSEEK("ST6",M->&cCpoFam.,1,"ST6->T6_NOME")
			EndIf
			M->TQ1_TIPEIX := aRodados[nEixo][1]
			lSuspenso     := If(!lTQ1SUSP, .F., If(nEixo == 1/*estepe*/, .F., aRodados[nEixo][Len(aRodados[nEixo])]) )
		EndIf

		DEFINE MSDIALOG oDlg TITLE OemToAnsi(STR0012) From 0,0 To 200,700 Pixel COLOR CLR_BLACK,CLR_WHITE //"Informações adicionais sobre o Pneu"
			oDlg:lEscClose := .F.

			oPnlPai := TPanel():New(00,00,,oDlg,,,,,,430,160,.F.,.F.)
		   		oPnlPai:Align := CONTROL_ALIGN_ALLCLIENT

			If lTQ1SUSP .And. nEixo != 1  //usa eixo suspenso e nao eh reserva
				TCheckBox():New(08,133,"Eixo Suspenso",{||lSuspenso},oPnlPai,60,10,,{||lSuspenso:=!lSuspenso},,,,,,.T.,"Indica se o eixo pode ser suspenso")
			EndIf

			@10,10 Say NGRETTITULO("TQ1_TIPEIX") PIXEL COLOR CLR_HBLUE of oPnlPai//Tipo do Eixo
			@08,49 Combobox M->TQ1_TIPEIX Items aItems Size 74,50 OF oPnlPai WHEN nEixo > 1 .And. (INCLUI .OR. ALTERA) PIXEL

			@33,10 Say NGRETTITULO(cCpoLoc) PIXEL COLOR CLR_HBLUE of oPnlPai//Localizacao
			@31,49 MsGet oGetLoc Var M->&cCpoLoc. Valid MNTA221LOC(M->&cCpoLoc.,cEixo,aOrderPneu[nCpoPos][2],@cNomLocal);
																Picture "@!" F3 "TPS" SIZE 33,09 WHEN INCLUI .OR. ALTERA PIXEL of oPnlPai HASBUTTON
				oGetLoc:cReadVar := "M->"+cCpoLoc

			@31,095 MsGet cNomLocal Picture "@!" SIZE 100,09 WHEN .F. PIXEL of oPnlPai HASBUTTON

			@46,10 Say NGRETTITULO(cCpoFam) PIXEL COLOR CLR_HBLUE of oPnlPai//Familia
			@46,49 MsGet oGetFam Var M->&cCpoFam. Valid MNTA221FAM(M->&cCpoFam.,@cNomFami) Picture "@!" F3 "ST6" SIZE 33,09 WHEN INCLUI .OR. ALTERA PIXEL of oPnlPai HASBUTTON
				oGetFam:cReadVar := "M->"+cCpoFam

			@46,095 MsGet cNomFami Picture "@!" SIZE 100,09 WHEN .F. PIXEL of oPnlPai HASBUTTON

		ACTIVATE MSDIALOG oDlg ON INIT EnchoiceBar(oDlg,{||lTudoOk := .T.,If(ValidPneu(M->&cCpoLoc.,M->&cCpoFam.),oDlg:End(),lTudoOk:=.F.)},{||lTudoOk := .F.,oDlg:End()}) Centered

		If lTudoOk
			If Len(aRodados) == 0
				aRodados := Array(Len(aEstruturas[nPosEstru][4]))
			EndIf

			If Empty(nPos)
				If aRodados[nEixo] == Nil
					aRodados[nEixo] := {}
					aAdd(aRodados[nEixo],M->TQ1_TIPEIX)
				EndIf
				aAdd(aRodados[nEixo],Array(5))
				aAdd(aRodados[nEixo],lSuspenso) //eixo suspenso
				nPos := Len(aRodados[nEixo])
			EndIf
			aRodados[nEixo][1] := M->TQ1_TIPEIX
			aRodados[nEixo][nPos][1] := cPosX
			aRodados[nEixo][nPos][2] := cPosY
			aRodados[nEixo][nPos][3] := M->&cCpoLoc.
			aRodados[nEixo][nPos][4] := M->&cCpoFam.
			aRodados[nEixo][nPos][5] := aOrderPneu[nCpoPos][2]
			aRodados[nEixo][Len(aRodados[nEixo])] := lSuspenso

			NGCriaPneu(@oTPanel,;
							aShape[nShape][__IMGX__],;
							aShape[nShape][__IMGY__],;
							aShape[nShape][__TYPE__],;
							aRodados[nEixo][nPos][3],;
							1,;
							aTail(aShape[nShape])[__ESTEPE__],;
							.F.,;
							.F.,;
							aShape[nShape][7],;
							"L")

			nIdPneu := aShape[nShape][__IDPNEU__]
			nIdTxt  := aShape[nShape][6][__IDTXT__]
			DeleteItem(@oTPanel,nIdPneu)
			DeleteItem(@oTPanel,nIdTxt)

		EndIf
	EndIf
Return

//---------------------------------------------------------------------
/*/{Protheus.doc} MNTA221LOC
Valida Localizacao do pneu

@param cLocaliza, Caracter, Determina a localização.
@param cEixo, Caracter, Determina o eixo.
@param cLocPneu, Caracter, Determina a localização do pneu.
@param cNomLoc, Caracter, Determina o nome da localização.

@author Vitor Emanuel Batista
@since 14/07/2009

@return Sempre Verdadeiro.
/*/
//---------------------------------------------------------------------
Static Function MNTA221LOC(cLocaliza,cEixo,cLocPneu,cNomLoc)
	Local nX, nPos

	If !EXISTCPO('TPS',cLocaliza)
		Return .f.
	EndIf

	cNomLoc := NGSEEK("TPS",cLocaliza,1,"TPS->TPS_NOME")

	//Valida a alteracao da localizacao, verificando se ja existem pneus na localizacao anterior
	If ALTERA .And. cOldLoc != cLocaliza .And. !Empty(cOldLoc)
		If !MNT221CHKLC(M->TQ0_DESENH,M->TQ0_TIPMOD,ValToSql(cOldLoc))
			MsgStop(STR0038+AllTrim(cOldLoc),STR0007) //"Não é possível alterar a localização do Esquema Padrão pois já existem Estruturas com pneus na localização "
			Return .F.
		EndIf
	EndIf

	For nX := 1 To Len(aRodados)
		nPos := aScanX(aRodados[nX],{|aArray,nPos| ValType(aArray)=="A" .And. nPos > 1 .And. aArray[3] == cLocaliza .And. (( nX == Val(cEixo) .And. cLocPneu != aArray[5]) .Or. nX != Val(cEixo) )  })
		If nPos > 0
			If nX == 1
				If M->TQ0_STEPES > '1'
					MsgStop(STR0013,STR0007) //"Localização já informada para o Stepe."
					Return .f.
				EndIf
			Else
				MsgStop(STR0014+cValToChar(nX-1)+STR0015,STR0007) //"Localização já informada no "###"º eixo."###"Atenção"
				Return .f.
			EndIf
			Return .t.
		EndIf
	Next nX
Return .t.

//---------------------------------------------------------------------
/*/{Protheus.doc} MNTA221FAM
Valida Familia do Pneu

@param cCodFami, Caracter, Determina o código da família.
@param cNomFami, Caracter, Determina o nome da família.

@author Vitor Emanuel Batista
@since 14/07/2009

@return Sempre Verdadeiro.
/*/
//---------------------------------------------------------------------
Static Function MNTA221FAM(cCodFami,cNomFami)

	If !ExistCpo("ST6",cCodFami)
		Return .F.
	EndIf

	cNomFami := NGSEEK("ST6",cCodFami,1,"ST6->T6_NOME")

	//Valida a alteracao da localizacao, verificando se ja existem pneus na localizacao anterior
	If ALTERA .And. cOldFam != cCodFami .And. !Empty(cOldFam)
		If !MNT221CHKLC(M->TQ0_DESENH,M->TQ0_TIPMOD,ValToSql(cOldLoc))
			MsgStop(STR0038+AllTrim(cOldLoc),STR0007) //"Não é possível alterar a localização do Esquema Padrão pois já existem Estruturas com pneus na localização "
			Return .F.
		EndIf
	EndIf

Return .T.

//---------------------------------------------------------------------
/*/{Protheus.doc} NGCriaPneu
Funcao que cria imagem do pneu na tela

@param oPanel, Objeto, Panel que sera criada imagem
@param nImgX, Numérico, Posicao X da imagem
@param nImgY, Numérico, Posicao Y da imagem
@param nType, Numérico, Tipo da Imagem 1, 2 ou 3
@param cCodPneu, Caracter, Codigo do Bem
@param nVida, Numérico, Vida do Pneu
@param lEstepe, Lógico, Indica se pneu adicionado sera estepe
@param lClick, Lógico, Indica se pneu adicionado sera criado pelo duplo
						clique, ficando mais claro/escuro
@param lInvisible, Lógico, Indica que shape ficara invisible, utilizado
							somente para se ter o evento do clique
@param aInfo, Array, Array onde sera adici. no aShape para consultas
@param cTypeCod, Caracter, Tipo de Codigo do Pneu (L - Localizacao, B-Bem )
@param lVisibleText, Lógico, Indica se o texto sobre o pneu será apresentado

@obs Utilização nos fontes MNTA221/MNTA232.

@author Vitor Emanuel Batista
@since 14/07/2009

@return Vazio.
/*/
//---------------------------------------------------------------------
Function NGCriaPneu(oPanel,nImgX,nImgY,cType,cCodPneu,nVida,lEstepe,lClick,lInvisible,aInfo,cTypeToolTip, lVisibleText)
	Local cImgId    := RetId()
	Local cTxtId    := RetId()
	Local aInfoPneu := NGRETPNEUS(cType)
	Local cWidth    := aInfoPneu[2] //tamanho do pneu
	Local cHeight   := aInfoPneu[3] //tamanho do pneu
	Local nTxtX, nTxtY, nLenTxt

	Local cPneuNovo
	Local cPneuVermelho
	Local cPneuVerde
	Local cPneuAzul
	Local cPneuLaranja
	Local cPneu    := ""
	Local cTmpPneu := "" // Usado no ponto de entrada
	Local cToolTip := ""
	Local cCalota

	//Local cCodImg
	Local cTypeImg

	//Cor da Letra, Fonte e tamanho
	Local cCorTxt  := "FFFFFF"
	Local cTxtFont := "Lucida Console" //"Arial Narrow"
	Local cTxtTam  := "13"

	// Variáveis das Áreas de Trabalho
	Local aAreaTQS := TQS->( GetArea() )

	// Defaults
	Default lEstepe := .f.
	Default lClick  := .f.
	Default aInfo   := {}
	Default lInvisible := .f.
	Default cTypeToolTip := "B"
	Default lVisibleText := .T.

	//Calcula Posicao do Txt
	nLenTxt  := Len(AllTrim(cCodPneu))
	nTxtX    := nImgX+Val(cWidth)/If(nLenTxt<3,3,Len(AllTrim(cCodPneu)))
	nTxtY    := nImgY+If(lEstepe,24,If(cType=="3",0,4))

	//Valida o tamanho da letra de acordo com o tamanho do codigo do pneu
	If nLenTxt <= 8
		cTxtTam := "10"
	ElseIf nLenTxt == 9
		cTxtTam := "9"
	ElseIf nLenTxt == 10
		cTxtTam := "8"
	ElseIf nLenTxt <= 13 
		cTxtTam := "6"
	ElseIf nLenTxt > 13
		cTxtTam := "5"
	EndIf


	If lClick .Or. (Type("cPrograma") == "C" .And. cPrograma == "MNTC125" .And. cCodPneu != cPneu125)
		//Se criado pelo clique, fica mais claro
		cTypeImg  := "CLARO" //NAO TRADUZIR
		cCorTxt   := "000000"
	Else
		cTypeImg  := "ESCURO" //NAO TRADUZIR
	EndIf
	cPneuNovo     := cDirImg+"NG_PNEU_PRETO_"+cTypeImg+"_"+cType+".png"
	cPneuVermelho := cDirImg+"NG_PNEU_VERMELHO_"+cTypeImg+"_"+cType+".png"
	cPneuVerde    := cDirImg+"NG_PNEU_VERDE_"+cTypeImg+"_"+cType+".png"
	cPneuAzul     := cDirImg+"NG_PNEU_AZUL_"+cTypeImg+"_"+cType+".png"
	cPneuLaranja  := cDirImg+"NG_PNEU_LARANJA_"+cTypeImg+"_"+cType+".png"
	cCalota       := cDirImg+"NG_CALOTA.PNG"

	If !lInvisible
		// Define a cor do Pneu
		If nVida == 1
			cPneu := cPneuNovo
		Elseif nVida == 2
			cPneu := cPneuVerde
		Elseif nVida == 3
			cPneu := cPneuAzul
		ElseIf nVida == 4
			cPneu := cPneuLaranja
		Elseif nVida == 5
			cPneu := cPneuVermelho
		Else
			// Busca qual é a Banda Atual do Pneu (a variável 'nVida' possui o valor numérico, mas pode ser que a banda seja "A", "B", etc., e isto em numérico é convertido para zero, o que não nos ajuda)
			If NGIFDBSEEK("TQS", cCodPneu, 1)
				If TQS->TQS_BANDAA >= "6"
					cPneu := cPneuVermelho
				EndIf
			EndIf
			RestArea(aAreaTQS)
		EndIf
		// Se ainda assim não for possível definir a cor do pneu, deixa como Novo
		If Empty(cPneu)
			cPneu := cPneuNovo
		EndIf
		If IsInCallStack("MNTA232") .Or. IsInCallStack("MNTA995")
			If ExistBlock("MNTA2211") // Verifica se existe o ponto de entrada
				cTmpPneu := ExecBlock("MNTA2211",.F.,.F.,{nVida,cTypeImg,cType}) // Passa informacoes da banda
				If ValType(cTmpPneu) == "C"
					cPneu := cTmpPneu
				EndIf
			EndIf
		EndIf
		// Recebe a Dica (tooltip)
		If !Empty(cCodPneu)
			If cTypeToolTip == "L"
				cToolTip := Trim(cCodPneu) + " - " + Trim(NGSEEK("TPS",cCodPneu,1,"TPS->TPS_NOME"))
			ElseIf cTypeToolTip == "B"
				cToolTip := Trim(cCodPneu) + " - " + Trim(NGSEEK("ST9",cCodPneu,1,"ST9->T9_NOME"))
			Else
				cToolTip := cTypeToolTip
			EndIf
		EndIf
	Else
		cCodPneu := ""
		cPneu    := ""
	EndIf

	//Array contendo nas primeiras posicoes variaveis padroes - (Id,Codigo, PosX, PosY, Tipo, {Texto}) e ultima posicao array Especifica do shape
	aAdd(aShape,{	Val(cImgId),; //CODIGO DO SHAPE
						cCodPneu,;    //DESCRICAO(CODIGO) DO PNEU ACIMA DA IMAGEM DO PNEU
						nImgX,;       //POSICAO X DO PNEU
						nImgY,;       //POSICAO Y DO PNEU
						cType,;
						{Val(cTxtId),nTxtX,nTxtY},; //ARRAY DO TEXTO
						aInfo,; //ARRAY COM INFORMACOES ADICIONAIS
						cToolTip,;
						lVisibleText,;
						{nVida,lEstepe,lInvisible}}; //ARRAY DA VIDA DO PNEU, SE ELE EH ESTEPE, SE ESTA INVISIVEL
					)
	//Pneu
	oPanel:addShape("id="+cImgId+";type=8;left="+Str(nImgX)+";top="+Str(nImgY)+";width="+cWidth+";height="+cHeight+";image-file="+lower(cPneu)+";tooltip="+cToolTip+";can-move=0;can-deform=0;can-mark=1;is-container=0")

	If lInvisible .And. lEstepe
		//Calota
		oPanel:addShape("id="+cTxtId+";type=8;left="+Str(nImgX+15)+";top="+Str(nImgY+15)+";width="+Str(Val(cWidth)/1.6)+";height="+Str(Val(cHeight)/1.6)+";image-file="+lower(cCalota)+";tooltip="+cToolTip+";can-move=0;can-deform=0;can-mark=1;is-container=0")
	Else
		//Texto
		oPanel:addShape("id="+cTxtId+";type=7;left="+Str(nTxtX)+";top="+Str(nTxtY)+";width=70;height=20;text="+If(lVisibleText,cCodPneu,"")+";font="+cTxtFont+","+cTxtTam+",1,0,1;pen-color=#"+cCorTxt+";pen-width=1;;tooltip="+cToolTip+";can-move=0;can-deform=0;can-mark=1;is-container=0")
	EndIf
Return

//---------------------------------------------------------------------
/*/{Protheus.doc} ValidPneu
Valida informacoes do pneu

@author Vitor Emanuel Batista
@since 14/07/2009

@return Sempre Verdadeiro.
/*/
//---------------------------------------------------------------------
Static Function ValidPneu(cLocali,cFamilia)
	If Empty(M->TQ1_TIPEIX) .Or. Empty(cLocali) .Or. Empty(cFamilia)
		Help(" ",1,"OBRIGAT",,Space(40),3)
		Return .f.
	EndIf
Return .t.

//---------------------------------------------------------------------
/*/{Protheus.doc} ImgPrevNext
Funcao para alterar estrutura para a proxima ou anterior

@param cAcao, Caracter, Ação desejada.
@param nLargura, Numérico, Tamanho da largura.
@param nAltura, Numérico, Tamanho da altura.

@author Vitor Emanuel Batista
@since 14/07/2009

@return lRet, Lógico, Retorna falso caso caia em alguma condição.
/*/
//---------------------------------------------------------------------
Static Function ImgPrevNext(cAcao,nLargura,nAltura)

	Local lRet       := .F.
	Local lValidStep := .T.

	// Valida Quantidade de Stepes
	lValidStep := MNT221STEPE()
	If !lValidStep
		Return .F.
	EndIf

	If Len( aEstruturas ) > 0
		If cAcao == 'NEXT'
			If nPosEstru >= Len(aEstruturas)
				nPosEstru := 1
			Else
				nPosEstru++
			EndIf
		Else
			If nPosEstru <= 1
				nPosEstru := Len(aEstruturas)
			Else
				nPosEstru--
			EndIf
		EndIf
		If Len(aEstruturas) >= nPosEstru
			lRet := CriaEstrutura()
		EndIf
	EndIf

Return lRet

//---------------------------------------------------------------------
/*/{Protheus.doc} MNTA221EIXO
Filtra estruturas de acordo com a quantidade de eixos

@author Vitor Emanuel Batista
@since 14/07/2009

@return Sempre verdadeiro.
/*/
//---------------------------------------------------------------------
Function MNTA221EIXO()
	Local aTempEstru

	If cPrograma != "MNTA221"
		Return .t.
	EndIf

	If ALTERA
		If M->TQ0_EIXOS != Len(aRodados)-1
			MsgStop(STR0016,STR0004) //"Não é possivel alterar a quantidade de Eixos após a inclusão."
			Return .f.
		EndIf
		Return .t.
	EndIf

	aTempEstru  := aClone(aEstruturas)
	aEstruturas := NGRETESTRU(,M->TQ0_EIXOS)

	If Len(aEstruturas) ==0
		ShowHelpDlg(STR0007,{STR0017},1,; //"Não existe estrutura para a quantidade de eixos informado."
							{STR0018},1)	 //"Informe outra quantidade de eixos."
		aEstruturas  := aClone(aTempEstru)
		Return .f.
	ElseIf Len(aEstruturas) ==1
		oBtnPrev:lActive := .f.
		oBtnNext:lActive := .f.
	Else
		oBtnPrev:lActive := .t.
		oBtnNext:lActive := .t.
	EndIf

	//Retorna aEstruturas e Valor da Qtd de eixos na memoria
	If M->TQ0_EIXOS != Len(aTempEstru[1][4]) .And. !Eval(oBtnNext:bAction)
		aEstruturas  := aClone(aTempEstru)
		Return .f.
	EndIf
Return .t.

//---------------------------------------------------------------------
/*/{Protheus.doc} MNT221STEPE
Valida estepe - coloca/retira da tela

@author Vitor Emanuel Batista
@since 14/07/2009

@return Sempre verdadeiro.
/*/
//---------------------------------------------------------------------
Function MNT221STEPE()
	Local nX, nIdPneu, nIdTxt
	Local nVida := 1

	If cPrograma != "MNTA221"
		Return .t.
	EndIf

	If Len(aRodados[1]) == 2 .And. M->TQ0_STEPES != "N"
		ShowHelpDlg(STR0007,	{STR0019},1,; //"Não é possível adicionar Stepes nesta estrutura."
									{STR0020},1)	 //"Altere este campos para 'N' ou altere a estrutura."
		Return .F.
	ElseIf M->TQ0_STEPES != "N" .And. Len(aRodados[1])-2 < Val(M->TQ0_STEPES)
		ShowHelpDlg(STR0007,	{STR0041 + cValToChar(Len(aRodados[1])- 2) + STR0042},1,; //"Não é possível incluir mais de " ##" Stepes nesta estrutura."
									{STR0043},1) //"Diminua a quantidade de Stepes."
		Return .F.
	EndIf

	For nX := 2 To Len(aRodados[1])-1
		cCodType := aRodados[1][nX][6]
		nPneuX := Val(aRodados[1][nX][1])
		nPneuY := Val(aRodados[1][nX][2])
		cCodLoc:= aRodados[1][nX][3]

		//Clicou na Imagem Pneu
		nShape := aSCAN(aShape,{|aArray| (aArray[__IMGX__] == nPneuX .And. aArray[__IMGY__] == nPneuY) .And. !aTail(aArray)[__INVISIBLE__]})
		If nShape > 0
			nIdPneu := aShape[nShape][__IDPNEU__]
			nIdTxt  := aShape[nShape][6][__IDTXT__]
			DeleteItem(@oTPanel,nIdPneu)
			DeleteItem(@oTPanel,nIdTxt)
		EndIf

		If M->TQ0_STEPES != "N" .And. Val(M->TQ0_STEPES) >= nX-1
			NGCriaPneu( oTPanel,;
							nPneuX,;
							nPneuY,;
							cCodType,;
							cCodLoc,;
							nVida,;
							.T.,; //estepe
							Empty(cCodLoc),; //clicado
							.f.,;
							aEstruturas[nPosEstru][5][1][nX-1],;
							"L")
		EndIf
	Next nX
Return .t.

//---------------------------------------------------------------------
/*/{Protheus.doc} RetId
Incrementa Id do Shape

@author Vitor Emanuel Batista
@since 14/07/2009

@return nAtuId, Numérico, Valor do id incrementado.
/*/
//---------------------------------------------------------------------
Static Function RetId()
	Local nAtuId := ++nId
	aAdd(aAllShape,{nAtuId})
Return AllTrim(Str(nAtuId))

//---------------------------------------------------------------------
/*/{Protheus.doc} NGRETESTRU
Retorna array contendo informacoes sobre as estruturas

@param cCodImg, Caracter, Codigo da imagem (aEstruturas[1][1]) para filtrar
@param nEixos, Numérico, Quantidade de eixos para filtrar

@obs Utilização nos fontes MNTA221/MNTA232.

@author Vitor Emanuel Batista
@since 14/07/2009

@return aEstruturas, Array, Retorna os valores da estrutura.
/*/
//---------------------------------------------------------------------
Function NGRETESTRU(cCodImg,nEixos)
	Local nX, nY, nZ
	Local cIniImg := "NG_ESTRUTURA_"
	Local cExtensao   := ".PNG"
	Local aRPOImg     := GetResArray(cIniImg+"*"+cExtensao)
	Local aEstruTemp  := {}
	Local aEstruturas := {}

	*********************************************************************************
	aAdd(aEstruTemp,{	"1",; //CODIGO DA IMAGEM DA ESTRUTURA   EX: NG_ESTRUTURA_1.PNG
							"353",; //TAMANHO X EM PIXEL
							"189",; //TAMANHO Y EM PIXEL
							{;	//PNEUS NA ESTRUTURA
								{; //PRIMEIRO EIXO
									{;
										"1",; //CODIGO DA IMAGEM DO PNEU   EX: NG_PNEU_PRETO_ESCURO_1.PNG
										"233",; //POSICAO X NA ESTRUTURA
										"006"; //POSICAO Y NA ESTRUTURA
									},;
									{;
										"1",; //CODIGO DA IMAGEM DO PNEU   EX: NG_PNEU_PRETO_ESCURO_1.PNG
										"233",; //POSICAO X NA ESTRUTURA
										"031"; //POSICAO Y NA ESTRUTURA
									},;
									{;
										"1",; //CODIGO DA IMAGEM DO PNEU   EX: NG_PNEU_PRETO_ESCURO_1.PNG
										"233",; //POSICAO X NA ESTRUTURA
										"136"; //POSICAO Y NA ESTRUTURA
									},;
									{;
										"1",; //CODIGO DA IMAGEM DO PNEU   EX: NG_PNEU_PRETO_ESCURO_1.PNG
										"233",; //POSICAO X NA ESTRUTURA
										"162"; //POSICAO Y NA ESTRUTURA
									};
								};
							},;
							{; //STEPES
								{;
									{;
										"2",; //CODIGO DA IMAGEM DO PNEU   EX: NG_PNEU_PRETO_ESCURO_1.PNG
										"125",; //POSICAO X NA ESTRUTURA
										"025"; //POSICAO Y NA ESTRUTURA
									},;
									{;
										"2",; //CODIGO DA IMAGEM DO PNEU   EX: NG_PNEU_PRETO_ESCURO_1.PNG
										"125",; //POSICAO X NA ESTRUTURA
										"095"; //POSICAO Y NA ESTRUTURA
									};
								};
							};
				};
		)


	*********************************************************************************
	aAdd(aEstruTemp,{	"2",; //CODIGO DA IMAGEM DA ESTRUTURA   EX: NG_ESTRUTURA_1.PNG
							"470",; //TAMANHO X EM PIXEL
							"196",; //TAMANHO Y EM PIXEL
							{;
								{;	//PRIMEIRO EIXO
									{;
										"1",; //CODIGO DA IMAGEM DO PNEU   EX: NG_PNEU_PRETO_ESCURO_1.PNG
										"240",; //POSICAO X NA ESTRUTURA
										"006"; //POSICAO Y NA ESTRUTURA
									},;
									{;
										"1",; //CODIGO DA IMAGEM DO PNEU   EX: NG_PNEU_PRETO_ESCURO_1.PNG
										"240",; //POSICAO X NA ESTRUTURA
										"031"; //POSICAO Y NA ESTRUTURA
									},;
									{;
										"1",; //CODIGO DA IMAGEM DO PNEU   EX: NG_PNEU_PRETO_ESCURO_1.PNG
										"240",; //POSICAO X NA ESTRUTURA
										"136"; //POSICAO Y NA ESTRUTURA
									},;
									{;
										"1",; //CODIGO DA IMAGEM DO PNEU   EX: NG_PNEU_PRETO_ESCURO_1.PNG
										"240",; //POSICAO X NA ESTRUTURA
										"161"; //POSICAO Y NA ESTRUTURA
									};
								},;
								{; //SEGUNDO EIXO
									{;
										"1",; //CODIGO DA IMAGEM DO PNEU   EX: NG_PNEU_PRETO_ESCURO_1.PNG
										"350",; //POSICAO X NA ESTRUTURA
										"006"; //POSICAO Y NA ESTRUTURA
									},;
									{;
										"1",; //CODIGO DA IMAGEM DO PNEU   EX: NG_PNEU_PRETO_ESCURO_1.PNG
										"350",; //POSICAO X NA ESTRUTURA
										"031"; //POSICAO Y NA ESTRUTURA
									},;
									{;
										"1",; //CODIGO DA IMAGEM DO PNEU   EX: NG_PNEU_PRETO_ESCURO_1.PNG
										"350",; //POSICAO X NA ESTRUTURA
										"136"; //POSICAO Y NA ESTRUTURA
									},;
									{;
										"1",; //CODIGO DA IMAGEM DO PNEU   EX: NG_PNEU_PRETO_ESCURO_1.PNG
										"350",; //POSICAO X NA ESTRUTURA
										"161"; //POSICAO Y NA ESTRUTURA
									};
								};
							},;
							{; //STEPES
								{;
									{;
										"2",; //CODIGO DA IMAGEM DO PNEU   EX: NG_PNEU_PRETO_ESCURO_1.PNG
										"125",; //POSICAO X NA ESTRUTURA
										"025"; //POSICAO Y NA ESTRUTURA
									},;
									{;
										"2",; //CODIGO DA IMAGEM DO PNEU   EX: NG_PNEU_PRETO_ESCURO_1.PNG
										"125",; //POSICAO X NA ESTRUTURA
										"095"; //POSICAO Y NA ESTRUTURA
									};
								};
							};
				};
		)
	*********************************************************************************
	aAdd(aEstruTemp,{	"3",; //CODIGO DA IMAGEM DA ESTRUTURA   EX: NG_ESTRUTURA_1.PNG
							"578",; //TAMANHO X EM PIXEL
							"196",; //TAMANHO Y EM PIXEL
							{;
								{;//PRIMEIRO EIXO
									{;
										"1",; //CODIGO DA IMAGEM DO PNEU   EX: NG_PNEU_PRETO_ESCURO_1.PNG
										"235",; //POSICAO X NA ESTRUTURA
										"006"; //POSICAO Y NA ESTRUTURA
									},;
									{;
										"1",; //CODIGO DA IMAGEM DO PNEU   EX: NG_PNEU_PRETO_ESCURO_1.PNG
										"235",; //POSICAO X NA ESTRUTURA
										"031"; //POSICAO Y NA ESTRUTURA
									},;
									{;
										"1",; //CODIGO DA IMAGEM DO PNEU   EX: NG_PNEU_PRETO_ESCURO_1.PNG
										"235",; //POSICAO X NA ESTRUTURA
										"136"; //POSICAO Y NA ESTRUTURA
									},;
									{;
										"1",; //CODIGO DA IMAGEM DO PNEU   EX: NG_PNEU_PRETO_ESCURO_1.PNG
										"235",; //POSICAO X NA ESTRUTURA
										"162"; //POSICAO Y NA ESTRUTURA
									};
								},;
								{; //SEGUNDO EIXO
									{;
										"1",; //CODIGO DA IMAGEM DO PNEU   EX: NG_PNEU_PRETO_ESCURO_1.PNG
										"345",; //POSICAO X NA ESTRUTURA
										"006"; //POSICAO Y NA ESTRUTURA
									},;
									{;
										"1",; //CODIGO DA IMAGEM DO PNEU   EX: NG_PNEU_PRETO_ESCURO_1.PNG
										"345",; //POSICAO X NA ESTRUTURA
										"031"; //POSICAO Y NA ESTRUTURA
									},;
									{;
										"1",; //CODIGO DA IMAGEM DO PNEU   EX: NG_PNEU_PRETO_ESCURO_1.PNG
										"345",; //POSICAO X NA ESTRUTURA
										"136"; //POSICAO Y NA ESTRUTURA
									},;
									{;
										"1",; //CODIGO DA IMAGEM DO PNEU   EX: NG_PNEU_PRETO_ESCURO_1.PNG
										"345",; //POSICAO X NA ESTRUTURA
										"162"; //POSICAO Y NA ESTRUTURA
									};
								},;
								{; //TERCEIRO EIXO
									{;
										"1",; //CODIGO DA IMAGEM DO PNEU   EX: NG_PNEU_PRETO_ESCURO_1.PNG
										"460",; //POSICAO X NA ESTRUTURA
										"006"; //POSICAO Y NA ESTRUTURA
									},;
									{;
										"1",; //CODIGO DA IMAGEM DO PNEU   EX: NG_PNEU_PRETO_ESCURO_1.PNG
										"460",; //POSICAO X NA ESTRUTURA
										"031"; //POSICAO Y NA ESTRUTURA
									},;
									{;
										"1",; //CODIGO DA IMAGEM DO PNEU   EX: NG_PNEU_PRETO_ESCURO_1.PNG
										"460",; //POSICAO X NA ESTRUTURA
										"136"; //POSICAO Y NA ESTRUTURA
									},;
									{;
										"1",; //CODIGO DA IMAGEM DO PNEU   EX: NG_PNEU_PRETO_ESCURO_1.PNG
										"460",; //POSICAO X NA ESTRUTURA
										"162"; //POSICAO Y NA ESTRUTURA
									};
								};
							},;
							{; //STEPES
								{;
									{;
										"2",; //CODIGO DA IMAGEM DO PNEU   EX: NG_PNEU_PRETO_ESCURO_1.PNG
										"125",; //POSICAO X NA ESTRUTURA
										"025"; //POSICAO Y NA ESTRUTURA
									},;
									{;
										"2",; //CODIGO DA IMAGEM DO PNEU   EX: NG_PNEU_PRETO_ESCURO_1.PNG
										"125",; //POSICAO X NA ESTRUTURA
										"095"; //POSICAO Y NA ESTRUTURA
									};
								};
							};
				};
		)
	*********************************************************************************
	aAdd(aEstruTemp,{	"4",; //CODIGO DA IMAGEM DA ESTRUTURA   EX: NG_ESTRUTURA_1.PNG
							"689",; //TAMANHO X EM PIXEL
							"196",; //TAMANHO Y EM PIXEL
							{;
								{; //PRIMEIRO EIXO
									{;
										"1",; //CODIGO DA IMAGEM DO PNEU   EX: NG_PNEU_PRETO_ESCURO_1.PNG
										"235",; //POSICAO X NA ESTRUTURA
										"006"; //POSICAO Y NA ESTRUTURA
									},;
									{;
										"1",; //CODIGO DA IMAGEM DO PNEU   EX: NG_PNEU_PRETO_ESCURO_1.PNG
										"235",; //POSICAO X NA ESTRUTURA
										"031"; //POSICAO Y NA ESTRUTURA
									},;
									{;
										"1",; //CODIGO DA IMAGEM DO PNEU   EX: NG_PNEU_PRETO_ESCURO_1.PNG
										"235",; //POSICAO X NA ESTRUTURA
										"136"; //POSICAO Y NA ESTRUTURA
									},;
									{;
										"1",; //CODIGO DA IMAGEM DO PNEU   EX: NG_PNEU_PRETO_ESCURO_1.PNG
										"235",; //POSICAO X NA ESTRUTURA
										"162"; //POSICAO Y NA ESTRUTURA
									};
								},;
								{;//SEGUNDO EIXO
									{;
										"1",; //CODIGO DA IMAGEM DO PNEU   EX: NG_PNEU_PRETO_ESCURO_1.PNG
										"345",; //POSICAO X NA ESTRUTURA
										"006"; //POSICAO Y NA ESTRUTURA
									},;
									{;
										"1",; //CODIGO DA IMAGEM DO PNEU   EX: NG_PNEU_PRETO_ESCURO_1.PNG
										"345",; //POSICAO X NA ESTRUTURA
										"031"; //POSICAO Y NA ESTRUTURA
									},;
									{;
										"1",; //CODIGO DA IMAGEM DO PNEU   EX: NG_PNEU_PRETO_ESCURO_1.PNG
										"345",; //POSICAO X NA ESTRUTURA
										"136"; //POSICAO Y NA ESTRUTURA
									},;
									{;
										"1",; //CODIGO DA IMAGEM DO PNEU   EX: NG_PNEU_PRETO_ESCURO_1.PNG
										"345",; //POSICAO X NA ESTRUTURA
										"162"; //POSICAO Y NA ESTRUTURA
									};
								},;
								{;//TERCEIRO EIXO
									{;
										"1",; //CODIGO DA IMAGEM DO PNEU   EX: NG_PNEU_PRETO_ESCURO_1.PNG
										"460",; //POSICAO X NA ESTRUTURA
										"006"; //POSICAO Y NA ESTRUTURA
									},;
									{;
										"1",; //CODIGO DA IMAGEM DO PNEU   EX: NG_PNEU_PRETO_ESCURO_1.PNG
										"460",; //POSICAO X NA ESTRUTURA
										"031"; //POSICAO Y NA ESTRUTURA
									},;
									{;
										"1",; //CODIGO DA IMAGEM DO PNEU   EX: NG_PNEU_PRETO_ESCURO_1.PNG
										"460",; //POSICAO X NA ESTRUTURA
										"136"; //POSICAO Y NA ESTRUTURA
									},;
									{;
										"1",; //CODIGO DA IMAGEM DO PNEU   EX: NG_PNEU_PRETO_ESCURO_1.PNG
										"460",; //POSICAO X NA ESTRUTURA
										"162"; //POSICAO Y NA ESTRUTURA
									};
								},;
								{; //QUARTO EIXO
									{;
										"1",; //CODIGO DA IMAGEM DO PNEU   EX: NG_PNEU_PRETO_ESCURO_1.PNG
										"570",; //POSICAO X NA ESTRUTURA
										"006"; //POSICAO Y NA ESTRUTURA
									},;
									{;
										"1",; //CODIGO DA IMAGEM DO PNEU   EX: NG_PNEU_PRETO_ESCURO_1.PNG
										"570",; //POSICAO X NA ESTRUTURA
										"031"; //POSICAO Y NA ESTRUTURA
									},;
									{;
										"1",; //CODIGO DA IMAGEM DO PNEU   EX: NG_PNEU_PRETO_ESCURO_1.PNG
										"570",; //POSICAO X NA ESTRUTURA
										"136"; //POSICAO Y NA ESTRUTURA
									},;
									{;
										"1",; //CODIGO DA IMAGEM DO PNEU   EX: NG_PNEU_PRETO_ESCURO_1.PNG
										"570",; //POSICAO X NA ESTRUTURA
										"162"; //POSICAO Y NA ESTRUTURA
									};
								};
							},;
							{; //STEPES
								{;
									{;
										"2",; //CODIGO DA IMAGEM DO PNEU   EX: NG_PNEU_PRETO_ESCURO_1.PNG
										"125",; //POSICAO X NA ESTRUTURA
										"025"; //POSICAO Y NA ESTRUTURA
									},;
									{;
										"2",; //CODIGO DA IMAGEM DO PNEU   EX: NG_PNEU_PRETO_ESCURO_1.PNG
										"125",; //POSICAO X NA ESTRUTURA
										"095"; //POSICAO Y NA ESTRUTURA
									},;
									{;
										"2",; //CODIGO DA IMAGEM DO PNEU   EX: NG_PNEU_PRETO_ESCURO_1.PNG
										"20",; //POSICAO X NA ESTRUTURA
										"025"; //POSICAO Y NA ESTRUTURA
									},;
									{;
										"2",; //CODIGO DA IMAGEM DO PNEU   EX: NG_PNEU_PRETO_ESCURO_1.PNG
										"20",; //POSICAO X NA ESTRUTURA
										"095"; //POSICAO Y NA ESTRUTURA
									};
								};
							};
				};
		)
	*********************************************************************************
	aAdd(aEstruTemp,{	"5",; //CODIGO DA IMAGEM DA ESTRUTURA   EX: NG_ESTRUTURA_1.PNG
							"471",; //TAMANHO X EM PIXEL
							"196",; //TAMANHO Y EM PIXEL
							{;
								{;//PRIMEIRO EIXO
									{;
										"1",; //CODIGO DA IMAGEM DO PNEU   EX: NG_PNEU_PRETO_ESCURO_1.PNG
										"240",; //POSICAO X NA ESTRUTURA
										"006"; //POSICAO Y NA ESTRUTURA
									},;
									{;
										"1",; //CODIGO DA IMAGEM DO PNEU   EX: NG_PNEU_PRETO_ESCURO_1.PNG
										"240",; //POSICAO X NA ESTRUTURA
										"160"; //POSICAO Y NA ESTRUTURA
									};
								},;
								{;//SEGUNDO EIXO
									{;
										"1",; //CODIGO DA IMAGEM DO PNEU   EX: NG_PNEU_PRETO_ESCURO_1.PNG
										"352",; //POSICAO X NA ESTRUTURA
										"006"; //POSICAO Y NA ESTRUTURA
									},;
									{;
										"1",; //CODIGO DA IMAGEM DO PNEU   EX: NG_PNEU_PRETO_ESCURO_1.PNG
										"352",; //POSICAO X NA ESTRUTURA
										"160"; //POSICAO Y NA ESTRUTURA
									};
								};
							},;
							{; //STEPES
								{;
									{;
										"2",; //CODIGO DA IMAGEM DO PNEU   EX: NG_PNEU_PRETO_ESCURO_1.PNG
										"125",; //POSICAO X NA ESTRUTURA
										"025"; //POSICAO Y NA ESTRUTURA
									},;
									{;
										"2",; //CODIGO DA IMAGEM DO PNEU   EX: NG_PNEU_PRETO_ESCURO_1.PNG
										"125",; //POSICAO X NA ESTRUTURA
										"095"; //POSICAO Y NA ESTRUTURA
									};
								};
							};
				};
		)
	*********************************************************************************
	aAdd(aEstruTemp,{	"6",; //CODIGO DA IMAGEM DA ESTRUTURA   EX: NG_ESTRUTURA_1.PNG
							"578",; //TAMANHO X EM PIXEL
							"196",; //TAMANHO Y EM PIXEL
							{;
								{; //PRIMEIRO EIXO
									{;
										"1",; //CODIGO DA IMAGEM DO PNEU   EX: NG_PNEU_PRETO_ESCURO_1.PNG
										"238",; //POSICAO X NA ESTRUTURA
										"006"; //POSICAO Y NA ESTRUTURA
									},;
									{;
										"1",; //CODIGO DA IMAGEM DO PNEU   EX: NG_PNEU_PRETO_ESCURO_1.PNG
										"238",; //POSICAO X NA ESTRUTURA
										"160"; //POSICAO Y NA ESTRUTURA
									};
								},;
								{;//SEGUNDO EIXO
									{;
										"1",; //CODIGO DA IMAGEM DO PNEU   EX: NG_PNEU_PRETO_ESCURO_1.PNG
										"350",; //POSICAO X NA ESTRUTURA
										"006"; //POSICAO Y NA ESTRUTURA
									},;
									{;
										"1",; //CODIGO DA IMAGEM DO PNEU   EX: NG_PNEU_PRETO_ESCURO_1.PNG
										"350",; //POSICAO X NA ESTRUTURA
										"160"; //POSICAO Y NA ESTRUTURA
									};
								},;
								{;//TERCEIRO EIXO
									{;
										"1",; //CODIGO DA IMAGEM DO PNEU   EX: NG_PNEU_PRETO_ESCURO_1.PNG
										"460",; //POSICAO X NA ESTRUTURA
										"006"; //POSICAO Y NA ESTRUTURA
									},;
									{;
										"1",; //CODIGO DA IMAGEM DO PNEU   EX: NG_PNEU_PRETO_ESCURO_1.PNG
										"460",; //POSICAO X NA ESTRUTURA
										"160"; //POSICAO Y NA ESTRUTURA
									};
								};
							},;
							{; //STEPES
								{;
									{;
										"2",; //CODIGO DA IMAGEM DO PNEU   EX: NG_PNEU_PRETO_ESCURO_1.PNG
										"125",; //POSICAO X NA ESTRUTURA
										"025"; //POSICAO Y NA ESTRUTURA
									},;
									{;
										"2",; //CODIGO DA IMAGEM DO PNEU   EX: NG_PNEU_PRETO_ESCURO_1.PNG
										"125",; //POSICAO X NA ESTRUTURA
										"095"; //POSICAO Y NA ESTRUTURA
									};
								};
							};
				};
		)
	*********************************************************************************
	aAdd(aEstruTemp,{	"7",; //CODIGO DA IMAGEM DA ESTRUTURA   EX: NG_ESTRUTURA_1.PNG
							"367",; //TAMANHO X EM PIXEL
							"196",; //TAMANHO Y EM PIXEL
							{;
								{; //PRIMEIRO EIXO
									{;
										"1",; //CODIGO DA IMAGEM DO PNEU   EX: NG_PNEU_PRETO_ESCURO_1.PNG
										"030",; //POSICAO X NA ESTRUTURA
										"010",; //POSICAO Y NA ESTRUTURA
									},;
									{;
										"1",; //CODIGO DA IMAGEM DO PNEU   EX: NG_PNEU_PRETO_ESCURO_1.PNG
										"030",; //POSICAO X NA ESTRUTURA
										"160"; //POSICAO Y NA ESTRUTURA
									};
								},;
								{; //SEGUNDO EIXO
									{;
										"1",; //CODIGO DA IMAGEM DO PNEU   EX: NG_PNEU_PRETO_ESCURO_1.PNG
										"265",; //POSICAO X NA ESTRUTURA
										"010",; //POSICAO Y NA ESTRUTURA
									},;
									{;
										"1",; //CODIGO DA IMAGEM DO PNEU   EX: NG_PNEU_PRETO_ESCURO_1.PNG
										"265",; //POSICAO X NA ESTRUTURA
										"160",; //POSICAO Y NA ESTRUTURA
									};
								};
							},;
							{; //STEPES
								{;
									{;
										"2",; //CODIGO DA IMAGEM DO PNEU   EX: NG_PNEU_PRETO_ESCURO_1.PNG
										"155",; //POSICAO X NA ESTRUTURA
										"025"; //POSICAO Y NA ESTRUTURA
									},;
									{;
										"2",; //CODIGO DA IMAGEM DO PNEU   EX: NG_PNEU_PRETO_ESCURO_1.PNG
										"155",; //POSICAO X NA ESTRUTURA
										"095"; //POSICAO Y NA ESTRUTURA
									};
								};
							};
						};
		)
	*********************************************************************************
	aAdd(aEstruTemp,{	"8",; //CODIGO DA IMAGEM DA ESTRUTURA   EX: NG_ESTRUTURA_1.PNG
							"484",; //TAMANHO X EM PIXEL
							"196",; //TAMANHO Y EM PIXEL
							{;
								{; //PRIMEIRO EIXO
									{;
										"1",; //CODIGO DA IMAGEM DO PNEU   EX: NG_PNEU_PRETO_ESCURO_1.PNG
										"068",; //POSICAO X NA ESTRUTURA
										"010"; //POSICAO Y NA ESTRUTURA
									},;
									{;
										"1",; //CODIGO DA IMAGEM DO PNEU   EX: NG_PNEU_PRETO_ESCURO_1.PNG
										"068",; //POSICAO X NA ESTRUTURA
										"158"; //POSICAO Y NA ESTRUTURA
									};
								},;
								{; //SEGUNDO EIXO
									{;
										"1",; //CODIGO DA IMAGEM DO PNEU   EX: NG_PNEU_PRETO_ESCURO_1.PNG
										"359",; //POSICAO X NA ESTRUTURA
										"004"; //POSICAO Y NA ESTRUTURA
									},;
									{;
										"1",; //CODIGO DA IMAGEM DO PNEU   EX: NG_PNEU_PRETO_ESCURO_1.PNG
										"359",; //POSICAO X NA ESTRUTURA
										"030"; //POSICAO Y NA ESTRUTURA
									},;
									{;
										"1",; //CODIGO DA IMAGEM DO PNEU   EX: NG_PNEU_PRETO_ESCURO_1.PNG
										"359",; //POSICAO X NA ESTRUTURA
										"133"; //POSICAO Y NA ESTRUTURA
									},;
									{;
										"1",; //CODIGO DA IMAGEM DO PNEU   EX: NG_PNEU_PRETO_ESCURO_1.PNG
										"359",; //POSICAO X NA ESTRUTURA
										"160"; //POSICAO Y NA ESTRUTURA
									};
								};
							},;
							{; //STEPES
								{;
									{;
										"2",; //CODIGO DA IMAGEM DO PNEU   EX: NG_PNEU_PRETO_ESCURO_1.PNG
										"250",; //POSICAO X NA ESTRUTURA
										"025"; //POSICAO Y NA ESTRUTURA
									},;
									{;
										"2",; //CODIGO DA IMAGEM DO PNEU   EX: NG_PNEU_PRETO_ESCURO_1.PNG
										"250",; //POSICAO X NA ESTRUTURA
										"095"; //POSICAO Y NA ESTRUTURA
									};
								};
							};
						};
		)
	*********************************************************************************
	aAdd(aEstruTemp,{	"9",; //CODIGO DA IMAGEM DA ESTRUTURA   EX: NG_ESTRUTURA_1.PNG
							"602",; //TAMANHO X EM PIXEL
							"196",; //TAMANHO Y EM PIXEL
							{;
								{;
									{;
										"1",; //CODIGO DA IMAGEM DO PNEU   EX: NG_PNEU_PRETO_ESCURO_1.PNG
										"068",; //POSICAO X NA ESTRUTURA
										"011"; //POSICAO Y NA ESTRUTURA
									},;
									{;
										"1",; //CODIGO DA IMAGEM DO PNEU   EX: NG_PNEU_PRETO_ESCURO_1.PNG
										"068",; //POSICAO X NA ESTRUTURA
										"156"; //POSICAO Y NA ESTRUTURA
									};
								},;
								{; //SEGUNDO EIXO
									{;
										"1",; //CODIGO DA IMAGEM DO PNEU   EX: NG_PNEU_PRETO_ESCURO_1.PNG
										"359",; //POSICAO X NA ESTRUTURA
										"002"; //POSICAO Y NA ESTRUTURA
									},;
									{;
										"1",; //CODIGO DA IMAGEM DO PNEU   EX: NG_PNEU_PRETO_ESCURO_1.PNG
										"359",; //POSICAO X NA ESTRUTURA
										"029"; //POSICAO Y NA ESTRUTURA
									},;
									{;
										"1",; //CODIGO DA IMAGEM DO PNEU   EX: NG_PNEU_PRETO_ESCURO_1.PNG
										"359",; //POSICAO X NA ESTRUTURA
										"133"; //POSICAO Y NA ESTRUTURA
									},;
									{;
										"1",; //CODIGO DA IMAGEM DO PNEU   EX: NG_PNEU_PRETO_ESCURO_1.PNG
										"359",; //POSICAO X NA ESTRUTURA
										"158"; //POSICAO Y NA ESTRUTURA
									};
								},;
								{; //TERCEIRO EIXO
									{;
										"1",; //CODIGO DA IMAGEM DO PNEU   EX: NG_PNEU_PRETO_ESCURO_1.PNG
										"478",; //POSICAO X NA ESTRUTURA
										"002"; //POSICAO Y NA ESTRUTURA
									},;
									{;
										"1",; //CODIGO DA IMAGEM DO PNEU   EX: NG_PNEU_PRETO_ESCURO_1.PNG
										"478",; //POSICAO X NA ESTRUTURA
										"029"; //POSICAO Y NA ESTRUTURA
									},;
									{;
										"1",; //CODIGO DA IMAGEM DO PNEU   EX: NG_PNEU_PRETO_ESCURO_1.PNG
										"478",; //POSICAO X NA ESTRUTURA
										"133"; //POSICAO Y NA ESTRUTURA
									},;
									{;
										"1",; //CODIGO DA IMAGEM DO PNEU   EX: NG_PNEU_PRETO_ESCURO_1.PNG
										"478",; //POSICAO X NA ESTRUTURA
										"158"; //POSICAO Y NA ESTRUTURA
									};
								};
							},;
							{; //STEPES
								{;
									{;
										"2",; //CODIGO DA IMAGEM DO PNEU   EX: NG_PNEU_PRETO_ESCURO_1.PNG
										"250",; //POSICAO X NA ESTRUTURA
										"025"; //POSICAO Y NA ESTRUTURA
									},;
									{;
										"2",; //CODIGO DA IMAGEM DO PNEU   EX: NG_PNEU_PRETO_ESCURO_1.PNG
										"250",; //POSICAO X NA ESTRUTURA
										"095"; //POSICAO Y NA ESTRUTURA
									};
								};
							};
						};
		)
	*********************************************************************************
	aAdd(aEstruTemp,{	"10",; //CODIGO DA IMAGEM DA ESTRUTURA   EX: NG_ESTRUTURA_1.PNG
							"367",; //TAMANHO X EM PIXEL
							"196",; //TAMANHO Y EM PIXEL
							{;
								{; //PRIMEIRO EIXO
									{;
										"1",; //CODIGO DA IMAGEM DO PNEU   EX: NG_PNEU_PRETO_ESCURO_1.PNG
										"135",; //POSICAO X NA ESTRUTURA
										"002"; //POSICAO Y NA ESTRUTURA
									},;
									{;
										"1",; //CODIGO DA IMAGEM DO PNEU   EX: NG_PNEU_PRETO_ESCURO_1.PNG
										"135",; //POSICAO X NA ESTRUTURA
										"028"; //POSICAO Y NA ESTRUTURA
									},;
									{;
										"1",; //CODIGO DA IMAGEM DO PNEU   EX: NG_PNEU_PRETO_ESCURO_1.PNG
										"135",; //POSICAO X NA ESTRUTURA
										"130"; //POSICAO Y NA ESTRUTURA
									},;
									{;
										"1",; //CODIGO DA IMAGEM DO PNEU   EX: NG_PNEU_PRETO_ESCURO_1.PNG
										"135",; //POSICAO X NA ESTRUTURA
										"156"; //POSICAO Y NA ESTRUTURA
									};
								},;
								{; //SEGUNDO EIXO
									{;
										"1",; //CODIGO DA IMAGEM DO PNEU   EX: NG_PNEU_PRETO_ESCURO_1.PNG
										"247",; //POSICAO X NA ESTRUTURA
										"002"; //POSICAO Y NA ESTRUTURA
									},;
									{;
										"1",; //CODIGO DA IMAGEM DO PNEU   EX: NG_PNEU_PRETO_ESCURO_1.PNG
										"247",; //POSICAO X NA ESTRUTURA
										"028"; //POSICAO Y NA ESTRUTURA
									},;
									{;
										"1",; //CODIGO DA IMAGEM DO PNEU   EX: NG_PNEU_PRETO_ESCURO_1.PNG
										"247",; //POSICAO X NA ESTRUTURA
										"130"; //POSICAO Y NA ESTRUTURA
									},;
									{;
										"1",; //CODIGO DA IMAGEM DO PNEU   EX: NG_PNEU_PRETO_ESCURO_1.PNG
										"247",; //POSICAO X NA ESTRUTURA
										"156"; //POSICAO Y NA ESTRUTURA
									};
								};
							},;
							{; //STEPES
								{;
									{;
										"2",; //CODIGO DA IMAGEM DO PNEU   EX: NG_PNEU_PRETO_ESCURO_1.PNG
										"025",; //POSICAO X NA ESTRUTURA
										"025"; //POSICAO Y NA ESTRUTURA
									},;
									{;
										"2",; //CODIGO DA IMAGEM DO PNEU   EX: NG_PNEU_PRETO_ESCURO_1.PNG
										"025",; //POSICAO X NA ESTRUTURA
										"095"; //POSICAO Y NA ESTRUTURA
									};
								};
							};
						};
		)

	*********************************************************************************
	aAdd(aEstruTemp,{	"11",; //CODIGO DA IMAGEM DA ESTRUTURA   EX: NG_ESTRUTURA_1.PNG
							"720",; //TAMANHO X EM PIXEL
							"196",; //TAMANHO Y EM PIXEL
							{;
								{; //PRIMEIRO EIXO
									{;
										"1",; //CODIGO DA IMAGEM DO PNEU   EX: NG_PNEU_PRETO_ESCURO_1.PNG
										"068",; //POSICAO X NA ESTRUTURA
										"010"; //POSICAO Y NA ESTRUTURA
									},;
									{;
										"1",; //CODIGO DA IMAGEM DO PNEU   EX: NG_PNEU_PRETO_ESCURO_1.PNG
										"068",; //POSICAO X NA ESTRUTURA
										"158"; //POSICAO Y NA ESTRUTURA
									};
								},;
								{; //SEGUNDO EIXO
									{;
										"1",; //CODIGO DA IMAGEM DO PNEU   EX: NG_PNEU_PRETO_ESCURO_1.PNG
										"359",; //POSICAO X NA ESTRUTURA
										"004"; //POSICAO Y NA ESTRUTURA
									},;
									{;
										"1",; //CODIGO DA IMAGEM DO PNEU   EX: NG_PNEU_PRETO_ESCURO_1.PNG
										"359",; //POSICAO X NA ESTRUTURA
										"030"; //POSICAO Y NA ESTRUTURA
									},;
									{;
										"1",; //CODIGO DA IMAGEM DO PNEU   EX: NG_PNEU_PRETO_ESCURO_1.PNG
										"359",; //POSICAO X NA ESTRUTURA
										"133"; //POSICAO Y NA ESTRUTURA
									},;
									{;
										"1",; //CODIGO DA IMAGEM DO PNEU   EX: NG_PNEU_PRETO_ESCURO_1.PNG
										"359",; //POSICAO X NA ESTRUTURA
										"160"; //POSICAO Y NA ESTRUTURA
									};
								},;
								{; //TERCEIRO EIXO
									{;
										"1",; //CODIGO DA IMAGEM DO PNEU   EX: NG_PNEU_PRETO_ESCURO_1.PNG
										"477",; //POSICAO X NA ESTRUTURA
										"004"; //POSICAO Y NA ESTRUTURA
									},;
									{;
										"1",; //CODIGO DA IMAGEM DO PNEU   EX: NG_PNEU_PRETO_ESCURO_1.PNG
										"477",; //POSICAO X NA ESTRUTURA
										"030"; //POSICAO Y NA ESTRUTURA
									},;
									{;
										"1",; //CODIGO DA IMAGEM DO PNEU   EX: NG_PNEU_PRETO_ESCURO_1.PNG
										"477",; //POSICAO X NA ESTRUTURA
										"133"; //POSICAO Y NA ESTRUTURA
									},;
									{;
										"1",; //CODIGO DA IMAGEM DO PNEU   EX: NG_PNEU_PRETO_ESCURO_1.PNG
										"477",; //POSICAO X NA ESTRUTURA
										"160"; //POSICAO Y NA ESTRUTURA
									};
								},;
								{; //QUARTO EIXO
									{;
										"1",; //CODIGO DA IMAGEM DO PNEU   EX: NG_PNEU_PRETO_ESCURO_1.PNG
										"595",; //POSICAO X NA ESTRUTURA
										"004"; //POSICAO Y NA ESTRUTURA
									},;
									{;
										"1",; //CODIGO DA IMAGEM DO PNEU   EX: NG_PNEU_PRETO_ESCURO_1.PNG
										"595",; //POSICAO X NA ESTRUTURA
										"030"; //POSICAO Y NA ESTRUTURA
									},;
									{;
										"1",; //CODIGO DA IMAGEM DO PNEU   EX: NG_PNEU_PRETO_ESCURO_1.PNG
										"595",; //POSICAO X NA ESTRUTURA
										"133"; //POSICAO Y NA ESTRUTURA
									},;
									{;
										"1",; //CODIGO DA IMAGEM DO PNEU   EX: NG_PNEU_PRETO_ESCURO_1.PNG
										"595",; //POSICAO X NA ESTRUTURA
										"160"; //POSICAO Y NA ESTRUTURA
									};
								};
							},;
							{; //STEPES
								{;
									{;
										"2",; //CODIGO DA IMAGEM DO PNEU   EX: NG_PNEU_PRETO_ESCURO_1.PNG
										"250",; //POSICAO X NA ESTRUTURA
										"025"; //POSICAO Y NA ESTRUTURA
									},;
									{;
										"2",; //CODIGO DA IMAGEM DO PNEU   EX: NG_PNEU_PRETO_ESCURO_1.PNG
										"250",; //POSICAO X NA ESTRUTURA
										"095"; //POSICAO Y NA ESTRUTURA
									};
								};
							};
						};
		)

	*********************************************************************************
	aAdd(aEstruTemp,{	"12",; //CODIGO DA IMAGEM DA ESTRUTURA   EX: NG_ESTRUTURA_1.PNG
							"296",; //TAMANHO X EM PIXEL
							"196",; //TAMANHO Y EM PIXEL
							{;
								{;	//PRIMEIRO EIXO
									{;
										"1",; //CODIGO DA IMAGEM DO PNEU   EX: NG_PNEU_PRETO_ESCURO_1.PNG
										"066",; //POSICAO X NA ESTRUTURA
										"006"; //POSICAO Y NA ESTRUTURA
									},;
									{;
										"1",; //CODIGO DA IMAGEM DO PNEU   EX: NG_PNEU_PRETO_ESCURO_1.PNG
										"066",; //POSICAO X NA ESTRUTURA
										"031"; //POSICAO Y NA ESTRUTURA
									},;
									{;
										"1",; //CODIGO DA IMAGEM DO PNEU   EX: NG_PNEU_PRETO_ESCURO_1.PNG
										"066",; //POSICAO X NA ESTRUTURA
										"136"; //POSICAO Y NA ESTRUTURA
									},;
									{;
										"1",; //CODIGO DA IMAGEM DO PNEU   EX: NG_PNEU_PRETO_ESCURO_1.PNG
										"066",; //POSICAO X NA ESTRUTURA
										"161"; //POSICAO Y NA ESTRUTURA
									};
								},;
								{; //SEGUNDO EIXO
									{;
										"1",; //CODIGO DA IMAGEM DO PNEU   EX: NG_PNEU_PRETO_ESCURO_1.PNG
										"178",; //POSICAO X NA ESTRUTURA
										"006"; //POSICAO Y NA ESTRUTURA
									},;
									{;
										"1",; //CODIGO DA IMAGEM DO PNEU   EX: NG_PNEU_PRETO_ESCURO_1.PNG
										"178",; //POSICAO X NA ESTRUTURA
										"031"; //POSICAO Y NA ESTRUTURA
									},;
									{;
										"1",; //CODIGO DA IMAGEM DO PNEU   EX: NG_PNEU_PRETO_ESCURO_1.PNG
										"178",; //POSICAO X NA ESTRUTURA
										"136"; //POSICAO Y NA ESTRUTURA
									},;
									{;
										"1",; //CODIGO DA IMAGEM DO PNEU   EX: NG_PNEU_PRETO_ESCURO_1.PNG
										"178",; //POSICAO X NA ESTRUTURA
										"161"; //POSICAO Y NA ESTRUTURA
									};
								};
							},;
							{; //STEPES
								{;
									{;
										"2",; //CODIGO DA IMAGEM DO PNEU   EX: NG_PNEU_PRETO_ESCURO_1.PNG
										"068",; //POSICAO X NA ESTRUTURA
										"058"; //POSICAO Y NA ESTRUTURA
									},;
									{;
										"2",; //CODIGO DA IMAGEM DO PNEU   EX: NG_PNEU_PRETO_ESCURO_1.PNG
										"178",; //POSICAO X NA ESTRUTURA
										"058"; //POSICAO Y NA ESTRUTURA
									};
								};
							};
				};
		)

	*********************************************************************************
	aAdd(aEstruTemp,{	"13",; //CODIGO DA IMAGEM DA ESTRUTURA   EX: NG_ESTRUTURA_1.PNG
							"545",; //TAMANHO X EM PIXEL
							"196",; //TAMANHO Y EM PIXEL
							{;
								{; //PRIMEIRO EIXO
									{;
										"1",; //CODIGO DA IMAGEM DO PNEU   EX: NG_PNEU_PRETO_ESCURO_1.PNG
										"030",; //POSICAO X NA ESTRUTURA
										"010",; //POSICAO Y NA ESTRUTURA
									},;
									{;
										"1",; //CODIGO DA IMAGEM DO PNEU   EX: NG_PNEU_PRETO_ESCURO_1.PNG
										"030",; //POSICAO X NA ESTRUTURA
										"156"; //POSICAO Y NA ESTRUTURA
									};
								},;
								{;//SEGUNDO EIXO
									{;
										"1",; //CODIGO DA IMAGEM DO PNEU   EX: NG_PNEU_PRETO_ESCURO_1.PNG
										"215",; //POSICAO X NA ESTRUTURA
										"004"; //POSICAO Y NA ESTRUTURA
									},;
									{;
										"1",; //CODIGO DA IMAGEM DO PNEU   EX: NG_PNEU_PRETO_ESCURO_1.PNG
										"215",; //POSICAO X NA ESTRUTURA
										"160"; //POSICAO Y NA ESTRUTURA
									};
								},;
								{;//TERCEIRO EIXO
									{;
										"1",; //CODIGO DA IMAGEM DO PNEU   EX: NG_PNEU_PRETO_ESCURO_1.PNG
										"326",; //POSICAO X NA ESTRUTURA
										"004"; //POSICAO Y NA ESTRUTURA
									},;
									{;
										"1",; //CODIGO DA IMAGEM DO PNEU   EX: NG_PNEU_PRETO_ESCURO_1.PNG
										"326",; //POSICAO X NA ESTRUTURA
										"160"; //POSICAO Y NA ESTRUTURA
									};
								};
							},;
							{; //STEPES
								{;
									{;
										"2",; //CODIGO DA IMAGEM DO PNEU   EX: NG_PNEU_PRETO_ESCURO_1.PNG
										"125",; //POSICAO X NA ESTRUTURA
										"025"; //POSICAO Y NA ESTRUTURA
									},;
									{;
										"2",; //CODIGO DA IMAGEM DO PNEU   EX: NG_PNEU_PRETO_ESCURO_1.PNG
										"125",; //POSICAO X NA ESTRUTURA
										"095"; //POSICAO Y NA ESTRUTURA
									};
								};
							};
				};
		)

	*********************************************************************************
	aAdd(aEstruTemp,{	"14",; //CODIGO DA IMAGEM DA ESTRUTURA   EX: NG_ESTRUTURA_1.PNG
							"649",; //TAMANHO X EM PIXEL
							"196",; //TAMANHO Y EM PIXEL
							{;
								{; //PRIMEIRO EIXO
									{;
										"1",; //CODIGO DA IMAGEM DO PNEU   EX: NG_PNEU_PRETO_ESCURO_1.PNG
										"028",; //POSICAO X NA ESTRUTURA
										"011"; //POSICAO Y NA ESTRUTURA
									},;
									{;
										"1",; //CODIGO DA IMAGEM DO PNEU   EX: NG_PNEU_PRETO_ESCURO_1.PNG
										"028",; //POSICAO X NA ESTRUTURA
										"156"; //POSICAO Y NA ESTRUTURA
									};
								},;
								{; //SEGUNDO EIXO
									{;
										"1",; //CODIGO DA IMAGEM DO PNEU   EX: NG_PNEU_PRETO_ESCURO_1.PNG
										"136",; //POSICAO X NA ESTRUTURA
										"011"; //POSICAO Y NA ESTRUTURA
									},;
									{;
										"1",; //CODIGO DA IMAGEM DO PNEU   EX: NG_PNEU_PRETO_ESCURO_1.PNG
										"136",; //POSICAO X NA ESTRUTURA
										"156"; //POSICAO Y NA ESTRUTURA
									};
								},;
								{; //TERCEIRO EIXO
									{;
										"1",; //CODIGO DA IMAGEM DO PNEU   EX: NG_PNEU_PRETO_ESCURO_1.PNG
										"319",; //POSICAO X NA ESTRUTURA
										"004"; //POSICAO Y NA ESTRUTURA
									},;
									{;
										"1",; //CODIGO DA IMAGEM DO PNEU   EX: NG_PNEU_PRETO_ESCURO_1.PNG
										"319",; //POSICAO X NA ESTRUTURA
										"029"; //POSICAO Y NA ESTRUTURA
									},;
									{;
										"1",; //CODIGO DA IMAGEM DO PNEU   EX: NG_PNEU_PRETO_ESCURO_1.PNG
										"319",; //POSICAO X NA ESTRUTURA
										"135"; //POSICAO Y NA ESTRUTURA
									},;
									{;
										"1",; //CODIGO DA IMAGEM DO PNEU   EX: NG_PNEU_PRETO_ESCURO_1.PNG
										"319",; //POSICAO X NA ESTRUTURA
										"160"; //POSICAO Y NA ESTRUTURA
									};
								},;
								{; //QUARTO EIXO
									{;
										"1",; //CODIGO DA IMAGEM DO PNEU   EX: NG_PNEU_PRETO_ESCURO_1.PNG
										"435",; //POSICAO X NA ESTRUTURA
										"004"; //POSICAO Y NA ESTRUTURA
									},;
									{;
										"1",; //CODIGO DA IMAGEM DO PNEU   EX: NG_PNEU_PRETO_ESCURO_1.PNG
										"435",; //POSICAO X NA ESTRUTURA
										"029"; //POSICAO Y NA ESTRUTURA
									},;
									{;
										"1",; //CODIGO DA IMAGEM DO PNEU   EX: NG_PNEU_PRETO_ESCURO_1.PNG
										"435",; //POSICAO X NA ESTRUTURA
										"135"; //POSICAO Y NA ESTRUTURA
									},;
									{;
										"1",; //CODIGO DA IMAGEM DO PNEU   EX: NG_PNEU_PRETO_ESCURO_1.PNG
										"435",; //POSICAO X NA ESTRUTURA
										"160"; //POSICAO Y NA ESTRUTURA
									};
								};
							},;
							{; //STEPES
								{;
									{;
										"2",; //CODIGO DA IMAGEM DO PNEU   EX: NG_PNEU_PRETO_ESCURO_1.PNG
										"545",; //POSICAO X NA ESTRUTURA
										"025"; //POSICAO Y NA ESTRUTURA
									},;
									{;
										"2",; //CODIGO DA IMAGEM DO PNEU   EX: NG_PNEU_PRETO_ESCURO_1.PNG
										"545",; //POSICAO X NA ESTRUTURA
										"095"; //POSICAO Y NA ESTRUTURA
									};
								};
							};
						};
		)

	*********************************************************************************
	aAdd(aEstruTemp,{	"15",; //CODIGO DA IMAGEM DA ESTRUTURA   EX: NG_ESTRUTURA_1.PNG
							"600",; //TAMANHO X EM PIXEL
							"196",; //TAMANHO Y EM PIXEL
							{;
								{; //PRIMEIRO EIXO
									{;
										"1",; //CODIGO DA IMAGEM DO PNEU   EX: NG_PNEU_PRETO_ESCURO_1.PNG
										"068",; //POSICAO X NA ESTRUTURA
										"010"; //POSICAO Y NA ESTRUTURA
									},;
									{;
										"1",; //CODIGO DA IMAGEM DO PNEU   EX: NG_PNEU_PRETO_ESCURO_1.PNG
										"068",; //POSICAO X NA ESTRUTURA
										"157"; //POSICAO Y NA ESTRUTURA
									};
								},;
								{; //SEGUNDO EIXO
									{;
										"1",; //CODIGO DA IMAGEM DO PNEU   EX: NG_PNEU_PRETO_ESCURO_1.PNG
										"359",; //POSICAO X NA ESTRUTURA
										"004"; //POSICAO Y NA ESTRUTURA
									},;
									{;
										"1",; //CODIGO DA IMAGEM DO PNEU   EX: NG_PNEU_PRETO_ESCURO_1.PNG
										"359",; //POSICAO X NA ESTRUTURA
										"030"; //POSICAO Y NA ESTRUTURA
									},;
									{;
										"1",; //CODIGO DA IMAGEM DO PNEU   EX: NG_PNEU_PRETO_ESCURO_1.PNG
										"359",; //POSICAO X NA ESTRUTURA
										"133"; //POSICAO Y NA ESTRUTURA
									},;
									{;
										"1",; //CODIGO DA IMAGEM DO PNEU   EX: NG_PNEU_PRETO_ESCURO_1.PNG
										"359",; //POSICAO X NA ESTRUTURA
										"159"; //POSICAO Y NA ESTRUTURA
									};
								},;
								{; //TERCEIRO EIXO
									{;
										"1",; //CODIGO DA IMAGEM DO PNEU   EX: NG_PNEU_PRETO_ESCURO_1.PNG
										"476",; //POSICAO X NA ESTRUTURA
										"004"; //POSICAO Y NA ESTRUTURA
									},;
									{;
										"1",; //CODIGO DA IMAGEM DO PNEU   EX: NG_PNEU_PRETO_ESCURO_1.PNG
										"476",; //POSICAO X NA ESTRUTURA
										"159"; //POSICAO Y NA ESTRUTURA
									};
								};
							},;
							{; //STEPES
								{;
									{;
										"2",; //CODIGO DA IMAGEM DO PNEU   EX: NG_PNEU_PRETO_ESCURO_1.PNG
										"250",; //POSICAO X NA ESTRUTURA
										"025"; //POSICAO Y NA ESTRUTURA
									},;
									{;
										"2",; //CODIGO DA IMAGEM DO PNEU   EX: NG_PNEU_PRETO_ESCURO_1.PNG
										"250",; //POSICAO X NA ESTRUTURA
										"095"; //POSICAO Y NA ESTRUTURA
									};
								};
							};
						};
		)

	*********************************************************************************
	aAdd(aEstruTemp,{	"16",; //CODIGO DA IMAGEM DA ESTRUTURA   EX: NG_ESTRUTURA_1.PNG
							"542",; //TAMANHO X EM PIXEL
							"196",; //TAMANHO Y EM PIXEL
							{;
								{; //PRIMEIRO EIXO
									{;
										"1",; //CODIGO DA IMAGEM DO PNEU   EX: NG_PNEU_PRETO_ESCURO_1.PNG
										"028",; //POSICAO X NA ESTRUTURA
										"011"; //POSICAO Y NA ESTRUTURA
									},;
									{;
										"1",; //CODIGO DA IMAGEM DO PNEU   EX: NG_PNEU_PRETO_ESCURO_1.PNG
										"028",; //POSICAO X NA ESTRUTURA
										"156"; //POSICAO Y NA ESTRUTURA
									};
								},;
								{; //SEGUNDO EIXO
									{;
										"1",; //CODIGO DA IMAGEM DO PNEU   EX: NG_PNEU_PRETO_ESCURO_1.PNG
										"136",; //POSICAO X NA ESTRUTURA
										"011"; //POSICAO Y NA ESTRUTURA
									},;
									{;
										"1",; //CODIGO DA IMAGEM DO PNEU   EX: NG_PNEU_PRETO_ESCURO_1.PNG
										"136",; //POSICAO X NA ESTRUTURA
										"156"; //POSICAO Y NA ESTRUTURA
									};
								},;
								{; //TERCEIRO EIXO
									{;
										"1",; //CODIGO DA IMAGEM DO PNEU   EX: NG_PNEU_PRETO_ESCURO_1.PNG
										"323",; //POSICAO X NA ESTRUTURA
										"004"; //POSICAO Y NA ESTRUTURA
									},;
									{;
										"1",; //CODIGO DA IMAGEM DO PNEU   EX: NG_PNEU_PRETO_ESCURO_1.PNG
										"323",; //POSICAO X NA ESTRUTURA
										"160"; //POSICAO Y NA ESTRUTURA
									};
								},;
								{; //QUARTO EIXO
									{;
										"1",; //CODIGO DA IMAGEM DO PNEU   EX: NG_PNEU_PRETO_ESCURO_1.PNG
										"435",; //POSICAO X NA ESTRUTURA
										"004"; //POSICAO Y NA ESTRUTURA
									},;
									{;
										"1",; //CODIGO DA IMAGEM DO PNEU   EX: NG_PNEU_PRETO_ESCURO_1.PNG
										"435",; //POSICAO X NA ESTRUTURA
										"029"; //POSICAO Y NA ESTRUTURA
									},;
									{;
										"1",; //CODIGO DA IMAGEM DO PNEU   EX: NG_PNEU_PRETO_ESCURO_1.PNG
										"435",; //POSICAO X NA ESTRUTURA
										"135"; //POSICAO Y NA ESTRUTURA
									},;
									{;
										"1",; //CODIGO DA IMAGEM DO PNEU   EX: NG_PNEU_PRETO_ESCURO_1.PNG
										"435",; //POSICAO X NA ESTRUTURA
										"160"; //POSICAO Y NA ESTRUTURA
									};
								};
							},;
							{; //STEPES
								{;
									{;
										"2",; //CODIGO DA IMAGEM DO PNEU   EX: NG_PNEU_PRETO_ESCURO_1.PNG
										"230",; //POSICAO X NA ESTRUTURA
										"025"; //POSICAO Y NA ESTRUTURA
									},;
									{;
										"2",; //CODIGO DA IMAGEM DO PNEU   EX: NG_PNEU_PRETO_ESCURO_1.PNG
										"230",; //POSICAO X NA ESTRUTURA
										"095"; //POSICAO Y NA ESTRUTURA
									};
								};
							};
						};
		)

	*********************************************************************************
	aAdd(aEstruTemp,{	"17",; //CODIGO DA IMAGEM DA ESTRUTURA   EX: NG_ESTRUTURA_1.PNG
							"354",; //TAMANHO X EM PIXEL
							"196",; //TAMANHO Y EM PIXEL
							{;	//PNEUS NA ESTRUTURA
								{; //PRIMEIRO EIXO
									{;
										"1",; //CODIGO DA IMAGEM DO PNEU   EX: NG_PNEU_PRETO_ESCURO_1.PNG
										"235",; //POSICAO X NA ESTRUTURA
										"006"; //POSICAO Y NA ESTRUTURA
									},;
									{;
										"1",; //CODIGO DA IMAGEM DO PNEU   EX: NG_PNEU_PRETO_ESCURO_1.PNG
										"235",; //POSICAO X NA ESTRUTURA
										"162"; //POSICAO Y NA ESTRUTURA
									};
								};
							},;
							{; //STEPES
								{;
									{;
										"2",; //CODIGO DA IMAGEM DO PNEU   EX: NG_PNEU_PRETO_ESCURO_1.PNG
										"125",; //POSICAO X NA ESTRUTURA
										"025"; //POSICAO Y NA ESTRUTURA
									},;
									{;
										"2",; //CODIGO DA IMAGEM DO PNEU   EX: NG_PNEU_PRETO_ESCURO_1.PNG
										"125",; //POSICAO X NA ESTRUTURA
										"095"; //POSICAO Y NA ESTRUTURA
									};
								};
							};
				};
		)

	*********************************************************************************
	aAdd(aEstruTemp,{	"18",; //CODIGO DA IMAGEM DA ESTRUTURA   EX: NG_ESTRUTURA_1.PNG
							"390",; //TAMANHO X EM PIXEL
							"196",; //TAMANHO Y EM PIXEL
							{;
								{;	//PRIMEIRO EIXO
									{;
										"1",; //CODIGO DA IMAGEM DO PNEU   EX: NG_PNEU_PRETO_ESCURO_1.PNG
										"066",; //POSICAO X NA ESTRUTURA
										"006"; //POSICAO Y NA ESTRUTURA
									},;
									{;
										"1",; //CODIGO DA IMAGEM DO PNEU   EX: NG_PNEU_PRETO_ESCURO_1.PNG
										"066",; //POSICAO X NA ESTRUTURA
										"031"; //POSICAO Y NA ESTRUTURA
									},;
									{;
										"1",; //CODIGO DA IMAGEM DO PNEU   EX: NG_PNEU_PRETO_ESCURO_1.PNG
										"066",; //POSICAO X NA ESTRUTURA
										"136"; //POSICAO Y NA ESTRUTURA
									},;
									{;
										"1",; //CODIGO DA IMAGEM DO PNEU   EX: NG_PNEU_PRETO_ESCURO_1.PNG
										"066",; //POSICAO X NA ESTRUTURA
										"161"; //POSICAO Y NA ESTRUTURA
									};
								},;
								{; //SEGUNDO EIXO
									{;
										"1",; //CODIGO DA IMAGEM DO PNEU   EX: NG_PNEU_PRETO_ESCURO_1.PNG
										"274",; //POSICAO X NA ESTRUTURA
										"006"; //POSICAO Y NA ESTRUTURA
									},;
									{;
										"1",; //CODIGO DA IMAGEM DO PNEU   EX: NG_PNEU_PRETO_ESCURO_1.PNG
										"274",; //POSICAO X NA ESTRUTURA
										"031"; //POSICAO Y NA ESTRUTURA
									},;
									{;
										"1",; //CODIGO DA IMAGEM DO PNEU   EX: NG_PNEU_PRETO_ESCURO_1.PNG
										"274",; //POSICAO X NA ESTRUTURA
										"136"; //POSICAO Y NA ESTRUTURA
									},;
									{;
										"1",; //CODIGO DA IMAGEM DO PNEU   EX: NG_PNEU_PRETO_ESCURO_1.PNG
										"274",; //POSICAO X NA ESTRUTURA
										"161"; //POSICAO Y NA ESTRUTURA
									};
								};
							},;
							{; //STEPES
								{;
									{;
										"2",; //CODIGO DA IMAGEM DO PNEU   EX: NG_PNEU_PRETO_ESCURO_1.PNG
										"170",; //POSICAO X NA ESTRUTURA
										"025"; //POSICAO Y NA ESTRUTURA
									},;
									{;
										"2",; //CODIGO DA IMAGEM DO PNEU   EX: NG_PNEU_PRETO_ESCURO_1.PNG
										"170",; //POSICAO X NA ESTRUTURA
										"095"; //POSICAO Y NA ESTRUTURA
									};
								};
							};
				};
		)

	*********************************************************************************
	aAdd(aEstruTemp,{	"19",; //CODIGO DA IMAGEM DA ESTRUTURA   EX: NG_ESTRUTURA_1.PNG
							"508",; //TAMANHO X EM PIXEL
							"196",; //TAMANHO Y EM PIXEL
							{;
								{;	//PRIMEIRO EIXO
									{;
										"1",; //CODIGO DA IMAGEM DO PNEU   EX: NG_PNEU_PRETO_ESCURO_1.PNG
										"063",; //POSICAO X NA ESTRUTURA
										"006"; //POSICAO Y NA ESTRUTURA
									},;
									{;
										"1",; //CODIGO DA IMAGEM DO PNEU   EX: NG_PNEU_PRETO_ESCURO_1.PNG
										"063",; //POSICAO X NA ESTRUTURA
										"031"; //POSICAO Y NA ESTRUTURA
									},;
									{;
										"1",; //CODIGO DA IMAGEM DO PNEU   EX: NG_PNEU_PRETO_ESCURO_1.PNG
										"063",; //POSICAO X NA ESTRUTURA
										"136"; //POSICAO Y NA ESTRUTURA
									},;
									{;
										"1",; //CODIGO DA IMAGEM DO PNEU   EX: NG_PNEU_PRETO_ESCURO_1.PNG
										"063",; //POSICAO X NA ESTRUTURA
										"161"; //POSICAO Y NA ESTRUTURA
									};
								},;
								{; //SEGUNDO EIXO
									{;
										"1",; //CODIGO DA IMAGEM DO PNEU   EX: NG_PNEU_PRETO_ESCURO_1.PNG
										"276",; //POSICAO X NA ESTRUTURA
										"006"; //POSICAO Y NA ESTRUTURA
									},;
									{;
										"1",; //CODIGO DA IMAGEM DO PNEU   EX: NG_PNEU_PRETO_ESCURO_1.PNG
										"278",; //POSICAO X NA ESTRUTURA
										"031"; //POSICAO Y NA ESTRUTURA
									},;
									{;
										"1",; //CODIGO DA IMAGEM DO PNEU   EX: NG_PNEU_PRETO_ESCURO_1.PNG
										"278",; //POSICAO X NA ESTRUTURA
										"136"; //POSICAO Y NA ESTRUTURA
									},;
									{;
										"1",; //CODIGO DA IMAGEM DO PNEU   EX: NG_PNEU_PRETO_ESCURO_1.PNG
										"278",; //POSICAO X NA ESTRUTURA
										"161"; //POSICAO Y NA ESTRUTURA
									};
								},;
								{; //TERCEIRO EIXO
									{;
										"1",; //CODIGO DA IMAGEM DO PNEU   EX: NG_PNEU_PRETO_ESCURO_1.PNG
										"391",; //POSICAO X NA ESTRUTURA
										"006"; //POSICAO Y NA ESTRUTURA
									},;
									{;
										"1",; //CODIGO DA IMAGEM DO PNEU   EX: NG_PNEU_PRETO_ESCURO_1.PNG
										"391",; //POSICAO X NA ESTRUTURA
										"031"; //POSICAO Y NA ESTRUTURA
									},;
									{;
										"1",; //CODIGO DA IMAGEM DO PNEU   EX: NG_PNEU_PRETO_ESCURO_1.PNG
										"391",; //POSICAO X NA ESTRUTURA
										"136"; //POSICAO Y NA ESTRUTURA
									},;
									{;
										"1",; //CODIGO DA IMAGEM DO PNEU   EX: NG_PNEU_PRETO_ESCURO_1.PNG
										"391",; //POSICAO X NA ESTRUTURA
										"161"; //POSICAO Y NA ESTRUTURA
									};
								};
							},;
							{; //STEPES
								{;
									{;
										"2",; //CODIGO DA IMAGEM DO PNEU   EX: NG_PNEU_PRETO_ESCURO_1.PNG
										"170",; //POSICAO X NA ESTRUTURA
										"025"; //POSICAO Y NA ESTRUTURA
									},;
									{;
										"2",; //CODIGO DA IMAGEM DO PNEU   EX: NG_PNEU_PRETO_ESCURO_1.PNG
										"170",; //POSICAO X NA ESTRUTURA
										"095"; //POSICAO Y NA ESTRUTURA
									};
								};
							};
				};
		)


	*********************************************************************************
	aAdd(aEstruTemp,{	"20",; //CODIGO DA IMAGEM DA ESTRUTURA   EX: NG_ESTRUTURA_1.PNG
							"511",; //TAMANHO X EM PIXEL
							"288",; //TAMANHO Y EM PIXEL
							{;
								{;	//PRIMEIRO EIXO
									{;
										"1",; //CODIGO DA IMAGEM DO PNEU   EX: NG_PNEU_PRETO_ESCURO_1.PNG
										"064",; //POSICAO X NA ESTRUTURA
										"006"; //POSICAO Y NA ESTRUTURA
									},;
									{;
										"1",; //CODIGO DA IMAGEM DO PNEU   EX: NG_PNEU_PRETO_ESCURO_1.PNG
										"064",; //POSICAO X NA ESTRUTURA
										"032"; //POSICAO Y NA ESTRUTURA
									},;
									{;
										"1",; //CODIGO DA IMAGEM DO PNEU   EX: NG_PNEU_PRETO_ESCURO_1.PNG
										"064",; //POSICAO X NA ESTRUTURA
										"081"; //POSICAO Y NA ESTRUTURA
									},;
									{;
										"1",; //CODIGO DA IMAGEM DO PNEU   EX: NG_PNEU_PRETO_ESCURO_1.PNG
										"064",; //POSICAO X NA ESTRUTURA
										"107"; //POSICAO Y NA ESTRUTURA
									},;
									{;
										"1",; //CODIGO DA IMAGEM DO PNEU   EX: NG_PNEU_PRETO_ESCURO_1.PNG
										"064",; //POSICAO X NA ESTRUTURA
										"152"; //POSICAO Y NA ESTRUTURA
									},;
									{;
										"1",; //CODIGO DA IMAGEM DO PNEU   EX: NG_PNEU_PRETO_ESCURO_1.PNG
										"064",; //POSICAO X NA ESTRUTURA
										"178"; //POSICAO Y NA ESTRUTURA
									},;
									{;
										"1",; //CODIGO DA IMAGEM DO PNEU   EX: NG_PNEU_PRETO_ESCURO_1.PNG
										"064",; //POSICAO X NA ESTRUTURA
										"227"; //POSICAO Y NA ESTRUTURA
									},;
									{;
										"1",; //CODIGO DA IMAGEM DO PNEU   EX: NG_PNEU_PRETO_ESCURO_1.PNG
										"064",; //POSICAO X NA ESTRUTURA
										"253"; //POSICAO Y NA ESTRUTURA
									};
								},;
								{; //SEGUNDO EIXO
									{;
										"1",; //CODIGO DA IMAGEM DO PNEU   EX: NG_PNEU_PRETO_ESCURO_1.PNG
										"165",; //POSICAO X NA ESTRUTURA
										"006"; //POSICAO Y NA ESTRUTURA
									},;
									{;
										"1",; //CODIGO DA IMAGEM DO PNEU   EX: NG_PNEU_PRETO_ESCURO_1.PNG
										"165",; //POSICAO X NA ESTRUTURA
										"032"; //POSICAO Y NA ESTRUTURA
									},;
									{;
										"1",; //CODIGO DA IMAGEM DO PNEU   EX: NG_PNEU_PRETO_ESCURO_1.PNG
										"165",; //POSICAO X NA ESTRUTURA
										"081"; //POSICAO Y NA ESTRUTURA
									},;
									{;
										"1",; //CODIGO DA IMAGEM DO PNEU   EX: NG_PNEU_PRETO_ESCURO_1.PNG
										"165",; //POSICAO X NA ESTRUTURA
										"107"; //POSICAO Y NA ESTRUTURA
									},;
									{;
										"1",; //CODIGO DA IMAGEM DO PNEU   EX: NG_PNEU_PRETO_ESCURO_1.PNG
										"165",; //POSICAO X NA ESTRUTURA
										"152"; //POSICAO Y NA ESTRUTURA
									},;
									{;
										"1",; //CODIGO DA IMAGEM DO PNEU   EX: NG_PNEU_PRETO_ESCURO_1.PNG
										"165",; //POSICAO X NA ESTRUTURA
										"178"; //POSICAO Y NA ESTRUTURA
									},;
									{;
										"1",; //CODIGO DA IMAGEM DO PNEU   EX: NG_PNEU_PRETO_ESCURO_1.PNG
										"165",; //POSICAO X NA ESTRUTURA
										"227"; //POSICAO Y NA ESTRUTURA
									},;
									{;
										"1",; //CODIGO DA IMAGEM DO PNEU   EX: NG_PNEU_PRETO_ESCURO_1.PNG
										"165",; //POSICAO X NA ESTRUTURA
										"253"; //POSICAO Y NA ESTRUTURA
									};
								},;
								{; //TERCEIRO EIXO
									{;
										"1",; //CODIGO DA IMAGEM DO PNEU   EX: NG_PNEU_PRETO_ESCURO_1.PNG
										"265",; //POSICAO X NA ESTRUTURA
										"006"; //POSICAO Y NA ESTRUTURA
									},;
									{;
										"1",; //CODIGO DA IMAGEM DO PNEU   EX: NG_PNEU_PRETO_ESCURO_1.PNG
										"265",; //POSICAO X NA ESTRUTURA
										"032"; //POSICAO Y NA ESTRUTURA
									},;
									{;
										"1",; //CODIGO DA IMAGEM DO PNEU   EX: NG_PNEU_PRETO_ESCURO_1.PNG
										"265",; //POSICAO X NA ESTRUTURA
										"081"; //POSICAO Y NA ESTRUTURA
									},;
									{;
										"1",; //CODIGO DA IMAGEM DO PNEU   EX: NG_PNEU_PRETO_ESCURO_1.PNG
										"265",; //POSICAO X NA ESTRUTURA
										"107"; //POSICAO Y NA ESTRUTURA
									},;
									{;
										"1",; //CODIGO DA IMAGEM DO PNEU   EX: NG_PNEU_PRETO_ESCURO_1.PNG
										"265",; //POSICAO X NA ESTRUTURA
										"152"; //POSICAO Y NA ESTRUTURA
									},;
									{;
										"1",; //CODIGO DA IMAGEM DO PNEU   EX: NG_PNEU_PRETO_ESCURO_1.PNG
										"265",; //POSICAO X NA ESTRUTURA
										"178"; //POSICAO Y NA ESTRUTURA
									},;
									{;
										"1",; //CODIGO DA IMAGEM DO PNEU   EX: NG_PNEU_PRETO_ESCURO_1.PNG
										"265",; //POSICAO X NA ESTRUTURA
										"227"; //POSICAO Y NA ESTRUTURA
									},;
									{;
										"1",; //CODIGO DA IMAGEM DO PNEU   EX: NG_PNEU_PRETO_ESCURO_1.PNG
										"265",; //POSICAO X NA ESTRUTURA
										"253"; //POSICAO Y NA ESTRUTURA
									};
								},;
								{; //QUARTO EIXO
									{;
										"1",; //CODIGO DA IMAGEM DO PNEU   EX: NG_PNEU_PRETO_ESCURO_1.PNG
										"365",; //POSICAO X NA ESTRUTURA
										"006"; //POSICAO Y NA ESTRUTURA
									},;
									{;
										"1",; //CODIGO DA IMAGEM DO PNEU   EX: NG_PNEU_PRETO_ESCURO_1.PNG
										"365",; //POSICAO X NA ESTRUTURA
										"032"; //POSICAO Y NA ESTRUTURA
									},;
									{;
										"1",; //CODIGO DA IMAGEM DO PNEU   EX: NG_PNEU_PRETO_ESCURO_1.PNG
										"365",; //POSICAO X NA ESTRUTURA
										"081"; //POSICAO Y NA ESTRUTURA
									},;
									{;
										"1",; //CODIGO DA IMAGEM DO PNEU   EX: NG_PNEU_PRETO_ESCURO_1.PNG
										"365",; //POSICAO X NA ESTRUTURA
										"107"; //POSICAO Y NA ESTRUTURA
									},;
									{;
										"1",; //CODIGO DA IMAGEM DO PNEU   EX: NG_PNEU_PRETO_ESCURO_1.PNG
										"365",; //POSICAO X NA ESTRUTURA
										"152"; //POSICAO Y NA ESTRUTURA
									},;
									{;
										"1",; //CODIGO DA IMAGEM DO PNEU   EX: NG_PNEU_PRETO_ESCURO_1.PNG
										"365",; //POSICAO X NA ESTRUTURA
										"178"; //POSICAO Y NA ESTRUTURA
									},;
									{;
										"1",; //CODIGO DA IMAGEM DO PNEU   EX: NG_PNEU_PRETO_ESCURO_1.PNG
										"365",; //POSICAO X NA ESTRUTURA
										"227"; //POSICAO Y NA ESTRUTURA
									},;
									{;
										"1",; //CODIGO DA IMAGEM DO PNEU   EX: NG_PNEU_PRETO_ESCURO_1.PNG
										"365",; //POSICAO X NA ESTRUTURA
										"253"; //POSICAO Y NA ESTRUTURA
									};
								};
							},;
							{; //STEPES
								{;
								};
							};
				};
		)

	*********************************************************************************
	aAdd(aEstruTemp,{	"21",; //CODIGO DA IMAGEM DA ESTRUTURA   EX: NG_ESTRUTURA_1.PNG
							"910",; //TAMANHO X EM PIXEL
							"305",; //TAMANHO Y EM PIXEL
							{;
								{;	//PRIMEIRO EIXO
									{;
										"1",; //CODIGO DA IMAGEM DO PNEU   EX: NG_PNEU_PRETO_ESCURO_1.PNG
										"064",; //POSICAO X NA ESTRUTURA
										"014"; //POSICAO Y NA ESTRUTURA
									},;
									{;
										"1",; //CODIGO DA IMAGEM DO PNEU   EX: NG_PNEU_PRETO_ESCURO_1.PNG
										"064",; //POSICAO X NA ESTRUTURA
										"040"; //POSICAO Y NA ESTRUTURA
									},;
									{;
										"1",; //CODIGO DA IMAGEM DO PNEU   EX: NG_PNEU_PRETO_ESCURO_1.PNG
										"064",; //POSICAO X NA ESTRUTURA
										"089"; //POSICAO Y NA ESTRUTURA
									},;
									{;
										"1",; //CODIGO DA IMAGEM DO PNEU   EX: NG_PNEU_PRETO_ESCURO_1.PNG
										"064",; //POSICAO X NA ESTRUTURA
										"116"; //POSICAO Y NA ESTRUTURA
									},;
									{;
										"1",; //CODIGO DA IMAGEM DO PNEU   EX: NG_PNEU_PRETO_ESCURO_1.PNG
										"064",; //POSICAO X NA ESTRUTURA
										"160"; //POSICAO Y NA ESTRUTURA
									},;
									{;
										"1",; //CODIGO DA IMAGEM DO PNEU   EX: NG_PNEU_PRETO_ESCURO_1.PNG
										"064",; //POSICAO X NA ESTRUTURA
										"187"; //POSICAO Y NA ESTRUTURA
									},;
									{;
										"1",; //CODIGO DA IMAGEM DO PNEU   EX: NG_PNEU_PRETO_ESCURO_1.PNG
										"064",; //POSICAO X NA ESTRUTURA
										"235"; //POSICAO Y NA ESTRUTURA
									},;
									{;
										"1",; //CODIGO DA IMAGEM DO PNEU   EX: NG_PNEU_PRETO_ESCURO_1.PNG
										"064",; //POSICAO X NA ESTRUTURA
										"262"; //POSICAO Y NA ESTRUTURA
									};
								},;
								{; //SEGUNDO EIXO
									{;
										"1",; //CODIGO DA IMAGEM DO PNEU   EX: NG_PNEU_PRETO_ESCURO_1.PNG
										"165",; //POSICAO X NA ESTRUTURA
										"014"; //POSICAO Y NA ESTRUTURA
									},;
									{;
										"1",; //CODIGO DA IMAGEM DO PNEU   EX: NG_PNEU_PRETO_ESCURO_1.PNG
										"165",; //POSICAO X NA ESTRUTURA
										"040"; //POSICAO Y NA ESTRUTURA
									},;
									{;
										"1",; //CODIGO DA IMAGEM DO PNEU   EX: NG_PNEU_PRETO_ESCURO_1.PNG
										"165",; //POSICAO X NA ESTRUTURA
										"089"; //POSICAO Y NA ESTRUTURA
									},;
									{;
										"1",; //CODIGO DA IMAGEM DO PNEU   EX: NG_PNEU_PRETO_ESCURO_1.PNG
										"165",; //POSICAO X NA ESTRUTURA
										"116"; //POSICAO Y NA ESTRUTURA
									},;
									{;
										"1",; //CODIGO DA IMAGEM DO PNEU   EX: NG_PNEU_PRETO_ESCURO_1.PNG
										"165",; //POSICAO X NA ESTRUTURA
										"160"; //POSICAO Y NA ESTRUTURA
									},;
									{;
										"1",; //CODIGO DA IMAGEM DO PNEU   EX: NG_PNEU_PRETO_ESCURO_1.PNG
										"165",; //POSICAO X NA ESTRUTURA
										"187"; //POSICAO Y NA ESTRUTURA
									},;
									{;
										"1",; //CODIGO DA IMAGEM DO PNEU   EX: NG_PNEU_PRETO_ESCURO_1.PNG
										"165",; //POSICAO X NA ESTRUTURA
										"235"; //POSICAO Y NA ESTRUTURA
									},;
									{;
										"1",; //CODIGO DA IMAGEM DO PNEU   EX: NG_PNEU_PRETO_ESCURO_1.PNG
										"165",; //POSICAO X NA ESTRUTURA
										"262"; //POSICAO Y NA ESTRUTURA
									};
								},;
								{; //TERCEIRO EIXO
									{;
										"1",; //CODIGO DA IMAGEM DO PNEU   EX: NG_PNEU_PRETO_ESCURO_1.PNG
										"265",; //POSICAO X NA ESTRUTURA
										"014"; //POSICAO Y NA ESTRUTURA
									},;
									{;
										"1",; //CODIGO DA IMAGEM DO PNEU   EX: NG_PNEU_PRETO_ESCURO_1.PNG
										"265",; //POSICAO X NA ESTRUTURA
										"040"; //POSICAO Y NA ESTRUTURA
									},;
									{;
										"1",; //CODIGO DA IMAGEM DO PNEU   EX: NG_PNEU_PRETO_ESCURO_1.PNG
										"265",; //POSICAO X NA ESTRUTURA
										"089"; //POSICAO Y NA ESTRUTURA
									},;
									{;
										"1",; //CODIGO DA IMAGEM DO PNEU   EX: NG_PNEU_PRETO_ESCURO_1.PNG
										"265",; //POSICAO X NA ESTRUTURA
										"116"; //POSICAO Y NA ESTRUTURA
									},;
									{;
										"1",; //CODIGO DA IMAGEM DO PNEU   EX: NG_PNEU_PRETO_ESCURO_1.PNG
										"265",; //POSICAO X NA ESTRUTURA
										"160"; //POSICAO Y NA ESTRUTURA
									},;
									{;
										"1",; //CODIGO DA IMAGEM DO PNEU   EX: NG_PNEU_PRETO_ESCURO_1.PNG
										"265",; //POSICAO X NA ESTRUTURA
										"187"; //POSICAO Y NA ESTRUTURA
									},;
									{;
										"1",; //CODIGO DA IMAGEM DO PNEU   EX: NG_PNEU_PRETO_ESCURO_1.PNG
										"265",; //POSICAO X NA ESTRUTURA
										"235"; //POSICAO Y NA ESTRUTURA
									},;
									{;
										"1",; //CODIGO DA IMAGEM DO PNEU   EX: NG_PNEU_PRETO_ESCURO_1.PNG
										"265",; //POSICAO X NA ESTRUTURA
										"262"; //POSICAO Y NA ESTRUTURA
									};
								},;
								{; //QUARTO EIXO
									{;
										"1",; //CODIGO DA IMAGEM DO PNEU   EX: NG_PNEU_PRETO_ESCURO_1.PNG
										"365",; //POSICAO X NA ESTRUTURA
										"014"; //POSICAO Y NA ESTRUTURA
									},;
									{;
										"1",; //CODIGO DA IMAGEM DO PNEU   EX: NG_PNEU_PRETO_ESCURO_1.PNG
										"365",; //POSICAO X NA ESTRUTURA
										"040"; //POSICAO Y NA ESTRUTURA
									},;
									{;
										"1",; //CODIGO DA IMAGEM DO PNEU   EX: NG_PNEU_PRETO_ESCURO_1.PNG
										"365",; //POSICAO X NA ESTRUTURA
										"089"; //POSICAO Y NA ESTRUTURA
									},;
									{;
										"1",; //CODIGO DA IMAGEM DO PNEU   EX: NG_PNEU_PRETO_ESCURO_1.PNG
										"365",; //POSICAO X NA ESTRUTURA
										"116"; //POSICAO Y NA ESTRUTURA
									},;
									{;
										"1",; //CODIGO DA IMAGEM DO PNEU   EX: NG_PNEU_PRETO_ESCURO_1.PNG
										"365",; //POSICAO X NA ESTRUTURA
										"160"; //POSICAO Y NA ESTRUTURA
									},;
									{;
										"1",; //CODIGO DA IMAGEM DO PNEU   EX: NG_PNEU_PRETO_ESCURO_1.PNG
										"365",; //POSICAO X NA ESTRUTURA
										"187"; //POSICAO Y NA ESTRUTURA
									},;
									{;
										"1",; //CODIGO DA IMAGEM DO PNEU   EX: NG_PNEU_PRETO_ESCURO_1.PNG
										"365",; //POSICAO X NA ESTRUTURA
										"235"; //POSICAO Y NA ESTRUTURA
									},;
									{;
										"1",; //CODIGO DA IMAGEM DO PNEU   EX: NG_PNEU_PRETO_ESCURO_1.PNG
										"365",; //POSICAO X NA ESTRUTURA
										"262"; //POSICAO Y NA ESTRUTURA
									};
								},;
								{; //QUINTO EIXO
									{;
										"1",; //CODIGO DA IMAGEM DO PNEU   EX: NG_PNEU_PRETO_ESCURO_1.PNG
										"465",; //POSICAO X NA ESTRUTURA
										"014"; //POSICAO Y NA ESTRUTURA
									},;
									{;
										"1",; //CODIGO DA IMAGEM DO PNEU   EX: NG_PNEU_PRETO_ESCURO_1.PNG
										"465",; //POSICAO X NA ESTRUTURA
										"040"; //POSICAO Y NA ESTRUTURA
									},;
									{;
										"1",; //CODIGO DA IMAGEM DO PNEU   EX: NG_PNEU_PRETO_ESCURO_1.PNG
										"465",; //POSICAO X NA ESTRUTURA
										"089"; //POSICAO Y NA ESTRUTURA
									},;
									{;
										"1",; //CODIGO DA IMAGEM DO PNEU   EX: NG_PNEU_PRETO_ESCURO_1.PNG
										"465",; //POSICAO X NA ESTRUTURA
										"116"; //POSICAO Y NA ESTRUTURA
									},;
									{;
										"1",; //CODIGO DA IMAGEM DO PNEU   EX: NG_PNEU_PRETO_ESCURO_1.PNG
										"465",; //POSICAO X NA ESTRUTURA
										"160"; //POSICAO Y NA ESTRUTURA
									},;
									{;
										"1",; //CODIGO DA IMAGEM DO PNEU   EX: NG_PNEU_PRETO_ESCURO_1.PNG
										"465",; //POSICAO X NA ESTRUTURA
										"187"; //POSICAO Y NA ESTRUTURA
									},;
									{;
										"1",; //CODIGO DA IMAGEM DO PNEU   EX: NG_PNEU_PRETO_ESCURO_1.PNG
										"465",; //POSICAO X NA ESTRUTURA
										"235"; //POSICAO Y NA ESTRUTURA
									},;
									{;
										"1",; //CODIGO DA IMAGEM DO PNEU   EX: NG_PNEU_PRETO_ESCURO_1.PNG
										"465",; //POSICAO X NA ESTRUTURA
										"262"; //POSICAO Y NA ESTRUTURA
									};
								},;
								{; //SEXTO EIXO
									{;
										"1",; //CODIGO DA IMAGEM DO PNEU   EX: NG_PNEU_PRETO_ESCURO_1.PNG
										"565",; //POSICAO X NA ESTRUTURA
										"014"; //POSICAO Y NA ESTRUTURA
									},;
									{;
										"1",; //CODIGO DA IMAGEM DO PNEU   EX: NG_PNEU_PRETO_ESCURO_1.PNG
										"565",; //POSICAO X NA ESTRUTURA
										"040"; //POSICAO Y NA ESTRUTURA
									},;
									{;
										"1",; //CODIGO DA IMAGEM DO PNEU   EX: NG_PNEU_PRETO_ESCURO_1.PNG
										"565",; //POSICAO X NA ESTRUTURA
										"089"; //POSICAO Y NA ESTRUTURA
									},;
									{;
										"1",; //CODIGO DA IMAGEM DO PNEU   EX: NG_PNEU_PRETO_ESCURO_1.PNG
										"565",; //POSICAO X NA ESTRUTURA
										"116"; //POSICAO Y NA ESTRUTURA
									},;
									{;
										"1",; //CODIGO DA IMAGEM DO PNEU   EX: NG_PNEU_PRETO_ESCURO_1.PNG
										"565",; //POSICAO X NA ESTRUTURA
										"160"; //POSICAO Y NA ESTRUTURA
									},;
									{;
										"1",; //CODIGO DA IMAGEM DO PNEU   EX: NG_PNEU_PRETO_ESCURO_1.PNG
										"565",; //POSICAO X NA ESTRUTURA
										"187"; //POSICAO Y NA ESTRUTURA
									},;
									{;
										"1",; //CODIGO DA IMAGEM DO PNEU   EX: NG_PNEU_PRETO_ESCURO_1.PNG
										"565",; //POSICAO X NA ESTRUTURA
										"235"; //POSICAO Y NA ESTRUTURA
									},;
									{;
										"1",; //CODIGO DA IMAGEM DO PNEU   EX: NG_PNEU_PRETO_ESCURO_1.PNG
										"565",; //POSICAO X NA ESTRUTURA
										"262"; //POSICAO Y NA ESTRUTURA
									};
								},;
								{; //SETIMO EIXO
									{;
										"1",; //CODIGO DA IMAGEM DO PNEU   EX: NG_PNEU_PRETO_ESCURO_1.PNG
										"665",; //POSICAO X NA ESTRUTURA
										"014"; //POSICAO Y NA ESTRUTURA
									},;
									{;
										"1",; //CODIGO DA IMAGEM DO PNEU   EX: NG_PNEU_PRETO_ESCURO_1.PNG
										"665",; //POSICAO X NA ESTRUTURA
										"040"; //POSICAO Y NA ESTRUTURA
									},;
									{;
										"1",; //CODIGO DA IMAGEM DO PNEU   EX: NG_PNEU_PRETO_ESCURO_1.PNG
										"665",; //POSICAO X NA ESTRUTURA
										"089"; //POSICAO Y NA ESTRUTURA
									},;
									{;
										"1",; //CODIGO DA IMAGEM DO PNEU   EX: NG_PNEU_PRETO_ESCURO_1.PNG
										"665",; //POSICAO X NA ESTRUTURA
										"116"; //POSICAO Y NA ESTRUTURA
									},;
									{;
										"1",; //CODIGO DA IMAGEM DO PNEU   EX: NG_PNEU_PRETO_ESCURO_1.PNG
										"665",; //POSICAO X NA ESTRUTURA
										"160"; //POSICAO Y NA ESTRUTURA
									},;
									{;
										"1",; //CODIGO DA IMAGEM DO PNEU   EX: NG_PNEU_PRETO_ESCURO_1.PNG
										"665",; //POSICAO X NA ESTRUTURA
										"187"; //POSICAO Y NA ESTRUTURA
									},;
									{;
										"1",; //CODIGO DA IMAGEM DO PNEU   EX: NG_PNEU_PRETO_ESCURO_1.PNG
										"665",; //POSICAO X NA ESTRUTURA
										"235"; //POSICAO Y NA ESTRUTURA
									},;
									{;
										"1",; //CODIGO DA IMAGEM DO PNEU   EX: NG_PNEU_PRETO_ESCURO_1.PNG
										"665",; //POSICAO X NA ESTRUTURA
										"262"; //POSICAO Y NA ESTRUTURA
									};
								},;
								{; //OITAVO EIXO
									{;
										"1",; //CODIGO DA IMAGEM DO PNEU   EX: NG_PNEU_PRETO_ESCURO_1.PNG
										"765",; //POSICAO X NA ESTRUTURA
										"014"; //POSICAO Y NA ESTRUTURA
									},;
									{;
										"1",; //CODIGO DA IMAGEM DO PNEU   EX: NG_PNEU_PRETO_ESCURO_1.PNG
										"765",; //POSICAO X NA ESTRUTURA
										"040"; //POSICAO Y NA ESTRUTURA
									},;
									{;
										"1",; //CODIGO DA IMAGEM DO PNEU   EX: NG_PNEU_PRETO_ESCURO_1.PNG
										"765",; //POSICAO X NA ESTRUTURA
										"089"; //POSICAO Y NA ESTRUTURA
									},;
									{;
										"1",; //CODIGO DA IMAGEM DO PNEU   EX: NG_PNEU_PRETO_ESCURO_1.PNG
										"765",; //POSICAO X NA ESTRUTURA
										"116"; //POSICAO Y NA ESTRUTURA
									},;
									{;
										"1",; //CODIGO DA IMAGEM DO PNEU   EX: NG_PNEU_PRETO_ESCURO_1.PNG
										"765",; //POSICAO X NA ESTRUTURA
										"160"; //POSICAO Y NA ESTRUTURA
									},;
									{;
										"1",; //CODIGO DA IMAGEM DO PNEU   EX: NG_PNEU_PRETO_ESCURO_1.PNG
										"765",; //POSICAO X NA ESTRUTURA
										"187"; //POSICAO Y NA ESTRUTURA
									},;
									{;
										"1",; //CODIGO DA IMAGEM DO PNEU   EX: NG_PNEU_PRETO_ESCURO_1.PNG
										"765",; //POSICAO X NA ESTRUTURA
										"235"; //POSICAO Y NA ESTRUTURA
									},;
									{;
										"1",; //CODIGO DA IMAGEM DO PNEU   EX: NG_PNEU_PRETO_ESCURO_1.PNG
										"765",; //POSICAO X NA ESTRUTURA
										"262"; //POSICAO Y NA ESTRUTURA
									};
								};
							},;
							{; //STEPES
								{;
									{;
										"2",; //CODIGO DA IMAGEM DO PNEU   EX: NG_PNEU_PRETO_ESCURO_1.PNG
										"-3",; //POSICAO X NA ESTRUTURA
										"4"; //POSICAO Y NA ESTRUTURA
									},;
									{;
										"2",; //CODIGO DA IMAGEM DO PNEU   EX: NG_PNEU_PRETO_ESCURO_1.PNG
										"-3",; //POSICAO X NA ESTRUTURA
										"78"; //POSICAO Y NA ESTRUTURA
									},;
									{;
										"2",; //CODIGO DA IMAGEM DO PNEU   EX: NG_PNEU_PRETO_ESCURO_1.PNG
										"-3",; //POSICAO X NA ESTRUTURA
										"152"; //POSICAO Y NA ESTRUTURA
									},;
									{;
										"2",; //CODIGO DA IMAGEM DO PNEU   EX: NG_PNEU_PRETO_ESCURO_1.PNG
										"-3",; //POSICAO X NA ESTRUTURA
										"225"; //POSICAO Y NA ESTRUTURA
									},;
									{;
										"2",; //CODIGO DA IMAGEM DO PNEU   EX: NG_PNEU_PRETO_ESCURO_1.PNG
										"833",; //POSICAO X NA ESTRUTURA
										"4"; //POSICAO Y NA ESTRUTURA
									},;
									{;
										"2",; //CODIGO DA IMAGEM DO PNEU   EX: NG_PNEU_PRETO_ESCURO_1.PNG
										"833",; //POSICAO X NA ESTRUTURA
										"78"; //POSICAO Y NA ESTRUTURA
									},;
									{;
										"2",; //CODIGO DA IMAGEM DO PNEU   EX: NG_PNEU_PRETO_ESCURO_1.PNG
										"833",; //POSICAO X NA ESTRUTURA
										"152"; //POSICAO Y NA ESTRUTURA
									},;
									{;
										"2",; //CODIGO DA IMAGEM DO PNEU   EX: NG_PNEU_PRETO_ESCURO_1.PNG
										"833",; //POSICAO X NA ESTRUTURA
										"225"; //POSICAO Y NA ESTRUTURA
									};
								};
							};
				};
		)

	*********************************************************************************
	aAdd(aEstruTemp,{	"22",; //CODIGO DA IMAGEM DA ESTRUTURA   EX: NG_ESTRUTURA_1.PNG
							"955",; //TAMANHO X EM PIXEL
							"159",; //TAMANHO Y EM PIXEL
							{;
								{;	//PRIMEIRO EIXO
									{;
										"1",; //CODIGO DA IMAGEM DO PNEU   EX: NG_PNEU_PRETO_ESCURO_1.PNG
										"025",; //POSICAO X NA ESTRUTURA
										"012"; //POSICAO Y NA ESTRUTURA
									},;
									{;
										"1",; //CODIGO DA IMAGEM DO PNEU   EX: NG_PNEU_PRETO_ESCURO_1.PNG
										"025",; //POSICAO X NA ESTRUTURA
										"116"; //POSICAO Y NA ESTRUTURA
									};
								},;
								{; //SEGUNDO EIXO
									{;
										"1",; //CODIGO DA IMAGEM DO PNEU   EX: NG_PNEU_PRETO_ESCURO_1.PNG
										"123",; //POSICAO X NA ESTRUTURA
										"012"; //POSICAO Y NA ESTRUTURA
									},;
									{;
										"1",; //CODIGO DA IMAGEM DO PNEU   EX: NG_PNEU_PRETO_ESCURO_1.PNG
										"123",; //POSICAO X NA ESTRUTURA
										"116"; //POSICAO Y NA ESTRUTURA
									};
								},;
								{; //TERCEIRO EIXO
									{;
										"1",; //CODIGO DA IMAGEM DO PNEU   EX: NG_PNEU_PRETO_ESCURO_1.PNG
										"223",; //POSICAO X NA ESTRUTURA
										"012"; //POSICAO Y NA ESTRUTURA
									},;
									{;
										"1",; //CODIGO DA IMAGEM DO PNEU   EX: NG_PNEU_PRETO_ESCURO_1.PNG
										"223",; //POSICAO X NA ESTRUTURA
										"116"; //POSICAO Y NA ESTRUTURA
									};
								},;
								{; //QUARTO EIXO
									{;
										"1",; //CODIGO DA IMAGEM DO PNEU   EX: NG_PNEU_PRETO_ESCURO_1.PNG
										"323",; //POSICAO X NA ESTRUTURA
										"012"; //POSICAO Y NA ESTRUTURA
									},;
									{;
										"1",; //CODIGO DA IMAGEM DO PNEU   EX: NG_PNEU_PRETO_ESCURO_1.PNG
										"323",; //POSICAO X NA ESTRUTURA
										"116"; //POSICAO Y NA ESTRUTURA
									};
								},;
								{; //QUINTO EIXO
									{;
										"1",; //CODIGO DA IMAGEM DO PNEU   EX: NG_PNEU_PRETO_ESCURO_1.PNG
										"423",; //POSICAO X NA ESTRUTURA
										"012"; //POSICAO Y NA ESTRUTURA
									},;
									{;
										"1",; //CODIGO DA IMAGEM DO PNEU   EX: NG_PNEU_PRETO_ESCURO_1.PNG
										"423",; //POSICAO X NA ESTRUTURA
										"116"; //POSICAO Y NA ESTRUTURA
									};
								},;
								{; //SEXTO EIXO
									{;
										"1",; //CODIGO DA IMAGEM DO PNEU   EX: NG_PNEU_PRETO_ESCURO_1.PNG
										"523",; //POSICAO X NA ESTRUTURA
										"012"; //POSICAO Y NA ESTRUTURA
									},;
									{;
										"1",; //CODIGO DA IMAGEM DO PNEU   EX: NG_PNEU_PRETO_ESCURO_1.PNG
										"523",; //POSICAO X NA ESTRUTURA
										"116"; //POSICAO Y NA ESTRUTURA
									};
								},;
								{; //SETIMO EIXO
									{;
										"1",; //CODIGO DA IMAGEM DO PNEU   EX: NG_PNEU_PRETO_ESCURO_1.PNG
										"623",; //POSICAO X NA ESTRUTURA
										"012"; //POSICAO Y NA ESTRUTURA
									},;
									{;
										"1",; //CODIGO DA IMAGEM DO PNEU   EX: NG_PNEU_PRETO_ESCURO_1.PNG
										"623",; //POSICAO X NA ESTRUTURA
										"116"; //POSICAO Y NA ESTRUTURA
									};
								},;
								{; //OITAVO EIXO
									{;
										"1",; //CODIGO DA IMAGEM DO PNEU   EX: NG_PNEU_PRETO_ESCURO_1.PNG
										"723",; //POSICAO X NA ESTRUTURA
										"012"; //POSICAO Y NA ESTRUTURA
									},;
									{;
										"1",; //CODIGO DA IMAGEM DO PNEU   EX: NG_PNEU_PRETO_ESCURO_1.PNG
										"723",; //POSICAO X NA ESTRUTURA
										"116"; //POSICAO Y NA ESTRUTURA
									};
								},;
								{; //NONO EIXO
									{;
										"1",; //CODIGO DA IMAGEM DO PNEU   EX: NG_PNEU_PRETO_ESCURO_1.PNG
										"823",; //POSICAO X NA ESTRUTURA
										"012"; //POSICAO Y NA ESTRUTURA
									},;
									{;
										"1",; //CODIGO DA IMAGEM DO PNEU   EX: NG_PNEU_PRETO_ESCURO_1.PNG
										"823",; //POSICAO X NA ESTRUTURA
										"116"; //POSICAO Y NA ESTRUTURA
									};
								};
							},;
							{; //STEPES
								{;
									{;
										"2",; //CODIGO DA IMAGEM DO PNEU   EX: NG_PNEU_PRETO_ESCURO_1.PNG
										"890",; //POSICAO X NA ESTRUTURA
										"042"; //POSICAO Y NA ESTRUTURA
									};
								};
							};
				};
		)

	*********************************************************************************
	aAdd(aEstruTemp,{	"23",; //CODIGO DA IMAGEM DA ESTRUTURA   EX: NG_ESTRUTURA_1.PNG
							"552",; //TAMANHO X EM PIXEL
							"206",; //TAMANHO Y EM PIXEL
							{;
								{;	//PRIMEIRO EIXO
									{;
										"1",; //CODIGO DA IMAGEM DO PNEU   EX: NG_PNEU_PRETO_ESCURO_1.PNG
										"044",; //POSICAO X NA ESTRUTURA
										"029"; //POSICAO Y NA ESTRUTURA
									},;
									{;
										"1",; //CODIGO DA IMAGEM DO PNEU   EX: NG_PNEU_PRETO_ESCURO_1.PNG
										"044",; //POSICAO X NA ESTRUTURA
										"059"; //POSICAO Y NA ESTRUTURA
									},;
									{;
										"1",; //CODIGO DA IMAGEM DO PNEU   EX: NG_PNEU_PRETO_ESCURO_1.PNG
										"044",; //POSICAO X NA ESTRUTURA
										"092"; //POSICAO Y NA ESTRUTURA
									},;
									{;
										"1",; //CODIGO DA IMAGEM DO PNEU   EX: NG_PNEU_PRETO_ESCURO_1.PNG
										"044",; //POSICAO X NA ESTRUTURA
										"123"; //POSICAO Y NA ESTRUTURA
									},;
									{;
										"1",; //CODIGO DA IMAGEM DO PNEU   EX: NG_PNEU_PRETO_ESCURO_1.PNG
										"044",; //POSICAO X NA ESTRUTURA
										"153"; //POSICAO Y NA ESTRUTURA
									};
								},;
								{; //SEGUNDO EIXO
									{;
										"1",; //CODIGO DA IMAGEM DO PNEU   EX: NG_PNEU_PRETO_ESCURO_1.PNG
										"426",; //POSICAO X NA ESTRUTURA
										"044"; //POSICAO Y NA ESTRUTURA
									},;
									{;
										"1",; //CODIGO DA IMAGEM DO PNEU   EX: NG_PNEU_PRETO_ESCURO_1.PNG
										"426",; //POSICAO X NA ESTRUTURA
										"075"; //POSICAO Y NA ESTRUTURA
									},;
									{;
										"1",; //CODIGO DA IMAGEM DO PNEU   EX: NG_PNEU_PRETO_ESCURO_1.PNG
										"426",; //POSICAO X NA ESTRUTURA
										"107"; //POSICAO Y NA ESTRUTURA
									},;
									{;
										"1",; //CODIGO DA IMAGEM DO PNEU   EX: NG_PNEU_PRETO_ESCURO_1.PNG
										"426",; //POSICAO X NA ESTRUTURA
										"137"; //POSICAO Y NA ESTRUTURA
									};
								};
							},;
							{; //STEPES
								{;
								};
							};
				};
		)

	*********************************************************************************
	aAdd(aEstruTemp,{	"24",; //CODIGO DA IMAGEM DA ESTRUTURA   EX: NG_ESTRUTURA_1.PNG
							"552",; //TAMANHO X EM PIXEL
							"206",; //TAMANHO Y EM PIXEL
							{;
								{;	//PRIMEIRO EIXO
									{;
										"1",; //CODIGO DA IMAGEM DO PNEU   EX: NG_PNEU_PRETO_ESCURO_1.PNG
										"044",; //POSICAO X NA ESTRUTURA
										"045"; //POSICAO Y NA ESTRUTURA
									},;
									{;
										"1",; //CODIGO DA IMAGEM DO PNEU   EX: NG_PNEU_PRETO_ESCURO_1.PNG
										"044",; //POSICAO X NA ESTRUTURA
										"075"; //POSICAO Y NA ESTRUTURA
									},;
									{;
										"1",; //CODIGO DA IMAGEM DO PNEU   EX: NG_PNEU_PRETO_ESCURO_1.PNG
										"044",; //POSICAO X NA ESTRUTURA
										"108"; //POSICAO Y NA ESTRUTURA
									},;
									{;
										"1",; //CODIGO DA IMAGEM DO PNEU   EX: NG_PNEU_PRETO_ESCURO_1.PNG
										"044",; //POSICAO X NA ESTRUTURA
										"138"; //POSICAO Y NA ESTRUTURA
									};
								},;
								{; //SEGUNDO EIXO
									{;
										"1",; //CODIGO DA IMAGEM DO PNEU   EX: NG_PNEU_PRETO_ESCURO_1.PNG
										"426",; //POSICAO X NA ESTRUTURA
										"060"; //POSICAO Y NA ESTRUTURA
									},;
									{;
										"1",; //CODIGO DA IMAGEM DO PNEU   EX: NG_PNEU_PRETO_ESCURO_1.PNG
										"426",; //POSICAO X NA ESTRUTURA
										"091"; //POSICAO Y NA ESTRUTURA
									},;
									{;
										"1",; //CODIGO DA IMAGEM DO PNEU   EX: NG_PNEU_PRETO_ESCURO_1.PNG
										"426",; //POSICAO X NA ESTRUTURA
										"122"; //POSICAO Y NA ESTRUTURA
									};
								};
							},;
							{; //STEPES
								{;
								};
							};
				};
		)

	*********************************************************************************
	aAdd(aEstruTemp,{	"25",; //CODIGO DA IMAGEM DA ESTRUTURA   EX: NG_ESTRUTURA_1.PNG
							"314",; //TAMANHO X EM PIXEL
							"305",; //TAMANHO Y EM PIXEL
							{;
								{;	//PRIMEIRO EIXO
									{;
										"1",; //CODIGO DA IMAGEM DO PNEU   EX: NG_PNEU_PRETO_ESCURO_1.PNG
										"064",; //POSICAO X NA ESTRUTURA
										"014"; //POSICAO Y NA ESTRUTURA
									},;
									{;
										"1",; //CODIGO DA IMAGEM DO PNEU   EX: NG_PNEU_PRETO_ESCURO_1.PNG
										"064",; //POSICAO X NA ESTRUTURA
										"040"; //POSICAO Y NA ESTRUTURA
									},;
									{;
										"1",; //CODIGO DA IMAGEM DO PNEU   EX: NG_PNEU_PRETO_ESCURO_1.PNG
										"064",; //POSICAO X NA ESTRUTURA
										"089"; //POSICAO Y NA ESTRUTURA
									},;
									{;
										"1",; //CODIGO DA IMAGEM DO PNEU   EX: NG_PNEU_PRETO_ESCURO_1.PNG
										"064",; //POSICAO X NA ESTRUTURA
										"116"; //POSICAO Y NA ESTRUTURA
									},;
									{;
										"1",; //CODIGO DA IMAGEM DO PNEU   EX: NG_PNEU_PRETO_ESCURO_1.PNG
										"064",; //POSICAO X NA ESTRUTURA
										"160"; //POSICAO Y NA ESTRUTURA
									},;
									{;
										"1",; //CODIGO DA IMAGEM DO PNEU   EX: NG_PNEU_PRETO_ESCURO_1.PNG
										"064",; //POSICAO X NA ESTRUTURA
										"187"; //POSICAO Y NA ESTRUTURA
									},;
									{;
										"1",; //CODIGO DA IMAGEM DO PNEU   EX: NG_PNEU_PRETO_ESCURO_1.PNG
										"064",; //POSICAO X NA ESTRUTURA
										"235"; //POSICAO Y NA ESTRUTURA
									},;
									{;
										"1",; //CODIGO DA IMAGEM DO PNEU   EX: NG_PNEU_PRETO_ESCURO_1.PNG
										"064",; //POSICAO X NA ESTRUTURA
										"262"; //POSICAO Y NA ESTRUTURA
									};
								},;
								{; //SEGUNDO EIXO
									{;
										"1",; //CODIGO DA IMAGEM DO PNEU   EX: NG_PNEU_PRETO_ESCURO_1.PNG
										"165",; //POSICAO X NA ESTRUTURA
										"014"; //POSICAO Y NA ESTRUTURA
									},;
									{;
										"1",; //CODIGO DA IMAGEM DO PNEU   EX: NG_PNEU_PRETO_ESCURO_1.PNG
										"165",; //POSICAO X NA ESTRUTURA
										"040"; //POSICAO Y NA ESTRUTURA
									},;
									{;
										"1",; //CODIGO DA IMAGEM DO PNEU   EX: NG_PNEU_PRETO_ESCURO_1.PNG
										"165",; //POSICAO X NA ESTRUTURA
										"089"; //POSICAO Y NA ESTRUTURA
									},;
									{;
										"1",; //CODIGO DA IMAGEM DO PNEU   EX: NG_PNEU_PRETO_ESCURO_1.PNG
										"165",; //POSICAO X NA ESTRUTURA
										"116"; //POSICAO Y NA ESTRUTURA
									},;
									{;
										"1",; //CODIGO DA IMAGEM DO PNEU   EX: NG_PNEU_PRETO_ESCURO_1.PNG
										"165",; //POSICAO X NA ESTRUTURA
										"160"; //POSICAO Y NA ESTRUTURA
									},;
									{;
										"1",; //CODIGO DA IMAGEM DO PNEU   EX: NG_PNEU_PRETO_ESCURO_1.PNG
										"165",; //POSICAO X NA ESTRUTURA
										"187"; //POSICAO Y NA ESTRUTURA
									},;
									{;
										"1",; //CODIGO DA IMAGEM DO PNEU   EX: NG_PNEU_PRETO_ESCURO_1.PNG
										"165",; //POSICAO X NA ESTRUTURA
										"235"; //POSICAO Y NA ESTRUTURA
									},;
									{;
										"1",; //CODIGO DA IMAGEM DO PNEU   EX: NG_PNEU_PRETO_ESCURO_1.PNG
										"165",; //POSICAO X NA ESTRUTURA
										"262"; //POSICAO Y NA ESTRUTURA
									};
								};
							},;
							{; //STEPES
								{;
									{;
										"2",; //CODIGO DA IMAGEM DO PNEU   EX: NG_PNEU_PRETO_ESCURO_1.PNG
										"-3",; //POSICAO X NA ESTRUTURA
										"39"; //POSICAO Y NA ESTRUTURA
									},;
									{;
										"2",; //CODIGO DA IMAGEM DO PNEU   EX: NG_PNEU_PRETO_ESCURO_1.PNG
										"-3",; //POSICAO X NA ESTRUTURA
										"186"; //POSICAO Y NA ESTRUTURA
									},;
									{;
										"2",; //CODIGO DA IMAGEM DO PNEU   EX: NG_PNEU_PRETO_ESCURO_1.PNG
										"233",; //POSICAO X NA ESTRUTURA
										"39"; //POSICAO Y NA ESTRUTURA
									},;
									{;
										"2",; //CODIGO DA IMAGEM DO PNEU   EX: NG_PNEU_PRETO_ESCURO_1.PNG
										"233",; //POSICAO X NA ESTRUTURA
										"186"; //POSICAO Y NA ESTRUTURA
									};
								};
							};
				};
		)

	*********************************************************************************
	aAdd(aEstruTemp,{	"26",; //CODIGO DA IMAGEM DA ESTRUTURA   EX: NG_ESTRUTURA_1.PNG
							"412",; //TAMANHO X EM PIXEL
							"305",; //TAMANHO Y EM PIXEL
							{;
								{;	//PRIMEIRO EIXO
									{;
										"1",; //CODIGO DA IMAGEM DO PNEU   EX: NG_PNEU_PRETO_ESCURO_1.PNG
										"064",; //POSICAO X NA ESTRUTURA
										"014"; //POSICAO Y NA ESTRUTURA
									},;
									{;
										"1",; //CODIGO DA IMAGEM DO PNEU   EX: NG_PNEU_PRETO_ESCURO_1.PNG
										"064",; //POSICAO X NA ESTRUTURA
										"040"; //POSICAO Y NA ESTRUTURA
									},;
									{;
										"1",; //CODIGO DA IMAGEM DO PNEU   EX: NG_PNEU_PRETO_ESCURO_1.PNG
										"064",; //POSICAO X NA ESTRUTURA
										"089"; //POSICAO Y NA ESTRUTURA
									},;
									{;
										"1",; //CODIGO DA IMAGEM DO PNEU   EX: NG_PNEU_PRETO_ESCURO_1.PNG
										"064",; //POSICAO X NA ESTRUTURA
										"116"; //POSICAO Y NA ESTRUTURA
									},;
									{;
										"1",; //CODIGO DA IMAGEM DO PNEU   EX: NG_PNEU_PRETO_ESCURO_1.PNG
										"064",; //POSICAO X NA ESTRUTURA
										"160"; //POSICAO Y NA ESTRUTURA
									},;
									{;
										"1",; //CODIGO DA IMAGEM DO PNEU   EX: NG_PNEU_PRETO_ESCURO_1.PNG
										"064",; //POSICAO X NA ESTRUTURA
										"187"; //POSICAO Y NA ESTRUTURA
									},;
									{;
										"1",; //CODIGO DA IMAGEM DO PNEU   EX: NG_PNEU_PRETO_ESCURO_1.PNG
										"064",; //POSICAO X NA ESTRUTURA
										"235"; //POSICAO Y NA ESTRUTURA
									},;
									{;
										"1",; //CODIGO DA IMAGEM DO PNEU   EX: NG_PNEU_PRETO_ESCURO_1.PNG
										"064",; //POSICAO X NA ESTRUTURA
										"262"; //POSICAO Y NA ESTRUTURA
									};
								},;
								{; //SEGUNDO EIXO
									{;
										"1",; //CODIGO DA IMAGEM DO PNEU   EX: NG_PNEU_PRETO_ESCURO_1.PNG
										"165",; //POSICAO X NA ESTRUTURA
										"014"; //POSICAO Y NA ESTRUTURA
									},;
									{;
										"1",; //CODIGO DA IMAGEM DO PNEU   EX: NG_PNEU_PRETO_ESCURO_1.PNG
										"165",; //POSICAO X NA ESTRUTURA
										"040"; //POSICAO Y NA ESTRUTURA
									},;
									{;
										"1",; //CODIGO DA IMAGEM DO PNEU   EX: NG_PNEU_PRETO_ESCURO_1.PNG
										"165",; //POSICAO X NA ESTRUTURA
										"089"; //POSICAO Y NA ESTRUTURA
									},;
									{;
										"1",; //CODIGO DA IMAGEM DO PNEU   EX: NG_PNEU_PRETO_ESCURO_1.PNG
										"165",; //POSICAO X NA ESTRUTURA
										"116"; //POSICAO Y NA ESTRUTURA
									},;
									{;
										"1",; //CODIGO DA IMAGEM DO PNEU   EX: NG_PNEU_PRETO_ESCURO_1.PNG
										"165",; //POSICAO X NA ESTRUTURA
										"160"; //POSICAO Y NA ESTRUTURA
									},;
									{;
										"1",; //CODIGO DA IMAGEM DO PNEU   EX: NG_PNEU_PRETO_ESCURO_1.PNG
										"165",; //POSICAO X NA ESTRUTURA
										"187"; //POSICAO Y NA ESTRUTURA
									},;
									{;
										"1",; //CODIGO DA IMAGEM DO PNEU   EX: NG_PNEU_PRETO_ESCURO_1.PNG
										"165",; //POSICAO X NA ESTRUTURA
										"235"; //POSICAO Y NA ESTRUTURA
									},;
									{;
										"1",; //CODIGO DA IMAGEM DO PNEU   EX: NG_PNEU_PRETO_ESCURO_1.PNG
										"165",; //POSICAO X NA ESTRUTURA
										"262"; //POSICAO Y NA ESTRUTURA
									};
								},;
								{; //TERCEIRO EIXO
									{;
										"1",; //CODIGO DA IMAGEM DO PNEU   EX: NG_PNEU_PRETO_ESCURO_1.PNG
										"265",; //POSICAO X NA ESTRUTURA
										"014"; //POSICAO Y NA ESTRUTURA
									},;
									{;
										"1",; //CODIGO DA IMAGEM DO PNEU   EX: NG_PNEU_PRETO_ESCURO_1.PNG
										"265",; //POSICAO X NA ESTRUTURA
										"040"; //POSICAO Y NA ESTRUTURA
									},;
									{;
										"1",; //CODIGO DA IMAGEM DO PNEU   EX: NG_PNEU_PRETO_ESCURO_1.PNG
										"265",; //POSICAO X NA ESTRUTURA
										"089"; //POSICAO Y NA ESTRUTURA
									},;
									{;
										"1",; //CODIGO DA IMAGEM DO PNEU   EX: NG_PNEU_PRETO_ESCURO_1.PNG
										"265",; //POSICAO X NA ESTRUTURA
										"116"; //POSICAO Y NA ESTRUTURA
									},;
									{;
										"1",; //CODIGO DA IMAGEM DO PNEU   EX: NG_PNEU_PRETO_ESCURO_1.PNG
										"265",; //POSICAO X NA ESTRUTURA
										"160"; //POSICAO Y NA ESTRUTURA
									},;
									{;
										"1",; //CODIGO DA IMAGEM DO PNEU   EX: NG_PNEU_PRETO_ESCURO_1.PNG
										"265",; //POSICAO X NA ESTRUTURA
										"187"; //POSICAO Y NA ESTRUTURA
									},;
									{;
										"1",; //CODIGO DA IMAGEM DO PNEU   EX: NG_PNEU_PRETO_ESCURO_1.PNG
										"265",; //POSICAO X NA ESTRUTURA
										"235"; //POSICAO Y NA ESTRUTURA
									},;
									{;
										"1",; //CODIGO DA IMAGEM DO PNEU   EX: NG_PNEU_PRETO_ESCURO_1.PNG
										"265",; //POSICAO X NA ESTRUTURA
										"262"; //POSICAO Y NA ESTRUTURA
									};
								};
							},;
							{; //STEPES
								{;
									{;
										"2",; //CODIGO DA IMAGEM DO PNEU   EX: NG_PNEU_PRETO_ESCURO_1.PNG
										"-3",; //POSICAO X NA ESTRUTURA
										"39"; //POSICAO Y NA ESTRUTURA
									},;
									{;
										"2",; //CODIGO DA IMAGEM DO PNEU   EX: NG_PNEU_PRETO_ESCURO_1.PNG
										"-3",; //POSICAO X NA ESTRUTURA
										"186"; //POSICAO Y NA ESTRUTURA
									},;
									{;
										"2",; //CODIGO DA IMAGEM DO PNEU   EX: NG_PNEU_PRETO_ESCURO_1.PNG
										"333",; //POSICAO X NA ESTRUTURA
										"39"; //POSICAO Y NA ESTRUTURA
									},;
									{;
										"2",; //CODIGO DA IMAGEM DO PNEU   EX: NG_PNEU_PRETO_ESCURO_1.PNG
										"333",; //POSICAO X NA ESTRUTURA
										"186"; //POSICAO Y NA ESTRUTURA
									};
								};
							};
				};
		)

	*********************************************************************************
	aAdd(aEstruTemp,{	"27",; //CODIGO DA IMAGEM DA ESTRUTURA   EX: NG_ESTRUTURA_1.PNG
							"509",; //TAMANHO X EM PIXEL
							"305",; //TAMANHO Y EM PIXEL
							{;
								{;	//PRIMEIRO EIXO
									{;
										"1",; //CODIGO DA IMAGEM DO PNEU   EX: NG_PNEU_PRETO_ESCURO_1.PNG
										"064",; //POSICAO X NA ESTRUTURA
										"014"; //POSICAO Y NA ESTRUTURA
									},;
									{;
										"1",; //CODIGO DA IMAGEM DO PNEU   EX: NG_PNEU_PRETO_ESCURO_1.PNG
										"064",; //POSICAO X NA ESTRUTURA
										"040"; //POSICAO Y NA ESTRUTURA
									},;
									{;
										"1",; //CODIGO DA IMAGEM DO PNEU   EX: NG_PNEU_PRETO_ESCURO_1.PNG
										"064",; //POSICAO X NA ESTRUTURA
										"089"; //POSICAO Y NA ESTRUTURA
									},;
									{;
										"1",; //CODIGO DA IMAGEM DO PNEU   EX: NG_PNEU_PRETO_ESCURO_1.PNG
										"064",; //POSICAO X NA ESTRUTURA
										"116"; //POSICAO Y NA ESTRUTURA
									},;
									{;
										"1",; //CODIGO DA IMAGEM DO PNEU   EX: NG_PNEU_PRETO_ESCURO_1.PNG
										"064",; //POSICAO X NA ESTRUTURA
										"160"; //POSICAO Y NA ESTRUTURA
									},;
									{;
										"1",; //CODIGO DA IMAGEM DO PNEU   EX: NG_PNEU_PRETO_ESCURO_1.PNG
										"064",; //POSICAO X NA ESTRUTURA
										"187"; //POSICAO Y NA ESTRUTURA
									},;
									{;
										"1",; //CODIGO DA IMAGEM DO PNEU   EX: NG_PNEU_PRETO_ESCURO_1.PNG
										"064",; //POSICAO X NA ESTRUTURA
										"235"; //POSICAO Y NA ESTRUTURA
									},;
									{;
										"1",; //CODIGO DA IMAGEM DO PNEU   EX: NG_PNEU_PRETO_ESCURO_1.PNG
										"064",; //POSICAO X NA ESTRUTURA
										"262"; //POSICAO Y NA ESTRUTURA
									};
								},;
								{; //SEGUNDO EIXO
									{;
										"1",; //CODIGO DA IMAGEM DO PNEU   EX: NG_PNEU_PRETO_ESCURO_1.PNG
										"165",; //POSICAO X NA ESTRUTURA
										"014"; //POSICAO Y NA ESTRUTURA
									},;
									{;
										"1",; //CODIGO DA IMAGEM DO PNEU   EX: NG_PNEU_PRETO_ESCURO_1.PNG
										"165",; //POSICAO X NA ESTRUTURA
										"040"; //POSICAO Y NA ESTRUTURA
									},;
									{;
										"1",; //CODIGO DA IMAGEM DO PNEU   EX: NG_PNEU_PRETO_ESCURO_1.PNG
										"165",; //POSICAO X NA ESTRUTURA
										"089"; //POSICAO Y NA ESTRUTURA
									},;
									{;
										"1",; //CODIGO DA IMAGEM DO PNEU   EX: NG_PNEU_PRETO_ESCURO_1.PNG
										"165",; //POSICAO X NA ESTRUTURA
										"116"; //POSICAO Y NA ESTRUTURA
									},;
									{;
										"1",; //CODIGO DA IMAGEM DO PNEU   EX: NG_PNEU_PRETO_ESCURO_1.PNG
										"165",; //POSICAO X NA ESTRUTURA
										"160"; //POSICAO Y NA ESTRUTURA
									},;
									{;
										"1",; //CODIGO DA IMAGEM DO PNEU   EX: NG_PNEU_PRETO_ESCURO_1.PNG
										"165",; //POSICAO X NA ESTRUTURA
										"187"; //POSICAO Y NA ESTRUTURA
									},;
									{;
										"1",; //CODIGO DA IMAGEM DO PNEU   EX: NG_PNEU_PRETO_ESCURO_1.PNG
										"165",; //POSICAO X NA ESTRUTURA
										"235"; //POSICAO Y NA ESTRUTURA
									},;
									{;
										"1",; //CODIGO DA IMAGEM DO PNEU   EX: NG_PNEU_PRETO_ESCURO_1.PNG
										"165",; //POSICAO X NA ESTRUTURA
										"262"; //POSICAO Y NA ESTRUTURA
									};
								},;
								{; //TERCEIRO EIXO
									{;
										"1",; //CODIGO DA IMAGEM DO PNEU   EX: NG_PNEU_PRETO_ESCURO_1.PNG
										"265",; //POSICAO X NA ESTRUTURA
										"014"; //POSICAO Y NA ESTRUTURA
									},;
									{;
										"1",; //CODIGO DA IMAGEM DO PNEU   EX: NG_PNEU_PRETO_ESCURO_1.PNG
										"265",; //POSICAO X NA ESTRUTURA
										"040"; //POSICAO Y NA ESTRUTURA
									},;
									{;
										"1",; //CODIGO DA IMAGEM DO PNEU   EX: NG_PNEU_PRETO_ESCURO_1.PNG
										"265",; //POSICAO X NA ESTRUTURA
										"089"; //POSICAO Y NA ESTRUTURA
									},;
									{;
										"1",; //CODIGO DA IMAGEM DO PNEU   EX: NG_PNEU_PRETO_ESCURO_1.PNG
										"265",; //POSICAO X NA ESTRUTURA
										"116"; //POSICAO Y NA ESTRUTURA
									},;
									{;
										"1",; //CODIGO DA IMAGEM DO PNEU   EX: NG_PNEU_PRETO_ESCURO_1.PNG
										"265",; //POSICAO X NA ESTRUTURA
										"160"; //POSICAO Y NA ESTRUTURA
									},;
									{;
										"1",; //CODIGO DA IMAGEM DO PNEU   EX: NG_PNEU_PRETO_ESCURO_1.PNG
										"265",; //POSICAO X NA ESTRUTURA
										"187"; //POSICAO Y NA ESTRUTURA
									},;
									{;
										"1",; //CODIGO DA IMAGEM DO PNEU   EX: NG_PNEU_PRETO_ESCURO_1.PNG
										"265",; //POSICAO X NA ESTRUTURA
										"235"; //POSICAO Y NA ESTRUTURA
									},;
									{;
										"1",; //CODIGO DA IMAGEM DO PNEU   EX: NG_PNEU_PRETO_ESCURO_1.PNG
										"265",; //POSICAO X NA ESTRUTURA
										"262"; //POSICAO Y NA ESTRUTURA
									};
								},;
								{; //QUARTO EIXO
									{;
										"1",; //CODIGO DA IMAGEM DO PNEU   EX: NG_PNEU_PRETO_ESCURO_1.PNG
										"365",; //POSICAO X NA ESTRUTURA
										"014"; //POSICAO Y NA ESTRUTURA
									},;
									{;
										"1",; //CODIGO DA IMAGEM DO PNEU   EX: NG_PNEU_PRETO_ESCURO_1.PNG
										"365",; //POSICAO X NA ESTRUTURA
										"040"; //POSICAO Y NA ESTRUTURA
									},;
									{;
										"1",; //CODIGO DA IMAGEM DO PNEU   EX: NG_PNEU_PRETO_ESCURO_1.PNG
										"365",; //POSICAO X NA ESTRUTURA
										"089"; //POSICAO Y NA ESTRUTURA
									},;
									{;
										"1",; //CODIGO DA IMAGEM DO PNEU   EX: NG_PNEU_PRETO_ESCURO_1.PNG
										"365",; //POSICAO X NA ESTRUTURA
										"116"; //POSICAO Y NA ESTRUTURA
									},;
									{;
										"1",; //CODIGO DA IMAGEM DO PNEU   EX: NG_PNEU_PRETO_ESCURO_1.PNG
										"365",; //POSICAO X NA ESTRUTURA
										"160"; //POSICAO Y NA ESTRUTURA
									},;
									{;
										"1",; //CODIGO DA IMAGEM DO PNEU   EX: NG_PNEU_PRETO_ESCURO_1.PNG
										"365",; //POSICAO X NA ESTRUTURA
										"187"; //POSICAO Y NA ESTRUTURA
									},;
									{;
										"1",; //CODIGO DA IMAGEM DO PNEU   EX: NG_PNEU_PRETO_ESCURO_1.PNG
										"365",; //POSICAO X NA ESTRUTURA
										"235"; //POSICAO Y NA ESTRUTURA
									},;
									{;
										"1",; //CODIGO DA IMAGEM DO PNEU   EX: NG_PNEU_PRETO_ESCURO_1.PNG
										"365",; //POSICAO X NA ESTRUTURA
										"262"; //POSICAO Y NA ESTRUTURA
									};
								};
							},;
							{; //STEPES
								{;
									{;
										"2",; //CODIGO DA IMAGEM DO PNEU   EX: NG_PNEU_PRETO_ESCURO_1.PNG
										"-3",; //POSICAO X NA ESTRUTURA
										"39"; //POSICAO Y NA ESTRUTURA
									},;
									{;
										"2",; //CODIGO DA IMAGEM DO PNEU   EX: NG_PNEU_PRETO_ESCURO_1.PNG
										"-3",; //POSICAO X NA ESTRUTURA
										"186"; //POSICAO Y NA ESTRUTURA
									},;
									{;
										"2",; //CODIGO DA IMAGEM DO PNEU   EX: NG_PNEU_PRETO_ESCURO_1.PNG
										"433",; //POSICAO X NA ESTRUTURA
										"39"; //POSICAO Y NA ESTRUTURA
									},;
									{;
										"2",; //CODIGO DA IMAGEM DO PNEU   EX: NG_PNEU_PRETO_ESCURO_1.PNG
										"433",; //POSICAO X NA ESTRUTURA
										"186"; //POSICAO Y NA ESTRUTURA
									};
								};
							};
				};
		)

	*********************************************************************************
	aAdd(aEstruTemp,{	"28",; //CODIGO DA IMAGEM DA ESTRUTURA   EX: NG_ESTRUTURA_1.PNG
							"607",; //TAMANHO X EM PIXEL
							"305",; //TAMANHO Y EM PIXEL
							{;
								{;	//PRIMEIRO EIXO
									{;
										"1",; //CODIGO DA IMAGEM DO PNEU   EX: NG_PNEU_PRETO_ESCURO_1.PNG
										"064",; //POSICAO X NA ESTRUTURA
										"014"; //POSICAO Y NA ESTRUTURA
									},;
									{;
										"1",; //CODIGO DA IMAGEM DO PNEU   EX: NG_PNEU_PRETO_ESCURO_1.PNG
										"064",; //POSICAO X NA ESTRUTURA
										"040"; //POSICAO Y NA ESTRUTURA
									},;
									{;
										"1",; //CODIGO DA IMAGEM DO PNEU   EX: NG_PNEU_PRETO_ESCURO_1.PNG
										"064",; //POSICAO X NA ESTRUTURA
										"089"; //POSICAO Y NA ESTRUTURA
									},;
									{;
										"1",; //CODIGO DA IMAGEM DO PNEU   EX: NG_PNEU_PRETO_ESCURO_1.PNG
										"064",; //POSICAO X NA ESTRUTURA
										"116"; //POSICAO Y NA ESTRUTURA
									},;
									{;
										"1",; //CODIGO DA IMAGEM DO PNEU   EX: NG_PNEU_PRETO_ESCURO_1.PNG
										"064",; //POSICAO X NA ESTRUTURA
										"160"; //POSICAO Y NA ESTRUTURA
									},;
									{;
										"1",; //CODIGO DA IMAGEM DO PNEU   EX: NG_PNEU_PRETO_ESCURO_1.PNG
										"064",; //POSICAO X NA ESTRUTURA
										"187"; //POSICAO Y NA ESTRUTURA
									},;
									{;
										"1",; //CODIGO DA IMAGEM DO PNEU   EX: NG_PNEU_PRETO_ESCURO_1.PNG
										"064",; //POSICAO X NA ESTRUTURA
										"235"; //POSICAO Y NA ESTRUTURA
									},;
									{;
										"1",; //CODIGO DA IMAGEM DO PNEU   EX: NG_PNEU_PRETO_ESCURO_1.PNG
										"064",; //POSICAO X NA ESTRUTURA
										"262"; //POSICAO Y NA ESTRUTURA
									};
								},;
								{; //SEGUNDO EIXO
									{;
										"1",; //CODIGO DA IMAGEM DO PNEU   EX: NG_PNEU_PRETO_ESCURO_1.PNG
										"165",; //POSICAO X NA ESTRUTURA
										"014"; //POSICAO Y NA ESTRUTURA
									},;
									{;
										"1",; //CODIGO DA IMAGEM DO PNEU   EX: NG_PNEU_PRETO_ESCURO_1.PNG
										"165",; //POSICAO X NA ESTRUTURA
										"040"; //POSICAO Y NA ESTRUTURA
									},;
									{;
										"1",; //CODIGO DA IMAGEM DO PNEU   EX: NG_PNEU_PRETO_ESCURO_1.PNG
										"165",; //POSICAO X NA ESTRUTURA
										"089"; //POSICAO Y NA ESTRUTURA
									},;
									{;
										"1",; //CODIGO DA IMAGEM DO PNEU   EX: NG_PNEU_PRETO_ESCURO_1.PNG
										"165",; //POSICAO X NA ESTRUTURA
										"116"; //POSICAO Y NA ESTRUTURA
									},;
									{;
										"1",; //CODIGO DA IMAGEM DO PNEU   EX: NG_PNEU_PRETO_ESCURO_1.PNG
										"165",; //POSICAO X NA ESTRUTURA
										"160"; //POSICAO Y NA ESTRUTURA
									},;
									{;
										"1",; //CODIGO DA IMAGEM DO PNEU   EX: NG_PNEU_PRETO_ESCURO_1.PNG
										"165",; //POSICAO X NA ESTRUTURA
										"187"; //POSICAO Y NA ESTRUTURA
									},;
									{;
										"1",; //CODIGO DA IMAGEM DO PNEU   EX: NG_PNEU_PRETO_ESCURO_1.PNG
										"165",; //POSICAO X NA ESTRUTURA
										"235"; //POSICAO Y NA ESTRUTURA
									},;
									{;
										"1",; //CODIGO DA IMAGEM DO PNEU   EX: NG_PNEU_PRETO_ESCURO_1.PNG
										"165",; //POSICAO X NA ESTRUTURA
										"262"; //POSICAO Y NA ESTRUTURA
									};
								},;
								{; //TERCEIRO EIXO
									{;
										"1",; //CODIGO DA IMAGEM DO PNEU   EX: NG_PNEU_PRETO_ESCURO_1.PNG
										"265",; //POSICAO X NA ESTRUTURA
										"014"; //POSICAO Y NA ESTRUTURA
									},;
									{;
										"1",; //CODIGO DA IMAGEM DO PNEU   EX: NG_PNEU_PRETO_ESCURO_1.PNG
										"265",; //POSICAO X NA ESTRUTURA
										"040"; //POSICAO Y NA ESTRUTURA
									},;
									{;
										"1",; //CODIGO DA IMAGEM DO PNEU   EX: NG_PNEU_PRETO_ESCURO_1.PNG
										"265",; //POSICAO X NA ESTRUTURA
										"089"; //POSICAO Y NA ESTRUTURA
									},;
									{;
										"1",; //CODIGO DA IMAGEM DO PNEU   EX: NG_PNEU_PRETO_ESCURO_1.PNG
										"265",; //POSICAO X NA ESTRUTURA
										"116"; //POSICAO Y NA ESTRUTURA
									},;
									{;
										"1",; //CODIGO DA IMAGEM DO PNEU   EX: NG_PNEU_PRETO_ESCURO_1.PNG
										"265",; //POSICAO X NA ESTRUTURA
										"160"; //POSICAO Y NA ESTRUTURA
									},;
									{;
										"1",; //CODIGO DA IMAGEM DO PNEU   EX: NG_PNEU_PRETO_ESCURO_1.PNG
										"265",; //POSICAO X NA ESTRUTURA
										"187"; //POSICAO Y NA ESTRUTURA
									},;
									{;
										"1",; //CODIGO DA IMAGEM DO PNEU   EX: NG_PNEU_PRETO_ESCURO_1.PNG
										"265",; //POSICAO X NA ESTRUTURA
										"235"; //POSICAO Y NA ESTRUTURA
									},;
									{;
										"1",; //CODIGO DA IMAGEM DO PNEU   EX: NG_PNEU_PRETO_ESCURO_1.PNG
										"265",; //POSICAO X NA ESTRUTURA
										"262"; //POSICAO Y NA ESTRUTURA
									};
								},;
								{; //QUARTO EIXO
									{;
										"1",; //CODIGO DA IMAGEM DO PNEU   EX: NG_PNEU_PRETO_ESCURO_1.PNG
										"365",; //POSICAO X NA ESTRUTURA
										"014"; //POSICAO Y NA ESTRUTURA
									},;
									{;
										"1",; //CODIGO DA IMAGEM DO PNEU   EX: NG_PNEU_PRETO_ESCURO_1.PNG
										"365",; //POSICAO X NA ESTRUTURA
										"040"; //POSICAO Y NA ESTRUTURA
									},;
									{;
										"1",; //CODIGO DA IMAGEM DO PNEU   EX: NG_PNEU_PRETO_ESCURO_1.PNG
										"365",; //POSICAO X NA ESTRUTURA
										"089"; //POSICAO Y NA ESTRUTURA
									},;
									{;
										"1",; //CODIGO DA IMAGEM DO PNEU   EX: NG_PNEU_PRETO_ESCURO_1.PNG
										"365",; //POSICAO X NA ESTRUTURA
										"116"; //POSICAO Y NA ESTRUTURA
									},;
									{;
										"1",; //CODIGO DA IMAGEM DO PNEU   EX: NG_PNEU_PRETO_ESCURO_1.PNG
										"365",; //POSICAO X NA ESTRUTURA
										"160"; //POSICAO Y NA ESTRUTURA
									},;
									{;
										"1",; //CODIGO DA IMAGEM DO PNEU   EX: NG_PNEU_PRETO_ESCURO_1.PNG
										"365",; //POSICAO X NA ESTRUTURA
										"187"; //POSICAO Y NA ESTRUTURA
									},;
									{;
										"1",; //CODIGO DA IMAGEM DO PNEU   EX: NG_PNEU_PRETO_ESCURO_1.PNG
										"365",; //POSICAO X NA ESTRUTURA
										"235"; //POSICAO Y NA ESTRUTURA
									},;
									{;
										"1",; //CODIGO DA IMAGEM DO PNEU   EX: NG_PNEU_PRETO_ESCURO_1.PNG
										"365",; //POSICAO X NA ESTRUTURA
										"262"; //POSICAO Y NA ESTRUTURA
									};
								},;
								{; //QUINTO EIXO
									{;
										"1",; //CODIGO DA IMAGEM DO PNEU   EX: NG_PNEU_PRETO_ESCURO_1.PNG
										"465",; //POSICAO X NA ESTRUTURA
										"014"; //POSICAO Y NA ESTRUTURA
									},;
									{;
										"1",; //CODIGO DA IMAGEM DO PNEU   EX: NG_PNEU_PRETO_ESCURO_1.PNG
										"465",; //POSICAO X NA ESTRUTURA
										"040"; //POSICAO Y NA ESTRUTURA
									},;
									{;
										"1",; //CODIGO DA IMAGEM DO PNEU   EX: NG_PNEU_PRETO_ESCURO_1.PNG
										"465",; //POSICAO X NA ESTRUTURA
										"089"; //POSICAO Y NA ESTRUTURA
									},;
									{;
										"1",; //CODIGO DA IMAGEM DO PNEU   EX: NG_PNEU_PRETO_ESCURO_1.PNG
										"465",; //POSICAO X NA ESTRUTURA
										"116"; //POSICAO Y NA ESTRUTURA
									},;
									{;
										"1",; //CODIGO DA IMAGEM DO PNEU   EX: NG_PNEU_PRETO_ESCURO_1.PNG
										"465",; //POSICAO X NA ESTRUTURA
										"160"; //POSICAO Y NA ESTRUTURA
									},;
									{;
										"1",; //CODIGO DA IMAGEM DO PNEU   EX: NG_PNEU_PRETO_ESCURO_1.PNG
										"465",; //POSICAO X NA ESTRUTURA
										"187"; //POSICAO Y NA ESTRUTURA
									},;
									{;
										"1",; //CODIGO DA IMAGEM DO PNEU   EX: NG_PNEU_PRETO_ESCURO_1.PNG
										"465",; //POSICAO X NA ESTRUTURA
										"235"; //POSICAO Y NA ESTRUTURA
									},;
									{;
										"1",; //CODIGO DA IMAGEM DO PNEU   EX: NG_PNEU_PRETO_ESCURO_1.PNG
										"465",; //POSICAO X NA ESTRUTURA
										"262"; //POSICAO Y NA ESTRUTURA
									};
								};
							},;
							{; //STEPES
								{;
									{;
										"2",; //CODIGO DA IMAGEM DO PNEU   EX: NG_PNEU_PRETO_ESCURO_1.PNG
										"-3",; //POSICAO X NA ESTRUTURA
										"39"; //POSICAO Y NA ESTRUTURA
									},;
									{;
										"2",; //CODIGO DA IMAGEM DO PNEU   EX: NG_PNEU_PRETO_ESCURO_1.PNG
										"-3",; //POSICAO X NA ESTRUTURA
										"186"; //POSICAO Y NA ESTRUTURA
									},;
									{;
										"2",; //CODIGO DA IMAGEM DO PNEU   EX: NG_PNEU_PRETO_ESCURO_1.PNG
										"533",; //POSICAO X NA ESTRUTURA
										"39"; //POSICAO Y NA ESTRUTURA
									},;
									{;
										"2",; //CODIGO DA IMAGEM DO PNEU   EX: NG_PNEU_PRETO_ESCURO_1.PNG
										"533",; //POSICAO X NA ESTRUTURA
										"186"; //POSICAO Y NA ESTRUTURA
									};
								};
							};
				};
		)

	*********************************************************************************
	aAdd(aEstruTemp,{	"29",; //CODIGO DA IMAGEM DA ESTRUTURA   EX: NG_ESTRUTURA_1.PNG
							"711",; //TAMANHO X EM PIXEL
							"305",; //TAMANHO Y EM PIXEL
							{;
								{;	//PRIMEIRO EIXO
									{;
										"1",; //CODIGO DA IMAGEM DO PNEU   EX: NG_PNEU_PRETO_ESCURO_1.PNG
										"064",; //POSICAO X NA ESTRUTURA
										"014"; //POSICAO Y NA ESTRUTURA
									},;
									{;
										"1",; //CODIGO DA IMAGEM DO PNEU   EX: NG_PNEU_PRETO_ESCURO_1.PNG
										"064",; //POSICAO X NA ESTRUTURA
										"040"; //POSICAO Y NA ESTRUTURA
									},;
									{;
										"1",; //CODIGO DA IMAGEM DO PNEU   EX: NG_PNEU_PRETO_ESCURO_1.PNG
										"064",; //POSICAO X NA ESTRUTURA
										"089"; //POSICAO Y NA ESTRUTURA
									},;
									{;
										"1",; //CODIGO DA IMAGEM DO PNEU   EX: NG_PNEU_PRETO_ESCURO_1.PNG
										"064",; //POSICAO X NA ESTRUTURA
										"116"; //POSICAO Y NA ESTRUTURA
									},;
									{;
										"1",; //CODIGO DA IMAGEM DO PNEU   EX: NG_PNEU_PRETO_ESCURO_1.PNG
										"064",; //POSICAO X NA ESTRUTURA
										"160"; //POSICAO Y NA ESTRUTURA
									},;
									{;
										"1",; //CODIGO DA IMAGEM DO PNEU   EX: NG_PNEU_PRETO_ESCURO_1.PNG
										"064",; //POSICAO X NA ESTRUTURA
										"187"; //POSICAO Y NA ESTRUTURA
									},;
									{;
										"1",; //CODIGO DA IMAGEM DO PNEU   EX: NG_PNEU_PRETO_ESCURO_1.PNG
										"064",; //POSICAO X NA ESTRUTURA
										"235"; //POSICAO Y NA ESTRUTURA
									},;
									{;
										"1",; //CODIGO DA IMAGEM DO PNEU   EX: NG_PNEU_PRETO_ESCURO_1.PNG
										"064",; //POSICAO X NA ESTRUTURA
										"262"; //POSICAO Y NA ESTRUTURA
									};
								},;
								{; //SEGUNDO EIXO
									{;
										"1",; //CODIGO DA IMAGEM DO PNEU   EX: NG_PNEU_PRETO_ESCURO_1.PNG
										"165",; //POSICAO X NA ESTRUTURA
										"014"; //POSICAO Y NA ESTRUTURA
									},;
									{;
										"1",; //CODIGO DA IMAGEM DO PNEU   EX: NG_PNEU_PRETO_ESCURO_1.PNG
										"165",; //POSICAO X NA ESTRUTURA
										"040"; //POSICAO Y NA ESTRUTURA
									},;
									{;
										"1",; //CODIGO DA IMAGEM DO PNEU   EX: NG_PNEU_PRETO_ESCURO_1.PNG
										"165",; //POSICAO X NA ESTRUTURA
										"089"; //POSICAO Y NA ESTRUTURA
									},;
									{;
										"1",; //CODIGO DA IMAGEM DO PNEU   EX: NG_PNEU_PRETO_ESCURO_1.PNG
										"165",; //POSICAO X NA ESTRUTURA
										"116"; //POSICAO Y NA ESTRUTURA
									},;
									{;
										"1",; //CODIGO DA IMAGEM DO PNEU   EX: NG_PNEU_PRETO_ESCURO_1.PNG
										"165",; //POSICAO X NA ESTRUTURA
										"160"; //POSICAO Y NA ESTRUTURA
									},;
									{;
										"1",; //CODIGO DA IMAGEM DO PNEU   EX: NG_PNEU_PRETO_ESCURO_1.PNG
										"165",; //POSICAO X NA ESTRUTURA
										"187"; //POSICAO Y NA ESTRUTURA
									},;
									{;
										"1",; //CODIGO DA IMAGEM DO PNEU   EX: NG_PNEU_PRETO_ESCURO_1.PNG
										"165",; //POSICAO X NA ESTRUTURA
										"235"; //POSICAO Y NA ESTRUTURA
									},;
									{;
										"1",; //CODIGO DA IMAGEM DO PNEU   EX: NG_PNEU_PRETO_ESCURO_1.PNG
										"165",; //POSICAO X NA ESTRUTURA
										"262"; //POSICAO Y NA ESTRUTURA
									};
								},;
								{; //TERCEIRO EIXO
									{;
										"1",; //CODIGO DA IMAGEM DO PNEU   EX: NG_PNEU_PRETO_ESCURO_1.PNG
										"265",; //POSICAO X NA ESTRUTURA
										"014"; //POSICAO Y NA ESTRUTURA
									},;
									{;
										"1",; //CODIGO DA IMAGEM DO PNEU   EX: NG_PNEU_PRETO_ESCURO_1.PNG
										"265",; //POSICAO X NA ESTRUTURA
										"040"; //POSICAO Y NA ESTRUTURA
									},;
									{;
										"1",; //CODIGO DA IMAGEM DO PNEU   EX: NG_PNEU_PRETO_ESCURO_1.PNG
										"265",; //POSICAO X NA ESTRUTURA
										"089"; //POSICAO Y NA ESTRUTURA
									},;
									{;
										"1",; //CODIGO DA IMAGEM DO PNEU   EX: NG_PNEU_PRETO_ESCURO_1.PNG
										"265",; //POSICAO X NA ESTRUTURA
										"116"; //POSICAO Y NA ESTRUTURA
									},;
									{;
										"1",; //CODIGO DA IMAGEM DO PNEU   EX: NG_PNEU_PRETO_ESCURO_1.PNG
										"265",; //POSICAO X NA ESTRUTURA
										"160"; //POSICAO Y NA ESTRUTURA
									},;
									{;
										"1",; //CODIGO DA IMAGEM DO PNEU   EX: NG_PNEU_PRETO_ESCURO_1.PNG
										"265",; //POSICAO X NA ESTRUTURA
										"187"; //POSICAO Y NA ESTRUTURA
									},;
									{;
										"1",; //CODIGO DA IMAGEM DO PNEU   EX: NG_PNEU_PRETO_ESCURO_1.PNG
										"265",; //POSICAO X NA ESTRUTURA
										"235"; //POSICAO Y NA ESTRUTURA
									},;
									{;
										"1",; //CODIGO DA IMAGEM DO PNEU   EX: NG_PNEU_PRETO_ESCURO_1.PNG
										"265",; //POSICAO X NA ESTRUTURA
										"262"; //POSICAO Y NA ESTRUTURA
									};
								},;
								{; //QUARTO EIXO
									{;
										"1",; //CODIGO DA IMAGEM DO PNEU   EX: NG_PNEU_PRETO_ESCURO_1.PNG
										"365",; //POSICAO X NA ESTRUTURA
										"014"; //POSICAO Y NA ESTRUTURA
									},;
									{;
										"1",; //CODIGO DA IMAGEM DO PNEU   EX: NG_PNEU_PRETO_ESCURO_1.PNG
										"365",; //POSICAO X NA ESTRUTURA
										"040"; //POSICAO Y NA ESTRUTURA
									},;
									{;
										"1",; //CODIGO DA IMAGEM DO PNEU   EX: NG_PNEU_PRETO_ESCURO_1.PNG
										"365",; //POSICAO X NA ESTRUTURA
										"089"; //POSICAO Y NA ESTRUTURA
									},;
									{;
										"1",; //CODIGO DA IMAGEM DO PNEU   EX: NG_PNEU_PRETO_ESCURO_1.PNG
										"365",; //POSICAO X NA ESTRUTURA
										"116"; //POSICAO Y NA ESTRUTURA
									},;
									{;
										"1",; //CODIGO DA IMAGEM DO PNEU   EX: NG_PNEU_PRETO_ESCURO_1.PNG
										"365",; //POSICAO X NA ESTRUTURA
										"160"; //POSICAO Y NA ESTRUTURA
									},;
									{;
										"1",; //CODIGO DA IMAGEM DO PNEU   EX: NG_PNEU_PRETO_ESCURO_1.PNG
										"365",; //POSICAO X NA ESTRUTURA
										"187"; //POSICAO Y NA ESTRUTURA
									},;
									{;
										"1",; //CODIGO DA IMAGEM DO PNEU   EX: NG_PNEU_PRETO_ESCURO_1.PNG
										"365",; //POSICAO X NA ESTRUTURA
										"235"; //POSICAO Y NA ESTRUTURA
									},;
									{;
										"1",; //CODIGO DA IMAGEM DO PNEU   EX: NG_PNEU_PRETO_ESCURO_1.PNG
										"365",; //POSICAO X NA ESTRUTURA
										"262"; //POSICAO Y NA ESTRUTURA
									};
								},;
								{; //QUINTO EIXO
									{;
										"1",; //CODIGO DA IMAGEM DO PNEU   EX: NG_PNEU_PRETO_ESCURO_1.PNG
										"465",; //POSICAO X NA ESTRUTURA
										"014"; //POSICAO Y NA ESTRUTURA
									},;
									{;
										"1",; //CODIGO DA IMAGEM DO PNEU   EX: NG_PNEU_PRETO_ESCURO_1.PNG
										"465",; //POSICAO X NA ESTRUTURA
										"040"; //POSICAO Y NA ESTRUTURA
									},;
									{;
										"1",; //CODIGO DA IMAGEM DO PNEU   EX: NG_PNEU_PRETO_ESCURO_1.PNG
										"465",; //POSICAO X NA ESTRUTURA
										"089"; //POSICAO Y NA ESTRUTURA
									},;
									{;
										"1",; //CODIGO DA IMAGEM DO PNEU   EX: NG_PNEU_PRETO_ESCURO_1.PNG
										"465",; //POSICAO X NA ESTRUTURA
										"116"; //POSICAO Y NA ESTRUTURA
									},;
									{;
										"1",; //CODIGO DA IMAGEM DO PNEU   EX: NG_PNEU_PRETO_ESCURO_1.PNG
										"465",; //POSICAO X NA ESTRUTURA
										"160"; //POSICAO Y NA ESTRUTURA
									},;
									{;
										"1",; //CODIGO DA IMAGEM DO PNEU   EX: NG_PNEU_PRETO_ESCURO_1.PNG
										"465",; //POSICAO X NA ESTRUTURA
										"187"; //POSICAO Y NA ESTRUTURA
									},;
									{;
										"1",; //CODIGO DA IMAGEM DO PNEU   EX: NG_PNEU_PRETO_ESCURO_1.PNG
										"465",; //POSICAO X NA ESTRUTURA
										"235"; //POSICAO Y NA ESTRUTURA
									},;
									{;
										"1",; //CODIGO DA IMAGEM DO PNEU   EX: NG_PNEU_PRETO_ESCURO_1.PNG
										"465",; //POSICAO X NA ESTRUTURA
										"262"; //POSICAO Y NA ESTRUTURA
									};
								},;
								{; //SEXTO EIXO
									{;
										"1",; //CODIGO DA IMAGEM DO PNEU   EX: NG_PNEU_PRETO_ESCURO_1.PNG
										"565",; //POSICAO X NA ESTRUTURA
										"014"; //POSICAO Y NA ESTRUTURA
									},;
									{;
										"1",; //CODIGO DA IMAGEM DO PNEU   EX: NG_PNEU_PRETO_ESCURO_1.PNG
										"565",; //POSICAO X NA ESTRUTURA
										"040"; //POSICAO Y NA ESTRUTURA
									},;
									{;
										"1",; //CODIGO DA IMAGEM DO PNEU   EX: NG_PNEU_PRETO_ESCURO_1.PNG
										"565",; //POSICAO X NA ESTRUTURA
										"089"; //POSICAO Y NA ESTRUTURA
									},;
									{;
										"1",; //CODIGO DA IMAGEM DO PNEU   EX: NG_PNEU_PRETO_ESCURO_1.PNG
										"565",; //POSICAO X NA ESTRUTURA
										"116"; //POSICAO Y NA ESTRUTURA
									},;
									{;
										"1",; //CODIGO DA IMAGEM DO PNEU   EX: NG_PNEU_PRETO_ESCURO_1.PNG
										"565",; //POSICAO X NA ESTRUTURA
										"160"; //POSICAO Y NA ESTRUTURA
									},;
									{;
										"1",; //CODIGO DA IMAGEM DO PNEU   EX: NG_PNEU_PRETO_ESCURO_1.PNG
										"565",; //POSICAO X NA ESTRUTURA
										"187"; //POSICAO Y NA ESTRUTURA
									},;
									{;
										"1",; //CODIGO DA IMAGEM DO PNEU   EX: NG_PNEU_PRETO_ESCURO_1.PNG
										"565",; //POSICAO X NA ESTRUTURA
										"235"; //POSICAO Y NA ESTRUTURA
									},;
									{;
										"1",; //CODIGO DA IMAGEM DO PNEU   EX: NG_PNEU_PRETO_ESCURO_1.PNG
										"565",; //POSICAO X NA ESTRUTURA
										"262"; //POSICAO Y NA ESTRUTURA
									};
								};
							},;
							{; //STEPES
								{;
									{;
										"2",; //CODIGO DA IMAGEM DO PNEU   EX: NG_PNEU_PRETO_ESCURO_1.PNG
										"-3",; //POSICAO X NA ESTRUTURA
										"39"; //POSICAO Y NA ESTRUTURA
									},;
									{;
										"2",; //CODIGO DA IMAGEM DO PNEU   EX: NG_PNEU_PRETO_ESCURO_1.PNG
										"-3",; //POSICAO X NA ESTRUTURA
										"113"; //POSICAO Y NA ESTRUTURA
									},;
									{;
										"2",; //CODIGO DA IMAGEM DO PNEU   EX: NG_PNEU_PRETO_ESCURO_1.PNG
										"-3",; //POSICAO X NA ESTRUTURA
										"187"; //POSICAO Y NA ESTRUTURA
									},;
									{;
										"2",; //CODIGO DA IMAGEM DO PNEU   EX: NG_PNEU_PRETO_ESCURO_1.PNG
										"633",; //POSICAO X NA ESTRUTURA
										"39"; //POSICAO Y NA ESTRUTURA
									},;
									{;
										"2",; //CODIGO DA IMAGEM DO PNEU   EX: NG_PNEU_PRETO_ESCURO_1.PNG
										"633",; //POSICAO X NA ESTRUTURA
										"113"; //POSICAO Y NA ESTRUTURA
									},;
									{;
										"2",; //CODIGO DA IMAGEM DO PNEU   EX: NG_PNEU_PRETO_ESCURO_1.PNG
										"633",; //POSICAO X NA ESTRUTURA
										"187"; //POSICAO Y NA ESTRUTURA
									};
								};
							};
				};
		)

	*********************************************************************************
	aAdd(aEstruTemp,{	"30",; //CODIGO DA IMAGEM DA ESTRUTURA   EX: NG_ESTRUTURA_1.PNG
							"810",; //TAMANHO X EM PIXEL
							"305",; //TAMANHO Y EM PIXEL
							{;
								{;	//PRIMEIRO EIXO
									{;
										"1",; //CODIGO DA IMAGEM DO PNEU   EX: NG_PNEU_PRETO_ESCURO_1.PNG
										"064",; //POSICAO X NA ESTRUTURA
										"014"; //POSICAO Y NA ESTRUTURA
									},;
									{;
										"1",; //CODIGO DA IMAGEM DO PNEU   EX: NG_PNEU_PRETO_ESCURO_1.PNG
										"064",; //POSICAO X NA ESTRUTURA
										"040"; //POSICAO Y NA ESTRUTURA
									},;
									{;
										"1",; //CODIGO DA IMAGEM DO PNEU   EX: NG_PNEU_PRETO_ESCURO_1.PNG
										"064",; //POSICAO X NA ESTRUTURA
										"089"; //POSICAO Y NA ESTRUTURA
									},;
									{;
										"1",; //CODIGO DA IMAGEM DO PNEU   EX: NG_PNEU_PRETO_ESCURO_1.PNG
										"064",; //POSICAO X NA ESTRUTURA
										"116"; //POSICAO Y NA ESTRUTURA
									},;
									{;
										"1",; //CODIGO DA IMAGEM DO PNEU   EX: NG_PNEU_PRETO_ESCURO_1.PNG
										"064",; //POSICAO X NA ESTRUTURA
										"160"; //POSICAO Y NA ESTRUTURA
									},;
									{;
										"1",; //CODIGO DA IMAGEM DO PNEU   EX: NG_PNEU_PRETO_ESCURO_1.PNG
										"064",; //POSICAO X NA ESTRUTURA
										"187"; //POSICAO Y NA ESTRUTURA
									},;
									{;
										"1",; //CODIGO DA IMAGEM DO PNEU   EX: NG_PNEU_PRETO_ESCURO_1.PNG
										"064",; //POSICAO X NA ESTRUTURA
										"235"; //POSICAO Y NA ESTRUTURA
									},;
									{;
										"1",; //CODIGO DA IMAGEM DO PNEU   EX: NG_PNEU_PRETO_ESCURO_1.PNG
										"064",; //POSICAO X NA ESTRUTURA
										"262"; //POSICAO Y NA ESTRUTURA
									};
								},;
								{; //SEGUNDO EIXO
									{;
										"1",; //CODIGO DA IMAGEM DO PNEU   EX: NG_PNEU_PRETO_ESCURO_1.PNG
										"165",; //POSICAO X NA ESTRUTURA
										"014"; //POSICAO Y NA ESTRUTURA
									},;
									{;
										"1",; //CODIGO DA IMAGEM DO PNEU   EX: NG_PNEU_PRETO_ESCURO_1.PNG
										"165",; //POSICAO X NA ESTRUTURA
										"040"; //POSICAO Y NA ESTRUTURA
									},;
									{;
										"1",; //CODIGO DA IMAGEM DO PNEU   EX: NG_PNEU_PRETO_ESCURO_1.PNG
										"165",; //POSICAO X NA ESTRUTURA
										"089"; //POSICAO Y NA ESTRUTURA
									},;
									{;
										"1",; //CODIGO DA IMAGEM DO PNEU   EX: NG_PNEU_PRETO_ESCURO_1.PNG
										"165",; //POSICAO X NA ESTRUTURA
										"116"; //POSICAO Y NA ESTRUTURA
									},;
									{;
										"1",; //CODIGO DA IMAGEM DO PNEU   EX: NG_PNEU_PRETO_ESCURO_1.PNG
										"165",; //POSICAO X NA ESTRUTURA
										"160"; //POSICAO Y NA ESTRUTURA
									},;
									{;
										"1",; //CODIGO DA IMAGEM DO PNEU   EX: NG_PNEU_PRETO_ESCURO_1.PNG
										"165",; //POSICAO X NA ESTRUTURA
										"187"; //POSICAO Y NA ESTRUTURA
									},;
									{;
										"1",; //CODIGO DA IMAGEM DO PNEU   EX: NG_PNEU_PRETO_ESCURO_1.PNG
										"165",; //POSICAO X NA ESTRUTURA
										"235"; //POSICAO Y NA ESTRUTURA
									},;
									{;
										"1",; //CODIGO DA IMAGEM DO PNEU   EX: NG_PNEU_PRETO_ESCURO_1.PNG
										"165",; //POSICAO X NA ESTRUTURA
										"262"; //POSICAO Y NA ESTRUTURA
									};
								},;
								{; //TERCEIRO EIXO
									{;
										"1",; //CODIGO DA IMAGEM DO PNEU   EX: NG_PNEU_PRETO_ESCURO_1.PNG
										"265",; //POSICAO X NA ESTRUTURA
										"014"; //POSICAO Y NA ESTRUTURA
									},;
									{;
										"1",; //CODIGO DA IMAGEM DO PNEU   EX: NG_PNEU_PRETO_ESCURO_1.PNG
										"265",; //POSICAO X NA ESTRUTURA
										"040"; //POSICAO Y NA ESTRUTURA
									},;
									{;
										"1",; //CODIGO DA IMAGEM DO PNEU   EX: NG_PNEU_PRETO_ESCURO_1.PNG
										"265",; //POSICAO X NA ESTRUTURA
										"089"; //POSICAO Y NA ESTRUTURA
									},;
									{;
										"1",; //CODIGO DA IMAGEM DO PNEU   EX: NG_PNEU_PRETO_ESCURO_1.PNG
										"265",; //POSICAO X NA ESTRUTURA
										"116"; //POSICAO Y NA ESTRUTURA
									},;
									{;
										"1",; //CODIGO DA IMAGEM DO PNEU   EX: NG_PNEU_PRETO_ESCURO_1.PNG
										"265",; //POSICAO X NA ESTRUTURA
										"160"; //POSICAO Y NA ESTRUTURA
									},;
									{;
										"1",; //CODIGO DA IMAGEM DO PNEU   EX: NG_PNEU_PRETO_ESCURO_1.PNG
										"265",; //POSICAO X NA ESTRUTURA
										"187"; //POSICAO Y NA ESTRUTURA
									},;
									{;
										"1",; //CODIGO DA IMAGEM DO PNEU   EX: NG_PNEU_PRETO_ESCURO_1.PNG
										"265",; //POSICAO X NA ESTRUTURA
										"235"; //POSICAO Y NA ESTRUTURA
									},;
									{;
										"1",; //CODIGO DA IMAGEM DO PNEU   EX: NG_PNEU_PRETO_ESCURO_1.PNG
										"265",; //POSICAO X NA ESTRUTURA
										"262"; //POSICAO Y NA ESTRUTURA
									};
								},;
								{; //QUARTO EIXO
									{;
										"1",; //CODIGO DA IMAGEM DO PNEU   EX: NG_PNEU_PRETO_ESCURO_1.PNG
										"365",; //POSICAO X NA ESTRUTURA
										"014"; //POSICAO Y NA ESTRUTURA
									},;
									{;
										"1",; //CODIGO DA IMAGEM DO PNEU   EX: NG_PNEU_PRETO_ESCURO_1.PNG
										"365",; //POSICAO X NA ESTRUTURA
										"040"; //POSICAO Y NA ESTRUTURA
									},;
									{;
										"1",; //CODIGO DA IMAGEM DO PNEU   EX: NG_PNEU_PRETO_ESCURO_1.PNG
										"365",; //POSICAO X NA ESTRUTURA
										"089"; //POSICAO Y NA ESTRUTURA
									},;
									{;
										"1",; //CODIGO DA IMAGEM DO PNEU   EX: NG_PNEU_PRETO_ESCURO_1.PNG
										"365",; //POSICAO X NA ESTRUTURA
										"116"; //POSICAO Y NA ESTRUTURA
									},;
									{;
										"1",; //CODIGO DA IMAGEM DO PNEU   EX: NG_PNEU_PRETO_ESCURO_1.PNG
										"365",; //POSICAO X NA ESTRUTURA
										"160"; //POSICAO Y NA ESTRUTURA
									},;
									{;
										"1",; //CODIGO DA IMAGEM DO PNEU   EX: NG_PNEU_PRETO_ESCURO_1.PNG
										"365",; //POSICAO X NA ESTRUTURA
										"187"; //POSICAO Y NA ESTRUTURA
									},;
									{;
										"1",; //CODIGO DA IMAGEM DO PNEU   EX: NG_PNEU_PRETO_ESCURO_1.PNG
										"365",; //POSICAO X NA ESTRUTURA
										"235"; //POSICAO Y NA ESTRUTURA
									},;
									{;
										"1",; //CODIGO DA IMAGEM DO PNEU   EX: NG_PNEU_PRETO_ESCURO_1.PNG
										"365",; //POSICAO X NA ESTRUTURA
										"262"; //POSICAO Y NA ESTRUTURA
									};
								},;
								{; //QUINTO EIXO
									{;
										"1",; //CODIGO DA IMAGEM DO PNEU   EX: NG_PNEU_PRETO_ESCURO_1.PNG
										"465",; //POSICAO X NA ESTRUTURA
										"014"; //POSICAO Y NA ESTRUTURA
									},;
									{;
										"1",; //CODIGO DA IMAGEM DO PNEU   EX: NG_PNEU_PRETO_ESCURO_1.PNG
										"465",; //POSICAO X NA ESTRUTURA
										"040"; //POSICAO Y NA ESTRUTURA
									},;
									{;
										"1",; //CODIGO DA IMAGEM DO PNEU   EX: NG_PNEU_PRETO_ESCURO_1.PNG
										"465",; //POSICAO X NA ESTRUTURA
										"089"; //POSICAO Y NA ESTRUTURA
									},;
									{;
										"1",; //CODIGO DA IMAGEM DO PNEU   EX: NG_PNEU_PRETO_ESCURO_1.PNG
										"465",; //POSICAO X NA ESTRUTURA
										"116"; //POSICAO Y NA ESTRUTURA
									},;
									{;
										"1",; //CODIGO DA IMAGEM DO PNEU   EX: NG_PNEU_PRETO_ESCURO_1.PNG
										"465",; //POSICAO X NA ESTRUTURA
										"160"; //POSICAO Y NA ESTRUTURA
									},;
									{;
										"1",; //CODIGO DA IMAGEM DO PNEU   EX: NG_PNEU_PRETO_ESCURO_1.PNG
										"465",; //POSICAO X NA ESTRUTURA
										"187"; //POSICAO Y NA ESTRUTURA
									},;
									{;
										"1",; //CODIGO DA IMAGEM DO PNEU   EX: NG_PNEU_PRETO_ESCURO_1.PNG
										"465",; //POSICAO X NA ESTRUTURA
										"235"; //POSICAO Y NA ESTRUTURA
									},;
									{;
										"1",; //CODIGO DA IMAGEM DO PNEU   EX: NG_PNEU_PRETO_ESCURO_1.PNG
										"465",; //POSICAO X NA ESTRUTURA
										"262"; //POSICAO Y NA ESTRUTURA
									};
								},;
								{; //SEXTO EIXO
									{;
										"1",; //CODIGO DA IMAGEM DO PNEU   EX: NG_PNEU_PRETO_ESCURO_1.PNG
										"565",; //POSICAO X NA ESTRUTURA
										"014"; //POSICAO Y NA ESTRUTURA
									},;
									{;
										"1",; //CODIGO DA IMAGEM DO PNEU   EX: NG_PNEU_PRETO_ESCURO_1.PNG
										"565",; //POSICAO X NA ESTRUTURA
										"040"; //POSICAO Y NA ESTRUTURA
									},;
									{;
										"1",; //CODIGO DA IMAGEM DO PNEU   EX: NG_PNEU_PRETO_ESCURO_1.PNG
										"565",; //POSICAO X NA ESTRUTURA
										"089"; //POSICAO Y NA ESTRUTURA
									},;
									{;
										"1",; //CODIGO DA IMAGEM DO PNEU   EX: NG_PNEU_PRETO_ESCURO_1.PNG
										"565",; //POSICAO X NA ESTRUTURA
										"116"; //POSICAO Y NA ESTRUTURA
									},;
									{;
										"1",; //CODIGO DA IMAGEM DO PNEU   EX: NG_PNEU_PRETO_ESCURO_1.PNG
										"565",; //POSICAO X NA ESTRUTURA
										"160"; //POSICAO Y NA ESTRUTURA
									},;
									{;
										"1",; //CODIGO DA IMAGEM DO PNEU   EX: NG_PNEU_PRETO_ESCURO_1.PNG
										"565",; //POSICAO X NA ESTRUTURA
										"187"; //POSICAO Y NA ESTRUTURA
									},;
									{;
										"1",; //CODIGO DA IMAGEM DO PNEU   EX: NG_PNEU_PRETO_ESCURO_1.PNG
										"565",; //POSICAO X NA ESTRUTURA
										"235"; //POSICAO Y NA ESTRUTURA
									},;
									{;
										"1",; //CODIGO DA IMAGEM DO PNEU   EX: NG_PNEU_PRETO_ESCURO_1.PNG
										"565",; //POSICAO X NA ESTRUTURA
										"262"; //POSICAO Y NA ESTRUTURA
									};
								},;
								{; //SETIMO EIXO
									{;
										"1",; //CODIGO DA IMAGEM DO PNEU   EX: NG_PNEU_PRETO_ESCURO_1.PNG
										"665",; //POSICAO X NA ESTRUTURA
										"014"; //POSICAO Y NA ESTRUTURA
									},;
									{;
										"1",; //CODIGO DA IMAGEM DO PNEU   EX: NG_PNEU_PRETO_ESCURO_1.PNG
										"665",; //POSICAO X NA ESTRUTURA
										"040"; //POSICAO Y NA ESTRUTURA
									},;
									{;
										"1",; //CODIGO DA IMAGEM DO PNEU   EX: NG_PNEU_PRETO_ESCURO_1.PNG
										"665",; //POSICAO X NA ESTRUTURA
										"089"; //POSICAO Y NA ESTRUTURA
									},;
									{;
										"1",; //CODIGO DA IMAGEM DO PNEU   EX: NG_PNEU_PRETO_ESCURO_1.PNG
										"665",; //POSICAO X NA ESTRUTURA
										"116"; //POSICAO Y NA ESTRUTURA
									},;
									{;
										"1",; //CODIGO DA IMAGEM DO PNEU   EX: NG_PNEU_PRETO_ESCURO_1.PNG
										"665",; //POSICAO X NA ESTRUTURA
										"160"; //POSICAO Y NA ESTRUTURA
									},;
									{;
										"1",; //CODIGO DA IMAGEM DO PNEU   EX: NG_PNEU_PRETO_ESCURO_1.PNG
										"665",; //POSICAO X NA ESTRUTURA
										"187"; //POSICAO Y NA ESTRUTURA
									},;
									{;
										"1",; //CODIGO DA IMAGEM DO PNEU   EX: NG_PNEU_PRETO_ESCURO_1.PNG
										"665",; //POSICAO X NA ESTRUTURA
										"235"; //POSICAO Y NA ESTRUTURA
									},;
									{;
										"1",; //CODIGO DA IMAGEM DO PNEU   EX: NG_PNEU_PRETO_ESCURO_1.PNG
										"665",; //POSICAO X NA ESTRUTURA
										"262"; //POSICAO Y NA ESTRUTURA
									};
								};
							},;
							{; //STEPES
								{;
									{;
										"2",; //CODIGO DA IMAGEM DO PNEU   EX: NG_PNEU_PRETO_ESCURO_1.PNG
										"-3",; //POSICAO X NA ESTRUTURA
										"39"; //POSICAO Y NA ESTRUTURA
									},;
									{;
										"2",; //CODIGO DA IMAGEM DO PNEU   EX: NG_PNEU_PRETO_ESCURO_1.PNG
										"-3",; //POSICAO X NA ESTRUTURA
										"186"; //POSICAO Y NA ESTRUTURA
									},;
									{;
										"2",; //CODIGO DA IMAGEM DO PNEU   EX: NG_PNEU_PRETO_ESCURO_1.PNG
										"733",; //POSICAO X NA ESTRUTURA
										"39"; //POSICAO Y NA ESTRUTURA
									},;
									{;
										"2",; //CODIGO DA IMAGEM DO PNEU   EX: NG_PNEU_PRETO_ESCURO_1.PNG
										"733",; //POSICAO X NA ESTRUTURA
										"186"; //POSICAO Y NA ESTRUTURA
									};
								};
							};
				};
		)

		*********************************************************************************
		aAdd(aEstruTemp,{	"31",; //CODIGO DA IMAGEM DA ESTRUTURA   EX: NG_ESTRUTURA_1.PNG
							"602",; //TAMANHO X EM PIXEL
							"196",; //TAMANHO Y EM PIXEL
							{;
								{;
									{;
										"1",; //CODIGO DA IMAGEM DO PNEU   EX: NG_PNEU_PRETO_ESCURO_1.PNG
										"068",; //POSICAO X NA ESTRUTURA
										"011"; //POSICAO Y NA ESTRUTURA
									},;
									{;
										"1",; //CODIGO DA IMAGEM DO PNEU   EX: NG_PNEU_PRETO_ESCURO_1.PNG
										"068",; //POSICAO X NA ESTRUTURA
										"156"; //POSICAO Y NA ESTRUTURA
									};
								},;
								{; //SEGUNDO EIXO
									{;
										"1",; //CODIGO DA IMAGEM DO PNEU   EX: NG_PNEU_PRETO_ESCURO_1.PNG
										"359",; //POSICAO X NA ESTRUTURA
										"002"; //POSICAO Y NA ESTRUTURA
									},;
									{;
										"1",; //CODIGO DA IMAGEM DO PNEU   EX: NG_PNEU_PRETO_ESCURO_1.PNG
										"359",; //POSICAO X NA ESTRUTURA
										"029"; //POSICAO Y NA ESTRUTURA
									},;
									{;
										"1",; //CODIGO DA IMAGEM DO PNEU   EX: NG_PNEU_PRETO_ESCURO_1.PNG
										"359",; //POSICAO X NA ESTRUTURA
										"133"; //POSICAO Y NA ESTRUTURA
									},;
									{;
										"1",; //CODIGO DA IMAGEM DO PNEU   EX: NG_PNEU_PRETO_ESCURO_1.PNG
										"359",; //POSICAO X NA ESTRUTURA
										"158"; //POSICAO Y NA ESTRUTURA
									};
								},;
								{; //TERCEIRO EIXO
									{;
										"1",; //CODIGO DA IMAGEM DO PNEU   EX: NG_PNEU_PRETO_ESCURO_1.PNG
										"478",; //POSICAO X NA ESTRUTURA
										"002"; //POSICAO Y NA ESTRUTURA
									},;
									{;
										"1",; //CODIGO DA IMAGEM DO PNEU   EX: NG_PNEU_PRETO_ESCURO_1.PNG
										"478",; //POSICAO X NA ESTRUTURA
										"029"; //POSICAO Y NA ESTRUTURA
									},;
									{;
										"1",; //CODIGO DA IMAGEM DO PNEU   EX: NG_PNEU_PRETO_ESCURO_1.PNG
										"478",; //POSICAO X NA ESTRUTURA
										"133"; //POSICAO Y NA ESTRUTURA
									},;
									{;
										"1",; //CODIGO DA IMAGEM DO PNEU   EX: NG_PNEU_PRETO_ESCURO_1.PNG
										"478",; //POSICAO X NA ESTRUTURA
										"158"; //POSICAO Y NA ESTRUTURA
									};
								};
							},;
							{; //STEPES
								{;
									{;
										"2",; //CODIGO DA IMAGEM DO PNEU   EX: NG_PNEU_PRETO_ESCURO_1.PNG
										"250",; //POSICAO X NA ESTRUTURA
										"025"; //POSICAO Y NA ESTRUTURA
									},;
									{;
										"2",; //CODIGO DA IMAGEM DO PNEU   EX: NG_PNEU_PRETO_ESCURO_1.PNG
										"250",; //POSICAO X NA ESTRUTURA
										"095"; //POSICAO Y NA ESTRUTURA
									};
								};
							};
						};
		)

		*********************************************************************************
		aAdd(aEstruTemp,{	"32",; //CODIGO DA IMAGEM DA ESTRUTURA   EX: NG_ESTRUTURA_1.PNG
								"303",; //TAMANHO X EM PIXEL
								"176",; //TAMANHO Y EM PIXEL
								{;
									{;
										{;
											"3",; //CODIGO DA IMAGEM DO PNEU   EX: NG_PNEU_PRETO_ESCURO_1.PNG
											"012",; //POSICAO X NA ESTRUTURA
											"077"; //POSICAO Y NA ESTRUTURA
										};
									},;
									{; //SEGUNDO EIXO
										{;
											"3",; //CODIGO DA IMAGEM DO PNEU   EX: NG_PNEU_PRETO_ESCURO_1.PNG
											"200",; //POSICAO X NA ESTRUTURA
											"077"; //POSICAO Y NA ESTRUTURA
										};
									};
								},;
								{; //STEPES
									{;
									};
								};
							};
		)

	*********************************************************************************
	aAdd(aEstruTemp,{	"33",; //CODIGO DA IMAGEM DA ESTRUTURA   EX: NG_ESTRUTURA_1.PNG
							"649",; //TAMANHO X EM PIXEL
							"196",; //TAMANHO Y EM PIXEL
							{;
								{; //PRIMEIRO EIXO
									{;
										"1",; //CODIGO DA IMAGEM DO PNEU   EX: NG_PNEU_PRETO_ESCURO_1.PNG
										"028",; //POSICAO X NA ESTRUTURA
										"011"; //POSICAO Y NA ESTRUTURA
									},;
									{;
										"1",; //CODIGO DA IMAGEM DO PNEU   EX: NG_PNEU_PRETO_ESCURO_1.PNG
										"028",; //POSICAO X NA ESTRUTURA
										"156"; //POSICAO Y NA ESTRUTURA
									};
								},;
								{; //SEGUNDO EIXO
									{;
										"1",; //CODIGO DA IMAGEM DO PNEU   EX: NG_PNEU_PRETO_ESCURO_1.PNG
										"136",; //POSICAO X NA ESTRUTURA
										"011"; //POSICAO Y NA ESTRUTURA
									},;
									{;
										"1",; //CODIGO DA IMAGEM DO PNEU   EX: NG_PNEU_PRETO_ESCURO_1.PNG
										"136",; //POSICAO X NA ESTRUTURA
										"156"; //POSICAO Y NA ESTRUTURA
									};
								},;
								{; //TERCEIRO EIXO
									{;
										"1",; //CODIGO DA IMAGEM DO PNEU   EX: NG_PNEU_PRETO_ESCURO_1.PNG
										"319",; //POSICAO X NA ESTRUTURA
										"004"; //POSICAO Y NA ESTRUTURA
									},;
									{;
										"1",; //CODIGO DA IMAGEM DO PNEU   EX: NG_PNEU_PRETO_ESCURO_1.PNG
										"319",; //POSICAO X NA ESTRUTURA
										"029"; //POSICAO Y NA ESTRUTURA
									},;
									{;
										"1",; //CODIGO DA IMAGEM DO PNEU   EX: NG_PNEU_PRETO_ESCURO_1.PNG
										"319",; //POSICAO X NA ESTRUTURA
										"135"; //POSICAO Y NA ESTRUTURA
									},;
									{;
										"1",; //CODIGO DA IMAGEM DO PNEU   EX: NG_PNEU_PRETO_ESCURO_1.PNG
										"319",; //POSICAO X NA ESTRUTURA
										"160"; //POSICAO Y NA ESTRUTURA
									};
								},;
								{; //QUARTO EIXO
									{;
										"1",; //CODIGO DA IMAGEM DO PNEU   EX: NG_PNEU_PRETO_ESCURO_1.PNG
										"435",; //POSICAO X NA ESTRUTURA
										"004"; //POSICAO Y NA ESTRUTURA
									},;
									{;
										"1",; //CODIGO DA IMAGEM DO PNEU   EX: NG_PNEU_PRETO_ESCURO_1.PNG
										"435",; //POSICAO X NA ESTRUTURA
										"029"; //POSICAO Y NA ESTRUTURA
									},;
									{;
										"1",; //CODIGO DA IMAGEM DO PNEU   EX: NG_PNEU_PRETO_ESCURO_1.PNG
										"435",; //POSICAO X NA ESTRUTURA
										"135"; //POSICAO Y NA ESTRUTURA
									},;
									{;
										"1",; //CODIGO DA IMAGEM DO PNEU   EX: NG_PNEU_PRETO_ESCURO_1.PNG
										"435",; //POSICAO X NA ESTRUTURA
										"160"; //POSICAO Y NA ESTRUTURA
									};
								};
							},;
							{; //STEPES
								{;
									{;
										"2",; //CODIGO DA IMAGEM DO PNEU   EX: NG_PNEU_PRETO_ESCURO_1.PNG
										"545",; //POSICAO X NA ESTRUTURA
										"025"; //POSICAO Y NA ESTRUTURA
									},;
									{;
										"2",; //CODIGO DA IMAGEM DO PNEU   EX: NG_PNEU_PRETO_ESCURO_1.PNG
										"545",; //POSICAO X NA ESTRUTURA
										"095"; //POSICAO Y NA ESTRUTURA
									};
								};
							};
						};
		)

	*********************************************************************************
	aAdd(aEstruTemp,{	"34",; //CODIGO DA IMAGEM DA ESTRUTURA   EX: NG_ESTRUTURA_1.PNG
							"213",; //TAMANHO X EM PIXEL
							"305",; //TAMANHO Y EM PIXEL
							{;
								{;	//PRIMEIRO EIXO
									{;
										"1",; //CODIGO DA IMAGEM DO PNEU   EX: NG_PNEU_PRETO_ESCURO_1.PNG
										"064",; //POSICAO X NA ESTRUTURA
										"014"; //POSICAO Y NA ESTRUTURA
									},;
									{;
										"1",; //CODIGO DA IMAGEM DO PNEU   EX: NG_PNEU_PRETO_ESCURO_1.PNG
										"064",; //POSICAO X NA ESTRUTURA
										"040"; //POSICAO Y NA ESTRUTURA
									},;
									{;
										"1",; //CODIGO DA IMAGEM DO PNEU   EX: NG_PNEU_PRETO_ESCURO_1.PNG
										"064",; //POSICAO X NA ESTRUTURA
										"089"; //POSICAO Y NA ESTRUTURA
									},;
									{;
										"1",; //CODIGO DA IMAGEM DO PNEU   EX: NG_PNEU_PRETO_ESCURO_1.PNG
										"064",; //POSICAO X NA ESTRUTURA
										"116"; //POSICAO Y NA ESTRUTURA
									},;
									{;
										"1",; //CODIGO DA IMAGEM DO PNEU   EX: NG_PNEU_PRETO_ESCURO_1.PNG
										"064",; //POSICAO X NA ESTRUTURA
										"160"; //POSICAO Y NA ESTRUTURA
									},;
									{;
										"1",; //CODIGO DA IMAGEM DO PNEU   EX: NG_PNEU_PRETO_ESCURO_1.PNG
										"064",; //POSICAO X NA ESTRUTURA
										"187"; //POSICAO Y NA ESTRUTURA
									},;
									{;
										"1",; //CODIGO DA IMAGEM DO PNEU   EX: NG_PNEU_PRETO_ESCURO_1.PNG
										"064",; //POSICAO X NA ESTRUTURA
										"235"; //POSICAO Y NA ESTRUTURA
									},;
									{;
										"1",; //CODIGO DA IMAGEM DO PNEU   EX: NG_PNEU_PRETO_ESCURO_1.PNG
										"064",; //POSICAO X NA ESTRUTURA
										"262"; //POSICAO Y NA ESTRUTURA
									};
								};
							},;
							{; //STEPES
								{;
									{;
										"2",; //CODIGO DA IMAGEM DO PNEU   EX: NG_PNEU_PRETO_ESCURO_1.PNG
										"-3",; //POSICAO X NA ESTRUTURA
										"39"; //POSICAO Y NA ESTRUTURA
									},;
									{;
										"2",; //CODIGO DA IMAGEM DO PNEU   EX: NG_PNEU_PRETO_ESCURO_1.PNG
										"-3",; //POSICAO X NA ESTRUTURA
										"186"; //POSICAO Y NA ESTRUTURA
									},;
									{;
										"2",; //CODIGO DA IMAGEM DO PNEU   EX: NG_PNEU_PRETO_ESCURO_1.PNG
										"233",; //POSICAO X NA ESTRUTURA
										"39"; //POSICAO Y NA ESTRUTURA
									},;
									{;
										"2",; //CODIGO DA IMAGEM DO PNEU   EX: NG_PNEU_PRETO_ESCURO_1.PNG
										"233",; //POSICAO X NA ESTRUTURA
										"186"; //POSICAO Y NA ESTRUTURA
									};
								};
							};
				};
		)

	*********************************************************************************
	aAdd(aEstruTemp,{	"35",; //CODIGO DA IMAGEM DA ESTRUTURA   EX: NG_ESTRUTURA_1.PNG
							"857",; //TAMANHO X EM PIXEL
							"159",; //TAMANHO Y EM PIXEL
							{;
								{;	//PRIMEIRO EIXO
									{;
										"1",; //CODIGO DA IMAGEM DO PNEU   EX: NG_PNEU_PRETO_ESCURO_1.PNG
										"025",; //POSICAO X NA ESTRUTURA
										"012"; //POSICAO Y NA ESTRUTURA
									},;
									{;
										"1",; //CODIGO DA IMAGEM DO PNEU   EX: NG_PNEU_PRETO_ESCURO_1.PNG
										"025",; //POSICAO X NA ESTRUTURA
										"116"; //POSICAO Y NA ESTRUTURA
									};
								},;
								{; //SEGUNDO EIXO
									{;
										"1",; //CODIGO DA IMAGEM DO PNEU   EX: NG_PNEU_PRETO_ESCURO_1.PNG
										"123",; //POSICAO X NA ESTRUTURA
										"012"; //POSICAO Y NA ESTRUTURA
									},;
									{;
										"1",; //CODIGO DA IMAGEM DO PNEU   EX: NG_PNEU_PRETO_ESCURO_1.PNG
										"123",; //POSICAO X NA ESTRUTURA
										"116"; //POSICAO Y NA ESTRUTURA
									};
								},;
								{; //TERCEIRO EIXO
									{;
										"1",; //CODIGO DA IMAGEM DO PNEU   EX: NG_PNEU_PRETO_ESCURO_1.PNG
										"223",; //POSICAO X NA ESTRUTURA
										"012"; //POSICAO Y NA ESTRUTURA
									},;
									{;
										"1",; //CODIGO DA IMAGEM DO PNEU   EX: NG_PNEU_PRETO_ESCURO_1.PNG
										"223",; //POSICAO X NA ESTRUTURA
										"116"; //POSICAO Y NA ESTRUTURA
									};
								},;
								{; //QUARTO EIXO
									{;
										"1",; //CODIGO DA IMAGEM DO PNEU   EX: NG_PNEU_PRETO_ESCURO_1.PNG
										"323",; //POSICAO X NA ESTRUTURA
										"012"; //POSICAO Y NA ESTRUTURA
									},;
									{;
										"1",; //CODIGO DA IMAGEM DO PNEU   EX: NG_PNEU_PRETO_ESCURO_1.PNG
										"323",; //POSICAO X NA ESTRUTURA
										"116"; //POSICAO Y NA ESTRUTURA
									};
								},;
								{; //QUINTO EIXO
									{;
										"1",; //CODIGO DA IMAGEM DO PNEU   EX: NG_PNEU_PRETO_ESCURO_1.PNG
										"423",; //POSICAO X NA ESTRUTURA
										"012"; //POSICAO Y NA ESTRUTURA
									},;
									{;
										"1",; //CODIGO DA IMAGEM DO PNEU   EX: NG_PNEU_PRETO_ESCURO_1.PNG
										"423",; //POSICAO X NA ESTRUTURA
										"116"; //POSICAO Y NA ESTRUTURA
									};
								},;
								{; //SEXTO EIXO
									{;
										"1",; //CODIGO DA IMAGEM DO PNEU   EX: NG_PNEU_PRETO_ESCURO_1.PNG
										"523",; //POSICAO X NA ESTRUTURA
										"012"; //POSICAO Y NA ESTRUTURA
									},;
									{;
										"1",; //CODIGO DA IMAGEM DO PNEU   EX: NG_PNEU_PRETO_ESCURO_1.PNG
										"523",; //POSICAO X NA ESTRUTURA
										"116"; //POSICAO Y NA ESTRUTURA
									};
								},;
								{; //SETIMO EIXO
									{;
										"1",; //CODIGO DA IMAGEM DO PNEU   EX: NG_PNEU_PRETO_ESCURO_1.PNG
										"623",; //POSICAO X NA ESTRUTURA
										"012"; //POSICAO Y NA ESTRUTURA
									},;
									{;
										"1",; //CODIGO DA IMAGEM DO PNEU   EX: NG_PNEU_PRETO_ESCURO_1.PNG
										"623",; //POSICAO X NA ESTRUTURA
										"116"; //POSICAO Y NA ESTRUTURA
									};
								},;
								{; //OITAVO EIXO
									{;
										"1",; //CODIGO DA IMAGEM DO PNEU   EX: NG_PNEU_PRETO_ESCURO_1.PNG
										"723",; //POSICAO X NA ESTRUTURA
										"012"; //POSICAO Y NA ESTRUTURA
									},;
									{;
										"1",; //CODIGO DA IMAGEM DO PNEU   EX: NG_PNEU_PRETO_ESCURO_1.PNG
										"723",; //POSICAO X NA ESTRUTURA
										"116"; //POSICAO Y NA ESTRUTURA
									};
								};
							},;
							{; //STEPES
								{;
									{;
										"2",; //CODIGO DA IMAGEM DO PNEU   EX: NG_PNEU_PRETO_ESCURO_1.PNG
										"790",; //POSICAO X NA ESTRUTURA
										"042"; //POSICAO Y NA ESTRUTURA
									};
								};
							};
				};
		)

	*********************************************************************************
	aAdd(aEstruTemp,{	"36",; //CODIGO DA IMAGEM DA ESTRUTURA   EX: NG_ESTRUTURA_1.PNG
							"754",; //TAMANHO X EM PIXEL
							"159",; //TAMANHO Y EM PIXEL
							{;
								{;	//PRIMEIRO EIXO
									{;
										"1",; //CODIGO DA IMAGEM DO PNEU   EX: NG_PNEU_PRETO_ESCURO_1.PNG
										"025",; //POSICAO X NA ESTRUTURA
										"012"; //POSICAO Y NA ESTRUTURA
									},;
									{;
										"1",; //CODIGO DA IMAGEM DO PNEU   EX: NG_PNEU_PRETO_ESCURO_1.PNG
										"025",; //POSICAO X NA ESTRUTURA
										"116"; //POSICAO Y NA ESTRUTURA
									};
								},;
								{; //SEGUNDO EIXO
									{;
										"1",; //CODIGO DA IMAGEM DO PNEU   EX: NG_PNEU_PRETO_ESCURO_1.PNG
										"123",; //POSICAO X NA ESTRUTURA
										"012"; //POSICAO Y NA ESTRUTURA
									},;
									{;
										"1",; //CODIGO DA IMAGEM DO PNEU   EX: NG_PNEU_PRETO_ESCURO_1.PNG
										"123",; //POSICAO X NA ESTRUTURA
										"116"; //POSICAO Y NA ESTRUTURA
									};
								},;
								{; //TERCEIRO EIXO
									{;
										"1",; //CODIGO DA IMAGEM DO PNEU   EX: NG_PNEU_PRETO_ESCURO_1.PNG
										"223",; //POSICAO X NA ESTRUTURA
										"012"; //POSICAO Y NA ESTRUTURA
									},;
									{;
										"1",; //CODIGO DA IMAGEM DO PNEU   EX: NG_PNEU_PRETO_ESCURO_1.PNG
										"223",; //POSICAO X NA ESTRUTURA
										"116"; //POSICAO Y NA ESTRUTURA
									};
								},;
								{; //QUARTO EIXO
									{;
										"1",; //CODIGO DA IMAGEM DO PNEU   EX: NG_PNEU_PRETO_ESCURO_1.PNG
										"323",; //POSICAO X NA ESTRUTURA
										"012"; //POSICAO Y NA ESTRUTURA
									},;
									{;
										"1",; //CODIGO DA IMAGEM DO PNEU   EX: NG_PNEU_PRETO_ESCURO_1.PNG
										"323",; //POSICAO X NA ESTRUTURA
										"116"; //POSICAO Y NA ESTRUTURA
									};
								},;
								{; //QUINTO EIXO
									{;
										"1",; //CODIGO DA IMAGEM DO PNEU   EX: NG_PNEU_PRETO_ESCURO_1.PNG
										"423",; //POSICAO X NA ESTRUTURA
										"012"; //POSICAO Y NA ESTRUTURA
									},;
									{;
										"1",; //CODIGO DA IMAGEM DO PNEU   EX: NG_PNEU_PRETO_ESCURO_1.PNG
										"423",; //POSICAO X NA ESTRUTURA
										"116"; //POSICAO Y NA ESTRUTURA
									};
								},;
								{; //SEXTO EIXO
									{;
										"1",; //CODIGO DA IMAGEM DO PNEU   EX: NG_PNEU_PRETO_ESCURO_1.PNG
										"523",; //POSICAO X NA ESTRUTURA
										"012"; //POSICAO Y NA ESTRUTURA
									},;
									{;
										"1",; //CODIGO DA IMAGEM DO PNEU   EX: NG_PNEU_PRETO_ESCURO_1.PNG
										"523",; //POSICAO X NA ESTRUTURA
										"116"; //POSICAO Y NA ESTRUTURA
									};
								},;
								{; //SETIMO EIXO
									{;
										"1",; //CODIGO DA IMAGEM DO PNEU   EX: NG_PNEU_PRETO_ESCURO_1.PNG
										"623",; //POSICAO X NA ESTRUTURA
										"012"; //POSICAO Y NA ESTRUTURA
									},;
									{;
										"1",; //CODIGO DA IMAGEM DO PNEU   EX: NG_PNEU_PRETO_ESCURO_1.PNG
										"623",; //POSICAO X NA ESTRUTURA
										"116"; //POSICAO Y NA ESTRUTURA
									};
								};
							},;
							{; //STEPES
								{;
									{;
										"2",; //CODIGO DA IMAGEM DO PNEU   EX: NG_PNEU_PRETO_ESCURO_1.PNG
										"690",; //POSICAO X NA ESTRUTURA
										"042"; //POSICAO Y NA ESTRUTURA
									};
								};
							};
				};
		)

	*********************************************************************************
	aAdd(aEstruTemp,{	"37",; //CODIGO DA IMAGEM DA ESTRUTURA   EX: NG_ESTRUTURA_1.PNG
							"653",; //TAMANHO X EM PIXEL
							"159",; //TAMANHO Y EM PIXEL
							{;
								{;	//PRIMEIRO EIXO
									{;
										"1",; //CODIGO DA IMAGEM DO PNEU   EX: NG_PNEU_PRETO_ESCURO_1.PNG
										"025",; //POSICAO X NA ESTRUTURA
										"012"; //POSICAO Y NA ESTRUTURA
									},;
									{;
										"1",; //CODIGO DA IMAGEM DO PNEU   EX: NG_PNEU_PRETO_ESCURO_1.PNG
										"025",; //POSICAO X NA ESTRUTURA
										"116"; //POSICAO Y NA ESTRUTURA
									};
								},;
								{; //SEGUNDO EIXO
									{;
										"1",; //CODIGO DA IMAGEM DO PNEU   EX: NG_PNEU_PRETO_ESCURO_1.PNG
										"123",; //POSICAO X NA ESTRUTURA
										"012"; //POSICAO Y NA ESTRUTURA
									},;
									{;
										"1",; //CODIGO DA IMAGEM DO PNEU   EX: NG_PNEU_PRETO_ESCURO_1.PNG
										"123",; //POSICAO X NA ESTRUTURA
										"116"; //POSICAO Y NA ESTRUTURA
									};
								},;
								{; //TERCEIRO EIXO
									{;
										"1",; //CODIGO DA IMAGEM DO PNEU   EX: NG_PNEU_PRETO_ESCURO_1.PNG
										"223",; //POSICAO X NA ESTRUTURA
										"012"; //POSICAO Y NA ESTRUTURA
									},;
									{;
										"1",; //CODIGO DA IMAGEM DO PNEU   EX: NG_PNEU_PRETO_ESCURO_1.PNG
										"223",; //POSICAO X NA ESTRUTURA
										"116"; //POSICAO Y NA ESTRUTURA
									};
								},;
								{; //QUARTO EIXO
									{;
										"1",; //CODIGO DA IMAGEM DO PNEU   EX: NG_PNEU_PRETO_ESCURO_1.PNG
										"323",; //POSICAO X NA ESTRUTURA
										"012"; //POSICAO Y NA ESTRUTURA
									},;
									{;
										"1",; //CODIGO DA IMAGEM DO PNEU   EX: NG_PNEU_PRETO_ESCURO_1.PNG
										"323",; //POSICAO X NA ESTRUTURA
										"116"; //POSICAO Y NA ESTRUTURA
									};
								},;
								{; //QUINTO EIXO
									{;
										"1",; //CODIGO DA IMAGEM DO PNEU   EX: NG_PNEU_PRETO_ESCURO_1.PNG
										"423",; //POSICAO X NA ESTRUTURA
										"012"; //POSICAO Y NA ESTRUTURA
									},;
									{;
										"1",; //CODIGO DA IMAGEM DO PNEU   EX: NG_PNEU_PRETO_ESCURO_1.PNG
										"423",; //POSICAO X NA ESTRUTURA
										"116"; //POSICAO Y NA ESTRUTURA
									};
								},;
								{; //SEXTO EIXO
									{;
										"1",; //CODIGO DA IMAGEM DO PNEU   EX: NG_PNEU_PRETO_ESCURO_1.PNG
										"523",; //POSICAO X NA ESTRUTURA
										"012"; //POSICAO Y NA ESTRUTURA
									},;
									{;
										"1",; //CODIGO DA IMAGEM DO PNEU   EX: NG_PNEU_PRETO_ESCURO_1.PNG
										"523",; //POSICAO X NA ESTRUTURA
										"116"; //POSICAO Y NA ESTRUTURA
									};
								};
							},;
							{; //STEPES
								{;
									{;
										"2",; //CODIGO DA IMAGEM DO PNEU   EX: NG_PNEU_PRETO_ESCURO_1.PNG
										"590",; //POSICAO X NA ESTRUTURA
										"042"; //POSICAO Y NA ESTRUTURA
									};
								};
							};
				};
		)

	*********************************************************************************
	aAdd(aEstruTemp,{	"38",; //CODIGO DA IMAGEM DA ESTRUTURA   EX: NG_ESTRUTURA_1.PNG
							"554",; //TAMANHO X EM PIXEL
							"159",; //TAMANHO Y EM PIXEL
							{;
								{;	//PRIMEIRO EIXO
									{;
										"1",; //CODIGO DA IMAGEM DO PNEU   EX: NG_PNEU_PRETO_ESCURO_1.PNG
										"025",; //POSICAO X NA ESTRUTURA
										"012"; //POSICAO Y NA ESTRUTURA
									},;
									{;
										"1",; //CODIGO DA IMAGEM DO PNEU   EX: NG_PNEU_PRETO_ESCURO_1.PNG
										"025",; //POSICAO X NA ESTRUTURA
										"116"; //POSICAO Y NA ESTRUTURA
									};
								},;
								{; //SEGUNDO EIXO
									{;
										"1",; //CODIGO DA IMAGEM DO PNEU   EX: NG_PNEU_PRETO_ESCURO_1.PNG
										"123",; //POSICAO X NA ESTRUTURA
										"012"; //POSICAO Y NA ESTRUTURA
									},;
									{;
										"1",; //CODIGO DA IMAGEM DO PNEU   EX: NG_PNEU_PRETO_ESCURO_1.PNG
										"123",; //POSICAO X NA ESTRUTURA
										"116"; //POSICAO Y NA ESTRUTURA
									};
								},;
								{; //TERCEIRO EIXO
									{;
										"1",; //CODIGO DA IMAGEM DO PNEU   EX: NG_PNEU_PRETO_ESCURO_1.PNG
										"223",; //POSICAO X NA ESTRUTURA
										"012"; //POSICAO Y NA ESTRUTURA
									},;
									{;
										"1",; //CODIGO DA IMAGEM DO PNEU   EX: NG_PNEU_PRETO_ESCURO_1.PNG
										"223",; //POSICAO X NA ESTRUTURA
										"116"; //POSICAO Y NA ESTRUTURA
									};
								},;
								{; //QUARTO EIXO
									{;
										"1",; //CODIGO DA IMAGEM DO PNEU   EX: NG_PNEU_PRETO_ESCURO_1.PNG
										"323",; //POSICAO X NA ESTRUTURA
										"012"; //POSICAO Y NA ESTRUTURA
									},;
									{;
										"1",; //CODIGO DA IMAGEM DO PNEU   EX: NG_PNEU_PRETO_ESCURO_1.PNG
										"323",; //POSICAO X NA ESTRUTURA
										"116"; //POSICAO Y NA ESTRUTURA
									};
								},;
								{; //QUINTO EIXO
									{;
										"1",; //CODIGO DA IMAGEM DO PNEU   EX: NG_PNEU_PRETO_ESCURO_1.PNG
										"423",; //POSICAO X NA ESTRUTURA
										"012"; //POSICAO Y NA ESTRUTURA
									},;
									{;
										"1",; //CODIGO DA IMAGEM DO PNEU   EX: NG_PNEU_PRETO_ESCURO_1.PNG
										"423",; //POSICAO X NA ESTRUTURA
										"116"; //POSICAO Y NA ESTRUTURA
									};
								};
							},;
							{; //STEPES
								{;
									{;
										"2",; //CODIGO DA IMAGEM DO PNEU   EX: NG_PNEU_PRETO_ESCURO_1.PNG
										"490",; //POSICAO X NA ESTRUTURA
										"042"; //POSICAO Y NA ESTRUTURA
									};
								};
							};
				};
		)

	*********************************************************************************
	aAdd(aEstruTemp,{	"39",; //CODIGO DA IMAGEM DA ESTRUTURA   EX: NG_ESTRUTURA_1.PNG
							"455",; //TAMANHO X EM PIXEL
							"159",; //TAMANHO Y EM PIXEL
							{;
								{;	//PRIMEIRO EIXO
									{;
										"1",; //CODIGO DA IMAGEM DO PNEU   EX: NG_PNEU_PRETO_ESCURO_1.PNG
										"025",; //POSICAO X NA ESTRUTURA
										"012"; //POSICAO Y NA ESTRUTURA
									},;
									{;
										"1",; //CODIGO DA IMAGEM DO PNEU   EX: NG_PNEU_PRETO_ESCURO_1.PNG
										"025",; //POSICAO X NA ESTRUTURA
										"116"; //POSICAO Y NA ESTRUTURA
									};
								},;
								{; //SEGUNDO EIXO
									{;
										"1",; //CODIGO DA IMAGEM DO PNEU   EX: NG_PNEU_PRETO_ESCURO_1.PNG
										"123",; //POSICAO X NA ESTRUTURA
										"012"; //POSICAO Y NA ESTRUTURA
									},;
									{;
										"1",; //CODIGO DA IMAGEM DO PNEU   EX: NG_PNEU_PRETO_ESCURO_1.PNG
										"123",; //POSICAO X NA ESTRUTURA
										"116"; //POSICAO Y NA ESTRUTURA
									};
								},;
								{; //TERCEIRO EIXO
									{;
										"1",; //CODIGO DA IMAGEM DO PNEU   EX: NG_PNEU_PRETO_ESCURO_1.PNG
										"223",; //POSICAO X NA ESTRUTURA
										"012"; //POSICAO Y NA ESTRUTURA
									},;
									{;
										"1",; //CODIGO DA IMAGEM DO PNEU   EX: NG_PNEU_PRETO_ESCURO_1.PNG
										"223",; //POSICAO X NA ESTRUTURA
										"116"; //POSICAO Y NA ESTRUTURA
									};
								},;
								{; //QUARTO EIXO
									{;
										"1",; //CODIGO DA IMAGEM DO PNEU   EX: NG_PNEU_PRETO_ESCURO_1.PNG
										"323",; //POSICAO X NA ESTRUTURA
										"012"; //POSICAO Y NA ESTRUTURA
									},;
									{;
										"1",; //CODIGO DA IMAGEM DO PNEU   EX: NG_PNEU_PRETO_ESCURO_1.PNG
										"323",; //POSICAO X NA ESTRUTURA
										"116"; //POSICAO Y NA ESTRUTURA
									};
								};
							},;
							{; //STEPES
								{;
									{;
										"2",; //CODIGO DA IMAGEM DO PNEU   EX: NG_PNEU_PRETO_ESCURO_1.PNG
										"390",; //POSICAO X NA ESTRUTURA
										"042"; //POSICAO Y NA ESTRUTURA
									};
								};
							};
				};
		)

	*********************************************************************************
	aAdd(aEstruTemp,{	"40",; //CODIGO DA IMAGEM DA ESTRUTURA   EX: NG_ESTRUTURA_1.PNG
							"356",; //TAMANHO X EM PIXEL
							"159",; //TAMANHO Y EM PIXEL
							{;
								{;	//PRIMEIRO EIXO
									{;
										"1",; //CODIGO DA IMAGEM DO PNEU   EX: NG_PNEU_PRETO_ESCURO_1.PNG
										"025",; //POSICAO X NA ESTRUTURA
										"012"; //POSICAO Y NA ESTRUTURA
									},;
									{;
										"1",; //CODIGO DA IMAGEM DO PNEU   EX: NG_PNEU_PRETO_ESCURO_1.PNG
										"025",; //POSICAO X NA ESTRUTURA
										"116"; //POSICAO Y NA ESTRUTURA
									};
								},;
								{; //SEGUNDO EIXO
									{;
										"1",; //CODIGO DA IMAGEM DO PNEU   EX: NG_PNEU_PRETO_ESCURO_1.PNG
										"123",; //POSICAO X NA ESTRUTURA
										"012"; //POSICAO Y NA ESTRUTURA
									},;
									{;
										"1",; //CODIGO DA IMAGEM DO PNEU   EX: NG_PNEU_PRETO_ESCURO_1.PNG
										"123",; //POSICAO X NA ESTRUTURA
										"116"; //POSICAO Y NA ESTRUTURA
									};
								},;
								{; //TERCEIRO EIXO
									{;
										"1",; //CODIGO DA IMAGEM DO PNEU   EX: NG_PNEU_PRETO_ESCURO_1.PNG
										"223",; //POSICAO X NA ESTRUTURA
										"012"; //POSICAO Y NA ESTRUTURA
									},;
									{;
										"1",; //CODIGO DA IMAGEM DO PNEU   EX: NG_PNEU_PRETO_ESCURO_1.PNG
										"223",; //POSICAO X NA ESTRUTURA
										"116"; //POSICAO Y NA ESTRUTURA
									};
								};
							},;
							{; //STEPES
								{;
									{;
										"2",; //CODIGO DA IMAGEM DO PNEU   EX: NG_PNEU_PRETO_ESCURO_1.PNG
										"290",; //POSICAO X NA ESTRUTURA
										"042"; //POSICAO Y NA ESTRUTURA
									};
								};
							};
				};
		)

	*********************************************************************************

	aAdd(aEstruTemp,{	"44",; //CODIGO DA IMAGEM DA ESTRUTURA   EX: NG_ESTRUTURA_1.PNG
							"671",; //TAMANHO X EM PIXEL
							"222",; //TAMANHO Y EM PIXEL
								{;
									{;	//PRIMEIRO EIXO
										{;
											"4",; //CODIGO DA IMAGEM DO PNEU   EX: NG_PNEU_PRETO_ESCURO_1.PNG
											"008",; //POSICAO X NA ESTRUTURA
											"021"; //POSICAO Y NA ESTRUTURA
										},;
										{;
											"4",; //CODIGO DA IMAGEM DO PNEU   EX: NG_PNEU_PRETO_ESCURO_1.PNG
											"008",; //POSICAO X NA ESTRUTURA
											"168"; //POSICAO Y NA ESTRUTURA
										};
									},;
									{;	//SEGUNDO EIXO
										{;
											"4",; //CODIGO DA IMAGEM DO PNEU   EX: NG_PNEU_PRETO_ESCURO_1.PNG
											"369",; //POSICAO X NA ESTRUTURA
											"021"; //POSICAO Y NA ESTRUTURA
										},;
										{;
											"4",; //CODIGO DA IMAGEM DO PNEU   EX: NG_PNEU_PRETO_ESCURO_1.PNG
											"369",; //POSICAO X NA ESTRUTURA
											"168"; //POSICAO Y NA ESTRUTURA
										};
									},;
									{; //TERCEIRO EIXO
										{;
											"4",; //CODIGO DA IMAGEM DO PNEU   EX: NG_PNEU_PRETO_ESCURO_1.PNG
											"474",; //POSICAO X NA ESTRUTURA
											"021"; //POSICAO Y NA ESTRUTURA
										},;
										{;
											"4",; //CODIGO DA IMAGEM DO PNEU   EX: NG_PNEU_PRETO_ESCURO_1.PNG
											"474",; //POSICAO X NA ESTRUTURA
											"168"; //POSICAO Y NA ESTRUTURA
										};
									};
								},;
								{; //STEPES
									{;
									};
								};
							};
		)

	*********************************************************************************

	aAdd(aEstruTemp,{	"45",; //CODIGO DA IMAGEM DA ESTRUTURA   EX: NG_ESTRUTURA_1.PNG
							"498",; //TAMANHO X EM PIXEL
							"197",; //TAMANHO Y EM PIXEL
								{;
									{;	//PRIMEIRO EIXO
										{;
											"4",; //CODIGO DA IMAGEM DO PNEU   EX: NG_PNEU_PRETO_ESCURO_1.PNG
											"160",; //POSICAO X NA ESTRUTURA
											"008"; //POSICAO Y NA ESTRUTURA
										},;
										{;
											"4",; //CODIGO DA IMAGEM DO PNEU   EX: NG_PNEU_PRETO_ESCURO_1.PNG
											"160",; //POSICAO X NA ESTRUTURA
											"160"; //POSICAO Y NA ESTRUTURA
										};
									},;
									{; //SEGUNDO EIXO
										{;
											"4",; //CODIGO DA IMAGEM DO PNEU   EX: NG_PNEU_PRETO_ESCURO_1.PNG
											"344",; //POSICAO X NA ESTRUTURA
											"008"; //POSICAO Y NA ESTRUTURA
										},;
										{;
											"4",; //CODIGO DA IMAGEM DO PNEU   EX: NG_PNEU_PRETO_ESCURO_1.PNG
											"344",; //POSICAO X NA ESTRUTURA
											"160"; //POSICAO Y NA ESTRUTURA
										};
									};
								},;
								{; //STEPES
									{;
									};
								};
							};
		)

	*********************************************************************************

	aAdd(aEstruTemp,{	"46",; //CODIGO DA IMAGEM DA ESTRUTURA   EX: NG_ESTRUTURA_1.PNG
							"356",; //TAMANHO X EM PIXEL
							"197",; //TAMANHO Y EM PIXEL
							{;	//PNEUS NA ESTRUTURA
								{; //PRIMEIRO EIXO
									{;
										"4",; //CODIGO DA IMAGEM DO PNEU   EX: NG_PNEU_PRETO_ESCURO_1.PNG
										"218",; //POSICAO X NA ESTRUTURA
										"006"; //POSICAO Y NA ESTRUTURA
									},;
									{;
										"4",; //CODIGO DA IMAGEM DO PNEU   EX: NG_PNEU_PRETO_ESCURO_1.PNG
										"218",; //POSICAO X NA ESTRUTURA
										"156"; //POSICAO Y NA ESTRUTURA
									};
								};
							},;
							{; //STEPES
								{;
								};
							};
				};
		)

	*********************************************************************************
	aAdd(aEstruTemp,{	"41",; //CODIGO DA IMAGEM DA ESTRUTURA   EX: NG_ESTRUTURA_1.PNG
							"547",; //TAMANHO X EM PIXEL
							"196",; //TAMANHO Y EM PIXEL
							{;
								{; //PRIMEIRO EIXO
									{;
										"1",; //CODIGO DA IMAGEM DO PNEU   EX: NG_PNEU_PRETO_ESCURO_1.PNG
										"028",; //POSICAO X NA ESTRUTURA
										"011"; //POSICAO Y NA ESTRUTURA
									},;
									{;
										"1",; //CODIGO DA IMAGEM DO PNEU   EX: NG_PNEU_PRETO_ESCURO_1.PNG
										"028",; //POSICAO X NA ESTRUTURA
										"156"; //POSICAO Y NA ESTRUTURA
									};
								},;
								{; //SEGUNDO EIXO
									{;
										"1",; //CODIGO DA IMAGEM DO PNEU   EX: NG_PNEU_PRETO_ESCURO_1.PNG
										"136",; //POSICAO X NA ESTRUTURA
										"011"; //POSICAO Y NA ESTRUTURA
									},;
									{;
										"1",; //CODIGO DA IMAGEM DO PNEU   EX: NG_PNEU_PRETO_ESCURO_1.PNG
										"136",; //POSICAO X NA ESTRUTURA
										"156"; //POSICAO Y NA ESTRUTURA
									};
								},;
								{; //TERCEIRO EIXO
									{;
										"1",; //CODIGO DA IMAGEM DO PNEU   EX: NG_PNEU_PRETO_ESCURO_1.PNG
										"323",; //POSICAO X NA ESTRUTURA
										"004"; //POSICAO Y NA ESTRUTURA
									},;
									{;
										"1",; //CODIGO DA IMAGEM DO PNEU   EX: NG_PNEU_PRETO_ESCURO_1.PNG
										"323",; //POSICAO X NA ESTRUTURA
										"029"; //POSICAO Y NA ESTRUTURA
									},;
									{;
										"1",; //CODIGO DA IMAGEM DO PNEU   EX: NG_PNEU_PRETO_ESCURO_1.PNG
										"323",; //POSICAO X NA ESTRUTURA
										"135"; //POSICAO Y NA ESTRUTURA
									},;
									{;
										"1",; //CODIGO DA IMAGEM DO PNEU   EX: NG_PNEU_PRETO_ESCURO_1.PNG
										"323",; //POSICAO X NA ESTRUTURA
										"160"; //POSICAO Y NA ESTRUTURA
									};
								},;
								{; //QUARTO EIXO
									{;
										"1",; //CODIGO DA IMAGEM DO PNEU   EX: NG_PNEU_PRETO_ESCURO_1.PNG
										"435",; //POSICAO X NA ESTRUTURA
										"004"; //POSICAO Y NA ESTRUTURA
									},;
									{;
										"1",; //CODIGO DA IMAGEM DO PNEU   EX: NG_PNEU_PRETO_ESCURO_1.PNG
										"435",; //POSICAO X NA ESTRUTURA
										"160"; //POSICAO Y NA ESTRUTURA
									};
								};
							},;
							{; //STEPES
								{;
									{;
										"2",; //CODIGO DA IMAGEM DO PNEU   EX: NG_PNEU_PRETO_ESCURO_1.PNG
										"230",; //POSICAO X NA ESTRUTURA
										"025"; //POSICAO Y NA ESTRUTURA
									},;
									{;
										"2",; //CODIGO DA IMAGEM DO PNEU   EX: NG_PNEU_PRETO_ESCURO_1.PNG
										"230",; //POSICAO X NA ESTRUTURA
										"095"; //POSICAO Y NA ESTRUTURA
									};
								};
							};
						};
		)

	*********************************************************************************
		aAdd(aEstruTemp,{	"42",; //CODIGO DA IMAGEM DA ESTRUTURA   EX: NG_ESTRUTURA_1.PNG
							"981",; //TAMANHO X EM PIXEL
							"318",; //TAMANHO Y EM PIXEL
							{;
								{; //PRIMEIRO EIXO
									{;
										"3",; //CODIGO DA IMAGEM DO PNEU   EX: NG_PNEU_PRETO_ESCURO_1.PNG
										"-002",; //POSICAO X NA ESTRUTURA
										"005"; //POSICAO Y NA ESTRUTURA
									},;
									{;
										"3",; //CODIGO DA IMAGEM DO PNEU   EX: NG_PNEU_PRETO_ESCURO_1.PNG
										"-002",; //POSICAO X NA ESTRUTURA
										"024"; //POSICAO Y NA ESTRUTURA
									},;
									{;
										"3",; //CODIGO DA IMAGEM DO PNEU   EX: NG_PNEU_PRETO_ESCURO_1.PNG
										"-002",; //POSICAO X NA ESTRUTURA
										"048"; //POSICAO Y NA ESTRUTURA
									},;
									{;
										"3",; //CODIGO DA IMAGEM DO PNEU   EX: NG_PNEU_PRETO_ESCURO_1.PNG
										"-002",; //POSICAO X NA ESTRUTURA
										"067"; //POSICAO Y NA ESTRUTURA
									},;
									{;
										"3",; //CODIGO DA IMAGEM DO PNEU   EX: NG_PNEU_PRETO_ESCURO_1.PNG
										"-002",; //POSICAO X NA ESTRUTURA
										"229"; //POSICAO Y NA ESTRUTURA
									},;
									{;
										"3",; //CODIGO DA IMAGEM DO PNEU   EX: NG_PNEU_PRETO_ESCURO_1.PNG
										"-002",; //POSICAO X NA ESTRUTURA
										"248"; //POSICAO Y NA ESTRUTURA
									},;
									{;
										"3",; //CODIGO DA IMAGEM DO PNEU   EX: NG_PNEU_PRETO_ESCURO_1.PNG
										"-002",; //POSICAO X NA ESTRUTURA
										"272"; //POSICAO Y NA ESTRUTURA
									},;
									{;
										"3",; //CODIGO DA IMAGEM DO PNEU   EX: NG_PNEU_PRETO_ESCURO_1.PNG
										"-002",; //POSICAO X NA ESTRUTURA
										"291"; //POSICAO Y NA ESTRUTURA
									};
								},;
							{; //SEGUNDO EIXO
									{;
										"3",; //CODIGO DA IMAGEM DO PNEU   EX: NG_PNEU_PRETO_ESCURO_1.PNG
										"097",; //POSICAO X NA ESTRUTURA
										"005"; //POSICAO Y NA ESTRUTURA
									},;
									{;
										"3",; //CODIGO DA IMAGEM DO PNEU   EX: NG_PNEU_PRETO_ESCURO_1.PNG
										"097",; //POSICAO X NA ESTRUTURA
										"024"; //POSICAO Y NA ESTRUTURA
									},;
									{;
										"3",; //CODIGO DA IMAGEM DO PNEU   EX: NG_PNEU_PRETO_ESCURO_1.PNG
										"097",; //POSICAO X NA ESTRUTURA
										"048"; //POSICAO Y NA ESTRUTURA
									},;
									{;
										"3",; //CODIGO DA IMAGEM DO PNEU   EX: NG_PNEU_PRETO_ESCURO_1.PNG
										"097",; //POSICAO X NA ESTRUTURA
										"067"; //POSICAO Y NA ESTRUTURA
									},;
									{;
										"3",; //CODIGO DA IMAGEM DO PNEU   EX: NG_PNEU_PRETO_ESCURO_1.PNG
										"097",; //POSICAO X NA ESTRUTURA
										"229"; //POSICAO Y NA ESTRUTURA
									},;
									{;
										"3",; //CODIGO DA IMAGEM DO PNEU   EX: NG_PNEU_PRETO_ESCURO_1.PNG
										"097",; //POSICAO X NA ESTRUTURA
										"248"; //POSICAO Y NA ESTRUTURA
									},;
									{;
										"3",; //CODIGO DA IMAGEM DO PNEU   EX: NG_PNEU_PRETO_ESCURO_1.PNG
										"097",; //POSICAO X NA ESTRUTURA
										"272"; //POSICAO Y NA ESTRUTURA
									},;
									{;
										"3",; //CODIGO DA IMAGEM DO PNEU   EX: NG_PNEU_PRETO_ESCURO_1.PNG
										"097",; //POSICAO X NA ESTRUTURA
										"291"; //POSICAO Y NA ESTRUTURA
									};
								},;
								{; //TERCEIRO EIXO
									{;
										"3",; //CODIGO DA IMAGEM DO PNEU   EX: NG_PNEU_PRETO_ESCURO_1.PNG
										"197",; //POSICAO X NA ESTRUTURA
										"005"; //POSICAO Y NA ESTRUTURA
									},;
									{;
										"3",; //CODIGO DA IMAGEM DO PNEU   EX: NG_PNEU_PRETO_ESCURO_1.PNG
										"197",; //POSICAO X NA ESTRUTURA
										"024"; //POSICAO Y NA ESTRUTURA
									},;
									{;
										"3",; //CODIGO DA IMAGEM DO PNEU   EX: NG_PNEU_PRETO_ESCURO_1.PNG
										"197",; //POSICAO X NA ESTRUTURA
										"048"; //POSICAO Y NA ESTRUTURA
									},;
									{;
										"3",; //CODIGO DA IMAGEM DO PNEU   EX: NG_PNEU_PRETO_ESCURO_1.PNG
										"197",; //POSICAO X NA ESTRUTURA
										"067"; //POSICAO Y NA ESTRUTURA
									},;
									{;
										"3",; //CODIGO DA IMAGEM DO PNEU   EX: NG_PNEU_PRETO_ESCURO_1.PNG
										"197",; //POSICAO X NA ESTRUTURA
										"229"; //POSICAO Y NA ESTRUTURA
									},;
									{;
										"3",; //CODIGO DA IMAGEM DO PNEU   EX: NG_PNEU_PRETO_ESCURO_1.PNG
										"197",; //POSICAO X NA ESTRUTURA
										"248"; //POSICAO Y NA ESTRUTURA
									},;
									{;
										"3",; //CODIGO DA IMAGEM DO PNEU   EX: NG_PNEU_PRETO_ESCURO_1.PNG
										"197",; //POSICAO X NA ESTRUTURA
										"272"; //POSICAO Y NA ESTRUTURA
									},;
									{;
										"3",; //CODIGO DA IMAGEM DO PNEU   EX: NG_PNEU_PRETO_ESCURO_1.PNG
										"197",; //POSICAO X NA ESTRUTURA
										"291"; //POSICAO Y NA ESTRUTURA
									};
								},;
								{; //QUARTO EIXO
									{;
										"3",; //CODIGO DA IMAGEM DO PNEU   EX: NG_PNEU_PRETO_ESCURO_1.PNG
										"297",; //POSICAO X NA ESTRUTURA
										"005"; //POSICAO Y NA ESTRUTURA
									},;
									{;
										"3",; //CODIGO DA IMAGEM DO PNEU   EX: NG_PNEU_PRETO_ESCURO_1.PNG
										"297",; //POSICAO X NA ESTRUTURA
										"024"; //POSICAO Y NA ESTRUTURA
									},;
									{;
										"3",; //CODIGO DA IMAGEM DO PNEU   EX: NG_PNEU_PRETO_ESCURO_1.PNG
										"297",; //POSICAO X NA ESTRUTURA
										"048"; //POSICAO Y NA ESTRUTURA
									},;
									{;
										"3",; //CODIGO DA IMAGEM DO PNEU   EX: NG_PNEU_PRETO_ESCURO_1.PNG
										"297",; //POSICAO X NA ESTRUTURA
										"067"; //POSICAO Y NA ESTRUTURA
									},;
									{;
										"3",; //CODIGO DA IMAGEM DO PNEU   EX: NG_PNEU_PRETO_ESCURO_1.PNG
										"297",; //POSICAO X NA ESTRUTURA
										"229"; //POSICAO Y NA ESTRUTURA
									},;
									{;
										"3",; //CODIGO DA IMAGEM DO PNEU   EX: NG_PNEU_PRETO_ESCURO_1.PNG
										"297",; //POSICAO X NA ESTRUTURA
										"248"; //POSICAO Y NA ESTRUTURA
									},;
									{;
										"3",; //CODIGO DA IMAGEM DO PNEU   EX: NG_PNEU_PRETO_ESCURO_1.PNG
										"297",; //POSICAO X NA ESTRUTURA
										"272"; //POSICAO Y NA ESTRUTURA
									},;
									{;
										"3",; //CODIGO DA IMAGEM DO PNEU   EX: NG_PNEU_PRETO_ESCURO_1.PNG
										"297",; //POSICAO X NA ESTRUTURA
										"291"; //POSICAO Y NA ESTRUTURA
									};
								},;
								{; //QUINTO EIXO
									{;
										"3",; //CODIGO DA IMAGEM DO PNEU   EX: NG_PNEU_PRETO_ESCURO_1.PNG
										"397",; //POSICAO X NA ESTRUTURA
										"005"; //POSICAO Y NA ESTRUTURA
									},;
									{;
										"3",; //CODIGO DA IMAGEM DO PNEU   EX: NG_PNEU_PRETO_ESCURO_1.PNG
										"397",; //POSICAO X NA ESTRUTURA
										"024"; //POSICAO Y NA ESTRUTURA
									},;
									{;
										"3",; //CODIGO DA IMAGEM DO PNEU   EX: NG_PNEU_PRETO_ESCURO_1.PNG
										"397",; //POSICAO X NA ESTRUTURA
										"048"; //POSICAO Y NA ESTRUTURA
									},;
									{;
										"3",; //CODIGO DA IMAGEM DO PNEU   EX: NG_PNEU_PRETO_ESCURO_1.PNG
										"397",; //POSICAO X NA ESTRUTURA
										"067"; //POSICAO Y NA ESTRUTURA
									},;
									{;
										"3",; //CODIGO DA IMAGEM DO PNEU   EX: NG_PNEU_PRETO_ESCURO_1.PNG
										"397",; //POSICAO X NA ESTRUTURA
										"229"; //POSICAO Y NA ESTRUTURA
									},;
									{;
										"3",; //CODIGO DA IMAGEM DO PNEU   EX: NG_PNEU_PRETO_ESCURO_1.PNG
										"397",; //POSICAO X NA ESTRUTURA
										"248"; //POSICAO Y NA ESTRUTURA
									},;
									{;
										"3",; //CODIGO DA IMAGEM DO PNEU   EX: NG_PNEU_PRETO_ESCURO_1.PNG
										"397",; //POSICAO X NA ESTRUTURA
										"272"; //POSICAO Y NA ESTRUTURA
									},;
									{;
										"3",; //CODIGO DA IMAGEM DO PNEU   EX: NG_PNEU_PRETO_ESCURO_1.PNG
										"397",; //POSICAO X NA ESTRUTURA
										"291"; //POSICAO Y NA ESTRUTURA
									};
								},;
								{; //SEXTO EIXO
									{;
										"3",; //CODIGO DA IMAGEM DO PNEU   EX: NG_PNEU_PRETO_ESCURO_1.PNG
										"497",; //POSICAO X NA ESTRUTURA
										"005"; //POSICAO Y NA ESTRUTURA
									},;
									{;
										"3",; //CODIGO DA IMAGEM DO PNEU   EX: NG_PNEU_PRETO_ESCURO_1.PNG
										"497",; //POSICAO X NA ESTRUTURA
										"024"; //POSICAO Y NA ESTRUTURA
									},;
									{;
										"3",; //CODIGO DA IMAGEM DO PNEU   EX: NG_PNEU_PRETO_ESCURO_1.PNG
										"497",; //POSICAO X NA ESTRUTURA
										"048"; //POSICAO Y NA ESTRUTURA
									},;
									{;
										"3",; //CODIGO DA IMAGEM DO PNEU   EX: NG_PNEU_PRETO_ESCURO_1.PNG
										"497",; //POSICAO X NA ESTRUTURA
										"067"; //POSICAO Y NA ESTRUTURA
									},;
									{;
										"3",; //CODIGO DA IMAGEM DO PNEU   EX: NG_PNEU_PRETO_ESCURO_1.PNG
										"497",; //POSICAO X NA ESTRUTURA
										"229"; //POSICAO Y NA ESTRUTURA
									},;
									{;
										"3",; //CODIGO DA IMAGEM DO PNEU   EX: NG_PNEU_PRETO_ESCURO_1.PNG
										"497",; //POSICAO X NA ESTRUTURA
										"248"; //POSICAO Y NA ESTRUTURA
									},;
									{;
										"3",; //CODIGO DA IMAGEM DO PNEU   EX: NG_PNEU_PRETO_ESCURO_1.PNG
										"497",; //POSICAO X NA ESTRUTURA
										"272"; //POSICAO Y NA ESTRUTURA
									},;
									{;
										"3",; //CODIGO DA IMAGEM DO PNEU   EX: NG_PNEU_PRETO_ESCURO_1.PNG
										"497",; //POSICAO X NA ESTRUTURA
										"291"; //POSICAO Y NA ESTRUTURA
									};
								},;
								{; //SETIMO EIXO
									{;
										"3",; //CODIGO DA IMAGEM DO PNEU   EX: NG_PNEU_PRETO_ESCURO_1.PNG
										"597",; //POSICAO X NA ESTRUTURA
										"005"; //POSICAO Y NA ESTRUTURA
									},;
									{;
										"3",; //CODIGO DA IMAGEM DO PNEU   EX: NG_PNEU_PRETO_ESCURO_1.PNG
										"597",; //POSICAO X NA ESTRUTURA
										"024"; //POSICAO Y NA ESTRUTURA
									},;
									{;
										"3",; //CODIGO DA IMAGEM DO PNEU   EX: NG_PNEU_PRETO_ESCURO_1.PNG
										"597",; //POSICAO X NA ESTRUTURA
										"048"; //POSICAO Y NA ESTRUTURA
									},;
									{;
										"3",; //CODIGO DA IMAGEM DO PNEU   EX: NG_PNEU_PRETO_ESCURO_1.PNG
										"597",; //POSICAO X NA ESTRUTURA
										"067"; //POSICAO Y NA ESTRUTURA
									},;
									{;
										"3",; //CODIGO DA IMAGEM DO PNEU   EX: NG_PNEU_PRETO_ESCURO_1.PNG
										"597",; //POSICAO X NA ESTRUTURA
										"229"; //POSICAO Y NA ESTRUTURA
									},;
									{;
										"3",; //CODIGO DA IMAGEM DO PNEU   EX: NG_PNEU_PRETO_ESCURO_1.PNG
										"597",; //POSICAO X NA ESTRUTURA
										"248"; //POSICAO Y NA ESTRUTURA
									},;
									{;
										"3",; //CODIGO DA IMAGEM DO PNEU   EX: NG_PNEU_PRETO_ESCURO_1.PNG
										"597",; //POSICAO X NA ESTRUTURA
										"272"; //POSICAO Y NA ESTRUTURA
									},;
									{;
										"3",; //CODIGO DA IMAGEM DO PNEU   EX: NG_PNEU_PRETO_ESCURO_1.PNG
										"597",; //POSICAO X NA ESTRUTURA
										"291"; //POSICAO Y NA ESTRUTURA
									};
								},;
								{; //OITAVO EIXO
									{;
										"3",; //CODIGO DA IMAGEM DO PNEU   EX: NG_PNEU_PRETO_ESCURO_1.PNG
										"697",; //POSICAO X NA ESTRUTURA
										"005"; //POSICAO Y NA ESTRUTURA
									},;
									{;
										"3",; //CODIGO DA IMAGEM DO PNEU   EX: NG_PNEU_PRETO_ESCURO_1.PNG
										"697",; //POSICAO X NA ESTRUTURA
										"024"; //POSICAO Y NA ESTRUTURA
									},;
									{;
										"3",; //CODIGO DA IMAGEM DO PNEU   EX: NG_PNEU_PRETO_ESCURO_1.PNG
										"697",; //POSICAO X NA ESTRUTURA
										"048"; //POSICAO Y NA ESTRUTURA
									},;
									{;
										"3",; //CODIGO DA IMAGEM DO PNEU   EX: NG_PNEU_PRETO_ESCURO_1.PNG
										"697",; //POSICAO X NA ESTRUTURA
										"067"; //POSICAO Y NA ESTRUTURA
									},;
									{;
										"3",; //CODIGO DA IMAGEM DO PNEU   EX: NG_PNEU_PRETO_ESCURO_1.PNG
										"697",; //POSICAO X NA ESTRUTURA
										"229"; //POSICAO Y NA ESTRUTURA
									},;
									{;
										"3",; //CODIGO DA IMAGEM DO PNEU   EX: NG_PNEU_PRETO_ESCURO_1.PNG
										"697",; //POSICAO X NA ESTRUTURA
										"248"; //POSICAO Y NA ESTRUTURA
									},;
									{;
										"3",; //CODIGO DA IMAGEM DO PNEU   EX: NG_PNEU_PRETO_ESCURO_1.PNG
										"697",; //POSICAO X NA ESTRUTURA
										"272"; //POSICAO Y NA ESTRUTURA
									},;
									{;
										"3",; //CODIGO DA IMAGEM DO PNEU   EX: NG_PNEU_PRETO_ESCURO_1.PNG
										"697",; //POSICAO X NA ESTRUTURA
										"291"; //POSICAO Y NA ESTRUTURA
									};
								},;
								{; //NONO EIXO
									{;
										"3",; //CODIGO DA IMAGEM DO PNEU   EX: NG_PNEU_PRETO_ESCURO_1.PNG
										"797",; //POSICAO X NA ESTRUTURA
										"005"; //POSICAO Y NA ESTRUTURA
									},;
									{;
										"3",; //CODIGO DA IMAGEM DO PNEU   EX: NG_PNEU_PRETO_ESCURO_1.PNG
										"797",; //POSICAO X NA ESTRUTURA
										"024"; //POSICAO Y NA ESTRUTURA
									},;
									{;
										"3",; //CODIGO DA IMAGEM DO PNEU   EX: NG_PNEU_PRETO_ESCURO_1.PNG
										"797",; //POSICAO X NA ESTRUTURA
										"048"; //POSICAO Y NA ESTRUTURA
									},;
									{;
										"3",; //CODIGO DA IMAGEM DO PNEU   EX: NG_PNEU_PRETO_ESCURO_1.PNG
										"797",; //POSICAO X NA ESTRUTURA
										"067"; //POSICAO Y NA ESTRUTURA
									},;
									{;
										"3",; //CODIGO DA IMAGEM DO PNEU   EX: NG_PNEU_PRETO_ESCURO_1.PNG
										"797",; //POSICAO X NA ESTRUTURA
										"229"; //POSICAO Y NA ESTRUTURA
									},;
									{;
										"3",; //CODIGO DA IMAGEM DO PNEU   EX: NG_PNEU_PRETO_ESCURO_1.PNG
										"797",; //POSICAO X NA ESTRUTURA
										"248"; //POSICAO Y NA ESTRUTURA
									},;
									{;
										"3",; //CODIGO DA IMAGEM DO PNEU   EX: NG_PNEU_PRETO_ESCURO_1.PNG
										"797",; //POSICAO X NA ESTRUTURA
										"272"; //POSICAO Y NA ESTRUTURA
									},;
									{;
										"3",; //CODIGO DA IMAGEM DO PNEU   EX: NG_PNEU_PRETO_ESCURO_1.PNG
										"797",; //POSICAO X NA ESTRUTURA
										"291"; //POSICAO Y NA ESTRUTURA
									};
								},;
								{; //DECIMO EIXO
									{;
										"3",; //CODIGO DA IMAGEM DO PNEU   EX: NG_PNEU_PRETO_ESCURO_1.PNG
										"897",; //POSICAO X NA ESTRUTURA
										"005"; //POSICAO Y NA ESTRUTURA
									},;
									{;
										"3",; //CODIGO DA IMAGEM DO PNEU   EX: NG_PNEU_PRETO_ESCURO_1.PNG
										"897",; //POSICAO X NA ESTRUTURA
										"024"; //POSICAO Y NA ESTRUTURA
									},;
									{;
										"3",; //CODIGO DA IMAGEM DO PNEU   EX: NG_PNEU_PRETO_ESCURO_1.PNG
										"897",; //POSICAO X NA ESTRUTURA
										"048"; //POSICAO Y NA ESTRUTURA
									},;
									{;
										"3",; //CODIGO DA IMAGEM DO PNEU   EX: NG_PNEU_PRETO_ESCURO_1.PNG
										"897",; //POSICAO X NA ESTRUTURA
										"067"; //POSICAO Y NA ESTRUTURA
									},;
									{;
										"3",; //CODIGO DA IMAGEM DO PNEU   EX: NG_PNEU_PRETO_ESCURO_1.PNG
										"897",; //POSICAO X NA ESTRUTURA
										"229"; //POSICAO Y NA ESTRUTURA
									},;
									{;
										"3",; //CODIGO DA IMAGEM DO PNEU   EX: NG_PNEU_PRETO_ESCURO_1.PNG
										"897",; //POSICAO X NA ESTRUTURA
										"248"; //POSICAO Y NA ESTRUTURA
									},;
									{;
										"3",; //CODIGO DA IMAGEM DO PNEU   EX: NG_PNEU_PRETO_ESCURO_1.PNG
										"897",; //POSICAO X NA ESTRUTURA
										"272"; //POSICAO Y NA ESTRUTURA
									},;
									{;
										"3",; //CODIGO DA IMAGEM DO PNEU   EX: NG_PNEU_PRETO_ESCURO_1.PNG
										"897",; //POSICAO X NA ESTRUTURA
										"291"; //POSICAO Y NA ESTRUTURA
									};
								};
							},;
							{; //STEPES
								{;
								};
							};
						};
		)
		*********************************************************************************
		aAdd(aEstruTemp,{	"49",; //CODIGO DA IMAGEM DA ESTRUTURA   EX: NG_ESTRUTURA_1.PNG
							"600",; //TAMANHO X EM PIXEL
							"196",; //TAMANHO Y EM PIXEL
							{;
								{;
									{;
										"1",; //CODIGO DA IMAGEM DO PNEU   EX: NG_PNEU_PRETO_ESCURO_1.PNG
										"066",; //POSICAO X NA ESTRUTURA
										"011"; //POSICAO Y NA ESTRUTURA
									},;
									{;
										"1",; //CODIGO DA IMAGEM DO PNEU   EX: NG_PNEU_PRETO_ESCURO_1.PNG
										"066",; //POSICAO X NA ESTRUTURA
										"156"; //POSICAO Y NA ESTRUTURA
									};
								},;
								{; //SEGUNDO EIXO
									{;
										"1",; //CODIGO DA IMAGEM DO PNEU   EX: NG_PNEU_PRETO_ESCURO_1.PNG
										"358",; //POSICAO X NA ESTRUTURA
										"004"; //POSICAO Y NA ESTRUTURA
									},;
									{;
										"1",; //CODIGO DA IMAGEM DO PNEU   EX: NG_PNEU_PRETO_ESCURO_1.PNG
										"358",; //POSICAO X NA ESTRUTURA
										"159"; //POSICAO Y NA ESTRUTURA
									};
								},;
								{; //TERCEIRO EIXO
									{;
										"1",; //CODIGO DA IMAGEM DO PNEU   EX: NG_PNEU_PRETO_ESCURO_1.PNG
										"477",; //POSICAO X NA ESTRUTURA
										"004"; //POSICAO Y NA ESTRUTURA
									},;
									{;
										"1",; //CODIGO DA IMAGEM DO PNEU   EX: NG_PNEU_PRETO_ESCURO_1.PNG
										"477",; //POSICAO X NA ESTRUTURA
										"030"; //POSICAO Y NA ESTRUTURA
									},;
									{;
										"1",; //CODIGO DA IMAGEM DO PNEU   EX: NG_PNEU_PRETO_ESCURO_1.PNG
										"477",; //POSICAO X NA ESTRUTURA
										"134"; //POSICAO Y NA ESTRUTURA
									},;
									{;
										"1",; //CODIGO DA IMAGEM DO PNEU   EX: NG_PNEU_PRETO_ESCURO_1.PNG
										"477",; //POSICAO X NA ESTRUTURA
										"160"; //POSICAO Y NA ESTRUTURA
									};
								};
							},;
							{; //STEPES
								{;
									{;
										"2",; //CODIGO DA IMAGEM DO PNEU   EX: NG_PNEU_PRETO_ESCURO_1.PNG
										"250",; //POSICAO X NA ESTRUTURA
										"025"; //POSICAO Y NA ESTRUTURA
									},;
									{;
										"2",; //CODIGO DA IMAGEM DO PNEU   EX: NG_PNEU_PRETO_ESCURO_1.PNG
										"250",; //POSICAO X NA ESTRUTURA
										"095"; //POSICAO Y NA ESTRUTURA
									};
								};
							};
						};
		)
	*********************************************************************************
	aAdd(aEstruTemp,{	"47",; //CODIGO DA IMAGEM DA ESTRUTURA   EX: NG_ESTRUTURA_1.PNG
							"349",; //TAMANHO X EM PIXEL
							"178",; //TAMANHO Y EM PIXEL
								{;
									{;	//PRIMEIRO EIXO
										{;
											"1",; //CODIGO DA IMAGEM DO PNEU   EX: NG_PNEU_PRETO_ESCURO_1.PNG
											"060",; //POSICAO X NA ESTRUTURA
											"000"; //POSICAO Y NA ESTRUTURA
										},;
										{;
											"1",; //CODIGO DA IMAGEM DO PNEU   EX: NG_PNEU_PRETO_ESCURO_1.PNG
											"060",; //POSICAO X NA ESTRUTURA
											"0148"; //POSICAO Y NA ESTRUTURA
										};
									},;
									{;	//SEGUNDO EIXO
										{;
											"3",; //CODIGO DA IMAGEM DO PNEU   EX: NG_PNEU_PRETO_ESCURO_1.PNG
											"273",; //POSICAO X NA ESTRUTURA
											"011"; //POSICAO Y NA ESTRUTURA
										},;
										{;
											"3",; //CODIGO DA IMAGEM DO PNEU   EX: NG_PNEU_PRETO_ESCURO_1.PNG
											"273",; //POSICAO X NA ESTRUTURA
											"142"; //POSICAO Y NA ESTRUTURA
										};
									};
								},;
								{; //STEPES
									{;
									};
								};
							};
		)
	*********************************************************************************
		aAdd(aEstruTemp,{	"48",; //CODIGO DA IMAGEM DA ESTRUTURA   EX: NG_ESTRUTURA_1.PNG
							"297",; //TAMANHO X EM PIXEL
							"208",; //TAMANHO Y EM PIXEL
								{;
									{;	//PRIMEIRO EIXO
										{; //PNEUS
											"1",; //CODIGO DA IMAGEM DO PNEU   EX: NG_PNEU_PRETO_ESCURO_1.PNG
											"017",; //POSICAO X NA ESTRUTURA
											"-002"; //POSICAO Y NA ESTRUTURA
										},;
										{;
											"1",; //CODIGO DA IMAGEM DO PNEU   EX: NG_PNEU_PRETO_ESCURO_1.PNG
											"017",; //POSICAO X NA ESTRUTURA
											"020"; //POSICAO Y NA ESTRUTURA
										},;
										{;
											"1",; //CODIGO DA IMAGEM DO PNEU   EX: NG_PNEU_PRETO_ESCURO_1.PNG
											"017",; //POSICAO X NA ESTRUTURA
											"156"; //POSICAO Y NA ESTRUTURA
										},;
										{;
											"1",; //CODIGO DA IMAGEM DO PNEU   EX: NG_PNEU_PRETO_ESCURO_1.PNG
											"017",; //POSICAO X NA ESTRUTURA
											"178"; //POSICAO Y NA ESTRUTURA
										};
									},;
									{;	//SEGUNDO EIXO
										{;   // PNEUS
											"1",; //CODIGO DA IMAGEM DO PNEU   EX: NG_PNEU_PRETO_ESCURO_1.PNG
											"197",; //POSICAO X NA ESTRUTURA
											"015"; //POSICAO Y NA ESTRUTURA
										},;
										{;
											"1",; //CODIGO DA IMAGEM DO PNEU   EX: NG_PNEU_PRETO_ESCURO_1.PNG
											"197",; //POSICAO X NA ESTRUTURA
											"163"; //POSICAO Y NA ESTRUTURA
										};
									};
								},;
								{; //STEPES
									{;
									};
								};
							};
		)
	*********************************************************************************
			aAdd(aEstruTemp,{	"50",; //CODIGO DA IMAGEM DA ESTRUTURA   EX: NG_ESTRUTURA_1.PNG
							"599",; //TAMANHO X EM PIXEL
							"321",; //TAMANHO Y EM PIXEL
								{;
									{;	//PRIMEIRO EIXO
										{; //PNEUS
											"4",; //CODIGO DA IMAGEM DO PNEU   EX: NG_PNEU_PRETO_ESCURO_1.PNG
											"162",; //POSICAO X NA ESTRUTURA
											"047"; //POSICAO Y NA ESTRUTURA
										},;
										{;
											"4",; //CODIGO DA IMAGEM DO PNEU   EX: NG_PNEU_PRETO_ESCURO_1.PNG
											"162",; //POSICAO X NA ESTRUTURA
											"080"; //POSICAO Y NA ESTRUTURA
										},;
										{;
											"4",; //CODIGO DA IMAGEM DO PNEU   EX: NG_PNEU_PRETO_ESCURO_1.PNG
											"162",; //POSICAO X NA ESTRUTURA
											"214"; //POSICAO Y NA ESTRUTURA
										},;
										{;
											"4",; //CODIGO DA IMAGEM DO PNEU   EX: NG_PNEU_PRETO_ESCURO_1.PNG
											"162",; //POSICAO X NA ESTRUTURA
											"247"; //POSICAO Y NA ESTRUTURA
										};
									},;
									{;	//SEGUNDO EIXO
										{;   // PNEUS
											"4",; //CODIGO DA IMAGEM DO PNEU   EX: NG_PNEU_PRETO_ESCURO_1.PNG
											"498",; //POSICAO X NA ESTRUTURA
											"071"; //POSICAO Y NA ESTRUTURA
										},;
										{;
											"4",; //CODIGO DA IMAGEM DO PNEU   EX: NG_PNEU_PRETO_ESCURO_1.PNG
											"498",; //POSICAO X NA ESTRUTURA
											"224"; //POSICAO Y NA ESTRUTURA
										};
									};
								},;
								{; //STEPES
									{;
									};
								};
							};
		)
	*********************************************************************************
					aAdd(aEstruTemp,{	"51",; //CODIGO DA IMAGEM DA ESTRUTURA   EX: NG_ESTRUTURA_1.PNG
							"930",; //TAMANHO X EM PIXEL
							"345",; //TAMANHO Y EM PIXEL
	  							{;
									{;	//PRIMEIRO EIXO
										{;    //PNEU
											"3",; //CODIGO DA IMAGEM DO PNEU   EX: NG_PNEU_PRETO_ESCURO_1.PNG
											"034",; //POSICAO X NA ESTRUTURA
											"008"; //POSICAO Y NA ESTRUTURA
										},;
										{;  //PNEU
											"3",; //CODIGO DA IMAGEM DO PNEU   EX: NG_PNEU_PRETO_ESCURO_1.PNG
											"034",; //POSICAO X NA ESTRUTURA
											"027"; //POSICAO Y NA ESTRUTURA                                             //
										},;
										{;  //PNEU
											"3",; //CODIGO DA IMAGEM DO PNEU   EX: NG_PNEU_PRETO_ESCURO_1.PNG
											"034",; //POSICAO X NA ESTRUTURA
											"294"; //POSICAO Y NA ESTRUTURA                                             //
										},;
										{;  //PNEU
											"3",; //CODIGO DA IMAGEM DO PNEU   EX: NG_PNEU_PRETO_ESCURO_1.PNG
											"034",; //POSICAO X NA ESTRUTURA
											"313"; //POSICAO Y NA ESTRUTURA                                             //
										};
									},;
									{;	//SEGUNDO EIXO
										{;  //PNEU
											"3",; //CODIGO DA IMAGEM DO PNEU   EX: NG_PNEU_PRETO_ESCURO_1.PNG
											"154",; //POSICAO X NA ESTRUTURA
											"008"; //POSICAO Y NA ESTRUTURA                                             //
										},;
										{;  //PNEU
											"3",; //CODIGO DA IMAGEM DO PNEU   EX: NG_PNEU_PRETO_ESCURO_1.PNG
											"154",; //POSICAO X NA ESTRUTURA
											"027"; //POSICAO Y NA ESTRUTURA                                             //
										},;
										{;  //PNEU
											"3",; //CODIGO DA IMAGEM DO PNEU   EX: NG_PNEU_PRETO_ESCURO_1.PNG
											"154",; //POSICAO X NA ESTRUTURA
											"294"; //POSICAO Y NA ESTRUTURA                                             //
										},;
										{;  //PNEU
											"3",; //CODIGO DA IMAGEM DO PNEU   EX: NG_PNEU_PRETO_ESCURO_1.PNG
											"154",; //POSICAO X NA ESTRUTURA
											"313"; //POSICAO Y NA ESTRUTURA                                             //
										};
									},;
									{;	//TERCEIRO EIXO
										{;  //PNEU
											"3",; //CODIGO DA IMAGEM DO PNEU   EX: NG_PNEU_PRETO_ESCURO_1.PNG
											"283",; //POSICAO X NA ESTRUTURA
											"008"; //POSICAO Y NA ESTRUTURA                                             //
										},;
										{;  //PNEU
											"3",; //CODIGO DA IMAGEM DO PNEU   EX: NG_PNEU_PRETO_ESCURO_1.PNG
											"283",; //POSICAO X NA ESTRUTURA
											"027"; //POSICAO Y NA ESTRUTURA                                             //
										},;
										{;  //PNEU
											"3",; //CODIGO DA IMAGEM DO PNEU   EX: NG_PNEU_PRETO_ESCURO_1.PNG
											"283",; //POSICAO X NA ESTRUTURA
											"294"; //POSICAO Y NA ESTRUTURA                                             //
										},;
										{;  //PNEU
											"3",; //CODIGO DA IMAGEM DO PNEU   EX: NG_PNEU_PRETO_ESCURO_1.PNG
											"283",; //POSICAO X NA ESTRUTURA
											"313"; //POSICAO Y NA ESTRUTURA                                             //
										};
									},;
									{;	//QUARTO EIXO
										{;  //PNEU
											"3",; //CODIGO DA IMAGEM DO PNEU   EX: NG_PNEU_PRETO_ESCURO_1.PNG
											"408",; //POSICAO X NA ESTRUTURA
											"008"; //POSICAO Y NA ESTRUTURA                                             //
										},;
										{;  //PNEU
											"3",; //CODIGO DA IMAGEM DO PNEU   EX: NG_PNEU_PRETO_ESCURO_1.PNG
											"408",; //POSICAO X NA ESTRUTURA
											"027"; //POSICAO Y NA ESTRUTURA                                             //
										},;
										{;  //PNEU
											"3",; //CODIGO DA IMAGEM DO PNEU   EX: NG_PNEU_PRETO_ESCURO_1.PNG
											"408",; //POSICAO X NA ESTRUTURA
											"294"; //POSICAO Y NA ESTRUTURA                                             //
										},;
										{;  //PNEU
											"3",; //CODIGO DA IMAGEM DO PNEU   EX: NG_PNEU_PRETO_ESCURO_1.PNG
											"408",; //POSICAO X NA ESTRUTURA
											"313"; //POSICAO Y NA ESTRUTURA                                             //
										};
									},;
									{;	//QUINTO EIXO
										{;  //PNEU
											"3",; //CODIGO DA IMAGEM DO PNEU   EX: NG_PNEU_PRETO_ESCURO_1.PNG
											"543",; //POSICAO X NA ESTRUTURA
											"008"; //POSICAO Y NA ESTRUTURA                                             //
										},;
										{;  //PNEU
											"3",; //CODIGO DA IMAGEM DO PNEU   EX: NG_PNEU_PRETO_ESCURO_1.PNG
											"543",; //POSICAO X NA ESTRUTURA
											"027"; //POSICAO Y NA ESTRUTURA                                             //
										},;
										{;  //PNEU
											"3",; //CODIGO DA IMAGEM DO PNEU   EX: NG_PNEU_PRETO_ESCURO_1.PNG
											"543",; //POSICAO X NA ESTRUTURA
											"294"; //POSICAO Y NA ESTRUTURA                                             //
										},;
										{;  //PNEU
											"3",; //CODIGO DA IMAGEM DO PNEU   EX: NG_PNEU_PRETO_ESCURO_1.PNG
											"543",; //POSICAO X NA ESTRUTURA
											"313"; //POSICAO Y NA ESTRUTURA                                             //
										};
									},;
									{;	//SEXTO EIXO
										{;  //PNEU
											"3",; //CODIGO DA IMAGEM DO PNEU   EX: NG_PNEU_PRETO_ESCURO_1.PNG
											"670",; //POSICAO X NA ESTRUTURA
											"008"; //POSICAO Y NA ESTRUTURA                                             //
										},;
										{;  //PNEU
											"3",; //CODIGO DA IMAGEM DO PNEU   EX: NG_PNEU_PRETO_ESCURO_1.PNG
											"670",; //POSICAO X NA ESTRUTURA
											"027"; //POSICAO Y NA ESTRUTURA                                             //
										},;
										{;  //PNEU
											"3",; //CODIGO DA IMAGEM DO PNEU   EX: NG_PNEU_PRETO_ESCURO_1.PNG
											"670",; //POSICAO X NA ESTRUTURA
											"294"; //POSICAO Y NA ESTRUTURA                                             //
										},;
										{;  //PNEU
											"3",; //CODIGO DA IMAGEM DO PNEU   EX: NG_PNEU_PRETO_ESCURO_1.PNG
											"670",; //POSICAO X NA ESTRUTURA
											"313"; //POSICAO Y NA ESTRUTURA                                             //
										};
									},;
									{;	//SETIMO EIXO
										{;  //PNEU
											"3",; //CODIGO DA IMAGEM DO PNEU   EX: NG_PNEU_PRETO_ESCURO_1.PNG
											"796",; //POSICAO X NA ESTRUTURA
											"008"; //POSICAO Y NA ESTRUTURA                                             //
										},;
										{;  //PNEU
											"3",; //CODIGO DA IMAGEM DO PNEU   EX: NG_PNEU_PRETO_ESCURO_1.PNG
											"796",; //POSICAO X NA ESTRUTURA
											"027"; //POSICAO Y NA ESTRUTURA                                             //
										},;
										{;  //PNEU
											"3",; //CODIGO DA IMAGEM DO PNEU   EX: NG_PNEU_PRETO_ESCURO_1.PNG
											"796",; //POSICAO X NA ESTRUTURA
											"294"; //POSICAO Y NA ESTRUTURA                                             //
										},;
										{;  //PNEU
											"3",; //CODIGO DA IMAGEM DO PNEU   EX: NG_PNEU_PRETO_ESCURO_1.PNG
											"796",; //POSICAO X NA ESTRUTURA
											"313"; //POSICAO Y NA ESTRUTURA                                             //
										};
									};
								},;
								{; //STEPES
									{;
									};
								};
							};
		)
	*********************************************************************************
					aAdd(aEstruTemp,{	"52",; //CODIGO DA IMAGEM DA ESTRUTURA   EX: NG_ESTRUTURA_1.PNG
							"546",; //TAMANHO X EM PIXEL
							"342",; //TAMANHO Y EM PIXEL
	  							{;
									{;	//PRIMEIRO EIXO
										{;    //PNEU
											"4",; //CODIGO DA IMAGEM DO PNEU   EX: NG_PNEU_PRETO_ESCURO_1.PNG
											"003",; //POSICAO X NA ESTRUTURA
											"023"; //POSICAO Y NA ESTRUTURA
										};
									},;
									{;	//SEGUNDO EIXO
										{;  //PNEU
											"4",; //CODIGO DA IMAGEM DO PNEU   EX: NG_PNEU_PRETO_ESCURO_1.PNG
											"122",; //POSICAO X NA ESTRUTURA
											"023"; //POSICAO Y NA ESTRUTURA                                             //
										};
									},;
									{;	//TERCEIRO EIXO
										{;  //PNEU
											"4",; //CODIGO DA IMAGEM DO PNEU   EX: NG_PNEU_PRETO_ESCURO_1.PNG
											"327",; //POSICAO X NA ESTRUTURA
											"023"; //POSICAO Y NA ESTRUTURA                                             //
										};
									},;
									{;	//QUARTO EIXO
										{;  //PNEU
											"4",; //CODIGO DA IMAGEM DO PNEU   EX: NG_PNEU_PRETO_ESCURO_1.PNG
											"446",; //POSICAO X NA ESTRUTURA
											"023"; //POSICAO Y NA ESTRUTURA                                             //
										};
									},;
									{;	//QUINTO EIXO
										{;  //PNEU
											"4",; //CODIGO DA IMAGEM DO PNEU   EX: NG_PNEU_PRETO_ESCURO_1.PNG
											"003",; //POSICAO X NA ESTRUTURA
											"273"; //POSICAO Y NA ESTRUTURA                                             //
										};
									},;
									{;	//SEXTO EIXO
										{;  //PNEU
											"4",; //CODIGO DA IMAGEM DO PNEU   EX: NG_PNEU_PRETO_ESCURO_1.PNG
											"122",; //POSICAO X NA ESTRUTURA
											"273"; //POSICAO Y NA ESTRUTURA                                             //
										};
									},;
									{;	//SETIMO EIXO
										{;  //PNEU
											"4",; //CODIGO DA IMAGEM DO PNEU   EX: NG_PNEU_PRETO_ESCURO_1.PNG
											"327",; //POSICAO X NA ESTRUTURA
											"273"; //POSICAO Y NA ESTRUTURA                                             //
										};
									},;
									{;	//OITAVO EIXO
										{;  //PNEU
											"4",; //CODIGO DA IMAGEM DO PNEU   EX: NG_PNEU_PRETO_ESCURO_1.PNG
											"446",; //POSICAO X NA ESTRUTURA
											"273"; //POSICAO Y NA ESTRUTURA                                             //
										};
									};
								},;
								{; //STEPES
									{;
									};
								};
							};
		)

	*********************************************************************************
		aAdd(aEstruTemp,{	"54",; //CODIGO DA IMAGEM DA ESTRUTURA   EX: NG_ESTRUTURA_1.PNG
							"653",; //TAMANHO X EM PIXEL
							"159",; //TAMANHO Y EM PIXEL
							{;
								{;	//PRIMEIRO EIXO
									{;
										"1",; //CODIGO DA IMAGEM DO PNEU   EX: NG_PNEU_PRETO_ESCURO_1.PNG
										"025",; //POSICAO X NA ESTRUTURA
										"007"; //POSICAO Y NA ESTRUTURA
									},;
									{;
										"1",; //CODIGO DA IMAGEM DO PNEU   EX: NG_PNEU_PRETO_ESCURO_1.PNG
										"025",; //POSICAO X NA ESTRUTURA
										"033"; //POSICAO Y NA ESTRUTURA
									},;
									{;
										"1",; //CODIGO DA IMAGEM DO PNEU   EX: NG_PNEU_PRETO_ESCURO_1.PNG
										"025",; //POSICAO X NA ESTRUTURA
										"135"; //POSICAO Y NA ESTRUTURA
									},;
									{;
										"1",; //CODIGO DA IMAGEM DO PNEU   EX: NG_PNEU_PRETO_ESCURO_1.PNG
										"025",; //POSICAO X NA ESTRUTURA
										"163"; //POSICAO Y NA ESTRUTURA
									};
								},;
								{; //SEGUNDO EIXO
									{;
										"1",; //CODIGO DA IMAGEM DO PNEU   EX: NG_PNEU_PRETO_ESCURO_1.PNG
										"123",; //POSICAO X NA ESTRUTURA
										"007"; //POSICAO Y NA ESTRUTURA
									},;
									{;
										"1",; //CODIGO DA IMAGEM DO PNEU   EX: NG_PNEU_PRETO_ESCURO_1.PNG
										"123",; //POSICAO X NA ESTRUTURA
										"033"; //POSICAO Y NA ESTRUTURA
									},;
									{;
										"1",; //CODIGO DA IMAGEM DO PNEU   EX: NG_PNEU_PRETO_ESCURO_1.PNG
										"123",; //POSICAO X NA ESTRUTURA
										"135"; //POSICAO Y NA ESTRUTURA
									},;
									{;
										"1",; //CODIGO DA IMAGEM DO PNEU   EX: NG_PNEU_PRETO_ESCURO_1.PNG
										"123",; //POSICAO X NA ESTRUTURA
										"163"; //POSICAO Y NA ESTRUTURA
									};
								},;
								{; //TERCEIRO EIXO
									{;
										"1",; //CODIGO DA IMAGEM DO PNEU   EX: NG_PNEU_PRETO_ESCURO_1.PNG
										"223",; //POSICAO X NA ESTRUTURA
										"007"; //POSICAO Y NA ESTRUTURA
									},;
									{;
										"1",; //CODIGO DA IMAGEM DO PNEU   EX: NG_PNEU_PRETO_ESCURO_1.PNG
										"223",; //POSICAO X NA ESTRUTURA
										"033"; //POSICAO Y NA ESTRUTURA
									},;
									{;
										"1",; //CODIGO DA IMAGEM DO PNEU   EX: NG_PNEU_PRETO_ESCURO_1.PNG
										"223",; //POSICAO X NA ESTRUTURA
										"135"; //POSICAO Y NA ESTRUTURA
									},;
									{;
										"1",; //CODIGO DA IMAGEM DO PNEU   EX: NG_PNEU_PRETO_ESCURO_1.PNG
										"223",; //POSICAO X NA ESTRUTURA
										"163"; //POSICAO Y NA ESTRUTURA
									};
								},;
								{; //QUARTO EIXO
									{;
										"1",; //CODIGO DA IMAGEM DO PNEU   EX: NG_PNEU_PRETO_ESCURO_1.PNG
										"323",; //POSICAO X NA ESTRUTURA
										"007"; //POSICAO Y NA ESTRUTURA
									},;
									{;
										"1",; //CODIGO DA IMAGEM DO PNEU   EX: NG_PNEU_PRETO_ESCURO_1.PNG
										"323",; //POSICAO X NA ESTRUTURA
										"033"; //POSICAO Y NA ESTRUTURA
									},;
									{;
										"1",; //CODIGO DA IMAGEM DO PNEU   EX: NG_PNEU_PRETO_ESCURO_1.PNG
										"323",; //POSICAO X NA ESTRUTURA
										"135"; //POSICAO Y NA ESTRUTURA
									},;
									{;
										"1",; //CODIGO DA IMAGEM DO PNEU   EX: NG_PNEU_PRETO_ESCURO_1.PNG
										"323",; //POSICAO X NA ESTRUTURA
										"163"; //POSICAO Y NA ESTRUTURA
									};
								},;
								{; //QUINTO EIXO
									{;
										"1",; //CODIGO DA IMAGEM DO PNEU   EX: NG_PNEU_PRETO_ESCURO_1.PNG
										"423",; //POSICAO X NA ESTRUTURA
										"007"; //POSICAO Y NA ESTRUTURA
									},;
									{;
										"1",; //CODIGO DA IMAGEM DO PNEU   EX: NG_PNEU_PRETO_ESCURO_1.PNG
										"423",; //POSICAO X NA ESTRUTURA
										"033"; //POSICAO Y NA ESTRUTURA
									},;
									{;
										"1",; //CODIGO DA IMAGEM DO PNEU   EX: NG_PNEU_PRETO_ESCURO_1.PNG
										"423",; //POSICAO X NA ESTRUTURA
										"135"; //POSICAO Y NA ESTRUTURA
									},;
									{;
										"1",; //CODIGO DA IMAGEM DO PNEU   EX: NG_PNEU_PRETO_ESCURO_1.PNG
										"423",; //POSICAO X NA ESTRUTURA
										"163"; //POSICAO Y NA ESTRUTURA
									};
								},;
								{; //SEXTO EIXO
									{;
										"1",; //CODIGO DA IMAGEM DO PNEU   EX: NG_PNEU_PRETO_ESCURO_1.PNG
										"523",; //POSICAO X NA ESTRUTURA
										"007"; //POSICAO Y NA ESTRUTURA
									},;
									{;
										"1",; //CODIGO DA IMAGEM DO PNEU   EX: NG_PNEU_PRETO_ESCURO_1.PNG
										"523",; //POSICAO X NA ESTRUTURA
										"033"; //POSICAO Y NA ESTRUTURA
									},;
									{;
										"1",; //CODIGO DA IMAGEM DO PNEU   EX: NG_PNEU_PRETO_ESCURO_1.PNG
										"523",; //POSICAO X NA ESTRUTURA
										"135"; //POSICAO Y NA ESTRUTURA
									},;
									{;
										"1",; //CODIGO DA IMAGEM DO PNEU   EX: NG_PNEU_PRETO_ESCURO_1.PNG
										"523",; //POSICAO X NA ESTRUTURA
										"163"; //POSICAO Y NA ESTRUTURA
									};
								};
							},;
							{; //STEPES
								{;
									{;
										"2",; //CODIGO DA IMAGEM DO PNEU   EX: NG_PNEU_PRETO_ESCURO_1.PNG
										"590",; //POSICAO X NA ESTRUTURA
										"060"; //POSICAO Y NA ESTRUTURA
									},;
									{;
										"2",; //CODIGO DA IMAGEM DO PNEU   EX: NG_PNEU_PRETO_ESCURO_1.PNG
										"474",; //POSICAO X NA ESTRUTURA
										"060"; //POSICAO Y NA ESTRUTURA
									},;
									{;
										"2",; //CODIGO DA IMAGEM DO PNEU   EX: NG_PNEU_PRETO_ESCURO_1.PNG
										"374",; //POSICAO X NA ESTRUTURA
										"060"; //POSICAO Y NA ESTRUTURA
									},;
									{;
										"2",; //CODIGO DA IMAGEM DO PNEU   EX: NG_PNEU_PRETO_ESCURO_1.PNG
										"274",; //POSICAO X NA ESTRUTURA
										"060"; //POSICAO Y NA ESTRUTURA
									};
								};
							};
				};
		)

		*********************************************************************************

		aAdd(aEstruTemp,{	"55",; //CODIGO DA IMAGEM DA ESTRUTURA   EX: NG_ESTRUTURA_1.PNG
							"511",; //TAMANHO X EM PIXEL
							"288",; //TAMANHO Y EM PIXEL
							{;
								{;	//PRIMEIRO EIXO
									{;
										"1",; //CODIGO DA IMAGEM DO PNEU   EX: NG_PNEU_PRETO_ESCURO_1.PNG
										"064",; //POSICAO X NA ESTRUTURA
										"006"; //POSICAO Y NA ESTRUTURA
									},;
									{;
										"1",; //CODIGO DA IMAGEM DO PNEU   EX: NG_PNEU_PRETO_ESCURO_1.PNG
										"064",; //POSICAO X NA ESTRUTURA
										"032"; //POSICAO Y NA ESTRUTURA
									},;
									{;
										"1",; //CODIGO DA IMAGEM DO PNEU   EX: NG_PNEU_PRETO_ESCURO_1.PNG
										"064",; //POSICAO X NA ESTRUTURA
										"227"; //POSICAO Y NA ESTRUTURA
									},;
									{;
										"1",; //CODIGO DA IMAGEM DO PNEU   EX: NG_PNEU_PRETO_ESCURO_1.PNG
										"064",; //POSICAO X NA ESTRUTURA
										"253"; //POSICAO Y NA ESTRUTURA
									};
								},;
								{; //SEGUNDO EIXO
									{;
										"1",; //CODIGO DA IMAGEM DO PNEU   EX: NG_PNEU_PRETO_ESCURO_1.PNG
										"165",; //POSICAO X NA ESTRUTURA
										"006"; //POSICAO Y NA ESTRUTURA
									},;
									{;
										"1",; //CODIGO DA IMAGEM DO PNEU   EX: NG_PNEU_PRETO_ESCURO_1.PNG
										"165",; //POSICAO X NA ESTRUTURA
										"032"; //POSICAO Y NA ESTRUTURA
									},;
									{;
										"1",; //CODIGO DA IMAGEM DO PNEU   EX: NG_PNEU_PRETO_ESCURO_1.PNG
										"165",; //POSICAO X NA ESTRUTURA
										"227"; //POSICAO Y NA ESTRUTURA
									},;
									{;
										"1",; //CODIGO DA IMAGEM DO PNEU   EX: NG_PNEU_PRETO_ESCURO_1.PNG
										"165",; //POSICAO X NA ESTRUTURA
										"253"; //POSICAO Y NA ESTRUTURA
									};
								},;
								{; //TERCEIRO EIXO
									{;
										"1",; //CODIGO DA IMAGEM DO PNEU   EX: NG_PNEU_PRETO_ESCURO_1.PNG
										"265",; //POSICAO X NA ESTRUTURA
										"006"; //POSICAO Y NA ESTRUTURA
									},;
									{;
										"1",; //CODIGO DA IMAGEM DO PNEU   EX: NG_PNEU_PRETO_ESCURO_1.PNG
										"265",; //POSICAO X NA ESTRUTURA
										"032"; //POSICAO Y NA ESTRUTURA
									},;
									{;
										"1",; //CODIGO DA IMAGEM DO PNEU   EX: NG_PNEU_PRETO_ESCURO_1.PNG
										"265",; //POSICAO X NA ESTRUTURA
										"227"; //POSICAO Y NA ESTRUTURA
									},;
									{;
										"1",; //CODIGO DA IMAGEM DO PNEU   EX: NG_PNEU_PRETO_ESCURO_1.PNG
										"265",; //POSICAO X NA ESTRUTURA
										"253"; //POSICAO Y NA ESTRUTURA
									};
								},;
								{; //QUARTO EIXO
									{;
										"1",; //CODIGO DA IMAGEM DO PNEU   EX: NG_PNEU_PRETO_ESCURO_1.PNG
										"365",; //POSICAO X NA ESTRUTURA
										"006"; //POSICAO Y NA ESTRUTURA
									},;
									{;
										"1",; //CODIGO DA IMAGEM DO PNEU   EX: NG_PNEU_PRETO_ESCURO_1.PNG
										"365",; //POSICAO X NA ESTRUTURA
										"032"; //POSICAO Y NA ESTRUTURA
									},;
									{;
										"1",; //CODIGO DA IMAGEM DO PNEU   EX: NG_PNEU_PRETO_ESCURO_1.PNG
										"365",; //POSICAO X NA ESTRUTURA
										"227"; //POSICAO Y NA ESTRUTURA
									},;
									{;
										"1",; //CODIGO DA IMAGEM DO PNEU   EX: NG_PNEU_PRETO_ESCURO_1.PNG
										"365",; //POSICAO X NA ESTRUTURA
										"253"; //POSICAO Y NA ESTRUTURA
									};
								};
							},;
							{; //STEPES
								{;
								};
							};
				};
		)

		*********************************************************************************


		aAdd(aEstruTemp,{	"57",; //CODIGO DA IMAGEM DA ESTRUTURA   EX: NG_ESTRUTURA_1.PNG
							"300",; //TAMANHO X EM PIXEL
							"185",; //TAMANHO Y EM PIXEL
							{;
								{;//PRIMEIRO EIXO
									{;
										"1",; //CODIGO DA IMAGEM DO PNEU   EX: NG_PNEU_PRETO_ESCURO_1.PNG
										"70",; //POSICAO X NA ESTRUTURA
										"0"; //POSICAO Y NA ESTRUTURA
									},;
									{;
										"1",; //CODIGO DA IMAGEM DO PNEU   EX: NG_PNEU_PRETO_ESCURO_1.PNG
										"70",; //POSICAO X NA ESTRUTURA
										"155"; //POSICAO Y NA ESTRUTURA
									};
								},;
								{;//SEGUNDO EIXO
									{;
										"1",; //CODIGO DA IMAGEM DO PNEU   EX: NG_PNEU_PRETO_ESCURO_1.PNG
										"180",; //PrOSICAO X NA ESTRUTURA
										"0"; //POSICAO Y NA ESTRUTURA
									},;
									{;
										"1",; //CODIGO DA IMAGEM DO PNEU   EX: NG_PNEU_PRETO_ESCURO_1.PNG
										"180",; //POSICAO X NA ESTRUTURA
										"155"; //POSICAO Y NA ESTRUTURA
									};
								};
							},;
							{; //STEPES
								{;
								};
							};
						};
		)

		*********************************************************************************

		aAdd(aEstruTemp,{	"56",; //CODIGO DA IMAGEM DA ESTRUTURA   EX: NG_ESTRUTURA_1.PNG
							"498",; //TAMANHO X EM PIXEL
							"197",; //TAMANHO Y EM PIXEL
							{;
								{;//PRIMEIRO EIXO
									{;
										"4",; //CODIGO DA IMAGEM DO PNEU   EX: NG_PNEU_PRETO_ESCURO_1.PNG
										"102",; //POSICAO X NA ESTRUTURA
										"20"; //POSICAO Y NA ESTRUTURA
									},;
									{;
										"4",; //CODIGO DA IMAGEM DO PNEU   EX: NG_PNEU_PRETO_ESCURO_1.PNG
										"102",; //POSICAO X NA ESTRUTURA
										"123"; //POSICAO Y NA ESTRUTURA
									};
								},;
								{;//SEGUNDO EIXO
									{;
										"4",; //CODIGO DA IMAGEM DO PNEU   EX: NG_PNEU_PRETO_ESCURO_1.PNG
										"410",; //POSICAO X NA ESTRUTURA
										"22"; //POSICAO Y NA ESTRUTURA
									},;
									{;
										"4",; //CODIGO DA IMAGEM DO PNEU   EX: NG_PNEU_PRETO_ESCURO_1.PNG
										"410",; //POSICAO X NA ESTRUTURA
										"123"; //POSICAO Y NA ESTRUTURA
									};
								};
							},;
							{; //STEPES
								{;
								};
							};
						};
		)

		*********************************************************************************

		aAdd(aEstruTemp,{	"58",; //CODIGO DA IMAGEM DA ESTRUTURA   EX: NG_ESTRUTURA_1.PNG
							"560",; //TAMANHO X EM PIXEL
							"200",; //TAMANHO Y EM PIXEL
							{;
								{; //PRIMEIRO EIXO
									{;
										"1",; //CODIGO DA IMAGEM DO PNEU   EX: NG_PNEU_PRETO_ESCURO_1.PNG
										"033",; //POSICAO X NA ESTRUTURA
										"012"; //POSICAO Y NA ESTRUTURA
									},;
									{;
										"1",; //CODIGO DA IMAGEM DO PNEU   EX: NG_PNEU_PRETO_ESCURO_1.PNG
										"033",; //POSICAO X NA ESTRUTURA
										"159"; //POSICAO Y NA ESTRUTURA
									};
								},;
								{; //SEGUNDO EIXO
									{;
										"1",; //CODIGO DA IMAGEM DO PNEU   EX: NG_PNEU_PRETO_ESCURO_1.PNG
										"141",; //POSICAO X NA ESTRUTURA
										"012"; //POSICAO Y NA ESTRUTURA
									},;
									{;
										"1",; //CODIGO DA IMAGEM DO PNEU   EX: NG_PNEU_PRETO_ESCURO_1.PNG
										"141",; //POSICAO X NA ESTRUTURA
										"159"; //POSICAO Y NA ESTRUTURA
									};
								},;
								{; //TERCEIRO EIXO
									{;
										"1",; //CODIGO DA IMAGEM DO PNEU   EX: NG_PNEU_PRETO_ESCURO_1.PNG
										"328",; //POSICAO X NA ESTRUTURA
										"006"; //POSICAO Y NA ESTRUTURA
									},;
									{;
										"1",; //CODIGO DA IMAGEM DO PNEU   EX: NG_PNEU_PRETO_ESCURO_1.PNG
										"328",; //POSICAO X NA ESTRUTURA
										"161"; //POSICAO Y NA ESTRUTURA
									};
								},;
								{; //QUARTO EIXO
									{;
										"1",; //CODIGO DA IMAGEM DO PNEU   EX: NG_PNEU_PRETO_ESCURO_1.PNG
										"438",; //POSICAO X NA ESTRUTURA
										"006"; //POSICAO Y NA ESTRUTURA
									},;
									{;
										"1",; //CODIGO DA IMAGEM DO PNEU   EX: NG_PNEU_PRETO_ESCURO_1.PNG
										"438",; //POSICAO X NA ESTRUTURA
										"161"; //POSICAO Y NA ESTRUTURA
									};
								};
							},;
							{; //STEPES
								{;
									{;
										"2",; //CODIGO DA IMAGEM DO PNEU   EX: NG_PNEU_PRETO_ESCURO_1.PNG
										"230",; //POSICAO X NA ESTRUTURA
										"025"; //POSICAO Y NA ESTRUTURA
									},;
									{;
										"2",; //CODIGO DA IMAGEM DO PNEU   EX: NG_PNEU_PRETO_ESCURO_1.PNG
										"230",; //POSICAO X NA ESTRUTURA
										"095"; //POSICAO Y NA ESTRUTURA
									};
								};
							};
						};
		)

		*********************************************************************************

		aAdd(aEstruTemp,{	"59",; //CODIGO DA IMAGEM DA ESTRUTURA   EX: NG_ESTRUTURA_1.PNG
							"550",; //TAMANHO X EM PIXEL
							"300",; //TAMANHO Y EM PIXEL
							{;	//PNEUS NA ESTRUTURA
								{; //PRIMEIRO EIXO
									{;
										"4",; //CODIGO DA IMAGEM DO PNEU   EX: NG_PNEU_PRETO_ESCURO_1.PNG
										"282",; //POSICAO X NA ESTRUTURA
										"22"; //POSICAO Y NA ESTRUTURA
									},;
									{;
										"4",; //CODIGO DA IMAGEM DO PNEU   EX: NG_PNEU_PRETO_ESCURO_1.PNG
										"283",; //POSICAO X NA ESTRUTURA
										"244"; //POSICAO Y NA ESTRUTURA
									};
								};
							},;
							{; //STEPES
								{;
								};
							};
				};
		)

		*********************************************************************************

		aAdd(aEstruTemp,{	"60",; //CODIGO DA IMAGEM DA ESTRUTURA   EX: NG_ESTRUTURA_1.PNG
							"605",; //TAMANHO X EM PIXEL
							"232",; //TAMANHO Y EM PIXEL
							{;
								{;//PRIMEIRO EIXO
									{;
										"1",; //CODIGO DA IMAGEM DO PNEU   EX: NG_PNEU_PRETO_ESCURO_1.PNG
										"180",; //POSICAO X NA ESTRUTURA
										"50"; //POSICAO Y NA ESTRUTURA
									},;
									{;
										"1",; //CODIGO DA IMAGEM DO PNEU   EX: NG_PNEU_PRETO_ESCURO_1.PNG
										"180",; //POSICAO X NA ESTRUTURA
										"155"; //POSICAO Y NA ESTRUTURA
									};
								},;
								{;//SEGUNDO EIXO
									{;
										"4",; //CODIGO DA IMAGEM DO PNEU   EX: NG_PNEU_PRETO_ESCURO_1.PNG
										"331",; //POSICAO X NA ESTRUTURA
										"12"; //POSICAO Y NA ESTRUTURA
									},;
									{;
										"4",; //CODIGO DA IMAGEM DO PNEU   EX: NG_PNEU_PRETO_ESCURO_1.PNG
										"331",; //POSICAO X NA ESTRUTURA
										"185"; //POSICAO Y NA ESTRUTURA
									};
								};
							},;
							{; //STEPES
								{;
								};
							};
						};
		)

		*********************************************************************************

		aAdd(aEstruTemp,{	"61",; //CODIGO DA IMAGEM DA ESTRUTURA   EX: NG_ESTRUTURA_1.PNG
							"365",; //TAMANHO X EM PIXEL
							"232",; //TAMANHO Y EM PIXEL
							{;
								{;//SEGUNDO EIXO
									{;
										"1",; //CODIGO DA IMAGEM DO PNEU   EX: NG_PNEU_PRETO_ESCURO_1.PNG
										"38",; //POSICAO X NA ESTRUTURA
										"27"; //POSICAO Y NA ESTRUTURA
									},;
									{;
										"1",; //CODIGO DA IMAGEM DO PNEU   EX: NG_PNEU_PRETO_ESCURO_1.PNG
										"38",; //POSICAO X NA ESTRUTURA
										"177"; //POSICAO Y NA ESTRUTURA
									};
								},;
								{;//PRIMEIRO EIXO
									{;
										"4",; //CODIGO DA IMAGEM DO PNEU   EX: NG_PNEU_PRETO_ESCURO_1.PNG
										"250",; //POSICAO X NA ESTRUTURA
										"11"; //POSICAO Y NA ESTRUTURA
									},;
									{;
										"4",; //CODIGO DA IMAGEM DO PNEU   EX: NG_PNEU_PRETO_ESCURO_1.PNG
										"250",; //POSICAO X NA ESTRUTURA
										"187"; //POSICAO Y NA ESTRUTURA
									};
								};
							},;
							{; //STEPES
								{;
								};
							};
						};
		)


		*********************************************************************************

		aAdd(aEstruTemp,{	"63",; //CODIGO DA IMAGEM DA ESTRUTURA   EX: NG_ESTRUTURA_1.PNG
							"498",; //TAMANHO X EM PIXEL
							"197",; //TAMANHO Y EM PIXEL
							{;
								{;//PRIMEIRO EIXO
									{;
										"4",; //CODIGO DA IMAGEM DO PNEU   EX: NG_PNEU_PRETO_ESCURO_1.PNG
										"160",; //POSICAO X NA ESTRUTURA
										"006"; //POSICAO Y NA ESTRUTURA
									},;
									{;
										"4",; //CODIGO DA IMAGEM DO PNEU   EX: NG_PNEU_PRETO_ESCURO_1.PNG
										"160",; //POSICAO X NA ESTRUTURA
										"160"; //POSICAO Y NA ESTRUTURA
									};
								},;
								{;//SEGUNDO EIXO
									{;
										"4",; //CODIGO DA IMAGEM DO PNEU   EX: NG_PNEU_PRETO_ESCURO_1.PNG
										"345",; //POSICAO X NA ESTRUTURA
										"006"; //POSICAO Y NA ESTRUTURA
									},;
									{;
										"4",; //CODIGO DA IMAGEM DO PNEU   EX: NG_PNEU_PRETO_ESCURO_1.PNG
										"345",; //POSICAO X NA ESTRUTURA
										"160"; //POSICAO Y NA ESTRUTURA
									};
								};
							},;
							{; //STEPES
								{;
								};
							};
						};
		)
		*********************************************************************************************
		aAdd(aEstruTemp,{	"64",; //CODIGO DA IMAGEM DA ESTRUTURA   EX: NG_ESTRUTURA_1.PNG
							"547",; //TAMANHO X EM PIXEL
							"196",; //TAMANHO Y EM PIXEL
							{;
								{; //PRIMEIRO EIXO
									{;
										"1",; //CODIGO DA IMAGEM DO PNEU   EX: NG_PNEU_PRETO_ESCURO_1.PNG
										"028",; //POSICAO X NA ESTRUTURA
										"011"; //POSICAO Y NA ESTRUTURA
									},;
									{;
										"1",; //CODIGO DA IMAGEM DO PNEU   EX: NG_PNEU_PRETO_ESCURO_1.PNG
										"028",; //POSICAO X NA ESTRUTURA
										"156"; //POSICAO Y NA ESTRUTURA
									};
								},;
								{; //SEGUNDO EIXO
									{;
										"1",; //CODIGO DA IMAGEM DO PNEU   EX: NG_PNEU_PRETO_ESCURO_1.PNG
										"136",; //POSICAO X NA ESTRUTURA
										"011"; //POSICAO Y NA ESTRUTURA
									},;
									{;
										"1",; //CODIGO DA IMAGEM DO PNEU   EX: NG_PNEU_PRETO_ESCURO_1.PNG
										"136",; //POSICAO X NA ESTRUTURA
										"156"; //POSICAO Y NA ESTRUTURA
									};
								},;
								{; //TERCEIRO EIXO
									{;
										"1",; //CODIGO DA IMAGEM DO PNEU   EX: NG_PNEU_PRETO_ESCURO_1.PNG
										"323",; //POSICAO X NA ESTRUTURA
										"004"; //POSICAO Y NA ESTRUTURA
									},;
									{;
										"1",; //CODIGO DA IMAGEM DO PNEU   EX: NG_PNEU_PRETO_ESCURO_1.PNG
										"323",; //POSICAO X NA ESTRUTURA
										"029"; //POSICAO Y NA ESTRUTURA
									},;
									{;
										"1",; //CODIGO DA IMAGEM DO PNEU   EX: NG_PNEU_PRETO_ESCURO_1.PNG
										"323",; //POSICAO X NA ESTRUTURA
										"135"; //POSICAO Y NA ESTRUTURA
									},;
									{;
										"1",; //CODIGO DA IMAGEM DO PNEU   EX: NG_PNEU_PRETO_ESCURO_1.PNG
										"323",; //POSICAO X NA ESTRUTURA
										"160"; //POSICAO Y NA ESTRUTURA
									};
								},;
								{; //QUARTO EIXO
									{;
										"1",; //CODIGO DA IMAGEM DO PNEU   EX: NG_PNEU_PRETO_ESCURO_1.PNG
										"435",; //POSICAO X NA ESTRUTURA
										"004"; //POSICAO Y NA ESTRUTURA
									},;
									{;
										"1",; //CODIGO DA IMAGEM DO PNEU   EX: NG_PNEU_PRETO_ESCURO_1.PNG
										"435",; //POSICAO X NA ESTRUTURA
										"029"; //POSICAO Y NA ESTRUTURA
									},;
									{;
										"1",; //CODIGO DA IMAGEM DO PNEU   EX: NG_PNEU_PRETO_ESCURO_1.PNG
										"435",; //POSICAO X NA ESTRUTURA
										"135"; //POSICAO Y NA ESTRUTURA
									},;
									{;
										"1",; //CODIGO DA IMAGEM DO PNEU   EX: NG_PNEU_PRETO_ESCURO_1.PNG
										"435",; //POSICAO X NA ESTRUTURA
										"160"; //POSICAO Y NA ESTRUTURA
									};
								};
							},;
							{; //STEPES
								{;
									{;
										"2",; //CODIGO DA IMAGEM DO PNEU   EX: NG_PNEU_PRETO_ESCURO_1.PNG
										"230",; //POSICAO X NA ESTRUTURA
										"025"; //POSICAO Y NA ESTRUTURA
									},;
									{;
										"2",; //CODIGO DA IMAGEM DO PNEU   EX: NG_PNEU_PRETO_ESCURO_1.PNG
										"230",; //POSICAO X NA ESTRUTURA
										"095"; //POSICAO Y NA ESTRUTURA
									};
								};
							};
						};
		)

		*********************************************************************************************
		aAdd(aEstruTemp,{	"65",; //CODIGO DA IMAGEM DA ESTRUTURA   EX: NG_ESTRUTURA_1.PNG
							"800",; //TAMANHO X EM PIXEL
							"171",; //TAMANHO Y EM PIXEL
							{;
								{;//PRIMEIRO EIXO
									{;
										"1",; //CODIGO DA IMAGEM DO PNEU   EX: NG_PNEU_PRETO_ESCURO_1.PNG
										"069",; //POSICAO X NA ESTRUTURA
										"000"; //POSICAO Y NA ESTRUTURA
									},;
									{;
										"1",; //CODIGO DA IMAGEM DO PNEU   EX: NG_PNEU_PRETO_ESCURO_1.PNG
										"069",; //POSICAO X NA ESTRUTURA
										"140"; //POSICAO Y NA ESTRUTURA
									};
								},;
								{;//SEGUNDO EIXO
									{;
										"1",; //CODIGO DA IMAGEM DO PNEU   EX: NG_PNEU_PRETO_ESCURO_1.PNG
										"165",; //POSICAO X NA ESTRUTURA
										"000"; //POSICAO Y NA ESTRUTURA
									},;
									{;
										"1",; //CODIGO DA IMAGEM DO PNEU   EX: NG_PNEU_PRETO_ESCURO_1.PNG
										"165",; //POSICAO X NA ESTRUTURA
										"141"; //POSICAO Y NA ESTRUTURA
									};
								},;
								{;//TERCEIRO EIXO
									{;
										"1",; //CODIGO DA IMAGEM DO PNEU   EX: NG_PNEU_PRETO_ESCURO_1.PNG
										"316",; //POSICAO X NA ESTRUTURA
										"000"; //POSICAO Y NA ESTRUTURA
									},;
									{;
										"1",; //CODIGO DA IMAGEM DO PNEU   EX: NG_PNEU_PRETO_ESCURO_1.PNG
										"316",; //POSICAO X NA ESTRUTURA
										"141"; //POSICAO Y NA ESTRUTURA
									};
								},;
								{;//QUARTO EIXO
									{;
										"1",; //CODIGO DA IMAGEM DO PNEU   EX: NG_PNEU_PRETO_ESCURO_1.PNG
										"447",; //POSICAO X NA ESTRUTURA
										"000"; //POSICAO Y NA ESTRUTURA
									},;
									{;
										"1",; //CODIGO DA IMAGEM DO PNEU   EX: NG_PNEU_PRETO_ESCURO_1.PNG
										"447",; //POSICAO X NA ESTRUTURA
										"026"; //POSICAO Y NA ESTRUTURA
									},;
									{;
										"1",; //CODIGO DA IMAGEM DO PNEU   EX: NG_PNEU_PRETO_ESCURO_1.PNG
										"447",; //POSICAO X NA ESTRUTURA
										"115"; //POSICAO Y NA ESTRUTURA
									},;
									{;
										"1",; //CODIGO DA IMAGEM DO PNEU   EX: NG_PNEU_PRETO_ESCURO_1.PNG
										"447",; //POSICAO X NA ESTRUTURA
										"141"; //POSICAO Y NA ESTRUTURA
									};
								},;
								{;//QUINTO EIXO
									{;
										"1",; //CODIGO DA IMAGEM DO PNEU   EX: NG_PNEU_PRETO_ESCURO_1.PNG
										"538",; //POSICAO X NA ESTRUTURA
										"000"; //POSICAO Y NA ESTRUTURA
									},;
									{;
										"1",; //CODIGO DA IMAGEM DO PNEU   EX: NG_PNEU_PRETO_ESCURO_1.PNG
										"538",; //POSICAO X NA ESTRUTURA
										"026"; //POSICAO Y NA ESTRUTURA
									},;
									{;
										"1",; //CODIGO DA IMAGEM DO PNEU   EX: NG_PNEU_PRETO_ESCURO_1.PNG
										"538",; //POSICAO X NA ESTRUTURA
										"115"; //POSICAO Y NA ESTRUTURA
									},;
									{;
										"1",; //CODIGO DA IMAGEM DO PNEU   EX: NG_PNEU_PRETO_ESCURO_1.PNG
										"538",; //POSICAO X NA ESTRUTURA
										"141"; //POSICAO Y NA ESTRUTURA
									};
								},;
								{;//SEXTO EIXO
									{;
										"1",; //CODIGO DA IMAGEM DO PNEU   EX: NG_PNEU_PRETO_ESCURO_1.PNG
										"655",; //POSICAO X NA ESTRUTURA
										"000"; //POSICAO Y NA ESTRUTURA
									},;
									{;
										"1",; //CODIGO DA IMAGEM DO PNEU   EX: NG_PNEU_PRETO_ESCURO_1.PNG
										"655",; //POSICAO X NA ESTRUTURA
										"141"; //POSICAO Y NA ESTRUTURA
									};
								};
							},;
							{; //STEPES
								{;
								};
							};
						};
		)
		*********************************************************************************
		aAdd(aEstruTemp,{	"66",; //CODIGO DA IMAGEM DA ESTRUTURA   EX: NG_ESTRUTURA_1.PNG
							"804",; //TAMANHO X EM PIXEL
							"196",; //TAMANHO Y EM PIXEL
							{;
								{; //PRIMEIRO EIXO
									{;
										"1",; //CODIGO DA IMAGEM DO PNEU   EX: NG_PNEU_PRETO_ESCURO_1.PNG
										"235",; //POSICAO X NA ESTRUTURA
										"006"; //POSICAO Y NA ESTRUTURA
									},;
									{;
										"1",; //CODIGO DA IMAGEM DO PNEU   EX: NG_PNEU_PRETO_ESCURO_1.PNG
										"235",; //POSICAO X NA ESTRUTURA
										"031"; //POSICAO Y NA ESTRUTURA
									},;
									{;
										"1",; //CODIGO DA IMAGEM DO PNEU   EX: NG_PNEU_PRETO_ESCURO_1.PNG
										"235",; //POSICAO X NA ESTRUTURA
										"136"; //POSICAO Y NA ESTRUTURA
									},;
									{;
										"1",; //CODIGO DA IMAGEM DO PNEU   EX: NG_PNEU_PRETO_ESCURO_1.PNG
										"235",; //POSICAO X NA ESTRUTURA
										"162"; //POSICAO Y NA ESTRUTURA
									};
								},;
								{;//SEGUNDO EIXO
									{;
										"1",; //CODIGO DA IMAGEM DO PNEU   EX: NG_PNEU_PRETO_ESCURO_1.PNG
										"345",; //POSICAO X NA ESTRUTURA
										"006"; //POSICAO Y NA ESTRUTURA
									},;
									{;
										"1",; //CODIGO DA IMAGEM DO PNEU   EX: NG_PNEU_PRETO_ESCURO_1.PNG
										"345",; //POSICAO X NA ESTRUTURA
										"031"; //POSICAO Y NA ESTRUTURA
									},;
									{;
										"1",; //CODIGO DA IMAGEM DO PNEU   EX: NG_PNEU_PRETO_ESCURO_1.PNG
										"345",; //POSICAO X NA ESTRUTURA
										"136"; //POSICAO Y NA ESTRUTURA
									},;
									{;
										"1",; //CODIGO DA IMAGEM DO PNEU   EX: NG_PNEU_PRETO_ESCURO_1.PNG
										"345",; //POSICAO X NA ESTRUTURA
										"162"; //POSICAO Y NA ESTRUTURA
									};
								},;
								{;//TERCEIRO EIXO
									{;
										"1",; //CODIGO DA IMAGEM DO PNEU   EX: NG_PNEU_PRETO_ESCURO_1.PNG
										"460",; //POSICAO X NA ESTRUTURA
										"006"; //POSICAO Y NA ESTRUTURA
									},;
									{;
										"1",; //CODIGO DA IMAGEM DO PNEU   EX: NG_PNEU_PRETO_ESCURO_1.PNG
										"460",; //POSICAO X NA ESTRUTURA
										"031"; //POSICAO Y NA ESTRUTURA
									},;
									{;
										"1",; //CODIGO DA IMAGEM DO PNEU   EX: NG_PNEU_PRETO_ESCURO_1.PNG
										"460",; //POSICAO X NA ESTRUTURA
										"136"; //POSICAO Y NA ESTRUTURA
									},;
									{;
										"1",; //CODIGO DA IMAGEM DO PNEU   EX: NG_PNEU_PRETO_ESCURO_1.PNG
										"460",; //POSICAO X NA ESTRUTURA
										"162"; //POSICAO Y NA ESTRUTURA
									};
								},;
								{; //QUARTO EIXO
									{;
										"1",; //CODIGO DA IMAGEM DO PNEU   EX: NG_PNEU_PRETO_ESCURO_1.PNG
										"570",; //POSICAO X NA ESTRUTURA
										"006"; //POSICAO Y NA ESTRUTURA
									},;
									{;
										"1",; //CODIGO DA IMAGEM DO PNEU   EX: NG_PNEU_PRETO_ESCURO_1.PNG
										"570",; //POSICAO X NA ESTRUTURA
										"031"; //POSICAO Y NA ESTRUTURA
									},;
									{;
										"1",; //CODIGO DA IMAGEM DO PNEU   EX: NG_PNEU_PRETO_ESCURO_1.PNG
										"570",; //POSICAO X NA ESTRUTURA
										"136"; //POSICAO Y NA ESTRUTURA
									},;
									{;
										"1",; //CODIGO DA IMAGEM DO PNEU   EX: NG_PNEU_PRETO_ESCURO_1.PNG
										"570",; //POSICAO X NA ESTRUTURA
										"162"; //POSICAO Y NA ESTRUTURA
									};
								},;
								{;//QUINTO EIXO
									{;
										"1",; //CODIGO DA IMAGEM DO PNEU   EX: NG_PNEU_PRETO_ESCURO_1.PNG
										"690",; //POSICAO X NA ESTRUTURA
										"006"; //POSICAO Y NA ESTRUTURA
									},;
									{;
										"1",; //CODIGO DA IMAGEM DO PNEU   EX: NG_PNEU_PRETO_ESCURO_1.PNG
										"690",; //POSICAO X NA ESTRUTURA
										"031"; //POSICAO Y NA ESTRUTURA
									},;
									{;
										"1",; //CODIGO DA IMAGEM DO PNEU   EX: NG_PNEU_PRETO_ESCURO_1.PNG
										"690",; //POSICAO X NA ESTRUTURA
										"136"; //POSICAO Y NA ESTRUTURA
									},;
									{;
										"1",; //CODIGO DA IMAGEM DO PNEU   EX: NG_PNEU_PRETO_ESCURO_1.PNG
										"690",; //POSICAO X NA ESTRUTURA
										"162"; //POSICAO Y NA ESTRUTURA
									};
								};
							},;
							{; //ESTEPES
								{;
									{;
										"2",; //CODIGO DA IMAGEM DO PNEU   EX: NG_PNEU_PRETO_ESCURO_1.PNG
										"125",; //POSICAO X NA ESTRUTURA
										"025"; //POSICAO Y NA ESTRUTURA
									},;
									{;
										"2",; //CODIGO DA IMAGEM DO PNEU   EX: NG_PNEU_PRETO_ESCURO_1.PNG
										"125",; //POSICAO X NA ESTRUTURA
										"095"; //POSICAO Y NA ESTRUTURA
									},;
									{;
										"2",; //CODIGO DA IMAGEM DO PNEU   EX: NG_PNEU_PRETO_ESCURO_1.PNG
										"20",; //POSICAO X NA ESTRUTURA
										"025"; //POSICAO Y NA ESTRUTURA
									},;
									{;
										"2",; //CODIGO DA IMAGEM DO PNEU   EX: NG_PNEU_PRETO_ESCURO_1.PNG
										"20",; //POSICAO X NA ESTRUTURA
										"095"; //POSICAO Y NA ESTRUTURA
									};
								};
							};
				};
		)
		*********************************************************************************
		aAdd(aEstruTemp,{	"67",; //CODIGO DA IMAGEM DA ESTRUTURA   EX: NG_ESTRUTURA_1.PNG
							"571",; //TAMANHO X EM PIXEL
							"302",; //TAMANHO Y EM PIXEL
								{;
									{;	//PRIMEIRO EIXO
										{;
											"4",; //CODIGO DA IMAGEM DO PNEU   EX: NG_PNEU_PRETO_ESCURO_1.PNG
											"178",; //POSICAO X NA ESTRUTURA
											"069"; //POSICAO Y NA ESTRUTURA
										},;
										{;
											"4",; //CODIGO DA IMAGEM DO PNEU   EX: NG_PNEU_PRETO_ESCURO_1.PNG
											"178",; //POSICAO X NA ESTRUTURA
											"206"; //POSICAO Y NA ESTRUTURA
										};
									},;
									{;	//SEGUNDO EIXO
										{;
											"3",; //CODIGO DA IMAGEM DO PNEU   EX: NG_PNEU_PRETO_ESCURO_1.PNG
											"341",; //POSICAO X NA ESTRUTURA
											"046"; //POSICAO Y NA ESTRUTURA
										},;
										{;
											"3",; //CODIGO DA IMAGEM DO PNEU   EX: NG_PNEU_PRETO_ESCURO_1.PNG
											"341",; //POSICAO X NA ESTRUTURA
											"244"; //POSICAO Y NA ESTRUTURA
										};
									},;
									{; //TERCEIRO EIXO
										{;
											"3",; //CODIGO DA IMAGEM DO PNEU   EX: NG_PNEU_PRETO_ESCURO_1.PNG
											"421",; //POSICAO X NA ESTRUTURA
											"046"; //POSICAO Y NA ESTRUTURA
										},;
										{;
											"3",; //CODIGO DA IMAGEM DO PNEU   EX: NG_PNEU_PRETO_ESCURO_1.PNG
											"421",; //POSICAO X NA ESTRUTURA
											"244"; //POSICAO Y NA ESTRUTURA
										};
									};
								},;
								{; //STEPES
									{;
									};
								};
							};
		)
		*********************************************************************************

		aAdd(aEstruTemp,{	"68",; //CODIGO DA IMAGEM DA ESTRUTURA   EX: NG_ESTRUTURA_1.PNG
							"323",; //TAMANHO X EM PIXEL
							"223",; //TAMANHO Y EM PIXEL
	  							{;
									{;	//PRIMEIRO EIXO
										{;    //PNEU
											"1",; //CODIGO DA IMAGEM DO PNEU   EX: NG_PNEU_PRETO_ESCURO_1.PNG
											"003",; //POSICAO X NA ESTRUTURA
											"096"; //POSICAO Y NA ESTRUTURA
										};
									},;
									{;	//SEGUNDO EIXO
										{;
											"1",; //CODIGO DA IMAGEM DO PNEU   EX: NG_PNEU_PRETO_ESCURO_1.PNG
											"172",; //POSICAO X NA ESTRUTURA
											"009"; //POSICAO Y NA ESTRUTURA
										},;
										{;
											"1",; //CODIGO DA IMAGEM DO PNEU   EX: NG_PNEU_PRETO_ESCURO_1.PNG
											"172",; //POSICAO X NA ESTRUTURA
											"185"; //POSICAO Y NA ESTRUTURA
										};
									};
								},;
								{; //STEPES
									{;
									};
								};
						};
		)

		*********************************************************************************

		aAdd(aEstruTemp,{	"69",; //CODIGO DA IMAGEM DA ESTRUTURA   EX: NG_ESTRUTURA_1.PNG
							"600",; //TAMANHO X EM PIXEL
							"300",; //TAMANHO Y EM PIXEL
								{;
									{;	//PRIMEIRO EIXO
										{;
											"1",; //CODIGO DA IMAGEM DO PNEU   EX: NG_PNEU_PRETO_ESCURO_1.PNG
											"035",; //POSICAO X NA ESTRUTURA
											"012"; //POSICAO Y NA ESTRUTURA
										},;
										{;
											"1",; //CODIGO DA IMAGEM DO PNEU   EX: NG_PNEU_PRETO_ESCURO_1.PNG
											"035",; //POSICAO X NA ESTRUTURA
											"155"; //POSICAO Y NA ESTRUTURA
										};
									},;
									{;	//SEGUNDO EIXO
										{;
											"1",; //CODIGO DA IMAGEM DO PNEU   EX: NG_PNEU_PRETO_ESCURO_1.PNG
											"110",; //POSICAO X NA ESTRUTURA
											"012"; //POSICAO Y NA ESTRUTURA
										},;
										{;
											"1",; //CODIGO DA IMAGEM DO PNEU   EX: NG_PNEU_PRETO_ESCURO_1.PNG
											"110",; //POSICAO X NA ESTRUTURA
											"155"; //POSICAO Y NA ESTRUTURA
										};
									},;
									{; //TERCEIRO EIXO
										{;
											"1",; //CODIGO DA IMAGEM DO PNEU   EX: NG_PNEU_PRETO_ESCURO_1.PNG
											"340",; //POSICAO X NA ESTRUTURA
											"005"; //POSICAO Y NA ESTRUTURA
										},;
										{;
											"1",; //CODIGO DA IMAGEM DO PNEU   EX: NG_PNEU_PRETO_ESCURO_1.PNG
											"340",; //POSICAO X NA ESTRUTURA
											"030"; //POSICAO Y NA ESTRUTURA
										},;
										{;
											"1",; //CODIGO DA IMAGEM DO PNEU   EX: NG_PNEU_PRETO_ESCURO_1.PNG
											"340",; //POSICAO X NA ESTRUTURA
											"137"; //POSICAO Y NA ESTRUTURA
										},;
										{;
											"1",; //CODIGO DA IMAGEM DO PNEU   EX: NG_PNEU_PRETO_ESCURO_1.PNG
											"340",; //POSICAO X NA ESTRUTURA
											"163"; //POSICAO Y NA ESTRUTURA
										};
									};
								},;
								{; //STEPES
									{;
									};
								};
							};
		)

		*********************************************************************************

		aAdd(aEstruTemp,{	"70",; //CODIGO DA IMAGEM DA ESTRUTURA   EX: NG_ESTRUTURA_1.PNG
							"800",; //TAMANHO X EM PIXEL
							"400",; //TAMANHO Y EM PIXEL
								{;
									{;	//PRIMEIRO EIXO
										{;
											"4",; //CODIGO DA IMAGEM DO PNEU   EX: NG_PNEU_PRETO_ESCURO_1.PNG
											"040",; //POSICAO X NA ESTRUTURA
											"015"; //POSICAO Y NA ESTRUTURA
										},;
										{;
											"4",; //CODIGO DA IMAGEM DO PNEU   EX: NG_PNEU_PRETO_ESCURO_1.PNG
											"040",; //POSICAO X NA ESTRUTURA
											"075"; //POSICAO Y NA ESTRUTURA
										};
									},;
									{;	//SEGUNDO EIXO
										{;
											"4",; //CODIGO DA IMAGEM DO PNEU   EX: NG_PNEU_PRETO_ESCURO_1.PNG
											"040",; //POSICAO X NA ESTRUTURA
											"270"; //POSICAO Y NA ESTRUTURA
										},;
										{;
											"4",; //CODIGO DA IMAGEM DO PNEU   EX: NG_PNEU_PRETO_ESCURO_1.PNG
											"040",; //POSICAO X NA ESTRUTURA
											"330"; //POSICAO Y NA ESTRUTURA
										};
									},;
									{;	//TERCEIRO EIXO
										{;
											"4",; //CODIGO DA IMAGEM DO PNEU   EX: NG_PNEU_PRETO_ESCURO_1.PNG
											"160",; //POSICAO X NA ESTRUTURA
											"015"; //POSICAO Y NA ESTRUTURA
										},;
										{;
											"4",; //CODIGO DA IMAGEM DO PNEU   EX: NG_PNEU_PRETO_ESCURO_1.PNG
											"160",; //POSICAO X NA ESTRUTURA
											"075"; //POSICAO Y NA ESTRUTURA
										};
									},;
									{;	//QUARTO EIXO
										{;
											"4",; //CODIGO DA IMAGEM DO PNEU   EX: NG_PNEU_PRETO_ESCURO_1.PNG
											"160",; //POSICAO X NA ESTRUTURA
											"270"; //POSICAO Y NA ESTRUTURA
										},;
										{;
											"4",; //CODIGO DA IMAGEM DO PNEU   EX: NG_PNEU_PRETO_ESCURO_1.PNG
											"160",; //POSICAO X NA ESTRUTURA
											"330"; //POSICAO Y NA ESTRUTURA
										};
									},;
									{;	//QUINTO EIXO
										{;
											"4",; //CODIGO DA IMAGEM DO PNEU   EX: NG_PNEU_PRETO_ESCURO_1.PNG
											"367",; //POSICAO X NA ESTRUTURA
											"015"; //POSICAO Y NA ESTRUTURA
										},;
										{;
											"4",; //CODIGO DA IMAGEM DO PNEU   EX: NG_PNEU_PRETO_ESCURO_1.PNG
											"367",; //POSICAO X NA ESTRUTURA
											"075"; //POSICAO Y NA ESTRUTURA
										};
									},;
									{;	//SEXTO EIXO
										{;
											"4",; //CODIGO DA IMAGEM DO PNEU   EX: NG_PNEU_PRETO_ESCURO_1.PNG
											"367",; //POSICAO X NA ESTRUTURA
											"270"; //POSICAO Y NA ESTRUTURA
										},;
										{;
											"4",; //CODIGO DA IMAGEM DO PNEU   EX: NG_PNEU_PRETO_ESCURO_1.PNG
											"367",; //POSICAO X NA ESTRUTURA
											"330"; //POSICAO Y NA ESTRUTURA
										};
									},;
									{;	//SÉTIMO EIXO
										{;
											"4",; //CODIGO DA IMAGEM DO PNEU   EX: NG_PNEU_PRETO_ESCURO_1.PNG
											"485",; //POSICAO X NA ESTRUTURA
											"015"; //POSICAO Y NA ESTRUTURA
										},;
										{;
											"4",; //CODIGO DA IMAGEM DO PNEU   EX: NG_PNEU_PRETO_ESCURO_1.PNG
											"485",; //POSICAO X NA ESTRUTURA
											"075"; //POSICAO Y NA ESTRUTURA
										};
									},;
									{;	//OITAVO EIXO
										{;
											"4",; //CODIGO DA IMAGEM DO PNEU   EX: NG_PNEU_PRETO_ESCURO_1.PNG
											"485",; //POSICAO X NA ESTRUTURA
											"270"; //POSICAO Y NA ESTRUTURA
										},;
										{;
											"4",; //CODIGO DA IMAGEM DO PNEU   EX: NG_PNEU_PRETO_ESCURO_1.PNG
											"485",; //POSICAO X NA ESTRUTURA
											"330"; //POSICAO Y NA ESTRUTURA
										};
									};
								},;
								{; //STEPES
									{;
									};
								};
							};
		)



		//Valida se a estrutura existe em imagem no RPO
		For nX := 1 to Len(aEstruTemp)
			If aScan(aRPOImg,{|x| cIniImg+aEstruTemp[nX][1]+cExtensao == x }) > 0
				If (!Empty(cCodImg) .And. aEstruTemp[nX][1] != cCodImg) .Or. ;
					(nEixos != Nil .And. nEixos != Len(aEstruTemp[nX][4]))
					Loop
				EndIf

				//aEstruTemp[nX][1] := cIniImg+aEstruTemp[nX][1]+cExtensao

				//Adiciona o numero do eixo em cada pneu da estrutura
				For nY := 1 to Len(aEstruTemp[nX][4])
					For nZ := 1 to Len(aEstruTemp[nX][4][nY])
						aAdd(aEstruTemp[nX][4][nY][nZ],nY)
					Next nZ
				Next nY

				aAdd(aEstruturas,aEstruTemp[nX])
			EndIf
		Next nX

Return aEstruturas

//---------------------------------------------------------------------
/*/{Protheus.doc} NGRETPNEUS
Retorna array contendo informacoes dos pneus

@param cType, Caracter, Codigo do Tipo do Pneu

@author Vitor Emanuel Batista
@since 14/07/2009

@return aPneus[n][1] - Codigo do Tipo do Pneu 1, 2 ou 3
		aPneus[n][2] - Tamanho x em Pixel
		aPneus[n][3] - Tamanho y em Pixel
		aPneus[n][4] - Posicao- H=HORIZONTAL / V=VERTICAL
/*/
//---------------------------------------------------------------------
Function NGRETPNEUS(cType)

	Local aPneus := {}
	Local nPos

	aAdd(aPneus,{	"1",; //CODIGO DA IMAGEM DO PNEU   EX: NG_PNEU_PRETO_ESCURO_1.PNG
						"80",; //TAMANHO X EM PIXEL
						"29",; //TAMANHO Y EM PIXEL
						"H"; //POSICAO - H=HORIZONTAL / V=VERTICAL
					};
		)
	aAdd(aPneus,{	"2",; //CODIGO DA IMAGEM DO PNEU   EX: NG_PNEU_PRETO_ESCURO_2.PNG
						"76",; //TAMANHO X EM PIXEL
						"77",; //TAMANHO Y EM PIXEL
						"H"; //POSICAO - H=HORIZONTAL / V=VERTICAL
					};
		)

	aAdd(aPneus,{	"2",; //CODIGO DA IMAGEM DO PNEU   EX: NG_PNEU_PRETO_ESCURO_2.PNG
						"76",; //TAMANHO X EM PIXEL
						"77",; //TAMANHO Y EM PIXEL
						"H"; //POSICAO - H=HORIZONTAL / V=VERTICAL
					};
		)

	aAdd(aPneus,{	"3",; //CODIGO DA IMAGEM DO PNEU   EX: NG_PNEU_PRETO_ESCURO_3.PNG
						"75",; //TAMANHO X EM PIXEL
						"21",; //TAMANHO Y EM PIXEL
						"H"; //POSICAO - H=HORIZONTAL / V=VERTICAL
					};
		)

	aAdd(aPneus,{	"4",; //CODIGO DA IMAGEM DO PNEU   EX: NG_PNEU_PRETO_ESCURO_3.PNG
						"98",; //TAMANHO X EM PIXEL
						"34",; //TAMANHO Y EM PIXEL
						"H"; //POSICAO - H=HORIZONTAL / V=VERTICAL
					};
		)

	If !Empty(cType)
		nPos := aScan(aPneus,{|x| x[1] == cType})
		Return aPneus[nPos]
	EndIf

Return aPneus

//---------------------------------------------------------------------
/*/{Protheus.doc} MenuDef
Utilizacao de menu Funcional

@obs Parametros do array a Rotina:
		1. Nome a aparecer no cabecalho
		2. Nome da Rotina associada
		3. Reservado
		4. Tipo de Transa‡„o a ser efetuada:
			1 - Pesquisa e Posiciona em um Banco de Dados
			2 - Simplesmente Mostra os Campos
			3 - Inclui registros no Bancos de Dados
			4 - Altera o registro corrente
			5 - Remove o registro corrente do Banco de Dados
		5. Nivel de acesso
		6. Habilita Menu Funcional

@author Vitor Emanuel Batista
@since 14/07/2009

@return aRotina, Array, Array com opcoes da rotina.
/*/
//---------------------------------------------------------------------
Static Function MenuDef()

	Local aRotina := {{ STR0021		,"AxPesqui"		, 0 , 1},; //"Pesquisar"
					{	STR0022		,"MNTA221INC"	, 0 , 2},; //"Visualizar"
					{	STR0023		,"MNTA221INC"	, 0 , 3},; //"Incluir"
					{	STR0024		,"MNTA221INC"	, 0 , 4},; //"Alterar"
					{	STR0025		,"MNTA221INC"	, 0 , 5, 3}} //"Excluir"

Return aRotina

//---------------------------------------------------------------------
/*/{Protheus.doc} VerifImg
Verifica imagens no repositorio, exporta ou exclui da pasta

@author Vitor Emanuel Batista
@since 14/07/2009

@return lRet, Lógico, Se exportou todas as imagens
/*/
//---------------------------------------------------------------------
Static Function VerifImg()
	Local nX, nY
	Local lRet     := .t.

	Local cBARRAS  := If(GetRemoteType() == 2,"/","\")
	Local cTemp    := GetTempPath() //"C:"+cBARRAS+"Temp"+cBARRAS
	Local cRodados := cTemp+"rodados"+cBARRAS
	Local cExtImg  := ".PNG"

	Local aTypeEstru	:= NGRETESTRU()
	Local aTypePneu	:= NGRETPNEUS()
	Local aAllImg		:= {}
	Local aPneus		:= {	"NG_PNEU_PRETO_CLARO_"		,"NG_PNEU_PRETO_ESCURO_"	,;
						  			"NG_PNEU_VERMELHO_CLARO_"	,"NG_PNEU_VERMELHO_ESCURO_",;
									"NG_PNEU_VERDE_CLARO_"		,"NG_PNEU_VERDE_ESCURO_"	,;
									"NG_PNEU_AZUL_CLARO_"		,"NG_PNEU_AZUL_ESCURO_"	}

	Local aEstruturas := {"NG_ESTRUTURA_"}

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
		IncProc(STR0026+Substr(cValToChar((nX*100)/Len(aAllImg)),1,5)+"%" ) //"Processando.. "

		//Exclui imagem se ela ja existir no diretorio
		If !File(cRodados+aAllImg[nX]+cExtImg)

			//Exporta imagens do RPO para a pasta especificada
			If !Resource2File(aAllImg[nX]+cExtImg,cRodados+aAllImg[nX]+cExtImg)
				lRet := .f.
				Exit
			EndIf
		Endif
	Next nX

Return lRet

//---------------------------------------------------------------------
/*/{Protheus.doc} VerifImg
Deleta Shape e todo seu relacionamento

@param oTPanel, Objeto, Objeto TPaintPanel
@param nId, Numérico, Id do Shape

@author Vitor Emanuel Batista
@since 14/07/2009

@return Vazio.
/*/
//---------------------------------------------------------------------
Static Function DeleteItem(oTPanel,nId)
	Local nShape

	oTPanel:DeleteItem(nId)

	//Clicou na Imagem Pneu
	nShape := aSCAN(aShape,{|x| (x[__IDPNEU__] == nId) .And. !aTail(X)[__INVISIBLE__]})
	If nShape == 0
		//Clicou no Texto do codigo so pneu
		nShape := aSCAN(aShape,{|x| (x[6][__IDTXT__] == nId) .And. !aTail(X)[__INVISIBLE__]})
	EndIf

	If nShape > 0
		aDel( aShape, nShape )
		aSize( aShape, Len( aShape ) - 1 )
	EndIf
Return


//---------------------------------------------------------------------
/*/{Protheus.doc} MNTA221Vds
Verifica se o sistema etá utilizando mais do que as 5 Vidas de Pneus.
(Original, Recape 1, Recape 2, Recape 3, Recape 4)

@author Wagner Sobral de Lacerda
@since 10/07/2012

@return lRet
/*/
//---------------------------------------------------------------------
Function MNTA221Vds()

	// Salva as áreas atuais
	Local aArea := GetArea()
	Local aAreaSX3 := SX3->( GetArea() )

	// Variáveis da validação
	Local aCposValid := {}
	Local aRetExist  := {.F., .F.}, aRetQuant := {0, 0}
	Local nTblValid  := 0, nCpoValid := 0

	// Variáveis auxiliares para a validação
	Local aChkCpos  := {}
	Local cChkAlias := ""

	Local aCBox := {}, aChkNewCpos := {}
	Local cCBox := "", cBanda := ""
	Local nX := 0, nAT := 0

	// Variável de retorno
	Local lRet := .F.

	//--- Define o array para a validação
	aCposValid := { ;
					{"TQS", ; // [1] - Tabela TQS (Complemento de Pneus)
						{"TQS_KMR5", "TQS_KMR6", "TQS_KMR7", "TQS_KMR8", "TQS_KMR9"} }, ; // [1][2][x] - Campos novos da TQS
					{"TQU", ; // [2] - Tabela TQU (Desenho de Pneus)
						{"TQU_KMESP5", "TQU_KMESP6", "TQU_KMESP7", "TQU_KMESP8", "TQU_KMESP9"} } ; // [2][2][x] - Campos novos da TQU
					}

	//----------------------------------------
	// Verfica o ComboBox do campo
	//----------------------------------------
	dbSelectArea("SX3")
	dbSetOrder(2)
	If dbSeek("TQS_BANDAA")
		cCBox := AllTrim( X3CBox() )
		aCBox := StrTokArr(cCBox, ";")
		For nX := 1 To Len(aCBox)
			nAT := AT("=", aCBox[nX])
			cBanda := AllTrim( SubStr(aCBox[nX], 1, (nAT-1)) )
			If cBanda > "5"
				aAdd(aChkNewCpos, aCBox[nX])
			EndIf
		Next nX
	EndIf

	//----------------------------------------
	// Valida a existência dos campos
	//----------------------------------------
	For nTblValid := 1 To Len(aCposValid)
		cChkAlias := aCposValid[nTblValid][1]
		aChkCpos := aClone( aCposValid[nTblValid][2] )
		For nCpoValid := 1 To Len(aChkCpos)
			If NGCADICBASE(aChkCpos[nCpoValid], "A", cChkAlias, .F.)
				// Quantidade de campos existentes deve ser igual ao combobox da Banda do Pneu
				aRetQuant[nTblValid]++

				// Existe novo campo de vida
				If !aRetExist[nTblValid]
					aRetExist[nTblValid] := .T.
				EndIf
			EndIf
		Next nCpoValid
	Next nTblValid

	// Define o retorno da função
	lRet := ( aRetExist[1] .And. aRetExist[2] .And. ( aRetQuant[1] == aRetQuant[2] .And. aRetQuant[1] == Len(aChkNewCpos) ) )

	// Devolve as áreas
	RestArea(aAreaSX3)
	RestArea(aArea)

Return lRet

//---------------------------------------------------------------------
/*/{Protheus.doc} MNTA221Bds
Retorna as Bandas de Pneus utilizadas pelo sistema.

@author Wagner Sobral de Lacerda
@since 10/07/2012

@param lOnlyNew
	Indica se deve retornar apenas as bandas novas utilizadas * Opcional
	  .T. - Apenas as novas (a partir da vida 6, ou seja, a partir do recape 5)
	  .F. - Todas
	Default: .F.

@return aBandas
/*/
//---------------------------------------------------------------------
Function MNTA221Bds(lOnlyNew)

	// Salva as áreas atuais
	Local aArea := GetArea()
	Local aAreaSX3 := SX3->( GetArea() )

	// Variáveis auxiliares
	Local aCBox := {}
	Local cCBox := "", cBanda := ""
	Local cCpoKMAtu := "", cDescResu := "", cImagem := "", cCpoKMEsp := ""
	Local cChkKMAtu := "", cChkKMEsp := ""
	Local nX := 0, nAT := 0

	// Variável do retorno
	Local aBandas := {}

	// Defaults
	Default lOnlyNew := .F.

	//--------------------
	// Monta Bandas
	//--------------------
	dbSelectArea("SX3")
	dbSetOrder(2)
	If dbSeek("TQS_BANDAA")
		cCBox := AllTrim( X3CBox() )
		aCBox := StrTokArr(cCBox, ";")

		For nX := 1 To Len(aCBox)
			nAT := AT("=", aCBox[nX])
			cBanda := AllTrim( SubStr(aCBox[nX], 1, (nAT-1)) )
			If !lOnlyNew .Or. (lOnlyNew .And. cBanda >= "5")
				cDescResu := "R"
				cImagem   := ""
				cChkKMAtu := "TQS"
				cChkKMEsp := "TQU"
				Do Case
					Case cBanda == "1" // Original
						cCpoKMAtu := "TQS_KMOR"
						cDescResu := "OR"
						cImagem   := "NG_PNEU_PRETO_ESCURO_1"
						cCpoKMEsp := "TQX_KMESPO"

						cChkKMEsp := "TQX"
					Case cBanda == "2" // Recape 1
						cCpoKMAtu := "TQS_KMR1"
						cDescResu := "R1"
						cImagem   := "NG_PNEU_VERDE_ESCURO_1"
						cCpoKMEsp := "TQU_KMESP1"
					Case cBanda == "3" // Recape 2
						cCpoKMAtu := "TQS_KMR2"
						cDescResu := "R2"
						cImagem   := "NG_PNEU_AZUL_ESCURO_1"
						cCpoKMEsp := "TQU_KMESP2"
					Case cBanda == "4" // Recape 3
						cCpoKMAtu := "TQS_KMR3"
						cDescResu := "R3"
						cImagem   := "NG_PNEU_LARANJA_ESCURO_1"
						cCpoKMEsp := "TQU_KMESP3"
					Case cBanda == "5" // Recape 4
						cCpoKMAtu := "TQS_KMR4"
						cDescResu := "R4"
						cImagem   := "NG_PNEU_VERMELHO_ESCURO_1"
						cCpoKMEsp := "TQU_KMESP4"
					Case cBanda == "6" // Recape 5
						cCpoKMAtu := "TQS_KMR5"
						cDescResu := "R5"
						cImagem   := "NG_PNEU_VERMELHO_ESCURO_1"
						cCpoKMEsp := "TQU_KMESP5"
					Case cBanda == "7" // Recape 6
						cCpoKMAtu := "TQS_KMR6"
						cDescResu := "R6"
						cImagem   := "NG_PNEU_VERMELHO_ESCURO_1"
						cCpoKMEsp := "TQU_KMESP6"
					Case cBanda == "8" // Recape 7
						cCpoKMAtu := "TQS_KMR7"
						cDescResu := "R7"
						cImagem   := "NG_PNEU_VERMELHO_ESCURO_1"
						cCpoKMEsp := "TQU_KMESP7"
					Case cBanda == "9" // Recape 8
						cCpoKMAtu := "TQS_KMR8"
						cDescResu := "R8"
						cImagem   := "NG_PNEU_VERMELHO_ESCURO_1"
						cCpoKMEsp := "TQU_KMESP8"
					Case cBanda == "A" // Recape 9
						cCpoKMAtu := "TQS_KMR9"
						cDescResu := "R9"
						cImagem   := "NG_PNEU_VERMELHO_ESCURO_1"
						cCpoKMEsp := "TQU_KMESP9"
					Otherwise
						Loop
				EndCase

				// Se o campo existir, então adiciona ao retorno
				If NGCADICBASE(cCpoKMAtu, "A", "TQS", .F.)
					//        1      2             3                   4                                 , 5
					// Array: Banda, Campo da TQS, Descrição Resumida, Imagem ilustrativa (para legendas), Campos da TQU
					aAdd(aBandas, {cBanda, cCpoKMAtu, cDescResu, cImagem, cCpoKMEsp})
				EndIf
			EndIf
		Next nX
	EndIf

	// Devolve as áreas
	RestArea(aAreaSX3)
	RestArea(aArea)

Return aBandas
