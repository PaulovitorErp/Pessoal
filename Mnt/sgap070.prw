#include "protheus.ch"
#include "msgraphi.ch"

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³ SGAP070  ³ Autor ³ Rafael Diogo Richter  ³ Data ³09/03/2007³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Monta array para Painel de Gestao On-line Tipo/Padrao 2.2: ³±±
±±³          ³ Planos de Acoes Pendentes                                  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³SGAP070()                                                   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³ Array = {cTypeGraf,{cTitleG,bClickG,aEixoX,aEixoY},        ³±±
±±³          ³ {cTitleT,bClickT,aTabela}}                                 ³±±
±±³          ³ cTypeGraph = Tipo do grafico                       		  ³±±
±±³          ³ cTitleG    = Titulo do grafico                      		  ³±±
±±³          ³ bClickG    = Bloco de codigo executado no click do grafico ³±±
±±³          ³ aEixoX     = Atributos do eixo X                           ³±±
±±³          ³ aEixoY     = Atributos do eixo Y                           ³±±
±±³          ³ cTitleT    = Titulo da tabela                              ³±±
±±³          ³ bClickT    = Bloco de codigo executado no click da tabela  ³±±
±±³          ³ aTabela    = Array multidimensional contendo os array por  ³±±
±±³          ³ filtro, no formato{"filtro",aCabec,aValores}               ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ SIGASGA                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function SGAP070()
Local cAliasTrb := ''
Local lQuery := .F.
Local aRetPanel := {}
Local aTabela := {}
Local aAcaoDia := {}
Local aAcaoAtras := {}
Local aQtdAcao := {}
Local aTipoAcao := {}
Local aCabec := {"Plano", "Nome", "Dt Term Prev"}

dbSelectArea("TAA")
dbSetOrder(1)

#IFDEF TOP

	lQuery    := .T.
	cAliasTrb := GetNextAlias()

	BeginSql Alias cAliasTrb
		SELECT TAA_CODPLA, TAA_NOME, TAA_DTFIPR
		FROM %Table:TAA% TAA
		WHERE TAA.TAA_FILIAL = %xFilial:TAA%
			AND TAA.%NotDel%
			AND TAA.TAA_QTDATU < TAA.TAA_META
			AND TAA.TAA_PERCEN < 100
			AND TAA.TAA_STATUS <> '2'
		ORDER BY TAA_CODPLA
	EndSql

#ELSE

	dbSelectArea("TAA")
	dbSetOrder(1)
	dbGoTop()
	While !Eof() .And. TAA->TAA_FILIAL == xFilial("TAA")

		If TAA->TAA_QTDATU < TAA->TAA_META .And. TAA->TAA_PERCEN < 100 .And. TAA->TAA_STATUS <> "2"
			If TAA->TAA_DTFIPR >= dDataBase
				aAdd(aAcaoDia, {TAA->TAA_CODPLA, TAA->TAA_NOME, TAA->TAA_DTFIPR})
			Else
				aAdd(aAcaoAtras, {TAA->TAA_CODPLA, TAA->TAA_NOME, TAA->TAA_DTFIPR})
			EndIf
		EndIf

		dbSelectArea("TAA")
		dbSkip()
	End

#ENDIF


If lQuery
	While (cAliasTrb)->( !Eof() )
		If STOD((cAliasTrb)->TAA_DTFIPR) >= dDataBase
			(cAliasTrb)->(aAdd(aAcaoDia, {TAA_CODPLA, TAA_NOME, STOD(TAA_DTFIPR)}))
		Else
			(cAliasTrb)->(aAdd(aAcaoAtras, {TAA_CODPLA, TAA_NOME, STOD(TAA_DTFIPR)}))
		EndIf
		DbSkip()
	End

	dbSelectArea(cAliasTrb)
	dbCloseArea()

	dbSelectArea("TAA")
	dbSetOrder(1)
EndIf

If !Empty(aAcaoDia)
	Aadd(aTipoAcao, "Em dia")
	aAdd(aTabela, { aTipoAcao[Len(aTipoAcao)], aCabec, aAcaoDia})
	aAdd(aQtdAcao, Len(aAcaoDia))
EndIf

If !Empty(aAcaoAtras)
	Aadd(aTipoAcao, "Em atraso")
	aAdd(aTabela, { aTipoAcao[Len(aTipoAcao)], aCabec, aAcaoAtras})
	aAdd(aQtdAcao, Len(aAcaoAtras))
EndIf

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Complementa o array com informacoes nulas, caso nao haja informacao p/ ser exibida³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If Empty(aTabela)
	Aadd(aTipoAcao, "")
	Aadd(aTabela, {aTipoAcao[1], aCabec, { {"","","",""} } })
	Aadd(aQtdAcao,1)
EndIf

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Preenche array do Painel de Gestao                                      ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
aRetPanel := 	{ GRP_PIE, {"Quantidade de Planos de Ação", /*{|| ONCLICKG()}*/, aTipoAcao, aQtdAcao},;
					{ "Planos de Ação", /*{|| ONCLICKG()}*/, aTabela}}

Return aRetPanel