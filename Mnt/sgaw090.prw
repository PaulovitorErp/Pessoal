#INCLUDE "SGAW090.ch"
#INCLUDE "PROTHEUS.CH"
#INCLUDE "TOPCONN.CH"

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³SGAW090   ºAutor  ³Roger Rodrigues     º Data ³  21/03/11   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Workflow de aviso de Nao Conformidade Gerada pela FMR       º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³SGAW090/SGAA510                                             º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function SGAW090(cCodFMR)
Default cCodFMR := ""
Private cIniFile := GetAdv97()
Private cCodEmp  := ""
Private cCodFil  := ""

//Se via schedule
If !(Type("oMainWnd")=="O")
	//Define Empresa e Filial
	cCodEmp := GetPvProfString("ONSTART","Empresa","",cInIfile)
	cCodFil := GetPvProfString("ONSTART","Filial","",cInIfile)

	If cCodEmp == '-1' .Or. cCodFil == '-1'
		Return .f.
	Endif

	//Nao consome licensas
	RPCSetType(3)

	//Abre empresa/filial/modulo/arquivos
	RPCSetEnv(cCodEmp,cCodFil,"","","SGA","",{"TDC","TDD","TDE","TDB","TAF","SB1","QAA"})

	//Verifica se o UPDSGA21 foi aplicado
	If TDC->(FieldPos("TDC_CODFMR")) == 0
		Return .F.
	Endif

	SGAW090F()//Processa Workflow

Else
	//Verifica se o UPDSGA21 foi aplicado
	If !SGAUPDFMR()
		Return .F.
	Endif
	Processa({ || SGAW090F(cCodFMR)})//Processa Workflow
EndIf

Return .T.

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³SGAW090F  ºAutor  ³Roger Rodrigues     º Data ³  21/03/11   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Envia o WorkFlow                                            º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³SGAW090                                                     º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function SGAW090F(cCodFMR)
Local oProcess
Local cArquivo := "SGAW090.htm"//Nome do Arquivo HTML
Local cDir     := AllTrim(GetMV("MV_WFDIR"))//Diretorio Onde se Encontra o Workflow
Local aEmails  := {}, cEmail := ""//Variaveis de email
Local cCodProc := "WSGA090"//Codigo do processo
Local aArea    := GetArea()
Default cCodFMR := ""

//Coloco a barra no final do parametro do diretorio
If Substr(cDir,Len(cDir),1) != "\"
	cDir += "\"
Endif

//Verifico se existe o arquivo de workflow
If !File(cDir+cArquivo)
	MsgInfo(">>> "+STR0011+" "+cDir+cArquivo) //"Não foi encontrado o arquivo"
	Return .F.
Endif

// Arquivo html template utilizado para montagem da aprovação
cHtmlModelo := cDir+cArquivo

// Assunto da mensagem
cAssunto := STR0012 //"Aviso sobre Não Conformidades na Movimentação de Resíduos"

dbSelectArea("TDC")
dbSetOrder(1)
dbSeek(xFilial("TDC")+cCodFMR)
While !eof() .and. xFilial("TDC") == TDC->TDC_FILIAL
	aEmails := {}
	cEmails := ""
	If Empty(cCodFMR) .and. TDC->TDC_DATA <> dDataBase
		dbSelectArea("TAA")
		dbSkip()
		Loop
	Endif
	// Inicialize a classe TWFProcess e assinale a variável objeto oProcess:
	oProcess := TWFProcess():New(cCodProc, cAssunto)

	// Crie uma tarefa.
	oProcess:NewTask(cAssunto, cHtmlModelo)

	// Repasse o texto do assunto criado para a propriedade especifica do processo.
	oProcess:cSubject := dtoc(MsDate())+" - "+cAssunto

	// Utilizada a variável __CUSERID para obter o codigo do usuario protheus.
	oProcess:UserSiga := __CUSERID

	// Informe o nome da função de retorno a ser executada quando a mensagem de
	// respostas retornarem ao Workflow:
	oProcess:bReturn := ""

	aAdd(oProcess:oHtml:ValByName("IT1.CODFMR"),  TDC->TDC_CODFMR)
	aAdd(oProcess:oHtml:ValByName("IT2.CODRES"),  TDC->TDC_CODRES)
	aAdd(oProcess:oHtml:ValByName("IT2.DESRES"),  Upper(AllTrim(NGSEEK("SB1",TDC->TDC_CODRES,1,"SB1->B1_DESC"))))
	aAdd(oProcess:oHtml:ValByName("IT3.CODNIV"),  TDC->TDC_DEPTO)
	aAdd(oProcess:oHtml:ValByName("IT3.NOMNIV"),  Upper(AllTrim(NGSEEK("TAF",TDC->TDC_DEPTO,8,"TAF->TAF_NOMNIV"))))
	aAdd(oProcess:oHtml:ValByName("IT4.CODPNT"),  TDC->TDC_CODPNT)
	aAdd(oProcess:oHtml:ValByName("IT4.NOMPNT"),  Upper(AlLTrim(NGSEEK("TDB",TDC->TDC_DEPTO+TDC->TDC_CODPNT,1,"TDB->TDB_DESCRI"))))
	//Gera tabela de Acondicionamentos
	dbSelectArea("TDD")
	dbSetOrder(1)
	dbSeek(xFilial("TDD")+cCodFMR)
	While !eof() .and. xFilial("TDD")+cCodFMR == TDD->(TDD_FILIAL+TDD_CODFMR)
		If !Empty(TDD->TDD_COLET)
			aAdd(oProcess:oHtml:ValByName("IT5.COLET")	,  TDD->TDD_COLET)
			aAdd(oProcess:oHtml:ValByName("IT5.DESCOL")	,  Upper(NGSEEK("SB1",TDD->TDD_COLET,1,"Substr(SB1->B1_DESC,1,30)")))
			aAdd(oProcess:oHtml:ValByName("IT5.PESO")	,  TDD->TDD_PESO)
			If TDD->( ColumnPos( "TDD_UNIRES" ) ) > 0
				aAdd(oProcess:oHtml:ValByName("IT5.UNIRES")	,  TDD->TDD_UNIRES)
			Else
				aAdd(oProcess:oHtml:ValByName("IT5.UNIRES")	,  NGSEEK("SB1",TDC->TDC_CODRES,1,"SB1->B1_UM"))
			EndIf
		Endif
		dbSelectArea("TDD")
		dbSkip()
	End
	aAdd(oProcess:oHtml:ValByName("IT6.DESCNC"),  MSMM(TDC->TDC_MMNC))


	//Grava Emails dos responsaveis para envio
	dbSelectArea("TDE")
	dbSetOrder(1)
	dbSeek(xFilial("TDE")+TDC->TDC_CODFMR)
	While !eof() .and. xFilial("TDE")+TDC->TDC_CODFMR == TDE->TDE_FILIAL+TDE->TDE_CODFMR
		dbSelectArea("QAA")
		dbSetOrder(1)
		If dbSeek(xFilial("QAA")+TDE->TDE_MAT)
			If !Empty(QAA->QAA_EMAIL) .and. aScan(aEmails,{|x| Trim(Upper(x[1])) == Trim(Upper(QAA->QAA_EMAIL))}) == 0
				cEmails += Alltrim(QAA->QAA_EMAIL) + ";"
				aAdd(aEmails,{AllTrim(QAA->QAA_EMAIL)})
			Endif
		Endif
		dbSelectArea("TDE")
		dbSkip()
	End

	If !Empty(cEmails)
		// Grava os endereços eletrônicos dos destinatários
		oProcess:cTo := cEmails
		oProcess:Start()//Manda email
		MsgInfo(STR0014) //"Aviso sobre Não Conformidades na Movimentação de Resíduos enviado com sucesso!"
		oProcess:Finish()
	Endif

	If !Empty(cCodFMR)
		Exit
	Else
		dbSelectArea("TDC")
		dbSkip()
	Endif
End
RestArea(aArea)
Return .T.