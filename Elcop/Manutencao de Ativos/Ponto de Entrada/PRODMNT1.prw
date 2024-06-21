//----------------------------------------------------------------------------
/*/{Protheus.doc} PRODMNT1
Ponto de Entrada que permite alterar o insumo do tipo terceiro previsto na ordem de serviço corretiva 
antes da geração da solicitação de compras ou Documento de Entrada relacionada.
Necessário esta alteração para que na consulta do Custo do Período esta Nota Fiscal de Serviço tenha
seu produto de serviço no Item Terceiros   
Este Ponto de Entrada foi restrito ao MATA103 - Documento de Entrada
 
@type function

@author Sinval 
@since 01/05/2020

@sample PRODMNT1(aprodutos)

@param aProdutos := PARAMIXB[1]
@return aProdutos
/*/
//----------------------------------------------------------------------------

#Include 'PROTHEUS.ch'
 
User Function PRODMNT1()
 
Local aProdutos := PARAMIXB[1]
Local nX
 
if funName() = "MATA103"
	if !Empty(SD1->D1_ORDEM) .and. SD1->D1_TP $ "MO-SV"
 		if !Empty(aProdutos) .And. alltrim(aProdutos[1]) == "TERCEIROS"
   			For nX := 1 To Len(aProdutos)
      			aProdutos[nX] := SD1->D1_COD
         	Next nX
      	EndIf
	EndIf
endif 
Return aProdutos
