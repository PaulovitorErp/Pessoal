#INCLUDE "PROTHEUS.ch"
#INCLUDE "rwmake.ch"

User Function ECDCHVMOV()
               
Local cTpSald  := (cAliasCT2)->CT2_TPSALD
Local cChavet  := " "
Local cLote    := (cAliasCT2)->CT2_LOTE
Local cFilMov  := (cAliasCT2)->CT2_FILIAL
Local cSbLote  := (cAliasCT2)->CT2_SBLOTE
Local cCT2CCD  := (cAliasCT2)->CT2_CCD
Local cCT2CCC  := (cAliasCT2)->CT2_CCC

//If substr(cCT2CCD,1,5) == '09020' .OR. substr(cCT2CCC,1,5) == '09020'
	cChavet:= (cAliasCT2)->CT2_FILIAL + DTOS( (cAliasCT2)->CT2_DATA ) + (cAliasCT2)->CT2_LOTE + (cAliasCT2)->CT2_SBLOTE
//EndIf  

Return(cChavet)