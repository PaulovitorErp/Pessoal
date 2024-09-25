#INCLUDE "PROTHEUS.CH"
#INCLUDE "FILEIO.CH"
#INCLUDE "MNTSR.CH"

#DEFINE __AFIELDSO_SO__ 1
#DEFINE __AFIELDSO_INPUT__ 2
#DEFINE __AFIELDSO_STEP__ 3

//------------------------------------------------------------------------------
/*/{Protheus.doc} MntSR
Classe de Solicitação de Serviço - MntSR

@author Guilherme Freudenburg
@since 29/05/2018
@version P12
/*/
//------------------------------------------------------------------------------
Class MntSR FROM NGGenerico

	Method New() CONSTRUCTOR

	//------------------------------------------------------
	// Publico: Validação e Operação
	//------------------------------------------------------
	Method ValidBusiness() // Validações de negócio.
	Method Upsert() // Método para inclusão e alteração.
	Method CreateSO() // Método para geração de O.S.
	Method Delete() // Método para exclusão.
	Method Assign() // Método para Distribuição da S.S.
	Method Close()  // Método para Fechamento da S.S.

	//------------------------------------------------------
	// Publico: Status da S.S.
	//------------------------------------------------------
	Method IsAnalysis()  // Aguardando Análise
	Method IsAssigned()  // Distribuída
	Method IsClosed()    // Fechada
	Method IsCanceled()  // Cancelada (Somente Facilities)
	Method IsCreateSO()  // Verifica se está no processo de Geração de OS
	Method IsAnswer()    // Verifica se está no processo de Resposta Questionário de Satisfação.

	//-------------------------------------------------------
	// Publico: Geração de OS
	//-------------------------------------------------------
	Method SetValueSO()   // Método para definir valores para geração de OS.
	Method HasSO()        // Verifica se existe OS em aberto para a SS.
	Method HasInput()     // Verifica se a OS possui insumos
	Method HasStep()      // Verifica se a OS possui etapas
	Method isCorrective() // Define se a O.S. é Corretiva
	Method isPreventive() // Define se a O.S. é Preventiva
	Method isThird()      // Indica se a O.S. é enviada para Terceiros

	//-------------------------------------------------------
	// Publico: Imagem
	//-------------------------------------------------------
	Method AddFile() // Método para adicionar imagem no Banco de Conhecimento
	Method GetFile() // Método para pegar imagem do Banco de Conhecimento
	Method GetFileList() // Método para pegar todas as imagens da S.S do Banco de Conhecimento
	Method DeleteFile()  // Método para excluir imagem do Bnaco de Conhecimento.

    //-------------------------------------------------------
	// Privado: Contador
	//-------------------------------------------------------
	Method HasCounter() // Método para identificação da utilização de contador.

    //-------------------------------------------------------
	// Privado: Workflow
	//-------------------------------------------------------
	Method SendWF() // Método para envio de Workflow.

	//--------------------------------------------------------------------------
	// Privado: Atributos gerais
	//--------------------------------------------------------------------------
	Data aFieldSO As Array

EndClass

//------------------------------------------------------------------------------
/*/{Protheus.doc} New
Método inicializador da classe

@author Guilherme Freudenburg
@since 01/06/2018
@version P12
@return Self, Objeto, objeto criado.
/*/
//------------------------------------------------------------------------------
Method New() Class MntSR

	_Super:New()

	// Alias formulário.
	::SetAlias("TQB")

	// Define o tipo de validação da classe.
	::SetValidationType("OUB")

	// Campos que não serão alterados.
	::SetUniqueField("TQB_FILIAL")
	::SetUniqueField("TQB_SOLICI")

	// Parâmetros utilizados
	::SetParam("MV_NGSSWRK", "N") // Geração de Workflow.
	::SetParam("MV_NG1FAC" , "2") // Integração com Facilites.
	::SetParam("MV_NGMNTMS", "N") // Integração com o TMS.
	::SetParam("MV_NGMULOS", "N") // Permite gerar múltiplas OS's a partir do retorno da Distribuição.
	::SetParam("MV_NGMNTFR", "N") // Indica se a empresa ira utilizar o Gestao de Frota.
	::SetParam("MV_NGSEREF", "")  // Código do serviço para Reforma de Pneus.
	::SetParam("MV_NGSECON", "")  // Codigo de servico para conserto de pneus.
	::SetParam("MV_NGSSPRE", "N") // Indica se a Solicitacao de Servico podera gerar OS do tipo Preventiva/Preditiva.
	::SetParam("MV_NGPSATI", "N") // Indica se utiliza pesquisa de satisfação das solicitações de serviços.
	::SetParam("MV_NGUNIDT", "D") // Indica o formato de data utilizado.
	::SetParam("MV_NGTARGE", "2") // Indica se utiliza Tarefa Genrérica.

	// Variáveis Privadas
	::cClassName := "MntSR"// Determina o nome da classe.
	// Exemplo da estrutura do ::aFieldSO
	// aAdd(aFieldSO,{ {*Ordem de Serviço 1*,{{Insumo 1}, {Insumo 2}, {Insumo 3}},{{Etapa 1}, {Etapa 2}, {Etapa 3}}} })
	::aFieldSO   := {} // Campos específicos para Geração de OS.

	// Gravação dos campos memo.
	::SetRelMemos({{"TQB_CODMSS", "TQB_DESCSS"},{"TQB_CODMSO","TQB_DESCSO"}})

Return Self

//------------------------------------------------------------------------------
/*/{Protheus.doc} ValidBusiness
Método que realiza a validação da regra de negócio da classe.

@param nOperation, Numérico, Determina o numero da operação selecionado.

@author Guilherme Freudenburg
@author Wexlei Silveira
@since 01/06/2018
@return lValid, lógico, confirma que os valores foram validados pela classe.
/*/
//------------------------------------------------------------------------------
Method ValidBusiness(nOperation) Class MntSR

	Local aArea     := GetArea()
	Local cError    := ""
	Local cUserName := RetCodUsr() // Retorna código do usuário.
	Local lRet      := .T.
	Local lGetAsk   := ::GetAsk()
	Local aOldArea  := {}
	Local aRet      := {}
	Local aEntryPt  := {}
	Local aHelp     := {}
	Local cSRStatus := ""
	Local nInd      := 0
	Local nCost     := 0
	Local nHourCt1  := 0
	Local nHourCt2  := 0
	Local nDateIn   := 0
	Local nAsset    := 0
	Local nCount1   := 0
	Local nCount2   := 0
	Local nX        := 0
	Local nTask     := 0
	Local nRegType  := 0
	Local nTlCode   := 0
	Local nQuant    := 0
	Local nStepTask := 0
	Local nStep     := 0
	Local nResQt    := 0
	Local nLocal    := 0
	Local nUse      := 0
	Local nUnity    := 0
	Local nRecord   := 0
	Local cInput    := ""
	Local dDateIn
	Local nService  := 0
	Local cService  := ""
	Local nSitua    := 0
	Local nSeque    := 0
	Local cSeque    := ""
	Local cAssetSO  := ""
	Local cFil2ST4  := NGTROCAFILI("ST4","")
	Local cFil2STE  := NGTROCAFILI("STE","")
	Local cFil2STF  := NGTROCAFILI("STF","")
	Local cHourSys  := SubStr( Time(), 1, 5 )
	Local cDateSys  := DToS( Date() )
	Local lDevice   := IsInCallStack("RESTEXECUTE") // Indica se vem do Mobile
	Local xPE280I   := Nil
	Local cCostTable  := If(CtbInUse(), "CTT", "SI3")
	Local cCostField  := If(CtbInUse(), "CTT_CUSTO", "I3_CUSTO")

	// Informações da TQB para validação.
	Local cBranch   := ::GetValue("TQB_FILIAL")
	Local cSolici   := ::GetValue("TQB_SOLICI")
	Local cDescSR   := ::GetValue("TQB_DESCSS")
	Local cTypeSR   := ::GetValue("TQB_TIPOSS")
	Local cAsset    := ::GetValue("TQB_CODBEM")
	Local cCostCnt  := ::GetValue("TQB_CCUSTO")
	Local cDateOp   := ::GetValue("TQB_DTABER")
	Local cHourOp   := ::GetValue("TQB_HOABER")
	Local cSolution := ::GetValue("TQB_SOLUCA")
	Local cCodeReq  := ::GetValue("TQB_CDSOLI")
	Local nCounter1 := ::GetValue("TQB_POSCON")
	Local nCounter2 := ::GetValue("TQB_POSCO2")
	Local cServCode := ::GetValue("TQB_CDSERV")
	Local cSupervi  := ::GetValue("TQB_FUNEXE")
	Local cWorkCnt  := ::GetValue("TQB_CENTRA")
	Local cExecCode := ::GetValue("TQB_CDEXEC")
	Local cPriority := ::GetValue("TQB_PRIORI")
	Local cOrder    := ::GetValue("TQB_ORDEM")
	Local cDateCl   := ::GetValue("TQB_DTFECH")
	Local cHourCl   := ::GetValue("TQB_HOFECH")
	Local cTime     := ::GetValue("TQB_TEMPO")
	Local cDeadL    := ::GetValue("TQB_PSAP")
	Local cNeed     := ::GetValue("TQB_PSAN")

	aRet      := NgFilTPN(cAsset,cDateOp,cHourOp,,cBranch)
	cSRStatus := Posicione("TQB",01,cBranch+cSolici,"TQB_SOLUCA")
	nCount1   := Posicione("TQB",01,cBranch+cSolici,"TQB_POSCON")
	nCount2   := Posicione("TQB",01,cBranch+cSolici,"TQB_POSCO2")

	//------------------------------------------------------------------------
	// MNTSR - Validações
	//------------------------------------------------------------------------
	If ::IsInsert()

		//------------------------------------------------------------------------
		// 1 - Validação de campos obrigatórios na Inclusão
		//------------------------------------------------------------------------

		// 1.1 - O campo Bem/Localiz. (TQB_CODBEM) deve estar preenchido.
		If Empty(cError) .And. Empty(cAsset) .And. !::IsUpdate()
			cError := ::MsgRequired('TQB_CODBEM') // O campo não foi preenchido.
		EndIf

		// 1.2 - O campo Solicitacao (TQB_SOLICI) deve estar preenchido.
		If Empty(cError) .And. Empty(cSolici)
			cError := ::MsgRequired('TQB_SOLICI') // O campo não foi preenchido.
		EndIf

		// 1.3 - O campo Tipo Item (TQB_TIPOSS) deve estar preenchido.
		If Empty(cError) .And. (!Empty(cTypeSR) .And. !(cTypeSR $ "BL"))
			cError := ::MsgRequired('TQB_TIPOSS') // O campo não foi preenchido.
		EndIf

		// 1.3.1 - O campo Serviço (TQB_DESCSS) deve estar preenchido
		If Empty(cError) .And. Empty(cDescSR)
			cError := ::MsgRequired('TQB_DESCSS') // O campo não foi preenchido.
		EndIf

		// Validações de permissão para o bem/localização
		If cTypeSR == "B" // Se for bem

			// 1.4 - O código do bem precisa ser válido.
			dbSelectArea("ST9")
			dbSetOrder(1)
			If !dbSeek(xFilial("ST9") + cAsset)
				cError := STR0001 // "Não existe Bem relacionado a este código."
			Else

				// 1.5 - O bem precisa estar ativo.
				If ST9->T9_SITBEM == "I"//Bem Inativo
					cError := STR0002 // "O Bem está Inativo no sistema."

				// 1.6 - O bem precisa pertencer a filial atual.
				ElseIf ST9->T9_SITBEM = "T"//Bem Transferido
					cError := STR0003 // "O Bem foi Transferido."

				// 1.7 - O bem precisa estar com manutenção ativa.
				ElseIf ST9->T9_SITMAN = "I"//Situação do bem Inativa
					cError := STR0004 // "Situação da Manutenção do bem está Inativa."
				EndIf

			EndIf

		Else // Se for localização

			// 1.8 - O usuário precisa ter permissão para incluir S.S. para bem informado.
			If Empty( cError ) .And. AllTrim( Posicione( 'TAF', 7, FWxFilial( 'TAF', cBranch ) + 'X2' +;
				Substr( cAsset, 1, FWTamSX3( 'TAF_CODNIV' )[1] ), 'TAF_CODNIV') ) != AllTrim( cAsset )

				cError := STR0005 // Não existe Localização relacionada a este código.

			// 1.9 - O usuário precisa ter permissão para incluir S.S. para a localização informada.
			ElseIf Empty( cError )

				dbSelectArea( 'TAF' )
				dbSetOrder( 2 ) // TAF_FILIAL + TAF_CODEST + TAF_CODNIV + TAF_NOMNIV
				If msSeek( cBranch + '001' + SubStr( cAsset, 1, FWTamSX3( 'TAF_CODNIV' )[1] ) )

					lRet := NGValidTUA() // Verifica se há permissão para visualizar o registro.

					If lRet
						lRet := MNT902REST( TAF->TAF_CODNIV, 'S', 'I', .F. )
					EndIf

					If !lRet
						cError := STR0006 // "Usuário sem permissão para incluir solicitações para esta localização."
					EndIf

				EndIf

			EndIf

		EndIf

		// 1.10 - O campo Centro Custo (TQB_CCUSTO) deve referenciar um centro de custo na tabela SI3 conforme regras do CTB.
		If Empty(cError) .And. cTypeSR != "L" .And. !Empty(cCostCnt) // Não valida para localização

			If Alltrim(cCostCnt) != Alltrim(aRet[2]) .Or. Empty(Alltrim(Posicione(cCostTable,1,xFilial(cCostTable) + cCostCnt,cCostField)))
				cError := STR0007 // "O Centro de Custo informado é incorreto, conforme histórico de movimentações."
			EndIf

		EndIf

		// 1.11 - O campo Centro Trabalho (TQB_CENTRA) deve estar de acordo com o Centro de Trabalho cadastrado na ST9 para o bem e com a TPN.
		If Empty(cError) .And. cTypeSR != "L" .And. !Empty(cWorkCnt) // Não valida para localização

			dbSelectArea("ST9")
			dbSetOrder(1)
			If dbSeek(cBranch + cAsset)

				If !Empty(ST9->T9_CENTRAB) .And. Alltrim(cWorkCnt) != Alltrim(ST9->T9_CENTRAB)
					cError := STR0008 // "O Centro de Trabalho informado é inválido."
				EndIf

			EndIf

			If Empty(cError) .And. Alltrim(cWorkCnt) != Alltrim(aRet[3])
				cError := STR0009 // "O Centro de Trabalho informado é incorreto, conforme histórico de movimentações."
			EndIf

		EndIf

		// 1.12 - O campo Dt. Abertura (TQB_DTABER) deve estar preenchido e ser menor ou igual a data atual.
		If Empty(cError)
			If Empty(cDateOp)
				cError := ::MsgRequired('TQB_DTABER') // O campo não foi preenchido.
			ElseIf cDateOp > dDataBase
				cError := STR0010 + Alltrim(Posicione("SX3",2,"TQB_DTABER","X3Titulo()")) + STR0011 // "O campo " #### " deve ser menor ou igual a data atual."
			ElseIf cDateOp == dDataBase .And. cHourOp > SubStr(Time(),1,5)
				cError := STR0010 + Alltrim(Posicione("SX3",2,"TQB_HOABER","X3Titulo()")) + STR0012 // "O campo " #### " deve ser menor ou igual a hora atual."
			EndIf
		EndIf

		// 1.13 - O campo Hr. Abertura (TQB_HOABER) deve estar preenchido.
		If Empty(cError) .And. Empty(cHourOp)
			cError := ::MsgRequired('TQB_HOABER') // O campo não foi preenchido.
		EndIf

		// 1.14 - O campo Hr. Abertura (TQB_HOABER) deve estar preenchido e ser válido.
		If Empty(cError) .And. !Empty(cHourOp) .And. !NGVALHORA(cHourOp,.F.)
			cError := STR0010 + Alltrim(Posicione("SX3",2,"TQB_HOABER","X3Titulo()")) + STR0013 // "O campo " #### " deve ser válido."
		EndIf

		// 1.15 - O campo Situacao S.S (TQB_SOLUCA) deve estar preenchido.
		If Empty(cError) .And. Empty(cSolution)
			cError := ::MsgRequired('TQB_SOLUCA') // O campo não foi preenchido.
		EndIf

		// 1.16 - O campo Situacao S.S (TQB_SOLUCA) deve estar preenchido e conter o valor "ADEC" .
		If Empty(cError) .And. !Empty(cSolution) .And. !( Left( cSolution, 1 ) $ 'A/D/E/C' )
			cError := STR0010 + Alltrim(Posicione("SX3",2,"TQB_SOLUCA","X3Titulo()")) + STR0014 // "O campo " #### " deve estar preechido e conter um valor entre: A, D, E ou C."
		EndIf

		// 1.17 - O campo Supervisor (TQB_FUNEXE) precisa ser válido.
		If Empty(cError) .And. !Empty(cSupervi) .And. !Empty(cServCode)
			aRet := NGFUNCRH( cSupervi, .F., , ,.T. )
			If !aRet
				cError := aRet[2]
			EndIf
			If Empty(cError) .And. Alltrim(Posicione("ST1",1,cSupervi,"T1_CODFUNC")) != Alltrim(cSupervi)
				cError := STR0015 + Alltrim(Posicione("SX3",2,"TQB_FUNEXE","X3Titulo()")) + STR0016 //"O valor informado no campo " #### " não foi encontrado na tabela de funcionários da manutenção."
			EndIf
		EndIf

		// 1.18 - O campo Solicitante (TQB_CDSOLI) deve estar preenchido.
		If Empty(cError) .And. Empty(cCodeReq)
			cError := ::MsgRequired('TQB_CDSOLI') // O campo não foi preenchido.
		EndIf

		// 1.19 - O usuário do campo Solicitante (TQB_CDSOLI) deve existir.
		If Empty(cError) .And. !Empty(cCodeReq)

			PswOrder(1) // Posiciona no usuário
			If !PswSeek(cCodeReq, .T.)
				cError := STR0017 //"Não existe usuário relacionado à este código."
			EndIf

		EndIf

		// 1.20 - O campo Tipo Servico (TQB_CDSERV) precisa ser válido.
		If Empty(cError) .And.  !Empty(cServCode)
			cError := fValServ(cServCode)
		EndIf

		//------------------------------------------------------------------------
		// 2 - Validações a nível de relacionamentos
		//------------------------------------------------------------------------

		// 2.1 - Validação de escala de viagem para o período da SS.
		If Empty(cError) .And. ::GetParam("MV_NGMNTMS", "N") == "S"
			aHelp := NGCHKTMS(cAsset, cDateOp, cHourOp, .F.)
			If !aHelp[2]
				If aHelp[3]
					cError := aHelp[1]
				ElseIf lGetAsk
					::AddAsk(aHelp[1])
				EndIf
			EndIf
		EndIf

		// 2.2 - Validação de existência de S.S. duplicada
		If Empty(cError) .And. !Empty(cAsset) .And. !Empty(cServCode)
			If fDplSR(Self, cAsset, cServCode)
				If lGetAsk
					::AddAsk( STR0018 ) // "Existe pelo menos uma Solicitação de Serviço incluída para o mesmo bem/localização e área de manutenção desta S.S."
				EndIf
			EndIf
		EndIf

		// 2.3 - Validação de existência de O.S. vencidas.
		If Empty(cError) .And. !Empty(cAsset)

			aRet := NGOSABRVEN( cAsset,,.F.,.T.,.T.,,, .F., .T., 2 )

			If aRet[1]
				If aRet[3]
					cError := aRet[2]
				ElseIf lGetAsk
					::AddAsk(aRet[2])
				EndIf
			EndIf
		EndIf

		// 3.3 - O campo Contador (TQB_POSCON) deve estar preenchido com um valor válido
		If Empty(cError) .And. nCounter1 != 0

			aRet := fValCnt(cAsset, cDateOp, cHourOp, nCounter1, 1, lGetAsk)

			If !Empty( aRet[2] )

				If aRet[1]
					::AddAsk( aRet[2] )
				Else
					cError := aRet[2]
				EndIf

			EndIf

		EndIf

		// 3.4 - O campo Contador 2 (TQB_POSCO2) deve estar preenchido com um valor válido
		If Empty(cError) .And. nCounter2 != 0

			aRet := fValCnt(cAsset, cDateOp, cHourOp, nCounter2, 2, lGetAsk)

			If !Empty( aRet[2] )

				If aRet[1]
					::AddAsk( aRet[2] )
				Else
					cError := aRet[2]
				EndIf

			EndIf

		EndIf

		//---------------------------------------------------------
		// Verifica se há pesquisa pendente para o usuário
		//---------------------------------------------------------
		If ::GetParam("MV_NGPSATI", "N") == "S" .And. !lDevice .And. isPending()
			cError := STR0019 // "Para abrir uma nova Solicitação de Serviço, você deverá responder as pesquisas de satisfação pendentes."
		EndIf

	ElseIf ::IsUpdate() .And. !::IsCreateSO() .And. !::IsAnswer()

		// 3.3 - O campo Contador (TQB_POSCON) deve estar preenchido com um valor válido quando informado.
		If Empty(cError) .And. nCount1 != nCounter1
			cError := STR0020 // "Não é possível alterar o contador."
		EndIf

		If Empty(cError) .And. nCount2 != nCounter2
			cError := STR0020 // "Não é possível alterar o contador."
		EndIf

		If ::IsAnalysis() // Alteração de SS com status "Aguardando Análise"

			If ::HasSO(cSolici)

				cError := STR0021 // "Não é possível alterar esta S.S. pois ela já possui Ordem de Serviço."

			EndIf

			// 3.1 - O campo Serviço (TQB_DESCSS) deve estar preenchido.
			If Empty(cError) .And. Empty(cDescSR)
				cError := ::MsgRequired('TQB_DESCSS') // O campo não foi preenchido.
			EndIf

			// 3.2 - O campo Tipo Servico (TQB_CDSERV) precisa ser válido.
			If Empty(cError) .And.  !Empty(cServCode)
				cError := fValServ(cServCode)
			EndIf

		ElseIf ::IsAssigned() // Distribuição de S.S.

			If cSRStatus != "D" // Distribuição de S.S.
				//------------------------------------------------------------------------
				// 5 - Validações do processo de Distribuição de Solicitação de Serviço
				//------------------------------------------------------------------------

				// 5.1 - O campo Executante (TQB_CDEXEC) deve ser preenchido.
				If Empty(cError) 
					If Empty(cExecCode)
						cError := ::MsgRequired('TQB_CDEXEC') // O campo não foi preenchido.
					ElseIf ::GetParam( 'MV_NG1FAC', .F., '2') == '2' .And. !NGIFDBSEEK( 'TQ4', cExecCode, 1, .F. )
						cError := STR0083 // 'Código do executante informado não é válido!'
					ElseIf ::GetParam( 'MV_NG1FAC', .F., '2') == '1' .And.  ( !NGIFDBSEEK( 'ST1', cExecCode, 1, .F. ) .Or. ST1->T1_TIPATE == '1' ) 
						cError := STR0083 // 'Código do executante informado não é válido!'
					EndIf
				EndIf
				
				// 5.2 - O campo Tipo Serviço (TQB_CDSERV) deve ser preenchido.
				If Empty(cError)
					If Empty(cServCode)
						cError := ::MsgRequired('TQB_CDSERV') // O campo não foi preenchido.
					ElseIf !NGIFDBSEEK( 'TQ3', cServCode, 1, .F. )
						cError := STR0084 // 'Serviço informado não é válido!'
					EndIf

				// 5.3 - O campo Prioridade (TQB_PRIORI) deve ser preenchido.
				ElseIf Empty(cError) .And. Empty(cPriority) .And.  X3Obrigat('TQB_PRIORI')
					cError := ::MsgRequired('TQB_PRIORI') // O campo não foi preenchido.
				EndIf

				// 5.3.1 - O campo Serviço (TQB_DESCSS) deve estar preenchido
				If Empty(cError) .And. Empty(cDescSR)
					cError := ::MsgRequired('TQB_DESCSS') // O campo não foi preenchido.
				EndIf

				If Empty(cError)

					// 5.4 - Não é possível distribuir solicitações de serviço com status diferente de Aguardando Análise (TQB_SOLUCA <> A).
					If cSRStatus != "A"
						cError := STR0022 // "Não é possível distribuir esta Solicitação de Serviço pois ela já foi distribuída."

					// 5.5 - Não é possível distribuir solicitações de serviço caso elas já possuam ordens de serviço relacionadas.
					ElseIf ::GetParam("MV_NGMULOS", "N") == "S"
						If !Empty(Alltrim(cOrder))
							cError := STR0023 // "Não é possível distribuir esta Solicitação de Serviço pois ela já possui Ordem de Serviço."
						EndIf
					EndIf

				EndIf

				//Ponto de Entrada para validar campos preenchidos ou não após distribuição da SS.
				If ExistBlock("MNTA295A")
					If !ExecBlock( "MNTA295A", .F., .F. ) //Se o Retorno do PE for falso.
						cError := STR0024 // "A validação adicionada no ponto de entrada MNTA295A está impossibilitando a continuidade do processo."
					EndIf
				EndIf

			EndIf

		ElseIf ::IsClosed() // Fechamento de S.S.

			//|------------------------------------------------------------------------
			//| 7 - Validações do processo de Fechamento de Solicitação de Serviço
			//|------------------------------------------------------------------------
			If cSRStatus != "E" // Fechamento de S.S.

				// 7.1 - Não é permitido fechar solicitações de serviço não distribuídas.
				If cSRStatus != "D"
					cError = STR0025 // "Não é possível fechar esta solicitação, pois ela ainda não foi distribuída."
				EndIf

				// 7.2 - Não é possível fechar uma S.S. que possua Ordem de Serviço em aberto.
				If Empty(cError) .And. ::HasSO(cSolici)
					cError := STR0026 // "Não é possível fechar esta S.S. pois ela ainda possui Ordem de Serviço aberta."
				EndIf

				If !Empty(cDateCl)
					// 7.3 - Se preenchido, campo TQB_DTFECH não pode ser maior que a data atual.
					If Empty(cError) .And. cDateCl > dDataBase
						cError := STR0027 // "A data de fechamento não pode ser maior que a data atual."
					EndIf

					// 7.4 - Se preenchido, campo TQB_DTFECH não pode ser menor que a data de abertura da S.S.
					If Empty(cError) .And. cDateCl < cDateOp
						cError := STR0028 // "A data de fechamento não pode ser menor que a data de abertura."
					EndIf

				EndIf

				If !Empty(cHourCl)

					If Empty(cDateCl)
						cError := ::MsgRequired('TQB_DTFECH') // O campo não foi preenchido.
					EndIf

					// 7.5 - Se preenchido, campo TQB_HOFECH não pode ser maior que a hora atual.
					If Empty(cError) .And. (cDateCl == dDataBase .And. cHourCl > SubStr(Time(),1,5))
						cError := STR0029 // "A hora de fechamento não pode ser maior que a hora atual."
					EndIf

					// 7.6 - Se preenchido, campo TQB_HOFECH deve ser maior que a hora de abertura da S.S.
					If Empty(cError) .And. (cDateCl == cDateOp .And. cHourCl <= cHourOp)
						cError := STR0010 + Alltrim(Posicione("SX3",2,"TQB_HOFECH","X3Titulo()")) + STR0030 // "O campo " #### " deve ser maior que a hora de abertura da S.S."
					EndIf

				EndIf

				// 7.7 - Campo TQB_TEMPO precisa ser maior que zero
				If Empty(cError) .And. (Empty(cTime) .Or. Val(AllTrim(StrTran(cTime,":",""))) == 0)
					cError := ::MsgRequired('TQB_TEMPO') // O campo não foi preenchido.
				EndIf

				// Ponto de Entrada MNTA2908 - Validação de campos não vazios
				If Empty(cError)
					If ExistBlock("MNTA2908")
						aEntryPt := ExecBlock("MNTA2908",.F.,.F.)
						If Len(aEntryPt) > 0
							For nX := 1 To Len(aEntryPt)
								If Empty(::GetValue(aEntryPt[nX,1])) .And. Empty(cError)
									cError := aEntryPt[nX,2]
								EndIf
							Next nX
						EndIf
					EndIf
				EndIf
			EndIf

		EndIf

		// 7.8 - Não é possível alterar o contador se a SS não estiver com status "Aguardando Análise"
		If !::IsAnalysis()

			If Empty(cError) .And. nCount1 != nCounter1
				cError := STR0020 // "Não é possível alterar o contador."
			EndIf

			If Empty(cError) .And. nCount2 != nCounter2
				cError := STR0020 // "Não é possível alterar o contador."
			EndIf

		EndIf

	ElseIf ::IsDelete()

		//------------------------------------------------------------------------
		// 4. Validações do processo de Exclusão de Solicitação de Serviço
		//------------------------------------------------------------------------

		// 4.1 - Ponto de Entrada MNTA280E - Não permite excluir S.S se o usuário de deleção for diferente do usuário que incluiu a S.S.
		If ExistBlock( "MNTA280E" )
			If !ExecBlock( "MNTA280E", .F., .F. )
				cError := STR0031 // "O usuário é diferente do que realizou a abertura da solicitação de serviço."
			EndIf
		Else
			// 4.2 - Deleção permitida apenas para o solicitante da S.S. ou usuário pertencente ao grupo de administradores.
			If AllTrim(cCodeReq) != AllTrim(cUserName) .And. !FwIsAdmin() //Verifica se o usuario e mesmo que abriu a SS ou se e administrador
				cError := STR0032 // "Deleção permitida apenas para o Solicitante da S.S. ou um usuário do grupo de Administradores."
			EndIf
		EndIf

		// 4.3 - Não é permitido a exclusão de solicitações de serviço já distribuídas.
		If Empty(cError) .And. cSolution != "A"
			cError := STR0033 // "Operação não permitida. A S.S. já foi distribuída."
		EndIf

		// 4.4 - Não é permitido a exclusão de solicitações de serviço que já possuam Ordem de Serviço relacionada.
		If Empty(cError) .And. ::HasSO(cSolici)
			cError := STR0034 // "Não é possível deletar esta S.S. pois ela já possui Ordem de Serviço."
		EndIf

	ElseIf ::IsCreateSO() // Verifica se é chamado pela Geração de OS.

		//------------------------------------------------------------------------
		// 6 - Validações do processo de Geração de Ordem de Serviço
		//------------------------------------------------------------------------

		// 6.1 - Verifica se a solicitação de serviço já foi distribuida.
		If Empty(cError) .And. !::IsAssigned()
			cError := STR0035 // "O Solicitação de Serviço não está distribuída."
		EndIf

		// 6.2 - Verifica se a Solicitação de Serviço possui Ordens de Serviço.
		If ::HasSO(cSolici) .And. ::GetParam("MV_NGMULOS", "N") == "N"
			cError := STR0036 // "Já foi gerada Ordem de Serviço para a Solicitação."
		EndIf

		nRecord := Len(::aFieldSO) // Verifica se existe algum registro para geração de OS.

		If Empty(cError) .And. nRecord > 0

			nAsset   := aScan( ::aFieldSO[nRecord,__AFIELDSO_SO__], {|x| AllTrim( Upper( X[1] ) ) == 'TJ_CODBEM' }  )
			nDateIn  := aScan( ::aFieldSO[nRecord,__AFIELDSO_SO__], {|x| AllTrim( Upper( X[1] ) ) == 'TJ_DTORIGI' } )
			nHourCt1 := aScan( ::aFieldSO[nRecord,__AFIELDSO_SO__], {|x| AllTrim( Upper( X[1] ) ) == 'TJ_HORACO1' } )
			nHourCt2 := aScan( ::aFieldSO[nRecord,__AFIELDSO_SO__], {|x| AllTrim( Upper( X[1] ) ) == 'TJ_HORACO2' } )

			For nInd := 1 To Len(::aFieldSO[nRecord, __AFIELDSO_SO__])

				// 6.3 - Validações do campo "Bem"
				If ::aFieldSO[nRecord,__AFIELDSO_SO__,nInd,1] == "TJ_CODBEM"
					If Empty(cError) .And. Empty(::aFieldSO[nRecord,__AFIELDSO_SO__,nInd,2])
						cError := ::MsgRequired(::aFieldSO[nRecord,__AFIELDSO_SO__,nInd,1]) // O campo não foi preenchido.
					EndIf

				// 6.4 - Validações do campo "Serviço"
				ElseIf ::aFieldSO[nRecord,__AFIELDSO_SO__,nInd,1] == "TJ_SERVICO"
					If Empty(cError) .And. Empty(::aFieldSO[nRecord,__AFIELDSO_SO__,nInd,2])
						cError := ::MsgRequired(::aFieldSO[nRecord,__AFIELDSO_SO__,nInd,1]) // O campo não foi preenchido.
					EndIf
					// 6.4.1 - Caso serviço da Solicitação de Serviço seja Reforma ou Conserto de Pneus,
					//  não será permitido fazer pela rotina, mas apenas pela rotina de O.S. Em Lote.
					If ::GetParam("MV_NGMNTFR", "N") == "S" //Efetua a validação somente se for Frota
						If (!Empty(::aFieldSO[nRecord,__AFIELDSO_SO__,nInd,2]) .And. !Empty(::GetParam("MV_NGSEREF", "")) .And.;
							Alltrim(::aFieldSO[nRecord,__AFIELDSO_SO__,nInd,2]) == Alltrim(::GetParam("MV_NGSEREF", ""))) .Or.;
							(!Empty(::aFieldSO[nRecord,__AFIELDSO_SO__,nInd,2]) .And. !Empty(::GetParam("MV_NGSECON", "")) .And.;
							Alltrim(::aFieldSO[nRecord,__AFIELDSO_SO__,nInd,2]) == Alltrim(::GetParam("MV_NGSECON", "")))
							cError := STR0037 // "Para abertura e finalização de O.S. com o serviço de Reforma ou Conserto de Pneus, "
							cError += STR0038 // "conforme definido nos parâmetros MV_NGSEREF e MV_NGSECON, deve ser utilizada a rotina de O.S. Em Lote."
						EndIf
					EndIf
					// 6.4.2 - O serviço informado, presente na tabela ST4, deve ser do tipo Corretivo, caso o parametro MV_NGSSPRE for diferente de "S".
					If AllTrim(::GetParam("MV_NGSSPRE", "")) == "N"
						aRet := NGTIPSER(::aFieldSO[nRecord,__AFIELDSO_SO__,nInd,2],"C",.F.)
						If !aRet[1]
							If aRet[2] == 'SERVNAOEXI'
								cError := STR0039 // 'O serviço informado não existe.'
							ElseIf aRet[2] == 'REGBLOQ' // 6.4.3 - O serviço informado, presente na tabela ST4, não pode estar bloqueado para uso (T4_MSBLQL = 1).
								cError := STR0040 // 'Entre em contato com o administrador do sistema ou o responsável pelo registro para identificar o motivo do bloqueio.'
							ElseIf aRet[2] == 'TPSERVNEXI'
								cError := STR0041 // 'Informe um servico do tipo Corretivo.'
							ElseIf aRet[2] == 'SERVNAOCOR'
								cError := STR0042 // 'Serviço informado não é do tipo Corretivo.'
							ElseIf aRet[2] == 'NSERVPREVE'
								cError := STR0043 // 'Para esta opção informar um servico do  tipo preventivo.'
							EndIf
						EndIf
					Else
						aOldArea := GetArea()
						dbSelectArea("ST4")
						dbSetOrder(1)
						If !dbSeek(xFilial("ST4")+::aFieldSO[nRecord,__AFIELDSO_SO__,nInd,2])
							cError := STR0010 + Alltrim(Posicione("SX3",2,::aFieldSO[nRecord,__AFIELDSO_SO__,nInd,1],"X3Titulo()")) + STR0044 // "O campo " #### " deve ser preenchido corretamente."
							RestArea(aOldArea)
						Else
							If !NGSERVBLOQ(::aFieldSO[nRecord,__AFIELDSO_SO__,nInd,2],.F.)[1] // 6.4.3 - O serviço informado, presente na tabela ST4, não pode estar bloqueado para uso (T4_MSBLQL = 1).
								cError := STR0045 // "Este registro está bloqueado para uso."
							EndIf
						EndIf
						RestArea(aOldArea)
					EndIf

				// 6.5 - Validações do campo "Dt. Original"
				ElseIf ::aFieldSO[nRecord,__AFIELDSO_SO__,nInd,1] == "TJ_DTORIGI"
					If Empty(cError) .And. Empty(::aFieldSO[nRecord,__AFIELDSO_SO__,nInd,2])
						cError := ::MsgRequired(::aFieldSO[nRecord,__AFIELDSO_SO__,nInd,1]) // O campo não foi preenchido.
					EndIf
					// 6.5.1 - O campo Data Original (TJ_DTORIGI) não pode ser menor que a Data e Hora de abertura da S.S.
					If ::aFieldSO[nRecord,__AFIELDSO_SO__,nInd,2] < ::GetValue("TQB_DTABER")
						cError := STR0010 + Alltrim(Posicione("SX3",2,::aFieldSO[nRecord,__AFIELDSO_SO__,nInd,1],"X3Titulo()")) + STR0046 // "O campo " #### " deve conter um valor maior ou igual a data de abertura."
					EndIf

				// 6.6 - Validações do campo "Contador" - primeiro contador
				ElseIf ::aFieldSO[nRecord,__AFIELDSO_SO__,nInd,1] == "TJ_POSCONT"

					If Empty(cError) .And. ::aFieldSO[nRecord,__AFIELDSO_SO__,nInd,2] != 0

						aRet := fValCnt( ::aFieldSO[nRecord,__AFIELDSO_SO__,nAsset,2], ::aFieldSO[nRecord,__AFIELDSO_SO__,nDateIn,2],;
						::aFieldSO[nRecord,__AFIELDSO_SO__,nHourCt1,2], ::aFieldSO[nRecord,__AFIELDSO_SO__,nInd,2], 1, lGetAsk )

						If !Empty( aRet[2] )

							If aRet[1]
								::AddAsk( aRet[2] )
							Else
								cError := aRet[2]
							EndIf

						EndIf

					EndIf

				// 6.7 - Validações do campo "Contador 2"
				ElseIf ::aFieldSO[nRecord,__AFIELDSO_SO__,nInd,1] == "TJ_POSCON2"

					If Empty(cError) .And. ::aFieldSO[nRecord,__AFIELDSO_SO__,nInd,2] != 0

						aRet := fValCnt( ::aFieldSO[nRecord,__AFIELDSO_SO__,nAsset,2], ::aFieldSO[nRecord,__AFIELDSO_SO__,nDateIn,2],;
						::aFieldSO[nRecord,__AFIELDSO_SO__,nHourCt2,2], ::aFieldSO[nRecord,__AFIELDSO_SO__,nInd,2], 2, lGetAsk )

						If !Empty( aRet[2] )

							If aRet[1]
								::AddAsk( aRet[2] )
							Else
								cError := aRet[2]
							EndIf

						EndIf

					EndIf

				// 6.8 - Validações do campo "Hora cont. 1"
				ElseIf ::aFieldSO[nRecord,__AFIELDSO_SO__,nInd,1] == "TJ_HORACO1"
					
					// 6.8.1 - Valor informado deve ser uma hora valida.
					If Empty(cError) .And. !Empty(::aFieldSO[nRecord,__AFIELDSO_SO__,nInd,2]) .And. !NGVALHORA(::aFieldSO[nRecord,__AFIELDSO_SO__,nInd,2],.F.)
						cError := STR0010 + Alltrim(Posicione("SX3",2,::aFieldSO[nRecord,__AFIELDSO_SO__,nInd,1],"X3Titulo()")) + STR0013 // "O campo " #### " deve ser válido."
					EndIf

					// 6.8.2 - Valor informado não deve ser superior a hora atual do sistema.
					If Empty( cError ) .And. ( DToS( ::aFieldSO[nRecord,__AFIELDSO_SO__,nDateIn,2] ) + ::aFieldSO[nRecord,__AFIELDSO_SO__,nInd,2] ) > ( cDateSys + cHourSys )
						
						// A hora de leitura do contador 1: XX:XX não deve ser maior que a hora atual do sistema: XX:XX
						cError := STR0081 + '1: ' + ::aFieldSO[nRecord,__AFIELDSO_SO__,nInd,2] + STR0082 + cHourSys

					EndIf

				// 6.9 - Validações do campo "Hora cont. 2"
				ElseIf ::aFieldSO[nRecord,__AFIELDSO_SO__,nInd,1] == "TJ_HORACO2"
					
					// 6.9.1 - Valor informado deve ser uma hora valida.
					If Empty(cError) .And. !Empty(::aFieldSO[nRecord,__AFIELDSO_SO__,nInd,2]) .And. !NGVALHORA(::aFieldSO[nRecord,__AFIELDSO_SO__,nInd,2],.F.)
						cError := STR0010 + Alltrim(Posicione("SX3",2,::aFieldSO[nRecord,__AFIELDSO_SO__,nInd,1],"X3Titulo()")) + STR0013 // "O campo " #### " deve ser válido."
					EndIf

					// 6.9.2 - Valor informado não deve ser superior a hora atual do sistema.
					If Empty( cError ) .And. ( DToS( ::aFieldSO[nRecord,__AFIELDSO_SO__,nDateIn,2] ) + ::aFieldSO[nRecord,__AFIELDSO_SO__,nInd,2] ) > ( cDateSys + cHourSys )
						
						// A hora de leitura do contador 2: XX:XX não deve ser maior que a hora atual do sistema: XX:XX
						cError := STR0081 + '2: ' + ::aFieldSO[nRecord,__AFIELDSO_SO__,nInd,2] + STR0082 + cHourSys

					EndIf

				// 6.10 - Validações do campo "Centro Custo"
				ElseIf ::aFieldSO[nRecord,__AFIELDSO_SO__,nInd,1] == "TJ_CCUSTO"
					If Empty(cError) .And. Empty(::aFieldSO[nRecord,__AFIELDSO_SO__,nInd,2])
						cError := ::MsgRequired(::aFieldSO[nRecord,__AFIELDSO_SO__,nInd,1]) // O campo não foi preenchido.
					EndIf
					If Empty(cError) .And. Alltrim(Posicione(cCostTable,1,xFilial(cCostTable) + ::aFieldSO[nRecord,__AFIELDSO_SO__,nInd,2],cCostField)) != Alltrim(::aFieldSO[nRecord,__AFIELDSO_SO__,nInd,2])
						cError := STR0010 + Alltrim(Posicione("SX3",2,::aFieldSO[nRecord,__AFIELDSO_SO__,nInd,1],"X3Titulo()")) + STR0047 // "O campo " #### " está inválido."
					EndIf

				// 6.11 - Validações do campo "Centro Trab."
				ElseIf ::aFieldSO[nRecord,__AFIELDSO_SO__,nInd,1] == "TJ_CENTRAB"
					If Empty(cError)
						nCost := aScan(::aFieldSO[nRecord,__AFIELDSO_SO__],{|x| AllTrim(Upper(X[1])) == "TJ_CCUSTO" })
						dbSelectArea("SHB")
						dbSetOrder(01) //HB_FILIAL+HB_COD
						If dbSeek(xFilial("SHB") + ::aFieldSO[nRecord,__AFIELDSO_SO__,nInd,2])
							If AllTrim( SHB->HB_CC ) <> AllTrim( ::aFieldSO[nRecord,__AFIELDSO_SO__,nCost,2] )
								cError := STR0010 + Alltrim(Posicione("SX3",2,::aFieldSO[nRecord,__AFIELDSO_SO__,nInd,1],"X3Titulo()")) + STR0047 // "O campo " #### " está inválido."
							EndIf
						EndIf
					EndIf
				EndIf

				If !Empty(cError)
					Exit
				EndIf

			Next nInd

			// 6.13.2 - Validações de Ordem de Serviço Preventiva
			If Empty(cError) .And. ::isPreventive(nRecord) .And. AllTrim(::GetParam("MV_NGSSPRE", "")) == "S"
				For nInd := 1 To Len(::aFieldSO)

					// Busca a posição dos campos.
					nService := aScan(::aFieldSO[nRecord, __AFIELDSO_SO__],{|x| AllTrim(Upper(X[1])) == "TJ_SERVICO"})
					nSitua   := aScan(::aFieldSO[nRecord, __AFIELDSO_SO__],{|x| AllTrim(Upper(X[1])) == "TJ_SITUACA"})
					nSeque   := aScan(::aFieldSO[nRecord, __AFIELDSO_SO__],{|x| AllTrim(Upper(X[1])) == "TJ_SEQRELA"})

					dDateIn  := ::aFieldSO[nRecord,__AFIELDSO_SO__,nDateIn,2]
					cAssetSO := ::aFieldSO[nRecord,__AFIELDSO_SO__,nAsset,2]
					cService := ::aFieldSO[nRecord,__AFIELDSO_SO__,nService,2]
					cSeque   := ::aFieldSO[nRecord,__AFIELDSO_SO__,nSeque,2]

					dbSelectArea("ST4")
					dbSetOrder(1)
					If dbSeek(cFil2ST4+cService)
						dbSelectArea("STE")
						dbSetOrder(1)
						If dbSeek(cFil2STE+ST4->T4_TIPOMAN) .And. STE->TE_CARACTE != 'P'
							cError := STR0078 // "Tipo de serviço deverá ser preventivo."
						EndIf
					EndIf

					If Empty(cError)
						dbSelectArea("STF")
						dbSetOrder(1)
						If !dbSeek(cFil2STF+cAssetSO+cService+cSeque)
							cError := STR0079 // "Sequência da manutenção não cadastrada."
						EndIf
					EndIf

					If Empty(cError)
						cError := NGPREVBSS("B",cAssetSO,cService,dDateIn,cSeque,.F.) // verifica se ja tem O.S pra data
					EndIf

					If !Empty(cError)
						Exit
					EndIf
				Next nInd
			EndIf

			// Validação de Insumos da OS.
			If Empty(cError) .And. ::HasInput(nRecord)

				For nX := 1 To Len(::aFieldSO[nRecord, __AFIELDSO_INPUT__])

					nTask    := aScan(::aFieldSO[nRecord, __AFIELDSO_INPUT__, nX],{|x| AllTrim(Upper(X[1])) == "TL_TAREFA"})
					nRegType := aScan(::aFieldSO[nRecord, __AFIELDSO_INPUT__, nX],{|x| AllTrim(Upper(X[1])) == "TL_TIPOREG"})
					nTlCode  := aScan(::aFieldSO[nRecord, __AFIELDSO_INPUT__, nX],{|x| AllTrim(Upper(X[1])) == "TL_CODIGO"})
					nQuant   := aScan(::aFieldSO[nRecord, __AFIELDSO_INPUT__, nX],{|x| AllTrim(Upper(X[1])) == "TL_QUANTID"})
					nResQt   := aScan(::aFieldSO[nRecord, __AFIELDSO_INPUT__, nX],{|x| AllTrim(Upper(X[1])) == "TL_QUANREC"})
					nUse     := aScan(::aFieldSO[nRecord, __AFIELDSO_INPUT__, nX],{|x| AllTrim(Upper(X[1])) == "TL_DESTINO"})
					nLocal   := aScan(::aFieldSO[nRecord, __AFIELDSO_INPUT__, nX],{|x| AllTrim(Upper(X[1])) == "TL_LOCAL"})
					nUnity   := aScan(::aFieldSO[nRecord, __AFIELDSO_INPUT__, nX],{|x| AllTrim(Upper(X[1])) == "TL_UNIDADE"})
					cInput   := ::aFieldSO[nRecord,__AFIELDSO_INPUT__,nX,nRegType,2] // Tipo do insumo

					If ::GetParam("MV_NGTARGE", "2") == "1" .And. ::isCorrective(nRecord) // TODO: Tratar o caso de tarefa generica no upsert da OS

						// 6.14 - Na previsão de insumos, o campo Tarefa (TL_TAREFA) deve ser preenchido.
						If Empty(cError) .And. Empty(::aFieldSO[nRecord,__AFIELDSO_INPUT__,nX,nTask,2])
							cError := STR0010 + Alltrim(Posicione("SX3",2,::aFieldSO[nRecord,__AFIELDSO_INPUT__,nX,nTask,1],"X3Titulo()")) + STR0050 // "O campo " #### STR0020
						EndIf

						// 6.15 - O código da tarefa deve ser um valor válido.
						If Empty(cError) .And. !NGIFDBSEEK("TT9", ::aFieldSO[nRecord,__AFIELDSO_INPUT__,nX,nTask,2], 1)
							cError := STR0051 // 'O Código da tarefa não foi encontrado na tabela "TT9 - Tarefas Genéricas".'
						EndIf

					EndIf

					//------------------------------------------------------------------------
					// 8.2 - Se OS for Preventiva, a Tarefa deve estar preenchida com um
					// código existente na tabela ST5 - Tarefas da Manutenção.
					//------------------------------------------------------------------------
					If Empty(cError) .And. ::isPreventive(nRecord) .And. AllTrim(::aFieldSO[nRecord,__AFIELDSO_INPUT__,nX,nTask,2]) <> "0" .And.;
					   !NGIFDBSEEK("ST5", ::aFieldSO[nRecord,__AFIELDSO_INPUT__,nX,nTask,2], 5)
						cError := STR0052 // "O Campo tarefa não existe ou pertence à tabela 'ST5 - Tarefas da Manutenção'"
					EndIf

					//------------------------------------------------------------------------
					// 6.16 -Campo TL_TIPOREG é obrigatório
					//------------------------------------------------------------------------
					If Empty(cError) .And. Empty(cInput)
						cError := STR0010 + Alltrim(Posicione("SX3",2,::aFieldSO[nRecord,__AFIELDSO_INPUT__,nX,nRegType,1],"X3Titulo()")) + STR0050 // "O campo " #### " é obrigatório."
					EndIf

					//------------------------------------------------------------------------
					// 6.17 - Código de Tipo de Insumo deve ser preenchido corretamente.
					//------------------------------------------------------------------------
					If Empty(cError) .And. !(cInput $ "F/M/P/T/E")
						cError := STR0053 + CRLF // "O Código do Tipo de insumo deve ser preenchido corretamente com: "
						cError += STR0054 + CRLF // "P – Produto"
						cError += STR0055 + CRLF // "M – Funcionário (Mão de Obra)"
						cError += STR0056 + CRLF // "F – Ferramenta"
						cError += STR0057 + CRLF // "T – Terceiros"
						cError += STR0058 // "E – Especialidade."
						::addError(cError)
					EndIf

					//------------------------------------------------------------------------
					// 8.5 -Quando informado Ferramenta ou Especialidade, Quantidade de Recurso deve ser informado
					//------------------------------------------------------------------------
					If Empty(cError) .And. (cInput == "F" .Or. cInput == "E") .And. Empty(::aFieldSO[nRecord,__AFIELDSO_INPUT__,nX,nResQt,2])
						cError := STR0010 + Alltrim(Posicione("SX3",2,::aFieldSO[nRecord,__AFIELDSO_INPUT__,nX,nResQt,1],"X3Titulo()")) +; // "O campo " ####
						          STR0059 // " é obrigatório para insumos do tipo Ferramenta e Especialidade."
					EndIf

					//------------------------------------------------------------------------
					// 6.18 -Campo TL_CODIGO é obrigatório
					//------------------------------------------------------------------------
					If Empty(cError) .And. Empty(::aFieldSO[nRecord,__AFIELDSO_INPUT__,nX,nTlCode,2])
						cError := STR0010 + Alltrim(Posicione("SX3",2,::aFieldSO[nRecord,__AFIELDSO_INPUT__,nX,nTlCode,1],"X3Titulo()")) + STR0050 // "O campo " #### " é obrigatório."
					EndIf

					//------------------------------------------------------------------------
					// 8.7 - Campo TL_QUANTID é obrigatório e precisa ser maior que zero
					//------------------------------------------------------------------------
					If Empty(cError) .And. (Empty(::aFieldSO[nRecord,__AFIELDSO_INPUT__,nX,nQuant,2]) .Or. ::aFieldSO[nRecord,__AFIELDSO_INPUT__,nX,nQuant,2] <= 0)
						cError := STR0010 + Alltrim(Posicione("SX3",2,::aFieldSO[nRecord,__AFIELDSO_INPUT__,nX,nQuant,1],"X3Titulo()")) + STR0050 // "O campo " #### " é obrigatório."
					EndIf

					//------------------------------------------------------------------------
					// 6.19 - Se insumo for Ferramenta, código deve existir na tabela SH4
					//------------------------------------------------------------------------
					If Empty(cError) .And. cInput == "F" .And. !NGIFDBSEEK("SH4", ::aFieldSO[nRecord,__AFIELDSO_INPUT__,nX,nTlCode,2], 1)
						cError := STR0060 // 'Código do insumo não encontrado na tabela "SH4 - Ferramentas".'
					EndIf

					//------------------------------------------------------------------------
					// 8.9 - Quando informado Produto, o campo Destino deve ser informado
					//------------------------------------------------------------------------
					If Empty(cError) .And. cInput == "P" .And. Empty(::aFieldSO[nRecord,__AFIELDSO_INPUT__,nX,nUse,2])
						cError := STR0010 + Alltrim(Posicione("SX3",2,::aFieldSO[nRecord,__AFIELDSO_INPUT__,nX,nUse,1],"X3Titulo()")) + STR0050 // "O campo " #### " é obrigatório."
					EndIf

					//------------------------------------------------------------------------
					// 8.10 - Quando informado Terceiro, campo Almoxarifado deve ser informado
					//------------------------------------------------------------------------
					If Empty(cError) .And. ::isThird(nRecord) .And. Empty(::aFieldSO[nRecord,__AFIELDSO_INPUT__,nX,nLocal,2])
						cError := STR0010 + Alltrim(Posicione("SX3",2,::aFieldSO[nRecord,__AFIELDSO_INPUT__,nX,nLocal,1],"X3Titulo()")) + STR0050 // "O campo " #### " é obrigatório."
					EndIf

					//+------------------------------------------------------------------
					// 8.11. - Se insumo for Ferramenta, unidade de consumo do insumo deve ser "H- Horas"
					//+------------------------------------------------------------------
					If Empty(cError) .And. cInput == "F" .And. AllTrim(::aFieldSO[nRecord,__AFIELDSO_INPUT__,nX,nUnity,2]) != "H"
						cError := STR0061 // "Unidade 'Consumo' deve ser como 'H- Horas' para o uso de insumo tipo 'F- Ferramenta'."
						::addError(cError)
					EndIf

					If !Empty(cError)
						Exit
					EndIf

				Next nX

			EndIf

			// Validação de Etapas da OS
			If Empty(cError) .And. ::HasStep(nRecord)

				For nX := 1 To Len(::aFieldSO[nRecord, __AFIELDSO_STEP__])

					nStepTask := aScan(::aFieldSO[nRecord, __AFIELDSO_STEP__,nX],{|x| AllTrim(Upper(X[1])) == "TQ_TAREFA"})
					nstep     := aScan(::aFieldSO[nRecord, __AFIELDSO_STEP__,nX],{|x| AllTrim(Upper(X[1])) == "TQ_ETAPA"})

					//------------------------------------------------------------------------
					// 8.11 - Campo TQ_TAREFA é obrigatório
					//------------------------------------------------------------------------
					If Empty(cError) .And. Empty(::aFieldSO[nRecord,__AFIELDSO_STEP__,nX,nStepTask,2])
						cError := STR0010 + Alltrim(Posicione("SX3",2,::aFieldSO[nRecord,__AFIELDSO_STEP__,nX,nStepTask,1],"X3Titulo()")) + STR0050 // "O campo " #### " é obrigatório."
					EndIf

					//------------------------------------------------------------------------
					// 8.12 - Campo TQ_ETAPA é obrigatório
					//------------------------------------------------------------------------
					If Empty(cError) .And. Empty(::aFieldSO[nRecord,__AFIELDSO_STEP__,nX,nstep,2])
						cError := STR0010 + Alltrim(Posicione("SX3",2,::aFieldSO[nRecord,__AFIELDSO_STEP__,nX,nstep,1],"X3Titulo()")) + STR0050 // "O campo " #### " é obrigatório."
					EndIf

					//------------------------------------------------------------------------
					// 8.13 - O código da tarefa deve existir na tabela TT9 - Tarefas Genéricas.
					//------------------------------------------------------------------------
					If Empty(cError) .And. (::isCorrective(nRecord) .And. ::GetParam("MV_NGTARGE", "2") == "1") .And.;
					   !NGIFDBSEEK("TT9", ::aFieldSO[nRecord,__AFIELDSO_STEP__,nX,nStepTask,2], 1)
						cError := STR0062 // "O Código da tarefa não existe ou não pertence à tabela TT9 - Tarefas Genéricas"
					EndIf

					//------------------------------------------------------------------------
					// 8.14 - O código da Etapa deve existir na tabela TPA - Etapas Genéricas.
					//------------------------------------------------------------------------
					If Empty(cError) .And. !NGIFDBSEEK("TPA", ::aFieldSO[nRecord,__AFIELDSO_STEP__,nX,nstep,2], 1)
						cError := STR0063 // "O Código da Etapa não existe ou pertence à tabela TPA - Etapas Genéricas"
					EndIf

					//------------------------------------------------------------------------
					// 8.15 - Se OS for Preventiva, a Tarefa deve estar preenchida
					// com um código existente na tabela ST5 - Tarefas da Manutenção.
					//------------------------------------------------------------------------
					If Empty(cError) .And. ::isPreventive(nRecord) .And. Alltrim(::aFieldSO[nRecord,__AFIELDSO_STEP__,nX,nStepTask,2]) <> "0" .And.;
					   !NGIFDBSEEK("ST5", ::aFieldSO[nRecord,__AFIELDSO_STEP__,nX,nStepTask,2], 5)
						cError := STR0064 // "O Campo tarefa não existe ou pertence à tabela ST5 - Tarefas da Manutenção"
					EndIf

					If !Empty(cError)
						Exit
					EndIf

				Next nX

			EndIf

			// Ponto de entrada que permite adicionar validações na geração de OS
			If Empty( cError ) .And. ( ExistBlock( 'MNTA2953' ) .And. !ExecBlock( 'MNTA2953', .F., .F. ) )

				cError := STR0080 // A validação adicionada no ponto de entrada MNTA295A está impossibilitando a continuidade do processo.

			EndIf

		EndIf

		If Empty(cError) //Caso não encontre problemas na validação.
			::SetValid(.T.)
		EndIf

	ElseIf ::IsAnswer() // Caso seja Resposta Questionário de Satisfação.

		//-------------------------------------------------------------------
		// 8 - Validações do processo de Questionário de Satisfação de S.S.
		//-------------------------------------------------------------------

		// 8.1 - Verificar se o campo Atend. Prazo(TQB_PSAP) foi preenchido.
		If Empty(cError) .And. Empty(cDeadL)
			cError := ::MsgRequired('TQB_PSAP') // O campo não foi preenchido.
		EndIf

		// 8.2 - Verificar se o campo Atend. Neces(TQB_PSAN) foi preenchido.
		If Empty(cError) .And. Empty(cNeed)
			cError := ::MsgRequired('TQB_PSAN') // O campo não foi preenchido.
		EndIf

		// 8.3 - Verifica se a S.S está como E - Encerrada.
		If Empty(cError) .And. !Empty(cSolution) .And. cSolution <> 'E'
			cError := STR0010 + Alltrim(Posicione("SX3",2,"TQB_SOLUCA","X3Titulo()")) + STR0065 // "O campo " #### " deve estar como E - Encerrada."
		EndIf

		// 8.4 - Verifica se o Questionário de Satisfação já foi Respondido.
		If Empty(cError) .And. !Empty(cSolici)
			If !Empty(Posicione("TQB",1,cBranch+cSolici,"TQB_PSAP")) .And.;
				!Empty(Posicione("TQB",1,cBranch+cSolici,"TQB_PSAN"))
				cError := STR0066 // "O Questionário de Satisfação já foi Respondido."
			EndIf
		EndIf

		// 8.5 - Verifica se o Serviço da S.S. possui questionário de Satisfação.
		If Empty(cError) .And. !Empty(cServCode)
			If Posicione("TQ3",1,cBranch+cServCode,"TQ3_PESQST") == "2"
				cError := STR0067 // "O Serviço da Solicitação de Serviço não possui Questionário de Satisfação."
			EndIf
		EndIf

	EndIf

	// 5 - Não é possível alterar ou excluir uma S.S. que já possua Ordem de Serviço.
	If  Empty(cError) .And. (::IsUpdate() .Or. ::IsDelete()) .And. !::IsCreateSO()

		If ::HasSO(cSolici) .And. !(::IsCreateSO() .And. ::GetParam("MV_NGMULOS", "N") == "S")

			cError := STR0068 + IIf(::IsUpdate(), STR0069, STR0070) + STR0071 // "Não é possível " #### "alterar" ou "excluir" #### " esta S.S. pois ela já possui Ordem de Serviço."

		EndIf

	EndIf

	// Ponto de entrada que permite incluir novas validações aos processos de solicitação de serviço.
	If Empty( cError ) .And. ExistBlock( 'MNTA280I' )

		xPE280I := ExecBlock( 'MNTA280I', .F., .F., { ::GetOperation() } )

		If ValType( xPE280I ) == 'A'

			cError := xPE280I[2]

		ElseIf !xPE280I

			cError := STR0072 // A validação adicionada no ponto de entrada MNTA280I está impossibilitando a continuidade do processo.

		EndIF

	EndIf

	//Adiciona o Erro ao Objeto instanciado
	If !Empty(cError)
		::AddError(cError)
		RollBackSX8()
	EndIf

	RestArea(aArea)

Return ::IsValid()

//------------------------------------------------------------------------------
/*/{Protheus.doc} Upsert
Método para gravação dos registros.

@author Guilherme Freudenburg
@since 29/05/2018
@return lValid, lógico, confirma que os valores foram validados pela classe.
/*/
//------------------------------------------------------------------------------
Method Upsert() Class MntSR

	Local aArea      := GetArea()
	Local aAreaTQB   := {}
	Local cBranchST9 := ""
	Local cAsset     := ::GetValue("TQB_CODBEM")
	Local dDateOp    := ::GetValue("TQB_DTABER")
	Local cHourOp    := ::GetValue("TQB_HOABER")

	// Verifica se a informação é válida para Inclusão/Alteração.
	If ::IsValid()

		BEGIN TRANSACTION

		// Realiza a gravação da tabela TQB - Solicitação de Serviço.
		_Super:Upsert()

		If ::IsValid()


			cBranchST9 := NGSEEK("ST9", cAsset, 1, "T9_FILIAL")

			// Verifica se o bem informado possui o contador 1 e se foi informado um valor para o contador.
			If ::HasCounter(1) .And. ::GetValue("TQB_POSCON") > 0

				NGTRETCON(cAsset, dDateOp, ::GetValue("TQB_POSCON"), cHourOp, 1, , .F., , cBranchST9)

			EndIf
			// Verifica se o bem informado possui o contador 2 e se foi informado um valor para o contador.
			If ::HasCounter(2) .And. ::GetValue("TQB_POSCO2") > 0

				NGTRETCON(cAsset, dDateOp, ::GetValue("TQB_POSCO2"), cHourOp, 2, , .F., , cBranchST9)

			EndIf

			//--------------------------------------------------------------------------
			// Ponto de entrada MNTA2807
			//--------------------------------------------------------------------------
			If ExistBlock("MNTA2807") .And. AllTrim( SuperGetMv("MV_NG1FAC", .F., "2") ) != "1"
				aAreaTQB := TQB->(GetArea())
				ExecBlock("MNTA2807",.F.,.F.)
				RestArea(aAreaTQB)
			EndIf

			If ::IsInsert()
				ConfirmSX8()
			EndIf

			//--------------------------------------------------------------------------
			// Envia Workflow
			//--------------------------------------------------------------------------
			::SendWF(::GetValue("TQB_SOLICI"))

		Else
			DisarmTransaction()
		EndIf

		END TRANSACTION

		// Finaliza o processo de alteração dos registros.
		MsUnlockAll()

	EndIf

	RestArea(aArea)

Return ::IsValid()

//------------------------------------------------------------------------------
/*/{Protheus.doc} Delete
Método para exclusão da Solicitação de Serviço.

@author Guilherme Freudenburg
@since 07/06/2018
@return lValid, lógico, confirma que os valores foram validados pela classe.
@sample oObj:Delete()
/*/
//------------------------------------------------------------------------------
Method Delete() Class MntSR

	Local cBranch := ::GetValue("TQB_FILIAL")
	Local cAsset  := ::GetValue("TQB_CODBEM")
	Local nCount1 := ::GetValue("TQB_POSCON")
	Local nCount2 := ::GetValue("TQB_POSCO2")
	Local cDateOp := ::GetValue("TQB_DTABER")
	Local cHourOp := ::GetValue("TQB_HOABER")

	Begin Transaction

	// Verifica se a informação é válida.
	If ::IsValid()

		// Chama método para exclusão.
		_Super:Delete()

		// Realiza a exclusão do contador 1
		If ::HasCounter(1)
			dbSelectArea("STP")
			dbSetOrder(5) // TP_FILIAL + TP_CODBEM + TP_DTLEITU + TP_HORA
			If dbSeek(cBranch + cAsset + DTOS(cDateOp) + cHourOp, .T.)

				RecLock("STP",.F.)
				dbDelete()
				STP->(MsUnLock())

				// Realiza o acerto do contador 1
				NGRECALHIS(cAsset, 0, nCount1, cDateOp, 1, .T., .F., .T.)

			EndIf
		EndIf

		// Realiza a exclusão do contador 2
		If ::HasCounter(2)
			dbSelectArea("TPP")
			dbSetOrder(5) // TPP_FILIAL+TPP_CODBEM+DTOS(TPP_DTLEIT)+TPP_HORA
			If dbSeek(cBranch + cAsset + DTOS(cDateOp) + cHourOp)

				RecLock("TPP",.F.)
				dbDelete()
				TPP->(MsUnLock())

				// Realiza o acerto do contador 2
				NGRECALHIS(cAsset, 0, nCount2, cDateOp, 2, .T., .F., .T.)

			EndIf
		EndIf

        // Envia Workflow
		::SendWF(::GetValue("TQB_SOLICI"))

	Else
		// Para a gravação.
		DisarmTransaction()
	EndIf

	End Transaction

	MsUnlockAll()

Return ::IsValid()

//------------------------------------------------------------------------------
/*/{Protheus.doc} Assign
Método para distribuição da Solicitação de Serviço.

@author Wexlei Silveira
@since 13/06/2018
@return lValid, lógico, confirma que os valores foram validados pela classe.
@sample oObj:Assign()
/*/
//------------------------------------------------------------------------------
Method Assign() Class MntSR

	Local lMNTA280J := ExistBlock( 'MNTA280J' )

	If ::IsAssigned()

		Begin Transaction

			// Verifica se a informação é válida.
			If ::ValidBusiness()

				// Efetua a alteração do registro na TQB - Solicitação de Serviço.
				_Super:Upsert()

				// Ponto de entrada que permite customizar o processo de gravação, incluindo novos campos.
				If lMNTA280J
					ExecBlock( 'MNTA280J', .F., .F. )
				EndIf

				// Envia Workflow
				::SendWF(::GetValue("TQB_SOLICI"), ::GetValue("TQB_CDEXEC"), ::GetValue("TQB_CDSERV"))

			Else
				// Para a gravação.
				DisarmTransaction()
			EndIf

		End Transaction

		MsUnlockAll()

	EndIf

Return ::IsValid()

//------------------------------------------------------------------------------
/*/{Protheus.doc} Close
Método para fechamento da Solicitação de Serviço.

@author Wexlei Silveira
@since 18/06/2018
@return lValid, lógico, confirma que os valores foram validados pela classe.
@sample oObj:Close()
/*/
//------------------------------------------------------------------------------
Method Close() Class MntSR

	Local lFacilit := AllTrim( SuperGetMv("MV_NG1FAC", .F., "2") ) == "1"

	If ::IsClosed()

		Begin Transaction

		// Verifica se a informação é válida.
		If ::IsValid()

			// Efetua a alteração do registro na TQB - Solicitação de Serviço.
			_Super:Upsert()

			//--------------------------------------------------------------------------
			// Ponto de entrada MNTFE290
			//--------------------------------------------------------------------------
			If ExistBlock("MNTFE290")
				ExecBlock("MNTFE290",.F.,.F.)
			EndIf

			If lFacilit
				//---------------------------------------------------------------------------------------------
				// Carrega campos de pesquisa quando utiliza facilities, deve ser acionado antes de enviar wf
				//---------------------------------------------------------------------------------------------
				fQuestions( ::GetValue("TQB_SOLICI") )
			EndIf

			//--------------------------------------------------------------------------
			// Envia Workflow
			//--------------------------------------------------------------------------
			::SendWF( ::GetValue("TQB_SOLICI"), ::GetValue("TQB_CDEXEC"), ::GetValue("TQB_CDSERV"), lFacilit )

			//--------------------------------------------------------------------------
			// Ponto de entrada MNTA2909
			//--------------------------------------------------------------------------
			If ExistBlock("MNTA2909")
				ExecBlock("MNTA2909",.F.,.F.,{ 3 }) //3 - fechamento, sempre fechamento
			EndIf

		Else
			// Para a gravação.
			DisarmTransaction()
		EndIf

		End Transaction

		MsUnlockAll()

	EndIf

Return ::IsValid()

//------------------------------------------------------------------------------
/*/{Protheus.doc} CreateSO
Método para geração de O.S. mediante a Solicitaçao de Serviço.

@author Guilherme Freudenburg
@since 11/06/2018
@return bool -	.T. - Geração Efetuada ,
                .F. - Geração não Efetuada.
/*/
//------------------------------------------------------------------------------
Method CreateSO() Class MntSR

	Local cBrachST9  := ""
	Local cObsTqb    := ""
	Local cHrParReal  := ""
	Local aAreaOS    := GetArea()
	Local aAreaTQB   := TQB->(GetArea())
	Local aAreaSS    := {}
	Local aAreaSSOS  := {}
	Local aCodSO     := {}
	Local aReturn    := {}
	Local nInd       := 0
	Local nSizeField := Len(::aFieldSO)
	Local nHoraReal  := 0
	Local nDataReal  := 0
	Local nAsset     := 0
	Local nDate      := 0
	Local nServ      := 0
	Local nCounter1  := 0
	Local nCounter2  := 0
	Local nHour1     := 0
	Local nHour2     := 0
	Local nPlan      := 0
	Local nSitua     := 0
	Local nFinish    := 0
	Local nCostCnt   := 0
	Local nSequen    := 0
	Local nTipoOS    := 0
	Local nX         := 0
	Local aInput     := {}
	Local aStep      := {}
	Local aInputBlk  := {}
	Local aCamp      := {}
	Local xRet       := {}
	Local lMNTA2956  := ExistBlock( 'MNTA2956' )
	Local lMNTA2952  := ExistBlock( 'MNTA2952' )
	Local dDtParReal  := CtoD("")

	// Insumos
	Local nTask      := 0
	Local nRegType   := 0
	Local nTlCode    := 0
	Local nReqQuant  := 0
	Local nQuant     := 0
	Local nUnity     := 0
	Local nDestin    := 0
	Local nLocale    := 0
	Local cTypeHour  := ::GetParam("MV_NGUNIDT", "D")
	Local nUseCal    := 0
	Local nInputCost := 0
	Local nTaskSeq   := 0
	Local nFornec    := 0
	Local nLoja      := 0
	Local nObserva   := 0

	// Etapas
	Local nStepTask := 0
	Local nStep     := 0
	Local nSeqStep  := 0

	SetInclui() // TODO: Remover quando for implementada no Genérico

	If ::GetParam("MV_NGMULOS", "N") == "N" .And. nSizeField > 1
		nSizeField := 1
	EndIf

	BEGIN TRANSACTION

	// Percorre os valores informados através do aFieldSO, para realizar a inclusão de OS.
	For nInd := 1 To nSizeField

		// Busca a posição dos campos.
		nAsset    := aScan(::aFieldSO[nInd, __AFIELDSO_SO__],{|x| AllTrim(Upper(X[1])) == "TJ_CODBEM" })
		nDate     := aScan(::aFieldSO[nInd, __AFIELDSO_SO__],{|x| AllTrim(Upper(X[1])) == "TJ_DTORIGI"})
		nServ     := aScan(::aFieldSO[nInd, __AFIELDSO_SO__],{|x| AllTrim(Upper(X[1])) == "TJ_SERVICO"})
		nCounter1 := aScan(::aFieldSO[nInd, __AFIELDSO_SO__],{|x| AllTrim(Upper(X[1])) == "TJ_POSCONT"})
		nCounter2 := aScan(::aFieldSO[nInd, __AFIELDSO_SO__],{|x| AllTrim(Upper(X[1])) == "TJ_POSCON2"})
		nHour1    := aScan(::aFieldSO[nInd, __AFIELDSO_SO__],{|x| AllTrim(Upper(X[1])) == "TJ_HORACO1"})
		nHour2    := aScan(::aFieldSO[nInd, __AFIELDSO_SO__],{|x| AllTrim(Upper(X[1])) == "TJ_HORACO2"})
		nPlan     := aScan(::aFieldSO[nInd, __AFIELDSO_SO__],{|x| AllTrim(Upper(X[1])) == "TJ_PLANO"  })
		nSitua    := aScan(::aFieldSO[nInd, __AFIELDSO_SO__],{|x| AllTrim(Upper(X[1])) == "TJ_SITUACA"})
		nFinish   := aScan(::aFieldSO[nInd, __AFIELDSO_SO__],{|x| AllTrim(Upper(X[1])) == "TJ_TERMINO"})
		nCostCnt  := aScan(::aFieldSO[nInd, __AFIELDSO_SO__],{|x| AllTrim(Upper(X[1])) == "TJ_CCUSTO" })
		nSequen   := aScan(::aFieldSO[nInd, __AFIELDSO_SO__],{|x| AllTrim(Upper(X[1])) == "TJ_SEQRELA"})
		nTipoOS   := aScan(::aFieldSO[nInd, __AFIELDSO_SO__],{|x| AllTrim(Upper(X[1])) == "TJ_TIPOOS" })
		nHoraReal := aScan(::aFieldSO[nInd, __AFIELDSO_SO__],{|x| AllTrim(Upper(X[1])) == "TJ_HOPRINI"})
		nDataReal := aScan(::aFieldSO[nInd, __AFIELDSO_SO__],{|x| AllTrim(Upper(X[1])) == "TJ_DTPRINI"})

		If nHoraReal > 0 .AND. nDataReal > 0

			cHrParReal := ::aFieldSO[nInd,__AFIELDSO_SO__,nHoraReal,2]
			dDtParReal := ::aFieldSO[nInd,__AFIELDSO_SO__,nDataReal,2]

		EndIf

		// Verifica se o registro é válido para exclusão.
		::ValidBusiness()

		// Verifica se o valor está valido para gravação.
		If ::IsValid()

			If ::isPreventive(nInd)
				// Chama função para inclusão de Ordem de Serviço Preventiva.
				aReturn := NGGERAOS("P",;
									::aFieldSO[nInd,__AFIELDSO_SO__,nDate,2],;
									::aFieldSO[nInd,__AFIELDSO_SO__,nAsset,2],;
									::aFieldSO[nInd,__AFIELDSO_SO__,nServ,2],;
									::aFieldSO[nInd,__AFIELDSO_SO__,nSequen,2],;
									"N","N","N","",;
									::aFieldSO[nInd,__AFIELDSO_SO__,nSitua,2],;
									.F.,.F., ::aFieldSO[nInd, __AFIELDSO_SO__],;
									IIf( nTipoOS > 0, ::aFieldSO[nInd,__AFIELDSO_SO__, nTipoOS, 2], "B"),;
									::GetValue( "TQB_SOLICI" ),;
									dDtParReal, cHrParReal)

			ElseIf ::isCorrective(nInd)
				// Chama função para inclusão de Ordem de Serviço Corretiva.
				aReturn := NGGERAOS("C",;
									::aFieldSO[nInd,__AFIELDSO_SO__,nDate,2],;
									::aFieldSO[nInd,__AFIELDSO_SO__,nAsset,2],;
									::aFieldSO[nInd,__AFIELDSO_SO__,nServ,2],;
									"","","","","",;
									::aFieldSO[nInd,__AFIELDSO_SO__,nSitua,2],;
									.F.,.F.,;
									::aFieldSO[nInd, __AFIELDSO_SO__],;
									IIf(nTipoOS <> 0,::aFieldSO[nInd,__AFIELDSO_SO__,nTipoOS,2],"B"),;
									::GetValue( "TQB_SOLICI" ),;
									dDtParReal, cHrParReal)
			EndIf

			If Len(aReturn) > 0 .And. aReturn[1,1] == "S"

				NGIFDBSEEK("STJ", aReturn[1,3], 1) // seleciona ordem gerada

				//--------------------------------------------------------------------------
				// Ponto de entrada MNTA2956 para inserção de campo
				//--------------------------------------------------------------------------
				If lMNTA2956

					// Salva area posicionada
					aAreaSS   := TQB->(GetArea())
					aAreaSSOS := STJ->(GetArea())

					xRet := ExecBlock("MNTA2956",.F.,.F.)

					If ValType(xRet) == "A"

						cObsTqb := MSMM(TQB->TQB_CODMSS,80) // Busca o valor do campo memo.
						aCamp   := xRet

						For nX:= 1 to Len(aCamp)

							cObsTqb := cObsTqb + " " + aCamp[nX]

						Next nX

					EndIf

					If !Empty(cObsTqb)
						RecLock("STJ",.F.)
						STJ->TJ_OBSERVA  := cObsTqb
						STJ->(MsUnLock())
					EndIf

					// Retorna area posicionada
					RestArea(aAreaSS)
					RestArea(aAreaSSOS)

				EndIf

				//--------------------------------------------------------------------------
				// Ponto de entrada MNTA2952 para gravação de campos de usuários.
				//--------------------------------------------------------------------------
				If lMNTA2952

					ExecBlock( 'MNTA2952', .F., .F., { aReturn[1,3] } )

				EndIf

				If ::GetParam("MV_NGMULOS", "N") == "N"

					// Adiciona o valor da ordem adicionado.
					::SetValue("TQB_ORDEM",aReturn[1,3])

					// Determina que o resgistro está correto para gravação.
					::SetValid(.T.)

					// Realiza a gravação da tabela TQB - Solicitação de Serviço.
					_Super:Upsert()

				EndIf

				//-----------------------------------
				// Envia e-mail para o solicitante
				//-----------------------------------
				::SendWF()

				// Busca a filial do Bem
				cBrachST9 := NGSEEK("ST9",::aFieldSO[nInd,__AFIELDSO_SO__,nAsset,2],1,"T9_FILIAL")

				// Verifica se o bem informado possui o contador 1 e se foi informado um valor para o contador.
				If ::HasCounter(1,::aFieldSO[nInd,__AFIELDSO_SO__,nAsset,2]) .And. nCounter1 > 0 .And. ::aFieldSO[nInd,__AFIELDSO_SO__,nCounter1,2] > 0
					NGTRETCON(::aFieldSO[nInd,__AFIELDSO_SO__,nAsset,2],::aFieldSO[nInd,__AFIELDSO_SO__,nDate,2],::aFieldSO[nInd,__AFIELDSO_SO__,nCounter1,2],::aFieldSO[nInd,__AFIELDSO_SO__,nHour1,2],1,,.F.,,cBrachST9)
				EndIf

				// Verifica se o bem informado possui o contador 2 e se foi informado um valor para o contador.
				If ::HasCounter(2,::aFieldSO[nInd,__AFIELDSO_SO__,nAsset,2]) .And. nCounter2 > 0 .And. ::aFieldSO[nInd,__AFIELDSO_SO__,nCounter2,2] > 0
					NGTRETCON(::aFieldSO[nInd,__AFIELDSO_SO__,nAsset,2],::aFieldSO[nInd,__AFIELDSO_SO__,nDate,2],::aFieldSO[nInd,__AFIELDSO_SO__,nCounter2,2],::aFieldSO[nInd,__AFIELDSO_SO__,nHour2,2],2,,.F.,,cBrachST9)
				EndIf

				// Gerar registro de nao-conformidade no respectivo modulo
				If nPlan > 0 .And. Val(::aFieldSO[nInd,__AFIELDSO_SO__,nPlan,2]) == 0
					NGGERAFNC(aReturn[1,3],::aFieldSO[nInd,__AFIELDSO_SO__,nAsset,2],::aFieldSO[nInd,__AFIELDSO_SO__,nServ,2],::aFieldSO[nInd,__AFIELDSO_SO__,nDate,2])
				EndIf

				// Caso o parâmetro MV_NGMULOS estiver como 'S', gera relacionamento entre Solicit. Serv. X Ordem Serv. através da tabela TT7.
				If ::GetParam("MV_NGMULOS", "N") == "S"

					dbSelectArea("TT7")
					dbSetOrder(1)
					If !dbSeek(xFilial("TT7") + ::GetValue("TQB_SOLICI") + STJ->TJ_ORDEM)

						Reclock("TT7",.T.)
						TT7->TT7_FILIAL := xFilial("TT7")
						TT7->TT7_SOLICI := ::GetValue("TQB_SOLICI")
						TT7->TT7_ORDEM  := STJ->TJ_ORDEM
						TT7->TT7_PLANO  := STJ->TJ_PLANO
						TT7->TT7_SITUAC := STJ->TJ_SITUACA
						TT7->TT7_TERMIN := STJ->TJ_TERMINO
						MsUnLock("TT7")

					EndIf

				EndIf

				// Monta o array de Insumos e grava
				If ::HasInput(nInd)

					For nX := 1 to Len(::aFieldSO[nInd,__AFIELDSO_INPUT__])

						nTask     := aScan(::aFieldSO[nInd, __AFIELDSO_INPUT__, nX],{|x| AllTrim(Upper(X[1])) == "TL_TAREFA"})
						nRegType  := aScan(::aFieldSO[nInd, __AFIELDSO_INPUT__, nX],{|x| AllTrim(Upper(X[1])) == "TL_TIPOREG"})
						nTlCode   := aScan(::aFieldSO[nInd, __AFIELDSO_INPUT__, nX],{|x| AllTrim(Upper(X[1])) == "TL_CODIGO"})
						nReqQuant := aScan(::aFieldSO[nInd, __AFIELDSO_INPUT__, nX],{|x| AllTrim(Upper(X[1])) == "TL_QUANREC"})
						nQuant    := aScan(::aFieldSO[nInd, __AFIELDSO_INPUT__, nX],{|x| AllTrim(Upper(X[1])) == "TL_QUANTID"})
						nUnity    := aScan(::aFieldSO[nInd, __AFIELDSO_INPUT__, nX],{|x| AllTrim(Upper(X[1])) == "TL_UNIDADE"})
						nDestin   := aScan(::aFieldSO[nInd, __AFIELDSO_INPUT__, nX],{|x| AllTrim(Upper(X[1])) == "TL_DESTINO"})
						nLocale   := aScan(::aFieldSO[nInd, __AFIELDSO_INPUT__, nX],{|x| AllTrim(Upper(X[1])) == "TL_LOCAL"})
						nUseCal   := aScan(::aFieldSO[nInd, __AFIELDSO_INPUT__, nX],{|x| AllTrim(Upper(X[1])) == "TL_USACALE"})
						nTaskSeq  := aScan(::aFieldSO[nInd, __AFIELDSO_INPUT__, nX],{|x| AllTrim(Upper(X[1])) == "TL_SEQTARE"})
						nDtIni    := aScan(::aFieldSO[nInd, __AFIELDSO_INPUT__, nX],{|x| AllTrim(Upper(X[1])) == "TL_DTINICI"})
						nHrIni    := aScan(::aFieldSO[nInd, __AFIELDSO_INPUT__, nX],{|x| AllTrim(Upper(X[1])) == "TL_HOINICI"})
						nFornec   := aScan(::aFieldSO[nInd, __AFIELDSO_INPUT__, nX],{|x| AllTrim(Upper(X[1])) == "TL_FORNEC"})
						nLoja     := aScan(::aFieldSO[nInd, __AFIELDSO_INPUT__, nX],{|x| AllTrim(Upper(X[1])) == "TL_LOJA"})
						nObserva  := aScan(::aFieldSO[nInd, __AFIELDSO_INPUT__, nX],{|x| AllTrim(Upper(X[1])) == "TL_OBSERVA"})

						nInputCost := NGCALCUSTI(::aFieldSO[nInd,__AFIELDSO_INPUT__,nX,nTlCode,2], ::aFieldSO[nInd,__AFIELDSO_INPUT__,nX,nRegType,2], ::aFieldSO[nInd,__AFIELDSO_INPUT__,nX,nQuant,2],;
												 ::aFieldSO[nInd,__AFIELDSO_INPUT__,nX,nLocale,2], cTypeHour,,, ::aFieldSO[nInd,__AFIELDSO_INPUT__,nX,nReqQuant,2])

						aAdd( aInput, { ::aFieldSO[nInd,__AFIELDSO_INPUT__,nX,nTask,2], ::aFieldSO[nInd,__AFIELDSO_INPUT__,nX,nRegType,2], ::aFieldSO[nInd,__AFIELDSO_INPUT__,nX,nTlCode,2],;
							::aFieldSO[nInd,__AFIELDSO_INPUT__,nX,nReqQuant,2], ::aFieldSO[nInd,__AFIELDSO_INPUT__,nX,nQuant,2], ::aFieldSO[nInd,__AFIELDSO_INPUT__,nX,nUnity,2],;
							::aFieldSO[nInd,__AFIELDSO_INPUT__,nX,nDestin,2], ::aFieldSO[nInd,__AFIELDSO_INPUT__,nX,nLocale,2], cTypeHour,;
							::aFieldSO[nInd,__AFIELDSO_INPUT__,nX,nUseCal,2], nInputCost, ::aFieldSO[nInd,__AFIELDSO_INPUT__,nX,nTaskSeq,2],;
							::aFieldSO[nInd,__AFIELDSO_INPUT__,nX,nDtIni,2], ::aFieldSO[nInd,__AFIELDSO_INPUT__,nX,nHrIni,2],;
							IIf( nFornec > 0, ::aFieldSO[nInd,__AFIELDSO_INPUT__,nX,nFornec,2], '' ),;   // 15 - TL_FORNEC
							IIf( nLoja > 0, ::aFieldSO[nInd,__AFIELDSO_INPUT__,nX,nLoja,2], '' ),;       // 16 - TL_LOJA
							IIf( nObserva > 0, ::aFieldSO[nInd, __AFIELDSO_INPUT__,nX,nObserva,2], '' )})// 17 - TL_OBSERVA 

						// Grava os insumos previstos
						aInputBlk := fInputStep(aReturn[1,3], ::aFieldSO[nInd,__AFIELDSO_SO__,nPlan,2], aInput, {}, ::aFieldSO[nInd,__AFIELDSO_SO__,nCostCnt,2])

						// Grava os bloqueios dos insumos
						NGBLOQINS(aInputBlk, ::aFieldSO[nInd,__AFIELDSO_SO__,nPlan,2], ::aFieldSO[nInd,__AFIELDSO_SO__,nAsset,2])

						aInput := {}
						aInputBlk := {}

					Next nX

				EndIf

				// Monta o array de Etapas e grava
				If ::HasStep(nInd)

					For nX := 1 to Len(::aFieldSO[nInd,__AFIELDSO_STEP__])

						nStepTask := aScan(::aFieldSO[nInd, __AFIELDSO_STEP__, nX],{|x| AllTrim(Upper(X[1])) == "TQ_TAREFA"})
						nStep     := aScan(::aFieldSO[nInd, __AFIELDSO_STEP__, nX],{|x| AllTrim(Upper(X[1])) == "TQ_ETAPA"})
						nSeqStep  := aScan(::aFieldSO[nInd, __AFIELDSO_STEP__, nX],{|x| AllTrim(Upper(X[1])) == "TQ_SEQETA"})

						aAdd(aStep, {::aFieldSO[nInd, __AFIELDSO_STEP__, nX, nStepTask,2], ::aFieldSO[nInd, __AFIELDSO_STEP__, nX, nStep,2], ::aFieldSO[nInd, __AFIELDSO_STEP__, nX, nSeqStep,2]})

						// Grava as etapas previstas
						fInputStep(aReturn[1,3], ::aFieldSO[nInd,__AFIELDSO_SO__,nPlan,2], {}, aStep, ::aFieldSO[nInd,__AFIELDSO_SO__,nCostCnt,2])

						aStep := {}

					Next nX

				EndIf

				// Verifica se foi realizado a inclusão de uma OS.
				aAdd(aCodSO, aReturn[1,3]) // Adiciona o código da OS gerada na variável da Classe.

				// Finaliza o processo de alteração dos registros.
				MsUnlockAll()

			ElseIf Len(aReturn) > 0 .And. !Empty(aReturn[1,2])

				::AddError(aReturn[1,2])
				aCodSO := {}
				DisarmTransaction()
				Exit

			EndIf

			// Finaliza processo de gravação
			If !::IsValid()
				DisarmTransaction()
			EndIf

		EndIf

	Next nInd

	END TRANSACTION

	RestArea(aAreaOS)
	RestArea(aAreaTQB)

Return aCodSO

//------------------------------------------------------------------------------
/*/{Protheus.doc} IsAnalysis
Indica se a S.S. está com status "Aguardando Análise".

@author Wexlei Silveira
@since 08/06/2018
@return lógico, se o status da SS for igual a "Aguardando Análise"
/*/
//------------------------------------------------------------------------------
Method IsAnalysis() Class MntSR
Return ::GetValue("TQB_SOLUCA") == "A"

//------------------------------------------------------------------------------
/*/{Protheus.doc} IsAssigned
Indica se a S.S. está com status "Distribuída".

@author Wexlei Silveira
@since 08/06/2018
@return lógico, se o status da SS for igual a "Distribuída"
/*/
//------------------------------------------------------------------------------
Method IsAssigned() Class MntSR
Return ::GetValue("TQB_SOLUCA") == "D"

//------------------------------------------------------------------------------
/*/{Protheus.doc} IsClosed
Indica se a S.S. está com status "Encerrada".

@author Wexlei Silveira
@since 08/06/2018
@return lógico, se o status da SS for igual a "Encerrada"
/*/
//------------------------------------------------------------------------------
Method IsClosed() Class MntSR
Return ::GetValue("TQB_SOLUCA") == "E"

//------------------------------------------------------------------------------
/*/{Protheus.doc} IsCanceled
Indica se a S.S. está com status "Cancelada".

@author Wexlei Silveira
@since 08/06/2018
@return lógico, se o status da SS for igual a "Cancelada"
/*/
//------------------------------------------------------------------------------
Method IsCanceled() Class MntSR
Return ::GetValue("TQB_SOLUCA") == "C"

//------------------------------------------------------------------------------
/*/{Protheus.doc} IsCreateSO
Indica se é o processo de Geração de Ordem de Serviço (OS)

@author Guilherme Freudenburg
@since 20/06/2018
@return lógico, se está no processo de geração de OS.
/*/
//------------------------------------------------------------------------------
Method IsCreateSO() Class MntSR
Return Len(::aFieldSO) > 0

//------------------------------------------------------------------------------
/*/{Protheus.doc} HasInput
Indica se a OS possui Insumos.

@parameters [nPos], Numérico, Posição no aFieldSO de acordo com a OS.
@author Wexlei Silveira
@since 29/08/2018
@return lógico, se está no processo de geração de OS.
/*/
//------------------------------------------------------------------------------
Method HasInput(nPos) Class MntSR

	Default nPos := 1

Return Len(::aFieldSO[nPos, __AFIELDSO_INPUT__, 1]) > 0

//------------------------------------------------------------------------------
/*/{Protheus.doc} HasStep
Indica se a OS possui Etapas.

@parameters [nPos], Numérico, Posição no aFieldSO de acordo com a OS.
@author Wexlei Silveira
@since 29/08/2018
@return lógico, se está no processo de geração de OS.
/*/
//------------------------------------------------------------------------------
Method HasStep(nPos) Class MntSR

	Default nPos := 1

Return Len(::aFieldSO[nPos, __AFIELDSO_STEP__, 1]) > 0

//------------------------------------------------------------------------------
/*/{Protheus.doc} isCorrective
Define se a O.S. é Corretiva.

@parameters nPos, Numérico, Posição no aFieldSO de acordo com a OS.
@author Wexlei Silveira
@since 02/10/2018
@return Bool
/*/
//------------------------------------------------------------------------------
Method isCorrective(nPos) Class MntSR

	Local nPlan := aScan(::aFieldSO[nPos, __AFIELDSO_SO__],{|x| AllTrim(Upper(X[1])) == "TJ_PLANO"})

Return Val(::aFieldSO[nPos, __AFIELDSO_SO__, nPlan, 2]) == 0

//------------------------------------------------------------------------------
/*/{Protheus.doc} isPreventive
Define se a O.S. é Preventiva.

@parameters nPos, Numérico, Posição no aFieldSO de acordo com a OS.
@author Wexlei Silveira
@since 02/10/2018
@return Bool
/*/
//------------------------------------------------------------------------------
Method isPreventive(nPos) Class MntSR

	Local nPlan := aScan(::aFieldSO[nPos, __AFIELDSO_SO__],{|x| AllTrim(Upper(X[1])) == "TJ_PLANO"})

Return Val(::aFieldSO[nPos, __AFIELDSO_SO__, nPlan, 2]) > 0

//------------------------------------------------------------------------------
/*/{Protheus.doc} isThird
Indica se a O.S. é enviada para Terceiros.

@parameters nPos, Numérico, Posição no aFieldSO de acordo com a OS.
@author Wexlei Silveira
@since 02/10/2018
@return bool
/*/
//------------------------------------------------------------------------------
Method isThird(nPos) Class MntSR

	Local nThird := aScan(::aFieldSO[nPos, __AFIELDSO_SO__],{|x| AllTrim(Upper(X[1])) == "TJ_TERCEIR"})

Return nThird > 0 .And. ::aFieldSO[nPos, __AFIELDSO_SO__, nThird, 2] == "2"

//------------------------------------------------------------------------------
/*/{Protheus.doc} IsAnswer
Indica se está no processo de Resposta de Questionário de Satisfação da
Solicitação de Serviço.

@author Guilherme Freudenburg
@since 26/06/2018
@return lógico, se está no processo de geração de Satisfação de SS.
/*/
//------------------------------------------------------------------------------
Method IsAnswer() Class MntSR

Return Posicione("TQB",01,::GetValue("TQB_FILIAL")+::GetValue("TQB_SOLICI"),"TQB_SOLUCA") == "E"

//------------------------------------------------------------------------------
/*/{Protheus.doc} SetValueSO
Transfere os valores do Array para o objeto.

@example
   aAdd(aCampos,{ {"TJ_CODBEM" , '10              '  },;
		          {"TJ_CCUSTO" , '01       ' },;
				  {"TJ_SERVICO", '10    ' },;
				  {"TJ_SEQRELA", '0' },;
				  {"TJ_DTORIGI", 01/01/2018 },;
				  {"TJ_POSCONT", 30000 },;
				  {"TJ_HORACO1", '10:10' },;
				  {"TJ_HOMPINI", '10:10' },;
				  {"TJ_DTMPINI", '01/01/2018' },;
				  {"TJ_OBSERVA", 'Observação da OS.' },;
				  {"TJ_SITUACA", 'L' },;
				  {"TJ_TERCEIR", 'N' },;
				  {"TJ_PLANO"  , '000000' }})

	oTQB:SetValueSO(aCampos)

@author Guilherme Freudenburg
@since 15/06/2018
@return Nil
/*/
//------------------------------------------------------------------------------
Method SetValueSO(aFields) Class MntSR
	::aFieldSO := aClone(aFields)
Return Nil

//------------------------------------------------------------------------------
/*/{Protheus.doc} HasCounter
Indica se o bem da S.S. possui contador

@author Guilherme Freudenburg
@since 30/05/2018
@parameters nCounter - Contador (1/2) - Numerico
@return lHasCount, lógico, se o bem tem contador próprio
/*/
//------------------------------------------------------------------------------
Method HasCounter(nCounter,cAsset) Class MntSR

	Local lHasCount := .F.

	Default nCounter := 1
	Default cAsset  := ::GetValue("TQB_CODBEM")

    // Contador 1.
    If nCounter == 1
        dbSelectArea("ST9")
        dbSetOrder(1)
        If dbSeek(xFilial("ST9") + cAsset)
            If ST9->T9_TEMCONT == "S"
                lHasCount := .T.
            EndIf
        EndIf

	// Contador 2.
	ElseIf nCounter == 2
		//FindFunction remover na release GetRPORelease() >= '12.1.027'
		If FindFunction("MNTCont2")
			lHasCount := MNTCont2(xFilial("TPE"), cAsset)
		Else
			dbSelectArea("TPE")
			dbSetOrder(1)
			If dbSeek(xFilial("TPE") + cAsset) .And. TPE->TPE_SITUAC == "1"
				lHasCount := .T.
			EndIf
		EndIf
	EndIf

Return lHasCount

//------------------------------------------------------------------------------
/*/{Protheus.doc} SendWF
Envio de Workflow.

@author Wexlei Silveira
@since 08/06/2018

@param cSolici, Caractere, Código da Solicitação
@param [cCDExec], Caractere, Código do Executante
@param [cServCode], Caractere, Tipo do Serviço
@param [cOrder], Caractere, Código da OS
@param [cState], Caractere, Status da OS
@param [lFacilit], boolean, se utiliza novo facilities

@return lRet, Lógico, Retorno das funções de envio de Workflow
/*/
//------------------------------------------------------------------------------
Method SendWF(cSolici, cCDExec, cServCode, cOrder, cState, lFacilit ) Class MntSR

	Local oWorkflow
	Local cAliasWF := GetNextAlias()
	Local aDbfW045 := {}
	Local aArea    := GetArea()
	Local aAreaTQB := TQB->(GetArea())
	Local lRet     := .T.

	Default lFacilit := .F.

	If ::GetParam("MV_NGSSWRK", "N") == "S"

		If ::IsInsert() // Workflow de inclusão de SS

			lRet := MNTW025(cSolici,,, cAliasWF)

		ElseIf ::IsAssigned() .And. !::IsCreateSO()// Workflow de distribuição da SS

			lRet := MNTW040(cSolici, cCDExec, cServCode, cAliasWF)

		ElseIf ::IsDelete() // Workflow de exclusão de SS

			lRet := MNTW045(cSolici,,, cAliasWF, aDbfW045)

		ElseIf ::IsClosed() // Workflow de fechamento de SS

			If lFacilit .Or. ( Empty( ::GetValue("TQB_PSAN") ) .And. Empty( ::GetValue("TQB_PSAP") ) )

				dbSelectArea("TQB")
				dbSetOrder(01)
				If dbSeek(xFilial("TQB") + cSolici, .T.)

					lRet := MNTW035(TQB->(RecNo()))

				Else

					lRet := .F.

				EndIf
			EndIf

		ElseIf ::IsCreateSO() // Caso seja chamado pela geração de Ordem de Serviço.

			MNW29501( ::GetValue( "TQB_CDSOLI" ) ) //Envia e-mail para solicitante
			//O wf MNTW215 não deve ser acionado aqui pois já é enviado através da função NGGERAOS
		EndIf
	EndIf

	If Type("oWorkflow") == "O"
		oWorkflow:Delete()
	EndIf

	RestArea(aAreaTQB)
	RestArea(aArea)

Return lRet

//------------------------------------------------------------------------------
/*/{Protheus.doc} HasSO
Verifica se existe OS em aberto para a S.S.

@author Wexlei Silveira
@since 19/06/2018

@param cSolici, Caractere, Código da Solicitação de Serviço

@return lRet, Lógico, Se existe ou não OS em aberto para a S.S.
/*/
//------------------------------------------------------------------------------
Method HasSO(cSolici) Class MntSR

	Local lRet     := .F.
	Local aArea    := GetArea()
	Local aAreaTQB := TQB->(GetArea())

	If ::GetParam("MV_NGMULOS", "N") == "N"

		dbSelectArea("TQB")
		dbSetOrder(01)
		If dbSeek(xFilial("TQB") + cSolici)
			If !Empty(TQB->TQB_ORDEM)
				lRet := .T.
				If ::IsClosed() .And. NGIFDBSEEK("STJ", TQB->TQB_ORDEM, 1) .And. ;
					(STJ->TJ_TERMINO != 'N' .Or. STJ->TJ_SITUACA == 'C')
					lRet := .F.
				EndIf
			EndIf
		EndIf

	ElseIf ::IsClosed()

		dbSelectArea("TT7")
		dbSetOrder(1)
		If dbSeek(xFilial("TT7") + cSolici)
			While !Eof() .And. Alltrim(TT7->TT7_SOLICI) == Alltrim(cSolici)
				dbSelectArea("STJ")
				dbSetOrder(01)
				If dbSeek(xFilial("STJ") + TT7->TT7_ORDEM)
					If STJ->TJ_TERMINO == "N" .And. STJ->TJ_SITUACA <> 'C'
						lRet := .T.
						Exit
					EndIf
				EndIf
				TT7->(dbSkip())
			EndDo
		EndIf

	EndIf

	RestArea(aAreaTQB)
	RestArea(aArea)

Return lRet

//------------------------------------------------------------------------------
/*/{Protheus.doc} AddFile
Adicionar imagem no Banco de Conhecimento

@author Vitor Bonet
@since 16/08/2018

@param oImage, Objeto, Contem a imagem em Base 64
@param nMode, Numérico, Modo de gravação. 1 para corpo da ordem, 2 para finalização

@return aImage, array, aImage[1] = nome do arquivo, aImage[2] = data e hora.
/*/
//------------------------------------------------------------------------------
Method AddFile(oImage, nMode) Class MntSR

	Local cDocPath
	Local cObject
	Local cFilePath
	Local nHandler
	Local cObjCode
	Local cSlash := If(isSRVunix(),"/","\")
	Local nNameSize := 5
	Local cDateTime := DToC( Date() ) + ' ' + Time()
	Local cType := If( nMode == 1, 'PROBLEM ', 'SOLUTION' )
	Local cMsDocPath := If(isSRVunix(), Lower(StrTran( MsDocPath(),'\', '/')),MsDocPath())
	Local cSolici   := ::GetValue("TQB_SOLICI")
	Local aImage := {}

	cDocPath := cMsDocPath
	cObject  := NewIdentif( nNameSize ) + '.jpg'
	// Enquanto existirem nomes conflitantes, geramos outro
	While File( cDocPath + cSlash + cObject )
		cObject := NewIdentif( nNameSize ) + '.jpg'
	EndDo

	// Abrimos um ponteiro para o novo arquivo para depositar os bytes
	cFilePath := cDocPath + cSlash + cObject
	nHandler := FCreate( cFilePath, Nil, Nil, .F. )
	If nHandler == -1
		::AddError( STR0077 ) // "Erro ao criar arquivo no servidor."
		Return aImage// "Erro ao criar arquivo no servidor"
	EndIf
	FWrite( nHandler, Decode64( oImage ) )
	FClose( nHandler )

	// Posicionar na tabela de objetos
	dbSelectArea( 'ACB' )
	dbSetOrder( 2 ) // ACB_FILIAL + ACB_OBJETO
	// Arquivo não possui registro na base, então adicionamos

	If !dbSeek( xFilial( 'ACB' ) + cObject )
		cObjCode := GetSXEnum( 'ACB', 'ACB_CODOBJ' )
		RecLock( 'ACB', .T. )
		ACB->ACB_FILIAL := xFilial( 'ACB' )
		ACB->ACB_CODOBJ := cObjCode
		ACB->ACB_OBJETO := cObject
		ACB->ACB_DESCRI := cType + ' ' + cDateTime
		ACB->(MsUnLock())
		ConfirmSX8()

		// Gravar vínculos entre objetos e ordem na AC9
		dbSelectArea( 'AC9' )
		dbSetOrder( 1 ) // AC9_FILIAL + AC9_CODOBJ + AC9_ENTIDA + AC9_FILENT + AC9_CODENT

		If !dbSeek( xFilial( 'AC9' ) + cObjCode + 'TQB' + xFilial( 'TQB' ) + cSolici )
			RecLock( 'AC9', .T. )
			AC9->AC9_FILIAL := xFilial( 'AC9' )
			AC9->AC9_FILENT := xFilial( 'TQB' )
			AC9->AC9_ENTIDA := 'TQB'
			AC9->AC9_CODENT := xFilial( 'TQB' ) + cSolici
			AC9->AC9_CODOBJ := cObjCode
			AC9->(MsUnLock())
		EndIf
	EndIf

	aAdd(aImage, { cObject, cDateTime, cObjCode })

Return aImage

//------------------------------------------------------------------------------
/*/{Protheus.doc} GetFileList
Busca todas as imagens que a S.S possui no Banco de Conhecimento.

@author Vitor Bonet
@since 16/08/2018

@return aImages, Array, Array com todos os Códigos de Objeto das imagens.

@obs aImages[1] = Código do Objeto, aImages[2] = Nome do arquivo, aImages[3] = Descrição, aImages[3] = Tipo da Imagem (Problema ou solução)

/*/
//------------------------------------------------------------------------------
Method GetFileList() Class MntSR

	Local aArea     := GetArea()
	Local cAliasQry := GetNextAlias()
	Local cSolici   := ::GetValue("TQB_SOLICI")
	Local aImages   := {}

	// Busca todos os caminhos das imagens PROBLEMA/SOLUÇÃO no Banco de Conhecimento.
	BeginSql Alias cAliasQry

		SELECT AC9.AC9_CODOBJ, ACB.ACB_OBJETO, ACB.ACB_DESCRI
		FROM %table:AC9% AC9
		INNER JOIN %table:ACB% ACB 
			ON ACB.ACB_FILIAL = %xFilial:ACB%
			AND ACB.ACB_CODOBJ = AC9.AC9_CODOBJ
			AND ACB.%NotDel%
            AND RTRIM(SUBSTRING( ACB.ACB_DESCRI, 1, 8 )) IN ('PROBLEM', 'SOLUTION')
		WHERE AC9.AC9_FILIAL = %xFilial:AC9%
			AND AC9_FILENT = %xFilial:TQB%
			AND AC9_ENTIDA = 'TQB'
			AND AC9_CODENT = %xFilial:TQB% || %Exp:cSolici%
			AND AC9.%NotDel%
		ORDER BY AC9.AC9_CODOBJ

	EndSql

	While (cAliasQry)->(!Eof())
		// Adiciona no array o Código do Objeto de cada imagem.
		aAdd( aImages, { (cAliasQry)->AC9_CODOBJ, (cAliasQry)->ACB_OBJETO, (cAliasQry)->ACB_DESCRI, SUBSTR((cAliasQry)->ACB_DESCRI, 1, 8) })

		(cAliasQry)->(dbSkip())
	End

	(cAliasQry)->(dbCloseArea())

	RestArea(aArea)

Return aImages

//------------------------------------------------------------------------------
/*/{Protheus.doc} DeleteFile
Deleta imagem do Banco de Conhecimento.

@author Vitor Bonet
@since 16/08/2018

@param cId, Caractere, Código do Objeto.

@return Lógico.

/*/
//------------------------------------------------------------------------------
Method DeleteFile(cId) Class MntSR

    Local cSlash   := If(isSRVunix(),"/","\")
    Local cDocPath := MsDocPath() + cSlash
    Local aArea    := GetArea()
    Local cAlias   := GetNextAlias()
	Local lRet     := .T.

    cQry := " SELECT AC9_CODENT, ACB_OBJETO "
    cQry += " FROM " + RetSqlName("AC9") + " AC9 "
    cQry += " INNER JOIN " + RetSqlName("ACB") + " ACB "
    cQry += "     ON ACB_CODOBJ = AC9_CODOBJ "
    cQry += "     AND ACB.D_E_L_E_T_ <> '*'
    cQry += " WHERE AC9_FILENT = " + ValToSQL(xFilial("TQB"))
    cQry += "     AND AC9_ENTIDA = 'TQB'"
    cQry += "     AND AC9_CODOBJ = "+ ValToSQL(cId)
    cQry += "     AND AC9.D_E_L_E_T_ <> '*'
    cQry += "     AND AC9_FILIAL = " + ValToSQL(xFilial("AC9"))

    cQry := ChangeQuery(cQry)

    MPSysOpenQuery(cQry, cAlias)

    dbSelectArea(cAlias)

    If Empty( ( cAlias )->AC9_CODENT )
        ::addError( STR0073 + cId + STR0074 )
        lRet := .F.
    EndIf

    // Remover vínculo de entidades (deleção lógica)
    dbSelectArea( 'AC9' )
    dbSetOrder( 2 ) // AC9_FILIAL + AC9_ENTIDA + AC9_FILENT + AC9_CODENT + AC9_CODOBJ
    If dbSeek( xFilial( 'AC9' ) + 'TQB' + xFilial( 'TQB' ) +( cAlias )->AC9_CODENT + cId )
        RecLock( 'AC9', .F. )
        dbDelete()
        MsUnlock()
    EndIf

    // Remover registro textual do banco de objetos (deleção lógica)
    dbSelectArea( 'ACB' )
    dbSetOrder( 1 ) // ACB_FILIAL + ACB_CODOBJ
    If dbSeek( xFilial( 'ACB' ) + cId )
        RecLock( 'ACB', .F. )
        dbDelete()
        MsUnlock()
    EndIf

    // Remover arquivo físico do banco de conhecimento
    If File( cDocPath + ( cAlias )->ACB_OBJETO )
        FErase( cDocPath + ( cAlias )->ACB_OBJETO )
    EndIf

    ( cAlias )->( dbCloseArea() )
	RestArea( aArea )

Return lRet

//------------------------------------------------------------------------------
/*/{Protheus.doc} fDplSR
Alerta a existência de SS duplicadas.

@author Wexlei Silveira
@since 07/06/2018
@param oTQB    , Object  , Objeto com os valores.
@param cAsset , Caracter, Código do bem.
@param cServCode, Caracter, Código do tipo de serviço.

@return lRet, Lógico, Retorna verdadeiro caso possua outra S.S.
/*/
//------------------------------------------------------------------------------
Static Function fDplSR(oTQB, cAsset, cServCode)

	Local lRet     := .F.
	Local aArea    := GetArea()
	Local aAreaTQB := TQB->(GetArea())

	dbSelectArea("TQB")
	dbSetOrder(05)
	dbSeek(xFilial("TQB") + cAsset,.T.)
	While !Eof() .And. TQB->TQB_FILIAL == xFilial("TQB") .And. TQB->TQB_CODBEM == cAsset

		If TQB->TQB_CDSERV == cServCode .And. TQB->TQB_SOLUCA == "A"
			lRet := .T.
			Exit
		EndIf

		TQB->(dbSkip())
	EndDo

	RestArea(aAreaTQB)
	RestArea(aArea)

Return lRet

//------------------------------------------------------------------------------
/*/{Protheus.doc} fValServ
Função responsável pela validação do campo 'TQB_CDSERV'

@param cCodServ, Caracter, Código do serviço - TQB_CDSERV.

@author Guilherme Freudenburg
@since 10/08/2018

@return lRet, Lógico, Retorna verdadeiro caso possua outra S.S.
/*/
//------------------------------------------------------------------------------
Static Function fValServ(cCodServ)

	Local aArea := GetArea()
	Local cErro := ""

	dbSelectArea("TQ3")
	dbSetOrder(1)
	If !dbSeek(xFilial("TQ3")+cCodServ)
		cErro := STR0015 + Alltrim(Posicione("SX3",2,"TQB_CDSERV","X3Titulo()")) + STR0075 //"O valor informado no campo " #### " está incorreto."
	EndIf

RestArea(aArea)

Return cErro

//------------------------------------------------------------------------------
/*/{Protheus.doc} fInputStep
Grava Insumo e/ou Etapa da OS.
@type function

@param cSOCode , Caractere, Código da OS
@param cSOPlan , Caractere, Código do plano da OS
@param [aInput], Array    , Array da Tarefa
@param [aStep] , Array    , Array da Etapa
@param cCostCnt, Caractere, Código do Centro de Custo

@author Wexlei Silveira
@since 30/08/2018

@return aBlock, Array, Array dos recursos a serem bloqueados.
@Obs.: Cópia da função NGGSTLSTQ
/*/
//------------------------------------------------------------------------------
Static Function fInputStep( cSOCode, cSOPlan, aInput, aStep, cCostCnt )

	Local i          := 1
	Local nTIP       := 0
	Local nQuant     := 0
	Local lSEQTAR    := NGCADICBASE( 'TL_SEQTARE', 'A', 'STL', .F. )
	Local lGrvBLO    := .T.
	Local aBlock     := { {}, {}, {}, {}, {} }
	Local aInsFim    := {}
	Local aArea      := GetArea()
	Local cCorPR     := SuperGetMv( 'MV_NGCORPR', .F., 'N' )
	Local cBlockEmp  := 'S'
	Local cBlockTool := 'S'
	Local cBlockItem := 'S'
	Local cUsCal     := ''
	Local cHrFim     := ''
	Local cHrIni     := ''
	Local dDtFim     := cToD( '' )
	Local dDtIni     := cToD( '' )

	If cSOPlan <= "000000"

		cBlockEmp  := IIf(cCorPR == "S", "S", "N")
		cBlockTool := IIf(cCorPR == "S", "S", "N")
		cBlockItem := IIf(cCorPR == "S", "S", "N")

	EndIf

	For i := 1 to Len(aInput)

		cUsCal := IIf( Empty( aInput[i,10] ), 'N', aInput[i,10] )

		If FindFunction( 'NgVldRpo' ) .And. NgVldRpo( { { 'MNTA295.prw', cToD( '20/12/2019' ), '11:08' } } )

			cHrIni := aInput[i][14]
			dDtIni := aInput[i][13]

			If aInput[i,2] == 'P'

				dDtFim := aInput[i,13]
				cHrFim := aInput[i,14]

			ElseIf aInput[i,2] == 'M'

				aInsFim := M420RETDAT( aInput[i,3], aInput[i,13], aInput[i,14], aInput[i,5], cUsCal )

				dDtFim := aInsFim[3]
				cHrFim := aInsFim[4]

			Else

				aInsFim := NGDTHORFIM( aInput[i,13], aInput[i,14], aInput[i,5], aInput[i][9] )

				dDtFim := aInsFim[1]
				cHrFim := aInsFim[2]

			EndIf

		EndIf

		dbSelectArea("STL")
		dbSetOrder(1)
		If !dbSeek(cSOCode + cSOPlan + aInput[i][1] + aInput[i][2] + aInput[i][3])

			STL->(RecLock("STL",.T.))
			STL->TL_FILIAL  := xFilial("STL")
			STL->TL_ORDEM   := cSOCode
			STL->TL_PLANO   := cSOPlan
			STL->TL_TAREFA  := aInput[i][1]
			STL->TL_TIPOREG := aInput[i][2]
			STL->TL_CODIGO  := aInput[i][3]
			STL->TL_QUANREC := aInput[i][4]
			STL->TL_QUANTID := aInput[i][5]
			STL->TL_UNIDADE := aInput[i][6]
			STL->TL_DESTINO := aInput[i][7]
			STL->TL_LOCAL   := aInput[i][8]
			STL->TL_SEQRELA := "0"
			STL->TL_TIPOHOR := aInput[i][9]
			STL->TL_USACALE := cUsCal
			STL->TL_CUSTO   := aInput[i][11]
			STL->TL_DTINICI := dDtIni
			STL->TL_HOINICI := cHrIni
			STL->TL_DTFIM   := dDtFim
			STL->TL_HOFIM   := cHrFim

			If STL->TL_TIPOREG == 'T'
				STL->TL_FORNEC := aInput[i][15]
				STL->TL_LOJA   := aInput[i][16]
			EndIf

			If lSEQTAR
				STL->TL_SEQTARE := aInput[i][12]
			EndIf
			STL->TL_OBSERVA := aInput[i][17]
			STL->(MsUnlock())

		EndIf

		If aInput[i][2] == "F"
			nTIP := IIf(cBlockTool == "S", 1, 0)
		ElseIf aInput[i][2] == "M"
			nTIP := IIf(cBlockEmp == "S", 2, 0)
		ElseIf aInput[i][2] == "E"
			nTIP := IIf(cBlockEmp == "S", 3, 0)
		ElseIf aInput[i][2] == "P"
			nTIP := IIf(cBlockItem == "S", 4, 0)
		ElseIf aInput[i][2] == "T"
			nTIP := IIf(cBlockItem == "S", 5, 0)
		Else
			nTIP := 0
		EndIf

		If nTIP > 0

			lGrvBLO := .T.
			If nTIP == 4 // Aglutina produtos iguais

				nPosBlo := aScan(aBlock[nTIP], {|x| x[2]+x[11] = aInput[i][3] + aInput[i][12]})
				If nPosBlo > 0
					aBlock[nTIP][nPosBlo][3] += IIf(aInput[i][2] $ "E/F", aInput[i][4], aInput[i][5])
					lGrvBLO := .F.
				Else
					lGrvBLO := .T.
				EndIf

			EndIf

			If lGrvBLO

				If aInput[i,2] $ 'E/F'
					nQuant := aInput[i,4]
				Else
					nQuant := aInput[i,5]
				EndIf

				aAdd( aBlock[nTIP], { 	aInput[i][1]  ,; // TL_TAREFA
										aInput[i][3]  ,; // TL_CODIGO
										nQuant		  ,; // Quantidade
										dDtIni		  ,; // Data inicio
										cHrIni		  ,; // Hora inicio
										dDtFim		  ,; // Data Fim
										cHrFim		  ,; // Hora fim
										cSOCode       ,; // TL_ORDEM
										cSOPlan       ,; // TL_PLANO
										cCostCnt      ,; // Centro de Custo
										Nil			  ,; // TL_NUMSC
										Nil			  ,; // TL_ITEMSC
										Nil			  ,; // TL_QTDOPER
										Nil			  ,; // TL_ALMOPERA
										Nil			  ,; // TL_QTDOMAT
										Nil			  ,; // TL_ALMOMAT
										Nil			  ,; // TL_QTDSC1
										aInput[i][8]  ,; // TL_LOCAL
										aInput[i][6]  ,; // TL_UNIDADE
										Nil			  ,; // OBSERVACAO DO INSUMO
										Nil			  ,; // TL_QTDSC1
										STL->TL_FORNEC,; // TL_FORNEC
										STL->TL_LOJA  ,; // TL_LOJA
										Nil			  ,; // TL_NUMSA
										Nil           ;  // TL_ITEMSA
									} ) 		 
									
			EndIf

		EndIf

	Next i

	//Grava as etapas da O.S.
	For i := 1 To Len(aStep)

		dbSelectArea("STQ")
		RecLock("STQ", .T.)
		STQ->TQ_FILIAL := xFILIAL("STQ")
		STQ->TQ_ORDEM  := cSOCode
		STQ->TQ_PLANO  := cSOPlan
		STQ->TQ_TAREFA := aStep[i][1]
		STQ->TQ_ETAPA  := aStep[i][2]
		STQ->TQ_SEQETA := aStep[i][3]
		MsUnlock("STQ")

	Next i

	RestArea(aArea)

Return aBlock

//------------------------------------------------------------------------------
/*/{Protheus.doc} fValCnt
Validações de contador.

@param cAsset, Caractere, Código do bem.
@param cDate, Caractere, Data do apontamento de contador.
@param cHour, Caractere, Hora do apontamento do contador.
@param nCounter, Numérico, Valor do contador.
@param nType, Numérico, Tipo de contador (1 ou 2).
@param lGetAsk, Lógico, Define se retorna perguntas.

@author Wexlei Silveira
@since 18/09/2018

@return aEror, Array, Lógico se o retorno é pergunta ou mensagem e
Descrição do erro ou vazio se não houver erros {lPergunta, cMensagem}.
/*/
//------------------------------------------------------------------------------
Static Function fValCnt(cAsset, cDate, cHour, nCounter, nType, lGetAsk)

	Local aRet   := {}
	Local aAcum  := {}
	Local nAcum  := 0
	Local nDtVar := 0
	Local aError := {.F., ""}
	Local aArea  := GetArea()

	// Posição de contador menor que zero
	If nCounter < 0
		aError := {.F., STR0076}
	EndIf

	// 3.3.1 - Não é permitido informar um valor de contador superior ao limite cadastrado na tabela ST9
	// 3.4.1 - Não é permitido informar um valor de contador superior ao limite cadastrado na tabela TPE
	If Empty(aError[2])

		aRet := CHKPOSLIM(cAsset, nCounter, nType, , .F.)
		If !aRet[1]
			aError := {.F., aRet[2]}
		EndIf

	EndIf

	// 3.3.2 - Não é permitido informar uma posição de contador inconsistente ao histórico de lançamentos
	// 3.4.2 - Não é permitido informar uma posição de contador 2 inconsistente ao histórico de lançamentos
	If aRet[1]

		aRet := NGCHKHISTO(cAsset, cDate, nCounter, cHour, nType, , .F.)
		If !aRet[1]
			aError := {.F., aRet[2]}
		EndIf

	EndIf

	// 3.3.3 - O usuário será alertado quando a posição de contador informado ultrapassar o limite de variação dia.
	If aRet[1]

		aAcum := NGACUMEHIS(cAsset, cDate, cHour, nType, "A")
		nAcum := aAcum[2] + (nCounter - aAcum[1])
		nDtVar := NGVARIADT(cAsset, cDate, nType, nAcum, .F., .T.)

		// 3.3.4 - O usuário será alertado quando a variação dia no intervalo ultrapassar o limite de variação estipulado para o bem nas tabelas STP e ST9.
		aRet := NGCHKLIMVAR(cAsset, NGSEEK("ST9", cAsset, 1, "T9_CODFAMI"), nType, nDtVar, .F., .F.)
		If !aRet[1]
			If lGetAsk
				aError := {.T., aRet[2]}
			EndIf
		EndIf

	EndIf

	// 3.4.3 - O usuário será alertado quando a variação dia no intervalo ultrapassar o limite de variação estipulado para o bem
	If aRet[1]

		aRet := NGVALIVARD(cAsset, nCounter, cDate, cHour, nType, .F.)
		If !aRet[1]
			If lGetAsk
				aError := {.T., aRet[2]}
			EndIf
		EndIf

	EndIf

	RestArea(aArea)

Return aError

//------------------------------------------------------------------------------
/*/{Protheus.doc} fQuestions
Grava campos de pesquisa para facilities

@author Maria Elisandra de paula
@since 27/09/2019
@param cSolic, string, Código da solicitação
@return Nil
/*/
//------------------------------------------------------------------------------
Static Function fQuestions( cSolic )

	Local aQuest  := {}

	//Retorna questionários
	aQuest := fRetQuesti( AllTrim( SuperGetMv( "MV_NGPESST",.F.,"" ) ), cSolic, .F., "" )
	If Len( aQuest ) > 0 .And. aQuest[4] <> "1" //Verifica se o Questionário está habilitado ou não (1=Sim;2=Não)
		MNT307QUE( .F., cSolic, .T. ) //Grava campos referente a pesquisa
	EndIf

Return

//------------------------------------------------------------------------------
/*/{Protheus.doc} isPending
Verifica se há pesquisa pendente para o usuário

@author Maria Elisandra de paula
@since 27/09/2019
@return boolean, se há pesquisa pendente para o usuário
/*/
//------------------------------------------------------------------------------
Static Function isPending()

	Local cCodUser  := RetCodUsr() // Retorna o Codigo do Usuario
	Local cAliasQry := GetNextAlias()
	Local lRet      := .F.

	If AllTrim( SuperGetMv("MV_NG1FAC", .F., "2") ) == "1" //facilities

		BeginSql Alias cAliasQry

			SELECT COUNT( TQB_SOLICI ) AS NClose
			FROM %table:TQB% TQB
			WHERE TQB.TQB_SOLUCA = 'E'
				AND TQB.TQB_CDSOLI = %Exp:cCodUser%
				AND TQB.TQB_SATISF <> '1'
				AND TQB.TQB_SEQQUE <> ' '
				AND TQB.TQB_FILIAL = %xFilial:TQB%
				AND TQB.%NotDel%

		EndSql

	Else

		BeginSql Alias cAliasQry

			SELECT COUNT( TQB_SOLICI ) AS NClose
			FROM %table:TQB% TQB
			INNER JOIN %table:TQ3% TQ3
				ON TQ3.TQ3_FILIAL = %xFilial:TQ3%
			  	AND TQB.TQB_CDSERV = TQ3.TQ3_CDSERV
				AND TQ3.%NotDel%
				AND TQ3.TQ3_PESQST = '1'
			  WHERE TQB.TQB_SOLUCA = 'E'
			    AND TQB.TQB_CDSOLI = %Exp:cCodUser%
			    AND TQB.TQB_PSAP = ' '
			    AND TQB.TQB_PSAN = ' '
				AND TQB.TQB_FILIAL = %xFilial:TQB%
				AND TQB.%NotDel%

		EndSql
	EndIf

	lRet := (cAliasQry)->NClose > 0

	(cAliasQry)->(dbCloseArea())

Return lRet
