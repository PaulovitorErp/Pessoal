#INCLUDE "PROTHEUS.CH"
#INCLUDE "FWMVCDEF.CH"
#INCLUDE "AP5MAIL.CH"
#INCLUDE "NGINTSFC.CH"

Function NGINTSFCF9()
	NGVersao("NGINTSFC")
Return

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³ NGINTSFC ³ Autor ³ Hugo Rizzo Pereira     ³ Data ³ 17/02/12 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Verifica se ha integracao com Chao de Fabrica (SIGASFC).    ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ Generico                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function NGINTSFC(lRetLgc, lVrfUpd)

	Local lIntSFC := .F.
	Local cIntSFC := ""

	Default lRetLgc := .T.
	Default lVrfUpd := .T.

	// Caso haja integracao entre os modulos PCP e SFC
	If GetNewPar( "MV_INTSFC", 0 )  == 1 .And. ( !lVrfUpd .Or. ( SuperGetMv( "MV_NGSEGPL", .F., 0 ) <> 0 ) )

		cIntSFC := cValToChar( GetNewPar( "MV_NGMNSFC", 1 ) ) // Verifica integracao entre MNT e SFC
		If !( lIntSFC := cIntSFC $ "2/3" )
			cIntSFC := ""
		Endif

	Endif

// Realiza retorno conforme parametro
Return If( lRetLgc, lIntSFC, cIntSFC )

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³ NGVRFMAQ ³ Autor ³ Hugo Rizzo Pereira     ³ Data ³ 28/11/11 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Verifica se o Bem é uma Máquina, no Chao Fabrica.           ³±±
±±³          ³ Integracao com Chao de Fabrica. (SIGASFC)                   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ cCodigo - Codigo do Bem/Máquina a ser verificado.           ³±±
±±³          ³ nTipo   - Define de onde partirá a verificação.             ³±±
±±³          ³           Opcoes : 1 - A partir do Codigo do Bem.           ³±±
±±³          ³                    2 - A partir do Codigo da Máquina.       ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ Generico                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function NGVRFMAQ(cCodPesq, nTipo)

	Local aAreaST9 := ST9->(GetArea())
	Local aArea  := GetArea()

	Local cCodigoAux, cChave, nOrdem

	Store "" To cCodigoAux, cChave

	Default cCodPesq := ""
	Default nTipo    := 1

	If Empty(cCodPesq)
		Return ""
	Endif

	// Define a Ordem e a chave a ser utilizada, conforme o tipo de verificação
	nOrdem := If(nTipo == 2, NGRETORDEM("ST9","T9_FILIAL+T9_FERRAME+T9_RECFERR"), 1)
	cChave := If(nTipo == 2, "R" + cCodPesq, cCodPesq)

	// Caso o bem estiver relacionado a algum recurso e estiver presente na CYB (Maquinas - SIGASFC)
	If (NGIFDBSEEK("ST9", cChave, nOrdem) .And. ST9->T9_FERRAME == "R" .And. ;
		!Empty(ST9->T9_RECFERR)) .And. NGIFDBSEEK("CYB", ST9->T9_RECFERR, 1)

		dbSelectArea("ST9")
		cCodigoAux := If( nTipo == 2, ST9->T9_CODBEM, ST9->T9_RECFERR )
	Endif

	RestArea(aAreaST9)
	RestArea(aArea)

Return cCodigoAux

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³ NGSFCVPRD ³ Autor ³ Hugo Rizzo Pereira     ³ Data ³ 28/11/11 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Verifica se a Parada Programada esta pendente,              ³±±
±±³          ³ possibilitando assim, uma possivel alteracao.               ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ cNumOrd - Numero da Ordem de Serviço. (SIGAMNT)             ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ Generico                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function NGSFCVPRD(cNumOrd)

	Local aArea    := GetArea()
	Local aAreaCZ2 := CZ2->(GetArea())

	Local lRet     := .T.

	dbSelectArea("CZ2")
	CZ2->(dbSetOrder(4))
	lRet := Empty(cNumOrd) .Or. !CZ2->( dbSeek(xFilial("CZ2")+cNumOrd) )

	If !lRet
		lRet := !NGIFDBSEEK("CYX", CZ2->CZ2_CDMQ+CZ2->CZ2_NRSQSP, 5)
	Endif

	RestArea(aAreaCZ2)
	RestArea(aArea)

Return lRet

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³NGSFCRESP ³ Autor ³ Hugo Rizzo Pereira     ³ Data ³ 15/02/12 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Realiza validacoes gerais da integracao MNT x SFC.          ³±±
±±³          ³ Consistencias necessarias para processo da integracao.      ³±±
±±³          ³ Verifica existencia de responsável na filial corrente.      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ Generico                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function NGSFCRESP(lShowHelp, lRetLgc)

	Local aArea    := GetArea()
	Local aAreaSTK := TSK->(GetArea())
	Local cErroRes := ""
	Local lRet     := .F.

	Default lShowHelp := .T.
	Default lRetLgc   := .T.

	NGIFDBSEEK("TSK", cFilAnt + "6", 2)
	While !Eof() .And. TSK->TSK_FILIAL == xFilial("TSK") .And. TSK->TSK_FILMS == cFilAnt .And. TSK->TSK_PROCES == "6"
		If !Empty(NGSEEK("SRA",TSK->TSK_CODFUN,1,"RA_EMAIL"))
			lRet := .T.
			Exit
		Endif
		TSK->(dbSkip())
	End

	If !lRet
		If lShowHelp
			ShowHelpDlg(STR0001,	{ STR0002 }, 1, ; // "Atenção" ## "A integração entre os módulos SIGAMNT e SIGASFC, exige a existência de um responsável, com e-mail cadastrado, para a filial em questão."
									{ STR0003 }, 1)   // "Informe um responsável para o processo 'Todos', através da rotina de Filiais (MNTA855)."
		Endif

		If !lRetLgc
			cErroRes := STR0004 // "Não existe responsável, com e-mail cadastrado, para a filial em questão."
		Endif
	Endif

	RestArea(aAreaSTK)
	RestArea(aArea)

Return If(lRetLgc, lRet, cErroRes)

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³NGSFCPARAM³ Autor ³ Hugo Rizzo Pereira     ³ Data ³ 28/11/11 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Valida parametro de Motivo de Parada. (MV_SFCMTSP)          ³±±
±±³          ³ Integracao com Chao de Fabrica. (SIGASFC)                   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ lShowHelp - Apresenta, ou não, a mensagem de erro.          ³±±
±±³          ³             Opcoes : .T. - Apresenta;                       ³±±
±±³          ³                      .F. - Não Apresenta;                   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ Generico                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function NGSFCPARAM(lShowHelp, lRetLgc)

	Local cMtvPrd := Padr( AllTrim(SuperGetMv("MV_SFCMTSP",.F.,"")), TAMSX3("CYN_CDSP")[1] )
	Local cCalSFC := Padr( AllTrim(SuperGetMv("MV_SFCCDCL",.F.,"")), TamSx3("CYG_CDCL")[1] )
	Local cTrnSFC := Padr( AllTrim(SuperGetMv("MV_SFCCDTN",.F.,"")), TamSx3("CYM_CDTN")[1] )

	Local aArea := GetArea()

	Local cHlpMtv := STR0085 + ":" + CRLF // "Parâmetro(s) inválido(s)"
	Local lRet    := .T.

	Default lShowHelp := .T.
	Default lRetLgc   := .T.

	cHlpMtv += If(lShowHelp, CRLF, "")

	If Empty(cMtvPrd) .Or. !NGIFDBSEEK("CYN", cMtvPrd, 1)
		cHlpMtv += "MV_SFCMTSP" + Space(1) + "(" + STR0005 + ")" // "Motivo de Parada"
		lRet    := .F.
	Endif

	If Empty(cCalSFC) .Or. !NGIFDBSEEK("CYG", cCalSFC, 1)
		cHlpMtv += If(!lRet,CRLF,"") + "MV_SFCCDCL" + Space(1) + "(" + STR0006 + ")" // "Calendário"
		lRet    := .F.
	Endif

	If Empty(cTrnSFC) .Or. !NGIFDBSEEK("CYM", cTrnSFC, 1)
		cHlpMtv += If(!lRet,CRLF,"") + "MV_SFCCDTN" + Space(1) + "(" + STR0087 + ")" // "Turno"
		lRet    := .F.
	Endif

	// Caso algum erro seja encontrado, e o parametro para apresentar o mesmo, esteja habilitado
	If !lRet .And. lShowHelp
		ShowHelpDlg(STR0086,	{cHlpMtv},1, ; // "Integração SIGAMNT x SIGASFC"
								{STR0007}, 1)  // "Preencha corretamento o parâmetros."
	Endif

	RestArea(aArea)

	If lRet
		cHlpMtv := ""
	Endif

Return If(lRetLgc, lRet, cHlpMtv)

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³NGSFCTRNCL³ Autor ³ Hugo Rizzo Pereira     ³ Data ³ 28/11/11 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Gera Parada Programada. (CZ2)                               ³±±
±±³          ³ Integracao com Chao de Fabrica. (SIGASFC)                   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ cRecSFC - Maquina a efetuar Parada. (Recurso PCP/MNT)       ³±±
±±³          ³ dDtIni   - Data Inicial da Parada.                          ³±±
±±³          ³ cHrIni   - Hora Inicial da Parada.                          ³±±
±±³          ³ dDtFim   - Data Final da Parada.                            ³±±
±±³          ³ cHrFim   - Hora Final da Parada.                            ³±±
±±³          ³ cOrdem   - Ordem de Serviço aberta para o Bem (Maquina SFC).³±±
±±³          ³ cTipInt  - Tipo de Integração entre SIGAMNT e SIGASFC.      ³±±
±±³          ³            Opcoes : 1 - Não Integra;						   ³±±
±±³          ³                     2 - Integra On-Line; 				   ³±±
±±³          ³                     3 - Integra Com Confirmação;            ³±±
±±³          ³ lCommit  - Define se as alterações serão aplicadas.         ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ Generico                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function NGSFCTRNCL( cCalen, lTipRet )

	Local lRet
	Local aArea := GetArea()

	Default lTipRet := .T.

	dbSelectArea("CYF")
	dbSetOrder(1)
	lRet := dbSeek(xFilial("CYF") + cCalen)

	RestArea(aArea)

Return If(lTipRet,lRet,CYF->CYF_NRTN)

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³NGSFCSTPP ³ Autor ³ Hugo Rizzo Pereira     ³ Data ³ 28/11/11 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Gera Parada Programada. (CZ2)                               ³±±
±±³          ³ Integracao com Chao de Fabrica. (SIGASFC)                   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ cRecSFC - Maquina a efetuar Parada. (Recurso PCP/MNT)       ³±±
±±³          ³ dDtIni   - Data Inicial da Parada.                          ³±±
±±³          ³ cHrIni   - Hora Inicial da Parada.                          ³±±
±±³          ³ dDtFim   - Data Final da Parada.                            ³±±
±±³          ³ cHrFim   - Hora Final da Parada.                            ³±±
±±³          ³ cOrdem   - Ordem de Serviço aberta para o Bem (Maquina SFC).³±±
±±³          ³ cTipInt  - Tipo de Integração entre SIGAMNT e SIGASFC.      ³±±
±±³          ³            Opcoes : 1 - Não Integra;						   ³±±
±±³          ³                     2 - Integra On-Line; 				   ³±±
±±³          ³                     3 - Integra Com Confirmação;            ³±±
±±³          ³ lCommit  - Define se as alterações serão aplicadas.         ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ Generico                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function NGSFCSTPP(cIntSFC)
Return If(cIntSFC == "3", "1", "2") // Status da Parada	: 1 - Pendente; 2 - Aprovada; 3 - Rejeitada

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³NGSFCINCPP³ Autor ³ Hugo Rizzo Pereira     ³ Data ³ 28/11/11 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Gera Parada Programada. (CZ2)                               ³±±
±±³          ³ Integracao com Chao de Fabrica. (SIGASFC)                   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ cRecSFC - Maquina a efetuar Parada. (Recurso PCP/MNT)       ³±±
±±³          ³ dDtIni   - Data Inicial da Parada.                          ³±±
±±³          ³ cHrIni   - Hora Inicial da Parada.                          ³±±
±±³          ³ dDtFim   - Data Final da Parada.                            ³±±
±±³          ³ cHrFim   - Hora Final da Parada.                            ³±±
±±³          ³ cOrdem   - Ordem de Serviço aberta para o Bem (Maquina SFC).³±±
±±³          ³ cTipInt  - Tipo de Integração entre SIGAMNT e SIGASFC.      ³±±
±±³          ³            Opcoes : 1 - Não Integra;						   ³±±
±±³          ³                     2 - Integra On-Line; 				   ³±±
±±³          ³                     3 - Integra Com Confirmação;            ³±±
±±³          ³ lCommit  - Define se as alterações serão aplicadas.         ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ Generico                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function NGSFCINCPP(cRecSFC ,dDtIni, cHrIni, dDtFim, cHrFim, cOrdem, cTipInt, cTurno, lShowMsg, lCommit, lRetLgc)

	Local oModelCZ2, cStatus
	Local cMtvPrd  := SuperGetMv("MV_SFCMTSP",.F.,"")
	Local lCreated := .F.
	Local cErroSFC := ""

	Default dDtIni   := CTOD("") , dDtFim  := CTOD("")
	Default cHrIni   := "  :  "  , cHrFim  := "  :  "
	Default cRecSFC := ""       , cOrdem  := ""
	Default cTurno   := ""
	Default cTipInt  := "2"
	Default lShowMsg := .T.
	Default lCommit  := .T.
	Default lRetLgc  := .T.

	cHrIni := SubStr(cHrIni,1,5)
	cHrFim := SubStr(cHrFim,1,5)

	cStatus  := NGSFCSTPP(cTipInt)
	cHrIni   := Padr(Trim(Transform(cHrIni,"99:99:99")),8,"0")	// Ajusta Hora Inicial conforme picture apresentada no modulo de Chao de Fabrica
	cHrFim   := Padr(Trim(Transform(cHrFim,"99:99:99")),8,"0")	// Ajusta Hora Final conforme picture apresentada no modulo de Chao de Fabrica
	cNrTurno := NGSFCTRNCL(cTurno, .F.)

	dbSelectArea('CZ2')
	CZ2->(dbSetOrder(4))
	If CZ2->(!dbSeek(xFilial('CZ2') + cOrdem))

		oModelCZ2 := FWLoadModel( 'SFCA102' )          // Instancia o modelo
		oModelCZ2:SetOperation(MODEL_OPERATION_INSERT) // Define operação como Inclusão
		oModelCZ2:Activate()                           // Inicia o processo de preenchimento/insercao dos dados no formulário

		// Define valores para os componentes do modelo resgatado
		oModelCZ2:LoadValue( 'CZ2MASTER' , 'CZ2_CDMQ'   , cRecSFC ) // Codigo da Maquina
		oModelCZ2:LoadValue( 'CZ2MASTER' , 'CZ2_CDSP'   , cMtvPrd  ) // Codigo da Parada
		oModelCZ2:LoadValue( 'CZ2MASTER' , 'CZ2_DTBGPL' , dDtIni   ) // Data Inicio
		oModelCZ2:LoadValue( 'CZ2MASTER' , 'CZ2_HRBGPL' , cHrIni   ) // Hora Inicio
		oModelCZ2:LoadValue( 'CZ2MASTER' , 'CZ2_DTEDPL' , dDtFim   ) // Data Fim
		oModelCZ2:LoadValue( 'CZ2MASTER' , 'CZ2_HREDPL' , cHrFim   ) // Hora Fim
		oModelCZ2:LoadValue( 'CZ2MASTER' , 'CZ2_NRORMN' , cOrdem   ) // Ordem Manutenção
		oModelCZ2:LoadValue( 'CZ2MASTER' , 'CZ2_TPSTSP' , cStatus  ) // Tipo Estado Parada (1-Pendente, 2-Aprovada, 3-Rejeitada)
		oModelCZ2:LoadValue( 'CZ2MASTER' , 'CZ2_CDTN'   , cTurno   ) // Codigo do Turno
		oModelCZ2:LoadValue( 'CZ2MASTER' , 'CZ2_NRTN'   , cNrTurno ) // Numero do Turno

		If (lCreated := oModelCZ2:VldData() .And. Eval(oModelCZ2:bPost)) // Valida modelo atual
			If lCommit
				oModelCZ2:CommitData() // Persiste dados informados
			Endif
		Else
			If lShowMsg
				cErroSFC := oModelCZ2:GetErrorMessage()[6]
				ShowHelpDlg(STR0001  + Space(1) +  STR0008 + Space(1) + AllTrim(cOrdem), ; // "Atenção" ## "O.S."
							{STR0009 + CRLF + CRLF + cErroSFC},1, ; // "Não foi possível criar a parada programada."
							{STR0010},1) // "Entre em contato com o Administrador do sistema."
			Endif
		EndIf

		oModelCZ2:DeActivate() // Desativa processo de inserção de dados

	Endif

Return If(lRetLgc, lCreated, cErroSFC)

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³NGSFCATPRD³ Autor ³ Hugo Rizzo Pereira     ³ Data ³ 28/11/11 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Atualiza Parada Programada. (CZ2)                           ³±±
±±³          ³ Integracao com Chao de Fabrica. (SIGASFC)                   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ cNumOrd - Numero da Ordem de Serviço. (SIGAMNT)             ³±±
±±³          ³ 			 Parada Programada relacionada à Manutencao.       ³±±
±±³          ³ aValues - Valores da Parada Programada, a serem alterados.  ³±±
±±³          ³           Estrutura : [1] - Nome do Campo;				   ³±±
±±³          ³                       [2] - Novo conteudo;  				   ³±±
±±³          ³ lCommit - Define se as alterações serão aplicadas.          ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ Generico                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function NGSFCATPRD(cNumOrd, aValues, lShowMsg, lCommit)

	// Variaveis do modelo de dados
	Local oModelCZ2, aFieldsCZ2

	// Armazenamento de areas atuais
	Local aAreaCZ2 := CZ2->(GetArea())
	Local aArea  := GetArea()

	// Variveis de controle
	Local lUpdated := .T.
	Local nField   := 0

	Default cNumOrd  := Replicate("0",TAMSX3("TJ_ORDEM")[1])
	Default aValues  := {}
	Default lShowMsg := .T.
	Default lCommit  := .T.

	// Verifica existencia de parada programada conforme Ordem de Serviço
	dbSelectArea('CZ2')
	CZ2->(dbSetOrder(4))
	If Len(aValues) > 0 .And. CZ2->(dbSeek(xFilial('CZ2')+cNumOrd))

		// Instancia o modelo
		oModelCZ2 := FWLoadModel( 'SFCA102' )
		oModelCZ2:SetOperation(MODEL_OPERATION_UPDATE) // Define operação como Alteração
		oModelCZ2:Activate()                           // Inicia o processo de preenchimento/insercao dos dados no formulário

		// Armazena campos presentes no modelo atual
		aFieldsCZ2 := oModelCZ2:GetModel( 'CZ2MASTER' ):GetStruct():GetFields()

		// Define valores para os componentes do modelo resgatado
		For nField := 1 to Len(aValues)
			If aScan(aFieldsCZ2,{|x| AllTrim( Upper(x[3]) ) == AllTrim( Upper(aValues[nField][1]) ) }) > 0
				oModelCZ2:LoadValue( 'CZ2MASTER' , aValues[nField][1] , aValues[nField][2]  )
			Endif
		Next nField

		If (lUpdated := oModelCZ2:VldData() .And. Eval(oModelCZ2:bPost)) // Valida modelo atual
			If lCommit
				oModelCZ2:CommitData() // Persiste dados informados
			Endif
		Else
			If lShowMsg
				ShowHelpDlg( STR0001  + oModelCZ2:GetErrorMessage()[4], ; // "Atenção"
							 {STR0011 + CRLF + CRLF + oModelCZ2:GetErrorMessage()[6]},1, ; // "Não foi possível alterar a parada programada."
							 {STR0010}, 1) // "Entre em contato com o Administrador do sistema."
			Endif
		EndIf

		oModelCZ2:DeActivate() // Desativa processo de inserção de dados

	Endif

	RestArea(aAreaCZ2)
	RestArea(aArea)

Return lUpdated

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³NGSFCDELPP³ Autor ³ Hugo Rizzo Pereira     ³ Data ³ 28/11/11 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Exclui Parada Programada. (CZ2)                             ³±±
±±³          ³ Integracao com Chao de Fabrica. (SIGASFC)                   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ cOrdemMan - Numero da Ordem de Serviço. (SIGAMNT)           ³±±
±±³          ³ 			 Parada Programada relacionada à Manutencao.       ³±±
±±³          ³ lShowMsg  - Define se apresenta mensagem de erro.           ³±±
±±³          ³ lCommit   - Define se as alterações serão aplicadas.        ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ Generico                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function NGSFCDELPP(cOrdemMan, lShowMsg, lCommit)

	// Variavel do modelo de dados
	Local oModelCZ2

	// Armazenamento de areas atuais
	Local aAreaCZ2 := CZ2->(GetArea())
	Local aArea  := GetArea()

	// Variavel de controle
	Local lDeleted := .T.

	Default cOrdemMan := Replicate("0",TAMSX3("TJ_ORDEM")[1])
	Default lShowMsg  := .T.
	Default lCommit   := .T.

	// Verifica existencia de parada programada conforme Ordem de Serviço
	dbSelectArea('CZ2')
	CZ2->(dbSetOrder(4))
	If CZ2->(dbSeek(xFilial('CZ2') + cOrdemMan))

		// Instancia o modelo
		oModelCZ2 := FWLoadModel( 'SFCA102' )
		oModelCZ2:SetOperation(5) // Define operação como Alteração
		oModelCZ2:Activate()      // Inicia o processo de preenchimento/insercao dos dados no formulário

		If (lDeleted := oModelCZ2:VldData() .And. Eval(oModelCZ2:bPost)) // Valida modelo atual
			If lCommit
				oModelCZ2:CommitData() // Persiste dados informados
			Endif
		Else
			If lShowMsg
				ShowHelpDlg( STR0001 + oModelCZ2:GetErrorMessage()[4], ; // "Atenção"
							 {STR0012 + CRLF + CRLF + oModelCZ2:GetErrorMessage()[6]},1, ; // "Não foi possível excluir a parada programada."
							 {STR0010}, 1) // "Entre em contato com o Administrador do sistema."
			Endif
		EndIf

		oModelCZ2:DeActivate() // Desativa processo de inserção de dados

	Endif

	RestArea(aAreaCZ2)
	RestArea(aArea)

Return lDeleted

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³NGSFCSNDML³ Autor ³ Hugo Rizzo Pereira     ³ Data ³ 28/11/11  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Envia e-mail para o responsável no SFC.                      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ aMailInfo - Informacoes da operacao.                         ³±±
±±³          ³             [1] - Codigo Operacao.                           ³±±
±±³          ³             [2] - Info O.S./Bens.                            ³±±
±±³          ³                   [1] - Codigo da O.S. (Alteracao e Exclusao)³±±
±±³          ³                   [2] - Codigo do Bem/Maquina.               ³±±
±±³          ³                   [3] - Data Inicial Prevista.               ³±±
±±³          ³                   [4] - Hora Inicial Prevista.               ³±±
±±³          ³                   [5] - Data Final Prevista.                 ³±±
±±³          ³                   [6] - Hora Final Prevista.                 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ Generico                                                     ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function NGSFCSNDML(nOper, aMailInfo, lPerg)

	Local oDlgMail, oMemo

	Local aRetMail  := {.F., STR0013} // "Cancelado pelo usuário!"
	Local aMailCnt  := {}
	Local lCanSend  := .F.

	Local cAssunto  := ""
	Local cMensagem := ""
	Local nOpcao    := 0

	Default lPerg := .T.

	If lPerg .And. !MsgYesNo( STR0014 + CRLF + ; // "Não é possível prosseguir com a operação para esta ordem de serviço."
							  STR0015 + CRLF + CRLF + ; // "Existe uma parada programada vinculada à mesma, impossibilitando o processo."
							  STR0016) // "Deseja enviar um e-mail a respeito, ao Chão de Fábrica?"
		Return .F.
	Endif

	If Len(aMailInfo) > 0
		aMailCnt  := NGMAILCNT(nOper, aMailInfo)
		cAssunto  := aMailCnt[1]
		cMensagem := aMailCnt[2]
	Endif

	PTSETACENT(.T.) // Habilita a acentuação do conteudo dos campos em tela

	Define MsDialog oDlgMail Title OemToAnsi(STR0017 + "  |  SIGASFC") From 00,00 TO 385,417 Pixel // "E-mail"

		oDlgMail:lEscClose := .F.

		@ 05,10 Say STR0018 Of oDlgMail Pixel // "Assunto:"
		@ 15,10 MsGet cAssunto Size 190,10 Of oDlgMail Pixel

		@ 33,10 Say STR0019 Of oDlgMail Pixel // "Mensagem:"
		@ 43,10 Get oMemo Var cMensagem MEMO Size 190,120 Of oDlgMail Pixel
		oMemo:SetFocus()

		@ 172,10  Button STR0020 Of oDlgMail Size 45,12 Pixel ; // "Enviar"
			Action (nOpcao := 1, If( NGMAILOK(cAssunto,cMensagem), oDlgMail:End(), nOpcao := 0) )

		@ 172,60  Button STR0021 Of oDlgMail Size 45,12 Pixel Action (nOpcao := 0, oDlgMail:End()) // "Cancelar"

	Activate MsDialog oDlgMail Centered

	PTSETACENT(.F.) // Desabilita a acentuação do conteudo dos campos em tela

	If nOpcao == 1 .And. FindFunction("SFCNGMAIL")
		aRetMail := SFCNGMAIL("", AllTrim(cAssunto), cMensagem)
		If !aRetMail[1]
			ShowHelpDlg(STR0001, {aRetMail[2]},1, ; // "Atenção"
					{STR0022,;   // "Verifique as configurações do servidor de e-mail."
					 STR0010},2) // "Entre em contato com o administrador do sistema."
		Endif
	Endif

Return aRetMail[1]

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³ NGMAILCNT ³ Autor ³ Hugo Rizzo Pereira     ³ Data ³ 28/11/11 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Define conteudo do corpo do e-mail conforme operacao.        ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ aMailInfo - Informacoes da operacao.                         ³±±
±±³          ³             [1] - Codigo Operacao.                           ³±±
±±³          ³             [2] - Info O.S./Bens.                            ³±±
±±³          ³                   [1] - Codigo da O.S. (Alteracao e Exclusao)³±±
±±³          ³                   [2] - Codigo do Bem/Maquina.               ³±±
±±³          ³                   [3] - Data Inicial Prevista.               ³±±
±±³          ³                   [4] - Hora Inicial Prevista.               ³±±
±±³          ³                   [5] - Data Final Prevista.                 ³±±
±±³          ³                   [6] - Hora Final Prevista.                 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ NGINTSFC                                                     ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Static Function NGMAILCNT(nOper, aMailInfo)

	Local cStrOpr  := If(nOper == 1,STR0023, If(nOper == 2, STR0024, STR0025)) // "Geração" ## "Alteração" ## "Exclusão"
	Local cAssunto := PADR("SIGAMNT  |  " + cStrOpr + Space(1) + STR0026, 120) // "de Parada Programada"
	Local cMailMsg := ""
	Local nInd

	cStrOpr := If(nOper == 1, STR0027, If(nOper == 2, STR0028, If(nOper == 3, STR0029, STR0030))) // "gerar" ## "alterar" ## "excluir" ## "finalizar"

	cMailMsg := STR0031 + Space(1) + cStrOpr + Space(1) + STR0032 // "Não foi possível" ## "a(s) parada(s) programada(s) através da(s) Ordem(ns) de Serviço(s)."
	cMailMsg += CRLF + STR0033 + Space(1) + CRLF // "Requer avaliação do Chão de Fábrica. Dados da operação realizada:"

	If Len(aMailInfo) > 0
		For nInd := 1 To Len(aMailInfo)

			cOrdServ := aMailInfo[nInd][1]
			cMailMsg += CRLF + Replicate("-", 50) + CRLF

			If ValType(cOrdServ) <> "C" .Or. !Empty(cOrdServ)

				cCodBem  := NGSEEK("STJ",cOrdServ,1,"TJ_CODBEM")

				cMailMsg += CRLF + STR0034 + Space(1) + cOrdServ // "Ordem de Serviço:"
				cMailMsg += CRLF + STR0035 + Space(1) + NGSEEK("ST9", cCodBem, 1, "T9_RECFERR") // "Máquina:"

				cMailMsg += CRLF + STR0036 + Space(1) + ; // "Data Inicial da Parada:"
					DTOC(If(Len(aMailInfo[nInd]) >= 3 .And. ValType(aMailInfo[nInd][3]) == "D",;
					aMailInfo[nInd][3], NGSEEK("STJ", cOrdServ, 1, "TJ_DTPPINI")))

				cMailMsg += CRLF + STR0037 + Space(1) + ; // "Hora Inicial da Parada:"
					If(Len(aMailInfo[nInd])      >= 4 .And. ValType(aMailInfo[nInd][4]) == "C",;
					aMailInfo[nInd][4], NGSEEK("STJ", cOrdServ, 1, "TJ_HOPPINI"))

				cMailMsg += CRLF + STR0038 + Space(1) + ; // "Data Final da Parada:"
					DTOC(If(Len(aMailInfo[nInd]) >= 5 .And. ValType(aMailInfo[nInd][5]) == "D",;
					aMailInfo[nInd][5], NGSEEK("STJ", cOrdServ, 1, "TJ_DTPPFIM")))

				cMailMsg += CRLF + STR0039 + Space(1) + ; // "Hora Final da Parada:"
					If(Len(aMailInfo[nInd])      >= 6 .And. ValType(aMailInfo[nInd][6]) == "C",;
					aMailInfo[nInd][6], NGSEEK("STJ", cOrdServ, 1, "TJ_HOPPFIM")) + CRLF
			Else

				cMailMsg += CRLF + STR0035 + Space(1) + NGSEEK("ST9", aMailInfo[nInd][2], 1, "T9_RECFERR") // "Data Inicial da Parada:"
				cMailMsg += CRLF + STR0036 + Space(1) + DTOC(aMailInfo[nInd][3])	// "Data Inicial da Parada:"
				cMailMsg += CRLF + STR0037 + Space(1) + aMailInfo[nInd][4] 		// "Hora Inicial da Parada:"
				cMailMsg += CRLF + STR0038 + Space(1) + DTOC(aMailInfo[nInd][5]) 	// "Data Final da Parada:"
				cMailMsg += CRLF + STR0039 + Space(1) + aMailInfo[nInd][6] + CRLF	// "Hora Final da Parada:"

			Endif
		Next nInd
	Endif

	cMailMsg += CRLF + Replicate("-", 50)

Return { cAssunto, cMailMsg }

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³ NGMAILOK  ³ Autor ³ Hugo Rizzo Pereira     ³ Data ³ 28/11/11 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Consistencias finais para envio do e-mail.                   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ cAssunto  - Assunto do e-mail a ser enviado.                 ³±±
±±³          ³ cMensagem - Mensagem a ser enviada. (Corpo do e-mail)        ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ NGINTSFC                                                     ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Static Function NGMAILOK(cAssunto,cMensagem)

	Default cAssunto  := ""
	Default cMensagem := ""

	If Empty(cAssunto)
		ShowHelpDlg(STR0001, ; // "Atenção"
					{ STR0040 }, 1,; // "O campo Assunto deve ser preenchido."
					{ STR0041 }, 1) // "Preencha corretamente o campo indicado."
		Return .F.
	Endif

	If Empty(cMensagem)
		ShowHelpDlg(STR0001, ; // "Atenção"
					{ STR0042 }, 1,; // "O campo Mensagem deve ser preenchido."
					{ STR0041 }, 1) // "Preencha corretamente o campo indicado."
		Return .F.
	Endif

Return .T.

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³ NGSFCMAIL ³ Autor ³ Hugo Rizzo Pereira     ³ Data ³ 28/11/11 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Envia e-mail ao responsavel pelo mod. Manutenção (SIGAMNT).  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ cMailCC   - End. e-mail para envio, em copia, da mensagem.   ³±±
±±³          ³ cAssunto  - Assunto do e-mail a ser enviado.                 ³±±
±±³          ³ cMensagem - Mensagem a ser enviada. (Corpo do e-mail)        ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ Generico                                                     ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function NGSFCMAIL(cMailCC, cAssunto, cMensagem)

	Local aRetMail := {}
	Local cMailTo, cMailFun

	Store "" To cMailTo, cMailFun

	Default cMailCC := ""

	// Seleciona os reponsaveis na filial corrente
	If NGIFDBSEEK("TSK",cFilAnt + "6",2)
		While TSK->(!Eof()) .And. TSK->TSK_FILIAL == xFilial("TSK") .And. ;
			TSK->TSK_FILMS == cFilAnt .And. TSK_PROCES == "6"

			// Caso o funcionario possua um endereço de e-mail informado
			cMailFun := NGSEEK("SRA",TSK->TSK_CODFUN,1,"RA_EMAIL")
			If !Empty(cMailFun)
				cMailto += AllTrim(cMailFun) + ";"
			Endif
			dbSkip()
		End
	Endif

	// Se existe algum responsavel válido na filial
	If !Empty(cMailTo)
		aRetMail := NGSFCENV(cMailTo, cMailCC, cAssunto, cMensagem)
	Else
		aRetMail := { .F., STR0043 + CRLF + STR0044 } // "Envio de e-mail cancelado!" ## "Não existem responsáveis cadastrados."
	Endif

Return aRetMail

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³ NGSFCENV ³ Autor ³ Hugo Rizzo Pereira     ³ Data ³ 28/11/11 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Envia e-mail utilizando parametros pre-definidos.           ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ cMailTo   - End. e-mail para envio da mensagem.             ³±±
±±³          ³ cMailCC   - End. e-mail para envio, em copia, da mensagem.  ³±±
±±³          ³ cAssunto  - Assunto do e-mail a ser enviado.                ³±±
±±³          ³ cMensagem - Mensagem a ser enviada. (Corpo do e-mail)       ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ NGINTSFC                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Static Function NGSFCENV(cMailTo, cMailCC, cAssunto, cMensagem)

	Local lRetMail := .T., aArea := GetArea()
	Local lOk := .F., lAutOk := .F., lSendOk := .T. // Variaveis para retorno das operações de e-mail

	// Parametros de configuração de e-mail
	Local cMailServer := AllTrim(GetNewPar("MV_RELSERV"," "))        // Servidor utilizado para envio do e-mail
	Local cMailConta  := AllTrim(GetNewPar("MV_RELACNT"," "))        // Conta utilizada para envio
	Local cMailSenha  := AllTrim(GetNewPar("MV_RELPSW" ," "))        // Senha da conta de envio
	Local lSmtpAuth   := GetNewPar("MV_RELAUTH", .F.)                // Verifica se deve realizar autenticação
	Local nTimeOut    := GetNewPar("MV_RELTIME", 120)                // Tempo de Espera antes de abortar a Conexão
	Local cUserAut    := Alltrim(GetNewPar("MV_RELAUSR",cMailConta)) // Usuário para Autenticação no Servidor de Email
	Local cSenhAut    := Alltrim(GetNewPar("MV_RELAPSW",cMailSenha)) // Senha para Autenticação no Servidor de Email
	Local cError      := ""

	// Campos a serem repassados no e-mail
	Default cMailTo   := Space(20)
	Default cMailCC   := Space(20)
	Default cAssunto  := Space(20)
	Default cMensagem := Space(20)

	// Valida existencia de campos necessarios para o envio do e-mail
	If !Empty(cMailServer) .And. !Empty(cMailConta)

		// Efetua conexao com servidor de e-mail informado
		CONNECT SMTP SERVER cMailServer ACCOUNT cMailConta PASSWORD cMailSenha TIMEOUT nTimeOut RESULT lOk

		// Verifica autenticação no servidor descrito, se necessario
		If !lAutOk
			If lSmtpAuth
				If !(lAutOk := MailAuth(cUserAut,cSenhAut))
					cMsgSend := STR0045 // "Falha na autenticação do usuário no provedor de e-mail"
					lRetMail := .F.
				Endif
			Else
				lAutOk := .T.
			EndIf
		EndIf

		If lRetMail // Caso a autenticação tenha sido efetuada corretamente.
			If lOk  // Caso a conexao com o servidor, esteja estabelecida, e possibilite o envio do e-mail
				SEND MAIL FROM cMailConta TO cMailTo CC cMailCC SUBJECT cAssunto BODY cMensagem RESULT lSendOk  // Efetua envio do e-mail

				If !lSendOk
					Get MAIL ERROR cError // Verifica erro indicado pelo servidor, no ato do envio do e-mail
				Endif

				// Armazena informações para retorno
				cMsgSend := If(lSendOk, STR0046, cError) // "E-mail enviado com sucesso!"
				lRetMail := lSendOk
			Else
				cMsgSend := STR0047 + CHR(13) + CHR(10) + ; // "Erro na conexão com o servidor SMTP."
							STR0048 // "Verifique configurações e autenticações do servidor de e-mail."
				lRetMail := .F.
			EndIf
		Endif

		DISCONNECT SMTP SERVER // Finaliza conexao com servidor de e-mail
	Else
		cMsgSend := STR0049 + CHR(13) + CHR(10) + ; // "As configurações para o acesso ao servidor de e-mail estão incorretas."
					STR0050 // "Verifique os parametros MV_RELSERV, MV_RELACNT e MV_RELPSW"
		lRetMail := .F.
	EndIf

	RestArea(aArea)

Return {lRetMail, cMsgSend}

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³NGSFCSSOS ³ Autor ³ Hugo Rizzo Pereira     ³ Data ³ 28/11/11 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Verifica disponibilidade de alteração do período.           ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ cOrdServ - Numero da Ordem de Serviço. (SIGAMNT)            ³±±
±±³          ³ dDtIni   - Nova Data de Início da O.S.                      ³±±
±±³          ³ cHrIni   - Novo horário inicial da O.S.                     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ Generico                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function NGSFCSSOS(cCodPesq, nTipoCod)

	Local aAreaTQB := TQB->(GetArea())
	Local aArea  := GetArea()
	Local nOrdem   := 0
	Local cCodAux  := ""

	Default cCodPesq := ""
	Default nTipoCod := 1

	If Empty(cCodPesq)
		Return cCodAux
	Endif

	// Define a Ordem e a chave a ser utilizada, conforme o tipo de verificação
	nOrdem := If(nTipoCod == 2, 4, 1)

	// Caso o bem estiver relacionado a algum recurso e estiver presente na CYB (Maquinas - SIGASFC)
	If NGIFDBSEEK("TQB",cCodPesq,nOrdem)
		cCodAux := If(nTipoCod == 2,TQB->TQB_ORDEM,TQB->TQB_SOLICI)
	Endif

	RestArea(aAreaTQB)
	RestArea(aArea)

Return cCodAux

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³NGSFCPDIS ³ Autor ³ Hugo Rizzo Pereira     ³ Data ³ 28/11/11 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Verifica disponibilidade de alteração do período.           ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ cOrdServ - Numero da Ordem de Serviço. (SIGAMNT)            ³±±
±±³          ³ dDtIni   - Nova Data de Início da O.S.                      ³±±
±±³          ³ cHrIni   - Novo horário inicial da O.S.                     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ Generico                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function NGSFCPDIS( oModelCZ2 )

	Local aAreaSTJ := STJ->(GetArea())
	Local aAreaSTF := STF->(GetArea())
	Local aArea    := GetArea()

	Local dDtCIni, cHrCIni, dDtCFim, cHrCFim
	Local cOrdServ, dDtIni, cHrIni
	Local nDias, nHoras

	Local cPlano  := Replicate("0",TAMSX3("TJ_PLANO")[1])
	Local aNewPer := {}
	Local lRet    := .T.

	Private dDtMIni, cHrMIni, dDtMFim, cHrMFim
	Private dDtPIni, cHrPIni, dDtPFim, cHrPFim
	Private nTmpAM, nTmpDM
	Private cCalend

	Private nDIFDAT := 0
	Private nDIFHOR := 0

	Private aNewHor := {}

	Store 0 To nDias, nHoras
	Store "" To cOrdServ, dDtIni, cHrIni

	If IsInCallStack("NGSFCATPRD")
		Return .T.
	Endif

	// Caso o parametro for repassado corretamente
	If ValType(oModelCZ2) == "O"
		cOrdServ := AllTrim(oModelCZ2:GetValue( "CZ2MASTER", "CZ2_NRORMN" ))
		dDtIni   := oModelCZ2:GetValue( "CZ2MASTER", "CZ2_DTBGPL" )
		cHrIni   := oModelCZ2:GetValue( "CZ2MASTER", "CZ2_HRBGPL" )
	Endif

	// Transforma hora repassada conforme picture utilizada
	cHrIni := Transform(cHrIni,"99:99")
	lRet   := !Empty(cOrdServ)

	// Localiza ordem de serviço informada
	If lRet .And. (lRet := NGIFDBSEEK("STJ",cOrdServ,1)) .And. STJ->TJ_PLANO > cPlano .And. (!Empty(dDtIni) .And. !Empty(cHrIni)) .And. ;
		(DTOS(STJ->TJ_DTPPINI) + STJ->TJ_HOPPINI <> DTOS(dDtIni) + cHrIni)


		// Valida utilizacao/alteracao da O.S. em questão
		If (lRet := NGSFCVALOS(dDtIni,cHrIni))

			// Tempo antes da Manutenção
			nTmpAM := If(STF->TF_UNPAANT == "I",STF->TF_TEPAANT/60,If(STF->TF_UNPAANT == "H",STF->TF_TEPAANT,If(STF->TF_UNPAANT == "S",STF->TF_TEPAANT * (120),;
						If(STF->TF_UNPAANT == "M",STF->TF_TEPAANT * (720),If(STF->TF_UNPAANT == "D",STF->TF_TEPAANT * (24),STF->TF_TEPAANT)))))

			// Tempo posterior a Manutenção
			nTmpDM := If(STF->TF_UNPADEP == "I",STF->TF_TEPADEP/60,If(STF->TF_UNPADEP == "H",STF->TF_TEPADEP,If(STF->TF_UNPADEP == "S",STF->TF_TEPADEP * (120),;
						If(STF->TF_UNPADEP == "M",STF->TF_TEPADEP * (720),If(STF->TF_UNPADEP == "D",STF->TF_TEPADEP * (24),STF->TF_TEPADEP)))))

			cCalend := STF->TF_CALENDA

			// Tempo total da Manutenção
			nTmpMan := TimeWork(STJ->TJ_DTMPINI, STJ->TJ_HOMPINI, STJ->TJ_DTMPFIM, STJ->TJ_HOMPFIM, cCalend)

			// Periodo da Parada do Bem
			// Atualiza periodo inicial de Parada do Bem
			dDtPIni := dDtIni
			cHrPIni := cHrIni

			// Periodo da Manutenção
			// Atualiza periodo inicial da Manutenção
			aNewPer := NGSFCADHOR(dDtPIni, cHrPIni, nTmpAM)
			dDtMIni := aNewPer[1]
			cHrMIni := aNewPer[2]

			// Verifica periodo util
			If (lRet := NGSFCVRFPU(dDtMIni, cHrMIni, cCalend))

				// Atualiza periodo final da Manutenção
				aNewPer := NGDTHORFCALE(dDtMIni,cHrMIni,nTmpMan,cCalend)
				dDtMFim := aNewPer[1]
				cHrMFim := aNewPer[2]

				// Atualiza periodo final de Parada do Bem
				aNewPer := NGSFCADHOR(dDtMFim, cHrMFim, nTmpDM)
				dDtPFim := aNewPer[1]
				cHrPFim := aNewPer[2]

				// Atualiza variaveis para verificação de disponibilidade
				dDtCIni := dDtMIni
				cHrCIni := cHrMIni
				dDtCFim := dDtMFim
				cHrCFim := cHrMFim

				nDIFDAT := dDtMIni - STJ->TJ_DTMPINI
				nDIFHOR := HTOM(cHrMIni) - HTOM(STJ->TJ_HOMPINI)

			Endif

		Endif

		// Verifica disponibilidade dos 'recursos' alocados, na data informada
		If lRet .And. (lRet := NGSFCDISP(cOrdServ,dDtCIni,cHrCIni,dDtCFim,cHrCFim, cCalend))

			cHrPFim := Padr(Trim(Transform(cHrPFim,"99:99:99")),8,"0")	// Ajusta Hora Inicial conforme picture apresentada no modulo de Chao de Fabrica
			cHrPIni := Padr(Trim(Transform(cHrPIni,"99:99:99")),8,"0")	// Ajusta Hora Inicial conforme picture apresentada no modulo de Chao de Fabrica

			// Caso o modelo for atualizado corretamente
			// Atualiza Ordem de Serviço com os horarios descritos
			If (lRet := oModelCZ2:LoadValue( 'CZ2MASTER' , 'CZ2_DTEDPL', dDtPFim ) .And. ;
						oModelCZ2:LoadValue( 'CZ2MASTER' , 'CZ2_HREDPL', cHrPFim ) .And. ;
						oModelCZ2:LoadValue( 'CZ2MASTER' , 'CZ2_DTBGPL', dDtPIni ) .And. ;
						oModelCZ2:LoadValue( 'CZ2MASTER' , 'CZ2_HRBGPL', cHrPIni ))

				NGSFCATOS() // Inicia processo de Atualizacao de O.S.

			Else
				Help(" ",1,STR0001,,STR0051,2,1) // "Atenção" ## "Não foi possível atualizar a parada."
			Endif

		Endif
	ElseIf !lRet
		Help(" ",1,STR0001,,STR0052,2,1) // "Atenção" ## "Ordem de serviço não encontrada."
		lRet := .F.
	Endif

	RestArea(aAreaSTF)
	RestArea(aAreaSTJ)
	RestArea(aArea)

Return lRet

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³NGSFCVALOS³ Autor ³ Hugo Rizzo Pereira     ³ Data ³ 28/11/11 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Verifica se a Ordem de Serviço está apta a aplicar a        ³±±
±±³          ³ alteração da data.                                          ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ NGINTSFC                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Static Function NGSFCVALOS(dDtIni,cHrIni)

	If STJ->TJ_SITUACA == "C" // Caso a ordem de serviço esteja cancelada
		Help(" ",1,STR0001,,STR0053,2,1) // "Atenção" ## "A Ordem de Serviço em questão foi cancelada."
		Return .F.
	ElseIf STJ->TJ_TERMINO == "S" // Caso a Ordem de Serviço esteja finalizada
		Help(" ",1,STR0001,,STR0054,2,1) // "Atenção" ## "A Ordem de Serviço em questão já foi terminada."
		Return .F.
	Endif

	// A data informada nao pode ser anterior a da ordem de serviço
	If DTOS(STJ->TJ_DTPPINI) + STJ->TJ_HOPPINI > DTOS(dDtIni) + cHrIni
		Help(" ",1,STR0001,,STR0055,2,1) // "Atenção" ## "Data prevista informada menor que a data prevista da Ordem de Serviço."
		Return .F.
	ElseIf !NGIFDBSEEK("STF",STJ->TJ_CODBEM+STJ->TJ_SERVICO+STJ->TJ_SEQRELA,1)
		Help(" ",1,STR0001,,STR0056 + CRLF + ; // "Atenção" ## "Não foi encontrada Manutencção para a O.S. informada."
								STR0057,2,1) // "Não será possível recalcular o período da manutenção."
		Return .F.
	Endif

Return .T.

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³NGSFCATOS ³ Autor ³ Hugo Rizzo Pereira     ³ Data ³15/02/2012³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Atualiza O.S. e Insumos.                                    ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ NGINTSFC                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Static Function NGSFCATOS()

	// Atualiza O.S. e Insumos relacionados
	Local cCODIGOPTER, cCODLOCALTER
	Local dMAX       := CtoD("  /  /  ")
	Local hMAX       := "  :  "
	Local nVx        := 0
	Local lDTAIGUAIS := .F.
	Local nPosSTL    := 0
	Local nRecnoAux

	//Ira verificar apenas o primeiro Produto Terceiro do parametro
	Local cCODPROTER := If(FindFunction("NGProdMNT"), NGProdMNT("T")[1], ;
							PADR(GETMV("MV_PRODTER"), TAMSX3("B1_COD")[1] ))

	dDATAPINI := STJ->TJ_DTMPINI
	cHORMPINI := STJ->TJ_HOMPINI
	dDATAPPIN := STJ->TJ_DTPPINI
	cHORAPPIN := STJ->TJ_HOPPINI

	cCODIGOP1 := STJ->TJ_ORDEM + "OS001"
	cCODIGOP2 := cCODIGOP1 + Space(TAMSX3("D4_OP")[1] - Len(cCODIGOP1))

	dbSelectArea("STJ")
	RecLock("STJ",.F.)
	STJ->TJ_DTMPINI := dDtMIni
	STJ->TJ_HOMPINI := cHrMIni
	STJ->TJ_DTMPFIM := dDtMFim
	STJ->TJ_HOMPFIM := cHrMFim

	STJ->TJ_DTPPINI := dDtPIni
	STJ->TJ_HOPPINI := cHrPIni
	STJ->TJ_DTPPFIM := dDtPFim
	STJ->TJ_HOPPFIM := cHrPFim
	STJ->(MsUnlock())

	dMAX := STJ->TJ_DTMPFIM
	hMAX := STJ->TJ_HOMPFIM

	If NGIFDBSEEK("STL",STJ->TJ_ORDEM + STJ->TJ_PLANO,1)

		While !Eof() .And. STL->TL_FILIAL == xFilial("STL") .And. ;
	              STL->TL_ORDEM == STJ->TJ_ORDEM .And. STL->TL_PLANO == STJ->TJ_PLANO

			If Alltrim(STL->TL_SEQRELA) == "0"
				dDtIniOld := STL->TL_DTINICI
				cHrIniOld := STL->TL_HOINICI

				RecLock("STL",.F.)
				STL->TL_DTINICI := STL->TL_DTINICI + nDIFDAT
				STL->TL_HOINICI := MTOH(HTOM(STL->TL_HOINICI) + nDIFHOR)
				STL->TL_DTFIM   := If(STL->TL_TIPOREG = "P", STL->TL_DTINICI, STL->TL_DTFIM + nDIFDAT)
				STL->TL_HOFIM   := MTOH(HTOM(STL->TL_HOFIM) + nDIFHOR)
				STL->(MsUnlock())

				// Verifica se nova data inicio existe no calendario, se nao existir busca proxima data no calendario
				If STL->TL_TIPOREG == "M" .And. STL->TL_USACALE == "S"

	                If Len(aNewHor) > 0 .And. (nPosSTL := aScan(aNewHor,{|x| x[1] == STL->(Recno()) })) > 0
		                RecLock("STL",.F.)
						STL->TL_DTINICI := aNewHor[nPosSTL,1]
						STL->TL_HOINICI := aNewHor[nPosSTL,2]
						STL->TL_DTFIM   := aNewHor[nPosSTL,3]
						STL->TL_HOFIM   := aNewHor[nPosSTL,4]
						STL->(MsUnlock())
					Endif

	      			If NGIFDBSEEK("STK",STL->TL_ORDEM+STL->TL_PLANO+STL->TL_TAREFA+STL->TL_CODIGO+DTOS(dDtIniOld)+cHrIniOld,1)
						RecLock("STK",.F.)
						STK->TK_DATAINI := STL->TL_DTINICI
						STK->TK_HORAINI := STL->TL_HOINICI
						STK->TK_DATAFIM := STL->TL_DTFIM
						STK->TK_HORAFIM := STL->TL_HOFIM
						STK->(MsUnlock())
	           		Endif

				EndIf

				If STL->TL_TIPOREG == "P" .Or. STL->TL_TIPOREG == "T"
					cCODIGOPTER  := If(STL->TL_TIPOREG == "P", STL->TL_CODIGO, cCODPROTER)
					cCODLOCALTER := If(STL->TL_TIPOREG == "P", STL->TL_LOCAL , NGSEEK("SB1",cCODIGOPTER,1,"B1_LOCPAD"))

					If NGIFDBSEEK("SD4",cCODIGOP2 + cCODIGOPTER + cCODLOCALTER,2)
						RecLock("SD4",.F.)
						SD4->D4_DATA := STJ->TJ_DTMPINI
						SD4->(MsUnlock())
					Endif

				Endif
			Endif

			If STL->TL_DTFIM >= dMAX
				If STL->TL_DTFIM > dMAX
					dMAX := STL->TL_DTFIM
					hMAX := STL->TL_HOFIM
				Else
					If STL->TL_HOFIM > hMAX
						hMAX := STL->TL_HOFIM
					EndIf
				EndIf
			EndIf

			NGDBSELSKIP("STL")
		End
	Endif

	If STJ->TJ_DTMPFIM <> dMAX .And. !Empty(dMAX)
		RecLock("STJ",.F.)

		STJ->TJ_DTMPFIM := dMAX
		STJ->TJ_HOMPFIM := hMAX

		aNewPer := NGSFCADHOR(dMAX, hMAX, nTmpDM)
		STJ->TJ_DTPPFIM := aNewPer[1]
		STJ->TJ_HOPPFIM := aNewPer[2]

		STJ->(MsUnLock())
	EndIf

	If NGIFDBSEEK("SC2",cCODIGOP1,6)
		While !Eof() .And. SC2->C2_FILIAL == xFilial("SC2") .And. ;
			SC2->C2_NUM + SC2->C2_ITEM + SC2->C2_SEQUEN = cCODIGOP1
			RecLock("SC2",.F.)
			SC2->C2_DATPRI := STJ->TJ_DTMPINI
			SC2->C2_DATPRF := STJ->TJ_DTMPINI
			SC2->(MsUnlock())
			Dbskip()
		End
	Endif

	//Altera Data Solicitacao Armazem
	If NGCADICBASE("TT4_FILIAL","A","TT4",.F.)
		NGIFDBSEEK("TT4",STJ->TJ_ORDEM+STJ->TJ_PLANO,2)
		While !Eof() .and. xFilial("TT4")+STJ->TJ_ORDEM+STJ->TJ_PLANO == TT4->TT4_FILIAL+TT4->TT4_ORDEM+TT4->TT4_PLANO
			If !Empty(TT4->TT4_NUMSA) .and. !Empty(TT4->TT4_ITEMSA)
				If NGIFDBSEEK("SCP",TT4->TT4_NUMSA+TT4->TT4_ITEMSA,1)
					RecLock("SCP",.f.)
					SCP->CP_DATPRF  := STJ->TJ_DTMPINI
					SCP->(MsUnLock())
				Endif
			Endif
			NGDBSELSKIP("TT4")
		End
	Endif

	// Verifica bloqueio de Recursos e Ferramentas (SH9) ----
	If NGIFDBSEEK("ST9",STJ->TJ_CODBEM,1) .And. ST9->T9_FERRAME == "R"
		If NGIFDBSEEK("SH9","B" + ST9->T9_RECFERR + DTOS(dDATAPPIN),3)

			While !Eof() .And. SH9->H9_FILIAL + SH9->H9_TIPO + SH9->H9_FERRAM + DTOS(SH9->H9_DTINI) == ;
				xFilial("SH9") + "B" + ST9->T9_RECFERR + DTOS(dDATAPPIN)

				If STJ->TJ_ORDEM $ SH9->H9_MOTIVO
					RecLock("SH9",.F.)
					SH9->H9_DTINI := dDtPIni
					SH9->H9_HRINI := cHrPIni
					SH9->H9_DTFIM := dDtPFim
					SH9->H9_HRFIM := cHrPFim
					SH9->(MsUnlock())
				EndIf

				SH9->(dbSkip())
			End
		EndIf
	EndIf
	//--------------------------------------------------------

Return

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³NGSFCDISP ³ Autor ³ Hugo Rizzo Pereira     ³ Data ³ 28/11/11 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Verifica disponibilidade (bloqueios).                       ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ cOrdServ - Numero da Ordem de Serviço. (SIGAMNT)            ³±±
±±³          ³ dDtIni   - Nova data de inicio.                             ³±±
±±³          ³ cHrIni   - Novo horario de inicio.                          ³±±
±±³          ³ dDtFim   - Nova data de inicio.                             ³±±
±±³          ³ cHrFim   - Novo horario de fim.                             ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ NGINTSFC                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Static Function NGSFCDISP( cOrdServ, dDtIni, cHrIni, dDtFim, cHrFim, cCodCal )

	Local aAreaSTJ := STJ->(GetArea())
	Local aArea    := GetArea()
	Local lRet     := .T.

	Default cOrdServ := ""
	Default dDtIni   := ""
	Default cHrIni   := ""
	Default dDtFim   := ""
	Default cHrFim   := ""

	// Caso o periodo definido seja invalido
	If Empty(dDtIni) .Or. Empty(cHrIni) .Or. Empty(dDtFim) .Or. Empty(cHrFim)
		Help(" ",1,STR0001,,STR0058,2,1) // "Atenção" ## "Período informado é inválido."
		Return .F.
	Endif

	// Caso a data fim seja menor que a data inicio
	If DTOS(dDtIni) + cHrIni > DTOS(dDtFim) + cHrFim
		Help(" ",1,STR0001,,STR0059,2,1) // "Atenção" ## "Período inicial deve ser menor que período final."
		Return .F.
	Endif

	// Incializa variavel para controle de periodo conforme calendario
	aNewHor := {}

	// Verifica existencia de inconsistencias e bloqueios no periodo informado
	If !Empty(cOrdServ) .And. NGIFDBSEEK("STJ",cOrdServ,1)

		// Verifica se a data informada e' menor que a data da O.S.
		If DTOS(STJ->TJ_DTMPINI) + STJ->TJ_HOMPINI > DTOS(dDtIni) + cHrIni
			Help(" ",1,STR0001,,STR0060,2,1) // "Atenção" ## "Data prevista calculada menor que a data prevista da Ordem de Serviço."
			lRet := .F.
		Else
			lRet := NGSFCBLQ()
		Endif
	Endif

	RestArea(aAreaSTJ)
	RestArea(aArea)

Return lRet

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³ NGSFCBLQ ³ Autor ³ Hugo Rizzo Pereira     ³ Data ³ 28/11/11 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Verifica a existencia de bloqueios conforme O.S. atual.     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ NGINTSFC                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Static Function NGSFCBLQ()

	Local aArea := GetArea()
	Local lRet  := .T.

	// Se o bem informado e valido
	If NGIFDBSEEK("ST9",STJ->TJ_CODBEM,1)

		// Verifica bloqueios do recurso, relacionado ao bem, na SH9
		lRet := NGSFCVRSH9()

	Endif

	RestArea(aArea)

Return lRet

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³NGSFCVRSH9³ Autor ³ Hugo Rizzo Pereira     ³ Data ³ 28/11/11 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Seleciona as O.S., nao canceladas, referente a maquina      ³±±
±±³          ³ e a data repassada.                                         ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ cRecSFC - Codigo da Maquina a ser verificada.               ³±±
±±³          ³ dDtAux   - Data para seleção das O.S.                       ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ NGINTSFC                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Static Function NGSFCVRSH9()

	Local lRet := .T.

	If ST9->T9_FERRAME == "R" // Verifica bloqueio de Recurso

		dbSelectArea("SH9")
		SH9->(dbSetOrder(1))
		If SH9->(!dbSeek(xFilial("SH9") + "B" + ST9->T9_CCUSTO + ST9->T9_RECFERR + DTOS(dDtPIni), .T.))
			SH9->(dbSkip(-1))
		Endif

		While SH9->(!Eof()) .And. SH9->H9_FILIAL == xFilial("SH9") .And. SH9->H9_TIPO == "B" .And. ;
			SH9->H9_RECURSO == ST9->T9_RECFERR .And. (DTOS(SH9->H9_DTFIM) + SH9->H9_HRFIM <= DTOS(dDtPFim))

			If STJ->TJ_ORDEM $ SH9->H9_MOTIVO
				dbSelectArea("SH9")
				dbSkip()
				Loop
			EndIf

			cDtHrIni := DTOS(dDtPIni) + cHrPIni
			cDtHrFim := DTOS(dDtPFim) + cHrPFim

			If ((DTOS(SH9->H9_DTINI) + SH9->H9_HRINI <= cDtHrIni) .And. (DTOS(SH9->H9_DTFIM) + SH9->H9_HRFIM >= cDtHrIni)) .Or. ;
				((DTOS(SH9->H9_DTINI) + SH9->H9_HRINI <= cDtHrFim) .And. (DTOS(SH9->H9_DTFIM) + SH9->H9_HRFIM >= cDtHrFim))
				lRet := .F.
				Exit
			Endif
			SH9->(dbSkip())
		End

		If !lRet
			Help(" ",1,STR0001,,STR0061 + CRLF + ; // "Atenção" ## "Período informado não está disponível."
									STR0065,2,1) // "Existe bloqueio para o bem no período em questão."
		Endif

	Endif

Return lRet

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³NGRETOSCOR³ Autor ³ Hugo Rizzo Pereira     ³ Data ³ 28/11/11 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Seleciona as O.S., nao canceladas, referente a maquina      ³±±
±±³          ³ e a data repassada.                                         ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ cRecSFC - Codigo da Maquina a ser verificada.               ³±±
±±³          ³ dDtAux   - Data para seleção das O.S.                       ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ Generico                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function NGSFCOSCOR( cRecSFC, dDtAux )

	// Variaveis utilizadas para controle na função
	Local aAreaSTJ := STJ->(GetArea())
	Local aOS      := {}

	// Variaveis para formação da chave de pesquisa
	Local cPlano   := Replicate("0",TAMSX3("TJ_PLANO")[1])
	Local cCodBem  := NGVRFMAQ(cRecSFC,2)

	// Caso haja ordem de serviço corretiva
	If !Empty(cCodBem) .And. NGIFDBSEEK("STJ",cPlano + "B" + cCodBem + DTOS(dDtAux),9)
		While STJ->(!Eof()) .And. xFilial("STJ") == STJ->TJ_FILIAL .And. STJ->TJ_PLANO == cPlano .And. ;
			STJ->TJ_TIPOOS == "B" .And. STJ->TJ_CODBEM == cCodBem .And. DTOS(STJ->TJ_DTMPINI) == DTOS(dDtAux)

			// Considera apenas O.S. não finalizadas e com situação Pendente ou Liberada
			If STJ->TJ_SITUACA != "C"

				cObserva := If(NGCADICBASE("TJ_MMSYP","A","STJ",.F.),MSMM(STJ->TJ_OBSERVA),STJ->TJ_OBSERVA)
				aInsumos := NGSFCINS() // Seleciona insumos relacionados a Ordem de Serviço

				aAdd(aOS, {STJ->TJ_ORDEM, STJ->TJ_SITUACA, cObserva, STJ->TJ_SERVICO, ;
				NGSEEK("ST4",STJ->TJ_SERVICO,1,"T4_NOME"), NGSEEK("ST4",STJ->TJ_SERVICO,1,"T4_DESCRIC"), aInsumos})
			Endif

			dbSelectArea("STJ")
			dbSkip()
		End
	Endif

	RestArea(aAreaSTJ)

Return aOS

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³ NGSFCINS ³ Autor ³ Hugo Rizzo Pereira     ³ Data ³ 28/11/11 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Seleciona os insumos relacionadas a O.S. posicionada.       ³±±
±±³          ³ Considerado apenas, insumos de Mao de Obra e Terceiros.     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ NGINTSFC                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Static Function NGSFCINS()

	Local cDescri, cNomTReg, cExec

	Local aAreaSTL := STL->(GetArea())
	Local aInsumos := {}

	dbSelectArea("STL")
	dbSetOrder(3)
	dbSeek(xFilial("STL") + STJ->TJ_ORDEM + STJ->TJ_PLANO)
	While STl->(!Eof()) .And. STL->TL_FILIAL == xFilial("STL") .And. ;
		STL->TL_ORDEM == STJ->TJ_ORDEM .And. STL->TL_PLANO == STJ->TJ_PLANO

		// Considera apenas insumos do tipo Mao de Obra e Terceiros
		If STL->TL_TIPOREG $ "M/T"

			// Define nome do tipo do Insumo
			cExec := If(AllTrim(STL->TL_SEQRELA) == "0", STR0067, STR0068) // "Previsto" ## "Realizado"

			// Mao de Obra
			If STL->TL_TIPOREG == "M"
				cDescri  := NGSEEK("SRA",AllTrim(STL->TL_CODIGO),1,"RA_NOME")
				cNomTReg := STR0069 // "Mão de Obra"
			Else // Terceiros
				cDescri  := NGSEEK("SA2",AllTrim(STL->TL_CODIGO),1,"A2_NOME")
				cNomTReg := STR0070 // "Terceiros"
			Endif

			aAdd(aInsumos, {cExec, cNomTReg, NGSEEK("TT9",STL->TL_TAREFA,1,"TT9_DESCRI"), ;
			STL->TL_OBSERVA, cDescri } )
		Endif

		dbSelectArea("STL")
		dbSkip()
	End

	RestArea(aAreaSTL)

Return aInsumos

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³NGSFCERPL ³ Autor ³ Hugo Rizzo Pereira     ³ Data ³ 28/11/11 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Apresenta registros que não puderam ser repassados ao SFC.  ³±±
±±³          ³ Possibilitando a marcação dos mesmos, direcionando-os ao    ³±±
±±³          ³ conteudo do e-mail a ser enviado ao SFC.                    ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ NGINTSFC                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function NGSFCERPL( nOper, aSFCErro )

	Local ODlgEr, oMark, nInd
	Local cMarca    := GetMark()
	Local aDBF      := {}
	Local aTRBER    := {}
	Local aMailInfo := {}
	Local nOpcao    := 0
	Local cProb     := ""
	Local cAviso    := ""
	Local oTempTMP  := Nil
	Local aIndTrbE1 := {}

	Aadd(aDBF,{"OK"         , "C", 2                	    , 0 })
	Aadd(aDBF,{"TJ_ORDEM"   , "C", TAMSX3("TJ_ORDEM"  )[1] , 0 })
	Aadd(aDBF,{"TJ_CODBEM"  , "C", TAMSX3("TJ_CODBEM" )[1] , 0 })
	Aadd(aDBF,{"TJ_DTMPINI" , "D", TAMSX3("TJ_DTMPINI")[1] , 0 })
	Aadd(aDBF,{"TJ_HOMPINI" , "C", TAMSX3("TJ_HOMPINI")[1] , 0 })
	Aadd(aDBF,{"TJ_DTMPFIM" , "D", TAMSX3("TJ_DTMPFIM")[1] , 0 })
	Aadd(aDBF,{"TJ_HOMPFIM" , "C", TAMSX3("TJ_HOMPFIM")[1] , 0 })

	Aadd(aTRBER,{"OK"        , NIL, " "     ,})
	Aadd(aTRBER,{"TJ_ORDEM"  , NIL, STR0008 ,}) // "O.S."
	Aadd(aTRBER,{"TJ_CODBEM" , NIL, STR0075 ,}) // "Bem"
	Aadd(aTRBER,{"TJ_DTMPINI", NIL, STR0071 ,}) // "Data Ini. Prev."
	Aadd(aTRBER,{"TJ_HOMPINI", NIL, STR0072 ,}) // "Hora Ini. Prev."
	Aadd(aTRBER,{"TJ_DTMPFIM", NIL, STR0073 ,}) // "Data Fin. Prev."
	Aadd(aTRBER,{"TJ_HOMPFIM", NIL, STR0074 ,}) // "Hora Fin. Prev."

	cTRBERSFC := GetNextAlias()
	aIndTrbE1 := {{"TJ_ORDEM","TJ_CODBEM"}}
	oTempTMP  := NGFwTmpTbl(cTRBERSFC,aDBF,aIndTrbE1)

	For nInd := 1 To Len(aSFCErro)
		dbSelectArea(cTRBERSFC)
		RecLock(cTRBERSFC, .T.)
		(cTRBERSFC)->OK := Space(2)

		If !Empty(aSFCErro[nInd][1])
			(cTRBERSFC)->TJ_ORDEM  := aSFCErro[nInd][1]
		Endif

		(cTRBERSFC)->TJ_CODBEM  := aSFCErro[nInd][2]
		(cTRBERSFC)->TJ_DTMPINI := aSFCErro[nInd][3]
		(cTRBERSFC)->TJ_HOMPINI := aSFCErro[nInd][4]
		(cTRBERSFC)->TJ_DTMPFIM := aSFCErro[nInd][5]
		(cTRBERSFC)->TJ_HOMPFIM := aSFCErro[nInd][6]
		(cTRBERSFC)->(MsUnlock())
	Next nInd

	dbSelectArea(cTRBERSFC)
	dbGoTop()

	cProb  := STR0076 // "Os registros abaixo, não foram repassados ao Chão de Fábrica (SIGASFC)."
	cAviso := STR0077 // "Selecione os registros a serem referenciados no e-mail."

	DEFINE MSDIALOG ODlgEr TITLE STR0078 + "  |  SIGASFC" FROM 0,0 TO 300,570 OF oMainWnd Pixel // "Erros"

		ODlgEr:lEscClose := .F.

		oPnlBg := TPanel():New(00,00,,ODlgEr,,,,,,0,0,.F.,.F.)
		oPnlBg:Align := CONTROL_ALIGN_ALLCLIENT

		oPnlAviso := TPanel():New(00,00,,oPnlBg,,,,,,0,28,.F.,.F.)
		oPnlAviso:Align := CONTROL_ALIGN_TOP

		TSay():New(005, 005, {|| cProb  }, oPnlAviso, , , , , , .T., CLR_BLACK, CLR_WHITE, 200, 100)
		TSay():New(015, 005, {|| cAviso }, oPnlAviso, , , , , , .T., CLR_BLACK, CLR_WHITE, 250, 100)

		oMark := MsSelect():New(cTRBERSFC,"OK",,aTRBER,,@cMarca,{0,0,0,0},,,oPnlBg)
		oMark:oBrowse:Align    := CONTROL_ALIGN_ALLCLIENT
		oMark:oBrowse:bAllMark := {|| NGSFCERALL(cTRBERSFC, @cMarca, @oMark) }

	ACTIVATE MSDIALOG ODlgEr ON INIT EnchoiceBar(ODlgEr,{|| nOpcao := 1, ODlgEr:End() },{|| nOpcao := 0, ODlgEr:End() }) CENTERED

	If nOpcao == 1
		dbSelectArea(cTRBERSFC)
		dbGoTop()
		While (cTRBERSFC)->(!Eof())
			If !Empty((cTRBERSFC)->OK)
				aAdd(aMailInfo,{(cTRBERSFC)->TJ_ORDEM,(cTRBERSFC)->TJ_CODBEM,(cTRBERSFC)->TJ_DTMPINI,(cTRBERSFC)->TJ_HOMPINI,(cTRBERSFC)->TJ_DTMPFIM,(cTRBERSFC)->TJ_HOMPFIM})
			Endif
			(cTRBERSFC)->(dbSkip())
		End
		If Len(aMailInfo) > 0
			NGSFCSNDML(nOper, aMailInfo, .F.)
		Endif
	Endif

	oTempTMP:Delete()

Return

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³NGSFCERALL³ Autor ³ Hugo Rizzo Pereira     ³ Data ³ 28/11/11 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Marcacao de todos os itens markbrowse.                      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ NGINTSFC                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Static Function NGSFCERALL( cTRBERSFC, cMarca, oMark )

	dbSelectArea(cTRBERSFC)
	dbgoTop()
	While !Eof()
		(cTRBERSFC)->OK := If(Empty((cTRBERSFC)->OK),cMarca,Space(2))
		(cTRBERSFC)->(dbSkip())
	End

	dbSelectArea(cTRBERSFC)
	dbGoTop()
	oMark:oBrowse:Refresh()

Return

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³NGSFCCANPR³ Autor ³ Hugo Rizzo Pereira     ³ Data ³ 28/11/11 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Verifica a necessidade de geracao da parada programada.     ³±±
±±³          ³ Caso exista uma parada real com o numero da S.S., a parada  ³±±
±±³          ³ programada nao deve ser gerada, ja que a mesma foi criada   ³±±
±±³          ³ pelo modulo SIGASFC, a partir de uma parada real.           ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ Generico                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function NGSFCCANPR( cOrdemServ )

	Local aArea    := GetArea()
	Local aAreaCYX := CYX->(GetArea())
	Local lRet     := .T.
	Local cSolicit := ""
	Local nOrdCYX  := NGRETORDEM("CYX","CYX_FILIAL+CYX_NRSS",.T.)

	Default cOrdemServ := ""

	cSolicit := If( !Empty(cOrdemServ), NGSEEK("STJ", cOrdemServ, 1, "TJ_SOLICI"), "" )

	If !Empty(cSolicit) .And. ( lRet := (nOrdCYX > 0) )
		dbSelectArea('CYX')
		CYX->(dbSetOrder(nOrdCYX))
		lRet := !CYX->(dbSeek(xFilial('CYX') + cSolicit))
	Endif

	RestArea(aAreaCYX)
	RestArea(aArea)

Return lRet

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³NGSFCADHOR³ Autor ³Hugo Rizzo Pereira     ³ Data ³10/02/2012³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³Calcula a data e hora fim a partir de uma data e hora       ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³NGINTSFC                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Static Function NGSFCADHOR( dDtAux, cHrAux, nQtdHr )

	Local nMinFim  := HTOM(cHrAux) + (nQtdHr * 60)
	Local nDiasRet := 0

	While nMinFim >= 1440
		nDiasRet++
		nMinFim -= 1440
	End

Return {dDtAux + nDiasRet, MTOH(nMinFim)}

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³NGSFCVRFPU³ Autor ³Hugo Rizzo Pereira     ³ Data ³10/02/2012³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³Calcula a data e hora fim a partir de uma data e hora       ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³NGINTSFC                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Static Function NGSFCVRFPU(dData, cHora, cCalend)

	Local aCalend := {}
	Local aPerDis := {}
	Local lPerOk  := .F.
	Local nHor, nIndSem
	Local aNewPer := {}
	Local dDataAux := dData

	nIndSem := Dow(dData)
	aCalend := NGCALENDAH(cCalend)

	If Len(aCalend[nIndSem,2]) > 0

		For nHor := 1 To Len(aCalend[nIndSem,2])
			If cHora < aCalend[nIndSem,2,nHor,2]
				If Len(aPerDis) == 0
					aPerDis := aCalend[nIndSem,2,nHor]
				Endif
				If (cHora >= aCalend[nIndSem,2,nHor,1] .And. cHora < aCalend[nIndSem,2,nHor,2])
					lPerOk := .T.
					Exit
				Endif
			Endif
		Next nHor

		If !lPerOk .And. Len(aPerDis) == 0 .And. Len(aCalend[nIndSem,2]) > 0
			aPerDis := aCalend[nIndSem,2,Len(aCalend[nIndSem,2])]
		Endif
	Endif

	If !lPerOk
		If Len(aPerDis) == 0
			cMsgHelp := STR0079 // "O dia informado não é um dia útil para a manutenção."
		Else
			aNewPer := NGRETIRAHOR(aPerDis[1],NTOH(nTmpAM))
			aPerDis[1] := aNewPer[1]
			dDataAux   -= aNewPer[2]

			aNewPer    := NGRETIRAHOR(aPerDis[2],NTOH(nTmpAM))
			aPerDis[2] := aNewPer[1]

			cMsgHelp := STR0080 + CRLF + CRLF // "O período informado não é útil para a manutenção."
			cMsgHelp += STR0081 + Space(1) + CRLF // "Perído, útil, próximo ao informado:"
			cMsgHelp += STR0082 + Space(1) + DTOC(dDataAux) + CRLF // "Data:"
			cMsgHelp += STR0083 + Space(1) + aPerDis[1] + CRLF // "Hora Inicial:"
			cMsgHelp += STR0084 + Space(1) + aPerDis[2] // "Hora Final:"
		Endif
		Help(" ",1,STR0001,,cMsgHelp,3,1) // "Atenção"
	Endif

Return lPerOk

//-------------------------------------------------------------------
/*/{Protheus.doc} MNTAJUSSH9
Realiza a alteração ou deleção do registro de bloqueio na SH9

@param cOrdem, caractere, Código da ordem de serviço
@param cPlano, caractere, Código do plano da O.s.
@param aDatasBkp, array,  Respectivamente Data inicio e Hora Inicio da Parada do Bem
(Caso a operação seja de alteração a Data e Hora deve ser anterior ao ajuste)

@author João Ricardo Santini Zandoná
@since 26/03/2024
@return Nil
/*/
//-------------------------------------------------------------------
Function MNTAJUSSH9(cOrdem, cPlano, aDatasBkp)

	Local aDtIni as Array
	Local aDtFim as Array
	Local cSeek  as Caracter

	dbSelectArea('STJ')
	dbSetOrder(1) // Filial + Ordem Serv. + Plano Manut.
	msSeek(FWxFilial('STJ')+cOrdem+cPlano)

	// RECALCULA DATA DE PARADA PREVISTA INÍCIO DA MANUTENÇÃO.
	aDtIni := MNT490PRE( STJ->TJ_CODBEM, STJ->TJ_SERVICO, STJ->TJ_SEQRELA, STJ->TJ_DTMPINI, STJ->TJ_HOMPINI )
	// RECALCULA DATA DE PARADA PREVISTA FIM DA MANUTENÇÃO.
	aDtFim := MNT490POS( STJ->TJ_CODBEM, STJ->TJ_SERVICO, STJ->TJ_SEQRELA, STJ->TJ_DTMPFIM, STJ->TJ_HOMPFIM )

	dbSelectArea('ST9')
	dbSetOrder(1) // Filial + Bem
	msSeek(FWxFilial('ST9')+STJ->TJ_CODBEM)

	dbSelectArea('SH9')

	If ST9->T9_FERRAME == 'R'
		cSeek := FWxFilial('SH9')+'B'+ST9->T9_CCUSTO+ST9->T9_RECFERR+DTOS(aDatasBkp[1])+aDatasBkp[2]
		dbSetOrder(1) // Filial + Tipo + C. Custo + Recurso + DT Inicial + Hora Inicial
	Else
		cSeek := FWxFilial('SH9')+'F'+ST9->T9_RECFERR+DTOS(aDatasBkp[1])+aDatasBkp[2]
		dbSetOrder(3) // Filial + Tipo + Ferramenta + DT Inicial + Hora Inicial
	EndIf
	
	If msSeek(cSeek)
		
		RecLock("SH9",.F.)
		
		SH9->H9_DTINI := aDtIni[1]
		SH9->H9_HRINI := aDtIni[2]
		SH9->H9_DTFIM := aDtFim[1]
		SH9->H9_HRINI := aDtFim[2]
		
		SH9->(MsUnlock())
	
	EndIf

	FWFreeArray(aDtIni)
	FWFreeArray(aDtFim)

Return
