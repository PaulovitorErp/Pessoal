#include "totvs.ch"
#include "protheus.ch"

#DEFINE CRLF     chr(13)+chr(10)

/*
========================================================================================================================
Programa--------------: inpsus
Autor-----------------: Erivaldo Oliveira 
Data da Criação-------: 27/04/2020
========================================================================================================================
Descrição-------------: Importa suspects
========================================================================================================================						   
Uso-------------------: ERP PROTHEUS 
========================================================================================================================
Parâmetros------------: Arquivo .csv
========================================================================================================================
Retorno---------------: Nenhum
========================================================================================================================
*/

User Function impsus()

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
	Local cCod		:= ""
	Local cLoja		:= "01"
	Local cNome		:= ""
	Local cCGC		:= ""
	Local ctel		:= ""
	Local cemail	:= ""
	Local cend      := ""
	Local cmun   	:= ""
	Local ccep		:= ""
	Local cest		:= ""
	Local npos		:= 0
	
	
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
		
		cCod		:= GETSX8NUM("SUS","US_COD")
		cLoja		:= "01"

		nPos := at(cToken,cLinha)
		cNome	:= substr(cLinha,1,nPos-1)
		cNome   := noacento(cNome)
		
		cLinha	:= substr(cLinha,npos+1,len(cLinha))

		nPos := at(cToken,cLinha)
		ccgc := substr(cLinha,1,nPos-1)
		
		cLinha	:= substr(cLinha,npos+1,len(cLinha))
		
		nPos := at(cToken,cLinha)
		ctel := substr(cLinha,1,nPos-1)
		
		cLinha	:= substr(cLinha,npos+1,len(cLinha))
		
		nPos := at(cToken,cLinha)
		cemail := substr(cLinha,1,nPos-1)
		
		cLinha	:= substr(cLinha,npos+1,len(cLinha))
		nPos := at(cToken,cLinha)
		cend := substr(cLinha,1,nPos-1)
		cend := noacento(cend)
		cend := strtran(cend,'^','')
		cend := strtran(cend,'~','')
		
		cLinha	:= substr(cLinha,npos+1,len(cLinha))
	
		nPos := at(cToken,cLinha)
		cmun := substr(cLinha,1,nPos-1)

		cLinha	:= substr(cLinha,npos+1,len(cLinha))

		nPos := at(cToken,cLinha)
		ccep := substr(cLinha,1,nPos-1)
		ccep := strtran(ccep,'-','')
		ccep := strtran(ccep,'.','')
		
		cLinha	:= substr(cLinha,npos+1,len(cLinha))

		cest := cLinha
		
		If !empty(ccod)
			reclock('sus',.t.)
			sus->us_cod 	:= cCod
			sus->us_loja	:= cLoja
			sus->us_nome	:= upper(cnome)
			sus->us_nreduz	:= upper(cnome)
			sus->us_tipo	:= 'F'
			sus->us_cgc		:= ccgc
			sus->us_obs		:= ctel
			sus->us_email	:= cemail
			sus->us_end		:= cend
			sus->us_mun		:= cmun
			sus->us_cep		:= ccep
			sus->us_est		:= cest
			sus->(msunlock())
		Endif

		FT_FSKIP()

	EndDo

	FT_FUSE()

RETURN