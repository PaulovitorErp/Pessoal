#INCLUDE "SGAA690.CH"
#include "Protheus.ch"
 
#DEFINE _nVERSAO 2 //Versao do fonte    
//-------------------------------------------------------------------------------
/*/{Protheus.doc} SGAA690() 
Cadastro de Fonte Energéticas.

@Author: Elynton Fellipe Bazzo 
@since: 03/05/2013
@version 110
@return .T.
/*/ 
//--------------------------------------------------------------------------------
Function SGAA690()
	
	Local aNGBEGINPRM	:= NGBEGINPRM( _nVERSAO )
	
	Private cCadastro	:= STR0001 //"Cadastro de Fontes Energéticas"
	Private aRotina		:= MenuDef()
	Private bNGGrava	:= {|| ExistChav("TED", M->TED_ANO+M->TED_TIPO) }
	
	//-------------------------------
	//Endereca a funcao de BROWSE
	//-------------------------------
	If !NGCADICBASE("TED_ANO","D","TED",.F.)
		If !NGINCOMPDIC("UPDSGA24","THYPMU",.F.)
			Return .F.
		EndIf
	EndIf
	
	dbSelectArea( "TED" )
	dbSetOrder( 01 )
	dbGoTop()
	mBrowse( 6,1,22,75,"TED" )
	
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

		  aRotina := {{	STR0020	, "AxPesqui"  , 0 , 1	},;//"Pesquisar"
					 { 	STR0021	, "NGCAD01"   , 0 , 2	},;//"Visualizar"
					 { 	STR0022	, "NGCAD01"   , 0 , 3	},;//"Incluir"
					 { 	STR0023	, "NGCAD01"   , 0 , 4	},;//"Alterar"
					 { 	STR0024	, "NGCAD01"   , 0 , 5, 3}}//"Excluir"

Return aRotina
//-------------------------------------------------------------------------------
/*/{Protheus.doc} SGAA690BOX() 
Retorn ComboBox do tipo.

@Author: Elynton Fellipe Bazzo 
@since: 03/05/2013
@version 110
@return cBox
/*/
//--------------------------------------------------------------------------------
Function SGAA690BOX( cTipo )

	Local cBox    := ""
	Default cTipo := ""
	
	If !Empty(cTipo)
		Do Case
			Case cTipo == "1"
				cBox := STR0002 //"Biomassa - Bagaço da Cana"
			Case cTipo == "2"
				cBox := STR0003 //"Biomassa - Casca de Arroz"
			Case cTipo == "3"
				cBox := STR0004 //"Biomassa - Serragem"
			Case cTipo == "4"
				cBox := STR0005 //"Biomassa - Lã Morta de Algodão"
			Case cTipo == "5"
				cBox := STR0006 //"Borracha Galvanizada"
			Case cTipo == "6"
				cBox := STR0007 //"Carvão"
			Case cTipo == "7"
				cBox := STR0008 //"Coque"
			Case cTipo == "8"
				cBox := STR0009 //"Energia Elétrica"
			Case cTipo == "9"
				cBox := STR0010 //"Energia Fotovoltaica"
			Case cTipo == "A"
				cBox := STR0011 //"Energia Solar"
			Case cTipo == "B"
				cBox := STR0012 //"Gás Líquido de Petróleo(GLP)"
			Case cTipo == "C"
				cBox := STR0013 //"Gás Natural"
			Case cTipo == "D"
				cBox := STR0014 //"Lenha"
			Case cTipo == "E"
				cBox := STR0015 //"Óleo Combustível"
			Case cTipo == "F"
				cBox := STR0016 //"Óleo Diesel"
			Case cTipo == "G"
				cBox := STR0017 //"Óleo Residual"
			Case cTipo == "H"
				cBox := STR0018 //"Pneu Picado"
			Case cTipo == "I"
				cBox := STR0019 //"Querosene"
			OtherWise
				cBox := ""
		EndCase
	Else
		cBox += "1=" + STR0002+";" //"Biomassa - Bagaço da Cana"
		cBox += "2=" + STR0003+";" //"Biomassa - Casca de Arroz"
		cBox += "3=" + STR0004+";" //"Biomassa - Serragem"
		cBox += "4=" + STR0005+";" //"Biomassa - Lã Morta de Algodão" 
		cBox += "5=" + STR0006+";" //"Borracha Galvanizada"
		cBox += "6=" + STR0007+";" //"Carvão"
		cBox += "7=" + STR0008+";" //"Coque"
		cBox += "8=" + STR0009+";" //"Energia Elétrica"
		cBox += "9=" + STR0010+";" //"Energia Fotovoltaica"
		cBox += "A=" + STR0011+";" //"Energia Solar"
		cBox += "B=" + STR0012+";" //"Gás Líquido de Petróleo(GLP)"
		cBox += "C=" + STR0013+";" //"Gás Natural"
		cBox += "D=" + STR0014+";" //"Lenha"
		cBox += "E=" + STR0015+";" //"Óleo Combustível"
		cBox += "F=" + STR0016+";" //"Óleo Diesel"
		cBox += "G=" + STR0017+";" //"Óleo Residual"
		cBox += "H=" + STR0018+";" //"Pneu Picado"
		cBox += "I=" + STR0019+";" //"Querosene"
	Endif
	 
Return cBox
//-------------------------------------------------------------------------------
/*/{Protheus.doc} SGAA690WHEN(cVar) 
When dos campos da tela.

@Author: Elynton Fellipe Bazzo 
@since: 03/05/2013
@version 110
@return lRet
/*/
//--------------------------------------------------------------------------------
Function SGAA690WHEN(cVar)

	Local lRet	 := .T.
	Default cVar := ""
	
	If cVar == "TED_AUTGER" .or. cVar == "TED_REDPUB"
		If M->TED_TIPO != "8"//Se nao for energia eletrica
			lRet := .F.
			&("M->"+cVar) := 0
		Endif
	ElseIf cVar == "TED_QTCONS"
		lRet := .T.
	ElseIf !Empty(cVar)
		If M->TED_TIPO == "8" .or. M->TED_TIPO == "9" .or. M->TED_TIPO == "A"//Se nao for Biomassa
			lRet := .F.
			&("M->"+cVar) := 0
		Endif
	Endif
	
Return lRet
//-------------------------------------------------------------------------------
/*/{Protheus.doc} SGAA690Val 
Função que tem o obejtivo de realizar avalidação dos campos:
   - TED_CAUTGE  
   - TED_CREDPU  
   
@Author Guilherme Freudenburg
@since 01/04/2015
@version 110
@return 
/*/
//--------------------------------------------------------------------------------
Function SGAA690VAL(cCampo)

Local cValor:= ""  
Local nPosAUT:= 0   
Local lRet:= .T. 

If !Empty(Val(cCampo))//Verifica se o campo foi preenchido
	nPosAUT:= At(".",cValToChar(cCampo))
	cValor:= SubStr(cCampo,nPosAUT+1,Len(cCampo))
	If Empty(cValor)   
		ShowHelpDlg(STR0025,{STR0026},2,{STR0027},2) //ATENÇÃO " " Os valores decimais, não foram preenchidos. " " Favor preencher os valores decimais.
		lRet:=.F. 
	Endif
Endif
	
Return lRet