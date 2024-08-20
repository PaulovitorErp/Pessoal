#include "totvs.ch"
#include "protheus.ch"

#DEFINE CRLF     chr(13)+chr(10)

/*
========================================================================================================================
Programa--------------: incxcx
Autor-----------------: Erivaldo Oliveira 
Data da Criação-------: 25/03/2020
========================================================================================================================
Descrição-------------: Importa conjuntos.
========================================================================================================================						   
Uso-------------------: ERP PROTHEUS 
========================================================================================================================
Parâmetros------------: Arquivo .csv
========================================================================================================================
Retorno---------------: Nenhum
========================================================================================================================
*/

User Function incxcx()

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
	Local cLinAux	:= ""
	Local cToken	:= ";"
	Local cItem		:= "000"
	Local novousado := ""
	Local cnumero	:= ""
	Local cano		:= ""
	Local cfabric  := ""
	Local cmodelo	:= ""
	Local cmetros	:= ""
	Local cdi		:= ""
	Local cpintura  := ""
	Local creforma	:= ""
	Local chidrau   := ""
	Local xalias	:= getnextalias()
	
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
		
	
		nPos := at(cToken,cLinha)
		novousado	:= substr(cLinha,1,nPos-1)
		
		cLinha	:= substr(cLinha,npos+1,len(cLinha))

		nPos := at(cToken,cLinha)
		cnumero := substr(cLinha,1,nPos-1)
		
		cLinha	:= substr(cLinha,npos+1,len(cLinha))
		
		nPos := at(cToken,cLinha)
		cano := substr(cLinha,1,nPos-1)
		
		cLinha	:= substr(cLinha,npos+1,len(cLinha))
		
		nPos := at(cToken,cLinha)
		cfabric := substr(cLinha,1,nPos-1)

		cLinha	:= substr(cLinha,npos+1,len(cLinha))
	
		nPos := at(cToken,cLinha)
		cmodelo := substr(cLinha,1,nPos-1)

		cLinha	:= substr(cLinha,npos+1,len(cLinha))

		nPos := at(cToken,cLinha)
		cmetros := substr(cLinha,1,nPos-1)
		
		cLinha	:= substr(cLinha,npos+1,len(cLinha))

		nPos := at(cToken,cLinha)
		cdi := substr(cLinha,1,nPos-1)

		cLinha	:= substr(cLinha,npos+1,len(cLinha))

		nPos := at(cToken,cLinha)
		cpintura := substr(cLinha,1,nPos-1)

		cLinha	:= substr(cLinha,npos+1,len(cLinha))

		nPos := at(cToken,cLinha)
		creforma := substr(cLinha,1,nPos-1)

		cLinha	:= substr(cLinha,npos+1,len(cLinha))

		nPos := at(cToken,cLinha)
		chidrau := substr(cLinha,1,nPos-1)


		DO CASE
			CASE "CRONUS" $ cmodelo 
				 CMOD	:= '002611'
			CASE "LOTUS" $ cmodelo 
				 CMOD	:= '002605'
			CASE "BRUTUS" $ cmodelo 
				 CMOD	:= '002618'
			CASE "PLANALTO" $ cmodelo 
				 CMOD	:= '002630'
			CASE "DAMAEQ" $ cmodelo 
				 CMOD	:= '002620'
			CASE "EQUITRAN" $ cmodelo 
				 CMOD	:= '002628'
			CASE "FACCHINI" $ cmodelo 
				 CMOD	:= '002629'
			CASE "DELTA" $ cmodelo 
				 CMOD	:= '002621'
			CASE "EZC" $ cmodelo 
				 CMOD	:= '002615'
			OTHERWISE 
				 CMOD	:= ' '
		END CASE

		DO CASE
			CASE "COPAC" $ cfabric 
				 CFAB	:= '1'
			CASE "FACCHINI" $ cfabric 
				 CFAB	:= '2'
			CASE "PLANALTO" $ cfabric 
				 CFAB	:= '3'
			CASE "USIMECA" $ cfabric 
				 CFAB	:= '4'
			CASE "DAMAEQ" $ cfabric 
				 CFAB	:= '5'
			CASE "EQUITRAN" $ cfabric 
				 CFAB	:= '6'
			OTHERWISE 
				 CFAB	:= ' '
		END CASE

		DO CASE
			CASE alltrim(cdi) == "SIMPLES" 
				 DI  := 'S'
			CASE alltrim(cdi) == "DUPLO" 
				 DI  := 'D'
			CASE alltrim(cdi) == "FIXO" 
				 DI  := 'F'
			OTHERWISE
				 DI	:= ''
		END CASE
		
		DO CASE
			CASE alltrim(cpintura) == "OK" 
				 CPINT  := '002'
			OTHERWISE
				 CPINT  := '001'
		END CASE

		DO CASE
			CASE alltrim(creforma) == "OK" 
				 CREFO  := '002'
			OTHERWISE
				 CREFO  := '001'
		END CASE

		DO CASE
			CASE alltrim(chidrau) == "OK" 
				 CHIDR  := '002'
			OTHERWISE
				 CHIDR  := '001'
		END CASE

		beginsql alias xalias
			select max(xcx_codigo) as cod
			from %table:xcx% xcx
			where xcx.xcx_filial = %exp:xfilial("xcx")% and
			xcx.%notdel%
		endsql

		ccodigo	:= soma1((xalias)->cod)
		
		(xalias)->(DbCloseArea())
		
		If !empty(ccodigo)
			reclock('xcx',.t.)
			xcx->xcx_codigo := ccodigo
			xcx->xcx_novo := iif(alltrim(novousado)=='NOVO','1','2')
			xcx->xcx_codid := strzero(val(cnumero),6)
			xcx->xcx_modelo := CMOD
			xcx->xcx_descmo := POSICIONE("SB1",1,XFILIAL("SB1")+SUBSTR(CMOD,1,6),"B1_DESC")
			xcx->xcx_fabric := CFAB		
			xcx->xcx_di     := DI
			xcx->xcx_anomod := cano		
			xcx->xcx_capaci := val(substr(cmetros,1,2))		
			xcx->xcx_xstref := CREFO
			xcx->xcx_xsthid := CHIDR
			xcx->xcx_xstpin := CPINT
			xcx->xcx_idweb  := "IMP"				
			xcx->(msunlock())
		Endif

		FT_FSKIP()

	EndDo

	FT_FUSE()



RETURN