#INCLUDE 'TOTVS.CH'

/*
========================================================================================================================
Programa--------------: fata600x
Autor-----------------: Erivaldo Oliveira 
Data da Criação-------: 16/04/2020
========================================================================================================================
Descricao-------------: Valida preenchimento do campo Novo / usado, na proposta comericlal. 
========================================================================================================================						   
Uso-------------------: CRM
========================================================================================================================
Parametros------------: Nenhum
========================================================================================================================
Retorno---------------: T ou F
========================================================================================================================
*/

User Function fata600()
Local cIdPonto		:= Paramixb[2]
Local oModel		:= fwmodelactive() 
Local nQtGrid	
Local oGrid		
Local nfaz
Local cNovUsado 	
Local lretorno	:= .t.

If cIdPonto == 'MODELPOS' .and. (oModel:GetOperation() == 3 .or. oModel:GetOperation() == 4)
	
	oGrid		:= oModel:GetModel('ADZPRODUTO')	
	nQtGrid		:= oGrid:LENGTH()					 
	
	for nfaz := 1 to nQtGrid
	
		cNovUsado := oGrid:GetValue("ADZ_XNOVO",nfaz)	
		
		If empty(cNovUsado)
			MsgStop("Informe o conteudo do campo, novo ou usado, "+cvaltochar(nfaz)+'ª linha.','CAMPO NÃO PREENCHIDO')
			lretorno	:= .f.
			return(lretorno)
		Endif
	
	next nfaz
	
Endif

Return(lRetorno)