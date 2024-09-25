#include "Protheus.ch"

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³ SGAP010  ³ Autor ³ Rafael Diogo Richter  ³ Data ³06/03/2007³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³Monta Array para o Painel On-line do tipo 5:                ³±±
±±³          ³- Ocorrencias por Plano Emergencial                         ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe	 ³ SGAP010() 										   	  			     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ SigaSGA                                                    ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³ Array = { cClick, aCabec, aValores }                       ³±±
±±³          ³ cClick   = Funcao p/ execucao do duplo-click no browse     ³±±
±±³          ³ aCabec   = Array contendo o cabecalho                      ³±±
±±³          ³ aValores = Array contendo os valores da lista       		  ³±±
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
Function SGAP010()
Local cAliasTrb := ''
Local aCabec := {}
Local aValores := {}
Local aRetPanel := {}
Local lQuery := .F.

dbSelectArea("TBB")
dbSetOrder(1)

dbSelectArea("TBV")
dbSetOrder(1)

aCabec := {"Plano","Descrição","Responsável","Nome","Ocorrências"}

#IFDEF TOP
	lQuery    := .T.
	cAliasTrb := GetNextAlias()

	BeginSql Alias cAliasTrb
		SELECT TBB_DESPLA, TBB_RESPON, QAA_NOME,TBB_CODPLA ,(SELECT COUNT(TBV_CODPLA) FROM %Table:TBV% TBV
	 		WHERE TBV.TBV_FILIAL = %xFilial:TBV%
	 			AND TBV.TBV_CODPLA = TBB.TBB_CODPLA GROUP BY TBV.TBV_CODPLA) nOco
		FROM %Table:TBB% TBB
		LEFT JOIN %Table:QAA% QAA ON QAA.QAA_FILIAL = %xFilial:QAA%
			AND QAA.%NotDel%
			AND QAA.QAA_MAT = TBB.TBB_RESPON
		WHERE TBB.TBB_FILIAL = %xFilial:TBB%
			AND TBB.%NotDel%
		ORDER BY TBB_CODPLA
	EndSql

#ELSE

	dbSelectArea("TBB")
	dbSetOrder(1)
	dbGoTop()
	While !Eof()
		nOco := 0
		dbSelectArea("TBV")
		dbSetOrder(1)
		dbSeek(xFilial("TBV")+TBB->TBB_CODPLA)
		While !Eof() .And. TBV->TBV_FILIAL == xFilial("TBV") .And. TBV->TBV_CODPLA == TBB->TBB_CODPLA
			nOco ++
			dbSelectArea("TBV")
			dbSkip()
		End
		dbSelectArea("QAA")
		dbSetOrder(1)
		dbSeek(xFilial("QAA")+TBB->TBB_RESPON)
		aAdd(aValores, {TBB->TBB_CODPLA, TBB->TBB_DESPLA, TBB->TBB_RESPON, QAA->QAA_NOME, nOco})

		dbSelectArea("TBB")
		dbSkip()
	End
#ENDIF

If lQuery
	While (cAliasTrb)->( !Eof() )
		(cAliasTrb)->(aAdd(aValores, {TBB_CODPLA, TBB_DESPLA, TBB_RESPON, QAA_NOME, nOco})) 
		DbSkip()
	End

	dbSelectArea(cAliasTrb)
	dbCloseArea()

	dbSelectArea("TBV")
	dbSetOrder(1)
EndIf

If Empty(aValores)
	aAdd(aValores, {'', '', '', '', 0})
EndIf

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Preenche array do Painel de Gestao                                      ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
aRetPanel := { Nil, aCabec, aValores }

Return aRetPanel