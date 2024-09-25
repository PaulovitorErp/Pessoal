#Include "mdta145.ch"
#Include "Protheus.ch"

//-------------------------------------------------------------------
/*/{Protheus.doc} MDTA145A
Filtra as fichas ocupacionais do funcionario

@param cAlias, Caractere, Alias da tabela
@param nReg, Numérico, Numero do registro posicionado na tabela
@param nOpcx, Numérico, Valor da operação a ser relizada

@author  Denis Hyroshi de Souza
@since   01/07/2008
@return  Nil, Sempre Nulo
/*/
//-------------------------------------------------------------------
Function MDTA145A( cAlias,nRecno,nOpcx )

	Local aOld := aClone( aRotina ), nX,oFWBrowse, oBROWSE
	Local aIndSeek := {}, aFWHeader := {}, nHeader, aFWBrwCon := {}, aColsBrw := {}
	Local lPyme := Iif( Type( "__lPyme" ) <> "U",__lPyme,.F. )
	Local aSMenuOld := aClone(aSMenu)

	Private oBrwQuest, aPesq := {}
	Private cAliasQue := GetNextAlias()

	Private aRotina := MenuDef()

	SetFunName( "MDTA145A" )

	If !lPyme
		AAdd( aRotina, { STR0017, "MDT415DOC", 0, 7 } )  //"Conhecimento"
	EndIf
	If !lSigaMdtPs .And. SuperGetMv( "MV_NG2AUDI",.F.,"2" ) == "1"
		aAdd( aRotina , { STR0048 ,"MDT145HIST" , 0 , 3 } )//"Hist. Exc."
	EndIf
	//Endereca a funcao de BROWSE

	aDBFB := {}
	Aadd( aDBFB,{"TMI_NUMFIC"   ,"C", 09,0} )
	Aadd( aDBFB,{"TMI_DTREAL"   ,"C", 08,0} )
	Aadd( aDBFB,{"TMI_QUESTI"   ,"C", 06,0} )

	oTempTable := FWTemporaryTable():New( cAliasQue, aDBFB )
	oTempTable:AddIndex( "1", {"TMI_NUMFIC","TMI_DTREAL","TMI_QUESTI"} )
	oTempTable:Create()

	aTRBB :={ {STR0007 ,"TMI_NUMFIC" ,"C",09,0,"@!"},;    //"Ficha Médica"
			  {STR0014 ,"(STOD(TMI_DTREAL))" ,"D",08,0,"99/99/99" },;    //"Realização"
			  {STR0006 ,"TMI_QUESTI" ,"C",06,0,"@!"   } }    //"Questionário"

	Processa( { |lEnd| MDTA145INI(.F.) }, STR0031 )//"Aguarde ..Processando"

	If SuperGetMv( "MV_NG2AUDI",.F.,"2" ) == "1"
		If Len( aSMenu ) > 0
			aAdd( aSMenu,{ STR0049 , "MDTRELHIS('TMI')" } )  //"Histórico do Registro"
		Else
			asMenu := { { STR0049 , "MDTRELHIS('TMI')" } } //"Histórico do Registro"
		EndIf
	Endif

	DbSelectarea( cAliasQue )
	dbSetOrder( 1 )
	dbGoTop()

	//Cria Array para montar a chave de pesquisa

	aAdd( aPesq , { "Ficha Medica + Dt. Real + Questi. " ,{{"","C" , 255 , 0 ,"","@!"} }} ) // Indices de pesquisa

	If Type( "oBrwQuest" ) == "O"
		oBrwQuest:DeActivate()
		oBrwQuest:Destroy()
		oBrwQuest := Nil
	EndIf

	oBrwQuest:= FWMBrowse():New()
	oBrwQuest:SetDescription( cCadastro )
	oBrwQuest:SetMenuDef( 'MDTA145A' )
	oBrwQuest:SetTemporary(.T.)
	oBrwQuest:SetAlias( cAliasQue )
	oBrwQuest:SetFields( aTRBB )
	oBrwQuest:DisableReport()
	oBrwQuest:DisableDetails()
	oBrwQuest:SetProfileID( '2' )
	oBrwQuest:SetSeek( .T.,aPesq )
	oBrwQuest:Activate()

	oTempTable:Delete()

	aRotina := aClone( aOld )

	asMenu := aClone( aSMenuOld )

	SetFunName( "MDTA145A" )

Return Nil

//-------------------------------------------------------------------
/*/{Protheus.doc} MenuDef
Utilização de Menu Funcional.
Parametros do array aRotina:
		1 - Pesquisa e Posiciona em um Banco de Dados
		2 - Simplesmente Mostra os Campos
		3 - Inclui registros no Bancos de Dados
		4 - Altera o registro corrente
		5 - Remove o registro corrente do Banco de Dados
		6- Habilita Menu Funcional

@author  Denis Hyroshi de Souza
@since   01/07/2008
@return  Nil, Sempre Nulo
/*/
//-------------------------------------------------------------------
Static Function MenuDef()

	Local aRotina

		aRotina := { { STR0004 , "AxPesqui"    , 0 , 1    },; //"Pesquisar"
					 { STR0030 , "MDTA145CAD"  , 0 , 2    },; //"Visualizar"
				 	 { STR0008 , "MDTA145CAD"  , 0 , 3    },; //"Incluir"
					 { STR0009 , "MDTA145CAD"  , 0 , 4    },; //"Alterar"
					 { STR0010 , "MDTA145CAD"  , 0 , 5, 3 },; //"Excluir"
					 { STR0021 , "IMPMDT410"   , 0 , 6    } } //"Imprimir"

Return aRotina