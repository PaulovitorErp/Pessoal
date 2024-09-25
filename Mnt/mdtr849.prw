#INCLUDE "MDTR849.ch"
#include "Protheus.ch"
#INCLUDE "Shell.CH"

//---------------------------------------------------------------------
/*/{Protheus.doc} MDTR849
Relatório de Historico de Avaliacoes de Perigos/Danos
   
@return

@sample    
MDTR849()

@author Jackson Machado
@since 27/03/2013  
@version 1.0
/*/
//---------------------------------------------------------------------
Function MDTR849()

//-----------------------------------------------------
// Guarda conteudo e declara variaveis padroes
//-----------------------------------------------------
Local aNGBEGINPRM := NGBEGINPRM()
Local oTempTRB1, oTempTRB2

Private cPerg := "MDT849"

If !ChkOHSAS()
	//-----------------------------------------------------
	// Devolve variaveis armazenadas (NGRIGHTCLICK)
	//-----------------------------------------------------
	NGRETURNPRM( aNGBEGINPRM )
	Return .F.
EndIf
	
aDBF1 := { {"ORDEM","C",TAMSX3("TG6_ORDEM")[1],0},;
			{"DTRESU","D",TAMSX3("TG6_DTRESU")[1],0},;
			{"CODNIV","C",TAMSX3("TG6_CODNIV")[1],0},;
			{"CODPER","C",TAMSX3("TG6_CODPER")[1],0},;
			{"CODDAN","C",TAMSX3("TG6_CODDAN")[1],0},;
			{"CODCLA","C",TAMSX3("TG6_CODCLA")[1],0},;
			{"CODHIS","C",TAMSX3("TGD_CODHIS")[1],0},;
			{"RESULT","N",TAMSX3("TGN_RESULT")[1],2},;
			{"DESCRI","C",TAMSX3("TG6_DESCRI")[1],0},;
			{"REAVAL","C",TAMSX3("TGD_REAVAL")[1],0}}

cTRB1 := GetNextAlias()
oTempTRB1 := FWTemporaryTable():New( cTRB1, aDBF1 )
oTempTRB1:AddIndex( "1", {"CODHIS","ORDEM","CODPER","CODDAN"} )
oTempTRB1:Create()

aDBF2 := {{"ORDEM","C",TAMSX3("TG6_ORDEM")[1],0},;
			{"INDICA","C",TAMSX3("TG7_INDICA")[1],0},;
			{"CODAVA","C",TAMSX3("TG7_CODAVA")[1],0},;
			{"CODHIS","C",TAMSX3("TGE_CODHIS")[1],0},;
			{"CODOPC","C",TAMSX3("TG7_CODOPC")[1],0}}

cTRB2 := GetNextAlias()
oTempTRB2 := FWTemporaryTable():New( cTRB2, aDBF2 )
oTempTRB2:AddIndex( "1", {"CODHIS","ORDEM","INDICA","CODAVA","CODOPC"} )
oTempTRB2:Create()

dbSelectArea( "TG0" )
dbSetOrder( 1 )
dbSeek( xFilial( "TG0" ) , .T. )

/*----------------------------------
//PERGUNTAS PADRÃO					|
| De Perigo ?							|
| Até Perigo ?						|
| De Dano ?							|
| Até Dano ?							|
| De Nível Estrutura ?				|
| Ate Nível Estrutura ?				|
| De Data ?							|
| Até Data ?							|
| Apresenta Ord. Hist. ?				|
| Revisão								|
| Imprime Requisitos ?				|
| Imprime Monitoramentos ?			|
| Imprime Objetivos ?				|
| Imprime Plano de Ação ?			| 
| Imprime Plano Emergencial ?		| 
| Imprime Controles ?				| 
------------------------------------*/

If Pergunte(cPerg,.T.) // 2013/03 - Gera em Excell
	Processa({ |lEnd| GeraXLS()},STR0020) //"Processando Arquivo..."
Endif

oTempTRB1:Delete()
oTempTRB2:Delete()

//-----------------------------------------------------
// Retorna conteudo de variaveis padroes
//-----------------------------------------------------
NGRETURNPRM(aNGBEGINPRM)

Return .T.
//---------------------------------------------------------------------
/*/{Protheus.doc} MDTR849TRB
Processa os arquivos e carrega arquivo temporario

@return

@sample
MDTR849TRB()

@author Jackson Machado
@since 27/03/2013
@version 1.0
/*/
//---------------------------------------------------------------------
Static Function MDTR849TRB()

Local cQuery1, cQuery2
Local cFormIS := TG0->TG0_CODFOR

//Query seleciona Ordens de Resultados de Avaliacoes (TG6)
cQuery1 := " SELECT TG6_ORDEM AS ORDEM, TG6_DTRESU AS DTRESU, TG6_CODNIV AS CODNIV,"
cQuery1 += " TG6_CODPER AS CODPER, "
cQuery1 += " TG6_CODDAN AS CODDAN, TG6_CODCLA AS CODCLA, '' AS CODHIS , TGN_RESULT AS RESULT , '' AS REAVAL"
cQuery1 += " FROM "+RetSQLName("TG6")+" TG6"
cQuery1 += " JOIN "+RetSQLName("TGN")+" TGN ON TGN_FILIAL = " + ValToSql( xFilial( "TGN" ) )
cQuery1 += " AND TGN_CODFOR = " + ValToSql( cFormIS ) + " AND TGN_ANALIS = TG6_ORDEM "
cQuery1 += " WHERE TG6_CODPER BETWEEN '"+MV_PAR01+"' AND '"+MV_PAR02+"' "
cQuery1 += " AND TG6_CODDAN BETWEEN '"+MV_PAR03+"' AND '"+MV_PAR04+"' "
cQuery1 += " AND TG6_CODNIV BETWEEN '"+MV_PAR05+"' AND '"+MV_PAR06+"' "
cQuery1 += " AND TG6_DTRESU BETWEEN '"+DTOS(MV_PAR07)+"' AND '"+DTOS(MV_PAR08)+"' "
cQuery1 += " AND TG6.TG6_FILIAL = '"+xFilial("TG6")+"' AND TG6.D_E_L_E_T_ <> '*'"
If !Empty( MV_PAR10 )
	cQuery1 += " AND TG6.TG6_REVISA = " + ValToSql( MV_PAR10 )
EndIf
SqlToTrb(cQuery1,aDBF1,cTRB1)

//Query seleciona Aspectos e Impactos de cada avaliacao (TG7)
cQuery2 := " SELECT TG7_ORDEM AS ORDEM, TG7_INDICA AS INDICA, TG7_CODAVA AS CODAVA, TG7_CODOPC AS CODOPC,"
cQuery2 += " '' AS CODHIS"
cQuery2 += " FROM "+RetSQLName("TG7")+" TG7"
cQuery2 += " WHERE TG7_ORDEM IN (SELECT DISTINCT ORDEM FROM ("+cQuery1+") AS TRB)"
cQuery2 += " AND TG7.TG7_OK = '1' AND TG7.TG7_FILIAL = '"+xFilial("TG7")+"' AND TG7.D_E_L_E_T_ <> '*'"
SqlToTrb(cQuery2,aDBF2,cTRB2)

If MV_PAR09 == 1
	
	//Query seleciona Ordens de Resultados de Avaliacoes - Historico (TGD)
	cQuery1 := " SELECT TGD_ORDEM AS ORDEM, TGD_DTRESU AS DTRESU, TGD_CODNIV AS CODNIV,"
	cQuery1 += " TGD_CODPER AS CODPER,"
	cQuery1 += " TGD_CODDAN AS CODDAN, TGD_CODCLA AS CODCLA, TGD_CODHIS AS CODHIS , TGO_RESULT AS RESULT, TGD_REAVAL AS REAVAL "
	cQuery1 += " FROM "+RetSQLName("TGD")+" TGD"
	cQuery1 += " JOIN "+RetSQLName("TGO")+" TGO ON TGO_FILIAL = " + ValToSql( xFilial( "TGO" ) )
	cQuery1 += " AND TGO_CODFOR = " + ValToSql( cFormIS ) + " AND TGO_ANALIS = TGD_ORDEM "
	cQuery1 += " WHERE TGD_CODPER BETWEEN '"+MV_PAR01+"' AND '"+MV_PAR02+"' "
	cQuery1 += " AND TGD_CODDAN BETWEEN '"+MV_PAR03+"' AND '"+MV_PAR04+"' "
	cQuery1 += " AND TGD_CODNIV BETWEEN '"+MV_PAR05+"' AND '"+MV_PAR06+"' "
	cQuery1 += " AND TGD_DTRESU BETWEEN '"+DTOS(MV_PAR07)+"' AND '"+DTOS(MV_PAR08)+"' "
	cQuery1 += " AND TGD.TGD_FILIAL = '"+xFilial("TGD")+"' AND TGD.D_E_L_E_T_ <> '*'"
	If !Empty( MV_PAR10 )
		cQuery1 += " AND TGD.TGD_REVISA = " + ValToSql( MV_PAR10 )
	EndIf
	SqlToTrb(cQuery1,aDBF1,cTRB1)
	
	//Query seleciona Aspectos e Impactos de cada avaliacao - Historico (TGE)
	cQuery2 := " SELECT TGE_ORDEM AS ORDEM, TGE_INDICA AS INDICA, TGE_CODAVA AS CODAVA, TGE_CODOPC AS CODOPC,"
	cQuery2 += " TGE_CODHIS AS CODHIS"
	cQuery2 += " FROM "+RetSQLName("TGE")+" TGE"
	cQuery2 += " WHERE TGE_ORDEM IN (SELECT DISTINCT ORDEM FROM ("+cQuery1+") AS TRB)"
	cQuery2 += " AND TGE.TGE_FILIAL = '"+xFilial("TGE")+"' AND TGE.TGE_OK = '1' AND TGE.D_E_L_E_T_ <> '*'"
	SqlToTrb(cQuery2,aDBF2,cTRB2)
	
EndIf

Return Nil
//---------------------------------------------------------------------
/*/{Protheus.doc} GeraXLS
Processa os Dados da PLanilha a ser gerada

@return

@sample
GeraXLS()

@author Jackson Machado
@since 27/03/2013
@version 1.0
/*/
//---------------------------------------------------------------------
Static Function GeraXLS()

Local nA
Local nB
Local cTab	  := ""
Local aTabGet := { ;
						{ "TGF" , "TGJ" , "TGF_ANALIS" , "TGJ_CODHIS+TGJ_ANALIS" , "TGF_CODPLA" , "TGJ_CODPLA" } , ;
						{ "TGG" , "TGK" , "TGG_ANALIS" , "TGK_CODHIS+TGK_ANALIS" , "TGG_CODPLA" , "TGK_CODPLA" } , ;
						{ "TGH" , "TGL" , "TGH_ANALIS" , "TGL_CODHIS+TGL_ANALIS" , "TGH_CODOBJ" , "TGL_CODOBJ" } , ;
						{ "TGI" , "TGM" , "TGI_ANALIS" , "TGM_CODHIS+TGM_ANALIS" , "TGI_CODMON" , "TGM_CODMON" } ;
				}
Local aControles := {}
Local oTempTMP, oTempLeg

MDTR849TRB()

aCabec     := {}
aRespostas := {}
aLegenda   := {}
aOpcoes    := {}

dbSelectArea(cTRB1)
dbSetOrder(01)
dbGoTop()

If RecCount() == 0
	MsgStop( STR0021 ) //"Não existem dados para a geração da planilha."
	Return .F.
EndIf

While !Eof()
	
	dbSelectArea( "TGD" )
	dbSetOrder( 4 )
	If dbSeek( xFilial( "TGD" ) + (cTRB1)->ORDEM )
		RecLock( cTRB1 , .F. ) 
		( cTRB1 )->( dbDelete() )
		( cTRB1 )->( MsUnLock() )
		dbSelectArea(cTRB1)
		dbSkip()
		Loop
	EndIf
	
	cOrdem     := (cTRB1)->ORDEM
	cCodNIV    := (cTRB1)->CODNIV
	cAtividade := NGSEEK("TAF",'001'+(cTRB1)->CODNIV,2,"TAF_NOMNIV")
	cPerigo    := NGSEEK("TG1",(cTRB1)->CODPER,1,"TG1_DESCRI")
	cDano      := NGSEEK("TG8",(cTRB1)->CODDAN,1,"TG8_DESCRI")
	
	cChave1 := "(cTRB1)->CODHIS+(cTRB1)->ORDEM"
	cChave2 := "(cTRB2)->CODHIS+(cTRB2)->ORDEM"
	
	//Impressao do Aspecto
	dbSelectArea(cTRB2)
	dbSetOrder(01)
	dbSeek(&cChave1,.T.)
	
	While !Eof() .And. &cChave1 == &cChave2
		DbSelectArea('TG2')
		DbSeek(xFilial('TG2')+(cTrb2)->CODAVA)
		cRequisito := fRetRequisitos( (cTRB1)->CODPER , (cTRB1)->CODDAN ) //Requisitos Legais Associados
		cObjetivo  := IF(NGIFDBSEEK( aTabGet[ 3 , If( Empty( (cTRB1)->CODHIS ) , 1 , 2 ) ] , If( Empty( (cTRB1)->CODHIS ) , cOrdem , (cTRB1)->CODHIS + cOrdem ) , 1 ),'X','') //Objetivos e Metas
		cPlnEmerg  := IF(NGIFDBSEEK( aTabGet[ 2 , If( Empty( (cTRB1)->CODHIS ) , 1 , 2 ) ] , If( Empty( (cTRB1)->CODHIS ) , cOrdem , (cTRB1)->CODHIS + cOrdem ) , 1 ),'X','') //Plano de Emergencia
		cPlnAcao   := IF(NGIFDBSEEK( aTabGet[ 1 , If( Empty( (cTRB1)->CODHIS ) , 1 , 2 ) ] , If( Empty( (cTRB1)->CODHIS ) , cOrdem , (cTRB1)->CODHIS + cOrdem ) , 1 ),'X','') //Plano de Ação
		cMonit     := IF(NGIFDBSEEK( aTabGet[ 4 , If( Empty( (cTRB1)->CODHIS ) , 1 , 2 ) ] , If( Empty( (cTRB1)->CODHIS ) , cOrdem , (cTRB1)->CODHIS + cOrdem ) , 1 ),'X','') //Monitoramento
		aControle  := fRetControles( aTabGet , Empty( (cTRB1)->CODHIS ) , If( Empty( (cTRB1)->CODHIS ) , cOrdem , (cTRB1)->CODHIS + cOrdem ) ) // Controle aplicado
		cObservacoes := If( Empty( (cTRB1)->CODHIS ) , NGSEEK( "TG6" , cOrdem , 1 , "TG6_DESCRI" ) , NGSEEK( "TGD" , (cTRB1)->CODHIS + cOrdem , 1 , "TGD_DESCRI" ) )
		//                1         2      3        4          5         6             7                 8               9                10         11           12       13         14       15        16
		If aScan( aControles , { | x | x[ 1 ] == cOrdem } ) == 0
			aAdd( aControles , { cOrdem , aClone( aControle ) } )
		EndIf
		aadd(aRespostas,{cOrdem,cCodNIV,cAtividade,cPerigo,cDano,(cTrb2)->CODAVA,(cTrb2)->CODOPC,TG2->TG2_TIPO,(cTRB1)->RESULT,(cTRB1)->CODCLA,cRequisito,cPlnEmerg,cObjetivo,cObservacoes,cPlnAcao,cMonit})
		nOpcao := aScan(aOpcoes,{|X| X[1] == (cTrb2)->CODAVA })
		If nOpcao == 0
			aAdd(aOpcoes,{(cTrb2)->CODAVA,TG2->TG2_TIPO,TG2->TG2_DESCRI})
		Endif
		dbSelectArea(cTRB2)
		dbSkip()
	EndDo
	
	dbSelectArea(cTRB1)
	dbSkip()
	
EndDo

// Cria Arquivo Temporario para Armazenar os dados do Relatorio
aEstru  := {}
cArqui := ""

aSort(aOpcoes,,,{|x,y| x[1] < y[1]})

aadd(aEstru,{"TG6_ORDEM"  ,"C",006,0})
aadd(aEstru,{"TG6_CODNIV" ,"C",003,0})
aadd(aEstru,{"ATIVIDADE"  ,"C",060,0})

//Monta a Estrutura das ATIVIDADEacoes
For nA := 1 To Len(aOpcoes)
	If aOpcoes[nA][2] == '3'
		cVariavel := 'LOCALI_'+aOpcoes[nA][1]
		aadd(aEstru,{cVariavel,"C",003,0})
	Endif
Next

aadd(aEstru,{"PERIGO"  ,"C",050,0})
//Monta a Estrutura das Aspectos
For nA := 1 To Len(aOpcoes)
	If aOpcoes[nA][2] == '1'
		cVariavel := 'PERVAR_'+aOpcoes[nA][1]
		aadd(aEstru,{cVariavel,"C",003,0})
	Endif
Next

aadd(aEstru,{"DANO"  ,"C",050,0})
//Monta a Estrutura das Aspectos
For nA := 1 To Len(aOpcoes)
	If aOpcoes[nA][2] == '2'
		cVariavel := 'DANVAR_'+aOpcoes[nA][1]
		aadd(aEstru,{cVariavel,"C",003,0})
	Endif
Next

// Pontuacao Significancia
aadd(aEstru,{"PONTUACAO"  ,"N",009,2})
aadd(aEstru,{"SIGNFICAN"  ,"C",005,0})
If MV_PAR11 == 1
	aadd(aEstru,{"REQUISITO"	,"C",050,0})
EndIf
If MV_PAR15 == 1
	aadd(aEstru,{"PLAN_EMER"	,"C",003,0}) 
EndIf
If MV_PAR16 == 1
	aadd(aEstru,{"CONTROLE"		,"C",050,0})
EndIf
If MV_PAR12 == 1
	aadd(aEstru,{"CRITER"		,"C",050,0})
EndIf
If MV_PAR13 == 1
	aadd(aEstru,{"OBJETIVOS"	,"C",003,0})
EndIf
aadd(aEstru,{"FORMULARIO"		,"C",003,0})
aadd(aEstru,{"OBSERV"			,"C",050,0})

oTempTMP := FWTemporaryTable():New( "TMPDBF", aEstru )
oTempTMP:AddIndex( "1", {"TG6_CODNIV","TG6_ORDEM"} )
oTempTMP:Create()

For nB := 1 To Len(aRespostas)
	
	cChave    := aRespostas[nB][2]+aRespostas[nB][1]
	nRecno    := 0
	
	cCampo := ''
	If aRespostas[nB][8] == "1" // Aspecto
		cCampo := 'PERVAR_'+aRespostas[nB][6]
	ElseIf aRespostas[nB][8] == "2" // Impacto
		cCampo := 'DANVAR_'+aRespostas[nB][6]
	Else  // Localizacao
		cCampo := 'LOCALI_'+aRespostas[nB][6]
	Endif
	
	// Verifica Se Já existe registro para este a Localizacao/aspecto/impacto
	// Se somente algum aspecto for preenchido aproveita do registro
	DbSelectArea('TMPDBF')
	DbSeek(cChave)
	Do While !Eof() .and. TMPDBF->TG6_CODNIV+TMPDBF->TG6_ORDEM == cChave
		If Empty(&cCampo)
			nRecno := TMPDBF->(Recno())
			Exit
		Endif
		DbSelectArea('TMPDBF')
		DbSkip()
	Enddo
	
	xConteudo := AllTrim(aRespostas[nB][7]) // Legenda
	//  xConteudo := NGSEEK("TG3",aRespostas[nB][6]+aRespostas[nB][7],1,"TG3_OPCAO") // conteudo da legenda
	If nRecno == 0
		DbSelectArea('TMPDBF')
		RecLock('TMPDBF',.T.)
		TMPDBF->TG6_ORDEM  := aRespostas[nB][1]
		TMPDBF->TG6_CODNIV := aRespostas[nB][2]
		TMPDBF->ATIVIDADE  := Alltrim(aRespostas[nB][3])
		TMPDBF->PERIGO     := Alltrim(aRespostas[nB][4])
		TMPDBF->DANO       := Alltrim(aRespostas[nB][5])
		TMPDBF->PONTUACAO  := aRespostas[nB][09]
		TMPDBF->SIGNFICAN  := aRespostas[nB][10]
		If MV_PAR11 == 1
			TMPDBF->REQUISITO  := aRespostas[nB][11]
		EndIf
		If MV_PAR15 == 1
			TMPDBF->PLAN_EMER  := aRespostas[nB][12]
		EndIf
		If MV_PAR16 == 1
			TMPDBF->CONTROLE   := aRespostas[nB][13]
		EndIf
		If MV_PAR12 == 1
			TMPDBF->CRITER     := aRespostas[nB][16]
		EndIf
		If MV_PAR13 == 1
			TMPDBF->OBJETIVOS  := aRespostas[nB][13]
		EndIf
		TMPDBF->OBSERV     := aRespostas[nB][14]
		FIELDPUT(FIELDPOS(cCampo),xConteudo)
		MsUnLock()
	Else
		DbSelectArea('TMPDBF')
		DbGoto(nRecno)
		RecLock('TMPDBF',.F.)
		FIELDPUT(FIELDPOS(cCampo),xConteudo)
		MsUnLock()
	Endif
Next nB

//Monta a Legenda
aLegenda := {}
For nA := 1 To Len(aOpcoes)
	cVariavel := 'LEGEND_'+aOpcoes[nA][1]
	aadd(aLegenda,{cVariavel,"C",035,0})
Next nA

oTempLeg := FWTemporaryTable():New( "TMPLEG", aLegenda )
oTempLeg:Create()

For nA := 1 To Len(aOpcoes)
	cCampo    := 'LEGEND_'+aOpcoes[nA][1]
	xConteudo := aOpcoes[nA][1]
	DbSelectArea('TG3')
	DbSetOrder(1)
	DbSeek(xFilial('TG3')+xConteudo)
	Do While !Eof() .and. TG3_CODAVA == xConteudo
		cLegenda := TG3_CODOPC+'-'+TG3_OPCAO
		nRecno := 0
		DbSelectArea('TMPLEG')
		DbGoTop()
		Do While !Eof()
			If Empty(&cCampo)
				nRecno := TMPLEG->(Recno())
				Exit
			Endif
			DbSkip()
		Enddo
		If nRecno == 0
			RecLock('TMPLEG',.T.)
		Else
			DbSelectArea('TMPLEG')
			DbGoto(nRecno)
			RecLock('TMPLEG',.F.)
		Endif
		FIELDPUT(FIELDPOS(cCampo),cLegenda)
		MsUnLock()
		DbSelectArea('TG3')
		DbSkip()
	Enddo
Next nA

MontaXLS(aEstru,aLegenda,aControles)

oTempLeg:Delete()

Return

//---------------------------------------------------------------------
/*/{Protheus.doc} MontaXLS
Monta a planilha e abre no excell

@return

@sample
MontaXLS( aArray , aLegenda )

@author Jackson Machado
@since 27/03/2013
@version 1.0
/*/
//---------------------------------------------------------------------
Static Function MontaXLS(aEstrutura,aLegenda,aControl)

Local nA , nB , nC
Local nMerg
Local nPosic
Local nPosCtl		:= 0
Local nHandle
Local nPosFor		:= 0
Local nTamFor		:= 0
Local cTam			:= ""
Local cArqPesq		:= ""
Local cPath			:= AllTrim(GetTempPath())
Local aControles	:= {}
Local aCabecFor	:= {}
Local aReavCri		:= {}
Local aReavalia	:= {}

cArqXML := CriaTrab(,.F.)

nColAti := 1  // Coluna que será impresso a atividade para depois alinhamento de impressão da Legenda
nColPER := 0  // Coluna que será impresso o Aspecto   para depois alinhamento de impressão da Legenda
nColCTR := 0  // Coluna do Controle Aplicado
//Monta o Cabecario dos Aspectos de acordo com a Estrutura do Arquivo
aCabec := {}
For nA := 3 To Len(aEstrutura)
	cCampo := aEstrutura[nA][1]
	cCor   := 's50'
	cTam   := '50'
	If AT("ATIVIDADE",cCampo) <> 0 // Atividade é Fundo Laranja na horizontal
		cCor := 's80'
		cTam := '222'
	ElseIf AT("LOCALI_",cCampo) <> 0 // LOcalizacao é Fundo Laranja na vertical
		cCodAva := Substr(cCampo,8,3)
		cCampo  := NGSEEK("TG2",cCodAVA,1,"TG2_DESCRI")
		cCor := fIndStyle(cCodAVA)//'s81'
		cTam := '23'
	ElseIf AT("PERIGO",cCampo) <> 0 // Aspecto é verde horizontal
		cCor := 's82'
		nColPER := Len(aCabec)+1
		cTam := '250'
	ElseIf AT("PERVAR_",cCampo) <> 0 // Descricao do Aspecto e verde veritical
		cCodAva := Substr(cCampo,8,3)
		cCampo  := NGSEEK("TG2",cCodAVA,1,"TG2_DESCRI")
		cCor := fIndStyle(cCodAVA)//'s83'
		cTam := '23'
	ElseIf AT("DANO",cCampo) <> 0 // impacto é azul
		cCor := 's84'
		cTam := '250'
	ElseIf AT("DANVAR_",cCampo) <> 0 // Descricao do impacto e azul veritical
		cCodAva := Substr(cCampo,8,3)
		cCampo  := NGSEEK("TG2",cCodAVA,1,"TG2_DESCRI")
		cCor := fIndStyle(cCodAVA)//'s85'
		cTam := '23'
	ElseIf AT("PONTUACAO",cCampo) <> 0 // Fundo Cinza 90 Graus
		cCampo  := STR0022 // STR //"Pontuação"
		cCor := 's87'
		cTam := '23'
	ElseIf AT("SIGNFICAN",cCampo) <> 0 // Fundo Cinza 90 Graus
		cCampo  := STR0023 // STR //"Significância"
		cCor := 's87'
		cTam := '32'
	ElseIf AT("REQUISITO",cCampo) <> 0// Fundo Cinza 90 Graus
		cCampo  := STR0024 // STR //"Requisitos Legais Associados"
		cCor := 's88'
		cTam := '150'
	ElseIf AT("PLAN_EMER",cCampo) <> 0// Fundo Cinza 90 Graus
		cCampo  := STR0027 // STR //"Plano Emergencial"
		cCor := 's89'
		cTam := '23'
	ElseIf AT("CONTROL",cCampo) <> 0// Fundo Cinza 90 Graus
		cCampo  := STR0034 // STR //"Controle e Monitoramento Aplicado"
		cCor := 's88'
		cTam := '150'
		nColCTR := Len(aCabec)+1
	ElseIf AT("CRITER",cCampo) <> 0 // Fundo Cinza 90 Graus
		cCampo  :=  STR0035 // STR //"Classificar Priorização de Controle"
		cCor := 's89'
		cTam := '23'
	ElseIf AT("OBJETIVOS",cCampo) <> 0 // Fundo Cinza 90 Graus
		cCampo  := STR0026 // STR //"Objetivos e Metas"
		cCor := 's89'
		cTam := '23'
	/*ElseIf AT("PLAN_ACAO",cCampo) <> 0 // Fundo Cinza 90 Graus
		cCampo  :=  STR0036 // "Plano de Ação"
		cCor := 's89'
		cTam := '23'*/
	ElseIf AT("FORMULARIO",cCampo) <> 0
		cCampo	:=  STR0037 // STR  //"Formulário"
		cCor := 's91'
		cTam := '50'
	ElseIf AT("OBSERV",cCampo) <> 0 // Fundo Cinza 90 Graus
		cCampo  := STR0038 // STR //"OBS."
		cCor := 's88'
		cTam := '150'
		nColCTR := Len(aCabec)+1
	Endif
	aadd(aCabec,{Alltrim(cCampo),cCor,cTam})
Next nA

// Monta o Cabec das Legendas
aLegCAB := {}
For nA := 1 to Len(aLegenda)
	cCodAva := Substr(aLegenda[nA][1],8,3)
	cCampo  := NGSEEK("TG2",cCodAVA,1,"TG2_DESCRI")
	cCor := 's50'
	aadd(aLegCAB,{cCampo,cCor})
Next nA

//Adiciona Significancia
aadd(aLegCAB,{ STR0039 , cCor }) // "SIGNIFICÂNCIA"

cArqPesq := cPath+cArqXML+".xml"
nHandle  := FCREATE(cArqPesq, 0) //Cria arquivo no diretório

//----------------------------------------------------------------------------------
// Verifica se o arquivo pode ser criado, caso contrario um alerta sera exibido
//----------------------------------------------------------------------------------
If FERROR() <> 0
	MsgAlert(STR0030 + cArqPesq ) //"Não foi possível abrir ou criar o arquivo: "
	Return
Endif

FWrite( nHandle, '<?xml version="1.0" encoding="ISO-8859-1" ?>' + CRLF ) //Esta tag e' necessaria pois indica para o excel que este e' um arquivo xml
FWrite( nHandle, '<?mso-application progid="Excel.Sheet"?>' + CRLF )//Esta tag informa que e' excel e utilizara' o Sheet (Folha)
FWrite( nHandle, '<Workbook xmlns="urn:schemas-microsoft-com:office:spreadsheet"' + CRLF )//Tag para montagem do workbook, que representa uma pasta de trabalho do excel
FWrite( nHandle, ' xmlns:o="urn:schemas-microsoft-com:office:office"' + CRLF )
FWrite( nHandle, ' xmlns:x="urn:schemas-microsoft-com:office:excel"' + CRLF )
FWrite( nHandle, ' xmlns:ss="urn:schemas-microsoft-com:office:spreadsheet"' + CRLF )
FWrite( nHandle, ' xmlns:html="http://www.w3.org/TR/REC-html40">' + CRLF )

// -------------------------- INICIO DO ESTILOS --------------------------
FWrite( nHandle, '<Styles>' + CRLF )
// -------------------------- INICIO DO ESTILOS --------------------------
FWrite( nHandle, '  <Style ss:ID="Default" ss:Name="Normal">' + CRLF )
FWrite( nHandle, '   <Alignment ss:Vertical="Bottom"/>' + CRLF )
FWrite( nHandle, '   <Borders/>' + CRLF )
FWrite( nHandle, '   <Font ss:FontName="Calibri" x:Family="Swiss" ss:Size="11" ss:Color="#000000"/>' + CRLF )
FWrite( nHandle, '   <Interior/>' + CRLF )
FWrite( nHandle, '   <NumberFormat/>' + CRLF )
FWrite( nHandle, '   <Protection/>' + CRLF )
FWrite( nHandle, '  </Style>' + CRLF )


//colunas com bordas e borda superior grossa        
FWrite( nHandle, '  <Style ss:ID="UpThick">' + CRLF )
FWrite( nHandle, '   <Borders>' + CRLF )
FWrite( nHandle, '    <Border ss:Position="Bottom" ss:LineStyle="Continuous" ss:Weight="1"/>' + CRLF )
FWrite( nHandle, '    <Border ss:Position="Left" ss:LineStyle="Continuous" ss:Weight="1"/>' + CRLF )
FWrite( nHandle, '    <Border ss:Position="Right" ss:LineStyle="Continuous" ss:Weight="1"/>' + CRLF )
FWrite( nHandle, '    <Border ss:Position="Top" ss:LineStyle="Continuous" ss:Weight="3"/>' + CRLF )
FWrite( nHandle, '   </Borders>' + CRLF )
FWrite( nHandle, '  </Style>' + CRLF )

//colunas com bordas e borda superior, inferior e direita grossa        
FWrite( nHandle, '  <Style ss:ID="UpRightThick">' + CRLF )
FWrite( nHandle, '   <Borders>' + CRLF )
FWrite( nHandle, '    <Border ss:Position="Bottom" ss:LineStyle="Continuous" ss:Weight="3"/>' + CRLF )
FWrite( nHandle, '    <Border ss:Position="Left" ss:LineStyle="Continuous" ss:Weight="1"/>' + CRLF )
FWrite( nHandle, '    <Border ss:Position="Right" ss:LineStyle="Continuous" ss:Weight="3"/>' + CRLF )
FWrite( nHandle, '    <Border ss:Position="Top" ss:LineStyle="Continuous" ss:Weight="3"/>' + CRLF )
FWrite( nHandle, '   </Borders>' + CRLF )
FWrite( nHandle, '   <Font ss:FontName="Calibri" x:Family="Swiss" ss:Size="11" ss:Color="#000000"' + CRLF )
FWrite( nHandle, '   	ss:Bold="1"/>' + CRLF )
FWrite( nHandle, '   <Interior ss:Color="#FAC090" ss:Pattern="Solid"/>' + CRLF )
FWrite( nHandle, '  </Style>' + CRLF )                        


//colunas com bordas e borda superior, inferior e esquerda grossa        
FWrite( nHandle, '  <Style ss:ID="UpLeftThick">' + CRLF )
FWrite( nHandle, '   <Borders>' + CRLF )
FWrite( nHandle, '    <Border ss:Position="Bottom" ss:LineStyle="Continuous" ss:Weight="3"/>' + CRLF )
FWrite( nHandle, '    <Border ss:Position="Left" ss:LineStyle="Continuous" ss:Weight="3"/>' + CRLF )
FWrite( nHandle, '    <Border ss:Position="Right" ss:LineStyle="Continuous" ss:Weight="1"/>' + CRLF )
FWrite( nHandle, '    <Border ss:Position="Top" ss:LineStyle="Continuous" ss:Weight="3"/>' + CRLF )
FWrite( nHandle, '   </Borders>' + CRLF )
FWrite( nHandle, '   <Font ss:FontName="Calibri" x:Family="Swiss" ss:Size="11" ss:Color="#000000"' + CRLF )
FWrite( nHandle, '   	ss:Bold="1"/>' + CRLF )
FWrite( nHandle, '   <Interior ss:Color="#FAC090" ss:Pattern="Solid"/>' + CRLF )
FWrite( nHandle, '  </Style>' + CRLF )                        

//colunas com bordas e borda esquerda grossa        
FWrite( nHandle, '  <Style ss:ID="LeftThick">' + CRLF )
FWrite( nHandle, '   <Borders>' + CRLF ) 
FWrite( nHandle, '    <Border ss:Position="Bottom" ss:LineStyle="Continuous" ss:Weight="1"/>' + CRLF )
FWrite( nHandle, '    <Border ss:Position="Left" ss:LineStyle="Continuous" ss:Weight="3"/>' + CRLF )
FWrite( nHandle, '    <Border ss:Position="Right" ss:LineStyle="Continuous" ss:Weight="1"/>' + CRLF )
FWrite( nHandle, '    <Border ss:Position="Top" ss:LineStyle="Continuous" ss:Weight="1"/>' + CRLF )
FWrite( nHandle, '   </Borders>' + CRLF )
FWrite( nHandle, '  </Style>' + CRLF )

//colunas com bordas e borda direita grossa        
FWrite( nHandle, '  <Style ss:ID="RightThick">' + CRLF )
FWrite( nHandle, '   <Borders>' + CRLF )
FWrite( nHandle, '    <Border ss:Position="Bottom" ss:LineStyle="Continuous" ss:Weight="1"/>' + CRLF )
FWrite( nHandle, '    <Border ss:Position="Left" ss:LineStyle="Continuous" ss:Weight="1"/>' + CRLF )
FWrite( nHandle, '    <Border ss:Position="Right" ss:LineStyle="Continuous" ss:Weight="3"/>' + CRLF )
FWrite( nHandle, '    <Border ss:Position="Top" ss:LineStyle="Continuous" ss:Weight="1"/>' + CRLF )
FWrite( nHandle, '   </Borders>' + CRLF )
FWrite( nHandle, '  </Style>' + CRLF )             


//colunas com bordas e borda superior grossa        
FWrite( nHandle, '  <Style ss:ID="OnlyUpThick">' + CRLF )
FWrite( nHandle, '   <Borders>' + CRLF )
FWrite( nHandle, '    <Border ss:Position="Top" ss:LineStyle="Continuous" ss:Weight="3"/>' + CRLF )
FWrite( nHandle, '   </Borders>' + CRLF )
FWrite( nHandle, '  </Style>' + CRLF )


// Coluna com Bordas
FWrite( nHandle, '  <Style ss:ID="s50">' + CRLF )
FWrite( nHandle, '  <Alignment ss:Horizontal="Center" ss:Vertical="Center" ss:WrapText="1"/>'+ CRLF )
FWrite( nHandle, '   <Borders>' + CRLF )
FWrite( nHandle, '    <Border ss:Position="Bottom" ss:LineStyle="Continuous" ss:Weight="1"/>' + CRLF )
FWrite( nHandle, '    <Border ss:Position="Left" ss:LineStyle="Continuous" ss:Weight="1"/>' + CRLF )
FWrite( nHandle, '    <Border ss:Position="Right" ss:LineStyle="Continuous" ss:Weight="1"/>' + CRLF )
FWrite( nHandle, '    <Border ss:Position="Top" ss:LineStyle="Continuous" ss:Weight="1"/>' + CRLF )
FWrite( nHandle, '   </Borders>' + CRLF )
FWrite( nHandle, '  </Style>' + CRLF )

// Coluna sem Bordas
FWrite( nHandle, '  <Style ss:ID="s50sembordas">' + CRLF )
FWrite( nHandle, '  </Style>' + CRLF )

// Coluna com bordas apenas cima, baixo e direita
FWrite( nHandle, '  <Style ss:ID="s50bordatres">' + CRLF )
FWrite( nHandle, '   <Borders>' + CRLF )
FWrite( nHandle, '    <Border ss:Position="Bottom" ss:LineStyle="Continuous" ss:Weight="1"/>' + CRLF )
FWrite( nHandle, '    <Border ss:Position="Right" ss:LineStyle="Continuous" ss:Weight="1"/>' + CRLF )
FWrite( nHandle, '    <Border ss:Position="Top" ss:LineStyle="Continuous" ss:Weight="1"/>' + CRLF )
FWrite( nHandle, '   </Borders>' + CRLF )
FWrite( nHandle, '  </Style>' + CRLF )

// Coluna com Bordas
FWrite( nHandle, '  <Style ss:ID="s50left">' + CRLF )
FWrite( nHandle, '   <Borders>' + CRLF )
FWrite( nHandle, '    <Border ss:Position="Bottom" ss:LineStyle="Continuous" ss:Weight="1"/>' + CRLF )
FWrite( nHandle, '    <Border ss:Position="Left" ss:LineStyle="Continuous" ss:Weight="1"/>' + CRLF )
FWrite( nHandle, '    <Border ss:Position="Right" ss:LineStyle="Continuous" ss:Weight="1"/>' + CRLF )
FWrite( nHandle, '    <Border ss:Position="Top" ss:LineStyle="Continuous" ss:Weight="1"/>' + CRLF )
FWrite( nHandle, '   </Borders>' + CRLF )
FWrite( nHandle, '  </Style>' + CRLF )

// Texto tamanho 25 centralizado do titulo
FWrite( nHandle, '    <Style ss:ID="s64">'+ CRLF )
FWrite( nHandle, '     <Alignment ss:Horizontal="Center" ss:Vertical="Center"/>'+ CRLF )
FWrite( nHandle, '     <Borders>'+ CRLF )
FWrite( nHandle, '      <Border ss:Position="Bottom" ss:LineStyle="Continuous" ss:Weight="1"/>'+ CRLF )
FWrite( nHandle, '      <Border ss:Position="Left" ss:LineStyle="Continuous" ss:Weight="1"/>'+ CRLF )
FWrite( nHandle, '      <Border ss:Position="Right" ss:LineStyle="Continuous" ss:Weight="1"/>'+ CRLF )
FWrite( nHandle, '      <Border ss:Position="Top" ss:LineStyle="Continuous" ss:Weight="1"/>'+ CRLF )
FWrite( nHandle, '     </Borders>'+ CRLF )
FWrite( nHandle, '     <Font ss:FontName="Calibri" x:Family="Swiss" ss:Size="25" ss:Color="#000000"'+ CRLF )
FWrite( nHandle, '      ss:Bold="1"/>'+ CRLF )
FWrite( nHandle, '    </Style>'+ CRLF )

// Texto tamanho 25 esquerda do titulo
FWrite( nHandle, '    <Style ss:ID="s64left">'+ CRLF )
FWrite( nHandle, '     <Borders>'+ CRLF )
FWrite( nHandle, '      <Border ss:Position="Bottom" ss:LineStyle="Continuous" ss:Weight="1"/>'+ CRLF )
FWrite( nHandle, '      <Border ss:Position="Left" ss:LineStyle="Continuous" ss:Weight="1"/>'+ CRLF )
FWrite( nHandle, '      <Border ss:Position="Right" ss:LineStyle="Continuous" ss:Weight="1"/>'+ CRLF )
FWrite( nHandle, '      <Border ss:Position="Top" ss:LineStyle="Continuous" ss:Weight="1"/>'+ CRLF )
FWrite( nHandle, '     </Borders>'+ CRLF )
FWrite( nHandle, '     <Font ss:FontName="Calibri" x:Family="Swiss" ss:Size="13" ss:Color="#000000"'+ CRLF )
FWrite( nHandle, '      ss:Bold="1"/>'+ CRLF )
FWrite( nHandle, '    </Style>'+ CRLF )

// Texto tamanho 11 - Titulo comum
FWrite( nHandle, '    <Style ss:ID="s65">'+ CRLF )
FWrite( nHandle, '     <Borders>'+ CRLF )
FWrite( nHandle, '      <Border ss:Position="Bottom" ss:LineStyle="Continuous" ss:Weight="1"/>'+ CRLF )
FWrite( nHandle, '      <Border ss:Position="Left" ss:LineStyle="Continuous" ss:Weight="1"/>'+ CRLF )
FWrite( nHandle, '      <Border ss:Position="Right" ss:LineStyle="Continuous" ss:Weight="1"/>'+ CRLF )
FWrite( nHandle, '      <Border ss:Position="Top" ss:LineStyle="Continuous" ss:Weight="1"/>'+ CRLF )
FWrite( nHandle, '     </Borders>'+ CRLF )
FWrite( nHandle, '     <Font ss:FontName="Calibri" x:Family="Swiss" ss:Size="11" ss:Color="#000000"'+ CRLF )
FWrite( nHandle, '      ss:Bold="1"/>'+ CRLF )
FWrite( nHandle, '    </Style>'+ CRLF )

// Texto tamanho 11 - Célula comum
FWrite( nHandle, '    <Style ss:ID="s66">'+ CRLF )
FWrite( nHandle, '     <Borders>'+ CRLF )
FWrite( nHandle, '      <Border ss:Position="Bottom" ss:LineStyle="Continuous" ss:Weight="1"/>'+ CRLF )
FWrite( nHandle, '      <Border ss:Position="Left" ss:LineStyle="Continuous" ss:Weight="1"/>'+ CRLF )
FWrite( nHandle, '      <Border ss:Position="Right" ss:LineStyle="Continuous" ss:Weight="1"/>'+ CRLF )
FWrite( nHandle, '      <Border ss:Position="Top" ss:LineStyle="Continuous" ss:Weight="1"/>'+ CRLF )
FWrite( nHandle, '     </Borders>'+ CRLF )
FWrite( nHandle, '     <Font ss:FontName="Calibri" x:Family="Swiss" ss:Size="11" ss:Color="#000000"/>'+ CRLF )
FWrite( nHandle, '    </Style>'+ CRLF )


FWrite( nHandle, '  <Style ss:ID="s71">' + CRLF )
FWrite( nHandle, '   <Font ss:FontName="Calibri" x:Family="Swiss" ss:Color="#000000"/>' + CRLF )
FWrite( nHandle, '  </Style>' + CRLF )

// Titulos Variaveis
FWrite( nHandle, '  <Style ss:ID="s80">'+ CRLF ) // Fundo Laranja 90 graus - Localizacao
FWrite( nHandle, '   <Borders>'+ CRLF )
FWrite( nHandle, '    <Border ss:Position="Bottom" ss:LineStyle="Continuous" ss:Weight="1"/>'+ CRLF )
FWrite( nHandle, '    <Border ss:Position="Left" ss:LineStyle="Continuous" ss:Weight="1"/>'+ CRLF )
FWrite( nHandle, '    <Border ss:Position="Right" ss:LineStyle="Continuous" ss:Weight="1"/>'+ CRLF )
FWrite( nHandle, '    <Border ss:Position="Top" ss:LineStyle="Continuous" ss:Weight="1"/>'+ CRLF )
FWrite( nHandle, '   </Borders>'+ CRLF )
FWrite( nHandle, '   <Font ss:FontName="Calibri" x:Family="Swiss" ss:Color="#000000"/>'+ CRLF )
FWrite( nHandle, '   <Interior ss:Color="#FAC090" ss:Pattern="Solid"/>'+ CRLF )
FWrite( nHandle, '  </Style>'+ CRLF )
FWrite( nHandle, '  <Style ss:ID="s81"> '+ CRLF ) // Fundo Laranja 90 graus - Localizacao
FWrite( nHandle, '   <Alignment ss:Horizontal="Center" ss:Vertical="Bottom" ss:Rotate="90"/>'+ CRLF )
FWrite( nHandle, '   <Borders>'+ CRLF )
FWrite( nHandle, '    <Border ss:Position="Bottom" ss:LineStyle="Continuous" ss:Weight="1"/>'+ CRLF )
FWrite( nHandle, '    <Border ss:Position="Left" ss:LineStyle="Continuous" ss:Weight="1"/>'+ CRLF )
FWrite( nHandle, '    <Border ss:Position="Right" ss:LineStyle="Continuous" ss:Weight="1"/>'+ CRLF )
FWrite( nHandle, '    <Border ss:Position="Top" ss:LineStyle="Continuous" ss:Weight="1"/>'+ CRLF )
FWrite( nHandle, '   </Borders>'+ CRLF )
FWrite( nHandle, '   <Font ss:FontName="Calibri" x:Family="Swiss" ss:Color="#000000" ss:Bold="1"/>'+ CRLF )
FWrite( nHandle, '   <Interior ss:Color="#FAC090" ss:Pattern="Solid"/>'+ CRLF )
FWrite( nHandle, '  </Style>'+ CRLF )
FWrite( nHandle, '  <Style ss:ID="s82">'+ CRLF ) // Fundo Azul - Horizontal Aspecto
FWrite( nHandle, '   <Borders>'+ CRLF )
FWrite( nHandle, '    <Border ss:Position="Bottom" ss:LineStyle="Continuous" ss:Weight="1"/>'+ CRLF )
FWrite( nHandle, '    <Border ss:Position="Left" ss:LineStyle="Continuous" ss:Weight="1"/>'+ CRLF )
FWrite( nHandle, '    <Border ss:Position="Right" ss:LineStyle="Continuous" ss:Weight="1"/>'+ CRLF )
FWrite( nHandle, '    <Border ss:Position="Top" ss:LineStyle="Continuous" ss:Weight="1"/>'+ CRLF )
FWrite( nHandle, '   </Borders>'+ CRLF )
FWrite( nHandle, '   <Font ss:FontName="Calibri" x:Family="Swiss" ss:Color="#000000"/>'+ CRLF )
FWrite( nHandle, '   <Interior ss:Color="#B6DDE8" ss:Pattern="Solid"/>'+ CRLF )
FWrite( nHandle, '  </Style>'+ CRLF )
FWrite( nHandle, '  <Style ss:ID="s83">'+ CRLF ) // Fundo Azul - 90 graus Aspectos
FWrite( nHandle, '   <Alignment ss:Vertical="Bottom" ss:Rotate="90"/>'+ CRLF )
FWrite( nHandle, '   <Borders>'+ CRLF )
FWrite( nHandle, '    <Border ss:Position="Bottom" ss:LineStyle="Continuous" ss:Weight="1"/>'+ CRLF )
FWrite( nHandle, '    <Border ss:Position="Left" ss:LineStyle="Continuous" ss:Weight="1"/>'+ CRLF )
FWrite( nHandle, '    <Border ss:Position="Right" ss:LineStyle="Continuous" ss:Weight="1"/>'+ CRLF )
FWrite( nHandle, '    <Border ss:Position="Top" ss:LineStyle="Continuous" ss:Weight="1"/>'+ CRLF )
FWrite( nHandle, '   </Borders>'+ CRLF )
FWrite( nHandle, '   <Font ss:FontName="Calibri" x:Family="Swiss" ss:Color="#000000"/>'+ CRLF )
FWrite( nHandle, '   <Interior ss:Color="#B6DDE8" ss:Pattern="Solid"/>'+ CRLF )
FWrite( nHandle, '  </Style>'+ CRLF )
FWrite( nHandle, '  <Style ss:ID="s84">'+ CRLF ) // Fundo verde-Impactos
FWrite( nHandle, '   <Borders>'+ CRLF )
FWrite( nHandle, '    <Border ss:Position="Bottom" ss:LineStyle="Continuous" ss:Weight="1"/>'+ CRLF )
FWrite( nHandle, '    <Border ss:Position="Left" ss:LineStyle="Continuous" ss:Weight="1"/>'+ CRLF )
FWrite( nHandle, '    <Border ss:Position="Right" ss:LineStyle="Continuous" ss:Weight="1"/>'+ CRLF )
FWrite( nHandle, '    <Border ss:Position="Top" ss:LineStyle="Continuous" ss:Weight="1"/>'+ CRLF )
FWrite( nHandle, '   </Borders>'+ CRLF )
FWrite( nHandle, '   <Font ss:FontName="Calibri" x:Family="Swiss" ss:Color="#000000"/>'+ CRLF )
FWrite( nHandle, '   <Interior ss:Color="#92D050" ss:Pattern="Solid"/>'+ CRLF )
FWrite( nHandle, '  </Style>'+ CRLF )
FWrite( nHandle, '  <Style ss:ID="s85"> // Fundo verde-impactos 90 graus'+ CRLF )
FWrite( nHandle, '   <Alignment ss:Vertical="Bottom" ss:Rotate="90"/>'+ CRLF )
FWrite( nHandle, '   <Borders>'+ CRLF )
FWrite( nHandle, '    <Border ss:Position="Bottom" ss:LineStyle="Continuous" ss:Weight="1"/>'+ CRLF )
FWrite( nHandle, '    <Border ss:Position="Left" ss:LineStyle="Continuous" ss:Weight="1"/>'+ CRLF )
FWrite( nHandle, '    <Border ss:Position="Right" ss:LineStyle="Continuous" ss:Weight="1"/>'+ CRLF )
FWrite( nHandle, '    <Border ss:Position="Top" ss:LineStyle="Continuous" ss:Weight="1"/>'+ CRLF )
FWrite( nHandle, '   </Borders>'+ CRLF )
FWrite( nHandle, '   <Font ss:FontName="Calibri" x:Family="Swiss" ss:Color="#000000"/>'+ CRLF )
FWrite( nHandle, '   <Interior ss:Color="#92D050" ss:Pattern="Solid"/>'+ CRLF )
FWrite( nHandle, '  </Style>'+ CRLF )
FWrite( nHandle, '  <Style ss:ID="s86">'+ CRLF ) //fundo cinza
FWrite( nHandle, '   <Borders>'+ CRLF )
FWrite( nHandle, '    <Border ss:Position="Bottom" ss:LineStyle="Continuous" ss:Weight="1"/>'+ CRLF )
FWrite( nHandle, '    <Border ss:Position="Left" ss:LineStyle="Continuous" ss:Weight="1"/>'+ CRLF )
FWrite( nHandle, '    <Border ss:Position="Right" ss:LineStyle="Continuous" ss:Weight="1"/>'+ CRLF )
FWrite( nHandle, '    <Border ss:Position="Top" ss:LineStyle="Continuous" ss:Weight="1"/>'+ CRLF )
FWrite( nHandle, '   </Borders>'+ CRLF )
FWrite( nHandle, '   <Font ss:FontName="Calibri" x:Family="Swiss" ss:Color="#000000"/>'+ CRLF )
FWrite( nHandle, '     <Interior ss:Color="#808080" ss:Pattern="Solid"/>'+ CRLF )
FWrite( nHandle, '  </Style>'+ CRLF )
FWrite( nHandle, '  <Style ss:ID="s87">'+ CRLF ) //fundo cinza 90 graus
FWrite( nHandle, '   <Alignment ss:Vertical="Bottom" ss:Rotate="90"/>'+ CRLF )
FWrite( nHandle, '   <Borders>'+ CRLF )
FWrite( nHandle, '    <Border ss:Position="Bottom" ss:LineStyle="Continuous" ss:Weight="1"/>'+ CRLF )
FWrite( nHandle, '    <Border ss:Position="Left" ss:LineStyle="Continuous" ss:Weight="1"/>'+ CRLF )
FWrite( nHandle, '    <Border ss:Position="Right" ss:LineStyle="Continuous" ss:Weight="1"/>'+ CRLF )
FWrite( nHandle, '    <Border ss:Position="Top" ss:LineStyle="Continuous" ss:Weight="1"/>'+ CRLF )
FWrite( nHandle, '   </Borders>'+ CRLF )
FWrite( nHandle, '     <Interior ss:Color="#808080" ss:Pattern="Solid"/>'+ CRLF )
FWrite( nHandle, '  </Style>'+ CRLF )
FWrite( nHandle, '  <Style ss:ID="s88"> '+ CRLF ) // Fundo Branco
FWrite( nHandle, '  <Alignment ss:WrapText="1"/>'+ CRLF ) 
FWrite( nHandle, '     <Borders>'+ CRLF )
FWrite( nHandle, '      <Border ss:Position="Bottom" ss:LineStyle="Continuous" ss:Weight="1"/>'+ CRLF )
FWrite( nHandle, '      <Border ss:Position="Left" ss:LineStyle="Continuous" ss:Weight="1"/>'+ CRLF )
FWrite( nHandle, '      <Border ss:Position="Right" ss:LineStyle="Continuous" ss:Weight="1"/>'+ CRLF )
FWrite( nHandle, '      <Border ss:Position="Top" ss:LineStyle="Continuous" ss:Weight="1"/>'+ CRLF )
FWrite( nHandle, '     </Borders>'+ CRLF )
FWrite( nHandle, '   <Font ss:FontName="Calibri" x:Family="Swiss" ss:Color="#000000"/>'+ CRLF )
FWrite( nHandle, '   <Interior/>'+ CRLF )
FWrite( nHandle, '	</Style>'+ CRLF )
FWrite( nHandle, '  <Style ss:ID="s88center"> '+ CRLF ) // Fundo Branco
FWrite( nHandle, '  <Alignment ss:WrapText="1" ss:Horizontal="Center" ss:Vertical="Center"/>'+ CRLF ) 
FWrite( nHandle, '     <Borders>'+ CRLF )
FWrite( nHandle, '      <Border ss:Position="Bottom" ss:LineStyle="Continuous" ss:Weight="1"/>'+ CRLF )
FWrite( nHandle, '      <Border ss:Position="Left" ss:LineStyle="Continuous" ss:Weight="1"/>'+ CRLF )
FWrite( nHandle, '      <Border ss:Position="Right" ss:LineStyle="Continuous" ss:Weight="1"/>'+ CRLF )
FWrite( nHandle, '      <Border ss:Position="Top" ss:LineStyle="Continuous" ss:Weight="1"/>'+ CRLF )
FWrite( nHandle, '     </Borders>'+ CRLF )
FWrite( nHandle, '   <Font ss:FontName="Calibri" x:Family="Swiss" ss:Color="#000000"/>'+ CRLF )
FWrite( nHandle, '   <Interior/>'+ CRLF )
FWrite( nHandle, '	</Style>'+ CRLF )
FWrite( nHandle, '    <Style ss:ID="s89">'+ CRLF ) // Fundo Branco 90 Graus
FWrite( nHandle, '     <Alignment ss:Vertical="Bottom" ss:Rotate="90"/>'+ CRLF )
FWrite( nHandle, '     <Borders>'+ CRLF )
FWrite( nHandle, '      <Border ss:Position="Bottom" ss:LineStyle="Continuous" ss:Weight="1"/>'+ CRLF )
FWrite( nHandle, '      <Border ss:Position="Left" ss:LineStyle="Continuous" ss:Weight="1"/>'+ CRLF )
FWrite( nHandle, '      <Border ss:Position="Right" ss:LineStyle="Continuous" ss:Weight="1"/>'+ CRLF )
FWrite( nHandle, '      <Border ss:Position="Top" ss:LineStyle="Continuous" ss:Weight="1"/>'+ CRLF )
FWrite( nHandle, '     </Borders>'+ CRLF )
FWrite( nHandle, '   </Style>'+ CRLF )
FWrite( nHandle, '    <Style ss:ID="s90">'+ CRLF ) // Mesclado a esquerda
FWrite( nHandle, '      <Alignment ss:Horizontal="Left" ss:Vertical="Bottom"/>'+ CRLF )
FWrite( nHandle, '      <Borders>'+ CRLF )
FWrite( nHandle, '      <Border ss:Position="Left" ss:LineStyle="Continuous" ss:Weight="1"/>'+ CRLF )
FWrite( nHandle, '      </Borders>'+ CRLF )
FWrite( nHandle, '     </Style>'+ CRLF )
FWrite( nHandle, '	<Style ss:ID="s91">' + CRLF )
FWrite( nHandle, '	 <Alignment ss:Horizontal="Center" ss:Vertical="Center"/>' + CRLF )
FWrite( nHandle, '	   <Borders>' + CRLF )
FWrite( nHandle, '      <Border ss:Position="Bottom" ss:LineStyle="Continuous" ss:Weight="1"/>' + CRLF )
FWrite( nHandle, '        <Border ss:Position="Left" ss:LineStyle="Continuous" ss:Weight="1"/>' + CRLF )
FWrite( nHandle, '        <Border ss:Position="Right" ss:LineStyle="Continuous" ss:Weight="1"/>' + CRLF )
FWrite( nHandle, '        <Border ss:Position="Top" ss:LineStyle="Continuous" ss:Weight="1"/>' + CRLF )
FWrite( nHandle, '      </Borders>' + CRLF )
FWrite( nHandle, '    <Interior ss:Color="#808080" ss:Pattern="Solid"/>' + CRLF )
FWrite( nHandle, '	</Style>' + CRLF )
// -------------------------- FIM DO ESTILOS --------------------------
FWrite( nHandle, '</Styles>' + CRLF )
// -------------------------- FIM DO ESTILOS --------------------------

// -------------------------- INICIO DAS DEFINICOES DE LARGURA DE COLUNA --------------------------
FWrite( nHandle, '<Worksheet ss:Name="MDTR849">' + CRLF )//Declara a primeira pasta de trabalho como sendo 'ENG2R202'
FWrite( nHandle, ' <Table x:FullColumns="1" ' + CRLF )
FWrite( nHandle, '   x:FullRows="1" ss:DefaultRowHeight="15">' + CRLF )
For nA := 1 To Len(aCabec)
	cTam := aCabec[nA][3]
	If aCabec[nA][1] == STR0037 //"Formulário"
		fBuscaRea( @aCabecFor , @aReavCri) // Monta cabeçalho e array com os resultados das formulas anteriores
		For nB := 1 To Len( aCabecFor )
			cTam := aCabecFor[nB][3]
			FWrite( nHandle, '   <Column ss:Width="'+cTam+'"/>' + CRLF )
		Next nB
	Else
		FWrite( nHandle, '   <Column ss:Width="'+cTam+'"/>' + CRLF )
	EndIf
Next
// -------------------------- FIM DAS DEFINICOES DE LARGURA DE COLUNA --------------------------
// -------------------------- Titulo --------------------------
nTamFor		:= Len(aCabecFor)
cRevisao :=  IIF(!Empty(MV_Par10) , STR0013+": " + MV_PAR10 , ' ' ) // "Revisão"
cTitPlan :=  STR0040 //+ cRevisao       // "ANÁLISE PRELIMINAR DE RISCO
cColunas := Str(If( nTamFor > 0 ,Len(aCabec)-1 + nTamFor-1,Len(aCabec)-2)-1)
FWrite( nHandle, '<Row ss:Height="33">' + CRLF )
FWrite( nHandle, '<Cell ss:MergeAcross="'+cColunas+'" ss:MergeDown="1" ss:StyleID="s64"><Data ss:Type="String">'+cTitPlan+'</Data></Cell>' + CRLF )
FWrite( nHandle, '<Cell ss:StyleID="s64left"><Data ss:Type="String">VERSÃO:</Data></Cell>' + CRLF )
FWrite( nHandle, '</Row>' + CRLF )
FWrite( nHandle, '<Row ss:Height="33">' + CRLF )
FWrite( nHandle, '<Cell ss:Index="'+cValToChar(Val(cColunas)+2)+'" ss:StyleID="s64left"><Data ss:Type="String">PÁGINA:</Data></Cell>' + CRLF )
FWrite( nHandle, '</Row>' + CRLF )
FWrite( nHandle, '<Row ss:AutoFitHeight="0">' + CRLF )
FWrite( nHandle, '<Cell ss:StyleID="s65"><Data ss:Type="String">' + "Unidade" + ':</Data></Cell>' + CRLF )
FWrite( nHandle, '<Cell ss:MergeAcross="'+cColunas+'" ss:StyleID="s66" />' + CRLF )
FWrite( nHandle, '</Row>' + CRLF )

// -------------------------- Final do Titulo --------------------------

// -------------------------- Cabecario --------------------------
nPosFor := 0
nPosMer := 0
lFormu	:= Len( aCabecFor ) > 0 .Or. MV_PAR12 == 1 .Or. MV_PAR13 == 1 .Or. MV_PAR15 == 1 .Or. MV_PAR16 == 1
nMerge  := If( MV_PAR12 == 1 , 1 , 0 ) + If( MV_PAR13 == 1 , 1 , 0 ) + If( MV_PAR15 == 1 , 1 , 0 ) + If( MV_PAR16 == 1 , 1 , 0 )
lMerge  := .F.
aMerge  := {}
If lFormu
	FWrite( nHandle, '<Row>' + CRLF )
Else
	FWrite( nHandle, '<Row ss:Height="170">' + CRLF )
EndIf
For nA := 1 To Len(aCabec)
	cCampo := aCabec[nA][1]
	cCor   := aCabec[nA][2]
	If cCampo $ STR0027 + "/" + STR0026 + "/" + STR0034 + "/" + STR0035
		aAdd( aMerge , aClone( aCabec[ nA ] ) )	
	EndIf
  	If STR0037 $ cCampo // "Formulário"
  		If nTamFor > 0
  	  		nPosFor := nA
			FWrite( nHandle,	'<Cell ss:MergeAcross="' + cValToChar(nTamFor-1) + '" ss:StyleID="'+cCor+'"><Data ss:Type="String">'+cCampo+'</Data></Cell>' + CRLF )
		EndIf
	ElseIf !lMerge .And. nMerge > 0 .And. cCampo $ STR0027 + "/" + STR0026 + "/" + STR0034 + "/" + STR0035
		nPosMer := nA
		FWrite( nHandle,	'<Cell '+If( nMerge-1 <= 0 , '' , 'ss:MergeAcross="' + cValToChar(nMerge-1) + '"' )+' ss:StyleID="s88center"><Data ss:Type="String">'+UPPER( STR0028 )+'</Data></Cell>' + CRLF )
		lMerge := .T.
	Else
		If !( nMerge > 0 .And. lMerge .And. cCampo $ STR0027 + "/" + STR0026 + "/" + STR0034 + "/" + STR0035 )
			FWrite( nHandle, '<Cell ' + If( lFormu , 'ss:MergeDown="1"' , '' ) + ' ss:StyleID="'+cCor+'"><Data ss:Type="String">'+cCampo+'</Data></Cell>' + CRLF )
		EndIf
	EndIf
Next
FWrite( nHandle, '</Row>' + CRLF )
//------------------- Formulario -------------------
If lFormu
	cIdx := 'ss:Index="'+cValToChar(nPosFor)+'"'
	If nMerge > 0
	 	cIdx := ''	
	EndIf
	FWrite( nHandle, '<Row ss:Height="170">' + CRLF )
	
	If nMerge > 0 
		For nMerg := 1 To Len( aMerge )	
			cCampo := aMerge[nMerg][1]
			cCor   := aMerge[nMerg][2]
			If nMerg == 1
				FWrite( nHandle, '<Cell ss:Index="'+cValToChar(nPosMer)+'" ss:StyleID="'+cCor+'"><Data ss:Type="String">'+cCampo+'</Data></Cell>' + CRLF )
			Else
				FWrite( nHandle, '<Cell ss:StyleID="'+cCor+'"><Data ss:Type="String">'+cCampo+'</Data></Cell>' + CRLF )
			EndIf	
		Next nMerg
	EndIf
	
	For nA := 1 To nTamFor
		cCampo := aCabecFor[nA][1]
		cCor   := aCabecFor[nA][2]
		If nA == 1
			FWrite( nHandle, '<Cell '+cIdx+' ss:StyleID="'+cCor+'"><Data ss:Type="String">'+cCampo+'</Data></Cell>' + CRLF )
		Else
			FWrite( nHandle, '<Cell ss:StyleID="'+cCor+'"><Data ss:Type="String">'+cCampo+'</Data></Cell>' + CRLF )
		EndIf
	Next nA
	FWrite( nHandle, '</Row>' + CRLF )
EndIf
// -------------------------- Final do Cabecalho --------------------------

// -------------------------- Itens --------------------------
cLocaliza := ""
lImprime  := .F.

DbSelectArea('TMPDBF')
DbGotop()
Do While !Eof()

	lImprime := .T.

	If cLocaliza <> TMPDBF->TG6_CODNIV .And. !Empty( cLocaliza )
		cLocaliza := TMPDBF->TG6_CODNIV
		FWrite( nHandle, '<Row ss:AutoFitHeight="0">' + CRLF )
		FWrite( nHandle, '<Cell ss:StyleID="s65"><Data ss:Type="String">' + "Participantes" + ':</Data></Cell>' + CRLF )
		FWrite( nHandle, '<Cell ss:MergeAcross="'+cColunas+'" ss:StyleID="s66" />' + CRLF )
		FWrite( nHandle, '</Row>' + CRLF )
	EndIf
	
	If( nPosic := aScan( aControl , { | x | x[ 1 ] == &( aEstrutura[1][1] ) } ) ) > 0
		aControles := aClone( aControl[ nPosic , 2 ] )
	Else
		aControles := { { "" , "" , "" } }
	EndIf
	
	If( nPosic:=aScan( aReavCri,{ | x | x[ 1 ] == &( aEstrutura[1][1] ) } ) ) > 0
		aReavalia := aClone( aReavCri[ nPosic , 2 ] )
	Else
		aReavalia := {}
		For nB := 1 To nTamFor
			aAdd( aReavalia, { "" , "" , "" } )
		Next nB
	EndIf
	
	nPosCtl := aScan( aEstrutura , { | x | X[ 1 ] == "CONTROLE" } )
	nPosFor := aScan( aEstrutura , { | x | X[ 1 ] == "FORMULARIO" } )
	For nB := 1 To Len( aControles )
		FWrite( nHandle, '<Row ss:AutoFitHeight="0">' + CRLF )
		If nB == 1
			For nA := 3 To Len(aEstrutura) // Despreza os dois primeiros campos de controle
				If nA <> nPosCtl
					cCampo    := aEstrutura[nA][1]
					xConteudo := &cCampo
					If aEstrutura[nA][2] == 'N'
						xConteudo := Alltrim(Str(xConteudo))
					ElseIf aEstrutura[nA][2] == 'L'
						xConteudo := If( xConteudo , STR0041 , STR0042 ) //STR0041##STR0042
					ElseIf aEstrutura[nA][2] == 'D'
						xConteudo := DTOC( xConteudo )
					Else
						xConteudo := AllTrim( xConteudo )
					Endif
				EndIf
				If nA == nPosCtl
					nA++
					FWrite( nHandle, '<Cell ss:StyleID="s50"><Data ss:Type="String">'+aControles[ nB , 2 ]+'</Data></Cell>' + CRLF )
					FWrite( nHandle, '<Cell ss:StyleID="s50"><Data ss:Type="String">'+aControles[ nB , 3 ]+'</Data></Cell>' + CRLF )
				ElseIf nA == nPosFor
					For nC := 1 To Len(aReavalia)
						If Len( aControles ) <= 1 .Or. nB > 1
							FWrite( nHandle, '<Cell ss:MergeDown="'+cValToChar(Len(aControles)-1)+'" ss:StyleID="s50"><Data ss:Type="String">'+aReavalia[ nC , 2 ]+'</Data></Cell>' + CRLF )
						Else
							FWrite( nHandle, '<Cell ss:MergeDown="'+cValToChar(Len(aControles)-1)+'" ss:StyleID="s50"><Data ss:Type="String">'+aReavalia[ nC , 2 ]+'</Data></Cell>' + CRLF )
						EndIf
					Next nC
				Else
					If Len( aControles ) <= 1 .Or. nB > 1
						FWrite( nHandle, '<Cell ss:StyleID="s50"><Data ss:Type="String">'+xConteudo+'</Data></Cell>' + CRLF )
					Else
						FWrite( nHandle, '<Cell ss:MergeDown="'+cValToChar(Len(aControles)-1)+'" ss:StyleID="s50"><Data ss:Type="String">'+xConteudo+'</Data></Cell>' + CRLF )
					EndIf
				Endif
				
			Next
		Else
			FWrite( nHandle, '<Cell ss:Index="' + cValToChar( ( nPosCtl - 2 ) ) + '" ss:StyleID="s50"><Data ss:Type="String">'+aControles[ nB , 2 ]+'</Data></Cell>' + CRLF )
			FWrite( nHandle, '<Cell ss:StyleID="s50"><Data ss:Type="String">'+aControles[ nB , 3 ]+'</Data></Cell>' + CRLF )	
		EndIf
		FWrite( nHandle, '</Row>' + CRLF )
	Next nB
	DbSelectArea('TMPDBF')
	DbSkip()
Enddo
If lImprime
	cLocaliza := TMPDBF->TG6_CODNIV
	FWrite( nHandle, '<Row ss:AutoFitHeight="0">' + CRLF )
	FWrite( nHandle, '<Cell ss:StyleID="s65"><Data ss:Type="String">' + "Participantes" + ':</Data></Cell>' + CRLF )
	FWrite( nHandle, '<Cell ss:MergeAcross="'+cColunas+'" ss:StyleID="s66" />' + CRLF )
	FWrite( nHandle, '</Row>' + CRLF )
EndIf
// -------------------------- Final dos itens --------------------------

// -------------------------- Cabec Legenda --------------------------
FWrite( nHandle, '<Row ss:AutoFitHeight="0">' + CRLF ) // Pula uma linha para deixar espaço da planilha de levantamento e o início da legenda
FWrite( nHandle, '</Row>' + CRLF )
FWrite( nHandle, '<Row ss:AutoFitHeight="0">' + CRLF )

FWrite( nHandle, '<Cell ss:StyleID="UpLeftThick" ss:MergeAcross="'+cValToChar(nColPER-2)+'"><Data ss:Type="String">'+STR0031+'</Data></Cell>' + CRLF )
FWrite( nHandle, '<Cell ss:StyleID="UpRightThick" ss:MergeAcross="'+cValToChar(((nColCTR-nColPER)-1)+nTamFor-1)+'"><Data ss:Type="String">'+STR0032+'</Data></Cell>' + CRLF )
FWrite( nHandle, '<Cell ss:StyleID="s50"><Data ss:Type="String">' + STR0033 + ': '+ Dtoc(Date())+'</Data></Cell>' + CRLF )

FWrite( nHandle, '</Row>' + CRLF )
// -------------------------- Final Cabec Legenda --------------------------

// -------------------------- Imprime a Legenda --------------------------
nCntPart := 0
For nA := 1 To Len(aLegenda)
	cDescri  := aLegCAB[nA,1]
	cLegenda := ''
	cStyle := ""
	DbSelectArea('TMPLEG')
	DbGotop()
	Do While !Eof()
		cCampo    := aLegenda[nA][1]
		If !Empty(&cCampo)
			If !Empty( cLegenda )
				cLegenda += ', '
			EndIf
			xConteudo := &cCampo
			cLegenda  += Alltrim(xConteudo)
		Endif
		DbSelectArea('TMPLEG')
		DbSkip()
	Enddo
	FWrite( nHandle, '<Row ss:AutoFitHeight="0">' + CRLF )
	For nB := 1 To 2
		If nB == 1		
			FWrite( nHandle, '<Cell ss:StyleID="LeftThick" ss:MergeAcross="'+cValToChar(nColPER-2)+'"><Data ss:Type="String">'+cDescri+'</Data></Cell>' + CRLF )
		Else
			FWrite( nHandle, '<Cell ss:StyleID="RightThick" ss:MergeAcross="'+cValToChar(((nColCTR-nColPER)-1)+nTamFor-1)+'"><Data ss:Type="String">'+cLegenda+'</Data></Cell>' + CRLF )
		Endif
	NExt nB
   	If nCntPart < 6
		nCntPart++
		If !Empty(cRevisao) .And. nCntPart == 1
			FWrite( nHandle, '<Cell ss:StyleID="s50left"><Data ss:Type="String">'+ cRevisao +'</Data></Cell>' + CRLF )
		ElseIf ( Empty(cRevisao) .And. nCntPart == 1 ) .Or. nCntPart == 2
			FWrite( nHandle, '<Cell ss:StyleID="s50left"><Data ss:Type="String">'+ "Responsáveis" +':</Data></Cell>' + CRLF )	
		Else
			FWrite( nHandle, '<Cell ss:StyleID="s50left"><Data ss:Type="String">'+ "Nome/Função" +':</Data></Cell>' + CRLF )
		EndIf
	EndIf
	FWrite( nHandle, '</Row>' + CRLF )
Next nA          
//imprimindo significancia na legenda
xConteudo := ""
DbSelectArea("TG4")
TG4->(DbSetOrder(1))                                                       
If TG4->(DbSeek(xFilial("TG4")))

	While !TG4->(Eof()) .AND. TG4->TG4_FILIAL == xFilial("TG4")
	    If !Empty( xConteudo )
	    	xConteudo += ", "
	    EndIf
	  	xConteudo += Alltrim(TG4->TG4_CODCLA)+"-"+Alltrim(TG4->TG4_DESCRI)
		TG4->(DbSkip())
	Enddo

Endif

If !Empty(xConteudo)    

	FWrite( nHandle, '<Row ss:AutoFitHeight="0">' + CRLF )
	FWrite( nHandle, '<Cell ss:StyleID="LeftThick" ss:MergeAcross="'+cValToChar(nColPER-2)+'"><Data ss:Type="String">'+TRANSFORM(STR0039,"@!")+'</Data></Cell>' + CRLF ) //"SIGNIFICÂNCIA"
	FWrite( nHandle, '<Cell ss:StyleID="RightThick" ss:MergeAcross="'+cValToChar(((nColCTR-nColPER)-1)+nTamFor-1)+'"><Data ss:Type="String">'+xConteUdo+'</Data></Cell>' + CRLF )
   If nCntPart < 6
		nCntPart++
		If !Empty(cRevisao) .And. nCntPart == 1
			FWrite( nHandle, '<Cell ss:StyleID="s50left"><Data ss:Type="String">'+ cRevisao +'</Data></Cell>' + CRLF )
		ElseIf ( Empty(cRevisao) .And. nCntPart == 1 ) .Or. nCntPart == 2
			FWrite( nHandle, '<Cell ss:StyleID="s50left"><Data ss:Type="String">'+ "Responsáveis" +':</Data></Cell>' + CRLF )	
		Else
			FWrite( nHandle, '<Cell ss:StyleID="s50left"><Data ss:Type="String">'+ "Nome/Função" +':</Data></Cell>' + CRLF )
		EndIf
	EndIf
	FWrite( nHandle, '</Row>' + CRLF )

Endif

//Imprime legenda da Classificação
dbSelectArea( "SX3" )
dbSetOrder( 2 )
dbSeek( "TGI_PRIORI" )
xConteUdo := Upper(X3CBox())
xConteUdo := StrTran( xConteUdo , ";" , "," )
xConteUdo := StrTran( xConteUdo , "=" , "-" )
FWrite( nHandle, '<Row ss:AutoFitHeight="0">' + CRLF )
FWrite( nHandle, '<Cell ss:StyleID="LeftThick" ss:MergeAcross="'+cValToChar(nColPER-2)+'"><Data ss:Type="String">'+Upper( STR0060 )+'</Data></Cell>' + CRLF ) //"Priorização de Controle"
FWrite( nHandle, '<Cell ss:StyleID="RightThick" ss:MergeAcross="'+cValToChar(((nColCTR-nColPER)-1)+nTamFor-1)+'"><Data ss:Type="String">'+xConteUdo+'</Data></Cell>' + CRLF )
If nCntPart < 6
	nCntPart++
	If !Empty(cRevisao) .And. nCntPart == 1
		FWrite( nHandle, '<Cell ss:StyleID="s50left"><Data ss:Type="String">'+ cRevisao +'</Data></Cell>' + CRLF )
	ElseIf ( Empty(cRevisao) .And. nCntPart == 1 ) .Or. nCntPart == 2
		FWrite( nHandle, '<Cell ss:StyleID="s50left"><Data ss:Type="String">'+ "Responsáveis" +':</Data></Cell>' + CRLF )	
	Else
		FWrite( nHandle, '<Cell ss:StyleID="s50left"><Data ss:Type="String">'+ "Nome/Função" +':</Data></Cell>' + CRLF )
	EndIf
EndIf
FWrite( nHandle, '</Row>' + CRLF )

If nCntPart < 5
	nCntPart++
	For nA := nCntPart To 6
		FWrite( nHandle, '<Row ss:AutoFitHeight="0">' + CRLF )
		If !Empty(cRevisao) .And. nA == 1
			FWrite( nHandle, '<Cell ss:StyleID="s50left" ss:Index="'+Alltrim(Str(nColCTR))+'"><Data ss:Type="String">'+ cRevisao +'</Data></Cell>' + CRLF )
		ElseIf ( Empty(cRevisao) .And. nA == 1 ) .Or. nA == 2
			FWrite( nHandle, '<Cell ss:StyleID="s50left" ss:Index="'+Alltrim(Str(nColCTR))+'"><Data ss:Type="String">'+ "Responsáveis" +':</Data></Cell>' + CRLF )	
		Else
			FWrite( nHandle, '<Cell ss:StyleID="s50left" ss:Index="'+Alltrim(Str(nColCTR))+'"><Data ss:Type="String">'+ "Nome/Função" +':</Data></Cell>' + CRLF )
		EndIf
		FWrite( nHandle, '</Row>' + CRLF )
	Next nA
EndIf

// -------------------------- Final da Legenda -----------------------------
FWrite( nHandle, '<Row ss:AutoFitHeight="0">' + CRLF )

For nA := 1 To (nColCTR - 1+nTamFor-1)
	FWrite( nHandle, '<Cell ss:StyleID="OnlyUpThick"><Data ss:Type="String"></Data></Cell>' + CRLF )
Next nA
FWrite( nHandle, '</Row>' + CRLF )

//-------------------------- Final da Planilha -----------------------------
FWrite( nHandle, '</Table>' + CRLF )
//--AutoAjuste
FWrite( nHandle, '  <WorksheetOptions xmlns="urn:schemas-microsoft-com:office:excel">' + CRLF )
FWrite( nHandle, '   <PageSetup>' + CRLF )
FWrite( nHandle, '    <Header x:Margin="0.4921259845"/>' + CRLF )
FWrite( nHandle, '    <Footer x:Margin="0.4921259845"/>' + CRLF )
FWrite( nHandle, '    <PageMargins x:Bottom="0.984251969" x:Left="0.78740157499999996"' + CRLF )
FWrite( nHandle, '     x:Right="0.78740157499999996" x:Top="0.984251969"/>' + CRLF )
FWrite( nHandle, '   </PageSetup>' + CRLF )
FWrite( nHandle, '   <Unsynced/>' + CRLF )
FWrite( nHandle, '   <Selected/>' + CRLF )
FWrite( nHandle, '   <Panes>' + CRLF )
FWrite( nHandle, '    <Pane>' + CRLF )
FWrite( nHandle, '     <Number>3</Number>' + CRLF )
FWrite( nHandle, '     <RangeSelection>R1:R1048576</RangeSelection>' + CRLF )
FWrite( nHandle, '    </Pane>' + CRLF )
FWrite( nHandle, '   </Panes>' + CRLF )
FWrite( nHandle, '   <ProtectObjects>False</ProtectObjects>' + CRLF )
FWrite( nHandle, '   <ProtectScenarios>False</ProtectScenarios>' + CRLF )
FWrite( nHandle, '  </WorksheetOptions>' + CRLF )
//---
FWrite( nHandle, '</Worksheet>' + CRLF )
FWrite( nHandle, '</Workbook>' + CRLF )
FCLOSE(nHandle)

dbCommit()
//--------------------------------
// Exporta relatorio para Excel
//--------------------------------
If !ApOleClient('MsExcel')
	MsgStop(STR0043) //"MsExcel não instalado!"
	Return
EndIf

ShellExecute("open", "excel", cArqPesq ,"" , SW_MAXIMIZE ) //- Microsoft Excel

Return
//---------------------------------------------------------------------
/*/{Protheus.doc} fRetRequisitos
Retorna os requisitos dos perigos e danos

@return

@sample
fRetRequisitos( '01' , '01' )

@author Jackson Machado
@since 27/03/2013
@version 1.0
/*/
//---------------------------------------------------------------------
Static Function fRetRequisitos( cPerigo , cDano )
	
	Local nFor			:= 0
	Local cRequisitos 	:= ""
	Local cTabela		:= ""
	Local cFldKey		:= ""
	Local cKeyPsq		:= ""
	Local cFldLeg		:= ""
	Local aRequisitos	:= { }
	Local aTabPrep		:= { { "TGB" , "TGB_CODPER" , cPerigo , "TGB_CODLEG" } , { "TGA" , "TGA_CODDAN" , cDano , "TGA_CODLEG" } }
	
	//Verifica a existência de treinamentos na análise
	For nFor := 1 To Len( aTabPrep )
		cTabela := aTabPrep[ nFor , 1 ]
		cFldKey := aTabPrep[ nFor , 2 ]
		cKeyPsq := aTabPrep[ nFor , 3 ]
		cFldLeg := aTabPrep[ nFor , 4 ]
		
		dbSelectArea( cTabela )
		dbSetOrder( 1 )
		dbSeek( xFilial( cTabela ) + cKeyPsq )
		While ( cTabela )->( !Eof() ) .AND. ( cTabela )->&( PrefixoCPO( cTabela ) + "_FILIAL" ) == xFilial( cTabela ) .AND. ;
						( cTabela )->&( cFldKey ) == cKeyPsq
			If aScan( aRequisitos , { | x | x == ( cTabela )->&( cFldLeg ) } ) == 0
				aAdd( aRequisitos , ( cTabela )->&( cFldLeg ) )
	    	EndIf
		    ( cTabela )->( dbSkip() )
		End
	Next nFor
	
	For nFor := 1  To Len( aRequisitos )
		
		If !Empty( cRequisitos )
			cRequisitos += "/"
		EndIf
		
		cRequisitos += AllTrim( aRequisitos[ nFor ] )//AllTrim( NGSeek( "TA0" , aRequisitos[ nFor ] , 1 , "TA0_EMENTA" ) )

	Next nFor
	
Return AllTrim( cRequisitos )
//---------------------------------------------------------------------
/*/{Protheus.doc} fRetControles
Retorna os controles aplicados no monitoramento

@return

@sample
fRetControles()

@author Jackson Machado
@since 27/03/2013
@version 1.0
/*/
//---------------------------------------------------------------------
Static Function fRetControles( aTabelas , lHistorico , cKeyPsq )
	
	Local nFor			:= 0
	Local cControles	:= ""
	Local cTblPsq		:= ""
	Local cFldWl		:= ""
	Local cFldKey		:= ""
	Local lConsid		:= .T.
	Local aControles	:= { }
	Local aMonit		:= aTabelas[ 4 ]
	Local aPlano		:= aTabelas[ 1 ]
	Local aSecund		:= { ;
							{ "TCD" , "TCD_DESCRI"	, "TGI_PRIORI" , "TGM_PRIORI" } , ;
							{ "TAA" , "TAA_NOME" 	, "TGF_PRIORI" , "TGJ_PRIORI" };
							}
	//Verifica os planos
	For nFor := 1 To 2
		lConsid := .T.
		If nFor == 1
			cTblPsq	:= aMonit[ If( lHistorico , 1 , 2 ) ]
			cFldWl	:= aMonit[ If( lHistorico , 3 , 4 ) ]
			cFldKey	:= aMonit[ If( lHistorico , 5 , 6 ) ]
			nOrd	:= 1
		Else
			cTblPsq	:= aPlano[ If( lHistorico , 1 , 2 ) ]
			cFldWl	:= aPlano[ If( lHistorico , 3 , 4 ) ]
			cFldKey	:= aPlano[ If( lHistorico , 5 , 6 ) ]
			nOrd	:= 1
		EndIf
		If aSecund[ nFor , 1 ] == "TAA" .And. mv_par14 <> 1
			lConsid := .F.
		EndIf
		
		If lConsid
			dbSelectArea( cTblPsq )
			dbSetOrder( nOrd )
			dbSeek( xFilial( cTblPsq ) + cKeyPsq )
			While( cTblPsq )->( !Eof() ) .And. xFilial( cTblPsq ) == ( cTblPsq )->&( PrefixoCPO( cTblPsq ) + "_FILIAL" ) .And. ;
					cKeyPsq == ( cTblPsq )->&( cFldWl )
				    
			    If aScan( aControles , { | x | x[ 1 ] == ( cTblPsq )->&( cFldKey ) } ) == 0
					aAdd( aControles , { ( cTblPsq )->&( cFldKey ) , AllTrim( NGSeek( aSecund[ nFor , 1 ] , ( cTblPsq )->&( cFldKey ) , 1 , aSecund[ nFor , 2 ] ) ) , ;
											If( lHistorico , ( cTblPsq )->&( aSecund[ nFor , 3 ] ) , ( cTblPsq )->&( aSecund[ nFor , 4 ] ) ) })
		    	EndIf

				( cTblPsq )->( dbSkip() )
			 End
		EndIf
	 Next nFor
	 
	If Len( aControles ) == 0 .Or. MV_PAR16 == 2
		aControles := { { "" , "" , "" } }
	EndIf
	
Return aControles
//---------------------------------------------------------------------
/*/{Protheus.doc} fIndStyle
Indica qual Style será utilizado

@return

@sample
fIndStyle()

@author Guilherme Benkendorf
@since 26/09/2013
@version 1.0
/*/
//---------------------------------------------------------------------
Static Function fIndStyle(cCodAVA)
	Local aAreaSty	:= GetArea()
	Local cCor		:= ""
	
	dbSelectArea( "TG2" )
	dbSetOrder( 1 )
	dbSeek( xFilial("TG2") + cCodAVA )	
	Do Case
		Case TG2->TG2_TIPO == "1" ; cCor := 's83'
		Case TG2->TG2_TIPO == "2" ; cCor := 's85'
		Case TG2->TG2_TIPO == "3" ; cCor := 's81'
	End Case
	
	RestArea(aAreaSty)
Return cCor
//---------------------------------------------------------------------
/*/{Protheus.doc} fBuscaRea
Retorna as fórmulas e os resultados das reavaliações

@return

@sample
fBuscaRea()

@author Guilherme Benkendorf
@since 26/09/2013
@version 1.0
/*/
//---------------------------------------------------------------------
Static Function fBuscaRea( aCabecRea , aReav )
	Local cCampo	:= cCor	:= cTam := ""
	Local cDescCri:= ""
	Local cIndica	:= ""
	Local cTam		:= "23"
	Local nX, nA
	Local nPosOrd	:= 0
		
	dbSelectArea(cTRB1)
	dbSetOrder(01)
	dbGoTop()

	While (cTRB1)->( !Eof() )
		dbSelectArea( "TG6" )
		dbSetOrder( 1 )//TG6_FILIAL+TG6_ORDEM+TG6_CODPER
		If !Empty(( cTRB1 )->REAVAL) .And. dbSeek( xFilial( "TG6" ) + ( cTRB1 )->REAVAL )
			dbSelectArea( "TG7" )
			dbSetOrder( 1 )//TG7_FILIAL+TG7_ORDEM+TG7_CODAVA+TG7_CODOPC
			dbSeek( xFilial( "TG7" ) + TG6->TG6_ORDEM )
			While TG7->( !Eof() ) .And. TG6->TG6_ORDEM == TG7->TG7_ORDEM .And. TG6->TG6_FILIAL == xFilial( "TG6" )
				cDescCri := NGSEEK("TG2",TG7->TG7_CODAVA,1,"TG2_DESCRI")
				If TG7->TG7_OK == "1" .And. Upper( AllTrim( cDescCri ) ) $ Upper( TG0->TG0_FORMUL )
					cIndica := NGSEEK("TG2",TG7->TG7_CODAVA,1,"TG2_TIPO")
					cIndica := If( cIndica == "3" , "1" , If( cIndica == "1" , "2" , "3" ) )
					If aScan( aCabecRea, {| x | x[ 1 ] == cDescCri } ) == 0
				  		aAdd(aCabecRea,	{;
												cDescCri,;
												fIndStyle(TG7->TG7_CODAVA),;
												cTam,;
												cIndica;
											})
					EndIf
					If ( nPosOrd := aScan( aReav , { | x | x[ 1 ] == ( cTRB1 )->ORDEM } ) ) == 0
						aAdd( aReav , { ( cTRB1 )->ORDEM , {} } )
						aAdd( aReav[ Len( aReav ) , 2 ] , { cDescCri , TG7->TG7_CODOPC , cIndica } )
					Else
						If aScan( aReav[ nPosOrd , 2 ] , { | x | x[ 1 ] == cDescCri } ) == 0
					 		aAdd( aReav[ nPosOrd , 2 ]  , { cDescCri , TG7->TG7_CODOPC , cIndica } )
						EndIf
					EndIf
				EndIf
				TG7->( dbSkip() )
			End
			//Adiciona a significância
			If aScan( aCabecRea , { | x | x[ 1 ] == STR0023 } ) == 0
				aAdd(aCabecRea,	{;
											STR0023,;//"Significância"
											's87',;
											'32',;
											'4';
										})
			EndIf
			
			dbSelectArea( "TGN" )
			dbSetOrder( 1 ) //TGN_FILIAL+TGN_ANALIS+TGN_CODFOR
			If dbSeek( xFilial( "TGN" ) + TG6->TG6_ORDEM + TG0->TG0_CODFOR )
				If ( nPosOrd := aScan( aReav , { | x | x[ 1 ] == ( cTRB1 )->ORDEM } ) ) == 0
					aAdd( aReav , { ( cTRB1 )->ORDEM , {} } )
					aAdd( aReav[ Len( aReav ) , 2 ] , { STR0023 , TG6->TG6_CODCLA , '4' } )
				Else
					aAdd( aReav[ nPosOrd , 2 ]  , { STR0023 , TG6->TG6_CODCLA , '4' } )
				EndIf	
			EndIf
		Else
			dbSelectArea( "TGD" )
			dbSetOrder( 4 )//TGD_FILIAL+TGD_REAVAL
			If !Empty(( cTRB1 )->REAVAL) .And. dbSeek( xFilial( "TGD" ) + ( cTRB1 )->REAVAL )
				dbSelectArea( "TGE" )
				dbSetOrder( 1 ) //TGE_FILIAL+TGE_CODHIS+TGE_ORDEM+TGE_CODAVA+TGE_CODOPC
				dbSeek( xFilial( "TGE" ) + TGD->TGD_CODHIS + TGD->TGD_ORDEM )
				While TGE->( !Eof() ) .And. TGE->TGE_ORDEM == TGD->TGD_ORDEM
					cDescCri := NGSEEK("TG2",TGE->TGE_CODAVA,1,"TG2_DESCRI")
					If TGE->TGE_OK == "1" .And. Upper( AllTrim( cDescCri ) ) $ Upper( TG0->TG0_FORMUL )
						cIndica := NGSEEK("TG2",TGE->TGE_CODAVA,1,"TG2_TIPO")
						cIndica := If( cIndica == "3" , "1" , If( cIndica == "1" , "2" , "3" ) )
						If aScan( aCabecRea, {| x | x[ 1 ] == cDescCri } ) == 0
					  		aAdd(aCabecRea,	{;
													cDescCri,;
													fIndStyle(TGE->TGE_CODAVA),;
													cTam,;
													cIndica;
												})
						EndIf
						If ( nPosOrd := aScan( aReav , { | x | x[ 1 ] == ( cTRB1 )->ORDEM } ) ) == 0
							aAdd( aReav , { ( cTRB1 )->ORDEM , {} } )
							aAdd( aReav[ Len( aReav ) , 2 ] , { cDescCri , TGE->TGE_CODOPC , cIndica } )
						Else
							If aScan( aReav[ nPosOrd , 2 ] , { | x | x[ 1 ] == cDescCri } ) == 0
						 		aAdd( aReav[ nPosOrd , 2 ]  , { cDescCri , TGE->TGE_CODOPC , cIndica } )
							EndIf
						EndIf
					EndIf
					TGE->(dbSkip())
				End
				
				//Adiciona a significância
				If aScan( aCabecRea , { | x | x[ 1 ] == STR0023 } ) == 0
					aAdd(aCabecRea,	{;
												STR0023,;//"Significância"
												's87',;
												'32',;
												'4';
											})
				EndIf
				
				dbSelectArea( "TGO" )
				dbSetOrder( 1 ) //TGO_FILIAL+TGO_CODHIS+TGO_ANALIS+TGO_CODFOR
				If dbSeek( xFilial( "TGO" ) + TGD->TGD_CODHIS + TGD->TGD_ORDEM + TG0->TG0_CODFOR )
					If ( nPosOrd := aScan( aReav , { | x | x[ 1 ] == ( cTRB1 )->ORDEM } ) ) == 0
						aAdd( aReav , { ( cTRB1 )->ORDEM , {} } )
						aAdd( aReav[ Len( aReav ) , 2 ] , { STR0023 , TGD->TGD_CODCLA , '4' } )
					Else
						aAdd( aReav[ nPosOrd , 2 ]  , { STR0023 , TGD->TGD_CODCLA , '4' } )
					EndIf	
				EndIf
			EndIf		
		EndIf
		(cTRB1)->(dbSkip())
	End	
   
   

	aCabecRea := aSort(aCabecRea,,,{|x,y| x[4] < y[4]})
	For nX := 1 To Len(aCabecRea)
		aDel(aCabecRea[nX],4)
		aSize(aCabecRea[nX],Len(aCabecRea[nX])-1)
	Next nX

	For nX := 1 To Len(aReav)
		aReav[nX,2] := aSort(aReav[nX,2],,,{|x,y| x[3] < y[3]})		
	Next nX
	
Return .T.
//---------------------------------------------------------------------
/*{Protheus.doc} SG400VaSX1
Funcao de Validação do SX1 de cPerg MDT849

@return Nil

@sample
SG400VaSX1("01")

@author Guilherme Benkendorf
@since 08/10/13
@version 1.0
//---------------------------------------------------------------------
*/
Function MDT849VSX1(cOrdem)
	Local lRet		:= .T.
	
	Do Case
		Case cOrdem == "01"
			lRet := If(Empty(MV_PAR01),.T., ExistCpo("TG1",MV_PAR01))
		Case cOrdem == "02"
			lRet := AteCodigo("TG1",MV_PAR01,MV_PAR02)
		Case cOrdem == "03"
			lRet := If(Empty(MV_PAR03),.T.,ExistCpo("TG8",MV_PAR03))
		Case cOrdem == "04"
			lRet := AteCodigo("TG8",MV_PAR03,MV_PAR04)
		Case cOrdem == "05"
			lRet := NGChkEstOr(AllTrim(MV_PAR05),AllTrim(MV_PAR06),,1)
		Case cOrdem == "06"
			If MV_PAR05 <= MV_PAR06   
		  		lRet := NGChkEstOr(AllTrim(MV_PAR05),AllTrim(MV_PAR06),,2)
			Else
				Help(" ",1,"DEATEINVAL")
				lRet := .F.
			EndIf
		Case cOrdem == "07"
			lRet := NaoVazio()
		Case cOrdem == "08"
			lRet := VALDATA( MV_PAR07 , MV_PAR08 , 'DATAINVALI' )
	End Case

Return lRet
