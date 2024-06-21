#include "Totvs.ch"
#include "Protheus.ch"
#include "Topconn.ch"
#include "rwmake.ch"
#include "Fileio.ch"

/*/{Protheus.doc} User Function FIMPSR7
    Fonte utilizado para importar registros atrav�s de arquivo TXT/CSV.
	@type function
    @since 06/11/2021
    @version 1
/*/
User Function FIMPSR7() 

	Private oLeTxt
		
		@ 200,1 TO 380,380 DIALOG oLeTxt TITLE "Importar Tabela de reajuste salarial"
		@ 02,10 TO 080,190
		@ 10,018 Say " Este programa ir� ler o conte�do de um arquivo texto, conforme"
		@ 18,018 Say " os par�metros definidos pelo usu�rio, e grav�-lo em sua"
		@ 26,018 Say " respectiva tabela no Protheus. "
		
		@ 65,128 BMPBUTTON TYPE 01 ACTION OkLeTxt()
		@ 65,158 BMPBUTTON TYPE 02 ACTION Close(oLeTxt)
		
		Activate Dialog oLeTxt Centered


Return()

Static Function OkLeTxt()
	Private cDiret
	Private cLinha   := ""
	Private lPrimlin := .T.
	Private aCampos  := {}
	Private aDados   := {}
	//Local i
	//Local j 
	Private nReg     := 0
	Private cDirLog  := "C:\spool\"
	Private cArqLog  := "imp_cargos_log.txt"
	Private nHandle

	FErase("C:\spool\imp_cargos_log.txt") // Apaga arquivo de log, se existir
	nHandle := FCreate(cDirLog+cArqLog) // Cria arquivo de log

	If nHandle < 0
		MsgAlert("Erro durante cria��o do arquivo de log.","Aten��o")
	Else
		FSeek(nHandle, 0, FS_END) 
		FWrite(nHandle, "In�cio processamento: " + DToC(Date()) + " - " + Time() + CRLF + CRLF)
	EndIf

	cDiret :=  cGetFile( 	'Arquivo CSV|*.csv| Arquivo TXT|*.txt| Arquivo XML|*.xml',; //[ cMascara], 
							'Sele��o de Arquivos',;                  				  //[ cTitulo], 
							0,;                                      					//[ nMascpadrao], 
							'C:\spool\',;                            					//[ cDirinicial], 
							.F.,;                                    					//[ lSalvar], 
							GETF_LOCALHARD  + GETF_NETWORKDRIVE,;    					//[ nOpcoes], 
							.T.)         

	//MsgInfo("O arquivo escolhido � "+cDiret, "Aten��o")

	Processa({|| RunCont() },"Processando...")

Return()

Static Function RunCont()
	Local i
	Local j 

	nTamFile := FT_FLastRec()
	ProcRegua(nTamFile)

	FT_FUSE(cDiret)
	ProcRegua(FT_FLASTREC())
	FT_FGOTOP()
	While !FT_FEOF()

		IncProc("Lendo arquivo...")

		cLinha := FT_FREADLN()
		cLinha := SubStr(cLinha,0,Len(cLinha)-1) //Utilizar se existir ; no final da linha de campos.

		If lPrimlin
			aCampos := Separa(cLinha,";",.T.)
			lPrimlin := .F.
		Else
			AADD(aDados,Separa(cLinha,";",.T.))
		EndIf

		FT_FSKIP()
	EndDo

	Begin Transaction
		
		cFilial   := '0101'
		cPosMat   := 1 //AScan(aCampos, {|x| AllTrim(x) == "MATRICULA"})
		nPosValor := 2 //AScan(aCampos, {|x| AllTrim(x) == "SALARIO"})
		
		ProcRegua(Len(aDados))
		For i:=1 to Len(aDados)

			cFil  	 :=  '0101'
			cmat  	 :=  aDados[i,cPosMat]
			nSalario :=  Val(StrTran(StrTran(aDados[i,nPosValor],".",""),",","."))

			dbSelectArea("SRA")
			SRA->(dbSetOrder(1))
			SRA->(dbGoTop())
			If SRA->(dbSeek(cFil+cmat))

				dbSelectArea("SR7")
				SR7->(dbSetOrder(1))
				SR7->(dbGoTop())
				If !SR7->(dbSeek(SRA->RA_FILIAL+SRA->RA_MAT+DTOS(ddatabase)+'003'))

					IncProc("Importando registros... Matricula: "+ SRA->RA_MAT +" Registro: "+ cValToChar(nReg))
					
					Reclock("SR7",.T.)
						SR7->R7_FILIAL  := SRA->RA_FILIAL
						SR7->R7_MAT     := SRA->RA_MAT
						SR7->R7_DATA    := DDATABASE
						SR7->R7_SEQ     := '1'
						SR7->R7_TIPO    := '003'
						SR7->R7_FUNCAO  := SRA->RA_CODFUNC
						SR7->R7_DESCFUN := posicione('SRJ',1,xFilial('SRJ')+SRA->RA_CODFUNC, 'RJ_DESC') 
						SR7->R7_TIPOPGT := 'M'
						SR7->R7_CATFUNC := 'M'
						SR7->R7_USUARIO := 'IMPORT'
					//	SR7->R7_CARGO   := SRA->RA_CARGO
					//	SR7->R7_DESCCAR := POSICIONE CARGO
					SR7->(MsUnlock())

					Reclock("SR3",.T.)
						SR3->R3_FILIAL  := SRA->RA_FILIAL
						SR3->R3_MAT     := SRA->RA_MAT
						SR3->R3_DATA    := DDATABASE
						SR3->R3_SEQ     := '1'
						SR3->R3_TIPO    := '003'
						SR3->R3_PD      := '000'
						SR3->R3_DESCPD  := 'SALARIO BASE'
						SR3->R3_VALOR   := nSalario
						SR3->R3_ANTEAUM := nSalario
						SR3->R3_XOBS    := 'IMPORT'
					SR3->(MsUnlock())
					
					Reclock("SRA",.F.)
						SRA->RA_ANTEAUM := nSalario
						SRA->RA_SALARIO := nSalario
					SRA->(MsUnlock())
					
					nReg++

				EndIf
			EndIf
					
		Next i
		
	End Transaction

	FSeek(nHandle, 0, FS_END) 
	FWrite(nHandle, CRLF + "Fim processamento: " + DToC(Date()) + " - " + Time() + CRLF)
	FClose(nHandle) // Fecha arquivo de log

	ApMsgInfo(  "Processo conclu�do com sucesso!"+CRLF+CRLF+;
				"Total de campos lidos: "+cValToChar(Len(aCampos))+CRLF+;
				"Total de registros lidos: "+cValToChar(Len(aDados))+CRLF+;
				"Total de registros inseridos: "+cValToChar(nReg),"Sucesso!")

	Close(oLeTxt)

Return()
