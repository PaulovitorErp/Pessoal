#INCLUDE 'MNTA612.CH'
#INCLUDE 'TOTVS.CH'
#INCLUDE 'FWMVCDEF.CH'

//---------------------------------------------------------------------
/*/{Protheus.doc} MNTA612
Cadastro de Preços

@type function
@author cristiano.kair
@since 01/10/2021

@param lOpenView, Lógico, usado para abrir a View diretamente

@return Nil
/*/
//---------------------------------------------------------------------
Function MNTA612( lOpenView )

	Local oBrowse
	Local lReturn := .T.

	Default lOpenView := .F.

	If TQF->TQF_TIPPOS == '3'

		Help( '', 1, STR0002, , STR0003, 1, 0 )  //'ATENÇÃO'###'Posto não conveniado!'
		lReturn := .F.
		
	EndIf

	If lReturn .And. TQF->TQF_ATIVO == '2'

		Help( ' ', 1, STR0002,, STR0019, 1, 0 ,,,,,, {STR0020}  ) //'ATENÇÃO'###'Posto esta Desativado.'###'Ative o Posto para realizar cadastro de Negociação ou Preço.'
		
		lReturn := .F.

	EndIf

	If lReturn

		//VERIFICA SE TEM NEGOCIACAO PARA PODER INCLUIR PRECO
		dbSelectArea( 'TQG' )
		dbSetOrder(1)
		If !dbSeek(xFilial( 'TQG' ) + TQF->TQF_CODIGO + TQF->TQF_LOJA )

			Help( ' ', 1, STR0002, , STR0017, 3, 1 ) //'ATENÇÃO'###'Não existe negociação cadastrada.'
			lReturn := .F.

		EndIf

	EndIf

	If lReturn

		oBrowse := FWMBrowse():New()
		oBrowse:SetAlias( 'TQH' )
		oBrowse:SetDescription( STR0001 ) // 'Preços'
		oBrowse:SetMenuDef( 'MNTA612' )
		oBrowse:SetFilterDefault( 'TQH_FILIAL == "' + xFILIAL( 'TQF' ) + '" .And. TQH_CODPOS == TQF->TQF_CODIGO .And. TQH_LOJA == TQF->TQF_LOJA' )
		oBrowse:SetChgAll(.F.)

		If lOpenView

			oExecView := FWViewExec():New()
			oExecView:SetSource( 'MNTA612' )
			oExecView:SetModal( .F. )
			oExecView:SetOperation( 3 ) //Inclusão.
			oExecView:OpenView( .T. )

		Else

			oBrowse:Activate()
			
		EndIf

	EndIf

Return lReturn

//------------------------------------------------------------------------------
/*/{Protheus.doc} MenuDef
Inicializa o MenuDef com as suas opções

@type Function

@author 
@since 

@return FWMVCMenu() Vai retornar as opções padrão do menu, como 'Incluir', 
'Alterar', e 'Excluir'
/*/
//------------------------------------------------------------------------------
Static Function MenuDef()

Return FWMVCMenu( 'MNTA612' )

//------------------------------------------------------------------------------
/*/{Protheus.doc} ModelDef
Regras de Modelagem da gravacao

@author NG Informática Ltda.
@since 01/01/2015
/*/
//------------------------------------------------------------------------------
Static Function ModelDef()

	Local oModel
	Local oStructTQH := FWFormStruct( 1, 'TQH' )
	Local bPreValid	 := { |oModel| PreValida( oModel )	} // Validação inicial
	Local bPosValid	 := { |oModel| ValidInfo( oModel )	}  // Validação final
	
	// Cria o objeto do Modelo de Dados
	oModel := MPFormModel():New( 'MNTA612', , bPosValid, /*bCommit*/, /*bCancel*/ )

	// Validate model activation
	oModel:SetVldActivate( bPreValid )

	// Adiciona ao modelo uma estrutura de formulário de edição por campo
	oModel:AddFields( 'MNTA612_TQH', Nil, oStructTQH )

	oModel:SetDescription( NgSX2Nome( 'TQH' ) )

Return oModel

//------------------------------------------------------------------------------
/*/{Protheus.doc} ViewDef
Regras de Interface com o Usuario

@author NG Informática Ltda.
@since 01/01/2015
/*/
//------------------------------------------------------------------------------
Static Function ViewDef()

	Local oModel := FWLoadModel( 'MNTA612' )
	Local oView  := FWFormView():New()

	// Objeto do model a se associar a view.
	oView:SetModel(oModel)

	//Adiciona no nosso View um controle do tipo FormFields(antiga enchoice)
	oView:AddField( 'MNTA612_TQH' , FWFormStruct( 2,'TQH' ) )

	// Inclusão de itens no Ações Relacionadas de acordo com o NGRightClick
	NGMVCUserBtn( oView )

Return oView

//---------------------------------------------------------------------
/*/{Protheus.doc} ValidInfo
Pós-validação do modelo de dados.

@author Cristiano Serafim Kair
@since 05/10/2021

@param  oModel, Objeto, Objeto principal da rotina, contem os valores informados.

@return lógico, pós validação do modelo
/*/
//---------------------------------------------------------------------
Static Function ValidInfo( oModel )

Return MNT612VALDT() .And. MNT612DTCA()

//------------------------------------------------------------------------------
/*/{Protheus.doc} PreValida
Pre validação para abertura do cadastro

@type function
@author cristiano.kair
@since 05/10/2021

@return Lógica. Valida se é administrador e se tem abastecimento com o
				posto, loja, combustivel e data negociação
/*/
//------------------------------------------------------------------------------
Static Function PreValida( oModel )

	Local nOperation := oModel:GetOperation()
	Local lReturn	 := .T.
	Local dPROXPRE   := ' '
	Local cAliasTQH
	Local cAliasTQN

	If !MNA613ADM( oModel )
		lReturn := .F.
	EndIf

	If lReturn .And. nOperation == MODEL_OPERATION_UPDATE .Or. nOperation == MODEL_OPERATION_DELETE

		cAliasTQH	 := GetNextAlias()
		cAliasTQN	 := GetNextAlias()
		cPOSTO := TQH->TQH_CODPOS
		cLOJA  := TQH->TQH_LOJA
		cCOMB  := TQH->TQH_CODCOM
		dDATA  := TQH->TQH_DTNEG
		
		BeginSql Alias cAliasTQH
			SELECT TQH.TQH_DTNEG
				FROM %table:TQH% TQH
			WHERE	TQH.TQH_FILIAL 	= %xFilial:TQH%
				AND	TQH.TQH_CODPOS 	= %exp:cPOSTO%
				AND TQH.TQH_LOJA 	= %exp:cLOJA%
				AND TQH.TQH_CODCOM 	= %exp:cCOMB%
				AND TQH.%NotDel%
		EndSql

		While ( cAliasTQH )->( !Eof() )
			If dDATA < StoD( ( cAliasTQH )->( TQH_DTNEG ) )
				dPROXPRE := StoD( ( cAliasTQH )->( TQH_DTNEG ) )
				Exit
			Else
				dPROXPRE := dDataBase
			EndIf
			( cAliasTQH )->( dbSkip() )
		End

		BeginSql Alias cAliasTQN
			SELECT Count( TQN_DTABAS ) total
				FROM %table:TQN% TQN
			WHERE	TQN.TQN_FILIAL 	=  %xFilial:TQN%
				AND	TQN.TQN_POSTO  	=  %exp:TQH->TQH_CODPOS%
				AND TQN.TQN_LOJA 	=  %exp:TQH->TQH_LOJA%
				AND TQN.TQN_CODCOM 	=  %exp:TQH->TQH_CODCOM%
				AND TQN.TQN_DTABAS 	>= %exp:TQH->TQH_DTNEG%
				AND TQN.TQN_DTABAS 	<= %exp:dPROXPRE%
				AND TQN.TQN_VALUNI 	=  %exp:TQH->TQH_PRENEG%
				AND TQN.%NotDel%
			GROUP BY TQN.TQN_DTABAS, TQN.TQN_VALUNI
		EndSql

		dbSelectArea( 'TQM' )
		dbSetOrder( 1 )
		dbSeek( xFilial( 'TQM' ) + TQH->TQH_CODCOM )

		If ( cAliasTQN )->( total ) > 0
			Help( ' ', 1, STR0002, , STR0015 +; //'ATENÇÃO'### //'Não é possivel alterar ou excluir informaçoes da negociação de preço do combustível '
					AllTrim( TQM->TQM_NOMCOM ) + ','+ chr(10) + Chr(13) + STR0016, 3, 1 ) //'pois já existe abastecimento com esse preço.'
			lReturn := .F.
		EndIf

		( cAliasTQN )->( DbCloseArea() )

		( cAliasTQH )->( DbCloseArea() )

	EndIf

Return lReturn

//---------------------------------------------------------------------
/*/{Protheus.doc} MNT612PREC
Valida preço negociado não ser maior que preço da bomba

@author Cristiano Serafim Kair
@since 08/08/2021

@return Lógico - Retorna verdadeiro caso validacoes estejam corretas
/*/
//---------------------------------------------------------------------
Function MNT612PREC()

	Local oModel   := FWModelActive()
	Local cPreneg  := oModel:GetValue( 'MNTA612_TQH', 'TQH_PRENEG' )
	Local cPrebom  := oModel:GetValue( 'MNTA612_TQH', 'TQH_PREBOM' )
	Local lReturn  := .T.

	If cPreneg > cPrebom
		Help( '', 1, STR0002, , STR0011, 3, 1 )   //'ATENCÃO'  //'Preço Negociado não pode ser maior que o Preço da Bomba.'
		lReturn := .F.
	EndIf

	If lReturn
		oModel:SetValue( 'MNTA612_TQH', 'TQH_DESCON', (1-(cPreneg/cPrebom))*100 )
	Endif

Return lReturn

//---------------------------------------------------------------------
/*/{Protheus.doc}  MNT612VALDT
Valida a data Negociacao,nao pode ser menor que a ultima

@type function
@author Cristiano Serafim Kair
@since 01/10/2021

@return Lógico. True se data e hora for maior que ultima cadastrada
/*/
//---------------------------------------------------------------------
Function MNT612VALDT()

	Local oModel	 := FWModelActive()
	Local dDtneg	 := oModel:GetValue( 'MNTA612_TQH', 'TQH_DTNEG' )
	Local cHrneg	 := oModel:GetValue( 'MNTA612_TQH', 'TQH_HRNEG' )
	Local cCodcom	 := oModel:GetValue( 'MNTA612_TQH', 'TQH_CODCOM' )
	Local lReturn	 := .T.
	Local cAliasTQH	 := GetNextAlias()

	BeginSql Alias cAliasTQH
		SELECT Count( TQH_DTNEG ) total
			FROM %table:TQH% TQH
		WHERE	TQH.TQH_FILIAL 	= %xFilial:TQH%
			AND	TQH.TQH_CODPOS 	= %exp:TQF->TQF_CODIGO%
			AND TQH.TQH_LOJA 	= %exp:TQF->TQF_LOJA%
			AND TQH.TQH_CODCOM 	= %exp:cCodcom%
			AND ( TQH.TQH_DTNEG	> %exp:dDtneg%
				OR ( TQH.TQH_DTNEG = %exp:dDtneg% AND TQH.TQH_HRNEG > %exp:cHrneg% ) )
			AND TQH.%NotDel%
		GROUP BY TQH.TQH_DTNEG, TQH.TQH_HRNEG
	EndSql

	If ( cAliasTQH )->( total ) > 0
		Help( '', 1, STR0002, , STR0009, 3, 1 ) // ### //'ATENCÃO'###  //'Data e hora da Negociação do Preço nao pode ser menor ou igual a última cadastrada.'
		lReturn := .F.
	EndIf

	( cAliasTQH )->( DbCloseArea() )

Return lReturn

//---------------------------------------------------------------------
/*/{Protheus.doc}  MNT612DTCA
Valida data negociacao nao pode ser menor que a data do
cadastramento do posto e cadastros nao menor que Dt. corrente

@type function
@author Cristiano Serafim Kair
@since 01/10/2021

@return Lógico. True se data e hora for maior que data de cadastro do posto
/*/
//---------------------------------------------------------------------
Function MNT612DTCA()

	Local oModel	:= FWModelActive()
	Local cCodcom	:= oModel:GetValue( 'MNTA612_TQH', 'TQH_CODCOM' )
	Local dDtneg	:= oModel:GetValue( 'MNTA612_TQH', 'TQH_DTNEG' )
	Local lReturn	:= .T.
	Local cAliasTQN

	If dDtneg < TQF->TQF_DTCAD
		Help( '', 1, STR0002, , STR0018, 3, 1 ) // 'ATENÇÃO'###'Data da negociação do Preço não pode ser menor que a data de cadastramento do posto.'
		lReturn := .F.
	EndIf

	If lReturn

		cAliasTQN := GetNextAlias()

		BeginSql Alias cAliasTQN
			SELECT COUNT( TQN_DTABAS ) total
				FROM %table:TQN% TQN
			WHERE	TQN.TQN_FILIAL 	= %xFilial:TQN%
				AND	TQN.TQN_POSTO  	= %exp:TQF->TQF_CODIGO%
				AND TQN.TQN_LOJA 	= %exp:TQF->TQF_LOJA%
				AND TQN.TQN_DTABAS 	> %exp:Dtos( dDtneg )%
				AND TQN.TQN_CODCOM 	= %exp:cCodcom%
				AND TQN.%NotDel%
		EndSql

		If ( cAliasTQN )->( total ) > 0
			Help( '', 1, STR0002, , STR0013, 3, 1 ) // 'ATENÇÃO'###'Já existem abastecimentos para esse posto com data maior que a Data da negociação!'
			lReturn := .F.
		EndIf

		( cAliasTQN )->( DbCloseArea() )
		
	EndIf

Return lReturn

//---------------------------------------------------------------------
/*/{Protheus.doc}  MNT612EXCHV
Valida chave na tabela de Negociacao de Preco

@type function
@author Cristiano Serafim Kair
@since 01/10/2021

@return Lógico. True se existe chave com os argumentos.
/*/
//---------------------------------------------------------------------
Function MNT612EXCHV()

	Local oModel  := FWModelActive()
	Local cCodcom := oModel:GetValue( 'MNTA612_TQH', 'TQH_CODCOM' )
	Local dDtneg  := oModel:GetValue( 'MNTA612_TQH', 'TQH_DTNEG' )
	Local cHrneg  := oModel:GetValue( 'MNTA612_TQH', 'TQH_HRNEG' )

Return EXISTCHAV( 'TQH', TQF->TQF_CODIGO + TQF->TQF_LOJA + cCodcom + DTOS( dDtneg ) + cHrneg )                                                                                                       

//---------------------------------------------------------------------
/*/{Protheus.doc}  MNT612VLD
Função acumuladora dos valid da TQH 

@type function
@author Cristiano Serafim Kair
@since 01/10/2021

@return Lógico. True se existe chave com os argumentos.
/*/
//---------------------------------------------------------------------
Function MNT612VLD(cCampo)

	Local oModel  := FWModelActive()
	Local lReturn := .T.
	Local cCodcom := oModel:GetValue( 'MNTA612_TQH', 'TQH_CODCOM' )
	Local nPrebom := oModel:GetValue( 'MNTA612_TQH', 'TQH_PREBOM' )
	Local nPreneg := oModel:GetValue( 'MNTA612_TQH', 'TQH_PRENEG' )
	Local cHrneg  := oModel:GetValue( 'MNTA612_TQH', 'TQH_HRNEG' )
	Local nDescon := oModel:GetValue( 'MNTA612_TQH', 'TQH_DESCON' )

	Do Case

		Case cCampo == 'TQH_CODCOM'

			lReturn := EXISTCPO( 'TQM', cCodcom )

		Case cCampo == 'TQH_DTNEG'

			lReturn := MNT612DTCA()

		Case cCampo == 'TQH_HRNEG'

			lReturn := NGVALHORA( cHrneg ) .And. MNT612VALDT() .And. MNT612EXCHV()

		Case cCampo == 'TQH_PRENEG'

			lReturn := Positivo( nPreneg ) .And. MNT612PREC()

		Case cCampo == 'TQH_PREBOM'

			lReturn := Positivo( nPrebom ) .And. MNT612PREC()

		Case cCampo == 'TQH_DESCON'

			oModel:SetValue( 'MNTA612_TQH', 'TQH_PRENEG', nPrebom - ( nPrebom * ( nDescon / 100 ) ) )

	EndCase

Return lReturn

//---------------------------------------------------------------------
/*/{Protheus.doc}  MNA612RELA
Relação da tabela TQH
@type function

@author Cristiano Serafim Kair
@since 01/10/2021
@version V12

@param cCampo, Caracter, campo a ser validado

@return Caracter. Valor do Relação do campo em questão.
/*/
//---------------------------------------------------------------------
Function MNA612RELA( cCampo )

	Local xRet

	Do Case

		Case cCampo == 'TQH_CODPOS'

			xRet := TQF->TQF_CODIGO

		Case cCampo == 'TQH_LOJA'

			xRet := TQF->TQF_LOJA

		Case cCampo == 'TQH_NOMCOM'

			xRet := TQM->( VDISP( TQH->TQH_CODCOM, 'TQM_NOMCOM' ) )

		Case cCampo == 'TQH_DTATUA'

			xRet := dDataBase

		Case cCampo == 'TQH_USUARI'

			xRet := SUBSTR( cUSUARIO, 7, 15 )

		Case cCampo == 'TQH_ORDENA'

			xRet := INVERTE( TQH->TQH_DTNEG )

	EndCase

Return xRet
