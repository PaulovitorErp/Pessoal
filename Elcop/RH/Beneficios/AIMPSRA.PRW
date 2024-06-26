#Include "Protheus.ch"
#INCLUDE "rwmake.ch"
#include "topconn.ch"
#INCLUDE "TbiConn.ch"

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �ProcImp   �Autor  �Microsiga			 � Data �  18/04/17   ���
�������������������������������������������������������������������������͹��
���          � Importa��o de Funcionario				                  ���
�������������������������������������������������������������������������͹��
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/

User function AIMPSRA()
	Private oLeTxt

	@ 200,1 TO 380,380 DIALOG oLeTxt TITLE "Importar Amarracao Cadastro de Funcionarios x Regra"
	@ 02,10 TO 080,190
	@ 10,018 Say " Este programa ir� ler o conteudo de um arquivo texto, conforme"
	@ 18,018 Say " os parametros definidos pelo usuario, e grav�-lo em sua"
	@ 26,018 Say " respectiva tabela no Protheus. "

	@ 70,128 BMPBUTTON TYPE 01 ACTION OkLeTxt()
	@ 70,158 BMPBUTTON TYPE 02 ACTION Close(oLeTxt)

	Activate Dialog oLeTxt Centered

Return()

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �OkLeTxt   �Autor  �Microsiga           � Data �  14/05/13   ���
�������������������������������������������������������������������������͹��
���Desc.     � Fun��o que abre a tela para sele��o do arquivo que ser�    ���
���          � Importado                                                  ���
�������������������������������������������������������������������������͹��
���Uso       � AP                                                         ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/

Static Function OkLeTxt()
	Local cArqTxt := cGetFile( '*.TXT' , 'Arquivo de importa��o', 1, "", .T., GETF_LOCALHARD,.T.,.T.)
	Private nHandle := FT_FUse(cArqTxt)  
	if nHandle == -1  
		MsgAlert("O arquivo "+cArqTxt+" nao pode ser aberto! Verifique os parametros.","Aten��o!")
		Return
	Endif 

	Private _cArqTxt := cArqTxt

	Processa({|| RunCont() },"Processando...")

Return()

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �RunCont   �Autor  �Microsiga           � Data �  14/05/13   ���
�������������������������������������������������������������������������͹��
���Desc.     � Fun��o responsavel pela leitura do arquivo texto e         ���
���          � e tamb�m a grava��o dos registros lidos                    ���
�������������������������������������������������������������������������͹��
���Uso       � AP                                                         ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/

Static Function RunCont()
	nTamFile := FT_FLastRec()

	ProcRegua(nTamFile) 	// Numero de registros a processar
	FT_FGoTop()				// Posiciona na primeira linha do arquivo texto de impota��o
	SX3->(DbSetOrder(2))
	aCab  := STRTOKARR(FT_FReadLn(),";")

	FT_FSKIP()
	While !FT_FEOF()
		IncProc()

		aLine  := StringToArray(FT_FReadLn())

		cCodFil   := PADL(aLine[aScan(aCab,"RA_FILIAL")],04,'0')	
		cCodMat   := PADL(aLine[aScan(aCab,"RA_MAT")],06,'0')	
		cCodReg   := PADL(aLine[aScan(aCab,"RA_XCODREG")],06,'0')	

		DbSelectArea("SRA")
        SRA->(Dbgotop())
		SRA->(DbSetOrder(1))
		IF SRA->(dbSeek(cCodFil+cCodMat))
			RecLock("SRA",.F.)		
                SRA->RA_XREGRA   := 'S'
				SRA->RA_XCODREG  := cCodReg
			SRA->(MsUnLock())
		EndIf


		FT_FSKIP()
	EndDo 

	FT_FUSE()                            

	MsgAlert("Importa��o Arquivo Finalizada com Sucesso!!")

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
