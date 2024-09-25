#INCLUDE "Protheus.ch"
#INCLUDE "MDTESOCIAL.CH"

//---------------------------------------------------------------------
/*/{Protheus.doc} MDTESOCIAL
Fonte com as funções genéricas usadas nos eventos de integração do SIGAMDT com o eSocial

@author Luis Fellipy Bett
@since 16/07/2018
/*/
//---------------------------------------------------------------------

//---------------------------------------------------------------------
/*/{Protheus.doc} MDTVldEsoc
Função genérica que valida as condições para realizar a integração com o eSocial

@author  Luis Fellipy Bett
@since   09/11/2020

@return lRet, Lógico, Retorna verdadeiro caso exista integração
/*/
//---------------------------------------------------------------------
Function MDTVldEsoc()

	Local lRet := ( cPaisLoc == 'BRA' .And. SuperGetMv( "MV_NG2ESOC", .F., "2" ) == "1" )

Return lRet

//---------------------------------------------------------------------
/*/{Protheus.doc} MDTIntEsoc
Função genérica que realiza validações e inicia o envio dos eventos ao Governo

@sample	MDTIntEsoc( "S-2210", 3, "0000001", {}, .T., oModel1, oModel2, @cMsgInc )

@param	cEvento, Caracter, Indica o evento que está sendo enviado
@param	nOper, Numérico, Indica a operação que está sendo realizada (3-Inclusão/4-Alteração/5-Exclusão)
@param	xFicMed, Caracter/Array, Indica a ficha médica do funcionário do Acidente ou do ASO (Utilizada apenas pelo S-2210 e S-2220)
@param	aFuncs, Array, Array contendo os funcionários que terão as informações validadas/enviadas (Utilizada apenas pelo S-2240)
	1ª posição - Matrícula do funcionário
	2ª posição - Filial do funcionário
	3ª posição - Número do risco
	4ª posição - Código da tarefa do funcionário
	5ª posição - Data início da tarefa do funcionário
	6ª posição - Data fim da tarefa do funcionário
	7ª posição - Array com as informações da transferência (utilizado apenas pelo GPEA180)
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
	8ª posição - Array com as informações dos EPIs entregues ao funcionário (Utilizado apenas pelo MDTA695 e MDTA630)
		1ª posição - Código do EPI entregue
		2ª posição - Data de entrega do EPI
	9ª posição - Chave de busca do ASO a ser comunicado - Filial + Código do ASO (Utilizado apenas pelo S-2220)
@param	lEnvio, Boolean, Indica se é envio ou validação de informações
@param	oModelTNC, Objeto, Objeto do Acidente para busca de informações (Utilizada apenas pelo S-2210)
@param	oModelTNY, Objeto, Objeto do Atestado para busca de informações (Utilizada apenas pelo S-2210)
@param	cMsgInc, Caracter, Guarda a inconsistência/solução e retorna para a chamada da função (Utilizada apenas pelo S-2240)
@param	cChvRJE, Caracter, Guarda a chave do registro a ser utilizada na busca do registro na RJE

@author	Luis Fellipy Bett
@since	02/12/2020

@return lRet, Lógico, Retorna verdadeiro caso integração tenha sido bem sucedida

@obs Não alterar o nome da função pois é chamada também de específicos (SSMDT01 - SEST/SENAT)
/*/
//---------------------------------------------------------------------
Function MDTIntEsoc( cEvento, nOper, xFicMed, aFuncs, lEnvio, oModelTNC, oModelTNY, cMsgInc, cChvRJE )

	//Variáveis de controle de área/filial
	Local aArea	  := GetArea()
	Local cFilBkp := cFilAnt

	//Variáveis de controle
	Local lRet := .T.
	Local lIntegra := .T. //Variável responsável por definir se o evento deve ser integrado ou não

	//Variáveis de parâmetro
	Local leSocial	 := IIf( FindFunction( "MDTVldEsoc" ), MDTVldEsoc(), .F. )
	Local lSigaMdtPS := SuperGetMv( "MV_MDTPS", .F., "N" ) == "S"

	//Variáveis de busca de informações
	Local cNumMat	 := ""
	Local aFunNaoEnv := {}
	Local aRetorno	 := {}

	//Variáveis de parâmetro private, usadas em todo o processo de validação e geração das informações
	Private dDtEsoc := SuperGetMv( "MV_NG2DTES", .F., SToD( "20211013" ) )
	Private lGPEA010 := FWIsInCallStack( "GPEA010" 		) .Or. FWIsInCallStack( "Gpea010Put" ) // Cadastro de Funcionário
	Private lGPEA180 := FWIsInCallStack( "GPEA180" 		) // Transferência
	Private lGPEA370 := FWIsInCallStack( "GPEA370" 		) // Cargos
	Private lGPEM040 := FWIsInCallStack( 'Gpem040' 		) // Rescisão
	Private lMATA185 := FWIsInCallStack( "MATA185" 		) // Gerar requisição (utilizada na função fVldEsp2240
	Private lMDTA090 := FWIsInCallStack( 'fTarS2240'	) // Tarefas do func.
	Private lMDTA125 := FWIsInCallStack( "MDTA125" 		) // Risco x EPI
	Private lMDTA130 := FWIsInCallStack( "MDTA130" 		) // EPI x Risco
	Private lMDTA165 := FWIsInCallStack( "MDTA165" 		) // Ambiente Físico
	Private lMDTA180 := FWIsInCallStack( "D180INCL" 	) // Cadastro de Risco
	Private lMDTA181 := FWIsInCallStack( "MDTA181" 		) // Relacionamentos do Risco
	Private lMDTA215 := FWIsInCallStack( "MDTA215" 		) // Laudos x Risco
	Private lMDTA630 := FWIsInCallStack( "MDTA630" 		) // EPI x Funcionário
	Private lMDTA695 := FWIsInCallStack( "MDTA695" 		) // Funcionário x EPI
	Private lMDTA881 := FWIsInCallStack( "MDTA881" 		) // Carga Inicial
	Private lMDTA882 := FWIsInCallStack( "MDTA882" 		) // Schedule de Tarefas
	Private lExecAuto := IIf( lGPEA010 .And. Type( "lGp010Auto" ) != "U", lGp010Auto, .F. ) .Or. IsBlind()
	Private lMiddleware	:= IIf( cPaisLoc == 'BRA' .And. Findfunction( "fVerMW" ), fVerMW(), .F. )

	Default lEnvio	  := .T. //Por padrão sempre faz o envio ao Governo, se passado como .F. apenas valida as informações a serem enviadas e não envia
	Default oModelTNC := Nil
	Default oModelTNY := Nil
	Default cMsgInc	  := ""
	Default cChvRJE	  := ""
	Default aFuncs	  := {}

	//---------------------------------------------------------------------------
	// Função genérica para posicionar na filial correta em chamadas específicas
	//---------------------------------------------------------------------------
	fPosFil( cEvento )
	
	If cEvento == "S-2210" .Or. cEvento == "S-2220"
		If ValType( xFicMed ) == "A" //Caso tiver passado um array com as fichas a serem comunicadas
			aFuncs := fGetMatFic( xFicMed )
		Else
			If !Empty( cNumMat := MDTDadFun( xFicMed )[1] ) //Busca a matrícula do funcionário
				aFuncs := { { cNumMat } } //Adiciona a matrícula no array
			EndIf
		EndIf
	EndIf

	//--------------------------------
	// Realiza as validações iniciais
	//--------------------------------
	If lSigaMdtPS //Valida se é Prestador
		lIntegra := .F.
	ElseIf !leSocial //Valida se tem integração com o eSocial
		lIntegra := .F.
	ElseIf ( cEvento == "S-2210" .Or. cEvento == "S-2220" ) .And. Len( aFuncs ) == 0 //Valida se as fichas médicas 
		lIntegra := .F.
	EndIf

	//-----------------------------------------------
	// Verifica se o funcionário deve ser comunicado
	// ao SIGATAF/Middleware ou não
	//-----------------------------------------------
	If lIntegra

		//Valida se algum funcionário não deve ser integrado
		fFunNaoEnv( cEvento, @aFuncs, nOper, @aFunNaoEnv )

		//Verifica se existe pelo menos um funcionário que deve ser integrado
		lIntegra := Len( aFuncs ) > 0

	EndIf

	//--------------------------------------
	// Caso as validações predecessoras
	// estejam ok, valida/envia ao eSocial
	//--------------------------------------
	If lIntegra
		If cEvento == "S-2210"
			aRetorno := MDTS2210( cNumMat, nOper, lEnvio, oModelTNC, oModelTNY, cChvRJE )
		ElseIf cEvento == "S-2220"
			aRetorno := MDTS2220( aFuncs, nOper, lEnvio, cChvRJE, @aFunNaoEnv )
		ElseIf cEvento == "S-2240"
			aRetorno := MDTS2240( aFuncs, nOper, lEnvio, @cMsgInc, cChvRJE, @aFunNaoEnv )
		EndIf

		lRet := aRetorno[ 1 ]
		lIntegra := aRetorno[ 2 ]
	EndIf

	//-------------------------------------------------------------
	// Caso seja após o envio, o envio tenha ocorrido sem
	// inconsistências e tenha funcionários que não foram enviados
	//-------------------------------------------------------------
	If lEnvio .And. Len( aFunNaoEnv ) > 0
		fMsgNaoEnv( aFunNaoEnv, @cMsgInc ) //Exibe a mensagem informando quais funcionários não foram comunicados
	EndIf

	cFilAnt := cFilBkp //Retorna para filial atual
	RestArea( aArea ) //Retorna área

Return lRet

//---------------------------------------------------------------------
/*/{Protheus.doc} MDTS2210
Função genérica que valida o envio das informações do evento S-2210 (CAT)

@sample	MDTS2210( 3, "000021", .F., oModel1, oModel2 )

@param cNumMat, Caracter, Indica a matrícula do funcionário do Acidente
@param nOper, Numérico, Indica a operação que está sendo realizada (3-Inclusão/4-Alteração/5-Exclusão)
@param lEnvio, Boolean, Indica no caso de Acidente, se é envio ou validação de informações
@param oModelTNC, Objeto, Objeto do Acidente para busca de informações
@param oModelTNY, Objeto, Objeto do Atestado para busca de informações
@param cChvRJE, Caracter, Guarda a chave do registro a ser utilizada na busca do registro na RJE

@author	Luis Fellipy Bett
@since	09/11/2020

@return lRet, Boolean, Retorna verdadeiro caso a integração tenha sido bem sucedida
/*/
//---------------------------------------------------------------------
Function MDTS2210( cNumMat, nOper, lEnvio, oModelTNC, oModelTNY, cChvRJE )

	//Variáveis de controle de área/filial
	Local aAreaTNC := TNC->( GetArea() )

	//Variáveis de controle
	Local lRet	   := .T.
	Local lIntegra := .T.
	Local lValida  := !lEnvio //Caso não for envio das informações, valida

	//Variáveis de chamadas utilizadas no MDTM002 para validação das informações
	Private lAcidente	 := fVerStack( "MDTA640", oModelTNC )
	Private lDiagnostico := fVerStack( "MDTA155", oModelTNC )
	Private lAtestado	 := fVerStack( "MDTA685", oModelTNC )

	//Variável de parâmetro
	Private cAtendAci := SuperGetMv( "MV_NG2IATE", .F., "3" )

	//---------------------------------------------------------------------------
	// Realiza as validações iniciais de envio, para verificar se o registro que
	// está sendo incluido/alterado/excluído deve ser comunicado com o Governo
	//---------------------------------------------------------------------------
	If lAcidente .And. !fVincCAT( oModelTNC ) //Verifica se a CAT está vinculada a um diagnóstico/atestado
		lIntegra := .F.
	ElseIf lDiagnostico .And. cAtendAci == "2" //Valida se o Diagnóstico deve ser considerado para envio das informações do atendimento
		lIntegra := .F.
	ElseIf lAtestado .And. cAtendAci == "1" //Valida se o Atestado deve ser considerado para envio das informações do atendimento
		lIntegra := .F.
	ElseIf lDiagnostico .And. Empty( M->TMT_ACIDEN ) //Valida se o Diagnóstico está vinculado a um acidente
		lIntegra := .F.
	ElseIf lAtestado .And. Empty( oModelTNY:GetValue( "TNYMASTER1", "TNY_ACIDEN" ) ) //Valida se o Atestado está vinculado a um acidente
		lIntegra := .F.
	ElseIf !( IIf( lAcidente, oModelTNC:GetValue( "TNCMASTER", "TNC_DTACID" ), TNC->TNC_DTACID ) >= dDtEsoc ) //Valida se a data do acidente é posterior a data início das obrigatoriedades de SST
		lIntegra := .F.
	ElseIf !( IIf( lAcidente, oModelTNC:GetValue( "TNCMASTER", "TNC_INDACI" ), TNC->TNC_INDACI ) $ "1/2/3" ) //Valida se é acidente típico, doença do trabalho ou acidente de trajeto
		lIntegra := .F.
	ElseIf lValida .And. ( nOper == 3 .Or. nOper == 4 ) //Caso for inclusão ou alteração
		If lAcidente .And. !MDTObriEsoc( "TNC", , oModelTNC ) //Valida os campos obrigatórios do Acidente
			lIntegra := .F.
			lRet := .F. //Caso os campos obrigatórios não estiverem preenchidos, retorna falso para parar o envio
		ElseIf lDiagnostico .And. !MDTObriEsoc( "TMT" ) //Valida os campos obrigatórios do Diagnóstico
			lIntegra := .F.
			lRet := .F. //Caso os campos obrigatórios não estiverem preenchidos, retorna falso para parar o envio
		ElseIf lAtestado .And. !MDTObriEsoc( "TNY", , oModelTNY ) //Valida os campos obrigatórios do Atestado
			lIntegra := .F.
			lRet := .F. //Caso os campos obrigatórios não estiverem preenchidos, retorna falso para parar o envio
		EndIf
	EndIf

	//-----------------------------------------------------------------------
	// Realiza as validações do ambiente de envio, para verificar versão do
	// leiaute, se o ambiente do cliente tem dicionários aplicados, etc
	//-----------------------------------------------------------------------
	If lValida .And. lIntegra .And. !MDTVerAPrp( "S2210" )
		lIntegra := .F.
		lRet := .F. //Caso o ambiente não estiver preparado, retorna falso para parar o envio
	EndIf

	If lIntegra //Caso as validações predecessoras estejam ok, valida/envia ao eSocial

		If lAtestado .Or. lDiagnostico //Caso for cadastro de Acidente

			If nOper == 3 .Or. nOper == 5 //Se for inclusão ou exclusão de Diagnóstico/Atestado, significa que é alteração no evento de Acidente, portanto 4- Alteração
				nOper := 4
			EndIf

			dbSelectArea( "TNC" )
			dbSetOrder( 1 ) // TNC_FILIAL + TNC_ACIDEN
			dbSeek( xFilial( "TNC" ) + IIf( lDiagnostico, M->TMT_ACIDEN, M->TNY_ACIDEN ) )

			cChvRJE := DToS( TNC->TNC_DTACID ) + StrTran( TNC->TNC_HRACID, ":", "" ) + TNC->TNC_TIPCAT //Chave do registro do acidente que vai ser alterado

		EndIf

		If nOper <> 5 .And. lValida //Caso a operação seja diferente de exclusão, valida as informações a serem enviadas
			lRet := MDTVldDad( "S-2210", nOper, { { cNumMat } }, , oModelTNC )
		EndIf

		If ( lRet .Or. nOper == 5 ) .And. lEnvio //Caso for envio de informações e não apenas validação
			lRet := MDTEnvEsoc( "S-2210", nOper, { { cNumMat } }, oModelTNC, cChvRJE )
		EndIf
	EndIf

	RestArea( aAreaTNC ) //Retorna área da tabela TNC

Return { lRet, lIntegra }

//---------------------------------------------------------------------
/*/{Protheus.doc} MDTS2220
Função genérica que valida o envio das informações do evento S-2220 (ASO)

@sample	MDTS2220( 3, "000021" )

@param aFuncs, Array, Array contendo os funcionáros a serem processados
@param nOper, Numérico, Indica a operação que está sendo realizada (3-Inclusão/4-Alteração/5-Exclusão)
@param lEnvio, Boolean, Indica no caso de Acidente, se é envio ou validação de informações
@param cChvRJE, Caracter, Guarda a chave do registro a ser utilizada na busca do registro na RJE
@param	aFunNaoEnv, Array, Array que receberá os funcionários que não deverão ser integrados

@author	Luis Fellipy Bett
@since	09/11/2020

@return lRet, Lógico, Retorna verdadeiro caso a integração tenha sido bem sucedida
/*/
//---------------------------------------------------------------------
Function MDTS2220( aFuncs, nOper, lEnvio, cChvRJE, aFunNaoEnv )

	//Variáveis de controle de área/filial
	Local aAreaTMY := TMY->( GetArea() )

	Local lRet	   := .T.
	Local lIntegra := .T.
	Local lASORet  := .T.
	Local lValida  := !lEnvio //Caso não for envio das informações, valida

	//Variáveis de chamadas
	Local lImpASO := IsInCallStack( "NGIMPRASO" ) .Or. IsInCallStack( "MDTR465" ) .Or. IsInCallStack( "NG200IMP" ) .Or. IsInCallStack( "fValAsoAdm" )

	//---------------------------------------------------------------------------
	// Realiza as validações iniciais de envio, para verificar se o registro que
	// está sendo incluido/alterado/excluído deve ser comunicado com o Governo
	//---------------------------------------------------------------------------
	If lValida .And. !lImpASO .And. !MDTObriEsoc( "TMY" ) //Caso for cadastro de ASO, valida os campos obrigatórios
		lIntegra := .F.
		lRet := .F. //Caso os campos obrigatórios não estiverem preenchidos, retorna falso para parar o envio
	ElseIf !lImpASO .And. Empty( M->TMY_DTEMIS ) //Valida se o ASO já foi emitido
		lIntegra := .F.
	ElseIf !( IIf( lImpASO, dDataBase, M->TMY_DTEMIS ) >= dDtEsoc ) //Valida se a data do ASO é posterior a data início das obrigatoriedades de SST
		lIntegra := .F.
	EndIf

	//-----------------------------------------------------------------------------
	// Realiza validações verificando caso o funcionário estiver demitido se o ASO
	// é demissional, se não for exclui o funcionário do array para não enviar
	//-----------------------------------------------------------------------------
	If lIntegra
		
		//Valida para os funcionário demitidos, se o ASO que está sendo integrado é ASO demissional
		fVldFunDem( @aFuncs, lImpASO )

		//Verifica se existe pelo menos um funcionário que deve ser integrado
		lIntegra := Len( aFuncs ) > 0

	EndIf

	//----------------------------------------------------------------------------
	// Verifica se o evento deve ser enviado de acordo com o parâmetro MV_NG2DENO 
	// caso o funcionário não esteja exposto a nenhum risco
	//----------------------------------------------------------------------------
	If lIntegra
	
		//Valida se existe algum funcionário sem exposição a risco que tenha o evento sendo enviado com uma data menor que a do parâmetro MV_NG2DENO
		fEveNObrig( "S-2220", @aFuncs, nOper, @aFunNaoEnv )

		//Verifica se existe pelo menos um funcionário que deve ser integrado
		lIntegra := Len( aFuncs ) > 0

	EndIf

	//-----------------------------------------------------------------------
	// Realiza as validações do ambiente de envio, para verificar versão do
	// leiaute, se o ambiente do cliente tem dicionários aplicados, etc
	//-----------------------------------------------------------------------
	If lValida .And. lIntegra .And. !MDTVerAPrp( "S2220" )
		lIntegra := .F.
		lRet := .F.
	EndIf

	//---------------------------------------------------------------------------------
	// Realiza a validação referente a ASO admissional, verificando se existem
	// outros ASO's admissionais cadastrados para o funcionário no SIGATAF/Middleware
	//---------------------------------------------------------------------------------
	If lValida .And. lIntegra .And. nOper != 5 //Caso seja validação, deva integrar o evento e não for exclusão

		//Verifica se existem ASO's admissionais anteriores pra casos de envio de ASO admissional		
		lASORet := fVldASOAdm( aFuncs, lImpASO )

		//Adiciona o retorno da função às variáveis
		lIntegra := lASORet
		lRet := lASORet

	EndIf

	//Caso as validações predecessoras estejam ok, valida/envia ao eSocial
	If lIntegra

		//Caso não for exclusão de registro e deva validar
		If nOper <> 5 .And. lValida
			lRet := MDTVldDad( "S-2220", nOper, aFuncs )
		EndIf

		If ( lRet .Or. nOper == 5 ) .And. lEnvio
			lRet := MDTEnvEsoc( "S-2220", nOper, aFuncs, , cChvRJE ) //Envia as informações ao Governo
		EndIf

	EndIf

	RestArea( aAreaTMY ) //Retorna área da tabela TMY

Return { lRet, lIntegra }

//---------------------------------------------------------------------
/*/{Protheus.doc} MDTS2240
Função genérica que valida o envio das informações do evento S-2240 (Riscos)

@sample	MDTS2240( { { "000021" } }, 3, .F., @cMsg )

@param aFuncs, Array, Array contendo os funcionários que terão as informações validadas/enviadas
@param nOper, Numérico, Indica a operação que está sendo realizada (3-Inclusão/4-Alteração/5-Exclusão)
@param lEnvio, Boolean, Indica no caso de Acidente, se é envio ou validação de informações
@param cMsgInc, Caracter, Guarda a inconsistência/solução e retorna para a chamada da função
@param cChvRJE, Caracter, Guarda a chave do registro a ser utilizada na busca do registro na RJE
@param	aFunNaoEnv, Array, Array que receberá os funcionários que não deverão ser integrados

@author	Luis Fellipy Bett
@since	09/11/2020

@return	lRet, Lógico, Retorna verdadeiro caso a integração tenha sido bem sucedida
/*/
//---------------------------------------------------------------------
Function MDTS2240( aFuncs, nOper, lEnvio, cMsgInc, cChvRJE, aFunNaoEnv )

	//Variáveis de controle e contadores
	Local lRet	   := .T.
	Local lIntegra := .T.
	Local lValida  := .T.

	//Variáveis de parâmetro
	Local lIntRHTAF	 := SuperGetMv( "MV_RHTAF", .F., .F. )

	Local cDescAtiv := "" //Variavel para controle paliativo da descrição da atividade

	//Caso for Carga Inicial ou execução do Schedule de Tarefas, realiza a validação
	//Apenas o GPEA010, GPEA180, MDTA881 e MDTA882 devem ficar nessa condição, os outros devem ser ajustados a etapa de validação e envio separadamente
	If lMDTA125 .Or. lMDTA130 .Or. lMDTA181 .Or. lMDTA215 .Or. lMDTA881 .Or. lMDTA882 .Or. lGPEA180 .Or. lGPEA010 .Or. lMATA185
		lValida := .T.
	Else
		lValida := !lEnvio
	EndIf

	//---------------------------------------------------------------------------
	// Realiza as validações iniciais de envio, para verificar se o registro que
	// está sendo incluido/alterado/excluído deve ser comunicado com o Governo
	//---------------------------------------------------------------------------

	// Valida se o risco está avaliado, caso não estiver não envia
	If ( lMDTA180 .Or. lMDTA181 ) .And. Empty( M->TN0_DTAVAL )

		lIntegra := .F.

	// Valida se o agente do risco não está vazio e é diferente do código de ausência
	ElseIf ( lMDTA180 .Or. lMDTA181 ) .And. ( Empty( Posicione( "TMA", 1, xFilial( "TMA" ) + M->TN0_AGENTE, "TMA_ESOC" ) ) .Or. ;
		Posicione( "TMA", 1, xFilial( "TMA" ) + M->TN0_AGENTE, "TMA_ESOC" ) == "09.01.001" )

		lIntegra := .F.

	// Caso o risco foi eliminado antes ou no dia da entrada do eSocial
	ElseIf ( lMDTA180 .Or. lMDTA181 ) .And. !Empty( M->TN0_DTELIM ) .And. M->TN0_DTELIM <= dDtEsoc

		lIntegra := .F.

	// Se inclusão de risco verifica se envia somente riscos vinculados ao laudo
	ElseIf lMDTA180 .And. nOper == 3 .And. SuperGetMv( 'MV_NG2VLAU', .F., '2' ) == '1'

		lIntegra := .F.

	// Se Cadastro de Funcionário ou Transferências, verifica se existe integração do RH com o TAF ou com o Middleware
	ElseIf ( lGPEA010 .Or. lGPEA180 ) .And. ( !lIntRHTAF .And. !lMiddleware )

		lIntegra := .F.

	// Valida se houve alguma alteração no cadastro do funcionário que necessite retificar o S-2240
	ElseIf lGPEA010 .And. !fVldEnvFun()

		lIntegra := .F.

	// Caso os campos obrigatórios não estiverem preenchidos, retorna falso para parar o envio
	ElseIf lValida .And. lMDTA180 .And. !MDTObriEsoc( "TN0", !( Inclui .Or. Altera ) )

		lIntegra := .F.
		lRet := .F.

	// Verifica se o EPI já foi enviado anteriormente ## Verifica o vínculo do EPI com o risco
	ElseIf ( lMDTA630 .Or. lMDTA695 .Or. lMATA185 ) .And. !fVldEPIRis( @cMsgInc, aFuncs, lValida )

		lIntegra := .F.

	EndIf

	If lIntegra .And. !fVldFunAvu( @aFuncs, @aFunNaoEnv, nOper )
		lIntegra := .F.
	EndIf

	//----------------------------------------------------------------------------
	// Verifica se o evento deve ser enviado de acordo com o parâmetro MV_NG2DENO 
	// caso o funcionário não esteja exposto a nenhum risco
	//----------------------------------------------------------------------------
	If lIntegra
	
		//Valida se existe algum funcionário sem exposição a risco que tenha o evento sendo enviado com uma data menor que a do parâmetro MV_NG2DENO
		fEveNObrig( "S-2240", @aFuncs, nOper, @aFunNaoEnv )

		//Verifica se existe pelo menos um funcionário que deve ser integrado
		lIntegra := Len( aFuncs ) > 0

	EndIf

	//-----------------------------------------------------------------------
	// Realiza as validações do ambiente de envio, para verificar versão do
	// leiaute, se o ambiente do cliente tem dicionários aplicados, etc
	//-----------------------------------------------------------------------
	If lValida .And. lIntegra .And. !MDTVerAPrp( "S2240", @cMsgInc )
		lIntegra := .F.
		lRet := .F.
	EndIf

	//--------------------------------------
	// Realiza verificações específicas
	// para algumas chamadas do S-2240
	//--------------------------------------
	If lValida .And. lIntegra
		fVldEsp2240( @cMsgInc, aFuncs, nOper )
	EndIf

	//-------------------------------------------------------------
	// Ajusta a chave única se necessário quando for transferência
	//-------------------------------------------------------------
	If lIntegra .And. lGPEA180
		fAjsCodUni( @aFuncs )
	EndIf

	If lIntegra //Caso as validações predecessoras estejam ok, valida/envia ao eSocial

		If nOper <> 5 .And. lValida
			Processa( { || lRet := MDTVldDad( "S-2240", nOper, aFuncs, , , , @cMsgInc ) }, STR0001 ) //Valida as informações a serem enviadas ## "Aguarde, validando os registros..."
		EndIf

		If ( lRet .Or. nOper == 5 ) .And. lEnvio
			Processa( { || lRet := MDTEnvEsoc( "S-2240", nOper, aFuncs, , cChvRJE, @cMsgInc, @cDescAtiv ) }, STR0002 ) //Envia as informações ao Governo ## "Aguarde, enviando os registros..."
		EndIf
	EndIf

Return { lRet, lIntegra }

//---------------------------------------------------------------------
/*/{Protheus.doc} MDTVerAPrp
Função genérica que verifica se o ambiente está preparado para o envio dos dados ao eSocial

@sample MDTVerAPrp( S2210, .T., @cMsgInc )

@param cEvento, Caracter, Indica o evento que está sendo enviado
@param cMsgInc, Caracter, Guarda a inconsistência e a solução e retorna para a chamada da função

@author  Luis Fellipy Bett
@since   10/11/2020

@return lRet, Lógico, Retorna verdadeiro caso exista integração
/*/
//---------------------------------------------------------------------
Function MDTVerAPrp( cEvento, cMsgInc )

	//Variáveis de controle
	Local lRet := .T.
	Local cVersLyt := ""
	Local cTAFVLES := SuperGetMv( 'MV_TAFVLES', .F., "02_05_00" )

	//Variáveis de busca de informação
	Local aTAF	  := {}
	Local cIncons := ""
	Local cCorrec := ""
	Local cStatus := "-1" //Verificação dos eventos predecessores - Evento S1000

	If lMiddleware //Validações de ambiente do Middleware
		If !ChkFile( "RJE" ) //Verifica se a tabela RJE existe
			cIncons := STR0003 //"Tabela RJE não encontrada"
			cCorrec := STR0004 //"Favor aplicar o pacote acumulado do eSocial para atualização do ambiente"
		ElseIf !ChkFile( "RJ9" ) //Verifica se a tabela RJ9 existe
			cIncons := STR0005 //"Tabela RJ9 não encontrada"
			cCorrec := STR0004 //"Favor aplicar o pacote acumulado do eSocial para atualização do ambiente"
		ElseIf Len( fXMLInfos() ) <= 0
			cIncons := STR0006 //"Não foram encontradas as informações da empresa na tabela RJ9"
			cCorrec := STR0007 //"Favor configurar a empresa para envio das informações"

		ElseIf FindFunction( "fVersEsoc" )

			fVersEsoc( cEvento, .F., Nil, Nil, Nil, Nil, @cVersLyt )

			If !fValVerLei( cVersLyt )
				cIncons := STR0069 // "Os eventos de SST do eSocial somente serão enviados caso o leiaute seja o S-1.1 (válido até 21/01/2024) ou S-1.2 (válido a partir de 20/11/2023)"
				cCorrec := STR0070 //"Favor configurar o ambiente nas condições citadas"
			EndIf

		ElseIf !fVld1000( AnoMes( dDataBase ), @cStatus )

			// 1 - Não enviado 			- Gravar por cima do registro encontrado
			// 2 - Enviado 				- Aguarda Retorno ( Enviar mensagem em tela e não continuar com o processo )
			// 3 - Retorno com Erro		- Gravar por cima do registro encontrado
			// 4 - Retorno com Sucesso	- Efetivar a gravação

			If cStatus == "-1" .Or. cStatus == "0" // nao encontrado na base de dados
				cIncons := STR0008 //"Registro do evento S-1000 não localizado na base de dados"
			ElseIf cStatus == "1" // nao enviado para o governo
				cIncons := STR0009 //"Registro do evento S-1000 não transmitido para o governo"
			ElseIf cStatus == "2" // enviado e aguardando retorno do governo
				cIncons := STR0010 //"Registro do evento S-1000 aguardando retorno do governo"
			ElseIf cStatus == "3" // enviado e retornado com erro
				cIncons := STR0011 //"Registro do evento S-1000 retornado com erro do governo"
			EndIf
			cCorrec := STR0012 //"Favor efetivar primeiramente o envio do evento S-1000"

		EndIf

	Else //Validações de ambiente do TAF

		aTAF := TafExisEsc( cEvento )

		If !aTAF[ 1 ] //Verifica se existe integração com o SIGATAF
			cIncons := STR0013 //"O ambiente não possui integração com o módulo do TAF"
			cCorrec := STR0014 //"Favor verificar"
		ElseIf aTAF[ 2 ] <> "1.0" .And. aTAF[ 2 ] <> "1.1" //Verifica se o leiaute do eSocial é o mais atual
			cIncons := STR0015 //"A versão do TAF está desatualizada"
			cCorrec := STR0014 //"Favor verificar"
		ElseIf !fValVerLei( cTAFVLES )
			cIncons := STR0069 // "Os eventos de SST do eSocial somente serão enviados caso o leiaute seja o S-1.1 (válido até 21/01/2024) ou S-1.2 (válido a partir de 20/11/2023)"
			cCorrec := STR0070 //"Favor configurar o ambiente nas condições citadas"
		EndIf

	EndIf

	//Validações de ambiente do SIGAMDT
	If Empty( cIncons ) .And. !fVldMDTAtu() //Verifica se o ambiente do MDT está atualizado
		cIncons := STR0016 //"A versão do MDT está desatualizada"
		cCorrec := STR0004 //"Favor aplicar o pacote acumulado do eSocial para atualização do ambiente"
	EndIf

	If !Empty( cIncons ) //Caso houver erro nas validações
		If !lExecAuto //Caso não for execução automática (via Schedule) emite a mensagem
			Help( ' ', 1, STR0017, , cIncons, 2, 0, , , , , , { cCorrec } ) //STR0017
		Else
			cMsgInc += CRLF + "- " + STR0018 + ": " + cIncons + CRLF + "- " + STR0019 + ": " + cCorrec //Ocorrência ## Solução
		EndIf
		lRet := .F.
	EndIf

Return lRet

//---------------------------------------------------------------------
/*/{Protheus.doc} fValVerLei
Valida a versão do leiaute atual

@author Gabriel Sokacheski
@since 02/11/2023

@param cLeiaute, leiaute atual

@return lRet, indica se o leiaute atual é válido
/*/
//---------------------------------------------------------------------
Static Function fValVerLei( cLeiaute )

	Local lRet := .F.

	If ( ( dDataBase <= CtoD( '21/01/2024' ) .And. 'S_01_01' $ cLeiaute ) .Or. 'S_01_02' $ cLeiaute )
		lRet := .T.
	EndIf

Return lRet

//---------------------------------------------------------------------
/*/{Protheus.doc} fVldMDTAtu
Valida se o SIGAMDT está atualizado e preparado para o envio dos eventos

@sample fVldMDTAtu()

@author  Luis Fellipy Bett
@since   09/03/2021

@return lRet, Lógico, Retorna verdadeiro caso esteja atualizado
/*/
//---------------------------------------------------------------------
Static Function fVldMDTAtu()

	Local aArea	:= GetArea()
	Local lRet	:= .T.

	dbSelectArea( "TNE" )
	If Empty( IndexKey( 2 ) ) //Caso o índice 2 da TNE não exista, significa que o ambiente está desatualizado
		lRet := .F.
	EndIf

	RestArea( aArea )

Return lRet

//---------------------------------------------------------------------
/*/{Protheus.doc} MDTVldDad
Função genérica que valida os dados dos Xml's a serem enviados ao Governo

@sample MDTVldDad( "S-2210", 3, .T., oModel )

@param cEvento, Caracter, Indica o evento que está sendo enviado
@param nOper, Numérico, Indica a operação que está sendo realizada (3-Inclusão/4-Alteração/5-Exclusão)
@param aFuncs, Array, Array contendo os funcionários que terão as informações de envio validadas
@param lXml, Boolean, Indica se é geração de Xml
@param oModel, Objeto, Modelo a ser utilizado pela busca das informações do Acidente (S-2210)
@param dDataEnv, Data, Data a ser considerada no envio do evento
@param cMsgInc, Caracter, Guarda a inconsistência e a solução e retorna para a chamada da função

@author  Luis Fellipy Bett
@since   09/11/2020

@return lRet, Lógico, Retorna verdadeiro caso não existam inconsistências
/*/
//---------------------------------------------------------------------
Function MDTVldDad( cEvento, nOper, aFuncs, lXml, oModel, dDataEnv, cMsgInc )

	//Variáveis de controle
	Local lRet := .T.
	Local cFilBkp := cFilAnt

	//Variáveis de contadores
	Local nCont := 0

	//Variáveis de composição de informações
	Local aIncEnv  := {}
	Local cFonte   := IIf( cEvento == "S-2210", "MDTM002", IIf( cEvento == "S-2220", "MDTM003", "MDTM004" ) )
	Local cNomeFun := ""
	Local dDtAtu   := SToD( "" )
	Local aGPEA180 := {}
	Local cChvASO  := ""

	//Variáveis private para busca das informações da filial de envio e empresa e filial destino no caso da transferência
	Private cEmpDes := cEmpAnt //Empresa destino (utilizado pelo GPEA180), inicia por padrão como a empresa atual
	Private cFilDes := cFilAnt //Filial destino (utilizado pelo GPEA180), inicia por padrão como a filial atual
	Private cFilEnv := "" //Filial de envio do TAF/Middleware

	Default lXml	 := .F.
	Default oModel	 := Nil
	Default dDataEnv := SToD( "" )
	Default cMsgInc  := ""

	//Trata mensagem inicial de inconsistências
	If cEvento == "S-2210"
		aAdd( aIncEnv, STR0020 + " (" + cEvento + ")" ) //"Inconsistências da CAT"
	ElseIf cEvento == "S-2220"
		aAdd( aIncEnv, STR0021 + " (" + cEvento + ")" ) //"Inconsistências do ASO"
	ElseIf cEvento == "S-2240"
		aAdd( aIncEnv, STR0022 + " (" + cEvento + ")" ) //"Inconsistências dos Riscos"
	EndIf
	aAdd( aIncEnv, STR0023 + ": " ) //"Os campos abaixo estão em branco ou possuem inconsistência com relação ao formato padrão do eSocial"
	aAdd( aIncEnv, "" )
	aAdd( aIncEnv, "" )

	//Define o tamanho da régua de processamento, caso envio do evento S-2240
	If cEvento == "S-2240"
		ProcRegua( Len( aFuncs ) )
	EndIf

	//Passa por todos os funcionários, validando os dados a serem enviados ao SIGATAF/Middleware
	For nCont := 1 To Len( aFuncs )

		//Incrementa a régua, caso envio do evento S-2240
		If cEvento == "S-2240"
			IncProc()
		EndIf

		//---------------------------------------------------------------------------
		// Função genérica para posicionar na filial correta em chamadas específicas
		//---------------------------------------------------------------------------
		fPosFil( cEvento, IIf( Len( aFuncs[ nCont ] ) > 1 .And. aFuncs[ nCont, 2 ] <> Nil, aFuncs[ nCont, 2 ], "" ) )

		//------------------------------------------------------------------------------------
		// Caso for transferência (GPEA180) adiciona as informações da transferência do array
		//------------------------------------------------------------------------------------
		If lGPEA180
			aGPEA180 := aFuncs[ nCont, 7 ]

			cEmpDes := aGPEA180[ 1, 3 ]
			cFilDes := aGPEA180[ 1, 5 ]
		EndIf

		//----------------------------------------------------------------
		// Busca a filial de envio que será considerada no TAF/Middleware
		//----------------------------------------------------------------
		cFilEnv := MDTBFilEnv()

		//-----------------------------------------------------------------------
		// Realiza as validações de envio dos eventos S-2190, S-2200 ou S-2230,
		// que são de envio obrigatório antes do envio de qualquer evento de SST
		//-----------------------------------------------------------------------
		If !MDTVld2200( aFuncs[ nCont, 1 ], aGPEA180 ) //Valida o envio do evento S-2190, S-2200 ou S-2300 do funcionário
			cNomeFun := AllTrim( Posicione( "SRA", 1, xFilial( "SRA" ) + aFuncs[ nCont, 1 ], "RA_NOME" ) )
			aAdd( aIncEnv, STR0024 + ": " + AllTrim( aFuncs[ nCont, 1 ] ) + " - " + cNomeFun ) //Funcionário: XXX - XXXXX
			aAdd( aIncEnv, STR0018 + ": " + STR0025 + " (" + cEvento + ") " + STR0026 ) //Ocorrência: Não será possível integrar o evento XXX com o Governo pois o registro de Admissão ou Carga Inicial deste
			aAdd( aIncEnv, STR0027 ) //funcionário ainda não foi integrado via SIGATAF ou Middleware
			aAdd( aIncEnv, STR0019 + ": " + STR0028 ) //Solução: Favor efetivar primeiramente o envio do evento S-2190, S-2200 ou S-2300 do funcionário
			aAdd( aIncEnv, '' )
			Loop
		EndIf

		//-----------------------------------------------------------------------
		// Realiza as validações de envio dos eventos S-2200 ou S-2230, que são
		// de envio obrigatório antes do envio de qualquer evento de SST
		//-----------------------------------------------------------------------
		If cEvento == "S-2210" //Caso for evento de CAT

			MDTM002( nOper, .T., @aIncEnv, oModel ) //Avalia as inconsistências da CAT

		ElseIf cEvento == "S-2220" //Caso for evento de ASO

			If Len( aFuncs[ nCont ] ) > 8 .And. aFuncs[ nCont, 9 ] <> Nil
				cChvASO := aFuncs[ nCont, 9 ]
			EndIf

			MDTM003( nOper, .T., @aIncEnv, , cChvASO ) //Avalia as inconsistências do ASO

		ElseIf cEvento == "S-2240" //Caso for evento de Risco

			//Busca a data de exposição atual do evento S-2240
			dDtAtu := MDTDtExpAtu( aFuncs[ nCont, 1 ] )

			//Busca a data de envio a ser considerada no envio do evento S-2240
			dDataEnv := MDTBscDtEnv( aFuncs[ nCont ], nOper, lXml, dDtAtu )

			If !Empty( dDataEnv ) //Caso exista uma inclusão/alteração do período de exposição, envia ao Governo
				MDTM004( aFuncs[ nCont, 1 ], nOper, dDataEnv, .T., @aIncEnv, Nil, aGPEA180, IIf( FWIsInCallStack( 'mdta090' ), aFuncs[ nCont, 6 ], Nil ) ) //Avalia as inconsistências do Risco
			EndIf

		EndIf

	Next nCont

	//Monta o relatório de inconsistências
	If Len( aIncEnv ) > 4

		//Caso seja execução via tela e não seja chamada do GPEA180
		If !lExecAuto .And. !lGPEA180

			fMakeLog( { aIncEnv }, { STR0029 }, Nil, Nil, cFonte, OemToAnsi( STR0030 ), "M", "P", , .F. )

			If lXml
				cStrInc := STR0031 //"O Xml possui inconsistências de acordo com o formato padrão do eSocial"
			Else
				cStrInc := STR0032 //"Envio ao SIGATAF/Middleware não realizado"
			EndIf

			Help( ' ', 1, STR0017, , cStrInc, 2, 0, , , , , , { STR0033 } )

		Else

			//Adiciona as inconsistências à variável para geração do arquivo do Schedule
			For nCont := 1 To Len( aIncEnv )

				cMsgInc += CRLF + "- " + aIncEnv[ nCont ]

			Next nCont

			//Caso for execução automática do GPEA010
			If lExecAuto

				//Adiciona no log
				AutoGrLog( cMsgInc )

			EndIf

		EndIf

		//Define o retorno como .F.
		lRet := .F.

	EndIf

	//Volta a filial
	cFilAnt := cFilBkp

Return lRet

//---------------------------------------------------------------------
/*/{Protheus.doc} MDTEnvEsoc
Função genérica que envia Xml's ao Governo, através do TAF ou Middleware

@param cEvento, Caracter, Indica o evento que está sendo enviado
@param nOper, Numérico, Indica a operação que está sendo realizada (3-Inclusão/4-Alteração/5-Exclusão)
@param cFicMed, Caracter, Indica a ficha médica do funcionário
@param oModel, Objeto, Objeto para busca de informações de rotinas em MVC
@param cChvRJE, Caracter, Guarda a chave do registro a ser utilizada na busca do registro na RJE
@param cMsgInc, Caracter, Guarda a inconsistência e a solução e retorna para a chamada da função

@author  Luis Fellipy Bett
@since   09/11/2020

@return lRet, Lógico, Retorna verdadeiro caso a integração tenha sido bem sucedida
/*/
//---------------------------------------------------------------------
Function MDTEnvEsoc( cEvento, nOper, aFuncs, oModel, cChvRJE, cMsgInc, cDescAtiv )

	Local aTbls			:= { 'C1E', 'CR9', 'C9V', 'T3A', 'CM9', 'CMA', 'CMB', 'LEA', 'T3S' }
	Local aErros		:= {}
	Local aDadFun 		:= {}
	Local aRetorno		:= {} // Recebe o erro de integração, se houver
	Local aGPEA180		:= {}

	Local cXml	   		:= ""
	Local cTpASO   		:= ""
	Local cEmpBkp  		:= cEmpAnt
	Local cFilBkp  		:= cFilAnt
	Local cArqBkp  		:= cArqTab
	Local cStrChv  		:= ""
	Local cChvAtu 		:= ""
	Local cChvNov 		:= ""
	Local cTAFKey 		:= "" // TAFKey a ser utilizada na integração do S-2210 (quando houver alteração da data, hora ou tipo do acidente)
	Local cEvtAux		:= SubStr( cEvento, 1, 1 ) + SubStr( cEvento, 3, 4 )

	Local dDtAtu   		:= SToD( "" )
	Local dDtASO   		:= SToD( "" )
	Local dDataEnv		:= SToD( "" )
	Local dEventoExc	:= SToD( '' )

	Local lRet	  		:= .T.
	Local lMudAmb       := .F.
	Local lExclu		:= nOper == 5 // Define se é exclusão de registro
	Local lGpea030		:= FWIsInCallStack( 'Gpea030' ) // Função
	Local lGpea010	    := IsInCallStack( "Gpea010" ) //Cadastro de Funcionário
	Local lIntegra

	Local nCont := 0

	Private cEmpDes 	:= cEmpAnt // Empresa destino (utilizado pelo GPEA180), inicia por padrão como a empresa atual
	Private cFilDes 	:= cFilAnt // Filial destino (utilizado pelo GPEA180), inicia por padrão como a filial atual
	Private cFilEnv 	:= "" // Filial de envio do TAF/Middleware
	Default cMsgInc 	:= ""
	Default cDescAtiv	:= ""

	Default oModel := Nil // Define modelo como nulo

	//Define o tamanho da régua de processamento, caso envio do evento S-2240
	If cEvento == "S-2240"
		ProcRegua( Len( aFuncs ) )
	EndIf

	//Passa por todos os funcionários, enviando ao SIGATAF/Middleware
	For nCont := 1 To Len( aFuncs )

		//Incrementa a régua, caso envio do evento S-2240
		If cEvento == "S-2240"
			IncProc()
		EndIf

		//---------------------------------------------------------------------------
		// Função genérica para posicionar na filial correta em chamadas específicas
		//---------------------------------------------------------------------------
		fPosFil( cEvento, IIf( Len( aFuncs[ nCont ] ) > 1 .And. aFuncs[ nCont, 2 ] <> Nil, aFuncs[ nCont, 2 ], "" ) )

		//------------------------------------------------------------------------------------
		// Caso for transferência (GPEA180) adiciona as informações da transferência do array
		//------------------------------------------------------------------------------------
		If lGPEA180
			aGPEA180 := aFuncs[ nCont, 7 ]

			cEmpDes := aGPEA180[ 1, 3 ]
			cFilDes := aGPEA180[ 1, 5 ]
		EndIf

		//----------------------------------------------------------------
		// Busca a filial de envio que será considerada no TAF/Middleware
		//----------------------------------------------------------------
		cFilEnv := MDTBFilEnv()

		lIntegra := .T. //Seta como .T. para enviar

		If cEvento == "S-2220"
			If FwIsInCallStack( 'NGIMPRASO' ) .Or. FwIsInCallStack( 'NG200IMP' ) .Or. FwIsInCallStack( 'fValAsoAdm' ) .Or. lGpea010
				dDtASO := IIf( Empty( TMY->TMY_DTEMIS ), dDataBase, TMY->TMY_DTEMIS )
				cTpASO := MDTTpASO( TMY->TMY_NATEXA ) //Busca o tipo do ASO conforme leiaute do eSocial
			Else
				dDtASO := M->TMY_DTEMIS
				cTpASO := MDTTpASO( M->TMY_NATEXA ) //Busca o tipo do ASO conforme leiaute do eSocial
			EndIf
		ElseIf cEvento == "S-2240" //Caso for evento de Risco

			If !lGpea030 // Busca data normalmente
				dDtAtu := MDTDtExpAtu( aFuncs[ nCont, 1 ] ) // Busca a data de exposição atual do evento S-2240
			Else // Caso evento a ser gerado for através da rotina de função procura o primeiro evento com a função atual
				dDtAtu := MdtEsoDatF( aFuncs[ nCont, 1 ] )[ 1 ]
			EndIf

			//Busca a data de envio a ser considerada no envio do evento S-2240
			dDataEnv := MDTBscDtEnv( aFuncs[ nCont ], nOper, , dDtAtu )

			// Busca a data do evento que será excluído pelo evento S-3000
			If nOper == 5
				dEventoExc := MDTBscDtEnv( aFuncs[ nCont ], 4, Nil, dDtAtu )
			EndIf

			cChvRJE := DToS( dDtAtu ) //Define a chave de busca do registro na tabela RJE

			lIntegra := !Empty( dDataEnv ) //Caso exista uma inclusão/alteração do período de exposição, envia ao Governo
		EndIf

		If lIntegra
			aDadFun := MDTDadFun( aFuncs[ nCont, 1 ], .T. ) //Busca as informações do funcionário
			//Posições do retorno
			//1- Matrícula
			//2- CPF
			//3- PIS
			//4- Código Único
			//5- Categoria
			//6- Data de Admissão

			//-----------------------------------------------------------------------
			// Realiza a verificação de existência de um registro predecessor no
			// TAF ou Middleware (RJE), para saber o tipo do envio a ser feito
			//-----------------------------------------------------------------------
			If lMiddleware //Caso for envio via Middleware

				If cEvento == "S-2210" //Caso for evento de CAT
					If lAcidente //Caso seja chamado pelo Acidente
						cStrChv := DtoS( oModel:GetValue( 'TNCMASTER', 'TNC_DTACID' ) ) + StrTran( oModel:GetValue( 'TNCMASTER', 'TNC_HRACID' ), ":", "" ) + oModel:GetValue( 'TNCMASTER', 'TNC_TIPCAT' )
					Else
						cStrChv := DtoS( TNC->TNC_DTACID ) + StrTran( TNC->TNC_HRACID, ":", "" ) + TNC->TNC_TIPCAT
					EndIf
				ElseIf cEvento == "S-2220" //Caso for evento de ASO
					cStrChv := DToS( dDtASO )
				ElseIf cEvento == "S-2240" //Caso for evento de Risco
					cStrChv := DToS( dDataEnv )
				EndIf

				If MDTVerTSVE( aDadFun[5] ) //Caso seja Trabalhador Sem Vínculo Estatutário
					cChvAtu := AllTrim( aDadFun[3] ) + AllTrim( aDadFun[5] ) + DToS( aDadFun[6] ) + cChvRJE
					cChvNov := AllTrim( aDadFun[3] ) + AllTrim( aDadFun[5] ) + DToS( aDadFun[6] ) + cStrChv
				Else
					cChvAtu := AllTrim( aDadFun[4] ) + cChvRJE
					cChvNov := AllTrim( IIf( lGPEA180, aGPEA180[ 1, 14 ], aDadFun[4] ) ) + cStrChv
				EndIf

				//Verifica condições das chaves
				If ( cEvento == "S-2210" .Or. cEvento == "S-2220" .And. nOper == 3 ) .Or. ( cEvento == "S-2240" .And. Empty( cChvRJE ) )
					cChvAtu := cChvNov
				EndIf

				If lMDTA165 .And. FindFunction( "fMudAmb" )
					lMudAmb := fMudAmb( aDadFun[ 1 ] ) //Verifica se mudou de ambiente físico
				EndIf

				If lMudAmb .And. nOper == 4 .And. dDataEnv != dDtAtu
					cChvAtu := AllTrim( aDadFun[4] ) + DToS( dDataEnv )
				EndIf
				
				lExstReg := MDTVerStat( .T., cEvtAux, cChvAtu, lExclu )

			Else //Caso for envio via SIGATAF

				If cEvento == "S-2210" //Caso for evento de CAT
					If lAcidente
						cStrChv := ";" + SubStr( cChvRJE, 1, 8 ) + ";" + SubStr( cChvRJE, 9, 4 ) + ";" + SubStr( cChvRJE, 13, 1 )
						cChvAtu := cChvRJE
						cChvNov := DtoS( oModel:GetValue( 'TNCMASTER', 'TNC_DTACID' ) ) + StrTran( oModel:GetValue( 'TNCMASTER', 'TNC_HRACID' ), ":", "" ) + oModel:GetValue( 'TNCMASTER', 'TNC_TIPCAT' )
					Else
						cStrChv := ";" + DtoS( TNC->TNC_DTACID ) + ";" + StrTran( TNC->TNC_HRACID, ":", "" ) + ";" + TNC->TNC_TIPCAT
						cChvAtu := DtoS( TNC->TNC_DTACID ) + StrTran( TNC->TNC_HRACID, ":", "" ) + TNC->TNC_TIPCAT
					EndIf
					nIndEsp := 4
				ElseIf cEvento == "S-2220" //Caso for evento de ASO
					cStrChv := ";" + cTpASO + ";" + DToS( dDtASO )
					cChvAtu := cTpASO + DToS( dDtASO )
					nIndEsp := 2
				ElseIf cEvento == "S-2240" //Caso for evento de Risco

					If nOper == 5
						cStrChv := ';' + DToS( dEventoExc )
						cChvAtu := DToS( dEventoExc )
					Else
						cStrChv := ';' + DToS( dDataEnv )
						cChvAtu := DToS( dDataEnv )
					EndIf

					nIndEsp := 5

				EndIf

				//Verifica o status do registro nas tabelas do SIGATAF
				lExstReg := TAFGetStat( cEvento, aDadFun[3] + aDadFun[4] + cStrChv, , cFilEnv, nIndEsp ) != "-1"

			EndIf

			//-----------------------------------------------------------------------
			// Verifica o tipo da operação que está sendo realizada
			// (3-Inclusão/4-Alteração/5-Exclusão) e carrega o Xml de acordo
			//-----------------------------------------------------------------------
			If nOper == 5 //Caso for exclusão de registro
				If lExstReg
					cXml := MDTM006( cEvtAux, aDadFun[1], cChvAtu )
				EndIf
			Else
				If nOper == 4 .And. !lExstReg //Caso for alteração de registro e o evento predecessor não exista, envia uma inclusão
					nOper := 3
				ElseIf nOper == 3 .And. lExstReg //Caso for inclusão de registro e o evento predecessor exista, envia uma alteração
					nOper := 4
				EndIf

				If cEvento == "S-2210" //Caso for evento de CAT
					cXml := MDTM002( nOper, , , oModel, cChvAtu, cChvNov, @cTAFKey ) //Carrega o Xml
				ElseIf cEvento == "S-2220" //Caso for evento de ASO
					cXml := MDTM003( nOper, , , cChvAtu ) //Carrega o Xml
				ElseIf cEvento == "S-2240" //Caso for evento de Risco
					cXml := MDTM004( aFuncs[ nCont, 1 ], nOper, dDataEnv, Nil, Nil, cChvAtu, aGPEA180, IIf( FWIsInCallStack( 'mdta090' ), aFuncs[ nCont, 6 ], Nil ), @cDescAtiv ) //Carrega o Xml
				EndIf
			EndIf

			//-----------------------------------------------------------------------
			// Realiza a integração do evento com o Governo, através do
			// SIGATAF ou do Middleware
			//-----------------------------------------------------------------------
			If !Empty( cXml ) //Caso tenha Xml a ser integrado

				//Caso o envio do evento for via Middleware
				If lMiddleware

					//Realiza o cadastro do evento na RJE
					aRetorno := MDTEnvMid( aDadFun[1], cEvtAux, cChvAtu, cChvNov, cXml, nOper )

					//Caso o retorno seja verdadeiro e seja o último funcionário enviado, emite a mensagem
					If !aRetorno[ 1, 1 ] .Or. nCont == Len( aFuncs )
						
						//Caso for execução automática
						If lExecAuto

							AutoGrLog( aRetorno[ 1, 2 ] )

						ElseIf lGPEA180 //Caso for GPEA180 a mensagem será retornada no log

							cMsgInc += CRLF + aRetorno[ 1, 2 ]

						Else

							Help( ' ', 1, STR0017, , aRetorno[ 1, 2 ], 2, 0 )

						EndIf

						//lRet recebe o retorno da MDTEnvMid
						lRet := aRetorno[ 1, 1 ]

					EndIf

				Else //Envia o evento ao eSocial através do SIGATAF
					
					//Caso for exclusão define o evento como sendo o S-3000
					If nOper == 5
						cEvtAux := "S3000"
					EndIf

					If cEvtAux == 'S2240' .And. lGPEA180 .And. cEmpAnt != cEmpDes // Caso for transferências entre empresas
						MDTChgEmp( aTbls, cEmpAnt, cEmpDes ) // Abre as tabelas do TAF na empresa destino
					EndIf

					//Integra o xml com o SIGATAF
					aRetorno := TafPrepInt( IIf( cEmpAnt != cEmpDes, cEmpDes, cEmpAnt ), cFilEnv, cXml, , "1", cEvtAux, , , , @aErros, , "MDT", , cTAFKey )

					If cEvtAux == 'S2240' .And. lGPEA180 .And. cEmpAnt != cEmpDes
						MDTChgEmp( aTbls, cEmpDes, cEmpBkp ) // Retorna as tabelas do TAF na empresa logada
					EndIf

					//Caso o retorno seja verdadeiro e seja o último funcionário enviado, emite a mensagem
					If Len( aRetorno ) > 0 .Or. nCont == Len( aFuncs )

						//Caso o retorno possua algum conteúdo significa que houve erro na integração
						If Len( aRetorno ) > 0

							//Caso for execução automática
							If lExecAuto

								AutoGrLog( STR0036 + CRLF + aRetorno[ 1 ] + CRLF + STR0037 )

							ElseIf lGPEA180 //Caso for GPEA180 a mensagem será retornada no log

								cMsgInc += CRLF + aRetorno[ 1 ]

							Else //Caso não for Transferências, emite a mensagem
								
								Help( ' ', 1, STR0017, , STR0036 + ':' + CRLF + CRLF + aErros[ 3 ] + ' - ' + aErros[ 4 ], 2, 0, , , , , , { STR0037 } )

							EndIf

							//Define o retorno como .F.
							lRet := .F.

						Else

							//Caso for execução automática
							If lExecAuto

								AutoGrLog( STR0034 + " (" + cEvtAux + ") " + STR0035 )
								lMsErroAuto := .F.

							ElseIf !lGPEA180 .And. IIf( IsInCallStack( "R465Imp" ), lMsgS2220, .T. ) //Caso não for transferência e caso seja impressão de ASO (verifica a variável de controle)

								Aviso( STR0017, STR0034 + " (" + cEvtAux + ") " + STR0035 + '.', { STR0047 }, 2 )

							EndIf

						EndIf

					EndIf

				EndIf

			EndIf

		EndIf

		//Caso tenha ocorrido erros durante a integração, interrompe o envio
		If !lRet
			Exit
		EndIf

	Next nCont

	//Retorna a empresa e filial
	cEmpAnt := cEmpBkp
	cFilAnt := cFilBkp
	cArqTab := cArqBkp

Return lRet

//---------------------------------------------------------------------
/*/{Protheus.doc} MDTGeraXml
Função genérica que realiza a exportação dos Xml's do eSocial para arquivos .xml

@sample	MDTGeraXml()

@author	Luis Fellipy Bett
@since	16/07/2018

@return	.T., Boolean, Sempre verdadeiro
/*/
//---------------------------------------------------------------------
Function MDTGeraXml()

	Local cMascara  	:= STR0040 //"Todos os arquivos|."
	Local cTitulo   	:= STR0041 //"Escolha o destino do arquivo"
	Local nMascpad  	:= 0
	Local cDirini   	:= "\"
	Local lSalvar   	:= .F. /*.F. = Salva || .T. = Abre*/
	Local nOpcoes   	:= GETF_LOCALHARD
	Local lArvore   	:= .F. /*.T. = apresenta o árvore do servidor || .F. = não apresenta*/
	Local lMDTA200		:= IsInCallStack( "MDTA200" ) //Cadastro de Atestado ASO
	Local lMDTA640		:= IsInCallStack( "MDTA640" ) //Cadastro de Acidentes
	Local dDtExp		:= SToD( "" )
	Local cArqPesq		:= ""
	Local cXml			:= ""
	Local cNumMat		:= ""
	Local cCodUnic		:= ""
	Local cFilArq		:= ""
	Local cChave		:= ""
	Local cChvRJE		:= ""
	Local lValid		:= .T.
	Local lFecha		:= .F.
	Local aDadFun		:= {}
	Local cDiretorio
	Local lSucess
	Local nHandle

	//Variáveis de parâmetro private, usadas em todo o processo de geração das informações
	Private lMiddleware	 := IIf( cPaisLoc == 'BRA' .And. Findfunction( "fVerMW" ), fVerMW(), .F. )
	Private dDtEsoc		 := SuperGetMv( "MV_NG2DTES", .F., SToD( "20211013" ) )
	Private cAtendAci	 := SuperGetMv( "MV_NG2IATE", .F., "3" )
	Private lGPEA010	 := IsInCallStack( "GPEA010" ) //Cadastro de Funcionário
	Private lExecAuto	 := .F. //Define o ExecAuto como .F.
	Private lAcidente	 := .F. //Define as variáveis utilizadas no MDTM002 como .F.
	Private lDiagnostico := .F. //Define as variáveis utilizadas no MDTM002 como .F.
	Private lAtestado	 := .F. //Define as variáveis utilizadas no MDTM002 como .F.
	Private lGPEA180	 := .F. //Define a variável de chamada da rotina de transferências como .F.
	Private lMDTA090	 := .F. //Define a variável de chamada da rotina de cadastro de tarefas como .F.
	Private lMDTA881	 := .F. //Define a variável de chamada da rotina de carga inicial como .F.
	Private lMDTA882	 := .F. //Define a variável de chamada da rotina de schedule de tarefas como .F.
	Private lMDTA165	 := .F. //Define a variável de chamada da rotina de cadastro de ambiente como .F.
	Private lMDTA180	 := .F. //Define a variável de chamada da rotina de cadastro de risco como .F.
	Private lMDTA125	 := .F. //Define a variável de chamada da rotina de cadastro de risco x EPI como .F.
	Private lMDTA130	 := .F. //Define a variável de chamada da rotina de cadastro de EPI x risco como .F.
	Private lMDTA181	 := .F. //Define a variável de chamada da rotina de cadastro de relacionamentos do risco como .F.
	Private lMDTA215	 := .F. //Define a variável de chamada da rotina de cadastro de laudos x risco como .F.
	Private lMDTA695	 := .F. //Define a variável de chamada da rotina de cadastro de funcionários x EPI como .F.
	Private lMDTA630	 := .F. //Define a variável de chamada da rotina de cadastro de EPI x funcionário como .F.
	Private lMATA185	 := .F. //Define a variável de chamada da rotina de cadastro de requisição ao estoque como .F.
	Private lGPEA370	 := .F. //Define a variável de chamada da rotina de cadastro de cargos como .F.
	Private cFilEnv		 := MDTBFilEnv() //Busca a filial de envio

	//----- Variáveis para busca de informações específicas para cada chamada ------
	If lGPEA010 //Variáveis de Busca dos Fatores de Risco

		cNumMat	 := SRA->RA_MAT
		cCodUnic := AllTrim( SRA->RA_CODUNIC )

	ElseIf lMDTA200 //Atestado ASO

		cNumMat	 := Posicione( "TM0", 1, xFilial( "TM0" ) + TMY->TMY_NUMFIC, "TM0_MAT" )
		cCodUnic := AllTrim( Posicione( "SRA", 1, xFilial( "SRA" ) + cNumMat, "RA_CODUNIC" ) )

		lValid := !Empty( Posicione( "TM0", 1, xFilial( "TM0" ) + TMY->TMY_NUMFIC, "TM0_MAT" ) )
		cMsgVld := STR0042 //"A geração de Xml para o eSocial são apenas para registros de funcionários"

	ElseIf lMDTA640 //Acidentes

		cNumMat	 := Posicione( "TM0", 1, xFilial( "TM0" ) + TNC->TNC_NUMFIC, "TM0_MAT" )
		cCodUnic := AllTrim( Posicione( "SRA", 1, xFilial( "SRA" ) + cNumMat, "RA_CODUNIC" ) )

		If !( lValid := !Empty( Posicione( "TM0", 1, xFilial( "TM0" ) + TNC->TNC_NUMFIC, "TM0_MAT" ) ) )
			cMsgVld := STR0042 //"A geração de Xml para o eSocial são apenas para registros de funcionários"
		ElseIf !( lValid := ( TNC->TNC_INDACI $ "1/2/3" ) )
			cMsgVld := STR0043 //"A geração de Xml para o eSocial são apenas para acidentes típicos, acidentes de trajeto ou doença do trabalho"
		EndIf

	EndIf

	//Validações anteriores a geração do Xml de acordo com cada chamada
	If !lValid
		Help( ' ', 1, STR0017, , cMsgVld, 2, 0 )
	Else

		If lGPEA010
			aOpcMnp := { STR0044, STR0045, STR0047 } //"Alteração"###"Inclusão"###"Fechar"
		Else
			aOpcMnp := { STR0046, STR0044, STR0045, STR0047 } //"Exclusão"###"Alteração"###"Inclusão"###"Fechar"
		EndIf

		nAviso := Aviso( STR0048, STR0049, aOpcMnp ) //"Geração Xml eSocial"###"Escolha o tipo de manipulação a ser considerada na geração do Xml"

		If lGPEA010
			Do Case
				Case nAviso == 1 ; nOpcMnp := 4
				Case nAviso == 2 ; nOpcMnp := 3
				Case nAviso == 3 ; lFecha := .T.
			End Case
		Else
			Do Case
				Case nAviso == 1 ; nOpcMnp := 5
				Case nAviso == 2 ; nOpcMnp := 4
				Case nAviso == 3 ; nOpcMnp := 3
				Case nAviso == 4 ; lFecha := .T.
			End Case
		EndIf

		If !lFecha
			cDiretorio := cGetFile( cMascara, cTitulo, nMascpad, cDirIni, lSalvar, nOpcoes, lArvore )
			cDiretorio := StrTran( cDiretorio, "\.", "\" )
		Else
			cDiretorio := ""
		EndIf

		If cDiretorio <> ""

			If lMDTA640 //S-2210 - Comunicação de Acidente de Trabalho

				cFilArq := StrTran( AllTrim( xFilial( "TNC" ) ), " ", "_" ) + "_"

				If nOpcMnp <> 5 //Se não for Xml de exclusão

					cChvRJE := DToS( TNC->TNC_DTACID ) + StrTran( TNC->TNC_HRACID, ":", "" ) + TNC->TNC_TIPCAT

					If MDTVldDad( "S-2210", nOpcMnp, { { cNumMat } }, .T. ) //Avalia as informações a serem enviadas
						cXml := MDTM002( nOpcMnp, , , , cChvRJE ) //Carrega o Xml
					EndIf

				Else
					//Busca as informações do funcionário
					aDadFun := MDTDadFun( cNumMat, .T. )

					If lMiddleware
						If MDTVerTSVE( aDadFun[5] ) //Caso seja Trabalhador Sem Vínculo Estatutário
							cChave := AllTrim( aDadFun[3] ) + AllTrim( aDadFun[5] ) + DToS( aDadFun[6] ) + DToS( TNC->TNC_DTACID ) + StrTran( TNC->TNC_HRACID, ":", "" ) + TNC->TNC_TIPCAT
						Else
							cChave := AllTrim( aDadFun[4] ) + DToS( TNC->TNC_DTACID ) + StrTran( TNC->TNC_HRACID, ":", "" ) + TNC->TNC_TIPCAT
						EndIf
					Else
						cChave := DtoS( TNC->TNC_DTACID ) + StrTran( TNC->TNC_HRACID, ":", "" ) + TNC->TNC_TIPCAT
					EndIf

					cXml := MDTM006( "S2210", cNumMat, cChave )
				EndIf

				cArqPesq := cFilArq + "evt_S-2210_" + DToS( Date() ) + "_" + StrTran( Time(), ":", "" ) + "_" + cCodUnic + DToS( TNC->TNC_DTACID ) + StrTran( TNC->TNC_HRACID, ":", "" ) + ".xml" //evt_S-2210_X_X_X.xml"

			ElseIf lMDTA200 //S-2220 - Monitoramento de Saúde do Trabalhador - Exame Ocupacional

				cFilArq := StrTran( AllTrim( xFilial( "TMY" ) ), " ", "_" ) + "_"

				If nOpcMnp <> 5 //Se não for Xml de exclusão

					cChvRJE := DToS( TMY->TMY_DTEMIS )

					If MDTVldDad( "S-2220", nOpcMnp, { { cNumMat } }, .T. ) //Avalia as informações a serem enviadas
						cXml := MDTM003( nOpcMnp, , , cChvRJE ) //Carrega o Xml
					EndIf

				Else
					//Busca as informações do funcionário
					aDadFun := MDTDadFun( cNumMat, .T. )

					If lMiddleware
						If MDTVerTSVE( aDadFun[5] ) //Caso seja Trabalhador Sem Vínculo Estatutário
							cChave := AllTrim( aDadFun[3] ) + AllTrim( aDadFun[5] ) + DToS( aDadFun[6] ) + DToS( TMY->TMY_DTEMIS )
						Else
							cChave := AllTrim( aDadFun[4] ) + DToS( TMY->TMY_DTEMIS )
						EndIf
					Else
						cChave := DToS( TMY->TMY_DTEMIS )
					EndIf

					cXml := MDTM006( "S2220", cNumMat, cChave )
				EndIf

				cArqPesq := cFilArq + "evt_S-2220_" + DToS( Date() ) + "_" + StrTran( Time(), ":", "" ) + "_" + cCodUnic + DToS( TMY->TMY_DTEMIS ) + ".xml" //evt_S-2220_X_X_X.xml"

			ElseIf lGPEA010 //S-2240 - Condições Ambientais de Trabalho - Fatores de Risco

				cFilArq := StrTran( AllTrim( xFilial( "SRA" ) ), " ", "_" ) + "_"

				cChvRJE := DToS( MDTDtExpAtu( cNumMat ) )

				If MDTVldDad( "S-2240", nOpcMnp, { { cNumMat } }, .T., , @dDtExp )
					cXml := MDTM004( cNumMat, nOpcMnp, dDtExp, , , cChvRJE )
				EndIf

				cArqPesq := cFilArq + "evt_S-2240_" + DToS( Date() ) + "_" + StrTran( Time(), ":", "" ) + "_" + AllTrim( cCodUnic ) + DToS( dDtExp ) + ".xml" //evt_S-2240_X_X_X.xml"

			EndIf

			//Caso exista Xml a ser gerado
			If !Empty( cXml )

				//Cria arquivo no diretório
				nHandle := FCREATE( cArqPesq, 0 )

				//----------------------------------------------------------------------------------
				// Verifica se o arquivo pode ser criado, caso contrario um alerta será exibido
				//----------------------------------------------------------------------------------
				If FERROR() <> 0
					Help( ' ', 1, STR0017, , STR0050 + " " + cArqPesq, 2, 0 )
					Return
				EndIf

				FWrite( nHandle, cXml ) //Escreve no arquivo

				FCLOSE( nHandle ) //Fecha o arquivo

				lSucess := CpyS2T( cArqPesq, cDiretorio ) //Copia o arquivo do server para o terminal

				If lSucess
					Help( ' ', 1, STR0017, , STR0051 + " " + "'" + cArqPesq + "'" + " " + STR0052 + " " + "'" + cDiretorio + "'", 2, 0 )
				Else
					Help( ' ', 1, STR0017, , STR0053 + " " + "'" + cArqPesq + "'", 2, 0 )
				Endif

				FERASE( cArqPesq )

			Else
				Help( ' ', 1, STR0017, , STR0053 + " " + "'" + cArqPesq + "'" + " " + STR0054, 2, 0 )
			EndIf

		EndIf
	EndIf

Return .T.

//---------------------------------------------------------------------
/*/{Protheus.doc} MDTSubTxt
Funcao que substitui os caracteres especiais por espacos

@return cImpLin Caracter Texto sem caracteres especiais

@sample MDTSubTxt( 'Olá' )

@param cTexto Caracter Texto a ser verificado

@author Jackson Machado
@since 28/01/2015
/*/
//---------------------------------------------------------------------
Function MDTSubTxt( cTexto )

	Local aAcentos	:= {}
	Local aAcSubst	:= {}
	Local cImpCar 	:= Space( 01 )
	Local cImpLin 	:= ""
	Local cAux 	  	:= ""
	Local cAux1	  	:= ""
	Local nTamTxt 	:= Len( cTexto )
	Local nCont
	Local nPos

	// Para alteracao/inclusao de caracteres, utilizar a fonte TERMINAL no IDE com o tamanho
	// maximo possivel para visualizacao dos mesmos.
	// Utilizar como referencia a tabela ASCII anexa a evidencia de teste (FNC 807/2009).

	aAcentos :=	{;
		Chr(199),Chr(231),Chr(196),Chr(197),Chr(224),Chr(229),Chr(225),Chr(228),Chr(170),;
		Chr(201),Chr(234),Chr(233),Chr(237),Chr(244),Chr(246),Chr(242),Chr(243),Chr(186),;
		Chr(250),Chr(097),Chr(098),Chr(099),Chr(100),Chr(101),Chr(102),Chr(103),Chr(104),;
		Chr(105),Chr(106),Chr(107),Chr(108),Chr(109),Chr(110),Chr(111),Chr(112),Chr(113),;
		Chr(114),Chr(115),Chr(116),Chr(117),Chr(118),Chr(120),Chr(122),Chr(119),Chr(121),;
		Chr(065),Chr(066),Chr(067),Chr(068),Chr(069),Chr(070),Chr(071),Chr(072),Chr(073),;
		Chr(074),Chr(075),Chr(076),Chr(077),Chr(078),Chr(079),Chr(080),Chr(081),Chr(082),;
		Chr(083),Chr(084),Chr(085),Chr(086),Chr(088),Chr(090),Chr(087),Chr(089),Chr(048),;
		Chr(049),Chr(050),Chr(051),Chr(052),Chr(053),Chr(054),Chr(055),Chr(056),Chr(057),;
		Chr(038),Chr(195),Chr(212),Chr(211),Chr(205),Chr(193),Chr(192),Chr(218),Chr(220),;
		Chr(213),Chr(245),Chr(227),Chr(252),Chr(210),Chr(202);
		}

	aAcSubst :=	{;
		"C","c","A","A","a","a","a","a","a",;
		"E","e","e","i","o","o","o","o","o",;
		"u","a","b","c","d","e","f","g","h",;
		"i","j","k","l","m","n","o","p","q",;
		"r","s","t","u","v","x","z","w","y",;
		"A","B","C","D","E","F","G","H","I",;
		"J","K","L","M","N","O","P","Q","R",;
		"S","T","U","V","X","Z","W","Y","0",;
		"1","2","3","4","5","6","7","8","9",;
		"E","A","O","O","I","A","A","U","U",;
		"O","o","a","u","O","E";
		}

	For nCont := 1 To Len( AllTrim( cTexto ) )
		cImpCar	:= SubStr( cTexto, nCont, 1 )
		//-- Nao pode sair com 2 espacos em branco.
		cAux	:= Space( 01 )
		nPos 	:= 0
		nPos 	:= Ascan( aAcentos, cImpCar )
		If nPos > 0
			cAux := aAcSubst[ nPos ]
		Elseif ( cAux1 == Space( 1 ) .And. cAux == Space( 1 ) ) .Or. Len( cAux1 ) == 0
			cAux :=	""
		EndIf
		cAux1 	:= cAux
		cImpCar	:= cAux
		cImpLin	:= cImpLin + cImpCar

	Next nCont

	//--Volta o texto no tamanho original
	cImpLin := Left( cImpLin + Space( nTamTxt ), nTamTxt )

Return cImpLin

//-------------------------------------------------------------------
/*/{Protheus.doc} MDTObriEsoc
Realiza verificação dos campos obrigatórios nos seus respectivos
cadastros, para não haver inconsistências no envio ao TAF

@author  Luis Fellipy Bett
@since   25/07/2018

@param   cTabela	- Caracter	- Indica as Tabelas que serão verificadas

@return lRet, Boolean, Retorna .T. ou .F. de acordo com as verificações dos campos
/*/
//-------------------------------------------------------------------
Function MDTObriEsoc( cTabela, lDelete, oModel )

	Local cIncEsoc	:= SuperGetMv( "MV_NG2AVIS", .F., "1" )
	Local leSocial	:= IIf( FindFunction( "MDTVldEsoc" ), MDTVldEsoc(), .F. )
	Local aCposInc	:= {}
	Local lRet		:= .T.
	Local cMsg		:= ""
	Local nCont		:= 0

	Default lDelete := .F.

	//Se é pra mostrar a mensagem e/ou impedir o processo
	If leSocial .And. cIncEsoc <> "2" .And. !lDelete

		If "TNC" $ cTabela //MDTA640 - Acidentes
			//Data do Acidente
			If TNC->( ColumnPos( "TNC_DTACID" ) ) > 0 .And. Empty( oModel:GetValue( "TNCMASTER", "TNC_DTACID" ) )
				aAdd( aCposInc, { NGRETTITULO( "TNC_DTACID" ) } )
			EndIf

			//Hora do Acidente
			If TNC->( ColumnPos( "TNC_HRACID" ) ) > 0 .And. oModel:GetValue( "TNCMASTER", "TNC_INDACI" ) == "1" .And. ( Empty( oModel:GetValue( "TNCMASTER", "TNC_HRACID" ) ) .Or. AllTrim( oModel:GetValue( "TNCMASTER", "TNC_HRACID" ) ) == ":" )
				aAdd( aCposInc, { NGRETTITULO( "TNC_HRACID" ) } )
			EndIf

			//Horas Trabalhadas Anteriormente ao Acidente
			If TNC->( ColumnPos( "TNC_HRTRAB" ) ) > 0 .And. oModel:GetValue( "TNCMASTER", "TNC_INDACI" ) == "1" .And. ( Empty( oModel:GetValue( "TNCMASTER", "TNC_HRTRAB" ) ) .Or. AllTrim( oModel:GetValue( "TNCMASTER", "TNC_HRTRAB" ) ) == ":" )
				aAdd( aCposInc, { NGRETTITULO( "TNC_HRTRAB" ) } )
			EndIf

			//Tipo de CAT
			If TNC->( ColumnPos( "TNC_TIPCAT" ) ) > 0 .And. Empty( oModel:GetValue( "TNCMASTER", "TNC_TIPCAT" ) )
				aAdd( aCposInc, { NGRETTITULO( "TNC_TIPCAT" ) } )
			EndIf

			//Indicação de Óbito
			If TNC->( ColumnPos( "TNC_MORTE" ) ) > 0 .And. Empty( oModel:GetValue( "TNCMASTER", "TNC_MORTE" ) )
				aAdd( aCposInc, { NGRETTITULO( "TNC_MORTE" ) } )
			EndIf

			//Data do Óbito
			If TNC->( ColumnPos( "TNC_DTOBIT" ) ) > 0 .And. oModel:GetValue( "TNCMASTER", "TNC_MORTE" ) == "1" .And. Empty( oModel:GetValue( "TNCMASTER", "TNC_DTOBIT" ) )
				aAdd( aCposInc, { NGRETTITULO( "TNC_DTOBIT" ) } )
			EndIf

			//Indicativo de Comunicação à Autoridade Policial
			If TNC->( ColumnPos( "TNC_POLICI" ) ) > 0 .And. Empty( oModel:GetValue( "TNCMASTER", "TNC_POLICI" ) )
				aAdd( aCposInc, { NGRETTITULO( "TNC_POLICI" ) } )
			EndIf

			//Código do Tipo do Acidnte - Utilizado para busca dos códigos da situação geradora do acidente na tabela TNG
			If TNC->( ColumnPos( "TNC_TIPACI" ) ) > 0 .And. Empty( oModel:GetValue( "TNCMASTER", "TNC_TIPACI" ) )
				aAdd( aCposInc, { NGRETTITULO( "TNC_TIPACI" ) } )
			EndIf

			//Tipo de Local do Acidente
			If TNC->( ColumnPos( "TNC_INDLOC" ) ) > 0 .And. Empty( oModel:GetValue( "TNCMASTER", "TNC_INDLOC" ) )
				aAdd( aCposInc, { NGRETTITULO( "TNC_INDLOC" ) } )
			EndIf

			//Descrição do Logradouro
			If TNC->( ColumnPos( "TNC_DESLOG" ) ) > 0 .And. Empty( oModel:GetValue( "TNCMASTER", "TNC_DESLOG" ) )
				aAdd( aCposInc, { NGRETTITULO( "TNC_DESLOG" ) } )
			EndIf

			//Indicativo de Internação
			If TNC->( ColumnPos( "TNC_INTERN" ) ) > 0 .And. !Empty( oModel:GetValue( "TNCMASTER", "TNC_DTATEN" ) ) .And. !Empty( oModel:GetValue( "TNCMASTER", "TNC_HRATEN" ) ) .And. Empty( oModel:GetValue( "TNCMASTER", "TNC_INTERN" ) )
				aAdd( aCposInc, { NGRETTITULO( "TNC_INTERN" ) } )
			EndIf

			//Duração do Tratamento
			If TNC->( ColumnPos( "TNC_QTAFAS" ) ) > 0 .And. !Empty( oModel:GetValue( "TNCMASTER", "TNC_DTATEN" ) ) .And. !Empty( oModel:GetValue( "TNCMASTER", "TNC_HRATEN" ) ) .And. Empty( oModel:GetValue( "TNCMASTER", "TNC_QTAFAS" ) ) .And. oModel:GetValue( "TNCMASTER", "TNC_AFASTA" ) != "2"
				aAdd( aCposInc, { NGRETTITULO( "TNC_QTAFAS" ) } )
			EndIf

			//Indicativo de Afastamento
			If TNC->( ColumnPos( "TNC_AFASTA" ) ) > 0 .And. !Empty( oModel:GetValue( "TNCMASTER", "TNC_DTATEN" ) ) .And. !Empty( oModel:GetValue( "TNCMASTER", "TNC_HRATEN" ) ) .And. Empty( oModel:GetValue( "TNCMASTER", "TNC_AFASTA" ) )
				aAdd( aCposInc, { NGRETTITULO( "TNC_AFASTA" ) } )
			EndIf

			//Código da Natureza da Lesão - Utilizado para busca do código da natureza da lesão na tabela TOJ
			If TNC->( ColumnPos( "TNC_CODLES" ) ) > 0 .And. !Empty( oModel:GetValue( "TNCMASTER", "TNC_DTATEN" ) ) .And. !Empty( oModel:GetValue( "TNCMASTER", "TNC_HRATEN" ) ) .And. Empty( oModel:GetValue( "TNCMASTER", "TNC_CODLES" ) )
				aAdd( aCposInc, { NGRETTITULO( "TNC_CODLES" ) } )
			EndIf

			//CID
			If TNC->( ColumnPos( "TNC_CID" ) ) > 0 .And. !Empty( oModel:GetValue( "TNCMASTER", "TNC_DTATEN" ) ) .And. !Empty( oModel:GetValue( "TNCMASTER", "TNC_HRATEN" ) ) .And. Empty( oModel:GetValue( "TNCMASTER", "TNC_CID" ) )
				aAdd( aCposInc, { NGRETTITULO( "TNC_CID" ) } )
			EndIf
		EndIf

		If "TNG" $ cTabela //MDTA600 - Tipos de Acidentes
			//Código eSocial do Tipo do Acidente
			If X3USO( GetSx3Cache( "TNG_ESOC", "X3_USADO" ) )
				If TNG->( ColumnPos( "TNG_ESOC" ) ) > 0 .And. Empty( oModel:GetValue( "TNG_ESOC" ) )
					aAdd( aCposInc, { NGRETTITULO( "TNG_ESOC" ) } )
				EndIf
			Else
				If TNG->( ColumnPos( "TNG_ESOC1" ) ) > 0 .And. Empty( oModel:GetValue( "TNG_ESOC1" ) )
					aAdd( aCposInc, { NGRETTITULO( "TNG_ESOC1" ) } )
				EndIf
			EndIf
		EndIf

		If "TOI" $ cTabela //MDTA603 - Parte do Corpo Atingida
			//Código eSocial da Parte do Corpo Atingida
			If TOI->( ColumnPos( "TOI_ESOC" ) ) > 0 .And. Empty( oModel:GetValue( "TOI_ESOC" ) )
				aAdd( aCposInc, { NGRETTITULO( "TOI_ESOC" ) } )
			EndIf
		EndIf

		If "TNH" $ cTabela //MDTA605 - Objeto Causador
			//Código eSocial do Objeto Causador
			If TNH->( ColumnPos( "TNH_ESOC" ) ) > 0 .And. Empty( oModel:GetValue( "TNH_ESOC" ) )
				aAdd( aCposInc, { NGRETTITULO( "TNH_ESOC" ) } )
			EndIf
		EndIf

		If "TOJ" $ cTabela //MDTA604 - Natureza da Lesão do Acidente
			//Código eSocial da Natureza da Lesão
			If TOJ->( ColumnPos( "TOJ_ESOC" ) ) > 0 .And. Empty( oModel:GetValue( "TOJ_ESOC" ) )
				aAdd( aCposInc, { NGRETTITULO( "TOJ_ESOC" ) } )
			EndIf
		EndIf

		If "TMK" $ cTabela //MDTA070 - Usuários
			//Nome do Médico
			If TMK->( ColumnPos( "TMK_NOMUSU" ) ) > 0 .And. Empty( M->TMK_NOMUSU )
				aAdd( aCposInc, { NGRETTITULO( "TMK_NOMUSU" ) } )
			EndIf

			//Órgão de Classe
			If TMK->( ColumnPos( "TMK_ENTCLA" ) ) > 0 .And. Empty( M->TMK_ENTCLA )
				aAdd( aCposInc, { NGRETTITULO( "TMK_ENTCLA" ) } )
			EndIf

			//Número de Inscrição do Órgão de Classe
			If TMK->( ColumnPos( "TMK_NUMENT" ) ) > 0 .And. Empty( M->TMK_NUMENT )
				aAdd( aCposInc, { NGRETTITULO( "TMK_NUMENT" ) } )
			EndIf

			//UF do Órgão de Classe
			If TMK->( ColumnPos( "TMK_UF" ) ) > 0 .And. Empty( M->TMK_UF )
				aAdd( aCposInc, { NGRETTITULO( "TMK_UF" ) } )
			EndIf
		EndIf

		If "TNP" $ cTabela //MDTA680 - Emitentes de Atestados
			//Nome do Médico
			If TNP->( ColumnPos( "TNP_NOME" ) ) > 0 .And. Empty( oModel:GetValue( "TNP_NOME" ) )
				aAdd( aCposInc, { NGRETTITULO( "TNP_NOME" )	} )
			EndIf

			//Órgão de Classe
			If TNP->( ColumnPos( "TNP_ENTCLA" ) ) > 0 .And. Empty( oModel:GetValue( "TNP_ENTCLA" ) )
				aAdd( aCposInc, { NGRETTITULO( "TNP_ENTCLA" ) } )
			EndIf

			//Número de Inscrição do Órgão de Classe
			If TNP->( ColumnPos( "TNP_NUMENT" ) ) > 0 .And. Empty( oModel:GetValue( "TNP_NUMENT" ) )
				aAdd( aCposInc, { NGRETTITULO( "TNP_NUMENT" ) } )
			EndIf

			//UF do Órgão de Classe
			If TNP->( ColumnPos( "TNP_UF" ) ) > 0 .And. Empty( oModel:GetValue( "TNP_UF" ) )
				aAdd( aCposInc, { NGRETTITULO( "TNP_UF" ) } )
			EndIf
		EndIf

		If "TMY" $ cTabela //MDTA200 - Atestado ASO
			//Natureza do ASO
			If TMY->( ColumnPos( "TMY_NATEXA" ) ) > 0 .And. Empty( M->TMY_NATEXA )
				aAdd( aCposInc, { NGRETTITULO( "TMY_NATEXA" )	} )
			EndIf

			//Parecer do Médico
			If TMY->( ColumnPos( "TMY_INDPAR" ) ) > 0 .And. Empty( M->TMY_INDPAR )
				aAdd( aCposInc, { NGRETTITULO( "TMY_INDPAR" )	} )
			EndIf

			//Tipo do Exame
			If TMY->( ColumnPos( "TMY_INDEXA" ) ) > 0 .And. Empty( M->TMY_INDEXA )
				aAdd( aCposInc, { NGRETTITULO( "TMY_INDEXA" )	} )
			EndIf
		EndIf

		If "TM4" $ cTabela //MDTA020 - Exames
			//Procedimento Realizado
			If TM4->( ColumnPos( "TM4_PROCRE" ) ) > 0 .And. Empty( M->TM4_PROCRE )
				aAdd( aCposInc, { NGRETTITULO( "TM4_PROCRE" ) } )
			EndIf
		EndIf

		If "TNE" $ cTabela //MDTA165 - Ambientes de Trabalho
			//Local do Ambiente
			If TNE->( ColumnPos( "TNE_LOCAMB" ) ) > 0 .And. Empty( oModel:GetValue( "TNE_LOCAMB" ) )
				aAdd( aCposInc, { NGRETTITULO( "TNE_LOCAMB" ) } )
			EndIf

			//Descrição do Ambiente
			If TNE->( ColumnPos( "TNE_MEMODS" ) ) > 0 .And. Empty( oModel:GetValue( "TNE_MEMODS" ) )
				aAdd( aCposInc, { NGRETTITULO( "TNE_MEMODS" ) } )
			EndIf

			//Tipo de Inscrição do Ambiente
			If TNE->( ColumnPos( "TNE_TPINS" ) ) > 0 .And. Empty( oModel:GetValue( "TNE_TPINS" ) )
				aAdd( aCposInc, { NGRETTITULO( "TNE_TPINS" ) } )
			EndIf

			//Número de Inscrição do Ambiente
			If TNE->( ColumnPos( "TNE_NRINS" ) ) > 0 .And. Empty( oModel:GetValue( "TNE_NRINS" ) )
				aAdd( aCposInc, { NGRETTITULO( "TNE_NRINS" ) } )
			EndIf
		EndIf

		If "TMA" $ cTabela //MDTA182 - Agentes
			//Descrição do Agente
			If TMA->( ColumnPos( "TMA_DESCRI" ) ) > 0 .And. !Empty( M->TMA_ESOC ) .And. M->TMA_ESOC $ "01.01.001/01.02.001/01.03.001/01.04.001/01.05.001/01.06.001/01.07.001/01.08.001/01.09.001/01.10.001/01.12.001/01.13.001/01.14.001/01.15.001/01.16.001/01.17.001/01.18.001/05.01.001" .And. Empty( M->TMA_DESCRI )
				aAdd( aCposInc, { NGRETTITULO( "TMA_DESCRI" ) } )
			EndIf

			//Tipo de Avaliação do Agente
			If TMA->( ColumnPos( "TMA_AVALIA" ) ) > 0 .And. !Empty( M->TMA_ESOC ) .And. M->TMA_ESOC <> "09.01.001" .And. Empty( M->TMA_AVALIA )
				aAdd( aCposInc, { NGRETTITULO( "TMA_AVALIA" ) } )
			EndIf
		EndIf

		If "TN0" $ cTabela //MDTA180 - Riscos
			If Posicione( "TMA", 1, xFilial( "TMA" ) + M->TN0_AGENTE, "TMA_AVALIA" ) == "1"
				//Unidade de Medida
				If TN0->( ColumnPos( "TN0_UNIMED" ) ) > 0 .And. Empty( M->TN0_UNIMED )
					aAdd( aCposInc, { NGRETTITULO( "TN0_UNIMED" ) } )
				EndIf

				//Técnica de Medição
				If TN0->( ColumnPos( "TN0_TECUTI" ) ) > 0 .And. Empty( M->TN0_TECUTI )
					aAdd( aCposInc, { NGRETTITULO( "TN0_TECUTI" ) } )
				EndIf
			EndIf
		EndIf

		If "TMT" $ cTabela //MDTA155 - Diagnóstico Médico
			//Data do Atendimento
			If TMT->( ColumnPos( "TMT_DTATEN" ) ) > 0 .And. !Empty( M->TMT_ACIDEN ) .And. Empty( M->TMT_DTATEN )
				aAdd( aCposInc, { NGRETTITULO( "TMT_DTATEN" ) } )
			EndIf

			//Hora do Atendimento
			If TMT->( ColumnPos( "TMT_HRATEN" ) ) > 0 .And. !Empty( M->TMT_ACIDEN ) .And. ( Empty( M->TMT_HRATEN ) .Or. AllTrim( M->TMT_HRATEN ) == ":" )
				aAdd( aCposInc, { NGRETTITULO( "TMT_HRATEN" ) } )
			EndIf

			//CID
			If TMT->( ColumnPos( "TMT_CID" ) ) > 0 .And. !Empty( M->TMT_ACIDEN ) .And. Empty( M->TMT_CID )
				aAdd( aCposInc, { NGRETTITULO( "TMT_CID" ) } )
			EndIf
		EndIf

		If "TNY" $ cTabela //MDTA685 - Atestado Médico
			//Hora da Consulta/Atendimento
			If TNY->( ColumnPos( "TNY_DTCONS" ) ) > 0 .And. !Empty( oModel:GetValue( "TNYMASTER1", "TNY_ACIDEN" ) ) .And. Empty( oModel:GetValue( "TNYMASTER1", "TNY_DTCONS" ) )
				aAdd( aCposInc, { NGRETTITULO( "TNY_DTCONS" ) } )
			EndIf

			//Hora da Consulta/Atendimento
			If TNY->( ColumnPos( "TNY_HRCONS" ) ) > 0 .And. !Empty( oModel:GetValue( "TNYMASTER1", "TNY_ACIDEN" ) ) .And. ( Empty( oModel:GetValue( "TNYMASTER1", "TNY_HRCONS" ) ) .Or. AllTrim( oModel:GetValue( "TNYMASTER1", "TNY_HRCONS" ) ) == ":" )
				aAdd( aCposInc, { NGRETTITULO( "TNY_HRCONS" ) } )
			EndIf

			//CID
			If TNY->( ColumnPos( "TNY_CID" ) ) > 0 .And. !Empty( oModel:GetValue( "TNYMASTER1", "TNY_ACIDEN" ) ) .And. Empty( oModel:GetValue( "TNYMASTER1", "TNY_CID" ) )
				aAdd( aCposInc, { NGRETTITULO( "TNY_CID" ) } )
			EndIf
		EndIf

		//Caso existam campos obrigtórios ao eSocial não preenchidos
		If Len( aCposInc ) > 0

			If cIncEsoc == "0"

				cMsg := STR0055 //"Os campos abaixo são de importância para a consistência das informações que serão enviadas ao eSocial"
				For nCont := 1 To Len( aCposInc )
					cMsg += CRLF + "- " + aCposInc[ nCont, 1 ]
				Next nCont

				If !( lRet := MsgYesNo( cMsg + CRLF + STR0056, STR0017 ) )
					Help( ' ', 1, STR0017, , cMsg, 2, 0, , , , , , { STR0057 } )
				EndIf

			ElseIf cIncEsoc == "1"

				cMsg := STR0055 //"Os campos abaixo são de importância para a consistência das informações que serão enviadas ao eSocial"
				For nCont := 1 To Len( aCposInc )
					cMsg += CRLF + "- " + aCposInc[ nCont, 1 ]
				Next nCont
				Help( ' ', 1, STR0017, , cMsg, 2, 0, , , , , , { STR0057 } )
				lRet := .F.

			EndIf
		EndIf
	EndIf

Return lRet

//---------------------------------------------------------------------
/*/{Protheus.doc} MDTGetFunc
Busca todos os funcionários cadastrados

@return aFuncs

@sample MDTGetFunc()

@author Luis Fellipy Bett
@since 09/10/2018
/*/
//---------------------------------------------------------------------
Function MDTGetFunc()

	//Variáveis de busca das informações
	Local aFuncs := {}
	Local lMDTA881 := IsInCallStack( "MDTA881" ) //Caso for chamada pela carga inicial
	
	//Variáveis de tabela temporária
	Local cAliasTmp := GetNextAlias()

	//Variáveis de montagem da tabela temporária
	Local aFields  := { { "FILIAL", "C", FWSizeFilial(), 0 } }
	Local cNameTab := ""
	Local oTmpFil

	//-------------------------------------------------
	// Cria a tabela temporária para salvar as filiais
	//-------------------------------------------------
	oTmpFil := FWTemporaryTable():New( cAliasTmp )
	
	//Define a tabela
	oTmpFil:SetFields( aFields )
	oTmpFil:AddIndex( "01", { "FILIAL" } )
	oTmpFil:Create()

	//Pega o nome da tabela do banco
	cNameTab := oTmpFil:GetRealName()

	//-----------------------------------------------------------------
	// Busca as filiais a serem consideradas na busca dos funcionários
	//-----------------------------------------------------------------
	If lMDTA881
		Processa( { || fGetFilFun( cAliasTmp, lMDTA881 ) }, STR0091 ) //"Aguarde, buscando as filiais..."
	Else
		fGetFilFun( cAliasTmp, lMDTA881 )
	EndIf

	//-----------------------
	// Busca os funcionários
	//-----------------------
	If lMDTA881
		Processa( { || fGetFun( cNameTab, @aFuncs, lMDTA881 ) }, STR0092 ) //"Aguarde, buscando os funcionários..."
	Else
		fGetFun( cNameTab, @aFuncs, lMDTA881 )
	EndIf

	//Deleta a tabela temporária
	oTmpFil:Delete()

Return aFuncs

//---------------------------------------------------------------------
/*/{Protheus.doc} fGetFilFun
Busca as filiais que deverão ser consideradas na busca dos funcionários

@return Nil, Nulo

@param	cAliasTmp, Caractere, Tabela temporária a ser alimentada na função

@sample fGetFilFun( "SGC" )

@author	Luis Fellipy Bett
@since	03/03/2022
/*/
//---------------------------------------------------------------------
Static Function fGetFilFun( cAliasTmp, lMDTA881 )

	//Variáveis de busca das informações
	Local lAllFil := SuperGetMv( "MV_NG2BLEV", .F., "ToFil", Space( Len( xFilial( "SRA" ) ) ) ) <> "ToFil"
	Local aFilSRA := {}
	Local cExpQry := ""

	//Variáveis de contadores
	Local nCont := 0
	
	//Variáveis de tabelas temporárias
	Local cAliasSM0 := ""
	
	//Caso for dicionário na base
	If MPDicInDB()
	
		//Pega o próximo alias
		cAliasSM0 := GetNextAlias()

		//----------------------------------------------------------------------
		// Verifica se busca os funcionários da empresa inteira ou só da filial
		//----------------------------------------------------------------------
		If lAllFil
			cExpQry := "%M0_CODIGO = '" + cEmpAnt + "'%"
		Else
			cExpQry := "%M0_CODFIL = '" + cFilAnt + "'%"
		EndIf

		//Busca as filiais da SM0
		BeginSQL Alias cAliasSM0
			SELECT M0_CODFIL FROM %Table:SM0% SM0
				WHERE %Exp:cExpQry%
				AND SM0.%notDel%
		EndSQL

		//Adiciona as filiais retornadas da query na tabela temrporária
		dbSelectArea( cAliasSM0 )
		( cAliasSM0 )->( dbGoTop() )

		//Caso for carga inicial, define a régua de processamento
		If lMDTA881
			ProcRegua( RecCount() )
		EndIf
		
		While ( cAliasSM0 )->( !Eof() )

			//Caso for carga inicial, incrementa a régua de processamento
			If lMDTA881
				IncProc()
			EndIf

			RecLock( cAliasTmp, .T. )
				( cAliasTmp )->FILIAL := xFilial( "SRA", ( cAliasSM0 )->M0_CODFIL )
			( cAliasTmp )->( MsUnlock() )

			dbSelectArea( cAliasSM0 )
			( cAliasSM0 )->( dbSkip() )
		End

		//Fecha a tabela temporária da SM0
		( cAliasSM0 )->( dbCloseArea() )

	Else //Caso for dicionário na system

		//Busca as filiais do sistema
		aFilSRA := FwLoadSM0()

		//Caso for carga inicial, define a régua de processamento
		If lMDTA881
			ProcRegua( Len( aFilSRA ) )
		EndIf

		//Percorre as filiais validando
		For nCont := 1 To Len( aFilSRA )

			//Caso for carga inicial, incrementa a régua de processamento
			If lMDTA881
				IncProc()
			EndIf

			//----------------------------------------------------------------------
			// Verifica se busca os funcionários da empresa inteira ou só da filial
			//----------------------------------------------------------------------
			If ( lAllFil .And. aFilSRA[ nCont, 1 ] == cEmpAnt ) .Or. ;
				( !lAllFil .And. aFilSRA[ nCont, 2 ] == cFilAnt )

				RecLock( cAliasTmp, .T. )
					( cAliasTmp )->FILIAL := xFilial( "SRA", aFilSRA[ nCont, 2 ] )
				( cAliasTmp )->( MsUnlock() )

			EndIf

		Next nCont

	EndIf

Return

//---------------------------------------------------------------------
/*/{Protheus.doc} fGetFun
Busca os funcionários que deverão ser integrados

@return Nil, Nulo

@param	cNameTab, Caractere, Nome da tabela temporária no banco de dados

@sample fGetFun( "SGC" )

@author	Luis Fellipy Bett
@since	03/03/2022
/*/
//---------------------------------------------------------------------
Static Function fGetFun( cNameTab, aFuncs, lMDTA881 )

	//Variáveis de tabela temporária
	Local cAliasSRA	:= GetNextAlias()

	BeginSQL Alias cAliasSRA
		SELECT SRA.RA_FILIAL, SRA.RA_MAT FROM %Table:SRA% SRA
			WHERE SRA.RA_FILIAL IN (
				SELECT FILIAIS.FILIAL
					FROM %temp-table:cNameTab% FILIAIS
			)
			AND SRA.RA_SITFOLH <> 'D'
			AND SRA.RA_DEMISSA = %Exp:SToD(Space(8))%
			AND SRA.%notDel%
	EndSQL

	dbSelectArea( cAliasSRA )
	( cAliasSRA )->( dbGoTop() )

	//Caso for carga inicial, define a régua de processamento
	If lMDTA881
		ProcRegua( RecCount() )
	EndIf

	While ( cAliasSRA )->( !EoF() )

		//Caso for carga inicial, incrementa a régua de processamento
		If lMDTA881
			IncProc()
		EndIf

		aAdd( aFuncs, { ( cAliasSRA )->RA_MAT, ( cAliasSRA )->RA_FILIAL } )

		( cAliasSRA )->( dbSkip() )

	End

	//Fecha a tabela temporária do SRA
	( cAliasSRA )->( dbCloseArea() )

Return

//---------------------------------------------------------------------
/*/{Protheus.doc} MdtVldRis
Valida se o Risco será enviado para o TAF

@return lRet, Boolean, .T. caso o risco deva ser enviado ao SIGATAF/Middleware

@sample MdtVldRis()

@param [dDtRet], Date, Identifica a data de referência para busca do PPRA

@author Luis Fellipy Bett
@since 09/10/2018
/*/
//---------------------------------------------------------------------
Function MdtVldRis( dDtRef, lRisCad )

	Local aArea	   := GetArea() //Salva a área
	Local cRisTAF  := SuperGetMv( "MV_NG2RIST", .F., "3" )
	Local lVldPPRA := SuperGetMv( "MV_NG2VLAU", .F., "2" ) == "1"
	Local lRisEPI  := IsInCallStack( "fVldEPIFun" ) .And. lVldEPI
	Local lRet     := .T.

	//Define o valor padrão para os parâmetros
	Default dDtRef	:= dDataBase
	Default lRisCad	:= .F.

	//-------------------------------------------------------------------------------------------------------------------------------------
	// Caso for cadastro de risco e estiver validando o risco que está sendo alterado, seta .F. pois a validação será feita posteriormente
	//-------------------------------------------------------------------------------------------------------------------------------------
	If lMDTA180 .And. !lRisCad .And. M->TN0_NUMRIS == TN0->TN0_NUMRIS
		lRet := .F.
	EndIf

	//---------------------------------------------------------------
	// Caso deva validar se o risco necessita da utilização de EPI's
	//---------------------------------------------------------------
	If lRet .And. lRisEPI
		lRet := IIf( lRisCad, M->TN0_NECEPI, TN0->TN0_NECEPI ) == "1"
	EndIf

	//----------------------------------------------------------
	// Valida se o funcionário está exposto ao risco no período
	//----------------------------------------------------------
	If lRet .And. ( ( !Empty( SRA->RA_DEMISSA ) .And. IIf( lRisCad, M->TN0_DTRECO, TN0->TN0_DTRECO ) >= SRA->RA_DEMISSA ) .Or. ;
		( !Empty( IIf( lRisCad, M->TN0_DTELIM, TN0->TN0_DTELIM ) ) .And. ( IIf( lRisCad, M->TN0_DTELIM, TN0->TN0_DTELIM ) <= dDtRef .Or. IIf( lRisCad, M->TN0_DTELIM, TN0->TN0_DTELIM ) <= dDtEsoc ) ) .Or. ;
		( Empty( IIf( lRisCad, M->TN0_DTAVAL, TN0->TN0_DTAVAL ) ) ) )
		lRet := .F.
	EndIf

	//-------------------------------------------------------------------
	// Valida se o agente do risco está definido no parâmetro para envio
	//-------------------------------------------------------------------
	If lRet
		// Valida se busca os riscos não obrigatórios
		// MV_NG2RIST - 0 - Nenhum
		// MV_NG2RIST - 1 - Somente Ergonomicos
		// MV_NG2RIST - 2 - Somente Acidentes\Mecânicos
		// MV_NG2RIST - 3 - Somente Ergonomicos\Acidentes\Mecânicos
		// MV_NG2RIST - 4 - Somente Perigosos
		// MV_NG2RIST - 5 - Todos
		dbSelectarea( "TMA" )
		dbSetOrder( 1 )
		dbSeek( xFilial( "TMA" ) + IIf( lRisCad, M->TN0_AGENTE, TN0->TN0_AGENTE ) )

		//Valida se o tipo do agente do risco está contido no parâmetro MV_NG2RIST
		If ( TMA->TMA_GRISCO == "4" .And. ( cRisTAF == "2" .Or. cRisTAF == "0" .Or. cRisTAF == "4" ) ) .Or. ;
			( ( TMA->TMA_GRISCO == "5" .Or. TMA->TMA_GRISCO == "6" ) .And. ( cRisTAF == "1" .Or. cRisTAF == "0" .Or. cRisTAF == "4" ) ) .Or. ;
			( TMA->TMA_GRISCO == "7" .And. ( cRisTAF == "0" .Or. cRisTAF == "1" .Or. cRisTAF == "2" .Or. cRisTAF == "3" ) )
			lRet := .F.
		EndIf
	EndIf

	//---------------------------------------------------------------------------------------
	// Valida se o agente possui um código do eSocial e se é diferente do código de ausência
	//---------------------------------------------------------------------------------------
	If lRet .And. ( Empty( TMA->TMA_ESOC ) .Or. TMA->TMA_ESOC == "09.01.001" )
		lRet := .F.
	EndIf
	
	//-------------------------------------------------------------
	// Valida se o risco está em algum PPRA no momento da execução
	//-------------------------------------------------------------
	If lRet .And. lVldPPRA //Caso tenha que validar o Laudo
		lRet := .F. //Indica inicialmente que o Risco não será setado para envio, caso ache então envia
		dbSelectArea( "TO1" )
		dbSetOrder( 2 ) //TO1_FILIAL+TO1_NUMRIS+TO1_LAUDO
		dbSeek( xFilial( "TO1" ) + IIf( lRisCad, M->TN0_NUMRIS, TN0->TN0_NUMRIS ) )
		While TO1->( !EoF() ) .And. TO1->TO1_FILIAL == xFilial( "TO1" ) .And. ;
				TO1->TO1_NUMRIS == IIf( lRisCad, M->TN0_NUMRIS, TN0->TN0_NUMRIS )

			dbSelectArea( "TO0" )
			dbSetOrder( 1 ) //TO0_FILIAL+TO0_LAUDO
			dbSeek( xFilial( "TO0" ) + TO1->TO1_LAUDO )
			If TO0->TO0_TIPREL == "1" .And. TO0->TO0_DTINIC <= dDtRef .And.;
				( TO0->TO0_DTVALI >= dDtRef .Or. Empty( TO0->TO0_DTVALI ) )
				lRet := .T.
				Exit
			EndIf
			TO1->( dbSkip() )
		End
	EndIf

	//Retorna a área
	RestArea( aArea )

Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} MDTBFilEnv
Busca a filial de envio

@return cFilTAF, Caracter, Retorna a filial de envio

@sample MDTBFilEnv()

@author  Luis Fellipy Bett
@since   14/08/2019
/*/
//-------------------------------------------------------------------
Function MDTBFilEnv()

	Local aArea		:= GetArea() //Salva a área
	Local cEmpBkp	:= cEmpAnt //Salva a empresa
	Local cFilBkp	:= cFilAnt //Salva a filial
	Local cFilMtrz  := ""
	Local aFilInTaf := {}
	Local aArrayFil := {}
	Local aTbls		:= { { "C1E", 01 }, { "CR9", 01 }, { "RJ9", 01 } }

	Default lGPEA180 := .F.
	Default lMiddleware := IIf( cPaisLoc == 'BRA' .And. Findfunction( "fVerMW" ), fVerMW(), .F. )

	//Caso for transferência de funcionário, posiciona na empresa e filial destino
	If lGPEA180
		If cEmpAnt <> cEmpDes //Caso for transferência de empresa, abre as tabelas na nova empresa
			NGPrepTBL( aTbls, cEmpDes, cFilDes )
			cEmpAnt := cEmpDes //Posiciona na empresa destino
		EndIf
		
		cFilAnt := cFilDes
	EndIf

	If !lMiddleware
		//Busca a filial a ser considerada no envio ao TAF
		fGp23Cons( @aFilInTaf, @aArrayFil, @cFilMtrz )
	EndIf

	If Empty( cFilMtrz )
		cFilMtrz := cFilAnt
	EndIf

	//Retorna a empresa e filial para a atual
	If lGPEA180
		If cEmpAnt <> cEmpBkp
			NGPrepTBL( aTbls, cEmpBkp, cFilBkp )
			cEmpAnt := cEmpBkp //Posiciona na empresa destino
		EndIf

		cFilAnt := cFilBkp
	EndIf

	//Retorna a área
	RestArea( aArea )

Return cFilMtrz

//-------------------------------------------------------------------
/*/{Protheus.doc} MDTVerTSVE
Função que verifica se o funcionário é TSVE - Trabalhador Sem Vínculo Estatutário

@return lRet, Lógico, Verdadeiro caso a categoria do trabalhador for de TSVE

@sample MDTVerTSVE( "701" )

@param cCodCateg, Caracter, Código da Categoria do Funcionário

@author	Luis Fellipy Bett
@since	03/12/2019
/*/
//-------------------------------------------------------------------
Function MDTVerTSVE( cCodCateg )

	Local lRet := .T.

	If !( cCodCateg $ "201/202/304/305/308/401/410/701/711/712/721/722/723/731/734/738/741/751/761/771/901/902/903/904/905" )
		lRet := .F.
	EndIf

Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} MdtTraAvul
Verifica se o funcionário é trabalhador avulso (categoria 2XX)

@author	Gabriel Sokacheski
@since 05/10/2022

@param cCodCateg, código da categoria do funcionário

@return lRet, verdadeiro caso seja trabalhador avulso
/*/
//-------------------------------------------------------------------
Function MdtTraAvul( cCategoria )

	Local lRet := .F.

	If SubStr( cCategoria, 1, 1 ) == '2' // Categoria 2XX
		lRet := .T.
	EndIf

Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} Mdt062022
Verifica se está dentro do período da nota técnica 06-2022

@author	Gabriel Sokacheski
@since 05/10/2022

@param dData, data a ser verificada

@return lRet, verdadeiro caso deva seguir a nota técnica
/*/
//-------------------------------------------------------------------
Function Mdt062022( dData )

	Local lRet := .F.

	If dData >= CtoD( '16/01/2023' )
		lRet := .T.
	EndIf

Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} MdtFunTar
Verifica qual a tarefa atual do funcionário.

@author	Gabriel Sokacheski
@since 07/10/2022

@param cMatricula, matricula do funcionário

@return aTarefa, contém as informações da tarefa
/*/
//-------------------------------------------------------------------
Function MdtFunTar( cMatricula, dEvento )

	Local aTarefa := {}

	Local nTarefa := 0

	Local oGrid
	Local oModel

	If FWIsInCallStack( 'mdta090' ) // Rotina: Tarefas do funcionário

		oModel := FWModelActive()
		oGrid := oModel:GetModel( 'TN6DETAIL' )

		If oGrid:SeekLine( { { 'TN6_MAT', cMatricula } } )

			For nTarefa := oGrid:GetLine() To oGrid:Length()

				oGrid:GoLine( nTarefa )

				If oGrid:GetValue( 'TN6_MAT' ) == cMatricula

					If dEvento >= oGrid:GetValue( 'TN6_DTINIC' ) .And. dEvento <= oGrid:GetValue( 'TN6_DTTERM' )

						aTarefa := { M->TN5_CODTAR, oGrid:GetValue( 'TN6_DTINIC' ), oGrid:GetValue( 'TN6_DTTERM' ) }
						Exit

					EndIf

				EndIf

			Next

		EndIf

	Else

		DbSelectArea( 'TN6' )
		DbSetOrder( 2 )
		If DbSeek( xFilial( 'TN6' ) + cMatricula )

			While !( 'TN6' )->( Eof() ) .And. xFilial( 'TN6' ) == TN6->TN6_FILIAL .And. cMatricula == TN6->TN6_MAT

				If dEvento >= TN6->TN6_DTINIC .And. dEvento <= TN6->TN6_DTTERM
					aTarefa := { TN6->TN6_CODTAR, TN6->TN6_DTINIC, TN6->TN6_DTTERM }
					Exit
				Else
					( 'TN6' )->( DbSkip() )
				EndIf

			End

		EndIf

	EndIf

Return aTarefa

//-------------------------------------------------------------------
/*/{Protheus.doc} MDTEnvMid
Realiza o envio dos eventos de SST para o eSocial através do Middleware

@return .T., sempre verdadeiro

@sample MDTEnvMid( "D MG 01 ", "787878", "S2210", "D MG 01 2019050214001", "<eSocial></eSocial>", 3 )

@param cMatricula, Caracter, Número da Matrícula do Funcionário
@param cEvento, Caracter, Nome do Evento
@param cChvAtu, Caracter, Chave atual do registro utilizada para busca na RJE
@param cChvNov, Caracter, Chave nova do registro utilizada para preenchimento do campo RJE_KEY
@param cXml, Caracter, Xml a ser enviado ao eSocial
@param nOper, Numérico, Operação a ser realizada (3- Inclusão, 4- Alteração e 5-Exclusão)

@author	Luis Fellipy Bett
@since	03/12/2019
/*/
//-------------------------------------------------------------------
Function MDTEnvMid( cMatricula, cEvento, cChvAtu, cChvNov, cXml, nOper )

	Local cEmpBkp  := cEmpAnt //Salva a empresa atual
	Local cFilBkp  := cFilAnt //Salva a filial atual
	Local aInfEnv  := {}
	Local aInfoC   := {}
	Local aRet	   := {} //Array de retorno
	Local aInfReg  := { /*cStatMid*/, /*cOpcRJE*/, /*cRetfRJE*/, /*nRecRJE*/ }
	Local lIntegra := .T.
	Local nOpcao   := 3
	Local cModo	   := ""
	Local cMsgErro := ""
	Local cOperNew := ""
	Local cRetfNew := ""
	Local cStatNew := ""
	Local lNovoRJE := .F.
	Local cTpInsc  := ""
	Local cNrInsc  := "0"
	Local cId	   := ""
	Local lAdmPubl := .F.

	Default nOper := 5

	//Caso for transferência entre empresas, posiciona na empresa destino
	If lGPEA180
		If cEmpAnt <> cEmpDes //Caso a empresa destino seja diferente da empresa atual
			
			//Posciona na empresa destino
			MDTPosSM0( cEmpDes, cFilDes )

			//Abre as tabelas na empresa destino
			EmpOpenFile( "RJ9", "RJ9", 1, .F., cEmpAnt, @cModo )
			EmpOpenFile( "RJ9", "RJ9", 1, .T., cEmpDes, @cModo )
			EmpOpenFile( "RJE", "RJE", 1, .F., cEmpAnt, @cModo )
			EmpOpenFile( "RJE", "RJE", 1, .T., cEmpDes, @cModo )

			//Posiciona na empresa destino
			cEmpAnt := cEmpDes
		EndIf

		//Posiciona na filial destino
		cFilAnt := cFilDes
	EndIf

	//Busca as informações da empresa
	aInfoC := fXMLInfos()

	If Len( aInfoC ) >= 4
		cTpInsc  := aInfoC[ 1 ]
		cNrInsc  := aInfoC[ 2 ]
		cId		 := aInfoC[ 3 ]
		lAdmPubl := aInfoC[ 4 ]		
	EndIf

	//Define status como "-1"
	aInfReg[ 1 ] := "-1"

	//Busca informações do registro
	aInfReg := MDTVerStat( .F., cEvento, cChvAtu )

	//Caso seja Alteração ou Exclusão
	If nOper == 4 .Or. nOper == 5

		//Retorno pendente impede o cadastro
		If aInfReg[ 1 ] == "2"
			cMsgErro := STR0058 //"Operação não será realizada pois o evento foi transmitido mas o retorno está pendente"
			lIntegra := .F.
		EndIf

		If nOper == 4 //Alteração

			If aInfReg[ 2 ] == "E" .And. aInfReg[ 1 ] != "4" //Evento de exclusão sem transmissão impede o cadastro

				cMsgErro := STR0059 //"Operação não será realizada pois há evento de exclusão que não foi transmitido ou está com retorno pendente"
				lIntegra := .F.

			ElseIf aInfReg[ 1 ] == "-1" //Não existe na fila, será tratado como inclusão

				nOpcao 	 := 3
				cOperNew := "I"
				cRetfNew := "1"
				cStatNew := "1"
				lNovoRJE := .T.

			ElseIf aInfReg[ 1 ] $ "1/3" //Evento sem transmissão, irá sobrescrever o registro na fila

				If aInfReg[ 2 ] == "A"
					nOpcao := 4
				EndIf
				cOperNew := aInfReg[ 2 ]
				cRetfNew := aInfReg[ 3 ]
				cStatNew := "1"
				lNovoRJE := .F.

			ElseIf aInfReg[ 2 ] != "E" .And. aInfReg[ 1 ] == "4" //Evento diferente de exclusão transmitido, irá gerar uma retificação

				nOpcao 	 := 4
				cOperNew := "A"
				cRetfNew := "2"
				cStatNew := "1"
				lNovoRJE := .T.

			ElseIf aInfReg[ 2 ] == "E" .And. aInfReg[ 1 ] == "4" //Evento de exclusão transmitido, será tratado como inclusão

				nOpcao 	 := 3
				cOperNew := "I"
				cRetfNew := "1"
				cStatNew := "1"
				lNovoRJE := .T.

			EndIf

		ElseIf nOper == 5 //Exclusão

			nOpcao := 5

			If aInfReg[2] == "E" .And. aInfReg[1] != "4" //Evento de exclusão sem transmissão impede o cadastro
				cMsgErro := STR0059 //"Operação não será realizada pois há evento de exclusão que não foi transmitido ou está com retorno pendente"
				lIntegra := .F.

			ElseIf aInfReg[2] != "E" .And. aInfReg[1] == "4" //Evento diferente de exclusão transmitido irá gerar uma exclusão

				cOperNew := "I"
				cRetfNew := aInfReg[3]
				cStatNew := "1"
				lNovoRJE := .T.
				cEvento	 := "S3000"

			EndIf
		EndIf

	//Caso seja Inclusão
	ElseIf nOper == 3

		If aInfReg[ 1 ] == "2" //Retorno pendente impede o cadastro

			cMsgErro := STR0058 //"Operação não será realizada pois o evento foi transmitido mas o retorno está pendente"
			lIntegra := .F.

		ElseIf aInfReg[ 2 ] == "E" .And. aInfReg[ 1 ] != "4" //Evento de exclusão sem transmissão impede o cadastro

			cMsgErro := STR0059 //"Operação não será realizada pois há evento de exclusão que não foi transmitido ou está com retorno pendente"
			lIntegra := .F.

		ElseIf aInfReg[ 1 ] $ "1/3" //Evento sem transmissão, irá sobrescrever o registro na fila

			nOpcao	 := IIf( aInfReg[ 2 ] == "I", 3, 4 )
			cOperNew := aInfReg[ 2 ]
			cRetfNew := aInfReg[ 3 ]
			cStatNew := "1"
			lNovoRJE := .F.

		ElseIf aInfReg[ 2 ] != "E" .And. aInfReg[ 1 ] == "4" //Evento diferente de exclusão transmitido, irá gerar uma retificação

			cOperNew := "A"
			cRetfNew := "2"
			cStatNew := "1"
			lNovoRJE := .T.

		Else //Será tratado como inclusão
			cOperNew := "I"
			cRetfNew := "1"
			cStatNew := "1"
			lNovoRJE := .T.
		EndIf
	EndIf

	//Caso for evento de exclusão
	If cEvento == "S3000"
		cChvNov := aInfReg[ 5 ] //A chave a ser cadastrada no campo RJE_KEY recebe o recibo do registro
		aInfReg[ 6 ] := aInfReg[ 5 ] //O recibo anterior recebe o recibo atual
	Else
		If cRetfNew == "2"
			If aInfReg[ 1 ] == "4"
				aInfReg[ 6 ] := aInfReg[ 5 ]
				aInfReg[ 5 ] := ""
			EndIf
		EndIf
	EndIf

	If lIntegra
		//RJE_FILIAL: Filial do sistema conforme compartilhamento da tabela
		//RJE_FIL: Filial que está sendo alterada
		//RJE_TPINSC : RJ9_TPINSC
		//RJE_INSCR: RJ9_NRINSC (8 caracteres)
		//RJE_EVENTO: S1030
		//RJE_INI: Data base (AAAAMM)
		//RJE_KEY : Código da Filial Completa + Código do Cargo
		//RJE_RETKEY: ID do XML
		//RJE_RETF: "1"
		//RJE_VERS: versão do Protheus
		//RJE_STATUS: "1"
		//RJE_DTG : Data Geração do Evento
		//RJE_HORAG: Hora Geração do Evento
		//RJE_OPER: Operação a ser realizada (I-Inclusão, A-Alteração, E-Exclusão)

		aAdd( aInfEnv, { xFilial( "RJE", cFilEnv ), cFilEnv, cTpInsc, IIf( cTpInsc == "1" .And. !lAdmPubl, SubStr( cNrInsc, 1, 8 ), cNrInsc ), cEvento, AnoMes( dDataBase ), cChvNov, cId, cRetfNew, "12", cStatNew, Date(), Time(), cOperNew, aInfReg[ 5 ], aInfReg[ 6 ] } )

		//Se não for uma exclusão de registro não transmitido, cria/atualiza registro na fila
		If !( nOpcao == 5 .And. ( ( aInfReg[ 2 ] == "E" .And. aInfReg[ 1 ] == "4" ) .Or. aInfReg[ 1 ] $ "-1/1/3" ) )

			If fGravaRJE( aInfEnv, cXml, lNovoRJE, aInfReg[ 4 ] )
				aAdd( aRet, { .T., STR0060 + " (" + cEvento + ") " + STR0061 } )
			Else
				aAdd( aRet, { .F., STR0062 + " (" + cEvento + ") " + STR0063 } )
			EndIf

		//Se for uma exclusão e não for de registro de exclusão transmitido, exclui registro de exclusão na fila
		ElseIf nOpcao == 5 .And. aInfReg[ 1 ] != "-1" .And. !( aInfReg[ 2 ] == "E" .And. aInfReg[ 1 ] == "4" )

			If fExcluiRJE( aInfReg[ 4 ] )
				aAdd( aRet, { .T., STR0064 + " (" + cEvento + ") " + STR0065 } )
			Else
				aAdd( aRet, { .F., STR0066 + " (" + cEvento + ")" } )
			EndIf

		EndIf

	Else
		aAdd( aRet, { .F., cMsgErro } )
	EndIf

	//Caso for chamada pelo GPEA180, altera a empresa e filial para a atual após ter buscado as informações
	If lGPEA180
		If cEmpAnt <> cEmpBkp //Caso a empresa destino seja diferente da empresa atual
			
			//Posciona na empresa logada novamente
			MDTPosSM0( cEmpBkp, cFilBkp )

			//Volta as tabelas na empresa logada novamente
			EmpOpenFile( "RJ9", "RJ9", 1, .F., cEmpAnt, @cModo )
			EmpOpenFile( "RJ9", "RJ9", 1, .T., cEmpBkp, @cModo )
			EmpOpenFile( "RJE", "RJE", 1, .F., cEmpAnt, @cModo )
			EmpOpenFile( "RJE", "RJE", 1, .T., cEmpBkp, @cModo )

			//Posiciona na empresa logada novamente
			cEmpAnt := cEmpBkp
		EndIf

		//Posiciona na filial logada novamente
		cFilAnt := cFilBkp
	EndIf

Return aRet

//-------------------------------------------------------------------
/*/{Protheus.doc} MDTVerStat
Verifica o status do registro passado por parâmetro e retorna se ele
já foi enviado ao TAF ou não

@return xRet, Indefindo, Ou lógico caso o registro exista na RJE ou um Array

@sample MDTVerStat( .T., "S2210", "D MG 01 2019050214001", .F. )

@param lRetBool, Boolean, Indica se o retorno da função vai ser Booleano, senão retorna um Array
@param cEvento, Caracter, Nome do evento
@param cChave, Caracter, Chave de busca pelo registro do evento
@param lExclu, Boolean, Indica se exclui o registro da RJE caso ele não esteja transmitido ao governo

@author	Luis Fellipy Bett
@since	03/12/2019
/*/
//-------------------------------------------------------------------
Function MDTVerStat( lRetBool, cEvento, cChave, lExclu )

	Local xRet
	Local cStatRJE	:= "-1"
	Local cOperRJE	:= ""
	Local cRetfRJE	:= ""
	Local nRecnRJE	:= 0
	Local cRecibRJE	:= ""
	Local CRecibAnt	:= ""
	Local cTpInsc	:= ""
	Local lAdmPubl	:= .F.
	Local cNrInsc	:= "0"
	Local cChvBus	:= ""

	Default lRetBool := .F.
	Default lExclu	 := .F.

	//Busca as informações da empresa
	aInfoC := fXMLInfos()

	If Len( aInfoC ) >= 4
		cTpInsc  := aInfoC[1]
		lAdmPubl := aInfoC[4]
		cNrInsc  := aInfoC[2]
	EndIf

	//RJE_TPINSC + RJE_INSCR + RJE_EVENTO + RJE_KEY + RJE_INI
	cChvBus := Padr( cTpInsc, TAMSX3( "RJE_TPINSC" )[1] ) + ;
				Padr( IIf( cTpInsc == "1" .And. !lAdmPubl, SubStr( cNrInsc, 1, 8 ), cNrInsc ), TAMSX3( "RJE_INSCR" )[1] ) + ;
				cEvento + ;
				Padr( cChave, TAMSX3( "RJE_KEY" )[1] )

	GetInfRJE( 2, cChvBus, @cStatRJE, @cOperRJE, @cRetfRJE, @nRecnRJE, @cRecibRJE, @CRecibAnt, , , lExclu )

	//Caso o retorno seja booleano
	If lRetBool
		If lExclu .And. ( cStatRJE <> "4" .And. cStatRJE <> "-1" ) .And. nRecnRJE > 0 //Caso o registro exista na RJE e não esteja transmitido ao governo, exclui
			If fExcluiRJE( nRecnRJE )
				Help( ' ', 1, STR0017, , STR0064 + " (" + cEvento + ") " + STR0065, 2, 0 )
				xRet := .F.
			EndIf
		ElseIf cStatRJE <> "-1" //Caso o registro exista na tabela RJE
			xRet := .T.
		Else
			//Caso o registro não exista na RJE
			xRet := .F.
		EndIf
	Else
		xRet := { cStatRJE, cOperRJE, cRetfRJE, nRecnRJE, cRecibRJE, CRecibAnt }
	EndIf

Return xRet

//-------------------------------------------------------------------
/*/{Protheus.doc} MDTVld2200
Verifica se existe um evento S-2190, S-2200 ou S-2230 enviado ao governo para o funcionário

@return	lRet, Boolean, .T. se existir um evento comunicado ao governo, senão .F.

@sample MDTVld2200( "787878", "1", "581312150001", .F. )

@param	cMatricula, Caracter, Matrícula do funcionário (RA_MAT)
@param	aGPEA180, Array, Array contendo as informações da transferência quando chamado pelo GPEA180

@author	Luis Fellipy Bett
@since	11/12/2019
/*/
//-------------------------------------------------------------------
Function MDTVld2200( cMatricula, aGPEA180 )

	//Variável da área
	Local aArea := GetArea() //Salva a área
	
	//Variáveis de busca e validação das informações
	Local cCodUnic	:= IIf( lGPEA180, aGPEA180[ 1, 14 ], Posicione( "SRA", 1, xFilial( "SRA" ) + cMatricula, "RA_CODUNIC" ) )
	Local cCodCateg	:= Posicione( "SRA", 1, xFilial( "SRA" ) + cMatricula, "RA_CATEFD" )
	Local cCPF		:= Posicione( "SRA", 1, xFilial( "SRA" ) + cMatricula, "RA_CIC" )
	Local dDtAdmis	:= Posicione( "SRA", 1, xFilial( "SRA" ) + cMatricula, "RA_ADMISSA" )
	Local lVldEvPre := SuperGetMv( "MV_NG2VEVP", .F., "2" ) == "1"
	Local lTSVE		:= MDTVerTSVE( cCodCateg )
	Local cEmpBkp	:= cEmpAnt //Salva a empresa
	Local cFilBkp	:= cFilAnt //Salva a filial
	Local lRet		:= .T.
	Local aInfoC	:= {}
	Local cStatus	:= "-1"
	Local cChave	:= ""
	Local cTpInsc	:= ""
	Local cNrInsc	:= ""
	Local lAdmPubl	:= ""
	Local aTbls		:= { { "T3A", 01 }, { "C9V", 01 } }

	//Caso o sistema deva realizar a validação dos eventos predecessores
	If lVldEvPre

		If lMiddleware //Caso for integração via Middleware

			//Busca as informações da empresa destino
			aInfoC	 := fXMLInfos()
			cTpInsc	 := aInfoC[1]
			cNrInsc	 := aInfoC[2]
			lAdmPubl := aInfoC[4]

			If MDTVerTSVE( cCodCateg ) //Caso for Trabalhador Sem Vínculo Estatutário
				cChave := cTpInsc + Padr( IIf( !lAdmPubl .And. cTpInsc == "1", SubStr( cNrInsc, 1, 8 ), cNrInsc ), TAMSX3( "RJE_INSCR" )[1] ) + "S2300" + Padr( AllTrim( cCPF ) + AllTrim( cCodCateg ) + DToS( dDtAdmis ), TAMSX3( "RJE_KEY" )[1], " " )
			Else
				cChave := cTpInsc + Padr( IIf( !lAdmPubl .And. cTpInsc == "1", SubStr( cNrInsc, 1, 8 ), cNrInsc ), TAMSX3( "RJE_INSCR" )[1] ) + "S2200" + Padr( AllTrim( cCodUnic ), TAMSX3( "RJE_KEY" )[1], " " )
			EndIf

			//RJE_TPINSC + RJE_INSCR + RJE_EVENTO + RJE_KEY + RJE_INI
			GetInfRJE( 2, cChave, @cStatus )

			//Caso o registro do funcionário exista na RJE
			If cStatus == "-1"
				lRet := .F.
			EndIf

		Else

			Help := .T. //Desabilita mensagens de validação da função ExistCPO

			//Caso for transferência de funcionário, posiciona na empresa e abre as tabelas destino
			If lGPEA180
				If cEmpAnt <> cEmpDes //Caso for transferência de empresa, abre as tabelas na nova empresa
					NGPrepTBL( aTbls, cEmpDes, cFilDes )
					cEmpAnt := cEmpDes //Posiciona na empresa destino
				EndIf
			EndIf

			//Posiciona na filial de envio de acordo com a configuração do TAF
			cFilAnt := cFilEnv

			//Verifica se existe o evento S-2190 para o funcionário
			lRet := ExistCPO( "T3A", cCPF, 2 )

			//Caso não existir o evento S-2190 para o funcionário, verifica se existe o evento S-2200 ou S-2300
			If !lRet
				If lTSVE
					lRet := ExistCPO( "C9V", cCPF, 3 )
				Else
					lRet := ExistCPO( "C9V", cCodUnic, 11 )
				EndIf
			EndIf

			//Caso for transferência de funcionário, retorna a empresa e as tabelas para a atual
			If lGPEA180
				If cEmpAnt <> cEmpBkp //Caso for transferência de empresa, retorna as tabelas para a empresa atual
					NGPrepTBL( aTbls, cEmpBkp, cFilBkp )
					cEmpAnt := cEmpBkp //Posiciona na empresa atual novamente
				EndIf
			EndIf

			//Retorna a filial
			cFilAnt := cFilBkp

			Help := .F. //Habilita mensagens de validação da função ExistCPO

		EndIf
	
	EndIf

	//Retorna a área
	RestArea( aArea )

Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} MDTGerCabc
Gera o cabeçalho dos Xml's a serem enviados ao Governo (ID Xml + Evento + Empregador)

@return .T., Sempre verdadeiro

@sample MDTGerCabc( "", "S2210", "1", "548648510000", .T., .F., "3", "", "D MG 01 " )

@param	cXml, Caracter, Xml a ser carregado
@param	cEvento, Caracter, Nome do evento
@param	cOper, Caracter, Operação que está sendo realizada (3- Inclusão, 4- Alteração e 5-Exclusão)
@param	cChave, Caracter, Chave do registro a ser verificado
@param	lEvtExclu, Boolean, Indica se é evento de exclusão (S-3000)

@author	Luis Fellipy Bett
@since	12/12/2019
/*/
//-------------------------------------------------------------------
Function MDTGerCabc( cXml, cEvento, cOper, cChave, lEvtExclu )

	Local cId		:= ""
	Local cTag		:= MDTTagEsoc( cEvento, lEvtExclu ) //Busca a Tag referente ao evento
	Local cTpAmb	:= SuperGetMv( "MV_GPEAMBE", , "2" ) //Tipo de ambiente para envio das informações (1-Produção, 2-Produção Restrita)
	Local cChvBus	:= ""
	Local cTpInsc	:= ""
	Local cNrInsc	:= ""
	Local cVersLyt	:= ""
	Local cStatReg	:= "-1"
	Local cOperReg	:= "I"
	Local cRetfReg	:= "1"
	Local cRetfNew	:= "1"
	Local cRecibReg	:= ""
	Local cRecibAnt	:= ""
	Local cRecibXML	:= ""

	Local lAdmPubl	:= .F.

	Local nRecReg	:= 0

	Local oModelTNC

	//Define como padrão Xml de inclusão
	Default cOper := "3"
	Default lEvtExclu := .F.

	//Caso envio seja através do Middleware
	If lMiddleware

		//Busca a versão do leiaute a ser utilizada no envio dos eventos de SST
		cVersLyt := MDTVerEsoc( cEvento )

		//Busca informações da empresa
		aInfoC := fXMLInfos()

		If Len( aInfoC ) >= 4
			cTpInsc  := aInfoC[ 1 ]
			cNrInsc  := aInfoC[ 2 ]
			cId  	 := aInfoC[ 3 ]
			lAdmPubl := aInfoC[ 4 ]
		EndIf

		//RJE_TPINSC + RJE_INSCR + RJE_EVENTO + RJE_KEY + RJE_INI
		cChvBus := Padr( cTpInsc, TAMSX3( "RJE_TPINSC" )[1] ) + ;
				Padr( IIf( cTpInsc == "1" .And. !lAdmPubl, SubStr( cNrInsc, 1, 8 ), cNrInsc ), TAMSX3( "RJE_INSCR" )[1] ) + ;
				cEvento + ;
				Padr( cChave, TAMSX3( "RJE_KEY" )[1] )

		GetInfRJE( 2, cChvBus, @cStatReg, @cOperReg, @cRetfReg, @nRecReg, @cRecibReg, @cRecibAnt, Nil, Nil, .T. )

		//Evento sem transmissão, irá sobrescrever o registro na fila
		If cStatReg $ "1/3"
			cOperNew 	:= cOperReg
			cRetfNew	:= cRetfReg
			cStatNew	:= "1"
			lNovoRJE	:= .F.
		//Evento diferente de exclusão transmitido, irá gerar uma retificação
		ElseIf cOperReg != "E" .And. cStatReg == "4"
			cOperNew 	:= "A"
			cRetfNew	:= "2"
			cStatNew	:=  "1"
			lNovoRJE	:= .T.
		//Será tratado como inclusão
		Else
			cOperNew 	:= "I"
			cRetfNew	:= "1"
			cStatNew	:= "1"
			lNovoRJE	:= .T.
		EndIf
		If cRetfNew == "2"
			If cStatReg == "4"
				cRecibXML := cRecibReg
			Else
				cRecibXML := cRecibAnt
			EndIf
		EndIf

		cXml := "<eSocial xmlns='http://www.esocial.gov.br/schema/evt/" + cTag + "/v" + cVersLyt + "'>"
		cXml += 	"<" + cTag + " Id='" + cId + "'>"
	Else
		cXml := "<eSocial>"
		cXml += 	"<" + cTag + ">"

		//Caso seja uma alteração, define o Xml como retificação
		If cOper == "4"
			cRetfNew := "2"
		EndIf
	EndIf

	If FWIsInCallStack( 'MDTA640' ) // Rotina de acidentes

		oModelTNC := FWModelActive()

		If ValType( oModelTNC ) != 'U' // Não necessário quando gerado o arquivo XML em outras ações
			// Na inclusão de uma CAT de reabertura ou óbito
			If M->TNC_TIPCAT $ '2/3' .And. oModelTNC:GetOperation() == 3
				cRetfNew := '1' // Trata como inclusão de registro
			EndIf
		EndIf

	EndIf

	//Vínculo Evento
	cXml += 			'<ideEvento>'
	If !lEvtExclu //Caso não for evento de exclusão
		cXml +=				'<indRetif>' + 	cRetfNew	+ '</indRetif>'
	EndIf
	If lMiddleware //Caso seja via Middleware (pega o recibo)
		If cRetfNew == "2" .And. !lEvtExclu //Caso seja retificação e não for evento de exclusão
			cXml +=			'<nrRecibo>' + 	cRecibXML	+ '</nrRecibo>'
		EndIf
		cXml +=				'<tpAmb>'	+	cTpAmb		+ '</tpAmb>'
		cXml +=				'<procEmi>' + 	"1"			+ '</procEmi>'
		cXml +=				'<verProc>' + 	"12"		+ '</verProc>'
	EndIf
	cXml += 			'</ideEvento>'

	//Vínculo Empregador
	If lMiddleware
		cXml +=			'<ideEmpregador>'
		cXml +=				'<tpInsc>' + cTpInsc	+ '</tpInsc>'
		cXml +=				'<nrInsc>' + SubStr( cNrInsc, 1, 8 ) + '</nrInsc>'
		cXml +=			'</ideEmpregador>'
	EndIf

Return .T.

//-------------------------------------------------------------------
/*/{Protheus.doc} MDTXmlVal

Busca o valor de uma tag dentro do Xml

@return	 cVal, Indefinido, Valor do nó passado no caminho do Xml

@sample MDTXmlVal( "S2240", "<eSocial></eSocial>", "/ns:eSocial/ns:evtExpRisco", "D" )

@param	 cEvento, Caracter, Nome do evento
@param	 cXml, Caracter, Xml a que será buscado o valor
@param	 cCamTag, Caracter, Caminho do Xml onde está o valor a ser pego
@param	 cTipRet, Caracter, Tipo de retorno do valor

@author  Luis Fellipy Bett
@since   31/01/2020
/*/
//-------------------------------------------------------------------
Function MDTXmlVal( cEvento, cXml, cCamTag, cTipRet )

	Local oXml
	Local cVal		:= ""
	Local cVersLyt	:= ""
	Local nStrIni	:= 0
	Local nStrFim	:= 0
	Local nTamStr	:= 0
	Local cTag		:= MDTTagEsoc( cEvento ) //Busca a Tag referente ao evento

	//Caso o Xml passado não esteja vazio
	If !Empty( cXml )

		//Busca a versão do leiaute de dentro do Xml
		nStrIni := At( '/v', cXml ) + 2
		nStrFim := IIf( At( '">', cXml ) > 0, At( '">', cXml ), At( "'>", cXml ) )
		nTamStr := nStrFim - nStrIni

		cVersLyt := SubStr( cXml, nStrIni, nTamStr ) //Define a versão do leiaute de acordo com a versão passada no Xml

		oXml := TXMLManager():New()

		If !oXml:Parse( cXml )
			Help( ' ', 1, STR0017, , STR0067, 2, 0, , , , , , { STR0068 } )
		Else
			oXml:XPathRegisterNs( "ns", "http://www.esocial.gov.br/schema/evt/" + cTag + "/v" + cVersLyt )

			If oXml:XPathHasNode( cCamTag )
				cVal := oXml:XPathGetNodeValue( cCamTag )
			EndIf
		EndIf
	EndIf

	//Caso a tag esteja preenchida
	If !Empty( cVal )
		If ValType( cVal ) <> cTipRet
			If cTipRet == "D"
				If Len( cVal ) > 8
					cVal := SToD( StrTran( cVal, "-", "" ) )
				Else
					cVal := SToD( cVal )
				EndIf
			ElseIf cTipRet == "N"
				cVal := Val( cVal )
			EndIf
		EndIf
	Else //Caso a tag esteja vazia
		If cTipRet == "D"
			cVal := SToD( "" )
		ElseIf cTipRet == "N"
			cVal := 0
		EndIf
	EndIf

Return cVal

//-------------------------------------------------------------------
/*/{Protheus.doc} fTabEveEso
Retorna a tabela referente ao evento passado por parâmetro

@return  cTab, Caracter, Tabela referente ao evento passado por parâmetro

@sample	 fTabEveEso( "S2240" )

@param	 cEvento, Caracter, Evento do eSocial

@author  Luis Fellipy Bett
@since   16/03/2021
/*/
//-------------------------------------------------------------------
Static Function fTabEveEso( cEvento )

	Local cTab := ""

	Do Case
		//Comunicação de Acidente de Trabalho (CAT)
		Case "2210" $ cEvento
			cTab := "CM0"
		//Monitoramento de Saúde do Trabalhador (ASO)
		Case "2220" $ cEvento
			cTab := "C8B"
		//Condição Ambiental de Trabalho (Risco)
		Case "2240" $ cEvento
			cTab := "CM9"
	EndCase

Return cTab

//-------------------------------------------------------------------
/*/{Protheus.doc} MDTTagEsoc
Retorna a tag referente ao evento passado por parâmetro

@return  cTag, Caracter, Tag referente ao evento passado por parâmetro

@sample	 MDTTagEsoc( "S2240" )

@param	 cEvento, Caracter, Evento do eSocial

@author  Luis Fellipy Bett
@since   03/02/2020
/*/
//-------------------------------------------------------------------
Function MDTTagEsoc( cEvento, lEvtExclu )

	Local cTag := ""

	Default lEvtExclu := .F.

	Do Case
		//Exclusão de Eventos
		Case lEvtExclu
			cTag := "evtExclusao"
		//Tabela de Estabelecimentos, Obras ou Unidades de Órgãos Públicos
		Case "1005" $ cEvento
			cTag := "evtTabEstab"
		//Comunicação de Acidente de Trabalho (CAT)
		Case "2210" $ cEvento
			cTag := "evtCAT"
		//Monitoramento de Saúde do Trabalhador (ASO)
		Case "2220" $ cEvento
			cTag := "evtMonit"
		//Condição Ambiental de Trabalho (Risco)
		Case "2240" $ cEvento
			cTag := "evtExpRisco"
	EndCase

Return cTag

//-------------------------------------------------------------------
/*/{Protheus.doc} MDTNrInsc
Valida o Número de Inscrição do Local do Acidente ou do Ambiente de
Exposição do Risco

@return lRet, Boolean, .T. se o conteúdo do campo estiver ok

@param cTpLocal, Caracter, Indica o tipo de local relacionado a Inscrição
@param cTpInsc, Caracter, Indica o tipo de inscrição a ser considerado
@param cNrInsc, Caracter, Indica o número da inscrição
@param cNumMat, Caracter, Indica a matrícula do funcionário

@author Luis Fellipy Bett
@since  16/04/2020
/*/
//-------------------------------------------------------------------
Function MDTNrInsc( cTpLocal, cTpInsc, cNrInsc, cNumMat )

	//Variáveis de busca e validação das informações
	Local aEvento   := {}
	Local lVldEvPre := SuperGetMv( "MV_NG2VEVP", .F., "2" ) == "1"
	Local cInscSM0	:= SM0->M0_CGC //Número de inscrição apenas da SM0 para validação
	Local lMDTM002	:= IsInCallStack( "MDTM002" )
	Local lMDTM004	:= IsInCallStack( "MDTM004" )
	Local lRet		:= .T.
	Local lExist	:= .F.
	Local cAliasIns	:= ""
	Local nEvento   := 0

	//Caso o sistema deva realizar a validação dos eventos predecessores
	If lVldEvPre
	
		//Caso o envio seja através do Middleware
		If lMiddleware

			//Pega o próximo Alias
			cAliasIns := GetNextAlias()

			//Busca os Xml's do evento S-1005
			aEvento := MDTLstXml( "S1005" )

			For nEvento := 1 To Len( aEvento )

				// Verifica se a inscrição informada existe no arquivo S-1005
				If AllTrim( MDTXmlVal( "S1005", aEvento[ nEvento, 1 ], "/ns:eSocial/ns:evtTabEstab/ns:infoEstab/ns:inclusao/ns:ideEstab/ns:nrInsc", "C" ) ) == AllTrim( cNrInsc ) .Or.;
				AllTrim( MDTXmlVal( "S1005", aEvento[ nEvento, 1 ], "/ns:eSocial/ns:evtTabEstab/ns:infoEstab/ns:alteracao/ns:ideEstab/ns:nrInsc", "C" ) ) == AllTrim( cNrInsc )
					lExist := .T.
					Exit
				EndIf

			Next nEvento

			If ( cTpLocal == "1" ) .Or. ( lMDTM002 .And. cTpLocal == '2' .And. MdtTraAvul( cCodCateg ) )
				lRet := lExist
			ElseIf ( cTpLocal == "2" .And. lMDTM004 ) .Or. ( cTpLocal == "3" .And. lMDTM002 )
				lRet := ( !lExist .And. IIf( cTpInsc == "1", AllTrim( cNrInsc ) <> AllTrim( cInscSM0 ), .T. ) )
			EndIf

		Else

			If ( cTpLocal == "1" ) .Or. ( lMDTM002 .And. cTpLocal == '2' .And. MdtTraAvul( cCodCateg ) )
				lRet := ExistCPO( "C92", cNrInsc, 3 )
			ElseIf ( cTpLocal == "2" .And. lMDTM004 ) .Or. ( cTpLocal == "3" .And. lMDTM002 )
				lRet := ( !ExistCPO( "C92", cNrInsc, 3 ) .And. IIf( cTpInsc == "1", AllTrim( cNrInsc ) <> AllTrim( cInscSM0 ), .T. ) )
			EndIf

		EndIf

	EndIf

Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} MDTAjsData
Ajusta as datas do sistema no formato adequado para cada forma
de envio (TAF ou Middleware)

@return	 cDataRet, Caracter, Data ajustada de acordo com o formato de envio

@sample	 MDTAjsData( 13/05/2020 )

@param	 dData, Date, Data a ser tranformada

@author  Luis Fellipy Bett
@since   13/05/2020
/*/
//-------------------------------------------------------------------
Function MDTAjsData( dData )

	Local cDataRet	:= ""
	Local cAno		:= SubStr( DToS( dData ), 1, 4 )
	Local cMes		:= SubStr( DToS( dData ), 5, 2 )
	Local cDia		:= SubStr( DToS( dData ), 7, 2 )

	If !Empty( dData ) //Caso não tenha sido passada uma data vazia
		If lMiddleware
			cDataRet := cAno + "-" + cMes + "-" + cDia //2020-05-13
		Else
			cDataRet := cAno + cMes + cDia //20200513
		EndIf
	EndIf

Return cDataRet

//-------------------------------------------------------------------
/*/{Protheus.doc} MDTDadFun
Busca algumas informações do funcionário que são utilizadas na
composição das chaves de busca

@return	 aDadFun, Array, Array contendo as informações do funcionário

@sample	 MDTDadFun( "000000001" )

@param	 cFicOrMat, Caracter, Ficha médica ou matrícula do funcionário

@author  Luis Fellipy Bett
@since   13/05/2020
/*/
//-------------------------------------------------------------------
Function MDTDadFun( cFicOrMat, lMat )

	//Variáveis de busca de informações
	Local aDadFun := {}
	Local cNumMat := ""

	Default lMat := .F.

	If FwIsInCallStack( 'MDTA007' )
		cNumMat := M->TM0_MAT
	ElseIf lMat //Caso a matrícula seja passada por parâmetro
		cNumMat := cFicOrMat
	Else
		cNumMat := Posicione( "TM0", 1, xFilial( "TM0" ) + cFicOrMat, "TM0_MAT" ) //Busca a matrícula do funcionário
	EndIf

	//----------------------
	//Posições do retorno
	//1- Matrícula
	//2- Nome
	//3- CPF
	//4- Código Único
	//5- Categoria
	//6- Data de Admissão
	//7- Centro de Custo
	//----------------------
	aDadFun := { cNumMat, ;
				Posicione( "SRA", 1, xFilial( "SRA" ) + cNumMat, "RA_NOME" ), ;
				Posicione( "SRA", 1, xFilial( "SRA" ) + cNumMat, "RA_CIC" ), ;
				Posicione( "SRA", 1, xFilial( "SRA" ) + cNumMat, "RA_CODUNIC" ), ;
				Posicione( "SRA", 1, xFilial( "SRA" ) + cNumMat, "RA_CATEFD" ), ;
				Posicione( "SRA", 1, xFilial( "SRA" ) + cNumMat, "RA_ADMISSA" ), ;
				Posicione( "SRA", 1, xFilial( "SRA" ) + cNumMat, "RA_CC" ) }

Return aDadFun

//-------------------------------------------------------------------
/*/{Protheus.doc} MDTGetIdFun
Busca a informação do  ID do funcionário no SIGATAF

@author Luis Fellipy Bett
@since 24/11/2020

@param cMatricula, Matricula do funcionário na SRA
@param cFilFun, Filial do funcionário a ser considerada

@return cIDFunc, ID do funcionário no TAF
/*/
//-------------------------------------------------------------------
Function MDTGetIdFun( cMatricula, cFilFun )

	Local cCPF		:= ""
	Local cCodUnic	:= ""

	Default cFilFun := cFilAnt

	cCPF 		:= Posicione( "SRA", 1, xFilial( "SRA", cFilFun ) + cMatricula, "RA_CIC" )
	cCodUnic	:= Posicione( "SRA", 1, xFilial( "SRA", cFilFun ) + cMatricula, "RA_CODUNIC" )

Return TAFIdFunc( cCPF, cCodUnic )[ 1 ]

//-------------------------------------------------------------------
/*/{Protheus.doc} MDTBscDtEnv
Busca a data que deverá ser considerada na integração

@return	 dDataEnv, Data, Data a ser considerada no envio do evento

@param	aFuncs, Array, Array contendo as informações do funcionário
@param	nOper, Numérico, Indica a operação que está sendo realizada (3-Inclusão/4-Alteração/5-Exclusão)
@param	lXml, Boolean, Indica se é validação chamada pela geração de xml
@param	dDtAtu, Data, Data de início da exposição atual do funcionário

@sample	 MDTBscDtEnv( { { "100000" } }, 3, .T., 21/10/2021 )

@author  Luis Fellipy Bett
@since   24/11/2020
/*/
//-------------------------------------------------------------------
Function MDTBscDtEnv( aFuncs, nOper, lXml, dDtAtu )

	Local aArea	   		:= GetArea()
	Local aEPIs			:= {}

	Local cEmp		    := FWGrpCompany()
	Local cFilBkp  		:= cFilAnt
	Local cNumRisco		:= ""
	Local cCategoria    := Posicione( 'SRA', 1, xFilial( 'SRA' ) + aFuncs[ 1 ], 'RA_CATEFD' )

	Local dDtAux		:= SToD( "" )
	Local dDtElim		:= SToD( "" )
	Local dDtReco		:= SToD( "" )
	Local dDataEnv		:= SToD( "" )
	Local dDataTra		:= SToD( "" )
	Local dDtAdmis		:= Posicione( "SRA", 1, xFilial( "SRA" ) + aFuncs[ 1 ], "RA_ADMISSA" )
	Local dDtAltSal		:= SToD( "" )
	Local dDtIniTar		:= SToD( "" )
	Local dDtFimTar		:= SToD( "" )

	Local lMudAmb       := .F.
	Local lMDTA130 		:= IsInCallStack( "MDTA130" )
	Local lMDTA125 		:= IsInCallStack( "MDTA125" )
	Local lMDTA215 		:= IsInCallStack( "MDTA215" )
	Local lGpea030  	:= FWIsInCallStack( 'Gpea030' ) // Função
	Local lRelLau		:= FWIsInCallStack( 'MDT181REL' ) ; // Risco
		.Or. FWIsInCallStack( 'MDT232REL' ) ; // Laudo
		.Or. FwIsInCallStack( 'MDTA215' ) ; // Laudos x Riscos
		.Or. FWIsInCallStack( 'MDTA181' ) ; // Relacionamentos do risco
		.Or. FWIsInCallStack( 'MDTA216' ) // Riscos x Laudos

	Local nCont  		:= 0
	Local nCont2 		:= 0

	Default lXml 		:= .F.

	//Adiciona os valores passados ou não pelo array, para as variáveis
	If Len( aFuncs ) > 2 //Caso o risco tenha sido passado no array (MDTA125, MDTA130, MDTA180, MDTA181, MDTA215)
		cNumRisco := IIf( aFuncs[ 3 ] != Nil, aFuncs[ 3 ], "" )
	EndIf
	If Len( aFuncs ) > 4 //Caso a data de início da tarefa tenha sido passada no array (MDTA005, MDTA090A, MDTA882)
		dDtIniTar := IIf( aFuncs[ 5 ] != Nil, aFuncs[ 5 ], SToD( "" ) )
	EndIf
	If Len( aFuncs ) > 5 .And. !MdtTraAvul( cCategoria ) //Caso a data de fim da tarefa tenha sido passada no array (MDTA005, MDTA090A, MDTA882)
		dDtFimTar := IIf( aFuncs[ 6 ] != Nil, aFuncs[ 6 ], SToD( "" ) )
	EndIf
	If Len( aFuncs ) > 6 .And. aFuncs[ 7 ] != Nil //Caso a data de transferência tenha sido passada no array (GPEA180)
		dDataTra := IIf( aFuncs[ 7, 1, 1 ] != Nil, aFuncs[ 7, 1, 1 ], SToD( "" ) )
	EndIf

	//Caso for cadastro de funcionário, Risco ou Risco x Laudos, busca informações das datas do Risco
	If lGPEA010 //Cadastro de Funcionário

		//Busca os riscos a que o funcionário está exposto
		aRisExp := MDTRis2240()

		For nCont := 1 To Len( aRisExp )
			dDtAux := Posicione( "TN0", 1, xFilial( "TN0" ) + aRisExp[ nCont, 1 ], "TN0_DTRECO" )
			If dDtReco < dDtAux
				dDtReco := dDtAux
			EndIf
		Next nCont

	ElseIf lMDTA180 //Cadastro de Risco

		dDtReco := M->TN0_DTRECO
		dDtElim := M->TN0_DTELIM

	ElseIf FWIsInCallStack( 'MDT181REL' ) // Risco
		
		dDtReco := M->TN0_DTRECO
		dDtElim := M->TN0_DTELIM

	ElseIf lMDTA215 //Risco x Laudo

		dDtReco := Posicione( "TN0", 1, xFilial( "TN0" ) + cNumRisco, "TN0_DTRECO" )
		dDtElim := Posicione( "TN0", 1, xFilial( "TN0" ) + cNumRisco, "TN0_DTELIM" )

	ElseIf FWIsInCallStack( 'MDT232REL' )

		dDtReco := Posicione( "TN0", 1, xFilial( "TN0" ) + M->TN0_NUMRIS, "TN0_DTRECO" )

	EndIf

	//---------------------------------------------------------------------------------
	// Verifica pela chamada de cada rotina, qual a data será considerada para o envio
	//---------------------------------------------------------------------------------
	If lGPEA010 //Cadastro de Funcionário

		If lXml //Caso for geração de Xml
			If !Empty( dDtAtu ) //Caso exista registro comunicado para o evento pega a data comunicado, senão pega a data base
				dDataEnv := dDtAtu
			Else
				dDataEnv := dDataBase
			EndIf
		Else
			If nOper != 3
				//Verifica a data de alteração salarial
				dDtAltSal := Posicione( "SRA", 1, xFilial( "SRA" ) + aFuncs[ 1 ], "RA_DATAALT" )
			EndIf

			//Caso as variáveis existirem
			If Type( "aSraHeader" ) == "A" .And. Type( "aSvSraCols" ) == "A"
			
				//Pega a função anterior
				cFuncAnt := GdFieldGet( "RA_CODFUNC", 1, .F., aSraHeader, aSvSraCols )

			EndIf

			//Pega a função atual
			cFuncAtu := GetMemVar( "RA_CODFUNC" )

			If !Empty( cFuncAnt ) .And. cFuncAnt <> cFuncAtu //Caso o funcionário tenha sido alterado de função

				dDataEnv := dDtAltSal

			ElseIf !MDTVld2240( aFuncs[ 1 ] ) //Caso não exista o registro do evento S-2240 para o funcionário no SIGATAF/Middleware

				//Verifica se existe tranferência do funcionário e traz a data da transferência
				dDtTrans := Posicione( "SRE", 2, cEmp + Padr( cFilBkp, Len( SRE->RE_FILIALP ) ) + aFuncs[ 1 ], "RE_DATA" )

				//Verifica qual a data de inicio da exposição
				If dDtReco >= dDtAdmis
					dDataEnv := dDtReco
				ElseIf dDtAdmis > dDtReco
					If dDtAdmis > dDtEsoc
						dDataEnv := dDtAdmis
					ElseIf dDtTrans > dDtEsoc
						dDataEnv := dDtTrans
					Else
						dDataEnv := dDtEsoc
					EndIf
				EndIf

			EndIf
		EndIf

	ElseIf lGPEA180 //Transferência de Funcionário

		dDataEnv := dDataTra

	ElseIf lMDTA090 .Or. lGPEM040

		If dDtIniTar <= dDataBase .And. ( dDataBase <= dDtFimTar .Or. Empty( dDtFimTar ) )
			// Caso tenha iniciado a tarefa, verifica se a ultima exposição é menor
			// se for, utiliza a data de inicio como referencia
			If dDtIniTar >= dDtAtu
				dDataEnv := dDtIniTar
			ElseIf dDtIniTar < dDtAtu
				dDataEnv := dDtAtu
			EndIf

			// Verifica se está finalizanda a Tarefa, caso esteja, utiliza como data base o fim da tarefa
			If !Empty( dDtIniTar ) .And. !Empty( dDtFimTar ) .And. dDtFimTar >= dDataBase
				dDataEnv := dDtFimTar
			EndIf

		Else
			//Se for um lançamento retroativo, verifica se o período é superior ao último lançamento
			If dDtIniTar < dDataBase .And. dDtFimTar < dDataBase .And. !Empty( dDtIniTar ) .And. !Empty( dDtFimTar )
				//Caso data de inicio seja maior que ultimo lançamento, gera novo, se não atualiza
				If dDtIniTar >= dDtAtu
					//Lançar um novo
					dDataEnv := dDtIniTar
				Else
					//Retificar o atual
					dDataEnv := dDtAtu
				EndIf

				//Caso data de fim seja maior que ultimo lançamento, gera novo, se não atualiza
				If dDtFimTar >= dDtAtu
					//Lançar um novo
					dDataEnv := dDtFimTar
				Else
					//Retificar o atual
					dDataEnv := dDtAtu
				EndIf
			EndIf
		EndIf

	ElseIf lGPEA370 .Or. lMDTA130 .Or. lMDTA125 //Relacionamentos do Risco, EPI x Risco, Risco x EPI

		dDataEnv := dDtAtu

	ElseIf lMDTA165 //Cadastro de Ambiente

		If FindFunction( "fMudAmb" )

			lMudAmb := fMudAmb( aFuncs[ 1 ] ) //Verifica se mudou de ambiente físico

			If lMudAmb
				dDtAtu := ""
			EndIf

		EndIf

		If !Empty( dDtAtu ) //Caso exista registro do S-2240 no TAF
			dDataEnv := dDtAtu
		ElseIf lMudAmb
			dDataEnv := dDataBase
		Else
			If dDtAdmis > dDtEsoc //Caso a admissão do funcionário for posterior ao inicio das obrigatoriedades
				dDataEnv := dDtAdmis
			Else
				dDataEnv := dDtEsoc
			EndIf
		EndIf

	ElseIf lMDTA695 .Or. lMDTA630 .Or. lMATA185 //Entrega de EPI's

		//Salva os EPIs no array auxiliar
		aEPIs := aFuncs[ 8 ]

		//Busca a última data de entrega do EPI
		For nCont2 := 1 To Len( aEPIs )
			If dDtAux < aEPIs[ nCont2, 2 ]
				dDtAux := aEPIs[ nCont2, 2 ]
			EndIf
		Next nCont2

		dDataEnv := dDtAux //A data de entrega de EPI mais atual

	ElseIf lMDTA881 //Carga Inicial Riscos

		//Caso a admissão do funcionário tenha sido feita após o início da obrigatoriedade
		If dDtAdmis > dDtEsoc
			dDataEnv := dDtAdmis
		Else
			dDataEnv := dDtEsoc
		EndIf

	ElseIf lMDTA882 //Schedule Tarefas

		dDataEnv := dDataBase

	ElseIf lMDTA180 //Cadastro de Risco

		If nOper == 5 //SE EU ESTIVER EXCLUINDO ----------------------------------------------

			dDataEnv := dDataBase

		ElseIf !Empty( dDtElim ) //SE EU ESTIVER ELIMINANDO ---------------------------------

			If dDtElim <= dDtAtu
				dDataEnv := dDtAtu
			ElseIf dDtElim > dDtAtu
				dDataEnv := dDtElim
			EndIf

		Else

			If SuperGetMv( 'MV_NG2VLAU', .F., '2' ) == '2' // Não necessário vínculo do risco com o laudo

				If MDTVld2240( aFuncs[ 1 ], Nil, IIf( dDtAdmis > dDtReco, dDtAdmis, dDtReco ) )

					If nOper == 3
						If dDtReco <= dDtAtu
							dDataEnv := dDtAtu
						ElseIf dDtReco > dDtAtu
							dDataEnv := dDtReco
						EndIf
					Else
						dDataEnv := dDtAtu
					EndIf

				Else //Caso não exista o registro S-2240 para o funcionário, valida como sendo inclusão do registro na CM9

					If dDtAdmis > dDtReco
						dDataEnv := dDtAdmis
					Else
						dDataEnv := dDtReco
					EndIf

				EndIf

			Else // Necessário vínculo

				dDataEnv := fBusDatEve( aFuncs[ 1 ] )

			EndIf

		EndIf

	ElseIf lRelLau // Relacionamento do laudo com o risco
		
		If !Empty( dDtAtu )
			If dDtReco > dDtAtu
				dDataEnv := dDtReco
			Else
				dDataEnv := dDtAtu
			EndIf
		Else
			If dDtAdmis > dDtReco
				dDataEnv := dDtAdmis
			Else
				dDataEnv := dDtReco
			EndIf
		EndIf

	ElseIf lGpea030

		dDataEnv := dDtAtu

	EndIf

	cFilAnt := cFilBkp //Retorna para filial atual
	RestArea( aArea ) //Retorna área

Return dDataEnv

//-------------------------------------------------------------------
/*/{Protheus.doc} MDTDtExpAtu
Busca a data atual de exposição do funcionário ao evento S-2240

@author	Luis Fellipy Bett
@since 24/11/2020

@param	cMatricula, matrícula do funcionário a ter a data buscada

@return	dDtAtu, data da exposição mais recente do funcionário
/*/
//-------------------------------------------------------------------
Function MDTDtExpAtu( cMatricula )

	//Variáveis de controle de área/filial
	Local aArea	  := GetArea()
	Local cFilBkp := cFilAnt

	//Variáveis de tabela temporária
	Local cAliasFunc := GetNextAlias() //Pega o próximo Alias

	//Variáveis de busca de informação
	Local aEvento := {}
	Local dDtAtu  := SToD( "" )

	If lMiddleware //Caso seja integração através do Middleware

		//Busca os Xml's do evento e funcionário passado por parâmetro
		aEvento := MDTLstXml( "S2240", cMatricula )

		//Passa o Xml para buscar a informação da data de exposição
		If Len( aEvento ) > 0
			dDtAtu := MDTXmlVal( "S2240", aEvento[ 1, 1 ], "/ns:eSocial/ns:evtExpRisco/ns:infoExpRisco/ns:dtIniCondicao", "D" )
		EndIf

	Else //Caso seja integração através do SIGATAF

		cIDFunc := MDTGetIdFun( cMatricula ) //Busca o ID do funcionário do TAF

		BeginSQL Alias cAliasFunc
			SELECT CM9.CM9_ID, CM9.CM9_DTINI
				FROM %table:CM9% CM9
				WHERE CM9.CM9_FILIAL = %xFilial:CM9% AND
						CM9.CM9_FUNC = %exp:cIDFunc% AND
						CM9.%NotDel%
				ORDER BY CM9.CM9_DTINI DESC
		EndSQL

		dbSelectArea( cAliasFunc )
		dDtAtu := SToD( ( cAliasFunc )->( CM9_DTINI ) )

		( cAliasFunc )->( dbCloseArea() )

	EndIf

	cFilAnt := cFilBkp //Retorna para filial atual
	RestArea( aArea ) //Retorna área

Return dDtAtu

//-------------------------------------------------------------------
/*/{Protheus.doc} MDTLstXml
Busca os Xml's existentes referente ao evento e funcionário passado por parâmetro

@author	Luis Fellipy Bett
@since	01/03/2021

@param	cEvento, Caracter, Evento para que será buscado o Xml
@param	cMatricula, Caracter, Matrícula do funcionário a ter o Xml buscado

@return, aEvento, contém as informações buscadas
/*/
//-------------------------------------------------------------------
Function MDTLstXml( cEvento, cMatricula )

	//Variáveis para busca das informações da empresa
	Local aInfoC	 := fXMLInfos()
	Local cTpInsc	 := ""
	Local cNrInsc	 := "0"
	Local lAdmPubl	 := .F.
	Local cChave	 := ""
	Local cNrInscChv := ""

	//Variáveis para busca das informações do funcionário
	Local aEvento    := {}
	Local aDadFun	 := ""
	Local cCPFAux	 := ""
	Local cUnicAux	 := ""
	Local cCategAux	 := ""
	Local cPesquisa  := ''
	Local dAdmisAux	 := ""

	//Define o valor padrão para as variáveis
	Default cMatricula := ""

	//Caso tenha sido passado uma matrícula por parâmetro
	If !Empty( cMatricula )
		aDadFun   := MDTDadFun( cMatricula, .T. )
		cCPFAux	  := aDadFun[3]
		cUnicAux  := aDadFun[4]
		cCategAux := aDadFun[5]
		dAdmisAux := aDadFun[6]
	EndIf

	//Busca as informações da empresa
	If Len( aInfoC ) >= 4
		cTpInsc  := aInfoC[1]
		cNrInsc  := aInfoC[2]
		lAdmPubl := aInfoC[4]
	EndIf

	//Monta a chave para busca do registro
	If cEvento == "S1005"
		cChave := cFilEnv + AllTrim( cNrInsc )
	Else
		If MDTVerTSVE( cCategAux ) //Caso for Trabalhador Sem Vínculo Estatutário
			cChave := AllTrim( cCPFAux ) + AllTrim( cCategAux ) + DToS( dAdmisAux )
		Else
			cChave := AllTrim( cUnicAux )
		EndIf
	EndIf

	//Monta a inscrição a ser considerada na busca dos xml's
	cNrInscChv := Padr( IIf( !lAdmPubl .And. cTpInsc == "1", SubStr( cNrInsc, 1, 8 ), cNrInsc ), TAMSX3( "RJE_INSCR" )[1] )

	cPesquisa := cTpInsc + cNrInscChv + cEvento

	DbSelectArea( 'RJE' )
	DbSetOrder( 2 )

	If DbSeek( cPesquisa + cChave )

		While ( 'RJE' )->( !Eof() ) .And. RJE->RJE_TPINSC + RJE->RJE_INSCR + RJE->RJE_EVENTO == cPesquisa .And. cChave $ RJE->RJE_KEY

			aAdd( aEvento, {;
				RJE->RJE_XML,;
				RJE->RJE_RECIB,;
				RJE->RJE_DTENV,;
				DtoS( RJE->RJE_DTG ),;
				RJE->RJE_HORAG;
			} )

			( 'RJE' )->( DbSkip() )

		End

		aSort( aEvento, Nil, Nil, { | x, y | x[ 4 ] + x [ 5 ] > y[ 4 ] + y[ 5 ] } ) // Ordena pelos eventos mais recentes

	EndIf

Return aEvento

//-------------------------------------------------------------------
/*/{Protheus.doc} MDTVerEsoc
Busca a versão do leiaute a ser considerada no envio dos eventos de SST ao eSocial

@return	cVersMDT, Caracter, Versão do leiaute a ser utilizado para os eventos de SST

@param	cEvento, Caracter, Evento que está sendo enviado ao Governo

@sample	MDTVerEsoc()

@author	Luis Fellipy Bett
@since	26/04/2021
/*/
//-------------------------------------------------------------------
Function MDTVerEsoc( cEvento )

	Local cVersMDT := ""
	Local cVersGPE := ""

	If FindFunction( "fVersEsoc" )
		fVersEsoc( cEvento, .F., /*aRetGPE*/ , /*aRetTAF*/ , Nil, Nil, @cVersGPE )
	EndIf

	cVersMDT := SuperGetMv( 'MV_VLESOC', .F., "S_01_01" )

	If SubStr( cVersMDT, 1, 1 ) != "_"
		cVersMDT := "_" + cVersMDT
	EndIf

Return cVersMDT

//-------------------------------------------------------------------
/*/{Protheus.doc} fVerStack
Verifica a chamada dos fontes de acordo com o fonte passado por parâmetro

@return	lRet, Boolean, .T. caso seja chamada do fonte do parâmetro

@param	cFonVer, Caracter, Fonte da chamada a ser verificado
@param	oModelTNC, Objeto, Objeto do modelo do cadastro de Acidentes

@sample	fVerStack( "MDTA640", oModelTNC )

@author	Luis Fellipy Bett
@since	27/05/2021
/*/
//-------------------------------------------------------------------
Static Function fVerStack( cFonVer, oModelTNC )

	Local lRet	:= .T.
	Local lAcid	:= oModelTNC <> Nil

	If cFonVer == "MDTA640" //Acidente
		lRet := IsInCallStack( "MDTA640" ) .Or. lAcid
	ElseIf cFonVer == "MDTA155" //Diagnóstico
		lRet := !lAcid .And. ( IsInCallStack( "MDTA155" ) .Or. IsInCallStack( "NG155CID" ) .Or. IsInCallStack( "MDT155GDI" ) .Or. FwIsInCallStack( 'MDTA155B' ) .Or. FwIsInCallStack( 'Mdta156' ) )
	ElseIf cFonVer == "MDTA685" //Atestado
		lRet := ( IsInCallStack( "MDTA685" ) .Or. IsInCallStack( "MDT685POS" ) .Or. IsInCallStack( "MDT685COMM" ) ) .And. !lAcid
	EndIf

Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} fFunNaoEnv
Valida se o evento do funcionário deve ser enviado ou não ao Governo

@return	aFunNao, Array, Array contendo os funcionários que não serão comunicados

@param	cEvento, Caracter, Evento que está sendo enviado
@param	aFuncs, Array, Array contendo os funcionários a serem validados
@param	nOper, Numérico, Indica a operação que está sendo realizada (3-Inclusão/4-Alteração/5-Exclusão)

@sample	fFunNaoEnv( "S-2240", { { "0000236" } } )

@author	Luis Fellipy Bett
@since	17/06/2021
/*/
//-------------------------------------------------------------------
Static Function fFunNaoEnv( cEvento, aFuncs, nOper, aFunNaoEnv )

	//Salva a área
	Local aArea := GetArea()

	Local cCategAut	 := SuperGetMv( "MV_NTSV", .F., "701/711/712/741" )
	Local cCategNao	 := SuperGetMv( "MV_NG2NENV", .F., "" )
	Local dDtDemis	 := SToD( "" )
	Local cFilBkp	 := cFilAnt
	Local cNomeFunc	 := ""
	Local cCatgFunc	 := ""
	Local cCpfFunc	 := ""
	Local cCodUnic	 := ""
	Local cSitFolh	 := ""
	Local cVersEnvio := ""
	Local nCont		 := 0
	Local nPosReg	 := 0
	Local nOpcAdd	 := 9
	Local lAdmPre	 := .F.

	//---------------------------
	// Busca a versão do leiaute
	//---------------------------
	fVersEsoc( "S2200", .F., , , @cVersEnvio )

	//-------------------------------------------------------
	// Percorre o array analisando as condições de não envio
	//-------------------------------------------------------
	For nCont := 1 To Len( aFuncs )

		//---------------------------------------------------------------------------
		// Função genérica para posicionar na filial correta em chamadas específicas
		//---------------------------------------------------------------------------
		fPosFil( cEvento, IIf( Len( aFuncs[ nCont ] ) > 1 .And. aFuncs[ nCont, 2 ] <> Nil, aFuncs[ nCont, 2 ], "" ) )

		//Busca as informações do funcionário
		cNomeFunc := AllTrim( Posicione( "SRA", 1, xFilial( "SRA" ) + aFuncs[ nCont, 1 ], "RA_NOME" ) )
		cCatgFunc := Posicione( "SRA", 1, xFilial( "SRA" ) + aFuncs[ nCont, 1 ], "RA_CATEFD" )
		cCpfFunc  := Posicione( "SRA", 1, xFilial( "SRA" ) + aFuncs[ nCont, 1 ], "RA_CIC" )
		cCodUnic  := Posicione( "SRA", 1, xFilial( "SRA" ) + aFuncs[ nCont, 1 ], "RA_CODUNIC" )
		dDtDemis  := Posicione( "SRA", 1, xFilial( "SRA" ) + aFuncs[ nCont, 1 ], "RA_DEMISSA" )
		cSitFolh  := Posicione( "SRA", 1, xFilial( "SRA" ) + aFuncs[ nCont, 1 ], "RA_SITFOLH" )
		lAdmPre	  := fVerAdmPre( cCpfFunc, cCodUnic, cCatgFunc )

		//-------------------------------------------------------------------------
		// Realiza validações para verificar se o funcionário não deve ser enviado
		//-------------------------------------------------------------------------
		If !Empty( dDtDemis ) .And. cSitFolh == "D" .And. cEvento <> "S-2220" .And. !IsInCallStack( "fEnvTaf180" ) //Caso o funcionário esteja demitido e não seja envio do evento S-2220
			nOpcAdd := 0
		ElseIf cCatgFunc $ cCategNao //Caso a categoria do funcionário esteja no parâmetro MV_NG2NENV
			nOpcAdd := 1
		ElseIf cCatgFunc $ cCategAut //Caso a categoria do funcionário esteja no parâmetro MV_NTSV
			nOpcAdd := 2
		ElseIf lAdmPre .And. cVersEnvio < "9.0.00" //Caso o funcionário esteja em admissão preliminar e o leiaute não for o S-1.0
			nOpcAdd := 3
		EndIf

		//Caso o funcionário não deva ser enviado, adiciona ao array
		If nOpcAdd <> 9
			aAdd( aFunNaoEnv, { nOpcAdd, aFuncs[ nCont, 1 ], cNomeFunc, cCatgFunc } )
			nOpcAdd := 9 //Volta a variável para validar o próximo funcionário do laço
		EndIf

	Next nCont

	//-----------------------------------------------------------------------
	// Caso exista funcionários que não devem ser enviados, deleta do array
	//-----------------------------------------------------------------------
	If Len( aFunNaoEnv ) > 0
		For nCont := 1 To Len( aFunNaoEnv )
			If ( nPosReg := aScan( aFuncs, { |x| x[ 1 ] == aFunNaoEnv[ nCont, 2 ] } ) ) > 0
				aDel( aFuncs, nPosReg ) //Deleta registro do array
				aSize( aFuncs, Len( aFuncs ) - 1 ) //Diminui a posição excluída do array
			EndIf
		Next nCont
	EndIf

	//Volta a filial
	cFilAnt := cFilBkp

	//Retorna a área
	RestArea( aArea )

Return

//-------------------------------------------------------------------
/*/{Protheus.doc} fMsgNaoEnv
Exibe a mensagem informando quais funcionários não foram comunicados

@return	Nil, Nulo

@param	aNaoEnv, Array, Array contendo os funcionários que não foram enviados
@param	cMsgInc, Caracter, Variável que recebe os funcionários que não foram enviados

@sample	fMsgNaoEnv( { { "0000236" } }, "" )

@author	Luis Fellipy Bett
@since	21/06/2021
/*/
//-------------------------------------------------------------------
Static Function fMsgNaoEnv( aNaoEnv, cMsgInc )

	Local cMsg1	   := STR0071 //"Os trabalhadores abaixo não foram comunicados pois se enquadram em alguma condição de não envio. Para saber mais sobre as condições clique no botão 'Abrir'."
	Local cMsg2	   := ""
	Local nCont	   := 0
	Local aArrAux1 := {}
	Local aArrAux2 := {}
	Local aArrAux3 := {}
	Local aArrAux4 := {}
	Local aValida5 := {}

	//Percorre todos os funcionários que não serão enviados e adiciona de acordo com a condição de não envio
	For nCont := 1 To Len( aNaoEnv )

		If aNaoEnv[ nCont, 1 ] == 1
			aAdd( aArrAux1, STR0024 + ": " + aNaoEnv[ nCont, 2 ] + " - " + aNaoEnv[ nCont, 3 ] + " / " + STR0072 + ": " + aNaoEnv[ nCont, 4 ] ) //Funcionário##Categoria
		ElseIf aNaoEnv[ nCont, 1 ] == 2
			aAdd( aArrAux2, STR0024 + ": " + aNaoEnv[ nCont, 2 ] + " - " + aNaoEnv[ nCont, 3 ] + " / " + STR0072 + ": " + aNaoEnv[ nCont, 4 ] ) //Funcionário##Categoria
		ElseIf aNaoEnv[ nCont, 1 ] == 3
			aAdd( aArrAux3, STR0024 + ": " + aNaoEnv[ nCont, 2 ] + " - " + aNaoEnv[ nCont, 3 ] ) //Funcionário
		ElseIf aNaoEnv[ nCont, 1 ] == 4
			aAdd( aArrAux4, STR0024 + ": " + aNaoEnv[ nCont, 2 ] + " - " + aNaoEnv[ nCont, 3 ] ) //Funcionário
		ElseIf aNaoEnv[ nCont, 1 ] == 5
			aAdd( aValida5, STR0024 + ": " + AllTrim( aNaoEnv[ nCont, 2 ] ) + " - " + AllTrim( aNaoEnv[ nCont, 3 ] ) ) // Funcionário
		EndIf

	Next nCont

	//Compõem a variável da mensagem com os funcionários que tem a categoria no parâmetro MV_NG2NENV
	If Len( aArrAux1 ) > 0
		cMsg2 += STR0076 + ": " + CRLF //"Os funcionários abaixo não foram comunicados devido terem suas categorias definidas no parâmetro MV_NG2NENV"
		For nCont := 1 To Len( aArrAux1 ) //Percorre o array adicionando os funcionários
			cMsg2 += aArrAux1[ nCont ] + CRLF
		Next nCont
	EndIf

	//Compõem a variável da mensagem com os funcionários que tem a categoria no parâmetro MV_NTSV
	If Len( aArrAux2 ) > 0
		cMsg2 += IIf( Empty( cMsg2 ), "", CRLF )
		cMsg2 += STR0074 + ": " + CRLF //"Os funcionários abaixo não foram comunicados devido terem suas categorias definidas no parâmetro MV_NTSV"
		For nCont := 1 To Len( aArrAux2 ) //Percorre o array adicionando os funcionários
			cMsg2 += aArrAux2[ nCont ] + CRLF
		Next nCont
	EndIf

	//Compõem a variável da mensagem com os funcionários que estão em admissão preliminar e o leiaute é anterior a versão S-1.0
	If Len( aArrAux3 ) > 0
		cMsg2 += IIf( Empty( cMsg2 ), "", CRLF )
		cMsg2 += STR0075 + ": " + CRLF //"Os funcionários abaixo não foram comunicados devido estarem em admissão preliminar e o leiaute ser anterior a versão S-1.0"
		For nCont := 1 To Len( aArrAux3 ) //Percorre o array adicionando os funcionários
			cMsg2 += aArrAux3[ nCont ] + CRLF
		Next nCont
	EndIf

	//Compõem a variável da mensagem com os funcionários que não estão expostos a riscos e o parâmetro MV_NG2DENO está com data superior ao do envio dos eventos
	If Len( aArrAux4 ) > 0
		cMsg2 += IIf( Empty( cMsg2 ), "", CRLF )
		cMsg2 += STR0093 + ": " + CRLF //"Os funcionários abaixo não foram comunicados pois não estão expostos a riscos e o parâmetro MV_NG2DENO está definido com uma data superior à data a ser considerada no envio do evento"
		For nCont := 1 To Len( aArrAux4 ) //Percorre o array adicionando os funcionários
			cMsg2 += aArrAux4[ nCont ] + CRLF
		Next nCont
	EndIf

	If Len( aValida5 ) > 0

		cMsg2 += IIf( Empty( cMsg2 ), '', CRLF )
		cMsg2 += STR0101 + CRLF + CRLF // "Os funcionários abaixo são funcionários com categoria eSocial 2XX. O evento S-2240 de um funcionário avulso somente será gerado a partir da rotina de tarefas (mdta090)."

		For nCont := 1 To Len( aValida5 )
			cMsg2 += aValida5[ nCont ] + CRLF
		Next nCont

	EndIf

	//Caso existam funcionários a serem informados na mensagem
	//Caso forem funcionários demitidos o sistema não emite na mensagem mas passa por essa função
	If !Empty( cMsg2 )

		//Caso não for execução automática mostra a mensagem
		If !lExecAuto
			MDTMEMOLINK( STR0073, cMsg1, "https://tdn.totvs.com/x/FE9uJQ", cMsg2 ) //Funcionários não comunicados
		Else
			//Adiciona as informações na variável de retorno
			cMsgInc += cMsg1 + CRLF
			cMsgInc += "https://tdn.totvs.com/x/FE9uJQ" + CRLF
			cMsgInc += cMsg2 + CRLF
		EndIf

	EndIf

Return

//-------------------------------------------------------------------
/*/{Protheus.doc} fVerAdmPre
Verifica se o funcionário está em admissão preliminar

@return	lAdmPre, Boolean, .T. caso seja admissão preliminar senão .F.

@param	cCPF, Caracter, CPF do funcionário
@param	cCodUnic, Caracter, Código único do funcionário
@param	cCodCateg, Caracter, Categoria do funcionário

@sample	fVerAdmPre( "41458562875", "T1D MG 01 10000020180305111429", "701" )

@author	Luis Fellipy Bett
@since	06/07/2021
/*/
//-------------------------------------------------------------------
Static Function fVerAdmPre( cCPF, cCodUnic, cCodCateg )

	Local lTSVE	  := MDTVerTSVE( cCodCateg )
	Local lAdmPre := .F.

	Help := .T. //Desabilita as mensagens de Help

	//Caso o registro do funcionário exista na tabela do S-2190 e não exista na do S-2200 ou S-2300
	If ExistCPO( "T3A", cCPF, 2 ) .And. !( IIf( lTSVE, ExistCPO( "C9V", cCPF, 3 ), ExistCPO( "C9V", cCodUnic, 11 ) ) )
		lAdmPre := .T.
	EndIf

	Help := .F. //Habilita as mensagens de Help

Return lAdmPre

//-------------------------------------------------------------------
/*/{Protheus.doc} fVldEsp2240
Realiza verificações específicas para o evento S-2240

@return	Nil, Nulo

@param	cMsgInc, Caracter, Mensagem de inconsistências a ser retornada
@param	aFuncs, Array, Array contendo os funcionários para validação
@param	nOper, Numérico, Indica a operação que está sendo realizada (3-Inclusão/4-Alteração/5-Exclusão)

@sample	fVldEsp2240( "", { { "000230" } }, 3 )

@author	Luis Fellipy Bett
@since	20/07/2021
/*/
//-------------------------------------------------------------------
Static Function fVldEsp2240( cMsgInc, aFuncs, nOper )

	//---------------------------------------------------
	// Realiza verificações especiais para cada chamada
	//---------------------------------------------------
	If lGPEA010 //Caso for cadastro de funcionário

		//Verifica as tarefas vinculadas aos funcionários
		fVldTarFun( @cMsgInc, aFuncs )

		//Verifica se o funcionário está vinculado a um ambiente
		fVldAmbFun( @cMsgInc, aFuncs, nOper )

		//Verifica se o funcionário está sendo cadastrado como admissão futura
		fVldAdmFut( @cMsgInc, aFuncs )

		//Verifica se existem EPI's entregues ao funcionário quando o risco está definido como sendo necessita EPI
		Processa( { || fVldEPIFun( @cMsgInc, aFuncs, nOper ) }, STR0090 ) //Valida as informações a serem enviadas ## "Aguarde, verificando os EPI's entregues ao funcionário..."

	ElseIf lGPEA180 //Caso for transferência de funcionário

		//Verifica as tarefas vinculadas aos funcionários
		fVldTarFun( @cMsgInc, aFuncs )

		//Verifica se o funcionário está vinculado a um ambiente
		fVldAmbFun( @cMsgInc, aFuncs, nOper )

		//Verifica se existem EPI's entregues ao funcionário quando o risco está definido como sendo necessita EPI
		Processa( { || fVldEPIFun( @cMsgInc, aFuncs, nOper ) }, STR0090 ) //Valida as informações a serem enviadas ## "Aguarde, verificando os EPI's entregues ao funcionário..."

	ElseIf lMDTA090 //Caso for cadastro de tarefas

		//Verifica as tarefas vinculadas aos funcionários
		fVldTarFun( @cMsgInc, aFuncs )

		//Verifica se o funcionário está vinculado a um ambiente
		fVldAmbFun( @cMsgInc, aFuncs, nOper )

		//Verifica se existem EPI's entregues ao funcionário quando o risco está definido como sendo necessita EPI
		Processa( { || fVldEPIFun( @cMsgInc, aFuncs, nOper ) }, STR0090 )

	ElseIf lMDTA165 //Caso for cadastro de de ambiente físico

		//Verifica as tarefas vinculadas aos funcionários
		fVldTarFun( @cMsgInc, aFuncs )

		//Verifica se existem EPI's entregues ao funcionário quando o risco está definido como sendo necessita EPI
		Processa( { || fVldEPIFun( @cMsgInc, aFuncs, nOper ) }, STR0090 ) //Valida as informações a serem enviadas ## "Aguarde, verificando os EPI's entregues ao funcionário..."

	ElseIf lMDTA180 //Caso cadastro de risco

		//Verifica se existem EPI's entregues ao funcionário quando o risco está definido como sendo necessita EPI
		Processa( { || fVldEPIFun( @cMsgInc, aFuncs, nOper ) }, STR0090 ) //Valida as informações a serem enviadas ## "Aguarde, verificando os EPI's entregues ao funcionário..."

	ElseIf lMDTA695 .Or. lMDTA630 //Caso cadastro de EPI

		//Verifica as tarefas vinculadas aos funcionários
		fVldTarFun( @cMsgInc, aFuncs )

	EndIf

Return

//-------------------------------------------------------------------
/*/{Protheus.doc} fVldFunAvu
Verifica se os funcionário é avulso. Funcionários avulsos só devem
gerar o evento através da rotina de tarefa.

@author Gabriel Sokacheski
@since 06/10/2022

@param aFuncs, contém as informações dos funcionários para validação
@param aFuncs, contém as informações dos funcionários excluídos
@param nOper, indica a operação que está sendo realizada

@return, lEnvia, indica se existe um evento a ser gerado
/*/
//-------------------------------------------------------------------
Static Function fVldFunAvu( aFuncs, aFunNaoEnv, nOper )

	Local aArea := GetArea( 'SRA' )

	Local aTarefa := {}

	Local dEnvio := CtoD( '  /  /    ' )

	Local lEnvia := .F.

	Local nFun := 0
	Local nPos := 0

	For nFun := 1 To Len( aFuncs )

		DbSelectArea( 'SRA' )
		DbSetOrder( 1 )
		If DbSeek( xFilial( 'SRA' ) + aFuncs[ nFun, 1 ] )

			dEnvio := MDTBscDtEnv( aFuncs[ nFun ], nOper, Nil, MDTDtExpAtu( SRA->RA_MAT ) )

			If MdtTraAvul( SRA->RA_CATEFD ) .And. Mdt062022( dEnvio )

				aTarefa := MdtFunTar( SRA->RA_MAT, dEnvio )

				If ( Empty( aTarefa ) .Or. Empty( aTarefa[ 3 ] ) ) // Se não possuir tarefa com a data de término preenchida

					aAdd( aFunNaoEnv, { 5, SRA->RA_MAT, SRA->RA_NOME } )

				EndIf

			EndIf

		EndIf

	Next nFun

	If Len( aFuncs ) > Len( aFunNaoEnv )
		lEnvia := .T.
	EndIf

	If Len( aFunNaoEnv ) > 0

		For nFun := 1 To Len( aFunNaoEnv )

			If ( nPos := aScan( aFuncs, { | x | x[ 1 ] == aFunNaoEnv[ nFun, 2 ] } ) ) > 0
				aDel( aFuncs, nPos )
				aSize( aFuncs, Len( aFuncs ) - 1 )
			EndIf

		Next nFun

	EndIf

	RestArea( aArea )

Return lEnvia

//-------------------------------------------------------------------
/*/{Protheus.doc} fVldTarFun
Verifica se os funcionários passados por parâmetro estão vinculados
a alguma tarefa

@return	Nil, Nulo

@param	cMsgInc, Caracter, Variável que grava as inconsistências (caso houver)
@param	aFuncs, Array, Array contendo as informações dos funcionários para validação

@sample	fVldTarFun( "", { { "000230" } } )

@author	Luis Fellipy Bett
@since	22/07/2021
/*/
//-------------------------------------------------------------------
Static Function fVldTarFun( cMsgInc, aFuncs )

	Local aArea	   	:= GetArea() // Salva a área
	Local aTarFun  	:= {}
	Local aGPEA180	:= {}

	Local cTpDesc  	:= SuperGetMv( 'MV_NG2TDES', .F., '1' )
	Local cTarefa	:= ''
	Local cTxtMemo 	:= ''

	Local lFicha 	:= .F.
	Local lGetTar  	:= .T.

	Local nCont	   	:= 0
	Local nCont2   	:= 0

	Local oModel	:= Nil

	If lMDTA090
		oModel := FwModelActive()
		lFicha := oModel:GetId() == 'mdta007b' // Chamado na rotina de ficha médica
	EndIf

	//----------------------------------------------
	// Caso o parâmetro for definido como 1- Tarefa
	//----------------------------------------------
	If cTpDesc == "1"

		//---------------------------------------------------------------------------
		// Percorre os funcionários para validar se estão vinculados a alguma tarefa
		//---------------------------------------------------------------------------
		For nCont := 1 To Len( aFuncs )

			//Caso for transferência de funcionário
			If lGPEA180
			
				//Salva as informações da transferência
				aGPEA180 := aFuncs[ nCont, 7 ]

				//Verifica se é transferência de empresa ou filial, caso for não deve buscar as tarefas pois não tem como o funcionário 
				//ter tarefa na empresa ou filial destino antes da transferência
				lGetTar := aGPEA180[ 1, 2 ] == aGPEA180[ 1, 3 ] .And. aGPEA180[ 1, 4 ] == aGPEA180[ 1, 5 ]

			EndIf

			//Caso deva buscar as tarefas do funcionário
			If lGetTar

				//Se for chamado pelo MDTA090 e não for exclusão, pega as tarefas diretamente da Grid
				If lMDTA090 .And. oModel:GetOperation() <> 5

					If !lFicha
						cTarefa := oModel:GetValue( 'TN5MASTER', 'TN5_CODTAR' )
					EndIf

					oGridTN6 := oModel:GetModel( "TN6DETAIL" )

					For nCont2 := 1 To oGridTN6:Length()

						oGridTN6:GoLine( nCont2 )

						If oGridTN6:GetValue( "TN6_MAT" ) == aFuncs[ nCont, 1 ] .And. !oGridTN6:IsDeleted()

							If lFicha
								cTarefa := oGridTN6:GetValue( 'TN6_CODTAR' )
							EndIf

							aAdd( aTarFun, { cTarefa } )

							Exit

						EndIf

					Next nCont2

				EndIf

				//Caso não tenha nenhuma atividade vinculada na grid ao funcionário, verifica em toda a TN6
				If Len( aTarFun ) == 0
					dbSelectArea( "TN6" )
					dbSetOrder( 2 )
					If dbSeek( xFilial( "TN6" ) + aFuncs[ nCont, 1 ] )
						While TN6->( !Eof() ) .And. TN6->TN6_FILIAL == xFilial( "TN6" ) .And. TN6->TN6_MAT == aFuncs[ nCont, 1 ]
							If !lMDTA090 .Or. ( !lFicha .And. TN6->TN6_CODTAR != oModel:GetValue( 'TN5MASTER', 'TN5_CODTAR' ) )
								aAdd( aTarFun, { TN6->TN6_CODTAR } )
								Exit
							EndIf
							TN6->( dbSkip() )
						End
					EndIf
				EndIf

			EndIf

			//Caso não exista nenhuma tarefa vinculada ao funcionário, add no array
			If Len( aTarFun ) == 0
				cTxtMemo += STR0024 + ": " + AllTrim( aFuncs[ nCont, 1 ] ) + " - " + AllTrim( Posicione( "SRA", 1, xFilial( "SRA" ) + aFuncs[ nCont, 1 ], "RA_NOME" ) ) + CRLF //Funcionário
			EndIf

			//Zera o array para validar o próximo funcionário
			aTarFun := {}

		Next nCont

		//--------------------------------------------------------
		// Caso existir funcionários sem tarefa, exibe a mensagem
		//--------------------------------------------------------
		If !Empty( cTxtMemo )
			
			// Caso não for execução automática mostra a mensagem
			If !lExecAuto
				MDTMEMOLINK( STR0080, STR0079, "https://tdn.totvs.com/x/o0ebJg", cTxtMemo ) //"Funcionários sem tarefa"##"O parâmetro MV_NG2TDES está definido como '1- Tarefa' e os funcionários abaixo estão sem tarefa. Para saber sobre como proceder em cada situação de funcionário sem tarefa clique no botão 'Abrir'."
			Else
				//Adiciona as informações na variável de retorno
				cMsgInc += STR0079 + CRLF
				cMsgInc += "https://tdn.totvs.com/x/o0ebJg" + CRLF
				cMsgInc += cTxtMemo + CRLF
			EndIf

		EndIf
	EndIf

	//Retorna a área
	RestArea( aArea )

Return

//-------------------------------------------------------------------
/*/{Protheus.doc} fVldAmbFun
Verifica se os funcionários passados por parâmetro estão vinculados
a algum ambiente

@return	Nil, Nulo

@param	cMsgInc, Caracter, Variável que grava as inconsistências (caso houver)
@param	aFuncs, Array, Array contendo as informações dos funcionários para validação
@param	nOper, Numérico, Indica a operação que está sendo realizada (3-Inclusão/4-Alteração/5-Exclusão)

@sample	fVldAmbFun( "", { { "000230" } }, 3 )

@author	Luis Fellipy Bett
@since	11/11/2021
/*/
//-------------------------------------------------------------------
Static Function fVldAmbFun( cMsgInc, aFuncs, nOper )

	Local aArea	   := GetArea() //Salva a área
	Local cEntAmb  := SuperGetMv( "MV_NG2EAMB", .F., "1" ) //Indica qual entidade será considerada no relacionamento com o ambiente
	Local lTOT	   := AliasInDic( "TOT" ) //Ambiente x Tarefa
	Local lTOU	   := AliasInDic( "TOU" ) //Ambiente x Funcionário
	Local dDataEnv := SToD( "" )
	Local dDtAtu   := SToD( "" )
	Local lExsTar  := .F.
	Local lGetRegs := .T.
	Local cTxtMemo := ""
	Local cMsg1	   := ""
	Local cMsg2	   := ""
	Local cLink	   := ""
	Local aTarefas := {}
	Local aGPEA180 := {}
	Local nCont	   := 0
	Local nTar	   := 0

	//-----------------------------------------------------------
	// Caso o vínculo do ambiente seja por tarefa ou funcionário
	//-----------------------------------------------------------
	If ( cEntAmb == "4" .And. lTOT ) .Or. ( cEntAmb == "5" .And. lTOU )

		//Percorre os funcionários passados por parâmetro
		For nCont := 1 To Len( aFuncs )

			//Caso for transferência de funcionário
			If lGPEA180

				//Salva as informações da transferência
				aGPEA180 := aFuncs[ nCont, 7 ]

				//Verifica se é transferência de empresa ou filial, caso for não deve buscar as informações pois não tem como o
				//funcionário ter tarefa ou estar relacionado a um ambiente na empresa ou filial destino antes da transferência
				lGetRegs := aGPEA180[ 1, 2 ] == aGPEA180[ 1, 3 ] .And. aGPEA180[ 1, 4 ] == aGPEA180[ 1, 5 ]

			EndIf

			//Caso o sistema deve buscar os registros para validar
			If lGetRegs

				//Caso for vinculo de ambiente por tarefa e não seja cadastro de tarefas (se for deve
				// haver alguma tarefa vinculada e isso será validado no relatório de inconsistências)
				If cEntAmb == "4" .And. !lMDTA090

					//Busca a data de exposição atual do evento S-2240
					dDtAtu := MDTDtExpAtu( aFuncs[ nCont, 1 ] )

					//Busca a data de envio a ser considerada no envio do evento S-2240
					dDataEnv := MDTBscDtEnv( aFuncs[ nCont ], nOper, , dDtAtu )

					//Busca as tarefas que o funcionário realiza
					aTarefas := MDTGetTar( aFuncs[ nCont, 1 ], dDataEnv )

					dbSelectArea( "TOT" )
					dbSetOrder( 2 )
					For nTar := 1 To Len( aTarefas )

						//Caso encontre uma tarefa do funcionário vinculada a um ambiente
						If dbSeek( xFilial( "TOT" ) + aTarefas[ nTar, 1 ] )

							lExsTar := .T.
							Exit

						EndIf

					Next nTar

					//Caso não existirem tarefas vinculadas ao funcionário
					If !lExsTar
						cTxtMemo += STR0024 + ": " + AllTrim( aFuncs[ nCont, 1 ] ) + " - " + AllTrim( Posicione( "SRA", 1, xFilial( "SRA" ) + aFuncs[ nCont, 1 ], "RA_NOME" ) ) + CRLF //Funcionário
					EndIf

					//Define a variável como .F. para validar o próximo funcionário do laço
					lExsTar := .F.

				ElseIf cEntAmb == "5" .And. !lMDTA165 //Caso for vinculo de ambiente por funcionário

					dbSelectArea( "TOU" )
					dbSetOrder( 2 )
					If !dbSeek( xFilial( "TOU" ) + aFuncs[ nCont, 1 ] )
						cTxtMemo += STR0024 + ": " + AllTrim( aFuncs[ nCont, 1 ] ) + " - " + AllTrim( Posicione( "SRA", 1, xFilial( "SRA" ) + aFuncs[ nCont, 1 ], "RA_NOME" ) ) + CRLF //Funcionário
					EndIf

				EndIf

			Else

				cTxtMemo += STR0024 + ": " + AllTrim( aFuncs[ nCont, 1 ] ) + " - " + AllTrim( Posicione( "SRA", 1, xFilial( "SRA" ) + aFuncs[ nCont, 1 ], "RA_NOME" ) ) + CRLF //Funcionário

			EndIf

		Next nCont

		//----------------------------------------------------------
		// Caso existir funcionários sem ambiente, exibe a mensagem
		//----------------------------------------------------------
		If !Empty( cTxtMemo )

			//Define as mensagens de acordo com o valor do parâmetro MV_NG2EAMB
			If cEntAmb == "4" //Caso for vinculo de ambiente por tarefa

				cMsg1 := STR0094 //"Funcionários sem tarefa vinculada a um ambiente"
				cMsg2 := STR0095 //"O parâmetro MV_NG2EAMB está definido como '4- Tarefa' e os funcionários abaixo estão sem nenhuma tarefa vinculada a um ambiente. Para saber sobre como proceder em cada situação de funcionário sem tarefa vinculada a um ambiente clique no botão 'Abrir'."
				cLink := "https://tdn.totvs.com/x/s1ByK"

			ElseIf cEntAmb == "5" //Caso for vinculo de ambiente por funcionário

				cMsg1 := STR0085 //"Funcionários sem ambiente vinculado"
				cMsg2 := STR0086 //"O parâmetro MV_NG2EAMB está definido como '5- Funcionário' e os funcionários abaixo estão sem ambiente vinculado. Para saber sobre como proceder em cada situação de funcionário sem ambiente clique no botão 'Abrir'."
				cLink := "https://tdn.totvs.com/x/8rXFJg"

			EndIf

			//Caso não for execução automática mostra a mensagem
			If !lExecAuto
				MDTMEMOLINK( cMsg1, cMsg2, cLink, cTxtMemo )
			Else
				//Adiciona as informações na variável de retorno
				cMsgInc += cMsg2 + CRLF
				cMsgInc += cLink + CRLF
				cMsgInc += cTxtMemo + CRLF
			EndIf

		EndIf

	EndIf

	//Retorna a área
	RestArea( aArea )

Return

//-------------------------------------------------------------------
/*/{Protheus.doc} fVldAdmFut
Verifica se os funcionários passados por parâmetro são admissões
futuras.

@author	Gabriel Sokacheski
@since	12/11/2021

@param cMsgInc, Caracter, Grava as inconsistências (caso houver)
@param aFuncs, Array, Contém as informações dos funcionários para validação

/*/
//-------------------------------------------------------------------
Static Function fVldAdmFut( cMsgInc, aFuncs )

	Local aArea	   := GetArea() //Salva a área
	Local dDtEnv   := dDataBase
	Local cTxtMemo := ""
	Local nCont	   := 0

	//--------------------------------------------------------------------------------
	// Percorre os funcionários para validar se é admissão futura com mais de 30 dias
	//--------------------------------------------------------------------------------
	For nCont := 1 To Len( aFuncs )

		dDtEnv := Posicione( "SRA", 1, xFilial( "SRA" ) + aFuncs[ nCont, 1 ], "RA_ADMISSA" )

		If dDtEnv > ( dDataBase + 30 )
			cTxtMemo += STR0024 + ": " + AllTrim( aFuncs[ nCont, 1 ] ) + " - " + AllTrim( Posicione( "SRA", 1, xFilial( "SRA" ) + aFuncs[ nCont, 1 ], "RA_NOME" ) ) + CRLF //Funcionário
		EndIf

	Next nCont

	//-----------------------------------------------------------------
	// Caso existir funcionários por admissão futura, exibe a mensagem
	//-----------------------------------------------------------------
	If !Empty( cTxtMemo )
		
		//Caso não for execução automática mostra a mensagem
		If !lExecAuto
			//"Funcionários por admissão futura"##"Os funcionários possuem admissão futura com data superior à 30 dias da data atual."
			MDTMEMOLINK( STR0083, STR0084 + Space( 1 ) + STR0082, "https://tdn.totvs.com/x/11q_Jg", cTxtMemo )
		Else
			//Adiciona as informações na variável de retorno
			cMsgInc += STR0084 + Space( 1 ) + STR0082 + CRLF
			cMsgInc += "https://tdn.totvs.com/x/11q_Jg" + CRLF
			cMsgInc += cTxtMemo + CRLF
		EndIf

	EndIf

	//Retorna a área
	RestArea( aArea )

Return

//-------------------------------------------------------------------
/*/{Protheus.doc} fVldEPIFun
Verifica se existem EPI's entregues ao funcionário quando o risco está
definido como necessita EPI (TN0_NECEPI)

@return	Nil, Nulo

@param	cMsgInc, Caracter, Variável que grava as inconsistências (caso houver)
@param	aFuncs, Array, Array contendo as informações dos funcionários para validação
@param	nOper, Numérico, Indica a operação que está sendo realizada (3-Inclusão/4-Alteração/5-Exclusão)

@sample	fVldEPIFun( "", { { "000230" } }, 4 )

@author	Luis Fellipy Bett
@since	29/11/2021
/*/
//-------------------------------------------------------------------
Static Function fVldEPIFun( cMsgInc, aFuncs, nOper )

	//Variáveis de controle de troca de empresa, quando transferência de empresa
	Local aAreaBkp := GetArea()
	Local cEmpBkp  := cEmpAnt
	Local cFilBkp  := cFilAnt
	Local cArqBkp  := cArqTab

	//Variáveis de controle de tabelas na troca de empresa, quando transferência de empresa
	Local aAreaTN6 := TN6->( GetArea() )
	Local aAreaTN0 := TN0->( GetArea() )
	Local aAreaTMA := TMA->( GetArea() )
	Local aAreaTO0 := TO0->( GetArea() )
	Local aAreaTO1 := TO1->( GetArea() )
	
	//Variável das tabelas a serem abertas
	Local aTbls := { "TN6", "TN0", "TMA", "TO0", "TO1" }
	
	//Variáveis para busca das informações
	Local dDtAtu   := SToD( "" )
	Local dDataEnv := SToD( "" )
	Local lGetEPI  := .T.
	Local aRisExp  := {}
	Local aEPITNX  := {}
	Local aEPINec  := {}
	Local aEPIEnt  := {}
	Local aRisEnt  := {}
	Local aGPEA180 := {}
	Local cTxtMemo := ""
	Local cTxtAux  := ""
	Local cRiscos  := "%"
	Local cVirgula := ", "
	Local nFun	   := 0
	Local nCont	   := 0

	//Variáveis dos alias
	Local cAliasTNX := ""
	Local cAliasTNF := ""

	//Variável private utilizada na função MDTVldRis para busca
	Private lVldEPI := .F.

	//Variáveis private para utilização na transferência
	Private cCCustoAnt := ""
	Private cDeptoAnt  := ""
	Private cFuncaoAnt := ""
	Private cCargoAnt  := ""

	//Define a régua de processamento
	ProcRegua( Len( aFuncs ) )

	//----------------------------------------------------------------------------------------------------------------
	// Percorre os funcionários para validar se estão expostos a risco que necessitam de EPI e estão sem EPI entregue
	//----------------------------------------------------------------------------------------------------------------
	For nFun := 1 To Len( aFuncs )

		//Incrementa a régua de proecessamento
		IncProc()

		//Seta a variável para .F. para buscar todos os riscos a que o funcionário está exposto no escopo da função MDTBscDtEnv
		lVldEPI := .F.

		//Busca a data de exposição atual do evento S-2240
		dDtAtu := MDTDtExpAtu( aFuncs[ nFun, 1 ] )

		//Busca a data de envio a ser considerada no envio do evento S-2240
		dDataEnv := MDTBscDtEnv( aFuncs[ nFun ], nOper, , dDtAtu )

		//Seta a variável para .T. para buscar apenas os riscos que necessitam de utilização de EPI
		lVldEPI := .T.

		dbSelectArea( "SRA" )
		dbSetOrder( 1 )
		dbSeek( xFilial( "SRA" ) + aFuncs[ nFun, 1 ] )

		//Caso for transferência de funcionário
		If lGPEA180

			//Busca as informações da transferência
			aGPEA180 := aFuncs[ nFun, 7 ]

			//Verifica se é transferência de empresa ou filial, caso for não deve buscar os EPI's pois não tem como o funcionário 
			//ter EPI entregue na empresa ou filial destino antes da transferência
			lGetEPI := aGPEA180[ 1, 2 ] == aGPEA180[ 1, 3 ] .And. aGPEA180[ 1, 4 ] == aGPEA180[ 1, 5 ]

			//Salva as informações da filial de origem
			cCCustoAnt := SRA->RA_CC
			cDeptoAnt  := SRA->RA_DEPTO
			cFuncaoAnt := SRA->RA_CODFUNC
			cCargoAnt  := SRA->RA_CARGO

			MDTChgSRA( .T., aGPEA180 )

			//Caso a empresa destino seja diferente da empresa atual
			If cEmpAnt <> aGPEA180[ 1, 3 ]

				//Caso Middleware, posiciona a SM0 na empresa destino
				If lMiddleware

					MDTPosSM0( aGPEA180[ 1, 3 ], aGPEA180[ 1, 5 ] )

				EndIf

				//Abre as tabelas na empresa destino
				MDTChgEmp( aTbls, cEmpAnt, aGPEA180[ 1, 3 ] )

				//Posiciona na empresa destino
				cEmpAnt := aGPEA180[ 1, 3 ]

			EndIf

			//Posiciona na filial destino
			cFilAnt := aGPEA180[ 1, 5 ]

		EndIf

		//Busca riscos expostos
		aRisExp := MDTRis2240( dDataEnv )

		//Caso for chamada pelo GPEA180, altera a empresa e filial para a atual após ter buscado as informações
		If lGPEA180

			//Caso a empresa destino seja diferente da empresa atual
			If cEmpAnt <> cEmpBkp

				//Caso Middleware, posiciona a SM0 na filial logada novamente
				If lMiddleware

					MDTPosSM0( cEmpBkp, cFilBkp )

				EndIf

				//Abre as tabelas na empresa logada novamente
				MDTChgEmp( aTbls, aGPEA180[ 1, 3 ], cEmpBkp )
				
				//Posiciona na empresa logada novamente
				cEmpAnt := cEmpBkp

			EndIf

			//Posiciona na filial logada novamente
			cFilAnt := cFilBkp

		EndIf

		//Caso for chamada pelo GPEA180, volta o valor dos campos
		If lGPEA180
			MDTChgSRA( .F., aGPEA180 )
		EndIf

		//Caso for cadastro de Risco, adiciona as informações da memória
		If lMDTA180 .And. aScan( aRisExp, { |x| x[1] == M->TN0_NUMRIS } ) == 0 .And. MdtVldRis( dDataEnv, .T. )
			aAdd( aRisExp, { M->TN0_NUMRIS } )
		EndIf

		//Caso deva buscar as informações dos EPI's
		If lGetEPI

			//--------------------------------------------------------------------------
			// Busca os EPI's necessários para os riscos a que o funcionário tá exposto
			//--------------------------------------------------------------------------
			//Adiciona os riscos na variável para busca na query
			For nCont := 1 To Len( aRisExp )

				If nCont == Len( aRisExp )
					cVirgula := ""
				EndIf

				cRiscos += "'" + aRisExp[ nCont, 1 ] + "'" + cVirgula

			Next nCont

			//Finaliza a variável com o '%' para executar corretamente na query
			cRiscos += "%"

			//Caso existam riscos a serem validados
			If cRiscos != "%%"

				cAliasTNX := GetNextAlias() //Pega o próximo alias

				BeginSQL Alias cAliasTNX
					SELECT TNX.TNX_NUMRIS, TNX.TNX_EPI
						FROM %Table:TNX% TNX
						WHERE TNX.TNX_FILIAL = %xFilial:TNX% AND
								TNX.TNX_NUMRIS IN ( %Exp:cRiscos% ) AND
								TNX.%NotDel%
				EndSQL

				//Posiciona na tabela para adicionar os registros no array
				dbSelectArea( cAliasTNX )
				( cAliasTNX )->( dbGoTop() )
				While ( cAliasTNX )->( !Eof() )

					//Adiciona as informações no array
					aAdd( aEPITNX, { ( cAliasTNX )->TNX_NUMRIS, ( cAliasTNX )->TNX_EPI } )
				
					( cAliasTNX )->( dbSkip() )

				End

				//Exclui a tabela
				( cAliasTNX )->( dbCloseArea() )

			EndIf

			//--------------------------------------------------
			// Trata os EPI's verificando se são pais ou filhos
			//--------------------------------------------------
			dbSelectArea( "TL0" )
			dbSetOrder( 1 )
			For nCont := 1 To Len( aEPITNX )

				//Caso o EPI seja um EPI pai busca os filhos
				If dbSeek( xFilial( "TL0" ) + aEPITNX[ nCont, 2 ] )

					While TL0->( !Eof() ) .And. TL0->TL0_FILIAL == xFilial( "TL0" ) .And. TL0->TL0_EPIGEN == aEPITNX[ nCont, 2 ]

						aAdd( aEPINec, { aEPITNX[ nCont, 1 ], TL0->TL0_EPIFIL } )

						TL0->( dbSkip() )

					End

				Else //Senão adiciona o próprio EPI filho

					aAdd( aEPINec, { aEPITNX[ nCont, 1 ], aEPITNX[ nCont, 2 ] } )

				EndIf

			Next nCont

			//--------------------------------------------
			// Busca os EPI's já entregues ao funcionário
			//--------------------------------------------
			cAliasTNF := GetNextAlias() //Pega o próximo alias
			
			BeginSQL Alias cAliasTNF
				SELECT TNF.TNF_CODEPI
					FROM %Table:TNF% TNF
					WHERE TNF.TNF_FILIAL = %xFilial:TNF% AND
							TNF.TNF_MAT = %Exp:aFuncs[ nFun, 1 ]% AND
							TNF.%NotDel%
			EndSQL

			//Posiciona na tabela para adicionar os registros no array
			dbSelectArea( cAliasTNF )
			( cAliasTNF )->( dbGoTop() )
			While ( cAliasTNF )->( !Eof() )

				If aScan( aEPIEnt, { |x| x[ 1 ] == ( cAliasTNF )->TNF_CODEPI } ) == 0

					aAdd( aEPIEnt, { ( cAliasTNF )->TNF_CODEPI } )

				EndIf

				( cAliasTNF )->( dbSkip() )

			End

			//Exclui a tabela
			( cAliasTNF )->( dbCloseArea() )

			//-----------------------------------------------------------------------------------------------------
			// Verifica se algum dos EPI's necessários ao riscos a que o funcionário está exposto já está entregue
			//-----------------------------------------------------------------------------------------------------
			//Caso existam EPI's entregues para o funcionário, verifica se já existe EPI entregue pra cada um dos riscos a que ele está exposto
			If Len( aEPIEnt ) > 0
			
				For nCont := 1 To Len( aEPINec )

					If aScan( aEPIEnt, { |x| x[ 1 ] == aEPINec[ nCont, 2 ] } ) > 0

						//Salvo o risco que já tem EPI entregue
						If aScan( aRisEnt, { |x| x[ 1 ] == aEPINec[ nCont, 1 ] } ) == 0
						
							aAdd( aRisEnt, { aEPINec[ nCont, 1 ] } )

						EndIf

					EndIf

				Next nCont

			EndIf

		EndIf

		//Percorre os riscos verificando se algum está sem EPI entregue, se tiver imprime na mensagem
		For nCont := 1 To Len( aRisExp )

			If aScan( aRisEnt, { |x| x[ 1 ] == aRisExp[ nCont, 1 ] } ) == 0

				cTxtAux += STR0024 + ; //Funcionário
						": " + ;
						AllTrim( aFuncs[ nFun, 1 ] ) + ;
						" - " + ;
						AllTrim( Posicione( "SRA", 1, xFilial( "SRA" ) + aFuncs[ nFun, 1 ], "RA_NOME" ) ) + ;
						" / " + ;
						STR0087 + ; //Risco
						": " + ;
						AllTrim( aRisExp[ nCont, 1 ] ) + ;
						CRLF

			EndIf

		Next nCont

		//Passa a string do funcionário para a string a ser impressa
		cTxtMemo += cTxtAux

		//Zera as variáveis para validar o próximo funcionário do array
		cRiscos	 := "%"
		cVirgula := ", "
		cTxtAux	 := ""
		aEPITNX	 := {}
		aEPINec	 := {}
		aEPIEnt	 := {}
		aRisEnt	 := {}

	Next nFun

	//-----------------------------------------------------------------------------------------------------------
	// Caso existir riscos que necessitam de EPI e esse EPI não esteja entregue ao funcionário, exibe a mensagem
	//-----------------------------------------------------------------------------------------------------------
	If !Empty( cTxtMemo )
		
		//Caso não for execução automática mostra a mensagem
		If !lExecAuto
			//"Funcionários sem EPI entregue para os riscos"##"Os funcionários abaixo não possuem pelo menos um EPI entregue para os riscos informados e os riscos estão definidos com necessidade de EPI (TN0_NECEPI = Sim). Para saber sobre como proceder em cada situação de funcionário sem EPI entregue para os riscos com necessidade de EPI clique no botão 'Abrir'."
			MDTMEMOLINK( STR0088, STR0089, "https://tdn.totvs.com/x/stXaJw", cTxtMemo )
		Else
			//Adiciona as informações na variável de retorno
			cMsgInc += STR0089 + CRLF //"Os funcionários abaixo não possuem pelo menos um EPI entregue para os riscos informados e os riscos estão definidos com necessidade de EPI (TN0_NECEPI = Sim). Para saber sobre como proceder em cada situação de funcionário sem EPI entregue para os riscos com necessidade de EPI clique no botão 'Abrir'."
			cMsgInc += "https://tdn.totvs.com/x/stXaJw" + CRLF
			cMsgInc += cTxtMemo + CRLF
		EndIf

	EndIf

	//Reposiciona as tabelas na filial logada
	RestArea( aAreaTN6 )
	RestArea( aAreaTN0 )
	RestArea( aAreaTMA )
	RestArea( aAreaTO0 )
	RestArea( aAreaTO1 )

	//Retorna as informações da empresa e filial logada
	cEmpAnt := cEmpBkp
	cFilAnt := cFilBkp
	cArqTab := cArqBkp
	
	//Retorna a área posicionada
	RestArea( aAreaBkp )

Return

//-------------------------------------------------------------------
/*/{Protheus.doc} fVldEPIRis
Verifica se os EPI's entregues ao funcionário estão vinculados ao risco
que o funcionário está exposto

@return	lRet, Lógico, controla o envio ou não do evento

@param	cMsgInc, Caracter, Variável que grava as inconsistências (caso houver)
@param	aFuncs, Array, Array contendo as informações dos funcionários para validação
@param	lValida, Lógico, Informa se deve realizar a validação das informações

@sample	fVldEPIRis( "", { { "000230" } } )

@author	Luis Fellipy Bett
@since	20/07/2021
/*/
//-------------------------------------------------------------------
Static Function fVldEPIRis( cMsgInc, aFuncs, lValida )

	Local aArea	   	 := GetArea()
	Local aEpiRis    := {} // EPI's necessários do risco
	Local aEpiEntFil := {} // EPI's entregues com código do EPI filho
	Local aEpiEntPai := {} // EPI's entregues com código do EPI genérico
	Local aRiscos    := {} // Riscos que o funcionário está exposto
	Local aEpiEnv    := {} // EPI's do funcionário já comunicados

	Local cTxtMemo := ""

	Local dDtAux := SToD( "" )

	Local lRet := .F.

	Local nEpi := 0 // EPI
	Local nFun := 0 // Funcionário
	Local nRis := 0 // Risco

	//------------------------------------------------------
	// Percorre todos os funcionários para validar os EPI's
	//------------------------------------------------------

	For nFun := 1 To Len( aFuncs )

		dbSelectArea( "SRA" )
		dbSetOrder( 1 )

		If dbSeek( xFilial( "SRA" ) + aFuncs[ nFun, 1 ] ) // Posiciona no funcionário em questão

			lRet := .F.

			aEpiEntFil := aFuncs[ nFun, 8 ] // EPI's entregues filho
			aEpiEntPai := aClone( aEpiEntFil ) // EPI's entregues pai

			//-------------------------------------------------------------------------
			// Se algum EPI for EPI genérico, troca o seu código no array pelo EPI pai
			//-------------------------------------------------------------------------

			dbSelectArea( "TL0" )
			dbSetOrder( 2 )

			For nEpi := 1 To Len( aEpiEntPai )

				If dbSeek( xFilial( "TL0" ) + aEpiEntPai[ nEpi, 1 ] )

					aEpiEntPai[ nEpi, 1 ] := TL0->TL0_EPIGEN

				EndIf

			Next nEpi

			//---------------------------------------
			// Busca a última data de entrega do EPI
			//---------------------------------------

			For nEpi := 1 To Len( aEpiEntFil )

				If dDtAux < aEpiEntFil[ nEpi, 2 ]

					dDtAux := aEpiEntFil[ nEpi, 2 ]

				EndIf

			Next nEpi

			aEpiEnv := fEpiEnv( aFuncs[ nFun, 1 ] ) // EPI's comunicados
			aRiscos := MDTRis2240( dDtAux ) // Busca os riscos a que o funcionário está exposto

			//---------------------------------------------------
			// Verifica se o funcionário está exposto a um risco
			//---------------------------------------------------

			If Len( aRiscos ) > 0 // Caso o funcionário esteja exposto a algum risco

				dbSelectArea( "TNX" )
				dbSetOrder( 2 )

				//-------------------------------------------------
				// Monta o array com os EPI's necessários do risco
				//-------------------------------------------------

				For nRis := 1 To Len( aRiscos )

					If dbSeek( xFilial( "TNX" ) + aRiscos[ nRis, 1 ] )

						While TNX->( !Eof() ) .And. TNX->TNX_FILIAL == xFilial( "TNX" ) .And. TNX->TNX_NUMRIS == aRiscos[ nRis, 1 ]

							If aScan( aEpiRis, { |x| x[1] == TNX->TNX_EPI } ) == 0

								aAdd( aEpiRis, { TNX->TNX_EPI } )

							EndIf

							TNX->( dbSkip() )

						End

					EndIf

				Next nRis

				For nEpi := 1 To Len( aEpiEntPai )

					//-----------------------------------------
					// Avisa quais EPI's não serão comunicados
					//-----------------------------------------

					If aScan( aEpiRis, { |x| x[1] == aEpiEntPai[ nEpi, 1 ] } ) == 0

						cTxtMemo += STR0078 +; // EPI
							": " +;
							AllTrim( aEpiEntFil[ nEpi, 1 ] ) +;
							" - " +;
							AllTrim( Posicione( "SB1", 1, xFilial( "SB1" ) + aEpiEntFil[ nEpi, 1 ], "B1_DESC" ) ) +;
							" / " +;
							STR0024 +; // Funcionário
							": " +;
							AllTrim( aFuncs[ nFun, 1 ] );
							+;
							" - ";
							+;
							AllTrim( Posicione( "SRA", 1, xFilial( "SRA" ) + aFuncs[ nFun, 1 ], "RA_NOME" ) ) +;
							CRLF

					ElseIf !lRet

						//--------------------------------------------------------------------------------------
						// Verifica se há pelo menos um EPI entregue que não foi comunicado para gerar o evento
						//--------------------------------------------------------------------------------------

						If ( Len( aEpiEnv ) == 0 .Or. aScan( aEpiEnv, { | x | x == AllTrim( aEpiEntPai[ nEpi, 7 ] ) } ) == 0 )

							lRet := .T.

						EndIf

					EndIf

				Next nEpi

			Else // Caso o funcionário não esteja exposto a nenhum risco

				lRet := .F.
				Exit

			EndIf

		EndIf

	Next nFun

	//-------------------------------------------
	// Caso existam EPI's que não serão enviados
	//-------------------------------------------

	If !Empty( cTxtMemo ) .And. lValida
		
		// Caso não for execução automática mostra a mensagem
		If !lExecAuto

			MDTMEMOLINK( STR0081, STR0077, "https://tdn.totvs.com/x/PkCbJg", cTxtMemo ) // "EPI's não enviados"##"Os EPI's abaixo não foram comunicados ao SIGATAF/Middleware. Para saber mais sobre os motivos pelo qual um EPI não é enviado clique no botão 'Abrir'."

		Else

			// Adiciona as informações na variável de retorno
			cMsgInc += STR0077 + CRLF
			cMsgInc += "https://tdn.totvs.com/x/PkCbJg" + CRLF
			cMsgInc += cTxtMemo + CRLF

		EndIf

	EndIf

	RestArea( aArea )

Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} fPosFil
Função genérica para posicionamento de filial em algumas chamadas específicas

@return	Nil, Nulo

@param	cEvento, Caracter, Nome do evento que está sendo processado
@param	cFilFun, Caracter, Filial do funcionário

@sample	fPosFil( "S-2220", "D MG 02 " )

@author	Luis Fellipy Bett
@since	13/09/2021
/*/
//-------------------------------------------------------------------
Static Function fPosFil( cEvento, cFilFun )

	Local lMDTA410 := IsInCallStack( "MDTA410" ) //Caso for chamado pelo prontuário médico
	Local lMDTA200 := IsInCallStack( "MDTA200" ) //Caso for chamado pelo atestado ASO

	Default cFilFun := ""

	If cEvento == "S-2220" .And. ( lMDTA410 .Or. lMDTA200 ) //Caso for chamado pelo prontuário médico ou atestado ASO e seja envio do S-2220, posiciona na filial da ficha médica
		cFilAnt := TM0->TM0_FILFUN
	ElseIf !Empty( cFilFun ) .And. ( ( lMDTA881 .Or. lMDTA882 ) .Or. ( cEvento == "S-2240" .And. lMDTA180 ) ) //Caso for carga inicial ou schedule de tarefas ou for cadastro de risco
		cFilAnt := cFilFun //Posiciona na filial do funcionário para validação
	EndIf

Return

//-------------------------------------------------------------------
/*/{Protheus.doc} fVincCAT
Verifica se a CAT está vinculada a um atestado ou diagnóstico

@return	lVinc, Boolean, .T. caso o acidente esteja vinculado a um atestado ou diagnóstico

@param	oModelTNC, Objeto, Objeto do cadastro de acidentes

@sample	fVincCAT( oModelTNC )

@author	Luis Fellipy Bett
@since	16/09/2021
/*/
//-------------------------------------------------------------------
Static Function fVincCAT( oModelTNC )

	//Salva a área
	Local aArea := GetArea()
	
	//Variáveis para busca das informações
	Local cAcidente	:= oModelTNC:GetValue( "TNCMASTER", "TNC_ACIDEN" )
	Local cNumFic	:= oModelTNC:GetValue( "TNCMASTER", "TNC_NUMFIC" )
	Local cDtAcid	:= oModelTNC:GetValue( "TNCMASTER", "TNC_DTACID" )
	Local cHrAcid	:= oModelTNC:GetValue( "TNCMASTER", "TNC_HRACID" )
	Local cTipoCAT	:= oModelTNC:GetValue( "TNCMASTER", "TNC_TIPCAT" )
	Local lVinc := .F.

	//Caso for uma CAT de reabertura ou óbito, busca o acidente inicial
	If cTipoCAT $ "2/3"

		//Busca a CAT inicial
		cAcidente := MDTCatIni( cNumFic, cDtAcid, cHrAcid )

	EndIf

	//--------------------------------------------------------
	// Verifica se o acidente está vinculado a um diagnóstico
	//--------------------------------------------------------
	If cAtendAci == "1" .Or. cAtendAci == "3"
		dbSelectArea( "TMT" )
		dbSetOrder( 7 )
		If dbSeek( xFilial( "TMT" ) + cAcidente )
			lVinc := .T.
		EndIf
	EndIf

	//-----------------------------------------------------
	// Verifica se o acidente está vinculado a um atestado
	//-----------------------------------------------------
	If !lVinc .And. ( cAtendAci == "2" .Or. cAtendAci == "3" )
		dbSelectArea( "TNY" )
		dbSetOrder( 5 )
		If dbSeek( xFilial( "TNY" ) + cAcidente )
			lVinc := .T.
		EndIf
	EndIf
	
	//Retorna a área
	RestArea( aArea )

Return lVinc

//-------------------------------------------------------------------
/*/{Protheus.doc} fGetMatFic
Busca a matrícula das fichas médicas passadas por parâmetro

@return	aFuncs, Array, Array contendo as matrículas dos funcionários

@param	aFichas, Array, Array contendo as fichas médicas

@sample	fGetMatFic( { { "000023" } } )

@author	Luis Fellipy Bett
@since	11/10/2021
/*/
//-------------------------------------------------------------------
Static Function fGetMatFic( aFichas )

	Local aArea	 := GetArea() //Salva a área
	Local cMat	 := ""
	Local aFuncs := {}
	Local nCont	 := 0

	For nCont := 1 To Len( aFichas )
		
		//Busca a matrícula relacionada à ficha médica
		cMat := Posicione( "TM0", 1, xFilial( "TM0" ) + aFichas[ nCont, 1 ], "TM0_MAT" )

		//Caso exista matrícula relacionada à ficha, ou seja, não seja ficha médica de um candidato
		If !Empty( cMat )
			aAdd( aFuncs, { cMat, , , , , , , , aFichas[ nCont, 2 ] } ) //Adiciona a chave do ASO na 9ª posição pois as outras já estão sendo utilizadas
		EndIf

	Next nCont

	RestArea( aArea ) //Retorna a área

Return aFuncs

//-------------------------------------------------------------------
/*/{Protheus.doc} MDTRis2240
Busca os riscos a que o funcionário está exposto

@return	aRiscos, Array, Array contendo os riscos a que o funcionário está exposto

@param	dDtRis, Data, Data a ser considerada na busca dos riscos

@sample	MDTRis2240( 13/10/2021 )

@author	Luis Fellipy Bett
@since	02/11/2021
/*/
//-------------------------------------------------------------------
Function MDTRis2240( dDtRis )

	Local aRiscos := {}
	Local cValRisco := '{ |dData| MdtVldRis( dData ) }'

	// Define por padrão a data a ser considerado como sendo a database
	Default dDtRis := dDataBase

	// Busca os riscos a que o funcionário está exposto quando não está sendo demitido
	If !FWIsInCallStack( 'Gpem040' ) // Rescisão
		aRiscos := MDTRetRis( dDtRis, , , , , , , .F., , , , cValRisco )[ 1 ]
	EndIf

Return aRiscos

//-------------------------------------------------------------------
/*/{Protheus.doc} fVldEnvFun
Valida se o cadastro do funcionário vai gerar a retificação do S-2240

@return	lRetif, Boolean, .T. caso haja retificação, senão .F.

@sample	fVldEnvFun()

@author	Luis Fellipy Bett
@since	30/11/2021
/*/
//-------------------------------------------------------------------
Static Function fVldEnvFun()

	//Variáveis para busca das informações
	Local cFuncAnt	:= ""
	Local cFuncAtu	:= GetMemVar( "RA_CODFUNC" )
	Local dDtDemiss	:= SRA->RA_DEMISSA
	Local lRetif	:= .F.

	//Caso as variáveis existirem
	If Type( "aSraHeader" ) == "A" .And. Type( "aSvSraCols" ) == "A"

		//Pega a função anterior
		cFuncAnt := GdFieldGet( "RA_CODFUNC", 1, .F., aSraHeader, aSvSraCols )

	EndIf

	//Caso o funcionário tenha sido demitido, alterado de função ou registro do S-2240 não exista no SIGATAF/Middleware, gera o evento S-2240
	If !Empty( dDtDemiss ) .Or. ( !Empty( cFuncAnt ) .And. cFuncAnt <> cFuncAtu ) .Or. !MDTVld2240( SRA->RA_MAT )
		lRetif := .T.
	EndIf

Return lRetif

//-------------------------------------------------------------------
/*/{Protheus.doc} MDTPosSM0
Força o posicionamento na SM0

@return	Nil, Nulo

@param	cEmpAux, Caracter, Empresa a ser considerada no posicionamento da SM0
@param	cFilAux, Caracter, Filial a ser considerada no posicionamento da SM0

@sample	MDTPosSM0()

@author	Luis Fellipy Bett
@since	01/12/2021
/*/
//-------------------------------------------------------------------
Function MDTPosSM0( cEmpAux, cFilAux )

	//Posiciona na SM0
	SM0->( dbSetOrder( 1 ) )
	SM0->( dbSeek( cEmpAux + cFilAux ) )

Return

//-------------------------------------------------------------------
/*/{Protheus.doc} fEpiEnv
Retorna os EPI's do funcionário que já foram comunicados.

@author Gabriel Sokacheski
@since 20/12/2021

@param cMatricula, Caracter, matrícula do funcionário.

@return	aEpi, Array, códigos dos EPI's já comunicados.
/*/
//-------------------------------------------------------------------
Static Function fEpiEnv( cMatricula )

	Local aEpi := {}
	Local aAreaV3D := ( 'V3D' )->( GetArea() )

	Local cAliasV3D

	If !lMiddleware

		cAliasV3D := GetNextAlias()

		// Busca as entregas de EPIs no TAF para o funcionário
		BeginSQL Alias cAliasV3D
			SELECT 
				V3D.V3D_FILIAL, V3D.V3D_ID
			FROM 
				%table:CM9% CM9 
				INNER JOIN %table:CMA% CMA ON 
					CMA.CMA_FILIAL = %xFilial:CMA%
					AND CMA.CMA_ID = CM9.CM9_ID
					AND CMA.CMA_VERSAO = CM9.CM9_VERSAO
					AND CMA.%notDel%
				INNER JOIN %table:CMB% CMB ON 
					CMB.CMB_FILIAL = %xFilial:CMB%
					AND CMB.CMB_ID = CMA.CMA_ID
					AND CMB.CMB_VERSAO = CMA.CMA_VERSAO
					AND CMB.CMB_CODAGE = CMA.CMA_CODAG
					AND CMB.%notDel%
				INNER JOIN %table:V3D% V3D ON 
					V3D.V3D_FILIAL = %xFilial:V3D%
					AND V3D.V3D_ID = CMB.CMB_DVAL
					AND V3D.%notDel%
			WHERE 
				CM9.CM9_FILIAL = %xFilial:CM9%
				AND CM9.CM9_FUNC = %exp:MDTGetIdFun( cMatricula )%
				AND CM9.%notDel%
		EndSQL

		DbSelectArea( cAliasV3D )
		( cAliasV3D )->( dbGoTop() )

		While ( cAliasV3D )->( !EoF() ) // Monta array com os EPIs enviados

			aAdd( aEpi, AllTrim( Posicione( 'V3D', 1, ( cAliasV3D )->V3D_FILIAL + ( cAliasV3D )->V3D_ID, 'V3D_DSCEPI' ) ) )

			( cAliasV3D )->( DbSkip() )

		End

		( cAliasV3D )->( DbCloseArea() )

	EndIf

	RestArea( aAreaV3D )

Return aEpi

//-------------------------------------------------------------------
/*/{Protheus.doc} fVldFunDem
Valida se o ASO é demissional quando o funcionário estiver demitido

@return	Nil, Nulo

@param	aFuncs, Array, Array contendo os funcionários a serem validados
@param	lImpASO, Boolean, Indica se é impressão do ASO

@sample	fVldFunDem( { { "0000236" } }, .F. )

@author	Luis Fellipy Bett
@since	04/01/2022
/*/
//-------------------------------------------------------------------
Static Function fVldFunDem( aFuncs, lImpASO )
	
	Local aArea	   := GetArea() //Salva a área
	Local aAreaTMY := TMY->( GetArea() ) //Salva a área da TMY
	Local dDtDemis := SToD( "" )
	Local dDtASO   := SToD( "" )
	Local cSitFolh := ""
	Local cChvASO  := ""
	Local cNatASO  := ""
	Local aFunNao  := {}
	Local nCont	   := 0
	Local nPosReg  := 0

	//------------------------------------
	// Percorre os funcionários validando
	//------------------------------------
	For nCont := 1 To Len( aFuncs )

		//Busca as informações do funcionário
		dDtDemis := Posicione( "SRA", 1, xFilial( "SRA" ) + aFuncs[ nCont, 1 ], "RA_DEMISSA" )
		cSitFolh := Posicione( "SRA", 1, xFilial( "SRA" ) + aFuncs[ nCont, 1 ], "RA_SITFOLH" )

		//Busca a chave do ASO
		cChvASO := IIf( Len( aFuncs[ nCont ] ) > 8 .And. aFuncs[ nCont, 9 ] <> Nil, aFuncs[ nCont, 9 ], TMY->TMY_FILIAL + TMY->TMY_NUMASO )

		//Caso o funcionário estiver demitido
		If !Empty( dDtDemis ) .And. cSitFolh == "D"

			//Busca as informações do ASO
			dDtASO := IIf( lImpASO, dDataBase, M->TMY_DTEMIS )
			cNatASO := IIf( lImpASO, Posicione( "TMY", 1, cChvASO, "TMY_NATEXA" ), M->TMY_NATEXA )

			// "O atestado possui data posterior ou igual a data de demissão e não é do tipo demissional, deseja tentar gerar o evento S-2220 mesmo assim?"
			If dDtASO >= dDtDemis .And. cNatASO != '5' .And. !MsgYesNo( STR0102, STR0017 )
				aAdd( aFunNao, { aFuncs[ nCont, 1 ] } ) //Adiciona no array para depois excluir
			EndIf

		EndIf

	Next nCont

	//----------------------------------------------------------------------
	// Caso exista funcionários que não devem ser enviados, deleta do array
	//----------------------------------------------------------------------
	If Len( aFunNao ) > 0
		For nCont := 1 To Len( aFunNao )
			If ( nPosReg := aScan( aFuncs, { |x| x[ 1 ] == aFunNao[ nCont, 1 ] } ) ) > 0
				aDel( aFuncs, nPosReg ) //Deleta registro do array
				aSize( aFuncs, Len( aFuncs ) - 1 ) //Diminui a posição excluída do array
			EndIf
		Next nCont
	EndIf

	//Retorna a área
	RestArea( aAreaTMY )
	RestArea( aArea )

Return

//-------------------------------------------------------------------
/*/{Protheus.doc} fAjsCodUni
Atualiza se necessário o código único do funcionário na transferência
entre empresas diferentes

@obs	Em casos onde é gerado o evento S-2299 e o novo S-2200 pelo SIGAGPE
e acontece algum erro na integração com o medicina, ao tentar refazer a transferência
o sistema trás como sendo o código único o código da filial origem, devido a variável
cCodUnic vir vazia por não passar pelo trecho do GPE. Nesse cenário é necessário buscar
o código único já cadastrado na filial destino e considerar ele como o código a ser enviado
no S-2240, esse é o papel dessa função

@return	Nil, Nulo

@param	aFuncs, Array, Array contendo os funcionários a serem validados

@sample	fAjsCodUni( { { "0000236" } } )

@author	Luis Fellipy Bett
@since	11/02/2022
/*/
//-------------------------------------------------------------------
Static Function fAjsCodUni( aFuncs )

	//Salva a área
	Local aArea := GetArea()

	//Variáveis de busca de informações
	Local aTbls := { { "C9V", 01 } }
	Local cEmpBkp := cEmpAnt //Salva a empresa
	Local cFilBkp := cFilAnt //Salva a filial
	Local aInfTra := {}
	Local cCPF	  := ""

	//Variável contadora
	Local nCont := 1

	//Percorre todos funcionários a serem transferidos verificando o código único vindo do GPE
	For nCont := 1 To Len( aFuncs )

		//Pega as informações da transferência
		aInfTra := aFuncs[ nCont, 7 ]

		//Caso a empresa origem seja diferente da empresa destino
		If aInfTra[ 1, 2 ] <> aInfTra[ 1, 3 ]

			//Caso a empresa do código único do funcionário for diferente da empresa pra que ele ta sendo transferido
			If SubStr( aInfTra[ 1, 14 ], 1, 2 ) <> aInfTra[ 1, 3 ]

				//Caso o envio for via SIGATAF
				If !lMiddleware
				
					//Busca o CPF do funcionário
					cCPF := Posicione( "SRA", 1, xFilial( "SRA" ) + aFuncs[ nCont, 1 ], "RA_CIC" )

					//Posiciona na empresa destino
					NGPrepTBL( aTbls, aInfTra[ 1, 3 ], aInfTra[ 1, 5 ] ) //Abre a tabela C9V na empresa destino
					cEmpAnt := aInfTra[ 1, 3 ] //Posiciona na empresa destino
					cFilAnt := aInfTra[ 1, 5 ] //Posiciona na filial destino

					dbSelectArea( "C9V" )
					dbSetOrder( 3 )
					If dbSeek( xFilial( "C9V" ) + cCPF )
						aFuncs[ nCont, 7, 1, 14 ] := C9V->C9V_MATRIC //Atualiza o código único do funcionário conforme o código da filial de destino
					EndIf

					//Volta a empresa para a posicionada
					NGPrepTBL( aTbls, cEmpBkp, cFilBkp ) //Abre a tabela C9V na empresa destino
					cEmpAnt := cEmpBkp //Posiciona na empresa destino
					cFilAnt := cFilBkp //Posiciona na filial destino
				
				EndIf

			EndIf

		EndIf

	Next nCont
	
	//Retorna a área
	RestArea( aArea )

Return

//-------------------------------------------------------------------
/*/{Protheus.doc} MDTVld2240
Verifica se existe o evento S-2240 para o funcionário no
SIGATAF/Middleware

@author	Luis Fellipy Bett
@since	21/02/2022

@param	cMatFun, Matrícula do funcionário a ser validado
@param	cFilFun, Filial do funcionário
@param	dEvento, Data de geração do evento a ser cadastrado

@return	lExsReg, Indica se existe o evento S-2240
/*/
//-------------------------------------------------------------------
Function MDTVld2240( cMatFun, cFilFun, dEvento )

	//Salva a área
	Local aArea := GetArea()

	//Variável para busca das informações
	Local aEvento := {}
	Local cFilEnv := MDTBFilEnv() //Busca a filial de envio para posicionar na CM9
	Local lExsReg := .F.
	Local cIDFunc := ""

	//Define as variáveis padrões
	Default cFilFun := cFilAnt
	Default lMiddleware := IIf( cPaisLoc == 'BRA' .And. Findfunction( "fVerMW" ), fVerMW(), .F. )
	Default dEvento := CtoD( '  /  /    ' )

	//Caso for envio via Middleware
	If lMiddleware

		//Busca os Xml's do evento e funcionário passado por parâmetro
		aEvento := MDTLstXml( "S2240", cMatFun )

		//Verifica se a query retornou algum registro
		lExsReg := !Empty( aEvento )

	Else //Caso for envio via SIGATAF

		//Busca o ID do funcionário no TAF
		cIDFunc := MDTGetIdFun( cMatFun, cFilFun )

		//Caso exista o funcionário no TAF
		If !Empty( cIDFunc )

			dbSelectArea( "CM9" )
			dbSetOrder( 2 )
			If dbSeek( xFilial( "CM9", cFilEnv ) + cIDFunc )

				If FwIsInCallStack( 'D180INCL' ) // Risco
					If dEvento == CM9->CM9_DTINI
						lExsReg := .T.
					EndIf
				Else
					lExsReg := .T.
				EndIf

			EndIf

		EndIf

	EndIf

	//Retorna a área
	RestArea( aArea )

Return lExsReg

//-------------------------------------------------------------------
/*/{Protheus.doc} fBusDatEve
Busca a data do último evento S-2240 do funcionário

@author Gabriel Sokacheski	
@since	16/02/2023

@param, cMat, matrícula do funcionário

@return, dEvento, data do último evento S-2240 do funcionário
/*/
//-------------------------------------------------------------------
Static Function fBusDatEve( cMat )

	Local aDtCM9    := {}

	Local cIdFun	:= ''
	Local cFilEnv 	:= MDTBFilEnv()

	Local dEvento	:= StoD( '  /  /    ' )

	Default lMiddleware := IIf( cPaisLoc == 'BRA' .And. Findfunction( 'fVerMW' ), fVerMW(), .F. )

	If lMiddleware

		dEvento := StoD( MDTLstXml( 'S2240', cMat )[ 1, 4 ] )

	Else

		cIdFun := MDTGetIdFun( cMat, cFilAnt )

		If !Empty( cIdFun )

			DbSelectArea( 'CM9' )
			( 'CM9' )->( DbSetOrder( 2 ) )

			If ( 'CM9' )->( DbSeek( xFilial( 'CM9', cFilEnv ) + cIdFun ) )

				While ( 'CM9' )->( !Eof() ) .And. CM9->CM9_FUNC == cIdFun

					aAdd( aDtCM9, { CM9->CM9_DTINI } )

				( 'CM9' )->( DbSkip() )

				End

				aSort( aDtCM9, Nil, Nil, { | x, y | x[ 1 ] > y[ 1 ] } )

				dEvento := aDtCM9[ 1, 1 ]

			EndIf

		EndIf

	EndIf

Return dEvento

//---------------------------------------------------------------------
/*/{Protheus.doc} MDTChgSRA
Altera os campos da SRA para considerar os dados corretos quando for transferência de funcionário

@return Nil, Nulo

@sample MDTChgSRA( .T., { { 23/06/2021 } } )

@param lAlt, Boolean, Indica se altera os campos, caso seja .F. retorna o valor dos campos
@param aGPEA180, Array, Array com os dados da transferência do funcionário
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
@since 23/06/2021
/*/
//---------------------------------------------------------------------
Function MDTChgSRA( lAlt, aGPEA180 )

	dbSelectArea( "SRA" )
	Reclock( "SRA", .F. )

	If lAlt
		SRA->RA_CC := aGPEA180[ 1, 9 ]
		SRA->RA_DEPTO := aGPEA180[ 1, 11 ]
		If !Empty( aGPEA180[ 1, 12 ] )
			SRA->RA_CODFUNC	:= aGPEA180[ 1, 12 ]
		EndIf
		If !Empty( aGPEA180[ 1, 13 ] )
			SRA->RA_CARGO := aGPEA180[ 1, 13 ]
		EndIf
	Else
		SRA->RA_CC := cCCustoAnt
		SRA->RA_DEPTO := cDeptoAnt
		If !Empty( aGPEA180[ 1, 12 ] )
			SRA->RA_CODFUNC := cFuncaoAnt
		EndIf
		If !Empty( aGPEA180[ 1, 13 ] )
			SRA->RA_CARGO := cCargoAnt
		EndIf
	EndIf

	SRA->( MsUnlock() )

Return

//---------------------------------------------------------------------
/*/{Protheus.doc} MDTChgEmp
Abre os arquivos na empresa passada por parâmetro

@return	Nil, Nulo

@sample	MDTChgEmp( { "TN6", "SRA" }, "T2", "M SC 02 " )

@param	aTbls, Array, Array contendo as tabelas a serem abertas
@param	cEmpCls, Caracter, Indica a empresa para qual as tabelas serão fechadas
@param	cEmpOpn, Caracter, Indica a empresa para qual as tabelas serão abertas

@author	Luis Fellipy Bett
@since	19/10/2021
/*/
//---------------------------------------------------------------------
Function MDTChgEmp( aTbls, cEmpCls, cEmpOpn )

	//Variáveis de busca das informações
	Local cModo := ""

	//Variáveis contadoras
	Local nCont := 0

	//Percorre as tabelas fechando e abrindo nas empresas
	For nCont := 1 To Len( aTbls )

		//Fecha a tabela
		EmpOpenFile( aTbls[ nCont ], aTbls[ nCont ], 1, .F., cEmpCls, @cModo )

		//Abre a tabela
		EmpOpenFile( aTbls[ nCont ], aTbls[ nCont ], 1, .T., cEmpOpn, @cModo )

	Next nCont

Return

//---------------------------------------------------------------------
/*/{Protheus.doc} fEveNObrig
Verifica se o funcionário deve ser integrado estando exposto a algum
risco e tendo a data dos eventos não obrigatórios maior que a data a
ser enviada nos eventos S-2220 e S-2240

@return	lEnvia, Boolean, Indica se deve ou não enviar o evento para o funcionário

@sample	fEveNObrig( "S-2220", { { "0001523" } }, 3, { {} } )

@param	cEvento, Caracter, Indica o evento que está sendo validado
@param	aFuncs, Array, Array contendo as informações do funcionário
@param	nOper, Numérico, Indica a operação que está sendo realizada (3-Inclusão/4-Alteração/5-Exclusão)
@param	aFunNaoEnv, Array, Array que receberá os funcionários que não deverão ser integrados

@author	Luis Fellipy Bett
@since	14/03/2022

@obs	Após a implementação do PPP eletrônico, prevista no dia de hoje (28/04/2022) para
01/01/2023, essa função poderá ser excluída, assim como suas respectivas chamadas pois será
obrigatório o envio dos eventos S-2220 e S-2240 para os trabalhadores sem exposição a riscos
/*/
//---------------------------------------------------------------------
Static Function fEveNObrig( cEvento, aFuncs, nOper, aFunNaoEnv )

	//Salva a área
	Local aArea := GetArea()

	//Variáveis de busca das informações
	Local dDtEnv  := SToD( "" )
	Local dDtAtu  := SToD( "" )
	Local nPosReg := 0

	//Variáveis de parâmetros
	Local dDtEveNObr := SuperGetMv( "MV_NG2DENO", .F., SToD( "20211013" ) )

	//Variáveis de chamadas
	Local lImpASO := IsInCallStack( "NGIMPRASO" ) .Or. IsInCallStack( "MDTR465" ) .Or. IsInCallStack( "NG200IMP" )

	//Variáveis contadoras
	Local nCont := 0

	//Percorre os funcionários validando
	For nCont := 1 To Len( aFuncs )

		//--------------------------------------------------------
		// Verifica a data a ser considerada no envio dos eventos
		//--------------------------------------------------------
		If cEvento == "S-2220" //Caso for validação do evento S-2220

			dDtEnv := IIf( lImpASO, dDataBase, M->TMY_DTEMIS )

		ElseIf cEvento == "S-2240" //Caso for validação do evento S-2240

			//Busca a data de exposição atual do evento S-2240
			dDtAtu := MDTDtExpAtu( aFuncs[ nCont, 1 ] )

			//Busca a data de envio a ser considerada no envio do evento S-2240
			dDtEnv := MDTBscDtEnv( aFuncs[ nCont ], nOper, , dDtAtu )

		EndIf

		//---------------------------------------------------------------------------------------
		// Caso o funcionário não esteja exposto a nenhum risco e a data definida como início de
		// envio dos eventos não obrigatórios seja maior que a data a ser considerada no evento
		//---------------------------------------------------------------------------------------
		If !Empty( dDtEnv ) .And. dDtEnv < dDtEveNObr .And. Len( MDTRis2240( dDtEnv ) ) == 0

			aAdd( aFunNaoEnv, { 4, aFuncs[ nCont, 1 ], AllTrim( Posicione( "SRA", 1, xFilial( "SRA" ) + aFuncs[ nCont, 1 ], "RA_NOME" ) ) } )

		EndIf

	Next nCont

	//----------------------------------------------------------------------
	// Caso exista funcionários que não devem ser enviados, deleta do array
	//----------------------------------------------------------------------
	If Len( aFunNaoEnv ) > 0
		For nCont := 1 To Len( aFunNaoEnv )
			If ( nPosReg := aScan( aFuncs, { |x| x[ 1 ] == aFunNaoEnv[ nCont, 2 ] } ) ) > 0
				aDel( aFuncs, nPosReg ) //Deleta registro do array
				aSize( aFuncs, Len( aFuncs ) - 1 ) //Diminui a posição excluída do array
			EndIf
		Next nCont
	EndIf

	//Retorna a área
	RestArea( aArea )

Return

//-------------------------------------------------------------------
/*/{Protheus.doc} fVldASOAdm
Valida se existe um ASO admissional anterior informado para os funcionários que estão sendo enviados

@return	Nil, Nulo

@param	aFuncs, Array, Array contendo os funcionários para validação
@param	lImpASO, Boolean, Indica se é impressão do ASO

@sample	fVldASOAdm( { { "000230" } }, .T. )

@author	Luis Fellipy Bett
@since	13/04/2022
/*/
//-------------------------------------------------------------------
Static Function fVldASOAdm( aFuncs, lImpASO )

	//Salva a área
	Local aArea := GetArea()
	Local aAreaTMY := TMY->( GetArea() )

	//Variáveis de controle
	Local lRet := .T.
	Local lExsASO := .F.

	//Variáveis de busca e validação das informações
	Local aEvento   := {}
	Local cIdFunc	:= ""
	Local cChvASO	:= ""
	Local cMsgASO	:= ""
	Local aASOAdd	:= {}
	Local aASOExc	:= {}
	Local aArrAux	:= {}
	Local aASOMsg	:= {}
	Local nPosReg	:= 0
	Local nEvento   := 0

	//Variáveis contadoras
	Local nCont	 := 0
	Local nCont2 := 0

	//Percorre os ASO's dos funcionários que estão sendo enviados para validar
	For nCont := 1 To Len( aFuncs )

		//Busca a chave do ASO
		cChvASO := IIf( Len( aFuncs[ nCont ] ) > 8 .And. aFuncs[ nCont, 9 ] <> Nil, aFuncs[ nCont, 9 ], TMY->TMY_FILIAL + TMY->TMY_NUMASO )

		//Busca a natureza do ASO
		cCodASO	:= IIf( lImpASO, Posicione( "TMY", 1, cChvASO, "TMY_NUMASO" ), M->TMY_NUMASO )
		cNatASO	:= IIf( lImpASO, Posicione( "TMY", 1, cChvASO, "TMY_NATEXA" ), M->TMY_NATEXA )
		dDtASO	:= IIf( lImpASO, dDataBase, M->TMY_DTEMIS )

		//Caso o ASO for admissional, verifica se já não existe outro ASO cadastrado
		If cNatASO == "1"

			//Caso for envio via Middleware
			If lMiddleware

				//Busca os Xml's do evento S-2220 para o funcionário
				aEvento := MDTLstXml( "S2220", aFuncs[ nCont, 1 ] )

				For nEvento := 1 To Len( aEvento )

					If MDTXmlVal( "S2220", aEvento[ nEvento, 1 ], "/ns:eSocial/ns:evtMonit/ns:exMedOcup/ns:aso/ns:dtAso", "D" ) < dDtASO
						lExsASO := .T.
						Exit
					EndIf

				Next nEvento

			Else //Caso for envio via SIGATAF

				//Busca o ID do funcionário na tabela CM9
				cIdFunc := MDTGetIdFun( aFuncs[ nCont, 1 ] )

				dbSelectArea( "C8B" )
				dbSetOrder( 2 )
				dbSeek( xFilial( "C8B" ) + cIdFunc )
				While xFilial( "C8B" ) == C8B->C8B_FILIAL .And. C8B->C8B_FUNC == cIdFunc //Percorre os ASO's do funcionário
					
					//Caso o ASO tiver a data anterior ao ASO que está sendo enviado
					If C8B->C8B_DTASO < dDtASO

						//Caso o ASO tenha sido incluído ou alterado
						If ( C8B->C8B_EVENTO == "I" .Or. C8B->C8B_EVENTO == "A" ) .And. aScan( aASOAdd, { | x | x == C8B->C8B_ID } ) == 0
							aAdd( aASOAdd, C8B->C8B_ID )
						ElseIf C8B->C8B_EVENTO == "E" .And. aScan( aASOExc, { | x | x == C8B->C8B_ID } ) == 0
							aAdd( aASOExc, C8B->C8B_ID )
						EndIf

					EndIf

					C8B->( dbSkip() )
				End

				//Passa o conteúdo pro array auxiliar
				aArrAux := aClone( aASOAdd )

				//Caso existirem ASO's cadastrados para o funcionário
				If Len( aArrAux ) > 0
					
					//Percorre o array validando se os ASO's existentes estão excluídos
					For nCont2 := 1 To Len( aArrAux )
						
						//Caso o ASO tiver sido excluído
						If aScan( aASOExc, { | x | x == aArrAux[ nCont2 ] } ) > 0
							
							//Exclui o ASO que possui evento de exclusão para não considerar
							If ( nPosReg := aScan( aASOAdd, { | x | x == aArrAux[ nCont2 ] } ) ) > 0
								aDel( aASOAdd, nPosReg ) //Deleta registro do array
								aSize( aASOAdd, Len( aASOAdd ) - 1 ) //Diminui a posição excluída do array
							EndIf
							
						EndIf

					Next nCont2

					//Caso existam ASO's que não foram excluídos
					If Len( aASOAdd ) > 0
						lExsASO := .T.
					EndIf

				EndIf

			EndIf

			//Caso já exista um ASO admissional
			If lExsASO

				//Adiciona o ASO para apresentar na mensagem
				aAdd( aASOMsg, { aFuncs[ nCont, 1 ], cCodASO } )

			EndIf

			//Retorna a variável para validar o próximo funcionário do laço
			lExsASO := .F.

		EndIf

	Next nCont

	//Caso houverem ASO's a serem informados
	If Len( aASOMsg ) > 0

		//Define a pergunta inicial
		cMsgASO += STR0097 + CRLF + CRLF //"Estão sendo integrados ASO's admissionais para os funcionários abaixo, porém os mesmos já possuem outro ASO admissional integrado ao SIGATAF/Middleware. Deseja realizar a integração mesmo assim?"

		//Percorre o array para montar a variável
		For nCont := 1 To Len( aASOMsg )

			cMsgASO += STR0024 + ": " + AllTrim( aASOMsg[ nCont, 1 ] ) + " - " + ; //"Funcionário"
						AllTrim( Posicione( "SRA", 1, xFilial( "SRA" ) + aASOMsg[ nCont, 1 ], "RA_NOME" ) ) + " / " + ;
						STR0096 + ": " + aASOMsg[ nCont, 2 ] + CRLF //"ASO"

		Next nCont

		//Exibe a mensagem perguntando ao usuário se deve continuar com a integração ou não
		lRet := MsgYesNo( cMsgASO, STR0017 )

	EndIf

	//Retorna as áreas
	RestArea( aAreaTMY )
	RestArea( aArea )

Return lRet

//---------------------------------------------------------------------
/*/{Protheus.doc} fMdtCarEso
Realiza a validação das informações do evento S-2240 ao Governo.
Chamada no fonte gpea370. (Cargos)

@author Gabriel Sokacheski
@since 27/04/2022

@param nOperacao, Numérico, Tipo de operação realizada na rotina
@param lEnvio, Boolean, Indica se é envio de informações,
caso contrário trata como validação
@param oModel, Objeto, Objeto do modelo

@return lRet, Booleano, Verdadeiro caso não existam inconsistências
/*/
//---------------------------------------------------------------------
Function mdtesoCar( nOperacao, lEnvio, oModel )

	Local aFun := {}

	Local cDesc := SuperGetMV( 'MV_NG2TDES', .F., '1' )
	Local cCargo := oModel:GetValue( 'Q3_CARGO' )
	Local cAliasFun := GetNextAlias()


	Local lRet := .T.

	If nOperacao == 4 .And. oModel:IsFieldUpdated( 'Q3_MEMO1' ) .And. cDesc $ '2/4'

		BeginSQL Alias cAliasFun
			SELECT
				RA_MAT
			FROM
				%table:SRA%
			WHERE
				RA_FILIAL = %xFilial:SRA%
				AND RA_CARGO = %exp:cCargo%
				AND %NotDel%
		EndSQL

		dbSelectArea( cAliasFun )
		dbGoTop()

		While ( cAliasFun )->( !Eof() )

			If MdtVld2240( ( cAliasFun )->RA_MAT ) // Verifica se o funcionário já possui o evento S-2240

				aAdd( aFun, { ( cAliasFun )->RA_MAT } )

			EndIf

			( cAliasFun )->( dbSkip() )

		End

		( cAliasFun )->( dbCloseArea() )

		// Caso existam funcionários a serem enviados
		If Len( aFun ) > 0

			lRet := MDTIntEsoc( 'S-2240', nOperacao, Nil, aFun, lEnvio ) // Valida as informações a serem enviadas ao Governo

		EndIf

	EndIf

Return lRet

//---------------------------------------------------------------------
/*/{Protheus.doc} MdtEsoFimT
Verifica se a descrição e o ambiente do S-2240 estão vinculados a
tarefa e alerta ao preencher a data de término.

@author Gabriel Sokacheski
@since 16/08/2022

/*/
//---------------------------------------------------------------------
Function MdtEsoFimT()

	If SuperGetMV( 'MV_NG2TDES', .F., Nil ) $ '1/4'
		// "O parâmetro está configurado como tarefa e a descrição das atividades no S-2240 poderá ficar em branco"
		// "O envio do evento sem uma informação obrigatória irá ocasionar um erro."
		MsgAlert( STR0098 + '.' + Space( 1 ) + STR0100 + '.', 'MV_NG2TDES' )
	EndIf

	If SuperGetMV( 'MV_NG2EAMB', .F., Nil ) == '4'
		// "O parâmetro está configurado como tarefa e o ambiente no S-2240 poderá ficar em branco"
		// "O envio do evento sem uma informação obrigatória irá ocasionar um erro."
		MsgAlert( STR0099 + '.' + Space( 1 ) + STR0100 + '.', 'MV_NG2EAMB' )
	EndIf

Return

//-------------------------------------------------------------------
/*/{Protheus.doc} MdtEsoFun
Busca os funcionários expostos aos riscos e envia ao eSocial.

@author Luis Fellipy Bett
@since 08/08/2019

@param lValid, Lógico, indica se fará a validação dos dados ou o envio
/*/
//-------------------------------------------------------------------
Function MdtEsoFun( lEnvio )

	Local aFuncs	:= {}
	Local aCampos	:= {}
	Local aRiscos	:= {}
	Local aAreaTN0	:= TN0->( GetArea() )

	Local nRisco 	:= 0

	Local lRet		:= .T.
	Local lEnvEso 	:= .T.

	Local oTempFunc

	Default lEnvio := .T.

	aCampos := {	{ "TMPA_MATRI", "C", TAMSX3( "RA_MAT" )[ 1 ], 0 }, ;
					{ "TMPA_NOMFU", "C", TAMSX3( "RA_NOME" )[ 1 ], 0 }, ;
					{ "TMPA_DTINI", "D", 8, 0 }, ;
					{ "TMPA_DTFIM", "D", 8, 0 }, ;
					{ "TMPA_TAREF", "C", TAMSX3( "TN5_NOMTAR" )[ 1 ], 0 }, ;
					{ "TMPA_CCUST", "C", TAMSX3( "CTT_DESC01" )[ 1 ], 0 }, ;
					{ "TMPA_FUNCA", "C", TAMSX3( "RJ_DESC" )[ 1 ], 0 }, ;
					{ "TMPA_NVFIL", "C", TAMSX3( "RA_FILIAL" )[ 1 ], 0 }, ;
					{ "TMPA_DEPTO", "C", TAMSX3( "TM0_DEPTO" )[ 1 ], 0 } }

	oTempFunc := FWTemporaryTable():New( "TMPA", aCampos )
	oTempFunc:AddIndex( "1", { "TMPA_NOMFU" }  )
	oTempFunc:Create()

	// Busca os riscos que estão sendo cadastrados no momento
	If FWIsInCallStack( 'MDT232REL' )

		aEval( aCols1, { | x | IIf( Empty( x[ 4 ] ) .And. !x[ 6 ], aAdd( aRiscos, x[ 1 ] ), Nil )  } )

		For nRisco := 1 To Len( aRiscos )

			DbSelectArea( 'TN0' )
			DbSetOrder( 1 )
			If DbSeek( xFilial( 'TN0' ) + aRiscos[ nRisco ] )

				RegToMemory( 'TN0' )
				MDT180BFUN()

				dbSelectArea( 'TMPA' )
				( 'TMPA' )->( DbGoTop() )

				While TMPA->( !Eof() )

					If aScan( aFuncs, { | x | x[ 1 ] == TMPA->TMPA_MATRI } ) == 0
						aAdd( aFuncs, { TMPA->TMPA_MATRI } )
					EndIf

					TMPA->( dbSkip() )

				End

			EndIf

		Next nRisco

	Else

		aEval( aCols1, { | x | IIf( Empty( x[ 4 ] ) .And. !x[ 6 ], Nil, lEnvEso := .F. )  } )

		If lEnvEso

			RegToMemory( 'TN0' )
			MDT180BFUN()

			dbSelectArea( 'TMPA' )
			( 'TMPA' )->( DbGoTop() )

			While TMPA->( !Eof() )

				If aScan( aFuncs, { | x | x[ 1 ] == TMPA->TMPA_MATRI } ) == 0
					aAdd( aFuncs, { TMPA->TMPA_MATRI, Nil, TN0->TN0_NUMRIS } )
				EndIf

				TMPA->( dbSkip() )

			End

		EndIf

	EndIf

	oTempFunc:Delete()

	If lEnvEso
		If Len( aFuncs ) > 0 .And. FindFunction( 'MDTIntEsoc' )
			lRet := MDTIntEsoc( 'S-2240', 4, Nil, aFuncs, lEnvio )
		EndIf
	EndIf

	RestArea( aAreaTN0 )

Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} MdtEsoDatF
Busca a data do primeiro evento em que a descrição das atividades
corresponde ao campo de requisitos da função em questão

@author Gabriel Sokacheski
@since 06/09/2023

@param cMatricula, matrícula do funcionário

@return dEvento, data do evento encontrado (vazio caso não encontre)
/*/
//-------------------------------------------------------------------
Function MdtEsoDatF( cMatricula )

	Local aEvento 		:= {}

	Local cAliasFun		:= GetNextAlias()
	Local cAtividade	:= ''

	Local dEvento  		:= SToD( '' )

	Local nEvento 		:= 0
	Local nEventos		:= 0

	Default lMiddleware := IIf( cPaisLoc == 'BRA' .And. Findfunction( 'fVerMW' ), fVerMW(), .F. )

	If !lMiddleware // Caso seja integração através do SIGATAF

		cIDFunc := MDTGetIdFun( cMatricula ) // Busca o ID do funcionário do TAF

		BeginSQL Alias cAliasFun
			SELECT
				CM9.CM9_DTINI, CM9.CM9_DATIVD
			FROM
				%table:CM9% CM9
			WHERE
				CM9.CM9_FILIAL = %xFilial:CM9%
				AND CM9.CM9_FUNC = %exp:cIDFunc%
				AND CM9.%NotDel%
			ORDER BY
				CM9.CM9_DTINI DESC
		EndSQL

		DbSelectArea( cAliasFun )

		While ( cAliasFun )->( !Eof() )

			//----------------------------------------------------------
			// Compara o conteúdo do campo de descrição das atividades
			// com o conteúdo do campo de requisitos antes da alteração
			//----------------------------------------------------------

			If ( cAliasFun )->( CM9_DATIVD ) == cReqAnt
				dEvento := SToD( ( cAliasFun )->( CM9_DTINI ) )
			EndIf

			nEventos += 1
			( cAliasFun )->( DbSkip() )

		End

		( cAliasFun )->( DbCloseArea() )

	Else // Caso seja integração através do Middleware

		aEvento := MDTLstXml( 'S2240', cMatricula )

		nEventos := Len( aEvento )

		For nEvento := 1 To nEventos

			cAtividade := SubStr( aEvento[ nEvento, 1 ], At( '<dscAtivDes>', aEvento[ nEvento, 1 ] ) + Len( '<dscAtivDes>' ) )
			cAtividade := SubStr( cAtividade, 1, At( '</dscAtivDes>', cAtividade ) - 1 )

			//----------------------------------------------------------
			// Compara o conteúdo do campo de descrição das atividades
			// com o conteúdo do campo de requisitos antes da alteração
			//----------------------------------------------------------

			If cAtividade == cReqAnt

				If Len( aEvento ) > 0
					dEvento := MDTXmlVal( 'S2240', aEvento[ nEvento, 1 ], '/ns:eSocial/ns:evtExpRisco/ns:infoExpRisco/ns:dtIniCondicao', 'D' )
				EndIf

			EndIf

		Next nEvento

	EndIf

Return { dEvento, nEventos }

//-------------------------------------------------------------------
/*/{Protheus.doc} MdtMidTaf
Verifica se o ambiente utiliza middleware ou taf

@author Gabriel Sokacheski
@since 02/11/2023

@return lMid, verdadeiro caso utiliza middleware
/*/
//-------------------------------------------------------------------
Function MdtMidTaf()

	Local lMid := .F.

	If cPaisLoc == 'BRA' .And. Findfunction( 'fVerMW' ) .And. fVerMW()
		lMid := .T.
	EndIf

Return lMid

//-------------------------------------------------------------------
/*/{Protheus.doc} MdtRetLei
Retorna o leiaute atual

@author Gabriel Sokacheski
@since 02/11/2023

@param cEvento, evento sendo gerado

@return cLeiaute, leiaute atual
/*/
//-------------------------------------------------------------------
Function MdtRetLei( cEvento )

	Local cLeiaute := ''

	If MdtMidTaf() // Middleware
		fVersEsoc( cEvento, .F., Nil, Nil, Nil, Nil, @cLeiaute )
	Else // Taf
		cLeiaute := SuperGetMv( 'MV_TAFVLES', .F., 'S_01_01' )
	EndIf

Return cLeiaute

//-------------------------------------------------------------------
/*/{Protheus.doc} MdtEndExt
Verifica se o endereço do funcionário é no exterior

@author Gabriel Sokacheski
@since 02/11/2023

@param cFilSra, filial SRA do funcionário
@param cMatSra, matrícula SRA do funcionário

@return lEndExt, verdadeiro caso possua endereço no exterior
/*/
//-------------------------------------------------------------------
Function MdtEndExt( cFilSra, cMatSra )

	Local aAreaSra 	:= ( 'SRA' )->( GetArea() )

	Local lEndExt 	:= Posicione( 'SRA', 1, cFilSra + cMatSra, 'RA_RESEXT' ) == '1' // Reside no exterior: '1'=Sim;'2'=Não;

	RestArea( aAreaSra )

Return lEndExt

//---------------------------------------------------------------------
/*/{Protheus.doc} fMudAmb
Verifica se o funcionário mudou de ambiente físico

@author Eloisa Anibaletto
@since 20/03/2024

@param cMatFun, matrícula do funcionário 

@return lMudAmb, retorna verdadeiro se mudou de ambiente físico
/*/
//---------------------------------------------------------------------
Static Function fMudAmb( cMatFun )

	Local aAreaCM9    := GetArea( 'CM9' )
	Local aAreaT0Q    := GetArea( 'T0Q' )
	Local aIdCM9      := {}
	Local aEvenFun    := {}

	Local cIdFun      := ''
	Local cIdCM9      := ''
	Local cLocal      := ''
	Local cSetor      := ''
	Local cTipoIns    := ''
	Local cNumIns     := ''

	Local lMudAmb   := .F.

	If lMiddleware

		aEvenFun := MDTLstXml( "S2240", cMatFun ) //Busca os xmls do evento S-2240 do funcionário

		cLocal   := MDTXmlVal( "S2240", aEvenFun[ 1, 1 ], "/ns:eSocial/ns:evtExpRisco/ns:infoExpRisco/ns:infoAmb/ns:localAmb", "C" )
        cSetor   := MDTXmlVal( "S2240", aEvenFun[ 1, 1 ], "/ns:eSocial/ns:evtExpRisco/ns:infoExpRisco/ns:infoAmb/ns:dscSetor", "C" )
        cTipoIns := MDTXmlVal( "S2240", aEvenFun[ 1, 1 ], "/ns:eSocial/ns:evtExpRisco/ns:infoExpRisco/ns:infoAmb/ns:tpInsc", "C" )
		cNumIns  := MDTXmlVal( "S2240", aEvenFun[ 1, 1 ], "/ns:eSocial/ns:evtExpRisco/ns:infoExpRisco/ns:infoAmb/ns:nrInsc", "C" )

		If cLocal + cSetor + cTipoIns + cNumIns != TNE->TNE_LOCAMB + AllTrim( TNE->TNE_NOME ) + TNE->TNE_TPINS + TNE->TNE_NRINS
			lMudAmb := .T.
		EndIf

	Else

		cIdFun    := MDTGetIdFun( cMatFun )

		DbSelectArea( 'CM9' )
		( 'CM9' )->( DbSetOrder( 2 ) )

		If dbSeek( xFilial( 'CM9' ) + cIdFun )

			While ( 'CM9' )->( !Eof() ) .And. CM9->CM9_FUNC == cIdFun

				aAdd( aIdCM9, { CM9->CM9_ID } )

				( 'CM9' )->( DbSkip() )

			End

			cIdCM9 := ArrTokStr( aTail( aIdCM9 ) )

		EndIf

		DbSelectArea( 'T0Q' )
		( 'T0Q' )->( DbSetOrder( 1 ) )

		If ( 'T0Q' )->( DbSeek( xFilial( 'T0Q' ) + cIdCM9 ) )

			If T0Q->T0Q_FILIAL + T0Q->T0Q_LAMB + T0Q->T0Q_DSETOR + T0Q->T0Q_TPINSC;
			+ T0Q->T0Q_NRINSC != TNE->TNE_FILIAL + TNE->TNE_LOCAMB + AllTrim( TNE->TNE_NOME );
			+ TNE->TNE_TPINS + TNE->TNE_NRINS
				lMudAmb := .T.	
			EndIf

		EndIf

	EndIf

	RestArea( aAreaT0Q )
	RestArea( aAreaCM9 )

Return lMudAmb
