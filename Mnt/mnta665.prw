#INCLUDE "MNTA665.ch"
#include "Protheus.ch"

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³ MNTA665  ³ Autor ³ Rafael Diogo Richter  ³ Data ³21/03/2007³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³Programa para Pagamento de Honorarios ao Despachante        ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Tabelas   ³TS6 -                                                       ³±±
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
Function MNTA665()
Local aDbf := {}

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Armazena variaveis p/ devolucao (NGRIGHTCLICK)                        ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
Local aNGBEGINPRM 	:= NGBEGINPRM()

Private cAliasTRB := GetNextAlias()
Private cCadastro := OemtoAnsi(STR0001) //"Pagamento de Honorários ao Despachante"
Private cPerg     := "MNA665"
Private aPerg     := {}
Private aCpoBrw	  := {}
Private lInverte  := .f.
Private cMarca    := GetMark()
Private oTotal, nTotal := 0
Private oTempTRB
Private lGera := .t.
Private nValor
Private lIntFin := SuperGetMv("MV_NGMNTFI",.F.,"N") == "S"

If NGCADICBASE("TU5_FILIAL","A","TU5",.F.)
	NGRETURNPRM(aNGBEGINPRM)
	MNTA666()
	Return
Endif

If lIntFin
   MsgInfo(STR0030+CHR(13); //"O pagamento de honorários deverá ser realizado acessando o "
   		  +STR0031+CHR(13); //"modulo Financeiro (SIGAFIN) devido a integração com o módulo"
           +STR0032,STR0033) //"de Manutenção de Ativos."###"Pagamento de Honorários"
   Return
Endif

aDBF :=	{{"OK"		, "C", 02,0},;
		 {"FILIAL"	, "C", 02,0},;
		 {"CODBEM"	, "C", 16,0},;
		 {"NOMBEM"	, "C", 30,0},;
		 {"PLACA"	, "C", 08,0},;
		 {"DOCTO"	, "C", 06,0},;
		 {"DESCRI"	, "C", 30,0},;
		 {"PARCEL"	, "C", 01,0},;
		 {"DTEMIS"	, "D", 08,0},;
		 {"DTVENC"	, "D", 08,0},;
         {"SERVIC"	, "C", 06,0}}

oTempTRB := FWTemporaryTable():New( cAliasTRB, aDBF )
oTempTRB:AddIndex( "1", {"FILIAL","CODBEM","DOCTO","DTVENC"} )
oTempTRB:AddIndex( "2", {"OK"} )
oTempTRB:Create()

Aadd(aCpoBrw,	{ "OK"		,, " "		, "@!"		 		} )
Aadd(aCpoBrw,	{ "DOCTO"	,, STR0011	, "@!" 				} ) //"Documento"
Aadd(aCpoBrw,	{ "DESCRI"	,, STR0012	, "@!"				} ) //"Descrição"
Aadd(aCpoBrw,	{ "PLACA"	,, STR0013	, "@!" 				} ) //"Placa"
Aadd(aCpoBrw,	{ "NOMBEM"	,, STR0014	, "@!" 				} ) //"Nome Bem"
Aadd(aCpoBrw,	{ "PARCEL"	,, STR0027	, "@!" 				} ) //"Parcela"
Aadd(aCpoBrw,	{ "DTVENC"	,, STR0026	, "99/99/9999"		} ) //"Data Vencimento"

If Pergunte("MNA665",.T.)
	MsgRun(OemToAnsi(STR0016),OemToAnsi(STR0017),{|| MNTA665TMP()}) //"Processando Arquivo..."###"Aguarde"
	If !lGera
		DbSelectArea(cAliasTRB)
		oTempTRB:Delete()
		NGRETURNPRM(aNGBEGINPRM)
		Return
	Endif
	MNTA665IMP()
EndIf

DbSelectArea(cAliasTRB)
oTempTRB:Delete()

NGRETURNPRM(aNGBEGINPRM)

Return .T.

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    |MNTA665TMP| Autor ³ Rafael Diogo Richter  ³ Data ³21/03/2007³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³Geracao do arquivo temporario                               ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³MNTA665                                                     ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function MNTA665TMP()
Local cAliasQry := ""

cAliasQry := "TETS8"

cQuery := " SELECT TS8.TS8_FILIAL, TS8.TS8_CODBEM, ST9.T9_NOME, TS8.TS8_PLACA, TS8.TS8_DOCTO, TS0.TS0_NOMDOC, "
cQuery += " TS8.TS8_PARCEL, TS8.TS8_DTEMIS, TS6.TS6_VALOR, TS8.TS8_DTVENC, TS6.TS6_SERVIC "
cQuery += "	FROM " + RetSQLName("TS8") + " TS8 "
cQuery += "	JOIN " + RetSQLName("ST9") + " ST9 ON ST9.T9_FILIAL = '" + xFilial("ST9") + "'"
cQuery += "	AND ST9.T9_CODBEM = TS8.TS8_CODBEM "
cQuery += "	AND ST9.D_E_L_E_T_ <> '*' "
cQuery += "	JOIN " + RetSQLName("TS0") + " TS0 ON TS0.TS0_FILIAL = '" + xFilial("TS0") + "'"
cQuery += "	AND TS0.TS0_DOCTO = TS8.TS8_DOCTO "
cQuery += "	AND TS0.D_E_L_E_T_ <> '*' "
cQuery += "	JOIN " + RetSQLName("TS6") + " TS6 ON TS6.TS6_FILIAL = '" + xFilial("TS6") + "'"
cQuery += "	AND TS6.TS6_FORNEC = '"+MV_PAR04+"'"
cQuery += "	AND TS6.TS6_LOJA = '"+MV_PAR05+"'"
cQuery += "	AND TS6.TS6_SERVIC = '"+MV_PAR06+"'"
cQuery += "	AND TS6.TS6_DOCTO  = '"+AllTrim(Str(YEAR(MV_PAR07)))+"'"
cQuery += "	AND TS6.D_E_L_E_T_ <> '*' "
cQuery += "	WHERE TS8.TS8_FILIAL = '" + xFilial("TS8") + "'"
cQuery += "	AND TS8.TS8_DTEMIS BETWEEN '"+DTOS(MV_PAR01)+"' AND '"+DTOS(MV_PAR02)+"'"
cQuery += "	AND TS8_FORNEC = ' ' "
cQuery += "	AND TS8_LOJA = ' ' "
cQuery += "	AND TS8.D_E_L_E_T_ <> '*' "
cQuery += "	ORDER BY TS8.TS8_FILIAL, TS8.TS8_DOCTO "

cQuery := ChangeQuery(cQuery)

MPSysOpenQuery( cQuery , cAliasQry )

dbSelectArea(cAliasQry)
dbGoTop()

If Eof()
	MsgInfo(STR0018,STR0019) //"Não existem dados para montar a Tela!"###"Atenção!"
   (cAliasQry)->(dbCloseArea())
   lGera := .f.
   Return
Endif

While (cAliasQry)->( !Eof() )
	dbSelectArea(cAliasTRB)
	dbSetOrder(1)
	If !dbSeek((cAliasQry)->TS8_FILIAL+(cAliasQry)->TS8_CODBEM+(cAliasQry)->TS8_DOCTO+DtoS((cAliasQry)->TS8_DTVENC))
		RecLock(cAliasTRB, .T.)
	Else
		RecLock(cAliasTRB, .F.)
	EndIf

	(cAliasTRB)->FILIAL 	:= (cAliasQry)->TS8_FILIAL
	(cAliasTRB)->CODBEM		:= (cAliasQry)->TS8_CODBEM
	(cAliasTRB)->NOMBEM		:= SubStr((cAliasQry)->T9_NOME,1,30)
	(cAliasTRB)->PLACA		:= (cAliasQry)->TS8_PLACA
	(cAliasTRB)->DOCTO		:= (cAliasQry)->TS8_DOCTO
	(cAliasTRB)->DESCRI		:= SubStr((cAliasQry)->TS0_NOMDOC,1,30)
	(cAliasTRB)->PARCEL		:= (cAliasQry)->TS8_PARCEL
	(cAliasTRB)->DTEMIS		:= STOD((cAliasQry)->TS8_DTEMIS)
	(cAliasTRB)->DTVENC		:= STOD((cAliasQry)->TS8_DTVENC)
	(cAliasTRB)->SERVIC     := (cAliasQry)->TS6_SERVIC
	nValor         := (cAliasQry)->TS6_VALOR

	MsUnLock(cAliasTRB)
	(cAliasQry)->(dbSkip())
End

(cAliasQry)->(dbCloseArea())
(cAliasTRB)->(dbGoTop())

Return .T.

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    |MNTA665Imp| Autor ³ Rafael Diogo Richter  ³ Data ³21/03/2007³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³Montagem da Tela com MarkBrowse                             ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³MNTA665                                                     ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function MNTA665Imp()
Local nOpca   := 0
Local oFont
Private oMenu

DEFINE FONT oFont NAME "Arial" SIZE 07,17 BOLD

Define msDialog oDlg Title STR0001 From 000,000 To 470,830 pixel //"Pagamento de Honorários ao Despachante"

	dbSelectArea("SA2")
	dbSetOrder(1)
	dbSeek(xFilial("SA2")+Mv_Par04+Mv_Par05)

	@ 013,001 Say STR0020 Font oFont Size 45,10 Of oDlg Pixel //color CLR_BLUE //"Fornecedor:"
	@ 013,050 Say AllTrim(SA2->A2_NOME) Font oFont Size 250,10 Of oDlg Pixel color CLR_BLUE
	@ 013,325 Say STR0021 Font oFont Size 25,10 Of oDlg Pixel //color CLR_BLUE //"Loja:"
	@ 013,350 Say AllTrim(Mv_Par05) Font oFont Size 55,10 Of oDlg Pixel color CLR_BLUE

	oMark := MsSelect():New(cAliasTRB,"OK",,aCpoBrw,@lInverte,@cMarca,{025,000,220,456})
	oMark:oBrowse:lHasMark = .T.
	oMark:oBrowse:lCanAllMark := .T.

   @ 224,290 Say STR0022 Font oFont Size 55,10 Of oDlg Pixel //color CLR_BLUE //"Valor Total:"
   @ 224,365 Say oTotal Var nValor Font oFont Size 80,10 Of oDlg Pixel Picture '@E 999,999,999.99' color CLR_BLUE

   NGPOPUP(asMenu,@oMenu)
	oDlg:bRClicked:= { |o,x,y| oMenu:Activate(x,y,oDlg)}

Activate MsDialog oDlg ON INIT EnchoiceBar(oDlg,{|| (nOpca:=1,oDlg:End())},{||oDlg:End()}) Center

If nOpca == 1
	dbSelectArea(cAliasTRB)
	dbSetOrder(2)
	dbSeek(cMarca)
	While !Eof() .And. (cAliasTRB)->OK <> "  "
		dbSelectArea("TS8")
		dbSetOrder(3)
		If dbSeek(xFilial("TS8")+(cAliasTRB)->CODBEM+(cAliasTRB)->DOCTO+DTOS((cAliasTRB)->DTVENC))
			Reclock("TS8",.F.)
			TS8->TS8_VALOR		:= nValor //(cAliasTRB)->VALOR
			TS8->TS8_NOTFIS	:= MV_PAR03
			TS8->TS8_FORNEC	:= MV_PAR04
			TS8->TS8_LOJA	:= MV_PAR05
			TS8->TS8_SERVIC	:= (cAliasTRB)->SERVIC
			TS8->TS8_DTPGTO	:= MV_PAR07
			MsUnLock("TS8")
		EndIf

		(cAliasTRB)->(dbSkip())
	End

EndIf
Return .T.

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    | MNA665Ma | Autor ³ Rafael Diogo Richter  ³ Data ³21/03/2007³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³Funcao para marcar o item selecionado e atualizar os dados  ³±±
±±³          ³no rodape.                                                  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³MNTA665                                                     ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function MNA665Ma(cMarca)

Local cFieldMarca := "OK"

If IsMark(cFieldMarca,cMarca,lInverte)
   nTotal += (cAliasTRB)->VALOR
   oMark:oBrowse:Refresh()
  	oTotal:Refresh()
Else
   nTotal -= (cAliasTRB)->VALOR
   oMark:oBrowse:Refresh()
  	oTotal:Refresh()
EndIf

Return .t.

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    | MNA665Ve | Autor ³ Rafael Diogo Richter  ³ Data ³21/03/2007³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³Funcao para inverter a selecao                              ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³MNTA665                                                     ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function MNA665VE(cMarca)

Dbselectarea(cAliasTRB)
DbGotop()
Procregua(LastRec())
While !Eof()
   IncProc(STR0023) //"Marcando e/ou Desmarcando"
   RecLock(cAliasTRB,.F.)
   If (cAliasTRB)->OK = "  "
	   (cAliasTRB)->OK := cMarca
	   nTotal += (cAliasTRB)->VALOR
	   oMark:oBrowse:Refresh()
   	oTotal:Refresh()
	Else
		(cAliasTRB)->OK := "  "
	   nTotal  -= (cAliasTRB)->VALOR
	   oMark:oBrowse:Refresh()
	   oTotal:Refresh()
	EndIf

	MsUnLock(cAliasTRB)
   dbSkip()
End
DbGotop()

Return .T.

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    |MNR145CC  | Autor ³Marcos Wagner Junior   ³ Data ³ 05/10/06 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o |Valida os codigos De Motivo, Ate Motivo                     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³MNTR145                                                     ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/

Function MNA665CC(nOpc,cParDe,cParAte,cTabela)

If (Empty(cParDe) .AND. cParAte = 'ZZZZZZ' )
	Return .t.
Else
	If nOpc == 1
		If Empty(cParDe)
			Return .t.
		Else
			lRet := IIf(Empty(cParDe),.t.,ExistCpo(cTabela,cParDe))
		   If !lRet
		      Return .f.
		   EndIf
		Endif
	ElseIf nOpc == 2
		If (cParAte == 'ZZZZZZ')
			Return .t.
		Else
	      lRet := IIF(ATECODIGO(cTabela,cParDe,cParAte,06),.T.,.F.)
	      If !lRet
	         Return .f.
	      EndIf
	   EndIf
	EndIf
Endif

Return .t.