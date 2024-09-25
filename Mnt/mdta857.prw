#INCLUDE "PROTHEUS.CH"

#DEFINE _nVERSAO 1 //Versao do fonte

//---------------------------------------------------------------------
/*/{Protheus.doc} MDTA857
Programa para Aprovacao de Multiplas Avaliacoes de Aspectos e Impactos Ambientais.

@author Hugo R. Pereira
@since 19/10/2012
@version MP10
@return Nil
/*/
//---------------------------------------------------------------------
Function MDTA857()
	
	Local aNGBEGINPRM := NGBEGINPRM( _nVERSAO ) // Armazena variaveis p/ devolucao [NGRIGHTCLICK]
	
	If !ChkOHSAS()
		//-----------------------------------------------------
		// Devolve variaveis armazenadas (NGRIGHTCLICK)
		//-----------------------------------------------------
		NGRETURNPRM( aNGBEGINPRM )
		Return .F.
	EndIf
	
	MDTA856( .T. ) // Efetua chamada de Avaliacoes em Lote, repassando parametro como 'Aprovação'
	
	NGRETURNPRM( aNGBEGINPRM ) // Devolve variaveis armazenadas [NGRIGHTCLICK]
	
Return .T.