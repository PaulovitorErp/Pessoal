#INCLUDE "TOTVS.CH"
#INCLUDE "FWMVCDEF.CH"
#INCLUDE "mdtm003.CH"

//-------------------------------------------------------------------------------------------------------------------
//-------------------------------------------------------------------------------------------------------------------
//-------------------------------------------------------------------------------------------------------------------
//  _______           _______  _       _________ _______             _______  _______  _______  _______  _______  ---
// (  ____ \|\     /|(  ____ \( (    /|\__   __/(  ___  )           (  ____ \/ ___   )/ ___   )/ ___   )(  __   ) ---
// | (    \/| )   ( || (    \/|  \  ( |   ) (   | (   ) |           | (    \/\/   )  |\/   )  |\/   )  || (  )  | ---
// | (__    | |   | || (__    |   \ | |   | |   | |   | |   _____   | (_____     /   )    /   )    /   )| | /   | ---
// |  __)   ( (   ) )|  __)   | (\ \) |   | |   | |   | |  (_____)  (_____  )  _/   /   _/   /   _/   / | (/ /) | ---
// | (       \ \_/ / | (      | | \   |   | |   | |   | |                 ) | /   _/   /   _/   /   _/  |   / | | ---
// | (____/\  \   /  | (____/\| )  \  |   | |   | (___) |           /\____) |(   (__/\(   (__/\(   (__/\|  (__) | ---
// (_______/   \_/   (_______/|/    )_)   )_(   (_______)           \_______)\_______/\_______/\_______/(_______) ---
//-------------------------------------------------------------------------------------------------------------------
//-------------------------------------------------------------------------------------------------------------------
//-------------------------------------------------------------------------------------------------------------------
//-------------------------------------------------------------------------------------------------------------------
/*/{Protheus.doc} MDTM003
Rotina de Envio de Eventos - Monitoramento da Saúde do Trabalhador (S-2220)
Realiza a composição do Xml a ser enviado ao Governo

@return cRet, Caracter, Retorna o Xml gerado pelo ASO

@sample MDTM003( 3, .T., {} )

@param nOper, Numérico, Indica a operação que está sendo realizada (3-Inclusão/4-Alteração/5-Exclusão)
@param lIncons, Boolean, Indica se é avaliação de inconsistências das informações de envio
@param aIncEnv, Array, Array que recebe as inconsistências, se houver, das informações a serem enviadas
@param cChave, Caracter, Chave atual do registro a ser utilizada na busca do registro na RJE
@param cChvASO, Caracter, Chave do ASO a ser validado/comunicado (Filial + Código do ASO)

@author Luis Fellipy Bett
@since	29/11/2017
/*/
//----------------------------------------------------------------------------------------------------
Function MDTM003( nOper, lIncons, aIncEnv, cChave, cChvASO )

	Local aArea	   := GetArea()
	Local aAreaTMY := TMY->( GetArea() )
	Local cRet	   := ""

	//Variáveis de chamadas
	Local lImpASO := IsInCallStack( "NGIMPRASO" ) .Or. IsInCallStack( "MDTR465" ) .Or. IsInCallStack( "NG200IMP" ) .Or. IsInCallStack( "fValAsoAdm" )
	Local lXml	  := IsInCallStack( "MDTGeraXml" ) //Verifica se é geração de Xml

	//Busca as informações do funcionário
	Local aDadFun := {}

	//Variáveis auxiliares para busca das informações a serem enviadas
	Private cNumMat			:= "" //Matrícula do Funcionário (RA_MAT)
	Private cNomeFun		:= "" //Nome do Funcionário (RA_NOME)
	Private dDtAdm			:= SToD( "" ) //Data de Admissão do Funcionário (RA_ADMISSA)
	Private cCodMedico		:= "" //Código do Médico Emitente do ASO (TMY_CODUSU)
	Private cCodResp		:= "" //Código do Médico Responsável/Coordenador do PCMSO
	Private cCodUsu		    := "" //Código usuário SESMT

	//Variáveis das informações a serem envidas
	Private cCpfTrab		:= "" //CPF do Funcionário (RA_CIC)
	Private cMatricula		:= "" //Matrícula do Funcionário a ser considerada no envio (RA_CODUNIC)
	Private cCodCateg		:= "" //Categoria do Funcionário (RA_CATEFD)
	Private cTpExameOcup	:= "" //Tipo do Exame Médico Ocupacional (TMY_NATEXA)
	Private dDtASO			:= SToD( "" ) //Data de Emissão do ASO (TMY_DTEMIS ou a data atual)
	Private cResAso			:= "" //Resultado do ASO (TMY_INDPAR)
	Private aExaAtes		:= {} //Exames relacionados ao ASO
	Private cNmMed			:= "" //Nome do Médico Emitente do ASO (TMK_NOMUSU)
	Private cNrCrmMed		:= "" //Número de Inscrição do Emitente do ASO no CRM (TMK_NUMENT)
	Private cUfCrmMed		:= "" //UF de Expedição do CRM do Médico Emitente do ASO (TMK_UF)
	Private cCpfResp		:= "" //CPF do médico responsável/coordenador do PCMSO (TMK_CIC)
	Private cNmResp			:= "" //Nome do médico responsável/coordenador do PCMSO (TMK_NOMUSU)
	Private cNrCrmResp		:= "" //Número de inscrição do médico responsável/coordenador do PCMSO no CRM (TMK_NUMENT)
	Private cUfCRMResp		:= "" //UF de expedição do CRM do Médico responsável/coordenador do PCMSO (TMK_UF)

	Default nOper	:= 3
	Default lIncons	:= .F.
	Default cChvASO := ""

	If lImpASO .Or. lXml //Alimenta as variáveis de memória para utilização
		dbSelectArea( "TMY" )
		dbSetOrder( 1 )
		dbSeek( IIf( !Empty( cChvASO ), cChvASO, TMY->TMY_FILIAL + TMY->TMY_NUMASO ) )
		RegToMemory( "TMY", .F., , .F. ) //Carrega os valores do ASO na memória
	EndIf

	//Busca as informações do funcionário
	aDadFun := MDTDadFun( IIf( lImpASO .Or. lXml, TMY->TMY_NUMFIC, M->TMY_NUMFIC ) )

	//Variáveis auxiliares para busca de informações a serem enviadas
	cNumMat		:= aDadFun[1] //Matrícula do Funcionário
	cNomeFun	:= aDadFun[2] //Nome do Funcionário
	dDtAdm		:= aDadFun[6] //Data de Admissão do Funcionário
	cCodMedico	:= M->TMY_CODUSU //Código do Médico Emitente do ASO

	If Empty( cCodUsu )
		cCodUsu := MDTASOCoord( M->TMY_DTGERA ) //Busca o código do Médico Coordenador do PCMSO
	EndIf

	cCodResp := cCodUsu

	//Busca da informação a ser enviada na tag <cpfTrab>
	cCpfTrab := aDadFun[3] //CPF do Funcionário

	//Busca da informação a ser enviada na tag <matricula>
	cMatricula := aDadFun[4] //Código Único do Funcionário

	//Busca da informação a ser enviada na tag <codCateg>
	cCodCateg := aDadFun[5] //Categoria do Funcionário

	//Busca da informação a ser enviada na tag <tpExameOcup>
	cTpExameOcup := MDTTpASO( M->TMY_NATEXA )

	//Busca da informação a ser enviada na tag <dtAso>
	dDtASO := IIf( !Empty( M->TMY_DTEMIS ), M->TMY_DTEMIS, dDataBase )

	//Busca da informação a ser enviada na tag <resAso>
	cResAso := M->TMY_INDPAR

	//Se o resultado do parecer do ASO for igual a "Apto com Restrição" verifica o parâmetro
	If cResAso == "3"
		If SuperGetMv( "MV_NG2RASO", .F., "1" ) == "1"
			cResAso := "1" //Apto
		Else
			cResAso := "2" //Inapto
		EndIf
	EndIf

	//Busca da informação a ser enviada nas tags <dtExm>, <procRealizado>, <obsProc>, <ordExame> e <indResult>
	aExaAtes := fBusExa( nOper, M->TMY_NUMASO, lImpASO, lXml, lIncons )

	//Busca da informação a ser enviada na tag <nmMed>
	cNmMed := Posicione( "TMK", 1, xFilial( "TMK" ) + cCodMedico, "TMK_NOMUSU" )

	//Busca da informação a ser enviada na tag <nrCRM>
	If !( 'S_01_02' $ MdtRetLei( 'S-2220' ) ) // Validação Leiaute S-1.1 (Remover condição a partir do dia 22/01/2024)
		cNrCrmMed := SubStr( Posicione( "TMK", 1, xFilial( "TMK" ) + cCodMedico, "TMK_NUMENT" ), 1, 8 )
	Else // Validação Leiaute S-1.2
		cNrCrmMed := SubStr( Posicione( "TMK", 1, xFilial( "TMK" ) + cCodMedico, "TMK_NUMENT" ), 1, 10 )
	EndIf

	//Busca da informação a ser enviada na tag <ufCRM>
	cUfCrmMed := Posicione( "TMK", 1, xFilial( "TMK" ) + cCodMedico, "TMK_UF" )

	//Busca da informação a ser enviada na tag <cpfResp>
	cCpfResp := Posicione( "TMK", 1, xFilial( "TMK" ) + cCodResp, "TMK_CIC" )

	//Busca da informação a ser enviada na tag <nmResp>
	cNmResp := Posicione( "TMK", 1, xFilial( "TMK" ) + cCodResp, "TMK_NOMUSU" )

	//Busca da informação a ser enviada na tag <nrCRM>
	If !( 'S_01_02' $ MdtRetLei( 'S-2220' ) ) // Validação Leiaute S-1.1 (Remover condição a partir do dia 22/01/2024)
		cNrCrmResp := SubStr( Posicione( "TMK", 1, xFilial( "TMK" ) + cCodResp, "TMK_NUMENT" ), 1, 8 )
	Else // Validação Leiaute S-1.2
		cNrCrmResp := SubStr( Posicione( "TMK", 1, xFilial( "TMK" ) + cCodResp, "TMK_NUMENT" ), 1, 10 )
	EndIf

	//Busca da informação a ser enviada na tag <ufCRM>
	cUfCRMResp := Posicione( "TMK", 1, xFilial( "TMK" ) + cCodResp, "TMK_UF" )

	//Realiza a verificação das inconsistências ou carrega o Xml
	If lIncons
		fInconsis( @aIncEnv )
	Else
		cRet := fCarrASO( cValToChar( nOper ), cChave )
	EndIf

	RestArea( aAreaTMY )
	RestArea( aArea )

Return cRet

//---------------------------------------------------------------------
/*/{Protheus.doc} fCarrASO
Monta o Xml do ASO para envio ao Governo

@return cXml, Caracter, Xml com as informações a serem enviadas ao SIGATAF/Middleware

@sample fCarrASO( "3", "D MG 01" )

@param cOper, Caracter, Indica a operação que está sendo realizada ("3"-Inclusão/"4"-Alteração/"5"-Exclusão)
@param cChave, Caracter, Chave atual do registro a ser utilizada na busca do registro na RJE

@author Luis Fellipy Bett
@since 30/08/2018
/*/
//---------------------------------------------------------------------
Static Function fCarrASO( cOper, cChave )

	Local cXml	:= ""
	Local nCont	:= 0
	Local lIndResult := SuperGetMv( "MV_NG2INDR", .F., "1" ) == "1"

	Default cOper := "3"

	//Cria o cabeçalho do Xml com o ID, informações do Evento e Empregador
	MDTGerCabc( @cXml, "S2220", cOper, cChave )

	//TRABALHADOR
	cXml += 		'<ideVinculo>'
	cXml += 			'<cpfTrab>'		+ cCpfTrab		+ '</cpfTrab>' //Obrigatório
	If !MDTVerTSVE( cCodCateg ) //Caso não for TSVE
		cXml +=			'<matricula>'	+ cMatricula	+ '</matricula>' //Obrigatório
	Else
		cXml +=			'<codCateg>'	+ cCodCateg		+ '</codCateg>' //Obrigatório
	EndIf
	cXml += 		'</ideVinculo>'

	//ATESTADO ASO
	cXml += 		'<exMedOcup>'
	cXml += 			'<tpExameOcup>' + cTpExameOcup + '</tpExameOcup>' //Obrigatório
	cXml += 			'<aso>'
	cXml += 				'<dtAso>'	+ MDTAjsData( dDtASO )	+ '</dtAso>' //Obrigatório
	cXml += 				'<resAso>'	+ cResAso		 		+ '</resAso>' //Obrigatório
	For nCont := 1 To Len( aExaAtes )
		cXml += 			'<exame>' //Exame Ocupacional
		cXml += 				'<dtExm>' 		  + MDTAjsData( aExaAtes[ nCont, 3 ] )	+ '</dtExm>' //Obrigatório
		cXml += 				'<procRealizado>' + aExaAtes[ nCont, 4 ]		+ '</procRealizado>' //Obrigatório
		If !Empty( aExaAtes[ nCont, 5 ] )
			cXml += 			'<obsProc>'		  + aExaAtes[ nCont, 5 ]		+ '</obsProc>'
		EndIf
		cXml += 				'<ordExame>'	  + aExaAtes[ nCont, 6 ]		+ '</ordExame>' //Obrigatório
		If lIndResult .And. !Empty( aExaAtes[ nCont, 7 ] ) //Caso seja definido o envio pelo parâmetro e não esteja vazio, compõem a tag
			cXml += 			'<indResult>'	  + aExaAtes[ nCont, 7 ]		+ '</indResult>'
		EndIf
		cXml += 			'</exame>'
	Next nCont
	cXml += 				'<medico>' //Médico Emitente do ASO
	cXml += 					'<nmMed>'	+ AllTrim( MDTSubTxt( cNmMed ) )	+ '</nmMed>' //Obrigatório

	If !( 'S_01_02' $ MdtRetLei( 'S-2220' ) ) .Or. !Empty( cNrCrmMed ) // Não obrigatório no leiaute S-1.2
		cXml += 					'<nrCRM>'	+ AllTrim( cNrCrmMed )				+ '</nrCRM>' //Obrigatório
	EndIf

	If !( 'S_01_02' $ MdtRetLei( 'S-2220' ) ) .Or. !Empty( cUfCrmMed ) // Não obrigatório no leiaute S-1.2
		cXml += 					'<ufCRM>'	+ cUfCrmMed							+ '</ufCRM>' //Obrigatório
	EndIf

	cXml += 				'</medico>'
	cXml += 			'</aso>'
	If !Empty( cCodResp ) //Se caso exisitr um médico responsável pelo PCMSO
		cXml +=			'<respMonit>' //Médico Responsável/Coordenador do PCMSO
		cXml +=				'<cpfResp>'	+ cCpfResp							+ '</cpfResp>'
		cXml +=				'<nmResp>'	+ AllTrim( MDTSubTxt( cNmResp ) )	+ '</nmResp>'
		cXml +=				'<nrCRM>'	+ AllTrim( cNrCrmResp )				+ '</nrCRM>'
		cXml +=				'<ufCRM>'	+ cUfCRMResp						+ '</ufCRM>'
		cXml +=			'</respMonit>'
	EndIf
	cXml += 		'</exMedOcup>'
	cXml += 	'</evtMonit>'
	cXml += '</eSocial>'

Return cXml

//---------------------------------------------------------------------
/*/{Protheus.doc} fInconsis
Valida as informações a serem enviadas para o SIGATAF/Middleware

@return	Nil, Nulo

@sample fInconsis( aIncEnv )

@param	aIncEnv, Array, Array passado por referência que irá receber os logs de inconsistências (se houver)

@author	Luis Fellipy Bett
@since	30/08/2018 - Refatorada em: 17/02/2021
/*/
//---------------------------------------------------------------------
Static Function fInconsis( aIncEnv )

	Local aArea	  	:= GetArea()

	Local cFilBkp 	:= cFilAnt
	Local cStrFil	:= STR0036 + ": " + AllTrim( cFilEnv ) //Filial: XXX
	Local cStrASO	:= STR0001 + ": " + M->TMY_NUMASO //Atestado ASO: XXX
	Local cStrFunc	:= STR0002 + ": " + AllTrim( cNumMat ) + " - " + AllTrim( cNomeFun ) //Funcionário: XXX - XXXXX
	Local cStrEmit	:= STR0003 + ": " + AllTrim( cCodMedico ) + " - " + AllTrim( cNmMed ) //Médico Emitente do ASO: XXX - XXXXX
	Local cStrResp	:= STR0004 + ": " + AllTrim( cCodResp ) + " - " + AllTrim( cNmResp ) //Médico Responsável/Coordenador do PCMSO: XXX - XXXXX

	Local lResExt 	:= MdtEndExt( xFilial( 'SRA' ), cNumMat )

	Local nCont		:= 0

	//Seta a filial de envio para as validações de tabelas do TAF
	cFilAnt := cFilEnv

	Help := .T. //Desativa as mensagens de Help

	//Validação da tag <cpfTrab> - CPF do trabalhador
	//Preencher com o número do CPF do trabalhador.
	//Informação obrigatória.
	If Empty( cCpfTrab )
		aAdd( aIncEnv, cStrFil + " / " + cStrFunc + " / " + STR0013 + ": " + STR0007 ) //Funcionário: XXX - XXXXX / CPF: Em branco
		aAdd( aIncEnv, '' )
	ElseIf !CHKCPF( cCpfTrab )
		aAdd( aIncEnv, cStrFil + " / " + cStrFunc + " / " + STR0013 + ": " + cCpfTrab ) //Funcionário: XXX - XXXXX / CPF: XXX
		aAdd( aIncEnv, STR0008 + ": " + STR0012 ) //Validação: Deve ser um número de CPF válido
		aAdd( aIncEnv, '' )
	EndIf

	//Validação da tag <matricula> - Matrícula atribuída ao trabalhador pela empresa
	//Deve corresponder à matrícula informada pelo empregador no evento S-2190, S-2200 ou S-2300 do respectivo contrato. Não preencher no caso de
	//Trabalhador Sem Vínculo de Emprego/Estatutário - TSVE sem informação de matrícula no evento S-2300
	//A validação de existência de um registro S-2190, S-2200 ou S-2300 já é realizada no começo do envio, através da função MDTVld2200

	//Validação da tag <codCateg> - Código da categoria do trabalhador
	//Informação obrigatória e exclusiva se não houver preenchimento de matricula. Se informado, deve ser um código válido e existente na Tabela 01.
	If Empty( cMatricula ) .And. Empty( cCodCateg )
		aAdd( aIncEnv, cStrFil + " / " + cStrFunc + " / " + STR0014 + ": " + STR0007 ) //Funcionário: XXX - XXXXX / Categoria: Em branco
		aAdd( aIncEnv, '' )
	ElseIf Empty( cMatricula ) .And. !ExistCPO( "C87", cCodCateg, 2 )
		aAdd( aIncEnv, cStrFil + " / " + cStrFunc + " / " + STR0014 + ": " + cCodCateg ) //Funcionário: XXX - XXXXX / Categoria: XXX
		aAdd( aIncEnv, STR0008 + ": " + STR0015 ) //Validação: Deve ser um código válido e existente na tabela 01 do eSocial
		aAdd( aIncEnv, '' )
	EndIf

	//Validação da tag <dtAso> - Data de emissão do ASO
	//Validação: Deve ser uma data válida, igual ou anterior à data atual e igual ou posterior à data de início da obrigatoriedade deste 
	//evento para o empregador no eSocial. Se tpExameOcup for diferente de [0], também deve ser igual ou posterior à data de 
	//admissão/exercício ou de início.
	//Informação obrigatória.
	If Empty( dDtASO )
		aAdd( aIncEnv, cStrFil + " / " + cStrASO + " / " + STR0019 + ": " + STR0007 ) //Atestado ASO: XXX / Data de Emissão do ASO: Em branco
		aAdd( aIncEnv, '' )
	ElseIf !( dDtASO <= dDataBase .And. dDtASO >= dDtEsoc .And. IIf( cTpExameOcup != "0", dDtASO >= dDtAdm, .T. ) )
		aAdd( aIncEnv, cStrFil + " / " + cStrASO + " / " + STR0019 + ": " + DToC( dDtASO ) ) //Atestado ASO: XXX / Data de Emissão do ASO: XX/XX/XXXX
		aAdd( aIncEnv, STR0008 + ": " + STR0020 + ": " ) //Validação: Deve ser uma data válida e:
		aAdd( aIncEnv, "* " + STR0021 + ": " + DToC( dDataBase ) ) //* Igual ou anterior à data atual: XX/XX/XXXX
		aAdd( aIncEnv, "* " + STR0022 + ": " + DToC( dDtEsoc ) ) //* Igual ou posterior à data de início de obrigatoriedade dos eventos de SST ao eSocial: XX/XX/XXXX
		aAdd( aIncEnv, "* " + STR0038 + ": " + DToC( dDtAdm ) ) //* Igual ou posterior à data de admissão do funcionário quando o ASO for diferente de admissional: XX/XX/XXXX
		aAdd( aIncEnv, '' )
	EndIf

	//Validação da tag <resAso> - Resultado do ASO
	//Valores válidos: 1 - Apto ou 2 - Inapto
	//Informação obrigatória.
	If Empty( cResAso )
		aAdd( aIncEnv, cStrFil + " / " + cStrASO + " / " + STR0023 + ": " + STR0007 ) //Atestado ASO: XXX / Resultado do ASO: Em branco
		aAdd( aIncEnv, '' )
	ElseIf !( cResAso $ "1/2" )
		aAdd( aIncEnv, cStrFil + " / " + cStrASO + " / " + STR0023 + ": " + cResAso ) //Atestado ASO: XXX / Resultado do ASO: XXX
		aAdd( aIncEnv, STR0008 + ": " + STR0024 ) //Validação: Deve ser igual a 1- Apto ou 2- Inapto
		aAdd( aIncEnv, '' )
	EndIf

	//Validação das tags <dtExm>, <procRealizado>, <obsProc>, <ordExame> e de existência de exames relacionados ao ASO
	If Len( aExaAtes ) > 0
		For nCont := 1 To Len( aExaAtes )

			//Validação da tag <dtExm> - Data do Exame
			//Deve ser uma data válida, igual ou anterior à data do ASO informada em dtAso.
			//Informação obrigatória.
			If Empty( aExaAtes[ nCont, 3 ] ) //<dtExm> - Data do exame realizado
				aAdd( aIncEnv, cStrFil + " / " + cStrFunc ) //Funcionário: XXX - XXXXX
				aAdd( aIncEnv, STR0025 + ": " + AllTrim( aExaAtes[ nCont, 1 ] ) + " - " + AllTrim( aExaAtes[ nCont, 2 ] ) + " / " + STR0026 + ": " + STR0007 ) //Exame: XXX / Data de Realização: Em branco
				aAdd( aIncEnv, '' )
			ElseIf !( aExaAtes[ nCont, 3 ] <= dDtASO ) //<dtExm> - Data do exame realizado
				aAdd( aIncEnv, cStrFil + " / " + cStrFunc ) //Funcionário: XXX - XXXXX
				aAdd( aIncEnv, STR0025 + ": " + AllTrim( aExaAtes[ nCont, 1 ] ) + " - " + AllTrim( aExaAtes[ nCont, 2 ] ) + " / " + STR0026 + ": " + DToC( aExaAtes[ nCont, 3 ] ) ) //Exame: XXX / Data de Realização: XX/XX/XXXX
				aAdd( aIncEnv, STR0008 + ": " + STR0020 + ": " ) //Validação: Deve ser uma data válida e:
				aAdd( aIncEnv, "* " + STR0039 + ": " + DToC( dDtASO ) ) //* Igual ou anterior a data de emissão do ASO: XX/XX/XXXX
				aAdd( aIncEnv, '' )
			EndIf

			//Validação da tag <procRealizado> - Procedimento Diagnóstico
			//Validação: Deve ser um código válido e existente na Tabela 27
			//Informação obrigatória.
			If Empty( aExaAtes[ nCont, 4 ] ) //<procRealizado>
				aAdd( aIncEnv, cStrFil + " / " + cStrFunc ) //Funcionário: XXX - XXXXX
				aAdd( aIncEnv, STR0025 + ": " + AllTrim( aExaAtes[ nCont, 1 ] ) + " - " + AllTrim( aExaAtes[ nCont, 2 ] ) + " / " + STR0028 + ": " + STR0007 ) //Exame: XXX / Procedimento Diagnóstico: Em branco
				aAdd( aIncEnv, '' )
			ElseIf !ExistCPO( "V2K", aExaAtes[ nCont, 4 ], 2 ) //<procRealizado>
				aAdd( aIncEnv, cStrFil + " / " + cStrFunc ) //Funcionário: XXX - XXXXX
				aAdd( aIncEnv, STR0025 + ": " + AllTrim( aExaAtes[ nCont, 1 ] ) + " - " + AllTrim( aExaAtes[ nCont, 2 ] ) + " / " + STR0028 + ": " + aExaAtes[ nCont, 4 ] ) //Exame: XXX / Procedimento Diagnóstico: XXX
				aAdd( aIncEnv, STR0008 + ": " + STR0029 ) //Validação: Deve ser um código válido e existente na tabela 27 do eSocial
				aAdd( aIncEnv, '' )
			EndIf

			//Validação da tag <obsProc> - Observação do Procedimento Diagnóstico
			//Validação: Preenchimento obrigatório se procRealizado = [0583, 0998, 0999, 1128, 1230, 1992, 1993, 1994, 1995, 1996, 1997, 1998, 1999, 9999].
			If aExaAtes[ nCont, 4 ] $ "0583/0998/0999/1128/1230/1992/1993/1994/1995/1996/1997/1998/1999/9999" .And. Empty( aExaAtes[ nCont, 5 ] ) //<obsProc>
				aAdd( aIncEnv, cStrFil + " / " + cStrFunc ) //Funcionário: XXX - XXXXX
				aAdd( aIncEnv, STR0025 + ": " + AllTrim( aExaAtes[ nCont, 1 ] ) + " - " + AllTrim( aExaAtes[ nCont, 2 ] ) + " / " + STR0037 + ": " + STR0007 ) //Exame: XXX / Observação sobre o Procedimento Diagnóstico: Em branco
				aAdd( aIncEnv, '' )
			EndIf

			//Validação da tag <ordExame> - Ordem do Exame
			//Valores válidos: 1 - Inicial ou 2 - Sequencial
			//Validação: Preenchimento obrigatório se procRealizado = [0281].
			If Empty( aExaAtes[ nCont, 6 ] ) .And. aExaAtes[ nCont, 4 ] $ "0281" //<ordExame>
				aAdd( aIncEnv, cStrFil + " / " + cStrASO + " / " + STR0030 + ": " + STR0007 ) //Atestado ASO: XXX / Indicativo do Tipo de Exame: Em branco
				aAdd( aIncEnv, '' )
			ElseIf !Empty( aExaAtes[ nCont, 6 ] ) .And. !( aExaAtes[ nCont, 6 ] $ "1/2" ) //<ordExame>
				aAdd( aIncEnv, cStrFil + " / " + cStrASO + " / " + STR0030 + ": " + aExaAtes[ nCont, 6 ] ) //Atestado ASO: XXX / Indicativo do Tipo de Exame: XXX
				aAdd( aIncEnv, STR0008 + ": " + STR0031 ) //Validação: Deve ser igual a 1- Inicial ou 2- Sequencial
				aAdd( aIncEnv, '' )
			EndIf

		Next nCont
	Else
		aAdd( aIncEnv, cStrFil + " / " + cStrASO + " / " + STR0032 ) //Atestado ASO: XXX / Não existem exames do tipo Ocupacional relacionados ao ASO
		aAdd( aIncEnv, '' )
	EndIf

	//Validação da tag <nmMed> - Nome do médico emitente do ASO
	//Informação obrigatória
	If Empty( cNmMed )
		aAdd( aIncEnv, cStrFil + " / " + cStrEmit + " / " + STR0033 + ": " + STR0007 ) //Médico Emitente do ASO: XXX - XXXXX / Nome: Em branco
		aAdd( aIncEnv, '' )
	EndIf

	//Validação da tag <nrCRM> - Número de inscrição do médico emitente do ASO no Conselho Regional de Medicina - CRM
	//Informação obrigatória
	If Empty( cNrCrmMed ) .And. !lResExt // Se extiver vazio e o endereço não for no exterior
		aAdd( aIncEnv, cStrFil + " / " + cStrEmit + " / " + STR0034 + ": " + STR0007 ) //Médico Emitente do ASO: XXX - XXXXX / Número de Inscrição no CRM: Em branco
		aAdd( aIncEnv, '' )
	EndIf

	//Validação da tag <ufCRM> - UF de expedição do CRM
	//Valores válidos: AC, AL, AP, AM, BA, CE, DF, ES, GO, MA, MT, MS, MG, PA, PB, PR, PE, PI, RJ, RN, RS, RO, RR, SC, SP, SE, TO
	//Informação obrigatória
	If Empty( cUfCrmMed ) .And. !lResExt // Se extiver vazio e o endereço não for no exterior
		aAdd( aIncEnv, cStrFil + " / " + cStrEmit + " / " + STR0035 + ": " + STR0007 ) //Médico Emitente do ASO: XXX - XXXXX / UF de Expedição do CRM: Em branco
		aAdd( aIncEnv, '' )
	EndIf

	//Validação da tag <cpfResp> - CPF do médico responsável/coordenador do PCMSO
	//Validação: Se informado, deve ser um CPF válido.
	If !Empty( cCodResp )
		If !Empty( cCpfResp ) .And. !CHKCPF( cCpfResp )
			aAdd( aIncEnv, cStrFil + " / " + cStrResp + " / " + STR0013 + ": " + cCpfResp ) //Médico Responsável/Coordenador do PCMSO: XXX - XXXXX / CPF: XXX
			aAdd( aIncEnv, STR0008 + ": " + STR0012 ) //Validação: Deve ser um número de CPF válido
			aAdd( aIncEnv, '' )
		EndIf
	EndIf

	//Validação da tag <nmResp> - Nome do médico responsável/coordenador do PCMSO
	//Informação obrigatória caso exista um médico responsável/coordenador do PCMSO
	If !Empty( cCodResp )
		If Empty( cNmResp )
			aAdd( aIncEnv, cStrFil + " / " + cStrResp + " / " + STR0033 + ": " + STR0007 ) //Médico Responsável/Coordenador do PCMSO: XXX - XXXXX / Nome: Em branco
			aAdd( aIncEnv, '' )
		EndIf
	EndIf

	//Validação da tag <nrCRM> - Número de inscrição do médico responsável/coordenador do PCMSO no CRM
	//Informação obrigatória caso exista um médico responsável/coordenador do PCMSO
	If !Empty( cCodResp )
		If Empty( cNrCrmResp )
			aAdd( aIncEnv, cStrFil + " / " + cStrResp + " / " + STR0034 + ": " + STR0007 ) //Médico Responsável/Coordenador do PCMSO: XXX - XXXXX / Número de Inscrição no CRM: Em branco
			aAdd( aIncEnv, '' )
		EndIf
	EndIf

	//Validação da tag <ufCRM> - UF de expedição do CRM
	//Valores válidos: AC, AL, AP, AM, BA, CE, DF, ES, GO, MA, MT, MS, MG, PA, PB, PR, PE, PI, RJ, RN, RS, RO, RR, SC, SP, SE, TO
	//Informação obrigatória caso exista um médico responsável/coordenador do PCMSO
	If !Empty( cCodResp )
		If Empty( cUfCRMResp )
			aAdd( aIncEnv, cStrFil + " / " + cStrResp + " / " + STR0035 + ": " + STR0007 ) //Médico Responsável/Coordenador do PCMSO: XXX - XXXXX / UF de Expedição do CRM: Em branco
			aAdd( aIncEnv, '' )
		EndIf
	EndIf

	Help := .F. //Ativa novamente as mensagens de Help

	cFilAnt := cFilBkp //Retorna filial do registro
	RestArea( aArea ) //Retorna área

Return

//---------------------------------------------------------------------
/*/{Protheus.doc} fBusExa
Busca os exames relacionados ao atestado ASO

@sample	fBusExa( 3, "000026", .T., .F., .F. )

@return	aExaAtes, Array, Array com os exames relacionados ao ASO

@param	nOpc, Numérico, Indica a operação que está sendo realizada (3-Inclusão/4-Alteração/5-Exclusão)
@param	cNumASO, Caracter, Indica o código do ASO que está sendo enviado para a busca de informações
@param	lImpASO, Boolean, Indica se é impressão do ASO
@param	lXml, Boolean, Indica se é geração de Xml
@param	lIncons, Boolean, Indica se é validação das informações

@author	Guilherme Benekendorf
@since	25/11/2013
/*/
//---------------------------------------------------------------------
Static Function fBusExa( nOpc, cNumASO, lImpASO, lXml, lIncons )

	Local aExaAtes := {}
	Local aExame   := {}

	If !IsInCallStack('MDTA410') .And. !IsInCallStack('MDTR465') .And. Type( 'cTRB2200' ) == 'C'
		dbSelectArea( cTRB2200 )
		dbGoTop()
	EndIf
	
	//Caso não for impressão do ASO, não for geração de xml, for validação das informações e existir a tabela temporária
	If !lImpASO .And. !lXml .And. lIncons .And. Type( "cTRB2200" ) == "C" .And. ( Select( cTRB2200 ) > 0 .And. !Empty( ( cTRB2200 )->TM5_EXAME) )
		If ( cTRB2200 )->( !Eof() )
			While ( cTRB2200 )->( !Eof() )
				If !Empty( ( cTRB2200 )->TM5_OK )
					dbSelectArea( "TM5" )
					dbSetOrder( 8 ) //"TM5_FILIAL+TM5_NUMFIC+DTOS(TM5_DTPROG)+TM5_HRPROG+TM5_EXAME"
					If dbSeek( xFilial( "TM5" ) + ( cTRB2200 )->TM5_NUMFIC + DTOS( ( cTRB2200 )->TM5_DTPROG ) + ( cTRB2200 )->TM5_HRPROG + ( cTRB2200 )->TM5_EXAME )

						aExame := fStructExa( aExaAtes )

						If Len( aExame ) > 0
							aAdd( aExaAtes, aExame )
							aAdd( aExameBack, aExame )
						EndIf

					EndIf
				EndIf
				dbSelectArea( cTRB2200 )
				( cTRB2200 )->( dbSkip() )
			End
		EndIf
	Else
		dbSelectArea( "TM5" )
		dbSetOrder( 4 ) //TM5_FILIAL+TM5_NUMASO
		If dbSeek( xFilial( "TM5" ) + cNumASO )
			While !Eof() .And. TM5->TM5_FILIAL == xFilial( "TM5" ) .And. ( TM5->TM5_NUMASO == cNumASO .Or.;
				TM5->TM5_NUMFIC == M->TMY_NUMFIC .And. Empty( TM5->TM5_NUMASO ) )

				aExame := fStructExa( aExaAtes )

				If Len( aExame ) > 0
					aAdd( aExaAtes, aExame )
				EndIf

				dbSelectArea( "TM5" )
				dbSkip()
			End
		EndIf
	EndIf

	If Empty( aExaAtes ) .And. !Empty( aExameBack )

		aExaAtes := aExameBack

	EndIf

	If !lIncons // Limpa os exames buscados no envio do evento
		aExameBack := {}
	EndIf

Return aExaAtes

//---------------------------------------------------------------------
/*/{Protheus.doc} fStructExa
Retorna a estrutura do exame a ser inserido no evento

@return	aExame, Array, Array com os exames a serem incluidos no Xml no formato de envio

@author	Luis Fellipy Bett
@since	23/10/2017
/*/
//---------------------------------------------------------------------
Function fStructExa( aExaAtes )

	Local aExame	 := {}
	Local cNomExa	 := Posicione( "TM4", 1, xFilial( "TM4" ) + TM5->TM5_EXAME, "TM4_NOMEXA" )
	Local cProcReal	 := Posicione( "TM4", 1, xFilial( "TM4" ) + TM5->TM5_EXAME, "TM4_PROCRE" )
	Local cObsProc	 := AllTrim( MDTSubTxt( TM5->TM5_OBSERV ) )
	Local cIndResult := TM5->TM5_INDRES

	//----- Indicação dos Resultados
	// 1- Normal						1- Normal
	// 2- Alterado						2- Alterado
	// 2- Alterado e 2- Agravamento		3- Estável
	// 2- Alterado e 1- Agravamento		4- Agravamento
	Do Case
		Case cIndResult = "2" .And. TM5->TM5_INDAGR == "2" ; cIndResult := "3"
		Case cIndResult = "2" .And. TM5->TM5_INDAGR == "1" ; cIndResult := "4"
	End Case

	If aScan( aExaAtes, { | x | x[ 3 ] == TM5->TM5_DTRESU .And. x[ 4 ] == AllTrim( cProcReal ) } ) == 0
		If !Empty( TM5->TM5_PCMSO )
			aExame := { TM5->TM5_EXAME, ;
						cNomExa, ; //Utilizado para impressão do nome do Exame no relatório de inconsistências
						TM5->TM5_DTRESU, ; //Valor a ser enviado na tag <dtExm>
						AllTrim( cProcReal ), ; //Valor a ser enviado na tag <procRealizado>
						AllTrim( cObsProc ), ; //Valor a ser enviado na tag <obsProc>
						M->TMY_INDEXA, ; //Valor a ser enviado na tag <ordExame>
						cIndResult } //Valor a ser enviado na tag <indResult>
		EndIf
	EndIf

Return aExame

//-------------------------------------------------------------------
/*/{Protheus.doc} MDTTpASO
Busca o tipo do ASO conforme o leiaute do eSocial

@return	cTipRet, Caracter, Tipo do ASO a ser retornado conforme leiaute do eSocial

@param	cTpASO, Caracter, Tipo do ASO no SIGAMDT

@sample	MDTTpASO( "1" )

@author	Luis Fellipy Bett
@since	10/01/2022
/*/
//-------------------------------------------------------------------
Function MDTTpASO( cTpASO )

	Local cTipRet := "" //Tipo do ASO que será retornado

	//-------------- Tipo de Atestado --------------
	// 1- Admissional			0- Admissional
	// 2- Periódico				1- Períodico, conforme planejamento do PCMSO
	// 3- Mudança de Função		3- De mudança de função
	// 4- Retorno ao Trabalho	2- De retorno ao trabalho
	// 5- Demissional			9- Demissional
	// 6- Monitoração Pontual	4- Exame médico de monitoração pontual
	//----------------------------------------------
	Do Case
		Case cTpASO == "1" ; cTipRet := "0"
		Case cTpASO == "2" ; cTipRet := "1"
		Case cTpASO == "3" ; cTipRet := "3"
		Case cTpASO == "4" ; cTipRet := "2"
		Case cTpASO == "5" ; cTipRet := "9"
		Case cTpASO == "6" ; cTipRet := "4"
	End Case

Return cTipRet
