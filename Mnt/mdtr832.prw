#Include "mdtr832.ch"
#Include "Protheus.ch"

//---------------------------------------------------------------------
/*/{Protheus.doc} MDTR832
Relatório da CAT do eSocial - CAT Web

@sample	MDTR832()

@author Luis Fellipy Bett
@since  18/11/2021

@return Nil, Nulo
/*/
//---------------------------------------------------------------------
Function MDTR832()

    //Salva a área
	Local aArea := GetArea()

	//Variáveis de parâmetros
    Local leSocial := IIf( FindFunction( "MDTVldEsoc" ), MDTVldEsoc(), .F. )

	//Variável do relatório
	Local oReport
	    
    //Armazena variaveis p/ devolucao (NGRIGHTCLICK)
    Local aNGBEGINPRM := NGBEGINPRM()

	//Variável de controle de chamada
	Private lMDTA640 := IsInCallStack( "MDTA640" )

    //Caso o usuário tenha acesso à rotina
	If MDTRESTRI( cPrograma ) .And. AMiIn( 35 )

		If leSocial
			//Interface de impressão
			oReport := ReportDef()
			oReport:SetPortrait()
			oReport:PrintDialog()
		Else
			Help( ' ', 1, STR0001, , STR0002, 2, 0, , , , , , { STR0053 } ) //"Esta opção só está disponível ao haver integração com o eSocial" ## "Favor habilitar o parâmetro MV_NG2ESOC"
		EndIf

    EndIf

    //Retorna a área
    RestArea( aArea )

    //Devolve variaveis armazenadas (NGRIGHTCLICK)
    NGRETURNPRM( aNGBEGINPRM )

Return .T.

//---------------------------------------------------------------------
/*/{Protheus.doc} ReportDef
Define as seções a serem impressas no relatório

@sample	ReportDef()

@author	Luis Fellipy Bett
@since	19/11/2020

@return oReport, Objeto, Objeto do relatório
/*/
//---------------------------------------------------------------------
Static Function ReportDef()

	Local oReport //Objeto do relatório
	Local oSection1 //Controle de quebra de página
	Local oSection2 //Dados de Identificação
	Local oSection3 //Emitente - Empregador
	Local oSection4 //Emitente - Acidentado
	Local oSection5 //Emitente - Acidente ou Doença I
	Local oSection6 //Emitente - Acidente ou Doença II
	Local oSection7 //Emitente - Acidente ou Doença III
	Local oSection8 //Emitente - Acidente ou Doença IV
	Local oSection9 //Emitente - Acidente ou Doença V
	Local oSection10 //Emitente - Acidente ou Doença VI
	Local oSection11 //Emitente - Acidente ou Doença VII
	Local oSection12 //Emitente - Acidente ou Doença VIII
	Local oSection13 //Emitente - Acidente ou Doença IX
	Local oSection14 //Emitente - Acidente ou Doença X
	Local oSection15 //Informações do Atestado Médico - Atendimento
	Local oSection16 //Informações do Atestado Médico - Lesão
	Local oSection17 //Informações do Atestado Médico - Diagnóstico I
	Local oSection18 //Informações do Atestado Médico - Diagnóstico II
	Local oSection19 //Informações do Atestado Médico - Diagnóstico III

	//Criação do relatório
	oReport := TReport():New( "MDTR832", OemToAnsi( STR0003 ), IIf( lMDTA640, "", "MDT832" ), { | oReport | ReportPrint( oReport ) }, STR0004 ) //"Comunicação de Acidente de Trabalho - CAT"##"Relatório da CAT eSocial"

	//Pergunte contendo as perguntas do terceiro parâmetro
	Pergunte( oReport:uParam, .F. )

	//Seção 1 - Seção de Controle de quebra de página
	oSection1 := TRSection():New( oReport, "Controle de quebra de página" )

	//Seção 2 - Dados de Identificação
	oSection2 := TRSection():New( oReport, "Dados de Identificação", "TNC" )
	TRCell():New( oSection2, "TNC_EMITEN", "TNC", STR0005, "@!", 14 ) //"1- Emitente"
	TRCell():New( oSection2, "TNC_TIPCAT", "TNC", STR0006, "@!", 25, , { || fGetTipCAT( TNC->TNC_TIPCAT ) } ) //"2- Tipo de CAT"
	TRCell():New( oSection2, "INICIAT", "", STR0007, "@!", 30, , { || STR0054 } ) //"3- Iniciativa da CAT" ## "Iniciativa do empregador"
	TRCell():New( oSection2, "FONTE", "", STR0008, "@!", 28, , { || STR0055 } ) //"4- Fonte do Cadastramento" ## "eSocial"
	If TNC->( ColumnPos( "TNC_RECIBO" ) ) > 0 //Caso o campo existir no dic
		TRCell():New( oSection2, "TNC_RECIBO", "TNC", STR0009, "@!", 33 ) //"5- Número da CAT"
	Else
		TRCell():New( oSection2, "RECIBO", "", STR0009, "@!", 33, , { || "" } ) //"5- Número da CAT"
	EndIf
	If TNC->( ColumnPos( "TNC_RECORI" ) ) > 0 //Caso o campo existir no dic
		TRCell():New( oSection2, "TNC_RECORI", "TNC", STR0010, "@!", 40 ) //"6- Número do recibo da CAT de origem"
	Else
		TRCell():New( oSection2, "RECORI", "", STR0010, "@!", 40, , { || "" } ) //"6- Número do recibo da CAT de origem"
	EndIf

	//Seção 3 - Emitente - Empregador
	oSection3 := TRSection():New( oReport, "Emitente - Empregador" )
	TRCell():New( oSection3, "RAZAO", "", STR0011, "@!", 45, , { || SM0->M0_NOME } ) //"7- Razão Social / Nome"
	TRCell():New( oSection3, "TIPO", "", STR0013, "@!", 15, , { || fGetTipIns( SM0->M0_TPINSC ) } ) //"8- Tipo"
	TRCell():New( oSection3, "INSC", "", STR0014, "@!", 20, , { || SM0->M0_CGC } ) //"9- Inscrição"
	TRCell():New( oSection3, "CNAE", "", STR0012, "@!", 20, , { || SM0->M0_CNAE } ) //"10- CNAE"
	
	//Seção 4 - Emitente - Acidentado
	oSection4 := TRSection():New( oReport, "Emitente - Acidentado", { "SRA", "SRJ", "TNC" } )
	TRCell():New( oSection4, "RA_NOME", "SRA", STR0015, "@!", 32 ) //"11- Nome"
	TRCell():New( oSection4, "RA_CIC", "SRA", STR0016, "@R 999.999.999-99", 17 ) //"12- CPF"
	TRCell():New( oSection4, "RA_NASC", "SRA", STR0017, "", 26 ) //"13- Data de Nascimento"
	TRCell():New( oSection4, "RA_SEXO", "SRA", STR0018, "@!", 10 ) //"14- Sexo"
	TRCell():New( oSection4, "RA_ESTCIVI", "SRA", STR0019, "@!", 19, , { || fGetEstCiv( SRA->RA_ESTCIVI ) } ) //"15- Estado Civil"
	TRCell():New( oSection4, "RJ_CODCBO", "SRJ", STR0020, "999999", 10 ) //"16- CBO"
	TRCell():New( oSection4, "TNC_TIPREV", "TNC", STR0021, "@!", 39 ) //"17- Filiação à Previdência Social"
	TRCell():New( oSection4, "TNC_AREA", "TNC", STR0022, "@!", 06 ) //"18- Áreas"
	TRPosition():New( oSection4, "TM0", 1, { || xFilial( "TM0" ) + TNC->TNC_NUMFIC } )
	TRPosition():New( oSection4, "SRA", 1, { || xFilial( "SRA" ) + TM0->TM0_MAT } )
	TRPosition():New( oSection4, "SRJ", 1, { || xFilial( "SRJ" ) + SRA->RA_CODFUNC } )

	//Seção 5 - Emitente - Acidente ou Doença I
	oSection5 := TRSection():New( oReport, "Emitente - Acidente ou Doença I", { "TNC" } )
	TRCell():New( oSection5, "TNC_DTACID", "TNC", STR0023, "", 25 ) //"19- Data do Acidente"
	TRCell():New( oSection5, "TNC_HRACID", "TNC", STR0024, "99:99", 25 ) //"20- Hora do Acidente"
	TRCell():New( oSection5, "TNC_HRTRAB", "TNC", STR0025, "99:99", 42 ) //"21- Após quantas horas de trabalho?"
	TRCell():New( oSection5, "TNC_INDACI", "TNC", STR0090, "@!", 15, , { || fGetTipAci( TNC->TNC_INDACI ) } ) //"22- Tipo"
	TRCell():New( oSection5, "TNC_AFASTA", "TNC", STR0026, "@!", 27 ) //"23- Houve afastamento?"
	TRCell():New( oSection5, "TNC_DTULTI", "TNC", STR0027, "", 08 ) //"24- Último dia trabalhado"
	
	//Seção 6 - Emitente - Acidente ou Doença II
	oSection6 := TRSection():New( oReport, "Emitente - Acidente ou Doença II", { "TNC" } )
	TRCell():New( oSection6, "TNC_INDLOC", "TNC", STR0028, "@!", 50, , { || fGetLocAci( TNC->TNC_INDLOC ) } ) //"25- Local do acidente"
	
	//Seção 7 - Emitente - Acidente ou Doença III
	oSection7 := TRSection():New( oReport, "Emitente - Acidente ou Doença III", { "TNC" } )
	TRCell():New( oSection7, "TNC_LOCAL", "TNC", STR0029, "@!", 255 ) //"26- Especificação do local do acidente"

	//Seção 8 - Emitente - Acidente ou Doença IV
	oSection8 := TRSection():New( oReport, "Emitente - Acidente ou Doença IV", { "TNC" } )
	TRCell():New( oSection8, "TNC_CGCPRE", "TNC", STR0030, "@!", 47 ) //"27- CNPJ/CAEPF/CNO do local do acidente"
	TRCell():New( oSection8, "TNC_ESTACI", "TNC", STR0031, "@!", 10 ) //"28- UF"
	TRCell():New( oSection8, "TNC_CODCID", "TNC", STR0032, "@!", 50, , { || fGetMunAci( TNC->TNC_ESTACI, TNC->TNC_CODCID ) } ) //"29- Município do local do acidente"
	TRCell():New( oSection8, "TNC_CODPAI", "TNC", STR0033, "@!", 50, , { || fGetPaiAci( TNC->TNC_CODPAI, TNC->TNC_INDLOC ) } ) //"30- País"
	
	//Seção 9 - Emitente - Acidente ou Doença V
	oSection9 := TRSection():New( oReport, "Emitente - Acidente ou Doença V", { "TOI" } )
	TRCell():New( oSection9, "TOI_ESOC", "TOI", STR0034, "@!", 160, , { || fGetDscPar( TOI->TOI_ESOC ) } ) //"31- Parte do corpo atingida"
	TRPosition():New( oSection9, "TYF", 1, { || xFilial( "TYF" ) + TNC->TNC_ACIDEN } )
	TRPosition():New( oSection9, "TOI", 1, { || xFilial( "TOI" ) + TYF->TYF_CODPAR } )

	//Seção 10 - Emitente - Acidente ou Doença VI
	oSection10 := TRSection():New( oReport, "Emitente - Acidente ou Doença VI", { "TNH" } )
	TRCell():New( oSection10, "TNH_ESOC", "TNH", STR0035, "@!", 220, , { || fGetDscAge( TNH->TNH_ESOC ) } ) //"32- Agente causador"
	TRPosition():New( oSection10, "TYE", 1, { || xFilial( "TYE" ) + TNC->TNC_ACIDEN } )
	TRPosition():New( oSection10, "TNH", 1, { || xFilial( "TNH" ) + TYE->TYE_CAUSA } )

	//Seção 11 - Emitente - Acidente ou Doença VII
	oSection11 := TRSection():New( oReport, "Emitente - Acidente ou Doença VII", { "TYF", "TNG" } )
	TRCell():New( oSection11, "TYF_LATERA", "TYF", STR0036, "@!", 25 ) //"33- Lateralidade"
	If X3USO( GetSx3Cache( "TNG_ESOC", "X3_USADO" ) )
		TRCell():New( oSection11, "TNG_ESOC", "TNG", STR0037, "@!", 220, , { || fGetDscSit( TNG->TNG_ESOC ) } ) //"34- Descrição da situação geradora"
	Else
		TRCell():New( oSection11, "TNG_ESOC1", "TNG", STR0037, "@!", 220, , { || fGetDscSit( TNG->TNG_ESOC1 ) } ) //"34- Descrição da situação geradora"
	EndIf
	TRPosition():New( oSection11, "TYF", 1, { || xFilial( "TYF" ) + TNC->TNC_ACIDEN } )
	TRPosition():New( oSection11, "TNG", 1, { || xFilial( "TNG" ) + TNC->TNC_TIPACI } )
	
	//Seção 12 - Emitente - Acidente ou Doença VIII
	oSection12 := TRSection():New( oReport, "Emitente - Acidente ou Doença VIII", { "TNC" } )
	TRCell():New( oSection12, "TNC_POLICI", "TNC", STR0038, "@!", 40 ) //"35- Houve registro policial?"
	TRCell():New( oSection12, "TNC_MORTE", "TNC", STR0039, "@!", 25 ) //"36- Houve morte?"
	TRCell():New( oSection12, "TNC_DTOBIT", "TNC", STR0040, "@!", 25 ) //"37- Data do óbito"

	//Seção 13 - Emitente - Acidente ou Doença IX
	oSection13 := TRSection():New( oReport, "Emitente - Acidente ou Doença IX", { "TNC" } )
	TRCell():New( oSection13, "TNC_DETALH", "TNC", STR0042, "@!", 254 ) //"38- Observações"

	//Seção 14 - Emitente - Acidente ou Doença X
	oSection14 := TRSection():New( oReport, "Emitente - Acidente ou Doença X", { "TNC" } )
	If TNC->( ColumnPos( "TNC_DTRECB" ) ) > 0
		TRCell():New( oSection14, "TNC_DTRECB", "TNC", STR0041, "", 08 ) //"39- Data do recebimento"
	Else
		TRCell():New( oSection14, "DTRECB", "", STR0041, "", 08, , { || "  /  /   " } ) //"39- Data do recebimento"
	EndIf

	//Seção 15 - Informações do Atestado Médico - Atendimento
	oSection15 := TRSection():New( oReport, "Informações do Atestado Médico - Atendimento", { "TNC" } )
	TRCell():New( oSection15, "DTATEN", "", STR0043, "@!", 12, , { || cDtAten } ) //"40- Data"
	TRCell():New( oSection15, "HRATEN", "", STR0044, "99:99", 11, , { || cHrAten } ) //"41- Hora"
	TRCell():New( oSection15, "TNC_INTERN", "TNC", STR0045, "@!", 25 ) //"42- Houve internação?"
	TRCell():New( oSection15, "DURTRA", "", STR0046, "@!", 47, , { || cDurTra } ) //"43- Provável duração do tratamento (dias)"
	TRCell():New( oSection15, "HOUAFA", "", STR0047, "@!", 03, , { || cHouAfa } ) //"44- Deverá o acidentado afastar-se do trabalho durante o tratamento?"

	//Seção 16 - Informações do Atestado Médico - Lesão
	oSection16 := TRSection():New( oReport, "Informações do Atestado Médico - Lesão", { "TNC", "TOJ" } )
	TRCell():New( oSection16, "TOJ_ESOC", "TOJ", STR0048, "@!", 08, , { || fGetDscNat( TOJ->TOJ_ESOC ) } ) //"45- Descrição e natureza da lesão"
	TRPosition():New( oSection16, "TOJ", 1, { || xFilial( "TOJ" ) + TNC->TNC_CODLES } )

	//Seção 17 - Informações do Atestado Médico - Diagnóstico I
	oSection17 := TRSection():New( oReport, "Informações do Atestado Médico - Diagnóstico I", "TNC" )
	TRCell():New( oSection17, "DIAGPRO", "", STR0049, "@!", 100, , { || cDiaPro } ) //"46- Diagnóstico provável"

	//Seção 18 - Informações do Atestado Médico - Diagnóstico II
	oSection18 := TRSection():New( oReport, "Informações do Atestado Médico - Diagnóstico II", "TNC" )
	TRCell():New( oSection18, "CID10", "", STR0050, "@!", 15, , { || cCID10 } ) //"47- CID-10"
	TRCell():New( oSection18, "LOCDAT", "", STR0051, "@!", 50, , { || cLocDat } ) //"48- Local e Data"
	TRCell():New( oSection18, "INFMED", "", STR0052, "@!", 60, , { || cInfMed } ) //"49- Nome do médico, CRM e UF"
	
	//Seção 19 - Informações do Atestado Médico - Diagnóstico III
	oSection19 := TRSection():New( oReport, "Informações do Atestado Médico - Diagnóstico III", "TNC" )
	TRCell():New( oSection19, "OBSERV", "", STR0091, "@!", 255, , { || cObserv } ) //"50- Observações"

Return oReport

//---------------------------------------------------------------------
/*/{Protheus.doc} ReportPrint
Chamada do relatório

@sample	ReportPrint( oReport )

@param oReport, Objeto, Objeto do relatório

@author	Luis Fellipy Bett
@since	09/11/2020

@return .T., Boolean, Sempre verdadeiro
/*/
//---------------------------------------------------------------------
Static Function ReportPrint( oReport )

	//Variáveis das seções
	Local oSection1 := oReport:Section( 1 )
	Local oSection2 := oReport:Section( 2 )
	Local oSection3 := oReport:Section( 3 )
	Local oSection4 := oReport:Section( 4 )
	Local oSection5 := oReport:Section( 5 )
	Local oSection6 := oReport:Section( 6 )
	Local oSection7 := oReport:Section( 7 )
	Local oSection8 := oReport:Section( 8 )
	Local oSection9 := oReport:Section( 9 )
	Local oSection10 := oReport:Section( 10 )
	Local oSection11 := oReport:Section( 11 )
	Local oSection12 := oReport:Section( 12 )
	Local oSection13 := oReport:Section( 13 )
	Local oSection14 := oReport:Section( 14 )
	Local oSection15 := oReport:Section( 15 )
	Local oSection16 := oReport:Section( 16 )
	Local oSection17 := oReport:Section( 17 )
	Local oSection18 := oReport:Section( 18 )
	Local oSection19 := oReport:Section( 19 )

	//Variáveis de composição de busca
	Local cAciDe := IIf( lMDTA640, TNC->TNC_ACIDEN, MV_PAR01 )
	Local cAciAte := IIf( lMDTA640, TNC->TNC_ACIDEN, MV_PAR02 )
	Local lAssElt := IIf( lMDTA640, MsgYesNo( STR0094, STR0001 ), MV_PAR03 == 1 ) //"Formulário assinado eletronicamente?"

	//Variáveis referentes a busca das informações do atendimento médico
	Private cDtAten := ""
	Private cHrAten := ""
	Private cDurTra := ""
	Private cHouAfa := ""
	Private cDiaPro := ""
	Private cCID10	:= ""
	Private cLocDat := ""
	Private cInfMed := ""
	Private cObserv := ""

	//Variáveis de estilização da fonte
	oFont1 := TFont():New( "Courier New", , -8, , .F. ) //Fonte normal para o corpo do relatório
	oFont2 := TFont():New( "Courier New", 08, 08, , .T. ) //Fonte em negrito para os títulos

	//Posiciona na TNC para buscar as informações do acidente
	dbSelectArea( "TNC" )
	dbSetOrder( 1 )
	dbSeek( xFilial( "TNC" ) + cAciDe, .T. )
	oReport:SetMeter( LastRec() ) //Define o tamanho da régua de processamento
	While !oReport:Cancel() .And. TNC->( !Eof() ) .And. TNC->TNC_FILIAL == xFilial( "TNC" ) .And. TNC->TNC_ACIDEN <= cAciAte

		//Busca as informações do atendimento médico do acidente
		fGetInfAte()

		//Inicia, imprime e finaliza a seção 1 (controle de quebra de página)
		oSection1:Init()
		oSection1:PrintLine()
		oSection1:Finish()
		oSection1:SetPageBreak( .T. )
		oSection1:PageBreak()

		//Imprime o cabeçalho
		oReport:oFontBody := oFont2
		oReport:PrtCenter( STR0058 ) //"I - DADOS DE IDENTIFICAÇÃO"
		oReport:oFontBody := oFont1
		oReport:SkipLine()
		oReport:FatLine()

		//Inicia, imprime e finaliza a seção 2
		oSection2:Init()
		oSection2:PrintLine()
		oSection2:Finish()
		oReport:SkipLine()

		//Imprime o cabeçalho
		oReport:oFontBody := oFont2
		oReport:PrtCenter( STR0059 ) //"II - EMITENTE"
		oReport:oFontBody := oFont1
		oReport:SkipLine()
		oReport:FatLine()
		oReport:SkipLine()

		//Imprime o cabeçalho
		oReport:oFontBody := oFont2
		oReport:PrtLeft( STR0061 ) //"EMPREGADOR"
		oReport:oFontBody := oFont1
		oReport:SkipLine()

		//Inicia, imprime e finaliza a seção 3
		oSection3:Init()
		oSection3:PrintLine()
		oSection3:Finish()
		oReport:SkipLine()

		//Imprime o cabeçalho
		oReport:oFontBody := oFont2
		oReport:PrtLeft( STR0062 ) //"ACIDENTADO"
		oReport:oFontBody := oFont1
		oReport:SkipLine()
		
		//Inicia, imprime e finaliza a seção 4
		oSection4:Init()
		oSection4:PrintLine()
		oSection4:Finish()
		oReport:SkipLine()

		//Imprime o cabeçalho
		oReport:oFontBody := oFont2
		oReport:PrtLeft( STR0063 ) //"ACIDENTE OU DOENÇA"
		oReport:oFontBody := oFont1
		oReport:SkipLine()
		
		//Inicia, imprime e finaliza a seção 5
		oSection5:Init()
		oSection5:PrintLine()
		oSection5:Finish()
		oReport:SkipLine()

		//Inicia, imprime e finaliza a seção 6
		oSection6:Init()
		oSection6:PrintLine()
		oSection6:Finish()
		oReport:SkipLine()

		//Inicia, imprime e finaliza a seção 7
		oSection7:Init()
		oSection7:PrintLine()
		oSection7:Finish()
		oReport:SkipLine()

		//Inicia, imprime e finaliza a seção 8
		oSection8:Init()
		oSection8:PrintLine()
		oSection8:Finish()
		oReport:SkipLine()

		//Inicia, imprime e finaliza a seção 9
		oSection9:Init()
		oSection9:PrintLine()
		oSection9:Finish()
		oReport:SkipLine()

		//Inicia, imprime e finaliza a seção 10
		oSection10:Init()
		oSection10:PrintLine()
		oSection10:Finish()
		oReport:SkipLine()

		//Inicia, imprime e finaliza a seção 11
		oSection11:Init()
		oSection11:PrintLine()
		oSection11:Finish()
		oReport:SkipLine()

		//Inicia, imprime e finaliza a seção 12
		oSection12:Init()
		oSection12:PrintLine()
		oSection12:Finish()

		//Inicia, imprime e finaliza a seção 13
		oSection13:Init()
		oSection13:PrintLine()
		oSection13:Finish()
		oReport:SkipLine()

		//Inicia, imprime e finaliza a seção 14
		oSection14:Init()
		oSection14:PrintLine()
		oSection14:Finish()
		oReport:SkipLine()

		//Imprime o cabeçalho
		oReport:oFontBody := oFont2
		oReport:PrtCenter( STR0060 ) //"III - INFORMAÇÕES DO ATESTADO MÉDICO"
		oReport:oFontBody := oFont1
		oReport:SkipLine()
		oReport:FatLine()
		oReport:SkipLine()

		//Imprime o cabeçalho
		oReport:oFontBody := oFont2
		oReport:PrtLeft( STR0064 ) //"ATENDIMENTO"
		oReport:oFontBody := oFont1
		oReport:SkipLine()

		//Inicia, imprime e finaliza a seção 15
		oSection15:Init()
		oSection15:PrintLine()
		oSection15:Finish()
		oReport:SkipLine()

		//Imprime o cabeçalho
		oReport:oFontBody := oFont2
		oReport:PrtLeft( STR0065 ) //"LESÃO"
		oReport:oFontBody := oFont1
		oReport:SkipLine()

		//Inicia, imprime e finaliza a seção 16
		oSection16:Init()
		oSection16:PrintLine()
		oSection16:Finish()
		oReport:SkipLine()

		//Imprime o cabeçalho
		oReport:oFontBody := oFont2
		oReport:PrtLeft( STR0066 ) //"DIAGNÓSTICO"
		oReport:oFontBody := oFont1
		oReport:SkipLine()

		//Inicia, imprime e finaliza a seção 17
		oSection17:Init()
		oSection17:PrintLine()
		oSection17:Finish()

		//Inicia, imprime e finaliza a seção 18
		oSection18:Init()
		oSection18:PrintLine()
		oSection18:Finish()
		oReport:SkipLine()

		//Inicia, imprime e finaliza a seção 19
		oSection19:Init()
		oSection19:PrintLine()
		oSection19:Finish()
		oReport:SkipLine()

		//Imprime o rodapé
		oReport:oFontBody := oFont2
		oReport:PrtCenter( STR0092 ) //"A COMUNICAÇÃO DO ACIDENTE É OBRIGATÓRIA, MESMO NO CASO EM QUE NÃO HAJA AFASTAMENTO DO TRABALHO"
		oReport:SkipLine()
		If lAssElt //Caso for assinatura eletrônica
			oReport:PrtCenter( STR0093 ) //"FORMULÁRIO ASSINADO ELETRONICAMENTE - DISPENSA ASSINATURA E CARIMBO"
		EndIf

		//Adiciona régua de processamento
		oReport:IncMeter()

		//Pula para o próximo registro
		TNC->( dbSkip() )

	End

Return .T.

//---------------------------------------------------------------------
/*/{Protheus.doc} fGetTipCAT
Retorna o tipo da CAT em string baseado no tipo da CAT passado por parâmetro

@sample	fGetTipCAT( "1" )

@param cTipCAT, Caracter, Tipo da CAT

@author	Luis Fellipy Bett
@since	22/11/2021

@return cTipRet, Caracter, Tipo da CAT em string
/*/
//---------------------------------------------------------------------
Static Function fGetTipCAT( cTipCAT )

	Local cTipRet := ""

	If cTipCAT == "1"
		cTipRet := STR0067 //"Inicial"
	ElseIf cTipCAT == "2"
		cTipRet := STR0068 //"Reabertura"
	ElseIf cTipCAT == "3"
		cTipRet := STR0069 //"Comunicação de óbito"
	EndIf

Return cTipRet

//---------------------------------------------------------------------
/*/{Protheus.doc} fGetTipIns
Retorna o tipo em string baseado no tipo numérico passado por parâmetro

@sample	fGetTipIns( 2 )

@param nTipo, Numérico, Tipo de inscrição da empresa

@author	Luis Fellipy Bett
@since	22/11/2021

@return cTipRet, Caracter, Tipo de inscrição em string
/*/
//---------------------------------------------------------------------
Static Function fGetTipIns( nTipo )

	Local cTipRet := ""

	If nTipo == 2
		cTipRet := STR0070 //"CNPJ"
	ElseIf nTipo == 3
		cTipRet := STR0016 //"CPF"
	EndIf

Return cTipRet

//---------------------------------------------------------------------
/*/{Protheus.doc} fGetEstCiv
Retorna o estado civil em string baseado no estado civil passado por parâmetro

@sample	fGetEstCiv( "S" )

@param cEstCiv, Caracter, Estado civil do funcionário

@author	Luis Fellipy Bett
@since	22/11/2021

@return cEstRet, Caracter, Estado civil em string
/*/
//---------------------------------------------------------------------
Static Function fGetEstCiv( cEstCiv )

	Local cEstRet := ""

	If cEstCiv == "S"
		cEstRet := STR0071 //"Solteiro(a)"
	ElseIf cEstCiv == "C"
		cEstRet := STR0072 //"Casado(a)"
	ElseIf cEstCiv == "V"
		cEstRet := STR0073 //"Viúvo(a)"
	ElseIf cEstCiv == "D"
		cEstRet := STR0074 //"Divorciado(a)"
	ElseIf cEstCiv == "Q"
		cEstRet := STR0075 //"Separado(a)"
	EndIf

Return cEstRet

//---------------------------------------------------------------------
/*/{Protheus.doc} fGetTipAci
Retorna o tipo do acidente em string baseado no tipo passado por parâmetro

@sample	fGetTipAci( "1" )

@param cTipoAci, Caracter, Tipo do acidente

@author	Luis Fellipy Bett
@since	22/11/2021

@return cTipoRet, Caracter, Tipo do acidente em string
/*/
//---------------------------------------------------------------------
Static Function fGetTipAci( cTipoAci )

	Local cTipoRet := ""

	If cTipoAci == "1"
		cTipoRet := STR0076 //"Típico"
	ElseIf cTipoAci == "2"
		cTipoRet := STR0077 //"Trajeto"
	ElseIf cTipoAci == "3"
		cTipoRet := STR0078 //"Doença"
	EndIf

Return cTipoRet

//---------------------------------------------------------------------
/*/{Protheus.doc} fGetLocAci
Retorna o tipo do local do acidente em string baseado no tipo de local passado por parâmetro

@sample	fGetLocAci( "1" )

@param cTipoLoc, Caracter, Tipo do local do acidente

@author	Luis Fellipy Bett
@since	22/11/2021

@return cLocRet, Caracter, Tipo do acidente em string
/*/
//---------------------------------------------------------------------
Static Function fGetLocAci( cTipoLoc )

	Local cLocRet := ""

	If cTipoLoc == "1"
		cLocRet := STR0079 //"Estabelecimento do empregador no Brasil"
	ElseIf cTipoLoc == "2"
		cLocRet := STR0080 //"Estabelecimento de terceiros"
	ElseIf cTipoLoc == "3"
		cLocRet := STR0081 //"Via pública"
	ElseIf cTipoLoc == "4"
		cLocRet := STR0082 //"Área rural"
	ElseIf cTipoLoc == "5"
		cLocRet := STR0083 //"Embarcação"
	ElseIf cTipoLoc == "6"
		cLocRet := STR0084 //"Estabelecimento do empregador no exterior"
	EndIf

Return cLocRet

//---------------------------------------------------------------------
/*/{Protheus.doc} fGetMunAci
Retorna o município do acidente em string baseado no código passado por parâmetro

@sample	fGetMunAci( "09102" )

@param cCodEst, Caracter, Código do estado do acidente
@param cCodCid, Caracter, Código do município do acidente

@author	Luis Fellipy Bett
@since	23/11/2021

@return cMunRet, Caracter, Município em string
/*/
//---------------------------------------------------------------------
Static Function fGetMunAci( cCodEst, cCodCid )

	Local cMunRet := AllTrim( Posicione( "CC2", 1, xFilial( "CC2" ) + cCodEst + cCodCid, "CC2_MUN" ) )

Return cMunRet

//---------------------------------------------------------------------
/*/{Protheus.doc} fGetPaiAci
Retorna o país do acidente em string baseado no código passado por parâmetro

@sample	fGetPaiAci( "000062", "6" )

@param cCodPai, Caracter, País do acidente
@param cTipoLoc, Caracter, Tipo do local do acidente

@author	Luis Fellipy Bett
@since	23/11/2021

@return cPaiRet, Caracter, País em string
/*/
//---------------------------------------------------------------------
Static Function fGetPaiAci( cCodPai, cTipoLoc )

	Local cPaiRet := ""

	//Caso for estabelecimento do empregador
	If cTipoLoc == "1"
		cCodPai := "000001"
	EndIf

	//Busca a descrição do país
	cPaiRet := AllTrim( Posicione( "C08", 3, xFilial( "C08" ) + cCodPai, "C08_DESCRI" ) )

Return cPaiRet

//---------------------------------------------------------------------
/*/{Protheus.doc} fGetDscPar
Retorna a descrição da parte atingida em string baseado no código passado por parâmetro

@sample	fGetDscPar( "753030000" )

@param cCodPar, Caracter, Código da parte atingida

@author	Luis Fellipy Bett
@since	23/11/2021

@return cParAti, Caracter, Parte atingida em string
/*/
//---------------------------------------------------------------------
Static Function fGetDscPar( cCodPar )

	Local cParAti := AllTrim( cCodPar ) + " - " + AllTrim( Posicione( "TOI", 3, xFilial( "TOI" ) + cCodPar, "TOI_DESPAR" ) )

Return cParAti

//---------------------------------------------------------------------
/*/{Protheus.doc} fGetDscAge
Retorna o agente causador em string baseado no código passado por parâmetro

@sample	fGetDscAge( "302010200" )

@param cCodAge, Caracter, Código do agente causador

@author	Luis Fellipy Bett
@since	23/11/2021

@return cAgeCau, Caracter, Agente causador em string
/*/
//---------------------------------------------------------------------
Static Function fGetDscAge( cCodAge )

	Local cAgeCau := AllTrim( cCodAge ) + " - " + AllTrim( Posicione( "TNH", 3, xFilial( "TNH" ) + cCodAge, "TNH_DESOBJ" ) )

Return cAgeCau

//---------------------------------------------------------------------
/*/{Protheus.doc} fGetDscSit
Retorna a situação geradora em string baseado no código passado por parâmetro

@sample	fGetDscSit( "200004600" )

@param cCodSit, Caracter, Código da situação geradora

@author	Luis Fellipy Bett
@since	23/11/2021

@return cSitGer, Caracter, Situação geradora em string
/*/
//---------------------------------------------------------------------
Static Function fGetDscSit( cCodSit )

	Local cSitGer := AllTrim( cCodSit ) + " - " + AllTrim( Posicione( "TNG", 4, xFilial( "TNG" ) + cCodSit, "TNG_DESTIP" ) )

Return cSitGer

//---------------------------------------------------------------------
/*/{Protheus.doc} fGetDscNat
Retorna a natureza da lesão em string baseado no código passado por parâmetro

@sample	fGetDscNat( "702015000" )

@param cCodNat, Caracter, Código da natureza da lesão

@author	Luis Fellipy Bett
@since	23/11/2021

@return cNatLes, Caracter, Natureza da lesão em string
/*/
//---------------------------------------------------------------------
Static Function fGetDscNat( cCodNat )

	Local cNatLes := AllTrim( cCodNat ) + " - " + AllTrim( Posicione( "TOJ", 3, xFilial( "TOJ" ) + cCodNat, "TOJ_NOMLES" ) )

Return cNatLes

//---------------------------------------------------------------------
/*/{Protheus.doc} fGetInfAte
Busca as informações do atendimento médico do funcionário

@sample	fGetInfAte()

@author	Luis Fellipy Bett
@since	23/11/2021

@return cRet, Caracter, Informação de retorno de acordo com o parâmetro
/*/
//---------------------------------------------------------------------
Static Function fGetInfAte()

	//Salva a área
	Local aArea := GetArea()
	Local aInfAte := {}

	//Variáveis private utilizadas na função MDTInfAte
	Private cAtendAci	 := SuperGetMv( "MV_NG2IATE", .F., "3" )
	Private lDiagnostico := .F.
	Private lAtestado	 := .F.
	Private lAtesAcid	 := .F.

	//Adiciona os campos do acidente posicionado na memória para buscar as informações do atendimento médico
	RegToMemory( "TNC", .F., , .F. )

	//Verifica se valida as informações do atendimento através do acidente
	lAtesAcid := !Empty( M->TNC_DTATEN ) .And. !Empty( M->TNC_HRATEN )
	
	//Busca as informações do atendimento médico do acidente
	aInfAte := MDTInfAte()

	cDtAten := IIf( Len( aInfAte ) > 0, DToC( aInfAte[ 1 ] ), "" ) //Data do atendimento
	cHrAten := IIf( Len( aInfAte ) > 0, SubStr( aInfAte[ 2 ], 1, 2 ) + ":" + SubStr( aInfAte[ 2 ], 3, 2 ), "" ) //Hora do atendimento
	cDurTra := IIf( Len( aInfAte ) > 0, aInfAte[ 3 ], "" ) //Duração do tratamento
	cHouAfa := IIf( Len( aInfAte ) > 0, IIf( aInfAte[ 4 ] == "S", STR0085, STR0086 ), "" ) //Houve afastamento? ## "Sim" ## "Não"
	cDiaPro := IIf( Len( aInfAte ) > 5, AllTrim( aInfAte[ 6 ] ), "" ) //Diagnóstico provável
	cCID10	:= IIf( Len( aInfAte ) > 0, SubStr( aInfAte[ 5 ], 1, 3 ) + "." + SubStr( aInfAte[ 5 ], 4, 1 ), "" ) //CID-10
	cLocDat := IIf( Len( aInfAte ) > 0, AllTrim( SM0->M0_CIDENT ) + " - " + AllTrim( SM0->M0_ESTENT ) + ", " + DToC( aInfAte[ 1 ] ), "" ) //Local e data
	cInfMed := IIf( Len( aInfAte ) > 5, AllTrim( aInfAte[ 8 ] ) + " - " + aInfAte[ 10 ] + " - " + aInfAte[ 11 ], "" ) //Nome do médico, CRM e UF
	cObserv := IIf( Len( aInfAte ) > 5, AllTrim( aInfAte[ 7 ] ), "" ) //Observações

	//Retorna a área
	RestArea( aArea )

Return
