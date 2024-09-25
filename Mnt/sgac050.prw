#INCLUDE "SGAC050.ch"
#include "protheus.ch"
#define _nVERSAO 2
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณSGAC050   บAutor  ณRoger Rodrigues     บ Data ณ  12/11/09   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณConsulta para visualiza็ใo de todas analises realizadas     บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณSIGASGA                                                     บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Function SGAC050
Local aNGBEGINPRM	:= NGBEGINPRM(_nVERSAO)
Local oTempTRB
Private aCampos := {}, aFields := {}
Private aRotina	:= MenuDef()
Private cCadastro	:= OemToAnsi(STR0001) //"Anแlises Realizadas"
Private cAnalise	:= GetNextAlias()
Private aVETINR := {}
dbSelectArea("TCD")
dbSelectArea("TCH")
//Cria Estrutura da tabela
aADD(aCampos, {"FILIAL"	, "C" , Len(TCH->TCH_FILIAL), 0})
aADD(aCampos, {"ANALISE"	, "C" , Len(TCH->TCH_ANALIS), 0})
aADD(aCampos, {"MONIT"		, "C" , Len(TCH->TCH_MONIT) , 0})
aADD(aCampos, {"DESCMONIT", "C" , 40				 	  , 0})
aADD(aCampos, {"GRUPO"		, "C" , Len(TCH->TCH_GRUPO) , 0})
aADD(aCampos, {"DESGRUPO"	, "C" , 40				 	  , 0})
aADD(aCampos, {"FONTE"		, "C" , Len(TCH->TCH_FONTE) , 0})
aADD(aCampos, {"DESFONTE"	, "C" , 40				 	  , 0})
aADD(aCampos, {"FORNEC"	, "C" , Len(TCH->TCH_FORNEC), 0})
aADD(aCampos, {"DESFORN"	, "C" , 30					  , 0})
aADD(aCampos, {"DATAINI"	, "D" , 8, 0})
aADD(aCampos, {"DATAFIM"	, "D" , 8, 0})
aADD(aCampos, {"ASTATUS"	, "C" , Len(TCH->TCH_STATUS), 0})

oTempTRB := FWTemporaryTable():New( cAnalise, aCampos )
oTempTRB:AddIndex( "1", {"ANALISE"} )
oTempTRB:AddIndex( "2", {"MONIT"} )
oTempTRB:AddIndex( "3", {"GRUPO"} )
oTempTRB:AddIndex( "4", {"FONTE"} )
oTempTRB:Create()

//Campos para visualiza็ใo em tela
aFields := {{STR0002	,"FILIAL"	,"C",Len(TCH->TCH_FILIAL)	, 0, "@!"},;
			{STR0003	,"ANALISE"		,"C",Len(TCH->TCH_ANALIS)	, 0, "@!"},; //"Analise"
			{STR0010	,"MONIT"		, "C" , Len(TCH->TCH_MONIT) , 0},;//"Monitoramento"
			{STR0016	,"DESCMONIT", "C" , 40				 	  , 0},;//"Desc. Monit"
			{STR0004	,"GRUPO"		,"C",Len(TCH->TCH_GRUPO)	, 0, "@!"},; //"Grupo"
			{STR0005	,"DESGRUPO"	,"C", 40					, 0, "@!"},; //"Desc. Grupo"
			{STR0006	,"FONTE"   	,"C",Len(TCH->TCH_FONTE)	, 0, "@!"},; //"Fonte"
			{STR0007	,"DESFONTE"	,"C", 40					, 0, "@!"},; //"Desc. Fonte"
			{STR0008	,"FORNEC"  	,"C", Len(TCH->TCH_FORNEC), 0, "@!"},; //"Fornecedor"
			{STR0009	,"DESFORN" 	,"C", 30  					, 0, "@!"},; //"Desc. Fornec"
			{STR0011	,"DATAINI"		,"D", 8						, 0, "99/99/9999"},; //"Data Inicial"
			{STR0012	,"DATAFIM"		,"D", 8						, 0, "99/99/9999"}} //"Data Final"

dbSelectArea("TCH")
//Fun็ใo que carrega TRB com analises efetuadas
Processa({|| SGC50TRB()})

dbSelectArea(cAnalise)
dbSetOrder(1)
dbGoTop()
mBrowse(6,1,22,75,cAnalise,aFields,,,,,SGC050SEM())
//Deleta o arquivo temporario fisicamente
oTempTRB:Delete()

NGRETURNPRM(aNGBEGINPRM)
Return .T.
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑฺฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤฟฑฑ
ฑฑณFun…o    ณ MenuDef  ณ Autor ณ Roger Rodrigues       ณ Data ณ12/11/2009ณฑฑ
ฑฑรฤฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤดฑฑ
ฑฑณDescri…o ณUtilizacao de Menu Funcional.                               ณฑฑ
ฑฑรฤฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤดฑฑ
ฑฑณ Uso      ณ SigaSGA                                                    ณฑฑ
ฑฑรฤฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤดฑฑ
ฑฑณRetorno   ณArray com opcoes da rotina.                                 ณฑฑ
ฑฑรฤฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤดฑฑ
ฑฑณParametrosณParametros do array a Rotina:                               ณฑฑ
ฑฑณ          ณ1. Nome a aparecer no cabecalho                             ณฑฑ
ฑฑณ          ณ2. Nome da Rotina associada                                 ณฑฑ
ฑฑณ          ณ3. Reservado                                                ณฑฑ
ฑฑณ          ณ4. Tipo de Transao a ser efetuada:                        ณฑฑ
ฑฑณ          ณ	  1 - Pesquisa e Posiciona em um Banco de Dados           ณฑฑ
ฑฑณ          ณ    2 - Simplesmente Mostra os Campos                       ณฑฑ
ฑฑณ          ณ5. Nivel de acesso                                          ณฑฑ
ฑฑณ          ณ6. Habilita Menu Funcional                                  ณฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function MenuDef()
Local aRotina :=	{ { STR0013	, "SGC50PESQ"	, 0 , 1},; //"Pesquisar"
                      { STR0014	, "SGC50VIS"	, 0 , 2},; //"Visualizar"
                      { STR0017	, "SGC050LEG"	, 0 , 3}} //"Legenda"
Return aRotina
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณSGC50TRB  บAutor  ณRoger Rodrigues     บ Data ณ  12/11/09   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณCarrega Tabela Temporแria com todas analises efetuadas      บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณSGAC050                                                     บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function SGC50TRB()

#IFDEF TOP
	cAliasQry := GetNextAlias()
	cQuery := "SELECT DISTINCT(TCH.TCH_ANALIS), TCH.TCH_FILIAL, TCH.TCH_GRUPO, TCH.TCH_FONTE, TCH.TCH_MONIT, TCH.TCH_FORNEC, TCH.TCH_STATUS, "
	cQuery += "(SELECT MIN(TCH2.TCH_DTCOLE) FROM "+RetSqlName("TCH")+" TCH2 WHERE TCH2.TCH_ANALIS = TCH.TCH_ANALIS AND TCH2.TCH_FILIAL = TCH.TCH_FILIAL "
	cQuery += "AND TCH2.D_E_L_E_T_ <> '*') AS DATAINI, "
	cQuery += "(SELECT MAX(TCH3.TCH_DTCOLE) FROM "+RetSqlName("TCH")+" TCH3 WHERE TCH3.TCH_ANALIS = TCH.TCH_ANALIS AND TCH3.TCH_FILIAL = TCH.TCH_FILIAL "
	cQuery += "AND TCH3.D_E_L_E_T_ <> '*') AS DATAFIM "
	cQuery += "FROM "+RetSqlName("TCH")+" TCH "
	cQuery += "WHERE TCH.TCH_FILIAL = '"+xFilial("TCH")+"' AND TCH.D_E_L_E_T_ <> '*'"
	cQuery := ChangeQuery(cQuery)
	MPSysOpenQuery( cQuery , cAliasQry )
		
	dbSelectArea(cAliasQry)
	dbGoTop()
	While !eof()
		RecLock(cAnalise, .T.)
		(cAnalise)->FILIAL := (cAliasQry)->TCH_FILIAL
		(cAnalise)->ANALISE	:= (cAliasQry)->TCH_ANALIS
		(cAnalise)->MONIT	:= (cAliasQry)->TCH_MONIT
		(cAnalise)->DESCMONIT:= NGSEEK("TCD",(cAliasQry)->TCH_MONIT,1,"TCD->TCD_DESCRI")
		(cAnalise)->GRUPO	:= (cAliasQry)->TCH_GRUPO
		(cAnalise)->DESGRUPO:= NGSEEK("TCA",(cAliasQry)->TCH_GRUPO,1,"TCA->TCA_DESCRI")
		(cAnalise)->FONTE	:= (cAliasQry)->TCH_FONTE
		(cAnalise)->DESFONTE:= NGSEEK("TCB",(cAliasQry)->TCH_FONTE,1,"TCB->TCB_DESCRI")
		(cAnalise)->FORNEC	:= (cAliasQry)->TCH_FORNEC
		(cAnalise)->DESFORN	:= NGSEEK("SA2",(cAliasQry)->TCH_FORNEC,1,"Substr(SA2->A2_NOME,1,30)")
		(cAnalise)->DATAINI	:= STOD((cAliasQry)->DATAINI)
		(cAnalise)->DATAFIM	:= STOD((cAliasQry)->DATAFIM)
		(cAnalise)->ASTATUS	:= (cAliasQry)->TCH_STATUS
		MsUnlock(cAnalise)
		dbSelectArea(cAliasQry)
		dbSkip()
	End
	dbSelectArea(cAliasQry)
	dbCloseArea()
#ELSE
	dbSelectArea("TCH")
	dbSetOrder(1)
	dbSeek(xFilial("TCH"))
	While !eof() .and. TCH->TCH_FILIAL == xFilial("TCH")
		dbSelectArea(cAnalise)
		If !dbSeek(TCH->TCH_ANALIS)
			RecLock(cAnalise, .T.)
			(cAnalise)->FILIAL := TCH->TCH_FILIAL
			(cAnalise)->ANALISE	:= TCH->TCH_ANALIS
			(cAnalise)->MONIT	:= TCH->TCH_MONIT
			(cAnalise)->DESCMONIT:= NGSEEK("TCD",TCH->TCH_MONIT,1,"TCD->TCD_DESCRI")
			(cAnalise)->GRUPO	:= TCH->TCH_GRUPO
			(cAnalise)->DESGRUPO:= NGSEEK("TCA",TCH->TCH_GRUPO,1,"TCA->TCA_DESCRI")
			(cAnalise)->FONTE	:= TCH->TCH_FONTE
			(cAnalise)->DESFONTE:= NGSEEK("TCB",TCH->TCH_FONTE,1,"TCB->TCB_DESCRI")
			(cAnalise)->FORNEC	:= TCH->TCH_FORNEC
			(cAnalise)->DESFORN	:= NGSEEK("SA2",TCH->TCH_FORNEC,1,"Substr(SA2->A2_NOME,1,30)")
			(cAnalise)->DATAINI	:= TCH->TCH_DTCOLE
			(cAnalise)->DATAFIM	:= TCH->TCH_DTCOLE
			(cAnalise)->ASTATUS	:= TCH->TCH_STATUS
			MsUnlock(cAnalise)
		Else
			If Empty((cAnalise)->DATAINI) .OR. (cAnalise)->DATAINI > TCH->TCH_DTCOLE
				RecLock(cAnalise,.F.)
				(cAnalise)->DATAINI := TCH->TCH_DTCOLE
				MsUnlock(cAnalise)
			Endif
			If Empty((cAnalise)->DATAFIM) .OR. (cAnalise)->DATAFIM < TCH->TCH_DTCOLE
				RecLock(cAnalise,.F.)
				(cAnalise)->DATAFIM := TCH->TCH_DTCOLE
				MsUnlock(cAnalise)
			Endif
		Endif
		dbSelectArea("TCH")
		dbSkip()
	End
#ENDIF

Return .T.

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณSGC50VIS  บAutor  ณRoger Rodrigues     บ Data ณ  12/11/09   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณMonta tela para visualiza็ใo da Analise                     บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณSGAC050                                                     บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Function SGC50VIS(cAlias,nRecno,nOpcx)
Local oDlg50
Local i:=1
Private aSize := MsAdvSize(,.f.,430), aObjects := {}
Private aVarNao := {}, aGetNao := {}
Private aCols := {}

Aadd(aObjects,{050,050,.T.,.T.}) // Indica dimensoes x e y e indica que redimensiona x e y e assume que retorno sera em linha final coluna final (.F.)
Aadd(aObjects,{100,100,.T.,.T.}) // Indica dimensoes x e y e indica que redimensiona x e y e assume que retorno sera em linha final coluna final (.F.)

aInfo := {aSize[1],aSize[2],aSize[3],aSize[4],0,0}
aPosObj := MsObjSize(aInfo, aObjects,.t.)

aVarNao := {'TCH_DTCOLE','TCH_HRCOLE','TCH_CODCRI','TCH_DESCRI','TCH_QUANTI','TCH_UNIMED'}
aChoice  := NGCAMPNSX3("TCH",aVarNao)
aHeader := CABECGETD("TCH",{'TCH_ANALIS','TCH_FORNEC', 'TCH_MONIT' ,'TCH_FONTE','TCH_GRUPO', 'TCH_STATUS', 'TCH_DESFOR', 'TCH_DESFON', 'TCH_DESGRU', 'TCH_DESMON'})

nDTCOLE := aSCAN(aHeader,{|x| TRIM(UPPER(x[2])) == "TCH_DTCOLE"})
nHRCOLE := aSCAN(aHeader,{|x| TRIM(UPPER(x[2])) == "TCH_HRCOLE"})
nCODCRI := aSCAN(aHeader,{|x| TRIM(UPPER(x[2])) == "TCH_CODCRI"})
nDESCRI := aSCAN(aHeader,{|x| TRIM(UPPER(x[2])) == "TCH_DESCRI"})
nQUANTI := aSCAN(aHeader,{|x| TRIM(UPPER(x[2])) == "TCH_QUANTI"})
nUNIMED := aSCAN(aHeader,{|x| TRIM(UPPER(x[2])) == "TCH_UNIMED"})
nCODPLA := aSCAN(aHeader,{|x| TRIM(UPPER(x[2])) == "TCH_CODPLA"})
nDESPLA := aSCAN(aHeader,{|x| TRIM(UPPER(x[2])) == "TCH_DESPLA"})
nALIWT  := aSCAN(aHeader,{|x| TRIM(UPPER(x[2])) == "TCH_ALI_WT"})   
nRECWT  := aSCAN(aHeader,{|x| TRIM(UPPER(x[2])) == "TCH_REC_WT"})

M->TCH_ANALIS := (cAnalise)->ANALISE

i:= 1
dbSelectArea("TCH")
dbSetOrder(1)
dbSeek(xFilial("TCH")+M->TCH_ANALIS)
While !eof() .and. xFilial("TCH") == TCH->TCH_FILIAL .and. TCH->TCH_ANALIS == M->TCH_ANALIS
	aAdd( aCols, BlankGetD(aHeader)[1] )
	
	aCols[i][nDTCOLE] := TCH->TCH_DTCOLE
	aCols[i][nHRCOLE] := TCH->TCH_HRCOLE
	aCols[i][nCODCRI] := TCH->TCH_CODCRI
	aCols[i][nDESCRI] := NGSEEK("TCC",TCH->TCH_CODCRI,1,"TCC->TCC_DESCRI")
	aCols[i][nQUANTI] := TCH->TCH_QUANTI
	aCols[i][nUNIMED] := NGSEEK("TCC",TCH->TCH_CODCRI,1,"TCC->TCC_UNIMED")
	If nCODPLA > 0 .And. nDESPLA > 0 
		aCols[i][nCODPLA] := TCH->TCH_CODPLA
		aCols[i][nDESPLA] := POSICIONE("TAA",1,XFILIAL("TAA")+TCH->TCH_CODPLA,"TAA_NOME") 
	EndIf
	
	If nALIWT > 0
		aCols[i][nALIWT]  := "TCH"
	Endif
	
	If nRECWT > 0
		aCols[i][nRECWT]  := TCH->(Recno())
	Endif
	
	i++
	dbSelectArea("TCH")
	dbSkip()
End
dbSelectArea("TCH")
dbSetOrder(1)
dbSeek(xFilial("TCH")+M->TCH_ANALIS)

Define MsDialog oDlg50 Title STR0015 From aSize[7],0 To aSize[6],aSize[5] Of oMainWnd Pixel //"Medi็๕es Realizadas"

oPnlPai := TPanel():New(00,00,,oDlg50,,,,,,12,13,.F.,.F.)
	oPnlPai:Align := CONTROL_ALIGN_ALLCLIENT
	                                                   
oEnchoice:= Msmget():New("TCH", 1, 2,,,,aChoice,{0,0,115,655},,3,,,,oPnlPai)
	oEnchoice:oBox:Align := CONTROL_ALIGN_TOP

oGet := MSGetDados():New(aPosObj[2,1],aPosObj[2,2],aPosObj[2,3],aPosObj[2,4],2,"AllwaysTrue","AllwaysTrue","",.T.,,,,Len(aCols),,,,,oPnlPai)
	oGet:oBrowse:Align := CONTROL_ALIGN_ALLCLIENT
	
Activate MsDialog oDlg50 On Init EnchoiceBar(oDlg50,{ ||oDlg50:End() },{||oDlg50:End()})

Return .T.
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณSGC050SEM บAutor  ณRoger Rodrigues     บ Data ณ  20/11/09   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณDefine as cores para o semแforo                             บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณSGAC050                                                     บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Function SGC050SEM()
Local aCores :={{"NGSEMAFARO('(cAnalise)->ASTATUS = "+'"1"'+"')" , "BR_AZUL" },;
				 {"NGSEMAFARO('(cAnalise)->ASTATUS = "+'"2"'+"')" , "BR_VERDE" },;
				 {"NGSEMAFARO('(cAnalise)->ASTATUS = "+'"3"'+"')" , "BR_VERMELHO" }}
	
Return aCores
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณSGC050LEG บAutor  ณRoger Rodrigues     บ Data ณ  20/11/09   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณMonta Browse com Legenda                                    บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณSGAC050                                                     บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Function SGC050LEG()
BrwLegenda(cCadastro,STR0017,{{"BR_AZUL", STR0018 },;//"Legenda"##"Em Analise"
									 {"BR_VERDE", STR0019},;//"Finalizada"
									 {"BR_VERMELHO", STR0020}})//"Cancelada"
Return .T.

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณSGC50PESQ บAutor  ณRoger Rodrigues     บ Data ณ  23/11/09   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณPesquisa informa็๕es no TRB e retorna no Browse             บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณSGAC050                                                     บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Function SGC50PESQ()
local oDlgPesq, oOrdem, oChave, oBtOk, oBtCan, oBtPar
Local cOrdem	:= STR0003//"Analise"
Local cChave	:= Space(10)
Local aOrdens	:= {}
Local nOrdem := 1
Local nOpcA := 0

aOrdens := {STR0003,;//"Analise"
			STR0010,;//"Monitoramento"
			STR0004,;//"Grupo"
			STR0006}//"Fonte"

Define msDialog oDlgPesq Title STR0013 From 00,00 To 100,500 pixel //"Pesquisar"

@ 005, 005 combobox oOrdem var cOrdem items aOrdens size 210,08 PIXEL OF oDlgPesq ON CHANGE nOrdem := oOrdem:nAt
@ 020, 005 msget oChave var cChave size 210,08 of oDlgPesq pixel

define sButton oBtOk  from 05,218 type 1 action (nOpcA := 1, oDlgPesq:End()) enable of oDlgPesq pixel
define sButton oBtCan from 20,218 type 2 action (nOpcA := 0, oDlgPesq:End()) enable of oDlgPesq pixel
define sButton oBtPar from 35,218 type 5 when .F. of oDlgPesq pixel

Activate MsDialog oDlgPesq Center

If nOpca == 1
	cChave := AllTrim(cChave)
	DbSelectArea(cAnalise)
	dbSetOrder(nOrdem)
	DbSeek(cChave)	
EndIf

DbSelectArea(cAnalise)
DbSetOrder(1)

Return .T.