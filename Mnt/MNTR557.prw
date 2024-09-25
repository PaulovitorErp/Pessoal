#INCLUDE "MNTR555.ch"
#INCLUDE "PROTHEUS.CH"

//---------------------------------------------------------------------
/*/{Protheus.doc} MNTR557
Relatório de Pneus por veiculo

@author Soraia de Carvalho
@since 11/09/06
@obs refeito por Maria Elisandra em 25/09/2020
@return nil
/*/
//---------------------------------------------------------------------
Function MNTR557()

    Local cPerg := "MNR555"
    Local oReport

	Private cNameFil := ''
	Private vFilTRB := MNT045TRB() // Cria tabela temporária para utilização no filtro de características

	SetKey(VK_F4, {|| MNT045FIL( vFilTRB[2] )}) // Cria tela de filtro de características

	/*---------------------------
	Parâmetros:
	MV_PAR01 -> De Filial
	MV_PAR02 -> Até Filial
	MV_PAR03 -> De Familia
	MV_PAR04 -> Até Familia
	MV_PAR05 -> De Veiculo
	MV_PAR06 -> Até Veículo
	MV_PAR07 -> Veículos 01=BANDA DIF. OR EIXO DIRECIONAL;02=PNEUS NOVOS EIXO TRASEIRO;03=COM MAIS DE UMA MEDIDA DE PNEUS;04=TODOS
    MV_PAR08 -> Considera ?1=Só Aplicados; 2=Estr. sem pneus
	MV_PAR09 -> Considera Pneus em M. Fogo ? 1=Sim;2=Não
	---------------------------*/

	If Pergunte(cPerg,.t.)
		SetKey(VK_F4, {|| })
		oReport := ReportDef()
		oReport:SetLandscape() // paisagem
		oReport:PrintDialog()
	EndIf
	
	MNT045TRB( .T., vFilTRB[1], vFilTRB[2]) // exclusão da tabela temporária

Return Nil

//---------------------------------------------------------------------
/*/{Protheus.doc} ReportDef
Definição das seções do relatório

@author Maria Elisandra de Paula
@since 25/09/2020
@return object, objeto da classe Treport
/*/
//---------------------------------------------------------------------
Static Function ReportDef()
	
    Local oReport
    Local oSection2
	Local oSection3

	oReport := TReport():New('MNTR557', STR0018,, {|oReport| ReportPrint(oReport)},'')

    oSection1 := TRSection():New(oReport,,{'ST9'},,,,,.T.) // Filial
    TRCell():New( oSection1 ,'T9_FILIAL','ST9', STR0022,,FWSIZEFILIAL()) // 'Filial'
	TRCell():New( oSection1 ,'NAMEFILIAL','', '',,50,,{|| cNameFil })

    oSection2 := TRSection():New(oReport,,{'ST9', 'TSZ', 'TQR'}) // veículos
    TRCell():New( oSection2 ,'T9_CODBEM',  'ST9', STR0023,,TAMSX3('T9_CODBEM')[1]) // 'Veículo'
	TRCell():New( oSection2 ,'T9_NOME',    'ST9', STR0050,,TAMSX3('T9_NOME')[1])	// 'Nome Veículo'
	TRCell():New( oSection2 ,'TSZ_DESSER', 'TSZ', STR0024,,TAMSX3('TSZ_DESSER')[1]) // 'Operação'
	TRCell():New( oSection2 ,'TQR_DESMOD', 'TQR', STR0025,,TAMSX3('TQR_DESMOD')[1]) // 'Tipo Modelo'

    oSection3 := TRSection():New(oReport,,{'TQS', 'ST9', 'TQR', 'TPS', 'TQT', 'TQ1' },,,,,,.T.) // pneu
	TRCell():New( oSection3 ,'TQS_EIXO',   '',     STR0051,, 20,,{|| fRetEixo( Alltrim( TQ1->TQ1_EIXO ) )  }) // 'Eixo'    
	TRCell():New( oSection3 ,'TQS_TIPEIX', 'TQS' , STR0052,, TAMSX3('TQS_TIPEIX')[1]) //'Tipo Eixo'
	TRCell():New( oSection3 ,'TPS_CODLOC', 'TPS' , STR0054,, TAMSX3('TPS_CODLOC')[1]) // 'Posição'
	TRCell():New( oSection3 ,'TQS_CODBEM', 'TQS' , STR0053,, TAMSX3('TQS_CODBEM')[1]) // 'Pneu'
    TRCell():New( oSection3 ,'TQR_DESMOD', 'TQR' , STR0025,, TAMSX3('TQR_DESMOD')[1]) // 'Tipo Modelo'
    TRCell():New( oSection3 ,'TQT_DESMED', 'TQT' , STR0055,, TAMSX3('TQT_DESMED')[1]) // 'Medida'
	TRCell():New( oSection3 ,'TQS_BANDAA', 'TQS',  STR0056,, 2,,) // 'Banda'
    TRCell():New( oSection3 ,'TQS_SULCAT', 'TQS' , STR0057,, TAMSX3('TQS_SULCAT')[1] + 4 ) // 'Sulco'
	TRCell():New( oSection3 ,'T9_CONTACU', 'ST9' , STR0058,, TAMSX3('T9_CONTACU')[1] + 4 ) // 'KM Total'
	TRCell():New( oSection3 ,'TQS_DESENH', 'TQS' , STR0059,, TAMSX3('TQS_DESENH')[1]  ) // 'Desenho'
	TRCell():New( oSection3 ,'TQS_DOT',    'TQS' , STR0060,, TAMSX3('TQS_DOT')[1]  ) // 'DOT'

	oSection3:Cell('TQS_BANDAA'):SetCBox('1=OR;2=R1;3=R2;4=R3;5=R4') // define descrição de campo combo

Return oReport

//---------------------------------------------------------------------
/*/{Protheus.doc} ReportPrint
Impressão do relatório

@param oReport, object, objeto da classe Treport
@author Maria Elisandra de Paula
@since 25/09/2020
@return boolean
/*/
//---------------------------------------------------------------------
Static Function ReportPrint(oReport)

	Local oSection1 := oReport:Section(1)
	Local oSection2 := oReport:Section(2)
	Local oSection3 := oReport:Section(3)
	Local cAliasQry := GetNextAlias()
	Local aStruct   := ''
	Local aPN       := { "1", "2", "3", "4", "5", "6", "7", "8", "9", "0" }
	Local nIndex    := 0
	Local cFil      := ''
	Local lShowNoPn := MV_PAR07 $ '03/04' .And. MV_PAR08 == 2 // Considera localizações sem Pneus sem Estrutura
	Local cCondTqs	:= "" // deve iniciar vazio
	Local cCondFire	:= "%%"
	Local lFound    := .F.
	Local cFire     := AllTrim( SuperGetMv( 'MV_NGSTAFG', .F., '' ) )
	Local lFire     := ValType( MV_PAR09 ) == 'N' .And. MV_PAR09 == 1

	If MV_PAR07 == '01' // 01=BANDA DIF. OR EIXO DIRECIONAL;
		cCondTqs := " AND TQS.TQS_BANDAA <> '1' AND (TQS.TQS_TIPEIX = '3' OR TQS.TQS_TIPEIX = '4')"
	ElseIf MV_PAR07 == '02' // 02=PNEUS NOVOS EIXO TRASEIRO;
		cCondTqs := " AND TQS.TQS_BANDAA = '1' AND (TQS.TQS_TIPEIX <> '3' AND TQS.TQS_TIPEIX <> '4')"
	EndIf

	If lFire
		cCondFire := "% OR ("
        cCondFire += " SELECT COUNT(TQS.TQS_CODBEM) "
        cCondFire += " FROM " + RetSqlName("TQS") + " TQS "
		cCondFire += " WHERE TQS.TQS_PLACA <> ' ' "
		cCondFire += " 	AND TQS.TQS_PLACA = ST9.T9_PLACA "
		cCondFire += " 	AND TQS.D_E_L_E_T_ <> '*' "
		cCondFire += cCondTqs
		cCondFire +=') > 0%'

	EndIf

	cCondTqs := IIf( Empty( cCondTqs ), '%%', '%' + cCondTqs + '%' )

	BeginSql Alias cAliasQry

		SELECT ST9.T9_FILIAL,
			ST9.T9_CODFAMI,
			ST9.T9_CODBEM,
			ST9.T9_TIPMOD,
			ST9.T9_PLACA,
			ST9.T9_CCUSTO
		FROM %table:ST9% ST9
		WHERE ST9.T9_FILIAL BETWEEN %exp:xFilial('ST9', MV_PAR01)% AND %exp:xFilial('ST9', MV_PAR02)%
			AND ST9.T9_CODFAMI BETWEEN %exp:MV_PAR03% AND %exp:MV_PAR04%
			AND ST9.T9_CODBEM BETWEEN %exp:MV_PAR05% AND %exp:MV_PAR06%
			AND ST9.%notdel%
			// veiculo deve possuir pelo menos 1 pneu na estrutura
			AND (( SELECT COUNT(TC_CODBEM)
					FROM %table:STC% STC
					JOIN  %table:TQS% TQS
						ON STC.TC_COMPONE = TQS.TQS_CODBEM
						AND STC.TC_FILIAL = TQS.TQS_FILIAL
						AND TQS.%notdel%
						%exp:cCondTqs%
					WHERE STC.TC_CODBEM = ST9.T9_CODBEM
						AND STC.TC_FILIAL = ST9.T9_FILIAL
						AND STC.%notdel%
			) > 0 %exp:cCondFire%  ) // veiculos com pneus com status aguardando marcação de fogo
		ORDER BY ST9.T9_FILIAL, ST9.T9_CODBEM

	EndSql

	While !(cAliasQry)->( Eof() )

		// filtro de características
		If MNT045STB( (cAliasQry)->T9_CODBEM, vFilTRB[2] )
			(cAliasQry)->( dbSkip() )
			Loop
		EndIf

		//---------------------------------------------
		// Esquema padrão do veículo
		//---------------------------------------------
		aStruct := {}
		dbSelectArea("TQ1")
		dbSetOrder(01)
		If dbSeek( xFilial("TQ1", (cAliasQry)->T9_FILIAL ) + (cAliasQry)->T9_CODFAMI + (cAliasQry)->T9_TIPMOD )
			While !EoF() .And. TQ1->TQ1_FILIAL == xFilial("TQ1", (cAliasQry)->T9_FILIAL ) .And. (cAliasQry)->T9_CODFAMI == TQ1->TQ1_DESENH ;
					.And. (cAliasQry)->T9_TIPMOD == TQ1->TQ1_TIPMOD

				For nIndex := 1 To TQ1->TQ1_QTDPNE
					aAdd( aStruct, { &("TQ1->TQ1_LOCPN" + aPn[nIndex]),; // localização
									TQ1->TQ1_EIXO,; // eixo
									TQ1->TQ1_TIPEIX,; // tipo eixo
									TQ1->( Recno()),; // recno tq1
									'',; // código do pneu
									'',; // medida do pneu
									.F. })  //Aguardando marcação
				Next nIndex

				TQ1->( dbSkip() )
			EndDo
		EndIf

		If Empty( aStruct )
			(cAliasQry)->( dbSkip() )
			Loop
		EndIf

		dbSelectArea("STC")
		dbSetOrder(5) // TC_FILIAL + TC_CODBEM
		If dbSeek(xFilial("STC", (cAliasQry)->T9_FILIAL ) + (cAliasQry)->T9_CODBEM )
			While !EoF() .And. STC->TC_FILIAL == xFilial("STC", (cAliasQry)->T9_FILIAL ) .And. STC->TC_CODBEM == (cAliasQry)->T9_CODBEM

				nIndex := aScan( aStruct, {|x| x[1] == STC->TC_LOCALIZ } )
				If nIndex > 0
					aStruct[nIndex, 5 ] := STC->TC_COMPONE // código do pneu

					If MV_PAR07 == '03'  //03=COM MAIS DE UMA MEDIDA DE PNEUS no mesmo eixo
						dbSelectArea('TQS')
						dbSetOrder(1)
						If dbSeek( xFilial('TQS', (cAliasQry)->T9_FILIAL ) + STC->TC_COMPONE ) 
							aStruct[nIndex, 6 ] := TQS->TQS_MEDIDA // medida do pneu
						EndIf

					EndIf

				EndIf

				STC->( dbSkip() )
			EndDo
		EndIf

		//------------------------------------------
		// Pneus aguardando marcação de fogo
		//------------------------------------------
		If lFire .And. Ascan( aStruct, {|x| Empty( x[5] )  } ) > 0
			cAliasSTQ := GetNextAlias()
			BeginSql Alias cAliasSTQ
				SELECT TQS.TQS_CODBEM,
					TQS.TQS_EIXO,
					TQS.TQS_MEDIDA,
					TQS.TQS_TIPEIX,
					TQS.TQS_POSIC
				FROM %table:TQS% TQS
				JOIN %table:ST9% ST9
					ON TQS.TQS_CODBEM = ST9.T9_CODBEM
					AND ST9.T9_STATUS = %exp:cFire%
					AND ST9.%notdel%
				WHERE TQS.TQS_PLACA = %exp:(cAliasQry)->T9_PLACA%
					AND TQS.%notdel%
			EndSql

			While !(cAliasSTQ)->( Eof() )
				nPosic := Ascan( aStruct, { |x| Empty( x[5] ) .And. ;
							Alltrim(x[1]) == Alltrim((cAliasSTQ)->TQS_POSIC) .And. ;
							Alltrim(x[2]) == Alltrim((cAliasSTQ)->TQS_EIXO) .And. ;
							Alltrim(x[3]) == Alltrim((cAliasSTQ)->TQS_TIPEIX) } )
				If nPosic > 0
					aStruct[nPosic,5] := (cAliasSTQ)->TQS_CODBEM
					aStruct[nPosic,6] := (cAliasSTQ)->TQS_MEDIDA
					aStruct[nPosic,7] := .T.
				EndIf
				(cAliasSTQ)->( dbSkip() )

			EndDo

			(cAliasSTQ)->( dbCloseArea() )
		EndIf

		If MV_PAR07 == '03'
			// busca medidas diferentes no mesmo eixo
			lFound := .F.
			For nIndex := 1 To Len( aStruct )
				If aScanX( aStruct, {|x,y| x[2] == aStruct[nIndex,2] .And. !Empty( x[6] ) .And. !Empty( aStruct[nIndex,6] );
					 .And. x[6] != aStruct[nIndex,6] .And. y != nIndex } )
					lFound := .T.
					Exit
				EndIf
			Next nIndex

			If !lFound
				(cAliasQry)->( dbSkip() )
				Loop
			EndIf
		EndIf

		dbSelectArea('ST9')
		dbSetOrder(1)
		dbSeek( (cAliasQry)->T9_FILIAL + (cAliasQry)->T9_CODBEM ) // veículo

		dbSelectArea('CTT')
		dbSetOrder(1)
		If dbSeek( xFilial('CTT', (cAliasQry)->T9_FILIAL ) + (cAliasQry)->T9_CCUSTO ) .And. !Empty( CTT->CTT_OPERAC )
			dbSelectArea('TSZ')
			dbSetOrder(1)
			dbSeek( xFilial('TSZ', (cAliasQry)->T9_FILIAL ) + CTT->CTT_OPERAC ) // operação
		EndIf

		dbSelectArea('TQR')
		dbSetOrder(1)
		dbSeek( xFilial('TQR', (cAliasQry)->T9_FILIAL ) + (cAliasQry)->T9_TIPMOD ) // modelo veículo

		If cFil != (cAliasQry)->T9_FILIAL
			cNameFil := FWFilName( cEmpAnt, (cAliasQry)->T9_FILIAL )
			oSection1:Init() // inicia filial
			oSection1:PrintLine()// Impressao da seção filial
			oSection1:Finish()
		EndIf

		cFil := (cAliasQry)->T9_FILIAL

		oSection2:Init() // inicia veiculo

		If !Empty( CTT->CTT_OPERAC )
			oSection2:Cell('TSZ_DESSER'):Show()
		Else
			oSection2:Cell('TSZ_DESSER'):Hide()
		EndIf

		oSection2:PrintLine() // Impressao da seção veículo
		oSection2:Finish()

		oSection3:Init() // inicia pneus

		For nIndex := 1 To Len( aStruct )

			dbSelectArea('TQ1')
			dbGoto( aStruct[nIndex,4] ) // recno tq1

			dbSelectArea('TPS')
			dbSetOrder(1)
			dbSeek(xFilial('TPS', (cAliasQry)->T9_FILIAL ) + aStruct[nIndex,1] ) // Localização / Posição

			If !Empty(aStruct[nIndex,5])

				dbSelectArea('TQS')
				dbSetOrder(1)
				dbSeek( xFilial('TQS', (cAliasQry)->T9_FILIAL ) + aStruct[nIndex,5] ) 

				dbSelectArea('TQT')
				dbSetOrder(1)
				dbSeek( xFilial('TQT', (cAliasQry)->T9_FILIAL ) + TQS->TQS_MEDIDA )  // medida

				dbSelectArea('ST9')
				dbSetOrder(1)
				dbSeek( xFilial('ST9', (cAliasQry)->T9_FILIAL ) + aStruct[nIndex,5] ) 

				dbSelectArea('TQR')
				dbSetOrder(1)
				dbSeek( xFilial('TQR', (cAliasQry)->T9_FILIAL ) + ST9->T9_TIPMOD ) // modelo veículo

				oSection3:Cell('TQS_CODBEM'):SetValue()
				oSection3:Cell('TQS_CODBEM'):Show()
				oSection3:Cell('TQR_DESMOD'):Show()
				oSection3:Cell('TQT_DESMED'):Show()
				oSection3:Cell('TQS_BANDAA'):Show()
				oSection3:Cell('TQS_SULCAT'):Show()
				oSection3:Cell('T9_CONTACU'):Show()
				oSection3:PrintLine() // Impressao da seção pneu

			ElseIf lShowNoPn

				oSection3:Cell('TQS_CODBEM'):SetValue(STR0048) // 'Sem Pneu'
				oSection3:Cell('TQR_DESMOD'):Hide()
				oSection3:Cell('TQT_DESMED'):Hide()
				oSection3:Cell('TQS_BANDAA'):Hide()
				oSection3:Cell('TQS_SULCAT'):Hide()
				oSection3:Cell('T9_CONTACU'):Hide()
				oSection3:PrintLine() // Impressao da seção pneu

			EndIf

		Next nIndex

		(cAliasQry)->( dbSkip() )
		oSection2:Finish()
		oSection3:Finish()

	EndDo

	(cAliasQry)->( dbCloseArea() )

Return .T.

//---------------------------------------------------------------------
/*/{Protheus.doc} fRetEixo
Retorna descrição do eixo

@param cEixo, string, código do eixo
@author Maria Elisandra de Paula
@since 25/09/2020
@return string, descrição do eixo
/*/
//---------------------------------------------------------------------
Static Function fRetEixo( cEixo )

	Local cRet :=  ''

	If cEixo == '1'
		cRet :=  STR0026 //"Primeiro"
	ElseIf cEixo == '2'
		cRet :=  STR0027 //"Segundo"
	ElseIf cEixo == '3'
		cRet :=  STR0028 //"Terceiro"
	ElseIf cEixo == '4'
		cRet :=  STR0029 //"Quarto"
	ElseIf cEixo == '5'
		cRet :=  STR0030 //"Quinto"
	ElseIf cEixo == '6'
		cRet :=  STR0031 //"Sexto"
	ElseIf cEixo == '7'
		cRet :=  STR0032 //"Sétimo"
	ElseIf cEixo == '8'
		cRet :=  STR0033 //"Oitavo"
	ElseIf cEixo == '9'
		cRet :=  STR0034 //"Nono"
	ElseIf cEixo == '10'
		cRet :=  STR0049 //"Décimo"
	ElseIf cEixo == 'RESERVA'
		cRet :=  STR0035 //"Reserva"
	EndIf

Return cRet
