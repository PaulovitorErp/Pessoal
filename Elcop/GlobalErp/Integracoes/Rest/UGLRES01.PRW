#INCLUDE "PROTHEUS.CH"
#INCLUDE "TOTVS.CH"
#INCLUDE "APWEBSRV.CH" 
#INCLUDE 'RESTFUL.CH'
#INCLUDE "topconn.ch"
#INCLUDE "TBICONN.CH"  

/*###########################################################################
#############################################################################
## Programa  | UGLOBAL03 | Autor| Adriano Reis		  | Data | 25/12/2020  ##
##=========================================================================##
## Desc.     | Server API Rest Integração - Protheus x Plataforma Web      ##
##=========================================================================##
## Uso       | GlobalErp Tecnologia		                                   ##
#############################################################################
###########################################################################*/

User Function UGlrest01()
Return()
	
WSRESTFUL Glrest01 DESCRIPTION "EndPoint GlobalErp Tecnologia - API Protheus x Plataforma Web"

	WSDATA cWSEmpresa 	 AS CHARACTER OPTIONAL
	WSDATA cWSFilial 	 AS CHARACTER OPTIONAL
	WSDATA clientecnpj 	 AS CHARACTER OPTIONAL
	WSDATA email	 	 AS CHARACTER OPTIONAL
	WSDATA password 	 AS CHARACTER OPTIONAL
	WSDATA chavelogin 	 AS CHARACTER OPTIONAL
	WSDATA Codvendedor   AS CHARACTER OPTIONAL 
	WSDATA nomecliente   AS CHARACTER OPTIONAL 
	WSDATA FiltroCliente AS CHARACTER OPTIONAL 
	WSDATA token		 AS CHARACTER OPTIONAL 
	WSDATA statusorc     AS CHARACTER OPTIONAL 	
	WSDATA CodigoDe  	 AS CHARACTER OPTIONAL     
	WSDATA CodigoAte 	 AS CHARACTER OPTIONAL
	WSDATA EmissaoDe     AS CHARACTER OPTIONAL
	WSDATA EmissaoAte    AS CHARACTER OPTIONAL
	
  	WSMETHOD POST incluisa ;
	DESCRIPTION "Inclui solicitacao ao armazem" ;
	PATH "/incluisa" ;
	WSSYNTAX "/Glrest01/incluisa"

  	WSMETHOD POST aprovsa ;
	DESCRIPTION "Aprova solicitacao ao armazem" ;
	PATH "/aprovsa" ;
	WSSYNTAX "/Glrest01/aprovsa"

	WSMETHOD GET listaarmazem ;
	DESCRIPTION "Consulta armazem" ;
	PATH "/listaarmazem" ;
	WSSYNTAX "/Glrest01/listaarmazem"	
    
  	WSMETHOD GET Produtos ;
	DESCRIPTION "Consulta de Produtos" ;
	PATH "/Produtos" ;
	WSSYNTAX "/Glrest01/produtos"

  	WSMETHOD POST Produtos ;
	DESCRIPTION "Consulta de Produtos" ;
	PATH "/Produtos" ;
	WSSYNTAX "/Glrest01/produtos"

  	WSMETHOD GET Bem ;
	DESCRIPTION "Consulta de Bem" ;
	PATH "/Bem" ;
	WSSYNTAX "/Glrest01/Bem"

  	WSMETHOD GET OrdemServico ;
	DESCRIPTION "Consulta de OrdemServico" ;
	PATH "/OrdemServico" ;
	WSSYNTAX "/Glrest01/OrdemServico"


	WSDATA limit as String Optional
	WSDATA offset as String Optional

	WSMETHOD GET Servico ;
	DESCRIPTION "Consulta de Servico" ;
	PATH "/Servico" ;
	WSSYNTAX "/Glrest01/Servico/{limit}{offset}"
	
END WSRESTFUL


/*###########################################################################
#############################################################################
## Programa  | POST |Autor| Adriano Reis	    		|Data|  30/06/2020 ##
##=========================================================================##
## Desc.     | Método POST para APP Incluir SA   						   ##
##=========================================================================##
## Uso       | GlobalErp Tecnologia	                                       ##
#############################################################################
###########################################################################*/


WSMETHOD POST incluisa WSSERVICE Glrest01

	Local oResponse		:= JsonObject():New()
	Local cBodyJson		:= ""
	Local oJson			:= NIL
	Local cCodEmp		:= "01"
	Local cCodFil		:= "01"
	Local lConnect		:= .F.
	Local nY     		:= 0
	Local cMsgErro      := ""
	Private lMsErroAuto := .F.

	Conout("++++++++++++ API INTEGRACAO Metodo Post++++++++++++++++")
	
	Self:SetContentType("application/json; charset=utf-8") 
	
	cBodyJson := AllTrim(Self:GetContent())
	
	RpcSetType(3)
	Reset Environment
	lConnect := RpcSetEnv(cCodEmp,cCodFil) 
	
	// se conseguiu logar na empresa
	if lConnect

	//	oJsontest := JsonObject():New()
	//	ret := oJsontest:FromJson(cBodyJson)  
		// converto a string JSON

		if FWJsonDeserialize(cBodyJson,@oJson)
			oJsontmp := (oJson)
			ctoken 	 := oJsontmp:token

			if ctoken == SuperGetMV("API_TOKEN",,"Elcop2024")
			
					aAuto   := {}
					aCab    := {}
					aLinha  := {}
					aRateio := {}
					
					nOpc            := oJsontmp:DATA:nOPCAO	  //3 - Incluir - 4 Alteracao - 5 - Exclusao		
					nOpcAuto 		:= nOpc		
					cCodFilial 		:= oJsontmp:DATA:FILIAL
					cIdWeb 			:= oJsontmp:DATA:IDWEB
					cIdProtheus 	:= oJsontmp:DATA:IDPROTHEUS					
					cCC				:= oJsontmp:DATA:CENTROCUSTO
					cPriori 		:= oJsontmp:DATA:PRIORIDADE
					cobs	  		:= oJsontmp:DATA:OBS
					ddataemis		:= oJsontmp:DATA:DTEMISSAO
					cSolicit        := oJsontmp:DATA:SOLICITANTE
					
					dData := dDataBase

					if nOpc = 3
						cCodigo := GetSxeNum("SCP","CP_NUM")
					Else
						cCodigo := cIdProtheus
					EndIf
					
					aCab:= {	{"CP_NUM"		,cCodigo		,NIL},;
								{"CP_SOLICIT"	,cSolicit		,NIL},;    
								{"CP_EMISSAO"	,dData      	,NIL}}		

					For nY := 1 To Len(oJsontmp:DATA:ITENS)	

						ItemItem     := oJsontmp:DATA:ITENS[NY]:ITEM
						ItemProd     := oJsontmp:DATA:ITENS[NY]:CODPRODUTO									
						ItemDtNec    := oJsontmp:DATA:ITENS[NY]:DTNECESSIDADE
						ItemQuant 	 := oJsontmp:DATA:ITENS[NY]:QUANTIDADE	 											
						ItemVlUnit   := oJsontmp:DATA:ITENS[NY]:VALORUNIT
						ItemObs  	 := oJsontmp:DATA:ITENS[NY]:ITEMOBS
						ItemLocal    := oJsontmp:DATA:ITENS[NY]:LOCAL			

						DbSelectArea("SB1")
						SB1->(DbSetOrder(1))
						If SB1->(DbSeek(xFilial("SB1")+PadR(ItemProd, tamsx3('CP_PRODUTO') [1])))

							aLinha := {}

							aadd(aLinha,{"CP_ITEM"		,'0'+cvaltochar(nY)	, Nil})
							aadd(aLinha,{"CP_PRODUTO"	, ItemProd			, Nil})
							aadd(aLinha,{"CP_UM"		, SB1->B1_UM		, Nil})
							aadd(aLinha,{"CP_QUANT"		, ItemQuant			, Nil})

							If !Empty(SB1->B1_SEGUM)
								aadd(aLinha,{"CP_SEGUM", SB1->B1_SEGUM, Nil})
								aadd(aLinha,{"CP_QTSEGUM", (ItemQuant*SB1->B1_CONV),Nil})
							EndIf

							aadd(aLinha,{"CP_DATPRF"	, stod(ItemDtNec) 		, Nil})
							aadd(aLinha,{"CP_CC"		, cCC					, Nil})
							aadd(aLinha,{"CP_LOCAL"		, SB1->B1_LOCPAD      	, Nil})
							aadd(aLinha,{"CP_OBS"		, ItemObs			    , Nil})

							aAdd(aAuto,aLinha)
						
						EndIf

					Next nY	

					MSExecAuto({|x,y,z,a| mata105(x,y,z,a)},aCab,aAuto,nOpcAuto) //aRateio //// 3 - Inclusao, 4 - Alteração, 5 - Exclusão

					cCodRet := '1'

					if lMsErroAuto
						cMsgErro += " " + MostraErro("\temp") + chr(13)+chr(10)
						Conout(cMsgErro)

						cMsgErro := "Erro Inclusao SA ! - "+cMsgErro
						lerro    := .F.
						nstatus  := 503

					Else

					if nOpcAuto = 3
						cMsgErro := "SA Cadastrada com Sucesso ! "
						cCodRet  := '3'
					Elseif nOpcAuto = 4
						cMsgErro := "SA Alterada com Sucesso ! "
						cCodRet  := '3'
					Elseif nOpcAuto = 5
						cMsgErro := "SA Excluida com Sucesso ! "
						cCodRet  := '3'
					Elseif nOpcAuto = 6
						cMsgErro := "SA Aprovada com Sucesso ! "
						cCodRet  := '3'
					Elseif nOpcAuto = 7
						cCodRet  := '4'
						cMsgErro := "SA Rejeitada com Sucesso ! "						
					EndIf
						
						lerro    := .T.
						nstatus  := 100
					
					EndIf

					oResponse["status"] 		:= nstatus
					oResponse["codigo"] 		:= cCodigo	
					oResponse["codret"] 		:= cCodRet
					oResponse["lstatus"]  		:= lerro		
					oResponse["msg"] 			:= cMsgErro
		
			Else
					Conout(">> token invalido!")
					oResponse["status"] := 500
					oResponse["msg"]    := "token invalido"		
			EndIf
			
		Else
		
			Conout(">> Json recebido invalido!")
			oResponse["status"] := 500
			oResponse["msg"] := "O Json recebido e invalido"	
				
		Endif
	Else
	
		Conout(">> Nao conectou na empresa e filial!")
		oResponse["status"] := 500
		oResponse["msg"] := "Nao conectou na empresa e filial"	
	
	Endif
	
	Self:SetResponse(FWJsonSerialize(oResponse, .F., .F., .T.))
	FreeObj(oResponse)
	RpcClearEnv()

Return(.T.)

/*###########################################################################
#############################################################################
## Programa  | POST |Autor| Adriano Reis	    		|Data|  30/06/2020 ##
##=========================================================================##
## Desc.     | Método POST para APP Incluir SA   						   ##
##=========================================================================##
## Uso       | GlobalErp Tecnologia	                                       ##
#############################################################################
###########################################################################*/

WSMETHOD POST aprovsa WSSERVICE Glrest01

	Local oResponse		:= JsonObject():New()
	Local cBodyJson		:= ""
	Local oJson			:= NIL
	Local cCodEmp		:= "01"
	Local cCodFil		:= "01"
	Local lConnect		:= .F.
	Local cMsgErro      := ""
	Private lMsErroAuto := .F.

	Conout("++++++++++++ API INTEGRACAO Metodo Post++++++++++++++++")
	
	Self:SetContentType("application/json; charset=utf-8") 
	
	cBodyJson := AllTrim(Self:GetContent())
	
	RpcSetType(3)
	Reset Environment
	lConnect := RpcSetEnv(cCodEmp,cCodFil) 
	
	// se conseguiu logar na empresa
	if lConnect

	//	oJsontest := JsonObject():New()
	//	ret := oJsontest:FromJson(cBodyJson)  
		// converto a string JSON

		if FWJsonDeserialize(cBodyJson,@oJson)
			oJsontmp := (oJson)
			ctoken 	 := oJsontmp:token

			if ctoken == SuperGetMV("API_TOKEN",,"Elcop2024")
			
					aAuto   := {}
					aCab    := {}
					aLinha  := {}
					aRateio := {}
					
					nOpc            := oJsontmp:DATA:nOPCAO	  //3 - Incluir - 4 Alteracao - 5 - Exclusao - 6 APROVACAO	- 7 REPROVA	
					nOpcAuto 		:= nOpc		
					cCodFilial 		:= oJsontmp:DATA:FILIAL
					cIdWeb 			:= oJsontmp:DATA:IDWEB
					cIdProtheus 	:= oJsontmp:DATA:IDPROTHEUS					
					cSolicit        := oJsontmp:DATA:NOMEAPROVADOR
					dData 			:= dDataBase
					cCodigo         := oJsontmp:DATA:IDPROTHEUS	

					DbSelectArea("SCP")
					SCP->(dBGoTop())
					SCP->( DbSetOrder(1) )
					if SCP->( DbSeek( xFilial("SCP") + cIdProtheus ) )
						while !SCP->( Eof() ) .and. xFilial("SCP") + cIdProtheus == xFilial("SCP") + SCP->CP_NUM                  

							IF nOpc = 6				
								RecLock("SCP",.F.)
									SCP->CP_STATSA := 'L'
								SCP->(MsUnlock())
							EndIf

							IF nOpc = 7	
								RecLock("SCP",.F.)
									SCP->CP_STATSA := 'B'
								SCP->(MsUnlock())
							EndIf				

						SCP->( DbSkip() )		
						Enddo
					EndIf

					cCodRet  := '1'
					cMsgErro := ''
					// status jander - 2 = em aprovação . 3  = em aberto - 4 - rejeitado - 5 - pre requisição gerada	
					if nOpcAuto = 3
						cMsgErro := "SA Cadastrada com Sucesso ! "
						cCodRet := '3'
					Elseif nOpcAuto = 4
						cMsgErro := "SA Alterada com Sucesso ! "
						cCodRet := '3'
					Elseif nOpcAuto = 5
						cMsgErro := "SA Excluida com Sucesso ! "
						cCodRet := '3'						
					Elseif nOpcAuto = 6
						cMsgErro := "SA Aprovada com Sucesso ! "
						cCodRet := '3'
					Elseif nOpcAuto = 7
						cCodRet := '4'
						cMsgErro := "SA Rejeitada com Sucesso ! "						
					EndIf
						
					lerro    := .T.
					nstatus  := 100

					oResponse["status"] 		:= nstatus
					oResponse["codigo"] 		:= cCodigo	
					oResponse["codret"] 		:= cCodRet				
					oResponse["lstatus"]  		:= lerro		
					oResponse["msg"] 			:= cMsgErro
		
			Else
					Conout(">> token invalido!")
					oResponse["status"] := 500
					oResponse["msg"]    := "token invalido"		
			EndIf
			
		Else
		
			Conout(">> Json recebido invalido!")
			oResponse["status"] := 500
			oResponse["msg"] := "O Json recebido e invalido"	
				
		Endif
	Else
	
		Conout(">> Nao conectou na empresa e filial!")
		oResponse["status"] := 500
		oResponse["msg"] := "Nao conectou na empresa e filial"	
	
	Endif
	
	Self:SetResponse(FWJsonSerialize(oResponse, .F., .F., .T.))
	FreeObj(oResponse)
	RpcClearEnv()

Return(.T.)

/*
#############################################################################
#############################################################################
## Programa  | GET |Autor|   					 		|Data|  12/06/2019 ##
##=========================================================================##
## Desc.     | Método GET para consulta de Armazem      				   ##
##=========================================================================##
## Uso       | Elcop	                                               	   ##
#############################################################################
#############################################################################
*/

WSMETHOD GET listaarmazem WSSERVICE Glrest01
	Local oResponse		:= JsonObject():New()
	Local cCodEmp		:= "01"
	Local cCodFil		:= "0101"
	Local lConnect		:= .F.
	Local cBodyJson		:= ""
	Local oJson			:= NIL

	Conout("++++++++++++ API DE CONSULTA DE ARMAZEM ++++++++++++++++") 
	
	Self:SetContentType("application/json; charset=utf-8") 
	
	cBodyJson := AllTrim(Self:GetContent())

	RpcSetType(3)
	Reset Environment
	lConnect := RpcSetEnv(cCodEmp,cCodFil) 
	
	// se conseguiu logar na empresa
	if lConnect	

	// converto a string JSON
		if FWJsonDeserialize(cBodyJson,@oJson)

			ctoken 		 := oJson:token			
			cdescri      := Alltrim(oJson:descricao)

			if ctoken == SuperGetMV("API_TOKEN",,"Elcop2024")
				conslocal(cdescri,@oResponse)
			Else
				Conout(">> token invalido!")
				oResponse["status"] := 500
				oResponse["msg"]    := "token invalido"		
			EndIf

		else
			Conout(">> Json recebido invalido!")
			oResponse["status"] := 500
			oResponse["msg"] := "O Json recebido e invalido"		
		endif

	Else	
		Conout(">> Nao conectou na empresa e filial!")
		oResponse["status"] := 500
		oResponse["msg"]    := "Nao conectou na empresa e filial"	
	endif
	
	Self:SetResponse(FWJsonSerialize(oResponse, .F., .F., .T.))
	FreeObj(oResponse)
	RpcClearEnv()

Return(.T.)

Static Function conslocal(cdescri,oResponse)

	Local aArea			:= GetArea()
	Local cPulaLinha	:= chr(13)+chr(10)
	Local cQry			:= ""
	Local oJson			:= NIL
		
	If Select("QRYTMP") > 0
		QRYTMP->(DbCloseArea())
	EndIf
	
	cQry := " SELECT NNR_CODIGO, NNR_DESCRI				 				 								" + cPulaLinha
	cQry += " FROM " + RetSqlName("NNR") + " 															" + cPulaLinha
	cQry += " WHERE D_E_L_E_T_ <> '*' 																	" + cPulaLinha

	if !Empty(AllTrim(cdescri))
		cQry += " AND NNR_DESCRI LIKE '%"+AllTrim(cdescri)+"%'											" + cPulaLinha
	endif
	
	TcQuery cQry New Alias "QRYTMP" // Cria uma nova area com o resultado do query   

	if QRYTMP->( !Eof() )
	
			oResponse["status"] 		:= 100
			oResponse["msg"]    		:= "OK"	
			oResponse["centrodecusto"] 	:= {}
	
		While QRYTMP->( !Eof() )

			oJson := JsonObject():New()

			// adiciono os dados a estrutura do produto
			oJson["codigo"]			:= Alltrim(QRYTMP->NNR_CODIGO)	   
			oJson["descricao"]		:= Alltrim(QRYTMP->NNR_DESCRI)	   
						
			// adiciono ao objeto de retorno a estrutura do produto
			aadd(oResponse["centrodecusto"] , oJson)
			FreeObj(oJson)
			
			QRYTMP->( DbSkip() )
		EndDo
		
	Else
		oResponse["status"] 		:= 501
		oResponse["msg"]    		:= "Local Nao Encontrado"	
	Endif

	If Select("QRYTMP") > 0
		QRYTMP->(DbCloseArea())
	EndIf
	
	RestArea(aArea)

Return()



/*###########################################################################
#############################################################################
## Programa  | GET |Autor| Adriano Reis         		|Data|  30/06/2019 ##
##=========================================================================##
## Desc.     | Método GET para consulta de produtos	JSON				   ##
##=========================================================================##
## Uso       | GlobalErp Tecnologia	                                       ##
#############################################################################
###########################################################################*/

WSMETHOD GET Produtos WSSERVICE Glrest01
	
	Local oResponse		:= JsonObject():New()
	Local cBodyJson		:= ""
	Local oJson			:= NIL
	Local cCodEmp		:= "01"
	Local cCodFil		:= "01"
	Local lConnect		:= .F.
	
	Conout("++++++++++++ API INTEGRACAO PRODUTOS  ++++++++++++++++")
	
	Self:SetContentType("application/json; charset=utf-8") 
	
	cBodyJson := AllTrim(Self:GetContent())
	
	RpcSetType(3)
	Reset Environment
	lConnect := RpcSetEnv(cCodEmp,cCodFil) 
	
	// se conseguiu logar na empresa
	if lConnect
	
		// converto a string JSON
		if FWJsonDeserialize(cBodyJson,@oJson)
			
			Conout("Json recebido: " + cBodyJson)

			ctoken := oJson:token			
			cNomeProd    := Alltrim(oJson:NomeProduto)
			cNcm         := Alltrim(oJson:ncm)
			cCodigo      := Alltrim(oJson:codigo)
			cGrupo       := Alltrim(oJson:codgrupo)
			cMostraSld   := Alltrim(oJson:mostrasaldo)
			climitreg    := oJson:limit
			coffset      := oJson:noffset  

			if ctoken == SuperGetMV("API_TOKEN",,"Elcop2024")
				// função que consulta os produtos e retorna a String Json
				ConsultaProd(cNomeProd,cncm,cCodigo,cgrupo,cMostraSld,climitreg,coffset,@oResponse)
			Else
				Conout(">> token invalido!")
				oResponse["status"] := 500
				oResponse["msg"]    := "token invalido"		
			EndIf

		else
			Conout(">> Json recebido invalido!")
			oResponse["status"] := 500
			oResponse["msg"] := "O Json recebido e invalido"		
		endif

	Else
		Conout(">> Nao conectou na empresa e filial!")
		oResponse["status"] := 500
		oResponse["msg"] := "Nao conectou na empresa e filial"	
	endif
	
	Self:SetResponse(FWJsonSerialize(oResponse, .F., .F., .T.))
	FreeObj(oResponse)
	RpcClearEnv()	

Return(.T.)


Static Function ConsultaProd(cNomeProd,cncm,cCodigo,cgrupo,cMostraSld,climitreg,coffset,oResponse)
	
	Local aArea			:= GetArea()
	Local cPulaLinha	:= chr(13)+chr(10)
	Local cQry			:= ""
	Local oJsonProd		:= NIL
	Local LRetProd		:= .F. 
	
	// verifico se nao existe este alias criado
	If Select("QRYSB1") > 0
		QRYSB1->(DbCloseArea())
	EndIf
	
	cQry := " 	SELECT "   + cPulaLinha
	cQry += " 	SB1.B1_COD 			AS CODIGO, "		+ cPulaLinha
	cQry += " 	SB1.B1_DESC 		AS DESCRICAO, "		+ cPulaLinha
	cQry += " 	SB1.B1_UM 			AS UM, "			+ cPulaLinha
	cQry += " 	SB1.B1_GRUPO 		AS B1_GRUPO, "		+ cPulaLinha
	cQry += " 	SB1.B1_POSIPI 		AS B1_POSIPI, "		+ cPulaLinha			
	cQry += " 	SB1.B1_TIPO 		AS B1_TIPO, "		+ cPulaLinha	
	cQry += " 	SB1.B1_CODBAR		AS CODBAR, "		+ cPulaLinha	
	cQry += " 	SB1.B1_MSBLQL     	AS B1_MSBLQL, "		+ cPulaLinha
	cQry += " 	SB1.B1_LOCPAD       AS B1_LOCPAD "		+ cPulaLinha
	cQry += " 	FROM " + RetSqlName("SB1") + " SB1 " 	+ cPulaLinha
	cQry += " 	WHERE SB1.D_E_L_E_T_ = '' AND SB1.B1_TIPO ='SV' OR SB1.B1_TIPO ='PV' " + cPulaLinha//AND SB1.B1_TIPO LIKE ('SV,PV') " + cPulaLinha
	cQry += " 	AND B1_MSBLQL = '2' " 				    + cPulaLinha
		
	if !Empty(cNomeProd)
		cQry += " AND SB1.B1_DESC   Like '%" + UPPER(cNomeProd) + "%' "	+ cPulaLinha
	EndIf
	if !Empty(cncm)
		cQry += " AND SB1.B1_POSIPI   = '" + cncm + "' "	+ cPulaLinha
	EndIf
	if !Empty(cCodigo)
		cQry += " AND SB1.B1_COD      = '" + cCodigo + "' "	+ cPulaLinha
	EndIf
	if !Empty(cgrupo)
		cQry += " AND SB1.B1_GRUPO    = '" + cgrupo + "' "	+ cPulaLinha
	EndIf	

	cQry += " ORDER BY SB1.B1_COD "					+ cPulaLinha

	if climitreg > 0 
		cQry += " OFFSET "+cvaltochar(coffset)+" ROWS "
		cQry += " FETCH NEXT "+cvaltochar(climitreg)+" ROWS ONLY "		
	EndIf

 
	TcQuery cQry New Alias "QRYSB1" 
		
	if QRYSB1->(!Eof()) 
	
		oResponse["status"] 	:= 100
		oResponse["produtos"] 	:= {}
	
		While QRYSB1->(!Eof()) 
			
				cDescProd   := AllTrim(QRYSB1->DESCRICAO)
				//cDescProd   := strtran(cDescProd,"/","")
				//cDescProd   := strtran(cDescProd,"\","")
				xCodAtu 	:= AllTrim(QRYSB1->CODIGO)
		
 
					oJsonProd := JsonObject():New()										
					oJsonProd["codproduto"]	    := AllTrim(QRYSB1->CODIGO)
					oJsonProd["descricao"]		:= EncodeUTF8(cValToChar(AllTrim(cDescProd)))
					oJsonProd["unidade"]		:= AllTrim(QRYSB1->UM)
					oJsonProd["codbar"]			:= AllTrim(QRYSB1->CODBAR)
					oJsonProd["grupo"]			:= AllTrim(QRYSB1->B1_GRUPO)	
					oJsonProd["descgrupo"]		:= AllTrim(Posicione("SBM",1,xFilial("SBM")+AllTrim(QRYSB1->CODIGO), "BM_DESC"))									
					oJsonProd["status"]			:= IIF(QRYSB1->B1_MSBLQL = '2','Ativo','Bloqueado')					
					oJsonProd["ncm"]			:= AllTrim(QRYSB1->B1_POSIPI)	
					oJsonProd["tipo"]			:= AllTrim(QRYSB1->B1_TIPO)	
					oJsonProd["LocalPadrao"]	:= AllTrim(QRYSB1->B1_LOCPAD)	
					oJsonProd["saldos"] 		:= {}								

					 
					aadd(oResponse["produtos"] , oJsonProd)			
					FreeObj(oJsonProd)
					
				//EndIf */
			
			QRYSB1->(DbSkip())
		EndDo
		
		if !LRetProd
		//	oResponse["status"] := 500
		//	oResponse["msg"] 	:= "Todos Produtos Sem Saldo"	
		EndIf
		
	Else
		oResponse["status"] := 500
		oResponse["msg"] 	:= "Produto Nao Encontrado"	
	Endif
 
	If Select("QRYSB1") > 0
		QRYSB1->(DbCloseArea())
	EndIf
	
	RestArea(aArea)

Return()
 
/*
#############################################################################
#############################################################################
## Programa  | GET |Autor|   					 		|Data|  12/06/2019 ##
##=========================================================================##
## Desc.     | Método GET para consulta de Bem		      				   ##
##=========================================================================##
## Uso       | Elcop	                                               	   ##
#############################################################################
#############################################################################
*/

WSMETHOD GET Bem WSSERVICE Glrest01
	Local oResponse		:= JsonObject():New()
	Local cCodEmp		:= "01"
	Local cCodFil		:= "0101"
	Local lConnect		:= .F.
	Local cBodyJson		:= ""
	Local oJson			:= NIL

	Conout("++++++++++++ API DE CONSULTA DE BEM ++++++++++++++++") 
	
	Self:SetContentType("application/json; charset=utf-8") 
	cBodyJson := AllTrim(Self:GetContent())

	RpcSetType(3)
	Reset Environment
	lConnect := RpcSetEnv(cCodEmp,cCodFil) 
	
	// se conseguiu logar na empresa
	if lConnect	

	// converto a string JSON
		if FWJsonDeserialize(cBodyJson,@oJson)

			ctoken 		 := oJson:token			
			cdescri      := Alltrim(oJson:descricao)
			cplaca       := Alltrim(oJson:placa)
			ccusto       := Alltrim(oJson:centcusto)

			if ctoken == SuperGetMV("API_TOKEN",,"Elcop2024")
				consbem(cdescri,cplaca,ccusto,@oResponse)
			Else
				Conout(">> token invalido!")
				oResponse["status"] := 500
				oResponse["msg"]    := "token invalido"		
			EndIf

		else
			Conout(">> Json recebido invalido!")
			oResponse["status"] := 500
			oResponse["msg"] := "O Json recebido e invalido"		
		endif

	Else	
		Conout(">> Nao conectou na empresa e filial!")
		oResponse["status"] := 500
		oResponse["msg"]    := "Nao conectou na empresa e filial"	
	endif
	
	Self:SetResponse(FWJsonSerialize(oResponse, .F., .F., .T.))
	FreeObj(oResponse)
	RpcClearEnv()

Return(.T.)

Static Function consbem(cdescri,cplaca,ccusto,oResponse)

	Local cPulaLinha	:= chr(13)+chr(10)
	Local cQry			:= ""
	Local oJson			:= NIL
		
	If Select("QRYTMP") > 0;QRYTMP->(DbCloseArea());EndIf
	
	cQry := " SELECT T9_CODBEM, T9_NOME , T9_PLACA, T9_CCUSTO, CTT.CTT_DESC01		 " + cPulaLinha
	cQry += " FROM " +RetSqlName("ST9")+" "+"AS ST9									  "+ cPulaLinha
	cQry += " INNER JOIN "+RetSqlName("CTT")+" "+"AS CTT ON CTT.CTT_CUSTO = ST9.T9_CCUSTO	" + cPulaLinha
	cQry += " WHERE ST9.D_E_L_E_T_ <> '*' AND  CTT.D_E_L_E_T_ <> '*'				 " + cPulaLinha



	/*cQuery += " FROM " + RetSqlName('SD2') + " SD2"
	cQuery += " INNER JOIN " +RetSqlName('SF2') + " SF2 ON SD2.D2_FILIAL = SF2.F2_FILIAL AND SD2.D2_DOC = SF2.F2_DOC AND SD2.D2_SERIE = SF2.F2_SERIE AND SD2.D2_CLIENTE = SF2.F2_CLIENTE AND SD2.D2_LOJA = SF2.F2_LOJA"*/

	if !Empty(AllTrim(cdescri))
		cQry += " AND T9_NOME  LIKE '%"+AllTrim(cdescri)+"%'										" + cPulaLinha
	endif

	if !Empty(AllTrim(cplaca))
		cQry += " AND T9_PLACA LIKE '%"+AllTrim(cplaca)+"%'											" + cPulaLinha
	endif

	TcQuery cQry New Alias "QRYTMP" // Cria uma nova area com o resultado do query   

	if QRYTMP->( !Eof() )
	
			oResponse["status"] 		:= GetDToVal("100")
			oResponse["msg"]    		:= "OK"
			oResponse["bem"] 			:= {}
	
		While QRYTMP->( !Eof() )

			oJson := JsonObject():New()

			// adiciono os dados a estrutura do produto
			oJson["T9_CODBEM"]		:= Alltrim(QRYTMP->T9_CODBEM)	   
			oJson["T9_NOME"]   		:= Alltrim(QRYTMP->T9_NOME)	   
			oJson["T9_PLACA"]   	:= Alltrim(QRYTMP->T9_PLACA)	
			oJson["T9_CCUSTO"]   	:= Alltrim(QRYTMP->T9_CCUSTO)   			
						
			// adiciono ao objeto de retorno a estrutura do produto
			aadd(oResponse["bem"] , oJson)
			FreeObj(oJson)
			
			QRYTMP->( DbSkip() )
		EndDo
		
	Else
		oResponse["status"] 		:= 501
		oResponse["msg"]    		:= "Bem Nao Encontrado"	
	Endif

	If Select("QRYTMP") > 0;QRYTMP->(DbCloseArea());EndIf
	
Return()


/*
#############################################################################
#############################################################################
## Programa  | GET |Autor|   					 		|Data|  12/06/2019 ##
##=========================================================================##
## Desc.     | Método GET para consulta de STJ		      				   ##
##=========================================================================##
## Uso       | Elcop	                                               	   ##
#############################################################################
#############################################################################
*/

WSMETHOD GET OrdemServico WSSERVICE Glrest01
	Local oResponse		:= JsonObject():New()
	Local cCodEmp		:= "01"
	Local cCodFil		:= "0101"
	Local lConnect		:= .F.
	Local cBodyJson		:= ""
	Local oJson			:= NIL

	Conout("++++++++++++ API DE CONSULTA DE ORDEM DE SERVICO ++++++++++++++++") 
	
	Self:SetContentType("application/json; charset=utf-8") 
	cBodyJson := AllTrim(Self:GetContent())

	RpcSetType(3)
	Reset Environment
	lConnect := RpcSetEnv(cCodEmp,cCodFil) 
	
	// se conseguiu logar na empresa
	if lConnect	

	// converto a string JSON
		if FWJsonDeserialize(cBodyJson,@oJson)

			ctoken 		 := oJson:token			
			ccodbem      := Alltrim(oJson:codbem)
			cplaca		 := Alltrim(oJson:placa)
			climitreg    := oJson:limit
			coffset      := oJson:noffset  


			if ctoken == SuperGetMV("API_TOKEN",,"Elcop2024")
				consordem(ccodbem,cplaca,climitreg,coffset,@oResponse)
			Else
				Conout(">> token invalido!")
				oResponse["status"] := 500
				oResponse["msg"]    := "token invalido"		
			EndIf

		else
			Conout(">> Json recebido invalido!")
			oResponse["status"] := 500
			oResponse["msg"] := "O Json recebido e invalido"		
		endif

	Else	
		Conout(">> Nao conectou na empresa e filial!")
		oResponse["status"] := 500
		oResponse["msg"]    := "Nao conectou na empresa e filial"	
	endif
	
	Self:SetResponse(FWJsonSerialize(oResponse, .F., .F., .T.))
	FreeObj(oResponse)
	RpcClearEnv()

Return(.T.)

Static Function consordem(ccodbem,cplaca,climitreg,coffset,oResponse)

	Local cPulaLinha	:= chr(13)+chr(10)
	Local cQry			:= ""
	Local oJson			:= NIL
		
	If Select("QRYTMP") > 0;QRYTMP->(DbCloseArea());EndIf
	
	cQry := " SELECT TJ_FILIAL, TJ_ORDEM , TJ_CODBEM,TJ_XPLACA , TJ_CCUSTO ,TJ_SERVICO				" + cPulaLinha
	cQry += " FROM " + RetSqlName("STJ") + " 														" + cPulaLinha
	cQry += " WHERE D_E_L_E_T_ <> '*' 																" + cPulaLinha

	if !Empty(AllTrim(ccodbem))
		cQry += " AND TJ_CODBEM  LIKE '%"+AllTrim(ccodbem)+"%'										" + cPulaLinha
	endif

	if !Empty(AllTrim(cplaca))
		cQry += " AND TJ_XPLACA LIKE '%"+AllTrim(cplaca)+"%'											" + cPulaLinha
	endif

	cQry += " ORDER BY TJ_ORDEM "					+ cPulaLinha

	if climitreg > 0 
		cQry += " OFFSET "+cvaltochar(coffset)+" ROWS "
		cQry += " FETCH NEXT "+cvaltochar(climitreg)+" ROWS ONLY "		
	EndIf

	TcQuery cQry New Alias "QRYTMP" // Cria uma nova area com o resultado do query   

	if QRYTMP->( !Eof() )
	
			oResponse["status"] 		:= 100
			oResponse["msg"]    		:= "OK"	
			oResponse["ordemservico"]   := {}
	
		While QRYTMP->( !Eof() )

			oJson := JsonObject():New()

			// adiciono os dados a estrutura do produto
			oJson["TJ_FILIAL"]		:= Alltrim(QRYTMP->TJ_FILIAL)	   
			oJson["TJ_ORDEM"]   	:= Alltrim(QRYTMP->TJ_ORDEM)	   
			oJson["TJ_CODBEM"]   	:= Alltrim(QRYTMP->TJ_CODBEM)	   			
			oJson["TJ_CCUSTO"]   	:= Alltrim(QRYTMP->TJ_CCUSTO)	   			
			oJson["TJ_SERVICO"]   	:= Alltrim(QRYTMP->TJ_SERVICO)	  
			oJson["TJ_XPLACA"]   	:= Alltrim(QRYTMP->TJ_XPLACA)	 			

			// adiciono ao objeto de retorno a estrutura do produto
			aadd(oResponse["ordemservico"] , oJson)
			FreeObj(oJson)
			
			QRYTMP->( DbSkip() )
		EndDo
		
	Else
		oResponse["status"] 		:= 501
		oResponse["msg"]    		:= "Ordem De Servico Nao Encontrada"	
	Endif

	If Select("QRYTMP") > 0;QRYTMP->(DbCloseArea());EndIf
	
Return()


/*
#############################################################################
#############################################################################
## Programa  | GET |Autor|   					 		|Data|  12/06/2019 ##
##=========================================================================##
## Desc.     | Método GET para consulta de ST4		      				   ##
##=========================================================================##
## Uso       | Elcop	                                               	   ##
#############################################################################
#############################################################################
*/

// https://centraldeatendimento.totvs.com/hc/pt-br/articles/360020555111-Cross-Segmento-TOTVS-Backoffice-Linha-Protheus-ADVPL-Em-um-WS-REST-definir-a-quantidade-de-informa%C3%A7%C3%A3o-retornada-em-um-m%C3%A9todo-GET

WSMETHOD GET Servico WSRECEIVE limit, offset WSSERVICE Glrest01
	Local oResponse		:= JsonObject():New()
	Local cCodEmp		:= "01"
	Local cCodFil		:= "0101"
	Local lConnect		:= .F.
	Local cBodyJson		:= ""
	Local oJson			:= NIL
	Local ctoken := Self:GetHeader('X-Token')
	Local cLimit := "100"
	Local cOffset := "0"
	
// https://devforum.totvs.com.br/1023-wsrestful--headers-que-contem-hifen-advpl

	Conout("++++++++++++ API DE CONSULTA DE SERVICO ++++++++++++++++") 
	
	Self:SetContentType("application/json; charset=utf-8") 
	cBodyJson := AllTrim(Self:GetContent())

	RpcSetType(3)
	Reset Environment
	lConnect := RpcSetEnv(cCodEmp,cCodFil) 
	
	// se conseguiu logar na empresa
	if lConnect	

		IF !Empty(Self:limit)
			cLimit := Self:limit
		EndIF

		IF !Empty(Self:offset)
			cOffset := Self:offset
		EndIF


		if ctoken == SuperGetMV("API_TOKEN",,"Elcop2024")
			conservico(cLimit,cOffset,@oResponse)
		Else
			Conout(">> token invalido!")
			oResponse["status"] := 500
			oResponse["msg"]    := "token invalido"	
		EndIf

	Else	
		Conout(">> Nao conectou na empresa e filial!")
		oResponse["status"] := 500
		oResponse["msg"]    := "Nao conectou na empresa e filial"	
	endif
	
	Self:SetResponse(FWJsonSerialize(oResponse, .F., .F., .T.))
	FreeObj(oResponse)
	RpcClearEnv()

Return(.T.)

// CP1252

Static Function conservico(cLimit,cOffset,oResponse)

	Local cPulaLinha	:= chr(13)+chr(10)
	Local cQry			:= ""
	Local oJson			:= NIL
		
	If Select("QRYTMP") > 0
	QRYTMP->(DbCloseArea())
	EndIf
	
	cQry := " SELECT T4_FILIAL, T4_SERVICO , T4_NOME			   " + cPulaLinha
	cQry += " FROM " + RetSqlName("ST4") + " 					   " + cPulaLinha
	cQry += " WHERE D_E_L_E_T_ <> '*' 							   " + cPulaLinha

	cQry += " ORDER BY T4_SERVICO "			                		+ cPulaLinha

	cQry += " OFFSET "+cvaltochar(cOffset)+" ROWS "
	cQry += " FETCH NEXT "+cvaltochar(cLimit)+" ROWS ONLY "		
	

	TcQuery cQry New Alias "QRYTMP" // Cria uma nova area com o resultado do query   

	if QRYTMP->( !Eof() )
	
			oResponse["status"] 		:= 100
			oResponse["msg"]    		:= "OK"	
			oResponse["Servico"]  		:= {}
	
		While QRYTMP->( !Eof() )

			oJson := JsonObject():New()

			// adiciono os dados a estrutura do produto
			oJson["T4_FILIAL"]		:= Alltrim(QRYTMP->T4_FILIAL)	   
			oJson["T4_SERVICO"]   	:= Alltrim(QRYTMP->T4_SERVICO)	   
			oJson["T4_NOME"]   	    := Alltrim(QRYTMP->T4_NOME)	   			
				 			

			// adiciono ao objeto de retorno a estrutura do produto
			aadd(oResponse["Servico"] , oJson)
			FreeObj(oJson)
			
			QRYTMP->( DbSkip() )
		EndDo
		
	Else
		oResponse["status"] 		:= 501
		oResponse["msg"]    		:= "Consulta De Servico Nao Encontrada"	
	Endif

	//If Select("QRYTMP") > 0;QRYTMP->(DbCloseArea());EndIf
	
Return()
