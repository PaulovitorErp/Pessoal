#Include 'Protheus.ch'
#INCLUDE "MDTA090a.ch"
#Include 'FWMVCDef.ch'

//-------------------------------------------------------------------
/*/{Protheus.doc} MDTA090A
Classe interna implementando o FWModelEvent
@author Luis Fellipy Bett
@since 06/04/2018
@version 1.0
/*/
//-------------------------------------------------------------------
Class MDTA090A FROM FWModelEvent

	Method GridLinePosVld()
	Method ModelPosVld()
	Method AfterTTS()
    Method New() Constructor

End Class

//-------------------------------------------------------------------
/*/{Protheus.doc} MDTA090A
Método construtor da classe
@author Luis Fellipy Bett
@since 06/04/2018
@version 1.0
/*/
//-------------------------------------------------------------------
Method New() Class MDTA090A
Return

//-------------------------------------------------------------------
/*/{Protheus.doc} GridLinePosVld
Método para fazer a verficação de validação das linhas da Grid (LinOK)
@author Luis Fellipy Bett
@since 30/04/2018
@version 1.0
/*/
//-------------------------------------------------------------------
Method GridLinePosVld( oModel, cModelId ) Class MDTA090A

	Local cMatric	:= ''
	Local cTarefa	:= ''
	Local cCondicao	:= ''

    Local dDtInic	:= oModel:GetValue( 'TN6_DTINIC' )
    Local dDtTerm 	:= oModel:GetValue( 'TN6_DTTERM' )

    Local lRet	  	:= .T.

    Local nI	  	:= 0
    Local nLine	  	:= oModel:nLine

	If FwIsInCallStack( 'Mdta007Tar' )
		cTarefa := oModel:GetValue( 'TN6_CODTAR' )
		cCondicao := "cTarefa == oModel:GetValue( 'TN6_CODTAR' )"
	Else
		cMatric	:= oModel:GetValue( 'TN6_MAT' )
		cCondicao := "cMatric == oModel:GetValue( 'TN6_MAT' )"
	EndIf

    If !( oModel:IsDeleted() )

        If dDtInic < Posicione( "SRA", 1, xFilial( "SRA" ) + cMatric, "RA_ADMISSA" )

            Help( ' ', 1, 'DTINIINVAL', , STR0015 + STR0016 + DToC( SRA->RA_ADMISSA ), 5, 5 )
            lRet := .F.

        Else

            For nI := 1 To oModel:Length()

                oModel:GoLine( nI )

                If nI != nLine .And. &( cCondicao ) .And. !( oModel:IsDeleted() )

                    If Empty( oModel:GetValue( "TN6_DTTERM" ) ) .And. ;
                        ( dDtInic > oModel:GetValue( "TN6_DTINIC" ) .Or. dDtTerm > oModel:GetValue( "TN6_DTINIC" ) )
                        lRet := .F.
                    ElseIf Empty( dDtTerm ) .And. dDtInic < oModel:GetValue( "TN6_DTTERM" )
                        lRet := .F.
                    ElseIf Empty( dDtTerm ) .And. Empty( oModel:GetValue( "TN6_DTTERM" ) )
                        lRet := .F.
                    ElseIf oModel:GetValue( "TN6_DTINIC" ) < dDtTerm .And. ;
                        oModel:GetValue( "TN6_DTTERM" ) > dDtInic
                        lRet := .F.
                    EndIf

                    If !lRet
                        Help( "", 1, "PERINVALID", , STR0008, 4, 5 ) //"O período cadastrado já existe para o funcionário."
                    EndIf

                EndIf

            Next nI

			oModel:GoLine( nLine )

        EndIf

		If lRet .And. MDTVldEsoc() .And. oModel:IsFieldUpdated( 'TN6_DTTERM' ) .And. !Empty( oModel:GetValue( 'TN6_DTTERM' ) )
			MdtEsoFimT() // Dispara alertas
		EndIf

    EndIf

Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} ModelPosVld
Validação do campo de data de validade inicial do model.
@author Luis Fellipy Bett
@since 06/04/2018
@version 1.0
/*/
//-------------------------------------------------------------------
Method ModelPosVld( oModel, cModelId ) Class MDTA090A

	Local aAreaTN5		:= TN5->( GetArea() )
	Local nOpcx 		:= oModel:GetOperation() // Operação de ação sobre o Modelo // 3 - Insert ; 4 - Update ; 5 - Delete
	Local aNaoSX9		:= { "TN6" }
	Local lRet			:= .T.

	Local lCheckTN6  	:= ( NGSX2MODO( "TN5" ) == "C" .And. NGSX2MODO( "TN6" ) != "C" )
	Local lExistTKD  	:= NGCADICBASE( "TKD_NUMFIC", "D", "TKD", .F. )
	Local lDeleta    	:= .F.
	Local lTN6 			:= .F.
	Local lTKD			:= .F.
	Local aFiliais   	:= {}
	Local cMsg			:= ""
	Local cMsg2			:= ""
	Local nCont2		:= 0

	Private aCHKSQL 	:= {} // Variável para consistência na exclusão (via SX9)
	Private aCHKDEL 	:= {} // Variável para consistência na exclusão (via Cadastro)

	// Recebe SX9 - Formato:
	// 1 - Domínio (tabela)
	// 2 - Campo do Domínio
	// 3 - Contra-Domínio (tabela)
	// 4 - Campo do Contra-Domínio
	// 5 - Condição SQL
	// 6 - Comparação da Filial do Domínio
	// 7 - Comparação da Filial do Contra-Domínio
	aCHKSQL := NGRETSX9( "TN5", aNaoSX9 )

	// Recebe relação do Cadastro - Formato:
	// 1 - Chave
	// 2 - Alias
	// 3 - Ordem (Índice)
	aAdd( aCHKDEL, { 'TN5->TN5_CODTAR', "TN0", 4 } )
	aAdd( aCHKDEL, { '"5"+TN5->TN5_CODTAR', "TOA", 2 } )

	If nOpcx == MODEL_OPERATION_DELETE //Exclusão
		If !NGCHKDEL( "TN5" )
			lRet := .F.
		EndIf

		If lRet .And. !NGVALSX9( "TN5", aNaoSX9, .T., .T. )
			lRet := .F.
		EndIf
	EndIf

	//-------------------------------------------------------------------------------------
	// Realiza as validações das informações do evento S-2240 que serão enviadas ao Governo
	//-------------------------------------------------------------------------------------
	If lRet .And. FindFunction( "MDTIntEsoc" )
		lRet := fTarS2240( nOpcx, .F., oModel )
	EndIf

	If lRet
		//Verifica se existem funcionarios para a tarefa em outras filiais
		For nCont2 := 1 To Len( aFiliais )
			If ( lTN6 .Or. !lCheckTN6 ) .And. ( !lExistTKD .Or. ( lExistTKD .And. lTKD ) )
				Exit
			Else
				If lCheckTN6 .And. !lTN6 .And. aFiliais[ nCont2 ][ 1 ] != cFilAnt
					dbSelectArea( "TN6" )
					dbSetOrder( 1 )
					If dbSeek( xFilial( "TN6", aFiliais[ nCont2 ][ 1 ] ) + TN5->TN5_CODTAR )
						lTN6 := .T.
					Endif
				Endif
				If lExistTKD .And. !lTKD
					dbSelectArea( "TKD" )
					dbSetOrder( 2 )
					If dbSeek( xFilial( "TKD", aFiliais[ nCont2 ][ 1 ] ) + TN5->TN5_CODTAR )
						lTKD := .T.
					Endif
				Endif
			Endif
		Next nCont2

		If lTN6 .Or. lTKD
			If lTN6
				cMsg := STR0001 //"Existem funcionários relacionados a esta tarefa em outras filiais."
			Endif
			If lTKD
				cMsg2 := STR0002 //"candidatos relacionados a esta tarefa."
			Endif
			If !Empty( cMsg ) .And. !Empty( cMsg2 )
				cMsg += CHR( 13 ) + STR0003 + cMsg2 //"Também existem "
			ElseIf Empty( cMsg )
				cMsg := STR0004 + cMsg2 //"Existem "
			Endif
			lDeleta := MsgYesNo( cMsg + CHR( 13 ) + STR0005 + CHR( 13 ) + STR0006, STR0007 ) //"Deseja mesmo excluir a tarefa?"###"Todas estas informações serão apagadas."###"Atenção"
			lRet := lDeleta
		Endif
	EndIf

	//Deleta informacoes das outras filiais
	If lRet .And. lDeleta
		For nCont2 := 1 To Len( aFiliais )
			If aFiliais[ nCont2 ][ 1 ] != cFilAnt
				dbSelectArea( "TN6" )
				dbSetOrder( 1 )
				While dbSeek( xFilial( "TN6", aFiliais[ nCont2 ][ 1 ] ) + TN5->TN5_CODTAR )
					RecLock( "TN6", .F. )
					dbDelete()
					MsUnlock( "TN6" )
				End
			EndIf
			If lExistTKD
				dbSelectArea( "TKD" )
				dbSetOrder( 2 )
				While dbSeek( xFilial( "TKD", aFiliais[ nCont2 ][ 1 ] ) + TN5->TN5_CODTAR )
					RecLock( "TKD", .F. )
					dbDelete()
					MsUnlock( "TKD" )
				End
			EndIf
		Next nCont2
	EndIf

	RestArea( aAreaTN5 ) //Retorna a área

Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} InTTS
Método executado durante o Commit
@author Luis Fellipy Bett
@since 05/02/2019
@version 1.0
/*/
//-------------------------------------------------------------------
Method AfterTTS( oModel, cModelId ) Class MDTA090A

	Local aAreaTN5 := TN5->( GetArea() )
	Local nOpcx := oModel:GetOperation() //Operação que está sendo realizada

	//-----------------------------------------------------------------
	// Realiza a integração das informações do evento S-2240 ao Governo
	//-----------------------------------------------------------------
	If FindFunction( "MDTIntEsoc" )
		fTarS2240( nOpcx, , oModel )
	EndIf

	RestArea( aAreaTN5 ) //Retorna a área

Return

//---------------------------------------------------------------------
/*/{Protheus.doc} fTarS2240
Realiza a validação e envio das informações do evento S-2240 ao Governo

@param nOper, Numérico, Indica a operação que está sendo realizada (3- Inclusão, 4- Alteração ou 5- Exclusão)
@param lEnvio, Boolean, Indica se é envio de informações, caso contrário trata como validação
@param oModel, Objeto, Objeto do modelo

@sample fTarS2240( 3, .F., oModel )

@return lRet, Boolean, .T. caso não existam inconsistências no envio

@author Luis Fellipy Bett
@since	18/03/2021
/*/
//---------------------------------------------------------------------
Static Function fTarS2240( nOper, lEnvio, oModel )

	Local aFuncs	 	:= {}

	Local cCodTar	 	:= ''
	Local cDesTar		:= ''
	Local cMatricula	:= ''

	Local dDtInic	 	:= SToD( '' )
	Local dDtTerm	 	:= SToD( '' )

	Local lRet		 	:= .T.
	Local lFicha		:= oModel:GetId() == 'mdta007b' // Chamado na rotina de ficha médica

	Local nCont		 	:= 0

	Local oModelTN6 := oModel:GetModel( 'TN6DETAIL' )

	Default lEnvio := .T. // Define por padrão como sendo envio de informações

	If !lFicha
		cCodTar := oModel:GetValue( 'TN5MASTER', 'TN5_CODTAR' )
		cDesTar := oModel:GetValue( 'TN5MASTER', 'TN5_DESCRI' )
	EndIf

	//Percorre a grid para validar todos os funcionários
	For nCont := 1 To oModelTN6:Length()
		
		//Posiciona na linha para validar
		oModelTN6:GoLine( nCont )

		If lFicha
			cCodTar := oModel:GetValue( 'TN6DETAIL', 'TN6_CODTAR' )
			cDesTar := Posicione( 'TN5', 1, xFilial( 'TN5' ) + cCodTar, 'TN5_DESCRI' )
		EndIf

		//Caso a descrição da tarefa tenha sido alterada ou a tarefa esteja sendo excluída ou o funcionário
		//tenha sido adicionado, alterado ou excluído da grid e o campo de matrícula não esteja vazio
		If (;
			( M->TN5_DESCRI != cDesTar );
			.Or. ( nOper == 5 );
			.Or. (;
				( oModelTN6:IsDeleted() .Or. oModelTN6:IsInserted() .Or. oModelTN6:IsUpdated() );
				.And. !( oModelTN6:IsDeleted() .And. oModelTN6:IsInserted() );
			) );
			.And. !Empty( oModel:GetValue( 'TN6DETAIL', 'TN6_MAT' );
		)

			cMatricula := oModel:GetValue( 'TN6DETAIL', "TN6_MAT" )
			dDtInic	   := oModel:GetValue( 'TN6DETAIL', "TN6_DTINIC" )
			dDtTerm	   := oModel:GetValue( 'TN6DETAIL', "TN6_DTTERM" )

			//Adiciona o funcionário no array
			aAdd( aFuncs, { cMatricula, , , cCodTar, dDtInic, dDtTerm } )

		EndIf

	Next nCont

	//Caso existam funcionários a serem enviados
	If Len( aFuncs ) > 0
		lRet := MDTIntEsoc( "S-2240", nOper, , aFuncs, lEnvio ) //Valida as informações a serem enviadas ao Governo
	EndIf

Return lRet
