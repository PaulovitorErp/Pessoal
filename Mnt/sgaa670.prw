#INCLUDE "SGAA670.CH"
#include "Protheus.ch"

#DEFINE _nVERSAO 2 //Versao do fonte
//---------------------------------------------------------------------
/*/{Protheus.doc} SGAA670()
Cadastro de Efluentes Liquidos

@author  Elynton Fellipe Bazzo
@since   03/05/2013
@version P11
@return  .T.
/*/
//---------------------------------------------------------------------
Function SGAA670()

	Local aNGBEGINPRM	:= NGBEGINPRM( _nVERSAO )

	If Amiin(56) //Verifica se o usuário possui licença para acessar a rotina.

	Private cCadastro	:= STR0001 //"Cadastro de Efluentes Líquidos"
	Private aRotina		:= MenuDef()

	aChoice		:= {}
	aVarNao		:= {}
	aGETNAO		:= {{"TEC_ANO","M->TEB_ANO"},{"TEC_FONTE","M->TEB_FONTE"},{"TEC_TRATAM","M->TEB_TRATAM"}}
	cGETWHILE	:= "TEC_FILIAL == xFilial('TEC') .and. TEC_ANO == M->TEB_ANO .and. TEC_FONTE == M->TEB_FONTE .and. TEC_TRATAM == M->TEB_TRATAM"
	cGETMAKE	:= "TEB->TEB_ANO+TEB->TEB_FONTE+TEB->TEB_TRATAM"
	cGETKEY		:= "M->TEB_ANO+M->TEB_FONTE+M->TEB_TRATAM+M->TEC_CODPOL+DTOS(M->TEC_DATA)"
	cGETALIAS	:= "TEC"
	cTUDOOK		:= "SGAA670LOK(.T.)"
	cLINOK		:= "SGAA670LOK()"

	//---------------------------
	// Endereca a funcao de BROWSE
	//---------------------------
	If !NGCADICBASE("TEB_ANO","D","TEB",.F.)
		If !NGINCOMPDIC("UPDSGA23","THYRMV",.F.)
			Return .F.
		EndIf
	EndIf

	If !NGCADICBASE("TEG_CODIGO","D","TEG",.F.)
		If !NGINCOMPDIC("UPDSGA24","THYPMU",.F.)
			Return .F.
		EndIf
	EndIf

	dbSelectArea( "TEB" )
	dbSetOrder( 01 )
	dbGoTop()
	mBrowse( 6,1,22,75,"TEB" )

	EndIf

	NGRETURNPRM( aNGBEGINPRM )

Return .T.
//---------------------------------------------------------------------
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


@author  Elynton Fellipe Bazzo
@since   03/05/2013
@version P11
@return  aRotina
/*/
//---------------------------------------------------------------------
Static Function MenuDef()

	Local aRotina := {}

		  aRotina := {{	STR0005	, "AxPesqui"  , 0 , 1	},; //"Pesquisar"
					 { 	STR0006	, "NGCAD02"   , 0 , 2	},; //"Visualizar"
					 { 	STR0007	, "NGCAD02"   , 0 , 3	},; //"Incluir"
					 { 	STR0008	, "NGCAD02"   , 0 , 4	},; //"Alterar"
					 { 	STR0009	, "NGCAD02"   , 0 , 5, 3}}  //"Excluir"

Return aRotina
//---------------------------------------------------------------------
/*/{Protheus.doc} SGAA670WHEN()
When dos campos da rotina

@author  Elynton Fellipe Bazzo
@since   03/05/2013
@version P11
@return  .T.
/*/
//---------------------------------------------------------------------
Function SGAA670WHEN(cCampo)

	If cCampo == "TEB_TIPOEM" .or. cCampo == "TEB_CORHID" .or. cCampo == "TEB_CORPRE" .or. cCampo == "TEB_OUTCOR" .or. cCampo == "TEB_EMPREC"
		If M->TEB_COMPAR != "1" .or. (Empty(M->TEB_TIPOEM) .and. cCampo != "TEB_TIPOEM") .or.;
			 (M->TEB_TIPOEM == "1" .and. cCampo != "TEB_CORHID" .and. cCampo != "TEB_TIPOEM") .or.;
			 (M->TEB_TIPOEM == "2" .and. M->TEB_CORPRE != "3" .and. cCampo == "TEB_OUTCOR") .or.;
			 (M->TEB_TIPOEM == "2" .and. cCampo == "TEB_CORHID" .and. cCampo != "TEB_TIPOEM")
			If Type("M->"+cCampo) == "N"
				&("M->"+cCampo) := 0
			ElseIf Type("M->"+cCampo) == "C"
				&("M->"+cCampo) := Space(TAMSX3(cCampo)[1])
			Endif
			If cCampo == "TEB_EMPREC"
				M->TEB_LOJREC := Space(TAMSX3("TEB_LOJREC")[1])
				M->TEB_DESFOR := Space(TAMSX3("TEB_DESFOR")[1])
			Endif
			If cCampo == "TEB_CORHID"
				M->TEB_DESCRE := Space(TAMSX3("TEB_CORHID")[1])
			Endif
			Return .F.
		Endif
	ElseIf cCampo == "TEB_TPSOLO" .or. cCampo == "TEB_OUTSOL"
		If M->TEB_COMPAR != "2" .or. (M->TEB_TPSOLO != "1" .and. cCampo == "TEB_OUTSOL")
			If Type("M->"+cCampo) == "N"
				&("M->"+cCampo) := 0
			ElseIf Type("M->"+cCampo) == "C"
				&("M->"+cCampo) := Space(TAMSX3(cCampo)[1])
			Endif
			Return .F.
		Endif
	Endif

Return .T.
//---------------------------------------------------------------------
/*/{Protheus.doc} SGAA670LOK()
Consiste linha da GetDados

@author  Elynton Fellipe Bazzo
@since   03/05/2013
@version P11
@return  .T.
/*/
//---------------------------------------------------------------------
Function SGAA670LOK(lFim)

	Local f, nQtd := 0
	Local nPosCod := aSCAN(aHeader,{|x| Trim(Upper(x[2])) == "TEC_CODPOL"})
	Local nPosDat := aSCAN(aHeader,{|x| Trim(Upper(x[2])) == "TEC_DATA"	 })
	Local nPosQtd := aSCAN(aHeader,{|x| Trim(Upper(x[2])) == "TEC_QUANTI"})
	Local nPosUni := aSCAN(aHeader,{|x| Trim(Upper(x[2])) == "TEC_UNIDAD"})

	Default lFim  := .F.

	If lFim
		If !ExistChav("TEB", M->TEB_ANO+M->TEB_FONTE+M->TEB_TRATAM)
			Return .F.
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

	PutFileinEof("TEC")
	If lFim
		ASORT(aCols,,, { |x, y| x[Len(aCols[n])] .and. !y[Len(aCols[n])] } )
	Endif

Return .T.
//---------------------------------------------------------------------
/*/{Protheus.doc} SGAA670VLD()
Validacao dos campos da rotina

@author  Elynton Fellipe Bazzo
@since   03/05/2013
@version P11
@return  .T.
/*/
//---------------------------------------------------------------------
Function SGAA670VLD(cCampo)

	If cCampo == "TEB_TRATAM"
		If ExistCpo("TB6",M->TEB_TRATAM)
			If TB6->TB6_TIPO != "1" .and. TB6->TB6_TIPO != "2" .and. TB6->TB6_TIPO != "4" .and. TB6->TB6_TIPO != "5"
				ShowHelpDlg(STR0002,{STR0003},1) //"Favor informar um tratamento de Tipo 1=Tratamento;2=Reutilizacao;4=Disposicao Final;5=Outros;"
				Return .F.
			Endif
		Endif
	ElseIf cCampo == "TEC_DATA"
		If Year(M->TEC_DATA) != Val(M->TEB_ANO)
			ShowHelpDlg(STR0002,{STR0004},1) //"Favor informar uma data cujo ano seja a mesma do monitoramento do Efluente Líquido."
			Return .F.
		Endif
	Endif

Return .T.