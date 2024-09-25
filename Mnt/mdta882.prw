#INCLUDE "PROTHEUS.CH"
#INCLUDE "MDTA882.CH"

//---------------------------------------------------------------------
/*/{Protheus.doc} MDTA882
Job que realiza a verificação diária de possíveis novos períodos de tarefas
dos funcionários para envio ao TAF (eSocial).

@return

@sample MDTA882()

@author Luis Fellipy Bett
@since 27/03/18
/*/
//---------------------------------------------------------------------
Function MDTA882()

	//Armazena as variáveis
	Local aNGBEGINPRM

	If FindFunction( "MDTIntEsoc" )
		If IsBlind() //Se via schedule

			If !fProcTar( .T. ) //Processa geração
				FWLogMsg( 'WARN', , 'BusinessObject', 'MDTA882', '', '01', STR0001, 0, 0, {} ) //"Erro na execução do Schedule, favor verificar!"
			Else
				FWLogMsg( 'WARN', , 'BusinessObject', 'MDTA882', '', '01', STR0002, 0, 0, {} ) //"Execução do Schedule realizada com sucesso!"
			EndIf

		Else //Se via rotina

			aNGBEGINPRM := NGBEGINPRM()

			If fProcTar() //Processa a validação e envio do evento S-2240 ao Governo
				Help( ' ', 1, STR0003, , STR0004, 2, 0 ) //"Atenção"##"Processamento realizado com sucesso!"
			EndIf

			NGRETURNPRM( aNGBEGINPRM )
		EndIf
	EndIf

Return .T.

//---------------------------------------------------------------------
/*/{Protheus.doc} fProcTar
Função que envia os dados da tarefa do funcionário ao TAF (eSocial).

@return lRet

@sample fProcTar()

@author Luis Fellipy Bett
@since 27/03/18
/*/
//---------------------------------------------------------------------
Function fProcTar( lSchedule )

	Local lRet		:= .T.
	Local lErro		:= .F.
	Local cMsg		:= ""
	Local cDirFile  := '\esocial_mdt'

	Default lSchedule := .F.

	If !lSchedule //Se for execução via rotina

		lRet := fRisS2240()

	Else //Se for execução via Schedule

		If !File( cDirFile )
			MakeDir( cDirFile )
		EndIf

		cArqPesq := cDirFile + "\mdt_evts2240_" + DToS( Date() ) + "_" + StrTran( Time(), ":", "" ) + ".txt"

		cMsg += "----------------------     MDTA882 | " + DToC( Date() ) + " " + Time() + "     ----------------------"

		If lRet := fRisS2240( @cMsg )
			cMsg += CRLF + "----------   " + STR0003 + " " + STR0005 + "   ----------" //"Atenção!"##"Envio ao SIGATAF/Middleware realizado com sucesso!"
		Else
			cMsg += CRLF + "--------------   " + STR0003 + " " + STR0006 + "   --------------" //"Atenção!"##"Envio ao SIGATAF/Middleware não realizado!"
		EndIf

		nHandle := FCREATE( cArqPesq, 0 ) //Cria arquivo no diretório

		//----------------------------------------------------------------------------------
		// Verifica se o arquivo pode ser criado, caso contrario um alerta sera exibido
		//----------------------------------------------------------------------------------
		If FERROR() <> 0
			lErro := .T.
		Endif

		If !lErro
			FWrite( nHandle, cMsg )

			FCLOSE( nHandle )
		Else
			lRet := .F.
		EndIf
	EndIf

Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} fRisS2240
Função para validar o envio do evento S-2240 ao TAF, na pós validação
do cadastro valida os dados e após a gravação envia ao TAF

@sample fRisS2240()

@param lValid, Lógico, indica se fará a validação dos dados ou o envio

@author  Luis Fellipy Bett
@since   08/08/2019
/*/
//-------------------------------------------------------------------
Static Function fRisS2240( cMsg )

	Local lRet     := .T.
	Local nCont    := 0
	Local aFuncTot := {}
	Local aFuncs   := {}

	Default cMsg := ""

	//Pega todos os funcionários ativos
	aFuncTot := MDTGetFunc()

	For nCont := 1 To Len( aFuncTot )

		//Tarefas por Funcionário
		dbSelectArea( "TN6" )
		dbSetOrder( 2 ) //TN6_FILIAL+TN6_MAT
		dbSeek( xFilial( "TN6" ) + aFuncTot[ nCont, 1 ] )
		While xFilial( "TN6" ) == TN6->TN6_FILIAL .And. TN6->TN6_MAT == aFuncTot[ nCont, 1 ]
			If TN6->TN6_DTINIC = dDataBase .Or. TN6->TN6_DTTERM = dDataBase
				aAdd( aFuncs, { aFuncTot[ nCont, 1 ], , , TN6->TN6_CODTAR, TN6->TN6_DTINIC, TN6->TN6_DTTERM } )
				Exit
			EndIf
			TN6->( dbSkip() )
		End

	Next nCont

	If Len( aFuncs ) > 0
		lRet := MDTIntEsoc( "S-2240", 4, , aFuncs, .T., , , @cMsg ) //Valida e envia informações ao Governo
	EndIf

Return lRet

//---------------------------------------------------------------------
/*/{Protheus.doc} SchedDef
Execução de Parâmetros na Definição do Schedule

@return aParam, Array, Conteudo com as definições de parâmetros para WF

@sample SchedDef()

@author Alexandre Santos
@since 04/07/2018
/*/
//---------------------------------------------------------------------
Static Function SchedDef()
Return { "P", "PARAMDEF", "", {}, "Param" }
