#INCLUDE "protheus.ch"

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³ RCTBR001 ³ Autor ³ Claudio Ferreira      ³ Data ³ 20/05/10 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Impressao do Plano de Contas x Conta Referencial           ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ SIGACTB                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/                         

User Function RCTBR001()
//Define Variaveis
	LOCAL wnrel
	LOCAL cString:="CT1"

	LOCAL aOrd	 := {}
	LOCAL cDesc1 := OemToAnsi("Este programa ir imprimir o Plano de Contas.")  //"Este programa ir  imprimir o Plano de Contas."
	LOCAL cDesc2 := OemToAnsi("Ser impresso de acordo com os parƒmetros solicitados pelo")  //"Ser  impresso de acordo com os parƒmetros solicitados pelo"
	LOCAL cDesc3 := OemToAnsi("usurio.")  //"usu rio."
	Local Tamanho:="M"

	PRIVATE aReturn := { OemToAnsi("Zebrado"), 1,OemToAnsi("Administracao"), 2, 2, 1, "",1 }  //"Zebrado"###"Administracao"
	PRIVATE nomeprog:="RCTBR001"
	PRIVATE aLinha  := { },nLastKey := 0
	PRIVATE cPerg   :="RCTBR001"
	PRIVATE titulo:= OemToAnsi("Listagem do Plano de Contas")  //"Listagem do Plano de Contas"
	PRIVATE cabec1 := OemToAnsi("CONTA                          D E N O M I N A C A O                      CLASSE      TIPO CTA.  CTA REF.")
	PRIVATE cabec2 := " "
	PRIVATE cCancel:= OemToAnsi("***** CANCELADO PELO OPERADOR *****")  //"***** CANCELADO PELO OPERADOR *****"

	li       := 80
	m_pag    := 1


	ValidPerg()          // Cria pergunta
	pergunte(cPerg,.f.)

	wnrel:="RCTBR001"            //Nome Default do relatorio em Disco
	wnrel:=SetPrint(cString,wnrel,cPerg,@titulo,cDesc1,cDesc2,cDesc3,.F.,aOrd,,Tamanho)

	If nLastKey == 27
		Set Filter To
		Return
	Endif

	SetDefault(aReturn,cString)


	If nLastKey == 27
		Set Filter To
		Return
	Endif

	RptStatus({|lEnd| RCTBR001Imp(@lEnd,wnRel,cString)})

Return

Static Function RCTBR001Imp(lEnd,WnRel,cString)
	LOCAL tamanho:="M"
	LOCAL limite := 132
	LOCAL cClasse
	Local cMascara
	Local cSeparador 	:= ""

	cMascara := GetMv("MV_MASCARA")

	cEntidade:= mv_par01

	dbSelectArea("CT1")
	dbGoTop()
	dbSetOrder( 1 )

	SetRegua(RecCount())   						// Total de elementos da regua

	dbSelectArea("CT1")
	dbSetOrder(1)
	cCondicao:=	" !Eof() "

	m_pag:=1

	While &cCondicao
		If lEnd
			@Prow()+1,001 PSAY cCancel
			Exit
		EndIF

		IncRegua()


		IF li > 75
			cabec(titulo,cabec1,cabec2,nomeprog,tamanho,;
				Iif(aReturn[4]==1,GetMv("MV_COMP"),GetMv("MV_NORM")))
			If len(Alltrim(CT1->CT1_CONTA)) < 9
				li -= 2
			Else
				li--
			EndIF
		EndIF

		cCodigo:=	Alltrim(CT1_CONTA)
		cDesc := &('CT1->CT1_DESC01')

		If len(Alltrim(CT1->CT1_CONTA)) < 9
			li += 2
		Else
			li++
		EndIF
//    0           1        2          3        4         5         6         7         8         9        10        11        12
//0123456789.123456789.123456789.123456789.123456789.123456789.123456789.123456789.123456789.123456789.123456789.123456789.123456789.12
//CONTA                          D E N O M I N A C A O                      CLASSE      TIPO CTA.  CTA REF.
		EntidadeCTB(CT1->CT1_CONTA,li,000,030,.F.,cMascara,cSeparador)
		@li, 031 PSAY cDesc
		@li, 074 PSAY If (CT1->CT1_CLASSE == "1", "Sintética", "Analitica")
		@li, 086 PSAY IF (CT1->CT1_NORMAL == "1", "Debito", "Credito")
		cCtaRef:=Posicione('CVD',1,xFilial('CVD')+CT1->CT1_CONTA+cEntidade,"CVD_CTAREF")
		cCodPla:=Posicione('CVD',1,xFilial('CVD')+CT1->CT1_CONTA+cEntidade,"CVD_CODPLA")
		dCtaRef:=Posicione('CVN',2,xFilial('CVN')+cCodPla+cCtaRef,"CVN_DSCCTA")
		@li, 095 PSAY Substr(cCtaRef,1,13)+' '+Substr(dCtaRef,1,24)
		dbSkip( )
	EndDo



	dbSelectarea( "CT1" )
	dbSetOrder( 1 )

	Set Filter To
	If aReturn[5] = 1
		Set Printer To
		Commit
		ourspool(wnrel)
	Endif
	MS_FLUSH()

Return

Static Function ValidPerg()
	_sAlias	:=	Alias()
	dbSelectArea("SX1")
	dbSetOrder(1)
	cPerg 	:=	PADR(cPerg,10)
//                                                                                     -SA1-
	putSx1(     cPerg,"01","Entidade    ?","."     ,"."       ,"mv_ch1","C",02,0,0,"G","","GP","","","mv_par01","","","","","","","","","","","","","","","","")

	dbSelectArea(_sAlias)

Return

