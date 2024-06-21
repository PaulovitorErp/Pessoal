//----------------------------------------------------------------------------
/*/{Protheus.doc} MNTA1301
Ponto de entrada para validar e/ou personalizar a importação de abastecimentos, 
chamado ao final de todo o processo, ou seja, após os registros já terem sido gravados 
na tabela de Abastecimentos Importados (TR6).Reflete nas rotinas de Importação via Convênio 
CTF, TICKET, GOOD CARD e VALE CARD
Programa Fonte
MNTA130; MNTA631; MNTA986
 
@type function

@author Sinval 
@since 01/05/2020

@sample MNTA1301()

@param paramIXB[1] 
@return lRetorno
/*/
//----------------------------------------------------------------------------

#Include 'PROTHEUS.ch'

User Function MNTA1301()
/* ParamIXB	[1] - Importacoes		
[1]  - Filial		
[2]  - Numero do Abastecimento		
[3]  - Placa do Veiculo		
[4]  - Combustivel/Convenio		
[5]  - CPF do Motorista		
[6]  - Posicao do Contador	   
[7]  - Quantidade de Combustivel Abastecido		
[8]  - Valor Unitario do Combustivel	   
[9]  - Data do Abastecimento		
[10] - Hora do Abastecimento		
[11] - Posicao do Contador 2 (zerado se nao houver segundo contador - 0)
*/

//Local aImport := aClone(ParamIXB[1])


Return .T.
