#INCLUDE "RWMAKE.CH"
#INCLUDE "TOPCONN.CH"
#INCLUDE "PROTHEUS.CH"
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³ AESTA00  ºAutor ³Evandro Gomes        º Data ³  30/09/2020 º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Importa planilha de inventario                             º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ Funcao Auxilia                                             º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDATA      ³ ANALISTA ³  MOTIVO                                         º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±º          ³          ³                                                 º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/

User Function AESTA001
	Local cPerg		:='MESTMAT008'
	Local cSep		:=''
	Local cCtEsc	:='001'
	//->Perguntas
	AjustaSX1(cPerg)
	pergunte(cPerg,.T.)
	cSep	:= MV_PAR03
	cCtEsc	:= MV_PAR05

	//->Validacoes                    
	If Empty(MV_PAR03)
		Alert("Separador Invalido!!!")
		Return(.F.)
	Endif         

	AESTAIMP(Alltrim(MV_PAR01)+Alltrim(MV_PAR02),MV_PAR03,MV_PAR04,MV_PAR05)
	
	ApMsgInfo("Importação do Inventário efetuada com sucesso!","SUCESSO")

Return()           

/*
Importa Arquivo
*/
Static Function AESTAIMP(cArquivo,cSep,nUmed,cCtSel)
	Local aItens  := {}
	Local nCont   := 0	
	Private nHdl  := 0
	Private cEOL  := "CHR(8)"

	If Empty(Alltrim(cArquivo))
		Alert("Nao existem arquivos para importar. Processo ABORTADO")
		Return.F.	
	EndIf

	//+---------------------------------------------------------------------+
	//| Abertura do arquivo texto                                           |
	//+---------------------------------------------------------------------+
	cArqTxt := cArquivo

	nHdl := fOpen(cArqTxt,0 )
	IF nHdl == -1
		IF FERROR()== 516
			ALERT("Feche o programa que gerou o arquivo.")
		EndIF
	EndIf

	//+---------------------------------------------------------------------+
	//| Verifica se foi possÌvel abrir o arquivo                            |
	//+---------------------------------------------------------------------+
	If nHdl == -1
		MsgAlert("O arquivo de nome "+cArquivo+" nao pode ser aberto! Verifique os parametros.","Atencao!" )
		Return
	Endif

	FSEEK(nHdl,0,0 )
	nTamArq:=FSEEK(nHdl,0,2 )
	FSEEK(nHdl,0,0 )
	fClose(nHdl)

	FT_FUse(cArquivo )  //abre o arquivo
	FT_FGoTop()         //posiciona na primeira linha do arquivo
	//nTamLinha := AT(cEOL,cBuffer )
	nTamLinha := Len(FT_FREADLN() ) //Ve o tamanho da linha
	FT_FGOTOP()

	//+---------------------------------------------------------------------+
	//| Verifica quantas linhas tem o arquivo                               |
	//+---------------------------------------------------------------------+
	nLinhas := FT_FLastRec() 

	ProcRegua(nLinhas)

	While !FT_FEOF()
		IF nCont > nLinhas
			exit
		Endif

		IncProc("Lendo arquivo texto...Linha "+Alltrim(str(nCont)))
		cLinha := Alltrim(FT_FReadLn())
		nRecno := FT_FRecno() // Retorna a linha corrente

		if !empty(Alltrim(cLinha))
			aItens:={}
			aItens:=STRTOKARR(cLinha,cSep)
			AESTAEXA(aItens)
		Endif
		FT_FSKIP()  
		nCont++
	EndDo

	FT_FUSE()
	fClose(nHdl )                
Return                                        


Static Function AESTAEXA(aItens)
	Private aVetor := {}
	Private cEscolha:='N'
	Private lMsErroAuto := .F.
	
		   /*+--------------------------------------+
			|           Layout do Arquivo          |
			+---+----------------------------------+
			|POS|CAMPO                             |
			+---+----------------------------------+
			|1  |DATA DO INVENTÁRIO                |
			|2  |Nº DO DOCUMENTO DO INVENTÁRIO     |
			|3  |CÓDIGO DO PRODUTO                 |
			|4  |LOCAL(ARMAZEM)                    |
			|5  |Quantidade                        |
			|				                       |
			+---+----------------------------------+*/  
			
	aVetor := 	{;
	{"B7_FILIAL" ,			xFilial("SB7")			,Nil},;
	{"B7_DATA"	 ,			STOD(aItens[1])			,Nil},;
	{"B7_DTVALID",			STOD(aItens[1])			,Nil},;
	{"B7_DOC"    ,			aItens[2]				,Nil},;	
	{"B7_COD"	 ,			aItens[3]				,Nil},; 
	{"B7_TIPO"	 ,			POSICIONE("SB1",1,XFILIAL("SB1")+aItens[3],"B1_TIPO"),Nil},;
	{"B7_LOCAL"  ,			aItens[4]				,Nil},;
	{"B7_QUANT"	 ,          val(aItens[5])			,Nil} }

    SB7->(DbSetOrder(3)) //filial+doc+cod_local
    if !SB7->(DbSeek(xFilial("SB7")+;
        PadR(alltrim(aItens[2]),TamSx3("B7_DOC")[1])+;
        PadR(alltrim(aItens[3]),TamSx3("B7_COD")[1])+;        
        PadR(alltrim(aItens[4]),TamSx3("B7_LOCAL")[1]) ))

        SB2->(DbSetOrder(1))
        if !SB2->(DBSEEK(xFilial("SB2") + PadR(alltrim(aItens[3]),TamSx3("B7_COD")[1]) +;
										  PadR(alltrim(aItens[4]),TamSx3("B7_LOCAL")[1]) ))
										  
            CriaSB2( PadR(alltrim(aItens[3]),TamSx3("B7_COD")[1]), PadR(alltrim(aItens[4]),TamSx3("B7_LOCAL")[1]))
        endif

		MSExecAuto({|x,y,z| mata270(x,y,z)},aVetor,.F.,3)
		if lMsErroAuto
			MostraErro()
			ConOut(OemToAnsi("Erro!"))
		else
			ConOut(OemToAnsi("Atualização realizada com êxito!"))	
		EndIf 
	Endif
Return Nil

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³ AjustaSX1ºAutor ³Luis Henrique Robustoº Data ³  22/05/06   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Ajusta o SX1 - Arquivo de Perguntas..                      º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ Funcao Principal                                           º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDATA      ³ ANALISTA ³ MOTIVO                                          º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±º          ³          ³                                                 º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/

Static Function AjustaSX1(cPerg)
	Local	aRegs   := {}  
	Local 	nX		:= 1

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Campos a serem grav. no SX1³
	//³aRegs[nx][01] - X1_GRUPO   ³
	//³aRegs[nx][02] - X1_ORDEM   ³
	//³aRegs[nx][03] - X1_PERGUNTE³
	//³aRegs[nx][04] - X1_PERSPA  ³
	//³aRegs[nx][05] - X1_PERENG  ³
	//³aRegs[nx][06] - X1_VARIAVL ³
	//³aRegs[nx][07] - X1_TIPO    ³
	//³aRegs[nx][08] - X1_TAMANHO ³
	//³aRegs[nx][09] - X1_DECIMAL ³
	//³aRegs[nx][10] - X1_PRESEL  ³
	//³aRegs[nx][11] - X1_GSC     ³
	//³aRegs[nx][12] - X1_VALID   ³
	//³aRegs[nx][13] - X1_VAR01   ³
	//³aRegs[nx][14] - X1_DEF01   ³
	//³aRegs[nx][15] - X1_DEF02   ³
	//³aRegs[nx][16] - X1_DEF03   ³
	//³aRegs[nx][17] - X1_DEF04   ³
	//³aRegs[nx][18] - X1_DEF05   ³
	//³aRegs[nx][19] - X1_F3      ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Cria uma array, contendo todos os valores...³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	aAdd(aRegs,{cPerg,'01','Local do Arquivo   ?','Local do Arquivo   ?','Local do Arquivo   ?','mv_ch1','C',40,0,0,'G','','mv_par01','','','','','',''})
	aAdd(aRegs,{cPerg,'02','Nome do arquivo    ?','Nome do arquivo    ?','Nome do arquivo    ?','mv_ch2','C',20,0,0,'G','','mv_par02','','','','','',''})
	aAdd(aRegs,{cPerg,'03','Separador          ?','Separador          ?','Separador          ?','mv_ch3','C', 1,0,0,'G','','mv_par03','','','','','',''})
	aadd(aRegs,{cPerg,'04','Qual Unid. Medida  ?','Qual Unid. Medida  ?','Qual Unid. Medida  ?','mv_ch4',"N",01,0,0,"C","","mv_par04","1a. UM","","","2a. UM","","","","","","","","","","",""})
	aAdd(aRegs,{cPerg,'05','Contagem Escolha   ?','Contagem Escolha   ?','Contagem Escolha   ?','mv_ch5','C', 3,0,0,'G','','mv_par05','','','','','',''})

	DbSelectArea('SX1')
	SX1->(DbSetOrder(1))
	For nX :=1 to Len(aRegs)                           
		If	(!SX1->(DbSeek(aRegs[nx][01]+aRegs[nx][02])) )
			If	RecLock('SX1',.T.)
				Replace SX1->X1_GRUPO  		With aRegs[nx][01]
				Replace SX1->X1_ORDEM   	With aRegs[nx][02]
				Replace SX1->X1_PERGUNTE	With aRegs[nx][03]
				Replace SX1->X1_PERSPA		With aRegs[nx][04]
				Replace SX1->X1_PERENG		With aRegs[nx][05]
				Replace SX1->X1_VARIAVL		With aRegs[nx][06]
				Replace SX1->X1_TIPO		With aRegs[nx][07]
				Replace SX1->X1_TAMANHO		With aRegs[nx][08]
				Replace SX1->X1_DECIMAL		With aRegs[nx][09]
				Replace SX1->X1_PRESEL		With aRegs[nx][10]
				Replace SX1->X1_GSC			With aRegs[nx][11]
				Replace SX1->X1_VALID		With aRegs[nx][12]
				Replace SX1->X1_VAR01		With aRegs[nx][13]
				Replace SX1->X1_DEF01		With aRegs[nx][14]
				Replace SX1->X1_DEF02		With aRegs[nx][15]
				Replace SX1->X1_DEF03		With aRegs[nx][16]
				Replace SX1->X1_DEF04		With aRegs[nx][17]
				Replace SX1->X1_DEF05		With aRegs[nx][18]
				Replace SX1->X1_F3   		With aRegs[nx][19]
				SX1->(MsUnlock())
			Else
				Help('',1,'REGNOIS')
			EndIf	
		Endif
	Next nX
Return
