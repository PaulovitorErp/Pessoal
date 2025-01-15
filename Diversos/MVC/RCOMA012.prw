#Include 'Protheus.ch'
#INCLUDE "TOPCONN.CH" 

/*/{Protheus.doc} RWSFAT04

Web Service para integração Protheus x SGAC
Processamento do metodo CONSULTA_CONTRATO

@author TOTVS
@since 17/02/2017
@version P12
@param Nao recebe parametros
@return nulo
/*/
User Function RCOMA012(oEnv, oRet)

	Local lOk 					:= .T.
	Local cMsgErr 				:= ""
	Local cMsgSuss 				:= ""
	Local nCount 				:= 0
	Local cEol 					:= chr(13)+chr(10)
	Local cQry1, cQry2, cQry3
	Local oNewAluno, oNewClausula, oNewCli
	
	if lOk
		
		cQry1 := " SELECT ZB2_FILIAL AS FILIAL,ZB2_RA AS RA,ZB2_NOME AS NOME, 									" +cEOL
		cQry1 += " ZB2_NASC AS DATANASC, 																		" +cEOL
		cQry1 += " ZB2_SITUAC AS SITUAC FROM " + RetSqlName("ZB2") + "   										" +cEOL
		cQry1 += " WHERE D_E_L_E_T_ <> '*' 																		" +cEOL
		
		if !empty(oEnv:cFil)
			
			cQry1 += " AND ZB2_FILIAL = '"+oEnv:cFil+"' " +cEOL
			
		endif
		
		if !empty(oEnv:cRa)
			
			cQry1 += " AND ZB2_RA = '"+oEnv:cRa+"' " +cEOL
			
		endif
		
		if !empty(oEnv:cNome)
			
			cQry1 += " AND ZB2_NOME LIKE '%"+oEnv:cNome+"%' " +cEOL
			
		endif
		
		if !empty(oEnv:cDtNasci)
			
			cQry1 += " AND ZB2_NASC = '"+sTod(oEnv:cDtNasci)+"' " +cEOL
			
		endif
		
		if !empty(oEnv:cSituac)
			
			cQry1 += " AND ZB2_SITUAC = '"+oEnv:cSituac+"' " +cEOL
			
		endif
		
		cQry1 := ChangeQuery(cQry1)
		
		If Select("QRYWS01") > 0
			QRYWS01->(DbCloseArea())
		EndIf
		
		TcQuery cQry1 New Alias "QRYWS01" // Cria uma nova area com o resultado do query
		
		QRYWS01->(dbGoTop())
		DbSelectArea("ZB2")
		While QRYWS01->(!Eof())
		
			// Cria e alimenta uma nova instancia do contrato
			oNewAluno :=  WSClassNew( "Aluno" )
							
			oNewAluno:cFil		:= QRYWS01->FILIAL
			oNewAluno:cRa		:= QRYWS01->RA
			oNewAluno:cNome		:= QRYWS01->NOME
			oNewAluno:cDtNasci	:= dToc(sTod(QRYWS01->DATANASC))
			oNewAluno:cSituac	:= QRYWS01->SITUAC 	
			
			AAdd( oRet:aAlunos, oNewAluno )
		
			QRYWS01->(DbSkip())
		enddo
			
		QRYWS01->(DbCloseArea())
			
	endif
	
Return()