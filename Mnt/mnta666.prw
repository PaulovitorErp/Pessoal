#INCLUDE "MNTA666.ch"
#include "Protheus.ch"

//---------------------------------------------------------------------
/*/{Protheus.doc} MNTA666
Programa para Pagamento de Honorarios ao Despachante
@author Rafael Diogo Richter
@since 21/03/2007
@version undefined
@type function
/*/
//---------------------------------------------------------------------
Function MNTA666()

	Local aDbf := {}
	Local nX

	//-------------------------------------------------------------------------
	//| Armazena variaveis p/ devolucao (NGRIGHTCLICK)                        |
	//-------------------------------------------------------------------------
	Local aNGBEGINPRM := NGBEGINPRM()
	Local cFilter     := ' TST_FILIAL = ' + ValToSQL( xFilial( 'TST' ) ) // Filtro Browse

	Private cCadastro	:= OemtoAnsi(STR0001) //"Geração de Honorários ao Despachante"
	Private aPerg		:= {}
	Private aCpoBrw		:= {}
	Private lInverte	:= .F.
	Private cMarca		:= GetMark()
	Private oTotal
	Private lGera		:= .T.
	Private nValor		:= 0
	Private lIntFin		:= SuperGetMv("MV_NGMNTFI",.F.,"N") == "S"
	Private aAlteraTS2  := {}
	Private aTS8NUMSEQ  := {}
	Private aRotina		:= MenuDef()
	Private aCAMPOSN	:= {}
	Private cTRB 		:= GetNextAlias()

	If !FindFunction("_NGIntFIN")
		Final("Atualizar NGIntFin!")
	EndIf

	SetBrwChgAll( .F. ) // Não apresenta tela para informar filial
	mBrowse( 6, 1, 22, 75, 'TST', , , , , , , , , , , , , , cFilter )

	//-------------------------------------------------------------------------
	//| Devolve variaveis armazenadas (NGRIGHTCLICK)                          |
	//-------------------------------------------------------------------------
	NGRETURNPRM(aNGBEGINPRM)

Return .T.

//---------------------------------------------------------------------
/*/{Protheus.doc} MNTA666TMP
Geracao do arquivo temporario
@author Rafael Diogo Richter
@since 21/03/2007
@version undefined
@type function
/*/
//---------------------------------------------------------------------
Function MNTA666TMP()

	Local nI
	Local nX
	Local cAliasQry  := ""
	Local cChaveMARK := ''
	Local aSerXdoc   := {}
	Local lGravouTRB := .f.

	aAlteraTS2 := {}
	_aRegsTS2  := {}

	cAlias1 := GetNextAlias()
	cQuery := " SELECT TU5.TU5_DOCTO, TS6.TS6_VALOR, TS4.TS4_CODSDP, TS4.TS4_DESCRI, TS4.TS4_PAGHON "
	cQuery += "	FROM " + RetSQLName("TS6") + " TS6 "
	cQuery += "	JOIN " + RetSQLName("TU5") + " TU5 ON TU5.TU5_FILIAL = '" + xFilial("TU5") + "'"
	cQuery += "	AND   TU5.TU5_CODSDP = TS6.TS6_SERVIC "
	cQuery += "	AND   TU5.D_E_L_E_T_ <> '*' "
	cQuery += "	JOIN " + RetSQLName("TS4") + " TS4 ON TS4.TS4_FILIAL = '" + xFilial("TS4") + "'"
	cQuery += "	AND   TS4.TS4_CODSDP = TU5.TU5_CODSDP "
	cQuery += "	AND   TS4.D_E_L_E_T_ <> '*' "
	cQuery += "	WHERE TS6.TS6_FILIAL = '" + xFilial("TS6") + "'"
	cQuery += "	AND   TS6.TS6_FORNEC = '" + Mv_Par04 + "'"
	cQuery += "	AND   TS6.TS6_LOJA   = '" + Mv_Par05 + "'"
	cQuery += "	AND   TS6.D_E_L_E_T_ <> '*' "
	cQuery += "	AND   TS6.TS6_DOCTO = '" + AllTrim(Str(Year(Mv_Par06))) + "'"
	cQuery += "	ORDER BY TS4.TS4_CODSDP, TU5.TU5_DOCTO "
	cQuery := ChangeQuery(cQuery)
	dbUseArea( .T., "TOPCONN", TCGENQRY(,,cQuery),cAlias1, .F., .T.)

	dbSelectArea(cAlias1)
	dbGoTop()
	If !Eof()
		While !Eof()
			nPos := aSCAN(aSerXdoc,{|x| x[1] == (cAlias1)->TS4_CODSDP })
			If nPos == 0
				Aadd(aSerXdoc,{(cAlias1)->TS4_CODSDP,(cAlias1)->TS4_DESCRI,(cAlias1)->TS6_VALOR,(cAlias1)->TS4_PAGHON,{(cAlias1)->TU5_DOCTO}})
			Else
				Aadd(aSerXdoc[nPOS][5],(cAlias1)->TU5_DOCTO)
			Endif
			dbSkip()
		End
		(cAlias1)->(dbCloseArea())
	EndIf

	For nI := 1 To Len(aSerXdoc)
		_cDoctos := ''
		_cOldBem := ''
		For nX := 1 To Len(aSerXdoc[nI][5])
			If Empty(_cDoctos)
				_cDoctos := "'" + aSerXdoc[nI][5][nX] + "'"
			Else
				_cDoctos += ",'" + aSerXdoc[nI][5][nX] + "'"
			Endif
		Next nX

		cAlias2 := GetNextAlias()
		cQuery2 := " SELECT TS2.TS2_CODBEM, TS2.TS2_DOCTO, TS2.TS2_DTVENC, TS2.TS2_DTPGTO, ST9.T9_NOME, ST9.T9_PLACA, (TS2.R_E_C_N_O_) AS TS2REC "
		cQuery2 += " FROM " + RetSQLName("TS2") + " TS2 "
		cQuery2 += " JOIN " + RetSQLName("ST9") + " ST9 ON ST9.T9_FILIAL = '" + xFilial("ST9") + "'"
		cQuery2 += " AND   ST9.T9_CODBEM = TS2.TS2_CODBEM "
		cQuery2 += " AND   ST9.D_E_L_E_T_ <> '*' "
		cQuery2 += " WHERE TS2.TS2_FILIAL = '" + xFilial("TS2") + "'"
		cQuery2 += " AND   TS2.TS2_DTEMIS BETWEEN '"+DTOS(MV_PAR01)+"' AND '"+DTOS(MV_PAR02)+"'"
		cQuery2 += " AND   TS2.TS2_DOCTO IN (" + _cDoctos + ")"
		cQuery2 += " AND   TS2.D_E_L_E_T_ <> '*' "
		cQuery2 += " AND   TS2.TS2_NUMSEQ = ' ' "
		cQuery2 += " ORDER BY  TS2.TS2_CODBEM, TS2.TS2_DOCTO, "
		If aSerXdoc[nI][4] == '1'
			cQuery2 += "TS2.TS2_DTVENC "
		Else
			cQuery2 += "TS2.TS2_DTVENC DESC"
		Endif
		cQuery2 := ChangeQuery(cQuery2)
		dbUseArea( .T., "TOPCONN", TCGENQRY(,,cQuery2),cAlias2, .F., .T.)
		While !Eof()

			If _cOldBem != (cAlias2)->TS2_CODBEM
				nDocPagos := 0
				_cLastKey := ''
				_cOldBem := (cAlias2)->TS2_CODBEM
				If lGravouTRB
					For nX := 1 To Len(_aRegsTS2)
						nPOS := aSCAN(aAlteraTS2,{|x| x[1] == cChaveMARK })
						If nPOS == 0
							AADD(aAlteraTS2,{cChaveMARK,{_aRegsTS2[nX]}})
						Else
							AADD(aAlteraTS2[nPOS][2],_aRegsTS2[nX])
						Endif
					Next nX

				Endif
				_aRegsTS2 := {}
			Endif

			AADD(_aRegsTS2,(cAlias2)->TS2REC) //Adiciona registros para nao serem mais relacionados com Honorarios, assim que os mesmos forem gerados.

			If _cLastKey != (cAlias2)->TS2_CODBEM+(cAlias2)->TS2_DOCTO
				_cLastKey := (cAlias2)->TS2_CODBEM+(cAlias2)->TS2_DOCTO

				If !Empty((cAlias2)->TS2_DTPGTO)
					nDocPagos += 1
				Endif

				//Grava a TRB quando todos documentos do servico estao pagos
				If Len(aSerXdoc[nI][5]) == nDocPagos
					dbSelectArea(cTRB)
					dbSetOrder(1)
					RecLock((cTRB), .T.)
					(cTRB)->CODBEM	:= (cAlias2)->TS2_CODBEM
					(cTRB)->NOMBEM	:= (cAlias2)->T9_NOME
					(cTRB)->PLACA	:= (cAlias2)->T9_PLACA
					(cTRB)->DOCTO	:= (cAlias2)->TS2_DOCTO
					(cTRB)->SERVIC	:= aSerXdoc[nI][1]
					(cTRB)->DESCRI	:= aSerXdoc[nI][2]
					(cTRB)->VALOR	:= aSerXdoc[nI][3]
					(cTRB)->(MsUnLock())
					cChaveMARK     := (cTRB)->CODBEM+(cTRB)->SERVIC //Chave do MarkBrowse
					lGravouTRB := .t.
				Endif
			Endif

			dbSelectArea(cAlias2)
			dbSkip()
		End
		(cAlias2)->(dbCloseArea())
	Next nI

	If !Empty(cChaveMARK)
		For nX := 1 To Len(_aRegsTS2)
			nPOS := aSCAN(aAlteraTS2,{|x| x[1] == cChaveMARK })
			If nPOS == 0
				AADD(aAlteraTS2,{(cTRB)->CODBEM+(cTRB)->SERVIC,{_aRegsTS2[nX]}})
			Else
				AADD(aAlteraTS2[nPOS][2],_aRegsTS2[nX])
			Endif
		Next nX
	Endif

	(cTRB)->(dbGoTop())

	If !lGravouTRB
		MsgInfo(STR0011,STR0012) //"Não existem dados para montar a Tela!"###"Atenção!"
		lGera := .f.
		Return
	Endif

Return .T.

//---------------------------------------------------------------------
/*/{Protheus.doc} MNTA666Tel
Montagem da Tela com MarkBrowse
@author Rafael Diogo Richter
@since 21/03/2007
@version undefined
@type function
/*/
//---------------------------------------------------------------------
Function MNTA666Tel()

	Local nOpca := 0
	Local oFont

	Private dDtVenc    := dDATABASE
	Private dDtPag     := dDATABASE
	Private cCondPag   := MV_PAR10
	Private cCndPgOld  := MV_PAR10 // Variavel para controle de condição de pagamento
	Private cDescPag   := NGSEEK("SE4",cCondPag,1,"E4_DESCRI")
	Private oMenu
	Private aParcBem   := {}
	Private aParcelas  := {}
	Private cCHANGEKEY := ""
	Private cGerSeq    := ""

	aNgButton := {}

	If lIntFin
		INCLUI := .t.
		Aadd(aNgButton,{"OMSDIVIDE" ,{|| MNT666PARC() },STR0037,STR0037})
	Endif

	DEFINE FONT oFont NAME "Arial" SIZE 07,17
	DEFINE FONT oFont NAME "Arial" SIZE 07,17 BOLD

	Define msDialog oDlg Title STR0001 From 000,000 To 489,888 pixel //"Geração de Honorários ao Despachante"

	oGRHNPNL := TPanel():New(0,0,,oDlg,,.t.,,,,0,0,.t.,.f.)
	oGRHNPNL:Align := CONTROL_ALIGN_ALLCLIENT

	dbSelectArea("SA2")
	dbSetOrder(1)
	dbSeek(xFilial("SA2")+Mv_Par04+Mv_Par05)

	@ 005,002 Say STR0013 Font oFont Size 45,08 Of oGRHNPNL Pixel //color CLR_BLUE //"Fornecedor:"
	@ 005,080 MSget AllTrim(SA2->A2_NOME) Font oFont Size 180,08 Of oGRHNPNL When .f. Pixel
	If lIntFin
		@ 017,002 Say STR0014 Font oFont Size 105,08 Of oGRHNPNL Pixel //color CLR_BLUE //"Condição Pagamento:"
		@ 017,080 MSget cCondPag Font oFont Size 50,08 Of oGRHNPNL Valid MNT666GAT() F3 "SE4" Pixel HASBUTTON
		@ 017,140 MSget cDescPag Font oFont Size 120,08 Of oGRHNPNL When .f. Pixel
	Else
		@ 017,002 Say STR0034 Font oFont Size 105,08 Of oGRHNPNL Pixel color CLR_BLUE //"Data do Pagamento:"
		@ 017,080 MSget dDtPag Font oFont Size 50,08 Of oGRHNPNL Valid NaoVazio() .AND. VALDT(dDtPag) .AND. MV_PAR06 <= dDtPag Pixel HASBUTTON
		@ 017,150 Say STR0035 Font oFont Size 105,08 Of oGRHNPNL Pixel color CLR_BLUE //"Data do Vencimento:"
		@ 017,229 MSget dDtVenc Font oFont Size 50,08 Of oGRHNPNL Valid NaoVazio() .AND. VALDT(dDtVenc) .AND. MV_PAR06 <= dDtVenc Pixel HASBUTTON
	Endif

	oMark := MsSelect():New((cTRB),"OK",,aCpoBrw,@lInverte,@cMarca,{035,000,216,446},,,oGRHNPNL)
	oMark:oBrowse:lHasMark = .T.
	oMark:oBrowse:lCanAllMark := .T.
	oMark:bMark := { || MNA666MA(cMarca) }
	oMark:oBrowse:bAllMark := { || Processa({ || MNA666VE(cMarca) }) }

	@ 221,290 Say STR0015 Font oFont Size 55,10 Of oGRHNPNL Pixel //color CLR_BLUE //"Valor Total:"
	@ 221,365 Say oTotal Var nValor Font oFont Size 80,10 Of oGRHNPNL Pixel Picture '@E 999,999,999.99' color CLR_BLUE

	NGPOPUP(asMenu,@oMenu)
	oGRHNPNL:bRClicked:= { |o,x,y| oMenu:Activate(x,y,oGRHNPNL)}

	Activate MsDialog oDlg ON INIT EnchoiceBar(oDlg,{|| (nOpca := 1, If(MNT666VLPR(),oDlg:End(),nOpca := 0) )},{||oDlg:End()},,aNgButton) Center

	If nOpca == 1

		Processa( { |lEnd| ProcDoc() }, STR0010 ) //"Aguarde"

		If Len(aTS8NUMSEQ) > 0
			MNTA666REL()
		Endif

	EndIf

Return .T.

//---------------------------------------------------------------------
/*/{Protheus.doc} ProcDoc
Montagem da Tela com MarkBrowse.
@author	 Rafael Diogo Richter
@since	 21/03/2007
@version MP11/MP12
/*/
//---------------------------------------------------------------------
Static Function ProcDoc()

	Local nI
	Local nPOS
	Local lGo     := .T.
	Local cCvSE2  := NGSEEKDIC("SX2","SE2",1,"X2_ARQUIVO")     //Utilizada na verificação do número sequencia da TRX
	Local lExSE2  := NGSX2MODO("SE2") == "C"

	//Necessário limpar array novamente pois se gerar novo honorário sem sair da rotina estava gerando o relatório com os registros anteriores.
	aTS8NUMSEQ	:= {}

	dbSelectArea(cTRB)
	dbSetOrder(02)
	dbSeek(cMarca)
	While !Eof() .And. (cTRB)->OK <> "  "

		IncProc( STR0042 + AllTrim((cTRB)->SERVIC) + STR0040 + AllTrim((cTRB)->CODBEM) ) //"Analisando serviço "####" do bem "

		aParcelas := {}

		If lIntFin //Se integrado ao modulo financeiro
			// Caso tenha definido as parcelas na tela anterior
			If Len(aParcBem) > 0 .And. (nPosParc := aScan(aParcBem,{|x| x[1] == (cTRB)->CODBEM+(cTRB)->SERVIC})) > 0
				aParcelas := aClone(aParcBem[nPosParc][2])
				aDel(aParcBem,nPosParc)
				aSize(aParcBem,Len(aParcBem)-1)
			Else
				// Caso nao haja parcelas definidas, gera novas parcelas a apartir da chave atual
				If !NGFICONDP(.F.,.F.,(cTRB)->VALOR,cCondPag,MV_PAR06)
					dbSelectArea(cTRB)
					(cTRB)->(dbSkip())
					Loop
				Endif
			Endif
		Endif

		For nI := 1 to If(lIntFin,Len(aParcelas),1)
			dbSelectArea("TS8")
			dbSetOrder(03)
			If dbSeek(xFilial("TS8")+(cTRB)->CODBEM+Space(TAMSX3("TS8_DOCTO")[1])+DTOS(If(lIntFin,aParcelas[nI][1],dDtVenc))+(cTRB)->SERVIC)
				lGo := .F.
				Exit
			EndIf
		Next nX

		If !lGo
			Exit
		EndIf

		(cTRB)->(dbSkip())
	EndDo

	If !lGo
		Help(,,'HELP',, 'Chave duplicada na geração de honorários: '+;
		'Bem: '+(cTRB)->CODBEM+' Serv.:'+(cTRB)->SERVIC+' Venc.:'+DTOC(If(lIntFin,aParcelas[nI][1],dDtVenc)),1,0)
	Else
		dbSelectArea(cTRB)
		dbSetOrder(2)
		ProcRegua(RecCount())
		dbSeek(cMarca)
		While !Eof() .And. (cTRB)->OK <> "  "

			// Retorna conteudo do parametro MV_1DUP
			cParSE2Doc := NGFI1DUP()

			nNumSeqDOC := GETSXENUM("TS8","TS8_NUMSEQ")
			nNumSeqSE2 := NGSEQSE2()

			//Consiste NgIntFin somente se integrado com financeiro MV_NGMNTFI = 'S'
			If lIntFin
				oIntFIN := NGIntFin():New()
				oIntFIN:setOperation(3)
				oIntFIN:setRelated("TS8")
				oIntFIN:setValue("E2_PREFIXO",MV_PAR07)
				oIntFIN:setValue("E2_NUM",nNumSeqSE2)
				oIntFIN:setValue("E2_TIPO",MV_PAR08)
				oIntFIN:setValue("E2_NATUREZ",MV_PAR09)
				oIntFIN:setValue("E2_FORNECE",MV_PAR04)
				oIntFIN:setValue("E2_LOJA",MV_PAR05)
				oIntFIN:setValue("E2_EMISSAO",MV_PAR06)
				oIntFIN:setValue("E2_ORIGEM",FunName())
				oIntFIN:setValue("E2_MOEDA",1)
				oIntFIN:setValue("E2_CCD",'')
				oIntFIN:setValue("E2_ITEMD",'')
				oIntFIN:setParcelas(aParcelas)

				If !oIntFIN:geraTitulo()
					Help(,,'HELP',, oIntFIN:getErrorList()[1],1,0)
					lGo := .F.
					If !Empty(cGerSeq)
						UnLockByName(cGerSeq+cCvSE2,.T.,lExSE2)
					Endif
				EndIf
			EndIf

			If lGo
				For nI := 1 to If(lIntFin,Len(aParcelas),1)
					cGerSeq   := ""
					// Verifica tipo do campo TS2_PARCEL [Numerico / Caracter]
					xIndParc := If(Valtype(TS8->TS8_PARCEL) == "C",If(lIntFin,aParcelas[nI][3],cParSE2Doc),nI)
					Reclock("TS8",.t.)
					TS8->TS8_FILIAL		:= xFilial("TS8")
					TS8->TS8_CODBEM		:= (cTRB)->CODBEM
					TS8->TS8_PLACA		:= (cTRB)->PLACA
					TS8->TS8_DOCTO		:= (cTRB)->DOCTO
					TS8->TS8_PARCEL		:= xIndParc
					TS8->TS8_VALOR		:= If(lIntFin,aParcelas[nI][2],(cTRB)->VALOR)
					TS8->TS8_NOTFIS		:= MV_PAR03
					TS8->TS8_FORNEC		:= MV_PAR04
					TS8->TS8_LOJA		:= MV_PAR05
					TS8->TS8_SERVIC		:= (cTRB)->SERVIC
					TS8->TS8_DTEMIS		:= MV_PAR06
					TS8->TS8_DTVENC		:= If(lIntFin,aParcelas[nI][1],dDtVenc)
					TS8->TS8_NUMSEQ		:= nNumSeqDOC
					TS8->TS8_PREFIX		:= MV_PAR07
					TS8->TS8_TIPO		:= MV_PAR08
					TS8->TS8_NATURE     := MV_PAR09
					If lIntFin
						TS8->TS8_NUMSE2	:= nNumSeqSE2
					Else
						TS8->TS8_VALPAG := (cTRB)->VALOR
						TS8->TS8_DTPGTO := dDtPag
					Endif
					TS8->(MsUnLock())

					AADD(aTS8NUMSEQ,{TS8->TS8_SERVIC,NGSEEK("TS4",TS8->TS8_SERVIC,1,"TS4_DESCRI"),;
					TS8->TS8_CODBEM,NGSEEK("ST9",TS8->TS8_CODBEM,1,"T9_NOME"),;
					TS8->TS8_PARCEL,TS8->TS8_DTVENC,TS8->TS8_VALOR,TS8->TS8_NUMSE2,;
					TS8->TS8_NOTFIS})

					cParSE2Doc := MNTPARCELA(cParSE2Doc)

					If !Empty(cGerSeq)
						UnLockByName(cGerSeq+cCvSE2,.T.,lExSE2)
					Endif
				Next
				nPOS := aSCAN(aAlteraTS2,{|x| x[1] == (cTRB)->CODBEM+(cTRB)->SERVIC })
				For nI := 1 To Len(aAlteraTS2[nPOS][2])
					dbSelectArea("TS2")
					dbGoTo(aAlteraTS2[nPOS][2][nI])
					Reclock("TS2",.F.)
					TS2->TS2_NUMSEQ := nNumSeqDOC
					TS2->(MsUnlock())
				Next

			EndIf

			(cTRB)->(dbSkip())
		End
	EndIf

Return lGo

//---------------------------------------------------------------------
/*/{Protheus.doc} MNT666PARC
Aciona montagem da GetDados com as parcelas.

@author Hugo Rizzo Pereira
@since 22/07/2011

@version undefined
@type function
/*/
//---------------------------------------------------------------------

Function MNT666PARC()

	Local lRet := .T.
	Local nPosParc

	cCHANGEKEY := DTOS(Mv_Par06)+cCondPag+cVALTOCHAR((cTRB)->VALOR)

	DbSelectArea(cTRB)
	If !Eof()
		If !Empty((cTRB)->OK)
			If (!Empty((cTRB)->VALOR) .And. (cTRB)->VALOR > 0) .And. !Empty(cCondPag)

				//Define parcelas, e abre tela para possível alteração das mesmas
				aParcelas := {}
				If (nPosParc1 := aScan(aParcBem,{|x| x[1] == (cTRB)->CODBEM+(cTRB)->SERVIC })) > 0
					aParcelas := aClone(aParcBem[nPosParc1][2])
				Else
					lRet := NGFICONDP(.F.,,(cTRB)->VALOR,cCondPag,MV_PAR06)
				Endif

				If lRet .And. FindFunction( 'MntParcVld' )

					lRet := MntParcVld( (cTRB)->VALOR, MV_PAR06, cCondPag, 0 )

				Endif

				If lRet

					lRet := NGPARCELAS( (cTRB)->VALOR, MV_PAR06, cCondPag, 0, , 2 )

				EndIf

				//Armazena/Altera chave + parcelas
				If (nPosParc2 := aScan(aParcBem,{|x| x[1] == (cTRB)->CODBEM+(cTRB)->SERVIC })) > 0
					aDel(aParcBem,nPosParc2)
					aSize(aParcBem,Len(aParcBem)-1)
				Endif

				If lRet .And. Len(aParcelas) > 0
					aAdd(aParcBem,{(cTRB)->CODBEM+(cTRB)->SERVIC,aClone(aParcelas)})
				Endif

				aParcelas := {}

			Endif
		Endif
	Endif

Return lRet

//---------------------------------------------------------------------
/*/{Protheus.doc} MNA666Ma
Funcao para marcar o item selecionado e atualizar os dados no rodape.
@author Rafael Diogo Richter
@since 21/03/2007
@version undefined
@param cMarca, characters, descricao
@type function
/*/
//---------------------------------------------------------------------
Function MNA666Ma(cMarca)

	Local cFieldMarca := "OK"
	Local lRet        := .T.
	Local nPosParc

	If IsMark(cFieldMarca,cMarca,lInverte)

		// Caso haja integracao com modulo financeiro
		// Valida geracao de parcelas conforme condicao de pagamento
		If lIntFin .And. !(lRet := NGFICONDP(.F.,,(cTRB)->VALOR,cCondPag,MV_PAR06))
			dbSelectArea(cTRB)
			RecLock((cTRB),.F.)
			(cTRB)->OK := Space(2)
			(cTRB)->(MsUnlock())
		Endif

		aParcelas := {}
		If lRet
			nValor += (cTRB)->VALOR
		Endif

		oMark:oBrowse:Refresh()
		oTotal:Refresh()
	Else

		If lIntFin .And. (nPosParc := aScan(aParcBem,{|x| x[1] == (cTRB)->CODBEM+(cTRB)->SERVIC })) > 0
			aDel(aParcBem,nPosParc)
			aSize(aParcBem,Len(aParcBem)-1)
		Endif

		nValor -= (cTRB)->VALOR
		oMark:oBrowse:Refresh()
		oTotal:Refresh()
	EndIf

Return lRet

//---------------------------------------------------------------------
/*/{Protheus.doc} MNA666VE
Funcao para inverter a selecao
@author Rafael Diogo Richter
@since 21/03/2007
@version undefined
@param cMarca, characters, descricao
@type function
/*/
//---------------------------------------------------------------------
Function MNA666VE(cMarca)

	Dbselectarea(cTRB)
	DbGotop()
	Procregua(LastRec())
	While !Eof()
		IncProc(STR0016) //"Marcando e/ou Desmarcando"
		If (cTRB)->OK = Space(2)
			// Valida geracao de parcelas conforme condicao de pagamento
			If lIntFin .And. !NGFICONDP(.F.,.F.,(cTRB)->VALOR,cCondPag,MV_PAR06)
				dbSelectArea(cTRB)
				dbSkip()
				Loop
			Endif

			aParcelas := {}
			dbSelectArea(cTRB)

			RecLock((cTRB),.F.)
			(cTRB)->OK := cMarca
			MsUnLock(cTRB)
			nValor += (cTRB)->VALOR
			oMark:oBrowse:Refresh()
			oTotal:Refresh()
		Else
			dbSelectArea(cTRB)
			RecLock((cTRB),.F.)
			(cTRB)->OK := Space(2)
			MsUnLock(cTRB)

			nValor  -= (cTRB)->VALOR
			oMark:oBrowse:Refresh()
			oTotal:Refresh()
		EndIf

		dbSelectArea(cTRB)
		dbSkip()
	End
	DbGotop()

Return .T.

//---------------------------------------------------------------------
/*/{Protheus.doc} MNT666GAT
Gatilho da "Condicao de Pagamento"
@author Marcos Wagner Junior
@since 15/06/11
@version undefined
@type function
/*/
//---------------------------------------------------------------------
Static Function MNT666GAT()

	If !NGIFDBSEEK("SE4",cCondPag,1)
		HELP(" ",1,"REGNOIS")
		Return .f.
	Endif

	//Só irá efetuar as alterações caso a condição de pagamento seja diferente
	If cCondPag <> cCndPgOld
		cDescPag  := SE4->E4_DESCRI

		/*Como houve alteração na condição de pagamento, todas as parcelas atuais
		ja alteradas/definidas serão desconsideradas */
		aParcBem  := {}
		aParcelas := {}
		cCndPgOld := cCondPag
	EndIf

Return .T.

//---------------------------------------------------------------------
/*/{Protheus.doc} MNTA666REL
Relatorio da Geracao de Documentos
@author Marcos Wagner Junior
@since 22/03/07
@version undefined
@type function
/*/
//---------------------------------------------------------------------
Function MNTA666REL()

	WNREL	:= "MNTA666"
	LIMITE	:= 80
	cDESC1	:= STR0028 //"O relatorio irá apresentar os honorários gerados."
	cDESC2	:= ""
	cDESC3	:= ""
	cSTRING := "ST9"

	Private NOMEPROG := "MNTA666"
	Private TAMANHO  := "M"
	Private aRETURN  := {STR0029,1,STR0030,1,2,1,"",1} //"Zebrado"###"Administracao"
	Private TITULO   := STR0031 //"Relatório da Geração de Honorários"
	Private nTIPO    := 0
	Private nLASTKEY := 0
	Private CABEC1,CABEC2

	WNREL := SetPrint(cString,Wnrel,,Titulo,cDesc1,cDesc2,cDesc3,.f.,"")
	If nLastKey = 27
		Set Filter To
		DbSelectArea("ST9")
		Return
	EndIf
	SetDefault(aReturn,cString)
	RptStatus({|lEnd| MNTA666IMP(@lEnd,Wnrel,Titulo,Tamanho)},STR0010,STR0009) //"Aguarde"###"Processando Arquivo..."
	Dbselectarea("ST9")

Return .T.

//---------------------------------------------------------------------
/*/{Protheus.doc} MNTA666IMP
Relatorio da Geracao de Documentos
@author Marcos Wagner Junior
@since 22/03/07
@version undefined
@type function
/*/
//---------------------------------------------------------------------
Function MNTA666IMP()

	Local nI
	Local cOldServico := ''
	Local nTotServ    := 0
	Local nTotGeral   := 0

	Private cRODATXT  := ""
	Private nCNTIMPR  := 0
	Private li 		  := 80
	Private m_pag     := 1

	nTIPO  := IIf(aReturn[4]==1,15,18)

	CABEC1 := STR0026 //"Serviço   Descrição"
	If lIntFin
		CABEC2 := STR0027 //"   Bem                Nome                                      Parcela        Valor    Vencimento   Nota Fiscal   N. Título   "
	Else
		CABEC2 := STR0036 //"   Bem                Nome                                      Parcela        Valor    Vencimento   Nota Fiscal"
	Endif

	/*
	1         2         3         4         5         6         7         8         9         0         1         2
	0123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123
	****************************************************************************************************************************
	Relatorio de Geracao de Honorarios
	****************************************************************************************************************************
	Serviço   Descrição
	xxxxxx    xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx
	Bem                Nome                                      Parcela        Valor    Vencimento   Nota Fiscal   N. Título
	xxxxxxxxxxxxxxxx   xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx        x   999.999,99      99/99/99   xxxxxxxxx     xxxxxxxxx
	*/

	If Len(aTS8NUMSEQ) > 0
		aSORT(aTS8NUMSEQ,,,{|x,y| x[1]+Dtos(x[6]) < y[1]+Dtos(y[6]) })
	Endif

	cVeiAntigo := ''
	SetRegua(Len(aTS8NUMSEQ))
	For nI := 1 to Len(aTS8NUMSEQ)
		IncRegua()

		NgSomaLi(58)
		If AllTrim(aTS8NUMSEQ[nI][1]) != cOldServico
			If !Empty(cOldServico)
				NgSomaLi(58)
				NgSomaLi(58)
				@ Li,050 Psay STR0032 //"TOTAL SERVIÇO:"
				@ Li,070 Psay PADL(Transform(nTotServ,'@E 999,999,999.99'),14)
				NgSomaLi(58)
				NgSomaLi(58)
				nTotServ := 0
			Endif
			@ Li,000 	 Psay AllTrim(aTS8NUMSEQ[nI][1])
			@ Li,010 	 Psay AllTrim(aTS8NUMSEQ[nI][2])
			cOldServico := AllTrim(aTS8NUMSEQ[nI][1])
			NgSomaLi(58)
			NgSomaLi(58)
		Endif
		@ Li,003 	 Psay aTS8NUMSEQ[nI][3]
		@ Li,022 	 Psay aTS8NUMSEQ[nI][4]
		@ Li,070 	 Psay aTS8NUMSEQ[nI][5]
		@ Li,074 	 Psay PADL(Transform(aTS8NUMSEQ[nI][7],'@E 999,999.99'),10)
		@ Li,088 	 Psay aTS8NUMSEQ[nI][6] Picture "99/99/9999"
		@ Li,101 	 Psay aTS8NUMSEQ[nI][9]
		@ Li,115 	 Psay aTS8NUMSEQ[nI][8]
		nTotServ  += aTS8NUMSEQ[nI][7]
		nTotGeral += aTS8NUMSEQ[nI][7]
	Next

	NgSomaLi(58)
	NgSomaLi(58)
	@ Li,050 Psay STR0032 //"TOTAL SERVIÇO:"
	@ Li,070 Psay PADL(Transform(nTotServ,'@E 999,999,999.99'),14)
	NgSomaLi(58)
	NgSomaLi(58)
	@ Li,050 Psay STR0033 //"TOTAL GERAL:"
	@ Li,070 Psay PADL(Transform(nTotGeral,'@E 999,999,999.99'),14)

	RODA(nCNTIMPR,cRODATXT,TAMANHO)

	RetIndex('ST9')
	Set Filter To
	Set Device To Screen
	If aReturn[5] == 1
		Set Printer To
		dbCommitAll()
		OurSpool(WNREL)
	EndIf
	MS_FLUSH()

Return Nil

//---------------------------------------------------------------------
/*/{Protheus.doc} MNT666VLPR
Consiste geração de parcelas para os documentos.
@author Hugo R. Pereira
@since 29/05/2012
@version MP10
@return lRet Indica se a geracao de parcela e' realizada corretamente.
/*/
//---------------------------------------------------------------------
Function MNT666VLPR()

	Local lRet     := .T.
	Local nPosParc := 0

	If !lIntFin
		Return .T.
	Endif

	dbSelectArea(cTRB)
	dbSetOrder(2)
	dbSeek(cMarca)
	While !Eof() .And. (cTRB)->OK <> Space(2)
		If (nPosParc := aScan(aParcBem,{|x| x[1] == (cTRB)->CODBEM + (cTRB)->SERVIC })) == 0

			If !(lRet := NGFICONDP(.F.,.F.,(cTRB)->VALOR,cCondPag,MV_PAR06))
				ShowHelpDlg(STR0007, {STR0038 + CRLF + ; // "Condição de pagamento inválida."
				STR0039 + AllTrim((cTRB)->SERVIC) + ; // "Não foi possível gerar as parcelas para o serviço "
				STR0040 + AllTrim((cTRB)->CODBEM) + "." },1,; // " do bem "
				{STR0041},1) // "Informe uma condição de pagamento válida."
				Exit
			Endif
		Endif

		dbSelectArea(cTRB)
		dbSkip()
	End

	aParcelas := {}

Return lRet

//---------------------------------------------------------------------
/*/{Protheus.doc} MenuDef
Utilizacao de menu Funcional
@author Bruno Lobo de Souza
@since 12/04/2016
@version P11/P12
@return aRotina
1. Nome a aparecer no cabecalho
2. Nome da Rotina associada
3. Reservado
4. Tipo de Transação a ser efetuada:
1 - Pesquisa e Posiciona em um Banco de Dados
2 - Simplesmente Mostra os Campos
3 - Inclui registros no Bancos de Dados
4 - Altera o registro corrente
5 - Remove o registro corrente do Banco de Dados
5. Nivel de acesso
6. Habilita Menu Funcional
/*/
//---------------------------------------------------------------------
Static Function MenuDef(nBrw)

	Local lPyme := IIf(Type("__lPyme") <> "U",__lPyme,.F.)

	Local aRotina


	If nBrw == 2
		aRotina := {	{ STR0043, "AxPesqui"  , 0, 1 },;     //"Pesquisar"
		{ STR0044, "MNT666GERA", 0, 3 },;     //"Gerar"
		{ STR0045, "MNT666EXC" , 0, 5,3 },;   //"Excluir"
		{ STR0046, "MNT666LEG" , 0, 7,,.F. } }//"Legenda"
	Else
		aRotina := {	{ STR0043, "AxPesqui"  , 0, 1 },;     //"Pesquisar"
		{ STR0047, "MNT666HONO", 0, 3} }      //"Honorarios"
	EndIf

Return aRotina

//---------------------------------------------------------------------
/*/{Protheus.doc} MNT666HONO
Abre browse com honorários do despachante.
@author Bruno Lobo de Souza
@since 12/04/2016
@version P11/P12
/*/
//---------------------------------------------------------------------
Function MNT666HONO()

	Local aCores := { 	{ "!Empty(TS8->TS8_VALPAG)", "BR_VERMELHO" },;
	{ "Empty(TS8->TS8_VALPAG)", "BR_VERDE"} }

	aRotina := MenuDef(2)

	dbSelectArea("TS8")
	dbSetOrder(1)

	Set Filter To TS8->TS8_FORNEC == TST->TST_FORNEC
	SetBrwChgAll( .T. ) // Apresenta a tela para informar a filial
	mBrowse(6,1,22,75,"TS8",,,,,,aCores)

Return

//---------------------------------------------------------------------
/*/{Protheus.doc} MNT666LEG
Define as cores da legenda do browse de honorários do despachante
@author Bruno Lobo de Souza
@since 12/04/2016
@version P11/P12
@return aCores - Array com as cores da legenda
/*/
//---------------------------------------------------------------------
Function MNT666LEG()

	Local aLegenda := { {"BR_VERMELHO","Honorário pago"},;
	{"BR_VERDE","Honorário a pagar"}}

	BrwLegenda( "", STR0046, aLegenda )

Return .T.

//---------------------------------------------------------------------
/*/{Protheus.doc} MNT666GERA
Gera honorário do despachante
@author Bruno Lobo de Souza
@since 11/04/2016
@version P11/P12
@return .T.
/*/
//---------------------------------------------------------------------
Function MNT666GERA()

	MNT666TRB()

Return .T.

//---------------------------------------------------------------------
/*/{Protheus.doc} MNT666EXC
Exclui o documento a pagar
@author Bruno Lobo de Souza
@since 11/04/2016
@version P11/P12
@return lRet Indica se a geracao de parcela e' realizada corretamente.
/*/
//---------------------------------------------------------------------
Function MNT666EXC( cAlias , nReg , nOpcX )

	Local nOpca		:= 0
	Local lRet		:= .T.
	Local dDTLiMFi	:= SuperGetMV( "MV_DATAFIN",.F.,STOD("") )
	Local aOldRot	:= aClone( aRotina )

	//Variaveis para efetuar as consistências após a exclusão da TS8
	Local cCodBem	:= ""
	Local cDocto	:= ""
	Local dDtEmis	:= ""
	Local cPrefix	:= ""
	Local cNumSeq	:= ""
	Local cNumSE2	:= ""
	Local cTipo		:= ""
	Local cNature	:= ""
	Local cFornec	:= ""
	Local cLoja		:= ""

	//Define um novo aRotina padrao para nao ocorrer erro
	aRotina 	:=	{ { "", "AxPesqui", 0, 1 } , ;  //"Pesquisar"
	{ "", "NGCAD01" , 0, 2 } , ;  //"Visualizar"
	{ "", "NGCAD01" , 0, 3 } , ;  //"Incluir"
	{ "", "NGCAD01" , 0, 4 } , ;  //"Alterar"
	{ "", "NGCAD01" , 0, 5, 3 } } //"Excluir"
	aCpoN	:= {}
	aChoice	:= NGCAMPNSX3( "TS8", aCpoN )

	//Verificar se pode deletar a multa quando integrado ao financeiro
	If lIntFin
		If dDTLiMFi > TS8->TS8_DTEMIS .And. !Empty(TS8->TS8_NUMSE2)
			MsgStop( STR0048, STR0012 ) //"Honorário não pode ser excluido pois a data de emissão é menor que a data limite de fechamento financeiro."##"Atenção!"
			lRet := .F.
		EndIf
	EndIf
	If lRet .And. TS8->TS8_VALPAG > 0 .And. !Empty(TS8->TS8_DTPGTO)
		lRet := .F.
		MsgStop(STR0049,STR0012) //""Honorário não pode ser excluido pois já foi pago.""##"Atenção!"
	EndIf

	If lRet
		cCodBem	:= TS8->TS8_CODBEM
		cDocto	:= TS8->TS8_DOCTO
		dDtEmis	:= TS8->TS8_DTEMIS
		cNumSeq	:= TS8->TS8_NUMSEQ
		cNumSE2	:= TS8->TS8_NUMSE2
		cPrefix	:= TS8->TS8_PREFIX
		cTipo	:= TS8->TS8_TIPO
		cNature	:= TS8->TS8_NATURE
		cFornec	:= TS8->TS8_FORNEC
		cLoja	:= TS8->TS8_LOJA
		nOpca := NGCAD01( cAlias , nReg , 5 )
	EndIf

	If nOpca == 1

		//Ao deletar uma parcela deleta as demais (caso existam)
		dbSelectArea("TS8")
		dbSetOrder(1)//TS8_FILIAL+TS8_CODBEM+TS8_DOCTO+DTOS(TS8_DTEMIS)
		dbSeek(xFilial("TS8")+cCodBem+cDocto+DtoS(dDtEmis))
		While !Eof() .And. xFilial("TS8") == TS8->TS8_FILIAL .And. TS8->TS8_CODBEM == cCodBem .And.;
		TS8->TS8_DOCTO == cDocto .And. TS8->TS8_DTEMIS == dDtEmis
			Reclock("TS8", .F.)
			dbDelete()
			MsUnLock("TS8")
			TS8->(dbSkip())
		End

		//Limpa 'Numseq' gravado ao efetuar o pagamento do honorário
		MNT666DREL(cCodBem,cDocto,cNumSeq)

		If NGCADICBASE("TS8_PREFIX","A","TS8",.F.)
			MNT666DPAR( cPrefix, cNumSE2, cTipo, cNature, cFornec, cLoja, dDtEmis ) //Deleta as parcelas geradas na integração com o financeiro
		EndIf
	EndIf

	aRotina := aClone( aOldRot )
Return .T.

//---------------------------------------------------------------------
/*/{Protheus.doc} MNT666TRB
Monta TRB para geração do honorário.
@author Bruno Lobo de Souza
@since 11/04/2016
@version P11/P12
@return Nil
/*/
//---------------------------------------------------------------------
Static Function MNT666TRB()

	Local aDbf		:= {}
	Local oTmpTbl
	Local cPerg		:= "MNA666"
	Local lIntFin 	:= SuperGetMv("MV_NGMNTFI",.F.,"N") == "S"

	aDBF :=	{	{"OK"		, "C", 02,0},;
				{"CODBEM"	, "C", 16,0},;
				{"NOMBEM"	, "C", 30,0},;
				{"PLACA"	, "C", 08,0},;
				{"DOCTO"	, "C", 06,0},;
				{"SERVIC"	, "C", 06,0},;
				{"DESCRI"	, "C", 40,0},;
				{"VALOR"	, "N", 09,2}}

	//Intancia classe FWTemporaryTable
	oTmpTbl:= FWTemporaryTable():New( cTRB, aDBF )
	//Adiciona os Indices
	oTmpTbl:AddIndex( "Ind01" , {"CODBEM","SERVIC"} )
	oTmpTbl:AddIndex( "Ind02" , {"OK"} )
	//Cria a tabela temporaria
	oTmpTbl:Create()

	aCpoBrw := {	{ "OK"		,, " "	  , "@!"		 	  },;
					{ "CODBEM"	,, STR0003, "@!" 			  },; //"Bem"
					{ "NOMBEM"	,, STR0004, "@!" 			  },; //"Nome Bem"
					{ "PLACA"	,, STR0005, "@!" 			  },; //"Placa"
					{ "DOCTO"	,, STR0050, "@!" 			  },; //"Documento"
					{ "SERVIC"	,, STR0006, "@!" 			  },; //"Serviço do Despachante"
					{ "DESCRI"	,, STR0007, "@!"			  },; //"Descrição"
					{ "VALOR"	,, STR0008, "@E 9,999,999.99" }}  //"Valor"

	If lIntFin
		cPerg := "MNA666FI"
	EndIf

	If Pergunte(cPerg,.T.)
		MsgRun(OemToAnsi(STR0009),OemToAnsi(STR0010),{|| MNTA666TMP()}) //"Processando Arquivo..."###"Aguarde"

		// Consiste conteudo do parametro MV_1DUP
		lGera := If(lGera, NGFIV1DUP(), lGera)
		If !lGera
			oTmpTbl:Delete()
			Return
		EndIf
		MNTA666Tel()
	EndIf
	oTmpTbl:Delete()

Return

//---------------------------------------------------------------------
/*/{Protheus.doc} MNT666DREL
Limpa 'Numseq' gravado ao efetuar o pagamento do honorário.

@param cCodBem, Caracter, Código do bem.
@param cDocto, 	Caracter, Código do documento.
@param cNumSeq,	Caracter, Sequencial.

@author Bruno Lobo de Souza
@since 11/04/2016
@version P11/P12
@return Nil
/*/
//---------------------------------------------------------------------
Static Function MNT666DREL(cCodBem,cDocto,cNumSeq)

	Local aArea := GetArea()

	dbSelectArea("TS2")
	dbSetOrder(1)
	dbSeek(xFilial("TS2")+cCodBem+cDocto)
	While !Eof() .And. xFilial("TS8") == TS2->TS2_FILIAL .And. cNumSeq == TS2->TS2_NUMSEQ
		RecLock("TS2",.F.)
		TS2->TS2_NUMSEQ := Space(TAMSX3("TS2_NUMSEQ")[1])
		MsUnLock()
		TS2->(dbSkip())
	End

	RestArea(aArea)

Return

//---------------------------------------------------------------------
/*/{Protheus.doc} MNT666DPAR
Deleta as parcelas referentes ao honorário excluido.
@author Bruno Lobo de Souza
@since 12/05/2016
@version P11/P12
@return Nil
/*/
//---------------------------------------------------------------------
Static Function MNT666DPAR( cPrefix, cNumSE2, cTipo, cNature, cFornec, cLoja, dDtEmis )

	Local lRet := .T.

	//Caso existam, seleciona as parcelas referente à chave informada
	Local aParcelas := fGetParcel( cPrefix, cNumSE2, cTipo, cFornec, cLoja )

	oIntFIN := NGIntFin():New()
	oIntFIN:setOperation(5)
	oIntFIN:setRelated("TS8")
	oIntFIN:setValue("E2_PREFIXO",cPrefix)
	oIntFIN:setValue("E2_NUM",cNumSE2)
	oIntFIN:setValue("E2_TIPO",cTipo)
	oIntFIN:setValue("E2_NATUREZ",cNature)
	oIntFIN:setValue("E2_FORNECE",cFornec)
	oIntFIN:setValue("E2_LOJA",cLoja)
	oIntFIN:setValue("E2_EMISSAO",dDtEmis)
	oIntFIN:setValue("E2_ORIGEM",FunName())
	oIntFIN:setValue("E2_MOEDA",1)
	oIntFIN:setValue("E2_CCD",'')
	oIntFIN:setValue("E2_ITEMD",'')

	oIntFIN:setParcelas(aParcelas)

	If !oIntFIN:geraTitulo()
		Help(,,'HELP',, oIntFIN:getErrorList()[1],1,0)
		lRet := .F.
	EndIf

Return lRet

//---------------------------------------------------------------------
/*/{Protheus.doc} fGetParcel
Retorna as parcelas
@author Bruno Lobo de Souza
@since 12/05/2016
@version P11/P12
@return Nil
/*/
//---------------------------------------------------------------------
Static Function fGetParcel( cPrefix, cNumSe2, cTipo, cFornec, cLoja )

	Local cQuery := ""

	aParcelas := {}

	cArqSE2 := GetNextAlias()
	cQuery := " SELECT SE2.E2_PARCELA, SE2.E2_VENCTO, SE2.E2_VALOR, SE2.E2_HIST, SE2.E2_DECRESC"
	cQuery += " FROM " + RetSQLName( "SE2" ) + " SE2 "
	cQuery += " WHERE SE2.E2_PREFIXO = '" + cPrefix + "'
	cQuery += " AND   SE2.E2_NUM     = '" + cNumSe2 + "'
	cQuery += " AND   SE2.E2_TIPO    = '" + cTipo   + "'
	cQuery += " AND   SE2.E2_FORNECE = '" + cFornec + "'
	cQuery += " AND   SE2.E2_LOJA    = '" + cLoja   + "'
	cQuery += " AND   SE2.E2_FILIAL  = '" + xFilial( "SE2" ) + "'
	cQuery += " AND   D_E_L_E_T_    <> '*'"
	cQuery += " ORDER BY SE2.E2_PARCELA "
	cQuery := ChangeQuery( cQuery )
	dbUseArea( .T.,"TOPCONN",TCGENQRY( ,,cQuery ),cArqSE2,.F.,.T. )

	dbSelectArea( cArqSE2 )
	dbGoTop()
	While !Eof()

		aAdd( aParcelas, { STOD((cArqSE2)->E2_VENCTO),(cArqSE2)->E2_VALOR,(cArqSE2)->E2_PARCELA,(cArqSE2)->E2_HIST,(cArqSE2)->E2_DECRESC } )

		dbSelectArea( cArqSE2 )
		dbSkip()
	End While

Return aParcelas