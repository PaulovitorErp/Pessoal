#include 'PROTHEUS.ch'
#Include 'FWMVCDef.ch'
#include 'MNTA085.ch'

Static aSimilar85 := { {}, {}, {}, {} }
Static _POSICST9_ := 1
Static _POSICTQS_ := 2
Static _POSICSTB_ := 3
Static _POSICTPE_ := 4

//---------------------------------------------------------------------
/*/{Protheus.doc} MNTA085
Gerar pneus a partir de Nota Fiscal SD1

@author Maria Elisandra de Paula
@since 02/09/20

@return
/*/
//---------------------------------------------------------------------
Function MNTA085()

	Local aFieldBrw := {}
	Local aSd1      := {}
	Local nIndex    := 0
	Local oBrowse
	
	If !FindFunction( 'MNTAmIIn' ) .Or. MNTAmIIn( 95 )
	
		If !Empty( Alltrim( SuperGetMv( 'MV_NGSTAFG', .F., '' ) ) ) .Or. !Empty( Alltrim( SuperGetMv( 'MV_NGPNGR', .F., '' ) ) )
		
			Private oTmpTmp
			Private cAlias085 := GetNextAlias()
			Private aFieldTmp := {} 

			//-----------------------------------------------------------
			// estrutura de campos usada em vários pontos do fonte
			// [7] - se apresenta no browser
			// [8] - help 
			//-----------------------------------------------------------
			aAdd( aFieldTmp, { NGRETTITULO('D1_DOC'), 'D1_DOC', 'C', TAMSX3('D1_DOC')[1] , 0, '@!', .T., STR0025 }) // "Número do documento, nota fiscal do fornecedor."
			aAdd( aFieldTmp, { NGRETTITULO('D1_ITEM'), 'D1_ITEM', 'C', TAMSX3('D1_ITEM')[1], 0, '@!', .T., STR0012 }) // "Item da Nota Fiscal."
			aAdd( aFieldTmp, { NGRETTITULO('D1_FORNECE'), 'D1_FORNECE', 'C', TAMSX3('D1_FORNECE')[1], 0, '@!', .T., STR0014 }) // "Código do  fornecedor."
			aAdd( aFieldTmp, { NGRETTITULO('D1_LOJA'), 'D1_LOJA', 'C', TAMSX3('D1_LOJA')[1], 0, '@!', .T., STR0015 }) // "Código da loja do fornecedor."
			aAdd( aFieldTmp, { NGRETTITULO('D1_SERIE'), 'D1_SERIE', 'C', TAMSX3('D1_SERIE')[1], 0, '@!', .T., STR0013 }) //"Número da série da nota fiscal."
			aAdd( aFieldTmp, { NGRETTITULO('D1_NUMSEQ'), 'D1_NUMSEQ',  'C', TAMSX3('D1_NUMSEQ')[1], 0, '@!', .T., STR0016 }) //"Numeração sequêncial  de  movimentos de estoque."
			aAdd( aFieldTmp, { NGRETTITULO('D1_EMISSAO'), 'D1_EMISSAO', 'D', TAMSX3('D1_EMISSAO')[1], 0, '99/99/9999', .T., STR0017 }) // "Data da emissão da nota fiscal de entrada."
			aAdd( aFieldTmp, { NGRETTITULO('D1_COD'), 'D1_COD', 'C', TAMSX3('D1_COD')[1], 0, '@!', .F. , STR0011 }) // "Código identificador do produto."
			aAdd( aFieldTmp, { NGRETTITULO('D1_LOCAL'), 'D1_LOCAL', 'C', TAMSX3('D1_LOCAL')[1], 0, '@!', .F.,  STR0019 }) //"Código  do Armazém no qual está estocado o produto."
			aAdd( aFieldTmp, { NGRETTITULO('D1_VUNIT'), 'D1_VUNIT', 'N', TAMSX3('D1_VUNIT')[1], 2,'@E 99999999.99', .F., STR0018 }) // "Valor unitário do item."
			aAdd( aFieldTmp, { NGRETTITULO('D1_QUANT'), 'D1_QUANT', 'N', TAMSX3('D1_QUANT')[1], 2, '@E 99999999.99', .T., STR0020 }) // "Quantidade total do produto/item"
			aAdd( aFieldTmp, { STR0028, 'GERADA', 'N', 9, 2, '@E 99999999.99', .T., STR0021 }) // "Qtd. gerada" # "Quantidade de pneus já gerados para o item da nota fiscal."
			aAdd( aFieldTmp, { STR0029, 'AGERAR', 'N', 9, 2, '@E 99999999.99', .F., STR0022 }) // "Qtd. a gerar"# "Quantidade de pneus a gerar para o item da nota fiscal."
			aAdd( aFieldTmp, { STR0030, 'PNESIMILAR', 'C', TAMSX3('T9_CODBEM')[1], 0, '@!', .F., STR0023}) // "Pneu Similar" # "Código do bem que será utilizado como referência para gerar pneus."
			aAdd( aFieldTmp, { STR0031, 'NOMEPNEU', 'C', TAMSX3('T9_NOME')[1], 0, '@!', .F., STR0024  }) // "Nome Pneu" # "Nome do bem que será utilizado como referência para gerar pneus."

			// Campos do browser
			For nIndex := 1 to Len( aFieldTmp )
				If aFieldTmp[nIndex,7]
					aAdd( aFieldBrw, { aFieldTmp[nIndex,1], aFieldTmp[nIndex,2], aFieldTmp[nIndex,3], aFieldTmp[nIndex,4],;
						aFieldTmp[nIndex,5], aFieldTmp[nIndex,6] } )
				EndIf
			Next nIndex

			// Campos da tabela temporária
			For nIndex := 1 to Len( aFieldTmp )
				aAdd( aSd1, { aFieldTmp[nIndex,2], aFieldTmp[nIndex,3], aFieldTmp[nIndex,4], aFieldTmp[nIndex,5] } )
			Next

			// cria tabela temporária
			oTmpTmp := FWTemporaryTable():New( cAlias085, aSd1 )
			oTmpTmp:AddIndex( '1', { 'D1_NUMSEQ' } )
			oTmpTmp:Create()

			//Carrega temporária
			fUpdateTmp()

			oBrowse := FWMBrowse():New()
			oBrowse:SetAlias( cAlias085 )
			oBrowse:SetTemporary( .T. )
			oBrowse:SetMenuDef( 'MNTA085' )
			oBrowse:SetDescription( STR0004 ) // Pneus a partir da Nota Fiscal
			oBrowse:SetFields( aFieldBrw )    // Campos que serão apresentados no Browser.	
			oBrowse:Activate()

			oTmpTmp:Delete()

		Else
			
			Help(' ',1, STR0007  ,, STR0001 ,2,0) // "NÃO CONFORMIDADE" //"Para utilizar esta rotina é necessário configurar os parâmetros 'MV_NGSTAFG' e 'MV_NGPNGR'"

		EndIf

	EndIf

Return .T.

//---------------------------------------------------------------------
/*/{Protheus.doc} fUpdateTmp
Carrega tabela temporária

@param [cNumSeq], string, numero sequencia da NF
@author Maria Elisandra de Paula
@since 02/09/20
@return
/*/
//---------------------------------------------------------------------
Static Function fUpdateTmp( cNumSeq )

	Local cAliasQry := GetNextAlias()
	Local cCondSql	:= '%%'
	Local cCondSql2 := '%%'
	Local cCondSql3 := '%%'
	Local cGroup    := ''
	Local aAux      := {}
	Local nIndex    := 0
	Local cGrpTire  := Alltrim( SuperGetMv( 'MV_NGPNGR', .F., '' ) )

	Default cNumSeq := ''

	If !Empty( cNumSeq )
		cCondSql := '%AND SD1.D1_NUMSEQ = ' + ValToSQL( cNumSeq ) + '%'
	EndIf

	//-----------------------------------------------------------
	// busca todos os grupos de pneus configurados no parâmetro
	//-----------------------------------------------------------

	If ";" $ cGrpTire
		aAux := Strtokarr( cGrpTire ,";")
	Else
		aAux := { cGrpTire }
	EndIf

	For nIndex := 1 To Len( aAux )
		If nIndex > 1
			cGroup += ','
		EndIf
		cGroup += ValtoSql( aAux[nIndex] )
	Next nIndex

	cCondSql2 := '%AND SB1.B1_GRUPO IN (' + cGroup + ')%'

	//----------------------------------------------------------------
	// PE para filtro do browse
	//----------------------------------------------------------------
	If ExistBlock("MNTA0851")
		cCondSql3 := ExecBlock("MNTA0851",.F.,.F.)
		If Valtype( cCondSql3 ) == 'C' .And. !Empty( cCondSql3 )
			cCondSql3 := '%' +  cCondSql3 + '%'
		Else
			cCondSql3 := '%%'
		EndIf
	EndIf

	BeginSql Alias cAliasQry

		SELECT SD1.D1_DOC,
					SD1.D1_ITEM,
					SD1.D1_NUMSEQ,
					SD1.D1_QUANT,
					SD1.D1_EMISSAO,
					SD1.D1_FORNECE,
					SD1.D1_VUNIT,
					SD1.D1_LOJA,
					SD1.D1_LOCAL,
					SD1.D1_SERIE,
					SD1.D1_COD,
					( SELECT COUNT( DISTINCT TQZ_CODBEM)
					FROM %table:TQZ% TQZ
					WHERE TQZ.TQZ_FILIAL = %xFilial:TQZ%
						AND TQZ.%NotDel%
						AND TQZ_NUMSEQ = SD1.D1_NUMSEQ ) GERADA
		FROM %table:SD1% SD1
		INNER JOIN %table:SB1% SB1
			ON SB1.B1_FILIAL = %xFilial:SB1%
			AND SD1.D1_COD = SB1.B1_COD
			%exp:cCondSql2%
			AND SB1.%NotDel%
       INNER JOIN %table:SF1% SF1
               ON SF1.F1_FILIAL = %xFilial:SF1%
                  AND SF1.F1_DOC = SD1.D1_DOC
                  AND SF1.F1_SERIE = SD1.D1_SERIE
                  AND SF1.F1_FORNECE = SD1.D1_FORNECE
                  AND SF1.F1_LOJA = SD1.D1_LOJA
                  AND SF1.F1_STATUS = 'A'
                  AND SF1.%NotDel%
		WHERE SD1.D1_FILIAL = %xFilial:SD1%
			%exp:cCondSql%			
			AND SD1.%NotDel%
			AND SD1.D1_NUMSEQ <> ' '
			AND D1_OP = ' ' 
			%exp:cCondSql3%
		ORDER BY SD1.D1_DOC, SD1.D1_ITEM

	EndSql

	While (cAliasQry)->( !EoF() )

		If (cAliasQry)->D1_QUANT <= (cAliasQry)->GERADA
			If Empty( cNumSeq )
				(cAliasQry)->( DbSkip() )
				Loop
			Else
				RecLock( cAlias085, .F. )
				(cAlias085)->( dbdelete() )
				(cAlias085)->( MsUnLock() )
				Exit
			EndIf
		EndIf

		dbSelectArea(cAlias085)
		dbSetOrder(1)
		If dbSeek( (cAliasQry)->D1_NUMSEQ )
			RecLock( cAlias085, .F. )
		Else
			RecLock( cAlias085, .T. )
		EndIf

		(cAlias085)->D1_COD     := (cAliasQry)->D1_COD
		(cAlias085)->D1_LOCAL   := (cAliasQry)->D1_LOCAL
		(cAlias085)->D1_DOC     := (cAliasQry)->D1_DOC
		(cAlias085)->D1_ITEM    := (cAliasQry)->D1_ITEM
		(cAlias085)->D1_FORNECE := (cAliasQry)->D1_FORNECE
		(cAlias085)->D1_LOJA    := (cAliasQry)->D1_LOJA
		(cAlias085)->D1_SERIE   := (cAliasQry)->D1_SERIE
		(cAlias085)->D1_NUMSEQ  := (cAliasQry)->D1_NUMSEQ
		(cAlias085)->D1_QUANT   := (cAliasQry)->D1_QUANT
		(cAlias085)->D1_EMISSAO := Stod( (cAliasQry)->D1_EMISSAO )
		(cAlias085)->AGERAR     := 0
		(cAlias085)->GERADA     := (cAliasQry)->GERADA
		(cAlias085)->PNESIMILAR    := ''
		(cAlias085)->NOMEPNEU   := ''
		(cAlias085)->D1_VUNIT   := (cAliasQry)->D1_VUNIT

		(cAlias085)->( MsUnLock() )

		(cAliasQry)->( dbSkip() )

	EndDo
	
	(cAliasQry)->( dbCloseArea() )

Return

//---------------------------------------------------------------------
/*/{Protheus.doc} MenuDef
Opções de menu 

@author Maria Elisandra de Paula
@since 01/09/2020

@return aRotina
/*/
//---------------------------------------------------------------------
Static Function MenuDef()

	Local aRot := {}
   
	ADD OPTION aRot TITLE STR0002 ACTION 'VIEWDEF.MNTA085' OPERATION MODEL_OPERATION_VIEW   ACCESS 0 // "Visualizar"
    ADD OPTION aRot TITLE STR0003 ACTION 'VIEWDEF.MNTA085' OPERATION MODEL_OPERATION_UPDATE ACCESS 0 // "Gerar Pneus"

Return aRot

//---------------------------------------------------------------------
/*/{Protheus.doc} ModelDef
Modelo de dados da temporária

@author Maria Elisandra de Paula
@since 02/09/2020

@return object model
/*/
//---------------------------------------------------------------------
Static Function ModelDef()

	Local oModel := MPFormModel():New('MNTA085',/*bPre*/, {|oModel| ValidPos( oModel )},  {|oModel| CommitInfo( oModel ) } , /*bCancel*/) 
	Local oStTMP := FWFormModelStruct():New()
	Local nIndex := 0

	fUpdateTmp( (cAlias085)->D1_NUMSEQ ) // Atualiza valor do registro selecionado

    oStTMP:AddTable(cAlias085, {'D1_NUMSEQ'}, STR0004 ) //"Pneus a partir da Nota Fiscal"

	For nIndex := 1 to Len( aFieldTmp )

		oStTmp:AddField( aFieldTmp[nIndex,1], aFieldTmp[nIndex,2], aFieldTmp[nIndex,2], aFieldTmp[nIndex,3], aFieldTmp[nIndex,4], ;
						aFieldTmp[nIndex,5], Nil,Nil,{},.F.,  &('{||(cAlias085)->' + aFieldTmp[nIndex,2] + '}' )  , .F.,.F.,.F.)

	Next nIndex

	oStTMP:SetProperty( 'AGERAR', MODEL_FIELD_VALID, FWBuildFeature( STRUCT_FEATURE_VALID, 'MNTA085VLD("AGERAR")' ) )
	oStTMP:SetProperty( 'AGERAR', MODEL_FIELD_OBRIGAT, .T.  )

	oStTMP:SetProperty( 'PNESIMILAR', MODEL_FIELD_VALID, FWBuildFeature( STRUCT_FEATURE_VALID, 'MNTA085VLD("PNESIMILAR")' ) )
	oStTMP:AddTrigger('PNESIMILAR', 'NOMEPNEU', {|| .T. }, { || Trigger()  })

    oModel:AddFields('MASTER',/*cOwner*/,oStTMP)
    oModel:SetPrimaryKey({'D1_NUMSEQ'})
    oModel:GetModel('MASTER'):SetDescription( STR0004 )

	//----------------------------------------------------------------
	// PE para realizar tratamentos no modelo
	//----------------------------------------------------------------
	If ExistBlock("MNTA0852")
		ExecBlock("MNTA0852",.F.,.F.,{ oModel, 'MASTER' })
	EndIf

Return oModel

//---------------------------------------------------------------------
/*/{Protheus.doc} ViewDef
Interface da rotina - tabela temporária

@author Maria Elisandra de Paula
@since 02/09/2020

@return object view
/*/
//---------------------------------------------------------------------
Static Function ViewDef()

    Local oModel := FWLoadModel('MNTA085')
    Local oStTmp := FWFormViewStruct():New()
    Local oView  := FWFormView():New()
	Local nIndex := 0

	oStTmp:AddGroup( '1', STR0005 ,'', 2) //'Detalhes da Nota Fiscal'
	oStTmp:AddGroup( '2', STR0006,'',2) // "Pneus"

	For nIndex := 1 to Len( aFieldTmp )
		oStTmp:AddField( aFieldTmp[nIndex,2], cValtochar( nIndex ), aFieldTmp[nIndex,1], aFieldTmp[nIndex,1], { aFieldTmp[nIndex,8] }, ;
			aFieldTmp[nIndex,3], aFieldTmp[nIndex,6], Nil, Nil,.F.,,'1')
	Next nIndex

	oStTMP:SetProperty( 'PNESIMILAR', MVC_VIEW_LOOKUP, 'PNEUSI' ) // F3
	oStTMP:SetProperty( 'PNESIMILAR', MVC_VIEW_CANCHANGE, .T. ) // Alterável
	oStTMP:SetProperty( 'AGERAR', MVC_VIEW_CANCHANGE, .T. ) // Alterável
	// parte de baixo da view
	oStTMP:SetProperty( 'GERADA', MVC_VIEW_GROUP_NUMBER, '2' )
	oStTMP:SetProperty( 'AGERAR', MVC_VIEW_GROUP_NUMBER, '2' )
	oStTMP:SetProperty( 'PNESIMILAR', MVC_VIEW_GROUP_NUMBER, '2' )
	oStTMP:SetProperty( 'NOMEPNEU', MVC_VIEW_GROUP_NUMBER, '2' )

    oView:AddField('VIEW_MASTER', oStTMP, 'MASTER')
    oView:SetModel(oModel)
    oView:CreateHorizontalBox('TELA',100)
    oView:SetCloseOnOk({||.T.})//Força o fechamento da janela na confirmação
    oView:SetOwnerView('VIEW_MASTER','TELA')

	//----------------------------------------------------------------
	// PE para realizar tratamentos na view
	//----------------------------------------------------------------
	If ExistBlock("MNTA0853")
		ExecBlock("MNTA0853",.F.,.F.,{ oView, 'VIEW_MASTER' })
	EndIf

	oView:AddUserButton("Pneu Modelo","MAGIC_BMP", {|oView| MNTA085PN( oView ) }, "Pneu Modelo",,,.T.)

Return oView

//---------------------------------------------------------------------
/*/{Protheus.doc} MNTA085VLD
Valid de campos da primeira tela 

@param cField, string, campo para validação

@author Maria Elisandra de Paula
@since 02/09/2020

@return lógico, define se a informação digitada está OK
/*/
//---------------------------------------------------------------------
Function MNTA085VLD( cField )

	Local lRet    := .T.
	Local oActive := FwModelActive()
	Local oModel  := oActive:GetModel('MASTER')

	If cField == 'AGERAR'
		
		lRet := Positivo()
		
		If lRet .And. oModel:GetValue('AGERAR') > ( oModel:GetValue('D1_QUANT') - oModel:GetValue('GERADA') )

			Help(' ',1, STR0007  ,, STR0008 ,2,0) // "NÃO CONFORMIDADE" # "A quantidade informada supera o total de itens da nota fiscal"
			lRet := .F.	

		EndIf

	ElseIf cField == 'PNESIMILAR'

		
		If ExistCpo( 'ST9', oModel:GetValue('PNESIMILAR') )

			dbSelectArea( 'ST9' )
			dbSetOrder( 1 ) // T9_FILIAL + T9_CODBEM
			If dbSeek( xFilial( 'ST9' ) + oModel:GetValue( 'PNESIMILAR' ) ) .And. ST9->T9_CATBEM != '3'

				Help( ,, STR0007, , STR0009  , 1, 0) //"O Bem digitado não é um Pneu!"
				lRet := .F.

			EndIf 

		Else

			lRet := .F.

		EndIf

	EndIf	

Return lRet

//---------------------------------------------------------------------
/*/{Protheus.doc} MNTA085PN
Tela para informar detalhes do pneu sample

@param oViewPai, objeto, view pai

@author Maria Elisandra de Paula
@since 02/09/2020

@return lógico, define se os dados informados estão OK
/*/
//---------------------------------------------------------------------
Static Function MNTA085PN( oViewPai )

	Local oModelPai := oViewPai:GetModel()
	Local cSimilar  := oModelPai:GetValue( 'MASTER', 'PNESIMILAR')
	Local cError    := ''
	Local aValues   := {}

	If FwFldGet( 'AGERAR' ) > ( oModelPai:GetValue( 'MASTER', 'D1_QUANT') - oModelPai:GetValue( 'MASTER', 'GERADA') )
		cError := STR0008 //"A quantidade informada supera o total de itens da nota fiscal"
	EndIf

	If Empty( cError )

		aAdd( aValues, { 'T9_STATUS',  Alltrim( SuperGetMv( 'MV_NGSTAFG', .F., '' ) ) } )
		aAdd( aValues, { 'T9_DTGARAN',  CTOD("  /  /    ") })
		aAdd( aValues, { 'T9_DTCOMPR', (cAlias085)->D1_EMISSAO } )
		aAdd( aValues, { 'T9_ESTRUTU', 'N'  } )
		aAdd( aValues, { 'T9_SERIE',   (cAlias085)->D1_SERIE } )
		aAdd( aValues, { 'T9_FORNECE', (cAlias085)->D1_FORNECE } )
		aAdd( aValues, { 'T9_LOJA',    (cAlias085)->D1_LOJA } )
		aAdd( aValues, { 'T9_VALCPA',  (cAlias085)->D1_VUNIT } )
		aAdd( aValues, { 'T9_NFCOMPR', (cAlias085)->D1_DOC } )
		aAdd( aValues, { 'T9_SITMAN',  'A' } )
		aAdd( aValues, { 'T9_PARTEDI', '2' } )
		aAdd( aValues, { 'T9_CODESTO', (cAlias085)->D1_COD } )
		aAdd( aValues, { 'T9_LOCPAD',  (cAlias085)->D1_LOCAL } )

		//-----------------------------------------------------------
		// Apresenta tela de pneu
		//-----------------------------------------------------------
		cError := MNTA085SI( oViewPai, oModelPai, cSimilar, aValues, @aSimilar85 )[1]

    EndIf

	If !Empty( cError )

		Help(' ',1, STR0007  ,, cError ,2,0) // Não Conformidade

	EndIf

Return Empty( cError )

//---------------------------------------------------------------------
/*/{Protheus.doc} MNT085TIRE
Validação do pneu sample

@author Maria Elisandra de Paula
@since 07/10/2020
@return lógico, define se o pneu poderá ser utilizado
/*/
//---------------------------------------------------------------------
Function MNT085TIRE()

	Local cMsg   := ''
	Local oModel := FWModelActive()

    // O campo status deve ser preenchido
    If Empty( oModel:GetValue( oModel:cId + '_ST9', 'T9_STATUS') )
		cMsg := STR0032 // "O campo Status deve ser informado."
	   	// Caso o status do pneu seja diferente de 'Aguardando Marcação de Fogo' (MV_NGSTAFG)
    	// o cadastro deve passar por todas as validações para salvar o modelo
	ElseIf !oModel:VldData()
        cMsg := Alltrim( oModel:GetErrorMessage()[6] )
	EndIf

	If !Empty( cMsg )
		Help(' ',1, STR0007 ,, cMsg  ,2,0)
	EndIf

Return Empty( cMsg )

//----------------------------------------------------------------------
/*/{Protheus.doc} MNTA85NEXT
Retorna o código do pneu para seguir sequencia de cadastro de bens

@param cLast, string, código do último bem

@author Maria Elisandra de Paula
@since 16/09/2020

@return caracter, código do proximo pneu a ser utilizado
/*/
//---------------------------------------------------------------------
Function MNTA85NEXT( cLast )

	Local cCondSql  := '%%'
    Local cRet      := ''
	Local cAliasQry := ''

	If Empty( cLast )

		cAliasQry:= GetNextAlias()

		If Alltrim( SuperGetMv( 'MV_NGDPST9', .F., '' ) ) == '0'
			cCondSql := '%AND T9_FILIAL = '  + ValToSQL( xFilial('ST9') ) + '%'
		EndIf

		BeginSql Alias cAliasQry

			SELECT MAX( ST9.T9_CODBEM ) AS T9_CODBEM
				FROM  %table:ST9% ST9 
			WHERE ST9.%NotDel% 
				AND T9_CATBEM = '3'
				%Exp:cCondSql%

		EndSql

		If !Empty((cAliasQry)->T9_CODBEM)
			cRet := (cAliasQry)->T9_CODBEM
		EndIf

		(cAliasQry)->( dbCloseArea() )

	Else

		cRet := cLast

	EndIf

	If Empty( cRet )
		cRet := 'PN000001'
	EndIf

	dbSelectArea('ST9')
	dbSetOrder( 1 ) // T9_FILIAL + T9_CODBEM
	While dbSeek( xFilial('ST9') + cRet )
		cRet := Soma1OLD( Alltrim( cRet ) )
	EndDo

Return cRet

//----------------------------------------------------------------------
/*/{Protheus.doc} fStruct
Retorno estrutura da tabela e conteúdo dos campos

@param oModelAux, objeto, modelo de dados
@param cTable, string, nome da tabela
@author Maria Elisandra de Paula
@since 04/09/2020
@return array, array de campos
/*/
//---------------------------------------------------------------------
Static Function fStruct( cTable, oModelAux )

	Local aAux   := {}
	Local nAux   := 0
	Local oChild := oModelAux:GetModel( oModelAux:cId + cTable)
	Local oStruc := oChild:GetStruct()
	Local aStruc := oStruc:GetFields()

	For nAux := 1 to Len( aStruc )
		aAdd( aAux, { aStruc[nAux, 3], oChild:GetValue( aStruc[nAux, 3] ) })
	Next nAux

Return aAux

//----------------------------------------------------------------------
/*/{Protheus.doc} fStruct2
Carrega campos 

@param aStruc, array, estrutura dos submódulos
@param aIndex, array, conteudo para carregar
@author Maria Elisandra de Paula
@since 07/10/2020
@return array
/*/
//---------------------------------------------------------------------
Static Function fStruct2( aStruc, aIndex )

	Local nIndex := 0
	Local nPosic := 0

	For nIndex := 1 to Len( aIndex )
		nPosic := Ascan( aStruc, {|x| x[1] == aIndex[nIndex,1] } )
		If nPosic > 0
			aStruc[nPosic,2] := aIndex[nIndex,2]
		EndIf
	Next nIndex

Return aStruc

//----------------------------------------------------------------------
/*/{Protheus.doc} CommitInfo
Operações após confirmar última tela - gera pneus

@oModel, object, modelo de dados 
@author Maria Elisandra de Paula
@since 01/10/20
@return .T.
/*/
//---------------------------------------------------------------------
Static Function CommitInfo( oModel )

	Local cSimilar   := oModel:GetValue('MASTER', 'PNESIMILAR')
	Local nAgerar    := oModel:GetValue( 'MASTER', 'AGERAR')
	Local oModelPneu
	Local cXCodBem   := ''
	Local aTires     := {}
	Local lValid     := .F.	
	Local nIndex     := 0

	If !Empty( cSimilar )
		dbSelectArea('ST9')
		dbSetOrder(1)
		dbSeek( xFilial('ST9') + cSimilar )
	EndIf

	//-----------------------------------------------------
	// Cria MODELO de pneu
	//-----------------------------------------------------
	oModelPneu := FWLoadModel( 'MNTA083' )
	oModelPneu:SetOperation( 3 )
	oModelPneu:Activate( !Empty( cSimilar ) )
	oModelPneu := MNT085BKP( oModelPneu, 2, aSimilar85 )[2] // recupera informações do pneu modelo

	cXCodBem := oModelPneu:GetValue( oModelPneu:cId + '_ST9', 'T9_CODBEM')

	For nIndex := 1 To nAgerar

		Begin transaction

			//-----------------------------------------------
			// Gravação pelo modelo padrão
			//-----------------------------------------------
			lValid := oModelPneu:SetValue( oModelPneu:cId + '_ST9', 'T9_CODBEM', cXCodBem ) .And.;
					oModelPneu:VldData() .And. oModelPneu:CommitData()

			If lValid

				//--------------------------------------
				// Atualiza TQZ do pneu gerados
				//--------------------------------------
				dbSelectArea( 'TQZ' )
				dbSetorder( 1 ) // TQZ_FILIAL + TQZ_CODBEM + TQZ_DTSTAT + TQZ_HRSTAT + TQZ_STATUS
				If dbSeek( xFilial('TQZ') + cXCodBem )
					RecLock('TQZ', .F.)
					TQZ->TQZ_NUMSEQ := (cAlias085)->D1_NUMSEQ  
					TQZ->TQZ_ORIGEM := 'SD1' 
					TQZ->( MsUnLock() )
				EndIf

				aAdd( aTires, { cXCodBem, Alltrim( oModelPneu:GetValue( oModelPneu:cId + '_ST9', 'T9_STATUS') ) })

			EndIf

		End transaction

		cXCodBem := MNTA85NEXT( cXCodBem )

	Next nIndex

	//----------------------------------------
	// Apresenta tela de pneus gerados
	//----------------------------------------
	MNT085SHOW( aTires )
	fUpdateTmp( (cAlias085)->D1_NUMSEQ ) // Atualiza campo quantidade gerada

Return .T.

//----------------------------------------------------------------------
/*/{Protheus.doc} MNTA085REC
Grava pneu manualmente

@param cXCodBem, string, código do bem
@param cStFire, string, status que será gravado os pneus
@param aInfoTQS, array, informação de pneus
	[1]-placa
	[2]-posição
	[3]-eixo
	[4]-tipo eixo
@author Maria Elisandra de Paula
@since 11/09/20
@return .T.
/*/
//---------------------------------------------------------------------
Function MNTA085REC( oModelPneu, cXCodBem, cStFire, aInfoTQS )

	Local aStrucST9 := {}
	Local aStrucTQS := {}
	Local aStrucTPE := {}
	Local aStrucSTB := {}
	Local aAux      := {}
	Local lTPE      := .F.
	Local lSTB      := .F.

	Default aInfoTQS := {}

	aStrucST9 := fStruct( '_ST9', oModelPneu )
	aStrucTQS := fStruct( '_TQS', oModelPneu )
	aStrucTPE := fStruct( '_TPE', oModelPneu )
	aStrucSTB := fStruct( '_STB', oModelPneu )

	lTPE := Ascan( aStrucTPE, {|x| x[1] == 'TPE_SITUAC' .And. !Empty( x[2] ) .And. x[2] == '1' } ) > 0

	//----------------------------------------------
	// Carrega campos manualmente ST9
	//----------------------------------------------
	aAux := {	{ 'T9_FILIAL', xFilial('ST9') },;
				{ 'T9_CODBEM', cXCodBem  },;
				{ 'T9_STATUS', cStFire  }}

	aStrucST9 := fStruct2( aStrucST9, aAux )

	//----------------------------------------------
	// Carrega campos manualmente TQS
	//----------------------------------------------
	aAux := {	{ 'TQS_FILIAL', xFilial('TQS') },;
				{ 'TQS_CODBEM', cXCodBem } }

	If !Empty( aInfoTQS )
		aAdd( aAux, { 'TQS_PLACA' , aInfoTQS[1] } )
		aAdd( aAux, { 'TQS_POSIC' , aInfoTQS[2] } )
		aAdd( aAux, { 'TQS_EIXO'  , aInfoTQS[3] } )
		aAdd( aAux, { 'TQS_TIPEIX', aInfoTQS[4] } )
	EndIf

	aStrucTQS := fStruct2( aStrucTQS, aAux )

	//----------------------------------------------
	// Carrega campos manualmente TPE
	//----------------------------------------------
	If lTPE
		aAux := {	{ 'TPE_FILIAL', xFilial('TPE') },;
					{ 'TPE_CODBEM', cXCodBem }}

		aStrucTPE := fStruct2( aStrucTPE, aAux )
	EndIf

	fRecord( cXCodBem, 'ST9', aStrucST9 )
	fRecord( cXCodBem, 'TQS', aStrucTQS )

	If TQS->TQS_SULCAT > 0

		//------------------------------------------------------------------
		// Grava histórico de sulco do pneu
		//------------------------------------------------------------------
		DBSelectArea( 'TQV' )
		DBSetOrder( 1 ) // TQV_FILIAL + TQV_CODBEM + TQV_DTMEDI + TQV_HRMEDI + TQV_BANDA
		If !DBSeek( xFilial('TQV') + TQS->TQS_CODBEM + DToS( TQS->TQS_DTMEAT ) + TQS->TQS_HRMEAT + TQS->TQS_BANDAA )
			RecLock( 'TQV' , .T. )
			TQV->TQV_FILIAL := xFilial('TQV')
			TQV->TQV_CODBEM := TQS->TQS_CODBEM
			TQV->TQV_DTMEDI := TQS->TQS_DTMEAT
			TQV->TQV_HRMEDI := TQS->TQS_HRMEAT
			TQV->TQV_BANDA  := TQS->TQS_BANDAA
			TQV->TQV_DESENH := TQS->TQS_DESENH
			TQV->TQV_SULCO  := TQS->TQS_SULCAT
			TQV->( MsUnLock() )
		EndIf

	EndIf

	//------------------------------------------------------------------
	// Grava histórico de status do pneu
	//------------------------------------------------------------------
	DBSelectArea( 'TQZ' )
	DBSetOrder( 1 ) // TQZ_FILIAL + TQZ_CODBEM + TQZ_DTSTAT + TQZ_HRSTAT + TQZ_STATUS
	If !DBSeek( xFilial('TQZ') + TQS->TQS_CODBEM + DToS( TQS->TQS_DTMEAT ) + TQS->TQS_HRMEAT + ST9->T9_STATUS)
		RecLock( 'TQZ' , .T. )
		TQZ->TQZ_FILIAL := xFilial('TQZ')
		TQZ->TQZ_CODBEM := TQS->TQS_CODBEM
		TQZ->TQZ_DTSTAT := TQS->TQS_DTMEAT
		TQZ->TQZ_HRSTAT := TQS->TQS_HRMEAT
		TQZ->TQZ_STATUS := ST9->T9_STATUS
		TQZ->TQZ_ALMOX  := ST9->T9_LOCPAD
		TQZ->TQZ_PRODUT := ST9->T9_CODESTO
		TQZ->TQZ_ALMOX  := ST9->T9_LOCPAD
		TQZ->( MsUnLock() )
	EndIf

	If lTPE
		fRecord( cXCodBem, 'TPE', aStrucTPE )
	EndIf

Return .T.

//----------------------------------------------------------------------
/*/{Protheus.doc} fRecord
Grava tabela manualmente de acordo com estrutura

@param cKey   , caracter, chave primária
@param cTable , caracter, tabela
@param aStruct, array   , estrutura de campos

@author Maria Elisandra de Paula
@since 08/10/20

@return nil
/*/
//---------------------------------------------------------------------
Static Function fRecord( cKey, cTable, aStruct )

	Local nValues := 0

	dbSelectArea( cTable )
	dbSetOrder(1)
	If !dbSeek( xFilial(cTable) + cKey )
		RecLock( cTable, .T. )
		For nValues := 1 To Len( aStruct )
			If FieldPos( aStruct[nValues,1] ) > 0
				&( cTable + '->' + aStruct[nValues,1] ) := aStruct[nValues,2]
			EndIf
		Next nValues
		MsUnLock()
	EndIf

Return

//----------------------------------------------------------------------
/*/{Protheus.doc} MNTA085SXB
Filtro para consulta padrão de pneus similares

@author Maria Elisandra de Paula
@since 10/09/20
@return caracter, retorna filtro para consulta padrão
/*/
//---------------------------------------------------------------------
Function MNTA085SXB()

	Local oModel
	Local cRet    := "@T9_CATBEM = '3' AND T9_SITBEM = 'A' "
	Local nIndex  := 0
	Local aFamily := {}
	Local cFamily := ''
	Local oGrid
	Local cMarked := ''

	If IsInCallStack('MNTA085') // Gera Pneu a partir de uma NF

		oModel  := FwModelActive()

		cRet += " AND ( SELECT COUNT(TQZ_CODBEM) FROM " + RetSqlName( 'TQZ' )
		cRet += " 	WHERE D_E_L_E_T_ <> '*' AND T9_CODBEM = TQZ_CODBEM"
		cRet += "		AND TQZ_FILIAL = " + ValToSQL( xFilial('TQZ') ) 
		cRet += " 		AND TQZ_NUMSEQ = " + ValToSQL( oModel:GetValue('MASTER', 'D1_NUMSEQ') ) + ") > 0"
	
	ElseIf IsInCallStack('MNTA084') // Gera Pneus a partir de um veículo

		oModel := FwModelActive()
		oGrid  := oModel:GetModel('DETAIL')

		//------------------------------------------------------------------------------------------
		// Trecho abaixo verifica se usuário já marcou alguma posição para pegar a família marcada
		//------------------------------------------------------------------------------------------
		For nIndex := 1 To oGrid:Length()
			oGrid:GoLine( nIndex )
			If Ascan( aFamily, oGrid:GetValue('T6_CODFAMI') ) == 0
				aAdd( aFamily, oGrid:GetValue('T6_CODFAMI') )
			EndIf

			If oGrid:GetValue('OK')
				cMarked := oGrid:GetValue('T6_CODFAMI')
			EndIf

		Next nIndex

		If !Empty( cMarked )

			//-------------------------------------
			// apenas a família marcada
			//-------------------------------------
			cFamily := ValToSQL( cMarked )

		Else

			//-------------------------------------------------------
			// Trecho abaixo concatena todas as familias de pneus
			//-------------------------------------------------------
			For nIndex := 1 to Len( aFamily )
				If nIndex > 1
					cFamily += ','
				EndIf
				cFamily += ValToSQL( aFamily[nIndex] )
			Next nIndex

		EndIf

		cRet += " AND T9_CODFAMI IN ( " + cFamily + ")"

	EndIf

Return cRet

//---------------------------------------------------------------------------------
/*/{Protheus.doc} MNT085SHOW
Mostra pneus gerados

@type static function

@param aTires, array, informações dos pneus gerados

@author Maria Elisandra de Paula
@since 06/10/20

@return logico, sempre .T.
/*/
//---------------------------------------------------------------------------------
Function MNT085SHOW( aTires )

	Local nIndex  := 0
	Local cStatus := ''
	Local cMsg    := ''
	
	For nIndex := 1 to Len( aTires )

		If cStatus != aTires[nIndex,2]
			cMsg += STR0010  + ' '  + aTires[nIndex,2]  + '-' + NGSEEK( 'TQY', aTires[nIndex,2], 1, 'TQY_DESTAT' ) // "Pneus gerados com status "
			cMsg += CRLF + CRLF
		EndIf

		cStatus := aTires[nIndex,2]
		cMsg += aTires[nIndex,1] + CRLF

	Next nIndex

	NGMSGMEMO( STR0027, cMsg ) // "Atenção"

Return .T.

//---------------------------------------------------------------------------------
/*/{Protheus.doc} ValidPos
Validação pneu similar

@type static function
@author Maria Elisandra de Paula
@since 06/10/20

@return logico, se deve prosseguir com a operação
/*/
//---------------------------------------------------------------------------------
Static Function ValidPos( oModel )

	Local cError  := ''
	
	If !HasBackup( aSimilar85 )

		cError := STR0033 //'O Pneu Modelo ainda não foi definido !'

	EndIf

	If !Empty( cError )

		Help(' ',1, STR0007  ,, cError ,2,0) // Não Conformidade

	EndIf

Return Empty( cError )

//---------------------------------------------------------------------
/*/{Protheus.doc} HasBackup
Verifica se já tem backup de informações

@author Maria Elisandra de Paula
@since 20/10/2020

@param aAux, array, informações já gravadas do pneu modelo

@return logico, caso não tenha backup retorna .T.
/*/
//---------------------------------------------------------------------
Static Function HasBackup( aAux )

	Local lEmpty := Empty( aAux[_POSICST9_] ) .And. Empty( aAux[_POSICTQS_] ) .And. ;
					Empty( aAux[_POSICSTB_] ) .And. Empty( aAux[_POSICTPE_] )

Return !lEmpty

//---------------------------------------------------------------------
/*/{Protheus.doc} MNT085BKP
Realiza backup dos campos alterados

@author Maria Elisandra de Paula
@since 20/10/2020

@param oModelPneu, objeto  , modelo de dados
@param nTime     , numerico, tipo de operação 1-backup;2-recupera
@param aAux      , array   , backup de inforações do pneu similar

@return array, [ 1 ] - backup de inforações do pneu similar
			   [ 2 ] - modelo de dados
/*/
//---------------------------------------------------------------------
Function MNT085BKP( oModelPneu, nTime, aAux )

	If nTime == 1

		// faz backup das informações
		aAux[_POSICST9_] := SaveInfo( oModelPneu, '_ST9' )
		aAux[_POSICTQS_] := SaveInfo( oModelPneu, '_TQS' )
		aAux[_POSICSTB_] := SaveInfo( oModelPneu, '_STB' )
		aAux[_POSICTPE_] := SaveInfo( oModelPneu, '_TPE' )

	Else

		// altera modelo de acordo com backup
		RestoreInfo( oModelPneu, '_ST9', aAux[_POSICST9_] )
		RestoreInfo( oModelPneu, '_TQS', aAux[_POSICTQS_] )
		RestoreInfo( oModelPneu, '_STB', aAux[_POSICSTB_] )
		RestoreInfo( oModelPneu, '_TPE', aAux[_POSICTPE_] )

	EndIf

Return { aAux, oModelPneu }

//----------------------------------------------------------------------
/*/{Protheus.doc} SaveInfo
Armazena informações que foram modificadas

@author Maria Elisandra de Paula
@since 20/09/2020

@param cTable, string, nome da tabela
@param oModelPneu, objeto, modelo de dados

@return array, campos modificados
/*/
//---------------------------------------------------------------------
Static Function SaveInfo( oModelPneu, cTable )

	Local aAux    := {}
	Local nAux    := 0
	Local oSubMod := oModelPneu:GetModel( oModelPneu:cId + cTable)
	Local aStruc  := oSubMod:GetStruct():GetFields()

	For nAux := 1 to Len( aStruc )
		If oSubMod:IsFieldUpdated( aStruc[nAux, 3] )
			aAdd( aAux, { aStruc[nAux, 3], oSubMod:GetValue( aStruc[nAux, 3] ) })
		EndIf
	Next nAux

Return aAux

//---------------------------------------------------------------------
/*/{Protheus.doc} RestoreInfo
Recupera informações armazenadas

@author Maria Elisandra de Paula
@since 20/10/2020

@param oModelPneu, objeto, modelo de dados
@param cTabel, string, tabela
@param aValues, array, valores a serem gravados no array

@return Nil
/*/
//---------------------------------------------------------------------
Static Function RestoreInfo( oModelPneu, cTable, aValues)

	Local cIdTable := oModelPneu:cId + cTable
	Local nAux     := 0

	For nAux := 1 to Len( aValues )
		oModelPneu:SetValue( cIdTable, aValues[nAux,1], aValues[nAux,2] )
	Next nAux

Return

//---------------------------------------------------------------------
/*/{Protheus.doc} MNTA085SI
Apresenta View de Pneu

@author Maria Elisandra de Paula
@since 21/10/2020

@param oViewPai, object, tela principal
@param oModelPai, object, modelo da tela principal
@param cSample, string, código do pneu que será usado para carregar campos
@param aValues, array, valores que devem ser modificados na primeira vez que acessar tela 
@param aSimDef, array, backup de informações 
@param [cFamily], string, código da família marcada na rotina 087
@param [nOperat], numerico, operação da view principal

@return array 
	[1]String com erro, caso exista
	[2]Boolean, se confirmou a tela
/*/
//---------------------------------------------------------------------
Function MNTA085SI( oViewPai, oModelPai, cSample, aValues, aSimDef, cFamily, nOperat )

	Local aArea     := GetArea()
    Local aAreaST9  := ST9->( GetArea() )
	Local oViewPneu
	Local cError   := ''
	Local cIdST9   := ''
	Local oModelPneu
	Local lConfirm := .F.
	Local nIndex   := 0

	Default cFamily := ''
	Default nOperat := oViewPai:GetOperation()

	If Empty( Alltrim( SuperGetMv( 'MV_NGSTAFG', .F., '' ) ) )
		cError := STR0001 // "Para utilizar esta rotina é necessário configurar os parâmetros 'MV_NGSTAFG' e 'MV_NGPNGR'"
	EndIf

	If Empty( cError )

		If !Empty( cSample )
			dbSelectArea('ST9')
			dbSetOrder(1)
			dbSeek( xFilial('ST9') + cSample )
		EndIf

		//-----------------------------------------------------
		// Gera MODEL de pneu para usuário informar detalhes
		//-----------------------------------------------------
		oModelPneu := FWLoadModel( 'MNTA083' )
		oModelPneu:SetOperation( 3 )
		If oModelPneu:Activate( !Empty( cSample ) )

			If !HasBackup( aSimDef ) // quando ainda não há um similar definido

				cIdST9 := oModelPneu:cId + '_ST9'

				//--------------------------------------------
				// Busca próximo código do bem
				//--------------------------------------------
				If Empty( oModelPneu:GetValue( cIdST9, 'T9_CODBEM') )
					aAdd( aValues, { 'T9_CODBEM',  MNTA85NEXT( '' )  } )
				EndIf

				For nIndex := 1 to Len( aValues )
					If !oModelPneu:SetValue( cIdST9, aValues[nIndex,1], aValues[nIndex,2] )
						cError := 'Campo: ' + aValues[nIndex,1] + ' - ' + 'Valor: '  + aValues[nIndex,2] + CRLF + oModelPneu:GetErrorMessage()[6]
						Exit
					EndIf
				Next nIndex


			Else
				//-----------------------------------------------------------------------------------
				// segunda vez ou + que acessa a tela, trata o modelo com o backup salvo previamente
				//-----------------------------------------------------------------------------------
				oModelPneu := MNT085BKP( oModelPneu, 2, aSimDef )[2]
			EndIf

		Else
			cError := oModelPneu:GetErrorMessage()[6]
		EndIf

	EndIf

	If Empty( cError )

		//-----------------------------------------------------------
		// Cria view de pneus
		//-----------------------------------------------------------
		oViewPneu := FWLoadView( 'MNTA083' )
		oViewPneu:oViewOwner := oViewPai
		oViewPneu:AddUserButton("Cancelar","MAGIC_BMP", {|oViewPneu| oViewPneu:CloseOwner() }, "Pneu Modelo",,,.T.)

		//-----------------------------------------------------------
		// Executa a view de pneus
		//-----------------------------------------------------------
		oExecView := FWViewExec():New()
		oExecView:SetTitle( STR0034 ) //"Modelo de Pneu"

		If IsInCallStack('MNTA085PN') // Gera Pneu a partir de uma NF
			oExecView:SetOK( {|| MNT085TIRE() } )
		Else
			oExecView:SetOK( {|| MNT087TIRE( cFamily ) } )
		EndIf

		oExecView:SetCancel({|| .T. })
		oExecView:SetOperation( nOperat )
		oExecView:SetModel( oModelPneu )
		oExecView:SetView( oViewPneu )

		oExecView:setButtons({{.F.,Nil},{.F.,Nil},{.F.,Nil},{.F.,Nil},{.F.,Nil},{.F.,Nil},{.T.,"Confirmar"},;
			{.T.,"Cancelar"},{.F.,Nil},{.F.,Nil},{.F.,Nil},{.F.,Nil},{.F.,Nil},{.F.,Nil}})
		oExecView:SetCloseOnOk( {||.T.} )
		oExecView:OpenView(.F.)

		If oExecView:GetButtonPress() == 0 // Confirma
			aSimDef := MNT085BKP( oModelPneu, 1, aSimDef )[1] // faz backup das informações (somente se confirmar a tela)
			lConfirm := .T.
		EndIf

	EndIf

	If ValType( oModelPneu ) == 'O' .And. oModelPneu:IsActive()
		oModelPneu:Deactivate()
		oModelPneu:Destroy()
		oModelPneu := Nil			
	EndIf

    RestArea(aArea)
    RestArea(aAreaST9)

	//--------------------------------------------------
	// Retorna para o model pai
	//--------------------------------------------------
	FWModelActive( oModelPai )

Return { cError, lConfirm }

//---------------------------------------------------------------------
/*/{Protheus.doc} Trigger
Gatilho de campo

@author Maria Elisandra de Paula
@since 21/10/2020
@return caractere, retorna nome do pneu similar
/*/
//---------------------------------------------------------------------
Static Function Trigger()

	Local oModel := FwModelActive()
	Local cRet   := NGSEEK( 'ST9', oModel:GetValue( 'MASTER', 'PNESIMILAR'), 1, 'T9_NOME' )

	aSimilar85   := { {}, {}, {}, {} }

Return cRet
