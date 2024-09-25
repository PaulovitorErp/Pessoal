#INCLUDE "MNTP020.ch"
#INCLUDE "PROTHEUS.CH"

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³MNTP020   ³ Autor ³ Elisangela Costa      ³ Data ³ 05/03/2007 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³Monta array para Painel de Gestao Tipo 1: Solicitacoes        ³±±
±±³          ³Pendentes                                                     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³MNTP020()                                                     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³Array = {{cText1,cValor,nColorValor,bClick},...}              ³±±
±±³          ³cTexto1     = Texto da Coluna                       		    ³±±
±±³          ³cValor      = Valor a ser exibido (string)          		    ³±±
±±³          ³nColorValor = Cor do valor no formato RGB (opcional)          ³±±
±±³          ³bClick      = Funcao executada no click do valor (opcional)   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³SIGAMDI                                                       ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function MNTP020()

Local aArea         := GetArea()
Local aAreaTQB      := TQB->(GetArea())
Local aRetPanel     := {}
Local cMensagem1 := "", cMensagem2 := "", cMensagem3 := "", cMensagem4 := "", cMensagem5 := "",;
      cMensagem6 := "", cMensagem7 := ""
Private vVETP020IND := {0,0,0,0,0,0,0,0}

Pergunte("MNTP020",.F.)

#IFDEF TOP

   BeginSql Alias "TRBTQB"
      Select TQB.TQB_DTABER
	  From %table:TQB% TQB
	  Where TQB.TQB_FILIAL = %xFilial:TQB%
	        And (TQB.TQB_DTABER >= %Exp:mv_par01% And TQB.TQB_DTABER <= %Exp:mv_par02%)
		    And (TQB.TQB_SOLUCA = "A" Or TQB.TQB_SOLUCA = "D")
		    AND TQB.%NotDel%
	  Order by TQB.TQB_DTABER
   EndSql

   dbSelectArea("TRBTQB")
   dbGotop()
   While !Eof()
      MNTP20GAR(Stod(TRBTQB->TQB_DTABER))
      dbSkip()
   End

   dbSelectArea("TRBTQB")
   dbCloseArea()

#ELSE

    dbSelectArea("TQB")
    dbSetOrder(02)
    dbSeek(xFilial("TQB")+DTOS(MV_PAR01),.T.)
    While !Eof() .And. TQB->TQB_DTABER <= MV_PAR02
       If TQB->TQB_SOLUCA = "A" .Or. TQB->TQB_SOLUCA = "D"
          MNTP20GAR(TQB->TQB_DTABER)
       EndIf
       dbSkip()
    End
    dbSelectArea("TQB")
    dbSetOrder(01)

#ENDIF

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Monta mensagens apresentadas ao clicar nas quantidade                   ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
cMensagem1 := STR0003 //"Quantidade de SS que estão em dia."
cMensagem2 := STR0004 //"Quantidade de SS que estão atrasadas em 1 dia."
cMensagem3 := STR0005 //"Quantidade de SS que estão atrasadas entre 2 e 3 dias."
cMensagem4 := STR0006 //"Quantidade de SS que estão atrasadas entre 4 e 5 dias."
cMensagem5 := STR0007 //"Quantidade de SS que estão atrasadas entre 6 e 7 dias."
cMensagem6 := STR0008 //"Quantidade de SS que estão atrasadas entre 8 e 14 dias."
cMensagem7 := STR0009 //"Quantidade de SS que estão atrasadas mais que 15 dias."

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Preenche array do Painel de Gestao                                      ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
Aadd(aRetPanel,{STR0010, Transform(vVETP020IND[1],"99999"),CLR_BLUE,{ || MsgInfo(cMensagem1)}} ) //"Em dia"
Aadd(aRetPanel,{STR0011, Transform(vVETP020IND[2],"99999"),CLR_BLUE,{ || MsgInfo(cMensagem2)}} ) //"Atrasada em 1 dia"
Aadd(aRetPanel,{STR0012, Transform(vVETP020IND[3],"99999"),CLR_BLUE,{ || MsgInfo(cMensagem3)}} ) //"Atrasada entre 2 e 3 dias"
Aadd(aRetPanel,{STR0013, Transform(vVETP020IND[4],"99999"),CLR_BLUE,{ || MsgInfo(cMensagem4)}} ) //"Atrasada entre 4 e 5 dias"
Aadd(aRetPanel,{STR0014, Transform(vVETP020IND[5],"99999"),CLR_BLUE,{ || MsgInfo(cMensagem5)}} ) //"Atrasada entre 6 e 7 dias"
Aadd(aRetPanel,{STR0015, Transform(vVETP020IND[6],"99999"),CLR_BLUE,{ || MsgInfo(cMensagem6)}} ) //"Atrasada entre 8 e 14 dias"
Aadd(aRetPanel,{STR0016, Transform(vVETP020IND[7],"99999"),CLR_BLUE,{ || MsgInfo(cMensagem7)}} ) //"Atrasada mais que 15 dias"

RestArea(aAreaTQB)
RestArea(aArea)

Return aRetPanel

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³MNTP20GAR ³ Autor ³ Elisangela Costa      ³ Data ³05/03/2007³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³Grava valores na array                                      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³dDATAABER => Data de abertura da SS                         ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³MNTP020                                                     ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function MNTP20GAR(dDATAABER)

Local nAtraso := 0

nATRASO := dDataBase - dDATAABER

If nATRASO <= 0
   vVETP020IND[1] += 1
ElseIf nATRASO > 0 .And. nATRASO <= 1
   vVETP020IND[2] += 1
ElseIf nATRASO > 1 .And. nATRASO <= 3
   vVETP020IND[3] += 1
ElseIf nATRASO > 3 .And. nATRASO <= 5
   vVETP020IND[4] += 1
ElseIf nATRASO > 5 .And. nATRASO <= 7
   vVETP020IND[5] += 1
ElseIf nATRASO > 7 .And. nATRASO <= 14
   vVETP020IND[6] += 1
ElseIf nATRASO > 14
   vVETP020IND[7] += 1
EndIf

Return .T.