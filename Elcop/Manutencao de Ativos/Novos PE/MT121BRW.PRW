/*             
Sintaxe
MT121BRW - Ponto de Entrada para Envio de E-mail de Confirmação da chegada dos Documentos 
            Nota Fiscal e Boletos

Retorno
URET(Nil)
Menu MATA121 - Pedido de Compras

*/
#include "TOTVS.CH"

user function MT121BRW()
	AAdd(aRotina,{"Confirma Docs","U_ACOM001(SC7->C7_NUM, SC7->C7_FORNECE, SC7->C7_LOJA)",0,6})

return

user Function ACOM001(cPedido, cFornece, cLoja)
	Local cMsg := ""
	Local xRet
	Local oServer, oMessage
	Local lMailAuth	:= SuperGetMv("MV_RELAUTH",,.F.)
	Local nPorta    := 587 //informa a porta que o servidor SMTP irá se comunicar, podendo ser 25 ou 587
    Local cPara     := GETMV("MV_XPEMAIL") 
    Local cCopia    := GETMV("MV_XCEMAIL") 
    Local cAssunto  := "Nota Fiscal Anexada ao Pedido"
    Local cMensagem := "Confirmação da Chegada da Nota Fiscal do Pedido "+cPedido+" do Fornecedor "+;
                        Posicione("SA2",1,xFilial("SA2")+cFornece+cLoja,"A2_NOME")
	Local aArquivos := {}
    Local nArq      := 1
 
	Private cMailConta :=GETMV("MV_RELACNT") //Conta utilizada para envio do email
	Private cMailServer:="smtp.office365.com"  //GETMV("MV_RELSERV") //Servidor SMTP
	Private cMailSenha :=GETMV("MV_RELPSW")  //Senha da conta de e-mail utilizada para envio
    
    if !msgyesno("Confirma Envio de E-mail ?")
        return
    endif

   	oMessage:= TMailMessage():New()
	oMessage:Clear()
   
	oMessage:cDate	 := cValToChar( Date() )
	oMessage:cFrom 	 := cMailConta
	oMessage:cTo 	 := cPara
    oMessage:cCc     := cCopia
	oMessage:cSubject:= cAssunto
	oMessage:cBody 	 := cMensagem
	
	If Len(aArquivos) > 0
		For nArq := 1 To Len(aArquivos)
			xRet := oMessage:AttachFile( aArquivos[nArq] )
			if xRet < 0
				cMsg := "O arquivo " + aArquivos[nArq] + " não foi anexado!"
				alert( cMsg )
				return
			endif
		Next nArq
	EndIf		
	   
	oServer := tMailManager():New()
	oServer:SetUseTLS( .T. ) //Indica se será utilizará a comunicação segura através de SSL/TLS (.T.) ou não (.F.)
   
	xRet := oServer:Init( "", cMailServer, cMailConta, cMailSenha, nPorta ) //inicilizar o servidor
	if xRet != 0
		alert("O servidor SMTP não foi inicializado: " + oServer:GetErrorString( xRet ) )
		return
	endif
   
	xRet := oServer:SetSMTPTimeout( 60 ) //Indica o tempo de espera em segundos.
	if xRet != 0
		alert("Não foi possível definir " + cProtocol + " tempo limite para " + cValToChar( nTimeout ))
	endif
   
	xRet := oServer:SMTPConnect()
	if xRet <> 0
		alert("Não foi possível conectar ao servidor SMTP: " + oServer:GetErrorString( xRet ))
		return
	endif
   
	if lMailAuth
		//O método SMTPAuth ao tentar realizar a autenticação do 
		//usuário no servidor de e-mail, verifica a configuração 
		//da chave AuthSmtp, na seção [Mail], no arquivo de 
		//configuração (INI) do TOTVS Application Server, para determinar o valor.
		xRet := oServer:SmtpAuth( cMailConta, cMailSenha )
		if xRet <> 0
			cMsg := "Could not authenticate on SMTP server: " + oServer:GetErrorString( xRet )
			alert( cMsg )
			oServer:SMTPDisconnect()
			return
		endif
   	Endif
	xRet := oMessage:Send( oServer )
	if xRet <> 0
		alert("Não foi possível enviar mensagem: " + oServer:GetErrorString( xRet ))
	else
		MsgInfo("E-mail enviado com suscesso","E-mail" )
    endif
   
	xRet := oServer:SMTPDisconnect()
	if xRet <> 0
		alert("Não foi possível desconectar o servidor SMTP: " + oServer:GetErrorString( xRet ))
	endif
return
