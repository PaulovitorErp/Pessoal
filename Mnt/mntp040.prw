#INCLUDE "MNTP040.ch"
#INCLUDE "PROTHEUS.CH"

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³MNTP040   ³ Autor ³ Elisangela Costa      ³ Data ³ 05/03/2007 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³Monta array para Painel de Gestao Tipo 1: Ordens de Abertas/  ³±±
±±³          ³Liberadas                                                     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³MNTP040()                                                     ³±±
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
Function MNTP040()

Local aArea         := GetArea()
Local aAreaSTJ      := STJ->(GetArea())
Local aRetPanel     := {}
Local cMensagem1 := "", cMensagem2 := ""
Private vVETP040IND := {0,0}

Pergunte("MNTP040",.F.)

#IFDEF TOP

   BeginSql Alias "TRBSTJ"
      Select STJ.TJ_DTMPFIM
      	  From %table:STJ% STJ
	      Where STJ.TJ_FILIAL = %xFilial:STJ%
	         And (STJ.TJ_DTMPINI >= %Exp:mv_par01% And STJ.TJ_DTMPINI <= %Exp:mv_par02%)
		     And (STJ.TJ_SITUACA = "L" And STJ.TJ_TERMINO = "N")
		     And STJ.%NotDel%
	  Order by STJ.TJ_DTMPFIM
   EndSql

   dbSelectArea("TRBSTJ")
   dbGotop()
   While !Eof()
      MNTP40GAR(Stod(TRBSTJ->TJ_DTMPFIM))
      dbSkip()
   End
   dbSelectArea("TRBSTJ")
   dbCloseArea()

#ELSE

    dbSelectArea("STJ")
    dbSetOrder(08)
    dbSeek(xFilial("STJ")+DTOS(MV_PAR01),.T.)
    While !Eof() .And. STJ->TJ_DTMPINI <= MV_PAR02
       If STJ->TJ_SITUACA = "L" .And. STJ->TJ_TERMINO = "S"
          MNTP40GAR(STJ->TJ_DTMPINI)
       EndIf
       dbSkip()
    End
    dbSelectArea("STJ")
    dbSetOrder(01)

#ENDIF

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Monta mensagens apresentadas ao clicar nas medias                       ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
cMensagem1 := STR0003+chr(13)+chr(10) //"Quantidade de ordens de serviço com situação"
cMensagem1 += STR0004+chr(13)+chr(10) //"de liberadas/não conluídas que estão em atraso,"
cMensagem1 += STR0005 //"no período selecionado no parâmetro."

cMensagem2 := STR0003+chr(13)+chr(10) //"Quantidade de ordens de serviço com situação"
cMensagem2 += STR0006+chr(13)+chr(10) //"de liberadas/não conluídas que estão em dia,"
cMensagem2 += STR0005 //"no período selecionado no parâmetro."

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Preenche array do Painel de Gestao                                      ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
Aadd(aRetPanel,{STR0007, Transform(vVETP040IND[1],"99999"),CLR_BLUE,{ || MsgInfo(cMensagem1)}} ) //"Abertas/Liber. em Atraso"
Aadd(aRetPanel,{STR0008, Transform(vVETP040IND[2],"99999"),CLR_BLUE,{ || MsgInfo(cMensagem2)}} ) //"Abertas/Liberadas em Dia"

RestArea(aAreaSTJ)
RestArea(aArea)

Return aRetPanel

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³MNTP40GAR ³ Autor ³ Elisangela Costa      ³ Data ³06/03/2007³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³Grava valores na array                                      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³dDATMPFIM => Data de manutencao prevista fim                ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³MNTP040                                                     ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function MNTP40GAR(dDATMPFIM)

If dDATMPFIM < dDataBase
   vVETP040IND[1] += 1
Else
   vVETP040IND[2] += 1
EndIf

Return .T.