#INCLUDE "mntw020.ch"
#INCLUDE "RWMAKE.CH"
#INCLUDE "PROTHEUS.CH"
#INCLUDE "TOPCONN.CH"

//---------------------------------------------------------------------
/*/{Protheus.doc} MNTW020
Programa para exportar dados para gerar workflow com alerta de Ordem
de servico preventiva a vencer com base no campo de tolerancia no
arquivo STF.
@type function

@author Ricardo Dal Ponte
@since 28/11/2006

@return Lógico, Define se o processo foi realizado com sucesso.
/*/
//---------------------------------------------------------------------
Function MNTW020()

	Local bKeyF10
	Local bKeyF11
	Local bKeyF12
	Local aOldMenu		:= {}
	Local aNGCAD02 		:= {}

	Private asMenu		:= {}
	Private aOrdensSTJ 	:= {}
	Private	aMotivoSTJ 	:= {}
	Private nQtdAVcto 	:= 0
	Private lAMBIE    	:= .F.
	Private cEmail    	:= ""
	Private cTRB		:= ""
	Private cNgMntRh 	:= "N"
	Private aVETINR   	:= {}
	Private dDtProxMan
	Private dDATATEM
	Private dDATACON
	Private oTmpTRB

	aOldMenu := aClone(asMenu)
	aNGCAD02 :={;
					IIf(Type("aCHOICE"		) == "A",aClone(aCHOICE)  ,{}),;
					IIf(Type("aVARNAO"		) == "A",aClone(aVARNAO)  ,{}),;
					IIf(Type("aGETNAO"		) == "A",aClone(aGETNAO)  ,{}),;
					IIf(Type("cGETWHILE"	) == "C",cGETWHILE,Nil)   ,;
					IIf(Type("cGETMAKE"		) == "C",cGETMAKE ,Nil)   ,;
					IIf(Type("cGETKEY"		) == "C",cGETKEY  ,Nil)   ,;
					IIf(Type("cGETALIAS"	) == "C",cGETALIAS,Nil)   ,;
					IIf(Type("cTUDOOK"		) == "C",cTUDOOK  ,Nil)   ,;
					IIf(Type("cLINOK"		) == "C",cLINOK   ,Nil)   ,;
					IIf(Type("aRELAC"		) == "A",aClone(aRELAC)   ,{}),;
					IIf(Type("aCHKDEL"		) == "A",aClone(aCHKDEL)  ,{}),;
					IIf(Type("bngGRAVA"		) == "A",aClone(bngGRAVA) ,{}),;
					IIf(Type("aNGBUTTON"	) == "A",aClone(aNGBUTTON),{});
				}

	cNgMntRh := AllTrim(GetMv("MV_NGMNTRH"))
	asMenu   := NGRIGHTCLICK("MNTW020")
	cTRB	 := GetNextAlias()

	Processa({ || MNTW020TRB()})

	dbSelectArea(cTRB)
	dbGoTop()
	If RecCount() <= 0
		oTmpTRB:Delete()
		MNTW020Ret(bKeyF10,bKeyF11,bKeyF12,aOldMenu,aNGCAD02)
		Return .F.
	EndIf

	If ExistBlock( 'MNTW0201' )
		ExecBlock( 'MNTW0201', .F., .F., { aOrdensSTJ, aMotivoSTJ } )
	Else
		Processa({ || MNTW020F()})
	EndIf

	oTmpTRB:Delete()

	MNTW020Ret(bKeyF10,bKeyF11,bKeyF12,aOldMenu,aNGCAD02)

Return .T.

//---------------------------------------------------------------------
/*/{Protheus.doc} MNTW020TRB
GERACAO DE ARQUIVO TEMPORARIO

@type function

@source MNTW020.prx

@author Ricardo Dal Ponte
@since 24/11/2006

	Nota: Atualizado para utilização da função de envio de workflow
	NGSendMail() pois o antigo processo TMailMessage() estava gerando
	problemas recorrentes.
	@author Rodrigo Luan Backes
	@since 01/09/2016
	S.S.: 028780

@sample MNTW020TRB()

@return Lógico
/*/
//---------------------------------------------------------------------
Function MNTW020TRB()

	Local aDBF		:= {}
	Local cIndR020	:= ""
	Local nTolera	:= 0
	Local dTolera
	Local lMNTW0203 	:= ExistBlock("MNTW0203")

	//criacao arquivo temporario
	//----------------------------------------
	aDBF := {{"CODBEM"  ,"C",16,0},;
		{"NOMBEM"  ,"C",40,0},;
		{"CCUSTO"  ,"C",09,0},; 
		{"NCUSTO"  ,"C",40,0},;
		{"SERVICO" ,"C",06,0},;
		{"SEQRELA" ,"C",03,0},;
		{"NOMSERV" ,"C",40,0},;
		{"PROXMA"  ,"D",08,0},;
		{"NTOLERA" ,"N",06,0},;
		{"DTOLERA" ,"D",08,0},;
		{"CHAVE"   ,"C",25,0},;
		{"COUNT"   ,"N",12,0}}

	//Intancia classe FWTemporaryTable
	oTmpTRB := FWTemporaryTable():New( cTRB, aDBF )
	//Cria indices
	oTmpTRB:AddIndex( "Ind01" , {"PROXMA","CODBEM","SERVICO","SEQRELA"} )
	//Cria a tabela temporaria
	oTmpTRB:Create()

	dbSelectArea("STF")
	dbSetOrder(01)
	dbSeek(xFilial("STF"))
	ProcRegua(RecCount())

	While !EoF() .And. xFilial("STF") = STF->TF_FILIAL

		IncProc()

		If STF->TF_ATIVO == "N"
			dbSelectArea("STF")
			dbSkip()
			Loop
		EndIf

		If STF->TF_PERIODO == "E"
			dbSelectArea("STF")
			dbSkip()
			Loop
		EndIf

		If lMNTW0203
			If !ExecBlock("MNTW0203",.F.,.F.)
				dbSelectArea("STF")
				dbSkip()
				Loop
			EndIf
		EndIf

		nTolera := 0
		Store Ctod("  /  /  ") To dDATATEM,dDATACON
		dDtProxMan := NGXPROXMAN(STF->TF_CODBEM)
		If STF->TF_TIPACOM $ "TA"
			nTolera := STF->TF_TOLERA
			If STF->TF_TIPACOM = "A" .And. dDATACON < dDATATEM
				nTolera := If(!Empty(STF->TF_TOLECON),Int(STF->TF_TOLECON / NGSEEK("ST9",STF->TF_CODBEM,1,"T9_VARDIA")),0)
			EndIf
		Else
			If !Empty(STF->TF_TOLECON)
				nTolera := Int(STF->TF_TOLECON / If(STF->TF_TIPACOM = "S",NGSEEK("TPE",STF->TF_CODBEM,1,"TPE_VARDIA"),;
					NGSEEK("ST9",STF->TF_CODBEM,1,"T9_VARDIA")))
			EndIf
		EndIf
		dTolera := dDtProxMan + nTolera
		If (dDtProxMan <= dDataBase)

			dbSelectArea(cTRB)
			dbSetOrder(01)
			If !dbSeek(DtoS(dDtProxMan)+STF->TF_CODBEM+STF->TF_SERVICO+STF->TF_SEQRELA)
				(cTRB)->(dbAppend())
				(cTRB)->CODBEM  := STF->TF_CODBEM
				(cTRB)->SERVICO := STF->TF_SERVICO
				(cTRB)->SEQRELA := STF->TF_SEQRELA
				(cTRB)->NOMBEM  := NGSEEK("ST9",STF->TF_CODBEM,1,'T9_NOME')
				(cTRB)->CCUSTO  := NGSEEK("ST9",STF->TF_CODBEM,1,'T9_CCUSTO')
				(cTRB)->NCUSTO  := NGSEEK("CTT",(cTRB)->CCUSTO,1,'CTT_DESC01')
				(cTRB)->NOMSERV := NGSEEK("ST4",STF->TF_SERVICO,1,'T4_NOME')
				(cTRB)->PROXMA  := dDtProxMan
				(cTRB)->NTOLERA := nTolera
				(cTRB)->DTOLERA := dTolera
				(cTRB)->CHAVE   := STF->TF_CODBEM+STF->TF_SERVICO+STF->TF_SEQRELA
			EndIf

			dbSelectArea("STJ")
			dbSetOrder(06)
			dbseek(xFilial("STJ")+"B"+STF->TF_CODBEM+STF->TF_SERVICO+STF->TF_SEQRELA)

			While !EoF() .And. xFilial("STJ") == STF->TF_FILIAL	 	.And.;
					STJ->TJ_CODBEM  == STF->TF_CODBEM  .And.;
					STJ->TJ_SERVICO == STF->TF_SERVICO .And.;
					STJ->TJ_SEQRELA == STF->TF_SEQRELA .And.;
					STJ->TJ_TIPOOS  == "B"

				nCont := 1

				aAdd(aOrdensSTJ,{(cTRB)->CHAVE,STJ->TJ_ORDEM,'1'})

				dbSelectArea("TPL")
				dbSetOrder(01)
				If dbseek(xFilial("TPL")+STJ->TJ_ORDEM)
					While !EoF() .And. TPL->TPL_FILIAL == xFilial("TPL") .And. TPL->TPL_ORDEM == STJ->TJ_ORDEM
						aAdd(aMotivoSTJ,{STJ->TJ_ORDEM,TPL->TPL_CODMOT+' - '+NGSEEK("TPJ",TPL->TPL_CODMOT,1,'TPJ_DESMOT'),;
							TPL->TPL_DTINIC,TPL->TPL_HOINIC,TPL->TPL_DTFIM,TPL->TPL_HOFIM})
						nCont++
						dbSkip()
					End
				EndIf
				aOrdensSTJ[Len(aOrdensSTJ)][3] := Str(nCont)

				dbSelectArea(cTRB)
				Reclock((cTRB),.F.)
				(cTRB)->COUNT := nCont
				MsUnLock()

				dbSelectArea("STJ")
				dbskip()
			End
		EndIf

		dbSelectArea("STF")
		dbSkip()
	End

Return .T.

//---------------------------------------------------------------------
/*/{Protheus.doc} MNTW020F
Programa para exportar dados para gerar workflow.
@type function

@author Ricardo Dal Ponte
@since 24/11/2006

@return Lógico, Define se o processo foi realizado com sucesso.
/*/
//---------------------------------------------------------------------
Function MNTW020F()

	Local aRegistros := {}
	Local nRegs      := 0
	Local lRet       := .T.

	dbSelectArea(cTRB)
	dbSetOrder(1)
	ProcRegua(LastRec())

	Do While (cTRB)->( !EoF() )
		IncProc()
		nRegs++
		aAdd(aRegistros,{	(cTRB)->PROXMA ,;
			(cTRB)->CODBEM ,;
			(cTRB)->NOMBEM ,;
			(cTRB)->CCUSTO ,;
			(cTRB)->NCUSTO ,;
			(cTRB)->SERVICO,;
			(cTRB)->NOMSERV,;
			(cTRB)->SEQRELA,;
			(cTRB)->NTOLERA,;
			(cTRB)->DTOLERA,;
			(cTRB)->CHAVE  })

		//faz o envio de workflow a cada 500 registros, quando o volume eh muito grande
		nRegs += (cTRB)->COUNT

		If nRegs == 500

			lRet := MNTW20SEND( aRegistros, .F. )
			nRegs := 0
			aRegistros := {}

			// Caso ocorra erro no envio em algum lote, encerra o processo dos demais envios.
			If !lRet
				Exit
			EndIf

		EndIf

		(cTRB)->( dbSkip() )

	EndDo

	//envio de workflow menor que 500 registros ou a diferenca que ultrapassou 500
	If Len( aRegistros ) > 0
		lRet := MNTW20SEND( aRegistros, .T. )
	EndIf

Return lRet

//---------------------------------------------------------------------
/*/{Protheus.doc} W020EMAIL
GERACAO DA LISTA DE EMAILS PARA O WORKFLOW

@type function

@source MNTW020.prx

@author Ricardo Dal Ponte
@since 24/11/2006

@sample W020EMAIL()

@return Caractere
/*/
//---------------------------------------------------------------------
Function W020EMAIL(cPrograma)
	
	Local aArea  := GetArea()
	Local cEmail :=""
	Local cEmailC:=""

	dbSelectArea("TP0")
	SET FILTER To TP0->TP0_CODPRO = cPrograma
	dbGoTop()
	While !EoF()
		dbSelectArea("TPT")
		SET FILTER To TPT->TPT_CODGRP = TP0->TP0_CODGRP
		dbGoTop()

		While !EoF()
			cCodFun :=TPT->TPT_CODFUN

			If cNgMntRh $ "SX"
				//CARREGA EMAIL DO CADASTRO DE FUNCIONARIOS DO SISTEMA DE RH (TABELA SRA)
				dbSelectArea("SRA")
				dbSetOrder(01)
				If dbSeek(xFilial("SRA")+cCodFun)
					If !Empty(SRA->RA_EMAIL)
						cEmail:=AllTrim(SRA->RA_EMAIL)
					EndIf
				EndIf
			EndIf

			If Empty(cEmail)
				//CARREGA EMAIL DO CADASTRO DE FUNCIONARIOS DO SISTEMA DE MNT (TABELA ST1)
				dbSelectArea("ST1")
				dbSetOrder(01)
				If dbSeek(xFilial("ST1")+cCodFun)
					If !Empty(ST1->T1_EMAIL)
						cEmail:=AllTrim(ST1->T1_EMAIL)
					EndIf
				EndIf
			EndIf

			If cEmailC == ""
				cEmailC := cEmail
			Else
				If cEmail <> ""
					cEmailC := cEmailC+";"+cEmail
				EndIf
			EndIf

			cEmail := ""

			dbSelectArea("TPT")
			dbSkip()
		End

		dbSelectArea("TP0")
		dbSkip()
	End

	cEmailC := NgEmailWF("1","MNTW020")

	dbSelectArea("TP0")
	Set Filter To

	dbSelectArea("TPT")
	Set Filter To

	RestArea( aArea )

Return cEmailC

//---------------------------------------------------------------------
/*/{Protheus.doc} MNTW020Ret
Programa para exportar dados para gerar workflow com alerta de
tendencia de falhas de bens.

@type function

@source MNTW020.prx

@author Felipe N. Welter
@since 28/07/2008

	Nota: Atualizado para utilização da função de envio de workflow
	NGSendMail() pois o antigo processo TMailMessage() estava gerando
	problemas recorrentes.
	@author Rodrigo Luan Backes
	@since 01/09/2016
	S.S.: 028780

@sample MNTW020Ret()

@return Lógico
/*/
//---------------------------------------------------------------------
Static Function MNTW020Ret(bKeyF10,bKeyF11,bKeyF12,aOldMenu,aNGCAD02)

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Devolve variaveis armazenadas (NGRIGHTCLICK) 							  	  ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	SETKEY(VK_F10,bKeyF10)
	SETKEY(VK_F11,bKeyF11)
	SETKEY(VK_F12,bKeyF12)

	asMenu := aClone(aOldMenu)

	aCHOICE := aClone(aNGCAD02[1])
	aVARNAO := aClone(aNGCAD02[2])
	AGETNAO := aClone(aNGCAD02[3])

	IIf(aNGCAD02[4] != Nil,cGETWHILE := aNGCAD02[4],)
	IIf(aNGCAD02[5] != Nil,cGETMAKE  := aNGCAD02[5],)
	IIf(aNGCAD02[6] != Nil,cGETKEY   := aNGCAD02[6],)
	IIf(aNGCAD02[7] != Nil,cGETALIAS := aNGCAD02[7],)
	IIf(aNGCAD02[8] != Nil,cTUDOOK   := aNGCAD02[8],)
	IIf(aNGCAD02[9] != Nil,cLINOK    := aNGCAD02[9],)

	aRELAC    := aClone(aNGCAD02[10])
	aCHKDEL   := aClone(aNGCAD02[11])
	bngGRAVA  := aClone(aNGCAD02[12])
	aNGBUTTON := aClone(aNGCAD02[13])

Return .T.

//---------------------------------------------------------------------------------
/*/{Protheus.doc} MNTW20SEND
Funcao de envio do workflow
@type function

@author Felipe Helio dos Santos
@since 14/02/2013

@sample MNTW20SEND( aRegi, .F. )

@param aRegistros, Array , Registros que compõe o workflow enviado.
@param lUltimo   , Lógico, Define se é o ultimo lote de 500 registros de envio.
@return Lógico   , Define se o envio do workflow foi enviado com sucesso.
/*/
//---------------------------------------------------------------------------------
Static Function MNTW20SEND( aRegistros, lUltimo )

	Local n1 ,n3
	Local nSTJ		 := 0
	Local lRet       := .T.
	Local cEmailEnv	 := W020EMAIL("MNTW020")+Chr(59)
	Local cMailMsg   := ''
	Local lNoInter   := IsBlind()

	//Inicio o processo
	cMailMsg := '<html>'
	cMailMsg += '<head>'
	cMailMsg += '<meta http-equiv="Content-Language" content="pt-br">'
	cMailMsg += '<meta http-equiv="Content-Type" content="text/html; charset=windows-1252">'
	cMailMsg += '<meta name="GENERATOR" content="Microsoft FrontPage 4.0">'
	cMailMsg += '<meta name="ProgId" content="FrontPage.Editor.Document">'
	cMailMsg += '<title>Aviso sobre Solicitação de Serviços</title>'
	cMailMsg += '</head>'
	cMailMsg += '<body bgcolor="#FFFFFF">'
	cMailMsg += '<table border=0 WIDTH=100% cellpadding="1">'
	cMailMsg += '<tr>'
	cMailMsg += '   <td bgcolor="#C0C0C0" align="center"><b><font face="Arial" size="2">'+STR0014+'</font></b></td>' //"Proxima Manutencao"
	cMailMsg += '   <td bgcolor="#C0C0C0" align="left"><b><font face="Arial" size="2">'+STR0015+'</font></b></td>'   //"Bem"
	cMailMsg += '   <td bgcolor="#C0C0C0" align="left"><b><font face="Arial" size="2">'+STR0016+'</font></b></td>'   //"Nome do Bem"
	cMailMsg += '   <td bgcolor="#C0C0C0" align="left"><b><font face="Arial" size="2">'+STR0017+'</font></b></td>'   //"Centro Custo"
	cMailMsg += '   <td bgcolor="#C0C0C0" align="left"><b><font face="Arial" size="2">'+STR0024+'</font></b></td>'   //"Nome do C.C"
	cMailMsg += '   <td bgcolor="#C0C0C0" align="left"><b><font face="Arial" size="2">'+STR0018+'</font></b></td>'   //"Servico"
	cMailMsg += '   <td bgcolor="#C0C0C0" align="left"><b><font face="Arial" size="2">'+STR0019+'</font></b></td>'   //"Nome do Servico"
	cMailMsg += '   <td bgcolor="#C0C0C0" align="Center"><b><font face="Arial" size="2">'+STR0020+'</font></b></td>' //"Sequencia"
	cMailMsg += '   <td bgcolor="#C0C0C0" align="left"><b><font face="Arial" size="2">'+STR0021+'</font></b></td>'   //"Dias Tolerância"
	cMailMsg += '   <td bgcolor="#C0C0C0" align="left"><b><font face="Arial" size="2">'+STR0022+'</font></b></td>'   //"Data Tolerância"
	cMailMsg += '</tr>'

	ProcRegua(Len(aRegistros))

	For n1 := 1 to Len(aRegistros)
		IncProc()
		cMailMsg += '<tr>'
		cMailMsg += '   <td bgcolor="#EEEEEE" align="center"><font face="Arial" size="1">'+DTOC(aRegistros[n1,1])+'</font></td>'
		cMailMsg += '   <td bgcolor="#EEEEEE" align="left"><font face="Arial" size="1">'+aRegistros[n1,2]+'</font></td>'
		cMailMsg += '   <td bgcolor="#EEEEEE" align="left"><font face="Arial" size="1">'+aRegistros[n1,3]+'</font></td>'
		cMailMsg += '   <td bgcolor="#EEEEEE" align="left"><font face="Arial" size="1">'+aRegistros[n1,4]+'</font></td>'
		cMailMsg += '   <td bgcolor="#EEEEEE" align="left"><font face="Arial" size="1">'+aRegistros[n1,5]+'</font></td>'
		cMailMsg += '   <td bgcolor="#EEEEEE" align="left"><font face="Arial" size="1">'+aRegistros[n1,6]+'</font></td>'
		cMailMsg += '   <td bgcolor="#EEEEEE" align="left"><font face="Arial" size="1">'+aRegistros[n1,7]+'</font></td>'
		cMailMsg += '   <td bgcolor="#EEEEEE" align="center"><font face="Arial" size="1">'+aRegistros[n1,8]+'</font></td>'
		cMailMsg += '   <td bgcolor="#EEEEEE" align="left"><font face="Arial" size="1">'+AllTrim(Str(aRegistros[n1,9]))+'</font></td>'
		cMailMsg += '   <td bgcolor="#EEEEEE" align="center"><font face="Arial" size="1">'+DTOC(aRegistros[n1,10])+'</font></td>'
		cMailMsg += '</tr>'

		While .T.

			nSTJ := aScanX(aOrdensSTJ, {|x,y| x[1] == aRegistros[n1,11] .And. y > nSTJ })
			If nSTJ > 0
				If Val(aOrdensSTJ[nSTJ][3]) > 1 //So imprime se tiver motivo de atraso
					cMailMsg += '<tr>'
					cMailMsg += '<td></td><td rowspan="'+AllTrim(aOrdensSTJ[nSTJ][3])+'" bgcolor="#EEEEEE" align="center"><font face="Arial" size="1"><b>';
						+STR0026+'</b>'+aOrdensSTJ[nSTJ][2]+'</font></td>' //"O.S.: "
					cMailMsg += '</tr>'
					aSort(aMotivoSTJ,,,{|x,y| DTOS(x[3])+x[4] < DTOS(y[3])+y[4]})
					For n3 := 1 to Len(aMotivoSTJ)
						If aMotivoSTJ[n3][1] == aOrdensSTJ[nSTJ][2]
							cMailMsg += '<tr>'
							cMailMsg += '<td><td colspan="4" bgcolor=	"#EEEEEE" align="left"><font face="Arial" size="1"><b>';
								+STR0027+'</b>'+aMotivoSTJ[n3][2]+'</font></td>' //"Motivo do Atraso: "
							cMailMsg += '<td colspan="2" td bgcolor="#EEEEEE" align="left"><font face="Arial" size="1">'+'<b>';
								+STR0028+'</b>'+DTOC(aMotivoSTJ[n3][3])+' - '+aMotivoSTJ[n3][4]+'</font></td>' //"Data/Hora Início: "
							cMailMsg += '<td colspan="2" td bgcolor="#EEEEEE" align="left"><font face="Arial" size="1">'+'<b>';
								+STR0029+'</b>'+DTOC(aMotivoSTJ[n3][5])+' - '+aMotivoSTJ[n3][6]+'</font></td>' //"Data/Hora Fim: "
						EndIf
					Next
				EndIf
			Else
				Exit
			EndIf

		EndDo
	Next

	If ExistBlock("MNTW0202")
		cMailMsg := ExecBlock("MNTW0202",.F.,.F.,{cMailMsg})
	EndIf

	cMailMsg += '</table>'
	cMailMsg += '<br><hr>'
	cMailMsg += '</body>'
	cMailMsg += '</html>'

	If Empty( cEmailEnv )

		If FindFunction( 'NGLogMsg' )
			NGLogMsg( STR0034, , , 'WARN', 'MNTW020' ) // Destinatário do E-mail não informado. # Atenção!
		ElseIf !lNoInter
			MsgAlert( STR0034 ) // Destinatário do E-mail não informado.
		EndIf
		lRet := .F.

	Else

		lRet := NGSendMail( , cEmailEnv, , , STR0030, , cMailMsg,,,,,,, 'MNTW020' ) // Manut. Prev. Atras.

		If lUltimo .And. lRet

			If FindFunction( 'NGLogMsg' )
				NGLogMsg( STR0023, , , 'INFO', 'MNTW020' ) // Workflow enviado com sucesso!
			ElseIf !lNoInter
				MsgInfo( STR0023 ) // Workflow enviado com sucesso!
			EndIf

		EndIf

	EndIf

Return lRet

//---------------------------------------------------------------------
/*/{Protheus.doc} SchedDef
Execução de Parâmetros na Definição do Schedule
@type static

@author Alexandre Santos
@since 05/04/2019

@sample SchedDef()

@param
@return Array, Conteudo com as definições de parâmetros para WF
/*/
//---------------------------------------------------------------------
Static Function SchedDef()
Return { 'P', 'PARAMDEF', '', {}, 'Param' }
