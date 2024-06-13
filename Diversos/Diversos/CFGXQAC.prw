#include "protheus.ch"
#INCLUDE 'totvs.ch' 
#include 'topconn.ch'
Static aAlias := {}, aFiles := {}
Static lBreakError := .F.

//FABRICIO AMARO - TOTVS OP - 06/06/2017
//QUERY ANALIZER CASEIRO - PERMITE EXECUÇÃO DE SCRIPS SQL COMO UPDATE, DELETE E INSERT
// -------------------------------------
User Function CFGXQAC( uParm )
Local oBanner
Local nI
//Local cSvMsgRec := oMsgRec:cMsg
//Local cSvMsgRdd	:= oMsgRdd:cMsg
//Local cSvMsgSts	:= oMsgSts:cMsg
Local oError	:= ErrorBlock({|e| ApQryError(e,@cError,@lError)})
Local oJanela

#IFNDEF TOP
	Return ApMsgInfo("Opção disponível somente para ambiente TOPConnect.","Atenção") //###
#ENDIF

Private oDlgQry
Private oMsgIt1
Private oMsgIt2
Private oMsgIt3
Private oMsgIt4
Private __aConnections := {}
Private __aServers := {}
Private __aQuery := {}
Private __nConnect
Private __nQuery
Private __cQuery := ""
Private __oQuery
Private __lChangeQuery := .T.
Private __nBuffer := 40
Private oPanelClose
Private oPanelResult
Private cError := ""
Private lError := .F.

Private _lScrManu := .F.


Public __LocalDriver    := "DBFCDX"
Public cUserId
Public cUserName

//oMsgRec:SetText(' ')
//oMsgRdd:SetText(' ')
//oMsgSts:SetText(' ')

//oMsgIt2 := oMsgRec
//oMsgIt3	:= oMsgRdd
//oMsgIt4 := oMsgSts

//If oApp:oFlatWnd != NIL
//	oJanela:=oApp:oFlatWnd
//Else
	oJanela := oApp:oMainWnd
//EndIf                                                                                                    

DEFINE MSDIALOG oDlgQry TITLE 'ApQA - Protheus ' + Subs(GetADV97(), 3, 1) + ' Query Analyzer' OF oJanela PIXEL;
	FROM oJanela:nTop+22, oJanela:nLeft TO oJanela:nBottom-58, oJanela:nRight-10 STYLE nOR(WS_VISIBLE,WS_POPUP)

oDlgQry:Owner():lEscClose:= .F. // desabilita o fechamento por ESC da tela

@000,000 BITMAP oBanner RESNAME "FAIXASUPERIOR4" SIZE 1200,040 NOBORDER PIXEL
oBanner:align:= CONTROL_ALIGN_TOP
oBanner:lStretch := .F.

ACTIVATE MSDIALOG oDlgQry ON INIT (If(ApQrySConnect(),ApQryRunEnv(),oDlgQry:End()))

For nI:=1 To Len(__aConnections)
	TcUnLink(__aConnections[nI])
Next nI

//oMsgRec:SetText(cSvMsgRec)
//oMsgRdd:SetText(cSvMsgRdd)
//oMsgSts:SetText(cSvMsgSts)
ErrorBlock(oError)
Return

// -------------------------------------
Static Function ApQryConnect(cDatabase,cServer,oConnect, nPort)
Local nConnect
Local nAt
Local lConnect

cDatabase := AllTrim(cDatabase)
cServer	  := AllTrim(cServer)

nAt := Ascan(__aServers,cServer+"/"+cDatabase)
If nAt > 0
	nConnect := __aConnections[nAt][1]
	__nQuery := nAt
Else	
	nConnect := TcLink(cDatabase,cServer, nPort)
	If nConnect > -1
		Aadd( __aConnections, nConnect)
		Aadd( __aServers,cServer+"/"+cDatabase)
		__nQuery := Len(__aConnections)
	Else
		ApMsgAlert("Atenção","Connect")
		Return .F.
	EndIf
EndIf
__nConnect := nConnect
lConnect := TcSetConn(__nConnect)
If lConnect 
	//oMsgIt3:SetText(cDatabase)
	//oMsgIt4:SetText(cServer)
	If oConnect <> Nil .And. oConnect:nAt > 0
		__aQuery[oConnect:nAt][2] := __cQuery
	EndIf
	Aadd(__aQuery,{__nConnect,""})
	__cQuery := ""
	If __oQuery <> Nil
		__oQuery:Refresh()
	EndIf
EndIf
Return lConnect


// -------------------------------------
Static Function ApQryRunEnv()
Local oToolBar
Local oPanel
Local oSep
Local oDum
Local aButtons  := {}
Local nCol		:= -14
Local cList

__nQuery := 1

oDlgQry:ReadClientCoors()

@ 000, 000 MSPANEL oToolBar OF oDlgQry SIZE __DlgWidth(oDlgQry), 014 RAISED
oToolBar:Align := CONTROL_ALIGN_TOP

@ 001,002 BITMAP oSep RESNAME "BMPSEP2" SIZE 6,11 OF oToolBar NOBORDER PIXEL

Aadd( aButtons, TBtnBmp2():New( 001, nCol+=26, 25, 25, "RPMNEW2"	,,,, {|| oDum:SetFocus(), ApQryNewQry()}, oToolBar, "New...", {|| __nQuery<>0},,))
Aadd( aButtons, TBtnBmp2():New( 001, nCol+=26, 25, 25, "RPMOPEN"	,,,, {|| oDum:SetFocus(), ApQryOpenQry()}, oToolBar, "Open...", {|| __nQuery<>0},,)) //
Aadd( aButtons, TBtnBmp2():New( 001, nCol+=26, 25, 25, "SALVAR"	,,,, {|| ApQrySvQry()}, oToolBar, "Save...", {|| __nQuery<>0},,)) //"
Aadd( aButtons, TBtnBmp2():New( 001, nCol+=26, 25, 25, "NEXT"		,,,, {|| oDum:SetFocus(), ApQryRun()}, oToolBar, "Run...", {|| __nQuery<>0},,)) //

@ 001,060 BITMAP oSep RESNAME "BMPSEP2" SIZE 6,11 OF oToolBar NOBORDER PIXEL

Aadd( aButtons, TBtnBmp2():New( 001, nCol+=40, 25, 25, "PMSRELA"	,,,, {|| ApQrySConnect(aButtons[7],aButtons)}, oToolBar, "Connect as...", {|| .T.},,)) //
Aadd( aButtons, TBtnBmp2():New( 001, nCol+=26, 25, 25, "NOCONNECT"	,,,, {|| ApQryDisconnect(aButtons[7])}, oToolBar, "Disconnect...", {|| __nQuery<>0},,)) //
Aadd( aButtons, TComboBox():New( 001, 095, bSETGET(cList),__aServers, 150, 009, oToolBar,,{|| ApQrySetConn(aButtons[7]:nAt)},,,, .T.,,,,{|| __nQuery<>0},,,))
Aadd( aButtons, TCheckBox():New( 001, __DlgWidth(oToolBar)-50, 'Change Query', bSETGET(__lChangeQuery), oToolBar, 050, 009,,,,,,,, .T.,,,)) //
Aadd( aButtons, TCheckBox():New( 001, __DlgWidth(oToolBar)-200, 'Script(s) para Manutenção(ões)', bSETGET(_lScrManu), oToolBar, 150, 009,,,,,,,, .T.,,,)) 

@ 002,260 SAY "Buffer de Leitura" OF oToolBar PIXEL //
Aadd( aButtons, TGet():New( 001, 305, bSETGET(__nBuffer), oToolBar, 025, 008, "9999999999",,,,,,, .T.,,, {|| __nQuery<>0},,.T.,,,,,))

@ 001,350 BITMAP oSep RESNAME "BMPSEP2" SIZE 6,11 OF oToolBar NOBORDER PIXEL

Aadd( aButtons, TBtnBmp2():New( 001, nCol+=555, 25, 25, "FINAL"		,,,, {|| ApQryCloseQry(aAlias,aFiles), oDlgQry:End()}, oToolBar, "Exit...", {|| .T.},,)) //

@ 000, 000 MSPANEL oPanel OF oDlgQry SIZE __DlgWidth(oDlgQry)-2, __DlgHeight(oDlgQry) RAISED
oPanel:Align := CONTROL_ALIGN_ALLCLIENT

@ -100,000 BUTTON oDum PROMPT "ZE" SIZE 050,010 OF oPanel PIXEL
oDum:bGotFocus := {|| __oQuery:SetFocus()}

@ 001,001 GET __oQuery VAR __cQuery MULTILINE OF oPanel SIZE __DlgWidth(oPanel), __DlgHeight(oPanel) PIXEL
__oQuery:Align := CONTROL_ALIGN_ALLCLIENT

@ 000, 000 MSPANEL oPanelClose OF oDlgQry SIZE 200, 010 RAISED;
	COLOR CLR_GRAY,CLR_GRAY

@ 000, 000 MSPANEL oPanelResult OF oDlgQry SIZE __DlgWidth(oDlgQry)-2, __DlgHeight(oDlgQry)/2 RAISED;
	COLOR CLR_GRAY,CLR_GRAY
oPanelResult:Align := CONTROL_ALIGN_BOTTOM
oPanelClose:Align := CONTROL_ALIGN_BOTTOM
oPanelClose:Hide()
oPanelResult:Hide()
Return

// -------------------------------------
Static Function ApQryRun()
//Local oDlg
Local oPanel
Local oBrowse	:= {}
Local oTabs
//Local oError	:= ErrorBlock({|e| ApQryError(e,@cError,@lError)})
Local oTime
Local oClose
Local nTop
Local nBottom
Local nRight
Local nI            
Local nX
Local nCount	:= 1
Local nSec1
Local nSec2
Local aQuerys	:= {}
Local aError	:= {}
Local cQuery
Local cTime		:= "00:00:00"
Local bSETGET
Local aStruct
Local aFieldEsp := {}
Local _nStatus := 0

If Empty(__cQuery)
	Return
EndIf

If __nBuffer < 40
	ApMsgAlert("O Buffer especificado deve ser maior ou igual a 40!","Atenção") //###
	Return
EndIf

Aadd(aFieldEsp,{"D_E_L_E_T_"	,"C", 1,0})

cQuery  := StrTran(__cQuery,CRLF," ") + ";"
aQuerys := StrTokArr(cQuery,";")

oDlgQry:ReadClientCoors()

nTop	:= oDlgQry:nClientHeight/3+145
nBottom	:= oDlgQry:nClientHeight - 4
nRight  := oDlgQry:nClientWidth - 4

ApQryCloseQry(aAlias,aFiles)

oPanelClose:Show()
oPanelResult:Show()

//DEFINE MSDIALOG oDlg FROM nTop,000 TO nBottom,nRight PIXEL STYLE nOR(WS_VISIBLE,WS_POPUP)

@ 000, 000.5 MSPANEL oPanel OF oPanelResult SIZE __DlgWidth(oPanelResult)-5, __DlgHeight(oPanelResult)-1 RAISED

@ 000.5,__DlgWidth(oPanelResult)-68 SAY "Run Time : " SIZE 030,009 OF oPanel PIXEL //
@ 000.5,__DlgWidth(oPanelResult)-42 SAY oTime VAR cTime SIZE 024,011 OF oPanel PIXEL
@ 004,oPanel:nWidth-10 BTNBMP oClose RESOURCE "XCLOSE" SIZE 018, 014 ACTION ApQryCloseQry(aAlias,aFiles) OF oPanelClose ADJUST

For nI:=1 To Len(aQuerys)
	cQuery := AllTrim(aQuerys[nI])
	
	If !_lScrManu
		If __lChangeQuery
			Begin Sequence
			lBreakError := .T.
			cQuery := ChangeQuery(cQuery)
			End Sequence
			lBreakError := .F.
		EndIf
		If !Empty(cQuery)
			Aadd( aAlias, "QRY"+StrZero(nCount,3) )
			If !lError
				nSec1 := Seconds()
				Begin Sequence
				lBreakError := .T.
				dbUseArea( .T., "TOPCONN", TCGenQry(,,cQuery), aAlias[nCount], .F., .F. )
				End Sequence
				lBreakError := .F.
				nSec2 := Seconds()
			EndIf
			If lError
				Aadd( aError, cError )
				bSETGET := &("{|U| If( PCount() == 0, aError["+Str(Len(aError))+"], aError["+Str(Len(aError))+"] := U ) }")
				Aadd( oBrowse, TMultiGet():New( 8, 3, bSETGET, oPanel, __DlgWidth(oPanelResult)-10, __DlgHeight(oPanelResult)-23,,,,,, .T.,,,,,, .T.,,,,, ) )
				lError := .F.
			Else
				
				aStruct := (aAlias[nCount])->(dbStruct())
				
				For nX:=1 To Len(aFieldEsp)
					If (aAlias[nCount])->(FieldPos(aFieldEsp[nX][1])) > 0
						Aadd(aStruct,aFieldEsp[nX])
					EndIf
				Next nX
				
				Aadd( aFiles, CriaTrab(aStruct) )
				dbUseArea( .T., "DBFCDX", aFiles[Len(aFiles)], aFiles[Len(aFiles)], .F., .F. )
				
				Aadd( oBrowse, MsBrGetDBase():New( 8, 3, __DlgWidth(oPanelResult)-10, __DlgHeight(oPanelResult)-23,,,, oPanelResult,,,,,,,,,,,, .F., aFiles[Len(aFiles)], .T.,, .F.,,,) )
				For nX:=1 To (aFiles[Len(aFiles)])->(FCount())
					oBrowse[nCount]:AddColumn( TCColumn():New( (aFiles[Len(aFiles)])->(FieldName(nX)), &("{ || "+aFiles[Len(aFiles)]+"->"+(aFiles[Len(aFiles)])->(FieldName(nX))+"}"),,,,,"LEFT") )
				Next nX
				
				ApQryPutInFile(aAlias[nCount],aFiles[Len(aFiles)])
				
				oBrowse[nCount]:lColDrag	:= .T.
				oBrowse[nCount]:lLineDrag	:= .T.
				oBrowse[nCount]:lJustific	:= .T.
				oBrowse[nCount]:nColPos		:= 1
				oBrowse[nCount]:Cargo		:= {|| __NullEditcoll()}
				oBrowse[nCount]:bSkip		:= &("{|N| ApQryPutInFile('"+aAlias[nCount]+"','"+aFiles[Len(aFiles)]+"',N), "+aFiles[Len(aFiles)]+"->(_DBSKIPPER(N))}")
				oBrowse[nCount]:cCaption	:= APSec2Time(nSec2-nSec1)
			EndIf
			oBrowse[nCount]:Hide()
			If oTabs == Nil
				@ __DlgHeight(oPanelResult)-15,3 TABS oTabs PROMPT "Query # "+AllTrim(Str(nCount)) OF oPanel PIXEL SIZE __DlgWidth(oPanelResult)-11,10;
					ACTION ( ApQrySetTabs(oTabs:nOption,oBrowse,oTime))
			Else
				oTabs:AddItem("Query # "+AllTrim(Str(nCount)))
			EndIf
			nCount += 1
		EndIf
	Else
		_nStatus := TCSqlExec(cQuery)
   
		If _nStatus != 0
			MsgStop("Erro ao executar a query abaixo:" + Chr(13) + Chr(10) + cQuery + Chr(13) + Chr(10) +Chr(13) + Chr(10) +;
						"Descrição do erro:" + Chr(13) + Chr(10) + TCSQLError())
		Else
			MsgInfo("A query abaixo foi executada com sucesso: "+ Chr(13) + Chr(10) + cQuery)
		EndIf
	EndIf
Next nI

If !_lScrManu
	oTabs:SetOption(1)
EndIf

//ACTIVATE MSDIALOG oDlg

//ErrorBlock(oError)
Return

// -------------------------------------
Static Function ApQrySetTabs(nOption,oBrowse,oTime)
Local nI
For nI:=1 To Len(oBrowse)
	If ( nI == nOption )
		oBrowse[nI]:Show()
		oTime:SetText(oBrowse[nI]:cCaption)
	Else
		oBrowse[nI]:Hide()
	EndIf
Next nI
Return

// -------------------------------------
Static Function ApQryError(e,cError,lError)
cError := e:Description
lError := .T.
If !lBreakError
	Return "DEFAULTERRORPROC"
EndIf
Break
Return
/*
// -------------------------------------
Function APSec2Time(nTime,nStr)
Local nHour
Local nMinute
Local nSecond
Local cTime
Local nTemp

DEFAULT nTime := 0
DEFAULT nStr := 2

nTemp := Int(nTime/60)

nHour := Int(nTemp/60)

nMinute := nTemp - (nHour*60)

nSecond := nTime - ((nHour*3600)+(nMinute*60))

cTime := StrZero(nHour,nStr,0)+":"+StrZero(nMinute,2,0)+":"+StrZero(nSecond,2,0)

Return cTime

// -------------------------------------
Function APTime2Sec(cTime)
Local nHour
Local nMinute
Local nSecond
Local nTime

DEFAULT cTime := "00:00:00"

nHour := Val(Subs(cTime,1,2))

nMinute := Val(Subs(cTime,4,2))

nSecond := Val(Subs(cTime,7,2))

nTime := (nHour*3600)+(nMinute*60)+nSecond

Return nTime
*/

// -------------------------------------
Static Function ApQrySConnect(oConnect,aButtons)
Local oDlg
Local oOk
Local oCancel
Local oServer
Local oDatabase
Local cServer	:= Space(50)
Local cDatabase	:= Space(50)
Local cAlias
Local cIniFile	:= GetADV97()
Local lReturn := .F.                                  
Local oPort
Local nPort := 0

// Implementação TotvsDBAccess
cDataBase := GetPvProfString("TotvsDBAccess","DataBase","ERROR",cInIfile )
cAlias	  := GetPvProfString("TotvsDBAccess","Alias","ERROR",cInIfile )
cServer	  := GetPvProfString("TotvsDBAccess","Server","ERROR",cInIfile )
nPort     := Val(GetPvProfString("TotvsDBAccess","Port","",cInIfile ))

cDataBase := GetSrvProfString("DBDataBase",cDatabase)
cAlias	  := GetSrvProfString("DBAlias",cAlias)
cServer	  := GetSrvProfString("DBServer",cServer)
nPort     := Val(GetSrvProfString("DBPort",Str(nPort)))

If ( cDataBase == "ERROR" .And. cAlias == "ERROR" )

	cDataBase := GetPvProfString("TopConnect","DataBase","ERROR",cInIfile )
	cAlias	  := GetPvProfString("TopConnect","Alias","ERROR",cInIfile )
	cServer	  := GetPvProfString("TopConnect","Server","ERROR",cInIfile )
	nPort     := Val(GetPvProfString("TopConnect","Port","",cInIfile ))
	
	// Ajuste pelo Environment do Server
	cDataBase := GetSrvProfString("TopDataBase",cDatabase)
	cAlias	  := GetSrvProfString("TopAlias",cAlias)
	cServer	  := GetSrvProfString("TopServer",cServer)
	nPort     := Val(GetSrvProfString("TopPort",Str(nPort)))
	
EndIf

cDatabase += "/" + cAlias
cDatabase := Padr(cDatabase,50)
cServer	  := Padr(cServer,50)
If nPort == 0
	nPort := 7890
EndIf

DEFINE MSDIALOG oDlg FROM 000,000 TO 170,316 PIXEL TITLE "Connect as..." //"

@ 003,005 SAY "Server" SIZE 060,007 OF oDlg PIXEL

@ 012,005 GET oServer VAR cServer PICTURE "@!" SIZE 150,009 PIXEL

@ 024,005 SAY "DBMS/Data Base" SIZE 060,007 OF oDlg PIXEL

@ 033,005 GET oDatabase VAR cDatabase PICTURE "@!" SIZE 150,009 OF oDlg PIXEL

@ 045,005 SAY "Port" SIZE 060,007 OF oDlg PIXEL

@ 054,005 GET oPort VAR nPort SIZE 150,009 OF oDlg PIXEL

DEFINE SBUTTON oOk FROM 070,097 TYPE 1 ENABLE OF oDlg PIXEL;
	WHEN (!Empty(cServer) .And. !Empty(cDatabase));
	ACTION (If(lReturn:=ApQryConnect(cDatabase,cServer,oConnect, nPort),(If(oConnect<>Nil,(oConnect:SetItems(__aServers),oConnect:nAt:=__nQuery,oConnect:Refresh(),oConnect:nAt:=Len(__aServers)),),oDlg:End()),))

DEFINE SBUTTON oCancel FROM 070,127 TYPE 2 ENABLE OF oDlg PIXEL;
	ACTION ( oDlg:End(), lReturn:=.F.)

ACTIVATE MSDIALOG oDlg CENTERED

Return lReturn

// -------------------------------------
Static Function ApQrySetConn(nAt)
Local cDataBase
Local cServer
Local nQ

If nAt == 0
	If Len(__aConnections) == 0
		__nQuery	:= nAt
		//oMsgIt3:SetText("")
		//oMsgIt4:SetText("")
	Else
		__nQuery	:= 1
		__cQuery	:= __aQuery[1][2]
		__oQuery:Refresh()
		__nQuery	:= 1
		__nConnect	:= __aConnections[1]
		cServer		:= Subs(__aServers[1],1,At("/",__aServers[1])-1)
		cDataBase	:= Subs(__aServers[1],At("/",__aServers[1])+1)
		cServer		:= Subs(__aServers[1],1,At("/",__aServers[1])-1)
		cDataBase	:= Subs(__aServers[1],At("/",__aServers[1])+1)
		//oMsgIt3:SetText(cDatabase)
		//oMsgIt4:SetText(cServer)
	EndIf
Else
	If TcSetConn(__aConnections[nAt])
		nQ := Ascan(__aQuery,{|x| x[1]==__nConnect})
		If nQ > 0
			__aQuery[nQ][2] := __cQuery
		EndIf
		__cQuery	:= __aQuery[nAt][2]
		__oQuery:Refresh()
		__nQuery	:= nAt
		__nConnect	:= __aConnections[nAt]
		cServer		:= Subs(__aServers[nAt],1,At("/",__aServers[nAt])-1)
		cDataBase	:= Subs(__aServers[nAt],At("/",__aServers[nAt])+1)
//		oMsgIt3:SetText(cDatabase)
//		oMsgIt4:SetText(cServer)
	EndIf
EndIf
Return

// -------------------------------------
Static Function ApQryDisconnect(oConnect,aButtons)
Local nAt := oConnect:nAt
Local cDatabase
Local cServer

If nAt <= Len(__aConnections)
	TCUnLink(__aConnections[nAt])
	Adel(__aConnections,nAt)
	Adel(__aServers,nAt)
	ASize(__aConnections,Len(__aConnections)-1)
	ASize(__aServers,Len(__aServers)-1)
	
	nAt := Len(__aServers)
	If nAt > 0
		oConnect:nAt := nAt
		TcSetConn(__aConnections[nAt])
		cServer		:= Subs(__aServers[nAt],1,At("/",__aServers[nAt])-1)
		cDataBase	:= Subs(__aServers[nAt],At("/",__aServers[nAt])+1)
//		oMsgIt3:SetText(cDatabase)
//		oMsgIt4:SetText(cServer)
	Else
//		oMsgIt3:SetText("")
//		oMsgIt4:SetText("")
	EndIf
	
	oConnect:SetItems(__aServers)
	oConnect:Refresh()
EndIf
Return


// -------------------------------------
Static Function ApQryPutInFile(cSource,cTarget,n)
Local nX
Local nI		:= 1
Local nRecno	:= (cTarget)->(Recno())
Local aFields
Local nFields

Default n := __nBuffer

If (cSource)->(Eof()) .Or. !( n > 0 .And. ( n+(cTarget)->(Recno()) > (cTarget)->(RecCount())-__nBuffer ) )
	Return
EndIf

aFields := (cTarget)->(dbStruct())
nFields := Len(aFields)

While (cSource)->(!Eof()) .And. nI <= __nBuffer
	(cTarget)->(dbAppend())
	For nX:=1 To nFields
		If aFields[nX][2] == "N"
			(cTarget)->(fieldput(nX,val(str((cSource)->(Fieldget(nX)),aFields[nX][3],aFields[nX][4]))))
		Else
			(cTarget)->(FieldPut(nX,(cSource)->&(aFields[nX][1])))
		EndIf
	Next nX
	nI += 1
	(cSource)->(dbSkip())
End
(cTarget)->(dbCommit())
(cTarget)->(dbGoto(nRecno))
Return

// -------------------------------------
Static Function ApQryOpenQry()
Local cFile
Local cBuffer
Local nLength
Local nHdl

cFile := cGetFile('Protheus Query Analyzer |*.APQ |SQL Query Analyzer |*.SQL |All Files|*.*','Open File',,,.T.,GETF_ONLYSERVER) //
If Empty(cFile)
	Return
EndIf

If At(".",cFile) == 0
	cFile += ".APQ"
EndIf

nHdl := FOpen(cFile,0)
If nHdl < 0
	ApMsgAlert("Falha na leitura do arquivo "+cFile ) //
	Return
EndIf

nLength := FSeek(nHdl,0,2)
cBuffer := Space(nLength)
FSeek(nHdl,0)
FRead(nHdl,@cBuffer,nLength)
FClose(nHdl)
__cQuery := cBuffer
__oQuery:Refresh()
Return

// -------------------------------------
Static Function ApQrySvQry()
Local cFile
Local nHdl

cFile := cGetFile('Protheus Query Analyzer |*.APQ |SQL Query Analyzer |*.SQL |All Files|*.*','Save File',,,.F.,GETF_ONLYSERVER) //
If Empty(cFile)
	Return
EndIf
If At(".",cFile) == 0
	cFile += ".APQ"
EndIf

If File(cFile) 
	If ApMsgYesNo("Sobrescrever o arquivo existente?","Atenção") //###
		FErase(cFile)
	Else 
		Return
	EndIf
EndIf

nHdl := FCreate(cFile,0)
If nHdl < 0
	ApMsgAlert("Falha na gravação do arquivo "+cFile ) //
	Return
EndIf
FWrite(nHdl,__cQuery)
FClose(nHdl)
Return

// -------------------------------------
Static Function ApQryNewQry()
If !Empty(__cQuery) .And. ApMsgYesNo("Salvar script corrente?","Atenção") //###
	ApQrySvQry()
EndIf
__cQuery := ""
__oQuery:Refresh()
Return

// -------------------------------------
Static Function __NullEditcoll()
Return

// -------------------------------------
Static Function ApQryCloseQry(aAlias,aFiles)
Local nI

oPanelClose:Hide()
oPanelResult:Hide()
oPanelResult:FreeChildren()

For nI:=1 To Len(aAlias)
	If Select(aAlias[nI]) > 0
		(aAlias[nI])->(dbCloseArea())
	EndIf
Next nI
For nI:=1 To Len(aFiles)
	(aFiles[nI])->(dbCloseArea())
	FErase(aFiles[nI]+GetDbExtension())
Next nI
aAlias := {}
aFiles := {}
Return
