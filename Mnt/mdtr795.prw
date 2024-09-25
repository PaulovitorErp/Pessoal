#INCLUDE "MDTR795.ch"
#INCLUDE "PROTHEUS.CH"

//---------------------------------------------------------------------
/*/{Protheus.doc} MDTR795
Relatório de Histórico Médico de Funcionário

@author Thiago Henrique dos Santos
@since 02/05/2013
@version P11
@return Nil
/*/
//---------------------------------------------------------------------

Function MDTR795()
Local aNGBEGINPRM := NGBEGINPRM( )
Local oReport
Local aArea := GetArea()
Private cPERG := "MDTR795"
Private aPerg :={}
Private lok := .T.
Private cDescAtend := ""

/*-----------------------
//PERGUNTAS PADRÃO		|
| De Ficha Médica ?		|
| Até Ficha Médica ?		|
| De Data ?				|
| Até Data ?				|
| Imprimir recibo ?		|
-------------------------*/

oReport := ReportDef()

If lOk
	oReport:PrintDialog()
Endif

NGRETURNPRM(aNGBEGINPRM)

RestArea(aArea)

Return

//---------------------------------------------------------------------
/*/{Protheus.doc} ReportDef
Constrói o objeto instância da Classe TReport

@author Thiago Santos
@since 07/05/2013
@version P11
@return Nil
/*/
//---------------------------------------------------------------------

Static Function ReportDef()
Local oReport
Local oSecFicha
Local oSecCons
Local oSecAtend
Local oSecMed
Local oSecExa
Local oSecASO
Local oSecAtest
//Local oSecAtest1
//Local oSecAtest2
Local oSecEnfer
Local oSecDoenca
Local oSecRestri
Local oSecVacina
Local oSecTarefas
Local oSecMedica

oReport := TReport():New("MDTR795",OemToAnsi(STR0011),cPERG,{|oReport| ReportPrint(oReport)},STR0012) //"Histórico Médico de Funcionário"###"O relatório apresentará o histórico médicos dos funcionários no período."

If !Pergunte(oReport:uParam)
	lOk := .F.
	return oReport
Endif

oReport:SetPortrait()        // Define orientação de página do relatório como retrato.
oReport:setTotalInLine(.F.)
oReport:DisableOrientation() // Desabilita a seleção da orientação (Retrato/Paisagem)

//oReport:SetBorder(5)

oReport:cFontBody := 'Courier New'
oReport:nFontBody := 6
//oReport:lBold := .T.

//-----------
oSecFicha:= TRSection():New(oReport,STR0013,{"TM0","SRA"},/*aOrdem*/)// "Relatório de Histórico Médico de Funcionário"
TRCell():New(oSecFicha,"TM0_NUMFIC","TM0",STR0014  ,X3Picture("TM0_NUMFIC"),TamSx3("TM0_NUMFIC")[1]+8,/*lPixel*/) //"Ficha Médica"
//TRCell():New(oSecFicha,"TM0_MAT"   ,"TM0",STR0015  ,X3Picture("TM0_MAT")   ,TamSx3("TM0_MAT")[1]+10   ,/*lPixel*/) //"Matrícula"
//TRCell():New(oSecFicha,"TM0_FILFUN","TM0",STR0016  ,X3Picture("TM0_FILFUN"),TamSx3("TM0_FILFUN")[1]+10,/*lPixel*/) //"Filial Func."
TRCell():New(oSecFicha,"TM0_NOMFIC"	,"TM0",STR0017  ,X3Picture("TM0_NOMFIC"),TamSx3("TM0_NOMFIC")[1]+10,/*lPixel*/) //"Nome"
TRCell():New(oSecFicha,"TM0_DTNASC"	,"TM0",STR0066  ,X3Picture("TM0_DTNASC"),TamSx3("TM0_DTNASC")[1]+10,/*lPixel*/) //"Data de Nasc."
TRCell():New(oSecFicha,"TM0_SEXO"	,"TM0",STR0067  ,"@!",15,/*lPixel*/,{||MDTR795BOX("TM0->TM0_SEXO")}) //"Sexo"
TRCell():New(oSecFicha,"TM0_SANGUE"	,"TM0",STR0068  ,"@!",15,/*lPixel*/,{||MDTR795BOX("TM0->TM0_SANGUE")}) //"Tipo Sanguíneo"
TRCell():New(oSecFicha,"TM0_FATORH"	,"TM0",STR0069  ,"@!",15,/*lPixel*/,{||MDTR795BOX("TM0->TM0_FATORH")})//"Fator RH"
TRCell():New(oSecFicha,"TM0_NOMFUN"	,"TM0",STR0089  ,"@!",40,/*lPixel*/,{||NGSEEK("SRJ",TM0->TM0_CODFUN,1,"RJ_DESC")})//"Função"
TRCell():New(oSecFicha,"TM0_CPF"	,"TM0",STR0090  ,X3Picture("TM0_CPF"),TamSx3("TM0_CPF")[1]+8,/*lPixel*/)//"Função"

oSecTarefas := TRSection():New(oSecFicha,STR0091,{"TM0","TN6","TN5"}) //"Tarefas"
TRCell():New(oSecTarefas,"TN5_CODTAR","TN5",STR0092  ,X3Picture("TN5_CODTAR"),TamSx3("TN5_CODTAR")[1]+8,/*lPixel*/) //"Tarefa"
TRCell():New(oSecTarefas,"TN5_NOMTAR","TN5",STR0020  ,X3Picture("TN5_NOMTAR"),TamSx3("TN5_NOMTAR")[1]+8,/*lPixel*/) //"Descrição"

//-------------------
oSecCons := TRSection():New(oSecFicha,STR0026,{"TMJ"}) //"Consultas"
TRCell():New(oSecCons,"TMJ_DTCONS","TMJ",STR0021  ,X3Picture("TMJ_DTCONS"),TamSx3("TMJ_DTCONS")[1]+5,/*lPixel*/) //"Data"
TRCell():New(oSecCons,"TMJ_HRCONS","TMJ",STR0027  ,X3Picture("TMJ_HRCONS"),TamSx3("TMJ_HRCONS")[1],/*lPixel*/) //"Hora"
TRCell():New(oSecCons,"TMJ_NOMUSU","TMJ",STR0028  ,X3Picture("TMJ_NOMUSU"),TamSx3("TMJ_NOMUSU")[1]+10,/*lPixel*/,;
																								{||NGSEEK('TMK',TMJ->TMJ_CODUSU,1,'TMK_NOMUSU')}) //"Nome"
TRCell():New(oSecCons,"TMJ_DESMOT"	,"TMJ",STR0094  ,X3Picture("TMS_NOMOTI"),TamSx3("TMS_NOMOTI")[1]+10,/*lPixel*/,;//"Desc. Motivo"
																								{||NGSEEK("TMS",TMJ->TMJ_MOTIVO,1,"TMS_NOMOTI")})
//-------------------

oSecAtend := TRSection():New(oSecFicha,STR0029,{"TMT"}) //"Atendimento"
TRCell():New(oSecAtend,"TMT_DTCONS","TMT",STR0021  ,X3Picture("TMT_DTCONS"),TamSx3("TMT_DTCONS")[1]+12,/*lPixel*/) //"Data"
TRCell():New(oSecAtend,"TMT_HRCONS" , "TMT",STR0027  ,X3Picture("TMT_HRCONS"),TamSx3("TMT_HRCONS")[1]+5,/*lPixel*/) //"Hora"
TRCell():New(oSecAtend,"TMT_NOMUSU","TMT",STR0028  ,X3Picture("TMT_NOMUSU"),TamSx3("TMT_NOMUSU")[1]+30,/*lPixel*/,;
																								{||NGSEEK('TMK',TMT->TMT_CODUSU,1,'TMK_NOMUSU')}) //"Nome"
TRCell():New(oSecAtend,"TMT_CID","TMT",STR0030  ,X3Picture("TMT_CID"),TamSx3("TMT_CID")[1]+10,/*lPixel*/) //"CID"
TRCell():New(oSecAtend,"TMT_DIAGNO","TMT",STR0112  ,"@!",200,/*lPixel*/, { | | cDescAtend } ) //"Ind. Atendim."

//-------------------

oSecMed := TRSection():New(oSecFicha,STR0034,{"TM2"}) //"Medicamentos"
TRCell():New(oSecMed,"TM2_DTCONS","TM2",STR0021  ,X3Picture("TM2_DTCONS"),TamSx3("TM2_DTCONS")[1]+10,/*lPixel*/) //"Data"
TRCell():New(oSecMed,"TM2_HRCONS","TM2",STR0027  ,X3Picture("TM2_HRCONS"),TamSx3("TM2_HRCONS")[1]+5,/*lPixel*/) //"Hora"
TRCell():New(oSecMed,"TM2_NOMEDI","TM2",STR0036  ,X3Picture("TM2_NOMEDI"),TamSx3("TM2_NOMEDI")[1]+10,/*lPixel*/,;
																								{||NGSEEK('TM1',TM2->TM2_CODMED,1,'TM1_NOMEDI')}) //"Medicamento"
TRCell():New(oSecMed,"TM2_QTUTIL","TM2",STR0037  ,X3Picture("TM2_QTUTIL"),TamSx3("TM2_QTUTIL")[1]+10,/*lPixel*/) //"Quantidade"
TRCell():New(oSecMed,"TM2_UNIDAD","TM2",STR0038  ,X3Picture("TM2_UNIDAD"),TamSx3("TM2_UNIDAD")[1]+10,/*lPixel*/) //"Unidade"
TRCell():New(oSecMed,"TM2_PSOLOG","TM2",STR0039  ,X3Picture("TM2_PSOLOG"),TamSx3("TM2_PSOLOG")[1]+10,/*lPixel*/) //"Posologia"

//-----------------
oSecExa := TRSection():New(oSecFicha,STR0018,{"TM5"}) //"Exames"
TRCell():New(oSecExa,"TM5_DTPROG","TM5",STR0021  ,X3Picture("TM5_DTPROG"),TamSx3("TM5_DTPROG")[1]+10,/*lPixel*/) //"Data"
TRCell():New(oSecExa,"TM5_DTRESU","TM5",STR0087  ,X3Picture("TM5_DTRESU"),TamSx3("TM5_DTRESU")[1]+10,/*lPixel*/) //"Data do Result."
TRCell():New(oSecExa,"TM5_EXAME","TM5",STR0019  ,X3Picture("TM5_EXAME"),TamSx3("TM5_EXAME")[1]+10,/*lPixel*/) //"Exame"
TRCell():New(oSecExa,"TM5_NOMEXA","TM5",STR0020  ,X3Picture("TM5_NOMEXA"),TamSx3("TM5_NOMEXA")[1]+10,/*lPixel*/,;
																					{||NGSEEK("TM4",TM5->TM5_EXAME,1,'TM4_NOMEXA')}) //"Descrição"
TRCell():New(oSecExa,"TM5_NATEXA","TMT",STR0097  ,"@!",20,/*lPixel*/,{||MDTR795BOX("TM5->TM5_NATEXA")}) //"Natureza"

//---------------------------
oSecASO := TRSection():New(oSecFicha,STR0040,{"TMY"}) //"ASO"
TRCell():New(oSecASO,"TMY_NUMASO","TMY",STR0041  ,X3Picture("TMY_NUMASO"),TamSx3("TMY_NUMASO")[1]+10,/*lPixel*/) //"Número ASO"
TRCell():New(oSecASO,"TMY_DTEMIS","TMY",STR0021  ,X3Picture("TMY_DTEMIS"),TamSx3("TMY_DTEMIS")[1]+10,/*lPixel*/) //"Data"
TRCell():New(oSecASO,"TMY_INDPAR","TMY",STR0043  ,"@!",20,/*lPixel*/,	{||MDTR795BOX("TMY->TMY_INDPAR")}) //"Parecer"
TRCell():New(oSecASO,"TMY_NOMUSU","TMY",STR0028  ,X3Picture("TMY_NOMUSU"),TamSx3("TMY_NOMUSU")[1]+10,/*lPixel*/,;
																								{||NGSEEK('TMK',TMY->TMY_CODUSU,1,'TMK_NOMUSU')}) //"Nome"
TRCell():New(oSecASO,"TMY_NATEXA","TMY",STR0097  ,"@!",20,/*lPixel*/,{||MDTR795BOX("TMY->TMY_NATEXA")}) //"Natureza"
TRCell():New(oSecASO,"TMY_NOVFUN","TMY",STR0099  ,X3Picture("TMY_NOVFUN"),TamSx3("TMY_NOVFUN")[1]+15,/*lPixel*/) //"Natureza"
TRCell():New(oSecASO,"TMY_NOMNFU","TMY",STR0100  ,"@!",50,/*lPixel*/,{||NGSEEK("SRJ",TMY->TMY_NOVFUN,1,"RJ_DESC")})

//---------------------------
oSecAtest := TRSection():New(oSecFicha,STR0044,{"TNY","TMK"}) //"Atestados"
TRCell():New(oSecAtest,"TNY_DTINIC","TNY",STR0046  ,X3Picture("TNY_DTINIC"),TamSx3("TNY_DTINIC")[1]+10,/*lPixel*/) //"Data Inic."
TRCell():New(oSecAtest,"TNY_HRINIC","TNY",STR0047  ,X3Picture("TNY_HRINIC"),TamSx3("TNY_HRINIC")[1]+10,/*lPixel*/) //"Hora Inic."

TRCell():New(oSecAtest,"TNY_DTFIM","TNY",STR0048  ,X3Picture("TNY_DTFIM"),TamSx3("TNY_DTFIM")[1]+10,/*lPixel*/) //"Data Term."
TRCell():New(oSecAtest,"TNY_HRFIM","TNY",STR0049  ,X3Picture("TNY_HRFIM"),TamSx3("TNY_HRFIM")[1]+10,/*lPixel*/) //"Hora Term."

TRCell():New(oSecAtest,"TMK_NOMUSU","TMK",STR0028  ,X3Picture("TMK_NOMUSU"),TamSx3("TMK_NOMUSU")[1]+10,/*lPixel*/)//,;
TRCell():New(oSecAtest,"TMK_NUMENT","TMK",STR0111  ,X3Picture("TMK_NUMENT"),30,/*lPixel*/,;
																									{||NGSEEK('TMK',TNY->TNY_EMITEN,1,'TMK_ENTCLA') + " " + NGSEEK('TMK',TNY->TNY_EMITEN,1,'TMK_NUMENT')}) //"Nome"
TRCell():New(oSecAtest,"TNY_CID","TNY",STR0030  ,X3Picture("TNY_CID"),TamSx3("TNY_CID")[1]+10,/*lPixel*/) //"CID"
TRCell():New(oSecAtest,"TNY_INDMED","TNY",STR0102  ,"@!",20,/*lPixel*/,{||MDTR795BOX("TNY->TNY_INDMED")}) //"Natureza"
TRPosition():New (oSecAtest, "TMK", 1, {|| xFilial("TMK") + TNY->TNY_EMITEN } )

//---------------------------
oSecEnfer := TRSection():New(oSecFicha,STR0050,{"TL5"}) //"Atendimentos de Enfermagem"
TRCell():New(oSecEnfer,"TL5_DTATEN","TL5",STR0021  ,X3Picture("TL5_DTATEN"),TamSx3("TL5_DTATEN")[1]+10,/*lPixel*/) //"Data"
TRCell():New(oSecEnfer,"TL5_HRATEN","TL5",STR0027  ,X3Picture("TL5_HRATEN"),TamSx3("TL5_HRATEN")[1]+10,/*lPixel*/) //"Hora"
TRCell():New(oSecEnfer,"TL5_NOMUSU","TL5",STR0051  ,X3Picture("TL5_NOMUSU"),TamSx3("TL5_NOMUSU")[1]+10,/*lPixel*/,;
																									{||NGSEEK('TMK',TL5->TL5_CODUSU,1,'TMK_NOMUSU')}) //"Nome"
TRCell():New(oSecEnfer,"TL5_INDICA","TL5",STR0052  ,"@!",15,/*lPixel*/,{||MDTR795BOX("TL5->TL5_INDICA")}) //"Indicação"
TRCell():New(oSecEnfer,"TL5_DESMOT","TL5",STR0020  ,X3Picture("TL5_DESMOT"),TamSx3("TL5_DESMOT")[1]+10,/*lPixel*/,;
																									{||NGSEEK('TMS',TL5->TL5_MOTIVO,1,'TMS_NOMOTI')})  //"Descrição"
TRCell():New(oSecEnfer,"TL5_OBSERV","TL5",STR0101  ,X3Picture("TL5_OBSERV"),50,/*lPixel*/,{|| MsMM( TL5->TL5_OBSSYP , 80 ) }) //"Observação"

//---------------------------
oSecMedica := TRSection():New(oSecFicha,STR0113,{"TY3","TL5"}) //"Medicamentos do Atendimento Enfermagem"
TRCell():New(oSecMedica,"TY3_DTATEN","TY3",STR0021  ,X3Picture("TY3_DTATEN"),TamSx3("TY3_DTATEN")[1]+10,/*lPixel*/) //"Data"
TRCell():New(oSecMedica,"TY3_HRATEN","TY3",STR0027  ,X3Picture("TY3_HRATEN"),TamSx3("TY3_HRATEN")[1]+10,/*lPixel*/) //"Hora"
TRCell():New(oSecMedica,"TY3_DESMED","TY3","Medicamento"  ,X3Picture("TY3_DESMED"),TamSx3("TY3_DESMED")[1]+10,/*lPixel*/,;
																							{||NGSEEK('TM1',TY3->TY3_CODMED,1,'TM1_NOMEDI')})  //"Descrição"
TRCell():New(oSecMedica,"TY3_QUANT","TY3",STR0037  ,X3Picture("TY3_QUANT"),TamSx3("TY3_QUANT")[1]+10,/*lPixel*/) //"Quantidade"

//---------------------------
oSecDoenca := TRSection():New(oSecFicha,STR0054,{"TNA"}) //"Doenças"
TRCell():New(oSecDoenca,"TNA_CID","TNA",STR0030  ,X3Picture("TNA_CID"),TamSx3("TNA_CID")[1]+10,/*lPixel*/) //"CID"
TRCell():New(oSecDoenca,"TNA_DTINIC","TNA",STR0046  ,X3Picture("TNA_DTINIC"),TamSx3("TNA_DTINIC")[1]+10,/*lPixel*/) //"Data Inic."
TRCell():New(oSecDoenca,"TNA_DTFIM","TNA",STR0048  ,X3Picture("TNA_DTFIM"),TamSx3("TNA_DTFIM")[1]+10,/*lPixel*/) //"Data Term."


//---------------------------
oSecRestri := TRSection():New(oSecFicha,STR0055,{"TMF"}) //"Restrições"
TRCell():New(oSecRestri,"TMF_NOMRES","TMF",STR0020  ,X3Picture("TMF_NOMRES"),TamSx3("TMF_NOMRES")[1]+10,/*lPixel*/,;
																								{||Alltrim(NGSEEK('TME',TMF->TMF_RESTRI,1,'TME_NOMRES'))}) //"Descrição"
TRCell():New(oSecRestri,"TMF_DTINIC","TMF",STR0046  ,X3Picture("TMF_DTINIC"),TamSx3("TMF_DTINIC")[1]+10,/*lPixel*/) //"Data Inic."
TRCell():New(oSecRestri,"TMF_DTFIM","TMF",STR0048  ,X3Picture("TMF_DTFIM"),TamSx3("TMF_DTFIM")[1]+10,/*lPixel*/) //"Data Term."

//---------------------------
oSecVacina := TRSection():New(oSecFicha,STR0059,{"TL9"}) //"Vacinas"
TRCell():New(oSecVacina,"TL9_NOMVAC","TL9",STR0020  ,X3Picture("TL9_NOMVAC"),TamSx3("TL9_NOMVAC")[1]+10,/*lPixel*/,;
																								{||Alltrim(NGSEEK('TL6',TL9->TL9_VACINA,1,'TL6_NOMVAC'))}) //"Descrição"
TRCell():New(oSecVacina,"TL9_DTPREV","TL9",STR0061  ,X3Picture("TL9_DTPREV"),TamSx3("TL9_DTPREV")[1]+10,/*lPixel*/) //"Data Prev."
TRCell():New(oSecVacina,"TL9_DTREAL","TL9",STR0062  ,X3Picture("TL9_DTREAL"),TamSx3("TL9_DTREAL")[1]+10,/*lPixel*/) //"Data Prev."
TRCell():New(oSecVacina,"TL9_DOSE","TL9",STR0063  ,X3Picture("TL9_DOSE"),TamSx3("TL9_DOSE")[1]+10,/*lPixel*/) //"Dose"
TRCell():New(oSecVacina,"TL8_DESCRI","TL8",STR0064  ,X3Picture("TL8_DESCRI"),TamSx3("TL8_DESCRI")[1]+10,/*lPixel*/,;
																								{||Alltrim(NGSEEK('TL8',TL9->TL9_DOSE+TL9->TL9_VACINA,2,'TL8_DESCRI'))}) //"Descrição") //"Vacina"
TRCell():New(oSecVacina,"TL9_INDVAC","TL9",STR0065  ,"@!",25,/*lPixel*/,{||MDTR795BOX("TL9->TL9_INDVAC")}) //"Vacinado"

oSecFicha:SetLineStyle()
oSecVacina:Cell("TL9_INDVAC"):lLineBreak := .T.
oSecCons:Cell("TMJ_DESMOT"):lLineBreak := .T.
oSecAtend:Cell("TMT_DIAGNO"):lLineBreak := .T.
oSecASO:Cell("TMY_NOMNFU"):lLineBreak := .T.
oSecEnfer:Cell("TL5_OBSERV"):lLineBreak := .T.
oSecEnfer:Cell("TL5_DESMOT"):lLineBreak := .T.
oSecAtest:Cell("TMK_NOMUSU"):lLineBreak := .T.
oSecEnfer:Cell("TL5_NOMUSU"):lLineBreak := .T.

Return oReport

//---------------------------------------------------------------------
/*/{Protheus.doc} ReportPrint
Emissão do relatório


@param oReport - Objeto instância da classe TReport
@param oFont  - Fonte para totalizador

@author Thiago Henrique dos Santos
@since 09/05/2013
@version P11
@return Nil
/*/
//---------------------------------------------------------------------
Static Function ReportPrint(oReport)

	Local nCps
	Local oSecFicha	  := oReport:Section(1)
	Local oSecTarefas := oReport:Section(1):Section(1)
	Local oSecCons	  := oReport:Section(1):Section(2)
	Local oSecAtend   := oReport:Section(1):Section(3)//:Section(1)
	Local oSecMed  	  := oReport:Section(1):Section(4)//:Section(2)
	Local oSecExa	  := oReport:Section(1):Section(5)
	Local oSecASO	  := oReport:Section(1):Section(6)
	Local oSecAtest	  := oReport:Section(1):Section(7)
	Local oSecEnfer   := oReport:Section(1):Section(8)
	Local oSecMedica  := oReport:Section(1):Section(9)
	Local oSecDoenca  := oReport:Section(1):Section(10)
	Local oSecRestri  := oReport:Section(1):Section(11)
	Local oSecVacina  := oReport:Section(1):Section(12)
	Local oFont1      := TFont():New(oReport:cFontBody,,-(oReport:nFontBody + 2),.T. ,.T.)
	Local oFont2      := TFont():New("Courier New",08,08 ,,.T.,,,,,.F.,.F.)
	Local oFont3      := TFont():New("Courier New",14,14 ,,.T.,,,,,.F.,.F.)
	Local cSoftTM0    := IF(Empty(MV_PAR01),"",MV_PAR01)
	Local lFirst      := .T.//Controle impressao de cabecalho
	Local aArea       := GetArea()
	Local aAreaSX3    := SX3->(GetArea())
	Local cCodUsr     := RetCodUsr()
	Local aCampos	  := 	{ 	{ "TMT_DIAGNO" 	, "TMT_DIASYP" } , ;
								{ "TMT_QUEIXA" 	, "TMT_QUESYP" } , ;
								{ "TMT_HDA"		, "TMT_HDASYP" } , ;
								{ "TMT_CABECA" 	, "TMT_CABSYP" } , ;
								{ "TMT_OLHOS" 	, "TMT_OLHSYP" } , ;
								{ "TMT_OUVIDO" 	, "TMT_OUVSYP" } , ;
								{ "TMT_PESCOC" 	, "TMT_PESSYP" } , ;
								{ "TMT_APRESP" 	, "TMT_APRSYP" } , ;
								{ "TMT_APDIGE" 	, "TMT_APDSYP" } , ;
								{ "TMT_APCIRC" 	, "TMT_APCSYP" } , ;
								{ "TMT_APURIN" 	, "TMT_APUSYP" } , ;
								{ "TMT_MMIISS" 	, "TMT_MISSYP" } , ;
								{ "TMT_PELE" 		, "TMT_PELSYP" } , ;
								{ "TMT_EXAMEF" 	, "TMT_EXFSYP" } , ;
								{ "TMT_TEMPER" } , ;
								{ "TMT_ALTURA" } , ;
								{ "TMT_PESO" } , ;
								{ "TMT_MASSA" } , ;
								{ "TMT_OROFAR" 	, "TMT_ORFSYP" } , ;
								{ "TMT_OTOSCO" 	, "TMT_OTSSYP" } , ;
								{ "TMT_ABDOME" 	, "TMT_ABDSYP" } , ;
								{ "TMT_AUSCAR" 	, "TMT_AUCSYP" } , ;
								{ "TMT_AUSPUL" 	, "TMT_AUPSYP" } }

	oReport:SetMeter(0)
	DbSelectArea("TM0")
	TM0->(DbSetOrder(1))
	If TM0->(DbSeek(xFilial("TM0")+cSoftTM0,.T.))

		//Fichas
		While TM0->(!Eof()) .AND. TM0->TM0_NUMFIC >= MV_PAR01 .AND. TM0->TM0_NUMFIC <= MV_PAR02 .AND. !oReport:Cancel()

			oReport:IncMeter()
			oSecFicha:Init()
			oReport:oFontBody := oFont2

			oSecFicha:PrintLine()

			// Tarefas
			DbSelectArea( 'TN6' )
			( 'TN6' )->( DbSetOrder( 2 ) )

			If !Empty( TM0->TM0_MAT ) .And. TN6->( DbSeek( xFilial( 'TN6', TM0->TM0_FILFUN ) + TM0->TM0_MAT ) )

				oReport:IncMeter()

				While TN6->( !Eof() ) .And. TN6->TN6_FILIAL == xFilial( 'TN6', TM0->TM0_FILFUN ) ;
				.And. TN6->TN6_MAT == TM0->TM0_MAT .And. !oReport:Cancel()

					If TN6->TN6_DTINIC <= MV_PAR04 .And. ( Empty( TN6->TN6_DTTERM ) .Or. TN6->TN6_DTTERM >= MV_PAR03 )

						DbSelectArea( 'TN5' )
						( 'TN5' )->( DbSetOrder( 1 ) )

						If ( 'TN5' )->( DbSeek( xFilial( 'TN5', TM0->TM0_FILFUN ) + TN6->TN6_CODTAR ) )

							If lFirst

								oReport:SkipLine()
								oSecTarefas:Init()
								oReport:ThinLine()
								oReport:PrintText(STR0091) // "Consultas"
								oReport:oFontBody := oFont1

								lFirst := .F.

							EndIf

							oSecTarefas:PrintLine()

						EndIf

					Endif

					TN6->(DbSkip())

				End

				If !lFirst
					oSecTarefas:Finish()
				EndIf

			EndIf

			lFirst := .T.

			//consultas
			DbSelectArea("TMJ")
			TMJ->(DbSetOrder(2))
			If TMJ->(DbSeek(xFilial("TMJ")+TM0->TM0_NUMFIC))

				oReport:IncMeter()
				While TMJ->(!Eof()) .AND. TMJ->TMJ_FILIAL == xFilial("TMJ") .AND. TMJ->TMJ_NUMFIC == TM0->TM0_NUMFIC .AND. !oReport:Cancel()

					If TMJ->TMJ_DTCONS >= MV_PAR03 .AND. TMJ->TMJ_DTCONS <= MV_PAR04
						If lFirst

							oReport:SkipLine()
							oSecCons:Init()
							oReport:ThinLine()
							oReport:PrintText(STR0026) // "Consultas"

							oReport:oFontBody := oFont1
							lFirst := .F.
						EndIf
						oSecCons:PrintLine()

					Endif
					TMJ->(DbSkip())

				Enddo
				If !lFirst
					oSecCons:Finish()
				EndIf
			Endif

			lFirst := .T.
			//Diagnosticos
			DbSelectArea("TMT")
			TMT->(DbSetOrder(3))
			If TMT->(DbSeek(xFilial("TMT")+TM0->TM0_NUMFIC))

				oReport:IncMeter()
				While TMT->(!Eof()) .AND. TMT->TMT_FILIAL == xFilial("TMT") .AND. TMT->TMT_NUMFIC == TM0->TM0_NUMFIC

					cDescAtend := ""

					If TMT->TMT_DTCONS >= MV_PAR03 .AND. TMT->TMT_DTCONS <= MV_PAR04

						//Busca os Campos
						aArea := GetArea()
						aAreaSX3 := SX3->(GetArea())
						dbSelectArea( "SX3" )
						dbSetOrder( 2 )
						For nCps := 1 To Len( aCampos )
							dbSeek( aCampos[ nCps , 1 ] )
							If NGCADICBASE( "TMT_DIASYP" , "A" , "TMT" , .F. ) .And. Len( aCampos[ nCps ] ) > 1
								cDescAtend += AllTrim( X3Titulo( aCampos[ nCps , 2 ] ) ) + ":" + CRLF
								cDescAtend += AllTrim( MsMM( TMT->&( aCampos[ nCps , 2 ] ) , 10 ) ) + CRLF
							Else
								cDescAtend += AllTrim( X3Titulo( aCampos[ nCps , 1 ] ) ) + ":" + CRLF
								If aCampos[ nCps , 1 ] == "TMT_PREART" //Pressão Arterial
									If !Empty(TMT->&( aCampos[ nCps , 1 ] ))
										cDescAtend += TMT->&( aCampos[ nCps , 1 ] )	//Campo antigo deixado para legado
									ElseIf TMT->(FieldPos("TMT_PRESIS") > 0)
										cDescAtend += cValToChar( TMT->TMT_PRESIS ) + " X " + cValToChar( TMT->TMT_PREDIS ) + CRLF//Novos campos de pressão
									EndIf
								Else
									cDescAtend += AllTrim(cValToChar( TMT->&( aCampos[ nCps , 1 ] ) ) ) + CRLF
								EndIf
							EndIf
						Next nCps
						RestArea( aAreaSX3 )
						RestArea( aArea )
						If lFirst
							oSecAtend:Init()

							oReport:oFontBody := oFont2
							oReport:SkipLine()
							oReport:ThinLine()
							oReport:PrintText(STR0070) // "Diagnósticos"
							oReport:oFontBody := oFont1
							lFirst := .F.
						EndIf

						oSecAtend:PrintLine()

					Endif

					TMT->(DbSkip())
				Enddo
				If !lFirst
					oSecAtend:Finish()
				EndIf
			Endif

			lFirst := .T.
			//Medicamentos
			DbSelectArea("TM2")
			TM2->(DbSetOrder(2))
			If TM2->(DbSeek(xFilial("TM2")+TM0->TM0_NUMFIC))
				oReport:IncMeter()
				While TM2->(!Eof()) .AND. TM2->TM2_FILIAL == xFilial("TM2") .AND. TM2->TM2_NUMFIC == TM0->TM0_NUMFIC

						If TM2->TM2_DTCONS >= MV_PAR03 .AND. TM2->TM2_DTCONS <= MV_PAR04
							If lFirst
								oSecMed:Init()
								oReport:oFontBody := oFont2
								oReport:SkipLine()
								oReport:ThinLine()
								oReport:PrintText(STR0034) // "Medicamentos"
								oReport:oFontBody := oFont1
								lFirst := .F.
							EndIf
							oSecMed:PrintLine()

						Endif

					TM2->(DbSkip())
				Enddo
				If !lFirst
					oSecMed:Finish()
				EndIf


			Endif

			//		oSecFicha:Finish()

			//		Endif

			lFirst := .T.
			//Exames
			DbSelectArea("TM5")
			TM5->(DbSetOrder(1))
			If TM5->(Dbseek(xFilial("TM5")+TM0->TM0_NUMFIC))

				oReport:IncMeter()
				While TM5->(!Eof()) .AND. TM5->TM5_FILIAL == xFilial("TM5") .AND. TM5->TM5_NUMFIC == TM0->TM0_NUMFIC .AND. !oReport:Cancel()

					iF TM5->TM5_DTPROG >= MV_PAR03 .AND. TM5->TM5_DTPROG <= MV_PAR04
						If lFirst
							oReport:oFontBody := oFont2
							oReport:SkipLine()
							oReport:ThinLine()
							oReport:PrintText(STR0018) // "Exames"
							oReport:oFontBody := oFont1

							oSecExa:Init()
							lFirst := .F.
						EndIf
						oSecExa:PrintLine()
					EndiF
					TM5->(Dbskip())
				Enddo
				If !lFirst
					oSecExa:Finish()
				EndIf

			Endif

			lFirst := .T.
			//ASO
			DbSelectArea("TMY")
			TMY->(DbSetOrder(2))
			IF TMY->(DbSeek(xFilial("TMY")+TM0->TM0_NUMFIC))


				oReport:IncMeter()
				While TMY->(!Eof())	.AND. TMY->TMY_FILIAL == xFilial("TMY") .AND. TMY->TMY_NUMFIC == TM0->TM0_NUMFIC .AND. !oReport:Cancel()

					If TMY->TMY_DTEMIS >= MV_PAR03 .AND. TMY->TMY_DTEMIS <= MV_PAR04
						If lFirst
							oSecAso:Init()

							oReport:oFontBody := oFont2
							oReport:SkipLine()
							oReport:ThinLine()
							oReport:PrintText(STR0040) // "ASO"
							oReport:oFontBody := oFont1

							lFirst := .F.
						EndIf
						oSecAso:PrintLine()

					Endif


					TMY->(DbSkip())
				Enddo
				If !lFirst
					oSecAso:Finish()
				EndIf

			Endif

			lFirst := .T.
			//Atestados
			DbSelectArea("TNY")
			TNY->(DbSetOrder(1))
			IF TNY->(DbSeek(xFilial("TNY")+TM0->TM0_NUMFIC))

				oReport:IncMeter()
				While TNY->TNY_FILIAL == xFilial("TNY") .AND. TNY->TNY_NUMFIC == TM0->TM0_NUMFIC .AND. !oReport:Cancel()

					If  TNY->TNY_DTINIC >= MV_PAR03 .AND. TNY->TNY_DTINIC <= MV_PAR04
						If lFirst
							oSecAtest:Init()

							oReport:oFontBody := oFont2
							oReport:SkipLine()
							oReport:ThinLine()
							oReport:PrintText(STR0044) // "Atestados"
							oReport:oFontBody := oFont1
							lFirst := .F.
						EndIf
						oSecAtest:PrintLine()
					Endif

					TNY->(Dbskip())
				Enddo
				If !lFirst
					oSecAtest:Finish()
				EndIf

			Endif

			lFirst := .T.
			//Atendimento de Enfermagem
			DbSelectArea("TL5")
			TL5->(DbSetOrder(1))
			IF	TL5->(DbSeek(xFilial("TL5")+TM0->TM0_NUMFIC))

				oReport:IncMeter()
				While TL5->TL5_FILIAL == xFilial("TL5").AND. TL5->TL5_NUMFIC == TM0->TM0_NUMFIC  .AND. !oReport:Cancel()

					If TL5->TL5_DTATEN >= MV_PAR03 .AND. TL5->TL5_DTATEN <= MV_PAR04
						If lFirst
							oSecEnfer:Init()

							oReport:oFontBody := oFont2
							oReport:SkipLine()
							oReport:ThinLine()
							oReport:PrintText(STR0050) // "Atendimentos de Enfermagem"
							oReport:oFontBody := oFont1
							lFirst := .F.

						EndIf
						oSecEnfer:PrintLine()
					Endif
					TL5->(Dbskip())
				Enddo
				If !lFirst
					oSecEnfer:Finish()
				EndIf

			Endif

			lFirst := .T.
			//Medicamentos
			DbSelectArea("TY3")
			TY3->(DbSetOrder(1))	//TY3_FILIAL+TY3_NUMFIC+DTOS(TY3_DTATEN)+TY3_HRATEN+TY3_INDICA+TY3_CODMED
			IF	TY3->(DbSeek(xFilial("TY3")+TM0->TM0_NUMFIC))

				oReport:IncMeter()
				While TY3->TY3_FILIAL == xFilial("TY3").AND. TY3->TY3_NUMFIC == TM0->TM0_NUMFIC  .AND. !oReport:Cancel()

					If TY3->TY3_DTATEN >= MV_PAR03 .AND. TY3->TY3_DTATEN <= MV_PAR04
						If lFirst
							oSecMedica:Init()

							oReport:oFontBody := oFont2
							oReport:SkipLine()
							oReport:ThinLine()
							oReport:PrintText(STR0113) //"Medicamentos do Atendimento Enfermagem"
							oReport:oFontBody := oFont1
							lFirst := .F.

						EndIf
						oSecMedica:PrintLine()
					Endif
					TY3->(Dbskip())
				Enddo
				If !lFirst
					oSecMedica:Finish()
				EndIf

			Endif

			lFirst := .T.
			//Doencas
			DbSelectArea("TNA")
			TNA->(DbSetOrder(1))
			IF TNA->(DbSeek(xFilial("TNA")+TM0->TM0_NUMFIC))

				oReport:IncMeter()
				While TNA->(!Eof()) .AND. TNA->TNA_NUMFIC == TM0->TM0_NUMFIC .AND. !oReport:Cancel()

					If TNA->TNA_DTINIC <= MV_PAR04 .AND. ( Empty(TNA->TNA_DTFIM) .Or. TNA->TNA_DTFIM >= MV_PAR03 )
						If lFirst
							oSecDoenca:Init()

							oReport:oFontBody := oFont2
							oReport:SkipLine()
							oReport:ThinLine()
							oReport:PrintText(STR0054) // "Doenças"
							oReport:oFontBody := oFont1
							lFirst := .F.
						EndIf
						oSecDoenca:PrintLine()

					Endif


					TNA->(DbSkip())
				Enddo
				If !lFirst
					oSecDoenca:Finish()
				EndIf

			Endif

			lFirst := .T.
			//Restricoes
			DbSelectArea("TMF")
			TMF->(DbSetOrder(1))
			IF TMF->(DbSeek(xFilial("TMF")+TM0->TM0_NUMFIC))

				oReport:IncMeter()
				While TMF->(!Eof()) .AND. TMF->TMF_NUMFIC == TM0->TM0_NUMFIC .AND. !oReport:Cancel()

					If TMF->TMF_DTINIC <= MV_PAR04 .AND. ( Empty(TMF->TMF_DTFIM) .Or. TMF->TMF_DTFIM >= MV_PAR03 )
						If lFirst
							oSecRestri:Init()

							oReport:oFontBody := oFont2
							oReport:SkipLine()
							oReport:ThinLine()
							oReport:PrintText(STR0055) // "Restrições"
							oReport:oFontBody := oFont1
							lFirst := .F.
						EndIf
						oSecRestri:PrintLine()

					Endif

					TMF->(DbSkip())
				Enddo
				If !lFirst
					oSecRestri:Finish()
				EndIF
			Endif

			lFirst := .T.
			//Vacinas
			DbSelectArea("TL9")
			TL9->(DbSetOrder(1))
			IF	TL9->(DbSeek(xFilial("TL9")+TM0->TM0_NUMFIC))

				oReport:IncMeter()
				While TL9->TL9_FILIAL == xFilial("TL9").AND. TL9->TL9_NUMFIC == TM0->TM0_NUMFIC .AND. !oReport:Cancel()

					IF TL9->TL9_DTPREV >= MV_PAR03 .AND. TL9->TL9_DTPREV <= MV_PAR04
						If lFirst
							oSecVacina:Init()

							oReport:oFontBody := oFont2
							oReport:SkipLine()
							oReport:ThinLine()
							oReport:PrintText(STR0059) // "Vacinas"
							oReport:oFontBody := oFont1
							lFirst := .F.
						EndIf
						oSecVacina:PrintLine()
					Endif
					TL9->(Dbskip())
				Enddo
				If !lFirst
					oSecVacina:Finish()
				EndIf

			Endif

			//demmais


			oSecFicha:Finish()
			oReport:oFontBody := oFont2
			oReport:SkipLine()
			oReport:FatLine()
			oReport:SkipLine()

			If mv_par05 == 1
				oReport:EndPage()

				oReport:oFontBody := oFont3

				oReport:PrintText(SPACE(1)+STR0079) // "TERMO DE RECEBIMENTO"
				oReport:SkipLine()
				oReport:SkipLine()
				oReport:oFontBody := oFont2

				PSWORDER(1)
				PSWSEEK(cCodUsr)
				oReport:PrintText(SPACE(1)+STR0080+If(!Empty(AllTrim(PSWRET()[1][4])),AllTrim(PSWRET()[1][4]),AllTrim(PSWRET()[1][2]))+STR0088+Alltrim(DtoC(mv_par03))+" "+STR0081+" "+Alltrim(DtoC(mv_par04))+" "+;
						STR0082+" "+Alltrim(TM0->TM0_NUMFIC)+" "+STR0083+" "+Alltrim(TM0->TM0_NOMFIC)+".")
				oReport:SkipLine()
				oReport:SkipLine()
				oReport:SkipLine()

				oReport:PrintText(" ______________________________________________________________ , ____________________________________________, _____________________")
				oReport:PrintText("                        "+STR0084+"                                                "+STR0085+"                              "+STR0086+"       ")
				cNomFunc := AllTrim( NGSEEK( "SRA" , TM0->TM0_MAT , 1 , "RA_NOME" , TM0->TM0_FILFUN ) )
				nPosicNome := Len( cNomFunc )
				nPosicAtu  := 30 - ( nPosicNome / 2 ) + 1
				oReport:PrintText(" " + Space( nPosicAtu ) + cNomFunc )
				oReport:EndPage()

			Endif

			TM0->(DbSkip())

		Enddo

	Endif

Return

//---------------------------------------------------------------------
/*/{Protheus.doc} MDTR795BOX
Retorna informações de campos do tipo box para impressão


@param cCampo - Campo, com alias e ponteiro, a ser pesquisado a descrição do box
@return cRet  - Descrição do box
@author Thiago Santos
@since 08/05/2013
@version P11
@return cRet - Descrição referente ao valor do campo
@sample MDTR795BOX("TM0->TM0_SANGUE")
/*/
//---------------------------------------------------------------------

Static Function MDTR795BOX(cCampo)
Local cRet := ""
Local aBox := {}
Local cValor := ""
Local cTemp  := ""

DbSelectArea("SX3")
SX3->(DbSetOrder(2))
If SX3->(DbSeek(SUBSTR(cCampo,6,LEN(cCampo)-5)))

	aBox := STRTOKARR(Alltrim(X3CBox()),";")
	cValor := &cCampo


	If AScan(aBox,{|x| cValor+"=" $ x } ) > 0

		cTemp := Alltrim(aBox[AScan(aBox,{|x| cValor+"=" $ x } )] )

		cRet := SUBSTR(cTemp,At("=",cTemp)+1,len(cTemp) - At("=",cTemp))

	Endif

Endif

Return cRet

//---------------------------------------------------------------------
/*/{Protheus.doc} MDTR795PER
Valida os campos de pergunta para o relatório

@param nParam  - Número do parâmetro (MV)
@author Thiago Henrique dos Santos
@since 10/05/2013
@version P11
@return lRet - Lógico, .T. se valido, .F. caso contrário
/*/
//---------------------------------------------------------------------
Function MDTR795PER(nParam)
Local lRet := .F.
Local lExist := .T.

If nParam == 1

	lExist := IIf(empty(mv_par01),.t.,ExistCpo('TM0',mv_par01))
	lRet := lExist .AND. IIF(!Empty(mv_par02),mv_par02 >= mv_par01,.T.)

	If !lRet .AND. lExist

		Help( " ",1, 'MDTR79501')

	Endif


ElseIf nParam == 2

	lRet := mv_par02 >= mv_par01

	If lRet

		DbSelectArea("TM0")
		TM0->(DbSetOrder(1))

		lRet := TM0->(DbSeek(xFilial("TM0")+mv_par02)) .OR. mv_par02 == Replicate("Z",TamSx3("TM0_NUMFIC")[1])

	Endif

	If !lRet

		Help( " ",1, 'MDTR79501')

	Endif

ElseIf nParam == 3

	lRet := !Empty(mv_par03) .AND. IIF(!Empty(mv_par04),mv_par04 >= mv_par03,.T.)

	If !lRet

		Help( " ",1, 'MDTR79501')

	Endif

ElseIf nParam == 4

	lRet := mv_par04 >= mv_par03

	If !lRet

		Help( " ",1, 'MDTR79501')

	Endif

Endif

Return lRet
