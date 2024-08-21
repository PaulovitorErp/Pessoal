#INCLUDE "PROTHEUS.CH"
#INCLUDE "FWBROWSE.CH"
#INCLUDE "FWMVCDEF.CH"
#INCLUDE 'TOPCONN.CH'

Static cPulaLinha	:= Chr(13) + Chr(10)

/*
=====================================================================================
Programa.:              MGIMP007
Autor....:         		Danilo Teles     
Data.....:              12/02/2024
Descricao / Objetivo:   Importa contratos
Uso......:               
Obs......:              
=====================================================================================
*/ 

User Function MGIMP007(oSay,cArquivo,nHdlLog,nObjProc,nSucesso)
	Local aLog       := {}
	Local cLogWrite  := ""
	Local cFiltroSX3 := ""
	Local cLinha     := ''
	Local lPrim      := .T.
	Local aCampos    := {}
	Local aDados     := {}
//Local cBKFilial  := cFilAnt
	Local nCampos    := 0
	Local aExecAuto  := {}
	Local aCamposSX3 := {}
	Local aTipoImp   := {}
	Local cTipo      := ''
	Local nI
	Local nX
	Local ncA := 1
	Local ncB := 1
	LOcal nCC := 1
	Local cClient := ""
	Local cCNANUM := ""
	Local cContra := ""
	Local cCNBProd := ""
	Local nICNA   := 1
	Local nICNB   := "001"
	Local lMudou  := .F.
	Local lMdCNA  := .F.
	Local lMdCNB  := .F.
	Local oModel 	:= FWLoadModel("CNTA301")
	Local oModelCN9 := Nil, oModelCNA := Nil, oModelCNB := Nil
	Local nReg      := 1
	Local aClient	:= {}
	Local dDtVencto := cTod("")
	Private lMsErroAuto    := .F.
	Private lMsHelpAuto	   := .F.
	Private lAutoErrNoFile := .T.

	Default oSay 		:= Nil
	Default cArquivo 	:= ""
	Default nHdlLog 	:= 0
	Default nObjProc 	:= 0
	Default nSucesso 	:= 0

	FT_FUSE(cArquivo)
	FT_FGOTOP()
	cLinha    := FT_FREADLN()
	aTipoImp  := Separa(cLinha,";",.T.)
	cTipo     := SUBSTR(aTipoImp[1],1,3)

	IF !(cTIPO $('CN9'))
		MsgAlert('Não é possivel importar a tabela: '+cTipo+ '  !!')
		Return
	ENDIF

	// monta filtro para consulta SX3
	cFiltroSX3 := " SX3.X3_ARQUIVO IN ('CN9','CNA','CNB','CNC','CNF') "

	// função que consulta tabela SX3
	aCamposSX3 := U_MEGAAUX2(cFiltroSX3)

	/*If !U_MEGAAUX1(aTipoImp, aCamposSX3, cTipo)
		Return
	Endif*/

	ProcRegua(FT_FLASTREC())
	FT_FGOTOP()
	While !FT_FEOF()
		IncProc("Lendo arquivo texto...")
		cLinha := FT_FREADLN()
		If lPrim
			aCampos := Separa(cLinha,";",.T.)
			lPrim := .F.
		Else
			AADD(aDados,Separa(cLinha,";",.T.))
		EndIf
		FT_FSKIP()
	EndDo

	ProcRegua(Len(aDados))
	CNTSetFun("CNTA301")
	ClrVCpoUsr()
	For nI:=1 to  Len(aDados)	

		IncProc("Importando arquivo...")

		if !CN9->(DbSetOrder(1),Dbseek( FWxFilial("CN9") + PadL(AllTrim(aDados[nI][aScan(aCampos,"CN9_NUMERO")]),TamSx3("CN9_NUMERO")[1] ,"0") ))

			aExecAuto := {}
			IF cClient == ""
				cClient	:= AllTrim(aDados[nI][aScan(aCampos,"CN9_CLIENT")])
				aClient	:= fGetCli(cClient) //AllTrim(aDados[nI][aScan(aCampos,"CN9_CLIENT")])
			ELSEIF cClient != AllTrim(aDados[nI][aScan(aCampos,"CN9_CLIENT")])
				cClient	:= AllTrim(aDados[nI][aScan(aCampos,"CN9_CLIENT")])
				aClient	:= fGetCli(cClient) //AllTrim(aDados[nI][aScan(aCampos,"CN9_CLIENT")])
			ENDIF
			
			IF LEN(aClient) > 0
				IF cContra   == ""
					nCC 	:= 1
					cCNANUM     := AllTrim(aDados[nI][aScan(aCampos,"CNA_NUMERO")])
					dDtVencto   := cTod(aDados[nI][aScan(aCampos,"CNF_DTVENC")])
					cContra		:= PadL(AllTrim(aDados[nI][aScan(aCampos,"CN9_NUMERO")]),TamSx3("CN9_NUMERO")[1] ,"0")
					//cCNBProd  	:= AllTrim(aDados[nI][aScan(aCampos,"CNB_PRODUT")])
					nICNA   := 1
					nObjProc ++
					oModel:SetOperation(MODEL_OPERATION_INSERT)
					if oModel:Activate()
						oModelCN9 := oModel:GetModel('CN9MASTER')
						oModelCNA := oModel:GetModel("CNADETAIL")
						oModelCNB := oModel:GetModel('CNBDETAIL')
						oModelCNC := oModel:GetModel('CNCDETAIL')

						CNTA300BlMd(oModelCNB, .F.)

						lMudou := .T.
						lMdCNA := .T.
						lMdCNB  := .T.	
					EndIF
				ELSE
					IF cContra     != PadL(AllTrim(aDados[nI][aScan(aCampos,"CN9_NUMERO")]),TamSx3("CN9_NUMERO")[1] ,"0")
		
						cCNANUM    := AllTrim(aDados[nI][aScan(aCampos,"CNA_NUMERO")])
						dDtVencto   := cTod(aDados[nI][aScan(aCampos,"CNF_DTVENC")])
						cContra	   := PadL(AllTrim(aDados[nI][aScan(aCampos,"CN9_NUMERO")]),TamSx3("CN9_NUMERO")[1] ,"0")
						nICNA      := 1
						nICNB      := "001"
						nCC 	   := 1
						nReg++

						//Cronograma Financeiro
						SetMVValue("CN300CRG","MV_PAR01",1	) //Mensal == 1
						SetMVValue("CN300CRG","MV_PAR02",30	) //dias
						SetMVValue("CN300CRG","MV_PAR03",1	) //Dt não existir == 1
						SetMVValue("CN300CRG","MV_PAR04","082024") //SubStr(dTos(cTod(AllTrim(aDados[nI][aScan(aCampos,"CN9_DTINIC")]))),5,2)//20491231
						SetMVValue("CN300CRG","MV_PAR05", dDtVencto ) //Colocar ultima data do mÊs.
						SetMVValue("CN300CRG","MV_PAR06", 303) // Qtd, puxar da cnb.
						SetMVValue("CN300CRG","MV_PAR07", "   ") //condição de apgto vazia.
						SetMVValue("CN300CRG","MV_PAR08", 0) //Tx de jutos.
						
						Pergunte("CN300CRG",.F.)
						CN300PrCF(.T.) 

						//Validação e Gravação do Modelo
						If oModel:VldData()
							oModel:CommitData()
							nSucesso ++
						else
							aLog := {}
							aLog := oModel:GetErrorMessage()
							//TmsMsgErr(aErro)	
							cLogWrite := ""
							For nX :=1 to Len(aLog)
								IF aLog[nX] != Nil
									cLogWrite += cValToChar(aLog[nX])+CRLF
								ENDIF
							next nX
							
							fWrite(nHdlLog,"Registro: " + cContra)
							fWrite(nHdlLog,cPulaLinha)
							fWrite(nHdlLog,"Erro: ExecAuto.")
							fWrite(nHdlLog,cPulaLinha)
							fWrite(nHdlLog, cLogWrite)
							fWrite(nHdlLog,cPulaLinha)	
						EndIf

						If(ValType(oModel)=='O')
							oModel:DeActivate()
						EndIf

						nObjProc ++
						oModel:SetOperation(MODEL_OPERATION_INSERT)
						if oModel:Activate()
							oModelCN9 := oModel:GetModel('CN9MASTER')
							oModelCNA := oModel:GetModel("CNADETAIL")
							oModelCNB := oModel:GetModel('CNBDETAIL')
							oModelCNC := oModel:GetModel('CNCDETAIL')
							CNTA300BlMd(oModelCNB, .F.)
							lMudou := .T.
							lMdCNA := .T.
							lMdCNB  := .T.
						ENDIF
					else
						lMudou := .F.
						IF cCNANUM  != AllTrim(aDados[nI][aScan(aCampos,"CNA_NUMERO")])
						dDtVencto   := cTod(aDados[nI][aScan(aCampos,"CNF_DTVENC")])
							cCNANUM     := AllTrim(aDados[nI][aScan(aCampos,"CNA_NUMERO")])
							//cCNBProd   := AllTrim(aDados[nI][aScan(aCampos,"CNB_PRODUT")])
							nICNB := "001"
							nICNA  += 1
							lMdCNA := .T.
							lMdCNB := .T.
							oModelCNA:AddLine()
							
						ELSE
							lMdCNA := .F.
							lMdCNB := .T.
							nICNB := Soma1(nICNB)
							oModelCNB:AddLine()
							
						ENDIF
					ENDIF

				ENDIF

				ncA := 1
				ncB := 1
				nCC := 1
				For nCampos := 1 To Len(aCampos)
					IF lMudou .AND. SUBSTR(Upper(aCampos[nCampos]),1,3)=='CN9'
						IF Upper(aCampos[nCampos]) == "CN9_CLIENT"
							oModelCN9:SetValue("CN9_CLIENT", aClient[1])
						//ELSEIF Upper(aCampos[nCampos]) == "CN9_LOJACL"
							oModelCN9:SetValue("CN9_LOJACL", aClient[2])
						ELSEIF Upper(aCampos[nCampos]) != "CN9_NUMERO"
				
							IF TamSx3(Upper(aCampos[nCampos]))[3] =='N'
								oModelCN9:SetValue(Upper(aCampos[nCampos]),VAL(strtran(strtran(aDados[nI,nCampos],".",""),",",".")))
							ELSEIF TamSx3(Upper(aCampos[nCampos]))[3] =='D'
								oModelCN9:SetValue(Upper(aCampos[nCampos]), CTOD(aDados[nI,nCampos] ))
							ELSE
								oModelCN9:SetValue(Upper(aCampos[nCampos]),FWNoAccent(PadR(SUBSTR(ALLTRIM(aDados[nI,nCampos]),1,TamSx3(aCampos[nCampos])[1]),TamSx3(aCampos[nCampos])[1])))
							ENDIF
						else
							oModelCN9:SetValue(Upper(aCampos[nCampos]), PadL(AllTrim(aDados[nI,nCampos]),TamSx3("CN9_NUMERO")[1] ,"0")) //PadR(AllTrim(aDados[nI][aScan(aCampos,"CN9_NUMERO")]),TamSx3("CN9_NUMERO")[1] ,"0")
						ENDIF
					ELSEIF lMudou .AND. SUBSTR(Upper(aCampos[nCampos]),1,3)=='CNC'
						IF nCC == 1 //Upper(aCampos[nCampos]) == "CNC_CLIENT"
							oModelCNC:SetValue("CNC_CLIENT", aClient[1])
						//ELSEIF Upper(aCampos[nCampos]) == "CNC_LOJACL"
							oModelCNC:SetValue("CNC_LOJACL", aClient[2])
						ELSE
							IF  TamSx3(Upper(aCampos[nCampos]))[3] =='N'
								oModelCNC:SetValue(Upper(aCampos[nCampos]),VAL(strtran(strtran(aDados[nI,nCampos],".",""),",",".")))
							ELSEIF TamSx3(Upper(aCampos[nCampos]))[3] =='D'
								oModelCNC:SetValue(Upper(aCampos[nCampos]), CTOD(aDados[nI,nCampos] ))
							ELSE
								oModelCNC:SetValue(Upper(aCampos[nCampos]),FWNoAccent(PadR(SUBSTR(ALLTRIM(aDados[nI,nCampos]),1,TamSx3(aCampos[nCampos])[1]),TamSx3(aCampos[nCampos])[1])))
							ENDIF
						ENDIF
					
					ELSEIF lMdCNA .AND. SUBSTR(Upper(aCampos[nCampos]),1,3)=='CNA'
						IF lMudou .AND. ncA == 1
							oModelCNC:SetValue("CNC_CLIENT", aClient[1])
						//ELSEIF Upper(aCampos[nCampos]) == "CNC_LOJACL"
							oModelCNC:SetValue("CNC_LOJACL", aClient[2])
						ENDIF
						//IF Upper(aCampos[nCampos]) == "CNA_CLIENT"
							//oModelCNA:SetValue(Upper(aCampos[nCampos]), aClient[1])				
						//ELSE
							IF	TamSx3(Upper(aCampos[nCampos]))[3] =='N'
								oModelCNA:SetValue(Upper(aCampos[nCampos]),VAL(strtran(strtran(aDados[nI,nCampos],".",""),",",".")))
							ELSEIF TamSx3(Upper(aCampos[nCampos]))[3] =='D'
								oModelCNA:SetValue(Upper(aCampos[nCampos]), CTOD(aDados[nI,nCampos] ))
							ELSE
								oModelCNA:SetValue(Upper(aCampos[nCampos]),FWNoAccent(PadR(SUBSTR(ALLTRIM(aDados[nI,nCampos]),1,TamSx3(aCampos[nCampos])[1]),TamSx3(aCampos[nCampos])[1])))
							ENDIF
						IF ncA== 1 //Upper(aCampos[nCampos]) == "CNA_CLIENT"
							oModelCNA:SetValue("CNA_CLIENT", aClient[1])				
						
						ENDIF
						ncA := 2
					ELSEIF lMdCNB .AND. SUBSTR(Upper(aCampos[nCampos]),1,3)=='CNB'
						IF ncB == 1
							oModelCNB:SetValue("CNB_ITEM", nICNB)
							oModelCNB:SetValue("CNB_NUMERO", cCNANUM)                 
						ENDIF

						IF Upper(aCampos[nCampos]) == "CNB_PRODUT"
							cCNBProd   := fGetPrd(AllTrim(aDados[nI][aScan(aCampos,"CNB_PRODUT")]))
							oModelCNB:SetValue(Upper(aCampos[nCampos]), cCNBProd)
						ELSE
							IF  TamSx3(Upper(aCampos[nCampos]))[3] =='N'
								oModelCNB:SetValue(Upper(aCampos[nCampos]),VAL(strtran(strtran(aDados[nI,nCampos],".","") ,",",".")))
							ELSEIF TamSx3(Upper(aCampos[nCampos]))[3] =='D'
								oModelCNB:SetValue(Upper(aCampos[nCampos]), CTOD(aDados[nI,nCampos] ))
							ELSE
								oModelCNB:SetValue(Upper(aCampos[nCampos]),FWNoAccent(PadR(SUBSTR(ALLTRIM(aDados[nI,nCampos]),1,TamSx3(aCampos[nCampos])[1]),TamSx3(aCampos[nCampos])[1])))
							ENDIF
						ENDIF
						ncB := 2
					ENDIF

				Next nCampos
			ELSE
				fWrite(nHdlLog,"Registro: " + cValToChar(nI))
				fWrite(nHdlLog,cPulaLinha)
				fWrite(nHdlLog,"CNPJ: " + cClient + " nao cadastrado na base!")
				fWrite(nHdlLog,cPulaLinha)
			ENDIF
		ELSE
			//fWrite(nHdlLog,"Registro: " + cValToChar(nI))
			//fWrite(nHdlLog,cPulaLinha)
			//fWrite(nHdlLog,"CNPJ: " + PadL(AllTrim(aDados[nI][aScan(aCampos,"CN9_NUMERO")]),TamSx3("CN9_NUMERO")[1] ,"0") + " contrato ja existe!")
			//fWrite(nHdlLog,cPulaLinha)
		ENDIF
		
	Next nI
	
	//Cronograma Financeiro
		SetMVValue("CN300CRG","MV_PAR01",1	) //Mensal == 1
		SetMVValue("CN300CRG","MV_PAR02",30	) //dias
		SetMVValue("CN300CRG","MV_PAR03",1	) //Dt não existir == 1
		SetMVValue("CN300CRG","MV_PAR04","082024") //SubStr(dTos(cTod(AllTrim(aDados[nI][aScan(aCampos,"CN9_DTINIC")]))),5,2)//20491231
		SetMVValue("CN300CRG","MV_PAR05", dDtVencto) //Colocar ultima data do mÊs.
		SetMVValue("CN300CRG","MV_PAR06", 303) // Qtd, puxar da cnb.
		SetMVValue("CN300CRG","MV_PAR07", "   ") //condição de apgto vazia.
		SetMVValue("CN300CRG","MV_PAR08", 0) //Tx de jutos.
										
		Pergunte("CN300CRG",.F.)
		CN300PrCF(.T.) 

	//Validação e Gravação do Modelo
	If oModel:VldData()
		oModel:CommitData()
        nSucesso++
	else
        aLog := {}
		aLog := oModel:GetErrorMessage()
		//TmsMsgErr(aErro)	
        cLogWrite := ""
        For nX :=1 to Len(aLog)
			IF aLog[nX] != Nil
            	cLogWrite += cValToChar(aLog[nX])+CRLF
			ENDIF
        next nX
        
        fWrite(nHdlLog,"Registro: " + cContra)
        fWrite(nHdlLog,cPulaLinha)
        fWrite(nHdlLog,"Erro: ExecAuto.")
        fWrite(nHdlLog,cPulaLinha)
        fWrite(nHdlLog, cLogWrite)
        fWrite(nHdlLog,cPulaLinha)	
	EndIf

	If(ValType(oModel)=='O')
		oModel:DeActivate()
	EndIf

	FT_FUSE()


Return


Static Function fGetPrd(cProduto)

Local cReturn 		:= ""
Local cQuery      	:= ""
Local cAliasQry   	:= ""
Default cProduto 	:= ""

	cQuery := " SELECT " 									+ CRLF
	cQuery += "		B1_COD AS PRODUTO "						+ CRLF
	cQuery += " FROM " + RetSqlName("SB1") + " SB1 " 		+ CRLF
	cQuery += " WHERE SB1.D_E_L_E_T_ = ' '  " 				+ CRLF
	cQuery += " AND B1_XIDSAP = '"+cProduto+"' " 			+ CRLF
	cQuery += " AND B1_FILIAL = '"+FWxFilial("SB1")+"' " 	+ CRLF

	cAliasQry := MPSysOpenQuery(cQuery)

	if !(cAliasQry)->(Eof())
		cReturn := PadR(AllTrim((cAliasQry)->PRODUTO),TamSx3("B1_COD")[1])
	endif

	if Select(cAliasQry) > 0 .AND. !Empty(cAliasQry)
		(cAliasQry)->(DbCloseArea())
	endif

Return(cReturn)


Static Function fGetCli(cCNPJ)

Local cReturn 		:= {}
Local cQuery      	:= ""
Local cAliasQry   	:= ""
Default cCNPJ 	:= ""

	cQuery := " SELECT A1_COD, A1_LOJA 			 "			+ CRLF
	cQuery += " FROM " + RetSqlName("SA1") + " SA1 " 		+ CRLF
	cQuery += " WHERE SA1.D_E_L_E_T_ = ' '  " 				+ CRLF
	cQuery += " AND ( A1_CGC = '"+cCNPJ+"' OR A1_XIDSAP = '"+cCNPJ+"' ) "	+ CRLF
	cQuery += " AND A1_FILIAL = '"+FWxFilial("SA1")+"' " 	+ CRLF
	
	cAliasQry := MPSysOpenQuery(cQuery)

	if !(cAliasQry)->(Eof())
		cReturn := {(cAliasQry)->A1_COD,(cAliasQry)->A1_LOJA}
	endif

	if Select(cAliasQry) > 0 .AND. !Empty(cAliasQry)
		(cAliasQry)->(DbCloseArea())
	endif

Return(cReturn)
