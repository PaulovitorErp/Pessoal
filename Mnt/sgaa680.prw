#INCLUDE "SGAA680.CH"
#INCLUDE "PROTHEUS.CH"

//---------------------------------------------------------------------
/*/{Protheus.doc} SGAA680()
Programa de cadastro de Corpo Receptor

@author  Elynton Fellipe Bazzo
@since   03/05/2013
@version P11
@return  .T.
/*/
//---------------------------------------------------------------------
Function SGAA680()

	Local aNGBEGINPRM := NGBEGINPRM()

	Private aRotina   := MenuDef()
	//--------------------------------------------
	// Define o cabecalho da tela de atualizacoes
	//--------------------------------------------
	Private cCadastro := OemtoAnsi(STR0001) //"Corpo Receptor"

	//--------------------------------------------
	//aCHKDEL array que verifica a INTEGRIDADE REFERENCIAL
	//na exclusão do registro.
	//1 - Chave de pesquisa
	//2 - Alias de pesquisa
	//3 - Ordem de pesquisa
	//--------------------------------------------
	aCHKDEL := { {'TEA->TEA_CODCRE', "TCD", 1} }

	If !NGCADICBASE("TEA_CODCRE","D","TEA",.F.)
		If !NGINCOMPDIC("UPDSGA23","THYRMV",.F.)
			Return .F.
		EndIf
	EndIf

	//--------------------------------------------
	// Endereca a funcao de BROWSE
	//--------------------------------------------
	mBrowse( 6, 1,22,75,"TEA" )

	NGRETURNPRM( aNGBEGINPRM )

Return .T.
//---------------------------------------------------------------------
/*/{Protheus.doc} MenuDef()
Utilizacao de menu Funcional

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

	Local aRotina := {  { STR0004	,"AxPesqui"  , 0 , 1},;//"Pesquisar"
	                    { STR0005	,"NGCAD01"   , 0 , 2},;//"Visualizar"
	                    { STR0006	,"NGCAD01"   , 0 , 3},;//"Incluir"
	                    { STR0007	,"NGCAD01"   , 0 , 4},;//"Alterar"
	                    { STR0008	,"NGCAD01"   , 0 , 5, 3} }//"Excluir"

Return aRotina
//---------------------------------------------------------------------
/*/{Protheus.doc} SGAA680VLD(cCampo)
Validacao dos campos da rotina

@author  Elynton Fellipe Bazzo
@since   03/05/2013
@version P11
@return  .T.
/*/
//---------------------------------------------------------------------
Function SGAA680VLD(cCampo)

	If cCampo == "TEA_CLACOR"
		If M->TEA_TIPCOR != "1" .and. M->TEA_CLACOR == "4"
			ShowHelpDlg(STR0002,{STR0003},1) //"A Classe 4 só se aplica a Corpo Receptor de tipo 1=Água Doce."
			Return .F.
		Endif
	Endif

Return .T.