#Include 'MNTA422.ch'
#Include 'Protheus.ch'
#INCLUDE "FWBrowse.ch"

Static lTarefa := .F.

//---------------------------------------------------------------------
/*/{Protheus.doc} MNTA422
Rotina de Apontamento de mão de obra

@author William Rozin Gaspar
@author Maria Elisandra
@since 12/10/2014
@version P12
@return Nil
/*/
//---------------------------------------------------------------------
Function MNTA422()

	Local aNGBeginPrm := {}
	Local oDlgPai, oPanel
	Local oFont14
	Local cMensHelp := ""

	If !FindFunction( 'MNTAmIIn' ) .Or. MNTAmIIn( 19, 95 )

		aNGBeginPrm := NGBeginPrm()

		oFont14 := TFont():New("Verdana",,14,,.T.,,,,.F.,.F.)

		//Parâmetro que define o código de ociosidade para incluir uma TTL
		Private cTipoHr :=  AllTrim(GetNewPar("MV_NGHROCI",""))

		Private oBarra
		Private cBarra		:= Space(Len(STQ->TQ_ORDEM+STQ->TQ_PLANO+STQ->TQ_TAREFA+STQ->TQ_ETAPA))
		Private cEtapaBar	:= Space(Len(STQ->TQ_ORDEM+STQ->TQ_PLANO+STQ->TQ_TAREFA+STQ->TQ_ETAPA)) //Código de barras da etapa
		Private cTarefaBar	:= Space(Len(STQ->TQ_ORDEM+STQ->TQ_PLANO+STQ->TQ_TAREFA)) //Código de barras da tarefa
		Private cCracha		:= Space(Len(ST1->T1_CRACHA)) //Código de matrícula do Colaborador

		If !Empty(cTipoHr)
			cMensHelp := STR0001 +  STR0002 // "Informe neste campo o código do crachá para iniciar o trabalho, ou terminar o expediente.expediente." # "Ao informar o código de barras da etapa, será necessário preencher o código do crachá posteriormente para iniciar uma atividade."
		Else
			cMensHelp := STR0002 // "Ao informar o código de barras da etapa, será necessário preencher o código do crachá posteriormente para iniciar uma atividade."
		EndIf

		Define MsDialog oDlgPai Title STR0003 From 000,000 To 180,450 Pixel //"Apontamento de Mão de Obra para Etapas"
			oPanel	:= TPanel():New(01,01,,oDlgPai,,,,,,338,30,.F.,.F.)
				oPanel:Align := CONTROL_ALIGN_ALLCLIENT

			@ 20,20 Say STR0004 OF oPanel Font oFont14 Color CLR_BLUE,CLR_WHITE Pixel //"CÓDIGO DE BARRAS - MOVIMENTAÇÃO DOS COLABORADORES"
			@ 52,20 Say STR0005 OF oPanel Font oFont14 Pixel //"Leitura:"
			@ 50,50 MsGet oBarra Var cBarra PICTURE "@!" SIZE 160,009 VALID ValidaBarra(cBarra) PIXEL OF oPanel

			oBtn := TBtnBmp2():New( 130, 385, 50,50,'tk_vertit_mdi.png',,,,{|| MNTC415() },oPanel,STR0026,,.T. )
			oBtn:lCanGotFocus := .F.

			oBarra:bHelp := { || ShowHelpCpo(STR0006, {cMensHelp},5, {},5)  }   // "Código de Barras"

			//Este botão foi criado para o campo de código (TGET) perder o foco e executar a validação (bValid)
			TButton():New(600,600,"", oDlgPai, {||},58,12,,,,.T.,,,,,,)

			//Inicializa o PlaceHold do TGet de código de barras
			LimpaBarra(1)

		ACTIVATE MSDIALOG oDlgPai Center ON INIT oBarra:SetFocus()

		NGRETURNPRM( aNGBeginPrm )

	EndIf

Return

//---------------------------------------------------------------------
/*/{Protheus.doc} ValidaBarra
Valida o código de barra digitado pelo usuário

@param cBarra - código de barra, que pode ser da etapa ou do crachá do Colaborador (T1_CRACHA)
@author  Maria Elisandra de Paula
@since   23/02/15
@version P12
/*/
//---------------------------------------------------------------------
Static Function ValidaBarra(cBarra)

	Local lRet		:= .F.
	Local cQuery 	:= ""
	Local cAliasQry	:= ""

	If Empty(cBarra)
		Return .f.
	EndIf

	If Len(Alltrim(cBarra)) <= Len(ST1->T1_CRACHA) // passou crachá
		dbSelectArea("ST1")
		dbSetorder(7)
		If dbSeek(xFilial("ST1")+ cBarra)
			If NGFUNCRH(ST1->T1_CODFUNC,.T.,)
				cCracha := cBarra

				//Se o código de ociosidade estiver preenchido, grava TTL - iniciando ou finalizando o dia
				If	!Empty(cTipoHr) .And. Empty(cEtapaBar)
					lRet := fFunTTL(ST1->T1_CODFUNC,1)
				ElseIf Empty(cTipoHr) .And. Empty(cEtapaBar) // passou somente crachá (ociosidade não estiver preenchido)
					fTimer(STR0007) // "Colaborador localizado, passe o código de barras da etapa."
					LimpaBarra(3)
				EndIf

				lRet := .T.
			Else		
				lRet := .f.
				LimpaTudo()
			EndIf
		Else
			fTimer(STR0017) //"Código de Barras inválido. Reinicie a operação."
			lRet := .f.
			LimpaTudo()
		EndIf
		//LimpaTudo()
		oBarra:SetFocus()
	Else
		lTarefa := Len(AllTrim(cBarra)) <= Len(cTarefaBar) // verifica se é um código de Tarefa
		cBarra := xFilial('STQ') + cBarra 
		//verifica se existe etapa independente se está deletada ou não
		cAliasQry := GetNextAlias()
		cQuery 	:= " SELECT TQ_ORDEM FROM " + RetSqlName('STQ')
		If lTarefa
			cQuery 	+= " WHERE TQ_FILIAL || TQ_ORDEM || TQ_PLANO || TQ_TAREFA = " + ValtoSql(cBarra)
		Else
			cQuery 	+= " WHERE TQ_FILIAL || TQ_ORDEM || TQ_PLANO || TQ_TAREFA || TQ_ETAPA = " + ValtoSql(cBarra)
		EndIf
		cQuery := ChangeQuery(cQuery)
		dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cAliasQry,.T.,.T.)

		If !Eof()
			
			cEtapaBar := cBarra

			//Verifica se Ordem de Serviço ainda está aberta
			dbSelectArea("STJ")
			dbSetOrder(1)
			If dbSeek(xFilial("STJ") + (cAliasQry)->TQ_ORDEM)
				If STJ->TJ_TERMINO == "N" .And. Empty(cCracha)

					If lTarefa
						fTimer(STR0027) //"Tarefa existente, passe seu Crachá!"
					Else
						fTimer(STR0008) //"Etapa existente, passe seu Crachá!"
					EndIf

					LimpaBarra(2)
					lRet := .T.
				ElseIf STJ->TJ_TERMINO == "S"
					fTimer(STR0009) // "Ordem de Serviço já finalizada. Reinicie a operação e informe outra Etapa."
					lRet := .F.
					LimpaTudo()

				EndIf
			EndIf
		Else
			fTimer(STR0017) //"Código de Barras inválido. Reinicie a operação."
			lRet := .F.
			LimpaTudo()
		EndIf

		(cAliasQry)->(dbCloseArea())

	EndIf

	//Caso o código da etapa e do crachá já tenham sido preenchidos
	If !Empty(cEtapaBar) .And. !Empty(cCracha)

		dbSelectArea("ST1")
		dbSetorder(7)
		If dbSeek(xFilial("ST1")+ cCracha)

			//verifica se existe etapa independente se está deletada ou não
			cAliasQry := GetNextAlias()
			cQuery 	:= " SELECT TQ_ORDEM,TQ_PLANO,TQ_TAREFA,TQ_ETAPA, TQ_OK  FROM " + RetSqlName('STQ')
			If lTarefa
				cQuery 	+= " WHERE TQ_FILIAL || TQ_ORDEM || TQ_PLANO || TQ_TAREFA = " + ValtoSql(cEtapaBar)
			Else
				cQuery 	+= " WHERE TQ_FILIAL || TQ_ORDEM || TQ_PLANO || TQ_TAREFA  || TQ_ETAPA = " + ValtoSql(cEtapaBar)
			EndIf
			cQuery := ChangeQuery(cQuery)
			dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cAliasQry,.T.,.T.)
			If !Eof()
				If Empty((cAliasQry)->TQ_OK) // somente etapas que não estão concluídas
					If lTarefa
						lRet := fAbrFech(ST1->T1_CODFUNC,(cAliasQry)->TQ_ORDEM,(cAliasQry)->TQ_PLANO,;
										(cAliasQry)->TQ_TAREFA)
					Else
						lRet := fAbrFech(ST1->T1_CODFUNC,(cAliasQry)->TQ_ORDEM,(cAliasQry)->TQ_PLANO,;
										(cAliasQry)->TQ_TAREFA,(cAliasQry)->TQ_ETAPA)
					EndIf
				Else
					fTimer(STR0025)//"Esta etapa já está concluída. Reinicie a operação."
					lRet := .F.
				EndIf
				LimpaTudo()
			EndIf

			(cAliasQry)->(dbCloseArea())

		EndIf
	EndIf

	oBarra:Refresh(.t.)
Return lRet

//---------------------------------------------------------------------
/*/{Protheus.doc} LimpaTudo
Limpa variáveis

@author William Rozin Gaspar
@since 12/10/2014
@version P12
@return Nil
/*/
//---------------------------------------------------------------------
Static Function LimpaTudo()
	cCracha	:= Space(Len(ST1->T1_CRACHA))
	cEtapaBar 	:= Space(Len(STQ->TQ_ORDEM+STQ->TQ_PLANO+STQ->TQ_TAREFA+STQ->TQ_ETAPA))
	LimpaBarra(1)
Return Nil

//---------------------------------------------------------------------
/*/{Protheus.doc} fTimer(cMensagem)
Monta Tela de Mensagem com Timer

@param cMensagem - Mens.  a aparecer na tela de timer
@author Maria Elisandra de Paula
@since 22/08/2014
@version P11
@return Nil
/*/
//---------------------------------------------------------------------
Static Function fTimer(cMensagem, cMensagem2)


	Local oDlgTimer
	Local oTFont, oTSay, oTFont2
	Local oTimer
	Local nTam 	:= 50
	Local lCenter := .T.
	Default cMensagem2 := ""

	If !Empty(cMensagem2)
		lCenter := .f.
		nTam := 20
	EndIf

	DEFINE MSDIALOG oDlgTimer TITLE STR0010 FROM 0,0 TO 150,600 PIXEL //"Atenção"

		oTimer := TTimer():New(3000, {|| oDlgTimer:End() }, oDlgTimer )
			oTimer:Activate()

		oTFont := TFont():New('verdana'/*cName */,0 /* nWidth */, -20 ,,.f. /*lBold*/,,,,,.f. /*lUnderline*/, .f. /*lItalic*/)
		oTFont2 := TFont():New('verdana'/*cName */,0 /* nWidth */, -15 ,,.f. /*lBold*/,,,,,.f. /*lUnderline*/, .f. /*lItalic*/)

		oTSay := TSay():New( 10,05,{||cMensagem},oDlgTimer,,oTFont,lCenter,.f.,.f.,.T.,0,,280,nTam,.F.,.T.,.F.,.F.,.F.,.F. )

		If !Empty(cMensagem2)
			TSay():New( 30,10,{||cMensagem2},oDlgTimer,,oTFont2,.f.,.f. 	,.f. 	,.T.,0,,280,40,.F.,.T.,.F.,.F.,.F.,.F. )
		EndIf

	ACTIVATE MSDIALOG oDlgTimer CENTERED
Return .T.

//---------------------------------------------------------------------
/*/{Protheus.doc} fFunTTL()
Processa dados ao informar crachá

@Param 	cMatric - Matricula
@Param 		nTipo - 1 - passou somente o crachá (inicia ou finaliza o dia)
			nTipo - 2 - já passou o código de barra da etapa e depois o crachá

@author  Maria Elisandra de Paula
@since   23/02/15
@version P12
/*/
//---------------------------------------------------------------------
Static Function fFunTTL(cMatric,nTipo)

	Local lRet    := .F.
	Local cCALE   := ""
	Local cHoraAt := SubString(Time(),1,5)
	Local dDataAt := Date()
	Local cQuery	:= ""
	Local cAliasQry := GetNextAlias()
	Local aEtapa 	:= {}
	Local cTimer	:= ""
	Local cTimer2 	:= ""
	Local cUsaCale	:= ""

	//variável utilizada na função NGCALEINTD
	Local lCALE := .f.

	If !Empty(cTipoHr) // Se empresa trabalha com Ociosidade

		//Verifica se usa calendário
		dbSelectArea("TTJ")
		dbSetOrder(1)
		If dbSeek(xFilial("TTJ")+ cTipoHr)
			cUsaCale := TTJ->TTJ_USACAL
		EndIf

		dbSelectArea("ST1")
		dbSetOrder(01)
		If dbSeek(xFilial("ST1")+ cMatric)
			cCALE := ST1->T1_TURNO
		Endif
		//Verifica se o Colaborador está trabalhando em alguma etapa de qualquer ordem de serviço
		If nTipo == 1
			aEtapa := NGVLDSTL3(cMatric)
		EndIf

		If Len(aEtapa) == 0 // se colaborador não está trabalhando em nenhuma etapa

			// busca último registro da TTL do Colaborador
			cQuery := 	" SELECT R_E_C_N_O_, TTL_DTFIM, TTL_HRFIM  FROM " + RETSQLNAME('TTL')
			cQuery += 	"  WHERE TTL_DTINI||TTL_HRINI = "
			cQuery += 	"  ( SELECT  MAX (TTL_DTINI||TTL_HRINI) FROM " + RETSQLNAME('TTL')
			cQuery += 	"  WHERE TTL_CODFUN = " + ValtoSql(cMatric)
			cQuery += 	"  AND TTL_FILIAL = " + ValToSql(xFilial('TTL'))
			cQuery += 	"  AND D_E_L_E_T_ <> '*'  )"
			cQuery += 	"  AND D_E_L_E_T_ <> '*' AND TTL_FILIAL = " + ValToSql(xFilial('TTL')) + " AND TTL_CODFUN = " + ValtoSql(cMatric)

			cQuery := ChangeQuery(cQuery)
			dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cAliasQry,.T.,.T.)

			dbSelectArea(cAliasQry)

			//EOF - Se não existir registro na TTL será fim de arquivo

			If Eof() .Or. (!Eof() .And. !Empty((cAliasQry)->TTL_DTFIM) .and. !Empty((cAliasQry)->TTL_HRFIM))


				/*Se Data+Hora Inicio = Data+Hora Fim = Data+Hora atual
				Ex: se o Colaborador passar o crachá, irá gerar um TTL, ao sair, irá preencher a data+hora fim
				Caso ele passe novamente o crachá no mesmo dia e hora+minuto, ao invés de gerar novo registro, ele irá modificar o já existente
				Não ocorrendo erro.log por chave duplicada*/
				dbSelectArea("TTL")
				dbSetOrder(1)
				If dbSeek(xFilial("TTL")+ cMatric + DTOS(dDataAt)+ cHoraAt + DTOS(dDataAt)+ cHoraAt )

					RecLock("TTL", .F.)
					TTL->TTL_DTFIM  := CTOD("  /  /  ")
					TTL->TTL_HRFIM  := ""
					MsUnlockAll()

					If nTipo == 1
						fTimer(STR0011) //"Colaborador disponível para execução de Etapas"
					EndIf
				Else
					RecLock("TTL", .T.)
					TTL->TTL_FILIAL := xFilial("TTL")
					TTL->TTL_CODFUN := cMatric
					TTL->TTL_TPHORA := cTipoHr
					TTL->TTL_DTINI  := dDataAt
					TTL->TTL_HRINI  := cHoraAt
					TTL->TTL_TIPOHO := "S"
					MsUnlockAll()

					If nTipo == 1
						fTimer(STR0011) //"Colaborador disponível para execução de Etapas"
					EndIf

				EndIf

			Else

				dbSelectArea("TTL")
				dbGoto((cAliasQry)->R_E_C_N_O_)
				RecLock("TTL", .F.)
				TTL->TTL_DTFIM  := dDataAt
				TTL->TTL_HRFIM  := cHoraAt
				TTL->TTL_QUANTI := MNTA422CAL(TTL->TTL_DTINI,TTL->TTL_HRINI,TTL->TTL_DTFIM,TTL->TTL_HRFIM,cCALE,cUsaCale == "S")

				MsUnlockAll()

				If nTipo == 1
					fTimer(STR0012) //"Colaborador finalizando o dia."
					oBarra:SetFocus()
				EndIf
			EndIf

			(cAliasQry)->(dbCloseArea())

			lRet := .T.
		Else

			cTimer := STR0013 + aEtapa[1] + CRLF   //"Você não finalizou a Etapa da OS  "
			cTimer2:= STR0014 + AllTrim(aEtapa[4]) + " - " + aEtapa[7] + CRLF //" Etapa: "
	  		cTimer2+= STR0015 + AllTrim(aEtapa[3]) + " - " + aEtapa[6] + CRLF //" Tarefa:   "
			cTimer2+= STR0016 + AllTrim(aEtapa[2]) + " - " + aEtapa[5] + CRLF //" Veículo: "

			fTimer(cTimer,cTimer2)
		EndIf
	EndIf
	LimpaTudo()
	oBarra:Refresh(.t.)
	oBarra:SetFocus()
Return lRet

//---------------------------------------------------------------------
/*/{Protheus.doc} fAbrFech()
Função para abrir ou fechar insumo(STL)
@param 	cCodFunc	- executante da etapa
		cOrdem - Código da ordem de serviço
		cPlano - Código do Plano
		cTarefa - Código da tarefa a ser fechada ou iniciada
		cEtapa - Código da etapa

@author Maria Elisandra de Paula
@since 20/08/2014
@version P11
@return Nil
/*/
//---------------------------------------------------------------------
Static Function fAbrFech(cCodFunc,cOrdem,cPlano,cTarefa,cEtapa)

	Local cQuery 	:= " "
	Local cAliasQry := GetNextAlias()
	Local aEtapa 	:= {}
	Local cTimer	:= ""
	Local cTimer2	:= ""
	Local nRecno 	:= 0
	Local cHiniSTL	:= ""
	Local dDiniSTL
	Local nQuantiSTL:= 0
	Local cSeqRela	:= '0'

	Local dData 	:= Date()
	Local cHora 	:= SubString(Time(),1,5)
	Local lRet		:= .f.

	Local lDisponiv := If(!Empty(cTipoHr) , VerDispo(cCodFunc) , .t.) //verifica disponibilidade na TTL
	Local nRecnoTTL := 0

	Default cEtapa 	:= ''

	//verifica se colaborador esta em execução em outra Etapa/Tarefa da mesma ordem
	aEtapa := NGVLDSTL3(cCodFunc,cOrdem,cPlano,cTarefa,cEtapa)

	If Len(aEtapa) == 0
	    //query verifica se a etapa já está aberta para o colaborador
	    cQuery += " SELECT R_E_C_N_O_ AS RECNO"
	    cQuery += " FROM " + RETSQLNAME('STL')
	    cQuery += " WHERE TL_ORDEM  = " + ValtoSql(cOrdem)
		cQuery += "   AND TL_PLANO = " + ValtoSql(cPlano)
	    cQuery += "   AND TL_TAREFA = " + ValtoSql(cTarefa)
		If !lTarefa
	    	cQuery += "   AND TL_ETAPA  = " + ValtoSql(cEtapa)
		EndIf
	    cQuery += "   AND TL_CODIGO  = " + ValtoSql(cCodFunc)
	    cQuery += "   AND TL_TIPOREG = 'M' AND TL_SEQRELA <> '0'"
	    cQuery += "   AND TL_DTFIM  = TL_DTINICI "
	    cQuery += "   AND TL_HOFIM  = TL_HOINICI "
	    cQuery += "   AND TL_FILIAL = " + ValtoSql(xFilial('STL'))
	    cQuery += "   AND D_E_L_E_T_ <> '*' "
	    cQuery := ChangeQuery( cQuery )
	    dbUseArea( .T. , "TOPCONN" , TcGenQry( , , cQuery ) , cAliasQry , .T. , .T.  )

	    If !EoF()
	        nRecno := (cAliasQry)->RECNO
	    EndIf

	    (cAliasQry)->(dbCloseArea())

		//Se existir STL finaliza etapa aberta (preenchendo os campos de data e hora )
		If !Empty(nRecno)

			If !lTarefa

				//Se a etapa(STQ) estive deletada, reabre para fechar a execução do insumo
				dbSelectArea("STQ")
				dbSetOrder(1)
				If !dbSeek(xFilial("STQ")+ cOrdem + cPlano + cTarefa + cEtapa )

				RecLock("STQ", .t.)
				STQ->TQ_FILIAL 	:= xFilial("STQ")
				STQ->TQ_ORDEM 	:= cOrdem
				STQ->TQ_PLANO 	:= cPlano
				STQ->TQ_TAREFA := cTarefa
		    	STQ->TQ_ETAPA  := cEtapa
				STQ->(MsUnlock())

				Endif

			Endif

			dbSelectArea("STL")
			dbSetOrder(01)
			dbGoTo(nRecno)

			If STL->TL_DTINICI == dData .AND. STL->TL_HOINICI  == substr(cHora,1,5)
				/*
				Se a Etapa for iniciada e finalizada no mesmo minuto que abriu entende- se que foi um erro e por isso será excluída
				*/

				cTimer := STR0021 // "Etapa fechada com tempo de execução menor que um minuto."
				lRet := .T.

				Reclock("STL", .F.)
				dbDelete()
				MsUnlock("STL")

				If  !Empty(cTipoHr)
					fFunTTL(cCodFunc,1)	// realizada operações de ociosidade
				EndIf
			Else
				If !Empty(cTipoHr)
					//Retorna último registro da TTL
					nRecnoTTL := fRecNoTTL(cCodFunc)
				EndIf

				cHiniSTL 	:= STL->TL_HOINICI
				dDiniSTL 	:= STL->TL_DTINICI

				//Valida se houve apontamento de insumo por outra rotina no intervalo de hora
				lRet := NGVALDATIN(cCodFunc,cOrdem,cPlano,dDiniSTL,cHiniSTL,dData,cHora,"M",STL->(RECNO()),"STL",,,If(nRecnoTTL <> 0,nRecnoTTL,nil))[1]

				//calcula a quantidade de tempo na etapa
				nQuantiSTL 	:= NGQUANTIHOR('M','H',STL->TL_DTINICI,STL->TL_HOINICI,dData,cHora,'N')

				If lRet
					// deleta registro existente com data e hora inicio igual a data e hora fim
					Reclock("STL", .F.)
					dbDelete()
					MsUnlock("STL")

					lRet:=	NGRETINS(	cOrdem,; 	//PORDEM
										cPlano,;	//PPLANO
										"C",;		//PTIPO
										"",;		//PCODBEM
										"",;		//PSERVICO
										,;			//PSEQ
										cTarefa,;	//PTAREFA
										"M",;		//PTIPOINS
										cCodFunc,;	//PCODIGO
										nQuantiSTL,;//PQUANTID
										'H',;		//PUNIDADE
										"",;		//PDESTINO
										'88888',;	//PDESCRIC
										dDiniSTL,;	//PDATAINI
										cHiniSTL,;	//PHORAINI
										"F",;		//PGERAFES
										,;			//PLOCAL
										,;			//PLOTEC
										,;			//PNUMLOTE
										,;			//PDTVALID
									)				//PLOCALIZ*/

					If lRet 
						If !lTarefa
							Reclock("STL", .F.)
							STL->TL_ETAPA		:= cEtapa
							MsUnlock("STL")
						EndIf
						cTimer := IIf( lTarefa, STR0031, STR0022 ) // "Você acaba de fechar esta Tarefa. "###"Você acaba de fechar esta Etapa. "

						If  !Empty(cTipoHr)
							fFunTTL(cCodFunc,2)	// realiza operações de ociosidade
						EndIf
					EndIf
				EndIf
			EndIf
		Else //Se não existir STL aberta para o mesmo colaborador Gera STL (deixando hora e data fim igual inicial )

			//Valida se houve apontamento de insumo por outra rotina no intervalo de hora
			If 	lRet := NGVALDATIN(cCodFunc,cOrdem,cPlano,dData,cHora,dData,cHora,"M",,"STL",,,If(nRecnoTTL <> 0,nRecnoTTL,nil))[1]

                dbSelectArea("STQ")
                dbSetOrder(1)
                If dbSeek(xFilial("STQ")+ cOrdem + cPlano + cTarefa + cEtapa )
                    If lDisponiv // disponibilidade para executar etapas

                        lRet := .t.

                        //variáveis utilizadas na função ULTSEQ

                        M->TL_ORDEM := cOrdem
                        M->TL_PLANO := cPlano
                        M->TJ_ORDEM := cOrdem
                        M->TJ_PLANO := cPlano

						cSeqRela	:= ULTSEQ()

						//Abre insumo OS com os campos data e hora fim  igual inicial
						dbSelectArea("STL")
						Reclock("STL", .t.)
						STL->TL_FILIAL	:= xFilial("STL")
						STL->TL_ORDEM	:= cOrdem
						STL->TL_PLANO	:= cPlano
						STL->TL_TAREFA	:= cTarefa
						STL->TL_SEQRELA	:= cSeqRela
						STL->TL_TIPOREG	:= "M"
						STL->TL_CODIGO	:= cCodFunc
						STL->TL_DTINICI	:= dData
						STL->TL_HOINICI	:= cHora
						STL->TL_USACALE  := "N"
						STL->TL_DTFIM 	:= dData
						STL->TL_HOFIM 	:= cHora
						STL->TL_QUANTID	:= 00000
						STL->TL_ETAPA	:= cEtapa
						STL->TL_UNIDADE	:= "H"
						MsUnlock()

						cTimer := IIf( lTarefa, STR0028, STR0023 ) //"Você acaba de iniciar esta Tarefa para trabalhar !"###"Você acaba de iniciar esta Etapa para trabalhar !"

						If  !Empty(cTipoHr)
							fFunTTL(cCodFunc,2)	// realizada operações de ociosidade
						EndIf
					Else
						cTimer := IIf( lTarefa, STR0029, STR0024 )// "Colaborador não está disponível para executar Tarefas."###"Colaborador não está disponível para executar Etapas."
						lRet := .F.
					EndIf
				Else
					cTimer := STR0017 //"Código de Barras inválido. Reinicie a operação."
					lRet := .f.
					LimpaTudo()

				EndIf
			Else
				LimpaTudo()
				oBarra:Refresh(.t.)
			EndIf
		EndIf
	Else
		If lTarefa
			cTimer := STR0030 + aEtapa[1] + CRLF  //"Você não finalizou a Tarefa da OS  "
			cTimer2+= STR0015 + AllTrim(aEtapa[3]) + " - " + aEtapa[6] + CRLF //" Tarefa:   "
			cTimer2+= STR0016 + AllTrim(aEtapa[2]) + " - " + aEtapa[5] + CRLF //" Veículo: "
		Else
			cTimer := STR0013 +aEtapa[1] + CRLF  //"Você não finalizou a Etapa da OS  "
			cTimer2:= STR0014 + AllTrim(aEtapa[4]) + " - " + aEtapa[7] + CRLF //" Etapa: "
			cTimer2+= STR0015 + AllTrim(aEtapa[3]) + " - " + aEtapa[6] + CRLF //" Tarefa:   "
			cTimer2+= STR0016 + AllTrim(aEtapa[2]) + " - " + aEtapa[5] + CRLF //" Veículo: "
		EndIf

		lRet := .f.

	EndIf
	//Apresenta mensagem ao usuário
	If !Empty(cTimer)
		If lRet
			fTimer(cTimer,cTimer2)
			LimpaBarra(1)
		Else
			fTimer(cTimer,cTimer2)
			LimpaTudo()
			oBarra:Refresh(.t.)

		EndIf
	EndIf
Return lRet

//---------------------------------------------------------------------
/*/{Protheus.doc} LimpaBarra(nMens)
Altera mensasgem do campo barra

@param nMens 	1 - primeira mensagem genérica : Informe o código de barras do seu crachá ou da etapa.
				2 - após passar somente a etapa.
				3 - após passar somente o crachá(apenas para quando não trabalha com ociosidade).
@author Maria Elisandra de Paula
@since 19/06/2015
@version P12
@return Nil
/*/
//---------------------------------------------------------------------
Static Function LimpaBarra(nMens)

	Default nMens := 1

	cBarra:= Space(24)
	oBarra:Refresh(.t.)

	If nMens == 1
		oBarra:cPlaceHold := STR0019 //"Informe o código de barras do seu crachá ou da etapa."
	ElseIf nMens == 2
		oBarra:cPlaceHold := STR0020 //"Informe o código de barras do seu crachá."
	Else
		oBarra:cPlaceHold := STR0018 //"Informe o código de barras da etapa."
	EndIf

	oBarra:SetFocus()
Return nil

//---------------------------------------------------------------------
/*/{Protheus.doc} VerDispo(cMatric)
Verifica disponibilidade

@param cMatric - Matricula do funcionario
@author Maria Elisandra de Paula
@since 06/05/2015
@version P12
@return Nil
/*/
//---------------------------------------------------------------------

Static Function VerDispo(cMatric)

	Local dDataAt   := Date()
	Local cQuery 	:= ""
	Local cAliasQry := GetNextAlias()
	Local lRet      := .F.

	cQuery := 	" SELECT TTL_DTFIM, TTL_HRFIM  FROM " + RETSQLNAME('TTL')
	cQuery += 	"  WHERE TTL_DTINI||TTL_HRINI = "
	cQuery += 	"  ( SELECT  MAX(TTL_DTINI||TTL_HRINI)  FROM " + RETSQLNAME('TTL')
	cQuery += 	"  WHERE TTL_CODFUN = " + ValtoSql(cMatric)
	cQuery += 	"  AND TTL_FILIAL = " + ValToSql(xFilial('TTL'))
	cQuery += 	"  AND D_E_L_E_T_ <> '*'  )"
	cQuery += 	"  AND D_E_L_E_T_ <> '*' AND TTL_FILIAL = " + ValToSql(xFilial('TTL')) + " AND TTL_CODFUN = " + ValtoSql(cMatric)

	cQuery := ChangeQuery(cQuery)
	dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cAliasQry,.T.,.T.)

	dbSelectArea(cAliasQry)

	If !Eof()  .And. Empty((cAliasQry)->TTL_DTFIM) .and. Empty((cAliasQry)->TTL_HRFIM)
		lRet := .T.
	EndIf
	(cAliasQry)->(dbCloseArea())

Return lRet

//---------------------------------------------------------------------
/*/{Protheus.doc} fRecnoTTL(cMatric)
Verifica último registro da TTL

@param 	cMatric - Matricula do funcionário a ser utilizado
@author Maria Elisandra de Paula
@since 07/12/2015
@version P12
@return Nil
/*/
//---------------------------------------------------------------------
Static Function fRecnoTTL(cMatricula)

	Local cQuery 	:= ""
	Local cAliasQry := GetNextAlias()
	Local nRet

	cQuery := 	" SELECT R_E_C_N_O_ FROM " + RETSQLNAME('TTL')
	cQuery += 	"  WHERE TTL_DTINI||TTL_HRINI = "
	cQuery += 	"  ( SELECT  MAX (TTL_DTINI||TTL_HRINI) FROM " + RETSQLNAME('TTL')
	cQuery += 	"  WHERE TTL_CODFUN = " + ValtoSql(cMatricula)
	cQuery += 	"  AND TTL_FILIAL = " + ValToSql(xFilial('TTL'))
	cQuery += 	"  AND D_E_L_E_T_ <> '*'  )"
	cQuery += 	"  AND D_E_L_E_T_ <> '*' AND TTL_FILIAL = " + ValToSql(xFilial('TTL')) + " AND TTL_CODFUN = " + ValtoSql(cMatricula)

	cQuery := ChangeQuery(cQuery)
	dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cAliasQry,.T.,.T.)
	dbSelectArea(cAliasQry)

	If !Eof()
		nRet := (cAliasQry)->R_E_C_N_O_
	EndIf
	(cAliasQry)->(dbCloseArea())
Return nRet

//---------------------------------------------------------------------
/*/{Protheus.doc} MNTA422CAL()
Cálculo da quantidade de horas
//cópia da NGCALEINTD, mas sem utilizar a  STL
@param 	dDTIV - Data Inicial
		hHIVV - Hora Inicial
		dDTFV - Data Final
		hHFVV - hora Final
		cCALEV- Calendário
		lCALE - Se o tipo de horas utiliza calendário

@author Maria Elisandra de Paula
@since 07/12/2015
@version P12
@return Nil
/*/
//---------------------------------------------------------------------
Static Function MNTA422CAL(dDTIV,hHIVV,dDTFV,hHFVV,cCALEV,lCALE)

	Local nQTDF := 0

	If lCALE
	   nQTDF := NGCALENHORA(dDTIV,hHIVV,dDTFV,hHFVV,cCALEV)
	ElseIf GETMV("MV_NGUNIDT") = "D"
	   nQTDF := NGCALCH100(dDTIV,hHIVV,dDTFV,hHFVV)
	Else
	   nQTDF := NGCALCH060(dDTIV,hHIVV,dDTFV,hHFVV)
	EndIf

Return nQTDF
