#Include "Protheus.ch"
#Include "MDTR485.ch"
#Include "msole.ch"

//---------------------------------------------------------------------
/*/{Protheus.doc} MDTR485

Relatório de Resultado Exame Oftalmológico

@author Guilherme Freudenburg
@since 04/09/2017

@sample MDTR485()
@version MP11

@return Sempre Verdadeiro
/*/
//---------------------------------------------------------------------
Function MDTR485()

	Local aNGBEGINPRM	:= NGBEGINPRM()//Armazena variaveis p/ devolucao (NGRIGHTCLICK)
	Local aSX1		:= {}
	Local cAliasOft := GetNextAlias()
	Local cDataDe	:= ""
	Local cDataAte	:= ""

	If GetRpoRelease() < "12.1.023" .Or. TM4->(ColumnPos("TM4_OFTIPO")) <= 0
		MsgInfo(STR0062, STR0058)
		Return .F.
	EndIf

	Private nTamTM0 := TamSX3("TM0_NUMFIC")[1] //Busca tamanho do campo de Ficha Médica
	Private nTamExa := TamSX3("TM4_EXAME")[1] //Busca tamanho do campo de Exame.
	Private cPerg 	:= "MDT485    "

	If Pergunte(cPerg, .T.)

		cDataDe	 := DTOS(Mv_Par05)
		cDataAte := DTOS(Mv_Par06)

		// Busca registros de impressão
		BeginSql ALIAS cAliasOft
			SELECT TM5.TM5_FILIAL,
				TM5.TM5_NUMFIC,
				TM5.TM5_EXAME,
				TM5.TM5_DTPROG,
				TM5.TM5_DTRESU,
				TM5.TM5_INDRES,
				TM5.TM5_CODRES,
				TM5.TM5_HRPROG,
				TM0.TM0_MAT,
				TM0.TM0_NOMFIC,
				TM0.TM0_DTNASC,
				TM0.TM0_RG,
				TM0.TM0_CODFUN,
				TM0.TM0_CC
			FROM %TABLE:TM5% TM5
			JOIN %TABLE:TM0% TM0
				ON TM5.TM5_FILIAL = TM0.TM0_FILIAL
				AND TM5.TM5_NUMFIC = TM0.TM0_NUMFIC
				AND TM0.%notDel%
			JOIN %TABLE:TM4% TM4
				ON TM5.TM5_FILIAL = TM4.TM4_FILIAL
				AND TM5.TM5_EXAME = TM4.TM4_EXAME
				AND TM4.TM4_INDRES = '5'
				AND TM4.TM4_OFTIPO = '1'
				AND TM4.%notDel%
			WHERE TM5.TM5_FILIAL = %xFilial:TM5%
				AND TM5.TM5_NUMFIC >= %exp:Mv_Par01%
				AND TM5.TM5_NUMFIC <= %exp:Mv_Par02%
				AND TM5.TM5_EXAME >= %exp:Mv_Par03%
				AND TM5.TM5_EXAME <= %exp:Mv_Par04%
				AND TM5.TM5_DTRESU >= %exp:cDataDe%
				AND TM5.TM5_DTRESU <= %exp:cDataAte%
				AND TM5.%notDel%
			ORDER BY TM5.TM5_FILIAL,
					TM5.TM5_NUMFIC,
					TM5.TM5_EXAME,
					TM5.TM5_DTRESU
		EndSQL

		If Mv_Par07 == 1 //Modelo gráfico
			Processa({|lEND| MDTR485PE(cAliasOft)},STR0018) //"Imprimindo..."
		ElseIf  Mv_Par07 == 2 //Modelo Word
			Processa({|lEND| MDTR485WO(cAliasOft)},STR0018) //"Imprimindo..."
		EndIf
	EndIf

	NGRETURNPRM(aNGBEGINPRM) //Devolve variaveis armazenadas (NGRIGHTCLICK)

Return .T.

//---------------------------------------------------------------------
/*/{Protheus.doc} MDTR485PE

Função de Impressão do Relatório de Resultado Exame Oftalmológico
no modelo Personalizado.

@author Guilherme Freudenburg
@since 04/09/2017

@param cAliasOft - Caracter - Tabela temporária com registros a serem impressos.

@sample MDTR485PE()
@version MP11

@return Sempre Verdadeiro
/*/
//---------------------------------------------------------------------
Function MDTR485PE(cAliasOft)

	Local nX
	Local nPrinter	:= 0
	Local nPag1		:= 0
	Local nQuebra	:= 0

	//Variaveis resposáveis por atribuir os valores referente ao campo visual
	//Direito
	Local cVisudNas := "( ) " + STR0051
	Local cVisud55  := "( ) 55%"
	Local cVisud70  := "( ) 70%"
	Local cVisud85  := "( ) 85%"

	//Esquerdo
	Local cVisueNas := "( )"
	Local cVisue55  := "( )"
	Local cVisue70  := "( )"
	Local cVisue85  := "( )"

	Private oPrint
	Private lin := 50

	//Definição de Fontes.
	DEFINE FONT oFont08 NAME  "Arial"  SIZE 0,08 OF oPrint
	DEFINE FONT oFont12 NAME  "Arial"  SIZE 0,10 OF oPrint
	DEFINE FONT oFont13 NAME  "Arial"  SIZE 0,10 OF oPrint BOLD
	DEFINE FONT oFont20 NAME  "Arial"  SIZE 0,12 OF oPrint BOLD
	DEFINE FONT oFont21 NAME  "Arial"  SIZE 0,12 OF oPrint

	dbSelectArea(cAliasOft)
	dbGoTop()

	oPrint := FWMsPrinter():New(OemToAnsi(STR0025), 6, .T.,, .F.,,,,, .F.,, .T.,) //"Resultado do Exame Acuidade Visual"
	oPrint:SetPortrait() //Retrato

	While (cAliasOft)->(!Eof())

		dbSelectArea("TYB")
		dbSetOrder(1) //TYB_FILIAL+TYB_NUMFIC+DTOS(TYB_DTPROG)+TYB_HRPROG+TYB_EXAME
		dbSeek(xFilial("TYB") + (cAliasOft)->(TM5_NUMFIC) + (cAliasOft)->(TM5_DTPROG) +;
			(cAliasOft)->(TM5_HRPROG)+(cAliasOft)->(TM5_EXAME))

		//Atribuindo valor as variaveis de campo visual
		//Direiro
		Do Case
			Case TYB->TYB_VISUD == "1"
				cVisudNas := "(X) " + STR0051
			Case TYB->TYB_VISUD == "2"
				cVisud55 := "(X) 55%"
			Case TYB->TYB_VISUD == "3"
				cVisud70 := "(X) 70%"
			Case TYB->TYB_VISUD == "4"
				cVisud85 := "(X) 85%"
		EndCase

		//Esquerdo
		Do Case
			Case TYB->TYB_VISUE == "1"
				cVisueNas := "(X)"
			Case TYB->TYB_VISUE == "2"
				cVisue55 := "(X)"
			Case TYB->TYB_VISUE == "3"
				cVisue70 := "(X)"
			Case TYB->TYB_VISUE == "4"
				cVisue85 := "(X)"
		EndCase

		If nQuebra > 0
			Somalinha(cAliasOft,, .T.)
		Else
			oPrint:StartPage()
			fPrintHead(cAliasOft)
		EndIf

		oPrint:Box(lin, 50, lin + 80, 2280) //Box principal
		oPrint:Say(Lin + 40, 950,  STR0041, oFont20)//"TESTE PARA LONGE"
		Somalinha(2, 100)

		// PRIMEIRO QUADRO - LONGE
		oPrint:Box(lin, 50, lin + 200, 2280) //Box principal
		oPrint:Line(lin + 100, 50, lin + 100, 2280) //Linha Horizontal para corte de Box.
		oPrint:Say(Lin + 50, 150, "OD", oFont20)
		oPrint:Say(Lin + 50, 470, "H", oFont20)
		oPrint:Say(Lin + 50, 820, "BN", oFont20)
		oPrint:Say(Lin + 50, 1130, "NFDF", oFont20)
		oPrint:Say(Lin + 50, 1440, "CEDZ", oFont20)
		oPrint:Say(Lin + 50, 1770, "BZTH", oFont20)
		oPrint:Say(Lin + 50, 2120, "OEHN", oFont20)
		oPrint:Say(Lin + 150, 120, "20/" + cValToChar(TYB->TYB_OLHODL), oFont21)
		oPrint:Say(Lin + 150, 430, "20/100", oFont21)
		oPrint:Say(Lin + 150, 795, "20/70", oFont21)
		oPrint:Say(Lin + 150, 1130, "20/50", oFont21)
		oPrint:Say(Lin + 150, 1440, "20/40", oFont21)
		oPrint:Say(Lin + 150, 1770, "20/30", oFont21)
		oPrint:Say(Lin + 150, 2120, "20/20", oFont21)

		//Linhas para divisão da Box
		oPrint:Line(lin, 335, lin + 200, 335) //1ª linha vertical
		oPrint:Line(lin, 671, lin + 200, 671) //2ª linha vertical
		oPrint:Line(lin, 1007, lin + 200, 1007) //3ª linha vertical
		oPrint:Line(lin, 1342, lin + 200, 1342) //4ª linha vertical
		oPrint:Line(lin, 1678, lin + 200, 1678) //5ª linha vertical
		oPrint:Line(lin, 2014, lin + 200, 2014) //6ª linha vertical

		// SEGUNDO QUADRO - LONGE
		Somalinha(cAliasOft, 200)
		oPrint:Box(lin,50,lin+200,2280) //Box principal
		oPrint:Line(lin + 100, 50, lin + 100, 2280) //Linha Horizontal para corte de Box.
		oPrint:Say(Lin + 55, 150, "OE", oFont20 )
		oPrint:Say(Lin + 55, 470, "N", oFont20 )
		oPrint:Say(Lin + 55, 820, "ZE", oFont20 )
		oPrint:Say(Lin + 55, 1130, "ENDZ", oFont20 )
		oPrint:Say(Lin + 55, 1440, "HFCO"  	, oFont20 )
		oPrint:Say(Lin + 55, 1770, "BTFH"  	, oFont20 )
		oPrint:Say(Lin + 55, 2120, "NEOZ"  	, oFont20 )
		oPrint:Say(Lin + 155, 120, "20/" + cVAltoChar(TYB->TYB_OLHOEL) , oFont21 )
		oPrint:Say(Lin + 155, 430, "20/100" , oFont21 )
		oPrint:Say(Lin + 155, 795, "20/70"  , oFont21 )
		oPrint:Say(Lin + 155, 1130, "20/50"  , oFont21 )
		oPrint:Say(Lin + 155, 1440, "20/40"  , oFont21 )
		oPrint:Say(Lin + 155, 1770, "20/30"  , oFont21 )
		oPrint:Say(Lin + 155, 2120, "20/20"  , oFont21 )

		//Linhas para divisão da Box
		oPrint:Line(lin, 335, lin + 200, 335) //1ª linha vertical
		oPrint:Line(lin, 671, lin + 200, 671) //2ª linha vertical
		oPrint:Line(lin, 1007, lin + 200, 1007) //3ª linha vertical
		oPrint:Line(lin, 1342, lin + 200, 1342) //4ª linha vertical
		oPrint:Line(lin, 1678, lin + 200, 1678) //5ª linha vertical
		oPrint:Line(lin, 2014, lin + 200, 2014) //6ª linha vertical

		// TERCEIRO QUADRO - LONGE
		Somalinha(cAliasOft, 200)
		oPrint:Box(lin,50,lin+200,2280) //Box principal
		oPrint:Line(lin + 100, 50, lin + 100, 2280) //Linha Horizontal para corte de Box.
		oPrint:Say(Lin + 55, 150, "AO", oFont20)
		oPrint:Say(Lin + 55, 470, "C", oFont20)
		oPrint:Say(Lin + 55, 820, "NE", oFont20)
		oPrint:Say(Lin + 55, 1130, "HTOE", oFont20)
		oPrint:Say(Lin + 55, 1440, "NHBZ", oFont20)
		oPrint:Say(Lin + 55, 1770, "BHNF", oFont20)
		oPrint:Say(Lin + 55, 2120, "PTZE", oFont20)
		oPrint:Say(Lin + 155, 115, "20/" + cVAltoChar(TYB->TYB_OLHOAL), oFont21)
		oPrint:Say(Lin + 155, 430, "20/100", oFont21)
		oPrint:Say(Lin + 155, 795, "20/70", oFont21)
		oPrint:Say(Lin + 155, 1130, "20/50", oFont21)
		oPrint:Say(Lin + 155, 1440, "20/40", oFont21)
		oPrint:Say(Lin + 155, 1770, "20/30", oFont21)
		oPrint:Say(Lin + 155, 2120, "20/20", oFont21)

		//Linhas para divisão da Box
		oPrint:Line(lin, 335, lin + 200, 335) //1ª linha vertical
		oPrint:Line(lin, 671, lin + 200, 671) //2ª linha vertical
		oPrint:Line(lin, 1007, lin + 200, 1007) //3ª linha vertical
		oPrint:Line(lin, 1342, lin + 200, 1342) //4ª linha vertical
		oPrint:Line(lin, 1678, lin + 200, 1678) //5ª linha vertical
		oPrint:Line(lin, 2014, lin + 200, 2014) //6ª linha vertical

		// PRIMEIRO QUADRO - FORIA - LONGE
		Somalinha(cAliasOft, 200)
		oPrint:Box(lin, 50, lin + 200, 2280) //Box principal
		oPrint:Line(lin + 130, 50, lin + 130, 2280) //Linha Horizontal para corte de Box.
		oPrint:Say(Lin + 45, 400, STR0042, oFont20)//"FORIA"
		oPrint:Say(Lin + 85, 340, STR0043, oFont21)//"Vermelho - Lateral"
		oPrint:Say(Lin + 170, 400, cValToChar(TYB->TYB_FORILL), oFont21) //Foria Lateral
		oPrint:Line(lin, 1000, lin + 200, 1000) //1ª linha vertical
		oPrint:Say(Lin + 45, 1600, STR0044, oFont20)//"ORTO"
		oPrint:Say(Lin + 85, 1490, "0. 1. 2. 3. 4. ! 5. 6. 7. 8. 9", oFont21)
		oPrint:Say(Lin + 170, 1533, "> " + STR0060 + "<", oFont21) //"Aceitável"
		oPrint:Line(lin + 162, 1432, lin + 162, 1532)
		oPrint:Line(lin + 162, 1685, lin + 162, 1785)

		// SEGUNDO QUADRO - FORIA - LONGE
		Somalinha(cAliasOft, 200)
		oPrint:Box(lin, 50, lin + 200, 2280) //Box principal
		oPrint:Line(lin + 130, 50, lin + 130, 2280) //Linha Horizontal para corte de Box.
		oPrint:Say(Lin + 45, 400, STR0042, oFont20)//"FORIA"
		oPrint:Say(Lin + 85, 360, STR0045, oFont21)//"Verde - Lateral"
		oPrint:Say(Lin + 170,400, cValToChar(TYB->TYB_FORIVL), oFont21) //Foria Lateral
		oPrint:Line(lin, 1000, lin + 200, 1000) //1ª linha vertical
		oPrint:Say(Lin + 45, 1600, STR0044, oFont20)//"ORTO"
		oPrint:Say(Lin + 85, 1490, "0. 1. 2. 3. 4. ! 5. 6. 7. 8. 9", oFont21)
		oPrint:Say(Lin + 170, 1533, "> " + STR0060 + "<", oFont21) //"Aceitável"
		oPrint:Line(lin + 162, 1432, lin + 162, 1532)
		oPrint:Line(lin + 162, 1685, lin + 162, 1785)

		// PRIMEIRO QUADRO - FUSAO - LONGE
		Somalinha(cAliasOft, 200)
		oPrint:Box(lin, 50, lin + 200, 2280) //Box principal
		oPrint:Line(lin + 100, 50, lin + 100, 2280) //Linha Horizontal para corte de Box.
		oPrint:Say( Lin + 50, 140, STR0046, oFont20) //"FUSÃO"
		oPrint:Say( Lin + 150, 140, STR0047, oFont20) //"Resposta"

		//Linhas para divisão da Box
		oPrint:Line(lin, 600, lin + 200, 600) //1ª linha vertical
		oPrint:Say(Lin + 50, 630, TYB->TYB_FORIFL, oFont21)
		oPrint:Say(Lin + 150, 630, NGRETSX3BOX("TYB_FORRPL", TYB->TYB_FORRPL), oFont21)

		Somalinha(cAliasOft, 200)

		oPrint:Box(lin, 50, lin + 200, 2280) //Box principal
		oPrint:Line(lin + 100, 50, lin + 100, 2280) //Linha Horizontal para corte de Box.
		oPrint:Say( Lin + 50, 140, STR0048, oFont20 ) //"ESTEREOPSIA"
		oPrint:Say( Lin + 150, 140, STR0047, oFont20 ) //"Resposta"

		//Linhas para divisão da Box
		oPrint:Line(Lin, 600, lin + 200, 600) //1ª linha vertical
		oPrint:Say(Lin + 50, 630, TYB->TYB_ESTERL, oFont21)
		oPrint:Say(Lin + 150, 630, NGRETSX3BOX("TYB_ESTREL", TYB->TYB_ESTREL), oFont21)

		Somalinha(cAliasOft, 250)
		oPrint:Say(Lin, 50, STR0049, oFont20)//"PERCEPÇÃO DAS CORES"

		If TYB->TYB_COR1 == "1"
			oPrint:Say(Lin, 950, "(X) 92", oFont21)
		Else
			oPrint:Say(Lin, 950,  "( ) 92", oFont21)
		EndIf

		If TYB->TYB_COR2 == "1"
			oPrint:Say(Lin, 1200, "(X) 56", oFont21)
		Else
			oPrint:Say(Lin, 1200, "( ) 56", oFont21)
		EndIf

		If TYB->TYB_COR3 == "1"
			oPrint:Say(Lin, 1450, "(X) 79", oFont21)
		Else
			oPrint:Say(Lin, 1450, "( ) 79", oFont21)
		EndIf

		If TYB->TYB_COR4 == "1"
			oPrint:Say(Lin, 1700, "(X) 23", oFont21)
		Else
			oPrint:Say(Lin, 1700, "( ) 23", oFont21)
		EndIf

		Somalinha(cAliasOft, 50)
		oPrint:Say(Lin, 050,  STR0050  , oFont20 )//"CAMPO VISUAL"
		Somalinha(cAliasOft)
		oPrint:Say(Lin, 200, "D", oFont21) //"Direito"
		oPrint:Say(Lin, 450, cVisudNas, oFont21) //"Nasal"
		oPrint:Say(Lin, 800, cVisud55, oFont21)
		oPrint:Say(Lin, 1050, cVisud70, oFont21)
		oPrint:Say(Lin, 1300, cVisud85, oFont21)

		Somalinha(cAliasOft)
		oPrint:Say(Lin, 200, "E", oFont21) //"Esquerdo"
		oPrint:Say(Lin, 450, cVisueNas, oFont21)
		oPrint:Say(Lin, 800, cVisue55, oFont21)
		oPrint:Say(Lin, 1050, cVisue70, oFont21)
		oPrint:Say(Lin, 1300, cVisue85, oFont21)

		Somalinha(cAliasOft,, .T.) //Quebra página

		oPrint:Box(lin, 50, lin + 80, 2280) //Box principal
		oPrint:Say(Lin + 40, 950, STR0052, oFont20)//"TESTE PARA PERTO"
		Somalinha(cAliasOft, 100)

		// PRIMEIRO QUADRO - PERTO
		oPrint:Box(lin, 50, lin + 200, 2280) //Box principal
		oPrint:Line(lin + 100, 50, lin + 100, 2280) //Linha Horizontal para corte de Box.
		oPrint:Say(Lin + 50, 150, "OD", oFont20)
		oPrint:Say(Lin + 50, 470, "H", oFont20)
		oPrint:Say(Lin + 50, 820, "BN", oFont20)
		oPrint:Say(Lin + 50, 1130, "NFDF", oFont20)
		oPrint:Say(Lin + 50, 1440, "CEDZ", oFont20)
		oPrint:Say(Lin + 50, 1770, "BZTH", oFont20)
		oPrint:Say(Lin + 50, 2120, "OEHN", oFont20)
		oPrint:Say(Lin + 150, 120, "20/" + cVAltoChar(TYB->TYB_OLHODP), oFont21)
		oPrint:Say(Lin + 150, 430, "20/100", oFont21)
		oPrint:Say(Lin + 150, 795, "20/70", oFont21)
		oPrint:Say(Lin + 150, 1130, "20/50", oFont21)
		oPrint:Say(Lin + 150, 1440, "20/40", oFont21)
		oPrint:Say(Lin + 150, 1770, "20/30", oFont21)
		oPrint:Say(Lin + 150, 2120, "20/20", oFont21)

		//Linhas para divisão da Box
		oPrint:Line(lin, 335, lin + 200, 335) //1ª linha vertical
		oPrint:Line(lin, 671, lin + 200, 671) //2ª linha vertical
		oPrint:Line(lin, 1007, lin + 200, 1007) //3ª linha vertical
		oPrint:Line(lin, 1342, lin + 200, 1342) //4ª linha vertical
		oPrint:Line(lin, 1678, lin + 200, 1678) //5ª linha vertical
		oPrint:Line(lin, 2014, lin + 200, 2014) //6ª linha vertical

		// SEGUNDO QUADRO - PERTO
		Somalinha(cAliasOft, 200)
		oPrint:Box(lin, 50, lin + 200, 2280) //Box principal
		oPrint:Line(lin + 100, 50, lin + 100, 2280) //Linha Horizontal para corte de Box.
		oPrint:Say(Lin + 50, 150, "OE", oFont20)
		oPrint:Say(Lin + 50, 470, "N", oFont20)
		oPrint:Say(Lin + 50, 820, "ZE", oFont20)
		oPrint:Say(Lin + 50, 1130, "ENDZ", oFont20)
		oPrint:Say(Lin + 50, 1440, "HFCO", oFont20)
		oPrint:Say(Lin + 50, 1770, "BTFH", oFont20)
		oPrint:Say(Lin + 50, 2120, "NEOZ", oFont20)
		oPrint:Say(Lin + 150, 120, "20/" + cVAltoChar(TYB->TYB_OLHOEP), oFont21)
		oPrint:Say(Lin + 150, 430, "20/100", oFont21)
		oPrint:Say(Lin + 150, 795, "20/70", oFont21)
		oPrint:Say(Lin + 150, 1130, "20/50", oFont21)
		oPrint:Say(Lin + 150, 1440, "20/40", oFont21)
		oPrint:Say(Lin + 150, 1770, "20/30", oFont21)
		oPrint:Say(Lin + 150, 2120, "20/20", oFont21)

		//Linhas para divisão da Box
		oPrint:Line(lin, 335, lin + 200, 335) //1ª linha vertical
		oPrint:Line(lin, 671, lin + 200, 671) //2ª linha vertical
		oPrint:Line(lin, 1007, lin + 200, 1007) //3ª linha vertical
		oPrint:Line(lin, 1342, lin + 200, 1342) //4ª linha vertical
		oPrint:Line(lin, 1678, lin + 200, 1678) //5ª linha vertical
		oPrint:Line(lin, 2014, lin + 200, 2014) //6ª linha vertical

		// TERCEIRO QUADRO - PERTO
		Somalinha(cAliasOft, 200)
		oPrint:Box(lin, 50, lin + 200, 2280) //Box principal
		oPrint:Line(lin + 100, 50, lin + 100, 2280) //Linha Horizontal para corte de Box.
		oPrint:Say(Lin + 50, 150, "AO", oFont20)
		oPrint:Say(Lin + 50, 470, "C", oFont20)
		oPrint:Say(Lin + 50, 820, "NE", oFont20)
		oPrint:Say(Lin + 50, 1130, "HTOE", oFont20)
		oPrint:Say(Lin + 50, 1440, "NHBZ", oFont20)
		oPrint:Say(Lin + 50, 1770, "BHNF", oFont20)
		oPrint:Say(Lin + 50, 2120, "PTZE", oFont20)
		oPrint:Say(Lin + 150, 120, "20/" + cVAltoChar(TYB->TYB_OLHOAP), oFont21)
		oPrint:Say(Lin + 150, 430, "20/100", oFont21)
		oPrint:Say(Lin + 150, 795, "20/70", oFont21)
		oPrint:Say(Lin + 150, 1130, "20/50", oFont21)
		oPrint:Say(Lin + 150, 1440, "20/40", oFont21)
		oPrint:Say(Lin + 150, 1770, "20/30", oFont21)
		oPrint:Say(Lin + 150, 2120, "20/20", oFont21)

		//Linhas para divisão da Box
		oPrint:Line(lin, 335, lin + 200, 335) //1ª linha vertical
		oPrint:Line(lin, 671, lin + 200, 671) //2ª linha vertical
		oPrint:Line(lin, 1007, lin + 200, 1007) //3ª linha vertical
		oPrint:Line(lin, 1342, lin + 200, 1342) //4ª linha vertical
		oPrint:Line(lin, 1678, lin + 200, 1678) //5ª linha vertical
		oPrint:Line(lin, 2014, lin + 200, 2014) //6ª linha vertical

		// PRIMEIRO QUADRO - FORIA - PERTO
		Somalinha(cAliasOft, 200)
		oPrint:Box(lin, 50, lin + 200, 2280) //Box principal
		oPrint:Line(lin + 130, 50, lin + 130, 2280) //Linha Horizontal para corte de Box.
		oPrint:Say(Lin + 45, 400, STR0042, oFont20 ) //"FORIA"
		oPrint:Say(Lin + 85, 340, STR0043, oFont21 ) //"Vermelho - Lateral"
		oPrint:Say(Lin + 170, 400, cValToChar(TYB->TYB_FORILP), oFont21) //Foria Lateral
		oPrint:Say(Lin + 45, 1600, STR0044, oFont20) //"ORTO"
		oPrint:Say(Lin + 85, 1490, "0. 1. 2. 3. 4. ! 5. 6. 7. 8. 9", oFont21)
		oPrint:Line(lin, 1000, lin + 200, 1000) //1ª linha vertical
		oPrint:Say(Lin + 170, 1533,  "> " + STR0060 + "<", oFont21) //"Aceitável"
		oPrint:Line(lin + 162, 1432, lin + 162, 1532)
		oPrint:Line(lin + 162, 1685, lin + 162, 1785)

		// SEGUNDO QUADRO - FORIA - PERTO
		Somalinha(cAliasOft, 200)
		oPrint:Box(lin, 50, lin + 200, 2280) //Box principal
		oPrint:Line(lin + 130, 50, lin + 130, 2280) //Linha Horizontal para corte de Box.
		oPrint:Say(Lin + 45, 400, STR0042, oFont20)//"FORIA"
		oPrint:Say(Lin + 85, 360, STR0045, oFont21)//"Verde - Lateral"
		oPrint:Say(Lin + 170, 400, cValToChar(TYB->TYB_FORIVP), oFont21) //Foria Lateral
		oPrint:Say(Lin + 45, 1600, STR0044, oFont20)//"ORTO"
		oPrint:Say(Lin + 85, 1490, "0. 1. 2. 3. 4. ! 5. 6. 7. 8. 9", oFont21)
		oPrint:Line(lin, 1000, lin + 200, 1000) //1ª linha vertical
		oPrint:Say(Lin + 170 ,1533, "> " + STR0060 + "<", oFont21) //"Aceitável"
		oPrint:Line(lin + 162, 1432, lin + 162, 1532)
		oPrint:Line(lin + 162, 1685, lin + 162, 1785)

		// PRIMEIRO QUADRO - FUSAO - PERTO
		Somalinha(cAliasOft, 200)
		oPrint:Box(lin, 50, lin + 200, 2280) //Box principal
		oPrint:Line(lin + 100, 50, lin + 100, 2280) //Linha Horizontal para corte de Box.
		oPrint:Say(Lin + 50, 140, STR0046, oFont20)//"FUSÃO"
		oPrint:Say(Lin + 150, 140, STR0047, oFont20)//"Resposta"

		//Linhas para divisão da Box
		oPrint:Line(lin, 600, lin + 200, 600) //1ª linha vertical
		oPrint:Say(Lin + 50, 630, TYB->TYB_FORIFP, oFont21)
		oPrint:Say(Lin + 150, 630, NGRETSX3BOX("TYB_FORRPP", TYB->TYB_FORRPP), oFont21)

		Somalinha(cAliasOft, 200)
		oPrint:Box(lin, 50, lin + 200, 2280) //Box principal
		oPrint:Line(lin + 100, 50, lin + 100, 2280) //Linha Horizontal para corte de Box.
		oPrint:Say(Lin + 50, 140, STR0048, oFont20) //"ESTEREOPSIA"
		oPrint:Say(Lin + 150, 140, STR0047, oFont20) //"Resposta"

		//Linhas para divisão da Box
		oPrint:Line(lin, 600, lin + 200, 600) //1ª linha vertical
		oPrint:Say(Lin + 50, 630, TYB->TYB_ESTERP, oFont21)
		oPrint:Say(Lin + 150, 630, NGRETSX3BOX( "TYB_ESTREP", TYB->TYB_ESTREP), oFont21)

		Somalinha(cAliasOft,, .T.)

		//Somalinha(cAliasOft, 200)
		oPrint:Say(Lin, 50, STR0053, oFont20) //"RESULTADO FINAL"
		If TYB->TYB_INDRES  == "1"
			oPrint:Say(Lin, 600, "(X) " + STR0054, oFont21) //"Aprovado"
			oPrint:Say(Lin, 1000, "( ) " + STR0055, oFont21) //"Reprovado"
		Else
			oPrint:Say(Lin, 600, "( ) " + STR0054, oFont21) //"Aprovado"
			oPrint:Say(Lin, 1000, "(X) " + STR0055, oFont21) //"Reprovado"
		EndIf

		nQuebra += 1
		(cAliasOft)->(dbSkip())
	End
	oPrint:Preview()

Return .T.

//---------------------------------------------------------------------
/*/{Protheus.doc} MDTR485WO

Função de impressão do relatório 'Resultado Exame Oftalmológico'
no modelo Word.

@author Guilherme Freudenburg
@since 04/09/2017

@param cAliasOft, caracter Tabela temporária com registros a serem impressos.

@sample MDTR485WO()

@return .T., boolean, Sempre Verdadeiro
/*/
//---------------------------------------------------------------------
Function MDTR485WO(cAliasOft)

	Local cArqDot  := "acuidade_visual.dot"		  // Nome do arquivo modelo do Word (Tem que ser .dot)
	Local cPathDot := Alltrim(GetMv("MV_DIRACA")) // Path do arquivo modelo do Word
	Local cBarraRem := "\"
	Local cBarraSrv := "\"

	Local cSMCOD := If(FindFunction("FWGrpCompany"), FWGrpCompany(), SM0->M0_CODIGO)
	Local cSMFIL := If(FindFunction("FWCodFil"), FWCodFil(), SM0->M0_CODFIL)

	Local oWord

	Private cPathEst := Alltrim(GetMv("MV_DIREST")) // PATH DO ARQUIVO A SER ARMAZENADO NA ESTACAO DE TRABALHOZ
	Private cArqBmp  := "LGRL"+cSMCOD+cSMFIL+".BMP" // Nome do arquivo logo do cliente
	Private cArqBmp2 := "LGRL"+cSMCOD+".BMP"        // Nome do arquivo logo do cliente
	Private cPathBmp := Alltrim(GetMv("MV_DIRACA"))	// Path do arquivo logo .bmp do cliente
	Private cPathBm2 := cPathBmp


	// Verifica versão do Word
	oWordTmp := OLE_CreateLink('TMsOleWord97')//Cria link como Word
	cTmpWord := OLE_GetProperty(oWordTmp, '209')
	OLE_CloseLink(oWordTmp) //Fecha link
	If Valtype(cTmpWord) == "C"
		If "12" $ cTmpWord
			cWordExt := ".dotm"
		Endif
	Endif

	//Realiza consistência das barras para utilização correta do Sistema Operacional
	If GetRemoteType() == 2  //Estacao com Sistema Operacional Unix
		cBarraRem := "/"
	Endif
	If IsSrvUnix()//Servidor e da família Unix (linux, solaris, free-bsd, hp-ux, etc.)
		cBarraSrv := "/"
	Endif

	cPathDot += If(Substr(cPathDot,len(cPathDot),1) != cBarraSrv,cBarraSrv,"") + cArqDot
	cPathEst += If(Substr(cPathEst,len(cPathEst),1) != cBarraRem,cBarraRem,"")

	cPathBmp += If(Substr(cPathBmp,len(cPathBmp),1) != cBarraSrv,cBarraSrv,"") + cArqBmp
	cPathBm2 += If(Substr(cPathBm2,len(cPathBm2),1) != cBarraSrv,cBarraSrv,"") + cArqBmp2

	//Cria diretorio se nao existir
	MontaDir(cPathEst)

	//Se existir .dot na estacao, apaga!
	If File( cPathEst + cArqDot )
		Ferase( cPathEst + cArqDot )
	EndIf
	If !File(cPathDot)
		MsgStop(STR0056 + Chr(10) +; //"O arquivo acuidade_visual.dot não foi encontrado no servidor."
			STR0057, STR0058) //"Verificar parâmetro 'MV_DIRACA'."###"ATENÇÃO"
		Return .F.
	EndIf

	If File( cPathDot )
		CpyS2T( cPathDot , cPathEst , .T. )
		If File( cPathBmp )
			If File( cPathEst + cArqBmp )
				FErase( cPathEst + cArqBmp )
			EndIf
			__copyfile( cPathBmp , cPathEst + cArqBmp )
		ElseIf File( cPathBm2 )
			If File( cPathEst + cArqBmp2 )
				FErase( cPathEst + cArqBmp2 )
			EndIf
			__copyfile( cPathBm2 , cPathEst + cArqBmp2 )
			cArqBmp := cArqBmp2
		EndIf

		cArqSaida := "Documento1"// Nome do arquivo de saida

		dbSelectArea(cAliasOft)
		dbGoTop()

		While (cAliasOft)->(!Eof())

			oWord := OLE_CreateLink( "TMsOleWord97" )//Cria link como Word

			OLE_SetProperty(oWord, oleWdVisible, .T.)
			OLE_SetProperty(oWord, oleWdPrintBack, .T.)
			OLE_NewFile(oWord, cPathEst + cArqDot) //Abrindo o arquivo modelo automaticamente

			dbSelectArea("TYB")
			dbSetOrder(1) //TYB_FILIAL+TYB_NUMFIC+DTOS(TYB_DTPROG)+TYB_HRPROG+TYB_EXAME
			dbSeek(xFilial("TYB") + (cAliasOft)->(TM5_NUMFIC) + (cAliasOft)->(TM5_DTPROG) +;
				(cAliasOft)->(TM5_HRPROG)+(cAliasOft)->(TM5_EXAME))

			// CABEÇALHO
			OLE_SetDocumentVar(oWord, "matricula", (cAliasOft)->(TM0_MAT))
			OLE_SetDocumentVar(oWord, "ficha", (cAliasOft)->(TM5_NUMFIC))
			OLE_SetDocumentVar(oWord, "nome", (cAliasOft)->(TM0_NOMFIC))
			OLE_SetDocumentVar(oWord, "idade", R555ID(STOD((cAliasOft)->(TM0_DTNASC)), dDataBase) + " anos")
			OLE_SetDocumentVar(oWord, "rg", (cAliasOft)->(TM0_RG))
			OLE_SetDocumentVar(oWord, "funcao", (cAliasOft)->(TM0_CODFUN))
			OLE_SetDocumentVar(oWord, "custo", (cAliasOft)->(TM0_CC))
			OLE_SetDocumentVar(oWord, "empresa", SM0->M0_NOME )
			OLE_SetDocumentVar(oWord, "dtexame", cValtoChar( STOD( (cAliasOft)->(TM5_DTPROG) ) ))
			OLE_SetDocumentVar(oWord, "equipamento", Posicione("TM7",1,xFilial("TM7")+TYB->TYB_EQUIPA,"TM7_NOEQTO") )
			OLE_SetDocumentVar(oWord, "fabricante", Posicione("TM7",1,xFilial("TM7")+TYB->TYB_EQUIPA,"TM7_NOMFAB") )
			OLE_SetDocumentVar(oWord, "afericao", cValtoChar( TYB->TYB_DTAFER ) )
			OLE_SetDocumentVar(oWord, "calibracao", cValToChar( TYB->TYB_CALIBR ) )
			OLE_SetDocumentVar(oWord, "dtresul", cValToChar( STOD((cAliasOft)->(TM5_DTRESU)) ) )

			// LONGE
			OLE_SetDocumentVar(oWord, "ODL", "20/" + cVAltoChar(TYB->TYB_OLHODL))
			OLE_SetDocumentVar(oWord, "OEL", "20/" + cVAltoChar(TYB->TYB_OLHOEL))
			OLE_SetDocumentVar(oWord, "AOL", "20/" + cVAltoChar(TYB->TYB_OLHOAL))
			OLE_SetDocumentVar(oWord, "FORILL", cValToChar(TYB->TYB_FORILL))
			OLE_SetDocumentVar(oWord, "FORIL2", cValToChar(TYB->TYB_FORIVL))
			OLE_SetDocumentVar(oWord, "flonge", TYB->TYB_FORIFL)
			OLE_SetDocumentVar(oWord, "respflonge", NGRETSX3BOX("TYB_FORRPL", TYB->TYB_FORRPL))
			OLE_SetDocumentVar(oWord, "estlonge", TYB->TYB_ESTERL)
			OLE_SetDocumentVar(oWord, "respestlonge", NGRETSX3BOX("TYB_ESTREL", TYB->TYB_ESTREL))
			OLE_SetDocumentVar(oWord, "visud", NGRETSX3BOX("TYB_VISUD", TYB->TYB_VISUD))
			OLE_SetDocumentVar(oWord, "visue", NGRETSX3BOX("TYB_VISUE", TYB->TYB_VISUE))

			// CORES
			OLE_SetDocumentVar(oWord, "92", IIf(TYB->TYB_COR1 == "1", "X", " "))
			OLE_SetDocumentVar(oWord, "56", IIf(TYB->TYB_COR2 == "1", "X", " "))
			OLE_SetDocumentVar(oWord, "79", IIf(TYB->TYB_COR3 == "1", "X", " "))
			OLE_SetDocumentVar(oWord, "23", IIf(TYB->TYB_COR4 == "1", "X", " "))

			//CAMPO VISUAL
			OLE_SetDocumentVar(oWord, "dir_nasal", IIf(TYB->TYB_VISUD == "1", "X", " "))
			OLE_SetDocumentVar(oWord, "dir_55", IIf(TYB->TYB_VISUD == "2", "X", " "))
			OLE_SetDocumentVar(oWord, "dir_70", IIf(TYB->TYB_VISUD == "3", "X", " "))
			OLE_SetDocumentVar(oWord, "dir_85", IIf(TYB->TYB_VISUD == "4", "X", " "))

			OLE_SetDocumentVar(oWord, "esq_nasal", IIf(TYB->TYB_VISUE == "1", "X", " "))
			OLE_SetDocumentVar(oWord, "esq_55", IIf(TYB->TYB_VISUE == "2", "X", " "))
			OLE_SetDocumentVar(oWord, "esq_70", IIf(TYB->TYB_VISUE == "3", "X", " "))
			OLE_SetDocumentVar(oWord, "esq_85", IIf(TYB->TYB_VISUE == "4", "X", " "))

			// PERTO
			OLE_SetDocumentVar(oWord, "ODP", "20/" + cVAltoChar(TYB->TYB_OLHODP) )
			OLE_SetDocumentVar(oWord, "OEP", "20/" + cVAltoChar(TYB->TYB_OLHOEP) )
			OLE_SetDocumentVar(oWord, "AOP", "20/" + cVAltoChar(TYB->TYB_OLHOAP) )
			OLE_SetDocumentVar(oWord, "FORILP", cValToChar(TYB->TYB_FORILP) )
			OLE_SetDocumentVar(oWord, "FORIP2", cValToChar(TYB->TYB_FORIVP) )
			OLE_SetDocumentVar(oWord, "fperto", TYB->TYB_FORIFP )
			OLE_SetDocumentVar(oWord, "respfperto", NGRETSX3BOX( "TYB_FORRPP" , TYB->TYB_FORRPP ) )
			OLE_SetDocumentVar(oWord, "estperto", TYB->TYB_ESTERP )
			OLE_SetDocumentVar(oWord, "respestperto", NGRETSX3BOX( "TYB_ESTREP" , TYB->TYB_ESTREP ) )

			// RESULTADO FINAL
			If TYB->TYB_INDRES  == "1"
				OLE_SetDocumentVar(oWord, "RESUF", "X")
				OLE_SetDocumentVar(oWord, "RESUFIN", " ")
			Else
				OLE_SetDocumentVar(oWord, "RESUF", " ")
				OLE_SetDocumentVar(oWord, "RESUFIN", "X")
			EndIf

			//RESPONSAVEL / EXECUTANTE
			dbSelectArea("TMK")
			dbSetOrder(1)
			dbSeek(xFilial("TMK")+TYB->TYB_ATENDE)
			_Crm := If(Empty(TMK->TMK_ENTCLA),"CRM - ",Alltrim(TMK->TMK_ENTCLA)+" - ")
			OLE_SetDocumentVar(oWord,"cCrm",_Crm+Alltrim(TMK->TMK_NUMENT)+space(2)) //CRM do Medico
			OLE_SetDocumentVar(oWord,"cMedico",TMK->TMK_NOMUSU) //Nome do Medico Responsavel

			OLE_ExecuteMacro(oWord,"Atualiza")

			(cAliasOft)->(dbSkip())
		End

		MsgInfo(STR0059) //"Alterne para o programa do Ms-Word para visualizar
						 //o documento ou clique no botao para fechar."

		If Valtype(oWord) == "O"
			OLE_CloseLink(oWord)
		EndIf

	EndIf

Return .T.

//---------------------------------------------------------------------
/*/{Protheus.doc} Somalinha

Função de adição de linhas para o modelo de impressão Padrão e Personalizado.

@author Guilherme Freudenburg
@since 04/09/2017

@param nImp - Numérico - Determina o modelo de impressão 1- Padrão e 2-Personalizado.
@param nAddLin - Numérico - Determina a quantidade de linhas que serão adicionadas.
@param lQuebra - Lógica - Determina a quebra de página.

@sample Somalinha()
@version MP11

@return
/*/
//---------------------------------------------------------------------
Static Function Somalinha(cAliasOft, nAddLin, lQuebra)

	Local nLin := 50

	Default nAddLin := 0
	Default lQuebra := .F.

	Lin += nLin + nAddLin
	If lin > 3000 .Or. lQuebra
		//Finaliza a pagina e inicia uma nova.
		oPrint:EndPage()
		oPrint:StartPage()
		lin := 50
		fPrintHead(cAliasOft) //Imprime cabeçalho
	EndIf

Return

//-------------------------------------------------------------------
/*/{Protheus.doc} MDT485VX1
Validações das perguntas do relatório
@type function
@author Bruno Lobo de Souza
@since 18/08/2018
@param cPerg, caracter, pergunta a ser validada
@return boolean, retorna o valor da validação
/*/
//-------------------------------------------------------------------
Function MDT485VX1(cPerg)

	Local lRet := .T.

	If cPerg == '03'
		If Empty(Mv_par03)
			lRet := .T.
		Else
			dbSelectArea("TM4")
			dbSetOrder(1)
			If dbSeek(xFilial("TM4")+Mv_par03) .And. TM4->TM4_OFTIPO == "1"
				lRet := .T.
			Else
				lRet := .F.
			EndIf
		EndIf
	ElseIf cPerg == '04'
		lRet := AteCodigo('TM4',mv_par03,mv_par04)
		If lRet .And. mv_par04 <> Replicate('Z', Len(mv_par04))
			dbSelectArea("TM4")
			dbSetOrder(1)
			lRet := dbSeek(xFilial("TM4")+Mv_par04) .And. TM4->TM4_OFTIPO == "1"
		EndIf
	EndIf

Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} fPrintHead
Imprime cabeçalho modelo grafico
@type static function
@author Bruno Lobo de Souza
@since 10/09/2018
@return boolean, sempre verdadeiro
/*/
//-------------------------------------------------------------------
Static Function fPrintHead(cAliasOft)

	oPrint:Box(lin, 50, lin+80, 2280) //Box principal
	oPrint:Say(Lin + 40, 900, STR0026, oFont20) //"ORTHO RATER"
	Somalinha(cAliasOft, 150)
	oPrint:Say(Lin, 050, STR0027, oFont13) //"Matrícula:"
	oPrint:Say(Lin, 250, (cAliasOft)->(TM0_MAT), oFont12)
	oPrint:Say(Lin, 850, STR0028, oFont13) //"Empresa:"
	oPrint:Say(Lin, 1200, SM0->M0_NOME, oFont12)
	Somalinha(cAliasOft)
	oPrint:Say(Lin, 050, STR0061, oFont13) //"Ficha Médica:"
	oPrint:Say(Lin, 250, (cAliasOft)->(TM5_NUMFIC), oFont12)
	oPrint:Say(Lin, 850, STR0029, oFont13)//"Nome:"
	oPrint:Say(Lin, 1200, (cAliasOft)->(TM0_NOMFIC), oFont12)
	Somalinha(cAliasOft)
	oPrint:Say(Lin, 050, STR0030, oFont13)//"Data do Exame:"
	oPrint:Say(Lin, 250, cValtoChar(STOD((cAliasOft)->(TM5_DTPROG))), oFont12)
	oPrint:Say(Lin, 400, STR0031, oFont13)//"Data do Resultado:"
	oPrint:Say(Lin, 650, cValToChar(STOD((cAliasOft)->(TM5_DTRESU)) ), oFont12)
	oPrint:Say(Lin, 850, STR0033, oFont13 )//"Emissão:"
	oPrint:Say(Lin, 1200, cValToChar(dDataBAse), oFont12)
	Somalinha(cAliasOft)
	oPrint:Say(Lin, 050, STR0032, oFont13 )//"Idade:"
	oPrint:Say(Lin, 250, R555ID(STOD((cAliasOft)->(TM0_DTNASC)), dDataBase) + " anos", oFont12)
	oPrint:Say(Lin, 850, STR0034, oFont13)//"R.G.:"
	oPrint:Say(Lin, 1200, (cAliasOft)->(TM0_RG), oFont12)
	Somalinha(cAliasOft)
	oPrint:Say(Lin, 050, STR0036, oFont13)//"Função:"
	oPrint:Say(Lin, 250, (cAliasOft)->(TM0_CODFUN), oFont12)
	oPrint:Say(Lin, 850, STR0038, oFont13)//"C. Custo:"
	oPrint:Say(Lin, 1200, (cAliasOft)->(TM0_CC), oFont12)
	Somalinha(cAliasOft)
	oPrint:Say(Lin, 050, STR0035, oFont13)//"Equipamento:"
	oPrint:Say(Lin, 250, Posicione("TM7", 1, xFilial("TM7") +;
		TYB->TYB_EQUIPA, "TM7_NOEQTO"), oFont12)
	oPrint:Say(Lin, 850, STR0037, oFont13)//"Fabricante:"
	oPrint:Say(Lin, 1200, Posicione("TM7", 1, xFilial("TM7") +;
		TYB->TYB_EQUIPA, "TM7_NOMFAB"), oFont12)
	Somalinha(cAliasOft)
	oPrint:Say(Lin, 050, STR0039, oFont13)//"Data de Aferição:"
	oPrint:Say(Lin, 250, cValtoChar(TYB->TYB_DTAFER), oFont12)
	oPrint:Say(Lin, 850, STR0040, oFont13)//"Data de Calibração:"
	oPrint:Say(Lin, 1200, cValToChar(TYB->TYB_CALIBR), oFont12)
	Somalinha(cAliasOft, 50)

Return .T.