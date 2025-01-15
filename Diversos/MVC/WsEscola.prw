#INCLUDE "PROTHEUS.CH"
#INCLUDE "APWEBSRV.CH"
#INCLUDE "TOPCONN.CH"
#INCLUDE "apwebex.ch"
#include "TOTVS.CH"
#INCLUDE "TBICONN.CH"
#INCLUDE "XMLXFUN.CH"

/*/{Protheus.doc} WS_ESCOLA

Web Service para integração Protheus x SGAC
Definição dos Metodos e Objetos

@author TOTVS
@since 17/02/2017
@version P12
@param Nao recebe parametros
@return nulo
/*/

WSSERVICE WS_ESCOLA DESCRIPTION "Treinamento WebService"


	WSDATA cRecebe				as String
	WSDATA cRetorna				as String
	
	WSDATA Env_CadAluno			as WSEnvCadAluno
	WSDATA Rec_CadAluno			as WSRecCadAluno
	
	WSDATA Env_DadosAluno			as WSEnvDadosAluno
	WSDATA Ret_DadosAluno			as WSRetDadosAluno

	WSMETHOD TESTE DESCRIPTION 		"TESTAR WEB SERVICE" 
	WSMETHOD CAD_ALUNO DESCRIPTION 	"INCLUIR ALUNO"
	WSMETHOD CONS_ALUNO DESCRIPTION "CONSULTAR ALUNO"
	
ENDWSSERVICE

WSMETHOD TESTE WSRECEIVE cRecebe WSSEND cRetorna WSSERVICE WS_ESCOLA

	if ::cRecebe=="1"
		
		::cRetorna := "Sucesso"
		
	else
	
		::cRetorna := "Falha"
	
	endif

Return(.T.)

WSMETHOD CAD_ALUNO WSRECEIVE Env_CadAluno WSSEND Rec_CadAluno WSSERVICE WS_ESCOLA

	U_RCOMA007(@::Env_CadAluno,@::Rec_CadAluno)

Return(.T.)

WSSTRUCT WSEnvCadAluno

	WSDATA 	cFil			as String
	WSDATA 	cRa				as String
	WSDATA 	cNome			as String
	WSDATA 	cDtNasci		as String
	WSDATA 	cSituac			as String

ENDWSSTRUCT

WSSTRUCT WSRecCadAluno

	WSDATA 	lRet			as Boolean
	WSDATA 	cMensagem		as String

ENDWSSTRUCT

WSMETHOD CONS_ALUNO WSRECEIVE Env_DadosAluno WSSEND Ret_DadosAluno WSSERVICE WS_ESCOLA

	U_RCOMA012(@::Env_DadosAluno,@::Ret_DadosAluno)

Return(.T.)

WSSTRUCT WSEnvDadosAluno

	WSDATA 	cFil			as String Optional
	WSDATA 	cRa				as String Optional
	WSDATA 	cNome			as String Optional
	WSDATA 	cDtNasci		as String Optional
	WSDATA 	cSituac			as String Optional

ENDWSSTRUCT

WSSTRUCT WSRetDadosAluno

	WSDATA 	aAlunos		as Array of Aluno Optional

ENDWSSTRUCT

WSSTRUCT Aluno
	
	WSDATA 	cFil			as String 
	WSDATA 	cRa				as String 
	WSDATA 	cNome			as String 
	WSDATA 	cDtNasci		as String 
	WSDATA 	cSituac			as String 

ENDWSSTRUCT