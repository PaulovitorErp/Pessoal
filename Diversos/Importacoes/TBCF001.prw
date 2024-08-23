#include "protheus.ch"

/*-------------------------------------------------------------------
Programa: UFINE001
Autor: Maiki Perin
Data: 31/03/2020
Descrição: Importação de cadastros geral.
------------------------------------------------------------------*/

/***********************/
User Function TBCF001()
/***********************/

    Local oDlg 			:= NIL
    Local oPanelBkg		:= NIL
    Local oStepWiz 		:= NIL
    Local oNewPag		:= NIL

    Private cEntidade	:= ""
    Private cArquivo    := Space(300)
    Private cDirLog     := Space(300)
    Private nHdlLog		:= 0
    Private cNomeArq    := ""
    Private oObjProc	:= NIL
    Private nObjProc  	:= 0
    Private oSucesso	:= NIL
    Private nSucesso	:= 0 

    // Crio dialog que ira receber o Wizard
    DEFINE DIALOG oDlg TITLE "Assistente de Importação de Dados" PIXEL STYLE nOR(WS_VISIBLE,WS_POPUP)

    oDlg:nWidth     := 800
    oDlg:nHeight    := 620

    // Crio panel do Wizard
    oPanelBkg := TPanel():New(0,0,"",oDlg,,,,,,300,300)

    oPanelBkg:Align := CONTROL_ALIGN_ALLCLIENT

    // Instâncio o objeto do Wizard
    oStepWiz := FWWizardControl():New(oPanelBkg)
    oStepWiz:ActiveUISteps()
    
    ////////////////////////////////////////////////////
    /// Crio a página 1 do Wizard - Instruções Iniciais
    ////////////////////////////////////////////////////

    oNewPag := oStepWiz:AddStep("1")

    // Altero a descrição do step
    oNewPag:SetStepDescription("Instruções iniciais")

    // Defino o bloco de construção
    oNewPag:SetConstruction({|Panel| Pag1Inf(Panel)})

    // Defino o bloco ao clicar no botão Próximo
    oNewPag:SetNextAction({||.T.})

    // Defino o bloco ao clicar no botão Cancelar
    oNewPag:SetCancelAction({||oDlg:End()})
    
    //////////////////////////////////////////////////////
    /// Crio a página 2 do Wizard - Seleção de Parâmetros
    //////////////////////////////////////////////////////

    oNewPag := oStepWiz:AddStep("2",{|Panel| Pag2Inf(Panel)})

    // Altero a descrição do step
    oNewPag:SetStepDescription("Seleção de parâmetros")

    oNewPag:SetNextAction({||VldPag2()})

    // Defino o bloco ao clicar no botão Cancelar
    oNewPag:SetCancelAction({||oDlg:End()})

    // Defino o bloco ao clicar no botão Voltar
    oNewPag:SetPrevAction({||.T.})

    ////////////////////////////////////////////////////////////
    /// Crio a página 3 do Wizard - Processamento da Importação
    ////////////////////////////////////////////////////////////

    oNewPag := oStepWiz:AddStep("3",{|Panel| Pag3Inf(Panel)})

    // Altero a descrição do step
    oNewPag:SetStepDescription("Processamento da importação")

    oNewPag:SetNextAction({||oDlg:End(),.T.})

    // Defino o bloco ao clicar no botão Cancelar
    oNewPag:SetCancelAction({||.F.})

    oNewPag:SetCancelWhen({||.F.})

    oNewPag:SetPrevAction({||.F.})

    ////////////////////
    /// Fim das páginas
    ////////////////////

    oStepWiz:Activate()

    ACTIVATE DIALOG oDlg CENTER

    oStepWiz:Destroy()

Return()

/******************************/
Static Function Pag1Inf(oPanel)
/******************************/

    Local oSay1 	:= NIL
    Local oSay2 	:= NIL
    Local oFnt18	:= TFont():New("Arial",,18,,.T.,,,,,.F.,.F.)
    Local oFnt16    := TFont():New("Arial",,16,,.F.,,,,,.F.,.F.)

    // Crio a parte superior da tela do wizard
    PartSup(oPanel)

    @ 045 , 020 SAY oSay1 PROMPT "Bem Vindo..." SIZE 200, 010 Font oFnt18 OF oPanel COLORS 0, 16777215 PIXEL
    @ 065 , 020 SAY oSay2 PROMPT "Esta rotina tem como objetivo ajudá-lo na importação de dados.";
    SIZE 300, 300 Font oFnt16 OF oPanel COLORS 0, 16777215 PIXEL

Return()

/******************************/
Static Function Pag2Inf(oPanel)
/******************************/

    Local oFnt16		:= TFont():New("Arial",,16,,.F.,,,,,.F.,.F.)
    Local oFnt16N		:= TFont():New("Arial",,16,,.T.,,,,,.F.,.F.)
    Local oSay1         := NIL
    Local oSay2         := NIL
    Local oSay3         := NIL
    Local oSay4         := NIL
    Local aEntidades	:= u_fRetCads()
    Local oArquivo      := NIL
    Local oBtnArq       := NIL
    Local oLog          := NIL
    Local oBtnLog       := NIL

    // Crio a parte superior da tela do wizard 	
    PartSup(oPanel)

    @ 045 , 020 SAY oSay1 PROMPT "Dados da Importação:" SIZE 200, 010 Font oFnt16N OF oPanel COLORS 0, 16777215 PIXEL

    @ 060 , 020 SAY oSay2 PROMPT "Entidade" SIZE 050, 007 Font oFnt16 OF oPanel COLORS CLR_BLUE, 16777215 PIXEL
    @ 070 , 020 ComboBox cEntidade Items aEntidades Size 200,012 PIXEL Font oFnt16 OF oPanel

    @ 090 , 020 SAY oSay3 PROMPT "Arquivo" SIZE 050, 007 Font oFnt16 OF oPanel COLORS CLR_BLUE, 16777215 PIXEL
    @ 100 , 020 MSGET oArquivo VAR cArquivo SIZE 300,010 PIXEL Font oFnt16 OF oPanel PICTURE "@!" ReadOnly
    oBtnArq	:= TButton():New(099,330,"Localizar",oPanel,;
    {|| cArquivo := cGetFile('Arquivos do tipo csv|*.csv','Selecione o arquivo para importação',1,,.T.,GETF_LOCALHARD+GETF_NETWORKDRIVE,.T.,.T.)},;
    40,13,,,.F.,.T.,.F.,,.F.,,,.F.)

    @ 120 , 020 SAY oSay4 PROMPT "Log" SIZE 050, 007 Font oFnt16 OF oPanel COLORS CLR_BLUE, 16777215 PIXEL
    @ 130 , 020 MSGET oLog VAR cDirLog SIZE 300,010 PIXEL Font oFnt16 OF oPanel PICTURE "@!" ReadOnly
    oBtnLog	:= TButton():New(129,330,"Localizar",oPanel,;
    {|| cDirLog := cGetFile('','Selecione o diretório',1,'C:\',.T.,GETF_RETDIRECTORY+GETF_LOCALHARD+GETF_NETWORKDRIVE,.T.,.T.)},;
    40,13,,,.F.,.T.,.F.,,.F.,,,.F.)

Return()

/******************************/
Static Function Pag3Inf(oPanel)
/******************************/

    Local oSay1 		:= NIL
    Local oSay2 		:= NIL
    Local oFnt16		:= TFont():New("Arial",,16,,.F.,,,,,.F.,.F.)
    Local oFnt16N		:= TFont():New("Arial",,16,,.T.,,,,,.F.,.F.)

    // Crio a parte superior da tela do wizard
    PartSup(oPanel)

    // Realizo a importação
    FWMsgRun(,{|oSay| ProcImp(oSay)},'Aguarde','Processando importação de dados...')

    // Informações
    @ 045 , 020 SAY oSay1 PROMPT "Processo de importação finalizado." SIZE 200, 010 Font oFnt16N OF oPanel COLORS 0, 16777215 PIXEL
    @ 070 , 020 SAY oSay2 PROMPT "Resultado:" SIZE 200, 010 Font oFnt16N OF oPanel COLORS 0, 16777215 PIXEL
    @ 090 , 020 SAY oSay3 PROMPT "Objetos processados:" SIZE 080, 007 Font oFnt16 OF oPanel COLORS 0, 16777215 PIXEL
    @ 090 , 100 MSGET oObjProc VAR nObjProc SIZE 060,010 READONLY PIXEL  Font oFnt16 OF oPanel PICTURE "@E 9999999"
    @ 105 , 020 SAY oSay4 PROMPT "Objetos importados:" SIZE 080, 007 Font oFnt16 OF oPanel COLORS 0, 16777215 PIXEL
    @ 105 , 100 MSGET oSucesso VAR nSucesso SIZE 060,010 PIXEL  READONLY Font oFnt16 OF oPanel PICTURE "@E 9999999"

    @ 120 , 020 BUTTON oBtnImp PROMPT "Visualizar Log" SIZE 070, 015 OF oPanel PIXEL ACTION (ShellExecute("Open",cDirLog + cNomeArq + ".txt"," ","C:\",1))

Return()

/******************************/
Static Function PartSup(oPanel)
/******************************/

    Local oSay1 		:= NIL
    Local oSay2 		:= NIL
    Local oLgTotvs		:= NIL
    Local oGroup1		:= NIL
    Local oFnt18		:= TFont():New("Arial",,18,,.T.,,,,,.F.,.F.)
    Local oFnt16		:= TFont():New("Arial",,16,,.F.,,,,,.F.,.F.)
    Local nLargPnl	    := oPanel:nClientWidth / 2
                
    // Carrego a imagem do repositório 
    @ 003 , 003 REPOSITORY oLgTotvs SIZE 90, 90 OF oPanel PIXEL NOBORDER
    oLgTotvs:LoadBmp("APLOGO.JPG")
    @ 010 , 070 SAY oSay1 PROMPT "Atenção!" SIZE 060, 010 Font oFnt18 OF oPanel COLORS 0, 16777215 PIXEL
    @ 025 , 070 SAY oSay2 PROMPT "Siga atentamente os passos para realizar a importação de dados para o ambiente Gestão de Pessoal.";
    SIZE 300, 010 Font oFnt16 OF oPanel COLORS 0, 16777215 PIXEL
    @ 040 , 020 GROUP oGroup1 TO 042 , nLargPnl - 2 PROMPT "" OF oPanel COLOR 0, 16777215 PIXEL

Return()

/************************/
Static Function VldPag2()
/************************/

Local lRet := .T.

    If Empty(cEntidade) .Or. Empty(cArquivo) .Or. Empty(cDirLog)
        lRet := .F.
        Help(,,'Help',,"As informações: Entidade, Arquivo e Log, são obrigatórias.",1,0)	
    Endif

    If lRet

        cNomeArq := StrTran(DToC(dDataBase),"/","") + "_" + StrTran(Time(),":","") + "_" + StrTran(StrTran(SubStr(cEntidade,4)," ",""),"/","-")
        nHdlLog := MsfCreate(cDirLog + cNomeArq + ".txt",0) //nHdlLog := MsfCreate(strtran(cDirLog + cNomeArq,"/","-") + ".txt",0) 
	
        If nHdlLog < 0
            lRet := .F.
            Help(,,'Help',,"Não foi possivel criar o arquivo de log, favor selecionar diretório com direito de gravação.",1,0)	
        EndIf
        
    EndIf

Return(lRet)

/****************************/
Static Function ProcImp(oSay)
/****************************/

    Local cPulaLinha	:= Chr(13) + Chr(10)

    If nHdlLog > 0
    fWrite(nHdlLog,"#########  IMPORTACAO DE DADOS #############")
    fWrite(nHdlLog,cPulaLinha)
    fWrite(nHdlLog," >> Data inicio: " + DTOC(Date()))
    fWrite(nHdlLog,cPulaLinha)
    fWrite(nHdlLog," >> Hora inicio: " + Time())
    fWrite(nHdlLog,cPulaLinha) 
    fWrite(nHdlLog," >> Entidade: " + SubStr(cEntidade,4))
    fWrite(nHdlLog,cPulaLinha) 
    fWrite(nHdlLog,Replicate("-",44))
    fWrite(nHdlLog,cPulaLinha) 

        Do Case
       
        Case SubStr(cEntidade,1,2) == "01" // Importa cadastro de produtos - SB1.
            U_TBCF002(oSay,cArquivo,@nHdlLog,@nObjProc,@nSucesso)

        Case SubStr(cEntidade,1,2) == "02" // Importa estrutura de produtos - SG1.
            U_TBCF003(oSay,cArquivo,@nHdlLog,@nObjProc,@nSucesso)

        Case SubStr(cEntidade,1,2) == "03" // Importa cadastro de clientes - SA1.
            U_TBCF004(oSay,cArquivo,@nHdlLog,@nObjProc,@nSucesso)

        Case SubStr(cEntidade,1,2) == "04" // Importa cadastro de fornecedores - SA2.
            U_TBCF005(oSay,cArquivo,@nHdlLog,@nObjProc,@nSucesso)
        
        Case SubStr(cEntidade,1,2) == "05" // Importa contas a pagar - SE2.
            U_TBCF006(oSay,cArquivo,@nHdlLog,@nObjProc,@nSucesso)

        Case SubStr(cEntidade,1,2) == "06" // Importa contas a receber - SE1.
            U_TBCF007(oSay,cArquivo,@nHdlLog,@nObjProc,@nSucesso)

        Case SubStr(cEntidade,1,2) == "07" // Importa tabela de Cadastro de Bens (Ativo Fixo) SN1/SN3.
            U_TBCF008(oSay,cArquivo,@nHdlLog,@nObjProc,@nSucesso)

        Case SubStr(cEntidade,1,2) == "08" // Importa Saldos em Estoque SB9.
            U_TBCF009(oSay,cArquivo,@nHdlLog,@nObjProc,@nSucesso)
			
        Case SubStr(cEntidade,1,2) == "09" // Importa Saldos por Lote - SD5.
            U_TBCF010(oSay,cArquivo,@nHdlLog,@nObjProc,@nSucesso)
	
        Case SubStr(cEntidade,1,2) == "10" // Cadastro de Grupo de Produto.
            U_TBCF011(oSay,cArquivo,@nHdlLog,@nObjProc,@nSucesso)
			
        Case SubStr(cEntidade,1,2) == "11" // Importa cadastro de Natureza - SED.
            U_TBCF012(oSay,cArquivo,@nHdlLog,@nObjProc,@nSucesso)
			
        Case SubStr(cEntidade,1,2) == "12" // Importa cadastro de Condição de Pagamento. - SE4.
            U_TBCF013(oSay,cArquivo,@nHdlLog,@nObjProc,@nSucesso)
			
        Case SubStr(cEntidade,1,2) == "13" // Importa cadastro de Centro de Custo. - CTT.
            U_TBCF014(oSay,cArquivo,@nHdlLog,@nObjProc,@nSucesso)

        Case SubStr(cEntidade,1,2) == "14" // Importa cadastro de Orçamentos.
            U_ORC001(oSay,cArquivo,@nHdlLog,@nObjProc,@nSucesso)

        EndCase

    fWrite(nHdlLog,Replicate("-",44))
    fWrite(nHdlLog,cPulaLinha) 
    fWrite(nHdlLog," >> Data fim: " + DTOC(Date()))
    fWrite(nHdlLog,cPulaLinha)
    fWrite(nHdlLog," >> Hora fim: " + Time())
    EndIf

    If nHdlLog > 0
    // Fecho o arquivo de log
    fClose(nHdlLog)
    EndIf

Return()
