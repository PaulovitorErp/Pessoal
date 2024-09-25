#Include 'MDTA057.ch'
#Include 'Protheus.ch'

#DEFINE _nVERSAO 2 //Versao do fonte

//---------------------------------------------------------------------
/*/{Protheus.doc} MDTA056
Questionário de Produto QUimico

@author Taina Alberto Cardoso
@since 22/04/13
@version MP11
@return Nil
/*/
//---------------------------------------------------------------------
Function MDTA057()

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Guarda conteudo e declara variaveis padroes ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	Local aNGBEGINPRM := NGBEGINPRM(_nVERSAO)
	Local oTempTable
	
	Private aRotina := MenuDef()
	PRIVATE cCadastro  := STR0001 //"Respostas Questionário Produto Quimico"
	Private cPrograma := "MDTA057"
	Private oFont10  := TFont():New("Arial",,-10,.T.,.T.)
	Private oFont12  := TFont():New("Arial",,-12,.T.,.T.)
	Private oFont14  := TFont():New("Arial",,-14,.T.,.T.)
	Private oFont16  := TFont():New("Arial",,-16,.T.,.T.)
	Private aSize := MsAdvSize(,.f.,430) , aObjects := {}
	
	Private aVETINR := {}
	
	
	If !AliasInDic("TID")
		If !NGINCOMPDIC("UPDMDT78","THFTE6",.T.)
	  		Return .F.
		EndIf
	EndIf
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Endereca a funcao de BROWSE                                  ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	
	aDBFB := {}
	Aadd(aDBFB,{"TID_CODIGO"   ,"C", 06,0})
	Aadd(aDBFB,{"TID_DESCRI"   ,"C", 30,0})
	Aadd(aDBFB,{"TID_DTINI"    ,"D", 08,0})
	
	oTempTable := FWTemporaryTable():New( "TRBB", aDBFB )
	oTempTable:AddIndex( "1", {"TID_CODIGO","TID_DTINI"} )
	oTempTable:Create()
	
	aTRBB := {{STR0007,"TID_CODIGO" ,"C",09,0,"@!"},;   //"Codigo"
	          {STR0008,"TID_DESCRI" ,"C",30,0,"@!" },;  //"Descrição"
	          {STR0009,"TID_DTINI"  ,"D",08,0,"@!" }}   //Data
	          
	Processa({ |lEnd| MDT057INI() },STR0010)  // "Aguarde ..Processando"
	
	DbSelectarea("TRBB")
	dbSetOrder(1)
	DbGotop()
	mBrowse(6,1,22,75,"TRBB",aTRBB)
	oTempTable:Delete()
		
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Retorna conteudo de variaveis padroes       ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	NGRETURNPRM(aNGBEGINPRM)


Return

//---------------------------------------------------------------------
/*/{Protheus.doc} MenuDef


@author Taina Alberto Cardoso
@since 22/04/13
@version MP11
@return Nil
/*/
//---------------------------------------------------------------------
Static Function MenuDef()

Local aRotina := {{STR0006,"AxPesqui",0,1},;  //"Pesquisar"
                  {STR0002,"MDT057INC" ,0,2},; //"Visualizar"
                  {STR0003,"MDT057INC" ,0,3},; //"Incluir"
                  {STR0004,"MDT057INC" ,0,4},; //"Alterar"
                  {STR0005,"MDT057INC" ,0,5,3}} //"Excluir"
Return(aRotina)

//---------------------------------------------------------------------
/*/{Protheus.doc} MDTA056
Inclusao de Respostas do Questionário de Produto QUimico

@author Taina Alberto Cardoso
@since 22/04/13
@version MP11
@return Nil
/*/
//---------------------------------------------------------------------
Function MDT057INC(cAlias,nReg,nOpcx)

	Local oDlgPar, oDlgResp, oPnlPai
	Local cCodigo := "", cProduto := ""
	Local nOpTemp := 0, nSize := 0
	Local i, nContro := 1
	Local cGrupo := ""
	local lVisual    := if( cValToChar( nOpcx ) $ "25",.t.,.f. )
	Local lTrocaTit := .F. 
	
	Private nLinObj    := 0, nOldMemo := 0
	Private aDados := {}
	Private nLinLarg   := 020
	Private nLargura := aSize[5]
	Private nAltura  := aSize[6]
	
	// declaração de objetos da rotina
	Private oScroll
	Private oMemoResp
	
	aInfo := {aSize[1],aSize[2],aSize[3],aSize[4],0,0}
	aAdd(aObjects,{200,200,.t.,.f.})
	aPosObj := MsObjSize(aInfo, aObjects,.t.)
	
	
	
	If nOpcx == 3
		
		RegToMemory("TID",.T.)
		
		DEFINE MSDIALOG oDlgPar TITLE OemToAnsi(cCadastro) From 0,0 To 170,450 OF oMainWnd PIXEL
		oDlgPar:LESCCLOSE := .f.
	
		//Panel criado para correta disposicao da tela
		oPnlPai := TPanel():New( , , , oDlgPar , , , , , , , , .F. , .F. )
			oPnlPai:Align := CONTROL_ALIGN_ALLCLIENT
	
	
			@ 4, 012 SAY oS_DtExa Prompt STR0009 PIXEL OF oPnlPai Font oFont12  //"Data"
			@ 4, 085 MSGET oG_DtExa VAR M->TID_DTINI SIZE 60,9 VALID f057Data(M->TID_DTINI) PIXEL OF oPnlPai HasButton
			@ 18, 012 SAY oS_TpExa Prompt STR0011 PIXEL OF oPnlPai Font oFont12  //"Código do Questionário"
			@ 18, 085 MSGET oG_TpExa VAR M->TID_CODIGO SIZE 60,8 VALID ExistCpo('TIB',M->TID_CODIGO) F3 "TIB" PIXEL OF oPnlPai HasButton
	
		ACTIVATE MSDIALOG oDlgPar ON INIT EnchoiceBar(oDlgPar,{|| f057Data(M->TID_DTINI) ,nOpTemp := 1, oDlgPar:End() },;
															  {|| nOpTemp := 2,oDlgPar:End()}) CENTERED
	Else
		nOpTemp := 1
	EndIf
	
	
	//Monta a Tela do Questinário
	If nOpTemp == 1 
		If INCLUI
			dbSelectArea("TIB")
			dbSetOrder(1)
			If dbSeek(xFIlial("TIB")+M->TID_CODIGO)
				cCodigo  := TIB->TIB_CODIGO
				cDesc    := TIB->TIB_DESCRI
				cProduto := Alltrim(TIB->TIB_CODPRO) + " - " + Alltrim(NGSEEK("SB1",TIB->TIB_CODPRO,1,"SB1->B1_DESC"))
				dDataIni := M->TID_DTINI 
				dbSelectArea("TIC")
				dbSetOrder(1)
				If dbSeek(xFilial("TIC")+cCodigo)
					While !Eof() .And. TIC->TIC_FILIAL == xFilial("TIC") .And. TIC->TIC_CODIGO == cCodigo
						//1 - Codigo, 2 - Produto, 3 - Grupo, 4 - Ordem, 5 - Pergunta, 6 - Tipo, 7 - Obrigaatorio , 8 - Resposta, 9 - Produto
						aAdd(aDados,{cCodigo,cProduto,TIC->TIC_CODGRU,TIC->TIC_ORDEM,TIC->TIC_PERG,TIC->TIC_TIPO,TIC->TIC_OBRIG,"",TIB->TIB_CODPRO})
						dbSelectArea("TIC")
						dbSkip()
					End
				EndIf
			EndIf
		Else
			dbSelectArea("TID")
			dbSetOrder(1)
			If dbSeek(xFilial("TID")+TRBB->TID_CODIGO+DtoS(TRBB->TID_DTINI))
				While !Eof() .And. TID->TID_FILIAL == xFilial("TID") .And. TID->TID_CODIGO == TRBB->TID_CODIGO ;
					.And. TID->TID_DTINI ==  TRBB->TID_DTINI
					
					
					//Busca as informacoes de Tipo e Obrigario
					dbSelectArea("TIC")
					dbSetOrder(1)
					dbSeek(xFilial("TIC")+TID->TID_CODIGO+TID->TID_CODGRU+TID->TID_ORDEM)
					//1 - Codigo, 2 - Produto, 3 - Grupo, 4 - Ordem, 5 - Pergunta, 6 - Tipo, 7 - Obrigaatorio , 8 - Resposta, 9 - Produto
					aAdd(aDados,{TID->TID_CODIGO,TID->TID_CODPRO,TID->TID_CODGRU,TID->TID_ORDEM,TID->TID_PERG,;
						TIC->TIC_TIPO,TIC->TIC_OBRIG ,MSMM( TID->TID_RESP ) ,TID->TID_CODPRO} )
						
					cCodigo  := TID->TID_CODIGO
					cDesc    := Alltrim(NgSeek("TIB",TID->TID_CODIGO,1,"TIB->TIB_DESCRI"))
					cProduto := Alltrim(TID->TID_CODPRO) + " - " + Alltrim(NGSEEK("SB1",TID->TID_CODPRO,1,"SB1->B1_DESC"))
					dDataIni := TID->TID_DTINI
				
					dbSelectArea("TID")	
					dbSkip()
				End
			EndIf
		EndIf
		
		//Ordena o Array pelo grupo e Ordem
		ASORT(aDados,,,{|x,y| x[3]+x[4] < y[3]+y[4] })
		
		nLinObj := 2
		
		DEFINE MSDIALOG oDlgResp TITLE OemToAnsi(cCadastro) From 0,0 To aSize[6],aSize[5] OF oMainWnd PIXEL
			
			oScroll := TScrollBox():New( oDlgResp,50,000,,,.t.,,.t. )
		   	oScroll:Align := CONTROL_ALIGN_ALLCLIENT
			
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³Titulo do Grupo                                ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			oPanelTmp := TPaintPanel():new(nLinObj-1,-4,aPosObj[1,4]+5,14,oScroll)
			oPanelTmp:addShape("id=2;type=1;left=0;top=0;width="+Alltrim(Str(aPosObj[1,4]*2.2,5))+";height=28;"+;
		                "gradient=1,0,-15,0,40,0.4,#C3DBF9,0.9,#83AAE2,0.0,#FFF6FF;pen-width=0;"+;
		                "pen-color=#B0C4DE;can-move=0;can-mark=0;is-blinker=1;")
			@ 2, 11 SAY oGrpNome Prompt "Questionario - "+cDesc PIXEL OF oPanelTmp Font oFont16 COLOR RGB(67,70,87)
			@ 2, 300 SAY oGrpNome Prompt "Produto "+ cProduto PIXEL OF oPanelTmp Font oFont16 COLOR RGB(67,70,87)
			
			nLinObj += 20
			i := 0
			For i := 1 to len(aDados)
				nLinObj := If(nLinObj > nOldMemo,nLinObj,nOldMemo)
				
				//Imprime o Titulo do Grupo
	 			If Empty(cGrupo) .Or. cGrupo <> aDados[i][3]	 				
	 				nLinObj += 20
	 				oSay := TSay():New( nLinObj,010,,oScroll,,oFont14,,,,.t.,RGB( 0,57,106 ),,200,010 )
					oSay:SetText( Alltrim(aDados[i][3]) + " - " + Alltrim(NGSEEK("TK0",aDados[i][3] ,1,"TK0->TK0_DESCRI")  ))
					If cGrupo <> aDados[i][3] .And. !Empty(cGrupo)
						lTrocaTit := .T.
						If Mod(nContro,2) == 0
							nContro ++
						EndIf
					EndIf
					cGrupo := aDados[i][3] 
	 			EndIf

				//Verifica se deve ser impresso na primeira coluna ou na segunda.
				If Mod(nContro,2) <> 0 .Or. lTrocaTit
	 				nLinLarg := 020
	 				nOldPos  := If(nLinObj > nOldMemo,nLinObj,nOldMemo)
	 				nLinObj  := If(nLinObj > nOldMemo,nLinObj,nOldMemo)
	 				lTrocaTit := .F.
	 			Else
	 				nLinLarg := 270
	 				nLinObj  := nOldPos 	 				
	 			EndIf
	 			nLinObj += 10
	 			//Imprime o Titulo da Pergunta
	 			If aDados[i][7] == "2"
	 				cTextHtml := "<font style='color: #FF0000; font-weight: bold;'>*</font>"	
	 			Else
	 				cTextHtml := ""
	 			EndIf
	 			oSay := TSay():New( nLinObj,nLinLarg,,oScroll,,oFont10,,,,.t.,RGB( 67,70,87 ),,200,010,,,,,,.T. )
				oSay:SetText( Alltrim(aDados[i][5]) + "  " + cTextHtml )
				nLinObj += 8
				//Verifica se tipo ComboBox ou Texto
				If aDados[i][6] == "1"
					nSize := 200
					If INCLUI
						aDados[i][8] :=  Space(80)
					Else
						aDados[i][8] := aDados[i][8] + Space(80-Len(aDados[i][8])) 
					EndIf
					oGet := TGet():New( nLinObj,nLinLarg,&( "{ |u| if( Pcount() > 0,aDados["+cValToChar( i ) +"][8] := u,aDados[" + cValToChar( i ) + "][8] ) }" ),oScroll,nSize,009,"@!",{ ||  },CLR_BLACK,,,,,.t.,,,,,,,,,,,,,,,, )
					oGet:bWhen := { || !lVisual }
					nLinObj += 10
				Else
					nSize := 200
					oMemoResp := TMultiget():New( nLinObj,nLinLarg,&( "{ |u| if( Pcount() > 0,aDados["+cValToChar( i ) +"][8] := u,aDados[" + cValToChar( i ) + "][8] ) }" ),oScroll,nSize,25,,,,,,.T. ,,,,,,,,{ ||  })
					oMemoResp:EnableHScroll( .t. )
					oMemoResp:EnableVScroll( .t. )
					oMemoResp:bWhen := { || !lVisual }
					nLinObj += 30
					nOldMemo := nLinObj
	 			EndIf
	 			nContro++ 
	 		Next i
			
		ACTIVATE MSDIALOG oDlgResp ON INIT EnchoiceBar(oDlgResp,{|| If(f057TudoOk(nOpcx), oDlgResp:End(),oDlgResp:End()) },;
															  {|| oDlgResp:End()}) CENTERED
	
	EndIf

Return

//---------------------------------------------------------------------
/*/{Protheus.doc} MDTA056
Valida a data de inclusao da resposta do Questionario

@author Taina Alberto Cardoso
@since 22/04/13
@version MP11
@return Nil
/*/
//---------------------------------------------------------------------
Static Function f057Data(dTMI_DTREAL)

If dTMI_DTREAL > dDataBase
	Help(" ",1,"NGATENCAO",,STR0012,3,1)  //"A data do questionário não pode ser maior que a data atual."
	Return .F.
Endif
If !NaoVazio(dTMI_DTREAL)
	Return .F.
Endif

Return .T.

//---------------------------------------------------------------------
/*/{Protheus.doc} MDTA056
Valida a data de inclusao da resposta do Questionario

@author Taina Alberto Cardoso
@since 22/04/13
@version MP11
@return Nil
/*/
//---------------------------------------------------------------------
Function f057TudoOk(nOpcx)

	Local nX := 0
	
	//Verifica se os campos obrigatorios foram preenchidos
	For nX := 1 to Len(aDados)
		If aDados[nX][7] == "2" .And. Empty(aDados[nX][8])
			Help(" ",1,"OBRIGAT")
			Return .F.
		EndIf
	Next nX
	
	//Grava as respostas do Questionario
	If INCLUI .Or. ALTERA
		For nX := 1 to Len(aDados)
			dbSelectArea("TID")
			dbSetOrder(1)
			If !dbSeek(xFilial("TID")+aDados[nX][1]+DtoS(dDataIni)+aDados[nX][3]+aDados[nX][4])				
				RecLock("TID",.T.)
				TID->TID_FILIAL := xFilial("TID")
				TID->TID_CODIGO := aDados[nX][1]
				TID->TID_DTINI  := M->TID_DTINI
				TID->TID_CODGRU := aDados[nX][3]
				TID->TID_ORDEM  := aDados[nX][4]
				TID->TID_PERG   := aDados[nX][5]
				TID->TID_RESP   := aDados[nX][8]
				TID->TID_CODPRO := aDados[nX][9]
				TID->TID_RESP   := MSMM( ,TAMSX3( "TID_RESMV" )[1],,aDados[nX][8],1,,,"TID","TID_RESP" )
				MsUnlock("TID")
			Else
				RecLock("TID",.F.)
				MSMM( TID->TID_RESP,TAMSX3( "TID_RESMV" )[1],,aDados[nX][8],1,,,"TID","TID_RESP" )
				MsUnlock("TID")
			EndIf
		Next nX
	ElseIf nOpcx == 5
		//Deleta as Respostas do Questionário
		For nX := 1 to Len(aDados)
			dbSelectArea("TID")
			dbSetOrder(1)
			If dbSeek(xFilial("TID")+aDados[nX][1]+DtoS(dDataIni)+aDados[nX][3]+aDados[nX][4])
				//Delete Memo
				DbSelectArea( "SYP" )
				DbSeek( xFilial( "SYP" ) + TID->TID_RESP )
				While !EoF() .And. SYP->( YP_FILIAL + YP_CHAVE ) == ( xFilial( "SYP" ) + TID->TID_RESP )
					RecLock( "SYP",.f. )
					DbDelete()
					MsUnLock( "SYP" )
					DbSelectArea( "SYP" )
					DbSkip()
				EndDo
				RecLock("TID",.F.)
				DbDelete()
				MsUnLock("TID")
			EndIf
		Next nX
	EndIf
	
	MDT057INI(.T.)
	

Return .T.


//---------------------------------------------------------------------
/*/{Protheus.doc} MDT057INI
Filtra as Resposta do Questinario Quimico TID

@author Taina Alberto Cardoso
@since 24/04/13
@version MP11
@return Nil
/*/
//---------------------------------------------------------------------
Function MDT057INI(lAltera)

Local cQuery 
Local cTabTID := RetSqlName("TID")

Private cAliasTID := GetNextAlias()
If lAltera
	Dbselectarea("TRBB")
	Zap
EndIf

cQuery := "Select TID_CODIGO,TID_DTINI"
cQuery += " From " + cTabTID + " "
cQuery += "WHERE TID_FILIAL = '" + xFilial("TID") + "' AND "	
cQuery += " D_E_L_E_T_ != '*' " 
cQuery += "Group by TID_CODIGO,TID_DTINI"

cQuery := ChangeQuery(cQuery)
MPSysOpenQuery( cQuery , cAliasTID )

dbSelectArea(cAliasTID)
dbgoTop()
While !Eof()

	Dbselectarea("TRBB")
	Dbgotop()
	If !Dbseek( (cAliasTID)->TID_CODIGO+(cAliasTID)->TID_DTINI)
		RecLock("TRBB",.t.)
		TRBB->TID_CODIGO := (cAliasTID)->TID_CODIGO
		TRBB->TID_DTINI := StoD((cAliasTID)->TID_DTINI)
		TRBB->TID_DESCRI := NGSEEK("TIB",(cAliasTID)->TID_CODIGO,1,"TIB->TIB_DESCRI")
		Msunlock("TRBB")		
	Endif			
    	
	dbSelectArea(cAliasTID)
	dbSkip()
End
(cAliasTID)->(dbCloseArea())
Dbselectarea("TRBB")

lREFRESH := .T.

Return .T.