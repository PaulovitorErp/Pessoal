#Include 'Protheus.ch'
#Include 'SGAR495.CH'

#DEFINE _nVERSAO 02 //Versao do fonte
//---------------------------------------------------------------------
/*/{Protheus.doc} SGAR495()
Relatório de Rotas de Pontos de Coleta

@param oReport Objeto da classe TReport.

@author  Gabriel Augusto Werlich
@since   17/03/2014
@version P11
@return  Nil
/*/
//---------------------------------------------------------------------
Function SGAR495()

	// Guarda conteudo e declara variaveis padroes
	Local aNGBEGINPRM := NGBEGINPRM(_nVERSAO)
	Local oReport
		
	Private cPerg := 'SGAR495'
	
	If !NGCADICBASE("TH1_CODROT","A","TH1",.F.)
		If !NGINCOMPDIC("UPDSGA38","TPNBEI")
			Return .F.
		Endif
	EndIf
	
	// Preparação do Relatorio(Inicialização)
	oReport := ReportDef()
	oReport:SetPortrait()
	oReport:PrintDialog()
	   
	// Devolve variaveis armazenadas (NGRIGHTCLICK)
	NGRETURNPRM(aNGBEGINPRM)
	
Return

//---------------------------------------------------------------------
/*/{Protheus.doc} ReportDef()
Construção do Relatório.

@param oReport Objeto da classe TReport.

@author  Gabriel Augusto Werlich
@since   17/03/2014
@version P11
@return  .T.
/*/
//---------------------------------------------------------------------

Static Function ReportDef()

	Local oReport
	Local oSection1
	Local oSection2
	Local oSection3
		
	DbSelectArea("TH1")
		
	//Objeto para construção do relatorio
	oReport  := TReport():New("SGAR495",STR0026,cPerg, {|oReport| ReportPrint(oReport) })
		
	// Atribui os valores das perguntas às variáveis MV_PAR
	Pergunte(oReport:uParam,.F.)
		
	// Sera utilizada para apresentação do conteudo
	oSection1 := TRSection():New(oReport,STR0001,{'TH1'}) //"Rota de Coleta"
		
	// Celulas utilizadas pelos campos para apresentação do relatorio
	TRCell():New(oSection1 , 'TH1_CODROT'	, "TH1" , STR0002,,TAMSX3("TH1_CODROT")[1]+7) // 'Rota'
	TRCell():New(oSection1 , 'TH1_DESROT'	, "TH1" , STR0011,,TAMSX3("TH1_DESROT")[1]+5) // 'Descrição'
	TRCell():New(oSection1 , 'TH1_RESPON'	, "TH1" , STR0004,,TAMSX3("TH1_RESPON")[1]+5) // 'Elaborador'
	TRCell():New(oSection1 , 'QAA_NOME'	, "QAA" , STR0011,,TAMSX3("QAA_NOME")[1]+4,,,,,,,5)  // 'Descrição'
	TRCell():New(oSection1 , 'TH1_NTEMPO'	, "TH1" , STR0006,,TAMSX3("TH1_NTEMPO")[1],,,,,,,5) // 'Tempo'
	TRCell():New(oSection1 , 'TH1_PRDCD'	, "TH1" , STR0005,,TAMSX3("TH1_PRDCD")[1],,,,,,,5) // 'Period.'
	TRCell():New(oSection1 , 'TH1_DATELA'	, "TH1" , STR0008,,TAMSX3("TH1_DATELA")[1])	// 'Dt. Elab.'
	
	TRPosition():New(oSection1,"QAA",1,{|| xFilial("QAA")+TH1->TH1_RESPON})
	
	oSection2 := TRSection():New(oReport,STR0035,{'TH2'}) //'Pontos de coleta da rota'
	TRCell():New(oSection2 , 'TH1_OBSERV'	, "TH1" , STR0007,,TAMSX3("TH1_OBSERV")[1]+104) 	// 'Observação'
	
	
	oSection3 := TRSection():New(oReport,STR0001,{'TH2'}) //Definição de Rota para Pontos de Coleta
	
	TRCell():New(oSection3 , 'TH2_CODORD'	, "TH2" , STR0025,,TAMSX3("TH2_CODORD")[1]+15) //'Ordem'
	TRCell():New(oSection3 , 'TH2_CODLOC'	, "TH2" , STR0009,,TAMSX3("TH2_CODLOC")[1]+15) //'Localização'
	TRCell():New(oSection3 , 'TAF_NOMNIV'	, "TAF" , STR0011,,TAMSX3("TAF_NOMNIV")[1]+15) //'Descrição'
	TRCell():New(oSection3 , 'TH2_CODPTO'	, "TH2" , STR0010,,TAMSX3("TH2_CODPTO")[1]+15) //'Ponto Coleta'
	TRCell():New(oSection3 , 'TDB_DESCRI'	, "TDB" , STR0011,,TAMSX3("TDB_DESCRI")[1]+15) //'Descrição'
	
	TRPosition():New(oSection3,"TAF",8,{|| xFilial("TDB")+TH2->TH2_CODLOC})
	TRPosition():New(oSection3,"TDB",1,{|| xFilial("TDB")+TH2->TH2_CODLOC+TH2->TH2_CODPTO})

Return oReport

//---------------------------------------------------------------------
/*/{Protheus.doc} ReportPrint()
Define conteudo que será impresso no relatorio.   

@param oReport Objeto da classe TReport.

@author  Gabriel Augusto Werlich
@since   17/03/2014
@version P11
@return  .T.
/*/
//---------------------------------------------------------------------
Static Function ReportPrint(oReport)

	Local oSection1
	Local oSection2
	Local oSection3
	
	oSection1 := oReport:Section(1) // Seleciona a primeira seção
	oSection2 := oReport:Section(2) // Seleciona a primeira seção
	oSection3 := oReport:Section(3) // Seleciona a segunda seção
		
	DbSelectArea("TH2")
	DbSetOrder(1)
	
	DbSelectArea("TDB")
	DbSetOrder(1)
	
	DbSelectArea("QAA")
	DbSetOrder(1)
	
	oReport:SetMeter(RecCount())
	
	// Percorre Alias, imprimindo seu conteudos
	dbSelectArea("TH1")
	dbSetOrder(1)
	TH1->(dbSeek(xFilial("TH1") + AllTrim(MV_PAR05), .T.))
	While TH1->(!Eof()) .And. !oReport:Cancel() .and. (TH1->TH1_CODROT >= MV_PAR01).and.(TH1->TH1_CODROT <= MV_PAR02)
	
		If TH1->TH1_DATELA <= MV_PAR03 .Or. TH1->TH1_DATELA > MV_PAR04
			DbSelectArea("TH1")
			TH1->(DbSkip())				
			Loop	
		EndIf	

		If TH1->TH1_RESPON < MV_PAR05 .Or. TH1->TH1_RESPON > MV_PAR06
			DbSelectArea("TH1")
			TH1->(DbSkip())				
			Loop	
		EndIf	

		oSection1:Init()
		oSection2:Init()
		oSection3:Init()
		
		oSection1:PrintLine() // Impressao de conteudo
		If MV_PAR07 == 1
			oSection2:PrintLine()	
			oSection2:Finish()
		EndIf
		oSection1:Finish()
		
		dbSelectArea("TH2")
		dbSetOrder(1)
		dbSeek(xFilial("TH2")+TH1->TH1_CODROT)
		While TH2->(!Eof()) .and. TH2->TH2_CODROT == TH1->TH1_CODROT
			oSection3:PrintLine() // Impressao de conteudo	
			dbSelectArea("TH2")
			dbSkip()
		End
		oReport:SkipLine()
		oReport:SkipLine()
		oReport:SkipLine()	
			
		oSection3:Finish()
		dbSelectArea("TH1")
		dbSkip()
		
	End

Return .T.

//---------------------------------------------------------------------
/*/{Protheus.doc} SGAR495DAT
Valida os perguntas.

@param nParam	Define tipo a ser validado.
				Opções : 	1 - De Data?
							2 - Até Data?

@author  Gabriel Augusto Werlich
@since   17/03/2014
@version P11
@return  lRet
/*/
//-----------------------------------------------------------------------
Function SGAR495DAT(nParam)
		
	Local lRet := .F.
	
	If nParam == 1
		If Empty(mv_par04) .OR. VALDATA(mv_par03,mv_par04,'DATAMAIOR')
			lRet:= .T.
		EndIf
	ElseIf nParam == 2
		If VALDATA(mv_par03, mv_par04, 'DATAMENOR')
			lRet:= .T.
		EndIf
	EndIf
	
Return lRet

//---------------------------------------------------------------------
/*/{Protheus.doc} SGAR495RES()
Valida os perguntas.

@param nTipo	Define tipo a ser validado.
				Opções : 	1 - De Elaborador?
							2 - Até Elaborador?
  

@author  Gabriel Augusto Werlich
@since   17/03/2014
@version P11
@return  Boolean
/*/
//-----------------------------------------------------------------------
Function SGAR495RES(nTipo)	

If nTipo == 1

	If !Empty(MV_PAR05)
		If !ExistCPO("QAA",MV_PAR05)
			Return .F.
		ElseIf !Empty(MV_PAR06) .And. MV_PAR05 > MV_PAR06	// Se a pergunta De Responsável? for maior que a Até Responsável?
			HELP(" ",1,"DEATEINVAL") 						   // apresenta mensagem.
			Return .F.
		Endif
	Endif

ElseIf nTipo == 2
	
	If MV_PAR06 <> Replicate("Z",Len(QAA->QAA_MAT))
	
		If Empty(MV_PAR05) .And. Empty(MV_PAR06)
			Return .T.	
		ElseIf MV_PAR06 < MV_PAR05	// Se a pergunta Até Responsável? for menor que a De Responsável?
			HELP(" ",1,"DEATEINVAL") // apresenta mensagem.
			Return .F.
		ElseIf !Empty(MV_PAR05) .And. Empty(MV_PAR06)
			HELP(" ",1,"DEATEINVAL")
			Return .F.
		ElseIf !ExistCPO("QAA",MV_PAR06)
			Return .F.
		Endif
		
	Endif
EndIf

Return

//---------------------------------------------------------------------
/*/{Protheus.doc} SGAR495ROT()
Valida os perguntas.

@param nTipo	Define tipo a ser validado.
				Opções : 	1 - De Elaborador?
							2 - Até Elaborador?
  

@author  Gabriel Augusto Werlich
@since   17/03/2014
@version P11
@return  Boolean
/*/
//-----------------------------------------------------------------------
Function SGAR495ROT(nTipo)	

If nTipo == 1

	If !Empty(MV_PAR01)
		If !ExistCPO("TH1",MV_PAR01)
			Return .F.
		ElseIf !Empty(MV_PAR02) .And. MV_PAR01 > MV_PAR02	// Se a pergunta De Responsável? for maior que a Até Responsável?
			HELP(" ",1,"DEATEINVAL") 						   // apresenta mensagem.
			Return .F.
		Endif
	Endif

ElseIf nTipo == 2
	
	If MV_PAR02 <> Replicate("Z",Len(TH1->TH1_CODROT))
	
		If Empty(MV_PAR01) .And. Empty(MV_PAR02)
			Return .T.	
		ElseIf MV_PAR02 < MV_PAR01	// Se a pergunta Até Responsável? for menor que a De Responsável?
			HELP(" ",1,"DEATEINVAL") // apresenta mensagem.
			Return .F.
		ElseIf !Empty(MV_PAR01) .And. Empty(MV_PAR02)
			HELP(" ",1,"DEATEINVAL")
			Return .F.
		ElseIf !ExistCPO("TH1",MV_PAR02)
			Return .F.
		Endif
		
	Endif
EndIf

Return