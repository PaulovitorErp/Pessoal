#INCLUDE "PROTHEUS.CH"

#DEFINE _nVERSAO 02

//---------------------------------------------------------------------
/*/{Protheus.doc} SGAA112
Programa para Aprovacao de Multiplas Avaliacoes de Aspectos e Impactos Ambientais.

@author Hugo R. Pereira
@since 19/10/2012
@version MP10
@return Nil
/*/
//---------------------------------------------------------------------
Function SGAA112(aFiltroAsp)
	
	Local aNGBEGINPRM := NGBEGINPRM(_nVERSAO) // Armazena variaveis p/ devolucao [NGRIGHTCLICK]
	Local aReturn := {}
	
	Default aFiltroAsp := Nil
	
	aReturn := SGAA111(.T.,aFiltroAsp) // Efetua chamada de Avaliacoes em Lote, repassando parametro como 'Aprovação'

	NGRETURNPRM(aNGBEGINPRM) // Devolve variaveis armazenadas [NGRIGHTCLICK]

Return aReturn