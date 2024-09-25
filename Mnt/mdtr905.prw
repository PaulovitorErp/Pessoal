#INCLUDE "MDTR905.ch"
#INCLUDE "Protheus.ch"

//---------------------------------------------------------------------
/*/{Protheus.doc} MDTR905
Relatório de Cadastro de Vacinas

@author Pedro Henrique Soares de Souza
@since 19/03/2013
@return
/*/
//---------------------------------------------------------------------
Function MDTR905()

	Local aNGBEGINPRM	:= NGBEGINPRM( )
	Local aPerg		:= {}
	Local aArea		:= GetArea()
	Private cPerg		:= "MDTR905"
	Private Titulo	:= STR0004 //"Relatório de Cadastro de Vacinas"

	If !AliasInDic("TKF") .Or. !AliasInDic("TKG")  .Or. !AliasInDic("TKH") .Or. !NGCADICBASE('TL6_SEXO',"A",'TL6',.F.)
		NGINCOMPDIC("UPDMDT27","SDHLC3",.F.)
		Return .F.
	EndIf

	//----------------------------------------------------------------
	//  Variaveis utilizadas para parametros!
	//  mv_par01     De Vacina
	//  mv_par02     Até Vacina
	//  mv_par03     Listar Centro de Custo (Sim/Não)
	//  mv_par04     Listar Função (Sim/Não)
	//  mv_par05     Listar Funcionários (Sim/Não)
	//----------------------------------------------------------------

	If FindFunction("TRepInUse") .And. TRepInUse()
		oReport := ReportDef()
		oReport:SetLandscape()
		oReport:PrintDialog()
	Else
		MDTR905R3()
	EndIf

	RestArea(aArea)
	NGRETURNPRM(aNGBEGINPRM)

Return

//---------------------------------------------------------------------
/*/{Protheus.doc} MDTR905R3
Imprime relatório no modelo padrão

@author Pedro Henrique Soares de Souza
@since 28/03/2013
@return
/*/
//---------------------------------------------------------------------

Static Function MDTR905R3()

	Local wnrel      := "MDTR905"
	Local cString    := "TL6"
	Local cDesc1     := STR0001 //"Relatório de Cadastro de Vacinas"
	Local cDesc2     := ""
	Local cDesc3     := ""
	Private aReturn  := {STR0002, 1,STR0004, 1, 2, 1, "",1 } //"Administração" , "relatório de cadastro de vacinas"
	Private nLastKey := 0
	private tamanho  := "G"
	Private nomeprog := "MDTR905"

	pergunte(cPerg,.F.)

	//----------------------------------------------------------------
	//  Variaveis utilizadas para parametros!
	//  mv_par01     De Vacina
	//  mv_par02     Até Vacina
	//  mv_par03     Listar Centro de Custo (Sim/Não)
	//  mv_par04     Listar Função (Sim/Não)
	//  mv_par05     Listar Funcionários (Sim/Não)
	//----------------------------------------------------------------

	wnrel:="MDTR905"
	WnRel :=SetPrint(cString,WnRel,cPerg,titulo,cDesc1,cDesc2,cDesc3,.F.,"",,tamanho)

	If nLastKey == 27
		Set Filter to
		Return
	Endif

	SetDefault(aReturn,cString)

	If nLastKey == 27
		Set Filter to
		Return
	Endif

RptStatus({|lEnd| MDTRPRINT(@lEnd,wnRel,titulo,tamanho)},titulo)

Return

//---------------------------------------------------------------------
/*/{Protheus.doc} ReportDef
Relatório de Cadastro de Vacinas

@author Pedro Henrique Soares de Souza
@since 28/03/2013
@return
/*/
//---------------------------------------------------------------------
Static Function ReportDef()

	Local oSection1
	Local oSection2
	Local oSection3
	Local oSection4
	Local oReport

	//--------------------------------------------------------------------------
	// Criacao do componente de impressão                                      |
	//                                                                         |
	// TReport():New                                                           |
	// ExpC1 : Nome do relatorio                                               |
	// ExpC2 : Titulo                                                          |
	// ExpC3 : Pergunte                                                        |
	// ExpB4 : Bloco de codigo que sera executado na confirmacao da impressao  |
	// ExpC5 : Descricao                                                       |
	//--------------------------------------------------------------------------

	oReport := TReport():New("MDTR905",Titulo,cPerg,{|oReport| ReportPrint(oReport)},STR0001)   //"Relatório de Cadastro de Vacinas" ## "Relatório de Cadastro de Vacinas"

	//----------------------------------------------------------------
	//  Verifica as perguntas selecionadas
	//----------------------------------------------------------------
	//  Variaveis utilizadas para parametros!
	//
	//  mv_par01     De Vacina
	//  mv_par02     Ate Vacina
	//  mv_par03     Listar Centro de Custo (Sim/Não)
	//  mv_par04     Listar Função (Sim/Não)
	//  mv_par05     Listar Funcionários (Sim/Não)
	//----------------------------------------------------------------

	Pergunte(oReport:uParam,.F.)

	oSection1 := TRSection():New (oReport,"Vacina",{"TL6"} )
	TRCell():New(oSection1, "TL6_VACINA","TL6",STR0003, "@!", Len(TL6->TL6_VACINA)+10,,) //"Cod. Vacina"
	TRCell():New(oSection1, "SUBSTR(TL6->TL6_NOMVAC, 1, 20)","TL6",STR0019, "@!",30,,) //"Nome da Vacina"
	TRCell():New(oSection1, "SUBSTR(TL6->TL6_DESVAC, 1, 40)","TL6",STR0020,"@!", 60,,) //"Descrição"
	TRCell():New(oSection1, "NGRETSX3BOX('TL6_SEXO',TL6->TL6_SEXO)","TL6",STR0021, "@!", 15,,) //"Sexo"
	TRCell():New(oSection1, "NGRETSX3BOX('TL6_CC',TL6->TL6_CC)","TL6",STR0022, "@!", 20,,) //"Centro de Custo"
	TRCell():New(oSection1, "NGRETSX3BOX('TL6_FUNC',TL6->TL6_FUNC)","TL6",STR0023, "@!", 10,,) //"Função"
	TRCell():New(oSection1, "NGRETSX3BOX('TL6_FNCR',TL6->TL6_FNCR)","TL6",STR0024, "@!", 10,,) //"Funcionário"

	oSection2 := TRSection():New (oReport,"Centro de Custo",{"CTT"},,,,,,,,,,4 )
	TRCell():New(oSection2, "TKF->TKF_CODCC","TKF",STR0028, "@!",Len(TKF->TKF_CODCC) + 16 ,,) //"C. Custo "
	TRCell():New(oSection2, "AllTrim(NGSEEK('CTT', TKF->TKF_CODCC ,1, 'CTT->CTT_DESC01'))","TKF",STR0025,"@!", 40,,) //"Descrição"

	oSection3 := TRSection():New (oReport,"Funções",{"SRJ"},,,,,,,,,,4 )
	TRCell():New(oSection3, "TKG->TKG_CODFUN","TKG",STR0029, "@!",Len(TKG->TKG_CODFUN) + 16 ,,) //"Funções "
	TRCell():New(oSection3, "AllTrim(NGSEEK('SRJ', TKG->TKG_CODFUN ,1, 'SRJ->RJ_DESC'))","TKG",STR0026, "@!", 20,,) //"Descrição"

	oSection4 := TRSection():New (oReport,"Funcionários",{"SRA"},,,,,,,,,,4 )
	TRCell():New(oSection4, "TKH->TKH_MATFUN","TKH",STR0030, "@!", Len(TKH->TKH_MATFUN)+ 16 ,,) //"Matrícula"
	TRCell():New(oSection4, "AllTrim(NGSEEK('SRA', TKH->TKH_MATFUN ,1, 'SRA->RA_NOME'))","TKH",STR0027, "@!", 30,,) //"Nome"

Return oReport

//---------------------------------------------------------------------
/*/{Protheus.doc} ReportPrint
Imprime relatório personalizado

@author Pedro Henrique Soares de Souza
@since 28/03/2013
@return
/*/
//---------------------------------------------------------------------
Static Function ReportPrint(oReport)

	Local oSection1 := oReport:Section(1)
	Local oSection2 := oReport:Section(2)
	Local oSection3 := oReport:Section(3)
	Local oSection4 := oReport:Section(4)
	Local lGera 	  := .F.


	If oReport:Cancel()
		Return .T.
	EndIf

	oReport:SetMeter(RecCount())

	dbSelectArea("TL6")
	dbSetOrder(1)
	dbSeek(xFilial("TL6")+MV_PAR01,.T.)

	While !Eof() .And. TL6->TL6_FILIAL == xFilial("TL6") .And. TL6->TL6_VACINA <= MV_PAR02

		lGera:=.T.
		oSection1:Init()
		oSection1:PrintLine()

		If MV_PAR03 == 2
			If TL6->TL6_CC == "1"

				oSection2:Init()
				oReport:SkipLine()
				dbSelectArea("TKF")
				dbSetOrder(01)
				dbSeek(xFilial("TKF")+TL6->TL6_VACINA)
				While !Eof() .And. TL6->TL6_VACINA == TKF->TKF_CODVAC

					oSection2:PrintLine()
					dbSelectArea("TKF")
					dbSkip()

				EndDo
				oSection2:Finish()
			Endif
		EndIf

		If MV_PAR04 == 2
			If TL6->TL6_FUNC == "1"

				oReport:SkipLine()
				oSection3:Init()
				dbSelectArea("TKG")
				dbSetOrder(01)
				dbSeek(xFilial("TKG")+TL6->TL6_VACINA)
				While !Eof() .And. TL6->TL6_VACINA == TKG->TKG_CODVAC

					oSection3:PrintLine()
					dbSelectArea("TKG")
					dbSkip()

				EndDo
				oSection3:Finish()
			Endif
		EndIf

		If MV_PAR05 == 2
			If TL6->TL6_FNCR == "1"

				oReport:SkipLine()
				oSection4:Init()
				dbSelectArea("TKH")
				dbSetOrder(01)
				dbSeek(xFilial("TKH")+TL6->TL6_VACINA)
				While !Eof() .And. TL6->TL6_VACINA == TKH->TKH_CODVAC

					oSection4:PrintLine()
					dbSelectArea("TKH")
					dbSkip()

				EndDo
				oSection4:Finish()
			EndIf
		EndIf

		oReport:SkipLine()
		oSection1:Finish()
		dbSelectArea("TL6")
		dbSkip()

	End

	If !lGera
		MsgInfo(STR0017,STR0018) //"Não existem dados para montar o relatório!"###"ATENÇÃO"
		Return .F.
	EndIf


Return .T.


//---------------------------------------------------------------------
/*/{Protheus.doc} MDTRPRINT ()
Função para imprimir o relatório padrão

@author Pedro Henrique Soares de Souza
@since 28/03/2013
@return
/*/
//---------------------------------------------------------------------

Static Function MDTRPRINT(lEND,WNREL,TITULO,TAMANHO)

	Local cRODATXT := ""
	Local nCNTIMPR := 0
	Local lGera 	 := .F.

	Private li := 80 ,m_pag := 1

	nTIPO  := If(aReturn[4]==1,15,18)
	CABEC1 := STR0012 //"Cod. Vacina     Nome Da Vacina        Descrição                                 Sexo         Centro de Custo  Função  Funcionário"
	CABEC2 := STR0013 //""

	/*/
	0         1         2         3         4         5         6         7         8         9         0         1         2         3
	01234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890
	***********************************************************************************************************************************
	Cod. Vacina     Nome Da Vacina        Descrição                                 Sexo         Centro de Custo  Função  Funcionário
	***********************************************************************************************************************************

	XX              XXXXXXXXXXXXXXXXXXXX  XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX  XXXXXXXXXX   XXX              XXX     XXX

	                C. Custo: 100100101 - Produção
	                          100100201 - Administração
	                          100100305 - Manutenção

	                Funções: 0041 - Auxiliar de Produção
	                         0345 - Almoxarife

	                Funcionários: 000001 - Devil Mattiollo
	                              000002 - Cássio Almeida

	/*/

	dbSelectArea("TL6")
	dbSetOrder(01)
	dbSeek(xFilial("TL6")+MV_PAR01,.T.)
	SetRegua(LastRec())
	While !Eof() .And. TL6->TL6_FILIAL == xFilial("TL6") .And.;
		TL6->TL6_VACINA <= MV_PAR02

	 	IncRegua()
		lGera:=.T.
		NGSOMALI(58)

		@LI,000 Psay TL6->TL6_VACINA					Picture "@!"
		@LI,016 Psay SUBSTR(TL6->TL6_NOMVAC, 1, 20)	Picture "@!"
		@LI,038 Psay SUBSTR(TL6->TL6_DESVAC, 1, 40)	Picture "@!"
		@LI,080 Psay NGRETSX3BOX("TL6_SEXO",TL6->TL6_SEXO)	Picture "@!"
		@LI,093 Psay NGRETSX3BOX("TL6_CC",TL6->TL6_CC)		Picture "@!"
		@LI,110 Psay NGRETSX3BOX("TL6_FUNC",TL6->TL6_FUNC)	Picture "@!"
		@LI,118 Psay NGRETSX3BOX("TL6_FNCR",TL6->TL6_FNCR)	Picture "@!"

		If MV_PAR03 == 2
			If TL6->TL6_CC == "1"

				dbSelectArea("TKF")
				dbSetOrder(01)
				If dbSeek(xFilial("TKF")+TL6->TL6_VACINA)

					NGSOMALI(58)

					@LI,016 Psay STR0014  //"C. Custo: "

					While !Eof() .And. TL6->TL6_VACINA == TKF->TKF_CODVAC

						@LI,026 Psay TKF->TKF_CODCC + " - " + AllTrim(NGSEEK("CTT", TKF->TKF_CODCC ,1, "CTT->CTT_DESC01")) Picture "@!"

						NGSOMALI(58)
						dbSelectArea("TKF")
						dbSkip()
					EndDo
				Endif
			EndIf
		EndIf

		If MV_PAR04 == 2
			If TL6->TL6_FUNC == "1"

				dbSelectArea("TKG")
				dbSetOrder(01)
				If dbSeek(xFilial("TKG")+TL6->TL6_VACINA)

					NGSOMALI(58)

					@LI,016 Psay STR0015  //"Funções: "

				 	While !Eof() .And. TL6->TL6_VACINA == TKG->TKG_CODVAC

						@LI,025 Psay TKG->TKG_CODFUN+ " - " + AllTrim(NGSEEK("SRJ", TKG->TKG_CODFUN ,1, "SRJ->RJ_DESC")) Picture "@!"

						NGSOMALI(58)
						dbSelectArea("TKG")
						dbSkip()
					EndDo
				Endif
			EndIf
		EndIf

		If MV_PAR05 == 2
			If TL6->TL6_FNCR == "1"

				dbSelectArea("TKH")
				dbSetOrder(01)
				If dbSeek(xFilial("TKH")+TL6->TL6_VACINA)

					NGSOMALI(58)

					@LI,016 Psay STR0016  //"Funcionários: "

					While !Eof() .And. TL6->TL6_VACINA == TKH->TKH_CODVAC

						@LI,030 Psay TKH->TKH_MATFUN + " - " + AllTrim(NGSEEK("SRA", TKH->TKH_MATFUN ,1, "SRA->RA_NOME")) Picture "@!"

						NGSOMALI(58)
						dbSelectArea("TKH")
						dbSkip()
					EndDo
				EndIf
			EndIf
		EndIf

		NGSOMALI(58)

		dbSelectArea("TL6")
		dbSkip()

	EndDo

	If !lGera
		MsgInfo(STR0017,STR0018) //"Não existem dados para montar o relatório!"###"ATENÇÃO"
		Return .F.
	EndIf

	Roda(nCntImpr,cRodaTxt,Tamanho)

	//----------------------------------------------------------------
	// Devolve a condicao original do arquivo principal
	//----------------------------------------------------------------

	RetIndex("TL6")
	Set Filter To
	Set device to Screen
	If aReturn[5] = 1
	   Set Printer To
	   dbCommitAll()
	   OurSpool(wnrel)
	EndIf
	MS_FLUSH()

Return .T.