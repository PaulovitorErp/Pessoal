#INCLUDE "PROTHEUS.CH"
#INCLUDE "FWMVCDEF.CH"
#INCLUDE "FWADAPTEREAI.CH"
#INCLUDE "CTBA030.CH"

STATIC __lCTA030CC	:= .F.
STATIC lCTA030TOK	:= ExistBlock("CTA030TOK")
STATIC lCTB030AUT	:= .F.
STATIC lIntTAF		:= ((SuperGetMv("MV_RHTAF",, .F.) == .T.) .AND. Val(SuperGetMv("MV_FASESOC",/*lHelp*/,' ')) >= 0 )

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³ CTBA030  ³ Autor ³ Pilar S. Albaladejo   ³ Data ³ 04/11/99 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Cadastramento de Centro de Custo 			              ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ CTBA030()                                                  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³ Nenhum                                                     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ Generico                                                   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ Nenhum                                                     ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±³			ATUALIZACOES SOFRIDAS DESDE A CONSTRU€AO INICIAL.			  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Programador ³ Data	³ FNC  ³  Motivo da Alteracao 					  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Aldo Marini ³07/07/11³014243³Preparacao para integracao do SIGAPON com ³±±
±±³            ³SDQY07  ³  2011³o TSA (Totvs Controle de Acesso) via Web  ³±±
±±³            ³        ³  	   ³services, desenvolvidos pela Datasul.	  ³±±
±±³Allyson M.  ³27/09/11³021301³Alteracao p/ replicar o conteudo do campo ³±±
±±³            ³        ³  2011³CTT_PEREMP p/ o I3_PEREMP.     			  ³±±
±±³Allyson M.  ³10/01/12³000406³Alteracao p/ replicar o conteudo do campo ³±±
±±³            ³        ³  2012³CTT_RECFAT p/ o I3_RECFAT.     			  ³±± 
±±³Raquel Hager³04/04/12³008509³Ajuste na funcao Ctba030Del para nao exclu³±±
±±³            ³        ³  2012³sao de centro de custo que possua cadastro³±± 
±±³            ³        ³      ³em departamento - Tabela SQB.        	    ³±±
±±³Allyson M.  ³16/04/12³009590³Alteracao p/ retirar o tratamento incluido ³±±
±±³            ³        ³  2012³dos campos CTT_RECFAT p/ o I3_RECFAT.      ³±±
±±³Leandro Dr. ³18/05/12³TF1898³Alteracao p/ replicar o conteudo do campo  ³±±
±±³            ³        ³      ³CTT_RECFAT p/ o I3_RECFAT.     	        ³±±
±±³Aldo Marini ³10/09/12³TFQQQM³Alteracao no WebService do TSA.	        ³±±
±±³Marcos Perei³03/09/15³PCREQ-³Alteração no retorno do ExecAuto, para a  ³±±
±±³            ³        ³5342  ³~produtização da gestão pública P12       ³±±
±±³Mariana M.  ³06/11/15³TTQN31³Criada validação na função Ct030TudOk para³±±
±±³            ³        ³      ³que ao incluir/alterar um centro de custo,³±±
±±³            ³        ³      ³o sistema não confirme quando campo CNPJ/ ³±±
±±³            ³        ³      ³CEI Tomad estiver em branco ou inválido,  ³±±
±±³            ³        ³      ³respeitando conteúdo do campo T.Insc.Tomad³±±
±±³Marcos Cout ³01/08/17³DRHESO³Realizar criação dos eventos extemporaneo ³±±
±±³            ³        ³CP-562³dos eventos S-1005 e S-1020               ³±±
±±³Marcos Cout ³20/12/17³DRHESOC³Realizado ajustes para geração ds eventos³±±
±±³            ³        ³P-2449 ³S-1005 e S-1020 do eSocial. Ajuste de msg³±±
±±³            ³        ³       ³Ajuste nas validações. Correção de error ³±±
±±³            ³        ³       ³ocasionado pela variavel Private. Ajuste ³±±
±±³            ³        ³       ³na leitura da variavel com os campos     ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
/*
Usar essa documentação quando inclui o fonte em alguma pasta de inovação, por exemplo
12.1.6, a cada merge com o fonte da sustentação atualizar as informações abaixo para 
que no merge final fique facil a atualização do fonte
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÑÍÍÍÍ³±±
±±³Data Fonte Sustentação³ ChangeSet ³±±
±±³ÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄ³±±  
±±³    07/08/2015        ³  321044   ³±±
±±³    06/11/2015        ³  341133   ³±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÑÍÍÍÍÍ±±
*/

Function CTBA030(aRotAuto,nOpcAuto)

Local aCores := {	{ "CTT_BLOQ == '1'" , "BR_VERMELHO"	},; // Conta Bloqueada
					{ "CTT_BLOQ == '2' .AND. ( ( Empty( CTT_DTEXIS ) .Or. CTT_DTEXIS <= dDatabase ) .AND. ( Empty( CTT_DTEXSF ) .Or. CTT_DTEXSF >= dDatabase ) )" , "BR_VERDE"   	},; // Sem Restrição
					{ "CTT_BLOQ == '2' .AND. ( ! Empty( CTT_DTEXIS ) .AND. CTT_DTEXIS >= dDatabase )" , "BR_AMARELO"	},; // Exercicio Não Iniciado
					{ "CTT_BLOQ == '2' .AND. ( ! Empty( CTT_DTEXSF ) .AND. CTT_DTEXSF <= dDatabase )" , "BR_CINZA"		} } // Exercicio Finalizado

PRIVATE aRotina := MenuDef()

PRIVATE cCadastro := OemToAnsi(STR0006)+CtbSayApro("CTT")  //"Cadastro Centro de Custos"     
__lCTA030CC := CtbMovSaldo("CTT")        

DEFAULT aRotAuto := {}
DEFAULT nOpcAuto := 3

If !__lCTA030CC            
	Help(" ",1,"NCONSALCC")
	Return
Endif	

If Len(aRotAuto) > 0
	lCTB030AUT := .T.
Else
	SetKey(VK_F12,{|a,b|AcessaPerg("CTB030",.T.)})
	////Verifica se utiliza o modulo de Gestao de Folha Publica - SIGAGFP 
	If FindFunction("fUsaGFP") .And. fUsaGFP()
		//Força .F. -> quando executa previamente alguma rotina com execauto da ctba030, esta variavel sai como .T. e
		//se executar em seguida esta rotina ctba030 via menu, a variavel entra já como .T. e executa como se fosse execauto
		lCTB030Aut := .f.  
	EndIf
EndIf


Pergunte("CTB030",.F.)

If lCTB030Aut
	PRIVATE aAutoCab   := Aclone(aRotAuto)
		MBrowseAuto(nOpcAuto,aAutoCab,"CTT")
Else  
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Variaveis utilizadas para parametros						³
	//³ mv_par01		// Gera CC  Sup? Autom/Formula/Digit	  	³
	//³ mv_par02		// Formula CC Sup							³
	//³ mv_par03		// Cadastro em arvore (Nao/Sim/Perguntar)	³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	
	If mv_par03 == 2
		CtbaTree("CTT")
		SET KEY VK_F12 to
		Return
	ElseIf mv_par03 == 3
		If MsgYesNo(STR0012)
			CtbaTree("CTT")
			SET KEY VK_F12 to
			Return
		EndIf
	EndIf
	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Endereca a funcao de BROWSE                                  ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	mBrowse( 6, 1,22,75,"CTT",,,,,,aCores)
	
	SET KEY VK_F12 to
EndIf

Return

/*/
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³Ctba030INC³ Autor ³ Pilar S. Albaladejo   ³ Data ³ 05/11/99 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Programa de Inclusao de Centro de Custo                    ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ ctba030Inc(ExpC1,ExpN1,ExpN2)                              ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³ Nenhum                                                     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ GENERICO                                                   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ ExpC1 = Alias do arquivo                                   ³±±
±±³          ³ ExpN1 = Numero do registro                                 ³±±
±±³          ³ ExpN2 = Numero da opcao selecionada                        ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function Ctba030Inc(cAlias,nReg,nOpc)

Local aTam			:= TamSX3("I3_CUSTO")
Local nOpcA			:= 0
Local lCtb030Vld	:= ExistBlock("CTB030VLD")
Local cInte 		:=  SuperGetMV("MV_PCOINTE",.T.,"2")
Local cSinc			:=  SuperGetMV("MV_PCOSINC",.T.,"1")
Local nY			:= 0
Local bCampo		:= {|nCPO| Field(nCPO)} 
Local cIntRes		:= ""
Local lTSREP		:= SuperGetMv( "MV_TSREP" , NIL , .F. )
Local aEaiRet		:= {}

Private oObjREP		:= Nil

Private aTELA[0][0]
Private aGETS[0]
PRIVATE aCposHistor := {} //21/07/2010
PRIVATE cCadastro := Alltrim(OemToAnsi(STR0006)+CtbSayApro("CTT"))+" - "+ UPPER(OemToAnsi(STR0003))  //"Cadastro + Centro de Custos - Incluir"     
Private aRotina   := MenuDef()      
DEFAULT nOpc := 3 

If FunName() == 'CTBA030'
	Chkfile("CTT")
	dbSelectArea("CTT")
	dbSetOrder(1)
EndIf            

cAlias := If(cAlias==NIL .Or. cAlias=="CTT001", ALIAS(), cAlias) // CTT001 -> Quando vem da consulta padrão SXB - CTT001

If lCtb030Vld
	If !ExecBlock("CTB030VLD", .F., .F.,nOpc)
		Return
    EndIf
EndIf

BEGIN TRANSACTION         
	If !lCTB030AUT		// SE NAO FOR ROTINA AUTOMATICA
		nOpca := AxInclui (cAlias,nReg,nOpc,,,,"Ct030TudOk(nOpc)")
	Else
		nOpca := AxInclui(cAlias,nReg,nOpc,/*aAcho*/,/*cFunc*/   ,/*aCpos*/,"Ct030TudOk(nOpc)",/*lF3*/,  ,   ,/*aParam*/,aAutoCab  ,/*lVirtual*/,/*lMaximized*/)
	EndIf
	
	If nOpca == 1	
		
		cIntRes := CTT->CTT_INTRES // Integra com Reserve
	
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³ Pto de entrada para gravacao de cpos de usu rio. ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			If ExistBlock("CT030GRI")
				ExecBlock("CT030GRI",.F.,.F.)
			Endif	
			dbSelectAREA("CTT")
		EndIf			
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Verifica se o plano de contas esta sincroni- ³
		//³ zado com o plano de contas orcamentario      ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		
		If cInte=="1" .And. cSinc=="3"
			PcoSincCO("CTT",1)
		EndIf
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Grava Histórico de Alterações na tabela CW4.                          ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ              
		If nOpc == 3
			CTBGrvHist(xFilial("CTT"),"CTT"		,CTT->CTT_CUSTO,       ,ValType(CTT->CTT_CUSTO),"CTT_CUSTO",""       ,CTT->CTT_CUSTO,nOpc)
			//		   cFilTabela	 ,cEntidade ,cCodigo       ,cGrupo,cTipoCampo             ,cCampo,cValorAnt,cValorNovo   ,nOpc)
		Else	  
			For nY := 1 To Len(aCposHistor)
				aCposHistor[nY][3] := CTT->&(EVAL(bCampo,nY))	  
				If aCposHistor[nY][2] <> aCposHistor[nY][3]
					CTBGrvHist(xFilial("CTT"),"CTT"     ,CTT->CTT_CUSTO,      ,ValType(aCposHistor[nY][1]),aCposHistor[nY][1],aCposHistor[nY][2],aCposHistor[nY][3],nOpc)
					//           cFilTabela	 ,cEntidade ,cCodigo       ,cGrupo,cTipoCampo                 ,cCampo            ,cValorAnt         ,cValorNovo        ,nOpc)
	       		EndIf
	   		Next nY
		EndIf
		
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
		//³Integracao protheus X tin	³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
		If FWHasEAI("CTBA030",.T.,,.T.)	
			aEaiRet := FwIntegDef( 'CTBA030' )
			
			If !aEaiRet[1]
				Help(" ",1,"HELP","Erro EAI",STR0041,3,1)//"Problemas na integração EAI, Transação não executada."
				DisarmTransaction()
			EndIf	
		Else
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³ Integracao PIMS GRAOS                             ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ			                                
			If SuperGetMV("MV_PIMSINT",.F.,.F.)
				PIMSGeraXML("CostCenter",STR0016,"2","CTT") //--## Centro de Custo
			EndIf
		Endif
	
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Integra Protheus x LEGAL DESK - SIGAPFS             ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		//Grava na fila de sincronização se o parâmetro MV_JFSINC = '1' - SIGAPFS
		J170GRAVA("CTT", xFilial("CTT") + CTT->CTT_CUSTO, "3")
	
		//-- Inicializa a integracao via WebServices TSA
		If lTSREP
			oObjREP := PTSREPOBJ():New()	
	
			/*/
			ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			³ Executa o WebServices TSA - Centro de Custo                  ³
			ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ*/
			If oObjREP:WSCostCenter( 1 )
		
				/*/
				ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				³ Grava o Log do controle de exportacao WebServices TSA        ³
				ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ*/
				oObjRep:WSUpdRHExp( "CTT" )
		
			Endif
		EndIF
			
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
		//³Integracao SIGAOMS X SIGAGFE	³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
		If !lCTB030AUT
			MaEnvEAI(/*EMPRESA*/,/*FILIAL*/,nOpc,"CTBA030",{ { "CTT", "CTBA030_CTT", NIL, NIL, NIL, NIL } },,,,,,"CTBA030" )
		EndIf	
		//--------------------
		// Integração Reserve
		//--------------------
		If cIntRes == '1'
			If SuperGetMV("MV_RESEXP",.F.,"0") <> "0" .And.;			//Verifica a forma de exportacao definida
				SubStr(SuperGetMV("MV_RESCAD",.F.,"111"),1,1) == "1"	//Verifica se a exportacao do centro de custo esta habilitada
				FINA655(nOpc)
			EndIf
		EndIf
		
		//Integração com o SIGAMDT
		If SuperGetMV( "MV_MDTGPE" , .F. , "N" ) == "S" .And. FindFunction("MDTW030")
			MDTW030( "CTT" , CTT->CTT_CUSTO ) //Executa o W.F. de Aviso do SESMT
		EndIf	
	

END TRANSACTION	

dbSelectArea("CTT")

Return

/*/
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³Ctba030Alt³ Autor ³ Pilar S. Albaladejo   ³ Data ³ 05/11/99 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Programa de Alteracao de Centro de Custo                   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ ctba030Alt(ExpC1,ExpN1,ExpN2)                              ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³ Nenhum                                                     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ GENERICO                                                   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ ExpC1 = Alias do arquivo                                   ³±±
±±³          ³ ExpN1 = Numero do registro                                 ³±±
±±³          ³ ExpN2 = Numero da opcao selecionada                        ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function Ctba030Alt(cAlias,nReg,nOpc)

Local aSaveArea:= GetArea()
Local aTam		:= TamSX3("I3_CUSTO")
Local nOpcA		:= 0
Local lCtb030Vld := ExistBlock("CTB030VLD")
Local cInte :=  SuperGetMV("MV_PCOINTE",.T.,"2")
Local cSinc :=  SuperGetMV("MV_PCOSINC",.T.,"1")
Local nY    := 0
Local bCampo := {|nCPO| Field(nCPO)} 

Local lTSREP		:= SuperGetMv( "MV_TSREP" , NIL , .F. )
Local aEaiRet		:= {}
Private oObjREP		:= Nil

PRIVATE aCposHistor := {} //21/07/2010
PRIVATE cCadastro := Alltrim(OemToAnsi(STR0006)+CtbSayApro("CTT"))+" - "+ UPPER(OemToAnsi(STR0004))  //"Cadastro + Centro de Custos - Alterar"     
Private aRotina   := MenuDef()

dbSelectArea("CTT")
dbSetOrder(1)

If lCtb030Vld
	If !ExecBlock("CTB030VLD", .F., .F.,nOpc)
		Return
    EndIf
EndIf        

BEGIN TRANSACTION 

If !lCTB030AUT		// SE NAO FOR ROTINA AUTOMATICA
	nOpca := AxAltera(cAlias,nReg,nOpc,,,,,"Ct030TudOk(4)")
Else
	nOpca := AxAltera(cAlias,nReg,nOpc,/*aAcho*/,/*cFunc*/   ,/*aCpos*/,,"Ct030TudOk(4)",/*lF3*/,  ,   ,/*aParam*/,aAutoCab  ,/*lVirtual*/,/*lMaximized*/)
EndIf

If nOpca == 1
	
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Pto de entrada para gravacao de cpos de usu rio. ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		If ExistBlock("CT030GRA")
			ExecBlock("CT030GRA",.F.,.F.)
		Endif	
		dbSelectAREA("CTT")
	EndIf			

	If cInte=="1" .And. cSinc=="3"
		PcoSincCO("CTT",2)
	EndIf
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Grava Histórico de Alterações na tabela CW4.                          ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If nOpc == 3
		CTBGrvHist(xFilial("CTT"),"CTT"		,CTT->CTT_CUSTO,       ,ValType(CTT->CTT_CUSTO),"CTT_CUSTO",""       ,CTT->CTT_CUSTO,nOpc)
		//		   cFilTabela	 ,cEntidade ,cCodigo       ,cGrupo,cTipoCampo             ,cCampo,cValorAnt,cValorNovo   ,nOpc)
	Else	  
		For nY := 1 To Len(aCposHistor)
			aCposHistor[nY][3] := CTT->&(EVAL(bCampo,nY))	  
			If aCposHistor[nY][2] <> aCposHistor[nY][3]
				CTBGrvHist(xFilial("CTT"),"CTT"     ,CTT->CTT_CUSTO,      ,ValType(aCposHistor[nY][1]),aCposHistor[nY][1],aCposHistor[nY][2],aCposHistor[nY][3],nOpc)
				//           cFilTabela	 ,cEntidade ,cCodigo       ,cGrupo,cTipoCampo                 ,cCampo            ,cValorAnt         ,cValorNovo        ,nOpc)
       		EndIf
   		Next nY
	EndIf
 
	//-- Inicializa a integracao via WebServices TSA
	If lTSREP
		oObjREP := PTSREPOBJ():New()	

		/*/
		ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		³ Executa o WebServices TSA - Centro de Custo                  ³
		ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ*/
		If oObjREP:WSCostCenter( 2 )
	
			/*/
			ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			³ Grava o Log do controle de exportacao WebServices TSA        ³
			ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ*/
			oObjRep:WSUpdRHExp( "CTT" )
	
		Endif
	EndIF
	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
	//³Integracao protheus X tin	³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
	If FWHasEAI("CTBA030",.T.,,.T.)		
		aEaiRet := FwIntegDef( 'CTBA030' )		
		
		If !aEaiRet[1]
			Help(" ",1,"HELP","Erro EAI",STR0041,3,1) //"Problemas na integração EAI, Transação não executada."
			DisarmTransaction()			
		EndIf	
		
	Else
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Integracao PIMS GRAOS                             ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ			                                
		If SuperGetMV("MV_PIMSINT",.F.,.F.)
			PIMSGeraXML("CostCenter",STR0016,"2","CTT") //--## Centro de Custo
		EndIf
	Endif
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Integra Protheus x LEGAL DESK - SIGAPFS             ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	//Grava na fila de sincronização se o parâmetro MV_JFSINC = '1' - SIGAPFS
	J170GRAVA("CTT", xFilial("CTT") + CTT->CTT_CUSTO, "4")
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
	//³Integracao SIGAOMS X SIGAGFE	³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
	If !lCTB030AUT
		MaEnvEAI(/*EMPRESA*/,/*FILIAL*/,nOpc,"CTBA030",{ { "CTT", "CTBA030_CTT", NIL, NIL, NIL, NIL } },,,,,,"CTBA030" )                    
	Endif

	//--------------------
	// Integração Reserve
	//--------------------
	If CTT->CTT_INTRES == '1' .AND. SuperGetMV("MV_RESEXP",.F.,"0") <> "0" .And.;			//Verifica a forma de exportacao definida
		SubStr(SuperGetMV("MV_RESCAD",.F.,"111"),1,1) == "1"	//Verifica se a exportacao do centro de custo esta habilitada
		FINA655(nOpc)
	EndIf

END TRANSACTION	

RestArea(aSaveArea)

Return

/*/
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³Ctba030del³ Autor ³ Pilar S. Albaladejo   ³ Data ³ 05/11/99 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Programa de exclusao de C. Custo                           ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ ctba030Del(ExpC1,ExpN1,ExpN2)                              ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³ Nenhum                                                     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ GENERICO                                                   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ ExpC1 = Alias do arquivo                                   ³±±
±±³          ³ ExpN1 = Numero do registro                                 ³±±
±±³          ³ ExpN2 = Numero da opcao selecionada                        ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function Ctba030Del(cAlias,nReg,nOpc)

Local aSaveArea		:= GetArea()
Local aTam			:= TamSX3("I3_CUSTO")
LOCAL nOpcA 		:= 0
Local lRet			:= .T.
Local oDlg
Local bCampo             
Local nRecCTT		:= 0
Local i   
Local aInfo     := {}
Local aPosObj   := {}
Local aObjects  := {}

Local lCtb030Vld	:= ExistBlock("CTB030VLD")
Local lCt030ADel	:= ExistBlock("CT030ADEL")	
Local lTemIndice	:= .T.
Local cSixChave		:= ""
Local cCtt_Custo	:= ""
Local cCtt_Filial	:= ""
Local cInte :=  SuperGetMV("MV_PCOINTE",.T.,"2")
Local cSinc :=  SuperGetMV("MV_PCOSINC",.T.,"1")
Local lIntGPE := If(GetMv("MV_QGINT",.F.,"N") == "S",.T.,.F.)
Local lCanEx  := .T.
Local aVerCC	:= {}		// Vetor que armazena as tabelas que precisam ser verificadas antes da exclusao de CC
Local cQuery	:= ""
Local lTSREP	:= SuperGetMv( "MV_TSREP" , NIL , .F. )
Local lNgVal	:= Iif(GetMV("MV_NGMNTAT")== "N",.F.,.T.)
Local aIntegRet		:= {}
Private oObjREP	:= Nil

Default cAlias	:= "CTT"

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
	//³Integracao SIGAOMS X SIGAGFE	³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
//If FindFunction("MaEnvEAI") .AND. !lCTB030AUT
	oMdl := MaEnvEAI(,,5,"CTBA030",,,.F.,,,,"CTBA030" )
//EndIf
cCtt_Filial	:= xFilial( cAlias )

cCtt_Custo	:= ( cAlias )->CTT_CUSTO
nRecCTT		:= ( cAlias )->( Recno() )

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Carrega Variaveis de Memoria                                 ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

dbSelectArea(cAlias)
bCampo := {|nCPO| Field(nCPO) }
FOR i := 1 TO FCount()
	M->&(EVAL(bCampo,i)) := FieldGet(i)
NEXT i

Private aTELA[0][0],aGETS[0]
	 
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Envia para processamento dos Gets          ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
dbSelectArea(cAlias)
dbSetOrder(1)

If !SoftLock(cAlias)
	Return
EndIf	             

If lCtb030Vld
	If !ExecBlock("CTB030VLD", .F., .F.,nOpc)
		Return
    EndIf
EndIf         

If !lCTB030AUT		// SE FOR ROTINA AUTOMATICA

	aSize := MsAdvSize()
	aObjects := {}
	AAdd( aObjects, { 100, 100, .t., .t. } )	
	aInfo := { aSize[ 1 ], aSize[ 2 ], aSize[ 3 ], aSize[ 4 ], 3, 3 }                                        
	aPosObj := MsObjSize( aInfo, aObjects )
		
	DEFINE MSDIALOG oDlg TITLE cCadastro From aSize[7],0 to aSize[6],aSize[5] of oMainWnd PIXEL	
	aPos := {aSize[7],000,aSize[6],aSize[5]}
	ENChoice( cAlias, nReg, nOpc, ,"AC",OemToAnsi(STR0004), ,aPosObj[1])  //"Quanto … exclus„o?" 
	nOpca := 1
	ACTIVATE MSDIALOG oDlg ON INIT EnchoiceBar(oDlg,{|| nOpca := 2,oDlg:End()},;
											 {|| nOpca := 1,oDlg:End()})
Else
	nOpcA := 2
EndIf

If nOpcA == 2
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Verifica se o item x conta tem valores     ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	IF ExiSalCQ("CTT",/*cFiltro*/,/*dDtIni*/,/*dDtFin*/,/*cConta*/,cCtt_Custo,/*cItem*/,/*cClasse*/)
		lRet:=.F.
		Help(" ",1,"CCMOVIM")
	EndIF

	SB1->(dbSetOrder(1))

	If SB1->( dbSeek( xFilial( "SB1" ) + "MOD" + cCtt_Custo ))
		Help(" ",1,"CCMOVIM",,OemToAnsi(STR0010) + Alltrim( cCtt_Custo ) + OemToAnsi(STR0011)+CHR(10)+CHR(13)+OemToAnsi(STR0013)+CHR(10)+CHR(13)+OemToAnsi(STR0014),1,0) //"Existe o registro MOD"####" no Cadastro de Produtos (SB1) relacionado a Mao-De-Obra. Favor excluir, primeiramente, a Mao-De-Obra."
		lRet := .F.
	EndIf          

	// Checa indice para verificacao do SB1
	If lRet .And. lTemIndice
		lTemIndice:=.F.
		SIX->(dbSeek("SB1"))
		While ("SB1" == SIX->(INDICE)) .and. !SIX->(Eof())
			cSixChave := AllTrim(SIX->(CHAVE))
			If SIX->ORDEM == "8" .And. cSixChave == "B1_FILIAL+B1_CCCUSTO+B1_GCCUSTO"
				lTemIndice:=.T.
				Exit
			EndIf
			SIX->(dbSkip())
		End
		// Pesquisa dados
		If lTemIndice
			SB1->(dbSetOrder(8))
			If SB1->(dbSeek(xFilial("SB1") + cCtt_Custo))
				Help(" ",1,"CCMOVIM",,OemToAnsi(STR0010)+Alltrim( cCtt_Custo )+OemToAnsi(STR0011)+CHR(10)+CHR(13)+OemToAnsi(STR0013)+CHR(10)+CHR(13)+OemToAnsi(STR0014),1,0) //"Existe o registro MOD"####" no Cadastro de Produtos (SB1) relacionado a Mao-De-Obra. Favor excluir, primeiramente, a Mao-De-Obra."
				lRet := .F.
			EndIf
		EndIf
	EndIf
	If lRet
		lRet	:= CtbValDel("CTT",{{"SRA",2,cCtt_Custo}})		//Verifica se esta utilizando o c.c. no cad. funcionarios
		If !lRet
			HELP(" ",1,"EXISTECCFU")		
		EndIf
	EndIf
	If lRet
		lRet	:= CtbValDel("CTT",{{"SRD",2,cCtt_Custo}})		//Verifica se esta utilizando o c.c. no movimento anual
		If !lRet
			HELP(" ",1,"EXISTEREG")		
		EndIf
	EndIf

	If lRet
		lRet	:= CtbValDel("CTT",{{"SRC",2,cCtt_Custo}})		//Verifica se esta utilizando o c.c. no movimento MENSAL
		If !lRet
			HELP(" ",1,"EXISTEREG")		
		EndIf
	EndIf
	If lRet .And. lIntGPE
		lRet	:= QVALDELCC(cCtt_Custo) //Verifica as tabelas do Quality
	Endif

	If lRet
		lRet	:= CtbValDel("CTT",{{"SHB",2,cCtt_Custo}})		//Verifica se esta' utilizando o c.c. no Centro de Trabalho
		If !lRet
			HELP(" ",1,"EXISTECCHB")		
		EndIf
	EndIf
	If lRet
		lRet	:= CtbValDel("CTT",{{"SH1",2,cCtt_Custo}})		//Verifica se esta' utilizando o c.c. no cad. Recursos
		If !lRet
			HELP(" ",1,"EXISTECCH1")		
		EndIf
	EndIf 
	If lRet
		lRet	:= CtbValDel("CTT",{{"SQB",4,cCtt_Custo}})		//Verifica se esta utilizando o c.c. no cad. Departamentos
		If !lRet
			HELP(" ",1,"EXISTESQB")		
		EndIf
	EndIf

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Verifica se o C.C esta amarrado a Atendentes - Field Service   ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If lRet
		cQuery := "SELECT COUNT(*) RECAA1 FROM "
		cQuery += RetSqlName("AA1") + " AA1 "
		cQuery += " WHERE "                                    
		cQuery += "AA1_FILIAL = '"+xFilial("AA1")+"' AND "
		cQuery += "AA1_CC = '" + CTT->CTT_CUSTO + "' AND "
		cQuery += "AA1.D_E_L_E_T_ = ' ' "

		cQuery := ChangeQuery(cQuery)
	
		dBUseArea(.T.,"TOPCONN",TCGENQRY(,,cQuery),"TRBAA1",.F.,.T.)

		If TRBAA1->RECAA1 > 0
			lRet := .F.
			Help(" ",1,"EXISTEAA1")	
		Endif							
		
		dbCloseArea()
	Endif

	
	IF lRet
		dbSelectARea( "CTT" )
		dbSetOrder(1)

		IF CTT->CTT_CLASSE == "1"			// Sintetica
			dbSkip( )
			If !Eof() .And. CTT->CTT_FILIAL == cCtt_Filial .and. Alltrim(M->CTT_CUSTO) == Alltrim(CTT->CTT_CCSUP) 
			   	Help(" ",1,"CCSINT")
				lRet:=.F.
			EndIf
		EndIf

		dbSetOrder(1)
	EndIf

	// Fazendo a checagem da integridade referencial de um Centro de Custo
    If lRet .And. lNgVal 
	   	lRet := NGVALSX9("CTT",/*aNao*/,.T.,.T.)
    Endif


	// Função usada para validar se existe integração do Protheus com o RM Solum e
	// Para chamar a validação específica do RM Solum na deleção do Produto. (PMSXFUNB)
	
	dbSelectArea(cAlias)
	dbSetOrder(1)
	CTT->( dbSeek( cCtt_Filial + cCtt_Custo ))
	If lRet .AND. !PmsSlmPrd("CC")  	
		lRet := .F.
	Endif  
	       
	If lCt030ADel
		lRet := ExecBlock("CT030ADEL", .F., .F.,nOpc)
	EndIf

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
	//³Integracao protheus X tin	³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
	If FindFunction( "GETROTINTEG" ) .and. FindFunction("FwHasEAI") .and. FWHasEAI("CTBA030",.T.,,.T.)
		aIntegRet := FwIntegDef( 'CTBA030' )
		if VALTYPE(aIntegRet) = "A"
			lret := aIntegRet[1]
			if !lret
				help("",1,"CA030EAIRE")
			EndIf
		EndIf
	Endif
		
	IF lRet
		BEGIN TRANSACTION
			//Ponto de Entrada da Exclusao de Centro de Custo			
			If ExistBlock("CT030GRE")
				ExecBlock("CT030GRE",.F.,.F.)
			Endif				

			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³ Deleta o C.Custo do Cadastro               ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			dbSelectArea( cAlias ) //seleciona o alias novamente somente para garantia
			dbSetOrder(1) // seta a ordem novamente por garantia

			dbSeek( cCtt_Filial + cCtt_Custo ) // posiciona o registro no item
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³ Integra Protheus x LEGAL DESK - SIGAPFS             ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			//Grava na fila de sincronização se o parâmetro MV_JFSINC = '1' - SIGAPFS
			J170GRAVA("CTT", xFilial("CTT") + CTT->CTT_CUSTO, "5")

			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³ Integra Protheus x Centro de Custo - SIGAPFS         ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			// Exclusão dos registros da tabela OHE (Responsaveis x C. Custo)
			Iif(ExistFunc("J245Exclui"),J245Exclui(CTT->CTT_CUSTO),) //Proteção

			//--------------------
			// Integração Reserve
			//--------------------
			If SuperGetMV("MV_RESEXP",.F.,"0") <> "0" .And.;			//Verifica a forma de exportacao definida
				SubStr(SuperGetMV("MV_RESCAD",.F.,"111"),1,1) == "1"	//Verifica se a exportacao do centro de custo esta habilitada
				FINA655(nOpc)
			Endif

            // por garantia, percorre a tabela ctt para deletar o item correto da chave
			While ! Eof() .And. ( CTT->CTT_FILIAL == cCtt_Filial ) .And. ( CTT->CTT_CUSTO == cCtt_Custo )

			   If cInte=="1" .And. cSinc=="3"
					If PCOVLDSINC("CTT",CTT->CTT_CUSTO)
						PcoSincCO("CTT",3)
					Else
						lRet := .F.
						EXIT
					EndIf						
				EndIf
					
				// verifica se o item não está deletado, assim evita retrabalho
				If lRet .AND. !(cAlias)->( Deleted() )
					//MsGoto(nRecCTT) --> retirei o goto, mtas vezes o recno não eh mto confiavel para manipulação dos registros
					RecLock( cAlias, .F., .T. )
					dbDelete()
					MsUnlock()
			 	Endif
		
				CTT->(dbSkip())
			EndDo	           
			If lRet .AND. lIntGPE
				DbSelectArea("QAD")
				DbSetOrder(1)
				If DbSeek(xFilial("QAD")+cEmpAnt+cFilAnt+cCtt_Custo)
					Reclock("QAD",.F.)
					dbDelete()
					MsUnlock()
				Endif
			Endif

			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³ Grava Histórico de Alterações na tabela CW4.         ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			If lRet
				CTBGrvHist(xFilial("CTT"),"CTT"     ,cCtt_Custo,      ,ValType(CTT->CTT_CUSTO),"CTT_CUSTO",cCtt_Custo,""        ,nOpc)
				//		   cFilTabela	 ,cEntidade ,cCodigo       ,cGrupo,cTipoCampo             ,cCampo     ,cValorAnt   ,cValorNovo,nOpc)
			EndIf

			If lRet .AND. lIntTaf
				//Realiza a verificacao inicial de validacao
				lRet := If(Findfunction("Ctb030eSoc"),Ctb030eSoc(nOpc),lRet)
			Endif
			
			If !lRet
				DisarmTransaction()
			EndIf
			
		END TRANSACTION
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
		//³Integracao SIGAOMS X SIGAGFE	³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
		If lRet .AND. oMdl <> Nil
			//--Exclusão CENTRO DE CUSTO
			MaEnvEAI(,,5,"CTBA030",,,,.F.,oMdl,,"CTBA030" )
		EndIf	
	Endif
	
	//-- Integração Protheus x GFE (EXCLUSÂO)
	If lRet .AND. !IntProtGfe(5)
		lRet := .F.
	EndIf

	//-- Inicializa a integracao via WebServices TSA
	If lRet .AND. lTSREP
		oObjREP := PTSREPOBJ():New()	

		dbSelectArea(cAlias)
		MsGoTo( nReg )
		/*/
		ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		³ Executa o WebServices TSA - Centro de Custo                  ³
		ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ*/
		oObjREP:WSCostCenter( 3 )

	EndIF

EndIf	

MsGoTo( nReg )
RestArea(aSaveArea)

Return	

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Program   ³CtbCCLP   ³ Autor ³ Pilar S. Albaladejo   ³ Data ³ 21.02.01 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Validacao  para informacoes de Lucros e Perdas - SX3       ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ CtbCCLP(cCodigo)                                           ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³ .T.                                                        ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ GENERICO                                                   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ ExpC1 = Codigo do Centro de custo                          ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function CtbCCLP(cCodigo)

LOCAL nEndereco
LOCAL nEnd1
Local nEnd2

M->CTT_CCLP := cCodigo

If (nEndereco := Ascan(aGets,{ |x| Subs(x,9,7) == "CTT_CCLP" } )) > 0
	nEnd1 := Val(Subs(aGets[nEndereco],1,2))
	nEnd2 := Val(Subs(aGets[nEndereco],3,1))*2
	aTela[nEnd1][nEnd2] := M->CTT_CCLP
	lRefresh := .T.
EndIf

Return .T.

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³Ctb030NoRe³ Autor ³ Simone Mie Sato       ³ Data ³ 22/05/01 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³Verifica se o cod. red. CC foi preenchdio com Analiticas!   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³CTB030NoRe() 	                                              ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³.T./.F.      	                                              ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ Valida‡„o no SX3 do campo CTT_RES (Cod. Reduzido)          ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ Nenhum.                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
FUNCTION CTB030NoRe()

Local lRet := .T.

If M->CTT_CLASSE == "2"						// Analitica
	If Empty(M->CTT_RES)
		Help(" ",1,"CA030NORES")
		lRet:=.F.
	EndIf
Else
	IF !empty(M->CTT_RES)
		Help(" ",1,"CA030SINT")
		lRet:=.F.
	EndIf
Endif

Return lRet        

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Program   ³Ct030TudOk³ Autor ³ Lucimara Soares       ³ Data ³ 21.10.02 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Validacao da prévia existência do Centro de Custo          ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ Ct030TudOk()                                               ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³ .T.                                                        ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ GENERICO                                                   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ Nenhum                                                     ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function Ct030TudOk(nOpc)
Local nY := 0
Local bCampo := {|nCPO| Field(nCPO) }
Local lIntegraCC	:= Iif(M->CTT_CLASSE == "2", .T., .F. ) //Se for do tipo Analitico, ele integra com o TAF
Local lRet			:= .T. //Se não tiver eSocial, passa como .T. e ja grava CTT

DEFAULT nOpc := 3

	//---------------------------------------------
	//| Inicio | Realizando a integração com o TAF
	//|        | Se integrar com taf e CC analitico
	//-----------------------------------------------
	If lIntTaf .AND. lIntegraCC
		//Realiza a verificacao inicial de validacao
		lRet := If(Findfunction("Ctb030eSoc"),Ctb030eSoc(nOpc),lRet)
	Endif
	//---------------------------------------------
	//| Final  | Realizando a integração com o TAF
	//---------------------------------------------
	
	//Se não tiver o eSocial integrando, vem direto para cá.
	If lRet
		If nOpc == 3
			IF FkInUse() // se a integridade estiver ligada
				If M->CTT_CUSTO == M->CTT_CCLP
					// limpa o campo CCLP do centro de custo, afim de evitar erro de 
					M->CTT_CCLP := ''
				Endif
			Endif
		
			If  !ExistChav( "CTT", M-> CTT_CUSTO )
				Return .F.
			EndIf
		ElseIf nOpc == 4
			If M-> CTT_CLASSE != CTT->CTT_CLASSE  
				IF ExiSalCQ("CTT",/*cFiltro*/,/*dDtIni*/,/*dDtFin*/,/*cConta*/,M->CTT_CUSTO,/*cItem*/,/*cClasse*/)
					Help( " " , 1 , "NALTCLASSE" ,, "da classe do c.custo, pois existem movimentações para o mesmo." ,3,0)
					Return .F.
				EndIf
		    EndIf
		EndIf

		//Realiza a limpeza da variavel, para evitar a sua multiplacacao de campos internos
 		aCposHistor := {}
		
		For nY := 1 To FCount()
			AADD(aCposHistor,{CTT->(FieldName(nY)),CTT->&(EVAL(bCampo,nY)),""})
		Next nY	
		
		If lCTA030TOK
			If ExecBlock("CTA030TOK",.F.,.F.,nOpc)
				Return .F.
			Endif
		Endif
		
		//-- Integração Protheus x GFE (INCLUSAO,ALTERAÇÃO)
		If !IntProtGfe(nOpc)
			Return .F.
		EndIf
		
		If M->CTT_TIPO $ '12' .AND. (Empty(M->CTT_CEI) .Or. M->CTT_CEI =='00000000000000')
			MsgInfo(STR0042,STR0032) //STR0035 "O campo 'CNPJ/CEI Tomad' não poderá ficar vazio ou inválido, caso o campo 'T.Insc.Tomad' esteja preenchido" //STR0032 'Atenção'
			Return .F.
		EndIf
		If nModulo == 77 // Pré faturamento de serviços
			If ExistFunc("JCtb030Vld") // Proteção
				If nOpc == 3 .Or. nOpc == 4
					If !JCtb030Vld(nOpc) // Validações referente a campos utilizando no módulo SIGAPFS
						Return .F.
					EndIf
				EndIf
			EndIf
		EndIf
	EndIf
Return( lRet )	

/*/
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o	 ³Ctb030Sup ³ Autor ³ Simone Mie Sato       ³ Data ³ 02/10/03 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³Gera o c¢digo do centro de custo sup. a partir do cc. atual ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³Ctb030Sup(cCodigo)                                          ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³.T.                                                         ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso		 ³ Valida‡„o do SX3 do Campo CTT_CUSTO                        ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ ExpC1 = Codigo do Centro de Custo         				  ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function Ctb030Sup(cCodigo)
Local nEndereco
Local nEnd1,nEnd2
Local cMemMvs := Sv020Mem()		// Funcao que salva os mv_par??

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Chamada a funcao que gera o cta superior             ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

Pergunte("CTB030",.F.)

If mv_par01 != 3					// Automatico / Formula
	If mv_par01 == 1				// Automatico -> Formula Siga
		M->CTT_CCSUP	:= CtbCCSup(cCodigo)
	ElseIf mv_par01 == 2			// Formula -> do usuario
		If !Empty(mv_par02)
			M->CTT_CCSUP:= &(mv_par02)
		EndIf
	EndIf
EndIf

If (nEndereco := Ascan(aGets,{ |x| Subs(x,9,10) == "CTT_CCSUP" } )) > 0
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Exibe na tela a Conta Superior Gerada                ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	nEnd1	:= Val(Subs(aGets[nEndereco],1,2))
	nEnd2	:= Val(Subs(aGets[nEndereco],3,1))*2
	aTela[nEnd1][nEnd2] := M->ct1_ctasup
	lRefresh := .T.
EndIf

Sv020Mem(cMemMvs)

Return .T.
/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³ CTBA030LEGEN ³ Autor ³ Renato F. Campos  ³ Data ³ 29/01/07 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Exibe a legenda referente ao status                        ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ CTBA030LEGEN()                                             ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ CTBA030                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function Ctba030leg()

BrwLegenda(STR0015,STR0016,{	{ "BR_VERDE"    , STR0017},;	 //"Legenda"###"Centro de Custo"###"Sem Restrição"
								{ "BR_VERMELHO" , STR0018},;  //"Bloqueado"
								{ "BR_AMARELO"	, STR0019},;  //"Exercicio Não Inciado"
								{ "BR_CINZA"	, STR0020}})	 //"Exercicio Finalizado"
									

Return Nil


/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Programa  ³MenuDef   ³ Autor ³ Paulo Carnelossi      ³ Data ³07/03/07  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Utilizacao de menu Funcional                               ³±±     
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³Array com opcoes da rotina.                                 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³Parametros do array a Rotina:                               ³±±
±±³          ³1. Nome a aparecer no cabecalho                             ³±±
±±³          ³2. Nome da Rotina associada                                 ³±±
±±³          ³3. Reservado                                                ³±±
±±³          ³4. Tipo de Transa‡„o a ser efetuada:                        ³±±
±±³          ³		1 - Pesquisa e Posiciona em um Banco de Dados         ³±±
±±³          ³    2 - Simplesmente Mostra os Campos                       ³±±
±±³          ³    3 - Inclui registros no Bancos de Dados                 ³±±
±±³          ³    4 - Altera o registro corrente                          ³±±
±±³          ³    5 - Remove o registro corrente do Banco de Dados        ³±±
±±³          ³5. Nivel de acesso                                          ³±±
±±³          ³6. Habilita Menu Funcional                                  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³   DATA   ³ Programador   ³Manutencao efetuada                         ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³24/10/2013³ Pedro.Alencar ³ Adição da opção "Aprovador x C. Custo"     ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Static Function MenuDef()

Local aRotina := {  	{ OemToAnsi(STR0001),"AxPesqui"		,0 , 1},;		//"Pesquisar"
			  	 	  	{ OemToAnsi(STR0002),"VIEWDEF.CTBA030"	,0 , 2},;	//"Visualizar"
					  	{ OemToAnsi(STR0003),"Ctba030Inc"	,0 , 3},;		//"Incluir"
					  	{ OemToAnsi(STR0004),"Ctba030Alt"	,0 , 4},;  		//"Alterar"
					  	{ OemToAnsi(STR0005),"Ctba030Del"	,0 , 5},;		//"Excluir"
						{ OemToAnsi(STR0021),"Ctba030Imp"	,0 , 3},;		//"Importar"
						{ OemToAnsi(STR0022),"Ctba030Exp"	,0 , 4},;		//"Exportar"
					  	{ OemToAnsi(STR0015),"Ctba030leg"	,0 , 6},;	    //"Legenda"
						{ OemToAnsi(STR0031),"MSDOCUMENT"	,0 , 4},;       //"Conhecimento"
						{ OemToAnsi(STR0034),"VIEWDEF.CTBA031"	,0 , 4}; //STR0034:"Aprovador x C.Custo"
					}

If nModulo == 77 .And. ExistFunc("Jura245") // Proteção
	aAdd( aRotina, { OemToAnsi(STR0059),"Jura245(4)"  ,0 , 4} ) // "Responsaveis x C. Custo"
EndIf

Return(aRotina)


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³CTBA030ExpºAutor  ³Marcelo Akama       º Data ³  13/08/09   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Exporta centros de custo para arquivo .CSV                  º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ AP                                                         º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function CTBA030Exp()
Local aRet		:=	{}   

If !FindFunction("CTBExpCSV")
	Aviso(STR0022,STR0030,{STR0028}) //"Exportar"###"Funcao nao disponivel" //"Fechar"
	Return .F.
EndIf

SaveInter()

If ParamBox({	{6,STR0023,padr("",150),"",,"",90 ,.T.,STR0024,"",GETF_LOCALHARD+GETF_LOCALFLOPPY+GETF_NETWORKDRIVE}},; //"Estrut. de centros de custo"###"Arquivo .CSV |*.CSV"
		STR0025,@aRet)  //"Exportar para estrutura de centros de custo"

	oProcess:= MsNewProcess():New( {|lEnd| CTBExpCSV( lEnd, oProcess, aRet[1], { {"CTT",1} } )} )
	oProcess:Activate()

EndIf

RestInter()

Return .T.


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³CTBA030ImpºAutor  ³Marcelo Akama       º Data ³  13/08/09   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Importa centros de custo de arquivo .CSV                    º±±
±±º          ³                                                            º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function CTBA030Imp()
Local aRet	:= {}
Local aArea	:= CTT->(GetArea())
Local aCfg
Local cCampos
Local cFilCTT    := xFilial("CTT")
Local cQuery     := ""
Local cNextAlias := GetNextAlias()
Local nRet		   := 0  

If !FindFunction("CTBImpCSV")
	Aviso(STR0021,STR0030,{STR0028}) //"Importar"###"Funcao nao disponivel" //"Fechar"
	Return .F.
EndIf

cQuery := " SELECT COUNT(CTT_CUSTO) CONTFCTT "
cQuery += " FROM "+ RetSQLTab("CTT")
cQuery += " WHERE  "
cQuery += " CTT_FILIAL = '"+cFilCTT+"' AND "
cQuery += " CTT.D_E_L_E_T_ = ' ' "

dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cNextAlias,.T.,.T.) 
nRet := (cNextAlias)->CONTFCTT
(cNextAlias)->(DbCloseArea())

If nRet > 0 
	Aviso(STR0021,STR0026+CRLF+STR0027,{STR0028}) //"Importar"###"A importacao dos centros de custo so pode ser"##"feita com o plano de contas vazio" //"Fechar"
	RestArea(aArea)
	Return .F.
EndIf

SaveInter()

cCampos:="CTT_CUSTO,CTT_CLASSE,CTT_NORMAL,CTT_DESC01,CTT_DESC02,CTT_DESC03,CTT_DESC04,CTT_DESC05,CTT_BLOQ,CTT_DTBLIN,CTT_DTBLFI,CTT_DTEXIS,CTT_DTEXSF,CTT_CCLP,CTT_CCPON,CTT_BOOK,CTT_CCSUP,CTT_RES,CTT_CRGNV1,CTT_RGNV2,CTT_RGNV3,CTT_ITOBRG,CTT_CLOBRG,CTT_ACITEM,CTT_ACCLVL,CTT_CCVM,CTT_CCRED,CTT_CSINCO,CTT_OPERAC"

aCfg := { { "CTT", cCampos, {||MsExecAuto({|x,y| CTBA030(x,y)}, xAutoCab, 3)} } }

If ParamBox({	{6,STR0023,padr("",150),"",,"", 90 ,.T.,STR0024,"",GETF_LOCALHARD+GETF_LOCALFLOPPY+GETF_NETWORKDRIVE}},;	 //"Estrut. de centros de custo"###"Arquivo .CSV |*.CSV" 
		STR0029,@aRet)  //"Importar estrutura de centros de custo"

	oProcess:= MsNewProcess():New( {|lEnd| CTBImpCSV( lEnd, oProcess, aRet[1], aCfg )} )
	oProcess:Activate()
	lCTB030AUT := .F.

EndIf

RestInter()
RestArea(aArea)

Return .T.

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³Ctb030Cus ³ Autor ³ Microsiga             ³ Data ³ 26/09/11 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³Validacao do Centro de Custo Digitado -> SX3                ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ Ctb030Cus()                                                ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³                                                            ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function Ctb030Cus()

Local aSaveArea := GetArea()
Local lRet 		:= .T.

lRet := ExistChav("CTT",,1) .And. Ctb030Sup(M->CTT_CUSTO) .And. CtbCCLP(M->CTT_CUSTO) .And. FreeForUse("CTT",m->ctt_custo)

RestArea(aSaveArea)                                                         
  
// Verifica se o c.custo que esta sendo incluido consta no cache como c.custo invalido e atualiza o cache.
AtuVldEnt("CTT", M->CTT_CUSTO)

Return lRet
//-------------------------------------
/*	Modelo do Browser
@author  	Leandro Ferreira Paulino
@version 	P10 R1.4
@build		7.00.101202A
@since 		17/08/2011
@return 	oModel Objeto do Modelo	 */
//-------------------------------------
Static Function ModelDef()
Local oModel 	:= Nil
Local oStruCTT	:= Nil

oStruCTT := FwFormStruct(1,"CTT")        

// Tira validação da estrutura
oStruCTT:SetProperty( '*'         , MODEL_FIELD_VALID, { || .T. } )   
oStruCTT:SetProperty( '*'         , MODEL_FIELD_WHEN,  NIL )             

oModel:= MpFormModel():New("CTBA030",/*Pre-Validacao*/, /*Pos-Validacao*/, /*Commit*/,/*Cancel*/)
oModel:AddFields("CTBA030_CTT",Nil,oStruCTT,/*Pre-Validacao*/,/*Pos-Validacao*/,/*Carga*/)
oModel:SetDescription(STR0016) // Metodo XML
oModel:GetModel("CTBA030_CTT"):SetDescription(STR0016)
oModel:SetPrimaryKey({"CTT_CUSTO"})
	
Return ( oModel )

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³INTEGDEF  ºAutor  ³Wilson P de Godoi    º Data ³ 23/01/2012 º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Função para a interação com EAI                             º±±
±±º          ³envio e recebimento                                         º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ AP                                                         º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function IntegDef( cXml, nType, cTypeMsg,cAdpVersao )
Local aRet := {}    
	aRet:= CTBI030( cXml, nType, cTypeMsg,cAdpVersao )
Return aRet  

//-----------------------------------------------------
/*/	Valid após a confirmação de inclusão/alteração/exclusão
@author Felipe Machado de Oliveira
@version P11
@since 18/04/2013
/*/
//------------------------------------------------------
Static Function IntProtGfe(nOperation)
Local lRet := .T.
Local lIntGFE := SuperGetMv("MV_INTGFE",.F.,.F.)
Local cIntGFE2 := SuperGetMv("MV_INTGFE2",.F.,"2")

If lIntGFE == .T. .And. cIntGFE2 $ "1"
	If !InterGUH(nOperation)
		lRet := .F.
	EndIf	
EndIf
	
Return lRet
//-----------------------------------------------------
/*/	Integra a tabela CTT(Protheus) com GUH(SIGAGFE) a cada registro novo
@author Felipe Machado de Oliveira
@version P11
@since 18/04/2013
/*/
//------------------------------------------------------
Static Function InterGUH(nOperation)
	Local aAreaGUH := GUH->( GetArea() )
	Local lRet :=  .T.
	Local oModelGUH := FWLoadModel("GFEA089")
	Local nTpOpSetad
	Local cMsg
	
	dbSelectArea("GUH")
	GUH->( dbSetOrder(1) )
	GUH->( dbSeek( xFilial("GUH")+M->CTT_CUSTO ) )
	If !GUH->( Eof() ) .And. GUH->GUH_FILIAL == xFilial("GUH");
						 .And. AllTrim(GUH->GUH_CCUSTO) == AllTrim(M->CTT_CUSTO)

		oModelGUH:SetOperation( MODEL_OPERATION_UPDATE )
		nTpOpSetad := MODEL_OPERATION_UPDATE
	Else	
		oModelGUH:SetOperation( MODEL_OPERATION_INSERT )
		nTpOpSetad := MODEL_OPERATION_INSERT
	EndIf
	
	oModelGUH:Activate()
	
	If nOperation <> MODEL_OPERATION_DELETE
		oModelGUH:SetValue( 'GFEA089_GUH', 'GUH_DESC'  , M->CTT_DESC01 )
		
		If nTpOpSetad == MODEL_OPERATION_UPDATE
			If nOperation == MODEL_OPERATION_INSERT
				oModelGUH:LoadValue( 'GFEA089_GUH', 'GUH_SIT', "1" )
			EndIf
		Else
			oModelGUH:SetValue( 'GFEA089_GUH', 'GUH_FILIAL', M->CTT_FILIAL )
			oModelGUH:SetValue( 'GFEA089_GUH', 'GUH_CCUSTO', M->CTT_CUSTO )
		EndIf
	Else
		If nTpOpSetad <> MODEL_OPERATION_INSERT
			oModelGUH:LoadValue( "GFEA089_GUH", "GUH_SIT", "2" )
		Endif
	EndIf
	
	If nOperation != MODEL_OPERATION_DELETE .Or. nTpOpSetad != MODEL_OPERATION_INSERT
		If oModelGUH:VldData()
			oModelGUH:CommitData()
		Else
			lRet := .F.
			cMsg := oModelGUH:GetErrorMessage()[6]
		EndIf
	EndIf
	
	oModelGUH:Deactivate()
	
	If !lRet
		Help( ,, STR0032,,cMsg, 1, 0 ) //"Atenção"
	EndIf
	
	RestArea( aAreaGUH )
	
Return lRet                 

/*/{Protheus.doc}CTB030Clas
Função de validação do campo CTT_CLASSE.
@author William Matos Gundim Junior.
@since  31/07/2014
@version  P12.
/*/
Function CTB030Clas()  
Local lRet := .T.
Local cCodigo := CTT->CTT_CUSTO 
Local aArea 	:= GetArea()

If ALTERA

	dbSelectArea("CTT")
	dbSetOrder(1)
	CTT->(dbSeek(	xFilial("CTT") + cCodigo ))
	If M->CTT_CLASSE != CTT->CTT_CLASSE
		Help(" ",1,"NALTCLASSE")
		lRet :=  .F.
	Endif
	
Endif

RestArea(aArea)
Return lRet

Static Function ViewDef()

Local oModel   := FWLoadModel("CTBA030")
Local oStruCTT := FWFormStruct(2,"CTT")
Local oView

oView := FWFormView():New()

oView:SetModel(oModel)
oView:AddField("ViewField",oStruCTT,"CTBA030_CTT")

oView:CreateHorizontalBox("ViewCTT",100) 

oView:SetOwnerView("ViewField","ViewCTT")	 

oView:EnableTitleView("ViewField","Centro de Custo") 

Return(oView)