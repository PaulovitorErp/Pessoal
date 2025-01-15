#Include "PROTHEUS.CH"
//--------------------------------------------------------------
/*/{Protheus.doc} MyFunction
Description                                                     
                                                                
@param xParam Parameter Description                             
@return xRet Return Description
@author e -                                               
@since 12/04/2018                                                   
/*/                                                             
//--------------------------------------------------------------
User Function RCOMA013()
Local oButton1
Local oButton2
Local oButton3
Local oGroup1
Static oDlg

  DEFINE MSDIALOG oDlg TITLE "Teste" FROM 000, 000  TO 190, 500 COLORS 0, 16777215 PIXEL

    @ 003, 005 GROUP oGroup1 TO 073, 244 PROMPT "Teste" OF oDlg COLOR 0, 16777215 PIXEL
    @ 081, 114 BUTTON oButton1 PROMPT "Teste" SIZE 037, 012 OF oDlg action funTeste() PIXEL
    @ 080, 160 BUTTON oButton2 PROMPT "oButton2" SIZE 037, 012 OF oDlg action funBot2() PIXEL
    @ 079, 206 BUTTON oButton3 PROMPT "oButton3" SIZE 037, 012 OF oDlg action funBot3() PIXEL

  ACTIVATE MSDIALOG oDlg CENTERED

Return()

Static Function funTeste()

	Local oWsAluno := WSWS_ESCOLA():new()
		
	oWsAluno:Teste("1")
	
	MsgAlert(oWsAluno:cTesteResult)
	
Return()


Static Function funBot2()

	Local oWsAluno := WSWS_ESCOLA():new()
		
	// Cria e alimenta uma nova instancia do contrato
	oNewAluno 			:=  WSClassNew( "WS_ESCOLA_WSENVDADOSALUNO" )
							
	oNewAluno:cCNOME		:= "A"
		
	oWsAluno:CONS_ALUNO(oNewAluno)
	
	Alert("ok")
	
Return()


Static Function funBot3()

	Alert("Botão3")

Return()