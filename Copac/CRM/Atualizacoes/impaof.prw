#include "totvs.ch"
#include "protheus.ch"

#DEFINE CRLF     chr(13)+chr(10)

/*
========================================================================================================================
Programa--------------: impaof
Autor-----------------: Erivaldo Oliveira 
Data da Criação-------: 30/04/2020
========================================================================================================================
Descrição-------------: Importa tarefas.
========================================================================================================================						   
Uso-------------------: ERP PROTHEUS 
========================================================================================================================
Parâmetros------------: Arquivo .csv
========================================================================================================================
Retorno---------------: Nenhum
========================================================================================================================
*/

User Function impaof()

GET_FILE()

If !Empty(cArq)
	BEGIN SEQUENCE
		Processa( {|| LeArq() }, "Aguarde...", "Processando arquivo...",.T.)
	END SEQUENCE
Else
	MsgStop("O arquivo "+cArq+" não foi encontrado. A importação será abortada!",FunName()+" - ATENCAO")
EndIf

MSGINFO("fim da importaçao.")

Return nil

//Retorna o arquivo .csv
Static Function GET_FILE()

	CTYPE := "ARQUIVO CSV     | *.CSV"
	Public cArq := CGETFILE(CTYPE, OEMTOANSI("SELECIONE O ARQUIVO "))

Return

//Lê o arquivo e faz a importação
Static Function LeArq()

	Local cLinha  	:= ""
	Local cToken	:= ";"
	Local xCodaof	:= ""
	Local cAssunto	:= ""
	Local cDescric	:= ""
	Local dDtCad	:= ctod('')
	Local dDtFim	:= ctod('')
	
	FT_FUSE(cArq)

	ProcRegua(FT_FLASTREC())

	FT_FGOTOP()

	While !FT_FEOF()

		IncProc('Importando...')

		cLinha := FT_FREADLN()

		If "Filial" $ cLInha
			FT_FSKIP()
			loop
		Endif	
		
		xCodaof		:= NEXTNUMERO("SUS",1,"US_COD",.T.)

		xCodaof		:= soma1(xCodaof)
		
		nPos := at(cToken,cLinha)
		cAssunto := substr(cLinha,1,nPos-1)
		cAssunto   := noacento(cAssunto)
		
		cLinha	:= substr(cLinha,npos+1,len(cLinha))

		nPos := at(cToken,cLinha)
		cDescric := substr(cLinha,1,nPos-1)
		cDescric   := noacento(cDescric)
		cDescric   := strtran(cDescric,'&','')
		
		cLinha	:= substr(cLinha,npos+1,len(cLinha))
		nPos := at(cToken,cLinha)		
		dDtCad := ctod(substr(cLinha,1,nPos-1))
		
		cLinha	:= substr(cLinha,npos+1,len(cLinha))
		
		dDtFim := ctod(substr(cLinha,1,10))
		
		reclock('aof',.t.)
		aof->aof_filial	:= '0101'
		aof->aof_codigo	:= xCodaof
		aof->aof_tipo	:= '1'
		aof->aof_status	:= '3'
		aof->aof_dtcad	:= dDtCad
		aof->aof_descri	:= cDescric
		aof->aof_codusr	:= retcodusr()
		aof->aof_priori	:= '2'
		aof->aof_dtinic	:= dDtCad
		aof->aof_dtfim	:= dDtFim
		aof->aof_percen	:= '5'
		aof->aof_dtfim	:= dDtFim
		aof->aof_agereu := '1'
		aof->aof_anexo  := '2'				
		aof->aof_partic := 'IMP'
		aof->(msunlock())


		FT_FSKIP()

	EndDo

	FT_FUSE()

RETURN