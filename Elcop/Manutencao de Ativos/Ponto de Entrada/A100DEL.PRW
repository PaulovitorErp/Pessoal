//----------------------------------------------------------------------------
/*/{Protheus.doc} A100DEL()
Ponto de Entrada tem os Seguintes Objetivos:
-> Excluir a NF com a OS Fechada, por padr�o o sistema n�o permite
-> Ser� Limpo o conte�do do campo SC2->C2_DATRF, assim o sistema n�o impedir� a exclus�o da NF e os movimentos no D3
	do custo de entrada. Esta informa��o � a mesma do campo STL->TL_DTFIM
-> Ser� exclu�do caso necess�rio os itens do Bem - Pe�as de Reposi��o, visto que este item foi inclu�do no momento da digita��o
	da NF, isso est� sendo feito, para que as Pe�as possam te o controle de troca ou garantia. 
	Tamb�m n�o sendo necess�rio a inclus�o manual - Tabela TPY
-> Ser� exclu�do tamb�m as Pe�as da Tabela STL, custo dos insumos gastos atrav�s da entrada de NFs. 
	Como a OS est� fechada este item n�o � exclu�do automaticamente.
 
@type function

@author Sinval 
@since 01/05/2020

@sample A100DEL()

@param 
@param 
@return .T.
/*/
//----------------------------------------------------------------------------

/**************************************/
user function A100DEL()                  
/*************************************/
local lRet := .T.
local _aAreas := getArea()

SD1->(DbSetOrder(1))
if SD1->(Dbseek(xFilial("SD1")+SF1->(F1_DOC+F1_SERIE+F1_FORNECE+F1_LOJA)))
	do while SD1->(!Eof()) .and. SD1->(D1_FILIAL+D1_DOC+D1_SERIE+D1_FORNECE+D1_LOJA) = SF1->(F1_FILIAL+F1_DOC+F1_SERIE+F1_FORNECE+F1_LOJA)
		if !Empty(SD1->D1_OP)
			SC2->(DbSetOrder(1))
			if SC2->(DbSeek(xFilial("SC2")+SD1->D1_OP))		
			   SC2->(recLock("SC2",.F.))
			   SC2->C2_DATRF := CTOD("  /  /  ")
			   SC2->(msUnLock())
		    endif
		endif	                   
		
		if !Empty(alltrim(SD1->D1_OP)) .and. !Empty(alltrim(SD1->D1_ORDEM))
			STJ->(DbSetOrder(1))
			STJ->(DbSeek(xFilial("STJ")+SD1->D1_ORDEM))
				
			TPY->(DbSetOrder(1))	
			if TPY->(dbSeek(xFilial("TPY")+STJ->TJ_CODBEM+SD1->D1_COD))	
				do while TPY->(!Eof()) .and. TPY->(TPY_CODBEM+TPY_CODPRO) = STJ->TJ_CODBEM+SD1->D1_COD
					if TPY->TPY_XCHAVE = SD1->(D1_DOC+D1_SERIE+D1_FORNECE+D1_LOJA)                                    
						TPY->(reclock("TPY",.F.))
						TPY->(dbDelete())
						TPY->(msUnLock())					
					endif
					TPY->(DbSkip())
				enddo
			endif
			
			STL->(DbSetOrder(1))
			if STL->(DbSeek(xFilial("STL")+SD1->D1_ORDEM))   
			 	do while STL->(!Eof()) .and. STL->TL_ORDEM = SD1->D1_ORDEM
					if STL->(TL_NOTFIS+TL_SERIE+TL_FORNEC+TL_LOJA) = SD1->(D1_DOC+D1_SERIE+D1_FORNECE+D1_LOJA)                                    
						STL->(reclock("STL",.F.))
						STL->(dbDelete())
						STL->(msUnLock())					
					endif
					STL->(DbSkip())			 	
			 	enddo
			endif
        endif
		
		SD1->(DbSkip())	
	enddo
endif       
restArea(_aAreas)
return(lRet)