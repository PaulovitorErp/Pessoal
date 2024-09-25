#INCLUDE "MNTC657.ch"
#Include "Protheus.ch"

#DEFINE _nVERSAO 2 //Versao do fonte
/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³ MNTC657  ³ Autor ³ Marcos                ³ Data ³ 04/10/10 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Registro de saida de combustivel                           ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ Generico                                                   ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function MNTC657()

	//+------------------------------------------------------------------------+
	//| Armazena variaveis p/ devolucao (NGRIGHTCLICK) 						   |
	//+------------------------------------------------------------------------+
	Local bKeyF9
	Local bKeyF10
	Local bKeyF11
	Local bKeyF12
	Local aNGCAD02 := {}
	Local aNGBEGINPRM := NGBEGINPRM(_nVERSAO,,,,.T.)
	Local oTempTable
	Local aPesq := {}

	Private asMenu
	Private lNovoBrw   := If(TcSrvType() == "AS/400" .OR. TcSrvType() == "iSeries",.F.,.T.)
	Private cPerg    := "MNC657"
	Private aPerg :={}

	Private cTRBC657 := GetNextAlias()

	asMenu := NGRIGHTCLICK("MNTC657")

	Private aRotina := MenuDef()
	Private cCadastro := STR0001 //"Consulta de Aferições da Bomba"
	Private aDBF := {}
	Private aCHKDEL  := Nil

	Aadd(aDBF,{"POSTO" ,"C", TAMSX3("A2_COD")[1],0})
	Aadd(aDBF,{"LOJA"  ,"C", TAMSX3("A2_LOJA")[1],0})
	Aadd(aDBF,{"TANQUE","C", 02,0})
	Aadd(aDBF,{"BOMBA" ,"C", 03,0})
	Aadd(aDBF,{"DATINI","D", 08,0})
	Aadd(aDBF,{"HORINI","C", 05,0})
	Aadd(aDBF,{"CONINI","N", 09,2})
	Aadd(aDBF,{"DATFIM","D", 08,0})
	Aadd(aDBF,{"HORFIM","C", 05,0})
	Aadd(aDBF,{"CONFIM","N", 09,2})
	Aadd(aDBF,{"QTDREG","N", 09,2})
	Aadd(aDBF,{"QTDABA","N", 09,2})
	Aadd(aDBF,{"QTDSAI","N", 09,2})
	Aadd(aDBF,{"ORDENA","C", 08,0})

	aTRB := {	{STR0002,"POSTO" , "C", TAMSX3("A2_COD")[1],0,"@!" },;	//"Posto"
				{STR0003,"LOJA"  , "C", TAMSX3("A2_LOJA")[1],0,"@!" },; //"Loja"
				{STR0004,"TANQUE", "C", 02, 0, "@!" },;					//"Tanque"
				{STR0005,"DATINI", "D", 08, 0, "@!" },;					//"Data Inicio"
				{STR0006,"HORINI", "C", 05, 0, "@!" },;					//"Hora Inicio"
				{STR0007,"CONINI", "N", 09, 2, "@E 999.999.99"},;		//"Contador Inicio"
				{STR0008,"DATFIM", "D", 08, 0, "@!" },;					//"Data Fim"
				{STR0009,"HORFIM", "C", 05, 0, "@!" },;					//"Hora Fim"
				{STR0010,"CONFIM", "N", 09, 2, "@E 999.999.99"},;		//"Contador Fim"
				{STR0011,"QTDREG", "N", 09, 2, "@E 999.999.99"},;		//"Qtde. Registrada"
				{STR0012,"QTDABA", "N", 09, 2, "@E 999.999.99"},;		//"Qtde. Abastecida"
				{STR0013,"QTDSAI", "N", 09, 2, "@E 999.999.99"}} 		//"Qtde. Saida"

	//Intancia classe FWTemporaryTable
	oTempTable := FWTemporaryTable():New( cTRBC657, aDBF )
	//Cria indices
	oTempTable:AddIndex( "Ind01" , {"POSTO","LOJA","TANQUE","BOMBA","DATINI","HORINI"}  )
	//Cria a tabela temporaria
	oTempTable:Create()

	If pergunte(cPerg,.T.)
		Processa({ |lEnd| MNC657TRB() },STR0021) //"Aguarde... Carregando."

		DbSelectarea(cTRBC657)
		DbGotop()

		//Cria Array para montar a chave de pesquisa
		aAdd( aPesq, {STR0002 + " + " + STR0003 + " + " + STR0004 + " + " + STR0033 + " + " + STR0005 + " + " + STR0006, {{"","C" , 255 , 0 ,"","@!"} }} ) // Indices de pesquisa

		oBrowse:= FWMBrowse():New()
		oBrowse:SetDescription(cCadastro)
		oBrowse:SetTemporary(.T.)
		oBrowse:SetAlias(cTRBC657)
		oBrowse:SetFields(aTRB)
		oBrowse:SetSeek(.T.,aPesq)
		oBrowse:Activate()

	Endif

	oTempTable:Delete()

Return .T.
/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³ MenuDef  ³ Autor ³ Rafael Diogo Richter  ³ Data ³02/02/2008³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³Utilizacao de Menu Funcional.                               ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ SigaMNT                                                    ³±±
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
±±ÃÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³         ATUALIZACOES SOFRIDAS DESDE A CONSTRU€AO INICIAL.             ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Programador ³ Data   ³ F.O  ³  Motivo da Alteracao                     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³            ³        ³      ³                                          ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Static Function MenuDef()
	Local aRotina :=	{{STR0023,"MNT657ABA" , 0 , 2},; //"Abastecimentos"
						{STR0024 ,"MNT657SAI" , 0 , 3},; //"Saidas"
						{STR0025 ,"MNT657REL" , 0 , 4}}  //"Imprimir"
Return aRotina

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³MNT657REL ³ Autor ³Elisangela Costa       ³ Data ³30/06/04  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³Impressao de Solicitacoes de Servivo atendidas              ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³MNTR657                                                     ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function MNT657REL()

	Local cString    := "TTH"
	Local cDesc1     := STR0026 //"Relatório de Aferições"
	Local cDesc2     := ""
	Local cDesc3     := ""
	Local wnrel      := "MNTC657"

	Private aReturn  := {STR0027, 1,STR0028, 1, 2, 1, "",1 } //"Zebrado"###"Administracao"
	Private nLastKey := 0
	Private Titulo   := cDesc1
	Private Tamanho  := "G"

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Envia controle para a funcao SETPRINT                        ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	wnrel:=SetPrint(cString,wnrel,,titulo,cDesc1,cDesc2,cDesc3,.F.,"")
	If nLastKey = 27
		Set Filter To
		Return
	Endif

	SetDefault(aReturn,cString)
	RptStatus({|lEnd| C657Imp(@lEnd,wnRel,titulo,tamanho)},titulo)

	DbSelectArea("TTH")

Return Nil

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³ C657Imp  ³ Autor ³Elisangela Costa       ³ Data ³ 30/06/04 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Impressao do Relatorio                                     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ MNT657REL                                                  ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function C657Imp(lEnd,wnRel,titulo,tamanho)
	Local cRodaTxt := ""
	Local nCntImpr := 0
	Local cPostoOld := '', cBombaOld := ''
	Private li := 80
	Private m_pag := 1

	nTipo  := IIF(aReturn[4]==1,15,18)

	Private Cabec1   := STR0029 //"______________Inicial______________   ______________Final______________   _______________________Litros______________________"
	Private Cabec2   := STR0030 //"Data         Hora          Contador   Data         Hora        Contador   Registrados   Abastecidos       Saídas    Diferença"
	Private nomeprog := "MNTC657"

	/*
	1         2         3         4         5         6         7         8         9         0         1         2
	01234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234
	______________Inicial______________   ______________Final______________   _______________________Litros______________________
	Data         Hora          Contador   Data         Hora        Contador   Registrados   Abastecidos       Saídas    Diferença
	99/99/9999   99:99       999,999.99   99/99/9999   99:99     999,999.99    999,999.99    999,999.99   999,999.99   999,999.99

	Posto / Loja: xxxxxxxxxxxxxxxxxxxx
	Tanque / Bomba : xxx / xx

	_____________________________________________________________________________________________________________________________________________________________________________________________________________________________

	*/
	DbSelectArea(cTRBC657)
	dbSetOrder(1)
	DbGoTop()
	SetRegua(LastRec())
	While !(cTRBC657)->(Eof())
		IncRegua()

		If cPostoOld != (cTRBC657)->POSTO+(cTRBC657)->LOJA+(cTRBC657)->TANQUE
			If !Empty(cPostoOld)
				NgSomaLi(58)
				@Li,000 Psay __PrtThinLine()
			Endif
			NgSomaLi(58)
			@Li,000 Psay STR0031 + AllTrim((cTRBC657)->POSTO)  + ' / ' + AllTrim((cTRBC657)->LOJA) + ' - ' + AllTrim(NGSEEK("TQF",(cTRBC657)->POSTO+(cTRBC657)->LOJA,1,"TQF_NREDUZ")) //"Posto : "
			NgSomaLi(58)
			@Li,000 Psay STR0032 + (cTRBC657)->TANQUE //"Tanque: "
			PrintNoBom()
			If cBombaOld == (cTRBC657)->BOMBA
				NgSomaLi(58)
				NgSomaLi(58)
			Endif
		Endif

		If cBombaOld != (cTRBC657)->BOMBA
			NgSomaLi(58)
			NgSomaLi(58)
			@Li,000 Psay STR0033 + (cTRBC657)->BOMBA //"Bomba: "
			NgSomaLi(58)
		Endif

		NgSomaLi(58)

		cPostoOld := (cTRBC657)->POSTO+(cTRBC657)->LOJA+(cTRBC657)->TANQUE
		cBombaOld := (cTRBC657)->BOMBA

		@Li,000 Psay (cTRBC657)->DATINI Picture "99/99/9999"
		@Li,013 Psay (cTRBC657)->HORINI Picture "99:99"
		@Li,025 Psay (cTRBC657)->CONINI Picture "999,999.99"

		@Li,038 Psay (cTRBC657)->DATFIM Picture "99/99/9999"
		@Li,051 Psay (cTRBC657)->HORFIM Picture "99:99"
		@Li,061 Psay (cTRBC657)->CONFIM Picture "999,999.99"

		@Li,075 Psay (cTRBC657)->QTDREG Picture "999,999.99"
		@Li,089 Psay (cTRBC657)->QTDABA Picture "999,999.99"
		@Li,102 Psay (cTRBC657)->QTDSAI Picture "999,999.99"

		@Li,115 Psay (cTRBC657)->QTDREG-(cTRBC657)->QTDABA-(cTRBC657)->QTDSAI Picture "999,999.99"
		If (cTRBC657)->QTDSAI != 0
			PrintSaida()
		Endif

		(cTRBC657)->(DbSkip())
	End

	Roda(nCntImpr,cRodaTxt,Tamanho)
	Set Filter To
	Set Device To Screen

	If aReturn[5] = 1
		Set Printer To
		dbCommitAll()
		OurSpool(wnrel)
	EndIf
	MS_FLUSH()

Return Nil

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³MNC657TRB ³ Autor ³Marcos Wagner Junior   ³ Data ³ 07/10/10 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Criacao da TRB			                                   ±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ MNTC657                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function MNC657TRB()
	Local aOldArea := GetArea()

	dbSelectArea("TQL")
	dbSetOrder(01)
	dbSeek(xFilial("TQL"))
	While !Eof() .AND. xFilial("TQL") == TQL->TQL_FILIAL
		If (TQL->TQL_POSTO+TQL->TQL_LOJA >= MV_PAR03+MV_PAR04) .AND. (TQL->TQL_POSTO+TQL->TQL_LOJA <= MV_PAR05+MV_PAR06) .AND.;
		(TQL->TQL_DTCOLE >= MV_PAR01 .AND. TQL->TQL_DTCOLE <= MV_PAR02)
			dbSelectArea(cTRBC657)
			RecLock(cTRBC657,.t.)
			(cTRBC657)->POSTO  := TQL->TQL_POSTO
			(cTRBC657)->LOJA   := TQL->TQL_LOJA
			(cTRBC657)->TANQUE := TQL->TQL_TANQUE
			(cTRBC657)->BOMBA  := TQL->TQL_BOMBA
			(cTRBC657)->DATINI := TQL->TQL_DTCOLE
			(cTRBC657)->HORINI := TQL->TQL_HRINIC
			(cTRBC657)->CONINI := TQL->TQL_POSINI
			(cTRBC657)->DATFIM := TQL->TQL_DTCOLE
			(cTRBC657)->HORFIM := TQL->TQL_HRFIM
			(cTRBC657)->CONFIM := TQL->TQL_POSFIM
			(cTRBC657)->QTDREG := TQL->TQL_CONSUM
			(cTRBC657)->QTDABA := TRB657ABA(TQL->TQL_DTCOLE,TQL->TQL_HRINIC,TQL->TQL_HRFIM,TQL->TQL_POSTO,TQL->TQL_LOJA,TQL->TQL_TANQUE)
			(cTRBC657)->QTDSAI := TRB657SAI(TQL->TQL_DTCOLE,TQL->TQL_HRINIC,TQL->TQL_HRFIM,TQL->TQL_POSTO,TQL->TQL_LOJA,TQL->TQL_TANQUE)
			(cTRBC657)->ORDENA := INVERTE(TQL->TQL_DTCOLE)
			(cTRBC657)->(MsUnlock())
		Endif
		dbSelectArea("TQL")
		dbSkip()
	End

	RestArea(aOldArea)

Return .t.

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³TRB657ABA ³ Autor ³Marcos Wagner Junior   ³ Data ³ 07/10/10 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Litragem do abastecimento no dia, entre o horario informado³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ MNTC657                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function TRB657ABA(_dDtAbas,_cHrIni,_cHrFim,_cPosto,_cLoja,_cTanque)
	Local aOldArea := GetArea()
	Local nQtde := 0

	dbSelectArea("TQN")
	dbSetOrder(03)
	If dbSeek(xFilial("TQN")+_cPosto+_cLoja+DTOS(_dDtAbas))
		While !Eof() .AND. TQN->TQN_POSTO == _cPosto .AND. TQN->TQN_LOJA == _cLoja .AND. TQN->TQN_DTABAS == _dDtAbas
			If (TQN->TQN_HRABAS >= _cHrIni .AND. TQN->TQN_HRABAS <= _cHrFim) .AND. TQN->TQN_TANQUE == _cTanque
				nQtde += TQN->TQN_QUANT
			Endif
			dbSelectArea("TQN")
			dbSkip()
		End
	Endif

	RestArea(aOldArea)

Return nQtde

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³TRB657SAI ³ Autor ³Marcos Wagner Junior   ³ Data ³ 07/10/10 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Litragem das saidas no dia, entre o horario informado      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ MNTC657                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function TRB657SAI(_dDtAbas,_cHrIni,_cHrFim,_cPosto,_cLoja,_cTanque)
	Local aOldArea := GetArea()
	Local nQtde := 0

	dbSelectArea("TTH")
	dbSetOrder(01)
	If dbSeek(xFilial("TTH")+_cPosto+_cLoja+_cTanque)
		While !Eof() .AND. TTH->TTH_POSTO == _cPosto .AND. TTH->TTH_LOJA == _cLoja .AND. TTH->TTH_TANQUE == _cTanque
			If TTH->TTH_DTABAS == _dDtAbas .AND. TTH->TTH_HRABAS >= _cHrIni .AND. TTH->TTH_HRABAS <= _cHrFim .AND. !Empty(TTH->TTH_BOMBA)
				nQtde += TTH->TTH_QUANT
			Endif
			dbSelectArea("TTH")
			dbSkip()
		End
	Endif

	RestArea(aOldArea)

Return nQtde

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³MNT657ABA ³ Autor ³ In cio Luiz Kolling   ³ Data ³ 07/10/10 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Lista os abastecimentos no dia, entre o horario informado  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ MNTC657                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function MNT657ABA()
	Local aOldArea := GetArea()
	Local aTMPFIELD ,bTMPFUNC,  cTMPBRW, lTemRot := .f.
	Private aIndTQN := {}, bFiltraBrw := {|| Nil}
	Private cCondTQN, cFilIniTQN

	If Type("aRotina") = "A"
		aOldRotina := aClone(aRotina)
		cOldCADASTRO := cCADASTRO
		lTemRot  := .t.
	Endif

	aRotina := {{STR0022,"PesqBrw" , 0, 1},; //"Pesquisar"
	{STR0034,"NGCAD01", 0, 2}} //"Visualizar"
	AAdd(aRotina,{STR0035,"MNC657FAB()",0,3}) //"Filtro"

	cCADASTRO := OEMTOANSI(STR0023) //"Abastecimentos"

	lNovoBrw := .f.
	If lNovoBrw
		cCondTQN := 'TQN_FILIAL = "' + xFilial("TQN") + '"' + ' And TQN_POSTO = "'+(cTRBC657)->POSTO + '" And '
		cCondTQN += 'TQN_LOJA   = "' + (cTRBC657)->LOJA + '"' + ' And TQN_TANQUE = "'+(cTRBC657)->TANQUE + '" And '
		cCondTQN += 'TQN_DTABAS >= "' + DTOS((cTRBC657)->DATINI) + '" And TQN_HRABAS >= "'+(cTRBC657)->HORINI + '" And '
		cCondTQN += 'TQN_DTABAS <= "' + DTOS((cTRBC657)->DATFIM) + '" And TQN_HRABAS <= "'+(cTRBC657)->HORFIM + '"'
		cFilIniTQN := cCondTQN

		MBROWSE(6,1,22,75,'TQN',,,,,,,,,,,,,,cCondTQN)
	Else
		cCondTQN := 'TQN_FILIAL = "' + xFilial("TQN") + '"' + ' .And. TQN_POSTO = "'+(cTRBC657)->POSTO + '" .And. '
		cCondTQN += 'TQN_LOJA   = "' + (cTRBC657)->LOJA + '"' + ' .And. TQN_TANQUE = "'+(cTRBC657)->TANQUE + '" .And. '
		cCondTQN += 'DTOS(TQN_DTABAS) >= "' + DTOS((cTRBC657)->DATINI) + '" .And. TQN_HRABAS >= "'+(cTRBC657)->HORINI + '" .And. '
		cCondTQN += 'DTOS(TQN_DTABAS) <= "' + DTOS((cTRBC657)->DATFIM) + '" .And. TQN_HRABAS <= "'+(cTRBC657)->HORFIM + '"'
		cFilIniTQN := cCondTQN

		bFiltraBrw := {|| FilBrowse('TQN',@aIndTQN,@cCondTQN)}
		Eval(bFiltraBrw)

		nINDTQN := INDEXORD()
		mBrowse( 6, 1, 22, 75, 'TQN',,,,,,)

		aEval(aIndTQN,{|x| Ferase(x[1]+OrdBagExt())})
		ENDFILBRW('TQN',aIndTQN)
	EndIf

	If lTemRot
		aRotina   := Aclone(aOldRotina)
		cCADASTRO := cOldCADASTRO
	Endif

	RestArea(aOldArea)

Return .t.

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³MNT657SAI ³ Autor ³Marcos Wagner Junior   ³ Data ³ 07/10/10 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Litragem das saidas no dia, entre o horario informado      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ MNTC657                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function MNT657SAI()
	Local aOldArea := GetArea()
	Local aTMPFIELD ,bTMPFUNC,  cTMPBRW, lTemRot := .f.
	Private aIndTTH := {}, bFiltraBrw := {|| Nil}
	Private cCondTTH, cFilIniTTH

	If Type("aRotina") = "A"
		aOldRotina := aClone(aRotina)
		cOldCADASTRO := cCADASTRO
		lTemRot  := .t.
	Endif

	aRotina := {{STR0022,"PesqBrw" , 0, 1},;  //"Pesquisar"
				{STR0034,"NGCAD01" , 0, 2}}   //"Visualizar"
	AAdd(aRotina,{STR0035,"MNC657FSA()",0,3}) //"Filtro"

	cCADASTRO := OEMTOANSI(STR0036) //"Saídas"

	lNovoBrw := .f.
	If lNovoBrw
		cCondTTH := "TTH_FILIAL = '" + xFilial("TTH") + "'" + " And TTH_POSTO = '"+(cTRBC657)->POSTO + "' And "
		cCondTTH += "TTH_LOJA   = '" + (cTRBC657)->LOJA + "'" + " And TTH_TANQUE = '"+(cTRBC657)->TANQUE + "' And "
		cCondTTH += "TTH_DTABAS >= '" + DTOS((cTRBC657)->DATINI) + "' And TTH_HRABAS >= '"+(cTRBC657)->HORINI + "' And "
		cCondTTH += "TTH_DTABAS <= '" + DTOS((cTRBC657)->DATFIM) + "' And TTH_HRABAS <= '"+(cTRBC657)->HORFIM + "'"
		cFilIniTTH := cCondTTH

		MBROWSE(6,1,22,75,'TTH',,,,,,,,,,,,,,cCondTTH)
	Else
		cCondTTH := "TTH_FILIAL = '" + xFilial("TTH") + "'" + " .And. TTH_POSTO = '"+(cTRBC657)->POSTO + "' .And. "
		cCondTTH += "TTH_LOJA   = '" + (cTRBC657)->LOJA + "'" + " .And. TTH_TANQUE = '"+(cTRBC657)->TANQUE + "' .And. "
		cCondTTH += "DTOS(TTH_DTABAS) >= '" + DTOS((cTRBC657)->DATINI) + "' .And. TTH_HRABAS >= '"+(cTRBC657)->HORINI + "' .And. "
		cCondTTH += "DTOS(TTH_DTABAS) <= '" + DTOS((cTRBC657)->DATFIM) + "' .And. TTH_HRABAS <= '"+(cTRBC657)->HORFIM + "'"
		cFilIniTTH := cCondTTH

		bFiltraBrw := {|| FilBrowse('TTH',@aIndTTH,@cCondTTH)}
		Eval(bFiltraBrw)

		nINDTTH := INDEXORD()
		mBrowse( 6, 1, 22, 75, 'TTH',,,,,,)

		aEval(aIndTTH,{|x| Ferase(x[1]+OrdBagExt())})
		ENDFILBRW('TTH',aIndTTH)
	EndIf

	If lTemRot
		aRotina   := Aclone(aOldRotina)
		cCADASTRO := cOldCADASTRO
	Endif

	RestArea(aOldArea)

Return .t.

/*/
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³MNC657FSA  ³ Autor ³Marcos Wagner Junior  ³ Data ³20/12/2008³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³Filtra as saidas.                         						  ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function MNC657FSA()
	Local cFilTTH

	dbSelectArea('TTH')
	ENDFILBRW('TTH',aIndTTH)
	cCondTTH   := BuildExpr('TTH',,cCondTTH,.F.)

	If !Empty(cCondTTH)
		cCondTTH := cFilIniTTH + '.And. ' + cCondTTH
	Else
		cCondTTH := cFilIniTTH
	Endif

	dbSelectArea('TTH')
	Set Filter To
	bFiltraBrw := {|| FilBrowse('TTH',@aIndTTH,@cCondTTH) }
	Eval(bFiltraBrw)

Return .T.

/*/
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³MNC657FAB  ³ Autor ³Marcos Wagner Junior  ³ Data ³20/12/2008³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³Filtra as saidas.                         						  ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function MNC657FAB()
	Local cFilTTH

	dbSelectArea('TQN')
	ENDFILBRW('TQN',aIndTQN)
	cCondTQN   := BuildExpr('TQN',,cCondTQN,.F.)

	If !Empty(cCondTQN)
		cCondTQN := cFilIniTQN + '.And. ' + cCondTQN
	Else
		cCondTQN := cFilIniTQN
	Endif

	dbSelectArea('TQN')
	Set Filter To
	bFiltraBrw := {|| FilBrowse('TQN',@aIndTQN,@cCondTQN) }
	Eval(bFiltraBrw)

Return .t.

/*/
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³PrintSaida ³ Autor ³Marcos Wagner Junior  ³ Data ³14/10/2010³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³Imprime as saidas                        						  ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Static Function PrintSaida()
	Local aOldArea := GetArea()
	Local lFirst := .t.

	dbSelectArea("TTH")
	dbSetOrder(01)
	If dbSeek(xFilial("TTH")+(cTRBC657)->POSTO+(cTRBC657)->LOJA+(cTRBC657)->TANQUE+(cTRBC657)->BOMBA+DTOS((cTRBC657)->DATINI))
		NgSomaLi(58)
		@Li,000 Psay STR0037 //"Saída: "
		While !Eof() .AND. TTH->TTH_POSTO == (cTRBC657)->POSTO .AND. TTH->TTH_LOJA == (cTRBC657)->LOJA .AND. TTH->TTH_TANQUE == (cTRBC657)->TANQUE;
		.AND. TTH->TTH_BOMBA == (cTRBC657)->BOMBA .AND. TTH->TTH_DTABAS == (cTRBC657)->DATINI
			If TTH->TTH_HRABAS >= (cTRBC657)->HORINI .AND. TTH->TTH_HRABAS <= (cTRBC657)->HORFIM
				If !lFirst
					NgSomaLi(58)
				Endif
				lFirst := .f.
				@Li,007 Psay AllTrim(NGSEEK("TTX",TTH->TTH_MOTIV2,1,"TTX_DESCRI"))
				@Li,102 Psay TTH->TTH_QUANT Picture "999,999.99"
			Endif
			dbSelectArea("TTH")
			dbSkip()
		End
	Endif

	RestArea(aOldArea)

Return

/*/
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³PrintNoBom ³ Autor ³Marcos Wagner Junior  ³ Data ³14/10/2010³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³Imprime as saidas que nao estao relacionadas a bombas       ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Static Function PrintNoBom()
	Local aOldArea := GetArea()
	Local lFirst := .t.

	dbSelectArea("TTH")
	dbSetOrder(01)
	If dbSeek(xFilial("TTH")+(cTRBC657)->POSTO+(cTRBC657)->LOJA+(cTRBC657)->TANQUE+'   '+DTOS((cTRBC657)->DATINI))
		NgSomaLi(58)
		@Li,000 Psay STR0037 //"Saída: "

		While !Eof() .AND. TTH->TTH_POSTO == (cTRBC657)->POSTO .AND. TTH->TTH_LOJA == (cTRBC657)->LOJA .AND. TTH->TTH_TANQUE == (cTRBC657)->TANQUE;
		.AND. TTH->TTH_DTABAS == (cTRBC657)->DATINI .AND. Empty(TTH->TTH_BOMBA)
			If TTH->TTH_HRABAS >= (cTRBC657)->HORINI .AND. TTH->TTH_HRABAS <= (cTRBC657)->HORFIM
				If !lFirst
					NgSomaLi(58)
				Endif
				lFirst := .f.
				@Li,007 Psay AllTrim(NGSEEK("TTX",TTH->TTH_MOTIV2,1,"TTX_DESCRI"))
				@Li,102 Psay TTH->TTH_QUANT Picture "999,999.99"
			Endif
			dbSelectArea("TTH")
			dbSkip()
		End
	Endif

	RestArea(aOldArea)

Return

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³ATECD657  ³ Autor ³ Marcos Wagner Junior  ³ Data ³14/10/2010³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³Validaçao do codigo do Posto Interno                        ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³MNTC845                                                     ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function ATECD657(ALIAS,PAR1,PAR2,TAM)

	If MV_PAR05 == Replicate('Z',TAMSX3("A2_COD")[1])
		Return .t.
	Endif

	If Empty(par2)
		Help(" ",1,STR0038,,STR0039,3,1) //"ATENÇÃO"###"Posto Interno final não pode ser vazio."
		Return .f.
	Elseif par2 < par1
		Help(" ",1,STR0038,,STR0040,3,1) //"ATENÇÃO"###"Posto Interno final informado é inválido."
		Return .f.
	Endif

	If par2 = replicate('Z',Len(PAR2))
		Return .t.
	Else
		If !Atecodigo('TQF',Par1+Mv_Par04,Par2+Mv_Par06,08)
			Return .f.
		Endif
	Endif

Return .t.

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³MNC657LO  ³ Autor ³ Marcos Wagner Junior  ³ Data ³14/10/2010³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³Valida o parametro de Loja                                  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³MNTC845                                                     ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function MNC657LO()

	If MV_PAR06 == Replicate('Z',TAMSX3("A2_LOJA")[1])
		Return .T.
	Endif

	If Empty(MV_PAR05)
		MsgStop(STR0041) //"Informe o Codigo do Posto"
		Return .F.
		If !Empty(MV_PAR05)
			DbSelectArea("TQF")
			DbSetOrder(01)
			DbSeek (xFilial("TQF")+MV_PAR06)
			MV_PAR05 := TQF->TQF_CODIGO
		EndIf
	EndIf
	If !ExistCpo("TQF",MV_PAR05+MV_PAR06)
		Return .F.
	EndIf

Return .T.

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³MNC657LOJA³ Autor ³ Marcos Wagner Junior  ³ Data ³14/10/2010³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³Valida o parametro de Loja                                  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³MNTC845                                                     ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function MNC657LOJA()

	If MV_PAR04 == Replicate(' ',TAMSX3("A2_LOJA")[1])
		Return .t.
	Endif

	If Empty(MV_PAR03)
		MsgStop(STR0042) //"Informe o Código do Posto"
		Return .F.
		If !Empty(MV_PAR03)
			DbSelectArea("TQF")
			DbSetOrder(01)
			DbSeek (xFilial("TQF")+MV_PAR04)
			MV_PAR03 := TQF->TQF_CODIGO
		EndIf
	EndIf
	If !ExistCpo("TQF",MV_PAR03+MV_PAR04)
		Return .F.
	EndIf

Return .T.