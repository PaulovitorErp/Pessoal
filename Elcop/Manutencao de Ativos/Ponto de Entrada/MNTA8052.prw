/*
Ao clicar em Documento, na rotina de Cadastros de Documentos Obrigatórios por Veículo, 
o ponto de entrada é chamado e realiza a alteração da busca dos documentos padrões, 
feita até então pelo ano do modelo. 
A partir desta alteração, passará a ser feiat através do ano de fabricação
*/

User Function MNTA8052() 
cAnoST9 := "ST9->T9_ANOFAB"
Return(.T.)