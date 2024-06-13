#INCLUDE "protheus.ch"
#INCLUDE "rwmake.ch"
#INCLUDE "topconn.ch"

/*
_____________________________________________________________________________
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦Programa  ¦ RCTBM009    ¦ Autor ¦ Totvs            ¦ Data ¦ 29/04/2016 ¦¦¦
¦¦+----------+------------------------------------------------------------¦¦¦
¦¦¦Descriçào ¦ Rotina de Contabilizaçao - Receb/Pagam entre filiais       ¦¦¦
¦¦¦          ¦                                                            ¦¦¦
¦¦+----------+------------------------------------------------------------¦¦¦
¦¦¦Uso       ¦ TOTVS - GO		                                          ¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯
*/

User Function RCTBM009()

Private oDlg08

//variaveis dos parametros
Private cPerg     := "RCTBM009"
Private lLancCtb  := .F.
Private lAglutina := .F.
Private dDtRef    := ctod("")
Private dDtInici  := ctod("")
Private dDtFinal  := ctod("")
Private cLote     := space(6) //"000120"
Private nSepPor   := 0
Private cFilDe    := space(TamSX3("E1_FILIAL")[1])
Private cFilAte   := space(TamSX3("E1_FILIAL")[1])

AjustaSX1()
//Pergunte(cPerg,.T.) //chama perguntas antes da tela explicativa

//Montando Dialog para parametrização
@ 200,1 TO 420,410 DIALOG oDlg08 TITLE OemToAnsi("Contabilização - Recebimentos/Pagamentos entre filais")
@ 10,10 TO 080,197
@ 20,018 Say " Este programa tem o objetivo de efetuar contabilização dos movimentos "
@ 28,018 Say " de Receb/Pagam entre filais (LP140). Utilize os parâmetros para preparar "
@ 36,018 Say " as configurações do processamento."

@ 90,108 BMPBUTTON TYPE 05 ACTION Pergunte(cPerg,.T.)
@ 90,138 BMPBUTTON TYPE 01 ACTION OkVldParam()
@ 90,168 BMPBUTTON TYPE 02 ACTION Close(oDlg08)

Activate Dialog oDlg08 Centered

Return

/*
_____________________________________________________________________________
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦Programa  ¦ OkVldParam    ¦ Autor ¦ Totvs          ¦ Data ¦ 02/04/2014 ¦¦¦
¦¦+----------+------------------------------------------------------------¦¦¦
¦¦¦Descriçào ¦ Validaçao para o Processamento da rotina de Contabilização ¦¦¦
¦¦¦          ¦                                                            ¦¦¦
¦¦+----------+------------------------------------------------------------¦¦¦
¦¦¦Uso       ¦ TOTVS - GO		                                          ¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯
*/
Static Function OkVldParam()
Local lRet := .T.

Pergunte(cPerg,.F.) //força criar parametros pelo grupo de perguntas

//setando valores dos parametros
dDtInici  := MV_PAR01
dDtFinal  := MV_PAR02
cFilDe    := MV_PAR03
cFilAte   := MV_PAR04
cLote     := MV_PAR05
lLancCtb  := iif(MV_PAR06==1,.T.,.F.) //1=Sim
lAglutina := iif(MV_PAR07==1,.T.,.F.) //1=Sim
nSepPor   := MV_PAR08
dDtRef    := dDtFinal
if lRet
	Processa({|| lRet := DoCtbRec() },"Processando...")
	iif(lRet, Close(oDlg08),)//fecha dlg
endif

Return lRet

/*
_____________________________________________________________________________
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦Programa  ¦ DoCtbRec      ¦ Autor ¦ Totvs          ¦ Data ¦ 29/04/2016 ¦¦¦
¦¦+----------+------------------------------------------------------------¦¦¦
¦¦¦Descriçào ¦ Faz o Processamento da rotina de Contabilização  	      ¦¦¦
¦¦¦          ¦                                                            ¦¦¦
¦¦+----------+------------------------------------------------------------¦¦¦
¦¦¦Uso       ¦ TOTVS - GO		                                          ¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯
*/
Static Function DoCtbRec()
Local _cSQL     := ""
Local _cSQL2    := ""
Local lRet      := .T.
Local lRet2     := .T.
Local nI
Local aFlagCTB  := {}
Local lLctPad40 := VerPadrao("140")
Local lLctPad41 := VerPadrao("141")
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Verifica o numero do Lote 									                 ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
Local cLoteCtb  := cLote
Local lUsaFlag  := GetNewPar("MV_CTBFLAG",.F.)
Local cPadrao   := "140"
Local cPadrao2  := "141"
Local c140
Local c141
Local aCT5      := {}
Local cArquivo  := ""
Local dDataSE5  := ctod("")
Local nTotalCtb := 0
Local nHdlPrv   := 0
Local lHeader   := .F.
Local oldDatabase := dDataBase //Salva a DataBase
Local _aEmp     := SM0->( GetArea() )
Local _cOldE    := cEmpAnt
Local _cOldF    := cFilAnt
Local _nregsm0  := SM0->(recno())
Private lDetProva := .T.

If !SE5->(FieldPos("E5_XORLA"))>0 .OR. !SE5->(FieldPos("E5_XDELA"))>0
	lUsaFlag:=.F.
endif

//Qry Origem
_cSQL := " SELECT *"
_cSQL += " FROM " + RetSqlName("SE5") + " SE5"
_cSQL += " WHERE E5_FILORIG BETWEEN '"+cFilDe+"' and '"+cFilAte+"'"
_cSQL += " AND SE5.D_E_L_E_T_ <> '*'" //nao deletados
If lUsaFlag
	_cSQL += " AND E5_XORLA != 'S'" //nao contabilizado
Endif
_cSQL += " AND E5_SITUACA<>'C' AND E5_FILORIG<>' ' AND E5_FILORIG<>E5_FILIAL " //somente entre filais
//_cSQL += " AND E5_MOTBX IN ('LIQ','CMP')  " //somente liquidações e compensações
_cSQL += " AND E5_DATA BETWEEN '"+Dtos(dDtInici)+"' and '"+Dtos(dDtFinal)+"'"
_cSQL += " ORDER BY E5_FILORIG, E5_DATA "
_cSQL := ChangeQuery(_cSQL) //comando para evitar erros de incompatibilidade de bancos

//Qry Destino
_cSQL2 := " SELECT *"
_cSQL2 += " FROM " + RetSqlName("SE5") + " SE5"
_cSQL2 += " WHERE E5_FILORIG BETWEEN '"+cFilDe+"' and '"+cFilAte+"'"
_cSQL2 += " AND SE5.D_E_L_E_T_ <> '*'" //nao deletados
If lUsaFlag
	_cSQL2 += " AND E5_XDELA != 'S'" //nao contabilizado
Endif
_cSQL2 += " AND E5_SITUACA<>'C' AND E5_FILORIG<>' ' AND E5_FILORIG<>E5_FILIAL " //somente entre filais
//_cSQL2 += " AND E5_MOTBX IN ('LIQ','CMP')  " //somente liquidações e compensações
_cSQL2 += " AND E5_DATA BETWEEN '"+Dtos(dDtInici)+"' and '"+Dtos(dDtFinal)+"'"
_cSQL2 += " ORDER BY E5_FILIAL, E5_DATA "
_cSQL2 := ChangeQuery(_cSQL2) //comando para evitar erros de incompatibilidade de bancos

if select("QRYSE5") > 0
	QRYSE5->(dbCloseArea())
endif

TcQuery _cSQL New Alias "QRYSE5" // Cria uma nova area com o resultado do query

TCSetField("QRYSE5","E5_DATA","D")

QRYSE5->(DbGoTop())

if QRYSE5->(EOF())
	lRet := .F.
endif

ProcRegua(QRYSE5->(RecCount()))

if lRet
	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Define as chaves de relacionamento SIGACTB
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If lLctPad40
		c140 := CtRelation(cPadrao,.F.,{{"QRYSE5","SE5"},{"QRYSE5","QRYSE5"},{"QRYSE5","RCTBM009"}})
	Endif
	
	While QRYSE5->(!EOF())
		cFilAnt := QRYSE5->E5_FILORIG
		
		//posiciones
		dbSelectArea("SM0")
		dbSeek(cEmpAnt+cFilAnt)
		
		if nSepPor == 2 //se por dia
			dDataSE5 := QRYSE5->E5_DATA
		else //se por periodo
			dDataSE5 := dDtRef
		endif
		
		While QRYSE5->(!EOF()) .and. cFilAnt == QRYSE5->E5_FILORIG
			
			IncProc("Processando movimentos " + QRYSE5->(E5_FILORIG+'-'+DTOC(E5_DATA)) + "...")
			
			//posiciones
			DbSelectArea("SA1")
			SA1->(DbSetOrder(1), DbGoTop(), DbSeek(xFilial('SA1')+QRYSE5->(E5_CLIFOR+E5_LOJA)))
			SED->(DbSetOrder(1), DbGoTop(), DbSeek(xFilial('SED')+QRYSE5->E5_NATUREZ))
			SE5->(DbGoto(QRYSE5->R_E_C_N_O_))
			
			if nSepPor == 2 .AND. dDataSE5 != QRYSE5->E5_DATA //se por dia
				dDatabase := dDataSE5
				//RodaProva
				RodaProva(nHdlPrv,nTotalCtb)
				If nTotalCtb > 0
					nTotalCtb := 0
					cA100Incl(cArquivo,nHdlPrv,1,cLoteCtb,lLancCtb,lAglutina,,,,@aFlagCTB)
				EndIf
				nTotalCtb := 0
				lHeader   := .F.
			endif
			
			If lUsaFlag
				aAdd(aFlagCTB,{"E5_XTORLA","S","SE5",SE5->(Recno()),0,0,0})
			EndIf
			
			//HeadProva
			If !lHeader
				nHdlPrv:=HeadProva(cLoteCtb,"RCTBM009",Substr(cUsuario,7,6),@cArquivo)
				
				If nHdlPrv <= 0
					HELP(" ",1,"SEM_LANC")
					lHeader := .F.
				Else
					lHeader := .T.
				EndIf
				
			EndIf
			
			If lHeader
				
				//DetProva
				lDetProva := .T.
				nParcCtb  := DetProva(nHdlPrv,cPadrao,"RCTBM009",cLoteCtb,,,,,@c140,@aCT5,,@aFlagCTB)
				nTotalCtb += nParcCtb
				
			Endif
			
			if nSepPor == 2 //se por dia
				dDataSE5 := QRYSE5->E5_DATA
			else //se por periodo
				dDataSE5 := dDtRef
			endif
			
			QRYSE5->(dbskip()) //proximo
		enddo
		
		if lHeader //RodaProva
			dDatabase := dDataSE5
			RodaProva(nHdlPrv,nTotalCtb)
			if nTotalCtb > 0
				nTotalCtb := 0
				cA100Incl(cArquivo,nHdlPrv,1,cLoteCtb,lLancCtb,lAglutina,,,,@aFlagCTB)
			endIf
		endif
		
	enddo
endif

//Analisa o destino

if select("QRYSE5") > 0
	QRYSE5->(dbCloseArea())
endif

TcQuery _cSQL2 New Alias "QRYSE5" // Cria uma nova area com o resultado do query

TCSetField("QRYSE5","E5_DATA","D")

QRYSE5->(DbGoTop())

if QRYSE5->(EOF())
    if !lRet
	  MSGInfo("Não foram encontrados movimentos para o processamento.","Contabilização")
	endif  
	lRet2 := .F.
endif

ProcRegua(QRYSE5->(RecCount()))

if lRet2

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Define as chaves de relacionamento SIGACTB
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If lLctPad41
		c141 := CtRelation(cPadrao,.F.,{{"QRYSE5","SE5"},{"QRYSE5","QRYSE5"},{"QRYSE5","RCTBM009"}})
	Endif
	
	While QRYSE5->(!EOF())
		cFilAnt := QRYSE5->E5_FILIAL
		
		//posiciones
		dbSelectArea("SM0")
		dbSeek(cEmpAnt+cFilAnt)
		
		if nSepPor == 2 //se por dia
			dDataSE5 := QRYSE5->E5_DATA
		else //se por periodo
			dDataSE5 := dDtRef
		endif
		
		While QRYSE5->(!EOF()) .and. cFilAnt == QRYSE5->E5_FILIAL
			
			IncProc("Processando movimentos " + QRYSE5->(E5_FILIAL+'-'+DTOC(E5_DATA)) + "...")
			
			//posiciones
			DbSelectArea("SA1")
			SA1->(DbSetOrder(1), DbGoTop(), DbSeek(xFilial('SA1')+QRYSE5->(E5_CLIFOR+E5_LOJA)))
			SED->(DbSetOrder(1), DbGoTop(), DbSeek(xFilial('SED')+QRYSE5->E5_NATUREZ))
			SE5->(DbGoto(QRYSE5->R_E_C_N_O_))
			
			if nSepPor == 2 .AND. dDataSE5 != QRYSE5->E5_DATA //se por dia
				dDatabase := dDataSE5
				//RodaProva
				RodaProva(nHdlPrv,nTotalCtb)
				If nTotalCtb > 0
					nTotalCtb := 0
					cA100Incl(cArquivo,nHdlPrv,1,cLoteCtb,lLancCtb,lAglutina,,,,@aFlagCTB)
				EndIf
				nTotalCtb := 0
				lHeader   := .F.
			endif
			
			If lUsaFlag
				aAdd(aFlagCTB,{"E5_XDELA","S","SE5",SE5->(Recno()),0,0,0})
			EndIf
			
			//HeadProva
			If !lHeader
				nHdlPrv:=HeadProva(cLoteCtb,"RCTBM009",Substr(cUsuario,7,6),@cArquivo)
				
				If nHdlPrv <= 0
					HELP(" ",1,"SEM_LANC")
					lHeader := .F.
				Else
					lHeader := .T.
				EndIf
				
			EndIf
			
			If lHeader
				
				//DetProva
				lDetProva := .T.
				nParcCtb  := DetProva(nHdlPrv,cPadrao2,"RCTBM009",cLoteCtb,,,,,@c141,@aCT5,,@aFlagCTB)
				nTotalCtb += nParcCtb
				
			Endif
			
			if nSepPor == 2 //se por dia
				dDataSE5 := QRYSE5->E5_DATA
			else //se por periodo
				dDataSE5 := dDtRef
			endif
			
			QRYSE5->(dbskip()) //proximo
		enddo
		
		if lHeader //RodaProva
			dDatabase := dDataSE5
			RodaProva(nHdlPrv,nTotalCtb)
			if nTotalCtb > 0
				nTotalCtb := 0
				cA100Incl(cArquivo,nHdlPrv,1,cLoteCtb,lLancCtb,lAglutina,,,,@aFlagCTB)
			endIf
		endif
		
	enddo
endif
if select("QRYSE5") > 0
	QRYSE5->(dbCloseArea())
endif


dDataBase := oldDatabase //Restaura a DataBase
//cEmpAnt   := _cOldE
cFilAnt   := _cOldF
SM0->( RestArea(_aEmp) )
//SM0->( dbgoto(_nregsm0) )
Return lRet

/*
_____________________________________________________________________________
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦Programa  ¦ AjustaSX1   ¦ Autor ¦ Totvs            ¦ Data ¦ 02/04/2014 ¦¦¦
¦¦+----------+------------------------------------------------------------¦¦¦
¦¦¦Descriçào ¦ Cria perguntas da rotina									  								¦¦¦
¦¦¦          ¦                                                            ¦¦¦
¦¦+----------+------------------------------------------------------------¦¦¦
¦¦¦Uso       ¦ TOTVS - GO		                                          ¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯
*/
Static Function AjustaSX1()

Local aHelpPor	:= {}
Local aHelpEng	:= {}
Local aHelpSpa	:= {}

u_xPutSx1( cPerg, "01","Data De ?","¿Fecha Ref ?","Ref. Date ?","mv_ch1","D",10,0,0,"G","","","","",;
"mv_par01","","","","","","","","","","","","","","","","",aHelpPor,aHelpEng,aHelpSpa)
u_xPutSx1( cPerg, "02","Data Ate?","¿Fecha Ref ?","Ref. Date ?","mv_ch2","D",10,0,0,"G","","","","",;
"mv_par02","","","","","","","","","","","","","","","","",aHelpPor,aHelpEng,aHelpSpa)
aHelpPor	:= {}
aHelpEng	:= {}
aHelpSpa	:= {}
Aadd(aHelpPor,"Informe a filial inicial a processar ")
Aadd(aHelpEng,"Enter a initial branch to process ")
Aadd(aHelpSpa,"Informe la sucursal inicial a procesar ")
u_xPutSx1( cPerg, "03","Filial Orig De  ?","®De Sucursal ?","From Branch ?","mv_ch2","C",TamSX3("E1_FILIAL")[1],0,0,"G","","SM0_01","","",;
"mv_par03","","","","","","","","","","","","","","","","",aHelpPor,aHelpEng,aHelpSpa)
aHelpPor	:= {}
aHelpEng	:= {}
aHelpSpa	:= {}
Aadd(aHelpPor,"Informe a filial final a processar ")
Aadd(aHelpEng,"Enter a final branch to process ")
Aadd(aHelpSpa,"Informe la sucursal final a procesar ")
u_xPutSx1( cPerg, "04","Filial Orig Ate ?","®A Sucursal  ?","To Branch   ?","mv_ch4","C",TamSX3("E1_FILIAL")[1],0,0,"G","","SM0_01","","",;
"mv_par04","","","","","","","","","","","","","","","","",aHelpPor,aHelpEng,aHelpSpa)
u_xPutSx1( cPerg, "05","Lote","Lote","Lote","mv_ch5","C",6,0,0,"G","","","","",;
"mv_par05","","","","000140","","","","","","","","","","","","",aHelpPor,aHelpEng,aHelpSpa)
u_xPutSx1( cPerg, "06","Mostra Lanç Contab ?","¿Muestra Asientos ?","Display Acc. Entry ?","mv_ch6","N",1,0,0,"C","","","","",;
"mv_par06","Sim","Si","Yes","Não","Não","No","No","","","","","","","","","",aHelpPor,aHelpEng,aHelpSpa)
u_xPutSx1( cPerg, "07","Aglut. Lancamentos ?","¿Agrupa Asientos ?","Group Entries ?","mv_ch7","N",1,0,0,"C","","","","",;
"mv_par07","Sim","Si","Yes","Não","Não","No","No","","","","","","","","","",aHelpPor,aHelpEng,aHelpSpa)
u_xPutSx1( cPerg, "08","Gera Lanc. Por ?","¿Genera Asiento Por ?","Generate Entry by ?","mv_ch8","N",1,0,0,"C","","","","",;
"mv_par08","Periodo","Periodo","Period","Periodo","Dia","Dia","Day","","","","","","","","","",aHelpPor,aHelpEng,aHelpSpa)
Return
