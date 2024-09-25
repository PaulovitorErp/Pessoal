#INCLUDE 'MNTA016.ch'
#INCLUDE 'Protheus.ch'
#INCLUDE 'FWMVCDef.ch'

//---------------------------------------------------------------------
/*/{Protheus.doc} MNTA016
Nova rotina de Etapas genéricas

@author Pedro Henrique Soares de Souza
@since 13/05/2014
@version 1.0
@return Nil, Nulo
/*/
//---------------------------------------------------------------------
Function MNTA016()

	Local oBrowse
	Local aNGBEGINPRM := NGBEGINPRM()

	Private cNewForm, cRetF3
	Private cMntGenFun := 'MNTTPCF3()'
	Private cMntGenRet := 'MNTTPCRET()'

	oBrowse := FWMBrowse():New()
	oBrowse:SetAlias("TPA")         // Alias da tabela utilizada
	oBrowse:SetMenuDef("MNTA016")   // Nome do fonte onde está a função MenuDef
	oBrowse:SetDescription(STR0001) // Descrição do browse ## "Etapas Genéricas"
	oBrowse:Activate()

	NGRETURNPRM(aNGBEGINPRM)

Return

//---------------------------------------------------------------------
/*/{Protheus.doc} MenuDef
Opções de menu

@author Pedro Henrique Soares de Souza
@since 13/05/2014
@version P11/P12
@return aRotina - Estrutura
	[n,1] Nome a aparecer no cabecalho
	[n,2] Nome da Rotina associada
	[n,3] Reservado
	[n,4] Tipo de Transação a ser efetuada:
		1 - Pesquisa e Posiciona em um Banco de Dados
		2 - Simplesmente Mostra os Campos
		3 - Inclui registros no Bancos de Dados
		4 - Altera o registro corrente
		5 - Remove o registro corrente do Banco de Dados
		6 - Alteração sem inclusão de registros
		7 - Cópia
		8 - Imprimir
	[n,5] Nivel de acesso
	[n,6] Habilita Menu Funcional
/*/
//---------------------------------------------------------------------
Static Function MenuDef()

	Local aRotina := {}

	ADD OPTION aRotina TITLE STR0004 ACTION 'PesqBrw'           OPERATION 1  ACCESS 0 // 'Pesquisar'
	ADD OPTION aRotina TITLE STR0005 ACTION 'VIEWDEF.MNTA016'   OPERATION 2  ACCESS 0 // 'Visualizar'
	ADD OPTION aRotina TITLE STR0006 ACTION 'VIEWDEF.MNTA016'   OPERATION 3  ACCESS 0 // 'Incluir'
	ADD OPTION aRotina TITLE STR0007 ACTION 'VIEWDEF.MNTA016'   OPERATION 4  ACCESS 0 // 'Alterar'
	ADD OPTION aRotina TITLE STR0008 ACTION 'VIEWDEF.MNTA016'   OPERATION 5  ACCESS 0 // 'Excluir'
	ADD OPTION aRotina TITLE STR0009 ACTION 'VIEWDEF.MNTA016'   OPERATION 8  ACCESS 0 // 'Imprimir'
	ADD OPTION aRotina TITLE STR0010 ACTION 'VIEWDEF.MNTA016'   OPERATION 9  ACCESS 0 // 'Copiar'

Return aRotina

//-------------------------------------------------------------------
/*/{Protheus.doc} ModelDef
Definição do modelo de Dados

@author Pedro Henrique Soares de Souza
@since 13/05/2014
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function ModelDef()

	Local oModel

	// Cria a estrutura a ser usada no Modelo de Dados
	Local oStructST1 := FWFormStruct( 1, 'TPA', /*bAvalCampo*/,/*lViewUsado*/ )
	Local oStructST2 := FWFormStruct( 1, 'TPC', /*bAvalCampo*/,/*lViewUsado*/ )
	Local oStructST3 := FWFormStruct( 1, 'TVT', /*bAvalCampo*/,/*lViewUsado*/ )

	Local bLinePost := {| oModelGrid, nLine | LinePost( oModelGrid, nLine ) }

    // Cria o objeto do Modelo de Dados
	oModel := MPFormModel():New('MNTA016', /*bPreValidacao*/,{|oModel| ValidInfo(oModel)}, {|oModel| CommitInfo(oModel) }, /*bCancel*/ )

    // Adiciona ao modelo uma estrutura de formulário de edição por campo
	oModel:AddFields( 'MNTA016_TPA', /*cOwner*/, oStructST1, /*bPreValidacao*/, /*bPosValidacao*/, /*bCarga*/ )

    // Adiciona ao modelo uma estrutura de formulário de edição por grid
	oModel:AddGrid( 'MNTA016_TPC', 'MNTA016_TPA', oStructST2, /*bLinePre*/, bLinePost, /*bPreValida*/, /*bPosVal*/, /*{|oModel| LoadGrid(oModel)}*/ )

    // Adiciona ao modelo uma estrutura de formulário de edição por grid
    oModel:AddGrid( 'MNTA016_TVT', 'MNTA016_TPA', oStructST3, /*bLinePre*/, bLinePost, /*bPreValida*/, /*bPosVal*/, /*{|oModel| LoadGrid(oModel)}*/ )


    // Faz relaciomaneto entre os compomentes do model
	oModel:SetRelation( 'MNTA016_TPC', { { 'TPC_FILIAL', 'xFilial( "TPC" )' }, { 'TPC_ETAPA', 'TPA_ETAPA' } }, TPC->(IndexKey(1)) )

    // Faz relaciomaneto entre os compomentes do model
    oModel:SetRelation( 'MNTA016_TVT', { { 'TVT_FILIAL', 'xFilial( "TVT" )' }, { 'TVT_ETAPA', 'TPA_ETAPA' } }, TVT->(IndexKey(1)) )

    // Liga o controle de não repetição de linha
	oModel:GetModel( 'MNTA016_TPC' ):SetUniqueLine( { 'TPC_OPCAO' } )
	oModel:GetModel( 'MNTA016_TVT' ):SetUniqueLine( {'TVT_CODFAM','TVT_TIPMOD','TVT_ANO' } )

    // Indica que é opcional ter dados informados na Grid
	oModel:GetModel( 'MNTA016_TPC' ):SetOptional(.T.)

    // Indica que é opcional ter dados informados na Grid
    oModel:GetModel( 'MNTA016_TVT' ):SetOptional(.T.)

    // Adiciona a descrição do Modelo de Dados
	oModel:SetDescription( STR0001 ) // "Etapas Genéricas"

    // Adiciona a descrição do Componente do Modelo de Dados
	oModel:GetModel('MNTA016_TPA' ):SetDescription( STR0002 ) // "Dados da Etapa"
	oModel:GetModel('MNTA016_TPC' ):SetDescription( STR0003 ) // "Dados das Opções"
	oModel:GetModel('MNTA016_TVT' ):SetDescription( STR0041 ) // "Dados do Tempo Médio"


Return oModel

//-------------------------------------------------------------------
/*/{Protheus.doc} ViewDef
Definição do interface

@author Pedro Henrique Soares de Souza
@since 13/05/2014
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function ViewDef()

    // Cria um objeto de Modelo de Dados baseado no ModelDef do fonte informado
	Local oModel := FWLoadModel( 'MNTA016' )

    // Cria a estrutura a ser usada na View
	Local oStructST1 := FWFormStruct( 2, 'TPA' )
	Local oStructST2 := FWFormStruct( 2, 'TPC' )
	Local oStructST3 := FWFormStruct( 2, 'TVT' )

	oStructST1:RemoveField("TPA_DOCTO")
	oStructST1:RemoveField("TPA_DOCFIL")

    // Cria o objeto de View
	oView := FWFormView():New()

    // Define qual o Modelo de dados será utilizado
	oView:SetModel( oModel )

    //Adiciona no nosso View um controle do tipo FormFields(antiga enchoice)
	oView:AddField( 'VIEW_TPA', oStructST1, 'MNTA016_TPA' )//oView:AddField('FORM2' , oStr3 )/

    //Adiciona um titulo para o formulário
	oView:EnableTitleView( 'VIEW_TPA' ,STR0002 ) // "Dados da Etapa"


    //Adiciona no nosso View um controle do tipo FormGrid(antiga newgetdados)
	oView:AddGrid( 'VIEW_TPC', oStructST2, 'MNTA016_TPC' )//oView:AddGrid('FORM6' , oStr4)
	oView:AddGrid( 'VIEW_TVT', oStructST3, 'MNTA016_TVT' )// oView:AddGrid('FORM8' , oStr5)

    // Criar um "box" horizontal para receber algum elemento da view
	oView:CreateHorizontalBox( 'SUPERIOR', 40 )
    oView:CreateVerticalBox( 'BOX_GRIDS', 100, 'SUPERIOR')
	oView:CreateHorizontalBox( 'INFERIOR', 60 )

    oView:CreateFolder( 'PASTAS', 'INFERIOR')
    oView:AddSheet('PASTAS','PASTA_TPC',STR0003)
    oView:AddSheet('PASTAS','PASTA_TVT',STR0041)//'Dados do Tempo Médio'

    oView:CreateHorizontalBox( 'BOX_TVT', 100, /*owner*/, /*lUsePixel*/, 'PASTAS', 'PASTA_TVT')
    oView:SetOwnerView('VIEW_TVT','BOX_TVT')
    oView:CreateHorizontalBox( 'BOX_TPC', 100, /*owner*/, /*lUsePixel*/, 'PASTAS', 'PASTA_TPC')
    oView:SetOwnerView('VIEW_TPC','BOX_TPC')
    oView:SetOwnerView('VIEW_TPA','BOX_GRIDS')


    //Remove o campo repetido em tela
	oStructST2:RemoveField("TPC_ETAPA")
	oStructST3:RemoveField("TVT_ETAPA")
	NGMVCUserBtn( oView, { { STR0011, 'MNT016QDO()' } } )

Return oView


//---------------------------------------------------------------------
/*/{Protheus.doc} ValidInfo
Validação ao confirmar tela

@author Pedro Henrique Soares de Souza
@since 13/05/2014
@version P11
@return lRet Lógico
/*/
//---------------------------------------------------------------------
Static Function ValidInfo(oModel)

	Local nI, nX
	Local lRet      := .T.
	Local nNumReg   := 0
	Local oModelTPC := oModel:GetModel( 'MNTA016_TPC' )

	If oModel:GetOperation() <> MODEL_OPERATION_DELETE
		If M->TPA_OPCOES != '0'
			For nI := 1 To oModelTPC:Length()

				oModelTPC:GoLine( nI )

				//---------------------------------------
				// Validação de linha
				//---------------------------------------
				lRet := Linepost( oModelTPC, nI )

				If !oModelTPC:IsDeleted() .And. !Empty( oModelTPC:GetValue('TPC_OPCAO') )
					nNumReg++
				EndIf
			Next nI

			If nNumReg < 2
				If M->TPA_OPCOES == '1'
					Help(" ",1,"NDUASOPCAO")
					lRet := .F.
				ElseIf nNumReg < 1
					Help(" ",1,"NGUMAOPCAO")
					lRet := .F.
				EndIf
			EndIf
		Else
			For nX := 1 To oModelTPC:Length()

				oModelTPC:GoLine( nI )

				If !oModelTPC:IsDeleted()
					If !Empty( oModelTPC:GetValue('TPC_OPCAO') )
						Help(" ",1,"NGSEMOPCAO")
						lRet := .F.
						Exit
					EndIf
				EndIf
			Next nX
		EndIf
	EndIf

Return lRet

//---------------------------------------------------------------------
/*/{Protheus.doc} CommitInfo
Confirmação da tela de cadastro

@author Pedro Henrique Soares de Souza
@since 06/08/2014
@version P11
@param oModel
@return lRet Lógico

@obs Função criada por Inacio Luiz Kolling (data desconhecida).
Readequada por Pedro Henrique (06/08/2014) quando transformada em MVC.

/*/
//---------------------------------------------------------------------
Static Function CommitInfo(oModel)

	Local aArea     := GetArea()
	Local aAreaTPH  := TPH->(GetArea())
	Local aAreaTP2  := TP2->(GetArea())
	Local aAreaSTH  := STH->(GetArea())
	Local aAreaTP1  := TP1->(GetArea())
	Local aAreaTPC  := TPC->(GetArea())

	Local nX, nZ
	Local lPadrao   := .F.

	Local cEtapa    := M->TPA_ETAPA
	Local cOpcoes   := M->TPA_OPCOES
	Local cTipRes   := Space( TamSX3("TPA_OPCOES")[1] )

	Local oModelTPC := oModel:GetModel( 'MNTA016_TPC' )

	If oModel:GetOperation() == MODEL_OPERATION_UPDATE

		cTipRes := TPA->TPA_OPCOES

		// Verifica se alterou dados do TPA e ou Opcoes ( getdados )
		If !lPadrao
			If TPA->TPA_OPCOES <> cOpcoes
				lPadrao := .T.
			EndIf

			If !lPadrao
				For nZ := 1 To oModelTPC:Length()
					If oModelTPC:IsUpdated() .Or. oModelTPC:IsDeleted()
						lPadrao := .T.
						Exit
					EndIf
				Next nZ
			EndIf
		EndIf

		If lPadrao
			Pergunte("MNT015",.T.)

			If MV_PAR01 == 2

				/*--------------------------------------------------
				Deleta opções da Etapa Padrão
				---------------------------------------------------*/
				If !(cTipRes == '0' .And. cOpcoes $ '1/2')
					dbSelectArea("TP2")
					dbSetOrder(2)
					If dbSeek( xFilial("TP2") + cEtapa )
						While !EoF() .And. TP2->TP2_FILIAL == xFilial( "TP2" ) .And.;
								TP2->TP2_ETAPA == cEtapa

							RecLock("TP2", .F.)
							dbDelete()
							MsUnlock("TP2")

							dbSelectArea("TP2")
							dbSkip()
						EndDo
					EndIf
				EndIf

				/*--------------------------------------------------
				Atualiza registros da Etapa Padrão
				---------------------------------------------------*/
				dbSelectArea("TPH")
				dbSetOrder(2)
				If dbSeek( xFilial("TPH") + cEtapa )
					While !EoF() .And. TPH->TPH_FILIAL == xFilial("TPH") .And.;
							TPH->TPH_ETAPA == cEtapa

						RecLock("TPH", .F.)
						TPH->TPH_OPCOES := cOpcoes
						MsUnlock("TPH")

						If !(cTipRes $ '1/2' .And. cOpcoes == '0')
							For nX = 1 To oModelTPC:Length()

								oModelTPC:GoLine( nX )

								If !oModelTPC:IsDeleted()
									dbSelectArea("TP2")
									dbSetOrder(01)
									If !dbSeek(xFilial("TP2") + TPH->TPH_CODFAM + TPH->TPH_SERVIC +;
											TPH->TPH_SEQREL + TPH->TPH_TAREFA + TPH->TPH_ETAPA + oModelTPC:GetValue('TPC_OPCAO') )

										RecLock("TP2", .T.)

										TP2->TP2_FILIAL := xFilial("TP2")
										TP2->TP2_CODFAM := TPH->TPH_CODFAM
										TP2->TP2_SERVIC := TPH->TPH_SERVIC
										TP2->TP2_SEQREL := TPH->TPH_SEQREL
										TP2->TP2_TAREFA := TPH->TPH_TAREFA
										TP2->TP2_ETAPA  := TPH->TPH_ETAPA

										If NGCADICBASE( "TP2_TIPMOD", "A", "TP2", .F.)
											TP2->TP2_TIPMOD := TPH->TPH_TIPMOD
										EndIf

										TP2->TP2_FORMUL := oModelTPC:GetValue('TPC_FORMUL')
										TP2->TP2_DESOPC := oModelTPC:GetValue('TPC_DESOPC')
										TP2->TP2_OPCAO  := oModelTPC:GetValue('TPC_OPCAO')
										TP2->TP2_TIPRES := oModelTPC:GetValue('TPC_TIPRES')
										TP2->TP2_TIPCAM := oModelTPC:GetValue('TPC_TIPCAM')
										TP2->TP2_TPMANU := oModelTPC:GetValue('TPC_TPMANU')
										TP2->TP2_SERVMN := oModelTPC:GetValue('TPC_SERVIC')
										TP2->TP2_PORBEM := oModelTPC:GetValue('TPC_PORBEM')
										TP2->TP2_DESCRI := oModelTPC:GetValue('TPC_DESCRI')

										MsUnlock("TP2")
									EndIf
								EndIf
							Next nX
						EndIf

						dbSelectArea("TPH")
						dbSkip()
					EndDo
				EndIf

				/*--------------------------------------------------
				Deleta opções da Etapa Padrão
				---------------------------------------------------*/
				If !(cTipRes == '0' .And. cOpcoes $ '1/2')
					dbSelectArea("TP1")
					dbSetOrder(02)
					If dbSeek(xFilial("TP1") + cEtapa)
						While !EoF() .And. TP1->TP1_FILIAL == xFilial("TP1") .And.;
								TP1->TP1_ETAPA == cEtapa

							RecLock("TP1", .F.)
							dbDelete()
							MsUnlock("TP1")

							dbSelectArea("TP1")
							dbSkip()
						EndDo
					EndIf
				EndIf

				/*--------------------------------------------------
				Atualiza registros da Etapa Padrão
				---------------------------------------------------*/
				dbSelectArea("STH")
				dbSetOrder(2)
				If dbSeek( xFilial("STH") + cEtapa )
					While !EoF() .And. STH->TH_FILIAL == xFilial("STH") .And.;
							STH->TH_ETAPA == cEtapa

						RecLock("STH",.F.)
						STH->TH_OPCOES := cOpcoes
						MsUnlock("STH")

						If !(cTipRes $ '1/2' .And. cOpcoes == '0')
							For nX = 1 To oModelTPC:Length()

								oModelTPC:GoLine( nX )

								If !oModelTPC:IsDeleted()
									dbSelectArea("TP1")
									dbSetOrder(1)
									If !dbSeek( xFilial("TP1") + STH->TH_CODBEM + STH->TH_SERVICO +;
											STH->TH_SEQRELA + STH->TH_TAREFA + STH->TH_ETAPA + oModelTPC:GetValue('TPC_OPCAO') )

										RecLock("TP1",.T.)

										TP1->TP1_FILIAL := xFilial('TP1')
										TP1->TP1_CODBEM := STH->TH_CODBEM
										TP1->TP1_SERVIC := STH->TH_SERVICO
										TP1->TP1_SEQREL := STH->TH_SEQRELA
										TP1->TP1_TAREFA := STH->TH_TAREFA
										TP1->TP1_ETAPA  := STH->TH_ETAPA
										TP1->TP1_OPCAO  := oModelTPC:GetValue('TPC_OPCAO')
										TP1->TP1_TIPRES := oModelTPC:GetValue('TPC_TIPRES')
										TP1->TP1_TIPCAM := oModelTPC:GetValue('TPC_TIPCAM')
										TP1->TP1_TPMANU := oModelTPC:GetValue('TPC_TPMANU')
										TP1->TP1_SERVMN := oModelTPC:GetValue('TPC_SERVIC')
										TP1->TP1_FORMUL := oModelTPC:GetValue('TPC_FORMUL')
										TP1->TP1_DESOPC := oModelTPC:GetValue('TPC_DESOPC')

										If oModelTPC:GetValue('TPC_PORBEM') == '1'
											TP1->TP1_BEMIMN := STH->TH_CODBEM
										Else
											If !Empty( oModelTPC:GetValue('TPC_DESCRI') )
												TP1->TP1_BEMIMN := SubStr( oModelTPC:GetValue('TPC_DESCRI'), 1, 16 )
											EndIf
										EndIf
										MsUnlock("TP1")
									EndIf
								EndIf
							Next nX
						EndIf

						dbSelectArea("STH")
						dbSkip()
					EndDo
				EndIf
			Else
				/*--------------------------------------------------
				Deleta as opções da Etapa
				---------------------------------------------------*/
				If !Empty( cTipRes ) .And. cOpcoes == '0'
					For nX := 1 To oModelTPC:Length()
						dbSelectArea('TPC')
						dbSetOrder(1)
						If dbSeek( xFilial( 'TPC' ) + cEtapa )

							While !EoF() .And. TPC->TPC_filial == xFilial('TPC') .And.;
									TPC->TPC_ETAPA == cEtapa

								RecLock('TPC', .F.)
								dbDelete()
								MsUnlock('TPC')

								dbSelectArea("TPC")
								dbSkip()
							EndDo
						EndIf
					Next nX
				EndIf
			EndIf
		EndIf
	EndIf

	FwFormCommit(oModel)

	RestArea( aAreaTPC )
	RestArea( aAreaTP1 )
	RestArea( aAreaSTH )
	RestArea( aAreaTP2 )
	RestArea( aAreaTPH )
	RestArea( aArea )

Return .T.

//---------------------------------------------------------------------
/*/{Protheus.doc} MNT016QDO
Monta a tela de visualização ou relacionamento do documento

@author Elisangela Costa
@since 13/10/2004
@version P11
@return lRet Lógico
/*/
//---------------------------------------------------------------------
Function MNT016QDO()

	Local oDlgQdo, oRadio, oMenu
	Local oModel := FWModelActive()

	Local nRadio := 1
	Local nOpc   := 1

	Local lRet   := .T.
	Local lGrava

	Define MsDialog oDlgQdo From 03.5,6 To 150,320 Title STR0012 Pixel  // "Atenção"

	Define FONT oBold NAME "Courier New" SIZE 0, -13 BOLD

	@ 0, 0 BITMAP oBmp RESNAME "PROJETOAP" oF oDlgQdo SIZE 35,250 NOBORDER WHEN .F. PIXEL

	@ 05,040 Say STR0013 Size 117,7 Of oDlgQdo Pixel Font oBold  //"O que deseja fazer?"

	@ 20,048 Radio oRadio Var nRadio Items STR0014, STR0015, STR0016 3d Size 105,10 Of oDlgQdo Pixel
	//"Relacionar um documento" ## "Visualizar documento relacionado" ## "Apagar documento relacionado"

	Define sButton From 055,090 Type 1 Enable Of oDlgQdo Action ( lGrava := .T., oDlgQdo:End() )
	Define sButton From 055,120 Type 2 Enable Of oDlgQdo Action ( lGrava := .F., oDlgQdo:End() )

	NGPOPUP(aSMenu,@oMenu)
	oDlgQdo:bRClicked := { |o,x,y| oMenu:Activate( x , y, oDlgQdo )}

	Activate MsDialog oDlgQdo Centered

	If !lGrava
		lRet := .F.
	Else
		If nRadio == 1
			If !MNT016RQDO( oModel )
				lRet := .F.
			EndIf

		ElseIf nRadio == 2

			If !MNT016VQDO( oModel )
				lRet := .F.
			EndIf
		Else
			oModel:GetModel('MNTA016_TPA'):LoadValue( 'TPA_DOCTO', Space(TAMSX3("TPA_DOCTO")[1]) )
			oModel:GetModel('MNTA016_TPA'):LoadValue( 'TPA_DOCFIL', Space(TAMSX3("TPA_DOCFIL")[1]) )
		EndIf
	EndIf

Return lRet

//---------------------------------------------------------------------
/*/{Protheus.doc} MNT016RQDO
Relaciona um procedimento à um documento QDO

@author Elisangela Costa
@since 13/10/2004
@version P11
@return lRet Lógico
/*/
//---------------------------------------------------------------------
Function MNT016RQDO( oModel )

	Local lRet := .F.

	lRet := ConPad1( ,,, "QDH",,, .F. )

	If lRet
		oModel:GetModel('MNTA016_TPA'):LoadValue( 'TPA_DOCTO', QDH->QDH_DOCTO )
		oModel:GetModel('MNTA016_TPA'):LoadValue( 'TPA_DOCFIL', QDH->QDH_FILIAL )
	EndIf

Return lRet

//---------------------------------------------------------------------
/*/{Protheus.doc} MNT016VQDO
Visualiza um documento QDO

@author Elisangela Costa
@since 13/10/2004
@version P11
@return lRet Lógico
/*/
//---------------------------------------------------------------------
Function MNT016VQDO( oModel )

	Local lRet := .F.

	If !Empty( oModel:GetModel('MNTA016_TPA'):GetValue('TPA_DOCTO') )
		If QDOVIEW( , oModel:GetModel('MNTA016_TPA'):GetValue('TPA_DOCTO') ) //Visualiza documentos Word
			lRet := .T.
		EndIf
	Else
		MsgInfo(STR0017,STR0018) //"Não existe documento associado à esta demanda." ## "NÃO CONFORMIDADE"
	EndIf

Return lRet

//---------------------------------------------------------------------
/*/{Protheus.doc} LinePost
Validação da linha do Grid

@param oModelGrid, objeto, modelo de dados da TPC
@param nLine, numerico, linha que está posicionado
@author Pedro Henrique Soares de Souza
@since 13/05/2014
@version 12
@return, Lógico, se linha está ok
/*/
//---------------------------------------------------------------------
Static Function LinePost( oModelGrid, nLine )

	Local lRet  := .T.

	M->TPC_OPCAO	:= FWFldGet('TPC_OPCAO')
	M->TPC_TIPCAM	:= FWFldGet('TPC_TIPCAM')
	M->TPC_TIPRES	:= FWFldGet('TPC_TIPRES')
	M->TPC_TPMANU	:= FWFldGet('TPC_TPMANU')
	M->TPC_SERVIC	:= FWFldGet('TPC_SERVIC')
	M->TPC_PORBEM	:= FWFldGet('TPC_PORBEM')
	M->TPC_DESCRI   := FWFldGet('TPC_DESCRI')
	M->TPC_FORMUL	:= FWFldGet('TPC_FORMUL')

	If M->TPA_OPCOES != '0' // 0=Nenhuma;1=Exclusiva;2=Múltiplas
		If !oModelGrid:IsDeleted(nLine)

			If Empty( M->TPC_OPCAO )
				Help(" ",1,"TPCOPCAOOB")
				lRet := .F.
			EndIf

			//-------------------------------------------------------------
			// O campo Serviço é obrigatório apenas para tipo O.S
			//-------------------------------------------------------------
			If lRet .And. M->TPC_TPMANU == '1' .And. ;
				( Empty( M->TPC_SERVIC ) .Or. Empty( M->TPC_PORBEM ) )
				Help(" ",1,"TPCSERVBEM")
				lRet := .F.
			EndIf

			//---------------------------------------------------------------
			// O campo 'Descrição' é obrigatório quando Gera Para Outro Bem
			//---------------------------------------------------------------
			If lRet .And. M->TPC_TPMANU != '0' .And. ;
				M->TPC_PORBEM == '2' .And. Empty( M->TPC_DESCRI ) // 1=Próprio Bem;2=Outro Bem
				Help(" ",1,"TPCBEMDESC")
				lRet := .F.
			EndIf

			If lRet .And. M->TPC_TIPRES == '2' // 1=Marcar;2=Informar

				If Empty( M->TPC_TIPCAM ) //C=Carater;D=Data;L=Logico;N=Numerico
					Help(" ",1,"TIPCAMINAV")
					lRet := .F.
				EndIf

				//Quando campo Tipo = "2-informar" e o Ação = "0-sem ação" não é necessário ter uma fórmula
				If lRet .And. ( Empty( M->TPC_FORMUL ) .And. !( M->TPC_TIPRES == "2" .And. M->TPC_TPMANU == "0" ) )
					Help(" ",1,"NGATENCAO",, STR0021, 1, 0) //"Infome o campo Fórmula!"
					lRet := .F.
				EndIf
			EndIf

		EndIf
	EndIf
Return lRet

//---------------------------------------------------------------------
/*/{Protheus.doc} ValServTPC
Consite o campo serviço da tabela TPC

@author Inacio Luiz Kolling
@since 27/04/2000
@version P11
@return lRet Lógico
/*/
//---------------------------------------------------------------------
Static Function ValServTPC( cTipMan, cServic )

	If cTipMan == '1'

		dbSelectArea("ST4")
		dbSetOrder(1)
		If !dbSeek(xFilial('ST4') + cServic)
			Help(" ",1,"SERVNAOEXI")
			lRet := .F.
		Else
			If NGFUNCRPO("NGSERVBLOQ", .F.) .And. !NGSERVBLOQ(cServic)
				lRet := .F.
			EndIf
		EndIf

		dbSelectArea("STE")
		dbSetOrder(1)
		If lRet .And. !dbSeek(xFilial('STE') + ST4->T4_TIPOMAN)
			Help(" ", 1, "TIPONAOEXIST")
			lRet := .F.
		EndIf

		If lRet .And. (cServic == GETNEWPAR("MV_NGSEREF") .Or. cServic == GETNEWPAR("MV_NGSECON"))

			MsgStop( STR0019 )	// "Para abertura e finalização de O.S. com o serviço
									// de Reforma ou Conserto de Pneus, conforme definido
									// nos parâmetros (MV_NGSEREF e MV_NGSECON), deve ser
									// utilizada a rotina MNTA720 - O.S. Em Lote."
			lRet := .F.
		EndIf

	ElseIf cTipMan $ '2'
		lRet := ExistCpo( "TQ3", cServic )
	EndIf

Return lRet

//---------------------------------------------------------------------
/*/{Protheus.doc} MNTA016VAL
Valid dos campos envolvidos na rotina MNTA016

@author Pedro Henrique Soares de Souza
@since 13/05/2014
@version P11
@return lRet Lógico
/*/
//---------------------------------------------------------------------
Function MNTA016VAL( cCampo )

	Local lRet      := .F.
	Local oModel    := FWModelActive()
	Local oModelTPC := oModel:GetModel( 'MNTA016_TPC' )

	Do Case
		Case ReadVar() == "M->TPA_ETAPA"
			lRet := ExistChav( "TPA", M->TPA_ETAPA )

		Case ReadVar() == "M->TPA_DESCRI"
			lRet := NaoVazio()

		Case ReadVar() == "M->TPA_DOCTO"
			lRet := ExistCpo( "QDH", M->TPA_DOCTO )

		Case ReadVar() == "M->TPA_CDAREA"
			lRet := If( Vazio(), .T., ExistCpo( "STD", M->TPA_CDAREA ))

		Case ReadVar() == "M->TPA_OPCOES"
			lRet := Pertence('012')

		Case ReadVar() == "M->TPA_TEMPOM"
			lRet := MNTA016TEM( M->TPA_TEMPOM )

		Case ReadVar() == "M->TPA_BLOQPT"
			lRet := Pertence('12')

		Case ReadVar() == "M->TPC_ETAPA"
			lRet := ExistCpo( 'TPA', M->TPA_ETAPA )

		Case ReadVar() == "M->TPC_OPCAO"
			lRet := ExistChav( 'TPC', M->TPA_ETAPA + M->TPC_OPCAO )

		Case ReadVar() == "M->TPC_TIPRES"

			lRet := Pertence('12')

			If oModelTPC:GetValue('TPC_TIPRES') == '1'
				If !oModelTPC:IsDeleted() .And. !Empty(oModelTPC:GetValue('TPC_OPCAO'))
					oModelTPC:LoadValue('TPC_TIPCAM', Space( TAMSX3( "TPC_TIPCAM" )[1]))
					oModelTPC:LoadValue('TPC_FORMUL', Space( TAMSX3( "TPC_FORMUL" )[1]))
					oModelTPC:LoadValue('TPC_TPMANU', '0' )
					oModelTPC:LoadValue('TPC_SERVIC', Space( TAMSX3( "TPC_SERVIC" )[1]))
					oModelTPC:LoadValue('TPC_PORBEM', '1' )
					oModelTPC:LoadValue('TPC_DESCRI', Space( TAMSX3( "TPC_TIPCAM" )[1]))
				EndIf
			EndIf

		Case ReadVar() == "M->TPC_TIPCAM"

			lRet := Pertence( 'CDLN' ) .And. ( IIf( !Empty( FWFldGet( 'TPC_FORMUL' ) ), ValForm016(), .T. ) )

		Case ReadVar() == "M->TPC_TPMANU"
			lRet := Pertence('012')

			oModelTPC:LoadValue( 'TPC_SERVIC', Space( TAMSX3('TPC_SERVIC')[1] ) )

		Case ReadVar() == "M->TPC_SERVIC"
			lRet := ValServTPC( oModelTPC:GetValue('TPC_TPMANU'), M->TPC_SERVIC )

		Case ReadVar() == "M->TPC_PORBEM"
			lRet := Pertence('12')

			oModelTPC:LoadValue( 'TPC_DESCRI', Space( TAMSX3('TPC_DESCRI')[1] ) )

		Case ReadVar() == "M->TPC_DESCRI"
			lRet := ExistCpo( 'ST9', M->TPC_DESCRI )

		Case ReadVar() == "M->TPC_PERCEN"
			lRet := Positivo()

		Case ReadVar() == "M->TPC_FORMUL"
			lRet := ValForm016()

		OtherWise
			lRet := .T.
	EndCase

Return lRet

//---------------------------------------------------------------------
/*/{Protheus.doc} MNTA016WHN
When dos campos envolvidos na rotina MNTA016

@author Pedro Henrique Soares de Souza
@since 20/05/2014
@version P11
@return lRet Lógico
/*/
//---------------------------------------------------------------------
Function MNTA016WHN( cCampo )

	Local lRet      := .F.
	Local oModel    := FWModelActive()
	Local oModelTPC := oModel:GetModel( 'MNTA016_TPC' )

	Do Case
		Case ReadVar() $ "M->TPC_TIPCAM/M->TPC_FORMUL"
			lRet := oModelTPC:GetValue('TPC_TIPRES') != '1'

		Case ReadVar() $ "M->TPC_SERVIC/M->TPC_PORBEM"
			lRet := oModelTPC:GetValue('TPC_TPMANU') != '0'

		Case ReadVar() $ "M->TPC_DESCRI"
			lRet := oModelTPC:GetValue('TPC_PORBEM') == '2'

		Case ReadVar() $ "M->TPC_PERCEN/M->TPC_OBSERV"
			lRet := oModelTPC:GetValue('TPC_TIPRES') == '2'

		OtherWise
			lRet := .T.
	EndCase

Return lRet

//---------------------------------------------------------------------
/*/{Protheus.doc} MNTFORTPC
Exibe tela para criação da Fórmula do campo TPC_FORMUL

@author Pedro Henrique Soares de Souza
@since 20/05/2014
@version P11
@return .T. Verdadeiro
/*/
//---------------------------------------------------------------------
Function MNTFORTPC()

	Local lOk		:= .F.
	Local oModel	:= FWModelActive()
	Local cExpres := Space(10)

	Local aCmbLog, aCmbOp
	Local cOldForm, cCmbLog, cCmbOp
	Local oDlg, oFont, oGetVal, oPanel

	//Variável utilizada para armazenas operações do usuário. Utilizada na opção "remover".
	Private aForm016 := {}

	cNewForm := FWFldGet('TPC_FORMUL')		//Carrega fórmula conforme memória do campo
	aForm016 := { FWFldGet('TPC_FORMUL') }	//Carrega fórmula como primeira operação do usuário

	If !Empty( FWFldGet('TPC_TIPCAM') )

		//Armazena fórmula antiga para recuperar se a tela não for confirmada
		cOldForm := cNewForm

		Define MsDialog oDlg Title OemToAnsi( STR0020 ) From 000,000 TO 250,400 Pixel COLOR CLR_BLACK,CLR_WHITE //"Fórmulas"

		//---------------------------------------------------------------------
		// Inicializa variáveis para criação dos objetos.
		//---------------------------------------------------------------------
		oPanel := TPanel():New( 0, 0,, oDlg,,,,,,,, .F., .F.)
		oPanel:Align := CONTROL_ALIGN_ALLCLIENT

		//Fonte padrão
		oFont := TFont():New( 'Arial',, 14, .T. )

		//Combo utilizada quando o tipo de campo for 'Lógico'
		aCmbLog	:= StrTokArr ( STR0022, ';' ) //"1=Verdadeiro;2=Falso"

		//Combo utilizada para indicar o operador da fórmula
		aCmbOp  := IIf( FWFldGet('TPC_TIPCAM') $ 'L/C',;
							StrTokArr( STR0023, ';' ) ,;	//"1=Igual;2=Diferente"
							StrTokArr( STR0024, ';' ))		//"1=Igual;2=Menor;3=Maior;4=Menor ou Igual;5=Maior ou Igual;6=Diferente"

		//Indica opção inicial da compo.
		cCmbOp  := aCmbOp[1]

		//---------------------------------------------------------------------
		// Criação dos objetos, botões e helps para tela de fórmulas
		//---------------------------------------------------------------------

		//Combo com operadores de comparação
		@ 005,005 MsComboBox oCmbOp VAR cCmbOp ITEMS aCmbOp SIZE 065, 012 OF oPanel COLORS 0, 16777215 PIXEL
		tMultiGet():New( 70, 05, {|u| IIf( PCount() > 0, cNewForm := u, cNewForm ) }, oDlg, 190, 40, , , , , , .T. ,,,{|| .F.})

		//Se o tipo do campo for lógico exibe combo com as opções ".T." e ".F."
		If FWFldGet('TPC_TIPCAM') $ 'L'
			@ 005,073 MsComboBox oGetVal VAR cCmbLog ITEMS aCmbLog SIZE 065, 012 OF oPanel COLORS 0, 16777215 PIXEL
		Else
			@ 005,073 MsGet oGetVal VAR cExpres SIZE 64,09 OF oPanel PIXEL PICTURE LoadPict() VALID ValTipCam(cExpres)
		EndIf

		//Botões de ação: Adiciona, Limpa e Desfaz
		TButton():New( 05, 140, STR0025, oPanel, {|| FormAction(1, cCmbOp, cCmbLog, cExpres) }, 55, 12,, oFont, .F., .T., .F.,, .F.,,, .F. ) //"Adicionar"
		TButton():New( 20, 005, STR0026, oPanel, {|| FormAction(2) }, 65, 13,, oFont, .F., .T., .F.,, .F.,,, .F. ) //"Limpar"
		TButton():New( 20, 073, STR0027, oPanel, {|| FormAction(3) }, 63, 13,, oFont, .F., .T., .F.,, .F.,,, .F. ) //"Remover"

		//Botões de operadores lógicos '(', ')', '.And.' e '.Or.'
		TButton():New( 20, 140, "("    , oPanel, {|| AddFormula('(')}, 12, 13,, oFont, .F., .T., .F.,, .F.,,, .F. )
		TButton():New( 20, 154, ")"    , oPanel, {|| AddFormula(')')}, 12, 13,, oFont, .F., .T., .F.,, .F.,,, .F. )
		TButton():New( 20, 168, STR0028, oPanel, {|| AddFormula('E')}, 12, 13,, oFont, .F., .T., .F.,, .F.,,, .F. ) //"E"
		TButton():New( 20, 182, STR0029, oPanel, {|| AddFormula('O')}, 13, 13,, oFont, .F., .T., .F.,, .F.,,, .F. )	//"OU"

		// Help dos campos 'Operador' e 'Expressão'
		oCmbOp:bHelp := {|| ShowHelpCpo( STR0030, { STR0031 }, 5, {}, 2)} //"Operação" ## "Indica a operação a ser utilizada na fórmula"
		oGetVal:bHelp := {|| ShowHelpCpo( STR0032, { STR0033 }, 5, {}, 2)} //"Expressão" ## "Indica o valor para comparação"

		Activate MSDIALOG oDlg On Init EnchoiceBar(oDlg, {|| lOk := .T., IIf( ValForm016( , Trim( cNewForm ) ), oDlg:End(), lOk := .F.) }, {|| lOk := .F., oDlg:End()}) Centered

		If !lOk
			cNewForm := cOldForm
		EndIf
	Else
		Help(" ",1,"Help", "NGATENCAO", STR0034, 1, 0) //"Infome o campo 'Tipo Resp.'!"
	EndIf

Return .T.

//---------------------------------------------------------------------
/*/{Protheus.doc} AddFormula
Inclusão de 'Abre'/'Fecha' Parêntese/'AND'/'OR'

@author Pedro Henrique Soares de Souza
@since 20/05/2014
@version P11
@param cBtn Indica a opção inclusa ('Abre'/'Fecha' Parêntese/'AND'/'OR' )
@return Nil Nulo
/*/
//---------------------------------------------------------------------
Static Function AddFormula(cBtn)

	Local cValue

	Do Case
		Case cBtn == '('
			cValue := '('
		Case cBtn == ')'
			cValue := ')'
		Case cBtn == 'E'
			cValue := ' .And. '
		Case cBtn == 'O'
			cValue := ' .Or. '
	EndCase

	cNewForm	:= AllTrim(cNewForm) + cValue

	//Adiciona valor ao array de operação do usuário
	aAdd(aForm016, AllTrim(cValue))
Return Nil

//---------------------------------------------------------------------
/*/{Protheus.doc} LoadPict
Carrega picture dos campos conforme o 'Tipo de Resposta'

@author Pedro Henrique Soares de Souza
@since 30/05/2014
@version P11
@return cPicture
/*/
//---------------------------------------------------------------------
Static Function LoadPict()

	Local cPicture

	Do Case
		Case FWFldGet('TPC_TIPCAM') $ 'N'
			cPicture := '@E'

		Case FWFldGet('TPC_TIPCAM') $ 'C'
			cPicture := '@!'

		Case FWFldGet('TPC_TIPCAM') == 'D'
			cPicture := '99/99/9999'

		Case FWFldGet('TPC_TIPCAM') == 'L'
			cPicture := '@L'
	EndCase

Return cPicture

//---------------------------------------------------------------------
/*/{Protheus.doc} ValTipCam
Valida tipo do campo

@author Pedro Henrique Soares de Souza
@since 30/05/2014
@version P11
@return lRet
/*/
//---------------------------------------------------------------------
Static Function ValTipCam(cCampo)
Return IIf( Empty( cCampo ), .T., NGTPCONTCAR( FWFldGet('TPC_TIPCAM'), AllTrim(cCampo)) )

//---------------------------------------------------------------------
/*/{Protheus.doc} ValForm016
Verifica se a fórmula inserida é válida.
@type function

@author Pedro Henrique Soares de Souza
@since 20/05/2014

@param lHelp   , boolean, Indica se exibe ou não mensagem de help
@param cForm   , string , Contúedo atual definido como formula.
@return boolean, Define se a formula é valida.
/*/
//---------------------------------------------------------------------
Static Function ValForm016( lHelp, cForm )

	Local cData := cToD( '' )
	Local lRet  := .T.

	Default lHelp := .T.
	Default cForm := Trim( FWFldGet('TPC_FORMUL') )

	If !Empty(cForm)
		If !(Len(cForm) > TAMSX3("TPC_FORMUL")[1])
				Do Case
					Case FWFldGet('TPC_TIPCAM') == 'L'
						cForm := StrTran( cForm, '#RESP#', '.T.' )
					Case FWFldGet('TPC_TIPCAM') == 'N'
						cForm := StrTran( cForm, '#RESP#', '0' )
					Case FWFldGet('TPC_TIPCAM') == 'D'
						cData := "'" + DToS( dDataBase ) + "'"
						cForm := StrTran( cForm, '#RESP#', cData )
					Case FWFldGet('TPC_TIPCAM') == 'C'
						cForm := StrTran( cForm, '#RESP#', "'NG'" )
				EndCase

				lRet := ( Type( '&cForm' ) == 'L' )

				If !lRet .And. lHelp
					ShowHelpDlg( "TPC_FORMUL", { STR0035 }, 5,;	//"A fórmula inserida não é válida."
									{ STR0036 }, 5)					//"Verifique a fórmula novamente e certifique-se de que não há inconsistências."
			EndIf
		Else
			If lHelp
					ShowHelpDlg( "TPC_FORMUL", { STR0037 }, 5,;	//"O tamanho da fórmula ultrapassou o limite de caracteres."
									{ STR0038 }, 5) 					//"Utilize uma fórmula de até 80 caracteres!"
				lRet := .F.
			EndIf
		EndIf
	Else
		lRet := .F.
	EndIf

Return lRet

//---------------------------------------------------------------------
/*/{Protheus.doc} FormAction
Ação dos botões 'Adicionar', 'Limpar' e 'Remover'

@author Pedro Henrique Soares de Souza
@since 30/05/2014
@version P11
@param nOpc 1 - Indica a ação adicionar
        nOpc 2 - Indica a ação limpar
        nOpc 3 - Indica a ação remover
@param cOp - Indica a operação a ser adicionada
@return Nil Nulo
/*/
//---------------------------------------------------------------------
Static Function FormAction(nOpc, cCmbOp, cCmbLog, cExpres)

	Local nPosDel
	Local cOp, cValue
	Local cMemoFor := AllTrim(cNewForm)

	If nOpc == 1
		If Empty(cCmbLog) .And. Empty(cExpres)
			ShowHelpDlg( "TPC_FORMUL", { STR0039 }, 5,;	//"A expressão não foi informada."
							{ STR0040 }, 5)					//"Informe uma expressão válida!"

		Else
			If FWFldGet('TPC_TIPCAM') $ 'L/C'
				cOp := IIf( cCmbOp == '1', ' == ', ' <> ')

				If FWFldGet('TPC_TIPCAM') == 'C'
					cValue   := IIf( Empty(cNewForm), '#RESP# ', ' #RESP# ') + cOp
					cValue   += "'" + AllTrim( cExpres ) + "'"
					cMemoFor += cValue
				Else
					cValue := IIf( Empty(cNewForm), '#RESP# ', ' #RESP# ') + cOp
					cValue += IIf( cCmbLog == '1', '.T.', '.F.'  )
					cMemoFor := LTrim( cMemoFor ) + cValue
				EndIf

			Else
				Do Case
				Case cCmbOp == '1'
					cOp := ' == '
				Case cCmbOp == '2'
					cOp := ' < '
				Case cCmbOp == '3'
					cOp := ' > '
				Case cCmbOp == '4'
					cOp := ' <= '
				Case cCmbOp == '5'
					cOp := ' >= '
				Case cCmbOp == '6'
					cOp := ' <> '
				EndCase

				cValue := IIf( Empty(cNewForm), '#RESP# ', ' #RESP# ') + cOp

				If FWFldGet('TPC_TIPCAM') == 'N'
					cValue += AllTrim( cExpres )
				ElseIf FWFldGet('TPC_TIPCAM') == 'D'
					cValue += "'" + DToS( CToD( AllTrim( cExpres ) ) ) + "'"
				EndIf

				cMemoFor += cValue

				cExpres := Space(10)
			EndIf
			cNewForm := cMemoFor
			//Adiciona valor ao array de operação do usuário
			aAdd(aForm016, AllTrim(cValue))
		EndIf
	ElseIf nOpc == 2

		cNewForm := ""	//Limpa a fórmula
		aForm016 := {""}	//Limpa o array de operações
	Else
		If !Empty( cNewForm ) .And. Len( aForm016 ) > 1

			nPosDel	:= RAt( ATail(aForm016), cNewForm)		//Procura último local onde a última operação foi utilizada
			cNewForm	:= SubStr( cNewForm, 0, nPosDel - 1 )	//Remove a última operação do usuário

			aDel( aForm016 , Len( aForm016 ) )			//Deleta do array a opção removida pelo usuário
			aSize( aForm016 , Len( aForm016 ) - 1 )	//Redimensiona array para o novo tamanho

		EndIf
	EndIf
Return Nil

//---------------------------------------------------------------------
/*/{Protheus.doc} MNTTPCF3
Responsável pelo F3 do campo serviço. Alterna de acordo com o campo
tipo de manutenção.

@author Pedro Henrique Soares de Souza
@since 30/05/2014
@version P11
@return Nil Nulo
/*/
//---------------------------------------------------------------------
Function MNTTPCF3()
	Local lRet

	If FwFldGet( 'TPC_TPMANU' ) == '1'
		lRet := ConPad1( ,,, 'ST4',,, .F. )

		If lRet
			cRetF3 := ST4->T4_SERVICO
		EndIf
	Else
		lRet := ConPad1( ,,, 'TQ3',,, .F. )

		If lRet
			cRetF3 := TQ3->TQ3_CDSERV
		EndIf
	EndIf
Return lRet


//---------------------------------------------------------------------
/*/{Protheus.doc} MNTTPCRET
Responsável pelo retorno do F3 do campo serviço (Função MNTTPCF3)

@author Pedro Henrique Soares de Souza
@since 30/05/2014
@version P11
@return Nil Nulo
/*/
//---------------------------------------------------------------------
Function MNTTPCRET()
Return IIf( Type('cRetF3') != 'U', cRetF3, Space( TAMSX3('TPC_SERVIC')[1] ) )

//---------------------------------------------------------------------
/*/{Protheus.doc} MNTRETFOR
Responsável pelo retorno do F3 do campo fórmula (Função MNTFORTPC)

@author Pedro Henrique Soares de Souza
@since 20/05/2014
@version P11
@return .T. True
/*/
//---------------------------------------------------------------------
Function MNTRETFOR()

	Local cRetForm := ''

	// Repassa novo conteúdo da formula para retorno da consulta padrão.
	cRetForm := IIf( Type( 'cNewForm' ) != 'U', cNewForm, Space( TAMSX3( 'TPC_FORMUL' )[1] ) )

	// Limpa variavel de controle da fórmula.
	cNewForm := Space( TAMSX3( 'TPC_FORMUL' )[1] )

Return cRetForm


//---------------------------------------------------------------------
/*/{Protheus.doc} MNTA016TEM
Consistencia do tempo de servico

@author Rodrigo Luan Backes
@since 13/08/2015
@version 1.0
@return lRet
/*/
//---------------------------------------------------------------------
Function MNTA016TEM(cVHora)

	Local nHora, nMinuto, nSegundo, nPos, nPos2, nh, nm, ns
	Local cHora, cMinuto, cSegundo, cCaracHor, cCaracMin, cCaracSeg
	Local cAuxStr := ""
	Local lRet := .T.

	If (nPos := At(":",cVHora)) == 0
		lRet := .F.
	Else
		cHora   := SubStr(cVHora,1,(nPos-1))
		cMinuto := SubStr(cVHora,(nPos+1),2)
		cAuxStr := SubStr(cVHora,(nPos+1))
		nPos2    := AT(":",cAuxStr)
		cSegundo := If(nPos2 > 0, SubStr(cAuxStr,(nPos2+1),2), "00")
		If Empty(cHora) .Or. Empty(cMinuto) .Or. Empty(cSegundo) .Or. Len(Alltrim(cMinuto)) < 2 .Or. Len(AllTrim(cSegundo)) < 2
			lRet := .F.
		Else
			For nh := 1 To Len(cHora)
				cCaracHor := Substr(cHora,nh,1)
				If Empty(cCaracHor) .Or. !Isdigit(cCaracHor)
					lRet := .F.
					Exit
				Endif
			Next nh
			If lRet
				For nm := 1 To Len(cMinuto)
					cCaracMin := Substr(cMinuto,nm,1)
					If Empty(cCaracMin) .Or. !Isdigit(cCaracMin)
						lRet := .F.
						Exit
					Endif
				Next nm
			Endif
			If lRet
				For ns := 1 To Len(cSegundo)
					cCaracSeg := Substr(cSegundo,ns,1)
					If Empty(cCaracSeg) .Or. !Isdigit(cCaracSeg)
						lRet := .F.
						Exit
					Endif
				Next ns
			EndIf

			If lRet
				nHora    := Val(cHora)
				nMinuto  := Val(cMinuto)
				nSegundo := Val(cSegundo)
				If nMinuto > 59 .Or. nSegundo > 59 .Or. (nHora == 0 .And. nMinuto == 0 .And. nSegundo == 0)
					lRet := .F.
				Endif
			Endif
		Endif
	Endif

	If !lRet
		Help(" ",1,"HORAINVALI") //ShowHelpDlg(STR0040,{STR0074},2,{STR0075},2) // "ATENCAO" ## "S.S. não possui tempo de atendimento reportado." ## "Favor realizar o Reporte de Horas para a S.S."
	Endif

Return lRet
