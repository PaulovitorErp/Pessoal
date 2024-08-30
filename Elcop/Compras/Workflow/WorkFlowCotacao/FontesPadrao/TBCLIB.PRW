#include "rwmake.ch"
#include "topconn.ch"
#include "protheus.ch"
#include "TBICONN.CH"

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³TBCLIB    ºAutor  ³DIVERSOS            º Data ³  01/12/08   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Conjunto de Funcoes Genericas                              º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³TOTVS GO           										  º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß

ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³SendMail  ºAutor  ³Cláudio Ferreira    º Data ³  12/09/07   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Classe para enviar email                                   º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³                  										  º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/

CLASS SendMail
DATA cFile 
DATA cSubject 
DATA cBody    
DATA lShedule 
DATA cTo     
DATA cCc      
DATA cFrom      
DATA cLogMsg     
DATA lEchoMsg 
DATA nSMTPPort
DATA nSMTPTime
DATA nPOPPort 
METHOD new() constructor
METHOD SetAttachment(_cFile)
METHOD SetSubject(_cSubject)
METHOD SetTo(_cTo)
METHOD SetCc(_cCc)
METHOD SetFrom(_cFrom)
METHOD SetBody(_cBody)
METHOD SetShedule(_lDef)
METHOD SetEchoMsg(_lDef)
METHOD SetSMTPPort(_nSMTPPort) 
METHOD SetPOPPort(_nPOPPort) 
METHOD Edit()
METHOD Send()
ENDCLASS

//------------------------------------------------------------------------//
METHOD new() CLASS SendMail
::cFile := ""
::cSubject := ""
::cBody    := space(240)
::lShedule := isBlind()
::cTo      := space(100)
::cCc      := space(100) 
::cFrom    := space(100)
::cLogMsg  := ""
::lEchoMsg :=  .T.
::nSMTPPort := 587                    // Porta do servidor SMTP
::nSMTPTime := 60 
::nPOPPort  := 110
Return Self

//------------------------------------------------------------------------//
METHOD SetSMTPPort(_nSMTPPort) CLASS SendMail
::nSMTPPort := _nSMTPPort
Return     

//------------------------------------------------------------------------//
METHOD SetPOPPort(_nPOPPort) CLASS SendMail
::nPOPPort := _nPOPPort
Return     

//------------------------------------------------------------------------//
METHOD SetAttachment(_cFile) CLASS SendMail
::cFile := _cFile
Return     

//------------------------------------------------------------------------//
METHOD SetSubject(_cSubject) CLASS SendMail
::cSubject := padr(_cSubject,100)
Return     

//------------------------------------------------------------------------//
METHOD SetTo(_cTo) CLASS SendMail
::cTo := _cTo
Return     

//------------------------------------------------------------------------//
METHOD SetCc(_cCc) CLASS SendMail
::cCc := _cCc
Return     

//------------------------------------------------------------------------//
METHOD SetFrom(_cFrom) CLASS SendMail
::cFrom := _cFrom
Return  

//------------------------------------------------------------------------//
METHOD SetBody(_cBody) CLASS SendMail
::cBody := _cBody
Return  

//------------------------------------------------------------------------//
METHOD SetShedule(_lDef) CLASS SendMail
::lShedule := _lDef
Return  

//------------------------------------------------------------------------//
METHOD SetEchoMsg(_lDef) CLASS SendMail
::lEchoMsg := _lDef
Return  


//------------------------------------------------------------------------//
METHOD Edit() CLASS SendMail 
LOCAL oDlg, nOP, nCol1, nCol2, nSize, nLinha, nLinAux    

DO WHILE !::lShedule

   nOp  :=0
   nCol1:=8
   nCol2:=33
   nSize:=225  
   nLinha:=15 

   DEFINE MSDIALOG oDlg OF oMainWnd FROM 0,0 TO 350,544 PIXEL TITLE "Envio de E-mail"

        nLinAux:=nLinha
        nLinha+=10

  		@ nLinha,nCol1 Say   "De:"      Size 012,08             OF oDlg PIXEL 
  		@ nLinha,nCol2 MSGET ::cFrom      Size nSize,10  F3 "_EM" OF oDlg PIXEL 
        nLinha+=15

  		@ nLinha,nCol1 Say   "Para:"    Size 016,08             OF oDlg PIXEL
  		@ nLinha,nCol2 MSGET ::cTo        Size nSize,10  F3 "_EM" OF oDlg PIXEL
        nLinha+=15

  		@ nLinha,nCol1 Say   "CC:"      Size 016,08             OF oDlg PIXEL
  		@ nLinha,nCol2 MSGET ::cCC        Size nSize,10  F3 "_EM" OF oDlg PIXEL
        nLinha+=15

  		@ nLinha,nCol1 Say   "Assunto:" Size 021,08             OF oDlg PIXEL
  		@ nLinha,nCol2 MSGET ::cSubject   Size nSize,10           OF oDlg PIXEL
        nLinha+=15

  		@ nLinha,nCol1 Say   "Mensagem:"   Size 016,08             OF oDlg PIXEL
  		@ nLinha,nCol2 Get   ::cBody      Size nSize,20  MEMO     OF oDlg PIXEL HSCROLL

  		@ nLinAux,nCol1-4 To nLinha+28,268 LABEL " Dados de Envio " OF oDlg PIXEL 
        nLinha+=35

    DEFINE SBUTTON FROM nLinha,(oDlg:nClientWidth-4)/2-90 TYPE 1 ACTION (If(Empty(::cTo),Help("",1,"AVG0001054"),(oDlg:End(),nOp:=1))) ENABLE OF oDlg PIXEL
    DEFINE SBUTTON FROM nLinha,(oDlg:nClientWidth-4)/2-45 TYPE 2 ACTION (oDlg:End()) ENABLE OF oDlg PIXEL

   ACTIVATE MSDIALOG oDlg CENTERED

   IF nOp = 0
      RETURN .f.
   ENDIF

   EXIT

ENDDO

Return .t. 

//------------------------------------------------------------------------//
METHOD Send() CLASS SendMail 
LOCAL cServer, cAccount, cPassword, lAutentica, cUserAut, cPassAut
local oServer  := Nil
local oMessage := Nil
local nErr     := 0   
local lOk	   :=.t.

IF EMPTY((cPOP:=AllTrim(GetNewPar("MV_WFPOP3",""))))
   ::cLogMsg := "Nome do Servidor POP nao definido no 'MV_WFPOP3'"
   if ::lEchoMsg 
     IF !::lShedule
        MSGINFO(::cLogMsg)
     ELSE
        U_UWCLogMsg(cLogMsg)
     ENDIF
   endif  
   RETURN .F.
ENDIF

IF EMPTY((cServer:=AllTrim(GetNewPar("MV_RELSERV",""))))
   ::cLogMsg := "Nome do Servidor de Envio de E-mail nao definido no 'MV_RELSERV'"
   if ::lEchoMsg 
     IF !::lShedule
        MSGINFO(::cLogMsg)
     ELSE
        U_UWCLogMsg(cLogMsg)
     ENDIF
   endif  
   RETURN .F.
ENDIF

IF EMPTY((cAccount:=AllTrim(GetNewPar("MV_RELACNT",""))))
   ::cLogMsg := "Conta para acesso ao Servidor de E-mail nao definida no 'MV_RELACNT'"
   if ::lEchoMsg 
     IF !::lShedule
        MSGINFO(::cLogMsg)
     ELSE
        U_UWCLogMsg(cLogMsg)
     ENDIF
   endif  
   RETURN .F.   
ENDIF   

IF EMPTY(::cTo)
   ::cLogMsg := "E-mail para envio, nao informado."
   if ::lEchoMsg 
     IF !::lShedule
        MSGINFO(::cLogMsg)
     ELSE
        U_UWCLogMsg(cLogMsg)
     ENDIF
   endif  
   RETURN .F.   
ENDIF   

IF EMPTY(::cFrom)
   ::cLogMsg := "E-mail de envio, nao informado."
   if ::lEchoMsg 
     IF !::lShedule
        MSGINFO(::cLogMsg)
     ELSE
        U_UWCLogMsg(cLogMsg)
     ENDIF
   endif  
   RETURN .F.   
ENDIF  


::cCC  := ::cCC + SPACE(200)
::cTo  := ::cTo + SPACE(200)
::cSubject:=::cSubject+SPACE(100)


cAttachment:=::cFile
cPassword := AllTrim(GetNewPar("MV_RELPSW"," "))         
lAutentica:= GetMv("MV_RELAUTH",,.F.)         //Determina se o Servidor de Email necessita de Autenticação
cUserAut  := Alltrim(GetMv("MV_RELAUSR",," "))//Usuário para Autenticação no Servidor de Email
cPassAut  := Alltrim(GetMv("MV_RELAPSW",," "))//Senha para Autenticação no Servidor de Email

// Instancia um novo TMailManager
oServer := tMailManager():New()    

if GetMv("MV_RELSSL",,.F.)
  // Usa SSL na conexao
  oServer:setUseSSL(.T.) 
Endif

if GetMv("MV_RELTLS",,.F.)
  // Usa SSL na conexao
  oServer:setUseTLS(.T.) 
Endif

_nSMTPPort:=::nSMTPPort
_nPOPPort:=::nPOPPort
if At(':',cServer)>0
  _nSMTPPort:=Val(Substr(cServer,At(':',cServer)+1)) 
  cServer:=Substr(cServer,1,At(':',cServer)-1)   
endif


// Inicializa
oServer:init(cPOP, cServer, cAccount, cPassword, _nPOPPort, _nSMTPPort)

// Define o Timeout SMTP
if oServer:SetSMTPTimeout(::nSMTPTime) != 0
   ::cLogMsg := "[ERROR]Falha ao definir timeout "
   if ::lEchoMsg 
     IF !::lShedule
        MSGINFO(::cLogMsg)
     ELSE
        U_UWCLogMsg(cLogMsg)
     ENDIF
   endif  
   return .F.
endif

// Conecta ao servidor
nErr := oServer:smtpConnect()
if nErr <> 0
   ::cLogMsg := "[ERROR]Falha ao conectar: " + oServer:getErrorString(nErr)
   if ::lEchoMsg 
     IF !::lShedule
        MSGINFO(::cLogMsg)
     ELSE
        U_UWCLogMsg(cLogMsg)
     ENDIF
   endif  
  oServer:smtpDisconnect()
  return .F.
endif
                      
If lAutentica
// Realiza autenticacao no servidor
nErr := oServer:smtpAuth(cUserAut,cPassAut)
if nErr <> 0
   ::cLogMsg := "[ERROR]Falha ao autenticar: " + oServer:getErrorString(nErr)
   if ::lEchoMsg 
     IF !::lShedule
        MSGINFO(::cLogMsg)
     ELSE
        U_UWCLogMsg(cLogMsg)
     ENDIF
   endif  
  oServer:smtpDisconnect()
  return .F.
endif
Endif

// Cria uma nova mensagem (TMailMessage)
oMessage := tMailMessage():new()
oMessage:clear()
oMessage:cFrom    := ::cFrom
oMessage:cTo      := ::cTo   
If !EMPTY(::cCC)
  oMessage:cCC      := ::cCC
Endif  
//oMessage:cBCC     := "bcc@example.com"
oMessage:cSubject := ::cSubject
oMessage:cBody    := ::cBody
                                        
// Envia a mensagem
nErr := oMessage:send(oServer)
if nErr <> 0
     ::cLogMsg := "[ERROR]Falha ao enviar: " + oServer:getErrorString(nErr)
     if ::lEchoMsg 
       IF !::lShedule
          MSGINFO(::cLogMsg)
       ELSE
          U_UWCLogMsg(cLogMsg)
       ENDIF
     endif  
  oServer:smtpDisconnect()
  return .F.
endif

// Disconecta do Servidor
oServer:smtpDisconnect()

IF lOk 
     ::cLogMsg := "E-mail enviado com sucesso."
     if ::lEchoMsg 
       IF !::lShedule
          MSGINFO(::cLogMsg)
       ELSE
          U_UWCLogMsg(cLogMsg)
       ENDIF
     endif  
ENDIF   

RETURN lOk 


User Function ConsContrib(cIE,cUF,lView) 
Local cURL      := PadR(GetNewPar("MV_SPEDURL","http://"),250)
Local cSituacao := '9'

if !empty(cIE+cUF) .and.  !'ISENT'$UPPER(cIE) .and. IsReady(cURL)
   cSituacao :=ConsCad(cIE,cUF,lView)
endif   
                                       
Return cSituacao

/*/{Protheus.doc} ConsCad
Funcao realiza a consulta do contribuinte junto a SEFAZ.

@author  David Moraes
@since 04/10/2012
@version 1.0 

@param cIE, character, Inscrição Estadual
@param cUF, character, Unidade Federativa (Estado)
/*/
Static Function ConsCad(cIE,cUF,lView)        

Local cURL       := PadR(GetMv("MV_SPEDURL"),250)
Local cIdEnt     := "" 
Local cRazSoci   := ""	
Local cRegApur   := ""
Local cCnpj      := ""
Local cCpf       := ""
Local cSituacao  := ""   
Local cPictCNPJ  := "" 

Local dIniAtiv   := Date()
Local dAtualiza  := Date()

Local nX         := {}

Local cSituacao:='9'

Private oWS

cIdEnt := GetIdEnt()

oWs:= WsNFeSBra() :New()
oWs:cUserToken    := "TOTVS"
oWs:cID_ENT       := cIdEnt
oWs:cUF           := cUF
oWs:cCNPJ         := ""
oWs:cCPF          := ""
oWs:cIE           := Alltrim(cIE)
oWS:_URL          := AllTrim(cURL)+"/NFeSBRA.apw"

If oWs:CONSULTACONTRIBUINTE()

	If Type("oWs:OWSCONSULTACONTRIBUINTERESULT:OWSNFECONSULTACONTRIBUINTE") <> "U" 
		If ( Len(oWs:OWSCONSULTACONTRIBUINTERESULT:OWSNFECONSULTACONTRIBUINTE) > 0 )
			nX := Len(oWs:OWSCONSULTACONTRIBUINTERESULT:OWSNFECONSULTACONTRIBUINTE)

			If ValType(oWs:OWSCONSULTACONTRIBUINTERESULT:OWSNFECONSULTACONTRIBUINTE[nX]:dInicioAtividade) <> "U"			
				dIniAtiv  := oWs:OWSCONSULTACONTRIBUINTERESULT:OWSNFECONSULTACONTRIBUINTE[nX]:dInicioAtividade
		   	Else
				dIniAtiv  := ""
			EndIf            
			cRazSoci  := oWs:OWSCONSULTACONTRIBUINTERESULT:OWSNFECONSULTACONTRIBUINTE[nX]:cRazaoSocial
			cRegApur  := oWs:OWSCONSULTACONTRIBUINTERESULT:OWSNFECONSULTACONTRIBUINTE[nX]:cRegimeApuracao
			cCnpj     := oWs:OWSCONSULTACONTRIBUINTERESULT:OWSNFECONSULTACONTRIBUINTE[nX]:cCNPJ
			cCpf      := oWs:OWSCONSULTACONTRIBUINTERESULT:OWSNFECONSULTACONTRIBUINTE[nX]:cCPF
		   	cIe       := oWs:OWSCONSULTACONTRIBUINTERESULT:OWSNFECONSULTACONTRIBUINTE[nX]:cIE
		   	cUf       := oWs:OWSCONSULTACONTRIBUINTERESULT:OWSNFECONSULTACONTRIBUINTE[nX]:cUF
			cSituacao := oWs:OWSCONSULTACONTRIBUINTERESULT:OWSNFECONSULTACONTRIBUINTE[nX]:cSituacao	

		  	If ValType(oWs:OWSCONSULTACONTRIBUINTERESULT:OWSNFECONSULTACONTRIBUINTE[nX]:dUltimaSituacao) <> "U"
			  	dAtualiza := oWs:OWSCONSULTACONTRIBUINTERESULT:OWSNFECONSULTACONTRIBUINTE[nX]:dUltimaSituacao           
			Else
				dAtualiza := ""
			EndIf

			If ( cSituacao == "1" )
				cSituacao := "1 - Habilitado"		//"1 - Habilitado"
			ElseIf ( cSituacao == "0" )
				cSituacao := "0 - Não Habilitado"	//"0 - Não Habilitado"
			EndIf 
			
 
			If ( !Empty(cCnpj) ) 
				cCnpj		:= cCnpj
				cPictCNPJ	:= "@R 99.999.999/9999-99"
			Else  
				cCnpj		:= cCPF
				cPictCNPJ	:= "@R 999.999.999-99"
			EndIf
			
			DEFINE FONT oFont BOLD
			if lView
		
			DEFINE MSDIALOG oDlgKey TITLE "Retorno do Consulta Contribuinte" FROM 0,0 TO 200,355 PIXEL OF GetWndDefault()  //"Retorno do Consulta Contribuinte"
			
			@ 008,010 SAY "Início das Atividades:"	PIXEL FONT oFont OF oDlgKey		//"Início das Atividades:"
			@ 008,072 SAY If(Empty(dIniAtiv),"",DtoC(dIniAtiv))	 PIXEL OF oDlgKey
			@ 008,115 SAY "UF:"	PIXEL FONT oFont OF oDlgKey		//"UF:"
			@ 008,124 SAY cUf		PIXEL OF oDlgKey
			@ 020,010 SAY "Razão Social:"	PIXEL FONT oFont OF oDlgKey		//"Razão Social:"
			@ 020,048 SAY cRazSoci	PIXEL OF oDlgKey		
			@ 032,010 SAY "CNPJ/CPF:"	PIXEL FONT oFont OF oDlgKey		//"CNPJ/CPF:"
			@ 032,040 SAY cCnpj		PIXEL PICTURE cPictCNPJ OF oDlgKey		
			@ 032,115 SAY "IE:"	PIXEL FONT oFont OF oDlgKey		//"IE:"
			@ 032,123 SAY cIe		PIXEL OF oDlgKey		
			@ 044,010 SAY "Regime:"	PIXEL FONT oFont OF oDlgKey		//"Regime:"
			@ 044,035 SAY cRegApur	PIXEL OF oDlgKey		      	
			@ 056,010 SAY "Situação:"	PIXEL FONT oFont OF oDlgKey		//"Situação:"
			@ 056,038 SAY cSituacao	PIXEL OF oDlgKey             	
			@ 068,010 SAY "Atualizado em:"	PIXEL FONT oFont OF oDlgKey		//"Atualizado em:"
  			@ 068,055 SAY If(Empty(dAtualiza),"",DtoC(dAtualiza))	 PIXEL OF oDlgKey
			
			@ 80,137 BUTTON oBtnCon PROMPT "Ok" SIZE 38,11 PIXEL ACTION oDlgKey:End()	//"Ok"
		
			ACTIVATE DIALOG oDlgKey CENTERED		  
		    Endif
		EndIf
	EndIf	
Else         
    if lView
	  Aviso("SPED",IIf(Empty(GetWscError(3)),GetWscError(1),GetWscError(3)),{'ERRO'},3)
	endif  
EndIf
				
Return cSituacao           