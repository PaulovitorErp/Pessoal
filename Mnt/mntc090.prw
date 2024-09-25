#INCLUDE "PROTHEUS.CH"
#INCLUDE "DBTREE.CH"
#INCLUDE "MNTC090.CH"

#DEFINE _nVERSAO 1 //Versao do fonte
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³ MNTC090  ³ Autor ³ Thiago Olis Machado   ³ Data ³07/08/02  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Estrutura de montagem dos pneus                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ MNTC090A                                                   ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/

Function MNTC090(cAlias,nReg,nOpcx)
	//+-----------------------------------------------------------------------+
	//| Armazena variaveis p/ devolucao (NGRIGHTCLICK)                        |
	//+-----------------------------------------------------------------------+
	Local aNGBEGINPRM := NGBEGINPRM(_nVERSAO)
	Local nRec,lRet ,i, x
	Local oPnlEstBL, oLgnd1
	Local aIdx1c90 := {}
	Local oTmpTbl090

	Private bFami := {|x| ST9->(DbSeek(xFilial('ST9') + x)), ST9->T9_CODFAMI},bCargo
	Private cPai, cComp,cCod,cAli,cRet,cItem:=Space(40),cCodigo,cDesc
	Private nOldCont, nPoscont, dOldAcom, dUltacom, lOpt
	Private nOldCont2, nPoscont2, dData1, dData2, lOpt2
	Private oDlg,oTree,oBmp
	Private oLOC1, oLOC2, oLOC3
	Private nFecha:=0,cNivel,cSeq,NNIVEL
	Private lTrb:=.f.
	Private asMenu := {}
	Private oMenu
	Private aVETINR := {}
	Private lSequeSTC := NGCADICBASE( "TC_SEQUEN","A","STC",.F. ) //Verifica se existe o campo TC_SEQUEN no dicionário ou base dados.
	Private cTRB := GetNextAlias()

	//ST9->(DbSeek(xFilial("ST9")+cAlias))
	DbSelectArea("ST9")
	DbSetOrder(1)
	DbSeek(xFilial("ST9")+cAlias)
	nInic   := Recno()
	bCargo  := {|| Substr(oTree:GetCargo(),1,40)}
	cSeq    := "0"
	cAli    := "ST9"
	cRet    := "ST9->T9_NOME"
	cTitulo := STR0001
	cDesc   := ST9->T9_NOME
	cPai    := ST9->T9_CODBEM
	nOldCont:= ST9->T9_POSCONT
	nPoscont:= ST9->T9_POSCONT
	dOldAcom:= ST9->T9_DTULTAC
	dUltacom:= ST9->T9_DTULTAC
	lOpt := IIf(ST9->T9_TEMCONT='N',.f.,.t.)

	lOpt2 :=IIF(TPE->(DbSeek(xFilial("TPE")+ST9->T9_CODBEM)),.t.,.f.)
	nPoscont2:= TPE->TPE_POSCON
	nOldCont2:= TPE->TPE_POSCON
	dData1   := TPE->TPE_DTULTA
	dData2   := TPE->TPE_DTULTA

	//+-------------------------------------------------------------------+
	//| Define as colunas (Niveis) da estrutura                           |
	//+-------------------------------------------------------------------+

	aHeader := {}
	aColTam := {}
	For i := 1 To 50
		aAdd(aColTam,40)
	Next
	aAdd(aHeader, "")
	aAdd(aHeader, "")
	aAdd(aHeader, "")

	//+-------------------------------------------------------------------+
	//| Cria Arquivo de Trabalho                                          |
	//+-------------------------------------------------------------------+
	aDbf := STC->(DbStruct())
	aAdd(aDbf, {"TC_SERVICO"   , "C", 06  , 0})
	aAdd(aDbf, {"TC_FAMBEM"    , "C", 16  , 0})
	aAdd(aDbf, {"TC_FAMCOMP "  , "C", 16  , 0})
	aAdd(aDbf, {"TC_INATI"     , "C", 1  , 0})

	aIdx1c90    := {{"TC_CODBEM","TC_COMPONE","TC_SEQRELA"},{"TC_COMPONE","TC_CODBEM","TC_SEQRELA"}}
	oTmpTbl090 := NGFwTmpTbl(cTRB,aDBF,aIdx1c90)
	aArray := NGESTRU(cPai)
	aAdd(aArray,cPai)
	For x:=1 To Len(aArray)
		dbSelectArea("STF")
		DbSeek(xFilial('STF') + aArray[x])
		cSeq := "0"
		Do While stf->tf_filial == xFilial('STF') .and.;
		stf->tf_codbem == aArray[x]           .and.;
		!EOF()

			(cTRB)->(DbAppend())
			(cTRB)->TC_FILIAL  := xFilial('STF')
			(cTRB)->TC_CODBEM  := aArray[x]
			(cTRB)->TC_SERVICO := stf->tf_servico
			(cTRB)->TC_DATAINI := If(STF->TF_PERIODO <> "E",a090PROC(stf->tf_codbem),CTOD('  /  /  '))
			(cTRB)->TC_TIPOEST := "S"
			(cTRB)->TC_INATI   := STF->TF_ATIVO
			If FindFunction("Soma1Old")
				(cTRB)->TC_SEQRELA := PADL(SOMA1OLD(cSeq),3)
			Else
				(cTRB)->TC_SEQRELA := PADL(SOMA1(cSeq),3)
			EndIf
			cSeq := (cTRB)->TC_SEQRELA
			dbSelectArea("STF")
			DbSkip()
		EndDo
	Next
	DbSelectArea("STC")
	DbSetOrder(1)
	DbSeek(xFilial("STC")+cPai)

	Do While !Eof()                      .And.;
	STC->TC_FILIAL == xFilial('STC') .And.;
	STC->TC_CODBEM == cPai

		If STC->TC_TIPOEST <> 'B'
			DbSkip()
			Loop
		EndIf
		nRec   := Recno()
		cComp  := STC->TC_COMPONE
		cNivel := STC->TC_SEQRELA

		lTrb   := .T.

		(cTRB)->(DbAppend())
		For i := 1 To 10
			(cTRB)->(FieldPut(i,STC->(FieldGet(i))))
		Next i

		If lSequeSTC //Verifica se existe o campo TC_SEQUEN no dicionário ou base dados.
			(cTRB)->TC_SEQUEN := STC->TC_SEQUEN
		EndIf

		DbSelectArea("STC")
		If dbSeek(xFILIAL('STC')+cCOMP)
			NGPOSTSON(cComp)
		EndIf
		DbGoto(nRec)
		DbSkip()
	EndDo

	cBem1 := " "
	cLoc1 := " "
	cBem2 := " "
	cLoc2 := " "
	cBem3 := " "
	cLoc3 := " "
	cRep  := " "
	cRep1 := " "
	lRet := .f.
	lTree:= .f.

	Define Font NgFont Name "Courier New" SIZE 6, 0
	Define MsDialog oDlg From  03.5,6 To 390,567 Title cTitulo Pixel

	@ 009,008 Say OemToAnsi(STR0002) Size 37,7 Of oDlg Pixel
	@ 007,037 MsGet cPai Size 48,08 Of oDlg Pixel When .f.
	@ 007,100 MsGet oDesc Var cDesc Size 160,08 Of oDlg Pixel When .f.

	@ 024,008 Say OemToAnsi(STR0005) Size 37,7 Of oDlg Pixel
	@ 022,037 MsGet nPoscont Size 48,08 Of oDlg Pixel Picture "@E 999,999,999" When .f.//lOpt Valid (nPoscont >= nOldCont)

	@ 024,100 Say OemToAnsi(STR0006) Size 37,7 Of oDlg Pixel
	@ 022,135 MsGet dUltAcom Size 48,08 Of oDlg Pixel When .f.//lOpt Valid (dUltAcom >= dOldAcom)

	@ 039,008 Say OemToAnsi(STR0007) Size 37,7 Of oDlg Pixel
	@ 039,037 MsGet nPoscont2 Size 48, 08 Of oDlg Pixel Picture "@E 999,999,999" When .f.//lOpt2 Valid (nPoscont2 >= nOldCont2)

	@ 039,100 Say OemToAnsi(STR0006) Size 37,7 Of oDlg Pixel
	@ 037,135 MsGet dData1 Size 48, 08 Of oDlg Pixel When .F. //lOpt2 Valid .f.//(dData1 >= dData2)

	@ 160,02 Say oBem1 Var cBem1 Size 048, 08 Of oDlg Pixel
	@ 160,36 Say oBem2 Var cBem2 Size 048, 08 Of oDlg Pixel
	@ 160,90 Say oBem3 Var cBem3 Size 348, 08 Of oDlg Pixel
	@ 170,02 Say oLoc1 Var cLoc1 Size 048, 08 Of oDlg Pixel
	@ 170,36 Say oLoc2 Var cLoc2 Size 048, 08 Of oDlg Pixel
	@ 170,90 Say oLoc3 Var cLoc3 Size 348, 08 Of oDlg Pixel
	@ 170,02 Say oRep1 Var cRep1 Size 348, 08 Of oDlg Pixel
	@ 170,36 Say oRep  Var cRep  Size 348, 08 Of oDlg Pixel

	oPnlEstBL:=TPanel():New(900,900,,oDlg,,,,,RGB(214,214,214),12,12,.F.,.F.)
	oPnlEstBL:Align := CONTROL_ALIGN_BOTTOM
	oPnlEstBL:nHeight := 25

	@ 000,005 Bitmap oLgnd1 Resource "Folder5" Size 25,25 Pixel Of oPnlEstBL Noborder When .F.
	@ 003,016 Say OemToAnsi(STR0012) Of oPnlEstBL Pixel

	@ 000,072 Bitmap oLgnd1 Resource "Folder7" Size 25,25 Pixel Of oPnlEstBL Noborder When .F.
	@ 003,083 Say OemToAnsi(STR0013) Of oPnlEstBL Pixel

	@ 000,145 Bitmap oLgnd1 Resource "Folder10" Size 25,25 Pixel Of oPnlEstBL Noborder When .F.
	@ 003,156 Say OemToAnsi(STR0014) Of oPnlEstBL Pixel

	@ 000,214 Bitmap oLgnd1 Resource "Folder14" Size 25,25 Pixel Of oPnlEstBL Noborder When .F.
	@ 003,225 Say OemToAnsi(STR0015) Of oPnlEstBL Pixel

	Define sButton From 160,240 Type 1 Enable Of oDlg Action oDlg:End()
	Activate MsDialog oDlg Centered On Init NGSHOWTREE()

	//NGDELETRB("TRB",cArqc090)
	oTmpTbl090:Delete()
	DbSelectArea("ST9")
	DbGoto(nInic)

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Devolve variaveis armazenadas (NGRIGHTCLICK)                          ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	NGRETURNPRM(aNGBEGINPRM)
Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³NGSHOWTREE  ³ Autor ³ Thiago Olis Machado ³ Data ³ 07/08/02 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³Cria a Arvore e mostra na tela gerenciando os niveis.       ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³MNTA830                                                     ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/

Static Function NGSHOWTREE()

	Local dDtMan	:= CtoD('  /  /  ')
	Local aItens	:= {}
	Local nI		:= 0
	Local cDesc2, cSeque, cTipoEst, cServico, dDataIni, cLocaliza

	If lTree
		oTree:End()
		lTree := .F.
	EndIf

	oTree := DbTree():New(060,012,150,272,oDlg,{|| NGSHOWLOC(oTree:GetCargo())},,.t.)
	lTree := .t.

	DbSelectArea(cTRB)
	DbSetOrder(1)
	lTrb := DbSeek(cPai)

	If lTrb
		cDesc2   := cPai+Replicate(" ",25-Len(Rtrim(cPai)))
		cProDesc := cDesc2+' - '+cDesc
		DbAddTree oTree Prompt cProDesc Opened Resource "FOLDER5", "FOLDER6" Cargo cPai

		If lSequeSTC //Verifica se existe o campo TC_SEQUEN no dicionário ou base dados.

			While !EoF() .And. Alltrim( (cTRB)->TC_CODBEM ) == Alltrim( cPai )

				nREC		:= RECNO()
				cCOMP		:= (cTRB)->TC_COMPONE
				cITEM		:= If(ST9->(DbSeek(xFilial('ST9')+cComp)),ST9->T9_NOME," ")
				cSEQ		:= (cTRB)->TC_SEQRELA
				cLOC		:= (cTRB)->TC_LOCALIZ
				cSeque		:= (cTRB)->TC_SEQUEN
				cTipoEst	:= (cTRB)->TC_TIPOEST
				cServico	:= (cTRB)->TC_SERVICO
				dDataIni	:= (cTRB)->TC_DATAINI
				cLocaliza	:= (cTRB)->TC_LOCALIZ
				cPRODESC	:= If(!Empty(cLOC),cCOMP+' - '+Alltrim(cITEM)+' - '+cLOC,cCOMP+' - '+cITEM)

				aAdd( aItens,{ cCOMP,cITEM,cSEQ,cLOC,cSeque,cTipoEst,cServico,dDataIni,cLocaliza } )

				Dbgoto(nREC)
				Dbskip()

			End While

			// Ordena itens antes de exibir na árvore
			aItens := aSort( aItens,,,{ |x,y| x[5] < y[5] } )

			For nI := 1 To Len( aItens )

				cCOMP 		:= aItens[nI][1] //Componente
				cITEM 		:= aItens[nI][2] //Item
				cSEQ  		:= aItens[nI][3] //Sequência
				cLOC  		:= aItens[nI][4] //Localização
				cSeque		:= aItens[nI][5] //Sequencial
				cTipoEst	:= aItens[nI][6] //Tipo Estoque
				cServico	:= aItens[nI][7] //Serviço
				dDataIni	:= aItens[nI][8] //Data Inicial
				cLocaliza	:= aItens[nI][9] //Localização

				If cTipoEst == "S"
					ST4->(DbSeek(xFilial('ST4') + cServico))
					cITEM  := cServico  + "  " + If(Empty( dDataIni ),STR0011,Dtoc( dDataIni ))//"(eventual)"
					dDtMan := dDataIni
				Else
					If !Empty( cLocaliza )
						If TPS->( DbSeek( xFilial("TPS")+cLocaliza ))
							cITEM := cITEM
						Endif
					Endif
				EndIf

				DbSelectArea(cTRB)
				If DbSeek(cComp)
					NGMAKETREE(cComp,cItem)
				Else
					cDesc2 := cComp+Replicate(" ",25-Len(Rtrim(cComp)))
					If Empty(cDesc2)
						cProDesc := cItem
					Else
						cProDesc := cDesc2+' - '+cItem
					EndIf
					(cTRB)->(DbSeek(cPai+cComp+cSeq))
					If cTipoEst == "S"
						If (cTRB)->TC_INATI == "N"
							DbAddItem oTree Prompt cProDesc Resource "FOLDER14" Cargo cComp
						ElseIf !Empty(dDtMan) .And. dDtMan < dDataBase
							DbAddItem oTree Prompt cProDesc Resource "FOLDER7" Cargo cComp
						Else
							DbAddItem oTree Prompt cProDesc Resource "FOLDER10" Cargo cComp
						EndIf
					Else
						DbAddItem oTree Prompt cProDesc Resource "FOLDER5" Cargo cComp
					EndIf
				EndIf

			Next nI

		Else

			While !Eof() .And. AllTrim((cTRB)->TC_CODBEM) == AllTrim(cPai)

				nRec  := Recno()
				cComp := (cTRB)->TC_COMPONE
				cSeq  := (cTRB)->TC_SEQRELA
				cItem := If(ST9->(DbSeek(xFilial('ST9')+cComp)),ST9->T9_NOME," ")

				If (cTRB)->TC_TIPOEST == "S"
					ST4->(DbSeek(xFilial('ST4') + (cTRB)->TC_SERVICO))
					cITEM  := (cTRB)->TC_SERVICO  + "  " + If(Empty((cTRB)->TC_DATAINI),STR0011,Dtoc((cTRB)->TC_DATAINI))  //"(eventual)"
					dDtMan := (cTRB)->TC_DATAINI
				Else
					If !empty((cTRB)->TC_LOCALIZ)
						If TPS->( DbSeek(xFilial("TPS")+(cTRB)->TC_LOCALIZ))
							cITEM := cITEM
						Endif
					Endif
				ENDIF
				DbSelectArea(cTRB)
				If DbSeek(cComp)
					NGMAKETREE(cComp,cItem)
				Else
					cDesc2   := cComp+Replicate(" ",25-Len(Rtrim(cComp)))
					If Empty(cDesc2)
						cProDesc := cItem
					Else
						cProDesc := cDesc2+' - '+cItem
					EndIf
					(cTRB)->(DbSeek(cPai+cComp+cSeq))
					if (cTRB)->TC_TIPOEST == "S"
						If (cTRB)->TC_INATI == "N"
							DbAddItem oTree Prompt cProDesc Resource "FOLDER14" Cargo cComp
						ElseIf !Empty(dDtMan) .And. dDtMan < dDataBase
							DbAddItem oTree Prompt cProDesc Resource "FOLDER7" Cargo cComp
						Else
							DbAddItem oTree Prompt cProDesc Resource "FOLDER10" Cargo cComp
						EndIf
					Else
						DbAddItem oTree Prompt cProDesc Resource "FOLDER5" Cargo cComp
					EndIf
				EndIf
				DbGoto(nRec)
				DbSkip()
			End While

		EndIf

		DbEndTree oTree
	EndIf

	oTree:Refresh()
	oTREE:TREESEEK(cPai)
Return Nil

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³NGMAKETREE  ³ Autor ³ Thiago Olis Machado ³ Data ³ 07/08/02 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Busca Itens filhos na estrutura - Funcao Recursiva         ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³                                                            ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/

Static Function NGMAKETREE(cPai,cDescPaI)

	Local nRec, cDesc2, cSeque
	Local aItens	:= {}
	Local nI		:= 0

	cDescPai := If(ST9->(DbSeek(xFilial('ST9')+cPai)),ST9->T9_NOME," ")
	cDesc2   := cPai+Replicate(" ",25-Len(Rtrim(cPai)))
	cProDesc := cDesc2+' - '+cDescPai

	DbAddTree oTree Prompt cProDesc Opened Resource "FOLDER5", "FOLDER6" Cargo cPai

	If lSequeSTC //Verifica se existe o campo TC_SEQUEN no dicionário ou base dados.

		While !EoF() .And. Alltrim( (cTRB)->TC_CODBEM ) == Alltrim( cPai )

			nREC		:= RECNO()
			cCOMP		:= (cTRB)->TC_COMPONE
			cITEM		:= If(ST9->(DbSeek(xFilial('ST9')+cComp)),ST9->T9_NOME," ")
			cSEQ		:= (cTRB)->TC_SEQRELA
			cLOC		:= (cTRB)->TC_LOCALIZ
			cSeque		:= (cTRB)->TC_SEQUEN
			cPRODESC	:= If(!Empty(cLOC),cCOMP+' - '+Alltrim(cITEM)+' - '+cLOC,cCOMP+' - '+cITEM)

			aAdd( aItens,{ cCOMP,cITEM,cSEQ,cLOC,cSeque } )

			Dbgoto(nREC)
			Dbskip()

		End While

		// Ordena itens antes de exibir na árvore
		aItens := aSort( aItens,,,{ |x,y| x[5] < y[5] } )

		For nI := 1 To Len( aItens )

			cCOMP 	:= aItens[nI][1] //Componente
			cITEM 	:= aItens[nI][2] //Item
			cSEQ  	:= aItens[nI][3] //Sequência
			cLOC  	:= aItens[nI][4] //Localização
			cSeque	:= aItens[nI][5] //Sequencial

			DbSelectArea(cTRB)
			If DbSeek(cComp)
				NGMAKETREE(cComp,cItem)
			Else
				If (cTRB)->(DbSeek(cPai+cComp+cSeq))
					If (cTRB)->TC_TIPOEST == "S"
						If Alltrim((cTRB)->TC_SEQRELA) <> "0"
							cDesc2   := cComp+Replicate(" ",25-Len(Rtrim(cComp)))
							cProDesc := cDesc2+' - '+cItem
							If (cTRB)->TC_INATI == "N"
								DbAddItem oTree Prompt (cTRB)->TC_SERVICO + "  " + DtoC((cTRB)->TC_DATAINI) Resource "FOLDER14" Cargo "-"+(cTRB)->TC_SERVICO
							ElseIf !Empty((cTRB)->TC_DATAINI) .And. (cTRB)->TC_DATAINI < dDataBase
								DbAddItem oTree Prompt (cTRB)->TC_SERVICO + "  " + DtoC((cTRB)->TC_DATAINI) Resource "FOLDER7" Cargo "-"+(cTRB)->TC_SERVICO
							Else
								DbAddItem oTree Prompt (cTRB)->TC_SERVICO + "  " + If(Empty((cTRB)->TC_DATAINI),STR0011,DtoC((cTRB)->TC_DATAINI)) Resource "FOLDER10" Cargo "-"+(cTRB)->TC_SERVICO  //"(eventual)"
							EndIf
						EndIf
					Else
						cDesc2   := cComp+Replicate(" ",25-Len(Rtrim(cComp)))
						cProDesc := cDesc2+' - '+cItem
						DbAddItem oTree Prompt cPRODESC RESOURCE "FOLDER5" CARGO cCOMP
					EndIf
				EndIf
			EndIf

		Next nI

	Else

		While (cTRB)->TC_CODBEM == cPai .And. !(cTRB)->(Eof())
			nRec  := Recno()
			cComp := (cTRB)->TC_COMPONE
			cSeq  := (cTRB)->TC_SEQRELA
			cItem := If(ST9->(DbSeek(xFilial('ST9')+cComp)),ST9->T9_NOME," ")
			DbSelectArea(cTRB)
			If DbSeek(cComp)
				NGMAKETREE(cComp,cItem)
			Else
				If (cTRB)->(DbSeek(cPai+cComp+cSeq))
					If (cTRB)->TC_TIPOEST == "S"
						If Alltrim((cTRB)->TC_SEQRELA) <> "0"
							cDesc2   := cComp+Replicate(" ",25-Len(Rtrim(cComp)))
							cProDesc := cDesc2+' - '+cItem
							If (cTRB)->TC_INATI == "N"
								DbAddItem oTree Prompt (cTRB)->TC_SERVICO + "  " + DtoC((cTRB)->TC_DATAINI) Resource "FOLDER14" Cargo "-"+(cTRB)->TC_SERVICO
							ElseIf !Empty((cTRB)->TC_DATAINI) .And. (cTRB)->TC_DATAINI < dDataBase
								DbAddItem oTree Prompt (cTRB)->TC_SERVICO + "  " + DtoC((cTRB)->TC_DATAINI) Resource "FOLDER7" Cargo "-"+(cTRB)->TC_SERVICO
							Else
								DbAddItem oTree Prompt (cTRB)->TC_SERVICO + "  " + If(Empty((cTRB)->TC_DATAINI),STR0011,DtoC((cTRB)->TC_DATAINI)) Resource "FOLDER10" Cargo "-"+(cTRB)->TC_SERVICO  //"(eventual)"
							EndIf
						EndIf
					Else
						cDesc2   := cComp+Replicate(" ",25-Len(Rtrim(cComp)))
						cProDesc := cDesc2+' - '+cItem
						DbAddItem oTree Prompt cPRODESC RESOURCE "FOLDER5" CARGO cCOMP
					EndIf
				EndIf
			EndIf

			DbGoto(nRec)
			DbSkip()
		End	While

	EndIf

	oTREE:TREESEEK(cPai)
	DbEndTree oTree

Return Nil

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³NGPOSTSON   ³ Autor ³ Thiago Olis Machado ³ Data ³ 07/08/02 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Inclui no arquivo de trabalho os itens filhos              ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³                                                            ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function NGPOSTSON(cPai)

	Local nRec,i

	Do While STC->TC_CODBEM == cPai .And.;
	STC->TC_FILIAL == xFilial('STC')

		If STC->TC_TIPOEST <> 'B'
			DbSkip()
			Loop
		EndIf
		nRec  := Recno()
		cComp := STC->TC_COMPONE

		(cTRB)->(DbAppend())
		For i := 1 TO 10
			(cTRB)->(FieldPut(i,STC->(FieldGet(i))))
		Next i

		If lSequeSTC //Verifica se existe o campo TC_SEQUEN no dicionário ou base dados.
			(cTRB)->TC_SEQUEN := STC->TC_SEQUEN
		EndIf

		(cTRB)->TC_FAMBEM  := Eval(bFami, STC->TC_CODBEM)
		(cTRB)->TC_FAMCOMP := Eval(bFami, STC->TC_COMPONE)

		MsUnLock()

		DbSelectArea("STC")
		If DbSeek(xFilial('STC')+cComp)
			NGPOSTSON(cCOMP)
		EndIf

		DbGoto(nRec)
		DbSkip()
	EndDo
Return Nil

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³ NGSHOWLOC  ³ Autor ³Thiago Olis Machado  ³ Data ³ 07/08/02 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³Mostra a localizacao do Bem na Estrutura                    ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ MNTA090                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function NGSHOWLOC(cCod)

	(cTRB)->(DbSetOrder(2))

	cBem1 := " "
	cLoc1 := " "
	cBem2 := " "
	cLoc2 := " "
	cBem3 := " "
	cLoc3 := " "
	cRep  := " "
	cRep1 := " "
	/*
	If cCod == cPai
	oTREE:BRCLICKED := {||}
	Else
	//oTree:bRClicked:= { |o,x,y| NGPOPUP( x, y , o,ASMENU ) }
	NGPOPUP(aSMenu,@oMenu)
	oTree:bRClicked:= { |o,x,y| oMenu:Activate(x,y,oTree)}
	EndIf
	*/
	If (cTRB)->(DbSeek(cCod))
		If ST9->(DbSeek(xFilial('ST9')+(cTRB)->TC_COMPONE))
			cBem1 := STR0002
			cBem2 := (cTRB)->TC_COMPONE
			cBem3 := ST9->T9_NOME
		EndIF
		If !Empty((cTRB)->TC_LOCALIZ)
			If TPS->(DbSeek(xFilial("TPS")+(cTRB)->TC_LOCALIZ))
				cLOC1 := STR0009
				cLOC2 := (cTRB)->TC_LOCALIZ
				cLOC3 := AllTrim(TPS->TPS_NOME)
			EndIf
		EndIf
	EndIf

	oBem1:Refresh()
	oBem2:Refresh()
	oBem3:Refresh()
	oLoc1:Refresh()
	oLoc2:Refresh()
	oLoc3:Refresh()
	(cTRB)->(DbSetOrder(1))

Return Nil

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³A090PROC  ³ Autor ³ Thiago Olis Machado   ³ Data ³07/08/02  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Processa a Proxima data de Manutencao                      ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Static Function a090PROC(cBem)

	_DtProx := NGXPROXMAN(cBem)

Return _DtProx
