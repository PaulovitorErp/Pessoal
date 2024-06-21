//----------------------------------------------------------------------------
/*/{Protheus.doc} A100DEL()
Ponto de Entrada tem os Seguintes Objetivos:
-> Excluir a NF com a OS Fechada, por padrão o sistema não permite
-> Será Limpo o conteúdo do campo SC2->C2_DATRF, assim o sistema não impedirá a exclusão da NF e os movimentos no D3
	do custo de entrada. Esta informação é a mesma do campo STL->TL_DTFIM
-> Será excluído caso necessário os itens do Bem - Peças de Reposição, visto que este item foi incluído no momento da digitação
	da NF, isso está sendo feito, para que as Peças possam te o controle de troca ou garantia. 
	Também não sendo necessário a inclusão manual - Tabela TPY
-> Será excluído também as Peças da Tabela STL, custo dos insumos gastos através da entrada de NFs. 
	Como a OS está fechada este item não é excluído automaticamente.
 
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