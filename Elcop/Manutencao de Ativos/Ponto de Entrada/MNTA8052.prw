/*
Ao clicar em Documento, na rotina de Cadastros de Documentos Obrigat�rios por Ve�culo, 
o ponto de entrada � chamado e realiza a altera��o da busca dos documentos padr�es, 
feita at� ent�o pelo ano do modelo. 
A partir desta altera��o, passar� a ser feiat atrav�s do ano de fabrica��o
*/

User Function MNTA8052() 
cAnoST9 := "ST9->T9_ANOFAB"
Return(.T.)