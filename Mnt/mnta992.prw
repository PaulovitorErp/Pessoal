#INCLUDE "MNTA992.ch"
#INCLUDE "PROTHEUS.CH"

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Programa  ³ MNTA992   ³ Autor ³Vitor Emanuel Batista ³ Data ³05/08/2009³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³Reporte de Horas da Mao de Obra                             ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³SIGAMNT                                                     ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function MNTA992()

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Guarda conteudo e declara variaveis padroes ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	Local aNGBEGINPRM := NGBEGINPRM()

	Private aRotina := MenuDef()

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Define o cabecalho da tela de atualizacoes                   ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	Private cCadastro := OemtoAnsi(STR0001) //"Reporte de Horas da Mao de Obra"
	Private bNGGrava  :=	{|| MNT992TUDOK() }

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Endereca a funcao de BROWSE                                  ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

	dbSelectArea("TTL")
	dbSetOrder(1)
	mBrowse( 6, 1,22,75,"TTL")

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Retorna conteudo de variaveis padroes       ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	NGRETURNPRM(aNGBEGINPRM)

Return Nil

//---------------------------------------------------------------------
/*/{Protheus.doc} MNT992TUDOK
Valida inclusao do reporte de horas

@author	Vitor Emanuel Batista
@since	31/08/2009

Return lRet, Lógico, Valor que confere se registro é valido.

/*/
//---------------------------------------------------------------------
Static Function MNT992TUDOK()
	Local nRecno := Nil
	Local lRet	 := .T.
	Local aArea  := GetArea()

	If INCLUI .Or. ALTERA
		If Empty(StrTran(M->TTL_HRFIM, ":", "", 1))
			lRet := .F.
			Help(1," ","OBRIGAT2",,NGRETTITULO("TTL_HRFIM"),3,0)
		EndIf
		If lRet .And. Empty(StrTran(M->TTL_HRINI, ":", "", 1))
			lRet := .F.
			Help(1," ","OBRIGAT2",,NGRETTITULO("TTL_HRINI"),3,0)
		EndIf
		If lRet .And. !NGVALDATIN(M->TTL_CODFUN,,,M->TTL_DTINI,M->TTL_HRINI,M->TTL_DTFIM,M->TTL_HRFIM,"M",,"STL")[1]
			lRet := .F.
		EndIf
		If lRet .And. !NGVALDATIN(M->TTL_CODFUN,,,M->TTL_DTINI,M->TTL_HRINI,M->TTL_DTFIM,M->TTL_HRFIM,"M",,"STT ")[1]
			lRet := .F.
		EndIf
		If lRet .And. !NGFUNCRH(M->TTL_CODFUN,.T.,M->TTL_DTFIM)
			lRet := .F.
		EndIf

		If lRet .And. ALTERA
			nRecno := TTL->(Recno())
		EndIf

		//Verifica se funcionario ja nao esta alocado no intervalo de data/hora
		If lRet .And. (!NGVDTINS(M->TTL_CODFUN,M->TTL_DTINI,M->TTL_HRINI,M->TTL_DTFIM,M->TTL_HRFIM,"M") .Or. ;
			!NGVDTHRTTL(M->TTL_CODFUN,M->TTL_DTINI,M->TTL_HRINI,M->TTL_DTFIM,M->TTL_HRFIM,nRecno))
			lRet := .F.
		EndIf
	EndIf

	If lRet .And. ExistBlock("MNTA9921")// Verifica se existe o ponto de entrada
		If ExecBlock("MNTA9921",.F.,.F.)
			lRet := .F.
		EndIf
	EndIf

	RestArea(aArea)
Return lRet

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    NGVDTHRTTL Autor ³Vitor Emanuel Batista ³ Data ³31/08/2009³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³Valida inclusao do reporte de horas                         ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³MNTA992                                                     ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function NGVDTHRTTL(cCodFun,dDataIni,cHoraIni,dDataFim,cHoraFim,nRecno)
	Local lRecno := nRecno!=Nil

	Local cHrIniTemp := cHoraIni
	Local cHrFimTemp := cHoraFim
	Local dDtIniTemp := dDataIni
	Local dDtFimTemp := cHoraFim

	//Validacao para permitir insumos no mesmo intervalo de data/hora inicio/fim
	If cHoraIni == '23:59'
		dDataIni += 1
	EndIf
	If cHoraFim == '00:00'
		dDataFim -= 1
	EndIf
	cHoraIni := MTOH(HTOM(cHoraIni)+1)
	cHoraFim := MTOH(HTOM(cHoraFim)-1)

	cAliasQry := GetNextAlias()
	cQuery := " SELECT TTL_TPHORA,TTL_QUANTI,TTL_DTINI,TTL_HRINI,TTL_DTFIM,TTL_HRFIM "
	cQuery += " FROM "+NGRETX2("TTL")+" TTL"
	cQuery += " WHERE TTL.TTL_CODFUN = "+ValToSql(cCodFun)+" AND "+RetSqlCond("TTL")
	cQuery += "     AND (("+ValToSql(DtoS(dDataIni)+cHoraIni)+" BETWEEN TTL.TTL_DTINI||TTL.TTL_HRINI AND TTL.TTL_DTFIM||TTL.TTL_HRFIM"
	cQuery += "      OR "+ValToSql(DtoS(dDataFim)+cHoraFim)+"  BETWEEN TTL.TTL_DTINI||TTL.TTL_HRINI  AND TTL.TTL_DTFIM||TTL.TTL_HRFIM)"
	cQuery += "      OR (TTL.TTL_DTINI||TTL.TTL_HRINI BETWEEN "+ValToSql(DtoS(dDataIni)+cHoraIni)+" AND "+ValToSql(DtoS(dDataFim)+cHoraFim)
	cQuery += "      OR TTL.TTL_DTFIM||TTL.TTL_HRFIM  BETWEEN "+ValToSql(DtoS(dDataIni)+cHoraIni)+" AND "+ValToSql(DtoS(dDataFim)+cHoraFim)+"))"
	If lRecno
		cQuery += " AND TTL.R_E_C_N_O_<> "+cValToChar(nRecno)
	EndIf
	cQuery += " ORDER BY "+TTL->(SqlOrder(IndexKey(1)))

	cQuery := ChangeQuery(cQuery)
	dbUseArea( .T., "TOPCONN", TCGENQRY(,,cQuery),cAliasQry, .F., .T.)

	//Retorna valores iniciais das variaveis
	cHoraIni := cHrIniTemp
	cHoraFim := cHrFimTemp
	dDataIni := dDtIniTemp
	dDataFim := dDtFimTemp

	dbSelectArea(cAliasQry)
	dbGoTop()
	If !Eof()
		MsgInfo(	STR0005+ CHR(13) + CHR(13)+; //"Já existe aplicação de insumo no intervalo de Data/Hora informada."
					STR0006 + CHR(13) + CHR(13) + ; //"Aplicação do insumo já existente pelo Reporte de Horas:"
					STR0007 + AllTrim((cAliasQry)->TTL_TPHORA) + " - " + AllTrim(NGSEEK("TTJ",(cAliasQry)->TTL_TPHORA,1,"TTJ->TTJ_DESCRI")) + CHR(13) + ; //"Tipo de Hora.: "
					STR0008 + DTOC(STOD((cAliasQry)->TTL_DTINI)) + CHR(13) + ; //"Data Início.....: "
					STR0009 + (cAliasQry)->TTL_HRINI + CHR(13) + ; //"Hora Início.....: "
					STR0010 + DTOC(STOD((cAliasQry)->TTL_DTFIM)) + CHR(13) + ; //"Data Fim........: "
					STR0011 + (cAliasQry)->TTL_HRFIM,STR0012) //"Hora Fim........: "###"NAO CONFORMIDADE"
		Return .F.
	EndIf
Return .T.

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Programa  ³MenuDef   ³ Autor ³Vitor Emanuel Batista  ³ Data ³05/08/2009³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Utilizacao de menu Funcional                               ³±±
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

	Local aRotina := {	{	STR0013	,	"AxPesqui"	,	0	,	1	},; //"Pesquisar" //"Pesquisar"
								{	STR0014,	"NGCAD01"	,	0	,	2	},; //"Visualizar" //"Visualizar"
								{	STR0015	,	"MNTA992CAD"	,	0	,	3	},; //"Incluir" //"Incluir"
								{	STR0016	,	"MNTA992CAD"	,	0	,	4	},; //"Alterar" //"Alterar"
								{	STR0017	,	"NGCAD01"	,	0	,	5,	3} } //"Excluir" //"Excluir"
Return(aRotina)

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³ MNTA992  ³ Autor ³ Marcos Wagner Junior  ³ Data ³ 05/05/10 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Funcao do botao "Incluir" e do botao "Alterar"             ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ MNTA035()                                                  ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function MNTA992CAD(cAlias,nReg,nOpcx)

Local cTipoHora := ''

Private cTpHoraAnt := ''
Private cFuncioAnt := ''
Private cDtHrAnt := ''

If nOpcx == 4
	cTpHoraAnt := TTL->TTL_TPHORA
	cFuncioAnt := TTL->TTL_CODFUN
	cDtHrAnt := DTOS(TTL->TTL_DTINI)+DTOS(TTL->TTL_DTFIM)+TTL->TTL_HRINI+TTL->TTL_HRFIM
Endif

nRet := NGCAD01(cAlias,nReg,nOpcx)

dbSelectArea("TTJ")
dbSetOrder(1)
If dbSeek( xFilial("TTJ")+TTL->TTL_TPHORA)
	If TTJ->TTJ_USACAL == "S"
		cTipoHora := "S"
	Else
		cTipoHora := GETMV("MV_NGUNIDT")
	EndIf
EndIf

If nRet == 1
	RecLock("TTL",.f.)
	TTL->TTL_TIPOHO := cTipoHora
	TTL->(MsUnlock())
Endif
cTpHoraAnt := ''
cFuncioAnt := ''

Return .T.

/*/
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³MNTA992CHK ³ Autor ³ Marcos Wagner Junior ³ Data ³ 05/05/10 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³Pre-consistencia da quantidade do insumo                    ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³MNTA400                                                     ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function MNTA992CHK()

If !NGVALQUANT('M','H',M->TTL_QUANTI,.t.,cCalend)
   Return .f.
Endif

Return .t.

/*/
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³NGCALDTHO ³ Autor ³Inacio Luiz Kolling    ³ Data ³30/09/2005³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³Calcula a data e hora inicio a partir de uma data e hora fim³±±
±±³          ³e quantidade ou vise-versa. Dependendo utiliza calend rio   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³GENERICA                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function MNT992DTHR()

	Local cUsaCale := ''
	Local cCALE := ''

	cREADVAR := Readvar()

	If (cREADVAR == "M->TTL_TPHORA" .AND. cTpHoraAnt <> M->TTL_TPHORA) .OR.;
		(cREADVAR == "M->TTL_CODFUN" .AND. cFuncioAnt <> M->TTL_CODFUN)
		M->TTL_DTINI := STOD('  /  /  ')
		M->TTL_HRINI := '  :  '
		M->TTL_DTFIM := STOD('  /  /  ')
		M->TTL_HRFIM :=  '  :  '
		M->TTL_QUANTI := 0
		cTpHoraAnt := M->TTL_TPHORA
		cFuncioAnt := M->TTL_CODFUN
		Return .T.
	EndIf

	If cREADVAR == "M->TTL_HRINI" .And. Empty(StrTran(M->TTL_HRINI, ":", "", 1 )) .Or.;
		cREADVAR == "M->TTL_HRFIM" .And. Empty(StrTran(M->TTL_HRFIM, ":", "", 1 ))
		Return .T.
	EndIf

	dbSelectArea("TTJ")
	dbSetOrder(1)
	If dbSeek(xFilial("TTJ")+M->TTL_TPHORA)
		cUsaCale := TTJ->TTJ_USACAL
	EndIf

	If cREADVAR == "M->TTL_QUANTI" .AND. !Empty(cUsaCale)
		If !NGVALQUANT('M','H',M->TTL_QUANTI,.T.,cUsaCale)
			Return .F.
		EndIf
	EndIf

	dbSelectArea("ST1")
	dbSetOrder(01)
	If dbSeek(xFilial("ST1")+M->TTL_CODFUN)
		cCALE := ST1->T1_TURNO
	EndIf

	If cREADVAR == "M->TTL_DTINI" .And. cUsaCale == "S" .And. !Empty(M->TTL_DTINI) .And. !Empty(StrTran(M->TTL_HRINI, ":", "", 1 ))
		If !NGVALHRCALE(cCALE,M->TTL_DTINI,M->TTL_HRINI,"I")
			Return .F.
		EndIf
	ElseIf cREADVAR == "M->TTL_HRINI" .And. cUsaCale == "S" .And. !Empty(M->TTL_DTINI) .And. !Empty(StrTran(M->TTL_HRINI, ":", "", 1 ))
		If !NGVALHRCALE(cCALE,M->TTL_DTINI,M->TTL_HRINI,"I")
			Return .F.
		EndIf
	ElseIf cREADVAR == "M->TTL_DTFIM" .And. cUsaCale == "S" .And. !Empty(StrTran(M->TTL_HRFIM, ":", "", 1 )) .And. !Empty(M->TTL_DTFIM)
		If !NGVALHRCALE(cCALE,M->TTL_DTFIM,M->TTL_HRFIM,"F")
			Return .F.
		EndIf
	ElseIf cREADVAR == "M->TTL_HRFIM" .And. cUsaCale == "S" .And. !Empty(M->TTL_DTFIM) .And. !Empty(StrTran(M->TTL_HRFIM, ":", "", 1 ))
		If !NGVALHRCALE(cCALE,M->TTL_DTFIM,M->TTL_HRFIM,"F")
			Return .F.
		EndIf
	EndIf

	If (M->TTL_DTINI <> STOD("")) .And. (M->TTL_DTFIM <> STOD("")) .And.;
		(Empty(M->TTL_HRINI) .Or. !Empty(StrTran(M->TTL_HRINI, ":", "", 1))) .And.;
		(Empty(M->TTL_HRFIM) .Or. !Empty(StrTran(M->TTL_HRFIM, ":", "", 1))) .And.;
		(M->TTL_DTINI == M->TTL_DTFIM) .And. (M->TTL_HRINI == M->TTL_HRFIM)
		MsgInfo(STR0022,STR0012) //"A diferença entre a Data/Hora inicio e Data/Hora fim deverá ser maior que 0"###"NAO CONFORMIDADE"
		Return .F.
	EndIf

	lGETACH  := .T.

	dDTI  := M->TTL_DTINI
	hHI   := M->TTL_HRINI
	dDTF  := M->TTL_DTFIM
	hHF   := M->TTL_HRFIM
	nQTD  := M->TTL_QUANTI
	cCODF := M->TTL_CODFUN
	cTIPR := 'M'

	If cREADVAR == "M->TTL_HRINI" .And. cTIPR <> "P" .And. !Empty(dDTI) .And. !Empty(dDTF) .And. !Empty(hHF)
		If dDTI = dDTF .And. M->TTL_HRINI > hHF
			Help(" ",1,"HORAINVALI",,STR0018,3,1) //"Hora inicio maior do que hora fim"
			Return .F.
		EndIf
	ElseIf cREADVAR == "M->TTL_HRFIM" .And. cTIPR <> "P" .And. !Empty(dDTI) .And. !Empty(dDTF) .And. !Empty(hHI)
		If dDTI = dDTF .And. M->TTL_HRFIM < hHI
			Help(" ",1,"HORAINVALI",,STR0019,3,1) //"Hora fim menor do que hora inicio"
			Return .F.
		EndIf
	ElseIf cREADVAR == "M->TTL_DTINI" .And. cTIPR <> "P" .And. !Empty(dDTF)
		If M->TTL_DTINI > dDTF
			MsgInfo(STR0020,STR0012) //"Data inicio maior do que data fim"###"NAO CONFORMIDADE"
			Return .F.
		EndIf
	ElseIf cREADVAR == "M->TTL_DTFIM" .And. cTIPR <> "P" .And. !Empty(dDTI)
		If M->TTL_DTFIM < dDTI
			MsgInfo(STR0021,STR0012) //"Data fim menor do que data inicio"###"NAO CONFORMIDADE"
			Return .F.
		ElseIf !Empty(dDTF) .And. !Empty(hHI) .And. !Empty(StrTran(hHF, ":", "", 1))
			If (dDTI == dDTF .And. hHI > hHF)
				Help(" ",1,"HORAINVALI",,STR0018,3,1) //"Hora inicio maior do que hora fim"
				Return .F.
			EndIf
		EndIf
	EndIf

	hHIV  := If(Empty(StrTran(hHI, ":", "", 1)),Space(5),hHI)
	hHFV  := If(Empty(StrTran(hHF, ":", "", 1)),Space(5),hHF)
	nQTDF := 0.00
	lCALE := .F.

	If cUsaCale == "S"
		aMATCA := NGCALENDAH(cCALE)
		lCALE  := .T.
	EndIf

	// TROCOU O TIPO
	If cREADVAR == "M->TTL_TPHORA" //"M->TL_USACALE"
		If !Empty(dDTI) .And. !Empty(hHIV) .And. (Empty(dDTF) .Or. Empty(hHFV)) .And. !Empty(nQTD)
			NGCALEDTFIM(dDTI,hHIV,nQTD,cCALE)
		ElseIf !Empty(dDTI) .And. !Empty(hHIV) .And. !Empty(dDTF) .And. !Empty(hHFV)
			NGCALEINTD(dDTI,hHIV,dDTF,hHFV,cCALE)
		ElseIf (!Empty(dDTI) .Or. !Empty(hHIV)) .And. !Empty(dDTF) .And. !Empty(hHFV) .And. !Empty(nQTD)
			NGCALEDTINI(dDTF,hHFV,nQTD,cCALE)
		Endif
	// DATA E HORA INICIO
	ElseIf (cREADVAR == "M->TTL_DTINI" .Or. cREADVAR == "M->TTL_HRINI")
		If cREADVAR == "M->TTL_DTINI"
		// LENDO A DATA INICIO
			If !Empty(dDTI)
				If !Empty(hHIV)
					If !Empty(dDTF) .And. !Empty(hHFV)
						NGCALEINTD(dDTI,hHIV,dDTF,hHFV,cCALE)
					ElseIf !Empty(nQTD)
						NGCALEDTFIM(dDTI,hHIV,nQTD,cCALE)
					EndIf
				Else
					If !Empty(dDTF) .And. !Empty(hHFV) .And. !Empty(nQTD)
						NGCALEDTINI(dDTF,hHFV,nQTD,cCALE)
					EndIf
				EndIf
			Else
				If !Empty(dDTF) .And. !Empty(hHFV) .And. !Empty(nQTD)
					NGCALEDTINI(dDTF,hHFV,nQTD,cCALE)
				EndIf
			EndIf
		Else
			// LENDO A HORA INICIO
			If !Empty(hHIV)
				If !Empty(dDTI)
					If !Empty(dDTF) .And. !Empty(hHFV)
						NGCALEINTD(dDTI,hHIV,dDTF,hHFV,cCALE)
					ElseIf !Empty(nQTD)
						NGCALEDTFIM(dDTI,hHIV,nQTD,cCALE)
					EndIf
				ElseIf !Empty(dDTF) .And. !Empty(hHFV) .And. !Empty(nQTD)
					NGCALEDTINI(dDTF,hHFV,nQTD,cCALE)
				EndIf
			Else
				If !Empty(dDTF) .And. !Empty(hHFV) .And. !Empty(nQTD)
					NGCALEDTINI(dDTF,hHFV,nQTD,cCALE)
				EndIf
			EndIf
		EndIf
	// DATA E HORA FIM
	ElseIf cREADVAR == "M->TTL_DTFIM" .Or. cREADVAR == "M->TTL_HRFIM"
		// LENDO A DATA FIM
		If cREADVAR == "M->TTL_HRFIM"
			If !Empty(dDTF)
				If !Empty(hHFV)
					If !Empty(dDTI) .And. !Empty(hHIV)
						NGCALEINTD(dDTI,hHIV,dDTF,hHFV,cCALE)
					ElseIf !Empty(nQTD)
						NGCALEDTINI(dDTF,hHFV,nQTD,cCALE)
					EndIf
				Else
					If !Empty(dDTI) .And. !Empty(hHIV) .And. !Empty(nQTD)
						NGCALEDTFIM(dDTI,hHIV,nQTD,cCALE)
					EndIf
				EndIf
			Else
				If !Empty(dDTI) .And. !Empty(hHIV) .And. !Empty(nQTD)
					NGCALEDTFIM(dDTI,hHIV,nQTD,cCALE)
				EndIf
			EndIf
		Else
			// LENDO A HORA FIM
			If !Empty(hHFV)
				If !Empty(dDTF)
					If !Empty(dDTI) .And. !Empty(hHIV)
						NGCALEINTD(dDTI,hHIV,dDTF,hHFV,cCALE)
					ElseIf !Empty(nQTD)
						NGCALEDTINI(dDTF,hHFV,nQTD,cCALE)
					EndIf
				ElseIf !Empty(dDTI) .And. !Empty(hHIV) .And. !Empty(nQTD)
					NGCALEDTINI(dDTI,hHFV,nQTD,cCALE)
				EndIf
			Else
				If !Empty(dDTI) .And. !Empty(hHIV) .And. !Empty(nQTD)
					NGCALEDTFIM(dDTI,hHIV,nQTD,cCALE)
				EndIf
			EndIf
		EndIf
	ElseIf cREADVAR == "M->TTL_QUANTI"
		// OK
		If !Empty(nQTD)
			If !Empty(dDTI) .And. !Empty(hHIV)
				NGCALEDTFIM(dDTI,hHIV,nQTD,cCALE)
			Else
				If (Empty(dDTI) .Or. Empty(hHIV)) .And. (!Empty(dDTF) .And. !Empty(hHFV))
					NGCALEDTINI(dDTF,hHFV,nQTD,cCALE)
				EndIf
			EndIf
		Else
			If !Empty(dDTI) .And. !Empty(hHIV) .And. !Empty(dDTF) .And. !Empty(hHFV)
				NGCALEINTD(dDTI,hHIV,dDTF,hHFV,cCALE)
			EndIf
		EndIf
	EndIf

Return .T.