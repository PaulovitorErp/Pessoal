#INCLUDE 'mdtbio.ch'
#INCLUDE 'PROTHEUS.CH'

//------------------------------------------------------------------
/*/{Protheus.doc} MdtBio
Centralizador de funcionalidades de biometria no SIGAMDT
@type  Function
@author bruno.souza
@since 13/04/2022
@param cMedRec, caracter, código da ficha médica 
@return sempre verdadeiro
@example
MdtBio( "000001" )
/*/
//------------------------------------------------------------------
Function MdtBio(cMedRec)

	Local cDigital

	cDigital := EnrollBio()

	If !Empty(cDigital) //Se digital preenchida, grava na TM0
		fRecBio(cDigital, cMedRec)
	EndIf

Return .T.

//------------------------------------------------------------------
/*/{Protheus.doc} EnrollBio
Funcionalidade de captura das digitais
@type  Function
@author bruno.souza
@since 13/04/2022
@return cDigital, caracter, hash da digital capturada
@example
EnrollBio()
/*/
//------------------------------------------------------------------
Function EnrollBio()

	cDigital := CallWSNit( 1 ) 

Return cDigital

//------------------------------------------------------------------
/*/{Protheus.doc} MatchBio
Função de comparação de digitais
@type  Function
@author bruno.souza
@since 13/04/2022
@param cDigital, caracter, hash da digital para comparação
@return return_var, return_type, return_description
@example
MatchBio( cDigital )
/*/
//------------------------------------------------------------------
Function MatchBio( cDigital )
	
	Local lOK := CallWSNit( 2, cDigital ) == "OK"

Return lOK

//-------------------------------------------------------------------
/*/{Protheus.doc} CallWSNit
Execução da API da Nitgen.
É necessária a execução da API via remote, pois o a API precisa estar na maquina 
do usuário, juntamente com o SmartClient, enquanto o appServer estará normalmente
sendo executado no servidor.

@type Function
@author bruno.souza
@since 18/01/2022

@param nType, numeric, tipo de operação a ser realizada
1 - Enroll, captura as digitais
2 - Match, compara digital
@param cDigital, caracter, hash da digital

@return cReturn, 
	caracter, hash da digital capturada ou
	validação da comparação da digital 
@example
CallWSNit( 1, cDigital )
/*/
//-------------------------------------------------------------------
Function CallWSNit(nType, cDigital)
	
	Local cReturn
	Local cNG2Host := SuperGetMV('MV_NG2HOST', .F., 'http://localhost:9000' )
	Local cBioHost := IIF( !Empty( cNG2Host ), cNG2Host, 'http://localhost:9000' ) //Paliativo para default do parâmetro, SuperGetMV não está retornando.
	Local cFileSave := "biometry.txt"
	Local cExec := 'cmd /c "curl ' + cBioHost + '/api/public/v1/captura/Enroll/1 > '+ cFileSave+ '"'
	Local cFileCompareSave := "compare_biometry.txt"
	Local cExecCompare := 'cmd /c "curl ' + cBioHost + '/api/public/v1/captura/Comparar?Digital='
	Local cExecFileCompare := ' > '+ cFileCompareSave+ '"'
	Local cRetCompare := ''
	Local cRmtPath
	
	// Recebe a pasta do SmartClient 
	cRmtPath := GETREMOTEININAME()
	cRmtPath := Left( cRmtPath, Rat( '\',cRmtPath ) )

	If nType == 1
		WaitRun( cExec, 0 )
		If File( cRmtPath + cFileSave )
			cReturn := MemoRead( cRmtPath + cFileSave )
			
		Else
			cReturn := ''
			Help( ' ', 1, STR0005,, STR0001 + STR0004, 2, 0,,,,,, { STR0002 } )
		EndIf

	ElseIf nType == 2
		WaitRun( cExecCompare + cDigital + cExecFileCompare, 0 )
		
		If File( cRmtPath + cFileCompareSave )
			cRetCompare := MemoRead( cRmtPath + cFileCompareSave )
			If ( cRetCompare != '"OK"' )
				cReturn := ''
				Help( ' ', 1, STR0005,, STR0001 + STR0003, 2, 0,,,,,, { STR0002 } )
			Else
				cReturn := "OK"
			EndIf
		EndIf
	EndIf

Return cReturn

//-------------------------------------------------------------------
/*/{Protheus.doc} fRecBio
Grava biometria no campo da TM0

@author bruno.souza
@since 02/06/2022

@param cDigital, caracter, hash da digital
@param cMedRec, caracter, código da ficha médica

@return sempre verdadeiro
/*/
//-------------------------------------------------------------------
Function fRecBio(cDigital, cMedRec)

	DbSelectArea( 'TM0' )
	( 'TM0' )->( DbSetOrder( 1 ) )

	If ( 'TM0' )->( DbSeek( xFilial( 'TM0' ) + cMedRec ) )

		RecLock( 'TM0', .F. )
			TM0->TM0_REGBIO := cDigital
		MsUnlock()

	EndIf

Return
