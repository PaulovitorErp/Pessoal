#INCLUDE "MNTP030.ch"
#INCLUDE "PROTHEUS.CH"

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³MNTP030   ³ Autor ³ Elisangela Costa      ³ Data ³ 05/03/2007 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³Monta array para Painel de Gestao Tipo 5: Distribuicao        ³±±
±±³          ³de Solicitacoes                                               ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³MNTP030()                                                     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³Array = { cClick, aCabec, aValores }                          ³±±
±±³          ³cClick   = Funcao p/ execucao do duplo-click no browse        ³±±
±±³          ³aCabec   = Array contendo o cabecalho                	       ³±±
±±³          ³aValores = Array contendo os valores da lista       		    ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³SIGAMDI                                                       ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function MNTP030() 

Local aArea      := GetArea()
Local aAreaTQB   := TQB->(GetArea())
Local aRetPanel  := {} 
Local aCabec     := {STR0001,STR0002,STR0003,STR0004} //"Funcionário"###"Nome"###"Para Atendimento"###"Em atraso + de 15 dias"
Local aAlign     := {"RIGHT","RIGHT","LEFT","LEFT"}
Private aValores := {}  

Pergunte("MNTP030",.F.)  

#IFDEF TOP

   BeginSql Alias "TRBTQB"
      Select TQB.TQB_CDEXEC,TQB.TQB_DTABER
	  From %table:TQB% TQB
	  Where TQB.TQB_FILIAL = %xFilial:TQB%                                     
	        And (TQB.TQB_CDEXEC >= %Exp:mv_par01% And TQB.TQB_CDEXEC <= %Exp:mv_par02%)
	        And (TQB.TQB_DTABER >= %Exp:mv_par03% And TQB.TQB_DTABER <= %Exp:mv_par04%)
		    And TQB.TQB_SOLUCA = "D" And TQB.%NotDel%						 
	  Order by TQB.TQB_CDEXEC
   EndSql
   
   dbSelectArea("TRBTQB")
   dbGotop()
   While !Eof() 
      MNTP30GAR(TRBTQB->TQB_CDEXEC,TRBTQB->TQB_DTABER)
      dbSelectArea("TRBTQB") 
      dbSkip()
   End  
   dbSelectArea("TRBTQB")
   dbCloseArea()
   
#ELSE  

    dbSelectArea("TQB")
    dbSetOrder(02)
    dbSeek(xFilial("TQB")+DTOS(MV_PAR03),.T.)
    While !Eof() .And. TQB->TQB_DTABER <= MV_PAR04
    
       If TQB->TQB_CDEXEC >= MV_PAR01 .And. TQB->TQB_CDEXEC <= MV_PAR02 .And.;
          TQB->TQB_SOLUCA = "D" 
          MNTP30GAR(TRBTQB->TQB_CDEXEC,TRBTQB->TQB_DTABER) 
       EndIf                                              
       dbSelectArea("TQB")
       dbSkip()
    End 
    dbSelectArea("TQB")
    dbSetOrder(01)
    
#ENDIF

If Len(aValores) = 0                     
   Aadd(aValores,{"","",0,0})
EndIf    

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Preenche array do Painel de Gestao                                      ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
aRetPanel := {/*cClick*/, aCabec, aValores, aAlign} 

RestArea(aAreaTQB)
RestArea(aArea) 

Return aRetPanel 

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³MNTP30GAR ³ Autor ³ Elisangela Costa      ³ Data ³05/03/2007³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³Grava valores na array                                      ³±± 
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³cCODEXECU => Codigo do executante                           ³±± 
±±³          ³dDATAABER => Data de abertura da SS                         ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³MNTP030                                                     ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/ 
Function MNTP30GAR(cCODEXECU,dDATAABER) 

Local nAtraso := 0

nPOSP030 := aSCAN(aValores, {|x| x[1] == cCODEXECU}) 
nATRASO  := dDataBase - STOD(dDATAABER)
      
If nPOSP030 > 0
   aValores[nPOSP030][3] += 1 
      
   If nATRASO > 14
      aValores[nPOSP030][4] += 1
   EndIf
Else
   Aadd(aValores,{cCODEXECU,NGSEEK("TQ4",cCODEXECU,1,"TQ4_NMEXEC"),1,;
        If(nATRASO > 14,1,0)} )
EndIf

Return .T.