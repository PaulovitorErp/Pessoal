#include "SGAA720.ch"
#include "Protheus.ch"

#DEFINE _nVERSAO 2 //Versao do fonte
//-------------------------------------------------------------------------------
/*/{Protheus.doc} SGAA720()
Cadastro de Poluentes

@Author: Elynton Fellipe Bazzo
@since: 03/05/2013
@version 110
@return .T.
/*/
//--------------------------------------------------------------------------------
Function SGAA720()

	Local aNGBEGINPRM	:= NGBEGINPRM(_nVERSAO,,{"TEG"})

	If Amiin(56) //Verifica se o usu�rio possui licen�a para acessar a rotina.

	Private cCadastro	:= STR0001 //"Cadastro de Poluentes"
	Private aRotina		:= MenuDef()

	//------------------------------
	// Endereca a funcao de BROWSE
	//------------------------------
	If !NGCADICBASE("TEG_CODIGO","D","TEG",.F.)
		If !NGINCOMPDIC("UPDSGA24","THYPMU",.F.)
			Return .F.
		EndIf
	EndIf

	dbSelectArea( "TEG" )
	dbSetOrder( 01 )
	dbGoTop()
	mBrowse( 6,1,22,75,"TEG" )

	EndIf

	NGRETURNPRM( aNGBEGINPRM )

Return .T.
//--------------------------------------------------------------------------------
/*/{Protheus.doc} MenuDef()
Utilizacao de Menu Funcional.
Parametros do array a Rotina:
							1. Nome a aparecer no cabecalho
							2. Nome da Rotina associada
							3. Reservado
							4. Tipo de Transa��o a ser efetuada:
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

		  aRotina := {{	STR0002	, "AxPesqui"  , 0 , 1	},;//"Pesquisar"
					 { 	STR0003	, "NGCAD01"   , 0 , 2	},;//"Visualizar"
					 { 	STR0004	, "NGCAD01"   , 0 , 3	},;//"Incluir"
					 { 	STR0005	, "NGCAD01"   , 0 , 4	},;//"Alterar"
					 { 	STR0006	, "NGCAD01"   , 0 , 5, 3}}//"Excluir"

Return aRotina