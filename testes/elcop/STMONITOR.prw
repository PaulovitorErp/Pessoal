//#INCLUDE "POSCSS.CH"
#INCLUDE "TOTVS.CH"
#INCLUDE "TBICONN.CH"
#INCLUDE "XMLXFUN.CH"
#INCLUDE "TOPCONN.CH"
#Include "SIGAWIN.CH"

Static aIDEnt := {}	//IDENT da tabela SPED000 para NFC-e e NF-e

//--------------------------------------------------------------
/*/{Protheus.doc} STMonitor
Description

@param xParam Parameter Description
@return xRet Return Description
@author Anderson Machado - anderson.machado.go@gmail.com
@since 19/01/2018


STYLE nOr(WS_VISIBLE, WS_POPUP)

/*/
//--------------------------------------------------------------
User Function STMonitor()
	Local oBVendas := {}, oBExportar := {}, oBFechar := {}, oBLegenda := {}, oBPesquisar := {}, oGrpSituacao := {}
	Local oBPrint := {}, oBStatusSFZ := {}, oGetPesquisa := {}
	Local oGrpModelo := {}, oGrpNF := {}, oGrpPeriodo := {}, oGrpPesquisa := {}
	Local oSayPesq := {}
	Local cGetPesquisa := Space(40)
	Local nLBoxModelo := 1, nLBoxPeriodo := 1, nLBoxSituacao := 1

	Local oButton1, oButton2, oCheckBo1
	Local oSay1, oSay2, oSay3, oSay4, oSay5, oSay6, oSay7
	Local oGet1, oGet2, oGet3, oGet4, oGet5, oGet6, oGet7
	//Local oFontGrid	:= TFont():New("Arial",,016,,.F.,,,,,.F.,.F.)

	Private __XVEZ := "0"
	Private lCheckBo1 := .F.
	Private lCheckBo2 := .F.
	Private lCheckBo3 := .T. //por default processa um unico dia
	Private cGet1 := Space(TamSx3("LW_OPERADO")[1])
	Private cGet2 := Space(TamSx3("LW_NUMMOV")[1])
	Private cGet3 := Space(TamSx3("A6_NOME")[1])
	Private cGet4 := Space(TamSx3("LW_ESTACAO")[1])
	Private cGet5 := Space(TamSx3("LW_PDV")[1])
	Private dGet6 := CtoD("")
	Private cGet7 := Space(TamSx3("LW_HRABERT")[1])

	Private oDlgMonitorTotvsPDV := {}, oMSGetNotas := {}, oBKPGetNotas := {}
	Private oLBoxPeriodo := {}, oLBoxModelo := {}, oLBoxSituacao := {}, dGetDt := CtoD("")

// Recupera handler da conexão atual com o DBAccess
// Esta conexão foi feita pelo Framework do AdvPL, usando TCLink()

	Private lUsaQuery	:= .F.

//-- Determina ID
	Private cIdEntNFe	:= "" //URetEntTss("55",.F.) //RetIdEnti()
	Private cURLNFe		:= AllTrim( GetMV("MV_SPEDURL") )

	Private cIdEntNFCe	:= "" //URetEntTss("65",.F.) //StaticCall(LOJNFCE,LjNFCeIDEnt)
	Private cURLNFCe	:= AllTrim( GetMV("MV_NFCEURL") )

	cIdEntNFe  := URetEntTss("55",.F.)
	cIdEntNFCe := URetEntTss("65",.F.)

	#IFDEF TOP
		lUsaQuery := .T.
		U_PROtcSetConn() //seta conexão para banco Protheus
	#ENDIF

	If !U_TSStcSetConn() //abre ou seta conexão para banco TSS
		MsgStop( "Falha ao conectar com banco do TSS",  "Atenção")
		Return .F.
	Else

		U_PROtcSetConn() //seta conexão para banco Protheus

		DEFINE MSDIALOG oDlgMonitorTotvsPDV TITLE "Monitor de Notas Fiscais Eletrônicas - Varejo" ;
			FROM 000, 000  TO 555, 1000 ;
			COLORS 0, 16777215 PIXEL ;
			STYLE DS_MODALFRAME STATUS

		@ 001, 008 GROUP oGrpPesquisa TO 095, 332 PROMPT " Opções de Pesquisa " OF oDlgMonitorTotvsPDV COLOR 0, 16777215 PIXEL

		@ 008, 014 GROUP oGrpPeriodo 	TO 088, 074 PROMPT " Período " OF oDlgMonitorTotvsPDV COLOR 0, 16777215 PIXEL
		oLBoxPeriodo := TListBox():New(015,019,{|u|if(Pcount()>0,nLBoxPeriodo:=u,nLBoxPeriodo)},;
			{"Diário","Últimos 2 dias","Últimos 4 dias","Semanal","Mensal","A partir de:","Única Nota"},050,048,,oDlgMonitorTotvsPDV,,,,.T.)
		oLBoxPeriodo:bLClicked := {|| StiLoadData() }

		//@ 008, 198 SAY oSayDt PROMPT "A partir de:" SIZE 025, 007 OF oDlgMonitorTotvsPDV COLORS 0, 16777215 PIXEL
		@ 064, 020 MSGET  oGetDt VAR dGetDt SIZE 050, 010 OF oDlgMonitorTotvsPDV ON CHANGE {|| StiLoadData() } PICTURE "@!" COLORS 0, 16777215 PIXEL
		oCheckBo3 := TCheckBox():New(079,020,"Único dia",{|u| iif( PCount()==0,lCheckBo3,lCheckBo3:= u) },oDlgMonitorTotvsPDV,045,008,,,,,,,,.T.,,,)

		@ 008, 079 GROUP oGrpModelo 	TO 078, 125 PROMPT " Modelo " OF oDlgMonitorTotvsPDV COLOR 0, 16777215 PIXEL
		oLBoxModelo := TListBox():New(015,084,{|u|if(Pcount()>0,nLBoxModelo:=u,nLBoxModelo)},;
			{"Todos","NF-e","NFC-e"},036,058,,oDlgMonitorTotvsPDV,,,,.T.)
		oLBoxModelo:bLClicked := {|| StiLoadData() }

		@ 008, 130 GROUP oGrpSituacao 	TO 078, 190 PROMPT " Situação " OF oDlgMonitorTotvsPDV COLOR 0, 16777215 PIXEL
		oLBoxSituacao :=  TListBox():New(015,135,{|u|if(Pcount()>0,nLBoxSituacao:=u,nLBoxSituacao)},;
			{"Todas","Autorizadas","Canceladas","Inutilizadas","Inconsistentes"},050,058,,oDlgMonitorTotvsPDV,,,,.T.)
		oLBoxSituacao:bLClicked := {|| StiLoadData() }

		@ 056, 198 SAY oSayPesq PROMPT "Pesquisa Rápida - Digite o que deseja localizar" SIZE 130, 007 OF oDlgMonitorTotvsPDV COLORS 0, 16777215 PIXEL
		@ 064, 196 MSGET  oGetPesquisa VAR cGetPesquisa SIZE 130, 010 OF oDlgMonitorTotvsPDV ON CHANGE PesqRapida( oMSGetNotas, AllTrim(cGetPesquisa) ) PICTURE "@!" COLORS 0, 16777215 PIXEL

		@ 008, 196 BUTTON oBStatusSFZ 	PROMPT "Status SEFAZ"	SIZE 038, 020 OF oDlgMonitorTotvsPDV ACTION LjMsgRun( "Consultando Status SEFAZ",,{|| SpedNFeStatus() } )	PIXEL
		@ 008, 240 BUTTON oBPrint 		PROMPT "Reimpressão" 	SIZE 038, 020 OF oDlgMonitorTotvsPDV ACTION PrinDanfe() PIXEL
		@ 008, 284 BUTTON oBMonSefz 	PROMPT "Monitor NFC-e"	SIZE 038, 020 OF oDlgMonitorTotvsPDV ACTION LjNFCeMnt()	PIXEL
		@ 032, 196 BUTTON oBVendas		PROMPT "Integridade" 	SIZE 038, 020 OF oDlgMonitorTotvsPDV ACTION U_xMonitor(cEmpAnt, cFilAnt) PIXEL
		@ 032, 240 BUTTON oBExportar 	PROMPT "Transmissão" 	SIZE 038, 020 OF oDlgMonitorTotvsPDV ACTION TransNF() PIXEL
		@ 032, 284 BUTTON oBMonSefzN 	PROMPT "Monitor NF-e"	SIZE 038, 020 OF oDlgMonitorTotvsPDV ACTION SpedNfe1Mnt("55") PIXEL

		@ 001, 338 GROUP oGrpCx TO 095, 488 PROMPT " Dados do Caixa " OF oDlgMonitorTotvsPDV COLOR 0, 16777215 PIXEL

		nLin := 014
		nCol := 342
		@ nLin+000, nCol+005 SAY oSay1 PROMPT "Caixa:" SIZE 016, 007 OF oDlgMonitorTotvsPDV COLORS 0, 16777215 PIXEL
		@ nLin+000, nCol+056 SAY oSay2 PROMPT "Num. Mov.:" SIZE 029, 007 OF oDlgMonitorTotvsPDV COLORS 0, 16777215 PIXEL
		//@ nLin+000, nCol+110 CHECKBOX oCheckBo1 VAR lCheckBo1 PROMPT "Filtra" SIZE 024, 008 OF oDlgMonitorTotvsPDV COLORS 0, 16777215 PIXEL
		oCheckBo1 := TCheckBox():New(nLin+000,nCol+110,"Filtra",{|u| iif( PCount()==0,lCheckBo1,lCheckBo1:= u) },oDlgMonitorTotvsPDV,024,008,,,,,,,,.T.,,,)
		//oCheckBo1:bSetGet 	:= {|| lCheckBo1 }
		oCheckBo1:bLClicked	:= {|| StiLoadData()}
		@ nLin+016, nCol+005 SAY oSay3 PROMPT "Nome:" SIZE 015, 007 OF oDlgMonitorTotvsPDV COLORS 0, 16777215 PIXEL
		@ nLin+032, nCol+005 SAY oSay4 PROMPT "Estação:" SIZE 022, 007 OF oDlgMonitorTotvsPDV COLORS 0, 16777215 PIXEL
		@ nLin+032, nCol+063 SAY oSay5 PROMPT "PDV:" SIZE 014, 007 OF oDlgMonitorTotvsPDV COLORS 0, 16777215 PIXEL
		@ nLin+048, nCol+005 SAY oSay6 PROMPT "Dt Abert.:" SIZE 025, 007 OF oDlgMonitorTotvsPDV COLORS 0, 16777215 PIXEL
		@ nLin+048, nCol+080 SAY oSay7 PROMPT "Hr. Abert.:" SIZE 025, 007 OF oDlgMonitorTotvsPDV COLORS 0, 16777215 PIXEL

		nLin := 012
		@ nLin+000, nCol+022 MSGET oGet1 VAR cGet1 SIZE 031, 010 OF oDlgMonitorTotvsPDV COLORS 0, 16777215 PIXEL WHEN .F.
		@ nLin+000, nCol+085 MSGET oGet2 VAR cGet2 SIZE 020, 010 OF oDlgMonitorTotvsPDV COLORS 0, 16777215 PIXEL WHEN .F.
		@ nLin+016, nCol+022 MSGET oGet3 VAR cGet3 SIZE 111, 010 OF oDlgMonitorTotvsPDV COLORS 0, 16777215 PIXEL WHEN .F.
		@ nLin+032, nCol+030 MSGET oGet4 VAR cGet4 SIZE 031, 010 OF oDlgMonitorTotvsPDV COLORS 0, 16777215 PIXEL WHEN .F.
		@ nLin+032, nCol+077 MSGET oGet5 VAR cGet5 SIZE 031, 010 OF oDlgMonitorTotvsPDV COLORS 0, 16777215 PIXEL WHEN .F.
		@ nLin+048, nCol+030 MSGET oGet6 VAR dGet6 SIZE 050, 010 OF oDlgMonitorTotvsPDV COLORS 0, 16777215 PIXEL WHEN .F.
		@ nLin+048, nCol+105 MSGET oGet7 VAR cGet7 SIZE 020, 010 OF oDlgMonitorTotvsPDV COLORS 0, 16777215 PIXEL WHEN .F.

		nLin := 008
		@ nLin+071, nCol+056 BUTTON oButton1 PROMPT "Abr. Caixa" SIZE 037, 012 OF oDlgMonitorTotvsPDV ACTION ULJ260Abre() PIXEL
		@ nLin+071, nCol+098 BUTTON oButton2 PROMPT "Fch. Caixa" SIZE 037, 012 OF oDlgMonitorTotvsPDV ACTION ULJ260Fecha() PIXEL

		oCheckBo2 := TCheckBox():New(080,195,"Todos Status",{|u| iif( PCount()==0,lCheckBo2,lCheckBo2:= u) },oDlgMonitorTotvsPDV,045,008,,,,,,,,.T.,,,)

		@ 078, 247 BUTTON oBLegenda PROMPT "&Legenda" SIZE 037, 012 OF oDlgMonitorTotvsPDV ACTION ULegStatus() PIXEL
		@ 078, 287 BUTTON oBPesquisar  PROMPT "&Pesquisar" SIZE 037, 012 OF oDlgMonitorTotvsPDV ACTION LjMsgRun("Aguarde... Aplicando Filtro...",,{|| StiLoadData()}) PIXEL
		@ 264, 452 BUTTON oBFechar PROMPT "&Sair" SIZE 037, 012 OF oDlgMonitorTotvsPDV ACTION oDlgMonitorTotvsPDV:End() PIXEL

		@ 097, 008 GROUP oGrpNF TO 260, 488 PROMPT " Notas Fiscais Eletrônicas Emitidas " OF oDlgMonitorTotvsPDV COLOR 0, 16777215 PIXEL

		fDadosCaixa()
		fMSGetNotas()

		oMSGetNotas:oBrowse:bHeaderClick := {|oBrw1,nCol| iif(oMSGetNotas:oBrowse:nColPos <> 111, OrderGrid(oMSGetNotas,nCol), )}
		oMSGetNotas:oBrowse:nScrollType := 0
		//oMSGetNotas:oBrowse:oFont := oFontGrid
		//oMSGetNotas:oBrowse:lUseDefaultColors := .F.
		//oMSGetNotas:oBrowse:SetBlkBackColor({|| U_CorLinha(oMSGetNotas)})

		//StiLoadData()

		ACTIVATE MSDIALOG oDlgMonitorTotvsPDV CENTERED
	EndIf

	// Volta para conexão ERP
	If lUsaQuery
		U_PROtcSetConn() //seta conexão para banco Protheus
	EndIf

	U_TSSCloseDB() //fecha conexão do banco TSS

	//conout( ">> StMonitor - FIM - Data: "+DtoC(date())+" - Hora: "+time()+"")

Return

//-------------------------------------------------------------------
/*/{Protheus.doc} ULJ260Abre
Abre o caixa
@author  author
@since   date
@version version
/*/
//-------------------------------------------------------------------
Static Function ULJ260Abre()
	Local aArea := GetArea()
	Local aAreaSA6 := SA6->(GetArea())

	If Type("cOperador") <> "U" .and. !Empty(cOperador)
		SA6->(DbSetOrder(1)) // A6_FILIAL + A6_COD + A6_AGENCIA + A6_NUMCON
		If SA6->(DbSeek(xFilial("SA6") + AllTrim(cOperador)))
			LJ260Abre()
		EndIf
	EndIf

	fDadosCaixa()

	RestArea(aAreaSA6)
	RestArea(aARea)
Return

//-------------------------------------------------------------------
/*/{Protheus.doc} ULJ260Fecha
Fecha o caixa
@author  author
@since   date
@version version
/*/
//-------------------------------------------------------------------
Static Function ULJ260Fecha()
	Local aArea := GetArea()
	Local aAreaSA6 := SA6->(GetArea())

	If Type("cOperador") <> "U" .and. !Empty(cOperador)

		SA6->(DbSetOrder(1)) // A6_FILIAL + A6_COD + A6_AGENCIA + A6_NUMCON
		If SA6->(DbSeek(xFilial("SA6") + AllTrim(cOperador)))
			LJ260Fecha()
		EndIf

	EndIf

	fDadosCaixa()

	RestArea(aAreaSA6)
	RestArea(aARea)
Return

//-------------------------------------------------------------------
/*/{Protheus.doc} fDadosCaixa
Preenche os dados do caixa corrente
@author  author
@since   date
@version version
/*/
//-------------------------------------------------------------------
Static Function fDadosCaixa()

	Local aArea := GetArea()
	Local aAreaSA6 := SA6->(GetArea())

	If Type("cOperador") == "C" .and. IsCaixaLoja(cOperador) // verifica se o usuario eh um caixa

		// verifico a data de abertura deste caixa
		SA6->(DbSetOrder(1)) // A6_FILIAL + A6_COD + A6_AGENCIA + A6_NUMCON
		If SA6->(DbSeek(xFilial("SA6") + AllTrim(cOperador)))

			cGet1 := cOperador
			cGet3 := SA6->A6_NOME
			If !Empty(SA6->A6_DATAABR)
				cGet2 := LjNumMov()
				cGet4 := LJGetStation("LG_CODIGO")
				cGet5 := LJGetStation("LG_PDV")
				dGet6 := SA6->A6_DATAABR
				cGet7 := SA6->A6_HORAABR
			Else
				cGet2 := Space(TamSx3("LW_NUMMOV")[1])
				cGet4 := Space(TamSx3("LW_ESTACAO")[1])
				cGet5 := Space(TamSx3("LW_PDV")[1])
				dGet6 := CtoD("")
				cGet7 := Space(TamSx3("LW_HRABERT")[1])
			EndIf

		Endif

	Else

		cGet1 := space(TamSx3("LW_OPERADO")[1])
		cGet2 := Space(TamSx3("LW_NUMMOV")[1])
		cGet3 := Space(TamSx3("A6_NOME")[1])
		cGet4 := Space(TamSx3("LW_ESTACAO")[1])
		cGet5 := Space(TamSx3("LW_PDV")[1])
		dGet6 := CtoD("")
		cGet7 := Space(TamSx3("LW_HRABERT")[1])

	EndIf

	RestArea(aAreaSA6)
	RestArea(aARea)

Return

//-------------------------------------------------------------------
/*/{Protheus.doc} fMSGetNotas
Cria o oMSGetNotas (MsNewGetDados)
@author  author
@since   date
@version version
/*/
//-------------------------------------------------------------------
Static Function fMSGetNotas()
	Local nX := 0
	Local aHeaderEx := {}, aColsEx := {}, aAlterFields := {}
	Local aFields := {"OK","L1_EMISNF","L1_HORA","L1_DOC","A1_NREDUZ","L1_VLRLIQ","CD6_PLACA","F0T_MODELO","L1_PDV","L1_KEYNFCE","L1_RETSFZ","L1_SITUA","N0C_VALOR"}

// Define field properties
	For nX:=1 to Len(aFields)

		if aFields[nX] == "OK"
			Aadd(aHeaderEx,{"OK",;
				"COR",;
				"@BMP",;
				1,;
				0,;
				.T.,;
				"",;
				"",;
				"",;
				"R",;
				"",;
				"",;
				.F.,;
				"V",;
				"",;
				"",;
				"",;
				"",;
				0})
		elseif !Empty(GetSx3Cache(aFields[nX],"X3_CAMPO")) //verifica se o campo existe na SX3
			aadd( aHeaderEx, U_UAHEADER(aFields[nX]) )
		endif

	Next nX

	For nX := 1 to Len(aHeaderEx)
		if AllTrim(aHeaderEx[nX][2]) == "COR"
			aHeaderEx[nX][1] := "Status"
		elseif AllTrim(aHeaderEx[nX][2]) == "L1_SITUA"
			aHeaderEx[nX][1] := "St Atual"
		elseif AllTrim(aHeaderEx[nX][2]) == "L1_DOC"
			aHeaderEx[nX][1] := "Num / Serie"
		elseif AllTrim(aHeaderEx[nX][2]) == "A1_NREDUZ"
			aHeaderEx[nX][1] := "Destinatário"
		elseif AllTrim(aHeaderEx[nX][2]) == "F0T_MODELO"
			aHeaderEx[nX][1] := "Modelo"
		elseif AllTrim(aHeaderEx[nX][2]) == "N0C_VALOR"
			aHeaderEx[nX][1] := "RecNo"
		elseif AllTrim(aHeaderEx[nX][2]) == "L1_PDV"
			aHeaderEx[nX][1] := "Operador"
		endif

	Next nX

	oMSGetNotas := MsNewGetDados():New( 105, 013, 255, 481, , "AllwaysTrue", "AllwaysTrue", "+Field1+Field2", aAlterFields,, 999, "AllwaysTrue", "", "AllwaysTrue", oDlgMonitorTotvsPDV, aHeaderEx, aColsEx)
Return

//-------------------------------------------------------------------
/*/{Protheus.doc} StiLoadData
Carrega dados
@author  author
@since   date
@version version
/*/
//-------------------------------------------------------------------
Static Function StiLoadData()

	LjMsgRun("Aguarde... Filtrando dados...",,{|| CarrDados() })

Return .T.

//-------------------------------------------------------------------
/*/{Protheus.doc} CarrDados
Filtrando dados...
@author  author
@since   date
@version version
/*/
//-------------------------------------------------------------------
Static Function CarrDados()
	Local aSL1 := SL1->( GetArea() )
	Local aSA1 := SA1->( GetArea() )
	Local aSLG := SLG->( GetArea() )
	Local bPeriodo := {|| }
	Local aFieldFill := {}, aRetTSS := {}
	Local oStatus := {}
	Local cID := "", cResp := ""
	Local dData := dDataBase
	Local nX := 0
	Local nCount := 0
	Local cCodAutorizados := "100/301/302/110/205/"	// Autorizado - Denegadas vao subir e cancelar no padrao
	Local lBkpCheckBo3 := iif( Type("lCheckBo3")=="L", lCheckBo3, .T.)

//Obtemos a e MODALIDADE do TSS
	cModelo := "65" //-- NFC-e
	aGetMvTSS := LjGetMVTSS( iif(cModelo == "55", "MV_MODALID", "MV_MODNFCE"), "1", cModelo )
	If aGetMvTSS[1]
		cMvModNFCe := SubStr( aGetMvTSS[2], 1, 1 )
		If cMvModNFCe == "2"
			MsgStop( "O TSS esta em contingência. Não será possivel consultar o status das notas na Sefaz.", "STMonitor" )
			Return .T.
		EndIf
	EndIf

	If Type("oMSGetNotas") != 'O'
		Return .T.
	EndIf

	do case
	case oLBoxPeriodo:nAT == 1	//-- Diario
		bPeriodo := {|| SL1->L1_EMISSAO == dDataBase }

	case oLBoxPeriodo:nAT == 2	//-- Ultimos 2 dias
		bPeriodo := {|| SL1->L1_EMISSAO >= dDataBase-1 }
		dData := dDataBase-1

	case oLBoxPeriodo:nAT == 3	//-- Ultimos 4 dias
		bPeriodo := {|| SL1->L1_EMISSAO >= dDataBase-3 }
		dData := dDataBase-3

	case oLBoxPeriodo:nAT == 4	//-- Semana
		bPeriodo := {|| SL1->L1_EMISSAO >= dDataBase-7 }
		dData := dDataBase-7

	case oLBoxPeriodo:nAT == 5	//-- Mensal
		bPeriodo := {|| SL1->L1_EMISSAO >= dDataBase-30 }
		dData := dDataBase-30

	case oLBoxPeriodo:nAT == 6	//-- A partir de:
		if lBkpCheckBo3 .and. !Empty(DtoS(dGetDt))
			bPeriodo := {|| SL1->L1_EMISSAO = dGetDt }
			dData := dGetDt
		elseif !Empty(DtoS(dGetDt))
			bPeriodo := {|| SL1->L1_EMISSAO >= dGetDt }
			dData := dGetDt
		else
			bPeriodo := {|| .T. }
		endif
	case oLBoxPeriodo:nAT == 7 //-- Única Nota
		bPeriodo := {|| .T. }
		Return .T.
	endcase

//U_MonPDVNFE(cGet5) //-- Funcao de Monitoramento da NF-e geradas no PDV e transmissão

//-- Zera Vetor
	oMSGetNotas:aCols := {}

//-- Define field values
	SA6->( DbSetOrder(1) ) //A6_FILIAL+A6_COD+A6_AGENCIA+A6_NUMCON
	SA1->( DbSetOrder(1) ) //A1_FILIAL+A1_COD+A1_LOJA
	SL1->( DbSetOrder(7) ) //L1_FILIAL+DTOS(L1_EMISSAO)+L1_HORA

//Considera os registros deletados
	SET DELETED OFF

	if oLBoxPeriodo:nAT == 6 .and. Empty(DtoS(dGetDt))
		SL1->( DbGoTop() )
	else
		SL1->( DbSeek( xFilial("SL1") + dtos( dData ), .T. ) )
	endif

	nCount := 0
	nRecSLG := SLG->(RecNo())

	while !SL1->( Eof() ) .and. Eval(bPeriodo) .and. (nCount <= 3000) .and. (!lCheckBo3 .or. dToS(SL1->L1_EMISSAO) = dToS(dData))

		nCount++

		//-- Depois ver pq nao esta preenchendo no padrão
		If !(SL1->L1_SITUA $ '00/TX/07') .and. !Empty(SL1->L1_DOC) .and. ((Empty(SL1->L1_PDV) .and. !Empty(SL1->L1_ESTACAO)) .or. Empty(SL1->L1_NUMCFIS) .or. Empty(SL1->L1_TIPO) .or. Empty(SL1->L1_KEYNFCE))
			RecLock( "SL1", .F. )

			If SL1->L1_TPFRET <> "S"
				SL1->L1_TPFRET := "S"
			EndIf

			If Empty(SL1->L1_NUMCFIS) .and. !Empty(SL1->L1_DOC)
				SL1->L1_NUMCFIS := SL1->L1_DOC
			EndIf

			If Empty(SL1->L1_KEYNFCE) .and. SF2->( DbSetOrder(1), DbSeek( xFilial("SF2") + SL1->L1_DOC + SL1->L1_SERIE ) )
				SL1->L1_KEYNFCE := SF2->F2_CHVNFE
			EndIf

			//se for NF-e
			If !Empty(SL1->L1_KEYNFCE) .and. SubStr(L1_KEYNFCE,21,2) == '55'
				SL1->L1_IMPNF := .T.
			EndIf

			If Empty(SL1->L1_TIPO)
				SL1->L1_TIPO := "V"
			EndIf

			If SL1->L1_CONFVEN <> 'SSSSSSSSNSSS'
				SL1->L1_CONFVEN	:= 'SSSSSSSSNSSS'
			EndIf

			If Empty(SL1->L1_PDV) .and. !Empty(SL1->L1_ESTACAO) .and. SLG->( DbSetOrder(1), DbSeek( xFilial("SLG") + SL1->L1_ESTACAO ) ) //LG_FILIAL+LG_CODIGO
				SL1->L1_PDV	  := SLG->LG_PDV
			EndIf

			If Empty(SL1->L1_OPERADO)
				aDadosPDV := RetDadosPDV(SL1->L1_PDV, SL1->L1_EMISNF, SL1->L1_HORA) //[01] PDV, [02] Operador, [03] Estação, [04] Num.Movimento
				SL1->L1_OPERADO := aDadosPDV[02] //SA6->A6_COD
			EndIf

			SL1->( MsUnLock() )
			SL1->( DbCommit() )
		EndIf

		If !Empty(SL1->L1_SERIE) .and. !Empty(SL1->L1_DOC) .and. Empty(SL1->L1_KEYNFCE)

			cKeyNfe := RetKeyNfe(SL1->L1_SERIE, SL1->L1_DOC)
			If !Empty(cKeyNfe)
				RecLock( "SL1", .F. )
				SL1->L1_KEYNFCE := cKeyNfe
				SL1->( MsUnlock() )
				SL1->( DbCommit() )
			EndIf

		EndIf

		aRetTSS := StrToKarr(SL1->L1_RETSFZ,"|")
		cID := ""

		If len(aRetTSS) >= 2
			cID := aRetTSS[2]
		EndIf

		If !Empty(SL1->L1_SERIE) .and. !Empty(SL1->L1_DOC) .and. !Empty(SL1->L1_KEYNFCE) .and. (Empty(SL1->L1_RETSFZ) .or. cID <> '100' .or. (cID = '100' .and. !(SL1->L1_SITUA $ '00/TX/07') .and. Empty(SL1->L1_NUMORIG)))

			aDados := {}
			lNFe := (Substr(SL1->L1_KEYNFCE,21,2) == "55")

			//-- Vamos Verificar se foi autorizado na SEFAZ
			//-- [01] = Versao
			//-- [02] = Ambiente
			//-- [03] = Cod Retorno Sefaz
			//-- [04] = Descricao Retorno Sefaz
			//-- [05] = Protocolo
			//-- [06] = Hash
			aDados  := VldNFSefaz( .F./*não consulta no TSS Local*/, {{SL1->L1_KEYNFCE,"",lNFe}} )
			cRetSfz := aDados[05]+"|"+aDados[03]+"|"+aDados[04]

			//aDados := VldNFSefaz( .T./*consulta no TSS Local*/, {{Left(AllTrim(SL1->L1_SERIE),3), Right(AllTrim(SL1->L1_DOC),9), lNFe}} )
			//cRetSfz := aDados[01][04]+"|"+aDados[01][05]+"|"+aDados[01][06]

			If !Empty(cRetSfz)

				RecLock( "SL1", .F. )
				If aDados[03] == '100' .and. !(SL1->L1_SITUA $ '00/TX/07') .and. Empty(SL1->L1_NUMORIG)
					SL1->L1_SITUA := '00'
				EndIf
				SL1->L1_RETSFZ := cRetSfz
				SL1->( MsUnlock() )
				SL1->( DbCommit() )

				//-- forço a gravação do DOC/SERIE do item
				SL2->(DbSetOrder(1)) //L2_FILIAL+L2_NUM+L2_ITEM+L2_PRODUTO
				SL2->(DbSeek(xFilial("SL2")+SL1->L1_NUM))
				While SL2->(!Eof()) .and. SL2->(L2_FILIAL+L2_NUM) == (xFilial("SL2")+SL1->L1_NUM)
					If Empty(SL2->L2_DOC) .and. Empty(SL2->L2_SERIE)
						RecLock( "SL2", .F. )
						SL2->L2_VENDIDO := 'S'
						SL2->L2_DOC := SL1->L1_DOC
						SL2->L2_SERIE := SL1->L1_SERIE
						SL2->( MsUnlock() )
					EndIf
					SL2->(DbSkip())
				EndDo

			EndIf

		EndIf

		//-- integra as vendas autorizadas que estão com RX no PDV
		If !Empty(SL1->L1_RETSFZ) .and. (SL1->L1_SITUA == 'RX') //!(SL1->L1_SITUA $ '00/TX/07')
			aRetSFZ := StrTokArr(SL1->L1_RETSFZ,"|")
			If !Empty(SL1->L1_RETSFZ) .and. len(aRetSFZ) >= 2 .and. aRetSFZ[02] $ cCodAutorizados .and. Empty(SL1->L1_NUMORIG)

				RecLock( "SL1", .F. )
				SL1->L1_SITUA := '00'
				SL1->( MsUnlock() )
				SL1->( DbCommit() )

				//-- forço a gravação do DOC/SERIE do item
				SL2->(DbSetOrder(1)) //L2_FILIAL+L2_NUM+L2_ITEM+L2_PRODUTO
				SL2->(DbSeek(xFilial("SL2")+SL1->L1_NUM))
				While SL2->(!Eof()) .and. SL2->(L2_FILIAL+L2_NUM) == (xFilial("SL2")+SL1->L1_NUM)
					If Empty(SL2->L2_DOC) .and. Empty(SL2->L2_SERIE)
						RecLock( "SL2", .F. )
						SL2->L2_VENDIDO := 'S'
						SL2->L2_DOC := SL1->L1_DOC
						SL2->L2_SERIE := SL1->L1_SERIE
						SL2->( MsUnlock() )
					EndIf
					SL2->(DbSkip())
				EndDo

			EndIf
		EndIf

		//-- Quando marcado para filtrar pelo operador, serão mostrados somente as vendas do seu turno
		If lCheckBo1 .and. !Empty(dGet6) .and. !( ;
				AllTrim(SL1->L1_OPERADO) == AllTrim(cGet1) .and. ;
				AllTrim(SL1->L1_NUMMOV) == AllTrim(cGet2) .and. ;
				AllTrim(SL1->L1_ESTACAO) == AllTrim(cGet4) .and. ;
				AllTrim(SL1->L1_PDV) ==  AllTrim(cGet5) .and. ;
				DtoS(SL1->L1_EMISNF)+SL1->L1_HORA >= DtoS(dGet6)+cGet7 ;
				)

			//-- Ignora Registro
			SL1->( DbSkip() )
			Loop
		EndIf

		//-- Verificar Filtros
		if olBoxModelo:nAt == 2 .and. substr(SL1->L1_KEYNFCE,21,2) <> "55" .or. ;
				olBoxModelo:nAt == 3 .and. substr(SL1->L1_KEYNFCE,21,2) <> "65" .or. ;
				Empty(SL1->L1_RETSFZ) .or. Empty(SL1->L1_DOC)

			//-- Ignora Registro
			SL1->( DbSkip() )
			Loop

		else

			SA1->( DbSeek( xFilial("SA1") + SL1->L1_CLIENTE + SL1->L1_LOJA ) )

			aRetTSS := StrToKarr(SL1->L1_RETSFZ,"|")
			cID := ""

			if len(aRetTSS) >= 2
				cID := aRetTSS[2]
			endif

			//-- Filtro referente a situação
			if ( oLBoxSituacao:nAt == 2 .and. cID <> "100" ) .or. ; 			//-- Autorizadas
				( oLBoxSituacao:nAt == 3 .and. SL1->L1_SITUA <> "07" ) .or. ;	//-- Canceladas
				( oLBoxSituacao:nAt == 4 .and. ! SL1->L1_SITUA $ "T1/T2/T3" ) .or. ;		//-- Inutilizadas
				( oLBoxSituacao:nAt == 5 .and. (!Empty(SL1->L1_RETSFZ) .or. !cID $ "100/101/102/110/301/302/" ) ) ;		//-- Inconsistentes

				//-- Ignora Registro
				SL1->( DbSkip() )
				Loop

			endif

			do case
			case cID == "100"
				cResp := "Autorizado o uso da NF-e"
				oStatus := LoadBitmap( GetResources(), "BR_VERDE")

			case cID == "101"
				cResp := "Cancelamento de NF-e homologado"
				oStatus := LoadBitmap( GetResources(), "BR_AZUL")

			case cID == "102"
				cResp := "Inutilização de número homologado"
				oStatus := LoadBitmap( GetResources(), "BR_AMARELO")

			case cID == "110"
				cResp := "Uso Denegado"
				oStatus := LoadBitmap( GetResources(), "BR_LARANJA")

			case cID == "301"
				cResp := "Uso Denegado : Irregularidade fiscal do emitente"
				oStatus := LoadBitmap( GetResources(), "BR_VERMELHO")

			case cID == "302"
				cResp := "Rejeição: Irregularidade fiscal do destinatário"
				oStatus := LoadBitmap( GetResources(), "BR_VIOLETA")

			otherwise
				cID := "99"
				cResp := "Rejeição"
				oStatus := LoadBitmap( GetResources(), "BR_PRETO")

			endcase

			cSitua := SL1->L1_SITUA
		/*
			do case
			case cSitua == "  "
			cSitua := "'  ' - Base Errada, Registro Ignorado"
			case cSitua == "00"
			cSitua := "00 - Venda Efetuada com Sucesso"
			case cSitua == "01"
			cSitua := "01 - Abertura do Cupom Não Impressa"
			case cSitua == "02"
			cSitua := "02 - Impresso a Abertura do Cupom"
			case cSitua == "03"
			cSitua := "03 - Item Não Impresso"
			case cSitua == "04"
			cSitua := "04 - Impresso o Item"
			case cSitua == "05"
			cSitua := "05 - Solicitado o Cancelamento do Item"
			case cSitua == "06"
			cSitua := "06 - Item Cancelado"
			case cSitua == "07"
			cSitua := "07 - Solicitado o Cancelamento do Cupom"
			case cSitua == "08"
			cSitua := "08 - Cupom Cancelado"
			case cSitua == "09"
			cSitua := "09 - Encerrado SL1 (Não gerado SL4)"
			case cSitua == "10"
			cSitua := "10 - Encerrado a Venda"
			case cSitua == "58"
			cSitua := "58 - Status temporário durante envio da venda para o SAT (Somente PDV)"
			case cSitua == "65"
			cSitua := "65 - Status temporário durante envio da venda para a Sefaz-NFC-e (Somente PDV)"
			case cSitua == "TX"
			cSitua := "TX - Foi Enviado ao Server"
			case cSitua == "RX"
			cSitua := "RX - Foi Recebido Pelo Server"
			case cSitua == "OK"
			cSitua := "OK - Foi Processado no Server (Enviar um OK ao Client que foi Processado)."
			case cSitua == "DU"
			cSitua := "DU – Orçamento duplicado na Retaguarda"
			case cSitua == "ER"
			cSitua := "ER – Caso haja algo de errado"
			case cSitua == "FR"
			cSitua := "FR – Pedido Processado"
			case cSitua == "T1"
			cSitua := "T1 - Gravado o orçamento (antes de pegar o numero do DOC)"
			case cSitua == "T2"
			cSitua := "T2 - Consumiu numero de Doc e Serie e atualizou os campos L1_DOC e L1_SERIE"
			case cSitua == "T3"
			cSitua := "T3 - Transmitiu o documento de saída da NFC-e (TSS)"
			otherwise
			cSitua := SL1->L1_SITUA

			endcase
		*/

			SA6->(DbSeek(xFilial("SA6") + AllTrim(SL1->L1_OPERADO)))

			//-- Carrega Objeto para Apresentar ao Usuario
			aFieldFill := {}
			For nX:=1 to Len(oMSGetNotas:aHeader)

				do case
				case AllTrim(oMSGetNotas:aHeader[nX][2]) == "COR"
					aadd(aFieldFill, oStatus)
				case AllTrim(oMSGetNotas:aHeader[nX][2]) == "L1_SITUA"
					aadd(aFieldFill, cSitua)
				case AllTrim(oMSGetNotas:aHeader[nX][2]) == "L1_DOC"
					aadd(aFieldFill, SL1->L1_DOC + " / " + SL1->L1_SERIE)
				case AllTrim(oMSGetNotas:aHeader[nX][2]) == "A1_NREDUZ"
					aadd(aFieldFill, SA1->A1_NREDUZ)
				case AllTrim(oMSGetNotas:aHeader[nX][2]) == "CD6_PLACA"
					aadd(aFieldFill, SL1->L1_PLACA)
				case AllTrim(oMSGetNotas:aHeader[nX][2]) == "F0T_MODELO"
					aadd(aFieldFill, iif( (Substr(SL1->L1_KEYNFCE,21,2) == "55"), "NF-e","NFC-e" ))
				case AllTrim(oMSGetNotas:aHeader[nX][2]) == "N0C_VALOR"
					aadd(aFieldFill, SL1->( RecNo() ))
				case AllTrim(oMSGetNotas:aHeader[nX][2]) == "L1_PDV"
					aadd(aFieldFill, AllTrim(SA6->A6_NOME))
				otherwise
					aadd(aFieldFill, &("SL1->"+AllTrim(oMSGetNotas:aHeader[nX][2])))
				endcase

			Next nX
			aadd(aFieldFill,.F.)

			aadd(oMSGetNotas:aCols, aFieldFill)

		endif

		SL1->( DbSkip() )

	enddo

	SLG->(DbGoto(nRecSLG))

//Desconsidera os registros deletados
	SET DELETED ON

//--
//oMSGetNotas:aCols := aSort(oMSGetNotas:aCols,,, { |x, y| x > y } )
	oBKPGetNotas := oMSGetNotas:aCols
	oMSGetNotas:Refresh()

	RestArea(aSLG)
	RestArea(aSA1)
	RestArea(aSL1)
Return .T.


//-------------------------------------------------------------------
/*/{Protheus.doc} SpedNFeStatus
Abre monitor de notas
@author  author
@since   date
@version version
/*/
//-------------------------------------------------------------------
Static Function SpedNFeStatus()
	Local aSL1 := SL1->( GetArea() )

//-- Posiciona para Impressao
	If oMSGetNotas:aCols[oMSGetNotas:nAt][aScan(oMSGetNotas:aHeader,{|x| AllTrim(x[2])=="N0C_VALOR"})] > 0

		SL1->( DbGoTo( oMSGetNotas:aCols[oMSGetNotas:nAt][aScan(oMSGetNotas:aHeader,{|x| AllTrim(x[2])=="N0C_VALOR"})] ) )

		//-- abrir monitor de notas: SpedNFe6Mnt(cSerie,cNotaIni,cNotaFim, lCte, lMDFe, cModel)
		SpedNFe6Mnt(SL1->L1_SERIE, SL1->L1_DOC, SL1->L1_DOC, .T.)

	EndIf

	RestArea(aSL1)
Return

//-------------------------------------------------------------------
/*/{Protheus.doc} PrinDanfe
Impressão do DANFE
@author  author
@since   date
@version version
/*/
//-------------------------------------------------------------------
Static Function PrinDanfe()

	Local aSL1 := SL1->( GetArea() )

	Private aFilBrw := {"SF2","F2_FILIAL=='"+xFilial("SF2")+"'"}
	Private aIndArq := {}

//-- Posiciona para Impressao
	If oMSGetNotas:aCols[oMSGetNotas:nAt][aScan(oMSGetNotas:aHeader,{|x| AllTrim(x[2])=="N0C_VALOR"})] > 0

		SL1->( DbGoTo( oMSGetNotas:aCols[oMSGetNotas:nAt][aScan(oMSGetNotas:aHeader,{|x| AllTrim(x[2])=="N0C_VALOR"})] ) )

		CursorWait()
		if SL1->(!Eof())

			//-- Validacao para garantir que a reimpressao ocorrera apenas se autorizado
			if !SL1->L1_SITUA $ '00/TX'
				u_uHelp("CANCELAMENTO/INUTULIZAÇÃO NF-e/NFC-e","Nota não encontrada/autorizada!!!","Entre no MONITOR e verifique o motivo retornado pela SEFAZ!")

				if SL1->L1_SITUA == '07'
					//--- Imprime comprovante Nao-Fiscal referente a Solicitacao de Cancelamento de NFC-e
					LjNFCePrtC(SL1->L1_PDV, SL1->L1_DOC, SL1->L1_SERIE, dDatabase, Time())
				endif

				//-- NFC-e
			elseif SL1->L1_SERIE == SLG->LG_SERIE
				//LJMsgRun("Reimprimindo NFC-e ...",,{|| StaticCall(ULOJA066, ImpDanfe, 1) })

			else //-- NF-e

				//-- Danfe Simplificado
				if GetNewPar("MV_LJTXNFE", 0) == 3
					//LJMsgRun("Reimprimindo NF-e Simplificada...",,{|| StaticCall(ULOJA066, ImpDanfe, 3) } )

				elseif GetNewPar("MV_LJTXNFE", 0) == 2
					SF2->( DbSetOrder(1), DbSeek( xFilial("SF2") + SL1->L1_DOC + SL1->L1_SERIE ) )
					//LJMsgRun("Reimprimindo NF-e (A4)...",,{|| StaticCall(ULOJA066, ImpDanfe, 2) })

				endif

			endif

		endif

	EndIf
	CursorArrow()

	RestArea(aSL1)
Return

//-------------------------------------------------------------------
/*/{Protheus.doc} PesqRapida
Pesquisa Rapida
@author  author
@since   date
@version version
/*/
//-------------------------------------------------------------------
Static Function PesqRapida(oMSGetNotas,cGetPesquisa)
	Local aColsMatch := {}, aColsOut := {}
	Local ix := 0, iy := 0, nFim := (len(oMSGetNotas:aHeader)-2)
	Local lFound := .F.

	oMSGetNotas:SetArray( aClone(oBKPGetNotas ) )

	for ix:=1 to len(oMSGetNotas:aCols)

		//-- Verificar se existe uma semelhanca
		//-- Vamos varrer todas as colunas
		lFound := .F.
		for iy:=2 to nFim

			do case
			case ValType( oMSGetNotas:aCols[ix][iy] ) == "D" .and. cGetPesquisa $ dtoc( oMSGetNotas:aCols[ix][iy] )
				lFound := .T.
				Exit

			case ValType( oMSGetNotas:aCols[ix][iy] ) == "C" .and. cGetPesquisa $ oMSGetNotas:aCols[ix][iy]
				lFound := .T.
				Exit

			case ValType( oMSGetNotas:aCols[ix][iy] ) == "N" .and. cGetPesquisa $ Transform( oMSGetNotas:aCols[ix][iy],"@E 99999999.99" )
				lFound := .T.
				Exit

			endcase

		next iy

		if lFound
			aadd(aColsMatch, aClone(oMSGetNotas:aCols[ix]) )
		else
			aadd(aColsOut, aClone(oMSGetNotas:aCols[ix]) )
		endif

	next ix

	ix := Len(oMSGetNotas:aCols)
	if Len(aColsMatch) < len(oMSGetNotas:aCols)

		//-- Zera Array
		oMSGetNotas:aCols := {}

		//-- Preenche com os dados encontrados
		oMSGetNotas:SetArray( aClone(aColsMatch) )

	endif

	oMSGetNotas:GoTop()
Return .T.

//-------------------------------------------------------------------
/*/{Protheus.doc} xMonitor
Verificar quais notas nao estao na base do cliente!!!
@author  author
@since   date
@version version
/*/
//-------------------------------------------------------------------
User Function xMonitor(cEmpAmb, cFilAmb, dApartir)

	Local   aArea	  := GetArea()
	Local   aSay      := {}
	Local   aButton   := {}
	Local   aMarcadas := {}
	Local   cTitulo   := "RECUPERAÇÃO DE NOTAS VIA XML - POSTO INTELIGENTE"
	Local   cDesc1    := "Esta rotina tem como objetivo fazer a importação de XMLs (SPED050)."
	Local   cDesc2    := "Serão importados as vendas que estão na SEFAZ porem por algum motivo "
	Local   cDesc3    := "não estão no sistema."
	Local   cDesc4    := ""
	Local   cDesc5    := "Escolha um local para salvar os LOGs."
	//Local   cDesc6    := ""
	//Local   cDesc7    := ""
	Local   lOk       := .F.
	Local   cPasta    := "\AUTOCOM"
	Local   lBkpCheckBo3 := iif( Type("lCheckBo3")=="L", lCheckBo3, .T.)
	Local   cArqINI   := GetAdv97()      	// Retorna o nome do arquivo INI do server
	Local   cIsCPDV   := GetPvProfString("CPDV", "ISCPDV", "", cArqINI) // Identifica no INI se eh Central de PDV
	Local   nPrzSfz   := SuperGetMV("MV_XMONSFZ",,6) //-- LIMITE SEFAZ: ultimos 6 meses (prazo maximo para consulta de chave na sefaz)
	Local   aParamBox := {}, aRet := {}
	Local cSerie := "", cDocumento := "", cNfeId := ""

	Private lIsCPDV	   := .F. // Eh central de PDV
	Private lUnicDia   := iif( Type("lCheckBo3")=="L", lCheckBo3, .T.)

	Private lAuto     := IsBlind() .or. (cEmpAmb <> NIL .and. cFilAmb <> NIL ) //( cEmpAmb <> NIL .or. cFilAmb <> NIL )
	Private cPathXML  := ""
	Private lPathXML  := .F.
	Private	cPathSX	  := ""
	Private cErroLOG  := "\AUTOCOM\STMONITOR"  //+"LOG" + cEmpAnt + StrTran(Alltrim(cFilAnt)," ","")

	Private oMainWnd  := NIL

	Default dApartir  := iif(!IsBlind(),CtoD(""),MonthSub(Date(),nPrzSfz)) //-- LIMITE SEFAZ: ultimos 6 meses (prazo maximo para consulta de chave na sefaz)

	If lAuto .and. ( cEmpAmb = NIL .or. cFilAmb = NIL )
		cEmpAmb := cEmpAnt
		cFilAmb := cFilAnt
	EndIf

//Obtemos a e MODALIDADE do TSS
	cModelo := "65" //-- NFC-e
	aGetMvTSS := LjGetMVTSS( iif(cModelo == "55", "MV_MODALID", "MV_MODNFCE"), "1", cModelo )
	If aGetMvTSS[1]
		cMvModNFCe := SubStr( aGetMvTSS[2], 1, 1 )
		If cMvModNFCe == "2"
			MsgStop( "O TSS esta em contingência. Não será possivel consultar o status das notas na Sefaz.", "STMonitor" )
			Return
		EndIf
	EndIf

	Static oSay

	If AllTrim(cIsCPDV) = "1"
		// Indica que o sistema foi iniciado como Central de PDV
		lIsCPDV := .T.
	EndIf

	If !ExistDir(cPasta)
		nRet := MakeDir( cPasta )
		If nRet != 0
			//conout( "Não foi possível criar o diretório "+cPasta+". Erro: " + cValToChar( FError() ) )
		EndIf
	EndIf

	If !ExistDir(cErroLOG )
		nRet := MakeDir( cErroLOG  )
		If nRet != 0
			//conout( "Não foi possível criar o diretório "+cErroLOG +". Erro: " + cValToChar( FError() ) )
		EndIf
	EndIf

	If Type("oLBoxPeriodo") != "U" .and. oLBoxPeriodo:nAT == 7	//-- Única Nota
		aParamBox := {}
		aAdd(aParamBox,{1,"Serie",Space(TamSx3("L1_SERIE")[1]),"","","","",0,.F.}) // Tipo caractere
		aAdd(aParamBox,{1,"Documento",Space(TamSx3("L1_DOC")[1]),"","","","",0,.F.}) // Tipo caractere
		If ParamBox(aParamBox,"Selecione a nota para processamento: ",@aRet)
			cSerie := aRet[01]
			cDocumento := aRet[02]
		Else
			return
		EndIf

		if ValType(dGetDt) == 'D' .and. !Empty(DtoS(dGetDt))
			dApartir := dGetDt
		else
			dApartir := Date()
		endif
		cNfeId := cSerie + cDocumento

	ElseIf Empty(DtoS(dApartir)) .and. Type("oLBoxPeriodo") != "U"
		do case
		case oLBoxPeriodo:nAT == 1	//-- Diario
			dApartir := Date()

		case oLBoxPeriodo:nAT == 2	//-- Ultimos 2 dias
			dApartir := DaySub(Date(),1)

		case oLBoxPeriodo:nAT == 3	//-- Ultimos 4 dias
			dApartir := DaySub(Date(),3)

		case oLBoxPeriodo:nAT == 4	//-- Semana
			dApartir := DaySub(Date(),7)

		case oLBoxPeriodo:nAT == 5	//-- Mensal
			dApartir := MonthSub(Date(),1)

		case oLBoxPeriodo:nAT == 6	//-- A partir de:
			if ValType(dGetDt) == 'D' .and. !Empty(DtoS(dGetDt))
				dApartir := dGetDt
			else
				dApartir := MonthSub(Date(),nPrzSfz) //-- LIMITE SEFAZ: ultimos 6 meses
			endif

		endcase
	ElseIf Empty(DtoS(dApartir))
		dApartir := MonthSub(Date(),nPrzSfz) //-- LIMITE SEFAZ: ultimos 6 meses (prazo maximo para consulta de chave na sefaz)
	Else
		lCheckBo3 := .F. //como veio do fechamento de caixa, seta para .F. para não processar um unico dia
	EndIf

	lUnicDia := iif( Type("lCheckBo3")=="L", lCheckBo3, .T.)

	#IFDEF TOP
		TCInternal( 5, "*OFF" ) // Desliga Refresh no Lock do Top
	#ENDIF

	__cInterNet := NIL
	__lPYME     := .F.

	Set Dele On //-- habilita filtro do campo DELET

// Mensagens de Tela Inicial
	aAdd( aSay, "RECUPERAÇÃO DE NOTAS - POSTO INTELIGENTE")
	aAdd( aSay, "" )
	aAdd( aSay, cDesc1 )
	aAdd( aSay, cDesc2 )
	aAdd( aSay, cDesc3 )
	aAdd( aSay, cDesc4 )
	aAdd( aSay, cDesc5 )
//aAdd( aSay, cDesc6 )
//aAdd( aSay, cDesc7 )

// Botoes Tela Inicial
	aAdd(  aButton, {  1, .T., { || lOk := .T., FechaBatch() } } )
	aAdd(  aButton, {  2, .T., { || lOk := .F., FechaBatch() } } )

	If lAuto
		lOk := .T.
	Else
		FormBatch( cTitulo, aSay, aButton )
	EndIf

/* -- IMPORTACAO DE XML VIA ARQUIVOS - MARACANA
	If MsgYesNo("Deseja importar vendas via arquivos XMLs?")
	lPathXML := .T.
	EndIf
*/

	If lOk
		If lAuto
			aMarcadas :={{ AllTrim(cEmpAmb), AllTrim(cFilAmb), AllTrim(cEmpAmb) + AllTrim(cFilAmb) }}
		Else
			aMarcadas := EscEmpresa() //{SM0->M0_CODIGO, SM0->M0_CODFIL, SM0->M0_CODIGO + SM0->M0_CODFIL}
		EndIf

		If !Empty( aMarcadas )

			If lAuto
				cPathSX := cErroLOG+iif(IsSrvUnix(),"/","\")
			Else
				cPathSX := cGetFile( "Selecione LOG | " , OemToAnsi( "Selecione Diretorio LOG" ) , NIL , "C:\" , .F. , GETF_LOCALHARD+GETF_RETDIRECTORY )
				iif((len(cPathSX)>0) .and. (substr(cPathSX,Len(cPathSX),1)<>"\"), cPathSX:=cPathSX+"\", )
			EndIf
			If lAuto .OR. MsgNoYes( "Confirma a recuperação de vendas ?", cTitulo )

				FWMsgRun(, {|oSay| lOk := xMonitor2( lAuto, oSay, aMarcadas, dApartir, cNfeID ) }, "Aguarde... Recuperação de vendas...", "Processando recuperação de vendas...")
				//FWMsgRun(, {|oSay| lOk := xMonitor3( lAuto, oSay, aMarcadas, dApartir ) }, "Aguarde... Inutilização de sequencial de notas...", "Processando inutilização de sequencial de notas...")
				//FWMsgRun(, {|oSay| lOk := xMonitor4( lAuto, oSay, aMarcadas, dApartir ) }, "Aguarde... Integração de vendas", "Processando integração de vendas...")

				If lAuto
					If lOk
						MsgStop( "STMonitor - Processamento realizado.", "STMonitor" )
						//dbCloseAll()
					Else
						MsgStop( "STMonitor - Processamento não realizado.", "STMonitor" )
						//dbCloseAll()
					EndIf
				Else
					If lOk
						Alert( "STMonitor - Processamento concluído." )
					Else
						Alert( "STMonitor - Processamento não realizado." )
					EndIf
				EndIf

			Else
				MsgStop( "STMonitor - Processamento não realizado.", "STMonitor" )

			EndIf

		Else
			MsgStop( "STMonitor - Processamento não realizado.", "STMonitor" )

		EndIf

	EndIf

	lCheckBo3 := lBkpCheckBo3

	RestArea(aArea)
Return

//-------------------------------------------------------------------
/*/{Protheus.doc} xMonitor2
processa a recuperação de vendas
@author  author
@since   date
@version version
/*/
//-------------------------------------------------------------------
Static Function xMonitor2( lAuto, oSay, aMarcadas, dApartir, cNfeId )

	Local cSQL := "", cXML := "", cError := "", cWarning := ""
	Local aDados := {}, aAutoriz := {}, oXML := NIL
	Local aRecnoSM0 := {}
	Local cRetSfz := ""

	Local nCount := 0, nCountSPDX := 0

	Local aFiles := {}
	Local nFiles := 0
	Local cFile	 := ""
	Local nX := 0, nV := 0, nW := 0, nI := 0
	Local lOk := .F.
	Local cTiposDoc := AllTrim( SuperGetMV( 'MV_ESPECIE' ) ) // Tipos de documentos fiscais utilizados na emissao de notas fiscais //1=SPED;U=NFS;UNI=RPS;4=SPED;5=NFCE;
		Local aTiposDoc := StrTokArr(cTiposDoc,';')
	Local cDocSerie := ""
	Local lCentPDV  := IIf( ExistFunc("LjGetCPDV"), LjGetCPDV()[1] , .F. ) // Eh Central de PDV
	Local bNoHasVar := {|cVar| Type(cVar) == "U" }
	Local bGetMvFil	:= {|cPar,cDef| SuperGetMV(cPar,,cDef) }

	Private lNFe := .F.

	Private cNomeArq 	:= ""
	Private cTexto 		:= ""
	Private cNotas 		:= "" //"Filial;Dt.Emis;Documento;Serie;Chave;Tipo;Vlr.Total;Status;" + CRLF
	Private cNfErro		:= ""

	Default cNfeId := ""

//Public cEmpAnt := "02", cFilAnt := "0101" //MARAJO - APARECIDAO

	For nX:=1 to Len(aTiposDoc) //1=NF;7=SPED;U=NFS;UNI=RPS;6=NFCE;
			aTiposDoc[nX] := StrTokArr(aTiposDoc[nX],'=')
		If AllTrim(aTiposDoc[nX][2]) == "SPED" .or. AllTrim(aTiposDoc[nX][2]) == "NFCE"
			If Empty(cDocSerie)
				cDocSerie := "'"+AllTrim(aTiposDoc[nX][1])+"'"
			Else
				cDocSerie += ", '"+AllTrim(aTiposDoc[nX][1])+"'"
			EndIf
		EndIf
	Next

	If Empty(cPathSX)
		cPathSX := cErroLOG+iif(IsSrvUnix(),"/","\")
	EndIf

	If !MyOpenSm0(.T.)
		Return .F.
	EndIf

	dbSelectArea( "SM0" )
	dbGoTop()

//aMarcadas -> {SM0->M0_CODIGO, SM0->M0_CODFIL, SM0->M0_CODIGO + SM0->M0_CODFIL}
	While !SM0->( EOF() )
		// So adiciona no aRecnoSM0 se a empresa for diferente
		If aScan( aRecnoSM0, { |x| AllTrim(x[2]) == AllTrim(SM0->M0_CODIGO) .and. AllTrim(x[3]) == AllTrim(SM0->M0_CODFIL) } ) == 0 ;
				.AND. aScan( aMarcadas, { |x| AllTrim(x[1]) == AllTrim(SM0->M0_CODIGO) .and. AllTrim(x[2]) == AllTrim(SM0->M0_CODFIL) } ) > 0
			aAdd( aRecnoSM0, { SM0->(Recno()), SM0->M0_CODIGO, SM0->M0_CODFIL } )
		EndIf
		SM0->( dbSkip() )
	EndDo

//SM0->( dbCloseArea() )

	For nI := 1 To Len( aRecnoSM0 )

		SM0->( dbGoTo( aRecnoSM0[nI][1] ) )

		If !lAuto
			//-- Preparar ambiente local
			//RpcSetType( 3 )
			//RpcSetEnv( SM0->M0_CODIGO, SM0->M0_CODFIL )

			cEmpAnt := AllTrim(SM0->M0_CODIGO)
			cFilAnt := AllTrim(SM0->M0_CODFIL)

			//-- Preparar ambiente local na retagauarda
			RpcSetType(3)
			//PREPARE ENVIRONMENT EMPRESA cEmpAnt FILIAL cFilAnt MODULO "SIGALOJA"
			PREPARE ENVIRONMENT EMPRESA cEmpAnt FILIAL cFilAnt MODULO "FRT"

		EndIf

		If Eval(bNoHasVar, "cIdEntNFe") //Type("cIdEntNFe") == "U"
			//-- Determina ID
			Private cIdEntNFe	:= URetEntTss("55",.F.) //RetIdEnti()
			Private cURLNFe		:= Alltrim(Eval(bGetMvFil,"MV_SPEDURL","")) //AllTrim( GetMV("MV_SPEDURL") )

			Private cIdEntNFCe	:= URetEntTss("65",.F.) //StaticCall(LOJNFCE,LjNFCeIDEnt)
			Private cURLNFCe	:= Alltrim(Eval(bGetMvFil,"MV_NFCEURL","")) //AllTrim( GetMV("MV_NFCEURL") )
		EndIf

		cPathXML := ""
		If lPathXML
			cPathXML := cGetFile( "*.xml|*.xml" , OemToAnsi( "Selecione Diretorio XML: "+AllTrim(SM0->M0_CODFIL)+"/"+AllTrim(SM0->M0_NOMECOM) ) , NIL , "C:\" , .F. , GETF_LOCALHARD+GETF_RETDIRECTORY )
		EndIf

		//-- Faz verificação na pasta contendo arquivos XMLs
		If lPathXML .and. !Empty(cPathXML)

			aFiles := Directory( cPathXML + "*.xml" )
			aFiles := aSort( aFiles, , , {|x,y| x[1] > y[1]} ) //-- ordenação dos arquivos pelo nome
			nFiles := Len(aFiles)

			If !IsBlind()
				oSay:cCaption := cFilAnt+' - Quantidade arquivos: ' + cValToChar(nFiles)
				ProcessMessages()
			EndIf
			//Sleep( 1000 )

			For nW := 1 to nFiles

				////conout('Arquivo: ' + aFiles[nX,1] + ' - Size: ' + AllTrim(Str(aFiles[nX,2])) )
				If !IsBlind()
					oSay:cCaption := cFilAnt+' - Processando o arquivo: ' + cValToChar(nW) + '/' +cValToChar(nFiles)
					ProcessMessages()
				EndIf

				cFile := cPathXML + aFiles[nW][1]
				FT_FUse( cFile )
				FT_FGoTop()

				nLast := FT_FLastRec() //-- Retorna o número de linhas do arquivo

				lOk := .F.
				cRetSfz := ""
				oXML := {}
				cXML := ""; cError := ""; cWarning := ""
				For nV := 1 to nLast
					cXML += FT_FReadLn() //AllTrim(FT_FReadLn()) //+ CRLF //-- Leitura da linha atual
					FT_FSkip()
				Next nV

				FT_FUse() //-- Libera o arquivo

				cXML := AllTrim(cXML)
				oXML := XmlParser( cXML, '_', @cError, @cWarning )

				If oXML == NIL

					//-- texto para gravar no LOG
					cTexto += "STMonitor: Retornou XML invalido para recuperacao da venda, arquivo [" + aFiles[nW][1] +"] " + CRLF
					cTexto += " cError: "+cError + CRLF
					cTexto += " cWarning: "+cWarning + CRLF
					cTexto += CRLF
					cTexto += CRLF

					cNomeArq := "ERR_04_"+cFilAnt+"_"+AllTrim(aFiles[nW][1])+"_"+DtoS(dDataBase)+"_"+SUBSTR(Time(),1,2)+SUBSTR(Time(),4,2)+SUBSTR(Time(),7,2)+".log"
					U_UCriaLog(cPathSX/*cPasta*/,cNomeArq/*cNomeArq*/,cTexto/*cTexto*/,.F./*lHelp*/) //-- por hora não faz nada
					cTexto := ""

				Else
					//-- se chegou aqui tem que importar o XML
					lOk := ImportaNota(oXML)

				EndIf

				//-- Copia o arquivo para subpasta "IMPORTADOS"
				If lOk
					If !ExistDir( cPathXML + iif(IsSrvUnix(),"/","\") + "IMPORTADOS" )
						If MakeDir( cPathXML + iif(IsSrvUnix(),"/","\") + "IMPORTADOS" ) == 0 //-- retorna zero (0), se o diretório for criado com sucesso
							__CopyFile(cFile, cPathXML + iif(IsSrvUnix(),"/","\") + "IMPORTADOS" + iif(IsSrvUnix(),"/","\") + aFiles[nW][1])
							FErase(cFile)
						EndIf
					Else
						__CopyFile(cFile, cPathXML + iif(IsSrvUnix(),"/","\") + "IMPORTADOS" + iif(IsSrvUnix(),"/","\") + aFiles[nW][1])
						FErase(cFile)
					EndIf
				EndIf

			Next nW

			//-- Faz verificação através da lista de notas do TSS local do PDV
		ElseIf !lPathXML

			#IFDEF TOP
				lUsaQuery := .T.
				U_PROtcSetConn() //seta conexão para banco Protheus
			#ENDIF

			If !U_TSStcSetConn() //abre ou seta conexão para banco TSS
				Return .F.
			Else

				//-- Select para buscar os XML com problema
				//-- Status NFe
				//--  [1] NFe Recebida
				//--  [2] NFe Assinada
				//--  [3] NFe com falha no schema XML
				//--  [4] NFe transmitida
				//--  [5] NFe com problemas
				//--  [6] NFe autorizada
				//--  [7] Cancelamento
				//cSQL := "SELECT S050.* FROM SPED050 S050, SPED054 S054" + CRLF
				cSQL := "SELECT S050.D_E_L_E_T_ as DELET, S050.R_E_C_N_O_ as RECNO, ISNULL(CAST(CAST(S050.XML_SIG AS VARBINARY(8000)) AS VARCHAR(8000)),'') as XMLSIG, S050.* " + CRLF
				cSQL += " FROM SPED050 S050 " + CRLF
				//cSQL += " WHERE S050.D_E_L_E_T_ = ' ' " + CRLF //-- todas as notas (MESMO DELETADAS)
				cSQL += " WHERE S050.AMBIENTE = 1 " + CRLF //-- 1-Produção / 2-Homologação

				If Eval(bNoHasVar, "lCheckBo2") .or. !lCheckBo2 //-- verifica se processa todos status
					cSQL += " AND (S050.STATUS <> 6 " //-- ou avalia somente notas não autorizadas (STATUS <> 6)
					cSQL += " OR S050.MODALIDADE = 2) " + CRLF //-- ou avalia todas a notas em contigência, independente do STATUS
				EndIf

				If !lCentPDV .and. !Empty(cDocSerie)
					cSQL += " AND S050.DOC_SERIE in ("+cDocSerie+") " + CRLF
				EndIf

				//cSQL += " AND S050.STATUS = '6' " + CRLF

				//cSQL += " AND NFE_ID = '5  000137198'" //-- clausura temporaria, para teste de integração das SPED050 e SPED054
				//cSQL += " AND DATE_NFE >= '20171214' " + CRLF
				//cSQL += " AND DATE_NFE >= '20170626' " + CRLF
				//cSQL += " AND NFE_ID = '5  000153937' " + CRLF //-- clausura temporaria, para processar so uma unica nota
				//cSQL += " AND ( STATUS = 1 OR STATUS = 2 OR STATUS = 3 OR STATUS = 4 OR STATUS = 5 ) " + CRLF
				If !Empty(cNfeId)
					cSQL += " AND NFE_ID = '"+cNfeId+"' " + CRLF //-- para processar so uma unica nota
				ElseIf ValType(lUnicDia) == 'L' .and. lUnicDia
					cSQL += " AND S050.DATE_NFE = '"+DtoS(dApartir)+"' " + CRLF
				ElseIf DtoS(dApartir) >= DtoS(MonthSub(Date(),6)) //526 - Rejeicao: Ano-Mes da Chave de Acesso com atraso superior a 6 meses em relacao ao Ano-Mes atual
					cSQL += " AND S050.DATE_NFE >= '"+DtoS(dApartir)+"' " + CRLF
				Else
					cSQL += " AND S050.DATE_NFE >= '"+DtoS(MonthSub(Date(),6))+"' " + CRLF
				EndIf

				//cSQL += " AND S050.DOC_CHV = S054.NFE_CHV"
				//cSQL += " AND S050.DATE_NFE >= '20180429' " + CRLF
				//cSQL += " AND S050.ID_ENT = '000001'"
				//cSQL += " AND S054.LOTE LIKE 'LT%'"

				//se estiver rodando via JOB, desconsidera os ultimos 60min (3600 segundos) (para não interferir o processo do PDV)
				If IsBlind()
					aRet := SubSegundo(DtoS(Date()),Time(),Eval(bGetMvFil,"MV_XMONMIN",3600)) //remove 60min (3600 segundos)
					cSQL += " AND S050.DATE_NFE + S050.TIME_NFE <= '" + aRet[01] + aRet[02] + "' " + CRLF
					cSQL += " AND S050.SITUA <> 'ER'" //-- evitar de ficar reprocessando várias vezes o mesmo registro
				EndIf

				cSQL += " AND RIGHT(S050.DOC_CHV,3) <> 'Id=' " + CRLF
				cSQL += " AND S050.DOC_CHV <> '' " + CRLF

				cSQL += " ORDER BY S050.DATE_NFE, S050.TIME_NFE " + CRLF

				//U_XHELP("xMonitor","cSQL: ",cSQL)

				//dbUseArea(.T.,"TOPCONN", TCGenQry(,,cSql), 'SPDX', .F., .T.)
				If Select("SPDX") > 0
					SPDX->( DbCloseArea() )
				EndIf

				If IsBlind()
					//conout("dApartir: "+ DtoC(dApartir))
					//conout("cSQL: " + CRLF + cSQL)
					//conout("")
				EndIF

//-----------------------------------------------------
//				//TODO: teste de UPDATE no banco do TSS
//				cSqlUpd := "UPDATE sped050 "
//				cSqlUpd += " SET "
//				cSqlUpd += 		" d_e_l_e_t_ = ' ' " //-- não deletado (caso registro deletado, recupera o mesmo)
//				cSqlUpd += " WHERE nfe_id = '001000528084                                ' "
//				nStatus := TcSQLExec(Upper(cSqlUpd))
//
//				If (nStatus < 0)
//					If !IsBlind()
//						Alert("TCSQLError() " + TCSQLError())
//					Else
//						//conout("TCSQLError() " + TCSQLError())
//					EndIf
//				EndIf
//
//				Return
//-----------------------------------------------------

				//cSQL := ChangeQuery(cSQL)
				TcQuery cSQL New ALIAS "SPDX"

				nCountSPDX := 0

				//-- Esse TRECHO esta deixando a o ponteiro do alias SPDX no final de arquivo, mesmo executando DbGoTop
				If !SPDX->( Eof() )
					SPDX->(dbEval({|| nCountSPDX++}))
				EndIf

				If nCountSPDX > 0
					If Select("SPDX") > 0
						SPDX->( DbCloseArea() )
					EndIf

					//cSQL := ChangeQuery(cSQL)
					TcQuery cSQL New ALIAS "SPDX"
				EndIf

				If !IsBlind()
					oSay:cCaption := 'Quantidade registros SPED050: ' + cValToChar(nCountSPDX)
					ProcessMessages()
				EndIf
				//Sleep( 1000 )

				U_PROtcSetConn() //seta conexão para banco Protheus
				//-- Altera Indice para
				SL1->( DbSetOrder(2) ) //L1_FILIAL+L1_SERIE+L1_DOC+L1_PDV

				SPDX->( DbGoTop() )
				While !SPDX->( Eof() ) .and. nCount <= nCountSPDX

					//se registro deletado, recupero o mesmo
					if SPDX->DELET = '*'

						U_TSStcSetConn() //abre ou seta conexão para banco TSS

						cSqlUpd := "UPDATE sped050 "
						cSqlUpd += " SET "
						cSqlUpd += 		" d_e_l_e_t_ = ' ' " //-- não deletado (caso registro deletado, recupera o mesmo)
						cSqlUpd += " WHERE r_e_c_n_o_ = '" + AllTrim( Str(SPDX->RECNO) ) + "' "
						nStatus := TcSQLExec(Upper(cSqlUpd))

						If (nStatus < 0)
							If !IsBlind()
								Alert("TCSQLError() " + TCSQLError())
							Else
								//conout("TCSQLError() " + TCSQLError())
							EndIf
						EndIf

						U_PROtcSetConn() //seta conexão para banco Protheus

					endif

					cTexto := ""
					nCount++
					lOk := .F.
					cRetSfz := ""

					If !IsBlind()
						oSay:cCaption := 'Processando a nota: ' + AllTrim(SPDX->NFE_ID) + ' - ' + cValToChar(nCount) + '/' +cValToChar(nCountSPDX)
						ProcessMessages()
					EndIf

					//-- Valida NF apenas apos 30min
					If (SPDX->DATE_NFE == DtoS(Date())) .and. (SubHoras( Time() , SPDX->TIME_NFE ) < 0.30)
						SPDX->( DbSkip() ) //-- tratar somente notas com mais de 30min
						Loop
					EndIf

					lNFe := (Substr(SPDX->DOC_CHV,21,2) == "55")

					//-- Vamos Verificar se foi autorizado na SEFAZ
					//-- [01] = Versao
					//-- [02] = Ambiente
					//-- [03] = Cod Retorno Sefaz
					//-- [04] = Descricao Retorno Sefaz
					//-- [05] = Protocolo
					//-- [06] = Hash
					if SPDX->STATUS <> 6
						aAutoriz := VldNFSefaz( .F./*não consulta no TSS Local*/, {{SPDX->DOC_CHV,"",lNFe}} )
					else
						//cVersao	 := StaticCall(LOJNFCE, LjCfgTSS, Substr(SPDX->DOC_CHV,21,2), "VER")[2]
						cVersao	 := &("StaticCall(LOJNFCE, LjCfgTSS, Substr(SPDX->DOC_CHV,21,2), 'VER')[2]")
						aAutoriz := {cVersao, Iif(SPDX->AMBIENTE==1,"1-Produção","2-Homologação"), "100", "Autorizado o uso da NF-e", SPDX->NFE_PROT, ""} //["3.10", "1-Produção", "100", "Autorizado o uso da NF-e", "321180129565401", "f31wP4irnZ2OblFZMzhJLG1EEG8="]
					endif

					//-- texto para gravar no LOG
					cTexto += "STATUS NA SEFAZ:" + CRLF
					cTexto += CRLF
					cTexto += "aAutoriz: " + CRLF
					cTexto += CRLF
					cTexto += U_XtoStrin(aAutoriz) + CRLF
					cTexto += CRLF
					cTexto += CRLF

					If Len(aAutoriz)>0

						//-- Sped esta Autorizada na SEFAZ??
						If aAutoriz[03] <> "100"

							//-- texto para gravar no LOG
							cTexto += "Tratamento somente para notas com STATUS '100|Autorizado o uso da NF-e', os demais casos ignora..." + CRLF
							cTexto += CRLF
							cTexto += "SERIE: " + Left(SPDX->NFE_ID,3) + CRLF
							cTexto += "NF: " + Right(AllTrim(SPDX->NFE_ID),9) + CRLF
							cTexto += "CHAVE: " + AllTrim(SPDX->DOC_CHV) + CRLF
							cTexto += CRLF
							cTexto += "Não faz nada..." + CRLF

							cNomeArq := "ERR_01_"+cFilAnt+"_"+AllTrim(Left(SPDX->NFE_ID,3))+"_"+AllTrim(Right(AllTrim(SPDX->NFE_ID),9))+"_"+SPDX->DOC_CHV+"_"+DtoS(dDataBase)+"_"+SUBSTR(Time(),1,2)+SUBSTR(Time(),4,2)+SUBSTR(Time(),7,2)+".log"
							U_UCriaLog(cPathSX/*cPasta*/,cNomeArq/*cNomeArq*/,cTexto/*cTexto*/,.F./*lHelp*/) //-- por hora não faz nada
							cTexto := ""

							//-- Vamos verificar se existe a nota na SL1
							SL1->( DbSetOrder( 2 ) ) //L1_FILIAL+L1_SERIE+L1_DOC+L1_PDV
							If SL1->( DbSeek( xFilial("SL1") + AllTrim(SPDX->NFE_ID) ) )

								If !Empty(SL1->L1_NUMORIG) ; //-- se integrou e não esta cancelado, entra lista de "notas que ESTÃO no Protheus e que NÃO ESTÃO AUTORIZADAS"
									.and. aAutoriz[03] <> "101" //101|Cancelamento de NF-e homologado
									If Empty(cNfErro)
										cNfErro := "Filial;Dt.Emis;Documento;Serie;Chave SL1;Chave SPED050;Situa SL1;Status SEFAZ;Tipo;Vlr.Total;" + CRLF
									EndIf
									cNfErro += cFilAnt+";"+DtoC(SL1->L1_EMISNF)+";"+SL1->L1_DOC+";"+SL1->L1_SERIE+";"+SL1->L1_KEYNFCE+";"+SPDX->DOC_CHV+";"+SL1->L1_SITUA+";"+aAutoriz[05]+"|"+aAutoriz[03]+"|"+aAutoriz[04]+";"+SL1->L1_TIPO+";"+cValToChar(SL1->L1_VLRTOT)+";" + CRLF
								EndIf

							/*/-- tratamento para evitar integrar indevidamente
								If (SL1->L1_SITUA $ 'RX/OK/ER')

									RecLock("SL1")
									SL1->L1_SITUA := "T2" //-- Inutiliza porque pegou DOC
									SL1->( MsUnLock() )

									StaticCall(ULOJA009,InutilNF) //-- Solicita a Inutilizacao NFC-e e/ou NF-e
								EndIf
							*/

							EndIf

							//-- Tratamento para inutilização de NFC-e e NF-e
							SL1->( DbSetOrder( 2 ) ) //L1_FILIAL+L1_SERIE+L1_DOC+L1_PDV
							If aAutoriz[03] <> "101" ; //101|Cancelamento de NF-e homologado
								.and. (SL1->(!DbSeek(xFilial("SL1")+AllTrim(SPDX->NFE_ID))) .or. Empty(SL1->L1_NUMORIG))
								SLX->(DbSetOrder(1)) //LX_FILIAL+LX_PDV+LX_CUPOM+LX_SERIE+LX_ITEM+LX_HORA
								If !SLX->(DbSeek(xFilial("SLX")+PADR("",TamSx3("LX_PDV")[1])+Right(AllTrim(SPDX->NFE_ID),9)+Left(SPDX->NFE_ID,3)))
									If SPDX->MODELO $ '65' //colocado provisoriamente apenas para NFCE
										Lj7SLXDocE(SPDX->MODELO, Right(AllTrim(SPDX->NFE_ID),9), Left(SPDX->NFE_ID,3), "", "", Nil)
									EndIf
								EndIf
							EndIf

							// Grava o SITUA com ER quando a SPED050 não esta autorizada na SEFAZ
							// -- Evitando assim reprocessar o mesmo registro via JOB novamente
							If IsBlind()
								ErrSPEDs(SPDX->R_E_C_N_O_)
							EndIf

							////conout("Tratamento somente para notas com STATUS '100|Autorizado o uso da NF-e', os demais casos ignora...")
							SPDX->( DbSkip() ) //-- tratar somente "100|Autorizado o uso da NF-e", os demais casos ignora
							Loop

						EndIf

						//-- Vamos verificar se existe a nota na SL1
						SL1->( DbSetOrder( 2 ) ) //L1_FILIAL+L1_SERIE+L1_DOC+L1_PDV
						SL1->( DbSeek( xFilial("SL1") + AllTrim(SPDX->NFE_ID) ) )

						//-- Existe na SL1 e ja foi integrado esta tudo certo, proximo registro
						If SL1->( Found() ) .and. SL1->L1_SITUA $ 'TX/00/CP'

							//-- texto para gravar no LOG
							cTexto += "Encontrou a venda na base local com status OK! (TABELA SL1 ->> SL1->L1_SITUA $ 'TX/00/CP' )..." + CRLF
							cTexto += CRLF
							cTexto += "SERIE: " + Left(SPDX->NFE_ID,3) + CRLF
							cTexto += "NF: " + Right(AllTrim(SPDX->NFE_ID),9) + CRLF
							cTexto += "CHAVE: " + AllTrim(SPDX->DOC_CHV) + CRLF
							cTexto += CRLF
							cTexto += "Numero: " + SL1->L1_NUM + CRLF
							cTexto += "Serie: " + SL1->L1_SERIE + CRLF
							cTexto += "Nf: " + SL1->L1_DOC + CRLF
							cTexto += "Status: " + SL1->L1_SITUA + CRLF
							cTexto += CRLF
							cTexto += "Não faz nada..." + CRLF
							cTexto += CRLF

							cNomeArq := "OK_"+cFilAnt+"_"+AllTrim(Left(SPDX->NFE_ID,3))+"_"+AllTrim(Right(AllTrim(SPDX->NFE_ID),9))+"_"+SPDX->DOC_CHV+"_"+DtoS(dDataBase)+"_"+SUBSTR(Time(),1,2)+SUBSTR(Time(),4,2)+SUBSTR(Time(),7,2)+".log"
							//U_UCriaLog(cPathSX/*cPasta*/,cNomeArq/*cNomeArq*/,cTexto/*cTexto*/,.F./*lHelp*/) //-- por hora não faz nada
							cTexto := ""

							If !Empty(SL1->L1_STATUS)
								If Empty(cNotas)
									cNotas := "Filial;Dt.Emis;Documento;Serie;Chave;Tipo;Vlr.Total;Status;" + CRLF
								EndIf
								cNotas += cFilAnt+";"+DtoC(SL1->L1_EMISNF)+";"+SL1->L1_DOC+";"+SL1->L1_SERIE+";"+SL1->L1_KEYNFCE+";"+SL1->L1_STATUS+";"+cValToChar(SL1->L1_VLRTOT)+";"+SL1->L1_SITUA+";" + CRLF
							EndIf

							//-- se ocorrer importação correta, ajusta o dados das tabelas SPED050 e SPED054
							If /*lOk .and. */aAutoriz[03] == '100' .and. SPDX->STATUS <> 6
								//If aAutoriz[03] == '100' .and. SPDX->STATUS == 6

								//Parametro: {[1]-entidade, [2]-nfe_ID, [3]-chave, [4]-protocolo, [5]-recno_sped050, [6]-dt, [7]-hr, [8]-digval, [9]-versao}
								AjusSPEDs({SPDX->ID_ENT, SPDX->NFE_ID, SPDX->DOC_CHV, aAutoriz[05], SPDX->R_E_C_N_O_, SPDX->DATE_NFE, SPDX->TIME_NFE, aAutoriz[06], aAutoriz[01] })
								If Empty(SL1->L1_STATUS)
									If Empty(cNotas)
										cNotas := "Filial;Dt.Emis;Documento;Serie;Chave;Tipo;Vlr.Total;Status;" + CRLF
									EndIf
									cNotas += cFilAnt+";"+DtoC(SL1->L1_EMISNF)+";"+SL1->L1_DOC+";"+SL1->L1_SERIE+";"+SL1->L1_KEYNFCE+";"+SL1->L1_STATUS+";"+cValToChar(SL1->L1_VLRTOT)+";"+SL1->L1_SITUA+";" + CRLF
								EndIf

							EndIf

							SPDX->( DbSkip() )
							Loop

							//-- Existe na SL1, mas nao integrou por algum motivo
						ElseIf SL1->( Found() ) .and. !(SL1->L1_SITUA $ 'TX/00/CP')

							//-- texto para gravar no LOG
							cTexto += "Encontrou a venda na base local sem status de OK! (TABELA SL1 ->> !(SL1->L1_SITUA $ 'TX/00/CP') )..." + CRLF
							cTexto += "Seram tratados no futuro..." + CRLF
							cTexto += CRLF
							cTexto += "SERIE: " + Left(SPDX->NFE_ID,3) + CRLF
							cTexto += "NF: " + Right(AllTrim(SPDX->NFE_ID),9) + CRLF
							cTexto += "CHAVE: " + AllTrim(SPDX->DOC_CHV) + CRLF
							cTexto += CRLF
							cTexto += "Numero: " + SL1->L1_NUM + CRLF
							cTexto += "Serie: " + SL1->L1_SERIE + CRLF
							cTexto += "Nf: " + SL1->L1_DOC + CRLF
							cTexto += "Status: " + SL1->L1_SITUA + CRLF
							cTexto += CRLF
							cTexto += "Não faz nada..." + CRLF
							cTexto += CRLF

							cNomeArq := "ERR_02_"+cFilAnt+"_"+AllTrim(Left(SPDX->NFE_ID,3))+"_"+AllTrim(Right(AllTrim(SPDX->NFE_ID),9))+"_"+SPDX->DOC_CHV+"_"+DtoS(dDataBase)+"_"+SUBSTR(Time(),1,2)+SUBSTR(Time(),4,2)+SUBSTR(Time(),7,2)+".log"
							U_UCriaLog(cPathSX/*cPasta*/,cNomeArq/*cNomeArq*/,cTexto/*cTexto*/,.F./*lHelp*/) //-- por hora não faz nada
							cTexto := ""

							If Len(aAutoriz)>=5
								cRetSfz := aAutoriz[05]+"|"+aAutoriz[03]+"|"+aAutoriz[04]
							EndIf

							If !Empty(cRetSfz)

								RecLock( "SL1", .F. )
								If aAutoriz[03] == '100' .and. !(SL1->L1_SITUA $ 'CP/00/TX') .and. Empty(SL1->L1_NUMORIG)
									SL1->( DbDelete() ) //SL1->L1_SITUA := '00' //-- deleto o registro para importar novamente
									lOk := .T. //-- vai importar novamente
								Else
									SL1->L1_KEYNFCE := SPDX->DOC_CHV
									SL1->L1_RETSFZ  := cRetSfz
									lOk := .F. //-- vai importar novamente
								EndIf
								SL1->( MsUnlock() )

								//-- se ocorrer importação correta, ajusta o dados das tabelas SPED050 e SPED054
								If lOk .and. aAutoriz[03] == '100' .and. SPDX->STATUS <> 6
									//If aAutoriz[03] == '100' .and. SPDX->STATUS == 6

									//Parametro: {[1]-entidade, [2]-nfe_ID, [3]-chave, [4]-protocolo, [5]-recno_sped050, [6]-dt, [7]-hr, [8]-digval, [9]-versao}
									AjusSPEDs({SPDX->ID_ENT, SPDX->NFE_ID, SPDX->DOC_CHV, aAutoriz[05], SPDX->R_E_C_N_O_, SPDX->DATE_NFE, SPDX->TIME_NFE, aAutoriz[06], aAutoriz[01] })

								EndIf

							EndIf

							If !lOk //!Empty(SL1->L1_STATUS)
								If Empty(cNotas)
									cNotas := "Filial;Dt.Emis;Documento;Serie;Chave;Tipo;Vlr.Total;Status;" + CRLF
								EndIf
								cNotas += cFilAnt+";"+DtoC(SL1->L1_EMISNF)+";"+SL1->L1_DOC+";"+SL1->L1_SERIE+";"+SL1->L1_KEYNFCE+";"+SL1->L1_STATUS+";"+cValToChar(SL1->L1_VLRTOT)+";"+SL1->L1_SITUA+";" + CRLF
							EndIf

							//-- Devido o numero de ocorrencias serem considerados raros, iremos desenvolver essa validação no futuro
							If !lOk
								SPDX->( DbSkip() )
								Loop
							EndIf

						EndIf

						//-- Se chegou aqui nao existe nada no PDV, vamos gerar um execauto para integrar a venda

						//-- Vamos buscar o XML pelo TSS Local
						//-- [15][02] = XML Assinado
						aDados := VldNFSefaz( .T./*consulta no TSS Local*/, {{Left(SPDX->NFE_ID,3),Right(AllTrim(SPDX->NFE_ID),9),lNFe}} )

						//-- texto para gravar no LOG
						cTexto += "STATUS NO TSS LOCAL:" + CRLF
						cTexto += CRLF
						cTexto += "aDados: " + CRLF
						cTexto += CRLF
						cTexto += U_XtoStrin(aDados) + CRLF
						cTexto += CRLF
						cTexto += CRLF

						If (Type("aDados") <> "A" .or. len(aDados) < 1 .or. len(aDados[01]) < 15 .or. len(aDados[01][15]) < 2 .or. Empty(aDados[01][15][02]))
							cXML := SPDX->XMLSIG
						Else
							cXML := AllTrim(aDados[01][15][02])
						EndIf

						If Empty(cXML)

							//-- texto para gravar no LOG
							cTexto += "STMonitor: Retornou sem XML para recuperacao da venda " + AllTrim(SPDX->NFE_ID) + "[" + SPDX->DOC_CHV +"] " + CRLF
							cTexto += CRLF
							cTexto += "SERIE: " + Left(SPDX->NFE_ID,3) + CRLF
							cTexto += "NF: " + Right(AllTrim(SPDX->NFE_ID),9) + CRLF
							cTexto += "CHAVE: " + AllTrim(SPDX->DOC_CHV) + CRLF
							cTexto += CRLF

							cNomeArq := "ERR_03_"+cFilAnt+"_"+AllTrim(Left(SPDX->NFE_ID,3))+"_"+AllTrim(Right(AllTrim(SPDX->NFE_ID),9))+"_"+SPDX->DOC_CHV+"_"+DtoS(dDataBase)+"_"+SUBSTR(Time(),1,2)+SUBSTR(Time(),4,2)+SUBSTR(Time(),7,2)+".log"
							U_UCriaLog(cPathSX/*cPasta*/,cNomeArq/*cNomeArq*/,cTexto/*cTexto*/,.F./*lHelp*/) //-- por hora não faz nada
							cTexto := ""

							////conout("STMonitor: Retornou sem XML para recuperacao da venda " + AllTrim(SPDX->NFE_ID) + "[" + SPDX->DOC_CHV +"] ")
							SPDX->( DbSkip() )
							Loop

						Else

							//-- se ocorrer importação correta, ajusta o dados das tabelas SPED050 e SPED054
							If aAutoriz[03] == '100' .and. SPDX->STATUS <> 6
								//If aAutoriz[03] == '100' .and. SPDX->STATUS == 6

								//Parametro: {[1]-entidade, [2]-nfe_ID, [3]-chave, [4]-protocolo, [5]-recno_sped050, [6]-dt, [7]-hr, [8]-digval, [9]-versao}
								AjusSPEDs({SPDX->ID_ENT, SPDX->NFE_ID, SPDX->DOC_CHV, aAutoriz[05], SPDX->R_E_C_N_O_, SPDX->DATE_NFE, SPDX->TIME_NFE, aAutoriz[06], aAutoriz[01] })

							EndIf

						EndIf

						oXML := {}
						oXML := XmlParser( cXML, '_', @cError, @cWarning )

						If oXML == NIL

							//-- texto para gravar no LOG
							cTexto += "STMonitor: Retornou XML invalido para recuperacao da venda " + AllTrim(SPDX->NFE_ID) + "[" + SPDX->DOC_CHV +"] " + CRLF
							cTexto += " cError: "+cError + CRLF
							cTexto += " cWarning: "+cWarning + CRLF
							cTexto += CRLF
							cTexto += "SERIE: " + Left(SPDX->NFE_ID,3) + CRLF
							cTexto += "NF: " + Right(AllTrim(SPDX->NFE_ID),9) + CRLF
							cTexto += "CHAVE: " + AllTrim(SPDX->DOC_CHV) + CRLF
							cTexto += CRLF

							cNomeArq := "ERR_04_"+cFilAnt+"_"+AllTrim(Left(SPDX->NFE_ID,3))+"_"+AllTrim(Right(AllTrim(SPDX->NFE_ID),9))+"_"+SPDX->DOC_CHV+"_"+DtoS(dDataBase)+"_"+SUBSTR(Time(),1,2)+SUBSTR(Time(),4,2)+SUBSTR(Time(),7,2)+".log"
							U_UCriaLog(cPathSX/*cPasta*/,cNomeArq/*cNomeArq*/,cTexto/*cTexto*/,.F./*lHelp*/) //-- por hora não faz nada
							cTexto := ""

							SPDX->( DbSkip() )
							Loop

						Else

							cRetSfz := aAutoriz[05]+"|"+aAutoriz[03]+"|"+aAutoriz[04] //315180148527873|100|Autorizado o uso da NF-e

							//-- se chegou aqui tem que importar o XML
							lOk := ImportaNota(oXML,cRetSfz)

						EndIf

						//-- se ocorrer importação correta, ajusta o dados das tabelas SPED050 e SPED054
						If lOk .and. aAutoriz[03] == '100' .and. SPDX->STATUS <> 6
							//If aAutoriz[03] == '100' .and. SPDX->STATUS == 6

							//Parametro: {[1]-entidade, [2]-nfe_ID, [3]-chave, [4]-protocolo, [5]-recno_sped050, [6]-dt, [7]-hr, [8]-digval, [9]-versao}
							AjusSPEDs({SPDX->ID_ENT, SPDX->NFE_ID, SPDX->DOC_CHV, aAutoriz[05], SPDX->R_E_C_N_O_, SPDX->DATE_NFE, SPDX->TIME_NFE, aAutoriz[06], aAutoriz[01] })

						EndIf

					EndIf

					SPDX->( DbSkip() )

				EndDo

				SPDX->( DbCloseArea() )

			EndIf

			// Volta para conexão ERP
			If lUsaQuery
				U_PROtcSetConn() //seta conexão para banco Protheus
			EndIf

			// Mostra a conexão ativa
			//conout( "StMonitor - xMonitor2 - Conexão ativa: banco = " + TcGetDB() )

			//conout( ">> StMonitor - xMonitor2 - FIM - Data: "+DtoC(date())+" - Hora: "+time()+"")

		EndIf

		If !Empty(cNotas)
			cNomeArq := "NOTAS_IMPORTADAS_"+cFilAnt+"_"+DtoS(dDataBase)+"_"+SUBSTR(Time(),1,2)+SUBSTR(Time(),4,2)+SUBSTR(Time(),7,2)+".csv"
			U_UCriaLog(cPathSX/*cPasta*/,cNomeArq/*cNomeArq*/,cNotas/*cTexto*/,.F./*lHelp*/)
		EndIf
		cNotas := ""

		If !Empty(cNfErro)
			cNomeArq := "NOTAS_COM_ERRO_"+cFilAnt+"_"+DtoS(dDataBase)+"_"+SUBSTR(Time(),1,2)+SUBSTR(Time(),4,2)+SUBSTR(Time(),7,2)+".csv"
			U_UCriaLog(cPathSX/*cPasta*/,cNomeArq/*cNomeArq*/,cNfErro/*cTexto*/,.F./*lHelp*/)
			cNfErro	:= ""
		EndIf

	Next nI

Return .T.

//-------------------------------------------------------------------
/*/{Protheus.doc} ImportaNota
Importa NFC-e
@author  author
@since   date
@version version
/*/
//-------------------------------------------------------------------
Static Function ImportaNota(oXML,cRetSfz)
	Local lRet := .F.

	Local cBico := "", cBomba := "", cTanque := "", cCodAbast := "", cLocAbast := ""
	Local cNumImp := "" //numero do oçamento importado
	Local cNumOrc := "" //numero do orçamento a ser copiado
	Local nEncIni := 0, nEncFin := 0

	Local aIdeNfce	:= {}
	Local aEmitNfce := {}
	Local aDestNfce := {}
	Local aPagNfce 	:= {}
	Local aItemNfce := {}
	Local aTotal 	:= {}
	Local cInfCpl	:= ""
	Local nPosPDV 	:= 0
	Local cNumPDV := "", cNumOpe := "", cNumMov := "", cNumEst := ""
	Local cDocumento := "", cSerie := "", dEmisNf := CtoD(""), cHora := "", cKeyNfce := "", cCodCli := "", cLojCli := "", cDestinatario := ""
	Local nX := 0
	Local oAux
	Local cZerEsq := SuperGetMV("MV_XSZERES",,"0") //Serie da nota recuperada: define o caracter que será preeenchido a esquerda do número da série (default "0")

	Private oTmpXML
	Private uTmpXML
	Private oItemTemp

	Default cRetSfz := ""

//-- zero as variaveis
	aIdeNfce := {}; aEmitNfce := {}; aDestNfce := {}; aPagNfce := {}; aItemNfce := {}; aTotal := {}

//-- pega os dados do XML que serão utilizados
	oTmpXML := oXML
	If Type("oTmpXML:_NFEPROC") != "U"
		oTmpXML := oTmpXML:_NFEPROC
	EndIf
	If Type("oTmpXML:_NFE:_INFNFE:_IDE") != "U"
		aIdeNfce := oTmpXML:_NFE:_INFNFE:_IDE //Dados da nota (detalhe da NF-e/NFC-e)
	EndIf
	If Type("oTmpXML:_NFE:_INFNFE:_EMIT") != "U"
		aEmitNfce := oTmpXML:_NFE:_INFNFE:_EMIT //Emitente
	EndIf
	If Type("oTmpXML:_NFE:_INFNFE:_DEST") == "O"
		aDestNfce := oTmpXML:_NFE:_INFNFE:_DEST //Destinatário
	EndIf
	If Type("oTmpXML:_NFE:_INFNFE:_PAG") == "A"
		aPagNfce := oTmpXML:_NFE:_INFNFE:_PAG
	Else
		If Type("oTmpXML:_NFE:_INFNFE:_PAG") == "O"
			aAdd(aPagNfce, oTmpXML:_NFE:_INFNFE:_PAG)
		EndIf
	EndIf
	If Type("oTmpXML:_NFE:_INFNFE:_DET") == "A"
		aItemNfce := oTmpXML:_NFE:_INFNFE:_DET
	Else
		If Type("oTmpXML:_NFE:_INFNFE:_DET") == "O"
			aAdd(aItemNfce, oTmpXML:_NFE:_INFNFE:_DET)
		EndIf
	EndIf
	If Type("oTmpXML:_NFE:_INFNFE:_TOTAL") <> "U"
		aTotal := oTmpXML:_NFE:_INFNFE:_TOTAL
	EndIf
	If Type("oTmpXML:_NFE:_INFNFE:_INFADIC") <> "U"
		cInfCpl := AllTrim(oTmpXML:_NFE:_INFNFE:_INFADIC:_INFCPL:TEXT)
	EndIf

//-- numero do PDV das informções complementares
	nPosPDV := At("PDV: ",cInfCpl)
	If nPosPDV > 0
		nPosPDV += 5
		cNumPDV := SubStr(cInfCpl,nPosPDV,TamSX3("L1_PDV")[1])
	EndIf

//-- numero do operador das informções complementares
	nPosPDV := At("OPERADOR: ",cInfCpl)
	If nPosPDV > 0
		nPosPDV += 10
		cNumOpe := SubStr(cInfCpl,nPosPDV,TamSX3("L1_OPERADO")[1])
	EndIf

//-- numero do movimento das informções complementares
	nPosPDV := At("N.MOV: ",cInfCpl)
	If nPosPDV > 0
		nPosPDV += 7
		cNumMov := SubStr(cInfCpl,nPosPDV,TamSX3("L1_NUMMOV")[1])
	EndIf

//-- numero da estação das informções complementares
	nPosPDV := At("ESTACAO: ",cInfCpl)
	If nPosPDV > 0
		nPosPDV += 9
		cNumEst := SubStr(cInfCpl,nPosPDV,TamSX3("L1_ESTACAO")[1])
	EndIf

//-- valida CNPJ do emitente do XML
	If AllTrim(SM0->M0_CGC) <> AllTrim(aEmitNfce:_CNPJ:TEXT)

		//-- texto para gravar no LOG
		cTexto += "CNPJ do arquivo XML diferente do CNPJ do sistema." + CRLF
		cTexto += CRLF
		cTexto += "CNPJ XML: " + aEmitNfce:_CNPJ:TEXT + CRLF
		cTexto += "CNPJ EMPRESA LOGADA: " + SM0->M0_CGC + CRLF
		cTexto += CRLF

		cNomeArq := "ERR_06_"+cFilAnt+"_"+AllTrim(cSerie)+"_"+AllTrim(cDocumento)+"_"+cKeyNfce+"_"+DtoS(dDataBase)+"_"+SUBSTR(Time(),1,2)+SUBSTR(Time(),4,2)+SUBSTR(Time(),7,2)+".log"
		U_UCriaLog(cPathSX/*cPasta*/,cNomeArq/*cNomeArq*/,cTexto/*cTexto*/,.F./*lHelp*/) //-- por hora não faz nada
		cTexto := ""

		Return lRet := .F.

	EndIf

//-- variaveis a serem utilizadas nos novos orçamentos gerados
	cDocumento := ""; cSerie := ""; dEmisNf := CtoD(""); cHora := ""; cKeyNfce := ""; cCodCli := ""; cLojCli := ""

	cDocumento := PADL(AllTrim(aIdeNfce:_NNF:TEXT),TamSx3("L1_DOC")[1],"0")
	cSerie := AllTrim(PADL(AllTrim(aIdeNfce:_SERIE:TEXT),TamSx3("L1_SERIE")[1],cZerEsq)) //TODO: dependendo do cliente, pode ou não ter zeros a esquerda
	dEmisNf := StoD(SubStr(aIdeNfce:_DHEMI:TEXT,1,4)+SubStr(aIdeNfce:_DHEMI:TEXT,6,2)+SubStr(aIdeNfce:_DHEMI:TEXT,9,2))
	cHora := SubStr(aIdeNfce:_DHEMI:TEXT,12,8)
	cKeyNfce :=	SubStr(oTmpXML:_NFE:_INFNFE:_ID:TEXT,4,44)
	lNFe := (Substr(cKeyNfce,21,2) == "55")

	If lNFe //-- Importa NF-e
		////-- Atualmente esse problema esta apenas com NFC-e, importação de NF-e sera implementação futura
		//
		////-- texto para gravar no LOG
		//cTexto += "Atualmente esse problema esta apenas com NFC-e, importação de NF-e sera implementação futura" + CRLF
		//cTexto += CRLF
		//cTexto += "SERIE: " + cSerie + CRLF
		//cTexto += "NF: " + cDocumento + CRLF
		//cTexto += CRLF
		//
		//cNomeArq := "ERR_05_"+cFilAnt+"_"+AllTrim(cSerie)+"_"+AllTrim(cDocumento)+"_"+cKeyNfce+"_"+DtoS(dDataBase)+"_"+SUBSTR(Time(),1,2)+SUBSTR(Time(),4,2)+SUBSTR(Time(),7,2)+".log"
		//U_UCriaLog(cPathSX/*cPasta*/,cNomeArq/*cNomeArq*/,cTexto/*cTexto*/,.F./*lHelp*/) //-- por hora não faz nada
		//cTexto := ""
		//
		//lRet := .F.

		//destinatario
		cDestinatario := ""
		If Empty(aDestNfce)
			cDestinatario := "CONSUMIDOR NÃO IDENTIFICADO"
			cCodCli := PadR(SuperGetMV("MV_CLIPAD",,"000001"),TAMSX3("L1_CLIENTE")[1])
			cLojCli := PadR(SuperGetMV("MV_LOJAPAD",,"01"),TAMSX3("L1_LOJA")[1])
		Else
			uTmpXML := aDestNfce
			If Type("uTmpXML:_CPF:TEXT") != "U" //LjRTemNode(aDestNfce,"_CPF")
				cDestinatario := "CONSUMIDOR - CPF: " + Transform(aDestNfce:_CPF:TEXT, "@R 999.999.999-99")
				SA1->( DbSetOrder(3) ) //A1_FILIAL+A1_CGC
				If SA1->( DbSeek(xFilial("SA1")+AllTrim(aDestNfce:_CPF:TEXT) ) )
					cCodCli := SA1->A1_COD
					cLojCli := SA1->A1_LOJA
				EndIf
			ElseIf Type("uTmpXML:_CNPJ:TEXT") != "U" //LjRTemNode(aDestNfce,"_CNPJ")
				cDestinatario := "CONSUMIDOR - CNPJ: " + Transform(aDestNfce:_CNPJ:TEXT, "@R 99.999.999/9999-99")
				SA1->( DbSetOrder(3) ) //A1_FILIAL+A1_CGC
				If SA1->( DbSeek(xFilial("SA1")+AllTrim(aDestNfce:_CNPJ:TEXT) ) )
					cCodCli := SA1->A1_COD
					cLojCli := SA1->A1_LOJA
				EndIf
			ElseIf Type("uTmpXML:_IDESTRANGEIRO:TEXT") != "U" //LjRTemNode(aDestNfce,"_IDESTRANGEIRO")
				cDestinatario := "CONSUMIDOR Id. Estrangeiro: " + aDestNfce:_IDESTRANGEIRO:TEXT
				cCodCli := PadR(SuperGetMV("MV_CLIPAD",,"000001"),TAMSX3("L1_CLIENTE")[1])
				cLojCli := PadR(SuperGetMV("MV_LOJAPAD",,"01"),TAMSX3("L1_LOJA")[1])
			EndIf
		EndIf

		//-- verifica se ja existe a nota na base
		SL1->(DbSetOrder(2)) //L1_FILIAL+L1_SERIE+L1_DOC+L1_PDV
		SL1->(DbSeek(xFilial("SL1") + cSerie + cDocumento))
		If SL1->( Found() ) .and. SL1->L1_SITUA $ "OK/RX/00/07/TX/CP/C0/CX"

			// "00"	Venda Efetuada com Sucesso
			// "07"	Solicitado o Cancelamento do Cupom
			// "TX"	Foi Enviado ao Server
			// "CP"	Recebido pela Central de PDV
			// "C0"	Cancelamento a ser enviado pelo PDV
			// "CX"	Cancelamento enviado pelo PDV
			// "RX"	Foi Recebido Pelo Server
			// "OK"	Foi Processado no Server Venda OK
			//
			//-- não faz nada, pois a venda ja esta OK

			//-- texto para gravar no LOG
			cTexto += "DADOS DO XML:" + CRLF
			cTexto += CRLF
			cTexto += "SERIE: " + cSerie + CRLF
			cTexto += "NF: " + cDocumento + CRLF
			cTexto += CRLF
			cTexto += "Não faz nada, pois a venda ja esta OK" + CRLF
			cTexto += CRLF
			cTexto += CRLF

			cNomeArq := "OK_01_"+cFilAnt+"_"+AllTrim(cSerie)+"_"+AllTrim(cDocumento)+"_"+AllTrim(cKeyNfce)+"_"+DtoS(dDataBase)+"_"+SUBSTR(Time(),1,2)+SUBSTR(Time(),4,2)+SUBSTR(Time(),7,2)+".log"
			//U_UCriaLog(cPathSX/*cPasta*/,cNomeArq/*cNomeArq*/,cTexto/*cTexto*/,.F./*lHelp*/) //-- por hora não faz nada
			cTexto := ""
			lRet := .T.

			If !Empty(SL1->L1_STATUS)
				cNotas += cFilAnt+";"+DtoC(SL1->L1_EMISNF)+";"+SL1->L1_DOC+";"+SL1->L1_SERIE+";"+SL1->L1_KEYNFCE+";"+SL1->L1_STATUS+";"+cValToChar(SL1->L1_VLRTOT)+";"+SL1->L1_SITUA+";" + CRLF
			EndIf

		ElseIf SL1->( Found() )
			//-- encontrou, porem não integrou (L1_SITUA <> "OK/RX/00/07/TX/CP/C0/CX")

			//-- texto para gravar no LOG
			cTexto += "DADOS DO XML:" + CRLF
			cTexto += CRLF
			cTexto += "SERIE: " + cSerie + CRLF
			cTexto += "NF: " + cDocumento + CRLF
			cTexto += CRLF
			cTexto += "Encontrou, porem não integrou (L1_SITUA <> OK/RX/00/07/TX/CP/C0/CX)" + CRLF
			cTexto += CRLF
			cTexto += CRLF

			cNomeArq := "ERR_02_"+cFilAnt+"_"+AllTrim(cSerie)+"_"+AllTrim(cDocumento)+"_"+AllTrim(cKeyNfce)+"_"+DtoS(dDataBase)+"_"+SUBSTR(Time(),1,2)+SUBSTR(Time(),4,2)+SUBSTR(Time(),7,2)+".log"
			U_UCriaLog(cPathSX/*cPasta*/,cNomeArq/*cNomeArq*/,cTexto/*cTexto*/,.F./*lHelp*/) //-- por hora não faz nada
			cTexto := ""

			If !Empty(SL1->L1_STATUS)
				cNotas += cFilAnt+";"+DtoC(SL1->L1_EMISNF)+";"+SL1->L1_DOC+";"+SL1->L1_SERIE+";"+SL1->L1_KEYNFCE+";"+SL1->L1_STATUS+";"+cValToChar(SL1->L1_VLRTOT)+";"+SL1->L1_SITUA+";" + CRLF
			EndIf

		Else
			//-- verifica abastecimento
			cBico := ""; cBomba := ""; cTanque := ""; cCodAbast := ""; cLocAbast := ""; cNumOrc := ""
			nEncIni := 0; nEncFin := 0; nDesconto := 0;  nAcrescim := 0

			//-- pega os dados de um dos abastecimentos, para tentar localizar a venda
			aItensXML := {} //[01-Produto][02-Quantidade][03-VlrUnitario][04-VlrTotal][05-VlrDesc][06-VlrAcres][07-cBico][08-cBomba][09-cTanque][10-nEncIni][11-nEncFin]
			For nX := 1 to Len(aItemNfce)
				cBico := ""; cBomba := ""; cTanque := ""; nEncIni := 0; nEncFin := 0
				nDesconto := 0
				nAcrescim := 0
				oItemTemp := aItemNfce[nX]
				If ValType(oItemTemp) == "O"
					//If Type("oItemTemp:_PROD:_COMB") == "O" .and. Type("oItemTemp:_PROD:_COMB:_ENCERRANTE") == "O"
					if (oAux := XmlChildEx(oItemTemp,"_PROD"))!=Nil .AND. ;
							(oAux := XmlChildEx(oAux,"_COMB"))!=Nil .AND. ;
							(oAux := XmlChildEx(oAux,"_ENCERRANTE"))!=Nil

						cBico := oItemTemp:_PROD:_COMB:_ENCERRANTE:_NBICO:TEXT
						cTanque := oItemTemp:_PROD:_COMB:_ENCERRANTE:_NTANQUE:TEXT
						//If Type("oItemTemp:_PROD:_COMB:_ENCERRANTE:_NBOMBA") == "O"
						If (oAux := XmlChildEx(oAux,"_NBOMBA"))!=Nil
							cBomba := oItemTemp:_PROD:_COMB:_ENCERRANTE:_NBOMBA:TEXT
						EndIf
						nEncIni := Val(oItemTemp:_PROD:_COMB:_ENCERRANTE:_VENCINI:TEXT)
						nEncFin := Val(oItemTemp:_PROD:_COMB:_ENCERRANTE:_VENCFIN:TEXT)
						//Exit //sai do For
					EndIf
					//if Type("oItemTemp:_PROD:_VDESC") != "U"
					if (oAux := XmlChildEx(oItemTemp,"_PROD"))!=Nil .AND. ;
							(oAux := XmlChildEx(oAux,"_VDESC"))!=Nil

						nDesconto := Val(oItemTemp:_PROD:_VDESC:TEXT)
					endif
					//if Type("oItemTemp:_PROD:_VOUTRO") != "U"
					if (oAux := XmlChildEx(oItemTemp,"_PROD"))!=Nil .AND. ;
							(oAux := XmlChildEx(oAux,"_VOUTRO"))!=Nil

						nAcrescim := Val(oItemTemp:_PROD:_VOUTRO:TEXT)
					endif

					aadd(aItensXML,{AllTrim(oItemTemp:_PROD:_CPROD:TEXT), Val(oItemTemp:_PROD:_QCOM:TEXT), Val(oItemTemp:_PROD:_VUNCOM:TEXT), Val(oItemTemp:_PROD:_VPROD:TEXT), nDesconto, nAcrescim, cBico, cBomba, cTanque, nEncIni, nEncFin})
				Else
					//conout("STMonitor - oItemTemp <> objeto")
				EndIf
			Next nX

			//-- texto para gravar no LOG
			cTexto += "DADOS DO XML:" + CRLF
			cTexto += CRLF
			cTexto += "SERIE: " + cSerie + CRLF
			cTexto += "NF: " + cDocumento + CRLF
			cTexto += CRLF
			cTexto += "Destinatario: " + cDestinatario + CRLF
			cTexto += "Bico: " + cBico + CRLF
			cTexto += "Bomba: " + cBomba + CRLF
			cTexto += "Tanque: " + cTanque + CRLF
			cTexto += "Enc. Inicial: " + cValToChar(nEncIni) + CRLF
			cTexto += "Enc. Final: " + cValToChar(nEncFin) + CRLF
			cTexto += "Abastecimento: " + cCodAbast + CRLF
			cTexto += "Local: " + cLocAbast + CRLF
			cTexto += CRLF
			cTexto += CRLF

			If Empty(cNumOrc) .and. !lRet

				cNumImp  := ImportaXML(@cTexto, cDocumento, cSerie, dEmisNf, cHora, cKeyNfce, cCodCli, cLojCli, aItensXML, {cNumPDV, cNumOpe, cNumMov, cNumEst}, cRetSfz, cInfCpl)
				If !Empty(cNumImp)

					SL1->( DbSetOrder(1) ) // L1_FILIAL + L1_NUM
					SL1->( DbSeek( xFilial("SL1") + cNumImp ) )

					cTexto += CRLF
					cTexto += "XML IMPORTADO:" + CRLF
					cTexto += "Numero: " + cNumImp + CRLF
					cTexto += "Serie: " + SL1->L1_SERIE + CRLF
					cTexto += "Nf: " + SL1->L1_DOC + CRLF
					cTexto += "Status: " + SL1->L1_SITUA + CRLF

					cNotas += cFilAnt+";"+DtoC(SL1->L1_EMISNF)+";"+SL1->L1_DOC+";"+SL1->L1_SERIE+";"+SL1->L1_KEYNFCE+";"+SL1->L1_STATUS+";"+cValToChar(SL1->L1_VLRTOT)+";"+SL1->L1_SITUA+";" + CRLF
					cNomeArq := "LOG_01_"+cFilAnt+"_"+AllTrim(cSerie)+"_"+AllTrim(cDocumento)+"_"+cKeyNfce+"_"+DtoS(dDataBase)+"_"+SUBSTR(Time(),1,2)+SUBSTR(Time(),4,2)+SUBSTR(Time(),7,2)+".log"
					lRet := .T.
				Else
					cNomeArq := "ERR_IMP_"+cFilAnt+"_"+AllTrim(cSerie)+"_"+AllTrim(cDocumento)+"_"+cKeyNfce+"_"+DtoS(dDataBase)+"_"+SUBSTR(Time(),1,2)+SUBSTR(Time(),4,2)+SUBSTR(Time(),7,2)+".log"
				EndIf

			Else


			EndIf
			U_UCriaLog(cPathSX/*cPasta*/,cNomeArq/*cNomeArq*/,cTexto/*cTexto*/,.F./*lHelp*/)
			cTexto := ""

		EndIf


	Else //-- Importa NFC-e (Retaguarda)

		//destinatario
		cDestinatario := ""
		If Empty(aDestNfce)
			cDestinatario := "CONSUMIDOR NÃO IDENTIFICADO"
			cCodCli := PadR(SuperGetMV("MV_CLIPAD",,"000001"),TAMSX3("L1_CLIENTE")[1])
			cLojCli := PadR(SuperGetMV("MV_LOJAPAD",,"01"),TAMSX3("L1_LOJA")[1])
		Else
			uTmpXML := aDestNfce
			If Type("uTmpXML:_CPF:TEXT") != "U" //LjRTemNode(aDestNfce,"_CPF")
				cDestinatario := "CONSUMIDOR - CPF: " + Transform(aDestNfce:_CPF:TEXT, "@R 999.999.999-99")
				SA1->( DbSetOrder(3) ) //A1_FILIAL+A1_CGC
				If SA1->( DbSeek(xFilial("SA1")+AllTrim(aDestNfce:_CPF:TEXT) ) )
					cCodCli := SA1->A1_COD
					cLojCli := SA1->A1_LOJA
				EndIf
			ElseIf Type("uTmpXML:_CNPJ:TEXT") != "U" //LjRTemNode(aDestNfce,"_CNPJ")
				cDestinatario := "CONSUMIDOR - CNPJ: " + Transform(aDestNfce:_CNPJ:TEXT, "@R 99.999.999/9999-99")
				SA1->( DbSetOrder(3) ) //A1_FILIAL+A1_CGC
				If SA1->( DbSeek(xFilial("SA1")+AllTrim(aDestNfce:_CNPJ:TEXT) ) )
					cCodCli := SA1->A1_COD
					cLojCli := SA1->A1_LOJA
				EndIf
			ElseIf Type("uTmpXML:_IDESTRANGEIRO:TEXT") != "U" //LjRTemNode(aDestNfce,"_IDESTRANGEIRO")
				cDestinatario := "CONSUMIDOR Id. Estrangeiro: " + aDestNfce:_IDESTRANGEIRO:TEXT
				cCodCli := PadR(SuperGetMV("MV_CLIPAD",,"000001"),TAMSX3("L1_CLIENTE")[1])
				cLojCli := PadR(SuperGetMV("MV_LOJAPAD",,"01"),TAMSX3("L1_LOJA")[1])
			EndIf
		EndIf

		//-- verifica se ja existe a nota na base
		SL1->(DbSetOrder(2)) //L1_FILIAL+L1_SERIE+L1_DOC+L1_PDV
		SL1->(DbSeek(xFilial("SL1") + cSerie + cDocumento))
		If SL1->( Found() ) .and. SL1->L1_SITUA $ "OK/RX"
			//-- não faz nada, pois a venda ja esta OK

			//-- texto para gravar no LOG
			cTexto += "DADOS DO XML:" + CRLF
			cTexto += CRLF
			cTexto += "SERIE: " + cSerie + CRLF
			cTexto += "NF: " + cDocumento + CRLF
			cTexto += CRLF
			cTexto += "Não faz nada, pois a venda ja esta OK" + CRLF
			cTexto += CRLF
			cTexto += CRLF

			cNomeArq := "OK_01_"+cFilAnt+"_"+AllTrim(cSerie)+"_"+AllTrim(cDocumento)+"_"+AllTrim(cKeyNfce)+"_"+DtoS(dDataBase)+"_"+SUBSTR(Time(),1,2)+SUBSTR(Time(),4,2)+SUBSTR(Time(),7,2)+".log"
			//U_UCriaLog(cPathSX/*cPasta*/,cNomeArq/*cNomeArq*/,cTexto/*cTexto*/,.F./*lHelp*/) //-- por hora não faz nada
			cTexto := ""
			lRet := .T.

			If !Empty(SL1->L1_STATUS)
				cNotas += cFilAnt+";"+DtoC(SL1->L1_EMISNF)+";"+SL1->L1_DOC+";"+SL1->L1_SERIE+";"+SL1->L1_KEYNFCE+";"+SL1->L1_STATUS+";"+cValToChar(SL1->L1_VLRTOT)+";"+SL1->L1_SITUA+";" + CRLF
			EndIf

		ElseIf SL1->( Found() )
			//-- encontrou, porem não integrou (L1_SITUA <> TX/00)

			//-- texto para gravar no LOG
			cTexto += "DADOS DO XML:" + CRLF
			cTexto += CRLF
			cTexto += "SERIE: " + cSerie + CRLF
			cTexto += "NF: " + cDocumento + CRLF
			cTexto += CRLF
			cTexto += "Encontrou, porem não integrou (L1_SITUA <> OK/RX)" + CRLF
			cTexto += CRLF
			cTexto += CRLF

			cNomeArq := "ERR_02_"+cFilAnt+"_"+AllTrim(cSerie)+"_"+AllTrim(cDocumento)+"_"+AllTrim(cKeyNfce)+"_"+DtoS(dDataBase)+"_"+SUBSTR(Time(),1,2)+SUBSTR(Time(),4,2)+SUBSTR(Time(),7,2)+".log"
			U_UCriaLog(cPathSX/*cPasta*/,cNomeArq/*cNomeArq*/,cTexto/*cTexto*/,.F./*lHelp*/) //-- por hora não faz nada
			cTexto := ""

			If !Empty(SL1->L1_STATUS)
				cNotas += cFilAnt+";"+DtoC(SL1->L1_EMISNF)+";"+SL1->L1_DOC+";"+SL1->L1_SERIE+";"+SL1->L1_KEYNFCE+";"+SL1->L1_STATUS+";"+cValToChar(SL1->L1_VLRTOT)+";"+SL1->L1_SITUA+";" + CRLF
			EndIf

		Else
			//-- verifica abastecimento
			cBico := ""; cBomba := ""; cTanque := ""; cCodAbast := ""; cLocAbast := ""; cNumOrc := ""
			nEncIni := 0; nEncFin := 0; nDesconto := 0;  nAcrescim := 0

			//-- pega os dados de um dos abastecimentos, para tentar localizar a venda
			aItensXML := {} //[01-Produto][02-Quantidade][03-VlrUnitario][04-VlrTotal][05-VlrDesc][06-VlrAcres][07-cBico][08-cBomba][09-cTanque][10-nEncIni][11-nEncFin]
			For nX := 1 to Len(aItemNfce)
				cBico := ""; cBomba := ""; cTanque := ""; nEncIni := 0; nEncFin := 0
				nDesconto := 0
				nAcrescim := 0
				oItemTemp := aItemNfce[nX]
				If ValType(oItemTemp) == "O"
					//If Type("oItemTemp:_PROD:_COMB") == "O" .and. Type("oItemTemp:_PROD:_COMB:_ENCERRANTE") == "O"
					if (oAux := XmlChildEx(oItemTemp,"_PROD"))!=Nil .AND. ;
							(oAux := XmlChildEx(oAux,"_COMB"))!=Nil .AND. ;
							(oAux := XmlChildEx(oAux,"_ENCERRANTE"))!=Nil

						cBico := oItemTemp:_PROD:_COMB:_ENCERRANTE:_NBICO:TEXT
						cTanque := oItemTemp:_PROD:_COMB:_ENCERRANTE:_NTANQUE:TEXT
						//If Type("oItemTemp:_PROD:_COMB:_ENCERRANTE:_NBOMBA") == "O"
						If (oAux := XmlChildEx(oAux,"_NBOMBA"))!=Nil
							cBomba := oItemTemp:_PROD:_COMB:_ENCERRANTE:_NBOMBA:TEXT
						EndIf
						nEncIni := Val(oItemTemp:_PROD:_COMB:_ENCERRANTE:_VENCINI:TEXT)
						nEncFin := Val(oItemTemp:_PROD:_COMB:_ENCERRANTE:_VENCFIN:TEXT)
						//Exit //sai do For
					EndIf
					//if Type("oItemTemp:_PROD:_VDESC") != "U"
					if (oAux := XmlChildEx(oItemTemp,"_PROD"))!=Nil .AND. ;
							(oAux := XmlChildEx(oAux,"_VDESC"))!=Nil

						nDesconto := Val(oItemTemp:_PROD:_VDESC:TEXT)
					endif
					//if Type("oItemTemp:_PROD:_VOUTRO") != "U"
					if (oAux := XmlChildEx(oItemTemp,"_PROD"))!=Nil .AND. ;
							(oAux := XmlChildEx(oAux,"_VOUTRO"))!=Nil

						nAcrescim := Val(oItemTemp:_PROD:_VOUTRO:TEXT)
					endif

					aadd(aItensXML,{AllTrim(oItemTemp:_PROD:_CPROD:TEXT), Val(oItemTemp:_PROD:_QCOM:TEXT), Val(oItemTemp:_PROD:_VUNCOM:TEXT), Val(oItemTemp:_PROD:_VPROD:TEXT), nDesconto, nAcrescim, cBico, cBomba, cTanque, nEncIni, nEncFin})
				Else
					//conout("STMonitor - oItemTemp <> objeto")
				EndIf
			Next nX

			//-- DE/PARA: PRODUTO DO MARACANA
			//-- verifica código do produto
		/* -> especifico para importação de XML do antigo sistema
			For nX := 1 to Len(aItensXML)

			cCondicao := "B1_FILIAL = '" + xFilial("SB1") + "'"
			cCondicao += " .AND. B1_CODANT = '" + PadR(aItensXML[nX][1],TAMSX3("B1_CODANT")[1]) + "'"

			SB1->(DbClearFilter()) //-- limpo os filtros da SB1
			bCondicao := "{|| " + cCondicao + " }"
			SB1->(DbSetFilter(&bCondicao,cCondicao))
			SB1->(DbGoTop())

				If SB1->(!Eof())
				aItensXML[nX][1] := SB1->B1_COD
				Else

				//-- texto para gravar no LOG
				cTexto += "Produto não encontrado no sistema." + CRLF
			   	cTexto += CRLF
			   	cTexto += "CODIGO PRODUTO XML: " + aItensXML[nX][1] + CRLF
				cTexto += CRLF
				cTexto += CRLF

				cNomeArq := "ERR_07_"+cFilAnt+"_"+AllTrim(cSerie)+"_"+AllTrim(cDocumento)+"_"+cKeyNfce+"_"+DtoS(dDataBase)+"_"+SUBSTR(Time(),1,2)+SUBSTR(Time(),4,2)+SUBSTR(Time(),7,2)+".log"
				U_UCriaLog(cPathSX, cNomeArq, cTexto, .F.) //-- por hora não faz nada
				cTexto := ""

				Return lRet := .F.

				EndIf

			Next nX

		SB1->(DbClearFilter()) //-- limpo os filtros da SB1
		*/

			//-- se conseguiu recuperar abastecimento do XML, tenta encontra-lo no cadastro de abastecimentos
			//-- em 20/06/2018: comentado esse trecho, para que todas as vendas recuperadas sejam recuperadas com os dados do abastecimento
		/*
			If !Empty(cBico) .and. nEncFin > 0

			//U51->(DbSetOrder(6)) //U51_FILIAL+U51_CODBIC+STR(U51_ENCERR)+U51_CODIGO
			//U51->(DbSeek(xFilial("U51")+SubStr(AllTrim(cBico),1,TamSX3("U51_CODBIC")[1])+Str(nEncFin,TamSX3("U51_ENCERR")[1],TamSX3("U51_ENCERR")[2])))

			cCondicao := "U51_FILIAL = '" + xFilial("U51") + "'"
			cCondicao += " .AND. U51_ENCERR = " + cValToChar(nEncFin) + ""
			cCondicao += " .AND. AllTrim(U51_NUMBIC) = '" + AllTrim(cBico) + "'"

			U51->(DbClearFilter()) //-- limpo os filtros da U51
			bCondicao := "{|| " + cCondicao + " }"
			U51->(DbSetFilter(&bCondicao,cCondicao))
			U51->(DbGoTop())

				While U51->(!Eof()) .and. U51->U51_FILIAL == xFilial("U51") .and. AllTrim(U51->U51_NUMBIC) = AllTrim(cBico) .and. U51->U51_ENCERR = nEncFin
					If U51->U51_BOMBA == cTanque .and. U51->(U51_ENCERR - U51_QTDLT) == nEncIni
					cCodAbast := U51->U51_CODIGO
					cLocAbast := U51->U51_LOCAL

					//-- verifica se existe venda para tal abastecimento
						If !Empty(cCodAbast)
						SL2->(DbOrderNickName("ABASTEC")) //L2_FILIAL+L2_XABASTE
							If SL2->(DbSeek(xFilial("SL2")+cCodAbast))
							cNumOrc := SL2->L2_NUM

							//-- verifica status da venda
								If !Empty(cNumOrc)
								SL1->(DbSetOrder(1)) //L1_FILIAL+L1_NUM
								SL1->(DbSeek(xFilial("SL1")+cNumOrc))
									If SL1->( Found() ) .and. SL1->L1_SITUA $ "TX/00"
									aItensSL2 := {} //[01-Produto][02-Quantidade][03-VlrUnitario][04-VlrTotal][05-VlrDesc][06-VlrAcres][07-cBico][08-cBomba][09-cTanque][10-nEncIni][11-nEncFin]
									SL2->(DbSetOrder(1)) //L2_FILIAL+L2_NUM+L2_ITEM+L2_PRODUTO
									SL2->(DbSeek(xFilial("SL2")+cNumOrc))
										While SL2->(!Eof()) .and. cNumOrc == SL2->L2_NUM
										aadd(aItensSL2,{AllTrim(SL2->L2_PRODUTO),SL2->L2_QUANT,SL2->L2_VRUNIT,SL2->L2_VLRITEM,SL2->L2_VALDESC})
										SL2->(DbSkip())
										EndDo
									//Exit //sai do While
									//aItensXML := {} //[01-Produto][02-Quantidade][03-VlrUnitario][04-VlrTotal][05-VlrDesc][06-VlrAcres][07-cBico][08-cBomba][09-cTanque][10-nEncIni][11-nEncFin]
										If Len(aItensXML) == Len(aItensSL2)
											For nX := 1 to Len(aItensSL2)
												If aScan( aItensXML, {|x| x[1] == aItensSL2[nX][1] .and. x[2] == aItensSL2[nX][2]} ) <= 0
												cNumOrc := "" //-- zero a variavel do orçamento a ser copiado, pois as vendas são diferentes
												Exit //sai do For
												EndIf
											Next nX
										EndIf

									EndIf
								EndIf
							EndIf
						EndIf
					EndIf
				U51->(DbSkip())
				EndDo


			U51->(DbClearFilter()) //-- limpo os filtros da U51
			EndIf
		*/

			If !Empty(cNumOrc)

				//-- verifica se a venda a ser copiada é exatametne igual a venda do XML
				SL2->( DbSetOrder(1) ) // L2_FILIAL + L2_NUM + L2_ITEM + L2_PRODUTO
				SL2->( DbGoTop() )
				SL2->( DbSeek( xFilial("SL2") + cNumOrc ) )
				While !SL2->( Eof() ) .AND. SL2->L2_FILIAL == xFilial("SL2") .AND. SL2->L2_NUM == cNumOrc
					//aItensXML -> [01-Produto][02-Quantidade][03-VlrUnitario][04-VlrTotal][05-VlrDesc][06-VlrAcres][07-cBico][08-cBomba][09-cTanque][10-nEncIni][11-nEncFin]
					nPos := aScan( aItensXML, { |x| AllTrim(x[1]) == AllTrim(SL2->L2_PRODUTO) .and. x[2] == SL2->L2_QUANT } )
					If nPos > 0 .and. SL2->(L2_VLRITEM) <> (aItensXML[nPos][04] + aItensXML[nPos][06] - aItensXML[nPos][05])

						cTexto += CRLF
						cTexto += "ORCAMENTO: " + cNumOrc + CRLF
						cTexto += "ERRO NO TOTAL DO ITEM: " + CRLF
						cTexto += "ITEM: " + SL2->L2_ITEM + CRLF
						cTexto += CRLF
						cTexto += "TOTAL ITEM (SL2): " + cValToChar(SL2->(L2_VLRITEM)) + CRLF
						cTexto += "VLR ITEM (SL2): " + cValToChar(SL2->L2_VLRITEM + SL2->L2_VALDESC) + CRLF
						cTexto += "DESCONTO (SL2): " + cValToChar(SL2->L2_VALDESC) + CRLF
						cTexto += CRLF
						cTexto += "TOTAL ITEM (XML): " + cValToChar(aItensXML[nPos][04]-aItensXML[nPos][05]) + CRLF
						cTexto += "VLR ITEM (XML): " + cValToChar(aItensXML[nPos][04]) + CRLF
						cTexto += "ACRESCIMO (XML): " + cValToChar(aItensXML[nPos][06]) + CRLF
						cTexto += "DESCONTO (XML): " + cValToChar(aItensXML[nPos][05]) + CRLF
						cTexto += CRLF
						cTexto += CRLF

						cNumOrc := ""
						Exit //sai do While

					ElseIf nPos <= 0

						cTexto += CRLF
						cTexto += "ORCAMENTO: " + cNumOrc + CRLF
						cTexto += "ERRO NAO ENCONTRADO O ITEM NO XML: " + CRLF
						cTexto += "ITEM: " + SL2->L2_ITEM + CRLF
						cTexto += CRLF
						cTexto += "TOTAL ITEM (SL2): " + cValToChar(SL2->(L2_VLRITEM)) + CRLF
						cTexto += "VLR ITEM (SL2): " + cValToChar(SL2->L2_VLRITEM + SL2->L2_VALDESC) + CRLF
						cTexto += "DESCONTO (SL2): " + cValToChar(SL2->L2_VALDESC) + CRLF
						cTexto += CRLF
						cTexto += CRLF

						cNumOrc := ""
						Exit //sai do While

					EndIf

					SL2->( DbSkip() )
				EndDo

				If !Empty(cNumOrc)

					nTXML := 0
					For nX:=1 to Len(aItensXML)
						nTXML += aItensXML[nX][4]+aItensXML[nX][6]-aItensXML[nX][5]
					Next nX

					aItensSL2 := {} //[01-Produto][02-Quantidade][03-VlrUnitario][04-VlrTotal][05-VlrDesc][06-VlrAcres][07-cBico][08-cBomba][09-cTanque][10-nEncIni][11-nEncFin]
					SL2->(DbSetOrder(1)) //L2_FILIAL+L2_NUM+L2_ITEM+L2_PRODUTO
					SL2->(DbGoTop())
					SL2->(DbSeek(xFilial("SL2")+cNumOrc))
					While SL2->(!Eof()) .and. cNumOrc == SL2->L2_NUM
						aadd(aItensSL2,{AllTrim(SL2->L2_PRODUTO),SL2->L2_QUANT,SL2->L2_VRUNIT,SL2->L2_VLRITEM,SL2->L2_VALDESC})
						SL2->(DbSkip())
					EndDo

					nTSL2 := 0
					For nX:=1 to Len(aItensSL2)
						nTSL2 += aItensSL2[nX][4]
					Next nX

					If nTSL2 <> nTXML
						cNumOrc := ""
					EndIf

				EndIf

			EndIf

			//-- texto para gravar no LOG
			cTexto += "DADOS DO XML:" + CRLF
			cTexto += CRLF
			cTexto += "SERIE: " + cSerie + CRLF
			cTexto += "NF: " + cDocumento + CRLF
			cTexto += CRLF
			cTexto += "Destinatario: " + cDestinatario + CRLF
			cTexto += "Bico: " + cBico + CRLF
			cTexto += "Bomba: " + cBomba + CRLF
			cTexto += "Tanque: " + cTanque + CRLF
			cTexto += "Enc. Inicial: " + cValToChar(nEncIni) + CRLF
			cTexto += "Enc. Final: " + cValToChar(nEncFin) + CRLF
			cTexto += "Abastecimento: " + cCodAbast + CRLF
			cTexto += "Local: " + cLocAbast + CRLF
			If !Empty(cNumOrc)
				cTexto += CRLF
				cTexto += "ORCAMENTO A SER COPIADO:" + CRLF
				cTexto += "Numero: " + cNumOrc + CRLF
				cTexto += "Serie: " + SL1->L1_SERIE + CRLF
				cTexto += "Nf: " + SL1->L1_DOC + CRLF
				cTexto += "Status: " + SL1->L1_SITUA + CRLF
			EndIf
			cTexto += CRLF
			cTexto += CRLF

			If !Empty(cNumOrc)

				cNumCpy  := CopyVenda(cNumOrc, @cTexto, cDocumento, cSerie, dEmisNf, cHora, cKeyNfce, cRetSfz, aItensXML)
				If !Empty(cNumCpy)

					SL1->( DbSetOrder(1) ) // L1_FILIAL + L1_NUM
					SL1->( DbSeek( xFilial("SL1") + cNumCpy ) )

					cTexto += CRLF
					cTexto += "ORCAMENTO COPIADO:" + CRLF
					cTexto += "Numero: " + cNumCpy + CRLF
					cTexto += "Serie: " + SL1->L1_SERIE + CRLF
					cTexto += "Nf: " + SL1->L1_DOC + CRLF
					cTexto += "Status: " + SL1->L1_SITUA + CRLF

					cNotas += cFilAnt+";"+DtoC(SL1->L1_EMISNF)+";"+SL1->L1_DOC+";"+SL1->L1_SERIE+";"+SL1->L1_KEYNFCE+";"+SL1->L1_STATUS+";"+cValToChar(SL1->L1_VLRTOT)+";"+SL1->L1_SITUA+";" + CRLF
					cNomeArq := "LOG_02_"+cFilAnt+"_"+AllTrim(cSerie)+"_"+AllTrim(cDocumento)+"_"+cKeyNfce+"_"+DtoS(dDataBase)+"_"+SUBSTR(Time(),1,2)+SUBSTR(Time(),4,2)+SUBSTR(Time(),7,2)+".log"
					lRet := .T.
				Else
					cNomeArq := "ERR_CPY_"+cFilAnt+"_"+AllTrim(cSerie)+"_"+AllTrim(cDocumento)+"_"+cKeyNfce+"_"+DtoS(dDataBase)+"_"+SUBSTR(Time(),1,2)+SUBSTR(Time(),4,2)+SUBSTR(Time(),7,2)+".log"
					cNumOrc  := "" //--limpo o orçamento a ser copiado para tentar importar via XML
				EndIf

			EndIf

			If Empty(cNumOrc) .and. !lRet

				cNumImp  := ImportaXML(@cTexto, cDocumento, cSerie, dEmisNf, cHora, cKeyNfce, cCodCli, cLojCli, aItensXML, {cNumPDV, cNumOpe, cNumMov, cNumEst}, cRetSfz, cInfCpl)
				If !Empty(cNumImp)

					SL1->( DbSetOrder(1) ) // L1_FILIAL + L1_NUM
					SL1->( DbSeek( xFilial("SL1") + cNumImp ) )

					cTexto += CRLF
					cTexto += "XML IMPORTADO:" + CRLF
					cTexto += "Numero: " + cNumImp + CRLF
					cTexto += "Serie: " + SL1->L1_SERIE + CRLF
					cTexto += "Nf: " + SL1->L1_DOC + CRLF
					cTexto += "Status: " + SL1->L1_SITUA + CRLF

					cNotas += cFilAnt+";"+DtoC(SL1->L1_EMISNF)+";"+SL1->L1_DOC+";"+SL1->L1_SERIE+";"+SL1->L1_KEYNFCE+";"+SL1->L1_STATUS+";"+cValToChar(SL1->L1_VLRTOT)+";"+SL1->L1_SITUA+";" + CRLF
					cNomeArq := "LOG_01_"+cFilAnt+"_"+AllTrim(cSerie)+"_"+AllTrim(cDocumento)+"_"+cKeyNfce+"_"+DtoS(dDataBase)+"_"+SUBSTR(Time(),1,2)+SUBSTR(Time(),4,2)+SUBSTR(Time(),7,2)+".log"
					lRet := .T.
				Else
					cNomeArq := "ERR_IMP_"+cFilAnt+"_"+AllTrim(cSerie)+"_"+AllTrim(cDocumento)+"_"+cKeyNfce+"_"+DtoS(dDataBase)+"_"+SUBSTR(Time(),1,2)+SUBSTR(Time(),4,2)+SUBSTR(Time(),7,2)+".log"
				EndIf

			Else


			EndIf
			U_UCriaLog(cPathSX/*cPasta*/,cNomeArq/*cNomeArq*/,cTexto/*cTexto*/,.F./*lHelp*/)
			cTexto := ""

		EndIf
	EndIf

Return lRet


//-------------------------------------------------------------------
/*/{Protheus.doc} VldNFSefaz
Retorna o status das notas, conforme vetor encaminhado
@author  author
@since   date
@version version
/*/
//-------------------------------------------------------------------
//User Function STMVLSEF(lConsTSS, aNotas)
//Return VldNFSefaz(lConsTSS, aNotas)
Static Function VldNFSefaz(lConsTSS, aNotas)
	Local cRetSFZ  := ""
	Local aRet := {}, aInfMonNFe := {}
	Local ix := 0

	If Type("cIdEntNFe") == "U"
		//-- Determina ID
		cIdEntNFe	:= URetEntTss("55",.F.) //RetIdEnti()
		cURLNFe		:= AllTrim( GetMV("MV_SPEDURL") )

		cIdEntNFCe	:= URetEntTss("65",.F.) //StaticCall(LOJNFCE,LjNFCeIDEnt)
		cURLNFCe	:= AllTrim( GetMV("MV_NFCEURL") )
	EndIf

	for ix:=1 to len(aNotas)

		//-- Consulta no TSS
		lNFe := aNotas[ix][03]
		cModelo := "65"
		If Len(aNotas[ix]) > 3
			cModelo := aNotas[ix][04]
		Else
			cModelo := iif(lNFe,"55","65")
		EndIf
		if lConsTSS

			//-- aNotas[01] Serie
			//-- aNotas[02] Nr da NF a Consultar
			aInfMonNFe := ProcMonitorDoc( iif(lNFe,cIdEntNFe,cIdEntNFCe),;
				iif(lNFe,cURLNFe,cURLNFCe),;
				{aNotas[ix][01],aNotas[ix][02],aNotas[ix][02]},;
				1 /*nTpMonitor*/,;
				cModelo,;
				.F. /*lCte*/,;
				@cRetSFZ)

			if len(aInfMonNFe) == 0
				////conout("STMonitor: Sem retorno no TSS Local " + iif(lNFe,cIdEntNFe,cIdEntNFCe) + "/" + aNotas[ix][01] + "/" + aNotas[ix][02] )

			endif

			if len(aInfMonNFe)>0
				aadd(aRet, aClone(aInfMonNFe[len(aInfMonNFe)]))
			endif

			//-- Consulta na SEFAZ
		else
			//-- aNotas[01] = Chave NFe/NFCe
			////conout("STMonitor: Consultando SEFAZ " + iif(lNFe,cIdEntNFe,cIdEntNFCe) + "/" + aNotas[ix][01] )
			aInfMonNFe := ConsNFeSEFAZ(iif(lNFe,cIdEntNFe,cIdEntNFCe), iif(lNFe,cURLNFe,cURLNFCe), aNotas[ix][01] )

			if len(aInfMonNFe)>0
				aRet := aClone(aInfMonNFe)
			else
				////conout("STMonitor: Sem retorno no SEFAZ " + iif(lNFe,cIdEntNFe,cIdEntNFCe) + "/" + aNotas[ix][01] )
			endif

		endif

	next ix

Return aClone(aRet)


//-------------------------------------------------------------------
/*/{Protheus.doc} ConsNFeSEFAZ
Consulta na SEFAZ
@author  author
@since   date
@version version
/*/
//-------------------------------------------------------------------
Static Function ConsNFeSEFAZ(cIdEnt, cUrl, cChave)
	Local oWS := {}, aDados := {"","","","","",""}

	oWs:= WsNFeSBra():New()
	oWs:cUserToken	:= "TOTVS"
	oWs:cID_ENT		:= cIdEnt
	oWs:cCHVNFE		:= cChave
	oWs:_URL        := AllTrim(cURL)+"/NFeSBRA.apw"

	if !oWs:ConsultaChaveNFE()
		Return aDados
	endif

	if !Empty(oWs:oWSCONSULTACHAVENFERESULT:cVERSAO)
		aDados[01] := oWs:oWSCONSULTACHAVENFERESULT:cVERSAO
	endif

	aDados[02] := IIf(oWs:oWSCONSULTACHAVENFERESULT:nAMBIENTE==1,"1-Produção","2-Homologação")
	aDados[03] := oWs:oWSCONSULTACHAVENFERESULT:cCODRETNFE
	aDados[04] := oWs:oWSCONSULTACHAVENFERESULT:cMSGRETNFE

	if !Empty(oWs:oWSCONSULTACHAVENFERESULT:cPROTOCOLO)
		aDados[05] := oWs:oWSCONSULTACHAVENFERESULT:cPROTOCOLO
	endif

	if !Empty(oWs:oWSCONSULTACHAVENFERESULT:cDIGVAL)
		aDados[06] := oWs:oWSCONSULTACHAVENFERESULT:cDIGVAL
	endif

Return aDados

/*/{Protheus.doc} EscEmpresa
Funcao Generica para escolha de Empresa, montado pelo SM0.
Retorna vetor contendo as selecoes feitas.
Se nao For marcada nenhuma o vetor volta vazio.

@author Totvs TBC
@since 31/10/2017

@version 1.0
@return ${return}, ${return_description}

@type function
/*/
Static Function EscEmpresa(cEmpEsc,cFilNot)
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Parametro  nTipo                           ³
//³ 1  - Monta com Todas Empresas/Filiais      ³
//³ 2  - Monta so com Empresas                 ³
//³ 3  - Monta so com Filiais de uma Empresa   ³
//³                                            ³
//³                                            ³
//³ Parametro  cEmpSel                         ³
//³ Empresa que sera usada para montar selecao ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	Local   aSalvAmb := GetArea()
	Local   aSalvSM0 := {}
	Local   aRet     := {}
	Local   aVetor   := {}
	Local   oDlg     := NIL
	Local   oChkMar  := NIL
	Local   oLbx     := NIL
	Local   oMascEmp := NIL
	Local   oButMarc := NIL
	Local   oButDMar := NIL
	Local   oButInv  := NIL
	Local   oSay     := NIL
	Local   oOk      := LoadBitmap( GetResources(), "LBOK" )
	Local   oNo      := LoadBitmap( GetResources(), "LBNO" )
	Local   lChk     := .F.
	Local   lTeveMarc:= .F.
	Local   cVar     := ""
	Local   cMascEmp := "??"
	Local   cMascFil := "??"
	Local   aMarcadas := {}

	Default cEmpEsc := ""
	Default cFilNot := ""

	If !MyOpenSm0(.T.)
		Return aRet
	EndIf

	dbSelectArea( "SM0" )
	aSalvSM0 := SM0->( GetArea() )
	dbSetOrder( 1 )
	dbGoTop()

	While !SM0->( EOF() )
		If (AllTrim(cFilNot) <> AllTrim(SM0->M0_CODFIL)) .and. (Empty(cEmpEsc) .or. AllTrim(SM0->M0_CODIGO) == AllTrim(cEmpEsc))
			If aScan( aVetor, {|x| x[2] == SM0->M0_CODIGO .and. x[3] == SM0->M0_CODFIL} ) == 0
				If Empty(cEmpEsc)
					aAdd( aVetor, { aScan( aMarcadas, {|x| x[1] == SM0->M0_CODIGO .and. x[2] == SM0->M0_CODFIL} ) > 0, SM0->M0_CODIGO, SM0->M0_CODFIL, SM0->M0_NOME, SM0->M0_FILIAL } )
				Else
					aAdd( aVetor, { aScan( aMarcadas, {|x| x[1] == SM0->M0_CODIGO .and. x[2] == SM0->M0_CODFIL} ) > 0, SM0->M0_CODFIL, SM0->M0_FILIAL } )
				EndIf
			EndIf
		EndIf
		SM0->( DbSkip() )
	EndDo

	RestArea( aSalvSM0 )

	Define MSDialog  oDlg Title "" From 0, 0 To 275, 396 Pixel

	oDlg:cToolTip := "Tela para Múltiplas Seleções de Empresas/Filiais"
	oDlg:cTitle   := "Selecione a(s) Empresa(s)..."

	If Empty(cEmpEsc)
		@ 10, 10 Listbox  oLbx Var  cVar Fields Header " ", "Empresa", "Filial", "Grupo", "Nome" Size 178, 095 Of oDlg Pixel
		oLbx:SetArray( aVetor )
		oLbx:bLine := {|| {IIf( aVetor[oLbx:nAt, 1], oOk, oNo ), ;
			aVetor[oLbx:nAt, 2], ;
			aVetor[oLbx:nAt, 3], ;
			aVetor[oLbx:nAt, 4], ;
			aVetor[oLbx:nAt, 5]}}
	Else
		@ 10, 10 Listbox  oLbx Var  cVar Fields Header " ", "Filial", "Nome" Size 178, 095 Of oDlg Pixel
		oLbx:SetArray( aVetor )
		oLbx:bLine := {|| {IIf( aVetor[oLbx:nAt, 1], oOk, oNo ), ;
			aVetor[oLbx:nAt, 2], ;
			aVetor[oLbx:nAt, 3]}}
	EndIf

	oLbx:BlDblClick := { || aVetor[oLbx:nAt, 1] := !aVetor[oLbx:nAt, 1], VerTodos( aVetor, @lChk, oChkMar ), oChkMar:Refresh(), oLbx:Refresh()}
	oLbx:cToolTip   :=  oDlg:cTitle
	oLbx:lHScroll   := .F. // NoScroll

	@ 112, 10 CheckBox oChkMar Var  lChk Prompt "Todos"   Message  Size 40, 007 Pixel Of oDlg;
		on Click MarcaTodos( lChk, @aVetor, oLbx )

	@ 124, 10 Button oButInv Prompt "&Inverter"  Size 32, 12 Pixel Action ( InvSelecao( @aVetor, oLbx ), VerTodos( aVetor, @lChk, oChkMar ) ) ;
		Message "Inverter Seleção" Of oDlg

// Marca/Desmarca por mascara
	@ 113, 51 Say  oSay Prompt "Empresa" Size  40, 08 Of oDlg Pixel
	@ 112, 80 MSGet  oMascEmp Var  cMascEmp Size  05, 05 Pixel Picture "@!"  Valid (  cMascEmp := StrTran( cMascEmp, " ", "?" ), cMascFil := StrTran( cMascFil, " ", "?" ), oMascEmp:Refresh(), .T. ) ;
		Message "Máscara Empresa ( ?? )"  Of oDlg
	@ 124, 50 Button oButMarc Prompt "&Marcar"    Size 32, 12 Pixel Action ( MarcaMas( oLbx, aVetor, cMascEmp, .T. ), VerTodos( aVetor, @lChk, oChkMar ) ) ;
		Message "Marcar usando máscara ( ?? )"    Of oDlg
	@ 124, 90 Button oButDMar Prompt "&Desmarcar" Size 32, 12 Pixel Action ( MarcaMas( oLbx, aVetor, cMascEmp, .F. ), VerTodos( aVetor, @lChk, oChkMar ) ) ;
		Message "Desmarcar usando máscara ( ?? )" Of oDlg

	Define SButton From 111, 125 Type 1 Action ( RetSelecao( @aRet, aVetor , cEmpEsc ), oDlg:End() ) OnStop "Confirma a Seleção"  Enable Of oDlg
	Define SButton From 111, 158 Type 2 Action ( IIf( lTeveMarc, aRet := aMarcadas, .T. ), oDlg:End() ) OnStop "Abandona a Seleção" Enable Of oDlg
	Activate MSDialog  oDlg Center

	RestArea( aSalvAmb )
	dbSelectArea( "SM0" )
	dbCloseArea()

Return aRet

/*/{Protheus.doc} MyOpenSM0
Funcao de processamento abertura do SM0 modo exclusivo.

@author Totvs TBC
@since 19/08/2015
@version 1.0

@return ${return}, ${return_description}
@param lShared, logical, Caso verdadeiro, indica que a tabela deve ser aberta em modo compartilhado, isto é, outros processos também poderão abrir esta tabela.

@type function
/*/
Static Function MyOpenSM0(lShared)

	Local lOpen := .F.
	Local nLoop := 0

	For nLoop := 1 To 20 //faz 20 tentativas

		If lShared
			OpenSm0() //Essa função realiza a abertura do SIGAMAT, utilizando como alias o SM0.
		Else
			OpenSM0Excl() //Essa função realiza a abertura do SIGAMAT em modo EXCLUSIVO, utilizando como alias o SM0.
		EndIf

		If !Empty( Select( "SM0" ) )
			lOpen := .T.
			Exit
		EndIf

		Sleep( 500 )

	Next nLoop

	If !lOpen
		Help(NIL, NIL, "ATENÇÃO", NIL, "Não foi possível a abertura da tabela " + ;
			IIf( lShared, "de empresas (SM0).", "de empresas (SM0) de forma exclusiva." ), 1, 0, NIL, NIL, NIL, NIL, NIL, {""})
	EndIf

Return lOpen

/*/{Protheus.doc} MarcaTodos
Funcao Auxiliar para marcar/desmarcar todos os itens do ListBox ativo.

@author Ernani Forastieri
@since 31/10/2017
@version 1.0
@return ${return}, ${return_description}
@param lMarca, logical, descricao
@param aVetor, array, descricao
@param oLbx, object, descricao
@type function
/*/
Static Function MarcaTodos( lMarca, aVetor, oLbx )
	Local  nI := 0

	For nI := 1 To Len( aVetor )
		aVetor[nI][1] := lMarca
	Next nI

	oLbx:Refresh()

Return NIL

/*/{Protheus.doc} InvSelecao
Funcao Auxiliar para inverter selecao do ListBox Ativo.

@author Ernani Forastieri
@since 31/10/2017
@version 1.0

@return ${return}, ${return_description}
@param aVetor, array, descricao
@param oLbx, object, descricao

@type function
/*/
Static Function InvSelecao( aVetor, oLbx )
	Local  nI := 0

	For nI := 1 To Len( aVetor )
		aVetor[nI][1] := !aVetor[nI][1]
	Next nI

	oLbx:Refresh()

Return NIL

/*/{Protheus.doc} RetSelecao
Funcao Auxiliar que monta o retorno com as selecoes.

@author Ernani Forastieri
@since 31/10/2017
@version 1.0

@return ${return}, ${return_description}
@param aRet, array, descricao
@param aVetor, array, descricao

@type function
/*/
Static Function RetSelecao( aRet, aVetor, cEmpEsc )
	Local  nI    := 0

	aRet := {}
	For nI := 1 To Len( aVetor )
		If aVetor[nI][1]
			If Empty(cEmpEsc)
				aAdd( aRet, { aVetor[nI][2] , aVetor[nI][3], aVetor[nI][2] +  aVetor[nI][3] } ) //SM0->M0_CODIGO, SM0->M0_CODFIL, SM0->M0_CODIGO + SM0->M0_CODFIL
			Else
				aAdd( aRet, { aVetor[nI][2] } ) // SM0->M0_CODFIL
			EndIf
		EndIf
	Next nI

Return NIL

/*/{Protheus.doc} MarcaMas
Funcao para marcar/desmarcar usando mascaras.

@author Ernani Forastieri
@since 31/10/2017
@version 1.0

@return ${return}, ${return_description}

@param oLbx, object, descricao
@param aVetor, array, descricao
@param cMascEmp, characters, descricao
@param lMarDes, logical, descricao

@type function
/*/
Static Function MarcaMas( oLbx, aVetor, cMascEmp, lMarDes )
	Local cPos1 := SubStr( cMascEmp, 1, 1 )
	Local cPos2 := SubStr( cMascEmp, 2, 1 )
	Local nPos  := oLbx:nAt
	Local nZ    := 0

	For nZ := 1 To Len( aVetor )
		If cPos1 == "?" .or. SubStr( aVetor[nZ][2], 1, 1 ) == cPos1
			If cPos2 == "?" .or. SubStr( aVetor[nZ][2], 2, 1 ) == cPos2
				aVetor[nZ][1] :=  lMarDes
			EndIf
		EndIf
	Next

	oLbx:nAt := nPos
	oLbx:Refresh()

Return NIL

/*/{Protheus.doc} VerTodos
Funcao auxiliar para verificar se estao todos marcardos ou nao.

@author Ernani Forastieri
@since 31/10/2017
@version 1.0

@return ${return}, ${return_description}

@param aVetor, array, descricao
@param lChk, logical, descricao
@param oChkMar, object, descricao

@type function
/*/
Static Function VerTodos( aVetor, lChk, oChkMar )
	Local lTTrue := .T.
	Local nI     := 0

	For nI := 1 To Len( aVetor )
		lTTrue := IIf( !aVetor[nI][1], .F., lTTrue )
	Next nI

	lChk := IIf( lTTrue, .T., .F. )
	oChkMar:Refresh()

Return NIL

//-------------------------------------------------------------------
/*/{Protheus.doc} CopyVenda
Copia o orçamento enviado
@author  author
@since   date
@version version
/*/
//-------------------------------------------------------------------
Static Function CopyVenda(cNumOrc, cTexto, cDocumento, cSerie, dEmisNf, cHora, cKeyNfce, cRetSfz, aItensXML)

	Local aCabec 		:= {}
	Local aItens 		:= {}
	Local aItem  		:= {}
	Local aParcelas 	:= {}
	Local aParcela 		:= {}
	Local nValTot		:= 0
	Local cNumCpy		:= ""
	Local cMsgErr		:= ""

	Local aArea			:= GetArea()
	Local aAreaSL1		:= SL1->(GetArea())
	Local aAreaSL2		:= SL2->(GetArea())

	Local dDtBkp		:= dDataBase
	Local cTesPad       := ""
	Local cStringSLR	:= ""

	Local nSpedExc 		:= SuperGetMV("MV_SPEDEXC",,72)			// Indica a quantidade de horas q a NFe pode ser cancelada
	Local nNfceExc      := SuperGetMV("MV_NFCEEXC",, 0)         // Indica a quantidade de horas q a NFCe pode ser cancelada
	Local nHoras		:= 0
	Local cEspecie		:= ""
	Local luSitua		:= SuperGetMV("MV_XUSITUA",,.T.) //Integra a venda: atualiza o L1_SITUA para integrar

	Local cAliasSX3 := GetNextAlias() // apelido para o arquivo de trabalho
	Local lOpen   	:= .F. // valida se foi aberto a tabela

	Private lAutomatoX := .T. //variavel para evitar mostrar aviso de certificado proximo do vencimento

	If Type("nRecSL1FinVd") == "U"
		Private nRecSL1FinVd := 0   //recno do registro da SL1 apontado pelo PE LJ7002, apos inclusao de orcamento
	EndIf

	SL1->( DbSetOrder(1) ) // L1_FILIAL + L1_NUM
	SL1->( DbSeek( xFilial("SL1") + cNumOrc ) )

	cL1_PDV := SL1->L1_PDV
	cL1_OPERADO := SL1->L1_OPERADO
	cL1_ESTACAO := SL1->L1_ESTACAO
	cL1_NUMMOV := SL1->L1_NUMMOV

	nValTot := 0
	dDataBase := SL1->L1_EMISNF

	cTexto += CRLF
	cTexto += "COPIA DO ORCAMENTO..." + CRLF

	// abre o dicionário SX3
	OpenSXs(NIL, NIL, NIL, NIL, cEmpAnt, cAliasSX3, "SX3", NIL, .F.)
	lOpen := Select(cAliasSX3) > 0

	// caso aberto, posiciona no topo
	If !(lOpen)
		Return .F.
	EndIf
	DbSelectArea(cAliasSX3)
	(cAliasSX3)->( DbSetOrder(1) )

	SL2->( DbSetOrder(1) ) // L2_FILIAL + L2_NUM + L2_ITEM + L2_PRODUTO
	SL2->( DbGoTop() )
	SL2->( DbSeek( xFilial("SL2") + SL1->L1_NUM ) )
	while !SL2->( Eof() ) .AND. SL2->L2_FILIAL == xFilial("SL2") .AND. SL2->L2_NUM == SL1->L1_NUM

		if SL2->L2_VALDESC > 0
			cStringSLR := 'LR_PRODUTO/LR_QUANT/LR_PRCTAB/LR_VALDESC/LR_VEND'
		else
			cStringSLR := 'LR_PRODUTO/LR_QUANT/LR_PRCTAB/LR_VRUNIT/LR_VLRITEM/LR_VEND'
		endif

		aItem := {}

		(cAliasSX3)->( DbSeek("SLR") )
		while !(cAliasSX3)->( Eof() ) .and. (cAliasSX3)->&("X3_ARQUIVO") == "SLR"

			nPos := SL2->(FieldPos("L2_"+AllTrim(SubStr((cAliasSX3)->&("X3_CAMPO"),4,LEN((cAliasSX3)->&("X3_CAMPO"))))))
			if /*X3Uso((cAliasSX3)->&("X3_USADO")) .AND.*/ cNivel >= (cAliasSX3)->&("X3_NIVEL") .AND. nPos > 0 ;
					.AND. AllTrim((cAliasSX3)->&("X3_CAMPO"))$cStringSLR

				aadd(aItem, { (cAliasSX3)->&("X3_CAMPO"), SL2->( FieldGet(nPos) ), NIL})

			elseif /*X3Uso((cAliasSX3)->&("X3_USADO")) .AND.*/ cNivel >= (cAliasSX3)->&("X3_NIVEL") .AND. nPos > 0 ;
					.AND. AllTrim((cAliasSX3)->&("X3_CAMPO")) == 'LR_TES' //-- tratamento da TES

				cTesPad := SL2->L2_TES

				//-- DE/PARA: TES DO MARACANA
					/*
				If cTesPad = '501'
						cTesPad := '601'
				ElseIF cTesPad = '502'
						cTesPad := '602'
				ElseIf cTesPad = '503'
						cTesPad := '603'
				ElseIf cTesPad = '504'
						cTesPad := '604'
				ElseIf cTesPad = '507'
						cTesPad := '607'
				ElseIf cTesPad = '508'
						cTesPad := '608'
				Else
						cTexto += CRLF
						cTexto += "*** NAO EXISTE TES CORRESPONDENTE ***" + CRLF
						cTexto += "TES: " + cTesPad + CRLF
						cTexto += CRLF
				EndIf
					*/

				//-- DE/PARA: TES DA MARAJO - APARECIDAO
					/*
				if (cFilAnt == "0101")
					if cTesPad $ '502, 503, 504 e 505'
			    			cTesPad := '534'
					elseif cTesPad $ '506 e 507'
			    			cTesPad := '535'
					elseif cTesPad $ '508 e 509'
			    			cTesPad := '536'
					else
			    			cTexto += CRLF
							cTexto += "*** NAO EXISTE TES CORRESPONDENTE ***" + CRLF
							cTexto += "TES: " + cTesPad + CRLF
							cTexto += CRLF
					endif
			    	// -- DE/PARA: TES DA MARAJO - BELEM
				elseif (cFilAnt == "0201")
					if cTesPad $ '502, 503, 504, 505, 510 e 511'
			    			cTesPad := '534'
					elseif cTesPad $ '506 e 507'
			    			cTesPad := '535'
					elseif cTesPad $ '508 e 509'
			    			cTesPad := '536'
					else
			    			cTexto += CRLF
							cTexto += "*** NAO EXISTE TES CORRESPONDENTE ***" + CRLF
							cTexto += "TES: " + cTesPad + CRLF
							cTexto += CRLF
					endif
			    	// -- DE/PARA: TES DA MARAJO - CUIABA
				elseif (cFilAnt == "0701")
					if cTesPad $ '502, 503, 504, 505, 510 e 511'
			    			cTesPad := '534'
					else
			    			cTexto += CRLF
							cTexto += "*** NAO EXISTE TES CORRESPONDENTE ***" + CRLF
							cTexto += "TES: " + cTesPad + CRLF
							cTexto += CRLF
					endif
				endif
			    	*/

				//aadd(aItem, { (cAliasSX3)->&("X3_CAMPO"), cTesPad, NIL})

			endif

			(cAliasSX3)->( DbSkip() )

		enddo

		if Len(aItem)>0

			aadd(aItens,aItem)
			nValTot += SL2->L2_VLRITEM

		endif

		SL2->( DbSkip() )

	enddo

	// abre o dicionário SX3
	OpenSXs(NIL, NIL, NIL, NIL, cEmpAnt, cAliasSX3, "SX3", NIL, .F.)
	lOpen := Select(cAliasSX3) > 0

	// caso aberto, posiciona no topo
	If !(lOpen)
		Return .F.
	EndIf
	DbSelectArea(cAliasSX3)

	//dados do cabeçalho e forma de pagamento do orçamento de produtos que não são abastecimentos
	If Len(aItens)>0 .and. nValTot>0

		//preenche o cabeçalho do orçamento
		(cAliasSX3)->(DbSetOrder(1)) //X3_ARQUIVO+X3_ORDEM
		(cAliasSX3)->(DbSeek("SLQ"))
		While !(cAliasSX3)->(EOF()) .AND. (cAliasSX3)->&("X3_ARQUIVO") == "SLQ"

			nPos := SL1->(FieldPos("L1_"+AllTrim(SubStr((cAliasSX3)->&("X3_CAMPO"),4,LEN((cAliasSX3)->&("X3_CAMPO"))))))
			If /*X3Uso((cAliasSX3)->&("X3_USADO")) .AND.*/ cNivel >= (cAliasSX3)->&("X3_NIVEL") ;
					.AND. nPos > 0 .AND. AllTrim((cAliasSX3)->&("X3_CAMPO"))$'LQ_VEND/LQ_CLIENTE/LQ_LOJA/LQ_PDV/LQ_OPERADO/LQ_ESTACAO/LQ_NUMMOV' .AND. AllTrim((cAliasSX3)->&("X3_CAMPO"))<>'LQ_NUM'

				aadd(aCabec, {(cAliasSX3)->&("X3_CAMPO"), SL1->( FieldGet(nPos) ), NIL})

			EndIf

			(cAliasSX3)->( DbSkip() )

		EndDo

		aadd(aCabec, {"LQ_VLRTOT"		, nValTot	  	, NIL} )
		aadd(aCabec, {"LQ_VLRLIQ"		, nValTot		, NIL} )
		aadd(aCabec, {"LQ_DINHEIR" 		, nValTot 	 	, NIL} )
		aadd(aCabec, {"LQ_CHEQUES" 		, 0 	 		, NIL} )
		aadd(aCabec, {"LQ_CARTAO" 		, 0				, NIL} )
		aadd(aCabec, {"LQ_VLRDEBI" 		, 0				, NIL} )
		aadd(aCabec, {"LQ_CONVENI" 		, 0 			, NIL} )
		aadd(aCabec, {"LQ_VALES" 		, 0 			, NIL} )
		aadd(aCabec, {"LQ_OUTROS" 		, 0   			, NIL} )

		//preenche
		//<<ATENCAO>> nao alterar a ordem desse array
		aParcela	:= {}
		aadd(aParcela, {"L4_FORMA"  	, "R$"					 	, NIL} )
		aadd(aParcela, {"L4_DATA"  		, dDataBase  				, NIL} )
		aadd(aParcela, {"L4_VALOR"  	, nValTot					, NIL} )
		aadd(aParcela, {"L4_ADMINIS" 	, "                    " 	, NIL} )
		aadd(aParcela, {"L4_FORMAID"	, " "              			, NIL} )
		aadd(aParcela, {"L4_MOEDA"  	, SuperGetMV("MV_MOEDA1",,0), NIL} )
		aadd(aParcelas,aParcela)

	EndIf

	If Len(aItens)>0 .and. nValTot>0 .and. Len(aCabec)>0 .and. Len(aParcelas)>0

		// inicio o controle de transação para inclusão do orçamento
		BeginTran()

		Private lMsHelpAuto := .T. // Variavel de controle interno do ExecAuto
		Private lMsErroAuto := .F. // Variavel que informa a ocorrência de erros no ExecAuto
		Private INCLUI 		:= .T. // Variavel necessária para o ExecAuto identificar que se trata de uma inclusão
		Private ALTERA 		:= .F. // Variavel necessária para o ExecAuto identificar que se trata de uma inclusão

		SetFunName("LOJA701")
		nModulo := 12

		//LjMsgRun("Aguarde... Gerando Orçamento...",,{|| MSExecAuto({|a,b,c,d,e,f,g,h| Loja701(a,b,c,d,e,f,g,h)},.F.,3,"","",{},aCabec,aItens,aParcelas)})
		MSExecAuto({|a,b,c,d,e,f,g,h| Loja701(a,b,c,d,e,f,g,h)},.F.,3,"","",{},aCabec,aItens,aParcelas)

		// essas variáveis devem ser apagadas, senão irá influenciar no fonte padrão de finalização da venda
		lMsHelpAuto := NIL
		INCLUI := NIL
		ALTERA := NIL

		If lMsErroAuto
			// mostra a tela de erros do Execauto
			cMsgErr += MostraErro("\temp") //MostraErro()
			// cancelo a transação de inclusão do orçamento
			DisarmTransaction()
			// libera sequencial
			RollBackSx8()

			cTexto += CRLF
			cTexto += "FALHA AO COMPIAR ORCAMENTO!" + CRLF
			cTexto += "Erro: " + cMsgErr + CRLF
			cTexto += CRLF
			cTexto += CRLF
		Else

			// confirmo a numeração
			ConfirmSX8()
			// numero do orçamento
			// posiciono no orçamento criado, devido a problema na rotina na base DBF
			#IFDEF TOP
				nRecSL1FinVd := 0
			#ELSE
				If Type("nRecSL1FinVd") <> "U"
					SL1->(DbGoTo(nRecSL1FinVd))
				EndIf
			#ENDIF
			cNumCpy := SL1->L1_NUM

			cTexto += CRLF
			cTexto += "ORCAMENTO COPIADO COM SUCERSSO!" + CRLF
			cTexto += "Novo Orçamento: " + cNumCpy + CRLF
			cTexto += CRLF
			cTexto += CRLF

			If !Empty(cNumCpy)

				//-- grava os dados da venda para integrar com retaguarda
				SL2->( DbSetOrder(1) ) // L2_FILIAL + L2_NUM + L2_ITEM + L2_PRODUTO
				SL2->( DbGoTop() )
				SL2->( DbSeek( xFilial("SL2") + cNumCpy ) )
				while !SL2->( Eof() ) .AND. SL2->L2_FILIAL == xFilial("SL2") .AND. SL2->L2_NUM == cNumCpy
					//aItensXML -> [01-Produto][02-Quantidade][03-VlrUnitario][04-VlrTotal][05-VlrDesc][06-VlrAcres][07-cBico][08-cBomba][09-cTanque][10-nEncIni][11-nEncFin]
					nPos := aScan( aItensXML, { |x| AllTrim(x[1]) == AllTrim(SL2->L2_PRODUTO) .and. x[2] == SL2->L2_QUANT } )
					if nPos > 0 .and. SL2->(L2_VLRITEM) <> (aItensXML[nPos][04] + aItensXML[nPos][06] - aItensXML[nPos][05])

						cTexto += CRLF
						cTexto += "ORCAMENTO: " + cNumCpy + CRLF
						cTexto += "ERRO NO TOTAL DO ITEM: " + CRLF
						cTexto += "ITEM: " + SL2->L2_ITEM + CRLF
						cTexto += CRLF
						cTexto += "TOTAL ITEM (SL2): " + cValToChar(SL2->(L2_VLRITEM)) + CRLF
						cTexto += "VLR ITEM (SL2): " + cValToChar(SL2->L2_VLRITEM + SL2->L2_VALDESC) + CRLF
						cTexto += "DESCONTO (SL2): " + cValToChar(SL2->L2_VALDESC) + CRLF
						cTexto += CRLF
						cTexto += "TOTAL ITEM (XML): " + cValToChar(aItensXML[nPos][04]-aItensXML[nPos][05]) + CRLF
						cTexto += "VLR ITEM (XML): " + cValToChar(aItensXML[nPos][04]) + CRLF
						cTexto += "ACRESCIMO (XML): " + cValToChar(aItensXML[nPos][06]) + CRLF
						cTexto += "DESCONTO (XML): " + cValToChar(aItensXML[nPos][05]) + CRLF
						cTexto += CRLF
						cTexto += CRLF

						cNumCpy := ""
						Exit //sai do While

					elseif nPos <= 0

						cTexto += CRLF
						cTexto += "ORCAMENTO: " + cNumCpy + CRLF
						cTexto += "ERRO NAO ENCONTRADO O ITEM NO XML: " + CRLF
						cTexto += "ITEM: " + SL2->L2_ITEM + CRLF
						cTexto += CRLF
						cTexto += "TOTAL ITEM (SL2): " + cValToChar(SL2->(L2_VLRITEM)) + CRLF
						cTexto += "VLR ITEM (SL2): " + cValToChar(SL2->L2_VLRITEM + SL2->L2_VALDESC) + CRLF
						cTexto += "DESCONTO (SL2): " + cValToChar(SL2->L2_VALDESC) + CRLF
						cTexto += CRLF
						cTexto += CRLF

						cNumCpy := ""
						Exit //sai do While

					endif

					SL2->( DbSkip() )
				enddo

			EndIf

			If !Empty(cNumCpy)

				//-- grava os dados da venda para integrar com retaguarda
				SL2->( DbSetOrder(1) ) // L2_FILIAL + L2_NUM + L2_ITEM + L2_PRODUTO
				SL2->( DbGoTop() )
				SL2->( DbSeek( xFilial("SL2") + SL1->L1_NUM ) )
				while !SL2->( Eof() ) .AND. SL2->L2_FILIAL == xFilial("SL2") .AND. SL2->L2_NUM == SL1->L1_NUM
					RecLock("SL2",.F.)
					SL2->L2_DOC := cDocumento
					SL2->L2_SERIE := cSerie
					SL2->L2_PDV := cL1_PDV
					SL2->L2_VENDIDO := 'S'

					//-- No XML, geralmente não é possivel identifiar o desconto, em alguns casos necessário ajuste do preço de tabela de desconto
					//-- Esse ajuste pretente evitar o seguinte erro no fechamento de caixa: "Inconsistência no valor do item do cupom."
					nVLRITEM := (NoRound((SL2->L2_QUANT*SL2->L2_PRCTAB),2) - SL2->L2_DESCPRO - SL2->L2_VALDESC)
					If nVLRITEM <> SL2->L2_VLRITEM
						If nVLRITEM < SL2->L2_VLRITEM

							nCount := 0
							nVALDESC := SL2->L2_VALDESC
							nPRCTAB  := SL2->L2_PRCTAB
							While nVLRITEM < SL2->L2_VLRITEM .and. nCount <= 10
								nPRCTAB  := SL2->L2_PRCTAB + 0.001
								nVALDESC := SL2->L2_VLRITEM + SL2->L2_DESCPRO - NoRound((SL2->L2_QUANT*nPRCTAB),2)
								nVLRITEM := (NoRound((SL2->L2_QUANT*nPRCTAB),2) - SL2->L2_DESCPRO - nVALDESC)
								nCount ++
							EndDo

							If nVLRITEM == SL2->L2_VLRITEM
								SL2->L2_VALDESC := nVALDESC
								SL2->L2_PRCTAB  := nPRCTAB
							EndIf

						Else

							nCount := 0
							nVALDESC := SL2->L2_VALDESC
							nPRCTAB  := SL2->L2_PRCTAB
							While nVLRITEM > SL2->L2_VLRITEM .and. nCount <= 10
								nPRCTAB  := SL2->L2_PRCTAB - 0.001
								nVALDESC := SL2->L2_VLRITEM + SL2->L2_DESCPRO - NoRound((SL2->L2_QUANT*nPRCTAB),2)
								nVLRITEM := (NoRound((SL2->L2_QUANT*nPRCTAB),2) - SL2->L2_DESCPRO - nVALDESC)
								nCount ++
							EndDo

							If nVLRITEM == SL2->L2_VLRITEM
								SL2->L2_VALDESC := nVALDESC
								SL2->L2_PRCTAB  := nPRCTAB
							EndIf

						EndIf
					EndIf

					SL2->( MsUnlock() )
					SL2->( DbSkip() )
				enddo

				nHoras := SubtHoras( dEmisNf, cHora, Date(), SubStr(Time(),1,2)+":"+SubStr(Time(),4,2) )
				cEspecie := LjRetEspec(cSerie)

				If "SPED" $ cEspecie
					nNfceExc := nSpedExc
				ElseIf "NFCE" $ cEspecie
					//Tratamento para manter o legado do parametro MV_SPEDEXC
					If nNfceExc <= 0
						nNfceExc := nSpedExc
					EndIf
				EndIf

				RecLock("SL1",.F.)
				SL1->L1_PDV := cL1_PDV
				SL1->L1_OPERADO := cL1_OPERADO
				SL1->L1_ESTACAO := cL1_ESTACAO
				SL1->L1_NUMMOV := cL1_NUMMOV
				SL1->L1_STATUS := 'XPROTH' //'XCOPIA' //-- log para identifiar que a venda foi recuperada
				SL1->L1_DOC := cDocumento
				SL1->L1_NUMCFIS := cDocumento
				If SL1->(FieldPos("L1_SDOC")) > 0
					SL1->L1_SDOC := cSerie
				EndIf
				SL1->L1_SERIE := cSerie
				SL1->L1_EMISNF := dEmisNf
				SL1->L1_HORA := cHora
				SL1->L1_KEYNFCE := cKeyNfce
				SL1->L1_RETSFZ := cRetSfz
				If luSitua
					If lIsCPDV
						SL1->L1_SITUA := 'CP' //"CP" - Recebido pela Central de PDV
					Else
						SL1->L1_SITUA := '00' //"00" - Venda Efetuada com Sucesso
					EndIf
				Else
					SL1->L1_SITUA := 'XX'
				EndIf
				SL1->L1_TIPO := 'V'

				//se for NF-e
				If !Empty(SL1->L1_KEYNFCE) .and. SubStr(L1_KEYNFCE,21,2) == '55'
					SL1->L1_IMPNF := .T. //identifica que é NF-e
					SL1->L1_IMPRIME = '1S'
					SL1->L1_STBATCH = '1'
				Else
					SL1->L1_IMPRIME := '5S'
				EndIf

				SL1->L1_TPFRET := 'S'
				SL1->L1_TPORC := 'E'
				//If SuperGetMV("MV_XMSTORC",,.T.) .and. nHoras < nNfceExc
				//	SL1->L1_STORC := 'A' //-- cancela a nota automaticamente após 'explodir' via gravabatch
				//EndIf

				SL1->( MsUnlock() )

			EndIf

		EndIf

		// finalizo o controle de transação para inclusão do orçamento
		EndTran()

		// essas variáveis devem ser apagadas, senão irá influenciar no fonte padrão de finalização da venda
		lMsErroAuto := NIL

	EndIf

	dDataBase := dDtBkp

	RestArea(aAreaSL1)
	RestArea(aAreaSL2)
	RestArea(aAreaSX3)
	RestArea(aArea)

Return cNumCpy

//-------------------------------------------------------------------
/*/{Protheus.doc} ImportaXML
Importa a venda via XML enviado
@author  author
@since   date
@version version
/*/
//-------------------------------------------------------------------
Static Function ImportaXML(cTexto, cDocumento, cSerie, dEmisNf, cHora, cKeyNfce, cCodCli, cLojCli, aItensXML, aNumPDV, cRetSfz, cInfCpl)

	Local aCabec 		:= {}
	Local aItens 		:= {}
	Local aItem  		:= {}
	Local nVlrUnit		:= 0
	Local nCountVl		:= 0
	Local aParcelas 	:= {}
	Local aParcela 		:= {}
	Local nValTot		:= 0
	Local cNumImp		:= ""
	Local nX := 0, nZ := 0
	Local cTesSai  		:= SuperGetMV("MV_TESSAI",,"501") // Pega do parametro o TES padrao para saida
	Local cTesPad       := ""
	Local cMsgErr		:= ""
	Local nPos := 0
	Local aDadosPDV := {"0001","C01","001","01"} //PDV, Operador, Estação, Num.Movimento

	Local aArea			:= GetArea()
	Local aAreaSL1		:= SL1->(GetArea())
	Local aAreaSL2		:= SL2->(GetArea())
	Local dDtBkp		:= dDataBase

	Local nSpedExc 		:= SuperGetMV("MV_SPEDEXC",,72)			// Indica a quantidade de horas q a NFe pode ser cancelada
	Local nNfceExc      := SuperGetMV("MV_NFCEEXC",, 0)         // Indica a quantidade de horas q a NFCe pode ser cancelada
	Local nHoras		:= 0                            		// Quantidade de horas da hora atual
	Local cEspecie		:= ""
	Local cLocAbast     := AllTrim(SuperGetMV("MV_XLOCREC",,""))  //Armazem padrão para recuperação de vendas do PDV
	Local luSitua		:= SuperGetMV("MV_XUSITUA",,.T.) //Integra a venda: atualiza o L1_SITUA para integrar

	Local cTabLEG := AllTrim( GetNewPar("MV_LJDCLEG","LEG") )
	Local cLEGPfx := iif( Left(cTabLEG,1)=="S", SubStr(cTabLEG,2,2), cTabLEG)
	Local aAbast := {}

	Private lAutomatoX := .T. //variavel para evitar mostrar aviso de certificado proximo do vencimento

	If Type("nRecSL1FinVd") == "U"
		Private nRecSL1FinVd := 0   //recno do registro da SL1 apontado pelo PE LJ7002, apos inclusao de orcamento
	EndIf

	cL1_PDV := ""
	cL1_OPERADO := ""
	cL1_ESTACAO := ""
	cL1_NUMMOV := ""

	nValTot := 0
	dDataBase := dEmisNf

	cTexto += CRLF
	cTexto += "IMPORTANDO XML DO ORCAMENTO..." + CRLF

	cTexto += "aItensXML: "+CRLF
	cTexto += U_XtoStrin(aItensXML) + CRLF
	cTexto += CRLF

	//-- dadas dos itens
	For nX := 1 To Len(aItensXML) //[01-Produto][02-Quantidade][03-VlrUnitario][04-VlrTotal][05-VlrDesc][06-VlrAcres][07-cBico][08-cBomba][09-cTanque][10-nEncIni][11-nEncFin]

		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Parametro da funcao MaTesInt               ³
		//³ExpN1 = Documento de 1-Entrada / 2-Saida   ³
		//³ExpC1 = Tipo de Operacao Tabela "DF" do SX5³
		//³ExpC2 = Codigo do Cliente ou Fornecedor    ³
		//³ExpC3 = Codigo do gracao E-Entrada         ³
		//³ExpC4 = Tipo de Operacao E-Entrada         ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		cTesPad := MaTesInt(2, "01", cCodCli, cLojCli, "C", aItensXML[nX][01], NIL)
		If Empty(cTesPad)
			cTesPad := cTesSai
		EndIf

		//aItensXML -> [01-Produto][02-Quantidade][03-VlrUnitario][04-VlrTotal][05-VlrDesc][06-VlrAcres][07-cBico][08-cBomba][09-cTanque][10-nEncIni][11-nEncFin]
		aItem := {}

		//-- ajuste do valor unitário do item
		nCountVl := 0
		nVlrUnit := Round(((aItensXML[nX][04]+aItensXML[nX][06])/aItensXML[nX][02]),TamSx3("L2_VRUNIT")[1])
		if NoRound((aItensXML[nX][02]*nVlrUnit),TamSx3("L2_VRUNIT")[1]) <> NoRound((aItensXML[nX][04]+aItensXML[nX][06]),TamSx3("L2_VRUNIT")[1])
			if NoRound((aItensXML[nX][02]*nVlrUnit),TamSx3("L2_VRUNIT")[1]) > NoRound((aItensXML[nX][04]+aItensXML[nX][06]),TamSx3("L2_VRUNIT")[1])
				while NoRound((aItensXML[nX][02]*nVlrUnit),TamSx3("L2_VRUNIT")[1]) > NoRound((aItensXML[nX][04]+aItensXML[nX][06]),TamSx3("L2_VRUNIT")[1]) .and. nCountVl < 10
					nVlrUnit := nVlrUnit - 0.001
					nCountVl++
				enddo
			elseif NoRound((aItensXML[nX][02]*nVlrUnit),TamSx3("L2_VRUNIT")[1]) < NoRound((aItensXML[nX][04]+aItensXML[nX][06]),TamSx3("L2_VRUNIT")[1]) .and. nCountVl < 10
				while NoRound((aItensXML[nX][02]*nVlrUnit),TamSx3("L2_VRUNIT")[1]) < NoRound((aItensXML[nX][04]+aItensXML[nX][06]),TamSx3("L2_VRUNIT")[1])
					nVlrUnit := nVlrUnit + 0.001
					nCountVl++
				enddo
			endif
		endif

		if NoRound((aItensXML[nX][02]*nVlrUnit),TamSx3("L2_VLRITEM")[1]) <> NoRound((aItensXML[nX][04]+aItensXML[nX][06]),TamSx3("L2_VLRITEM")[1])
			nVlrUnit := ((aItensXML[nX][04]+aItensXML[nX][06])/aItensXML[nX][02])
		endif

		aadd(aItem, { "LR_PRODUTO", aItensXML[nX][01], NIL})
		aadd(aItem, { "LR_QUANT", aItensXML[nX][02], NIL})
		aadd(aItem, { "LR_PRCTAB", NoRound(((aItensXML[nX][04]+aItensXML[nX][06])/aItensXML[nX][02]),TamSx3("L2_PRCTAB")[1]), NIL})
		if aItensXML[nX][05] > 0
			aadd(aItem, { "LR_VALDESC", aItensXML[nX][05], NIL})
		else
			aadd(aItem, { "LR_VRUNIT", nVlrUnit, NIL})
			aadd(aItem, { "LR_VLRITEM", (aItensXML[nX][04]+aItensXML[nX][06]-aItensXML[nX][05]), NIL})
		endif
		//aadd(aItem, { "LR_TES", cTesPad, NIL})

		//aItensXML -> [01-Produto][02-Quantidade][03-VlrUnitario][04-VlrTotal][05-VlrDesc][06-VlrAcres][07-cBico][08-cBomba][09-cTanque][10-nEncIni][11-nEncFin]
		cCodAbast := ""
		nPosPDV := At("Item: "+StrZero(nX,TamSx3("L2_ITEM")[1],0),cInfCpl)
		//Item: 01 / Num.Abast: 000264522
		If nPosPDV > 0
			nPosPDV += 22
			cCodAbast := SubStr(cInfCpl,nPosPDV,TamSx3("L2_MIDCOD")[1])
		EndIf

		if !Empty(cCodAbast)

			(cTabLEG)->(DbSetOrder(1)) //LEG_FILIAL+LEG_CODIGO
			if (cTabLEG)->(DbSeek(xFilial(cTabLEG) + cCodAbast))
				cLocAbast := iif(Empty(cLocAbast) .and. !Empty((cTabLEG)->&(cLEGPfx+"_TANQUE")), (cTabLEG)->&(cLEGPfx+"_TANQUE"), cLocAbast)
			endif

			aadd(aItem, { "LR_MIDCOD", cCodAbast, NIL})

			//if SLR->(FieldPos("LR_BICO")) > 0 .and. !Empty(aItensXML[nX][07])
			//	aadd(aItem, { "LR_BICO", aItensXML[nX][07], NIL})
			//endif

		elseif Len(aItensXML[nX])>6 .and. !Empty(aItensXML[nX][07])

			aAbast := RetAbaste(dEmisNf, aItensXML[nX][01], aItensXML[nX][02], aItensXML[nX][07], aItensXML[nX][08], aItensXML[nX][09], aItensXML[nX][10], aItensXML[nX][11])

			cTexto += "aAbast: " + CRLF
			cTexto += U_XtoStrin(aAbast) + CRLF
			cTexto += CRLF

			cCodAbast := aAbast[01]
			cLocAbast := iif(Empty(cLocAbast) .and. !Empty(aAbast[02]), aAbast[02], cLocAbast)

			if !Empty(cCodAbast)
				aadd(aItem, { "LR_MIDCOD", cCodAbast, NIL})
			endif

			//if SLR->(FieldPos("LR_BICO")) > 0 .and. !Empty(aItensXML[nX][07])
			//	aadd(aItem, { "LR_BICO", aItensXML[nX][07], NIL})
			//endif

		endif

		if Empty(cLocAbast)
			cLocAbast := RetLocal(aItensXML[nX][01])
		endif

		if !Empty(cLocAbast)
			aadd(aItem, { "LR_LOCAL", cLocAbast, NIL} )
		endif

		aadd(aItens, aItem)

		nValTot += (aItensXML[nX][04] + aItensXML[nX][06] - aItensXML[nX][05])

	Next nX

	cTexto += "aItens: " + CRLF
	cTexto += U_XtoStrin(aItens) + CRLF
	cTexto += CRLF

	//-- dados do cabeçalho e forma de pagamento do orçamento de produtos que não são abastecimentos
	If Len(aItens)>0 .and. nValTot>0

		//preenche o cabeçalho do orçamento
		aadd(aCabec, {"LQ_CLIENTE"		, cCodCli		, NIL} )
		aadd(aCabec, {"LQ_LOJA"			, cLojCli		, NIL} )
		aadd(aCabec, {"LQ_VLRTOT"		, nValTot	  	, NIL} )
		aadd(aCabec, {"LQ_VLRLIQ"		, nValTot		, NIL} )
		aadd(aCabec, {"LQ_DINHEIR" 		, nValTot 	 	, NIL} )
		aadd(aCabec, {"LQ_CHEQUES" 		, 0 	 		, NIL} )
		aadd(aCabec, {"LQ_CARTAO" 		, 0				, NIL} )
		aadd(aCabec, {"LQ_VLRDEBI" 		, 0				, NIL} )
		aadd(aCabec, {"LQ_CONVENI" 		, 0 			, NIL} )
		aadd(aCabec, {"LQ_VALES" 		, 0 			, NIL} )
		aadd(aCabec, {"LQ_OUTROS" 		, 0   			, NIL} )

		//preenche
		//<<ATENCAO>> nao alterar a ordem desse array
		aParcela	:= {}
		aadd(aParcela, {"L4_FORMA"  	, "R$"					 	, NIL} )
		aadd(aParcela, {"L4_DATA"  		, dDataBase  				, NIL} )
		aadd(aParcela, {"L4_VALOR"  	, nValTot					, NIL} )
		aadd(aParcela, {"L4_ADMINIS" 	, "                    " 	, NIL} )
		aadd(aParcela, {"L4_FORMAID"	, " "              			, NIL} )
		aadd(aParcela, {"L4_MOEDA"  	, SuperGetMV("MV_MOEDA1",,0), NIL} )
		aadd(aParcelas,aParcela)

	EndIf

	If Len(aItens)>0 .and. nValTot>0 .and. Len(aCabec)>0 .and. Len(aParcelas)>0

		// inicio o controle de transação para inclusão do orçamento
		BeginTran()

		Private lMsHelpAuto := .T. // Variavel de controle interno do ExecAuto
		Private lMsErroAuto := .F. // Variavel que informa a ocorrência de erros no ExecAuto
		Private INCLUI 		:= .T. // Variavel necessária para o ExecAuto identificar que se trata de uma inclusão
		Private ALTERA 		:= .F. // Variavel necessária para o ExecAuto identificar que se trata de uma inclusão

		SetFunName("LOJA701")
		nModulo := 12

		//LjMsgRun("Aguarde... Gerando Orçamento...",,{|| MSExecAuto({|a,b,c,d,e,f,g,h| Loja701(a,b,c,d,e,f,g,h)},.F.,3,"","",{},aCabec,aItens,aParcelas)})
		MSExecAuto({|a,b,c,d,e,f,g,h| Loja701(a,b,c,d,e,f,g,h)},.F.,3,"","",{},aCabec,aItens,aParcelas)

		// essas variáveis devem ser apagadas, senão irá influenciar no fonte padrão de finalização da venda
		lMsHelpAuto := NIL
		INCLUI := NIL
		ALTERA := NIL

		If lMsErroAuto
			// mostra a tela de erros do Execauto
			cMsgErr += MostraErro("\temp") //MostraErro()
			// cancelo a transação de inclusão do orçamento
			DisarmTransaction()
			// libera sequencial
			RollBackSx8()

			cTexto += CRLF
			cTexto += "FALHA AO IMPORTAR XML DO ORCAMENTO!" + CRLF
			cTexto += "Erro: " + cMsgErr + CRLF
			cTexto += CRLF
			cTexto += CRLF
		Else

			// confirmo a numeração
			ConfirmSX8()
			// numero do orçamento
			// posiciono no orçamento criado, devido a problema na rotina na base DBF
			#IFDEF TOP
				nRecSL1FinVd := 0
			#ELSE
				If Type("nRecSL1FinVd") <> "U"
					SL1->(DbGoTo(nRecSL1FinVd))
				EndIf
			#ENDIF
			cNumImp := SL1->L1_NUM

			cTexto += CRLF
			cTexto += "ORCAMENTO IMPORTARDO COM SUCERSSO!" + CRLF
			cTexto += "Novo Orçamento: " + cNumImp + CRLF
			cTexto += CRLF
			cTexto += CRLF

			//força a gravação do código de abastecimento: LEG_CODIGO
			SL2->(DbSetOrder(1)) //L2_FILIAL+L2_NUM+L2_ITEM+L2_PRODUTO
			For nZ:=1 to len(aItens)
				nPosProd := Ascan(aItens[nZ],{|x| Alltrim(Upper(x[1]))="LR_PRODUTO"})
				If nPosProd > 0 .and. SL2->( DbSeek( xFilial("SL2") + cNumImp + StrZero(nZ,TamSx3("L2_ITEM")[1],0) + aItens[nZ][nPosProd][2] ) )
					nPosLEG := Ascan(aItens[nZ],{|x| Alltrim(Upper(x[1]))="LR_MIDCOD"})
					If nPosLEG > 0 .and. !Empty(aItens[nZ][nPosLEG][2])
						RecLock("SL2",.F.)
						SL2->L2_MIDCOD := aItens[nZ][nPosLEG][2]
						SL2->( MsUnlock() )
					EndIf
				EndIf
			Next

			If !Empty(cNumImp)

				//-- grava os dados da venda para integrar com retaguarda
				SL2->( DbSetOrder(1) ) // L2_FILIAL + L2_NUM + L2_ITEM + L2_PRODUTO
				SL2->( DbGoTop() )
				SL2->( DbSeek( xFilial("SL2") + cNumImp ) )
				while !SL2->( Eof() ) .AND. SL2->L2_FILIAL == xFilial("SL2") .AND. SL2->L2_NUM == cNumImp
					//aItensXML -> [01-Produto][02-Quantidade][03-VlrUnitario][04-VlrTotal][05-VlrDesc][06-VlrAcres][07-cBico][08-cBomba][09-cTanque][10-nEncIni][11-nEncFin]
					nPos := aScan( aItensXML, { |x| AllTrim(x[1]) == AllTrim(SL2->L2_PRODUTO) .and. x[2] == SL2->L2_QUANT } )
					if nPos > 0 .and. SL2->(L2_VLRITEM) <> (aItensXML[nPos][04] + aItensXML[nPos][06] - aItensXML[nPos][05])

						cTexto += CRLF
						cTexto += "ORCAMENTO: " + cNumImp + CRLF
						cTexto += "ERRO NO TOTAL DO ITEM: " + CRLF
						cTexto += "ITEM: " + SL2->L2_ITEM + CRLF
						cTexto += CRLF
						cTexto += "TOTAL ITEM (SL2): " + cValToChar(SL2->(L2_VLRITEM)) + CRLF
						cTexto += "VLR ITEM (SL2): " + cValToChar(SL2->L2_VLRITEM + SL2->L2_VALDESC) + CRLF
						cTexto += "DESCONTO (SL2): " + cValToChar(SL2->L2_VALDESC) + CRLF
						cTexto += CRLF
						cTexto += "TOTAL ITEM (XML): " + cValToChar(aItensXML[nPos][04]-aItensXML[nPos][05]) + CRLF
						cTexto += "VLR ITEM (XML): " + cValToChar(aItensXML[nPos][04]) + CRLF
						cTexto += "ACRESCIMO (XML): " + cValToChar(aItensXML[nPos][06]) + CRLF
						cTexto += "DESCONTO (XML): " + cValToChar(aItensXML[nPos][05]) + CRLF
						cTexto += CRLF
						cTexto += CRLF

						cNumImp := ""
						Exit //sai do While

					elseif nPos <= 0

						cTexto += CRLF
						cTexto += "ORCAMENTO: " + cNumImp + CRLF
						cTexto += "ERRO NAO ENCONTRADO O ITEM NO XML: " + CRLF
						cTexto += "ITEM: " + SL2->L2_ITEM + CRLF
						cTexto += CRLF
						cTexto += "TOTAL ITEM (SL2): " + cValToChar(SL2->(L2_VLRITEM)) + CRLF
						cTexto += "VLR ITEM (SL2): " + cValToChar(SL2->L2_VLRITEM + SL2->L2_VALDESC) + CRLF
						cTexto += "DESCONTO (SL2): " + cValToChar(SL2->L2_VALDESC) + CRLF
						cTexto += CRLF
						cTexto += CRLF

						cNumImp := ""
						Exit //sai do While

					endif

					SL2->( DbSkip() )
				enddo

			EndIf

			If !Empty(cNumImp)

				//-- grava os dados da venda para integrar com retaguarda
				SL2->( DbSetOrder(1) ) // L2_FILIAL + L2_NUM + L2_ITEM + L2_PRODUTO
				SL2->( DbGoTop() )
				SL2->( DbSeek( xFilial("SL2") + SL1->L1_NUM ) )
				while !SL2->( Eof() ) .AND. SL2->L2_FILIAL == xFilial("SL2") .AND. SL2->L2_NUM == SL1->L1_NUM

					RecLock("SL2",.F.)
					SL2->L2_DOC := cDocumento
					SL2->L2_SERIE := cSerie
					SL2->L2_PDV := "0001" //cL1_PDV
					SL2->L2_VENDIDO := 'S'

					//-- No XML, geralmente não é possivel identifiar o desconto, em alguns casos necessário ajuste do preço de tabela de desconto
					//-- Esse ajuste pretente evitar o seguinte erro no fechamento de caixa: "Inconsistência no valor do item do cupom."
					nVLRITEM := (NoRound((SL2->L2_QUANT*SL2->L2_PRCTAB),2) - SL2->L2_DESCPRO - SL2->L2_VALDESC)
					If nVLRITEM <> SL2->L2_VLRITEM
						If nVLRITEM < SL2->L2_VLRITEM

							nCount := 0
							nVALDESC := SL2->L2_VALDESC
							nPRCTAB  := SL2->L2_PRCTAB
							While nVLRITEM < SL2->L2_VLRITEM .and. nCount <= 10
								nPRCTAB  := SL2->L2_PRCTAB + 0.001
								nVALDESC := SL2->L2_VLRITEM + SL2->L2_DESCPRO - NoRound((SL2->L2_QUANT*nPRCTAB),2)
								nVLRITEM := (NoRound((SL2->L2_QUANT*nPRCTAB),2) - SL2->L2_DESCPRO - nVALDESC)
								nCount ++
							EndDo

							If nVLRITEM == SL2->L2_VLRITEM
								SL2->L2_VALDESC := nVALDESC
								SL2->L2_PRCTAB  := nPRCTAB
							EndIf

						Else

							nCount := 0
							nVALDESC := SL2->L2_VALDESC
							nPRCTAB  := SL2->L2_PRCTAB
							While nVLRITEM > SL2->L2_VLRITEM .and. nCount <= 10
								nPRCTAB  := SL2->L2_PRCTAB - 0.001
								nVALDESC := SL2->L2_VLRITEM + SL2->L2_DESCPRO - NoRound((SL2->L2_QUANT*nPRCTAB),2)
								nVLRITEM := (NoRound((SL2->L2_QUANT*nPRCTAB),2) - SL2->L2_DESCPRO - nVALDESC)
								nCount ++
							EndDo

							If nVLRITEM == SL2->L2_VLRITEM
								SL2->L2_VALDESC := nVALDESC
								SL2->L2_PRCTAB  := nPRCTAB
							EndIf

						EndIf
					EndIf

					SL2->( MsUnlock() )

					SL2->( DbSkip() )
				enddo

				//-- retorna o dados do caixa
				If !Empty(aNumPDV[01]) .and. Empty(aNumPDV[02])
					aDadosPDV := RetDadosPDV(aNumPDV[01], dEmisNf, cHora) //[01] PDV, [02] Operador, [03] Estação, [04] Num.Movimento
				ElseIf Len(aNumPDV) == 4
					aDadosPDV := {aNumPDV[01], aNumPDV[02], aNumPDV[04], aNumPDV[03]}
				EndIf

				nHoras := SubtHoras( dEmisNf, cHora, Date(), SubStr(Time(),1,2)+":"+SubStr(Time(),4,2) )
				cEspecie := LjRetEspec(cSerie)

				If "SPED" $ cEspecie
					nNfceExc := nSpedExc
				ElseIf "NFCE" $ cEspecie
					//Tratamento para manter o legado do parametro MV_SPEDEXC
					If nNfceExc <= 0
						nNfceExc := nSpedExc
					EndIf
				EndIf

				RecLock("SL1",.F.)
				SL1->L1_PDV := aDadosPDV[01] //cL1_PDV
				SL1->L1_OPERADO := aDadosPDV[02] //cL1_OPERADO
				SL1->L1_ESTACAO := aDadosPDV[03] //cL1_ESTACAO
				SL1->L1_NUMMOV := aDadosPDV[04] //cL1_NUMMOV
				SL1->L1_STATUS := 'XSEFAZ' //'XXML' //-- log para identifiar que a venda foi recuperada
				SL1->L1_DOC := cDocumento
				SL1->L1_NUMCFIS := cDocumento
				If SL1->(FieldPos("L1_SDOC")) > 0
					SL1->L1_SDOC := cSerie
				EndIf
				SL1->L1_SERIE := cSerie
				SL1->L1_EMISNF := dEmisNf
				SL1->L1_HORA := cHora
				SL1->L1_KEYNFCE := cKeyNfce
				SL1->L1_RETSFZ := cRetSfz
				If luSitua
					If lIsCPDV
						SL1->L1_SITUA := 'CP' //"CP" - Recebido pela Central de PDV
					Else
						SL1->L1_SITUA := '00' //"00" - Venda Efetuada com Sucesso
					EndIf
				Else
					SL1->L1_SITUA := 'XX'
				EndIf
				SL1->L1_TIPO := 'V'

				//se for NF-e
				If !Empty(SL1->L1_KEYNFCE) .and. SubStr(L1_KEYNFCE,21,2) == '55'
					SL1->L1_IMPNF := .T. //identifica que é NF-e
					SL1->L1_IMPRIME = '1S'
					SL1->L1_STBATCH = '1'
				Else
					SL1->L1_IMPRIME := '5S'
				EndIf

				SL1->L1_TPFRET := 'S'
				SL1->L1_TPORC := 'E'
				//If SuperGetMV("MV_XMSTORC",,.T.) .and. nHoras < nNfceExc
				//	SL1->L1_STORC := 'A' //-- cancela a nota automaticamente após 'explodir' via gravabatch
				//EndIf

				SL1->( MsUnlock() )

			EndIf

		EndIf

		// finalizo o controle de transação para inclusão do orçamento
		EndTran()

		// essas variáveis devem ser apagadas, senão irá influenciar no fonte padrão de finalização da venda
		lMsErroAuto := NIL

	EndIf

	dDataBase := dDtBkp

	RestArea(aAreaSL1)
	RestArea(aAreaSL2)
	RestArea(aArea)

Return cNumImp

//-------------------------------------------------------------------
/*/{Protheus.doc} RetDadosPDV
Retorna dados do PDV
@author  author
@since   date
@version version
/*/
//-------------------------------------------------------------------
Static Function RetDadosPDV(cNumPDV, dEmisNf, cHora)

	Local aRet := {"0001","C01","001","01"} //PDV, Operador, Estação, Num.Movimento
	Local aArea := GetArea()
	Local aAreaSLW := SLW->(GetArea())

	SLW->(DbSetOrder(2)) //LW_FILIAL+LW_PDV+DTOS(LW_DTABERT)
	If SLW->(DbSeek(xFilial("SLW")+PADR(AllTrim(cNumPDV),TamSx3("LW_PDV")[1])+SubStr(DtoS(dEmisNf),1,6)))
		While SLW->(!Eof()) .and. SLW->LW_FILIAL == xFilial("SLW") .and. SLW->LW_PDV == PADR(AllTrim(cNumPDV),TamSx3("LW_PDV")[1]) .and. DtoS(dEmisNf) >= DTOS(SLW->LW_DTABERT)
			If (DtoS(SLW->LW_DTABERT)+SubStr(SLW->LW_HRABERT,1,5)) <= (DtoS(dEmisNf)+SubStr(cHora,1,5)) .and. (Empty(DtoS(SLW->LW_DTFECHA)) .or. ((DtoS(SLW->LW_DTFECHA)+SubStr(SLW->LW_HRFECHA,1,5)) >= (DtoS(dEmisNf)+SubStr(cHora,1,5))))
				aRet := {SLW->LW_PDV, SLW->LW_OPERADO, SLW->LW_ESTACAO, SLW->LW_NUMMOV}
				Exit// sai do While
			EndIf
			SLW->(DbSkip())
		EndDo
	EndIf

	RestArea(aAreaSLW)
	RestArea(aArea)
Return aRet

//-------------------------------------------------------------------
/*/{Protheus.doc} RetKeyNfe
Retorna a chave da nota na tabela SPED050 do TSS
@author  author
@since   date
@version version
/*/
//-------------------------------------------------------------------
Static Function RetKeyNfe(_cSer, _cDoc)

	Local cRet := ""
	Local cSQL := ""
	Local cIdEnt  := ""
	Local cEspecie := LjRetEspec(_cSer)

	//-- Determina ID
	If AllTrim(cEspecie) == "SPED"
		cIdEnt := URetEntTss("55",.F.) //RetIdEnti()
	ElseIf AllTrim(cEspecie) == "NFCE"
		cIdEnt := URetEntTss("65",.F.) //StaticCall(LOJNFCE,LjNFCeIDEnt)
	EndIf

	If !U_TSStcSetConn() //abre ou seta conexão para banco TSS
		Return cRet
	Else

		cSQL := "select S050.* " + CRLF
		cSQL += " from sped050 S050" + CRLF
		cSQL += " where S050.d_e_l_e_t_ = ' ' " + CRLF
		cSQL += " and S050.ambiente = 1 " + CRLF //-- 1-Produção / 2-Homologação
		cSQL += " and S050.id_ent = '" + cIdEnt + "' " + CRLF
		cSQL += " and S050.nfe_id = '" + _cSer + _cDoc + "' " + CRLF

		If Select("SPDX") > 0
			SPDX->( DbCloseArea() )
		EndIf

		//cSQL := ChangeQuery(cSQL)
		TcQuery cSQL New ALIAS "SPDX"

		If SPDX->(!Eof())
			cRet := SPDX->DOC_CHV
		EndIf

		SPDX->( DbCloseArea() )

	EndIf

	If lUsaQuery
		U_PROtcSetConn() //seta conexão para banco Protheus
	EndIf

Return cRet

//-------------------------------------------------------------------
/*/{Protheus.doc} LjRetEspec
Retorna a Especie a ser utilizada de acordo com a configuracao dos parametros MV_LOJANF e MV_ESPECIE.
@author  author
@since   date
@version version
/*/
//-------------------------------------------------------------------
Static Function LjRetEspec(_cSerie)

	Local cEspecie 	:= "NF" // Especie da NF
	Local cTiposDoc	:= "" 	// Tipos de documentos fiscais utilizados na emissao de notas fiscais
	Local nCount 	:= 0
	Local nPosSign	:= 0

	If cPaisLoc == "BRA"
		cTiposDoc := AllTrim( SuperGetMV( 'MV_ESPECIE' ) ) // Tipos de documentos fiscais utilizados na emissao de notas fiscais
		DbSelectArea("SX5")
		SX5->( DbSetOrder(1) )
		If cTiposDoc <> NIL
			cTiposDoc := StrTran( cTiposDoc, ";", CRLF)

			For nCount := 1 TO MLCount( cTiposDoc )
				cEspecie := ALLTRIM( StrTran( MemoLine( cTiposDoc,, nCount ), CHR(13), CHR(10) ) )
				nPosSign := Rat( "=", cEspecie)

				If nPosSign > 0 .AND. ALLTRIM( _cSerie ) == ALLTRIM( SUBSTR( cEspecie, 1, nPosSign - 1 ) )
					If SX5->( DbSeek( xFilial("SX5") + "42" + SUBSTR(cEspecie, nPosSign + 1) ) )
						cEspecie := SUBSTR( cEspecie, nPosSign + 1 )
					Else
						cEspecie := SPACE(5)
					Endif
					Exit
				Else
					cEspecie := SPACE(5)
				Endif
			Next nCount

		Endif
	Endif

Return cEspecie

//-------------------------------------------------------------------
/*/{Protheus.doc} OrderGrid
Função que faz a ordenação do grid de acordo com o objeto 
e coluna passados como parâmetro
@author  author
@since   date
@version version
/*/
//-------------------------------------------------------------------
Static Function OrderGrid(oObj,nColum)

	if __XVEZ == "0"
		__XVEZ := "1"
	else
		if __XVEZ == "1"
			__XVEZ := "2"
		endif
	endif

	if __XVEZ == "2"

		lOrderByDesc := !lOrderByDesc

		if lOrderByDesc //ordem decrescente

			ASORT(oObj:aCols,,,{|x, y| x[nColum] > y[nColum] })

		else //ordem crescente

			ASORT(oObj:aCols,,,{|x, y| x[nColum] < y[nColum] })

		endif

		__XVEZ := "0"

		// faço um refresh no grid
		oObj:oBrowse:Refresh()

	endif

Return()

//-------------------------------------------------------------------
/*/{Protheus.doc} ErrSPEDs
Grava o SITUA com ER quando a SPED050 não esta autorizada na SEFAZ
-- Evitando assim reprocessar o mesmo registro via JOB novamente
@author  author
@since   date
@version version
/*/
//-------------------------------------------------------------------
Static Function ErrSPEDs(nRecSPED050)

	Local cSqlUpd := "", nStatus := 0
	Local luSitSp := SuperGetMV("MV_XUSITSP",,.F.) //Atualiza o campo "situa" (customizado) das tabelas SPEDs (SPED054 e SPED050)

	U_TSStcSetConn() //abre ou seta conexão para banco TSS

	cSqlUpd := "UPDATE sped050 "
	cSqlUpd += " SET "
	If luSitSp
		cSqlUpd += 		" situa = 'ER', " //campo customizado para controle de processamento do STMONITOR
	EndIf
	cSqlUpd += 		" d_e_l_e_t_ = ' ' " //-- não deletado (caso registro deletado, recupera o mesmo)
	cSqlUpd += " WHERE r_e_c_n_o_ = '" + AllTrim( Str(nRecSPED050) ) + "' "
	nStatus := TcSQLExec(Upper(cSqlUpd))

	If (nStatus < 0)
		If !IsBlind()
			Alert("TCSQLError() " + TCSQLError())
		Else
			//conout("TCSQLError() " + TCSQLError())
		EndIf
	EndIf

	U_PROtcSetConn() //seta conexão para banco Protheus

Return


//-------------------------------------------------------------------
/*/{Protheus.doc} AjusSPEDs
Quando a nota estiver com status "100 - Autorizado o uso da NF-e" na Sefaz, faz o ajuste na SPED050 e SPED054
@author  author
@since   date
@version version
/*/
//-------------------------------------------------------------------
Static Function AjusSPEDs(aDados) //{[1]-entidade, [2]-nfe_ID, [3]-chave, [4]-protocolo, [5]-recno_sped050, [6]-dt, [7]-hr, [8]-digval, [9]-versao}

	Local cLote := "", nStatus := 0
	Local cSqlUpd := ""
	Local aArea := GetArea()
	Local cXML_PROT := ""
	Local lUpdSped054 := SuperGetMV("ES_AJUS054",,.T.) //-- Atualiza a tabela SPED054, quando ocorrer recuperação de venda ? (default .T.)
	Local lCentPDV := IIf( ExistFunc("LjGetCPDV"), LjGetCPDV()[1] , .F. ) // Eh Central de PDV
	Local cAliasSX6 := GetNextAlias() // apelido para o arquivo de trabalho
	Local lOpen   	:= .F. // valida se foi aberto a tabela
	Local luSitSp := SuperGetMV("MV_XUSITSP",,.F.) //Atualiza o campo "situa" (customizado) das tabelas SPEDs (SPED054 e SPED050)

	U_PROtcSetConn() //seta conexão para banco Protheus

	//-- garantir que o parametro ES_NWLTTSS exista (antigo ES_LOTETSS)

	// abre o dicionário SIX
	OpenSXs(NIL, NIL, NIL, NIL, cEmpAnt, cAliasSX6, "SX6", NIL, .F.)
	lOpen := Select(cAliasSX6) > 0

	// caso aberto, posiciona no topo
	If !(lOpen)
		Return .F.
	EndIf
	DbSelectArea(cAliasSX6)
	(cAliasSX6)->( DbSetOrder( 1 ) ) //X6_FIL+X6_VAR
	(cAliasSX6)->( DbGoTop() )

	If !(cAliasSX6)->( DbSeek( cFilAnt + "ES_NWLTTSS") )
		RecLock(cAliasSX6,.T.)
		(cAliasSX6)->&("X6_FIL") := cFilAnt
		(cAliasSX6)->&("X6_VAR") := "ES_NWLTTSS"
		(cAliasSX6)->&("X6_TIPO") := "C"
		(cAliasSX6)->&("X6_DESCRIC")	:= "Nro lote para notas recuperadas via monitor PDV"
		If lCentPDV
			(cAliasSX6)->&("X6_CONTEUD")	:= cFilAnt+StrZero(1,15-len(cFilAnt))
		Else
			(cAliasSX6)->&("X6_CONTEUD")	:= cFilAnt+SLG->LG_CODIGO+StrZero(1,15-(len(cFilAnt)+len(SLG->LG_CODIGO)))
		EndIf
		(cAliasSX6)->&("X6_PROPRI")	:= "U"
		(cAliasSX6)->( MsUnLock() )
	EndIf

	cLote := GetMV("ES_NWLTTSS")

	FreeUsedCode()
	While !MayIUseCode( "ES_NWLTTSS"+cLote )
		cLote := StrZero(Val(cLote)+1,15,0)
	EndDo

	//-- aqui estou gravando o proximo numero no parametro ES_NWLTTSS
	PutMv("ES_NWLTTSS",StrZero(Val(cLote)+1,15,0))

	If U_TSStcSetConn() //abre ou seta conexão para banco TSS

		//cSqlUpd := "DELETE "
		//cSqlUpd += " FROM sped054 "
		//cSqlUpd += 		" WHERE id_ent = '" + aDados[1] + "' "
		//cSqlUpd += 		" AND nfe_id = '" + aDados[2] + "' "
		//nStatus := TcSQLExec(Upper(cSqlUpd))

		cSqlUpd := "UPDATE sped054 "
		cSqlUpd += " SET d_e_l_e_t_ = '*' " //-- deletado (para guardar HISTÓRICO)
		cSqlUpd += 		" WHERE id_ent = '" + aDados[1] + "' "
		cSqlUpd += 		" AND nfe_id = '" + aDados[2] + "' "
		nStatus := TcSQLExec(Upper(cSqlUpd))

		If (nStatus < 0)
			If !IsBlind()
				Alert("TCSQLError() " + TCSQLError())
			Else
				//conout("TCSQLError() " + TCSQLError())
			EndIf
		EndIf

		//-- Criado um parametro "ES_AJUS054": Atualiza SPED054 ?
		If lUpdSped054

			cXML_PROT := '<protNFe xmlns="http://www.portalfiscal.inf.br/nfe" versao="'+aDados[9]+'">'
			cXML_PROT += '<infProt>'
			cXML_PROT += '<tpAmb>1</tpAmb>'
			cXML_PROT += '<verAplic>'+aDados[9]+'</verAplic>'
			cXML_PROT += '<chNFe>'+aDados[3]+'</chNFe>'
			cXML_PROT += '<dhRecbto>'+SubStr(aDados[6],1,4)+'-'+SubStr(aDados[6],5,2)+'-'+SubStr(aDados[6],7,2)+'T'+aDados[7]+'-03:00</dhRecbto>'
			cXML_PROT += '<nProt>'+aDados[4]+'</nProt>'
			cXML_PROT += '<digVal>'+aDados[8]+'</digVal>'
			cXML_PROT += '<cStat>100</cStat>'
			cXML_PROT += '<xMotivo>Autorizado o uso da NF-e</xMotivo>'
			cXML_PROT += '</infProt>'
			cXML_PROT += '</protNFe>'

			cSqlUpd := "INSERT INTO sped054"
			If luSitSp
				cSqlUpd += 		" (r_e_c_n_o_, id_ent, lote, nfe_id, nfe_chv, cstat_sefr, xml_prot, xmot_sefr, dtrec_sefr, hrrec_sefr, nfe_prot, dtver_lotp, hrver_lotp, situa) "
				cSqlUpd += 		" VALUES ( (select MAX(s054.r_e_c_n_o_) "
				cSqlUpd += 					" from sped054 s054)+1, '"+aDados[1]+"', '"+cLote+"', '"+aDados[2]+"', '"+aDados[3]+"', '100', '"+cXML_PROT+"', 'Autorizado o uso da NF-e', '"+aDados[6]+"', '"+aDados[7]+"', '"+aDados[4]+"', '"+aDados[6]+"', '"+aDados[7]+"', '  ' )"
			Else
				cSqlUpd += 		" (r_e_c_n_o_, id_ent, lote, nfe_id, nfe_chv, cstat_sefr, xml_prot, xmot_sefr, dtrec_sefr, hrrec_sefr, nfe_prot, dtver_lotp, hrver_lotp) "
				cSqlUpd += 		" VALUES ( (select MAX(s054.r_e_c_n_o_) "
				cSqlUpd += 					" from sped054 s054)+1, '"+aDados[1]+"', '"+cLote+"', '"+aDados[2]+"', '"+aDados[3]+"', '100', '"+cXML_PROT+"', 'Autorizado o uso da NF-e', '"+aDados[6]+"', '"+aDados[7]+"', '"+aDados[4]+"', '"+aDados[6]+"', '"+aDados[7]+"' )"
			EndIf
			nStatus := TcSQLExec(Upper(cSqlUpd))

			If (nStatus < 0)
				If !IsBlind()
					Alert("TCSQLError() " + TCSQLError())
				Else
					//conout("TCSQLError() " + TCSQLError())
				EndIf
			EndIf

		EndIf

		cSqlUpd := "UPDATE sped050 "
		cSqlUpd += " SET nfe_prot = '" + aDados[4] + "', "
		cSqlUpd += 		" status = 6, "
		cSqlUpd += 		" lote = '" + cLote + "', "
		If luSitSp
			cSqlUpd += 		" situa = '  ', "
		EndIf
		cSqlUpd += 		" statuscanc = 0, "
		cSqlUpd += 		" statusmail = 0, "
		cSqlUpd += 		" tipo_canc = 0, "
		cSqlUpd += 		" d_e_l_e_t_ = ' ' " //-- não deletado (caso registro deletado, recupera o mesmo)
		cSqlUpd += " WHERE r_e_c_n_o_ = '" + AllTrim( Str(aDados[5]) ) + "' "
		nStatus := TcSQLExec(Upper(cSqlUpd))

		If (nStatus < 0)
			If !IsBlind()
				Alert("TCSQLError() " + TCSQLError())
			Else
				//conout("TCSQLError() " + TCSQLError())
			EndIf
		EndIf

	EndIf

	FreeUsedCode()

	If lUsaQuery
		U_PROtcSetConn() //seta conexão para banco Protheus
	EndIf

	RestArea(aArea)

Return

//----------------------------------------------------------------
/*/{Protheus.doc} URetEntTss
Retorna o Codigo da Entidade.
@param	 cModelo 	Modelo do Documento Fiscal
@return	 cIDENT		Codigo da Entidade que sera retornado
@author  Varejo
@version P11.8
@since   19/04/2016
/*/
//------------------------------------------------------------------
Static Function URetEntTss(cModelo, lAviso)

	Local cIDENT	:= ""							// Codigo da Entidade que sera retornado
	Local cURL   	:= ""							// URL de conexão com o TSS
	Local cErro		:= ""							// mensagem de erro do WS
	Local nPos		:= 0
	Local lRetWS	:= .T.							// verifica se o metodo do WS foi executado com sucesso
	Local lTentar	:= .T.
	Local lUsaGesEmp:= IIF( FindFunction("FWFilialName") .AND. FindFunction("FWSizeFilial") .AND. FWSizeFilial() > 2, .T., .F. )
	Local lEnvCodEmp:= GetNewPar("MV_ENVCDGE",.F.)
	Local aEndereco	:= {}							// array com Logradouro[C], Numero[N], Numero[C] e Complemento[C]
	Local aTelefone := {}							// array com DDI[N], DDD[N] e Telefone[N]
	Local cFax		:= ""
	Local cNomeFant	:= ""
	Local oWS										// Objeto WS

	Default cModelo	:= "65"	//NFC-e
	Default lAviso	:= .T.

	LjGrvLog ("", "Modelo do Documento"		, cModelo)
	LjGrvLog ("", "Grupo Empresa SM0"		, SM0->M0_CODIGO)
	LjGrvLog( "", "Filial SM0"				, SM0->M0_CODFIL)
	LjGrvLog( "", "Grupo Empresa cEmpAnt"	, cEmpAnt)
	LjGrvLog( "", "Filial cFilAnt"			, cFilAnt)

	If SM0->M0_CODFIL <> CFILANT
		LjGrvLog( "LOJNFCE", "SM0 NÃO posicionada conforme CFILANT", SM0->M0_CODFIL )

		If !SM0->( DbSeek(CEMPANT + CFILANT) )
			LjGrvLog( "LOJNFCE", "NÃO foi possível posicionar SM0 conforme CFILANT", CFILANT)
		EndIf
	EndIf

//
// verificamos se o IDENT já foi obtido
//
	nPos := Ascan( aIDEnt, {|x| x[1] == cModelo} )

// Se não achou o modelo de documento no array, precisamos obter sua entidade no TSS
	If nPos == 0

		// tratamento dos parametros do metodo do WS
		If FindFunction("LjFiGetEnd")
			aEndereco := LjFiGetEnd(SM0->M0_ENDENT, Nil, .T.)	//LOJXFUNB.PRW
			aTelefone := LjFiGetTel(SM0->M0_TEL)
			cFax	  := LjFiGetTel(SM0->M0_FAX)[3]
		Else
			aEndereco := FisGetEnd(SM0->M0_ENDENT) 				//MATA950.PRW
			aTelefone := FisGetTel(SM0->M0_TEL)
			cFax	  := FisGetTel(SM0->M0_FAX)[3]
		EndIf

		If cModelo == "65"
			cURL := SuperGetMV("MV_NFCEURL",,"")
			cNomeFant := Alltrim(SM0->M0_NOME)
		Else
			cURL := SuperGetMV("MV_SPEDURL",,"")
			//futuramente, verificar o impacto de passar essa mesma validação para NFC-e
			If lUsaGesEmp
				cNomeFant := FWFilialName()
			Else
				cNomeFant := Alltrim(SM0->M0_NOME)
			EndIf
		EndIf

		//
		//instancia o Web Services
		//
		oWS := WsSPEDAdm():New()

		oWS:_URL 					:= AllTrim(cURL)+"/SPEDADM.apw"
		oWS:cUSERTOKEN				:= "TOTVS"

		oWS:oWSEMPRESA:cCNPJ        := IIF(SM0->M0_TPINSC==2 .Or. Empty(SM0->M0_TPINSC),SM0->M0_CGC,"")
		oWS:oWSEMPRESA:cCPF         := IIF(SM0->M0_TPINSC==3,SM0->M0_CGC,"")
		oWS:oWSEMPRESA:cIE          := SM0->M0_INSC
		oWS:oWSEMPRESA:cIM          := SM0->M0_INSCM
		oWS:oWSEMPRESA:cNOME        := SM0->M0_NOMECOM
		oWS:oWSEMPRESA:cFANTASIA    := cNomeFant
		oWS:oWSEMPRESA:cENDERECO    := aEndereco[1]
		oWS:oWSEMPRESA:cNUM         := aEndereco[3]
		oWS:oWSEMPRESA:cCOMPL       := aEndereco[4]
		oWS:oWSEMPRESA:cUF          := SM0->M0_ESTENT
		oWS:oWSEMPRESA:cCEP         := SM0->M0_CEPENT
		oWS:oWSEMPRESA:cCOD_MUN     := SM0->M0_CODMUN
		oWS:oWSEMPRESA:cCOD_PAIS    := "1058"
		oWS:oWSEMPRESA:cBAIRRO      := SM0->M0_BAIRENT
		oWS:oWSEMPRESA:cMUN         := SM0->M0_CIDENT
		oWS:oWSEMPRESA:cCEP_CP      := Nil
		oWS:oWSEMPRESA:cCP          := Nil
		oWS:oWSEMPRESA:cDDD         := Str(aTelefone[2],3)
		oWS:oWSEMPRESA:cFONE        := AllTrim( Str(aTelefone[3],15) )
		oWS:oWSEMPRESA:cFAX         := AllTrim( Str(cFax,15) )
		oWS:oWSEMPRESA:cEMAIL       := UsrRetMail(RetCodUsr())
		oWS:oWSEMPRESA:cNIRE        := SM0->M0_NIRE
		oWS:oWSEMPRESA:dDTRE        := SM0->M0_DTRE
		oWS:oWSEMPRESA:cNIT         := IIF(SM0->M0_TPINSC==1,SM0->M0_CGC,"")
		oWS:oWSEMPRESA:cINDSITESP   := ""
		oWS:oWSEMPRESA:cID_MATRIZ   := ""
		//exclusivo para NF-e
		If cModelo == "55" .AND. lUsaGesEmp .AND. lEnvCodEmp
			oWS:oWSEMPRESA:CIDEMPRESA:= FwGrpCompany()+FwCodFil()
		EndIf
		oWS:oWSOUTRASINSCRICOES:oWSInscricao := SPEDADM_ARRAYOFSPED_GENERICSTRUCT():New()

		LjGrvLog("","Objeto oWS",oWS)

		//
		//tratamento do retorno do Web Services
		//
		While lTentar

			lRetWS := oWs:ADMEMPRESAS()

			//tratamento do retorno do WS
			If ValType(lRetWS) == "U"
				lRetWS := .F.
			EndIf

			If lRetWS
				Aadd( aIDEnt, {cModelo, oWS:cADMEMPRESASRESULT} )
				lTentar := .F.	//para sair do While
			Else
				//tratamento para obter o SOAP Fault do Web Services
				If Empty( GetWscError(3) )
					cErro := GetWscError(1)
				Else
					cErro := GetWscError(3)
				EndIf

				//se houver interface de usuario, pergunta ao usuario se ele quer tentar novamente
				If !IsBlind()
					If lAviso
						//"NFC-e: Não foi possível transmitir NFC-e (Capturar Código Entidade)" ## //"SIM" ## //NÃO ## //"Deseja tentar novamente?"
						If Aviso("Nao foi possível obter o código da Entidade", cErro, {"SIM","NÃO"}, 3, "Deseja tentar novamente?") == 2
							lTentar := .F.	//usuário escolheu não tentar novamente
						EndIf
					EndIf
				Else
					lTentar := .F.
					//conout( "Nao foi possivel obter o código da Entidade", cErro)	//"NFC-e: Não foi possível transmitir NFC-e (Capturar Código Entidade)"
					Help( ,, "NFCETSS",, "Nao foi possivel obter o código da Entidade" + cErro, 1, 0 )
				EndIf
			EndIf
		EndDo

	EndIf

//
// Obtemos o codigo da entidade (SPED001.IDENT) de acordo com o modelo de documento (55 NF-e ou 65 NFC-e)
//
	If lRetWS
		// se acabou de obter o IDENT, procuramos sua posição no array estatico
		If nPos == 0
			nPos := Ascan( aIDEnt, {|x| x[1] == cModelo} )
			LjGrvLog("","aIDEnt (Entidades Carregadas)", aIDEnt)
		EndIf

		If nPos > 0
			cIDENT := aIDEnt[nPos][2]
		EndIf
	EndIf

	LjGrvLog("","Entidade Retornada", cIDENT)

Return cIDENT

//-------------------------------------------------------------------
/*/{Protheus.doc} ULegStatus
Legenda do Status das notas
@author  author
@since   date
@version version
/*/
//-------------------------------------------------------------------
Static Function ULegStatus()

	BrwLegenda("Status da Nota", "Legenda", { ;
		{"BR_VERDE","100 - Autorizado o uso da NF-e"},;
		{"BR_AZUL","101 - Cancelamento de NF-e homologado"},;
		{"BR_AMARELO","102 - Inutilização de número homologado"},;
		{"BR_LARANJA","110 - Uso Denegado"},;
		{"BR_VERMELHO","301 - Uso Denegado : Irregularidade fiscal do emitente"},;
		{"BR_VIOLETA","302 - Rejeição: Irregularidade fiscal do destinatário"},;
		{"BR_PRETO","999 - Rejeição: Erro não catalogado"};
		})

Return()

//-------------------------------------------------------------------
/*/{Protheus.doc} TransNF
Transmissão da NFC-e/NF-e
@author  author
@since   date
@version version
/*/
//-------------------------------------------------------------------
Static Function TransNF()

	Local aSL1 := SL1->( GetArea() )
	Local aRetTSS := {}
	Local cID := ""
	Local lRet := .F.
	Local aDados := {}
	Local cArqINI := GetAdv97() // Retorna o nome do arquivo INI do server
	Local cIsCPDV := GetPvProfString("CPDV", "ISCPDV", "", cArqINI) // Identifica no INI se eh Central de PDV
	Local lIsCPDV := .F. // Eh central de PDV
	Local luSitua := SuperGetMV("MV_XUSITUA",,.T.) //Integra a venda: atualiza o L1_SITUA para integrar

	If AllTrim(cIsCPDV) = "1"
		// Indica que o sistema foi iniciado como Central de PDV
		lIsCPDV := .T.
	EndIf

	//-- Posiciona para Impressao
	SL1->( DbGoTo( oMSGetNotas:aCols[oMSGetNotas:nAt][aScan(oMSGetNotas:aHeader,{|x| AllTrim(x[2])=="N0C_VALOR"})] ) )
	If SL1->(!Eof())

		aRetTSS := StrToKarr(SL1->L1_RETSFZ,"|")
		cID := ""

		if len(aRetTSS) >= 2
			cID := aRetTSS[2]
		endif

		If cID == '100'
			U_UHelp("Transmissão NF-e/NFC-e","Nota fiscal já foi autorizada.",SL1->L1_RETSFZ)

		ElseIf !Empty(SL1->L1_KEYNFCE)
			If substr(SL1->L1_KEYNFCE,21,2) == "65"
				LjNFCeRetr()
			Else
				MsgRun("Aguarde, transmitindo a nota "+SL1->L1_DOC+"/"+SL1->L1_SERIE+"...",,{|| lRet := STransNF()})
			EndIf

		EndIf

	EndIf

	If lRet
		aRetTSS := StrToKarr(SL1->L1_RETSFZ,"|")
		cID := ""

		If len(aRetTSS) >= 2
			cID := aRetTSS[2]
		EndIf

		If cID <> '100'
			aDados := {}
			lNFe := (Substr(SL1->L1_KEYNFCE,21,2) == "55")

			//-- Vamos Verificar se foi autorizado na SEFAZ
			//-- [01] = Versao
			//-- [02] = Ambiente
			//-- [03] = Cod Retorno Sefaz
			//-- [04] = Descricao Retorno Sefaz
			//-- [05] = Protocolo
			//-- [06] = Hash
			aDados  := VldNFSefaz( .F./*não consulta no TSS Local*/, {{SL1->L1_KEYNFCE,"",lNFe}} )
			cRetSfz := aDados[05]+"|"+aDados[03]+"|"+aDados[04]

			//aDados := VldNFSefaz( .T./*consulta no TSS Local*/, {{Left(AllTrim(SL1->L1_SERIE),3), Right(AllTrim(SL1->L1_DOC),9), lNFe}} )
			//cRetSfz := aDados[01][04]+"|"+aDados[01][05]+"|"+aDados[01][06]

			If !Empty(cRetSfz)

				RecLock( "SL1", .F. )
				If aDados[03] == '100' .and. !(SL1->L1_SITUA $ '00/TX/07') .and. Empty(SL1->L1_NUMORIG)
					If luSitua
						If lIsCPDV
							SL1->L1_SITUA := 'CP' //"CP" - Recebido pela Central de PDV
						Else
							SL1->L1_SITUA := '00' //"00" - Venda Efetuada com Sucesso
						EndIf
					Else
						SL1->L1_SITUA := 'XX'
					EndIf
				EndIf
				SL1->L1_RETSFZ := cRetSfz
				SL1->( MsUnlock() )

				//-- forço a gravação do DOC/SERIE do item
				SL2->(DbSetOrder(1)) //L2_FILIAL+L2_NUM+L2_ITEM+L2_PRODUTO
				SL2->(DbSeek(xFilial("SL2")+SL1->L1_NUM))
				While SL2->(!Eof()) .and. SL2->(L2_FILIAL+L2_NUM) == (xFilial("SL2")+SL1->L1_NUM)
					If Empty(SL2->L2_DOC) .and. Empty(SL2->L2_SERIE)
						RecLock( "SL2", .F. )
						SL2->L2_VENDIDO := 'S'
						SL2->L2_DOC := SL1->L1_DOC
						SL2->L2_SERIE := SL1->L1_SERIE
						SL2->( MsUnlock() )
					EndIf
					SL2->(DbSkip())
				EndDo

			EndIf
		EndIf
		StiLoadData()
	EndIf

	RestArea(aSL1)
Return

//-------------------------------------------------------------------
/*/{Protheus.doc} STransNF
Transmite NFe/NFCe (considera que esta posicionado na SL1)
@author  author
@since   date
@version version
/*/
//-------------------------------------------------------------------
Static Function STransNF()

	Local cRetorno		:= ""	//mensagem de retorno
	Local cIDEnt		:= ""
	Local cAmbiente		:= ""
	Local cModalidade	:= ""
	Local cVersao		:= ""
	Local lRetorno		:= .F.
	Local lEnd			:= .F.
	Local aArea			:= GetArea()
	Local aSL1aArea		:= SL1->( GetArea() )
	Local lAux 			:= .T.

	Private bFiltraBrw := {||}	//usado por compatibilidade por causa do fonte SPEDNFE.PRX

	MV_PAR01 := SL1->L1_SERIE
	MV_PAR02 := SL1->L1_DOC
	MV_PAR03 := SL1->L1_DOC

	//---------------------------
	// Obtem o codigo da entidade
	//---------------------------
	cIDEnt := iif( (Substr(SL1->L1_KEYNFCE,21,2) == "55"), cIdEntNFe, cIdEntNFCe )

	If !Empty(cIDEnt)

		//------------------------------------
		// Obtem os parametros do servidor TSS
		//------------------------------------
		//carregamos o array estatico com os parametros do TSS
		//If StaticCall(LOJNFCE, LjCfgTSS, Substr(SL1->L1_KEYNFCE,21,2))[1]
		lAux := &("StaticCall(LOJNFCE, LjCfgTSS, Substr(SL1->L1_KEYNFCE,21,2))[1]")
		If lAux
			//cAmbiente	:= StaticCall(LOJNFCE, LjCfgTSS, Substr(SL1->L1_KEYNFCE,21,2), "AMB")[2]
			//cModalidade := StaticCall(LOJNFCE, LjCfgTSS, Substr(SL1->L1_KEYNFCE,21,2), "MOD")[2]
			//cVersao		:= StaticCall(LOJNFCE, LjCfgTSS, Substr(SL1->L1_KEYNFCE,21,2), "VER")[2]
			cAmbiente	:= &("StaticCall(LOJNFCE, LjCfgTSS, Substr(SL1->L1_KEYNFCE,21,2), 'AMB')[2]")
			cModalidade := &("StaticCall(LOJNFCE, LjCfgTSS, Substr(SL1->L1_KEYNFCE,21,2), 'MOD')[2]")
			cVersao		:= &("StaticCall(LOJNFCE, LjCfgTSS, Substr(SL1->L1_KEYNFCE,21,2), 'VER')[2]")

			//------------------------------
			// Realiza a transmissão da NF-e
			//------------------------------
			//conout( "[IDENT: " + cIDEnt+"] - Iniciando transmissao NF-e de saida! - " + Time() )

			cRetorno := SpedNFeTrf(	"SL1"	, SL1->L1_SERIE, SL1->L1_DOC , SL1->L1_DOC ,;
				cIDEnt	, cAmbiente	   , cModalidade , cVersao	   ,;
				@lEnd	, .F.		   , .F. )

			lRetorno := .T.

			//conout( "[IDENT: " + cIDEnt+"] - Transmissao da NF-e de saida finalizada! - " + Time() )
			/*
			3 ULTIMOS PARAMETROS:
				lEnd - parametro não utilizado no SPEDNFeTrf
				lCte
				lAuto
			*/
		Else
			cRetorno += "Não foi possível obter o valor dos parâmetros do TSS." + CRLF
			cRetorno += "Por favor, realize a transmissão através do Módulo FATURAMENTO." + CRLF
		EndIf
	Else
		cRetorno += "Não foi possível obter o Código da Entidade (IDENT) do servidor TSS." + CRLF
		cRetorno += "Por favor, realize a transmissão através do Módulo FATURAMENTO." + CRLF
	EndIf

	If !Empty(cRetorno)
		u_uHelp("Transmissão NF-e/NFC-e",cRetorno,"")
	EndIf

	//restaura as areas
	RestArea(aSL1aArea)
	RestArea(aArea)

Return lRetorno

//-------------------------------------------------------------------
/*/{Protheus.doc} RetAbaste
Retorna o código do abastecimento, conforme parametros
@author  author
@since   date
@version version
/*/
//-------------------------------------------------------------------
Static Function RetAbaste(dEmisNf, cProduto, nQuant, cBico, cBomba, cTanque, nEncIni, nEncFin)

	Local cTabLEG := AllTrim( GetNewPar("MV_LJDCLEG","LEG") )
	Local cLEGPfx := iif( Left(cTabLEG,1)=="S", SubStr(cTabLEG,2,2), cTabLEG)
	Local aArea		:= GetArea()
	Local aAreaLEG  := (cTabLEG)->(GetArea())
	Local cCodAbast := ""
	Local cLocAbast := AllTrim(SuperGetMV("MV_XLOCREC",,"")) //Armazem padrão para recuperação de vendas do PDV
	Local cCondicao	:= ""
	Local bCondicao

	If !Empty(cBico) .and. nEncFin > 0

		cCondicao := cLEGPfx+"_FILIAL = '" + xFilial(cTabLEG) + "'"
		cCondicao += " .AND. AllTrim("+cLEGPfx+"_PROD) = '" + AllTrim(cProduto) + "'"
		//cCondicao += " .AND. "+cLEGPfx+"_QTDLT = " + cValToChar(Round(nQuant,TamSX3(cLEGPfx+"_QTDLT")[2])) + ""
		cCondicao += " .AND. INT("+cLEGPfx+"_NENCER) = INT(" + cValToChar(nEncFin) + ")"
		cCondicao += " .AND. "+cLEGPfx+"_TANQUE = '" + cTanque + "'"
		cCondicao += " .AND. Val("+cLEGPfx+"_CODBIA) = " + cBico + ""
		cCondicao += " .AND. Val("+cLEGPfx+"_BOMBA) = " + cBomba + ""

		(cTabLEG)->(DbClearFilter()) //-- limpo os filtros da LEG
		bCondicao := "{|| " + cCondicao + " }"
		(cTabLEG)->(DbSetFilter(&bCondicao,cCondicao))
		(cTabLEG)->(DbGoTop())

		While (cTabLEG)->(!Eof()) .and. (cTabLEG)->&(cLEGPfx+"_FILIAL") == xFilial(cTabLEG)

			If (cTabLEG)->&(cLEGPfx+"_QTDLT") = nQuant

				cCodAbast := (cTabLEG)->&(cLEGPfx+"_CODIGO")

				If Empty(cLocAbast)
					cLocAbast := (cTabLEG)->&(cLEGPfx+"_TANQUE")
				EndIf
				Exit //sai do While

			EndIf
			(cTabLEG)->(DbSkip())
		EndDo

		(cTabLEG)->(DbClearFilter()) //-- limpo os filtros da LEG
	EndIf

	RestArea(aAreaLEG)
	RestArea(aArea)
Return {cCodAbast,cLocAbast}

//-------------------------------------------------------------------
/*/{Protheus.doc} xMonitor3
processa as inutilizações
@author  author
@since   date
@version version
/*/
//-------------------------------------------------------------------
Static Function xMonitor3( lAuto, oSay, aMarcadas, dApartir )

	Local cSQL := ""
	Local aRecnoSM0 := {}

	Local nCount := 0, nCountSPDX := 0

	Local nI := 0, nX := 0, nV := 0

	Local cTiposDoc := AllTrim( SuperGetMV( 'MV_ESPECIE' ) ) // Tipos de documentos fiscais utilizados na emissao de notas fiscais //1=SPED;U=NFS;UNI=RPS;4=SPED;5=NFCE;
		Local aTiposDoc := StrTokArr(cTiposDoc,';')
	Local bNoHasVar := {|cVar| Type(cVar) == "U" }
	Local bGetMvFil	:= {|cPar,cDef| SuperGetMV(cPar,,cDef) }

	Private lNFe := .F.

	Private cNomeArq 	:= ""
	Private cTexto 		:= ""
	Private cNotas 		:= "" //"Filial;Dt.Emis;Documento;Serie;Status;" + CRLF

	If Empty(cPathSX)
		cPathSX := cErroLOG+iif(IsSrvUnix(),"/","\")
	EndIf

//-- Abre tela para seleção de pasta (maquina local) para salvar os LOG's
//cPathSX := cGetFile( "Selecione LOG | " , OemToAnsi( "Selecione Diretorio LOG" ) , NIL , "C:\" , .F. , GETF_LOCALHARD+GETF_RETDIRECTORY )
//iif((len(cPathSX)>0) .and. (substr(cPathSX,Len(cPathSX),1)<>"\"), cPathSX:=cPathSX+"\", )

	If !MyOpenSm0(.T.)
		Return .F.
	EndIf

	If Type("cIdEntNFe") == "U"
		//-- Determina ID
		cIdEntNFe	:= URetEntTss("55",.F.)
		cURLNFe		:= AllTrim( GetMV("MV_SPEDURL") )

		cIdEntNFCe	:= URetEntTss("65",.F.)
		cURLNFCe	:= AllTrim( GetMV("MV_NFCEURL") )
	EndIf

	dbSelectArea( "SM0" )
	dbGoTop()

//aMarcadas -> {SM0->M0_CODIGO, SM0->M0_CODFIL, SM0->M0_CODIGO + SM0->M0_CODFIL}
	While !SM0->( EOF() )
		// So adiciona no aRecnoSM0 se a empresa for diferente
		If aScan( aRecnoSM0, { |x| AllTrim(x[2]) == AllTrim(SM0->M0_CODIGO) .and. AllTrim(x[3]) == AllTrim(SM0->M0_CODFIL) } ) == 0 ;
				.AND. aScan( aMarcadas, { |x| AllTrim(x[1]) == AllTrim(SM0->M0_CODIGO) .and. AllTrim(x[2]) == AllTrim(SM0->M0_CODFIL) } ) > 0
			aAdd( aRecnoSM0, { SM0->(Recno()), SM0->M0_CODIGO, SM0->M0_CODFIL } )
		EndIf
		SM0->( dbSkip() )
	EndDo

//SM0->( dbCloseArea() )

	For nI := 1 To Len( aRecnoSM0 )

		SM0->( dbGoTo( aRecnoSM0[nI][1] ) )

		If !lAuto
			//-- Preparar ambiente local
			//RpcSetType( 3 )
			//RpcSetEnv( SM0->M0_CODIGO, SM0->M0_CODFIL )

			cEmpAnt := AllTrim(SM0->M0_CODIGO)
			cFilAnt := AllTrim(SM0->M0_CODFIL)

			//-- Preparar ambiente local na retagauarda
			RpcSetType(3)
			//PREPARE ENVIRONMENT EMPRESA cEmpAnt FILIAL cFilAnt MODULO "SIGALOJA"
			PREPARE ENVIRONMENT EMPRESA cEmpAnt FILIAL cFilAnt MODULO "FRT"

		EndIf

		#IFDEF TOP
			lUsaQuery := .T.
			U_PROtcSetConn() //seta conexão para banco Protheus
		#ENDIF

		If !U_TSStcSetConn() //abre ou seta conexão para banco TSS
			Return .F.
		Else

			For nX:=1 to Len(aTiposDoc)

				If "=SPED" $ aTiposDoc[nX] .or. "=NFCE" $ aTiposDoc[nX] //MV_ESPECIE -> 1=SPED;U=NFS;UNI=RPS;4=SPED;5=NFCE;

					cSerNF := StrTran(StrTran(aTiposDoc[nX],"=NFCE",""),"=SPED","")

					//-- Select para encotrar os 'buracos' de notas para serem inutilizadas
					cSQL := "select S050_2.* " + CRLF
					cSQL += " from ( " + CRLF
					cSQL += " select S050.ID_ENT, S050.DOC_SERIE, S050.DOC_ID, S050.MODELO, " + CRLF
					cSQL += " coalesce(lag(DOC_ID) over (order by DOC_ID),'') as DOC_ID_ANTERIOR, " + CRLF
					cSQL += " coalesce(cast(DOC_ID as int) - cast(lag(DOC_ID) over (order by DOC_ID) as int) - 1,0) as QTD " + CRLF
					cSQL += " from SPED050 S050 " + CRLF
					cSQL += " where S050.D_E_L_E_T_ = ' ' " + CRLF
					cSQL += " and S050.ID_ENT = '" + Iif( "=SPED" $ aTiposDoc[nX], cIdEntNFe, cIdEntNFCe ) + "' " + CRLF
					cSQL += " and S050.AMBIENTE = 1 " + CRLF //-- 1-Produção / 2-Homologação
					cSQL += " and S050.DOC_SERIE = '" + cSerNF + "'"+ CRLF
					If ValType(lUnicDia) == 'L' .and. lUnicDia
						cSQL += " and S050.DATE_NFE = '" + DtoS(dApartir) + "'" + CRLF
					Else
						cSQL += " and S050.DATE_NFE >= '" + DtoS(dApartir) + "'" + CRLF
					EndIf
					cSQL += ") as S050_2 where S050_2.QTD > 0 " + CRLF

					If Select("S050") > 0
						S050->( DbCloseArea() )
					EndIf

					//U_XHELP("xMonitor3","cSQL: "+cSQL,"")

					//cSQL := ChangeQuery(cSQL)
					TcQuery cSQL New ALIAS "S050"

					nCountSPDX := 0
					nCount := 0

					//-- Esse TRECHO esta deixando a o ponteiro do alias S050 no final de arquivo, mesmo executando DbGoTop
					If !S050->( Eof() )
						S050->(DbEval({|| nCountSPDX += S050->QTD}))
					EndIf

					If nCountSPDX > 0
						If Select("S050") > 0
							S050->( DbCloseArea() )
						EndIf

						//cSQL := ChangeQuery(cSQL)
						TcQuery cSQL New ALIAS "S050"
					EndIf

					If !IsBlind()
						oSay:cCaption := 'Quantidade registros SPED050: ' + cValToChar(nCountSPDX)
						ProcessMessages()
					EndIf
					//Sleep( 5000 )

					SLX->(DbSetOrder(1)) //LX_FILIAL+LX_PDV+LX_CUPOM+LX_SERIE+LX_ITEM+LX_HORA
					SL1->(DbSetOrder(2)) //L1_FILIAL+L1_SERIE+L1_DOC+L1_PDV

					S050->( DbGoTop() )
					While !S050->( Eof() )

						If S050->QTD > 0

							cDoc := AllTrim(S050->DOC_ID_ANTERIOR)
							cDoc := PADL(cDoc,TamSx3("LX_CUPOM")[1],"0")
							nQtd := S050->QTD

							For nV:=1 to nQtd

								cDoc   := SOMA1(cDoc)
								cSerie := S050->DOC_SERIE

								nCount++

								If !IsBlind()
									oSay:cCaption := 'Processando a nota: ' + AllTrim(cDoc)+'/'+AllTrim(cSerie) + ' - ' + cValToChar(nCount) + '/' +cValToChar(nCountSPDX)
									ProcessMessages()
								EndIf

								cSQL := "select S050.ID_ENT, S050.DOC_SERIE, S050.DOC_ID, S050.MODELO " + CRLF
								cSQL += " from SPED050 S050 " + CRLF
								cSQL += " where S050.D_E_L_E_T_ = ' ' " + CRLF
								cSQL += " and S050.ID_ENT = '" + S050->ID_ENT + "' " + CRLF
								cSQL += " and S050.AMBIENTE = 1 " + CRLF //-- 1-Produção / 2-Homologação
								cSQL += " and S050.DOC_ID = '" + cValToChar(Val(cDoc)) + "'"
								cSQL += " and S050.DOC_SERIE = '" + S050->DOC_SERIE + "'" + CRLF

								If Select("S050TMP") > 0
									S050TMP->( DbCloseArea() )
								EndIf

								//cSQL := ChangeQuery(cSQL)
								TcQuery cSQL New ALIAS "S050TMP"

								If Empty(cNotas)
									cNotas := "Filial;Dt.Emis;Documento;Serie;Status;" + CRLF
								EndIf

								If S050TMP->( Eof() ) //se consulta retornou vazia
									If !SL1->(DbSeek(xFilial("SL1")+cSerie+cDoc))
										If !SLX->(DbSeek(xFilial("SLX")+PADR("",TamSx3("LX_PDV")[1])+cDoc+cSerie))
											//Lj7SLXDocE(S050->MODELO, cDoc, cSerie, "", "", Nil) //inclui na SLX
											cNotas += cFilAnt+";"+DtoC(Date())+";"+cDoc+";"+cSerie+";"+"INCLUIDO NA SLX"+";" + CRLF
										Else
											cNotas += cFilAnt+";"+DtoC(SLX->LX_DTMOVTO)+";"+cDoc+";"+cSerie+";"+"JA INCLUIDO NA SLX"+";" + CRLF
										EndIf
									Else
										cNotas += cFilAnt+";"+DtoC(SLX->LX_DTMOVTO)+";"+cDoc+";"+cSerie+";"+"NOTA EXISTE NA SL1"+";" + CRLF
									EndIf
								Else
									cNotas += cFilAnt+";"+DtoC(SLX->LX_DTMOVTO)+";"+cDoc+";"+cSerie+";"+"NOTA EXISTE NA SPED050"+";" + CRLF
								EndIf

								S050TMP->( DbCloseArea() )

							Next nV
						EndIf

						S050->( DbSkip() )

					EndDo

					S050->( DbCloseArea() )

				EndIf

			Next nX

		EndIf

		// Volta para conexão ERP
		If lUsaQuery
			U_PROtcSetConn() //seta conexão para banco Protheus
		EndIf

		// Mostra a conexão ativa
		//conout( "StMonitor - xMonitor3 - Conexão ativa: banco = " + TcGetDB() )

		//conout( ">> StMonitor - xMonitor3 - FIM - Data: "+DtoC(date())+" - Hora: "+time()+"")

		If !Empty(cNotas)
			cNomeArq := "NOTAS_INUTILIZADAS_"+cFilAnt+"_"+DtoS(dDataBase)+"_"+SUBSTR(Time(),1,2)+SUBSTR(Time(),4,2)+SUBSTR(Time(),7,2)+".csv"
			U_UCriaLog(cPathSX/*cPasta*/,cNomeArq/*cNomeArq*/,cNotas/*cTexto*/,.F./*lHelp*/)
		EndIf
		cNotas := ""

	Next nI

Return .T.

//-------------------------------------------------------------------
/*/{Protheus.doc} xMonitor4
processa integração de vendas
@author  author
@since   date
@version version
/*/
//-------------------------------------------------------------------
Static Function xMonitor4( lAuto, oSay, aMarcadas, dApartir )

	Local aArea := GetArea()
	Local aAreaSL1 := SL1->(GetArea())
	Local aAreaSLG := SLG->(GetArea())
	Local aAreaSF2 := SF2->(GetArea())

	Local cCondicao := ""
	Local bCondicao
	Local luSitua	:= SuperGetMV("MV_XUSITUA",,.T.) //Integra a venda: atualiza o L1_SITUA para integrar

	Private cNomeArq 	:= ""
	Private cTexto 		:= ""
	Private cNotas 		:= "" //"Filial;Dt.Emis;Documento;Serie;Status;" + CRLF

	If Empty(cPathSX)
		cPathSX := cErroLOG+iif(IsSrvUnix(),"/","\")
	EndIf

//-- Abre tela para seleção de pasta (maquina local) para salvar os LOG's
//cPathSX := cGetFile( "Selecione LOG | " , OemToAnsi( "Selecione Diretorio LOG" ) , NIL , "C:\" , .F. , GETF_LOCALHARD+GETF_RETDIRECTORY )
//iif((len(cPathSX)>0) .and. (substr(cPathSX,Len(cPathSX),1)<>"\"), cPathSX:=cPathSX+"\", )

	#IFDEF TOP
		lUsaQuery := .T.
		U_PROtcSetConn() //seta conexão para banco Protheus
	#ENDIF

	If !U_TSStcSetConn() //abre ou seta conexão para banco TSS
		Return .F.
	Else

		cCondicao := " L1_FILIAL = '" + xFilial("SL1") + "'"
		cCondicao += " .and. !Empty(L1_DOC) .and. (Empty(L1_SITUA) .or. L1_SITUA = 'OK')"
		If ValType(lUnicDia) == 'L' .and. lUnicDia
			cCondicao += " .and. DtoS(L1_EMISNF) = '" + DtoS(dApartir) + "'"
		Else
			cCondicao += " .and. DtoS(L1_EMISNF) >= '" + DtoS(dApartir) + "'"
		EndIf
		cCondicao += " .and. DtoS(L1_EMISNF)+SubStr(L1_HORA,1,5) < '" + DtoS(Date())+SubStr(Time(),1,5) + "'"

		bCondicao 	:= "{|| " + cCondicao + " }"

		SL1->(DbClearFilter())
		SL1->(DbSetFilter(&bCondicao,cCondicao))

		SL1->(DbGoTop())

		nRecSLG := SLG->(RecNo())

		while !SL1->( Eof() )

			//-- Depois ver pq nao esta preenchendo no padrão
			If !(SL1->L1_SITUA $ 'CP/00/TX/07') .and. !Empty(SL1->L1_DOC) .and. ((Empty(SL1->L1_PDV) .and. !Empty(SL1->L1_ESTACAO)) .or. Empty(SL1->L1_NUMCFIS) .or. Empty(SL1->L1_TIPO) .or. Empty(SL1->L1_KEYNFCE))
				RecLock( "SL1", .F. )

				If SL1->L1_TPFRET <> "S"
					SL1->L1_TPFRET := "S"
				EndIf

				If Empty(SL1->L1_NUMCFIS) .and. !Empty(SL1->L1_DOC)
					SL1->L1_NUMCFIS := SL1->L1_DOC
				EndIf

				If Empty(SL1->L1_KEYNFCE) .and. SF2->( DbSetOrder(1), DbSeek( xFilial("SF2") + SL1->L1_DOC + SL1->L1_SERIE ) )
					SL1->L1_KEYNFCE := SF2->F2_CHVNFE
				EndIf

				//se for NF-e
				If !Empty(SL1->L1_KEYNFCE) .and. SubStr(L1_KEYNFCE,21,2) == '55'
					SL1->L1_IMPNF := .T.
				EndIf

				If Empty(SL1->L1_TIPO)
					SL1->L1_TIPO := "V"
				EndIf

				If SL1->L1_CONFVEN <> 'SSSSSSSSNSSS'
					SL1->L1_CONFVEN	:= 'SSSSSSSSNSSS'
				EndIf

				If Empty(SL1->L1_PDV) .and. !Empty(SL1->L1_ESTACAO) .and. SLG->( DbSetOrder(1), DbSeek( xFilial("SLG") + SL1->L1_ESTACAO ) ) //LG_FILIAL+LG_CODIGO
					SL1->L1_PDV := SLG->LG_PDV
				EndIf

				If Empty(SL1->L1_OPERADO)
					aDadosPDV := RetDadosPDV(SL1->L1_PDV, SL1->L1_EMISNF, SL1->L1_HORA) //[01] PDV, [02] Operador, [03] Estação, [04] Num.Movimento
					SL1->L1_OPERADO := aDadosPDV[02] //SA6->A6_COD
				EndIf

				SL1->( MsUnLock() )
				SL1->( DbCommit() )
			EndIf

			If !Empty(SL1->L1_SERIE) .and. !Empty(SL1->L1_DOC) .and. Empty(SL1->L1_KEYNFCE)

				cKeyNfe := RetKeyNfe(SL1->L1_SERIE, SL1->L1_DOC)
				If !Empty(cKeyNfe)
					RecLock( "SL1", .F. )
					SL1->L1_KEYNFCE := cKeyNfe
					SL1->( MsUnlock() )
					SL1->( DbCommit() )
				EndIf

			EndIf

			aRetTSS := StrToKarr(SL1->L1_RETSFZ,"|")
			cID := ""

			If len(aRetTSS) >= 2
				cID := aRetTSS[2]
			EndIf

			If !Empty(SL1->L1_SERIE) .and. !Empty(SL1->L1_DOC) .and. !Empty(SL1->L1_KEYNFCE) .and. (Empty(SL1->L1_RETSFZ) .or. cID <> '100' .or. (cID = '100' .and. !(SL1->L1_SITUA $ '00/TX/07') .and. Empty(SL1->L1_NUMORIG)))

				aDados := {}
				lNFe := (Substr(SL1->L1_KEYNFCE,21,2) == "55")

				//-- Vamos Verificar se foi autorizado na SEFAZ
				//-- [01] = Versao
				//-- [02] = Ambiente
				//-- [03] = Cod Retorno Sefaz
				//-- [04] = Descricao Retorno Sefaz
				//-- [05] = Protocolo
				//-- [06] = Hash
				aDados  := VldNFSefaz( .F./*não consulta no TSS Local*/, {{SL1->L1_KEYNFCE,"",lNFe}} )
				cRetSfz := aDados[05]+"|"+aDados[03]+"|"+aDados[04]

				//aDados := VldNFSefaz( .T./*consulta no TSS Local*/, {{Left(AllTrim(SL1->L1_SERIE),3), Right(AllTrim(SL1->L1_DOC),9), lNFe}} )
				//cRetSfz := aDados[01][04]+"|"+aDados[01][05]+"|"+aDados[01][06]

				If !Empty(cRetSfz)

					RecLock( "SL1", .F. )
					If aDados[03] == '100' .and. !(SL1->L1_SITUA $ 'CP/00/TX/07') .and. Empty(SL1->L1_NUMORIG)
						If luSitua
							If lIsCPDV
								SL1->L1_SITUA := 'CP' //"CP" - Recebido pela Central de PDV
							Else
								SL1->L1_SITUA := '00' //"00" - Venda Efetuada com Sucesso
							EndIf
						Else
							SL1->L1_SITUA := 'XX'
						EndIf
						If Empty(cNotas)
							cNotas := "Filial;Dt.Emis;Documento;Serie;Status;" + CRLF
						EndIf
						cNotas += cFilAnt+";"+DtoC(SL1->L1_EMISNF)+";"+SL1->L1_DOC+";"+SL1->L1_SERIE+";"+"NOTA INTEGRADA"+";" + CRLF
					EndIf
					SL1->L1_RETSFZ := cRetSfz
					SL1->( MsUnlock() )
					SL1->( DbCommit() )

					//-- forço a gravação do DOC/SERIE do item
					SL2->(DbSetOrder(1)) //L2_FILIAL+L2_NUM+L2_ITEM+L2_PRODUTO
					SL2->(DbSeek(xFilial("SL2")+SL1->L1_NUM))
					While SL2->(!Eof()) .and. SL2->(L2_FILIAL+L2_NUM) == (xFilial("SL2")+SL1->L1_NUM)
						If Empty(SL2->L2_DOC) .and. Empty(SL2->L2_SERIE)
							RecLock( "SL2", .F. )
							SL2->L2_VENDIDO := 'S'
							SL2->L2_DOC := SL1->L1_DOC
							SL2->L2_SERIE := SL1->L1_SERIE
							SL2->( MsUnlock() )
						EndIf
						SL2->(DbSkip())
					EndDo

				EndIf

			EndIf

			//-- integra as vendas autorizadas que estão com RX no PDV
			If !Empty(SL1->L1_RETSFZ) .and. (SL1->L1_SITUA == 'RX') //!(SL1->L1_SITUA $ '00/TX/07')
				aRetSFZ := StrTokArr(SL1->L1_RETSFZ,"|")
				If !Empty(SL1->L1_RETSFZ) .and. len(aRetSFZ) >= 2 .and. aRetSFZ[02] $ cCodAutorizados .and. Empty(SL1->L1_NUMORIG)

					RecLock( "SL1", .F. )
					If luSitua
						If lIsCPDV
							SL1->L1_SITUA := 'CP' //"CP" - Recebido pela Central de PDV
						Else
							SL1->L1_SITUA := '00' //"00" - Venda Efetuada com Sucesso
						EndIf
					Else
						SL1->L1_SITUA := 'XX'
					EndIf
					If Empty(cNotas)
						cNotas := "Filial;Dt.Emis;Documento;Serie;Status;" + CRLF
					EndIf
					cNotas += cFilAnt+";"+DtoC(SL1->L1_EMISNF)+";"+SL1->L1_DOC+";"+SL1->L1_SERIE+";"+"NOTA INTEGRADA"+";" + CRLF
					SL1->( MsUnlock() )
					SL1->( DbCommit() )

					//-- forço a gravação do DOC/SERIE do item
					SL2->(DbSetOrder(1)) //L2_FILIAL+L2_NUM+L2_ITEM+L2_PRODUTO
					SL2->(DbSeek(xFilial("SL2")+SL1->L1_NUM))
					While SL2->(!Eof()) .and. SL2->(L2_FILIAL+L2_NUM) == (xFilial("SL2")+SL1->L1_NUM)
						If Empty(SL2->L2_DOC) .and. Empty(SL2->L2_SERIE)
							RecLock( "SL2", .F. )
							SL2->L2_VENDIDO := 'S'
							SL2->L2_DOC := SL1->L1_DOC
							SL2->L2_SERIE := SL1->L1_SERIE
							SL2->( MsUnlock() )
						EndIf
						SL2->(DbSkip())
					EndDo

				EndIf
			EndIf

			SL1->( DbSkip() )
		EndDo

	EndIf

	// Volta para conexão ERP
	If lUsaQuery
		U_PROtcSetConn() //seta conexão para banco Protheus
	EndIf

	// Mostra a conexão ativa
	//conout( "StMonitor - xMonitor4 - Conexão ativa: banco = " + TcGetDB() )

	//conout( ">> StMonitor - xMonitor4 - FIM - Data: "+DtoC(date())+" - Hora: "+time()+"")

	If !Empty(cNotas)
		cNomeArq := "NOTAS_INTEGRADAS_"+cFilAnt+"_"+DtoS(dDataBase)+"_"+SUBSTR(Time(),1,2)+SUBSTR(Time(),4,2)+SUBSTR(Time(),7,2)+".csv"
		U_UCriaLog(cPathSX/*cPasta*/,cNomeArq/*cNomeArq*/,cNotas/*cTexto*/,.F./*lHelp*/)
	EndIf
	cNotas := ""

	SL1->(DbClearFilter())
	SLG->(DbGoto(nRecSLG))

	RestArea(aAreaSL1)
	RestArea(aAreaSLG)
	RestArea(aAreaSF2)
	RestArea(aArea)

Return .T.
//-------------------------------------------------------------------
/*/{Protheus.doc} SubHoras
Função que subtrai duas horas
@author  author
@since   date
@version version
/*/
//-------------------------------------------------------------------
Static Function SubHoras( nHr1 , nHr2 )
Return( __Min2Hrs( ( __Hrs2Min( nHr1 ) - __Hrs2Min( nHr2 ) ) ) )

//-------------------------------------------------------------------
/*/{Protheus.doc} SubSegundo
Função que subtrai 60min (3600 segundos) de uma Dt/Hr
@author  author
@since   date
@version version
/*/
//-------------------------------------------------------------------
Static Function SubSegundo(dtexp,hrexp,nsubseg)

	Local nHor := 0, nMin := 0, nSeg := 0
	Local aRet := {"",""} //Dt,Hr
	Default nsubseg := 3600 //60min (3600 segundos)

	//conout(">> SubSegundo - Função que subtrai "+cValToChar(nsubseg)+" segundos ("+cValToChar(nsubseg/60)+" min) de uma Dt/Hr")
	//conout(">> >> ANTES: dtexp - [" + dtoc( stod( dtexp ) ) + "] / hrexp - [" + hrexp + "]")

	//-- caso seja mais que 24h (86400 segundos) subtrai os dias
	dtexp := DtoS(DaySub(StoD(dtexp),int(nsubseg/86400))) //subtrai N dias
	nsubseg := mod(nsubseg,86400)

	//-- converte a hora passada em segundos
	nSeg += Val(SubStr(hrexp,1,2))*60*60 //converte hora em segundos
	nSeg += Val(SubStr(hrexp,4,2))*60 	 //converte minutos em segundos
	nSeg += Val(SubStr(hrexp,7,2)) 		 //segundos

	If nSeg > nsubseg //"00:00:00"
		nSeg := nSeg - nsubseg //subtrai nsubseg segundos
		nHor := Int(nSeg/(60*60))
		nMin := Int((nSeg-(nHor*60*60))/60)
		nSeg := Int(nSeg-(nHor*60*60)-(nMin*60))
		hrexp := StrZero(nHor,2)+":"+StrZero(nMin,2)+":"+StrZero(nSeg,2)
	Else
		dtexp := DtoS(DaySub(StoD(dtexp),1)) //subtrai 1 dias
		nSeg := nsubseg - nSeg
		nSeg := 86400 - nSeg //subtrai nSeg segundos de 24h
		nHor := Int(nSeg/(60*60))
		nMin := Int((nSeg-(nHor*60*60))/60)
		nSeg := Int(nSeg-(nHor*60*60)-(nMin*60))
		hrexp := StrZero(nHor,2)+":"+StrZero(nMin,2)+":"+StrZero(nSeg,2)
	EndIf

	aRet := {dtexp,hrexp}

	//conout(">> >> DEPOIS: dtexp - [" + dtoc( stod( dtexp ) ) + "] / hrexp - [" + hrexp + "]")
	//conout("")

Return(aRet)

/*/{Protheus.doc} RetLocal
Retorna o local estoque
@author thebr
@since 30/11/2018
@version 1.0
@return Nil
@param cProd, characters, descricao
@type function
/*/
Static Function RetLocal(cProd)

	Local aArea		:= GetArea()
	Local cLocal 	:= Space(TamSX3("L2_LOCAL")[1])

	//Verifica se possui Estoque de Exposição (no proceso da Marajó só pode haver 01 (um))
	DbSelectArea("U59")
	U59->(DbSetOrder(2)) //U59_FILIAL+U59_PRODUT

	/*
	Pablo Nunes
	Data: 12/12/2017
	Ajuste: com a finalidade de atender clientes que possuem mais de um estoque de exposição para o mesmo produto.
	Neste caso, deverá ser criado o campo "LG_XLOCAL" no cadastro de estação e alimenta-lo com o estoque de exposição do PDV.
	*/
	If SLG->(FieldPos("LG_XLOCAL"))>0 .and. !Empty(SLG->LG_XLOCAL)
		cLocal := SLG->LG_XLOCAL
	ElseIf U59->(DbSeek(xFilial("U59")+cProd))
		cLocal := U59->U59_LOCAL
	Else
		//Senão, utilização almoxarifado padrão
		DbSelectArea("SB1")
		SB1->(DbSetOrder(1)) //B1_FILIAL+B1_COD

		If SB1->(DbSeek(xFilial("SB1")+cProd))
			cLocal := SB1->B1_LOCPAD
		Endif
	Endif

	RestArea(aArea)

Return cLocal
