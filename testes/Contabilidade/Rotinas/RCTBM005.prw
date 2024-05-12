#INCLUDE "rwmake.ch"

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³ RCTBM005 º Autor ³ Claudio Ferreira   º Data ³  23/10/12   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDescricao ³ Programa que refaz a tabela CTH - Classe Valor , percorre aº±±
±±º          ³ filiais incluindo as mesmas.                               º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ TOTVS-GO                                                   º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/

User Function RCTBM005()
Local cQry 		:= ''

if msgyesno("Confirma o Reprocessamento das Classes  de valor?")
  cQry := "DELETE FROM "+RetSqlName("CTH")+ " Where CTH_BOOK  = 'AUTO' "
  TCSqlExec(cQry)
  TCSqlExec("commit")
  Processa({|| RunItem() },"Processando Classe de Valor...")
endif  
Return()

Static Function RunItem() 
Local _sAlias	:=	Alias()
// Busca as filiais
dbSelectArea("SM0")
nFRecno:=Recno()
dbSeek(cEmpant,.T.)
While SM0->(!Eof()) .and. SM0->M0_CODIGO == cEmpAnt

	If !CTH->(dbSeek(xFilial('CTH')+SM0->M0_CODFIL))
		dbSelectArea("CTH")
		If RecLock("CTH",.T.)
			CTH->CTH_FILIAL := xFilial("CTH")
			CTH->CTH_CLVL   := SM0->M0_CODFIL
			CTH->CTH_DESC01 := SM0->M0_FILIAL
			CTH->CTH_CLASSE := "2"
			CTH->CTH_NORMAL := "2"
			CTH->CTH_BLOQ   := "2"
			CTH->CTH_DTEXIS := CtoD("01/01/2010")
			CTH->CTH_CLVLLP := CTH->CTH_CLVL
			CTH->CTH_BOOK   := "AUTO"
			MsUnlock("CTH")
		EndIf
	EndIf 
	
	dbSelectArea("SM0")
	DbSkip()
enddo
dbSelectArea("SM0")
dbGoTo( nFRecno )
dbSelectArea(_sAlias)
Return