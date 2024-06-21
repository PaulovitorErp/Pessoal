#INCLUDE "RWMAKE.CH"
#INCLUDE "TOPCONN.CH"
#INCLUDE "PROTHEUS.CH"
/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �   �Autor �ANDRE CASTILHO       � Data �     02/2024 ���
�������������������������������������������������������������������������͹��
���Desc.     � Importa planilha CADASTRO DE MOTORISTA                                    ���
�������������������������������������������������������������������������͹��
���Uso       � Funcao Auxilia                                             ���
�������������������������������������������������������������������������͹��
���DATA      � ANALISTA �  MOTIVO                                         ���
�������������������������������������������������������������������������͹��
���          �          �                                                 ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/

User Function FRTIMP()
	Local cPerg		:='GPE01'
	Local cSep		:=';'

	//->Perguntas
	AjustaSX1(cPerg)
	pergunte(cPerg,.T.)
	cSep	:= MV_PAR03

	//->Validacoes                    
	If Empty(MV_PAR03)
		Alert("Separador Invalido!!!")
		Return(.F.)
	Endif         

    if MsgYesNo("Confirma Importa��o do Arquivo => "+Alltrim(MV_PAR01)+Alltrim(MV_PAR02)+ " ?")
        Processa( {|| MCHKIMP(Alltrim(MV_PAR01)+Alltrim(MV_PAR02),MV_PAR03) }, "Aguarde...",;
                         "Importando Localiza��es ",.F.)

	    msginfo("Importa��o Finalizada..","Importa��o")
    endif

Return()           

/*
Importa Arquivo
*/
Static Function MCHKIMP(cArquivo,cSep)
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
	//| Verifica se foi poss�vel abrir o arquivo                            |
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

		if nCont == 0
			FT_FSKIP()  
			nCont++
			loop
		endif

		IncProc("Lendo arquivo texto, Linha ==> "+Alltrim(str(nCont)))
		cLinha := Alltrim(FT_FReadLn())
		nRecno := FT_FRecno() // Retorna a linha corrente

		if !empty(Alltrim(cLinha))
			aItens:={}
			aItens:=strToKarr2(cLinha,cSep,.T.)
			MCHKEXA(aItens)
		Endif
		FT_FSKIP()  
		nCont++
	EndDo

	FT_FUSE()
	fClose(nHdl )                
Return                                        

Static Function MCHKEXA(aItens)
   /*+--------------------------------------+
	|           Layout do Arquivo          |
	+---+----------------------------------+
	|POS|CAMPO                             |
	+---+----------------------------------+
	|1  |Filial            D4_FILIAL|
	|2  |Tp. Motorista    DA4_TIPMOT|
	|3  |Codigo                             |
	|4  |Motorista         DA4_NOME|
	|5  |Nome Reduzido|
    |6  |CPF               DA4_CGC|
    |7  |CENTRO DE CUSTO   DA4_AJUDA1|
    |8  |Numero CNH        DA4_NUMCNH|
    |9  |DT EX             DA4_DTECNH|
    |10 |DT VENC           DA4_DTVCNH|
    |11 |Valor                             |
	+---+----------------------------------+*/  
//RGB_FILIAL+RGB_PROCES+RGB_MAT+RGB_PERIOD+RGB_SEMANA+RGB_ROTEIR+RGB_PD+RGB_CC+RGB_ITEM+RGB_CLVL+RGB_SEQ+DTOS(RGB_DTREF)+RGB_CONVOC
//	(0101, 00001, 001264, 202102, 01, FOL, 583, 132008   ,          ,          ,  ,         ,       , 0).

 //comentado por andre 30/08/2023

  /*  RGB->(DbSetorder(1)) //RGB_FILIAL+RGB_MAT+RGB_PD+RGB_PERIOD+RGB_SEMANA+RGB_SEQ+RGB_CONVOC
	if !RGB->(DbSeek(ALLTRIM(aItens[1])+ALLTRIM(aItens[2])+ALLTRIM(aItens[8])+ALLTRIM(aItens[5])+ALLTRIM(aItens[6])))
		RGB->(Reclock("RGB",.T.))
		RGB->RGB_FILIAL := ALLTRIM(aItens[1])
		RGB->RGB_PROCES := ALLTRIM(aItens[4])
		RGB->RGB_PERIOD := ALLTRIM(aItens[5])
		RGB->RGB_SEMANA := ALLTRIM(aItens[6])
		RGB->RGB_ROTEIR := ALLTRIM(aItens[7])
		RGB->RGB_MAT    := ALLTRIM(aItens[2])
		RGB->RGB_PD     := ALLTRIM(aItens[8])
		RGB->RGB_TIPO1  := ALLTRIM(aItens[9])
		if ALLTRIM(aItens[9]) == "H"
			RGB->RGB_HORAS  := val( StrTran( aItens[11], ",", ".",":"))
		elseif ALLTRIM(aItens[9]) == "V"
				RGB->RGB_VALOR  := val( StrTran( aItens[11], ",", "."))
		endif
		RGB->RGB_CC     := Posicione("SRA",1,ALLTRIM(aItens[1])+ALLTRIM(aItens[2]),"RA_CC")
		RGB->RGB_TIPO2  := ALLTRIM(aItens[10])
		RGB->(MsUnlock())
	endif
Return Nil
*/

DA4->(DbSetorder(3)) //DA4_FILIAL+DA4_COD
	if !DA4->(DbSeek(ALLTRIM(aItens[1])+ALLTRIM(aItens[5])))
        //   DA4->(DbAppend())
	    DA4->(Reclock("DA4",.T.))
		DA4->DA4_FILIAL :=ALLTRIM('01')
		DA4->DA4_FILBAS := ALLTRIM(aItens[1])
		DA4->DA4_TIPMOT := ALLTRIM(aItens[2])
        DA4->DA4_MAT    := ALLTRIM(aItens[3])
        DA4->DA4_COD    := U_PROXDA4('DA4','DA4_COD')
		DA4->DA4_NOME   := ALLTRIM(aItens[4])
        DA4->DA4_NREDUZ := ALLTRIM(aItens[5])
		DA4->DA4_CGC    := ALLTRIM(aItens[6])
		DA4->DA4_AJUDA1 := ALLTRIM(aItens[7]) // CENTRO CUSTO
		DA4->DA4_NUMCNH    := ALLTRIM(aItens[8])
		DA4->DA4_DTECNH    := STOD(aItens[9])
		DA4->DA4_DTVCNH   :=  STOD(aItens[10])
   //     DA4->DA4_XIBOTON  := ALLTRIM(aItens[10])
		DA4->(MsUnlock())
	endif
Return Nil


/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  � AjustaSX1�Autor � Adriano Reis        � Data �  22/05/06   ���
�������������������������������������������������������������������������͹��
���Desc.     � Ajusta o SX1 - Arquivo de Perguntas..                      ���
�������������������������������������������������������������������������͹��
���Uso       � Funcao Principal                                           ���
�������������������������������������������������������������������������͹��
���DATA      � ANALISTA � MOTIVO                                          ���
�������������������������������������������������������������������������͹��
���          �          �                                                 ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/

Static Function AjustaSX1(cPerg)
	Local aRegs     := {}  
    Local _sAlias	:= Alias()
    Local i, j

    dbSelectArea("SX1")
    dbSetOrder(1)
    cPerg	:= PADR(cPerg,10)

    //          Grupo/Ordem/Pergunta          /1Perspa/2Pereng/3Variavel/4Tipo/5Tamanho/6Decimal/7Presel/8GSC/9Valid/10Var01/11Def01/12Defspa1/13Defeng1/14Cnt01/15Var02/16Def02/17Defspa2/18Defeng2/19Cnt02/20Var03/21Def03/22Defspa3/23Defeng3/24Cnt03/25Var04/26Def04/27Defspa4/28Defeng4/29Cnt04/30Var05/31Def05/32Defspa5/33Defeng5/34Cnt05/35F3
    aAdd(aRegs,{cPerg,'01','Local do Arquivo   ?','Local do Arquivo   ?','Local do Arquivo   ?','mv_ch1','C',40,0,0,'G','','mv_par01','','','','','',''})
    aAdd(aRegs,{cPerg,'02','Nome do arquivo    ?','Nome do arquivo    ?','Nome do arquivo    ?','mv_ch2','C',20,0,0,'G','','mv_par02','','','','','',''})
    aAdd(aRegs,{cPerg,'03','Separador          ?','Separador          ?','Separador          ?','mv_ch3','C', 1,0,0,'G','','mv_par03','','','','','',''})

    For i:=1 to Len(aRegs)
	    If !dbSeek(cPerg+aRegs[i,2])
		    RecLock("SX1",.T.)
    		For j:=1 to FCount()
	    		If j <= Len(aRegs[i])
		    		FieldPut(j,aRegs[i,j])
			    Endif
    		Next
	    	MsUnlock()
	    Endif
    Next

    dbSelectArea(_sAlias)
Return
