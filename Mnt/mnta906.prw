#INCLUDE "PROTHEUS.CH"
#INCLUDE "MNTA906.CH"

#INCLUDE "DBINFO.CH"
#INCLUDE "FILEIO.CH"

#DEFINE AJUSTADO 1
#DEFINE _OPC_cGETFILE ( GETF_RETDIRECTORY + GETF_LOCALFLOPPY + GETF_LOCALHARD + GETF_NETWORKDRIVE + GETF_SHAREAWARE )

Static __cImagem := Space(20)
Static __nOpcRad := 1
Static __nAt     := 0

//-------------------------------------------------------------------
/*/{Protheus.doc} MNTA906
Cadastro de Opcoes e Imagens para a Planta Grafica

@author  Vitor Emanuel Batista
@since   31/03/2010
@version P11/P12
/*/
//-------------------------------------------------------------------
Function MNTA906()

	// Guarda conteudo e declara variaveis padroes
	Local aNGBEGINPRM := NGBEGINPRM()
	Local lExect      := fValRunRot()//Verifica a execução da rotina.

	If lExect
		Private aRotina := MenuDef()
		Private oRep    := TBmpRep():New ( 0, 0, 0, 0, "", .T., oMainWnd, Nil, Nil, .F., .F. )

		aCHOICE	:= {}
		aVARNAO	:= {}
		aRELAC	:= {}
		aGETNAO	:= {{"TU1_OPCAO" ,"M->TU0_OPCAO"} }

		cGETWHILE := "TU1->TU1_FILIAL == xFilial('TU1') .And. TU1->TU1_OPCAO == M->TU0_OPCAO"
		cGETMAKE  := "TU0->TU0_OPCAO"
		cGETKEY   := "M->TU0_OPCAO + M->TU1_TIPIMG + M->TU1_IMAGEM + M->TU1_DESCRI"
		cGETALIAS := "TU1"
		cTUDOOK   := "MNTA906ALL()"
		cLINOK    := "MNTA906CHK()"

		cCadastro := OemtoAnsi(STR0001) //"Cadastro de Opções e Imagens da Planta Gráfica"

		//---------------------------------------------
		// Insere biblioteca gráfica padrão do SIGAMNT
		//---------------------------------------------
		oTPanel := TNGPG():New()
			oTPanel:InsertLibrary()
			oTPanel:Free()

		// Endereca a funcao de BROWSE
		mBrowse( 6, 1,22,75,"TU0")
	EndIf

	// Retorna conteudo de variaveis padroes
	NGRETURNPRM(aNGBEGINPRM)
Return

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³MNTA906ALL³ Autor ³Pedro Acacio de M. Neto³ Data ³01/04/2010³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Faz a ordenacao da GetDados para que as linhas deletadas   ³±±
±±³          ³ fiquem por ultimo.                                         ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ MNTA906                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function MNTA906ALL()
Local i
Local lRet := .F.
Private nColDel := Len(aCols[n])

//Verifica se existe alguma linha preenchida
For i:=1 to Len(aCols)
	If !aCols[i][nColDel]
		lRet := .T.
	Endif
Next i
If lRet
	ASORT(aCols,,, { |x, y| x[nColDel] .and. !y[nColDel] } )
Else
	Help("", 1, STR0004, Nil,STR0005, 1, 0) //"Atenção"###"É necessário preencher os campos 'Imagem' e 'Descricao'."
Endif
Return lRet

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³MNTA906CHK³ Autor ³Pedro Acacio de M. Neto³ Data ³01/04/2010³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Faz a validacao da linha na GetDados.                      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ MNTA906                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function MNTA906CHK()
Local nX, nPos
Local nXX := 0
Local lRet := .T.
Local nPosImg := aScan(aHeader, {|x| x[2] == "TU1_IMAGEM"})
Local nPosDes := aScan(aHeader, {|x| x[2] == "TU1_DESCRI"})

// Verifica se e possivel fazer a exclusao
If Atail(aCols[n])

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ So permite deletar imagens do Usuario                        ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	nPos := aSCAN( aHEADER, { |x| Trim( Upper(x[2]) ) == "TU1_PROPRI"} )

	If aCols[n][nPos] == "1"		//1 -> Microsiga
		lRet := .F.
		Help("", 1, STR0002, Nil,STR0003, 1, 0) //"Aviso"###"Não é possível excluir uma imagem cujo proprietário é a Microsiga."
	EndIf
	//Verifica se a imagem nao esta sendo utilizada
	If lRet .and. !Inclui
		lRet := fVlExcImg(M->TU0_OPCAO, aCols[n][nPos], aCols[n][nPosImg])
	Endif
	//Restaura foco
	oGet:oBrowse:SetFocus()
// Verifica se os campos essenciais foram preenchidos
Else

	If Empty(aCols[n][nPosImg])  .Or. Empty(aCols[n][nPosDes])
		Help("", 1, STR0004, Nil,STR0005, 1, 0) //"Atenção"###"É necessário preencher os campos 'Imagem' e 'Descricao'."
		lRet := .F.
	EndIf

	// Verifica se nao ha linhas duplicadas
	If lRet
		nPos := aSCAN( aHEADER, { |x| Trim( Upper(x[2]) ) == "TU1_IMAGEM"} )

		If nPos > 0
			For nX := 1 to Len(aCols)
			   	If Atail(aCols[nX])
					Loop
				Endif
				If nX <> n
					If AllTrim(aCols[nX][nPos]) == AllTrim(aCols[n][nPos])
						nXX := nXX + 1
					Endif
				Endif
			Next
		Endif

		If nXX > 0
			Help(" ",1,"JAEXISTINF")
			lRet := .F.
		Endif
	EndIf

EndIf

Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} MNA906VLIM
Valida o campo TU1_IMAGEM

@author  Pedro Acacio de M. Neto
@since   01/04/2010
@version P11/P12
@param   lMsg, Lógico, Define se apresenta mensagem
@return  lógico, define se o valor informado é valido
/*/
//-------------------------------------------------------------------
Function MNA906VLIM(lMsg)

Local aExt
Local lRet    := .T.
Local aSvArea := GetArea()
Local cBuffer, cExt, lAnswer, cImg, cTipImg
Local nPosTipImg, nPosPoint, nPosImg, nPosExt
Local nTamImagemSX3

Default lMsg := .T.

nPosImg		:= aScan(aHeader, {|x| x[2] == "TU1_IMAGEM"})
nPosTipImg	:= aScan(aHeader, {|x| x[2] == "TU1_TIPIMG"})

cImg    := If(Type("M->TU1_IMAGEM") == 'C', AllTrim(Upper(M->TU1_IMAGEM)), aCols[n][nPosImg])
cTipImg := If(Type("M->TU1_TIPIMG") == 'C', AllTrim(Upper(M->TU1_TIPIMG)), aCols[n][nPosTipImg])

If !Empty(cImg)
	lRet := MNA906VEXT(cImg)
	If lRet

		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Verificando se a imagem existe no repositorio.               ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

		If cTipImg == '1'											//RPO
			lRet := Len(GetResArray(cImg)) > 0
		ElseIf cTipImg == '2'									//Repositorio de Imagem

			// Armazena a extensao da imagem e a retira no nome do arquivo
			nPosPoint := Rat('.', cImg)
			cExt      := SubStr(cImg, nPosPoint + 1)
			cImg      := SubStr(cImg, 1, nPosPoint - 1)

			oRep:OpenRepository()
			lRet:=oRep:ExistBmp(cImg)
			oRep:CloseRepository()

		EndIf

		If !lRet .And. lMsg
			Help("", 1, STR0002, Nil,STR0006, 1, 0) //"Aviso"###"Imagem não contida no repositório informado."
		ElseIf aCols[n][nPosTipImg] == '2'					// Se a imagem estiver no repositorio e for do tipo '2'

			// Verificando se a extensão informada é igual a do repositorio de imagens
			aExt := {}
			aAdd(aExt, {"JF", "JPG"  } )
			aAdd(aExt, {"BM", "BMP"  } )
			aAdd(aExt, {"PN", "PNG"  } )

			cBuffer := Left( LoadReposit(cImg) , 10 )
			nPosExt := aScan(aExt, {|x| x[1] $ cBuffer})

			If nPosExt > 0
				If cExt <> aExt[nPosExt][2]
					lRet := .F.
					lAnswer := MsgYesNo(STR0007 + aExt[nPosExt][2] + STR0008 + cExt + STR0009 + aExt[nPosExt][2] + "?") //"Foi encontrada uma imagem com extensao "###". Deseja substitui "###" para "
					If lAnswer
						cImg := cImg + '.' + aExt[nPosExt][2]
						nTamImagemSX3 := TamSX3("TU1_IMAGEM")

						M->TU1_IMAGEM := PadR(cImg, nTamImagemSX3[1])
					EndIf
				EndIf
			EndIf
		EndIf

	EndIf
EndIf

RestArea(aSvArea)

Return lRet

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³MNA906VEXT³ Autor ³Pedro Acacio de M. Neto³ Data ³06/04/2010³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³Valida a extensao informada para a imagem.                  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ cNameImg -> Nome da imagem                                 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³Generico                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function MNA906VEXT(cNameImg)

Local aExt
Local cExt, nPos, x
Local lRet := .F.

aExt := {}
aAdd(aExt, "JPG"  )
aAdd(aExt, "JPEG" )
aAdd(aExt, "BMP"  )
aAdd(aExt, "PNG"  )

nPos := Rat(".", cNameImg)
If nPos > 0
	cExt := SubStr(cNameImg, nPos + 1)
	lRet := ( aScan( aExt, {|x| x == cExt} ) > 0)
EndIf

If !lRet
	Help("", 1, STR0002, Nil,STR0010, 1, 0) //"Aviso"###"A extensao informada para a imagem não é válida."
EndIf

Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} MNA906VLTI
Valida o campo Tipo Imagem.

@author  Pedro Acacio de M. Neto
@since   19/04/2010
@version P11/P12
/*/
//-------------------------------------------------------------------
Function MNA906VLTI()

Local nPosImg

If !MNA906VLIM(.F.)
	nPosImg := aScan(aHeader, {|x| x[2] == "TU1_IMAGEM"})
	aCols[n][nPosImg] := ""
EndIf

Return .T.

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³MNA906VLTI³ Autor ³Pedro Acacio de M. Neto³ Data ³19/04/2010³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³Verifica se e possivel excluir uma opcao                    ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³Generico                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function MNA906DEL(cAlias, nRec, nOpc)
Local cOpcao := TU0->TU0_OPCAO
Local lRet := .T.

If TU0->TU0_PROPRI == "2"
	//Verifica se existem registros utilizando as figuras
	dbSelectArea("TU1")
	dbSetOrder(1)
	dbSeek(xFilial("TU1")+cOpcao)
	While !Eof() .and. xFilial("TU1")+cOpcao == TU1->TU1_FILIAL+TU1->TU1_OPCAO
		lRet := fVlExcImg(TU1->TU1_OPCAO, TU1->TU1_TIPIMG, TU1->TU1_IMAGEM)
		If !lRet
			Exit
		Endif
		dbSelectArea("TU1")
		dbSkip()
	End
	If lRet
		NGCAD02( cAlias, nRec, nOpc)
	Endif
Else
	Help("", 1, STR0002, Nil,STR0011, 1, 0) //"Aviso"###"Não é possível excluir uma opção cujo proprietário é a Microsiga."
EndIf

Return .T.

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³MNA906WNGD³ Autor ³Pedro Acacio de M. Neto³ Data ³19/04/2010³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³Verifica o X3_WHEN da GetDados.                             ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³Generico                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function MNA906WNGD()

Local lRet := .F.
Local nPos := aSCAN( aHEADER, { |x| Trim( Upper(x[2]) ) == "TU1_PROPRI"} )

If nPos > 0
	If aCols[n][nPos] == "2"
		lRet := .T.
	EndIf
EndIf

Return lRet

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Programa  ³MenuDef   ³ Autor ³Vitor Emanuel Batista  ³ Data ³31/03/2010³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Utilizacao de menu Funcional                               ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³Array com opcoes da rotina.                                 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³Parametros do array a Rotina:                               ³±±
±±³          ³1. Nome a aparecer no cabecalho                             ³±±
±±³          ³2. Nome da Rotina associada                                 ³±±
±±³          ³3. Reservado                                                ³±±
±±³          ³4. Tipo de Transa‡„o a ser efetuada:                        ³±±
±±³          ³    1 - Pesquisa e Posiciona em um Banco de Dados           ³±±
±±³          ³    2 - Simplesmente Mostra os Campos                       ³±±
±±³          ³    3 - Inclui registros no Bancos de Dados                 ³±±
±±³          ³    4 - Altera o registro corrente                          ³±±
±±³          ³    5 - Remove o registro corrente do Banco de Dados        ³±±
±±³          ³5. Nivel de acesso                                          ³±±
±±³          ³6. Habilita Menu Funcional                                  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³   DATA   ³ Programador   ³Manutencao efetuada                         ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³          ³               ³                                            ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Static Function MenuDef()

Local aRotina := {	{STR0012 ,"AxPesqui", 0 , 1},; //"Pesquisar"
							{STR0013,"NGCAD02" , 0 , 2},; //"Visualizar"
							{STR0014   ,"NGCAD02" , 0 , 3},; //"Incluir"
							{STR0015   ,"NGCAD02" , 0 , 4, 0},; //"Alterar"
							{STR0016   ,"MNA906DEL", 0 , 5, 3} } //"Excluir"
Return(aRotina)

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³MNT906IMG ³ Autor ³Pedro Acacio de M. Neto³ Data ³07/04/2010³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Pesquisa de imagens.                                       ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³cTipoImg  -> Indica o local onde a imagem esta armazenada:  ³±±
±±³          ³             1 - RPO                                        ³±±
±±³          ³             2 - Repositorio de Imagens                     ³±±
±±³          ³cCampo    -> Nome do campo que deve ser preenchido com a    ³±±
±±³          ³             imagem selecionada.                            ³±±
±±³          ³cImgSelect-> Nome da imagem ja contido no campo.            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ GENERICO                                                   ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function MNT906IMG(cTipoImg, cCampo, cImgSelect)

Local aSvKeys		:= GetKeys()
Local aType			:= { STR0017, "BMP", "JPG", "PNG"}  //"Todos"
Local aObjs			:= {}
Local nX, cExt
Local cOldImg       := cImgSelect

Local bSetF4		:= { || MarckUnMarck( "M" , oListBox , oComboBox ) }
Local bSetF5		:= { || MarckUnMarck( "D" , oListBox , oComboBox ) }
Local bSetF6		:= { || MarckUnMarck( "I" , oListBox , oComboBox ) }
Local bInitDialog	:= { ||;
								ChgList( @oBmp, @oListBox, @cBitmap),;
								ChangeStr( @oBmp , AJUSTADO ),;
								ChangeStr( @oBmp , @nStretch ),;
								SetKey( VK_F4  , bSetF4  ),;
								SetKey( VK_F5  , bSetF5  ),;
								SetKey( VK_F6  , bSetF6  ),;
								SetKey( VK_F7  , bBtSort ),;
								SetKey( VK_F8  , bBtPesq );
				 		}

Local bBtSort	:= { || ImgSort( @oListBox ) }
Local bBtPesq	:= { || ImgPesq( @oListBox ) }
Local bBtOk		:= { || oDlg:End(), AtuCampo(oListBox, cCampo, ,cTipoImg, cOldImg), RestKeys( aSvKeys , .T. ) }
Local bBtCancel	:= { || oDlg:End(), RestKeys( aSvKeys , .T. ) }

Local cType		:= STR0017 //"Todos"
Local cBitMap 	:= Space(255)
Local cDirAtu 	:= ""		// Diretório incial da cGetfile de inclusão

Local lFlatMode  := IF( FindFunction("FLATMODE") , FlatMode() , SetMDIChild() )

local nWidth	 := oMainWnd:nClientWidth  // Largura
Local nHeight	 := oMainWnd:nClientHeight // Altura
Local nMaskDef	 := 1 // Marca JPEG como Default
Local nStretch	 := 2
Local nBmpHeigth := 80
Local nBmpWidth	 := 100
Local nWndTop
Local nWndLeft
Local nAdjust

Local oDlg
Local oBmp
Local oBar
Local oBold
Local oBtOk
Local oPanel
Local oBtSort
Local oBtPesq
Local oListBox
Local oStretch
Local aNgButton
Local oComboBox
Local oScrollBox
Local oButtonBar
Local oBtnMarcTod
Local oBtnDesmTod
Local oBtnInverte

Default cTipoImg := '2'
Default cCampo := ""

oMainWnd:ReadClientCoors()

IF lFlatMode
	nAdjust	:= 86
Else
	nAdjust	:= 172
EndIf

DEFINE MSDIALOG oDlg FROM 0,0 TO oMainWnd:nBottom-nAdjust,883 TITLE STR0018 COLOR CLR_BLACK,CLR_WHITE PIXEL //"Pesquisa de Imagens"

	oDlg:lEscClose 		:= .F. //Nao permite sair ao se pressionar a tecla ESC.
	oDlg:lMaximized		:= .F.

	DEFINE FONT oBold NAME "Arial" SIZE 000,-013 BOLD

	aNgButton := {}
	aAdd(aNgButton, {"BMPORD1", bBtSort, "<F7>", STR0019} ) //"Ordenar"
	aAdd(aNgButton, {"PESQUISA",	bBtPesq, "<F8>", STR0012} ) //"Pesquisar"

	If cTipoImg == '2'
		aAdd(aNgButton, {"BMPINCLUIR", {|| InsertRep( @oListBox, @oBmp, @cDirAtu, @nMaskDef )}, STR0020, STR0021} )		 //"Inserir Imagem"###"Inserir"
		aAdd(aNgButton, {"BMPDEL", {|| DeleteBmp( @oBmp, @oListBox, cTipoImg )}, STR0022, STR0023} ) //"Deletar Imagem"###"Deletar"
	EndIf

	aAdd(aNgButton, {"CTBREPLA", {|| ExtractRep( @oListBox, @oBmp, cTipoImg )}, STR0024, STR0025} ) //"Extrair Imagens"###"Extrair"

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Definindo os paineis.                                        ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

	oPanel := TPanel():New(17,5,,oDlg,,,,,CLR_WHITE,(oDlg:nRight/2)-10,(oDlg:nBottom/2)-If(PtGetTheme()= "MDI",40,30),,)	// Painel de fundo. Onde os demais paineis serao adicionados
	oPanel:Align := CONTROL_ALIGN_ALLCLIENT

	oPanelTop := TPanel():New(0,0,,oPanel,,,,,CLR_WHITE,0,45,,)										// Painel superior. Onde sera adicionado as labels "Visualização" e "Opcoes"
	oPanelTop:Align := CONTROL_ALIGN_TOP

	oPanelLeft := TPanel():New(0,0,,oPanel,,,,,CLR_WHITE,110,,,)										// Painel esquerdo. Onde sera adicionado a listbox
	oPanelLeft:Align := CONTROL_ALIGN_LEFT

	oPanelDiv := TPanel():New(0,0,,oPanel,,,,,CLR_WHITE,08,0,,)										// Painel central. Serve como espacador entre o paienl esquerdo e o direito
	oPanelDiv:Align := CONTROL_ALIGN_LEFT

	oPanelRight := TPanel():New(0,0,,oPanel,,,,,CLR_WHITE,0,0,,)										// Painel direito. Onde sera adicionado o visualizador de imagens.
	oPanelRight:Align := CONTROL_ALIGN_ALLCLIENT

	@005,003 TO 032,103 LABEL OemToAnsi(STR0026) PIXEL OF oPanelTop //"Visualização"
	@011,030 RADIO oStretch VAR nStretch ITEMS OemToAnsi(STR0027),OemToAnsi(STR0028) SIZE 070,010 PIXEL OF oPanelTop; //"Ajustado"###"Normal"
			 ON CHANGE ChangeStr( @oBmp , @nStretch )

	@005.0,123 TO 032,423 LABEL OemToAnsi(STR0029) PIXEL OF oPanelTop //"Opções"

	@012.0,140 BUTTON 	oBtnMarcTod	PROMPT OemToAnsi(STR0030)	SIZE 075,013.50 OF oPanelTop	PIXEL ACTION Eval( bSetF4 ) //"Marca Todos - <F4>"
	@012.0,215 BUTTON 	oBtnDesmTod	PROMPT OemToAnsi(STR0031)	SIZE 075,013.50 OF oPanelTop	PIXEL ACTION Eval( bSetF5 ) //"Desmarca Todos - <F5>"
	@012.0,290 BUTTON 	oBtnInverte	PROMPT OemToAnsi(STR0032) SIZE 075,013.50 OF oPanelTop	PIXEL ACTION Eval( bSetF6 ) //"Inverte Sele‡„o - <F6>"
	@013.5,369 COMBOBOX	oComboBox VAR cType ITEMS aType 		SIZE 040,014.50 OF oPanelTop	PIXEL

	@044,008 LISTBOX oListBox FIELDS .F.,"__NOIMG__","" HEADER "",OemToAnsi(STR0033),OemToAnsi(STR0034) OF oPanelLeft PIXEL SIZE 110,351; //// //"Imagens"###"Tipo"
	   		 ON CHANGE ChgList( oBmp, oListBox, @cBitmap)

	oListBox:cToolTip	:= STR0035 //"Duplo click ou <Enter> para visualizar a imagem"
	oListBox:Align := CONTROL_ALIGN_ALLCLIENT

	@044,121 REPOSITORY oBmp SIZE 313, oDlg:nHeight - 600 OF oPanelRight PIXEL
	oBmp:Align := CONTROL_ALIGN_ALLCLIENT


	// Inicializa o List com os nomes dos bitmaps
	MsgRun( OemToAnsi(STR0036) , "" , { || CursorWait(), InitList( @oListBox , @oBmp, cTipoImg ) , CursorArrow() } ) //"Carregando Imagens do Repositório. aguarde..."

	//Selecionando a imagem que ja esta contida na campo enviado como parametro
	If !Empty(cImgSelect)
		cExt := GetImgExt(cImgSelect)
		cImgSelect := StrTran(cImgSelect, "."+cExt, "")

		If(nX := aScan(oListBox:aArray, {|x| x[2] + x[3]  == AllTrim(cImgSelect) + AllTrim(cExt)})) > 0
			oListBox:nAt := nX
		EndIf
	EndIf

Activate Dialog oDLG On Init ( Eval(bInitDialog), ENCHOICEBAR(oDLG, bBtOk, bBtCancel,,aNgButton) ) CENTERED

RestKeys( aSvKeys , .T. )

aAdd( aObjs , oDlg		  )
aAdd( aObjs , oBmp        )
aAdd( aObjs , oBar		  )
aAdd( aObjs , oBold       )
aAdd( aObjs , oBtOk		  )
aAdd( aObjs , oPanel      )
aAdd( aObjs , oBtSort 	  )
aAdd( aObjs , oBtPesq     )
aAdd( aObjs , oStretch    )
aAdd( aObjs , oListBox    )
aAdd( aObjs , oComboBox   )
aAdd( aObjs , oScrollBox  )
aAdd( aObjs , oButtonBar  )
aAdd( aObjs , oBtnMarcTod )
aAdd( aObjs , oBtnDesmTod )
aAdd( aObjs , oBtnInverte )

FreeObjs( @aObjs )

Return( NIL )

//--------------------------------------------------------------------------------------
Static Function FreeObjs( aObjs )

Local nObj
Local nObjs

nObjs := Len( aObjs )
For nObj := 1 To nObjs
	ObjFree( @aObjs[ nObj ] )
Next nObj

aObjs := NIL

Return( NIL )

//--------------------------------------------------------------------------------------
Static Function MarckUnMarck( cTipo , oListBox , oComboBox )

IF ( cTipo == "M" )
	aEval( oListBox:aArray , { |x,y| oListBox:aArray[y,1] := IF(;
																	(;
																		( oComboBox:nAt == 1 );
																		.or.;
																		( oListBox:aArray[y,3] == oComboBox:aItems[oComboBox:nAt] );
																	),;
																	.T.,;
																	oListBox:aArray[y,1];
																);
							};
			)
ElseIF ( cTipo == "D" )
	aEval( oListBox:aArray , { |x,y| oListBox:aArray[y,1] := IF(;
																	(;
																		( oComboBox:nAt == 1 );
																		.or.;
																		( oListBox:aArray[y,3] == oComboBox:aItems[oComboBox:nAt] );
																	),;
																	.F.,;
																	oListBox:aArray[y,1];
																);
							};
			)
ElseIF ( cTipo == "I" )
	aEval( oListBox:aArray , { |x,y| oListBox:aArray[y,1] := IF(;
																	(;
																		( oComboBox:nAt == 1 );
																		.or.;
																		( oListBox:aArray[y,3] == oComboBox:aItems[oComboBox:nAt] );
																	),;
																	!( oListBox:aArray[y,1] ),;
																	oListBox:aArray[y,1];
																);
							};
			)

EndIF

oListBox:Refresh()

Return( NIL  )

//--------------------------------------------------------------------------------------
Static Function DeleteBmp( oBmp , oListBox , cTipo)
Default cTipo := ""

IF MsgYesNo(;
			OemToAnsi(STR0037); //"Deseja realmente excluir as imagens Selecionadas "
			+;
			OemToAnsi(STR0038),;	 //" do repositorio de imagens?"
			OemToAnsi(STR0004); //"Atenção"
		)   //
	MsgRun( OemToAnsi(STR0039) , "" , { || CursorWait(), BmpDelete( @oBmp , @oListBox, cTipo ) , CursorArrow() } ) //"Atualizando o repositório de objetos. aguarde..."
Endif

Return( NIL )

//--------------------------------------------------------------------------------------
Static Function BmpDelete( oBmp, oListBox, cTipo )
Local lRet := .T.
Local nDel		:= 0
Local nItens	:= Len( oListBox:aArray )

While ( ( nDel := aScan( oListBox:aArray , { |aElem| aElem[1] } ) ) > 0 )
	lRet := .T.
	//Verifica se a imagem na esta sendo utilizada
	If !Empty(cTipo)
		lRet := fVlExcImg(M->TU0_OPCAO, cTipo, AllTrim(oListBox:aArray[ nDel , 2 ])+"."+AllTrim(oListBox:aArray[ nDel , 3 ]), .F.)
	Endif
	If lRet
		oBmp:DeleteBmp( oListBox:aArray[ nDel , 2 ] )
		aDel( oListBox:aArray , nDel )
		aSize( oListBox:aArray , --nItens )
	Else
		oListBox:aArray[ nDel , 1 ] := .F.
	Endif
End While

IF ( Len( oListBox:aArray ) == 0 )
	LstBoxAddImg( @oListBox , "__NOIMG__" )
EndIF

oBmp:Pack()
oListBox:Refresh()
oBmp:Refresh()

Return( NIL )

//--------------------------------------------------------------------------------------
Static Function ChgList( oBmp , oListBox , cBitmap)

Begin Sequence

	IF ( Len( oListBox:aArray ) == 0 )
		Break
	EndIF

	IF ! ( oListBox:aArray[ oListBox:nAt , 2 ] == cBitmap )
		oBmp:LoadBmp( oListBox:aArray[ oListBox:nAt , 2 ] )
		cBitMap := oListBox:aArray[ oListBox:nAt , 2 ]
	EndIF

End Sequence

Return( NIL )

//--------------------------------------------------------------------------------------
Static Function InsertRep( oListBox , oBmp , cDirAtu , nMaskDef )

Local cDir			:= Space( 500 )
Local cFile 		:= ""
Local cMask 		:= OemToAnsi(STR0033)+" (*.BMP)(*.JPG)(*.JPEG)(*.PNG) |*.bmp;*.jpg;*.jpeg;*.png|" //"Imagens"
Local cDrive		:= Space( 500 )
Local cMaskJPG		:= "*.JPG"
Local cMaskJPEG	:= "*.JPEG"
Local cMaskBMP		:= "*.BMP"
Local cMaskPNG		:= "*.PNG"

Local lRet 			:= .T.

Local aFiles
Local aFilesJPG
Local aFilesJPEG
Local aFilesBMP
Local aFilesPNG

Local cPath
Local cPathFile

Local nFiles
Local nFilesJPG
Local nFilesJPEG
Local nFilesBMP
Local nFilesPNG

cPath := cGetFile( cMask , OemToAnsi(STR0040) , @nMaskDef , cDirAtu , .F. , _OPC_cGETFILE ) //"Selecione arquivo..."

Begin Sequence

	IF Empty( cPath )
		MsgInfo( OemToAnsi(STR0041) ) //"Não foi possível encontrar o diretório de imagens"
		Break
	EndIF

	cPathFile	:= ( cPath + cMaskJPG )
	aFilesJPG	:= Array( aDir( cPathFile ) )
	nFilesJPG	:= aDir( cPathFile , aFilesJPG )

	cPathFile	:= ( cPath + cMaskJPEG )
	aFilesJPEG	:= Array( aDir( cPathFile ) )
	nFilesJPEG	:= aDir( cPathFile , aFilesJPEG )

	cPathFile	:= ( cPath + cMaskBMP )
	aFilesBMP	:= Array( aDir( cPathFile ) )
	nFilesBMP	:= aDir( cPathFile , aFilesBMP )

	cPathFile	:= ( cPath + cMaskPNG )
	aFilesPNG	:= Array( aDir( cPathFile ) )
	nFilesPNG	:= aDir( cPathFile , aFilesPNG )

	nFiles		:= ( nFilesJPG + nFilesJPEG + nFilesBMP + nFilesPNG)

	IF ( nFiles == 0 )
		MsgInfo(STR0042) //"Não Existem Imagens a serem importadas"
		Break
	EndIF

	aFiles := {}
	aEval( aFilesJPG  , { |cFile| aAdd( aFiles , cFile ) } )
	aEval( aFilesJPEG , { |cFile| aAdd( aFiles , cFile ) } )
	aEval( aFilesBMP  , { |cFile| aAdd( aFiles , cFile ) } )
	aEval( aFilesPNG  , { |cFile| aAdd( aFiles , cFile ) } )

	aFilesJPG	:= NIL
	aFilesJPEG	:= NIL
	aFilesBMP	:= NIL
	aFilesPNG	:= NIL

	SplitPath( cPathFile , @cDrive , @cDir )
	cDirAtu := ( Alltrim( cDrive ) + Alltrim( cDir ) )
	IF IsFileServer( cDirAtu ) // Se for no servidor soma a string servidor
		cDirAtu := ( OemToAnsi("SERVIDOR") + cDirAtu )
	EndIF

	IF MsgYesNo(STR0043) //"Deseja Selecionar as Imagens a serem inseridas?"
		IF !( ShowInsertRep( @cPath , @aFiles ) )
			Break
		EndIF
	EndIF

	MsgRun( OemToAnsi(STR0044) , "" , { || CursorWait(), RepInsert( @oBmp , @oListBox , @cPath , @aFiles ) , CursorArrow() } ) //"Inserindo Imagens no Repositório. aguarde..."

End Sequence

Return( lRet )

//-------------------------------------------------------------------
/*/{Protheus.doc} RepInsert
Inclui as imagens selecionadas do diretório para o array do oListBox

@author  NG Informática
@since   XX/XX/XXXX
@version P11/P12
@param   oBmp    , Objeto  , Objeto responsável pelo manuseio das imagens
@param   oListBox, Objeto  , Objeto ListBox com as imagens disponiveis
@param   cPath   , Caracter, Diretório onde está armazenada a imagem
@param   aFiles  , Array   , Array contendo os nome das imagens

/*/
//-------------------------------------------------------------------
Static Function RepInsert( oBmp , oListBox , cPath , aFiles )

	Local bGetExtension	:= {|| GetImgExt(aFiles[nFile]) }
	Local cPathFile
	Local lInsert		:= .T.
	Local nFile

	oBmp:RecordCount()
	For nFile := 1 To Len( aFiles )

		cFile 		:= aFiles[ nFile ]
		cPathFile	:= ( cPath + cFile )

		If Len(GetResArray(cFile)) == 0
			cFile		:= oBmp:InsertBmp( cPathFile , NIL , @lInsert )

			IF !Empty( cFile )
				oBmp:LoadBmp( cFile )
				oBmp:Refresh()
				If lInsert
					If aScan(oListBox:aArray, {|x| AllTrim(x[2]) == AllTrim(cFile)}) == 0
						LstBoxAddImg( @oListBox , AllTrim( cFile )/*@oBmp:cBmpFile*/ , @bGetExtension)
						oListBox:Cargo++
					Endif
				EndIF

				oListBox:nAt := Len( oListBox:aArray )
				oListBox:Refresh()
				oListBox:SetFocus()

			EndIF
		Else
			ShowHelpDlg(STR0067, {STR0068,'"'+AllTrim(cFile)+'"',STR0069},4,;//"Atenção"#"A Imagem "#"já se encontra compilado no repositório de imagens."
						{STR0070})//"Renomeie a Imagem para um nome válido."
		Endif

	Next nFile

Return

//--------------------------------------------------------------------------------------
Static Function LstBoxAddImg( oListBox , cEntryName , bGetExtension , nPos )

/*/ Pode existir uma forma mais inteligente de se obter o tipo do arquivo, + ... /*/
DEFAULT bGetExtension := { || IF( ( Left( LoadReposit( cEntryName ) , 2 ) == "BM" ) , "BMP" , "JPG" ) }
DEFAULT nPos          := 0

IF ( nPos > 0 )
	oListBox:aArray[ nPos , 1 ] := .F.
	oListBox:aArray[ nPos , 2 ] := cEntryName
	oListBox:aArray[ nPos , 3 ] := Eval( bGetExtension )
ElseIF (;
			( Len( oListBox:aArray ) == 1 );
			.and.;
			( oListBox:aArray[ 1 , 2 ] == "__NOIMG__" );
		)
	oListBox:aArray[ 1 , 2 ] := cEntryName
	oListBox:aArray[ 1 , 3 ] := Eval( bGetExtension )
Else
	aAdd( oListBox:aArray , { .F. , cEntryName , Eval( bGetExtension ) } )
EndIF

Return( NIL )

//--------------------------------------------------------------------------------------
Static Function ExtractRep( oListBox , oBmp, cTipoImg )

Local lRet	:= .T.
Local nSave	:=  0

Begin Sequence

	IF ( ( nSave := aScan( oListBox:aArray , { |aElem| aElem[1] } ) ) == 0 )
		lRet := .F.
		Break
	EndIF

	MsgRun( OemToAnsi(STR0045) , "" , { || CursorWait(), RepExtract( @oListBox , @oBmp , @nSave,, cTipoImg ) , CursorArrow() } ) //"Extraido imagens. aguarde..."

End Sequence

Return( lRet )

//--------------------------------------------------------------------------------------
Static Function RepExtract( oListBox , oBmp , nSave , cPath, cTipoImg)

Local cFile			:= ""
Local cMask 		:= OemToAnsi(STR0046)+"(*.*) |*.*|" //"Todos os arquivos"
Local cEntryName	:= ""

cPath	:= cGetFile(cMask,OemToAnsi(STR0040),NIL,NIL,.F.,_OPC_cGETFILE) //"Selecione arquivo..."

If cTipoImg == "1" //Extrair imagem do RPO

	cEntryName	:= oListBox:aArray[ nSave , 2 ] + "." + oListBox:aArray[ nSave , 3 ]

	cFile	:= AllTrim( cPath )
	cFile	+= AllTrim( cEntryName )
	cFile	+= "." + oListBox:aArray[ nSave , 3 ]
	cFile	:= Lower( cFile )

	Resource2File(Trim(cEntryName),cFile)

ElseIf cTipoImg == "2" //Extrair do RPO de imagem

	While ( ( nSave := aScan( oListBox:aArray , { |aElem| aElem[1] } , nSave ) ) > 0 )
		cEntryName	:= oListBox:aArray[ nSave , 2 ]
		IF ( cEntryName <> OemToAnsi(STR0047) ) //"Deletado"
			cFile	:= AllTrim( cPath )
			cFile	+= AllTrim( cEntryName )
			cFile	+= GetImgExt(cEntryName)
			cFile	:= Lower( cFile )
			cFile	:= oBmp:Extract( cEntryName , cFile )
		EndIF
		++nSave
	End While

EndIf

Return( NIL )

//--------------------------------------------------------------------------------------
Static Function ChangeStr(oBmp, nStretch)

oBmp:lStretch := (nStretch == AJUSTADO)

Return( NIL )

//--------------------------------------------------------------------------------------
Static Function InitList( oListBox, oBmp, cTipoImg )

	Local bGetExtension	:= {|| GetImgExt(cEntryName) }
	Local cEntryName
	Local aExt := {}
	Local aImg := {}
	Local cExt
	Local cBuffer
	Local cAlsReposit
	Local cBinReposit
	Local nItem
	Local nX, nY
	Local nBuffer
	Local nBinReposit
	Local lRepInBD  := FindFunction( 'RepositInBD' ) .And. RepositInBD() // Verifica onde está o repositório de imagens

	oListBox:SetArray( { { .F. , "__NOIMG__" , "" } } )

	If cTipoImg = '1'

		aAdd(aExt, ".BMP")
		aAdd(aExt, ".JPG")
		aAdd(aExt, ".PNG")

		aImg := Array( Len(aExt) )
		nItem := 0

		For nX := 1 To Len(aExt)
			aImg[nX] := GetResArray( '*' + aExt[nX] )
			nItem += Len( aImg[nX] )
		Next nX

		If nItem > 0

			oListBox:aArray := Array( nItem , 3 )
			nItem := 0

			For nX := 1 To Len(aExt)
				For nY := 1 To Len( aImg[nX] )
					cEntryName := StrTran ( aImg[nX][nY], aExt[nX], "")		//Retira a extensao do nome do arquivo
					LstBoxAddImg( @oListBox , @cEntryName , {|| SubStr(aExt[nX], -3) }, ++nItem )
				Next nY
			Next nX

		EndIf

	ElseIf cTipoImg = '2'
		If !lRepInBD
			lEmpty      := oBmp:RecordCount() == 0
			cAlsReposit := 'REPOSIT'
		Else
			// Tratativa realizada para compatibilidade de release.
			cAlsReposit := GetNextAlias()
			// Necessária tratativa pois quando é incluso uma imagem muito grande é inserido várias linhas com o mesmo nome,
			// consequentemente traz registros duplicados em tela. Valida o modulo pelo qual está sendo acessado.
			BeginSQL Alias cAlsReposit
				SELECT DISTINCT BMPNAME FROM PROTHEUS_REPOSIT PRT
					WHERE PRT.MODULO = %exp:cModulo%
					AND PRT.%notDel%
			EndSQL
			lEmpty := ( cAlsReposit )->( Eof() )
		EndIf
		If !lEmpty
			oListBox:aArray := {}
			nItem           := 0
			While ( cAlsReposit )->( !Eof() )
				cEntryName  := AllTrim( ( cAlsReposit )->BMPNAME )
				If lRepInBD .Or. ( !lRepInBD .And. Empty( ( cAlsReposit )->BMPDEL ) )
					aAdd( oListBox:aArray, { Nil, Nil, Nil } )
					LstBoxAddImg( @oListBox , @cEntryName , bGetExtension , ++nItem )
				EndIf
				( cAlsReposit )->( dbSkip() )
			End While
		EndIf
		// Verifica se o repositório de imagens está no banco
		If lRepInBD
			(cAlsReposit)->( dbCloseArea() )
		EndIf
	EndIf

	oListBox:Cargo     	:= oBmp
	oListBox:cAlias    	:= "ARRAY"
	oListBox:bLine     	:= { || LineLstBox( oListBox , .T. , NIL , 1 , .F. ) }
	oListBox:bLDblClick	:= { || oListBox:aArray[oListBox:nAt,1] := !( oListBox:aArray[oListBox:nAt,1] ) , oListBox:Refresh() }

Return( NIL )

//--------------------------------------------------------------------------------------
Static Function LineLstBox( oListBox , lMarck , aOkNo , nPosMarck , uOk )

Local abLine	:= {}
Local lIsArray	:= .F.
Local nItem		:= 0
Local nItens	:= 0

Static __aOkNo__

DEFAULT lMarck		:= .F.
DEFAULT __aOkNo__	:= { LoadBitmap( GetResources(), "LBOK" ) , LoadBitmap( GetResources(), "LBNO" ) }
DEFAULT aOkNo		:= IF( lMarck , aClone( __aOkNo__ ) , NIL )
DEFAULT nPosMarck	:= 1

#DEFINE __LINEBUTTONOK__	1
#DEFINE __LINEBUTTONNO__	2

IF ( ( oListBox:nAt := Min( oListBox:nAt , Len( oListBox:aArray ) ) ) > 0 )
	nItens			:= Len( oListBox:aHeaders )
	For nItem := 1 To nItens
		IF ( lIsArray := ( ValType( oListBox:aArray[ oListBox:nAt ] ) == "A" ) )
			IF ( nItem <= Len( oListBox:aArray[ oListBox:nAt ] ) )
				aAdd( abLine , oListBox:aArray[ oListBox:nAt , nItem ] )
			Else
				aAdd( abLine , "" )
			EndIF
			IF ( ( lMarck ) .and. nItem == ( nPosMarck ) )
				DEFAULT uOk := abLine[ nItem ]
				IF ( ValType( oListBox:aArray[ oListBox:nAt , nItem ] ) == "L" ) .or. ( oListBox:aArray[ oListBox:nAt , nItem ] == uOk )
					abLine[ nItem ] := IF( abLine[ nItem ] , aOkNo[__LINEBUTTONOK__] , aOkNo[__LINEBUTTONNO__] )
				EndIF
			EndIF
		Else
			IF ( nItem <= Len( oListBox:aArray ) )
				aAdd( abLine , oListBox:aArray[ oListBox:nAt ] )
			Else
				aAdd( abLine , "" )
			EndIF
		EndIF
	Next nItem
Else
	oListBox:nAt := 1
	aAdd( abLine , "" )
EndIF

Return( abLine )

//--------------------------------------------------------------------------------------
Static Function ShowInsertRep( cPath , aFiles )

Local aSvKeys		:= GetKeys()
Local aType			:= { STR0017, "BMP", "JPG", "PNG"}  //"Todos"
Local aObjs			:= {}

Local bSetF4		:= { || MarckUnMarck( "M" , oListBox , oComboBox ) }
Local bSetF5		:= { || MarckUnMarck( "D" , oListBox , oComboBox ) }
Local bSetF6		:= { || MarckUnMarck( "I" , oListBox , oComboBox ) }
Local bInitDialog	:= { ||;
								InsChgList( @oJPeg , @oListBox , @cPath , @cJPegFile ),;
								ChangeStr( @oJPeg , AJUSTADO ),;
								ChangeStr( @oJPeg , @nStretch ),;
								SetKey( VK_F4  , bSetF4     ),;
								SetKey( VK_F5  , bSetF5     ),;
								SetKey( VK_F6  , bSetF6     ),;
								SetKey( VK_F7  , bBtSort    ),;
								SetKey( VK_F8  , bBtPesq    );
				 		}

//Local bSvSet15		:= SetKey( CTRL_O , NIL )
Local bBtSort		:= { || ImgSort( @oListBox ) }
Local bBtPesq		:= { || ImgPesq( @oListBox ) }
Local bInsAction	:= { ||;
								CursorWait()	,;
								lInsertRep := ChkInsertRep( @oListBox , @aFiles )	,;
								oDlg:End()	,;
								RestKeys( aSvKeys , .T. )	,;
								CursorArrow();
						}

Local cType			:= STR0017 //"Todos"
Local cDirAtu 	  	:= ""		// Diretório incial da cGetfile de inclusão
Local cJPegFile		:= Space( 255 )

Local lFlatMode		:= IF( FindFunction("FLATMODE") , FlatMode() , SetMDIChild() )
Local lInsertRep	:= .F.

local nWidth	  	:= oMainWnd:nClientWidth  //Largura
Local nHeight	  	:= oMainWnd:nClientHeight //Altura
Local nMaskDef		:= 1 //Masca JPEG como Default
Local nStretch	  	:= 2

Local nWndTop
Local nWndLeft
Local nAdjust

Local oBar
Local oDlg
Local oBtOk
Local oJPeg
Local oBold
Local oPanel
Local oBtSort
Local oBtPesq
Local oListBox
Local oStretch
Local oComboBox
Local oScrollBox
Local oBtnMarcTod
Local oBtnDesmTod
Local oBtnInverte
Local aNgButton

oMainWnd:ReadClientCoors()

If ( lFlatMode )
	nWndTop		:= 0
	nWndLeft	:= 0
	nAdjust		:= 120
Else
	nWndTop		:= oMainWnd:nTop+125
	nWndLeft	:= oMainWnd:nLeft+5
	nAdjust		:= 210
EndIf

DEFINE MSDIALOG oDlg FROM nWndTop,nWndLeft TO oMainWnd:nBottom-nAdjust,oMainWnd:nRight-250 TITLE cPath PIXEL

	oDlg:lEscClose		:= .F. //Nao permite sair ao se pressionar a tecla ESC.
	oDlg:lMaximized		:= .T.

	DEFINE FONT oBold NAME "Arial" SIZE 0,-13 BOLD

	@000,114 MSPANEL oPanel SIZE 025,025
	oPanel:Align		:= CONTROL_ALIGN_TOP
	oPanel:lShowHint 	:= .T.

	aNgButton := {}
	aAdd(aNgButton, {"BMPORD1", bBtSort, "<F7>", STR0019} ) //"Ordenar"
	aAdd(aNgButton, {STR0048,	bBtPesq, "<F8>", STR0012} ) //"PESQUISA"###"Pesquisar"

	@014,003 TO 16,oDlg:nWidth LABEL '' OF oPanel  PIXEL

	@000,000 MSPANEL oPanel SIZE 003,003
	oPanel:Align		:= CONTROL_ALIGN_LEFT

	@025,003	LISTBOX oListBox FIELDS .F.,aFiles[oListBox:nAt],"" HEADER "",OemToAnsi(STR0033),OemToAnsi(STR0034) OF oDlg PIXEL SIZE 110,080; //"Imagens"###"Tipo"
			ON CHANGE InsChgList( @oJPeg , @oListBox , @cPath , @cJPegFile )

	oListBox:cToolTip	:= STR0035 //"Duplo click ou <Enter> para visualizar a imagem"
	oListBox:Align		:= CONTROL_ALIGN_LEFT

	@000,000 MSPANEL oPanel SIZE 003,003
	oPanel:Align		:= CONTROL_ALIGN_LEFT

	oJPeg := TBitmap():New(025, 114, ((oDlg:nWidth/2) - 190), ((oDlg:nHeight /2) - 80),, cJPegFile,.T.,oDlg,,,,,,,,,.T.,,,,.T.)
	oJPeg:Align     := CONTROL_ALIGN_ALLCLIENT
	oJPeg:lAutoSize := .F.

	@000,000 MSPANEL oPanel SIZE 003,003
	oPanel:Align		:= CONTROL_ALIGN_RIGHT

	@000,000 MSPANEL oPanel SIZE 036,036
	oPanel:Align		:= CONTROL_ALIGN_BOTTOM

	@005,003 TO 032,113 LABEL OemToAnsi(STR0026) PIXEL OF oPanel //"Visualização"
	@011,008 RADIO oStretch VAR nStretch ITEMS OemToAnsi(STR0027),OemToAnsi(STR0028) SIZE 070,010 PIXEL OF oPanel; //"Ajustado"###"Normal"
		ON CHANGE ChangeStr( @oJPeg , @nStretch )

	@005.0,114 TO 32,310 LABEL OemToAnsi(STR0075) PIXEL OF oPanel //"Seleção"
	@012.0,116 BUTTON 	oBtnMarcTod	PROMPT OemToAnsi(STR0076)	SIZE 050,013.50 OF oPanel	PIXEL ACTION Eval( bSetF4 ) //"Marca Todos"
	@012.0,166 BUTTON 	oBtnDesmTod	PROMPT OemToAnsi(STR0077)	SIZE 050,013.50 OF oPanel	PIXEL ACTION Eval( bSetF5 ) //"Desmarca Todos"
	@012.0,216 BUTTON 	oBtnInverte	PROMPT OemToAnsi(STR0078) SIZE 050,013.50 OF oPanel	PIXEL ACTION Eval( bSetF6 ) //"Inverte Sele‡„o"
	@013.0,270 COMBOBOX	oComboBox VAR cType ITEMS aType 		SIZE 040,014.50 OF oPanel	PIXEL

	MsgRun( OemToAnsi(STR0049) , "" , { || CursorWait(), InsInitList( @oListBox, @oJPeg, @aFiles ) , CursorArrow() } ) //"Carregando Imagens. aguarde..."

//ACTIVATE DIALOG oDlg ON INIT Eval( bInitDialog ) CENTERED
Activate Dialog oDLG On Init ( Eval(bInitDialog), ENCHOICEBAR(oDLG, bInsAction, {||oDlg:End()},,aNgButton) ) CENTERED
RestKeys( aSvKeys , .T. )

aAdd( aObjs, oDlg       )
aAdd( aObjs, oBar	      )
aAdd( aObjs, oBtOk		)
aAdd( aObjs, oJPeg      )
aAdd( aObjs, oBold      )
aAdd( aObjs, oPanel     )
aAdd( aObjs, oBtSort    )
aAdd( aObjs, oBtPesq    )
aAdd( aObjs, oListBox   )
aAdd( aObjs, oStretch   )
aAdd( aObjs, oComboBox  )
aAdd( aObjs, oBtnMarcTod)
aAdd( aObjs, oBtnDesmTod)
aAdd( aObjs, oBtnInverte)

FreeObjs(@aObjs)

Return( lInsertRep )

//--------------------------------------------------------------------------------------
Static Function ChkInsertRep( oListBox , aFiles )

Local lChkInsertRep	:= .F.

Local nChkInsertRep	:= 0

lChkInsertRep	:= ( ( nChkInsertRep := aScan( oListBox:aArray , { |aElem| aElem[1] } ) ) > 0 )
IF ( lChkInsertRep )
	aFiles := {}
	While ( ( nChkInsertRep := aScan( oListBox:aArray , { |aElem| aElem[1] } , nChkInsertRep ) ) > 0 )
		aAdd( aFiles , oListBox:aArray[ nChkInsertRep , 2 ] )
		++nChkInsertRep
	End While
EndIF

Return( lChkInsertRep )

//--------------------------------------------------------------------------------------
Static Function InsChgList( oJPeg , oListBox , cPath , cJPegFile )
IF ( Len( oListBox:aArray ) > 0 )
	cJPegFile		:= ( cPath + oListBox:aArray[ oListBox:nAt , 2 ] )
	oJPeg:cBmpFile	:= cJPegFile
	oJPeg:Refresh()
EndIF
Return( NIL )

//--------------------------------------------------------------------------------------
Static Function InsInitList( oListBox, oJPeg , aFiles )

Local bGetExtension	:= { || GetImgExt( aFiles[nItem] ) }

Local nItem
Local nItens

oListBox:SetArray( { { .F. , "__NOIMG__" , "" } } )
nItens := Len( aFiles )
For nItem := 1 To nItens
	LstBoxAddImg( @oListBox , @aFiles[ nItem ] , @bGetExtension )
Next nItem

oListBox:Cargo     	:= oJPeg
oListBox:cAlias    	:= "ARRAY"
oListBox:bLine     	:= { || LineLstBox( oListBox , .T. , NIL , 1 , .F. ) }
oListBox:bLDblClick	:= { || oListBox:aArray[oListBox:nAt,1] := !( oListBox:aArray[oListBox:nAt,1] ) , oListBox:Refresh() }

Return( NIL )

//---------------------------------------------------------------------------
/*/{Protheus.doc} ImgSort
Define ordenção que deve ser aplicada a lista de imagens.
@type static

@author
@since xx/xx/xxxx

@sample ImgSort()

@param	oListBox, Objeto, Objeto que contém a listagem de imagem.
@return Nil
/*/
//---------------------------------------------------------------------------
Static Function ImgSort( oListBox )

	Local aSvKeys := GetKeys()
	Local bSort	  := { || Nil }
	Local lbSet15 := .F.
	Local nOpcRad := 1
	Local oFont	  := Nil
	Local oDlg	  := Nil
	Local oGroup  := Nil
	Local oRadio  := Nil
	Local oPnl    := Nil

	bSet15 := { ||	(;
						lbSet15 := .T. ,;
						GetKeys(),;
						oDlg:End();
					);
				}

	bSet24 := { || GetKeys() , oDlg:End() }

	DEFINE FONT oFont NAME "Arial" SIZE 0,-11 BOLD
	DEFINE MSDIALOG oDlg TITLE OemToAnsi( STR0019 ) From 186, 0 TO 405, 582 OF GetWndDefault() PIXEL //Ordenar

		oPnl := TPanel():New( ,,, oDlg,,,,,,,, .F., .F. )
		oPnl:Align := CONTROL_ALIGN_ALLCLIENT

		@ 05 ,10 GROUP oGroup TO 73, 284 LABEL OemToAnsi( STR0050 ) OF oPnl PIXEL //Ordenação
		oGroup:oFont:= oFont

		@ 15 ,015 SAY OemToAnsi( STR0051 ) SIZE 300, 10 OF oPnl PIXEL FONT oFont //Efetuar a Ordenação por:
		@ 15 ,110 RADIO oRadio VAR nOpcRad ITEMS OemToAnsi( STR0052 ),; //Imagem
												 OemToAnsi( STR0034 ),; //Tipo
												 OemToAnsi( STR0053 ),; //Item selecionado e Imagem
												 OemToAnsi( STR0054 ),; //Item selecionado e Tipo
												 OemToAnsi( STR0055 ),; //Item n„o selecionado e Imagem
												 OemToAnsi( STR0056 );  //Item n„o selecionado e Tipo
				                                 SIZE 115,010 OF oPnl PIXEL
		oRadio:oFont := oFont

	ACTIVATE MSDIALOG oDlg CENTERED ON INIT EnchoiceBar( oDlg , bSet15 , bSet24 )

	IF ( lbSet15 )
		Do Case
			Case ( nOpcRad == 1 )
				bSort := { |x,y| x[2] < y[2] }
			Case ( nOpcRad == 2 )
				bSort := { |x,y| x[3] < y[3] }
			Case ( nOpcRad == 3 )
				bSort := { |x,y| ( IF( x[1] , "A" , "Z" ) + x[2] ) < ( IF( y[1] , "A" , "Z" ) + y[2] ) }
			Case ( nOpcRad == 4 )
				bSort := { |x,y| ( IF( x[1] , "A" , "Z" ) + x[3] ) < ( IF( y[1] , "A" , "Z" ) + y[3] ) }
			Case ( nOpcRad == 5 )
				bSort := { |x,y| ( IF( !x[1] , "A" , "Z" ) + x[2] ) < ( IF( !y[1] , "A" , "Z" ) + y[2] ) }
			Case ( nOpcRad == 6 )
				bSort := { |x,y| ( IF( !x[1] , "A" , "Z" ) + x[3] ) < ( IF( !y[1] , "A" , "Z" ) + y[3] ) }
		End Case
		aSort( oListBox:aArray , NIL , NIL , bSort )
		oListBox:nAt := 1
		oListBox:Refresh()
	EndIF

	RestKeys( aSvKeys , .T. )

Return( NIL )

//--------------------------------------------------------------------------------------
Static Function ImgPesq( oListBox )

Local aSvKeys		:= GetKeys()
Local aAdvSize		:= {}
Local aInfoAdvSize	:= {}
Local aObjCoords	:= {}
Local aObjSize		:= {}
Local aButtons		:= {}

Local bAscan		:= { || NIL }
//Local bPrev			:= { || GoPrev( @oListBox ) , GetKeys() , oDlg:End() }
//Local bNext			:= { || GoNext( @oListBox ) , GetKeys() , oDlg:End() }
Local bInitDialog	:= { ||;
								EnchoiceBar( oDlg , bSet15 , bSet24 , NIL , aButtons ),;
				 		}

Local cMsg			:= ""

Local lbSet15		:= .F.

Local oFont			:= NIL
Local oDlg			:= NIL
Local oGroup		:= NIL
Local oRadio		:= NIL
Local oCodigo		:= NIL

aAdvSize		:= MsAdvSize( .T. , .T. )

aAdvSize[3] -= 25
aAdvSize[4] -= 50
aAdvSize[5] -= 50
aAdvSize[6] -= 50
aAdvSize[7] += 50
aInfoAdvSize	:= { aAdvSize[1] , aAdvSize[2] , aAdvSize[3] , aAdvSize[4] , 0 , 0 }
aAdd( aObjCoords , { 000 , 000 , .T. , .T. } )
aObjSize		:= MsObjSize( aInfoAdvSize , aObjCoords )

bSet15 := { ||	(;
					lbSet15 := .T. ,;
					GetKeys(),;
					oDlg:End();
				  );
			}

bSet24 := { || GetKeys() , oDlg:End() }

/*aAdd(;
		aButtons	,;
						{;
							"PREV"				,;
   							bPrev				,;
       	   					OemToAnsi(STR0057),; //"Anterior <F4>..."
       	   					OemToAnsi(STR0058) ;	 //"Anterior"
           				};
        )

aAdd(;
		aButtons	,;
						{;
							"NEXT"				,;
   							bNext				,;
       	   					OemToAnsi(STR0059),; //"Pr¢ximo <F5>..."
       	   					OemToAnsi(STR0060) ; //"Pr¢ximo"
           				};
        )
*/
DEFINE FONT oFont NAME "Arial" SIZE 0,-11 BOLD
DEFINE MSDIALOG oDlg TITLE OemToAnsi(STR0012) From aAdvSize[7],0 TO aAdvSize[6]+20,aAdvSize[5] OF GetWndDefault() COLOR CLR_BLACK, CLR_WHITE PIXEL //"Pesquisar"

	@ aObjSize[1,1],aObjSize[1,2]+3 GROUP oGroup TO aObjSize[1,3]+12,aObjSize[1,4] LABEL OemToAnsi(STR0048) OF oDlg PIXEL //"Pesquisa"
	oGroup:oFont:= oFont

	@ ( aObjSize[1,1] + 010 ) , ( aObjSize[1,2]+005 )	SAY OemToAnsi(STR0061)	SIZE 300,10 OF oDlg PIXEL FONT oFont //"Tipo da Pesquia:"
	@ ( aObjSize[1,1] + 010 ) , ( aObjSize[1,2]+60 )	RADIO oRadio VAR __nOpcRad	ITEMS 	OemToAnsi(STR0062),;	 //"Exata"
																	 						OemToAnsi(STR0063) ; //"Parcial"
																						SIZE 115,010 OF oDlg PIXEL
	oRadio:cToolTip := OemToAnsi(STR0064) //"Ap¢s selecionar pressione a tecla <TAB> para habilitar a digita‡„o"
	oRadio:oFont	:= oFont

	@ ( aObjSize[1,1] + 050 ) , ( aObjSize[1,2]+005 )	SAY OemToAnsi(STR0065)					SIZE 100,10 OF oDlg PIXEL FONT oFont //"Imagem:"
	@ ( aObjSize[1,1] + 048 ) , ( aObjSize[1,2]+60 )	MSGET oCodigo VAR __cImagem					SIZE 100,10 OF oDlg PIXEL FONT oFont

ACTIVATE MSDIALOG oDlg CENTERED ON INIT EnchoiceBar( oDlg , bSet15 , bSet24 , NIL , aButtons )
RestKeys( aSvKeys , .T. )

IF ( lbSet15 )
	Do Case
		Case ( __nOpcRad == 1 )
			bAscan	:= { |x| Upper( AllTrim( x[2] ) ) == Upper( AllTrim( __cImagem ) ) }
		Case ( __nOpcRad == 2 )
			bAscan	:= { |x| Upper( AllTrim( __cImagem ) ) $ Upper( AllTrim(x[2]) ) 	}
	End Case
	IF ( ( ( __nAt := aScan( oListBox:aArray , bAscan ) ) ) > 0 )
		oListBox:nAt := __nAt
		Eval( oListBox:bChange )
		oListBox:Refresh()
	Else
		cMsg	:= STR0066 //"Imagem n„o encontrada"
		MsgInfo( OemToAnsi( cMsg ) , OemToAnsi(STR0012) ) //"Pesquisar"
		Eval( oListBox:bChange )
		oListBox:Refresh()
	EndIF
EndIF

Return( NIL )

//--------------------------------------------------------------------------------------
Static Function ObjFree(oObj)

If ValType(oObj) == "O"
	oObj:End()
	oObj := Nil
EndIf

Return

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³ GetImgExt³ Autor ³Pedro Acacio de M. Neto³ Data ³06/04/2010³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³Retorna a extensao de uma imagem do repositorio de imagens. ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³Generico                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Static Function GetImgExt(cNameImg)

Local cExt, nX, nPos
Local aExt := {}
Local nPosExt := 0

aAdd(aExt, {"JF", "JPG"  } )
aAdd(aExt, {""  , "JPEG" } )
aAdd(aExt, {"BM", "BMP"  } )
aAdd(aExt, {"PN", "PNG"  } )

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Caso o nome da imagem ja esteja com a extensao.              ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

nPos := Rat(".", cNameImg)
If nPos > 0
	cExt := SubStr(cNameImg, nPos + 1) 						// Para ignorar o ponto
	nPosExt := aScan( aExt, {|x| x[2] == Upper(AllTrim(cExt))} )
EndIf

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Caso o nome da imagem nao esteja com extensao.               ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

If nPosExt == 0
	cExt := Left( LoadReposit( cNameImg ) , 10 )
	nPosExt := aScan(aExt, {|x| x[1] $ cExt})
EndIf

cExt := If (nPosExt <> 0, aExt[nPosExt][2], "")

// Faz com que nao haja distincao entre JPEG e JPG
cExt := If (cExt == "JPEG", "JPG", cExt)

Return cExt

//-------------------------------------------------------------------
/*/{Protheus.doc} AtuCampo
Faz a atualizacao do valor do campo passado por parametro

@author  Pedro Acacio de M. Neto
@since   16/04/2010
@version P11/P12
@param   oListBox,  Objeto  , Objeto ListBox com as imagens disponiveis
@param   cCampo,    Caracter, Nome do campo que deve ser atualizado.
@param   lGetDados, Lógico  , Define se o campo está em um GetDados
@param   cTipo,     Caracter, 1 - Compilada/2 - Diretório
@param   cOldImage, Caracter, Nome da imagem define anteriormente.

/*/
//-------------------------------------------------------------------
Static Function AtuCampo(oListBox, cCampo, lGetDados, cTipo, cOldImg)

	Local nX, nPos    := aSCAN( aHEADER, { |x| Trim( Upper(x[2]) ) == "TU1_IMAGEM"} )
	Local nXX         := 0
	Local nPos2       := 0
	Local nPosCamp    := 0
	Local nBinReposit := 0
	Local cImagem	  := oListBox:aArray[ oListBox:nAt , 2 ] + "." + oListBox:aArray[ oListBox:nAt , 3 ] // Nome da imagem + . + extensao = "Nome.ext"
	Local cArquivo    := ''
	Local cAlsReposit := ''
	Local lRet        := .T.
	Local lFindImg    := .F. // Define se a imagem já existe no repositório de imagens
	Local lRepInBD    := FindFunction( 'RepositInBD' ) .And. RepositInBD() // Verifica onde está o repositório de imagens

	Default cOldImg   := ""
	Default cTipo     := ""
	Default lGetDados := .T.

	If MNA906WNGD()
		// Verifica se nao ha linhas duplicadas
		If nPos > 0
			For nX := 1 to Len(aCols)
				If Atail(aCols[nX])
					Loop
				Endif
				If nX <> n
					If AllTrim(aCols[nX][nPos]) == AllTrim(cImagem)
						nXX := nXX + 1
					Endif
				Endif
			Next
		Endif

		If nXX > 0
			Help(" ",1,"JAEXISTINF")
			lRet := .F.
		Endif

		If (!Empty(cOldImg) .and. !Empty(cTipo)) .and. AllTrim(cImagem) <> AllTrim(cOldImg) .and. !Inclui .and. lRet
			lRet := fVlExcImg(M->TU0_OPCAO, cTipo, cOldImg)//Verifica se a imagem nao esta sendo utilizada
		Endif
		If cTipo == "1"
			cArquivo := cImagem
			nPos2 := Rat( '.', cArquivo )
			If nPos2 > 0
				cArquivo := SubStr( cImagem, 1, nPos2 - 1 )
			Endif
			If !lRepInBD
				cAlsReposit	:= "REPOSIT"
				cBinReposit	:= ( cAlsReposit )->( dbInfo( DBI_FULLPATH ) )
				cBinReposit	:= StrTran( cBinReposit , SubStr( cBinReposit , -3 ) , "bmr" )
				nBinReposit	:= fOpen( cBinReposit )
				dbSelectArea(cAlsReposit)
				lFindImg    := dbSeek( cArquivo )
				fClose( nBinReposit )
			Else
				lFindImg    := oRep:ExistBMP( cArquivo )
			EndIF
			If lFindImg
				ShowHelpDlg(STR0067,{STR0068,AllTrim(cImagem),STR0071})//"Atenção"#"A imagem "#"não pode ser utilizada, pois a mesma já existe no repositório de arquivos."
				lRet := .F.
			Endif
		Endif
		If lRet
			If lGetDados
				nPosCamp := aScan( aHeader, {|x| x[2] = cCampo} )
				If nPosCamp > 0
					aCols[n][nPosCamp] := If ("__NOIMG__" $ cImagem, "", cImagem)
				EndIf
			Else
				M->&(cCampo) := If ("__NOIMG__" $ cImagem, "", cImagem)
			EndIf
		Endif
	EndIf

Return .T.

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³fVlExcImg ºAutor  ³Roger Rodrigues     º Data ³  16/07/10   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Valida a Exclusão da imagem                                 º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³MNTA906                                                     º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function fVlExcImg(cOpcao, cTipImg, cImagem, lConsid)
Local lRet := .T.
Local nQtde:= 0, nQtdImg := 0
Default lConsid := .T.

//Verifica se esta sendo utilizado na TAF
cAliasQry := GetNextAlias()
cQuery := " SELECT COUNT(*) AS QTDE FROM "+RetSqlName("TAF")+" TAF "
cQuery += " WHERE TAF.D_E_L_E_T_ <> '*' AND TAF.TAF_IMAGEM = '"+cImagem+"' AND TAF.TAF_TIPIMG = '"+cTipImg+"'"
If NGSX2MODO("TAF") == "E" .and. NGSX2MODO("TU1") == "E"
	cQuery += " AND TAF.TAF_FILIAL = '"+xFilial("TAF")+"'"
Endif
cQuery := ChangeQuery(cQuery)
dbUseArea( .T., "TOPCONN", TCGENQRY(,,cQuery),cAliasQry, .F., .T.)

dbSelectArea(cAliasQry)
dbGoTop()
If !Eof()
	nQtde := (cAliasQry)->QTDE
EndIf
(cAliasQry)->(dbCloseArea())

If nQtde > 0
	If lConsid
		//Verifica se existe em outro grupo de imagens
		cAliasQry := GetNextAlias()
		cQuery := " SELECT COUNT(*) AS QTDE FROM "+RetSqlName("TU1")+" TU1 "
		cQuery += " WHERE TU1.D_E_L_E_T_ <> '*' AND TU1.TU1_IMAGEM = '"+cImagem+"' AND TU1.TU1_OPCAO <> '"+cOpcao+"'"
		If NGSX2MODO("TAF") == "E" .and. NGSX2MODO("TU1") == "E"
			cQuery += " AND TU1.TU1_FILIAL = '"+xFilial("TU1")+"'"
		Endif
		cQuery := ChangeQuery(cQuery)
		dbUseArea( .T., "TOPCONN", TCGENQRY(,,cQuery),cAliasQry, .F., .T.)

		dbSelectArea(cAliasQry)
		dbGoTop()
		If !Eof()
			nQtdImg := (cAliasQry)->QTDE
		EndIf
		(cAliasQry)->(dbCloseArea())
	Endif
	//Se nao existir em outro grupo
	If nQtdImg == 0
		ShowHelpDlg("NGINTMOD",{STR0072,'"'+AllTrim(cImagem)+'"',;//"Não é possível excluir a imagem "
								STR0073} ,4,;//"pois a mesma está sendo utilizada na tabela: TAF - Estrutura Organizacional"
								{STR0074})//"Verifique os relacionamentos da mesma."
		lRet := .F.
	Endif
Endif

Return lRet
//---------------------------------------------------------------------
/*/{Protheus.doc} fValRunRot
Verifica se é permitido a execução da rotina.

@author Guilherme Benkendorf
@since 30/06/2014
@version P11
@return Nil
/*/
//---------------------------------------------------------------------
Static Function fValRunRot()
	Local lSigaMdtPs:= SuperGetMv("MV_MDTPS",.F.,"N") == "S"
	Local lRet      := .T.

	If lSigaMdtPs
		MsgStop( STR0080 , STR0067 ) //"Prestador de Serviço não tem acesso a Árvore Lógica."###"Atenção"
		lRet := .F.
	Else
		//Verificação para a utilização da Planta Grafica em MDT
		If nModulo == 35
			If !FindFunction("MNT902VlId")
				Aviso(OemToAnsi(STR0067), OemToAnsi(STR0081), {"Ok"})	//"Atencao"#"Repositório incompatível para esta operação, favor contatar o Administrador para atualizar."
				lRet := .F.
			ElseIf !NGCADICBASE( "TAF_CODAMB", "D", "TAF", .F. )
				NGINCOMPDIC( "UPDMDTA1" , "TPTZE6" )
				lRet := .F.
			ElseIf !NGCADICBASE( "TAF_EVEMDT", "D", "TAF", .F. )
				NGINCOMPDIC( "UPDMDTA3" , "TQEKGE" )
				lRet := .F.
			EndIf
		EndIf
	EndIf

Return lRet