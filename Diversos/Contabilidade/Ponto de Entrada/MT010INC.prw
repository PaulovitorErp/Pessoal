#include "rwmake.ch"    
#include "topconn.ch"
/*
_____________________________________________________________________________
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦Programa  ¦ MT010INC   ¦ Autor ¦ Claudio Ferreira   ¦ Data ¦ 08/05/2012¦¦¦
¦¦+----------+------------------------------------------------------------¦¦¦
¦¦¦Descriçào ¦ Ponto de Entrada apos a inclusao do produto                ¦¦¦
¦¦¦          ¦ Utilizado para avisar a CTB                                ¦¦¦
¦¦+----------+------------------------------------------------------------¦¦¦
¦¦¦ Uso      ¦ TOTVS-GO                                                   ¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯
*/

User Function MT010INC()

Local cAviso:='Inclusão de novo Produto'
Local cDestino:=SuperGetMV("MV_XAVCTB", ,"")
Local _lGrv := .f.

if !empty(cDestino)
	//Envia email de Aviso
	xHTM := '<HTML><BODY>'
	xHTM += '<hr>'
	xHTM += '<p  style="word-spacing: 0; line-height: 100%; margin-top: 0; margin-bottom: 0">'
	xHTM += '<b><font face="Verdana" SIZE=3>'+cAviso+' &nbsp; '+dtoc(date())+'&nbsp;&nbsp;&nbsp;'+time()+'</b></p>'
	xHTM += '<hr>'
	xHTM += '<br>'
	xHTM += '<br>'
	xHTM += 'Foi incluido um novo Produto <BR><BR>-Código <b>'  +SB1->B1_COD+' - '+SB1->B1_DESC+'</b> <BR>-Usuario <b>'+ U_zUsrRetName(RetCodUsr())+'</b> <br><br>'
	xHTM += 'Ação: Deve-se validar o cadastro e liberar para uso<br><br>'
	xHTM += '</BODY></HTML>'
	
	//Parametros necessarios para a rotina
	// MV_RELACNT - Conta a ser utilizada no envio de E-Mail
	// MV_RELFROM - E-mail utilizado no campo FROM no envio
	// MV_RELSERV - Nome do Servidor de Envio de E-mail utilizado no envio
	// MV_RELAUTH - Determina se o Servidor de Email necessita de Autenticação
	// MV_RELAUSR - Usuário para Autenticação no Servidor de Email
	// MV_RELAPSW - Senha para Autenticação no Servidor de Email
	
	oMail := SendMail():new()
	
	oMail:SetTo(cDestino)
	//oMail:SetCc('') // (opc)
	oMail:SetFrom(Alltrim(GetMv("MV_RELFROM",," ")))
	//oMail:SetAttachment('\system\siga.txt') //Anexo (opc)
	oMail:SetSubject('Aviso - '+cAviso)
	oMail:SetBody(xHTM)
	oMail:SetShedule(.f.) //(opc) Default .f. - define modo Schedule
	oMail:SetEchoMsg(.f.) //(opc) Default .t. - define se exibe mensagens automaticamente na Tela (Schedule .f.) / Console (Schedule .t.)
	oMail:Sendmail()
endif

Return
