#Include "MNTA693.ch"
#Include "PROTHEUS.CH"

#Define _cBemTran_	AllTrim( GetNewPar('MV_NGBEMTR', '') )
#Define _lObrigOS_	AllTrim( GetNewPar('MV_NGINFOS', '') ) == "1"

//Define posições do Array de Criação do TRB
#DEFINE _nPosTRB 1
#DEFINE _nPosCps 2
#DEFINE _nPosIdx 3
#DEFINE _nPosAls 4
#DEFINE _nPosVld 5

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Programa  ³ MNTA693  ³ Autor ³Vitor Emanuel Batista ³ Data ³02/09/2010³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³Transferencia de Bens entre Empresa e Filiais               ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³CONSTRUCAO CIVIL                                             ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function MNTA693()

	Local oBrowse
	Local aNGBeginPrm := NGBeginPrm()

	If !FindFunction( 'MNTAmIIn' ) .Or. MNTAmIIn( 19, 95 )
		//----------------------------------------------------------------------
		// As variáveis aRotina e cCadastro são utilizadas na função MsDocument
		// no fonte MATXFUNC, não retirá-las!
		//----------------------------------------------------------------------
		Private aRotina   := {}
		Private cCadastro := OemToAnsi(STR0001) //"Transferência de Bens"
		Private cFilLogad	:= xFilial()
		Private TipoAcom	:= .F.
		Private TipoAcom2	:= .F.
		Private lFuncCont2  := FindFunction("MNTCont2")

		If !MntCheckCC("MNTA683") .Or. !fValParam()
			Return .F.
		EndIf

		oBrowse := FWMBrowse():New()

		oBrowse:SetAlias( "TQ2" )			// Alias da tabela utilizada
		oBrowse:SetMenuDef( "MNTA693" )		// Nome do fonte onde está a função MenuDef
		oBrowse:SetDescription( STR0001 )	// Descrição do browse

		oBrowse:AddLegend( "TQ2->TQ2_STATUS = '1'", "RED"   , "Pendente Nota Fiscal" )
		oBrowse:AddLegend( "TQ2->TQ2_STATUS = '2'", "YELLOW", "Pendente Confirmação" )
		oBrowse:AddLegend( "TQ2->TQ2_STATUS = '3'", "GREEN" , "Confirmado" )

		oBrowse:SetFilterDefault("!Empty( TQ2->TQ2_EMPDES ) .And.!Empty( TQ2->TQ2_EMPORI )")

		oBrowse:Activate()

		NGReturnPrm(aNGBeginPrm)

		NgPrepTbl({ {"ST9"}, {"CTT"}, {"SHB"} }, cEmpAnt)

	EndIf

Return

//---------------------------------------------------------------------
/*/{Protheus.doc} MenuDef
Opções de menu

@return aRotina - Estrutura
@obs [n,1] Nome a aparecer no cabecalho
[n,2] Nome da Rotina associada
[n,3] Reservado
[n,4] Tipo de Transação a ser efetuada:
1 - Pesquisa e Posiciona em um Banco de Dados
2 - Simplesmente Mostra os Campos
3 - Inclui registros no Bancos de Dados
4 - Altera o registro corrente
5 - Remove o registro corrente do Banco de Dados
6 - Alteração sem inclusão de registros
7 - Cópia
8 - Imprimir
[n,5] Nivel de acesso
[n,6] Habilita Menu Funcional

@author Pedro Henrique Soares de Souza
@since 01/09/2015
/*/
//---------------------------------------------------------------------
Static Function MenuDef()

	Local lPyme   := IIf( Type("__lPyme") <> "U", __lPyme, .F. )

	aRotina := { 	{ STR0004, "PesqBrw"  , 0, 1 },;	//"Pesquisar"
	{ STR0005, "MNT693IN" , 0, 2 },;	//"Visualizar"
	{ STR0006, "MNT693IN" , 0, 3 },;	//"Incluir"
	{ STR0007, "MNT693IN" , 0, 4 },;	//"Alterar"
	{ STR0008, "MNT693IN" , 0, 5,3},;	//"Excluir"
	{ STR0009, "MNT693IN" , 0, 6 },;	//"Confirmar"
	{ STR0010 ,"MNT693LEG", 0, 4,,.F.}} //"Legenda"

	If !lPyme
		aAdd( aRotina, {"Conhecimento", "MsDocument", 0, 4 } )
	EndIf

Return aRotina
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³MNT693IN   ³ Autor ³Vitor Emanuel Batista  ³ Data ³03/09/2010³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³Inclusao,Alteracao,Exclusao e Confirmacao da Transferencia  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³CONSTRUCAO CIVIL                                             ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function MNT693IN(cAlias, nRecno, nOpcao)

	Local cQryAlias, cQuery
	Local aPerg   	:= {}
	Local cPerg   	:= "MNTA693"
	Local nOpcCad := nOpcao

	Private aTRBs := {} //Array Para salvar Tabelas Temporárias
	Private cTRBGRV := GetNextAlias()  //oTmpTbl1  || Inconsistencias
	Private cTRB 	:= GetNextAlias()  //oTmpTbl2  || ST9 (BEM)
	Private cTRBDA3 := GetNextAlias()  //oTmpTbl3  || DA3 (Veiculos)
	Private cTRBSTB := GetNextAlias()  //oTmpTbl4  || STB (Detalhes do Bem)
	Private cTRBTPY := GetNextAlias()  //oTmpTbl5  || TPY (Peças de Reposição do Bem)
	Private cTRBTQS := GetNextAlias()  //oTmpTbl6  || TQS (Complemento bem - Pneus)
	Private cTRBAC9 := GetNextAlias()  //oTmpTbl7  || AC9 (Relação de Objetos x Entidades)
	Private cTRBACB := GetNextAlias()  //oTmpTbl8  || ACB (Banco de Conhecimento)
	Private cTRBACC := GetNextAlias()  //oTmpTbl9  || ACC (Palavras Chave)
	Private cTRBTPN := GetNextAlias()  //oTmpTbl10 || TPN (Utilização de Bens)
	Private cTRBTPE := GetNextAlias()  //oTmpTbl11 || TPE (Segundo Contador do Bem)
	Private cTRBSTC := GetNextAlias()  //oTmpTbl12 || STC (Estrutura)
	Private cTRBSTZ := GetNextAlias()  //oTmpTbl13 || STZ (Movimentação de Bens)
	Private cTRBSTF := GetNextAlias()  //oTmpTbl14 || STF (Manutenção)
	Private cTRBST5 := GetNextAlias()  //oTmpTbl15 || ST5 (Tarefas da Manutenção)
	Private cTRBSTM := GetNextAlias()  //oTmpTbl16 || STM (Dependências da Manutenção)
	Private cTRBSTG := GetNextAlias()  //oTmpTbl17 || STG (Detalhes da Manutenção)
	Private cTRBSTH := GetNextAlias()  //oTmpTbl18 || STH (Etapas da Manutenção)
	Private cTRBTP1 := GetNextAlias()  //oTmpTbl19 || TP1 (Opções da Etapa de Manutenção)
	Private cTRBTT8 := GetNextAlias()  //oTmpTbl20 || TT8 (Tanque do Bem)
	Private cTRBTS3 := GetNextAlias()  //oTmpTbl21 || TS3 (Veiculos Penhorados)
	Private cTRBTSJ := GetNextAlias()  //oTmpTbl22 || TSJ (Leasing de Veiculos)
	Private bNGGrava := {|| GravaTQ2()}
	Private lCONFIRM := ( nOpcao == 6 )

	//----------------------------------------------
	//Valida preenchimento do campo Nota Fiscal
	//----------------------------------------------
	If nOpcao == 6 .And. Empty(TQ2->TQ2_NOTFIS)

		ShowHelpDlg( STR0011, { STR0012 }, 1, { STR0013 }, 1 )

		//"Atenção" ## "Não é possível confirmar a solicitação de transferência sem o preenchimento da Nota Fiscal."
		//"Altere o registro informando o campo Nota Fiscal."

		Return .F.

	ElseIf nOpcao != 2 .And. nOpcao != 3 .And. TQ2->TQ2_STATUS == '3'

		ShowHelpDlg( STR0011,	{ STR0014 }, 1, { STR0015 }, 1 )

		//"Atenção" ## "Não é possível alterar uma Transferência já confirmada." ## "Escolha a opção Incluir."

		Return .F.
	EndIf

	If nOpcao == 4 .Or. nOpcao == 6

		dbSelectArea("ST9")
		dbSetOrder(01)
		If dbSeek(xFilial("ST9",TQ2->TQ2_FILORI) + TQ2->TQ2_CODBEM)
			TipoAcom  := ST9->T9_TEMCONT == "S"
			If !lFuncCont2
				TipoAcom2 := TPE->( dbSeek(xFilial("TPE",TQ2->TQ2_FILORI) + ST9->T9_CODBEM) )
			Else
				TipoAcom2 := MNTCont2(TQ2->TQ2_FILORI, TQ2->TQ2_CODBEM)
			EndIf

		EndIf

		NgPrepTbl({ {"ST9"} }, TQ2->TQ2_EMPORI)
		NgPrepTbl({ {"CTT"}, {"SHB"} }, TQ2->TQ2_EMPDES)

	Else

		If nOpcao == 3 .Or. (nOpcao == 5 .And. TQ2->TQ2_STATUS = '1')
			aChoice := NGCAMPNSX3("TQ2", {"TQ2_NOTFIS", "TQ2_SERIE", "TQ2_EMAIL2"})
		EndIf

		TipoAcom := .F.
		TipoAcom2:= .F.

	EndIf

	nOpcCad := IIf( nOpcao == 6, 4, nOpcao )

	If NGCAD01(cAlias, nRecno, nOpcCad) == 1

		If nOpcao == 4 .Or. nOpcao == 6

			RecLock("TQ2", .F.)

			TQ2->TQ2_STATUS := IIf(nOpcao == 4, '2', '3')

			If nOpcao == 6
				TQ2->TQ2_USERCO := cUsername
				TQ2->TQ2_DATACO := dDataBase
				TQ2->TQ2_HORACO := SubStr(Time(), 1, 5)
			EndIf

			MsUnLock()
		EndIf

		//Gera WorkFlow
		MNT693WF(nOpcao)
	EndIf

	NgPrepTbl({ {"ST9"}, {"CTT"}, {"SHB"} }, cEmpAnt, cFilLogad)

Return

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³ Funcao   ³ GravaTQ2 ³ Autor ³Vitor Emanuel Batista  ³ Data ³03/09/2010³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Descri‡…o³ Valida e grava informacoes                                 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ MNTA693                                                   ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Static Function GravaTQ2()

	Local lRet     := .T.
	Local lIntegAF := ( SuperGetMv( 'MV_NGMNTAT', .F., '' ) $ '1/3' )
	Local aAreaTQ2 := GetArea()
	Local cBem     := ""
	Local cFilDest := ""
	Local cTMSOri  := AllTrim(GetNewPar("MV_NGMNTMS","N"))
	Local cTQSOri  := AllTrim(GetNewPar("MV_NGPNEUS","N"))
	Local cHistOri := AllTrim(GetNewPar("MV_NGCONTC","N"))
	Local cTMSDes  := NGRetParEx(M->TQ2_EMPDES,,"MV_NGMNTMS","N") //Busca parâmetro de outro grupo de empresas
	Local cTQSDes  := NGRetParEx(M->TQ2_EMPDES,,"MV_NGPNEUS","N") //Busca parâmetro de outro grupo de empresas
	Local cHistDes := NGRetParEx(M->TQ2_EMPDES,,"MV_NGCONTC","N") //Busca parâmetro de outro grupo de empresas
	Local lFRTOri  := IIf( FindFunction('MNTFrotas'), MNTFrotas(), GetNewPar('MV_NGMNTFR','N') == 'S' )

	Private lTMSInt    := cTMSOri $ "S/P"     .And. cTMSDes   $ "S/P"
	Private lTQSInt    := cTQSOri == "S"      .And. cTQSDes  == "S"
	// A partir do release 12.1.33, o parâmetro MV_NGMNTFR será descontinuado
	// Haverá modulo específico para a gestão de Frotas no padrão do produto
	Private lFROInt    := lFRTOri .And. ( GetRPORelease() >= '12.1.033' .Or. NGRetParEx(M->TQ2_EMPDES,,"MV_NGMNTFR","N") == 'S' )
	Private lHistCom   := cHistOri $ "S/P"    .And. cHistDes  $ "S/P"
	Private lTT8Tanque := FWAliasInDic("TT8") .And. NGAliasInDic("TT8",M->TQ2_EMPDES) //Verifica se existe tabela de Tanque em Ambas as empresas
	Private lTS3Table  := FWAliasInDic("TS3") .And. NGAliasInDic("TS3",M->TQ2_EMPDES) //Verifica se existe tabela de Veiculos Penhorados em Ambas as empresas
	Private lTSJTable  := FWAliasInDic("TSJ") .And. NGAliasInDic("TSJ",M->TQ2_EMPDES) //Verifica se existe tabela de Leasing em Ambas as empresas

	If ALTERA .Or. INCLUI
		If Empty(M->TQ2_EMPDES) .Or. Empty(M->TQ2_FILDES)
			lRet := .F.
		EndIf
	EndIf

	If lRet

		dbSelectArea("SM0")
		dbSetOrder(1)
		dbSeek(cEmpAnt + cFilAnt)

		//------------------------------------------------
		//Valida duplicidade de registros
		//------------------------------------------------

		If !ExistChav( "TQ2", M->TQ2_CODBEM + DTOS( M->TQ2_DATATR ) + M->TQ2_HORATR )

			lRet := .F.

		EndIf

		If lRet

			If ALTERA .Or. INCLUI .Or. lCONFIRM
				//----------------------------------------------------
				// Valida ordem de serviço na confirmação da rotina
				//----------------------------------------------------
				If !MNT693OS()
					Return .F.
				EndIf

				//Valida contador 1 e 2
				If TipoAcom .And. !MNT693CONT(1)
					Return .F.
				ElseIf TipoAcom2 .And. !MNT693CONT(2)
					Return .F.
				EndIf

				//Criação de Tabelas Temporárias
				fCriaTRB()

				If lCONFIRM //Confirmação da transferência

					BEGIN TRANSACTION	 													// Inicia transação

						MsgRun( STR0002 , STR0003 , { || lRet := fSILTRNSF(!lCONFIRM)}) //"Processando informações..."###"Aguarde"

						If lRet .And. lIntegAF

							lRet := f015TRSATF()
							If !lRet													//Caso o ExecAuto retorne falso, cancela a transação
								DisarmTransaction()
							Else
								cFilDest	:= M->TQ2_FILDES
								cBem	    := M->TQ2_CODBEM
								//END TRANSACTION										//Se executado o ExecAuto, encerra a transação

								If 	M->TQ2_EMPORI == M->TQ2_EMPDES

									//Atualiza o campo T9_CODIMOB da filial destino
									dbSelectArea("ST9")
									dbSetOrder(1)
									If dbSeek(xFilial("ST9",M->TQ2_FILDES)+ M->TQ2_CODBEM)
										RecLock("ST9",.F.)
										ST9->T9_CODIMOB := NGCODIMOB(M->TQ2_FILDES,M->TQ2_CODBEM)
										MsUnlock()
									EndIf
								EndIf
							EndIf
							MsUnLockAll()
							f550CLOSE()
						EndIf
					END TRANSACTION
					// Deleção Tabelas Temporárias
					//f550CLOSE()
					MsUnLockAll()
				Else
					MsgRun( STR0002 , STR0003 , { || lRet := fSILTRNSF(!lCONFIRM)}) //"Processando informações..."###"Aguarde"
					f550CLOSE()
				EndIf
				// Deleção Tabelas Temporárias
				//f550CLOSE()
			EndIf
		EndIf

		If !lRet
			NgPrepTbl({ {"CTT"}, {"SHB"} }, M->TQ2_EMPORI)
		EndIf
	EndIf
	RestArea(aAreaTQ2)

Return lRet


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³MNT693BEM  ³ Autor ³Vitor Emanuel Batista  ³ Data ³03/09/2010³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³Valida codigo do Bem                                        ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³CONSTRUCAO CIVIL                                             ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function MNT693BEM()

	Local cMsg   := ""
	Local lCatOK := .T.
	Local aArea

	dbSelectArea("ST9")
	dbSetOrder(01)
	dbSeek(xFilial("ST9") + M->TQ2_CODBEM)

	aArea := GetArea()

	//---------------------------
	//Valida categoria do Bem
	//---------------------------
	If ST9->T9_CATBEM == "2"
		MsgInfo( STR0178, STR0017 )//"Para transferência nesta rotina não são aceitos bens de catergoria '2 = Frota Integrada ao TMS'."###"NAO CONFORMIDADE"
		Return .F.
	EndIf

	//------------------------------------------------------------
	//Valida situacao do Bem
	//------------------------------------------------------------
	If ST9->T9_SITBEM <> "A" .And. ST9->T9_SITBEM $ 'I/T'

		cMsg := IIf( ST9->T9_SITBEM == "I", STR0016, STR0018 )

		//STR0016 -> "Situacao do bem inativo, nao pode ser transferido."###"NAO CONFORMIDADE"
		//STR0018 -> "Situacao do bem 'Transferido', nao pode ser transferido."###"NAO CONFORMIDADE"
	Else

		//------------------------------------------------------------
		//Verifica a existencia de transferência pendente para o Bem
		//------------------------------------------------------------
		dbSelectArea("TQ2")
		dbSetOrder(4)
		If dbSeek(xFilial("TQ2") + M->TQ2_CODBEM + "1") .Or. dbSeek(xFilial("TQ2") + M->TQ2_CODBEM + "2")
			ShowHelpDlg(STR0011,	{STR0019},1,; //"Atenção"###"Já existe uma transferência não finalizada para o Bem informado."
			{STR0020},1) //"Utilize a transferência já cadastrada."
			Return .F.
		EndIf

		If !Empty( _cBemTran_ )

			dbSelectArea("TQY")
			dbSetOrder(01)
			If dbSeek(xFilial("TQY") + _cBemTran_)

				If !Empty(TQY->TQY_CATBEM) .And. TQY->TQY_CATBEM != ST9->T9_CATBEM
					lCatOK := .F.
				Else
					dbSelectArea("STC")
					dbSetOrder(01)
					dbSeek(xFilial("STC") + M->TQ2_CODBEM)
					While !EoF() .And. STC->TC_CODBEM == M->TQ2_CODBEM

						dbSelectArea("ST9")
						dbSetOrder(01)
						If dbSeek(xFilial("ST9") + STC->TC_COMPONE)
							If !( lCatOK := Empty(TQY->TQY_CATBEM) .Or. TQY->TQY_CATBEM == ST9->T9_CATBEM )
								Exit
							EndIf
						EndIf

						dbSelectArea("STC")
						dbSkip()
					EndDo
				EndIf

				If !lCatOK
					cMsg := STR0021 + CHR(13) //"Categoria do status informada no parametro MV_NGBEMTR nao é genérica"
					cMsg += STR0022 + CHR(13) //"nem corresponde as categorias da familia. Para realizar a transferencia é"
					cMsg += STR0023 + CHR(13) //"necessário que este parâmetro esteja associado a um status cadastrado,"
					cMsg += STR0024 //"com a categoria dos componentes da estrutura ou em branco."
				EndIf

			Else
				cMsg := STR0025 + CHR(13) //"Nao existe status correspondente ao parametro MV_NGBEMTR. Para realizar "
				cMsg += STR0026 + CHR(13) //"a transferencia é necessário que este parâmetro esteja associado a um status"
				cMsg += STR0027 //"cadastrado, com a categoria dos componentes da estrutura ou em branco."
			EndIf

		Else

			cMsg := STR0028 + CHR(13) //"Parametro MV_NGBEMTR (para status 'Transferido') está vazio. Para realizar "
			cMsg += STR0026 + CHR(13) //"a transferencia é necessário que este parâmetro esteja associado a um status"
			cMsg += STR0027 //"cadastrado, com a categoria dos componentes da estrutura ou em branco."

		EndIf
	EndIf

	If !Empty(cMsg)
		MsgInfo(cMsg)
		Return .F.
	EndIf

	RestArea(aArea)

	TipoAcom  := ST9->T9_TEMCONT == "S"
	IF !lFuncCont2
		TipoAcom2 := TPE->(dbSeek(xFilial("TPE")+ST9->T9_CODBEM))
	Else
		TipoAcom2 := MNTCont2( xFilial("TPE"), ST9->T9_CODBEM )
	EndIf

Return .T.

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³MNT693DAT ³ Autor ³Vitor Emanuel Batista  ³ Data ³17/09/2010³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³Valida campo de Data de Transferencia                       ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³CONSTRUCAO CIVIL                                             ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function MNT693DAT()

	If !Empty(M->TQ2_CODBEM)
		dbSelectArea("ST9")
		dbSetOrder(1)
		If dbSeek(xFilial("ST9")+M->TQ2_CODBEM) .And. ST9->T9_DTCOMPR > M->TQ2_DATATR

			Help( Nil, Nil, STR0011, Nil, STR0029, 1, 0, Nil, Nil, Nil, Nil, Nil, { STR0030 } )
			//"Atenção"###"Data de transferência inferior a data da compra do Bem."
			//"Informe uma data de transferência superior a data de compra do Bem."

			Return .F.

		EndIf
	EndIf

	If M->TQ2_DATATR > dDataBase .Or. ( M->TQ2_DATATR == dDataBase .And. M->TQ2_HORATR > Substr(Time(),1,5) )

		Help( Nil, Nil, STR0011, Nil, STR0031, 1, 0, Nil, Nil, Nil, Nil, Nil, { STR0032 } )
		//"Atenção"###"Data de transferência superior a data atual."
		//"Informe uma data menor ou igual a data atual."

		Return .F.

	EndIf

Return .T.

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³MNT693DES  ³ Autor ³Vitor Emanuel Batista  ³ Data ³09/09/2010³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³Valida Empresa+Filial destino                               ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³CONSTRUCAO CIVIL                                             ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function MNT693DES(lEmpDes)

	Local cRegSM0 := SM0->M0_CODIGO+SM0->M0_CODFIL

	Default lEmpDes := .T.

	If lEmpDes
		If M->TQ2_EMPDES != SM0->M0_CODIGO .Or. Empty( M->TQ2_FILDES )
			dbSelectArea("SM0")
			dbSetOrder(1)
			If dbSeek(M->TQ2_EMPDES)
				M->TQ2_FILDES := SubStr(SM0->M0_CODFIL,1,TamSx3('TQ2_FILDES')[1])
			EndIf
		EndIf
	EndIf

	dbSelectArea("SM0")
	dbSetOrder(1)
	If !dbSeek(M->TQ2_EMPDES+M->TQ2_FILDES)
		Help(" ",1,"REGNOIS")
		dbSeek( cRegSM0 )
		Return .F.
	EndIf

	If M->TQ2_EMPORI == SM0->M0_CODIGO .And. M->TQ2_FILORI == SM0->M0_CODFIL
		ShowHelpDlg(STR0011,	{STR0033},1,; //"Atenção"###"Empresa/Filial inválida."
		{STR0034},1) //"Informe uma Empresa/Filial diferente da atual."
		dbSeek( cRegSM0 )
		Return .F.
	EndIf

	NgPrepTbl({ {"CTT"}, {"SHB"} }, M->TQ2_EMPDES, M->TQ2_FILDES)
Return .T.

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³ MNT693OS  ³ Autor ³Vitor Emanuel Batista  ³ Data ³03/09/2010³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³Valida Ordem de Servico                                     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³CONSTRUCAO CIVIL                                             ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function MNT693OS()

	Local aAreaSTJ	:= GetArea()
	Local cMENORD	:= Space(1)
	Local cMOTIVO	:= Space(1)

	dbSelectArea("STJ")
	dbSetOrder(1)
	dbSeek(xFilial("STJ")+M->TQ2_ORDEM)

	If Empty( M->TQ2_ORDEM )
		If !_lObrigOS_
			RestArea(aAreaSTJ)
			Return .T.
		Else
			cMOTIVO := "É obrigatório o preenchimento do campo: " + AllTrim( NGRETTITULO( "TQ2_ORDEM" ) )
		EndIf
	EndIf

	If Empty( cMOTIVO ) .And. STJ->TJ_CODBEM <> M->TQ2_CODBEM
		cMOTIVO := STR0035 //"Ordem de servico nao pertence ao bem."
	Else
		If Empty( cMOTIVO ) .And. !(STJ->TJ_SITUACA == "L" .And. STJ->TJ_TERMINO == "S")
			cMOTIVO := STR0036 //"Ordem de servico nao liberada/terminada."
		EndIf
	EndIf

	If !Empty(cMOTIVO)
		cMENORD := STR0038+chr(13); //"Transferencia nao pode ser executada, pois nao foi realizado"
		+STR0039+chr(13)+chr(13); //"o servico de checagem da transferencia"
		+STR0040+chr(13)+chr(13)+cMOTIVO //"MOTIVO:"
		MsgInfo(cMENORD,STR0041) //"NAO COMFORMIDADE"
		Return .F.
	EndIf

	RestArea(aAreaSTJ)

Return .T.


/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³ fSILTRNSF³ Autor ³ Felipe Nathan Welter  ³ Data ³ 15/03/10 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Realiza a transferencia do bem entre empresas/filiais      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ 1.aInfo - Vetor contendo informacoes do bem pai e componen.³±±
±±³          ³ 2.lSimula - indica se deve simular          (opc - def:.F.)³±±
±±³          ³ 3.lConsist - mostra relatorio de inconsist. (opc - def:.T.)³±±
±±³          ³ 4.lCont - valida e reporta contadores       (opc - def:.T.)³±±
±±³          ³     *no caso de utilizacao junto de outros processos, nao  ³±±
±±³          ³     e' necessario realizar reporte com mesma data/hora     ³±±
±±³          ³  -> Composicao de aInfo:                                   ³±±
±±³          ³  [01] - aPai (vetor com informacoes do pai)                ³±±
±±³          ³  [02...n] - aFilho (vetor com inforamcoes dos componentes) ³±±
±±³          ³  -> Composicao dos vetores de aInfo:                       ³±±
±±³          ³  [01] - Codigo do bem                                      ³±±
±±³          ³  [02] - Codigo da Empresa Origem                           ³±±
±±³          ³  [03] - Codigo da Filial Origem                            ³±±
±±³          ³  [04] - Codigo da Empresa Destino                          ³±±
±±³          ³  [05] - Codigo da Filial Destino                           ³±±
±±³          ³  [06] - Data                                               ³±±
±±³          ³  [07] - Hora                                               ³±±
±±³          ³  [08] - Motivo de transferencia                            ³±±
±±³          ³  [09] - Centro de Custo Destino                            ³±±
±±³          ³  [10] - Centro de Trabalho Destino                         ³±±
±±³          ³  [11] - Contador 01                                        ³±±
±±³          ³  [12] - Contador 02                                        ³±±
±±³          ³  [13] - Ordem de Servico                                   ³±±
±±³          ³  [14] - Causa                                              ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ Generico                                                   ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Static Function fSILTRNSF(lSimula,lConsist,lCont)

	//Armazena variaveis p/ devolucao (NGRIGHTCLICK)
	Local aNGBEGINPRM := NGBEGINPRM()
	Local nX          := 0

	Default lSimula  := .F.
	Default lConsist := .T.
	Default lCont    := .T.

	//Variaveis para identificar a presenca de tabelas
	Private cF3CTTSI3  := If(CtbInUse(), "CTT", "SI3")

	//Variaveis para carregar a filial considerando compartilhado e exclusivo
	Private cFilTrTS3  := ""
	Private cFilOriTS3 := ""
	Private cFilTrTSJ  := ""
	Private cFilOriTSJ := ""

	Private cIndTRBACB, cIndTRBACC, cIdx2A, cIdx2B
	Private TIPOACOM  := .F.
	Private TIPOACOM2 := .F.
	Private lChkCont  := lCont
	Private q         := AllTrim(GetNewPar("MV_NGBEMTR"   ))  //Status do bem transferido
	Private lObrigOS  := AllTrim(GetNewPar("MV_NGINFOS","")) == "1"  //Obriga digitar OS

	//VERIFICACAO DE DICIONARIO
	aLog := {}

	If CtbInUse() != NGRetParEx(M->TQ2_EMPDES,,"MV_MCONTAB","") == "CTB"
		aAdd(aLog,{"CTB",STR0046}) //"Parâmetro MV_MCONTAB deve ser equivalente entre as empresas da transferência."
	EndIf

	If !FWAliasInDic("TQ2") .Or. !NGAliasInDic("TQ2",M->TQ2_EMPDES)
		aAdd(aLog,{"TQ2",STR0042}) //"Arquivo/tabela TQ2 não presente no SX2."
	EndIf

	//---------------------------------------------------------------
	For nX := 1 To Len(aLog)
		fGravPrb(aLog[nX,1],,aLog[nX,2],3)
	Next nX

	//---------------------------------------------------------------
	//---------------------------------------------------------------
	//Consistencia do modo de criacao da tabelas/arquivos
	f550MO()

	//Verificacao se houveram inconsistencias para a transferencia
	If lConsist
		If !f550CHKINC()
			NGRETURNPRM(aNGBEGINPRM)
			Return .F.
		EndIf
	Else
		If (cTRBGRV)->(RecCount()) > 0
			dbSelectArea(cTRBGRV)
			dbSetOrder(02)
			If dbSeek('2') .Or. dbSeek('3') .Or. dbSeek('4')
				NGRETURNPRM(aNGBEGINPRM)
				Return .F.
			EndIf
		EndIf
	EndIf


	//---------------------------------------------------------------
	//---------------------------------------------------------------
	//ALIMENTA VARIAVEIS E VALIDA PARAMETROS
	fSI1A5VAR()

	//---------------------------------------------------------------
	//---------------------------------------------------------------
	//Monta estrutura do bem
	aBEMTRA := NGCOMPEST(M->TQ2_CODBEM,"B",.F.,.F.,.F.,M->TQ2_FILORI,M->TQ2_EMPORI)

	//---------------------------------------------------------------
	//---------------------------------------------------------------
	//EXECUTA TESTES INDIVIDUAIS ANTES DA GRAVACAO FINAL

	/*
	Conforme especificado, as funcoes abaixo estarao validando a existencia de chaves estrangeiras para
	os campos das tabelas principais, assumindo que ao encontrar um mesmo codigo na empresa/filial destino,
	esse seja gravado na transferencia. A falta de campos obrigatorios impedira a conclusao do processo.
	*/

	//---Cadastro de Bens
	f550ST9T() //BEM
	f550STBT() //CARACTERISTICAS DO BEM
	f550TPYT() //PECAS DE REPOSICAO DO BEM

	If lFROInt
		f550TQST() //PNEUS
	EndIf

	//---Estrutura de bens
	f550STCT() //ESTRUTURA DO BEM

	//---Cadastro de Manutencao
	f550STFT() //MANUTENCAO
	f550ST5T() //TAREFAS DA MANUTENCAO
	f550STGT() //DETALHES DA MANUTENCAO
	f550STHT() //ETAPAS DA MANUTENCAO
	f550TP1T() //OPCOES DA ETAPAS DA MANUTENCAO


	//---------------------------------------------------------------
	If !lSimula
		//Verificacao se houveram inconsistencias para a transferencia
		If lConsist
			If !f550CHKINC()
				NGRETURNPRM(aNGBEGINPRM)
				Return .F.
			EndIf
		Else
			If (cTRBGRV)->(RecCount()) > 0
				dbSelectArea(cTRBGRV)
				dbSetOrder(02)
				If dbSeek('2') .Or. dbSeek('3') .Or. dbSeek('4')
					NGRETURNPRM(aNGBEGINPRM)
					Return .F.
				EndIf
			EndIf
		EndIf
		//---------------------------------------------------------------
		BEGIN TRANSACTION

			f550GRAV() //OPERACAO DE TRANSFERENCIA

		END TRANSACTION
		MsUnlockAll()
		//---------------------------------------------------------------
	EndIf
	//---------------------------------------------------------------

	//---------------------------------------------------------------
	//Verificacao se houveram inconsistencias para a transferencia
	If lConsist
		If !f550CHKINC()
			NGRETURNPRM(aNGBEGINPRM)
			Return .F.
		EndIf
	Else
		If (cTRBGRV)->(RecCount()) > 0
			dbSelectArea(cTRBGRV)
			dbSetOrder(02)
			If dbSeek('2') .Or. dbSeek('3') .Or. dbSeek('4')
				NGRETURNPRM(aNGBEGINPRM)
				Return .F.
			EndIf
		EndIf
	EndIf

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Devolve variaveis armazenadas (NGRIGHTCLICK)                          ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	NGRETURNPRM(aNGBEGINPRM)

Return .T.

/*/
	ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
	±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
	±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
	±±³Fun‡ao    ³f550TRAS  ³ Autor ³ Felipe Nathan Welter  ³ Data ³ 15/03/10 ³±±
	±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
	±±³Descri‡…o ³Faz a transferencia                                         ³±±
	±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
	±±³Parametros³nREGCONT1 = Numero do registro logico do bem (Contador 1)   ³±±
	±±³          ³nREGCONT2 = Numero do registro logico do bem (Contador 2)   ³±±
	±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
	±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
	ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Static Function f550TRAS(nREGCONT1,nREGCONT2)

	Local i, nn
	Local nCONTAD1 , nCONTAD2, cCENTRAB

	//Hora de inclusao na estrutura
	cHORAINC := M->TQ2_HORATR

	// Monta a estrutura do bem
	NgPrepTbl({ {"ST9"}, {"TPE"}, {"STC"} }, M->TQ2_EMPORI, M->TQ2_FILORI)
	NGESTRUTRB(M->TQ2_CODBEM,"B","TRBSTRU")
	NgPrepTbl({ {"ST9"}, {"TPE"}, {"STC"} }, SM0->M0_CODIGO, SM0->M0_CODFIL)

	dbSelectArea("TRBSTRU")
	dbGoTop()
	If Reccount() > 0

		dbSelectArea("TRBSTRU")
		While !Eof()

			// Limpa e cria arquivo temporario do st9
			//dbSelectArea(cTRB)
			//ZAP

			// Limpa e cria arquivo temporario do tpe
			//dbSelectArea(cTRBTPE)
			//ZAP

			NGPrepTBL({ {"ST9", 01} }, M->TQ2_EMPORI)
			If dbSeek(NGTROCAFILI("ST9",M->TQ2_FILORI,M->TQ2_EMPORI)+TRBSTRU->TC_COMPONE)

				//faz uma copia do ST9
				dbSelectArea(cTRB)
				RecLock((cTRB),.T.)
				For i := 1 TO FCOUNT()
					pp   := "ST9->"+ FieldName(i)
					vl   := "(cTRB)->"+ FieldName(i)
					&vl. := &pp.
				Next i
				(cTRB)->(MsUnlock())

				//Altera o status do ST9
				dbSelectArea("ST9")
				RecLock("ST9",.F.)
				ST9->T9_SITMAN := "I"
				ST9->T9_SITBEM := "T"
				If lFROInt .And. !Empty( _cBemTran_ )
					ST9->T9_STATUS := _cBemTran_
				EndIf
				MsUnLock("ST9")

				//Cria um novo st9 com a nova filial
				NGPrepTBL({ {"ST9", 01} }, M->TQ2_EMPDES)
				If dbSeek(NGTROCAFILI("ST9",M->TQ2_FILDES,M->TQ2_EMPDES)+TRBSTRU->TC_COMPONE)
					RecLock("ST9",.F.)
				Else
					RecLock("ST9",.T.)
				EndIf

				For i := 1 TO FCOUNT()

					nn := FieldName(i)
					pp   := "ST9->"+ FieldName(i)
					vl   := "(cTRB)->"+ FieldName(i)

					If nn == "T9_FILIAL"
						&pp. := NGTROCAFILI("ST9",M->TQ2_FILDES,M->TQ2_EMPDES)
					ElseIf nn == "T9_CODIMOB"
						If !Empty(&vl.) .And. (fChkArquivo("SN1") .Or. fSilSEEK("SN1",&vl.,01,M->TQ2_FILDES,M->TQ2_EMPDES))
							&pp. := &vl.
						Else
							&pp. := ""
						EndIf
					ElseIf nn == "T9_RECFERR"
						If (cTRB)->T9_FERRAME == "F"
							If (fChkArquivo("SH4") .Or. fSilSEEK("SH4",&vl.,01,M->TQ2_FILDES,M->TQ2_EMPDES))
								&pp. := &vl.
							Else
								&pp. := ""
							EndIf
						ElseIf (cTRB)->T9_FERRAME == "R"
							If (fChkArquivo("SH1") .Or. fSilSEEK("SH1",&vl.,01,M->TQ2_FILDES,M->TQ2_EMPDES))
								&pp. := &vl.
							Else
								&pp. := ""
							EndIf
						EndIf
					ElseIf nn == "T9_CCUSTO"
						If cF3CTTSI3 == "CTT"
							If !Empty(M->TQ2_CCUSTO) .And. (fChkArquivo("CTT") .Or. fSilSEEK("CTT",M->TQ2_CCUSTO,01,M->TQ2_FILDES,M->TQ2_EMPDES))
								&pp. := M->TQ2_CCUSTO//&vl.
							Else
								&pp. := ""
							EndIf
						ElseIf cF3CTTSI3 == "SI3"
							If !Empty(M->TQ2_CCUSTO) .And. (fChkArquivo("SI3") .Or. fSilSEEK("SI3",M->TQ2_CCUSTO,01,M->TQ2_FILDES,M->TQ2_EMPDES))
								&pp. := M->TQ2_CCUSTO//&vl.
							Else
								&pp. := ""
							EndIf
						EndIf
					ElseIf nn == "T9_CENTRAB"
						If !Empty(M->TQ2_CENTRA) .And. (fChkArquivo("SHB") .Or. fSilSEEK("SHB",M->TQ2_CENTRA,01,M->TQ2_FILDES,M->TQ2_EMPDES))
							&pp. := M->TQ2_CENTRA//&vl.
						Else
							&pp. := ""
						EndIf
					ElseIf nn == "T9_FORNECE"
						If !Empty(&vl.) .And. (fChkArquivo("SA2") .Or. fSilSEEK("SA2",&vl.,01,M->TQ2_FILDES,M->TQ2_EMPDES))
							&pp. := &vl.
						Else
							&pp. := ""
						EndIf
					ElseIf nn == "T9_FABRICA"
						If !Empty(&vl.) .And. (fChkArquivo("ST7") .Or. fSilSEEK("ST7",&vl.,01,M->TQ2_FILDES,M->TQ2_EMPDES))
							&pp. := &vl.
						Else
							&pp. := ""
						EndIf
					ElseIf nn == "T9_CODESTO"
						If !Empty(&vl.) .And. (fChkArquivo("SB1") .Or. fSilSEEK("SB1",&vl.,01,M->TQ2_FILDES,M->TQ2_EMPDES))
							&pp. := &vl.
						Else
							&pp. := ""
						EndIf
					ElseIf nn == "T9_CLIENTE"
						If !Empty(&vl.) .And. (fChkArquivo("SA1") .Or. fSilSEEK("SA1",&vl.,01,M->TQ2_FILDES,M->TQ2_EMPDES))
							&pp. := &vl.
						Else
							&pp. := ""
						EndIf
					ElseIf nn == "T9_MTBAIXA"
						If !Empty(&vl.) .And. (fChkArquivo("TPJ") .Or. fSilSEEK("TPJ",&vl.,01,M->TQ2_FILDES,M->TQ2_EMPDES))
							&pp. := &vl.
						Else
							&pp. := ""
						EndIf
					ElseIf nn == "T9_ITEMCTA"
						If !Empty(&vl.) .And. (fChkArquivo("CTD") .Or. fSilSEEK("CTD",&vl.,01,M->TQ2_FILDES,M->TQ2_EMPDES))
							&pp. := &vl.
						Else
							&pp. := ""
						EndIf
					ElseIf nn == "T9_TIPMOD" .Or.  nn == "T9_STATUS" .Or.  nn == "T9_CORVEI";//FROTAS
						.Or. nn == "T9_UFEMPLA" .Or. nn == "T9_CODTMS" .Or. nn == "T9_TIPVEI"

						If nn == "T9_TIPMOD"
							If !Empty(&vl.) .And. (fChkArquivo("TQR") .Or. fSilSEEK("TQR",&vl.,01,M->TQ2_FILDES,M->TQ2_EMPDES))
								&pp. := &vl.
							Else
								&pp. := ""
							EndIf
						ElseIf nn == "T9_STATUS"
							If !Empty(&vl.) .And. (fChkArquivo("TQY") .Or. fSilSEEK("TQY",&vl.,01,M->TQ2_FILDES,M->TQ2_EMPDES))
								&pp. := &vl.
							Else
								&pp. := ""
							EndIf
						ElseIf nn == "T9_CORVEI"
							If !Empty(&vl.) .And. (fChkArquivo("SX5") .Or. fSilSEEK("SX5","M7"+&vl.,01,M->TQ2_FILDES,M->TQ2_EMPDES))
								&pp. := &vl.
							Else
								&pp. := ""
							EndIf
						ElseIf nn == "T9_UFEMPLA"
							If !Empty(&vl.) .And. (fChkArquivo("SX5") .Or. fSilSEEK("SX5","12"+&vl.,01,M->TQ2_FILDES,M->TQ2_EMPDES))
								&pp. := &vl.
							Else
								&pp. := ""
							EndIf
						ElseIf nn == "T9_CODTMS"
							If !Empty(&vl.) .And. (fChkArquivo("DA3") .Or. fSilSEEK("DA3",&vl.,01,M->TQ2_FILDES,M->TQ2_EMPDES))
								&pp. := &vl.
							Else
								&pp. := ""
							EndIf
						ElseIf nn == "T9_TIPVEI"
							If !Empty(&vl.) .And. (fChkArquivo("DUT") .Or. fSilSEEK("DUT",&vl.,01,M->TQ2_FILDES,M->TQ2_EMPDES))
								&pp. := &vl.
							Else
								&pp. := ""
							EndIf
						EndIf
					Else
						&pp. := &vl.
					EndIf
				Next i
				MsUnLock("ST9")

				//Integracao com TMS
				If ST9->T9_CATBEM == "2"
					If fChkArquivo("DA3")
						//tabela compartilhada entre empresas, troca filial base para filial destino
						NgPrepTbl({ {"DA3", 03} }, M->TQ2_EMPDES)
						If dbSeek(NGTROCAFILI("DA3",M->TQ2_FILDES,M->TQ2_EMPDES)+ST9->T9_PLACA)
							RecLock("DA3",.F.)
							DA3->DA3_FILBAS := NGTROCAFILI("ST9",M->TQ2_FILDES,M->TQ2_EMPDES)
							MsUnLock("DA3")
						EndIf
						NgPrepTbl({ {"DA3"} }, SM0->M0_CODIGO)

					ElseIf fSilSEEK("DA3",ST9->T9_PLACA,03,M->TQ2_FILDES,M->TQ2_EMPDES)

						//placa TMS existente na empresa destino, associa ST9 ao DA3
						NgPrepTbl({ {"DA3", 03} }, M->TQ2_EMPDES)
						If dbSeek(NGTROCAFILI("DA3",M->TQ2_FILDES,M->TQ2_EMPDES)+ST9->T9_PLACA)

							RecLock("DA3",.F.)
							DA3->DA3_FILBAS := NGTROCAFILI("ST9",M->TQ2_FILDES,M->TQ2_EMPDES)
							MsUnLock("DA3")

							RecLock("ST9",.F.)
							ST9->T9_CODTMS := DA3->DA3_COD
							MsUnLock("ST9")

						EndIf
						NgPrepTbl({ {"DA3"} }, SM0->M0_CODIGO)
					Else

						//faz uma copia do DA3
						NgPrepTbl({ {"DA3", 03} }, M->TQ2_EMPORI)
						If dbSeek(NGTROCAFILI("DA3",M->TQ2_FILORI,M->TQ2_EMPORI)+ST9->T9_PLACA)
							RecLock((cTRBDA3),.T.)
							For i := 1 To Fcount()
								pp   := "DA3->"+ FieldName(i)
								vl   := "(cTRB)->"+ FieldName(i)
								&vl. := &pp.
							Next i

							(cTRBDA3)->(MsUnlock())

							NgPrepTbl({ {"DA3"} }, M->TQ2_EMPDES)
							dbSelectArea("DA3")
							RecLock("DA3",.T.)
							For i := 1 To Fcount()
								nn := FieldName(i)
								pp := "DA3->"+ FieldName(i)
								vl := "(cTRBDA3)->"+ FieldName(i)
								If nn == "DA3_FILIAL"
									&pp. := NGTROCAFILI("DA3",M->TQ2_FILDES,M->TQ2_EMPDES)
								ElseIf nn == "DA3_FILBAS"
									&pp. := NGTROCAFILI("ST9",M->TQ2_FILDES,M->TQ2_EMPDES)
								ElseIf nn == "DA3_ESTPLA"
									If !Empty(&vl.) .And. (fChkArquivo("SX5") .Or. fSilSEEK("SX5","12"+&vl.,01,M->TQ2_FILDES,M->TQ2_EMPDES))
										&pp. := &vl.
									EndIf
								ElseIf nn == "DA3_MOTORI"
									If !Empty(&vl.) .And. (fChkArquivo("DA4") .Or. fSilSEEK("DA4",&vl.,01,M->TQ2_FILDES,M->TQ2_EMPDES))
										&pp. := &vl.
									EndIf
								ElseIf nn == "DA3_CODFOR"
									If !Empty(&vl.) .And. (fChkArquivo("SA2") .Or. fSilSEEK("SA2",&vl.,01,M->TQ2_FILDES,M->TQ2_EMPDES))
										&pp. := &vl.
									EndIf
								ElseIf nn == "DA3_MARVEI"
									If !Empty(&vl.) .And. (fChkArquivo("SX5") .Or. fSilSEEK("SX5","M6"+&vl.,01,M->TQ2_FILDES,M->TQ2_EMPDES))
										&pp. := &vl.
									EndIf
								ElseIf nn == "DA3_CORVEI"
									If !Empty(&vl.) .And. (fChkArquivo("SX5") .Or. fSilSEEK("SX5","M7"+&vl.,01,M->TQ2_FILDES,M->TQ2_EMPDES))
										&pp. := &vl.
									EndIf
								ElseIf nn == "DA3_TIPVEI"
									If !Empty(&vl.) .And. (fChkArquivo("DUT") .Or. fSilSEEK("DUT",&vl.,01,M->TQ2_FILDES,M->TQ2_EMPDES))
										&pp. := &vl.
									EndIf
								ElseIf nn == "DA3_ATIVO"
									&pp. := "2"
								Else
									&pp. := &vl.
								EndIf
							Next i
							MsUnLock("DA3")

							RecLock("ST9",.F.)
							ST9->T9_CODTMS := DA3->DA3_COD
							MsUnLock("ST9")

							NgPrepTbl({ {"DA3"} }, SM0->M0_CODIGO)
						EndIf

					EndIf
				EndIf

				//Contador 2
				cFilTPE := NGTROCAFILI("TPE",M->TQ2_FILORI,M->TQ2_EMPORI)
				NgPrepTbl({ {"TPE", 01} }, M->TQ2_EMPORI)
				If dbSeek(cFilTPE+TRBSTRU->TC_COMPONE)

					//Faz uma copia do tpe
					dbSelectArea(cTRBTPE)
					RecLock((cTRBTPE),.T.)
					For i := 1 TO FCOUNT()
						pp   := "TPE->"+ FieldName(i)
						vl   := "(cTRBTPE)->"+ FieldName(i)
						&vl. := &pp.
					Next i
					(cTRBTPE)->(MsUnLock())

					//Cria um novo tpe
					cFilTPE := NGTROCAFILI("TPE",M->TQ2_FILDES,M->TQ2_EMPDES)
					NgPrepTbl({ {"TPE"} }, M->TQ2_EMPDES)
					If dbSeek(cFilTPE+TRBSTRU->TC_COMPONE)
						RecLock("TPE",.F.)
					Else
						RecLock("TPE",.T.)
					EndIf

					For i := 1 TO FCOUNT()
						pp   := "TPE->"+ FieldName(i)
						vl   := "(cTRBTPE)->"+ FieldName(i)
						&pp. := &vl.
					Next i
					TPE->TPE_FILIAL := cFilTPE
					MsUnLock("TPE")
				EndIf
				NgPrepTbl({ {"TPE"} }, SM0->M0_CODIGO)

				// Baixa da estrutura STC
				cFilSTC := NGTROCAFILI("STC",M->TQ2_FILORI,M->TQ2_EMPORI)
				NgPrepTbl({ {"ST9"}, {"STZ"}, {"STC"} }, M->TQ2_EMPORI)
				If dbSeek(cFilSTC+TRBSTRU->TC_CODBEM+TRBSTRU->TC_COMPONE)

					dbSelectArea(cTRBSTC)
					//ZAP

					dbSelectArea(cTRBSTC)
					RecLock((cTRBSTC),.T.)
					For i := 1 TO FCOUNT()
						pp   := "STC->"+ FieldName(i)
						vl   := "(cTRBSTC)->"+ FieldName(i)
						&vl. := &pp.
					Next i
					(cTRBSTC)->(MsUnLock())

					dbSelectArea("STC")
					RecLock("STC",.F.)
					dbDelete()
					MsUnLock("STC")

					// Baixa da estrutura STZ
					lSTZ := .F.
					cFilSTZ := NGTROCAFILI("STZ",M->TQ2_FILORI,M->TQ2_EMPORI)
					dbSelectArea("STZ")
					dbSetOrder(01)
					If dbSeek(cFilSTZ+TRBSTRU->TC_COMPONE+"E")
						While !Eof() .And. STZ->TZ_FILIAL == cFilSTZ .And. STZ->TZ_CODBEM == TRBSTRU->TC_COMPONE
							If Empty(STZ->TZ_DATASAI)
								lSTZ := .T.
								//dbSelectArea(cTRBSTZ)
								//ZAP
								dbSelectArea(cTRBSTZ)
								RecLock((cTRBSTZ),.T.)
								For i := 1 TO FCOUNT()
									pp   := "STZ->"+ FieldName(i)
									vl   := "(cTRBSTZ)->"+ FieldName(i)
									&vl. := &pp.
								Next i
								(cTRBSTZ)->(MsUnLock())


								dbSelectArea("STZ")
								RecLock("STZ",.F.)
								STZ->TZ_TIPOMOV := "S"
								STZ->TZ_DATASAI := M->TQ2_DATATR
								STZ->TZ_CONTSAI := TRBSTRU->TC_CONTBE1
								STZ->TZ_CAUSA   := M->TQ2_CAUSA
								STZ->TZ_CONTSA2 := TRBSTRU->TC_CONTBE2
								STZ->TZ_HORASAI := M->TQ2_HORATR
								MsUnLock("STZ")
								nCONT1TZ := STZ->TZ_CONTSAI
								nCONT2TZ := STZ->TZ_CONTSA2
								dbSelectArea("ST9")
								dbSetOrder(01)
								If dbSeek(NGTROCAFILI("ST9",M->TQ2_FILORI,M->TQ2_EMPORI)+TRBSTRU->TC_COMPONE)
									RecLock("ST9",.F.)
									ST9->T9_ESTRUTU := "N"
									MsUnLock("ST9")
								EndIf
								Exit
							EndIf
							dbSelectArea("STZ")
							dbSkip()
						EndDo
					EndIf

					NgPrepTbl({ {"STC"} }, M->TQ2_EMPDES)
					//Cria um novo stc com a nova filial
					dbSelectarea("STC")
					RecLock("STC",.T.)
					For i := 1 TO FCOUNT()

						nn := FieldName(i)
						pp := "STC->"+ FieldName(i)
						vl := "(cTRBSTC)->"+ FieldName(i)

						If nn == "TC_ LOCALIZ"
							If (fChkArquivo("TPS") .Or. fSilSEEK("TPS",STC->TC_LOCALIZ,01,M->TQ2_FILDES,M->TQ2_EMPDES))
								&pp. := &vl.
							EndIf
						ElseIf nn == "TC_FILIAL"
							&pp. := NGTROCAFILI("STC",M->TQ2_FILDES,M->TQ2_EMPDES)
						Else
							&pp. := &vl.
						EndIf
					Next i
					STC->TC_DATAINI := M->TQ2_DATATR
					MsUnLock("STC")

					If lSTZ
						NgPrepTbl({ {"STZ"} }, M->TQ2_EMPDES)
						//Cria um novo stz com a nova filial
						RecLock("STZ",.T.)
						For i := 1 TO FCOUNT()
							pp := "STZ->"+ FieldName(i)
							vl := "(cTRBSTZ)->"+ FieldName(i)
							&pp. := &vl.
						Next i
						STZ->TZ_FILIAL  := NGTROCAFILI("STZ",M->TQ2_FILDES,M->TQ2_EMPDES)
						STZ->TZ_DATAMOV := M->TQ2_DATATR
						STZ->TZ_HORAENT := cHORAINC
						STZ->TZ_POSCONT := nCONT1TZ
						STZ->TZ_POSCON2 := nCONT2TZ
						MsUnLock("STZ")

					EndIf
				EndIf

				//---------------------------------------------------
				//HISTORICO DE MOVIMENTACAO DE CENTRO DE CUSTO
				nCONTAD1 := 0
				nCONTAD2 := 0

				cFilSTZ := NGTROCAFILI("STZ",M->TQ2_FILDES,M->TQ2_EMPDES)
				NgPrepTbl({ {"STZ", 01} }, M->TQ2_EMPDES)
				If dbSeek(cFilSTZ+STC->TC_COMPONE)
					While !Eof() .And. STZ->TZ_FILIAL = cFilSTZ .And. STZ->TZ_CODBEM == STC->TC_COMPONE
						If STZ->TZ_TIPOMOV = 'E'
							nCONTAD1 := STZ->TZ_POSCONT
							nCONTAD2 := STZ->TZ_POSCON2
							Exit
						EndIf
						dbSelectArea("STZ")
						dbskip()
					EndDo
				EndIf

				cFilTPN := NGTROCAFILI("TPN",M->TQ2_FILDES,M->TQ2_EMPDES)
				NgPrepTbl({ {"TPN",01} }, M->TQ2_EMPDES)
				If !dbSeek(cFilTPN+TRBSTRU->TC_COMPONE+M->TQ2_CCUSTO+M->TQ2_CENTRA+DTOS(M->TQ2_DATATR)+M->TQ2_HORATR)
					RecLock("TPN",.T.)

					TPN->TPN_FILIAL := cFilTPN
					TPN->TPN_CODBEM := TRBSTRU->TC_COMPONE
					TPN->TPN_DTINIC := M->TQ2_DATATR
					TPN->TPN_HRINIC := M->TQ2_HORATR
					TPN->TPN_CCUSTO := M->TQ2_CCUSTO
					TPN->TPN_CTRAB  := M->TQ2_CENTRA
					TPN->TPN_UTILIZ := "U"
					TPN->TPN_POSCON := nCONTAD1
					TPN->TPN_POSCO2 := nCONTAD2
					MsUnLock("TPN")
				EndIf

				//---------------------------------------------------
				//----------------------------------------------------------
				//Cria Historico de Movimentacao (exclusao) da Estrutura Organizacional
				NgPrepTbl({ {"TCJ"}, {"TAF"} }, M->TQ2_EMPORI)
				dbSelectArea("TAF")
				dbSetOrder(06)
				If dbSeek(NGTROCAFILI("TAF",M->TQ2_FILORI,M->TQ2_EMPORI)+"X1"+ST9->T9_CODBEM)
					dbSelectArea("TCJ")
					dbSetOrder(01)
					If !dbSeek(NGTROCAFILI("TCJ",M->TQ2_FILORI,M->TQ2_EMPORI)+TAF->TAF_CODNIV+TAF->TAF_NIVSUP+"E"+DTOS(dDataBase)+Time())
						RecLock("TCJ",.T.)
						TCJ->TCJ_FILIAL := NGTROCAFILI("TCJ",M->TQ2_FILORI,M->TQ2_EMPORI)
						TCJ->TCJ_CODNIV := TAF->TAF_CODNIV
						TCJ->TCJ_DESNIV := SubStr(TAF->TAF_NOMNIV,1,40)
						TCJ->TCJ_NIVSUP := TAF->TAF_NIVSUP
						TCJ->TCJ_DATA   := dDatabase
						TCJ->TCJ_HORA   := Time()
						TCJ->TCJ_TIPROC := "E"
						MsUnLock("TCJ")
					EndIf
				EndIf
				NgPrepTbl({ {"TCJ"}, {"TAF"} }, SM0->M0_CODIGO)

				//Realiza a exclusao na Estrutura Organizacional e participantes do processo
				NgPrepTbl({{"TAF"},{"TAK"}},M->TQ2_EMPORI)
				dbSelectArea("TAF")
				dbSetOrder(06)
				If dbSeek(NGTROCAFILI("TAF",M->TQ2_FILORI,M->TQ2_EMPORI)+"X1"+ST9->T9_CODBEM)
					dbSelectArea("TAK")
					dbSetOrder(01)
					dbSeek(NGTROCAFILI("TAK",M->TQ2_FILORI,M->TQ2_EMPORI)+"001"+TAF->TAF_CODNIV)
					While !Eof() .And. TAK->TAK_FILIAL+"001"+TAK->TAK_CODNIV == NGTROCAFILI("TAK",M->TQ2_FILORI,M->TQ2_EMPORI)+"001"+TAF->TAF_CODNIV
						RecLock("TAK",.F.)
						dbDelete()
						MsUnlock("TAK")
						dbSelectArea("TAK")
						dbSkip()
					EndDo
					RecLock("TAF",.F.)
					dbDelete()
					MsUnLock("TAF")
				EndIf
				NgPrepTbl({{"TAF"},{"TAK"}},SM0->M0_CODIGO)

				//----------------------------------------------------------

				NgPrepTbl({{"ST9"},{"STZ"},{"STC"}},SM0->M0_CODIGO)

				f550TCARA(TRBSTRU->TC_COMPONE) //Faz a tranferencia das caracteristicas
				f550TREPO(TRBSTRU->TC_COMPONE) //Faz a tranferencia das pecas de reposicao
				f550BANCON(TRBSTRU->TC_CODBEM+TRBSTRU->TC_COMPONE,"STC",M->TQ2_FILORI,M->TQ2_EMPORI,M->TQ2_FILDES,M->TQ2_EMPDES)//Faz a tranferencia do banco do conhecimento da estrutura
				f550BANCON(TRBSTRU->TC_COMPONE,"ST9",M->TQ2_FILORI,M->TQ2_EMPORI,M->TQ2_FILDES,M->TQ2_EMPDES)//Faz a tranferencia do banco do conhecimento do bem
				If lFROInt
					f550TANQUE(TRBSTRU->TC_COMPONE) //Faz tranferencia do tanque de combustivel
					If lTS3Table
						f550PENHOR(TRBSTRU->TC_COMPONE) //Faz transferencia dos registros de veiculo penhorado
					EndIf
					If lTSJTable
						f550LEASIN(TRBSTRU->TC_COMPONE) //Faz transferencia dos registros de leasing de veiculos
					EndIf
					If lTQSInt
						f550PNEUS(TRBSTRU->TC_COMPONE)//Faz a tranferencia de pneus quando integrado com frotas
					EndIf
				EndIf
				f550TMANU(TRBSTRU->TC_COMPONE) //Faz a tranferencia da manutencao

				//Altera registro da TTM - Veiculos do Grupo
				aAreaTTM := TTM->(GetArea())
				dbSelectArea("TTM")
				dbSetOrder(01)
				If dbSeek(ST9->T9_CODBEM)
					RecLock("TTM",.F.)
					TTM->TTM_EMPROP := M->TQ2_EMPDES
					TTM->TTM_FILPRO := M->TQ2_FILDES
					MsUnLock("TTM")
				EndIf

				RestArea(aAreaTTM)

				//Altera movimentacoes da TTI
				If AliasInDic("TTI")
					aAreaTTI := TTI->(GetArea())
					dbSelectArea("TTI")
					dbSetOrder(03)
					dbSeek(M->TQ2_EMPORI+M->TQ2_FILORI+ST9->T9_CODBEM,.T.)
					While !Eof() .And. TTI->TTI_EMPVEI == M->TQ2_EMPORI .And. TTI->TTI_FILVEI == M->TQ2_FILORI .And. TTI->TTI_CODVEI == ST9->T9_CODBEM
						RecLock("TTI",.F.)
						TTI->TTI_EMPVEI := M->TQ2_EMPDES
						TTI->TTI_FILVEI := M->TQ2_FILDES
						MsUnLock("TTI")
						dbSelectArea("TTI")
						dbSkip()
					EndDo
					RestArea(aAreaTTI)
				EndIf

			EndIf
			dbSelectArea("TRBSTRU")
			dbskip()
		EndDo
	EndIf
	dbSelectArea("TRBSTRU")
	Use
Return

/*/
	ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
	±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
	±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
	±±³Fun‡ao    ³f550MO    ³ Autor ³Felipe Nathan Welter   ³ Data ³ 15/03/10 ³±±
	±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
	±±³Descri‡…o ³Consistencia do modo de criacao da tabelas/arquivos         ³±±
	±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
	±±³Uso       ³fSILTRNSF                                                   ³±±
	±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
	±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
	ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Static Function f550MO()

	Local xx, xz, xy
	Local cEmpMO

	Private aARQEXC  := {}
	Private aARQCOM  := {}

	/***** MODO EXCLUSIVO *****/
	/*
	TPN - MOVIMENTACOES DE CENTRO DE CUSTO
	ST9 - BEM
	TPE - SEGUNDO CONTADOR DO BEM
	STB - CARACTERISTICAS DO BEM
	TPY - PECAS DE REPOSICAO
	STC - ESTRUTURA DE BENS
	STZ - MOVIMENTACAO DE ESTRUTURA
	STF - MANUTENCOES DO BEM
	ST5 - TAREFAS DA MANUTENCAO
	STM - DEPENDENCIA DA MANUTENCAO
	STG - INSUMOS DA MANUTENCAO
	STH - ETAPAS DA MANUTENCAO
	TP1 - OPCOES DA ETAPA DA MANUTENCAO
	TQS - COMPLEMENTO BENS - PNEUS*/

	/***** MODO COMPARTILHADO *****/
	/*
	ST6 - FAMILIA DE BENS
	SH7 - CALENDARIOS
	ST4 - SERVICOS DE MANUTENCAO
	TQ2 - HISTORICO MOVIMEN. ENTRE FILIAIS
	SI3 - CENTRO DE CUSTO/CTT - CENTRO DE CUSTO
	TQT - MEDIDAS DE PNEUS
	TQY - STATUS DO BEM
	TQU - DESEMPENHO DOS PNEUS (RECAPAGEM)
	*/

	AAdd(aARQEXC,{"ST9","ST9 - BEM"})
	AAdd(aARQEXC,{"TPE",STR0047}) //"TPE - SEGUNDO CONTADOR DO BEM"
	AAdd(aARQEXC,{"STC",STR0048}) //"STC - ESTRUTURA DE BENS"
	AAdd(aARQEXC,{"STZ",STR0049}) //"STZ - MOVIMENTACAO DE ESTRUTURA"
	AAdd(aARQEXC,{"TPN",STR0050}) //"TPN - MOVIMENTACOES DE CENTRO DE CUSTO"
	AAdd(aARQEXC,{"STB",STR0051}) //"STB - CARACTERISTICAS DO BEM"
	AAdd(aARQEXC,{"TPY",STR0052}) //"TPY - PECAS DE REPOSICAO"
	AAdd(aARQEXC,{"STF",STR0053}) //"STF - MANUTENCOES DO BEM"
	AAdd(aARQEXC,{"ST5",STR0054}) //"ST5 - TAREFAS DA MANUTENCAO"
	AAdd(aARQEXC,{"STM",STR0055}) //"STM - DEPENDENCIA DA MANUTENCAO"
	AAdd(aARQEXC,{"STG",STR0056}) //"STG - INSUMOS DA MANUTENCAO"
	AAdd(aARQEXC,{"STH",STR0057}) //"STH - ETAPAS DA MANUTENCAO"
	AAdd(aARQEXC,{"TP1",STR0058}) //"TP1 - OPCOES DA ETAPA DA MANUTENCAO"
	//Contador Exclusivo
	If lHistCom
		AAdd(aARQEXC,{"STP",STR0061}) //"STP - HISTORICO DE CONTADOR 1"
		AAdd(aARQEXC,{"TPP",STR0062}) //"TPP - HISTORICO DE CONTADOR 2"
	EndIf
	If lTQSInt .And. lFROInt
		AAdd(aARQEXC,{"TQS",STR0059}) //"TQS - COMPLEMENTO BENS - PNEUS"
		AAdd(aARQEXC,{"TQV",STR0184}) //"TQV - HIST. DE SULCO DE PNEUS"
		AAdd(aARQEXC,{"TQZ",STR0185}) //"TQZ - HISTORICO DE STATUS DE PNEUS"
		AAdd(aARQCOM,{"TQY",STR0186}) //"TQY - STATUS"
		AAdd(aARQCOM,{"TQU",STR0187}) //"TQU - CODIGO DESENHO"
	EndIf

	AAdd(aARQCOM,{"TQ2",STR0060}) //"TQ2 - HISTORICO MOVIMEN. ENTRE FILIAIS"
	AAdd(aARQCOM,{"ST6",STR0188}) //"ST6 - FAMILIA DE BENS"
	//Não necessário, pois já é validado através da função F550ST9T()
	//AAdd(aARQCOM,{"SH7",STR0189}) //"SH7 - CALENDARIOS"
	AAdd(aARQCOM,{"ST4",STR0190}) //"ST4 - SERVICOS DE MANUTENCAO"
	AAdd(aARQCOM,{"TQT",STR0191}) //"TQT - MEDIDAS DE PNEUS"

	For xy := 1 To 2
		For xz := 1 To Len(aARQEXC)
			If FWModeAccess(aARQEXC[xz][1], 3, M->TQ2_EMPORI) <> "E"
				fGravPrb("SX2",,STR0063+aARQEXC[xz][2]+STR0064,3) //"Tabela/arquivo "###"deve estar no modo 'exclusivo'."
			EndIf
		Next xz
		For xx := 1 To Len(aARQCOM)
			If FWModeAccess(aARQCOM[xx][1], 3, M->TQ2_EMPORI) <> "C"
				fGravPrb("SX2",,STR0063+aARQCOM[xx][1]+STR0065,3) //"Tabela/Arquivo "###"deve estar no modo 'compartilhado'."
			EndIf
		Next xx
		//Abertura do SX2 na empresa destino
		cEmpMO := If(xy == 1,M->TQ2_EMPDES,M->TQ2_EMPORI)
	Next xy

Return Nil

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³fSI1A5VAR ³ Autor ³ Felipe Nathan Welter  ³ Data ³ 15/03/10 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³Alimenta variaveis e valida parametros                      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³fSILTRNSF                                                   ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Static Function fSI1A5VAR()

	Local lRet := .T.
	Local zz
	Local lGFrotas := IIf( FindFunction('MNTFrotas'), MNTFrotas(), GetNewPar('MV_NGMNTFR','N') == 'S')

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Filial/Empresa Origem/Destino ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	//---------------------------------------------------------------
	//---------------------------------------------------------------
	aAreaSM0 := SM0->(GetArea())

	If !Empty(M->TQ2_EMPORI) .And. !Empty(M->TQ2_FILORI)
		dbSelectArea("SM0")
		dbSetOrder(01)
		If !dbSeek(M->TQ2_EMPORI+M->TQ2_FILORI)
			fGravPrb("SM0",,STR0066,4) //"Filial não existe para a empresa origem."
			lRet := .F.
		EndIf
	Else
		fGravPrb("SM0",,STR0067,4) //"Filial/Empresa origem não foram informados."
		lRet := .F.
	EndIf

	If !Empty(M->TQ2_EMPDES) .And. !Empty(M->TQ2_FILDES)
		dbSelectArea("SM0")
		dbSetOrder(01)
		If !dbSeek(M->TQ2_EMPDES+M->TQ2_FILDES)
			fGravPrb("SM0",,STR0068,4) //"Filial não existe para a empresa destino."
			lRet := .F.
		EndIf
	Else
		fGravPrb("SM0",,STR0069,4) //"Filial/Empresa destino não foram informados."
		lRet := .F.
	EndIf

	RestArea(aAreaSM0)

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Bem                ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	//---------------------------------------------------------------
	//---------------------------------------------------------------
	NgPrepTbl({{"ST9"},{"TPE"},{"TQY"},{"STC"}},M->TQ2_EMPORI)
	dbSelectArea("ST9")
	dbSetOrder(01)
	If dbSeek(xFilial("ST9",M->TQ2_FILORI)+M->TQ2_CODBEM)
		If ST9->T9_SITBEM <> "A"
			If ST9->T9_SITBEM == "I"
				fGravPrb("ST9",,STR0070+AllTrim(M->TQ2_CODBEM)+STR0071,4) //"Situação do bem "###" é 'inativo', não pode ser transferido."
			ElseIf ST9->T9_SITBEM == "T"
				fGravPrb("ST9",,STR0072+AllTrim(M->TQ2_CODBEM)+STR0073,4) //"Situaçãoo do bem "###" é 'transferido', não pode ser transferido."
			EndIf
			lRet := .F.
		EndIf

		//Carrega variaveis para validacao de contadores
		TIPOACOM  := If(ST9->T9_TEMCONT = "S",.T.,.F.)
		TIPOACOM2 := If(TPE->(dbSeek(NGTROCAFILI("TPE",M->TQ2_FILORI,M->TQ2_EMPORI)+ST9->T9_CODBEM)),.T.,.F.)

	Else
		fGravPrb("ST9",,STR0074+AllTrim(M->TQ2_CODBEM)+STR0075,4) //"Bem "###" não localizado na empresa/filial de origem."
		lRet := .F.
	EndIf

	//-----------------------------------
	//Existencia do bem na nova filial
	//-----------------------------------
	nRecST9 := ST9->(RecNo())
	NgPrepTbl({{"ST9",01}},M->TQ2_EMPDES)
	If dbSeek(NGTROCAFILI("ST9",M->TQ2_FILDES,M->TQ2_EMPDES)+M->TQ2_CODBEM)
		If ST9->T9_SITBEM = "A"
			fGravPrb("ST9",,STR0076+AllTrim(M->TQ2_CODBEM)+STR0077,4) //"Já existe um bem "###" cadastrado e ativo para a nova empresa/filial."
			lRet := .F.
		EndIf
	EndIf
	NgPrepTbl({{"ST9",01}},M->TQ2_EMPORI)
	dbGoTo(nRecST9)

	If lChkCont
		If TIPOACOM
			If !CHKPOSLIM(M->TQ2_CODBEM,M->TQ2_POSCON,1,M->TQ2_FILORI) .Or. (M->TQ2_POSCON <= 0)
				fGravPrb("ST9",,STR0078+AllTrim(M->TQ2_CODBEM)+".",4) //"Inconsistência no limite do contador para o bem "
				lRet := .F.
			EndIf
		EndIf

		If TIPOACOM2
			If !CHKPOSLIM(M->TQ2_CODBEM,M->TQ2_POSCO2,2,M->TQ2_FILORI) .Or. (M->TQ2_POSCO2 <= 0)
				fGravPrb("TPE",,STR0078+AllTrim(M->TQ2_CODBEM)+".",4) //"Inconsistência no limite do contador para o bem "
				lRet := .F.
			EndIf
		EndIf
	EndIf

	//-------------------------------
	//Valida MV_NGBEMTR
	//-------------------------------
	cMsg := ""
	lCatOK := .T.
	nRecST9 := ST9->(RecNo())
	If !Empty( _cBemTran_ )
		dbSelectArea("TQY")
		dbSetOrder(01)
		If dbSeek(NGTROCAFILI("TQY",M->TQ2_FILORI,M->TQ2_EMPORI)+ _cBemTran_)
			If !Empty(TQY->TQY_CATBEM) .And. TQY->TQY_CATBEM != ST9->T9_CATBEM
				lCatOK := .F.
			Else
				dbSelectArea("STC")
				dbSetOrder(01)
				dbSeek(NGTROCAFILI("STC",M->TQ2_FILORI,M->TQ2_EMPORI)+M->TQ2_CODBEM,.T.)
				While !Eof() .And. STC->TC_CODBEM == M->TQ2_CODBEM
					dbSelectArea("ST9")
					dbSetOrder(01)
					If dbSeek(NGTROCAFILI("ST9",M->TQ2_FILORI,M->TQ2_EMPORI)+STC->TC_COMPONE)
						If !Empty(TQY->TQY_CATBEM) .And. TQY->TQY_CATBEM != ST9->T9_CATBEM
							lCatOK := .F.
						EndIf
					EndIf
					dbSelectArea("STC")
					dbSkip()
				EndDo
			EndIf
			If !lCatOK
				cMsg := STR0079 //"Categoria do status informada no parâmetro MV_NGBEMTR não é genérica "
				cMsg += STR0080 //"nem corresponde às categorias da família. Para realizar a transferência é "
				cMsg += STR0081 //"necessário que este parâmetro esteja associado a um status cadastrado, "
				cMsg += STR0082+AllTrim(M->TQ2_CODBEM)+")." //"com a categoria dos componentes da estrutura ou em branco ("
			EndIf
			dbSelectArea("ST9")
			dbGoTo(nRecST9)
		Else
			cMsg := STR0083 //"Nao existe status correspondente ao parâmetro MV_NGBEMTR. Para realizar "
			cMsg += STR0084 //"a transferência é necessário que este parâmetro esteja associado a um status "
			cMsg += STR0027 //"cadastrado, com a categoria dos componentes da estrutura ou em branco."
		EndIf
	Else
		cMsg := STR0085 //"Parâmetro MV_NGBEMTR (para status 'Transferido') está vazio. Para realizar "
		cMsg += STR0086 //"a transferência é necessário que este parâmetro esteja associado a um status"
		cMsg += STR0027 //"cadastrado, com a categoria dos componentes da estrutura ou em branco."
	EndIf

	If !Empty(cMsg)
		fGravPrb("TQY",,cMsg,4)
		lRet := .F.
	EndIf

	//Armazena Centro de Custo e Centro de Trabalho
	M->TQ2_CCUSTO := If(M->TQ2_CCUSTO==Nil,ST9->T9_CCUSTO,M->TQ2_CCUSTO)
	M->TQ2_CENTRA := If(M->TQ2_CENTRA==Nil,ST9->T9_CENTRAB,M->TQ2_CENTRA)

	NgPrepTbl({{"ST9",01},{"TPE",01},{"TQY",01},{"STC",01}},SM0->M0_CODIGO)

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Contador           ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	//---------------------------------------------------------------
	//---------------------------------------------------------------
	//Valida data/hora de transferencia com o ultimo acompanhamento do bem (contador 1/contador 2)
	If lChkCont
		NgPrepTbl({{"ST9"},{"TPE"}},M->TQ2_EMPORI)
		If !f550CKCON()
			fGravPrb("STP",,STR0087+AllTrim(M->TQ2_CODBEM)+").",4) //"Encontrados problemas nos contadores do bem/estrutura ("
			lRet := .F.
		EndIf
		NgPrepTbl({{"ST9"},{"TPE"}},SM0->M0_CODIGO)
	EndIf

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ C. Custo/C. Trab.  ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	//---------------------------------------------------------------
	//---------------------------------------------------------------
	If Empty(M->TQ2_CCUSTO)
		fGravPrb(cF3CTTSI3,,STR0088,4) //"Centro de custo não informado."
		lRet := .F.
	ElseIf !fSilSEEK(cF3CTTSI3,M->TQ2_CCUSTO,01,M->TQ2_FILDES,M->TQ2_EMPDES)
		fGravPrb(cF3CTTSI3,,STR0089+AllTrim(M->TQ2_CCUSTO)+STR0090+AllTrim(M->TQ2_CODBEM)+STR0091,4) //"Centro de custo "###" do bem "###" é inválido."
		lRet := .F.
	Else
		If !Empty(M->TQ2_CENTRA)

			If !fSilSEEK("SHB",M->TQ2_CENTRA,01,M->TQ2_FILDES,M->TQ2_EMPDES)
				fGravPrb("SHB","T9_CENTRAB",STR0092+AllTrim(M->TQ2_CENTRA)+STR0093,0) //"Centro de trabalho "###" não cadastrado para a filial de destino."
				lRet := .F.
				M->TQ2_CENTRA := ""
			ElseIf NGSEEK("SHB",M->TQ2_CENTRA,01,"HB_CC",M->TQ2_FILDES,M->TQ2_EMPDES) <> M->TQ2_CCUSTO
				fGravPrb("SHB","T9_CENTRAB",STR0092+AllTrim(M->TQ2_CENTRA)+STR0094+AllTrim(M->TQ2_CCUSTO)+STR0095,0) //"Centro de trabalho "###" não está relacionado com o centro de custo "###" no destino."
				lRet := .F.
				M->TQ2_CENTRA := ""
			EndIf

		EndIf
	EndIf

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Estrutura                   ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	//---------------------------------------------------------------
	//---------------------------------------------------------------
	//valida estrutura
	cFilSTC := NGTROCAFILI("STC",M->TQ2_FILORI,M->TQ2_EMPORI)
	NgPrepTbl({{"STC"}},M->TQ2_EMPORI)
	aBEMTRA := NGCOMPEST(M->TQ2_CODBEM,"B",.F.,.F.,.F.,M->TQ2_FILORI,M->TQ2_EMPORI)
	dbSelectArea("STC")
	dbSetOrder(03)
	If dbSeek(cFilSTC+M->TQ2_CODBEM)
		fGravPrb("STC",,STR0074+AllTrim(M->TQ2_CODBEM)+STR0096,4) //"Bem "###" já faz parte de uma estrutura e/ou não é pai da estrutura."
		lRet := .F.
	EndIf
	NgPrepTbl({{"STC"}},SM0->M0_CODIGO)

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Ordens de Servico pendentes ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	//---------------------------------------------------------------
	//---------------------------------------------------------------
	//valida OS para bem pai
	cFilSTJ := NGTROCAFILI("STJ",M->TQ2_FILORI,M->TQ2_EMPORI)
	NgPrepTbl({{"STJ",02}},M->TQ2_EMPORI)
	If dbSeek(cFilSTJ+"B"+M->TQ2_CODBEM)
		While !Eof() .And. STJ->TJ_FILIAL = cFilSTJ .And. STJ->TJ_TIPOOS = "B" .And. STJ->TJ_CODBEM = M->TQ2_CODBEM
			If STJ->TJ_TERMINO = "N" .And. STJ->TJ_SITUACA $ "LP"
				fGravPrb("STJ",,STR0097+STJ->TJ_ORDEM+STR0098+AllTrim(M->TQ2_CODBEM)+".",4) //"Existem ordens de serviço ("###") liberadas/pendentes para o bem "
				lRet := .F.
				Exit
			EndIf
			dbSkip()
		EndDo
	EndIf

	//valida OS para componentes da estrutura
	For zz := 1 To Len(aBEMTRA)
		dbSelectArea("STJ")
		dbSetOrder(02)
		If dbSeek(cFilSTJ+"B"+aBEMTRA[zz])
			While !Eof() .And. STJ->TJ_FILIAL = cFilSTJ .And. STJ->TJ_TIPOOS = "B" .And. STJ->TJ_CODBEM = aBEMTRA[zz]
				If STJ->TJ_TERMINO = "N" .And. STJ->TJ_SITUACA $ "LP"
					fGravPrb("STJ",,STR0099+STJ->TJ_ORDEM+STR0100+AllTrim(aBEMTRA[zz])+" ("+AllTrim(M->TQ2_CODBEM)+").",4) //"Existem ordens de serivço ("###") liberadas/pendentes para componente: "
					lRet := .F.
					Exit
				EndIf
				dbSelectArea("STJ")
				dbSkip()
			EndDo
		EndIf
	Next zz
	NgPrepTbl({{"STJ"}},SM0->M0_CODIGO)

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Ordens de Acomp. pendentes ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	//---------------------------------------------------------------
	//---------------------------------------------------------------
	//Consiste OS de acompanhamento abertas para o bem pai
	cFilTQA := NGTROCAFILI("TQA",M->TQ2_FILORI,M->TQ2_EMPORI)
	NgPrepTbl({{"TQA",02}},M->TQ2_EMPORI)
	If dbSeek(cFilTQA+M->TQ2_CODBEM)
		While !Eof() .And. TQA->TQA_FILIAL = cFilTQA .And. TQA->TQA_CODBEM = M->TQ2_CODBEM
			If TQA->TQA_TERMIN = "N" .And. TQA->TQA_SITUAC $ "LP"
				fGravPrb("TQA",,STR0101+AllTrim(M->TQ2_CODBEM)+".",4) //"Existem ordens de acompanhamento liberadas/pendentes para o bem "
				lRet := .F.
				Exit
			EndIf
			dbSkip()
		EndDo
	EndIf

	//Consiste OS de acompanhamento abertas para componentes da estrutura
	For zz := 1 To Len(aBEMTRA)
		dbSelectArea("TQA")
		dbSetOrder(02)
		If dbSeek(cFilTQA+aBEMTRA[zz])
			While !Eof() .And. TQA->TQA_FILIAL = cFilTQA .And. TQA->TQA_CODBEM = aBEMTRA[zz]
				If TQA->TQA_TERMIN = "N" .And. TQA->TQA_SITUAC $ "LP"
					fGravPrb("TQA",,STR0102+AllTrim(aBEMTRA[zz])+" ("+AllTrim(M->TQ2_CODBEM)+").",4) //"Existem ordens de acompanhamento liberadas/pendentes para componente: "
					lRet := .F.
					Exit
				EndIf
				dbSkip()
			EndDo
		EndIf
	Next zz
	NgPrepTbl({{"TQA",02}},SM0->M0_CODIGO)

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Inconsistencias Abastecim. ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	//---------------------------------------------------------------
	//---------------------------------------------------------------
	cFilTQQ := NGTROCAFILI("TQQ",M->TQ2_FILORI,M->TQ2_EMPORI)
	cFilST9 := NGTROCAFILI("ST9",M->TQ2_FILORI,M->TQ2_EMPORI)
	NgPrepTbl({{"ST9"},{"TQQ"}},M->TQ2_EMPORI)

	If lGFrotas

		// Consiste as inconsistencias de abastecimentos para bem pai
		dbSelectArea("ST9")
		dbSetOrder(01)
		If dbSeek(cFilST9+M->TQ2_CODBEM)
			If !Empty(ST9->T9_PLACA)
				dbSelectArea("TQQ")
				dbSetOrder(03)
				If dbSeek(cFilTQQ+ST9->T9_PLACA)
					fGravPrb("TQQ",,STR0103+AllTrim(M->TQ2_CODBEM)+".",4) //"Foram localizados registros de abastecimentos inconsistentes para o bem "
					lRet := .F.
				EndIf
			EndIf
		EndIf

		// Consiste as inconsistencias de abastecimentos para componentes da estrutura
		For zz := 1 To Len(aBEMTRA)
			dbSelectArea("ST9")
			dbSetOrder(01)
			If dbSeek(cFilST9+aBEMTRA[zz])
				If !Empty(ST9->T9_PLACA)
					dbSelectArea("TQQ")
					dbSetOrder(03)
					If dbSeek(cFilTQQ+ST9->T9_PLACA)
						fGravPrb("TQQ",,STR0104+AllTrim(aBEMTRA[zz])+" ("+AllTrim(M->TQ2_CODBEM)+").",4) //"Foram localizados registros de abastecimentos inconsistentes para componente: "
						lRet := .F.
					EndIf
				EndIf
			EndIf
		Next zz
	EndIf
	NgPrepTbl({{"ST9"},{"TQQ"}},SM0->M0_CODIGO)

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Solicitacoes de Servico    ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	//---------------------------------------------------------------
	//---------------------------------------------------------------
	cFilTQB := NGTROCAFILI("TQB",M->TQ2_FILORI,M->TQ2_EMPORI)
	cFilST9 := NGTROCAFILI("ST9",M->TQ2_FILORI,M->TQ2_EMPORI)
	NgPrepTbl({{"TQB"}},M->TQ2_EMPORI)
	// Consiste as solicitacoes de servico abertas para bem pai
	dbSelectArea("TQB")
	dbSetOrder(05)
	If dbSeek(cFilTQB+M->TQ2_CODBEM)
		While !Eof() .And. TQB->TQB_FILIAL == cFilTQB .And. TQB->TQB_CODBEM == M->TQ2_CODBEM
			If TQB->TQB_SOLUCA $ "AD"
				fGravPrb("TQB",,STR0105+AllTrim(M->TQ2_CODBEM)+".",4) //"Existem solicitações de serviço distribuídas e/ou aguardando análise para o bem "
				lRet := .F.
				Exit
			EndIf
			dbSkip()
		EndDo
	EndIf

	// Consiste as solicitacoes de servico abertas para componentes da estrutura
	For zz := 1 To Len(aBEMTRA)
		dbSelectArea("TQB")
		dbSetOrder(05)
		If dbSeek(cFilTQB+aBEMTRA[zz])
			While !Eof() .And. TQB->TQB_FILIAL == cFilTQB .And. TQB->TQB_CODBEM == aBEMTRA[zz]
				If TQB->TQB_SOLUCA $ "AD"
					fGravPrb("TQQ",,STR0106+; //"Existem solicitações de serviço distribuídas e/ou aguardando análise para componente: "
					AllTrim(aBEMTRA[zz])+" ("+AllTrim(M->TQ2_CODBEM)+").",4)
					lRet := .F.
					Exit
				EndIf
				dbSkip()
			EndDo
		EndIf
	Next zz
	NgPrepTbl({{"TQB"}},SM0->M0_CODIGO)

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Ordem de Servico de transferencia  ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	//---------------------------------------------------------------
	//---------------------------------------------------------------
	cFilSTJ := NGTROCAFILI("STJ",M->TQ2_FILORI,M->TQ2_EMPORI)
	NgPrepTbl({{"STJ"}},M->TQ2_EMPORI)

	If lObrigOS .And. Empty(M->TQ2_ORDEM)
		fGravPrb("STJ",,STR0107+AllTrim(M->TQ2_CODBEM)+".",4) //"Ordem de serviço não foi informada para o bem "
		lRet := .F.
	EndIf

	If !Empty(M->TQ2_ORDEM)
		dbSelectArea("STJ")
		dbSetOrder(01)
		If !dbSeek(cFilSTJ+M->TQ2_ORDEM)
			fGravPrb("STJ",,STR0108+AllTrim(M->TQ2_ORDEM)+STR0109,4) //"Ordem de serviço "###" não cadastrada."
			lRet := .F.
		Else
			If STJ->TJ_CODBEM <> M->TQ2_CODBEM
				fGravPrb("STJ",,STR0108+AllTrim(M->TQ2_ORDEM)+STR0110+AllTrim(M->TQ2_CODBEM)+".",4) //"Ordem de serviço "###" não pertence ao bem "
				lRet := .F.
			Else
				If !(STJ->TJ_SITUACA == "L" .And. STJ->TJ_TERMINO == "S")
					fGravPrb("STJ",,STR0108+AllTrim(M->TQ2_ORDEM)+STR0111,4) //"Ordem de serviço "###" não liberada/terminada."
					lRet := .F.
				EndIf
			EndIf
		EndIf
	EndIf
	NgPrepTbl({{"STJ"}},SM0->M0_CODIGO)

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Causa              ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	//---------------------------------------------------------------
	//---------------------------------------------------------------
	NgPrepTbl({{"ST8"}},M->TQ2_EMPORI)

	If Empty(M->TQ2_CAUSA)
		If fSilSEEK("STC",M->TQ2_CODBEM,01,M->TQ2_FILORI,M->TQ2_EMPORI)
			fGravPrb("ST8",,STR0112+AllTrim(M->TQ2_CODBEM)+").",4) //"Codigo da causa de remoção não informado. Obrigatório quando o bem possui estrutura ("
		EndIf
	Else
		dbSelectArea("ST8")
		dbSetOrder(01)
		If !dbSeek(NGTROCAFILI("ST8",M->TQ2_FILORI,M->TQ2_EMPORI)+M->TQ2_CAUSA+"C")
			fGravPrb("ST8",,STR0113+AllTrim(M->TQ2_CAUSA)+STR0114,4) //"Causa de remoção "###" inválida."
			lRet := .F.
		EndIf
	EndIf
	NgPrepTbl({{"ST8"}},SM0->M0_CODIGO)

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Motivo             ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	//---------------------------------------------------------------
	//---------------------------------------------------------------
	If Empty(M->TQ2_MOTTRA)
		fGravPrb("",,STR0115+AllTrim(M->TQ2_CODBEM)+".",4) //"Motivo de tranferência não foi informado para o bem "
		lRet := .F.
	EndIf

Return lRet

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³f550CKCON ³ Autor ³ Felipe Nathan Welter  ³ Data ³ 15/03/10 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³Verifica se a data/hora de transferencia do bem pai e compo-³±±
±±³          ³nentes com contador proprio e' maior que o ultimo lancamento³±±
±±³          ³de historico.                                               ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³fSI1A5VAR                                                   ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Static Function f550CKCON()
	Local zx := 0, vVETCON := {}
	Local cMsg := ""

	If TIPOACOM
		//Verifica se a data/hora e maior que o ultimo lancamento do historico
		vVETCON := A550CBEM(M->TQ2_CODBEM,M->TQ2_DATATR,M->TQ2_HORATR,1)  //funcao mantida pois STP e TPP sao compartilhadas em multiempresa
		If !Empty(vVETCON)
			cMsg := STR0116+; //"Data/hora de transferência é menor ou igual ao último acompanhamento do contador 1."
			STR0117+Alltrim(vVETCON[1])+STR0118+DTOC(vVETCON[2])+STR0119+vVETCON[3]+STR0120+Str(vVETCON[4],9)+; //"  Bem: "###"  Dt.Ult.Acomp.: "###"  Hora: "###"  Contador: "
			STR0121+; //"  Data e hora de transferência deve ser maior que o último acomp. do bem a ser transferido e todos os componentes pertencentes a"
			STR0122 //" estrutura controlados por contador próprio."
			fGravPrb("STP",,cMsg,4)
			lRet := .F.
		EndIf
	EndIf

	If TIPOACOM2
		//Verifica se a data/hora e maior que o ultimo lancamento do historico
		vVETCON := A550CBEM(M->TQ2_CODBEM,M->TQ2_DATATR,M->TQ2_HORATR,2)  //funcao mantida pois STP e TPP sao compartilhadas em multiempresa
		If !Empty(vVETCON)
			cMsg := STR0123+; //"Data/hora de transferência é menor ou igual ao último acompanhamento do contador 2."
			STR0117+Alltrim(vVETCON[1])+STR0124+DTOC(vVETCON[2])+STR0125+vVETCON[3]+STR0126+Str(vVETCON[4],9)+; //"  Bem: "###" Dt.Ult.Acomp.: "###" Hora: "###" Contador: "
			STR0127+; //"  Data e hora de transferência deve ser maior que o último acomp. do bem a ser transferido e todos os componentes pertencentes a "
			STR0122 //" estrutura controlados por contador próprio."
			fGravPrb("TPP",,cMsg,4)
			lRet := .F.
		EndIf
	EndIf

	cFilSTC := NGTROCAFILI("STC",M->TQ2_FILORI,M->TQ2_EMPORI)
	cFilST9 := NGTROCAFILI("ST9",M->TQ2_FILORI,M->TQ2_EMPORI)
	cFilTPE := NGTROCAFILI("TPE",M->TQ2_FILORI,M->TQ2_EMPORI)

	NgPrepTbl({{"STC"},{"ST9"},{"TPE"}},M->TQ2_EMPORI)

	dbSelectArea("STC")
	dbSetOrder(01)
	If dbSeek(cFilSTC+M->TQ2_CODBEM)
		aBEMTRA := NGCOMPEST(M->TQ2_CODBEM,"B",.F.,.F.,.F.,M->TQ2_FILORI,M->TQ2_EMPORI)
		For zx := 1 To Len(aBEMTRA)
			dbSelectArea("ST9")
			dbSetOrder(01)
			If dbSeek(cFilST9+aBEMTRA[zx])
				If ST9->T9_TEMCONT = "S"
					//Verifica se a data/hora e maior que o ultimo lancamento do historico
					vVETCON := A550CBEM(ST9->T9_CODBEM,M->TQ2_DATATR,M->TQ2_HORATR,1)  //funcao mantida pois STP e TPP sao compartilhadas em multiempresa
					If !Empty(vVETCON)
						cMsg := STR0128+; //"Data/hora de transferência é menor ou igual ao último acompanhamento do contador 1 do componente."
						STR0117+Alltrim(vVETCON[1])+STR0118+DTOC(vVETCON[2])+STR0119+vVETCON[3]+STR0120+Str(vVETCON[4],9)+; //"  Bem: "###"  Dt.Ult.Acomp.: "###"  Hora: "###"  Contador: "
						STR0121+; //"  Data e hora de transferência deve ser maior que o último acomp. do bem a ser transferido e todos os componentes pertencentes a"
						STR0129 //"estrutura controlados por contador próprio."
						fGravPrb("STP",,cMsg,4)
						lRet := .F.
					EndIf

					dbSelectArea("TPE")
					dbSetOrder(01)
					If dbSeek(cFilTPE+aBEMTRA[zx])
						//Verifica se a data/hora e maior que o ultimo lancamento do historico
						vVETCON := A550CBEM(ST9->T9_CODBEM,M->TQ2_DATATR,M->TQ2_HORATR,2)  //funcao mantida pois STP e TPP sao compartilhadas em multiempresa
						If !Empty(vVETCON)
							cMsg := STR0130+; //"Data/hora de transferência é menor ou igual ao último acompanhamento do contador 2 do componente."
							STR0117+Alltrim(vVETCON[1])+STR0124+DTOC(vVETCON[2])+STR0125+vVETCON[3]+STR0126+Str(vVETCON[4],9)+; //"  Bem: "###" Dt.Ult.Acomp.: "###" Hora: "###" Contador: "
							STR0127+; //"  Data e hora de transferência deve ser maior que o último acomp. do bem a ser transferido e todos os componentes pertencentes a "
							STR0129 //"estrutura controlados por contador próprio."
							fGravPrb("TPP",,cMsg,4)
							lRet := .F.
						EndIf
					EndIf
				EndIf
			EndIf
		Next zx
	EndIf

	NgPrepTbl({{"STC"},{"ST9"},{"TPE"}},SM0->M0_CODIGO)

Return .T.

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³f550TMANU ³ Autor ³Felipe Nathan Welter   ³ Data ³ 15/03/10 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³Transferencia das manutencoes                               ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³SIGAMNT                                                     ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Static Function f550TMANU(cCODBEMTRA)
	Local i, nn,lPROBSTG := .F.

	//---------------------------------------------------------------
	//CRIA ARQUIVO TEMPORARIO COM OS DADOS DA FILIAL DE ORIGEM
	cFilSTF := NGTROCAFILI("STF",M->TQ2_FILORI,M->TQ2_EMPORI)
	NgPrepTbl({{"STF",01}},M->TQ2_EMPORI)
	dbSeek(cFilSTF+cCODBEMTRA)
	While !Eof() .And. STF->TF_FILIAL == cFilSTF .And. STF->TF_CODBEM == cCODBEMTRA

		dbSelectArea(cTRBSTF)
		// Faz uma copia do STF
		RecLock((cTRBSTF),.T.)
		For i := 1 TO FCOUNT()
			pp := "STF->"+ FieldName(i)
			vl := "(cTRBSTF)->"+ FieldName(i)
			&vl. := &pp.
		Next i
		(cTRBSTF)->(MsUnLock())

		dbSelectArea("STF")
		RecLock("STF",.F.)
		STF->TF_ATIVO := "N"
		MsUnLock("STF")
		dbSkip()
	End

	//CRIA NOVOS REGISTROS NA FILIAL DE DESTINO
	cFilSTF := NGTROCAFILI("STF",M->TQ2_FILDES,M->TQ2_EMPDES)
	NgPrepTbl({{"STF",01}},M->TQ2_EMPDES)
	dbSelectArea(cTRBSTF)
	dbGoTop()
	While !Eof()
		dbSelectArea("STF")
		dbSetOrder(01)
		If !dbSeek(cFilSTF+(cTRBSTF)->TF_CODBEM+(cTRBSTF)->TF_SERVICO+(cTRBSTF)->TF_SEQRELA)
			//Cria um novo STF com a nova filial
			RecLock("STF",.T.)
			For i := 1 TO FCOUNT()
				nn := FieldName(i)
				pp := "STF->"+ FieldName(i)
				vl := "(cTRBSTF)->"+ FieldName(i)
				If nn == "TF_DOCTO" .Or. nn == "TF_DOCFIL"
					If fChkArquivo("QDH")
						&pp. := &vl.
					Else
						&pp. := " "
					EndIf
				ElseIf nn == "TF_ATIVO" .And. (&vl. == " " .Or. &vl. == "S" ) //ADD para tratar manutenção inativa na filial destino
					&pp. := "S"
				ElseIf nn == "TF_FILIAL"
					&pp. := cFilSTF
				Else
					&pp. := &vl.
				EndIf
			Next i
			STF->(MsUnLock())
		Else
			dbSelectArea("STF")
			RecLock("STF",.F.)
			For i := 1 TO FCOUNT()

				nn := FieldName(i)
				pp := "STF->"+ FieldName(i)
				vl := "(cTRBSTF)->"+ FieldName(i)

				If nn == "TF_DOCTO" .Or. nn == "TF_DOCFIL"
					If fChkArquivo("QDH")
						&pp. := &vl.
					Else
						&pp. := " "
					EndIf
				ElseIf nn <> "TF_FILIAL"
					&pp. := &vl.
				EndIf
			Next i
			STF->(MsUnLock())
		EndIf

		f550BANCON(cCODBEMTRA+(cTRBSTF)->TF_SERVICO+(cTRBSTF)->TF_SEQRELA,"STF",M->TQ2_FILORI,M->TQ2_EMPORI,M->TQ2_FILDES,M->TQ2_EMPDES) //Faz a tranferencia do banco do conhecimento

		dbSelectArea(cTRBSTF)
		dbSkip()
	End

	NgPrepTbl({{"STF",01}},SM0->M0_CODIGO)

	//---------------------------------------------------------------
	//CRIA ARQUIVO TEMPORARIO COM OS DADOS DA FILIAL DE ORIGEM
	cFilST5 := NGTROCAFILI("ST5",M->TQ2_FILORI,M->TQ2_EMPORI)
	NgPrepTbl({{"ST5",01}},M->TQ2_EMPORI)
	dbSeek(cFilST5+cCODBEMTRA)
	While !Eof() .And. ST5->T5_FILIAL == cFilST5 .And. ST5->T5_CODBEM == cCODBEMTRA
		// Faz uma copia do ST5
		dbSelectArea(cTRBST5)
		RecLock((cTRBST5),.T.)
		For i := 1 TO FCOUNT()
			pp := "ST5->"+ FieldName(i)
			vl := "(cTRBST5)->"+ FieldName(i)
			&vl. := &pp.
		Next i
		(cTRBST5)->(MsUnLock())
		dbSelectArea("ST5")
		dbSkip()
	End

	//DELETE REGISTRO NA FILIAL DE DESTINO
	cFilST5 := NGTROCAFILI("ST5",M->TQ2_FILDES,M->TQ2_EMPDES)
	NgPrepTbl({{"ST5",01}},M->TQ2_EMPDES)
	dbSeek(cFilST5+cCODBEMTRA)
	While !Eof() .And. ST5->T5_FILIAL == cFilST5 .And. ST5->T5_CODBEM == cCODBEMTRA
		RecLock("ST5",.F.)
		ST5->(dbDelete())
		ST5->(MsUnLock())
		dbSelectArea('ST5')
		dbSkip()
	End

	//CRIA NOVOS REGISTROS NA FILIAL DE DESTINO
	dbSelectArea(cTRBST5)
	dbGoTop()
	While !Eof()
		dbSelectArea("ST5")
		If !dbSeek(cFilST5+(cTRBST5)->T5_CODBEM+(cTRBST5)->T5_SERVICO+(cTRBST5)->T5_SEQRELA+(cTRBST5)->T5_TAREFA)
			//Cria um novo ST5 com a nova filial
			RecLock("ST5",.T.)
			For i := 1 TO FCOUNT()
				nn := FieldName(i)
				pp := "ST5->"+ FieldName(i)
				vl := "(cTRBST5)->"+ FieldName(i)

				If nn == "T5_DOCTO" .Or. nn == "T5_DOCFIL"
					If fChkArquivo("QDH")
						&pp. := &vl.
					EndIf
				ElseIf nn == "T5_FILIAL"
					&pp. := cFilST5
				Else
					&pp. := &vl.
				EndIf

			Next i
			ST5->(MsUnLock())
		EndIf
		dbSelectArea(cTRBST5)
		dbSkip()
	End

	NgPrepTbl({{"ST5",01}},SM0->M0_CODIGO)

	//---------------------------------------------------------------
	//CRIA ARQUIVO TEMPORARIO COM OS DADOS DA FILIAL DE ORIGEM
	cFilSTM := NGTROCAFILI("STM",M->TQ2_FILORI,M->TQ2_EMPORI)
	NgPrepTbl({{"STM",01}},M->TQ2_EMPORI)
	dbSeek(cFilSTM+cCODBEMTRA)
	While !Eof() .And. STM->TM_FILIAL == cFilSTM .And. STM->TM_CODBEM == cCODBEMTRA
		// Faz uma copia do STM
		dbSelectArea(cTRBSTM)
		RecLock((cTRBSTM),.T.)
		For i := 1 TO FCOUNT()
			pp := "STM->"+ FieldName(i)
			vl := "(cTRBSTM)->"+ FieldName(i)
			&vl. := &pp.
		Next i
		(cTRBSTM)->(MsUnLock())
		dbSelectArea("STM")
		dbSkip()
	End

	//DELETE REGISTRO NA FILIAL DE DESTINO
	cFilSTM := NGTROCAFILI("STM",M->TQ2_FILDES,M->TQ2_EMPDES)
	NgPrepTbl({{"STM",01}},M->TQ2_EMPDES)
	dbSeek(cFilSTM+cCODBEMTRA)
	While !Eof() .And. STM->TM_FILIAL == cFilSTM .And. STM->TM_CODBEM == cCODBEMTRA
		RecLock("STM",.F.)
		STM->(dbDelete())
		STM->(MsUnLock())
		dbSelectArea("STM")
		dbSkip()
	End

	//---------------------------------------------------------------
	//CRIA NOVOS REGISTROS NA FILIAL DE DESTINO
	dbSelectArea(cTRBSTM)
	dbGoTop()
	While !Eof()
		dbSelectArea("STM")
		If !dbSeek(cFilSTM+(cTRBSTM)->TM_CODBEM+(cTRBSTM)->TM_SERVICO+(cTRBSTM)->TM_SEQRELA+(cTRBSTM)->TM_TAREFA+(cTRBSTM)->TM_DEPENDE)
			//Cria um novo STM com a nova filial
			RecLock("STM",.T.)
			For i := 1 TO FCOUNT()
				pp := "STM->"+ FieldName(i)
				vl := "(cTRBSTM)->"+ FieldName(i)
				&pp. := &vl.
			Next i
			STM->TM_FILIAL := cFilSTM
			STM->(MsUnLock())
		EndIf
		dbSelectArea(cTRBSTM)
		dbSkip()
	EndDo

	NgPrepTbl({{"STM",01}},SM0->M0_CODIGO)

	//---------------------------------------------------------------
	//CRIA ARQUIVO TEMPORARIO COM OS DADOS DA FILIAL DE ORIGEM
	cFilSTG := NGTROCAFILI("STG",M->TQ2_FILORI,M->TQ2_EMPORI)
	NgPrepTbl({{"STG",01}},M->TQ2_EMPORI)
	dbSeek(cFilSTG+cCODBEMTRA)
	While !Eof() .And. STG->TG_FILIAL == cFilSTG .And. STG->TG_CODBEM == cCODBEMTRA
		// Faz uma copia do STG
		dbSelectArea(cTRBSTG)
		RecLock((cTRBSTG),.T.)
		For i := 1 TO FCOUNT()
			pp := "STG->"+ FieldName(i)
			vl := "(cTRBSTG)->"+ FieldName(i)
			&vl. := &pp.
		Next i
		(cTRBSTG)->(MsUnLock())
		dbSelectArea("STG")
		dbSkip()
	End

	//DELETE REGISTRO NA FILIAL DE DESTINO
	cFilSTG := NGTROCAFILI("STG",M->TQ2_FILDES,M->TQ2_EMPDES)
	NgPrepTbl({{"STG",01}},M->TQ2_EMPDES)
	dbSeek(cFilSTG+cCODBEMTRA)
	While !Eof() .And. STG->TG_FILIAL == cFilSTG .And. STG->TG_CODBEM == cCODBEMTRA
		RecLock("STG",.F.)
		STG->(dbDelete())
		STG->(MsUnLock())
		dbSelectArea("STG")
		dbSkip()
	End

	NgPrepTbl({{"STF"}},M->TQ2_EMPDES)
	//CRIA NOVOS REGISTROS NA FILIAL DE DESTINO
	dbSelectArea(cTRBSTG)
	dbGoTop()
	While !Eof()
		dbSelectArea("STG")
		If !dbSeek(cFilSTG+(cTRBSTG)->TG_CODBEM+(cTRBSTG)->TG_SERVICO+(cTRBSTG)->TG_SEQRELA+(cTRBSTG)->TG_TAREFA+(cTRBSTG)->TG_TIPOREG+(cTRBSTG)->TG_CODIGO)
			//ST0 DEVE SER COMPARTILHADA e Produto Exclusivo
			lPROBSTG := .F.
			If (;
			((cTRBSTG)->TG_TIPOREG == "M" .And. !(fChkArquivo("ST1") .Or. fSilSEEK("ST1",STG->TG_CODIGO,01,M->TQ2_FILDES,M->TQ2_EMPDES))) .Or.;
			((cTRBSTG)->TG_TIPOREG == "E" .And. !(fChkArquivo("ST0") .Or. fSilSEEK("ST0",STG->TG_CODIGO,01,M->TQ2_FILDES,M->TQ2_EMPDES))) .Or.;
			((cTRBSTG)->TG_TIPOREG == "P" .And. !((fChkArquivo("SB1") .Or. fSilSEEK("SB1",STG->TG_CODIGO,01,M->TQ2_FILDES,M->TQ2_EMPDES)) .Or.;
			(fChkArquivo("SAH") .Or. fSilSEEK("SAH",STG->TG_CODIGO,01,M->TQ2_FILDES,M->TQ2_EMPDES)))) .Or.;
			((cTRBSTG)->TG_TIPOREG == "F" .And. !(fChkArquivo("SH4") .Or. fSilSEEK("SH4",STG->TG_CODIGO,01,M->TQ2_FILDES,M->TQ2_EMPDES))) .Or.;
			((cTRBSTG)->TG_TIPOREG == "T" .And. !(fChkArquivo("SA2") .Or. fSilSEEK("SA2",STG->TG_CODIGO,01,M->TQ2_FILDES,M->TQ2_EMPDES)));
			)

				lPROBSTG := .T.
				EndIf

			If lPROBSTG
				//Inativa a manutencao e nao grava o insumo na filial destino
				NgPrepTbl({{"STF",01}},M->TQ2_EMPDES)
				If dbSeek(cFilSTF+(cTRBSTG)->TG_CODBEM+(cTRBSTG)->TG_SERVICO+(cTRBSTG)->TG_SEQRELA)
					RecLock("STF",.F.)
					STF->TF_ATIVO := "N"
					STF->(MsUnLock())
				EndIf
				NgPrepTbl({{"STF",01}},SM0->M0_CODIGO)
				dbSelectArea(cTRBSTG)
				dbSkip()
				Loop
			EndIf

			//Cria um novo STG com a nova filial
			dbSelectArea("STG")
			RecLock("STG",.T.)
			For i := 1 TO FCOUNT()
				pp := "STG->"+ FieldName(i)
				vl := "(cTRBSTG)->"+ FieldName(i)
				&pp. := &vl.
			Next i
			STG->TG_FILIAL := cFilSTG
			STG->(MsUnLock())

		EndIf
		dbSelectArea(cTRBSTG)
		dbSkip()
	End
	NgPrepTbl({{"STF"},{"STG"}},SM0->M0_CODIGO)

	//---------------------------------------------------------------
	//CRIA ARQUIVO TEMPORARIO COM OS DADOS DA FILIAL DE ORIGEM
	cFilSTH := NGTROCAFILI("STH",M->TQ2_FILORI,M->TQ2_EMPORI)
	NgPrepTbl({{"STH",01}},M->TQ2_EMPORI)
	dbSeek(cFilSTH+cCODBEMTRA)
	While !Eof() .And. STH->TH_FILIAL == cFilSTH .And. STH->TH_CODBEM == cCODBEMTRA
		// Faz uma copia do STH
		dbSelectArea(cTRBSTH)
		RecLock((cTRBSTH),.T.)
		For i := 1 TO FCOUNT()
			pp := "STH->"+ FieldName(i)
			vl := "(cTRBSTH)->"+ FieldName(i)
			&vl. := &pp.
		Next i
		(cTRBSTH)->(MsUnLock())
		dbSelectArea("STH")
		dbSkip()
	EndDo

	//DELETE REGISTRO NA FILIAL DE DESTINO
	cFilSTH := NGTROCAFILI("STH",M->TQ2_FILDES,M->TQ2_EMPDES)
	NgPrepTbl({{"STH",01}},M->TQ2_EMPDES)
	dbSeek(cFilSTH+cCODBEMTRA)
	While !Eof() .And. STH->TH_FILIAL == cFilSTH .And. STH->TH_CODBEM == cCODBEMTRA
		RecLock("STH",.F.)
		STH->(dbDelete())
		STH->(MsUnLock())
		dbSelectArea("STH")
		dbSkip()
	End

	//CRIA NOVOS REGISTROS NA FILIAL DE DESTINO
	dbSelectArea(cTRBSTH)
	dbGoTop()
	While !Eof()
		dbSelectArea("STH")
		If (fChkArquivo("TPA") .Or. fSilSEEK("TPA",(cTRBSTH)->TH_ETAPA,01,M->TQ2_FILDES,M->TQ2_EMPDES))
			If !dbSeek(cFilSTH+(cTRBSTH)->TH_CODBEM+(cTRBSTH)->TH_SERVICO+(cTRBSTH)->TH_SEQRELA+(cTRBSTH)->TH_TAREFA+(cTRBSTH)->TH_ETAPA)
				//Cria um novo STH com a nova filial
				RecLock("STH",.T.)
				For i := 1 TO FCOUNT()
					nn := FieldName(i)
					pp := "STH->"+ FieldName(i)
					vl := "(cTRBSTH)->"+ FieldName(i)
					If nn == "TH_DOCTO" .Or. nn == "TH_DOCFIL"
						If fChkArquivo("QDH")
							&pp. := &vl.
						EndIf
					ElseIf nn == "TH_FILIAL"
						&pp. := cFilSTH
					Else
						&pp. := &vl.
					EndIf
				Next i
				STH->(MsUnLock())
			EndIf
		EndIf
		dbSelectArea(cTRBSTH)
		dbSkip()
	End

	//---------------------------------------------------------------
	//CRIA ARQUIVO TEMPORARIO COM OS DADOS DA FILIAL DE ORIGEM
	cFilTP1 := NGTROCAFILI("TP1",M->TQ2_FILORI,M->TQ2_EMPORI)
	NgPrepTbl({{"TP1",01}},M->TQ2_EMPORI)
	If dbSeek(cFilTP1+cCODBEMTRA)
		While !Eof() .And. TP1->TP1_FILIAL == cFilTP1 .And. TP1->TP1_CODBEM == cCODBEMTRA
			// Faz uma copia do TP1
			dbSelectArea(cTRBTP1)
			RecLock((cTRBTP1),.T.)
			For i := 1 TO FCOUNT()
				pp := "TP1->"+ FieldName(i)
				vl := "(cTRBTP1)->"+ FieldName(i)
				&vl. := &pp.
			Next i
			(cTRBTP1)->(MsUnLock())
			dbSelectArea("TP1")
			dbSkip()
		End

		//DELETE REGISTRO NA FILIAL DE DESTINO
		cFilTP1 := NGTROCAFILI("TP1",M->TQ2_FILDES,M->TQ2_EMPDES)
		NgPrepTbl({{"TP1",01}},M->TQ2_EMPDES)
		dbSeek(cFilTP1+cCODBEMTRA)
		While !Eof() .And. TP1->TP1_FILIAL == cFilTP1 .And. TP1->TP1_CODBEM == cCODBEMTRA
			RecLock("TP1",.F.)
			TP1->(dbDelete())
			TP1->(MsUnLock())
			dbSelectArea("TP1")
			dbSkip()
		End

		//CRIA NOVOS REGISTROS NA FILIAL DE DESTINO
		cFilST9 := NGTROCAFILI("ST9",M->TQ2_FILDES,M->TQ2_EMPDES)
		NgPrepTbl({{"ST9"}},M->TQ2_EMPDES)
		dbSelectArea(cTRBTP1)
		dbGoTop()
		While !Eof()
			dbSelectArea("TP1")
			If !dbSeek(cFilTP1+(cTRBTP1)->TP1_CODBEM+(cTRBTP1)->TP1_SERVIC+(cTRBTP1)->TP1_SEQREL+(cTRBTP1)->TP1_TAREFA+(cTRBTP1)->TP1_ETAPA+(cTRBTP1)->TP1_OPCAO)
				//Cria um novo TP1 com a nova filial
				If !Empty((cTRBTP1)->TP1_BEMIMN)
					dbSelectArea("ST9")
					dbSetOrder(01)
					If !dbSeek(M->TQ2_EMPDES+(cTRBTP1)->TP1_BEMIMN)
						//Inativa a manutencao e nao grava o insumo na filial destino
						NgPrepTbl({{"STF",01}},M->TQ2_EMPDES)
						If dbSeek(cFilSTF+(cTRBTP1)->TP1_CODBEM+(cTRBTP1)->TP1_SERVIC+(cTRBTP1)->TP1_SEQREL)
							RecLock("STF",.F.)
							STF->TF_ATIVO := "N"
							STF->(MsUnLock())
						EndIf
						NgPrepTbl({{"STF",01}},SM0->M0_CODIGO)
						dbSelectArea(cTRBTP1)
						dbSkip()
						Loop
					EndIf
				EndIf

				dbSelectArea("TP1")
				RecLock("TP1",.T.)
				For i := 1 TO FCOUNT()
					pp := "TP1->"+ FieldName(i)
					vl := "(cTRBTP1)->"+ FieldName(i)
					&pp. := &vl.
				Next i
				TP1->TP1_FILIAL := cFilTP1
				TP1->(MsUnLock())

			EndIf
			dbSelectArea(cTRBTP1)
			dbSkip()
		End
	EndIf
Return .T.

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³f550TCARA ³ Autor ³ Felipe Nathan Welter  ³ Data ³ 15/03/10 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³Transferencia das caracteristicas                           ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³f550GRAV/f550TRAS                                           ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Static Function f550TCARA(cCODBTRANF)

	Local i, nn

	//dbSelectArea(cTRBSTB)
	//ZAP

	If fChkArquivo("STB") .And. fChkArquivo("SAH")
		Return .T.
	EndIf

	cFilSTB := NGTROCAFILI("STB",M->TQ2_FILORI,M->TQ2_EMPORI)
	NgPrepTbl({{"STB",01}},M->TQ2_EMPORI)
	//Cria arquivo temporario com os dados da filial de origem
	dbSeek(cFilSTB+cCODBTRANF)
	While !Eof() .And. cFilSTB == STB->TB_FILIAL .And. STB->TB_CODBEM == cCODBTRANF
		// Faz uma copia do STB
		dbSelectArea(cTRBSTB)
		RecLock((cTRBSTB),.T.)
		For i := 1 TO FCOUNT()
			pp := "STB->"+ FieldName(i)
			vl := "(cTRBSTB)->"+ FieldName(i)
			&vl. := &pp.
		Next i
		(cTRBSTB)->(MsUnLock())
		dbSelectArea("STB")
		dbSkip()
	End

	cFilSTB := NGTROCAFILI("STB",M->TQ2_FILDES,M->TQ2_EMPDES)
	NgPrepTbl({{"STB",01}},M->TQ2_EMPDES)
	//Deleta os registros encontrados no destino
	dbSeek(cFilSTB+cCODBTRANF)
	While !Eof() .And. cFilSTB == STB->TB_FILIAL .And. STB->TB_CODBEM == cCODBTRANF
		RecLock("STB",.F.)
		dbDelete()
		MsUnLock("STB")
		dbSkip()
	EndDo

	//cria novos registros na filial de destino
	dbSelectArea(cTRBSTB)
	dbGotop()
	While !Eof()
		If fSilSEEK("TPR",(cTRBSTB)->TB_CARACTE,01,M->TQ2_FILDES,M->TQ2_EMPDES)
			dbSelectArea("STB")
			If !dbSeek(cFilSTB+(cTRBSTB)->TB_CODBEM+(cTRBSTB)->TB_CARACTE)
				//Cria um novo STB com a nova filial
				RecLock("STB",.T.)
				For i := 1 TO FCOUNT()
					nn := FieldName(i)
					pp := "STB->"+ FieldName(i)
					vl := "(cTRBSTB)->"+ FieldName(i)
					If nn == "TB_UNIDADE"
						If fChkArquivo("SAH") .Or. fSilSEEK("SAH",&vl.,01,M->TQ2_FILDES,M->TQ2_EMPDES)
							&pp. := &vl.
						EndIf
					ElseIf nn == "TB_FILIAL"
						&pp. := cFilSTB
					Else
						&pp. := &vl.
					EndIf
				Next i
				STB->(MsUnLock())
			EndIf
		EndIf
		dbSelectArea(cTRBSTB)
		dbSkip()
	End

Return .T.

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³f550TREPO ³ Autor ³ Felipe Nathan Welter  ³ Data ³ 15/03/10 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³Transferencia das pecas de reposicao                        ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³f550GRAV/f550TRAS                                           ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Static Function f550TREPO(cCODBTRANF)
	Local i, nn

	//dbSelectArea(cTRBTPY)
	//ZAP

	If fChkArquivo("TPY") .And. fChkArquivo("SAH")
		Return .T.
	EndIf

	cFilTPY := NGTROCAFILI("TPY",M->TQ2_FILORI,M->TQ2_EMPORI)
	NgPrepTbl({{"TPY",01}},M->TQ2_EMPORI)
	//Cria arquivo temporario com os dados da filial de origem
	dbSeek(cFilTPY+cCODBTRANF)
	While !Eof() .And. cFilTPY == TPY->TPY_FILIAL .And. TPY->TPY_CODBEM == cCODBTRANF
		// Faz uma copia do STB
		dbSelectArea(cTRBTPY)
		RecLock((cTRBTPY),.T.)
		For i := 1 TO FCOUNT()
			pp := "TPY->"+ FieldName(i)
			vl := "(cTRBTPY)->"+ FieldName(i)
			&vl. := &pp.
		Next i
		(cTRBTPY)->(MsUnLock())
		dbSelectArea("TPY")
		dbSkip()
	End

	cFilTPY := NGTROCAFILI("TPY",M->TQ2_FILDES,M->TQ2_EMPDES)
	NgPrepTbl({{"TPY",01}},M->TQ2_EMPDES)
	//Deleta os registros encontrados no destino
	dbSeek(cFilTPY+cCODBTRANF)
	While !Eof() .And. cFilTPY == TPY->TPY_FILIAL .And. TPY->TPY_CODBEM == cCODBTRANF
		RecLock("TPY",.F.)
		dbDelete()
		MsUnLock("TPY")
		dbSkip()
	EndDo

	//cria novos registros na filial de destino
	dbSelectArea(cTRBTPY)
	dbGoTop()
	While !Eof()
		If fSilSEEK("SB1",(cTRBTPY)->TPY_CODPRO,01,M->TQ2_FILDES,M->TQ2_EMPDES)
			dbSelectArea("TPY")
			If !dbSeek(cFilTPY+(cTRBTPY)->TPY_CODBEM+(cTRBTPY)->TPY_CODPRO)
				//Cria um novo TPY com a nova filial
				RecLock("TPY",.T.)
				For i := 1 TO FCOUNT()
					nn := FieldName(i)
					pp := "TPY->"+ FieldName(i)
					vl := "(cTRBTPY)->"+ FieldName(i)
					If nn == "TPY_LOCGAR"
						If fChkArquivo("SAH") .Or. fSilSEEK("SAH",&vl.,01,M->TQ2_FILDES,M->TQ2_EMPDES)
							&pp. := &vl.
						EndIf
					ElseIf nn == "TPY_FILIAL"
						&pp. := cFilTPY
					Else
						&pp. := &vl.
					EndIf
				Next i
				TPY->(MsUnLock())
			EndIf
		EndIf
		dbSelectArea(cTRBTPY)
		dbSkip()
	End

Return .T.

//----------------------------------------------------------------------------------------------------------
/*/{Protheus.doc} f550TANQUE
Transferencia do tanque de combustivel (TT8).
@type static

@author Felipe Nathan Welter
@since 15/03/2010

@sample f550TANQUE("0001")

@param cCODBTRANF , Caracter , Código bem tranferido.

@return .T.
/*/
//----------------------------------------------------------------------------------------------------------
Static Function f550TANQUE(cCODBTRANF)
	Local i, nn
	Local cAliSeek
	Local cChaveSeek

	If fChkArquivo("TT8") .And. fChkArquivo("TQM")
		Return .T.
	EndIf

	If lTT8Tanque
		//CRIA ARQUIVO TEMPORARIO COM OS DADOS DA FILIAL DE ORIGEM
		cFilTT8 := NGTROCAFILI("TT8",M->TQ2_FILORI,M->TQ2_EMPORI)
		NgPrepTbl({{"TT8",01}},M->TQ2_EMPORI)
		dbSeek(cFilTT8+cCODBTRANF,.T.)
		While !Eof() .And. TT8->TT8_FILIAL == cFilTT8 .And. TT8->TT8_CODBEM == cCODBTRANF
			//Faz uma copia do TT8
			dbSelectArea(cTRBTT8)
			RecLock((cTRBTT8),.T.)
			For i := 1 TO FCOUNT()
				pp := "TT8->"+ FieldName(i)
				vl := "(cTRBTT8)->"+ FieldName(i)
				&vl. := &pp.
			Next i
			(cTRBTT8)->(MsUnLock())
			dbSelectArea("TT8")
			dbSkip()
		EndDo

		//DELETE REGISTRO NA FILIAL DE DESTINO
		cFilTT8 := NGTROCAFILI("TT8",M->TQ2_FILDES,M->TQ2_EMPDES)
		NgPrepTbl({{"TT8",01}},M->TQ2_EMPDES)
		dbSeek(cFilTT8+cCODBTRANF)
		While !Eof() .And. TT8->TT8_FILIAL == cFilTT8 .And. TT8->TT8_CODBEM == cCODBTRANF
			RecLock("TT8",.F.)
			TT8->(dbDelete())
			TT8->(MsUnLock())
			dbSelectArea("TT8")
			dbSkip()
		EndDo

		//CRIA NOVOS REGISTROS NA FILIAL DE DESTINO
		dbSelectArea(cTRBTT8)
		dbGoTop()
		While !Eof()
			dbSelectArea("TT8")
			dbSetOrder(1)

			cChaveTT8 := cFilTT8+(cTRBTT8)->TT8_CODBEM+(cTRBTT8)->TT8_CODCOM+(cTRBTT8)->TT8_TPCONT+(cTRBTT8)->TT8_TIPO
			If (cTRBTT8)->TT8_TIPO == "2"
				cAliSeek := "TZZ"
				cChaveSeek := (cTRBTT8)->TT8_CODCOM
				lChkArq := .F.
			Else
				cAliSeek := "TQM"
				cChaveSeek := SubStr((cTRBTT8)->TT8_CODCOM,1,3)
				lChkArq := .T.
			EndIf

			If !dbSeek(cChaveTT8)
				If fChkArquivo(cAliSeek) .Or. fSilSEEK(cAliSeek,cChaveSeek,01,M->TQ2_FILDES,M->TQ2_EMPDES)
					//Cria um novo TT8 com a nova filial
					RecLock("TT8",.T.)
					For i := 1 TO FCOUNT()
						nn := FieldName(i)
						pp := "TT8->"+ FieldName(i)
						vl := "(cTRBTT8)->"+ FieldName(i)
						If nn == "TT8_FILIAL"
							&pp. := cFilTT8
						Else
							&pp. := &vl.
						EndIF
					Next i
					TT8->(MsUnLock())
				EndIf
			EndIf
			dbSelectArea(cTRBTT8)
			dbSkip()
		End
	EndIf

Return .T.

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³f550PENHOR³ Autor ³Felipe Nathan Welter   ³ Data ³ 15/03/09 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³Transferencia dos registros de penhor (TS3)                 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³f550GRAV/f550TRAS                                           ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Static Function f550PENHOR(cCODBTRANF)
	Local i, nn
	Local lGrava := .T.

	cFilST9 := NGTROCAFILI("ST9",M->TQ2_FILORI,M->TQ2_EMPORI)
	NgPrepTbl({{"TS3"},{"ST9"}},M->TQ2_EMPORI)
	cPlaca := If(dbSeek(cFilST9+cCODBTRANF),ST9->T9_PLACA,"")

	dbSelectArea("TS3")
	dbSetOrder(02)
	If dbSeek(cFilOriTS3+cPlaca)

		//dbSelectArea(cTRBTS3)
		//ZAP

		//Nova Filial
		cFilTrTS3 := A525FILIAL(cPlaca,1,M->TQ2_FILDES,M->TQ2_EMPDES)

		//CRIA ARQUIVO TEMPORARIO COM OS DADOS DA FILIAL DE ORIGEM
		dbSelectArea("TS3")
		dbSetOrder(1)
		dbSeek(cFilOriTS3+cCODBTRANF)
		While !Eof() .And. TS3->TS3_FILIAL == cFilOriTS3 .And. TS3->TS3_CODBEM == cCODBTRANF
			//Faz uma copia do TS3
			dbSelectArea(cTRBTS3)
			RecLock((cTRBTS3),.T.)
			For i := 1 TO FCOUNT()
				pp := "TS3->"+ FieldName(i)
				vl := "(cTRBTS3)->"+ FieldName(i)
				&vl. := &pp.
			Next i
			(cTRBTS3)->(MsUnLock())

			dbSelectArea("TS3")
			dbSkip()
		End

		//DELETE REGISTRO NA FILIAL DE DESTINO
		NgPrepTbl({{"TS3"}},M->TQ2_EMPDES)
		dbSeek(cFilTrTS3+cCODBTRANF)
		While !Eof() .And. TS3->TS3_FILIAL == cFilTrTS3 .And. TS3->TS3_CODBEM == cCODBTRANF
			RecLock("TS3",.F.)
			TS3->(dbDelete())
			TS3->(MsUnLock())
			dbSelectArea("TS3")
			dbSkip()
		End

		//CRIA NOVOS REGISTROS NA FILIAL DE DESTINO
		dbSelectArea(cTRBTS3)
		dbGoTop()
		While !Eof()
			lGrava := .T.
			NgPrepTbl({{"TS3"}},M->TQ2_EMPDES)
			dbSeek(cFilTrTS3+(cTRBTS3)->TS3_CODBEM)
			While !Eof() .And. TS3->TS3_FILIAL == cFilTrTS3 .And. TS3->TS3_CODBEM == (cTRBTS3)->TS3_CODBEM
				lGrava := If((cTRBTS3)->TS3_DTIND == TS3->TS3_DTIND,.F.,lGrava)
				dbSelectArea("TS3")
				dbSkip()
			EndDo
			If lGrava
				//Cria um novo TS3 com a nova filial
				RecLock("TS3",.T.)
				For i := 1 TO FCOUNT()
					nn := FieldName(i)
					pp := "TS3->"+ FieldName(i)
					vl := "(cTRBTS3)->"+ FieldName(i)
					If nn == "TS3_FILIAL"
						&pp. := cFilTrTS3
					Else
						&pp. := &vl.
					EndIf
				Next i
				TS3->(MsUnLock())
			EndIf
			dbSelectArea(cTRBTS3)
			dbSkip()
		End

		//DELETE REGISTRO NA FILIAL DE ORIGEM
		NgPrepTbl({{"TS3"}},M->TQ2_EMPORI)
		dbSeek(cFilOriTS3+cCODBTRANF)
		While !Eof() .And. TS3->TS3_FILIAL == cFilOriTS3 .And. TS3->TS3_CODBEM == cCODBTRANF
			RecLock("TS3",.F.)
			TS3->(dbDelete())
			TS3->(MsUnLock())
			dbSelectArea("TS3")
			dbSkip()
		End

	EndIf

	NgPrepTbl({{"TS3"},{"ST9"}},SM0->M0_CODIGO)

Return .T.

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³f550LEASIN³ Autor ³Felipe Nathan Welter   ³ Data ³ 15/03/10 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³Transferencia dos registros de leasing (TSJ)                ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³f550GRAV/f550TRAS                                           ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Static Function f550LEASIN(cCODBTRANF)
	Local i, nn
	Local lGrava := .T.

	cFilST9 := NGTROCAFILI("ST9",M->TQ2_FILORI,M->TQ2_EMPORI)
	NgPrepTbl({{"TSJ"},{"ST9"}},M->TQ2_EMPORI)
	dbSelectArea("TSJ")
	dbSetOrder(01)
	If dbSeek(cFilOriTSJ+cCODBTRANF)

		//dbSelectArea(cTRBTSJ)
		//ZAP

		//Nova Filial
		dbSelectArea("ST9")
		cPlaca := If(dbSeek(cFilST9+cCODBTRANF),ST9->T9_PLACA,"")
		cFilTrTSJ := A755FILIAL(cPlaca,1,M->TQ2_FILDES,M->TQ2_EMPDES)

		//CRIA ARQUIVO TEMPORARIO COM OS DADOS DA FILIAL DE ORIGEM
		NgPrepTbl({{"TSJ"}},M->TQ2_EMPDES)
		dbSeek(cFilOriTSJ+cCODBTRANF)
		While !Eof() .And. TSJ->TSJ_FILIAL == cFilOriTSJ .And. TSJ->TSJ_CODBEM == cCODBTRANF
			//Faz uma copia do TSJ
			dbSelectArea(cTRBTSJ)
			RecLock((cTRBTSJ),.T.)
			For i := 1 TO FCOUNT()
				pp := "TSJ->"+ FieldName(i)
				vl := "(cTRBTSJ)->"+ FieldName(i)
				&vl. := &pp.
			Next i
			(cTRBTSJ)->(MsUnLock())

			dbSelectArea("TSJ")
			dbSkip()
		End

		//DELETE REGISTRO NA FILIAL DE DESTINO
		NgPrepTbl({{"TSJ"}},M->TQ2_EMPDES)
		dbSeek(cFilTrTSJ+cCODBTRANF)
		While !Eof() .And. TSJ->TSJ_FILIAL == cFilTrTSJ .And. TSJ->TSJ_CODBEM == cCODBTRANF
			RecLock("TSJ",.F.)
			TSJ->(dbDelete())
			TSJ->(MsUnLock())
			dbSelectArea("TSJ")
			dbSkip()
		End

		//CRIA NOVOS REGISTROS NA FILIAL DE DESTINO
		dbSelectArea(cTRBTSJ)
		dbGoTop()
		While !Eof()
			dbSelectArea("TSJ")
			dbSetOrder(03)
			If !dbSeek(cFilTrTSJ+(cTRBTSJ)->TSJ_CODBEM+DTOS((cTRBTSJ)->TSJ_DTINIC))
				//Cria um novo TSJ com a nova filial
				RecLock("TSJ",.T.)
				For i := 1 TO FCOUNT()
					nn := FieldName(i)
					pp := "TSJ->"+ FieldName(i)
					vl := "(cTRBTSJ)->"+ FieldName(i)
					If nn == "TSJ_FILIAL"
						&pp. := cFilTrTSJ
					Else
						&pp. := &vl.
					EndIf
				Next i
				TSJ->(MsUnLock())
			EndIf
			dbSelectArea(cTRBTSJ)
			dbSkip()
		End

		//DELETE REGISTRO NA FILIAL DE ORIGEM
		NgPrepTbl({{"TSJ"}},M->TQ2_EMPORI)
		dbSetOrder(01)
		dbSeek(cFilOriTSJ+cCODBTRANF)
		While !Eof() .And. TSJ->TSJ_FILIAL == cFilOriTSJ .And. TSJ->TSJ_CODBEM == cCODBTRANF
			RecLock("TSJ",.F.)
			TSJ->(dbDelete())
			TSJ->(MsUnLock())
			dbSelectArea("TSJ")
			dbSkip()
		End

	EndIf

	NgPrepTbl({{"TSJ"},{"ST9"}},SM0->M0_CODIGO)

Return .T.

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³f550BANCON³ Autor ³ Felipe Nathan Welter  ³ Data ³ 17/03/10 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³Transferencia do banco do conhecimento                      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³cCODBEMCON - Codigo da entidade                             ³±±
±±³          ³cTABENTID  - Entidade                                       ³±±
±±³          ³cFILORI    - Filial origem da entidade                      ³±±
±±³          ³cEMPORI    - Empresa origem da entidade                     ³±±
±±³          ³cFILDES    - Filial destino da entidade                     ³±±
±±³          ³cEMPDES    - Empresa destino da entidade                    ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³fSILTRNSF                                                   ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Static Function f550BANCON(cCODBEMCON,cTABENTID,cFILORI,cEMPORI,cFILDES,cEMPDES)

	Local i

	If fChkArquivo("AC9") .And. fChkArquivo("ACB") .And. fChkArquivo("ACC")
		Return .T.
	EndIf

	cFilAC9 := NGTROCAFILI("AC9",cFILORI,cEMPORI)
	cFilACB := NGTROCAFILI("ACB",cFILORI,cEMPORI)
	cFilACC := NGTROCAFILI("ACC",cFILORI,cEMPORI)
	NgPrepTbl({{"AC9"},{"ACB"},{"ACC"}},cEMPORI)
	//Cria arquivo temporario com os dados da filial de origem
	dbSelectArea("AC9")
	dbSetOrder(02)
	dbSeek(cFilAC9+cTABENTID+cFILORI+cCODBEMCON,.T.)
	While !Eof() .And. AC9->AC9_FILIAL == cFilAC9 .And. AC9->AC9_ENTIDA == cTABENTID;
	.And. AC9->AC9_FILENT == cFILORI .And. Alltrim(AC9->AC9_CODENT) == Alltrim(cCODBEMCON)

		// Faz uma copia do AC9
		dbSelectArea(cTRBAC9)
		RecLock((cTRBAC9),.T.)
			For i := 1 TO FCOUNT()
			pp := "AC9->"+ FieldName(i)
			vl := "(cTRBAC9)->"+ FieldName(i)
			&vl. := &pp.
		Next i
		(cTRBAC9)->(MsUnLock())

		dbSelectArea("ACB")
		dbSetOrder(01)
		If dbSeek(cFilACB+AC9->AC9_CODOBJ)

			// Faz uma copia do ACB
			dbSelectArea(cTRBACB)
			RecLock((cTRBACB),.T.)
			For i := 1 TO FCOUNT()
				pp := "ACB->"+ FieldName(i)
				vl := "(cTRBACB)->"+ FieldName(i)
				&vl. := &pp.
			Next i
			(cTRBACB)->(MsUnLock())

		EndIf

		dbSelectArea("ACC")
		dbSetOrder(01)
		If dbSeek(cFilACC+AC9->AC9_CODOBJ)

			// Faz uma copia do ACC
			dbSelectArea(cTRBACC)
			RecLock((cTRBACC),.T.)
			For i := 1 TO FCOUNT()
				pp := "ACC->"+ FieldName(i)
				vl := "(cTRBACC)->"+ FieldName(i)
				&vl. := &pp.
			Next i
			(cTRBACC)->(MsUnLock())

		EndIf

		dbSelectArea("AC9")
		dbSkip()
	End

	cFilAC9 := NGTROCAFILI("AC9",cFILDES,cEMPDES)
	cFilACB := NGTROCAFILI("ACB",cFILDES,cEMPDES)
	cFilACC := NGTROCAFILI("ACC",cFILDES,cEMPDES)
	NgPrepTbl({{"AC9"},{"ACB"},{"ACC"}},cEMPDES)
	//Cria o banco de conhecimento na filial destino
	dbSelectArea(cTRBAC9)
	dbGoTop()
	While !Eof()
		dbSelectArea("AC9")
		dbSetOrder(01)
		If !dbSeek(cFilAC9+(cTRBAC9)->AC9_CODOBJ+(cTRBAC9)->AC9_ENTIDA+cFILDES+(cTRBAC9)->AC9_CODENT)
			//Cria um novo AC9 com a nova filial
			RecLock("AC9",.T.)
			For i := 1 TO FCOUNT()
				pp := "AC9->"+ FieldName(i)
				vl := "(cTRBAC9)->"+ FieldName(i)
				&pp. := &vl.
			Next i
			AC9->AC9_FILIAL := cFilAC9
			AC9->AC9_FILENT := cFILDES
			AC9->(MsUnLock())

			dbSelectArea(cTRBACB)
			If dbSeek((cTRBAC9)->AC9_CODOBJ)

				dbSelectArea("ACB")
				dbSetOrder(01)
				If !dbSeek(cFilACB+(cTRBAC9)->AC9_CODOBJ)
					//Cria um novo ACB com a nova filial
					RecLock("ACB",.T.)
					For i := 1 To Fcount()
						pp := "ACB->"+ FieldName(i)
						vl := "(cTRBACB)->"+ FieldName(i)
						&pp. := &vl.
					Next i
					ACB->ACB_FILIAL := cFilACB
					ACB->(MsUnLock())
				EndIf

			EndIf

			dbSelectArea(cTRBACC)
			If dbSeek((cTRBAC9)->AC9_CODOBJ)

				dbSelectArea("ACC")
				dbSetOrder(01)
				If !dbSeek(cFilACC+(cTRBAC9)->AC9_CODOBJ)
					//Cria um novo ACC com a nova filial
					RecLock("ACC",.T.)
					For i := 1 To Fcount()
						pp := "ACC->"+ FieldName(i)
						vl := "(cTRBACC)->"+ FieldName(i)
						&pp. := &vl.
					Next i
					ACC->ACC_FILIAL := cFilACC
					ACC->(MsUnLock())
				EndIf

			EndIf
		EndIf
		dbSelectArea(cTRBAC9)
		dbSkip()
	End

	NgPrepTbl({{"AC9"},{"ACB"},{"ACC"}},SM0->M0_CODIGO)

Return .T.

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³f550PNEUS ³ Autor ³ Felipe Nathan Welter  ³ Data ³ 15/03/10 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³Transferencia de pneus                                      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³f550GRAV/f550TRAS                                           ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Static Function f550PNEUS(cCODBTRANF)
	Local i, nn

	//Cria arquivo temporario com os dados da filial de origem
	NgPrepTbl({{"TQS"}},M->TQ2_EMPORI)
	If dbSeek(NGTROCAFILI("TQS",M->TQ2_FILORI,M->TQ2_EMPORI)+cCODBTRANF)
		// Faz uma copia do TQS
		dbSelectArea(cTRBTQS)
		RecLock((cTRBTQS),.T.)
		For i := 1 TO FCOUNT()
			pp := "TQS->"+ FieldName(i)
			vl := "(cTRBTQS)->"+ FieldName(i)
			&vl. := &pp.
		Next i
		(cTRBTQS)->(MsUnLock())
	EndIf

	cFilTQS := NGTROCAFILI("TQS",M->TQ2_FILDES,M->TQ2_EMPDES)
	NgPrepTbl({{"TQS"}},M->TQ2_EMPDES)
	//cria novos registros na filial de destino
	dbSelectArea(cTRBTQS)
	dbGoTop()
	While !Eof()
		dbSelectArea("TQS")
		lLock := (dbSeek(cFilTQS+(cTRBTQS)->TQS_CODBEM))
		RecLock("TQS",!lLock)
		For i := 1 TO FCOUNT()
			nn := FieldName(i)
			pp := "TQS->"+ FieldName(i)
			vl := "(cTRBTQS)->"+ FieldName(i)
			If nn == "TQS_DESENH"
				If fChkArquivo("TQU") .Or. fSilSEEK("TQU",(cTRBTQS)->TQS_DESENH,01,M->TQ2_FILDES,M->TQ2_EMPDES)
					&pp. := &vl.
				EndIf
			ElseIf nn == "TQS_POSIC"
				If fChkArquivo("TPS") .Or. fSilSEEK("TPS",(cTRBTQS)->TQS_POSIC,01,M->TQ2_FILDES,M->TQ2_EMPDES)
					&pp. := &vl.
				EndIf
			ElseIf nn == "TQS_FILIAL"
				&pp. := cFilTQS
			Else
				&pp. := &vl.
			EndIf
		Next i
		TQS->(MsUnLock())
		dbSelectArea(cTRBTQS)
		(cTRBTQS)->(dbSkip())
	EndDo
	NgPrepTbl({{"TQS"}},SM0->M0_CODIGO)

Return .T.

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³f550ST9T  ³ Autor ³ Felipe Nathan Welter  ³ Data ³ 15/03/10 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³Validacao ST9 - BEM                                         ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³SIGAMNT                                                     ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Static Function f550ST9T()

	Local zz := 0

	NGPrepTBL({{"DA3"},{"TS3"},{"TSJ"},{"ST9"}},M->TQ2_EMPORI)
	If dbSeek(NGTROCAFILI("ST9",M->TQ2_FILORI,M->TQ2_EMPORI)+M->TQ2_CODBEM)

		//VALIDACAO DO CODIGO DO CENTRO DE CUSTO
		If !fSilSEEK(cF3CTTSI3,M->TQ2_CCUSTO,01,M->TQ2_FILDES,M->TQ2_EMPDES)
			fGravPrb(cF3CTTSI3,"T9_CCUSTO",STR0131+M->TQ2_CODBEM,2) //"Bem: "
		EndIf

		//VALIDACAO DO CODIGO DA FAMILIA
		If !(fChkArquivo("ST6") .Or. fSilSEEK("ST6",ST9->T9_CODFAMI,01,M->TQ2_FILDES,M->TQ2_EMPDES))
			fGravPrb("ST6","T9_CODFAMI",STR0131+M->TQ2_CODBEM,2) //"Bem: "
		EndIf

		//VALIDACAO DO TURNO
		If !(fChkArquivo("SH7") .Or. fSilSEEK("SH7",ST9->T9_CALENDA,01,M->TQ2_FILDES,M->TQ2_EMPDES))
			fGravPrb("SH7","T9_CALENDA",STR0131+M->TQ2_CODBEM,2) //"Bem: "
		EndIf

		//VALIDACAO DO CODIGO DO RECURSO/FERRAMENTA
		If !Empty(ST9->T9_RECFERR)
			If ST9->T9_FERRAME == "F" //Ferramenta
				If !(fChkArquivo("SH4") .Or. fSilSEEK("SH4",ST9->T9_RECFERR,01,M->TQ2_FILDES,M->TQ2_EMPDES))
					fGravPrb("SH4","T9_FERRAME",STR0131+M->TQ2_CODBEM,0) //"Bem: "
				EndIf
			Else //Recurso
				If !(fChkArquivo("SH1") .Or. fSilSEEK("SH1",ST9->T9_RECFERR,01,M->TQ2_FILDES,M->TQ2_EMPDES))
					fGravPrb("SH1","T9_FERRAME",STR0131+M->TQ2_CODBEM,0) //"Bem: "
				EndIf
			EndIf
		EndIf

		//VALIDACAO DO CODIGO DO CENTRO DE TRABALHO
		If !Empty(M->TQ2_CENTRA) .And. !(fChkArquivo("SHB") .Or. fSilSEEK("SHB",M->TQ2_CENTRA,01,M->TQ2_FILDES,M->TQ2_EMPDES))
			fGravPrb("SHB","T9_CENTRAB",STR0131+M->TQ2_CODBEM,0) //"Bem: "
		EndIf

		//VALIDACAO DO CODIGO DO FORNECEDOR
		If !Empty(ST9->T9_FORNECE) .And. !(fChkArquivo("SA2") .Or. fSilSEEK("SA2",ST9->T9_FORNECE,01,M->TQ2_FILDES,M->TQ2_EMPDES))
			fGravPrb("SA2","T9_FORNECE",STR0131+M->TQ2_CODBEM,0) //"Bem: "
		EndIf

		//VALIDACAO DO CODIGO DO FABRICANTE
		If !Empty(ST9->T9_FABRICA) .And. !(fChkArquivo("ST7") .Or. fSilSEEK("ST7",ST9->T9_FABRICA,01,M->TQ2_FILDES,M->TQ2_EMPDES))
			fGravPrb("ST7","T9_FABRICA",STR0131+M->TQ2_CODBEM,0) //"Bem: "
		EndIf

		//VALIDACAO DO CODIGO DO ESTOQUE
		If !Empty(ST9->T9_CODESTO) .And. !(fChkArquivo("SB1") .Or. fSilSEEK("SB1",ST9->T9_CODESTO,01,M->TQ2_FILDES,M->TQ2_EMPDES))
			fGravPrb("SB1","T9_CODESTO",STR0131+M->TQ2_CODBEM,0) //"Bem: "
		EndIf

		//VALIDACAO DO CODIGO DO CLIENTE
		If !Empty(ST9->T9_CLIENTE) .And. !(fChkArquivo("SA1") .Or. fSilSEEK("SA1",ST9->T9_CLIENTE,01,M->TQ2_FILDES,M->TQ2_EMPDES))
			fGravPrb("SA1","T9_CLIENTE",STR0131+M->TQ2_CODBEM,0) //"Bem: "
		EndIf

		//VALIDACAO DO CODIGO DO MOTIVO
		If !Empty(ST9->T9_MTBAIXA) .And. !(fChkArquivo("TPJ") .Or. fSilSEEK("TPJ",ST9->T9_MTBAIXA,01,M->TQ2_FILDES,M->TQ2_EMPDES))
			fGravPrb("TPJ","T9_MTBAIXA",STR0131+M->TQ2_CODBEM,0) //"Bem: "
		EndIf

		//VALIDACAO DO ITEM CONTABIL
		If !Empty(ST9->T9_ITEMCTA) .And. !(fChkArquivo("CTD") .Or. fSilSEEK("CTD",ST9->T9_ITEMCTA,01,M->TQ2_FILDES,M->TQ2_EMPDES))
			fGravPrb("CTD","T9_ITEMCTA",STR0131+M->TQ2_CODBEM,0) //"Bem: "
		EndIf

		//VALIDACAO DOS CAMPOS DE FROTAS
		If lFROInt
			If !Empty(ST9->T9_TIPMOD) .And. !(fChkArquivo("TQR") .Or. fSilSEEK("TQR",ST9->T9_TIPMOD,01,M->TQ2_FILDES,M->TQ2_EMPDES))
				fGravPrb("TQR","T9_TIPMOD",STR0131+M->TQ2_CODBEM,2) //"Bem: "
			EndIf

			If !Empty(ST9->T9_STATUS) .And. !(fChkArquivo("TQY") .Or. fSilSEEK("TQY",ST9->T9_STATUS,01,M->TQ2_FILDES,M->TQ2_EMPDES))
				fGravPrb("TQY","T9_STATUS",STR0131+M->TQ2_CODBEM,0) //"Bem: "
			EndIf

			If !Empty(ST9->T9_CORVEI) .And. !(fChkArquivo("SX5") .Or. fSilSEEK("SX5","M7"+ST9->T9_CORVEI,01,M->TQ2_FILDES,M->TQ2_EMPDES))
				fGravPrb("SX5","T9_CORVEI",STR0131+M->TQ2_CODBEM,0) //"Bem: "
			EndIf

			If !Empty(ST9->T9_UFEMPLA) .And. !(fChkArquivo("SX5") .Or. fSilSEEK("SX5","12"+ST9->T9_UFEMPLA,01,M->TQ2_FILDES,M->TQ2_EMPDES))
				fGravPrb("SX5","T9_UFEMPLA",STR0131+M->TQ2_CODBEM,0) //"Bem: "
			EndIf

			If !Empty(ST9->T9_CODTMS) .And. !(fChkArquivo("DA3") .Or. fSilSEEK("DA3",ST9->T9_CODTMS,01,M->TQ2_FILDES,M->TQ2_EMPDES))
				fGravPrb("DA3","T9_CODTMS",STR0131+M->TQ2_CODBEM,0) //"Bem: "

				dbSelectArea("DA3")
				dbSetOrder(01)
				If dbSeek(NGTROCAFILI("DA3",M->TQ2_FILORI,M->TQ2_EMPORI)+ST9->T9_CODTMS)

					If !Empty(DA3->DA3_ESTPLA) .And. !(fChkArquivo("SX5") .Or. fSilSEEK("SX5","12"+DA3->DA3_ESTPLA,01,M->TQ2_FILDES,M->TQ2_EMPDES))
						fGravPrb("SX5","DA3_ESTPLA",STR0131+M->TQ2_CODBEM,0) //"Bem: "
					EndIf

					If !Empty(DA3->DA3_MOTORI) .And. !(fChkArquivo("DA4") .Or. fSilSEEK("DA4",DA3->DA3_MOTORI,01,M->TQ2_FILDES,M->TQ2_EMPDES))
						fGravPrb("DA4","DA3_MOTORI",STR0131+M->TQ2_CODBEM,0) //"Bem: "
					EndIf

					If !Empty(DA3->DA3_CODFOR) .And. !(fChkArquivo("SA2") .Or. fSilSEEK("SA2",DA3->DA3_CODFOR,01,M->TQ2_FILDES,M->TQ2_EMPDES))
						fGravPrb("SA2","DA3_CODFOR",STR0131+M->TQ2_CODBEM,2) //"Bem: "
					EndIf

					If !Empty(DA3->DA3_MARVEI) .And. !(fChkArquivo("SX5") .Or. fSilSEEK("SX5","M6"+DA3->DA3_MARVEI,01,M->TQ2_FILDES,M->TQ2_EMPDES))
						fGravPrb("SA2","DA3_MARVEI",STR0131+M->TQ2_CODBEM,2) //"Bem: "
					EndIf

					If !Empty(DA3->DA3_CORVEI) .And. !(fChkArquivo("SX5") .Or. fSilSEEK("SX5","M7"+DA3->DA3_CORVEI,01,M->TQ2_FILDES,M->TQ2_EMPDES))
						fGravPrb("SX5","DA3_CORVEI",STR0131+M->TQ2_CODBEM,0) //"Bem: "
					EndIf

					If !Empty(DA3->DA3_TIPVEI) .And. !(fChkArquivo("DUT") .Or. fSilSEEK("DUT",DA3->DA3_TIPVEI,01,M->TQ2_FILDES,M->TQ2_EMPDES))
						fGravPrb("DUT","DA3_TIPVEI",STR0131+M->TQ2_CODBEM,0) //"Bem: "
					EndIf

				EndIf

			EndIf

			If !Empty(ST9->T9_PLACA)
				dbSelectArea("TS3")
				cFilOriTS3 := A525FILIAL(ST9->T9_PLACA,1,M->TQ2_FILORI,M->TQ2_EMPORI)
			EndIf

			If !Empty(ST9->T9_PLACA)
				dbSelectArea("TSJ")
				cFilOriTSJ := A755FILIAL(ST9->T9_PLACA,1,M->TQ2_FILORI,M->TQ2_EMPORI)
			EndIf

		EndIf
	EndIf

	//Valida os componentes da Estrutura
	For zz := 1 To Len(aBEMTRA)
		dbSelectArea("ST9")
		dbSetOrder(01)
		If dbSeek(NGTROCAFILI("ST9",M->TQ2_FILORI,M->TQ2_EMPORI)+aBEMTRA[zz])

			//---------------------------------------------------------------

			//VALIDACAO DO CODIGO DO CENTRO DE CUSTO
			If !fSilSEEK(cF3CTTSI3,M->TQ2_CCUSTO,01,M->TQ2_FILDES,M->TQ2_EMPDES)
				fGravPrb(cF3CTTSI3,"T9_CCUSTO",STR0131+AllTrim(aBEMTRA[zz])+" ("+AllTrim(M->TQ2_CODBEM)+")",2) //"Bem: "
			EndIf

			//VALIDACAO DO CODIGO DA FAMILIA
			If !(fChkArquivo("ST6") .Or. fSilSEEK("ST6",ST9->T9_CODFAMI,01,M->TQ2_FILDES,M->TQ2_EMPDES))
				fGravPrb("ST6","T9_CODFAMI",STR0131+AllTrim(aBEMTRA[zz])+" ("+AllTrim(M->TQ2_CODBEM)+")",2) //"Bem: "
			EndIf

			//VALIDACAO DO TURNO
			If !(fChkArquivo("SH7") .Or. fSilSEEK("SH7",ST9->T9_CALENDA,01,M->TQ2_FILDES,M->TQ2_EMPDES))
				fGravPrb("SH7","T9_CALENDA",STR0131+AllTrim(aBEMTRA[zz])+" ("+AllTrim(M->TQ2_CODBEM)+")",2) //"Bem: "
			EndIf

			//VALIDACAO DO CODIGO DO RECURSO/FERRAMENTA
			If !Empty(ST9->T9_RECFERR)
				If ST9->T9_FERRAME == "F" //Ferramenta
					If !(fChkArquivo("SH4") .Or. fSilSEEK("SH4",ST9->T9_FERRAME,01,M->TQ2_FILDES,M->TQ2_EMPDES))
						fGravPrb("SH4","T9_FERRAME",STR0131+AllTrim(aBEMTRA[zz])+" ("+AllTrim(M->TQ2_CODBEM)+")",0) //"Bem: "
					EndIf
				Else //Recurso
					If !(fChkArquivo("SH1") .Or. fSilSEEK("SH1",ST9->T9_FERRAME,01,M->TQ2_FILDES,M->TQ2_EMPDES))
						fGravPrb("SH1","T9_FERRAME",STR0131+AllTrim(aBEMTRA[zz])+" ("+AllTrim(M->TQ2_CODBEM)+")",0) //"Bem: "
					EndIf
				EndIf
			EndIf

			//VALIDACAO DO CODIGO DO CENTRO DE TRABALHO
			If !Empty(M->TQ2_CENTRA) .And. !(fChkArquivo("SHB") .Or. fSilSEEK("SHB",M->TQ2_CENTRA,01,M->TQ2_FILDES,M->TQ2_EMPDES))
				fGravPrb("SHB","T9_CENTRAB",STR0131+AllTrim(aBEMTRA[zz])+" ("+AllTrim(M->TQ2_CODBEM)+")",0) //"Bem: "
			EndIf

			//VALIDACAO DO CODIGO DO FORNECEDOR
			If !Empty(ST9->T9_FORNECE) .And. !(fChkArquivo("SA2") .Or. fSilSEEK("SA2",ST9->T9_FORNECE,01,M->TQ2_FILDES,M->TQ2_EMPDES))
				fGravPrb("SA2","T9_FORNECE",STR0131+AllTrim(aBEMTRA[zz])+" ("+AllTrim(M->TQ2_CODBEM)+")",0) //"Bem: "
			EndIf

			//VALIDACAO DO CODIGO DO FABRICANTE
			If !Empty(ST9->T9_FABRICA) .And. !(fChkArquivo("ST7") .Or. fSilSEEK("ST7",ST9->T9_FABRICA,01,M->TQ2_FILDES,M->TQ2_EMPDES))
				fGravPrb("ST7","T9_FABRICA",STR0131+AllTrim(aBEMTRA[zz])+" ("+AllTrim(M->TQ2_CODBEM)+")",0) //"Bem: "
			EndIf

			//VALIDACAO DO CODIGO DO ESTOQUE
			If !Empty(ST9->T9_CODESTO) .And. !(fChkArquivo("SB1") .Or. fSilSEEK("SB1",ST9->T9_CODESTO,01,M->TQ2_FILDES,M->TQ2_EMPDES))
				fGravPrb("SB1","T9_CODESTO",STR0131+AllTrim(aBEMTRA[zz])+" ("+AllTrim(M->TQ2_CODBEM)+")",0) //"Bem: "
			EndIf

			//VALIDACAO DO CODIGO DO CLIENTE
			If !Empty(ST9->T9_CLIENTE) .And. !(fChkArquivo("SA1") .Or. fSilSEEK("SA1",ST9->T9_CLIENTE,01,M->TQ2_FILDES,M->TQ2_EMPDES))
				fGravPrb("SA1","T9_CLIENTE",STR0131+AllTrim(aBEMTRA[zz])+" ("+AllTrim(M->TQ2_CODBEM)+")",0) //"Bem: "
			EndIf

			//VALIDACAO DO CODIGO DO MOTIVO
			If !Empty(ST9->T9_MTBAIXA) .And. !(fChkArquivo("TPJ") .Or. fSilSEEK("TPJ",ST9->T9_MTBAIXA,01,M->TQ2_FILDES,M->TQ2_EMPDES))
				fGravPrb("TPJ","T9_MTBAIXA",STR0131+AllTrim(aBEMTRA[zz])+" ("+AllTrim(M->TQ2_CODBEM)+")",0) //"Bem: "
			EndIf

			//VALIDACAO DO ITEM CONTABIL
			If !Empty(ST9->T9_ITEMCTA) .And. !(fChkArquivo("CTD") .Or. fSilSEEK("CTD",ST9->T9_ITEMCTA,01,M->TQ2_FILDES,M->TQ2_EMPDES))
				fGravPrb("CTD","T9_ITEMCTA",STR0131+AllTrim(aBEMTRA[zz])+" ("+AllTrim(M->TQ2_CODBEM)+")",0) //"Bem: "
			EndIf

			//VALIDACAO DOS CAMPOS DE FROTAS
			If lFROInt
				If !Empty(ST9->T9_TIPMOD) .And. !(fChkArquivo("TQR") .Or. fSilSEEK("TQR",ST9->T9_TIPMOD,01,M->TQ2_FILDES,M->TQ2_EMPDES))
					fGravPrb("TQR","T9_TIPMOD",STR0131+AllTrim(aBEMTRA[zz])+" ("+AllTrim(M->TQ2_CODBEM)+")",2) //"Bem: "
				EndIf

				If !Empty(ST9->T9_STATUS) .And. !(fChkArquivo("TQY") .Or. fSilSEEK("TQY",ST9->T9_STATUS,01,M->TQ2_FILDES,M->TQ2_EMPDES))
					fGravPrb("TQY","T9_STATUS",STR0131+AllTrim(aBEMTRA[zz])+" ("+AllTrim(M->TQ2_CODBEM)+")",0) //"Bem: "
				EndIf

				If !Empty(ST9->T9_CORVEI) .And. !(fChkArquivo("SX5") .Or. fSilSEEK("SX5","M7"+ST9->T9_CORVEI,01,M->TQ2_FILDES,M->TQ2_EMPDES))
					fGravPrb("SX5","T9_CORVEI",STR0131+AllTrim(aBEMTRA[zz])+" ("+AllTrim(M->TQ2_CODBEM)+")",0) //"Bem: "
				EndIf

				If !Empty(ST9->T9_UFEMPLA) .And. !(fChkArquivo("SX5") .Or. fSilSEEK("SX5","12"+ST9->T9_UFEMPLA,01,M->TQ2_FILDES,M->TQ2_EMPDES))
					fGravPrb("SX5","T9_UFEMPLA",STR0131+AllTrim(aBEMTRA[zz])+" ("+AllTrim(M->TQ2_CODBEM)+")",0) //"Bem: "
				EndIf

				If !Empty(ST9->T9_CODTMS) .And. !(fChkArquivo("DA3") .Or. fSilSEEK("DA3",ST9->T9_CODTMS,01,M->TQ2_FILDES,M->TQ2_EMPDES))
					fGravPrb("DA3","T9_CODTMS",STR0131+AllTrim(aBEMTRA[zz])+" ("+AllTrim(M->TQ2_CODBEM)+")",0) //"Bem: "

					dbSelectArea("DA3")
					dbSetOrder(01)
					If dbSeek(NGTROCAFILI("DA3",M->TQ2_FILORI,M->TQ2_EMPORI)+ST9->T9_CODTMS)

						If !Empty(DA3->DA3_ESTPLA) .And. !(fChkArquivo("SX5") .Or. fSilSEEK("SX5","12"+DA3->DA3_ESTPLA,01,M->TQ2_FILDES,M->TQ2_EMPDES))
							fGravPrb("SX5","DA3_ESTPLA",STR0131+AllTrim(aBEMTRA[zz])+" ("+AllTrim(M->TQ2_CODBEM)+")",0) //"Bem: "
						EndIf

						If !Empty(DA3->DA3_MOTORI) .And. !(fChkArquivo("DA4") .Or. fSilSEEK("DA4",DA3->DA3_MOTORI,01,M->TQ2_FILDES,M->TQ2_EMPDES))
							fGravPrb("DA4","DA3_MOTORI",STR0131+AllTrim(aBEMTRA[zz])+" ("+AllTrim(M->TQ2_CODBEM)+")",0) //"Bem: "
						EndIf

						If !Empty(DA3->DA3_CODFOR) .And. !(fChkArquivo("SA2") .Or. fSilSEEK("SA2",DA3->DA3_CODFOR,01,M->TQ2_FILDES,M->TQ2_EMPDES))
							fGravPrb("SA2","DA3_CODFOR",STR0131+AllTrim(aBEMTRA[zz])+" ("+AllTrim(M->TQ2_CODBEM)+")",2) //"Bem: "
						EndIf

						If !Empty(DA3->DA3_MARVEI) .And. !(fChkArquivo("SX5") .Or. fSilSEEK("SX5","M6"+DA3->DA3_MARVEI,01,M->TQ2_FILDES,M->TQ2_EMPDES))
							fGravPrb("SA2","DA3_MARVEI",STR0131+AllTrim(aBEMTRA[zz])+" ("+AllTrim(M->TQ2_CODBEM)+")",2) //"Bem: "
						EndIf

						If !Empty(DA3->DA3_CORVEI) .And. !(fChkArquivo("SX5") .Or. fSilSEEK("SX5","M7"+DA3->DA3_CORVEI,01,M->TQ2_FILDES,M->TQ2_EMPDES))
							fGravPrb("SX5","DA3_CORVEI",STR0131+AllTrim(aBEMTRA[zz])+" ("+AllTrim(M->TQ2_CODBEM)+")",0) //"Bem: "
						EndIf

						If !Empty(DA3->DA3_TIPVEI) .And. !(fChkArquivo("DUT") .Or. fSilSEEK("DUT",DA3->DA3_TIPVEI,01,M->TQ2_FILDES,M->TQ2_EMPDES))
							fGravPrb("DUT","DA3_TIPVEI",STR0131+AllTrim(aBEMTRA[zz])+" ("+AllTrim(M->TQ2_CODBEM)+")",0) //"Bem: "
						EndIf

					EndIf

				EndIf
			EndIf
		EndIf
	Next zz

	NGPrepTBL({{"DA3"},{"TS3"},{"TSJ"},{"ST9"}},SM0->M0_CODIGO)

Return .T.
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³f550STCT  ³ Autor ³ Felipe Nathan Welter  ³ Data ³ 15/03/10 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³Validacao STC - ESTRUTURA                                   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³SIGAMNT                                                     ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Static Function f550STCT()

	Local zz := 0

	If fChkArquivo("TPS")
		Return .T.
	EndIf

	//Valida os componentes da Estrutura
	For zz := 1 To Len(aBEMTRA)
		dbSelectArea("STC")
		dbSetOrder(3)
		If dbSeek(NGTROCAFILI("STC",M->TQ2_FILORI,M->TQ2_EMPORI)+aBEMTRA[zz])
			If !Empty(STC->TC_LOCALIZ) .And. !(fChkArquivo("TPS") .Or. fSilSEEK("TPS",STC->TC_LOCALIZ,01,M->TQ2_FILDES,M->TQ2_EMPDES))
				fGravPrb("TPS","TC_LOCALIZ",STR0131+AllTrim(aBEMTRA[zz])+" ("+AllTrim(M->TQ2_CODBEM)+")",0) //"Bem: "
				Exit
			EndIf
		EndIf
	Next zz

Return .T.

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³f550STFT  ³ Autor ³ Felipe Nathan Welter  ³ Data ³ 15/03/10 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³Validacao STF - MANUTENCAO                                  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³SIGAMNT                                                     ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Static Function f550STFT()

	Local zz := 0
	Local lExitQDH := .F.

	If fChkArquivo("QDH")
		Return .T.
	EndIf

	cFilSTF := NGTROCAFILI("STF",M->TQ2_FILORI,M->TQ2_EMPORI)
	NgPrepTbl({{"STF",01}},M->TQ2_EMPORI)
	dbSeek(cFilSTF+M->TQ2_CODBEM)
	While !Eof() .And. STF->TF_FILIAL == cFilSTF .And. STF->TF_CODBEM == M->TQ2_CODBEM
		//VALIDACAO DO DOCUMENTO
		If !Empty(STF->TF_DOCTO) .And. !fChkArquivo("QDH")
			fGravPrb("QDH","TF_DOCTO","Bem: "+M->TQ2_CODBEM,0)
			lExitQDH := .T.
			Exit
		EndIf
		dbSelectArea("STF")
		dbSkip()
	End

	//Valida os componentes da Estrutura
	For zz := 1 To Len(aBEMTRA)

		If lExitQDH
			Exit
		EndIF

		dbSelectArea("STF")
		dbSetOrder(01)
		dbSeek(xFilial("STF")+aBEMTRA[zz])
		While !Eof() .And. STF->TF_FILIAL == cFilSTF .And. STF->TF_CODBEM == aBEMTRA[zz]

			//VALIDACAO DO DOCUMENTO
			If !Empty(STF->TF_DOCTO) .And. !fChkArquivo("QDH")
				fGravPrb("QDH","TF_DOCTO",STR0131+AllTrim(aBEMTRA[zz])+" ("+AllTrim(M->TQ2_CODBEM)+")",0) //"Bem: "
				Exit
			EndIf
			dbSelectArea("STF")
			dbSkip()
		End

	Next zz

	NgPrepTbl({{"STF",01}},SM0->M0_CODIGO)

Return .T.

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³f550ST5T  ³ Autor ³ Felipe Nathan Welter  ³ Data ³ 15/03/10 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³Validacao ST5 - TAREFAS DA MANUTENCAO                       ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³SIGAMNT                                                     ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Static Function f550ST5T()

	Local zz := 0
	Local lExitQDH := .F.

	If fChkArquivo("QDH")
		Return .T.
	EndIf

	cFilST5 := NGTROCAFILI("ST5",M->TQ2_FILORI,M->TQ2_EMPORI)
	NgPrepTbl({{"ST5",01}},M->TQ2_EMPORI)
	dbSeek(cFilST5+M->TQ2_CODBEM)
	While !Eof() .And. ST5->T5_FILIAL == cFilST5 .And. ST5->T5_CODBEM == M->TQ2_CODBEM
		//VALIDACAO DO DOCUMENTO
		If !Empty(ST5->T5_DOCTO) .And. !fChkArquivo("QDH")
			fGravPrb("QDH","T5_DOCTO",STR0131+M->TQ2_CODBEM,0) //"Bem: "
			lExitQDH := .T.
			Exit
		EndIf
		dbSelectArea("ST5")
		dbSkip()
	End

	//Valida os componentes da Estrutura
	For zz := 1 To Len(aBEMTRA)

		If lExitQDH
			Exit
		EndIf

		dbSelectArea("ST5")
		dbSetOrder(01)
		dbSeek(cFilST5+aBEMTRA[zz])
		While !Eof() .And. ST5->T5_FILIAL == cFilST5 .And. ST5->T5_CODBEM == M->TQ2_CODBEM

			//VALIDACAO DO DOCUMENTO
			If !Empty(ST5->T5_DOCTO) .And. !fChkArquivo("QDH")
				fGravPrb("QDH","T5_DOCTO",STR0131+M->TQ2_CODBEM,0) //"Bem: "
				lExitQDH := .T.
				Exit
			EndIf
			dbSkip()
		End

	Next zz

	NgPrepTbl({{"ST5",01}},SM0->M0_CODIGO)

Return .T.

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³f550STGT  ³ Autor ³ Felipe Nathan Welter  ³ Data ³ 15/03/10 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³Validacao STG - DETALHES DA MANUTENCAO                      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³SIGAMNT                                                     ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Static Function f550STGT()
	Local zz := 0
	Local lCOMST1 := .F., lCOMST0 := .F., lCOMSB1 := .F., lCOMSH4 := .F., lCOMSA2 := .F., lCOMSAH := .F.

	If fChkArquivo("ST1") .And. fChkArquivo("ST0") .And. fChkArquivo("SB1") .And. fChkArquivo("SAH") .And. fChkArquivo("SH4") .And. fChkArquivo("SA2")
		Return .T.
	EndIf

	cFilSTG := NGTROCAFILI("STG",M->TQ2_FILORI,M->TQ2_EMPORI)
	NgPrepTbl({{"STG",01}},M->TQ2_EMPORI)
	dbSeek(xFilial("STG")+M->TQ2_CODBEM)
	While !Eof() .And. STG->TG_FILIAL == cFilSTG .And. STG->TG_CODBEM == M->TQ2_CODBEM

		If lCOMST1 .And. lCOMST0 .And. lCOMSB1 .And. lCOMSAH .And. lCOMSH4 .And. lCOMSA2
			Exit
		EndIf

		If STG->TG_TIPOREG == 'M' .And. !lCOMST1  //Mao-de-obra
			If !(fChkArquivo("ST1") .Or. fSilSEEK("ST1",STG->TG_CODIGO,01,M->TQ2_FILDES,M->TQ2_EMPDES))
				fGravPrb("ST1","TG_CODIGO",STR0131+M->TQ2_CODBEM,1) //"Bem: "
				lCOMST1 := .T.
			EndIf
		ElseIf STG->TG_TIPOREG == 'E' .And. !lCOMST0 //Especialidade
			If !(fChkArquivo("ST0") .Or. fSilSEEK("ST1",STG->TG_CODIGO,01,M->TQ2_FILDES,M->TQ2_EMPDES))
				fGravPrb("ST0","TG_CODIGO",STR0131+M->TQ2_CODBEM,1) //"Bem: "
				lCOMST0 := .T.
			EndIf
		ElseIf STG->TG_TIPOREG == 'P' //Produto
			If !(fChkArquivo("SB1") .Or. fSilSEEK("SB1",STG->TG_CODIGO,01,M->TQ2_FILDES,M->TQ2_EMPDES)) .And. !lCOMSB1
				lCOMSB1 := .T.
				fGravPrb("SB1","TG_CODIGO",STR0131+M->TQ2_CODBEM,1) //"Bem: "
			EndIf
			If !(fChkArquivo("SAH") .Or. fSilSEEK("SAH",STG->TG_UNIDADE,01,M->TQ2_FILDES,M->TQ2_EMPDES)) .And. !lCOMSAH
				lCOMSAH := .T.
				fGravPrb("SAH","TG_UNIDADE",STR0131+M->TQ2_CODBEM,1) //"Bem: "
			EndIf
		ElseIf STG->TG_TIPOREG == 'F' .And. !lCOMSH4 //Ferramenta
			If !(fChkArquivo("SH4") .Or. fSilSEEK("SH4",STG->TG_CODIGO,01,M->TQ2_FILDES,M->TQ2_EMPDES))
				lCOMSH4 := .T.
				fGravPrb("SH4","TG_CODIGO",STR0131+M->TQ2_CODBEM,1) //"Bem: "
			EndIf
		ElseIf STG->TG_TIPOREG == 'T' .And. !lCOMSA2 //Terceiro
			If !(fChkArquivo("SA2") .Or. fSilSEEK("SA2",STG->TG_CODIGO,01,M->TQ2_FILDES,M->TQ2_EMPDES))
				lCOMSA2 := .T.
				fGravPrb("SA2","TG_CODIGO",STR0131+M->TQ2_CODBEM,1) //"Bem: "
			EndIf
		EndIf
		dbSkip()
	EndDo

	//Valida os componentes da Estrutura
	For zz := 1 To Len(aBEMTRA)

		If lCOMST1 .And. lCOMST0 .And. lCOMSB1 .And. lCOMSH4 .And. lCOMSA2 .And. lCOMSAH
			Exit
		EndIf

		dbSelectArea("STG")
		dbSetOrder(01)
		dbSeek(cFilSTG+aBEMTRA[zz])
		While !Eof() .And. STG->TG_FILIAL == cFilSTG .And. STG->TG_CODBEM == aBEMTRA[zz]

			If lCOMST1 .And. lCOMST0 .And. lCOMSB1 .And. lCOMSAH .And. lCOMSH4 .And. lCOMSA2
				Exit
			EndIf

			If STG->TG_TIPOREG == 'M' .And. !lCOMST1  //Mao-de-obra
				If !(fChkArquivo("ST1") .Or. fSilSEEK("ST1",STG->TG_CODIGO,01,M->TQ2_FILDES,M->TQ2_EMPDES))
					fGravPrb("ST1","TG_CODIGO",STR0132+AllTrim(aBEMTRA[zz])+" ("+AllTrim(M->TQ2_CODBEM)+")",1) //"Não será gravado insumo Mão-de-Obra. Bem: "
					lCOMST1 := .T.
				EndIf
			ElseIf STG->TG_TIPOREG == 'E' .And. !lCOMST0 //Especialidade
				If !(fChkArquivo("ST0") .Or. fSilSEEK("ST1",STG->TG_CODIGO,01,M->TQ2_FILDES,M->TQ2_EMPDES))
					fGravPrb("ST0","TG_CODIGO",STR0133+AllTrim(aBEMTRA[zz])+" ("+AllTrim(M->TQ2_CODBEM)+")",1) //"Não será gravado insumo Especialidade. Bem: "
					lCOMST0 := .T.
				EndIf
			ElseIf STG->TG_TIPOREG == 'P' //Produto
				If !(fChkArquivo("SB1") .Or. fSilSEEK("SB1",STG->TG_CODIGO,01,M->TQ2_FILDES,M->TQ2_EMPDES)) .And. !lCOMSB1
					lCOMSB1 := .T.
					fGravPrb("SB1","TG_CODIGO",STR0134+AllTrim(aBEMTRA[zz])+" ("+AllTrim(M->TQ2_CODBEM)+")",1) //"Não será gravado insumo Produto. Bem: "
				EndIf
				If !(fChkArquivo("SAH") .Or. fSilSEEK("SAH",STG->TG_UNIDADE,01,M->TQ2_FILDES,M->TQ2_EMPDES)) .And. !lCOMSAH
					lCOMSAH := .T.
					fGravPrb("SAH","TG_UNIDADE",STR0134+AllTrim(aBEMTRA[zz])+" ("+AllTrim(M->TQ2_CODBEM)+")",1) //"Não será gravado insumo Produto. Bem: "
				EndIf
			ElseIf STG->TG_TIPOREG == 'F' .And. !lCOMSH4 //Ferramenta
				If !(fChkArquivo("SH4") .Or. fSilSEEK("SH4",STG->TG_CODIGO,01,M->TQ2_FILDES,M->TQ2_EMPDES))
					lCOMSH4 := .T.
					fGravPrb("SH4","TG_CODIGO",STR0135+AllTrim(aBEMTRA[zz])+" ("+AllTrim(M->TQ2_CODBEM)+")",1) //"Não será gravado insumo Ferramenta. Bem: "
				EndIf
			ElseIf STG->TG_TIPOREG == 'T' .And. !lCOMSA2 //Terceiro
				If !(fChkArquivo("SA2") .Or. fSilSEEK("SA2",STG->TG_CODIGO,01,M->TQ2_FILDES,M->TQ2_EMPDES))
					lCOMSA2 := .T.
					fGravPrb("SA2","TG_CODIGO",STR0136+AllTrim(aBEMTRA[zz])+" ("+AllTrim(M->TQ2_CODBEM)+")",1) //"Não será gravado insumo Terceiro. Bem: "
				EndIf
			EndIf

			dbSelectArea("STG")
			dbSkip()
		EndDo
	Next zz
	NgPrepTbl({{"STG",01}},SM0->M0_CODIGO)

Return .T.

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³f550STHT  ³ Autor ³ Felipe Nathan Welter  ³ Data ³ 15/03/10 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³Validacao STH - ETAPAS DA MANUTENCAO                        ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³SIGAMNT                                                     ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Static Function f550STHT()

	Local zz := 0
	Local lExitTPA := .F.
	Local lExitQDH := .F.

	If fChkArquivo("TPA") .Or. fChkArquivo("QDH")
		Return .T.
	EndIf

	cFilSTH := NGTROCAFILI("STH",M->TQ2_FILORI,M->TQ2_EMPORI)
	NgPrepTbl({{"STH",01}},M->TQ2_EMPORI)
	If dbSeek(cFilSTH+M->TQ2_CODBEM)
		If !(fChkArquivo("TPA") .Or. fSilSEEK("TPA",STH->TH_ETAPA,01,M->TQ2_FILDES,M->TQ2_EMPDES))
			fGravPrb("TPA","TH_ETAPA",STR0131+M->TQ2_CODBEM,1) //"Bem: "
			lExitTPA := .T.
		EndIf
	EndIf

	If (fChkArquivo("TPA") .Or. fSilSEEK("TPA",STH->TH_ETAPA,01,M->TQ2_FILDES,M->TQ2_EMPDES))
		dbSelectArea("STH")
		dbSetOrder(01)
		If dbSeek(cFilSTH+M->TQ2_CODBEM)
			While !Eof() .And. STH->TH_FILIAL == cFilSTH .And. STH->TH_CODBEM == M->TQ2_CODBEM
				If !Empty(STH->TH_DOCTO) .And. !fChkArquivo("QDH")
					fGravPrb("QDH","TH_DOCTO",STR0131+M->TQ2_CODBEM,0) //"Bem: "
					lExitQDH := .T.
				EndIf
				dbSelectArea("STH")
				dbSkip()
			End
		EndIf
	EndIf

	//Valida os componentes da Estrutura
	For zz := 1 To Len(aBEMTRA)

		If lExitTPA .And. lExitQDH
			Exit
		EndIf

		dbSelectArea("STH")
		dbSetOrder(1)
		If dbSeek(cFilSTH+aBEMTRA[zz])

			If !(fChkArquivo("TPA") .Or. fSilSEEK("TPA",STH->TH_ETAPA,01,M->TQ2_FILDES,M->TQ2_EMPDES))
				fGravPrb("TPA","TH_ETAPA",STR0131+AllTrim(aBEMTRA[zz])+" ("+AllTrim(M->TQ2_CODBEM)+")",1) //"Bem: "
				lExitTPA := .T.
			EndIf

		EndIf

		If (fChkArquivo("TPA") .Or. fSilSEEK("TPA",STH->TH_ETAPA,01,M->TQ2_FILDES,M->TQ2_EMPDES))
			dbSelectArea("STH")
			dbSetOrder(01)
			If dbSeek(cFilSTH+aBEMTRA[zz])
				While !Eof() .And. STH->TH_FILIAL == cFilSTH .And. STH->TH_CODBEM == aBEMTRA[zz]
					If !Empty(STH->TH_DOCTO) .And. !fChkArquivo("QDH")
						fGravPrb("QDH","TH_DOCTO",STR0131+AllTrim(aBEMTRA[zz])+" ("+AllTrim(M->TQ2_CODBEM)+")",0) //"Bem: "
						lExitQDH := .T.
					EndIf
					dbSelectArea("STH")
					dbSkip()
				End
			EndIf
		EndIf
	Next zz

	NgPrepTbl({{"STH",01}},SM0->M0_CODIGO)

Return .T.

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³f550TP1T  ³ Autor ³ Felipe Nathan Welter  ³ Data ³ 15/03/10 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³Validacao TP1 - OPCOES DA ETAPA DA MANUTENCAO               ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³SIGAMNT                                                     ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Static Function f550TP1T()
	Local zz := 0
	Local lExitTPA := .F.
	Local lExitTP1 := .F.

	If (fChkArquivo("TPA") .And. fChkArquivo("ST9"))
		Return .T.
	EndIf

	cFilTP1 := NGTROCAFILI("TP1",M->TQ2_FILORI,M->TQ2_EMPORI)
	NgPrepTbl({{"TP1",01}},M->TQ2_EMPORI)
	If dbSeek(cFilTP1+M->TQ2_CODBEM)
		If !(fChkArquivo("TPA") .Or. fSilSEEK("TPA",STH->TH_ETAPA,01,M->TQ2_FILDES,M->TQ2_EMPDES))
			fGravPrb("TPA","TP1_ETAPA",STR0131+M->TQ2_CODBEM,1) //"Bem: "
			fGravPrb("TPC","TP1_ETAPA",STR0131+M->TQ2_CODBEM,1) //"Bem: "
			lExitTPA := .T.
		EndIf
	EndIf

	cFilTP1 := NGTROCAFILI("TP1",M->TQ2_FILDES,M->TQ2_EMPDES)
	cFilST9 := NGTROCAFILI("ST9",M->TQ2_FILDES,M->TQ2_EMPDES)
	NgPrepTbl({{"TP1"},{"ST9"}},M->TQ2_EMPDES)
	If (fChkArquivo("TPA") .Or. fSilSEEK("TPA",STH->TH_ETAPA,01,M->TQ2_FILDES,M->TQ2_EMPDES))
		If (fChkArquivo("ST9") .Or. fSilSEEK("ST9",TP1->TP1_CODBEM,01,M->TQ2_FILDES,M->TQ2_EMPDES))
			dbSelectArea("TP1")
			dbSetOrder(01)
			If dbSeek(cFilTP1+M->TQ2_CODBEM)
				While !Eof() .And. TP1->TP1_FILIAL == cFilTP1 .And. TP1->TP1_CODBEM == M->TQ2_CODBEM
					If !Empty(TP1->TP1_BEMIMN)
						dbSelectArea("ST9")
						dbSetOrder(01)
						If !dbSeek(cFilST9+TP1->TP1_BEMIMN)
							fGravPrb("ST9","TP1_BEMIMN",STR0131+M->TQ2_CODBEM,1) //"Bem: "
							lExitTP1 := .T.
						EndIf
					EndIf
					dbSelectArea("TP1")
					dbSkip()
				EndDo
			EndIf
		EndIf
	EndIf

	//Valida os componentes da Estrutura
	For zz := 1 To Len(aBEMTRA)

		If lExitTPA .And. lExitTP1
			Exit
		EndIf

		cFilTP1 := NGTROCAFILI("TP1",M->TQ2_FILORI,M->TQ2_EMPORI)
		NgPrepTbl({{"TP1",01}},M->TQ2_EMPORI)
		If dbSeek(cFilTP1+aBEMTRA[zz])
			If !(fChkArquivo("TPA") .Or. fSilSEEK("TPA",STH->TH_ETAPA,01,M->TQ2_FILDES,M->TQ2_EMPDES))
				fGravPrb("TPA","TP1_ETAPA",STR0131+AllTrim(aBEMTRA[zz])+" ("+AllTrim(M->TQ2_CODBEM)+")",1) //"Bem: "
				fGravPrb("TPC","TP1_ETAPA",STR0131+AllTrim(aBEMTRA[zz])+" ("+AllTrim(M->TQ2_CODBEM)+")",1) //"Bem: "
				lExitTPA := .T.
			EndIf
		EndIf

		cFilTP1 := NGTROCAFILI("TP1",M->TQ2_FILDES,M->TQ2_EMPDES)
		cFilST9 := NGTROCAFILI("ST9",M->TQ2_FILDES,M->TQ2_EMPDES)
		NgPrepTbl({{"TP1"},{"ST9"}},M->TQ2_EMPDES)
		If (fChkArquivo("TPA") .Or. fSilSEEK("TPA",STH->TH_ETAPA,01,M->TQ2_FILDES,M->TQ2_EMPDES))
			If (fChkArquivo("ST9") .Or. fSilSEEK("ST9",TP1->TP1_CODBEM,01,M->TQ2_FILDES,M->TQ2_EMPDES))
				dbSelectArea("TP1")
				dbSetOrder(01)
				If dbSeek(cFilTP1+aBEMTRA[zz])
					While !Eof() .And. TP1->TP1_FILIAL == cFilTP1 .And. TP1->TP1_CODBEM == aBEMTRA[zz]
						If !Empty(TP1->TP1_BEMIMN)
							dbSelectArea("ST9")
							dbSetOrder(01)
							If !dbSeek(cFilST9+TP1->TP1_BEMIMN)
								fGravPrb("ST9","TP1_BEMIMN",STR0131+AllTrim(aBEMTRA[zz])+" ("+AllTrim(M->TQ2_CODBEM)+")",1) //"Bem: "
								lExitTP1 := .T.
							EndIf
						EndIf
						dbSelectArea("TP1")
						dbSkip()
					EndDo
				EndIf
			EndIf
		EndIf
	Next zz

	NgPrepTbl({{"TP1"},{"ST9"}},SM0->M0_CODIGO)

Return .T.

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³f550STBT  ³ Autor ³ Felipe Nathan Welter  ³ Data ³ 16/03/10 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³Validacao STB - DETALHES DO BEM                             ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³SIGAMNT                                                     ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Static Function f550STBT()

	Local zz := 0
	Local lExitTPR := .F.
	Local lExitSAH := .F.

	If fChkArquivo("TPR") .And. fChkArquivo("SAH")
		Return .T.
	EndIf

	NgPrepTbl({{"STB"},{"ST9"}},M->TQ2_EMPORI)

	cFilSTB := NGTROCAFILI("STB",M->TQ2_FILORI,M->TQ2_EMPORI)
	If !fChkArquivo("TPR")
		dbSelectArea("STB")
		dbSetOrder(01)
		dbSeek(cFilSTB+M->TQ2_CODBEM,.T.)
		While !Eof() .And. cFilSTB == STB->TB_FILIAL .And. M->TQ2_CODBEM == STB->TB_CODBEM
			If !fSilSEEK("TPR",STB->TB_CARACTE,01,M->TQ2_FILDES,M->TQ2_EMPDES)
				fGravPrb("TPR","TB_CARACTE",STR0131+M->TQ2_CODBEM,1)  //nao serao gravadas algumas das caracteristicas //"Bem: "
				lExitTPR := .T.
				Exit
			EndIf
			dbSelectArea("STB")
			dbSkip()
		EndDo
	EndIf

	If !fChkArquivo("STB")
		dbSelectArea("STB")
		dbSetOrder(01)
		dbSeek(cFilSTB+M->TQ2_CODBEM,.T.)
		While !Eof() .And. cFilSTB == STB->TB_FILIAL .And. M->TQ2_CODBEM == STB->TB_CODBEM
			If fSilSEEK("TPR",STB->TB_CARACTE,01,M->TQ2_FILDES,M->TQ2_EMPDES)
				If !Empty(STB->TB_UNIDADE)
					If !fSilSEEK("SAH",STB->TB_UNIDADE,01,M->TQ2_FILDES,M->TQ2_EMPDES)
						fGravPrb("TPR","TB_UNIDADE",STR0131+M->TQ2_CODBEM,0)  //algumas das unidades das caracteristicas serao gravadas em branco //"Bem: "
						lExitSAH := .T.
						Exit
					EndIf
				EndIf
			EndIf
			dbSelectArea("STB")
			dbSkip()
		EndDo
	EndIf

	//Valida os componentes da Estrutura
	For zz := 1 To Len(aBEMTRA)

		If lExitTPR .And. lExitSAH
			Exit
		EndIf

		cFilSTB := NGTROCAFILI("STB",M->TQ2_FILORI,M->TQ2_EMPORI)
		If !fChkArquivo("TPR")
			dbSelectArea("STB")
			dbSetOrder(01)
			dbSeek(cFilSTB+aBEMTRA[zz],.T.)
			While !Eof() .And. cFilSTB == STB->TB_FILIAL .And. aBEMTRA[zz] == STB->TB_CODBEM
				If !fSilSEEK("TPR",STB->TB_CARACTE,01,M->TQ2_FILDES,M->TQ2_EMPDES)
					fGravPrb("TPR","TB_CARACTE",STR0131+AllTrim(aBEMTRA[zz])+" ("+AllTrim(M->TQ2_CODBEM)+")",1)  //nao serao gravadas algumas das caracteristicas //"Bem: "
					lExitTPR := .T.
					Exit
				EndIf
				dbSelectArea("STB")
				dbSkip()
			EndDo
		EndIf

		If !fChkArquivo("STB")
			dbSelectArea("STB")
			dbSetOrder(01)
			dbSeek(cFilSTB+aBEMTRA[zz],.T.)
			While !Eof() .And. cFilSTB == STB->TB_FILIAL .And. aBEMTRA[zz] == STB->TB_CODBEM
				If fSilSEEK("TPR",STB->TB_CARACTE,01,M->TQ2_FILDES,M->TQ2_EMPDES)
					If !Empty(STB->TB_UNIDADE)
						If !fSilSEEK("SAH",STB->TB_UNIDADE,01,M->TQ2_FILDES,M->TQ2_EMPDES)
							fGravPrb("TPR","TB_UNIDADE",STR0131+AllTrim(aBEMTRA[zz])+" ("+AllTrim(M->TQ2_CODBEM)+")",0)  //algumas das unidades das caracteristicas serao gravadas em branco //"Bem: "
							lExitSAH := .T.
							Exit
						EndIf
					EndIf
				EndIf
				dbSelectArea("STB")
				dbSkip()
			EndDo
		EndIf

	Next zz

	NgPrepTbl({{"STB"},{"ST9"}},SM0->M0_CODIGO)

Return .T.

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³f550TPYT  ³ Autor ³ Felipe Nathan Welter  ³ Data ³ 15/03/10 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³Validacao TPY - PECAS DE REPOSICAO DO BEM                   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³SIGAMNT                                                     ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Static Function f550TPYT()
	Local zz := 0

	Local lExitSB1 := .F.
	Local lExitTPS := .F.

	If fChkArquivo("SB1") .And. fChkArquivo("TPS")
		Return .T.
	EndIf

	NgPrepTbl({{"TPY"},{"ST9"}},M->TQ2_EMPORI)

	cFilTPY := NGTROCAFILI("TPY",M->TQ2_FILORI,M->TQ2_EMPORI)
	If !fChkArquivo("SB1")
		dbSelectArea("TPY")
		dbSetOrder(01)
		dbSeek(cFilTPY+M->TQ2_CODBEM,.T.)
		While !Eof() .And. cFilTPY == TPY->TPY_FILIAL .And. M->TQ2_CODBEM == TPY->TPY_CODBEM
			If !fSilSEEK("SB1",TPY->TPY_CODPRO,01,M->TQ2_FILDES,M->TQ2_EMPDES)
				fGravPrb("SB1","TPY_CODPRO",STR0131+M->TQ2_CODBEM,1)  //nao serao gravadas algumas das pecas de reposicao //"Bem: "
				lExitSB1 := .T.
				Exit
			EndIf
			dbSelectArea("TPY")
			dbSkip()
		EndDo
	EndIf

	If !fChkArquivo("TPS")
		dbSelectArea("TPY")
		dbSetOrder(01)
		dbSeek(cFilTPY+M->TQ2_CODBEM,.T.)
		While !Eof() .And. cFilTPY == TPY->TPY_FILIAL .And. M->TQ2_CODBEM == TPY->TPY_CODBEM
			If fSilSEEK("SB1",TPY->TPY_CODPRO,01,M->TQ2_FILDES,M->TQ2_EMPDES)
				If !Empty(TPY->TPY_LOCGAR)
					If !fSilSEEK("TPS",TPY->TPY_LOCGAR,01,M->TQ2_FILDES,M->TQ2_EMPDES)
						fGravPrb("TPS","TPY_LOCGAR",STR0131+M->TQ2_CODBEM,0)  //algumas das localizacoes das pecas de reposicao serao gravadas em branco //"Bem: "
						lExitTPS := .T.
						Exit
					EndIf
				EndIf
			EndIf
			dbSelectArea("TPY")
			dbSkip()
		EndDo
	EndIf

	//Valida os componentes da Estrutura
	For zz := 1 To Len(aBEMTRA)

		If lExitSB1 .And. lExitTPS
			Exit
		EndIf

		cFilTPY := NGTROCAFILI("TPY",M->TQ2_FILORI,M->TQ2_EMPORI)
		If !fChkArquivo("SB1")
			dbSelectArea("TPY")
			dbSetOrder(01)
			dbSeek(cFilTPY+aBEMTRA[zz],.T.)
			While !Eof() .And. cFilTPY == TPY->TPY_FILIAL .And. aBEMTRA[zz] == TPY->TPY_CODBEM
				If !fSilSEEK("SB1",TPY->TPY_CODPRO,01,M->TQ2_FILDES,M->TQ2_EMPDES)
					fGravPrb("SB1","TPY_CODPRO",STR0131+AllTrim(aBEMTRA[zz])+" ("+AllTrim(M->TQ2_CODBEM)+")",1)  //nao serao gravadas algumas das pecas de reposicao //"Bem: "
					lExitSB1 := .T.
					Exit
				EndIf
				dbSelectArea("TPY")
				dbSkip()
			EndDo
		EndIf

		If !fChkArquivo("TPS")
			dbSelectArea("TPY")
			dbSetOrder(01)
			dbSeek(cFilTPY+aBEMTRA[zz],.T.)
			While !Eof() .And. cFilTPY == TPY->TPY_FILIAL .And. aBEMTRA[zz] == TPY->TPY_CODBEM
				If fSilSEEK("SB1",TPY->TPY_CODPRO,01,M->TQ2_FILDES,M->TQ2_EMPDES)
					If !Empty(TPY->TPY_LOCGAR)
						If !fSilSEEK("TPS",TPY->TPY_LOCGAR,01,M->TQ2_FILDES,M->TQ2_EMPDES)
							fGravPrb("TPS","TPY_LOCGAR",STR0131+AllTrim(aBEMTRA[zz])+" ("+AllTrim(M->TQ2_CODBEM)+")",0)  //algumas das localizacoes das pecas de reposicao serao gravadas em branco //"Bem: "
							lExitTPS := .T.
							Exit
						EndIf
					EndIf
				EndIf
				dbSelectArea("TPY")
				dbSkip()
			EndDo
		EndIf

	Next zz

	NgPrepTbl({{"TPY"},{"ST9"}},SM0->M0_CODIGO)

Return .T.

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³f550TQST  ³ Autor ³ Felipe Nathan Welter  ³ Data ³ 15/03/10 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³Validacao TQS - PNEUS                                       ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³SIGAMNT                                                     ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Static Function f550TQST()

	Local zz
	Local lExitTQU := .F.
	Local lExitTPS := .F.

	If fChkArquivo("TQU") .And. fChkArquivo("TPS")
		Return .T.
	EndIf

	NGPrepTBL({{"TQS",01}},M->TQ2_EMPORI)
	If dbSeek(NGTROCAFILI("TQS",M->TQ2_FILORI,M->TQ2_EMPORI)+M->TQ2_CODBEM)
		If !Empty(TQS->TQS_DESENH) .And. !(fChkArquivo("TQU") .Or. fSilSEEK("TQU",TQS->TQS_DESENH,01,M->TQ2_FILDES,M->TQ2_EMPDES))
			fGravPrb("TQU","TQS_DESENH",STR0131+M->TQ2_CODBEM,0) //"Bem: "
			lExitTQU := .T.
		EndIf
	EndIf

	If !fChkArquivo("TPS")
		If !Empty(TQS->TQS_POSIC) .And. !(fChkArquivo("TPS") .Or. fSilSEEK("TPS",TQS->TQS_POSIC,01,M->TQ2_FILDES,M->TQ2_EMPDES))
			fGravPrb("TPS","TQS_POSIC",STR0131+M->TQ2_CODBEM,0) //"Bem: "
			lExitTPS := .F.
		EndIf
	EndIf

	//Valida os componentes da Estrutura
	For zz := 1 To Len(aBEMTRA)

		If lExitTQU .And. lExitTPS
			Exit
		EndIf

		dbSelectArea("TQS")
		dbSetOrder(01)
		If dbSeek(NGTROCAFILI("TQS",M->TQ2_FILORI,M->TQ2_EMPORI)+aBEMTRA[zz])
			If !Empty(TQS->TQS_DESENH) .And. !(fChkArquivo("TQU") .Or. fSilSEEK("TQU",TQS->TQS_DESENH,01,M->TQ2_FILDES,M->TQ2_EMPDES))
				fGravPrb("TQU","TQS_DESENH",STR0131+AllTrim(aBEMTRA[zz])+" ("+AllTrim(M->TQ2_CODBEM)+")",0) //"Bem: "
				lExitTQU := .T.
			EndIf
		EndIf

		If !fChkArquivo("TPS")
			If !Empty(TQS->TQS_POSIC) .And. !(fChkArquivo("TPS") .Or. fSilSEEK("TPS",TQS->TQS_POSIC,01,M->TQ2_FILDES,M->TQ2_EMPDES))
				fGravPrb("TPS","TQS_POSIC",STR0131+AllTrim(aBEMTRA[zz])+" ("+AllTrim(M->TQ2_CODBEM)+")",0) //"Bem: "
				lExitTPS := .F.
			EndIf
		EndIf

	Next zz
	NGPrepTBL({{"TQS",01}},SM0->M0_CODIGO)

Return .T.

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³A550CHKINC³ Autor ³ Felipe Nathan Welter  ³ Data ³ 15/03/10 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³Verificacao se houveram inconsistencias para a transferencia³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³SIGAMNT                                                     ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Static Function f550CHKINC()

	Local lRet := .T.

	//Grava     -> 0 - gravar em branco, 1 - nao vai gravar o registro
	//Nao Grava -> 2 - necessita informar, 3 - problemas de dicionario, 4 - inconsistencias de cadastros

	If (cTRBGRV)->(RecCount()) == 0
		Return .T.
	EndIf

	dbSelectArea(cTRBGRV)
	dbSetOrder(02)
	If dbSeek('2') .Or. dbSeek('3') .Or. dbSeek('4')
		If MsgYesNo(STR0137+CHR(13)+; //"Foram encontradas inconsistências no processo de transferência de bens."
		STR0138,STR0139) //"A transferência será cancelada. Deseja imprimir relatório de inconsistências ?"###"ATENCAO"
			f550RIMP()
		EndIf
		lRet := .F.
	Else
		If MsgYesNo(STR0137+CHR(13)+; //"Foram encontradas inconsistências no processo de transferência de bens."
		STR0140,STR0139) //"Deseja imprimir relatório de inconsistências ?"###"ATENCAO"
			f550RIMP()
			lRet := .T.
		EndIf
	EndIf

Return lRet

//---------------------------------------------------------------------
/*/{Protheus.doc} f550GRAV
Efetiva Gravacao da transferencia
@type static

@author Felipe Nathan Welter
@since 13/03/10

@sample f550GRAV()

@param
@return .T.
/*/
//---------------------------------------------------------------------
Static Function f550GRAV()

	Local i        := 0
	Local nn       := 0
	Local nX       := 0
	Local nCONTAD1 := 0
	Local nCONTAD2 := 0
	Local cCENTRAB := ''
	Local cTipolan := ""

	nREGCONT1 := 0
	nREGCONT2 := 0

	//Grava contadores 1 na filiais de origem
	// Obs.: é necessário atualizar o contator antes da transferencia do bem, pois o ST9 é copiado e precisa estar atualizado.
	If lChkCont
		//Grava Contador 1
		If TIPOACOM .And. M->TQ2_POSCON > 0
			//Gera o registro no histórico de contador para a filial de origem.
			NGTRETCON( M->TQ2_CODBEM, M->TQ2_DATATR, M->TQ2_POSCON, M->TQ2_HORATR, 1,, .F., 'C', M->TQ2_FILORI,, 'MNTA693' )
		EndIf
	EndIf

	//-------------------CADASTRO DE BENS------------------
	If !fSilSEEK("ST9",M->TQ2_CODBEM,01,M->TQ2_FILDES,M->TQ2_EMPDES)

		NGPrepTBL({{"ST9",01}},M->TQ2_EMPORI)
		If dbSeek(NGTROCAFILI("ST9",M->TQ2_FILORI,M->TQ2_EMPORI)+M->TQ2_CODBEM)

			//faz uma copia do ST9
			dbSelectArea(cTRB)
			RecLock((cTRB),.T.)
			For i := 1 To Fcount()
				pp   := "ST9->"+ FieldName(i)
				vl   := "(cTRB)->"+ FieldName(i)
				&vl. := &pp.
			Next i
			(cTRB)->(MsUnLock())

			//Altera o status do ST9
			dbSelectArea("ST9")
			RecLock("ST9",.F.)
			ST9->T9_SITMAN := "I"
			ST9->T9_SITBEM := "T"
			If lFROInt .And. !Empty( _cBemTran_ )
				ST9->T9_STATUS := _cBemTran_
			EndIf
			MsUnLock("ST9")

			NGPrepTBL({{"ST9",01}},M->TQ2_EMPDES)
			//cria um novo ST9
			dbSelectArea("ST9")
			RecLock("ST9",.T.)
			For i := 1 To Fcount()
				nn := FieldName(i)
				pp := "ST9->"+ FieldName(i)
				vl := "(cTRB)->"+ FieldName(i)

				If nn == "T9_FILIAL"
					&pp. := NGTROCAFILI("ST9",M->TQ2_FILDES,M->TQ2_EMPDES)
				ElseIf nn == "T9_CODIMOB"
					If !Empty(&vl.) .And. (fChkArquivo("SN1") .Or. fSilSEEK("SN1",&vl.,01,M->TQ2_FILDES,M->TQ2_EMPDES))
						&pp. := &vl.
					EndIf
				ElseIf nn == "T9_RECFERR"
					If (cTRB)->T9_FERRAME == "F" .And. (fChkArquivo("SH4") .Or. fSilSEEK("SH4",&vl.,01,M->TQ2_FILDES,M->TQ2_EMPDES))
						&pp. := &vl.
					ElseIf (cTRB)->T9_FERRAME == "R" .And. (fChkArquivo("SH1") .Or. fSilSEEK("SH1",&vl.,01,M->TQ2_FILDES,M->TQ2_EMPDES))
						&pp. := &vl.
					EndIf
				ElseIf nn == "T9_CCUSTO"
					If cF3CTTSI3 == "CTT" .And. (fChkArquivo("CTT") .Or. fSilSEEK("CTT",M->TQ2_CCUSTO,01,M->TQ2_FILDES,M->TQ2_EMPDES))
						&pp. := M->TQ2_CCUSTO//&vl.
					ElseIf cF3CTTSI3 == "SI3" .And. (fChkArquivo("SI3") .Or. fSilSEEK("SI3",M->TQ2_CCUSTO,01,M->TQ2_FILDES,M->TQ2_EMPDES))
						&pp. := M->TQ2_CCUSTO//&vl.
					EndIf
				ElseIf nn == "T9_CENTRAB"
					If !Empty(M->TQ2_CENTRA) .And. (fChkArquivo("SHB") .Or. fSilSEEK("SHB",M->TQ2_CENTRA,01,M->TQ2_FILDES,M->TQ2_EMPDES))
						&pp. := M->TQ2_CENTRA//&vl.
					EndIf
				ElseIf nn == "T9_FORNECE"
					If !Empty(&vl.) .And. (fChkArquivo("SA2") .Or. fSilSEEK("SA2",&vl.,01,M->TQ2_FILDES,M->TQ2_EMPDES))
						&pp. := &vl.
					EndIf
				ElseIf nn == "T9_FABRICA"
					If !Empty(&vl.) .And. (fChkArquivo("ST7") .Or. fSilSEEK("ST7",&vl.,01,M->TQ2_FILDES,M->TQ2_EMPDES))
						&pp. := &vl.
					EndIf
				ElseIf nn == "T9_CODESTO"
					If !Empty(&vl.) .And. (fChkArquivo("SB1") .Or. fSilSEEK("SB1",&vl.,01,M->TQ2_FILDES,M->TQ2_EMPDES))
						&pp. := &vl.
					EndIf
				ElseIf nn == "T9_CLIENTE"
					If !Empty(&vl.) .And. (fChkArquivo("SA1") .Or. fSilSEEK("SA1",&vl.,01,M->TQ2_FILDES,M->TQ2_EMPDES))
						&pp. := &vl.
					EndIf
				ElseIf nn == "T9_MTBAIXA"
					If !Empty(&vl.) .And. (fChkArquivo("TPJ") .Or. fSilSEEK("TPJ",&vl.,01,M->TQ2_FILDES,M->TQ2_EMPDES))
						&pp. := &vl.
					EndIf
				ElseIf nn == "T9_ITEMCTA"
					If !Empty(&vl.) .And. (fChkArquivo("CTD") .Or. fSilSEEK("CTD",&vl.,01,M->TQ2_FILDES,M->TQ2_EMPDES))
						&pp. := &vl.
					EndIf
				ElseIf nn == "T9_TIPMOD" .Or.  nn == "T9_STATUS" .Or.  nn == "T9_CORVEI";//FROTAS
					.Or. nn == "T9_UFEMPLA" .Or. nn == "T9_CODTMS" //.Or. nn == "T9_TIPVEI"
					If nn == "T9_TIPMOD"
						If !Empty(&vl.) .And. (fChkArquivo("TQR") .Or. fSilSEEK("TQR",&vl.,01,M->TQ2_FILDES,M->TQ2_EMPDES))
							&pp. := &vl.
						EndIf
					ElseIf nn == "T9_STATUS"
						If !Empty(&vl.) .And. (fChkArquivo("TQY") .Or. fSilSEEK("TQY",&vl.,01,M->TQ2_FILDES,M->TQ2_EMPDES))
							&pp. := &vl.
						EndIf
					ElseIf nn == "T9_CORVEI"
						If !Empty(&vl.) .And. (fChkArquivo("SX5") .Or. fSilSEEK("SX5","M7"+&vl.,01,M->TQ2_FILDES,M->TQ2_EMPDES))
							&pp. := &vl.
						EndIf
					ElseIf nn == "T9_UFEMPLA"
						If !Empty(&vl.) .And. (fChkArquivo("SX5") .Or. fSilSEEK("SX5","12"+&vl.,01,M->TQ2_FILDES,M->TQ2_EMPDES))
							&pp. := &vl.
						EndIf
					ElseIf nn == "T9_CODTMS"
						If !Empty(&vl.) .And. (fChkArquivo("DA3") .Or. fSilSEEK("DA3",&vl.,01,M->TQ2_FILDES,M->TQ2_EMPDES))
							&pp. := &vl.
						EndIf
					EndIf
				Else
					&pp. := &vl.
				EndIf
			Next i
			MsUnLock("ST9")

			//Grava contadores 1 na filiais de destino
			If lChkCont
				//Grava Contador 1
				If TIPOACOM .And. M->TQ2_POSCON > 0
					// Verifica se o bem já existiu na filail de destino, ou seja, já possui um registro com o tipo lançamento igual a "I"
					dbSelectArea( 'STP' )
					dbSetOrder( 8 ) //TP_FILIAL + TP_CODBEM + TP_TIPOLAN
					If dbSeek( M->TQ2_FILDES + M->TQ2_CODBEM + "I" )
						cTipolan	:= "C"
					Else
						cTipolan	:= "I"
					EndIf
					//Posiciona na filial de origem para copiar os dados de saida e criar na destino
					dbSetOrder( 5 ) //TP_FILIAL + TP_CODBEM + TP_DTLEITU + TP_HORA
					If dbSeek( M->TQ2_FILORI + M->TQ2_CODBEM + DtoS( M->TQ2_DATATR ) + M->TQ2_HORATR )
						NGGRAVAHIS( STP->TP_CODBEM, STP->TP_POSCONT, STP->TP_VARDIA, STP->TP_DTLEITU, STP->TP_ACUMCON, STP->TP_VIRACON, STP->TP_HORA, 1, cTipolan,;
							M->TQ2_FILDES, M->TQ2_FILDES, 'MNTA693' )
					EndIf
				EndIf
			EndIf

			//------------------------------------------------------
			//Integracao com TMS
			If ST9->T9_CATBEM == "2"
				If fChkArquivo("DA3")

					//tabela compartilhada entre empresas, troca filial base para filial destino
					NgPrepTbl({{"DA3",03}},M->TQ2_EMPDES)
					If dbSeek(NGTROCAFILI("DA3",M->TQ2_FILDES,M->TQ2_EMPDES)+ST9->T9_PLACA)
						RecLock("DA3",.F.)
						DA3->DA3_FILBAS := NGTROCAFILI("ST9",M->TQ2_FILDES,M->TQ2_EMPDES)
						MsUnLock("DA3")
					EndIf
					NgPrepTbl({{"DA3"}},SM0->M0_CODIGO)

				ElseIf fSilSEEK("DA3",ST9->T9_PLACA,03,M->TQ2_FILDES,M->TQ2_EMPDES)

					//placa TMS existente na empresa destino, associa ST9 ao DA3
					NgPrepTbl({{"DA3",03}},M->TQ2_EMPDES)
					If dbSeek(NGTROCAFILI("DA3",M->TQ2_FILDES,M->TQ2_EMPDES)+ST9->T9_PLACA)

						RecLock("DA3",.F.)
						DA3->DA3_FILBAS := NGTROCAFILI("ST9",M->TQ2_FILDES,M->TQ2_EMPDES)
						MsUnLock("DA3")

						RecLock("ST9",.F.)
						ST9->T9_CODTMS := DA3->DA3_COD
						MsUnLock("ST9")

					EndIf
					NgPrepTbl({{"DA3"}},SM0->M0_CODIGO)

				Else

					//faz uma copia do DA3
					NgPrepTbl({{"DA3",03}},M->TQ2_EMPORI)
					If dbSeek(NGTROCAFILI("DA3",M->TQ2_FILORI,M->TQ2_EMPORI)+ST9->T9_PLACA)
						RecLock((cTRBDA3),.T.)
						For i := 1 To Fcount()
							pp   := "DA3->"+ FieldName(i)
							vl   := "(cTRBDA3)->"+ FieldName(i)
							&vl. := &pp.
						Next i
						(cTRBDA3)->(MsUnLock())

						NgPrepTbl({{"DA3"}},M->TQ2_EMPDES)
						dbSelectArea("DA3")
						RecLock("DA3",.T.)
						For i := 1 To Fcount()
							nn := FieldName(i)
							pp := "DA3->"+ FieldName(i)
							vl := "(cTRBDA3)->"+ FieldName(i)
							If nn == "DA3_FILIAL"
								&pp. := NGTROCAFILI("DA3",M->TQ2_FILDES,M->TQ2_EMPDES)
							ElseIf nn == "DA3_FILBAS"
								&pp. := NGTROCAFILI("ST9",M->TQ2_FILDES,M->TQ2_EMPDES)
							ElseIf nn == "DA3_ESTPLA"
								If !Empty(&vl.) .And. (fChkArquivo("SX5") .Or. fSilSEEK("SX5","12"+&vl.,01,M->TQ2_FILDES,M->TQ2_EMPDES))
									&pp. := &vl.
								EndIf
							ElseIf nn == "DA3_MOTORI"
								If !Empty(&vl.) .And. (fChkArquivo("DA4") .Or. fSilSEEK("DA4",&vl.,01,M->TQ2_FILDES,M->TQ2_EMPDES))
									&pp. := &vl.
								EndIf
							ElseIf nn == "DA3_CODFOR"
								If !Empty(&vl.) .And. (fChkArquivo("SA2") .Or. fSilSEEK("SA2",&vl.,01,M->TQ2_FILDES,M->TQ2_EMPDES))
									&pp. := &vl.
								EndIf
							ElseIf nn == "DA3_MARVEI"
								If !Empty(&vl.) .And. (fChkArquivo("SX5") .Or. fSilSEEK("SX5","M6"+&vl.,01,M->TQ2_FILDES,M->TQ2_EMPDES))
									&pp. := &vl.
								EndIf
							ElseIf nn == "DA3_CORVEI"
								If !Empty(&vl.) .And. (fChkArquivo("SX5") .Or. fSilSEEK("SX5","M7"+&vl.,01,M->TQ2_FILDES,M->TQ2_EMPDES))
									&pp. := &vl.
								EndIf
							ElseIf nn == "DA3_TIPVEI"
								If !Empty(&vl.) .And. (fChkArquivo("DUT") .Or. fSilSEEK("DUT",&vl.,01,M->TQ2_FILDES,M->TQ2_EMPDES))
									&pp. := &vl.
								EndIf
							ElseIf nn == "DA3_ATIVO"
								&pp. := "2"
							Else
								&pp. := &vl.
							EndIf
						Next i
						MsUnLock("DA3")

						RecLock("ST9",.F.)
						ST9->T9_CODTMS := DA3->DA3_COD
						MsUnLock("ST9")

						NgPrepTbl({{"DA3"}},SM0->M0_CODIGO)
					EndIf

				EndIf
			EndIf

			//Contador 1
			nCONTAD1 := ST9->T9_POSCONT

			//Grava contadores 2 na filiais de origem.
			// Obs.: é necessário atualizar o contator antes da transferencia do bem, pois o TPE é copiado e precisa estar atualizado.
			If lChkCont
				//Grava Contador 2
				If TIPOACOM2 .And. M->TQ2_POSCO2 > 0
					//Gera o registro no histórico de contador para a filial de origem.
					NGTRETCON( M->TQ2_CODBEM, M->TQ2_DATATR, M->TQ2_POSCO2, M->TQ2_HORATR, 2,, .F., 'C', M->TQ2_FILORI,, 'MNTA693' )
				EndIf
			EndIf

			//Contador2
			nCONTAD2 := 0
			NgPrepTbl({{"TPE",01}},M->TQ2_EMPORI)
			If dbSeek(NGTROCAFILI("TPE",M->TQ2_FILORI,M->TQ2_EMPORI)+M->TQ2_CODBEM)

				nREGCONT2 := TPE->(Recno())
				nCONTAD2  := TPE->TPE_POSCON

				//Faz uma copia do TPE
				dbSelectArea(cTRBTPE)
				RecLock((cTRBTPE),.T.)
				For i := 1 TO FCOUNT()
					pp   := "TPE->"+ FieldName(i)
					vl   := "(cTRBTPE)->"+ FieldName(i)
					&vl. := &pp.
				Next i
				(cTRBTPE)->(MsUnLock())

				//Cria um novo TPE
				cFilTPE := NGTROCAFILI("TPE",M->TQ2_FILDES,M->TQ2_EMPDES)
				NgPrepTbl({{"TPE"}},M->TQ2_EMPDES)
				If dbSeek(cFilTPE+M->TQ2_CODBEM)
					RecLock("TPE",.F.)
				Else
					RecLock("TPE",.T.)
				EndIf

				For i := 1 TO FCOUNT()
					pp   := "TPE->"+ FieldName(i)
					vl   := "(cTRBTPE)->"+ FieldName(i)
					&pp. := &vl.
				Next i
				TPE->TPE_FILIAL := NGTROCAFILI("TPE",M->TQ2_FILDES,M->TQ2_EMPDES)
				MsUnLock("TPE")

				// Grava o 2 contador na filial de destino
				If lChkCont
					// Verifica se o bem já existiu na filail de destino, ou seja, já possui um registro com o tipo lançamento igual a "I"
					dbSelectArea( 'TPP' )
					dbSetOrder( 8 ) //TPP_FILIAL + TPP_CODBEM + TPP_TIPOLA
					If dbSeek( M->TQ2_FILDES + M->TQ2_CODBEM + "I" )
						cTipolan	:= "C"
					Else
						cTipolan	:= "I"
					EndIf
					dbSetOrder( 5 ) //TPP_FILIAL + TPP_CODBEM + TPP_DTLEIT + TPP_HORA
					If dbSeek( M->TQ2_FILORI + M->TQ2_CODBEM + DtoS( M->TQ2_DATATR ) + M->TQ2_HORATR )
						NGGRAVAHIS( TPP->TPP_CODBEM, TPP->TPP_POSCON, TPP->TPP_VARDIA, TPP->TPP_DTLEIT, TPP->TPP_ACUMCO, TPP->TPP_VIRACO, TPP->TPP_HORA, 2, cTipolan,;
							M->TQ2_FILDES, M->TQ2_FILDES, 'MNTA693' )
					EndIf
				EndIf

			EndIf
			NgPrepTbl({{"TPE"}},SM0->M0_CODIGO)

			//---Movimentacao de Centro de Custo
			cFilTPN := NGTROCAFILI("TPN",M->TQ2_FILDES,M->TQ2_EMPDES)
			NgPrepTbl({{"TPN",01}},M->TQ2_EMPDES)
			If !dbSeek(cFilTPN+M->TQ2_CODBEM+M->TQ2_CCUSTO+M->TQ2_CENTRA+DTOS(M->TQ2_DATATR)+M->TQ2_HORATR)
				RecLock("TPN",.T.)
				TPN->TPN_FILIAL := cFilTPN
				TPN->TPN_CODBEM := M->TQ2_CODBEM
				TPN->TPN_DTINIC := M->TQ2_DATATR
				TPN->TPN_HRINIC := M->TQ2_HORATR
				TPN->TPN_CCUSTO := M->TQ2_CCUSTO
				TPN->TPN_CTRAB  := M->TQ2_CENTRA
				TPN->TPN_UTILIZ := "U"
				TPN->TPN_POSCON := M->TQ2_POSCON
				TPN->TPN_POSCO2 := M->TQ2_POSCO2
				MsUnLock("TPN")
			EndIf
			NgPrepTbl({{"TPN",01}},SM0->M0_CODIGO)

			//Cria Historico de Movimentacao (exclusao) da Estrutura Organizacional
			NgPrepTbl({{"TCJ"},{"TAF"}},M->TQ2_EMPORI)
			dbSelectArea("TAF")
			dbSetOrder(06)
			If dbSeek(NGTROCAFILI("TAF",M->TQ2_FILORI,M->TQ2_EMPORI)+"X1"+M->TQ2_CODBEM)
				dbSelectArea("TCJ")
				dbSetOrder(01)
				If !dbSeek(NGTROCAFILI("TCJ",M->TQ2_FILORI,M->TQ2_EMPORI)+TAF->TAF_CODNIV+TAF->TAF_NIVSUP+"E"+DTOS(dDataBase)+Time())
					RecLock("TCJ",.T.)
					TCJ->TCJ_FILIAL := NGTROCAFILI("TCJ",M->TQ2_FILORI,M->TQ2_EMPORI)
					TCJ->TCJ_CODNIV := TAF->TAF_CODNIV
					TCJ->TCJ_DESNIV := SubStr(TAF->TAF_NOMNIV,1,40)
					TCJ->TCJ_NIVSUP := TAF->TAF_NIVSUP
					TCJ->TCJ_DATA   := dDatabase
					TCJ->TCJ_HORA   := Time()
					TCJ->TCJ_TIPROC := "E"
					MsUnLock("TCJ")
				EndIf
			EndIf
			NgPrepTbl({{"TCJ"},{"TAF"}},SM0->M0_CODIGO)

			//Realiza a exclusao na Estrutura Organizacional e participantes do processo
			NgPrepTbl({{"TAF"},{"TAK"}},M->TQ2_EMPORI)
			dbSelectArea("TAF")
			dbSetOrder(06)
			If dbSeek(NGTROCAFILI("TAF",M->TQ2_FILORI,M->TQ2_EMPORI)+"X1"+M->TQ2_CODBEM)
				dbSelectArea("TAK")
				dbSetOrder(01)
				dbSeek(NGTROCAFILI("TAK",M->TQ2_FILORI,M->TQ2_EMPORI)+"001"+TAF->TAF_CODNIV)
				While !Eof() .And. TAK->TAK_FILIAL+"001"+TAK->TAK_CODNIV == NGTROCAFILI("TAK",M->TQ2_FILORI,M->TQ2_EMPORI)+"001"+TAF->TAF_CODNIV
					RecLock("TAK",.F.)
					dbDelete()
					MsUnlock("TAK")
					dbSelectArea("TAK")
					dbSkip()
				End
				RecLock("TAF",.F.)
				dbDelete()
				MsUnLock("TAF")
			EndIf

			NgPrepTbl({{"TAF"},{"TAK"}},SM0->M0_CODIGO)

		EndIf

		NGPrepTBL({{"ST9",01}},SM0->M0_CODIGO)

		f550TCARA(M->TQ2_CODBEM) //Faz a tranferencia das caracteristicas
		f550TREPO(M->TQ2_CODBEM) //Faz a tranferencia das pecas de reposicao
		f550BANCON(M->TQ2_CODBEM,"ST9",M->TQ2_FILORI,M->TQ2_EMPORI,M->TQ2_FILDES,M->TQ2_EMPDES)//Faz a tranferencia do banco do conhecimento
		If lFROInt
			f550TANQUE(M->TQ2_CODBEM) //Faz tranferencia do tanque de combustivel
			If lTS3Table
				f550PENHOR(M->TQ2_CODBEM) //Faz transferencia dos registros de veiculo penhorado
			EndIf
			If lTSJTable
				f550LEASIN(M->TQ2_CODBEM) //Faz transferencia dos registros de leasing de veiculos
			EndIf
			If lTQSInt
				f550PNEUS(M->TQ2_CODBEM)//Faz a tranferencia de pneus quando integrado com frotas
			EndIf
		EndIf
		f550TMANU(M->TQ2_CODBEM) //Faz a tranferencia da manutencao
		f550TRAS(nREGCONT1,nREGCONT2)  //Faz a tranferencia dos componentes da estrutura de bens

	Else
		NGPrepTBL({{"ST9",01}},M->TQ2_EMPORI)

		If dbSeek(NGTROCAFILI("ST9",M->TQ2_FILORI,M->TQ2_EMPORI)+M->TQ2_CODBEM)

			//faz uma copia do ST9
			dbSelectArea(cTRB)
			RecLock((cTRB),.T.)
			For i := 1 TO FCOUNT()
				pp   := "ST9->"+ FieldName(i)
				vl   := "(cTRB)->"+ FieldName(i)
				&vl. := &pp.
			Next i
			(cTRB)->(MsUnLock())

			dbSelectArea("ST9")
			RecLock("ST9",.F.)
			ST9->T9_SITMAN := "I"
			ST9->T9_SITBEM := "T"
			MsUnLock("ST9")

			NgPrepTbl({{"ST9"}},M->TQ2_EMPDES)
			dbSelectArea("ST9")
			If dbSeek(NGTROCAFILI("ST9",M->TQ2_FILDES,M->TQ2_EMPDES)+M->TQ2_CODBEM)

				dbSelectArea("ST9")
				RecLock("ST9",.F.)
				For i := 1 TO FCOUNT()

					nn := FieldName(i)
					pp := "ST9->"+ FieldName(i)
					vl := "(cTRB)->"+ FieldName(i)

					If nn == "T9_FILIAL"
						&pp. := NGTROCAFILI("ST9",M->TQ2_FILDES,M->TQ2_EMPDES)
					ElseIf nn == "T9_CODIMOB"
						If !Empty(&vl.) .And. (fChkArquivo("SN1") .Or. fSilSEEK("SN1",&vl.,01,M->TQ2_FILDES,M->TQ2_EMPDES))
							&pp. := &vl.
						Else
							&pp. := ""
						EndIf
					ElseIf nn == "T9_RECFERR"
						If (cTRB)->T9_FERRAME == "F"
							If (fChkArquivo("SH4") .Or. fSilSEEK("SH4",&vl.,01,M->TQ2_FILDES,M->TQ2_EMPDES))
								&pp. := &vl.
							Else
								&pp. := ""
							EndIf
						ElseIf (cTRB)->T9_FERRAME == "R"
							If (fChkArquivo("SH1") .Or. fSilSEEK("SH1",&vl.,01,M->TQ2_FILDES,M->TQ2_EMPDES))
								&pp. := &vl.
							Else
								&pp. := ""
							EndIf
						EndIf
					ElseIf nn == "T9_CCUSTO"
						If cF3CTTSI3 == "CTT"
							If !Empty(M->TQ2_CCUSTO) .And. (fChkArquivo("CTT") .Or. fSilSEEK("CTT",M->TQ2_CCUSTO,01,M->TQ2_FILDES,M->TQ2_EMPDES))
								&pp. := M->TQ2_CCUSTO//&vl.
							EndIf
						ElseIf cF3CTTSI3 == "SI3"
							If !Empty(&vl.) .And. (fChkArquivo("SI3") .Or. fSilSEEK("SI3",&vl.,01,M->TQ2_FILDES,M->TQ2_EMPDES))
								&pp. := &vl.
							EndIf
						EndIf
					ElseIf nn == "T9_CENTRAB"
						If !Empty(M->TQ2_CENTRA) .And. (fChkArquivo("SHB") .Or. fSilSEEK("SHB",M->TQ2_CENTRA,01,M->TQ2_FILDES,M->TQ2_EMPDES))
							&pp. := M->TQ2_CENTRA//&vl.
						Else
							&pp. := ""
						EndIf
					ElseIf nn == "T9_FORNECE"
						If !Empty(&vl.) .And. (fChkArquivo("SA2") .Or. fSilSEEK("SA2",&vl.,01,M->TQ2_FILDES,M->TQ2_EMPDES))
							&pp. := &vl.
						Else
							&pp. := ""
						EndIf
					ElseIf nn == "T9_FABRICA"
						If !Empty(&vl.) .And. (fChkArquivo("ST7") .Or. fSilSEEK("ST7",&vl.,01,M->TQ2_FILDES,M->TQ2_EMPDES))
							&pp. := &vl.
						Else
							&pp. := ""
						EndIf
					ElseIf nn == "T9_CODESTO"
						If !Empty(&vl.) .And. (fChkArquivo("SB1") .Or. fSilSEEK("SB1",&vl.,01,M->TQ2_FILDES,M->TQ2_EMPDES))
							&pp. := &vl.
						Else
							&pp. := ""
						EndIf
					ElseIf nn == "T9_CLIENTE"
						If !Empty(&vl.) .And. (fChkArquivo("SA1") .Or. fSilSEEK("SA1",&vl.,01,M->TQ2_FILDES,M->TQ2_EMPDES))
							&pp. := &vl.
						Else
							&pp. := ""
						EndIf
					ElseIf nn == "T9_MTBAIXA"
						If !Empty(&vl.) .And. (fChkArquivo("TPJ") .Or. fSilSEEK("TPJ",&vl.,01,M->TQ2_FILDES,M->TQ2_EMPDES))
							&pp. := &vl.
						Else
							&pp. := ""
						EndIf
					ElseIf nn == "T9_ITEMCTA"
						If !Empty(&vl.) .And. (fChkArquivo("CTD") .Or. fSilSEEK("CTD",&vl.,01,M->TQ2_FILDES,M->TQ2_EMPDES))
							&pp. := &vl.
						Else
							&pp. := ""
						EndIf
					ElseIf nn == "T9_TIPMOD" .Or.  nn == "T9_STATUS" .Or.  nn == "T9_CORVEI";//FROTAS
						.Or. nn == "T9_UFEMPLA" .Or. nn == "T9_CODTMS" //.Or. nn == "T9_TIPVEI"

						If nn == "T9_TIPMOD"
							If !Empty(&vl.) .And. (fChkArquivo("TQR") .Or. fSilSEEK("TQR",&vl.,01,M->TQ2_FILDES,M->TQ2_EMPDES))
								&pp. := &vl.
							Else
								&pp. := ""
							EndIf
						ElseIf nn == "T9_STATUS"
							If !Empty(&vl.) .And. (fChkArquivo("TQY") .Or. fSilSEEK("TQY",&vl.,01,M->TQ2_FILDES,M->TQ2_EMPDES))
								&pp. := &vl.
							Else
								&pp. := ""
							EndIf
						ElseIf nn == "T9_CORVEI"
							If !Empty(&vl.) .And. (fChkArquivo("SX5") .Or. fSilSEEK("SX5","M7"+&vl.,01,M->TQ2_FILDES,M->TQ2_EMPDES))
								&pp. := &vl.
							Else
								&pp. := ""
							EndIf
						ElseIf nn == "T9_UFEMPLA"
							If !Empty(&vl.) .And. (fChkArquivo("SX5") .Or. fSilSEEK("SX5","12"+&vl.,01,M->TQ2_FILDES,M->TQ2_EMPDES))
								&pp. := &vl.
							Else
								&pp. := ""
							EndIf
						ElseIf nn == "T9_CODTMS"
							If !Empty(&vl.) .And. (fChkArquivo("DA3") .Or. fSilSEEK("DA3",&vl.,01,M->TQ2_FILDES,M->TQ2_EMPDES))
								&pp. := &vl.
							Else
								&pp. := ""
							EndIf
						EndIf
					Else
						&pp. := &vl.
					EndIf
				Next i
				MsUnLock("ST9")

				//Grava contadores 1 na filiais de destino
				If lChkCont
					//Grava Contador 1
					If TIPOACOM .And. M->TQ2_POSCON > 0
						// Verifica se o bem já existiu na filail de destino, ou seja, já possui um registro com o tipo lançamento igual a "I"
						dbSelectArea( 'STP' )
						dbSetOrder( 8 ) //TP_FILIAL + TP_CODBEM + TP_TIPOLAN
						If dbSeek( M->TQ2_FILDES + M->TQ2_CODBEM + "I" )
							cTipolan	:= "C"
						Else
							cTipolan	:= "I"
						EndIf
						//Posiciona na filial de origem para copiar os dados de saida e criar na destino
						dbSetOrder( 5 ) //TP_FILIAL + TP_CODBEM + TP_DTLEITU + TP_HORA
						If dbSeek( M->TQ2_FILORI + M->TQ2_CODBEM + DtoS( M->TQ2_DATATR ) + M->TQ2_HORATR )
							NGGRAVAHIS( STP->TP_CODBEM, STP->TP_POSCONT, STP->TP_VARDIA, STP->TP_DTLEITU, STP->TP_ACUMCON, STP->TP_VIRACON, STP->TP_HORA, 1, cTipolan,;
								M->TQ2_FILDES, M->TQ2_FILDES, 'MNTA693' )
						EndIf
					EndIf
				EndIf

				//Integracao com TMS
				If ST9->T9_CATBEM == "2"

					If fChkArquivo("DA3")
						//tabela compartilhada entre empresas, troca filial base para filial destino
						NgPrepTbl({{"DA3",03}},M->TQ2_EMPDES)
						If dbSeek(NGTROCAFILI("DA3",M->TQ2_FILDES,M->TQ2_EMPDES)+ST9->T9_PLACA)
							RecLock("DA3",.F.)
							DA3->DA3_FILBAS := NGTROCAFILI("ST9",M->TQ2_FILDES,M->TQ2_EMPDES)
							MsUnLock("DA3")
						EndIf
						NgPrepTbl({{"DA3"}},SM0->M0_CODIGO)

					ElseIf fSilSEEK("DA3",ST9->T9_PLACA,03,M->TQ2_FILDES,M->TQ2_EMPDES)

						//placa TMS existente na empresa destino, associa ST9 ao DA3
						NgPrepTbl({{"DA3",03}},M->TQ2_EMPDES)
						If dbSeek(NGTROCAFILI("DA3",M->TQ2_FILDES,M->TQ2_EMPDES)+ST9->T9_PLACA)

							RecLock("DA3",.F.)
							DA3->DA3_FILBAS := NGTROCAFILI("ST9",M->TQ2_FILDES,M->TQ2_EMPDES)
							MsUnLock("DA3")

							RecLock("ST9",.F.)
							ST9->T9_CODTMS := DA3->DA3_COD
							MsUnLock("ST9")

						EndIf
						NgPrepTbl({{"DA3"}},SM0->M0_CODIGO)
					Else

						//faz uma copia do DA3
						NgPrepTbl({{"DA3",03}},M->TQ2_EMPORI)
						If dbSeek(NGTROCAFILI("DA3",M->TQ2_FILORI,M->TQ2_EMPORI)+ST9->T9_PLACA)
							RecLock((cTRBDA3),.T.)
							For i := 1 To Fcount()
								pp   := "DA3->"+ FieldName(i)
								vl   := "(cTRB)->"+ FieldName(i)
								&vl. := &pp.
							Next i
							(cTRBDA3)->(MsUnLock())

							NgPrepTbl({{"DA3"}},M->TQ2_EMPDES)
							dbSelectArea("DA3")
							RecLock("DA3",.T.)
							For i := 1 To Fcount()
								nn := FieldName(i)
								pp := "DA3->"+ FieldName(i)
								vl := "(cTRBDA3)->"+ FieldName(i)
								If nn == "DA3_FILIAL"
									&pp. := NGTROCAFILI("DA3",M->TQ2_FILDES,M->TQ2_EMPDES)
								ElseIf nn == "DA3_FILBAS"
									&pp. := NGTROCAFILI("ST9",M->TQ2_FILDES,M->TQ2_EMPDES)
								ElseIf nn == "DA3_ESTPLA"
									If !Empty(&vl.) .And. (fChkArquivo("SX5") .Or. fSilSEEK("SX5","12"+&vl.,01,M->TQ2_FILDES,M->TQ2_EMPDES))
										&pp. := &vl.
									EndIf
								ElseIf nn == "DA3_MOTORI"
									If !Empty(&vl.) .And. (fChkArquivo("DA4") .Or. fSilSEEK("DA4",&vl.,01,M->TQ2_FILDES,M->TQ2_EMPDES))
										&pp. := &vl.
									EndIf
								ElseIf nn == "DA3_CODFOR"
									If !Empty(&vl.) .And. (fChkArquivo("SA2") .Or. fSilSEEK("SA2",&vl.,01,M->TQ2_FILDES,M->TQ2_EMPDES))
										&pp. := &vl.
									EndIf
								ElseIf nn == "DA3_MARVEI"
									If !Empty(&vl.) .And. (fChkArquivo("SX5") .Or. fSilSEEK("SX5","M6"+&vl.,01,M->TQ2_FILDES,M->TQ2_EMPDES))
										&pp. := &vl.
									EndIf
								ElseIf nn == "DA3_CORVEI"
									If !Empty(&vl.) .And. (fChkArquivo("SX5") .Or. fSilSEEK("SX5","M7"+&vl.,01,M->TQ2_FILDES,M->TQ2_EMPDES))
										&pp. := &vl.
									EndIf
								ElseIf nn == "DA3_TIPVEI"
									If !Empty(&vl.) .And. (fChkArquivo("DUT") .Or. fSilSEEK("DUT",&vl.,01,M->TQ2_FILDES,M->TQ2_EMPDES))
										&pp. := &vl.
									EndIf
								ElseIf nn == "DA3_ATIVO"
									&pp. := "2"
								Else
									&pp. := &vl.
								EndIf
							Next i
							MsUnLock("DA3")

							RecLock("ST9",.F.)
							ST9->T9_CODTMS := DA3->DA3_COD
							MsUnLock("ST9")

							NgPrepTbl({{"DA3"}},SM0->M0_CODIGO)
						EndIf

					EndIf
				EndIf

				//Contador 1
				nCONTAD1 := ST9->T9_POSCONT

				//Contador 2
				nCONTAD2 := 0

				//Grava contadores 2 na filiais de origem.
				// Obs.: é necessário atualizar o contator antes da transferencia do bem, pois o TPE é copiado e precisa estar atualizado.
				If lChkCont
					//Grava Contador 2
					If TIPOACOM2 .And. M->TQ2_POSCO2 > 0
						//Gera o registro no histórico de contador para a filial de origem.
						NGTRETCON( M->TQ2_CODBEM, M->TQ2_DATATR, M->TQ2_POSCO2, M->TQ2_HORATR, 2,, .F., 'C', M->TQ2_FILORI,, 'MNTA693' )
					EndIf
				EndIf

				NgPrepTbl({{"TPE",01}},M->TQ2_EMPORI)
				If dbSeek(NGTROCAFILI("TPE",M->TQ2_FILORI,M->TQ2_EMPORI)+M->TQ2_CODBEM)

					nREGCONT2 := TPE->(Recno())
					nCONTAD2  := TPE->TPE_POSCON

					dbSelectArea(cTRBTPE)
					RecLock((cTRBTPE),.T.)
					For i := 1 TO FCOUNT()
						pp   := "TPE->"+ FieldName(i)
						vl   := "(cTRBTPE)->"+ FieldName(i)
						&vl. := &pp.
					Next i
					(cTRBTPE)->(MsUnLock())

					//Cria um novo TPE
					cFilTPE := NGTROCAFILI("TPE",M->TQ2_FILDES,M->TQ2_EMPDES)
					NgPrepTbl({{"TPE"}},M->TQ2_EMPDES)
					If dbSeek(cFilTPE+M->TQ2_CODBEM)
						RecLock("TPE",.F.)
					Else
						RecLock("TPE",.T.)
					EndIf

					For i := 1 TO FCOUNT()
						pp   := "TPE->"+ FieldName(i)
						vl   := "(cTRBTPE)->"+ FieldName(i)
						&pp. := &vl.
					Next i
					TPE->TPE_FILIAL := NGTROCAFILI("TPE",M->TQ2_FILDES,M->TQ2_EMPDES)
					MsUnLock("TPE")
				EndIf

				//Grava contadores 2 na filiais de origem.
				// Obs.: é necessário atualizar o contator antes da transferencia do bem, pois o TPE é copiado e precisa estar atualizado.
				If lChkCont
					dbSelectArea( 'TPP' )
					dbSetOrder( 8 ) //TPP_FILIAL + TPP_CODBEM + TPP_TIPOLA
					If dbSeek( M->TQ2_FILDES + M->TQ2_CODBEM + "I" )
						cTipolan	:= "C"
					Else
						cTipolan	:= "I"
					EndIf

					dbSetOrder( 5 ) //TPP_FILIAL + TPP_CODBEM + TPP_DTLEIT + TPP_HORA
					If dbSeek( M->TQ2_FILORI + M->TQ2_CODBEM + DtoS( M->TQ2_DATATR ) + M->TQ2_HORATR )
						NGGRAVAHIS( TPP->TPP_CODBEM, TPP->TPP_POSCON, TPP->TPP_VARDIA, TPP->TPP_DTLEIT, TPP->TPP_ACUMCO, TPP->TPP_VIRACO, TPP->TPP_HORA, 2, cTipolan,;
							M->TQ2_FILDES, M->TQ2_FILDES, 'MNTA693' )
					EndIf
				EndIf

				NgPrepTbl({{"TPE"}},SM0->M0_CODIGO)

				//---Movimentacao de centro de custo
				cFilTPN := NGTROCAFILI("TPN",M->TQ2_FILDES,M->TQ2_EMPDES)
				NgPrepTbl({{"TPN",01}},M->TQ2_EMPDES)
				If !dbSeek(cFilTPN+M->TQ2_CODBEM+M->TQ2_CCUSTO+M->TQ2_CENTRA+DTOS(M->TQ2_DATATR)+M->TQ2_HORATR)
					RecLock("TPN",.T.)
					TPN->TPN_FILIAL := cFilTPN
					TPN->TPN_CODBEM := M->TQ2_CODBEM
					TPN->TPN_DTINIC := M->TQ2_DATATR
					TPN->TPN_HRINIC := M->TQ2_HORATR
					TPN->TPN_CCUSTO := M->TQ2_CCUSTO
					TPN->TPN_CTRAB  := M->TQ2_CENTRA
					TPN->TPN_UTILIZ := "U"
					TPN->TPN_POSCON := nCONTAD1
					TPN->TPN_POSCO2 := nCONTAD2
					MsUnLock("TPN")
				EndIf
				NgPrepTbl({{"TPN",01}},SM0->M0_CODIGO)

				f550TCARA(M->TQ2_CODBEM) //Faz a tranferencia das caracteristicas
				f550TREPO(M->TQ2_CODBEM) //Faz a tranferencia das pecas de reposicao
				f550BANCON(M->TQ2_CODBEM,"ST9",M->TQ2_FILORI,M->TQ2_EMPORI,M->TQ2_FILDES,M->TQ2_EMPDES)//Faz a tranferencia do banco do conhecimento
				If lFROInt
					f550TANQUE(M->TQ2_CODBEM) //Faz tranferencia do tanque de combustivel
					If lTS3Table
						f550PENHOR(M->TQ2_CODBEM) //Faz transferencia dos registros de veiculo penhorado
					EndIf
					If lTSJTable
						f550LEASIN(M->TQ2_CODBEM) //Faz transferencia dos registros de leasing de veiculos
					EndIf
					If lTQSInt
						f550PNEUS(M->TQ2_CODBEM)//Faz a tranferencia de pneus quando integrado com frotas
					EndIf
				EndIf
				f550TMANU(M->TQ2_CODBEM) //Faz a tranferencia da manutencao
				f550TRAS(nREGCONT1,nREGCONT2)  //Faz a tranferencia dos componentes da estrutura de bens
			EndIf

		EndIf

		//Altera registro da TTM - Veiculos do Grupo
		aAreaTTM := TTM->(GetArea())
		dbSelectArea("TTM")
		dbSetOrder(01)
		If dbSeek(M->TQ2_CODBEM)
			RecLock("TTM",.F.)
			TTM->TTM_EMPROP := M->TQ2_EMPDES
			TTM->TTM_FILPRO := M->TQ2_FILDES
			MsUnLock("TTM")
		EndIf
		RestArea(aAreaTTM)

		//Altera movimentacoes da TTI
		If AliasInDic("TTI")
			aAreaTTI := TTI->(GetArea())
			dbSelectArea("TTI")
			dbSetOrder(03)
			dbSeek(M->TQ2_EMPORI+M->TQ2_FILORI+M->TQ2_CODBEM,.T.)
			While !Eof() .And. TTI->TTI_EMPVEI == M->TQ2_EMPORI .And. TTI->TTI_FILVEI == M->TQ2_FILORI .And. TTI->TTI_CODVEI == M->TQ2_CODBEM
				RecLock("TTI",.F.)
				TTI->TTI_EMPVEI := M->TQ2_EMPDES
				TTI->TTI_FILVEI := M->TQ2_FILDES
				MsUnLock("TTI")
				dbSelectArea("TTI")
				dbSkip()
			EndDo
			RestArea(aAreaTTI)

			If Type("M->TTI_EMPVEI") == "C"
				M->TTI_EMPVEI := M->TQ2_EMPDES
				M->TTI_FILVEI := M->TQ2_FILDES
			EndIf
		EndIf
	EndIf

Return .T.

//---------------------------------------------------------------------
/*/{Protheus.doc} fCriaTRB
Cria arquivos temporarios
@author eduardo.izola
@since 16/02/2017
@version undefined
@type function
/*/
//---------------------------------------------------------------------
Static Function fCriaTRB()

	Local i
	Local cObjName

	//Arquivo de inconsistencias
	aCampos  := {}
	aAdd(aCAMPOS,{"TABELA", "C", 003, 0})
	aAdd(aCAMPOS,{"CAMPO" , "C", 010, 0})
	aAdd(aCAMPOS,{"CONTEU", "C", 400, 0})
	aAdd(aCAMPOS,{"TIPO"  , "C", 001, 0})

	//Array de Criação de tabelas Temporárias (cAlias,aField,aIndex,AliasTabela)
	aCriaTRB := { { cTRBGRV, aCampos	, {{"CAMPO","TABELA"},{"TIPO","CAMPO","TABELA"}}, 	   ,								},;
		{ cTRB   ,			, {{"T9_FILIAL"}} 								, "ST9",								},;
		{ cTRBDA3,			, {{"DA3_FILIAL"}}								, "DA3",								},;
		{ cTRBSTB,			, {{"TB_FILIAL"}} 								, "STB",								},;
		{ cTRBTPY,			, {{"TPY_FILIAL"}}								, "TPY",								},;
		{ cTRBAC9,			, {{"AC9_FILIAL"}}								, "AC9",								},;
		{ cTRBACB,			, {{"ACB_CODOBJ"}}								, "ACB",								},;
		{ cTRBACC,			, {{"ACC_CODOBJ"}}								, "ACC",								},;
		{ cTRBTPN,			, {{"TPN_FILIAL"}}								, "TPN",								},;
		{ cTRBTPE,			, {{"TPE_FILIAL"}}								, "TPE",								},;
		{ cTRBSTC,			, {{"TC_FILIAL"}} 								, "STC",								},;
		{ cTRBSTZ,			, {{"TZ_FILIAL"}}								, "STZ",								},;
		{ cTRBSTF,			, {{"TF_FILIAL"}} 								, "STF",								},;
		{ cTRBST5,			, {{"T5_FILIAL"}} 								, "ST5",								},;
		{ cTRBSTM,			, {{"TM_FILIAL"}} 								, "STM",								},;
		{ cTRBSTG,			, {{"TG_FILIAL"}} 								, "STG",								},;
		{ cTRBSTH,			, {{"TH_FILIAL"}} 								, "STH",								},;
		{ cTRBTP1,			, {{"TP1_FILIAL"}}								, "TP1",								},;
		{ cTRBTQS,			, {{"TQS_FILIAL"}}								, "TQS", {|| lFROInt .And. lTQSInt }	},;
		{ cTRBTT8,			, {{"TT8_FILIAL"}}								, "TT8", {|| lTT8Tanque }				},;
		{ cTRBTS3,			, {{"TS3_FILIAL"}}								, "TS3", {|| lTS3Table  }				},;
		{ cTRBTSJ,			, {{"TSJ_FILIAL"}}								, "TSJ", {|| lTSJTable  }				}}

	aTRBs := {}
	//Cria Tabelas temporarias contidas no aCriaTRB
	For i := 1 To Len(aCriaTRB)

		cAlsTRB := aCriaTRB[ i , _nPosTRB ]
		xCps	:= aCriaTRB[ i , _nPosCps ]
		aIndex	:= aCriaTRB[ i , _nPosIdx ]
		xAlias	:= aCriaTRB[ i , _nPosAls ]
		xValid	:= aCriaTRB[ i , _nPosVld ]

		//Faz verificação para criação da Tabela Temporária
		If ValType( xValid ) <> "B" .Or. Eval( xValid )

			cObjName := "oTmpTbl" + cValToChar(i)

			_SetOwnerPrvt( cObjName , Nil )

			&( cObjName ) := fStructTRB( cAlsTRB , xCps , aIndex , xAlias )

			aAdd( aTRBs ,  cObjName  )

		EndIf

	Next i

Return .T.

//---------------------------------------------------------------------
/*/{Protheus.doc} C280WCLEAR
Deleção das Tabelas Temporárias
@author eduardo.izola
@since 07/03/2017
@version undefined
@type function
/*/
//---------------------------------------------------------------------
Static Function f550CLOSE()

	Local i

	For i := 1 To Len (aTRBs)
		&(aTRBs[i]):Delete()
	Next i

Return .T.

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³f550RIMP  ³ Autor ³ Felipe Nathan Welter  ³ Data ³ 18/03/10 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³Imprime os problemas encontrados na transferencia           ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³SIGAMNT                                                     ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function f550RIMP()

	Local cString  := "SA1"
	Local cDesc1   := STR0142 //"Geracao de inconsistencias encontradas durante o processo de Checagem"
	Local cDesc2   := STR0143 //"dos registros relacionados a origem/destino de transferência."
	Local cDesc3   := ""
	Local wnrel    := "MNTA693"

	Private aReturn  := {STR0144,1,STR0145, 1, 2, 1, "",1 } //"Zebrado"###"Administracao"
	Private nLastKey := 0
	Private Tamanho  := "M"
	Private limite   := 132
	Private nomeprog := "MNTA693"
	Private Titulo   := STR0146+" " + Alltrim(M->TQ2_CODBEM) //"Inconsistencias Encontradas para a Transferencia do Bem:"

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Envia controle para a funcao SETPRINT                        ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	wnrel:=SetPrint(cString,wnrel,,titulo,cDesc1,cDesc2,cDesc3,.F.,"")
	If nLastKey == 27
		Set Filter To
		Return
	EndIf
	SetDefault(aReturn,cString)
	RptStatus({|lEnd| f550RIT(@lEnd,wnRel,titulo,tamanho)},titulo)

Return Nil

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³f550RIT   ³ Autor ³ Felipe Nathan Welter  ³ Data ³ 18/03/10 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³Chamada do Relat¢rio                                        ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³f550RIMP                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Static Function f550RIT(lEnd,wnRel,titulo,tamanho)

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Define Variaveis                                             ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	cRodaTxt := ""
	nCntImpr := 0
	nAtual   := 0
	contador := 0
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Variaveis para controle do cursor de progressao do relatorio ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	nTotRegs := 0
	nMult    := 1
	nPosAnt  := 4
	nPosAtu  := 4
	nPosCnt  := 0
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Contadores de linha e pagina                                 ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	li := 80
	m_pag := 1
	lEnd := .F.

	CABEC1 := " "
	CABEC2 := " "
	ntipo  := 0

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Verifica se deve comprimir ou nao                            ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	nTipo  := IIF(aReturn[4]==1,15,18)

	dbSelectArea(cTRBGRV)
	dbSetOrder(02)
	dbGoTop()
	SetRegua(LastRec())

	NgSomaLi(58)

	If (cTRBGRV)->TIPO $ '0'
		@li,001 Psay STR0147 //"Os seguintes campos serão gravados em branco:"
		While !Eof() .And. (cTRBGRV)->TIPO $ '0'
			NgSomaLi(58)
			IncProc()
			@li,003 Psay "- "+(cTRBGRV)->CAMPO
			@li,017 Psay "("+AllTrim(NGRETTITULO((cTRBGRV)->CAMPO))+")"
			@li,031 Psay "-> "+(cTRBGRV)->TABELA
			@li,039 Psay "  " + SubStr(FWX2Nome((cTRBGRV)->TABELA),1,30)
			If !Empty((cTRBGRV)->CONTEU)
				cConteudo := AllTrim((cTRBGRV)->CONTEU)
				nLen := Len(cConteudo)
				While nLen > 0
					@li,073 Psay SubStr(cConteudo,1,59)
					cConteudo := SubStr(cConteudo,60,Len(cConteudo))
					nLen -= 59
					If nLen > 0
						NgSomaLi(58)
					EndIf
				EndDo
			EndIf
			dbSelectArea(cTRBGRV)
			dbSkip()
		EndDo
		NgSomaLi(58)
		NgSomaLi(58)
		@li,001 Psay STR0148 //"  Campos serão gravados em branco quando a tabela estrangeira que alimenta o campo em questão não está compartilhada entre as em-  "
		NgSomaLi(58)
		@li,001 Psay STR0149 //"presas que realizarão a transferência, ou quando o conteúdo/código do campo presente na empresa/filial de origem  não corresponde  "
		NgSomaLi(58)
		@li,001 Psay STR0150 //"a um código encontrado na empresa/filial destino."
		NgSomaLi(58)
		@li,001 Psay __PrtThinLine()
		NgSomaLi(58)
		NgSomaLi(58)
	EndIf

	If (cTRBGRV)->TIPO $ '1'
		@li,001 Psay STR0151 //"Alguns registros não serão gravados devido aos seguintes campos:"
		While !Eof() .And. (cTRBGRV)->TIPO $ '1'
			NgSomaLi(58)
			IncProc()
			@li,003 Psay "- "+(cTRBGRV)->CAMPO
			@li,017 Psay "("+AllTrim(NGRETTITULO((cTRBGRV)->CAMPO))+")"
			@li,031 Psay "-> "+(cTRBGRV)->TABELA
			@li,039 Psay "  " + FWX2Nome((cTRBGRV)->TABELA)
			If !Empty((cTRBGRV)->CONTEU)
				cConteudo := AllTrim((cTRBGRV)->CONTEU)
				nLen := Len(cConteudo)
				While nLen > 0
					@li,073 Psay SubStr(cConteudo,1,59)
					cConteudo := SubStr(cConteudo,60,Len(cConteudo))
					nLen -= 59
					If nLen > 0
						NgSomaLi(58)
					EndIf
				EndDo
			EndIf
			dbSelectArea(cTRBGRV)
			dbSkip()
		EndDo
		NgSomaLi(58)
		NgSomaLi(58)
		@li,001 Psay STR0152 //"  Registros não serão gravados quando a tabela de um campo chave não está compartilhada entre as empresas que realizarão a transfe-"
		NgSomaLi(58)
		@li,001 Psay STR0153 //"rência, ou quando o conteúdo / código deste campo na empresa / filial de origem não corresponde a um código encontrado na empresa /"
		NgSomaLi(58)
		@li,001 Psay STR0154 //" filial destino."
		NgSomaLi(58)
		@li,001 Psay __PrtThinLine()
		NgSomaLi(58)
		NgSomaLi(58)
	EndIf

	If (cTRBGRV)->TIPO $ '2'
		@li,001 Psay STR0155//"* Alguns campos necessitam ser informados para que se realize a transferência:"
		While !Eof() .And. (cTRBGRV)->TIPO $ '2'
			NgSomaLi(58)
			IncProc()
			@li,003 Psay "- "+(cTRBGRV)->CAMPO
			@li,017 Psay "("+AllTrim(NGRETTITULO((cTRBGRV)->CAMPO))+")"
			@li,031 Psay "-> "+(cTRBGRV)->TABELA
			@li,039 Psay "  " + FWX2Nome((cTRBGRV)->TABELA)
			If !Empty((cTRBGRV)->CONTEU)
				cConteudo := AllTrim((cTRBGRV)->CONTEU)
				nLen := Len(cConteudo)
				While nLen > 0
					@li,073 Psay SubStr(cConteudo,1,59)
					cConteudo := SubStr(cConteudo,60,Len(cConteudo))
					nLen -= 59
					If nLen > 0
						NgSomaLi(58)
					EndIf
				EndDo
			EndIf
			dbSelectArea(cTRBGRV)
			dbSkip()
		EndDo
		NgSomaLi(58)
		NgSomaLi(58)
		@li,001 Psay STR0156//"  Quando campos obrigatórios/chave essenciais para a transferência não possuem conteúdo, seja porque a tabela estrangeira não está "
		NgSomaLi(58)
		@li,001 Psay STR0157//"compartilhada entre as empresas que realizarão a transferência, ou quando o conteúdo/código deste campo na empresa/filial de origem"
		NgSomaLi(58)
		@li,001 Psay STR0158//"não corresponde a um código encontrado na empresa/filial destino, a transferência não pode ser realizada."
		NgSomaLi(58)
		@li,001 Psay __PrtThinLine()
		NgSomaLi(58)
		NgSomaLi(58)
	EndIf

	If (cTRBGRV)->TIPO $ '3'
		@li,001 Psay STR0159//"* Problemas no dicionário: "
		While !Eof() .And. (cTRBGRV)->TIPO $ '3'
			NgSomaLi(58)
			IncProc()
			@li,003 Psay "- "+(cTRBGRV)->TABELA
			@li,010 Psay " " + AllTrim(SubStr(FWX2Nome((cTRBGRV)->TABELA),1,30))
			If !Empty((cTRBGRV)->CONTEU)
				cConteudo := AllTrim((cTRBGRV)->CONTEU)
				nLen := Len(cConteudo)
				While nLen > 0
					@li,047 Psay SubStr(cConteudo,1,85)
					cConteudo := SubStr(cConteudo,86,Len(cConteudo))
					nLen -= 85
					If nLen > 0
						NgSomaLi(58)
					EndIf
				EndDo
			EndIf
			dbSelectArea(cTRBGRV)
			dbSkip()
		EndDo
		NgSomaLi(58)
		NgSomaLi(58)
		@li,001 Psay STR0160//"  Problemas no dicionário podem impedir o andamento do processo devido à falta de campos, tabelas ou índices necessários para se"
		NgSomaLi(58)
		@li,001 Psay STR0161//"realizar a transferência."
		NgSomaLi(58)
		@li,001 Psay __PrtThinLine()
		NgSomaLi(58)
		NgSomaLi(58)
	EndIf

	If (cTRBGRV)->TIPO $ '4'
		@li,001 Psay STR0162//"* Foram encontradas inconsistências de cadastro:"
		While !Eof() .And. (cTRBGRV)->TIPO $ '4'
			NgSomaLi(58)
			IncProc()
			@li,003 Psay "- "+(cTRBGRV)->TABELA
			@li,010 Psay "-> " + FWX2Nome((cTRBGRV)->TABELA)
			If !Empty((cTRBGRV)->CONTEU)
				cConteudo := AllTrim((cTRBGRV)->CONTEU)
				nLen := Len(cConteudo)
				While nLen > 0
					@li,047 Psay SubStr(cConteudo,1,85)
					cConteudo := SubStr(cConteudo,86,Len(cConteudo))
					nLen -= 85
					If nLen > 0
						NgSomaLi(58)
					EndIf
				EndDo
			EndIf
			dbSelectArea(cTRBGRV)
			dbSkip()
		EndDo
		NgSomaLi(58)
		NgSomaLi(58)
		@li,001 Psay STR0163//"  Validações de cadastros relacionados aos bens que serão transferidos podem indicar pendências ou inconsistências nas informa-"
		NgSomaLi(58)
		@li,001 Psay STR0164//"ções e parametrização."
		NgSomaLi(58)
		@li,001 Psay __PrtThinLine()
		NgSomaLi(58)
		NgSomaLi(58)
	EndIf

	NgSomaLi(58)

	RODA(nCNTIMPR,cRODATXT,TAMANHO)

	Set Filter To
	Set Device To Screen
	If aReturn[5] == 1
		Set Printer To
		dbCommitAll()
		OurSpool(wnrel)
	EndIf

	MS_FLUSH()

Return Nil


/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡ao    ³fGravPrb  ³ Autor ³ Felipe Nathan Welter  ³ Data ³ 15/03/10 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³Grava inconsistencias encontradas na validacao da transfer. ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³1.cTable - Tabela que referencia o problema                 ³±±
±±³          ³2.cField - Campo que referencia o problema                  ³±±
±±³          ³3.cCont  - Observacao/Conteudo referente ao problema        ³±±
±±³          ³4.nTipo  - Tipo de inconsistencia encontrada:               ³±±
±±³          ³           0 -> Grava campo em branco                       ³±±
±±³          ³           1 -> Nao grava o registro, mas transfere         ³±±
±±³          ³           2 -> Necessita informar, obrigatorio             ³±±
±±³          ³           3 -> Problemas no dicionario                     ³±±
±±³          ³           4 -> Inconsistencia de cadastros                 ³±±
±±³          ³    Obs: os tipo 2, 3 e 4 impedem a transferencia           ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Static Function fGravPrb(cTable,cField,cCont,nTipo)
	Local aArea := GetArea()
	Local lGrava := .T.
	Default cTable := ""
	Default cField := ""
	Default cCont := ""
	Default nTipo := -1

	dbSelectArea(cTRBGRV)
	dbSetOrder(02)

	If nTipo == 2 .And. dbSeek('2'+cField+Space(10-Len(cField))+cTable)
		lGrava := .F.
	EndIf

	If nTipo == 0 .And. dbSeek('0'+cField+Space(10-Len(cField))+cTable)
		While !Eof() .And. '0'+cField+Space(10-Len(cField))+cTable == (cTRBGRV)->TIPO+(cTRBGRV)->CAMPO+(cTRBGRV)->TABELA
			If AllTrim(cCont) == AllTrim((cTRBGRV)->CONTEU)
				lGrava := .F.
				Exit
			EndIf
			dbSkip()
		EndDo
	EndIf

	If nTipo == 4 .And. dbSeek('4'+cField+Space(10-Len(cField))+cTable)
		While !Eof() .And. '0'+cField+Space(10-Len(cField))+cTable == (cTRBGRV)->TIPO+(cTRBGRV)->CAMPO+(cTRBGRV)->TABELA
			If AllTrim(cCont) == AllTrim((cTRBGRV)->CONTEU)
				lGrava := .F.
				Exit
			EndIf
			dbSkip()
		EndDo
	EndIf

	If lGrava
		RecLock((cTRBGRV),.T.)
		(cTRBGRV)->TABELA := cTable
		(cTRBGRV)->CAMPO  := cField
		(cTRBGRV)->CONTEU := cCont
		(cTRBGRV)->TIPO   := cValToChar(nTipo)
		(cTRBGRV)->(MsUnLock())
	EndIf

	RestArea(aArea)
Return .T.


//----------------------------------------------------------------------------------------------------------
/*/{Protheus.doc} fChkArquivo
Testa se tabela é compartilhada entre empresas.
@type static

@author Felipe Nathan Welter
@since 15/03/2010

@sample fChkArquivo("TT8")

@param cAlias   , Caracter, Tabela a ser verificada.
@param [cEmpOri], Caracter, Empresa Origem.
@param [cEmpDes], Caracter, Empresa Destino.
@param [cFilOri], Caracter, Filial Origem.
@param [cFilDes], Caracter, Filial Destino.

@return Lógico    , Verifica se tabela é compartilhada.
/*/
//----------------------------------------------------------------------------------------------------------
Static Function fChkArquivo(cAlias, cEmpOri, cEmpDes, cFilOri, cFilDes)

	Local lRet    := .T.

	Default cFilOri := M->TQ2_FILORI
	Default cFilDes := M->TQ2_FILDES
	Default cEmpOri := M->TQ2_EMPORI
	Default cEmpDes := M->TQ2_EMPDES

	If cEmpOri <> cEmpDes
		lRet := RetFullName(cAlias, cEmpOri) == RetFullName(cAlias, cEmpDes)
		lRet := IIf(lRet, (FWModeAccess(cAlias, 3, cEmpOri) == FWModeAccess(cAlias, 3, cEmpDes)), .F.)
	EndIf

	//Se compartilhado, verifica se origem e destino são iguais.
	If xFilial(cAlias, cFilOri) <> xFilial(cAlias, cFilDes)
		lRet := .F.
	EndIf

Return lRet

/*/
	ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
	±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
	±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
	±±³Fun‡ao    ³ fSilSEEK  ³ Autor ³ Felipe Nathan Welter ³ Data ³ 15/03/10 ³±±
	±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
	±±³Descri‡…o ³Testa se registro existe em determinada empresa e filial    ³±±
	±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
	±±³Parametros³1.cAlias - Tabela a ser verificada                          ³±±
	±±³          ³2.cKey   - Chave a se pesquisada                            ³±±
	±±³          ³3.nOrd   - Indice para pesquisa                             ³±±
	±±³          ³4.cFilTroc - Filial para troca                              ³±±
	±±³          ³5.cEmpTroc - Empresa para troca                             ³±±
	±±³          ³6.cEmpRet - Empresa para retorno                            ³±±
	±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
	±±³Retorno   ³lRet = .T./.F. - registro localizado                        ³±±
	±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
	±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
	ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Static Function fSilSEEK(cALIAS,cKEY,nORD,cFilTroc,cEmpTroc,cEmpRet)
	Local lRet,aAreaSe := GetArea(),cEmpInfo,cFilInfo
	Local cFilArq := NGTROCAFILI(cALIAS,cFilTroc,cEmpTroc),lTemFilI := .T.

	If FindFunction("NGCONVINDICE")
		cDesInd := Alltrim(NGSEEKDIC("SIX",cALIAS+NGCONVINDICE(nORD,"N"),1,'CHAVE'))
		nPosTra := At("_",cDesInd)
		If nPosTra > 0
			nPosMai := At("+",cDesInd)
			cFilInc := If(nPosMai > 0,SubStr(cDesInd,nPosTra+1,(nPosMai-1)-nPosTra),;
				SubStr(cDesInd,nPosTra+1,Len(cDesInd)-nPosTra))
			lTemFilI := 'FILIAL' $ cFilInc
		EndIf
	EndIf

	If cEmpTroc <> Nil
		dbSelectArea(cALIAS)
		cEmpInfo := If(cEmpRet <> NIL,cEmpRet,SM0->M0_CODIGO)
		cFilInfo := cFilAnt
		NGPrepTBL({{cALIAS,nORD}},cEmpTroc,cFilTroc)
	EndIf

	dbSelectArea(cALIAS)
	dbSetOrder(nORD)
	lRet := dbSeek(If(lTemFilI,cFilArq+cKey,cKey))

	If cEmpTroc <> Nil
		NGPrepTBL({{cALIAS,nORD}},cEmpInfo,cFilInfo)
	EndIf

	RestArea(aAreaSe)
Return lRet

//----------------------------------------------------------------------------------------------------------
/*/{Protheus.doc} MNT693WF
Envia WorkFlow para os responsáveis pela Nota Fiscal

@type Static Function
@author Vitor Emanuel Batista
@since 09/09/2010

@param nType, Numérico, Tipo de operação:	- 3: Inclusão
											- 4: Alteração
											- Outro: Confirmação
/*/
//----------------------------------------------------------------------------------------------------------
Static Function MNT693WF( nType )

	Local cTitulo    := ''
	Local cSubTitulo := ''
	Local cObserv    := ''
	Local cBody      := ''
	Local aCamposEst := {}
	Local aProcess   := {}

	If nType == 4

		cTitulo := STR0166 //'Solicitação para Transferência'
		cEmail  := TQ2->TQ2_EMAIL2

	ElseIf nType == 3

		cTitulo    := STR0165 //'Solicitação de Nota Fiscal para Transferência'
		cEmail     := TQ2->TQ2_EMAIL1
		cSubTitulo := STR0167 //'Favor emitir e nos enviar por e-mail cópia da nota fiscal conforme pedido abaixo:'

	Else
		Return
	EndIf

	dbSelectArea( 'ST9' )
	dbSetOrder( 1 )
	dbSeek( xFilial( 'ST9', TQ2->TQ2_FILORI ) + TQ2->TQ2_CODBEM )

	// Verifica se existe o arquivo de WorkFlow para utilizar a função de WorkFlow.
	If FindFunction( 'NGUseTWF' ) .And. NGUseTWF( 'MNTW693' )[1]

		aCamposEst := { { 'strTitulo'		 , cTitulo                                                   },;
			{ 'strSubTitulo'     , cSubTitulo                                                },;
			{ 'strOrigem'        , STR0193                                                   },; // Origem
		{ 't1l1.strNumME'    , STR0194                                                   },; // Num. ME.
		{ 't1l2.strEmpOrig'  , STR0195                                                   },; // Empresa
		{ 't1l3.strFilOrig'  , STR0196                                                   },; // Filial
		{ 't1l4.strCodBem'   , STR0197                                                   },; // Equipamento
		{ 't1l5.strNumSer'   , STR0198                                                   },; // N° Série
		{ 't1l6.strDataTR'   , STR0199                                                   },; // Data
		{ 't1l7.strHoraTR'   , STR0200                                                   },; // Hora
		{ 't2l1.strNUMME'	 , TQ2->TQ2_NUMME                                            },;
			{ 't2l2.strEMPORI'	 , TQ2->TQ2_EMPORI + ' - ' + FWGrpName( TQ2->TQ2_EMPORI )    },; // M0_NOME
		{ 't2l3.strFILORI'	 , TQ2->TQ2_FILORI + ' - ' + FWFilialName( TQ2->TQ2_EMPORI,;
			TQ2->TQ2_FILORI ) },; // M0_FILIAL
		{ 't2l4.strCODBEM'	 , AllTrim( TQ2->TQ2_CODBEM ) + ' - ' + ST9->T9_NOME         },;
			{ 't2l5.strSERIE'	 , ST9->T9_SERIE                                             },;
			{ 't2l6.strDATATR'	 , dToC( TQ2->TQ2_DATATR )                                   },;
			{ 't2l7.strHORATR'	 , TQ2->TQ2_HORATR                                           },;
			{ 'strDestino'       , STR0201                                                   },; // Destino
		{ 't3l1.strEmpDest'  , STR0195                                                   },; // Empresa
		{ 't3l2.strFilDest'  , STR0196                                                   },; // Filial
		{ 't3l3.strObserv'   , STR0202                                                   },; // Observação
		{ 't4l1.strEMPDES'	 , TQ2->TQ2_EMPDES + ' - ' + FWGrpName( TQ2->TQ2_EMPDES )    },; // M0_NOME
		{ 't4l2.strFILDES'	 , TQ2->TQ2_FILDES + ' - ' + FWFilialName( TQ2->TQ2_EMPDES,;
			TQ2->TQ2_FILDES ) },; // M0_FILIAL
		{ 't4l3.strMOTTRA'	 , MemoLine( TQ2->TQ2_MOTTRA )                               };
			}

		// Função para criação do objeto da classe TWFProcess responsavel pelo envio de workflows.
		aProcess := NGBuildTWF( cEmail, 'MNTW693', DToC( dDataBase ) + ' - ' + cTitulo, 'MNTA693', aCamposEst )

		// Consiste se foi possivel a inicialização do objeto TWFProcess.
		If aProcess[1]

			// Função que realiza o envio do workflow conforme definições do objeto passado por parãmetro.
			NGSendTWF( aProcess[2] )

		EndIf

	Else

		cBody := '<html>'
		cBody += '<head>'
		cBody += '<title>'+cTitulo+'</title>'
		cBody += '</head>'

		cBody += '<body bgcolor="#FFFFFF">'

		cBody += '<p><b><font face="Arial">'+cTitulo+'</font></b></p>'
		cBody += '</u>'

		cBody += '<table border=0 WIDTH=655 cellpadding="1">'

		cBody += '<tr>'
		cBody += '    <td bgcolor="#FFFFFF" align="left" width="157"><font face="Arial" size="2">'+cSubTitulo+'</font></td>'
		cBody += '</tr>'
		cBody += '</table>'

		cBody += '<br>'
		cBody += '<b><font face="Arial" size="2">Origem</font></b>'
		cBody += '<br><br>'
		cBody += '<table border=0 WIDTH=655 cellpadding="1">'

		cBody += '<tr>'
		cBody += '   <td bgcolor="#EEEEEE" align="left" width="157"><b><font face="Arial" size="2">Num. ME.</font></b></td>'
		cBody += '   <td bgcolor="#EEEEEE" align="left" width="420"><font face="Arial" size="1">'+TQ2->TQ2_NUMME+'</font></td>'
		cBody += '</tr>'
		cBody += '<tr>'
		cBody += '   <td bgcolor="#EEEEEE" align="left" width="157"><b><font face="Arial" size="2">Empresa</font></b></td>'
		cBody += '   <td bgcolor="#EEEEEE" align="left" width="420"><font face="Arial" size="1">'+ TQ2->TQ2_EMPORI + ' - ' + FWGrpName( TQ2->TQ2_EMPORI ) +'</font></td>'
		cBody += '</tr>'
		cBody += '<tr>'
		cBody += '   <td bgcolor="#EEEEEE" align="left" width="157"><b><font face="Arial" size="2">Filial</font></b></td>'
		cBody += '   <td bgcolor="#EEEEEE" align="left" width="420"><font face="Arial" size="1">'+TQ2->TQ2_FILORI + ' - ' + FWFilialName( TQ2->TQ2_EMPORI,TQ2->TQ2_FILORI ) + '</font></td>'
		cBody += '</tr>'
		cBody += '<tr>'
		cBody += '   <td bgcolor="#EEEEEE" align="left" width="157"><b><font face="Arial" size="2">Equipamento</font></b></td>'
		cBody += '   <td bgcolor="#EEEEEE" align="left" width="420"><font face="Arial" size="1">'+AllTrim(TQ2->TQ2_CODBEM) + " - " + ST9->T9_NOME+'</font></td>'
		cBody += '</tr>'
		cBody += '<tr>'
		cBody += '   <td bgcolor="#EEEEEE" align="left" width="157"><b><font face="Arial" size="2">Nº Série</font></b></td>'
		cBody += '   <td bgcolor="#EEEEEE" align="left" width="420"><font face="Arial" size="1">'+ST9->T9_SERIE+'</font></td>'
		cBody += '</tr>'
		cBody += '<tr>'
		cBody += '   <td bgcolor="#EEEEEE" align="left" width="157"><b><font face="Arial" size="2">Data</font></b></td>'
		cBody += '   <td bgcolor="#EEEEEE" align="left" width="420"><font face="Arial" size="1">'+DTOC(TQ2->TQ2_DATATR)+'</font></td>'
		cBody += '</tr>'
		cBody += '<tr>'
		cBody += '   <td bgcolor="#EEEEEE" align="left" width="157"><b><font face="Arial" size="2">Hora</font></b></td>'
		cBody += '   <td bgcolor="#EEEEEE" align="left" width="420"><font face="Arial" size="1">'+TQ2->TQ2_HORATR+'</font></td>'
		cBody += '</tr>'
		cBody += '</table>'

		cBody += '<br>'
		cBody += '<b><font face="Arial" size="2">Destino</font></b>'
		cBody += '<br><br>'
		cBody += '<table border=0 WIDTH=655 cellpadding="1">'

		cBody += '<tr>'
		cBody += '   <td bgcolor="#EEEEEE" align="left" width="157"><b><font face="Arial" size="2">Empresa</font></b></td>'
		cBody += '   <td bgcolor="#EEEEEE" align="left" width="420"><font face="Arial" size="1">'+ TQ2->TQ2_EMPDES + ' - ' + FWGrpName( TQ2->TQ2_EMPDES ) +'</font></td>'
		cBody += '<tr>'
		cBody += '   <td bgcolor="#EEEEEE" align="left" width="157"><b><font face="Arial" size="2">Filial</font></b></td>'
		cBody += '   <td bgcolor="#EEEEEE" align="left" width="420"><font face="Arial" size="1">'+ TQ2->TQ2_FILDES + ' - ' + FWFilialName( TQ2->TQ2_EMPDES, TQ2->TQ2_FILDES ) + '</font></td>'
		cBody += '</tr>'

		//Campo Observação
		cObserv := TQ2->TQ2_MOTTRA
		cObserv := MemoLine(cObserv)

		cBody += '<tr>'
		cBody += '   <td bgcolor="#EEEEEE" align="left" width="157"><b><font face="Arial" size="2">Observação</font></b></td>'
		cBody += '   <td bgcolor="#EEEEEE" align="left" width="420"><font face="Arial" size="1">'+cObserv+'</font></td>'
		cBody += '</tr>'
		cBody += '</table>'
		cBody += '</body>'
		cBody += '</html>'

		NGSendMail( , Alltrim(cEmail)+Chr(59), , , OemToAnsi(dtoc(MsDate())+" - "+cTitulo), "", cBody)

	EndIf

Return

/*/
	ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
	±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
	±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
	±±³ Funcao   ³ MNT693WH  ³ Autor ³ Marcos Wagner Junior  ³ Data ³09/09/2010³±±
	±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
	±±³ Descri‡…o³ When                                                       ³±±
	±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
	±±³ Uso      ³ MNTA693                                                   ³±±
	±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
	±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
	ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function MNT693WH()

	Local aOldArea	:= GetArea()

	If ReadVar() == 'M->TQ2_CCUSTO'
		If !Empty(M->TQ2_EMPDES) .And. !Empty(M->TQ2_FILDES)
			NgPrepTbl({{"CTT"},{"SHB"}},M->TQ2_EMPDES,M->TQ2_FILDES)
		EndIf
	Else
		If !Empty(M->TQ2_EMPORI) .And. !Empty(M->TQ2_FILORI)
			NgPrepTbl({{"CTT"},{"SHB"}},M->TQ2_EMPORI,M->TQ2_FILORI)
		EndIf
	EndIf

	RestArea(aOldArea)

Return .F.
//----------------------------------------------------------------------
	/*/{Protheus.doc} f015TRSATF()
	Faz a transferencia do Ativo Fixo

	@author Júlio Bertolucci
	@since 29/10/2013
	@version MP11
	@return
	/*/
//---------------------------------------------------------------------
Static Function f015TRSATF()

	Local aDadosAuto 	:= {}		// Array com os dados a serem enviados pela MsExecAuto() para gravacao automatica
	Local aOldArea 		:= GetArea()
	Local lRet			:= .T.
	Local _nRecnoSN1
	Local cCContab 		:= ""
	Local cCCorrec 		:= ""
	Local cCDeprec 		:= ""
	Local cCCDepr	 	:= ""
	Local cCCDesp  		:= ""
	Local cFilOld := cFilAnt
	Local cImobST9 := ""

	Private lMsHelpAuto := .T.	// Determina se as mensagens de help devem ser direcionadas para o arq. de log
	Private lMsErroAuto := .F.	// Determina se houve alguma inconsistencia na execucao da rotina em relacao aos

	//Validação para não realizar transferencia de Ativo Fixo quando a transferencia for entre Empresas
	If M->TQ2_EMPORI <> M->TQ2_EMPDES
		cFilAnt := cFilOld
		RestArea(aOldArea)
		Return lRet
	EndIf

	dbSelectArea("ST9")
	dbSetOrder(01)
	If dbSeek(xFilial("ST9",M->TQ2_FILORI) + M->TQ2_CODBEM)
		cImobST9 := ST9->T9_CODIMOB
	EndIf

	If !Empty(cImobST9)

		dbSelectArea("SN1")
		dbSetOrder(01)
		dbSeek(xFilial("SN1",M->TQ2_FILORI) + cImobST9)

		dbSelectArea("SN3")
		dbSetOrder(01)
		dbSeek(xFilial("SN3",M->TQ2_FILORI)+SN1->N1_CBASE+SN1->N1_ITEM)

		////////////////////////////////////////////////////////////////////////////
		//Abre pergunta de contas contábeis e alimenta as variáveis para execauto//
		////////////////////////////////////////////////////////////////////////////

		If Pergunte("MNTA693", .T. , "Informe as contas contábeis de destino." )
			cCContab 	:= If (!Empty(AllTrim(MV_PAR01)), MV_PAR01, SN3->N3_CCONTAB)
			cCCorrec 	:= If (!Empty(AllTrim(MV_PAR02)), MV_PAR02, SN3->N3_CCORREC)
			cCDeprec 	:= If (!Empty(AllTrim(MV_PAR03)), MV_PAR03, SN3->N3_CDEPREC)
			cCCDepr	 	:= If (!Empty(AllTrim(MV_PAR04)), MV_PAR04, SN3->N3_CCDEPR)
			cCCDesp  	:= If (!Empty(AllTrim(MV_PAR05)), MV_PAR05, SN3->N3_CDESP)
		Else
			lRet := .F.
			Return lRet
		EndIf

		////////
		//Fim //
		////////

		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ O exemplo abaixo foi considerado passando somente dados de conta contabil e centro de custo, caso ³
		//³ necessario passar os campos referentes a itens contabeis e classes de valores.                    ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		aDadosAuto:= { {'N1_FILIAL'  , M->TQ2_FILDES	, Nil},;
			{'N3_CBASE'		  , SN1->N1_CBASE	, Nil},;	// Codigo base do ativo //"0000000002"
		{'N3_ITEM'    , SN1->N1_ITEM 	, Nil},;	// Item sequencial do codigo bas do ativo //"0001"
		{'N4_DATA' 	  , dDATABASE		, Nil},;	// Data de aquisicao do ativo
		{'N4_HORA' 	  , M->TQ2_HORATR	, Nil},;	// Hoara da transferencia do ativo
		{'N3_CCUSTO'  , M->TQ2_CCUSTO	, Nil},;	// Centro de Custo de Despesa
		{'N3_CCONTAB' , cCContab		, Nil},;	// Conta Contabil
		{'N3_CCORREC' , cCCorrec		, Nil},;	// Conta de Correcao do Bem
		{'N3_CDEPREC' , cCDeprec		, Nil},;	// Conta Despesa Depreciacao
		{'N3_CCDEPR'  , cCCDepr			, Nil},;	// Conta Depreciacao Acumulada
		{'N3_CDESP'   , cCCDesp			, Nil},;	// Conta Correcao Depreciacao
		{'N3_CUSTBEM' , M->TQ2_CCUSTO	, Nil},;	// Centro de Custo da Conta do Bem
		{'N3_CCCORR'  , M->TQ2_CCUSTO	, Nil},;	// Centro Custo Correcao Monetaria
		{'N3_CCDESP'  , M->TQ2_CCUSTO	, Nil},;	// Centro Custo Despesa Depreciacao
		{'N3_CCCDEP'  , M->TQ2_CCUSTO	, Nil},;	// Centro Custo Despesa Acumulada
		{'N3_CCCDES'  , M->TQ2_CCUSTO	, Nil},;	// Centro Custo Correcao Depreciacao
		{'N1_GRUPO'   , SN1->N1_GRUPO	, Nil},;	// Codigo do Grupo do Bem
		{'N1_LOCAL'   , SN1->N1_LOCAL	, Nil},;	// Localizacao do Bem
		{'N1_NFISCAL' , M->TQ2_NOTFIS	, Nil},;	// Numero da NF
		{'N1_NSERIE'  , M->TQ2_SERIE 	, Nil},;	// Serie da NF
		{'N3_TIPO'    , "01"		 	, Nil}}	    // Tipo

		If !Empty(SN1->N1_TAXAPAD)
			AAdd( aDadosAuto, {'N1_TAXAPAD' ,SN1->N1_TAXAPAD,Nil } )// Codigo da Taxa Padrao
		EndIf
		cFilAnt := TQ2->TQ2_FILORI

		MSExecAuto({|x, y, z| AtfA060(x, y, z)},aDadosAuto, 4)

		If lMsErroAuto
			MostraErro()
			RestArea(aOldArea)
			lRet := .F.
		EndIf
	EndIf
	cFilAnt := cFilOld
	RestArea(aOldArea)

Return lRet

	//----------------------------------------------------------------------
	/*/{Protheus.doc} NGCODIMOB()
	Verifica o codigo e item atual ativo fixo do bem

	@param cFilSN1 - Filial destino
	@param cBemSN1 - bem a ser pesquisado

	@return cImobSN1 - Código do imobilizado + item

	@author Maria Elisandra de Paula
	@since 11/12/2014
	/*/
//---------------------------------------------------------------------

Static Function NGCODIMOB(cFilSN1,cBemSN1)

	Local aOldArea := GetArea()
	Local cImobSN1 := ""
	Local cAliasQry := GetNextAlias()
	Local cQuery := " "

	// Query para retornar o campo N1_CBASE e N1_ITEM da filial de destino para atualizar o campo T9_CODIMOB da filial de destino
	cQuery += " SELECT N1_CBASE,N1_ITEM FROM " + RetSQLName("SN1") + " SN1 "
	cQuery += " WHERE D_E_L_E_T_ <> '*' AND N1_CODBEM = '" + cBemSN1 + "'"
	cQuery += " AND N1_FILIAL  = '" + cFilSN1 + "' AND N1_STATUS = '1' "

	cQuery := ChangeQuery(cQuery)
	dbUseArea( .T., "TOPCONN", TCGenQry(,,cQuery), cAliasQry, .F., .T.)

	dbSelectArea(cAliasQry)
	If !Eof()
		cImobSN1 := (cAliasQry)->N1_CBASE + (cAliasQry)->N1_ITEM
	EndIf
	(cAliasQry)->(dbCloseArea())

	RestArea(aOldArea)
Return cImobSN1

//---------------------------------------------------------------------
/*/{Protheus.doc} fValParam
Verifica se o conteúdo do parâmetro MV_NGBEMTR é válido.

@return lRet Indica se o parâmetro está preenchido.

@author Pedro Henrique Soares de Souza
@since 04/09/2014
/*/
//---------------------------------------------------------------------
Static Function fValParam()

	Local lRet	:= !Empty( _cBemTran_ )

	If !lRet
		Help( '', 1, STR0011,, STR0085 + STR0086 + STR0027, 2, 0 )
	EndIf

	//Atenção
	//"Parâmetro MV_NGBEMTR (para status 'Transferido') está vazio. Para realizar "
	//"a transferência é necessário que este parâmetro esteja associado a um status"
	//"cadastrado, com a categoria dos componentes da estrutura ou em branco."

Return lRet

/*/
	ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
	±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
	±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
	±±³ Funcao   ³MNT693LEG³ Autor ³Vitor Emanuel Batista  ³ Data ³03/09/2010³±±
	±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
	±±³ Descri‡…o³ Cria uma janela contendo a legenda da mBrowse              ³±±
	±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
	±±³ Uso      ³ MNTA693                                                   ³±±
	±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
	±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
	ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function MNT693LEG()

	BrwLegenda(cCadastro,'Legenda',{{"BR_VERMELHO",'Pendente Nota Fiscal'},;
		{"BR_AMARELO",'Pendente Confirmação'},;
		{"BR_VERDE",'Confirmado'}})
Return

//---------------------------------------------------------------------
/*/{Protheus.doc} fStructTRB
Cria TRB
@author eduardo.izola
@since 16/02/2017
@version undefined
@param cAlias, characters, Alias Tabela
@param aFields, array, Array de campos
@param aIndex, array, Indice TRB
@param AliasTab, characters, Tabela para dbUseArea
@type function
/*/
//---------------------------------------------------------------------
Static Function fStructTRB(cAlias,aFields,aIndex,AliasTab)

	Local i

	If !Empty(AliasTab)
		dbSelectArea(AliasTab)
		aFields := dbStruct()
	EndIf

	oTempTable := FWTemporaryTable():New( cAlias , aFields )
	For i := 1 To Len(aIndex)
		oTempTable:AddIndex("ind"+cValToChar(i), aIndex[i] )
	Next i
	oTempTable:Create()

Return oTempTable

//---------------------------------------------------------------------
/*/{Protheus.doc} MNT693CONT
Valida primeiro e segundo contador
@author tainã.cardoso
@since 28/06/2018

@param nCont, numeric, 1 = Primeiro Contador 2 = Segundo contador

@type function
/*/
//---------------------------------------------------------------------
Function MNT693CONT(nCont)

	Local lRet := .T.
	Default nCont := 0

	If Positivo(M->TQ2_POSCON) .And. Positivo(M->TQ2_POSCO2)
		If nCont == 1 .And. TIPOACOM
			//Valida limite do contador
			If CHKPOSLIM(M->TQ2_CODBEM, M->TQ2_POSCON, 1)
				//Valida histórico do contador
				If !NGCHKHISTO(M->TQ2_CODBEM,M->TQ2_DATATR,M->TQ2_POSCON,M->TQ2_HORATR,1,,.T.,M->TQ2_FILORI)
					lRet := .F.
				EndIf
				//Valida variação dia
				If lRet .And. !NGVALIVARD(M->TQ2_CODBEM,M->TQ2_POSCON,M->TQ2_DATATR,M->TQ2_HORATR,1,.T.,,M->TQ2_FILORI)
					lRet := .F.
				EndIf
			Else
				lRet := .F.
			EndIf
		EndIf

		//Contador 2
		If nCont == 2 .And. TIPOACOM2
			//Valida limite do contador
			If lRet .And. CHKPOSLIM(M->TQ2_CODBEM, M->TQ2_POSCO2, 2)
				//Valida histórico do contador
				If lRet .And. !NGCHKHISTO(M->TQ2_CODBEM,M->TQ2_DATATR,M->TQ2_POSCO2,M->TQ2_HORATR,2,,.T.,M->TQ2_FILORI)
					lRet := .F.
				EndIf
				//Valida variação dia
				If lRet .And. !NGVALIVARD(M->TQ2_CODBEM,M->TQ2_POSCO2,M->TQ2_DATATR,M->TQ2_HORATR,2,.T.,,M->TQ2_FILORI)
					lRet := .F.
				EndIf
			Else
				lRet := .F.
			EndIf
		EndIf
	Else
		lRet := .F.
	EndIf

Return lRet
