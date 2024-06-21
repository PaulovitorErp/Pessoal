#include "rwmake.ch"
#include "topconn.ch"
#include "tbiconn.ch"
#include "protheus.ch"
#INCLUDE "COLORS.CH"
#INCLUDE "FONT.CH"

//--------------------------------------------------------------
/*/{Protheus.doc} MyFunction
Description                                                     

@param xParam Parameter Description                             
@return xRet Return Description                                 
@author teste - teste@hotmail.com                                              
@since 17/09/2019                                                   
/*/                                                             
//--------------------------------------------------------------

User Function IMPcoSE4()                        
	Local oButton1
	Local oButton2
	Local oGroup1
	Local oSay1
	Static oDlg

	DEFINE MSDIALOG oDlg TITLE "Importar Planilha CSV" FROM 000, 000  TO 300, 600 COLORS 0, 16777215 PIXEL

	@ 002, 004 GROUP oGroup1 TO 125, 294 PROMPT "Importar Prazo Medio  " OF oDlg COLOR 0, 16777215 PIXEL
	@ 019, 015 SAY oSay1 PROMPT "Clique para Selecionar a Planilha para Importar o Arquivo para Importar Prazo Medio ." SIZE 241, 030 OF oDlg COLORS 0, 16777215 PIXEL

	@ 054, 013 BUTTON oButton1 PROMPT "Importar Arquivo CSV" SIZE 266, 027 OF oDlg PIXEL	Action( OkLeTxt() )
	@ 129, 242 BUTTON oButton2 PROMPT "Fechar" SIZE 052, 014 OF oDlg PIXEL	Action( oDlg:End() )

	ACTIVATE MSDIALOG oDlg CENTERED

Return()

Static Function OkLeTxt()
	Local cArqTxt := cGetFile( '*.TXT' , 'Arquivo de importação', 1, "", .T., GETF_LOCALHARD,.T.,.T.)
	Private nHandle := FT_FUse(cArqTxt)  
	if nHandle == -1  
		MsgAlert("O arquivo "+cArqTxt+" nao pode ser aberto! Verifique os parametros.","Atenção!")
		Return
	Endif 

	Private _cArqTxt := cArqTxt

	Processa({|| RunCont() },"Processando...")

Return()

Static Function RunCont()
	nTamFile := FT_FLastRec()

	ProcRegua(nTamFile) 	// Numero de registros a processar
	FT_FGoTop()				// Posiciona na primeira linha do arquivo texto de impotação
	SX3->(DbSetOrder(2))
	aCab  := STRTOKARR(FT_FReadLn(),";")

	FT_FSKIP()
	While !FT_FEOF()
		IncProc()

		aLine  := StringToArray(FT_FReadLn())

		cCodProd  := (aLine[aScan(aCab,"E4_CODIGO")])	
		Media     := Val(StrTran(StrTran(aLine[aScan(aCab,"MEDIA")],".",""),",",".")) 	

			DbSelectArea("SE4")
			SE4->(DbSetOrder(1))
			IF SE4->(dbSeek(xFilial("SE4")+cCodProd))
	
				RecLock("SE4",.F.)
					SE4->E4_XMEDPG 	:= Media
				SE4->(MsUnlock())
	
			EndIf

		FT_FSKIP()
	EndDo 

	FT_FUSE()                            

	MsgAlert("Importação Complemento de Produto Finalizada com Sucesso!!")

Return()                         

Static FUNCTION StringToArray( cString, cSeparator ) 
	LOCAL nPos 
	LOCAL aString := {} 
	DEFAULT cSeparator := ";" 
	cString := ALLTRIM( cString ) + cSeparator 
	DO WHILE .T. 
		nPos := AT( cSeparator, cString ) 
		IF nPos = 0 
			EXIT 
		ENDIF 
		AADD( aString, SUBSTR( cString, 1, nPos-1 ) ) 
		cString := SUBSTR( cString, nPos+1 ) 
	ENDDO 
RETURN ( aString ) 
