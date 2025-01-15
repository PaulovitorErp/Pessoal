#INCLUDE "protheus.ch"
#INCLUDE "apwebsrv.ch"

/* ===============================================================================
WSDL Location    http://localhost:8085/WS_ESCOLA.apw?WSDL
Gerado em        04/12/18 10:38:12
Observações      Código-Fonte gerado por ADVPL WSDL Client 1.120703
                 Alterações neste arquivo podem causar funcionamento incorreto
                 e serão perdidas caso o código-fonte seja gerado novamente.
=============================================================================== */

User Function _KLTMQOO ; Return  // "dummy" function - Internal Use 

/* -------------------------------------------------------------------------------
WSDL Service WSWS_ESCOLA
------------------------------------------------------------------------------- */

WSCLIENT WSWS_ESCOLA

	WSMETHOD NEW
	WSMETHOD INIT
	WSMETHOD RESET
	WSMETHOD CLONE
	WSMETHOD CAD_ALUNO
	WSMETHOD CONS_ALUNO
	WSMETHOD TESTE

	WSDATA   _URL                      AS String
	WSDATA   _HEADOUT                  AS Array of String
	WSDATA   _COOKIES                  AS Array of String
	WSDATA   oWSENV_CADALUNO           AS WS_ESCOLA_WSENVCADALUNO
	WSDATA   oWSCAD_ALUNORESULT        AS WS_ESCOLA_WSRECCADALUNO
	WSDATA   oWSENV_DADOSALUNO         AS WS_ESCOLA_WSENVDADOSALUNO
	WSDATA   oWSCONS_ALUNORESULT       AS WS_ESCOLA_WSRETDADOSALUNO
	WSDATA   cCRECEBE                  AS string
	WSDATA   cTESTERESULT              AS string

	// Estruturas mantidas por compatibilidade - NÃO USAR
	WSDATA   oWSWSENVCADALUNO          AS WS_ESCOLA_WSENVCADALUNO
	WSDATA   oWSWSENVDADOSALUNO        AS WS_ESCOLA_WSENVDADOSALUNO

ENDWSCLIENT

WSMETHOD NEW WSCLIENT WSWS_ESCOLA
::Init()
If !FindFunction("XMLCHILDEX")
	UserException("O Código-Fonte Client atual requer os executáveis do Protheus Build [7.00.131227A-20180328 NG] ou superior. Atualize o Protheus ou gere o Código-Fonte novamente utilizando o Build atual.")
EndIf
Return Self

WSMETHOD INIT WSCLIENT WSWS_ESCOLA
	::oWSENV_CADALUNO    := WS_ESCOLA_WSENVCADALUNO():New()
	::oWSCAD_ALUNORESULT := WS_ESCOLA_WSRECCADALUNO():New()
	::oWSENV_DADOSALUNO  := WS_ESCOLA_WSENVDADOSALUNO():New()
	::oWSCONS_ALUNORESULT := WS_ESCOLA_WSRETDADOSALUNO():New()

	// Estruturas mantidas por compatibilidade - NÃO USAR
	::oWSWSENVCADALUNO   := ::oWSENV_CADALUNO
	::oWSWSENVDADOSALUNO := ::oWSENV_DADOSALUNO
Return

WSMETHOD RESET WSCLIENT WSWS_ESCOLA
	::oWSENV_CADALUNO    := NIL 
	::oWSCAD_ALUNORESULT := NIL 
	::oWSENV_DADOSALUNO  := NIL 
	::oWSCONS_ALUNORESULT := NIL 
	::cCRECEBE           := NIL 
	::cTESTERESULT       := NIL 

	// Estruturas mantidas por compatibilidade - NÃO USAR
	::oWSWSENVCADALUNO   := NIL
	::oWSWSENVDADOSALUNO := NIL
	::Init()
Return

WSMETHOD CLONE WSCLIENT WSWS_ESCOLA
Local oClone := WSWS_ESCOLA():New()
	oClone:_URL          := ::_URL 
	oClone:oWSENV_CADALUNO :=  IIF(::oWSENV_CADALUNO = NIL , NIL ,::oWSENV_CADALUNO:Clone() )
	oClone:oWSCAD_ALUNORESULT :=  IIF(::oWSCAD_ALUNORESULT = NIL , NIL ,::oWSCAD_ALUNORESULT:Clone() )
	oClone:oWSENV_DADOSALUNO :=  IIF(::oWSENV_DADOSALUNO = NIL , NIL ,::oWSENV_DADOSALUNO:Clone() )
	oClone:oWSCONS_ALUNORESULT :=  IIF(::oWSCONS_ALUNORESULT = NIL , NIL ,::oWSCONS_ALUNORESULT:Clone() )
	oClone:cCRECEBE      := ::cCRECEBE
	oClone:cTESTERESULT  := ::cTESTERESULT

	// Estruturas mantidas por compatibilidade - NÃO USAR
	oClone:oWSWSENVCADALUNO := oClone:oWSENV_CADALUNO
	oClone:oWSWSENVDADOSALUNO := oClone:oWSENV_DADOSALUNO
Return oClone

// WSDL Method CAD_ALUNO of Service WSWS_ESCOLA

WSMETHOD CAD_ALUNO WSSEND oWSENV_CADALUNO WSRECEIVE oWSCAD_ALUNORESULT WSCLIENT WSWS_ESCOLA
Local cSoap := "" , oXmlRet

BEGIN WSMETHOD

cSoap += '<CAD_ALUNO xmlns="http://localhost:8085/">'
cSoap += WSSoapValue("ENV_CADALUNO", ::oWSENV_CADALUNO, oWSENV_CADALUNO , "WSENVCADALUNO", .T. , .F., 0 , NIL, .F.,.F.) 
cSoap += "</CAD_ALUNO>"

oXmlRet := SvcSoapCall(	Self,cSoap,; 
	"http://localhost:8085/CAD_ALUNO",; 
	"DOCUMENT","http://localhost:8085/",,"1.031217",; 
	"http://localhost:8085/WS_ESCOLA.apw")

::Init()
::oWSCAD_ALUNORESULT:SoapRecv( WSAdvValue( oXmlRet,"_CAD_ALUNORESPONSE:_CAD_ALUNORESULT","WSRECCADALUNO",NIL,NIL,NIL,NIL,NIL,NIL) )

END WSMETHOD

oXmlRet := NIL
Return .T.

// WSDL Method CONS_ALUNO of Service WSWS_ESCOLA

WSMETHOD CONS_ALUNO WSSEND oWSENV_DADOSALUNO WSRECEIVE oWSCONS_ALUNORESULT WSCLIENT WSWS_ESCOLA
Local cSoap := "" , oXmlRet

BEGIN WSMETHOD

cSoap += '<CONS_ALUNO xmlns="http://localhost:8085/">'
cSoap += WSSoapValue("ENV_DADOSALUNO", ::oWSENV_DADOSALUNO, oWSENV_DADOSALUNO , "WSENVDADOSALUNO", .T. , .F., 0 , NIL, .F.,.F.) 
cSoap += "</CONS_ALUNO>"

oXmlRet := SvcSoapCall(	Self,cSoap,; 
	"http://localhost:8085/CONS_ALUNO",; 
	"DOCUMENT","http://localhost:8085/",,"1.031217",; 
	"http://localhost:8085/WS_ESCOLA.apw")

::Init()
::oWSCONS_ALUNORESULT:SoapRecv( WSAdvValue( oXmlRet,"_CONS_ALUNORESPONSE:_CONS_ALUNORESULT","WSRETDADOSALUNO",NIL,NIL,NIL,NIL,NIL,NIL) )

END WSMETHOD

oXmlRet := NIL
Return .T.

// WSDL Method TESTE of Service WSWS_ESCOLA

WSMETHOD TESTE WSSEND cCRECEBE WSRECEIVE cTESTERESULT WSCLIENT WSWS_ESCOLA
Local cSoap := "" , oXmlRet

BEGIN WSMETHOD

cSoap += '<TESTE xmlns="http://localhost:8085/">'
cSoap += WSSoapValue("CRECEBE", ::cCRECEBE, cCRECEBE , "string", .T. , .F., 0 , NIL, .F.,.F.) 
cSoap += "</TESTE>"

oXmlRet := SvcSoapCall(	Self,cSoap,; 
	"http://localhost:8085/TESTE",; 
	"DOCUMENT","http://localhost:8085/",,"1.031217",; 
	"http://localhost:8085/WS_ESCOLA.apw")

::Init()
::cTESTERESULT       :=  WSAdvValue( oXmlRet,"_TESTERESPONSE:_TESTERESULT:TEXT","string",NIL,NIL,NIL,NIL,NIL,NIL) 

END WSMETHOD

oXmlRet := NIL
Return .T.


// WSDL Data Structure WSENVCADALUNO

WSSTRUCT WS_ESCOLA_WSENVCADALUNO
	WSDATA   cCDTNASCI                 AS string
	WSDATA   cCFIL                     AS string
	WSDATA   cCNOME                    AS string
	WSDATA   cCRA                      AS string
	WSDATA   cCSITUAC                  AS string
	WSMETHOD NEW
	WSMETHOD INIT
	WSMETHOD CLONE
	WSMETHOD SOAPSEND
ENDWSSTRUCT

WSMETHOD NEW WSCLIENT WS_ESCOLA_WSENVCADALUNO
	::Init()
Return Self

WSMETHOD INIT WSCLIENT WS_ESCOLA_WSENVCADALUNO
Return

WSMETHOD CLONE WSCLIENT WS_ESCOLA_WSENVCADALUNO
	Local oClone := WS_ESCOLA_WSENVCADALUNO():NEW()
	oClone:cCDTNASCI            := ::cCDTNASCI
	oClone:cCFIL                := ::cCFIL
	oClone:cCNOME               := ::cCNOME
	oClone:cCRA                 := ::cCRA
	oClone:cCSITUAC             := ::cCSITUAC
Return oClone

WSMETHOD SOAPSEND WSCLIENT WS_ESCOLA_WSENVCADALUNO
	Local cSoap := ""
	cSoap += WSSoapValue("CDTNASCI", ::cCDTNASCI, ::cCDTNASCI , "string", .T. , .F., 0 , NIL, .F.,.F.) 
	cSoap += WSSoapValue("CFIL", ::cCFIL, ::cCFIL , "string", .T. , .F., 0 , NIL, .F.,.F.) 
	cSoap += WSSoapValue("CNOME", ::cCNOME, ::cCNOME , "string", .T. , .F., 0 , NIL, .F.,.F.) 
	cSoap += WSSoapValue("CRA", ::cCRA, ::cCRA , "string", .T. , .F., 0 , NIL, .F.,.F.) 
	cSoap += WSSoapValue("CSITUAC", ::cCSITUAC, ::cCSITUAC , "string", .T. , .F., 0 , NIL, .F.,.F.) 
Return cSoap

// WSDL Data Structure WSRECCADALUNO

WSSTRUCT WS_ESCOLA_WSRECCADALUNO
	WSDATA   cCMENSAGEM                AS string
	WSDATA   lLRET                     AS boolean
	WSMETHOD NEW
	WSMETHOD INIT
	WSMETHOD CLONE
	WSMETHOD SOAPRECV
ENDWSSTRUCT

WSMETHOD NEW WSCLIENT WS_ESCOLA_WSRECCADALUNO
	::Init()
Return Self

WSMETHOD INIT WSCLIENT WS_ESCOLA_WSRECCADALUNO
Return

WSMETHOD CLONE WSCLIENT WS_ESCOLA_WSRECCADALUNO
	Local oClone := WS_ESCOLA_WSRECCADALUNO():NEW()
	oClone:cCMENSAGEM           := ::cCMENSAGEM
	oClone:lLRET                := ::lLRET
Return oClone

WSMETHOD SOAPRECV WSSEND oResponse WSCLIENT WS_ESCOLA_WSRECCADALUNO
	::Init()
	If oResponse = NIL ; Return ; Endif 
	::cCMENSAGEM         :=  WSAdvValue( oResponse,"_CMENSAGEM","string",NIL,"Property cCMENSAGEM as s:string on SOAP Response not found.",NIL,"S",NIL,NIL) 
	::lLRET              :=  WSAdvValue( oResponse,"_LRET","boolean",NIL,"Property lLRET as s:boolean on SOAP Response not found.",NIL,"L",NIL,NIL) 
Return

// WSDL Data Structure WSENVDADOSALUNO

WSSTRUCT WS_ESCOLA_WSENVDADOSALUNO
	WSDATA   cCDTNASCI                 AS string OPTIONAL
	WSDATA   cCFIL                     AS string OPTIONAL
	WSDATA   cCNOME                    AS string OPTIONAL
	WSDATA   cCRA                      AS string OPTIONAL
	WSDATA   cCSITUAC                  AS string OPTIONAL
	WSMETHOD NEW
	WSMETHOD INIT
	WSMETHOD CLONE
	WSMETHOD SOAPSEND
ENDWSSTRUCT

WSMETHOD NEW WSCLIENT WS_ESCOLA_WSENVDADOSALUNO
	::Init()
Return Self

WSMETHOD INIT WSCLIENT WS_ESCOLA_WSENVDADOSALUNO
Return

WSMETHOD CLONE WSCLIENT WS_ESCOLA_WSENVDADOSALUNO
	Local oClone := WS_ESCOLA_WSENVDADOSALUNO():NEW()
	oClone:cCDTNASCI            := ::cCDTNASCI
	oClone:cCFIL                := ::cCFIL
	oClone:cCNOME               := ::cCNOME
	oClone:cCRA                 := ::cCRA
	oClone:cCSITUAC             := ::cCSITUAC
Return oClone

WSMETHOD SOAPSEND WSCLIENT WS_ESCOLA_WSENVDADOSALUNO
	Local cSoap := ""
	cSoap += WSSoapValue("CDTNASCI", ::cCDTNASCI, ::cCDTNASCI , "string", .F. , .F., 0 , NIL, .F.,.F.) 
	cSoap += WSSoapValue("CFIL", ::cCFIL, ::cCFIL , "string", .F. , .F., 0 , NIL, .F.,.F.) 
	cSoap += WSSoapValue("CNOME", ::cCNOME, ::cCNOME , "string", .F. , .F., 0 , NIL, .F.,.F.) 
	cSoap += WSSoapValue("CRA", ::cCRA, ::cCRA , "string", .F. , .F., 0 , NIL, .F.,.F.) 
	cSoap += WSSoapValue("CSITUAC", ::cCSITUAC, ::cCSITUAC , "string", .F. , .F., 0 , NIL, .F.,.F.) 
Return cSoap

// WSDL Data Structure WSRETDADOSALUNO

WSSTRUCT WS_ESCOLA_WSRETDADOSALUNO
	WSDATA   oWSAALUNOS                AS WS_ESCOLA_ARRAYOFALUNO OPTIONAL
	WSMETHOD NEW
	WSMETHOD INIT
	WSMETHOD CLONE
	WSMETHOD SOAPRECV
ENDWSSTRUCT

WSMETHOD NEW WSCLIENT WS_ESCOLA_WSRETDADOSALUNO
	::Init()
Return Self

WSMETHOD INIT WSCLIENT WS_ESCOLA_WSRETDADOSALUNO
Return

WSMETHOD CLONE WSCLIENT WS_ESCOLA_WSRETDADOSALUNO
	Local oClone := WS_ESCOLA_WSRETDADOSALUNO():NEW()
	oClone:oWSAALUNOS           := IIF(::oWSAALUNOS = NIL , NIL , ::oWSAALUNOS:Clone() )
Return oClone

WSMETHOD SOAPRECV WSSEND oResponse WSCLIENT WS_ESCOLA_WSRETDADOSALUNO
	Local oNode1
	::Init()
	If oResponse = NIL ; Return ; Endif 
	oNode1 :=  WSAdvValue( oResponse,"_AALUNOS","ARRAYOFALUNO",NIL,NIL,NIL,"O",NIL,NIL) 
	If oNode1 != NIL
		::oWSAALUNOS := WS_ESCOLA_ARRAYOFALUNO():New()
		::oWSAALUNOS:SoapRecv(oNode1)
	EndIf
Return

// WSDL Data Structure ARRAYOFALUNO

WSSTRUCT WS_ESCOLA_ARRAYOFALUNO
	WSDATA   oWSALUNO                  AS Array Of  WS_ESCOLA_ALUNO OPTIONAL
	WSMETHOD NEW
	WSMETHOD INIT
	WSMETHOD CLONE
	WSMETHOD SOAPRECV
ENDWSSTRUCT

WSMETHOD NEW WSCLIENT WS_ESCOLA_ARRAYOFALUNO
	::Init()
Return Self

WSMETHOD INIT WSCLIENT WS_ESCOLA_ARRAYOFALUNO
//	::oWSALUNO             := {} // Array Of  WS_ESCOLA_ALUNO():New()
Return

WSMETHOD CLONE WSCLIENT WS_ESCOLA_ARRAYOFALUNO
	Local oClone := WS_ESCOLA_ARRAYOFALUNO():NEW()
	oClone:oWSALUNO := NIL
	If ::oWSALUNO <> NIL 
		oClone:oWSALUNO := {}
		aEval( ::oWSALUNO , { |x| aadd( oClone:oWSALUNO , x:Clone() ) } )
	Endif 
Return oClone

WSMETHOD SOAPRECV WSSEND oResponse WSCLIENT WS_ESCOLA_ARRAYOFALUNO
	Local nRElem1, oNodes1, nTElem1
	::Init()
	If oResponse = NIL ; Return ; Endif 
	oNodes1 :=  WSAdvValue( oResponse,"_ALUNO","ALUNO",{},NIL,.T.,"O",NIL,NIL) 
	nTElem1 := len(oNodes1)
	For nRElem1 := 1 to nTElem1 
		If !WSIsNilNode( oNodes1[nRElem1] )
			aadd(::oWSALUNO , WS_ESCOLA_ALUNO():New() )
			::oWSALUNO[len(::oWSALUNO)]:SoapRecv(oNodes1[nRElem1])
		Endif
	Next
Return

// WSDL Data Structure ALUNO

WSSTRUCT WS_ESCOLA_ALUNO
	WSDATA   cCDTNASCI                 AS string
	WSDATA   cCFIL                     AS string
	WSDATA   cCNOME                    AS string
	WSDATA   cCRA                      AS string
	WSDATA   cCSITUAC                  AS string
	WSMETHOD NEW
	WSMETHOD INIT
	WSMETHOD CLONE
	WSMETHOD SOAPRECV
ENDWSSTRUCT

WSMETHOD NEW WSCLIENT WS_ESCOLA_ALUNO
	::Init()
Return Self

WSMETHOD INIT WSCLIENT WS_ESCOLA_ALUNO
Return

WSMETHOD CLONE WSCLIENT WS_ESCOLA_ALUNO
	Local oClone := WS_ESCOLA_ALUNO():NEW()
	oClone:cCDTNASCI            := ::cCDTNASCI
	oClone:cCFIL                := ::cCFIL
	oClone:cCNOME               := ::cCNOME
	oClone:cCRA                 := ::cCRA
	oClone:cCSITUAC             := ::cCSITUAC
Return oClone

WSMETHOD SOAPRECV WSSEND oResponse WSCLIENT WS_ESCOLA_ALUNO
	::Init()
	If oResponse = NIL ; Return ; Endif 
	::cCDTNASCI          :=  WSAdvValue( oResponse,"_CDTNASCI","string",NIL,"Property cCDTNASCI as s:string on SOAP Response not found.",NIL,"S",NIL,NIL) 
	::cCFIL              :=  WSAdvValue( oResponse,"_CFIL","string",NIL,"Property cCFIL as s:string on SOAP Response not found.",NIL,"S",NIL,NIL) 
	::cCNOME             :=  WSAdvValue( oResponse,"_CNOME","string",NIL,"Property cCNOME as s:string on SOAP Response not found.",NIL,"S",NIL,NIL) 
	::cCRA               :=  WSAdvValue( oResponse,"_CRA","string",NIL,"Property cCRA as s:string on SOAP Response not found.",NIL,"S",NIL,NIL) 
	::cCSITUAC           :=  WSAdvValue( oResponse,"_CSITUAC","string",NIL,"Property cCSITUAC as s:string on SOAP Response not found.",NIL,"S",NIL,NIL) 
Return


