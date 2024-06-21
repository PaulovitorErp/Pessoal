#INCLUDE "topconn.ch"
#INCLUDE "rwmake.ch"

/*
_____________________________________________________________________________
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦Programa  ¦ BRICNAB    ¦ Autor ¦ Andre Castilho      ¦ Data ¦ 23/11/20 ¦¦¦
¦¦+----------+------------------------------------------------------------¦¦¦
¦¦¦Descriçào ¦ GERA SEQUENCIAL REMESSA EXCLUSIVO FOLHA BRADESCO           ¦¦¦
¦¦+----------+------------------------------------------------------------¦¦¦
¦¦¦ Uso      ¦ CNAB BANCO DO BRADESCO (MULTIPAG) - FOLHA DE PAGAMENTO     ¦¦¦
¦¦+----------+------------------------------------------------------------¦¦¦
¦¦¦ Revisado ¦ Por:           	                        ¦ Data ¦          ¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯
*/
User Function BRICNAB()


	Public c_Ret := getmv("MV_XSEQREM")
	c_Ret :=StrZero(c_Ret+1,6)

	PutMv("MV_XSEQREM", c_Ret)

	DbSelectArea("SEE")
	SEE->(DbSetOrder(1))
    If SEE->(DbSeek(xFilial("SEE")+"237"))
//	If SEE->(DbSeek(xFilial(("SEE")+("237")+("01283")+("6500      ")+("001"))))
		RecLock("SEE", .F.)
		SEE->EE_ULTDSK :=Alltrim(c_Ret)
		SEE->(MsUnLock()) // Confirma e finaliza a operação

	EndIf

//MsgAlert('Cnab Bradesco Gerado! Numero Sequencial:'+ c_Ret)

Return(c_Ret)
