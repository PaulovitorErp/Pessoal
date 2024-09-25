#INCLUDE "SGAC150.ch"
#INCLUDE "PROTHEUS.CH"

#DEFINE _nVERSAO 02 //Versao do fonte

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³ SGAC150  ³ Autor ³ Felipe Nathan Welter  ³ Data ³ 26/01/10 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Consulta de Historico das Avaliacoes de Aspecto/Impacto    ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ SIGASGA                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function SGAC150()

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Guarda conteudo e declara variaveis padroes ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
Local aNGBEGINPRM := NGBEGINPRM(_nVERSAO)
Local cQuery1
Local oTempTable

Private aRotina := MenuDef()
Private cPerg := "SGR150"

cCadastro := OemtoAnsi(STR0001) //"Histórico das Avaliações de Aspectos/Impactos"

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Variaveis utilizadas para parametros                       			   ³
//³ MV_PAR01     //  De Aspecto ?                                          ³
//³ MV_PAR02     //  Ate Aspecto ?                                         ³
//³ MV_PAR03     //  De Impacto ?                                          ³
//³ MV_PAR04     //  Ate Impacto ?                                         ³
//³ MV_PAR05     //  De Nivel Estrutura ?                                  ³
//³ MV_PAR06     //  Ate Nivel Estrutura ?                                 ³
//³ MV_PAR07     //  De Data ?                                             ³
//³ MV_PAR08     //  Ate Data ?                                            ³
//³ MV_PAR09     //  Apresenta Ord. Hist. ?                                ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

If !Pergunte(cPerg,.T.)
	NGRETURNPRM(aNGBEGINPRM)
	Return .F.
Else
	//Ajusta parametros de/até Nível Estrutura
	If MV_PAR05 > MV_PAR06
		cTempPar  := MV_PAR05
		MV_PAR05 := MV_PAR06
		MV_PAR06 := cTempPar
	EndIf
EndIf


aDBF1 := {{"CODNIV","C",TAMSX3("TAB_CODNIV")[1],0},;
			 {"DESNIV","C",TAMSX3("TAF_NOMNIV")[1],0},;
			 {"CODASP","C",TAMSX3("TAB_CODASP")[1],0},;
			 {"DESASP","C",TAMSX3("TA4_DESCRI")[1],0},;
			 {"CODIMP","C",TAMSX3("TAB_CODIMP")[1],0},;
			 {"DESIMP","C",TAMSX3("TAE_DESCRI")[1],0}}
			 
aDBF1B :=  {{"Cod. Nivel","CODNIV" ,"C",TAMSX3("TAB_CODNIV")[1],0,"@!"},;
				{STR0013 ,"DESNIV" ,"C",TAMSX3("TAF_NOMNIV")[1],0,"@!"},; //"Descrição"
				{STR0014 ,"CODASP" ,"C",TAMSX3("TAB_CODASP")[1],0,"@!"},; //"Aspecto"
				{STR0013 ,"DESASP" ,"C",TAMSX3("TA4_DESCRI")[1],0,"@!"},; //"Descrição"
				{STR0015 ,"CODIMP" ,"C",TAMSX3("TAB_CODIMP")[1],0,"@!"},; //"Impacto"
				{STR0013 ,"DESIMP" ,"C",TAMSX3("TAE_DESCRI")[1],0,"@!"}}  //"Descrição"

cTRB150 := GetNextAlias()
oTempTable := FWTemporaryTable():New( cTRB150, aDBF1 )
oTempTable:AddIndex( "1", {"CODNIV","CODASP","CODIMP"} )
oTempTable:Create()

cQuery1 := " SELECT TAB.TAB_CODNIV AS CODNIV, TAB.TAB_CODASP AS CODASP, TAB.TAB_CODIMP AS CODIMP,"
cQuery1 += " TAF.TAF_NOMNIV AS DESNIV, TA4.TA4_DESCRI AS DESASP, TAE.TAE_DESCRI AS DESIMP"
cQuery1 += " FROM "+RetSQLName("TAB")+" TAB "
cQuery1 += " LEFT JOIN "+RetSQLName("TAF")+" TAF ON TAF.TAF_CODEST = '001' AND TAF.TAF_CODNIV = TAB.TAB_CODNIV"
cQuery1 += " LEFT JOIN "+RetSQLName("TA4")+" TA4 ON TA4.TA4_CODASP = TAB.TAB_CODASP"
cQuery1 += " LEFT JOIN "+RetSQLName("TAE")+" TAE ON TAE.TAE_CODIMP = TAB.TAB_CODIMP"
cQuery1 += " WHERE TAB.TAB_CODASP BETWEEN '"+MV_PAR01+"' AND '"+MV_PAR02+"' "
cQuery1 += " AND TAB.TAB_CODIMP BETWEEN '"+MV_PAR03+"' AND '"+MV_PAR04+"' "
cQuery1 += " AND TAB.TAB_CODNIV BETWEEN '"+MV_PAR05+"' AND '"+MV_PAR06+"' "
cQuery1 += " AND TAB.TAB_DTRESU BETWEEN '"+DTOS(MV_PAR07)+"' AND '"+DTOS(MV_PAR08)+"' "
cQuery1 += " AND TAB.TAB_FILIAL = '"+xFilial("TAB")+"' AND TA4.TA4_FILIAL = '"+xFilial("TA4")+"' AND TAE.TAE_FILIAL = '"+xFilial("TAE")+"'"
cQuery1 += " AND TAB.D_E_L_E_T_ <> '*' AND TA4.D_E_L_E_T_ <> '*' AND TAE.D_E_L_E_T_ <> '*'"
cQuery1 += " GROUP BY TAB.TAB_CODNIV, TAF.TAF_NOMNIV, TAB.TAB_CODASP, TA4.TA4_DESCRI, TAE.TAE_DESCRI, TAB.TAB_CODIMP"

If MV_PAR09 == 1
	cQuery1 += " UNION "
	cQuery1 += " SELECT TAO.TAO_CODNIV AS CODNIV, TAO.TAO_CODASP AS CODASP, TAO.TAO_CODIMP AS CODIMP,"
	cQuery1 += " TAF.TAF_NOMNIV AS DESNIV, TA4.TA4_DESCRI AS DESASP, TAE.TAE_DESCRI AS DESIMP"
	cQuery1 += " FROM "+RetSQLName("TAO")+" TAO "
	cQuery1 += " LEFT JOIN "+RetSQLName("TAF")+" TAF ON TAF.TAF_CODEST = '001' AND TAF.TAF_CODNIV = TAO.TAO_CODNIV"
	cQuery1 += " LEFT JOIN "+RetSQLName("TA4")+" TA4 ON TA4.TA4_CODASP = TAO.TAO_CODASP"
	cQuery1 += " LEFT JOIN "+RetSQLName("TAE")+" TAE ON TAE.TAE_CODIMP = TAO.TAO_CODIMP"
	cQuery1 += " WHERE TAO.TAO_CODASP BETWEEN '"+MV_PAR01+"' AND '"+MV_PAR02+"' "
	cQuery1 += " AND TAO.TAO_CODIMP BETWEEN '"+MV_PAR03+"' AND '"+MV_PAR04+"' "
	cQuery1 += " AND TAO.TAO_CODNIV BETWEEN '"+MV_PAR05+"' AND '"+MV_PAR06+"' "
	cQuery1 += " AND TAO.TAO_DTRESU BETWEEN '"+DTOS(MV_PAR07)+"' AND '"+DTOS(MV_PAR08)+"' "
	cQuery1 += " AND TAO.TAO_FILIAL = '"+xFilial("TAO")+"' AND TA4.TA4_FILIAL = '"+xFilial("TA4")+"' AND TAE.TAE_FILIAL = '"+xFilial("TAE")+"'"
	cQuery1 += " AND TAO.D_E_L_E_T_ <> '*' AND TA4.D_E_L_E_T_ <> '*' AND TAE.D_E_L_E_T_ <> '*'"
	cQuery1 += " GROUP BY TAO.TAO_CODNIV, TAF.TAF_NOMNIV, TAO.TAO_CODASP, TA4.TA4_DESCRI, TAE.TAE_DESCRI, TAO.TAO_CODIMP"
EndIf

SqlToTrb(cQuery1,aDBF1,cTRB150)


dbSelectarea(cTRB150)
dbGoTop()
mBrowse(6,1,22,75,cTRB150,aDBF1B)

oTempTable:Delete()

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Retorna conteudo de variaveis padroes       ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
NGRETURNPRM(aNGBEGINPRM)

Return .T.

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³SGAC150HIS³ Autor ³ Felipe Nathan Welter  ³ Data ³ 26/01/10 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³Monta listagem das avaliações de aspectos/impactos          ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³SGAC150                                                     ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function SGAC150HIS()

Local nAltura   := (GetScreenRes()[2]*.4)
Local nLargura  := (GetScreenRes()[1]*.8)
Local cQuery1, cQuery2
Local oTempTRBH

Private cCadastro := OemToAnsi(STR0017) //"Listagem de Avaliações de Aspectos/Impactos"
Private oListHist, oDlg

aDBFH := {{"ORDEM","C",TAMSX3("TAB_ORDEM")[1],0},;
			{"DTRESU","D",TAMSX3("TAB_DTRESU")[1],0},;
			{"CODNIV","C",TAMSX3("TAB_CODNIV")[1],0},;
			{"DESNIV","C",TAMSX3("TAF_NOMNIV")[1],0},;
			{"CODPLA","C",TAMSX3("TAB_CODPLA")[1],0},;
			{"CODEME","C",TAMSX3("TAB_CODEME")[1],0},;
			{"CODASP","C",TAMSX3("TAB_CODASP")[1],0},;
			{"DESASP","C",TAMSX3("TA4_DESCRI")[1],0},;
			{"CODIMP","C",TAMSX3("TAB_CODIMP")[1],0},;
			{"DESIMP","C",TAMSX3("TAE_DESCRI")[1],0},;
			{"DESCLA","C",TAMSX3("TA8_DESCRI")[1],0},;
			{"CODHIS","C",TAMSX3("TAO_CODHIS")[1],0}}

aDBFHB := {{STR0018,"ORDEM" ,"C",TAMSX3("TAB_ORDEM")[1] ,0,"@!"},; //"Ordem"
			{STR0019  ,"CODHIS","C",TAMSX3("TAO_CODHIS")[1],0,"@!"},; //"Cod. Historico"
			{STR0020  ,"DTRESU","D",TAMSX3("TAB_DTRESU")[1],0,"99/99/9999"},; //"Dt. Desemp."
			{STR0021  ,"CODNIV","C",TAMSX3("TAB_CODNIV")[1],0,"@!"},; //"Nivel Estr."
			{STR0013  ,"DESNIV","C",TAMSX3("TAF_NOMNIV")[1],0,"@!"},; //"Descrição"
			{STR0014  ,"CODASP","C",TAMSX3("TAB_CODASP")[1],0,"@!"},; //"Aspecto"
			{STR0013  ,"DESASP","C",TAMSX3("TA4_DESCRI")[1],0,"@!"},; //"Descrição"
			{STR0015  ,"CODIMP","C",TAMSX3("TAB_CODIMP")[1],0,"@!"},; //"Impacto"
			{STR0013  ,"DESIMP","C",TAMSX3("TAE_DESCRI")[1],0,"@!"},; //"Descrição"
			{STR0022  ,"DESCLA","C",TAMSX3("TA8_DESCRI")[1],0,"@!"},; //"Signific."
			{STR0026  ,"CODPLA","C",TAMSX3("TAB_CODPLA")[1],0,"@!"},;//"Pl. Ação"
			{STR0023  ,"CODEME","C",TAMSX3("TAB_CODEME")[1],0,"@!"}} //"Pl. Emerge."

cTRBH := GetNextAlias()
oTempTRBH := FWTemporaryTable():New( cTRBH, aDBFH )
oTempTRBH:AddIndex( "1", {"CODHIS","ORDEM","CODASP","CODIMP","DTRESU"} )
oTempTRBH:Create()

//Query seleciona Ordens de Resultados de Avaliacoes (TAB)
cQuery1 := " SELECT TAB_ORDEM AS ORDEM, TAB_DTRESU AS DTRESU, TAB_CODNIV AS CODNIV,"
cQuery1 += " TAB_CODPLA AS CODPLA, TAB_CODEME AS CODEME, TAB_CODASP AS CODASP,"
cQuery1 += " TAB_CODIMP AS CODIMP, "
cQuery1 += " TAF.TAF_NOMNIV AS DESNIV, TA4.TA4_DESCRI AS DESASP, TAE.TAE_DESCRI AS DESIMP, TA8_DESCRI AS DESCLA"
cQuery1 += " FROM "+RetSQLName("TAB")+" TAB"
cQuery1 += " LEFT JOIN "+RetSQLName("TA8")+" TA8 ON TA8.TA8_CODCLA = TAB.TAB_CODCLA"
cQuery1 += " LEFT JOIN "+RetSQLName("TAF")+" TAF ON TAF.TAF_CODEST = '001' AND TAF.TAF_CODNIV = TAB.TAB_CODNIV"
cQuery1 += " LEFT JOIN "+RetSQLName("TA4")+" TA4 ON TA4.TA4_CODASP = TAB.TAB_CODASP"
cQuery1 += " LEFT JOIN "+RetSQLName("TAE")+" TAE ON TAE.TAE_CODIMP = TAB.TAB_CODIMP"
cQuery1 += " WHERE TAB_CODASP = '"+(cTRB150)->CODASP+"'"
cQuery1 += " AND TAB_CODIMP = '"+(cTRB150)->CODIMP+"'"
cQuery1 += " AND TAB_CODNIV = '"+(cTRB150)->CODNIV+"' "
cQuery1 += " AND TAB_DTRESU BETWEEN '"+DTOS(MV_PAR07)+"' AND '"+DTOS(MV_PAR08)+"' "
cQuery1 += " AND TAB.TAB_FILIAL = '"+xFilial("TAB")+"' AND TA8.TA8_FILIAL = '"+xFilial("TA8")+"'"
cQuery1 += " AND TAB.D_E_L_E_T_ <> '*' AND TA8.D_E_L_E_T_ <> '*'"
SqlToTrb(cQuery1,aDBFH,cTRBH)

If MV_PAR09 == 1
	//Query seleciona Ordens de Resultados de Avaliacoes - Historico (TAO)
	cQuery1 := " SELECT TAO_ORDEM AS ORDEM, TAO_DTRESU AS DTRESU, TAO_CODNIV AS CODNIV,"
	cQuery1 += " TAO_CODPLA AS CODPLA, TAO_CODEME AS CODEME, TAO_CODASP AS CODASP,"
	cQuery1 += " TAO_CODIMP AS CODIMP, TAO_CODHIS AS CODHIS,"
	cQuery1 += " TAF.TAF_NOMNIV AS DESNIV, TA4.TA4_DESCRI AS DESASP, TAE.TAE_DESCRI AS DESIMP, TA8_DESCRI AS DESCLA"
	cQuery1 += " FROM "+RetSQLName("TAO")+" TAO"
	cQuery1 += " LEFT JOIN "+RetSQLName("TA8")+" TA8 ON TA8.TA8_CODCLA = TAO.TAO_CODCLA"
	cQuery1 += " LEFT JOIN "+RetSQLName("TAF")+" TAF ON TAF.TAF_CODEST = '001' AND TAF.TAF_CODNIV = TAO.TAO_CODNIV"
	cQuery1 += " LEFT JOIN "+RetSQLName("TA4")+" TA4 ON TA4.TA4_CODASP = TAO.TAO_CODASP"
	cQuery1 += " LEFT JOIN "+RetSQLName("TAE")+" TAE ON TAE.TAE_CODIMP = TAO.TAO_CODIMP"
	cQuery1 += " WHERE TAO_CODASP = '"+(cTRB150)->CODASP+"'"
	cQuery1 += " AND TAO_CODIMP = '"+(cTRB150)->CODIMP+"'"
	cQuery1 += " AND TAO_CODNIV = '"+(cTRB150)->CODNIV+"' "
	cQuery1 += " AND TAO_DTRESU BETWEEN '"+DTOS(MV_PAR07)+"' AND '"+DTOS(MV_PAR08)+"' "
	cQuery1 += " AND TAO.TAO_FILIAL = '"+xFilial("TAO")+"' AND TA8.TA8_FILIAL = '"+xFilial("TA8")+"'"
	cQuery1 += " AND TAO.D_E_L_E_T_ <> '*' AND TA8.D_E_L_E_T_ <> '*'"
	SqlToTrb(cQuery1,aDBFH,cTRBH)
EndIf

Define MsDialog oDlg From 0,0 to nAltura,nLargura Title cCadastro Pixel
	
	dbSelectArea(cTRBH)
	dbSetOrder(01)
	dbGoTop()
	
	@ 0,0 Listbox oListHist Fields (cTRBH)->ORDEM,;
											 (cTRBH)->CODHIS,;
											 (cTRBH)->DTRESU,;
											 (cTRBH)->CODNIV,;
											 (cTRBH)->DESNIV,;
											 (cTRBH)->CODASP,;
											 (cTRBH)->DESASP,;
											 (cTRBH)->CODIMP,;
											 (cTRBH)->DESIMP,;
											 (cTRBH)->DESCLA,;
											 (cTRBH)->CODPLA,;
											 (cTRBH)->CODEME ;
	                     FieldSizes 25,40,40,35,80,30,80,30,80,70,30,30   ;
	                     Size 570,300 Pixel Of oDlg  ;
	                     HEADERS STR0018,; //"Ordem"
	                     		  STR0024,; //"Cod.Historico"
	                     		  STR0025,; //"Dt.Desemp."
	                     		  STR0021,; //"Nivel Estr."
	                     		  STR0013,; //"Descrição"
	                     		  STR0014,; //"Aspecto"
	                     		  STR0013,; //"Descrição"
	                     		  STR0015,; //"Impacto"
	                     		  STR0013,; //"Descrição"
	                     		  STR0022,; //"Signific."
	                     		  STR0026,; //"Pl. Ação"
	                     		  STR0023 //"Pl. Emerge."
	                     		  
	oListHist:Align := CONTROL_ALIGN_ALLCLIENT
	
Activate Dialog oDlg On Init(ENCHOICEBAR(oDlg,{||oDlg:End()},{||oDlg:End()})) CENTERED

oTempTRBH:Delete()

Return

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Programa  ³MenuDef   ³ Autor ³ Felipe Nathan Welter  ³ Data ³ 26/01/10 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³Utilizacao de menu Funcional                                ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³Array com opcoes da rotina.                                 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³Parametros do array a Rotina:                               ³±±
±±³          ³1. Nome a aparecer no cabecalho                             ³±±
±±³          ³2. Nome da Rotina associada                                 ³±±
±±³          ³3. Reservado                                                ³±±
±±³          ³4. Tipo de Transa‡„o a ser efetuada:                        ³±±
±±³          ³		1 - Pesquisa e Posiciona em um Banco de Dados           ³±±
±±³          ³    2 - Simplesmente Mostra os Campos                       ³±±
±±³          ³    3 - Inclui registros no Bancos de Dados                 ³±±
±±³          ³    4 - Altera o registro corrente                          ³±±
±±³          ³    5 - Remove o registro corrente do Banco de Dados        ³±±
±±³          ³5. Nivel de acesso                                          ³±±
±±³          ³6. Habilita Menu Funcional                                  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³   DATA   ³ Programador   ³Manutencao efetuada                         ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³          ³               ³                                            ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Static Function MenuDef()

Local aRotina := {{STR0027,"SGAC150HIS" ,0,2,0},; //"Historico"
						{STR0028,"SGAR150(.F.)" ,0,2,0}} //"Relatorio"

Return(aRotina)
