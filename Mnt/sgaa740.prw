#include "SGAA740.ch"
#include "Protheus.ch"
//---------------------------------------------------------------------
/*/{Protheus.doc} SGAA740()
Programa para cadastro de Prodlist/Agro-Pesca

@author  Elynton Fellipe Bazzo
@since   03/05/2013
@version P11
@return  .T.
/*/
//---------------------------------------------------------------------
Function SGAA740()

	Local aNGBEGINPRM 	:= NGBEGINPRM(1)
	
	Private aRotina 	:= MenuDef()
	Private cCadastro 	:= OemtoAnsi(STR0001)//"Prodlist/Agro-Pesca"
	Private AsMenu 		:= {}, aChkDel := {}, bNGGrava,aChoice := {},aVarNao := {}
	
	If !NGCADICBASE("TEM_CODIGO","D","TEM",.F.)
		If !NGINCOMPDIC("UPDSGA30","THYQNJ",.F.)
			Return .F.
		EndIf
	EndIf
	
	dbSelectArea("TEM")
	dbSetOrder(01)
	
	cNGCADELET := "SGAA740DE"
	aGETNAO    := {{"TEM_CODIGO","M->TEJ_CODIGO"}}
	cGETWHILE  := "TEM_FILIAL == xFilial('TEM') .and. TEM_CODIGO == M->TEJ_CODIGO"
	cGETMAKE   := "TEJ->TEJ_CODIGO"
	cGETKEY    := "M->TEJ_CODIGO+M->TEM_CODPRO"
	cGETALIAS  := "TEM"     
	
	cTUDOOK    := "AllwaysTrue()"
	cLINOK     := "AllwaysTrue()"
	
	bNGGrava   := {|| SGAA740GR()}
	
	DbSelectArea( "TEJ" )
	DbSetOrder( 01 )
	mBrowse( 6, 1,22,75,"TEJ" )
	
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

	Local aRotina :=	{{ "Pesquisar" , "AxPesqui" , 0 , 1	},;
		                { "Visualizar" , "NGCAD02"  , 0 , 2	},;
		                { "Incluir"    , "NGCAD02"  , 0 , 3	},;
		                { "Alterar"    , "NGCAD02"  , 0 , 4	},;
		                { "Excluir"    , "NGCAD02"  , 0 , 5, 3}}
	
Return aRotina
//---------------------------------------------------------------------
/*/{Protheus.doc} SGAA740LI()
Validacao da GetDados para nao repetir o Produto

@author  Elynton Fellipe Bazzo
@since   03/05/2013
@version P11
@return  .T.
/*/
//---------------------------------------------------------------------
Function SGAA740LI()

	If !aCols[n][Len(aCols[n])] .AND. aScan( aCols, { |x| x[1] == M->TEM_CODPRO .And. !x[Len(aCols[n])]}) > 0
		Help(" ",1,"JAGRAVADO")
		Return .f.
	Endif
	
Return .T.
//---------------------------------------------------------------------
/*/{Protheus.doc} SGAA740DE()
Validacao da GetDados quando deletada uma linha

@author  Elynton Fellipe Bazzo
@since   03/05/2013
@version P11
@return  .T.
/*/
//---------------------------------------------------------------------
Function SGAA740DE()

	If !aTail(aCols[n]) .AND. aScanX(aCols,{ |x,y| x[1]  == aCols[n][1] .AND. y <> n .And. !x[Len(aCols[n])]}) > 0
		aTail(aCols[n]) := .t.
		oGet:Refresh()
		Help(" ",1,"JAGRAVADO")
		Return .f.
	Endif

Return .T.
//---------------------------------------------------------------------
/*/{Protheus.doc} SGAA740GR()
Tira os registros deletados do aCols

@author  Elynton Fellipe Bazzo
@since   03/05/2013
@version P11
@return  .T.
/*/
//---------------------------------------------------------------------
Function SGAA740GR()

	aCols := NGTDELACOLS(aCols)

Return .T.
//---------------------------------------------------------------------
/*/{Protheus.doc} SGAA740WSIG()
When do campo Inf. Sigilo

@author  Elynton Fellipe Bazzo
@since   03/05/2013
@version P11
@return  lRet
/*/
//---------------------------------------------------------------------
Function SGAA740WSIG()

	Local lRet := .F.
	
	If M->TEJ_SIGILO <> "1"
		M->TEJ_INFSI  := ""
		M->TEJ_TPSIGI := " "
		M->TEJ_CODLEG := Space(TAMSX3("TA0_CODLEG")[1])
		M->TEJ_EMENTA := Space(40)
	Else
		lRet := .T.
	Endif
	
Return lRet