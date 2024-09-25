#include 'Protheus.ch'
#include 'MDTA640A.ch'
#include 'FWMVCDEF.ch'
#include 'Totvs.Ch'

//-------------------------------------------------------------------------------------------------------------
/*/{Protheus.doc} MDT640EVEN
Classe de evento do MVC Acidentes de Trabalho.

@author  Guilherme Freudenburg
@since   19/10/2017
@type    Class
@version 12.1.17
/*/
//-------------------------------------------------------------------------------------------------------------
Class MDT640EVEN FROM FWModelEvent

    Data cChv2210 AS Caracter

	Method New()
	Method GridLinePosVld() //Validação LinOk da Grid
	Method GridPosVld() //Validação Pós-Valid da Grid
    Method ModelPosVld() //Validação Pós-Valid do Modelo
    Method InTTS() //Method executado durante o Commit

End Class

//-------------------------------------------------------------------------------------------------------------
/*/{Protheus.doc} New
Mehtod New para criação da estancia entre o evento e as classes.

@author  Guilherme Freudenburg
@since   19/10/2017
@type    Class
@version 12.1.17
/*/
//-------------------------------------------------------------------------------------------------------------
Method New() Class MDT640EVEN
Return

//-------------------------------------------------------------------------------------------------------------
/*/{Protheus.doc} fValCamObr
Static Function criada para realizar a validação dos campos para o envio do S-2210.

@author Matheus Wilbert
@since 18/12/2023

@param oModel - Objeto - Modelo Utilizado

@return lRet - Retorna se o campo foi alterado ou não.
/*/
//-------------------------------------------------------------------------------------------------------------
Static Function fValCamObr( oModel )
 
	Local lRet 		:= .F.	
	Local oMaster 	:= oModel:GetModel( 'TNCMASTER' )
	Local oCausa 	:= oModel:GetModel( 'TNMCAUSA' 	)
	Local oParte 	:= oModel:GetModel( 'TNMPARTE' )

	If oMaster:IsFieldUpdated( 'TNC_DTACID' ) .Or. oMaster:IsFieldUpdated( 'TNC_INDACI' ) 	.Or. oMaster:IsFieldUpdated( 'TNC_HRACID' );
	.Or. oMaster:IsFieldUpdated( 'TNC_HRTRAB' ) .Or. oMaster:IsFieldUpdated( 'TNC_TIPCAT' ) .Or. oMaster:IsFieldUpdated( 'TNC_MORTE' );
	.Or. oMaster:IsFieldUpdated( 'TNC_DTOBIT' ) .Or. oMaster:IsFieldUpdated( 'TNC_POLICI' ) .Or. oMaster:IsFieldUpdated( 'TNC_DTULTI' ); 	
	.Or. oMaster:IsFieldUpdated( 'TNC_AFASTA' ) .Or. oMaster:IsFieldUpdated( 'TNC_QTAFAS' ) .Or. oMaster:IsFieldUpdated( 'TNC_DETALH' );
	.Or. oMaster:IsFieldUpdated( 'TNC_INDLOC' ) .Or. oMaster:IsFieldUpdated( 'TNC_LOCAL' ) 	.Or. oMaster:IsFieldUpdated( 'TNC_TPLOGR' );
	.Or. oMaster:IsFieldUpdated( 'TNC_DESLOG' ) .Or. oMaster:IsFieldUpdated( 'TNC_NUMLOG' ) .Or. oMaster:IsFieldUpdated( 'TNC_COMPL' );
	.Or. oMaster:IsFieldUpdated( 'TNC_BAIRRO' ) .Or. oMaster:IsFieldUpdated( 'TNC_CEP'	) .Or. oMaster:IsFieldUpdated( 'TNC_CODCID' );
	.Or. oMaster:IsFieldUpdated( 'TNC_ESTACI' ) .Or. oMaster:IsFieldUpdated( 'TNC_CODPAI' ) .Or. oMaster:IsFieldUpdated( 'TNC_CODPOS' );
	.Or. oMaster:IsFieldUpdated( 'TNC_TPINS' ) .Or. oMaster:IsFieldUpdated( 'TNC_CGCPRE' ) .Or. oMaster:IsFieldUpdated( 'TNC_DTATEN' );
	.Or. oMaster:IsFieldUpdated( 'TNC_HRATEN' ) .Or. oMaster:IsFieldUpdated( 'TNC_INTERN' ) .Or. oMaster:IsFieldUpdated( 'TNC_DESLES' );
	.Or. oMaster:IsFieldUpdated( 'TNC_CID' ) .Or. oCausa:IsFieldUpdated( 'TYE_CAUSA' ) .Or. oParte:IsFieldUpdated( 'TYF_LATERA' );
	.Or. oParte:IsFieldUpdated( 'TYF_CODPAR' )	
		lRet := .T.
	EndIf

Return lRet

//-------------------------------------------------------------------------------------------------------------
/*/{Protheus.doc} ModelPosVld
Method para pós-validação do Modelo.

@param oModel - Objeto - Modelo utilizado.
@param cModelId - Caracter - Id do modelo utilizado.

@class MDT640EVEN - Classe origem.

@author  Guilherme Freudenburg
@since   19/10/2017
@type    Class
@version 12.1.17
/*/
//-------------------------------------------------------------------------------------------------------------
Method ModelPosVld( oModel, cModelId ) Class MDT640EVEN

	Local lRet		:= .T.
	Local aAreaTNC	:= TNC->( GetArea() ) //Salva área posicionada.
	Local nOpca		:= oModel:GetOperation() // Operação de ação sobre o Modelo
	Local aOldTNY	:= {}
	Local o685Model

	Private aCHKSQL   := {}  // Variável para consistência na exclusão (via SX9)
	Private aCHKDEL   := {}  // Variável para consistência na exclusão (via Cadastro)
	Private cProcesso := ""

	// Recebe SX9 - Formato:
	// 1 - Domínio (tabela)
	// 2 - Campo do Domínio
	// 3 - Contra-Domínio (tabela)
	// 4 - Campo do Contra-Domínio
	// 5 - Condição SQL
	// 6 - Comparação da Filial do Domínio
	// 7 - Comparação da Filial do Contra-Domínio
	aCHKSQL := NGRETSX9( "TNC" )

	If nOpca == MODEL_OPERATION_DELETE //Exclusão

		If !NGCHKDEL( "TNC" ) //Verifica a integridade da tabela.
			lRet := .F.
		EndIf

	EndIf

	If lRet .And. ( nOpca == MODEL_OPERATION_INSERT .Or. nOpca == MODEL_OPERATION_UPDATE )

		If AliasInDic( "TBV" ) .And. ( nOpca == MODEL_OPERATION_INSERT .Or. ;
			( nOpca == MODEL_OPERATION_UPDATE .And. oModel:GetValue( 'TNCMASTER', 'TNC_OCOPLA' ) <> TNC->TNC_OCOPLA ) )
			dbSelectArea( "TBV" )
			dbSetOrder( 1 )

			If dbSeek( xFilial( "TBV" ) + oModel:GetValue( 'TNCMASTER', 'TNC_OCOPLA' ) )
				dbSelectArea( "TBB" )
				dbSetOrder( 1 )

				If dbSeek( xFilial( "TBB" ) + TBV->TBV_CODPLA ) .And. MsgYesNo( STR0001 ) //"Devido ao acidente estar vinculado a uma ocorrência, o plano emergencial precisa ser reavaliado, deseja alterar o seu status?"
					RecLock( "TBB", .F. )
					TBB->TBB_INDAVA := "2"
					TBB->( MsUnLock() )
				EndIf

			EndIf

		EndIf

		// Atualiza o Afastamento vinculado
		If nOpca == MODEL_OPERATION_UPDATE
			aArea 		:= GetArea()
			aAreaTNC 	:= TNC->( GetArea() )
			dbSelectArea( "TNY" )
			dbSetOrder( 5 )//TNY_FILIAL+TNY_ACIDEN+TNY_NUMFIC+DTOS(TNY_DTINIC)+TNY_HRINIC

			If dbSeek( xFilial( "TNY" ) + oModel:GetValue( 'TNCMASTER', 'TNC_ACIDEN' ) )
				//Chamado para manter a compatibilidade
				aOldTNY := MDT685TNYA()
				o685Model := FwLoadModel( "MDTA685" )
				o685Model:SetOperation( MODEL_OPERATION_UPDATE )
				o685Model:Activate()
				lCpoSr8 := .F.
				A685UPDATE( nOpca, o685Model )
				o685Model:DeActivate()
			EndIf

			RestArea( aAreaTNC )
			RestArea( aArea )
		EndIf

		// Verifica consistencia de CID em Diagnostico e Atestado médico
		If !Empty( oModel:GetValue( 'TNCMASTER', 'TNC_NUMFIC' ) )
			fConsisCID( oModel:GetValue( 'TNCMASTER', 'TNC_ACIDEN' ), oModel:GetValue( 'TNCMASTER', 'TNC_NUMFIC' ), oModel:GetValue( 'TNCMASTER', 'TNC_CID' ) )
		EndIf

	EndIf

	//-------------------------------------------------------------------------------------
	// Realiza as validações das informações do evento S-2210 que serão enviadas ao Governo
	//-------------------------------------------------------------------------------------
	If lRet .And. FindFunction( "MDTIntEsoc" ) .And. fValCamObr( oModel )
		//Variável que guarda a chave atual do registro para busca do registro na RJE e do TAFKEY no TAF
		::cChv2210 := DToS( TNC->TNC_DTACID	) + StrTran( TNC->TNC_HRACID, ":", "" ) + TNC->TNC_TIPCAT

		lRet := MDTIntEsoc( "S-2210", nOpca, oModel:GetValue( 'TNCMASTER', 'TNC_NUMFIC' ), , .F., oModel )
	EndIf

	RestArea( aAreaTNC ) //Retorna área.

Return lRet

//-------------------------------------------------------------------------------------------------------------
/*/{Protheus.doc} InTTS
Method para integração com TAF durante o Commit.

@param oModel - Objeto - Modelo utilizado.
@param cModelId - Caracter - Id do modelo utilizado.

@class MDT640EVEN - Classe origem.

@author  Guilherme Freudenburg
@since   19/10/2017
@type    Class
@version 12.1.17
/*/
//-------------------------------------------------------------------------------------------------------------
Method InTTS( oModel, cModelId ) Class MDT640EVEN

	Local nOpcx		:= oModel:GetOperation()
	Local lSendMail	:= SuperGetMv( "MV_NG2EMAC", .F., "N" ) == "S"

	If AliasInDic( "TBV" ) .And. nOpcx == MODEL_OPERATION_DELETE .Or. ;
		( nOpcx == MODEL_OPERATION_UPDATE .And. oModel:GetValue( 'TNCMASTER', 'TNC_OCOPLA' ) <> TNC->TNC_OCOPLA )
		dbSelectArea( "TBV" )
		dbSetOrder( 1 ) // TBV_FILIAL+TBV_CODOCO+DTOS(TBV_DATA)+TBV_HORA

		If dbSeek( xFilial( "TBV" ) + oModel:GetValue( 'TNCMASTER', 'TNC_OCOPLA' ) )
			dbSelectArea( "TBB" )
			dbSetOrder( 1 ) // TBB_FILIAL+TBB_CODPLA

			If dbSeek( xFilial( "TBB" ) + TBV->TBV_CODPLA ) .And. MsgYesNo( STR0005 ) //"Devido ao acidente estar vinculado a uma ocorrência, o plano emergencial precisa ser reavaliado, deseja alterar o seu status?"
				RecLock( "TBB", .F. )
				TBB->TBB_INDAVA := "2"
				TBB->( MsUnLock() )
			EndIf
		EndIf
	EndIf

	If lSendMail .And. ( nOpcx == MODEL_OPERATION_INSERT .Or. nOpcx = MODEL_OPERATION_UPDATE ) //Caso Inclusão ou Alteração
		fSendMail()
	EndIf

	//-----------------------------------------------------------------
	// Realiza a integração das informações do evento S-2210 ao Governo
	//-----------------------------------------------------------------
	If FindFunction( "MDTIntEsoc" ) .And. fValCamObr( oModel )
		MDTIntEsoc( "S-2210", nOpcx, oModel:GetValue( 'TNCMASTER', 'TNC_NUMFIC' ), , , oModel, , , ::cChv2210 )
	EndIf

Return .T.

//-------------------------------------------------------------------------------------------------------------
/*/{Protheus.doc} GridLinePosVld
Method para Pós-Validação da linha da GRID.

@param oModel - Objeto - Modelo utilizado.
@param cModelId - Caracter - Id do modelo utilizado.
@param nLine - Numérico - Numero da linha.

@class MDT640EVEN - Classe origem.

@author  Guilherme Freudenburg
@since   19/10/2017
@type    Class
@version 12.1.17
/*/
//-------------------------------------------------------------------------------------------------------------
Method GridLinePosVld( oSubModel, cModelId, nLina ) Class MDT640EVEN

	Local lRet 		 := .T.
	Local nLenCompl  := oSubModel:Length()
	Local nCont  	 := 0
	Local cCid		 := ""
	Local cGrCid	 := ""
	Local lValid	 := .T.

	If cModelId == "TNMDCOMPL" //Verifica se é a Grid desejada.

		cCid 	 := oSubModel:GetValue( "TKK_CID" ) //CID
		cGrCid	 := oSubModel:GetValue( "TKK_GRPCID" ) //Grupo CID

		If  Empty( oSubModel:GetValue( "TKK_GRPCID" ) )
			lValid := .F.
		EndIf

		If lValid
			For nCont := 1 To nLenCompl
				oSubModel:GoLine( nCont )
				If nLenCompl > 1 .And. Empty( oSubModel:GetValue( "TKK_GRPCID" ) ) .And. !( oSubModel:IsDeleted() ) .And. Empty( oSubModel:GetValue( "TKK_CID" ) )
					Help( , , STR0002, , STR0006, 5, 5 )//"Informe um Grupo de CID ou um CID ."
					lRet := .F.
				EndIf
				If lRet .And. !Empty( oSubModel:GetValue( "TKK_GRPCID" ) )
					If oSubModel:GetValue( "TKK_GRPCID" ) == cGrCid .And. Empty( cCid )
						Help( , , STR0002, , STR0007 + " ' " + NGRETTITULO( "TKK_CID" ) +" ' " + STR0008, 5, 5 )//"O campo" ## "deve ser preenchido quando já existir outro CID do mesmo grupo."
						lRet := .F.
						Exit
					EndIf
				EndIf
				If  lRet .And. nCont <> 1 .And. Empty( cCid ) .And. Empty( cGrCid )
					//Mostra mensagem de Help
					Help( 1, " ", "OBRIGAT2", , , 3, 0 )
					lRet := .F.
					Exit
				EndIf
			Next nCont
		EndIf

	ElseIf cModelId == "TNMPARTE"

		If Empty( oSubModel:GetValue( "TYF_CODPAR" ) ) .Or. Empty( oSubModel:GetValue( "TYF_LATERA" ) )
			Help( , " ", STR0002, , STR0003 + " " + NGRETTITULO( "TYF_CODPAR" ) + STR0009 + NGRETTITULO( "TYF_LATERA" ) + STR0010, 5, 5, , , , , , { STR0011 } ) //"Os campos XXX e XXX são de preenchimento obrigatório!"##"Favor preenchê-los!"
			lRet := .F.
		EndIf

	EndIf

Return lRet
//-------------------------------------------------------------------------------------------------------------
/*/{Protheus.doc} GridPosVld
Method para Pós-Validação da GRID

@param oModel - Objeto - Modelo utilizado.
@param cModelId - Caracter - Id do modelo utilizado.

@class MDT640EVEN - Classe origem.

@author  Guilherme Freudenburg
@since   19/10/2017
@type    Class
@version 12.1.17
/*/
//-------------------------------------------------------------------------------------------------------------
Method GridPosVld( oSubModel, cModelID ) Class MDT640EVEN

	Local lRet 		 := .T.
	Local nLenCompl  := oSubModel:Length()
	Local nCont		 := 0
	Local cCid 		 := ""
	Local cGrCid	 := ""
	Local lCompDel   := !( oSubModel:IsDeleted() )
	Local lValid	 := .T.

	If cModelID == "TNMDCOMPL"

		cCid	:= oSubModel:GetValue( "TKK_CID" ) //CID
		cGrCid	:= oSubModel:GetValue( "TKK_GRPCID" ) //Grupo CID

		If  Empty( oSubModel:GetValue( "TKK_GRPCID" ) )
			lValid := .F.
		EndIf

		If lValid
			For nCont := 1 To nLenCompl
				oSubModel:GoLine( nCont )
				If !( oSubModel:IsDeleted() ) //Verifica se registro está deletado.
					If lRet .And. !Empty( oSubModel:GetValue( "TKK_GRPCID" ) )
						If oSubModel:GetValue( "TKK_GRPCID" ) == M->TNC_GRPCID .And. ;
						( Empty( oSubModel:GetValue( "TKK_CID" ) ) .Or. Empty( M->TNC_CID ) ) .And. lCompDel
							Help( , , STR0002, , STR0007 + " ' " + NGRETTITULO( "TKK_CID" ) + " ' " + STR0008, 5, 5 ) //"o campo" ## "deve ser preenchido quando já existir outro CID do mesmo grupo."
							lRet := .F.
							Exit
						EndIf
					EndIf
					If lRet .And. !Empty( oSubModel:GetValue( "TKK_GRPCID" ) )
						If oSubModel:GetValue( "TKK_GRPCID" ) == cGrCid .And. Empty( cCid )
							Help( , , STR0002, , STR0007 + " ' " + NGRETTITULO( "TKK_CID" ) + " ' " + STR0008, 5, 5 ) //"o campo" ## "deve ser preenchido quando já existir outro CID do mesmo grupo."
							lRet := .F.
							Exit
						EndIf
					EndIf
				EndIf
				If  lRet .And. nCont <> 1 .And. Empty( cCid ) .And. Empty( cGrCid )
					//Mostra mensagem de Help
					Help( 1, " ", "OBRIGAT2", , , 3, 0 )
					lRet := .F.
					Exit
				EndIf
			Next nCont
		EndIf
	EndIf

Return lRet
