#include "Protheus.ch"

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³ SGAP040  ³ Autor ³ Rafael Diogo Richter  ³ Data ³08/03/2007³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³Monta Array para o Painel On-line do tipo 1:                ³±±
±±³          ³- Demandas Vencidas                                         ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe	 ³ SGAP040() 										   	  			     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ SigaSGA                                                    ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³ Array = {{cText1,cValor,nColorValor,bClick},...}           ³±±
±±³          ³ cTexto1     = Texto da Coluna                       		  ³±±
±±³          ³ cValor      = Valor a ser exibido (string)          		  ³±±
±±³          ³ nColorValor = Cor do valor no formato RGB (opcional)       ³±±
±±³          ³ bClick      = Funcao executada no click do valor (opcional)³±±
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
Function SGAP040()
Local cAliasTrb := ''
Local aLeg := {0,0,0,0,0,0,0}
Local aRetPanel := {}
Local lQuery := .F.

dbSelectArea("TA0")
dbSetOrder(1)

#IFDEF TOP

	lQuery    := .T.
	cAliasTrb := GetNextAlias()

	BeginSql Alias cAliasTrb
		SELECT COUNT(TA0_CODLEG) nLeg1,
			(SELECT COUNT(TA0_CODLEG)
			FROM 	%Table:TA0% TA01
			WHERE TA01.TA0_FILIAL = %xFilial:TA0%
				AND TA01.%NotDel%
				AND TA01.TA0_DTVENC <> ' '
				AND TA01.TA0_DTVENC < %Exp:Dtos(dDataBase)%
				AND TA01.TA0_DTVENC >= %Exp:Dtos(dDataBase-1)%) nLeg2, 
			(SELECT COUNT(TA0_CODLEG)
			FROM %Table:TA0% TA02
			WHERE TA02.TA0_FILIAL = %xFilial:TA0%
				AND TA02.%NotDel%
				AND TA02.TA0_DTVENC <> ' '
				AND TA02.TA0_DTVENC < %Exp:Dtos(dDataBase-1)%
				AND TA02.TA0_DTVENC >= %Exp:Dtos(dDataBase-3)%) nLeg3, 
			(SELECT COUNT(TA0_CODLEG)
			FROM %Table:TA0% TA03
			WHERE TA03.TA0_FILIAL = %xFilial:TA0%
				AND TA03.%NotDel%
				AND TA03.TA0_DTVENC <> ' '
				AND TA03.TA0_DTVENC < %Exp:Dtos(dDataBase-3)%
				AND TA03.TA0_DTVENC >= %Exp:Dtos(dDataBase-5)%) nLeg4, 
			(SELECT COUNT(TA0_CODLEG)
			FROM %Table:TA0% TA04
			WHERE TA04.TA0_FILIAL = %xFilial:TA0%
				AND TA04.%NotDel%
				AND TA04.TA0_DTVENC <> ' '
				AND TA04.TA0_DTVENC < %Exp:Dtos(dDataBase-5)%
				AND TA04.TA0_DTVENC >= %Exp:Dtos(dDataBase-7)%) nLeg5, 
			(SELECT COUNT(TA0_CODLEG)
			FROM %Table:TA0% TA05
			WHERE TA05.TA0_FILIAL = %xFilial:TA0%
				AND TA05.%NotDel%
				AND TA05.TA0_DTVENC <> ' '
				AND TA05.TA0_DTVENC < %Exp:Dtos(dDataBase-7)%
				AND TA05.TA0_DTVENC >= %Exp:Dtos(dDataBase-14)%) nLeg6, 
			(SELECT COUNT(TA0_CODLEG)
			FROM %Table:TA0% TA06
			WHERE TA06.TA0_FILIAL = %xFilial:TA0%
				AND TA06.%NotDel%
				AND TA06.TA0_DTVENC <> ' '
				AND TA06.TA0_DTVENC < %Exp:Dtos(dDataBase-14)%
				AND TA06.TA0_DTVENC >= %Exp:Dtos(dDataBase-15)%) nLeg7
		FROM %Table:TA0% TA0
		WHERE TA0.TA0_FILIAL = %xFilial:TA0%
			AND TA0.%NotDel%
			AND TA0.TA0_DTVENC = ' '
			OR TA0.TA0_DTVENC >= %Exp:Dtos(dDataBase)% 
			GROUP BY TA0_FILIAL
	EndSql

#ELSE

	dbSelectArea("TA0")
	dbSetOrder(1)
	dbGoTop()
	While !Eof() .And. xFilial("TA0") == TA0->TA0_FILIAL

		If Empty(TA0->TA0_DTVENC) .Or. TA0->TA0_DTVENC >= dDataBase
			aLeg[1] += 1
		ElseIf !Empty(TA0->TA0_DTVENC) .And. TA0->TA0_DTVENC < dDataBase .And. TA0->TA0_DTVENC >= dDataBase-1
			aLeg[2] += 1		
		ElseIf !Empty(TA0->TA0_DTVENC) .And. TA0->TA0_DTVENC < dDataBase-1 .And. TA0->TA0_DTVENC >= dDataBase-3
			aLeg[3] += 1
		ElseIf !Empty(TA0->TA0_DTVENC) .And. TA0->TA0_DTVENC < dDataBase-3 .And. TA0->TA0_DTVENC >= dDataBase-5
			aLeg[4] += 1
		ElseIf !Empty(TA0->TA0_DTVENC) .And. TA0->TA0_DTVENC < dDataBase-5 .And. TA0->TA0_DTVENC >= dDataBase-7
			aLeg[5] += 1
		ElseIf !Empty(TA0->TA0_DTVENC) .And. TA0->TA0_DTVENC < dDataBase-7 .And. TA0->TA0_DTVENC >= dDataBase-14
			aLeg[6] += 1
		ElseIf !Empty(TA0->TA0_DTVENC) .And. TA0->TA0_DTVENC < dDataBase-14 .And. TA0->TA0_DTVENC >= dDataBase-15
			aLeg[7] += 1
		EndIf

		dbSelectArea("TA0")
		dbSkip()
	End

#ENDIF

If lQuery
	While (cAliasTrb)->( !Eof() )
		aLeg[1] := (cAliasTrb)->nLeg1
		aLeg[2] := (cAliasTrb)->nLeg2
		aLeg[3] := (cAliasTrb)->nLeg3
		aLeg[4] := (cAliasTrb)->nLeg4
		aLeg[5] := (cAliasTrb)->nLeg5
		aLeg[6] := (cAliasTrb)->nLeg6
		aLeg[7] := (cAliasTrb)->nLeg7
		DbSkip()
	End

	dbSelectArea(cAliasTrb)
	dbCloseArea()

	dbSelectArea("TA0")
	dbSetOrder(1)
EndIf

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Preenche array do Painel de Gestao                                      ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
aAdd( aRetPanel, {"Demandas em dia:", Transform(aLeg[1],"@E 999,999"), CLR_HRED, ,/*bClick*/ } )
aAdd( aRetPanel, {"Atrasadas em 1 dia:", Transform(aLeg[2],"@E 999,999"), CLR_HRED, ,/*bClick*/ } )
aAdd( aRetPanel, {"Atrasadas entre 2 e 3 dias:", Transform(aLeg[3],"@E 999,999"), CLR_HRED, ,/*bClick*/ } )
aAdd( aRetPanel, {"Atrasadas entre 4 e 5 dias:", Transform(aLeg[4],"@E 999,999"), CLR_HRED, ,/*bClick*/ } )
aAdd( aRetPanel, {"Atrasadas entre 6 e 7 dias:", Transform(aLeg[5],"@E 999,999"), CLR_HRED, ,/*bClick*/ } )
aAdd( aRetPanel, {"Atrasadas entre 8 e 14 dias:", Transform(aLeg[6],"@E 999,999"), CLR_HRED, ,/*bClick*/ } )
aAdd( aRetPanel, {"Atrasadas em mais de 15 dias", Transform(aLeg[7],"@E 999,999"), CLR_HRED, ,/*bClick*/ } )

Return aRetPanel