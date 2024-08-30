//#include "rwmake.ch"
#include "TbiConn.ch"
#include "TbiCode.ch"
#include 'protheus.ch'
#include 'parmtype.ch'
#INCLUDE "topconn.ch"

/*----------------------------------------------------------------------
- Programa: ACOMP001
- Autor: Wellington Gonçalves
- Data: 28/08/2020
- Descrição: Workflow de Cotação de Compras
------------------------------------------------------------------------*/

User Function ACOMP001(oProcess)

	Local aCond			:= {}
	Local aMoeda		:= {}
	Local aItensUpg 	:= {}
	Local aCotacoes		:= {}
	Local _cC8_NUM		:= ""
	Local _cC8_FORNECE	:= ""
	Local _cC8_LOJA		:= ""
	Local _cEmlFor		:= ""
	Local _cC8_RecNO 	:= 0
	Local cEmail  		:= Space(30)
	Local cUsermail		:= ""
	Local cMailID		:= ""
	Local _AreaSC8 		:= SC8->( GetArea() )
	Local _AreaSE4 		:= SE4->( GetArea() )
	Local _AreaSB1 		:= SB1->( GetArea() )
	Local cEmailComp	:= ""
	Local lEnviado    	:= .F.
	Local nDiasTime		:= 0
	Local cEmailTST		:= SuperGetMV("MV_WFETST",.F.,'')
	Local lDescSB5 		:= SuperGetMV("MV_XDESCB5",.F.,.T.)
	Local lCopia		:= SuperGetMV("MV_XCMP001",.F.,.F.)
	Local lWFDesabilit	:= SuperGetMV("MV_XDWFCOT",.F.,.F.)

	Private cNomeFor 	:= ""
	Private cNameEmp	:= Alltrim(SM0->M0_NOMECOM)
	Private lWFCO		:= SC8->(FieldPos("C8_WFCO")) > 0
	Private lWFID		:= SC8->(FieldPos("C8_WFID")) > 0
	Private lWFEMAIL	:= SC8->(FieldPos("C8_WFEMAIL")) > 0
	Private lTrackWF	:= SuperGetMV("MV_XTRCKWF",.F.,.F.)

	// verifica se o workflow pode ser executado
	if ValidaExec()

		/*** Atualiza a variavel quando nao for a rotina automatica do configurador ***/
		If len( PswRet() ) # 0
			cUsermail := AllTrim(UsrRetMail(RetCodUsr())) 
			//cUsermail := SuperGetMV("MV_RELACNT")
			//cUsermail := PswRet()[1][14]
		EndIF

		// verifico se o alias já existe
		If Select("WAFORNEC") > 0
			WAFORNEC->(DbCloseArea())
		EndIf

		cQuery := " SELECT "
		cQuery += " SC8.C8_FILIAL, "
		cQuery += " SC8.C8_NUM, "
		cQuery += " SC8.C8_FORNECE, "
		cQuery += " SC8.C8_LOJA, "
		cQuery += " SC8.C8_ITEM, "
		cQuery += " SC8.C8_NUMPRO, "
		cQuery += " SC8.C8_ITEMGRD, "
		cQuery += " SC8.C8_VALIDA, "
		cQuery += " SC8.C8_CONTATO, "
		cQuery += " SC8.C8_ITEM, "
		cQuery += " SC8.C8_PRODUTO, "
		cQuery += " SC8.C8_QUANT, "
		cQuery += " SC8.C8_UM, "
		cQuery += " SC8.C8_DATPRF, "
		cQuery += " SC8.R_E_C_N_O_, "
		cQuery += " SA2.A2_COD, "
		cQuery += " SA2.A2_LOJA, "
		cQuery += " SA2.A2_NOME, "
		cQuery += " SA2.A2_END, "
		cQuery += " SA2.A2_MUN, "
		cQuery += " SA2.A2_BAIRRO, "
		cQuery += " SA2.A2_TEL, "
		cQuery += " SA2.A2_FAX, "
		cQuery += " SC8.C8_FORMAIL, "
		cQuery += " SA2.A2_COND, "
		cQuery += " SC1.C1_OBS, "
		cQuery += " SB1.B1_COD, "
		cQuery += " SB1.B1_DESC "

		if lWFCO
			cQuery += " , SC8.C8_WFCO "
		endif

		if lWFEMAIL
			cQuery += " , SA2.A2_EMAIL as C8_WFEMAIL "
		endif

		if lWFID
			cQuery += " , SC8.C8_WFID "
		endif

		cQuery += " FROM "
		cQuery += " " + RetSqlName("SC8") + " SC8 "
		cQuery += " INNER JOIN "
		cQuery += " " + RetSqlName("SA2") + " SA2 "
		cQuery += " ON ( "
		cQuery += "		SA2.D_E_L_E_T_ <> '*' "
		cQuery += "		AND SA2.A2_FILIAL = '" + xFilial("SA2") + "' "
		cQuery += "		AND SA2.A2_COD = SC8.C8_FORNECE "
		cQuery += "		AND SA2.A2_LOJA = SC8.C8_LOJA "
		cQuery += " ) "
		cQuery += " INNER JOIN "
		cQuery += " " + RetSqlName("SB1") + " SB1 "
		cQuery += " ON ( "
		cQuery += "		SB1.D_E_L_E_T_ <> '*' "
		cQuery += "		AND SB1.B1_FILIAL = '" + xFilial("SB1") + "' "
		cQuery += "		AND SB1.B1_COD = SC8.C8_PRODUTO "
		cQuery += " ) "
		cQuery += " INNER JOIN "
		cQuery += " " + RetSqlName("SC1") + " SC1 "
		cQuery += " ON ( "
		cQuery += "		SC1.D_E_L_E_T_ <> '*' "
		cQuery += "		AND SC1.C1_FILIAL  = '" + xFilial("SC1") + "' "
		cQuery += "		AND SC1.C1_PRODUTO = SC8.C8_PRODUTO "
		cQuery += "		AND SC1.C1_NUM     = SC8.C8_NUMSC "
		cQuery += "		AND SC1.C1_ITEM    = SC8.C8_ITEMSC "
		cQuery += " ) "
		cQuery += " WHERE "
		cQuery += " SC8.D_E_L_E_T_ = ' ' "
		cQuery += " AND SC8.C8_FILIAL = '" + xFilial("SC8") + "' "
		cQuery += " AND SC8.C8_NUM = '" + ParamIXB[1] + "' "

		If Type("ParamIXB[2]") == "C"

			cQuery += " AND SC8.C8_FORNECE = '" + ParamIXB[2] + "' "
			cQuery += " AND SC8.C8_LOJA = '" + ParamIXB[3] + "' "

		Endif

		// verifica se a cotação já foi respondida
		if lWFCO
			cQuery += " AND SC8.C8_WFCO <> '1004' "
		endif

		cQuery += " ORDER BY SC8.C8_FILIAL, SC8.C8_NUM, SA2.A2_COD, SA2.A2_LOJA, SB1.B1_DESC "

		cQuery := ChangeQuery(cQuery)
		//memowrite("C:\temp\sqlwf.sql",cQuery)

		// crio o alias temporario
		TcQuery cQuery New Alias "WAFORNEC" // Cria uma nova area com o resultado do query

		if WAFORNEC->(!Eof())

			SE4->(DbSetOrder(1)) // E4_FILIAL + E4_CODIGO
			SC8->(DbSetOrder(1)) // C8_FILIAL + C8_NUM + C8_FORNECE + C8_LOJA + C8_ITEM + C8_NUMPRO + C8_ITEMGRD

			// posiciona no primeiro registro
			SE4->( dbGoTop() )
			if SE4->(DbSeek(xFilial("SE4")))

				// percorro as condições de pagamento
				While !SE4->( Eof() ) .AND. SE4->E4_FILIAL == xFilial("SE4")
					aAdd( aCond, SE4->E4_CODIGO + " - " + SE4->E4_DESCRI )
					SE4->( DbSkip() )
				EndDo

			endif


			aadd(aMoeda, "R$"	) // Real
			aadd(aMoeda, "US$"	) // Dolar
			aadd(aMoeda, "€"	) // Euro


			// percorre todos os itens da cotação
			While WAFORNEC->(!Eof())

				cDescProd 	:= ""
				aCotacoes 	:= {}
				cEmailComp	:= ""

				// posiciono na cotação
				if SC8->(DbSeek(WAFORNEC->C8_FILIAL + WAFORNEC->C8_NUM + WAFORNEC->C8_FORNECE + WAFORNEC->C8_LOJA + WAFORNEC->C8_ITEM + WAFORNEC->C8_NUMPRO + WAFORNEC->C8_ITEMGRD))

					/*** Atualiza variaveis com as informacoes da cotacao posicionada ***/
					_cC8_FILIAL  	:= WAFORNEC->C8_FILIAL
					_cC8_NUM     	:= WAFORNEC->C8_NUM
					_cC8_FORNECE 	:= WAFORNEC->A2_COD
					_cC8_LOJA    	:= WAFORNEC->A2_LOJA
					cNomeFor 		:= alltrim(WAFORNEC->A2_NOME)
					_cEmlFor 		:= AllTrim(WAFORNEC->C8_FORMAIL)
					_cC8_RecNO   	:= WAFORNEC->R_E_C_N_O_
					aItensUpg 	 	:= {}
					nDiasTime		:= STOD(WAFORNEC->C8_VALIDA) - dDatabase

					// E-mail de teste
					if !Empty(cEmailTST)
						_cEmlFor := cEmailTST
					endif

					// se o fornecedor não tiver email
					if Empty(_cEmlFor)//

						Aviso("Atenção", "E-mail do fornecedor não informado! Não será possível realizar o envio", {"Ok"})

						// se existe o campo de ID do WF na tabela de cotação
						if lWFID

							/*** Atualizar a cotacao (SC8) para nao processar novamente (falta da informacao e-mail) ***/
							if RecLock('SC8')
								SC8->C8_WFID := "WF9999"
								SC8->( MsUnlock() )
							endif

						endif

						WAFORNEC->(DbSkip())
						Loop

					else

						/*** Inicia um novo Processo de Workflow para env ***/
						oProcess := TWFProcess():New( "COTPRE", "Cotação de Preços" )
						oProcess :NewTask( "Fluxo de Cotação de Preços", "/workflow/cotacao.htm" )

						if lTrackWF
							oProcess:Track('1000',"Gerando o Processo de Workflow para o fornecedor: "+Trim(cNomeFor),SubStr(cUsuario,7,15))
						endif

						/*** Preenche os dados do cabecalho ***/
						oHtml := oProcess:oHTML

						////////////////////////////////////////////////////////////////////////////////////
						/////////////// 		VARIAVEIS DO CABEÇALHO DA COTACAO			 ///////////////
						////////////////////////////////////////////////////////////////////////////////////

						oHtml:valbyname('proc_link2', 'http://'+SuperGetMv("MV_XWFWS")+"/" )
						oHtml:valbyname('proc_link3', 'http://'+SuperGetMv("MV_XWFWS")+SuperGetMv("MV_WFDIR")+"/" )

						oHtml:ValByName( "WF2P11", "WFHTTPRET.APL")
						oHtml:ValByName( "M0_NOMECOM"	, cNameEmp               			)
						oHtml:ValByName( "C8_CONTATO"	, WAFORNEC->C8_CONTATO  			)
						oHtml:ValByName( "C8_FILIAL"  	, WAFORNEC->C8_FILIAL				)
						oHtml:ValByName( "C8_NUM"    	, WAFORNEC->C8_NUM					)
						oHtml:ValByName( "C8_VALIDA" 	, DTOC(STOD(WAFORNEC->C8_VALIDA))	)
						oHtml:ValByName( "C8_FORNECE"	, WAFORNEC->A2_COD 					)
						oHtml:ValByName( "C8_LOJA"   	, WAFORNEC->A2_LOJA					)
						oHtml:ValByName( "A2_NOME"   	, WAFORNEC->A2_NOME  				)
						oHtml:ValByName( "A2_END"    	, WAFORNEC->A2_END    				)
						oHtml:ValByName( "A2_MUN"    	, WAFORNEC->A2_MUN    				)
						oHtml:ValByName( "A2_BAIRRO" 	, WAFORNEC->A2_BAIRRO 				)
						oHtml:ValByName( "A2_TEL"    	, WAFORNEC->A2_TEL    				)
						oHtml:ValByName( "A2_FAX"    	, WAFORNEC->A2_FAX    				)
						oHtml:ValByName( "C8_OBS"    	, ""								)

						/*** Preenche de Entrega ***/
						oHtml:ValByName( "C8_ENDENTREGA1", trim(SM0->M0_ENDENT) )
						oHtml:ValByName( "C8_ENDENTREGA2", trim(SM0->M0_CIDENT)+" - "+SM0->M0_ESTENT+" - "+trim(SM0->M0_CEPENT) )

						////////////////////////////////////////////////////////////////////////////////////
						/////////////// 			VARIAVEIS DOS ITENS DA COTACAO			 ///////////////
						////////////////////////////////////////////////////////////////////////////////////

						// percorre todos os itens da SC8 do mesmo fornecedor
						while WAFORNEC->(!Eof()) ;
						.AND. WAFORNEC->C8_FILIAL = xFilial("SC8") ;
						.AND. WAFORNEC->C8_NUM  = _cC8_NUM ;
						.AND. WAFORNEC->A2_COD 	= _cC8_FORNECE ;
						.AND. WAFORNEC->A2_LOJA = _cC8_LOJA

							// descrição da SB5
							if lDescSB5
								cDescProd := AllTrim(Posicione("SB5", 1, xFilial("SB5") + WAFORNEC->C8_PRODUTO, "B5_CEME" ))
							endif

							// se não tem descrição na SB5, considera a descriçao da SB1
							if Empty(cDescProd)
								cDescProd := AllTrim(WAFORNEC->B1_DESC)
							endif

							aAdd( (oHtml:ValByName( "it.item"    )) , WAFORNEC->C8_ITEM    							)
							aAdd( (oHtml:ValByName( "it.produto" )) , WAFORNEC->C8_PRODUTO 							)
							aAdd( (oHtml:ValByName( "it.descri"  )) , cDescProd 									)
							aAdd( (oHtml:ValByName( "it.obs"     )) , WAFORNEC->C1_OBS										)
							aAdd( (oHtml:ValByName( "it.quant"   )) , TRANSFORM(WAFORNEC->C8_QUANT,'@E 99,999.99' ) )
							aAdd( (oHtml:ValByName( "it.um"      )) , WAFORNEC->C8_UM      							)
							aAdd( (oHtml:ValByName( "it.moeda"   )) , aMoeda      									)
							aAdd( (oHtml:ValByName( "it.preco"   )) , TRANSFORM(0,'@E 99,999.99' ) 					)
							aAdd( (oHtml:ValByName( "it.valor"   )) , TRANSFORM(0,'@E 99,999.99' ) 					)
							aAdd( (oHtml:ValByName( "it.ipi"     )) , TRANSFORM(0,'@E 99.99' ) 						)
							aAdd( (oHtml:ValByName( "it.prazo"   )) , "0" 											)

							aAdd( aCotacoes, {WAFORNEC->R_E_C_N_O_,(WAFORNEC->A2_COD+WAFORNEC->A2_LOJA+WAFORNEC->B1_COD)})

							WAFORNEC->(DbSkip())

						EndDo

						////////////////////////////////////////////////////////////////////////////////////
						/////////////// 			VARIAVEIS DO RODAPE DA COTACAO			 ///////////////
						////////////////////////////////////////////////////////////////////////////////////

						oHtml:ValByName( "Pagamento"	, aCond    							)
						oHtml:ValByName( "Frete"    	, {"CIF","FOB"}   					)
						oHtml:ValByName( "subtot"   	, TRANSFORM( 0 ,'@E 999,999.99' ) 	)
						oHtml:ValByName( "vldesc"   	, TRANSFORM( 0 ,'@E 999,999.99' ) 	)
						oHtml:ValByName( "aliipi"   	, TRANSFORM( 0 ,'@E 999,999.99' ) 	)
						oHtml:ValByName( "valfre"   	, TRANSFORM( 0 ,'@E 999,999.99' ) 	)
						oHtml:ValByName( "totped"   	, TRANSFORM( 0 ,'@E 999,999.99' ) 	)

						////////////////////////////////////////////////////////////////////////////////////
						//////////////////////// 			ENVIO DO EMAIL			 ///////////////////////
						////////////////////////////////////////////////////////////////////////////////////

						oProcess:cSubject := "Processo de geração de Cotação de Preços N." + _cC8_NUM
						oProcess:cTo      := 'cotpre' //Documentação solicita que se altere para o usuário microsiga e não mais o email usando a variavel: _cEmlFor
						oProcess:bReturn  := "U_MT130WFR(1)" // Funçao de Retorno

						nDiasTime := iif(nDiasTime < 0,0,nDiasTime)

						oProcess:bTimeOut := { { "U_MT130WFR(3)", nDiasTime, 0 , 2 } } //oProcess:bTimeOut := { { funcao, dias, horas, minutos } }

						cMailID := oProcess:Start() // Inicia o processo com o Messenger ativo gera o HTML na pasta do usuário pelo messenger.

						cAviso 	:= 'Solicitação de Cotação de Preços N.' + _cC8_NUM + ' - ' + cNameEmp
						cLink	:= 'http://'+SuperGetMv("MV_XWFWS")+'/messenger'+'/emp' + cEmpAnt + '/'+'cotpre'+'/' + cMailId + '.htm'

						// Envia email de Aviso
						xHTM := '<HTML><BODY>'
						xHTM += '<hr>'
						xHTM += '<p  style="word-spacing: 0; line-height: 100%; margin-top: 0; margin-bottom: 0">'
						xHTM += '<b><font face="Verdana" SIZE=3>'+cAviso+' &nbsp; '+dtoc(date())+'&nbsp;&nbsp;&nbsp;'+time()+'</b></p>'
						xHTM += '<hr>'
						xHTM += '<br>'
						xHTM += '<b><font face="Verdana" SIZE=3> Prezado(a) Fornecedor(a)</b></p>'
						xHTM += '<br>'
						xHTM += 'Favor clicar no link abaixo para participar do processo de cotação em referência<BR> <br>'
						xHTM += "<a href="+cLink+" title="+cLink+">Ver Cotação</a> <br><br>  "//+cLink
						xHTM += '<p>'
						xHTM += '<b>Prezado(a) fornecedor(a), não responda esse e-mail,<br> para enviar a cotação, preencha o formulário através do link e clique em enviar.</b>'
						xHTM += '</BODY></HTML>'

						//Parametros necessarios para a rotina
						// MV_RELACNT - Conta a ser utilizada no envio de E-Mail
						// MV_RELFROM - E-mail utilizado no campo FROM no envio
						// MV_RELSERV - Nome do Servidor de Envio de E-mail utilizado no envio
						// MV_RELAUTH - Determina se o Servidor de Email necessita de Autenticação
						// MV_RELAUSR - Usuário para Autenticação no Servidor de Email
						// MV_RELAPSW - Senha para Autenticação no Servidor de Email

						// crio objeto para envio de e-mail
						oMail := SendMail():new()

						// defino o destinatário
						oMail:SetTo(_cEmlFor)

						// defino o remetente
						oMail:SetFrom(Alltrim(SuperGetMv("MV_RELFROM",," ")))

						// preencho o assunto do e-mail
						oMail:SetSubject('Solicitação de Cotação de Preços - ' + cNameEmp)

						// preencho o corpo do e-mail
						oMail:SetBody(xHTM)
						oMail:SetEchoMsg(.F.)

						// realiza o envio do e-mail
						lEnviado := oMail:Send()

						if lEnviado
							Aviso("Informação", "E-mail enviado com sucesso para o fornecedor : " + AllTrim(cNomeFor) + " e-mail: " + Trim(_cEmlFor) , {"Ok"})
						else
							Alert(oMail:CLOGMSG)
						endif

						if lTrackWF
							oProcess:Track('1001',"Enviando o e-mail para o fornecedor: "+Trim(cNomeFor),SubStr(cUsuario,7,15))
						endif

						// atualiza as cotações
						AtuSC8(aCotacoes,cUsermail,oProcess)

						if lTrackWF
							oProcess:Track('1002',"Aguardando retorno do fornecedor: "+Trim(cNomeFor),SubStr(cUsuario,7,15))
						endif

					endif

				endif

				If lCopia .AND. MsgYesNo("Deseja receber uma cópia da cotação?")

					if SuperGetMv("MV_XATUWF",,.F.)

						SC8->(RecLock("SC8",.F.))
						SC8->C8_WFEMAIL := AllTrim(UsrRetMail(RetCodUsr())) 
						SC8->(MsUnLock())

					endif

					if lWFEMAIL
						cEmailComp := SC8->C8_WFEMAIL
					endif

					if Empty(cEmailComp)
						cEmailComp := SuperGetMv("MV_XWFCMP")
					endif

					xHTM := '<HTML><BODY>'
					xHTM += '<hr>'
					xHTM += '<p  style="word-spacing: 0; line-height: 100%; margin-top: 0; margin-bottom: 0">'
					xHTM += '<b><font face="Verdana" SIZE=3>'+cAviso+' &nbsp; '+dtoc(date())+'&nbsp;&nbsp;&nbsp;'+time()+'</b></p>'
					xHTM += '<hr>'
					xHTM += '<br>'
					xHTM += '<b><font face="Verdana" SIZE=3> Prezado(a) Fornecedor(a)</b></p>'
					xHTM += '<br>'
					xHTM += 'Favor clicar no link abaixo para participar do processo de cotação em referencia<BR> <br>'
					xHTM += "<a href="+cLink+" title="+cLink+">Ver Cotação</a> <br><br>  "//+cLink
					xHTM += '<p>'
					xHTM += '<b>Prezado(a) comprador(a), não responda esse e-mail,<br> Não envie a cotação, esse processo deve ser feito pelo fornecedor.</b>'
					xHTM += '</BODY></HTML>'

					// crio objeto para envio de e-mail
					oMail := SendMail():new()

					// defino o destinatário
					oMail:SetTo(cEmailComp)

					// defino o remetente
					oMail:SetFrom(Alltrim(SuperGetMv("MV_RELFROM",," ")))

					// preencho o assunto do e-mail
					oMail:SetSubject('Solicitação de Cotação de Preços - '+cNameEmp)

					// preencho o corpo do e-mail
					oMail:SetBody(xHTM)
					oMail:SetEchoMsg(.F.)

					lEnviado := oMail:Send()

				endif
				//WAFORNEC->(DbSkip())
			EndDo

		endif

		// verifico se o alias já existe
		If Select("WAFORNEC") > 0
			WAFORNEC->(DbCloseArea())
		EndIf

		if lWFEMAIL.and.type("SC8->C8_WFEMAIL") == 'U'
			AVISO("Atenção", "Para este processo funcionar é necessário criaro o campo SC8->C8_WFEMAIL!", {"Ok"})
			return
		endif

	endif

	/*** Restaura Ambiente ***/
	RestArea( _AreaSC8 )
	RestArea( _AreaSE4 )
	RestArea( _AreaSB1 )

Return NIL

/*###########################################################################
#############################################################################
## Programa  | MT130WFR | Autor | Wellington Gonçalves | Data | 02/04/2019 ##
##=========================================================================##
## Desc.     | Faz a gravação do retorno do Workflow					   ##
##=========================================================================##
## Uso       | Linea		                                               ##
#############################################################################
###########################################################################*/

User Function MT130WFR(AOpcao, oProcess)

	Local aCab   		:={}
	Local nTotaCot		:= 0
	Local _nMoedaCot	:= 0
	Local aRelImp 		:= MaFisRelImp("MT150",{"SC8"})
	Local _AreaSC8 		:= SC8->( GetArea() )
	Local _AreaSE4 		:= SE4->( GetArea() )
	Local _AreaSB1 		:= SB1->( GetArea() )
	Local aProdPrench	:= {}
	Local _cValPreco 	:= ""
	Local cFilCot		:= ""
	Local cNumCot		:= ""
	Local cFornCot		:= ""
	Local cLojaCot		:= ""
	Local cItemCot		:= ""
	Local cEmailComp	:= ""
	Local _cMoedaCot	:= ""
	Local _nVlrPreco 	:= _nTotPed := _nVlDesc := 0
	Local nPercentItem	:= 0
	Local cEmailTST		:= SuperGetMV("MV_WFETST",.F.,'')
	Local lFreteProp	:= SuperGetMV("MV_XFRETPR",.F.,.T.)
	Local nY, nX, _nInd

	Private cNameEmp	:= Alltrim(SM0->M0_NOMECOM)
	Private lWFCO		:= SC8->(FieldPos("C8_WFCO"))> 0
	Private lWFID		:= SC8->(FieldPos("C8_WFID"))> 0
	Private lWFEMAIL	:= SC8->(FieldPos("C8_WFEMAIL"))> 0
	Private lTrackWF	:= SuperGetMV("MV_XTRCKWF",.F.,.F.)

	if ValType(aOpcao) = "A"
		aOpcao := aOpcao[1]
	endif

	if aOpcao == NIL
		aOpcao := 0
	elseif aOpcao == 1

		_cC8_NUM     := oProcess:oHtml:RetByName("C8_NUM"     )
		_cC8_Filial  := oProcess:oHtml:RetByName("C8_FILIAL"     )
		_cC8_FORNECE := oProcess:oHtml:RetByName("C8_FORNECE" )
		_cC8_LOJA    := oProcess:oHtml:RetByName("C8_LOJA"    )

	elseif aOpcao == 2

		_cC8_NUM     := oProcess:oHtml:RetByName("C8_NUM"     )
		_cC8_Filial  := oProcess:oHtml:RetByName("C8_FILIAL"     )
		_cC8_FORNECE := oProcess:oHtml:RetByName("C8_FORNECE" )
		_cC8_LOJA    := oProcess:oHtml:RetByName("C8_LOJA"    )

	elseif aOpcao == 3 //TimeOut

		SPCTimeOut( oProcess )
		Return

	endif

	dbSelectArea("SC8")
	dbSetOrder(1)
	if SC8->(!DbSeek( _cC8_Filial + Padr(_cC8_NUM,6) + _cC8_FORNECE + _cC8_LOJA ))
		U_UWCLogMsg("INICIO DE RETORNO WF COTACAO ( WF COTACAO) Data: "+dtoc(ddatabase)+ "Hora: "+time()+" Não achou SC8 (1): " + _cC8_Filial + Padr(_cC8_NUM,6) + _cC8_FORNECE + _cC8_LOJA )
	endif

	// se o fornecedor clicou na opção de aprovação
	if oProcess:oHtml:RetByName("Aprovacao") = "S"

		if lTrackWF
			oProcess:Track('1003',"Processando a resposta da Cotação N." + _cC8_NUM + " do Fornecedor: " + _cC8_FORNECE , SubStr(cUsuario,7,15))
		endif

		_cC8_VLDESC := oProcess:oHtml:RetByName("VLDESC" )
		_cC8_ALIIPI := oProcess:oHtml:RetByName("ALIIPI" )
		_cC8_VALFRE := oProcess:oHtml:RetByName("VALFRE" )

		/*** Verifica o frete ***/
		if oProcess:oHtml:RetByName("Frete") = "FOB"
			_cC8_RATFRE := 0
		endif

		/*** Atualizacao dos valores da cotacao na SC8 ***/
		for _nind := 1 to len(oProcess:oHtml:RetByName("it.preco"))

			//BASE DO ICMS
			MaFisIni(PADR(_cC8_FORNECE,9,""),_cC8_LOJA,"F","N","R",aRelImp)
			MaFisIniLoad(1)

			For nY := 1 To Len(aRelImp)
				MaFisLoad(aRelImp[nY][3],SC8->(FieldGet(FieldPos(aRelImp[nY][2]))),1)
			Next nY

			MaFisEndLoad(1)

			dbSelectArea("SB1")
			SB1->(DbSetOrder(1)) // B1_FILIAL + B1_COD
			SB1->(DbSeek( xFilial("SB1") + oProcess:oHtml:RetByName("it.produto")[_nind] ))
			cIcm := SC8->C8_PICM

			_cC8_ITEM := oProcess:oHtml:RetByName("it.item")[_nind]
			dbSelectArea("SC8")
			SC8->(DbSetOrder(1))
			if !SC8->(DbSeek( _cC8_Filial + Padr(_cC8_NUM,6) + _cC8_FORNECE + _cC8_LOJA + _cC8_ITEM ))
				U_UWCLogMsg("INICIO DE RETORNO WF COTACAO ( WF COTACAO) Data: " + dtoc(ddatabase) + "Hora: " + time() + " Não achou SC8 (2): " + _cC8_Filial + Padr(_cC8_NUM,6) + _cC8_FORNECE + _cC8_LOJA)
			endif

			/*** Verifica se o prazo tenha vencido não permite gravacao ***/
			If lWFID .AND. SC8->C8_WFID = "9999"

				if lTrackWF
					oProcess:Track('1004',"Cotação N." + Padr(_cC8_NUM,6) + " recebida fora do prazo do fornecedor: " + _cC8_FORNECE, SubStr(cUsuario,7,15))
				endif

				/*** Restaura Ambiente ***/
				RestArea( _AreaSC8 )
				RestArea( _AreaSE4 )
				RestArea( _AreaSB1 )
				Return

			EndIf

			dbSelectArea("SC8")
			dbSetOrder(1)
			if SC8->(dbSeek( _cC8_Filial + Padr(_cC8_NUM,6) + _cC8_FORNECE + _cC8_LOJA + _cC8_ITEM ))

				if RecLock("SC8",.F.)

					if lWFCO
						SC8->C8_WFCO   := "1004"
					endif

					SC8->C8_MOTIVO := trim( oProcess:oHtml:RetByName("c8_obs") )
					SC8->C8_OBS    := Substr(Dtoc(Date()),1,5)+'-'+Substr(Time(),1,5)+':'+SC8->C8_MOTIVO

					_cValPreco := StrTran(AllTrim(oProcess:oHtml:RetByName("it.preco")[_nind]),",",".")
					SC8->C8_PRECO  := Round(Val(_cValPreco),TamSX3("C8_PRECO")[2])

					_cValPreco := StrTran(AllTrim(oProcess:oHtml:RetByName("it.valor")[_nind]),",",".")
					SC8->C8_TOTAL  := Round(Val(_cValPreco),TamSX3("C8_TOTAL")[2])

					_cValPreco := StrTran(AllTrim(oProcess:oHtml:RetByName("it.ipi")[_nind]),",",".")
					SC8->C8_ALIIPI := Round(Val(_cValPreco),TamSX3("C8_ALIIPI")[2])

					_nPrazo := Trim(oProcess:oHtml:RetByName("it.prazo")[_nind])
					SC8->C8_PRAZO  := Val( _nPrazo )

					_cMoedaCot := Trim(oProcess:oHtml:RetByName("it.moeda")[_nind])

					if _cMoedaCot == "R$"
						_nMoedaCot := 1
					elseif _cMoedaCot == "US$"
						_nMoedaCot := 2
					elseif _cMoedaCot == "€"
						_nMoedaCot := 4
					else
						_nMoedaCot := 1
					endif

					if !Empty(_cMoedaCot)
						SC8->C8_XMOEDA  := _nMoedaCot
					endif

					//caso o IPI não seja zero
					If Val(oProcess:oHtml:RetByName("it.ipi"  )[_nind])>0
						C8_VALIPI  := (Val(oProcess:oHtml:RetByName("it.ipi"  )[_nind])*Val(oProcess:oHtml:RetByName("it.valor")[_nind]))/100
						C8_BASEIPI := SC8->C8_TOTAL
					EndIf

					//caso o icm nao seja zero
					MaFisAlt("IT_ALIQICM",cIcm,1)
					C8_PICM        := MaFisRet(1,"IT_ALIQICM")

					If C8_PICM >0

						C8_BASEICM     := SC8->C8_TOTAL
						MaFisAlt("IT_VALICM",cIcm,1)
						C8_VALICM      := MaFisRet(1,"IT_VALICM")

					EndIf

					SC8->C8_COND   := Substr(oProcess:oHtml:RetByName("pagamento"),1,3)
					SC8->C8_TPFRETE:= Substr(oProcess:oHtml:RetByName("Frete"),1,1)


					/*** Preenche variaveis ***/
					_cValPreco := StrTran(AllTrim(oProcess:oHtml:RetByName("it.preco")[_nind]),",",".")
					_nVlrPreco := Round(Val(_cValPreco),TamSX3("C8_PRECO")[2])

					_cValPreco := StrTran(AllTrim(oProcess:oHtml:RetByName("totped")),",",".")
					_nTotPed := Round(Val(_cValPreco),TamSX3("C8_PRECO")[2])


					_cValFrete := StrTran(AllTrim(oProcess:oHtml:RetByName("valfre")),",",".")
					U_UWCLogMsg("( WF COTACAO) Data: "+dtoc(ddatabase)+ "Hora: "+time()+" Valor Frete: "+_cValFrete )

					_cValFrete := Round(Val(_cValFrete),TamSX3("C8_PRECO")[2])

					//carrego os itens preenchidos na cotacao para calcular proporcionalmente o frete para os produtos
					if lFreteProp .And. SC8->C8_TOTAL > 0 .And. _cValFrete > 0

						Aadd( aProdPrench, {SC8->C8_FILIAL,;
						SC8->C8_NUM,;
						SC8->C8_FORNECE,;
						SC8->C8_LOJA,;
						SC8->C8_ITEM,;
						_cValFrete } )

					endif

					nTotaCot += SC8->C8_TOTAL

					//caso nao esteja ativado o frete proporcional, replica o valor para todos os itens
					if !lFreteProp
						SC8->C8_VALFRE := _cValFrete 
						U_UWCLogMsg("( WF COTACAO) Data: "+dtoc(ddatabase)+ "Hora: "+time()+" Gravado Valor Frete2: "+alltrim(str(_cValFrete)) )
					endif

					/*** Preenche variaveis (valor desconto) ***/
					_vldesc := StrTran(AllTrim(oProcess:oHtml:RetByName("vldesc")),",",".")
					_vldesc := Round(Val(_vldesc),TamSX3("C8_PRECO")[2])

					if _vldesc <= 0
						SC8->C8_VLDESC := 0
					else
						SC8->C8_VLDESC := ( (Val(oProcess:oHtml:RetByName("it.quant")[_nind]) * (_nVlrPreco / (_nTotPed +_vldesc)) ) * _vldesc )
					endif

					SC8->(MsUnlock())

					MaFisEnd()

				endif

			else
				U_UWCLogMsg("INICIO DE RETORNO WF COTACAO ( WF COTACAO) Data: "+dtoc(ddatabase)+ "Hora: "+time()+" Não achou SC8 (2): " + _cC8_Filial + Padr(_cC8_NUM,6) + _cC8_FORNECE + _cC8_LOJA)
			endif

		next

		//calculo o valor de frete proporcional aos itens preenchidos
		if lFreteProp

			SC8-> ( DbSetOrder(1) ) //C8_FILIAL+C8_NUM+C8_FORNECE+C8_LOJA+C8_ITEM+C8_NUMPRO+C8_ITEMGRD

			For nX := 1 To Len( aProdPrench )

				cFilCot		:= aProdPrench[nX,1]
				cNumCot		:= aProdPrench[nX,2]
				cFornCot	:= aProdPrench[nX,3]
				cLojaCot	:= aProdPrench[nX,4]
				cItemCot	:= aProdPrench[nX,5]
				nFreteCot	:= aProdPrench[nX,6]

				if SC8->( DbSeek( cFilCot + cNumCot + cFornCot + cLojaCot +  cItemCot ) )

					//proporcao do item sobre a cotacao
					nPercentItem	:= SC8->C8_TOTAL / nTotaCot

					//calculo o frete proporcional ao item
					nFreteItem	:= NoRound( nFreteCot * nPercentItem, 2 )

					if RecLock("SC8",.F.)
						SC8->C8_VALFRE	:= nFreteItem
						SC8->( MsUnlock() )
					endif

				endif

			Next nX

		endif

		if lTrackWF
			oProcess:Track('1005', "Concluido a atualzação da cotação do fornecedor: "+_cC8_FORNECE, SubStr(cUsuario,7,15))
		endif

		if lWFEMAIL
			cEmailComp := SC8->C8_WFEMAIL
		endif

		if Empty(cEmailComp)
			cEmailComp := SuperGetMv("MV_XWFCMP")
		endif

		Aprovar(oProcess,cEmailComp,_cC8_NUM,_cC8_Filial)

		oProcess:Finish()  //Finalizo o Processo

	Else //caso tenha sido rejeitado

		aCab := {	{"C8_NUM"	,_cC8_NUM,NIL}}

		if lTrackWF
			oProcess:Track('1006', "O fornecedor "+_cC8_FORNECE+" informou sua desistência no processo de Cotação N."+Padr(_cC8_NUM,6), SubStr(cUsuario,7,15))
		endif

		/*** Atualiza os itens da cotação na SC8 ***/
		for _nind := 1 to len(oProcess:oHtml:RetByName("it.preco"))

			_cC8_ITEM := oProcess:oHtml:RetByName("it.item")[_nind]

			dbSelectArea("SC8")
			SC8->(dbSetOrder(1))

			if !SC8->(dbSeek( _cC8_Filial + Padr(_cC8_NUM,6) + _cC8_FORNECE + _cC8_LOJA + _cC8_ITEM ))
				U_UWCLogMsg("INICIO DE RETORNO WF COTACAO ( WF COTACAO) Data: "+dtoc(ddatabase)+ "Hora: "+time()+" Não achou SC8 (3): " + _cC8_Filial + Padr(_cC8_NUM,6) + _cC8_FORNECE + _cC8_LOJA )
			endif

			if RecLock("SC8",.f.)
				SC8->C8_MOTIVO := Substr(Dtoc(Date()),1,5)+'-'+Substr(Time(),1,5)+':'+trim( oProcess:oHtml:RetByName("c8_obs") )
				SC8->C8_OBS    := SC8->C8_MOTIVO
				SC8->(MsUnlock())
			endif

			if lTrackWF
				oProcess:Track('1007',"Cancelado a Cotação N."+Padr(_cC8_NUM,6)+" do fornecedor "+_cC8_FORNECE, SubStr(cUsuario,7,15))
			endif

		Next

		if lWFEMAIL
			cEmailComp := SC8->C8_WFEMAIL
		endif

		if Empty(cEmailComp)
			cEmailComp := SuperGetMv("MV_XWFCMP")
		endif

		//Email para teste Claudio 11.05.15
		if !empty(cEmailTST)
			cEmailComp := cEmailTST
		endif

		if lTrackWF
			oProcess:Track('1008',"Enviando e-mail de NOTIFICAÇÃO ao Comprador de desistência do fornecedor: "+_cC8_FORNECE+" da Cotação de Preços N."+Padr(_cC8_NUM,6), SubStr(cUsuario,7,15))
		endif

		Reprovar(oProcess, cEmailComp, _cC8_NUM,_cC8_Filial)

		oProcess:Finish()  //Finalizo o Processo

	endif

	/*** Restaura Ambiente ***/
	RestArea( _AreaSC8 )
	RestArea( _AreaSE4 )
	RestArea( _AreaSB1 )

Return

/*###########################################################################
#############################################################################
## Programa  | Reprovar  | Autor | Wellington Gonçalves |Data | 03/04/2019 ##
##=========================================================================##
## Desc.     | Função de Reprovação da Cotação							   ##
##=========================================================================##
## Uso       | Linea		                                               ##
#############################################################################
###########################################################################*/

Static function Reprovar(oProcess,cEmailComp,_cC8_NUM,_cC8_Filial)

	Local _user 		:= Subs(cUsuario,7,15)
	Local _cHTM 		:= ""
	Local _cNrCotacao 	:= oProcess:oHtml:RetByName("C8_FORNECE") + oProcess:oHtml:RetByName("C8_LOJA")
	Local _cAviso		:= "NOTIFICAÇÃO - Desistência do fornecedor na Cotação de Preços - " + cNameEmp + "  Nr. " + _cC8_NUM
	Local _cFornecedor 	:= Posicione("SA2", 1, xFilial("SA2") + _cNrCotacao, "A2_NOME" )
	Local cEmailTST		:= SuperGetMV("MV_WFETST",.F.,'')
	Local lEnviado		:= .F.
	Private lWFEMAIL	:= SC8->(FieldPos("C8_WFEMAIL")) > 0
	Private lTrackWF	:= SuperGetMV("MV_XTRCKWF",.F.,.F.)

	_cHTM := '<HTML><BODY>'
	_cHTM += '<hr>'
	_cHTM += '<p  style="word-spacing: 0; line-height: 100%; margin-top: 0; margin-bottom: 0">'
	_cHTM += '<b><font face="Verdana" SIZE=3>'+_cAviso+' &nbsp; '+dtoc(date())+'&nbsp;&nbsp;&nbsp;'+time()+'</b></p>'
	_cHTM += '<hr>'
	_cHTM += '<br>'
	_cHTM += '<br>'
	_cHTM += 'O fornecedor <b>'+Trim(_cFornecedor)+'</b> informa sua desistência na Cotação de Nr. <b>'+_cC8_NUM+'</b>, Filial: <b>'+_cC8_Filial+'</b> <BR><BR>'
	_cHTM += 'Sob motivo: <b>'+oProcess:oHtml:RetByName("C8_OBS")+'</b> <BR><BR>'
	_cHTM += '</BODY></HTML>'

	//Email para teste Claudio 11.05.15
	if !empty(cEmailTST)
		cEmailComp:=cEmailTST
	endif

	U_UWCLogMsg("Enviando e-mail para o comprador: " + cEmailComp)

	oMail := SendMail():new()
	oMail:SetTo(cEmailComp)
	oMail:SetFrom(Alltrim(SuperGetMv("MV_RELFROM",," ")))
	oMail:SetSubject(_cAviso)
	oMail:SetBody(_cHTM)
	oMail:SetEchoMsg(.f.)

	// realiza o envio do e-mail
	lEnviado := oMail:Send()

	if lEnviado
		U_UWCLogMsg("E-mail enviado com sucesso!")
	else
		U_UWCLogMsg("Erro no envio do e-mail!")
	endif

	if lTrackWF
		oProcess:Track('1009',"Finalizado a participação do fornecedor: "+_cC8_FORNECE+" da Cotação de Preços N."+Padr(_cC8_NUM,6), SubStr(cUsuario,7,15))
	endif

return

/*###########################################################################
#############################################################################
## Programa  | Aprovar  | Autor | Wellington Gonçalves | Data | 03/04/2019 ##
##=========================================================================##
## Desc.     | Função de Aprovação da Cotação							   ##
##=========================================================================##
## Uso       | Linea		                                               ##
#############################################################################
###########################################################################*/

Static function Aprovar(oProcess,cEmailComp,_cC8_NUM,_cC8_Filial)

	Local _user 		:= Subs(cUsuario,7,15)
	Local _cHTM 		:= ""
	Local _cNrCotacao 	:= oProcess:oHtml:RetByName("C8_FORNECE")+oProcess:oHtml:RetByName("C8_LOJA")
	Local _cAviso		:= "NOTIFICAÇÃO - Participação do fornecedor na Cotação de Preços - "+cNameEmp+"  Nr. "+_cC8_NUM
	Local _cFornecedor 	:= Posicione("SA2", 1, xFilial("SA2")+_cNrCotacao, "A2_NOME" )
	Local cEmailTST		:= SuperGetMV("MV_WFETST",.F.,'')
	Local lEnviado		:= .F.
	Private lWFEMAIL	:= SC8->(FieldPos("C8_WFEMAIL"))> 0
	Private lTrackWF	:= SuperGetMV("MV_XTRCKWF",.F.,.F.)

	_cHTM := '<HTML><BODY>'
	_cHTM += '<hr>'
	_cHTM += '<p  style="word-spacing: 0; line-height: 100%; margin-top: 0; margin-bottom: 0">'
	_cHTM += '<b><font face="Verdana" SIZE=3>'+_cAviso+' &nbsp; '+dtoc(date())+'&nbsp;&nbsp;&nbsp;'+time()+'</b></p>'
	_cHTM += '<hr>'
	_cHTM += '<br>'
	_cHTM += '<br>'
	_cHTM += 'O fornecedor <b>'+Trim(_cFornecedor)+'</b> informa sua participação na Cotação de Nr. <b>'+_cC8_NUM+'</b>, Filial: <b>'+_cC8_Filial+'</b> <BR><BR>'
	_cHTM += 'Sob motivo: <b>'+oProcess:oHtml:RetByName("C8_OBS")+'</b> <BR><BR>'
	_cHTM += '</BODY></HTML>'

	//Email para teste Claudio 11.05.15
	if !empty(cEmailTST)
		cEmailComp := cEmailTST
	endif

	U_UWCLogMsg("Enviando e-mail para o comprador: " + cEmailComp)

	oMail := SendMail():new()
	oMail:SetTo(cEmailComp)
	oMail:SetFrom(Alltrim(SuperGetMv("MV_RELFROM",," ")))
	oMail:SetSubject(_cAviso)
	oMail:SetBody(_cHTM)
	oMail:SetEchoMsg(.f.)

	// realiza o envio do e-mail
	lEnviado := oMail:Send()

	if lEnviado
		U_UWCLogMsg("E-mail enviado com sucesso!")
	else
		U_UWCLogMsg("Erro no envio do e-mail!")
	endif

	if lTrackWF
		oProcess:Track('1009',"Finalizado a participação do fornecedor: "+_cC8_FORNECE+" da Cotação de Preços N."+Padr(_cC8_NUM,6), SubStr(cUsuario,7,15))
	endif

return

/*###########################################################################
#############################################################################
## Programa  | SPCTimeOut  |Autor| Wellington Gonçalves |Data | 03/04/2019 ##
##=========================================================================##
## Desc.     | Função de TimeOut										   ##
##=========================================================================##
## Uso       | Linea		                                               ##
#############################################################################
###########################################################################*/

Static Function SPCTimeOut( oProcess )

	Local cEmailTST		:= SuperGetMV("MV_WFETST",.F.,'')
	Local lEnviado		:= .F.
	Local _nInd

	Private cNameEmp	:= Alltrim(SM0->M0_NOMECOM)
	Private lWFEMAIL	:= SC8->(FieldPos("C8_WFEMAIL"))> 0
	Private lTrackWF	:= SuperGetMV("MV_XTRCKWF",.F.,.F.)

	_cC8_NUM     := oProcess:oHtml:RetByName("C8_NUM"     )
	_cC8_Filial  := oProcess:oHtml:RetByName("C8_FILIAL"     )
	_cC8_FORNECE := oProcess:oHtml:RetByName("C8_FORNECE" )
	_cC8_LOJA    := oProcess:oHtml:RetByName("C8_LOJA"    )

	U_UWCLogMsg("Funcao de TIMEOUT executada Cotação " + _cC8_NUM + " " + _cC8_FORNEC )

	/*** PEGA O EMAIL PARA AVISAR O COMPRADOR ***/
	cEmailComp := if(lWFEMAIL,SC8->C8_WFEMAIL,SuperGetMv("MV_XWFCMP"))

	/*** Atualiza os itens da cotação na SC8 ***/
	for _nind := 1 to len(oProcess:oHtml:RetByName("it.preco"))

		_cC8_ITEM := oProcess:oHtml:RetByName("it.item")[_nind]

		dbSelectArea("SC8")
		SC8->(DbSetOrder(1))
		if SC8->(dbSeek( _cC8_Filial + Padr(_cC8_NUM,6) + _cC8_FORNECE + _cC8_LOJA + _cC8_ITEM ))

			if RecLock("SC8",.f.)
				SC8->C8_MOTIVO := 'AUTOMATICO: Falta de retorno'
				SC8->C8_OBS    := SC8->C8_MOTIVO
				SC8->(MsUnlock())
			endif

		endif

		if lWFEMAIL
			cEmailComp := SC8->C8_WFEMAIL
		else
			cEmailComp := SuperGetMv("MV_XWFCMP")
		endif

		//Email para teste Claudio 11.05.15
		if !empty(cEmailTST)
			cEmailComp:=cEmailTST
		endif

		if lTrackWF
			oProcess:Track('1007',"Cancelado a Cotação N." + Padr(_cC8_NUM,6) + " do fornecedor " + _cC8_FORNECE, SubStr(cUsuario,7,15))
		endif

	Next

	_cAviso :="NOTIFICAÇÃO - Cotação finalizada por falta de resposta - " + cNameEmp + "- Cotação No " + _cC8_NUM
	_cHTM := '<HTML><BODY>'
	_cHTM += '<hr>'
	_cHTM += '<p  style="word-spacing: 0; line-height: 100%; margin-top: 0; margin-bottom: 0">'
	_cHTM += '<b><font face="Verdana" SIZE=3>'+_cAviso+' &nbsp; '+dtoc(date())+'&nbsp;&nbsp;&nbsp;'+time()+'</b></p>'
	_cHTM += '<hr>'
	_cHTM += '<br>'
	_cHTM += '<br>'
	_cHTM += 'O fornecedor <b>'+_cC8_FORNECE+'</b> teve sua Cotação finalizada por falta de retorno - Cotação Nr. <b>'+_cC8_NUM+'</b> <BR><BR>'
	_cHTM += '</BODY></HTML>'

	U_UWCLogMsg("Enviando e-mail para o comprador: " + cEmailComp)

	oMail := SendMail():new()
	oMail:SetTo(cEmailComp)
	oMail:SetFrom(Alltrim(SuperGetMv("MV_RELFROM",," ")))
	oMail:SetSubject(_cAviso)
	oMail:SetBody(_cHTM)
	oMail:SetEchoMsg(.t.)

	// realiza o envio do e-mail
	lEnviado := oMail:Send()

	if lEnviado
		U_UWCLogMsg("E-mail enviado com sucesso!")
	else
		U_UWCLogMsg("Erro no envio do e-mail!")
	endif

	oProcess:Finish()  //Finalizo o Processo

Return

/*###########################################################################
#############################################################################
## Programa  | ValidaExec |Autor| Wellington Gonçalves | Data | 02/04/2019 ##
##=========================================================================##
## Desc.     | Função que valida se o WF será executado					   ##
##=========================================================================##
## Uso       | Linea		                                               ##
#############################################################################
###########################################################################*/

Static Function ValidaExec()

	Local lWFDesabilit	:= SuperGetMV("MV_XDWFCOT",.F.,.F.)
	Local cLinkWF		:= SuperGetMv("MV_XWFWS")
	Local cDirWF		:= SuperGetMv("MV_WFDIR")
	Local lRet			:= .T.

	// se o WorkFlow estiver ativo
	if lWFDesabilit
		lRet := .F.
	else

		// Não executa na exclusão da cotação
		If Type("ParamIXB[1]") == "N" .And. ParamIXB[1] == 5
			lRet := .F.
		else

			if Empty(cLinkWF)
				AVISO("Atenção", "O parametro MV_XWFWS não foi informado! O processo de WF de Cotação será abortado!", {"Ok"})
				lRet := .F.
			else

				if Empty(cDirWF)
					AVISO("Atenção", "O parametro MV_WFDIR não foi informado! O processo de WF de Cotação será abortado!", {"Ok"})
					lRet := .F.
				endif

			endif

		endif

	endif

Return(lRet)

/*###########################################################################
#############################################################################
## Programa  | AtuSC8 | Autor | Wellington Gonçalves   | Data | 02/04/2019 ##
##=========================================================================##
## Desc.     | Função que atualiza as cotações							   ##
##=========================================================================##
## Uso       | Linea		                                               ##
#############################################################################
###########################################################################*/

Static Function AtuSC8(aCotacoes,cUsermail,oProcess)

	Local aArea		:= GetArea()
	Local aAreaSC8	:= SC8->(GetArea())
	Local nX 		:= 1

	// Busca os itens para Gravar as informações já processadas do WorkFlow
	For nX := 1 to Len(aCotacoes)

		// posiciona na cotação
		SC8->( DbGoTo(aCotacoes[nX,1]) )

		if RecLock('SC8',.F.)

			if lWFEMAIL
				SC8->C8_WFEMAIL := iif( cUsername == "Administrador", SuperGetMV("MV_RELACNT"), cUsermail )
			endif

			if lWFID
				SC8->C8_WFID := oProcess:fProcessID
			endif

			SC8->( MsUnlock() )

		endif

	Next nX

	RestArea(aAreaSC8)
	RestArea(aArea)

Return()
