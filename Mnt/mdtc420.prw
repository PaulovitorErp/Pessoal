#INCLUDE "Protheus.ch"
#INCLUDE "TOPCONN.CH"
#INCLUDE "SHELL.CH"
#INCLUDE "MDTC420.CH"

#DEFINE _NQUESTAO  1
#DEFINE _NPERGUNTA 2
#DEFINE _NRESPOSTA 3

#DEFINE _SESMT       1
#DEFINE _FUNCIONARIO 2
#DEFINE _OUTROS      3

//---------------------------------------------------------------------
/*/{Protheus.doc} MDTC420
Gráfico de desvios de respostas no questionário de Medicina e
Segurança do Trabalho


@author Thiago Henrique dos Santos
@since 15/04/2013
@version P10

/*/
//---------------------------------------------------------------------
Function MDTC420()

	Local aSize := MsAdvSize( .T. )
	Local oDlg
	Local aDBF, aTRB
	Local lInverte := .F.
	Local oMARKF
	Local oTempTable
	Local aPerg := {}
	Local nOpc  := 0
	Local cValidCpo := ""
	Local nMaiorCpo := 0
	Local aTams     := { TAMSX3( "RA_MAT" )[1],TAMSX3( "TMK_CODUSU" )[1],TAMSX3( "QAA_MAT" )[1] }
	Local nI        := 0 // Variável de laço 'For'
	Local aExcs     := { "MDTC420B","MDTC420A","MDTC420" }
	Local cGrupo    := ''

	Private cMarca := GetMark()
	Private cPERG := "MDTC420C"
	Private cQuest := ""
	Private cSeries := ""
	Private aSeries := {}
	Private cTipList := ""
	Private cAliasTRB := GetNextAlias()

	Private aTrocaF3   := {}

	// Valida compatilibdade de dicionário
	If !MDT999COMPQ()
		Return Nil
	EndIf

	// Verifica qual o maior campo
	For nI := 1 To Len( aTams )
		If aTams[nI] > nMaiorCpo
			nMaiorCpo := aTams[nI]
		EndIf
	Next nI

	If !AliasInDic('TYH')

		// "As perguntas do relatório estão desatualizadas, favor aplicar a atualização contida no pacote da issue DNG-1847"
		MsgStop( STR0044 )

	Else
		// Gera tela de perguntas da consulta
		If !Pergunte( cPerg )
			Return Nil
		EndIf

		If Empty(MV_PAR03)

			ShowHelpDlg(STR0018,{STR0026},2,{STR0027},2)//#"Atenção"###"Parâmetros Inválidos."###"É obrigatório informar o questionário."

			Return

		Endif

		cQuest := MV_PAR03

		aDBF := {}
		AADD(aDBF,{ "TJ3_OK"      , "C" ,02      						, 0 })
		AADD(aDBF,{ "TJ3_QUESTA"  , "C" ,TamSx3("TJ3_QUESTA")[1] , 0 })
		AADD(aDBF,{ "TJ3_PERGUN"  , "C" ,TamSx3("TJ3_PERGUN")[1] , 0 })
		AADD(aDBF,{ "TJ3_TPLIST"  , "C" ,20,0 })

		aTRB := {}
		AADD(aTRB,{ "TJ3_OK"    ,NIL," "	  	,})
		AADD(aTRB,{ "TJ3_QUESTA",NIL,"Pergunta"	,})
		AADD(aTRB,{ "TJ3_PERGUN",NIL,"Descrição"	,})
		AADD(aTRB,{ "TJ3_TPLIST",NIL,"Tipo Questão"	,})

		oTempTable := FWTemporaryTable():New( cAliasTRB, aDBF )
		oTempTable:AddIndex( "1", {"TJ3_QUESTA"} )
		oTempTable:Create()

		dbSelectArea("TJ3")
		TJ3->(DbSetOrder(1))
		If TJ3->(DbSeek(xFilial("TJ3")+cQuest))

			While TJ3->(!Eof()) .AND. TJ3->TJ3_FILIAL == xFilial("TJ3") .AND. TJ3->TJ3_QUESTI == cQuest

				If Empty( TJ3->TJ3_PERGUN )
					NGDBSELSKIP( "TJ3" )
					Loop
				EndIf

				If TJ3->TJ3_TPLIST <> "3" .AND. TJ3->TJ3_TIPGRP == "1" //não apresenta perguntas com respostas descritivas e mostra apenas para tipo normal
					RecLock(cAliasTRB,.T.)
					(cAliasTRB)->TJ3_OK := "  "
					(cAliasTRB)->TJ3_QUESTA := TJ3->TJ3_QUESTA
					(cAliasTRB)->TJ3_PERGUN := TJ3->TJ3_PERGUN
					( cAliasTRB )->TJ3_TPLIST := NGRETSX3BOX( "TJ3_TPLIST",TJ3->TJ3_TPLIST )

					(cAliasTRB)->(MsUnlock())

				Endif


				TJ3->(Dbskip())
			Enddo

			(cAliasTRB)->(DbGotop())

		Endif

			DEFINE MSDIALOG oDlg TITLE STR0015+" "+Alltrim(cQuest) FROM 0, 0 TO aSize[6], aSize[5] PIXEL  //#Questionário

				oPanel := TPanel():New(aSize[2],aSize[1],,oDlg,,,,,,aSize[3],aSize[4])

				oMARKF := MsSelect():NEW(cAliasTRB,"TJ3_OK",,aTRB,@lINVERTE,@cMARCA,{0,0,aSize[4],aSize[3]},,,oPanel)
				oMARKF:oBROWSE:lHASMARK := .T.
				oMARKF:oBROWSE:lCANALLMARK := .T.
				oMARKF:oBROWSE:bALLMARK := {|| InvMarca(cMarca,cAliasTRB) }//Funcao inverte marcadores
				oMARKF:oBROWSE:ALIGN := CONTROL_ALIGN_ALLCLIENT

			ACTIVATE MSDIALOG oDlg ON INIT EnchoiceBar(oDlg,{|| nOpc := 1, If(ValPergs(),oDlg:End(),nOpc := 0)},{|| nOpc := 0,oDlg:End()}) CENTERED

		If nOpc == 1

			Processa( {|| MDTC420GER(cAliasTRB) },STR0016 ,STR0017 ,.F.) //#"Aguarde..." ### "Processando Consulta..."

		Endif

		oTempTable:Delete()
	EndIf

Return

//---------------------------------------------------------------------
/*/{Protheus.doc} ValPergs
Rotina que Valida se as perguntas selecionadas  são comuns e
possuem a mesma série de respostas


@return lRet - Indica se a seleção é válida ou não
@author Thiago Henrique dos Santos
@since 15/04/2013
@version P10

/*/
//---------------------------------------------------------------------
Static Function ValPergs()

	Local lRet        := .T.
	Local lAchou      := .F.
	Local aOptionsTJ3 := {}
	Local aOptionsSer := {}
	Local nI          := 0

	DbSelectArea(cAliasTRB)
	(cAliasTRB)->(DbGoTop())

	While (cAliasTRB)->(!Eof())

		If !Empty((cAliasTRB)->TJ3_OK)

			DbSelectArea("TJ3")
			TJ3->(DbSetOrder(1))
			IF TJ3->(DbSeek(xFilial("TJ3")+cQuest+(cAliasTRB)->TJ3_QUESTA))

				If !lAchou

					cSeries := Alltrim(TJ3->TJ3_COMBO)
					cTipList := Alltrim(TJ3->TJ3_TPLIST)
					aOptionsTJ3 := StrTokArr( TJ3->TJ3_COMBO, ";" )

				EndIf

				lAchou := .T.

				aOptionsSer := StrTokArr( cSeries, ";" )

				// Valida se série das questões são iguais
				If Len( aOptionsTJ3 ) > 0 .And. Len( aOptionsSer ) > 0
					For nI := 1 To Len( aOptionsSer )
						If AllTrim( SubStr( aOptionsSer[nI],1,At( "*P:",aOptionsSer[nI] ) - 1 ) ) != AllTrim( SubStr( aOptionsTJ3[nI],1,At( "*P:",aOptionsTJ3[nI] ) - 1 ) )
							lRet := .F.
						EndIf
					Next nI
				EndIf

				/*
				If cSeries <>  Alltrim(TJ3->TJ3_COMBO) .OR. cTipList <> Alltrim(TJ3->TJ3_TPLIST)
					lRet := .F.
				Endif */

				If cTipList <> AllTrim( TJ3->TJ3_TPLIST )
					lRet := .F.
				EndIf

			Endif


		Endif

		(cAliasTRB)->(DbSkip())

	Enddo

	If !lRet
		ShowHelpDlg(STR0018,{STR0019,STR0020},2,; //#"Atenção"###"Não é possivel traçar gráfico."###"As perguntas selecionadas possuem séries de respostas incompatíveis."
						{STR0021},2)//#"Selecione apenas perguntas do mesmo tipo e com as mesmas séries de respostas."
	Endif

	If !lAchou

		lRet := .F.

		ShowHelpDlg(STR0018,{STR0019},2,{STR0021},2)//#"Atenção"###"Não é possivel traçar gráfico."###"Selecione pelo menos uma pergunta"


	Endif
	( cAliasTRB )->( DbGoTop() )

Return lRet



//---------------------------------------------------------------------
/*/{Protheus.doc} MDTC420GER
Rotina que gera o gráfico de desvios

@param cAliasTRB - Alias do arquivo temporário para selecao de perguntas

@author Thiago Henrique dos Santos
@since 15/04/2013
@version P10

/*/
//---------------------------------------------------------------------

Static Function MDTC420GER

Local cSql := ""
Local dDeResp   := MV_PAR01
Local dAteResp  := MV_PAR02
Local cLocaliz := MV_PAR04
Local cCCustro := MV_PAR05
Local cFuncao := MV_PAR06
Local cTarefa := MV_PAR07
Local cAmbiente := MV_PAR08
Local cFunciona := MV_PAR10
Local cResponsa  := MV_PAR12
Local cAliasSql := GetNextAlias()
Local aQuest := {}
Local nI := 0
Local nX := 0
Local cPerg := ""
//Local aResp := {}
Local lFirst := .T.
Local aTable := {}
Local nTam := 0
Local aLinha := {}
Local aTemp := {}
Local nPerg := 0
Local cTemp := ""
Local lFormula := .F.
Local cCampo := ""
Local cStringOpc := ""


DbSelectArea(cAliasTRB)
ProcRegua(0)
(cAliasTRB)->(DbGoTop())

While (cAliasTRB)->(!Eof())

	IncProc("Processando Consulta..")

	If !Empty((cAliasTRB)->TJ3_OK)

		AADD(aQuest,(cAliasTRB)->TJ3_QUESTA)

	Endif


	(cAliasTRB)->(DbSkip())
Enddo


cSql := "SELECT TJ3_PERGUN, TJ3_FORMUL, TJ3_QUESTA, TJ5_RESPCD, TJ5_NUMERI, COUNT(*) AS NUMRESP "
cSql += "FROM "+RetSqlName("TJ5")+" TJ5 "
cSql += "INNER JOIN "+RetSqlName("TJ3")+" TJ3 ON TJ3_FILIAL = TJ5_FILIAL AND TJ3_QUESTI = TJ5_QUEST AND TJ3_QUESTA = TJ5_PERG AND TJ3.D_E_L_E_T_ <> '*' "
cSql += "LEFT JOIN "+RetSqlName("TJ1")+" TJ1 ON TJ1_FILIAL = TJ5_FILIAL AND TJ1_QUESTI = TJ5_QUEST AND TJ1_DTINC = TJ5_DTRESP AND TJ1_FUNC = TJ5_FUNC AND TJ1_TAR = TJ5_TAR AND TJ1_CC = TJ5_CC AND TJ1_AMB = TJ5_AMB AND TJ1_LOC = TJ5_LOC AND TJ1_MAT = TJ5_MAT AND TJ1_OSSIMU = TJ5_OSSIMU AND TJ1.D_E_L_E_T_ <> '*' "
cSql += "WHERE TJ5_FILIAL = '"+xFilial("TJ5")+"' AND TJ5_QUEST = '"+cQuest+"' "

//Filtros das questoes selecionadas
If len(aQuest) > 0

	cSql+= "AND TJ5_PERG IN ("

	For nI:= 1 to len(aQuest)

		If nI > 1

			cSql += ","

		Endif

		cSql += "'"+aQuest[nI]+"'"

	Next nI

	cSql += ") "

Endif


//FILTROS DOS PARÂMETROS
If !Empty( dDeResp )

	cSql += "AND TJ5_DTRESP >= '" + DTOS( dDeResp ) + "' AND TJ5_DTRESP <= '" + DTOS( dAteResp ) + "' "

Endif

If !Empty(cLocaliz)

	cSql += "AND TJ5_LOC =  '"+cLocaliz+"' "

Endif

If !Empty(cCCustro)

	cSql += "AND TJ5_CC =  '"+cCCustro+"' "

Endif

If !Empty(cFuncao)

	cSql += "AND TJ5_FUNC =  '"+cFuncao+"' "

Endif

If !Empty(cTarefa)

	cSql += "AND TJ5_TAR =  '"+cTarefa+"' "

Endif

If !Empty(cAmbiente)

	cSql += "AND TJ5_AMB =  '"+cAmbiente+"' "

Endif


If !Empty(cFunciona)

	cSql += "AND TJ5_MAT =  '"+cFunciona+"' "

Endif


If !Empty(cResponsa)

	cSql += "AND TJ1_RESPEN =  '"+cResponsa+"' "

Endif


cSql += "AND TJ5.D_E_L_E_T_ <> '*' "
cSql += "GROUP BY TJ3_PERGUN, TJ3_FORMUL, TJ3_QUESTA, TJ5_RESPCD, TJ5_NUMERI "
cSql += "ORDER BY TJ3_PERGUN ASC "

cSql := ChangeQuery(cSql)

MPSysOpenQuery( cSql , cAliasSql )

//montado tabela em array


/*** Formato aTables *******

  A   		B   	 C       D     	E
1 						 Serie1 	Serie2 	Serie3 ...
2 Descri1 Pergunt1 tot1 	tot2 		tot3   ...
3 .
4 .
  .                            ***/

If cTipList == "5" //series da formula

	cSeries := ""
	DbselectArea(cAliasSql)
	(cAliasSql)->(DbGoTop())

	If (cAliasSql)->(!Eof())

		DbSelectArea("TJ6")
		TJ6->(DbSetOrder(1))
		If TJ6->(DbSeek(xFilial("TJ6")+(cAliasSql)->TJ3_FORMUL))

			While TJ6->(!Eof()) .AND. TJ6->TJ6_FILIAL+TJ6->TJ6_CODFOR == xFilial("TJ6")+(cAliasSql)->TJ3_FORMUL

				If !Empty(cSeries)

					cSeries+=";"

				Endif

				cSeries+="="+Alltrim(TJ6->TJ6_RETOR)+"*"+cValToChar(TJ6->TJ6_ITDE)+"#"+cValToChar(TJ6->TJ6_ITATE)

				TJ6->(DbSkip())
			Enddo

		Else

		   lFormula := .T.
		   cSeries+="1=Resposta*"+"*0#9999999999999999"  // Para considerar na série entre uma faixa grande qndo não for fórmula

		EndIf

	Endif



Endif

aSeries := StrTokArr(cSeries,";")



//preparando o tamanho de colunas para a tabela
If len(aSeries) == 0

   aTemp  := Array(1,3)
	aLinha := ACLONE(aTemp[1])

	//preparando a linha em branco da tabela
	aLinha[1] := ""
	aLinha[2] := ""
	aLinha[3] := 0

	AADD(aTable,ACLONE(aLinha))
	aTable[1][3]:= "Resultado"

Else

   aTemp :=  Array(1,len(aSeries)+2)
   aLinha :=  ACLONE(aTemp[1])

	//preparando a linha em branco da tabela
	aLinha[1] := ""
	aLinha[2] := ""
	For nI := 3 to len(aLinha)
		aLinha[nI] := 0
	Next nI


	AADD(aTable,ACLONE(aLinha))

	For nI := 1 to len(aSeries)

		// aTable[1][nI+2] := Alltrim(Substr(aSeries[nI],At("=", aSeries[nI])+1,At("*", aSeries[nI])-1 - At("=", aSeries[nI])))

		If ValType( aTable[1][nI+2] ) == "N" .And. Empty( aTable[1][nI+2] )
			aTable[1][nI+2] := Nil
		EndIf

		cStringOpc := ""
		If "*" $ aSeries[nI]
     		cStringOpc := AllTrim( SubStr( aSeries[nI],At( "=",aSeries[nI] ) + 1,At( "*",aSeries[nI] ) - 1 - At( "=",aSeries[nI] ) ) )
     	Else
     		cStringOpc := AllTrim( SubStr( aSeries[nI],At( "=",aSeries[nI] ) + 1,Len( aSeries[nI] ) ) )
     	EndIf

		If Empty( aTable[1][nI+2] )
			aTable[1][nI+2] := cStringOpc
		Else
			aTable[1][nI+2] += cStringOpc
		EndIf

	Next nI

Endif




DbselectArea(cAliasSql)
(cAliasSql)->(DbGoTop())

While (cAliasSql)->(!Eof())

   If len(aTable) > 1
		nPerg := aScan(aTable,{|x|x[2] == Alltrim((cAliasSql)->TJ3_QUESTA)})
	Else

		nPerg := 0
	Endif

	If  nPerg < 1

		AADD(aTable,ACLONE(aLinha))

		nPerg := len(aTable)
		aTable[nPerg][1]:= Alltrim((cAliasSql)->TJ3_PERGUN)
		aTable[nPerg][2]:= Alltrim((cAliasSql)->TJ3_QUESTA)

	Endif

	If cTipList $ "12" // opção exclusiva ou multipla

		If aScan(aSeries,{|x| (cAliasSql)->TJ5_RESPCD+"=" $ x}) > 0


			aTable[nPerg][aScan(aSeries,{|x| (cAliasSql)->TJ5_RESPCD+"=" $ x})+2] += (cAliasSql)->NUMRESP

		Endif


	ElseIf cTipList == "4" // numerico, série unica

		aTable[nPerg][3] += (cAliasSql)->TJ5_NUMERI * (cAliasSql)->NUMRESP


	ElseIf cTipList == "5" // Formula

		//cTemp := cValToChar((cAliasSql)->TJ5_NUMERI)

		nX := aScan(aSeries,{|x| (cAliasSql)->TJ5_NUMERI >= Val(SUBSTR(x, At("*",x)+1, At("#",x) -1 - At("*", x))) ;
								.AND. (cAliasSql)->TJ5_NUMERI <= Val(SUBSTR(x, At("#",x)+1,len(x)- At("#",x)  ))})

		If lFormula
			cCampo := "TJ5_NUMERI"
		Else
			cCampo := "NUMRESP"
		EndIf

		If nX > 0

			aTable[nPerg][nX+2] += (cAliasSql)->&(cCampo)

		Endif


	Endif

	(cAliasSql)->(dbSkip())
Enddo

IncProc(STR0023) //#"Gerando Arquivo XLSX"

GeraXlsx(aTable)


Return



//---------------------------------------------------------------------
/*/{Protheus.doc} GeraXlsx
Gera o arquivo xlsx

@param cMarca - Marcação
@param cAliasTRB - Alias temporário

@author Thiago Henrique dos Santos
@since 15/04/2013
@version P10

/*/
//---------------------------------------------------------------------
Static Function  GeraXlsx(aTable)

Local cNome := FunName()+"-"+StrTran(Alltrim(Time()),":","")
Local cPath := AllTrim(GetTempPath())+cNome

Local cArqVBS := ""
Local cArq := ""
Local nI := 0
Local nTam := 0

Local cVBS := ""
Local nHandle := 0
Local cConType:= ""
Local c_Rels := ""
Local cApp := ""
Local cCore := ""
Local cTemp := ""
Local cColuna := "ABCDEFGHIJKLMNOPQRSTUVWXYZ"
Local nJ := 0


//RpcSetType(3)
//RpcSetEnv('99','01')

If ExistDir(cPath)

	DirRemove(cPath)

Endif

//arquivo da raiz do documento   /.

/***************************************************************************************************************************
									[Content_Types].xml
 ***************************************************************************************************************************/


cConType := '<?xml version="1.0" encoding="UTF-8" standalone="yes"?>'+CRLF
cConType += '<Types xmlns="http://schemas.openxmlformats.org/package/2006/content-types">'
cConType +='<Default Extension="rels" ContentType="application/vnd.openxmlformats-package.relationships+xml"/>'
cConType +='<Default Extension="xml" ContentType="application/xml"/><Override PartName="/xl/workbook.xml" ContentType="application/vnd.openxmlformats-officedocument.spreadsheetml.sheet.main+xml"/>'
cConType +='<Override PartName="/xl/worksheets/sheet1.xml" ContentType="application/vnd.openxmlformats-officedocument.spreadsheetml.worksheet+xml"/>'
cConType +='<Override PartName="/xl/worksheets/sheet2.xml" ContentType="application/vnd.openxmlformats-officedocument.spreadsheetml.worksheet+xml"/>'
cConType +='<Override PartName="/xl/worksheets/sheet3.xml" ContentType="application/vnd.openxmlformats-officedocument.spreadsheetml.worksheet+xml"/>'
cConType +='<Override PartName="/xl/theme/theme1.xml" ContentType="application/vnd.openxmlformats-officedocument.theme+xml"/>'
cConType +='<Override PartName="/xl/styles.xml" ContentType="application/vnd.openxmlformats-officedocument.spreadsheetml.styles+xml"/>'
cConType +='<Override PartName="/xl/sharedStrings.xml" ContentType="application/vnd.openxmlformats-officedocument.spreadsheetml.sharedStrings+xml"/>'
cConType +='<Override PartName="/xl/drawings/drawing1.xml" ContentType="application/vnd.openxmlformats-officedocument.drawing+xml"/>'
cConType +='<Override PartName="/xl/charts/chart1.xml" ContentType="application/vnd.openxmlformats-officedocument.drawingml.chart+xml"/>'
cConType +='<Override PartName="/docProps/core.xml" ContentType="application/vnd.openxmlformats-package.core-properties+xml"/>'
cConType +='<Override PartName="/docProps/app.xml" ContentType="application/vnd.openxmlformats-officedocument.extended-properties+xml"/>'
cConType +='</Types>'


MakeDir(cPath)
cArq := cPath+"\[Content_Types].xml"

nHandle  := FCREATE(cArq, 0)
fWrite(nHandle, cConType)
fClose(nHandle)


/***************************************************************************************************************************
									/_rels/.rels.xml
 ***************************************************************************************************************************/

//Arquivos de /_rels/

c_Rels := '<?xml version="1.0" encoding="UTF-8" standalone="yes"?>'+CRLF
c_Rels += '<Relationships xmlns="http://schemas.openxmlformats.org/package/2006/relationships">'
c_Rels += '<Relationship Id="rId3" Type="http://schemas.openxmlformats.org/officeDocument/2006/relationships/extended-properties" Target="docProps/app.xml"/>'
c_Rels += '<Relationship Id="rId2" Type="http://schemas.openxmlformats.org/package/2006/relationships/metadata/core-properties" Target="docProps/core.xml"/>'
c_Rels += '<Relationship Id="rId1" Type="http://schemas.openxmlformats.org/officeDocument/2006/relationships/officeDocument" Target="xl/workbook.xml"/>
c_Rels += '</Relationships>'

MakeDir(cPath+"\_rels")
cArq := cPath+"\_rels"+"\.rels"

nHandle  := FCREATE(cArq, 0)
fWrite(nHandle, c_Rels)
fClose(nHandle)



/***************************************************************************************************************************
									Arquivos de /docProps/
 ***************************************************************************************************************************/

cApp := '<?xml version="1.0" encoding="UTF-8" standalone="yes"?>'+CRLF
cApp+= '<Properties xmlns="http://schemas.openxmlformats.org/officeDocument/2006/extended-properties" xmlns:vt="http://schemas.openxmlformats.org/officeDocument/2006/docPropsVTypes">'
cApp+= '<Application>Microsoft Excel</Application>'
cApp+= '<DocSecurity>0</DocSecurity><ScaleCrop>false</ScaleCrop>'
cApp+= '<HeadingPairs><vt:vector size="2" baseType="variant"><vt:variant><vt:lpstr>Planilhas</vt:lpstr></vt:variant>'
cApp+= '<vt:variant><vt:i4>3</vt:i4></vt:variant></vt:vector></HeadingPairs>'
cApp+= '<TitlesOfParts><vt:vector size="3" baseType="lpstr"><vt:lpstr>Plan1</vt:lpstr><vt:lpstr>Plan2</vt:lpstr><vt:lpstr>Plan3</vt:lpstr>'
cApp+= '</vt:vector></TitlesOfParts><LinksUpToDate>false</LinksUpToDate><SharedDoc>false</SharedDoc>'
cApp+= '<HyperlinksChanged>false</HyperlinksChanged><AppVersion>14.0300</AppVersion></Properties>'


cCore := '<?xml version="1.0" encoding="UTF-8" standalone="yes"?>'+CRLF
cCore += '<cp:coreProperties xmlns:cp="http://schemas.openxmlformats.org/package/2006/metadata/core-properties" xmlns:dc="http://purl.org/dc/elements/1.1/" xmlns:dcterms="http://purl.org/dc/terms/" xmlns:dcmitype="http://purl.org/dc/dcmitype/" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance">'
cCore += '<dc:creator>d0d0</dc:creator><cp:lastModifiedBy>d0d0</cp:lastModifiedBy>'

cCore += '<dcterms:created xsi:type="dcterms:W3CDTF">'+Substr(DtoS(Date()),1,4)+'-'+Substr(DtoS(Date()),5,2)+;
				'-'+Substr(DtoS(Date()),7,2)+'T'+Alltrim(Time())+'Z</dcterms:created>'
cCore += '<dcterms:modified xsi:type="dcterms:W3CDTF">'+Substr(DtoS(Date()),1,4)+'-'+Substr(DtoS(Date()),5,2)+;
				'-'+Substr(DtoS(Date()),7,2)+'T'+Alltrim(Time())+'Z</dcterms:modified></cp:coreProperties>'

MakeDir(cPath+"\docProps")
cArq := cPath+"\docProps"+"\app.xml"

nHandle  := FCREATE(cArq, 0)
fWrite(nHandle, cApp)
fClose(nHandle)


cArq := cPath+"\docProps"+"\core.xml"
nHandle  := FCREATE(cArq, 0)
fWrite(nHandle, cCore)
fClose(nHandle)



//Arquivos de /xl/
MakeDir(cPath+"\xl")

/***************************************************************************************************************************
									Shared Strings
 ***************************************************************************************************************************/


nTam := (len(aTable) -1) * 2
nTam += len(aTable[1]) - 1


cTemp := '<?xml version="1.0" encoding="UTF-8" standalone="yes"?>'+CRLF
cTemp += '<sst xmlns="http://schemas.openxmlformats.org/spreadsheetml/2006/main" count="'+cValToChar(nTam)+'" uniqueCount="'+cValToChar(nTam)+'">'

//strings de séries
cTemp += '<si><t>'+STR0024+'</t></si>'	//#"Pergunta"
For nI := 3 to len(aTable[1])

	cTemp += '<si><t>'+aTable[1][nI]+'</t></si>'

Next nI

//strings de codigos
 For nI := 2 to len(aTable)

	cTemp += '<si><t>'+aTable[nI][2]+'</t></si>'

Next nI

//strings das perguntas
For nI := 2 to len(aTable)
	cTemp += '<si><t>'+aTable[nI][1]+'</t></si>'
Next nI


cTemp += '</sst>'

cArq := cPath+"\xl"+"\sharedStrings.xml"
nHandle  := FCREATE(cArq, 0)
fWrite(nHandle, cTemp)
fClose(nHandle)

cTemp := '<?xml version="1.0" encoding="UTF-8" standalone="yes"?>'+CRLF
cTemp += '<styleSheet xmlns="http://schemas.openxmlformats.org/spreadsheetml/2006/main" xmlns:mc="http://schemas.openxmlformats.org/markup-compatibility/2006" mc:Ignorable="x14ac" xmlns:x14ac="http://schemas.microsoft.com/office/spreadsheetml/2009/9/ac">'
cTemp += '<fonts count="1" x14ac:knownFonts="1"><font><sz val="11"/><color theme="1"/><name val="Calibri"/><family val="2"/>'
cTemp += '<scheme val="minor"/></font></fonts><fills count="2"><fill><patternFill patternType="none"/></fill>'
cTemp += '<fill><patternFill patternType="gray125"/></fill></fills><borders count="1"><border><left/><right/><top/><bottom/>'
cTemp += '<diagonal/></border></borders><cellStyleXfs count="1"><xf numFmtId="0" fontId="0" fillId="0" borderId="0"/></cellStyleXfs>'
cTemp += '<cellXfs count="1"><xf numFmtId="0" fontId="0" fillId="0" borderId="0" xfId="0"/></cellXfs><cellStyles count="1">'
cTemp += '<cellStyle name="Normal" xfId="0" builtinId="0"/></cellStyles><dxfs count="0"/>'
cTemp += '<tableStyles count="0" defaultTableStyle="TableStyleMedium2" defaultPivotStyle="PivotStyleLight16"/>'
cTemp += '<extLst><ext uri="{EB79DEF2-80B8-43e5-95BD-54CBDDF9020C}" xmlns:x14="http://schemas.microsoft.com/office/spreadsheetml/2009/9/main">'
cTemp += '<x14:slicerStyles defaultSlicerStyle="SlicerStyleLight1"/></ext></extLst></styleSheet>'

cArq := cPath+"\xl"+"\styles.xml"
nHandle  := FCREATE(cArq, 0)
fWrite(nHandle, cTemp)
fClose(nHandle)

/***************************************************************************************************************************
									Workbook
 ***************************************************************************************************************************/


cTemp := '<?xml version="1.0" encoding="UTF-8" standalone="yes"?>'+CRLF
cTemp += '<workbook xmlns="http://schemas.openxmlformats.org/spreadsheetml/2006/main" xmlns:r="http://schemas.openxmlformats.org/officeDocument/2006/relationships">'
cTemp += '<fileVersion appName="xl" lastEdited="5" lowestEdited="5" rupBuild="9302"/><workbookPr defaultThemeVersion="124226"/>'
cTemp += '<bookViews><workbookView xWindow="240" yWindow="45" windowWidth="20115" windowHeight="7740"/></bookViews><sheets>'
cTemp += '<sheet name="Plan1" sheetId="1" r:id="rId1"/><sheet name="Plan2" sheetId="2" r:id="rId2"/>'
cTemp += '<sheet name="Plan3" sheetId="3" r:id="rId3"/></sheets><calcPr calcId="145621"/></workbook>'

cArq := cPath+"\xl"+"\workbook.xml"
nHandle  := FCREATE(cArq, 0)
fWrite(nHandle, cTemp)
fClose(nHandle)



//arquivo de /xl/_rels/
MakeDir(cPath+"\xl\_rels")

/***************************************************************************************************************************
									Workbook.rels
 ***************************************************************************************************************************/


cTemp := '<?xml version="1.0" encoding="UTF-8" standalone="yes"?>'+CRLF
cTemp += '<Relationships xmlns="http://schemas.openxmlformats.org/package/2006/relationships">'
cTemp += '<Relationship Id="rId3" Type="http://schemas.openxmlformats.org/officeDocument/2006/relationships/worksheet" Target="worksheets/sheet3.xml"/>'
cTemp += '<Relationship Id="rId2" Type="http://schemas.openxmlformats.org/officeDocument/2006/relationships/worksheet" Target="worksheets/sheet2.xml"/>'
cTemp += '<Relationship Id="rId1" Type="http://schemas.openxmlformats.org/officeDocument/2006/relationships/worksheet" Target="worksheets/sheet1.xml"/>'
cTemp += '<Relationship Id="rId6" Type="http://schemas.openxmlformats.org/officeDocument/2006/relationships/sharedStrings" Target="sharedStrings.xml"/>'
cTemp += '<Relationship Id="rId5" Type="http://schemas.openxmlformats.org/officeDocument/2006/relationships/styles" Target="styles.xml"/>'
cTemp += '<Relationship Id="rId4" Type="http://schemas.openxmlformats.org/officeDocument/2006/relationships/theme" Target="theme/theme1.xml"/>'
cTemp += '</Relationships>'

cArq := cPath+"\xl\_rels\workbook.xml.rels"
nHandle  := FCREATE(cArq, 0)
fWrite(nHandle, cTemp)
fClose(nHandle)

//arquivos de /xl/charts/
MakeDir(cPath+"\xl\charts")

/***************************************************************************************************************************
									Charts
 ***************************************************************************************************************************/


cTemp := '<?xml version="1.0" encoding="UTF-8" standalone="yes"?>'+CRLF
cTemp += '<c:chartSpace xmlns:c="http://schemas.openxmlformats.org/drawingml/2006/chart" xmlns:a="http://schemas.openxmlformats.org/drawingml/2006/main" xmlns:r="http://schemas.openxmlformats.org/officeDocument/2006/relationships">'
cTemp += '<c:date1904 val="0"/><c:lang val="pt-BR"/><c:roundedCorners val="0"/>'
cTemp += '<mc:AlternateContent xmlns:mc="http://schemas.openxmlformats.org/markup-compatibility/2006">'
cTemp += '<mc:Choice Requires="c14" xmlns:c14="http://schemas.microsoft.com/office/drawing/2007/8/2/chart">'
cTemp += '<c14:style val="102"/></mc:Choice><mc:Fallback><c:style val="2"/></mc:Fallback></mc:AlternateContent>'
cTemp += '<c:chart>'
cTemp += '<c:title><c:tx><c:rich><a:bodyPr/><a:lstStyle/><a:p><a:pPr><a:defRPr/></a:pPr><a:r><a:rPr lang="pt-BR"/>'
cTemp += '<a:t>'+STR0025+'</a:t></a:r></a:p></c:rich></c:tx><c:layout/><c:overlay val="0"/></c:title>'//##Resultado
cTemp += '<c:plotArea><c:layout/><c:barChart><c:barDir val="col"/><c:grouping val="clustered"/><c:varyColors val="0"/>'

//montando as series
For nI := 3 to len(aTable[1])

	cTemp +='<c:ser><c:idx val="'+Alltrim(Str(nI-3))+'"/><c:order val="'+Alltrim(Str(nI-3))+'"/>'

	//Cabecalho da serie, com celula, id e nome
	cTemp += '<c:tx><c:strRef><c:f>Plan1!$'+Substr(cColuna,nI-1,1)+'$1</c:f><c:strCache><c:ptCount val="1"/>'
	cTemp += '<c:pt idx="0"><c:v>'+aTable[1][nI]+'</c:v></c:pt></c:strCache></c:strRef></c:tx>'


	//faixa de campos com os nomes dos grupos e id de cada grupo de amostragem
	cTemp += '<c:invertIfNegative val="0"/><c:cat><c:strRef><c:f>Plan1!$A$2:$A$'+Alltrim(Str(len(aTable)))+'</c:f>'
	cTemp += '<c:strCache><c:ptCount val="'+Alltrim(Str(len(aTable)-1))+'"/>'

	For nJ := 2 to len(aTable)

		cTemp += '<c:pt idx="'+Alltrim(Str(nJ-2))+'"><c:v>'+aTable[nJ][2]+'</c:v></c:pt>'

	Next nJ

	cTemp += '</c:strCache></c:strRef></c:cat>'

	//faixa de campos com valores de acordo com id do grupo
	cTemp+= '<c:val><c:numRef><c:f>Plan1!$'+Substr(cColuna,nI-1,1)+'$2:$'+Substr(cColuna,nI-1,1)+'$'+Alltrim(Str(len(aTable)))+'</c:f>'
	cTemp+= '<c:numCache><c:formatCode>Geral</c:formatCode><c:ptCount val="'+Alltrim(Str(len(aTable)-1))+'"/>'

	For nJ := 2 to len(aTable)

		cTemp+= '<c:pt idx="'+Alltrim(Str(nJ-2))+'"><c:v>'+cValToChar(aTable[nJ][nI])+'</c:v></c:pt>'

	Next nJ

	cTemp+= '</c:numCache></c:numRef></c:val></c:ser>'


Next nI


cTemp += '<c:dLbls><c:showLegendKey val="0"/><c:showVal val="0"/><c:showCatName val="0"/><c:showSerName val="0"/>'
cTemp += '<c:showPercent val="0"/><c:showBubbleSize val="0"/></c:dLbls><c:gapWidth val="150"/><c:axId val="41209344"/>'
cTemp += '<c:axId val="64990016"/></c:barChart><c:catAx><c:axId val="41209344"/><c:scaling><c:orientation val="minMax"/>'
cTemp += '</c:scaling><c:delete val="0"/><c:axPos val="b"/><c:majorTickMark val="out"/><c:minorTickMark val="none"/>'
cTemp += '<c:tickLblPos val="nextTo"/><c:crossAx val="64990016"/><c:crosses val="autoZero"/><c:auto val="1"/><c:lblAlgn val="ctr"/>'
cTemp += '<c:lblOffset val="100"/><c:noMultiLvlLbl val="0"/></c:catAx><c:valAx><c:axId val="64990016"/>'
cTemp += '<c:scaling><c:orientation val="minMax"/></c:scaling><c:delete val="0"/><c:axPos val="l"/><c:majorGridlines/>'
cTemp += '<c:numFmt formatCode="Geral" sourceLinked="1"/><c:majorTickMark val="out"/><c:minorTickMark val="none"/>'
cTemp += '<c:tickLblPos val="nextTo"/><c:crossAx val="41209344"/><c:crosses val="autoZero"/><c:crossBetween val="between"/>'
cTemp += '</c:valAx></c:plotArea><c:legend><c:legendPos val="r"/><c:layout/><c:overlay val="0"/></c:legend><c:plotVisOnly val="1"/>'
cTemp += '<c:dispBlanksAs val="gap"/><c:showDLblsOverMax val="0"/></c:chart><c:printSettings><c:headerFooter/>'
cTemp += '<c:pageMargins b="0.78740157499999996" l="0.511811024" r="0.511811024" t="0.78740157499999996" header="0.31496062000000002" footer="0.31496062000000002"/>'
cTemp += '<c:pageSetup/></c:printSettings></c:chartSpace>'

cArq := cPath+"\xl\charts\chart1.xml"
nHandle  := FCREATE(cArq, 0)
fWrite(nHandle, cTemp)
fClose(nHandle)


//arquivos de /xl/drawings/
MakeDir(cPath+"\xl\drawings")

/***************************************************************************************************************************
									Drawings
 ***************************************************************************************************************************/

cTemp := '<?xml version="1.0" encoding="UTF-8" standalone="yes"?>'+CRLF
cTemp += '<xdr:wsDr xmlns:xdr="http://schemas.openxmlformats.org/drawingml/2006/spreadsheetDrawing" xmlns:a="http://schemas.openxmlformats.org/drawingml/2006/main">'
cTemp += '<xdr:twoCellAnchor><xdr:from><xdr:col>6</xdr:col><xdr:colOff>466725</xdr:colOff><xdr:row>5</xdr:row><xdr:rowOff>90487</xdr:rowOff>'
cTemp += '</xdr:from><xdr:to><xdr:col>14</xdr:col><xdr:colOff>161925</xdr:colOff><xdr:row>19</xdr:row><xdr:rowOff>166687</xdr:rowOff>'
cTemp += '</xdr:to><xdr:graphicFrame macro=""><xdr:nvGraphicFramePr><xdr:cNvPr id="7" name="Grafico"/><xdr:cNvGraphicFramePr/>'
cTemp += '</xdr:nvGraphicFramePr><xdr:xfrm><a:off x="0" y="0"/><a:ext cx="0" cy="0"/></xdr:xfrm><a:graphic>'
cTemp += '<a:graphicData uri="http://schemas.openxmlformats.org/drawingml/2006/chart">'
cTemp += '<c:chart xmlns:c="http://schemas.openxmlformats.org/drawingml/2006/chart" xmlns:r="http://schemas.openxmlformats.org/officeDocument/2006/relationships" r:id="rId1"/>'
cTemp += '</a:graphicData></a:graphic></xdr:graphicFrame><xdr:clientData/></xdr:twoCellAnchor></xdr:wsDr>'

cArq := cPath+"\xl\drawings\drawing1.xml"
nHandle  := FCREATE(cArq, 0)
fWrite(nHandle, cTemp)
fClose(nHandle)


//arquivos de /xl/drawings/_rels
MakeDir(cPath+"\xl\drawings\_rels")

cTemp := '<?xml version="1.0" encoding="UTF-8" standalone="yes"?>'+CRLF
cTemp += '<Relationships xmlns="http://schemas.openxmlformats.org/package/2006/relationships">'
cTemp += '<Relationship Id="rId1" Type="http://schemas.openxmlformats.org/officeDocument/2006/relationships/chart" Target="../charts/chart1.xml"/>'
cTemp += '</Relationships>'

cArq := cPath+"\xl\drawings\_rels\drawing1.xml.rels"
nHandle  := FCREATE(cArq, 0)
fWrite(nHandle, cTemp)
fClose(nHandle)

//arquivos de /xl/theme/
MakeDir(cPath+"\xl\theme")

/***************************************************************************************************************************
									Theme
 ***************************************************************************************************************************/


cTemp := '<?xml version="1.0" encoding="UTF-8" standalone="yes"?>'+CRLF
cTemp += '<a:theme xmlns:a="http://schemas.openxmlformats.org/drawingml/2006/main" name="Tema do Office">'
cTemp += '<a:themeElements><a:clrScheme name="Escritório"><a:dk1><a:sysClr val="windowText" lastClr="000000"/>'
cTemp += '</a:dk1><a:lt1><a:sysClr val="window" lastClr="FFFFFF"/></a:lt1><a:dk2><a:srgbClr val="1F497D"/></a:dk2>'
cTemp += '<a:lt2><a:srgbClr val="EEECE1"/></a:lt2><a:accent1><a:srgbClr val="4F81BD"/></a:accent1><a:accent2><a:srgbClr val="C0504D"/></a:accent2>'
cTemp += '<a:accent3><a:srgbClr val="9BBB59"/></a:accent3><a:accent4><a:srgbClr val="8064A2"/></a:accent4><a:accent5><a:srgbClr val="4BACC6"/></a:accent5>'
cTemp += '<a:accent6><a:srgbClr val="F79646"/></a:accent6><a:hlink><a:srgbClr val="0000FF"/></a:hlink><a:folHlink><a:srgbClr val="800080"/></a:folHlink></a:clrScheme>'
cTemp += '<a:fontScheme name="Escritório"><a:majorFont><a:latin typeface="Cambria"/><a:ea typeface=""/><a:cs typeface=""/>'
cTemp += '<a:font script="Arab" typeface="Times New Roman"/><a:font script="Hebr" typeface="Times New Roman"/>'
cTemp += '<a:font script="Thai" typeface="Tahoma"/><a:font script="Ethi" typeface="Nyala"/><a:font script="Beng" typeface="Vrinda"/>'
cTemp += '<a:font script="Gujr" typeface="Shruti"/><a:font script="Khmr" typeface="MoolBoran"/><a:font script="Knda" typeface="Tunga"/>'
cTemp += '<a:font script="Guru" typeface="Raavi"/><a:font script="Cans" typeface="Euphemia"/><a:font script="Cher" typeface="Plantagenet Cherokee"/>'
cTemp += '<a:font script="Yiii" typeface="Microsoft Yi Baiti"/><a:font script="Tibt" typeface="Microsoft Himalaya"/>'
cTemp += '<a:font script="Thaa" typeface="MV Boli"/><a:font script="Deva" typeface="Mangal"/><a:font script="Telu" typeface="Gautami"/>'
cTemp += '<a:font script="Taml" typeface="Latha"/><a:font script="Syrc" typeface="Estrangelo Edessa"/><a:font script="Orya" typeface="Kalinga"/>'
cTemp += '<a:font script="Mlym" typeface="Kartika"/><a:font script="Laoo" typeface="DokChampa"/><a:font script="Sinh" typeface="Iskoola Pota"/>'
cTemp += '<a:font script="Mong" typeface="Mongolian Baiti"/><a:font script="Viet" typeface="Times New Roman"/>'
cTemp += '<a:font script="Uigh" typeface="Microsoft Uighur"/><a:font script="Geor" typeface="Sylfaen"/></a:majorFont><a:minorFont>'
cTemp += '<a:latin typeface="Calibri"/><a:ea typeface=""/><a:cs typeface=""/><a:font script="Jpan" typeface="MS P????"/>'
cTemp += '<a:font script="Hang" typeface="?? ??"/><a:font script="Hans" typeface="??"/><a:font script="Hant" typeface="????"/>'
cTemp += '<a:font script="Arab" typeface="Arial"/><a:font script="Hebr" typeface="Arial"/><a:font script="Thai" typeface="Tahoma"/>'
cTemp += '<a:font script="Ethi" typeface="Nyala"/><a:font script="Beng" typeface="Vrinda"/><a:font script="Gujr" typeface="Shruti"/>'
cTemp += '<a:font script="Khmr" typeface="DaunPenh"/><a:font script="Knda" typeface="Tunga"/><a:font script="Guru" typeface="Raavi"/>'
cTemp += '<a:font script="Cans" typeface="Euphemia"/><a:font script="Cher" typeface="Plantagenet Cherokee"/>'
cTemp += '<a:font script="Yiii" typeface="Microsoft Yi Baiti"/><a:font script="Tibt" typeface="Microsoft Himalaya"/>'
cTemp += '<a:font script="Thaa" typeface="MV Boli"/><a:font script="Deva" typeface="Mangal"/><a:font script="Telu" typeface="Gautami"/>'
cTemp += '<a:font script="Taml" typeface="Latha"/><a:font script="Syrc" typeface="Estrangelo Edessa"/><a:font script="Orya" typeface="Kalinga"/><a:font script="Mlym" typeface="Kartika"/>'
cTemp += '<a:font script="Laoo" typeface="DokChampa"/><a:font script="Sinh" typeface="Iskoola Pota"/><a:font script="Mong" typeface="Mongolian Baiti"/><a:font script="Viet" typeface="Arial"/>'
cTemp += '<a:font script="Uigh" typeface="Microsoft Uighur"/><a:font script="Geor" typeface="Sylfaen"/></a:minorFont></a:fontScheme>'
cTemp += '<a:fmtScheme name="Escritório"><a:fillStyleLst><a:solidFill><a:schemeClr val="phClr"/></a:solidFill><a:gradFill rotWithShape="1">'
cTemp += '<a:gsLst><a:gs pos="0"><a:schemeClr val="phClr"><a:tint val="50000"/><a:satMod val="300000"/></a:schemeClr></a:gs>'
cTemp += '<a:gs pos="35000"><a:schemeClr val="phClr"><a:tint val="37000"/><a:satMod val="300000"/></a:schemeClr></a:gs>'
cTemp += '<a:gs pos="100000"><a:schemeClr val="phClr"><a:tint val="15000"/><a:satMod val="350000"/></a:schemeClr></a:gs></a:gsLst>'
cTemp += '<a:lin ang="16200000" scaled="1"/></a:gradFill><a:gradFill rotWithShape="1"><a:gsLst><a:gs pos="0"><a:schemeClr val="phClr">'
cTemp += '<a:shade val="51000"/><a:satMod val="130000"/></a:schemeClr></a:gs><a:gs pos="80000"><a:schemeClr val="phClr"><a:shade val="93000"/><a:satMod val="130000"/></a:schemeClr></a:gs>'
cTemp += '<a:gs pos="100000"><a:schemeClr val="phClr"><a:shade val="94000"/><a:satMod val="135000"/></a:schemeClr></a:gs></a:gsLst>'
cTemp += '<a:lin ang="16200000" scaled="0"/></a:gradFill></a:fillStyleLst><a:lnStyleLst><a:ln w="9525" cap="flat" cmpd="sng" algn="ctr">'
cTemp += '<a:solidFill><a:schemeClr val="phClr"><a:shade val="95000"/><a:satMod val="105000"/></a:schemeClr></a:solidFill>'
cTemp += '<a:prstDash val="solid"/></a:ln><a:ln w="25400" cap="flat" cmpd="sng" algn="ctr"><a:solidFill><a:schemeClr val="phClr"/>'
cTemp += '</a:solidFill><a:prstDash val="solid"/></a:ln><a:ln w="38100" cap="flat" cmpd="sng" algn="ctr"><a:solidFill>'
cTemp += '<a:schemeClr val="phClr"/></a:solidFill><a:prstDash val="solid"/></a:ln></a:lnStyleLst><a:effectStyleLst><a:effectStyle>'
cTemp += '<a:effectLst><a:outerShdw blurRad="40000" dist="20000" dir="5400000" rotWithShape="0"><a:srgbClr val="000000">'
cTemp += '<a:alpha val="38000"/></a:srgbClr></a:outerShdw></a:effectLst></a:effectStyle><a:effectStyle><a:effectLst>'
cTemp += '<a:outerShdw blurRad="40000" dist="23000" dir="5400000" rotWithShape="0"><a:srgbClr val="000000"><a:alpha val="35000"/>'
cTemp += '</a:srgbClr></a:outerShdw></a:effectLst></a:effectStyle><a:effectStyle><a:effectLst>'
cTemp += '<a:outerShdw blurRad="40000" dist="23000" dir="5400000" rotWithShape="0"><a:srgbClr val="000000"><a:alpha val="35000"/>'
cTemp += '</a:srgbClr></a:outerShdw></a:effectLst><a:scene3d><a:camera prst="orthographicFront"><a:rot lat="0" lon="0" rev="0"/>'
cTemp += '</a:camera><a:lightRig rig="threePt" dir="t"><a:rot lat="0" lon="0" rev="1200000"/></a:lightRig></a:scene3d><a:sp3d>'
cTemp += '<a:bevelT w="63500" h="25400"/></a:sp3d></a:effectStyle></a:effectStyleLst><a:bgFillStyleLst><a:solidFill>'
cTemp += '<a:schemeClr val="phClr"/></a:solidFill><a:gradFill rotWithShape="1"><a:gsLst><a:gs pos="0"><a:schemeClr val="phClr">'
cTemp += '<a:tint val="40000"/><a:satMod val="350000"/></a:schemeClr></a:gs><a:gs pos="40000"><a:schemeClr val="phClr">'
cTemp += '<a:tint val="45000"/><a:shade val="99000"/><a:satMod val="350000"/></a:schemeClr></a:gs><a:gs pos="100000">'
cTemp += '<a:schemeClr val="phClr"><a:shade val="20000"/><a:satMod val="255000"/></a:schemeClr></a:gs></a:gsLst><a:path path="circle">'
cTemp += '<a:fillToRect l="50000" t="-80000" r="50000" b="180000"/></a:path></a:gradFill><a:gradFill rotWithShape="1"><a:gsLst>'
cTemp += '<a:gs pos="0"><a:schemeClr val="phClr"><a:tint val="80000"/><a:satMod val="300000"/></a:schemeClr></a:gs><a:gs pos="100000">'
cTemp += '<a:schemeClr val="phClr"><a:shade val="30000"/><a:satMod val="200000"/></a:schemeClr></a:gs></a:gsLst><a:path path="circle">'
cTemp += '<a:fillToRect l="50000" t="50000" r="50000" b="50000"/></a:path></a:gradFill></a:bgFillStyleLst></a:fmtScheme></a:themeElements>'
cTemp += '<a:objectDefaults/><a:extraClrSchemeLst/></a:theme>'


cArq := cPath+"\xl\theme\theme1.xml"
nHandle  := FCREATE(cArq, 0)
fWrite(nHandle, cTemp)
fClose(nHandle)

//arquivos de /xl/worksheets/
MakeDir(cPath+"\xl\worksheets")

/***************************************************************************************************************************
									WorkSheets
 ***************************************************************************************************************************/


cTemp := '<?xml version="1.0" encoding="UTF-8" standalone="yes"?>'+CRLF
cTemp += '<worksheet xmlns="http://schemas.openxmlformats.org/spreadsheetml/2006/main" xmlns:r="http://schemas.openxmlformats.org/officeDocument/2006/relationships" xmlns:mc="http://schemas.openxmlformats.org/markup-compatibility/2006" mc:Ignorable="x14ac" xmlns:x14ac="http://schemas.microsoft.com/office/spreadsheetml/2009/9/ac">'
cTemp += '<dimension ref="A1:'+SubStr(cColuna,len(aTable[1])-1,1)+Alltrim(Str(len(aTable)))+'"/>'
cTemp += '<sheetViews><sheetView tabSelected="1" workbookViewId="0"></sheetView></sheetViews>'
cTemp += '<sheetFormatPr defaultRowHeight="15" x14ac:dyDescent="0.25"/><sheetData>

//'<row r="1" spans="1:3" x14ac:dyDescent="0.25">'



For nI := 1 to Len(aTable)

   cTemp += '<row r="'+Alltrim(Str(nI))+'" >'

	For nJ := 2 to len(aTable[nI])

		//cabecalho de colunas
		If nI == 1

				If nJ > 1


					cTemp += '<c r="'+SubStr(cColuna,nJ-1,1)+Alltrim(Str(nI))+'" t="s"><v>'+Alltrim(Str(nJ-2))+'</v></c>'

				Endif
				//'<c r="B1" t="s"><v>1</v></c><c r="C1" t="s"><v>2</v></c></row>'

		Else  //series

			If nJ == 2

				cTemp += '<c r="'+SubStr(cColuna,nJ-1,1)+Alltrim(Str(nI))+'" t="s"><v>'+Alltrim(Str(len(aTable[nI])+ nI -3))+'</v></c>'

			Else

				cTemp += '<c r="'+SubStr(cColuna,nJ-1,1)+Alltrim(Str(nI))+'"><v>'+cValToChar(aTable[nI][nJ])+'</v></c>'

			Endif

		endif

	Next nJ

  	If nI > 1
		cTemp += '<c r="'+SubStr(cColuna,nJ,1)+Alltrim(Str(nI))+'" t="s"><v>'+Alltrim(Str(len(aTable) + len(aTable[nI])+ nI -4 ))+'</v></c>'
	Endif

	cTemp += '</row>'

Next nI

cTemp += '</sheetData><pageMargins left="0.511811024" right="0.511811024" top="0.78740157499999996" bottom="0.78740157499999996" header="0.31496062000000002" footer="0.31496062000000002"/>'
cTemp += '<drawing r:id="rId1"/></worksheet>'

cArq := cPath+"\xl\worksheets\sheet1.xml"
nHandle  := FCREATE(cArq, 0)
fWrite(nHandle, cTemp)
fClose(nHandle)

cTemp := '<?xml version="1.0" encoding="UTF-8" standalone="yes"?>'+CRLF
cTemp += '<worksheet xmlns="http://schemas.openxmlformats.org/spreadsheetml/2006/main" xmlns:r="http://schemas.openxmlformats.org/officeDocument/2006/relationships" xmlns:mc="http://schemas.openxmlformats.org/markup-compatibility/2006" mc:Ignorable="x14ac" xmlns:x14ac="http://schemas.microsoft.com/office/spreadsheetml/2009/9/ac"><dimension ref="A1"/><sheetViews><sheetView workbookViewId="0"/>'
cTemp += '</sheetViews><sheetFormatPr defaultRowHeight="15" x14ac:dyDescent="0.25"/><sheetData/><pageMargins left="0.511811024" right="0.511811024" top="0.78740157499999996" bottom="0.78740157499999996" header="0.31496062000000002" footer="0.31496062000000002"/>'
cTemp += '</worksheet>'

cArq := cPath+"\xl\worksheets\sheet2.xml"
nHandle  := FCREATE(cArq, 0)
fWrite(nHandle, cTemp)
fClose(nHandle)

cTemp := '<?xml version="1.0" encoding="UTF-8" standalone="yes"?>'+CRLF
cTemp += '<worksheet xmlns="http://schemas.openxmlformats.org/spreadsheetml/2006/main" xmlns:r="http://schemas.openxmlformats.org/officeDocument/2006/relationships" xmlns:mc="http://schemas.openxmlformats.org/markup-compatibility/2006" mc:Ignorable="x14ac" xmlns:x14ac="http://schemas.microsoft.com/office/spreadsheetml/2009/9/ac"><dimension ref="A1"/><sheetViews><sheetView workbookViewId="0"/></sheetViews>'
cTemp += '<sheetFormatPr defaultRowHeight="15" x14ac:dyDescent="0.25"/><sheetData/>'
cTemp += '<pageMargins left="0.511811024" right="0.511811024" top="0.78740157499999996" bottom="0.78740157499999996" header="0.31496062000000002" footer="0.31496062000000002"/>'
cTemp += '</worksheet>'



cArq := cPath+"\xl\worksheets\sheet3.xml"
nHandle  := FCREATE(cArq, 0)
fWrite(nHandle, cTemp)
fClose(nHandle)



//arquivos de /xl/worksheets/_rels
MakeDir(cPath+"\xl\worksheets\_rels")
cTemp := '<?xml version="1.0" encoding="UTF-8" standalone="yes"?>'+CRLF
cTemp += '<Relationships xmlns="http://schemas.openxmlformats.org/package/2006/relationships">'
cTemp += '<Relationship Id="rId1" Type="http://schemas.openxmlformats.org/officeDocument/2006/relationships/drawing" Target="../drawings/drawing1.xml"/>
cTemp += '</Relationships>'

cArq := cPath+"\xl\worksheets\_rels\sheet1.xml.rels"
nHandle  := FCREATE(cArq, 0)
fWrite(nHandle, cTemp)
fClose(nHandle)

cArqVBS := cPath+"NGZIP.vbs"
nHandle  := FCREATE(cArqVBS, 0) //Cria arquivo no diretório

sleep(500)
/***************************************************************************************************************************
									ZIP and OPEN
 ***************************************************************************************************************************/


cVBS += 'InputFolder = "'+cPath+'"'+CRLF
cVBS += 'CreateObject("Scripting.FileSystemObject").CreateTextFile("'+AllTrim(GetTempPath())+cNome+'.zip", True).Write "PK" & Chr(5) & Chr(6) & String(18, vbNullChar)'+CRLF
cVBS += 'Set objShell = CreateObject("Shell.Application")'+CRLF
cVBS += 'Set source = objShell.NameSpace(InputFolder).Items'+CRLF
cVBS += 'objShell.NameSpace("'+AllTrim(GetTempPath())+cNome+'.zip").CopyHere(source)'+CRLF
cVBS += 'wScript.Sleep 2000'


fWrite(nHandle, cVBS)

fClose(nHandle)


shellExecute( "Open", cArqVBS, "", "", SW_HIDE)
sleep(4000)


cPath := AllTrim(GetTempPath())+cNome

 Frename(cPath+".zip",cPath+".xlsx")

If file(cPath+".xlsx")

	ShellExecute("open", "excel", cPath+".xlsx" ,"" , SW_MAXIMIZE ) //- Microsoft Excel

Endif



Return





//---------------------------------------------------------------------
/*/{Protheus.doc} InvMarca
Inverte a marcação das perguntas

@param cMarca - Marcação
@param cAliasTRB - Alias temporário

@author Thiago Henrique dos Santos
@since 15/04/2013
@version P10

/*/
//---------------------------------------------------------------------
Static Function InvMarca(cMarca,cAliasTRB)
Local aArea := GetArea()

dbSelectArea(cAliasTRB)
(cAliasTRB)->(dbGoTop())
While !(cAliasTRB)->(Eof())
	(cAliasTRB)->TJ3_OK := IF(Empty((cAliasTRB)->TJ3_OK),cMARCA," ")
	(cAliasTRB)->(dbskip())
End

RestArea(aArea)
Return .T.
//---------------------------------------------------------------------
/*/{Protheus.doc} MDTC420VL
Validação de perguntas da consulta

@param Integer nParam: indica número do mv_par
@author André Felipe Joriatti
@since 23/09/2013
@return Boolean lRet: retorno lógico conforme avaliação da validação
@version P10

/*/
//---------------------------------------------------------------------

Function MDTC420VL( nParam )

	Local lRet := .T.

	// Executa troca de F3 dos campos de Funcionário e Responsável
	fTrocaF3420()
	Do Case

		Case nParam == 1
			lRet := NaoVazio()
		Case nParam == 2
			lRet := gpeChkData( MV_PAR01, MV_PAR02 )
		Case nParam == 3
			lRet := ExistCpo( "TJ2",MV_PAR03,1 ) .And. NaoVazio()
		Case nParam == 4
			lRet := IIF( Vazio(),.T.,ExistCpo( "TAF",MV_PAR04,8 ) )
		Case nParam == 5
			lRet := IIF( Vazio(),.T.,CTB105CC( MV_PAR05 ) )
		Case nParam == 6
			lRet := IIF( Vazio(),.T.,ExistCpo( "SRJ",MV_PAR06,1 ) )
		Case nParam == 7
			lRet := IIF( Vazio(),.T.,ExistCpo( "TN5",MV_PAR07,1 ) )
		Case nParam == 8
			lRet := IIF( Vazio(),.T.,ExistCpo( "TNE",MV_PAR08,1 ) )
		Case nParam == 9
			lRet := NaoVazio()
		Case nParam == 10
			lRet := fVldCad()
		Case nParam == 11
			lRet := NaoVazio()
		Case nParam == 12
			lRet := fVldCad()
	EndCase

Return lRet

//---------------------------------------------------------------------
/*/{Protheus.doc} fVldCad
Função para executar a troca de Consulta Padrão de MV_PAR09 e MV_PAR11
conforme o combo de seleção do tipo

@author André Felipe Joriatti
@since 23/09/2013
@return Boolean lRet: .T.
@version P10

/*/
//---------------------------------------------------------------------

Static Function fTrocaF3420()

	Local lRet    := .T.

	aTrocaF3 := {}

	// Altera F3 do Funcionário
	If MV_PAR09 == _SESMT
		aAdd( aTrocaF3,{ "MV_PAR10","TMK" } )
	ElseIf MV_PAR09 == _FUNCIONARIO
		aAdd( aTrocaF3,{ "MV_PAR10","SRA" } )
	ElseIf MV_PAR09 == _OUTROS
		aAdd( aTrocaF3,{ "MV_PAR10","QAA" } )
	EndIf

	// Altera F3 do Responsável
	If MV_PAR11 == _SESMT
		aAdd( aTrocaF3,{ "MV_PAR12","TMK" } )
	ElseIf MV_PAR11 == _FUNCIONARIO
		aAdd( aTrocaF3,{ "MV_PAR12","SRA" } )
	ElseIf MV_PAR11 == _OUTROS
		aAdd( aTrocaF3,{ "MV_PAR12","QAA" } )
	EndIf

Return lRet

//---------------------------------------------------------------------
/*/{Protheus.doc} fVldCad
Valida os parametros de funcionário e responsável do Questionário
respondido

@param Integer nTipo: indica se deve validar o funcionario ou o responsável
Sendo 1 - Funcionário, 2 - Responsável
@author André Felipe Joriatti
@since 23/09/2013
@return Boolean lRet: retorno lógico conforme avaliação da validação
@version P10

/*/
//---------------------------------------------------------------------

Static Function fVldCad()

	Local nInd        := 0
	Local cAliasVer   := ""
	Local lRet        := .T.
	Local cChave      := ""
	Local nValorValid := 0

	If ReadVar() == "MV_PAR10"
		nValorValid := MV_PAR09
		cChave      := MV_PAR10
	ElseIf ReadVar() == "MV_PAR12"
		nValorValid := MV_PAR11
		cChave      := MV_PAR12
	EndIf

	If Empty( cChave )
		Return .T.
	EndIf

	If nValorValid == _SESMT
		nInd      := 1 // TMK_FILIAL+TMK_CODUSU
		cAliasVer := "TMK"
		cChave    := PadR( cChave,TAMSX3( "TMK_CODUSU" )[1] )
	ElseIf nValorValid == _FUNCIONARIO
		nInd      := 1 // RA_FILIAL+RA_MAT
		cAliasVer := "SRA"
		cChave    := PadR( cChave,TAMSX3( "RA_MAT" )[1] )
	ElseIf nValorValid == _OUTROS
		nInd      := 1 // QAA_FILIAL+QAA_MAT
		cAliasVer := "QAA"
		cChave    := PadR( cChave,TAMSX3( "QAA_MAT" )[1] )
	EndIf

	lRet := ExistCpo( cAliasVer,cChave,nInd )

Return lRet
