#INCLUDE "MNTA740.ch"
#include "Protheus.ch"

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³ MNTA740  ³ Autor ³ Rafael Diogo Richter  ³ Data ³20/03/2007³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³Programa para Pagamento de Documentos                       ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Tabelas   ³TS2 - Documentos a Pagar                                    ³±±
±±³          ³TS8 - Honorarios de Despachante                             ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ SigaMNT                                                    ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³         ATUALIZACOES SOFRIDAS DESDE A CONSTRU€AO INICIAL.             ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Programador ³ Data   ³ F.O  ³  Motivo da Alteracao                     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³            ³        ³      ³                                          ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function MNTA740()
	Local aDbf := {}

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Armazena variaveis p/ devolucao (NGRIGHTCLICK) 						     ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	Local bKeyF9,bKeyF10,bKeyF11,bKeyF12
	Local aOldMenu
	Local aNGCAD02 := {}
	Local oTempTable //Tabela Temporaria

	Local nSizeFil := If(FindFunction("FWSizeFilial"),FwSizeFilial(),Len(SM0->M0_CODFIL))

	Private asMenu

	bKeyF9  := SetKey(VK_F9)
	bKeyF10 := SetKey(VK_F10)
	bKeyF11 := SetKey(VK_F11)
	bKeyF12 := SetKey(VK_F12)
	SETKEY(VK_F10,Nil)
	SETKEY(VK_F11,Nil)
	SETKEY(VK_F12,Nil)

	aOldMenu := ACLONE(asMenu)

	asMenu := NGRIGHTCLICK("MNTA740")

	aNGCAD02:={;
	If(Type("aCHOICE")   == "A",ACLONE(aCHOICE),{}),;
	If(Type("aVARNAO")   == "A",ACLONE(aVARNAO),{}),;
	If(Type("aGETNAO")   == "A",ACLONE(aGETNAO),{}),;
	If(Type("cGETWHILE") == "C",cGETWHILE,NIL),;
	If(Type("cGETMAKE")  == "C",cGETMAKE,NIL),;
	If(Type("cGETKEY")   == "C",cGETKEY,NIL),;
	If(Type("cGETALIAS") == "C",cGETALIAS,NIL),;
	If(Type("cTUDOOK")   == "C",cTUDOOK,NIL),;
	If(Type("cLINOK")    == "C",cLINOK,NIL),;
	If(Type("aRELAC")    == "A",ACLONE(aRELAC),{}),;
	If(Type("aCHKDEL")   == "A",ACLONE(aCHKDEL),{}),;
	If(Type("bngGRAVA")  == "A",ACLONE(bngGRAVA),{}),;
	If(Type("aNGBUTTON") == "A",ACLONE(aNGBUTTON),{})}

	Private cCadastro := OemtoAnsi(STR0001) //"Pagamento de Documentos"
	Private cPerg     := "MNT74A"
	Private aCpoBrw	  := {}
	Private lInverte  := .F.
	Private cTRB	  := GetNextAlias()
	Private cMarca    := GetMark()
	Private oTotal, nTotal := 0

	Private lIntFin := SuperGetMv("MV_NGMNTFI",.F.,"N") == "S"

	If lIntFin
		MsgInfo(STR0034+CHR(13); //"Pagamentos deverão ser realizados acessando o modulo "
		+STR0035+CHR(13); //"Financeiro (SIGAFIN) devido a integração do modulo"
		+STR0036,STR0033) //"Manutenção de Ativos com o mesmo."###"Pagamento de Documentos"
		Return
	Endif

	aDBF :=	{	{"OK"		, "C", 02, 0},;
				{"FILIAL"	, "C", nSizeFil,0},;
			 	{"DOCTO"	, "C", 06, 0},;
			 	{"DESCRI"	, "C", 30, 0},;
				If (NGSEEKDIC("SX3","TS2_PARCEL",2,"X3_TIPO") == 'C', {"PARCEL", "C", TAMSX3("TS2_PARCEL")[1],0}, {"PARCEL"	, "N", 02,0}),;
				{"DTVENC"	, "D", 08, 0},;
			 	{"PLACA"	, "C", 08, 0},;
			 	{"CODBEM"	, "C", 16, 0},;
			 	{"NOMBEM"	, "C", 30, 0},;
			 	{"VALOR"	, "N", 09, 2}}

	//Instancia classe FWTemporaryTable
	oTempTable  := FWTemporaryTable():New( cTRB, aDBF )
	oTempTable:AddIndex( "Ind01" , {"FILIAL","CODBEM","DOCTO","DTVENC"}  )
	oTempTable:AddIndex( "Ind02" , {"OK"} )
	oTempTable:Create()

	Aadd(aCpoBrw,	{ "OK"		,, " "			, "@!"		 		} )
	Aadd(aCpoBrw,	{ "DOCTO"	,, STR0008	, "@!" 				} ) //"Documento"
	Aadd(aCpoBrw,	{ "DESCRI"	,, STR0009	, "@!"				} ) //"Descrição"
	If NGSEEKDIC("SX3","TS2_PARCEL",2,"X3_TIPO") == 'C'
		Aadd(aCpoBrw,	{ "PARCEL"	,, STR0010	, "@!"			} ) //"Parcela"
	Else
		Aadd(aCpoBrw,	{ "PARCEL"	,, STR0010	, "@E 99"		} ) //"Parcela"
	Endif
	Aadd(aCpoBrw,	{ "PLACA"	,, STR0011		, "@!" 				} ) //"Placa"
	Aadd(aCpoBrw,	{ "NOMBEM"	,, STR0012	, "@!" 				} ) //"Nome Bem"
	Aadd(aCpoBrw,	{ "VALOR"	,, STR0013		, "@E 999,999.99"	} ) //"Valor"

	If Pergunte("MNT74A",.T.)
		MsgRun(OemToAnsi(STR0014),OemToAnsi(STR0015),{|| If(MNTA740TMP(),MNTA740IMP(),)}) //"Processando Arquivo..."###"Aguarde"
	EndIf

	oTempTable:Delete()

	//+-----------------------------------------------+
	//| Devolve variaveis armazenadas (NGRIGHTCLICK)  |
	//+-----------------------------------------------+
	SETKEY(VK_F9,bKeyF9)
	SETKEY(VK_F10,bKeyF10)
	SETKEY(VK_F11,bKeyF11)
	SETKEY(VK_F12,bKeyF12)

	asMenu  := ACLONE(aOldMenu)
	aCHOICE := ACLONE(aNGCAD02[1])
	aVARNAO := ACLONE(aNGCAD02[2])
	AGETNAO := ACLONE(aNGCAD02[3])
	If(aNGCAD02[4] != NIL,cGETWHILE := aNGCAD02[4],)
	If(aNGCAD02[5] != NIL,cGETMAKE  := aNGCAD02[5],)
	If(aNGCAD02[6] != NIL,cGETKEY   := aNGCAD02[6],)
	If(aNGCAD02[7] != NIL,cGETALIAS := aNGCAD02[7],)
	If(aNGCAD02[8] != NIL,cTUDOOK   := aNGCAD02[8],)
	If(aNGCAD02[9] != NIL,cLINOK    := aNGCAD02[9],)
	aRELAC    := ACLONE(aNGCAD02[10])
	aCHKDEL   := ACLONE(aNGCAD02[11])
	bngGRAVA  := ACLONE(aNGCAD02[12])
	aNGBUTTON := ACLONE(aNGCAD02[13])

Return .T.

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    |MNTA740TMP| Autor ³ Rafael Diogo Richter  ³ Data ³20/03/2007³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³Geracao do arquivo temporario                               ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³MNTA740                                                     ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function MNTA740TMP()
	Local cAliasQry := ""

	cAliasQry := "TETS2"

	cQuery := "	SELECT TS2.TS2_FILIAL, TS2.TS2_PLACA, TS2.TS2_CODBEM, ST9.T9_NOME, TS2.TS2_DOCTO, TS0.TS0_NOMDOC, "
	cQuery += "	TS2.TS2_DTPGTO, TS2.TS2_DTVENC, TS2.TS2_PARCEL, TS2.TS2_VALOR, TS2.TS2_NOTFIS "
	cQuery += "	FROM " + RetSQLName("TS2") + " TS2 "
	cQuery += "	JOIN " + RetSQLName("ST9") + " ST9 ON ST9.T9_FILIAL = '" + xFilial("ST9") + "'"
	cQuery += "	AND ST9.T9_CODBEM = TS2.TS2_CODBEM "
	cQuery += "	AND ST9.D_E_L_E_T_ <> '*' "
	cQuery += "	JOIN " + RetSQLName("TS0") + " TS0 ON TS0.TS0_FILIAL = '" + xFilial("TS0") + "'"
	cQuery += "	AND TS0.TS0_DOCTO = TS2.TS2_DOCTO "
	cQuery += "	AND TS0.D_E_L_E_T_ <> '*' "
	cQuery += "	WHERE TS2.TS2_FILIAL = '" + xFilial("TS2") + "'"
	cQuery += "	AND TS2.TS2_DTVENC BETWEEN '"+DTOS(MV_PAR01)+"' AND '"+DTOS(MV_PAR02)+"'"
	If !Empty(MV_PAR07)
		cQuery += "	AND TS2.TS2_CODBEM BETWEEN '"+MV_PAR06+"' AND '"+MV_PAR07+"'"
	Endif
	If !Empty(MV_PAR09)
		cQuery += "	AND TS2.TS2_PLACA  BETWEEN '"+MV_PAR08+"' AND '"+MV_PAR09+"'"
	Endif
	cQuery += "	AND TS2.TS2_DTPGTO = ' ' "
	cQuery += "	AND TS2.D_E_L_E_T_ <> '*' "
	cQuery += "	ORDER BY TS2.TS2_FILIAL, TS2.TS2_DOCTO, TS2.TS2_PARCEL "

	cQuery := ChangeQuery(cQuery)

	dbUseArea( .T., "TOPCONN", TCGENQRY(,,cQuery),cAliasQry, .F., .T.)

	dbSelectArea(cAliasQry)
	dbGoTop()

	If Eof()
		MsgInfo(STR0016,STR0017) //"Não existem dados para montar a Tela!"###"Atenção!"
		(cAliasQry)->(dbCloseArea())
		Return .F.
	Endif

	While (cAliasQry)->( !Eof() )
		dbSelectArea(cTRB)
		dbSetOrder(1)
		If !dbSeek((cAliasQry)->TS2_FILIAL+(cAliasQry)->TS2_CODBEM+(cAliasQry)->TS2_DOCTO+(cAliasQry)->TS2_DTVENC)
			RecLock((cTRB), .T.)
		Else
			RecLock((cTRB), .F.)
		EndIf

		(cTRB)->FILIAL 	:= (cAliasQry)->TS2_FILIAL
		(cTRB)->DOCTO		:= (cAliasQry)->TS2_DOCTO
		(cTRB)->DESCRI		:= SubStr((cAliasQry)->TS0_NOMDOC,1,30)
		(cTRB)->PARCEL		:= (cAliasQry)->TS2_PARCEL
		(cTRB)->DTVENC		:= STOD((cAliasQry)->TS2_DTVENC)
		(cTRB)->PLACA		:= (cAliasQry)->TS2_PLACA
		(cTRB)->CODBEM		:= (cAliasQry)->TS2_CODBEM
		(cTRB)->NOMBEM		:= SubStr((cAliasQry)->T9_NOME,1,30)
		(cTRB)->VALOR		:= (cAliasQry)->TS2_VALOR

		MsUnLock(cTRB)
		(cAliasQry)->(dbSkip())
	End

	(cAliasQry)->(dbCloseArea())
	(cTRB)->(dbGoTop())

Return .T.

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    |MNTA740Imp| Autor ³ Rafael Diogo Richter  ³ Data ³20/03/2007³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³Montagem da Tela com MarkBrowse                             ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³MNTA740                                                     ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function MNTA740Imp()
	Local oFont
	Local oMenu
	Local nOpca   		:= 0
	Local nQtde 		:= 0
	Local cKeyTS2 		:= "(cTRB)->CODBEM+(cTRB)->DOCTO+DTOS((cTRB)->DTVENC)"
	Local aNgButton 	:= {}
	Local aButtonsNew //Variavel utilizada pelo PE MNTA740A

	If NGRETORDEM("TS2","TS2_FILIAL+TS2_CODBEM+TS2_DOCTO+DTOS(TS2_DTVENC)+TS2_PARCEL",.T.) > 0
		cKeyTS2 += "+(cTRB)->PARCEL"
	Endif

	DEFINE FONT oFont NAME "Arial" SIZE 07,17 BOLD

	Define msDialog oDlg Title STR0001 From 000,000 To 470,750 pixel //"Pagamento de Documentos"

	oMark := MsSelect():New(cTRB,"OK",,aCpoBrw,@lInverte,@cMarca,{030,000,220,376})
	oMark:oBrowse:lHasMark = .T.
	oMark:oBrowse:lCanAllMark := .T.
	oMark:bMark := { || MNA740MA(cMarca) }
	oMark:oBrowse:bAllMark := { || Processa({ || MNA740VE(cMarca) }) }

	NGPOPUP(asMenu,@oMenu)
	oDlg:bRClicked:= { |o,x,y| oMenu:Activate(x,y,oDlg)}
	oMark:oBrowse:bRClicked:= { |o,x,y| oMenu:Activate(x,y+60,oDlg)}

	@ 224,240 Say STR0018 Font oFont Size 55,10 Of oDlg Pixel //color CLR_BLUE //"Valor Total:"
	@ 224,315 Say oTotal Var nTotal Font oFont Size 80,10 Of oDlg Pixel Picture '@E 999,999,999.99' color CLR_BLUE

	//PE PARA INCLUIR/REMOVER BOTÕES DO AÇÕES RELACIONADAS
	If ExistBlock("MNTA740A")
		aButtonsNew := ExecBlock("MNTA740A",.F.,.F.,{aNgButton})
		If ValType(aButtonsNew) == "A"
			aNgButton := aClone(aButtonsNew)
		Endif
	EndIf

	Activate MsDialog oDlg ON INIT EnchoiceBar(oDlg,{|| IIf(MNT740Val(),(nOpca:=1,oDlg:End()),)},{||oDlg:End()},,aNgButton) Center

	If nOpca == 1
		dbSelectArea(cTRB)
		dbSetOrder(2)
		dbSeek(cMarca)
		While !Eof() .And. (cTRB)->OK <> "  "
			nQtde++

			dbSelectArea("TS2")
			dbSetOrder(1)
			If dbSeek(xFilial("TS2") + &cKeyTS2. )
				Reclock("TS2",.F.)
				TS2->TS2_DTPGTO := MV_PAR05
				TS2->TS2_NOTFIS := MV_PAR03
				TS2->TS2_VALPAG := TS2->TS2_VALOR // valor pago da parcela
				MsUnlock("TS2")

				dbSelectArea( "TS1" ) //Documentos obrigatórios por veículo
				dbSetOrder( 2 ) //TS1_FILIAL+TS1_CODBEM+TS1_DOCTO+DTOS(TS1_DTEMIS)
				If dbSeek( xFilial( "TS1" ) + TS2->TS2_CODBEM + TS2->TS2_DOCTO + DTOS( TS2->TS2_DTEMIS ) )
					RecLock( "TS1",.F. )
					TS1->TS1_VALPAG += TS2->TS2_VALOR // somado o valor da parcela
					MsUnlock()
				EndIf

			EndIf

			(cTRB)->(dbSkip())
		End While

		MsgInfo(Alltrim(Str(nQtde))+STR0028,STR0017) //" documentos foram provisionados para pagamento."###"Atenção!"
	EndIf

Return .T.

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    | MNA740Ma | Autor ³ Rafael Diogo Richter  ³ Data ³20/03/2007³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³Funcao para marcar o item selecionado e atualizar os dados  ³±±
±±³          ³no rodape.                                                  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³MNTA740                                                     ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function MNA740Ma(cMarca)

	Local cFieldMarca := "OK"

	If IsMark(cFieldMarca,cMarca,lInverte)
		nTotal += (cTRB)->VALOR
		oMark:oBrowse:Refresh()
		oTotal:Refresh()
	Else
		nTotal -= (cTRB)->VALOR
		oMark:oBrowse:Refresh()
		oTotal:Refresh()
	EndIf

Return .t.

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    | MNA740Ve | Autor ³ Rafael Diogo Richter  ³ Data ³20/03/2007³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³Funcao para inverter a selecao                              ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³MNTA740                                                     ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function MNA740VE(cMarca)

	Dbselectarea(cTRB)
	DbGotop()
	Procregua(LastRec())
	While !Eof()
		IncProc(STR0019) //"Marcando e/ou Desmarcando"
		RecLock((cTRB),.F.)
		If (cTRB)->OK = "  "
			(cTRB)->OK := cMarca
			nTotal += (cTRB)->VALOR
			oMark:oBrowse:Refresh()
			oTotal:Refresh()
		Else
			(cTRB)->OK := "  "
			nTotal  -= (cTRB)->VALOR
			oMark:oBrowse:Refresh()
			oTotal:Refresh()
		EndIf

		MsUnLock(cTRB)
		dbSkip()
	End
	DbGotop()

Return .T.

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    | MNT740Val| Autor ³ Rafael Diogo Richter  ³ Data ³20/03/2007³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³Funcao para validar a gravacao                              ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³MNTA740                                                     ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function MNT740Val()

	//If !Empty(MV_PAR04)
	If nTotal <> MV_PAR04
		Help(" ",1,STR0020,,STR0021,2,1) //"Atenção"###"O valor total é diferente do valor da NF/Recibo"
		Return .F.
	EndIf
	//EndIf

Return .T.

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    |MNT740PLA | Autor ³Marcos Wagner Junior   ³ Data ³28/04/2009³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o | Valida De/Ate Placa													  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ MNTA740                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function MNT740PLA(nOpc,cParDe,cParAte,cTabela)
	Local lRet := .t.

	If Empty(cParDe) .AND. cParAte = 'ZZZZZZZZ'
		lRet := .t.
	Else
		If nOpc == 1
			If Empty(cParDe)
				lRet := .t.
			Else
				If !Empty(cParDe)
					dbSelectArea(cTabela)
					dbSetOrder(14)
					If !dbSeek(cParDe+'A')
						MsgStop(STR0022,STR0020)//"Placa digitada é inválida!"###"Atenção"
						lRet := .f.
					Endif
				Endif
			Endif
		ElseIf nOpc == 2
			If cParAte == 'ZZZZZZZZ'
				lRet := .t.
			Else
				If !Empty(cParAte)
					dbSelectArea(cTabela)
					dbSetOrder(14)
					If !dbSeek(cParAte+'A')
						MsgStop(STR0022,STR0020) //"Placa digitada é inválida!"###"Atenção"
						lRet := .f.
					Endif
				ElseIf !Empty(cParDe)
					MsgStop(STR0025,STR0020) //"'Ate Placa' deverá ser digitado!"###"Atenção"
					lRet := .f.
				Endif
			EndIf
		EndIf
	Endif

	If lRet
		If (Empty(MV_PAR08) .AND. !Empty(MV_PAR09)) .OR. (!Empty(MV_PAR08) .AND. !Empty(MV_PAR09))
			If MV_PAR08 > MV_PAR09
				MsgStop(STR0026,STR0020) //"'De Placa' deverá ser menor/igual a 'Ate Placa'!"###"Atenção"
				Return .f.
			Endif
		Endif
		If !Empty(MV_PAR08) .OR. !Empty(MV_PAR09)
			MV_PAR06 := Space(16)
			MV_PAR07 := Space(16)
		Endif
	Endif

Return lRet

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    |MNT740BEM | Autor ³Marcos Wagner Junior   ³ Data ³28/04/2009³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o | Valida De/Ate Bem     												  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ MNTA740                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function MNT740BEM(nOpc,cParDe,cParAte,cTabela)
	Local lRet := .t.

	If Empty(cParDe) .AND. cParAte = 'ZZZZZZZZZZZZZZZZ'
		lRet := .t.
	Else
		If nOpc == 1
			If Empty(cParDe)
				lRet := .t.
			Else
				If !Empty(cParDe)
					dbSelectArea(cTabela)
					dbSetOrder(16)
					If !dbSeek(cParDe+'A')
						MsgStop(STR0023,STR0020)//"Bem digitado é inválido!"###"Atenção"
						lRet := .f.
					Endif
				Endif
			Endif
		ElseIf nOpc == 2
			If cParAte == 'ZZZZZZZZZZZZZZZZ'
				lRet := .t.
			Else
				If !Empty(cParAte)
					dbSelectArea(cTabela)
					dbSetOrder(16)
					If !dbSeek(cParAte+'A')
						MsgStop(STR0023,STR0020) //"Bem digitado é inválido!"###"Atenção"
						lRet := .f.
					Endif
				ElseIf !Empty(cParDe)
					MsgStop(STR0024,STR0020) //"'Ate Bem' deverá ser digitado!"###"Atenção"
					lRet := .f.
				Endif
			EndIf
		EndIf
	Endif

	If lRet
		If (Empty(MV_PAR06) .AND. !Empty(MV_PAR07)) .OR. (!Empty(MV_PAR06) .AND. !Empty(MV_PAR07))
			If MV_PAR06 > MV_PAR07
				MsgStop(STR0026,STR0020) //"'De Bem' deverá ser menor/igual a 'Ate Bem'!"###"Atenção"
				Return .f.
			Endif
		Endif
		If !Empty(MV_PAR06) .OR. !Empty(MV_PAR07)
			MV_PAR08 := Space(08)
			MV_PAR09 := Space(08)
		Endif
	Endif

Return lRet