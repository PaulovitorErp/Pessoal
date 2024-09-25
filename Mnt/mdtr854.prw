#INCLUDE "Mdtr854.ch"
#INCLUDE "Protheus.ch"
#INCLUDE "MSOLE.ch"

//---------------------------------------------------------------------
/*/{Protheus.doc} MDTR854

Relatorio GERAL do PPR
Este programa emite relatorio do Laudo do PPR

@author Bruno L. Souza
@since 02/04/2013
@version MP11
@return Nil
/*/
//---------------------------------------------------------------------
Function MDTR854()

	Local aNGBEGINPRM := NGBEGINPRM( )//Armazena variaveis p/ devolucao (NGRIGHTCLICK)

	Private nTipoDoc := 1 //Indica que o documento é o PPR
	Private cPathEst := Alltrim(GetMv("MV_DIREST")) // PATH DO ARQUIVO A SER ARMAZENADO NA ESTACAO DE TRABALHOZ
	Private cFiltroF := Alltrim(SuperGetMv("MV_NGCATFU",.F.," "))
	Private cCodEmpresa := FWGrpCompany()

	If FindFunction( 'MDTChkTJ7' )

		If MDTChkTJ7() // Verifica o tamanho do campo TJ7_CODIGO
			If SuperGetMv( "MV_NG2NR32", .F., "2" ) <> "1"
				MsgStop( STR0130, STR0131 )//"Parâmetro 'MV_NG2NR32' deve estar habilitado (1=Sim) para que seja impresso o relatório."//"MV_NG2NR32 desabilitado"
			Else
				MDTREL854()
			EndIf
		EndIf
	Else
		MsgStop( STR0137 ) //"Seu ambiente encontra-se desatualizado ou com inconsistências no campo Código (TJ7_CODIGO) da tabela de Serviços (TJ7). Favor atualizar o ambiente."
	EndIf

	NGRETURNPRM( aNGBEGINPRM ) //Devolve variaveis armazenadas (NGRIGHTCLICK)

Return Nil

//---------------------------------------------------------------------
/*/{Protheus.doc} MDTREL854

Funcao de Impressao do PPR

@author Bruno L. Souza
@since 02/04/2013
@version MP11
@return Nil
/*/
//---------------------------------------------------------------------
Function MDTREL854()

Local oRadOp,oDLGPPR,i
Private cPathBmp      := Alltrim(GetMv("MV_DIRACA"))// Path do arquivo logo .bmp do cliente
Private lSigaMdtPS    := If( SuperGetMv("MV_MDTPS",.F.,"N") == "S", .T. , .F. )
Private nModeloImp    := 1
Private cCliMdtPs     := " "
Private aFuncionarios := {}
Private aFuncRisco    := {}
Private nFuncRisco    := 0
Private lMdtUmCC      := lMDT190UMCC()
Private nSizeSI3      := If((TAMSX3("I3_CUSTO")[1]) < 1,9,(TAMSX3("I3_CUSTO")[1]))
Private nSizeCli      := If((TAMSX3("A1_COD")[1]) < 1,6,(TAMSX3("A1_COD")[1]))
Private nSizeLoj      := If((TAMSX3("A1_LOJA")[1]) < 1,2,(TAMSX3("A1_LOJA")[1]))
Private cAliasCC      := "SI3"
Private cDescrCC      := "SI3->I3_DESC"
Private aNfrisco      := {}
Private lMdtUnix      := If( GetRemoteType() == 2 .or. isSRVunix() , .T. , .F. ) //Verifica se servidor ou estacao é Linux
Private titulo        := " "
Private nQtdFunT      := 0
Private lImpTodos	    := .T.
Private aVETINR       := {} //Usado pela funcao que cria arq. temporario
Private cFiltroF      := Alltrim(SuperGetMv("MV_NGCATFU",.F.," "))
Private dDeLaudo      := "", dAteLaudo := ""
Private aImagens      := {}
Private lCabec854     := .F.
Private aTipoInsc     := {}

aTipoInsc := fTipoINSC()
If Empty(aTipoInsc[1])
	aTipoInsc[1] := "C.G.C."//"C.G.C."
EndIf
cPathEst 	:= Alltrim(GetMv("MV_DIREST"))// PATH DO ARQUIVO A SER ARMAZENADO NA ESTACAO DE TRABALHOZ
titulo		:= STR0001

//Campos da tela
Private cCli_O := Space(Len(SA1->A1_COD))
Private cLoj_O := Space(Len(SA1->A1_LOJA))
Private cNom_O := Space(Len(SA1->A1_NOME))

If Alltrim(GETMV("MV_MCONTAB")) == "CTB"
	cAliasCC := "CTT"
	cDescrCC := "CTT->CTT_DESC01"
Endif

lRet  := .F.

DEFINE MSDIALOG oDLGPPR FROM  0,0 TO 150,320 TITLE STR0002 PIXEL //"Selecione o Modelo do Relatório"

@ 10,10 TO 55,150 LABEL STR0003 of oDLGPPR Pixel //"Modelo do Relatório"
@ 20,14 RADIO oRadOp VAR nModeloImp ITEMS "Word",STR0004,STR0005 SIZE 70,15 PIXEL OF oDLGPPR //"Padrão" //"Gráfico"

DEFINE SBUTTON FROM 59,90  TYPE 1 ENABLE OF oDLGPPR ACTION EVAL({|| lRET := .T.,oDLGPPR:END()})
DEFINE SBUTTON FROM 59,120 TYPE 2 ENABLE OF oDLGPPR ACTION oDLGPPR:END()

ACTIVATE MSDIALOG oDLGPPR CENTERED

If lRet
	If nModeloImp == 1
		fMDT854WOR()
	Else
		MDT854PADR()
	Endif
Endif

For i:=1 to Len(aImagens)
	If File(aImagens[i][1]+"JPG")
		Ferase(aImagens[i][1]+"JPG") //Apaga imagem extraida do repositorio
	Endif
	If File(aImagens[i][1]+"BMP")
		Ferase(aImagens[i][1]+"BMP") //Apaga imagem extraida do repositorio
	Endif
Next i

Return Nil

//---------------------------------------------------------------------
/*/{Protheus.doc} MDT854PADR

Relatorio padrao do PPR

@author Bruno L. Souza
@since 02/04/2013
@version MP11
@return Nil
/*/
//---------------------------------------------------------------------
Function MDT854PADR()

Local wnrel   := "MDTR854"
Local cString := "TO0"
Local cF3CC   := "MDTPS4"  //SI3 apenas do cliente
Local cDesc1  := STR0001+" - PPR" //"Programa de Proteção Radiológica"
Local cDesc2  := STR0006 //"Atraves dos parametros selecionar os itens que devem ser considerados"
Local cDesc3  := STR0007 //"no Relatorio.

If Alltrim(GETMV("MV_MCONTAB")) == "CTB"
	cF3CC := "MDTPS6"  //CTT apenas do cliente
Endif

Private nomeprog := "MDTR854"
Private tamanho  := "M"
Private aReturn  := { STR0008, 1,STR0009, 1, 2, 1, "",1 } //### //"Zebrado"###"Administracao"
Private ntipo    := 0
Private nLastKey := 0
Private cPerg    := Padr( "MDTR854", 10 )
Private cabec1, cabec2

pergunte(cPerg,.F.)//Verifica as perguntas selecionadas
wnrel:=SetPrint(cString,wnrel,cPerg,titulo,cDesc1,cDesc2,cDesc3,.F.,"")//Envia controle para a funcao SETPRINT

If nLastKey == 27
	Set Filter to
	Return
Endif

SetDefault(aReturn,cString)

If nLastKey == 27
	Set Filter to
	Return
EndIf
If !lSigaMdtps
	dbSelectArea("TO0")
	dbSetOrder(1)
	dbSeek(xFilial("TO0")+mv_par01)
	dDeLaudo := TO0->TO0_DTINIC
	If	!Empty(TO0->TO0_DTFIM)
		dAteLaudo := TO0->TO0_DTFIM
	Else
		dAteLaudo := dDatabase
	EndIf
Else
	cCliMdtps := Mv_par01+Mv_par02
Endif

If nModeloImp == 2
	nQtdFunT := fQtdFunRis() //Retorna quantidade de funcionarios expostos a riscos
	RptStatus({|lEnd| R854Imp(@lEnd,wnRel,titulo,tamanho)},titulo)
Else
	nQtdFunT := fQtdFunRis() //Retorna quantidade de funcionarios expostos a riscos
	RptStatus({|lEnd| R854Grf(@lEnd,wnRel,titulo,tamanho)},titulo)
Endif

Return NIL

//---------------------------------------------------------------------
/*/{Protheus.doc} R854Imp

Chamada do Relatório padão

@author Bruno L. Souza
@since 02/04/2013
@version MP11
@return Nil
/*/
//---------------------------------------------------------------------
Static Function R854Imp(lEnd,wnRel,titulo,tamanho)

Local cMemo := " ",cTitulo := " ",cTexto := " "
Local lEof  := .T.
Local nX
Local nLenMemo := 0
Local nPerMemo := 0
Local cEmp, cFil

Private lPrint   := .T.
Private lPrin2   := .T.
Private lFirst   := .T.
Private lJumpCab := .T.
Private lIdentar := .F.
Private aRiscos  := {}
Private aEpis    := {}
Private aExames  := {}

//Contadores de linha e pagina
Private li := 80 ,m_pag := 1

//Verifica se deve comprimir ou nao
nTipo  := IIF(aReturn[4]==1,15,18)

cabec1 := " "
cabec2 := " "

If lSigaMdtps

	dbSelectArea("SA1")
	dbSetOrder(1)
	dbSeek(xFilial("SA1")+cCliMdtps)

	dbSelectArea("TO0")
	dbSetOrder(6)  //cli + loj + laudo
	dbSeek(xFilial("TO0")+cCliMdtps+mv_par03)

	cCidade   := Capital(Alltrim(SA1->A1_MUN))+If(!Empty(SA1->A1_EST),"-"+SA1->A1_EST," ")
	cCidadeRe := Capital(Alltrim(SA1->A1_MUN))
	cEmp_Nome := SA1->A1_NOME
	cEmp_Cnpj := SA1->A1_CGC
	cEmp_Endr := SA1->A1_END
	cEmp_Bair := SA1->A1_BAIRRO
	cEmp_Insc := SA1->A1_INSCR
	cEmp_Cnae := SA1->A1_ATIVIDA
	cNum_Func := Alltrim(Str(If(nQtdFunT==0,TO0->TO0_QTDFUN,nQtdFunT),9))

	SomaLinha()
	SomaLinha()
	SomaLinha()
	SomaLinha()
	@ LI,000 PSay "                                        "+UPPER(STR0001)+" - PPR"
	Somalinha()
	Somalinha()
	Somalinha()
	@ Li,000 Psay STR0014+" "+cEmp_Nome //"NOME DA EMPRESA :"
	SomaLinha()
	@ Li,000 Psay STR0015+" "+cEmp_Endr //"ENDERECO :"
	SomaLinha()
	@ Li,000 Psay STR0016+" "+cCidade //"CIDADE :"
	SomaLinha()
	@ Li,000 Psay STR0017+" "+cEmp_Bair //"BAIRRO : "
	SomaLinha()
	@ Li,000 Psay STR0021+" "+cNum_Func //"Nº de Funcionários:"
	SomaLinha()
	@ Li,000 Psay aTipoInsc[1]+" "+aTipoInsc[2] //"CNPJ :"## ou ##"CGC :"
	SomaLinha()
	@ Li,000 Psay STR0018+" "+cEmp_Insc //"INSCRIÇÃO ESTADUAL : "
	Somalinha()
	SomaLinha()
	SomaLinha()

	cMemo := Alltrim(TO0->TO0_DESCRI)
	If NGCADICBASE("TO0_MMSYP2","A","TO0",.F.)
		If !Empty(TO0->TO0_MMSYP2)
			cMMSYP2 := MSMM(TO0->TO0_MMSYP2,80)
			If !Empty(cMMSYP2)
				If !Empty(cMemo)
					cMemo += Chr(13)+Chr(10)
				Endif
				cMemo += cMMSYP2
			Endif
		Endif
	ElseIf NGCADICBASE("TO0_DESC2","A","TO0",.F.)
		If !Empty(TO0->TO0_DESC2)
			If !Empty(cMemo)
				cMemo += Chr(13)+Chr(10)
			Endif
			cMemo += Alltrim(TO0->TO0_DESC2)
		Endif
	Endif

	SetRegua(100)
	nLenMemo := Len(cMemo)
	nPerMemo := 0

	While lEof

		If Empty(cMemo) //Memo vazio
			lEof := .F.
			Exit
		Else
			nPos1 := At("#",cMemo) //Inicio de um Titulo

			If nPos1 > 1
				cTexto := Alltrim(Substr(cMemo,1,nPos1-1))
				cMemo  := Alltrim(Substr(cMemo,nPos1))
				IMPDOC854(Alltrim(cTexto))
				fReguaPPR( nLenMemo, @nPerMemo, Len(cMemo) ) //Incrementa Regua
				Loop
			ElseIf nPos1 == 1 //Existe #
				cMemo   := Alltrim(Substr(cMemo,nPos1+1))
				nPos1   := At("#",cMemo)
				cTitulo := Alltrim(Substr(cMemo,1,nPos1-1))
				cMemo   := Alltrim(Substr(cMemo,nPos1+1))

				nPos1   := At("#",cMemo)
				If nPos1 > 0
					cTexto := Alltrim(Substr(cMemo,1,nPos1-1))
					cMemo  := Alltrim(Substr(cMemo,nPos1))
				Else
					cTexto := Alltrim(cMemo)
					cMemo  := " "
					lEof   := .F.
				Endif
			Else //Nao existe #
				//IMPRIME TEXTO
				IMPDOC854(Alltrim(cMemo))
				lEof := .F.
				Exit
			Endif

			//IMPRIME TITULO
			If !Empty(cTitulo)
				IMPHEA854(cTitulo)
			Endif

			//IMPRIME TEXTO
			If !Empty(cTexto)
				lPrint := .T.
				lPrin2 := .T.
				IMPDOC854(Alltrim(cTexto))
			Endif

		Endif

		fReguaPPR( nLenMemo, @nPerMemo, Len(cMemo) ) //Incrementa Regua
	End

	cTxtMemo := " "
	dbSelectArea("TMZ")
	dbSetOrder(1)
	IF dbSeek(xFilial("TMZ")+TO0->TO0_TERMO)
		cTxtMemo := TMZ->TMZ_DESCRI
	Endif

	dbSelectArea("TMK")
	dbSetOrder(1)
	dbSeek(xFilial("TMK")+Mv_par04)

	If Li != 6 //Se o cursor estiver na primeira linha nao eh necessario criar uma nova pagina
		li := 80
		Somalinha()
	Endif

	@li,048 Psay STR0023 //"RESPONSÁVEIS TÉCNICOS"
	For nX := 1 to 3
		Somalinha()
	Next nX

	IMPDOC854(Alltrim(cTxtMemo))
	Somalinha()
	Somalinha()
	Somalinha()
	@li,000 Psay (STR0024+" "+Alltrim(TMK->TMK_NOMUSU)) //"COORDENADOR:"

	Somalinha()
	@li,000 Psay (STR0025+" "+Alltrim(TMK->TMK_REGMTB)) //"REG.SSST:"

	If !Empty(TMK->TMK_NUMENT)
  		Somalinha()
  		@li,000 Psay (If(Empty(TMK->TMK_ENTCLA),"",Alltrim(TMK->TMK_ENTCLA)+": ")+Alltrim(TMK->TMK_NUMENT))
	EndIf

	Somalinha()
	@li,000 Psay (STR0026+": "+Alltrim(TMK->TMK_TELUSU)) //"FONE:"

	Somalinha()
	@li,000 Psay (STR0015+" "+Alltrim(TMK->TMK_ENDUSU)) //"ENDEREÇO:"

	dbSelectArea("TMK")
	dbSetOrder(1)
	dbSeek(xFilial("TMK")+TO0->TO0_CODUSU)

	SomaLinha()
	SomaLinha()
	@li,000 Psay (STR0027+" "+ Alltrim(TMK->TMK_NOMUSU)) //"RESPONSÁVEL: "

	If !Empty(TMK->TMK_NUMENT)
  		Somalinha()
  		@li,000 Psay (If(Empty(TMK->TMK_ENTCLA),"",Alltrim(TMK->TMK_ENTCLA)+": ")+Alltrim(TMK->TMK_NUMENT))
	EndIf

	Somalinha()
	@li,000 Psay (STR0026+": "+Alltrim(TMK->TMK_TELUSU)) //"FONE:"

	Somalinha()
	@li,000 Psay (STR0015+" "+Alltrim(TMK->TMK_ENDUSU)) //"ENDEREÇO:"

	For nX := 1 to 3
		Somalinha()
	Next nX
	@li,000 Psay cCidadeRe+", "+StrZero(Day(dDataBase),2)+STR0028+MesExtenso(dDataBase)+STR0028+; //" de "###" de "
				StrZero(Year(dDataBase),4)+"."
	For nX := 1 to 5
		Somalinha()
	Next nX
	@li,000 Psay (STR0030+"___________________________________________")  //"Ass.: "

Else
    cEmp := FWGrpCompany()
    cFil := FWCodFil()
	dbSelectArea("TO0")
	dbSetOrder(1)
	dbSeek(xFilial("TO0")+Mv_par01)

	dbSelectArea("SM0")
	dbSetOrder(1)
	dbSeek(cEmp+cFil)

	cCidade   := Alltrim(SM0->M0_CIDCOB)+If(!Empty(SM0->M0_ESTCOB),"-"+SM0->M0_ESTCOB," ")
	cCidadeRe := Capital(Alltrim(SM0->M0_CIDCOB))
	cEmp_Nome := SM0->M0_NOMECOM
	cEmp_Cnpj := aTipoInsc[2]//SM0->M0_CGC
	cEmp_Endr := SM0->M0_ENDCOB
	cEmp_Bair := SM0->M0_BAIRCOB
	cEmp_Insc := SM0->M0_INSC
	cEmp_Cnae := SM0->M0_CNAE
	cNum_Func := Alltrim(Str(If(nQtdFunT==0,TO0->TO0_QTDFUN,nQtdFunT),9))

	SomaLinha()
	SomaLinha()
	SomaLinha()
	SomaLinha()
	@ LI,000 PSay "                                        "+UPPER(STR0001)+" - PPR"
	Somalinha()
	Somalinha()
	Somalinha()
	@ Li,000 Psay STR0014+" "+cEmp_Nome //"NOME DA EMPRESA :"
	SomaLinha()
	@ Li,000 Psay STR0015+" "+cEmp_Endr //"ENDERECO :"
	SomaLinha()
	@ Li,000 Psay STR0016+" "+cCidade //"CIDADE :"
	SomaLinha()
	@ Li,000 Psay STR0017+" "+cEmp_Bair //"BAIRRO : "
	SomaLinha()
	@ Li,000 Psay STR0021+" "+cNum_Func //"Nº de Funcionários:"
	SomaLinha()
	@ Li,000 Psay aTipoInsc[1]+" "+cEmp_Cnpj //"CNPJ :"## ou ##"CGC :"
	SomaLinha()
	@ Li,000 Psay STR0018+" "+cEmp_Insc //"INSCRIÇÃO ESTADUAL : "
	Somalinha()
	SomaLinha()
	SomaLinha()

	cMemo := Alltrim(TO0->TO0_DESCRI)
	If NGCADICBASE("TO0_MMSYP2","A","TO0",.F.)
		If !Empty(TO0->TO0_MMSYP2)
			cMMSYP2 := MSMM(TO0->TO0_MMSYP2,80)
			If !Empty(cMMSYP2)
				If !Empty(cMemo)
					cMemo += Chr(13)+Chr(10)
				Endif
				cMemo += cMMSYP2
			Endif
		Endif
	ElseIf NGCADICBASE("TO0_DESC2","A","TO0",.F.)
		If !Empty(TO0->TO0_DESC2)
			If !Empty(cMemo)
				cMemo += Chr(13)+Chr(10)
			Endif
			cMemo += Alltrim(TO0->TO0_DESC2)
		Endif
	Endif

	SetRegua(100)
	nLenMemo := Len(cMemo)
	nPerMemo := 0

	While lEof
		If Empty(cMemo)  //Memo vazio
			lEof := .F.
			Exit
		Else
			nPos1 := At("#",cMemo) //Inicio de um Titulo

			If nPos1 > 1
				cTexto := Alltrim(Substr(cMemo,1,nPos1-1))
				cMemo  := Alltrim(Substr(cMemo,nPos1))
				IMPDOC854(Alltrim(cTexto))
				fReguaPPR( nLenMemo, @nPerMemo, Len(cMemo) ) //Incrementa Regua
				Loop
			ElseIf nPos1 == 1 //Existe #
				cMemo   := Alltrim(Substr(cMemo,nPos1+1))
				nPos1   := At("#",cMemo)
				cTitulo := Alltrim(Substr(cMemo,1,nPos1-1))
				cMemo   := Alltrim(Substr(cMemo,nPos1+1))

				nPos1   := At("#",cMemo)
				If nPos1 > 0
					cTexto := Alltrim(Substr(cMemo,1,nPos1-1))
					cMemo  := Alltrim(Substr(cMemo,nPos1))
				Else
					cTexto := Alltrim(cMemo)
					cMemo  := " "
					lEof   := .F.
				Endif
			Else //Nao existe #
				//IMPRIME TEXTO
				IMPDOC854(Alltrim(cMemo))
				lEof := .F.
				Exit
			Endif

			//IMPRIME TITULO
			If !Empty(cTitulo)
				IMPHEA854(cTitulo)
			Endif

			//IMPRIME TEXTO
			If !Empty(cTexto)
				lPrint := .T.
				lPrin2 := .T.
				IMPDOC854(Alltrim(cTexto))
			Endif

		Endif
		fReguaPPR( nLenMemo, @nPerMemo, Len(cMemo) ) //Incrementa Regua
	End

	cTxtMemo := " "
	dbSelectArea("TMZ")
	dbSetOrder(1)
	IF dbSeek(xFilial("TMZ")+TO0->TO0_TERMO)
		cTxtMemo := TMZ->TMZ_DESCRI
	Endif

	dbSelectArea("TMK")
	dbSetOrder(1)
	dbSeek(xFilial("TMK")+Mv_par02)

	If Li != 6 //Se o cursor estiver na primeira linha nao eh necessario criar uma nova pagina
		li := 80
		Somalinha()
	Endif

	@li,048 Psay STR0023 //"RESPONSÁVEIS TÉCNICOS"
	For nX := 1 to 3
		Somalinha()
	Next nX

	IMPDOC854(Alltrim(cTxtMemo))
	Somalinha()
	Somalinha()
	Somalinha()
	@li,000 Psay (STR0024+" "+Alltrim(TMK->TMK_NOMUSU)) //"COORDENADOR:"

	Somalinha()
	@li,000 Psay (STR0025+" "+Alltrim(TMK->TMK_REGMTB)) //"REG.SSST:"

	If !Empty(TMK->TMK_NUMENT)
		Somalinha()
		@li,000 Psay (If(Empty(TMK->TMK_ENTCLA),"",Alltrim(TMK->TMK_ENTCLA)+": ")+Alltrim(TMK->TMK_NUMENT))
	End If

	Somalinha()
	@li,000 Psay (STR0026+": "+Alltrim(TMK->TMK_TELUSU)) //"FONE:"

	Somalinha()
	@li,000 Psay (STR0015+" "+Alltrim(TMK->TMK_ENDUSU)) //"ENDEREÇO:"

	dbSelectArea("TMK")
	dbSetOrder(1)
	dbSeek(xFilial("TMK")+TO0->TO0_CODUSU)

	SomaLinha()
	SomaLinha()
	@li,000 Psay (STR0027+" "+ Alltrim(TMK->TMK_NOMUSU))  //"RESPONSÁVEL: "

	If !Empty(TMK->TMK_NUMENT)
		Somalinha()
		@li,000 Psay (If(Empty(TMK->TMK_ENTCLA),"",Alltrim(TMK->TMK_ENTCLA)+": ")+Alltrim(TMK->TMK_NUMENT))
	End If

	Somalinha()
	@li,000 Psay (STR0026+": "+Alltrim(TMK->TMK_TELUSU)) //"FONE:"

	Somalinha()
	@li,000 Psay (STR0015+" "+Alltrim(TMK->TMK_ENDUSU)) //"ENDEREÇO:"

	For nX := 1 to 3
		Somalinha()
	Next nX
	@li,000 Psay cCidadeRe+", "+StrZero(Day(dDataBase),2)+STR0028+MesExtenso(dDataBase)+STR0028+; //" de "###" de "
				StrZero(Year(dDataBase),4)+"."

	For nX := 1 to 5
		Somalinha()
	Next nX

	@li,000 Psay (STR0030+"___________________________________________")  //"Ass.: "

Endif

//################################################################
//## Devolve a condicao original do arquivo principal           ##
//################################################################
RetIndex("TO0")
Set Filter To
Set device to Screen
If aReturn[5] = 1
	Set Printer To
	dbCommitAll()
	OurSpool(wnrel)
Endif
MS_FLUSH()

Return NIL

//---------------------------------------------------------------------
/*/{Protheus.doc} R854Grf

Chamada do Relatório grafico

@author Bruno L. Souza
@since 02/04/2013
@version MP11
@return Nil
/*/
//---------------------------------------------------------------------
Static Function R854Grf(lEnd,wnRel,titulo,tamanho)

Local cMemo := " ",cTitulo := " ",cTexto := " "
Local lEof  := .T.
Local nLenMemo := 0
Local nPerMemo := 0
Local cSMCOD   := FWGrpCompany()
Local cSMFIL   := FWCodFil()

Private lPrint   := .T.
Private lPrin2   := .T.
Private lFirst   := .T.
Private lJumpCab := .T.
Private lIdentar := .F.
Private aRiscos  := {}
Private aEpis    := {}
Private aExames  := {}
Private nPaginaG := 0

Private oFont08	  := TFont():New("Verdana",08,08,,.F.,,,,.F.,.F.)
Private oFont08b  := TFont():New("Verdana",08,08,,.T.,,,,.F.,.F.)
Private oFont10b  := TFont():New("Verdana",10,10,,.T.,,,,.F.,.F.)
Private oFont10	  := TFont():New("Verdana",10,10,,.F.,,,,.F.,.F.)
Private oFont12b  := TFont():New("Verdana",12,12,,.T.,,,,.F.,.F.)
Private oFont12   := TFont():New("Verdana",12,12,,.F.,,,,.F.,.F.)
Private oFont12bs := TFont():New("Verdana",12,12,,.T.,,,,.T.,.T.)
Private oFont12s  := TFont():New("Verdana",12,12,,.F.,,,,.T.,.T.)
Private oFont28b  := TFont():New("Verdana",28,28,,.T.,,,,.F.,.F.)
Private oFont50b  := TFont():New("Verdana",50,50,,.T.,,,,.F.,.F.)

oPrintPPR := TMSPrinter():New(OemToAnsi(UPPER(STR0001)+" - PPR"))
oPrintPPR:Setup()
oPrintPPR:SetPortrait() // Seta Retrato como padrão

//Contadores de linha e pagina
Private lin := 9999 ,m_pag := 1

//Caminho do logoppp.bmp
Private cStartDir := AllTrim(GetSrvProfString("StartPath","\"))
Private cStartLogo := " "
If lSigaMdtPS
	If File(cStartDir+"LGRL"+cCliMdtPs+".BMP")
		cStartLogo := cStartDir+"LGRL"+cCliMdtPs+".BMP"
	ElseIf File(cStartDir+"LGRL"+Substr(cCliMdtPs,1,nSizeCli)+".BMP")
		cStartLogo := cStartDir+"LGRL"+Substr(cCliMdtPs,1,nSizeCli)+".BMP"
	Endif
Else
	If File(cStartDir+"LGRL"+cSMCOD+cSMFIL+".BMP")
		cStartLogo := cStartDir+"LGRL"+cSMCOD+cSMFIL+".BMP"
	ElseIf File(cStartDir+"LGRL"+cSMCOD+".BMP")
		cStartLogo := cStartDir+"LGRL"+cSMCOD+".BMP"
	Endif
Endif

//Verifica se deve comprimir ou nao
nTipo  := IIF(aReturn[4]==1,15,18)

cabec1 := " "
cabec2 := " "

If lSigaMdtps

	dbSelectArea("SA1")
	dbSetOrder(1)
	dbSeek(xFilial("SA1")+cCliMdtps)

	dbSelectArea("TO0")
	dbSetOrder(6)  //cli + loj + laudo
	dbSeek(xFilial("TO0")+cCliMdtps+mv_par03)

	cCidade   := Capital(Alltrim(SA1->A1_MUN))+If(!Empty(SA1->A1_EST),"-"+SA1->A1_EST," ")
	cCidadeRe := Capital(Alltrim(SA1->A1_MUN))
	cEmp_Nome := SA1->A1_NOME
	cEmp_Cnpj := SA1->A1_CGC
	cEmp_Endr := SA1->A1_END
	cEmp_Bair := SA1->A1_BAIRRO
	cEmp_Insc := SA1->A1_INSCR
	cEmp_Cnae := SA1->A1_ATIVIDA
	cNum_Func := Alltrim(Str(If(nQtdFunT==0,TO0->TO0_QTDFUN,nQtdFunT),9))

    cTitPPR := " "
	cTitPPR := STR0001 //"Programa de Gerenciamento de Riscos"

	SomaLinha(150)
	oPrintPPR:Say(700,1000,"PPR",oFont50b)
	oPrintPPR:Say(1200,400,MemoLine(cTitPPR,30,1),oFont28b)
	oPrintPPR:Say(1400,980,MemoLine(cTitPPR,30,2),oFont28b)

	oPrintPPR:Say(2340,150,STR0031,oFont12b) //"EMPRESA"
	oPrintPPR:Say(2340,600,cEmp_Nome,oFont12)
	oPrintPPR:Say(2420,150,aTipoInsc[1]+":",oFont12b) //"CGC :" ## ou ## "CNPJ :"
	oPrintPPR:Say(2420,600,cEmp_Cnpj,oFont12)
	oPrintPPR:Say(2500,150,STR0016,oFont12b) //"CIDADE"
	oPrintPPR:Say(2500,600,cCidade,oFont12)

	lin := 9999 //Forçar quebra de pagina
	Somalinha(150)
	oPrintPPR:Say(lin,150,"1. "+STR0032,oFont12b) //"IDENTIFICAÇÃO DA EMPRESA"
	Somalinha(80)
	oPrintPPR:Say(lin,150,STR0033+":",oFont10b) //"Razão Social"
	oPrintPPR:Say(lin,600,cEmp_Nome,oFont10)
	SomaLinha()
	oPrintPPR:Say(lin,150,aTipoInsc[1]+":",oFont10b) //"CNPJ :"
	oPrintPPR:Say(lin,600,cEmp_Cnpj,oFont10)
	SomaLinha()
	oPrintPPR:Say(lin,150,STR0018,oFont10b) //"Inscrição Estadual"
	oPrintPPR:Say(lin,600,cEmp_Insc,oFont10)
	SomaLinha()
	oPrintPPR:Say(lin,150,STR0015,oFont10b) //"Endereço"
	oPrintPPR:Say(lin,600,cEmp_Endr,oFont10)
	SomaLinha()
	oPrintPPR:Say(lin,150,STR0017,oFont10b) //"Bairro"
	oPrintPPR:Say(lin,600,cEmp_Bair,oFont10)
	SomaLinha()
	oPrintPPR:Say(lin,150,STR0021,oFont10b) //"Nº de Funcionários:"
	oPrintPPR:Say(lin,600,cNum_Func,oFont10)
	SomaLinha()
	oPrintPPR:Say(lin,150,STR0016,oFont10b) //"Cidade"
	oPrintPPR:Say(lin,600,cCidade,oFont10)
	Somalinha(160)

	cMemo := Alltrim(TO0->TO0_DESCRI)
	If NGCADICBASE("TO0_MMSYP2","A","TO0",.F.)
		If !Empty(TO0->TO0_MMSYP2)
			cMMSYP2 := MSMM(TO0->TO0_MMSYP2,80)
			If !Empty(cMMSYP2)
				If !Empty(cMemo)
					cMemo += Chr(13)+Chr(10)
				Endif
				cMemo += cMMSYP2
			Endif
		Endif
	ElseIf NGCADICBASE("TO0_DESC2","A","TO0",.F.)
		If !Empty(TO0->TO0_DESC2)
			If !Empty(cMemo)
				cMemo += Chr(13)+Chr(10)
			Endif
			cMemo += Alltrim(TO0->TO0_DESC2)
		Endif
	Endif

	SetRegua(100)
	nLenMemo := Len(cMemo)
	nPerMemo := 0

	While lEof
		If Empty(cMemo)  //Memo vazio
			lEof := .F.
			Exit
		Else
			nPos1 := At("#",cMemo) //Inicio de um Titulo

			If nPos1 > 1
				cTexto := Alltrim(Substr(cMemo,1,nPos1-1))
				cMemo  := Alltrim(Substr(cMemo,nPos1))
				IMPDOC854(Alltrim(cTexto))
				fReguaPPR( nLenMemo, @nPerMemo, Len(cMemo) ) //Incrementa Regua
				Loop
			ElseIf nPos1 == 1 //Existe #
				cMemo   := Alltrim(Substr(cMemo,nPos1+1))
				nPos1   := At("#",cMemo)
				cTitulo := Alltrim(Substr(cMemo,1,nPos1-1))
				cMemo   := Alltrim(Substr(cMemo,nPos1+1))

				nPos1   := At("#",cMemo)
				If nPos1 > 0
					cTexto := Alltrim(Substr(cMemo,1,nPos1-1))
					cMemo  := Alltrim(Substr(cMemo,nPos1))
				Else
					cTexto := Alltrim(cMemo)
					cMemo  := " "
					lEof   := .F.
				Endif
			Else //Nao existe #
				//IMPRIME TEXTO
				IMPDOC854(Alltrim(cMemo))
				lEof := .F.
				Exit
			Endif

			//IMPRIME TITULO
			If !Empty(cTitulo)
				IMPHEA854(cTitulo)
			Endif

			//IMPRIME TEXTO
			If !Empty(cTexto)
				lPrint := .T.
				lPrin2 := .T.
				IMPDOC854(Alltrim(cTexto))
			Endif

		Endif

		fReguaPPR( nLenMemo, @nPerMemo, Len(cMemo) ) //Incrementa Regua

	End

	cTxtMemo := " "
	dbSelectArea("TMZ")
	dbSetOrder(1)
	IF dbSeek(xFilial("TMZ")+TO0->TO0_TERMO)
		cTxtMemo := TMZ->TMZ_DESCRI
	Endif

	dbSelectArea("TMK")
	dbSetOrder(1)
	dbSeek(xFilial("TMK")+Mv_par04)

	If Lin != 300 //Se o cursor estiver na primeira linha nao eh necessario criar uma nova pagina
		Lin := 9999
		Somalinha()
	Endif

	oPrintPPR:Say(lin,1000,STR0023,oFont12b) //"RESPONSÁVEIS TÉCNICOS"

	Somalinha(180)
	IMPDOC854(Alltrim(cTxtMemo))

	Somalinha(180)
	oPrintPPR:Say(lin,100,STR0024,oFont12b) //"COORDENADOR:"
	oPrintPPR:Say(lin,600,Alltrim(TMK->TMK_NOMUSU),oFont12)

	Somalinha()
	oPrintPPR:Say(lin,100,STR0025,oFont12b) //"REG.SSST:"
	oPrintPPR:Say(lin,600,Alltrim(TMK->TMK_REGMTB),oFont12)

	If !Empty(TMK->TMK_NUMENT)
		Somalinha()
		oPrintPPR:Say(lin,100,If(Empty(TMK->TMK_ENTCLA),"",Alltrim(TMK->TMK_ENTCLA)+": "),oFont12b)
		oPrintPPR:Say(lin,600,Alltrim(TMK->TMK_NUMENT),oFont12)
	End If

	Somalinha()
	oPrintPPR:Say(lin,100,STR0026+": ",oFont12b) //"FONE:"
	oPrintPPR:Say(lin,600,Alltrim(TMK->TMK_TELUSU),oFont12)

	Somalinha()
	oPrintPPR:Say(lin,100,STR0015+" ",oFont12b) //"ENDEREÇO:"
	oPrintPPR:Say(lin,600,Alltrim(TMK->TMK_ENDUSU),oFont12)

	dbSelectArea("TMK")
	dbSetOrder(1)
	dbSeek(xFilial("TMK")+TO0->TO0_CODUSU)

	SomaLinha(120)
	oPrintPPR:Say(lin,100,STR0027+" ",oFont12b) //"RESPONSÁVEL: "
	oPrintPPR:Say(lin,600,Alltrim(TMK->TMK_NOMUSU),oFont12)

	If !Empty(TMK->TMK_NUMENT)
		Somalinha()
		oPrintPPR:Say(lin,100,If(Empty(TMK->TMK_ENTCLA),"",Alltrim(TMK->TMK_ENTCLA)+": "),oFont12b)
		oPrintPPR:Say(lin,600,Alltrim(TMK->TMK_NUMENT),oFont12)
	End If

	Somalinha()
	oPrintPPR:Say(lin,100,STR0026+": ",oFont12b) //"FONE: "
	oPrintPPR:Say(lin,600,Alltrim(TMK->TMK_TELUSU),oFont12)

	Somalinha()
	oPrintPPR:Say(lin,100,"ENDEREÇO:",oFont12b) //"ENDEREÇO:"
	oPrintPPR:Say(lin,600,Alltrim(TMK->TMK_ENDUSU),oFont12)

	Somalinha(180)
	cTxtTmp := cCidadeRe+", "+StrZero(Day(dDataBase),2)+STR0028+MesExtenso(dDataBase)+STR0028+StrZero(Year(dDataBase),4)+"." //" de "###" de "
	oPrintPPR:Say(lin,100,cTxtTmp,oFont12b)

	Somalinha(300)
	oPrintPPR:Say(lin,100,STR0030+"___________________________________________",oFont12) //"Ass.: "

Else
	cEmp := FWGrpCompany()
    cFil := FWCodFil()
	dbSelectArea("TO0")
	dbSetOrder(1)
	dbSeek(xFilial("TO0")+Mv_par01)

	dbSelectArea("SM0")
	dbSetOrder(1)
	dbSeek(cSMCOD+cSMFIL)

	cCidade   := Alltrim(SM0->M0_CIDCOB)+If(!Empty(SM0->M0_ESTCOB),"-"+SM0->M0_ESTCOB," ")
	cCidadeRe := Capital(Alltrim(SM0->M0_CIDCOB))
	cEmp_Nome := SM0->M0_NOMECOM
	cEmp_Cnpj := aTipoInsc[2]//SM0->M0_CGC
	cEmp_Endr := SM0->M0_ENDCOB
	cEmp_Bair := SM0->M0_BAIRCOB
	cEmp_Insc := SM0->M0_INSC
	cEmp_Cnae := SM0->M0_CNAE
	cNum_Func := Alltrim(Str(If(nQtdFunT==0,TO0->TO0_QTDFUN,nQtdFunT),9))

    cTitPPR := " "
	cTitPPR := STR0001
	SomaLinha(150)
	oPrintPPR:Say(700,1000,"PPR",oFont50b)
	oPrintPPR:Say(1200,400,MemoLine(cTitPPR,30,1),oFont28b)
	oPrintPPR:Say(1400,980,MemoLine(cTitPPR,30,2),oFont28b)

	oPrintPPR:Say(2340,150,STR0031,oFont12b) //"EMPRESA"
	oPrintPPR:Say(2340,600,cEmp_Nome,oFont12)
	oPrintPPR:Say(2420,150,aTipoInsc[1]+" ",oFont12b) //"CGC :" ## ou ## "CNPJ :"
	oPrintPPR:Say(2420,600,cEmp_Cnpj,oFont12)
	oPrintPPR:Say(2500,150,STR0016,oFont12b) //"Cidade"
	oPrintPPR:Say(2500,600,cCidade,oFont12)

	lin := 9999 //Forçar quebra de pagina
	Somalinha(150)
	oPrintPPR:Say(lin,150,"1. "+STR0032,oFont12b) //"IDENTIFICAÇÃO DA EMPRESA"
	Somalinha(80)
	oPrintPPR:Say(lin,150,STR0033+":",oFont10b) //"Razão Social"
	oPrintPPR:Say(lin,600,cEmp_Nome,oFont10)
	SomaLinha()
	oPrintPPR:Say(lin,150,aTipoInsc[1]+" ",oFont10b) //"CNPJ :"
	oPrintPPR:Say(lin,600,cEmp_Cnpj,oFont10)
	SomaLinha()
	oPrintPPR:Say(lin,150,STR0018,oFont10b) //"Inscrição Estadual"
	oPrintPPR:Say(lin,600,cEmp_Insc,oFont10)
	SomaLinha()
	oPrintPPR:Say(lin,150,STR0015,oFont10b) //"Endereço"
	oPrintPPR:Say(lin,600,cEmp_Endr,oFont10)
	SomaLinha()
	oPrintPPR:Say(lin,150,STR0017,oFont10b) //"Bairro"
	oPrintPPR:Say(lin,600,cEmp_Bair,oFont10)
	SomaLinha()
	oPrintPPR:Say(lin,150,STR0021,oFont10b) //"Nº de Funcionários:"
	oPrintPPR:Say(lin,600,cNum_Func,oFont10)
	SomaLinha()
	oPrintPPR:Say(lin,150,STR0016,oFont10b) //"Cidade"
	oPrintPPR:Say(lin,600,cCidade,oFont10)

	Somalinha(120)

	cMemo := Alltrim(TO0->TO0_DESCRI)
	If NGCADICBASE("TO0_MMSYP2","A","TO0",.F.)
		If !Empty(TO0->TO0_MMSYP2)
			cMMSYP2 := MSMM(TO0->TO0_MMSYP2,80)
			If !Empty(cMMSYP2)
				If !Empty(cMemo)
					cMemo += Chr(13)+Chr(10)
				Endif
				cMemo += cMMSYP2
			Endif
		Endif
	ElseIf NGCADICBASE("TO0_DESC2","A","TO0",.F.)
		If !Empty(TO0->TO0_DESC2)
			If !Empty(cMemo)
				cMemo += Chr(13)+Chr(10)
			Endif
			cMemo += Alltrim(TO0->TO0_DESC2)
		Endif
	Endif

	SetRegua(100)
	nLenMemo := Len(cMemo)
	nPerMemo := 0

	While lEof
		If Empty(cMemo) //Memo vazio
			lEof := .F.
			Exit
		Else
			nPos1 := At("#",cMemo) //Inicio de um Titulo

			If nPos1 > 1
				cTexto := Alltrim(Substr(cMemo,1,nPos1-1))
				cMemo  := Alltrim(Substr(cMemo,nPos1))
				IMPDOC854(Alltrim(cTexto))
				fReguaPPR( nLenMemo, @nPerMemo, Len(cMemo) ) //Incrementa Regua
				Loop
			ElseIf nPos1 == 1 //Existe #
				cMemo   := Alltrim(Substr(cMemo,nPos1+1))
				nPos1   := At("#",cMemo)
				cTitulo := Alltrim(Substr(cMemo,1,nPos1-1))
				cMemo   := Alltrim(Substr(cMemo,nPos1+1))

				nPos1   := At("#",cMemo)
				If nPos1 > 0
					cTexto := Alltrim(Substr(cMemo,1,nPos1-1))
					cMemo  := Alltrim(Substr(cMemo,nPos1))
				Else
					cTexto := Alltrim(cMemo)
					cMemo  := " "
					lEof   := .F.
				Endif
			Else //Nao existe #
				//IMPRIME TEXTO
				IMPDOC854(Alltrim(cMemo))
				lEof := .F.
				Exit
			Endif

			//IMPRIME TITULO
			If !Empty(cTitulo)
				IMPHEA854(cTitulo)
			Endif

			//IMPRIME TEXTO
			If !Empty(cTexto)
				lPrint := .T.
				lPrin2 := .T.
				IMPDOC854(Alltrim(cTexto))
			Endif

		Endif

		fReguaPPR( nLenMemo, @nPerMemo, Len(cMemo) ) //Incrementa Regua

	End

	cTxtMemo := " "
	dbSelectArea("TMZ")
	dbSetOrder(1)
	IF dbSeek(xFilial("TMZ")+TO0->TO0_TERMO)
		cTxtMemo := TMZ->TMZ_DESCRI
	Endif

	dbSelectArea("TMK")
	dbSetOrder(1)
	dbSeek(xFilial("TMK")+Mv_par02)

	If Lin != 300 //Se o cursor estiver na primeira linha nao eh necessario criar uma nova pagina
		Lin := 9999
		Somalinha()
	Endif

	oPrintPPR:Say(lin,1000,STR0023,oFont12b) //"RESPONSÁVEIS TÉCNICOS"

	Somalinha(180)
	IMPDOC854(Alltrim(cTxtMemo))

	Somalinha(180)
	oPrintPPR:Say(lin,100,STR0024,oFont12b) //"COORDENADOR:"
	oPrintPPR:Say(lin,600,Alltrim(TMK->TMK_NOMUSU),oFont12)

	Somalinha()
	oPrintPPR:Say(lin,100,STR0025,oFont12b) //"REG.SSST:"
	oPrintPPR:Say(lin,600,Alltrim(TMK->TMK_REGMTB),oFont12)

  	If !Empty(TMK->TMK_NUMENT)
  		Somalinha()
  		oPrintPPR:Say(lin,100,If(Empty(TMK->TMK_ENTCLA),"",Alltrim(TMK->TMK_ENTCLA)+": "),oFont12b)
  		oPrintPPR:Say(lin,600,Alltrim(TMK->TMK_NUMENT),oFont12)
  	End If

	Somalinha()
	oPrintPPR:Say(lin,100,STR0026,oFont12b) //"FONE:"
	oPrintPPR:Say(lin,600,Alltrim(TMK->TMK_TELUSU),oFont12)

	Somalinha()
	oPrintPPR:Say(lin,100,STR0015,oFont12b) //"ENDEREÇO:"
	oPrintPPR:Say(lin,600,Alltrim(TMK->TMK_ENDUSU),oFont12)

	dbSelectArea("TMK")
	dbSetOrder(1)
	dbSeek(xFilial("TMK")+TO0->TO0_CODUSU)

	SomaLinha(120)
	oPrintPPR:Say(lin,100,STR0027+" ",oFont12b) //"RESPONSÁVEL: "
	oPrintPPR:Say(lin,600,Alltrim(TMK->TMK_NOMUSU),oFont12)

	If !Empty(TMK->TMK_NUMENT)
		Somalinha()
		oPrintPPR:Say(lin,100,If(Empty(TMK->TMK_ENTCLA),"",Alltrim(TMK->TMK_ENTCLA)+": "),oFont12b)
		oPrintPPR:Say(lin,600,Alltrim(TMK->TMK_NUMENT),oFont12)
	End If

	Somalinha()
	oPrintPPR:Say(lin,100,STR0026+" ",oFont12b) //"FONE: "
	oPrintPPR:Say(lin,600,Alltrim(TMK->TMK_TELUSU),oFont12)

	Somalinha()
	oPrintPPR:Say(lin,100,STR0015,oFont12b) //"ENDEREÇO:"
	oPrintPPR:Say(lin,600,Alltrim(TMK->TMK_ENDUSU),oFont12)

	Somalinha(180)
	cTxtTmp := cCidadeRe+", "+StrZero(Day(dDataBase),2)+STR0028+MesExtenso(dDataBase)+STR0028+StrZero(Year(dDataBase),4)+"." //" de "###" de "
	oPrintPPR:Say(lin,100,cTxtTmp,oFont12b)

	Somalinha(300)
	oPrintPPR:Say(lin,100,STR0030+"___________________________________________",oFont12) //"Ass.: "

Endif

If aReturn[5] == 1
	oPrintPPR:Preview()
Else
	oPrintPPR:Print()
EndIf

//Devolve a condicao original do arquivo principal
RetIndex("TO0")
Set Filter To

Return NIL

//---------------------------------------------------------------------
/*/{Protheus.doc} SomaLinha

Incrementa Linha e Controla Salto de Pagina

@author Inacio Luiz Kolling
@since 06/97
@version MP11
@return Nil
/*/
//---------------------------------------------------------------------
Static Function Somalinha(nLin__)

If nModeloImp == 1
	OLE_ExecuteMacro(oWord,"Somalinha")
ElseIf nModeloImp == 2
    Li++
    If Li > 58
       Cabec(titulo,cabec1,cabec2,nomeprog,tamanho,nTipo,,.F.)
    EndIf
ElseIf nModeloImp == 3
	If ValType(nLin__) == "N"
	    Lin += nLin__
	Else
		Lin += 60
	Endif
    If Lin > 3000
	    Lin := 300
	    If nPaginaG > 0
		    oPrintPPR:EndPage()
		Endif
		oPrintPPR:StartPage()
		nPaginaG++
		If nPaginaG != 1
			oPrintPPR:Say(100,2320,Alltrim(Str(nPaginaG,10)),oFont08)
		Endif
		If !Empty(cStartLogo) .and. File(cStartLogo)
			oPrintPPR:SayBitMap(100,150,cStartLogo,300,150)
	    EndIf
	Endif
Endif
Return

//---------------------------------------------------------------------
/*/{Protheus.doc} fMDT854WOR

Relatorio do PPR (Word)

@author Bruno L. Souza
@since 02/04/2013
@version MP11
@return Nil
/*/
//---------------------------------------------------------------------
Function fMDT854WOR()

Local cF3CC   := "MDTPS4"  //SI3 apenas do cliente
Private cPerg := "MDTRW854"

If Alltrim(GETMV("MV_MCONTAB")) == "CTB"
	cF3CC := "MDTPS6"  //CTT apenas do cliente
Endif

If Pergunte(cPerg, .T.)
	If lSigaMdtps
		cCliMdtps := Mv_par01+Mv_par02
	Endif
	RptStatus({|lEnd| fWORD854() },titulo)
Endif

Return .T.

//---------------------------------------------------------------------
/*/{Protheus.doc} fWORD854

Impressao do relatorio (Word)

@author Bruno L. Souza
@since 02/04/2013
@version MP11
@return Nil
/*/
//---------------------------------------------------------------------
Function fWORD854()

Local nLenMemo := 0
Local nPerMemo := 0
Local cMemo := " ",cTitulo := " ",cTexto := " "
Local lEof := .T.
Local nLinha
Local cBarraRem := "\"
Local cBarraSrv := "\"
Local cSMCOD := FWGrpCompany()
Local cSMFIL := FWCodFil()
Private lCriaIndice := .F.

Private cArqDot  := "ppr.dot"					 // Nome do arquivo modelo do Word (Tem que ser .dot)
Private cArqBmp  := "LGRL"+cSMCOD+cSMFIL+".BMP"  // Nome do arquivo logo do cliente
Private cArqBmp2 := "LGRL"+cSMCOD+".BMP"         // Nome do arquivo logo do cliente
Private cPathDot := Alltrim(GetMv("MV_DIRACA"))	 // Path do arquivo modelo do Word
Private cRootPath
Private cFileLogo
Private cPathBmp := Alltrim(GetMv("MV_DIRACA"))			// Path do arquivo logo .bmp do cliente
Private cPathBm2 := cPathBmp

If lSigaMdtPS
	cArqBmp  := "LGRL"+cCliMdtPs+".bmp"              // Nome do arquivo logo do cliente
	cArqBmp2 := "LGRL"+Substr(cCliMdtPs,1,nSizeCli)+".bmp" // Nome do arquivo logo do cliente
Endif

If GetRemoteType() == 2  //estacao com sistema operacional unix
	cBarraRem := "/"
Endif
If isSRVunix()  //servidor eh da familia Unix (linux, solaris, free-bsd, hp-ux, etc.)
	cBarraSrv := "/"
Endif

cPathDot += If(Substr(cPathDot,len(cPathDot),1) != cBarraSrv,cBarraSrv,"") + cArqDot
cPathEst += If(Substr(cPathEst,len(cPathEst),1) != cBarraRem,cBarraRem,"")

cPathBmp += If(Substr(cPathBmp,len(cPathBmp),1) != cBarraSrv,cBarraSrv,"") + cArqBmp
cPathBm2 += If(Substr(cPathBm2,len(cPathBm2),1) != cBarraSrv,cBarraSrv,"") + cArqBmp2

//Cria diretorio se nao existir
MontaDir(cPathEst)

//Se existir .dot na estacao, apaga!
If File( cPathEst + cArqDot )
	Ferase( cPathEst + cArqDot )
EndIf
If !File(cPathDot)
	MsgStop(STR0036+chr(10)+STR0037,STR0038) //"O arquivo ppr.dot não foi encontrado no servidor."
	Return
EndIf
CpyS2T(cPathDot,cPathEst,.T.) // Copia do Server para o Remote, eh necessario
// para que o wordview e o proprio word possam preparar o arquivo para impressao e
// ou visualizacao .... copia o DOT que esta no ROOTPATH Protheus para o PATH da
// estacao , por exemplo C:\WORDTMP
//__copyfile(cPathDot,cPathEst+cArqDot)
//Logo
//Se existir .bmp na estacao, apaga!
If File(cPathBmp)
	If File( cPathEst + cArqBmp )
		Ferase( cPathEst + cArqBmp )
	EndIf
	__copyfile(cPathBmp,cPathEst+cArqBmp)
ElseIf File(cPathBm2)
	If File( cPathEst + cArqBmp2 )
		Ferase( cPathEst + cArqBmp2 )
	EndIf
	__copyfile(cPathBm2,cPathEst+cArqBmp2)
	cArqBmp := cArqBmp2
EndIf // para que o wordview e o proprio word possam preparar o arquivo para impressao e
// ou visualizacao .... copia o DOT que esta no ROOTPATH Protheus para o PATH da
// estacao , por exemplo C:\WORDTMP

Private cVar     := "cVAR",nVar := 1
Private cVar1    := "cTIT",nVar1 := 1
Private lPrint   := .T.
Private lPrin2   := .T.
Private lFirst   := .T.
Private lJumpCab := .T.
Private lIdentar := .F.
Private aRiscos  := {}
Private aEpis    := {}
Private aExames  := {}
Private oWord

nQtdFunT := fQtdFunRis() //Retorna quantidade de funcionarios expostos a riscos

If lSigaMdtps

	//cCliMdtPs |------>  Variavel do cliente

	dbSelectArea("TO0")
	dbSetOrder(6)  //TO0_FILIAL+TO0_CLIENT+TO0_LOJA+TO0_LAUDO
	If dbSeek(xFilial("TO0")+cCliMdtPs+Mv_par03)

		lImpress	:= If(mv_par05 == 1,.T.,.F.)	//Verifica se a saida sera em Tela ou Impressora
		cArqSaida	:= If(Empty(mv_par06),"Documento1",AllTrim(mv_par06))	// Nome do arquivo de saida

		oWord := OLE_CreateLink('TMsOleWord97')//Cria link como Word

		If lImpress //Impressao via Impressora
			OLE_SetProperty(oWord,oleWdVisible,  .F.)
			OLE_SetProperty(oWord,oleWdPrintBack,.T.)
		Else //Impressao na Tela(Arquivo)
			OLE_SetProperty(oWord,oleWdVisible,  .F.)
			OLE_SetProperty(oWord,oleWdPrintBack,.F.)
		EndIf

		OLE_NewFile(oWord,cPathEst + cArqDot) //Abrindo o arquivo modelo automaticamente

		cMatriz   := " "
		dbSelectArea("SA1")
		dbSetOrder(1)
		If dbSeek(xFilial("SA1")+cCliMdtps)
			cMatriz := SA1->A1_NOME
		Endif
		cCidade     := Alltrim(SA1->A1_MUN)+If(!Empty(SA1->A1_EST),"-"+SA1->A1_EST," ")
		cEmp_Nome   := SA1->A1_NOME
		cEmp_Cnpj   := SA1->A1_CGC
		cEmp_Endr   := SA1->A1_END
		cEmp_Bair   := SA1->A1_BAIRRO
		cEmp_Insc   := SA1->A1_INSCR
		cEmp_Cnae   := SA1->A1_ATIVIDA
		cEmp_Unop   := TO0->TO0_LOJA
		cEmp_GRisco := TO0->TO0_GRISCO
		cNum_Func   := Alltrim(Str(If(nQtdFunT==0,TO0->TO0_QTDFUN,nQtdFunT),9))

		//Imprime Logo
		cFileLogo := cPathEst + cArqBmp
		If !lMdtUnix //Se for windows
			If File( cFileLogo )
				OLE_SetDocumentVar(oWord,"Cria_Var",cFileLogo)
				OLE_ExecuteMacro(oWord,"Insere_logo")
			Endif
		Endif

		//Dados Empresa
		OLE_SetDocumentVar(oWord,"Empresa",cEmp_Nome)
		OLE_SetDocumentVar(oWord,"tipoInsc",aTipoInsc[1])
		OLE_ExecuteMacro(oWord,"Com_Negrito")
		OLE_SetDocumentVar(oWord,"CGC",cEmp_Cnpj)
		OLE_SetDocumentVar(oWord,"Ie",cEmp_Insc)
		OLE_SetDocumentVar(oWord,"Cnae",cEmp_Cnae)
		OLE_SetDocumentVar(oWord,"GRisco",cEmp_GRisco)
		OLE_SetDocumentVar(oWord,"Cidade",cCidade)
		OLE_SetDocumentVar(oWord,"Endereco",cEmp_Endr)
		OLE_SetDocumentVar(oWord,"Bairro",cEmp_Bair)
		OLE_SetDocumentVar(oWord,"cNum_Func",cNum_Func)
		If lSigaMdtPS
			OLE_SetDocumentVar(oWord,"UNOP",cEmp_Unop)
		Endif
		OLE_ExecuteMacro(oWord,"Deleta_Linha")	//Deleta linha da tabela
		OLE_SetDocumentVar(oWord,"RazaoSocial",cMatriz)
		If Empty(TO0->TO0_DTVALI)
			OLE_SetDocumentVar(oWord,"Validade"," ")
		Else
			OLE_SetDocumentVar(oWord,"Validade",Upper(MesExtenso(TO0->TO0_DTVALI))+"/"+StrZero(Year(TO0->TO0_DTVALI),4))
		Endif

		OLE_ExecuteMacro(oWord,"NewPage")

		cMemo := Alltrim(TO0->TO0_DESCRI)
		If NGCADICBASE("TO0_MMSYP2","A","TO0",.F.)
			If !Empty(TO0->TO0_MMSYP2)
				cMMSYP2 := MSMM(TO0->TO0_MMSYP2,80)
				If !Empty(cMMSYP2)
					If !Empty(cMemo)
						cMemo += Chr(13)+Chr(10)
					Endif
					cMemo += cMMSYP2
				Endif
			Endif
		ElseIf NGCADICBASE("TO0_DESC2","A","TO0",.F.)
			If !Empty(TO0->TO0_DESC2)
				If !Empty(cMemo)
					cMemo += Chr(13)+Chr(10)
				Endif
				cMemo += Alltrim(TO0->TO0_DESC2)
			Endif
		Endif

		SetRegua(100)
		nLenMemo := Len(cMemo)
		nPerMemo := 0

		While lEof
			OLE_ExecuteMacro(oWord,"Atualiza")

			If Empty(cMemo)  //Memo vazio
				lEof := .F.
				Exit
			Else
				nPos1 := At("#",cMemo) //Inicio de um Titulo

				If nPos1 > 1
					cTexto := Alltrim(Substr(cMemo,1,nPos1-1))
					cMemo  := Alltrim(Substr(cMemo,nPos1))
					IMPDOC854(Alltrim(cTexto))
					fReguaPPR( nLenMemo, @nPerMemo, Len(cMemo) ) //Incrementa Regua
					Loop
				ElseIf nPos1 == 1 //Existe #
					cMemo   := Alltrim(Substr(cMemo,nPos1+1))
					nPos1   := At("#",cMemo)
					cTitulo := Alltrim(Substr(cMemo,1,nPos1-1))
					cMemo   := Alltrim(Substr(cMemo,nPos1+1))

					nPos1   := At("#",cMemo)
					If nPos1 > 0
						cTexto := Alltrim(Substr(cMemo,1,nPos1-1))
						cMemo  := Alltrim(Substr(cMemo,nPos1))
					Else
						cTexto := Alltrim(cMemo)
						cMemo  := " "
						lEof   := .F.
					Endif
				Else //Nao existe #
					//IMPRIME TEXTO
					IMPDOC854(Alltrim(cMemo))
					lEof := .F.
					Exit
				Endif


				//IMPRIME TITULO
				If !Empty(cTitulo)
					lCabec854 := .T.
					IMPHEA854(cTitulo,,.T.)
					If !Empty(cTexto)
						nTexto := 0
						nLinhasMemo := MLCOUNT(cTexto,10)
						For nLinha := 1 to nLinhasMemo
						    cTextTemp := MemoLine(cTexto,10,nLinha)
						    If !Empty(cTextTemp)
						    	nTexto := At("@",AllTrim(cTextTemp))
						    	Exit
						    Endif
						Next Linha

						If nTexto == 0
							OLE_ExecuteMacro(oWord,"SomaLinha")
							OLE_ExecuteMacro(oWord,"SomaLinha")
						Endif
					Endif
				Endif
				lPrint := .T.
				lPrin2 := .T.
				IMPDOC854(Alltrim(cTexto))
			Endif

			fReguaPPR( nLenMemo, @nPerMemo, Len(cMemo) ) //Incrementa Regua

		End

		cTxtMemo := " "
		dbSelectArea("TMZ")
		dbSetOrder(1)
		IF dbSeek(xFilial("TMZ")+TO0->TO0_TERMO)
			cTxtMemo := TMZ->TMZ_DESCRI
		Endif

		aUsuSX5 := {}
		aAdd(aUsuSX5,{"1",STR0039}) //"Médico(a) do Trabalho"
		aAdd(aUsuSX5,{"2",STR0040}) //"Enfermeiro(a) do Trabalho"
		aAdd(aUsuSX5,{"3",STR0041}) //"Auxiliar de Enfermagem do Trabalho"
		aAdd(aUsuSX5,{"4",STR0042}) //"Engenheiro(a) de Segurança do Trabalho"
		aAdd(aUsuSX5,{"5",STR0043}) //"Técnico(a) de Segurança do Trabalho"
		aAdd(aUsuSX5,{"6",STR0044}) //"Médico(a)"
		aAdd(aUsuSX5,{"7",STR0045}) //"Enfermeiro(a)"
		aAdd(aUsuSX5,{"8",STR0046}) //"Auxiliar de Enfermagem"
		aAdd(aUsuSX5,{"9",STR0047}) //"Técnico(a) de Enfermagem do Trabalho"
		aAdd(aUsuSX5,{"A",STR0048}) //"Fisioterapeuta"

		nInfoDoc := 0
		cMemoUsu := ""
		dbSelectArea("TMK")
		dbSetOrder(1)
		If dbSeek(xFilial("TMK")+TO0->TO0_CODUSU)
			cMemoUsu += TMK->TMK_NOMUSU+"@#$"+"#*"
			nInfoDoc++
			nPosUs := aScan( aUsuSX5,{|x| x[1] == TMK->TMK_INDFUN })
			If nPosUs > 0
				cMemoUsu += aUsuSX5[nPosUs,2]+"#*"
			Else
				cMemoUsu += " "+"#*"
			Endif
			nInfoDoc++
			If !Empty(TMK->TMK_NUMENT)
				cMemoUsu += If(Empty(TMK->TMK_ENTCLA),"",Alltrim(TMK->TMK_ENTCLA)+": ")+TMK->TMK_NUMENT+"#*"
				nInfoDoc++
			Endif
			If !Empty(TMK->TMK_REGMTB)
				cMemoUsu += STR0049+TMK->TMK_REGMTB+"#*" //"Reg. DSST/MTE.: "
				nInfoDoc++
			Endif
		Endif

		dbSelectArea("TMK")
		dbSetOrder(1)
		If dbSeek(xFilial("TMK")+Mv_par04) .And. Mv_par04 <> TO0->TO0_CODUSU
			cMemoUsu += TMK->TMK_NOMUSU+"@#$"+"#*"
			nInfoDoc++
			nPosUs := aScan( aUsuSX5,{|x| x[1] == TMK->TMK_INDFUN })
			If nPosUs > 0
				cMemoUsu += aUsuSX5[nPosUs,2]+"#*"
			Else
				cMemoUsu += " "+"#*"
			Endif
			nInfoDoc++
			If !Empty(TMK->TMK_NUMENT)
				cMemoUsu += If(Empty(TMK->TMK_ENTCLA),"",Alltrim(TMK->TMK_ENTCLA)+": ")+TMK->TMK_NUMENT+"#*"
				nInfoDoc++
			Endif
			If !Empty(TMK->TMK_REGMTB)
				cMemoUsu += STR0049+TMK->TMK_REGMTB+"#*" //"Reg. DSST/MTE.: "
				nInfoDoc++
			Endif
		Endif

		If nInfoDoc > 0
			OLE_ExecuteMacro(oWord,"Somalinha")
			OLE_ExecuteMacro(oWord,"Somalinha")
			OLE_SetDocumentVar(oWord,"Tabela",cMemoUsu)
			OLE_SetDocumentVar(oWord,"Linhas",nInfoDoc)
			OLE_ExecuteMacro(oWord,"Table_Responsavel")
		Endif

		OLE_SetDocumentVar(oWord,"Cria_Var"	,Space(1)) //Limpa campo oculto do documento
		OLE_SetDocumentVar(oWord,"Tabela"	,Space(1)) //Limpa campo oculto do documento
		OLE_SetDocumentVar(oWord,"Tabela2"	,Space(1)) //Limpa campo oculto do documento
		OLE_SetDocumentVar(oWord,"Linhas"	,Space(1)) //Limpa campo oculto do documento
		If lCriaIndice
			OLE_ExecuteMacro(oWord,"Cria_Indice")//"Cria o indice"
		Endif
		OLE_ExecuteMacro(oWord,"Atualiza") //Executa a macro que atualiza os campos do documento
		If lCriaIndice
			OLE_ExecuteMacro(oWord, "AtualizaIndice")//"Atualiza Indice"
		Endif
		OLE_ExecuteMacro(oWord,"Begin_Text") //Posiciona o cursor no inicio do documento

		cRootPath := GetPvProfString( GetEnvServer(), "RootPath", "ERROR", GetADV97() )
		cRootPath := IF( RIGHT(cRootPath,1) == cBarraSRV,SubStr(cRootPath,1,Len(cRootPath)-1), cRootPath)

		IF lImpress //Impressao via Impressora
			OLE_SetProperty( oWord, '208', .F. ) ; OLE_PrintFile( oWord, "ALL",,, 1 )
		Else //Impressao na Tela(Arquivo)
			OLE_SetProperty(oWord,oleWdVisible,.T.)
			OLE_ExecuteMacro(oWord,"Maximiza_Tela")
			If !lMdtUnix //Se for windows
				If fDIRR854(cRootPath+cBarraSRV+"SPOOL"+cBarraSRV)
					OLE_SaveAsFile(oWord,cRootPath+cBarraSRV+"SPOOL"+cBarraSRV+cArqSaida,,,.F.,oleWdFormatDocument)
				ElseIf fDIRR854(cPathEst)
					OLE_SaveAsFile(oWord,cPathEst+cArqSaida,,,.F.,oleWdFormatDocument)
				Else
					OLE_SaveAsFile(oWord,cPathEst+cArqSaida,,,.F.,oleWdFormatDocument)
				Endif
			Endif
			MsgInfo(STR0050) //"Alterne para o programa do Ms-Word para visualizar o documento ou clique no botao para fechar."
		EndIF
		OLE_CloseFile(oWord) //Fecha o documento
		OLE_CloseLink(oWord) //Fecha o documento
	Endif

Else

	dbSelectArea("TO0")
	dbSetOrder(1)
	If dbSeek(xFilial("TO0")+Mv_par01)

		lImpress	:= If(mv_par03 == 1,.T.,.F.)	//Verifica se a saida sera em Tela ou Impressora
		cArqSaida	:= If(Empty(mv_par04),"Documento1",AllTrim(mv_par04))	// Nome do arquivo de saida

		oWord := OLE_CreateLink('TMsOleWord97')//Cria link como Word

		OLE_NewFile(oWord,cPathEst + cArqDot) //Abrindo o arquivo modelo automaticamente

		If lImpress //Impressao via Impressora
			OLE_SetProperty(oWord,oleWdVisible,  .F.)
			OLE_SetProperty(oWord,oleWdPrintBack,.T.)
		Else //Impressao na Tela(Arquivo)
			OLE_SetProperty(oWord,oleWdVisible,  .F.)
			OLE_SetProperty(oWord,oleWdPrintBack,.F.)
		EndIf
		cEmp := FWGrpCompany()
	    cFil := FWCodFil()
		dbSelectArea("SM0")
		dbSetOrder(1)
		dbSeek(cSMCOD+cSMFIL)
		cCidade   := Alltrim(SM0->M0_CIDCOB)+If(!Empty(SM0->M0_ESTCOB),"-"+SM0->M0_ESTCOB," ")
		cEmp_Nome := SM0->M0_NOMECOM
		cEmp_Cnpj := aTipoInsc[2]//SM0->M0_CGC
		cEmp_Endr := SM0->M0_ENDCOB
		cEmp_Bair := SM0->M0_BAIRCOB
		cEmp_Insc := SM0->M0_INSC
		cEmp_Cnae := SM0->M0_CNAE
		cEmp_Unop := " "
		cMatriz   := " "
		cEmp_GRisco := TO0->TO0_GRISCO
		cNum_Func := Alltrim(Str(If(nQtdFunT==0,TO0->TO0_QTDFUN,nQtdFunT),9))

		//Imprime Logo
		cFileLogo := cPathEst + cArqBmp
		If !lMdtUnix //Se for windows
			If File( cFileLogo )
				OLE_SetDocumentVar(oWord,"Cria_Var",cFileLogo)
				OLE_ExecuteMacro(oWord,"Insere_logo")
			Endif
		Endif

		//Dados Empresa
		OLE_SetDocumentVar(oWord,"Empresa",cEmp_Nome)
		OLE_SetDocumentVar(oWord,"tipoInsc",aTipoInsc[1])
		OLE_ExecuteMacro(oWord,"Com_Negrito")
		OLE_SetDocumentVar(oWord,"CGC",cEmp_Cnpj)
		OLE_SetDocumentVar(oWord,"Ie",cEmp_Insc)
		OLE_SetDocumentVar(oWord,"Cnae",cEmp_Cnae)
		OLE_SetDocumentVar(oWord,"GRisco",cEmp_GRisco)
		OLE_SetDocumentVar(oWord,"Cidade",cCidade)
		OLE_SetDocumentVar(oWord,"Endereco",cEmp_Endr)
		OLE_SetDocumentVar(oWord,"Bairro",cEmp_Bair)
		OLE_SetDocumentVar(oWord,"cNum_Func",cNum_Func)
		If lSigaMdtPS
			OLE_SetDocumentVar(oWord,"UNOP",cEmp_Unop)
		Endif
		OLE_ExecuteMacro(oWord,"Deleta_Linha")	//Deleta linha da tabela
		OLE_SetDocumentVar(oWord,"RazaoSocial",cMatriz)
		If Empty(TO0->TO0_DTVALI)
			OLE_SetDocumentVar(oWord,"Validade"," ")
		Else
			OLE_SetDocumentVar(oWord,"Validade",Upper(MesExtenso(TO0->TO0_DTVALI))+"/"+StrZero(Year(TO0->TO0_DTVALI),4))
		Endif

		OLE_ExecuteMacro(oWord,"NewPage")

		cMemo := Alltrim(TO0->TO0_DESCRI)

		If NGCADICBASE("TO0_MMSYP2","A","TO0",.F.)
			If !Empty(TO0->TO0_MMSYP2)
				cMMSYP2 := MSMM(TO0->TO0_MMSYP2,80)
				If !Empty(cMMSYP2)
					If !Empty(cMemo)
						cMemo += Chr(13)+Chr(10)
					Endif
					cMemo += cMMSYP2
				Endif
			Endif
		ElseIf NGCADICBASE("TO0_DESC2","A","TO0",.F.)
			If !Empty(TO0->TO0_DESC2)
				If !Empty(cMemo)
					cMemo += Chr(13)+Chr(10)
				Endif
				cMemo += Alltrim(TO0->TO0_DESC2)
			Endif
		Endif

		SetRegua(100)
		nLenMemo := Len(cMemo)
		nPerMemo := 0

		While lEof
			OLE_ExecuteMacro(oWord,"Atualiza")

			If Empty(cMemo) //Memo vazio
				lEof := .F.
				Exit
			Else
				nPos1 := At("#",cMemo) //Inicio de um Titulo

				If nPos1 > 1
					cTexto := Alltrim(Substr(cMemo,1,nPos1-1))
					cMemo  := Alltrim(Substr(cMemo,nPos1))
					IMPDOC854(Alltrim(cTexto))
					fReguaPPR( nLenMemo, @nPerMemo, Len(cMemo) ) //Incrementa Regua
					Loop
				ElseIf nPos1 == 1 //Existe #
					cMemo   := Alltrim(Substr(cMemo,nPos1+1))
					nPos1   := At("#",cMemo)
					cTitulo := Alltrim(Substr(cMemo,1,nPos1-1))
					cMemo   := Alltrim(Substr(cMemo,nPos1+1))

					nPos1   := At("#",cMemo)
					If nPos1 > 0
						cTexto := Alltrim(Substr(cMemo,1,nPos1-1))
						cMemo  := Alltrim(Substr(cMemo,nPos1))
					Else
						cTexto := Alltrim(cMemo)
						cMemo  := " "
						lEof   := .F.
					Endif
				Else //Nao existe #
					//IMPRIME TEXTO
					IMPDOC854(Alltrim(cMemo))
					lEof := .F.
					Exit
				Endif

				//IMPRIME TITULO
				If !Empty(cTitulo)
					lCabec854 := .T.
			   		IMPHEA854(cTitulo,,.T.)
					If !Empty(cTexto)
						nTexto := 0
						nLinhasMemo := MLCOUNT(cTexto,10)
						For nLinha := 1 to nLinhasMemo
						    cTextTemp := MemoLine(cTexto,10,nLinha)
						    If !Empty(cTextTemp)
						    	nTexto := At("@",AllTrim(cTextTemp))
						    	Exit
						    Endif
						Next Linha

						If nTexto == 0
							OLE_ExecuteMacro(oWord,"SomaLinha")
							OLE_ExecuteMacro(oWord,"SomaLinha")
						Endif
					Endif
				Endif
				lPrint := .T.
				lPrin2 := .T.
				IMPDOC854(Alltrim(cTexto))
			Endif
			fReguaPPR( nLenMemo, @nPerMemo, Len(cMemo) ) //Incrementa Regua
		End

		cTxtMemo := " "
		dbSelectArea("TMZ")
		dbSetOrder(1)
		IF dbSeek(xFilial("TMZ")+TO0->TO0_TERMO)
			cTxtMemo := TMZ->TMZ_DESCRI
		Endif

		aUsuSX5 := {}
		aAdd(aUsuSX5,{"1",STR0039}) //"Médico(a) do Trabalho"
		aAdd(aUsuSX5,{"2",STR0040}) //"Enfermeiro(a) do Trabalho"
		aAdd(aUsuSX5,{"3",STR0041}) //"Auxiliar de Enfermagem do Trabalho"
		aAdd(aUsuSX5,{"4",STR0042}) //"Engenheiro(a) de Segurança do Trabalho"
		aAdd(aUsuSX5,{"5",STR0043}) //"Técnico(a) de Segurança do Trabalho"
		aAdd(aUsuSX5,{"6",STR0044}) //"Médico(a)"
		aAdd(aUsuSX5,{"7",STR0045}) //"Enfermeiro(a)"
		aAdd(aUsuSX5,{"8",STR0046}) //"Auxiliar de Enfermagem"
		aAdd(aUsuSX5,{"9",STR0047}) //"Técnico(a) de Enfermagem do Trabalho"
		aAdd(aUsuSX5,{"A",STR0048}) //"Fisioterapeuta"

		nInfoDoc := 0
		cMemoUsu := ""
		dbSelectArea("TMK")
		dbSetOrder(1)
		If dbSeek(xFilial("TMK")+TO0->TO0_CODUSU)
			cMemoUsu += TMK->TMK_NOMUSU+"@#$"+"#*"
			nInfoDoc++
			nPosUs := aScan( aUsuSX5,{|x| x[1] == TMK->TMK_INDFUN })
			If nPosUs > 0
				cMemoUsu += aUsuSX5[nPosUs,2]+"#*"
			Else
				cMemoUsu += " "+"#*"
			Endif
			nInfoDoc++
			If !Empty(TMK->TMK_NUMENT)
				cMemoUsu += If(Empty(TMK->TMK_ENTCLA),"",Alltrim(TMK->TMK_ENTCLA)+": ")+TMK->TMK_NUMENT+"#*"
				nInfoDoc++
			Endif
			If !Empty(TMK->TMK_REGMTB)
				cMemoUsu += STR0049+TMK->TMK_REGMTB+"#*" //"Reg. DSST/MTE.: "
				nInfoDoc++
			Endif
		Endif

		dbSelectArea("TMK")
		dbSetOrder(1)
		If dbSeek(xFilial("TMK")+Mv_par02) .And. Mv_par02 <> TO0->TO0_CODUSU
			cMemoUsu += TMK->TMK_NOMUSU+"@#$"+"#*"
			nInfoDoc++
			nPosUs := aScan( aUsuSX5,{|x| x[1] == TMK->TMK_INDFUN })
			If nPosUs > 0
				cMemoUsu += aUsuSX5[nPosUs,2]+"#*"
			Else
				cMemoUsu += " "+"#*"
			Endif
			nInfoDoc++
			If !Empty(TMK->TMK_NUMENT)
				cMemoUsu += If(Empty(TMK->TMK_ENTCLA),"",Alltrim(TMK->TMK_ENTCLA)+": ")+TMK->TMK_NUMENT+"#*"
				nInfoDoc++
			Endif
			If !Empty(TMK->TMK_REGMTB)
				cMemoUsu += STR0049+TMK->TMK_REGMTB+"#*" //"Reg. DSST/MTE.: "
				nInfoDoc++
			Endif
		Endif

		If nInfoDoc > 0
			OLE_ExecuteMacro(oWord,"Somalinha")
			OLE_ExecuteMacro(oWord,"Somalinha")
			OLE_SetDocumentVar(oWord,"Tabela",cMemoUsu)
			OLE_SetDocumentVar(oWord,"Linhas",nInfoDoc)
			OLE_ExecuteMacro(oWord,"Table_Responsavel")
		Endif

		OLE_SetDocumentVar(oWord,"Cria_Var"	,Space(1)) //Limpa campo oculto do documento
		OLE_SetDocumentVar(oWord,"Tabela"	,Space(1)) //Limpa campo oculto do documento
		OLE_SetDocumentVar(oWord,"Tabela2"	,Space(1)) //Limpa campo oculto do documento
		OLE_SetDocumentVar(oWord,"Linhas"	,Space(1)) //Limpa campo oculto do documento
   		If lCriaIndice
			OLE_ExecuteMacro(oWord,"Cria_Indice")//"Cria o indice"
		Endif
		OLE_ExecuteMacro(oWord,"Atualiza") //Executa a macro que atualiza os campos do documento
		If lCriaIndice
			OLE_ExecuteMacro(oWord, "AtualizaIndice")//"Atualiza Indice"
		Endif
		OLE_ExecuteMacro(oWord,"Begin_Text") //Posiciona o cursor no inicio do documento

		cRootPath := GetPvProfString( GetEnvServer(), "RootPath", "ERROR", GetADV97() )
		cRootPath := IF( RIGHT(cRootPath,1) == cBarraSRV,SubStr(cRootPath,1,Len(cRootPath)-1), cRootPath)

		IF lImpress //Impressao via Impressora
			OLE_SetProperty( oWord, '208', .F. ) ; OLE_PrintFile( oWord, "ALL",,, 1 )
		Else //Impressao na Tela(Arquivo)
			OLE_SetProperty(oWord,oleWdVisible,.T.)
			OLE_ExecuteMacro(oWord,"Maximiza_Tela")
			If !lMdtUnix //Se for windows
				If fDIRR854(cRootPath+cBarraSRV+"SPOOL"+cBarraSRV)
					OLE_SaveAsFile(oWord,cRootPath+cBarraSRV+"SPOOL"+cBarraSRV+cArqSaida,,,.F.,oleWdFormatDocument)
				ElseIf fDIRR854(cPathEst)
					OLE_SaveAsFile(oWord,cPathEst+cArqSaida,,,.F.,oleWdFormatDocument)
				Else
					OLE_SaveAsFile(oWord,cPathEst+cArqSaida,,,.F.,oleWdFormatDocument)
				Endif
			Endif
			MsgInfo(STR0050) //"Alterne para o programa do Ms-Word para visualizar o documento ou clique no botao para fechar."
		EndIF
		OLE_CloseFile(oWord) //Fecha o documento
		OLE_CloseLink(oWord) //Fecha o documento
	Endif

Endif

Return .T.

/*---------------------------------------------------------------------
{Protheus.doc} fQtdFunRis

Contabiliza a quantidade de funcionarios expostos a riscos

@author Bruno L. Souza
@since 02/04/2013
@version MP11
@return Nil

---------------------------------------------------------------------*/
Static Function fQtdFunRis()
Local aFunc  := {} , nFunc := 0
Local cCusto := "", cFunc := "" , cTar := ""
Local cSeek  := " "
Local cSeekTN0
Local lRet := .T. , nInd  := 1
Local lDepto := NGCADICBASE( "TN0_DEPTO", "A" , "TN0" , .F. )
Local aCateg := {},n , cCond := ""
Local nTamCC := If((TAMSX3("TN0_CC")[1]) < 1,9,(TAMSX3("TN0_CC")[1]))
Local nTamFun:= If((TAMSX3("TN0_CODFUN")[1]) < 1,5,(TAMSX3("TN0_CODFUN")[1]))
Local nTamTar:= If((TAMSX3("TN0_CODTAR")[1]) < 1,6,(TAMSX3("TN0_CODTAR")[1]))
Local nTamDep:= If( lDepto ,TAMSX3("TN0_DEPTO")[1], 9 )

If Empty(dDeLaudo) .Or. Empty(dAteLaudo)
	If !lSigaMdtps
		dbSelectArea("TO0")
		dbSetOrder(1)
		dbSeek(xFilial("TO0")+mv_par01)
		dDeLaudo := TO0->TO0_DTINIC
		If	!Empty(TO0->TO0_DTFIM)
			dAteLaudo := TO0->TO0_DTFIM
		Else
			dAteLaudo := dDatabase
		EndIf
	Else
		dbSelectArea("TO0")
		dbSetOrder(1)
		dbSeek(xFilial("TO0")+mv_par03)
		dDeLaudo := TO0->TO0_DTINIC
		If	!Empty(TO0->TO0_DTFIM)
			dAteLaudo := TO0->TO0_DTFIM
		Else
			dAteLaudo := dDatabase
		EndIf
	EndIf
EndIf

cFiltroF := Alltrim(SuperGetMv("MV_NGCATFU",.F.," "))
aCateg := fSubCateg(cFiltroF)
For n:=1 to Len(aCateg)
	cCond += " AND RA_CATFUNC <> '"+aCateg[n] + "' "
Next

If !lSigaMdtPs
	dbSelectArea("TN0")
		dbSetOrder(5)//TN0_FILIAL+TN0_CC+TN0_CODFUN+TN0_CODTAR+TN0_DEPTO
		cSeekTN0 := xFilial("TN0")+PADR( "*", nTamCC )+PADR( "*", nTamFun )+PADR( "*", nTamTar )
		If lDepto
			cSeekTN0 += PADR( "*", nTamDep)
		EndIf
		If dbSeek( cSeekTN0 ) .or. lImpTodos//Se achar centro de custo/funcao/tarefa * considera todos
	  	#IFDEF TOP
			cTabSRA := RetSqlName("SRA")
			cFilSRA := xFilial("SRA")
			cAliasSRA := GetNextAlias()
			cQuery := "SELECT COUNT(*) AS TOTAL "
			cQuery += "FROM " + cTabSRA + " "
			cQuery += "WHERE (RA_SITFOLH != 'D' OR RA_DEMISSA > '"+ DtoS(dAteLaudo) +"')"
			cQuery += "AND RA_ADMISSA < '"+DtoS(dAteLaudo)+"' AND RA_FILIAL = '" + cFilSRA + "' AND D_E_L_E_T_ != '*'"
			If !Empty(cCond)
				cQuery += cCond
			Endif
			cQuery := ChangeQuery(cQuery)
			MPSysOpenQuery( cQuery , cAliasSRA )
			dbSelectArea(cAliasSRA)
			dbGoTop()
			nFunc := (cAliasSRA)->TOTAL
			(cAliasSRA)->( dbCloseArea() )
			Return nFunc
		#ELSE
			dbSelectArea("SRA")
			dbSetOrder(1)
			dbSeek(xFilial("SRA"))
			While !eof() .and. xFilial("SRA") == SRA->RA_FILIAL
				If SRA->RA_CATFUNC $ cFiltroF //Indica as Categorias Funcionais que nao aparecerao no PPRA
					dbSelectArea("SRA")
					dbSkip()
					Loop
				Endif
				If (SRA->RA_SITFOLH == "D" .And. SRA->RA_DEMISSA <= dAteLaudo) .or. (!Empty(SRA->RA_DEMISSA) .And. SRA->RA_DEMISSA <= dAteLaudo)
					dbSelectArea("SRA")
					dbSkip()
					Loop
				EndIf
				If SRA->RA_ADMISSA > dAteLaudo
					dbSelectArea("SRA")
					dbSkip()
					Loop
				EndIf
				nFunc++
				dbSelectArea("SRA")
				dbSkip()
				Loop
			End
			Return nFunc
		#ENDIF
	Else
		//Percorre todos os riscos
		dbSelectArea("TN0")
		dbSetOrder(1)
		dbSeek(xFilial("TN0"))
		While !Eof() .and. xFilial("TN0") == TN0->TN0_FILIAL
		   If TN0->TN0_MAPRIS == "1"//Valida se o Mapa Risco é igual a CIPA ### Autor: Jackson Machado ### Data: 10/02/2011
		   	dbSelectArea("TN0")
		   	dbSkip()
		   	Loop
		   Endif
			dbSelectArea("TO1")
			dbSetOrder(1)
			dbGoTop()
			If !dbSeek(xFilial("TO1")+mv_par01+TN0->TN0_NUMRIS)
				dbSelectArea("TN0")
				dbSkip()
				Loop
			EndIf
			dbSelectArea("TN0")

			cCusto := TN0->TN0_CC
			cFunc := TN0->TN0_CODFUN
			cTar := TN0->TN0_CODTAR
			If lDepto
				cDepto := TN0->TN0_DEPTO
			EndIf
			If Alltrim(cCusto) == "*"
				If Alltrim(cFunc) == "*"
					If If(lDepto,(Alltrim(cDepto) == "*"),.T.)
					If Alltrim(cTar) == "*"
						Return 0
					Else
						dbSelectArea("TN6")
						dbSetOrder(01)
						dbSeek(xFilial("TN6")+cTar)//Verifica quantidade da tarefa
						While !EOF() .and. xFilial("TN6") == TN6->TN6_FILIAL .and. TN6->TN6_CODTAR == cTar
							dbSelectArea("SRA")
							dbSetOrder(01)
							If dbSeek(xFilial("SRA")+TN6->TN6_MAT)  .and.;
								TN6->TN6_DTINIC <= dDatabase         .and.;
								(TN6->TN6_DTTERM >= dDatabase .or. Empty(TN6->TN6_DTTERM))
								//Verifica se não esta demitido e no array
								If (SRA->RA_SITFOLH == "D") .or. (!Empty(SRA->RA_DEMISSA) .And. SRA->RA_DEMISSA <= dAteLaudo)
									dbSelectArea("SRA")
									dbSkip()
									Loop
								EndIf
								If SRA->RA_ADMISSA > dAteLaudo
									dbSelectArea("SRA")
									dbSkip()
									Loop
								EndIf
								If (SRA->RA_SITFOLH != "D" .and. (aScan(aFunc,{|x| Trim(Upper(x[1])) == Trim(Upper(SRA->RA_MAT)) }) == 0) .and. !(SRA->RA_CATFUNC $ cFiltroF)) .Or.;
									(!Empty(SRA->RA_DEMISSA) .And. SRA->RA_DEMISSA > dAteLaudo .And. (aScan(aFunc,{|x| Trim(Upper(x[1])) == Trim(Upper(SRA->RA_MAT)) }) == 0) .and. !(SRA->RA_CATFUNC $ cFiltroF))
									aADD(aFunc,{SRA->RA_MAT})
								EndIf
							EndIf
							dbSelectArea("TN6")
							dbSkip()
							Loop
						End
						lRet := .F.
						//Volta ao loop principal
						dbSelectArea("TN0")
						dbSkip()
						Loop
					EndIf
				Else
					lRet := .T.
						nInd   := 21 //Ordenar pelo Codigo do Departamento
						cSeek  := cDepto
						cField := "SRA->RA_DEPTO"
					EndIf
				Else
					lRet := .T.
					nInd   := 7 //Ordenar pelo Codigo da Funcao
					cSeek  := cFunc
					cField := "SRA->RA_CODFUNC"
				EndIf
			Else
				lRet := .T.
				nInd   := 2 //Ordenar pelo Codigo do Centro de Custo
				cSeek  := cCusto
				cField := "SRA->RA_CC"
			EndIf

			If lRet
				//Percorre SRA com chave (CC ou funcao)
				dbSelectArea("SRA")
				dbSetOrder(nInd)
				dbSeek(xFilial("SRA")+cSeek)
				While !EOF() .and. xFilial("SRA") == SRA->RA_FILIAL .and. &cField == cSeek
					//Nao le demitidos
					If (SRA->RA_SITFOLH == "D" .And. SRA->RA_DEMISSA <= dAteLaudo) .or. (!Empty(SRA->RA_DEMISSA) .And. SRA->RA_DEMISSA <= dAteLaudo)
						dbSelectArea("SRA")
						dbSkip()
						Loop
					EndIf
					If SRA->RA_ADMISSA > dAteLaudo
						dbSelectArea("SRA")
						dbSkip()
						Loop
					EndIf
					If SRA->RA_CATFUNC $ cFiltroF //Indica as Categorias Funcionais que nao aparecerao no PPRA
						dbSelectArea("SRA")
						dbSkip()
						Loop
					Endif

					lFunc := .f.
					//Se estiver por funcao
					If nInd == 7
						If If(lDepto,( SRA->RA_DEPTO == cDepto .or. Alltrim(cDepto) == "*" ),.T.) .And. ;
							( SRA->RA_CC == cCusto .or. Alltrim(cCusto) == "*" )
						If Alltrim(cTar) == "*"//Se todas as tarefas
							If (SRA->RA_SITFOLH == "D" .And. SRA->RA_DEMISSA <= dAteLaudo) .or. (!Empty(SRA->RA_DEMISSA) .And. SRA->RA_DEMISSA <= dAteLaudo)
								dbSelectArea("SRA")
								dbSkip()
								Loop
							EndIf
							If SRA->RA_ADMISSA > dAteLaudo
								dbSelectArea("SRA")
								dbSkip()
								Loop
							EndIf
							If (SRA->RA_SITFOLH != "D" .and. (aScan(aFunc,{|x| Trim(Upper(x[1])) == Trim(Upper(SRA->RA_MAT)) }) == 0)) .Or.;
								(!Empty(SRA->RA_DEMISSA) .And. SRA->RA_DEMISSA > dAteLaudo .and. (aScan(aFunc,{|x| Trim(Upper(x[1])) == Trim(Upper(SRA->RA_MAT)) }) == 0))
								aADD(aFunc,{SRA->RA_MAT})
							EndIf
							//Volta ao Loop da SRA
							dbSelectArea("SRA")
							dbSkip()
							Loop
						Else
							lFunc := .t.//Indice que deve verificar tarefa
						EndIf
						EndIf
					ElseIf nInd == 21
						If ( SRA->RA_CODFUNC == cFunc .or. Alltrim(cFunc) == "*" ) .And. ;
							( SRA->RA_CC == cCusto .or. Alltrim(cCusto) == "*" )
							If Alltrim(cTar) == "*"
								If (SRA->RA_SITFOLH == "D" .And. SRA->RA_DEMISSA <= dAteLaudo) .or. (!Empty(SRA->RA_DEMISSA) .And. SRA->RA_DEMISSA <= dAteLaudo)
									dbSelectArea("SRA")
									dbSkip()
									Loop
								EndIf
								If SRA->RA_ADMISSA > dAteLaudo
									dbSelectArea("SRA")
									dbSkip()
									Loop
								EndIf
								If SRA->RA_SITFOLH != "D" .and.	(aScan(aFunc,{|x| Trim(Upper(x[1])) == Trim(Upper(SRA->RA_MAT)) }) == 0)
									aADD(aFunc,{SRA->RA_MAT})
								EndIf
								dbSelectArea("SRA")//Volta ao Loop da SRA
								dbSkip()
								Loop
							Else
								lFunc := .t.//Indice que deve verificar tarefa
							EndIf
						EndIf
					Else//Se for por CC
						If ( SRA->RA_CODFUNC == cFunc .or. Alltrim(cFunc) == "*" ) .And. ;
							If(lDepto,( SRA->RA_DEPTO == cDepto .or. Alltrim(cDepto) == "*" ),.T.)
							If Alltrim(cTar) == "*"
								If (SRA->RA_SITFOLH == "D" .And. SRA->RA_DEMISSA <= dAteLaudo) .or. (!Empty(SRA->RA_DEMISSA) .And. SRA->RA_DEMISSA <= dAteLaudo)
									dbSelectArea("SRA")
									dbSkip()
									Loop
								EndIf
								If SRA->RA_ADMISSA > dAteLaudo
									dbSelectArea("SRA")
									dbSkip()
									Loop
								EndIf
								If SRA->RA_SITFOLH != "D" .and.	(aScan(aFunc,{|x| Trim(Upper(x[1])) == Trim(Upper(SRA->RA_MAT)) }) == 0)
									aADD(aFunc,{SRA->RA_MAT})
								EndIf
								dbSelectArea("SRA")//Volta ao Loop da SRA
								dbSkip()
								Loop
							Else
								lFunc := .t.//Indice que deve verificar tarefa
							EndIf
						EndIf
					EndIf

					//Verifica por tarefa
					If lFunc
						dbSelectArea("TN6")
						dbSetOrder(01)
						dbSeek(xFilial("TN6")+cTar+SRA->RA_MAT)
						While !Eof() .and. xFilial("TN6") == TN6->TN6_FILIAL .and. TN6->TN6_MAT == SRA->RA_MAT .and. TN6->TN6_CODTAR == cTar
							If TN6->TN6_DTINIC <= dDatabase .and. (TN6->TN6_DTTERM >= dDatabase .or. Empty(TN6->TN6_DTTERM))
								If (SRA->RA_SITFOLH != "D" .and.	SRA->RA_ADMISSA < dAteLaudo .and. (aScan(aFunc,{|x| Trim(Upper(x[1])) == Trim(Upper(SRA->RA_MAT)) }) == 0)) .Or.;
									(!Empty(SRA->RA_DEMISSA) .And. SRA->RA_DEMISSA > dAteLaudo .and.	SRA->RA_ADMISSA < dAteLaudo .and. (aScan(aFunc,{|x| Trim(Upper(x[1])) == Trim(Upper(SRA->RA_MAT)) }) == 0))
									aADD(aFunc,{SRA->RA_MAT})
								EndIf
								Exit//Volta ao loop da SRA
							EndIf
							dbSelectArea("TN6")
							dbSkip()
							Loop
						End
					EndIf
					dbSelectArea("SRA")
					dbSkip()
					Loop
				End
			EndIf
			dbSelectArea("TN0")
			dbSkip()
			Loop
		End
	EndIf
EndIf

Return Len(aFunc)

/*---------------------------------------------------------------------
{Protheus.doc} fSubCateg

Carrega no array os tipos de categoria do funcionario.

@author Bruno L. Souza
@since 02/04/2013
@version MP11
@return Nil

---------------------------------------------------------------------*/
Static Function fSubCateg(cCateg)
Local aCateg := {}
Local nPos

If !Empty(cCateg)
	If Substr(cCateg,1,1) == ","
		cCateg := Substr(cCateg,2)
	Endif
	If Substr(cCateg,Len(cCateg),1) != ","
		cCateg += ","
	Endif
	cCateg := AllTrim(cCateg)

	While .T.
		nPos := At(",",cCateg)
		If nPos > 0
			If !Empty(Substr(cCateg,1,nPos-1)) .and. Substr(cCateg,1,nPos-1) != ","
				aADD(aCateg,Substr(cCateg,1,nPos-1))
			Endif
			cCateg := Substr(cCateg,nPos+1)
		Else
			Exit
		Endif
	End
Endif

Return aCateg

//---------------------------------------------------------------------
/*/{Protheus.doc} fDIRR854

Verifica se o diretorio existe.

@author Bruno L. Souza
@since 02/04/2013
@version MP11
@return Nil
/*/
//---------------------------------------------------------------------
Function fDIRR854(cCaminho)

Local lDir    := .F.
Local cBARRAS := If(isSRVunix(),"/","\")
Local cBARRAD := If(isSRVunix(),"//","\\")

If !empty(cCaminho) .and. !(cBARRAD$cCaminho)
	cCaminho := alltrim(cCaminho)
	if Right(cCaminho,1) == cBarras
		cCaminho := SubStr(cCaminho,1,len(cCaminho)-1)
	Endif
	lDir :=(Ascan( Directory(cCaminho,"D"),{|_Vet | "D" $ _Vet[5] } ) > 0)
EndIf

Return lDir

//---------------------------------------------------------------------
/*/{Protheus.doc} IMPDOC854

Imprime o conteudo do texto

@author Bruno L. Souza
@since 02/04/2013
@version MP11
@return Nil
/*/
//---------------------------------------------------------------------
Function IMPDOC854(_cTexto,lSaltaLin,lEsquerda,lBackSpc,nMaisCol,lIdentPri,oFonte)

Local lTexto  := .T.
Local nPosTxt := 0
Local cTitExe
Local cTextoNew := _cTexto
Local cTxtMemo  := _cTexto
Local nArroba,LinhaCor
Local nPosTemp
Local cCNS := " "

Default lEsquerda := .F.  //Alinhar à esquerda
Default lBackSpc  := .F.
Default nMaisCol  := 0    //Adiciona colunas para impressão
Default lIdentPri := .T.
If nModeloImp == 3
	Default oFonte	    := oFont10
EndIf

Private lFirst    := .T.
//Imprime texto

lJumpCab := .F. //Somalinha do Titulo de Relatorio
While lTexto
	nArroba := At("@",cTxtMemo)

	If nArroba > 1
		cTextoNew := Alltrim(Substr(cTxtMemo,1,nArroba-1))
		cTxtMemo  := Alltrim(Substr(cTxtMemo,nArroba))
		IMPDOC854(Alltrim(cTextoNew))
		Loop
	ElseIf nArroba == 1 //Existe @
		cTxtMemo := Alltrim(Substr(cTxtMemo,nArroba+1))
		nArroba  := At("@",cTxtMemo)
		cTitExe  := Alltrim(Substr(cTxtMemo,1,nArroba-1))
		PROC854TIT(cTitExe)
		lCabec854 := .F.
		cTxtMemo := Alltrim(Substr(cTxtMemo,nArroba+1))

		nArroba := At("@",cTxtMemo)
		If nArroba > 0
			cTextoNew := Alltrim(Substr(cTxtMemo,1,nArroba-1))
			cTxtMemo  := Alltrim(Substr(cTxtMemo,nArroba))
			IMPDOC854(Alltrim(cTextoNew))
			Loop
		Endif
	Endif

	If (nPosTxt := At(Chr(13)+Chr(10),cTxtMemo)) == 0
		lTexto := .F.
		cTextoNew :=  Alltrim(cTxtMemo)
	Else
		cTextoNew :=  Alltrim(Substr(cTxtMemo,1,nPosTxt-1))
		cTxtMemo  :=  Alltrim(Substr(cTxtMemo,nPosTxt+2))
		If Len(cTxtMemo) == 0
			lTexto := .F.
		Endif
	Endif

	lImp854 := .T.
	If Empty(cTextoNew)
		cTextoNew := " "
	Endif

	If lImp854
		If nModeloImp == 2
			nAddLi := 0+nMaisCol
			If lIdentar
				nAddLi := 5
			Endif
			If lIdentPri
				lPrimeiro := .T.
			Else
				lPrimeiro := .F.
			EndIf
			nLinhasMemo := MLCOUNT(cTextoNew,120)
			For LinhaCor := 1 to nLinhasMemo
			    If lPrimeiro
					@ Li,005+nAddLi PSAY (MemoLine(cTextoNew,120,LinhaCor))
					lPrimeiro := .F.
				Else
					@ Li,000+nAddLi PSAY (MemoLine(cTextoNew,120,LinhaCor))
				EndIf
				Somalinha()
			Next LinhaCor
		ElseIf nModeloImp == 1 .And. cTextoNew <> " "
			cVar1 := "cTXT"+Strzero(nVar1,6)
			OLE_SetDocumentVar(oWord,"Cria_Var",cVar1)
			nVar1++

			If lPrint .and. !lFirst
				OLE_ExecuteMacro(oWord,"Somalinha")
				lPrint := .F.
			Endif
			If lPrin2 .and. !lFirst
				OLE_ExecuteMacro(oWord,"Somalinha")
			Endif

			If lSaltaLin
				OLE_ExecuteMacro(oWord,"Somalinha")
			Endif

			If lIdentar .and. !lFirst
				OLE_ExecuteMacro(oWord,"Identar")
			Endif

			OLE_ExecuteMacro(oWord,"Cria_Txt2")

			If ("{" $ cTextoNew) .and.  ("}" $ cTextoNew)
				nPosTemp := At("}",cTextoNew)
				cCNS     := Substr(cTextoNew,1,nPosTemp)
				cTextoNew := Substr(cTextoNew,nPosTemp+1)
			Endif

			If ("N" $ Upper(cCNS)) //N=Negrito
				OLE_ExecuteMacro(oWord,"Com_Negrito")
			Else
				OLE_ExecuteMacro(oWord,"Sem_Negrito")
			Endif

			If ("C" $ Upper(cCNS)) //C=Centralizar
				OLE_ExecuteMacro(oWord,"Centralizar")
			Else
				OLE_ExecuteMacro(oWord,"Justificar")
			Endif

			If ("S" $ Upper(cCNS)) //S=Sublinhar
				OLE_ExecuteMacro(oWord,"Com_Sublinhar")
			Else
				OLE_ExecuteMacro(oWord,"Sem_Sublinhar")
			Endif

			If lBackSpc .and. lFirst
				OLE_ExecuteMacro(oWord,"BackSpace")
			Endif
			lPrin2 := .T.
			lFirst := .F.
			If lEsquerda
				OLE_ExecuteMacro(oWord,"Alinhar_Esquerda")
			Endif
			OLE_SetDocumentVar(oWord,cVar1,cTextoNew)
		ElseIf nModeloImp == 3
			nAddLi := 0+nMaisCol
			nDifCarac := 0
			If lIdentar
				nAddLi := 150
				nDifCarac := 7
			Endif
			If lIdentPri
				lPrimeiro := .T.
			Else
				lPrimeiro := .F.
			EndIf
			nLinhasMemo := MLCOUNT(cTextoNew,90 - nDifCarac)
			For LinhaCor := 1 to nLinhasMemo
				If lPrimeiro
			    	oPrintPPR:Say(lin,300+nAddLi,MemoLine(cTextoNew,90 - nDifCarac,LinhaCor),oFonte)
					lPrimeiro := .F.
				Else
					oPrintPPR:Say(lin,150+nAddLi,MemoLine(cTextoNew,90 - nDifCarac,LinhaCor),oFonte)
				EndIf
				Somalinha()
			Next LinhaCor
		Endif
	Endif
End
Return .T.

//---------------------------------------------------------------------
/*/{Protheus.doc} IMPHEA854

IMPRIME O TITULO DO TEXTO

@author Bruno L. Souza
@since 02/04/2013
@version MP11
@return Nil
/*/
//---------------------------------------------------------------------
Function IMPHEA854(_cTit,lJump,lIndice)
Local nPosTemp
Local _cTitulo := _cTit
Local cCNS := " "
Local lJumper
Local nLinhasMemo
Local LinhaCor

Default lJump := .F.
Default lIndice := .F.
lJumper := If(!lJump,lJumpCab,lJump)

If nModeloImp == 2
	If ("{" $ _cTitulo) .and.  ("}" $ _cTitulo)
		nPosTemp := At("}",_cTitulo)
		cCNS     := Substr(_cTitulo,1,nPosTemp)
		_cTitulo := Substr(_cTitulo,nPosTemp+1)
	Endif
	Somalinha()
	@ Li,000 Psay _cTitulo
	Somalinha()
	Return .T.

ElseIf nModeloImp == 3

	If ("{" $ _cTitulo) .and.  ("}" $ _cTitulo)
		nPosTemp := At("}",_cTitulo)
		cCNS     := Substr(_cTitulo,1,nPosTemp)
		_cTitulo := Substr(_cTitulo,nPosTemp+1)
	Endif

	nLinhasMemo := MLCOUNT(_cTitulo,90)
	For LinhaCor := 1 to nLinhasMemo
		Somalinha()
		nColImp := 150
		cTxtImp := Alltrim(MemoLine(_cTitulo,90,LinhaCor))
		If ("C" $ Upper(cCNS)) //C=Centralizar
			nDiff := Round( (90 - Len(cTxtImp)) / 2 , 0 )
			If nDiff > 0
				nColImp := 150 + (nDiff*23.3)
			Endif
		Endif
		If ("N" $ Upper(cCNS)) //N=Negrito
			If ("S" $ Upper(cCNS)) //S=Sublinhar
				oPrintPPR:Say(lin,nColImp,cTxtImp,oFont12bs)
			Else
				oPrintPPR:Say(lin,nColImp,cTxtImp,oFont12b)
			Endif
		Else
			If ("S" $ Upper(cCNS)) //S=Sublinhar
				oPrintPPR:Say(lin,nColImp,cTxtImp,oFont12s)
			Else
				oPrintPPR:Say(lin,nColImp,cTxtImp,oFont12)
			Endif
		Endif
	Next LinhaCor

	Return .T.
Else
	lFirst := .F. //Somalinha do texto

	cVar := "cTIT"+Strzero(nVar,6)
	nVar++
	OLE_SetDocumentVar(oWord,"Cria_Var",cVar)
	If !lJumper
		OLE_ExecuteMacro(oWord,"Somalinha")
	Endif
	lJumpCab := .F.//Somalinha do Titulo de Relatorio
	OLE_ExecuteMacro(oWord,"Somalinha")

	If ("{" $ _cTitulo) .and.  ("}" $ _cTitulo)
		nPosTemp := At("}",_cTitulo)
		cCNS     := Substr(_cTitulo,1,nPosTemp)
		_cTitulo := Substr(_cTitulo,nPosTemp+1)
	Endif

	If lIndice
		If ("1" $Upper(cCNS))//Titulo 1
			lCriaIndice := .T.
			OLE_ExecuteMacro(oWord, "Cria_TituloUsuario")
		ElseIf("2" $Upper(cCNS))//2=Titulo 2
			lCriaIndice := .T.
			OLE_ExecuteMacro(oWord, "Cria_TituloUsuario2")
		ElseIf("3" $Upper(cCNS))//2=Titulo 3
			lCriaIndice := .T.
			OLE_ExecuteMacro(oWord, "Cria_TituloUsuario3")
		ElseIf("4" $Upper(cCNS))//2=Titulo 4
			lCriaIndice := .T.
			OLE_ExecuteMacro(oWord, "Cria_TituloUsuario4")
	    Else
	    	OLE_ExecuteMacro(oWord,"Cria_Titulo")
	    Endif
	Else
		OLE_ExecuteMacro(oWord,"Cria_Titulo")
	EndIf

	If ("N" $ Upper(cCNS)) //N=Negrito
		OLE_ExecuteMacro(oWord,"Com_Negrito")
	Else
		OLE_ExecuteMacro(oWord,"Sem_Negrito")
	Endif

	If ("C" $ Upper(cCNS)) //C=Centralizar
		OLE_ExecuteMacro(oWord,"Centralizar")
	Else
		OLE_ExecuteMacro(oWord,"Justificar")
	Endif

	If ("S" $ Upper(cCNS)) //S=Sublinhar
		OLE_ExecuteMacro(oWord,"Com_Sublinhar")
	Else
		OLE_ExecuteMacro(oWord,"Sem_Sublinhar")
	Endif

	OLE_SetDocumentVar(oWord,cVar,_cTitulo)

	If lIndice
		Somalinha()
	Endif
Endif

Return .T.

//---------------------------------------------------------------------
/*/{Protheus.doc} PROC854TIT

IMPRIME A TABELA RELACIONADA AO TITULO

@author Bruno L. Souza
@since 02/04/2013
@version MP11
@return Nil
/*/
//---------------------------------------------------------------------
Function PROC854TIT(_cTitExe)
Local cTitExe := _cTitExe, nTipo := 1, cTitTemp, nPos1

cTitTemp := _cTitExe
nPos1    := At("!",cTitTemp)
If nPos1 > 0
	cTitTemp := Alltrim(Substr(cTitTemp,nPos1+1))
	nPos1    := At("!",cTitTemp)
	If nPos1 > 0
		cTitTemp := Substr(cTitTemp,1,nPos1-1)
		nTipo := 2
	Endif
Endif

If nTipo == 1
	cTitTemp := _cTitExe
	nPos1    := At("%",cTitTemp)
	If nPos1 > 0
		cTitTemp := Alltrim(Substr(cTitTemp,nPos1+1))
		nPos1    := At("%",cTitTemp)
		If nPos1 > 0
			cTitTemp := Substr(cTitTemp,1,nPos1-1)
			nTipo := 3
		Endif
	Endif
Endif

Begin Sequence

	If nTipo == 2
		A854IMAGEM(cTitTemp)
	ElseIf nTipo == 3
		A854ARQUIVO(cTitTemp)
	ElseIf "EQUIPAMENTOS RADIOATIVOS" $ Upper(cTitExe)
		A854EQPRAD()
	ElseIf "PPR - FUNCIONÁRIOS" $ Upper(cTitExe)
		A854PprFun()
	ElseIf "CONTROLE" $ Upper(cTitExe)
		A854CNTRLE()
	ElseIf "LEVANTAMENTO RADIOMÉTRICO" $ Upper(cTitExe)
		A854DOSIME("1",.T.)//A854DOSAMBI(.T.)
	ElseIf "ESTRUTURA LOCAIS" $ Upper(cTitExe)
		A854ESTLOC()
	ElseIf "PPR X PE" $ Upper(cTitExe)
		A854PPRXPE()
	ElseIf "QUADRO REQUISITOS X TREINAMENTO" $ Upper(cTitExe)
		A854QUATRE()
	ElseIf "QUADRO - PROGRAMA MONITORAMENTO" $ Upper(cTitExe)
		A854PROMON()
	ElseIf "DOSIMETRIA POR AMBIENTE FÍSICO" $ Upper(cTitExe)
		A854DOSIME("1",.F.)//A854DOSAMBI(.F.)
	ElseIf "DOSIMETRIA POR FUNCIONÁRIO" $ Upper(cTitExe)
		A854DOSIME("2")//A854DOSFUNC()
	ElseIf "DOSIMETRIA POR CENTRO DE CUSTO" $ Upper(cTitExe)
		A854DOSIME("3")//A854DOSICC()
	ElseIf "DOSIMETRIA POR FUNÇÃO" $ Upper(cTitExe)
		A854DOSIME("4")//A854DFUNCAO()
	ElseIf "DOSIMETRIA POR ATIVIDADE" $ Upper(cTitExe)
		A854DOSIME("5")//A854DOSATIV()
	ElseIf "RADIAÇÃO DE FUGA" $ Upper(cTitExe)
		A854RFUGA()
	ElseIf "PAGINA"	$ Upper(cTitExe)
		If nModeloImp == 2
			li := 80
			somalinha()
		ElseIf nModeloImp == 3
			lin := 9999
			somalinha()
		Else
			OLE_ExecuteMacro(oWord,"NewPage")
			lJumpCab := .T.
		Endif
	Endif
End Sequence

Return .T.

//---------------------------------------------------------------------
/*/{Protheus.doc} A854IMAGEM

Funcao para inserir imagem no doc

@author Bruno L. Souza
@since 02/04/2013
@version MP10/11
@return Nil
/*/
//---------------------------------------------------------------------
Static Function A854IMAGEM(cTitTemp)

Local cFileArq  := "", nPos
Local cBarraSrv := "\"

If nModeloImp != 1 //Se nao for em formato WORD, nao imprime
	Return
Endif

If isSRVunix()  //servidor eh da familia Unix (linux, solaris, free-bsd, hp-ux, etc.)
	cBarraSrv := "/"
Endif

nPos := Rat(cBarraSrv,cTitTemp)
If nPos > 0
	cFileArq := AllTrim(Substr(cTitTemp,nPos+1))
Endif

CpyS2T(Alltrim(cTitTemp),cPathEst,.T.) 	// Copia do Server para o Remote, eh necessario

If File( cPathEst+cFileArq )
	OLE_ExecuteMacro(oWord,"Somalinha")
	OLE_SetDocumentVar(oWord,"Cria_Var",cPathEst+cFileArq)
	OLE_ExecuteMacro(oWord,"Insere_img")
Endif

Return

//---------------------------------------------------------------------
/*/{Protheus.doc} A854ARQUIVO

Funcao para inserir documentos no doc

@author Bruno L. Souza
@since 02/04/2013
@version MP10/11
@return Nil
/*/
//---------------------------------------------------------------------
Static Function A854ARQUIVO(cTitTemp)

Local cFileArq := "", nPos
Local cBarraSrv := "\"

If nModeloImp != 1 //Se nao for em formato WORD, nao imprime
	Return
Endif

If isSRVunix()  //servidor eh da familia Unix (linux, solaris, free-bsd, hp-ux, etc.)
	cBarraSrv := "/"
Endif

nPos := Rat(cBarraSrv,cTitTemp)
If nPos > 0
	cFileArq := AllTrim(Substr(cTitTemp,nPos+1))
Endif

CpyS2T(Alltrim(cTitTemp),cPathEst,.T.) 	// Copia do Server para o Remote, eh necessario

If File( cPathEst+cFileArq )
	OLE_ExecuteMacro(oWord,"Somalinha")
	OLE_SetDocumentVar(oWord,"Cria_Var",cPathEst+cFileArq)
	OLE_ExecuteMacro(oWord,"Insere_doc")
Endif

Return

//---------------------------------------------------------------------
/*/{Protheus.doc} fTipoINSC

Funcao para inserir documentos no doc

@author Bruno L. Souza
@since 02/04/2013
@version MP10/11
@return Nil
/*/
//---------------------------------------------------------------------
Static Function fTipoINSC()

Local cCNPJ := ""
Local cTipoInsc := ""

If !Empty(SM0->M0_CGC)
	If SM0->M0_TPINSC != 2
		cCNPJ := Transform(SM0->M0_CGC,"@R 99.999.99999/99")
		cTipoInsc := STR0051 //"C.G.C. : "
	Else
		cCNPJ := Transform(SM0->M0_CGC,"@R 99.999.999/9999-99")//CNPJ
		cTipoInsc := STR0052 //"CNPJ :"
	Endif
Else
	cTipoInsc := STR0051 //"C.G.C. : "
Endif

Return { cTipoInsc , cCNPJ }
//---------------------------------------------------------------------
/*/{Protheus.doc} fReguaPPR

Processa regua

@author Bruno L. Souza
@since 09/04/2013
@version MP10/11
@return Nil
/*/
//---------------------------------------------------------------------
Static Function fReguaPPR( nLenMemo, nPerMemo, nLenAtual )

Local nLenOld := (100 - nPerMemo) * ( nLenMemo / 100 ) //Calcula Len anterior
Local nDiff := nLenOld - nLenAtual
Local nFor,nPercent

If nDiff > 0
	//Porcentagem que processou neste Loop
	nPercent := Round( (100 / nLenMemo) * nDiff , 0 )
	//Porcentagem processada
	nPerMemo += nPercent
	If nPercent >= 1 .and. nPercent <= 100
		For nFor := 1 To nPercent
			IncRegua()
		Next nFor
	Endif
Endif

Return

//---------------------------------------------------------------------
/*/{Protheus.doc} A854PprFun

Imprime atalho PPR - Funcionarios.

@author Bruno L. Souza
@since 24/04/2013
@version MP11
@return Nil
/*/
//---------------------------------------------------------------------
Function A854PprFun()

Local cLaudo := If(lSIGAMDTPS,MV_PAR03,MV_PAR01)
Local cProgSaude, cNome, cCPF, cCodSet, cCargo
Local cCodFun, cDescFun, cDescSet, cMat, cDepto, cDeparta
Local nF
Local nFuncPPR := 1
Local cFuncPPR := ""
Local aFunc    := {}
Local oBrush1  := TBrush():New( , RGB(229,229,229) ) // Objeto que preenche campos coloridos, Modelo Grafico.
Local lDepto := NGCADICBASE( "TN0_DEPTO", "A" , "TN0" , .F. )

dbSelectArea("TIA")
If dbSeek(xFilial("TIA")+cLaudo)
	While !Eof() .And. TIA->TIA_LAUDO == cLaudo
		cProgSaude := TIA->TIA_CODPRO
		dbSelectArea("TMN")
		dbSetOrder(1)
		If dbSeek(xFilial("TMN")+Alltrim(cProgSaude))
			While !Eof() .And. TMN->TMN_CODPRO == cProgSaude
				cMat     := NGSEEK("TM0", TMN_NUMFIC ,1,'TM0->TM0_MAT') //Matrícula
				cNome    := NGSEEK("SRA", cMat ,1,'SRA->RA_NOME') //Nome
				cCPF     := NGSEEK("SRA", cMat ,1,'SRA->RA_CIC') //CPF
				cCodFun  := NGSEEK("SRA", cMat ,1,'SRA->RA_CODFUNC') //Código da Função
				cDescFun := NGSEEK("SRJ", cCodFun ,1,'SRJ->RJ_DESC') //Descrição da Função
				cCargo   := NGSEEK("SRA", cMat ,1,'SRA->RA_CARGO') // Código do Cargo
				cDescCar := NGSEEK("SQ3", cCargo ,1,'SQ3->Q3_DESCSUM') //Descrição do Cargo
				cCodSet  := NGSEEK("TM0", TMN_NUMFIC ,1,'TM0->TM0_CC') //Código do Centro de Custo
				cDescSet := NGSEEK("CTT", cCodSet ,1,'CTT_DESC01') //Descrição do Centro de Custo
				If lDepto
					cDeparta	:= NGSEEK("SRA", cMat ,1,'SRA->RA_DEPTO') //Código do Departamento
					cDepto 	:= NGSEEK("SQB", cDeparta ,1,'SQB->QB_DESCRIC') //Descrição do Departamento
				EndIf
				If !Empty(cMat) .And. lDepto
					aAdd( aFunc , { cLaudo, cNome, cCPF, cDescFun, cDescCar, cDescSet, cDepto } )
				ElseIf !Empty(cMat)
					aAdd( aFunc , { cLaudo, cNome, cCPF, cDescFun, cDescCar, cDescSet } )
				EndIf
				dbSkip()
			End
		EndIf
		dbSkip()
	End
EndIf

If Len(aFunc) < 1
	Return .F.
EndIf

If nModeloImp == 1
	cFuncPPR += STR0053 + "#*"
	cFuncPPR += STR0054 + "#*"
	cFuncPPR += STR0055 + "#*"
	cFuncPPR += STR0056 + "#*"
	If lDepto .And. Mv_par05 == 2 //Departamento
		cFuncPPR += STR0136 + "#*"
	Else
	cFuncPPR += STR0057 + "#*"
	ENdif
EndIf

For nF := 1 To Len(aFunc)
    If nModeloImp == 1
	    cFuncPPR += AllTrim( aFunc[nF][2] ) + "#*"
		cFuncPPR += AllTrim( aFunc[nF][3] ) + "#*"
		cFuncPPR += AllTrim( aFunc[nF][4] ) + "#*"
		cFuncPPR += AllTrim( aFunc[nF][5] ) + "#*"
		If lDepto .And. Mv_par05 == 2
			cFuncPPR += AllTrim( aFunc[nF][7] ) + "#*"
		Else
		cFuncPPR += AllTrim( aFunc[nF][6] ) + "#*"
		EndIf
		nFuncPPR++
    ElseIf nModeloImp == 2
		/*
		********************************************************************************************
		0         1         2         3         4         5         6         7         8         9
		01234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901
		********************************************************************************************
		Nome do Funcionário        CPF          Função            Cargo          Centro de Custo
		xxxxxxxxxxxxxxxxxxxxxxxxx  xxxxxxxxxxx  xxxxxxxxxxxxxxxx  xxxxxxxxxxxxx  xxxxxxxxxxxxxxxxx
		xxxxxxxxxxxxxxxxxxxxxxxxx  xxxxxxxxxxx  xxxxxxxxxxxxxxxx  xxxxxxxxxxxxx  xxxxxxxxxxxxxxxxx
		xxxxxxxxxxxxxxxxxxxxxxxxx  xxxxxxxxxxx  xxxxxxxxxxxxxxxx  xxxxxxxxxxxxx  xxxxxxxxxxxxxxxxx
		*/
		If nF == 1
			Somalinha()
			@ Li,000 PSay STR0053 //"Nome do Funcionário"
			@ Li,027 PSay STR0054 //"CPF"
			@ Li,040 PSay STR0055 //"Função"
			@ Li,058 PSay STR0056 //"Cargo"
			If lDepto .And. Mv_par03 == 2
				@ Li,073 PSay STR0136 //"Departamento"
			Else
				@ Li,073 PSay STR0057 //"Centro de Custo"
			EndIf
		EndIf
		Somalinha()
		@ Li,000 PSay SubStr(aFunc[nF][2],1,25)
		@ Li,027 PSay aFunc[nF][3]
		@ Li,040 PSay SubStr(aFunc[nF][4],1,17)
		@ Li,058 PSay SubStr(aFunc[nF][5],1,13)
		If lDepto .And. Mv_par03 == 2
			@ Li,073 PSay SubStr(aFunc[nF][7],1,17)
		Else
			@ Li,073 PSay SubStr(aFunc[nF][6],1,17)
		EndIf
	ElseIf nModeloImp == 3
		If nF == 1
			If lin+120 > 3000
				Somalinha(120)
			EndIf
			Somalinha()
			oPrintPPR:FillRect({lin, 150, lin+60 , 2370}, oBrush1 )
			oBrush1:End()
			oPrintPPR:Box(lin,150,lin+60,2370)
			oPrintPPR:Line(lin,700,lin+60,700)
			oPrintPPR:Line(lin,940,lin+60,940)
			oPrintPPR:Line(lin,1470,lin+60,1470)
			oPrintPPR:Line(lin,1870,lin+60,1870)
			oPrintPPR:Say(lin+10,260,STR0053,oFont08b) //"Nome do Funcionário"
			oPrintPPR:Say(lin+10,790,STR0054,oFont08b) //"CPF"
			oPrintPPR:Say(lin+10,1020,STR0055,oFont08b) //"Função"
			oPrintPPR:Say(lin+10,1500,STR0056,oFont08b) //"Cargo"
			If lDepto .And. Mv_par03 == 2
				oPrintPPR:Say(lin+10,2060,STR0136,oFont08b) //"Departamento"
			Else
			oPrintPPR:Say(lin+10,2060,STR0057,oFont08b) //"Centro de Custo"
			Endif
		EndIf
		Somalinha()
	 	If lin == 300
			oPrintPPR:Line(lin,150,lin,2370)
		EndIf
		oPrintPPR:Line(lin,150,lin+60,150)
		oPrintPPR:Line(lin,700,lin+60,700)
		oPrintPPR:Line(lin,940,lin+60,940)
		oPrintPPR:Line(lin,1470,lin+60,1470)
		oPrintPPR:Line(lin,1870,lin+60,1870)
		oPrintPPR:Line(lin,2370,lin+60,2370)
		oPrintPPR:Line(lin+60,150,lin+60,2370)

		oPrintPPR:Say(lin+10,170,SubStr(aFunc[nF][2],1,25),oFont08)
		oPrintPPR:Say(lin+10,720,aFunc[nF][3],oFont08)
		oPrintPPR:Say(lin+10,960,SubStr(aFunc[nF][4],1,17),oFont08)
		oPrintPPR:Say(lin+10,1490,SubStr(aFunc[nF][5],1,13),oFont08)
		If lDepto .And. Mv_par03 == 2
			oPrintPPR:Say(lin+10,1890,SubStr(aFunc[nF][7],1,17),oFont08)
		Else
		oPrintPPR:Say(lin+10,1890,SubStr(aFunc[nF][6],1,17),oFont08)
	EndIf
	EndIf
Next nF

If nModeloImp == 1
	OLE_ExecuteMacro(oWord,"Somalinha")
	OLE_ExecuteMacro(oWord,"Somalinha")
	OLE_SetDocumentVar(oWord,"Tabela",cFuncPPR)
	OLE_SetDocumentVar(oWord,"Linhas",nFuncPPR)
	OLE_ExecuteMacro(oWord,"Table_Func_PPR")
	OLE_ExecuteMacro(oWord,"Somalinha")
 	OLE_ExecuteMacro(oWord,"Somalinha")
Else
	Somalinha()
EndIf

Return

//---------------------------------------------------------------------
/*/{Protheus.doc} A854PPRXPE

Imprime atalho PPRXPE.

@author Bruno L. Souza
@since 29/04/2013
@version MP11
@return Nil
/*/
//---------------------------------------------------------------------
Static Function A854PPRXPE()

Local aArea := GetArea()
Local cMemo := ""
Local nRegs := 0
Local LinhaCorrente := 0
Local oBrush1  := TBrush():New( , RGB(229,229,229) ) // Objeto que preenche campos coloridos, Modelo Grafico.

If nModeloImp == 1 //Modelo de impressão .doc
	dbSelectArea( "TJG" )
	dbSetOrder( 1 )
		If dbSeek( xFilial( "TJG" ) + TO0->TO0_LAUDO )
			//Impressao do título de Plano Emergencial
			cVar1 := "cTXT"+Strzero(nVar1,6)
			OLE_SetDocumentVar(oWord,"Cria_Var",cVar1)
			nVar1++
			OLE_ExecuteMacro  (oWord , "Somalinha")
			OLE_ExecuteMacro  (oWord , "Cria_Texto")
			OLE_SetDocumentVar(oWord , cVar1,STR0058) // "PLANO EMERGENCIAL:"
			OLE_ExecuteMacro  (oWord , "Somalinha")
			While TJG->( !Eof() ) .And. TJG->TJG_FILIAL == xFilial( "TJG" ) .And. ;
				TJG->TJG_LAUDO == TO0->TO0_LAUDO
				dbSelectArea("TJK")
				dbSetOrder(1)//TJK_FILIAL+TJK_CODPLA
				dbSeek(xFilial("TJK") + TJG->TJG_CODPLA )
				nRegs := 0
				cMemo += STR0058+"#*"+TJK->TJK_CODPLA+" - "+Capital(TJK->TJK_DESPLA)+"#*" //"Código" - "Descrição"
				nRegs ++
				cMemo += STR0059+":"+"#*"  + Capital(NGSEEK("SRA",TJK->TJK_ELABOR,1,"RA_NOME"))+"#*" //"Elaborador:"
				nRegs ++
				cMemo += STR0060+":"+"#*" + Capital(NGSEEK("SRA",TJK->TJK_RESPON,1,"RA_NOME"))+"#*" //"Responsável:"
		   		nRegs ++
		   		If !Empty(TJK->TJK_OBSPLA)
		   			cMemo += STR0061+":"+"#*" + Capital(TJK->TJK_OBSPLA)+"#*"//"Observações:"
		   			nRegs ++
		   		Else
		   			cMemo += STR0061+":"+"#*" + ""+"#*"//"Observações:"
		   			nRegs ++
		   		EndIf
		   		cMemo += STR0062+":"+"#*" + Capital(TAF->TAF_NOMNIV) + "#*" //"Processos:"
		    	nRegs ++

		     	dbSelectArea("TJS") // "Ações:"
		   		dbSetOrder(1) //TJS_FILIAL+TJS_CODPLA+TJS_CODACA
		   		dbGoTop()
		   		dbSeek(xFilial("TJS")+TJK->TJK_CODPLA)
		   		// Percorre a Tabela TJS e imprime as acoes.
		   		While !Eof() .And. TJS->TJS_FILIAL == xFilial("TJS") .And. TJS->TJS_CODPLA == TJK->TJK_CODPLA
			   		nRegs ++
			   		cMemo += STR0063+":"+"#*"+Alltrim(TJS->TJS_CODACA)+" - "+Alltrim(TJS->TJS_DESACA)+"#*" //"Ações:"
			   		dbSelectArea("TJS")
			      	dbSkip()
				EndDo

		    	// Percorre a Tabela TJT e imprime os Participantes.
			   	dbSelectArea("TJT")
			   	dbSetOrder(1) //TJT_FILIAL+TJT_CODPLA+TJT_CODPAR
			   	dbGoTop()
			   	dbSeek(xFilial("TJT")+TJK->TJK_CODPLA)
			   	While !Eof() .And. TJT->TJT_FILIAL == xFilial("TJT") .And. TJT->TJT_CODPLA == TJK->TJK_CODPLA
			   		nRegs ++
			   		cMemo += STR0064+":"+"#*"+Alltrim(TJT->TJT_CODPAR)+" - "+NGSEEK("SRA",TJT->TJT_CODPAR,1,"RA_NOME")+"#*" //"Participantes:"
			      	dbSelectArea("TJT")
			      	dbSkip()
		  		EndDo

				// Percorre a Tabela TJW e imprime os Contatos Externos.
				dbSelectArea("TJW")
				dbSetOrder(1) //TJW_FILIAL+TJW_CODPLA+TJW_CODCON
				dbGoTop()
				dbSeek(xFilial("TJW")+TJK->TJK_CODPLA)
				If !Empty(TJW->TJW_CODPLA)
					While !Eof() .And. TJW->TJW_FILIAL == xFilial("TJW") .And. TJW->TJW_CODPLA == TJK->TJK_CODPLA
						nRegs ++
						cMemo += STR0065+":"+"#*"+Alltrim(TJW->TJW_CODCON)+" - "+Alltrim(TJW->TJW_DESCON)+Space(05)+STR0026+Alltrim(TJW->TJW_FONE)+"#*" //"Contatos Externos:" -  "Fone:"
						dbSelectArea("TJW")
						dbSkip()
					EndDo
				Else
					nRegs ++
					cMemo += STR0065+":"+"#*"+""+"#*" //"Contatos Externos:" -  "Fone:"
				EndIf

				cVar1 := "cTXT"+Strzero(nVar1,6)
				OLE_SetDocumentVar(oWord,"Cria_Var",cVar1)
				nVar1++
				OLE_ExecuteMacro   ( oWord , "Somalinha"	)
				OLE_SetDocumentVar ( oWord , "Tabela",cMemo	)
				OLE_SetDocumentVar ( oWord , "Linhas",nRegs	)
				OLE_ExecuteMacro   ( oWord , "Table_PPRXPE" ) // Cria tabela do PPR x Plano Emergencial.
				OLE_ExecuteMacro   ( oWord , "Somalinha"	)
				cMemo := ""
				dbSelectArea( "TJG" )
				TJG->( dbSkip() )
			EndDo
	EndIf
ElseIf nModeloImp == 2  //Modelo de impressão padrão.
	dbSelectArea( "TJG" )
	dbSetOrder( 1 )
		If dbSeek( xFilial( "TJG" ) + TO0->TO0_LAUDO )
			@ Li,000 Psay STR0058 //"PLANO EMERGENCIAL:"
   			SomaLinha()
			While TJG->( !Eof() ) .And. TJG->TJG_FILIAL == xFilial( "TJG" ) .And. ;
				TJG->TJG_LAUDO == TO0->TO0_LAUDO
				dbSelectArea("TJK")
				dbSetOrder(1)//TJK_FILIAL+TJK_CODPLA
				dbSeek(xFilial("TJK") + TJG->TJG_CODPLA )
				SomaLinha()
				@ Li,005 Psay STR0058 //"Plano Emergencial:"
				@ Li,025 Psay Capital(TJK->TJK_CODPLA)//"Plano Emergencial:"
			   	@ Li,032 Psay " - " //" - "
			   	@ Li,035 Psay Capital(TJK->TJK_DESPLA)//"Plano Emergencial:"
			   	SomaLinha()
			   	@ Li,005 Psay STR0059+":" //"Elaborador:"
			   	@ Li,025 Psay Capital(NGSEEK("SRA",TJK->TJK_ELABOR,1,"RA_NOME"))//"Elaborador:"
			   	SomaLinha()
			   	@ Li,005 Psay STR0060+":" //"Responsável:"
			   	@ Li,025 Psay Capital(NGSEEK("SRA",TJK->TJK_RESPON,1,"RA_NOME"))//"Responsável:"
			   	SomaLinha()
		   		If !Empty(TJK->TJK_OBSPLA)
					nLinhasMemo := MLCOUNT(TJK->TJK_OBSPLA,100)
			   		@ Li,005 Psay STR0061+":" //"Observações:"
					For LinhaCorrente := 1 To nLinhasMemo
		   		  		@ Li,025 Psay MemoLine(TJK->TJK_OBSPLA,100,LinhaCorrente) //"Observações:"
		   		   		SomaLinha()
		   	   		Next
		   		Else
		   	   		@ Li,005 Psay STR0061+":" //"Observações:"
		   	   		SomaLinha()
		   		EndIf
		   		@ Li,005 Psay STR0062+":" //"Processos:"
		   		@ Li,025 Psay Capital(TAF->TAF_NOMNIV)//"Processos:"
		   		SomaLinha()
		      	//ACOES
				@ Li,005 Psay STR0063+":" //"Ações:"
				dbSelectArea("TJS")
				dbSetOrder(1)//TJS_FILIAL+TJS_CODPLA+TJS_CODACA
				dbGoTop()
				If dbSeek(xFilial("TJS")+TJK->TJK_CODPLA)
					While !Eof() .And. TJS->TJS_FILIAL == xFilial("TJS") .And. TJS->TJS_CODPLA == TJK->TJK_CODPLA
			   	   		@ Li,025 Psay Capital(TJS->TJS_CODACA)+" - "+Capital(TJS->TJS_DESACA)
			  			SomaLinha()
			     		dbSelectArea("TJS")
			       		dbSkip()
			    		Loop
					EndDo //Finaliza While que percorre a Tabela (TJS)
				Else
					SomaLinha()
				Endif
		      	//PARTICIPANTES
				@ Li,005 Psay STR0064+":" //"Participantes:"
				dbSelectArea("TJT")
				dbSetOrder(1) //TJT_FILIAL+TJT_CODPLA+TJT_CODPAR
				dbGoTop()
				If dbSeek(xFilial("TJT")+TJK->TJK_CODPLA)
					While !Eof() .And. TJT->TJT_FILIAL == xFilial("TJT") .And. TJT->TJT_CODPLA == TJK->TJK_CODPLA
			   			@ Li,025 Psay Capital(TJT->TJT_CODPAR)+" - "+Capital(NGSEEK("SRA",TJT->TJT_CODPAR,1,"RA_NOME")) //"Participantes:"
			   			SomaLinha()
			  			dbSelectArea("TJT")
			   			dbSkip()
			   			Loop
			  		EndDo //Finaliza While que percorre a Tabela (TJT)
			  	Else
			  		SomaLinha()
			  	Endif
		      	//CONTATOS EXTERNOS
		      	@ Li,005 Psay STR0065+":" //"Contatos Externos:"
				dbSelectArea("TJW")
				dbSetOrder(1)//TJW_FILIAL+TJW_CODPLA+TJW_CODCON
				dbGoTop()
				dbSeek(xFilial("TJW")+TJK->TJK_CODPLA)
				While !Eof() .And. TJW->TJW_FILIAL == xFilial("TJW") .And. TJW->TJW_CODPLA == TJK->TJK_CODPLA
		   			@ Li,025 Psay Capital(TJW->TJW_CODCON)+" - "+Capital(TJW->TJW_DESCON)
		    		@ Li,085 Psay STR0026+":  "+Capital(TJW->TJW_FONE) //"Fone"
		   			SomaLinha()
		   			dbSelectArea("TJW")
		   			dbSkip()
					Loop
				EndDo //Finaliza While que percorre a Tabela (TJW)
				SomaLinha()
				dbSelectArea( "TJG" )
				TJG->( dbSkip() )
	   		EndDo //Finaliza While que percorre a Tabela (TJG)
   	EndIf
ElseIf nModeloImp == 3  //Modelo de impressão gráfico.
	dbSelectArea( "TJG" )
	dbSetOrder(1)
		If dbSeek( xFilial( "TJG" ) + TO0->TO0_LAUDO )
			SomaLinha()
			oPrintPPR:Say(lin,165,STR0058,oFont10) //"PLANO EMERGENCIAL"
			SomaLinha()
			While TJG->( !Eof() ) .And. TJG->TJG_FILIAL == xFilial( "TJG" ) .And. ;
				TJG->TJG_LAUDO == TO0->TO0_LAUDO
				dbSelectArea("TJK")
				dbSetOrder(1)//TJK_FILIAL+TJK_CODPLA
				dbSeek(xFilial("TJK") + TJG->TJG_CODPLA )
				If lin+120 > 3000
					Somalinha(120)
				EndIf
				Somalinha()
				oPrintPPR:FillRect({lin, 150, lin+60 , 2300}, oBrush1 )
				oBrush1:End()
			 	oPrintPPR:Box  ( lin , 150  , lin+60  , 2300     ) // Monta tabela
				oPrintPPR:line ( lin , 600  , lin+60  , 600      ) // Linha Vertical que separa os campos
				oPrintPPR:Say  ( lin , 300  , STR0067 , oFont10b ) // "Campo"
				oPrintPPR:Say  ( lin , 1250 , STR0068 , oFont10b ) // "Conteudo"
				Somalinha()
				oPrintPPR:Box  ( lin , 150 , lin+60 						  	   , 2300     ) // Monta tabela
			   	oPrintPPR:line ( lin , 600 , lin+60  						  	   , 600      ) // Linha Vertical que separa os campos
			   	oPrintPPR:Say  ( lin , 165 , STR0058 	  				           , oFont10b ) // "Plano Emergencial:"
			   	oPrintPPR:Say  ( lin , 620 , Capital(TJK->TJK_CODPLA) 			   , oFont10  ) // "Código"
			   	oPrintPPR:Say  ( lin , 770 , STR0066						  	   , oFont10  )
			   	oPrintPPR:Say  ( lin , 920 , Capital(Substr(TJK->TJK_DESPLA,1,50)) , oFont10  ) // "Descrição"
			   	Somalinha()
			   	//Elaborador
				oPrintPPR:Box  ( lin , 150 , lin+60 						  					, 2300     	) // Monta tabela
			   	oPrintPPR:line ( lin , 600 , lin+60  						  					, 600      	) // Linha Vertical que separa os campos
			   	oPrintPPR:Say  ( lin , 165 , STR0059+":"	   				  					, oFont10b 	) // "Elaborador:"
			   	oPrintPPR:Say  ( lin , 620 , Capital(NGSEEK("SRA",TJK->TJK_ELABOR,1,"RA_NOME")) , oFont10 	) // "Elaborador:"
			   	Somalinha()
			   	//Responsavel
			   	oPrintPPR:Box  ( lin , 150 , lin+60 						  					, 2300     	) // Monta tabela
			   	oPrintPPR:line ( lin , 600 , lin+60  						  					, 600      	) // Linha Vertical que separa os campos
			   	oPrintPPR:Say  ( lin , 165 , STR0060+":"										, oFont10b	) // "Responsável:"
			   	oPrintPPR:Say  ( lin , 620 , Capital(NGSEEK("SRA",TJK->TJK_RESPON,1,"RA_NOME")) , oFont10 	) // "Responsável:"
			   	Somalinha()
				//Observações
				If !Empty(TJK->TJK_OBSPLA)
					nLinhasMemo := MLCOUNT(TJK->TJK_OBSPLA,75)
			   		oPrintPPR:Say	 ( lin , 165 , STR0061+":" , oFont10b ) // "Observações:"
					For LinhaCorrente := 1 To nLinhasMemo
		   				oPrintPPR:Say  ( lin , 620  , MemoLine(TJK->TJK_OBSPLA,75,LinhaCorrente),oFont10 )
		    			oPrintPPR:Line ( lin , 150  , lin+60 , 150  ) // Coluna Inicial
						oPrintPPR:Line ( lin , 2300 , lin+60 , 2300 ) // Coluna Final
		    	  		oPrintPPR:line ( lin , 600  , lin+60 , 600  ) // Linha Vertical que separa os campos
		    	  		SomaLinha()
					Next
				Else
					oPrintPPR:Say  ( lin , 165 , STR0061+":" , oFont10b ) // "Observações:"
					oPrintPPR:Box  ( lin , 150 , lin+60  , 2300     ) // Monta tabela
		   	   		oPrintPPR:line ( lin , 600 , lin+60  , 600      ) // Linha Vertical que separa os campos
					SomaLinha()
				EndIf
			   	//Processos
			   	oPrintPPR:Box  ( lin , 150 , lin+60 				  , 2300     ) // Monta tabela
			   	oPrintPPR:line ( lin , 600 , lin+60  				  , 600      ) // Linha Vertical que separa os campos
			   	oPrintPPR:Say  ( lin , 165 , STR0062+":" 			  , oFont10b ) // "Processos:"
			   	oPrintPPR:Say  ( lin , 620 , Capital(TAF->TAF_NOMNIV) , oFont10  ) // "Processos:"
		  		Somalinha()
		      	//Acoes
				dbSelectArea("TJS")
				dbSetOrder(1) //TJS_FILIAL+TJS_CODPLA+TJS_CODACA
				dbGoTop()
				If dbSeek(xFilial("TJS")+TJK->TJK_CODPLA)
					oPrintPPR:Say ( lin , 165 , STR0063+":" , oFont10b ) // "Ações:"
					While !Eof() .And. TJS->TJS_FILIAL == xFilial("TJS") .And. TJS->TJS_CODPLA == TJK->TJK_CODPLA
						oPrintPPR:Box  ( lin , 150 , lin+60 						  	   , 2300    ) // Monta tabela
					   	oPrintPPR:line ( lin , 600 , lin+60  						  	   , 600     ) // Linha Vertical que separa os campos
					   	oPrintPPR:Say  ( lin , 620 , Capital(TJS->TJS_CODACA) 			   , oFont10 ) // "Ações:"
					   	oPrintPPR:Say  ( lin , 770 , " - " 						  		   , oFont10 )
					   	oPrintPPR:Say  ( lin , 840 , Capital(Substr(TJS->TJS_DESACA,1,50)) , oFont10 ) // "Ações:"
					   	Somalinha()
						dbSelectArea("TJS")
						dbSkip()
						Loop
					EndDo //Finaliza While que percorre a Tabela (TJS)
				Endif
				//Participantes
				dbSelectArea("TJT")
				dbSetOrder(1) //TJT_FILIAL+TJT_CODPLA+TJT_CODPAR
				dbGoTop()
				If dbSeek(xFilial("TJT")+TJK->TJK_CODPLA)
					oPrintPPR:Say ( lin , 165 , STR0064+":" , oFont10b ) // "Participantes:"
					While !Eof() .And. TJT->TJT_FILIAL == xFilial("TJT") .And. TJT->TJT_CODPLA == TJK->TJK_CODPLA
						oPrintPPR:Box  ( lin , 150 , lin+60 						  					, 2300     	) // Monta tabela
					   	oPrintPPR:line ( lin , 600 , lin+60  						  					, 600      	) // Linha Vertical que separa os campos
					   	oPrintPPR:Say  ( lin , 620 , Capital(TJT->TJT_CODPAR) 						    , oFont10  	) // "Participantes:"
					   	oPrintPPR:Say  ( lin , 770 , " - "   						  					, oFont10  	)
					   	oPrintPPR:Say  ( lin , 840 , Capital(NGSEEK("SRA",TJT->TJT_CODPAR,1,"RA_NOME")) , oFont10 	) // "Participantes:"
					   	Somalinha()
						dbSelectArea("TJT")
						dbSkip()
						Loop
					EndDo //Finaliza While que percorre a Tabela (TJT)
				Endif
			   	//Contatos Externos
				dbSelectArea("TJW")
				dbSetOrder(1) //TJW_FILIAL+TJW_CODPLA+TJW_CODCON
				dbGoTop()
				dbSeek(xFilial("TJW")+TJK->TJK_CODPLA)
				If !Empty(TJW->TJW_CODPLA) // Se o existir conteudo no campo de Contatos Externos, o mesmo sera impresso.
					oPrintPPR:Say ( lin , 165 , STR0065+":" , oFont10b ) // "Contatos Externos:"
					While !Eof() .And. TJW->TJW_FILIAL == xFilial("TJW") .And. TJW->TJW_CODPLA == TJK->TJK_CODPLA
						oPrintPPR:Box  ( lin , 150  , lin+60 					 			, 2300     ) // Monta tabela
					   	oPrintPPR:line ( lin , 600  , lin+60					 			, 600      ) // Linha Vertical que separa os campos
					   	oPrintPPR:Say  ( lin , 620  , Capital(TJW->TJW_CODCON) 			    , oFont10  ) // "Contatos Externos:"
					   	oPrintPPR:Say  ( lin , 770  , " - " 					 			, oFont10  )
					   	oPrintPPR:Say  ( lin , 840  , Capital(Substr(TJW->TJW_DESCON,1,27)) , oFont10  ) // "Contatos Externos:"
					   	oPrintPPR:Say  ( lin , 1745 , STR0026+":"					 		, oFont10  ) // "Fone"
					   	oPrintPPR:Say  ( lin , 1842 , Capital(TJW->TJW_FONE)   				, oFont10  ) // "Fone"
					   	Somalinha()
						dbSelectArea("TJW")
						dbSkip()
						Loop
					EndDo //Finaliza While que percorre a Tabela (TJW)
				Else //Senao sera impresso apenas a Descricao do campo.
					oPrintPPR:Say  ( lin , 165  , STR0065+":" , oFont10b ) // "Contatos Externos:"
					oPrintPPR:Box  ( lin , 150  , lin+60  , 2300     ) // Monta tabela
					oPrintPPR:line ( lin , 600  , lin+60  , 600      ) // Linha Vertical que separa os campos
					oPrintPPR:Say  ( lin , 1745 , STR0026+":" , oFont10  ) // "Fone"
					Somalinha()
				EndIf
				SomaLinha()
				dbSelectArea("TJG")
				TJG->( dbSkip() )
			EndDo //Finaliza While que percorre a Tabela (TJG)
	EndIf
EndIf
RestArea( aArea )

Return

//---------------------------------------------------------------------
/*/{Protheus.doc} A854CNTRLE

Imprime atalho CONTROLE.

@author Bruno L. Souza
@since 29/04/2013
@version MP11
@return Nil
/*/
//---------------------------------------------------------------------
Static Function A854CNTRLE()

Local aArea  := GetArea()
Local nPrint := 0
If lSigaMdtps
	dbSelectArea("TO3")
	dbSetOrder(3)
	dbSeek(xFilial("TO3") + cCliMdtPs + TO0->TO0_LAUDO)
	While !eof() .and. xFilial("TO3")+TO0->TO0_LAUDO == TO3->TO3_FILIAL+TO3->TO3_LAUDO .and. cCliMdtPs == TO3->TO3_CLIENT+TO3->TO3_LOJA
		dbSelectArea("TO4")
		dbSetOrder(1)
		If dbSeek(xFilial("TO4")+TO3->TO3_CONTRO)
			nPrint ++
			lPrint := .T.
			If nPrint == 1
				Somalinha()
			EndIf
			If nModeloImp != 1
				IMPDOC854(Capital(AllTrim(TO4->TO4_NOMCTR))+": "+Alltrim(TO3->TO3_DESCRI))
			Else
				cVar1 := "cTXT"+Strzero(nVar1,6)
				OLE_ExecuteMacro(oWord,"Nao_Identar")
				OLE_SetDocumentVar(oWord,"Cria_Var",cVar1)
				nVar1++
				OLE_ExecuteMacro(oWord,"Somalinha")
				OLE_ExecuteMacro(oWord,"Somalinha")
				OLE_ExecuteMacro(oWord,"Cria_Titulo")
				OLE_ExecuteMacro(oWord,"Com_Negrito")
				OLE_SetDocumentVar(oWord,cVar1,Capital(AllTrim(TO4->TO4_NOMCTR))+": ")

				IMPDOC854(Alltrim(TO3->TO3_DESCRI),.F.,.T.)
			Endif
		Endif
		dbSelectArea("TO3")
		dbSkip()
	End
Else
	dbSelectArea("TO3")
	dbSetOrder(1)
	dbSeek(xFilial("TO3")+TO0->TO0_LAUDO)
	While !eof() .and. xFilial("TO3")+TO0->TO0_LAUDO == TO3->TO3_FILIAL+TO3->TO3_LAUDO
		dbSelectArea("TO4")
		dbSetOrder(1)
		If dbSeek(xFilial("TO4")+TO3->TO3_CONTRO)
			nPrint ++
			lPrint := .T.
			If nPrint == 1
				Somalinha()
			EndIf
			If nModeloImp != 1
				IMPDOC854(Capital(AllTrim(TO4->TO4_NOMCTR))+": "+Alltrim(TO3->TO3_DESCRI))
			Else
				cVar1 := "cTXT"+Strzero(nVar1,6)
				OLE_ExecuteMacro(oWord,"Nao_Identar")
				OLE_SetDocumentVar(oWord,"Cria_Var",cVar1)
				nVar1++
				OLE_ExecuteMacro(oWord,"Somalinha")
				OLE_ExecuteMacro(oWord,"Somalinha")
				OLE_ExecuteMacro(oWord,"Cria_Titulo")
				OLE_ExecuteMacro(oWord,"Com_Negrito")
				OLE_SetDocumentVar(oWord,cVar1,Capital(AllTrim(TO4->TO4_NOMCTR))+": ")

				IMPDOC854(Alltrim(TO3->TO3_DESCRI),.F.,.T.)
			Endif
		Endif
		dbSelectArea("TO3")
		dbSkip()
	End

Endif

RestArea(aArea)
Return .T.
/*---------------------------------------------------------------------
{Protheus.doc} A854EQPRAD

Imprime os Equipamentos Radiologicos

@author Bruno L. Souza
@since 02/04/2013
@version MP11
@return Nil

---------------------------------------------------------------------*/
Static Function A854EQPRAD()

    Local cLaudo := If( lSIGAMDTPS, MV_PAR03, MV_PAR01 )
    Local cEquip, cNomFam, cDesMod, cNomFab
    Local nE, nC
    Local aEquip := {}, aCarac := {}

    dbSelectArea("TI9")
    dbGoTop()
    If dbSeek(xFilial("TI9")+cLaudo)
        While !Eof() .And. xFilial("TI9") == TI9->TI9_FILIAL .And. TI9->TI9_LAUDO == cLaudo
            cEquip := TI9->TI9_CODEQP
            dbSelectArea("ST9")
            dbSetOrder(1)
            If dbSeek(xFilial("ST9")+Alltrim(cEquip))
                cNomFam := NGSEEK("ST6", ST9->T9_CODFAMI, 1, 'ST6->T6_NOME')
                cDesMod := NGSEEK("TQR", ST9->T9_TIPMOD, 1, 'TQR->TQR_DESMOD')
                cNomFab := NGSEEK("ST7", ST9->T9_FABRICA, 1, 'ST7->T7_NOME')
                dbSelectArea("STB")
                dbSetOrder(1)
                If dbSeek(xFilial("STB")+Alltrim(cEquip))
                    aCarac := {}
                    While !Eof() .And. cEquip == STB->TB_CODBEM
                        cNomCarac := NGSEEK("TPR" , STB->TB_CARACTE , 1 , "TPR->TPR_NOME")

							aAdd(aCarac , { STB->TB_CARACTE, cNomCarac, STB->TB_CONDOP, STB->TB_DETALHE,;
                                               STB->TB_INFO02, STB->TB_UNIDADE})

                        dbSelectArea("STB")
                        dbSkip()
                    EndDo
                EndIf
                aAdd( aEquip , { ST9->T9_CODBEM, ST9->T9_NOME, cNomFam, cDesMod, cNomFab, ST9->T9_SERIE, TI9->TI9_DESCRI,aClone(aCarac)} )
            EndIf
            dbSelectArea("TI9")
            dbSkip()
        EndDo
    EndIf

    For nE := 1 To Len(aEquip)
        If nModeloImp == 1
            Somalinha()
            IMPHEA854("{N}"+STR0069,.T.,.F.)
            IMPDOC854(aEquip[nE][1] + " " + aEquip[nE][2],.F.)
            IMPHEA854("{N}"+STR0070,.T.,.F.)
            IMPDOC854(aEquip[nE][3],.F.)
            IMPHEA854("{N}"+STR0071,.T.,.F.)
            IMPDOC854(aEquip[nE][4],.F.)
            IMPHEA854("{N}"+STR0072,.T.,.F.)
            IMPDOC854(aEquip[nE][5],.F.)
            IMPHEA854("{N}"+STR0073,.T.,.F.)
            IMPDOC854(aEquip[nE][6],.F.)
            IMPHEA854("{N}"+"Detalhes",.T.,.F.)
            IMPDOC854(Alltrim(aEquip[nE][7]),.F.,.T.)

            If !Empty(aEquip[nE][8])
                For nC := 1 To Len(aEquip[nE][8])
                    IMPHEA854("{N}" + Capital( Alltrim(aEquip[nE][8][nC][2] ) ), .T., .F.)

                    If Alltrim(aEquip[nE][8][nC][3]) == '1'
                        IMPDOC854( Alltrim(aEquip[nE][8][nC][4]) + " " + Alltrim(aEquip[nE][8][nC][6]), .F.)
                    Else
                        IMPDOC854( Upper( Alltrim( NGRetSX3Box( "TB_CONDOP", aEquip[nE][8][nC][3]) )) + " " +;
                            AllTrim( aEquip[nE][8][nC][4] ) + " ~ " + AllTrim( aEquip[nE][8][nC][5] ) + " " +;
                             AllTrim( aEquip[nE][8][nC][6] ), .F.)
                    EndIf
                Next nC
            EndIf

        ElseIf nModeloImp == 2
            Somalinha()
            @ Li,000 PSay STR0069 + ": " + AllTrim(aEquip[nE][1]) + " - " + STR0074 + " " + aEquip[nE][2] //"Descrição"+"Equipamento"
            Somalinha()
            @ Li,000 PSay STR0070 + "....: " + aEquip[nE][3] //"Familia"
            Somalinha()
            @ Li,000 PSay STR0071 + ".....: " + aEquip[nE][4] //"Modelo"
            Somalinha()
            @ Li,000 PSay STR0072 + "......: " + aEquip[nE][5] //"Marca"
            Somalinha()
            @ Li,000 PSay STR0073 + "......: " + aEquip[nE][6] //"Serie"
            Somalinha()

            If !Empty(aEquip[nE][8])
                For nC := 1 To Len(aEquip[nE][8])
                    //Verifica se a opção é Igual ('1') ou Entre ('2')
                    If Alltrim(aEquip[nE][8][nC][3]) == '1'
                        @ Li,000 PSay ( AllTrim( Capital(aEquip[nE][8][nC][2]) )) + ": " +; // + Space(TAMSX3("TPR_NOME")[1] - Len(aEquip[nE][8][nC][2]))) + " " +;
                            AllTrim ( aEquip[nE][8][nC][4] ) + " " + AllTrim( aEquip[nE][8][nC][6] )
                    Else
                        @ Li,000 PSay ( AllTrim( Capital(aEquip[nE][8][nC][2]) )) + ": " +;//+ Space(TAMSX3("TPR_NOME")[1] - Len(aEquip[nE][8][nC][2]))) + " " + ;
                              Alltrim( NGRetSX3Box( "TB_CONDOP", aEquip[nE][8][nC][3]) ) + " " +;
                               AllTrim( aEquip[nE][8][nC][4] ) + " ~ " + AllTrim( aEquip[nE][8][nC][5] ) + " " +;
                                AllTrim( aEquip[nE][8][nC][6] )
                    EndIf
                    Somalinha()
                Next nC
            EndIf

            IMPDOC854( STR0120 + "...: " + Alltrim(aEquip[nE][7]),.F.,.T.,,,.F.)

            Somalinha()
        ElseIf nModeloImp == 3

            Somalinha()
            oPrintPPR:Say(lin+10,170,STR0069+":",oFont08b) //"Equipamento:"
            oPrintPPR:Say(lin+10,420,AllTrim(aEquip[nE][1]) + " " + aEquip[nE][2],oFont08)

            Somalinha()
            oPrintPPR:Say(lin+10,170,STR0070+".........:",oFont08b) //"Família"
            oPrintPPR:Say(lin+10,420,aEquip[nE][3],oFont08)

            Somalinha()
            oPrintPPR:Say(lin+10,170,STR0071+".........:",oFont08b) //"Modelo"
            oPrintPPR:Say(lin+10,420,aEquip[nE][4],oFont08)

            Somalinha()
            oPrintPPR:Say(lin+10,170,STR0072+"...........:",oFont08b)  //"Marca"
            oPrintPPR:Say(lin+10,420,aEquip[nE][5],oFont08)

            Somalinha()
            oPrintPPR:Say(lin+10,170,STR0073+"............:",oFont08b)  //"Serie"
            oPrintPPR:Say(lin+10,420,aEquip[nE][6],oFont08)

            Somalinha()

            If !Empty(aEquip[nE][8])
                For nC := 1 To Len( aEquip[nE][8] )
                    If Alltrim(aEquip[nE][8][nC][3]) == '1'

                        oPrintPPR:Say( lin + 10, 170, Alltrim( Capital( aEquip[nE][8][nC][2]) ) + ": ", oFont08b)
                        oPrintPPR:Say( lin + 10, 170 + ( (Len(Alltrim(aEquip[nE][8][nC][2] ) ) + 1) * 20 ) + 20, Alltrim(aEquip[nE][8][nC][4]) + " " + aEquip[nE][8][nC][6],oFont08)
                    Else
                        oPrintPPR:Say( lin + 10, 170, Alltrim( Capital( aEquip[nE][8][nC][2]) ) + ": ", oFont08b)
                        oPrintPPR:Say( lin + 10, 170 + ( (Len(Alltrim(aEquip[nE][8][nC][2] ) ) + 1) * 20 ) + 20, Alltrim( NGRetSX3Box( "TB_CONDOP", aEquip[nE][8][nC][3]) ) + " " +;
                            AllTrim( aEquip[nE][8][nC][4] ) + " ~ " + AllTrim( aEquip[nE][8][nC][5] ) + " " +;
                             AllTrim( aEquip[nE][8][nC][6] ) ,oFont08)

                    EndIf

                    Somalinha()
                Next nC
            EndIf

            oPrintPPR:Say(lin+10,170,STR0120+ "......:",oFont08b)  //"Detalhes"

            IMPDOC854(Alltrim(aEquip[nE][7]),.F.,.T.,,270,.F.,oFont08)

            Somalinha()
        EndIf
    Next nE

Return

//---------------------------------------------------------------------
/*/{Protheus.doc} A854ESTLOC

@author Bruno L. Souza
@since 02/05/2013
@version P11
/*/
//---------------------------------------------------------------------
Static Function A854ESTLOC()

Local nQtd	:= 1
Local nEst	:= 0
Local nCmp	:= 0
Local nCol	:= 0
Local nCont	:= 1
Local cMemo := ""
Local lPri	:= .T.
Local aCmp	:= { "TNE_NAT" , "TNE_ESP" , "TNE_UNI" , "TNE_LOC" }
Local aEst	:= { ;
                { "PAR" , STR0098 } , ;
                { "PIS" , STR0099 } , ;
                { "TET" , STR0100 } , ;
                { "POR" , STR0101 } , ;
                { "RE1" , STR0102 } , ;
                { "RE2" , STR0103 } , ;
                { "VIS" , STR0104 } ;
				}
Local aColumms	:= { 20 , 40 , 20 , 0 }
Local aPosInf	:= { 170 , 500 , 830 , 1160 }

Local oBrush1	:= TBrush():New( , RGB(229,229,229) ) // Objeto que preenche campos coloridos, Modelo Grafico.

cMemo += STR0094 + "#*"
	cMemo += STR0095 + "#*"
	cMemo += STR0096 + "#*"
	cMemo += STR0097 + "#*"
	//nQtd++
	dbSelectArea( "TO5" )
	dbSetOrder( 1 )
	dbSeek( xFilial( "TO5" ) + Mv_par01 )
	While TO5->( !Eof() ) .And. TO5->TO5_FILIAL == xFilial( "TO5" ) .And. TO5->TO5_LAUDO == Mv_par01
   		dbSelectArea( "TNE" )
   		dbSetOrder( 1 )
   		dbSeek( xFilial( "TNE" ) + TO5->TO5_CODAMB )
   		SomaLinha()
   		If nModeloImp == 1 // Modelo de ImpressÃ£o .doc (Word.)
			IMPHEA854( "{N}"+STR0093 )
			IMPDOC854( TNE->TNE_NOME )
		ElseIf nModeloImp == 2 // Modelo de Impressão padrão
			SomaLinha()
			@ Li,019 Psay STR0093 // "Ambiente Físico:"
			@ Li,037 Psay TNE->TNE_NOME
		ElseIf nModeloImp == 3 // Modelo de Impressão grafico
			SomaLinha()
			oPrintPPR:Say  ( lin , 165 , STR0093 , oFont10b	) // "Ambiente Físico:"
			oPrintPPR:Say  ( lin , 525 , TNE->TNE_NOME , oFont10 )
			SomaLinha()
		EndIf
        SomaLinha()
        For nEst := 1 To Len( aEst )
        	cMemo += aEst[ nEst , 2 ] + "#*"
        	For nCmp := 1 To Len( aCmp )
        		If "LOC" $ aCmp[ nCmp ] .And. aEst[ nEst , 1 ] == "TET"
        			cMemo += "-|-#*"
        		Else
        			If "NAT" $ aCmp[ nCmp ]
        				cMemo += X3Combo( aCmp[ nCmp ] + aEst[ nEst , 1 ] , &( aCmp[ nCmp ] + aEst[ nEst , 1 ] ) )
        			Else
		        		cMemo += AllTrim( cValToChar( &( aCmp[ nCmp ] + aEst[ nEst , 1 ] ) ) ) + Space( 1 )
		        	EndIf
		        	If !( "ESP" $ aCmp[ nCmp ] )
		        		cMemo += "#*"
		        	EndIf
	        	EndIf
        	Next nCmp
        	nQtd++
        Next nEst
        cMemo := StrTran(cMemo,"#*#*", "#* #*")
		If nModeloImp == 1 // Modelo de ImpressÃ£o .doc (Word.)
   			OLE_ExecuteMacro   ( oWord , "Somalinha"	  	)
			OLE_SetDocumentVar ( oWord , "Tabela",cMemo	  	)
			OLE_SetDocumentVar ( oWord , "Linhas",nQtd		)
			OLE_ExecuteMacro   ( oWord , "Table_Estrutura"	) // Cria tabela no Word de Estrutura por Ambiente Físico.
		ElseIf nModeloImp == 2 .Or. nModeloImp == 3
			While !Empty( cMemo )
				nAt := At( "#*" , cMemo )
				cTextImp := SubStr( cMemo , 1 , nAt - 1 )
				cMemo := SubStr( cMemo , nAt + 2 )
				If nModeloImp == 2
					@ Li,nCol Psay cTextImp
				ElseIf nModeloImp == 3
					aPosInf	:= If(lPri,{ 220 , 550 , 870 , 1560 },{ 170 , 500 , 830 , 1160 })
					If nCont == 1
						If lin+120 > 3000
							Somalinha(120)
						EndIf
						If lPri
							//Destaca linha
						  	oPrintPPR:FillRect({lin, 150, lin+60 , 2300}, oBrush1 )
					   		oBrush1:End()
					   	EndIf
				   		//Monta tabela do cabeçalho
				   		oPrintPPR:Box  ( lin , 150  , lin+60 , 2300 ) // Monta tabela
					  	oPrintPPR:line ( lin , 480  , lin+60 , 480  ) // Linha Vertical que separa os campos
				   		oPrintPPR:line ( lin , 810  , lin+60 , 810  ) // Linha Vertical que separa os campos
				   		oPrintPPR:line ( lin , 1140 , lin+60 , 1140 ) // Linha Vertical que separa os campos
					EndIf
			   		//Comteúdo do cabeçalho
			   		oPrintPPR:Say  ( lin , aPosInf[ nCont ]  , cTextImp	, If( lPri , oFont10b , oFont10) )
				EndIf
				nCol += aColumms[ nCont ]
				nCont++
				If nCont > 4
					lPri := .F.
					SomaLinha()
					nCol := 000
					nCont := 1
				EndIf
			End
   		EndIf
   		nQtd  := 1
   		cMemo := ""
   		cMemo += STR0094 + "#*"
		cMemo += STR0095 + "#*"
		cMemo += STR0096 + "#*"
		cMemo += STR0097 + "#*"
		lPri  := .T.
	 	TO5->( dbSkip() )
End

Return
//---------------------------------------------------------------------
/*/{Protheus.doc} A854QUATRE
	- Funcao que imprime em Relatorio de Quadro de Requisitos x Treinamento

	- Foi adicionado um novo Atalho (Quadro de Requisitos x Treinamento) na rotina, MDTA210a.prx
	  para impressao no PPRA e PPR
	- Quando este atalho for incluido no Laudo, serao impressos os quadros conforme
	  modelos abaixo:

	  nModeloImp == 1 -> MODELO WORD
	  nModeloImp == 2 -> MODELO PADRAO
	  nModeloImp == 3 -> MODELO GRAFICO

@author Felipe Helio dos Santos
@since 31/03/2013
@version P10/P11
/*/
//---------------------------------------------------------------------
Static Function A854QUATRE()

	Local aArea := GetArea(), aAreaReq := GetArea()
	Local aEmenta := {}, aTreino := {}, aRequisito := {}
	Local nLinCorre, nLinhaMemo, nPosEme, nPosTre, nMax, i, nY, nX, nZ, nJ, nI, nReg := 1
	Local cEmenta := "", cTreino := "", cMemo := "", cEme := ""
	Local oBrush1 := TBrush():New( , RGB(229,229,229) ) // Objeto que preenche campos coloridos, Modelo Gráfico.

	dbSelectArea("TJA")
	dbSetOrder(01)
	dbSeek(xFilial("TJA")+MV_PAR01)

	While !EOF() .And. xFilial("TJA") == TJA->TJA_FILIAL .And. MV_PAR01 = TJA->TJA_LAUDO

		aAreaReq := GetArea()
		dbSelectArea("TJE")
		dbSetOrder(01)
		dbSeek(xFilial("TJE")+TJA->TJA_CODLEG)

		While !EOF() .And. xFilial("TJE") == TJE->TJE_FILIAL .And. TJE->TJE_CODLEG == TJA->TJA_CODLEG
			aAdd(aTreino,Alltrim(Capital(NGSEEK("RA2",TJE->TJE_CALEND,1,"RA2->RA2_DESC"))))
			dbSelectArea("TJE")
			dbSkip()
		EndDo
		RestArea(aAreaReq)

		dbSelectArea("TA0")
		dbSetOrder(01)
		dbSeek(xFilial("TA0")+TJA->TJA_CODLEG)

		aAdd(aRequisito, {TA0->TA0_CODLEG,Lower(TA0->TA0_EMENTA),TA0->TA0_DTVIGE,;
							TA0->TA0_TIPO,	NGRETSX3BOX("TA0_ORIGEM",TA0->TA0_ORIGEM),aTreino})
 		aTreino := {}

		dbSelectArea("TJA")
		dbSkip()

	EndDo

	For i := 1 To Len(aRequisito)

		nLinhaMemo := MLCOUNT(aRequisito[i][2],30)
		For nLinCorre := 1 To nLinhaMemo		//Tratamento Campo Ementa
			If !Empty((MemoLine(aRequisito[i][2],30,nLinCorre)))
				aAdd(aEmenta, (MemoLine(aRequisito[i][2],30,nLinCorre)))
			Endif
		Next nLinCorre

		For nY := 1 To Len(aRequisito[i][6])  //Tratamento Campo Treino
			If !Empty(aRequisito[i][6][nY])
				aAdd(aTreino, AllTrim(aRequisito[i][6][nY]))
			EndIf
		Next nY

		nMax := If(Len(aEmenta) > Len(aTreino),nMax := Len(aEmenta),nMax := Len(aTreino))

		If nModeloImp == 1
			If i == 1
				cVar1 := "cTXT"+Strzero(nVar1,6)
				OLE_SetDocumentVar(oWord,"Cria_Var",cVar1)
				nVar1++
				OLE_ExecuteMacro(oWord, "Somalinha")
				OLE_ExecuteMacro(oWord,"Cria_Titulo")
				OLE_ExecuteMacro(oWord,"Com_Negrito")
				OLE_ExecuteMacro(oWord,"Alinhar_Esquerda")
				OLE_SetDocumentVar(oWord, cVar1, "Requisito x Treinamento")
				OLE_ExecuteMacro(oWord, "Somalinha")
				cMemo += STR0110 + "#*" + STR0105 + "#*" + STR0106 + "#*" + STR0107 + "#*" + STR0108+ "#*" + STR0109 + "#*"
			EndIf

			For nJ := 1 To Len(aEmenta)
				cEmenta += aEmenta[nJ] + CRLF
			Next nJ
			For nI := 1 To Len(aTreino)
				cTreino += Capital(aTreino[nI]) + CRLF
			Next nI

			cMemo += aRequisito[i][1]  + "#*"
			cMemo += cEmenta + "#*"
			cMemo += DtoC(aRequisito[i][3])  + "#*"
			cMemo += Capital(aRequisito[i][4]) + "#*"
			cMemo += Capital(aRequisito[i][5]) + "#*"
			cMemo += cTreino + "#*"
			nReg++
			aEmenta := {}
			aTreino := {}
			cEmenta := ""
			cTreino := ""
		ElseIf nModeloImp == 2
			If i == 1
				SomaLinha()
				@ Li,00  Psay STR0110
				@ Li,15  Psay STR0105
				@ Li,47  Psay STR0106
				@ Li,59  Psay STR0107
				@ Li,73  Psay STR0108
				@ Li,86  Psay STR0109
				SomaLinha()
			EndIf
			@ Li,00  Psay aRequisito[i][1]
	   		@ Li,47  Psay aRequisito[i][3]
	   		@ Li,59  Psay Capital(aRequisito[i][4])
	   		@ Li,73  Psay Capital(aRequisito[i][5])
			If nMax >= 1
				For nX := 1 To nMax
					If Len(aEmenta) >= nX
						nPosEme := If(nX == 1,16,15)
						cEme := If(nX==1,Capital(aEmenta[nX]),aEmenta[nX])
						@ Li,nPosEme  Psay AllTrim(cEme)
					EndIf
					If Len(aTreino) >= nX
						nPosTre := If(nX == 1,87,86)
						@ Li,nPosTre  Psay AllTrim(aTreino[nX])
					EndIf
					SomaLinha()
				Next nX
			EndIf
			aEmenta := {}
			aTreino := {}
			SomaLinha()
		ElseIf nModeloImp = 3
			If i == 1
				If lin+120 > 3000
					Somalinha(120)
				EndIf
				SomaLinha()
				oPrintPPR:FillRect({lin, 150, lin+60 , 2300}, oBrush1 )
	   			oBrush1:End()
				oPrintPPR:Box (lin, 150,  lin+60, 2300 )// Monta tabela
				oPrintPPR:Line(lin, 436,  lin+60, 436  )//Linha vertical requisito | termo lei
				oPrintPPR:Line(lin, 1150, lin+60, 1150 )//Linha vertical Termo lei | Vigência
				oPrintPPR:Line(lin, 1335, lin+60, 1335 )//Linha vertical Vigência  | Tipo
				oPrintPPR:Line(lin, 1625, lin+60, 1625 )//Linha vertical Tipo      | Origem
				oPrintPPR:Line(lin, 1820, lin+60, 1820 )//Linha vertical Origem    | Treinamento
				oPrintPPR:Say (lin+11, 155 , STR0110, oFont08b)
				oPrintPPR:Say (lin+11, 440 , STR0105, oFont08b)
				oPrintPPR:Say (lin+11, 1155, STR0106, oFont08b)
				oPrintPPR:Say (lin+11, 1340, STR0107, oFont08b)
				oPrintPPR:Say (lin+11, 1630, STR0108, oFont08b)
				oPrintPPR:Say (lin+11, 1825, STR0109, oFont08b)
				SomaLinha()
			EndIf

			oPrintPPR:Say(lin,153 ,Capital(aRequisito[i][1]),oFont08,5000)
			oPrintPPR:Say(lin,1155,DtoC(aRequisito[i][3])   ,oFont08)
			oPrintPPR:Say(lin,1340,Capital(aRequisito[i][4]),oFont08)
			oPrintPPR:Say(lin,1630,Capital(aRequisito[i][5]),oFont08)

			If nMax >= 1
			//nInc := 0
				For nZ := 1 To nMax
					If Len(aEmenta) >= nZ
						oPrintPPR:Say(lin,440 ,Capital(aEmenta[nZ]),oFont08)
					EndIf
					If Len(aTreino) >= nZ
						oPrintPPR:Say(lin,1825,Capital(aTreino[nZ]),oFont08)
					EndIf
					oPrintPPR:Line(lin-30,150 ,lin+60,150 )//Linha vertical Esquerda
					oPrintPPR:Line(lin-30,436 ,lin+60,436 )//Linha vertical requisito | termo lei
					oPrintPPR:Line(lin-30,1150,lin+60,1150)//Linha vertical Termo lei | Vigência
					oPrintPPR:Line(lin-30,1335,lin+60,1335)//Linha vertical Vigência  | Tipo
					oPrintPPR:Line(lin-30,1625,lin+60,1625)//Linha vertical Tipo      | Origem
					oPrintPPR:Line(lin-30,1820,lin+60,1820)//Linha vertical Origem    | Treinamento
					oPrintPPR:Line(lin-30,2300,lin+60,2300)//Linha vertical Direita
					SomaLinha()
				Next nZ
				oPrintPPR:Line(lin,150,lin,2300)   			//Linha horizontal inferior
			EndIf
			aEmenta := {}
			aTreino := {}
		EndIf
	Next i
	If nModeloImp == 1 .And. Len(aRequisito) > 0
		OLE_SetDocumentVar(oWord,"Tabela",cMemo)
		OLE_SetDocumentVar(oWord,"Linhas",nReg)
		OLE_ExecuteMacro(oWord,"Table_ReqTre")
		OLE_ExecuteMacro(oWord,"Somalinha")
	EndIf

	RestArea(aArea)

Return

//---------------------------------------------------------------------
/*/{Protheus.doc} A854PROMON

@author Bruno L. Souza
@since 13/05/2013
@version P11
/*/
//---------------------------------------------------------------------
Static Function A854PROMON()

Local cLaudo := If(lSIGAMDTPS,MV_PAR03,MV_PAR01)
Local cEpc, cNomEPC, cCodFam, cFreq, cDesFreq
Local cTPCOMTA, cServico, cNomServ, cSeqrela
Local nQd, nE
Local aQdMonitor := {}, aEtapa := {}
Local oBrush1 := TBrush():New( , RGB(229,229,229) )
Local cMemo := "", nRegs := 0
Local cPosMerge := ""
Local lImp := .F.

dbSelectArea("TIG")
dbSetOrder(1)
If dbSeek(xFilial("TIG")+cLaudo)
	While !Eof() .And. xFilial("TIG") == TIG->TIG_FILIAL .And. TIG->TIG_LAUDO == cLaudo
		cCodFam := TIG->TIG_CODFAM
		dbSelectArea("ST9")
		dbSetOrder(4)
		If dbSeek(xFilial("ST9")+Alltrim(cCodFam))
			While !Eof() .And. xFilial("ST9") == ST9->T9_FILIAL .And. cCodFam == ST9->T9_CODFAMI
				cEpc     := ST9->T9_CODBEM
				cNomEpc  := ST9->T9_NOME
				cTPCOMTA := ST9->T9_TPCONTA
				dbSelectArea("STF")
		        dbSetOrder(1)
				If dbSeek(xFilial("STF")+Alltrim(cEpc))
					lImp := .T.//Se o bem possui manutenção habilita impressão
					While !Eof() .And. xFilial("STF") == STF->TF_FILIAL .And. cEpc == STF->TF_CODBEM
						cServico := STF->TF_SERVICO
						cNomServ := Posicione( "ST4" , 1 , xFilial("ST4")+cServico , "T4_NOME" )
						cSeqrela := STF->TF_SEQRELA
						If STF->TF_TIPACOM == "T"
							cFreq    := STF->TF_UNENMAN
							cDesFreq := cValToChar(STF->TF_TEENMAN) + " " + NGRETSX3BOX("TF_UNENMAN",cFreq)
						ElseIf STF->TF_TIPACOM $ "C/P"
							cDesFreq := cValToChar(STF->TF_INENMAN) + " " + cTPCOMTA
						ElseIf STF->TF_TIPACOM == "A"
							cFreq    := STF->TF_UNENMAN
							cDesFreq := cValToChar(STF->TF_TEENMAN) + " " + NGRETSX3BOX("TF_UNENMAN",cFreq) + " ou "
							cDesFreq += cValToChar(STF->TF_INENMAN) + " " + cTPCOMTA
						Else
							cDesFreq := ""
						EndIf
						aAdd( aQdMonitor , { cCodFam , cEpc , cNomEpc , cNomServ , cDesFreq , {} } )
						dbSelectArea("STH")
						dbSetOrder(1)
						dbSeek( xFilial("STH") + cEpc + cServico + cSeqrela )
						aEtapa := {}
						While !Eof() .And. xFilial("STH") == STH->TH_FILIAL .And. cEpc == STH->TH_CODBEM .And. cServico == STH->TH_SERVICO .And. cSeqrela == STH->TH_SEQRELA
							cCodEta := STH->TH_ETAPA
							cDesEta := Posicione( "TPA" , 1 , xFilial("TPA")+cCodEta , "TPA_DESCRI" )
							aAdd( aQdMonitor[Len(aQdMonitor)][6] , { cCodEta , cDesEta } )
							dbSelectArea("STH")
							dbSkip()
						End
						dbSelectArea("STF")
						dbSkip()
					End
				EndIf
				dbSelectArea("ST9")
				dbSkip()
			End
		EndIf
		dbSelectArea("TIG")
		dbSkip()
	End
EndIf
// Impressão do Cabeçalho
Somalinha()
If lImp//Verifica se possui cinteudo para imprimir
	If nModeloImp == 1
		cMemo += STR0115+"#*" //"Equipamento/Area"
		cMemo += STR0116+"#*" //"Nome"
		cMemo += STR0117+"#*" //"Descrição do Serviço"
		cMemo += STR0118+"#*" //"Frequência"
		nRegs++
	ElseIf nModeloImp == 2
		/*
		****************************************************************************************************************************
		0         1         2         3         4         5         6         7         8         9         0         1         2
		0123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123
		****************************************************************************************************************************
		Equipamento/Area  Nome                  	        Descrição do Serviço            Frequência

		xxxxxxxxxxxxxxxx  xxxxxxxxxxxxxxxxxxxxxxxxxxxxxx  xxxxxxxxxxxxxxxxxxxxxxxxxxxxxx  xxxxxxxxxx
						                    Etapas
		xxxxxx - xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx
		xxxxxx - xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx
		xxxxxx - xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx
		xxxxxxxxxxxxxxxx  xxxxxxxxxxxxxxxxxxxxxxxxxxxxxx  xxxxxxxxxxxxxxxxxxxxxxxxxxxxxx  xxxxxxxxxx
		xxxxxxxxxxxxxxxx  xxxxxxxxxxxxxxxxxxxxxxxxxxxxxx  xxxxxxxxxxxxxxxxxxxxxxxxxxxxxx  xxxxxxxxxx
		*/
		@ Li,000 PSay STR0115 //"Equipamento/Area"
		@ Li,018 PSay STR0116 //"Nome"
		@ Li,050 PSay STR0117 //"Descrição do Serviço"
		@ Li,082 PSay STR0118 //"Frequência"
		Somalinha()
	ElseIf nModeloImp == 3
		If lin+120 > 3000
			Somalinha(120)
		EndIf
		oPrintPPR:FillRect({lin, 150, lin+60 , 2300}, oBrush1 )
		oBrush1:End()
		oPrintPPR:Box (lin , 150  , lin+60 , 2300 )
		oPrintPPR:Line(lin , 490  , lin+60 , 490  )
		oPrintPPR:Line(lin , 1060 , lin+60 , 1060 )
		oPrintPPR:Line(lin , 1680 , lin+60 , 1680 )
		oPrintPPR:Say(lin+10 , 170  , STR0115 , oFont08b) //"Equipamento/Area"
		oPrintPPR:Say(lin+10 , 510  , STR0116 , oFont08b) //"Nome"
		oPrintPPR:Say(lin+10 , 1080 , STR0117 , oFont08b) //"Descrição do Serviço"
		oPrintPPR:Say(lin+10 , 1700 , STR0118 , oFont08b) //"Frequência"
		Somalinha()
	EndIf
	//Impressão do Conteúdo
	For nQd := 1 To Len(aQdMonitor)
	    If nModeloImp == 1
			cMemo += aQdMonitor[nQd][2]+"#*"
		    cMemo += aQdMonitor[nQd][3]+"#*"
		    cMemo += aQdMonitor[nQd][4]+"#*"
		    cMemo += aQdMonitor[nQd][5]+"#*"
		    nRegs++
		    If Len(aQdMonitor[nQd][6]) > 0
		    	cMemo += STR0119 + "#*" + "#*" + "#*" + "#*"
		    	nRegs++
		    	cPosMerge += "{N}" + cValToChar( nRegs ) + "#*"
		    	For nE := 1 To Len(aQdMonitor[nQd][6])
	    			cMemo += AllTrim(aQdMonitor[nQd][6][nE][1]) + " - " + aQdMonitor[nQd][6][nE][2] + "#*" + "#*" + "#*" + "#*"
	    			nRegs++
	    			cPosMerge += cValToChar( nRegs ) + "#*"
	    		Next nE
	    	EndIf
	    ElseIf nModeloImp == 2
			@ Li,000 PSay aQdMonitor[nQd][2]
			@ Li,018 PSay SubStr(aQdMonitor[nQd][3],1,30)
			@ Li,050 PSay SubStr(aQdMonitor[nQd][4],1,30)
			@ Li,082 PSay aQdMonitor[nQd][5]
			Somalinha()
			If Len(aQdMonitor[nQd][6]) > 0
				For nE := 1 To Len(aQdMonitor[nQd][6])
					If nE == 1
						@ Li,034 PSay STR0119
						Somalinha()
					EndIf
					@ Li,000 PSay AllTrim(aQdMonitor[nQd][6][nE][1]) + " - " + SubStr(aQdMonitor[nQd][6][nE][2],1,120)
					Somalinha()
				Next nE
			Else
				Somalinha()
			EndIf
		ElseIf nModeloImp == 3
			oPrintPPR:Box(lin, 150  , lin+60, 2300 )
			oPrintPPR:Line(lin, 490 , lin+60, 490  )
			oPrintPPR:Line(lin, 1060, lin+60, 1060 )
			oPrintPPR:Line(lin, 1680, lin+60, 1680 )
			oPrintPPR:Say(lin+10, 170,  aQdMonitor[nQd][2] , oFont08)
			oPrintPPR:Say(lin+10, 510,  SubStr(aQdMonitor[nQd][3],1,20) , oFont08)
			oPrintPPR:Say(lin+10, 1080, SubStr(aQdMonitor[nQd][4],1,25) , oFont08)
			oPrintPPR:Say(lin+10, 1700, aQdMonitor[nQd][5] , oFont08)
			Somalinha()
			If Len(aQdMonitor[nQd][6]) > 0
				For nE := 1 To Len(aQdMonitor[nQd][6])
					If nE == 1
						oPrintPPR:Line(lin, 150,  lin+60, 150  )
						oPrintPPR:Line(lin, 2300, lin+60, 2300 )
						oPrintPPR:Line(lin+60 , 150 , lin+60 , 2300 )
						oPrintPPR:Say(lin+10 , 1070 , STR0119 , oFont08b) //"Etapas"
						Somalinha()
					EndIf
					oPrintPPR:Line(lin, 150,  lin+60, 150  )
					oPrintPPR:Line(lin, 2300, lin+60, 2300 )
					oPrintPPR:Say(lin+10 , 170 ,(AllTrim(aQdMonitor[nQd][6][nE][1]) + " - " + SubStr(aQdMonitor[nQd][6][nE][2],1,70)),oFont08)
					If nE == Len(aQdMonitor[nQd][6])//Fecha quadro de etapas.
						oPrintPPR:Line(lin+60 , 150 , lin+60 , 2300 )
					EndIf
					Somalinha()
				Next nE
			EndIf
		EndIf
	Next nQd

	If nModeloImp == 1
		cVar1 := "cTXT"+Strzero(nVar1,6)
		OLE_SetDocumentVar(oWord,"Cria_Var",cVar1)
		nVar1++
		OLE_ExecuteMacro   ( oWord , "Somalinha"	)
		OLE_SetDocumentVar ( oWord , "Tabela",cMemo	)
		OLE_SetDocumentVar ( oWord , "Linhas",nRegs	)
		OLE_SetDocumentVar ( oWord , "tabela2",cPosMerge	)
		OLE_ExecuteMacro   ( oWord , "Table_Programa_Monitoramento" ) // Cria tabela do PPR x Plano Emergencial.
		OLE_ExecuteMacro   ( oWord , "Somalinha"	)
		cMemo := ""
	EndIf
EndIf

Return

/*---------------------------------------------------------------------
{Protheus.doc} A854RFUGA

@author Bruno L. Souza
@since 06/03/2014
@version P11

---------------------------------------------------------------------*/
Static Function A854RFUGA()
Local nRfCab	:= 0
Local nRfCont	:= 0
Local nRegs	:= 0
Local cMemo 	:= ""
Local aRadFug := {}
Local oBrush1	:= TBrush():New( , RGB( 229, 229, 229 ) ) // Objeto que preenche campos coloridos, Modelo Grafico.


dbSelectArea( "TNE" )
dbSetOrder( 1 )
dbGoTop()
	While TNE->(!Eof()) .And. TNE->TNE_FILIAL == xFilial( "TNE" )
		dbSelectArea( "TO5" )
	dbSetOrder( 1 )
	If dbSeek( xFilial( "TO5" ) + Mv_par01 + TNE->TNE_CODAMB )
		dbSelectArea( "TI7" )
		dbSetOrder( 1 )
		dbSeek( xFilial( "TI7" ) + TNE->TNE_CODAMB )
		While !Eof() .And. xFilial( "TI7" ) == TI7->TI7_FILIAL .And. TI7->TI7_CODAMB == TNE->TNE_CODAMB
			If ( nCodAmb := aScan( aRadFug , {|x| x[1] == TI7->TI7_CODAMB } ) ) == 0
				aAdd(aRadFug,{ TI7->TI7_CODAMB, TNE->TNE_NOME , {} } )
				nCodAmb := Len(aRadFug)
			EndIf
			aAdd( aRadFug[nCodAmb,3] , { TI7->TI7_PONMED , TI7->TI7_TAXOBS , TI7->TI7_DESPAD } )
			TI7->( dbSkip() )
		End
	EndIf
	TNE->( dbSkip() )
End

// Impressão do Cabeçalho
If Len(aRadFug) > 0 //Verifica se possui conteudo para imprimir
	For nRfCab := 1 To Len(aRadFug)
		nRegs := 0
   		If nModeloImp == 1 // Modelo de ImpressÃ£o .doc (Word.)
			IMPHEA854( "{N}"+STR0093 )
			IMPDOC854( Alltrim(aRadFug[nRfCab][1])+" - "+aRadFug[nRfCab][2] )
			cMemo += STR0081+"#*" //"Pontos"
			cMemo += STR0128+"#*" //"Taxa de Dose Absorvida(mGy/h)"
			cMemo += STR0129+"#*" //"Desvio Padrão"
			nRegs++
		ElseIf nModeloImp == 2 // Modelo de Impressão padrão
			/*
			****************************************************************************************************************************
			0         1         2         3         4         5         6         7         8         9         0         1         2
			0123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123
			****************************************************************************************************************************
			Ambiente Físico: xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx

			Pontos      Taxa de Dose Absorvida(mGy/h)  Desvio Padrão
			xxxxxxxxxx                         xxxxxx       xxxxxxxx
			xxxxxxxxxx                         xxxxxx       xxxxxxxx
			xxxxxxxxxx                         xxxxxx       xxxxxxxx
			xxxxxxxxxx                         xxxxxx       xxxxxxxx
			xxxxxxxxxx                         xxxxxx       xxxxxxxx
			*/
			@ Li,000 Psay STR0093 // "Ambiente Físico:"
			@ Li,017 Psay Alltrim(aRadFug[nRfCab][1])+" - "+aRadFug[nRfCab][2]
			Somalinha()
			@ Li,000 PSay STR0081 //"Pontos"
			@ Li,012 PSay STR0128 //"Taxa de Dose Absorvida(mGy/h)"
			@ Li,043 PSay STR0129 //"Desvio Padrão"
			Somalinha()
		ElseIf nModeloImp == 3 // Modelo de Impressão grafico
			SomaLinha()
			If lin+120 > 3000
				Somalinha(120)
			EndIf
			oPrintPPR:Say  ( lin , 165 , STR0093 , oFont10b ) // "Ambiente Físico:"
			oPrintPPR:Say  ( lin , 525 , aRadFug[nRfCab][1]+" - "+aRadFug[nRfCab][2] , oFont10 )
			Somalinha()
			oPrintPPR:FillRect({lin, 150, lin+60 , 2300}, oBrush1 )
			oBrush1:End()
			oPrintPPR:Box (lin , 150  , lin+60 , 2300 )
			oPrintPPR:Line(lin , 860  , lin+60 , 860  )
			oPrintPPR:Line(lin , 1580 , lin+60 , 1580 )
			oPrintPPR:Say(lin+10 , 170  , STR0081 , oFont10b) //"Pontos"
			oPrintPPR:Say(lin+10 , 870  , STR0128 , oFont10b) //"Taxa de Dose Absorvida(mGy/h)"
			oPrintPPR:Say(lin+10 , 1590 , STR0129 , oFont10b) //"Desvio Padrão"
			Somalinha()
		EndIf

		//Impressão do Conteúdo
		For nRfCont := 1 To Len(aRadFug[nRfCab][3])
		    If nModeloImp == 1
				cMemo += aRadFug[nRfCab][3][nRfCont][1]+"#*"
			    cMemo += cValToChar(aRadFug[nRfCab][3][nRfCont][2])+"#*"
			    cMemo += cValToChar(aRadFug[nRfCab][3][nRfCont][3])+"#*"
			    nRegs++
		    ElseIf nModeloImp == 2
				@ Li,000 PSay aRadFug[nRfCab][3][nRfCont][1]
				@ Li,012 PSay aRadFug[nRfCab][3][nRfCont][2]
				@ Li,043 PSay aRadFug[nRfCab][3][nRfCont][3]
				Somalinha()
			ElseIf nModeloImp == 3
				oPrintPPR:Box(lin, 150  , lin+60, 2300 )
				oPrintPPR:Line(lin, 860 , lin+60, 860  )
				oPrintPPR:Line(lin, 1580, lin+60, 1580 )
				oPrintPPR:Say(lin+10, 170,  aRadFug[nRfCab][3][nRfCont][1] , oFont10)
				oPrintPPR:Say(lin+10, 870,  cValToChar(aRadFug[nRfCab][3][nRfCont][2]) , oFont10)
				oPrintPPR:Say(lin+10, 1590, cValToChar(aRadFug[nRfCab][3][nRfCont][3]) , oFont10)
				Somalinha()
			EndIf
		Next nRfCont
		If nModeloImp == 1
			cVar1 := "cTXT"+Strzero(nVar1,6)
			OLE_SetDocumentVar(oWord,"Cria_Var",cVar1)
			nVar1++
			OLE_ExecuteMacro   ( oWord , "Somalinha"	)
			OLE_SetDocumentVar ( oWord , "Tabela",cMemo	)
			OLE_SetDocumentVar ( oWord , "Linhas",nRegs	)
			OLE_ExecuteMacro   ( oWord , "Table_Radiação_Fuga" ) // Cria tabela de Radiação de Fuga.
			OLE_ExecuteMacro   ( oWord , "Somalinha"	)
			cMemo := ""
		EndIf
	Next nRfCab
EndIf

Return

//---------------------------------------------------------------------
/*/{Protheus.doc} MDTR854TR

@author Bruno L. Souza
@since 18/07/2013
@version P11
/*/
//---------------------------------------------------------------------
Function MDTR854TR(mv_par01)

Local lRet := .T.
Local cTipRel := NGSEEK("TO0",mv_par01,1,"TO0->TO0_TIPREL")

If cTipRel <> "8"
	lRet := .F.
	MsgStop(STR0121,STR0038)
EndIf

Return lRet

//---------------------------------------------------------------------
/*{Protheus.doc} A854DOSIME

Funcao genérica para impressão de:

 - Dosimetria por Ambiente Físico.
 - Dosimetria por Funcionario.
 - Dosimetria por Centro de Custo.
 - Dosimetria por Função.
 - Dosimetria por Atividade.

Nos modelos de impressão:
 - Word.
 - Padrão.
 - Grafico.

@author Bruno Lobo de Souza
@since 23/09/2013
@version P11
/*/
//---------------------------------------------------------------------
Static Function A854DOSIME(cTipDos,lImage)

Local nRegs 	  := 1
Local cImgPath	  := ""
Local cCodOld	  := ""
Local cMemo 	  := ""
Local aFiltros  := {}
Local aArea   	  := GetArea()
Local oBrush1	  := TBrush():New( , RGB(229,229,229) ) // Objeto que preenche campos coloridos, Modelo GrÃ¡fico.

Default lImage := .F.

If cTipDos == "1"
	dbSelectArea( "TO5" )
	dbSetOrder( 1 )
	dbSeek( xFilial( "TO5" ) + MV_PAR01 )
	While TO5->( !Eof() ) .And. TO5->TO5_FILIAL == xFilial( "TO5" ) .And. TO5->TO5_LAUDO == MV_PAR01
		aAdd( aFiltros , TO5->TO5_CODAMB )
		TO5->( dbSkip() )
	End
EndIf

 dbSelectArea( "TJ7" )
 dbSetOrder( 1 )
 If dbSeek( xFilial( "TJ7" ) + cTipDos )
 	While !Eof() .And. xFilial( "TJ7" ) == TJ7->TJ7_FILIAL .And. TJ7->TJ7_TIPREG == cTipDos

 		If cTipDos == "1"
			If aScan( aFiltros , { | x | Alltrim(x) == Alltrim(TJ7->TJ7_CODIGO) } ) == 0
				TJ7->( dbSkip() )
				Loop
			EndIf
 		EndIf

   		If cCodOld <> TJ7->TJ7_CODIGO
   			If !Empty( cCodOld )
   				// Execução da Macro para impressão Word.
			   	If nModeloImp == 1 .And. !Empty(cMemo) .And. nRegs > 1 // Modelo de ImpressÃ£o .doc (Word.)
			   		OLE_ExecuteMacro   ( oWord , "Somalinha"	  	  )
					OLE_SetDocumentVar ( oWord , "Tabela",cMemo	  )
					OLE_SetDocumentVar ( oWord , "Linhas",nRegs	  )
					OLE_ExecuteMacro   ( oWord , "Table_Dosimetria" ) // Cria tabela no Word de Dosimetria por Ambiente Físico.
					cMemo := ""
					nRegs := 1
			   	EndIf
   			EndIf

   			cCodOld := TJ7->TJ7_CODIGO

	   		//Inicio da impressão do cabeçalho
	   		If nModeloImp == 1 // Modelo de ImpressÃ£o .doc (Word.)
	   			If cTipDos == "1"
					IMPHEA854("{N}"+STR0079+": ") // "Dosimetria Por Ambiente Físico:"
					IMPDOC854(Substr(AllTrim(NGSEEK("TNE",TJ7->TJ7_CODIGO,1,"TNE->TNE_NOME")),1,20))
				ElseIf cTipDos == "2"
					IMPHEA854("{N}"+STR0111+": ") // "Dosimetria Por Funcionário:"
					IMPDOC854(Substr(AllTrim(NGSEEK("SRA",TJ7->TJ7_CODIGO,1,"SRA->RA_NOME")),1,20))
				ElseIf cTipDos == "3"
					IMPHEA854("{N}"+STR0112+": ") // "Dosimetria Por Centro de Custo:"
					IMPDOC854(Substr(AllTrim(NGSEEK("CTT",TJ7->TJ7_CODIGO,1,"CTT->CTT_DESC01")),1,20))
				ElseIf cTipDos == "4"
					IMPHEA854("{N}"+STR0113+": ") // "Dosimetria Por Função:"
					IMPDOC854(Substr(AllTrim(NGSEEK("SRJ",TJ7->TJ7_CODIGO,1,"SRJ->RJ_DESC")),1,20))
				ElseIf cTipDos == "5"
					IMPHEA854("{N}"+STR0114+": ") // "Dosimetria Por Tarefa:"
					IMPDOC854(Substr(AllTrim(NGSEEK("TN5",TJ7->TJ7_CODIGO,1,"TN5->TN5_NOMTAR")),1,20))
				EndIf

			 	//Impressão da imagem do ambiente físico.
			 	If !Empty(TNE->TNE_BITMAP) .And. lImage
					cImgPath := NGimgExtract( TNE->TNE_BITMAP, cPathEst )
					If !Empty( cImgPath )
						cImgPath := Substr(cImgPath,1,At(".",cImgPath))
						If File(cImgPath+"JPG")
							cImgPath += "JPG"
						ElseIf File(cImgPath+"JPEG")
							cImgPath += "JPEG"
						ElseIf File(cImgPath+"PNG")
							cImgPath += "PNG"
						ElseIf File(cImgPath+"BMP")
							cImgPath += "BMP"
						Endif
						OLE_ExecuteMacro(oWord,"Somalinha")
						OLE_SetDocumentVar(oWord,"Cria_Var",cImgPath)
						OLE_ExecuteMacro(oWord,"Insere_figura")    //Insere a imagem no documento Word
						OLE_ExecuteMacro(oWord,"Somalinha")
						If aScan( aImagens,{|x| UPPER(TRIM(x[1])) == UPPER(TRIM(Substr(cImgPath,1,At(".",cImgPath)))) }) == 0
							aADD( aImagens,{ Substr(cImgPath,1,At(".",cImgPath)) })
						Endif
						Ferase( cImgPath )  //Apaga imagem extraida do repositorio
					EndIf
				Endif

				cMemo += STR0080+"#*"
				cMemo += STR0081+"#*"
				cMemo += STR0082+"#*"
				cMemo += STR0083+"#*"
				cMemo += STR0084+"#*"
				cMemo += STR0085+"#*"
				cMemo += STR0086+"#*"
	   		ElseIf nModeloImp == 2 // Modelo de Impressão Padrão.
	   			/*
				********************************************************************************************
				0         1         2         3         4         5         6         7         8         9         0         1
				012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123
				********************************************************************************************
				Data        Pontos      Tipo Locais                               Fator         Taxa de Dose  Unidade  Distância
																				  Ocupação (T)  Equivalente   Medida
				xx/xx/xxxx  xxxxxxxxxx  xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx  xxxx          xxxx          xx       xxx
				xx/xx/xxxx  xxxxxxxxxx  xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx  xxxx          xxxx          xx       xxx
				xx/xx/xxxx  xxxxxxxxxx  xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx  xxxx          xxxx          xx       xxx

				*/
		   		SomaLinha()
		   		If cTipDos == "1"
					@ Li,019 Psay STR0079 + ": " // "Dosimetria Por Ambiente Físico:"
					@ Li,048 Psay SubStr(Capital(TJ7->TJ7_CODIGO),1,05) + " - " + SubStr(Capital(NGSEEK("TNE",TJ7->TJ7_CODIGO,1,"TNE->TNE_NOME")),1,30)
				ElseIf cTipDos == "2"
					@ Li,019 Psay STR0111 + ": " // "Dosimetria Por Funcionário:"
					@ Li,048 Psay SubStr(Capital(TJ7->TJ7_CODIGO),1,05) + " - " + SubStr(Capital(NGSEEK("SRA",TJ7->TJ7_CODIGO,1,"SRA->RA_NOME")),1,30)
				ElseIf cTipDos == "3"
					@ Li,019 Psay STR0112 + ": " // "Dosimetria Por Centro de Custo:"
					@ Li,048 Psay SubStr(Capital(TJ7->TJ7_CODIGO),1,05) + " - " + SubStr(Capital(NGSEEK("CTT",TJ7->TJ7_CODIGO,1,"CTT->CTT_DESC01")),1,30)
				ElseIf cTipDos == "4"
					@ Li,019 Psay STR0113 + ": " // "Dosimetria Por Função:"
					@ Li,048 Psay SubStr(Capital(TJ7->TJ7_CODIGO),1,05) + " - " + SubStr(Capital(NGSEEK("SRJ",TJ7->TJ7_CODIGO,1,"SRJ->RJ_DESC")),1,30)
				ElseIf cTipDos == "5"
					@ Li,019 Psay STR0114 + ": " // "Dosimetria Por Tarefa:"
					@ Li,048 Psay SubStr(Capital(TJ7->TJ7_CODIGO),1,05) + " - " + SubStr(Capital(NGSEEK("TN5",TJ7->TJ7_CODIGO,1,"TN5->TN5_NOMTAR")),1,30)
				EndIf
				SomaLinha()
		   		@ Li,000 Psay STR0080 // "Data"
				@ Li,012 Psay STR0081 // "Pontos"
				@ Li,024 Psay STR0082 // "Tipo Local"
				@ Li,066 Psay STR0087 // "Fator"
				@ Li,080 Psay STR0088 // "Taxa de Dose Equivalente"
				@ Li,094 Psay STR0089 // "Unidade"
				@ Li,103 Psay STR0086 // "Distância"
				SomaLinha()
				@ Li,066 Psay STR0090 //"Ocupação (T)"
				@ Li,080 Psay STR0091 //"Equivalente"
				@ Li,094 Psay STR0092 //"Medida"

	   		ElseIf nModeloImp == 3 // Modelo de Impressão Grafico.
	   			If Lin + 300 > 3000
	   				SomaLinha(300)
	   			EndIf
		   		SomaLinha()
		   		If cTipDos == "1"
					oPrintPPR:Say  ( lin , 165 , STR0079+": " , oFont10b	) // Dosimetria Ambiente Físico:
			   		oPrintPPR:Say  ( lin , 745 , SubStr(Capital(TJ7->TJ7_CODIGO),1,Len(TNE->TNE_CODAMB)) + " - " + Capital(NGSEEK("TNE",TJ7->TJ7_CODIGO,1,"TNE->TNE_NOME")) , oFont10 	)
				ElseIf cTipDos == "2"
					oPrintPPR:Say  ( lin , 165 , STR0111+": " , oFont10b	) // "Dosimetria Por Funcionário:"
			   		oPrintPPR:Say  ( lin , 665 , SubStr(Capital(TJ7->TJ7_CODIGO),1,Len(SRA->RA_MAT)) + " - " + Capital(NGSEEK("SRA",TJ7->TJ7_CODIGO,1,"SRA->RA_NOME")) , oFont10 	)
				ElseIf cTipDos == "3"
					oPrintPPR:Say  ( lin , 165 , STR0112+": " , oFont10b	) // "Dosimetria Por Centro de Custo:"
			   		oPrintPPR:Say  ( lin , 745 , SubStr(Capital(TJ7->TJ7_CODIGO),1,Len(CTT->CTT_CUSTO)) + " - " + Capital(NGSEEK("CTT",TJ7->TJ7_CODIGO,1,"CTT->CTT_DESC01")) , oFont10 	)
				ElseIf cTipDos == "4"
					oPrintPPR:Say  ( lin , 165 , STR0113+": " , oFont10b	) // "Dosimetria Por Função:"
			   		oPrintPPR:Say  ( lin , 570 , SubStr(Capital(TJ7->TJ7_CODIGO),1,Len(SRJ->RJ_FUNCAO)) + " - " + Capital(NGSEEK("SRJ",TJ7->TJ7_CODIGO,1,"SRJ->RJ_DESC")) , oFont10 	)
				ElseIf cTipDos == "5"
					oPrintPPR:Say  ( lin , 165 , STR0114+": " , oFont10b	) // "Dosimetria Por Tarefa:"
			   		oPrintPPR:Say  ( lin , 620 , SubStr(Capital(TJ7->TJ7_CODIGO),1,Len(TN5->TN5_CODTAR)) + " - " + Capital(NGSEEK("TN5",TJ7->TJ7_CODIGO,1,"TN5->TN5_NOMTAR")) , oFont10 	)
				EndIf

			  	SomaLinha()
			  	If !Empty(TNE->TNE_BITMAP) .And. lImage
					cImgPath := NGimgExtract( TNE->TNE_BITMAP, cPathEst )
					If !Empty( cImgPath )
						Somalinha()
						//Caso a página esteja no fim cria nova página para não truncar imagem
						If lin > 2160
							lin := 3001
							Somalinha()
						Endif
						cImgPath := Substr(cImgPath,1,At(".",cImgPath))
						If File(cImgPath+"JPG")
							oPrintPPR:SayBitmap(lin+10,200,cImgPath+"JPG",1600,800)
						ElseIf File(cImgPath+"JPEG")
							oPrintPPR:SayBitmap(lin+10,200,cImgPath+"JPEG",1600,800)
						ElseIf File(cImgPath+"PNG")
							oPrintPPR:SayBitmap(lin+10,200,cImgPath+"PNG",1600,800)
						ElseIf File(cImgPath+"BMP")
							oPrintPPR:SayBitmap(lin+10,200,cImgPath+"BMP",1600,800)
						Endif
						//Verifica os arquivos criados para deletar depois
						If aScan( aImagens,{|x| UPPER(TRIM(x[1])) == UPPER(TRIM(cImgPath)) }) == 0
							aADD( aImagens,{ cImgPath })
						Endif
						lin += 820
					Endif
				Endif
			  	SomaLinha()
			  	//Destaca linha
			  	oPrintPPR:FillRect({lin, 150, lin+120 , 2300}, oBrush1 )
		   		oBrush1:End()
		   		//Monta tabela do cabeçalho
		   		oPrintPPR:Box  ( lin , 150  , lin+120 , 2300 ) // Monta tabela
			  	oPrintPPR:line ( lin , 400  , lin+60  , 400  ) // Linha Vertical que separa os campos
		   		oPrintPPR:line ( lin , 670  , lin+60  , 670  ) // Linha Vertical que separa os campos
		   		oPrintPPR:line ( lin , 1090 , lin+60  , 1090 ) // Linha Vertical que separa os campos
		   		oPrintPPR:line ( lin , 1430 , lin+60  , 1430 ) // Linha Vertical que separa os campos
		   		oPrintPPR:line ( lin , 1770 , lin+60  , 1770 ) // Linha Vertical que separa os campos
		   		oPrintPPR:line ( lin , 2040 , lin+60  , 2040 ) // Linha Vertical que separa os campos
		   		//Comteúdo do cabeçalho
		   		oPrintPPR:Say  ( lin , 230  , STR0080 , oFont10b ) // "Data"
			  	oPrintPPR:Say  ( lin , 450  , STR0081 , oFont10b ) // "Ponto"
			  	oPrintPPR:Say  ( lin , 720  , STR0082 , oFont10b ) // "Tipo Local"
			  	oPrintPPR:Say  ( lin , 1190 , STR0087 , oFont10b ) // "Fator Ocupação (T)"
			  	oPrintPPR:Say  ( lin , 1460 , STR0088 , oFont10b ) // "Taxa de Dose Equivalente"
			  	oPrintPPR:Say  ( lin , 1825 , STR0089 , oFont10b ) // "Unidade Medida"
			  	oPrintPPR:Say  ( lin , 2080 , STR0086 , oFont10b ) // "Distânncia"
			  	SomaLinha()
			  	//Segunda linha do cabeçalho
			  	oPrintPPR:line ( lin , 400  , lin+60 , 400  ) // Linha Vertical que separa os campos
		   		oPrintPPR:line ( lin , 670  , lin+60 , 670  ) // Linha Vertical que separa os campos
		   		oPrintPPR:line ( lin , 1090 , lin+60 , 1090 ) // Linha Vertical que separa os campos
		   		oPrintPPR:line ( lin , 1430 , lin+60 , 1430 ) // Linha Vertical que separa os campos
		   		oPrintPPR:line ( lin , 1770 , lin+60 , 1770 ) // Linha Vertical que separa os campos
		   		oPrintPPR:line ( lin , 2040 , lin+60 , 2040 ) // Linha Vertical que separa os campos
		   		//Conteúdo da segunda linha do cabeçalho
			  	oPrintPPR:Say  ( lin , 1120 , STR0090 , oFont10b)
			  	oPrintPPR:Say  ( lin , 1480 , STR0091 , oFont10b)
			  	oPrintPPR:Say  ( lin , 1835 , STR0092 , oFont10b)
	   		EndIf
   		EndIf //Fim da impressão do cabeçalho.

   		//Inicio da impressão do conteudo.
   		If nModeloImp == 1 // Modelo de Impressão .doc (Word.)
   			cMemo += DtoC( TJ7->TJ7_DATA )+"#*"
   			cMemo += Alltrim( TJ7->TJ7_PONTO )+"#*"
			cMemo += Alltrim( TJ7->TJ7_TIPO )+"#*"
			cMemo += Alltrim( TJ7->TJ7_OCUPAC )+"#*"
			cMemo += Alltrim( TJ7->TJ7_DOSE )+"#*"
			cMemo += Alltrim( TJ7->TJ7_UNIDAD )+"#*"
		   	cMemo += cValToChar( TJ7->TJ7_DISTAN )+"#*"
		   	nRegs++
   		ElseIf nModeloImp == 2 // Modelo de ImpressÃ£o Padrão.
   			SomaLinha()
			@ Li,000 Psay TJ7->TJ7_DATA
			@ Li,012 Psay Capital(TJ7->TJ7_PONTO)
			@ Li,024 Psay Capital(TJ7->TJ7_TIPO)
			@ Li,066 Psay TJ7->TJ7_OCUPAC
			@ Li,080 Psay TJ7->TJ7_DOSE
			@ Li,094 Psay TJ7->TJ7_UNIDAD
			@ Li,103 Psay TJ7->TJ7_DISTAN
		ElseIf nModeloImp == 3 // Modelo de ImpressÃ£o Gráfico.
		  	SomaLinha()
		  	//incremento das linhas da tabela
		  	oPrintPPR:Box  ( lin , 150  , lin+60 , 2300	 ) // Monta tabela
		  	oPrintPPR:line ( lin , 400  , lin+60 , 400 	 ) // Linha Vertical que separa os campos
	   		oPrintPPR:line ( lin , 670  , lin+60 , 670 	 ) // Linha Vertical que separa os campos
	   		oPrintPPR:line ( lin , 1090 , lin+60 , 1090 ) // Linha Vertical que separa os campos
   			oPrintPPR:line ( lin , 1430 , lin+60 , 1430 ) // Linha Vertical que separa os campos
   			oPrintPPR:line ( lin , 1770 , lin+60 , 1770 ) // Linha Vertical que separa os campos
   			oPrintPPR:line ( lin , 2040 , lin+60 , 2040 ) // Linha Vertical que separa os campos
   			//Incremento do campos da tabela
	   		oPrintPPR:Say  ( lin , 170  , DTOC(TJ7->TJ7_DATA)		 				    , oFont10 	) // "Data"
		  	oPrintPPR:Say  ( lin , 410  , TJ7->TJ7_PONTO                               , oFont10 	) // "Ponto"
		  	oPrintPPR:Say  ( lin , 680  , SubStr( AllTrim ( TJ7->TJ7_TIPO  ),1,14 )	, oFont10 	) // "Tipo Local"
		  	oPrintPPR:Say  ( lin , 1110 , cValToChar( TJ7->TJ7_OCUPAC )			   	, oFont10 	) // "Fator Ocupação(T)"
		  	oPrintPPR:Say  ( lin , 1450 , cValToChar( TJ7->TJ7_DOSE   )			   	, oFont10 	) // "Taxa de Dose Equivalente"
		  	oPrintPPR:Say  ( lin , 1790 , cValToChar( TJ7->TJ7_UNIDAD )			   	, oFont10 	) // "Unidade Medida"
		  	oPrintPPR:Say  ( lin , 2060 , cValToChar( TJ7->TJ7_DISTAN )			   	, oFont10 	) // "Distância"
   		EndIf

   		TJ7->( dbSkip() )
   	End // Fim da impressão do conteúdo.

   	// Execução da Macro para impressão Word.
   	If nModeloImp == 1 .And. !Empty(cMemo) .And. nRegs > 1 // Modelo de ImpressÃ£o .doc (Word.)
   		OLE_ExecuteMacro   ( oWord , "Somalinha"	  	  )
		OLE_SetDocumentVar ( oWord , "Tabela",cMemo	  )
		OLE_SetDocumentVar ( oWord , "Linhas",nRegs	  )
		OLE_ExecuteMacro   ( oWord , "Table_Dosimetria" ) // Cria tabela no Word de Dosimetria por Ambiente Físico.
		cMemo := ""
   	EndIf
 EndIf

RestArea( aArea )

Return
