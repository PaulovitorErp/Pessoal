//----------------------------------------------------------------------------
/*/{Protheus.doc} MT103FIM
	Ponto de Entrada Utilizado para Inclus�o do Insumo na Tabela 
 	TPY - Manuten��o de Ativos - Cadastro do Bem
 
@type function

@author Sinval 
@since 01/05/2020

@sample MT103FIM(nOpcao, nConfirma)

@param nOpcao  			:= PARAMIXB[1]   // Op��o Escolhida pelo usuario no aRotina 
@param Local nConfirma 	:= PARAMIXB[2]   // Se o usuario confirmou a opera��o de grava��o da NFECODIGO DE APLICA��O DO USUARIO
@return .T.
/*/
//----------------------------------------------------------------------------

#include "Protheus.ch"
#include "RwMake.ch"

User Function MT103FIM() 
	Local nOpcao 	:= PARAMIXB[1]   // Op��o Escolhida pelo usuario no aRotina 
	Local nConfirma := PARAMIXB[2]   // Se o usuario confirmou a opera��o de grava��o da NFECODIGO DE APLICA��O DO USUARIO        
	Local aAreaSA2  := SA2->(GetArea())
	_
	Local aAreaSF1  := SF1->(GetArea())
	Local aAreaSB1  := SB1->(GetArea())
	Local aAreaCDD  := CDD->(GetArea())
	Local aAreaCDT  := CDT->(GetArea())
	Local aAreaSF2  := SF2->(GetArea())
	Local aAreaSD2  := SD2->(GetArea())
	Local aAreaSF4  := SF4->(GetArea())
	Local aAreaSE2  := SE2->(GetArea())
	Local _aAreas 	:= getArea()  
	Local _cQuery 	:= ""

	if nConfirma = 1 
		if nOpcao = 3 
			SD1->(DbSetOrder(1))
			if SD1->(DbSeek(SF1->(F1_FILIAL+F1_DOC+F1_SERIE+F1_FORNECE+F1_LOJA))) 
				do while SD1->(!Eof()) .and. SD1->(D1_FILIAL+D1_DOC+D1_SERIE+D1_FORNECE+D1_LOJA) = SF1->(F1_FILIAL+F1_DOC+F1_SERIE+F1_FORNECE+F1_LOJA)
					if !Empty(alltrim(SD1->D1_OP)) .and. !Empty(alltrim(SD1->D1_ORDEM))
						
						Dbselectarea("STJ")
						STJ->(DbSetOrder(1))
						if STJ->(DbSeek(xFilial("STJ")+SD1->D1_ORDEM))     
						
							SB1->(DbSetOrder(1))
							SB1->(DbSeek(xFilial("SB1")+SD1->D1_COD))

							if !Empty(SD1->D1_ORDEM) .and. SD1->D1_TP $ "PV"
								TPY->(DbSetorder(1))
								if !TPY->(DbSeek(xFilial("TPY")+STJ->TJ_CODBEM+SD1->D1_COD))
									TPY->(reclock("TPY",.T.))
									TPY->TPY_FILIAL := xFilial("TPY")
									TPY->TPY_CODBEM := STJ->TJ_CODBEM
									TPY->TPY_CODPRO := SD1->D1_COD
									TPY->TPY_QUANTI := SD1->D1_QUANT
									TPY->TPY_CRITIC	:= "M"
									TPY->TPY_QTDGAR := if(SB1->B1_XTMPGAR = 0, 1, SB1->B1_XTMPGAR)
									TPY->TPY_UNIGAR	:= "M"
									TPY->TPY_CONGAR := ""
									TPY->TPY_QTDCON := 0 
									TPY->TPY_LOCGAR := ""
									TPY->TPY_ALTER  := "2"  
									TPY->TPY_XCHAVE := SD1->(D1_DOC+D1_SERIE+D1_FORNECE+D1_LOJA)
									TPY->(msUnLock())					
								endif
							endif
							
							//Variaveis para Baixar STJ
							//Criado para Baixar OS Apos Entrada do DOc Entrada
	

							RecLock("STJ",.F.)
							STJ->TJ_DTMRINI := ddatabase
							STJ->TJ_HOMRINI := time()
							STJ->TJ_DTMRFIM := ddatabase
							STJ->TJ_HOMRFIM := time()
							STJ->TJ_TERMINO := "S"
							//STJ->TJ_DTPRINI := If(Empty(dDTMRINI),STJ->tj_dtmpini,dDTMRINI)
							//STJ->TJ_HOPRINI := If(Empty(cHOMRINI) .Or. Alltrim(cHOMRINI) = ':',STJ->tj_hompini,cHOMRINI)
							//STJ->TJ_DTPRFIM := If(Empty(dDTMRFIM),STJ->tj_dtmpfim,dDTMRFIM)
							//STJ->TJ_HOPRFIM := If(Empty(cHOMRFIM) .Or. Alltrim(cHOMRFIM) = ':',STJ->tj_hompfim,cHOMRFIM)
							//	STJ->TJ_MOEDA := "1"
							STJ->TJ_CUSTMDO := 0
							STJ->TJ_CUSTMAT := 0
							STJ->TJ_CUSTMAA := 0
							STJ->TJ_CUSTMAS := 0
							STJ->TJ_CUSTTER := 0						
							MsUnLock("STJ")	

						EndIf

					endif		
					SD1->(DbSkip())			
				enddo
			endif
		elseif nOpcao = 5

				if select("D1OP") > 0 
					D1OP->(DbCloseArea())
				endif
				
				_cQuery =  " SELECT D1_OP, D1_ORDEM"
				_cQuery += " FROM "
				_cQuery += RetSqlName("SD1") + " SD1 "
				_cQuery += " WHERE SD1.D_E_L_E_T_ = '*' "
				_cQuery += " AND SD1.D1_FILIAL = '" + SF1->F1_FILIAL + "'"
				_cQuery += " AND SD1.D1_DOC = '" + SF1->F1_DOC + "'"
				_cQuery += " AND SD1.D1_SERIE = '" + SF1->F1_SERIE + "'"
				_cQuery += " AND SD1.D1_FORNECE = '"+SF1->F1_FORNECE+"' "
				_cQuery += " AND SD1.D1_LOJA = '"+SF1->F1_LOJA+"' "
				_cQuery := ChangeQuery (_cQuery)
				dbUseArea(.T.,"TOPCONN",TCGenQry(,,ALLTRIM(Upper(_cQuery))),'D1OP',.F.,.T.)

				D1OP->(dbGoTop())                                     
				do while D1OP->(!EOF())
					if !Empty(D1OP->D1_OP)   
					
						STJ->(DbSetOrder(1))
						STJ->(DbSeek(xFilial("STJ")+D1OP->D1_ORDEM))
						
						SC2->(DbSetOrder(1))
						if SC2->(DbSeek(xFilial("SC2")+D1OP->D1_OP))		
							SC2->(recLock("SC2",.F.))
							SC2->C2_DATRF := STJ->TJ_DTMPFIM
							SC2->(msUnLock())
						endif
					endif	           	
					D1OP->(dbSkip())
				enddo
				
				D1OP->(dbCloseArea())
		endif
	endif

	//Complemento Gravacao SA2 - Regra Nota Fornecedor
	//Retirado porque e somente no momento que ter NF Entrada
	/*
	IF (nOpcao == 3 .OR. nOpcao == 4)  .AND. nConfirma == 1  

			_DtReceb := U_TelaReceb() 

			DbSelectArea("SD1")
			SD1->(dbSetOrder(1))
			if SD1->(dbSeek(xFilial("SD1")+SF1->F1_DOC+SF1->F1_SERIE+SF1->F1_FORNECE+SF1->F1_LOJA))
				While SD1->(!Eof() .AND. D1_FILIAL+D1_DOC+D1_SERIE+D1_FORNECE+D1_LOJA == xFilial('SD1')+SF1->(F1_DOC+F1_SERIE+F1_FORNECE+F1_LOJA))
					DbSelectArea("SC7") 
					SC7->(dbSetOrder(1))
					If SC7->(MsSeek(xFilial("SC7")+SD1->(D1_PEDIDO+D1_ITEMPC)))
						DbSelectArea("SA2")
						SA2->( dbSetOrder(1))
						If SA2->(Dbseek(xFilial("SA2")+SF1->F1_FORNECE+SF1->F1_LOJA))
							//Qual o nome do campo da SC7 para comparar ?
							//Qual a logica se a data de recebimento for mairo que o datprf  se for maior, grava 0 no SA2, caso contrario grava 100 ? 

								IF _DtReceb > SC7->C7_DATAPRF //Se a data do Recebimento for Maior que o SC7->C7_DATAPRF 
								//qual o campo nota na sa2 peri A2_XNOTLIC
									RecLock( "SA2" , .F. )
										SA2->A2_XNOTLIC := 0
									MsUnLock()	
								Else
									RecLock( "SA2" , .F. )
										SA2->A2_XNOTLIC := 100
									MsUnLock()									
								EndiF
								//Pronto coloca o debug e faz uma nf entrada para validar
						EndIf
					EndIf
				SD1->(DbSkip())			
				enddo
			EndIf	
	EndIf
	*/

	restArea(_aAreas)
	RestArea(aAreaSA2)
	RestArea(aAreaSD1)
	RestArea(aAreaSF1)
	RestArea(aAreaSB1)
	RestArea(aAreaCDD)
	RestArea(aAreaCDT)
	RestArea(aAreaSF2)
	RestArea(aAreaSD2)
	RestArea(aAreaSF4)
	RestArea(aAreaSE2)

Return (NIL)

