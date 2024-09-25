#INCLUDE "MDTA854.ch"
#include "Protheus.ch"

#DEFINE _nVERSAO 1 //Versao do fonte
//---------------------------------------------------------------------
/*/{Protheus.doc} MDTA854
Programa para cadastrar Danos

@return

@sample
MDTA854()

@author Jackson Machado
@since 22/03/2013
@version 1.0
/*/
//---------------------------------------------------------------------             
Function MDTA854()
            
	//-----------------------------------------------------
	// Armazena variaveis p/ devolucao (NGRIGHTCLICK)
	//-----------------------------------------------------
	Local aNGBEGINPRM 	:= NGBEGINPRM( _nVERSAO , , { "TG8" , { "TGA" } } )
		
	Private aRotina 	:= MenuDef()
	
	Private cCadastro 	:= OemtoAnsi( STR0001 )//Define o titulo da Janla //"Danos"
	Private aChkDel   	:= { { "TG8->TG8_CODDAN" , "TG6" , 5 } }
	Private bNgGrava  	:= { | | .T. }
	Private aChoice   	:= {}
	Private aVarNao   	:= {}
	Private cTudoOk   	:= "AllwaysTrue"//Define TudoOk da GetDados
	Private cLinOk    	:= "MDT854LIOK( 'TGA' )"//Define LinhaOk da GetDados
	Private aGetNao   	:= { { "TGA_CODDAN" , "M->TG8_CODDAN" } }//Campos e respectivos valores nao apresentados na GetDados
	Private cGetAlias 	:= "TGA"//Alias da Getdados
	Private cGetMake  	:= "TG8->TG8_CODDAN"//Chave de pesquisa
	Private cGetWhile 	:= "TGA->TGA_FILIAL == xFilial( 'TGA' ) .and. TGA->TGA_CODDAN == M->TG8_CODDAN"//Verificacao da continuacao da pesquisa
	Private cGetKey   	:= "M->TG8_CODDAN+M->TGA_CODLEG"//Chave do Registro
	
	If !ChkOHSAS()
		//-----------------------------------------------------
		// Devolve variaveis armazenadas (NGRIGHTCLICK)
		//-----------------------------------------------------
		NGRETURNPRM( aNGBEGINPRM )
		Return .F.
	EndIf
	
	dbSelectArea( "TG8" )
	dbSetOrder( 1 )
	mBrowse( 6 , 1 , 22 , 75 , "TG8" )
	
	//-----------------------------------------------------
	// Devolve variaveis armazenadas (NGRIGHTCLICK)
	//-----------------------------------------------------
	NGRETURNPRM( aNGBEGINPRM )

Return .t.    

//---------------------------------------------------------------------
/*/{Protheus.doc} MDT854LIOK
Função de LinhaOk da GetDados

@return Lógico - Retorna verdadeiro caso linha esteja correta

@param cAlias 	- Alias a ser validado

@sample
MDT001GRV( 'TGA' )

@author Jackson Machado
@since 22/03/2013
@version 1.0
/*/
//---------------------------------------------------------------------
Function MDT854LIOK( cAlias )

	Local f
	Local nPosCod := 1, nAt := n
	Local aColsOk := {}, aHeadOk := {}
	
	If cAlias == "TGA"
		aColsOk := aClone( aCols )
		aHeadOk := aClone( aHeader )
		nPosCod := aScan( aHeader , { | x | Trim( Upper( x[ 2 ] ) ) == "TGA_CODLEG" } )
	Endif
	
	//Percorre aCols
	For f:= 1 to Len( aColsOk )
		If !aColsOk[ f , Len( aColsOk[ f ] ) ]
			//Verifica se é somente LinhaOk
			If f <> nAt .and. !aColsOk[ nAt , Len( aColsOk[ nAt ] ) ]
				If aColsOk[ f , nPosCod ] == aColsOk[ nAt , nPosCod ]
					Help( " " , 1 , "JAEXISTINF" , , aHeadOk[ nPosCod , 1 ] )
					Return .F.
				Endif
			Endif
		Endif
	Next f
	
	PutFileInEof( "TGA" ) 

Return .t.
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

	Local aRotina :=	{ 	{ STR0002 , "AxPesqui" , 0 , 1 } , ; //"Pesquisar"
		                    { STR0003 , "NGCAD02"  , 0 , 2 } , ; //"Visualizar"
		                    { STR0004 , "NGCAD02"  , 0 , 3 } , ; //"Incluir"
		                    { STR0005 , "NGCAD02"  , 0 , 4 } , ; //"Alterar"
		                    { STR0006 , "NGCAD02"  , 0 , 5 , 3 } } //"Excluir"
	
Return aRotina