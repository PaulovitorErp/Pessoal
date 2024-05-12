#include "rwmake.ch"  
#Include "SigaWin.ch"

/*
__________________________________________________________________________
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦Programa  ¦ CTBVAL   ¦ Utilizador ¦ Claudio Ferreira  ¦ Data ¦ 04/06/12¦¦¦
¦¦+----------+------------------------------------------------------------¦¦¦
¦¦¦Descriçào ¦ Rotinas de Validação Contábil                              ¦¦¦
¦¦¦          ¦                                                            ¦¦¦
¦¦¦          ¦ 															  ¦¦¦
¦¦+----------+------------------------------------------------------------¦¦¦
¦¦¦ Uso      ¦ TOTVS-GO                                                   ¦¦¦    
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯
*/

/*
__________________________________________________________________________
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦Programa  ¦ ValCCNF  ¦ Utilizador ¦ Claudio Ferreira  ¦ Data ¦ 04/06/12¦¦¦
¦¦+----------+------------------------------------------------------------¦¦¦
¦¦¦Descriçào ¦ Valida digitação do C.Custo no Doc de Entrada              ¦¦¦
¦¦¦          ¦                                                            ¦¦¦
¦¦¦          ¦ Utilizado no PE MT100TOK                          		  ¦¦¦
¦¦+----------+------------------------------------------------------------¦¦¦
¦¦¦ Uso      ¦ TOTVS-GO                                                   ¦¦¦    
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯
*/

User Function ValCCNF(aCols,aBackColsSDE)
Local lOk:=.t. 
Local i,ii
Local nPosTES  := GDFieldPos("D1_TES")
Local nPosCC   := GDFieldPos("D1_CC")
Local lValSDE   :=.f.

if Len(aBackColsSDE)>0
  For i:=1 to Len(aBackColsSDE) 
    if Posicione('SF4',1,xFilial('SF4')+aCols[i][nPosTES],'F4_ESTOQUE')='N' .and. Posicione('SF4',1,xFilial('SF4')+aCols[i][nPosTES],'F4_DUPLIC')='S' .and. Posicione('SF4',1,xFilial('SF4')+aCols[i][nPosTES],'F4_ATUATF')<>'S'
      For ii:=1 to Len(aBackColsSDE[i][2]) 
       if empty(aBackColsSDE[i][2][ii][3])//Centro de Custo 
         lOk:=.f.
       endif
       lValSDE   :=.t.
      Next ii 
    endif
  Next i
  if !lOk
    msgbox("Informe os Centros de Custo no Rateio")
  endif  
endif  
if lOk .and. !lValSDE
  For i:=1 to Len(aCols) 
    if !aCols[i,Len(aHeader) + 1] .and. Posicione('SF4',1,xFilial('SF4')+aCols[i][nPosTES],'F4_ESTOQUE')='N' .and. Posicione('SF4',1,xFilial('SF4')+aCols[i][nPosTES],'F4_DUPLIC')='S' .and. Posicione('SF4',1,xFilial('SF4')+aCols[i][nPosTES],'F4_ATUATF')<>'S'
      if empty(aCols[i][nPosCC])//Centro de Custo 
        lOk:=.f.
      endif
    endif  
  Next i
 
  if !lOk
    msgbox("Informe os Centros de Custo dos Itens ou Selecione um Rateio CC")
  endif  
endif

Return lOk

/*
__________________________________________________________________________
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦Programa  ¦ LPLSG    ¦ Utilizador ¦ Claudio Ferreira  ¦ Data ¦ 18/06/12¦¦¦
¦¦+----------+------------------------------------------------------------¦¦¦
¦¦¦Descriçào ¦ Retorna se o LP é ou não uma contabilização de Leasing/    ¦¦¦
¦¦¦          ¦ Financiamento                                              ¦¦¦
¦¦¦          ¦ Utilizado nos LP´s                                 		  ¦¦¦
¦¦+----------+------------------------------------------------------------¦¦¦
¦¦¦ Uso      ¦ TOTVS-GO                                                   ¦¦¦    
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯
*/

User Function LPLSG(nOpn)
Local lOk:=.f.
if     nOPn=1 //SE2
  lOk:=Alltrim(SE2->E2_NATUREZ)$(SuperGetMV("MV_XNATLSG",.F.,"")+'/'+SuperGetMV("MV_XNATFIN",.F.,""))
elseif nOPn=2 //SE5
  lOk:=(Alltrim(SE5->E5_NATUREZ)$(SuperGetMV("MV_XNATLSG",.F.,"")+'/'+SuperGetMV("MV_XNATFIN",.F.,""))) .AND. (!Alltrim(SE5->E5_NATUREZ)$(SuperGetMV("MV_XNATJUR",.F.,"")))
elseif nOPn=3 //SE5 - Juros e Encargos 
  lOk:=(Alltrim(SE5->E5_NATUREZ)$(SuperGetMV("MV_XNATLSG",.F.,"")+'/'+SuperGetMV("MV_XNATFIN",.F.,""))) .AND. (Alltrim(SE5->E5_NATUREZ)$(SuperGetMV("MV_XNATJUR",.F.,"")))
elseif nOPn=4 //SE5 - Principal+Juros e Encargos 
  lOk:=(Alltrim(SE5->E5_NATUREZ)$(SuperGetMV("MV_XNATLSG",.F.,"")+'/'+SuperGetMV("MV_XNATFIN",.F.,"")+'/'+SuperGetMV("MMV_XNATJUR",.F.,""))) 
endif
Return lOk
