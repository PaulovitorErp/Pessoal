#include "rwmake.ch"
#include "Topconn.ch"

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  � CT220EMP �Autor  �Claudio Ferreira    � Data �  21/09/12   ���
�������������������������������������������������������������������������͹��
���Desc.     � Ponto de entrada para filtrar filiais a serem consolidadas ���
���          � Uso Consolida��o Geral                                     ���
�������������������������������������������������������������������������͹��
���Uso       �  CTB                                                       ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/

User Function CT220EMP( )
Local aEmp:= Paramixb[1]
Local aNewEmp:= {}
Local cFiliais := SuperGetMv("MV_XCONSOL",.T.,"")
Local nTamFil:=Len(Alltrim(cFilAnt))

if !empty(cFiliais)
  FOR nI = 1 to len(aEmp)
    if aEmp[nI][2]+Substr(aEmp[nI][3],1,nTamFil)$cFiliais       
 	aadd(aNewEmp,aEmp[nI])
    endif	
  NEXT    
else
  aNewEmp:=aEmp
endif

Return aNewEmp
