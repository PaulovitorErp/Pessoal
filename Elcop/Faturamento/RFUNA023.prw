#include 'protheus.ch'
#include 'parmtype.ch'
#INCLUDE "hbutton.ch"
#INCLUDE "FWPrintSetup.ch"
#INCLUDE "RPTDEF.CH"
#INCLUDE "PARMTYPE.CH"
#include "TOTVS.CH"

/*
_____________________________________________________________________________
�����������������������������������������������������������������������������
��+-----------------------------------------------------------------------+��
���Programa  � RFUNA023   � Autor � Andre Castilho   � Data � 03/01/2017  ���
��+----------+------------------------------------------------------------���
���Descri��o � Conecta no Site Prefeitura Goiania						  ���
���          �                                                            ���
��+----------+------------------------------------------------------------���
���Uso       � Paz Universal                                              ���
��+-----------------------------------------------------------------------+��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/

User Function RFUNA023()

Local oSay1			:= NIL
Local oSay2			:= NIL
Local oSay3			:= NIL
Local oGetInscri	:= NIL
//Local oGetNota		:= NIL
//Local oGetVer		:= NIL
Local oPanel		:= NIL
//Local oTIBrowser	:= NIL 
//Local oScrool		:= NIL  
Local oButton1		:= NIL	
//Local oButton2		:= NIL
Local oButton3		:= NIL	
Local oGroup1		:= NIL
Local oGroup2		:= NIL
Local cGetInscri	:= AllTrim(RetDadosSM0(cEmpAnt,cFilAnt,"M0_INSCM")) // inscri��o municipal da empresa 
//Local cGetNota		:= Space(TamSX3("F2_NFELETR")[1]) // n�mero da nota da prefeitura  
//Local cGetVer		:= Space(TamSX3("F2_CODNFE")[1]) // c�digo de verifica��o da nota 
Local cGetNFDe		:= SF2->F2_NFELETR //Space(TamSX3("F2_NFELETR")[1]) // n�mero da nota da prefeitura  
Local cGetNFAte 	:= SF2->F2_NFELETR //Space(TamSX3("F2_NFELETR")[1]) // c�digo de verifica��o da nota 
Local cF3Nota       := "F2FNFS"
Local _aAreas		:= GetArea()
Static oDlg			:= NIL


DEFINE MSDIALOG oDlg TITLE "Impress�o da NFS-e" FROM 000, 000  TO 570, 697 COLORS 0, 16777215 PIXEL
																// 700, 697
// Prepara o conector WebSocket
oWebChannel := TWebChannel():New()
nPort := oWebChannel::connect()

@ 005, 005 GROUP oGroup1 TO 035, 345 PROMPT "  Par�metros de impress�o:  " OF oDlg COLOR 0, 16777215 PIXEL

@ 018, 010 SAY oSay1 PROMPT "Inscri��o Municipal:" SIZE 100, 006 OF oDlg COLORS 0, 16777215 PIXEL
@ 016, 060 MSGET oGetInscri VAR cGetInscri SIZE 035, 010 OF oDlg COLORS 0, 16777215 PIXEL WHEN .F.

@ 018, 105 SAY oSay2 PROMPT "N�mero Nota De:" SIZE 100, 006 OF oDlg COLORS 0, 16777215 PIXEL
@ 016, 148 MSGET oGetNFDe VAR cGetNFDe SIZE 035, 010  OF oDlg COLORS 0, 16777215 HASBUTTON PIXEL

//@ 016, 148 MSGET oGetNFDe VAR cGetNFDe SIZE 035, 010 F3 cF3Nota OF oDlg COLORS 0, 16777215 HASBUTTON PIXEL
//@ 018, 202 SAY oSay3 PROMPT "C�d. de Verifica��o:" SIZE 100, 006 OF oDlg COLORS 0, 16777215 PIXEL
//@ 016, 255 MSGET oGetVer VAR cGetVer SIZE 040, 010 OF oDlg COLORS 0, 16777215 PIXEL

@ 018, 202 SAY oSay3 PROMPT "N�mero Nota At�:" SIZE 100, 006 OF oDlg COLORS 0, 16777215 PIXEL
@ 016, 255 MSGET oGetNFAte VAR cGetNFAte SIZE 040, 010 F3 cF3Nota OF oDlg COLORS 0, 16777215 PIXEL

@ 016, 302 BUTTON oButton1 PROMPT "Visualizar" Action(FWMsgRun(,{|oSay| iif(GoPageNFS(oWebEngine,cGetInscri,cGetNFDe,cGetNFAte) , oPanel:Hide() , oPanel:Show())},'Aguarde...','Imprimindo Nota...')) SIZE 037, 012 OF oDlg PIXEL

// crio um panel com cor diferenciada, para ficar de fundo
@ 040, 005 MSPANEL oPanel PROMPT "Nota Fiscal de Servi�o" SIZE 330, 210 OF oDlg COLORS 0, 15395562 CENTERED LOWERED
															// 340, 285
// crio o objeto de Browser, para mostrar a nota na prefeitura      
//oTIBrowser:= TIBrowser():New(040,005,340,285,"",oDlg )   
//oTIBrowser:= TWebEngine():New(040,005,340,285)   

// Cria componente                     040  030
oWebEngine := TWebEngine():New(oPanel, 005, 005, 330, 210,, nPort)
												//320, 285

@ 255, 005 GROUP oGroup2 TO 280, 345 PROMPT "" OF oDlg COLOR 0, 16777215 PIXEL   
//328
//@ 260, 244 BUTTON oButton2 PROMPT 'Gera PDF' SIZE 040, 012 OF oDlg PIXEL ACTION (oWebEngine:PrintPdf())
@ 260, 290 BUTTON oButton3 PROMPT 'Fechar' 	 SIZE 040, 012 OF oDlg PIXEL ACTION (oDlg:End())
//333
ACTIVATE MSDIALOG oDlg CENTERED

RestArea(_aAreas)	
Return()

/*
_____________________________________________________________________________
�����������������������������������������������������������������������������
��+-----------------------------------------------------------------------+��
���Programa  � GoPageNFS   � Autor � Andre Castilho   � Data � 03/01/2017 ���
��+----------+------------------------------------------------------------���
���Descri��o � Visualiza Pagina NFS Prefeitura 							  ���
���          �                                                            ���
��+----------+------------------------------------------------------------���
���Uso       � Paz Universal                                              ���
��+-----------------------------------------------------------------------+��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/

Static Function GoPageNFS(oWebEngine,cGetInscri,cGetNFDe,cGetNFAte)

Local lRet	:= .T.
//Local nItem	:= 1
Local cLink	:= SuperGetMV('MV_XLINKNF',,"")

// valido se todos os campos foram preenchidos
if !Empty(cGetInscri) .AND. !Empty(cGetNFDe) .AND. !Empty(cGetNFAte) 

	// se o link da prefeitura estiver correto
	if AT("inscricao",cLink) > 0 .AND. AT("nota",cLink) > 0 .AND. AT("verificador",cLink) > 0 
		cNfIni := cGetNFDe

		do while cNfIni <= cGetNFAte
			cLink	:= SuperGetMV('MV_XLINKNF',,"")
			
			// atualizo o link de consulta na prefeitura
			cLink := StrTran(cLink,"#inscricao#",Alltrim(cGetInscri))
			cLink := StrTran(cLink,"#nota#",Alltrim(cNfIni))
			cLink := StrTran(cLink,"#verificador#",Alltrim(Posicione("SF2",8,xFilial("SF2")+cNfIni,"F2_CODNFE")))
			
			oWebEngine:bLoadFinished := {|self,url| conout("Termino da carga do pagina: " + url) }
			oWebEngine:navigate(cLink)
			oWebEngine:Align := CONTROL_ALIGN_NONE //CONTROL_ALIGN_ALLCLIENT

			// dou um intervalo de 3 segundos para a p�gina ser processada
			
			Sleep(1000)

			oWebEngine:PrintPdf()

			cNFIni := alltrim(str(val(cNFIni) + 1))
		enddo

	else
		MsgInfo("O par�metro de configura��o da nota (MV_XLINKNF) n�o existe ou est� incorreto!","Aten��o!")
		lRet := .F.		
	endif
	
else
	MsgInfo("Informe os dados da nota!","Aten��o!")
	lRet := .F.
endif

Return(lRet)

/*
_____________________________________________________________________________
�����������������������������������������������������������������������������
��+-----------------------------------------------------------------------+��
���Programa  � RetDadosSM0   � Autor � Andre Castilho  � Data � 03/01/2017���
��+----------+------------------------------------------------------------���
���Descri��o � Retorna informa��es do cad de empresas					  ���
���          �                                                            ���
��+----------+------------------------------------------------------------���
���Uso       � Paz Universal                                              ���
��+-----------------------------------------------------------------------+��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/



Static Function RetDadosSM0(cEmp,cFil,cCampo)
 
Local aArea		:= GetArea()       
Local aAreaSM0	:= SM0->(GetArea()) 
Local cRet		:= ""    

cRet := Posicione("SM0",1,cEmp + cFil,cCampo)

RestArea(aAreaSM0)
RestArea(aArea)

Return(cRet)





