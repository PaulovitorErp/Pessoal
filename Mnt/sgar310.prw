#Include 'Protheus.ch'
#Include 'SGAR310.CH'

#DEFINE _nVERSAO 02 //Versao do fonte

//------------------------------------------------------------------------------------------------------
/* {Protheus.doc} SGAR310
Relatório de Critérios de Controle

@author Juliani Schlickmann Damasceno
@since 20/02/2014
@version 1.0
*/
//----------------------------------------------------------------------------------------------------- 
Function SGAR310()

// Guarda conteudo e declara variaveis padroes
Local aNGBEGINPRM := NGBEGINPRM(_nVERSAO)
Local oReport
	
Private cPerg := 'SGAR310'

// Preparação do Relatorio(Inicialização)
oReport := ReportDef()
oReport:SetPortrait()
oReport:PrintDialog()
   
// Devolve variaveis armazenadas (NGRIGHTCLICK)
NGRETURNPRM(aNGBEGINPRM)
	
Return

//-----------------------------------------------------------------------
/*{Protheus.doc} ReportDef
Construção do Relatório.

@author Juliani Schlickmann Damasceno
@since 20/02/2014
@version 1.0
*/
//-----------------------------------------------------------------------
Static Function ReportDef()
Local oReport
Local oSection1
Local oSection2
	
DbSelectArea("TAX")
DbSelectArea("TAZ")

// Objeto para construção do relatorio
oReport  := TReport():New('SGAR310',STR0001,cPerg, {|oReport| ReportPrint(oReport) })
	
// Atribui os valores das perguntas às variáveis MV_PAR
Pergunte(oReport:uParam,.F.)
	
// Sera utilizada para apresentação do conteudo
oSection1 := TRSection():New(oReport,STR0002,{'TAX'}) // 'Resíduo' 
	
// Celulas utilizadas pelos campos para apresentação do relatorio
TRCell():New(oSection1 , 'TAX_CODRES'	, "TAX" , STR0002,,TAMSX3("TAX_CODRES")[1]+5) // 'Resíduo' 
TRCell():New(oSection1 , 'B1_DESC'		, "SB1" , STR0003,,TAMSX3("B1_DESC")[1]+5) // 'Descrição'

//Sessão para impressão dos Critérios.
oSection2 := TRSection():New(oReport,STR0004,{'TAZ'}) // 'Critérios'

TRCell():New(oSection2 , 'TAZ_CODCRI'	, "TAZ"		  , STR0005,,TAMSX3("TAZ_CODCRI")[1]+5) 		// 'Critério'
TRCell():New(oSection2 , 'TAZ_DESCRI' 	, "TAZ" 	  , STR0006,,TAMSX3("TAZ_DESCRI")[1]) 			// 'Desc. Critério'
TRCell():New(oSection2 , 'TAZ_LIMMIN'	, "TAZ" 	  , STR0007,,TAMSX3("TAZ_LIMMIN")[1],,,,,,,5) // 'Lim. Mín.'
TRCell():New(oSection2 , 'TAZ_LIMMAX'	, "TAZ" 	  , STR0008,,TAMSX3("TAZ_LIMMAX")[1],,,,,,,5) // 'Lim. Máx.'
TRCell():New(oSection2 , 'TAZ_UNIMED'  , "TAZ" 	  , STR0009,,TAMSX3("TAZ_UNIMED")[1],,,,,,,5) // 'Unid. Med.'
TRCell():New(oSection2 , 'TAZ_RESPON'	, "TAZ" 	  , STR0010,,TAMSX3("TAZ_RESPON")[1]+5) 		// 'Responsável'
TRCell():New(oSection2 , 'QAA_NOME'		, "QAA" 	  , STR0011,,TAMSX3("QAA_NOME")[1]+5)		    // 'Nome Resp.'

Return oReport

//-----------------------------------------------------------------------
/*{Protheus.doc} ReportPrint
Define conteudo que será impresso no relatorio.   

@param oReport Objeto da classe TReport.

@author Juliani Schlickmann Damasceno
@since 20/02/2014
@version 1.0
*/
//-----------------------------------------------------------------------
Static Function ReportPrint(oReport)
Local oSection1
Local oSection2
Local lPrintCrit

oSection1 := oReport:Section(1) // Seleciona a primeira seção
oSection2 := oReport:Section(2) // Seleciona a segunda seção
	
dbSelectArea("TAX")
dbSetOrder(1)

DbSelectArea("SB1")
DbSetOrder(1)

DbSelectArea("TAZ")
DbSetOrder(1)

DbSelectArea("QAA")
DbSetOrder(1)

TAX->(dbSeek(xFilial("TAX") + MV_PAR01, .T.))

oReport:SetMeter(RecCount()) // Atribui valores para o objeto Meter (Barra de Progresso)

// Percorre Alias, imprimindo seu conteudo
While TAX->(!Eof()) .And. !oReport:Cancel() .And. (TAX->TAX_CODRES <= MV_PAR02)
	
	oSection1:Init()
	oSection2:Init()
	
	
	SB1->(DbSeek(xFilial("SB1")+ TAX->TAX_CODRES))
	
	If TAZ->(DbSeek(xFilial("TAZ")+ TAX->TAX_CODRES))
		
		lPrintCrit := .T.
					
		While TAZ->(!Eof()) .And. (TAZ->TAZ_CODRES == TAX->TAX_CODRES)
			
			If TAZ->TAZ_RESPON < MV_PAR03 .Or. TAZ->TAZ_RESPON > MV_PAR04
				DbSelectArea("TAZ")
				TAZ->(DbSkip())				
				Loop			
			EndIf
			
			QAA->(DbSeek(xFilial("QAA")+ TAZ->TAZ_RESPON))
		
			If lPrintCrit
				oSection1:PrintLine() // Impressao de conteudo
				lPrintCrit := .F.				
			EndIf
			
			oSection2:PrintLine() // Impressao de conteudo
						
			DbSelectArea("TAZ")
			TAZ->(DbSkip())
		End

	Else
		If MV_PAR05 == 1
			oSection1:PrintLine() 
			oReport:SkipLine()
			oReport:Say(oReport:Row(), oReport:Col(), STR0022, , oSection1:nCLRBACK, oSection1:nCLRFORE) //"Não possui Critérios de Controle."	
			oReport:SkipLine()
		EndIf
	EndIf
	
	oReport:IncMeter()   // Incremento na barra de progresso
	
	oSection2:Finish()
	oSection1:Finish()
	
	dbSelectArea("TAX")
	dbSkip()
		
End

Return .T.
//-----------------------------------------------------------------------
/*{Protheus.doc} AlimTRB
Valida os perguntas.

@param nTipo	Define tipo a ser validado.
				Opções : 	1 - De Resíduo?
							2 - Até Resíduo?
							3 - De Responsável?
							4 - Até Responsável?
							5 - Resíduos sem Critérios?   

@author Juliani Schlickmann Damasceno
@since 20/02/2014
@version 1.0
*/
//-----------------------------------------------------------------------
Function Sg310Vld(nTipo)

If nTipo == 1

	If !Empty(MV_PAR01)
		If !ExistCPO("TAX",MV_PAR01)
			Return .F.
		ElseIf !Empty(MV_PAR02) .And. MV_PAR01 > MV_PAR02  // Se a pergunta De Resíduo? for maior que a Até Resíduo?
			HELP(" ",1,"DEATEINVAL") 						 //apresenta mensagem.
			Return .F.
		Endif
	Endif
	
ElseIf nTipo == 2

	If MV_PAR02 <> Replicate("Z",Len(TAX->TAX_CODRES))
		If !ExistCPO("TAX",MV_PAR02)
			Return .F.
		ElseIf MV_PAR02 < MV_PAR01	// Se a pergunta Até Resíduo? for menor que a De Resíduo?
			HELP(" ",1,"DEATEINVAL") //apresenta mensagem.
			Return .F.
		Endif
	Endif
	
ElseIf nTipo == 3

	If !Empty(MV_PAR03)
		If !ExistCPO("QAA",MV_PAR03)
			Return .F.
		ElseIf !Empty(MV_PAR04) .And. MV_PAR03 > MV_PAR04	// Se a pergunta De Responsável? for maior que a Até Responsável?
			HELP(" ",1,"DEATEINVAL") 						//apresenta mensagem.
			Return .F.
		Endif
	Endif

ElseIf nTipo == 4
	If MV_PAR04 <> Replicate("Z",Len(QAA->QAA_MAT))
		If !ExistCPO("QAA",MV_PAR04)
			Return .F.
		ElseIf MV_PAR04 < MV_PAR03	// Se a pergunta Até Responsável? for menor que a De Responsável?
			HELP(" ",1,"DEATEINVAL") // apresenta mensagem.
			Return .F.
		Endif
	Endif
EndIf

Return .T.