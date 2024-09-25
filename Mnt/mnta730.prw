#INCLUDE "MNTA730.ch"
#INCLUDE "PROTHEUS.CH"
#INCLUDE "FWMVCDEF.CH"

//---------------------------------------------------------------------
/*/{Protheus.doc} MNT730
Programa de cadastro de Check List Padrao

@return
@sample MNT730()
@author Vitor Emanuel Batista
@since 10/11/2008
@version 1.0
/*/
//---------------------------------------------------------------------
Function MNTA730()

	Local aNGBEGINPRM := NGBEGINPRM() //Guarda conteudo e declara variaveis padroes
	Local oBrowse

	If !FindFunction( 'MNTAmIIn' ) .Or. MNTAmIIn( 19, 95 )

		Private lCORRET := .T. //Variavel para  filtrar apenas Serviço corretivos na consulta SX3 'ST3' ( não retirar )

		oBrowse	:= FWMBrowse():New()
		oBrowse:SetAlias("TTD")
		oBrowse:SetMenuDef("MNTA730")
		oBrowse:SetDescription(STR0001) //"Cadastro de Check List padrão"
		oBrowse:Activate()

	EndIf

	NGRETURNPRM(aNGBEGINPRM)//Retorna conteudo de variaveis padroes

Return

//---------------------------------------------------------------------
/*/{Protheus.doc} MenuDef
Opções de menu

@author Rodrigo Luan Backes
@since 31/07/2015
@version P12
@return aRotina - Cadastro de Check List padrão
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

	Local aRotina := FWMVCMenu( 'MNTA730' )

	ADD OPTION aRotina Title STR0011 Action 'MNTR205(TTD->TTD_CODFAM,TTD->TTD_TIPMOD,TTD->TTD_SEQFAM)' OPERATION 8 ACCESS 0   //'Imprimir Retorno'

Return aRotina

//---------------------------------------------------------------------
/*/{Protheus.doc} ModelDef
Regras de modelagem da gravação

@author Rodrigo Luan Backes
@since 30/07/2015
@version P12
@return oModel
/*/
//---------------------------------------------------------------------
Static Function ModelDef()

	// Cria a estrutura a ser usada no Modelo de Dados
	Local oStructTTD := FWFormStruct( 1, "TTD", /*bAvalCampo*/, /*lViewUsado*/)
	Local oStructTTE := FWFormStruct( 1, "TTE", /*bAvalCampo*/, /*lViewUsado*/)
	Local oModel

	//Remove o campo repetido em tela
	oStructTTE:RemoveField("TTE_SEQFAM")
	oStructTTE:RemoveField("TTE_CODFAM")
	oStructTTE:RemoveField("TTE_TIPMOD")

	// Cria o objeto do Modelo de Dados
	oModel := MPFormModel():New( "MNTA730", /*{|oModel| PreValida(oModel) }*/, /*{|oModel| ValidInfo(oModel)}*/, /*{|oModel| CommitInfo(oModel) }*/, /*bCancel*/ )

	// Adiciona ao modelo uma estrutura de formulário de edição por campo
	oModel:AddFields( "MNTA730_TTD", Nil, oStructTTD,/*bPre*/,/*bPost*/,/*bLoad*/)

	// Adiciona ao modelo uma estrutura de formulário de edição por grid
	oModel:AddGrid( 'MNTA730_TTE', 'MNTA730_TTD', oStructTTE, /*bLinePre*/, { |oModel| fLinePos( ) } , /*bPreVal*/, /*bPosVal*/, /*BLoad*/ )

	// Faz relaciomaneto entre os compomentes do model
	oModel:SetRelation( 'MNTA730_TTE', { { 'TTE_FILIAL', 'xFilial( "TTE" )' }, ;
										 { 'TTE_CODFAM', 'TTD_CODFAM' },;
										 { "TTE_TIPMOD", "TTD_TIPMOD" },;
										 { "TTE_SEQFAM", "TTD_SEQFAM" } }, TTE->( IndexKey(1) ) )

	// Liga o controle de nao repeticao de linha
	oModel:GetModel( 'MNTA730_TTE' ):SetUniqueLine( { 'TTE_ETAPA' } )

	// Indica que é opcional ter dados informados na Grid
	oModel:GetModel( 'MNTA730_TTE' ):SetOptional(.T.)

	oModel:SetPrimaryKey( { "TTD_FILIAL", "TTD_CODFAM" , "TTD_TIPMOD" , "TTD_SEQFAM" } ) //TTD_FILIAL+TTD_CODFAM+TTD_TIPMOD+TTD_SEQFAM

	// Adiciona a descricao do Modelo de Dados
	oModel:SetDescription( STR0001 ) // "Cadastro de Check List Padrão"

Return oModel

//---------------------------------------------------------------------
/*/{Protheus.doc} ViewDef
Regras de Interface com o Usuário

@author Rodrigo Luan Backes
@since 30/07/2015
@version P12
@return oView
/*/
//---------------------------------------------------------------------
Static Function ViewDef()

	// Cria um objeto de Modelo de Dados baseado no ModelDef do fonte informado
	Local oModel		:= FWLoadModel( "MNTA730" )

	// Cria a estrutura a ser usada na View
	Local oStructTTE	:= FWFormStruct( 2, 'TTE' )

	// Cria o objeto de View
	Local oView		:= FWFormView():New()

	// Objeto do model a se associar a view.
	oView:SetModel(oModel)

	//Remove o campo repetido em tela
	oStructTTE:RemoveField("TTE_SEQFAM")
	oStructTTE:RemoveField("TTE_CODFAM")
	oStructTTE:RemoveField("TTE_TIPMOD")

	//Adiciona no nosso View um controle do tipo FormFields(antiga enchoice)
	oView:AddField( "MNTA730_TTD", FWFormStruct( 2, "TTD" ), /*cLinkID*/ )

	//Adiciona no nosso View um controle do tipo FormGrid(antiga newgetdados)
	oView:AddGrid( 'MNTA730_TTE', oStructTTE, 'MNTA730_TTE' )

	// Criar um "box" horizontal para receber algum elemento da view
	oView:CreateHorizontalBox( 'SUPERIOR', 40,/*cIDOwner*/,/*lFixPixel*/,/*cIDFolder*/,/*cIDSheet*/ )
	oView:CreateHorizontalBox( 'INFERIOR', 60,/*cIDOwner*/,/*lFixPixel*/,/*cIDFolder*/,/*cIDSheet*/ )

	// Relaciona o ID da View com o "box" para exibicao
	oView:SetOwnerView( "MNTA730_TTD", "SUPERIOR" )
	oView:SetOwnerView( "MNTA730_TTE", "INFERIOR" )

	//Inclusão de itens no Ações Relacionadas de acordo com o NGRightClick
	NGMVCUserBtn(oView)

Return oView

//---------------------------------------------------------------------
/*/{Protheus.doc} fLinePos
Consiste Linha

@author Vitor Emanuel Batista
@since 10/11/2008
@version 12
@return boolean
/*/
//---------------------------------------------------------------------
Static Function fLinePos()

	Local oModel := FWModelActive()
	Local oGrid  := oModel:GetModel( 'MNTA730_TTE' ) // Posiciona no Model da Grid
	Local lRet   := .T.

	//------------------------------------------------------------------
	// Obrigatoriedade do campo Serviço quando selecionado para gerar OS
	//------------------------------------------------------------------
	If Empty( oGrid:GetValue("TTE_SERVIC") ) .And. ( oGrid:GetValue("TTE_ALTA") == 'O'.Or. ;
		oGrid:GetValue("TTE_MEDIA") == 'O' .Or. oGrid:GetValue("TTE_BAIXA") == 'O' )

		Help( " ", 1, STR0003,, STR0004, 2, 1 )// "Atenção" // "O campo Serviço deve ser preenchido se o evento de uma das criticidades for Gerar OS"
	   	lRet := .F.
	EndIf

Return lRet

//---------------------------------------------------------------------
/*/{Protheus.doc} MNT730CHKSER
Consite campo servico

@return .T.
@sample MNT730CHKSER()
@author Vitor Emanuel Batista
@since 25/11/2008
@version 1.0
/*/
//---------------------------------------------------------------------
Function MNT730CHKSER()
	Local cSerefor  := Alltrim(SuperGetMv( 'MV_NGSEREF', .F., ' '))
	Local aServRef  := StrTokArr( cSerefor, ';' ) 
	Local cSercons  := Alltrim(SuperGetMv( 'MV_NGSECON', .F., ' '))
	Local aServCon := StrTokArr( cSercons, ';' ) 
	Local oModel 	:= FWModelActive()
	Local oGrid  	:= oModel:GetModel( 'MNTA730_TTE' ) // Posiciona no Model da Grid
	Local cServico	:= oGrid:GetValue("TTE_SERVIC")

	If !ST4->(dbSeek(xFilial('ST4') + cServico))
	   Help(" ",1,"SERVICONAOEXIST")
	   Return .F.
	Else
	   If NGFUNCRPO("NGSERVBLOQ",.F.) .And. !NGSERVBLOQ(cServico)
	      Return .f.
	   EndIf
	EndIf

	If !STE->(dbSeek(xFilial('STE') + ST4->T4_TIPOMAN))
	   Help(" ",1,"TIPONAOEXIST")
	   Return .F.
	EndIf

	If STE->TE_CARACTE != "C"
		Help(" ",1,"SERVNAOCORRET")
		Return .F.
	EndIf

	If aScan(aServRef, {|x| x == AllTrim(cServico)}) > 0 .OR. aScan(aServCon, {|x| x == AllTrim(cServico)}) > 0
		//------------------------------------------------------------------------------------------------------------------------
		// "Para abertura e finalização de O.S. com o serviço de Reforma ou Conserto de Pneus,
		// conforme definido nos parâmetros (MV_NGSEREF e MV_NGSECON), deve ser utilizada a rotina MNTA720 - O.S. Em Lote."
		//------------------------------------------------------------------------------------------------------------------------
		MsgStop(STR0013)
		Return .F.
	EndIf

Return .T.

//---------------------------------------------------------------------
/*/{Protheus.doc} MNT730SEQ
Funcao para incrementar a sequencia do check list.

@obs essa função é acionada no valid dos campos 'TTD_TIPMOD' e 'TTD_CODFAM'
e somente na inclusão pois esses campos não podem ser alterados
@return .T.
@sample MNT730SEQ()
@author Vitor Emanuel Batista
@since 19/03/2012
@version 1.0
/*/
//---------------------------------------------------------------------
Function MNT730SEQ()

	Local aArea		:= GetArea()
	Local aAreaTTD	:= TTD->( GetArea() )
	Local cSeq		:= ""
	Local oModel	:= FWModelActive()
	Local cTipMod	:= oModel:GetValue( 'MNTA730_TTD', 'TTD_TIPMOD' )
	Local cCodFam	:= oModel:GetValue( 'MNTA730_TTD', 'TTD_CODFAM' )

	If NGIFDBSEEK("TTD",cCodFam+cTipMod,1)
		cSEQ := TTD->TTD_SEQFAM

		While !Eof() .And. TTD->TTD_FILIAL == xFILIAL("TTD") .And.;
			TTD->TTD_CODFAM == cCodFam .And. TTD->TTD_TIPMOD == cTipMod

			If TTD->TTD_SEQFAM > cSEQ
				cSEQ := TTD->TTD_SEQFAM
			Endif
			Dbskip()
		End
	EndIf

	oModel:LoadValue('MNTA730_TTD', 'TTD_SEQFAM', IIf( Empty( cSEQ ), "001", Soma1Old( cSEQ ) ))

	RestArea( aArea )
	RestArea( aAreaTTD )

Return .T.

//----------------------------------------------------------------
/*/{Protheus.doc} MNTA730GAT()
Executa gatilhos específicos.
@type function

@author Wexlei Silveira
@since	06/04/2020
@version P12.1.33

@param cCampo, Caractere, Nome do campo

@return Caractere, Descrição do campo
/*/
//----------------------------------------------------------------
Function MNTA730GAT(cCampo)

	Local cDesc		:= ''
	Local oModel	:= FWModelActive()
	Local cTipMod	:= oModel:GetValue( 'MNTA730_TTD', 'TTD_TIPMOD' )

	If cCampo == 'TTD_TIPMOD'

		// A partir do release 12.1.33, o valor '*' torna-se válido e indica que a
		// regra aplica-se à todos os tipos modelos existentes
		If Trim(cTipMod) == '*'
			cDesc := STR0015 // TODOS
		Else
			cDesc := Posicione('TQR', 1, xFilial('TQR') + cTipMod, 'TQR_DESMOD')
		EndIf

	EndIf

Return cDesc

//----------------------------------------------------------------
/*/{Protheus.doc} MNTA730VLD()
Validação de campos.
@type function

@author Wexlei Silveira
@since	13/04/2020
@version P12.1.33

@param cCampo, Caractere, Nome do campo a ser validado

@return Lógico, verdadeiro se informações corretas
/*/
//----------------------------------------------------------------
Function MNTA730VLD(cCampo)

	Local lRet		:= .T.
	Local oModel	:= FWModelActive()
	Local cTipMod	:= oModel:GetValue( 'MNTA730_TTD', 'TTD_TIPMOD' )

	If cCampo == 'TTD_TIPMOD'

		// A partir do release 12.1.33, o valor '*' torna-se válido e indica que a
		// regra aplica-se à todos os tipos modelos existentes
		If Trim( cTipMod ) != '*' .And. !EXISTCPO( 'TQR', cTipMod, 1 )
			lRet := .F.
		EndIf

	EndIf

Return lRet

//----------------------------------------------------------------
/*/{Protheus.doc} MNTA730INI()
Inicializador padrão para a descrição de campos.
@type function

@author Wexlei Silveira
@since	13/04/2020
@version P12.1.33

@param cCampo, Caractere, Nome do campo

@return Caractere, Descrição do campo
/*/
//----------------------------------------------------------------
Function MNTA730INI(cCampo)

	Local cDesc		:= ''
	Local oModel	:= FWModelActive()
	Local cTipMod	:= oModel:GetValue( 'MNTA730_TTD', 'TTD_TIPMOD' )

	If cCampo == 'TTD_DESMOD'

		// A partir do release 12.1.33, o valor '*' torna-se válido e indica que a
		// regra aplica-se à todos os tipos modelos existentes
		If Trim( cTipMod ) == '*'
			cDesc := STR0015 // TODOS
		Else
			cDesc := Posicione( 'TQR', 1, xFilial( 'TQR' ) + cTipMod, 'TQR_DESMOD' )
		EndIf

	EndIf

Return cDesc

//----------------------------------------------------------------
/*/{Protheus.doc} MNTA730BRW(cCampo)
Inicializador do browse para a descrição de campos.
@type function

@author Wexlei Silveira
@since	13/04/2020
@version P12.1.33

@param cCampo, Caractere, Nome do campo

@return Caractere, Descrição do campo
/*/
//----------------------------------------------------------------
Function MNTA730BRW(cCampo)

	Local cDesc := ''

	If cCampo == 'TTD_DESMOD'

		// A partir do release 12.1.33, o valor '*' torna-se válido e indica que a
		// regra aplica-se à todos os tipos modelos existentes
		If Trim(TTD->TTD_TIPMOD) == '*'
			cDesc := STR0015 // TODOS
		Else
			cDesc := Posicione( 'TQR', 1, xFilial( 'TQR' ) + TTD->TTD_TIPMOD, 'TQR_DESMOD' )
		EndIf

	EndIf

Return cDesc
