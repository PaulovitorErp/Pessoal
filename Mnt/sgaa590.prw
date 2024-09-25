#INCLUDE "PROTHEUS.CH"
#INCLUDE "TOPCONN.CH"
#INCLUDE "SGAA590.CH"

//---------------------------------------------------------------------
/*/{Protheus.doc} SGAA590
MANUTENCAO DE REVISAO/DESEMPENHO

@author LUCIANO CAMPOS DE SANTANA
@since 27/03/2013
@version MP11
/*/
//---------------------------------------------------------------------
Function SGAA590()

	// ---------------------------------------------
	//³ Guarda conteudo e declara variaveis padroes ³
	// ---------------------------------------------
	Local aNGBEGINPRM := NGBEGINPRM(,"SGAA590")
	Local aPERG,aHELP,aTAMSX, aSX3ARQ, aORD,aPOS, aBUTTONS, aTDR,aTAB,aTA4,aTAE, aCPOTMPA
	Local cGRUPO,cPERG,lRESULT,cFILEA ,cOALIAS,cKEYPESQ,cFILEA2
	Local bOK,bCANCEL
	Local nA, nBTPO
	Local oDLG
	Local oPnlTot
	Local oTempTMPA

	Local aCpsTAB   := APBuildHeader( "TAB" )
	Local cCampo    := ''
	Local aTamCpo   := {}
	Local nCps      := 0
	Local aListCpo  := { "TAB_REVISA", "TAB_SITUAC", "TAB_ORDEM", "TAB_CODASP" }

	Private aCAMPOS,aHEADER,cMARCA,lINVERTE,cREVISAO,cPESQUISA
	Private _lActAprv := .F. // Variavel para validação do SGA111PRAV
	Private aSize := MsAdvSize(,.f.,430), aObjects := {}
	Aadd(aObjects,{200,200,.t.,.f.})
	aInfo := {aSize[1],aSize[2],aSize[3],aSize[4],0,0}
	aPosObj := MsObjSize(aInfo, aObjects,.t.)

	//valida se update foi aplicado
	IF !NGCADICBASE('TDR_REVISA','A','TDR',.F.)
		NGINCOMPDIC("UPDSGA21","THYYMI")
		// --------------------------------------
		// Retorna conteudo de variaveis padroes
		// --------------------------------------
		NGRETURNPRM(aNGBEGINPRM)

		RETURN(NIL)
	ENDIF

	// Declara variáveis para utilização
	cOALIAS   := ALIAS()
	aTDR      := {TDR->(INDEXORD()),TDR->(RECNO())}
	aTAB      := {TAB->(INDEXORD()),TAB->(RECNO())}
	aTA4      := {TA4->(INDEXORD()),TA4->(RECNO())}
	aTAE      := {TAE->(INDEXORD()),TAE->(RECNO())}
	aTAF      := {TAF->(INDEXORD()),TAF->(RECNO())}
	aPERG     := {}
	aHELP     := {}
	bPESQUISA := {|| FVZ001("bPESQUISA")}
	cPERG     := "SGA111Z"
	cKEYPESQ  := STR0001 //"Ordem+Cod.Aspecto"
	cPESQUISA := SPACE(LEN(TAB->(TAB_ORDEM+TAB_CODASP)))
	cGRUPO    := PADR( cPERG, 10, " " )
	cMARCA    := GETMARK()
	lINVERTE  := .F.

	If PERGUNTE(cPERG)

		// CRIA A ESTRUTURA DO ARQUIVO TEMPORARIO
		aCAMPOS  := {}
		aHEADER  := {}
		aSX3ARQ  := { { "TMPA_FLAG", "C", 02, 0 } }
		aCPOTMPA := { { "TMPA_FLAG", , " " } }

		For nCps := 1 To Len(aCpsTAB)

			cCampo  := AllTrim( aCpsTAB[ nCps, 2 ] )
			aTamCpo := TamSX3( cCampo )
			cBrowse := GetSx3Cache( cCampo, 'X3_BROWSE' )
			cTipo   := GetSx3Cache( cCampo, 'X3_TIPO' )

			If cBrowse == "S" .Or. aScan( aListCpo,{|x| Alltrim(x) == Alltrim(cCampo) } ) > 0

				If GetSx3Cache( cCampo, 'X3_CONTEXT' ) <> "V"
					aAdd( aSX3ARQ, { cCampo, cTipo, aTamCpo[1], aTamCpo[2] } )
				Else
					aAdd( aSX3ARQ,{ cCampo, cTipo, 20, aTamCpo[2] } )
				EndIf
				If cBrowse == "S"
					aAdd( aCPOTMPA, { cCampo, , AVSX3( cCampo, 5 ) } )
				EndIf
			EndIf

			If cCampo == "TAB_CODNIV"
				aAdd( aSX3ARQ,{ "TAB_DESNIV", "C", 20, 0 } )
				aAdd( aCPOTMPA, { "TAB_DESNIV", , AVSX3( "TAB_DESNIV", 5 ) } )
			EndIf

		Next nCps

		cTRBTMPA  := GetNextAlias()
		oTempTMPA := FWTemporaryTable():New( cTRBTMPA, aSX3ARQ )
		oTempTMPA:AddIndex( "1", {"TAB_REVISA"} )
		oTempTMPA:AddIndex( "2", {"TAB_ORDEM","TAB_CODASP"} )
		oTempTMPA:Create()

		// Inicia proceso de incremento das tabelas
		PROCESSA( {|| lRESULT := INCTRBBRW() } )
		IF ! lRESULT
			MSGINFO(STR0031,STR0032) //"Nao ha dados para os Filtros informados !" ## "Atencao"
		ELSE
			DBSELECTAREA( cTRBTMPA )
			bOK      := {|| nBTOP := 1,IF(FVZ001("bOK"),oDLG:END(),nBTOP := 0)}
			bCANCEL  := {|| nBTOP := 0,oDLG:END()}
			aBUTTONS := {}
			nBTOP    := 0
			cREVISAO := MV_PAR09 //TMPA->TAB_REVISA

			DEFINE MSDIALOG oDLG TITLE STR0033 FROM aSize[7],0 To aSize[6],aSize[5] OF oMainWnd PIXEL  //"Revisao / Desempelho"

			oPnlTot       := TPanel():New( 0, 0, , oDLG, , , , , , 0, 35)
			oPnlTot:Align := CONTROL_ALIGN_ALLCLIENT

			@ 13,010 SAY AVSX3("TAB_REVISA",5) PIXEL OF oPnlTot
			@ 13,055 MSGET cREVISAO PICTURE AVSX3("TAB_REVISA",6) SIZE 45,08 WHEN(EMPTY(cREVISAO	)) F3("TDR") ;
			VALID(FVZ001("cREVISA")) PIXEL OF oPnlTot HASBUTTON

			@ 02,460 To 035,640 Label STR0034 Of oPnlTot Pixel
			@ 13,480 MSGET cKEYPESQ WHEN(.F.) SIZE 60,08 PIXEL OF oPnlTot
			@ 13,540 MSGET cPESQUISA SIZE 60,08 PIXEL OF oPnlTot
			@ 13,600 BUTTON STR0034 SIZE 30,09 ACTION Eval(bPESQUISA) PIXEL OF oPnlTot //"&Pesquisa"

			aPOS           := POSDLG(oPnlTot)
			aPOS[1]        := aPOS[1]+20
			aPOS[3]        := aPOS[3]-15
			oMSELECT       := MSSELECT():New(cTRBTMPA,"TMPA_FLAG",,aCPOTMPA,@lINVERTE,@cMARCA,aPOS,,,oPnlTot)
			oMSELECT:BAVAL := {|| FVZ001("MARCA")}
			ACTIVATE MSDIALOG oDLG ON INIT ENCHOICEBAR(oDLG,bOK,bCANCEL,,aBUTTONS) CENTERED
			IF nBTOP == 1
				BEGIN TRANSACTION
				PROCESSA( {|| FVZ001("TMPA_TO_TAB") } )
				END TRANSACTION
			ENDIF
		ENDIF
		oTempTMPA:Delete()
	ENDIF

	TDR->(DBSETORDER(aTDR[1])) ; TDR->(DBGOTO(aTDR[2]))
	TAB->(DBSETORDER(aTAB[1])) ; TAB->(DBGOTO(aTAB[2]))
	TA4->(DBSETORDER(aTA4[1])) ; TA4->(DBGOTO(aTA4[2]))
	TAE->(DBSETORDER(aTAE[1])) ; TAE->(DBGOTO(aTAE[2]))
	TAF->(DBSETORDER(aTAF[1])) ; TAF->(DBGOTO(aTAF[2]))
	IF ! EMPTY(cOALIAS)
		DBSELECTAREA(cOALIAS)
	ENDIF

	// ---------------------------------------
	//³ Retorna conteudo de variaveis padroes ³
	// ---------------------------------------
	NGRETURNPRM(aNGBEGINPRM)

RETURN(NIL)

//---------------------------------------------------------------------
/*/{Protheus.doc} FVZ001


@author LUCIANO CAMPOS DE SANTANA
@since 27/03/2013
@version MP11
/*/
//---------------------------------------------------------------------
FUNCTION FVZ001(cP_PARAM)

	LOCAL lRET,cOALIAS,cAUX

	lRET     := .T.
	cP_PARAM := IF(cP_PARAM==NIL,"",cP_PARAM)
	cOALIAS  := ALIAS()
	IF cP_PARAM == "X1_REVISAO" .OR.;
		cP_PARAM == "cREVISAO"

		cAUX := IF(cP_PARAM=="cREVISAO",cREVISAO,MV_PAR09)
		IF ! EMPTY(cAUX)
			TDR->(DBSETORDER(1))
			IF ! (TDR->(DBSEEK(XFILIAL("TDR")+AVKEY(cAUX,"TDR_REVISAO"))))
				MSGINFO(STR0035,STR0032) //"Revisao invalida !" ## "Atencao"
				lRET := .F.
			ENDIF
		ELSEIF cP_PARAM == "cREVISAO"
			IF EMPTY(cREVISAO)
				MSGINFO(STR0036,STR0032) //"Preenchimento Obrigatorio do campo Revisao !" ## "Atencao"
				lRET := .F.
			ENDIF
		ENDIF
	ELSEIF cP_PARAM == "bOK"
		IF ! FVZ001("cREVISAO")
			lRET := .F.
		ENDIF
	ELSEIF cP_PARAM == "MARCA"
		IF ! EMPTY(( cTRBTMPA )->TMPA_FLAG)
			( cTRBTMPA )->TMPA_FLAG := ""
		ELSE
			( cTRBTMPA )->TMPA_FLAG := cMARCA
		ENDIF
	ELSEIF cP_PARAM == "TMPA_TO_TAB"
		PROCREGUA(0)
		( cTRBTMPA )->(DBGOTOP())
		DO WHILE ! ( cTRBTMPA )->(EOF())
			INCPROC(STR0037) // "Gravando..."
			TAB->(DBSETORDER(1))
			IF (TAB->(DBSEEK(XFILIAL("TAB")+( cTRBTMPA )->(TAB_ORDEM+TAB_CODASP))))
				TAB->(RECLOCK("TAB",.F.))
				IF ! EMPTY(( cTRBTMPA )->TMPA_FLAG)
					TAB->TAB_REVISA := cREVISAO
				ELSE
					TAB->TAB_REVISA := ""
				ENDIF
			ENDIF
			( cTRBTMPA )->(DBSKIP())
		ENDDO
	ELSEIF cP_PARAM == "bPESQUISA"
		cAUX := ( cTRBTMPA )->(RECNO())
		( cTRBTMPA )->(DBSETORDER(2))
		IF ! (( cTRBTMPA )->(DBSEEK(ALLTRIM(cPESQUISA))))
			MSGINFO(STR0038,STR0032)  //"Ordem+Aspecto nao encontrada !" ## "Atencao"
			( cTRBTMPA )->(DBGOTO(cAUX))
		ENDIF
		( cTRBTMPA )->(DBSETORDER(1))
	ENDIF
	IF ! EMPTY(cOALIAS)
		DBSELECTAREA(cOALIAS)
	ENDIF

RETURN(lRET)

//---------------------------------------------------------------------
/*/{Protheus.doc} INCTRBBRW


@author LUCIANO CAMPOS DE SANTANA
@since 27/03/2013
@version MP11
/*/
//---------------------------------------------------------------------
STATIC FUNCTION INCTRBBRW()

	LOCAL cQRYA,lRET,/*lAPPEND,*/nA,cCPTMPA

	lRET  := .T.
	cQRYA := "SELECT * FROM "+RETSQLNAME("TAB")+ " WHERE"

	// CONDICAO PARA REVISAO
	IF ! EMPTY(MV_PAR09)
		cQRYA := cQRYA+" ( TAB_REVISA = '"+MV_PAR09+"' OR TAB_REVISA = ''"
	ELSE
		cQRYA := cQRYA+" ( TAB_REVISA = ''"
	ENDIF
	// CONDICAO PARA DATA
	IF ! EMPTY(MV_PAR01) .AND. ! EMPTY(MV_PAR02)
		cQRYA := cQRYA+" AND TAB_DTRESU >= '"+DTOS(MV_PAR01)+"' AND TAB_DTRESU <= '"+DTOS(MV_PAR02)+"'"
	ELSEIF ! EMPTY(MV_PAR01) .AND. EMPTY(MV_PAR02)
		cQRYA := cQRYA+" AND TAB_DTRESU >= '"+DTOS(MV_PAR01)+"'"
	ELSEIF EMPTY(MV_PAR01) .AND. ! EMPTY(MV_PAR02)
		cQRYA := cQRYA+" AND TAB_DTRESU <= '"+DTOS(MV_PAR02)+"'"
	ENDIF
	// CONDICAO PARA AVALIACAO
	IF ! EMPTY(MV_PAR03) .AND. ! EMPTY(MV_PAR04)
		cQRYA := cQRYA+" AND TAB_ORDEM >= '"+MV_PAR03+"' AND TAB_ORDEM <= '"+MV_PAR04+"'"
	ELSEIF ! EMPTY(MV_PAR03) .AND. EMPTY(MV_PAR04)
		cQRYA := cQRYA+" AND TAB_ORDEM >= '"+MV_PAR03+"'"
	ELSEIF EMPTY(MV_PAR03) .AND. ! EMPTY(MV_PAR04)
		cQRYA := cQRYA+" AND TAB_ORDEM <= '"+MV_PAR04+"'"
	ENDIF
	// CONDICAO PARA ASPECTO
	IF ! EMPTY(MV_PAR05) .AND. ! EMPTY(MV_PAR06)
		cQRYA := cQRYA+" AND TAB_CODASP >= '"+MV_PAR05+"' AND TAB_CODASP <= '"+MV_PAR06+"'"
	ELSEIF ! EMPTY(MV_PAR05) .AND. EMPTY(MV_PAR06)
		cQRYA := cQRYA+" AND TAB_CODASP >= '"+MV_PAR05+"'"
	ELSEIF EMPTY(MV_PAR05) .AND. ! EMPTY(MV_PAR06)
		cQRYA := cQRYA+" AND TAB_CODASP <= '"+MV_PAR06+"'"
	ENDIF
	// CONDICAO PARA IMPACTO
	IF ! EMPTY(MV_PAR07) .AND. ! EMPTY(MV_PAR08)
		cQRYA := cQRYA+" AND TAB_CODIMP >= '"+MV_PAR07+"' AND TAB_CODIMP <= '"+MV_PAR08+"'"
	ELSEIF ! EMPTY(MV_PAR07) .AND. EMPTY(MV_PAR08)
		cQRYA := cQRYA+" AND TAB_CODIMP >= '"+MV_PAR07+"'"
	ELSEIF EMPTY(MV_PAR07) .AND. ! EMPTY(MV_PAR08)
		cQRYA := cQRYA+" AND TAB_CODIMP <= '"+MV_PAR08+"'"
	ENDIF


  	cQRYA := cQRYA+") AND D_E_L_E_T_ = '' AND TAB_FILIAL = '"+XFILIAL("TAB")+"'"

	MPSysOpenQuery( cQRYA , "QRYA" )
	IF QRYA->(EOF()) .AND. QRYA->(BOF())
		lRET := .F.
	ENDIF
	PROCREGUA(0)
	DO WHILE ! QRYA->(EOF())
		IncProc(STR0039) //"Processando..."
		( cTRBTMPA )->(DBAPPEND())
		FOR nA := 1 TO ( cTRBTMPA )->(FCOUNT())
			cCPTMPA := ( cTRBTMPA )->(FIELDNAME(nA))
			IF QRYA->(FIELDPOS(cCPTMPA)) > 0
				cCTQRYA := QRYA->(FIELDGET(FIELDPOS(cCPTMPA)))
				IF VALTYPE(( cTRBTMPA )->(FIELDGET(nA))) == "D"
					cCTQRYA := CTOD(RIGHT(cCTQRYA,2)+"/"+SUBSTR(cCTQRYA,5,2)+"/"+LEFT(cCTQRYA,4))
				ENDIF
				( cTRBTMPA )->(FIELDPUT(nA,cCTQRYA))
			ENDIF
		NEXT
		// GRAVA DESCRICAO DO ASPECTO
		TA4->(DBSETORDER(1))
		TA4->(DBSEEK(XFILIAL("TA4")+( cTRBTMPA )->TAB_CODASP))
		( cTRBTMPA )->TAB_NOMASP := TA4->TA4_DESCRI
		// GRAVA DESCRICAO DO IMPACTO
		TAE->(DBSETORDER(1))
		TAE->(DBSEEK(XFILIAL("TAE")+( cTRBTMPA )->TAB_CODIMP))
		( cTRBTMPA )->TAB_NOMIMP := TAE->TAE_DESCRI
		// GRAVA DESCRICAO DO NIVEL
		TAF->(DBSETORDER(8))
		TAF->(DBSEEK(XFILIAL("TAF")+( cTRBTMPA )->TAB_CODNIV))
		( cTRBTMPA )->TAB_DESNIV := TAF->TAF_NOMNIV
		*
		IF ! EMPTY(( cTRBTMPA )->TAB_REVISA)
			( cTRBTMPA )->TMPA_FLAG := cMARCA
		ENDIF
		QRYA->(DBSKIP())
	ENDDO
	QRYA->(DBCLOSEAREA())
	( cTRBTMPA )->(DBGOTOP())

RETURN(lRET)