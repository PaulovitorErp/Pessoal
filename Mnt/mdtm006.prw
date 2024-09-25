#INCLUDE "TOTVS.CH"
#INCLUDE "MDTM006.CH"

//---------------------------------------------------------------------
/*/{Protheus.doc} MDTM006
Rotina de Envio de Eventos - Exclusão de Eventos (S-3000)
Realiza a composição do Xml a ser enviado ao Governo

@return cRet, Caracter, Xml com a estrutura do evento de exclusão

@sample MDTM006( 'S-2210' , '000000001' , , '20170101 , { cEmpAnt, cFilAnt } )

@param	cEvento, Caracter, Indica o evento a ser excluído
@param	cNumMat, Caracter, Matrícula do Funcionário
@param	cChave, Caracter, Chave única de busca
	S-2210 - DTOS( TNC->TNC_DTACID ) + TNC->TNC_HRACID + TNC->TNC_TIPCAT
	S-2220 - TMY->TMY_DTEMIS
	S-2240 - TN0->TN0_DTRECO

@author	Luis Fellipy Bett
@since	16/03/2021
/*/
//---------------------------------------------------------------------
Function MDTM006( cEvento, cNumMat, cChave )

	Local cRet	  := ""
	Local aDadFun := MDTDadFun( cNumMat, .T. ) //Array de Informações do Funcionário

	//Variáveis private para composição do Xml
	Private cRecibo	 := "" //Recibo do registro que será excluído
	Private cCpfTrab := aDadFun[ 3 ] //CPF do Funcionário (RA_CIC)

	//Busca da informação a ser enviada na tag <nrRecEvt>
	cRecibo := fGetRcb( cEvento, aDadFun, cChave )

	//Carrega o Xml para retorno
	cRet := fCarrExc( cEvento, cChave )

Return cRet

//---------------------------------------------------------------------
/*/{Protheus.doc} fCarrExc
Monta o Xml do evento de exclusão para envio ao Governo

@return	cXml, Caracter, Estrutura XML a ser enviada para o SIGATAF/Middleware

@sample	fCarrExc( "S2210", "" )

@param	cEvento, Caracter, Evento para que será gerado o evento de exclusão
@param	cChave, Caracter, Chave do registro que será excluído

@author	Luis Fellipy Bett
@since	16/03/2021
/*/
//---------------------------------------------------------------------
Static Function fCarrExc( cEvento, cChave )

	//Variável de composição e retorno do Xml
	Local cXml	  := ""
	Local cEvtAux := "S-" + Right( cEvento, 4 )

	//Cria o cabeçalho do Xml com o ID, informações do Evento e Empregador
	MDTGerCabc( @cXml, cEvento, "3", cChave, .T. )

	cXml += 		'<infoExclusao>'
	cXml += 			'<tpEvento>'	+ cEvtAux + '</tpEvento>'
	cXml += 			'<nrRecEvt>'	+ cRecibo + '</nrRecEvt>'
	cXml += 			'<ideTrabalhador>'
	cXml += 				'<cpfTrab>'	+ cCpfTrab + '</cpfTrab>'
	cXml += 			'</ideTrabalhador>'
	cXml += 		'</infoExclusao>'
	cXml += 	'</evtExclusao>'
	cXml += '</eSocial>'

Return cXml

//-------------------------------------------------------------------
/*/{Protheus.doc} fGetRcb
Busca o recibo do Xml enviado de acordo com a chave passada por parâmetro

@return	cRecibo, Caracter, Recibo do Xml enviado para o evento da chave passada como parâmetro

@param	cEvento, Caracter, Evento para que será buscado o recibo do Xml
@param	nIndEsp, Numérico, Índice a ser considerado na busca do recibo

@sample	fGetRcb()

@author	Luis Fellipy Bett
@since	07/04/2021
/*/
//-------------------------------------------------------------------
Static Function fGetRcb( cEvento, aDadFun, cChave )

	Local aArea	   := GetArea() //Salva a área
	Local cCodTrab := ""
	Local cRecibo  := ""
	Local cTabela  := ""

	If lMiddleware
		cRecibo := MDTVerStat( , cEvento, cChave )[ 5 ]
	Else
		//Pega a tabela do TAF de acordo com o evento
		If "2210" $ cEvento
			cTabela := "CM0"
			nIndEsp := 4
		ElseIf "2220" $ cEvento
			cTabela := "C8B"
			nIndEsp := 2
		ElseIf "2240" $ cEvento
			cTabela := "CM9"
			nIndEsp := 5
		EndIf

		//Busca o código do funcionário no SIGATAF
		cCodTrab := MDTGetIdFun( aDadFun[ 1 ] )

		//Posiciona na tabela com o índice e chave para buscar o valor do campo "XXX_PROTUL"
		dbSelectArea( cTabela )
		dbSetOrder( nIndEsp )
		If dbSeek( xFilial( cTabela ) + cCodTrab + cChave )
			cRecibo := &( cTabela + "->" + cTabela + "_PROTUL" )

			If Empty( cRecibo )
				cRecibo := aDadFun[ 3 ] + aDadFun[ 4 ] + cChave
			EndIf
		EndIf
	EndIf

	RestArea( aArea ) //Retorna a área

Return cRecibo
