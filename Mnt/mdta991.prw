#INCLUDE "MDTA991.ch"
#INCLUDE "Protheus.ch"

//---------------------------------------------------------------------
/*/{Protheus.doc} MDTA991
Cria Browse com o historico de Registros deletados

@type   function
@sample MDTA991( 'XXX' , {'XXX_CAMPO1','XXX_CAMPO2'} , {1,2} )

@param cAliTmp, Caractere, Alias da Tabela a ser gerado o historico - Obrigatorio
@param aExpFil, Array, Contém os campos para Filtro
@param aValFil, Array, Contém valores para o Filtro

@author Jackson Machado
@since 16/01/2013
@return Nil, Sempre nulo
/*/
//---------------------------------------------------------------------
Function MDTA991( cAliTmp , aExpFil , aValFil )

	// Armazena variaveis p/ devolucao (NGRIGHTCLICK)
	Local aNGBEGINPRM := NGBEGINPRM()

	//Variaveis utilizadas na montagem do TRB
	Local nCntTRB := 0//Contador dos registros VALIDOS do TRB, visto que o RecCount considera todos os registros
	Local cAliTrb := GetNextAlias()//Novo alias para montagem do TRB
	Local cFilSav := dbFilter()//Salva filtro da tabela atual
	Local aDBF    := {}, aDBFBro := {}//Arrays para montagem da estrutura do TRB
	Local aIdxTmp := {}//Indices do TRB
	Local aIdxTot := {}//Todos os indices relacionados a tabela
	Local aArea   := GetArea()//Salva area de trabalho atual
	Local nIdx	  := 0

	// Variaveis necessarias
	Private aRotina := MenuDef()
	// Nao retirar variaveis abaixo, utilizadas em funcoes genericas
	Private aIndPTmp  // Utilizada para retorno dos indices na Funcao NGPESQTEMP - Nao retirar
	Private cAliIndex // Utilizada para definicao do Alias Padrao nas Funcoes MDT991REL e MDT991VIS

	// Define parametros
	Default cAliTmp := "TM0" // Parâmetro obrigatório porem criado Default para não apresentar erro caso chame diretamente
	Default aExpFil := { PrefixoCpo( cAliTmp ) + "_FILIAL" }
	Default aValFil := { xFilial( cAliTmp ) }

	SetBrwCHGAll( .F. ) // nao apresentar a tela para informar a filial

	If SuperGetMv( "MV_NG2AUDI" , .F. , "2" ) == "2"//Caso auditoria de sistema esteja desligado, funcionalidade nao habilitada
		ShowHelpDlg( STR0001 ,;  //"ATENÇÃO"
					{ STR0002 } , 2 ,; // "Parâmetro de auditoria não ativado." //"Parâmetro de auditoria não ativado."
					{ STR0003 } , 2 )  // "Para utilização deste recurso é necessaria a ativacao do parametro MV_NG2AUDI juntamente com a auditoria de sistema." //"Para utilização deste recurso é necessaria a ativacao do parametro MV_NG2AUDI juntamente com a auditoria de sistema."
		Return .F.
	EndIf

	//Salva o Alias padrao
	cAliIndex := cAliTmp

	#IFNDEF TOP
		MsgInfo( STR0004 ) // "Funcionalidade apenas disponível para ambientes TOP CONNECT."
		Return .F.
	#ENDIF

	// Define como alteracao pois para que se utilize o historico do browse e' necessario passa-lo como inclusao
	aRotSetOpc( cAliTmp , 0 , 4 )

	// Monta array necessarios para o TRB
	NGDBFTRB( cAliTmp , @aDBF , @aDBFBro , @aIdxTot , @aIndPTmp , .T. , .T. )

    // Array de Indices retornada com descricoes por necessidade da funcao NGPESQTEMP, portanto selecionado apenas
    // os indices para montagem do TRB, para isto, utilizada a funcao fRetIndex, localizada no NGUTIL05
    // esta funcao nao foi criada como Function, pois a utilizacao da mesma fora do escopo e' restrita
	Eval( &( " {|x| x := StaticCall( NGUTIL , fRetIndex , 1 ) } " ) , aIdxTmp )

	//Adiciona o RECNO no TRB pois eh utilizado na impressao do relatorio
	aAdd( aDBF , { "RECVAL" , "N" , 10 , 0 } )

	// Tabela temporaria sera montada apenas com os indices do Browse, pois outros
	// sao desnecessarios, portanto na funcao NGPESQTEMP sera usado apenas os
	// indices do Browse, tanto que o array aIndPTmp recebeu apenas estes
	// Monta o TRB

	oTempTRB := FWTemporaryTable():New( cAliTrb, aDBF )
	For nIdx := 1 To Len( aIdxTmp )
		oTempTRB:AddIndex( RETASC( cValToChar( nIdx ) , 1 , .T. ), StrTokArr( aIdxTmp[nIdx] , "+" ) )
	Next nIdx
	oTempTRB:Create()

	// Alimenta o TRB
	fAliTrb( cAliTRB , cAliTmp , aExpFil , aValFil , aDBF , @nCntTRB )

	// Caso TRB vazio sai da Funcao
	dbSelectArea( cAliTRB )
	If nCntTRB <= 0
		MsgStop(STR0005) //"Não existem dados para montagem do browse."
	Else
		//Chama o Browse
		mBrowse( 6 , 1 , 22 , 75 , ( cAliTRB ) , aDBFBro )//Sexto parametro corresponde a estrutura do Browse a ser montado do TRB
	EndIf

    oTempTRB:Delete()
	//Retorna a area e o filtro atual
	RestArea(aArea)
	If !Empty(cFilSav)//Verifica se tabela possuia filtro, caso sim retorna
		Set Filter To &(cFilSav)
	EndIf

	// Devolve variaveis armazenadas (NGRIGHTCLICK)
	NGRETURNPRM(aNGBEGINPRM)

Return Nil

//---------------------------------------------------------------------
/*/{Protheus.doc} fAliTrb
Alimento o TRB do Browse

@type   function
@sample fAliTrb( "TRB" , "TM0" , { "TM0_NUMFIC" } , { "000000000001" }, ;
{ { "TM0_NUMFIC" , "C" , 12 , 0 } } , 1 )

@param  cAliTmp Alias da Tabela temporária
@param  cAliBro Alias da Tabela Pai
@param  aExpFil Array com os campos para Filtro
@param  aValFil Array com valores para o Filtro
@param  aDBF    Array com os campos do TRB

@author Jackson Machado
@since  16/01/2013
@return Nil, Sempre nulo
/*/
//---------------------------------------------------------------------
Static Function fAliTrb( cAliTmp, cAliBro, aExpFil, aValFil, aDBF, nContador )

	Local nExp
	Local lLogExp := .F.
	Local cCmpLgP := PrefixoCpo( cAliBro ) + "_USERGI"
	Local xCmpLgF := PrefixoCpo( cAliBro ) + "_USERGI"
	Local cQuery  := ""
	Local dDtInc  := dDataBase

	//Realiza uma query para selecionar os registros deletados de acordo com o filtro
	cQuery := " SELECT TEMP.*, TEMP.R_E_C_N_O_ AS RECVAL FROM " + NGRETX2( cAliBro ) + " TEMP WHERE "
	If Len( aExpFil ) > 0 .AND. Len( aValFil ) > 0 .AND. Len( aExpFil ) == Len( aValFil )
   		For nExp := 1 To Len( aExpFil )//Percorre filtros para montagem da query
   			If !( "_USERGI" $ cValToChar( aExpFil[ nExp ] ) ) .And. !( "_USERLGI" $ cValToChar( aExpFil[ nExp ] ) )
   				cQuery += cValToChar( aExpFil[ nExp ] ) + " = '" + cValToChar( aValFil[ nExp ] ) + "' AND "
   			Else
   				//Caso tenha usuario de inclusao no filtro salva o usuario e a verificao de data
   			 	lLogExp := .T.
   			 	cCmpLgP := cValToChar( aExpFil[ nExp ] )
   			 	xCmpLgF := aValFil[ nExp ]
   			EndIf
   		Next nExp
	EndIf
	cQuery += " D_E_L_E_T_ = '*' "

	SqlToTrb( cQuery , aDBF , cAliTmp )

	If lLogExp//Caso tenha usuario de inclusao no filtro
		dbSelectArea( cAliTmp )
	    dbGoTop()
	    While (cAliTmp)->( !Eof() )
	    	dDtInc := MDTDATALO( (cAliTmp)->&( cCmpLgP ) , , .F. )//Salva a data de inclusao do registro
	        If xCmpLgF > dDtInc//Verifica se a data de inclusao do registro eh superior a data de inclusao do 'pai'
	        	RecLock( cAliTmp , .F. )
	        	(cAliTmp)->( dbDelete() )
	        	(cAliTmp)->( MsUnLock() )
	        Else
	        	nContador++//Caso registro valido incrementa contador de registro
	        EndIf
	    	(cAliTmp)->( dbSkip() )
	    End
	Else
		nContador := (cAliTmp)->( RecCount() ) //Caso nao tenha filtro pela inclusao do registro, ;
											   //adiciona para o contador a quantidade de registros do TRB
	EndIf

Return Nil

//---------------------------------------------------------------------
/*/{Protheus.doc} MenuDef
Menu Funcional

@type   function
@sample MenuDef()

@author Jackson Machado
@since  16/01/2013
@return Array contendo as opcoes de Menu
/*/
//---------------------------------------------------------------------
Static Function MenuDef()

	Local aRotina := {	{ STR0006 , "NGPESQTEMP" , 0 , 1 },; //"Pesquisar"
 						{ STR0007 , "MDT991VIS"  , 0 , 2 },; //"Visualizar"
                  		{ STR0008 , "MDT991REL"  , 0 , 3 } } //"Hist. Detal."

Return aRotina

//---------------------------------------------------------------------
/*/{Protheus.doc} MDT991REL
Chamada do Relatorio de Historico

@type   function
@sample MDT991REL( "TRB" , 1 , 3 )

@param  cAlias, Caractere, Alias do Browse
@param  nReg, Numérico, Alias do Browse
@param  nOpc, Numérico, Alias do Browse

@author Jackson Machado
@since  16/01/2013
@return Nil, Sempre nulo
/*/
//---------------------------------------------------------------------
Function MDT991REL( cAlias , nReg , nOpcx )

	aRotSetOpc( cAliIndex , (cAlias)->RECVAL , 4 )//Define como alteracao para imprimir corretamente o relatorio de historico

	MDTRELHIS( cAliIndex , .T. , (cAlias)->RECVAL )//Funcao para montagem do relatorio

Return Nil

//---------------------------------------------------------------------
/*/{Protheus.doc} MDT991VIS
Monta tela de visualizacao do Registro

@type    function
@sample MDT991REL( "TRB" , 1 , 2 )

@param  cAlias, Caractere, Alias do Browse
@param  nReg, Numérico, Alias do Browse
@param  nOpcx, Numérico, Alias do Browse

@author Jackson Machado
@since  16/01/2013
@return Nil, Sempre nulo
/*/
//---------------------------------------------------------------------
Function MDT991VIS( cAlias , nReg , nOpcx )

    //Variaveis de tamanho de tela
	Local aInfo, aPosObj
	Local aSize := MsAdvSize( , .F. , 430 ), aObjects := {}
	//Declaracao de Objetos
	Local oDialog, oPanel, oEnchoice

	//Define variaveis de tela
	aAdd( aObjects , { 050 , 050 , .T. , .T. } )
	aAdd( aObjects , { 100 , 100 , .T. , .T. } )
	aInfo   := { aSize[ 1 ] , aSize[ 2 ] , aSize[ 3 ] , aSize[ 4 ] , 0 ,  0 }
	aPosObj := MsObjSize( aInfo , aObjects , .T. )

	//Posiciona no registro da tabela e alimenta memorias
	dbSelectArea( cAliIndex )
	dbGoTo( &( cAlias + "->RECVAL" ) )
	RegToMemory( cAliIndex , .F. )

	//Monta tela de visualizacao
	Define MsDialog oDialog TITLE cCadastro From aSize[ 7 ],0 To aSize[ 6 ],aSize[ 5 ] OF oMainWnd PIXEL

		//Criacao de um painel para adequacao de tela
		oPanel := TPanel():New( 0 , 0 , Nil , oDialog , Nil , .T. , .F. , Nil , Nil , 0 , 0 , .T. , .F. )
			oPanel:Align := CONTROL_ALIGN_ALLCLIENT
		   	oEnchoice    := Msmget():New( cAliIndex , 0 , nOpcx , , , , , aPosObj[ 1 ] , , 3 , , , , oPanel , , .T. )

	Activate MsDialog oDialog On Init EnchoiceBar( oDialog , { || oDialog:End() } , { || oDialog:End() } ,;
						AlignObject( oDialog , { oEnchoice:oBox } , 1 ) )

Return Nil
