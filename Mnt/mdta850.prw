#include "MDTA850.ch"
#include "Protheus.ch"

#DEFINE _nVERSAO 1 //Versao do fonte
//---------------------------------------------------------------------
/*/{Protheus.doc} MDTA850
Programa para definir criterios de avaliacao do Perigo/Dano

@return

@sample
MDTA850()

@author Jackson Machado
@since 22/03/2013
@version 1.0
/*/
//---------------------------------------------------------------------
Function MDTA850()
	
	//-----------------------------------------------------
	// Armazena variaveis p/ devolucao (NGRIGHTCLICK)
	//-----------------------------------------------------
	Local aNGBEGINPRM 	:= NGBEGINPRM( _nVERSAO , , { "TG2" , { "TG3" } } )
	
	Private aRotina 	:= MenuDef()
	
	Private cCadastro 	:= OemtoAnsi( STR0001 )//Define o titulo da Janla //"Critérios de Avaliação dos Perigos/Danos"
	Private aChkDel 	:= {}, aChoice := {}, aVarNao := {}
	Private bNgGrava 	:= { | | MDT850VAL() }//Funcao para validacao ao confirma a tela
	Private lTipo 		:= .F.
	
	If !ChkOHSAS()
		//-----------------------------------------------------
		// Devolve variaveis armazenadas (NGRIGHTCLICK)
		//-----------------------------------------------------
		NGRETURNPRM( aNGBEGINPRM )
		Return .F.
	EndIf
	
	cTudoOk   			:= "MDT850GRV( 'TG3' , .T. )"//Define TudoOk da GetDados
	cLinOk    			:= "MDT850GRV( 'TG3' )"//Define LinhaOk da GetDados
	aGetNao   			:= { { "TG3_CODAVA" , "M->TG2_CODAVA" } }//Campos e respectivos valores nao apresentados na GetDados
	cGetAlias 			:= "TG3"//Alias da Getdados
	cGetMake  			:= "TG2->TG2_CODAVA"//Chave de pesquisa
	cGetWhile 			:= "TG3_FILIAL == xFilial( 'TG3' ) .And. TG3_CODAVA == M->TG2_CODAVA"//Verificacao da continuacao da pesquisa
	cGetKey   			:= "M->TG2_CODAVA+M->TG3_CODOPC"//Chave do Registro
	cDELOK    			:= "MDT850VDEL()"
	//-----------------------------------------------------
	// Endereca a funcao de BROWSE
	//-----------------------------------------------------
	mBrowse( 6 , 1 , 22 , 75 , "TG2" )
	
	//-----------------------------------------------------
	// Devolve variaveis armazenadas (NGRIGHTCLICK)
	//-----------------------------------------------------
	NGRETURNPRM( aNGBEGINPRM )

Return .T.
//---------------------------------------------------------------------
/*/{Protheus.doc} MDT850GRV
Função de LinhaOk e TudoOk da GetDados

@return Lógico - Retorna verdadeiro caso linha/getdados esteja correta

@param cAlias 	- Alias a ser validado
@param lFim		- Identificador de LinhaOk/TudoOk ( .F. - LinhaOk , .T. - TudoOk )

@sample
MDT850GRV( 'TG3' )

@author Jackson Machado
@since 22/03/2013
@version 1.0
/*/
//---------------------------------------------------------------------
Function MDT850GRV( cAlias , lFim )

	Local f //Contador de For
	Local nQtd		:= 0//Contador da quantidade de registro
	Local cMemo		:= ""//Memo de Formula                                        
	Local cMens		:= ""//Mensagem de Erro
	Local nPosCod	:= 1//Posicao do código
	Local nAt		:= n//Linha atual
	Local aOldArea	:= GetArea() // Guarda variaveis de alias e indice
	Local aColsOk	:= {}, aHeadOk := {}//Validacoes de GetDados 
	Local lRet		:= .T.//Retorno da Função
	
	Default lFim	:= .F.
	
	If cAlias == "TG3" //Verifica o alias e salva os dados correspondentes
		aColsOk := aClone( aCols )
		aHeadOk := aClone( aHeader )
		nPosCod := aScan( aHeader , { | x | Trim( Upper( x[ 2 ] ) ) == "TG3_CODOPC" } )
	Endif
	
	//Percorre aCols
	For f:= 1 to Len( aColsOk )
		If !aColsOk[ f , Len( aColsOk[ f ] ) ]//Valida se linha nao esta deletada
			nQtd++
			If f == nAt
				//VerIfica se os campos obrigatórios estão preenchidos
				If Empty( aColsOk[ f , nPosCod ] )
					//Mostra mensagem de Help
					Help( 1 , " " , "OBRIGAT2" , , aHeadOk[ nPosCod , 1 ] , 3 , 0 )
					lRet := .F.
					Exit
				Endif
			Endif
			//Verifica se é somente LinhaOk
			If f <> nAt .and. !aColsOk[ nAt , Len( aColsOk[ nAt ] ) ]
				If aColsOk[ f , nPosCod ] == aColsOk[ nAt , nPosCod ]
					Help( " " , 1 , "JAEXISTINF" , , aHeadOk[ nPosCod , 1 ] )
					lRet := .F.
					Exit
				Endif
			Endif
		Endif
	Next f
	
	If lRet .AND. nQtd == 0 .and. lFim //Caso for TudoOk, verifica se GetDados está vazia
		Help( 1 , " " , "OBRIGAT2" , , aHeadOk[ nPosCod , 1 ] , 3 , 0 )
		lRet := .F.
	Endif
	
	If ALTERA .AND. lRet //Caso seja alteracao, verifica se ja esta sendo usado
		If M->TG2_DESCRI <> TG2->TG2_DESCRI .And. TG2->TG2_PESO  > 0
			DbSelectArea( "TG0" )
			DbSetOrder( 1 )
			DbSeek( xFilial( "TG0" ) )
			While !Eof() .and. xFilial( "TG0" ) == TG0->TG0_FILIAL
				cMemo := TG0->TG0_FORMUL
				If "#" + AllTrim( TG2->TG2_DESCRI ) + "#" $ cMemo
					cMens := STR0002 + AllTrim( TG2->TG2_DESCRI ) + CHR( 13 ) //"A descrição do critério de avaliação "
					cMens += STR0003 + CHR( 13 ) //"não poderá ser alterada pois a mesma esta sendo"
					cMens += STR0004 + AllTrim( TG0->TG0_DESCRI ) //"usada na fórmula "
					
					MsgStop( cMens )
					RestArea( aOldArea )
					lRet := .F.
					Exit
				EndIf
				DbSelectArea( "TG0" )
				DbSkip()
			End
		Elseif M->TG2_TIPO == "1" .and. M->TG2_TIPO <> TG2->TG2_TIPO
			DbSelectArea( "TG0" )
			DbSetOrder( 1 )
			DbSeek( xFilial( "TG0" ) )
			While !Eof() .and. xFilial( "TG0" ) == TG0->TG0_FILIAL
				cMemo := TG0->TG0_FORMUL
				If "#" + AllTrim( TG2->TG2_DESCRI ) + "#" $ cMemo
					cMens := STR0005 + " '" + STR0006 + "'" + CHR( 13 ) //"O tipo de avaliação"###"Perigo"
					cMens += STR0007 + CHR( 13 ) //"não poderá ser alterado pois o mesmo esta sendo"
					cMens += STR0008 + " " + AllTrim( TG0->TG0_DESCRI ) //"usado na fórmula "
					
					MsgStop( cMens )
					RestArea( aOldArea )
					lRet := .F.
					Exit
				EndIf
				DbSelectArea( "TG0" )
				DbSkip()
			End
		EndIf
	EndIf
	
	RestArea( aOldArea )
	
	PutFileInEof( "TG3" )
        
Return lRet       
//---------------------------------------------------------------------
/*/{Protheus.doc} MDT850TIP
Valida o campo Titulo para jogar o conteudo correspondente

@return

@sample
MDT850TIP()

@author Jackson Machado
@since 22/03/2013
@version 1.0
/*/
//---------------------------------------------------------------------
Function MDT850TIP()

	Local n
	Local lRet := .T.
	
	nPeso := aSCAN( aHEADER, { | x | Trim( Upper( x[ 2 ] ) ) == "TG3_PESO" } )
	
	oEnchoice:Refresh()
	oGet:Refresh()

Return lRet

//---------------------------------------------------------------------
/*/{Protheus.doc} SG060Peso
Ao informar um Peso Zerado no Campo TG2_PESO , limpa os pesos do critério

@author Jackson Machado
@since 04/02/2013
/*/
//---------------------------------------------------------------------
Function MDT850Peso()

Local n
nPeso := aSCAN( aHEADER, { |x| Trim( Upper(x[2]) ) == "TG3_PESO"})

If  M->TG2_PESO == 0
	For n := 1 to Len(aCols)
		aCols[n][nPeso] := 0
	Next
Endif

M->TG2_TITULO := IIF(M->TG2_PESO == 0 , "1" , "2" )  // Se For Peso 0 é caracterização

oEnchoice:Refresh()
oGet:Refresh()

Return .T.
//---------------------------------------------------------------------
/*/{Protheus.doc} MDT850BRW
Mostra no browse ao invez de numero a descricao do conteudo de um combobox.

@return _cReturn - Caso tipo seja '1', retornará 'Perigo', caso não, retornará 'Dano'

@sample
MDT850BRW( '1' )

@author Jackson Machado
@since 22/03/2013
@version 1.0
/*/
//---------------------------------------------------------------------
Function MDT850BRW( cTipo ) 
         
	Local _cReturn := ""
	
	If cTipo == "1"      
	   _cReturn := STR0006 //"Perigo"
	Else
	   _cReturn := STR0009 //"Dano"
	EndIf

Return _cReturn     
//---------------------------------------------------------------------
/*/{Protheus.doc} MDT850VAL
Funcao para validacao da exclusao do registro.

@return Lógico - Retorna verdadeiro caso possa ser excluído

@sample
MDT850VAL()

@author Jackson Machado
@since 22/03/2013
@version 1.0
/*/
//---------------------------------------------------------------------
Function MDT850VAL() 

	Local lRet		:= .T.
	Local nx		:= 0
	Local aOldArea	:= GetArea()
	
	If !INCLUI .and. !ALTERA
		DbSelectArea( "TG0" )
		DbSetOrder( 1 )
		DbSeek( xFilial( "TG0" ) )
		While !Eof() .and. xFilial( "TG0" ) == TG0->TG0_FILIAL
			cMemo := TG0->TG0_FORMUL
			If "#" + AllTrim( TG2->TG2_DESCRI ) + "#" $ cMemo
				cMens := STR0010 + " " + AllTrim( TG2->TG2_DESCRI ) + CHR( 13 ) //"O Critério de Avaliação"
				cMens += STR0011 + CHR( 13 ) //"não poderá ser excluido pois o mesmo está sendo"
				cMens += STR0008 + " " + AllTrim( TG0->TG0_DESCRI ) //"usado na fórmula "
				
				HELP( " " , 1 , "NGINTMOD" , , cMens , 4 , 1 )
				RestArea( aOldArea )
				lRet := .F.
				Exit
			EndIf
			DbSelectArea( "TG0" )
			DbSkip()
		End
	Endif
		//Verifica a existencia de avalicao, caso seja bloqueado
	If INCLUI .Or. ALTERA
		If M->TG2_MSBLQL == "1"
			If Len(aCols) > 0
				DbSelectArea( "TG7" )
				DbSetOrder( 2 )
				For nx := 1 To Len(aCols)

					If DbSeek( xFilial( "TG7" ) + M->TG2_CODAVA + aCols[ nx , 1 ] ) .And. TG7->TG7_OK == "1"
						HELP( " " , 1 , "NGINTMOD")
						lRet := .F.
						Break
					EndIf
				Next nx
			Else
				If DbSeek( xFilial( "TG7" ) + M->TG2_CODAVA ) .And. TG7->TG7_OK == "1"
					HELP( " " , 1 , "NGINTMOD")
					lRet := .F.
					Break					
				EndIf
			EndIf
		EndIf
	EndIf
	
	RestArea( aOldArea )
	
Return lRet
//---------------------------------------------------------------------
/*/{Protheus.doc} MenuDef
Utilizacao de Menu Funcional.  

@return aRotina  - 	Array com as opções de menu.
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

@sample
MenuDef()

@author Jackson Machado
@since 22/03/2013
/*/
//---------------------------------------------------------------------
Static Function MenuDef()

	Local aRotina := {	{ STR0012 , "AxPesqui"   , 0 , 1 } , ; //"Pesquisar"
	                    { STR0013 , "MDT850CAD"  , 0 , 2 } , ; //"Visualizar"
	                    { STR0014 , "MDT850CAD"  , 0 , 3 } , ; //"Incluir"
	                    { STR0015 , "MDT850CAD"  , 0 , 4 } , ; //"Alterar"
	                    { STR0016 , "MDT850CAD"  , 0 , 5 , 3 } } //"Excluir"

Return aRotina
//---------------------------------------------------------------------
/*/{Protheus.doc} MDT850VPE
Valida para que a porcentagem do peso nao ultrapasse 100

@return Lógico - Retorn verdadeiro se a porcentagem não ultrapassar 100%

@sample
MDT850VPE()

@author Jackson Machado
@since 22/03/2013
@version 1.0
/*/
//---------------------------------------------------------------------
Function MDT850VPE()
	
	Local lRet := .T.
	
	If M->TG3_PESO > 100//Valida o valor do peso
		MsgStop( STR0017 ) //"A porcentagem do peso não pode ser maior que 100."
		lRet := .F.
	EndIf

Return lRet
//---------------------------------------------------------------------
/*/{Protheus.doc} MDT850VDEL
Valida se pode deletar a opção

@return Lógico - Retorn verdadeiro se a pode deletar

@sample
MDT850VDEL()

@author Jackson Machado
@since 22/03/2013
@version 1.0
/*/
//---------------------------------------------------------------------
Function MDT850VDEL()
	
	Local nRec, nAt 
	Local lRet		:= .T.
	Local lReturn 	:= .F.
	Local aOld		:= {}
	
	If Type( "aChkSql" )  == "A"
		lReturn := .T.
		aOld 	:= aClone( aChkSql )
		aChkSql := NGRETSX9( "TG3" )
	EndIf
	
	If Type( "aCols" ) == "A" .AND. Len( aCols ) > 0
		If lValDel//Necessária esta verificacao pois a GetDados valida duas vezes o cDel
			lValDel := .F.
			nAt 	:= n
			//Se inclusao ou estiver reativando a linha
			If !Inclui .And. !aCols[ nAt , Len( aCols[ nAt ] ) ]
				nRec := aCols[ nAt , Len( aCols[ nAt ] ) - 1 ]
				If nRec > 0
					dbSelectArea( "TG3" )
					dbGoTo( nRec )
					If !NGVALSX9( "TG3" , , .T. )
						lRet := .F.
					EndIf
				Endif	
			Endif
		Else
			lValDel := .T.
		Endif
	Endif
	
	If lReturn
		aChkSql := aClone( aOld )
	EndIf
	
Return lRet
//---------------------------------------------------------------------
/*/{Protheus.doc} MDT850CAD
Função de manipulação
Necessária para validações de deleção da GetDados

@return Nil

@sample
MDT850CAD( "TG2" , 0 , 3 )

@author Jackson Machado
@since 22/03/2013
@version 1.0
/*/
//---------------------------------------------------------------------
Function MDT850CAD( cAlias , nRecno , nOpcx )
	
	Private lValDel := .T.
	
	NGCAD02( cAlias , nRecno , nOpcx )
	
Return
//---------------------------------------------------------------------
/*/{Protheus.doc} MDT850WHN
Função para When do Campo, utilizada para impedir alteração após relacionar

@return Lógico - Retorna verdadeiro quando pode alterar

@sample
MDT850WHN()

@author Jackson Machado
@since 22/03/2013
@version 1.0
/*/
//---------------------------------------------------------------------
Function MDT850WHN()
	
	Local nRec, nAt 
	Local lRet		:= .T.
	Local lReturn 	:= .F.
	Local aOld		:= {}
	
	If Type( "aChkSql" )  == "A"
		lReturn := .T.
		aOld 	:= aClone( aChkSql )
		aChkSql := NGRETSX9( "TG3" )
	EndIf
	
	If Type( "aCols" ) == "A" .AND. Len( aCols ) > 0
		nAt 	:= n
		//Se inclusao ou estiver reativando a linha
		If !Inclui .And. !aCols[ nAt , Len( aCols[ nAt ] ) ]
			nRec := aCols[ nAt , Len( aCols[ nAt ] ) - 1 ]
			If nRec > 0
				dbSelectArea( "TG3" )
				dbGoTo( nRec )
				If !NGVALSX9( "TG3" )
					lRet := .F.
				EndIf
			Endif	
		Endif
	Endif
	
	If lReturn
		aChkSql := aClone( aOld )
	EndIf
	
Return lRet