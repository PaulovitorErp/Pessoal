#include "SGAA730.ch"
#include "Protheus.ch"

//-------------------------------------------------------------------------------
/*/{Protheus.doc} SGAA730()
Cadastro de Unidade Poluidora

@Author: Elynton Fellipe Bazzo
@since: 03/05/2013
@version 110
@return .T.
/*/
//--------------------------------------------------------------------------------
Function SGAA730()

	Local aNGBEGINPRM	:= NGBEGINPRM()

	Private cCadastro	:= STR0001 //"Cadastro de Unidades Poluidoras"
	Private aRotina		:= MenuDef()

	aChoice		:= {}
	aVarNao		:= {}
	aGETNAO		:= {{"TEI_ANO","M->TEH_ANO"},{"TEI_CODUNI","M->TEH_CODIGO"}}
	cGETWHILE	:= "TEI_FILIAL == xFilial('TEI') .and. TEI_ANO == M->TEH_ANO .and. TEI_CODUNI == M->TEH_CODIGO"
	cGETMAKE	:= "TEH->TEH_ANO+TEH->TEH_CODIGO"
	cGETKEY		:= "M->TEH_ANO+M->TEH_CODIGO+M->TEI_CODPOL+DTOS(M->TEI_DATA)"
	cGETALIAS	:= "TEI"
	cTUDOOK		:= "SGAA730LOK(.T.)"
	cLINOK		:= "SGAA730LOK()"

	//------------------------------
	// Endereca a funcao de BROWSE
	//------------------------------
	If !NGCADICBASE("TEH_ANO","D","TEH",.F.)
		If !NGINCOMPDIC("UPDSGA24","THYPMU",.F.)
			Return .F.
		EndIf
	EndIf

	dbSelectArea( "TEH" )
	dbSetOrder( 01 )
	dbGoTop()
	mBrowse( 6,1,22,75,"TEH" )

	NGRETURNPRM( aNGBEGINPRM )

Return .T.
//-------------------------------------------------------------------------------
/*/{Protheus.doc} MenuDef()
Utilizacao de Menu Funcional.
Parametros do array a Rotina:
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

@Author: Elynton Fellipe Bazzo
@since: 03/05/2013
@version 110
@return aRotina
/*/
//--------------------------------------------------------------------------------
Static Function MenuDef()

	Local aRotina := {}

	aRotina := 	{ { STR0004 , "AxPesqui"  , 0 , 1	 }, ; //"Pesquisar"
				  { STR0005	, "NGCAD02"   , 0 , 2	 }, ; //"Visualizar"
				  { STR0006	, "NGCAD02"   , 0 , 3	 }, ; //"Incluir"
				  { STR0007	, "NGCAD02"   , 0 , 4	 }, ; //"Alterar"
				  { STR0008	, "NGCAD02"   , 0 , 5, 3 } } //"Excluir"

Return aRotina
//-------------------------------------------------------------------------------
/*/{Protheus.doc} SGAA730WHEN(cCampo)
When dos campos da rotina

@Author: Elynton Fellipe Bazzo
@since: 03/05/2013
@version 110
@return .T.
/*/
//--------------------------------------------------------------------------------
Function SGAA730WHEN(cCampo)

	If M->TEH_POSCHA != "1"
		If Type("M->"+cCampo) == "N"
			&("M->"+cCampo) := 0
		ElseIf Type("M->"+cCampo) == "C"
			&("M->"+cCampo) := Space(TAMSX3(cCampo)[1])
		Endif
		Return .F.
	Endif

Return .T.
//-------------------------------------------------------------------------------
/*/{Protheus.doc} SGAA730LOK(lFim)
Consiste linha da GetDados

@Author: Elynton Fellipe Bazzo
@since: 03/05/2013
@version 110
@return .T.
/*/
//--------------------------------------------------------------------------------
Function SGAA730LOK(lFim)

	Local f, nQtd := 0
	Local nPosCod := aSCAN(aHeader,{|x| Trim(Upper(x[2])) == "TEI_CODPOL"})
	Local nPosDat := aSCAN(aHeader,{|x| Trim(Upper(x[2])) == "TEI_DATA"})
	Local nPosQtd := aSCAN(aHeader,{|x| Trim(Upper(x[2])) == "TEI_QUANTI"})
	Local nPosUni := aSCAN(aHeader,{|x| Trim(Upper(x[2])) == "TEI_UNIDAD"})
	Default lFim  := .F.

If lFim
	If !ExistChav("TEH", M->TEH_ANO+M->TEH_CODIGO)
		Return .F.
	Endif
	//Se possuir chamine
	If M->TEH_POSCHA == "1"
		If Empty(M->TEH_ALTITU)
			Help(1," ","OBRIGAT2",,RetTitle("TEH_ALTITU"),3,0)
			Return .F.
		ElseIf Empty(M->TEH_ALTURA)
			Help(1," ","OBRIGAT2",,RetTitle("TEH_ALTURA"),3,0)
			Return .F.
		ElseIf Empty(M->TEH_TMPGAS)
			Help(1," ","OBRIGAT2",,RetTitle("TEH_TMPGAS"),3,0)
			Return .F.
		ElseIf Empty(M->TEH_DIAINT)
			Help(1," ","OBRIGAT2",,RetTitle("TEH_DIAINT"),3,0)
			Return .F.
		ElseIf Empty(M->TEH_VAZGAS)
			Help(1," ","OBRIGAT2",,RetTitle("TEH_VAZGAS"),3,0)
			Return .F.
		Endif
	Endif
Endif

//Percorre aCols
For f:= 1 to Len(aCols)
	If !aCols[f][Len(aCols[f])]
		If lFim .or. f == n
			If !Empty(aCols[f][nPosCod]) .or. !Empty(aCols[f][nPosDat]) .or. !Empty(aCols[f][nPosQtd]) .or. !Empty(aCols[f][nPosUni])
				//VerIfica se os campos obrigatórios estão preenchidos
				If Empty(aCols[f][nPosCod])
					//Mostra mensagem de Help
					Help(1," ","OBRIGAT2",,aHeader[nPosCod][1],3,0)
					Return .F.
				ElseIf nPosDat > 0 .and. Empty(aCols[f][nPosDat])
					//Mostra mensagem de Help
					Help(1," ","OBRIGAT2",,aHeader[nPosDat][1],3,0)
					Return .F.
				ElseIf nPosQtd > 0 .and. Empty(aCols[f][nPosQtd])
					//Mostra mensagem de Help
					Help(1," ","OBRIGAT2",,aHeader[nPosQtd][1],3,0)
					Return .F.
				ElseIf nPosUni > 0 .and. Empty(aCols[f][nPosUni])
					//Mostra mensagem de Help
					Help(1," ","OBRIGAT2",,aHeader[nPosUni][1],3,0)
					Return .F.
				Endif
			Endif
		Endif
		//Verifica se é somente LinhaOk
		If f <> n .and. !aCols[n][Len(aCols[n])]
			If aCols[f][nPosCod]+DTOS(aCols[f][nPosDat]) == aCols[n][nPosCod]+DTOS(aCols[n][nPosDat])
				Help(" ",1,"JAEXISTINF",,aHeader[nPosCod][1])
				Return .F.
			Endif
		Endif
	Endif
Next f

PutFileinEof("TEI")
If lFim
	ASORT(aCols,,, { |x, y| x[Len(aCols[n])] .and. !y[Len(aCols[n])] } )
Endif

Return .T.
//-------------------------------------------------------------------------------
/*/{Protheus.doc} SGAA730VLD()
Valida campo de data

@Author: Elynton Fellipe Bazzo
@since: 03/05/2013
@version 110
@return .T.
/*/
//--------------------------------------------------------------------------------
Function SGAA730VLD()

	If Year(M->TEI_DATA) != Val(M->TEH_ANO)
		ShowHelpDlg(STR0002,{STR0003},1) //"Atenção" - "Favor informar uma data cujo ano seja o mesmo da unidade poluidora."
		Return .F.
	Endif

Return .T.