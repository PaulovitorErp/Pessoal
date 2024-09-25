#INCLUDE "TOTVS.CH"
#INCLUDE "FWMVCDEF.CH"
#INCLUDE "MDTM004.CH"

//-------------------------------------------------------------------------------------------------------------------
//-------------------------------------------------------------------------------------------------------------------
//-------------------------------------------------------------------------------------------------------------------
//  _______           _______  _       _________ _______             _______  _______  _______    ___    _______  ---
// (  ____ \|\     /|(  ____ \( (    /|\__   __/(  ___  )           (  ____ \/ ___   )/ ___   )  /   )  (  __   ) ---
// | (    \/| )   ( || (    \/|  \  ( |   ) (   | (   ) |           | (    \/\/   )  |\/   )  | / /) |  | (  )  | ---
// | (__    | |   | || (__    |   \ | |   | |   | |   | |   _____   | (_____     /   )    /   )/ (_) (_ | | /   | ---
// |  __)   ( (   ) )|  __)   | (\ \) |   | |   | |   | |  (_____)  (_____  )  _/   /   _/   /(____   _)| (/ /) | ---
// | (       \ \_/ / | (      | | \   |   | |   | |   | |                 ) | /   _/   /   _/      ) (  |   / | | ---
// | (____/\  \   /  | (____/\| )  \  |   | |   | (___) |           /\____) |(   (__/\(   (__/\    | |  |  (__) | ---
// (_______/   \_/   (_______/|/    )_)   )_(   (_______)           \_______)\_______/\_______/    (_)  (_______) ---
//-------------------------------------------------------------------------------------------------------------------
//-------------------------------------------------------------------------------------------------------------------
//-------------------------------------------------------------------------------------------------------------------

//-------------------------------------------------------------------------------------------------------------------
/*/{Protheus.doc} MDTM004
Rotina de Envio de Eventos - Condição Ambiental de Trabalho - Riscos (S-2240)
Realiza a composição do Xml a ser enviado ao Governo

@author Luis Fellipy Bett
@since 27/11/2017

@param cNumMat, Caracter, Indica a matrícula do Funcionário ao qual serão enviadas as informações
@param nOper, Numérico, Indica a operação que está sendo realizada (3-Inclusão/4-Alteração/5-Exclusão)
@param dDtIniCond, Date, Indica a data de referência do período de exposição que será enviado
@param lIncons, Boolean, Indica se é avaliação de inconsistências das informações de envio
@param aIncEnv, Array, Array que recebe as inconsistências, se houver, das informações a serem enviadas
@param cChave, Caracter, Chave atual do registro a ser utilizada na busca do registro na RJE
@param aGPEA180, Array, Array contendo as informações da transferência do funcionário
	1ª posição - Data da transferência
	2ª posição - Empresa origem
	3ª posição - Empresa destino
	4ª posição - Filial origem
	5ª posição - Filial destino
	6ª posição - Matrícula origem
	7ª posição - Matrícula destino
	8ª posição - Centro de custo origem
	9ª posição - Centro de custo destino
	10ª posição - Departamento origem
	11ª posição - Departamento destino
	12ª posição - Função destino
	13ª posição - Cargo destino
	14ª posição - Código único destino
@param dFimCon, data final da condição <dtFimCondicao>

@return cRet, Caracter, Retorna o Xml gerado pelo Risco
/*/
//------------------------------------------------------------------------------------------------------------------
Function MDTM004( cNumMat, nOper, dDtIniCond, lIncons, aIncEnv, cChave, aGPEA180, dFimCon, cDescAtiv )

	//Variáveis de controle de troca de empresa, quando transferência de empresa
	Local aAreaBk  := GetArea()
	Local cEmpBkp  := cEmpAnt
	Local cFilBkp  := cFilAnt
	Local cArqBkp  := cArqTab

	//Variáveis de controle de tabelas na troca de empresa, quando transferência de empresa
	Local aAreaTOQ := TOQ->( GetArea() )
	Local aAreaTOR := TOR->( GetArea() )
	Local aAreaTOS := TOS->( GetArea() )
	Local aAreaTOT := TOT->( GetArea() )
	Local aAreaTOU := TOU->( GetArea() )
	Local aAreaTNE := TNE->( GetArea() )
	Local aAreaTN6 := TN6->( GetArea() )
	Local aAreaSR8 := SR8->( GetArea() )
	Local aAreaSQ3 := SQ3->( GetArea() )
	Local aAreaTN5 := TN5->( GetArea() )
	Local aAreaSRJ := SRJ->( GetArea() )
	Local aAreaTN0 := TN0->( GetArea() )
	Local aAreaTO9 := TO9->( GetArea() )
	Local aAreaTMA := TMA->( GetArea() )
	Local aAreaTLK := TLK->( GetArea() )
	Local aAreaTO0 := TO0->( GetArea() )
	Local aAreaTMK := TMK->( GetArea() )
	Local aAreaTNX := TNX->( GetArea() )
	Local aAreaTNF := TNF->( GetArea() )
	Local aAreaTN3 := TN3->( GetArea() )
	Local aAreaTL0 := TL0->( GetArea() )
	Local aAreaTJF := TJF->( GetArea() )
	Local aAreaSB1 := SB1->( GetArea() )
	Local aAreaCTT := CTT->( GetArea() )
	Local aAreaSQB := SQB->( GetArea() )
	Local aAreaC92 := C92->( GetArea() )
	Local aAreaC87 := C87->( GetArea() )
	Local aAreaTO1 := TO1->( GetArea() )
	Local aAreaV5Y := V5Y->( GetArea() )
	Local aAreaV3F := V3F->( GetArea() )
	Local aAreaRJ9 := RJ9->( GetArea() )
	Local aAreaRJE := RJE->( GetArea() )
	
	//Variável das tabelas a serem abertas
	Local aTbls := { "TOQ", "TOR", "TOS", "TOT", "TOU", ;
					"TNE", "TN6", "SR8", "SQ3", "TN5", ;
					"SRJ", "TN0", "TO9", "TMA", "TLK", ;
					"TO0", "TMK", "TNX", "TNF", "TN3", ;
					"TL0", "TJF", "SB1", "CTT", "SQB", ;
					"C92", "C87", "TO1", "V5Y", "V3F" }

	//Variáveis de busca das informações
	Local cRet		:= ""
	Local cCCusto	:= ""
	Local cDepto	:= ""
	Local cFuncao	:= ""

	//Variáveis private auxiliares para validação e busca das informações a serem enviadas
	Private cNomeFun   := "" //Nome do Funcionário (RA_NOME)
	Private dDtAdm	   := SToD( "" ) //Data de Admissão do Funcionário (RA_ADMISSA)
	Private cCCustoAnt := ""
	Private cDeptoAnt  := ""
	Private cFuncaoAnt := ""
	Private cCargoAnt  := ""

	//Variáveis das informações a serem envidas
	Private cCpfTrab	:= "" //CPF do Funcionário (RA_CIC)
	Private cMatricula	:= "" //Matrícula do Funcionário a ser considerada no envio (RA_CODUNIC)
	Private cCodCateg	:= "" //Categoria do Funcionário (RA_CATEFD)
	Private aAmbExp		:= {} //Ambiente de Exposição do Funcionário
	Private cDscAtivDes	:= "" //Descrição das Atividades do Funcionário (TN5_DESCRI ou TN5_NOMTAR/Q3_DESCDET ou Q3_DESCSUM/RJ_DESCREQ ou RJ_DESC/Q3_DESCDET ou Q3_DESCSUM + TN5_DESCRI ou TN5_NOMTAR)
	Private aRisTrat 	:= {} //Riscos a que o Funcionário está exposto
	Private aRespAmb    := {} //Responsável pelos Registros Ambientais

	//Define os valores padrões para os parâmetros
	Default nOper	:= 3
	Default lIncons	:= .F.
	Default dFimCon := CtoD( '  /  /    ' )
	Default cDescAtiv := ""

	If lMiddleware // Adiciona as tabelas do Middleware
		aAdd( aTbls, "RJ9" )
		aAdd( aTbls, "RJE" )
	Else // Adiciona as tabelas do TAF
		aAdd( aTbls, 'C9V' )
	EndIf

	//Posiciona no registro do funcionário na SRA
	dbSelectArea( "SRA" )
	dbSetOrder( 1 )
	dbSeek( xFilial( "SRA" ) + cNumMat )

	//Salva as informações da filial de origem
	cCCustoAnt := SRA->RA_CC
	cDeptoAnt  := SRA->RA_DEPTO
	cFuncaoAnt := SRA->RA_CODFUNC
	cCargoAnt  := SRA->RA_CARGO

	//Caso for chamada pelo GPEA180
	If lGPEA180

		//Altera o valor dos campos para considerar corretamente os dados da filial destino
		MDTChgSRA( .T., aGPEA180 )

	EndIf

	//Salva as informações nas variáveis
	cNomeFun := SRA->RA_NOME //Nome do Funcionário
	dDtAdm	 := SRA->RA_ADMISSA //Data de Admissão do Funcionário
	cCCusto	 := SRA->RA_CC //Centro de Custo do Funcionário
	cDepto	 := SRA->RA_DEPTO //Departamento do Funcionário
	cFuncao	 := SRA->RA_CODFUNC //Função do Funcionário

	//Caso for chamada pelo GPEA180, altera a filial para buscar as informações da filial de destino
	If lGPEA180

		//Caso a empresa destino seja diferente da empresa atual
		If cEmpAnt <> cEmpDes

			//Caso Middleware
			If lMiddleware

				//Posiciona a SM0 na empresa destino
				MDTPosSM0( cEmpDes, cFilDes )

			EndIf

			// Abre o dicionário na empresa destino
			fOpenSX( { 'SX2', 'SX3', 'SX6' }, cEmpDes )

			// Abre as tabelas na empresa destino
			MDTChgEmp( aTbls, cEmpAnt, cEmpDes )

			//Posiciona na empresa destino
			cEmpAnt := cEmpDes

		EndIf

		//Posiciona na filial destino
		cFilAnt := cFilDes

	EndIf

	//Busca da informação a ser enviada na tag <cpfTrab>
	cCpfTrab := SRA->RA_CIC //CPF do Funcionário

	//Busca da informação a ser enviada na tag <matricula>
	cMatricula := IIf( lGPEA180, aGPEA180[ 1, 14 ], SRA->RA_CODUNIC ) //Código Único do Funcionário

	//Busca da informação a ser enviada na tag <matricula>
	cCodCateg := SRA->RA_CATEFD //Categoria do Funcionário

	//O valor da tag <dtIniCondicao> é passado por parâmetro
	//Informar a data em que o trabalhador iniciou as atividades nas condições descritas ou a data de início da obrigatoriedade deste evento
	//para o empregador no eSocial, a que for mais recente
	If dDtIniCond < dDtEsoc

		//Define o início da condição como sendo o início de obrigatoriedade do eSocial
		dDtIniCond := dDtEsoc

	EndIf

	//Busca da informação a ser enviada nas tags <localAmb>, <dscSetor>, <tpInsc> e <nrInsc>
	aAmbExp := fGetAmbExp( cCCusto, cDepto, cFuncao, cNumMat, dDtIniCond, lIncons )

	//Busca da informação a ser enviada na tag <dscAtivDes>
	If Empty(cDescAtiv) .Or. !lGPEA370 //Tratamento paliativo para varios funcionários com mesmo cargo
		cDscAtivDes := fGetDscAti( cNumMat, dDtIniCond, aGPEA180 )
		cDescAtiv := cDscAtivDes
	Else
		cDscAtivDes := cDescAtiv
	EndIf

	//Busca da informação a ser enviada nas tags <codAgNoc>, <dscAgNoc>, <tpAval>, <intConc>, <limTol>, <unMed>, <tecMedicao>, <utilizEPC>,
	//<eficEpc>, <utilizEPI>, <docAval>, <eficEpi>, <medProtecao>, <condFuncto>, <usoInint>, <przValid>, <periodicTroca> e <higienizacao>
	aRisTrat := fGetRisExp( cNumMat, dDtIniCond, nOper, lIncons )

	//Busca da informação a ser enviada nas tags <cpfResp>, <ideOC>, <dscOC>, <nrOC> e <ufOC>
	aRespAmb := fGetResAmb( dDtIniCond, aRisTrat )

	//Caso for verificação das inconsistências
	If lIncons

		//Analisa as inconsistências
		fInconsis( @aIncEnv, dDtIniCond, cNumMat, cCCusto, cDepto, cFuncao )

	Else

		//Carrega o xml do evento
		cRet := fCarrRis( cValToChar( nOper ), dDtIniCond, cChave, dFimCon )

	EndIf

	//Caso for chamada pelo GPEA180, altera a empresa e filial para a atual após ter buscado as informações
	If lGPEA180

		//Caso a empresa destino seja diferente da empresa atual
		If cEmpAnt <> cEmpBkp

			//Caso Middleware
			If lMiddleware

				//Posiciona a SM0 na filial logada novamente
				MDTPosSM0( cEmpBkp, cFilBkp )

			EndIf

			// Abre o dicionário na empresa logada novamente
			fOpenSX( { 'SX2', 'SX3', 'SX6' }, cEmpBkp )

			// Abre as tabelas na empresa logada novamente
			MDTChgEmp( aTbls, cEmpDes, cEmpBkp )

			//Posiciona na empresa logada novamente
			cEmpAnt := cEmpBkp

		EndIf

		//Posiciona na filial logada novamente
		cFilAnt := cFilBkp

	EndIf

	//Caso for chamada pelo GPEA180
	If lGPEA180

		//Volta o valor dos campos
		MDTChgSRA( .F., aGPEA180 )

	EndIf

	//Reposiciona as tabelas na filial logada
	RestArea( aAreaTOQ )
	RestArea( aAreaTOR )
	RestArea( aAreaTOS )
	RestArea( aAreaTOT )
	RestArea( aAreaTOU )
	RestArea( aAreaTNE )
	RestArea( aAreaTN6 )
	RestArea( aAreaSR8 )
	RestArea( aAreaSQ3 )
	RestArea( aAreaTN5 )
	RestArea( aAreaSRJ )
	RestArea( aAreaTN0 )
	RestArea( aAreaTO9 )
	RestArea( aAreaTMA )
	RestArea( aAreaTLK )
	RestArea( aAreaTO0 )
	RestArea( aAreaTMK )
	RestArea( aAreaTNX )
	RestArea( aAreaTNF )
	RestArea( aAreaTN3 )
	RestArea( aAreaTL0 )
	RestArea( aAreaTJF )
	RestArea( aAreaSB1 )
	RestArea( aAreaCTT )
	RestArea( aAreaSQB )
	RestArea( aAreaC92 )
	RestArea( aAreaC87 )
	RestArea( aAreaTO1 )
	RestArea( aAreaV5Y )
	RestArea( aAreaV3F )
	RestArea( aAreaRJ9 )
	RestArea( aAreaRJE )

	//Retorna as informações da empresa e filial logada
	cEmpAnt := cEmpBkp
	cFilAnt := cFilBkp
	cArqTab := cArqBkp
	
	//Retorna a área posicionada
	RestArea( aAreaBk )

Return cRet

//---------------------------------------------------------------------
/*/{Protheus.doc} fCarrRis
Monta o Xml dos Riscos para envio ao Governo

@author Luis Fellipy Bett
@since 30/08/2018

@param cOper, Caracter, Indica a operação que está sendo realizada (3-Inclusão/4-Alteração/5-Exclusão)
@param dDtIniCond, Data, Data de referência que o sistema considera como início de exposição do funcionário
@param cChave, Caracter, Chave atual do registro a ser utilizada na busca do registro na RJE
@param dFimCon, data final da condição <dtFimCondicao>

@return cXml Caracter Estrutura XML a ser enviada para o SIGATAF/Middleware
/*/
//---------------------------------------------------------------------
Static Function fCarrRis( cOper, dDtIniCond, cChave, dFimCon )

	Local cXml	:= ""
	Local aEPIs	:= {}

	//Contadores
	Local nRis := 0
	Local nEPI := 0
	Local nRes := 0
	Local nAmb := 0

	If cOper == "5" //Caso for exclusão define como alteração
		cOper := "4"
	EndIf

	//Cria o cabeçalho do Xml com o ID, informações do Evento e Empregador
	MDTGerCabc( @cXml, "S2240", cOper, cChave )

	//-------------
	// Funcionário
	//-------------

	cXml += 		'<ideVinculo>'
	cXml += 			'<cpfTrab>'		+ cCpfTrab		+ '</cpfTrab>' //Obrigatório

	// Caso não for funcionário TSVE ou possuir matrícula eSocial ou matrícula Middleware(RJE)
	If !MDTVerTSVE( cCodCateg ) .Or. fVerMatEso( cCpfTrab, cMatricula ) .Or. fMatMid( cMatricula )
		cXml +=			'<matricula>'	+ cMatricula	+ '</matricula>' //Obrigatório
	Else
		cXml +=			'<codCateg>'	+ cCodCateg		+ '</codCateg>' //Obrigatório
	EndIf
	cXml += 		'</ideVinculo>'

	//---------------------------------------
	// Monitoramento da saúde do trabalhador
	//---------------------------------------

	cXml += 		'<infoExpRisco>'

	cXml += 			'<dtIniCondicao>' + MDTAjsData( dDtIniCond ) + '</dtIniCondicao>' //Obrigatório

	If MdtTraAvul( cCodCateg ) .And. Mdt062022( dDtIniCond )
		cXml += 			'<dtFimCondicao>' + MDTAjsData( dFimCon ) + '</dtFimCondicao>'
	EndIf

	For nAmb := 1 To Len( aAmbExp ) // Somente funcionário da categoria 2XX possui mais de um ambiente
		cXml += 		'<infoAmb>'
		cXml += 			'<localAmb>'	+ aAmbExp[ nAmb, 2 ]	+ '</localAmb>' // Obrigatório
		cXml += 			'<dscSetor>'	+ aAmbExp[ nAmb, 3 ]	+ '</dscSetor>' // Obrigatório
		cXml += 			'<tpInsc>'		+ aAmbExp[ nAmb, 4 ]	+ '</tpInsc>' // Obrigatório
		cXml += 			'<nrInsc>'		+ aAmbExp[ nAmb, 5 ]	+ '</nrInsc>' // Obrigatório
		cXml += 		'</infoAmb>'
	Next nAmb

	cXml += 			'<infoAtiv>'
	cXml += 				'<dscAtivDes>'	+ cDscAtivDes	+ '</dscAtivDes>' //Obrigatório
	cXml += 			'</infoAtiv>'

	If Len( aRisTrat ) > 0

		For nRis := 1 To Len( aRisTrat )

			cXml += 	'<agNoc>'
			cXml += 		'<codAgNoc>'		+ aRisTrat[ nRis, 3 ]		+ '</codAgNoc>' //Obrigatório
			cXml +=			'<dscAgNoc>'		+ aRisTrat[ nRis, 4 ]		+ '</dscAgNoc>'
			If aRisTrat[ nRis, 3 ] != "09.01.001" //Caso não for ausência de fator de risco
				cXml +=		'<tpAval>'			+ aRisTrat[ nRis, 5 ]		+ '</tpAval>' //Obrigatório
			EndIf
			If aRisTrat[ nRis, 5 ] == "1" //Se o tipo de avaliação for quantitativa
				cXml += 	'<intConc>'			+ aRisTrat[ nRis, 6 ]		+ '</intConc>'
				If aRisTrat[ nRis, 3 ] $ "01.18.001/02.01.014"
					cXml +=	'<limTol>'			+ aRisTrat[ nRis, 7 ]		+ '</limTol>'
				EndIf
				cXml += 	'<unMed>'			+ aRisTrat[ nRis, 8 ]		+ '</unMed>'
				cXml += 	'<tecMedicao>'		+ aRisTrat[ nRis, 9 ]		+ '</tecMedicao>'
			EndIf

			// Nova tag criada no leiaute S-1.2 para quando agente for incluído por ação judicial ou administrativa
			If aRisTrat[ nRis, 3 ] == '05.01.001' .And. 'S_01_02' $ MdtRetLei( 'S-2240' ) .And. !Empty( aRisTrat[ nRis, 14 ] )
				cXml += '<nrProcJud>' + aRisTrat[ nRis, 14 ] + '</nrProcJud>'
			EndIf

			cXml += 		'<epcEpi>'
			cXml += 			'<utilizEPC>'	+ aRisTrat[ nRis, 10 ]		+ '</utilizEPC>' //Obrigatório
			If aRisTrat[ nRis, 10 ] == "2"
				cXml +=			'<eficEpc>'		+ aRisTrat[ nRis, 11 ]		+ '</eficEpc>'
			EndIf
			cXml += 			'<utilizEPI>'	+ aRisTrat[ nRis, 12 ]		+ '</utilizEPI>' //Obrigatório
			If aRisTrat[ nRis, 12 ] == "2"
				aEPIs := aClone( aRisTrat[ nRis, 13 ] )
				If Len( aEPIs ) > 0
					cXml +=		'<eficEpi>'		+ aEPIs[ Len( aEPIs ), 4 ]	+ '</eficEpi>'
					For nEPI := 1 To Len( aEPIs )
						cXml += 	'<epi>'
						cXml +=			'<docAval>'			+ aEPIs[ nEpi, 2 ] + '</docAval>' // Obrigatório
						cXml += 	'</epi>'
					Next nEPI
					cXml += 		'<epiCompl>'
					cXml += 			'<medProtecao>'		+ aEPIs[ Len( aEPIs ), 5 ] + '</medProtecao>'
					cXml += 			'<condFuncto>'		+ aEPIs[ Len( aEPIs ), 6 ] + '</condFuncto>'
					cXml += 			'<usoInint>'		+ aEPIs[ Len( aEPIs ), 7 ] + '</usoInint>'
					cXml += 			'<przValid>'		+ aEPIs[ Len( aEPIs ), 8 ] + '</przValid>'
					cXml += 			'<periodicTroca>'	+ aEPIs[ Len( aEPIs ), 9 ] + '</periodicTroca>'
					cXml += 			'<higienizacao>'	+ aEPIs[ Len( aEPIs ), 10 ] + '</higienizacao>'
					cXml += 		'</epiCompl>'
				EndIf
			EndIf
			cXml += 		'</epcEpi>'
			cXml += 	'</agNoc>'
		Next nRis

	Else

		cXml += 		'<agNoc>'
		cXml += 			'<codAgNoc>09.01.001</codAgNoc>'
		cXml += 		'</agNoc>'

	EndIf

	For nRes := 1 To Len( aRespAmb )

		cXml += 		'<respReg>'
		cXml += 			'<cpfResp>'	+ aRespAmb[ nRes, 3 ]	+ '</cpfResp>' //Obrigatório
		If !Empty( aRespAmb[ nRes, 4 ] )
			cXml +=			'<ideOC>'	+ aRespAmb[ nRes, 4 ]	+ '</ideOC>' //Obrigatório
		EndIf
		If !Empty( aRespAmb[ nRes, 4 ] ) .And. aRespAmb[ nRes, 4 ] == "9"
			cXml += 		'<dscOC>'	+ aRespAmb[ nRes, 5 ]	+ '</dscOC>'
		EndIf
		If !Empty( aRespAmb[ nRes, 6 ] )
			cXml +=			'<nrOC>'	+ aRespAmb[ nRes, 6 ]	+ '</nrOC>' //Obrigatório
		EndIf
		If !Empty( aRespAmb[ nRes, 7 ] )
			cXml +=			'<ufOC>'	+ aRespAmb[ nRes, 7 ]	+ '</ufOC>' //Obrigatório
		EndIf
		cXml += 		'</respReg>'

	Next nRes

	cXml += 		'</infoExpRisco>'

	cXml += 	'</evtExpRisco>'

	cXml += '</eSocial>'

Return cXml

//---------------------------------------------------------------------
/*/{Protheus.doc} fInconsis
Valida as informações a serem enviadas para o SIGATAF/Middleware

@return	Nil, Nulo

@sample	fInconsis( aIncEnv, 21/10/2021, "0000001", "000031", "000000002", "00003" )

@param	aIncEnv, Array, Array passado por referência que irá receber os logs de inconsistências (se houver)
@param	dDtIniCond, Data, Data de início de exposição
@param	cNumMat, Caracter, Matrícula do funcionário
@param	cCCusto, Caracter, Centro de custo do funcionário
@param	cDepto, Caracter, Departamento do funcionário
@param	cFuncao, Caracter, Função do funcionário

@author	Luis Fellipy Bett
@since	30/08/2018 - Refatorada em: 17/02/2021
/*/
//---------------------------------------------------------------------
Static Function fInconsis( aIncEnv, dDtIniCond, cNumMat, cCCusto, cDepto, cFuncao )

	Local aArea	  		:= GetArea()
	Local aTarefas	 	:= {}

	Local cBarra	 	:= " / "
	Local cLisAge		:= 	'01.01.001/' + ;
							'01.02.001/' + ;
							'01.03.001/' + ;
							'01.04.001/' + ;
							'01.05.001/' + ;
							'01.06.001/' + ;
							'01.07.001/' + ;
							'01.08.001/' + ;
							'01.09.001/' + ;
							'01.10.001/' + ;
							'01.12.001/' + ;
							'01.13.001/' + ;
							'01.14.001/' + ;
							'01.15.001/' + ;
							'01.16.001/' + ;
							'01.17.001/' + ;
							'01.18.001/' + ;
							'05.01.001'
	Local cFilBkp 		:= cFilAnt
	Local cStrFil	 	:= ''
	Local cEntAmb	 	:= SuperGetMv( "MV_NG2EAMB", .F., "1" ) //Indica qual entidade será considerada no relacionamento com o ambiente
	Local cTarefas	 	:= ""
	Local cStrFunc	 	:= STR0001 + ": " + AllTrim( cNumMat ) + " - " + AllTrim( cNomeFun ) //Funcionário: XXX - XXXXX
	Local cStrCCus	 	:= STR0051 + ": " + AllTrim( cCCusto ) + " - " + AllTrim( Posicione( "CTT", 1, xFilial( "CTT" ) + cCCusto, "CTT_DESC01" ) ) //Centro de Custo: XXX - XXXXX
	Local cStrDepto  	:= STR0054 + ": " + AllTrim( cDepto ) + " - " + AllTrim( Posicione( "SQB", 1, xFilial( "SQB" ) + cDepto, "QB_DESCRIC" ) ) //Departamento: XXX - XXXXX
	Local cStrFuncao	:= STR0055 + ": " + AllTrim( cFuncao ) + " - " + AllTrim( Posicione( "SRJ", 1, xFilial( "SRJ" ) + cFuncao, "RJ_DESC" ) ) //Função: XXX - XXXXX

	Local lGerXml	 	:= IsInCallStack( "MDTGeraXml" ) //Caso for geração de xml
	Local lVldDsc	 	:= IIf( SuperGetMv( "MV_NG2TDES", .F., "1" ) == "1", ( lGPEA010 .And. lGerXml ) .Or. ( !lGPEA010 .And. !lGPEA180 .And. !lMDTA090 .And. !lMDTA165 .And. !lMDTA630 .And. !lMDTA695 ), .T. )
	Local lVldNrIns	 	:= .T.

	Local nCont		 	:= 0

	Local oModel	 	:= Nil

	If FWIsInCallStack( 'GPEA180' )
		cFilAnt := cFilEnv // Posiciona na filial de envio que deve ser considerada nas validações
	EndIf

	cStrFil := STR0062 + ':' + Space( 1 ) + AllTrim( cFilAnt ) //Filial: XXX

	Help := .T. //Desativa as mensagens de Help

	//Validação da tag <cpfTrab> - CPF do trabalhador
	//Preencher com o número do CPF do trabalhador.
	If Empty( cCpfTrab )
		aAdd( aIncEnv, cStrFil + " / " + cStrFunc + " / " + STR0010 + ": " + STR0004 ) //Funcionário: XXX - XXXXX / CPF: Em branco
		aAdd( aIncEnv, '' )
	ElseIf !CHKCPF( cCpfTrab )
		aAdd( aIncEnv, cStrFil + " / " + cStrFunc + " / " + STR0010 + ": " + cCpfTrab ) //Funcionário: XXX - XXXXX / CPF: XXX
		aAdd( aIncEnv, STR0005 + ": " + STR0009 ) //Validação: Deve ser um número de CPF válido
		aAdd( aIncEnv, '' )
	EndIf

	//Validação da tag <matricula> - Matrícula atribuída ao trabalhador pela empresa
	//Deve corresponder à matrícula informada pelo empregador no evento S-2190, S-2200 ou S-2300 do respectivo contrato. Não preencher no caso de
	//Trabalhador Sem Vínculo de Emprego/Estatutário - TSVE sem informação de matrícula no evento S-2300
	//A validação de existência de um registro S-2190, S-2200 ou S-2300 já é realizada no começo do envio, através da função MDTVld2200

	//Validação da tag <codCateg> - Código da categoria do trabalhador
	//Informação obrigatória e exclusiva se não houver preenchimento de matricula. Se informado, deve ser um código válido e existente na Tabela 01.
	If Empty( cMatricula ) .And. Empty( cCodCateg )
		aAdd( aIncEnv, cStrFil + " / " + cStrFunc + " / " + STR0011 + ": " + STR0004 ) //Funcionário: XXX - XXXXX / Categoria: Em branco
		aAdd( aIncEnv, '' )
	ElseIf Empty( cMatricula ) .And. !ExistCPO( "C87", cCodCateg, 2 )
		aAdd( aIncEnv, cStrFil + " / " + cStrFunc + " / " + STR0011 + ": " + cCodCateg ) //Funcionário: XXX - XXXXX / Categoria: XXX
		aAdd( aIncEnv, STR0005 + ": " + STR0012 ) //Validação: Deve ser um código válido e existente na tabela 01 do eSocial
		aAdd( aIncEnv, '' )
	EndIf

	//Validação da tag <dtIniCondicao> - Data em que o trabalhador iniciou as atividades nas condições descritas ou a data de início da
	//obrigatoriedade deste evento para o empregador no eSocial, a que for mais recente
	//Validação: Deve ser uma data válida, igual ou posterior à data de admissão do vínculo a que se refere. Não pode ser anterior à data de
	//início da obrigatoriedade deste evento para o empregador no eSocial, nem pode ser posterior a 30 (trinta) dias da data atual.
	If Empty( dDtIniCond )
		aAdd( aIncEnv, cStrFil + " / " + STR0013 + ": " + STR0004 ) //Data de Início das Atividades: Em Branco
		aAdd( aIncEnv, '' )
	ElseIf !( dDtIniCond >= dDtAdm .And. dDtIniCond >= dDtEsoc .And. IIf( ( lGPEA010 .And. lGerXml ) .Or. !lGPEA010, dDtIniCond <= ( dDataBase + 30 ), .T. ) )
		aAdd( aIncEnv, cStrFil + " / " + STR0013 + ": " + DToC( dDtIniCond ) ) //Data de Início das Atividades: XX/XX/XXXX
		aAdd( aIncEnv, STR0005 + ": " + STR0014 + ":" ) //Validação: Deve ser uma data válida e:
		aAdd( aIncEnv, "* " + STR0015 + ": " + DToC( dDtAdm ) ) //* Igual ou posterior à data de admissão do trabalhador: XX/XX/XXXX
		aAdd( aIncEnv, "* " + STR0016 + ": " + DToC( dDtEsoc ) ) //* Igual ou posterior à data de início de obrigatoriedade dos eventos de SST ao eSocial: XX/XX/XXXX
		aAdd( aIncEnv, "* " + STR0017 + ": " + DToC( dDataBase + 30 ) ) //* Igual ou anterior à 30 dias a partir da data atual: XX/XX/XXXX
		aAdd( aIncEnv, '' )
	EndIf

	//Ambiente de trabalho do funcionário
	If Len( aAmbExp ) > 0

		//Validação da tag <localAmb> - Tipo de estabelecimento do ambiente de trabalho
		//Valores válidos: 1 - Estabelecimento do próprio empregador ou 2 - Estabelecimento de terceiros
		If Empty( aAmbExp[ 1, 2 ] )
			aAdd( aIncEnv, cStrFil + " / " + STR0018 + ": " + aAmbExp[ 1, 1 ] + " / " + STR0019 + ": " + STR0004 ) //Ambiente: XXX / Tipo do Estabelecimento: Em Branco
			aAdd( aIncEnv, '' )
		ElseIf !( aAmbExp[ 1, 2 ] $ "1/2" )
			aAdd( aIncEnv, cStrFil + " / " + STR0018 + ": " + aAmbExp[ 1, 1 ] + " / " + STR0019 + ": " + aAmbExp[ 1, 2 ] ) //Ambiente: XXX / Tipo do Estabelecimento: XXX
			aAdd( aIncEnv, STR0005 + ": " + STR0020 ) //Validação: Deve ser igual a 1- Estabelecimento do Empregador ou 2- Estabelecimento de Terceiro
			aAdd( aIncEnv, '' )
		EndIf

		//Validação da tag <dscSetor> - Descrição do lugar administrativo, na estrutura organizacional da empresa, onde o trabalhador exerce suas
		//atividades laborais.
		//Informação obrigatória
		If Empty( aAmbExp[ 1, 3 ] )
			aAdd( aIncEnv, cStrFil + " / " + STR0018 + ": " + aAmbExp[ 1, 1 ] + " / " + STR0021 + ": " + STR0004 ) //Ambiente: XXX / Descrição: Em Branco
			aAdd( aIncEnv, '' )
		EndIf

		//Validação da tag <tpInsc> - Código correspondente ao tipo de inscrição, conforme Tabela 05
		//Valores válidos: 1 - CNPJ, 3 - CAEPF ou 4 - CNO
		If Empty( aAmbExp[ 1, 4 ] )
			aAdd( aIncEnv, cStrFil + " / " + STR0018 + ": " + aAmbExp[ 1, 1 ] + " / " + STR0003 + ": " + STR0004 ) //Ambiente: XXX / Tipo de Inscrição: Em branco
			aAdd( aIncEnv, '' )
		ElseIf !( aAmbExp[ 1, 4 ] $ "1/3/4" )
			aAdd( aIncEnv, cStrFil + " / " + STR0018 + ": " + aAmbExp[ 1, 1 ] + " / " + STR0003 + ": " + aAmbExp[ 1, 4 ] ) //Ambiente: XXX / Tipo de Inscrição: XXX
			aAdd( aIncEnv, STR0005 + ": " + STR0022 ) //Validação: Deve ser igual a 1- CNPJ, 3- CAEPF ou 4- CNO
			aAdd( aIncEnv, '' )
		EndIf

		//Validação da tag <nrInsc> - Número de inscrição onde está localizado o ambiente
		//Validação: Deve ser um identificador válido, compatível com o conteúdo do campo infoAmb/tpInsc e: a) Se localAmb = [1], deve ser válido
		//e existente na Tabela de Estabelecimentos (S-1005); b) Se localAmb = [2], deve ser diferente dos estabelecimentos informados na Tabela
		//S-1005 e, se infoAmb/tpInsc = [1] e o empregador for pessoa jurídica, a raiz do CNPJ informado deve ser diferente da constante em S-1000.
		//Caso o tipo de inscrição seja igual a 1 (CNPJ), valida primeiramente se é um CNPJ válido
		If Empty( aAmbExp[ 1, 5 ] )
			aAdd( aIncEnv, cStrFil + " / " + STR0018 + ": " + aAmbExp[ 1, 1 ] + " / " + STR0007 + ": " + STR0004 ) //Ambiente: XXX / Número de Inscrição: Em branco
			aAdd( aIncEnv, '' )
		Else
			If !Empty( aAmbExp[ 1, 4 ] ) //Caso o tipo de inscrição estiver preenchido, valida o número da inscrição
				If aAmbExp[ 1, 4 ] == "1" //Caso o tipo de inscrição for igual a CNPJ, valida se é um CNPJ válido
					If !CGC( aAmbExp[ 1, 5 ] )
						aAdd( aIncEnv, cStrFil + " / " + STR0018 + ": " + aAmbExp[ 1, 1 ] + " / " + STR0007 + ": " + aAmbExp[ 1, 5 ] ) //Ambiente: XXX / Número de Inscrição: XXX
						aAdd( aIncEnv, STR0005 + ": " + STR0008 ) //Validação: Deve ser um número de CNPJ válido
						aAdd( aIncEnv, '' )
						lVldNrIns := .F.
					EndIf
				EndIf

				If lVldNrIns
					If !MDTNrInsc( aAmbExp[ 1, 2 ], aAmbExp[ 1, 4 ], aAmbExp[ 1, 5 ], cNumMat ) //Valida o Número de Inscrição do Ambiente
						aAdd( aIncEnv, cStrFil + " / " + STR0018 + ": " + aAmbExp[ 1, 1 ] + " / " + STR0007 + ": " + aAmbExp[ 1, 5 ] ) //Ambiente: XXX / Número de Inscrição: XXX
						aAdd( aIncEnv, STR0005 + ": " + STR0023 ) //Validação: 1) Deve constar na tabela S-1005 se o local do ambiente for igual a 'Estabelecimento do próprio empregador'.
						aAdd( aIncEnv, STR0024 ) //2) Deve ser diferente dos estabelecimentos informados na Tabela S-1005 se o local do ambiente for igual a 'Estabelecimento de
						aAdd( aIncEnv, STR0025 ) //terceiros' e diferente do CNPJ base indicado em S-1000 se o tipo de inscrição do local do ambiente for igual a CNPJ.
						aAdd( aIncEnv, '' )
					EndIf
				EndIf
			EndIf
		EndIf
	Else
		If cEntAmb == "1" //Centro de Custo

			aAdd( aIncEnv, cStrFil + " / " + cStrFunc + " / " + cStrCCus ) //Funcionário: XXX - XXXXX / Centro de Custo: XXX - XXXXX
			aAdd( aIncEnv, STR0026 ) //Não foi encontrado um Ambiente relacionado ao Centro de Custo do funcionário
			aAdd( aIncEnv, '' )

		ElseIf cEntAmb == "2" //Departamento

			aAdd( aIncEnv, cStrFil + " / " + cStrFunc + " / " + cStrDepto ) //Funcionário: XXX - XXXXX / Departamento: XXX - XXXXX
			aAdd( aIncEnv, STR0056 ) //Não foi encontrado um ambiente relacionado ao departamento do funcionário
			aAdd( aIncEnv, '' )

		ElseIf cEntAmb == "3" //Função

			aAdd( aIncEnv, cStrFil + " / " + cStrFunc + " / " + cStrFuncao ) //Funcionário: XXX - XXXXX / Função: XXX - XXXXX
			aAdd( aIncEnv, STR0057 ) //Não foi encontrado um ambiente relacionado à função do funcionário
			aAdd( aIncEnv, '' )

		ElseIf cEntAmb == "4" //Tarefa

			// Caso for chamada pelo cadastro de funcionário e é geração de xml ou
			// caso não for chamada via cadastro do funcionário (não existe como vincular uma tarefa ao funcionário antes de cadastrá-lo no GPEA010) ou
			// caso for transferência não existe como vincular o funcionário a alguma tarefa
			If ( lGPEA010 .And. lGerXml ) .Or. ( !lGPEA010 .And. !lGPEA180 .And. !lGPEM040 .And. !lMDTA090 )
			
				If lMDTA090 //Caso for chamado pela rotina de Tarefas do Funcionário
					oModel := FWModelActive()
				EndIf

				//Busca as tarefas que o funcionário realiza
				aTarefas := MDTGetTar( cNumMat, dDtIniCond, oModel )

				For nCont := 1 To Len( aTarefas )
					If nCont == Len( aTarefas )
						cBarra := ""
					EndIf
					cTarefas += AllTrim( aTarefas[ nCont, 1 ] ) + " - " + AllTrim( Posicione( "TN5", 1, xFilial( "TN5" ) + aTarefas[ nCont, 1 ], "TN5_NOMTAR" ) ) + cBarra
				Next nCont

				aAdd( aIncEnv, cStrFil + " / " + cStrFunc ) //Funcionário: XXX - XXXXX
				aAdd( aIncEnv, STR0060 + ": " + IIf( !Empty( cTarefas ), cTarefas, STR0061 ) ) //"Tarefas: XXX - XXXXX" ou "Nenhuma tarefa vinculada ao funcionário"
				aAdd( aIncEnv, STR0058 ) //Não foi encontrado um ambiente relacionado à alguma tarefa do funcionário
				aAdd( aIncEnv, '' )

			EndIf

		ElseIf cEntAmb == "5" //Funcionário

			// Caso for chamada pelo cadastro de funcionário e é geração de xml ou
			// Caso não for chamada via cadastro do funcionário (não existe como vincular um ambiente ao funcionário antes de cadastrá-lo no GPEA010)
			// Mesmo caso para transferência do funcionário
			// Caso não for chamada via cadastro de ambiente (precisa permitir o vínculo antes de validar)
			// Cadastro de tarefas também
			If ( lGPEA010 .And. lGerXml ) .Or. ( !lGPEA010 .And. !lGPEA180 .And. !lMDTA090 )
				aAdd( aIncEnv, cStrFil + " / " + cStrFunc ) //Funcionário: XXX - XXXXX
				aAdd( aIncEnv, STR0059 ) //"Não foi encontrado um ambiente relacionado ao funcionário"
				aAdd( aIncEnv, '' )
			EndIf

		EndIf
	EndIf

	//Validação da tag <dscAtivDes> - Descrição das atividades, físicas ou mentais, realizadas pelo trabalhador, por força do poder de comando a
	//que se submete. As atividades deverão ser escritas com exatidão, e de forma sucinta, com a utilização de verbos no infinitivo impessoal.
	//Ex.: Distribuir panfletos, operar máquina de envase, etc.
	//Informação obrigatória
	If lVldDsc .And. Empty( cDscAtivDes )
		aAdd( aIncEnv, cStrFil + " / " + cStrFunc + " / " + STR0027 + ": " + STR0004 ) //Funcionário: XXX - XXXXX / Descrição das Atividades Realizadas: Em branco
		aAdd( aIncEnv, '' )
	EndIf

	// Agentes nocivos a que o funcionário está exposto
	For nCont := 1 To Len( aRisTrat )

		//Validação da tag <codAgNoc> - Código do agente nocivo ao qual o trabalhador está exposto
		//Validação: Deve ser um código válido e existente na Tabela 24. Não é possível informar nenhum outro código de agente nocivo quando
		//houver o código [09.01.001].
		If Empty( aRisTrat[ nCont, 3 ] ) //<codAgNoc>
			aAdd( aIncEnv, cStrFil + " / " + STR0028 + ": " + aRisTrat[ nCont, 2 ] + " / " + STR0029 + ": " + STR0004 ) //Agente: XXX / Código eSocial: Em branco
			aAdd( aIncEnv, '' )
		ElseIf aRisTrat[ nCont, 3 ] != "09.01.001"
			If !ExistCPO( "V5Y", aRisTrat[ nCont, 3 ], 2 )
				aAdd( aIncEnv, cStrFil + " / " + STR0028 + ": " + aRisTrat[ nCont, 2 ] + " / " + STR0029 + ": " + aRisTrat[ nCont, 3 ] ) //Agente: XXX / Código eSocial: XXX
				aAdd( aIncEnv, STR0005 + ": " + STR0030 ) //Validação: Deve ser um código válido e existente na tabela 24 do eSocial
				aAdd( aIncEnv, '' )
			EndIf
		EndIf

		// Validação da tag <dscAgNoc> - Descrição do agente nocivo
		// Validação: Preenchimento obrigatório se codAgNoc = [01.01.001, 01.02.001, 01.03.001, 01.04.001, 01.05.001, 01.06.001, 01.07.001,
		//01.08.001, 01.09.001, 01.10.001, 01.12.001, 01.13.001, 01.14.001, 01.15.001, 01.16.001, 01.17.001, 01.18.001, 05.01.001].
		If Empty( aRisTrat[ nCont, 4 ] ) .And. aRisTrat[ nCont, 3 ] $ cLisAge // </dscAgNoc>
			aAdd( aIncEnv, cStrFil + " / " + STR0028 + ": " + aRisTrat[ nCont, 2 ] + " / " + STR0021 + ": " + STR0004 ) // Agente: XXX / Descrição: Em branco
			aAdd( aIncEnv, '' )
		ElseIf Len( aRisTrat[ nCont, 4 ]) > 100 .And. aRisTrat[ nCont, 3 ] $ cLisAge // </dscAgNoc>
			
			aAdd( aIncEnv, cStrFil + " / " + cStrFunc + " / " + STR0028 + ": " + aRisTrat[ nCont, 2 ] + " / " + STR0021 + ": " + STR0065 ) // Funcionário: XXX - XXXXX / Agente: XXX / Descrição: Contém mais que 100 caracteres
			aAdd( aIncEnv, '' )
		
		EndIf

		//Validação da tag <tpAval> - Tipo de avaliação do agente nocivo
		//Valores válidos: 1 - Critério quantitativo ou 2 - Critério qualitativo
		//Validação: Preenchimento obrigatório e exclusivo se codAgNoc for diferente de [09.01.001].
		If aRisTrat[ nCont, 3 ] != "09.01.001"
			If Empty( aRisTrat[ nCont, 5 ] ) //</tpAval>
				aAdd( aIncEnv, cStrFil + " / " + STR0028 + ": " + aRisTrat[ nCont, 2 ] + " / " + STR0031 + ": " + STR0004 ) //Agente: XXX / Tipo de Avaliação: Em branco
				aAdd( aIncEnv, '' )
			ElseIf !( aRisTrat[ nCont, 5 ] $ "1/2" )
				aAdd( aIncEnv, cStrFil + " / " + STR0028 + ": " + aRisTrat[ nCont, 2 ] + " / " + STR0031 + ": " + aRisTrat[ nCont, 5 ] ) //Agente: XXX / Tipo de Avaliação: XXX
				aAdd( aIncEnv, STR0005 + ": " + STR0032 ) //Validação: Deve ser igual a 1- Critério quantitativo ou 2- Critério qualitativo
				aAdd( aIncEnv, '' )
			EndIf
		EndIf

		If 'S_01_02' $ MdtRetLei( 'S-2240' ) .And. aRisTrat[ nCont, 3 ] == '05.01.001' .And. dDtIniCond >= CtoD( '22/01/2024' )
			If Empty( aRisTrat[ nCont, 14 ] )
				aAdd( aIncEnv, STR0066 + ':' + Space( 1 ) + STR0004 ) // "Número do processo" // "Em branco"
				aAdd( aIncEnv, '' )
			EndIf
		EndIf

		//Validação da tag <intConc> - Intensidade, concentração ou dose da exposição do trabalhador ao agente nocivo
		//Validação: Preenchimento obrigatório e exclusivo se tpAval = [1].
		If Empty( aRisTrat[ nCont, 6 ] ) .And. aRisTrat[ nCont, 5 ] == "1" //<intConc>
			aAdd( aIncEnv, cStrFil + " / " + STR0033 + ": " + aRisTrat[ nCont, 1 ] + " / " + STR0034 + ": " + STR0004 ) //Risco: XXX / Intensidade de Exposição: Em branco
			aAdd( aIncEnv, '' )
		EndIf

		//Validação da tag <limTol> - Limite de tolerância calculado para agentes específicos
		//Validação: Preenchimento obrigatório e exclusivo se tpAval = [1] e codAgNoc = [01.18.001, 02.01.014].
		If Empty( aRisTrat[ nCont, 7 ] ) .And. aRisTrat[ nCont, 5 ] == "1" .And. aRisTrat[ nCont, 3 ] $ "01.18.001/02.01.014" //<limTol>
			aAdd( aIncEnv, cStrFil + " / " + STR0033 + ": " + aRisTrat[ nCont, 1 ] + " / " + STR0035 + ": " + STR0004 ) //Risco: XXX / Limite de Tolerância: Em branco
			aAdd( aIncEnv, '' )
		EndIf

		//Validação da tag <unMed> - Dose ou unidade de medida da intensidade ou concentração do agente
		//Valores válidos:
		// 1 - dose diária de ruído
		// 2 - decibel linear (dB (linear))
		// 3 - decibel (C) (dB(C))
		// 4 - decibel (A) (dB(A))
		// 5 - metro por segundo ao quadrado (m/s²)
		// 6 - metro por segundo elevado a 1,75 (m/s^1,75)
		// 7 - parte de vapor ou gás por milhão de partes de ar contaminado (ppm)
		// 8 - miligrama por metro cúbico de ar (mg/m³)
		// 9 - fibra por centímetro cúbico (f/cm³)
		// 10 - grau Celsius (ºC)
		// 11 - metro por segundo (m/s)
		// 12 - porcentual
		// 13 - lux (lx)
		// 14 - unidade formadora de colônias por metro cúbico (ufc/m³)
		// 15 - dose diária
		// 16 - dose mensal
		// 17 - dose trimestral
		// 18 - dose anual
		// 19 - watt por metro quadrado (W/m²)
		// 20 - ampère por metro (A/m)
		// 21 - militesla (mT)
		// 22 - microtesla (?T)
		// 23 - miliampère (mA)
		// 24 - quilovolt por metro (kV/m)
		// 25 - volt por metro (V/m)
		// 26 - joule por metro quadrado (J/m²)
		// 27 - milijoule por centímetro quadrado (mJ/cm²)
		// 28 - milisievert (mSv)
		// 29 - milhão de partículas por decímetro cúbico (mppdc)
		// 30 - umidade relativa do ar (UR (%))
		//Validação: Preenchimento obrigatório e exclusivo se tpAval = [1].
		If aRisTrat[ nCont, 5 ] == "1" // Se o agente for quantitativo
			If Empty( aRisTrat[ nCont, 8 ] ) //<unMed>
				aAdd( aIncEnv, cStrFil + " / " + STR0033 + ": " + aRisTrat[ nCont, 1 ] + " / " + STR0036 + ": " + STR0004 ) //Risco: XXX / Unidade de Medida: Em branco
				aAdd( aIncEnv, '' )
			Else
				If !ExistCPO( "V3F", aRisTrat[ nCont, 8 ], 2 )
					aAdd( aIncEnv, cStrFil + " / " + STR0033 + ": " + aRisTrat[ nCont, 1 ] + " / " + STR0036 + ": " + aRisTrat[ nCont, 8 ] ) //Risco: XXX / Unidade de Medida: XXX
					aAdd( aIncEnv, STR0005 + ": " + STR0037 ) //Validação: Deve ser um código válido e existente na descrição da tag <unMed> do evento S-2240 do eSocial
					aAdd( aIncEnv, '' )
				EndIf
			EndIf
		EndIf

		//Validação da tag <tecMedicao> - Técnica utilizada para medição da intensidade ou concentração
		//Validação: Preenchimento obrigatório e exclusivo se tpAval = [1].
		If Empty( aRisTrat[ nCont, 9 ] ) .And. aRisTrat[ nCont, 5 ] == "1" //<tecMedicao>
			aAdd( aIncEnv, cStrFil + " / " + STR0033 + ": " + aRisTrat[ nCont, 1 ] + " / " + STR0038 + ": " + STR0004 ) //Risco: XXX / Técnica de Medição: Em branco
			aAdd( aIncEnv, '' )
		EndIf

		//Validação da tag <utilizEPC> - O empregador implementa medidas de proteção coletiva (EPC) para eliminar ou reduzir a exposição dos
		//trabalhadores ao agente nocivo?
		//Valores válidos: 0 - Não se aplica, 1 - Não implementa ou 2 - Implementa
		If Empty( aRisTrat[ nCont, 10 ] ) //<utilizEPC>
			aAdd( aIncEnv, cStrFil + " / " + STR0033 + ": " + aRisTrat[ nCont, 1 ] + " / " + STR0039 + ": " + STR0004 ) //Risco: XXX / Indicativo de Implementação de EPC: Em branco
			aAdd( aIncEnv, '' )
		ElseIf !( aRisTrat[ nCont, 10 ] $ "0/1/2" )
			aAdd( aIncEnv, cStrFil + " / " + STR0033 + ": " + aRisTrat[ nCont, 1 ] + " / " + STR0039 + ": " + aRisTrat[ nCont, 10 ] ) //Risco: XXX / Indicativo de Implementação de EPC: XXX
			aAdd( aIncEnv, STR0005 + ": " + STR0040 ) //Validação: Deve ser igual a 0- Não se aplica, 1- Não implementa ou 2- Implementa
			aAdd( aIncEnv, '' )
		EndIf

		//Validação da tag <eficEpc> - Os EPCs são eficazes na neutralização dos riscos ao trabalhador?
		//Valores válidos: S - Sim ou N - Não
		//Validação: Preenchimento obrigatório e exclusivo se utilizEPC = [2].
		If Empty( aRisTrat[ nCont, 11 ] ) .And. aRisTrat[ nCont, 10 ] == "2"
			aAdd( aIncEnv, cStrFil + " / " + STR0033 + ": " + aRisTrat[ nCont, 1 ] + " / " + STR0041 + ": " + STR0004 ) //Risco: XXX / Indicativo de Efiência dos EPC's: Em branco
			aAdd( aIncEnv, '' )
		EndIf

		//Validação da tag <utilizEPI> - Utilização de EPI
		//Valores válidos: 0 - Não se aplica, 1 - Não utilizado ou 2 - Utilizado
		If Empty( aRisTrat[ nCont, 12 ] ) //<utilizEPI>
			aAdd( aIncEnv, cStrFil + " / " + STR0033 + ": " + aRisTrat[ nCont, 1 ] + " / " + STR0042 + ": " + STR0004 ) //Risco: XXX / Indicativo de Utilização de EPI: Em branco
			aAdd( aIncEnv, '' )
		EndIf

		//Caso não for cadastro de risco
		If ( lGPEA010 .And. lGerXml ) .Or. ( !lGPEA010 .And. !lGPEA180 .And. !lMDTA165 .And. !lMDTA180 .And. !lMDTA090 )
			//Caso a tag <utilizEPI> seja igual a 'Sim'
			If !Empty( aRisTrat[ nCont, 12 ] ) .And. aRisTrat[ nCont, 12 ] == "2"
				//Validação de existência de EPI's entregues ao funcionário
				If Len( aRisTrat[ nCont, 13 ] ) == 0
					aAdd( aIncEnv, cStrFil + " / " + STR0033 + ": " + aRisTrat[ nCont, 1 ] + " / " + STR0042 + ": " + aRisTrat[ nCont, 12 ] ) //Risco: XXX / Indicativo de Utilização de EPI: XXX
					aAdd( aIncEnv, cStrFunc ) //Funcionário: XXX - XXXXX
					aAdd( aIncEnv, STR0005 + ": " + STR0063 ) //"O risco foi definido com o indicativo de utilização de EPI igual a 'Sim' porém não existem"
					aAdd( aIncEnv, STR0064 ) //"EPI's necessários a esse risco entregues ao funcionário"
					aAdd( aIncEnv, '' )
				EndIf
			EndIf
		EndIf

	Next nCont

	//Responsável pelos Registros Ambientais
	If Len( aRespAmb ) > 0
		For nCont := 1 To Len( aRespAmb )

			//Validação da tag <cpfResp> - CPF do responsável pelos registros ambientais
			//Validação: Deve ser um CPF válido.
			If Empty( aRespAmb[ nCont, 3 ] ) //<cpfResp>
				aAdd( aIncEnv, cStrFil + " / " + STR0044 + ": " + aRespAmb[ nCont, 1 ] + " - " + aRespAmb[ nCont, 2 ] + " / " + STR0010 + ": " + STR0004 ) //Responsável pelos Registros Ambientais: XXX - XXX / CPF: Em branco
				aAdd( aIncEnv, '' )
			ElseIf !CHKCPF( aRespAmb[ nCont, 3 ] ) //<cpfResp>
				aAdd( aIncEnv, cStrFil + " / " + STR0044 + ": " + aRespAmb[ nCont, 1 ] + " - " + aRespAmb[ nCont, 2 ] + " / " + STR0010 + ": " + aRespAmb[ nCont, 3 ] ) //Responsável pelos Registros Ambientais: XXX - XXX / CPF: XXX
				aAdd( aIncEnv, STR0005 + ": " + STR0009 ) //Validação: Deve ser um número de CPF válido
				aAdd( aIncEnv, '' )
			EndIf

			//Validação da tag <ideOC> - Órgão de classe ao qual o responsável pelos registros ambientais está vinculado
			//Valores válidos: 1 - Conselho Regional de Medicina - CRM, 4 - Conselho Regional de Engenharia e Agronomia - CREA ou 9 - Outros
			//Preenchimento obrigatório se codAgNoc for diferente de [09.01.001].
			If Len( aRisTrat ) > 0 //Caso o funcionário esteja exposto a algum risco diferente de 09.01.001
				If Empty( aRespAmb[ nCont, 4 ] ) //<ideOC>
					aAdd( aIncEnv, cStrFil + " / " + STR0044 + ": " + aRespAmb[ nCont, 1 ] + " - " + aRespAmb[ nCont, 2 ] + " / " + STR0045 + ": " + STR0004 ) //Responsável pelos Registros Ambientais: XXX - XXXXX / Órgão de Classe: Em branco
					aAdd( aIncEnv, '' )
				ElseIf !( aRespAmb[ nCont, 4 ] $ "1/4/9" )
					aAdd( aIncEnv, cStrFil + " / " + STR0044 + ": " + aRespAmb[ nCont, 1 ] + " - " + aRespAmb[ nCont, 2 ] + " / " + STR0045 + ": " + aRespAmb[ nCont, 4 ] ) //Responsável pelos Registros Ambientais: XXX - XXXXX / Órgão de Classe: XXX
					aAdd( aIncEnv, STR0005 + ": " + STR0046 ) //Validação: Deve ser igual a 1- CRM, 4- CREA ou 9- Outros
					aAdd( aIncEnv, '' )
				EndIf
			EndIf

			//Validação da tag <dscOC> - Descrição (sigla) do órgão de classe ao qual o responsável pelos registros ambientais está vinculado
			//Validação: Preenchimento obrigatório e exclusivo se ideOC = [9].
			If Empty( aRespAmb[ nCont, 5 ] ) .And. aRespAmb[ nCont, 4 ] == "9" //<dscOC>
				aAdd( aIncEnv, cStrFil + " / " + STR0044 + ": " + aRespAmb[ nCont, 1 ] + " - " + aRespAmb[ nCont, 2 ] + " / " + STR0047 + ": " + STR0004 ) //Responsável pelos Registros Ambientais: XXX - XXXXX / Descrição do Órgão de Classe: Em branco
				aAdd( aIncEnv, '' )
			EndIf

			//Validação da tag <nrOC> - Número de inscrição no órgão de classe.
			//Informação Obrigatória
			//Preenchimento obrigatório se codAgNoc for diferente de [09.01.001].
			If Len( aRisTrat ) > 0 //Caso o funcionário esteja exposto a algum risco diferente de 09.01.001
				If Empty( aRespAmb[ nCont, 6 ] ) //<nrOC>
					aAdd( aIncEnv, cStrFil + " / " + STR0044 + ": " + aRespAmb[ nCont, 1 ] + " - " + aRespAmb[ nCont, 2 ] + " / " + STR0048 + ": " + STR0004 ) //Responsável pelos Registros Ambientais: XXX - XXXXX / Número do Órgão de Classe: Em branco
					aAdd( aIncEnv, '' )
				EndIf
			EndIf

			//Validação da tag <ufOC> - UF do órgão de classe
			//Valores válidos: AC, AL, AP, AM, BA, CE, DF, ES, GO, MA, MT, MS, MG, PA, PB, PR, PE, PI, RJ, RN, RS, RO, RR, SC, SP, SE, TO
			//Preenchimento obrigatório se codAgNoc for diferente de [09.01.001].
			If Len( aRisTrat ) > 0 //Caso o funcionário esteja exposto a algum risco diferente de 09.01.001
				If Empty( aRespAmb[ nCont, 7 ] ) //<ufOC>
					aAdd( aIncEnv, cStrFil + " / " + STR0044 + ": " + aRespAmb[ nCont, 1 ] + " - " + aRespAmb[ nCont, 2 ] + " / " + STR0049 + ": " + STR0004 ) //Responsável pelos Registros Ambientais: XXX - XXXXX / UF do Órgão de Classe: Em branco
					aAdd( aIncEnv, '' )
				EndIf
			EndIf

		Next nCont
	Else
		aAdd( aIncEnv, cStrFil + " / " + cStrFunc ) //Funcionário: XXX - XXXXX
		aAdd( aIncEnv, STR0050 ) //Não existem Responsáveis Ambientais para o período de exposição do funcionário
		aAdd( aIncEnv, '' )
	EndIf

	Help := .F. //Ativa novamente as mensagens de Help

	cFilAnt := cFilBkp //Retorna filial do registro
	RestArea( aArea ) //Retorna área

Return

//-------------------------------------------------------------------
/*/{Protheus.doc} fGetAmbExp
Busca as informações do Ambiente de Exposição do Funcionário

@sample	fGetAmbExp( "000000001", "000000002", "00003", "000005" )

@return	aInfAmb, Array, Array contendo as informações do ambiente de exposição

@param cCCusto, Caracter, Centro de Custo do Funcionário
@param cDepto, Caracter, Departamento do Funcionário
@param cFuncao, Caracter, Função do Funcionário
@param cNumMat, Caracter, Matrícula do Funcionário
@param dDtIniCond, Data de início do evento
@param lIncons, Indica se é avaliação de inconsistências das informações de envio

@author Luis Fellipy Bett
@since  19/02/2021
/*/
//-------------------------------------------------------------------
Static Function fGetAmbExp( cCCusto, cDepto, cFuncao, cNumMat, dDtIniCond, lIncons )

	Local aArea	    := GetArea() //Salva a área
	Local cEntAmb   := SuperGetMv( "MV_NG2EAMB", .F., "1" ) //Indica qual entidade será considerada no relacionamento com o ambiente
	Local lTOQ	    := AliasInDic( "TOQ" )
	Local lTOR	    := AliasInDic( "TOR" )
	Local lTOS	    := AliasInDic( "TOS" )
	Local lTOT	    := AliasInDic( "TOT" )
	Local lTOU	    := AliasInDic( "TOU" )
	Local aInfAmb   := {}
	Local aTarefas  := {}
	Local nIndTNE   := 1
	Local nCont	    := 0
	Local cSeekTNE  := ""
	Local oModel    := Nil

	//----------------------------------------------------------------------
	// Busca o ambiente relacionado ao funcionário de acordo com a entidade
	//----------------------------------------------------------------------
	If lTOQ .And. cEntAmb == "1" //Centro de Custo
		
		dbSelectArea( "TOQ" )
		dbSetOrder( 2 )
		If dbSeek( xFilial( "TOQ" ) + cCCusto )
			cSeekTNE := TOQ->TOQ_CODAMB
		EndIf

	ElseIf lTOR .And. cEntAmb == "2" //Departamento

		dbSelectArea( "TOR" )
		dbSetOrder( 2 )
		If dbSeek( xFilial( "TOR" ) + cDepto )
			cSeekTNE := TOR->TOR_CODAMB
		EndIf

	ElseIf lTOS .And. cEntAmb == "3" //Função

		dbSelectArea( "TOS" )
		dbSetOrder( 2 )
		If dbSeek( xFilial( "TOS" ) + cFuncao )
			cSeekTNE := TOS->TOS_CODAMB
		EndIf

	ElseIf lTOT .And. cEntAmb == "4" //Tarefa

		If lMDTA090 //Caso for chamado pela rotina de Tarefas do Funcionário
			oModel := FWModelActive()
		EndIf

		//Busca as tarefas que o funcionário realiza
		aTarefas := MDTGetTar( cNumMat, dDtIniCond, oModel )

		dbSelectArea( "TOT" )
		dbSetOrder( 2 )
		For nCont := 1 To Len( aTarefas )
			If dbSeek( xFilial( "TOT" ) + aTarefas[ nCont, 1 ] )
				cSeekTNE := TOT->TOT_CODAMB
				Exit
			EndIf
		Next nCont

	ElseIf lTOU .And. cEntAmb == "5" // Funcionário

		If lMDTA165
			oModel := FWModelActive()
		EndIf

	Else //Caso o ambiente não esteja atualizado com as tabelas relacionais, pega de acordo com o campo TNE_CODLOT

		nIndTNE := 2
		cSeekTNE := cCCusto

	EndIf

	//-------------------------------------------------------------------------------
	// Posiciona na tabela TNE para buscar as informações do ambiente do funcionário
	//-------------------------------------------------------------------------------
	If !Empty( cSeekTNE )

		dbSelectArea( 'TNE' )
		dbSetOrder( nIndTNE )

		If dbSeek( xFilial( 'TNE' ) + cSeekTNE )

			aAdd( aInfAmb, {;
				AllTrim( TNE->TNE_CODAMB ),;
				IIf( TNE->TNE_LOCAMB == '1', '1', '2' ),;
				AllTrim( SubStr( MDTSubTxt( Upper( TNE->TNE_MEMODS ) ), 1, 99 ) ),;
				IIf( TNE->TNE_TPINS == '2', '3', IIf( TNE->TNE_TPINS == '3', '4', TNE->TNE_TPINS ) ),;
				TNE->TNE_NRINS;
			} )

		EndIf

	ElseIf lTOU .And. cEntAmb == '5'

		DbSelectArea( 'TOU' )
		DbSetOrder( 2 )

		If DbSeek( xFilial( 'TOU' ) + cNumMat )

			While ( 'TOU' )->( !Eof() ) .And. xFilial( 'TOU' ) + cNumMat == TOU->TOU_FILIAL + TOU->TOU_MAT

				dbSelectArea( 'TNE' )
				dbSetOrder( nIndTNE )
				If dbSeek( xFilial( 'TNE' ) + TOU->TOU_CODAMB )

					aAdd( aInfAmb, {;
						AllTrim( TNE->TNE_CODAMB ),;
						IIf( TNE->TNE_LOCAMB == '1', '1', '2' ),;
						AllTrim( SubStr( MDTSubTxt( Upper( TNE->TNE_MEMODS ) ), 1, 99 ) ),;
						IIf( TNE->TNE_TPINS == '2', '3', IIf( TNE->TNE_TPINS == '3', '4', TNE->TNE_TPINS ) ),;
						TNE->TNE_NRINS;
					} )

				EndIf

				( 'TOU' )->( DbSkip() )

			End

		EndIf

		If lMDTA165 .And. lIncons // No momento do envio os registros já foram cadastrados

			If AScan( aInfAmb, { | x | x[ 1 ] == oModel:GetValue( 'TNEMASTER', 'TNE_CODAMB' ) } ) == 0

				aAdd( aInfAmb, { AllTrim( oModel:GetValue( 'TNEMASTER', 'TNE_CODAMB' ) ),;
					IIf( oModel:GetValue( 'TNEMASTER', 'TNE_LOCAMB' ) == '1', '1', '2' ),;
					AllTrim( SubStr( MDTSubTxt( Upper( oModel:GetValue( 'TNEMASTER', 'TNE_MEMODS' ) ) ), 1, 99 ) ),;
					IIf( oModel:GetValue( 'TNEMASTER', 'TNE_TPINS' ) == '2', '3', IIf( oModel:GetValue( 'TNEMASTER', 'TNE_TPINS' ) == '3', '4', oModel:GetValue( 'TNEMASTER', 'TNE_TPINS' ) ) ),;
					oModel:GetValue( 'TNEMASTER', 'TNE_NRINS' );
				} )

			EndIf

		EndIf

	EndIf

	//Retorna a área
	RestArea( aArea )

Return aInfAmb

//-------------------------------------------------------------------
/*/{Protheus.doc} fGetDscAti
Busca a descrição das atividades desempenhadas pelo funcionário de acordo
com o parâmetro MV_NG2TDES

@sample	fGetDscAti( "00000012" )

@return	cDscAtiv, Caracter, Descrição das atividades do funcionário

@param cNumMat, Caracter, Matrícula do funcionário (RA_MAT)
@param dDtIniCond, Date, Data de Início das condições ambientais
@param aGPEA180, Array, Array contendo as informações da transferência do funcionário
	1ª posição - Data da transferência
	2ª posição - Empresa origem
	3ª posição - Empresa destino
	4ª posição - Filial origem
	5ª posição - Filial destino
	6ª posição - Matrícula origem
	7ª posição - Matrícula destino
	8ª posição - Centro de custo origem
	9ª posição - Centro de custo destino
	10ª posição - Departamento origem
	11ª posição - Departamento destino
	12ª posição - Função destino
	13ª posição - Cargo destino
	14ª posição - Código único destino

@author Luis Fellipy Bett
@since  19/02/2021
/*/
//-------------------------------------------------------------------
Static Function fGetDscAti( cNumMat, dDtIniCond, aGPEA180 )

	Local aTarefas 	:= {}

	Local cTraco   	:= ""
	Local cCargo   	:= ""
	Local cFuncao  	:= ""
	Local cCenCus  	:= ""
	Local cTpDesc  	:= SuperGetMv( "MV_NG2TDES", .F., "1" )
	Local cFilOri  	:= IIf( lGPEA180, aGPEA180[ 1, 4 ], cFilAnt )
	Local cFldDesc 	:= ""
	Local cDscAtiv	:= ""

	Local lFirst   	:= .T.
	Local lFicha 	:= .F.

	Local nCont	   	:= 0

	Local oModel   	:= Nil

	//Caso for transferência de funcionário, pega a função e cargo da filial de destino
	If lGPEA180
		cFuncao := IIf( Len( aGPEA180[ 1 ] ) > 11 .And. !Empty( aGPEA180[ 1, 12 ] ), aGPEA180[ 1, 12 ], "" )
		cCargo	:= IIf( Len( aGPEA180[ 1 ] ) > 12 .And. !Empty( aGPEA180[ 1, 13 ] ), aGPEA180[ 1, 13 ], "" )
	EndIf

	//Caso a função não tenha sido preenchida na chamada do GPEA180
	If Empty( cFuncao )
		cFuncao := Posicione( "SRA", 1, xFilial( "SRA", cFilOri ) + cNumMat, "RA_CODFUNC" )
	EndIf

	//Caso o cargo não tenha sido preenchido na chamada do GPEA180
	If Empty( cCargo )
		cCargo	:= Posicione( "SRA", 1, xFilial( "SRA", cFilOri ) + cNumMat, "RA_CARGO" )
	EndIf

	//Verifica qual descrição buscar de acordo com o parâmetro MV_NG2TDES
	If cTpDesc $ "1/2/4" //Tarefa, Cargo ou Cargo + Tarefa

		If cTpDesc $ "2/4" //Cargo ou Cargo + Tarefa

			If lGPEA370 //Caso for chamado pela rotina de Tarefas do Funcionário
				
				oModel := FWModelActive()
				cDscAtiv := AllTrim ( MDTSubTxt( oModel:GetValue( 'MODELGPEA370', 'Q3_MEMO1' ) ) )
				
			Else

				// Busca o CC do funcionário para pesquisar o cargo
				cCenCus := Posicione( "SRA", 1, xFilial( "SRA", cFilOri ) + cNumMat, "RA_CC" )

				// Busca as informações do Cargo com o CC
				cFldDesc := Posicione( "SQ3", 1, xFilial( "SQ3" ) + cCargo + cCenCus, "Q3_DESCDET" )
				cDscAtiv := AllTrim( ( MDTSubTxt( MSMM( cFldDesc, 80, , , , , , "SQ3", , "RDY" ) ) ) )

				If Empty( cDscAtiv )

					// Busca as informações do Cargo sem o CC
					cFldDesc := Posicione( "SQ3", 1, xFilial( "SQ3" ) + cCargo, "Q3_DESCDET" )
					cDscAtiv := AllTrim( ( MDTSubTxt( MSMM( cFldDesc, 80, , , , , , "SQ3", , "RDY" ) ) ) )

				EndIf

				If Empty( cDscAtiv )

					cDscAtiv := AllTrim( ( Posicione( "SQ3", 1, xFilial( "SQ3" ) + cCargo + cCenCus, "Q3_DESCSUM" ) ) )

					If Empty( cDscAtiv )

						cDscAtiv := AllTrim( MDTSubTxt( ( Posicione( "SQ3", 1, xFilial( "SQ3" ) + cCargo, "Q3_DESCSUM" ) ) ) )

					EndIf

				EndIf

			EndIf

		EndIf

		//Caso for Cargo + Tarefa, adiciona a "/" para separar as informações
		If cTpDesc == "4"
			If !Empty( cDscAtiv )
				cDscAtiv += " / "
			EndIf
		EndIf

		If cTpDesc $ "1/4" //Tarefa ou Cargo + Tarefa

			If lMDTA090 //Caso for chamado pela rotina de Tarefas do Funcionário
				oModel := FWModelActive()
				lFicha := oModel:GetId() == 'mdta007b' // Chamado na rotina de ficha médica
			EndIf

			//Busca as tarefas que o funcionário realiza
			aTarefas := MDTGetTar( cNumMat, dDtIniCond, oModel )

			For nCont := 1 To Len( aTarefas )

				If lMDTA090 .And. !lFicha .And. AllTrim( aTarefas[ nCont, 1 ] ) == AllTrim( oModel:GetValue( "TN5MASTER", "TN5_CODTAR" ) )
					cDscAtiv += cTraco + AllTrim( MDTSubTxt( ( oModel:GetValue( "TN5MASTER", "TN5_DESCRI" ) ) ) )
				Else
					cDscAtiv += cTraco + AllTrim( MDTSubTxt( ( Posicione( "TN5", 1, xFilial( "TN5", cFilOri ) + aTarefas[ nCont, 1 ], "TN5_DESCRI" ) ) ) ) //TN5_FILIAL+TN5_CODTAR
				EndIf

				If Empty( cDscAtiv )

					If lMDTA090 .And. !lFicha .And. AllTrim( aTarefas[ nCont, 1 ] ) == AllTrim( oModel:GetValue( "TN5MASTER", "TN5_CODTAR" ) )
						cDscAtiv += cTraco + AllTrim( ( oModel:GetValue( "TN5MASTER", "TN5_NOMTAR" ) ) )
					Else
						cDscAtiv += cTraco + AllTrim( MDTSubTxt( ( Posicione( "TN5", 1, xFilial( "TN5", cFilOri ) + aTarefas[ nCont, 1 ], "TN5_NOMTAR" ) ) ) ) //TN5_FILIAL+TN5_CODTAR
					EndIf

				EndIf

				If lFirst
					cTraco := " / "
					lFirst := .F.
				EndIf

			Next nCont
		EndIf

	ElseIf cTpDesc == "3" //Função

		cFldDesc := MDTSubTxt( Posicione( "SRJ", 1, xFilial( "SRJ" ) + cFuncao, "RJ_DESCREQ" ) )
		cDscAtiv := AllTrim( MDTSubTxt( ( MSMM( cFldDesc, 80, , , , , , "SRJ", , "RDY" ) ) ) ) 

		If Empty( cDscAtiv )
			cDscAtiv := AllTrim( ( Posicione( "SRJ", 1, xFilial( "SRJ" ) + cFuncao, "RJ_DESC" ) ) ) //RJ_FILIAL+RJ_FUNCAO
		EndIf

	EndIf

Return cDscAtiv

//-------------------------------------------------------------------
/*/{Protheus.doc} MDTGetTar
Busca as tarefas que o funcionário realiza

@sample	MDTGetTar( "00000012" )

@return	aTarFun, Array, Array contendo as tarefas realizadas pelo funcionário

@param cNumMat, Caracter, Matrícula do funcionário (RA_MAT)
@param dDtIniCond, Date, Data de Início das condições ambientais
@param oModel, Objeto, Objeto do modelo

@author Luis Fellipy Bett
@since  19/02/2021
/*/
//-------------------------------------------------------------------
Function MDTGetTar( cNumMat, dDtIniCond, oModel )

	Local aTarFun	:= {}

	Local cTarefa	:= ''

	Local lFicha	:= .F.

	Local nCont	  	:= 0

	Local oGridTN6	:= Nil

	//Se for chamado pelo MDTA090 e não for exclusão, pega as tarefas diretamente da Grid
	If lMDTA090 .And. oModel:GetOperation() != 5

		lFicha := oModel:GetId() == 'mdta007b' // Chamado na rotina de ficha médica

		oGridTN6 := oModel:GetModel( "TN6DETAIL" )

		If !lFicha
			cTarefa := oModel:GetValue( 'TN5MASTER', 'TN5_CODTAR' )
		EndIf

		For nCont := 1 To oGridTN6:Length()

			oGridTN6:GoLine( nCont )

			If lFicha
				cTarefa := oGridTN6:GetValue( 'TN6_CODTAR' )
			EndIf

			If oGridTN6:GetValue( "TN6_MAT" ) == cNumMat .And. aScan( aTarFun, { | x | x[ 1 ] == cTarefa } ) == 0;
			.And. oGridTN6:GetValue( "TN6_DTINIC" ) <= dDtIniCond .And. !oGridTN6:IsDeleted();
			.And. ( oGridTN6:GetValue( "TN6_DTTERM" ) > dDtIniCond .Or. Empty( oGridTN6:GetValue( "TN6_DTTERM" ) ) );

				aAdd( aTarFun, { cTarefa } )

			EndIf

		Next nCont

	EndIf

	dbSelectArea( "TN6" )
	dbSetOrder( 2 )
	dbSeek( xFilial( "TN6" ) + cNumMat )
	While TN6->TN6_FILIAL = xFilial( "TN6" ) .And. TN6->TN6_MAT = cNumMat

		If TN6->TN6_DTINIC <= dDtIniCond .And. ( TN6->TN6_DTTERM > dDtIniCond .Or. Empty( TN6->TN6_DTTERM ) );
		.And. ( !lMDTA090 .Or. ( !lFicha .And. TN6->TN6_CODTAR != oModel:GetValue( 'TN5MASTER', 'TN5_CODTAR' ) ) );
		.And. aScan( aTarFun, { | x | x[1] == TN6->TN6_CODTAR } ) == 0

			aAdd( aTarFun, { TN6->TN6_CODTAR } )

		EndIf

		TN6->( dbSkip() )

	End

Return aTarFun

//-------------------------------------------------------------------
/*/{Protheus.doc} fGetRisExp
Busca as informações de exposição dos riscos do funcionário

@author Luis Fellipy Bett
@since  19/02/2021

@param cNumMat, Caracter, Matricula do funcionário
@param dDtIniCond, Date, Data de Início das condições ambientais
@param nOper, Numérico, Operação que está sendo realizada (3- Inclusão, 4- Alteração ou 5- Exclusão)

@return	aInfRis, Array contendo as informações de exposição dos riscos
/*/
//-------------------------------------------------------------------
Static Function fGetRisExp( cNumMat, dDtIniCond, nOper, lIncons )

	Local aInfRis	:= {}
	Local aInfEPI	:= {}
	Local aRisExp	:= {}

	Local cEPC	  	:= ""
	Local cEfiEPC	:= "S"
	Local cNumRis 	:= ""
	Local cAgente 	:= ""
	Local cUniMed 	:= ""
	Local cTecUti 	:= ""
	Local cNecEPI 	:= ""
	Local cNormat 	:= IIf( TLK->( ColumnPos( 'TLK_NORMAT' ) ) > 0, '1', '' )
	Local cDesAge	:= ''

	Local nRis		:= 0
	Local nEpi		:= 0
	Local nPosRis	:= 0
	Local nQtAgen 	:= 0

	//Busca riscos expostos
	aRisExp := MDTRis2240( dDtIniCond )

	//Caso for cadastro de Risco, adiciona as informações da memória
	If lMDTA180 .And. aScan( aRisExp, { |x| x[1] == M->TN0_NUMRIS } ) == 0 .And. MdtVldRis( dDtIniCond, .T. )
		aAdd( aRisExp, { M->TN0_NUMRIS, M->TN0_AGENTE } )
	EndIf

	For nRis := 1 To Len( aRisExp ) //Percorre os Riscos a que o funcionário está exposto

		dbSelectArea( "TN0" )
		dbSetOrder( 1 )

		If dbSeek( xFilial( "TN0" ) + aRisExp[ nRis, 1 ] ) .And. IIf( lMDTA180, aRisExp[ nRis, 1 ] <> M->TN0_NUMRIS, .T. )
			cNumRis := TN0->TN0_NUMRIS
			cAgente := TN0->TN0_AGENTE
			cDesAge := fBusDesAge( .F. )
			nQtAgen := TN0->TN0_QTAGEN
			cUniMed := TN0->TN0_UNIMED
			cTecUti := TN0->TN0_TECUTI
			cEPC	:= TN0->TN0_EPC
			cNecEPI	:= TN0->TN0_NECEPI
		Else // Cadastro do risco
			cNumRis := aRisExp[ nRis, 1 ]
			cAgente := aRisExp[ nRis, 2 ]
			cDesAge := fBusDesAge( .T., aRisExp[ nRis, 2 ] )
			nQtAgen := M->TN0_QTAGEN
			cUniMed := M->TN0_UNIMED
			cTecUti := M->TN0_TECUTI
			cEPC	:= M->TN0_EPC
			cNecEPI	:= M->TN0_NECEPI
		EndIf

		//Se for exclusão e o funcionário estiver exposto ao Risco que estou excluindo, não envio o Risco ao eSocial
		If !( lMDTA180 .And. nOper == 5 .And. cNumRis == M->TN0_NUMRIS )

			//Epi deve estar entregue ao funcionário e vinculado ao risco
			fGetEpiRis( cNumRis, cNumMat, @aInfEPI, lIncons )

			//Verifica se o EPC é eficaz
			dbSelectArea( "TO9" )
			dbSetOrder( 1 )
			dbSeek( xFilial( "TO9" ) + cNumRis )
			While xFilial( "TO9" ) == TO9->TO9_FILIAL .And. TO9->TO9_NUMRIS == cNumRis
				If TO9->TO9_EFIEPC == "2"
					cEfiEPC := "N"
					Exit
				EndIf
				dbSkip()
			End

			// Caso não exista mais de um Risco com o mesmo fator de Risco no array, adiciona
			If ( nPosRis := aScan( aInfRis, { | x | x[ 3 ] == Posicione( "TMA", 1, xFilial( "TMA" ) + cAgente, "TMA_ESOC" ) .And. ;
			x[ 4 ] == cDesAge } ) ) == 0

				aAdd( aInfRis, { ;
					AllTrim( cNumRis ), ;
					AllTrim( cAgente ), ;
					Posicione( "TMA", 1, xFilial( "TMA" ) + cAgente, "TMA_ESOC" ), ; // Informação obrigatória a ser enviada na tag <codAgNoc>
					cDesAge, ; // Informação a ser enviada na tag <dscAgNoc>
					fGetTpAval( cAgente, nQtAgen ), ; // Informação obrigatória a ser enviada na tag <tpAval>
					cValToChar( nQtAgen ), ; // Informação a ser enviada na tag <intConc>
					MDTGetTLim( , cAgente, nQtAgen, cNormat ), ; // Informação a ser enviada na tag <limTol>
					AllTrim( cUniMed ), ; // Informação a ser enviada na tag <unMed>
					AllTrim( MDTSubTxt( cTecUti ) ), ; // Informação a ser enviada na tag <tecMedicao>
					IIf( Empty( cEPC ), "0" , IIf( cEPC == "1", "2", "1" ) ), ; // Informação obrigatória a ser enviada na tag <utilizEPC>
					cEfiEPC, ; // Informação a ser enviada na tag <eficEpc>
					IIf( Empty( cNecEPI ), "0", IIf( cNecEPI == "1", "2", "1" ) ), ; // Informação obrigatória a ser enviada na tag <utilizEPI>
					aClone( aInfEPI ),;
					fTmaProces( cAgente );
				} )

			Else

				// Caso exista mais de um Risco com um mesmo fator de risco e caso ele tenha maior quantidade de exposição,
				// atribuo os valores dele para serem enviados
				If Val( aInfRis[ nPosRis, 6 ] ) < nQtAgen
					aInfRis[ nPosRis, 1 ] := AllTrim( cNumRis )
					aInfRis[ nPosRis, 2 ] := AllTrim( cAgente )
					aInfRis[ nPosRis, 4 ] := cDesAge // Informação a ser enviada na tag <dscAgNoc>
					aInfRis[ nPosRis, 5 ] := fGetTpAval( cAgente, nQtAgen ) // Informação obrigatória a ser enviada na tag <tpAval>
					aInfRis[ nPosRis, 6 ] := cValToChar( nQtAgen ) // Informação a ser enviada na tag <intConc>
					aInfRis[ nPosRis, 7 ] := MDTGetTLim( , cAgente, nQtAgen, cNormat )
					aInfRis[ nPosRis, 8 ] := AllTrim( cUniMed ) // Informação a ser enviada na tag <unMed>
					aInfRis[ nPosRis, 9 ] := AllTrim( MDTSubTxt( cTecUti ) ) // Informação a ser enviada na tag <tecMedicao>
					aInfRis[ nPosRis, 10 ] := IIf( Empty( cEPC ), "0", IIf( cEPC == "1", "2", "1" ) ) // Informação obrigatória a ser enviada na tag <utilizEPC>
					aInfRis[ nPosRis, 12 ] := IIf( Empty( cNecEPI ), "0", IIf( cNecEPI == "1", "2", "1" ) ) // Informação obrigatória a ser enviada na tag <utilizEPI>
				EndIf

				For nEpi := 1 To Len( aInfEPI )
					If ( aScan( aInfRis[ nPosRis, 13 ], { | x | x[ 1 ] == aInfEPI[ nEpi, 1 ] } ) ) == 0
						aAdd( aInfRis[ nPosRis, 13 ], aClone( aInfEPI[ nEpi ] ) )
					EndIf
				Next nEpi

				If cEfiEPC == "N"
					aInfRis[ nPosRis, 11 ] := cEfiEPC //Informação a ser enviada na tag <eficEpc>
				EndIf

			EndIf

			//Zera array para buscar os relacionados ao próximo risco
			aInfEPI := {}

		EndIf

	Next nRis

Return aInfRis

//-------------------------------------------------------------------
/*/{Protheus.doc} fTmaProces
Retorna o código do processo, caso exista o campo TMA_PROCES

@author Gabriel Sokacheski
@since 02/11/2023

@param cAgente, código do agente

@return cProcesso, valor preenchido no campo TMA_PROCES
/*/
//-------------------------------------------------------------------
Static Function fTmaProces( cAgente )

	Local cProcesso := ''

	DbSelectArea( 'TMA' )

	If FieldPos( 'TMA_PROCES' ) > 0
		cProcesso := Posicione( 'TMA', 1, xFilial( 'TMA' ) + cAgente, 'TMA_PROCES' )
	Else
		cProcesso := ''
	EndIf

Return cProcesso

//-------------------------------------------------------------------
/*/{Protheus.doc} fBusDesAge
Busca o conteúdo da tag dscAgNoc

@author Gabriel Sokacheski
@since 20/02/2023

@param lCadRis, indica se está no cadastro de risco
@param cCodAgeRis, código do agente do risco sendo cadastrado

@return	cDesAge, conteúdo a ser considerado na tag
/*/
//-------------------------------------------------------------------
Static Function fBusDesAge( lCadRis, cCodAgeRis )

	Local cAgente := ''
	Local cDesAge := ''

	Local cCodAmb := ''

	If lCadRis
		cAgente := cCodAgeRis
		cCodAmb := M->TN0_CODAMB
	Else
		cAgente := TN0->TN0_AGENTE
		cCodAmb := TN0->TN0_CODAMB
	EndIf

	If MdtTraAvul( cCodCateg )

		If !Empty( cCodAmb )

			DbSelectArea( 'TNE' )
			( 'TNE' )->( DbSetOrder( 1 ) )

			If ( 'TNE' )->( DbSeek( xFilial( 'TNE' ) + cCodAmb ) )

				Do case
					Case TNE->TNE_TPINS = '1'
						cDesAge := 'CNPJ'
					Case TNE->TNE_TPINS = '2'
						cDesAge := 'CAEPF'
					Case TNE->TNE_TPINS = '3'
						cDesAge := 'CNO'
				EndCase

				cDesAge += Space( 1 ) + AllTrim( TNE->TNE_NRINS )

			EndIf

		EndIf

	Else

		cDesAge := AllTrim( MDTSubTxt( Posicione( 'TMA', 1, xFilial( 'TMA' ) + cAgente, 'TMA_DESCRI' ) ) )

	EndIf

Return cDesAge

//-------------------------------------------------------------------
/*/{Protheus.doc} fGetResAmb
Busca as informações do responsável pelos registros ambientais

@sample	fGetResAmb( 12/03/2021 )

@return	aResp, Array, Array contendo as informações do responsável pelos registros ambientais

@param	dDtIniCond, Date, Data de Início das condições ambientais
@param	aRisTrat, Array, Array contendo os riscos que serão enviados ao governo para o funcionário

@author	Luis Fellipy Bett
@since	22/02/2021
/*/
//-------------------------------------------------------------------
Static Function fGetResAmb( dDtIniCond, aRisTrat )

	Local lAllResp	:= SuperGetMv( "MV_NG2RAMB", .F., "1" ) == "1"
	Local cTpUsu	:= SuperGetMv( "MV_NG2REST", .F., "1" )
	Local cAliasLau	:= GetNextAlias()
	Local aResp		:= {}
	Local aUsus		:= {}
	Local nCont		:= 0
	Local cResTaf	:= ""
	Local nIdeOC	:= ""
	Local cExpRis	:= "%"
	Local cVirgula	:= ", "

	//Variável da tabela a ser considerada na query (usada dessa forma para pegar corretamente na transferência entre empresas)
	Local cTblTO0 := "%" + RetFullName( "TO0", cEmpAnt ) + "%"
	Local cTblTO1 := "%" + RetFullName( "TO1", cEmpAnt ) + "%"

	//Parâmetro que indica que tipo de Usuário Responsável será enviado ao TAF
	If cTpUsu == "1" //Médico do Trabalho
		cResTaf := "1"
	ElseIf cTpUsu == "2" //Engenheiro do Trabalho
		cResTaf := "4"
	ElseIf cTpUsu == "3" //Ambos
		cResTaf := "1/4"
	ElseIf cTpUsu == "4" //Todos
		cResTaf := "1/2/3/4/5/6/7/8/9/A/B/C"
	EndIf

	//Caso sejam enviados todos os responsáveis ambientais ou caso sejam enviados apenas os relacionados a riscos e o funcionário 
	//não estiver exposto a nenhum risco
	If lAllResp .Or. ( !lAllResp .And. Len( aRisTrat ) == 0 )

		BeginSQL Alias cAliasLau
			SELECT TO0.TO0_CODUSU
				FROM %Exp:cTblTO0% TO0
				WHERE TO0.TO0_FILIAL = %xFilial:TO0% AND
						TO0.TO0_DTINIC <= %Exp:dDtIniCond% AND
						( TO0.TO0_DTVALI >  %Exp:dDtIniCond% OR
						TO0.TO0_DTVALI = '' ) AND
						TO0.%NotDel%
		EndSQL

	Else

		//Adiciona todos os riscos na variável para utilização na query
		For nCont := 1 To Len( aRisTrat )
			
			//Caso for o último risco do array que estiver sendo processado, zera a vírgula
			If nCont == Len( aRisTrat )
				cVirgula := ""
			EndIf

			//Adiciona o risco na expressão
			cExpRis += "'" + aRisTrat[ nCont, 1 ] + "'" + cVirgula

		Next nCont

		//Finaliza a expressão com o %
		cExpRis += "%"

		//Caso não exista nenhum risco a que o funcionário está exposto
		If cExpRis == "%%"
			cExpRis := "%''%"
		EndIf

		BeginSQL Alias cAliasLau
			SELECT TO0.TO0_CODUSU
				FROM %Exp:cTblTO0% TO0
				WHERE TO0.TO0_FILIAL = %xFilial:TO0% AND
						TO0.TO0_LAUDO IN (
							SELECT TO1.TO1_LAUDO
								FROM %Exp:cTblTO1% TO1
								WHERE TO1.TO1_FILIAL = %xFilial:TO1% AND
									TO1.TO1_NUMRIS IN ( %Exp:cExpRis% ) AND
									TO1.%NotDel% ) AND
						TO0.TO0_DTINIC <= %Exp:dDtIniCond% AND
						( TO0.TO0_DTVALI >  %Exp:dDtIniCond% OR
						TO0.TO0_DTVALI = '' ) AND
						TO0.%NotDel%
		EndSQL

	EndIf

	dbSelectArea( cAliasLau )
	While ( cAliasLau )->( !EoF() )
		If ( aScan( aUsus, { | x | x[ 1 ] == ( cAliasLau )->TO0_CODUSU } ) == 0 )
			aAdd( aUsus, { ( cAliasLau )->TO0_CODUSU } )
		EndIf
		( cAliasLau )->( dbSkip() )
	End
	( cAliasLau )->( dbCloseArea() )

	dbSelectArea( "TMK" ) //Usuários
	dbSetOrder( 1 )
	( 'TMK' )->( DbGoTop() )

	For nCont := 1 To Len( aUsus )

		If dbSeek( xFilial( 'TMK' ) + aUsus[ nCont, 1 ] ) .And.;
			TMK->TMK_INDFUN $ cResTaf .And. ;
			TMK->TMK_DTINIC <= dDtIniCond .And. ;
			( TMK->TMK_DTTERM >= dDtIniCond .Or. Empty( TMK->TMK_DTTERM ) ) .And. ;
			TMK->TMK_RESAMB == '1'

			If "CRM" $ TMK->TMK_ENTCLA
				nIdeOC := "1"
			ElseIf "CREA" $ TMK->TMK_ENTCLA
				nIdeOC := "4"
			Else
				nIdeOC := "9"
			EndIf

			aAdd( aResp, { AllTrim( TMK->TMK_CODUSU ), ;
							AllTrim( TMK->TMK_NOMUSU ), ;
							TMK->TMK_CIC, ; //Informação obrigatória a ser enviada na tag <cpfResp>
							nIdeOC, ; //Informação obrigatória a ser enviada na tag <ideOC>
							AllTrim( TMK->TMK_ENTCLA ), ; //Informação a ser enviada na tag <dscOC>
							AllTrim( TMK->TMK_NUMENT ), ; //Informação obrigatória a ser enviada na tag <nrOC>
							TMK->TMK_UF } ) //Informação obrigatória a ser enviada na tag <ufOC>
		EndIf

	Next nCont

Return aResp

//---------------------------------------------------------------------
/*/{Protheus.doc} fGetEpiRis
Analisa os Requesitos do EPI eficazes:

@param cRiscoFun	Caracter Risco no qual está exposto
@param cMat			Caracter Matrícula do Funcionário
@param aInfEpi		Array Dados do Epi

Integração das condições diferenciais de trabalho, Evento S-2360

@author Guilherme Benkendorf
@since 28/02/2014
/*/
//---------------------------------------------------------------------
Static Function fGetEpiRis( cRiscoFun, cMat, aInfEpi, lIncons )

	// Contadores
	Local nFor1, nFor2, nFor3, nEpi, nOrdEPi

	// Variaveis de Tamanho de Campo
	Local nSizeCod := IIf( ( TAMSX3( "B1_COD" )[ 1 ] ) < 1, 15, ( TAMSX3( "B1_COD" )[ 1 ] ) )

	//Variaveis do TRB
	Local cAliTRB := GetNextAlias()
	Local aDBF := {}

	Local aAreaEPI := GetArea()

	// Controladores
	Local nPosi, nDiasUtilizados, nQtdeAfast
	Local nPosCAP
	Local cNumCAP

	Local dInicioRis, dFimRis, dtAval, dDtEntr
	Local dDtEficaz, dDtEfica2, dDtTNFfi2

	Local lFirst
	Local lStart, lEpiSub, lEpiAltOK
	Local lEpiEntregue := .F.

	// Parâmetros
	Local nDias := SuperGetMv( "MV_PPPDTRI", .F., "" )
	Local nLimite_Dias_Epi := 30

	Local lConsEPI := SuperGetMv( "MV_NG2CEPI", .F., "N" ) == "S"
	Local lEPIRis  := SuperGetMv( "MV_NG2EPIR", .F., "1" ) == "2"

	// Modos de Compartilhamento
	Local cModoTN0, cXFilTN0, cModoTNX, cXFilTNX, cModoTNF, cXFilTNF, cModoTN3, cXFilTN3
	Local cFilFun := xFilial( "SRA" )

	// Controle de EPI's Obrigatórios
	Local aTNFobr, aTNFfam, aTNFalt
	Local aOrdEPIs := {}

	Local cMedPrt := "N" //Define por padrão a medida de proteção igual a 'Não'
	Local cPROTEC
	Local cCndFun
	Local cUsuIni
	Local cPrzVld
	Local cPerTrc
	Local cHigien
	Local dDtReco
	Local dDtElim
	Local cNumRis
	Local cTN0CFu
	Local cTN0PVl
	Local cTN0PTr
	Local cTN0Hig
	Local lNaoEfic := .F. //Guarda se todos os EPI's são eficazes

	Default aEpiEso := {}

	// Verifica quantidade de dias
	If ValType( nDias ) == "N"
		nLimite_Dias_Epi := nDias
	ElseIf ValType( nDias ) == "C"
		nLimite_Dias_Epi := Val( nDias )
	Endif

	// Monta o TRB
	aAdd( aDBF, { "DTINI", "D", 08, 0 } )
	aAdd( aDBF, { "NUMCAP", "C", 12, 0 } )
	aAdd( aDBF, { "PROTEC", "C", 02, 0 } )
	aAdd( aDBF, { "DTREAL", "D", 08, 0 } )
	aAdd( aDBF, { "SITUAC", "C", 01, 0 } )
	aAdd( aDBF, { "DTDEVO", "D", 08, 0 } )
	aAdd( aDBF, { "CODEPI", "C", nSizeCod, 0 } )

	oTempAli := FWTemporaryTable():New( cAliTRB, aDBF )
	oTempAli:AddIndex( "1", { "DTINI", "NUMCAP", "PROTEC", "DTREAL" } )
	oTempAli:AddIndex( "2", { "SITUAC", "NUMCAP", "DTINI", "PROTEC", "DTREAL" } )
	oTempAli:Create()

	// Definições de compartilhamento do Risco
	dbselectarea( "TN0" )
	dbsetorder( 1 )
	If dbseek( xFilial( "TN0" ) + cRiscoFun )
		dDtReco := TN0->TN0_DTRECO
		dDtElim := TN0->TN0_DTELIM
		cNumRis := TN0->TN0_NUMRIS
		cTN0CFu := TN0->TN0_CONFUN
		cTN0PVl := TN0->TN0_PRZVLD
		cTN0PTr := TN0->TN0_PERTRC
		cTN0Hig := TN0->TN0_HIGIEN
	Else
		dDtReco := M->TN0_DTRECO
		dDtElim := M->TN0_DTELIM
		cNumRis := M->TN0_NUMRIS
		cTN0CFu := M->TN0_CONFUN
		cTN0PVl := M->TN0_PRZVLD
		cTN0PTr := M->TN0_PERTRC
		cTN0Hig := M->TN0_HIGIEN
	EndIf

	cModoTN0 := NGSEEKDIC( "SX2", "TN0", 1, "X2_MODOEMP + X2_MODOUN + X2_MODO" )
	cXFilTN0 := FwxFilial( "TN0", cFilFun, Substr( cModoTN0, 1, 1 ), Substr( cModoTN0, 2, 1 ), Substr( cModoTN0, 3, 1 ) )

	cModoTNX := NGSEEKDIC( "SX2", "TNX", 1, "X2_MODOEMP + X2_MODOUN + X2_MODO" )
	cXFilTNX := FwxFilial( "TNX", cFilFun, Substr( cModoTNX, 1, 1 ), Substr( cModoTNX, 2, 1 ), Substr( cModoTNX, 3, 1 ) )

	cModoTNF := NGSEEKDIC( "SX2", "TNF", 1, "X2_MODOEMP + X2_MODOUN + X2_MODO" )
	cXFilTNF := FwxFilial( "TNF", cFilFun, Substr( cModoTNF, 1, 1 ), Substr( cModoTNF, 2, 1 ), Substr( cModoTNF, 3, 1 ) )

	cModoTN3 := NGSEEKDIC( "SX2", "TN3", 1, "X2_MODOEMP + X2_MODOUN + X2_MODO" )
	cXFilTN3 := FwxFilial( "TN3", cFilFun, Substr( cModoTN3, 1, 1 ), Substr( cModoTN3, 2, 1 ), Substr( cModoTN3, 3, 1 ) )

	cModoTL0 := NGSEEKDIC( "SX2", "TL0", 1, "X2_MODOEMP + X2_MODOUN + X2_MODO" )
	cXFilTL0 := FwxFilial( "TL0", cFilFun, Substr( cModoTL0, 1, 1 ), Substr( cModoTL0, 2, 1 ), Substr( cModoTL0, 3, 1 ) )

	lStart     := .F.
	dInicioRis := dDtReco
	dFimRis    := dDataBase

	dtAval := dDtReco

	If dtAval >= dInicioRis  .And. dtAval <= dFimRis
		lStart  := .T.

		If !Empty( dDtElim ) .And. dDtElim < dFimRis
			dFimRis := dDtElim
		EndIf

		dInicioRis := dtAval
	ElseIf dtAval < dInicioRis .And. ( Empty( dDtElim ) .Or. dDtElim >= dInicioRis )
		lStart  := .T.

		If !Empty( dDtElim ) .And. dDtElim < dFimRis
			dFimRis := dDtElim
		EndIf

	EndIf

	If lStart .And. lConsEPI // Se consiste EPI

		// Apaga todos os registros do arquivo temporario onde estao os EPI's entregues
		aTNFobr := {}
		aTNFalt := {}
		aTNFfam := {}

		lFirst     := .T.

		dbSelectArea( "TNX" )
		dbSetOrder( 1 ) // TNX_FILIAL+TNX_NUMRIS+TNX_EPI
		dbSeek( cXFilTNX + cNumRis )

		While TNX->( !Eof() ) .And. cXFilTNX == TNX->TNX_FILIAL .And. cNumRis == TNX->TNX_NUMRIS

			If TNX->TNX_TIPO == "1"
				aAdd( aTNFobr, TNX->TNX_EPI )
			Else

				If (nPosi := aSCAN( aTNFfam, { |x| x == TNX->TNX_FAMIL } ) ) > 0
					aAdd( aTNFalt[ nPosi ], TNX->TNX_EPI )
				Else
					aAdd( aTNFfam, TNX->TNX_FAMIL )
					aAdd( aTNFalt, { TNX->TNX_EPI } )
				EndIf

			EndIf

			dbSelectArea( "TNX" )
			dbSkip()
		End

		// Epi esta previsto p/ funcionario
		lEpiObr := .T. // Verifica se houve utilizacao de todos os EPIs necessarios
		dDtEficaz := STOD( Space( 8 ) ) // Data inicio Eficaz dos EPIs

		If Len( aTNFobr ) > 0 .Or. Len( aTNFalt ) > 0
			cCndFun := "S"
			cUsuIni := "S"
			cPrzVld := "S"
			cPerTrc := "S"
			cHigien := "S"
		Else
			cCndFun := "N"
			cUsuIni := "N"
			cPrzVld := "N"
			cPerTrc := "N"
			cHigien := "N"
		EndIf

		For nFor1 := 1 To Len( aTNFobr )
			cCndFun := "S"
			cUsuIni := "S"
			cPrzVld := "S"
			cPerTrc := "S"
			cHigien := "S"
			aAdd( aOrdEPIs, {} )
			nPosAdd := Len( aOrdEPIs )
			dbSelectArea( "TN3" )
			dbSetOrder( 2 )
			dbSeek( xFilial( "TN3" ) + aTNFobr[nFor1] )

			While TN3->( !EoF() ) .And. TN3->TN3_FILIAL == xFilial( "TN3" ) .And. TN3->TN3_CODEPI == aTNFobr[nFor1]

				If TN3->TN3_GENERI == "2"
					//Procurar os filhos e adicionar no Array
					dbSelectArea( "TL0" )
					dbSetOrder( 1 ) //TL0_FILIAL+TL0_EPIGEN

					If dbSeek( xFilial( "TL0" ) + TN3->TN3_CODEPI )
						aAdd( aOrdEPIs[ nPosAdd ], TL0->TL0_NUMCAP )
					EndIf

				Else
					aAdd( aOrdEPIs[ nPosAdd ], TN3->TN3_NUMCAP )
				EndIf

				TN3->( dbSkip() )
			End

			dDtEfica2 := dFimRis
			lEpiSub := .F.
			dbSelectArea( "TNF" )
			dbSetOrder( 3 )  //TNF_FILIAL+TNF_MAT+TNF_CODEPI+DTOS(TNF_DTENTR)+TNF_HRENTR

			If lIncons .And. ( lMdta695 .Or. lMdta630 )

				For nFor3 := 1 To Len( aEpiEso )

					If aTNFobr[ nFor1 ] != aEpiEso[ nFor3, 1 ] // Verifica se o EPI é o EPI obrigatório em questão
						Loop
					EndIf

					If aEpiEso[ nFor3, 9 ] != cMat // Verifica se o EPI pertence ao funcionário em questão
						Loop
					EndIf

					If !Dbseek( cXFilTNF + cMat + aTNFobr[ nFor1 ] )

						lEpiEntregue := .T.

						lEpiSub	  := .T.
						lFirst	  := .F.
						dDtEfica2 := IIf( aEpiEso[ nFor3, 2 ] > dDtEfica2, dDtEfica2, aEpiEso[ nFor3, 2 ] )
						dDtEntr	  := IIf( aEpiEso[ nFor3, 2 ] < dInicioRis, dInicioRis, aEpiEso[ nFor3, 2 ] )
						cPROTEC	  := IIf( aEpiEso[ nFor3, 8 ] == "2", "N", IIf( aEpiEso[ nFor3, 8 ] == "3", "N", "S" ) )

						If ( nPosCAP := aScan( aInfEpi, { | x | x[ 2 ] == AllTrim( TNF->TNF_NUMCAP ) } ) ) == 0

							aAdd( aInfEpi, {;
								AllTrim( aEpiEso[ nFor3, 1 ] ),;
								AllTrim( aEpiEso[ nFor3, 7 ] ),; // Informação a ser enviada na tag <docAval>
								AllTrim( Posicione( "SB1", 1, xFilial("SB1") + aEpiEso[ nFor3, 1 ], "B1_DESC" ) ),; // Informação a ser enviada na tag <dscEPI> (Descontinuada)
								cPROTEC,; // Informação a ser enviada na tag <eficEpi>
								cMedPrt,; // Informação a ser enviada na tag <medProtecao>
								cCndFun,; // Informação a ser enviada na tag <condFuncto>
								cUsuIni,; // Informação a ser enviada na tag <usoInint>
								cPrzVld,; // Informação a ser enviada na tag <przValid>
								cPerTrc,; // Informação a ser enviada na tag <periodicTroca>
								cHigien; // Informação a ser enviada na tag <higienizacao>
							} )

						EndIf

					EndIf

				Next

			EndIf

			If Dbseek( cXFilTNF + cMat + aTNFobr[ nFor1 ] )

				While TNF->( !Eof() ) .And. cXFilTNF + cMat + aTNFobr[nFor1] == TNF->( TNF_FILIAL + TNF_MAT + TNF_CODEPI )

					cNumCAP := TNF->TNF_NUMCAP
					lEpiEntregue := .T.

					dbSelectArea( "TN3" )
					dbSetOrder( 1 )
					dbSeek( cXFilTN3 + TNF->TNF_FORNEC + TNF->TNF_LOJA + TNF->TNF_CODEPI + TNF->TNF_NUMCAP )

					lEpiSub	  := .T.
					lFirst	  := .F.
					dDtEfica2 := IIf( TNF->TNF_DTENTR > dDtEfica2, dDtEfica2, TNF->TNF_DTENTR )
					dDtEntr	  := IIf( TNF->TNF_DTENTR < dInicioRis, dInicioRis, TNF->TNF_DTENTR )
					cPROTEC	  := IIf( TNF->TNF_EPIEFI == "2", "N", IIf( TNF->TNF_EPIEFI == "3", "N", "S" ) )

					If ( nPosCAP := aScan( aInfEpi, { | x | x[ 2 ] == AllTrim( TNF->TNF_NUMCAP ) } ) ) == 0
						aAdd( aInfEpi, { AllTrim( TNF->TNF_CODEPI ), ;
										AllTrim( TNF->TNF_NUMCAP ), ; //Informação a ser enviada na tag <docAval>
										AllTrim( Posicione( "SB1", 1, xFilial("SB1") + TNF->TNF_CODEPI, "B1_DESC" ) ) ,; //Informação a ser enviada na tag <dscEPI> (Descontinuada)
										cPROTEC, ; //Informação a ser enviada na tag <eficEpi>
										cMedPrt, ; //Informação a ser enviada na tag <medProtecao>
										cCndFun, ; //Informação a ser enviada na tag <condFuncto>
										cUsuIni, ; //Informação a ser enviada na tag <usoInint>
										cPrzVld, ; //Informação a ser enviada na tag <przValid>
										cPerTrc, ; //Informação a ser enviada na tag <periodicTroca>
										cHigien } ) //Informação a ser enviada na tag <higienizacao>
						nPosCAP := Len( aInfEpi )
					EndIf

					dDtDevo := dFimRis

					If !Empty( TNF->TNF_DTDEVO ) .And. TNF->TNF_DTDEVO >= dInicioRis .And. TNF->TNF_DTDEVO < dFimRis
						dDtDevo := TNF->TNF_DTDEVO
					ElseIf Empty( TNF->TNF_DTDEVO )
						dbSelectArea( "TNF" )  //TNF_FILIAL+TNF_MAT+TNF_CODEPI+DTOS(TNF_DTENTR)+TNF_HRENTR
						dbSkip()

						If cXFilTNF + cMat + aTNFobr[ nFor1 ] == TNF->( TNF_FILIAL + TNF_MAT + TNF_CODEPI ) .And. TNF->( !Eof() ) .And. TNF->TNF_INDDEV != "3"

							If dDtEntr < TNF->TNF_DTENTR
								If ( TNF->TNF_DTENTR - 1 ) >= dInicioRis .And. ( TNF->TNF_DTENTR - 1 ) < dFimRis
									dDtDevo := TNF->TNF_DTENTR - 1
								Endif

							ElseIf dDtEntr == TNF->TNF_DTENTR

								If TNF->TNF_DTENTR >= dInicioRis .And. TNF->TNF_DTENTR < dFimRis
									dDtDevo := TNF->TNF_DTENTR
								EndIf
							EndIf
						EndIf
						dbSkip( -1 )
					Endif

					// Grava no TRB
					dbSelectArea( cAliTRB )
					dbSetOrder( 1 )

					If !Dbseek( DTOS( dDtEntr ) + cNumCAP + cPROTEC + DTOS( TNF->TNF_DTENTR ) )
						RecLock( cAliTRB, .T. )
						( cAliTRB )->DTINI  := dDtEntr
						( cAliTRB )->NUMCAP := cNumCAP
						( cAliTRB )->PROTEC := cPROTEC
						( cAliTRB )->DTREAL := TNF->TNF_DTENTR
						( cAliTRB )->DTDEVO := dDtDevo
						( cAliTRB )->CODEPI := TNF->TNF_CODEPI
						Msunlock( cAliTRB )
					Else

						If ( cAliTRB )->CODEPI == TNF->TNF_CODEPI .And. dDtDevo > ( cAliTRB )->DTDEVO
							RecLock( cAliTRB, .F. )
							( cAliTRB )->DTDEVO := dDtDevo
							Msunlock( cAliTRB )
						Endif

					Endif

					// Verifica se pelo menos um EPI foi entregue fora do prazo de validade
					If !( TNF->TNF_DTENTR <= TN3->TN3_DTVENC .And. dDtDevo <= TN3->TN3_DTVENC )
						cPrzVld :=  "N"
					Endif

					// Verifica se funcionario ficou afastado
					nQtdeAfast := 0

					If NGCADICBASE( "TN3_TPDURA", "A", "TN3", .F. )

						If TN3->TN3_TPDURA == "U"
							nQtdeAfast := fQtdeAfast( cFilFun, cMat, TNF->TNF_DTENTR, dDtDevo )
						Endif

					Else
						nQtdeAfast := fQtdeAfast( cFilFun, cMat, TNF->TNF_DTENTR, dDtDevo )
					Endif

					// Verifica se pelo menos um EPI foi utilizado mais do que o seu prazo de durabilidade
					nDiasUtilizados := ( dDtDevo - TNF->TNF_DTENTR ) - nQtdeAfast

					If nDiasUtilizados > TN3->TN3_DURABI
						cPerTrc := "N"
					EndIf

					// Verifica se pelo menos um EPI nao teve higienização
					If TNF->( FieldPos( "TNF_DTMANU" ) ) > 0 .And. TN3->( FieldPos( "TN3_PERMAN" ) ) > 0

						If TN3->TN3_PERMAN > 0 .And. Empty( TNF->TNF_DTMANU )
							cHigien := "N"
						EndIf

					EndIf

					// Ajusta Informações do C.A.
					If cPrzVld == "N"
						aInfEpi[ nPosCAP, 8 ] := cPrzVld //Informação a ser enviada na tag <przValid>
					EndIf

					If cPerTrc == "N"
						aInfEpi[ nPosCAP, 9 ] := cPerTrc //Informação a ser enviada na tag <periodicTroca>
					EndIf

					If cHigien == "N"
						aInfEpi[ nPosCAP, 10 ] := cHigien //Informação a ser enviada na tag <higienizacao>
					EndIf

					dbSelectArea( "TNF" )
					dbSkip()

					//--------------------------------------------------------------
					// Reinicia as variáveis de controle de informações sobre o EPI
					//--------------------------------------------------------------
					cCndFun := 'S'
					cUsuIni := 'S'
					cPrzVld := 'S'
					cPerTrc := 'S'
					cHigien := 'S'

				End

			Else
				dbSelectArea( "TN3" )
				dbSetOrder( 2 ) //TN3_FILIAL+TN3_CODEPI
				dbSeek( cXFilTN3 + aTNFobr[ nFor1 ] )

				While TN3->( !Eof() ) .And. TN3->TN3_CODEPI == aTNFobr[ nFor1 ]

					If TN3->TN3_GENERI == "2"
						dbSelectArea( "TL0" )
						dbSetOrder( 1 ) //TL0_FILIAL+TL0_EPIGEN+TL0_FORNEC+TL0_LOJA+TL0_EPIFIL
						dbSeek( cXFilTL0 + aTNFobr[ nFor1 ] )

						While TL0->( !Eof() ) .And. TL0->TL0_EPIGEN == aTNFobr[ nFor1 ]
							dbSelectArea( "TNF" )
							dbSetOrder( 3 ) //TNF_FILIAL+TNF_MAT+TNF_CODEPI+DTOS(TNF_DTENTR)+TNF_HRENTR

							If lIncons .And. ( lMdta695 .Or. lMdta630 )

								For nFor3 := 1 To Len( aEpiEso )

									If TL0->TL0_EPIFIL != aEpiEso[ nFor3, 1 ] // Verifica se o EPI é o EPI obrigatório em questão
										Loop
									EndIf

									If aEpiEso[ nFor3, 9 ] != cMat // Verifica se o EPI pertence ao funcionário em questão
										Loop
									EndIf

									If !Dbseek( cXFilTNF + cMat + TL0->TL0_EPIFIL )

										lEpiEntregue := .T.

										lEpiSub	  := .T.
										lFirst	  := .F.
										dDtEfica2 := IIf( aEpiEso[ nFor3, 2 ] > dDtEfica2, dDtEfica2, aEpiEso[ nFor3, 2 ] )
										dDtEntr	  := IIf( aEpiEso[ nFor3, 2 ] < dInicioRis, dInicioRis, aEpiEso[ nFor3, 2 ] )
										cPROTEC	  := IIf( aEpiEso[ nFor3, 8 ] == "2", "N", IIf( aEpiEso[ nFor3, 8 ] == "3", "N", "S" ) )

										If ( nPosCAP := aScan( aInfEpi, { | x | x[ 2 ] == AllTrim( TNF->TNF_NUMCAP ) } ) ) == 0

											aAdd( aInfEpi, {;
												AllTrim( aEpiEso[ nFor3, 1 ] ),;
												AllTrim( aEpiEso[ nFor3, 7 ] ),; // Informação a ser enviada na tag <docAval>
												AllTrim( Posicione( "SB1", 1, xFilial("SB1") + aEpiEso[ nFor3, 1 ], "B1_DESC" ) ),; // Informação a ser enviada na tag <dscEPI> (Descontinuada)
												cPROTEC,; // Informação a ser enviada na tag <eficEpi>
												cMedPrt,; // Informação a ser enviada na tag <medProtecao>
												cCndFun,; // Informação a ser enviada na tag <condFuncto>
												cUsuIni,; // Informação a ser enviada na tag <usoInint>
												cPrzVld,; // Informação a ser enviada na tag <przValid>
												cPerTrc,; // Informação a ser enviada na tag <periodicTroca>
												cHigien; // Informação a ser enviada na tag <higienizacao>
											} )

										EndIf

									EndIf

								Next

							EndIf

							If Dbseek( cXFilTNF + cMat + TL0->TL0_EPIFIL )

								While TNF->(!Eof()) .And. cXFilTNF + cMat + TL0->TL0_EPIFIL == TNF->( TNF_FILIAL + TNF_MAT + TNF_CODEPI )

									cNumCAP := Space( 12 )

									If TNF->TNF_INDDEV == "3" .Or. TNF->TNF_DTENTR > dFimRis
										dbSelectArea( "TNF" )
										dbSkip()
										Loop
									EndIf

									If TNF->TNF_DTDEVO < dInicioRis .And. !Empty( TNF->TNF_DTDEVO )
										dbSelectArea( "TNF" )
										dbSkip()
										Loop
									EndIf

									If TNF->TNF_INDDEV == "1" //Caso o EPI esteja com status igual a 'Devolvido'
										Dbselectarea( "TNF" )
										dbSkip()
										Loop
									EndIf

									cNumCAP := TNF->TNF_NUMCAP
									lEpiEntregue := .T.

									lEpiSub   := .T.
									lFirst    := .F.
									dDtEfica2 := IIf( TNF->TNF_DTENTR > dDtEfica2, dDtEfica2, TNF->TNF_DTENTR )
									dDtEntr   := IIf( TNF->TNF_DTENTR < dInicioRis, dInicioRis, TNF->TNF_DTENTR )
									cPROTEC	  := IIf( TNF->TNF_EPIEFI == "2", "N", IIf( TNF->TNF_EPIEFI == "3", "N", "S" ) )

									If ( nPosCAP := aScan( aInfEpi, { | x | x[ 2 ] == AllTrim( TNF->TNF_NUMCAP ) } ) ) == 0
										aAdd( aInfEpi, { AllTrim( TNF->TNF_CODEPI ), ;
														AllTrim( TNF->TNF_NUMCAP ), ; //Informação a ser enviada na tag <docAval>
														AllTrim( Posicione( "SB1", 1, xFilial( "SB1" ) + TNF->TNF_CODEPI, "B1_DESC" ) ), ; //Informação a ser enviada na tag <dscEPI> (Descontinuada)
														cPROTEC, ; //Informação a ser enviada na tag <eficEpi>
														cMedPrt, ; //Informação a ser enviada na tag <medProtecao>
														cCndFun, ; //Informação a ser enviada na tag <condFuncto>
														cUsuIni, ; //Informação a ser enviada na tag <usoInint>
														cPrzVld, ; //Informação a ser enviada na tag <przValid>
														cPerTrc, ; //Informação a ser enviada na tag <periodicTroca>
														cHigien } ) //Informação a ser enviada na tag <higienizacao>
										nPosCAP := Len( aInfEpi )
									EndIf

									dDtDevo := dFimRis

									If !Empty( TNF->TNF_DTDEVO ) .And. TNF->TNF_DTDEVO >= dInicioRis .And. TNF->TNF_DTDEVO < dFimRis
										dDtDevo := TNF->TNF_DTDEVO
									ElseIf Empty( TNF->TNF_DTDEVO )
										dbSelectArea( "TNF" )
										dbSkip()

										If cXFilTNF + cMat + TL0->TL0_EPIFIL == TNF->( TNF_FILIAL + TNF_MAT + TNF_CODEPI );
												.And. TNF->( !Eof() ) .And. TNF->TNF_INDDEV != "3"

											If dDtEntr < TNF->TNF_DTENTR

												If ( TNF->TNF_DTENTR - 1 ) >= dInicioRis .And. ( TNF->TNF_DTENTR - 1 ) < dFimRis
													dDtDevo := TNF->TNF_DTENTR - 1
												EndIf

											ElseIf dDtEntr == TNF->TNF_DTENTR

												If TNF->TNF_DTENTR >= dInicioRis .And. TNF->TNF_DTENTR < dFimRis
													dDtDevo := TNF->TNF_DTENTR
												EndIf
											EndIf
										EndIf
										dbSkip( -1 )
									EndIf

									// Grava no TRB
									dbSelectArea( cAliTRB )
									dbSetOrder( 1 )

									If !dbSeek( DTOS( dDtEntr ) + cNumCAP + cPROTEC + DTOS( TNF->TNF_DTENTR ) )
										RecLock( cAliTRB, .T. )
										( cAliTRB )->DTINI  := dDtEntr
										( cAliTRB )->NUMCAP := cNumCAP
										( cAliTRB )->PROTEC := cPROTEC
										( cAliTRB )->DTREAL := TNF->TNF_DTENTR
										( cAliTRB )->DTDEVO := dDtDevo
										( cAliTRB )->CODEPI := TNF->TNF_CODEPI
										Msunlock( cAliTRB )
									Else

										If ( cAliTRB )->CODEPI == TNF->TNF_CODEPI .And. dDtDevo > ( cAliTRB )->DTDEVO
											RecLock( cAliTRB, .F. )
											( cAliTRB )->DTDEVO := dDtDevo
											Msunlock( cAliTRB )
										Endif

									Endif

									// Verifica se pelo menos um EPI foi entregue fora do prazo de validade
									If !( TNF->TNF_DTENTR <= TN3->TN3_DTVENC .And. dDtDevo <= TN3->TN3_DTVENC )
										cPrzVld := "N"
									EndIf

									// Verifica se funcionario ficou afastado
									nQtdeAfast := 0

									If NGCADICBASE( "TN3_TPDURA", "A", "TN3", .F. )

										If NGSEEK( "TN3", TL0->TL0_FORNEC+TL0->TL0_LOJA+TL0->TL0_EPIGEN, 1, "TN3->TN3_TPDURA" ) == "U"
											nQtdeAfast := fQtdeAfast( cFilFun, cMat, TNF->TNF_DTENTR, dDtDevo )
										Endif

									Else
										nQtdeAfast := fQtdeAfast( cFilFun, cMat, TNF->TNF_DTENTR, dDtDevo )
									Endif

									// Verifica se pelo menos um EPI foi utilizado mais do que o seu prazo de durabilidade
									nDiasUtilizados := ( dDtDevo - TNF->TNF_DTENTR ) - nQtdeAfast

									If nDiasUtilizados > TN3->TN3_DURABI
										cPerTrc := "2"
									EndIf

									// Verifica se pelo menos um EPI nao teve higienização
									If TNF->( FieldPos( "TNF_DTMANU" ) ) > 0 .And. TN3->( FieldPos( "TN3_PERMAN" ) ) > 0

										If TN3->TN3_PERMAN > 0 .And. Empty( TNF->TNF_DTMANU )
											cHigien := "N"
										EndIf

									Endif

									// Ajusta Informações do C.A.
									If cPrzVld == "N"
										aInfEpi[ nPosCAP, 8 ] := cPrzVld //Informação a ser enviada na tag <przValid>
									EndIf

									If cPerTrc == "N"
										aInfEpi[ nPosCAP, 9 ] := cPerTrc //Informação a ser enviada na tag <periodicTroca>
									EndIf

									If cHigien == "N"
										aInfEpi[ nPosCAP, 10 ] := cHigien //Informação a ser enviada na tag <higienizacao>
									EndIf

									dbSelectArea( "TNF" )
									dbSkip()
								End
							EndIf
							dbSelectArea( "TL0" )
							TL0->( dbSkip() )
						End
					EndIf
					dbSelectArea( "TN3" )
					TN3->( dbSkip() )
				End
			EndIf

			If !lEpiSub
				lEpiObr := .F.
			EndIf

			If dDtEfica2 > dDtEficaz
				dDtEficaz := dDtEfica2
			Endif

		Next nFor1

		For nFor1 := 1 To Len( aTNFalt )

			lEpiAltOK := .F.
			dDtEfica2 := dFimRis

			aAdd( aOrdEPIs, {} )

			nPosAdd := Len( aOrdEPIs )

			For nFor2 := 1 To Len( aTNFalt[nFor1] )

				dbSelectArea( "TN3" )
				dbSetOrder( 2 )
				dbSeek( xFilial( "TN3" ) + aTNFalt[ nFor1, nFor2 ] )

				While TN3->( !EoF() ) .And. TN3->TN3_FILIAL == xFilial( "TN3" ) .And. TN3->TN3_CODEPI == aTNFalt[ nFor1, nFor2 ]

					If TN3->TN3_GENERI == "2"
						//Procurar os filhos e adicionar no Array
						dbSelectArea( "TL0" )
						dbSetOrder( 1 ) // TL0_FILIAL + TL0_EPIGEN
						If dbSeek( xFilial( "TL0" ) + TN3->TN3_CODEPI )
							aAdd( aOrdEPIs[ nPosAdd ], TL0->TL0_NUMCAP )
						EndIf
					Else
						aAdd( aOrdEPIs[ nPosAdd ], TN3->TN3_NUMCAP )
					EndIf

					TN3->( dbSkip() )
				End

				dbSelectArea( "TNF" )
				dbSetOrder( 3 ) //TNF_FILIAL+TNF_MAT+TNF_CODEPI+DTOS(TNF_DTENTR)+TNF_HRENTR

				If lIncons .And. ( lMdta695 .Or. lMdta630 )

					For nFor3 := 1 To Len( aEpiEso )

						If aTNFalt[ nFor1, nFor2 ] != aEpiEso[ nFor3, 1 ] // Verifica se o EPI é o EPI obrigatório em questão
							Loop
						EndIf

						If aEpiEso[ nFor3, 9 ] != cMat // Verifica se o EPI pertence ao funcionário em questão
							Loop
						EndIf

						If !Dbseek( cXFilTNF + cMat + aTNFalt[ nFor1, nFor2 ] )

							lEpiEntregue := .T.

							lEpiSub	  := .T.
							lFirst	  := .F.
							dDtEfica2 := IIf( aEpiEso[ nFor3, 2 ] > dDtEfica2, dDtEfica2, aEpiEso[ nFor3, 2 ] )
							dDtEntr	  := IIf( aEpiEso[ nFor3, 2 ] < dInicioRis, dInicioRis, aEpiEso[ nFor3, 2 ] )
							cPROTEC	  := IIf( aEpiEso[ nFor3, 8 ] == "2", "N", IIf( aEpiEso[ nFor3, 8 ] == "3", "N", "S" ) )

							If ( nPosCAP := aScan( aInfEpi, { | x | x[ 2 ] == AllTrim( TNF->TNF_NUMCAP ) } ) ) == 0

								aAdd( aInfEpi, {;
									AllTrim( aEpiEso[ nFor3, 1 ] ),;
									AllTrim( aEpiEso[ nFor3, 7 ] ),; // Informação a ser enviada na tag <docAval>
									AllTrim( Posicione( "SB1", 1, xFilial("SB1") + aEpiEso[ nFor3, 1 ], "B1_DESC" ) ),; // Informação a ser enviada na tag <dscEPI> (Descontinuada)
									cPROTEC,; // Informação a ser enviada na tag <eficEpi>
									cMedPrt,; // Informação a ser enviada na tag <medProtecao>
									cCndFun,; // Informação a ser enviada na tag <condFuncto>
									cUsuIni,; // Informação a ser enviada na tag <usoInint>
									cPrzVld,; // Informação a ser enviada na tag <przValid>
									cPerTrc,; // Informação a ser enviada na tag <periodicTroca>
									cHigien; // Informação a ser enviada na tag <higienizacao>
								} )

							EndIf

						EndIf

					Next

				EndIf

				If Dbseek( cXFilTNF + cMat + aTNFalt[ nFor1, nFor2 ] )

					While TNF->( !Eof() ) .And. cXFilTNF + cMat + aTNFalt[ nFor1, nFor2 ] == TNF->( TNF_FILIAL + TNF_MAT + TNF_CODEPI )

						cNumCAP := Space( 12 )

						If TNF->TNF_INDDEV == "3" .Or. TNF->TNF_DTENTR > dFimRis
							Dbselectarea( "TNF" )
							Dbskip()
							Loop
						EndIf

						If TNF->TNF_DTDEVO < dInicioRis .And. !Empty( TNF->TNF_DTDEVO )
							Dbselectarea( "TNF" )
							Dbskip()
							Loop
						EndIf

						If TNF->TNF_INDDEV == "1" //Caso o EPI esteja com status igual a 'Devolvido'
							Dbselectarea( "TNF" )
							dbSkip()
							Loop
						EndIf

						cNumCAP := TNF->TNF_NUMCAP
						lEpiEntregue := .T.

						dbSelectArea( "TN3" )
						dbSetOrder( 1 ) //TN3_FILIAL+TN3_FORNEC+TN3_LOJA+TN3_CODEPI+TN3_NUMCAP
						dbSeek( xFilial( "TN3", cFilFun ) + TNF->TNF_FORNEC + TNF->TNF_LOJA + TNF->TNF_CODEPI + TNF->TNF_NUMCAP )

						lEpiAltOK := .T.
						lFirst    := .F.
						dDtEfica2 := IIf( TNF->TNF_DTENTR > dDtEfica2, dDtEfica2, TNF->TNF_DTENTR )
						dDtEntr   := IIf( TNF->TNF_DTENTR < dInicioRis, dInicioRis, TNF->TNF_DTENTR )
						cPROTEC	  := IIf( TNF->TNF_EPIEFI == "2", "N", IIf( TNF->TNF_EPIEFI == "3", "N", "S" ) )

						If ( nPosCAP := aScan( aInfEpi, { | x | x[ 2 ] == AllTrim( TNF->TNF_NUMCAP ) } ) ) == 0
							aAdd( aInfEpi, { AllTrim( TNF->TNF_CODEPI ), ;
											AllTrim( TNF->TNF_NUMCAP ), ; //Informação a ser enviada na tag <docAval>
											AllTrim( Posicione( "SB1", 1, xFilial( "SB1" ) + TNF->TNF_CODEPI, "B1_DESC" ) ), ; //Informação a ser enviada na tag <dscEPI> (Descontinuada)
											cPROTEC, ; //Informação a ser enviada na tag <eficEpi>
											cMedPrt, ; //Informação a ser enviada na tag <medProtecao>
											cCndFun, ; //Informação a ser enviada na tag <condFuncto>
											cUsuIni, ; //Informação a ser enviada na tag <usoInint>
											cPrzVld, ; //Informação a ser enviada na tag <przValid>
											cPerTrc, ; //Informação a ser enviada na tag <periodicTroca>
											cHigien } ) //Informação a ser enviada na tag <higienizacao>
							nPosCAP := Len( aInfEpi )
						EndIf

						dDtDevo := dFimRis

						If !Empty( TNF->TNF_DTDEVO ) .And. TNF->TNF_DTDEVO >= dInicioRis .And. TNF->TNF_DTDEVO < dFimRis
							dDtDevo := TNF->TNF_DTDEVO
						ElseIf Empty( TNF->TNF_DTDEVO )
							dbSelectArea( "TNF" )
							dbSkip()

							If cXFilTNF + cMat + aTNFalt[ nFor1, nFor2 ] == TNF->( TNF_FILIAL + TNF_MAT + TNF_CODEPI );
								.And. TNF->( Eof() ) .And. TNF->TNF_INDDEV != "3"

								If dDtEntr < TNF->TNF_DTENTR

									If ( TNF->TNF_DTENTR - 1 ) >= dInicioRis .And. ( TNF->TNF_DTENTR - 1 ) < dFimRis
										dDtDevo := TNF->TNF_DTENTR - 1
									Endif

								ElseIf dDtEntr == TNF->TNF_DTENTR

									If TNF->TNF_DTENTR >= dInicioRis .And. TNF->TNF_DTENTR < dFimRis
										dDtDevo := TNF->TNF_DTENTR
									EndIf
								EndIf
							EndIf
							dbSkip( -1 )
						Endif

						// Grava no TRB
						dbSelectArea( cAliTRB )
						dbSetOrder( 1 )

						If !dbSeek( DTOS( dDtEntr ) + cNumCAP + cPROTEC + DTOS( TNF->TNF_DTENTR ) )
							RecLock( cAliTRB, .T. )
							( cAliTRB )->DTINI  := dDtEntr
							( cAliTRB )->NUMCAP := cNumCAP
							( cAliTRB )->PROTEC := cPROTEC
							( cAliTRB )->DTREAL := TNF->TNF_DTENTR
							( cAliTRB )->DTDEVO := dDtDevo
							( cAliTRB )->CODEPI := TNF->TNF_CODEPI
							Msunlock( cAliTRB )
						Else

							If ( cAliTRB )->CODEPI == TNF->TNF_CODEPI .And. dDtDevo > ( cAliTRB )->DTDEVO
								RecLock( cAliTRB, .F. )
								( cAliTRB )->DTDEVO := dDtDevo
								Msunlock( cAliTRB )
							Endif

						Endif

						// Verifica se pelo menos um EPI foi entregue fora do prazo de validade
						If !( TNF->TNF_DTENTR <= TN3->TN3_DTVENC .And. dDtDevo <= TN3->TN3_DTVENC )
							cPrzVld := "N"
						EndIf

						// Verifica se funcionario ficou afastado
						nQtdeAfast := 0

						If NGCADICBASE( "TN3_TPDURA", "A", "TN3", .F. )

							If TN3->TN3_TPDURA == "U"
								nQtdeAfast := fQtdeAfast( cFilFun, cMat, TNF->TNF_DTENTR, dDtDevo )
							Endif

						Else
							nQtdeAfast := fQtdeAfast( cFilFun, cMat, TNF->TNF_DTENTR, dDtDevo )
						Endif

						// Verifica se pelo menos um EPI foi utilizado mais do que o seu prazo de durabilidade
						nDiasUtilizados := ( dDtDevo - TNF->TNF_DTENTR ) - nQtdeAfast

						If nDiasUtilizados > TN3->TN3_DURABI
							cPerTrc := "N"
						EndIf

						// Verifica se pelo menos um EPI nao teve higienização
						If TNF->( FieldPos( "TNF_DTMANU" ) ) > 0 .And. TN3->( FieldPos( "TN3_PERMAN" ) ) > 0

							If TN3->TN3_PERMAN > 0 .And. Empty( TNF->TNF_DTMANU )
								cHigien := "N"
							EndIf

						EndIf

						//Ajusta Informações do C.A.
						If cPrzVld == "N"
							aInfEpi[ nPosCAP, 8 ] := cPrzVld //Informação a ser enviada na tag <przValid>
						EndIf

						If cPerTrc == "N"
							aInfEpi[ nPosCAP, 9 ] := cPerTrc //Informação a ser enviada na tag <periodicTroca>
						EndIf

						If cHigien == "N"
							aInfEpi[ nPosCAP, 10 ] := cHigien //Informação a ser enviada na tag <higienizacao>
						EndIf

						dbSelectArea( "TNF" )
						dbSkip()
					End

				Else
					dbSelectArea( "TN3" )
					dbSetOrder( 2 ) //TN3_FILIAL+TN3_CODEPI
					dbSeek( cXFilTN3 + aTNFalt[ nFor1, nFor2 ] )

					While TN3->( !Eof() ) .And. TN3->TN3_CODEPI == aTNFalt[ nFor1, nFor2 ]

						If TN3->TN3_GENERI == "2"
							dbSelectArea( "TL0" )
							dbSetOrder( 1 ) //TL0_FILIAL+TL0_EPIGEN+TL0_FORNEC+TL0_LOJA+TL0_EPIFIL
							dbSeek( cXFilTL0 + aTNFalt[ nFor1, nFor2 ] )

							While TL0->( !Eof() ) .And. TL0->TL0_EPIGEN == aTNFalt[ nFor1, nFor2 ]
								dbSelectArea( "TNF" )
								dbSetOrder( 3 ) //TNF_FILIAL+TNF_MAT+TNF_CODEPI+DTOS(TNF_DTENTR)+TNF_HRENTR

								If Dbseek( cXFilTNF + cMat + TL0->TL0_EPIFIL )
									While TNF->(!Eof()) .And. cXFilTNF + cMat + TL0->TL0_EPIFIL == TNF->(TNF_FILIAL + TNF_MAT + TNF_CODEPI)

										cNumCAP := Space( 12 )

										If TNF->TNF_INDDEV == "3" .Or. TNF->TNF_DTENTR > dFimRis
											Dbselectarea( "TNF" )
											Dbskip()
											Loop
										Endif

										If TNF->TNF_DTDEVO < dInicioRis .And. !Empty( TNF->TNF_DTDEVO )
											Dbselectarea( "TNF" )
											Dbskip()
											Loop
										Endif

										If TNF->TNF_INDDEV == "1" //Caso o EPI esteja com status igual a 'Devolvido'
											Dbselectarea( "TNF" )
											dbSkip()
											Loop
										EndIf

										cNumCAP := TNF->TNF_NUMCAP
										lEpiEntregue := .T.

										lEpiAltOK := .T.
										lFirst    := .F.
										dDtEfica2 := IIf( TNF->TNF_DTENTR > dDtEfica2, dDtEfica2, TNF->TNF_DTENTR )
										dDtEntr   := IIf( TNF->TNF_DTENTR < dInicioRis, dInicioRis, TNF->TNF_DTENTR )
										cPROTEC	  := IIf( TNF->TNF_EPIEFI == "2", "N", IIf( TNF->TNF_EPIEFI == "3", "N", "S" ) )

										If ( nPosCAP := aScan( aInfEpi, { | x | x[ 2 ] == AllTrim( TNF->TNF_NUMCAP ) } ) ) == 0
											aAdd( aInfEpi, { AllTrim( TNF->TNF_CODEPI ), ;
															AllTrim( TNF->TNF_NUMCAP ), ; //Informação a ser enviada na tag <docAval>
															AllTrim( Posicione( "SB1", 1, xFilial( "SB1" ) + TNF->TNF_CODEPI, "B1_DESC" ) ), ; //Informação a ser enviada na tag <dscEPI> (Descontinuada)
															cPROTEC, ; //Informação a ser enviada na tag <eficEpi>
															cMedPrt, ; //Informação a ser enviada na tag <medProtecao>
															cCndFun, ; //Informação a ser enviada na tag <condFuncto>
															cUsuIni, ; //Informação a ser enviada na tag <usoInint>
															cPrzVld, ; //Informação a ser enviada na tag <przValid>
															cPerTrc, ; //Informação a ser enviada na tag <periodicTroca>
															cHigien } ) //Informação a ser enviada na tag <higienizacao>
											nPosCAP := Len( aInfEpi )
										EndIf

										dDtDevo := dFimRis

										If !Empty( TNF->TNF_DTDEVO ) .And. TNF->TNF_DTDEVO >= dInicioRis .And. TNF->TNF_DTDEVO < dFimRis
											dDtDevo := TNF->TNF_DTDEVO
										Elseif Empty( TNF->TNF_DTDEVO )
											dbSelectArea( "TNF" )
											dbSkip()

											If cXFilTNF + cMat + TL0->TL0_EPIFIL == TNF->( TNF_FILIAL + TNF_MAT + TNF_CODEPI );
													.And. TNF->( !Eof() ) .And. TNF->TNF_INDDEV != "3"

												If dDtEntr < TNF->TNF_DTENTR

													If ( TNF->TNF_DTENTR - 1 ) >= dInicioRis .And. ( TNF->TNF_DTENTR - 1 ) < dFimRis
														dDtDevo := TNF->TNF_DTENTR - 1
													Endif

												ElseIf dDtEntr == TNF->TNF_DTENTR

													If TNF->TNF_DTENTR >= dInicioRis .And. TNF->TNF_DTENTR < dFimRis
														dDtDevo := TNF->TNF_DTENTR
													EndIf
												EndIf
											EndIf
											dbSkip( -1 )
										Endif

										//Grava no TRB
										dbSelectArea( cAliTRB )
										dbSetOrder( 1 )

										If !Dbseek( DTOS( dDtEntr ) + cNumCAP + cPROTEC + DTOS( TNF->TNF_DTENTR ) )
											RecLock( cAliTRB, .T. )
											( cAliTRB )->DTINI  := dDtEntr
											( cAliTRB )->NUMCAP := cNumCAP
											( cAliTRB )->PROTEC := cPROTEC
											( cAliTRB )->DTREAL := TNF->TNF_DTENTR
											( cAliTRB )->DTDEVO := dDtDevo
											( cAliTRB )->CODEPI := TNF->TNF_CODEPI
											Msunlock( cAliTRB )
										Else

											If ( cAliTRB )->CODEPI == TNF->TNF_CODEPI .And. dDtDevo > ( cAliTRB )->DTDEVO
												RecLock( cAliTRB, .F. )
												( cAliTRB )->DTDEVO := dDtDevo
												Msunlock( cAliTRB )
											Endif

										Endif

										// Verifica se pelo menos um EPI foi entregue fora do prazo de validade
										If !( TNF->TNF_DTENTR <= TN3->TN3_DTVENC .And. dDtDevo <= TN3->TN3_DTVENC )
											cPrzVld := "N"
										EndIf

										// Verifica se funcionario ficou afastado
										nQtdeAfast := 0

										If NGCADICBASE( "TN3_TPDURA", "A", "TN3", .F. )

											If NGSEEK( "TN3", TL0->TL0_FORNEC + TL0->TL0_LOJA + TL0->TL0_EPIGEN, 1, "TN3->TN3_TPDURA" ) == "U"
												nQtdeAfast := fQtdeAfast( cFilFun, cMat, TNF->TNF_DTENTR, dDtDevo )
											Endif

										Else
											nQtdeAfast := fQtdeAfast( cFilFun, cMat, TNF->TNF_DTENTR, dDtDevo )
										Endif

										// Verifica se pelo menos um EPI foi utilizado mais do que o seu prazo de durabilidade
										nDiasUtilizados := ( dDtDevo - TNF->TNF_DTENTR ) - nQtdeAfast

										If nDiasUtilizados > TN3->TN3_DURABI
											cPerTrc := "N"
										EndIf

										// Verifica se pelo menos um EPI nao teve higienização
										If TNF->( FieldPos( "TNF_DTMANU" ) ) > 0 .And. TN3->( FieldPos( "TN3_PERMAN" ) ) > 0

											If TN3->TN3_PERMAN > 0 .And. Empty( TNF->TNF_DTMANU )
												cHigien := "N"
											EndIf

										EndIf

										// Ajusta Informações do C.A.
										If cPrzVld == "N"
											aInfEpi[ nPosCAP, 8 ] := cPrzVld //Informação a ser enviada na tag <przValid>
										EndIf

										If cPerTrc == "N"
											aInfEpi[ nPosCAP, 9 ] := cPerTrc //Informação a ser enviada na tag <periodicTroca>
										EndIf

										If cHigien == "N"
											aInfEpi[ nPosCAP, 10 ] := cHigien //Informação a ser enviada na tag <higienizacao>
										EndIf

										dbSelectArea( "TNF" )
										TNF->( dbSkip() )
									End
								EndIf
								dbSelectArea( "TL0" )
								TL0->( dbSkip() )
							End
						EndIf
						dbSelectArea( "TN3" )
						TN3->( dbSkip() )
					End
				EndIf

			Next nFor2

			If dDtEfica2 > dDtEficaz
				dDtEficaz := dDtEfica2
			Endif

			If !lEpiAltOK
				lEpiObr := .F.
			Endif

		Next nFor1

		For nOrdEPi := 1 To Len( aOrdEPIs ) // Verificar

			dDtEficaz := IIf( dInicioRis + nLimite_Dias_Epi >= dDtEficaz, dInicioRis, dDtEficaz )

			// Cria historico de epi's entregues
			If !lFirst  //Epi esta previsto p/ funcionario e foi entregue

				If dDtEficaz != dInicioRis
					cCndFun := "N"
					cUsuIni := "N"
				Endif

				If cCndFun == "S"
					fAjustaData( dInicioRis, cAliTRB )
					dbSelectArea( cAliTRB )
					dbSetOrder( 1 )

					// Filtrar o TRB conforme os EPIs do Array
					If dbSeek( xFilial( cAliTRB ) + aOrdEPIs[ nOrdEPi, 1 ] )
						dbGoTop()
						dDtTNFfi2 := ( cAliTRB )->DTDEVO

						While ( cAliTRB )->( !Eof() )
							dDtTNFini := ( cAliTRB )->DTINI

							If ( cAliTRB )->DTDEVO > dDtTNFfi2
								dDtTNFfi2 := ( cAliTRB )->DTDEVO
							Endif

							dbSkip()
							If !Eof()
								If ( cAliTRB )->DTINI > dDtTNFfi2 + nLimite_Dias_Epi .And. ( dDtTNFfi2 + 1 ) <= ( ( cAliTRB )->DTINI - 1 )
									cCndFun		:= "N"
									cUsuIni		:= "N"
									dDtTNFfi2	:= ( cAliTRB )->DTDEVO
									Exit
								EndIf
							Else
								If dFimRis > dDtTNFfi2 + nLimite_Dias_Epi
									cCndFun := "N"
									cUsuIni := "N"
									Exit
								EndIf
							EndIf
						End

						If cCndFun <> "S"
							dbSelectArea( cAliTRB )
							dbSetOrder( 2 )
							dbSeek( " " )

							While ( cAliTRB )->( !Eof() ) .And. ( cAliTRB )->SITUAC == " "

								If lEpiObr
									If AllTrim( ( cAliTRB )->PROTEC ) == "N"
										cCndFun := "N"
										cUsuIni := "N"
										Exit
									Endif
								Else
									cCndFun := "N"
									cUsuIni := "N"
									Exit
								Endif

								dbSelectArea( cAliTRB )
								dbSkip()
							End
						EndIf
					EndIf
				EndIf
			EndIf // Fim - Tem EPI previsto
		Next nOrdEPi
	EndIf //Fim - Consiste EPI

	If !lEpiEntregue
		cCndFun := "N"
		cUsuIni := "N"
		cPrzVld := "N"
		cPerTrc := "N"
		cHigien := "N"
	EndIf

	//------------------------------------------
	// Percorre os EPI's verificando a eficácia
	//------------------------------------------
	For nEpi := 1 To Len( aInfEpi )
		If aInfEpi[ nEpi, 4 ] == "N"
			lNaoEfic := .T.
			Exit
		EndIf
	Next nEpi

	If lNaoEfic //Caso algum EPI entregue não seja eficaz, define todos como não eficazes
		For nEpi := 1 To Len( aInfEpi )
			aInfEpi[ nEpi, 4 ] := "N"
		Next nEpi
	EndIf

	//------------------------------------------------------------------------------------------------
	// Atualiza o envio da tag <medProtecao> de acordo com as medidas de controle vinculadas ao risco
	//------------------------------------------------------------------------------------------------
	dbSelectArea( "TJF" )
	dbSetOrder( 1 )
	If dbSeek( xFilial( "TJF" ) + cNumRis )
		While TJF->( !Eof() ) .And. TJF->TJF_FILIAL == xFilial( "TJF" ) .And. TJF->TJF_NUMRIS == cNumRis
			If Posicione( "TO4", 1, xFilial( "TO4" ) + TJF->TJF_MEDCON, "TO4_TIPCTR" ) == "2" .Or.;
			Posicione( "TO4", 1, xFilial( "TO4" ) + TJF->TJF_MEDCON, "TO4_TIPCTR" ) == "4"
				cMedPrt := "S"
				Exit
			EndIf
			TJF->( dbSkip() )
		End
	EndIf

	For nEpi := 1 To Len( aInfEpi )
		If  aInfEpi[ nEpi, 6 ] == "S" .And. aInfEpi[ nEpi, 8 ] == "S" .And. aInfEpi[ nEpi, 9 ] == "S"
			cMedPrt := "S"
			Exit
		EndIf
	Next nEpi
	
	//Caso exista medida de proteção
	If cMedPrt == "S"
		//Percorre o array alterando
		For nEpi := 1 To Len( aInfEpi )
			aInfEpi[ nEpi, 5 ] := cMedPrt //Informação a ser enviada na tag <medProtecao>
		Next nEpi
	EndIf

	//Caso as informações complementares do EPI forem buscadas do cadastro de risco
	If lEPIRis
		For nEpi := 1 To Len( aInfEpi ) //Percorre o array ajustando com as informações do risco
			aInfEpi[ nEpi, 6 ] := IIf( cTN0CFu == "1", "S", "N" ) //Informação a ser enviada na tag <condFuncto>
			aInfEpi[ nEpi, 7 ] := IIf( cTN0CFu == "1", "S", "N" ) //Informação a ser enviada na tag <usoInint>
			aInfEpi[ nEpi, 8 ] := IIf( cTN0PVl == "1", "S", "N" ) //Informação a ser enviada na tag <przValid>
			aInfEpi[ nEpi, 9 ] := IIf( cTN0PTr == "1", "S", "N" ) //Informação a ser enviada na tag <periodicTroca>
			aInfEpi[ nEpi, 10 ] := IIf( cTN0Hig == "1", "S", "N" ) //Informação a ser enviada na tag <higienizacao>
		Next nEpi
	EndIf

	//Deleta a tabela temporária
	If Select( cAliTRB ) > 0
		oTempAli:Delete()
	EndIf

	//Retorna a área
	RestArea( aAreaEPI )

Return .T.

//---------------------------------------------------------------------
/*/{Protheus.doc} fAjustaData
Função replicada de MDTR700, Ajusta os Epis entregues em outra funcao/setor

@param dInicio Data Indica a data de início de exposição ao risco.
@param cAliTRB Caracter Alias do TRB

@author Jackson Machado
@since 06/03/2014
/*/
//---------------------------------------------------------------------
Static Function fAjustaData( dInicio , cAliTRB )

Local aRecnos := {}
Local nFor

dbSelectArea( cAliTRB )
dbSetOrder(1)
dbSeek(DTOS(dInicio))
While !Eof() .And. dInicio == ( cAliTRB )->DTINI

	cSvCA     := ( cAliTRB )->NUMCAP
	dDtIniTRB := ( cAliTRB )->DTREAL
	nRecnoTRB := ( cAliTRB )->(Recno())
	lFirstTRB := .T.

	While !Eof() .and. dInicio == ( cAliTRB )->DTINI .And. cSvCA == ( cAliTRB )->NUMCAP
		If !lFirstTRB .and. ( cAliTRB )->DTREAL > dDtIniTRB
			dDtIniTRB := ( cAliTRB )->DTREAL
			nRecnoTRB := ( cAliTRB )->( Recno() )
		Endif

		RecLock( cAliTRB , .F. )
		( cAliTRB )->SITUAC := "S"
		MsUnLock( cAliTRB )

		lFirstTRB := .F.

		dbSelectArea( cAliTRB )
		dbSkip()
	End

	aAdd( aRecnos , nRecnoTRB )
End

For nFor := 1 to Len( aRecnos )
	dbSelectArea( cAliTRB )
	dbGoTo( aRecnos[ nFor ] )
	If ( cAliTRB )->( !Eof() ) .and. ( cAliTRB )->( !Bof() )
		RecLock( cAliTRB , .F. )
		( cAliTRB )->SITUAC := " "
		MsUnLock( cAliTRB )
	Endif
Next nFor

Return

//---------------------------------------------------------------------
/*/{Protheus.doc} fQtdeAfast
Função replicada de MDTR700, Verifica se houve afastamento e retorna a
quantidade de dias.

@param cFilFun   Caracter Indica a filial do funcionario.
@param cMatric   Caracter Indica o código da matricula do funcionario.
@param _dtIniRis Data Indica a data de inicio do risco
@param _dtFimRis Data Indica a data de termino do risco

@author Guilherme Benkendorf
@since 05/03/2014
/*/
//---------------------------------------------------------------------
Static Function fQtdeAfast( cFilFun , cMatric , _dtIniRis , _dtFimRis )

Local nPos, nX, nCont := 0
Local nDias   := 0
Local nVetID  := 0
Local dTmpSR8 := StoD("")
Local dIniAfa := StoD("")
Local dFimAfa := StoD("")
Local cModoSR8, cXFilSR8
Local aAfasta := {}
Local lMudou := .F.

cModoSR8 := NGSEEKDIC( "SX2", "SR8", 1, "X2_MODOEMP+X2_MODOUN+X2_MODO" )
cXFilSR8 := FwxFilial( "SR8", cFilFun, Substr(cModoSR8,1,1), Substr(cModoSR8,2,1), Substr(cModoSR8,3,1) )

dbSelectArea( "SR8" )
dbSetOrder( 1 ) //R8_FILIAL+R8_MAT+DTOS(R8_DATAINI)+R8_TIPO
dbSeek( cXFilSR8 + cMatric )
While SR8->( !Eof() ) .And. SR8->R8_FILIAL + SR8->R8_MAT == cXFilSR8 + cMatric

	dTmpSR8 := If( Empty( SR8->R8_DATAFIM ) , _dtFimRis , SR8->R8_DATAFIM )

	If SR8->R8_DATAINI <= _dtFimRis .And. dTmpSR8 >= _dtIniRis .And. !Empty(SR8->R8_DATAINI)

		dIniAfa := If( SR8->R8_DATAINI < _dtIniRis , _dtIniRis , SR8->R8_DATAINI )
		dFimAfa := If( dTmpSR8 > _dtFimRis , _dtFimRis , dTmpSR8 )
		nVetID++
		aAdd( aAfasta , { dIniAfa , dFimAfa , .T. , nVetID } )

	Endif
	dbSelectArea("SR8")
	dbSkip()
End

While nCont < 1000
	nCont++
	lMudou := .F.
	For nX := 1 To Len( aAfasta )
		If aAfasta[ nX , 3 ]
			nPos := aSCAN( aAfasta , { |x| x[1] <= aAfasta[ nX , 2 ] .And. x[ 2 ] >= aAfasta[ nX , 1 ] .And. nX <> x[ 4 ] .And. x[ 3 ] } )
			If nPos > 0
				aAfasta[ nX , 1 ] := If( aAfasta[ nX , 1 ] > aAfasta[ nPos , 1 ] , aAfasta[ nPos , 1 ] , aAfasta[ nX , 1 ] )
				aAfasta[ nX , 2 ] := If( aAfasta[ nX , 2 ] < aAfasta[ nPos , 2 ] , aAfasta[ nPos , 2 ] , aAfasta[ nX , 2 ] )
				aAfasta[ nPos,3 ] := .T.
				lMudou := .T.
			Endif
		Endif
	Next nX

	If !lMudou
		Exit
	Endif
End
For nX := 1 To Len( aAfasta )
	If aAfasta[ nX , 3 ]
		nDias += ( aAfasta[ nX , 2 ] - aAfasta[ nX , 1 ] ) + 1
	Endif
Next nX

Return nDias

//---------------------------------------------------------------------
/*/{Protheus.doc} fGetTpAval
Busca o tipo de avaliação do agente de acordo com o parâmetro MV_NG2TPAG

@return cTpAval, Caracter, Tipo de avaliação do agente

@sample fGetTpAval( "01.01.001", 23 )

@param cAgente, Caracter, Indica o código do agente do risco
@param nQtAgen, Numérico, Indica a quantidade de agente no risco

@author Luis Fellipy Bett
@since 05/10/2021
/*/
//---------------------------------------------------------------------
Static Function fGetTpAval( cAgente, nQtAgen )

	Local aArea := GetArea() //Salva a área
	Local cTpAgen := SuperGetMv( "MV_NG2TPAG", .F., "1" ) //Verifica por onde o tipo do agente será buscado
	Local cTpAval := ""
	
	If cTpAgen == "1" //Caso o tipo do agente for buscado do cadastro de agentes
		cTpAval := Posicione( "TMA", 1, xFilial( "TMA" ) + cAgente, "TMA_AVALIA" )
	ElseIf cTpAgen == "2" //Caso o tipo do agente for buscado do cadastro de riscos
		cTpAval := IIf( nQtAgen > 0, "1", "2" )
	EndIf

	RestArea( aArea ) //Retorna a área

Return cTpAval

//---------------------------------------------------------------------
/*/{Protheus.doc} fVerMatEso
Indica se o último evento S-2300 do funcionário possuí matrícula
do eSocial cadastrada

@author Gabriel Sokacheski
@since 25/07/2023

@param cCpfFun, cpf do funcionário
@param cMatEso, matrícula eSocial para filtro

@return lTemMatEso, indica se o último evento S-2300 possui
matrícula do eSocial cadastrada
/*/
//---------------------------------------------------------------------
Static Function fVerMatEso( cCpfFun, cMatEso )

	Local aAreaC9V := ( 'C9V' )->( GetArea() )

	Local lTemMatEso := .F.

	DbSelectArea( 'C9V' )
	DBSetOrder( 20 )

	If !Empty( cMatEso ) .And. ( 'C9V' )->( DbSeek( xFilial( 'C9V' ) + cCpfFun + cMatEso + 'S2300' ) )
		lTemMatEso := .T.
	EndIf

	RestArea( aAreaC9V )

Return lTemMatEso

//---------------------------------------------------------------------
/*/{Protheus.doc} fMatMid
Caso for ambiente Middleware verifica se o evento S-2300 do 
funcionário possuí matrícula cadastrada na RJE

@author Eloisa Anibaletto
@since 15/09/2023

@param cMatMid, matrícula do funcionário 

@return lTemMatMid, retorna verdadeiro se existir o evento
/*/
//---------------------------------------------------------------------
Static Function fMatMid( cMatMid )

	Local lTemMatMid := .F.

	If lMiddleware

		DbSelectArea( 'RJE' )
		DBSetOrder( 4 )

		If !Empty( cMatMid ) .And. ( 'RJE' )->( DbSeek( "S2300" + cMatMid ) )
			lTemMatEso := .T.
		EndIf

	EndIf

Return lTemMatMid
