#INCLUDE "MDTA852.ch"
#include "Protheus.ch"

#DEFINE _nVERSAO 1 //Versao do fonte
//---------------------------------------------------------------------
/*/{Protheus.doc} MDTA852
Programa para cadastro de classes

@return

@sample
MDTA852()

@author Jackson Machado
@since 22/03/2013
@version 1.0
/*/
//---------------------------------------------------------------------
Function MDTA852()

	Local nOpcx
	
	//-----------------------------------------------------
	// Armazena variaveis p/ devolucao (NGRIGHTCLICK)
	//-----------------------------------------------------
	Local aNGBEGINPRM	:= NGBEGINPRM( _nVERSAO,,{"TG4",{"TGD"}} )
	Private aRotina		:= MenuDef()
	
	Private cCadastro	:= OemtoAnsi( STR0001 ) //"Classes"
	Private aChkDel		:= {} , bNgGrava := { | | MDT852VAL() }
	Private aClasses
	
	If !ChkOHSAS()
		//-----------------------------------------------------
		// Devolve variaveis armazenadas (NGRIGHTCLICK)
		//-----------------------------------------------------
		NGRETURNPRM( aNGBEGINPRM )
		Return .F.
	EndIf
	
	DbSelectArea( "TG4" )
	DbSetOrder( 1 )
	mBrowse( 6 , 1 , 22 , 75 , "TG4" )
	
	//-----------------------------------------------------
	// Devolve variaveis armazenadas (NGRIGHTCLICK)
	//-----------------------------------------------------
	NGRETURNPRM( aNGBEGINPRM )

Return .T.
//---------------------------------------------------------------------
/*/{Protheus.doc} MDT852CLA
Carrega uma Array de Classe para validacao dos Pesos

@return aClasse - Array contendo as classes

@sample
MDT852CLA()

@author Jackson Machado
@since 22/03/2013
@version 1.0
/*/
//---------------------------------------------------------------------
Function MDT852CLA()

	Local aClasse	:= {}
	Local aOldArea	:= GetArea() // Guarda variaveis de alias e indice
	
	DbSelectArea( "TG4" )
	DbSetOrder( 1 )
	DbSeek( xFilial( "TG4" ) )
	
	Do While !Eof() .and. xFilial( "TG4" ) == TG4->TG4_FILIAL
		aAdd( aClasse , { TG4->TG4_LIMMIN , TG4->TG4_LIMMAX , TG4->TG4_DESCRI , TG4->TG4_CODCLA } )
		DbSkip()
	EndDo
	
	RestArea( aOldArea )

Return aClasse
//---------------------------------------------------------------------
/*/{Protheus.doc} MDT852VAL
Valida os Pesos Minimo e Maximo para nao haver duplicidade de Classes

@return Lógico - Retorna verdadeiro caso não haja duplicidade

@sample
MDT852VAL()

@author Jackson Machado
@since 22/03/2013
@version 1.0
/*/
//---------------------------------------------------------------------
Function MDT852VAL()

	Local i , j , k//Contadores de For
	Local nMinimo , nMaximo
	Local cFaixa := ""
	Local lClasseJaExiste := .f.
	
	aClasses := MDT852CLA()
	If nOpcao == 5
		If ( nPos := aScan( aClasses, { | x | x[ 3 ] == M->TG4_DESCRI } ) ) > 0
			aDel( aClasses , nPos )
			aSize( aClasses , Len( aClasses ) - 1 )
		EndIf
	EndIf
	
	If Inclui .or. Altera
		For i := 1 To Len( aClasses )
			If aClasses[i][4] <> M->TG4_CODCLA
				nMinimo := aClasses[ i , 1 ]
				nMaximo := aClasses[ i , 2 ]
				
				If ( M->TG4_LIMMIN < nMinimo .And. M->TG4_LIMMAX > nMaximo )
					lClasseJaExiste := .T.
				ElseIf ( M->TG4_LIMMIN = nMinimo .And. M->TG4_LIMMAX = nMaximo )
					lClasseJaExiste := .T.
				ElseIf ( ( M->TG4_LIMMIN > nMinimo .And. M->TG4_LIMMIN < nMaximo ) .And. ;
						( M->TG4_LIMMAX > nMinimo	.And. M->TG4_LIMMAX > nMaximo ) )
					lClasseJaExiste := .T.
				ElseIf ( M->TG4_LIMMIN < nMinimo .And. M->TG4_LIMMAX > nMinimo .And. M->TG4_LIMMAX < nMaximo )
					lClasseJaExiste := .T.
				ElseIf ( M->TG4_LIMMIN > nMinimo .And. M->TG4_LIMMIN < nMaximo .And. M->TG4_LIMMAX > nMaximo )
					lClasseJaExiste := .T.
				ElseIf ( M->TG4_LIMMIN > nMinimo .And. M->TG4_LIMMIN < nMaximo .And. M->TG4_LIMMAX < nMaximo )
					lClasseJaExiste := .T.
				EndIf
				
				If lClasseJaExiste
					MsgStop( STR0002 + aClasses[ i , 3 ] ) //"A faixa informada ja existe "
					Return .F.
				EndIf
				
			EndIf
		Next i
	EndIf

Return .T.
//---------------------------------------------------------------------
/*/{Protheus.doc} MDT852CAD
Chama a funcao de criacao da tela de cadastro

@return

@sample
MDT852CAD()

@author Jackson Machado
@since 22/03/2013
@version 1.0
/*/
//---------------------------------------------------------------------
Function MDT852CAD( cAlias , nRecno , nOpcx )

	Private nOpcao := nOpcx
	
	NGCAD01( cAlias , nRecno , nOpcx )

Return
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

	Local aRotina :=	{ 	{ STR0003 , "AxPesqui" , 0 , 1 } , ; //"Pesquisar"
							{ STR0004 , "MDT852CAD" , 0 , 2 } , ; //"Visualizar"
							{ STR0005 , "MDT852CAD" , 0 , 3 } , ; //"Incluir"
							{ STR0006 , "MDT852CAD" , 0 , 4 } , ; //"Alterar"
							{ STR0007 , "MDT852CAD" , 0 , 5 , 3 } } //"Excluir"

Return aRotina