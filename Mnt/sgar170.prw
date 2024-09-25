#INCLUDE "SGAR170.ch"
#include "protheus.ch"
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณSGAR170   บAutor  ณRoger Rodrigues     บ Data ณ  30/08/10   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณImpressao de Inventario Corporativo de Gases do Efeito      บฑฑ
ฑฑบ          ณEstufa                                                      บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณSIGASGA                                                     บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Function SGAR170()
Local aNGBEGINPRM := NGBEGINPRM()
//Variaveis para impressao
Local wnrel   := "SGAR170"
Local cDesc1  := STR0001 //"Emissใo do Inventแrio Corporativo de Gases do Efeito Estufa."
Local cDesc2  := ""
Local cDesc3  := ""
Local cString := "TD9"
Private aReturn  := {STR0002, 1,STR0003, 1, 2, 1, "",1 } //"Zebrado"###"Administracao"
Private titulo   := STR0004 //"Inventแrio Corporativo de Gases do Efeito Estufa."
Private ntipo    := 0
Private nLastKey := 0
Private oPrintOS//Variavel do relatorio
Private cPerg :="SGR170"

//Varํaveis para verificar tamanho dos campos
Private nTamTAF := If((TAMSX3("TAF_CODNIV")[1]) < 1,3 ,(TAMSX3("TAF_CODNIV")[1]))
Private nTamTD1 := If((TAMSX3("TD1_CODIGO")[1]) < 1,10,(TAMSX3("TD1_CODIGO")[1]))
Private nTamTD0 := If((TAMSX3("TD0_CODIGO")[1]) < 1,10,(TAMSX3("TD0_CODIGO")[1]))
Private nTamSB1 := If((TAMSX3("B1_COD")[1]) < 1,15,(TAMSX3("B1_COD")[1]))
Private nTamSAH := If((TAMSX3("AH_UNIMED")[1]) < 1,2,(TAMSX3("AH_UNIMED")[1]))

//Verifica se o update do GEE esta aplicado
If !SGAUPDGEE()
	Return .F.
Endif

If !SGAUPDCAMP()
	Return .F.
EndIf

//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณ Envia controle para a funcao SETPRINT                        ณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
pergunte(cPerg,.F.)
wnrel:=SetPrint(cString,wnrel,cPerg,titulo,cDesc1,cDesc2,cDesc3,.F.,"")

If nLastKey == 27
   Set Filter to
   Return
Endif

SetDefault(aReturn,cString)

If nLastKey == 27
   Set Filter to
   Return
Endif

Processa({|lEnd| SGR170IMP()}) // MONTE TELA PARA ACOMPANHAMENTO DO PROCESSO.

//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณRetorna conteudo de variaveis padroes       ณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
NGRETURNPRM(aNGBEGINPRM)
Return .T.

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณSGR170IMP บAutor  ณRoger Rodrigues     บ Data ณ  30/08/10   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณRealiza impressao do relatorio                              บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณSGAR170                                                     บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function SGR170IMP()
Local i
Local nTotalEqCO2 := 0
Local lImp := .F.
Local cTempPar := ""
Local cTotalCO2 := ""
//Variaveis de verificacao de chave
Local cCodNiv  := "", cCodEsc := "", cTipFon := ""
Local cCodFon := "", cCodPro := "", cDesEsc := ""
Private cLocalizacao := ""

//Variaveis do relatorio
Private oPrintGas
Private Lin := 9999
Private nPagNum := 0
Private lFirst := .T.

//Definicao de Fontes
Private cFonte := "Verdana"
Private oFont13	 := TFont():New(cFonte,13,13,,.F.,,,,.F.,.F.)
Private oFont12	 := TFont():New(cFonte,12,12,,.F.,,,,.F.,.F.)
Private oFont11	 := TFont():New(cFonte,11,11,,.F.,,,,.F.,.F.)
Private oFont10	 := TFont():New(cFonte,10,10,,.F.,,,,.F.,.F.)
Private oFont09	 := TFont():New(cFonte,09,09,,.F.,,,,.F.,.F.)
Private oFont08	 := TFont():New(cFonte,08,08,,.F.,,,,.F.,.F.)
Private oFont07	 := TFont():New(cFonte,06,06,,.F.,,,,.F.,.F.)
Private oFont10b := TFont():New(cFonte,10,10,,.T.,,,,.F.,.F.)

//Variaveis para criacao de Arquivo Temporario
Private aDBF := {}
Private cTRBGAS := GetNextAlias()//Arquivo com O.S.
Private oTempTRB

//Inicializa Objeto
oPrintGas := TMSPrinter():New(OemToAnsi(titulo))
oPrintGas:Setup()
oPrintGas:SetLandscape()//Paisagem

//Cria Arquivo temporario
aDBF := {}
aAdd(aDBF, {"TD9_CODNIV","C",nTamTAF, 0})
aAdd(aDBF, {"TD1_ESCOPO","C",1		, 0})
aAdd(aDBF, {"TD1_TIPFON","C",1		, 0})
aAdd(aDBF, {"TD9_CODFON","C",nTamTD1, 0})
aAdd(aDBF, {"TD1_DESCRI","C",40		, 0})
aAdd(aDBF, {"PRODUTO"	,"C",nTamSB1, 0})//Pode ser o Codigo do Produto ou o Grupo
aAdd(aDBF, {"DESCPROD"	,"C",40		, 0})//Descricao do Produto ou do Grupo
aAdd(aDBF, {"TDA_CODGAS","C",nTamTD0, 0})
aAdd(aDBF, {"TD0_UNIMED","C",nTamSAH, 0})
aAdd(aDBF, {"TOTGERADO"	,"N",15		, 5})
aAdd(aDBF, {"TD0_PAG"  	,"N",15     , 5})

oTempTRB := FWTemporaryTable():New( cTRBGAS, aDBF )
oTempTRB:AddIndex( "1", {"TD9_CODNIV","TD1_ESCOPO","TD1_TIPFON","TD9_CODFON","PRODUTO","TDA_CODGAS"} )
oTempTRB:AddIndex( "2", {"TD9_CODNIV","TD1_ESCOPO","TD1_TIPFON","TD1_DESCRI","PRODUTO","TDA_CODGAS"} )
oTempTRB:Create()

//Ordena parametros De/Ate Localiza็ใo
If MV_PAR03 > MV_PAR04
	cTempPar  := MV_PAR03
	MV_PAR03 := MV_PAR04
	MV_PAR04 := cTempPar
EndIf

Processa({ || SGR170TRB() }, STR0014) //"Processando Ocorr๊ncias do GEE"

//Se existirem registros, imprime parametros e comeca relatorio
If (cTRBGAS)->(RecCount()) > 0
	Somalinha()
Endif
dbSelectArea(cTRBGAS)
dbSetOrder(2)
dbGoTop()
ProcRegua((cTRBGAS)->(RecCount()))
While !eof()
	cCodNiv := ""
	//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
	//ณImprime Localizacao das Ocorrencias         ณ
	//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
	If (cTRBGAS)->TD9_CODNIV <> cCodNiv
		lFirst := .T.
		cCodNiv := (cTRBGAS)->TD9_CODNIV
		cCodEsc := ""
		cLocalizacao := AllTrim(NGLocComp((cTRBGAS)->TD9_CODNIV,"2","SGA"))
		dbSelectArea(cTRBGAS)
		While !eof() .and. (cTRBGAS)->TD9_CODNIV == cCodNiv
			//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
			//ณImprime Escopo das Fontes Geradoras         ณ
			//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
			If (cTRBGAS)->TD1_ESCOPO <> cCodEsc
				Somalinha(,Empty(cCodEsc))

				cCodEsc := (cTRBGAS)->TD1_ESCOPO
				cTipFon := ""
				lFirst := .T.
				lImp := .T.
				oPrintGas:Say(Lin, 60, (cTRBGAS)->TD1_ESCOPO, oFont08)
				dbSelectArea(cTRBGAS)
				While !eof() .and. (cTRBGAS)->(TD9_CODNIV+TD1_ESCOPO) == cCodNiv+cCodEsc
					//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
					//ณImprime Tipo das Fontes Geradoras           ณ
					//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
					If (cTRBGAS)->TD1_TIPFON <> cTipFon
						cTipFon := (cTRBGAS)->TD1_TIPFON
						cCodFon := ""
						If (cTRBGAS)->TD1_ESCOPO == "1"
							If (cTRBGAS)->TD1_TIPFON == "1"
								cDesEsc := "Estacionแrios" //"Estacionแrios"
							ElseIf (cTRBGAS)->TD1_TIPFON == "2"
								cDesEsc := "M๓vel" //"M๓vel"
							ElseIf (cTRBGAS)->TD1_TIPFON == "3"
								cDesEsc := "Processo" //"Processo"
							ElseIf (cTRBGAS)->TD1_TIPFON == "4"
								cDesEsc := "Fugitiva" //"Fugitiva"
							ElseIf (cTRBGAS)->TD1_TIPFON == "5"
								cDesEsc := "Agrํcola" //"Agrํcola"
							Endif
						ElseIf (cTRBGAS)->TD1_ESCOPO == "2"
							cDesEsc := "Aquisi็ใo de Energia" //"Aquisi็ใo de Energia"
						Else
							cDesEsc := "Emiss๕es Biomassa" //"Emiss๕es Biomassa"
						Endif
						//So pula de linha se mudar de chave
						If !lFirst
							Somalinha()
							lFirst := .T.
						Endif
						oPrintGas:Say(Lin, 220, Upper(cDesEsc), oFont08)
						dbSelectArea(cTRBGAS)
						While !eof() .and. (cTRBGAS)->(TD9_CODNIV+TD1_ESCOPO+TD1_TIPFON) == cCodNiv+cCodEsc+cTipFon
							//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
							//ณImprime Fonte Geradora                      ณ
							//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
							If (cTRBGAS)->TD9_CODFON <> cCodFon
								cCodFon := (cTRBGAS)->TD9_CODFON
								cCodPro := ""
								//So pula de linha se mudar de chave
								If !lFirst
									Somalinha()
									lFirst := .T.
								Endif
								oPrintGas:Say(Lin, 630, (cTRBGAS)->TD1_DESCRI, oFont08)
								dbSelectArea(cTRBGAS)
								While !eof() .and. (cTRBGAS)->(TD9_CODNIV+TD1_ESCOPO+TD1_TIPFON+TD9_CODFON) == cCodNiv+cCodEsc+cTipFon+cCodFon
									//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
									//ณImprime Produto ou Grupo de Produtos        ณ
									//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
									If (cTRBGAS)->PRODUTO <> cCodPro
										cCodPro := (cTRBGAS)->PRODUTO
										//So pula de linha se mudar de chave
										If !lFirst
											Somalinha()
											lFirst := .T.
										Endif
										oPrintGas:Say(Lin, 1390, Trim((cTRBGAS)->DESCPROD), oFont08)
										dbSelectArea(cTRBGAS)
										While !eof() .and. (cTRBGAS)->(TD9_CODNIV+TD1_ESCOPO+TD1_TIPFON+TD9_CODFON+PRODUTO) == ;
															cCodNiv+cCodEsc+cTipFon+cCodFon+cCodPro
											IncProc()
											//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
											//ณImprime Gases Gerados                       ณ
											//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
											If !lFirst
												Somalinha()
											Else
												lFirst := .F.
											Endif
											oPrintGas:Say(lin,1950,(cTRBGAS)->TDA_CODGAS,oFont08) //Cod Gแs

											oPrintGas:Say(lin,2210,TransForm((cTRBGAS)->TOTGERADO,"@E 9,999,999,999,999.9999"),oFont08) //Qntidade Emitida

											oPrintGas:Say(lin,2560,(cTRBGAS)->TD0_UNIMED,oFont08)//Un.

											cTotalCO2 := (cTRBGAS)->TOTGERADO * (cTRBGAS)->TD0_PAG  //Equivalente CO2
											nTotalEqCO2 += cTotalCO2    //Totalizador
											oPrintGas:Say(lin,2625,TransForm(cTotalCO2,"@E 9,999,999,999,999.9999"),oFont08) //Imprime Equivalente CO2

											oPrintGas:Line(lin+40, 2240	, lin+40, 3060)

											//Imprime colunas da linha
											oPrintGas:Line(lin, 50	, lin+40, 50)
											oPrintGas:Line(lin, 210	, lin+40, 210)
											oPrintGas:Line(lin, 620	, lin+40, 620)
											oPrintGas:Line(lin, 1380, lin+40, 1380)
											oPrintGas:Line(lin, 1940, lin+40, 1940)
											oPrintGas:Line(lin, 2240, lin+40, 2240)
											oPrintGas:Line(lin, 2550, lin+40, 2550)
											oPrintGas:Line(lin, 2630, lin+40, 2630)
											oPrintGas:Line(lin, 3060, lin+40, 3060)
											dbSelectArea(cTRBGAS)
											dbSkip()

										End
										oPrintGas:Line(lin+40, 1400	, lin+40, 1400)
									Else
										dbSelectArea(cTRBGAS)
										dbSkip()
									Endif
								End
								oPrintGas:Line(lin+40, 580	, lin+40, 3060)
							Else
								dbSelectArea(cTRBGAS)
								dbSkip()
							Endif
						End
						oPrintGas:Line(lin+40, 210	, lin+40, 3060)
					Else
						dbSelectArea(cTRBGAS)
						dbSkip()
					Endif
				End
				oPrintGas:Line(lin+40, 50	, lin+40, 3060)
			Else
				dbSelectArea(cTRBGAS)
				dbSkip()
			Endif
		End
	Else
		dbSelectArea(cTRBGAS)
		dbSkip()
	Endif

End

If lImp

	//Realiza a impessใo do Totalizador
	Somalinha()//Salta a linha
	oPrintGas:Line(lin+40, 2480	, lin+40, 3060)//Imprime uma linha da 1ช coluna at้ a 3ช coluna
	Somalinha()
	oPrintGas:Say(lin,2490,STR0052,oFont10b)//Imprime o titulo //499999449950
	oPrintGas:Say(lin,2610,TransForm(nTotalEqCO2,"@E 9,999,999,999,999,999.9999"),oFont08)//Imprime o valor
	oPrintGas:Line(lin, 2480, lin+40, 2480)//Imprime 1ช coluna (linha)
	oPrintGas:Line(lin, 2600, lin+40, 2600)//Imprime 2ช coluna (linha)
	oPrintGas:Line(lin, 3060, lin+40, 3060)//Imprime 3ช coluna (linha)
	oPrintGas:Line(lin+40, 2480	, lin+40, 3060)//Imprime uma linha da 1ช coluna at้ a 3ช coluna

	oPrintGas:EndPage()
	//Imprime na Tela ou Impressora
	If aReturn[5] == 1
		oPrintGas:Preview()
	Else
		oPrintGas:Print()
	EndIf
Else
	MsgStop(STR0020,STR0021) //"Nใo existem dados para montar o relat๓rio."###"Aten็ใo"
Endif
MS_FLUSH()

//Deleta arquivo temporแrio e restaura area
oTempTRB:Delete()
dbSelectArea("TD9")

Return .T.

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณSomalinha บAutor  ณRoger Rodrigues     บ Data ณ  30/08/10   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณRealiza salto de linha e imprime cabecalho da pagina        บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณSGAR170                                                     บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function Somalinha(nLin, lCabec)
Local cLogo, i
Default nLin := 40
Default lCabec := .F.
Lin += nLin

If Lin > 2300 .or. lCabec
	If lCabec
		If ((180+(MLCOUNT(cLocalizacao, 110)-1)*60)+Lin) > 2300
			Lin := 9999
		EndIf
	Endif
	If Lin > 2300
		//Se for troca de pagina imprime linha
		If !lCabec .and. nPagNum > 0
			oPrintGas:Line(lin, 50, lin, 3060)
		Endif
		lCabec := .F.
		oPrintGas:EndPage()
		//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
		//ณInicia pagina e imprime cabe็alho           ณ
		//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
		oPrintGas:StartPage()
		oPrintGas:Line(50, 0, 50, 3060)
		oPrintGas:Line(51, 0, 51, 3060)
		oPrintGas:Line(52, 0, 52, 3060)
		cLogo := If(FindFunction("NGLOCLOGO"),NGLocLogo(),"")//Retorna arquivo de logo a ser utilizado
		//Imprime logo da empresa
		If File(cLogo)
			oPrintGas:SayBitMap(55,10,cLogo,325,125)
		Endif
		oPrintGas:Say(200,10,"SIGA/SGAR170",oFont10)
		oPrintGas:Say(250,10,STR0022+AllTrim(SM0->M0_NOME)+STR0023+SM0->M0_FILIAL,oFont10) //"Empresa: "###"/ Filial: "
		oPrintGas:Say(145,850,STR0024,oFont11) //"INVENTมRIO CORPORATIVO DE GASES DE EFEITO ESTUFA"
		If nPagNum > 0
			oPrintGas:Say(150,2600,STR0025+Alltrim(STR(nPagNum,4)),oFont10) //"Folha....:"
		Endif
		oPrintGas:Say(200,2600,STR0026+AllTrim(DTOC(dDatabase)),oFont10) //"Emissใo:"
		oPrintGas:Say(250,2600,STR0027+Time(),oFont10) //"Hora.....:"
		oPrintGas:Line(300, 0, 300, 5000)
		oPrintGas:Line(301, 0, 301, 5000)
		oPrintGas:Line(302, 0, 302, 5000)
		Lin := 330
	Endif
	//Se primeira pagina, imprime parametros
	If nPagNum == 0 .and. !lCabec
		SGR170PAR()
	Else
		If lCabec
			Lin += 80
		Endif
		oPrintGas:Line(lin, 50, lin, 3060)
		oPrintGas:Line(lin, 50, lin+60, 50)
		oPrintGas:Line(lin, 3060, lin+60, 3060)
		oPrintGas:Say(Lin+10, 60, STR0028, oFont10b) //"Local de Consumo:"
		For i:=1 to MLCOUNT(cLocalizacao, 110)
			If i!= 1
				Lin += 60
				oPrintGas:Line(lin, 50, lin+60, 50)
				oPrintGas:Line(lin, 3060, lin+60, 3060)
			Endif
			oPrintGas:Say(Lin+10, 450, MemoLine(cLocalizacao,110,i), oFont10b)
		Next i
		Lin += 60
		oPrintGas:Box(lin,50,lin+60,3060)
		oPrintGas:Say(lin+10,60,STR0029,oFont10b) //"Escopo"
		oPrintGas:Line(lin, 210, lin+60, 210)
		oPrintGas:Say(lin+10,220,STR0030,oFont10b) //"Tipo Fonte"
		oPrintGas:Line(lin, 620, lin+60, 620)
		oPrintGas:Say(lin+10,630,STR0031,oFont10b) //"Fonte Emissใo"
		oPrintGas:Line(lin, 1380, lin+60, 1380) //1140
		If MV_PAR07 == 1
			oPrintGas:Say(Lin+10, 1390, STR0032, oFont10b) //"Grupo Gerador"
		Else
			oPrintGas:Say(Lin+10, 1390, STR0033, oFont10b) //"Produto Gerador"
		Endif
		oPrintGas:Line(lin, 1940, lin+60, 1940) //2230
		oPrintGas:Say(lin+10,1950,STR0034,oFont10b) //"Gแs" 2240
		oPrintGas:Line(lin, 2240, lin+60, 2240)             //2530
		oPrintGas:Say(lin+10,2250,STR0035,oFont10b) //"Qtde. Emitida"
		oPrintGas:Line(lin, 2550, lin+60, 2550)
		oPrintGas:Say(lin+10,2560,STR0036,oFont10b) //"Un."
		oPrintGas:Line(lin, 2630, lin+60, 2630)
		oPrintGas:Say(lin+10,2640,STR0051,oFont10b)//"Equivalente CO2"
		oPrintGas:Line(lin, 3060, lin+60, 3060)
		Lin += 60

	Endif
	If !lCabec
		//Incrementa Numero de Pแgina
		nPagNum ++
	Endif
Endif

Return .T.

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณSGR170TRB บAutor  ณRoger Rodrigues     บ Data ณ  30/08/10   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณCarrega arquivo temporario com os gases gerados             บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณSGR170TRB                                                   บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function SGR170TRB()
Local cEscopo := "", cTipFon := "", cFonDesc := ""
Local cProduto:= "", cProDesc:= ""

//Percorre ocorr๊ncias de residuo
dbSelectArea("TD9")
dbSetOrder(3)
ProcRegua(TD9->(RecCount()))
dbSeek(xFilial("TD9")+DTOS(MV_PAR01),.T.)
While !eof() .and. xFilial("TD9")+DTOS(MV_PAR02) >= TD9->TD9_FILIAL+DTOS(TD9->TD9_DATA)
	IncProc()
	//Verifica se a Data esta nos parametros
	If TD9->TD9_DATA < MV_PAR01 .OR. TD9->TD9_DATA > MV_PAR02
		dbSelectArea("TD9")
		dbSkip()
		Loop
	Endif
	//Verifica se a localizacao esta nos parametros
	If TD9->TD9_CODNIV < MV_PAR03 .OR. TD9->TD9_CODNIV > MV_PAR04
		dbSelectArea("TD9")
		dbSkip()
		Loop
	Endif
	//Verifica se a fonte esta nos parametros
	If TD9->TD9_CODFON < MV_PAR05 .OR. TD9->TD9_CODFON > MV_PAR06
		dbSelectArea("TD9")
		dbSkip()
		Loop
	Endif
	//Carrega variaveis de fonte
	cEscopo := ""
	cTipFon := ""
	dbSelectArea("TD1")
	dbSetOrder(1)
	If dbSeek(xFilial("TD1")+TD9->TD9_CODFON)
		cEscopo := TD1->TD1_ESCOPO
		cTipFon := TD1->TD1_TIPFON
		cFonDesc:= Substr(TD1->TD1_DESCRI,1,40)
	Endif
	//Variaveis de Produto
	cProduto:= ""
	cProDesc:= ""
	dbSelectArea("SB1")
	dbSetOrder(1)
	If dbSeek(xFilial("SB1")+TD9->TD9_CODPRO)
		//Se Considerar por grupos de produto
		If MV_PAR07 == 1
			dbSelectArea("SBM")
			dbSetOrder(1)
			If dbSeek(xFilial("SBM")+SB1->B1_GRUPO)
				cProduto := Padr(SBM->BM_GRUPO, nTamSB1)
				cProDesc := Substr(SBM->BM_DESC,1,40)
			Endif
		Else
			cProduto := SB1->B1_COD
			cProDesc := Substr(SB1->B1_DESC,1,40)
		Endif
	Endif

	//Se nao existir grupo de produto para o Produto nao considera
	If !Empty(cProduto)
		//Percorre gases gerados pela ocorrencia
		dbSelectArea("TDA")
		dbSetOrder(1)
		dbSeek(xFilial("TDA")+TD9->TD9_CODIGO)
		While !eof() .and. xFilial("TDA")+TD9->TD9_CODIGO == TDA->TDA_FILIAL+TDA->TDA_CODOCO
			dbSelectArea(cTRBGAS)
			dbSetOrder(1)
			If dbSeek(TD9->TD9_CODNIV+cEscopo+cTipFon+TD9->TD9_CODFON+cProduto+TDA->TDA_CODGAS)
				RecLock(cTRBGAS, .F.)
				(cTRBGAS)->TOTGERADO += TDA->TDA_GERADO
			Else
				RecLock(cTRBGAS, .T.)
				(cTRBGAS)->TOTGERADO := TDA->TDA_GERADO
				(cTRBGAS)->TD9_CODNIV:= TD9->TD9_CODNIV
				(cTRBGAS)->TD1_ESCOPO:= cEscopo
				(cTRBGAS)->TD1_TIPFON:= cTipFon
				(cTRBGAS)->TD9_CODFON:= TD9->TD9_CODFON
				(cTRBGAS)->TD1_DESCRI:= Upper(cFonDesc)
				(cTRBGAS)->PRODUTO   := cProduto
				(cTRBGAS)->DESCPROD  := Upper(cProDesc)
				(cTRBGAS)->TDA_CODGAS:= TDA->TDA_CODGAS
				(cTRBGAS)->TD0_UNIMED:= NGSEEK("TD0",TDA->TDA_CODGAS,1,"TD0->TD0_UNIMED")
				(cTRBGAS)->TD0_PAG   := NGSEEK("TD0",TDA->TDA_CODGAS,1,"TD0->TD0_PAG")
			Endif
			MsUnlock(cTRBGAS)
			dbSelectArea("TDA")
			dbSkip()
		End
	Endif
	dbSelectArea("TD9")
	dbSkip()
End

Return .T.

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณSGR170PAR บAutor  ณRoger Rodrigues     บ Data ณ  30/08/10   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณImprime Pagina de parametros do relatorio                   บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณSGAR170                                                     บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function SGR170PAR()

Somalinha(70)
oPrintGas:Line(Lin, 0, Lin, 5000)
oPrintGas:Line(Lin+1, 0, Lin+1, 5000)
oPrintGas:Line(Lin+2, 0, Lin+2, 5000)
Somalinha()
oPrintGas:Say(Lin,10,STR0037,oFont10) //"Pergunta 01 : De Data  ?"
oPrintGas:Say(Lin,650,DTOC(MV_PAR01),oFont10)
Somalinha()
oPrintGas:Say(Lin,10,STR0038,oFont10) //"Pergunta 02 : At้ Data ?"
oPrintGas:Say(Lin,650,DTOC(MV_PAR02),oFont10)
Somalinha()
oPrintGas:Say(Lin,10,STR0039,oFont10) //"Pergunta 03 : De Local ?"
oPrintGas:Say(Lin,650,MV_PAR03,oFont10)
Somalinha()
oPrintGas:Say(Lin,10,STR0040,oFont10) //"Pergunta 04 : At้ Local?"
oPrintGas:Say(Lin,650,MV_PAR04,oFont10)
Somalinha()
oPrintGas:Say(Lin,10,STR0041,oFont10) //"Pergunta 05 : De Fonte ?"
oPrintGas:Say(Lin,650,MV_PAR05,oFont10)
Somalinha()
oPrintGas:Say(Lin,10,STR0042,oFont10) //"Pergunta 06 : At้ Fonte?"
oPrintGas:Say(Lin,650,MV_PAR06,oFont10)
Somalinha()
oPrintGas:Say(Lin,10,STR0043,oFont10) //"Pergunta 07 : Agrupar  ?"
oPrintGas:Say(Lin,650,If(MV_PAR07 == 1,STR0012,STR0013),oFont10) //"Grupo Produtos"###"Produtos"
Somalinha(100)
oPrintGas:Line(Lin, 0, Lin, 5000)
oPrintGas:Line(Lin+1, 0, Lin+1, 5000)
oPrintGas:Line(Lin+2, 0, Lin+2, 5000)

Lin := 9999
Return .T.