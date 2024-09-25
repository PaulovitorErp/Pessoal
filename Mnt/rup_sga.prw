#Include "Protheus.ch"

//-------------------------------------------------------------------
/*/{Protheus.doc} RUP_MDT
Função exemplo de compatibilização do release incremental. Esta função é relativa ao módulo Medicina e Segurança do Trabalho.
Serão chamadas todas as funções compiladas referentes aos módulos cadastrados do Protheus
Será sempre considerado prefixo "RUP_" acrescido do nome padrão do módulo sem o prefixo SIGA.
Ex: para o módulo SIGAMDT criar a função RUP_MDT

@param  cVersion 	Caracter Versão do Protheus
@param  cMode 		Caracter Modo de execução. 1=Por grupo de empresas / 2=Por grupo de empresas + filial (filial completa)
@param  cRelStart 	Caracter Release de partida Ex: 002
@param  cRelFinish 	Caracter Release de chegada Ex: 005
@param  cLocaliz 	Caracter Localização (país) Ex: BRA

@Author Bruno Lobo de Souza
@since 27/11/2017
@version P12
/*/
//-------------------------------------------------------------------
Function RUP_SGA(cVersion, cMode, cRelStart, cRelFinish, cLocaliz)

	//Trativa para quando executado ambiente TOTVS PDV
	#IFDEF TOP
		If ( cVersion == "12" )//Executa somente para versão 7
			//Alterações definidas para o Release 007 ou superiores
			If cRelFinish >= "007"
				If cMode == "1" //Executa para cada Grupo de Empresa
					fValueDef("TAF", "TAF_ETAPA" , "2")
					fValueDef("TCK", "TCK_STATUS", "1")
					fValueDef("TAX", "TAX_TPGERA", "1")
					fValueDef("TCO", "TCO_PRIORI", "3")
					fValueDef("TAA", "TAA_TPMETA", "1")
					fValueDef("TCQ", "TCQ_RETMTR", "2")
					fValueDef("TB6", "TB6_STATUS", "1")
				EndIf
			EndIf
			//Alterações definidas para o Release 017 ou superiores
			If cRelFinish >= "017"
				If cMode == "1"//Executa para cada Grupo de Empresa
					fValueDef("TCS", "TCS_PERIGO" , "1")
				EndIf
			EndIf
		EndIf
	#ENDIF

Return

//-------------------------------------------------------------------
/*/{Protheus.doc} fValueDef
Atribui valor default dos campos
@type  Static Function
@author Bruno Lobo de Souza
@since 27/11/2017
@version P12
@param cTblAlias, Caracter, Alias da tabela cujo campo receberá um valor default
@param cTblField, Caracter, Campo que receberá um valor default
@param cValueDef, Caracter, Valor default a ser atribuido ao campo
@param cCondition, Caracter, Condição para atribuição do valor default ao campo
@return Nil
@example
fValueDef("TLD", "TLD_RECEBI", "1", "TLD_RECEBI = '' AND TLD_SITUAC = '2'")

/*/
//-------------------------------------------------------------------
Static Function fValueDef(cTblAlias, cTblField, cValueDef, cCondition)

	Local cQuery
	Default cCondition := cTblField + " = ''"

	cQuery := "UPDATE "
	cQuery += RetSqlName( cTblAlias )
	cQuery += " SET " + cTblField + " = " + ValToSql(cValueDef)
	cQuery += " WHERE " + cCondition
	TcSqlExec( cQuery )

Return