#INCLUDE "MNTR682.ch"
#INCLUDE "PROTHEUS.CH"
#INCLUDE "RWMAKE.CH"

#Define _nVersao 001	//Versao do Fonte

//---------------------------------------------------------------------
/*/{Protheus.doc} MNTR682
Relatorio de Planejamentos de Mobilizacao e Desmobilizacao de Equipamentos (Bens).                                   

@author Wagner S. de Lacerda
@since 16/08/2011
@return 
/*/
//---------------------------------------------------------------------
Function MNTR682()

	Local aNGBeginPrm := NGBeginPrm(_nVersao)

	Private cCadastro := OemToAnsi(STR0001) //"Relatório de Desmobilização"
	Private cPrograma := "MNTR682"
	Private cPerg     := "MNTR682"
	Private cGrupo    := ""
	Private aZEMPS    := {} //Variavel obrigatoria para as Perguntas De/Ate Empresa/Filial

	Private c200EmpOri := cEmpAnt //Armazena a Empresa Original
	Private c200FilOri := cFilAnt //Armazena a Filial Original

	Private nSMOCODIGO  := Len(SM0->M0_CODIGO)
	Private nSM0SizeFil := FWSizeFilial()
	Private nT6CODFAMI  := TamSX3("T6_CODFAMI")[1]
	Private nTQRTIPMOD  := TamSX3("TQR_TIPMOD")[1]

	/* Variaveis do Relatorio */
	Private cNomeProg := cPrograma
	Private nLimite   := 132
	Private cTamanho  := "M"
	Private aReturn   := {STR0002,1,STR0003,1,2,1,"",1} //"Zebrado"###"Administração"
	Private nTipo     := 0
	Private nLastKey  := 0
	Private cTitulo   := cCadastro
	Private cDesc1    := OemToAnsi(STR0004) //"Imprime as datas previstas de desmobilização dos equipamentos "
	Private cDesc2    := OemToAnsi(STR0005) //"de acordo com os planejamentos das obras."
	Private cDesc3    := ""
	Private cString   := "TVY"
	/* - */

	Private aDadosImp  := {}
	Private cTitPagina := ""
	Private nProcMes   := 0
	Private nProcAno   := 0

	If !MntCheckCC(cPrograma)
		Return .F.
	EndIf

	Inclui := .F.
	Altera := .F.

	//-------------------------------------------------------------------------
	// Parametrizacao da Consulta:
	//
	// MV_PAR01 - De Empresa/Filial ?
	// MV_PAR02 - Ate Empresa/Filial ?
	// MV_PAR03 - De Familia ?
	// MV_PAR04 - Ate Familia ?
	// MV_PAR05 - De Modelo ?
	// MV_PAR06 - Ate Modelo ?
	// MV_PAR07 - De Data ?
	// MV_PAR08 - Ate Data ?
	// MV_PAR09 - Tabulacao ?
	//-------------------------------------------------------------------------

	If FindFunction("TRepInUse") .And. TRepInUse()
		Private oReport, oSection1, oSection2, oSection3, oSection4
		Private nPROCDados, nPROCDesmo
	
		If Pergunte(cPerg,.T.)
			// Interface de impressao
			oReport := fReportDef()
			oReport:SetPortrait()
			oReport:PrintDialog()
		EndIf
	Else
		Pergunte(cPerg,.F.)
		MNTR682IM()
	EndIf

	NGReturnPrm(aNGBeginPrm)

Return .T.

//---------------------------------------------------------------------
/*/{Protheus.doc} fReportDef
Define o Relatorio Personalizavel.                                    

@author Wagner S. de Lacerda
@since 18/08/2011
@return 
/*/
//---------------------------------------------------------------------

Static Function fReportDef()

Local oBreak

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Criacao do componente de impressao                                      ³
//³                                                                        ³
//³TReport():New                                                           ³
//³ExpC1 : Nome do relatorio                                               ³
//³ExpC2 : Titulo                                                          ³
//³ExpC3 : Pergunte                                                        ³
//³ExpB4 : Bloco de codigo que sera executado na confirmacao da impressao  ³
//³ExpC5 : Descricao                                                       ³
//³                                                                        ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
oReport := TReport():New(cNomeProg, cCadastro, ,{|oReport| fReportPrt()}, cDesc1+cDesc2+cDesc3)

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Criacao da secao utilizada pelo relatorio                               ³
//³                                                                        ³
//³TRSection():New                                                         ³
//³ExpO1 : Objeto TReport que a secao pertence                             ³
//³ExpC2 : Descricao da seçao                                              ³
//³ExpA3 : Array com as tabelas utilizadas pela secao. A primeira tabela   ³
//³        sera considerada como principal para a seção.                   ³
//³ExpA4 : Array com as Ordens do relatório                                ³
//³ExpL5 : Carrega campos do SX3 como celulas                              ³
//³        Default : False                                                 ³
//³ExpL6 : Carrega ordens do Sindex                                        ³
//³        Default : False                                                 ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Criacao da celulas da secao do relatorio                                ³
//³                                                                        ³
//³TRCell():New                                                            ³
//³ExpO1 : Objeto TSection que a secao pertence                            ³
//³ExpC2 : Nome da celula do relatório. O SX3 será consultado              ³
//³ExpC3 : Nome da tabela de referencia da celula                          ³
//³ExpC4 : Titulo da celula                                                ³
//³        Default : X3Titulo()                                            ³
//³ExpC5 : Picture                                                         ³
//³        Default : X3_PICTURE                                            ³
//³ExpC6 : Tamanho                                                         ³
//³        Default : X3_TAMANHO                                            ³
//³ExpL7 : Informe se o tamanho esta em pixel                              ³
//³        Default : False                                                 ³
//³ExpB8 : Bloco de código para impressao.                                 ³
//³        Default : ExpC2                                                 ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

/* Exemplo de Impressao

Se MV_PAR09 == 1 (Por Mês)

          1         2         3         4         5         6         7         8         9         10        11        12        13 
0123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012
*************************************************************************************************************************************
                                                                                                                                     
MES            ANO                                                                                                                   
_____________________________________________________________________________________________________________________________________
XXXXXXXXXX     9999                                                                                                                  
                                                                                                                                     
Família        Nome da Família          Modelo         Nome do Modelo           Capacidade Produtiva     Unidade                     
_____________________________________________________________________________________________________________________________________
XXXXXXXXXX     XXXXXXXXXXXXXXXXXXXX     XXXXXXXXXX     XXXXXXXXXXXXXXXXXXXX           999.999.999,99     XXXXX                       
                                                                                                                                     
_____________________________________________________________________________________________________________________________________
               Empresa             Nome da Empresa          Filial              Nome da Filial              Data         Quantidade  
               XXXXXXXXXXXXXXX     XXXXXXXXXXXXXXXXXXXX     XXXXXXXXXXXXXXX     XXXXXXXXXXXXXXXXXXXX     99/99/9999         999.999  
               XXXXXXXXXXXXXXX     XXXXXXXXXXXXXXXXXXXX     XXXXXXXXXXXXXXX     XXXXXXXXXXXXXXXXXXXX     99/99/9999         999.999  
               XXXXXXXXXXXXXXX     XXXXXXXXXXXXXXXXXXXX     XXXXXXXXXXXXXXX     XXXXXXXXXXXXXXXXXXXX     99/99/9999         999.999  
                                                                                                                                     
Sub Total                                                                                                                            
_____________________________________________________________________________________________________________________________________
                                                                                                                        999.999.999  
                                                                                                                                     
TOTAL DO MÊS                                                                                                                         
_____________________________________________________________________________________________________________________________________
                                                                                                                    999.999.999.999  

Se MV_PAR09 == 2 (Por Família)

          1         2         3         4         5         6         7         8         9         10        11        12        13 
0123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012
*************************************************************************************************************************************
                                                                                                                                     
FAMILIA        NOME                                                                                                                  
_____________________________________________________________________________________________________________________________________
XXXXXXXXXX     XXXXXXXXXXXXXXXXXXXX                                                                                                  
                                                                                                                                     
Modelo         Nome do Modelo           Capacidade Produtiva     Unidade                                                             
_____________________________________________________________________________________________________________________________________
XXXXXXXXXX     XXXXXXXXXXXXXXXXXXXX           999.999.999,99     XXXXX                                                               
                                                                                                                                     
               Mês            Ano                                                                                                    
_____________________________________________________________________________________________________________________________________
               XXXXXXXXXX     9999                                                                                                   
                                                                                                                                     
_____________________________________________________________________________________________________________________________________
               Empresa             Nome da Empresa          Filial              Nome da Filial              Data         Quantidade  
               XXXXXXXXXXXXXXX     XXXXXXXXXXXXXXXXXXXX     XXXXXXXXXXXXXXX     XXXXXXXXXXXXXXXXXXXX     99/99/9999         999.999  
               XXXXXXXXXXXXXXX     XXXXXXXXXXXXXXXXXXXX     XXXXXXXXXXXXXXX     XXXXXXXXXXXXXXXXXXXX     99/99/9999         999.999  
               XXXXXXXXXXXXXXX     XXXXXXXXXXXXXXXXXXXX     XXXXXXXXXXXXXXX     XXXXXXXXXXXXXXXXXXXX     99/99/9999         999.999  
                                                                                                                                     
Sub Total                                                                                                                            
_____________________________________________________________________________________________________________________________________
                                                                                                                        999.999.999  
                                                                                                                                     
TOTAL DA FAMILIA                                                                                                                     
_____________________________________________________________________________________________________________________________________
                                                                                                                    999.999.999.999  
*/

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Por Mes     ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If MV_PAR09 == 1
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Section1: Mes/Ano          ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	oSection1 := TRSection():New(oReport,STR0011,{}) //"Mês/Ano"
		TRCell():New(oSection1, "MES", "", STR0012, "@!", 20, .T./*lPixel*/,{|| fGetMes(nProcMes) }) //"MÊS"
		TRCell():New(oSection1, STR0013, "", "ANO", "@!", 20, .T./*lPixel*/,{|| cValToChar(nProcAno) }) //"ANO"
		
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Section2: Familia e Modelo ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	oSection2 := TRSection():New(oReport,STR0014,{}) //"Família e Modelo"
		TRCell():New(oSection2, "CODFAM", "", STR0015             , "@!"               , 10, .T./*lPixel*/,{|| aDadosImp[nPROCDados][1] }) //"Família"
		TRCell():New(oSection2, "NOMFAM", "", STR0016     , "@!"               , 20, .T./*lPixel*/,{|| aDadosImp[nPROCDados][2] }) //"Nome da Família"
		TRCell():New(oSection2, "CODMOD", "", STR0017              , "@!"               , 10, .T./*lPixel*/,{|| aDadosImp[nPROCDados][3] }) //"Modelo"
		TRCell():New(oSection2, "NOMMOD", "", STR0018      , "@!"               , 20, .T./*lPixel*/,{|| aDadosImp[nPROCDados][4] }) //"Nome do Modelo"
		TRCell():New(oSection2, "CAPPRO", "", STR0019, "@E 999,999,999.99", 20, .T./*lPixel*/,{|| aDadosImp[nPROCDados][5] }) //"Capacidade Produtiva"
		TRCell():New(oSection2, "UNICAP", "", STR0020             , "@!"               , 20, .T./*lPixel*/,{|| aDadosImp[nPROCDados][6] }) //"Unidade"
		
		oSection2:Cell("CAPPRO"):SetHeaderAlign("RIGHT")
		
		oSection2:nLeftMargin := 05
		
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Section3: Desmobilizacoes  ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	oSection3 := TRSection():New(oReport,STR0021,{}) //"Desmobilizações"
		TRCell():New(oSection3, "CODEMP", "", STR0022             , "@!"        , 15, .T./*lPixel*/,{|| aDadosImp[nPROCDados][7][nPROCDesmo][1] }) //"Empresa"
		TRCell():New(oSection3, "NOMEMP", "", STR0023     , "@!"        , 20, .T./*lPixel*/,{|| aDadosImp[nPROCDados][7][nPROCDesmo][2] }) //"Nome da Empresa"
		TRCell():New(oSection3, "CODFIL", "", STR0024              , "@!"        , 15, .T./*lPixel*/,{|| aDadosImp[nPROCDados][7][nPROCDesmo][3] }) //"Filial"
		TRCell():New(oSection3, "NOMFIL", "", STR0025      , "@!"        , 20, .T./*lPixel*/,{|| aDadosImp[nPROCDados][7][nPROCDesmo][4] }) //"Nome da Filial"
		TRCell():New(oSection3, "DATA"  , "", STR0026                , "99/99/9999", 20, .T./*lPixel*/,{|| aDadosImp[nPROCDados][7][nPROCDesmo][5] }) //"Data"
		TRCell():New(oSection3, "QUANTI", "", STR0027          , "@E 999,999", 20, .T./*lPixel*/,{|| aDadosImp[nPROCDados][7][nPROCDesmo][6] }) //"Quantidade"
		
		oSection3:Cell("QUANTI"):SetHeaderAlign("RIGHT")
		
		oSection3:nLeftMargin := 20
	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Break: Sub Total           ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	oBreak := TRBreak():New(oSection2,oSection2:Cell("CODFAM"),STR0028,.F.) //"Sub Total"
		TRFunction():New(oSection3:Cell("QUANTI"),/*cId*/,"SUM",oBreak,/*cTitle*/,"@E 999,999,999"/*cPicture*/,/*uFormula*/,.F./*lEndSection*/,.F./*lEndReport*/,.F./*lEndPage*/)
		
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Break: TOTAL DE MES        ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	oBreak := TRBreak():New(oSection1,oSection1:Cell("MES"),STR0029,.F.) //"TOTAL DO MES"
		TRFunction():New(oSection3:Cell("QUANTI"),/*cId*/,"SUM",oBreak,/*cTitle*/,"@E 999,999,999,999"/*cPicture*/,/*uFormula*/,.F./*lEndSection*/,.F./*lEndReport*/,.F./*lEndPage*/)
Else
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Por Familia ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Section1: Familia          ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	oSection1 := TRSection():New(oReport,STR0015,{}) //"Família"
		TRCell():New(oSection1, "CODFAM", "", STR0015, "@!", 20, .T./*lPixel*/,{|| aDadosImp[nPROCDados][1] }) //"FAMÍLIA"
		TRCell():New(oSection1, "NOMFAM", "", STR0030   , "@!", 20, .T./*lPixel*/,{|| aDadosImp[nPROCDados][2] }) //"NOME"
		
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Section2: Modelo           ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	oSection2 := TRSection():New(oReport,STR0017,{}) //"Modelo"
		TRCell():New(oSection2, "CODMOD", "", STR0017              , "@!"               , 10, .T./*lPixel*/,{|| aDadosImp[nPROCDados][3] }) //"Modelo"
		TRCell():New(oSection2, "NOMMOD", "", STR0018      , "@!"               , 20, .T./*lPixel*/,{|| aDadosImp[nPROCDados][4] }) //"Nome do Modelo"
		TRCell():New(oSection2, "CAPPRO", "", STR0019, "@E 999,999,999.99", 20, .T./*lPixel*/,{|| aDadosImp[nPROCDados][5] }) //"Capacidade Produtiva"
		TRCell():New(oSection2, "UNICAP", "", STR0020             , "@!"               , 20, .T./*lPixel*/,{|| aDadosImp[nPROCDados][6] }) //"Unidade"
		
		oSection2:Cell("CAPPRO"):SetHeaderAlign("RIGHT")
		
		oSection2:nLeftMargin := 05
		
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Section4: Mes/Ano          ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	oSection4 := TRSection():New(oReport,STR0011,{}) //"Mês/Ano"
		TRCell():New(oSection4, "MES", "", STR0012, "@!", 20, .T./*lPixel*/,{|| fGetMes(nProcMes) }) //"Mês"
		TRCell():New(oSection4, "ANO", "", STR0013, "@!", 20, .T./*lPixel*/,{|| cValToChar(nProcAno) }) //"Ano"
		
		oSection4:nLeftMargin := 15
	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Section3: Desmobilizacoes  ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	oSection3 := TRSection():New(oReport,STR0021,{}) //"Desmobilizações"
		TRCell():New(oSection3, "CODEMP", "", STR0022             , "@!"        , 15, .T./*lPixel*/,{|| aDadosImp[nPROCDados][7][nPROCDesmo][1] }) //"Empresa"
		TRCell():New(oSection3, "NOMEMP", "", STR0023     , "@!"        , 20, .T./*lPixel*/,{|| aDadosImp[nPROCDados][7][nPROCDesmo][2] }) //"Nome da Empresa"
		TRCell():New(oSection3, "CODFIL", "", STR0024              , "@!"        , 15, .T./*lPixel*/,{|| aDadosImp[nPROCDados][7][nPROCDesmo][3] }) //"Filial"
		TRCell():New(oSection3, "NOMFIL", "", STR0025      , "@!"        , 20, .T./*lPixel*/,{|| aDadosImp[nPROCDados][7][nPROCDesmo][4] }) //"Nome da Filial"
		TRCell():New(oSection3, "DATA"  , "", STR0026                , "99/99/9999", 20, .T./*lPixel*/,{|| aDadosImp[nPROCDados][7][nPROCDesmo][5] }) //"Data"
		TRCell():New(oSection3, "QUANTI", "", STR0027          , "@E 999,999", 20, .T./*lPixel*/,{|| aDadosImp[nPROCDados][7][nPROCDesmo][6] }) //"Quantidade"
		
		oSection3:Cell("QUANTI"):SetHeaderAlign("RIGHT")
		
		oSection3:nLeftMargin := 20
	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Break: Sub Total           ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	oBreak := TRBreak():New(oSection4,oSection4:Cell("MES"),STR0028,.F.) //"Sub Total"
		TRFunction():New(oSection3:Cell("QUANTI"),/*cId*/,"SUM",oBreak,/*cTitle*/,"@E 999,999,999"/*cPicture*/,/*uFormula*/,.F./*lEndSection*/,.F./*lEndReport*/,.F./*lEndPage*/)
		
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Break: TOTAL DA FAMILIA    ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	oBreak := TRBreak():New(oSection1,oSection1:Cell("CODFAM"),STR0031,.F.) //"TOTAL DA FAMÍLIA"
		TRFunction():New(oSection3:Cell("QUANTI"),/*cId*/,"SUM",oBreak,/*cTitle*/,"@E 999,999,999,999"/*cPicture*/,/*uFormula*/,.F./*lEndSection*/,.F./*lEndReport*/,.F./*lEndPage*/)
	
EndIf

Return oReport

//---------------------------------------------------------------------
/*/{Protheus.doc} fReportPrt
Imprime o Relatorio Personalizavel                                    

@author Wagner S. de Lacerda
@since 18/08/2011
@return 
/*/
//---------------------------------------------------------------------

Static Function fReportPrt()

Local nImpDados := 0, nImpMes := 0, nImpDesmob
Local nTemDes := 0

Local cCodFamAnt := ""

Local aDesmobs := {}
Local lFirst := .F.
Local lEndPage := .F., lStartPage := .F.

//ÉÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ»
//º Busca os Dados para a Impressao º
//ÈÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼
Processa({|| aDadosImp := aClone( fProcessa() ) }, OemToAnsi(STR0032)) //"Processando Relatório..."

If Len(aDadosImp) == 0
	MsgInfo(STR0033,STR0034) //"Não há dados para imprimir o relatório."###"Atenção"
	Return .F.
EndIf

//ÉÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ»
//º Realiza a Impressao do Cadastro º
//ÈÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼
oReport:SetMeter(Len(aDadosImp))

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Por Mes     ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If MV_PAR09 == 1
	lEndPage   := .F.
	lStartPage := .F.
	
	nProcMes := 0
	nProcAno := 0
	For nImpMes := 1 To 12
		
		If oReport:Cancel()
			ApMsgStop(STR0035,STR0036) //"Relatório cancelado pelo usuário."###"Operação Cancelada"
			Return .F.
		EndIf
		
		If nProcMes == 0
			nProcMes := Month(MV_PAR07)
			nProcAno := Year(MV_PAR07)
		Else
			nProcMes++
			If nProcMes > 12
				nProcMes := nProcMes - 12
				nProcAno++
			EndIf
		EndIf
		
		cTitPagina := fTitPagina() //Titulo da Pagina
		
		oReport:IncMeter()
		
		If lEndPage
			oReport:EndPage()
			
			lEndPage   := .F.
			lStartPage := .T.
		EndIf
		
		lFirst := .T.
		cCodFamAnt := ""
		For nImpDados := 1 To Len(aDadosImp)
			nPROCDados := nImpDados
			
			If oReport:Cancel()
				ApMsgStop(STR0035,STR0036) //"Relatório cancelado pelo usuário."###"Operação Cancelada"
				Return .F.
			EndIf
			
			nTemDes := aScan(aDadosImp[nImpDados][7], {|x| Month(x[5]) == nProcMes .And. Year(x[5]) == nProcAno })
			If nTemDes > 0
				lImpMes := .T.
				
				If lStartPage .Or. lFirst
					oReport:StartPage()
					
					lEndPage   := .T.
					lStartPage := .F.
				EndIf
				
				If lFirst
					oSection1:Init()
					oSection1:PrintLine()
					
					lFirst := .F.
				EndIf
				oSection2:Init()
				oSection2:PrintLine()
				
				aDesmobs := aDadosImp[nImpDados][7]
				oSection3:Init()
				For nImpDesmob := 1 To Len(aDesmobs)
					nPROCDesmo := nImpDesmob
					
					If oReport:Cancel()
						ApMsgStop(STR0035,STR0036) //"Relatório cancelado pelo usuário."###"Operação Cancelada"
						Return .F.
					EndIf
					
					If Month(aDesmobs[nImpDesmob][5]) == nProcMes .And. Year(aDesmobs[nImpDesmob][5]) == nProcAno
						oSection3:PrintLine()
					EndIf
				Next nImpDesmob
				oSection3:Finish()
				oSection2:Finish()
			EndIf
			
			cCodFamAnt := aDadosImp[nImpDados][1]
		Next nImpDados
		If !lFirst
			oSection1:Finish()
		EndIf
	Next nImpMes
Else
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Por Familia ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	lFirst     := .T.
	cCodFamAnt := ""
	For nImpDados := 1 To Len(aDadosImp)
		nPROCDados := nImpDados
		
		oReport:IncMeter()
		
		If oReport:Cancel()
			ApMsgStop(STR0035,STR0036) //"Relatório cancelado pelo usuário."###"Operação Cancelada"
			Return .F.
		EndIf
		
		cTitPagina := fTitPagina(nImpDados) //Titulo da Pagina
		
		lFirst := ( cCodFamAnt <> aDadosImp[nImpDados][1] )
		nTemDes := aScan(aDadosImp[nImpDados][7], {|x| x[5] >= MV_PAR07 .And. x[5] <= MV_PAR08})
		If nTemDes > 0
			If lFirst
				lFirst := .F.
				oSection1:Init()
				oSection1:PrintLine()
			EndIf
			
			oSection2:Init()
			oSection2:PrintLine()
			
			aDesmobs := aDadosImp[nImpDados][7]
			nProcMes := 0
			For nImpMes := 1 To 12
				lImpMes := .T.
				
				If nProcMes == 0
					nProcMes := Month(MV_PAR07)
					nProcAno := Year(MV_PAR07)
				Else
					nProcMes++
					If nProcMes > 12
						nProcMes := nProcMes - 12
						nProcAno++
					EndIf
				EndIf
				
				For nImpDesmob := 1 To Len(aDesmobs)
					nPROCDesmo := nImpDesmob
					
					If Month(aDesmobs[nImpDesmob][5]) == nProcMes .And. Year(aDesmobs[nImpDesmob][5]) == nProcAno
						If lImpMes
							lImpMes := .F.
							
							oSection3:Init()
							
							oSection4:Init()
							oSection4:PrintLine()
						EndIf
						
						oSection3:PrintLine()
					EndIf
				Next nImpDesmob
				If !lImpMes
					oSection4:Finish()
					oSection3:Finish()
				EndIf
			Next nImpMes
			oSection2:Finish()
		EndIf
		
		If ( (nImpDados + 1) > Len(aDadosImp) ) .Or. ;
			( (nImpDados + 1) <= Len(aDadosImp) .And. aDadosImp[nImpDados][1] <> aDadosImp[nImpDados+1][1] )
			
			oSection1:Finish()
		EndIf
		
		cCodFamAnt := aDadosImp[nImpDados][1]
	Next nImpDados
EndIf

//ÉÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ»
//º Finaliza a Impressao            º
//ÈÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼

Return .T.

//---------------------------------------------------------------------
/*/{Protheus.doc} MNTR682IM
Funcao de impressao do Relatorio em Modelo Padrao.                                  

@author Wagner S. de Lacerda
@since 18/08/2011
@return  	.T. -> Impressao concluida.  
			.F. -> Nao imprimiu.
/*/
//---------------------------------------------------------------------

Function MNTR682IM()

Private cWnRel  := cNomeProg
Private cCabec1 := ""
Private cCabec2 := ""

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Envia controle para a funcao SETPRINT                        ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
cWnRel := SetPrint(cString, cWnRel, cPerg, cTitulo, cDesc1, cDesc2, cDesc3, .F., "")
If nLastKey == 27
	Return .F.
EndIf

nTipo := If(aReturn[4] == 1, 15, 18)

SetDefault(aReturn, cString)
RptStatus({|lEnd| fImpRelPad(@lEnd)}, OemToAnsi(STR0037)) //"Imprimindo Relatório..."

Return .T.

//---------------------------------------------------------------------
/*/{Protheus.doc} fImpRelPad
Imprime o relatorio padrao.                                  

@author Wagner S. de Lacerda
@since 18/08/2011
@Param lEnd -> Obrigatorio; 
		Indica se o relatorio foi cancelado. 
		.F. - Continua impressao   
		.T. - Cancelado   
@return  	
/*/
//---------------------------------------------------------------------

Static Function fImpRelPad(lEnd)

Local aDesmobs := {}
Local nImpMes := 0
Local nImpDados := 0
Local nImpDesmob := 0

Local cCodFamAnt := ""
Local lFirst := .T., lImpMes := .T., lImpFamMod := .T.
Local nTemDes := 0

Local nTOTFamMod := 0
Local nTOTMes := 0

Local cRodaTxt := "" //Variavel para controle do Relatorio
Local nCntImpr := 0 //Variavel para controle do Relatorio

Private Li := 80, m_pag := 1 //Variaveis para controle do Relatorio

/* Exemplo de Impressao

Se MV_PAR09 == 1 (Por Mês)

          1         2         3         4         5         6         7         8         9         10        11        12        13 
0123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012
*************************************************************************************************************************************
                                                                                                                                     
     MES: XXXXXXXXXX / 9999                                                                                                          
*************************************************************************************************************************************
                                                                                                                                     
Família        Nome da Família          Modelo         Nome do Modelo           Capacidade Produtiva     Unidade                     
XXXXXXXXXX     XXXXXXXXXXXXXXXXXXXX     XXXXXXXXXX     XXXXXXXXXXXXXXXXXXXX           999.999.999,99     XXXXX                       
               ----------------------------------------------------------------------------------------------------------------------
               Empresa             Nome da Empresa          Filial              Nome da Filial              Data         Quantidade  
               XXXXXXXXXXXXXXX     XXXXXXXXXXXXXXXXXXXX     XXXXXXXXXXXXXXX     XXXXXXXXXXXXXXXXXXXX     99/99/9999         999.999  
               XXXXXXXXXXXXXXX     XXXXXXXXXXXXXXXXXXXX     XXXXXXXXXXXXXXX     XXXXXXXXXXXXXXXXXXXX     99/99/9999         999.999  
               XXXXXXXXXXXXXXX     XXXXXXXXXXXXXXXXXXXX     XXXXXXXXXXXXXXX     XXXXXXXXXXXXXXXXXXXX     99/99/9999         999.999  
                                                                                                                                     
                                                                                                                    ---------------  
                                                                                                         Sub Total:     999.999.999  
                                                                                                                                     
                                                                                                                    ***************  
                                                                                                     Total do  Mês: 999.999.999.999  

Se MV_PAR09 == 2 (Por Família)

          1         2         3         4         5         6         7         8         9         10        11        12        13 
0123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012
*************************************************************************************************************************************
                                                                                                                                     
     FAMÍLIA: XXXXXXXXXX - XXXXXXXXXXXXXXXXXXXX                                                                                      
*************************************************************************************************************************************
                                                                                                                                     
Modelo         Nome do Modelo           Capacidade Produtiva     Unidade                                             
XXXXXXXXXX     XXXXXXXXXXXXXXXXXXXX           999.999.999,99     XXXXX                                                
               ----------------------------------------------------------------------------------------------------------------------
                                                                                                           Mês/Ano: XXXXXXXXXX/9999 
                                                                                                                                     
               Empresa             Nome da Empresa          Filial              Nome da Filial              Data         Quantidade  
               XXXXXXXXXXXXXXX     XXXXXXXXXXXXXXXXXXXX     XXXXXXXXXXXXXXX     XXXXXXXXXXXXXXXXXXXX     99/99/9999         999.999  
               XXXXXXXXXXXXXXX     XXXXXXXXXXXXXXXXXXXX     XXXXXXXXXXXXXXX     XXXXXXXXXXXXXXXXXXXX     99/99/9999         999.999  
               XXXXXXXXXXXXXXX     XXXXXXXXXXXXXXXXXXXX     XXXXXXXXXXXXXXX     XXXXXXXXXXXXXXXXXXXX     99/99/9999         999.999  
                                                                                                                                     
                                                                                                                    ---------------  
                                                                                                         Sub Total:     999.999.999  
                                                                                                                                     
                                                                                                                    ***************  
                                                                                                  Total da Família: 999.999.999.999  
*/
If MV_PAR09 == 1 //Por Mes
	cCabec1 := STR0038 //"Família        Nome da Família          Modelo         Nome do Modelo           Capacidade Produtiva     Unidade"
Else
	cCabec1 := STR0039 //"Modelo         Nome do Modelo           Capacidade Produtiva     Unidade"
EndIf
cCabec2 := STR0040 //"               Empresa             Nome da Empresa          Filial              Nome da Filial              Data         Quantidade"


//ÉÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ»
//º Busca os Dados para a Impressao º
//ÈÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼
Processa({|| aDadosImp := aClone( fProcessa() ) }, OemToAnsi(STR0032)) //"Processando Relatório..."

If Len(aDadosImp) == 0
	MsgInfo(STR0033,STR0034) //"Não há dados para imprimir o relatório."###"Atenção"
	Return .F.
EndIf

//ÉÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ»
//º Realiza a Impressao do Cadastro º
//ÈÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼
SetRegua(12)
Li := 80

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Por Mes     ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If MV_PAR09 == 1
	nProcMes := 0
	nProcAno := 0
	For nImpMes := 1 To 12
		
		If lEnd
			ApMsgStop(STR0035,STR0036) //"Relatório cancelado pelo usuário."###"Operação Cancelada"
			Return .F.
		EndIf
		
		If nProcMes == 0
			nProcMes := Month(MV_PAR07)
			nProcAno := Year(MV_PAR07)
		Else
			nProcMes++
			If nProcMes > 12
				nProcMes := nProcMes - 12
				nProcAno++
			EndIf
		EndIf
		
		cTitPagina := fTitPagina() //Titulo da Pagina
		
		IncRegua(STR0041+cTitPagina) //"Imprimindo: "
		
		lFirst     := .T.
		lImpMes    := .F.
		cCodFamAnt := ""
		nTOTMes    := 0
		For nImpDados := 1 To Len(aDadosImp)
			
			If lEnd
				ApMsgStop(STR0035,STR0036) //"Relatório cancelado pelo usuário."###"Operação Cancelada"
				Return .F.
			EndIf
			
			nTemDes := aScan(aDadosImp[nImpDados][7], {|x| Month(x[5]) == nProcMes .And. Year(x[5]) == nProcAno })
			If nTemDes > 0
				lImpMes := .T.
				
				If lFirst
					lFirst := .F.
					SomaLinha(80)
				Else
					SomaLinha()
				EndIf
				
				If cCodFamAnt <> aDadosImp[nImpDados][1]
					@ Li,000 PSAY OemToAnsi(SubStr(aDadosImp[nImpDados][1],1,10))
					@ Li,015 PSAY OemToAnsi(SubStr(aDadosImp[nImpDados][2],1,20))
				EndIf
				
				@ Li,040 PSAY OemToAnsi(SubStr(aDadosImp[nImpDados][3],1,10))
				@ Li,055 PSAY OemToAnsi(SubStr(aDadosImp[nImpDados][4],1,20))
				@ Li,086 PSAY Transform(aDadosImp[nImpDados][5],"@E 999,999,999.99")
				@ Li,105 PSAY OemToAnsi(SubStr(aDadosImp[nImpDados][6],1,5))
				
				aDesmobs := aDadosImp[nImpDados][7]
				nTOTFamMod := 0
				lImpFamMod := .F.
				
				SomaLinha()
				@ Li,015 PSAY Replicate("-",nLimite-16)
				For nImpDesmob := 1 To Len(aDesmobs)
					If lEnd
						ApMsgStop(STR0035,STR0036) //"Relatório cancelado pelo usuário."###"Operação Cancelada"
						Return .F.
					EndIf
					
					If Month(aDesmobs[nImpDesmob][5]) == nProcMes .And. Year(aDesmobs[nImpDesmob][5]) == nProcAno
						If !lImpFamMod
							lImpFamMod := .T.
						EndIf
						SomaLinha()
						
						@ Li,015 PSAY OemToAnsi(SubStr(aDesmobs[nImpDesmob][1],1,15))
						@ Li,035 PSAY OemToAnsi(SubStr(aDesmobs[nImpDesmob][2],1,20))
						@ Li,060 PSAY OemToAnsi(SubStr(aDesmobs[nImpDesmob][3],1,15))
						@ Li,080 PSAY OemToAnsi(SubStr(aDesmobs[nImpDesmob][4],1,20))
						@ Li,105 PSAY aDesmobs[nImpDesmob][5] PICTURE "99/99/9999"
						@ Li,124 PSAY Transform(aDesmobs[nImpDesmob][6],"@E 999,999")
						
						nTOTFamMod += aDesmobs[nImpDesmob][6]
					EndIf
				Next nImpDesmob
				If lImpFamMod
					SomaLinha()
					@ Li,116 PSAY Replicate("-",15)
					SomaLinha()
					@ Li,105 PSAY OemToAnsi(STR0042) //"Sub Total:"
					@ Li,120 PSAY Transform(nTOTFamMod,"@E 999,999,999")
				EndIf
				
				nTOTMes += nTOTFamMod
				cCodFamAnt := aDadosImp[nImpDados][1]
				SomaLinha(2)
			EndIf
		Next nImpDados
		
		If lImpMes
			SomaLinha()
			@ Li,116 PSAY Replicate("*",15)
			SomaLinha()
			@ Li,101 PSAY OemToAnsi(STR0043) PICTURE "@!" //"Total do Mês:"
			@ Li,116 PSAY Transform(nTOTMes,"@E 999,999,999,999")
		EndIf
	Next nImpMes
Else
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Por Familia ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	lFirst     := .T.
	lImpMes    := .F.
	cCodFamAnt := ""
	nTOTMes    := 0
	For nImpDados := 1 To Len(aDadosImp)
		IncRegua(STR0041+aDadosImp[nImpDados][1]) //"Imprimindo: "
		
		If lEnd
			ApMsgStop(STR0035,STR0036) //"Relatório cancelado pelo usuário."###"Operação Cancelada"
			Return .F.
		EndIf
		
		cTitPagina := fTitPagina(nImpDados) //Titulo da Pagina
		
		nTemDes := aScan(aDadosImp[nImpDados][7], {|x| x[5] >= MV_PAR07 .And. x[5] <= MV_PAR08})
		If nTemDes > 0
			If lFirst
				lFirst := .F.
				nTOTFamMod := 0
				SomaLinha(80)
			ElseIf cCodFamAnt <> aDadosImp[nImpDados][1]
				nTOTFamMod := 0
				SomaLinha(2,.T.)
			EndIf
			
			@ Li,000 PSAY OemToAnsi(SubStr(aDadosImp[nImpDados][3],1,10))
			@ Li,015 PSAY OemToAnsi(SubStr(aDadosImp[nImpDados][4],1,20))
			@ Li,046 PSAY Transform(aDadosImp[nImpDados][5],"@E 999,999,999.99")
			@ Li,065 PSAY OemToAnsi(SubStr(aDadosImp[nImpDados][6],1,5))
			
			aDesmobs := aDadosImp[nImpDados][7]
			
			SomaLinha()
			@ Li,015 PSAY Replicate("-",nLimite-16)
			nProcMes := 0
			For nImpMes := 1 To 12
				
				If lEnd
					ApMsgStop(STR0035,STR0036) //"Relatório cancelado pelo usuário."###"Operação Cancelada"
					Return .F.
				EndIf
				
				If nProcMes == 0
					nProcMes := Month(MV_PAR07)
					nProcAno := Year(MV_PAR07)
				Else
					nProcMes++
					If nProcMes > 12
						nProcMes := nProcMes - 12
						nProcAno++
					EndIf
				EndIf
				
				nTOTMes := 0
				lImpMes := .F.
				For nImpDesmob := 1 To Len(aDesmobs)
					
					If lEnd
						ApMsgStop(STR0035,STR0036) //"Relatório cancelado pelo usuário."###"Operação Cancelada"
						Return .F.
					EndIf
					
					If Month(aDesmobs[nImpDesmob][5]) == nProcMes .And. Year(aDesmobs[nImpDesmob][5]) == nProcAno
						If !lImpMes
							SomaLinha()
							@ Li,107 PSAY OemToAnsi(STR0044) //"Mês/Ano:"
							@ Li,116 PSAY OemToAnsi(PADL(fGetMes(nProcMes),10," ")) + "/" + cValTochar(nProcAno)
							lImpMes := .T.
						EndIf
						SomaLinha()
						
						@ Li,015 PSAY OemToAnsi(SubStr(aDesmobs[nImpDesmob][1],1,15))
						@ Li,035 PSAY OemToAnsi(SubStr(aDesmobs[nImpDesmob][2],1,20))
						@ Li,060 PSAY OemToAnsi(SubStr(aDesmobs[nImpDesmob][3],1,15))
						@ Li,080 PSAY OemToAnsi(SubStr(aDesmobs[nImpDesmob][4],1,20))
						@ Li,105 PSAY aDesmobs[nImpDesmob][5] PICTURE "99/99/9999"
						@ Li,124 PSAY Transform(aDesmobs[nImpDesmob][6],"@E 999,999")
						
						nTOTMes += aDesmobs[nImpDesmob][6]
					EndIf
				Next nImpDesmob
				
				If lImpMes
					SomaLinha()
					@ Li,116 PSAY Replicate("-",15)
					SomaLinha()
					@ Li,105 PSAY OemToAnsi(STR0042) //"Sub Total:"
					@ Li,120 PSAY Transform(nTOTMes,"@E 999,999,999")
					SomaLinha(2)
				EndIf
				
				nTOTFamMod += nTOTMes
			Next nImpMes
		EndIf
		
		If ( (nImpDados + 1) > Len(aDadosImp) ) .Or. ;
			( (nImpDados + 1) <= Len(aDadosImp) .And. aDadosImp[nImpDados][1] <> aDadosImp[nImpDados+1][1] )
			
			SomaLinha()
			@ Li,116 PSAY Replicate("*",15)
			SomaLinha()
			@ Li,098 PSAY OemToAnsi(STR0045) PICTURE "@!" //"Total da Família:"
			@ Li,116 PSAY Transform(nTOTFamMod,"@E 999,999,999,999")
			SomaLinha()
		EndIf
		
		cCodFamAnt := aDadosImp[nImpDados][1]
		
	Next nImpDados
EndIf

//ÉÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ»
//º Finaliza a Impressao            º
//ÈÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼
Roda(nCntImpr, cRodaTxt, cTamanho)

Set Device To Screen
If aReturn[5] == 1
	Set Printer To
	dbCommitAll()
	OurSpool(cWnRel)
EndIf
MS_FLUSH()

Return .T.

//---------------------------------------------------------------------
/*/{Protheus.doc} fProcessa
Processa os dados do relatorio.                                

@author Wagner S. de Lacerda
@since 18/08/2011
@return aRetDados -> Array com os dados para impressao.   	
/*/
//---------------------------------------------------------------------

Static Function fProcessa()

Local aArea := GetArea()
Local aRetDados := {}

/* Verifica Empresa e Filial */
Local cVerEmp
Local cVerFil
Local nEmpFil
/**/

/* Compartilhamento das Tabelas */
Local lCompST6 := .F.
Local lCompST9 := .F.
Local lCompTQR := .F.
/**/

/* Controle dos Dados */
Local nExstDad := 0
Local nExstDes := 0
Local nX       := 0, nY := 0, nRemovMes := 0

Local cNomeFam   := ""
Local cNomeMod   := ""
Local nCapMod    := 0
Local cUniCapMod := ""

Local aAuxiliar := {}
Local cVerFam   := ""
Local cVerMod   := ""
Local nDesmob   := 0

Local lAddDesmob := .T.
Local lTemDesmob := .F.
/**/

aRetDados := { {},{},{},{},{},{},{},{},{},{} } //Tamanho 12 - 12 meses
aTabelas  := { {"ST6"}, {"ST9"}, {"TQR"}, {"TVY"} }


dbSelectArea("SM0")
dbSetOrder(1)
dbSeek(MV_PAR01,.T.)
While !Eof() .And. SM0->M0_CODIGO+SM0->M0_CODFIL <= MV_PAR02
	aAdd( aZEMPS, { SM0->M0_CODIGO, Substr( SM0->M0_CODFIL, 1, FWSizeFilial() ) } )

	dbSelectArea("SM0")
	dbSkip()
EndDo

If Len(aZEMPS) == 0
	Return {}
EndIf

aRetDados := {}

ProcRegua(Len(aZEMPS))
For nEmpFil := 1 To Len(aZEMPS) //Ja filtrando pelas Empresas e Filiais
	
	cVerEmp := aZEMPS[nEmpFil][1]
	cVerFil := aZEMPS[nEmpFil][2]
	
	IncProc(STR0046+cVerEmp+STR0047+cVerFil) //"Processando Empresa "###" / Filial "
	aAuxiliar := NGSEEKSM0(cVerEmp+cVerFil,{"M0_NOME","M0_FILIAL"})
	If Len(aAuxiliar) == 0
		Loop
	EndIf
	
	NGPrepTbl(aTabelas,cVerEmp)
	
	lCompST6 := ( NGSX2MODO("ST6") == "C" )
	lCompST9 := ( NGSX2MODO("ST9") == "C" )
	lCompTQR := ( NGSX2MODO("TQR") == "C" )
	
	dbSelectArea("TVY")
	dbSetOrder(4)
	dbGoTop()
	dbSeek(cVerFil+MV_PAR03,.T.)
	While !Eof() .And. TVY->TVY_FILIAL == cVerFil .And. TVY->TVY_CODFAM <= MV_PAR04 //Ja filtrando pela Familia
		
		//Filtro pelo Modelo
		If TVY->TVY_TIPMOD < MV_PAR05 .Or. TVY->TVY_TIPMOD > MV_PAR06
			dbSelectArea("TVY")
			dbSkip()
			Loop
		EndIf
		
		//Filtro pela Data Fim (Data Fim = Data de Desmobilizacao no Planejamento)
		If TVY->TVY_DTFIM < MV_PAR07 .Or. TVY->TVY_DTFIM > MV_PAR08
			dbSelectArea("TVY")
			dbSkip()
			Loop
		EndIf
		
		//--- Recebe a Quantidade Prevista de Desmobilizacao
		nDesmob := TVY->TVY_QUANT
		
		//--- Recebe o Nome da Familia
		cNomeFam := ""
		dbSelectArea("ST6")
		dbSetOrder(1)
		If dbSeek(If(lCompST6,xFilial("ST6"),cVerFil)+TVY->TVY_CODFAM)
			cNomeFam := ST6->T6_NOME
		EndIf
		
		//--- Recebe o Nome do Modelo, Capacidade Produtiva e Unidade desta Capacidade
		cNomeMod   := ""
		nCapMod    := 0
		cUniCapMod := ""
		dbSelectArea("TQR")
		dbSetOrder(1)
		If dbSeek(If(lCompTQR,xFilial("TQR"),cVerFil)+TVY->TVY_TIPMOD)
			cNomeMod   := TQR->TQR_DESMOD
			nCapMod    := TQR->TQR_CPPROD
			cUniCapMod := TQR->TQR_UNPROD
		EndIf
		
		//--- Adiciona ao Array de Dados
		nExstDad := aScan(aRetDados, {|x| x[1]+x[3] == TVY->TVY_CODFAM+TVY->TVY_TIPMOD })
		If nExstDad == 0
			//1                 ; 2               ; 3                ; 4              ; 5                             ; 6                              ; 7
			//Codigo da Familia ; Nome da Familia ; Codigo do Modelo ; Nome do Modelo ; Capacidade Produtiva (Modelo) ; Unidade da Capacidade (Modelo) ; {Periodos}
			aAdd(aRetDados, { TVY->TVY_CODFAM, cNomeFam, TVY->TVY_TIPMOD, cNomeMod, nCapMod, cUniCapMod, {} } )
			nExstDad := Len(aRetDados)
		EndIf
				
		aAuxiliar := NGSEEKSM0(cVerEmp+cVerFil,{"M0_NOME","M0_FILIAL"})
		
		nExstDes := aScan(aRetDados[nExstDad][7], {|x| x[1]+x[3]+DTOS(x[5]) == cVerEmp+cVerFil+DTOS(TVY->TVY_DTFIM) .And. x[7] == "P"})
		If nExstDes == 0
			//1       ; 2               ; 3      ; 4              ; 5                      ; 6                                                 ; 7                                                                  ; 8
			//Empresa ; Nome da Empresa ; Filial ; Nome da Filial ; Data de Desmobilizacao ; Quantidade de Equipamentos Desmobilizados na data ; Indica a origem da desmobilizacao ("P" - Planejamento , "B" - Bem) ; Data de Mobilizacao
			aAdd(aRetDados[nExstDad][7], {cVerEmp, aAuxiliar[1], cVerFil, aAuxiliar[2], TVY->TVY_DTFIM, nDesmob, "P", TVY->TVY_DTINIC} )
		Else
			aRetDados[nExstDad][7][nExstDes][6] += nDesmob
		EndIf
		
		dbSelectArea("TVY")
		dbSkip()
	End
Next nEmpFil

//--- Verifica os Bens da Familia e Modelo que possuem data de Desmobilizacao
ProcRegua(Len(aZEMPS))
For nEmpFil := 1 To Len(aZEMPS) //Ja filtrando pelas Empresas e Filiais
	
	cVerEmp := aZEMPS[nEmpFil][1]
	cVerFil := aZEMPS[nEmpFil][2]
	
	IncProc(STR0048) //"Processando Desmobilizações..."
	
	aAuxiliar := NGSEEKSM0(cVerEmp+cVerFil,{"M0_NOME","M0_FILIAL"})
	If Len(aAuxiliar) == 0
		Loop
	EndIf
	
	NGPrepTbl(aTabelas,cVerEmp)
	
	For nX := 1 To Len(aRetDados)
		cVerFam := aRetDados[nX][1]
		cVerMod := aRetDados[nX][3]
		
		dbSelectArea("ST9")
		dbSetOrder(4)
		dbGoTop()
		dbSeek(If(lCompST9,xFilial("ST9"),cVerFil)+cVerFam,.T.)
		While !Eof() .And. ST9->T9_FILIAL == If(lCompST9,xFilial("ST9"),cVerFil) .And. ST9->T9_CODFAMI == cVerFam
			
			If ST9->T9_TIPMOD == cVerMod .And. !Empty(ST9->T9_DTDESMO)
				
				lAddDesmob := .T.
				
				//Filtro pela Data de Desmobilizacao do Bem
				If ST9->T9_DTDESMO < MV_PAR07 .Or. ST9->T9_DTDESMO > MV_PAR08
					lAddDesmob := .F.
				EndIf
				
				//Adiciona Desmobilizacao do BEM
				If lAddDesmob
					nExstDes := aScan(aRetDados[nX][7], {|x| x[1]+x[3]+DTOS(x[5]) == cVerEmp+cVerFil+DTOS(ST9->T9_DTDESMO)})
					If nExstDes == 0
						aAdd(aRetDados[nX][7], {cVerEmp, aAuxiliar[1], cVerFil, aAuxiliar[2], ST9->T9_DTDESMO, 1, "B"} )
					Else
						aRetDados[nX][7][nExstDes][6] += 1
					EndIf
					
					nExstDes := aScan(aRetDados[nX][7], {|x| x[1]+x[3] == cVerEmp+cVerFil .And. x[7] == "P" .And. ST9->T9_DTDESMO >= x[8] .And. ST9->T9_DTDESMO <= x[5]})
					If nExstDes > 0
						aRetDados[nX][7][nExstDes][6] -= 1
					EndIf
				EndIf
				
			EndIf
			
			dbSelectArea("ST9")
			dbSkip()
		End
	Next nX
Next nEmpFil

lTemDesmob := .F.
For nX := 1 To Len(aRetDados)
	If Len(aRetDados[nX][7]) > 0
		lTemDesmob := .T.
		aSort(aRetDados[nX][7], , , {|x,y| DTOS(x[5]) < DTOS(y[5]) })
	EndIf
Next nX
If lTemDesmob
	aSort(aRetDados, , , {|x,y| x[1]+x[3] < y[1]+y[3]  })
Else
	aRetDados := {}
EndIf

NGPrepTbl(aTabelas,c200EmpOri)
RestArea(aArea)

Return aRetDados

//---------------------------------------------------------------------
/*/{Protheus.doc} fTitPagina
Define o Titulo da Pagina.                                 

@author Wagner S. de Lacerda
@since 18/08/2011
@Param nPosImp -> Opcional;
		Deve ser indicado quando for necessario saber a
		familia no titulo da pagina (MV_PAR09 == 2) 
@return cTitPag -> Titulo da Pagina   	
/*/
//---------------------------------------------------------------------

Static Function fTitPagina(nPosImp)

Local cTitPag := ""

Default nPosImp := 1

If MV_PAR09 == 1 //Por Mes
	cTitPag := fGetMes(nProcMes)
	cTitPag := PADL(cTitPag,10," ")
	
	cTitPag += " / "+cValToChar(nProcAno)
Else //Por Familia
	cTitPag := STR0049 + aDadosImp[nPosImp][1] + " - " + aDadosImp[nPosImp][2] //"Família: "
EndIf

cTitPag := OemToAnsi(cTitPag)

Return cTitPag

//---------------------------------------------------------------------
/*/{Protheus.doc} fGetMes
Define o Mes do ano.                                 

@author Wagner S. de Lacerda
@since 18/08/2011
@Param nVerMes -> Obrigatorio; 
		 Deve ser indicado qual o mes para retorno.   
@return cVerMes -> Mes por extenso.  
/*/
//---------------------------------------------------------------------

Static Function fGetMes(nVerMes)

Local cVerMes := ""

Do Case
	Case nVerMes == 1
		cVerMes := STR0050 //"Janeiro"
	Case nVerMes == 2
		cVerMes := STR0051 //"Fevereiro"
	Case nVerMes == 3
		cVerMes := STR0052 //"Março"
	Case nVerMes == 4
		cVerMes := STR0053 //"Abril"
	Case nVerMes == 5
		cVerMes := STR0054 //"Maio"
	Case nVerMes == 6
		cVerMes := STR0055 //"Junho"
	Case nVerMes == 7
		cVerMes := STR0056 //"Julho"
	Case nVerMes == 8
		cVerMes := STR0057 //"Agosto"
	Case nVerMes == 9
		cVerMes := STR0058 //"Setembro"
	Case nVerMes == 10
		cVerMes := STR0059 //"Outrubro"
	Case nVerMes == 11
		cVerMes := STR0060 //"Novembro"
	Case nVerMes == 12
		cVerMes := STR0061 //"Dezembro"
	Otherwise
		cVerMes := STR0062 //"Indefinido"
EndCase

Return cVerMes

//---------------------------------------------------------------------
/*/{Protheus.doc} SomaLinha
Incrementa a Linha no relatorio                              

@author Wagner S. de Lacerda
@since 18/08/2011
@Param nLinhas ---> Opcional;                                     
        Indica a quantidade de linhas.                
              Default: 1                                    
		lForcaTit -> Opcional;                                     
        Indica se deve forcar a impressao do titulo.  
               .T. - Imprime o Titulo.                      
               .F. - Nao imprime.                           
              Default: .F.  
@return cVerMes -> Mes por extenso.  
/*/
//---------------------------------------------------------------------

Static Function SomaLinha(nLinhas,lForcaTit)

Local lCabec := .F.

Default nLinhas := 1

Li += nLinhas
lCabec := .F.

If Li > 58
	Cabec(cTitulo,cCabec1,cCabec2,cNomeProg,cTamanho,nTipo, , /*Imprime Parametros (.T./.F.)*/)
	
	lCabec := .T.
EndIf

If lCabec .Or. lForcaTit
	@ Li,005 PSAY cTitPagina PICTURE "@!"
	Li++
	@ Li,000 PSAY Replicate("*",nLimite)
	Li += 2
EndIf

Return .T.

//---------------------------------------------------------------------
/*/{Protheus.doc} MNTR682FA
Validaca da Pergunta: De/Ate Familia                             

@author Wagner S. de Lacerda
@since 18/08/2011
@Param nParam -> Obrigatorio;
		Indica qual dos tipos de pergunta sera validado: 
   		1 - De                                          
   		2 - Ate   
@return .T. -> Familia OK. 
		 .F. -> Familia Invalida.
/*/
//---------------------------------------------------------------------

Function MNTR682FA(nParam)

If nParam == 1
	If Empty(MV_PAR03)
		Return .T.
	ElseIf !ExistCpo("ST6",MV_PAR03,1)
		Return .F.
	EndIf
Else
	If Vazio() .Or. !AteCodigo("ST6",MV_PAR03,MV_PAR04)
		Return .F.
	EndIf
EndIf

Return .T.

//---------------------------------------------------------------------
/*/{Protheus.doc} MNTR682MO
Validaca da Pergunta: De/Ate Modelo                           

@author Wagner S. de Lacerda
@since 18/08/2011
@Param nParam -> Obrigatorio;
		Indica qual dos tipos de pergunta sera validado: 
   		1 - De                                          
   		2 - Ate   
@return .T. -> Modelo OK. 
		 .F. -> modelo Invalida.
/*/
//---------------------------------------------------------------------

Function MNTR682MO(nParam)

	Local lRet := .T.

	If nParam == 1
		If !Empty(MV_PAR05) .And. !ExistCpo("TQR",MV_PAR05,1)
			lRet := .F.
		EndIf
	Else
		If Vazio() .Or. !AteCodigo("TQR", MV_PAR05, MV_PAR06)
			lRet := .F.
		EndIf
	EndIf

Return lRet

//---------------------------------------------------------------------
/*/{Protheus.doc} MNTR682DT
Validaca da Pergunta: De/Ate Data                           

@author Wagner S. de Lacerda
@since 18/08/2011
@Param nParam -> Obrigatorio;
		Indica qual dos tipos de pergunta sera validado: 
   		1 - De                                          
   		2 - Ate   
@return .T. -> Data OK. 
		 .F. -> Data Invalida.
/*/
//---------------------------------------------------------------------

Function MNTR682DT(nParam)

Local nDiaIni  := nMesIni := nAnoIni := 0
Local cVerData := ""
Local dVerData := CTOD("")

If nParam == 1
	If Empty(MV_PAR07)
		ShowHelpDlg(STR0034,; //"Atenção"
						{STR0064},2,; //"A data inicial não pode ser vazia."
						{STR0065},2) //"Insira uma data."
		Return .F.
	ElseIf !Empty(MV_PAR08) .And. MV_PAR07 > MV_PAR08
		ShowHelpDlg(STR0034,; //"Atenção"
						{STR0066},2,; //"A data inicial não pode ser maior que a final."
						{STR0067},2) //"Insira uma data menor ou igual a final."
		Return .F.
	EndIf
	
	nDiaIni := 31 //Maior dia possivel
	nMesIni := Month(MV_PAR07) + 11
	nAnoIni := Year(MV_PAR07)
	
	If nMesIni > 12
		nMesIni := nMesIni - 12
		nAnoIni++
	EndIf
	
	cVerData := cValToChar(nDiaIni)+"/"+cValToChar(nMesIni)+"/"+cValToChar(nAnoIni)
	dVerData := CTOD(cVerData)
	While nDiaIni > 28 .And. Empty(dVerData)
		nDiaIni--
		
		cVerData := cValToChar(nDiaIni)+"/"+cValToChar(nMesIni)+"/"+cValToChar(nAnoIni)
		dVerData := CTOD(cVerData)
	End
	MV_PAR08 := dVerData
Else
	If Empty(MV_PAR08)
		ShowHelpDlg(STR0034,; //"Atenção"
						{STR0068},2,; //"A data final não pode ser vazia."
						{STR0065},2) //"Insira uma data."
		Return .F.
	ElseIf MV_PAR08 < MV_PAR07
		ShowHelpDlg(STR0034,; //"Atenção"
						{STR0069},2,; //"A data final não pode ser menor que a inicial."
						{STR0070},2) //"Insira uma data maior ou igual a inicial."
		Return .F.
	Else
		nDiaIni := 01 //Menor dia possivel
		nMesIni := Month(MV_PAR08) - 11
		nAnoIni := Year(MV_PAR08)
		
		If nMesIni < 1
			nMesIni := nMesIni + 12
			nAnoIni--
		EndIf
		
		cVerData := cValToChar(nDiaIni)+"/"+cValToChar(nMesIni)+"/"+cValToChar(nAnoIni)
		dVerData := CTOD(cVerData)
		While nDiaIni > 28 .And. Empty(dVerData)
			nDiaIni--
			
			cVerData := cValToChar(nDiaIni)+"/"+cValToChar(nMesIni)+"/"+cValToChar(nAnoIni)
			dVerData := CTOD(cVerData)
		End
		
		If MV_PAR07 < dVerData
			MV_PAR07 := dVerData
		EndIf
	EndIf
EndIf

Return .T.