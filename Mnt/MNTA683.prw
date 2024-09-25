#Include 'MNTA683.ch'
#Include 'Protheus.CH'
#Include 'FWMVCDEF.CH'


Static _nSizeFil  := NGMTamFil()
Static _aNgEmpSM0 := {}

//---------------------------------------------------------------------
/*/{Protheus.doc} MNTA683()
Custo de Locação do Equipamento

@author Pedro Henrique Soares de Souza
@since 03/10/2014
/*/
//---------------------------------------------------------------------
Function MNTA683()

	Local aNGBEGINPRM := NGBEGINPRM()
	Local oBrowse

	If !MntCheckCC("MNTA683") .Or. !fValParam()
		Return .F.
	EndIf

	oBrowse := FWMBrowse():New()

		oBrowse:SetChgAll(.F.)				// Não exibe tela de seleção de filial
		oBrowse:SetAlias( "TVL" )			// Alias da tabela utilizada
		oBrowse:SetMenuDef( "MNTA683" )		// Nome do fonte onde está a função MenuDef
		oBrowse:SetDescription( STR0001 )	// Descrição do browse
		oBrowse:SetFilterDefault( "TVL->TVL_FILIAL == xFilial('TVL')" )

		oBrowse:Activate()

	NGRETURNPRM(aNGBEGINPRM)

Return .T.

//---------------------------------------------------------------------
/*/{Protheus.doc} MenuDef
Opções de menu

@return aRotina - Estrutura
    [n,1] Nome a aparecer no cabecalho
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
@since 02/08/2014
/*/
//---------------------------------------------------------------------
Static Function MenuDef()

	Local aRotina := {}

	ADD OPTION aRotina TITLE STR0025 ACTION 'PesqBrw'           OPERATION 1  ACCESS 0 // 'Pesquisar'
	ADD OPTION aRotina TITLE STR0026 ACTION 'VIEWDEF.MNTA683'   OPERATION 2  ACCESS 0 // 'Visualizar'
	ADD OPTION aRotina TITLE STR0027 ACTION 'MNT683GE()'        OPERATION 3  ACCESS 0 // 'Calcular'
	ADD OPTION aRotina TITLE STR0028 ACTION 'VIEWDEF.MNTA683'   OPERATION 4  ACCESS 0 // 'Alterar'
	ADD OPTION aRotina TITLE STR0029 ACTION 'MNT683PA()'        OPERATION 4  ACCESS 0 // 'Filtro'
	ADD OPTION aRotina TITLE STR0051 ACTION 'VIEWDEF.MNTA683'   OPERATION 8  ACCESS 0 // 'Imprimir'

	//P. Entrada para incluir opções na Rotina
	If ExistBlock("MNTA6832")
		aRotina:= ExecBlock("MNTA6832", .F., .F., { aRotina })
	EndIf

Return aRotina

//---------------------------------------------------------------------
/*/{Protheus.doc} ModelDef
Regras de modelagem da gravação

@author Pedro Henrique Soares de Souza
@since 03/10/2014
/*/
//---------------------------------------------------------------------
Static Function ModelDef()

	Local oModel, oStructTVL := FWFormStruct( 1, "TVL" )

    // Cria o objeto do Modelo de Dados
	oModel := MPFormModel():New( "MNTA683", {|oModel| ValidEntry(oModel)}, {|oModel| ValidInfo(oModel)}, {|oModel| CommitInfo(oModel)}, /*bCancel*/ )

    // Adiciona ao modelo uma estrutura de formulário de edição por campo
	oModel:AddFields( "MNTA683_TVL", Nil, oStructTVL,/*bPre*/,/*bPost*/,/*bLoad*/)

	oModel:SetDescription( STR0001 ) //"Custo de Locação do Equipamento"

Return oModel

//---------------------------------------------------------------------
/*/{Protheus.doc} ViewDef
Regras de Interface com o Usuário

@author Pedro Henrique Soares de Souza
@since 03/10/2014
/*/
//---------------------------------------------------------------------
Static Function ViewDef()

	Local oModel := FWLoadModel( "MNTA683" )
	Local oView  := FWFormView():New()

    // Objeto do model a se associar a view.
	oView:SetModel(oModel)

    //Adiciona no nosso View um controle do tipo FormFields(antiga enchoice)
	oView:AddField( "MNTA683_TVL", FWFormStruct( 2, "TVL" ), /*cLinkID*/ )

	//Bloco de pré validação para abertura da tela de alteração.
	oView:SetViewCanActivate({|oModel| ValidEntry(oModel)})

    // Criar um "box" horizontal para receber algum elemento da view
	oView:CreateHorizontalBox( "MASTER", 100,/*cIDOwner*/,/*lFixPixel*/,/*cIDFolder*/,/*cIDSheet*/ )

    // Associa um View a um box
	oView:SetOwnerView( "MNTA683_TVL", "MASTER" )

	//Inclusão de itens nas Ações Relacionadas de acordo com O NGRightClick
	NGMVCUserBtn(oView)

Return oView

//---------------------------------------------------------------------
/*/{Protheus.doc} ValidEntry
Valida acesso à rotina de acordo com parâmetro MV_NGDTINC (Data de
integração contábil. Limitará a alteração dos registros. Deverá ter a
máscara MM/AAAA. Onde MM indicara o mês e AAAA o ano.

@author Pedro Henrique Soares de Souza
@since 09/10/2014
/*/
//---------------------------------------------------------------------
Static Function ValidEntry( oModel )

	Local lRet			:= .T.
	Local cDataInc	:= AllTrim(GetNewPar('MV_NGDTINC'))

	If oModel:GetOperation() == MODEL_OPERATION_UPDATE
		If !Empty(cDataInc) .And. SubStr(cDataInc, 4, 4) + SubStr(cDataInc, 1, 2) >= AllTrim( TVL->TVL_ANOREF + TVL->TVL_MESREF )
			Help(1, " ", "NGATENCAO",, STR0023, 5, 0)
			lRet := .F.
		EndIf
	EndIf
Return lRet

//---------------------------------------------------------------------
/*/{Protheus.doc} ValidInfo
Validação ao confirmar tela

@return lRet Indica se os campos foram ou não preenchidos corretamente

@author Pedro Henrique Soares de Souza
@since 06/08/2014
/*/
//---------------------------------------------------------------------
Static Function ValidInfo(oModel)

	Local lRet		:= .T.
	Local aArea	:= GetArea()

	// Verifica se o Ind. foi alterado e obriga a digitacao da OB
	If (( FWFldGet('TVL_INDCAL') != TVL->TVL_INDCAL .Or. FwFldGet('TVL_VALFAT') != TVL->TVL_VALFAT ) .And.;
			Empty( FwFldGet('TVL_MOTIVO')) )

		ShowHelpDlg( "TVL_MOTIVO", { "O campo " + AllTrim( NGRETTITULO('TVL_MOTIVO') ) + " está vazio." }, 5,;
							{"Preencha o campo antes de prosseguir com a alteração!"}, 5)
		lRet := .F.
	ElseIf (( FwFldGet('TVL_INDCAL') != TVL->TVL_INDCAL .Or. FwFldGet('TVL_VALFAT') != TVL->TVL_VALFAT ) .And.;
				!Empty( FwFldGet('TVL_MOTIVO') ) )

		If FwFldGet('TVL_MOTIVO') == TVL->TVL_MOTIVO
			ShowHelpDlg( "TVL_MOTIVO", { "O campo " + AllTrim( NGRETTITULO('TVL_MOTIVO') ) + " não foi alterado." }, 5,;
							{"Altere o campo antes de prosseguir com a alteração!"}, 5)
			lRet := .F.
		EndIf
	EndIf

	RestArea( aArea )

Return lRet

//---------------------------------------------------------------------
/*/{Protheus.doc} CommitInfo
Validação ao confirmar tela

@author Pedro Henrique Soares de Souza
@since 06/08/2014
/*/
//---------------------------------------------------------------------
Static Function CommitInfo(oModel)

	Local aArea	:= GetArea()
	Local cCodBem	:= Space( TamSX3("T9_CODBEM")[1] )

	//---------------------------------------------------------------------------
	// Atualização TV8 - Histórico Alteração Aluguel
	//---------------------------------------------------------------------------
	// Caso os campos TVL_INDCAL (Indicador de cálculo custo) ou TVL_VALFAT
	// (Valor faturado) e o campo TVL_MOTIVO (Motivo) forem alterados, atualiza
	// TV8 (Histórico Alteração Aluguel).
	//---------------------------------------------------------------------------
	If ( FwFldGet('TVL_INDCAL') != TVL->TVL_INDCAL .Or. FwFldGet('TVL_VALFAT') != TVL->TVL_VALFAT ) .And.;
			( !Empty( FwFldGet('TVL_MOTIVO') )  .And. FwFldGet('TVL_MOTIVO') != TVL->TVL_MOTIVO )

		If oModel:GetOperation() == MODEL_OPERATION_UPDATE .Or.;
				oModel:GetOperation() == MODEL_OPERATION_INSERT

			cCodBem := TVL->TVL_CODBEM

			dbSelectArea("TV8")
			dbSetOrder(01)
			If !dbSeek(xFilial("TV8") + cCodBem + DToS(dDataBase) + Time())

				RecLock("TV8", .T.)

				TV8->TV8_FILIAL := xFilial("TV8")
				TV8->TV8_CODBEM := cCodBem
				TV8->TV8_DATALT := dDatabase
				TV8->TV8_HORALT := Time()
				TV8->TV8_ROTINA := FunName()
			Else
				RecLock("TV8", .F.)
			EndIf

			TV8->TV8_USUARI := cUserName
			TV8->TV8_MOTIVO := TVL->TVL_MOTIVO

			TV8->( MsUnLock() )

		EndIf
	EndIf

	FwFormCommit(oModel)

	RestArea( aArea )

Return .T.

//---------------------------------------------------------------------
/*/{Protheus.doc} MNT683GE
Custo de Locacao do Equipamento

@author Marcos Wagner Junior
@since 02/06/2010
/*/
//---------------------------------------------------------------------
Function MNT683GE()

	//--------------------------------------------------------------
	//1 = Sintetico ; 2 = Analítico
	//--------------------------------------------------------------
	Local lCalcAnlt	:= ( GetNewPar("MV_NGCCCAL", "") <> "1" )

	Local cPergFil	:= "MNTA683"
	Local cPergCalc	:= "MNTA683GE"

	If lCalcAnlt
		If Pergunte(cPergFil, .T.)
			If MNT683VLMA(.T.)
				Processa( {|lEnd| GravaDados()}, STR0019, STR0020 ) //"Aguarde..."###"Processando Registros..."
			EndIf
		EndIf
	Else
		If Pergunte(cPergCalc, .T.)
			If MNT683VLMA(.T.)
				Processa( {|lEnd| GravaDados()}, STR0019, STR0020 ) //"Aguarde..."###"Processando Registros..."
			EndIf
		EndIf
	EndIF

Return Nil

//---------------------------------------------------------------------
/*/{Protheus.doc} MNT683VLMA
Valida o parametro "Mes/Ano"

@author Marcos Wagner Junior
@since 02/06/2010
/*/
//---------------------------------------------------------------------
Function MNT683VLMA(lRecalculo)

	Local lRetorno	:= .T.
	Local lFoundTVL	:= .F.
	Local cDataInc	:= AllTrim(GetNewPar('MV_NGDTINC'))
	Local cQryTVL, cQuery

	fVldMesAno(MV_PAR09,1)

	If Len( Alltrim(MV_PAR09) ) < 7 .Or. Val( SubStr(MV_PAR09, 1, 2) ) > 12
		ShowHelpDlg( "MÊS/ANO INVÁLIDO", { "O Mês/Ano informado não é válido." }, 5,;
							{"Informe um Mês/Ano válido!"}, 5)
		lRetorno := .F.
	ElseIf !Empty(cDataInc) .And. SubStr(cDataInc, 4, 4) + SubStr(cDataInc, 1, 2) >= AllTrim(SubStr(MV_PAR09, 4, 7) + SubStr(MV_PAR09, 1, 2))
		Help(1, " ", "NGATENCAO",, STR0023, 5, 0)
		lRetorno := .F.
	Else
		cQryTVL := GetNextAlias()

		cQuery := " SELECT TVL.TVL_CODBEM "
		cQuery += " FROM " + RetSqlName("TVL") + " TVL"
		cQuery += " WHERE TVL.D_E_L_E_T_ <> '*'"
		cQuery += "   AND TVL.TVL_ANOREF = '" + SubStr(MV_PAR09, 4, 7) + "'"
		cQuery += "   AND TVL.TVL_MESREF = '" + SubStr(MV_PAR09, 1, 2) + "'"
		cQuery += "   AND TVL.TVL_CODBEM >= '" + MV_PAR07 + "'"
		cQuery += "   AND TVL.TVL_CODBEM <= '" + MV_PAR08 + "'"

		cQuery := ChangeQuery(cQuery)

		dbUseArea( .T., "TOPCONN", TCGENQRY(,, cQuery), cQryTVL, .F., .T.)

		If ( cQryTVL )->( !EoF() )
			lFoundTVL := .T.
		EndIf

		(cQryTVL)->( dbCloseArea() )

		If lRecalculo
			If SubStr(MV_PAR09, 1, 2) + SubStr(MV_PAR09, 4, 4) < StrZero( Month(dDataBase), 2 ) + AllTrim( Str( Year(dDatabase) ) )
				lRetorno := !lFoundTVL .Or. (lFoundTVL .And. MsgYesNo(STR0022)) //"Mês já calculado, deseja recalcular?"
			EndIf
		EndIf
	EndIf

Return lRetorno

//---------------------------------------------------------------------
/*/{Protheus.doc} MNTRetTPN
Retorna dados do Bem no periodo solicitado.

@author Marcos Wagner Junior
@since 07/06/2010
/*/
//---------------------------------------------------------------------
Static Function MNTRetTPN(cBem,dDataIni)

	Local dDtFimCalc := cTod("  /  /  ")
	Local dDatFim    := LastDay(dDataIni)
	Local lFirst     := .T.
	Local nI         := 0
	Local nDiasTVB   := 0
	Local nSoma1     := 0
	Local nPosCC     := 0
	Local aCampos    := {}
	Local aRet       := {}
	Local aEmpFil    := NGRetEmp()
	Local cArqTRB    := ""
	Local cEmpresa   := ""
	Local cQuery     := ""
	Local cAliasQry  := ""
	Local cTRB683    := GetNextAlias()
	Local cEmpOld    := cEmpAnt
	Local oTemp683   := Nil

	Private aColsAux := {}

	aCampos	:= {{"EMPRESA", "C", 02, 0},;
				{"FILIAL" , "C", _nSizeFil, 0},;
				{"CCUSTO" , "C", TamSX3("CTT_CUSTO")[1], 0},;
				{"DATINI" , "D", 08, 0},;
				{"HORINI" , "C", 05, 0},;
				{"DATFIM" , "D", 08, 0},;
				{"HORFIM" , "C", 05, 0},;
				{"HORIMI" , "N", 09, 0},;
				{"HORIMF" , "N", 09, 0}}

	oTemp683 := FWTemporaryTable():New(cTRB683,aCampos)
	oTemp683:AddIndex( "1", {"DATINI","HORINI"} )
	oTemp683:Create()

	For nI := 1 To Len(aEmpFil)

		cEmpresa := aEmpFil[nI][1]
		If !M985ChkTbl( {"TPN"}, cEmpresa )
			Loop
		EndIf

		cAliasQry := GetNextAlias()

		cQuery := " SELECT TPN_FILIAL, TPN_CCUSTO, TPN_DTINIC, TPN_HRINIC"
		cQuery += "   FROM " + RetFullName("TPN",cEmpresa)
		cQuery += "  WHERE TPN_CODBEM  = " + ValToSql(cBem)
		cQuery += "    AND D_E_L_E_T_ <> '*' "
		cQuery += "  ORDER BY TPN_DTINIC, TPN_HRINIC, R_E_C_N_O_ "
		cQuery := ChangeQuery(cQuery)

		If Select(cAliasQry) > 0
			dbSelectArea(cAliasQry)
			(cAliasQry)->(dbCloseArea())
		EndIf

		MPSysOpenQuery( cQuery , cAliasQry )

		While (cAliasQry)->( !Eof() )

			nHodomIni := NGCONTAP(cBem,(cAliasQry)->TPN_DTINIC,(cAliasQry)->TPN_HRINIC)[1]

			dbSelectArea(cTRB683)

			RecLock(cTRB683, .T.)
			(cTRB683)->EMPRESA   := cEmpresa
			(cTRB683)->FILIAL    := (cAliasQry)->TPN_FILIAL
			(cTRB683)->CCUSTO    := (cAliasQry)->TPN_CCUSTO
			(cTRB683)->DATINI    := SToD((cAliasQry)->TPN_DTINIC)
			(cTRB683)->HORINI    := (cAliasQry)->TPN_HRINIC
			(cTRB683)->DATFIM    := SToD('  /  /    ')
			(cTRB683)->HORFIM    := '  :  '
			(cTRB683)->HORIMI    := nHodomIni
			(cTRB683)->HORIMF    := 0
			(cTRB683)->(MsUnlock())

			dbSelectArea(cAliasQry)
			dbSkip()
		EndDo

		(cAliasQry)->( dbCloseArea() )
	Next

	cEmpAnt := cEmpOld

	//Grava a data/hora final
	dbSelectArea(cTRB683)
	nRecCount := RecCount()
	dbGoBottom()
	While nRecCount > 0

		RecLock(cTRB683,.F.)

		If lFirst
			(cTRB683)->DATFIM := dDatFim
			(cTRB683)->HORFIM := '24:00'
			(cTRB683)->HORIMF := NGCONTAP(cBem,DToS(dDatFim),'24:00')[1]
		Else
			(cTRB683)->DATFIM := dDataPoste
			(cTRB683)->HORFIM := nHoraPoste
			(cTRB683)->HORIMF := nHoriPoste
		EndIf

		(cTRB683)->(MsUnlock())

		dDataPoste := (cTRB683)->DATINI
		nHoraPoste := (cTRB683)->HORINI
		nHoriPoste := (cTRB683)->HORIMI

		dbSkip(-1)
		lFirst := .F.
		nRecCount--
	EndDo

	dbSelectArea(cTRB683)
	dbGoTop()
	nSoma1 := 0
	While !Eof()
		If ((cTRB683)->DATINI <= dDataIni .And. ((cTRB683)->DATFIM >= dDatFim .Or. (cTRB683)->DATFIM >= dDataIni)) .Or.;
				((cTRB683)->DATINI >= dDataIni .And. ((cTRB683)->DATFIM <= dDatFim .Or. (cTRB683)->DATFIM >= dDatFim))

			// Pesquisa se o centro de Custo já foi adicionado ao aRet
			nPosCC := aScan( aRet, { | x | x[ 3 ] == (cTRB683)->CCUSTO } )

			If (cTRB683)->DATINI < dDataIni

				nSoma1				:= IIf( Day(dDataIni) == 1 .And. nSoma1 == 0, 1, 0)
				dDtFimCalc			:= IIf( (cTRB683)->DATFIM > dDatFim, dDatFim, (cTRB683)->DATFIM )
				nDiasTVB			:= DIAS_TVB(cBem,dDataIni,dDtFimCalc,(cTRB683)->FILIAL)
				nDiasTrab			:= dDtFimCalc - dDataIni + nSoma1 + nDiasTVB

				//Calcula diferenca do contador do fim do mes ao inicio
				nC_INIFIM := IIf( NGCONTAP(cBem,DToS(dDataIni),'00:00')[1] == 0, 0,;
					(cTRB683)->HORIMF - NGCONTAP(cBem,DToS(dDataIni),'00:00')[1] )

				// Caso centro de custo já exista no aRet e for da mesma filial, soma a quantidade de dias trabalhados
				If nPosCC > 0 .And. aRet[ nPosCC, 2 ] == (cTRB683)->FILIAL
					aRet[ nPosCC, 08 ] += nDiasTrab
				Else
					aAdd( aRet, { (cTRB683)->EMPRESA, (cTRB683)->FILIAL, (cTRB683)->CCUSTO,;
						dDataIni, '00:00', (cTRB683)->DATFIM, (cTRB683)->HORFIM,;
						nDiasTrab, NGCONTAP(cBem, DToS(dDataIni), '00:00')[1], (cTRB683)->HORIMF,;
						NGCONTAP(cBem, DToS( (cTRB683)->DATFIM ), '24:00')[16], nC_INIFIM })
				EndIf

				If (cTRB683)->DATFIM > dDatFim
					aRet[1][6] := dDatFim
					aRet[1][7] := '24:00'
					Exit
				EndIf

			Else

				dDataIni := (cTRB683)->DATINI
				cHoraIni := (cTRB683)->HORINI

				If (cTRB683)->DATFIM <= dDatFim
					nSoma1 := IIf( Day(dDataIni) == 1 .And. nSoma1 == 0, 1, 0 )

					nDiasTVB := DIAS_TVB(cBem,dDataIni,(cTRB683)->DATFIM,(cTRB683)->FILIAL)
					nDiasTrab := (cTRB683)->DATFIM - dDataIni + nSoma1 + nDiasTVB

					nC_INIFIM := IIf( NGCONTAP(cBem,DToS(dDataIni),cHoraIni)[1] == 0, 0,;
						(cTRB683)->HORIMF - NGCONTAP(cBem,DToS(dDataIni),cHoraIni)[1] )

					// Caso centro de custo já exista no aRet e for da mesma filial, soma a quantidade de dias trabalhados
					If nPosCC > 0 .And. aRet[ nPosCC, 2 ] == (cTRB683)->FILIAL
						aRet[ nPosCC, 08 ] += nDiasTrab
					Else
						aAdd(aRet,{(cTRB683)->EMPRESA,(cTRB683)->FILIAL,(cTRB683)->CCUSTO,dDataIni,cHoraIni,(cTRB683)->DATFIM,(cTRB683)->HORFIM,nDiasTrab,;
							NGCONTAP(cBem,DToS(dDataIni),cHoraIni)[1],(cTRB683)->HORIMF,NGCONTAP(cBem,DToS((cTRB683)->DATFIM),cHoraIni)[16],nC_INIFIM})
					EndIf
				Else
					nSoma1		:= IIf( Day(dDataIni) == 1 .And. nSoma1 == 0, 1, 0 )
					nDiasTVB	:= DIAS_TVB(cBem,dDataIni,dDatFim,(cTRB683)->FILIAL)
					nDiasTrab	:= dDatFim - dDataIni + nSoma1 + nDiasTVB

					nC_INIFIM := IIf( NGCONTAP(cBem,DToS(dDataIni),cHoraIni)[1] == 0, 0,;
						(cTRB683)->HORIMF - NGCONTAP(cBem, DToS(dDataIni),cHoraIni)[1] )

					// Caso centro de custo já exista no aRet e for da mesma filial, soma a quantidade de dias trabalhados
					If nPosCC > 0 .And. aRet[ nPosCC, 2 ] == (cTRB683)->FILIAL
						aRet[ nPosCC, 08 ] += nDiasTrab
					Else
						aAdd(aRet,{(cTRB683)->EMPRESA,(cTRB683)->FILIAL,(cTRB683)->CCUSTO,dDataIni,cHoraIni,dDatFim,'24:00',nDiasTrab,;
							NGCONTAP(cBem,DToS(dDataIni),cHoraIni)[1],(cTRB683)->HORIMF,NGCONTAP(cBem,DToS(dDatFim),cHoraIni)[16],nC_INIFIM})
					EndIf
					Exit
				EndIf
			EndIf
		EndIf
		dbSelectArea(cTRB683)
		dbSkip()
	EndDo

	dbSelectArea(cTRB683)
	oTemp683:Delete()

Return aRet

//---------------------------------------------------------------------
/*/{Protheus.doc} DIAS_TVB
Verifica a quantidade de dias que o bem ficou Suspenso

@author Marcos Wagner Junior
@since 08/06/2010
/*/
//---------------------------------------------------------------------
Static Function DIAS_TVB(cBem,_dDatIni,_dDatFim,_cFilial)

	Local nRet, nDiasSusp, nDiasParado
	Local nContAux, nPeriodo, cCondicao

	Local aOldArea := GetArea()

	Private aPeriodos := {}
	Private nPerPrvt

	Private dDataIni, dDataFim, nPerAux

	Store CToD("") To dDataIni, dDataFim
	Store 0 To nRet, nDiasSusp, nDiasParado, nContAux, nPeriodo, nPerPrvt

	cAliasQry := GetNextAlias()

	cQuery := " SELECT TVB_DATINI, TVB_DATFIM "
	cQuery += "  FROM " + RetSQLName("TVB") + " TVB "
	cQuery += "  WHERE TVB.D_E_L_E_T_ <> '*' "
	cQuery += "    AND TVB.TVB_CODBEM    = " + ValtoSql(cBem)
	cQuery += "    AND TVB.TVB_FILIAL    = " + ValtoSql(_cFilial)
	cQuery += "    AND ((TVB.TVB_DATINI >= " + ValToSql(_dDatIni) + " AND TVB.TVB_DATINI <= " + ValToSql(_dDatFim) + ") "
	cQuery += "      OR   (TVB.TVB_DATFIM >= " + ValToSql(_dDatIni) + " AND TVB.TVB_DATFIM <= " + ValToSql(_dDatFim) + ") "
	cQuery += "      OR   (TVB.TVB_DATINI  < " + ValToSql(_dDatIni) + " AND TVB.TVB_DATFIM  > " + ValtoSql(_dDatFim) + ")) "
	cQuery += "  ORDER BY TVB_DATINI||TVB_DATFIM "

	cQuery := ChangeQuery(cQuery)

	dbUseArea( .T., "TOPCONN", TCGENQRY(,,cQuery),cAliasQry, .F., .T.)

	While (cAliasQry)->( !Eof() )
		nContAux++
		aAdd(aPeriodos, {nContAux, (cAliasQry)->TVB_DATINI, (cAliasQry)->TVB_DATFIM, .T.} )
		(cAliasQry)->( dbSkip() )
	EndDo

	(cAliasQry)->( dbCloseArea() )

	If Len(aPeriodos) > 0

		cCondicao := " (nPerAux := aScan(aPeriodos, {|x| nPerPrvt != x[1] .And. x[4] .And. "
		cCondicao += " ((dDataIni <= x[2] .And. dDataFim >= x[2]) .Or. (dDataIni <= x[2] .And. dDataFim >= x[3])) } )) > 0 "

		For nPeriodo := 1 to Len(aPeriodos)
			dDataIni := aPeriodos[nPeriodo][2]
			dDataFim := aPeriodos[nPeriodo][3]
			nPerPrvt := nPeriodo

			If aPeriodos[nPeriodo][4]
				While &cCondicao.
					aPeriodos[nPerAux][4]  := .F.
					aPeriodos[nPeriodo][3] := If(aPeriodos[nPerAux][3] > dDataFim, aPeriodos[nPerAux][3], dDataFim)
					dDataFim := aPeriodos[nPeriodo][3]
				EndDo
			Endif

		Next nPeriodo

		aSort(aPeriodos,,,{|x,y| x[2]+x[3] < y[2]+y[3] })
		For nPeriodo := 1 to Len(aPeriodos)

			If !aPeriodos[nPeriodo][4]
				Loop
			Endif

			_dAuxIni := IIF(_dDatIni > STOD(aPeriodos[nPeriodo][2]),_dDatIni,STOD(aPeriodos[nPeriodo][2]))
			_dAuxFim := IIF(_dDatFim < STOD(aPeriodos[nPeriodo][3]),_dDatFim,STOD(aPeriodos[nPeriodo][3]))

			While _dAuxIni <= _dAuxFim
				If aScan(aColsAux, {|x| x[1] == _dAuxIni}) == 0
					AADD(aColsAux,{_dAuxIni})
					nDiasParado += 1
				Endif
				_dAuxIni += 1
			End
		Next nPeriodo

	Endif

	If Len(aColsAux) == 0
		nRet := 0
	Else
		nRet := - ( Len(aColsAux) )
	Endif

Return -nDiasParado

//---------------------------------------------------------------------
/*/{Protheus.doc} DEPANTIGA
Calcula a depreciacao do mes anterior do bem

@author Marcos Wagner Junior
@since 08/06/2010
/*/
//---------------------------------------------------------------------
Static Function DEPANTIGA(cCodbem,_cAnoRef,_cMesRef,_cVidaST9)

	Local aOldArea	:= GetArea()
	Local cTVLDeprem	:= ''
	Local cAliasDep	:= ''

	cAliasDep := GetNextAlias()

	cQuery := " SELECT TVL_DEPREM "
	cQuery += "  FROM " + RetSQLName("TVL")
	cQuery += "  WHERE D_E_L_E_T_ <> '*' "
	cQuery += "    AND   TVL_CODBEM = '" + cCodbem + "' "
	cQuery += "    AND   TVL_ANOREF+TVL_MESREF < '" + _cAnoRef + _cMesRef + "' "
	cQuery += "  ORDER BY TVL_ANOREF,TVL_MESREF "

	cQuery := ChangeQuery(cQuery)

	dbUseArea( .T., "TOPCONN", TCGENQRY(,,cQuery), cAliasDep, .F., .T.)
	If !Eof()
		While (cAliasDep)->( !Eof() )
			cTVLDeprem := (cAliasDep)->TVL_DEPREM

			(cAliasDep)->( dbSkip() )
		EndDo
	Else
		cTVLDeprem := _cVidaST9
	EndIf

	(cAliasDep)->( dbCloseArea() )

	RestArea(aOldArea)

Return cTVLDeprem

//---------------------------------------------------------------------
/*/{Protheus.doc} VLPREANTIG
Calcula o valor residual do mes anterior do bem

@author Marcos Wagner Junior
@since 08/06/2010
/*/
//---------------------------------------------------------------------
Static Function VLPREANTIG( cCodbem,_cAnoRef,_cMesRef)

	Local aOldArea := GetArea()
	Local cTVLVALPRE := 0
	Local cAliasDep

	cAliasDep := GetNextAlias()

	cQuery := " SELECT TVL_VALPRE "
	cQuery += " FROM " + RetSQLName("TVL")
	cQuery += " WHERE D_E_L_E_T_ <> '*' "
	cQuery += "   AND   TVL_CODBEM = '"+cCodbem+"' "
	cQuery += "   AND   TVL_ANOREF+TVL_MESREF < '"+_cAnoRef+_cMesRef+"' "
	cQuery += " ORDER BY TVL_ANOREF,TVL_MESREF "

	cQuery := ChangeQuery(cQuery)

	dbUseArea( .T., "TOPCONN", TCGENQRY(,,cQuery),cAliasDep, .F., .T.)

	If !EoF()
		While (cAliasDep)->( !EoF() )
			cTVLVALPRE := (cAliasDep)->TVL_VALPRE

			dbSelectArea(cAliasDep)
			dbSkip()
		EndDo
	EndIf

	(cAliasDep)->(dbCloseArea())

	RestArea(aOldArea)

Return cTVLVALPRE

//---------------------------------------------------------------------
/*/{Protheus.doc} VerifCont
Utilizada para verificar a quantidade de horas que o bem trabalhou
no período do cálculo da locação.

@author Marcos Wagner Junior
@since 15/01/2014
/*/
//--------------------------------------------------------------------
Static Function VerifCont(cBem, dDataIni, cHoraIni, dDataFim, cHoraFim)

	Local nHorim    := 0
	Local cQryStp   := ""
	Local aArea     := GetArea()
	Local cGetDB   := TcGetDb()
	cQryStp   := GetNextAlias()

	If Upper(cGetDB) == "ORACLE"
		cQuery := " SELECT NVL(MIN(TP_POSCONT),0) AS CONT_MIN, NVL(MAX(TP_POSCONT),0) AS CONT_MAX "
	ElseIf "DB2" $ Upper(cGetDB) .Or. Upper(cGetDB) == "POSTGRES"
		cQuery := " SELECT COALESCE(MIN(TP_POSCONT),0) AS CONT_MIN, COALESCE(MAX(TP_POSCONT),0) AS CONT_MAX "
	Else
		cQuery := " SELECT ISNULL(MIN(TP_POSCONT),0) AS CONT_MIN, ISNULL(MAX(TP_POSCONT),0) AS CONT_MAX "
	EndIf

	cQuery += " FROM " + RetSQLName("STP") + " STP "
	cQuery += " WHERE STP.TP_CODBEM = '" + cBem + "'"
	cQuery += " AND (STP.TP_DTLEITU || STP.TP_HORA >= '" + DToS(dDataIni) + "'" + "+'" + cHoraIni + "') "
	cQuery += " AND (STP.TP_DTLEITU || STP.TP_HORA <= '" + DToS(dDataFim) + "'" + "+'" + cHoraFim + "') "
	cQuery += " AND STP.D_E_L_E_T_ = '' "

	cQuery := ChangeQuery(cQuery)

	If Select(cQryStp) > 0
		dbSelectArea(cQryStp)
		(cQryStp)->(dbCloseArea())
	EndIf

	dbUseArea( .T., "TOPCONN", TCGENQRY(,,cQuery),cQryStp, .F., .T.)

	nHorim  := ((cQryStp)->CONT_MAX) - ((cQryStp)->CONT_MIN)

	If Select(cQryStp) > 0
		dbSelectArea(cQryStp)
		(cQryStp)->(dbCloseArea())
	EndIf

	RestArea(aArea)

Return nHorim

//---------------------------------------------------------------------
/*/{Protheus.doc} GravaDados
 Grava os dados na tabela TVL.

@author Marcos Wagner Junior
@since 04/06/2010
/*/
//---------------------------------------------------------------------
Static Function GravaDados()

	Local lCalcAnlt		:= GetNewPar("MV_NGCCCAL", "") <> "1" //1 = Sintetico ; 2 = Analítico
	Local nI, nX 		:= 1
	Local lTrocaEmp 	:= .T.
	Local lMNTA6831 	:= ExistBlock("MNTA6831")
	Local cEmpIni 		:= SubStr(MV_PAR01,1,2)
	Local cAliasQry, cQuery, cRetTPN11 := 0
	Local lMMoeda 		:= NGCADICBASE("TL_MOEDA","A","STL",.F.) // Multi-Moeda
	Local nValCpa, nValDes
	Local nMesCalc 		:= 0
	Local _cFilINI 		:= Space(_nSizeFil)
	Local _cFilFIM		:= Space(_nSizeFil)
	Local aEmpFil 		:= NGRetEmp()
	Local cDataInc 	:= AllTrim(GetNewPar('MV_NGDTINC'))

	Private _cEmpAnt
	cEmpOld := cEmpAnt

	//Limpa o filtro para nao dar chave duplicada
	dbSelectArea("TVL")
	Set Filter To

	While lTrocaEmp

		//Inicio - Filiais
		If nX == 1
			_cFilINI := SubStr(MV_PAR01,3,_nSizeFil)
		Else
			_cFilINI := Space(_nSizeFil)
		EndIf
		//Fim - Filiais

		If cEmpIni == SubStr(MV_PAR02,1,2) //Se a empresa for igual ao 'ATE EMPRESA'
			_cFilFIM := SubStr(MV_PAR02,3,_nSizeFil)
			lTrocaEmp := .F.
		Else
			_cFilFIM := Replicate('Z',_nSizeFil)
		EndIf
		//Fim - Filiais

		_cEmpAnt := IIf( Empty(cEmpIni), aEmpFil[nX][1], cEmpIni)

		If nX == Len(aEmpFil)
			lTrocaEmp := .F.
		EndIf

		If !M985ChkTbl({"ST6","ST9","STP"},_cEmpAnt)
			Loop
		EndIf

		cAliasQry := GetNextAlias()

		cQuery := " SELECT ST9.T9_CODBEM, ST9.T9_VALCPA, ST9.T9_VALODES, ST9.T9_UNIDDES, ST9.T9_CONTACU, ST9.T9_SEGLICE, ST9.T9_VALFAT, "
		cQuery += "        ST6.T6_BASHMIN, ST9.T9_PERMANU, ST6.T6_PERESID, ST9.T9_ALUGUEL, ST9.T9_VALPRES, ST9.T9_DTCOMPR, ST9.T9_TEMCONT, "
		cQuery += "        ST9.T9_VALPROR, ST9.T9_DTCOMPR, T6_PTAXA, TQR_VALALU  "

		If lMMoeda
			cQuery += " , ST9.T9_MOEDA "
		EndIf

		cQuery += "  FROM " + RetFullName("ST9",_cEmpAnt) + " ST9 "
		cQuery += " INNER JOIN " + RetFullName("ST6",_cEmpAnt) + " ST6 ON T6_CODFAMI = T9_CODFAMI AND ST6.D_E_L_E_T_ = ''"
		cQuery += " INNER JOIN " + RetFullName("TQR",_cEmpAnt) + " TQR ON TQR_TIPMOD = T9_TIPMOD  AND TQR.D_E_L_E_T_ = ''" //ADD
		cQuery += " WHERE ST9.D_E_L_E_T_ <> '*' "
		cQuery += "   AND ST9.T9_FILIAL  BETWEEN '" + _cFilINI + "' AND '" + _cFilFIM + "' "
		cQuery += "   AND ST9.T9_CCUSTO  BETWEEN '" + MV_PAR03 + "' AND '" + MV_PAR04 + "' "
		cQuery += "   AND ST9.T9_CODFAMI BETWEEN '" + MV_PAR05 + "' AND '" + MV_PAR06 + "' "
		cQuery += "   AND ST9.T9_CODBEM  BETWEEN '" + MV_PAR07 + "' AND '" + MV_PAR08 + "' "
		cQuery += "   AND ST9.T9_PROPRIE = '1' "
		cQuery += "   AND ST9.T9_ALUGUEL = '1' "
		cQuery += "   AND ST9.T9_SITBEM  = 'A' "

		cQuery := ChangeQuery(cQuery)

		dbUseArea( .T., "TOPCONN", TCGENQRY(,,cQuery),cAliasQry, .F., .T.)

		ProcRegua(ReCountTmp(cAliasQry))

		While (cAliasQry)->( !Eof() )

			IncProc()

			dDataInici := CTOD('01/'+SubStr(MV_PAR09,1,2)+'/'+SubStr(MV_PAR09,4,4))
			dDataFinal := LastDay(dDataInici)

			aRetTPN := MNTRetTPN((cAliasQry)->T9_CODBEM,dDataInici)
			For nI := 1 to Len(aRetTPN)
				If lCalcAnlt
					If aRetTPN[nI][8] > 0 //Se dias trabalhados for maior que 0 calcula
						nBaseHora := (((cAliasQry)->T6_BASHMIN / (dDataFinal-dDataInici+1) ) * aRetTPN[nI][8])
						lNovoReg := .F.
						nHrasReais = 0 //variavel nHrasReais:= 0 para corrigir erro MNTA6831

						dbSelectArea("TVL")
						dbSetOrder(01)
						If dbSeek(xFilial("TVL")+(cAliasQry)->T9_CODBEM+SubStr(MV_PAR09,4,4)+SubStr(MV_PAR09,1,2)+aRetTPN[nI][1]+aRetTPN[nI][2]+aRetTPN[nI][3])
							RecLock("TVL",.F.)
						Else
							RecLock("TVL",.T.)
							TVL->TVL_FILIAL := xFilial("TVL")
							TVL->TVL_CODBEM := (cAliasQry)->T9_CODBEM
							TVL->TVL_ANOREF := SubStr(MV_PAR09,4,4)
							TVL->TVL_MESREF := SubStr(MV_PAR09,1,2)
							TVL->TVL_EMPOPE := aRetTPN[nI][1]
							TVL->TVL_FILOPE := aRetTPN[nI][2]
							TVL->TVL_CCUSTO := aRetTPN[nI][3]
							lNovoReg := .T.
						EndIf
						If lMMoeda
							TVL->TVL_MOEDA := MV_PAR14
						EndIf
						If lNovoReg .OR. (!lNovoReg .And. TVL->TVL_INDCAL == '1')
							If (cAliasQry)->T9_TEMCONT == 'S' .OR. (cAliasQry)->T9_TEMCONT == 'P'

								nValCpa := If(lMMoeda, xMoeda((cAliasQry)->T9_VALCPA, Val((cAliasQry)->T9_MOEDA), MV_PAR14, STOD((cAliasQry)->T9_DTCOMPR), 2), (cAliasQry)->T9_VALCPA)
								nValDes := If(lMMoeda, xMoeda((cAliasQry)->T9_VALODES, Val((cAliasQry)->T9_MOEDA), MV_PAR14, STOD((cAliasQry)->T9_DTCOMPR), 2), (cAliasQry)->T9_VALODES)

								TVL->TVL_EMPRES := MV_PAR13
								TVL->TVL_VALAQU := nValCpa
								TVL->TVL_VIDUTI := nValDes
								TVL->TVL_UNIDES := (cAliasQry)->T9_UNIDDES

								cRetTPN11 := aRetTPN[nI][11] //CONTADOR ACUMULADO
								TVL->TVL_DEPREM := nValDes - cRetTPN11 //VIDA UTIL REMANESCENTE

								lDepreciado := .F.
								If cRetTPN11 > nValDes
									lDepreciado := .T.
								EndIf
								TVL->TVL_VALRES := nValCpa * ((cAliasQry)->T6_PERESID/100)

								nDEPANTIGA := DEPANTIGA((cAliasQry)->T9_CODBEM,SubStr(MV_PAR09,4,4),SubStr(MV_PAR09,1,2),nValDes)
								If nDEPANTIGA == nValDes
									nVALPRES := If(lMMoeda, xMoeda((cAliasQry)->T9_VALPROR, Val((cAliasQry)->T9_MOEDA), MV_PAR14, dDataBase, 2), (cAliasQry)->T9_VALPROR)
								Else
									If lNovoReg
										nVALPRES := If(lMMoeda, xMoeda((cAliasQry)->T9_VALPRES, Val((cAliasQry)->T9_MOEDA), MV_PAR14, dDataBase, 2), (cAliasQry)->T9_VALPRES)
									Else
										nVALPRES := VLPREANTIG((cAliasQry)->T9_CODBEM,SubStr(MV_PAR09,4,4),SubStr(MV_PAR09,1,2))
									EndIf
								EndIf

								nPresCalc := ((( nValCpa - TVL->TVL_VALRES) / TVL->TVL_VIDUTI ) * TVL->TVL_DEPREM) + TVL->TVL_VALRES
								If TVL->TVL_DEPREM > 0 .And. LastDay(CTOD('01/'+cDataInc)) > STOD((cAliasQry)->T9_DTCOMPR)
									If nPresCalc > nVALPRES
										TVL->TVL_VALPRE := nVALPRES - ((nVALPRES / TVL->TVL_DEPREM) * aRetTPN[nI][12])
									Else
										TVL->TVL_VALPRE := nPresCalc
									EndIf
								Else
									If TVL->TVL_DEPREM <= 0
										TVL->TVL_VALPRE := TVL->TVL_VALRES
										TVL->TVL_DEPREM := 0
									ElseIf TVL->TVL_DEPREM > 0 .And. LastDay(CTOD('01/'+cDataInc)) < STOD((cAliasQry)->T9_DTCOMPR)
										If nPresCalc > nVALPRES
											TVL->TVL_VALPRE := nPresCalc
										Else
											TVL->TVL_VALPRE := nVALPRES - ((nVALPRES / TVL->TVL_DEPREM) * aRetTPN[nI][12])
										EndIf
									EndIf
								EndIf

								//Assume o Valor Residual, se o mesmo for maior que o Valor Presente
								If LastDay(CTOD('01/'+cDataInc)) > STOD((cAliasQry)->T9_DTCOMPR) .And. nVALPRES < TVL->TVL_VALRES
									TVL->TVL_VALPRE := nVALPRES
								EndIf

								If CTOD('01/'+cDataInc) > STOD((cAliasQry)->T9_DTCOMPR)
									TVL->TVL_PARDEP :=  (nValCpa - TVL->TVL_VALRES) / TVL->TVL_VIDUTI
								Else
									TVL->TVL_PARDEP :=  (nValCpa - TVL->TVL_VALRES) / TVL->TVL_VIDUTI
								EndIf

								If lDepreciado
									TVL->TVL_PARDEP := 0
								EndIf


								If lDepreciado
									TVL->TVL_TAXCUS := (TVL->TVL_VALRES ) * ((( 1 + (MV_PAR10/100)) ** ( 1 / 12)) - 1 ) / 	(cAliasQry)->T6_BASHMIN
									TVL->TVL_FUNMNT := ((cAliasQry)->T9_PERMANU/100) * TVL->TVL_VALRES
								Else
									TVL->TVL_TAXCUS := (TVL->TVL_VALPRE ) * ((( 1 + (MV_PAR10/100)) ** ( 1 / 12)) - 1 ) / 	(cAliasQry)->T6_BASHMIN
									TVL->TVL_FUNMNT := ((cAliasQry)->T9_PERMANU/100) * nValCpa
								EndIf
								TVL->TVL_CLEVAR := TVL->TVL_PARDEP + TVL->TVL_FUNMNT + TVL->TVL_TAXCUS
								TVL->TVL_SEGLIC := (nValCpa * (cAliasQry)->T9_SEGLICE) / 100
								TVL->TVL_TAXADM := ((TVL->TVL_CLEVAR * (cAliasQry)->T6_BASHMIN ) + TVL->TVL_SEGLIC) * (MV_PAR11 / 100)

								TVL->TVL_INDOCI := (((TVL->TVL_CLEVAR * (cAliasQry)->T6_BASHMIN ) + TVL->TVL_SEGLIC + TVL->TVL_TAXADM ) * (MV_PAR12 / 100))

								TVL->TVL_CLEFIX := TVL->TVL_SEGLIC + TVL->TVL_TAXADM + TVL->TVL_INDOCI
								TVL->TVL_CLETOT := (((TVL->TVL_CLEVAR * (cAliasQry)->T6_BASHMIN ) + TVL->TVL_CLEFIX) / (cAliasQry)->T6_BASHMIN ) * nBaseHora

								TVL->TVL_BASHOR := nBaseHora
								nCLEHOR := (((TVL->TVL_CLEVAR * (cAliasQry)->T6_BASHMIN ) + TVL->TVL_CLEFIX) / (cAliasQry)->T6_BASHMIN )
								TVL->TVL_CLEHOR := nCLEHOR
								nHrasReais := aRetTPN[nI][12] //aRetTPN[nI][10] - aRetTPN[nI][9]
								If nHrasReais > nBaseHora
									TVL->TVL_CLEHRE := nHrasReais * nCLEHOR
								Else
									TVL->TVL_CLEHRE := nBaseHora * nCLEHOR
								EndIf

								nValFat := If(lMMoeda, xMoeda((cAliasQry)->T9_VALFAT, Val((cAliasQry)->T9_MOEDA), MV_PAR14, dDataBase, 2), (cAliasQry)->T9_VALFAT)

								TVL->TVL_VALFAT := (nValFat / (dDataFinal-dDataInici+1)) * aRetTPN[nI][8]
								TVL->TVL_INDCAL := (cAliasQry)->T9_ALUGUEL
								TVL->TVL_DIALOC := aRetTPN[nI][8]
								TVL->TVL_CONTAD := aRetTPN[nI][11]
							Else

								nValCpa := If(lMMoeda, xMoeda((cAliasQry)->T9_VALCPA, Val((cAliasQry)->T9_MOEDA), MV_PAR14, STOD((cAliasQry)->T9_DTCOMPR), 2), (cAliasQry)->T9_VALCPA)
								nValDes := If(lMMoeda, xMoeda((cAliasQry)->T9_VALODES, Val((cAliasQry)->T9_MOEDA), MV_PAR14, STOD((cAliasQry)->T9_DTCOMPR), 2), (cAliasQry)->T9_VALODES)

								TVL->TVL_EMPRES := MV_PAR13
								TVL->TVL_VALAQU := nValCpa
								TVL->TVL_VIDUTI := nValDes
								TVL->TVL_UNIDES := (cAliasQry)->T9_UNIDDES

								cRetTPN11 := nBaseHora
								nDEPANTIGA := DEPANTIGA((cAliasQry)->T9_CODBEM,SubStr(MV_PAR09,4,4),SubStr(MV_PAR09,1,2),nValDes)
								If nDEPANTIGA == nValDes
									nVALPRES := If(lMMoeda, xMoeda((cAliasQry)->T9_VALPROR, Val((cAliasQry)->T9_MOEDA), MV_PAR14, dDataBase, 2), (cAliasQry)->T9_VALPROR)
								Else
									If lNovoReg
										nVALPRES := If(lMMoeda, xMoeda((cAliasQry)->T9_VALPRES, Val((cAliasQry)->T9_MOEDA), MV_PAR14, dDataBase, 2), (cAliasQry)->T9_VALPRES)
									Else
										nVALPRES := VLPREANTIG((cAliasQry)->T9_CODBEM,SubStr(MV_PAR09,4,4),SubStr(MV_PAR09,1,2))
									EndIf
								EndIf
								TVL->TVL_DEPREM := nDEPANTIGA - cRetTPN11

								lDepreciado := .F.
								If cRetTPN11 > nValDes
									lDepreciado := .T.
								EndIf
								TVL->TVL_VALRES := nValCpa * ((cAliasQry)->T6_PERESID/100)

								nPresCalc := ((( nValCpa - TVL->TVL_VALRES) / TVL->TVL_VIDUTI ) * TVL->TVL_DEPREM) + TVL->TVL_VALRES
								If TVL->TVL_DEPREM > 0 .And. LastDay(CTOD('01/'+cDataInc)) > STOD((cAliasQry)->T9_DTCOMPR)
									TVL->TVL_VALPRE := nVALPRES - ((nVALPRES / nValDes) * nBaseHora)
								Else
									If TVL->TVL_DEPREM <= 0
										TVL->TVL_VALPRE := TVL->TVL_VALRES
										TVL->TVL_DEPREM := 0
									ElseIf TVL->TVL_DEPREM > 0 .And. LastDay(CTOD('01/'+cDataInc)) < STOD((cAliasQry)->T9_DTCOMPR)
										TVL->TVL_VALPRE := nPresCalc
									EndIf
								EndIf

								//Assume o Valor Residual, se o mesmo for maior que o Valor Presente
								If LastDay(CTOD('01/'+cDataInc)) > STOD((cAliasQry)->T9_DTCOMPR) .And. TVL->TVL_VALPRE < TVL->TVL_VALRES
									TVL->TVL_VALPRE := TVL->TVL_VALRES
								EndIf

								If TVL->TVL_DEPREM >= 0
									If CTOD('01/'+cDataInc) > STOD((cAliasQry)->T9_DTCOMPR)
										TVL->TVL_PARDEP :=  (nValCpa - TVL->TVL_VALRES) / TVL->TVL_VIDUTI
									Else
										TVL->TVL_PARDEP :=  (nValCpa - TVL->TVL_VALRES) / TVL->TVL_VIDUTI
									EndIf
								Else
									TVL->TVL_PARDEP := 0
								EndIf

								If TVL->TVL_DEPREM <= 0 //lDepreciado
									TVL->TVL_PARDEP := 0
								EndIf


								If lDepreciado
									TVL->TVL_TAXCUS := (TVL->TVL_VALRES ) * ((( 1 + (MV_PAR10/100)) ** ( 1 / 12)) - 1 ) / 	(cAliasQry)->T6_BASHMIN
									TVL->TVL_FUNMNT := ((cAliasQry)->T9_PERMANU/100) * TVL->TVL_VALRES
								Else
									TVL->TVL_TAXCUS := (TVL->TVL_VALPRE ) * ((( 1 + (MV_PAR10/100)) ** ( 1 / 12)) - 1 ) / 	(cAliasQry)->T6_BASHMIN
									TVL->TVL_FUNMNT := ((cAliasQry)->T9_PERMANU/100) * nValCpa
								EndIf
								TVL->TVL_CLEVAR := TVL->TVL_PARDEP + TVL->TVL_FUNMNT + TVL->TVL_TAXCUS
								TVL->TVL_SEGLIC := (nValCpa * (cAliasQry)->T9_SEGLICE) / 100
								TVL->TVL_TAXADM := ((TVL->TVL_CLEVAR * (cAliasQry)->T6_BASHMIN ) + TVL->TVL_SEGLIC) * (MV_PAR11 / 100)

								TVL->TVL_INDOCI := (((TVL->TVL_CLEVAR * (cAliasQry)->T6_BASHMIN ) + TVL->TVL_SEGLIC + TVL->TVL_TAXADM ) * (MV_PAR12 / 100))

								TVL->TVL_CLEFIX := TVL->TVL_SEGLIC + TVL->TVL_TAXADM + TVL->TVL_INDOCI
								TVL->TVL_CLETOT := (((TVL->TVL_CLEVAR * (cAliasQry)->T6_BASHMIN ) + TVL->TVL_CLEFIX) / (cAliasQry)->T6_BASHMIN ) * nBaseHora

								TVL->TVL_BASHOR := nBaseHora
								nCLEHOR := (((TVL->TVL_CLEVAR * (cAliasQry)->T6_BASHMIN ) + TVL->TVL_CLEFIX) / (cAliasQry)->T6_BASHMIN )// * IIF(TVL->TVL_INDACU==0,1,TVL->TVL_INDACU)
								TVL->TVL_CLEHOR := nCLEHOR
								nHrasReais := aRetTPN[nI][12] //aRetTPN[nI][10] - aRetTPN[nI][9]
								If nHrasReais > nBaseHora
									TVL->TVL_CLEHRE := nHrasReais * nCLEHOR
								Else
									TVL->TVL_CLEHRE := nBaseHora * nCLEHOR
								EndIf

								nValFat := If(lMMoeda, xMoeda((cAliasQry)->T9_VALFAT, Val((cAliasQry)->T9_MOEDA), MV_PAR14, dDataBase, 2), (cAliasQry)->T9_VALFAT)

								TVL->TVL_VALFAT := (nValFat / (dDataFinal-dDataInici+1)) * aRetTPN[nI][8]
								TVL->TVL_INDCAL := (cAliasQry)->T9_ALUGUEL
								TVL->TVL_DIALOC := aRetTPN[nI][8]
								TVL->TVL_CONTAD := aRetTPN[nI][11]
							EndIf
						EndIf
						TVL->(MsUnlock())

						// Ponto de entrada para modificar dados da TVL
						If lMNTA6831
							ExecBlock("MNTA6831",.F.,.F.)
						EndIf

						dbSelectArea("ST9")
						dbSetOrder(16)
						If dbSeek((cAliasQry)->T9_CODBEM+'A') .And. (TVL->TVL_VALPRE < ST9->T9_VALPRES .OR. ST9->T9_VALPRES == 0)
							RecLock("ST9",.F.)
							ST9->T9_VALPRES := TVL->TVL_VALPRE
							ST9->(MsUnlock())
						EndIf
					Else
						dbSelectArea("TVL")
						dbSetOrder(01)
						If dbSeek(xFilial("TVL")+(cAliasQry)->T9_CODBEM+SubStr(MV_PAR09,4,4)+SubStr(MV_PAR09,1,2)+aRetTPN[nI][1]+aRetTPN[nI][2]+aRetTPN[nI][3])
							RecLock("TVL",.F.)
							dbDelete()
							TVL->(MsUnlock())
						EndIf
					EndIf
				Else		//Se for cálculo sintético
					If aRetTPN[nI][8] > 0 //Se dias trabalhados for maior que 0 calcula
						nBaseHora := (((cAliasQry)->T6_BASHMIN / (dDataFinal-dDataInici+1) ) * aRetTPN[nI][8])
						lNovoReg := .F.
						nHrasReais = 0 //variavel nHrasReais:= 0 para corrigir MNTA6831

						dbSelectArea("TVL")
						dbSetOrder(01)
						If dbSeek(xFilial("TVL")+(cAliasQry)->T9_CODBEM+SubStr(MV_PAR09,4,4)+SubStr(MV_PAR09,1,2)+aRetTPN[nI][1]+aRetTPN[nI][2]+aRetTPN[nI][3])
							RecLock("TVL",.F.)
						Else
							RecLock("TVL",.T.)
							TVL->TVL_FILIAL := xFilial("TVL")
							TVL->TVL_CODBEM := (cAliasQry)->T9_CODBEM
							TVL->TVL_ANOREF := SubStr(MV_PAR09,4,4)
							TVL->TVL_MESREF := SubStr(MV_PAR09,1,2)
							TVL->TVL_EMPOPE := aRetTPN[nI][1]
							TVL->TVL_FILOPE := aRetTPN[nI][2]
							TVL->TVL_CCUSTO := aRetTPN[nI][3]
							lNovoReg := .T.
						EndIf
						If lNovoReg .OR. (!lNovoReg .And. TVL->TVL_INDCAL == '1')
							If (cAliasQry)->T9_TEMCONT == 'S' .OR. (cAliasQry)->T9_TEMCONT == 'P'
								TVL->TVL_EMPRES := MV_PAR10
								TVL->TVL_VALAQU := 0
								TVL->TVL_VIDUTI := 0
								TVL->TVL_UNIDES := ""
								cRetTPN11 := aRetTPN[nI][11] //CONTADOR ACUMULADO
								TVL->TVL_DEPREM := 0
								TVL->TVL_VALRES := 0
								TVL->TVL_VALPRE := (cAliasQry)->TQR_VALALU
								TVL->TVL_PARDEP := 0
								TVL->TVL_TAXCUS := 0
								TVL->TVL_FUNMNT := 0
								TVL->TVL_CLEVAR := 0
								TVL->TVL_SEGLIC := 0
								TVL->TVL_TAXADM := (cAliasQry)->T6_PTAXA
								TVL->TVL_INDOCI := 0
								TVL->TVL_CLEFIX := 0
								TVL->TVL_BASHOR := nBaseHora //((cAliasQry)->T6_BASHMIN)

								nCLEHOR := ((((cAliasQry)->TQR_VALALU * (cAliasQry)->T6_PTAXA) / (cAliasQry)->T6_BASHMIN) / 100)

								TVL->TVL_CLEHOR := nCLEHOR

								nHrasReais := VerifCont((cAliasQry)->T9_CODBEM,aRetTPN[nI][4],aRetTPN[nI][5],aRetTPN[nI][6],aRetTPN[nI][7])

						  		//Inicio - cálculo de dias trabalhados p/ desconto
								nMesCalc := Month(dDataInici)

								Do Case
								Case aRetTPN[nI][8] < 31 .And. (nMesCalc = 1 .Or. nMesCalc = 3 .Or. nMesCalc = 5 .Or.;
										nMesCalc = 7 .Or. nMesCalc = 8 .Or. nMesCalc = 10 .Or. nMesCalc = 12) .And.;
										nHrasReais < nBaseHora

									TVL->TVL_CLEHRE := nBaseHora * nCLEHOR

								Case aRetTPN[nI][8] < 30 .And. (nMesCalc = 2 .Or. nMesCalc = 4 .Or. nMesCalc = 6 .Or.;
										nMesCalc = 9 .Or. nMesCalc = 11) .And. nHrasReais < nBaseHora

									TVL->TVL_CLEHRE := nBaseHora * nCLEHOR

								OtherWise
									TVL->TVL_CLEHRE := IIf( nHrasReais > ((cAliasQry)->T6_BASHMIN), nHrasReais * nCLEHOR,;
										((cAliasQry)->T6_BASHMIN) * nCLEHOR )
								EndCase
								//Fim

								TVL->TVL_CLETOT := ((cAliasQry)->T6_BASHMIN) * nCLEHOR
								TVL->TVL_VALFAT := TVL->TVL_CLEHRE
								TVL->TVL_INDCAL := (cAliasQry)->T9_ALUGUEL
								TVL->TVL_DIALOC := aRetTPN[nI][8]
								TVL->TVL_CONTAD := nHrasReais

							EndIf
						EndIf

						TVL->(MsUnlock())

						// Ponto de entrada para modificar dados da TVL
						If lMNTA6831
							ExecBlock("MNTA6831",.F.,.F.)
						EndIf

					Else
						dbSelectArea("TVL")
						dbSetOrder(01)
						If dbSeek(xFilial("TVL")+(cAliasQry)->T9_CODBEM+SubStr(MV_PAR09,4,4)+SubStr(MV_PAR09,1,2)+aRetTPN[nI][1]+aRetTPN[nI][2]+aRetTPN[nI][3])
							RecLock("TVL",.F.)
							dbDelete()
							TVL->(MsUnlock())
						EndIf
					EndIf
				EndIf		//Fim
			Next

			dbSelectArea(cAliasQry)
			dbSkip()
		EndDo

		(cAliasQry)->( dbCloseArea() )

		cEmpIni := aEmpFil[nX][1]
		If cEmpIni < SubStr(MV_PAR02,1,2)

			nX := aScan(aEmpFil,{|x| x[1] == cEmpIni})

			If nX < Len(aEmpFil)
				nX++
			ElseIf nX == Len(aEmpFil)
				If SubStr(MV_PAR02, 1, _nSizeFil) == Replicate('Z', _nSizeFil)
					nX := Len(aEmpFil)
				EndIf
			EndIf

			cEmpIni := aEmpFil[nX][1]
		EndIf

	End
	cEmpAnt := cEmpOld

Return

//---------------------------------------------------------------------
/*/{Protheus.doc} MNT683PA
Botao que ira filtrar os dados do browse

@author Marcos Wagner Junior
@since 02/06/2010
/*/
//---------------------------------------------------------------------
Function MNT683PA()

	Local cPergFil := "MNT683PA"

	If Pergunte(cPergFil, .T.)
		FiltrarTVL( cPergFil )
	EndIf

Return .T.

//---------------------------------------------------------------------
/*/{Protheus.doc} FiltrarTVL
Filtra informações da tabela TVL - Histórico de Custos de Locação

@author Pedro Henrique Soares de Souza
@since 09/10/2014
/*/
//---------------------------------------------------------------------
Static Function FiltrarTVL( cPerg )

	Local cCondicao
	Local oBrowse		:= FWMBrwActive()

	Pergunte( cPerg, .F. )

	dbSelectArea("TVL")

	cCondicao := "TVL->TVL_EMPOPE >= '" + SubStr(MV_PAR01, 1, 2) + "' .And. "
	cCondicao += "TVL->TVL_EMPOPE <= '" + SubStr(MV_PAR02, 1, 2) + "' .And. "
	cCondicao += "TVL->TVL_FILOPE >= '" + SubStr(MV_PAR01, 3, _nSizeFil) + "' .And. "
	cCondicao += "TVL->TVL_FILOPE <= '" + SubStr(MV_PAR02, 3, _nSizeFil) + "' .And. "
	cCondicao += "TVL->TVL_CCUSTO >= '" + MV_PAR03 + "' .And. TVL->TVL_CCUSTO <= '" + MV_PAR04 + "' .And. "
	cCondicao += "TVL->TVL_CCUSTO >= '" + MV_PAR05 + "' .And. TVL->TVL_CCUSTO <= '" + MV_PAR06 + "' .And. "
	cCondicao += "TVL->TVL_CODBEM >= '" + MV_PAR07 + "' .And. TVL->TVL_CODBEM <= '" + MV_PAR08 + "' .And. "
	cCondicao += "TVL->TVL_ANOREF + TVL->TVL_MESREF >= '" + SubStr(MV_PAR09, 4, 4) + SubStr(MV_PAR09, 1, 2) + "' .And. "
	cCondicao += "TVL->TVL_ANOREF + TVL->TVL_MESREF <= '" + SubStr(MV_PAR10, 4, 4) + SubStr(MV_PAR10, 1, 2) + "'"

	oBrowse:SetFilterDefault( cCondicao )

Return Nil

//---------------------------------------------------------------------
/*/{Protheus.doc} fValParam
Verifica se o conteúdo do parâmetro MV_NGDTINC é válido.

@return lRet Indica se o parâmetro está correto.

@author Pedro Henrique Soares de Souza
@since 04/09/2014
/*/
//---------------------------------------------------------------------
Static Function fValParam()

	Local lRet		 := .T.
	Local cDataInc := AllTrim( GetNewPar('MV_NGDTINC') )

	If !Empty( cDataInc )
		If Len( cDataInc ) <> 7 .Or. At('/', cDataInc) == 0
			ShowHelpDlg( "MV_NGDTINC", { STR0002 }, 5,; // "O parâmetro MV_NGDTINC deverá estar com a máscara MM/AAAA. Favor alterar!"
							{ STR0052 }, 5) //"Altere o parâmetro para utilização da rotina!"
			lRet := .F.
		EndIf
	EndIf

Return lRet

//---------------------------------------------------------------------
/*/{Protheus.doc} NGRetEmp
Função que retorna empresas conforme SM0

@param 	nTipo	Informações a serem retornadas:

					1 - Tudo (Emp + Fil)
					2 - Filiais da Empresa
					3 - Empresas ( 1a. Filial )

@param 	cEmp	Empresa para utilização do tipo 2

@return aEmpFil

@author Pedro Henrique Soares de Souza
@since 06/07/2015
/*/
//---------------------------------------------------------------------
Function NGRetEmp( nTipo, cEmp )

	Local uAux		:= Nil
	Local aEmpFil := {}

	ParamType 0 Var nTipo	As Numeric		Optional Default 1
	ParamType 1 Var cEmp		As Character	Optional Default cEmpAnt

	LoadSM0()

	Do Case
		Case nTipo == 1

			aEmpFil := aClone( _aNgEmpSM0 )

		Case nTipo == 2

			aEVal( _aNgEmpSM0, { | aX | IIf( aX[1] == cEmp, aAdd( aEmpFil, aX ), ) } )

		Case nTipo == 3

			aEVal( _aNgEmpSM0, { | aX | uAux := aX, IIf( aScan( aEmpFil, { | aY | aY[1] == uAux[1] } ) == 0, aAdd( aEmpFil, aX ), ) } )

	EndCase

Return aEmpFil

//---------------------------------------------------------------------
/*/{Protheus.doc} NGDeAteEmp

@return aEmpFil

@author Pedro Henrique Soares de Souza
@since 06/07/2015
/*/
//---------------------------------------------------------------------
Function NGDeAteEmp( cDe, cAte )

	Local nX, nFil, aEmpFil := {}

	ParamType 0 Var cDe	As Character	Optional Default ''
	ParamType 1 Var cAte	As Character	Optional Default Replicate('Z', FwSizeFilial() + 2 )

	LoadSM0()

	For nX := 1 To Len(_aNgEmpSM0)

		For nFil := 1 To Len(_aNgEmpSM0[nX][2])

			cEmp := _aNgEmpSM0[nX,1]
			cFil := _aNgEmpSM0[nX,2,nFil]

			If cEmp + cFil < cDe .Or. cEmp + cFil > cAte
				Loop
			EndIf

			aAdd( aEmpFil, { cEmp, cFil } )

		Next nFil

	Next nX

Return aEmpFil

//----------------------------------------------------------------------
/*/{Protheus.doc} LoadSM0
Rotina auxiliar para carregar o vetor _aNgEmpSM0 com dados do sigamat.emp
Uso Geral.

@author Pedro Henrique Soares de Souza
@since 06/07/2015
/*/
//----------------------------------------------------------------------
Static Function LoadSM0()

	Local aArea    := {}
	Local aAreaSM0 := {}

	Local nPos		 := 0

	If Len( _aNgEmpSM0 ) == 0

		aArea    := GetArea()
		aAreaSM0 := SM0->( GetArea() )

		SM0->( dbSetOrder( 1 ) )
		SM0->( dbGoTop() )
		SM0->( dbEVal( { || cEmp := SM0->M0_CODIGO, IIf( ( nPos := aScan(_aNgEmpSM0, {|x| x[1] == cEmp}) ) == 0,;
										aAdd( _aNgEmpSM0, { SM0->M0_CODIGO, { SubStr(SM0->M0_CODFIL, 1, FwSizeFilial()) } } ),;
										aAdd( _aNgEmpSM0[nPos][2], SubStr(SM0->M0_CODFIL, 1, FwSizeFilial())  );
										)},,{ || !EoF() } ) )

		RestArea( aAreaSM0 )
		RestArea( aArea )

	EndIf

Return Nil

//---------------------------------------------------------------------------
/*/{Protheus.doc} MNTA683VLD
Valida o conteudo das perguntas
@param cParam1  Carater	Valor recebido no parametro DE?
@param cParam2  Carater	Valor recebido no parametro ATE?
@param cAlias  	Carater	Indica a tabela que os registros pertencem
@param lDeAte   Lógico	Indica se a validação é para o DE ou ATE
@return lRet	Lógico	.T. para valido, .F. para inconsistencia.
@sample MNTA683VLD(cParam1, cParam2, cAlias, lDeAte)
@author Alexandre Santos
@since 01/09/2017
/*/
//---------------------------------------------------------------------------
Function MNTA683VLD(cParam1, cParam2, cAlias, lDeAte)
	Local lRet := .T.
	Default lDeAte := .T.
	//Validação DE?
	If lDeAte
		If !Empty(cParam1) .And. !ExistCpo(cAlias, cParam1)
			lRet := .F.
		ElseIf !Empty(cParam1) .And. !Empty(cParam2) .And. cParam2 < cParam1
			Help(" ",1,"ATEINVALID")
			lRet := .F.
		EndIf
	Else
		If Empty(cParam1) .And. Empty(cParam2)
			Help(" ",1,"ATEINVALID")
			lRet := .F.
		EndIf
		If !Empty(cParam1) .And. Empty(cParam2)
			Help(" ",1,"ATEINVALID")
			lRet := .F.
		EndIf
		If !Empty(cParam2) .And. cParam2 < cParam1
			lRet := .F.
			Help(" ",1,"DEATEINVAL")
		EndIf
		If !Empty(cParam2)
			If cParam2 == replicate('Z',Len(cParam2))
				lRet := .T.
			ElseIf ExistCpo(cAlias, cParam2)
				lRet := .T.
			EndIf
		EndIf
	EndIf
Return lRet

//---------------------------------------------------------------------------
/*/{Protheus.doc} MNTA683Fil
Cria o filtro para a consulta padrão TTMCC

@param
@return lRet Lógico .T. para execução do filtro na consulta padrão TTMCC.

@sample MNTA683Fil()
@author Alexandre Santos
@since 06/10/2017
/*/
//---------------------------------------------------------------------------
Function MNTA683Fil()

	Local lRet 		:= .F.
	Local cCodFam	:= NGSeek("ST9", TTM->TTM_CODBEM, 1, "T9_CODFAMI")
	Local cCatFam 	:= ""

	If MV_PAR05 <= cCodFam .And. MV_PAR06 >= cCodFam
		cCatFam := NGSeek("ST6", cCodFam, 1, "T6_CATBEM")
	EndIf

	cFilTTM := "TTM->TTM_EMPROP >= SubStr(MV_PAR01, 1, 2) .And. TTM->TTM_EMPROP <= SubStr(MV_PAR02, 1, 2) .And."
	cFilTTM += " TTM->TTM_FILPRO >= SubStr(MV_PAR01, 3, FwSizeFilial()) .And. TTM->TTM_FILPRO <= SubStr(MV_PAR02, 3, FwSizeFilial())"
	cFilTTM += " .And. TTM->TTM_ALUGUE == '1' .And. TTM->TTM_PROPRI == '1' "

	If &(cFilTTM) .And. (cCatFam == TTM->TTM_CATBEM .Or. Empty(cCatFam))
		lRet := .T.
	EndIf

Return lRet

//NaoVazio() .And. MNT683VLMA(.T.)
