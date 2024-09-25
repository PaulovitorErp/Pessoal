#include "sgaa440.ch"
#include "Protheus.ch"

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³SGAA440   ºAutor  ³Roger Rodrigues     º Data ³  10/05/10   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Monta Browse para aprovação em lote de objetivos            º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³SIGASGA                                                     º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function SGAA440()

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Armazena variaveis p/ devolucao (NGRIGHTCLICK) 	   					  ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	Local aNGBEGINPRM := NGBEGINPRM()
	Local aCpsTBH := APBuildHeader('TBH')
	Local cCampo  := ''
	Local aTamCpo := {}
	Local cNivCpo := ''
	Local nCps    := 0

	Private cCadastro := STR0001 //"Aprovação em Lote de Objetivos"
	Private cAliasTBH := GetNextAlias()//Alias Temporario
	Private aDBFTBH := {}, aFieldsTBH := {}, aVirtTBH := {}
	Private cMarca := GetMark()//Define marcacao
	Private aLegBrw := {}//Array de Legenda
	Private aRotina := {}
	Private oTempTRB

	aAdd( aRotina,{ STR0002,"SGA440PESQ",0,1 } ) //"Pesquisar"
	aAdd( aRotina,{ STR0003,"SGA440VIS" ,0,2 } ) //"Visualizar"
	aAdd( aRotina,{ STR0004,"SGA440APR" ,0,4 } ) //"Aprovar"
	aAdd( aRotina,{ STR0005,"SG300LEG"  ,0,5 } ) //"Legenda"

	SetAltera(.T.)//Utilizado caso exista algum Ini. Browse

	//Define campos do arquivo temporario
	aAdd(aDBFTBH,{"OK"				,"C"	,2	,0	})
	aAdd(aDBFTBH,{"TBH_CODOBJ"	,"C"	,TAMSX3("TBH_CODOBJ")[1]	,TAMSX3("TBH_CODOBJ")[2]	})
	aAdd(aDBFTBH,{"TBH_DESCRI" 	,"C"	,TAMSX3("TBH_DESCRI")[1]	,TAMSX3("TBH_DESCRI")[2]	})
	aAdd(aDBFTBH,{"TBH_PRAZO"		,"D"	,TAMSX3("TBH_PRAZO")[1]	,TAMSX3("TBH_PRAZO")[2]	})

	aAdd(aFieldsTBH, {"OK", Nil,"", "" })
	aAdd(aFieldsTBH, {"TBH_CODOBJ"	,Nil,RetTitle("TBH_CODOBJ")	, PesqPict("TBH", "TBH_CODOBJ")	})
	aAdd(aFieldsTBH, {"TBH_DESCRI"	,Nil,RetTitle("TBH_DESCRI")	, PesqPict("TBH", "TBH_DESCRI")	})
	aAdd(aFieldsTBH, {"TBH_PRAZO"		,Nil,RetTitle("TBH_PRAZO")	, PesqPict("TBH", "TBH_PRAZO")	})

	//Carrega somente os campos que serao visualizados no browse

	For nCps := 1 To Len(aCpsTBH)

		cCampo  := Alltrim(aCpsTBH[ nCps, 2 ])
		aTamCpo := TamSX3( cCampo )
		cTipo   := GetSx3Cache( cCampo, 'X3_TIPO')
		cBox    := GetSx3Cache( cCampo, 'X3_CBOX')

		If GetSx3Cache( cCampo, 'X3_BROWSE') == 'S' .And. ;
			aScan( aDBFTBH,{ |x| Trim(Upper(x[1])) == cCampo } ) == 0

			aAdd( aDBFTBH, { cCampo, AllTrim(cTipo), If(!Empty(cBox), 20, aTamCpo[1]), aTamCpo[2] } ) //Campos do TRB

			aAdd( aFieldsTBH, { cCampo, Nil, RetTitle(cCampo), PesqPict("TBH",cCampo) } ) //Campos do MarkBrowse

			If GetSx3Cache( cCampo, 'X3_CONTEXT') == 'V' //Se o campo for virtual guarda o Ini. Browse
				aAdd( aVirtTBH, { cCampo, AllTrim( GetSx3Cache( cCampo, 'X3_INIBRW' ) ) } )
			EndIf

		EndIf

	Next nCps

	//Cria Arquivo temporario
	oTempTRB := FWTemporaryTable():New( cAliasTBH, aDBFTBH )
	oTempTRB:AddIndex( "1", {"TBH_CODOBJ"} )
	oTempTRB:AddIndex( "2", {"TBH_DESCRI"} )
	oTempTRB:AddIndex( "3", {"OK"} )
	oTempTRB:Create()

	//Carrega Arquivo temporario
	Processa({|lEnd | SGA440TRB()},STR0006,STR0007) //"Aguarde..."###"Processando Registros..."

	//Legenda
	aLegBrw := {	{"(cAliasTBH)->TBH_PRAZO < dDataBase", "BR_VERMELHO",STR0008},; //"Atrasada"
					{"(cAliasTBH)->TBH_PRAZO >= dDataBase","BR_VERDE",STR0009}} //"Em dia"

	//Cria MarkBrowse
	MarkBrow(cAliasTBH,"OK","",aFieldsTBH,,cMarca,"SGA440MALL()",,,,,,,,aLegBrw)

	//Deleta Arquivo temporario
	oTempTRB:Delete()

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Devolve variaveis armazenadas (NGRIGHTCLICK) 						  ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	NGRETURNPRM(aNGBEGINPRM)

Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³SGA440TRB ºAutor  ³Roger Rodrigues     º Data ³  10/05/10   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Carrega TRB com objetivos pendentes a aprovação             º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³SGAA440                                                     º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function SGA440TRB()

	Local i,nPos
	Local lFlag	:= NGCADICBASE('TBH_FLAG','A','TBH',.F.)

	//Limpa Tabela temporaria
	dbSelectArea(cAliasTBH)
	ZAP

	//Percorre Objetivos
	dbSelectArea("TBH")
	dbSetOrder(1)
	dbGoTop()
	ProcRegua(TBH->(RecCount()))
	While !eof() .and. TBH->TBH_FILIAL == xFilial("TBH")
		IncProc()
		//Filtra somente os pendentes
		If TBH->TBH_SITUAC <> "1"
			dbSelectArea("TBH")
			dbSkip()
			Loop
		Endif
		If lFlag .And. ( ( nModulo == 35 .And. TBH->TBH_FLAG == "1" ) .Or. ( nModulo == 56 .And. TBH->TBH_FLAG == "2" ) )
			dbSelectArea("TBH")
			dbSkip()
			Loop
		EndIf
		//Grava registro no arquivo temporario
		RecLock(cAliasTBH,.T.)
		For i:=1 to Len(aDBFTBH)
			If aDBFTBH[i][1] == "OK"
				(cAliasTBH)->OK := Space(2)
			ElseIf aDBFTBH[i][1] == "TBH_PRIORI"
				(cAliasTBH)->TBH_PRIORI := TBH->TBH_PRIORI+"="+NGRETSX3BOX("TBH_PRIORI",TBH->TBH_PRIORI)
			ElseIf aDBFTBH[i][1] == "TBH_SITUAC"
				(cAliasTBH)->TBH_SITUAC := TBH->TBH_SITUAC+"="+NGRETSX3BOX("TBH_SITUAC",TBH->TBH_SITUAC)
			Else
				//Verifica se o campo eh virtual
				If (nPos := aScan(aVirtTBH,{|x| Trim(Upper(x[1])) == Trim(Upper(aDBFTBH[i][1]))}) ) > 0
					//Executa Ini. Browse
					If !Empty(aVirtTBH[nPos][2])
						&("(cAliasTBH)->"+aDBFTBH[i][1]) := &(aVirtTBH[nPos][2])
					Else
						If aDBFTBH[i][2] == "C"
							&("(cAliasTBH)->"+aDBFTBH[i][1]) := ""
						ElseIf aDBFTBH[i][2] == "D"
							&("(cAliasTBH)->"+aDBFTBH[i][1]) := STOD("")
						ElseIf aDBFTBH[i][2] == "N"
							&("(cAliasTBH)->"+aDBFTBH[i][1]) := 0
						Endif
					Endif
				Else
					//Grava normalmente
					&("(cAliasTBH)->"+aDBFTBH[i][1]) := &("TBH->"+aDBFTBH[i][1])
				Endif
			Endif
		Next i
		MsUnlock(cAliasTBH)
		dbSelectArea("TBH")
		dbSkip()
	End
	dbSelectArea(cAliasTBH)
	dbGoTop()

Return .T.

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³SGA440VIS ºAutor  ³Roger Rodrigues     º Data ³  11/05/10   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Chama tela para visualização do objetivo                    º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³SGAA440                                                     º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function SGA440VIS(cAlias, nRecno, nOpcx)

	//Posiciona no Objetivo
	dbSelectArea("TBH")
	dbSetOrder(1)
	dbSeek(xFilial("TBH")+(cAliasTBH)->TBH_CODOBJ)

	//Chama tela de visualizacao
	SG300CAD("TBH", TBH->(Recno()), 2)

Return .T.

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³SGA440PESQºAutor  ³Roger Rodrigues     º Data ³  11/05/10   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Monta tela para pesquisa                                    º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³SGAA440                                                     º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function SGA440PESQ()

	local oDlgPesq, oOrdem, oChave, oBtOk, oBtCan, oBtPar
	Local cOrdem	:= RetTitle("TBH_CODOBJ")
	Local cChave	:= Space(TAMSX3("TBH_DESCRI")[1])
	Local aOrdens	:= {}
	Local nOrdem := 1
	Local nOpcA := 0

	//Array com indices
	aOrdens := {RetTitle("TBH_CODOBJ"),RetTitle("TBH_DESCRI")}

	//Define Tela de Pesquisa
	Define msDialog oDlgPesq Title STR0002 From 00,00 To 100,500 Pixel //"Pesquisar"

	@ 005, 005 ComboBox oOrdem Var cOrdem Items aOrdens Size 210,08 Pixel OF oDlgPesq On Change nOrdem := oOrdem:nAt
	@ 020, 005 MsGet oChave Var cChave Size 210,08 of oDlgPesq Pixel

	Define sButton oBtOk  From 05,218 Type 1 Action (nOpcA := 1, oDlgPesq:End()) Enable of oDlgPesq pixel
	Define sButton oBtCan From 20,218 Type 2 Action (nOpcA := 0, oDlgPesq:End()) Enable of oDlgPesq pixel
	Define sButton oBtPar From 35,218 Type 5 When .F. of oDlgPesq pixel

	Activate MsDialog oDlgPesq Center

	If nOpca == 1
		//Posiciona no registro
		cChave := AllTrim(cChave)
		DbSelectArea(cAliasTBH)
		dbSetOrder(nOrdem)
		DbSeek(cChave)
	EndIf

	DbSelectArea(cAliasTBH)
	DbSetOrder(1)

Return .T.

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³SGA440MALLºAutor  ³Roger Rodrigues     º Data ³  11/05/10   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Inverte marcacao de todo o MarkBrowse                       º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³SGAA440                                                     º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function SGA440MALL()

	Local nRecno := Recno()//Guarda registro posicionado

	//Inverte a marcacao dos registros
	dbSelectarea(cAliasTBH)
	dbGoTop()
	While !Eof()
	dbSelectArea(cAliasTBH)
	RecLock(cAliasTBH,.F.)
	(cAliasTBH)->OK := If(IsMark("OK",cMarca),Space(2),cMarca)
	MsUnlock(cAliasTBH)
	dbSkip()
	End

	//Reposiciona no Registro
	dbGoTo(nRecno)

Return .T.

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³SGA440APR ºAutor  ³Roger Rodrigues     º Data ³  11/05/10   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Aprova os objetivos marcados                                º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³SGAA440                                                     º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function SGA440APR()

	Local lAprovou := .F.
	Local aArea := GetArea()

	//Verifica se existe algum registro marcado
	dbSelectArea(cAliasTBH)
	dbSetOrder(3)
	dbGoTop()
	If Empty((cAliasTBH)->OK)
		MsgStop(STR0011, STR0012) //"Não existe nenhum objetivo marcado."###"Atenção"
		RestArea(aArea)
		Return .F.
	Endif

	If MsgYesNo(STR0013,STR0012) //"Esta operação irá aprovar todos os objetivos marcados. Deseja continuar?"###"Atenção"
		//Aprova objetivos
		Processa({|lEnd | SGA440PROC()},STR0006,STR0007) //"Aguarde..."###"Processando Registros..."
	Endif
	dbSelectArea(cAliasTBH)
	dbSetOrder(1)
	dbGoTop()

Return .T.

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³SGA440PROCºAutor  ³Roger Rodrigues     º Data ³  11/05/10   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Aprova os objetivos marcados                                º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³SGAA440                                                     º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function SGA440PROC()

	Local lRet := .F.

	//Percorre arquivo temporario para aprovar marcados
	dbSelectArea(cAliasTBH)
	dbSetOrder(1)
	dbGoTop()
	ProcRegua((cAliasTBH)->(RecCount()))
	While !Eof()
		IncProc()
		If !Empty((cAliasTBH)->OK)
			//Aprova objetivos
			dbSelectArea("TBH")
			dbSetOrder(1)
			If dbSeek(xFilial("TBH")+(cAliasTBH)->TBH_CODOBJ)
				RecLock("TBH",.f.)
				TBH->TBH_SITUAC := "2"
				MsUnLock("TBH")
				lRet := .T.
				//Tira registro do TRB
				dbSelectArea(cAliasTBH)
				RecLock(cAliasTBH,.F.)
				dbDelete()
				MsUnlock(cAliasTBH)
			EndIf
		Endif
		dbSelectArea(cAliasTBH)
		dbSkip()
	End

	If lRet
		MsgInfo(STR0014,STR0012) //"Objetivos aprovados com sucesso."###"Atenção"
	Endif

Return lRet