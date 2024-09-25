#INCLUDE "MDTR960.ch"
#include "protheus.ch"
#DEFINE _nVERSAO 2 //Versao do fonte

//----------------------------------------------------------------------------
/*/{Protheus.doc} MDTR960
Impressao da carta de registro do Sesmt junto ao SRTE

@author Roger Rodrigues
@since 15/09/10

@return .T.
/*/
//----------------------------------------------------------------------------
Function MDTR960()
Local aNGBEGINPRM := NGBEGINPRM(_nVERSAO)
//Variaveis para impressao
Local i
Local wnrel   := "MDTR960"
Local cDesc1  := STR0001 //"Relatório de Registro do Sesmt no Ministério do Trabalho"
Local cDesc2  := ""
Local cDesc3  := ""
Local cString := "TMK"
Private aReturn  := {STR0002, 1,STR0003, 1, 2, 1, "",1 } //"Zebrado"###"Administracao"
Private titulo   := STR0001 //"Relatório de Registro do Sesmt no Ministério do Trabalho"
Private ntipo    := 0
Private nLastKey := 0
Private oPrintOS//Variavel do relatorio
Private lSigaMdtPS := If( SuperGetMv("MV_MDTPS",.F.,"N") == "S", .t. , .f. )
Private cPerg := If(!lSigaMdtPS,"MDT960","MDT960PS  "), aPerg := {}

//Varíaveis para verificar tamanho dos campos
Private nTamSRA := If((TAMSX3("RA_MAT")[1]) < 1,6 ,(TAMSX3("RA_MAT")[1]))
Private nTa1 := If((TAMSX3("A1_COD")[1]) < 1,6,(TAMSX3("A1_COD")[1]))
Private nTa1L := If((TAMSX3("A1_LOJA")[1]) < 1,2,(TAMSX3("A1_LOJA")[1]))
Private nSizeTD := nTa1+nTa1L

/*---------------------------
//PADRÃO						|
|  Orgão MTB					|
|  Seção MTB					|
|  Endereço MTB				|
|  Complemento 				|
|  Cidade/UF MTB				|
|  Nº Registro				|
|  Matrícula					|
|  								|
//PRESTADOR					|
|  Cliente ?					|
|  Loja						|
|  Orgão MTB					|
|  Seção MTB					|
|  Endereço MTB				|
|  Complemento 				|
|  Cidade/UF MTB				|
|  Nº Registro				|
|  Matrícula					|
-------------------------------*/

If !MDTRESTRI(cPrograma)
	//---------------------------------------------------
	// Devolve variaveis armazenadas (NGRIGHTCLICK)
	//---------------------------------------------------
	NGRETURNPRM(aNGBEGINPRM)
	Return .F.
Endif

//----------------------------------------------
// Envia controle para a funcao SETPRINT
//----------------------------------------------
pergunte(cPerg,.F.)
wnrel:=SetPrint(cString,wnrel,cPerg,titulo,cDesc1,cDesc2,cDesc3,.F.,"")

If nLastKey == 27
   Set Filter to
   Return
Endif

SetDefault(aReturn,cString)

If nLastKey == 27
   Set Filter to
   Return
Endif

Processa({|lEnd| MDT960IMP()}) // MONTE TELA PARA ACOMPANHAMENTO DO PROCESSO.

//----------------------------------------------
// Retorna conteudo de variaveis padroes
//----------------------------------------------
NGRETURNPRM(aNGBEGINPRM)
Return .T.

//----------------------------------------------------------------------------
/*/{Protheus.doc} MDT960IMP
Realiza impressao do relatorio

@author Roger Rodrigues
@since 30/08/10

@return
/*/
//----------------------------------------------------------------------------
Static Function MDT960IMP()
Local i, j
Local lImp := .F.
Local nSizeTOE := If((TAMSX3("TOE_CNAE")[1]) < 1,7,(TAMSX3("TOE_CNAE")[1]))
Local aSesmt := {}
//Variaveis da empresa
Local cData := "", cCarta := ""
Private cNome := "", cCep := "", cCNAE := "", cCNPJ := "", cEnder := "", cCNAEImp := ""
Private cTelef:= "", cFax := "", cBairro :="", cCidade := "", cGrau := ""

//Variaveis do relatorio
Private oPrint960
Private Lin := 9999

//Definicao de Fontes
Private cFonte := "Verdana"
Private oFont13	 := TFont():New(cFonte,13,13,,.T.,,,,.F.,.F.)
Private oFont13bs:= TFont():New(cFonte,13,13,,.T.,,,,.F.,.T.)
Private oFont12	 := TFont():New(cFonte,12,12,,.T.,,,,.F.,.F.)
Private oFont11	 := TFont():New(cFonte,11,11,,.T.,,,,.F.,.F.)
Private oFont10	 := TFont():New(cFonte,10,10,,.T.,,,,.F.,.F.)
Private oFont09	 := TFont():New(cFonte,09,09,,.T.,,,,.F.,.F.)
Private oFont08	 := TFont():New(cFonte,08,08,,.T.,,,,.F.,.F.)
Private oFont07	 := TFont():New(cFonte,06,06,,.T.,,,,.F.,.F.)

//Inicializa Objeto
oPrint960 := TMSPrinter():New(OemToAnsi(titulo))
oPrint960:Setup()
oPrint960:SetPortrait()//Retrato

Processa({|lEnd| aSesMt := MDT960ARR()})//Carrega Array com Usuarios Sesmt

If Len(aSesMt) > 0
	If lSigaMdtps
		dbSelectArea("SA1")
		dbSetOrder(1)
		If dbSeek(xFilial("SA1")+mv_par01+mv_par02)
			cNome	:= AllTrim(Capital(SA1->A1_NOME))
			cCEP	:= Transform(SA1->A1_CEP,"99999-999")
			cCNAE	:= SA1->A1_ATIVIDA
			nSizeCNAE := Len(AllTrim(SA1->A1_ATIVIDA))
			If nSizeCNAE > 5
				cCNAEImp := Transform(SA1->A1_ATIVIDA,"@R 99.99-9/99")
			Else
				cCNAEImp := Transform(SA1->A1_ATIVIDA,"@R 99.99-9")
			EndIf

			cCNPJ	:= Transform(SA1->A1_CGC,"@R 99.999.999/9999-99")
			cTpIns	:= STR0047//"CNPJ"

			cTelef	:= AllTrim(SA1->A1_TEL)
			cFax	:= AllTrim(SA1->A1_FAX)
			cEnder	:= AllTrim(Capital(SA1->A1_END))
			cBairro	:= SA1->A1_BAIRRO
			cCidade	:= AllTrim(Capital(SA1->A1_MUN))+" - "+AllTrim(Upper(SA1->A1_EST))
			cCidEmp := SA1->A1_MUN
			dbSelectArea("TOE")
			dbSetOrder(1)
			If dbSeek(xFilial("TOE")+cCnae)
				cGrau := TOE->TOE_GRISCO
			ElseIf dbSeek(xFilial("TOE")+Substr(cCnae,1,5)+Space(nSizeTOE-5))
				cGrau := TOE->TOE_GRISCO
			Endif
		Endif
	Else
		cNome	:= AllTrim(Capital(SM0->M0_NOMECOM))
		cCEP	:= Transform(SM0->M0_CEPCOB,"99999-999")
		cCNAE	:= SM0->M0_CNAE
		nSizeCNAE := Len(AllTrim(SM0->M0_CNAE))
		If nSizeCNAE > 5
			cCNAEImp := Transform(SM0->M0_CNAE,"@R 99.99-9/99")
		Else
			cCNAEImp := Transform(SM0->M0_CNAE,"@R 99.99-9")
		EndIf

		If SM0->M0_TPINSC != 2
			cCNPJ	:= Transform(SM0->M0_CGC,"@R 99.999.99999/99")
			cTpIns	:= STR0048//"CEI"
		Else
			cCNPJ	:= Transform(SM0->M0_CGC,"@R 99.999.999/9999-99")
			cTpIns	:= STR0047//"CNPJ"
		Endif
		cTelef	:= AllTrim(SM0->M0_TEL)
		cFax	:= AllTrim(SM0->M0_FAX)
		cEnder	:= AllTrim(Capital(SM0->M0_ENDCOB))
		cBairro	:= SM0->M0_BAIRCOB
		cCidade	:= AllTrim(Capital(SM0->M0_CIDCOB))+" - "+AllTrim(Upper(SM0->M0_ESTCOB))
		cCidEmp := SM0->M0_CIDCOB
		dbSelectArea("TOE")
		dbSetOrder(1)
		If dbSeek(xFilial("TOE")+cCnae)
			cGrau := TOE->TOE_GRISCO
		ElseIf dbSeek(xFilial("TOE")+Substr(cCnae,1,5)+Space(nSizeTOE-5))
			cGrau := TOE->TOE_GRISCO
		Endif
	Endif

	Somalinha()
	lImp := .T.
	oPrint960:Say(lin,1200,STR0022,oFont13bs,,,,2) //"REGISTRO DO SESMT"
	Somalinha(150)
	cData := Alltrim(Capital(cCidEmp))+", "+STRZERO(Day(dDataBase),2)+STR0023+ Capital(MesExtenso(dDataBase))+STR0023+StrZero(Year(dDataBase),4) //" de "###" de "
	oPrint960:Say(lin,100,cData,oFont10)
	Somalinha(200)
	oPrint960:Say(lin,100,"À,",oFont10)
	Somalinha()
	oPrint960:Say(lin,100,AllTrim(If(lSigaMdtps,mv_par03,mv_par01)),oFont10)
	Somalinha()
	oPrint960:Say(lin,100,AllTrim(If(lSigaMdtps,mv_par04,mv_par02)),oFont10)
	Somalinha()
	oPrint960:Say(lin,100,AllTrim(If(lSigaMdtps,mv_par05,mv_par03)) + " " + AllTrim(If(lSigaMdtps,mv_par06,mv_par04)),oFont10)
	Somalinha()
	oPrint960:Say(lin,100,AllTrim(If(lSigaMdtps,mv_par07,mv_par05)),oFont10)
	Somalinha(180)
	oPrint960:Say(lin,100,STR0024+AllTrim(If(lSigaMdtps,mv_par08,mv_par06)),oFont10) //"Assunto: Registro do SESMT N.º "
	Somalinha(180)

	cCarta := STR0025+cNome+", " //"A "
	cCarta += cTpIns+" "+AllTrim(cCNPJ)+", "
	cCarta += STR0026+cEnder+", " //"estabelecida na "
	cCarta += STR0027+AllTrim(Capital(cBairro))+", "+cCidade+", " //"bairro "
	cCarta += STR0028+cCEP+STR0029+cCNAEImp+STR0030+cGrau+", " //"CEP "###", CNAE "###", Grau de Risco "
	cCarta += STR0031+AllTrim(Str(MDT960FUN(),5))+STR0032 //"mantendo em seu estabelecimento central "###" funcionários, "
	cCarta += STR0033 //"vem atualizar a composição de seu SESMT - Serviços Especializados em Engenharia de Segurança e em Medicina do Trabalho, "
	cCarta += STR0034//"em conformidade com a NR-4 da Portaria N.º 3.214/78 do Ministério do Trabalho.

	For i:=1 to MLCOUNT(cCarta,100)
		Somalinha()
		oPrint960:Say(lin,100,MemoLine(cCarta,100,i),oFont10)
	Next i

	Lin := 2850-(250)
	oPrint960:Say(lin,100,STR0035,oFont10)//"Atenciosamente, "
	Somalinha(80)
	dbSelectArea("SRA")
	dbSetOrder(1)
	If dbSeek(xFilial("SRA")+If(lSigaMdtps,mv_par09,mv_par07))
		oPrint960:Say(lin,100,AllTrim(Capital(SRA->RA_NOME)),oFont10)
		If !Empty(NGSEEK("SRJ",SRA->RA_CODFUNC,1,"SRJ->RJ_DESC"))
			Somalinha()
			oPrint960:Say(lin,100,AllTrim(Capital(NGSEEK("SRJ",SRA->RA_CODFUNC,1,"SRJ->RJ_DESC"))),oFont10)
		Endif
		If !Empty(NGSEEK("SI3",SRA->RA_CC,1,"SI3->I3_DESC"))
			Somalinha()
			oPrint960:Say(lin,100,AllTrim(Capital(NGSEEK("SI3",SRA->RA_CC,1,"SI3->I3_DESC"))),oFont10)
		Endif
		Somalinha()
		oPrint960:Say(lin,100,cNome,oFont10)
	Endif

	Lin := 9999
	cTipo := ""
	For i:=1 to Len(aSesmt)
		Somalinha(60,.T.)
		If aSesMt[i][3] != cTipo
			cTipo := aSesMt[i][3]
			If Lin + 100 > 2850
				Somalinha(9999,.T.)
			Else
				Somalinha(60,.T.)
			Endif
			dbSelectArea("TMK")
			oPrint960:Box(lin,100,lin+60,2300)
			oPrint960:Say(lin+10,110,Tabela('P1',cTipo,.F.),oFont10)
			Somalinha(60)
		Endif
		cCPF := Transform(aSesMt[i][4],PesqPict("SRA","RA_CIC"))
		nMaior := MLCount(aSesMt[i][2],25)//Nome
		nMaior := If(nMaior < MLCount(aSesMt[i][4],25), MLCount(cCPF,25), nMaior)//CPF
		nMaior := If(nMaior < MLCount(aSesMt[i][5],25), MLCount(aSesMt[i][5],25), nMaior)//Registro
		nMaior := If(nMaior < MLCount(aSesMt[i][6],25), MLCount(aSesMt[i][6],25), nMaior)//Horario
		For j:=1 to nMaior
			If j!= 1
				Somalinha(60,.T.,(j==nMaior))
			Endif
			oPrint960:Line(lin,100,lin+60,100)
			oPrint960:Say(lin+10,110,MemoLine(aSesMt[i][2],25,j),oFont10)
			oPrint960:Line(lin,650,lin+60,650)
			oPrint960:Say(lin+10,660,MemoLine(cCPF,25,j),oFont10)
			oPrint960:Line(lin,1200,lin+60,1200)
			oPrint960:Say(lin+10,1210,MemoLine(aSesMt[i][5],25,j),oFont10)
			oPrint960:Line(lin,1750,lin+60,1750)
			oPrint960:Say(lin+10,1760,MemoLine(aSesMt[i][6],25,j),oFont10)
			oPrint960:Line(lin,2300,lin+60,2300)
			If j==nMaior
				oPrint960:Line(lin+60,100,lin+60,2300)
			Endif
		Next j
	Next i
Endif

If lImp
	oPrint960:EndPage()
	//Imprime na Tela ou Impressora
	If aReturn[5] == 1
		oPrint960:Preview()
	Else
		oPrint960:Print()
	EndIf
Else
	MsgStop(STR0036,STR0037)//"Não existem dados para montar o relatório."##"Atenção"
Endif
MS_FLUSH()

Return

//----------------------------------------------------------------------------
/*/{Protheus.doc} MDT960ARR
Retorna array com informacoes dos Usuarios Sesmt da Empresa

@author Roger Rodrigues
@since 15/09/10

@return aArray
/*/
//----------------------------------------------------------------------------
Static Function MDT960ARR()
Local i, j
Local aArray  := {}, aCalend   := {}
Local cCalend := "", cRegistro := ""
Local cHoraIni:= "", cHoraFim  := ""

dbSelectArea("TMK")
dbSetOrder(1)
dbSeek(xFilial("TMK"))
While !eof() .and. xFilial("TMK") == TMK->TMK_FILIAL

	//Verifica se compoe Sesmt
	If TMK->TMK_SESMT != "1"
		dbSelectArea("TMK")
		dbSkip()
		Loop
	Endif
	If !lSigaMdtps
		//Verifica Data Inicio e Fim
		If (TMK->TMK_DTTERM < dDataBase .and. !Empty(TMK->TMK_DTTERM)) .or. TMK->TMK_DTINIC > dDataBase
			dbSelectArea("TMK")
			dbSkip()
			Loop
		Endif
	Else
		dbSelectArea("TOV")
		dbSetOrder(2)
		If dbSeek(xFilial("TOV")+MV_PAR01+MV_PAR02+TMK->TMK_CODUSU)
			//Verifica Data Inicio e Fim
			If (TOV->TOV_DTFIM < dDataBase .and. !Empty(TOV->TOV_DTFIM)) .or. TOV->TOV_DTINIC > dDataBase
				dbSelectArea("TMK")
				dbSkip()
				Loop
			Endif
		Else
			dbSelectArea("TMK")
			dbSkip()
			Loop
		Endif
	Endif

	cCalend  := ""
	cRegistro:= ""
	aCalend  := {}
	cHoraIni := ""
	cHoraFim := ""

	//Verifica Calendario de Atendimento
	If !Empty(TMK->TMK_CALEND)
		cCalend := MDTR960HOR( TMK->TMK_CALEND )
	EndIf

	//Retorna numero de registro
	If !Empty(TMK->TMK_NUMENT) .and. !Empty(TMK->TMK_ENTCLA)
		cRegistro := AllTrim(TMK->TMK_ENTCLA)+" "+AllTrim(TMK->TMK_NUMENT)
		If !Empty(TMK->TMK_REGMTB)
			cRegistro += CHR(13)+CHR(10)
		Endif
	Endif
	If !Empty(TMK->TMK_REGMTB)
		cRegistro += "MTB "+AllTrim(TMK->TMK_REGMTB)
	Endif
	//Verifica e adiciona no array
	If aScan(aArray, {|x| Upper(x[1]) == TMK->TMK_CODUSU}) == 0
		aAdd(aArray, {TMK->TMK_CODUSU, AllTrim(Capital(TMK->TMK_NOMUSU)), TMK->TMK_INDFUN, TMK->TMK_CIC, cRegistro, cCalend})
	Endif
	dbSelectArea("TMK")
	dbSkip()
End
//Ordena por tipo+nome
ASORT(aArray,,,{|x,y| x[3]+x[2] < y[3]+y[2] })
Return aArray

//----------------------------------------------------------------------------
/*/{Protheus.doc} Somalinha
Realiza salto de linha

@param nLin - Linha posicionada.
@param lCabec - Verifica impressão do cabeçalho.
@param lPrtLin - Verifica impressão de linha.

@author Roger Rodrigues
@since 15/09/10

@return .T.
/*/
//----------------------------------------------------------------------------
Static Function Somalinha(nLin, lCabec,lPrtLin)
Local cEnd, cTel
Default nLin := 40
Default lCabec := .F.
Default lPrtLin := .F.
Lin += nLin
If lin > 2850
	If lPrtLin
		oPrint960:Line(lin,100,lin,2300)
	Endif
	oPrint960:EndPage()
	//---------------------------------------------
	// Inicia pagina e imprime cabeçalho
	//---------------------------------------------
	oPrint960:StartPage()
	lin := 130
	If !Empty(cNome)
		oPrint960:Say(2980,1200,cNome,oFont10,,,,2)

		cEnd := cEnder + STR0039 + cCEP//" - CEP "
		oPrint960:Say(3020,1200,cEnd,oFont10,,,,2)

		cTel := STR0040+cTelef + STR0041 + cFax//"Tefelone:"##"  Fax:"
		oPrint960:Say(3060,1200,cTel,oFont10,,,,2)
		oPrint960:Say(3100,1200,cCidade,oFont10,,,,2)
	Endif
	If lCabec
		oPrint960:Say(lin,1200,STR0042,oFont13bs,,,,2)//"COMPONENTES DO SESMT"
		Lin += 130
		oPrint960:Box(lin,100,lin+100,2300)
		oPrint960:Say(lin+30,290,STR0043,oFont11)//"Nome"
		oPrint960:Line(lin,650,lin+100,650)
		oPrint960:Say(lin+30,870,STR0044,oFont11)//"CPF"
		oPrint960:Line(lin,1200,lin+100,1200)
		oPrint960:Say(lin+30,1265,STR0045,oFont11)//"Nº Registro/ Órgão"
		oPrint960:Line(lin,1750,lin+100,1750)
		oPrint960:Say(lin+30,1950,STR0046,oFont11)//"Horário"
		Lin += 100
		If lPrtLin
			oPrint960:Line(lin,100,lin,2300)
		Endif
	Endif
Endif

Return .T.

//----------------------------------------------------------------------------
/*/{Protheus.doc} MDT960FUN
Retorna quantidade de funcionarios da empresa

@author Roger Rodrigues
@since 09/15/10

@return nFunc - Quantidade de funcionário.
/*/
//----------------------------------------------------------------------------
Static Function MDT960FUN()
Local nFunc := 0

If !lSigaMdtps //Caso não seja prestador de serviço.
	cTabSRA := RetSqlName("SRA")
	cFilSRA := xFilial("SRA")
	cAliasSRA := GetNextAlias()
	cQuery := "SELECT COUNT(*) AS TOTAL "
	cQuery += "FROM " + cTabSRA + " "
	cQuery += "WHERE RA_SITFOLH != 'D' AND D_E_L_E_T_ != '*' AND RA_FILIAL = " + ValToSQL( cFilSRA )
	cQuery += "AND RA_CATFUNC != 'A' "
	cQuery := ChangeQuery(cQuery)
	MPSysOpenQuery( cQuery , cAliasSRA )
	dbSelectArea(cAliasSRA)
	dbGotop()
	nFunc := (cAliasSRA)->TOTAL
	(cAliasSRA)->( dbCloseArea() )
Else //Caso seja prestador de serviço.
	dbSelectArea("SRA")
	dbSetOrder(1)
	dbSeek(xFilial("SRA"))
	While !eof() .and. xFilial("SRA") == SRA->RA_FILIAL
		If SRA->RA_SITFOLH <> "D" .And. SRA->RA_CATFUNC <> "A" .And. Substr(SRA->RA_CC,1,nTA1+nTA1L) == mv_par01+mv_par02
			nFunc++
		Endif
		dbSelectArea("SRA")
		dbSkip()
	End
Endif
Return nFunc

//----------------------------------------------------------------------------
/*/{Protheus.doc} MDT960CLI
Valida codigo do cliente.

@sample MDTR960

@author Roger Rodrigues
@since 16/09/2010

@return lRet - Varivel de controle.
/*/
//----------------------------------------------------------------------------
Function MDT960CLI()
Local lRet := .T.

cCliMdtps := MV_PAR01+MV_PAR02

If !Empty(MV_PAR09)
	dbSelectArea("SRA")
	dbSetOrder(1)
	If !dbSeek(xFilial("SRA")+MV_PAR09)
		MV_PAR09 := Space(nTamSRA)
	Else
		If Substr(SRA->RA_CC,1,nTA1+nTA1L) != mv_par01+mv_par02
			MV_PAR09 := Space(nTamSRA)
		Endif
	Endif
Endif
Return lRet

//----------------------------------------------------------------------------
/*/{Protheus.doc} MDT960MAT
Valida a pergunta Matricula.

@sample MDTR960

@author Roger Rodrigues
@since 16/09/2010

@return ExCpoMDT("SRA",Mv_par09) .AND. MDTMATVAL(mv_par09,mv_par01+mv_par02)
/*/
//----------------------------------------------------------------------------
Function MDT960MAT()

Return ExCpoMDT("SRA",Mv_par09) .AND. MDTMATVAL(mv_par09,mv_par01+mv_par02)

//---------------------------------------------------------------------
/*/{Protheus.doc} MDTR960HOR
Função para trazer todos os intervalos do calendário do atendente

@type function
@author Daniela Marioti
@since  02/08/2019
@param  cCalend, Caractere, Calendário do Atendente
@sample MDTR960HOR( '001' )

@return cHorAten, Caractere, Carga horária do Atendente
/*/
//---------------------------------------------------------------------
Function MDTR960HOR( cCalend )

	Local cHorAten   := ''
	Local aDiaSem   := { STR0049, STR0050, STR0051, STR0052, STR0053, STR0054, STR0055}
	Local nDia      := 0
	Local nInt      := 0

	aCalend := NGCALENDAH( cCalend ) //Recebe os horario do turno

	//Percorre dias da semana
	For nDia := 1 to Len( aCalend )
		//Se encontrar horas no dia
		If aCalend[nDia][1] != "00:00" .And. Len(aCalend[nDia]) > 1
			cHorAten += aDiaSem[nDia] + ' -'

			For nInt := 1 to Len(aCalend[nDia][2]) //Pega todos os inbtervalos do dia
				cHorAten += ' ' + aCalend[nDia][2][nInt][1] + ' ' + STR0038 + ' ' + aCalend[nDia][2][nInt][2] + CRLF
			Next nInt

		EndIf
	Next nDia

Return cHorAten