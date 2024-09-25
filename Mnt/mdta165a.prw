#Include 'Protheus.ch'
#INCLUDE "MDTA165a.ch"
#Include 'FWMVCDef.ch'

//-------------------------------------------------------------------
/*/{Protheus.doc} MDTA165A
Classe interna implementando o FWModelEvent
@author Julia Kondlatsch
@since 30/10/2017
@version 1.0
/*/
//-------------------------------------------------------------------
Class MDTA165A FROM FWModelEvent

	Method New() Constructor
	Method ModelPosVld() //Validação Pós-Valid do Modelo
	Method InTTS() //Method executado durante o Commit

End Class

//-------------------------------------------------------------------
/*/{Protheus.doc} MDTA165A
Método construtor da classe
@author Julia Kondlatsch
@since 30/10/2017
@version 1.0
/*/
//-------------------------------------------------------------------
Method New() Class MDTA165A
Return

//-------------------------------------------------------------------
/*/{Protheus.doc} ModelPosVld
Validação do campo de data de validade inicial do model.
@author Julia Kondlatsch
@since 30/10/2017
@version 1.0
/*/
//-------------------------------------------------------------------
Method ModelPosVld( oModel, cModelId ) Class MDTA165A

	Local lRet		:= .T.
	Local lValida   := .F.
	Local oModelTNE := oModel:GetModel( "TNEMASTER" )
	Local nOpc		:= oModel:GetOperation() // Operação de ação sobre o Modelo
	Local aNao		:= { "TI7", "TOQ", "TOR", "TOS", "TOT", "TOU" }
	
	//Variáveis de validação dos relacionamentos do ambiente
	Local cEntAmb	:= SuperGetMv( "MV_NG2EAMB", .F., "1" ) //Indica qual entidade será considerada no relacionamento com o ambiente
	Local lTOQ		:= AliasInDic( "TOQ" ) //Ambiente x Centro de Custo
	Local lTOR		:= AliasInDic( "TOR" ) //Ambiente x Departamento
	Local lTOS		:= AliasInDic( "TOS" ) //Ambiente x Função
	Local lTOT		:= AliasInDic( "TOT" ) //Ambiente x Tarefa
	Local lTOU		:= AliasInDic( "TOU" ) //Ambiente x Funcionário
	Local nCont		:= 0
	Local aRegsVld	:= {}
	Local aCCSint	:= {}
	Local aCampos	:= {}
	Local aFunEnv	:= {}
	Local cStrAux	:= ""
	Local oModelAux

	Private aCHKSQL := {} // Variável para consistência na exclusão (via SX9)
	Private aCHKDEL := {} // Variável para consistência na exclusão (via Cadastro)

	//Recebe SX9
	aCHKSQL := NGRETSX9( "TNE", aNao )

	If nOpc == MODEL_OPERATION_DELETE .And. ( !NGCHKDEL( "TNE" ) .Or. !NGVALSX9( "TNE", aNao, .T., .T. ) )
		lRet := .F.
	EndIf

	//Caso as validações anteriores estejam Ok
	If lRet
		//Caso a opção de relacionamento seja por Centro de Custo
		If cEntAmb == "1" .And. lTOQ

			//Pega o modelo da tabela TOQ
			oModelAux := oModel:GetModel( "TOQDETAIL" )

			//Define as informações utilizadas na validação
			aCampos := { "TOQ", 2, "TOQ_CC", "TOQ_CODAMB", "CTT", "CTT_DESC01", STR0010, STR0011, STR0013 } //"Os centros de custo abaixo já estão vinculados a outros ambientes" ## "Centro de Custo" ## "Favor selecionar outros centros de custo"

			//---------------------------------------------------------------
			// Valida se os centros de custo inputados são do tipo Analítico
			//---------------------------------------------------------------
			For nCont := 1 To oModelAux:Length()
				oModelAux:GoLine( nCont )
				If !( oModelAux:IsDeleted() )
					If fCCSint( oModelAux:GetValue( "TOQ_CC" ) ) //Verifica se o Centro de Custo inputado é do tipo sintético
						aAdd( aCCSint, { oModelAux:GetValue( "TOQ_CC" ) } )
					EndIf
				EndIf
			Next nCont

			If Len( aCCSint ) > 0
				cStrAux := STR0014 + ":" + CRLF //"Os Centros de Custo abaixo são do tipo 'Sintético', portanto não podem ser vinculados"
				For nCont := 1 To Len( aCCSint )
					cStrAux += CRLF + "- " + STR0011 + ": " + AllTrim( Posicione( "CTT", 1, xFilial( "CTT" ) + aCCSint[ nCont, 1 ], "CTT_DESC01" ) )
				Next nCont

				Help( ' ', 1, STR0001, , cStrAux, 2, 0, , , , , , { STR0013 } ) //"Atenção" ## "Favor selecionar outros centros de custo"
				lRet := .F.
			EndIf

		//Caso a opção de relacionamento seja por Departamento
		ElseIf cEntAmb == "2" .And. lTOR

			//Pega o modelo da tabela TOR
			oModelAux := oModel:GetModel( "TORDETAIL" )

			//Define as informações utilizadas na validação
			aCampos := { "TOR", 2, "TOR_DEPTO", "TOR_CODAMB", "SQB", "QB_DESCRIC", STR0015, STR0016, STR0017 } //"Os departamentos abaixo já estão vinculados a outros ambientes" ## "Departamento" ## "Favor selecionar outros departamentos"

		//Caso a opção de relacionamento seja por Função
		ElseIf cEntAmb == "3" .And. lTOS

			//Pega o modelo da tabela TOS
			oModelAux := oModel:GetModel( "TOSDETAIL" )

			//Define as informações utilizadas na validação
			aCampos := { "TOS", 2, "TOS_FUNCAO", "TOS_CODAMB", "SRJ", "RJ_DESC", STR0018, STR0019, STR0020 } //"As funções abaixo já estão vinculadas a outros ambientes" ## "Função" ## "Favor selecionar outras funções"

		//Caso a opção de relacionamento seja por Tarefa
		ElseIf cEntAmb == "4" .And. lTOT

			//Pega o modelo da tabela TOT
			oModelAux := oModel:GetModel( "TOTDETAIL" )

			//Define as informações utilizadas na validação
			aCampos := { "TOT", 2, "TOT_TAREFA", "TOT_CODAMB", "TN5", "TN5_NOMTAR", STR0021, STR0022, STR0023 } //"As tarefas abaixo já estão vinculadas a outros ambientes" ## "Tarefa" ## "Favor selecionar outras tarefas"

		//Caso a opção de relacionamento seja por Funcionário
		ElseIf cEntAmb == "5" .And. lTOU

			//Pega o modelo da tabela TOU
			oModelAux := oModel:GetModel( "TOUDETAIL" )

			//Define as informações utilizadas na validação
			aCampos := { "TOU", 2, "TOU_MAT", "TOU_CODAMB", "SRA", "RA_NOME", STR0024, STR0025, STR0026 } //"Os funcionários abaixo já estão vinculados a outros ambientes" ## "Funcionário" ## "Favor selecionar outros funcionários"

		EndIf

		//-------------------------------------------------------------------
		// Valida a existência de outro relacionamento igual para cada opção
		//-------------------------------------------------------------------
		If lRet
			For nCont := 1 To oModelAux:Length()
				oModelAux:GoLine( nCont )
				If !( oModelAux:IsDeleted() )
					dbSelectArea( aCampos[ 1 ] )
					dbSetOrder( aCampos[ 2 ] )
					If dbSeek( xFilial( aCampos[ 1 ] ) + oModelAux:GetValue( aCampos[ 3 ] ) )
						If &( aCampos[ 1 ] + "->" + aCampos[ 4 ] ) <> oModelTNE:GetValue( "TNE_CODAMB" )
							aAdd( aRegsVld, { &( aCampos[ 1 ] + "->" + aCampos[ 3 ] ), &( aCampos[ 1 ] + "->" + aCampos[ 4 ] ) } )
						EndIf
					EndIf
				EndIf
			Next nCont

			If Len( aRegsVld ) > 0

				cStrAux := aCampos[ 7 ] + ":" + CRLF

				For nCont := 1 To Len( aRegsVld )

					If aCampos[ 5 ] == 'SRA' // Validação específica para funcionários

						DbSelectArea( 'SRA' )
						DbSetOrder( 1 )

						If DbSeek( xFilial( 'SRA' ) + aRegsVld[ nCont, 1 ] )

							If !MdtTraAvul( SRA->RA_CATEFD ) // Trabalhador avulso pode ter mais de um ambiente
								cStrAux += CRLF + "- " + aCampos[ 8 ] + ": " + AllTrim( SRA->RA_NOME ) + " / " + STR0012 + ": " + AllTrim( Posicione( "TNE", 1, xFilial( "TNE" ) + aRegsVld[ nCont, 2 ], "TNE_NOME" ) ) //"Ambiente"
								lValida := .T.
							EndIf

						EndIf

					Else

						cStrAux += CRLF + "- " + aCampos[ 8 ] + ": " + AllTrim( Posicione( aCampos[ 5 ], 1, xFilial( aCampos[ 5 ] ) + aRegsVld[ nCont, 1 ], aCampos[ 6 ] ) ) + " / " + STR0012 + ": " + AllTrim( Posicione( "TNE", 1, xFilial( "TNE" ) + aRegsVld[ nCont, 2 ], "TNE_NOME" ) ) //"Ambiente"
						lValida := .T.

					EndIf

				Next nCont

				If lValida
					Help( ' ', 1, STR0001, , cStrAux, 2, 0, , , , , , { aCampos[ 9 ] } ) //"Atenção"
					lRet := .F.
				EndIf

			EndIf

		EndIf
	EndIf

	//Verifica campos obrigatórios ao eSocial
	If lRet .And. nOpc != MODEL_OPERATION_DELETE
		lRet := MDTObriEsoc( "TNE", , oModelTNE )
	EndIf

	//---------------------------------------------------------------------------------
	// Caso a entidade de vínculo com o ambiente seja por funcionário, valida o S-2240
	//---------------------------------------------------------------------------------
	If lRet .And. FindFunction( "MDTIntEsoc" ) .And. cEntAmb == "5" .And. lTOU

		//Busca os funcionários incluídos na grid
		aFunEnv := fGetFunc( oModel )

		//Caso existam funcionários a serem enviados
		If Len( aFunEnv ) > 0
			lRet := MDTIntEsoc( "S-2240", nOpc, , aFunEnv, .F. ) //Valida os funcionários a serem enviados
		EndIf

	EndIf

Return lRet

//-------------------------------------------------------------------------------------------------------------
/*/{Protheus.doc} InTTS
Method para integração com TAF durante o Commit

@param	oModel, Objeto, Modelo utilizado
@param	cModelId, Caracter, Id do modelo utilizado

@class	MDTA165A - Classe origem.

@author	Luis Fellipy Bett
@since	10/11/2021
@type	Class
/*/
//-------------------------------------------------------------------------------------------------------------
Method InTTS( oModel, cModelId ) Class MDTA165A

	//Variáves de verificação
	Local cEntAmb := SuperGetMv( "MV_NG2EAMB", .F., "1" ) //Indica qual entidade será considerada no relacionamento com o ambiente
	Local lTOU	  := AliasInDic( "TOU" ) //Ambiente x Funcionário
	Local aFunEnv := {}
	
	//Variável do tipo de operação
	Local nOpc := oModel:GetOperation()

	//--------------------------------------------------------------------------------
	// Caso a entidade de vínculo com o ambiente seja por funcionário, envia o S-2240
	//--------------------------------------------------------------------------------
	If FindFunction( "MDTIntEsoc" ) .And. cEntAmb == "5" .And. lTOU

		//Busca os funcionários incluídos na grid
		aFunEnv := fGetFunc( oModel )

		//Caso existam funcionários a serem enviados
		If Len( aFunEnv ) > 0
			MDTIntEsoc( "S-2240", nOpc, , aFunEnv ) //Envia os funcionários
		EndIf

	EndIf

Return .T.

//---------------------------------------------------------------------
/*/{Protheus.doc} fCCSint
Verifica se o centro de custo passado por parâmetro é do tipo sintético

@return	lSint, Boolean, .T. caso o CC seja do tipo sintético, senão .F.

@sample	fCCSint( "00000123" )

@author	Luis Fellipy Bett
@since	11/06/2021
/*/
//---------------------------------------------------------------------
Static Function fCCSint( cCCusto )

	Local lSint := .F.

	If Posicione( "CTT", 1, xFilial( "CTT" ) + cCCusto, "CTT_CLASSE" ) == "1"
		lSint := .T.
	EndIf

Return lSint

//---------------------------------------------------------------------
/*/{Protheus.doc} fGetFunc
Busca os funcionários que foram incluídos na grid

@return	aFuncs, Array, Array contendo os funcionários incluídos

@sample	fGetFunc( oModel )

@param	oModel, Objeto, Objeto do modelo

@author	Luis Fellipy Bett
@since	10/11/2021
/*/
//---------------------------------------------------------------------
Static Function fGetFunc( oModel )

	Local oModelTOU	:= oModel:GetModel( "TOUDETAIL" ) //Pega o modelo da tabela TOU
	Local aFuncs	:= {}
	Local nCont		:= 0

	//Percorre toda a grid verificando os funcionário incluídos
	For nCont := 1 To oModelTOU:Length()
		
		//Posiciona na linha a ser validada
		oModelTOU:GoLine( nCont )

		//Caso a linha tenha sido inserida e a linha não esteja em branco
		If oModelTOU:IsInserted() .And. !Empty( oModelTOU:GetValue( "TOU_MAT" ) )
			aAdd( aFuncs, { oModelTOU:GetValue( "TOU_MAT" ) } ) //Salva a matrícula do funcionário no array
		EndIf

	Next nCont

Return aFuncs
