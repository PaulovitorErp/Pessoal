#INCLUDE "MNTA735.CH"
#INCLUDE "PROTHEUS.CH"
#Include 'FWMVCDEF.CH'

Static lRel12133 := GetRPORelease() >= '12.1.033'

//------------------------------------------------------------------------------
/*/{Protheus.doc} MNTA735
Programa de Geracao de Check List

@author Guilherme Freudenburg
@since 16/03/2018
@version P12

@return Nil
/*/
//------------------------------------------------------------------------------
Function MNTA735()

	Local aArea := GetArea() // Salva area posicionada.
	Local oBrowse // Objeto para montagem do browser.

	If !FindFunction( 'MNTAmIIn' ) .Or. MNTAmIIn( 19, 95 )

		Private aRotina := MenuDef()

		If ( FindFunction('U_MNTA7352') .Or. FindFunction('U_MNTA7351') .Or. FindFunction('U_MNTA7358') .Or. FindFunction('U_MNTA7356') .Or.;
			FindFunction('U_MNTA7355') ) .And. !FindFunction('U_MNTA735')
			MsgInfo(STR0045,STR0046) //'Os ponto de entrada "MNTA7351, MNTA7352, MNTA7355, MNTA7356 e MNTA7358" devem ser alterados conforme o novo modelo. Favor pesquisar a ISSUE MNG-6615 no TDN.'##'PONTO DE ENTRADA'
		EndIf

		// Instânciando FWMBrowse - Somente com dicionário de dados
		oBrowse := FWMBrowse():New()
		   
		// Setando a tabela de cadastro de Check - List
		oBrowse:SetAlias('TTF')

		// Nome do fonte onde esta a função MenuDef
		oBrowse:SetMenuDef( "MNTA735" )
		 
		// Setando a descrição da rotina
		oBrowse:SetDescription(STR0048) // Check List
		    
		// Ativa a Browse
		oBrowse:Activate()

	EndIf

	RestArea(aArea)

Return Nil
 
//------------------------------------------------------------------------------
/*/{Protheus.doc} MenuDef
Utilizacao de menu Funcional

@obs Parametros do array a Rotina:
	1. Nome a aparecer no cabecalho
	2. Nome da Rotina associada
	3. Reservado
	4. Tipo de Transação a ser efetuada:
		1 - Pesquisa e Posiciona em um Banco de Dados
		2 - Simplesmente Mostra os Campos
		3 - Inclui registros no Bancos de Dados
		4 - Altera o registro corrente
		5 - Remove o registro corrente do Banco de Dados
	5. Nivel de acesso
	6. Habilita Menu Funcional

@author Vitor Emanuel Batista
@since 10/11/2008
@version P12

@return aMenu, Array, Contêm as opções do menu.
/*/
//------------------------------------------------------------------------------
Static Function MenuDef()

	Local aMenu := {}
	Local aRet  := {}

	ADD OPTION aMenu Title STR0029 Action 'AxPesqui'		OPERATION 1 ACCESS 0 // 'Pesquisar'
	ADD OPTION aMenu Title STR0030 Action 'MNTA735COM(1)'   OPERATION 2 ACCESS 0 // 'Visualizar'
	ADD OPTION aMenu Title STR0031 Action 'VIEWDEF.MNTA735' OPERATION 3 ACCESS 0 // 'Incluir'
	ADD OPTION aMenu Title STR0033 Action 'MNTA735COM(5)'   OPERATION 5 ACCESS 0 // 'Excluir'

	// P.E. que permite a inclusão ou remoção de opções do menu funcional.
	If ExistBlock( 'MNTA7350' )

		aRet := ExecBlock( 'MNTA7350', .F., .F., { aMenu } )

		If ValType( aRet ) == 'A'

			aMenu := aClone( aRet )

		EndIf

	EndIf

Return aMenu
 
//------------------------------------------------------------------------------
/*/{Protheus.doc} ModelDef
Definição do Modelo (padrão MVC).

@author Guilherme Freudenburg
@since 16/03/2018
@version P12

@return oModel, Objeto, Modelo de dados.
/*/
//------------------------------------------------------------------------------
Static Function ModelDef()

	Local oModel    := Nil
	Local oStrucTTF := FWFormStruct(1,'TTF') // Estrutura da tabela TTF
	Local oStrucTTG := FWFormStruct(1,'TTG') // Estrutura da tabela TTG (Grid)

	// Cria campo para controlar Tipo Modelo do Checklist Padrão selecionado
	If lRel12133
		oStrucTTF:AddField('Mod. Padrão.','Modelo Checklist Padrão','TMCHKPAD','C',;
			oStrucTTF:GetProperty('TTF_TIPMOD', MODEL_FIELD_TAMANHO),;
			oStrucTTF:GetProperty('TTF_TIPMOD', MODEL_FIELD_DECIMAL),,,,,,.F.,.T.,.T.)
	EndIf

	// Adiciona o campo de Problema, para marcação das etapas.
	If !IsInCallStack("MNTA735COM")
		oStrucTTG:AddField(STR0038,STR0038,'TTD_TIPMOD','C',1,0,Nil,{|| MNT735OK()},{},.F.,,.T.,.F.,.F.)
	EndIf

	// Retira campos do modelo
	If !NGVERUTFR() // Retira campo da tela caso não utilize o Frotas.
		oStrucTTF:RemoveField('TTF_PLACA')
	EndIf

	// Ponto de Entrada MNTA7357 com o objetido de adicionar campos na estrutura.
	If ExistBlock("MNTA7357")
		ExecBlock("MNTA7357",.F.,.F.,{.T.,@oStrucTTG})
	EndIf

	// Criando o modelo e os relacionamentos
	oModel := MPFormModel():New('MNTA735',/*bPre*/,{ | oModel | fCheckDel() .And. fCheckTudo() }/*bPost*/,{ | oModel | fGrava() }/*bCommit*/,/*bCancel*/ )

	oModel:AddFields('TTFMASTER',/*cOwner*/,oStrucTTF)
	oModel:AddGrid('TTGDETAIL','TTFMASTER',oStrucTTG,/*bLinePre*/,{ | oModel | fLinOk() }/*bLinePost*/,/*bPre*/,/*bPos*/,/*bLoad*/)

	// Determina que o preenchimento da Grid não é obrigatório.
	oModel:GetModel('TTGDETAIL'):SetOptional(.T.) // CID complementar para Atestado.

	// Cria relacionamento entre a tabela TTF e TTG
	oModel:SetRelation('TTGDETAIL',{{'TTG_FILIAL','xFilial("TTG")'},{'TTG_CHECK','TTF_CHECK'}},TTG->(IndexKey(1))) // Faz relaciomaneto entre os compomentes do model
	oModel:GetModel('TTGDETAIL'):SetUniqueLine({"TTG_ETAPA"}) // Não repetir informações ou combinações
	oModel:SetPrimaryKey({})
	  
	// Setando as descrições
	oModel:SetDescription(STR0001) // 'Check List'
	oModel:GetModel('TTFMASTER'):SetDescription(STR0001) // 'Check List'
	oModel:GetModel('TTGDETAIL'):SetDescription(STR0002) // 'Etapas'

Return oModel

//------------------------------------------------------------------------------
/*/{Protheus.doc} ViewDef
Definição do View (padrão MVC).

@author Guilherme Freudenburg
@since 16/03/2018
@version P12

@return oView, Objeto, Retorna o oView utilizado.
/*/
//------------------------------------------------------------------------------
Static Function ViewDef()

	Local oView     := Nil
	Local oModel    := FWLoadModel('MNTA735')
	Local oStrucTTF := FWFormStruct(2,'TTF')
	Local oStrucTTG := FWFormStruct(2,'TTG')
	    
	// Criando a View
	oView := FWFormView():New()
	oView:SetModel(oModel)

	// Adicionando o campo Problema para ser exibido
	If !IsInCallStack("MNTA735COM") 
		oStrucTTG:AddField("TTD_TIPMOD","01",STR0038,STR0038,Nil,"C","@!",Nil,Nil,.T.,Nil,Nil,Nil,Nil,Nil,Nil,Nil,Nil)                        
	EndIf

	// Ponto de Entrada MNTA7357 com o objetido de adicionar campos na estrutura.
	If ExistBlock("MNTA7357")
		ExecBlock("MNTA7357",.F.,.F.,{.F.,@oStrucTTG})
	EndIf
	  
	// Adicionando os campos do cabeçalho e o grid dos filhos
	oView:AddField('VIEW_TTF',oStrucTTF,'TTFMASTER')
	oView:AddGrid('VIEW_TTG',oStrucTTG,'TTGDETAIL')
	    
	// Setando o dimensionamento de tamanho
	oView:CreateHorizontalBox('CABEC',50)
	oView:CreateHorizontalBox('GRID',50)
	     
	// Amarrando a view com as box
	oView:SetOwnerView('VIEW_TTF','CABEC')
	oView:SetOwnerView('VIEW_TTG','GRID')
	  
	// Habilitando título
	oView:EnableTitleView('VIEW_TTF',STR0001)// "Check List"
	oView:EnableTitleView('VIEW_TTG','Etapas')
	   
	// Retira campos do view
	oStrucTTG:RemoveField("TTG_CHECK")   
	If !IsInCallStack("MNTA735COM") 
		oStrucTTG:RemoveField("TTG_EVENTO") 
		oStrucTTG:RemoveField("TTG_NUMERO") 
		oStrucTTG:RemoveField("TTG_SERVIC") 
	Endif
	 
	If !NGVERUTFR() // Retira campo da tela caso não utilize o Frotas.
		oStrucTTF:RemoveField("TTF_PLACA")  
	EndIf

	// Força o fechamento da janela na confirmação  
	oView:SetCloseOnOk({||.T.})

	//Inclusão de itens nas Ações Relacionadas de acordo com O NGRightClick
	NGMVCUserBtn(oView)
	     
Return oView


//------------------------------------------------------------------------------
/*/{Protheus.doc} MNT735OK
Marca uma etapa do check list

@author Vitor Emanuel Batista
@since 12/11/2008
@version P12

@return lRet, Lógico, Retorna .T. para liberar o campo e .F. para travar.
/*/
//------------------------------------------------------------------------------
Function MNT735OK()

	Local lRet  := .T.
	Local oModel
	Local oGrid
	Local oView
	Local nOperat

	If IsInCallStack( 'MNTA735' )
		oModel := FWModelActive()  // Copia o Model utilizado.
		oGrid  := oModel:GetModel( 'TTGDETAIL' ) // Posiciona no Model da Grid
		oView  := FWViewActive() // Ativação do View.
		nOperat  := oModel:GetOperation()

		If nOperat == MODEL_OPERATION_INSERT
			If !Empty(oGrid:GetValue('TTG_ETAPA'))
				If !Empty(oGrid:GetValue('TTD_TIPMOD')) // Verifica se campo está preenchido.
					oGrid:LoadValue('TTG_CRITIC','')
					oGrid:LoadValue('TTD_TIPMOD','')
				Else
					oGrid:LoadValue('TTD_TIPMOD', 'X') // Faz a marcação do campo.
				EndIf
			EndIf
			If ValType(oView) == 'O'
				oView:Refresh() // Atualiza a tela.
			EndIf
			lRet := .F.
		EndIf
	EndIf

Return lRet

//------------------------------------------------------------------------------
/*/{Protheus.doc} MNT735FUNC
Valida campo Executante

@author Vitor Emanuel Batista
@since 12/11/2008
@version P12

@return lRet, Lógico, Retorna .T. caso as condições estejam corretas.
/*/
//------------------------------------------------------------------------------
Function MNT735FUNC()

	Local lRet   := .T.
	Local oModel := FWModelActive()

	If !ExistCpo('ST1',oModel:GetValue("TTFMASTER","TTF_CODFUN"))
		Help(" ",1,"REGNOIS")
		lRet := .F.
	EndIf

Return lRet

//------------------------------------------------------------------------------
/*/{Protheus.doc} MNT735BEM
Valida campo Frota

@author Vitor Emanuel Batista
@since 12/11/2008
@version P12

@return lRet, Lógico, Retorna .T. caso as condições estejam corretas.
/*/
//------------------------------------------------------------------------------
Function MNT735BEM(cCODBEM)

	Local oModel  := FWModelActive() // Copia o Model utilizado.
	Local cCodB   := oModel:GetValue('TTFMASTER', 'TTF_CODBEM')
	Local lRet    := .T.
	Local nNomBem := TAMSX3('TTF_NOMBEM')[1]
	Local nNomFam := TAMSX3('TTF_NOMFAM')[1]
	Local nDesMod := TAMSX3('TTF_DESMOD')[1]
	Local nPlaca  := TAMSX3('TTF_PLACA')[1]

	oModel:LoadValue('TTFMASTER', 'TTF_CODBEM', cCODBEM)
	oModel:LoadValue('TTFMASTER', 'TTF_POSCON', IIF(!FindFunction("NGBlCont") .Or.;
												NGBlCont( cCodB ), 0 ,NGTpCont(cCodB,;
												oModel:GetValue('TTFMASTER', 'TTF_DATA'), oModel:GetValue('TTFMASTER', 'TTF_HORA'))))

	// Limpa Tipo Modelo do Checklist Padrão
	If lRel12133
		oModel:ClearField('TTFMASTER','TMCHKPAD')
	EndIf

	If !Empty( cCodB )
		dbSelectArea("ST9")
		dbSetOrder(1)
		If !dbSeek(xFilial("ST9")+cCodB)
			Help(" ",1,"REGNOIS")
			lRet := .F.
		ElseIf ST9->T9_SITBEM == 'I' //Caso o bem esteja inativo, não permite seguir no processo.
			lRet := .F.
			Help("", 1, "INATIVO", "", STR0047, 1, 0,,,,,"")
		EndIf

		If lRet
			oModel:LoadValue("TTFMASTER","TTF_CODFAM",ST9->T9_CODFAMI)
			oModel:LoadValue("TTFMASTER","TTF_TIPMOD",ST9->T9_TIPMOD)
			oModel:LoadValue("TTFMASTER","TTF_NOMBEM",SubStr(NGSEEK("ST9",M->TTF_CODBEM,1,"ST9->T9_NOME"),1,nNomBem))
			oModel:LoadValue("TTFMASTER","TTF_NOMFAM",SubStr(NGSEEK("ST6",M->TTF_CODFAM,1,"ST6->T6_NOME"),1,nNomFam))
			oModel:LoadValue("TTFMASTER","TTF_DESMOD",SubStr(NGSEEK("TQR",M->TTF_TIPMOD,1,"TQR->TQR_DESMOD"),1,nDesMod))
			oModel:LoadValue('TTFMASTER','TTF_POSCO2',0)

			If NGVERUTFR()
				If !Empty(ST9->T9_PLACA)
					oModel:LoadValue('TTFMASTER','TTF_PLACA',SubStr(ST9->T9_PLACA,1,nPlaca))
				Else
					oModel:LoadValue('TTFMASTER','TTF_PLACA',Space(nPlaca))
				EndIf
			EndIf

			// Limpa campo de sequencia
			oModel:ClearField('TTFMASTER','TTF_SEQFAM')

			// Monta Check-List para preenchimento.
			MNT735LIST(oModel:GetValue('TTFMASTER','TTF_CODFAM'),oModel:GetValue('TTFMASTER','TTF_TIPMOD'))

		EndIf
	EndIf

Return lRet

//------------------------------------------------------------------------------
/*/{Protheus.doc} MNT735LIST
Monta detalhes do Check List

@author Vitor Emanuel Batista
@since 12/11/2008
@version P12

@return Sempre verdadeiro.
/*/
//------------------------------------------------------------------------------
Static Function MNT735LIST(cCodFam,cTipMod,cSeqFam)

	Local lMNTA735A	:= ExistBlock("MNTA735A")
	Local oModel    := FWModelActive()  // Copia o Model utilizado.
	Local oGrid     := oModel:GetModel('TTGDETAIL') // Posiciona no Model da Grid
	Local cCheck	:= oModel:GetValue('TTFMASTER','TTF_CHECK')
	Local nItens    := 1
	Local nNomeTa   := TAMSX3('TTG_NOMETA')[1]

	Default cSeqFam := ''

	oGrid:ClearData(.T.,.T.) //Limpa a grid, quando ocorreu a troca de bem.

	If fSeekPad( cCodFam, cTipMod, cSeqFam )

		// Atualiza com a sequencia encontrada
		If cSeqFam != TTE->TTE_SEQFAM
			oModel:LoadValue('TTFMASTER', 'TTF_SEQFAM', TTE->TTE_SEQFAM)
		EndIf

		cTipMod := TTE->TTE_TIPMOD
		cSeqFam := TTE->TTE_SEQFAM
		
		If lRel12133
			oModel:LoadValue('TTFMASTER', 'TMCHKPAD', cTipMod) // Atualiza Tipo Modelo do Checklist Padrão encontrado
		EndIf

		While !Eof() .And. TTE->TTE_FILIAL+TTE->TTE_CODFAM+TTE->TTE_TIPMOD+TTE->TTE_SEQFAM == xFilial('TTE') + cCodFam + cTipMod + cSeqFam
			If nItens > 1
				oGrid:AddLine()
				oGrid:GoLine(nItens)
			EndIf
			oGrid:LoadValue('TTD_TIPMOD',Space(1))
			oGrid:LoadValue('TTG_ETAPA',TTE->TTE_ETAPA)
			oGrid:LoadValue('TTG_NOMETA',SubStr(NGSEEK("TPA",TTE->TTE_ETAPA,1,"TPA->TPA_DESCRI"),1,nNomeTa))
			oGrid:LoadValue('TTG_CRITIC','')
			oGrid:LoadValue('TTG_CHECK', cCheck)
			nItens++
			dbSelectArea("TTE")
			dbSkip()
		End

		/*---------------------------------------------------------------
		| PE para gatilhar informações para campo de usuario na TTG		|
		----------------------------------------------------------------*/
		If lMNTA735A
			ExecBlock("MNTA735A",.F.,.F.,{oGrid})
		EndIf

	Else
		oGrid:LoadValue('TTD_TIPMOD',Space(1))
		oGrid:LoadValue('TTG_ETAPA' ,'')
		oGrid:LoadValue('TTG_NOMETA','')
		oGrid:LoadValue('TTG_CRITIC','')

	EndIf

	If nItens > 1 // Caso seja adicionado alguma Etapa.
		oGrid:GoLine(1) // Posiciona na primeira linha da Grid.
	EndIf

Return .T.

//------------------------------------------------------------------------------
/*/{Protheus.doc} MNT735FSEQ
Funcao para carregar as sequencias na Consulta Padrão.

@author Bruno Souza
@since 27/03/12
@version P12

@return lRet, Lógico, Retorna verdadeiro mediante as condições de validação.
/*/
//------------------------------------------------------------------------------
Function MNT735FSEQ()

	Local lRet   := .F.
	Local oModel := FWModelActive()
	Local cCodFa := oModel:GetValue('TTFMASTER','TTF_CODFAM')
	Local cTipoM := oModel:GetValue('TTFMASTER','TTF_TIPMOD')

	If (TTD->TTD_CODFAM == cCodFa .And. TTD->TTD_TIPMOD == cTipoM) .Or.;
	   (TTD->TTD_CODFAM == cCodFa .And. Empty(TTD->TTD_TIPMOD))
		lRet := .T.
	EndIf

Return lRet

//------------------------------------------------------------------------------
/*/{Protheus.doc} MNT735SEQ
Funcao para validar campo sequencia.

@author Bruno Souza
@since 27/03/12
@version P12

@return lRet, Lógico, Retorna verdadeiro caso registro exista.
/*/
//------------------------------------------------------------------------------
Function MNT735SEQ()

	Local lRet    := .T.
	Local oModel  := FWModelActive()
	Local cSeqF   := oModel:GetValue('TTFMASTER','TTF_SEQFAM')
	Local cCodF   := oModel:GetValue('TTFMASTER','TTF_CODFAM')
	Local cTipM   := IIf( lRel12133, oModel:GetValue('TTFMASTER','TMCHKPAD'), oModel:GetValue('TTFMASTER','TTF_TIPMOD') )

	If !Empty(cCodF) .And. !Empty(cTipM) .And. !Empty(cSeqF) .And. ;
		!fSeekPad( cCodF, cTipM, cSeqF, , 'TTD', 1 )
		lRet := .F.
	EndIf
	
	If lRet
		MNT735LIST(cCodF,cTipM,cSeqF)
	EndIf

Return lRet

//------------------------------------------------------------------------------
/*/{Protheus.doc} fGrava
Grava dados nas tabelas TTF e TTG

@author Vitor Emanuel Batista
@since 12/11/2008
@version P12

@return Array.
		aTypeRet[1], Array	, Grava ou não (conteúdo Lógico).
/*/
//------------------------------------------------------------------------------
Static Function fGrava()

	Local oModel   := FWModelActive()
	Local oGrid    := oModel:GetModel('TTGDETAIL') // Posiciona no Model da Grid
	Local cEtapa   := ''
	Local cCriti   := ''
	Local cEvento  := ''
	Local cServico := ''
	Local cSeek    := ''
	Local cGeraPrev:= AllTrim(GETMv('MV_NGGERPR'))
	Local cHora    := oModel:GetValue('TTFMASTER','TTF_HORA')
	Local cCodB    := oModel:GetValue('TTFMASTER','TTF_CODBEM')
	Local lCont1   := (Posicione("ST9", 1, xFilial("ST9") + cCodB, 'T9_TEMCONT') == 'S')
	Local lCont2   := MNT735TPE(cCodB)
	Local nLenGrid := oGrid:Length() // Quantidade Total de linhas do oGrid.
	Local nOperat  := oModel:GetOperation()
	Local nCont1   := oModel:GetValue('TTFMASTER','TTF_POSCON')
	Local nCont2   := oModel:GetValue('TTFMASTER','TTF_POSCO2')
	Local nX       := 0
	Local nZ       := 0
	Local dDtTTF   := oModel:GetValue('TTFMASTER','TTF_DATA')
	Local aOS      := {}
	Local aSS      := {}
	Local lMostraMsg := IIf(IsInCallStack("MNTA735"),.T.,.F.)
	Local aTypeRet := {.T.,''}
	Local cTipoMod := ''

	Private cMVOBS  := GetMV("MV_NGOBCHK")

	Begin Transaction

		If nOperat == MODEL_OPERATION_DELETE // Exclusão

			// Exclui o lancamento de contador relacionado ao bem do Contador 1
			If !Empty(TTF->TTF_HORA) .And. TTF->TTF_POSCON > 0
				MNT470EXCO(TTF->TTF_CODBEM,TTF->TTF_DATA,TTF->TTF_HORA,1)
			EndIf

			// Exclui o lancamento de contador relacionado ao bem do Contador 2
			If !Empty(TTF->TTF_HORA) .And. TTF->TTF_POSCO2 > 0
				MNT470EXCO(TTF->TTF_CODBEM,TTF->TTF_DATA,TTF->TTF_HORA,2)
			EndIf

			//-----------------------------
			// Efetiva a operacao desejada
			//-----------------------------
			FWFormCommit( oModel )

		Else
		
			cTipoMod := IIf( lRel12133, 'TMCHKPAD', 'TTF_TIPMOD' )
			
			cSeek :=  oModel:GetValue('TTFMASTER', 'TTF_CODFAM') + ;
                      oModel:GetValue('TTFMASTER', cTipoMod  ) + ;
                      oModel:GetValue('TTFMASTER', 'TTF_SEQFAM')

			oModel:LoadValue("TTFMASTER","TTF_POSCON",If(lCONT1,IIF(!FindFunction("NGBlCont") .Or. NGBlCont( cCodB ),nCont1,;
														NGTpCont(cCodB, dDtTTF,;
														cHora, nCont1)),0))
			oModel:LoadValue("TTFMASTER","TTF_POSCO2",If(lCONT2,nCont2,0))

			For nZ := 1 To nLenGrid // Percorre todos os dados da Grid.
				oGrid:GoLine(nZ) // Posiciona na linha desejada.
				If !Empty(oGrid:GetValue("TTD_TIPMOD")) .And. !( oGrid:IsDeleted() ) // Veririfica se registro foi preenchido e não está delatado.

					oGrid:LoadValue("TTG_CHECK", oModel:GetValue('TTFMASTER','TTF_CHECK'))

					cEtapa 		:= oGrid:GetValue("TTG_ETAPA")
					cCriti 		:= oGrid:GetValue("TTG_CRITIC")
					cEvento 	:= ""
					cServico	:= ""
					dbSelectArea("TTE")
					dbSetOrder(3)
					If dbSeek(xFilial("TTE") + cSeek + cEtapa)

						If cCriti == 'A'  // CRITICIDADE ALTA
							cEvento := TTE->TTE_ALTA
							If TTE->TTE_ALTA == 'O' // GERA O.S
								cServico := TTE->TTE_SERVIC
							EndIf
						ElseIf cCriti == 'M' // CRITICIDADE MEDIA
							cEvento := TTE->TTE_MEDIA
							If TTE->TTE_MEDIA == 'O' // GERA O.S
								cServico := TTE->TTE_SERVIC
							EndIf
						ElseIf cCriti == 'B'// CRITICIDADE BAIXA
							cEvento := TTE->TTE_BAIXA
							If TTE->TTE_BAIXA == 'O' // GERA O.S
								cServico := TTE->TTE_SERVIC
							EndIf
						EndIf
						oGrid:LoadValue("TTG_EVENTO", cEvento)
						oGrid:LoadValue("TTG_SERVIC", cServico)
					Endif
				Else
					oGrid:DeleteLine() // Apaga a linha que não foi marcada.
				EndIf
			Next nZ

			For nX := 1 to nLenGrid
				oGrid:GoLine(nX)
				If oGrid:GetValue("TTG_EVENTO") == 'S' // Gerar S.S
					aAdd(aSS,{oGrid:GetValue("TTG_ETAPA"),oGrid:GetValue("TTG_CRITIC")})
				ElseIf oGrid:GetValue("TTG_EVENTO") == 'O' // Gerar O.S
					If (nPos := aSCAN(aOS, {|x| x[1] == oGrid:GetValue("TTG_SERVIC")}) ) > 0
						aAdd(aOS[nPos],oGrid:GetValue("TTG_ETAPA"))
					Else
						aAdd(aOS,{oGrid:GetValue("TTG_SERVIC"),oGrid:GetValue("TTG_ETAPA")})
					EndIf
				EndIf
			Next nX

			// Gera Solicitacao de Servico
			Processa({ |lEnd| aTypeRet := MNTA735SS(aSS) }, STR0040 ) // "Aguarde ..Gerando Ordem de Serviço Corretiva.."

			If aTypeRet[1]
				// Ponto de entrada para adicionar valores na TTG.
				If ExistBlock('MNTA735')
					ExecBlock('MNTA735',.F.,.F.,{oModel,'FORMCOMMITTTSPRE',oModel:cId,@oGrid})
				EndIf

				// Efetiva a operacao desejada
				FWFormCommit( oModel )

				// Gera Ordem de Servico Corretiva
				Processa({ |lEnd| MNTA735OS(aOS) }, STR0039 ) // "Aguarde ..Gerando Ordem de Serviço Corretiva.."

				//Adicionar o número da SS
				For nX := 1 to Len(aSS)
					IncProc()
					dbSelectArea("TTG")
					dbSetOrder(1) //TTG_FILIAL+TTG_CHECK+TTG_ETAPA
					If dbSeek(xFilial("TTG")+oModel:GetValue('TTFMASTER','TTF_CHECK')+aSS[nX][1])
						RecLock("TTG",.F.)
						TTG->TTG_NUMERO := aSS[nX][3]
						TTG->(MsUnLock())
					EndIf
				Next nX

				// Ponto de entrada para adicionar dados na tabela TTF e gravação em outras tabelas.
				If ExistBlock('MNTA735')
					ExecBlock('MNTA735',.F.,.F.,{oModel,'FORMCOMMITTTSPOS',oModel:cId})
				EndIf

				// Atualiza contadores
				If lCont1 .And. !Empty(nCont1)
					NGTRETCON(cCodB,dDtTTF,;
					nCont1,cHora,1,,.T.)
					// GERAR O.S AUTOMATICA POR CONTADOR
					If (cGeraPrev = "S" .Or. cGeraPrev = "C")
						If lMostraMsg
							If NGCONFOSAUT(cGeraPrev)
								NGGEROSAUT(cCodB,nCont1)
							EndIf
						Else
							NGGEROSAUT(cCodB,nCont1)
						EndIf
					EndIf
				EndIf

				If lCont2 .And. !Empty(nCont2)
					NGTRETCON(cCodB,dDtTTF,;
					nCont2,cHora,2,,.T.)
					// GERAR O.S AUTOMATICA POR CONTADOR
					If (cGeraPrev = "S" .Or. cGeraPrev = "C")
						If lMostraMsg
							If NGCONFOSAUT(cGeraPrev)
								NGGEROSAUT(cCodB,nCont2)
							EndIf
						Else
							NGGEROSAUT(cCodB,nCont2)
						EndIf
					EndIf
				EndIf
			Else
				//Volta o registro em caso de inconsistência
				RollbackSx8()
				DisarmTransaction()

				oModel:SetErrorMessage('MNTA735',/**/,/**/,/**/,STR0020,aTypeRet[2]) //"Atenção"
			EndIf

		EndIf

	End Transaction

Return aTypeRet[1]

//------------------------------------------------------------------------------
/*/{Protheus.doc} MNT735RAMAL
Verifica se ramal devera ser informado

@author Vitor Emanuel Batista
@since 06/01/2009
@version P12

@return Sempre verdadeiro.
/*/
//------------------------------------------------------------------------------
Function MNT735RAMAL()

	Local nX      := 0
	Local lSS     := .F.
	Local lRet 	  := .T.
	Local oModel  := FWModelActive()
	Local oGrid   := oModel:GetModel( 'TTGDETAIL' ) //Posiciona no Model da Grid
	Local nLenGrid:= oGrid:Length()
	Local cTipoMod := IIf( lRel12133, 'TMCHKPAD', 'TTF_TIPMOD' )
	
	If Empty(oModel:GetValue('TTFMASTER','TTF_RAMAL')) .And. X3OBRIGAT("TQB_RAMAL")
		For nX := 1 to nLenGrid
			oGrid:GoLine(nX)
			If !Empty(oGrid:GetValue("TTD_TIPMOD")) .And. lRet
				dbSelectArea("TTE")
				dbSetOrder(3)
				dbSeek( xFilial("TTE") + ;
				        oModel:GetValue('TTFMASTER','TTF_CODFAM') + ;
						oModel:GetValue('TTFMASTER', cTipoMod )   + ;
						oModel:GetValue('TTFMASTER','TTF_SEQFAM') + ;
						oGrid:GetValue("TTG_ETAPA"))

				If oGrid:GetValue("TTG_CRITIC") == 'A'
					lSS := If(TTE->TTE_ALTA == 'S',.T.,.F.)
				ElseIf oGrid:GetValue("TTG_CRITIC") == 'M'
					lSS := If(TTE->TTE_MEDIA == 'S',.T.,.F.)
				ElseIf oGrid:GetValue("TTG_CRITIC") == 'B'
					lSS := If(TTE->TTE_BAIXA == 'S',.T.,.F.)
				EndIf

				If lSS
					Help(Nil, Nil, STR0020, Nil, STR0024, 1, 0)// "Deverá ser preenchido o Ramal, quando existir criticidade que Gere SS"
					lRet := .F.
				EndIf
			EndIf
		Next nX
	EndIf

Return lRet

//------------------------------------------------------------------------------
/*/{Protheus.doc} fCheckDel
Verifica se existe SS ou OS para o check-list selecionado

@author Vitor Emanuel Batista
@since 06/01/2009
@version P12

@return lDel, Lógica, Verifica se registro poderá ser excluido.
/*/
//------------------------------------------------------------------------------
Static Function fCheckDel()

	Local lDel       := .T.
	Local oModel     := FWModelActive()
	Local nOperation := oModel:GetOperation()

	If nOperation == MODEL_OPERATION_DELETE // Exclusão

		dbSelectArea("TTG")
		dbSetOrder(1)
		dbSeek(xFilial("TTG")+TTF->TTF_CHECK)
		While !Eof() .And. xFilial("TTG") == TTG->TTG_FILIAL .And. TTG->TTG_CHECK == TTF->TTF_CHECK

			If TTG->TTG_EVENTO == 'O'
				dbSelectArea("STJ")
				dbSetOrder(1)
				If dbSeek(xFilial("STJ")+TTG->TTG_NUMERO)
					If STJ->TJ_SITUACA <> "C"
						lDel := .F.
						Exit
					EndIf
				EndIf
			ElseIf TTG->TTG_EVENTO == 'S'
				dbSelectArea("TQB")
				dbSetOrder(1)
				If dbSeek(xFilial("TQB")+TTG->TTG_NUMERO)
					If TQB->TQB_SOLUCA <> "C"
						lDel := .F.
						Exit
					EndIf
				EndIf
			EndIf

			dbSelectArea("TTG")
			dbSkip()
		End

		If !lDel
			Help(Nil, Nil, STR0020, Nil, STR0034, 1, 0)// "Existem O.S e/ou S.S gerados para este Check-List"
		EndIf
	EndIf

Return lDel

//------------------------------------------------------------------------------
/*/{Protheus.doc} fCheckTudo
Verifica se todos os dados estao OK para inclusao

@author Vitor Emanuel Batista
@since 12/11/2008
@version P12

@return lRet, Lógico, Retorna .T. quando verificação estiver correta.
/*/
//------------------------------------------------------------------------------
Static Function fCheckTudo()

	Local lRet       := .T.
	Local oModel     := FWModelActive()
	Local cCodB      := oModel:GetValue('TTFMASTER','TTF_CODBEM')
	Local cHora      := oModel:GetValue('TTFMASTER','TTF_HORA')
	Local lCont1     := (Posicione("ST9", 1, xFilial("ST9") + cCodB, 'T9_TEMCONT') == 'S')
	Local lCont2     := MNT735TPE(cCodB)
	Local nCont1     := oModel:GetValue('TTFMASTER','TTF_POSCON')
	Local nCont2     := oModel:GetValue('TTFMASTER','TTF_POSCO2')
	Local dData      := oModel:GetValue('TTFMASTER','TTF_DATA')
	Local nOperation := oModel:GetOperation()
	Local aMsgCHKH   := {}
	Local aMsgValid  := {}
	Local lIsBlind   := IsBlind()
	Local xValid
	Local cTipoMod := IIf( lRel12133, 'TMCHKPAD', 'TTF_TIPMOD' )

	If nOperation == MODEL_OPERATION_INSERT
		dbSelectArea("TTD")
		dbSetOrder(1)
		If !dbSeek( xFilial("TTD") + ;
		            oModel:GetValue('TTFMASTER','TTF_CODFAM') + ;
					oModel:GetValue('TTFMASTER', cTipoMod   ) + ;
					oModel:GetValue('TTFMASTER','TTF_SEQFAM'))
			oModel:SetErrorMessage('MNTA735',/**/,/**/,/**/,/**/,STR0028)
			lRet := .F.
		EndIf

		//Valida primeiro contador
		If lCont1 .And. !Empty(nCont1) .And. lRet

			aMsgCHKH := NGCHKHISTO(cCodB,dData, nCont1,cHora,1,,.F.)
			If !aMsgCHKH[1]
				lRet := .F.
				oModel:SetErrorMessage('MNTA735',/**/,/**/,/**/,/**/,aMsgCHKH[2])
			EndIf

			If lRet
				xValid:= NGVALIVARD(cCodB,nCont1,dData,cHora,1,!lIsBlind)
				If ValType( xValid ) == "A"
					aMsgValid := aClone( xValid )
				Else
					aMsgValid := { xValid, "" }
				EndIf

				If !aMsgValid[1]
					lRet := .F.
					oModel:SetErrorMessage('MNTA735',/**/,/**/,/**/,/**/,aMsgValid[2])
				EndIf
			EndIf

		EndIf

		//Valida segundo contador contador
		If lCont2 .And. !Empty(nCont2) .And. lRet

			aMsgCHKH := NGCHKHISTO(cCodB,dData,nCont2,cHora,2,,.F.)
			If !aMsgCHKH[1]
				lRet := .F.
				oModel:SetErrorMessage('MNTA735',/**/,/**/,/**/,/**/,aMsgCHKH[2])
			EndIf

			If lRet
				xValid := NGVALIVARD(cCodB,nCont2,dData,cHora,2,!lIsBlind)

				If ValType( xValid ) == "A"
					aMsgValid := aClone( xValid )
				Else
					aMsgValid := { xValid, "" }
				EndIf

				If !aMsgValid[1]
					lRet := .F.
					oModel:SetErrorMessage('MNTA735',/**/,/**/,/**/,/**/,aMsgValid[2])
				EndIf
			EndIf

		EndIf
	EndIf

	// Ponto de entrada para validar os dados na tela.
	If lRet .And. ExistBlock('MNTA735')
		lRet := ExecBlock('MNTA735',.F.,.F.,{oModel,'MODELPOS',oModel:cId})
	EndIf

Return lRet

//------------------------------------------------------------------------------
/*/{Protheus.doc} fLinOk
Valida linha da Grid.

@author Vitor Emanuel Batista
@since 12/11/2008
@version P12

@return lRet, Lógico, Retorna .T. quando verificação estiver correta.
/*/
//------------------------------------------------------------------------------
Static Function fLinOk()

	Local lRet := .T.
	Local oModel  := FWModelActive()
	Local oGrid   := oModel:GetModel( 'TTGDETAIL' ) // Posiciona no Model da Grid
	Local oView   := FWViewActive() // Ativação do View.
	Local lOS     := .F.
	Local lSS     := .F.
	Local lER     := .F.
	Local cCodB   := oModel:GetValue('TTFMASTER','TTF_CODBEM')
	Local lMostraMsg := IIf(IsInCallStack("MNTA735"),.T.,.F.)
	Local cTipoMod := IIf( lRel12133, 'TMCHKPAD', 'TTF_TIPMOD' )

	If !Empty(oGrid:GetValue("TTG_CRITIC"))
		oGrid:LoadValue("TTD_TIPMOD", 'X')
	EndIf

	If !Empty(oGrid:GetValue("TTD_TIPMOD"))
		If Empty(oGrid:GetValue("TTG_CRITIC"))
			Help(Nil, Nil, STR0020, Nil, STR0023, 1, 0)// "Não foi informada a criticidade da Etapa"
			lRet := .F.
		EndIf

		dbSelectArea("TTE")
		dbSetOrder(3)
		dbSeek( xFilial("TTE") + ;
		        oModel:GetValue('TTFMASTER','TTF_CODFAM') + ;
		        oModel:GetValue('TTFMASTER', cTipoMod   ) + ;
				oModel:GetValue('TTFMASTER','TTF_SEQFAM') + ;
				oGrid:GetValue("TTG_ETAPA") )

		If oGrid:GetValue("TTG_CRITIC") == 'A'
			lOS := If(TTE->TTE_ALTA == 'O',.T.,.F.)
			lSS := If(TTE->TTE_ALTA == 'S',.T.,.F.)
			lER := If(Empty(TTE->TTE_ALTA),.T.,.F.)
		ElseIf oGrid:GetValue("TTG_CRITIC") == 'M'
			lOS := If(TTE->TTE_MEDIA == 'O',.T.,.F.)
			lSS := If(TTE->TTE_MEDIA == 'S',.T.,.F.)
			lER := If(Empty(TTE->TTE_MEDIA),.T.,.F.)
		ElseIf oGrid:GetValue("TTG_CRITIC") == 'B'
			lOS := If(TTE->TTE_BAIXA == 'O',.T.,.F.)
			lSS := If(TTE->TTE_BAIXA == 'S',.T.,.F.)
			lER := If(Empty(TTE->TTE_BAIXA),.T.,.F.)
		EndIf

		If lER
			Help(Nil, Nil, STR0037, Nil, STR0043, 1, 0)// "Não existe nenhum Evento para a criticidade informada!"
			oGrid:LoadValue("TTG_CRITIC",'')
			oGrid:LoadValue("TTD_TIPMOD",'')
			If ValType(oView) == 'O'
				oView:Refresh() // Atualiza a tela.
			EndIf
			lRet := .F.
		EndIf

		If lOS
			If !NGOSABRVEN(cCodB,TTE->TTE_SERVIC,.T.,.T.,.T.,,,lMostraMsg) .Or. ;
			!NGMNTOSCO('B',cCodB,TTE->TTE_SERVIC,oModel:GetValue('TTFMASTER','TTF_DATA'),'Val(STJ->TJ_PLANO) = 0')
				oGrid:LoadValue("TTG_CRITIC",'')
				oGrid:LoadValue("TTD_TIPMOD",'')
				If ValType(oView) == 'O'
					oView:Refresh() // Atualiza a tela.
				EndIf
				lRet := .F.
			EndIf
		EndIf

		If lSS
			If Empty(oModel:GetValue('TTFMASTER','TTF_RAMAL')) .And. X3OBRIGAT("TQB_RAMAL")
				Help(Nil, Nil, STR0020, Nil, STR0024, 1, 0)// "Deverá ser preenchido o Ramal, quando existir criticidade que Gere SS"
				oGrid:LoadValue("TTG_CRITIC",'')
				oGrid:LoadValue("TTD_TIPMOD",'')
				If ValType(oView) == 'O'
					oView:Refresh() // Atualiza a tela.
				EndIf
				lRet := .F.
			EndIf
		EndIf

	EndIf

	// Ponto de entrada para validar a linha em questao
	If ExistBlock('MNTA735')
		lRet := ExecBlock('MNTA735',.F.,.F.,{oModel,'FORMLINEPOS',oModel:cId})
	EndIf

Return lRet

//------------------------------------------------------------------------------
/*/{Protheus.doc} MNT735PLA
Valida campo Placa

@author Vitor Emanuel Batista
@since 12/11/2008
@version P12

@return lRet, Lógico, Retorna .T. quando verificação estiver correta.
/*/
//------------------------------------------------------------------------------
Function MNT735PLA()

	Local lRet   := .T.
	Local oModel := FWModelActive()
	Local cPlaca := oModel:GetValue('TTFMASTER','TTF_PLACA')

	If !Empty(cPlaca)
		dbSelectArea("ST9")
		dbSetOrder(14)
		If !dbSeek(cPlaca)
			Help(Nil, Nil, STR0020, Nil, STR0022, 1, 0)// "Placa não Encontrada."
			lRet := .F.
		EndIf
		If lRet
			oModel:LoadValue("TTFMASTER","TTF_CODBEM",ST9->T9_CODBEM)
			If !MNT735BEM(oModel:GetValue('TTFMASTER','TTF_CODBEM'))
				lRet := .F.
			EndIf
		EndIf
	EndIf

Return lRet

//------------------------------------------------------------------------------
/*/{Protheus.doc} MNTA735SS
Gera Solicitacao de Servico

@param aSS, Array, Possui campo de Etapa de Criticidade.

@author Vitor Emanuel Batista
@since 13/11/2008
@version P12

@return Array.
		aTypeRet[1], Array	, Gerou ou não a SS (conteúdo Lógico).
		aTypeRet[2], Array	, Mensagem de erro (conteúdo Caracter).
/*/
//------------------------------------------------------------------------------
Static Function MNTA735SS(aSS)

	Local oModel := FWModelActive()
	Local oTQB
	Local cMEMOTQB
	Local cMEMOPROB
	Local cCodSS := ""
	Local cCodB  := oModel:GetValue('TTFMASTER','TTF_CODBEM')
	Local cCheck := oModel:GetValue('TTFMASTER','TTF_CHECK')
	Local nX     := 0
	Local lRPORel17 := IIf(GetRPORelease() <= '12.1.017', .T., .F.) // Release menor ou igual a 17
	Local aTypeRet := { .T. , '' }

	ProcRegua(Len(aSS))
	If Len(aSS) > 0
		MNT280CPO(1,3)
		MNT280REG(3,,a280Memos)

		cMEMOPROB := STR0042 // 'Problema(s):'
		For nX := 1 to Len(aSS)
			IncProc()
			aAdd(aSS[nX],M->TQB_SOLICI)
			cMEMOPROB += Chr(13)+Chr(10) + aSS[nX][1] + " - " + AllTrim(NGSEEK("TPA",aSS[nX][1],1,"Subst(TPA->TPA_DESCRI,1,40)")) + Space(1)
			cMEMOPROB += "(" + NGRETSX3BOX("TTG_CRITIC",aSS[nX][2]) + ")"
		Next nX

		If lRPORel17 // Caso serja release 12.1.17 ou inferior.

			// Gera Solicitacao de Servico
			M->TQB_CODBEM  := cCodB
			M->TQB_TIPOSS  := "B"
			M->TQB_CCUSTO  := NGSEEK("ST9",cCodB,1,"T9_CCUSTO")
			M->TQB_LOCALI  := NGSEEK("ST9",cCodB,1,"T9_LOCAL")
			M->TQB_CENTRA  := NGSEEK("ST9",cCodB,1,"T9_CENTRAB")
			M->TQB_DTABER  := dDataBase
			M->TQB_HOABER  := Time()
			M->TQB_SOLUCA  := "A"
			M->TQB_USUARI  := cUsername
			M->TQB_CDSOLI  := RetCodUsr()
			M->TQB_RAMAL   := oModel:GetValue('TTFMASTER','TTF_RAMAL')

			cMEMOTQB := STR0018+cCheck+"." +Chr(13)+Chr(10)+Chr(13)+Chr(10) // "Solicitação de Serviço aberta pelo Check List Nº"
			cMEMOTQB += cMEMOPROB

			If cMVOBS $ "2/3" .And. !Empty(oModel:GetValue('TTFMASTER','TTF_OBS'))
					cMEMOTQB += Chr(13)+Chr(10)+Chr(13)+Chr(10)
					cMEMOTQB += STR0041 +Chr(13)+Chr(10)+ oModel:GetValue('TTFMASTER','TTF_OBS') // "Observações do Check-List: "
			EndIf

			M->TQB_DESCSS  := cMEMOTQB

			cCodSS := MNT280GRV(1, 3, , a280Memos)

		Else // Caso seja release maior que 12.1.17

			oTQB := MntSR():New() // Chama a classe MntSr
			oTQB:setOperation(3) // Determina processo de inclusão.
			oTQB:setAsk(.F.) // Não apresenta mensagens condicionais.
			oTQB:MemoryToClass() // Joga valores em memória para classe.

			oTQB:setValue("TQB_FILIAL" , xFilial("TQB"))
			oTQB:setValue("TQB_CODBEM" , cCodB)
			oTQB:setValue("TQB_TIPOSS" , "B")
			oTQB:setValue("TQB_CCUSTO" , NGSEEK("ST9",cCodB,1,"T9_CCUSTO"))
			oTQB:setValue("TQB_LOCALI" , NGSEEK("ST9",cCodB,1,"T9_LOCAL"))
			oTQB:setValue("TQB_CENTRA" , NGSEEK("ST9",cCodB,1,"T9_CENTRAB"))
			oTQB:setValue("TQB_DTABER" , dDataBase)
			oTQB:setValue("TQB_HOABER" , Time())
			oTQB:setValue("TQB_SOLUCA" , "A")
			oTQB:setValue("TQB_USUARI" , cUsername)
			oTQB:setValue("TQB_CDSOLI" , RetCodUsr())
			oTQB:setValue("TQB_RAMAL"  , oModel:GetValue('TTFMASTER','TTF_RAMAL'))

			cMEMOTQB := STR0018+cCheck+"." +Chr(13)+Chr(10)+Chr(13)+Chr(10) // "Solicitação de Serviço aberta pelo Check List Nº"
			cMEMOTQB += cMEMOPROB

			If cMVOBS $ "2/3" .And. !Empty(oModel:GetValue('TTFMASTER','TTF_OBS'))
				cMEMOTQB += Chr(13)+Chr(10)+Chr(13)+Chr(10)
				cMEMOTQB += STR0041 +Chr(13)+Chr(10)+ oModel:GetValue('TTFMASTER','TTF_OBS') // "Observações do Check-List: "
			EndIf

			oTQB:setValue("TQB_DESCSS" , cMEMOTQB)

			If oTQB:valid() // Realiza validações.
				cCodSS := MNT280GRV(1, 3, , a280Memos, , , oTQB)
			Else
				//Array contendo o resultado do erro gerado na validação (oTQB:valid())
				aTypeRet := { .F. , oTQB:GetErrorList()[1] }
			EndIf

			oTQB:Free() // Destroi objeto da classe.

		EndIf

		If !Empty(cCodSS)

			dbSelectArea("TQB")
			dbSetOrder(1)
			dbSeek(xFilial("TQB")+cCodSS)

			// Ponto de entrada para adicionar dados na tabela TQB
			If ExistBlock("MNTA7354")
				ExecBlock("MNTA7354",.F.,.F.)
			EndIf

		EndIf

	EndIf

Return aTypeRet

//------------------------------------------------------------------------------
/*/{Protheus.doc} MNTA735OS
Gera Ordem de Servico Corretiva

@param aOS, Array, Possui campo de Serviço de Etapa.

@author Vitor Emanuel Batista
@since 13/11/2008
@version P12

@return Sempre Verdadeiro.
/*/
//------------------------------------------------------------------------------
Static Function MNTA735OS(aOS)

	Local oModel   := FWModelActive()
	Local cSerefor := Alltrim(GETMV("MV_NGSEREF"))
	Local aServRef := StrTokArr( cSerefor, ';' )
	Local cSercons := Alltrim(GETMV("MV_NGSECON"))
	Local aServCon := StrTokArr( cSercons, ';' )
	Local cMEMOSTJ
	Local cCodB    := oModel:GetValue('TTFMASTER','TTF_CODBEM')
	Local cCheck   := oModel:GetValue('TTFMASTER','TTF_CHECK')
	Local cHora    := oModel:GetValue('TTFMASTER','TTF_HORA')
	Local lCont1   := (Posicione("ST9", 1, xFilial("ST9") + cCodB, 'T9_TEMCONT') == 'S')
	Local lCont2   := MNT735TPE(cCodB)
	Local nOS      := 0
	Local nX       := 0
	Local nCont1   := oModel:GetValue('TTFMASTER','TTF_POSCON')
	Local nCont2   := oModel:GetValue('TTFMASTER','TTF_POSCO2')
	Local lMNTA7353:= ExistBlock("MNTA7353")

	ProcRegua(Len(aOS))
	For nOS := 1 to Len(aOS)
		IncProc()

		If aScan(aServRef, {|x| x == AllTrim(aOS[nOS][1])}) == 0 .And. aScan(aServCon, {|x| x == AllTrim(aOS[nOS][1])}) == 0

			// Gera Ordem de Servico Corretiva
			aRetorno := NGGERAOS('C',dDataBase,cCodB,aOS[nOS][1],,'N','N','N')
			If aRetorno[1][1] == 'N'
				Help(Nil, Nil, STR0020, Nil, aRetorno[1][2], 1, 0)
			Else
				dbSelectArea("STJ")
				dbSetOrder(1)
				If dbSeek(xFilial("STJ")+aRetorno[1][3]+'000000')
					RecLock("STJ",.F.)
					cMEMOSTJ := STR0017+cCheck+"." // "Ordem de Serviço aberta pelo Check List Nº"

					If cMVOBS $ '1/3'
						If !Empty(oModel:GetValue('TTFMASTER','TTF_OBS'))
							cMEMOSTJ += Chr(13)+Chr(10)+Chr(13)+Chr(10)
							cMEMOSTJ += STR0041 +Chr(13)+Chr(10)+ oModel:GetValue('TTFMASTER','TTF_OBS') // "Observações do Check-List: "
						EndIf
					EndIf

					If lCont1 .And. !Empty(nCont1)
						STJ->TJ_HORACO1 := cHora
						STJ->TJ_POSCONT := nCont1
					EndIf

					If lCont2 .And. !Empty(nCont2)
						STJ->TJ_HORACO2 := cHora
						STJ->TJ_POSCON2 := nCont2
					EndIf

					If NGCADICBASE("TJ_MMSYP","A","STJ",.F.)
						MsMM(,80,,cMEMOSTJ,1,,,"STJ","TJ_MMSYP")
					Else
						STJ->TJ_OBSERVA := cMEMOSTJ
					EndIf
					MsUnlock("STJ")
				EndIf

				For nX := 2 to Len(aOS[nOS])
					dbSelectArea("TTG")
					dbSetOrder(1)
					If dbSeek(xFilial("TTG")+cCheck+aOS[nOS,nX])
						RecLock("TTG",.F.)
						TTG->TTG_NUMERO := aRetorno[1][3]
						MsUnLock("TTG")
					EndIf

					// Grava Etapas Relacionada a Ordem de Servico
					RecLock("STQ",.T.)
					STQ->TQ_FILIAL  := xFilial("STQ")
					STQ->TQ_ORDEM   := aRetorno[1][3]
					STQ->TQ_PLANO   := '000000'
					STQ->TQ_TAREFA  := '0'
					STQ->TQ_ETAPA   := aOS[nOS][nX]
					MsUnLock("STQ")

					// Ponto de entrada para adicionar dados nas tabelas STQ
					If lMNTA7353
						ExecBlock("MNTA7353",.F.,.F.)
					EndIf

				Next nX
			EndIf
		Else
			Help(Nil, Nil, STR0020, Nil, STR0044, 1, 0)
		EndIf
	Next nOS

Return .T.

//------------------------------------------------------------------------------
/*/{Protheus.doc} MNTA735GAT
Função utilizada em gatilho dos campos.

@param nInd, Numérico, Quando for valor 1 - é chamado pelo campo de bem.
@param nInd, Numérico, Quandof for o valor 2 - é chamado pelo campo de placa.

@author Guilherme Freudenburg
@since 20/03/2018
@version P12

@return cCod, Caracter, Retorna o Código do bem ou placa.
/*/
//------------------------------------------------------------------------------
Function MNTA735GAT(nInd)

	Local oModel  := FWModelActive() // Copia o Model utilizado.
	Local oView   := FWViewActive() // Ativação do View.
	Local cCod    := oModel:GetValue('TTFMASTER','TTF_CODBEM')
	Local nNomBem := TAMSX3('TTF_NOMBEM')[1]
	Local nNomFam := TAMSX3('TTF_NOMFAM')[1]
	Local nDesMod := TAMSX3('TTF_DESMOD')[1]
	Local nPlaca  := TAMSX3('TTF_PLACA')[1]

	If nInd == 1 // Se foi chamado pelo campo de bem.
		oModel:LoadValue("TTFMASTER","TTF_NOMBEM",SubStr(Posicione("ST9",1,xFilial("ST9")+cCod,"T9_NOME"),1,nNomBem))
		oModel:LoadValue("TTFMASTER","TTF_CODFAM",Posicione("ST9",1,xFilial("ST9")+cCod,"T9_CODFAMI"))
		oModel:LoadValue("TTFMASTER","TTF_NOMFAM",SubStr(Posicione("ST6",1,xFilial("ST6")+oModel:GetValue('TTFMASTER','TTF_CODFAM'),"T6_NOME"),1,nNomFam))
		oModel:LoadValue("TTFMASTER","TTF_TIPMOD",Posicione("ST9",1,xFilial("ST9")+cCod,"T9_TIPMOD"))
		oModel:LoadValue("TTFMASTER","TTF_DESMOD",SubStr(Posicione("TQR",1,xFilial("TQR")+oModel:GetValue('TTFMASTER','TTF_TIPMOD'),"TQR_DESMOD"),1,nDesMod))
		If NGVERUTFR()
			If !Empty(Posicione("ST9",1,xFilial("ST9")+cCod,"T9_PLACA"))
				oModel:LoadValue("TTFMASTER","TTF_PLACA",SubStr(Posicione("ST9",1,xFilial("ST9")+cCod,"T9_PLACA"),1,nPlaca))
			Else
				oModel:LoadValue("TTFMASTER","TTF_PLACA",Space(nPlaca))
			EndIf
		EndIf
		cCod  := oModel:GetValue('TTFMASTER','TTF_NOMBEM')
	Else // Caso foi chamado pelo campo de placa.
		cPlaca := oModel:GetValue('TTFMASTER','TTF_PLACA')
		If !Empty( cPlaca )
			oModel:LoadValue("TTFMASTER","TTF_CODBEM",Posicione("ST9",14,cPlaca,"T9_CODBEM"))
			oModel:LoadValue("TTFMASTER","TTF_NOMBEM",SubStr(Posicione("ST9",14,cPlaca,"T9_NOME"),1,nNomBem))
			oModel:LoadValue("TTFMASTER","TTF_CODFAM",Posicione("ST9",14,cPlaca,"T9_CODFAMI"))
			oModel:LoadValue("TTFMASTER","TTF_NOMFAM",SubStr(Posicione("ST6",1,xFilial("ST6")+oModel:GetValue('TTFMASTER','TTF_CODFAM'),"T6_NOME"),1,nNomFam))
			oModel:LoadValue("TTFMASTER","TTF_TIPMOD",Posicione("ST9",14,cPlaca,"T9_TIPMOD"))
			oModel:LoadValue("TTFMASTER","TTF_DESMOD",SubStr(Posicione("TQR",1,xFilial("TQR")+oModel:GetValue('TTFMASTER','TTF_TIPMOD'),"TQR_DESMOD"),1,nDesMod))
			// Retorna nome do bem
			cCod := oModel:GetValue('TTFMASTER','TTF_NOMBEM')
		Else // Limpa os campos caso o usuário apaque o campo de placa.
			oModel:LoadValue( 'TTFMASTER', 'TTF_CODBEM', '' )
			oModel:LoadValue( 'TTFMASTER', 'TTF_NOMBEM', '' )
			oModel:LoadValue( 'TTFMASTER', 'TTF_CODFAM', '' )
			oModel:LoadValue( 'TTFMASTER', 'TTF_NOMFAM', '' )
			oModel:LoadValue( 'TTFMASTER', 'TTF_TIPMOD', '' )
			oModel:LoadValue( 'TTFMASTER', 'TTF_DESMOD', '' )
			If lRel12133
				oModel:ClearField('TTFMASTER', 'TMCHKPAD')
			EndIf
			cCod := ''
		EndIf
	EndIf
	If ValType(oView) == 'O'
		oView:Refresh() // Atualiza a tela.
	EndIf

Return cCod

//------------------------------------------------------------------------------
/*/{Protheus.doc} MNTA735COM
Função responsável por chamar o View e o Model.

@param nInd, Numérico, Determina a operação que será executada.

@obs. Função foi criada mediante a necessidade de abrir a tela
		de Visualização e Exclusão com alguns campos a mais na
		Grid como (TTG_EVENTO, TTG_NUMERO e TTG_SERVIC), os quais
		na Inclusão não devem estar presentes, mas são preenchidos
		em conjunto com a gravação.

@author Guilherme Freudenburg
@since 20/03/2018
@version P12

@return Sempre Verdadeiro.
/*/
//------------------------------------------------------------------------------
Function MNTA735COM(nOperat)

	Local oModelEx

	Default nOperat := 1 // Visualização

	oModelEx := FWViewExec():New()
	oModelEx:SetTitle( STR0001 ) //'Check List'
	oModelEx:SetSource( "MNTA735" )
	oModelEx:SetModal( .F. )
	oModelEx:SetOperation( nOperat )
	oModelEx:OpenView( .F. )

Return .T.

//------------------------------------------------------------------------------
/*/{Protheus.doc} MNT735WHEN
Função utilizada no When dos campos das tabelas TTF e TTG.

@author Guilherme Freudenburg
@since 20/03/2018
@version P12

@return lRet, Lógico, Retorna .T. para liberar o campo e .F. para travar.
/*/
//------------------------------------------------------------------------------
Function MNT735WHEN(cCampo)

	Local lRet   := .F.
	Local lCont1 := .F.
	Local oModel := FWModelActive()  // Copia o Model utilizado.
	Local aArea  := GetArea() // Salva area posicionada.
	Local cCodB  := oModel:GetValue('TTFMASTER','TTF_CODBEM')

	Default cCampo := ''

	If cCampo == "TTF_POSCON"

		lCont1 := (Posicione("ST9", 1, xFilial("ST9") + cCodB, 'T9_TEMCONT') == 'S')

		If lCont1 .And. NGBlCont( cCodB )
			lRet := .T.
		EndIf

	ElseIf cCampo == "TTF_POSCO2"

		dbSelectArea("TPE")
		dbSetOrder(1)
		lRet := dbSeek(xFilial("TPE")+cCodB)

	EndIf

	RestArea(aArea)

Return lRet

//------------------------------------------------------------------------------
/*/{Protheus.doc} MNT735TPE
Verifica se o bem possui o segundo contador.

@param cCodBme, Caracter, Código do bem que será verificado.

@author Guilherme Freudenburg
@since 20/03/2018
@version P12

@return lRet, Lógico, Retorna .T. para liberar o campo e .F. para travar.
/*/
//------------------------------------------------------------------------------
Function MNT735TPE(cCodBem)

	Local aArea := GetArea() // Salva area posicionada.
	Local lRet  := .F.

	dbSelectArea("TPE")
	dbSetOrder(1)
	lRet := dbSeek(xFilial("TPE")+cCodBem)

	RestArea(aArea)

Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} fSeekPad
Busca Check List padrão na TTE/TTD

@type   Function

@author Cristiano Serafim Kair
@since  28/04/2021
@Param  cCodFam, Caracter, Família do Bem
		cTipMod, Caracter, Tipo Modelo
		cSeqFam, Caracter, Sequência da Família
		cCompl,  Caracter, Código do complemento de pesquisa

@return Lógico, .T. ou .F. ao tentar encontrar um registro na TTE com os argumentos.
/*/
//-------------------------------------------------------------------
Static Function fSeekPad( cCodFam, cTipMod, cSeqFam, cCompl, cTabela, nIndice )

	Local lTemPad 	:= .F.

	Default cSeqFam := ''
	Default cCompl	:= ''
	Default cTabela := 'TTE'
	Default nIndice := 3

	If lRel12133

		lTemPad := MNTSeekPad( cTabela, nIndice, cCodFam, cTipMod, cSeqFam + cCompl )

	Else

		dbSelectArea( cTabela )
		dbSetOrder( nIndice )
		lTemPad := dbSeek( xFilial( cTabela ) + cCodFam + cTipMod + cSeqFam + cCompl )

	EndIf

Return lTemPad

//------------------------------------------------------------------------------
/*/{Protheus.doc} MNTA735SFM
Funcao para carregar as sequencias na Consulta Padrão. do campo Seq. Fam.
É chamada no Tipo 6 (filtro) da Consulta Padrão TTDSEQ

@author Cristiano S. Kair
@since 05/05/21
@version P12

@return cFiltro, Character, Filtro SQL
/*/
//------------------------------------------------------------------------------
Function MNTA735SFM()

	Local oModel := FWModelActive()
	Local cCodFa := oModel:GetValue('TTFMASTER','TTF_CODFAM')
	Local cTipoM := oModel:GetValue('TTFMASTER','TTF_TIPMOD')
	Local cFiltro

	cFiltro := "@TTD_CODFAM = " + ValToSql(cCodFa)
	cFiltro += " AND ( ( TTD_TIPMOD = " + ValToSql( Padr('*', Len(cTipoM) ) )
	cFiltro +=         " AND NOT EXISTS ( SELECT 1"
	cFiltro +=                          " FROM " + RetSqlName('TTD') + " TTDPAD"
	cFiltro +=                          " WHERE TTDPAD.TTD_CODFAM = " + ValToSql( cCodFa )
	cFiltro +=                            " AND TTDPAD.TTD_TIPMOD = " + ValToSql( cTipoM )
	cFiltro +=                            " AND TTDPAD.TTD_FILIAL = " + ValToSql( xFilial('TTD') )
	cFiltro +=                            " AND TTDPAD.D_E_L_E_T_ = ' ' ) "
	cFiltro +=      ") OR TTD_TIPMOD   = " + ValToSql(cTipoM) + " )"

Return cFiltro
