/* Ponto de Entrada que Permite Exclusão do Documento de Entrada com o Número da OS Vinculado

Localizada na função de validação da exclusão de uma nota fiscal de entrada, 
este ponto de entrada tem por objetivo permitir ou não a validação 
se a notas fiscal de entrada possui Ordem de Produção vinculados.
*/

User Function M103APO()
Local ExpL1 := .T.// Validações do usuário

Return(ExpL1)         

