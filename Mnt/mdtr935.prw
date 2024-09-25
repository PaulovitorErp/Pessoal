#INCLUDE "MDTR935.ch"
#INCLUDE "protheus.ch"
#DEFINE _nVERSAO 2 //Versao do fonte
//---------------------------------------------------------------------
/*/{Protheus.doc} MDTR935
Rotina para Impressão do Cartificado de Aprovação de Instalação.

@return

@sample
MDTR935()

@author Bruno Lobo de Souza
@since 14/06/2013
@version 1.0
/*/
//---------------------------------------------------------------------
Function MDTR935()
Local aNGBEGINPRM := NGBEGINPRM(_nVERSAO)  
//Variaveis para impressao
Local i
Local wnrel   := "MDTR935"
Local cDesc1  := STR0001 //"Certificado de Aprovação de Instalação"
Local cDesc2  := ""
Local cDesc3  := ""
Local cString := "TIH"

Private aReturn  := {STR0002, 1,STR0003, 1, 2, 1, "",1 } //"Zebrado"###"Administracao"
Private titulo   := STR0001 //"Certificado de Aprovação de Instalação"
Private ntipo    := 0
Private nLastKey := 0

Private lSigaMdtPS := If( SuperGetMv("MV_MDTPS",.F.,"N") == "S", .t. , .f. )

Private cPerg    := If(!lSigaMdtPS,"MDT935","MDT935PS  "), aPerg := {}

//Varíaveis para verificar tamanho dos campos
Private nTa1    := If((TAMSX3("A1_COD")[1]) < 1,6,(TAMSX3("A1_COD")[1]))
Private nTa1L   := If((TAMSX3("A1_LOJA")[1]) < 1,2,(TAMSX3("A1_LOJA")[1]))
Private nSizeTD := nTa1+nTa1L

/*-----------------------
//PADRÃO				|
|  De CAI ?				|
|  Até CAI ? 			|
|  Em branco ?			|
|  						|
//PRESTADOR				|
|  De Cliente ?			|
|  Até Cliente ?    	|
|  De Loja ?			|
|  Até Loja ?			|
|  De CAI ?				|
|  Até CAI ? 			|
|  Em branco ?			|
-------------------------*/

//################################################################
//# Envia controle para a funcao SETPRINT                        #
//################################################################
pergunte(cPerg,.F.)
wnrel:=SetPrint(cString,wnrel,cPerg,titulo,cDesc1,cDesc2,cDesc3,.F.,"",.T.)

If nLastKey == 27
   Set Filter to
   Return
EndIf

SetDefault(aReturn,cString)

If nLastKey == 27
   Set Filter to
   Return
EndIf

Processa({|lEnd| MDT935IMP()}) // MONTE TELA PARA ACOMPANHAMENTO DO PROCESSO.

//##############################################
//# Retorna conteudo de variaveis padroes      #
//##############################################
NGRETURNPRM(aNGBEGINPRM)
Return .T.

//---------------------------------------------------------------------
/*/{Protheus.doc} MDT935IMP
Impressão do Cartificado de Aprovação de Instalação.

@return

@sample
MDTR935()

@author Bruno Lobo de Souza
@since 14/06/2013
@version 1.0
/*/
//---------------------------------------------------------------------
Static Function MDT935IMP()
Local i, j, k,  nTotalLinhas, nLinhasMemo
Local lImp := .F.
Local nSizeTOE := If((TAMSX3("TOE_CNAE")[1]) < 1,7,(TAMSX3("TOE_CNAE")[1]))
Local aCAI := {}
Local nParBranco := If(lSigaMdtPS,MV_PAR07,MV_PAR03)

//Variaveis de conteúdo 
Local cCodCAI := "" , cDelega := ""
Local cEntDel := "" , cCNAE   := ""
Local cPerMax := "" , cQtdFun := "" 
Local cMasMai := "" , cMasMen := ""
Local cFemMai := "" , cFemMen := ""

//Variaveis do relatorio
Private oPrint935
Private Lin := 9999

//Definicao de Fontes
Private cFonte    := "Verdana"
Private oFont12	  := TFont():New(cFonte,12,12,,.F.,,,,.F.,.F.)
Private oFont12N  := TFont():New(cFonte,12,12,,.T.,,,,.F.,.F.)

//Inicializa Objeto
oPrint935 := FWMSPrinter():New(OemToAnsi(titulo))
oPrint935:SetPortrait()//Retrato
oPrint935:SetMargin(50,50,50,50)

If nParBranco == 2
	Processa({|lEnd| aCAI := MDT935INFO()})//Carrega Array com informações do CAI.
Else
	aAdd( aCAI ,{ Replicate( "_" , Len( TIH->TIH_CODCAI ) ) , Replicate( "_" , Len( TIE->TIE_NOME ) ) , Replicate( "_" , Len( TIE->TIE_ENTDEL ) ) ,;
				  Replicate( "_" , Len( TIH->TIH_CNAE ) ) , " " , " " , " " , " " , " " , " " , " "  })
EndIf

For i := 1 To Len( aCAI )
	lImp := .T.
	//Carrega os campos
	cCodCAI := aCAI[i,1]
	cDelega := aCAI[i,2]
	cEntDel := aCAI[i,3]
	cCNAE   := aCAI[i,4]
	cPerMax := cValToChar(aCAI[i,5])
	cQtdFun := cValToChar(aCAI[i,6])
	cMasMai := cValToChar(aCAI[i,7])
	cMasMen := cValToChar(aCAI[i,8])
	cFemMai := cValToChar(aCAI[i,9])
	cFemMen := cValToChar(aCAI[i,10])
	cMemo	:= STR0020 + " " //"Descrição das Instalações e dos Equipamentos (Deverá ser feita obedecendo ao disposto nas NR 8, 11, 12, 13, 14, 15"
	cMemo	+= STR0021 + CRLF + CRLF //"(anexos), 17, 19, 20, 23, 24, 25 e 26) (Use o verso e anexe outras folhas se necessário)" 
	cMemo   += MSMM(aCAI[i,11],,,,3,,,"TIH","TIH_MMSYP")
	
	//Inicio da Mensagem
	Somalinha()
	oPrint935:Say(Lin,100,STR0022,oFont12N)//"MINISTÉRIO DO TRABALHO"
	Somalinha()
	oPrint935:Say(Lin,100,STR0023,oFont12N)//"SECRETARIA DE MEDICINA E SEGURANÇA DO TRABALHO"
	Somalinha()
	oPrint935:Say(Lin,100,STR0024 + " " + cDelega,oFont12N)//"DELEGACIA"
	Somalinha(2)
	oPrint935:Say(Lin,100,STR0025,oFont12)//"CERTIFICADO DE APROVAÇÃO DE INSPEÇÕES"
	Somalinha()
	oPrint935:Say(Lin,100,STR0026 + " " + cCodCAI ,oFont12)//"CAI nº"
	Somalinha(2)
	
	//Corpo da mensagem
	If "DTM" $ cEntDel
		cTEXTO := STR0060 + ", "
	Else
		cTEXTO := STR0027 + ", "
	EndIf
	cTEXTO += STR0028 + " "
	cTEXTO += Alltrim(cEntDel) + " "
	cTEXTO += STR0029 + " "
	cTEXTO += Alltrim(SM0->M0_NOME) + " "
	cTEXTO += STR0030 + " "
	cTEXTO += Alltrim(SM0->M0_ENDENT) + ", "
	cTEXTO += STR0031 + " "
	cTEXTO += Alltrim(SM0->M0_CIDENT) + " "
	cTEXTO += STR0032 + " "
	cTEXTO += Alltrim(cCNAE) + " "
	cTEXTO += STR0033 + " "
	cTEXTO += Alltrim(cPerMax) + " "
	cTEXTO += STR0034 + " "
	cTEXTO += STR0035 + " "
	cTEXTO += STR0036 + " "
	cTEXTO += STR0037
	j := 1
	nTotalLinhas := MlCount( cTEXTO , 90 )
	While j <= nTotalLinhas
		If j <> 1
   			SomaLinha()
		EndIf
		cString := MemoLine( cTEXTO, 90, j )
		oPrint935:Say(Lin,100, cString ,oFont12)

		j++
	End
	Somalinha(3)
	oPrint935:Say(Lin , 100  , "Nova inspeção deverá ser requerida, nos termos do § 1° do citado art. 160 da CLT, quando" + " " , oFont12)
	SomaLinha()
	oPrint935:Say(Lin , 100  , "ocorrer modificação substancial nas instalações e/ou nos equipamentos de seu(s) estabelecimento(s)." , oFont12)
	SomaLinha(3)
	oPrint935:Line( Lin , 200  , lin , 900  , 0 , "-4" )
	oPrint935:Line( Lin , 1100 , lin , 1650 , 0 , "-4" )
	SomaLinha()
	oPrint935:Say(Lin , 200  , STR0038 , oFont12)
	oPrint935:Say(Lin , 1100 , STR0039 , oFont12)
	SomaLinha()
	oPrint935:Say(Lin , 200  , STR0040 , oFont12)
	oPrint935:Say(Lin , 1100 , STR0041 , oFont12)
	
	SomaLinha(1,.T.)//Inicia nova pagina
	     
	oPrint935:SayAlign( Lin ,100, STR0042 ,oFont12N, 2100, 100, 0, 2, 1)
	
	//Conteudo Box 1
	SomaLinha(4)
	oPrint935:Box( Lin  , 100 , 1350 , 2100 , "-4" )
	SomaLinha()
	oPrint935:Say( Lin , 170  , "1-" , oFont12 )
	oPrint935:Say( Lin , 220  , STR0043 + ".......: " + Alltrim(SM0->M0_NOME) , oFont12 )
	SomaLinha()
	oPrint935:Say( Lin , 220  , STR0044 + "................: " + Alltrim(SM0->M0_CGC) , oFont12 )
	SomaLinha()
	oPrint935:Say( Lin , 220  , STR0045 + "...........: " + Alltrim(SM0->M0_CIDENT) + ", " + Alltrim(SM0->M0_ENDENT) , oFont12 )
	oPrint935:Say( Lin , 1320 , STR0046 + ": " + Alltrim(SM0->M0_CEPENT) , oFont12 )
	oPrint935:Say( Lin , 1720 , STR0047 + ": " + Alltrim(SM0->M0_TEL) , oFont12 )
	SomaLinha()
	oPrint935:Say( Lin , 220  , STR0048 + ": " + Alltrim(cCNAE) , oFont12 )
	SomaLinha(2)
	oPrint935:Say( Lin , 220  , STR0049 , oFont12 )
	oPrint935:Say( Lin , 800  , "- " + STR0050 + ":" , oFont12 )
	oPrint935:Say( Lin , 1070 , STR0051 + ": " + cMasMai , oFont12 )
	SomaLinha()
	oPrint935:Say( Lin , 1070 , STR0052 + ": " + cMasMen , oFont12 )
	SomaLinha(2)
	oPrint935:Say( Lin , 800  , "- " + STR0053 + ".:" , oFont12 )
	oPrint935:Say( Lin , 1070 , STR0051 + ": " + cFemMai , oFont12 )
	SomaLinha()
	oPrint935:Say( Lin , 1070 , STR0052 + ": " + cFemMen , oFont12 )
	Lin := 1350
	//Conteudo Box 2
	SomaLinha(2)
	nLinhasMemo := MlCount( cMemo , 80 )
	SomaLinha()
	k := 1
	nLinSav := 200
	nFimBox := 0
	While k <= nLinhasMemo
		//Determina um limite para o fim do box.
		If k <> 1
   			SomaLinha(,,2850)
		EndIf
		If k == 1 .Or. nLinSav == Lin
			nLinComp := nLinhasMemo
			If k <> 1
				nLinComp := nLinhasMemo - k
			EndIf
			//Caso seja primeira linha o e o conteúdo
			//não ultrapasse 500 pixels fecha o Box em 1950.
			If k == 1
				nFimBox := If( nLinComp*50 < 500, 1950, ( (nLinComp*50)+ 50 + Lin ) )
			Else
				nFimBox := (nLinComp*50)+250
			EndIf
			//Determina o fim do Box caso total de linhas,
			//ultrapasse a 500 pixels que é o padrão.
			If !( nLinComp*50 < 500 )
				If ( nFimBox + Lin ) > 2900
					nFimBox := 2900
				EndIf
			EndIf
			oPrint935:Box( Lin - 50 , 100 , nFimBox , 2100 , "-4" )
		EndIf
		cStrMemo := MemoLine( cMemo, 80, k )
		If k == 1
			oPrint935:Say( Lin , 170 , "2-"  , oFont12 )
		EndIf
		oPrint935:Say( Lin , 220 , cStrMemo , oFont12 )

		k++
	End
	If nFimBox <= 0
		nFimBox := If( nLinhasMemo*50 < 500, 1950, (nLinhasMemo*50)+50)
	EndIf
	Lin := nFimBox
	
	//Conteudo Box 3
	SomaLinha(2)
	oPrint935:Box( Lin , 100 , Lin + 300, 2100 , "-4" )
	SomaLinha()
	oPrint935:Say( Lin , 170 , "3-" , oFont12 )
	oPrint935:Say( Lin , 220 , STR0056 + ": " + DtoC(dDataBase), oFont12 )
	SomaLinha(2)
	oPrint935:Line( Lin , 240  , lin , 1300  , 0 , "-4" )
	SomaLinha()
	oPrint935:Say( Lin , 220 , STR0057 , oFont12 )
	If i < Len(aCAI)
		SomaLinha(1,.T.)
	EndIf
Next i

If lImp
	oPrint935:EndPage()
	//Imprime na Tela ou Impressora
	If aReturn[5] == 1
		oPrint935:Preview()
	Else
		oPrint935:Print()
	EndIf
Else
	MsgStop(STR0058,STR0059)//"Não existem dados para montar o relatório."##"Atenção"
Endif
MS_FLUSH()

Return
//---------------------------------------------------------------------
/*/{Protheus.doc} MDT935INFO
Monta o array de informações do CAI.

@return

@sample
MDT935INFO()

@author Bruno Lobo de Souza
@since 14/06/2013
@version 1.0
/*/
//---------------------------------------------------------------------
Static Function MDT935INFO()
Local aArray  := {}
Local cIniCai := If(lSigaMdtps,MV_PAR05,MV_PAR01)
Local cFimCai := If(lSigaMdtps,MV_PAR06,MV_PAR02)

dbSelectArea("TIH")
dbSetOrder(1)
dbSeek(xFilial("TIH") + Alltrim(cIniCai))
While !Eof() .And. xFilial("TIH") == TIH->TIH_FILIAL .And. TIH->TIH_CODCAI  >= cIniCai .And. TIH->TIH_CODCAI <= cFimCai
	cDescDeleg := NGSEEK("TIE",TIH->TIH_CODDEL,1,"TIE_NOME")
	cEntDeleg  := NGSEEK("TIE",TIH->TIH_CODDEL,1,"TIE_ENTDEL")
	Aadd(aArray,{ TIH->TIH_CODCAI , cDescDeleg , cEntDeleg , TIH->TIH_CNAE , TIH->TIH_PERMAX ,;
				  TIH->TIH_QTDFUN , TIH->TIH_MASMAI , TIH->TIH_MASMEN , TIH->TIH_FEMMAI , TIH->TIH_FEMMEN ,;
				  TIH->TIH_MMSYP })
	dbSelectArea("TIH")
	dbSkip()
End

Return aArray

//---------------------------------------------------------------------
/*/{Protheus.doc} Somalinha
Realiza salto de linha.

@return

@sample
Somalinha()

@author Bruno Lobo de Souza
@since 14/06/2013
@version 1.0
/*/
//---------------------------------------------------------------------
Static Function Somalinha( nQtdLin , lEndPage , nLimite )

Local nLin := 50

Default nQtdLin := 1
Default lEndPage := .F.
Default nLimite := 2950

nLin := nLin * nQtdLin
Lin += nLin
If lin > nLimite .Or. lEndPage
	//Finaliza a pagina e inicia uma nova.
	oPrint935:EndPage()
	oPrint935:StartPage()
	lin := 200
EndIf

Return .T.