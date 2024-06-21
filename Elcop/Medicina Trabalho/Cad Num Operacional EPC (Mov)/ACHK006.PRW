#Include 'Protheus.ch'
#Include 'FWMVCDef.ch'
#Include 'topconn.ch'
#Include 'tbiconn.ch'
#Include 'APWizard.ch'

#Define ENTER 	Chr(13) + Chr(10)
                                        
/*
_____________________________________________________________________________
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦Programa  ¦ ACHK006.prw ¦ Autor ¦ Sinval Gedolin ¦ Data ¦ Janeiro/2021 ¦¦¦
¦¦+----------+------------------------------------------------------------¦¦¦
¦¦¦Descrição ¦ Tela de Cadastrodo Num Operacional x EPC           	      ¦¦¦
¦¦¦          ¦ 															  ¦¦¦
¦¦+----------+------------------------------------------------------------¦¦¦
¦¦¦Objetivo  ¦ 			                                                  ¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯
*/ 

User Function ACHK006()

	Local oBrowse
	Local aArea := (GetArea())

	//Instânciando FWMBrowse - Somente com dicionário de dados dadadas
	oBrowse := FWmBrowse():New()

	//Setando a tabela
	oBrowse:SetAlias( 'ZCA' )

	//Setando a descrição da rotina
	oBrowse:SetDescription('Número Operacional x EPC')
 	oBrowse:SetDetails(.F., {||})
	oBrowse:SetWalkThru(.F.)
	oBrowse:SetAmbiente(.T.) 

	//Adiciona Legenda
//	oBrowse:AddLegend( "ZCB_QTTDEV == 0", "GREEN" , "Sem Devolução    " )
//	oBrowse:AddLegend( "ZCB_QTDENT - ZCB_QTTDEV > 0", "YELLOW", "Devolução Parcial" )
//	oBrowse:AddLegend( "ZCB_QTDENT - ZCB_QTTDEV == 0", "RED"   , "Devolução Total  " )

	//Ativa a Browse
	oBrowse:Activate()
	RestArea(aArea)

Return

//----------------------------MenuDef---------------------------------------
/*
Define as operações que serão realizadas pela aplicação.
Na MenuDef da aplicação instanciamos a interface (View) de outra aplicação
*/

Static Function MenuDef()

	Local aRotina := {}

	// Faz referencia a uma VIEWDEF             
	ADD OPTION aRotina TITLE 'Pesquisar'  		ACTION 'PesqBrw'         			OPERATION 1 ACCESS 0
	ADD OPTION aRotina Title 'Visualizar' 		Action 'VIEWDEF.ACHK006' 			OPERATION 2 ACCESS 0
	//ADD OPTION aRotina Title 'Incluir'    		Action 'VIEWDEF.ACHK006' OPERATION 3 ACCESS 0
	ADD OPTION aRotina Title 'EPCs'     		Action 'VIEWDEF.ACHK006' 			OPERATION 4 ACCESS 0
	ADD OPTION aRotina Title 'Imprimir'    		Action 'U_RDMT001(ZCA->ZCA_NUMOPE)' OPERATION 6 ACCESS 0

Return aRotina

//----------------------------ModelDef---------------------------------------

/*
Define a regra de negócios propriamente dita onde são definidas
* Todas as entidades (tabelas) que farão parte do modelo de dados (Model); 
* Regras de dependência entre as entidades;
* Validações (de campos e aplicação);
* Persistência dos dados (gravação).
*/

Static Function ModelDef()
	Local aArea := GetArea()

	//Cria a estrutura a ser usada no Modelo de Dados
	//							   <nType>, <cAliasSX2>, [bSX3]
	Local oStruZCA := FWFormStruct(1 , 'ZCA', )
	Local oStruZCB := FWFormStruct(1 , 'ZCB', )
	Local oStruZD6 := FWFormStruct(1 , 'ZD6', )
    
	//Cria o objeto do Modelo de Dados
	Local oModel := MPFormModel():New('ACHK006A', /*bPre*/, /*bPos*/, /*bCommit*/, /*bCancel*/)

   	//Criação de um componente de formulário no Modelo de Dados (AddFields)
	oModel:AddFields('ZCA_MASTER', 			  , oStruZCA, /*bPre*/, /*bPos*/, /*bLoad*/)

	oModel:AddGrid('ZCB_MODEL'	 ,'ZCA_MASTER', oStruZCB,/*bLinePre*/, /*bLinePost*/, /*bPre*/, /*bPost*/, /*bLoad*/)       

	oModel:SetRelation('ZCB_MODEL', {{'ZCB_FILIAL', 'XFilial("ZCA")'},;
	 								 {'ZCB_NUMOPE' , 'ZCA_NUMOPE'   } },;
	 								 ZCB->(IndexKey(1)))

	oModel:AddGrid('ZD6_MODEL'	 ,'ZCB_MODEL', oStruZD6,/*bLinePre*/, /*bLinePost*/, /*bPre*/, /*bPost*/, /*bLoad*/)       

	//Num Operacional x item e as devoluções pelo item
	oModel:SetRelation('ZD6_MODEL', {{'ZD6_FILIAL'	, 'XFilial("ZCB")'	} ,;
	 								 {'ZD6_NUMOPE' 	, 'ZCB_NUMOPE'   	} ,;
	 								 {'ZD6_ITEM' 	, 'ZCB_ITEM'   		} ,;
	 								 {'ZD6_COD' 	, 'ZCB_COD'   		} },;
	 								 ZD6->(IndexKey(1)))


	//Controle de não repetição de Linha
	oModel:GetModel( 'ZCB_MODEL' ):SetUniqueLine( { 'ZCB_FILIAL', 'ZCB_NUMOPE', 'ZCB_ITEM' } )

	//Controle de não repetição de Linha
	oModel:GetModel( 'ZD6_MODEL' ):SetUniqueLine( { 'ZD6_FILIAL', 'ZD6_NUMOPE', 'ZD6_ITEM', 'ZD6_COD' } )

	//Adicionando descrição ao modelo
	oModel:SetDescription('Cadastro de Num Operacional x EPC')

	//Descrição dos componentes do modelo de dados (SetDescription)
	//Setando a descrição do formulário
	oModel:GetModel('ZCA_MASTER'):SetDescription('Numero Operacional')
	oModel:GetModel('ZCB_MODEL'):SetDescription('Numero Operacional x EPC')
	oModel:GetModel('ZD6_MODEL'):SetDescription('Numero Operacional x EPC x Devolução')	

	//A Chave Primária é obrigatória, caso não tenha defina um array vazio
	oModel:SetPrimaryKey({'ZCA_FILIAL','ZCA_NUMOPE'}) // ZA0_FILIAL+ZA0_CARGA   
	
	oStruZCA:SetProperty("ZCA_NUMOPE",MODEL_FIELD_WHEN	,{|| .F. })
	oStruZCA:SetProperty("ZCA_DESCRI",MODEL_FIELD_WHEN	,{|| .F. })
	oStruZCA:SetProperty("ZCA_NUMCON",MODEL_FIELD_WHEN	,{|| .F. })
	oStruZCA:SetProperty("ZCA_CODCLI",MODEL_FIELD_WHEN	,{|| .F. })
	oStruZCA:SetProperty("ZCA_LOJA"	 ,MODEL_FIELD_WHEN	,{|| .F. })
	oStruZCA:SetProperty("ZCA_FILCLI",MODEL_FIELD_WHEN	,{|| .F. })
	oStruZCA:SetProperty("ZCA_CODGRU",MODEL_FIELD_WHEN	,{|| .F. })

	oModel:GetModel('ZD6_MODEL'):SetOptional(.T.)
	oModel:GetModel('ZD6_MODEL'):SetNoDeleteLine(.T.)
	oModel:GetModel('ZCB_MODEL'):SetNoDeleteLine(.T.)

	RestArea(aArea)
Return oModel

//------------------------------ViewDef-------------------------------------
/*
Define como será a interface (construção da interface) e portanto como o usuario interage com o modelo (Model)
recebe dados informado pelo usuario e fornece ao modelo (modelDef).
*/
Static Function ViewDef()

	Local aArea := GetArea()

	//Cria a estrutura a ser usada na View
	//Construção da interface de visualização. Cria o objeto de View ... Iniciando a construção da interface
	Local oView 	:= FWFormView():New()

	//Cria um objeto de modelo de dados no ModelDef() do fonte informado
	Local oModel 	:= FWLoadModel('ACHK006')

	Local oStruZCA  := FWFormStruct(2 , 'ZCA', {|x|chkCampo('ZCA',alltrim(x))})
	Local oStruZCB  := FWFormStruct(2 , 'ZCB', {|x|chkCampo('ZCB',alltrim(x))})
	Local oStruZD6  := FWFormStruct(2 , 'ZD6', {|x|chkCampo('ZD6',alltrim(x))})

	//Definimos qual o modelo de dados (Model) que será utilizado na interface (View)
	oView:SetModel(oModel)

	//Adiciona na nossa View um controle do tipo formulário (antiga Enchoice)
	oView:AddField('ZCA_VIEW', oStruZCA, 'ZCA_MASTER')
	
	oView:AddGrid('ZCB_VIEW', oStruZCB , 'ZCB_MODEL')
	oView:AddGrid('ZD6_VIEW', oStruZD6 , 'ZD6_MODEL')

	// Criar "box" horizontal para receber algum elemento da view
	oView:CreateHorizontalBox( 'ID_HBOX_SUPERIOR' 	, 15 )    
	oView:CreateHorizontalBox( 'ID_HBOX_MEIO'		, 65 )    
	oView:CreateHorizontalBox( 'ID_HBOX_INFERIOR'	, 20 )    

	// Quebra em 2 "box" vertical para receber algum elemento da view
	oView:CreateVerticalBox( 'BI_TOT',100, 'ID_HBOX_MEIO' )
	oView:CreateVerticalBox( 'BI_DEV',100, 'ID_HBOX_INFERIOR' )
	
	// Relaciona o identificador (ID) da View com o "box" para exibicao
	oView:SetOwnerView( 'ZCA_VIEW', 'ID_HBOX_SUPERIOR'  )
	
	oView:SetOwnerView( 'ZCB_VIEW' , 'BI_TOT' )
	oView:SetOwnerView( 'ZD6_VIEW' , 'BI_DEV' )

	// Liga a identificacao do componente
	oView:EnableTitleView('ZCA_MASTER', 'Numero Operacional')
	oView:EnableTitleView('ZCB_MODEL' , 'Numero Operacional x EPC')
	oView:EnableTitleView('ZD6_MODEL' , 'Numero Operacional x EPC x Devoluções')

//	oView:SetFieldAction("ZCA_CODGRU" , {|oView, oModel| addZCB(oView, oModel)})

    oView:AddIncrementField( 'ZCB_VIEW', 'ZCB_ITEM' )
    oView:AddIncrementField( 'ZD6_VIEW', 'ZD6_SEQ' )

	//oView:SetViewProperty("ZCB_VIEW" , "GRIDVSCROLL", {.F.})	
	//oView:SetViewProperty("ZD6_VIEW" , "GRIDVSCROLL", {.F.})	
	
	oView:AddUserButton( "Importa EPC", "BMPCONS", { || addZCB(oView, oModel) } ) 

	RestArea(aArea)
Return oView
          

/* Alimenta ZCB com o correspondente cadastro no grupo de EPC */
static function addZCB(oView, oModel)
	Local _aAreas	:= getArea()
	Local nItem		:= 1

	oModel 		:= FWModelActive()                
	oModelZCA 	:= oModel:GetModel('ZCA_MASTER')
	oModelZCB	:= oModel:GetModel('ZCB_MODEL')
	cCodGru		:= oModelZCA:GetValue("ZCA_CODGRU")

	ZCG->(DbSetOrder(1))
	ZCG->(DbSeek(xFilial("ZCG")+cCodGru))
	do while ZCG->(!Eof()) .and. ZCG->(ZCG_FILIAL+ZCG_CODGRU) == xFilial("ZCG")+ cCodGru
		oModelZCB:AddLine()                      
		oModelZCB:LoadValue('ZCB_NUMOPE', oModelZCA:GetValue("ZCA_NUMOPE") )
		oModelZCB:LoadValue('ZCB_ITEM'	, StrZero(nItem,3) 	)
		oModelZCB:LoadValue('ZCB_COD'	, ZCG->ZCG_CODEPC	)
		oModelZCB:LoadValue('ZCB_DESC'	, Posicione("SB1",1,xFilial("SB1")+ZCG->ZCG_CODEPC,"B1_DESC"))
		oModelZCB:LoadValue('ZCB_QTDENT', ZCG->ZCG_QTDE )
		oModelZCB:GoLine(1)
		oView:Refresh('ZCB_VIEW') 
		nItem++
		ZCG->(DbSkip())
	enddo

	RestArea(_aAreas)
return(.T.)


/* Define quais campos poderão ou não aparecer nos forms */
static function chkCampo(cAlias,cCampo)
Local lReturn := .T.

if cAlias == "ZA0"
	if alltrim(cCampo) $ "ZA0_DTINC-ZA0_USERIN-ZA0_CODMOT-ZA0_DIVERG-ZA0_VLRTOT-ZA0_VLRDIF"
		lReturn := .F.
	else
		lReturn := .T.	
	endif
endif

if cAlias == "ZCB"
	if alltrim(cCampo) $ "ZCB_NUMOPE"
		lReturn := .F.
	else
		lReturn := .T.	
	endif
endif

if cAlias == "ZD6"
	if alltrim(cCampo) $ "ZD6_NUMOPE-ZD6_ITEM-ZD6_QTDENT"
		lReturn := .F.
	else
		lReturn := .T.	
	endif
endif

return(lReturn)

/*
___________________________________________________________________________
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦Programa  ¦ ANFF001.prw ¦ Autor ¦ Sinval         ¦ Data ¦    05/2021   ¦¦¦
¦¦+----------+------------------------------------------------------------¦¦¦
¦¦¦Descriçào ¦ Ponto de Entrada da ANFF001                                ¦¦¦
¦¦¦			 ¦ 															  ¦¦¦
¦¦¦          ¦ 															  ¦¦¦
¦¦+----------+------------------------------------------------------------¦¦¦
¦¦¦Objetivo  ¦                                            				  ¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯
*/

/*
IDs dos Pontos de Entrada
-------------------------

MODELPRE 			Antes da alteração de qualquer campo do modelo. (requer retorno lógico)
MODELPOS 			Na validação total do modelo (requer retorno lógico)

FORMPRE 			Antes da alteração de qualquer campo do formulário. (requer retorno lógico)
FORMPOS 			Na validação total do formulário (requer retorno lógico)

FORMLINEPRE 		Antes da alteração da linha do formulário GRID. (requer retorno lógico)
FORMLINEPOS 		Na validação total da linha do formulário GRID. (requer retorno lógico)

MODELCOMMITTTS 		Apos a gravação total do modelo e dentro da transação
MODELCOMMITNTTS 	Apos a gravação total do modelo e fora da transação

FORMCOMMITTTSPRE 	Antes da gravação da tabela do formulário
FORMCOMMITTTSPOS 	Apos a gravação da tabela do formulário

FORMCANCEL 			No cancelamento do botão.

BUTTONBAR 			Para acrescentar botoes a ControlBar

MODELVLDACTIVE 		Para validar se deve ou nao ativar o Model

Parametros passados para os pontos de entrada:
PARAMIXB[1] - Objeto do formulário ou model, conforme o caso.
PARAMIXB[2] - Id do local de execução do ponto de entrada
PARAMIXB[3] - Id do formulário

Se for uma FORMGRID
PARAMIXB[4] - Linha da Grid
PARAMIXB[5] - Acao da Grid
*/

User Function ACHK006A

	Local nQtdElIXB		:= 0
	Local oObj			:= ''
	Local cIdPonto		:= ''
	Local cIdModel		:= ''
	Local cClasse		:= ''
	Local nOper 		:= 0          
	Local xRet			:= .T.   
	Local nPosDev

//    Local lMsErroAuto   := .F.    
    
	If PARAMIXB <> Nil
		nQtdElIXB	:= Len(PARAMIXB)
		oObj 		:= PARAMIXB[1]
		cIdPonto	:= PARAMIXB[2]
		cIdModel	:= PARAMIXB[3]
		cClasse 	:= Iif(oObj<>Nil, oObj:ClassName(), '')	// Nome da classe utilizada na rotina (FWFORMFIELD - Formulário, FWFORMGRID - Grid)
		nOper 		:= oObj:getOperation()  

		If cIdPonto == 'MODELVLDACTIVE' 
	
		ElseIf cIdPonto == 'BUTTONBAR'

				xRet := {}
				aadd(xRet,  {'Pesquisa Rapida', 'ATUPRC', { || U_ACHK006P() }, 'Pesquisa Rapida' })

		ElseIf cIdPonto == 'FORMPRE'

		ElseIf cIdPonto == 'FORMPOS'

		ElseIf cIdPonto == 'FORMLINEPRE'    
		
		ElseIf cIdPonto == 'FORMLINEPOS'
				
				oModel 		:= FWModelActive()                
				oModelZCB 	:= oModel:GetModel('ZCB_MODEL')

				oView  		:= FwViewActive()
				nOper		:= oModelZCB:GetOperation()

				if nOper == 3 .or. nOper == 4

					if oModelZCB:GetValue("ZCB_SITEPC")= "1"

						if oModelZCB:GetValue("ZCB_QTDDEV") = 0
							Aviso("Qtde Devolução","Quantidade de Devolução tem que ser Maior do que Zero",{'OK'},3)            
							xRet := .F.            
						Endif

						if empty(alltrim(oModelZCB:GetValue("ZCB_LOCDEV")))
							Aviso("Armazém Devolução","Necessário Informar o Armazém de Devolução",{'OK'},3)            
							xRet := .F.            
						Endif

						if empty(alltrim(oModelZCB:GetValue("ZCB_REPOR")))
							Aviso("Repor","Preencher o Campo Repor Estoque",{'OK'},3)            
							xRet := .F.            
						Endif	
						
					Else

						if Posicione("SB1",1,xFilial("SB1")+oModelZCB:Getvalue( "ZCB_COD" ),"B1_XCONLAU") = "S"
							if empty(alltrim(oModelZCB:GetValue("ZCB_XLAUD1")))
								Aviso("Laudo","Necessário Informar o Laudo do Material ",{'OK'},3)							
								xRet := .F.            
							Endif
						Endif

						if Posicione("SB1",1,xFilial("SB1")+oModelZCB:GetValue("ZCB_COD"),"B1_XCONSER") = "S"
							if empty(alltrim(oModelZCB:GetValue("ZCB_XSERIA")))
								Aviso("Número Série","Necessário Informar o Número de Série do Material ",{'OK'},3)            
								xRet := .F.            
							Endif
						Endif
					
					Endif

					//Valida Quantidade Saida Estoque
					if nOper == 3 .or. nOper == 4

						//Valida Saida
						cProduto := oModelZCB:Getvalue("ZCB_COD")
						cLocal   := oModelZCB:GetValue("ZCB_LOCAL")
						nQtdDev  := oModelZCB:GetValue("ZCB_QTDENT")
						xsequen  := oModelZCB:GetValue("ZCB_XSEQEN")
						nSaldoB2 := 0

						if Empty(xsequen)

							DBSelectArea("SB2")
							SB2->(DBSetOrder(1)) 
							IF DBSeek(xFilial("SB2")+cProduto+cLocal)
								nSaldoB2 := SB2->B2_QATU

								//MsgAlert("Saldo"+cvaltochar(nSaldoB2))
								//MsgAlert("Qtd Entr"+cvaltochar(nQtdDev))

								Aviso("Saldo em Estoque","Estoque Produto "+cProduto+" Armazem "+cLocal+chr(13)+chr(10)+"Estoque Atual << "+transform(nSaldoB2,PesqPict('SB2','B2_QATU'))+" >> Qtd Entregue << "+transform(nQtdDev,PesqPict('SB2','B2_QATU'))+" >> ",{'OK'},3)  

								cYesno :=   "Deseja Executar a Movimentação Cadastro EPC ?"+chr(13)+chr(10);
											+"Produto - "+cProduto+" Local - "+cLocal+"."  //+chr(13)+chr(10);
								//			+"Qtd Atual << "+Alltrim(transform(nSaldoB2,PesqPict('SB2','B2_QATU')))+" >> Qtd Entreg << "+Alltrim(transform(nQtdDev,PesqPict('SB2','B2_QATU')))+" >> ")

								If MsgYesNo(cYesno,"Executar EPC")

									if nQtdDev > nSaldoB2
										Aviso("Estoque","Não e Possivel Realizar Devolucao : "+chr(13)+chr(10)+"Motivo - Falta de Estoque Produto - "+cProduto+" Local - "+cLocal+chr(13)+chr(10)+"Estoque Atual no Armazem <<<< "+transform(nSaldoB2,PesqPict('SB2','B2_QATU'))+" >>>> "+chr(13)+chr(10)+"Quantidade Entregue <<<< "+transform(nQtdDev,PesqPict('SB2','B2_QATU'))+" >>>> ",{'OK'},3)  
										xRet := .F.   
									EndIf

								Else
								xRet := .F.  
								EndIf

							Else
								MsgAlert("Não Existe Saldo e Armazem Criado para Este Produto "+cProduto+" .","Estoque")
								xRet := .F.   
							EndIf

						EndIf
						
					EndIf

				Endif

				/*
				oModel 		:= FWModelActive()                
				oModelZD6 	:= oModel:GetModel('ZD6_MODEL')

				oView  		:= FwViewActive()
				nOper		:= oModelZD6:GetOperation()

				if nOper == 3 .or. nOper == 4

					cProduto := oModelZD6:Getvalue( "ZD6_COD" )
					cLocal   := Alltrim(oModelZD6:GetValue("ZD6_LOCDEV"))
					nSaldoB2 := 0
					nQtdDev  := oModelZD6:GetValue("ZD6_QTDDEV")

					DBSelectArea("SB2")
					SB2->(DBSetOrder(1)) 
					IF DBSeek(xFilial("SB2")+cProduto+cLocal)
						nSaldoB2 := SB2->B2_QATU
					Endif

					if nQtdDev > nSaldoB2
						Aviso("Estoque","Não e Possivel Realizar Devolucao , Motivo - Estoque Atual << "+transform(nSaldoB2,PesqPict('SB2','B2_QATU'))+" >> Menor que Estoque Devolução << "+transform(nQtdDev,PesqPict('SB2','B2_QATU'))+" >> . ",{'OK'},3)  
						xRet := .F.   
					EndIf
				
				EndIf
				*/
//IIF((ZCB->ZCB_QTDENT=ZCB->ZCB_QTTDEV),"BR_VERMELHO","BR_VERDE")   //IIF(Empty(ZCB->ZCB_XSEQEN),"BR_VERMELHO","BR_VERDE")                                                                                                                                  
		ElseIf cIdPonto == 'MODELPRE'

		ElseIf cIdPonto == 'MODELPOS'
		
		ElseIf cIdPonto == 'FORMCOMMITTTSPRE'         
				
		ElseIf cIdPonto == 'FORMCOMMITTTSPOS'

		ElseIf cIdPonto == 'MODELCOMMITTTS'

		ElseIf cIdPonto == 'MODELCOMMITNTTS'
				
				oModel 		:= FWModelActive()    
				oModelZCA 	:= oModel:GetModel('ZCA_MASTER')            
				oModelZCB 	:= oModel:GetModel('ZCB_MODEL')
				oModelZD6   := oModel:GetModel('ZD6_MODEL')

				oView  		:= FwViewActive()
				nOper		:= oModelZCA:GetOperation()

				if nOper == 3 .or. nOper == 4
					ZCB->(DbSetOrder(1))
					if ZCB->(DbSeek(xFilial("ZCB")+oModelZCA:GetValue("ZCA_NUMOPE")))
						do while ZCB->(!Eof()) .and. ZCB->(ZCB_FILIAL+ZCB_NUMOPE) == xFilial("ZCA")+oModelZCA:GetValue("ZCA_NUMOPE")

							if empty(ZCB->ZCB_XSEQEN) //realiza movimentação de estoque

								aNumSeq := fGrvSD3Q(oModelZCA:GetValue("ZCA_NUMOPE"), ZCB->ZCB_COD, ZCB->ZCB_QTDENT,;
													ZCB->ZCB_LOCAL, oModelZCA:GetValue("ZCA_CC"), "502", ZCB->ZCB_DTAENT)

								if Len(aNumSeq) > 0
									ZCB->(RecLock("ZCB", .F.))
									ZCB->ZCB_XSEQEN := aNumSeq[1][1]
									ZCB->ZCB_NUMDOC := aNumSeq[1][2]
									ZCB->(MsUnlock())
								endif
							endif
							ZCB->(DbSkip())
						enddo
					endif

					aProdDev := {}
					ZD6->(DbSetOrder(1))
					if ZD6->(DbSeek(xFilial("ZD6")+oModelZCA:GetValue("ZCA_NUMOPE")))
						do while ZD6->(!Eof()) .and. ZD6->(ZD6_FILIAL+ZD6_NUMOPE) == xFilial("ZD6")+oModelZCA:GetValue("ZCA_NUMOPE")

							if empty(ZD6->ZD6_XSEQDV) //realiza movimentação de estoque

								aNumSeq := fGrvSD3Q(oModelZCA:GetValue("ZCA_NUMOPE"), ZD6->ZD6_COD, ZD6->ZD6_QTDDEV, ZD6->ZD6_LOCDEV,;
													oModelZCA:GetValue("ZCA_CC"), "001", ZD6->ZD6_DTADEV)

								if len(aNumSeq) > 0 
									ZD6->(RecLock("ZD6", .F.))
									ZD6->ZD6_XSEQDV := aNumSeq[1][1]
									ZD6->ZD6_NUMDOC := aNumSeq[1][2]
									ZD6->(MsUnlock())
								endif

							endif

							nPosDev := AScan(aProdDev, ZD6->(ZD6_NUMOPE+ZD6_ITEM+ZD6_COD) )

							if  nPosDev = 0 
								Aadd(aProdDev,{ZD6->(ZD6_NUMOPE+ZD6_ITEM+ZD6_COD), ZD6->ZD6_QTDDEV})
							else
								aProdDev[nPosDev][2] += ZD6->ZD6_QTDDEV

							endif

							ZD6->(DbSkip())
						enddo

						for nPosDev := 1 to len(aProdDev)

							if ZCB->(DbSeek(xFilial("ZCB")+aProdDev[nPosDev][1]))
								ZCB->(RecLock("ZCB",.F.))
								ZCB->ZCB_QTTDEV := aProdDev[nPosDev][2]
								ZCB->(MsUnlock())
							endif
						next

					endif

				endif

  		ElseIf cIdPonto == 'MODELCANCEL'

		EndIf

	EndIf

Return xRet
//se a quantidade entregue for igual a quantidade devolvido fica uma legendinha verde ou vermelha  - totalmente devolvido fica vermelho
static function fGrvSD3Q(cNumOPe, cCodPro, nQtdProd, _cLocal, cCC, cTM, _dData)

    Local _aAreas       := getArea()
    //Local cLocMov       := cLocPad  //GETMV("MV_XLOCMOV",.F.,"01")  //Local de Estoque onde será realizado a movimentação do produto
    Local cTipMov       := cTM //GETMV("MV_XTIPMOV",.F.,"003") //Tipo de Movimentação de Estoque para adicionar ao local o produto
    Local cCCMov        := cCC //GETMV("MV_XCCMOV" ,.F.,"") //Centro de Custo que identifica a movimentação

    Local lMsErroAuto   := .F.
    Local nOper         := 3
    Local aCabecalho    := {}
    Local aItem         := {}
    Local aItens        := {}
    Local cObs          := "EPC" + cNumOPe
	Local aNumSeq		:= {}

    Private l241Auto    := .T.

    aCabecalho := { {"D3_TM"      , cTipMov             , NIL},;
                    {"D3_EMISSAO" , _dData	            , NIL},;
                    {"D3_FILIAL"  , xFilial("SD3")      , Nil},;
                    {"D3_CC"      , cCCMov              , NIL}}

    aItem   := {    {"D3_COD"       , cCodPro           , NIL},;
                    {"D3_QUANT"     , nQtdProd          , NIL},;
                    {"D3_LOCAL"     , _cLocal           , NIL},;
                    {"D3_USUARIO"   , cUserName         , NIL},;
                    {"D3_OBSERVA"   , cObs              , Nil} }    

    aadd(aItens, aItem)

	SB2->(DbSetOrder(1))
	if !SB2->(DBSEEK(xFilial("SB2") + cCodPro + _cLocal ))
		CriaSB2( cCodPro, _cLocal)
	endif

    MSExecAuto({|x,y,z| MATA241(x,y,z)}, aCabecalho, aItens, nOper)
     
    If lMsErroAuto
        Mostraerro()
	else
		Aadd(aNumSeq, {SD3->D3_NUMSEQ, SD3->D3_DOC})

    EndIf    

    restArea(_aAreas)

Return(aNumSeq)  

User Function ACHK006P() 
	Local oButton1
	Local oButton2
	Local oGet1
	Local cGet1 := Space(60)
	Local oSay1
	Static oDlg

	DEFINE MSDIALOG oDlg TITLE "Pesquisa" FROM 000, 000  TO 110, 360 COLORS 0, 16777215 PIXEL
		@ 010, 004 SAY oSay1 PROMPT "Pesquisa Descricao Produto:" SIZE 091, 007 OF oDlg COLORS 0, 16777215 PIXEL
		@ 019, 004 MSGET oGet1 VAR cGet1 SIZE 172, 010 OF oDlg COLORS 0, 16777215 PIXEL

		@ 040, 097 BUTTON oButton2 PROMPT "Pesquisar" SIZE 037, 012 OF oDlg  PIXEL  Action (Processa({|| ExecFiltro(Alltrim(cGet1)) }, "Processando...") , Odlg:End() )  //ACTION (ExecFiltro(Alltrim(cGet1))) PIXEL
		@ 040, 140 BUTTON oButton1 PROMPT "Fechar"    SIZE 037, 012 OF oDlg  PIXEL  Action (Odlg:End())	
	ACTIVATE MSDIALOG oDlg CENTERED

Return()

Static Function ExecFiltro(cPesquisa)

	Local nX := 0
	oModel 		:= FWModelActive()    
	oModelZCA 	:= oModel:GetModel('ZCA_MASTER')            
	//oModelZCB 	:= oModel:GetModel('ZCB_MODEL')
	//oModelZD6     := oModel:GetModel('ZD6_MODEL')
	oMdlZCB     := oModel:GetModel('ZCB_MODEL')
	
	oView  		:= FwViewActive()
	nOper		:= oModelZCA:GetOperation()

	nLinAtu := oMdlZCB:GetLine()

	For nX := 1 To oMdlZCB:Length()

		// posiciono em cada na linha
		oMdlZCB:Goline(nX)
		cCodProd := oMdlZCB:GetValue("ZCB_COD")
		cDescri  := Posicione("SB1",1,xFilial("SB1")+cCodProd,"B1_DESC")
		
		if Alltrim(cPesquisa) $ Alltrim(cDescri) 
			oMdlZCB:Goline(nX)
			Return()
		EndIf

	Next nX

	oMdlZCB:Goline(nLinAtu)

Return()


//IIF(!EMPTY(ZCB->ZCB_COD).AND.(ZCB->ZCB_QTDENT=ZCB->ZCB_QTTDEV),"BR_VERDE","BR_VERMELHO")                                        
//IIF(!EMPTY(ZCB->ZCB_COD).AND.(ZCB->ZCB_QTDENT=ZCB->ZCB_QTTDEV),"BR_VERMELHO","BR_VERDE")                                        
