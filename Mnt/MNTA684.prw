#Include 'MNTA684.ch'
#Include 'Protheus.CH'
#Include 'FWMVCDEF.CH'

Static _nSizeFil := NGMTamFil()

//---------------------------------------------------------------------
/*/{Protheus.doc} MNTA684()
Projeção de Custos

@author Pedro Henrique Soares de Souza
@since 03/10/2014
/*/
//---------------------------------------------------------------------
Function MNTA684()

	Local aNGBeginPrm := NGBeginPrm()
	Local oBrowse

	If !MntCheckCC("MNTA684")
		Return .F.
	EndIf

	oBrowse := FWMBrowse():New()

		oBrowse:SetAlias( "TVA" )			//Alias da tabela utilizada
		oBrowse:SetMenuDef( "MNTA684" )		//Nome do fonte onde está a função MenuDef
		oBrowse:SetDescription( STR0001 )	//Descrição do browse ## "Projeção e Cálculo de Custos do Equipamento"
		oBrowse:SetFilterDefault( "TVA->TVA_FILIAL == xFilial('TVA')" )

		oBrowse:Activate()

	NGReturnPrm(aNGBeginPrm)

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
@since 03/08/2014
/*/
//---------------------------------------------------------------------
Static Function MenuDef()

	Local aRotina := {}

	ADD OPTION aRotina TITLE STR0018 ACTION 'PesqBrw'           OPERATION 1  ACCESS 0 // 'Pesquisar'
	ADD OPTION aRotina TITLE STR0019 ACTION 'VIEWDEF.MNTA684'   OPERATION 2  ACCESS 0 // 'Visualizar'
	ADD OPTION aRotina TITLE STR0020 ACTION 'MNT684GE()'        OPERATION 3  ACCESS 0 // 'Projetar'
	ADD OPTION aRotina TITLE STR0021 ACTION 'MNT684PA()'        OPERATION 4  ACCESS 0 // 'Filtro'
	ADD OPTION aRotina TITLE STR0024 ACTION 'VIEWDEF.MNTA684'   OPERATION 8  ACCESS 0 // 'Imprimir'

Return aRotina

//---------------------------------------------------------------------
/*/{Protheus.doc} ModelDef
Regras de modelagem da gravação

@return Nil

@author Pedro Henrique Soares de Souza
@since 03/10/2014
/*/
//---------------------------------------------------------------------
Static Function ModelDef()

	Local oModel

	Local oStructTVA := FWFormStruct( 1, "TVA" )

    //Cria o objeto do Modelo de Dados
	oModel := MPFormModel():New( "MNTA684", /*bPre*/, /*bPost*/, /*bCommit*/, /*bCancel*/ )

    //Adiciona ao modelo uma estrutura de formulário de edição por campo
	oModel:AddFields( "MNTA684_TVA", Nil, oStructTVA,/*bPre*/,/*bPost*/,/*bLoad*/)

	oModel:SetDescription( STR0001 )

Return oModel

//---------------------------------------------------------------------
/*/{Protheus.doc} ViewDef
Regras de Interface com o Usuário

@return Nil

@author Pedro Henrique Soares de Souza
@since 03/10/2014
/*/
//---------------------------------------------------------------------
Static Function ViewDef()

	Local oModel := FWLoadModel( "MNTA684" )
	Local oView  := FWFormView():New()

    //Objeto do model a se associar a view.
	oView:SetModel(oModel)

    //Adiciona no nosso View um controle do tipo FormFields(antiga enchoice)
	oView:AddField( "MNTA684_TVA", FWFormStruct( 2, "TVA" ), /*cLinkID*/ )

    //Criar um "box" horizontal para receber algum elemento da view
	oView:CreateHorizontalBox( "MASTER", 100,/*cIDOwner*/,/*lFixPixel*/,/*cIDFolder*/,/*cIDSheet*/ )

    //Associa um View a um box
	oView:SetOwnerView( "MNTA684_TVA", "MASTER" )

	//Inclusão de itens nas Ações Relacionadas de acordo com O NGRightClick
	NGMVCUserBtn(oView)

Return oView

//---------------------------------------------------------------------
/*/{Protheus.doc}  MNT684BEM(nPerg,cTipo)
Validacao De/Ate Bem

@return

@author Marcos Wagner Junior
@since 08/06/2010
/*/
//---------------------------------------------------------------------
Function MNT684BEM(nPerg, cTipo)

	Local aOldArea  := GetArea()
	Local lRet      := .T.
	Local cCodBem   := ""
	Local cDePar, cAtePar, cAliasQry, cQuery

	Default cTipo  := '1'

	If cTipo == '1'
		cDePar  := MV_PAR07
		cAtePar := MV_PAR08
		cCodBem := IIf( nPerg == 1, MV_PAR07, MV_PAR08 )
    Else
    	cDePar  := MV_PAR01
		cAtePar := MV_PAR02
		cCodBem := IIf( nPerg == 1, MV_PAR01, MV_PAR02 )
    EndIf

	If ( nPerg == 1 .And. !Empty(cDePar) ) .Or.;
			( nPerg == 2 .And. cAtePar <> Replicate('Z', TamSX3("T9_CODBEM")[1]) )

		cAliasQry := GetNextAlias()

		cQuery := " SELECT TTM_CODBEM "
		cQuery += " FROM " + RetSQLName("TTM")
		cQuery += " WHERE D_E_L_E_T_ <> '*' "
		cQuery += "   AND TTM_CODBEM = '" + cCodBem + "' "

		If cTipo == '1'
			cQuery += "   AND TTM_EMPROP >= '" + SubStr( MV_PAR01, 1, 2 ) + "' "
			cQuery += "   AND TTM_EMPROP <= '" + SubStr( MV_PAR02, 1, 2) + "' "
			cQuery += "   AND TTM_FILPRO >= '" + SubStr( MV_PAR01, 3, _nSizeFil ) + "' "
			cQuery += "   AND TTM_FILPRO <= '" + SubStr( MV_PAR02, 3, _nSizeFil ) + "' "
		EndIf

		cQuery += "   AND TTM_ALUGUE = '1' "
		cQuery += "   AND TTM_PROPRI = '1' "

		cQuery := ChangeQuery(cQuery)

		dbUseArea( .T., "TOPCONN", TCGENQRY(,,cQuery),cAliasQry, .F., .T.)

		If (cAliasQry)->( EoF() )
			Help( " ", 1, "REGNOIS",, NGSX2NOME('TTM'), 3, 1 )
			lRet := .F.
		Endif

		(cAliasQry)->(dbCloseArea())

		If lRet .And. nPerg == 2
			lRet := AteCodigo("TTM", cDePar, cAtePar, 06)
		EndIf
	EndIf

	RestArea(aOldArea)

Return lRet

//---------------------------------------------------------------------
/*/{Protheus.doc}MNT684GE()
Custo de Locacao do Equipamento

@author Marcos Wagner Junior
@since 02/06/2010
/*/
//---------------------------------------------------------------------
Function MNT684GE()

	Local cPergFil := "MNTA684"

	If Pergunte(cPergFil, .T.)
		Processa({|lEnd| GravaDados()}, STR0016,STR0017) // "Aguarde..." ## "Processando Registros..."
	Endif

Return Nil

//---------------------------------------------------------------------
/*/{Protheus.doc} GravaDados()
Grava os dados na tabela TVA.

@author Marcos Wagner Junior
@since 04/06/2010
/*/
//---------------------------------------------------------------------
Static Function GravaDados()

	Local cAliasQry, cFilDe, cFilAte, cQuery, cEmpOld
	Local nT6BashMin, nI, nX := 1

	Local lTrocaEmp := .T.

	Local aEmpFil   := NGRetEmp()

	Local cEmpDe := cEmpIni := SubStr(MV_PAR01, 1, 2)

	cEmpOld := cEmpAnt

	While lTrocaEmp

		cFilDe := IIf( nX == 1, SubStr(MV_PAR01, 3, _nSizeFil), Space( _nSizeFil ) )

		If cEmpDe == SubStr( MV_PAR02, 1, 2 ) //Se a empresa for igual ao 'ATE EMPRESA'
			cFilAte := SubStr( MV_PAR02, 3, _nSizeFil )
			lTrocaEmp := .F.
		Else
			cFilAte := Replicate('Z', _nSizeFil)
		Endif

		//Se empresa estiver vazia, pega primeira empresa da SM0
		cEmpAnt := IIf( Empty(cEmpDe), aEmpFil[nX][1], cEmpDe )

		If nX == Len(aEmpFil)
			lTrocaEmp := .F.
		Endif

		cAliasQry := GetNextAlias()

		cQuery := " SELECT ST9.T9_CODBEM, ST9.T9_VALCPA, ST9.T9_VALODES, ST9.T9_UNIDDES, ST9.T9_CONTACU, ST9.T9_SEGLICE, "
		cQuery += "        ST6.T6_BASHMIN, ST9.T9_PERMANU, ST6.T6_PERESID, ST9.T9_DTCOMPR, ST9.T9_VALPROR, ST9.T9_VALPRES "
		cQuery += " FROM " + RetFullName("ST9",cEmpAnt) + " ST9 "
		cQuery += " INNER JOIN " + RetFullName("ST6",cEmpAnt) + " ST6 ON T6_CODFAMI = T9_CODFAMI AND ST6.D_E_L_E_T_ = ''"
		cQuery += " WHERE ST9.D_E_L_E_T_ <> '*' "
		cQuery += "   AND ST9.T9_FILIAL  BETWEEN '" + cFilDe + "' AND '" + cFilAte + "' "
		cQuery += "   AND ST9.T9_CCUSTO  BETWEEN '" + MV_PAR03 + "' AND '" + MV_PAR04 + "' "
		cQuery += "   AND ST9.T9_CODFAMI BETWEEN '" + MV_PAR05 + "' AND '" + MV_PAR06 + "' "
		cQuery += "   AND ST9.T9_CODBEM  BETWEEN '" + MV_PAR07 + "' AND '" + MV_PAR08 + "' "
		cQuery += "   AND ST9.T9_ALUGUEL = '1' "
		cQuery += "   AND ST9.T9_PROPRIE = '1' "

		cQuery := ChangeQuery(cQuery)

		dbUseArea( .T., "TOPCONN", TCGENQRY(,,cQuery),cAliasQry, .F., .T.)

		ProcRegua( ReCountTmp(cAliasQry) )

		While !EoF()
			IncProc()

			nQtdeUtil   := ( (cAliasQry)->T9_VALODES - (cAliasQry)->T9_CONTACU ) / (cAliasQry)->T6_BASHMIN
			nQtdeUtil   := IIf( nQtdeUtil <> Int(nQtdeUtil), Int(nQtdeUtil) + 1, nQtdeUtil)
			nT9ContaCu  := (cAliasQry)->T9_CONTACU

			nMesAtual := Month(dDataBase)
			nAnoAtual := Year(dDataBase)

			For nI := 1 To (nQtdeUtil + 1)
				If nI > 1
					nMesAtual++

					If nMesAtual > 12
						nMesAtual := 1
						nAnoAtual++
					Endif
				Endif

				cAnoChave := AllTrim( Str(nAnoAtual) )
				cMesChave := StrZero( nMesAtual, 2 )

				dbSelectArea("TVA")
				dbSetOrder(01)
				If ( lNovoReg := !( dbSeek(xFilial("TVA") + (cAliasQry)->T9_CODBEM + cAnoChave + cMesChave) ) )

					RecLock("TVA", .T.)
					TVA->TVA_FILIAL := xFilial("TVA")
					TVA->TVA_CODBEM := (cAliasQry)->T9_CODBEM
					TVA->TVA_ANOREF := cAnoChave
					TVA->TVA_MESREF := cMesChave

				Else

					RecLock("TVA", .F.)

				Endif

				TVA->TVA_VALAQU := (cAliasQry)->T9_VALCPA
				TVA->TVA_VIDUTI := (cAliasQry)->T9_VALODES
				TVA->TVA_DEPREM := IIf( ( (cAliasQry)->T9_VALODES - nT9CONTACU ) < 0, 0,(cAliasQry)->T9_VALODES - nT9CONTACU)

				nT6BashMin := (cAliasQry)->T6_BASHMIN

				TVA->TVA_VALRES := (cAliasQry)->T9_VALCPA * ((cAliasQry)->T6_PERESID/100) //OK

				nDEPANTIGA := DEPANTIGA((cAliasQry)->T9_CODBEM,cAnoChave,cMesChave,(cAliasQry)->T9_VALODES)

				If nDEPANTIGA == (cAliasQry)->T9_VALODES
					nVALPRES := (cAliasQry)->T9_VALPROR
				Else
					nVALPRES := IIf( lNovoReg, (cAliasQry)->T9_VALPRES, fOldVRes((cAliasQry)->T9_CODBEM,cAnoChave,cMesChave) )
				Endif

				nPresCalc := ((( (cAliasQry)->T9_VALCPA - TVA->TVA_VALRES) / TVA->TVA_VIDUTI ) * TVA->TVA_DEPREM) + TVA->TVA_VALRES

				If TVA->TVA_DEPREM > 0
					TVA->TVA_VALPRE := nPresCalc
				Else
					TVA->TVA_VALPRE := TVA->TVA_VALRES
					TVA->TVA_DEPREM := 0
				Endif

				//Assume o Valor Residual, se o mesmo for maior que o Valor Presente
				If nVALPRES < TVA->TVA_VALRES
					TVA->TVA_VALPRE := nVALPRES
				EndIf

				TVA->TVA_PARDEP := ((cAliasQry)->T9_VALCPA - TVA->TVA_VALRES ) / TVA->TVA_VIDUTI
				If nI <> nQtdeUtil + 1
					TVA->TVA_FUNMNT := ((cAliasQry)->T9_PERMANU/100) * (cAliasQry)->T9_VALCPA
					TVA->TVA_TAXCUS := (TVA->TVA_VALPRE - TVA->TVA_VALRES ) * ((( 1 + (MV_PAR09/100)) ** ( 1 / 12)) - 1 ) / nT6BASHMIN
					TVA->TVA_CLEVAR := TVA->TVA_PARDEP + TVA->TVA_FUNMNT + TVA->TVA_TAXCUS
					TVA->TVA_SEGLIC := (cAliasQry)->T9_VALCPA * (cAliasQry)->T9_SEGLICE / 100
					TVA->TVA_TAXADM := ((TVA->TVA_CLEVAR * nT6BASHMIN) + TVA->TVA_SEGLIC) * (MV_PAR10/100)
					TVA->TVA_INDOCI := (((TVA->TVA_CLEVAR * nT6BASHMIN ) + TVA->TVA_SEGLIC + TVA->TVA_TAXADM ) * (MV_PAR11/100))
				Else
					TVA->TVA_PARDEP := 0 //OK
					TVA->TVA_FUNMNT := (TVA->TVA_VALRES * ((cAliasQry)->T9_PERMANU/100)) * nT6BASHMIN

					TVA->TVA_TAXCUS := IIf( TVA->TVA_VALPRE == TVA->TVA_VALRES, (TVA->TVA_VALRES) * (( 1 +  MV_PAR09/100 ) ** ( 1 / 12) - 1 ),;
						(TVA->TVA_VALPRE-TVA->TVA_VALRES) * (( 1 +  MV_PAR09/100 ) ** ( 1 / 12) - 1 ))

					TVA->TVA_CLEVAR := TVA->TVA_PARDEP + TVA->TVA_FUNMNT + TVA->TVA_TAXCUS
					TVA->TVA_SEGLIC := (cAliasQry)->T9_VALCPA * (cAliasQry)->T9_SEGLICE / 100
					TVA->TVA_TAXADM := (MV_PAR10/100) * (TVA->TVA_CLEVAR  + TVA->TVA_SEGLIC)
					TVA->TVA_INDOCI := (TVA->TVA_TAXCUS + TVA->TVA_FUNMNT + TVA->TVA_TAXADM + TVA->TVA_SEGLIC ) * (MV_PAR11/100)
				Endif

				TVA->TVA_CLEFIX := TVA->TVA_SEGLIC + TVA->TVA_TAXADM + TVA->TVA_INDOCI //OK
				TVA->TVA_CLETOT := IIf( TVA->TVA_PARDEP == 0, TVA->TVA_CLEVAR + TVA->TVA_CLEFIX,;
					((TVA->TVA_CLEVAR * nT6BASHMIN ) + TVA->TVA_CLEFIX))

				TVA->TVA_CLEHOR := (TVA->TVA_CLETOT / nT6BASHMIN) //OK
				TVA->TVA_MPAR09 := MV_PAR09
				TVA->TVA_MPAR10 := MV_PAR10
				TVA->TVA_MPAR11 := MV_PAR11
				TVA->(MsUnlock())

				nT9CONTACU += (cAliasQry)->T6_BASHMIN
			Next

			dbSelectArea(cAliasQry)
			dbSkip()
		EndDo

		(cAliasQry)->( dbCloseArea() )

		cEmpIni := aEmpFil[nX][1]

		If cEmpIni < SubStr(MV_PAR02, 1, 2)

			If ( nX := aScan(aEmpFil,{|x| x[1] == cEmpIni}) ) < Len(aEmpFil)

				nX++

			ElseIf nX == Len(aEmpFil) .And. SubStr(MV_PAR02, 1, 2) == 'ZZ'

				nX := Len(aEmpFil)

			Endif

			cEmpIni := aEmpFil[nX][1]
		Endif

	EndDo

	cEmpAnt := cEmpOld

Return

//---------------------------------------------------------------------
/*/{Protheus.doc}  DEPANTIGA(,)
Calcula a depreciacao do mes anterior do bem

@author Marcos Wagner Junior
@since 08/06/2010
/*/
//---------------------------------------------------------------------
Static Function DEPANTIGA(_cCodbem, _cAnoRef, _cMesRef, _cVidaST9)

	Local aOldArea	:= GetArea()

	Local cAliasDep	:= ''
	Local cTVADeprem	:= ''

	cAliasDep := GetNextAlias()

	cQuery := " SELECT TVA_DEPREM "
	cQuery += "  FROM " + RetSQLName("TVA")
	cQuery += "  WHERE D_E_L_E_T_ <> '*' "
	cQuery += "    AND   TVA_CODBEM = '" + _cCodbem + "' "
	cQuery += "    AND   TVA_ANOREF || TVA_MESREF < '" + _cAnoRef + _cMesRef + "' "
	cQuery += "  ORDER BY TVA_ANOREF,TVA_MESREF "

	cQuery := ChangeQuery(cQuery)

	dbUseArea( .T., "TOPCONN", TCGENQRY(,,cQuery),cAliasDep, .F., .T.)
	If (cAliasDep)->( !Eof() )

		While  (cAliasDep)->( !Eof() )

			cTVADeprem := (cAliasDep)->TVA_DEPREM

			dbSelectArea(cAliasDep)
			dbSkip()
		EndDo
	Else
		cTVADeprem := _cVidaST9
	Endif

	(cAliasDep)->( dbCloseArea() )

	RestArea(aOldArea)

Return cTVADeprem

//---------------------------------------------------------------------
/*/{Protheus.doc}  fOldVRes()
Calcula o valor residual do mes anterior do bem

@author Marcos Wagner Junior
@since 08/06/2010
/*/
//---------------------------------------------------------------------
Static Function fOldVRes( cCodbem, cAnoRef, cMesRef )

	Local aOldArea	:= GetArea()
	Local nValPre		:= 0

	Local cAliasDep, cQuery

	cAliasDep := GetNextAlias()

	cQuery := " SELECT TVA_VALPRE "
	cQuery += "  FROM " + RetSQLName("TVA")
	cQuery += "  WHERE D_E_L_E_T_ <> '*' "
	cQuery += "    AND   TVA_CODBEM = '" + cCodbem + "' "
	cQuery += "    AND   TVA_ANOREF || TVA_MESREF < '" + cAnoRef + cMesRef + "' "
	cQuery += "  ORDER BY TVA_ANOREF,TVA_MESREF "

	cQuery := ChangeQuery(cQuery)

	dbUseArea( .T., "TOPCONN", TCGENQRY(,,cQuery), cAliasDep, .F., .T.)

	If (cAliasDep)->( !EoF() )
		While (cAliasDep)->( !EoF() )
			nValPre := (cAliasDep)->TVA_VALPRE

			dbSelectArea(cAliasDep)
			dbSkip()
		EndDo
	EndIf

	(cAliasDep)->( dbCloseArea() )

	RestArea(aOldArea)

Return nValPre

//---------------------------------------------------------------------
/*/{Protheus.doc} MNT684PA()
Botao que ira filtrar os dados do browse

@author Marcos Wagner Junior
@since 06/02/2010
/*/
//---------------------------------------------------------------------
Function MNT684PA()

	Local cPergFil := "MNT684PA"

	If Pergunte(cPergFil, .T.)
		FiltrarTVA( cPergFil )
	EndIf

Return .T.

//---------------------------------------------------------------------
/*/{Protheus.doc} FiltrarTVA
Filtra informações da tabela TVA - Histórico de Custos de Locação

@author Pedro Henrique Soares de Souza
@since 09/10/2014
/*/
//---------------------------------------------------------------------
Static Function FiltrarTVA( cPergFil )

	Local cCondicao, oBrowse := FWMBrwActive()

	Pergunte( cPergFil, .F. )

	dbSelectArea("TVA")

	cCondicao := ' TVA->TVA_CODBEM >= "' + MV_PAR01 + '" .And. ' + ' TVA->TVA_CODBEM <= "' + MV_PAR02 + '" .And. '
	cCondicao += ' TVA->TVA_MESREF >= "' + SubStr(MV_PAR03, 1, 2) + '" .And. ' + ' TVA->TVA_MESREF <= "' + SubStr(MV_PAR04, 1, 2) + '" .And. '
	cCondicao += ' TVA->TVA_ANOREF >= "' + SubStr(MV_PAR03, 4, 4) + '" .And. ' + ' TVA->TVA_ANOREF <= "' + SubStr(MV_PAR04, 4, 4) + '"'

	oBrowse:SetFilterDefault( cCondicao )

Return Nil
